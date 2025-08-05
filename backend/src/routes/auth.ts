import express from 'express';
import bcrypt from 'bcrypt';
import jwt from 'jsonwebtoken';
import { createSession, invalidateSession, refreshSession, getValidSession, createSessionWithCleanup } from '../services/session.service';
import { authenticate, AuthenticatedRequest } from '../middleware/authenticate';
import { hasPermission } from '../services/access-control.service';
import { authLimiter, authSlowDown, registrationLimiter, passwordResetLimiter } from '../middleware/rateLimiter';
import { isAccountLocked, recordSuccessfulLogin, recordFailedLogin } from '../services/brute-force-protection.service';
import { 
  validatePassword, 
  getPasswordStrengthText, 
  getPasswordStrengthPercentage, 
  getPasswordStrengthColor 
} from '../services/password-validation.service';
import { jwtConfig } from '../config/jwt.config';
import crypto from 'crypto';
import prisma from '../libs/prisma';
import { csrfProtection, getCsrfToken } from '../middleware/csrf-protection';
import { rotateSession, CriticalAction } from '../services/session-rotation.service';
import { loggers } from '../config/logger.config';
import { mailService } from '../services/mail.service';

const router = express.Router();

// Konfiguration für Token-Lebensdauer
const ACCESS_TOKEN_EXPIRES_IN = 15 * 60; // 15 Minuten
const REFRESH_TOKEN_EXPIRES_IN = 7 * 24 * 60 * 60; // 7 Tage

// Session-Konfiguration
const ALLOW_MULTI_DEVICE_LOGIN = process.env.ALLOW_MULTI_DEVICE_LOGIN === 'true' || false;
const MAX_SESSIONS_PER_USER = parseInt(process.env.MAX_SESSIONS_PER_USER || '1', 10);

// Hilfsfunktion: Sichere Token-Generierung
function generateSecureToken(): string {
  return crypto.randomBytes(32).toString('hex'); // 256 Bit Entropie
}

// Hilfsfunktion: Access-Token generieren
function generateAccessToken(userId: number, username: string, timezone: string): string {
  const config = jwtConfig.getTokenConfig();
  return jwt.sign(
    {
      userId,
      username,
      type: 'access',
      timezone
    },
    config.secret,
    { 
      expiresIn: ACCESS_TOKEN_EXPIRES_IN,
      issuer: config.issuer,
      audience: config.audience
    }
  );
}

// Hilfsfunktion: Refresh-Token generieren
function generateRefreshToken(userId: number): string {
  const config = jwtConfig.getTokenConfig();
  return jwt.sign(
    {
      userId,
      type: 'refresh'
    },
    config.secret,
    { 
      expiresIn: REFRESH_TOKEN_EXPIRES_IN,
      issuer: config.issuer,
      audience: config.audience
    }
  );
}

// Hilfsfunktion: IP & Fingerprint extrahieren
function extractClientInfo(req: express.Request) {
  const ip = req.headers['x-forwarded-for'] || req.ip || req.socket.remoteAddress || '';
  const fingerprint = req.headers['x-device-fingerprint'] as string || req.headers['user-agent'] || 'unknown';
  return { ip: ip.toString(), fingerprint };
}

// Hilfsfunktion: Client-Zeitzone extrahieren
function extractClientTimezone(req: express.Request) {
  let timezone = req.headers['x-client-timezone'] as string;
  const clientTime = req.headers['x-client-time'] as string;
  
  // Verwende explizite Client-Headers oder UTC als Standard
  if (!timezone) {
    timezone = 'UTC'; // Internationaler Standard für APIs
  }
  
  return {
    timezone,
    clientTime: clientTime ? parseInt(clientTime) : null
  };
}

// POST /api/auth/login
router.post('/login', 
  authLimiter,      // Rate limiting
  authSlowDown,     // Progressive slow-down
  async (req: express.Request<{}, {}, { username?: string; identifier?: string; password: string }>, res) => {
  const { username, identifier, password } = req.body;
  const { ip, fingerprint } = extractClientInfo(req);

  // Support both 'username' and 'identifier' fields
  const loginIdentifier = identifier || username;

  if (!loginIdentifier || !password) {
    loggers.auth.login(loginIdentifier || 'unknown', ip, false, { 
      reason: 'missing_credentials',
      userAgent: req.headers['user-agent']
    });
    return res.status(400).json({ error: 'Benutzername und Passwort erforderlich' });
  }

  // Try to find user by username or email
  const user = await prisma.user.findFirst({
    where: {
      OR: [
        { username: loginIdentifier },
        { email: loginIdentifier }
      ]
    },
    include: { roles: true }
  });

  if (!user) {
    loggers.auth.login(loginIdentifier, ip, false, { 
      reason: 'user_not_found',
      userAgent: req.headers['user-agent']
    });
    return res.status(401).json({ error: 'Ungültige Zugangsdaten' });
  }

  // Prüfe ob Account gesperrt ist
  const lockStatus = await isAccountLocked(user.id);
  if (lockStatus.locked) {
    loggers.auth.login(loginIdentifier, ip, false, { 
      reason: 'account_locked',
      lockedUntil: lockStatus.until,
      lockType: lockStatus.until ? 'temporary' : 'permanent',
      userAgent: req.headers['user-agent']
    });
    
    if (lockStatus.until) {
      return res.status(403).json({ 
        error: 'Account temporär gesperrt',
        message: `Zu viele fehlgeschlagene Versuche. Bitte versuche es nach ${lockStatus.until.toLocaleTimeString('de-DE')} erneut.`,
        lockedUntil: lockStatus.until
      });
    } else {
      return res.status(403).json({ 
        error: 'Account gesperrt',
        message: 'Dein Account wurde gesperrt. Bitte kontaktiere den Support.'
      });
    }
  }

  const pwValid = await bcrypt.compare(password, user.passwordHash);
  if (!pwValid) {
    // Registriere fehlgeschlagenen Versuch
    const attemptResult = await recordFailedLogin(user.id);
    
    loggers.auth.login(loginIdentifier, ip, false, { 
      reason: 'invalid_password',
      remainingAttempts: attemptResult.remainingAttempts,
      isLocked: attemptResult.isLocked,
      userAgent: req.headers['user-agent']
    });
    
    if (attemptResult.isLocked) {
      return res.status(403).json({ 
        error: 'Account gesperrt',
        message: attemptResult.message,
        lockedUntil: attemptResult.lockoutUntil
      });
    }
    
    return res.status(401).json({ 
      error: 'Ungültige Zugangsdaten',
      remainingAttempts: attemptResult.remainingAttempts,
      message: attemptResult.message
    });
  }

  // Erfolgreicher Login - Reset Fehlversuche
  await recordSuccessfulLogin(user.id);

  const { timezone, clientTime } = extractClientTimezone(req);

  // Zwei-Token-System: Access-Token + Refresh-Token
  const accessToken = generateAccessToken(user.id, user.username, timezone);
  const refreshToken = generateRefreshToken(user.id);

  // Session mit Refresh-Token speichern
  try {
    await createSessionWithCleanup(
      user.id, 
      refreshToken, 
      ip, 
      fingerprint, 
      timezone, 
      clientTime || undefined,
      {
        keepExistingSessions: ALLOW_MULTI_DEVICE_LOGIN,
        maxSessionsPerUser: MAX_SESSIONS_PER_USER
      }
    );
  } catch (error) {
    loggers.system.error('Session creation failed during login', error, {
      userId: user.id,
      username: user.username,
      ip,
      fingerprint
    });
    return res.status(500).json({ error: 'Session-Erstellung fehlgeschlagen' });
  }

  // Erfolgreicher Login loggen
  loggers.auth.login(loginIdentifier, ip, true, {
    userId: user.id,
    email: user.email,
    timezone,
    fingerprint: fingerprint.substring(0, 50), // Kurze Version für Log
    sessionType: 'access_refresh_tokens',
    multiDevice: ALLOW_MULTI_DEVICE_LOGIN,
    userAgent: req.headers['user-agent']
  });

  return res.status(200).json({
    accessToken,
    refreshToken,
    expiresIn: ACCESS_TOKEN_EXPIRES_IN,
    refreshExpiresIn: REFRESH_TOKEN_EXPIRES_IN,
    user: {
      id: user.id,
      username: user.username,
      email: user.email
    }
  });
});

// POST /api/auth/logout
router.post('/logout', authenticate, csrfProtection, async (req: AuthenticatedRequest, res) => {
  if (!req.user) {
    return res.status(401).json({ error: 'Nicht authentifiziert' });
  }

  const { ip } = extractClientInfo(req);
  const authHeader = req.headers.authorization;
  
  if (!authHeader?.startsWith('Bearer ')) {
    loggers.auth.logout(req.user.username, ip, { 
      success: false,
      reason: 'invalid_token_format',
      userAgent: req.headers['user-agent']
    });
    return res.status(401).json({ error: 'Kein gültiges Token übergeben' });
  }

  const token = authHeader.split(' ')[1];

  try {
    // Session invalidieren (Refresh-Token löschen)
    const result = await invalidateSession(req.user.id, token);

    // Erfolgreicher Logout loggen
    loggers.auth.logout(req.user.username, ip, {
      success: true,
      userId: req.user.id,
      sessionsDeleted: result.count,
      userAgent: req.headers['user-agent']
    });

    return res.status(200).json({ success: true, deleted: result.count });
  } catch (err) {
    loggers.auth.logout(req.user!.username, ip, {
      success: false,
      reason: 'logout_error',
      error: err instanceof Error ? err.message : 'Unknown error',
      userAgent: req.headers['user-agent']
    });
    return res.status(500).json({ error: 'Interner Serverfehler' });
  }
});

// POST /api/auth/register
router.post('/register', 
  registrationLimiter,  // IP-basiertes Limit
  authLimiter,          // Generelles Auth-Limit
  async (req: express.Request<{}, {}, { username: string; email: string; password: string }>, res) => {
  const { username, email, password } = req.body;
  const { ip, fingerprint } = extractClientInfo(req);

  const emailRegex = /^[^@]+@[^@]+\.[^@]+$/;
  if (!username || !email || !password) {
    loggers.auth.register(username || 'unknown', email || 'unknown', ip, {
      success: false,
      reason: 'missing_fields',
      userAgent: req.headers['user-agent']
    });
    return res.status(400).json({ error: 'Alle Felder (username, email, password) sind erforderlich.' });
  }
  if (!emailRegex.test(email)) {
    loggers.auth.register(username, email, ip, {
      success: false,
      reason: 'invalid_email_format',
      userAgent: req.headers['user-agent']
    });
    return res.status(400).json({ error: 'Ungültige E-Mail-Adresse.' });
  }
  
  // Erweiterte Passwort-Validierung
  const passwordValidation = validatePassword(password, [username, email]);
  
  if (!passwordValidation.valid) {
    loggers.auth.register(username, email, ip, {
      success: false,
      reason: 'weak_password',
      passwordScore: passwordValidation.score,
      userAgent: req.headers['user-agent']
    });
    return res.status(400).json({ 
      error: 'Passwort erfüllt nicht die Sicherheitsanforderungen',
      details: {
        score: passwordValidation.score,
        feedback: passwordValidation.feedback,
        suggestions: passwordValidation.suggestions,
        estimatedCrackTime: passwordValidation.estimatedCrackTime
      }
    });
  }

  try {
    // Prüfe auf vorhandenen User
    const userByUsername = await prisma.user.findUnique({ where: { username } });
    const userByEmail = await prisma.user.findUnique({ where: { email } });
    if (userByUsername || userByEmail) {
      loggers.auth.register(username, email, ip, {
        success: false,
        reason: 'user_already_exists',
        conflictType: userByUsername ? 'username' : 'email',
        userAgent: req.headers['user-agent']
      });
      return res.status(409).json({ error: 'Benutzername oder E-Mail bereits vergeben.' });
    }

    // Passwort hashen
    const passwordHash = await bcrypt.hash(password, 10);

    // User anlegen mit Standard-User-Rolle in einer Transaktion
    const result = await prisma.$transaction(async (tx) => {
      // User erstellen
      const user = await tx.user.create({
        data: {
          username,
          email,
          passwordHash,
        }
      });

      // Prüfe ob Rollen existieren
      const roleCount = await tx.role.count();
      
      if (roleCount === 0) {
        loggers.system.error('No roles found in database - seeds not executed', new Error('Database not seeded'), {
          roleCount: 0,
          expectedAction: 'npm run seed'
        });
        throw new Error('Keine Rollen in Datenbank. Seeds wurden nicht ausgeführt!');
      }

      // Standard-User-Rolle finden
      const userRole = await tx.role.findUnique({
        where: { name: 'user' }
      });

      if (!userRole) {
        const allRoles = await tx.role.findMany({ select: { name: true } });
        loggers.system.error('Standard user role not found', new Error('User role missing'), {
          availableRoles: allRoles.map(r => r.name),
          expectedRole: 'user',
          expectedAction: 'npm run seed'
        });
        throw new Error('Standard-User-Rolle nicht gefunden. Bitte Seeds ausführen: npm run seed');
      }

      loggers.system.info('User role found during registration', {
        roleId: userRole.id,
        roleName: userRole.name
      });

      // Beide Rollen-Einträge erstellen (global und world)
      // Erstelle global role
      const globalRole = await tx.userRole.create({
        data: {
          userId: user.id,
          roleId: userRole.id,
          scopeType: 'global',
          scopeObjectId: 'global'
        }
      });

      // Erstelle world role
      const worldRole = await tx.userRole.create({
        data: {
          userId: user.id,
          roleId: userRole.id,
          scopeType: 'world',
          scopeObjectId: '*'  // Wildcard für alle Welten
        }
      });

      loggers.system.info('Created roles for user', {
        userId: user.id,
        username: user.username,
        globalRoleId: globalRole.id,
        worldRoleId: worldRole.id
      });

      return user;
    });

    // Verifiziere die Rollen-Zuweisung
    const userWithRoles = await prisma.user.findUnique({
      where: { id: result.id },
      include: {
        roles: {
          include: {
            role: true
          }
        }
      }
    });

    loggers.system.info('User created', {
      userId: result.id,
      username: result.username,
      email: result.email,
      roleCount: userWithRoles?.roles.length || 0
    });

    // Debug-Info für den Client
    const debugInfo = {
      rolesCount: userWithRoles?.roles.length || 0,
      roleDetails: userWithRoles?.roles.map(r => ({
        roleId: r.roleId,
        roleName: r.role.name,
        scopeType: r.scopeType,
        scopeObjectId: r.scopeObjectId
      }))
    };

    // Token generieren nach erfolgreicher Registrierung
    const { timezone, clientTime } = extractClientTimezone(req);
    
    const accessToken = generateAccessToken(result.id, result.username, timezone);
    const refreshToken = generateRefreshToken(result.id);
    
    // Session erstellen
    try {
      await createSessionWithCleanup(
        result.id, 
        refreshToken, 
        ip, 
        fingerprint, 
        timezone, 
        clientTime || undefined,
        {
          keepExistingSessions: ALLOW_MULTI_DEVICE_LOGIN,
          maxSessionsPerUser: MAX_SESSIONS_PER_USER
        }
      );
    } catch (error) {
      loggers.system.error('Session creation failed after registration', error, {
        userId: result.id,
        username: result.username,
        ip,
        fingerprint
      });
      // Registrierung war erfolgreich, also geben wir trotzdem die Tokens zurück
    }

    // Erfolgreiche Registrierung loggen
    loggers.auth.register(username, email, ip, {
      success: true,
      userId: result.id,
      rolesAssigned: userWithRoles?.roles.length || 0,
      timezone,
      userAgent: req.headers['user-agent']
    });

    return res.status(201).json({
      accessToken,
      refreshToken,
      expiresIn: ACCESS_TOKEN_EXPIRES_IN,
      refreshExpiresIn: REFRESH_TOKEN_EXPIRES_IN,
      user: {
        id: result.id,
        username: result.username,
        email: result.email,
        // Temporär für Debugging
        _debug: debugInfo
      }
    });
  } catch (error) {
    loggers.system.error('Registration failed', error, {
      username,
      email,
      ip,
      userAgent: req.headers['user-agent'],
      errorDetails: error instanceof Error ? error.message : 'Unknown error'
    });
    
    // Fehler loggen
    loggers.auth.register(username, email, ip, {
      success: false,
      reason: 'database_error',
      error: error instanceof Error ? error.message : 'Unknown error',
      userAgent: req.headers['user-agent']
    });
    
    // Detailliertere Fehlermeldung für den Client
    let errorMessage = 'Fehler bei der Registrierung';
    let errorDetails = {};
    
    if (error instanceof Error) {
      if (error.message.includes('Standard-User-Rolle nicht gefunden')) {
        errorMessage = 'Datenbank nicht korrekt initialisiert. Bitte Administrator kontaktieren.';
        errorDetails = {
          hint: 'Seeds müssen ausgeführt werden: npm run seed',
          missingRole: 'user'
        };
      }
      errorDetails = { ...errorDetails, message: error.message };
    }
    
    return res.status(500).json({ 
      error: errorMessage,
      details: errorDetails 
    });
  }
});

// POST /api/auth/request-reset
router.post('/request-reset', 
  passwordResetLimiter,  // Sehr striktes Limit
  async (req, res) => {
  const { email } = req.body;
  if (!email) {
    return res.status(400).json({ error: 'E-Mail erforderlich' });
  }
  const user = await prisma.user.findUnique({ where: { email } });
  if (!user) {
    // Immer Erfolg zurückgeben, um Enumeration zu verhindern
    return res.status(200).json({ message: 'Reset-Mail verschickt (falls E-Mail existiert)' });
  }
  // Token generieren
  const token = crypto.randomBytes(32).toString('hex');
  const expiresAt = new Date(Date.now() + 1000 * 60 * 60); // 1h gültig
  await prisma.passwordReset.create({
    data: {
      userId: user.id,
      token,
      expiresAt
    }
  });
  // Mail-Versand mit Token (wenn konfiguriert)
  if (mailService.isEnabled()) {
    try {
      await mailService.sendPasswordResetMail({
        email: user.email,
        username: user.username,
        resetToken: token
      }, process.env.PUBLIC_CLIENT_URL || 'https://192.168.2.168');
      
      loggers.system.info('📧 Password-Reset-Mail versendet', {
        to: user.email,
        username: user.username
      });
    } catch (error) {
      loggers.system.error('❌ Password-Reset-Mail Versand fehlgeschlagen', {
        to: user.email,
        username: user.username,
        error
      });
      // Fehler beim Mail-Versand soll den Reset-Prozess nicht stoppen
    }
  }
  
  return res.status(200).json({ message: 'Reset-Mail verschickt (falls E-Mail existiert)' });
});

// POST /api/auth/reset-password
router.post('/reset-password', async (req, res) => {
  const { token, password } = req.body;
  
  loggers.system.info('🔄 Password-Reset Versuch', {
    tokenPreview: token ? token.substring(0, 8) + '...' : 'missing',
    hasPassword: !!password,
    passwordLength: password ? password.length : 0,
    endpoint: '/auth/reset-password'
  });

  if (!token || !password) {
    loggers.system.warn('❌ Password-Reset: Fehlende Parameter', {
      hasToken: !!token,
      hasPassword: !!password
    });
    return res.status(400).json({ error: 'Token und neues Passwort erforderlich' });
  }

  try {
    const reset = await prisma.passwordReset.findUnique({ where: { token } });
    
    if (!reset) {
      loggers.system.warn('❌ Password-Reset: Token nicht gefunden', {
        tokenPreview: token.substring(0, 8) + '...'
      });
      return res.status(400).json({ error: 'Ungültiger oder abgelaufener Token' });
    }

    if (reset.usedAt) {
      loggers.system.warn('❌ Password-Reset: Token bereits verwendet', {
        tokenPreview: token.substring(0, 8) + '...',
        usedAt: reset.usedAt,
        userId: reset.userId
      });
      return res.status(400).json({ error: 'Ungültiger oder abgelaufener Token' });
    }

    if (reset.expiresAt < new Date()) {
      loggers.system.warn('❌ Password-Reset: Token abgelaufen', {
        tokenPreview: token.substring(0, 8) + '...',
        expiresAt: reset.expiresAt,
        userId: reset.userId
      });
      return res.status(400).json({ error: 'Ungültiger oder abgelaufener Token' });
    }

    // Passwort-Validierung (mindestens 6 Zeichen)
    if (password.length < 6) {
      loggers.system.warn('❌ Password-Reset: Passwort zu kurz', {
        passwordLength: password.length,
        userId: reset.userId
      });
      return res.status(400).json({ error: 'Passwort muss mindestens 6 Zeichen lang sein' });
    }

    // Passwort setzen
    const passwordHash = await bcrypt.hash(password, 10);
    await prisma.user.update({
      where: { id: reset.userId },
      data: { passwordHash }
    });
    
    await prisma.passwordReset.update({
      where: { id: reset.id },
      data: { usedAt: new Date() }
    });

    loggers.system.info('✅ Password erfolgreich zurückgesetzt', {
      userId: reset.userId,
      tokenPreview: token.substring(0, 8) + '...'
    });

    return res.status(200).json({ message: 'Passwort erfolgreich geändert' });
  } catch (error) {
    loggers.system.error('❌ Password-Reset Fehler', error, {
      tokenPreview: token ? token.substring(0, 8) + '...' : 'missing'
    });
    
    return res.status(500).json({ error: 'Interner Serverfehler' });
  }
});

// POST /api/auth/refresh
router.post('/refresh', async (req, res) => {
  const authHeader = req.headers.authorization;
  if (!authHeader?.startsWith('Bearer ')) {
    return res.status(401).json({ error: 'Kein gültiges Token übergeben' });
  }

  const token = authHeader.split(' ')[1];
  const { fingerprint } = extractClientInfo(req);

  try {
    // Refresh-Token verifizieren
    const decoded = jwt.verify(
      token,
      jwtConfig.getSecret()
    ) as { userId: number; type: string; exp: number };

    // Prüfen ob es ein Refresh-Token ist
    if (decoded.type !== 'refresh') {
      return res.status(401).json({ error: 'Ungültiger Token-Typ für Refresh' });
    }

    // Session in Datenbank prüfen
    const session = await getValidSession(decoded.userId, token, fingerprint);
    if (!session) {
      return res.status(401).json({ error: 'Session nicht gefunden oder abgelaufen' });
    }

    // User-Daten laden
    const user = await prisma.user.findUnique({
      where: { id: decoded.userId },
      select: { username: true }
    });

    if (!user) {
      return res.status(401).json({ error: 'Benutzer nicht gefunden' });
    }

    // Neuen Access-Token generieren
    const newAccessToken = generateAccessToken(decoded.userId, user.username, session.timezone || 'UTC');

    // Session aktualisieren (lastAccessedAt)
    await refreshSession(decoded.userId, token);

    return res.status(200).json({ 
      success: true, 
      accessToken: newAccessToken,
      expiresIn: ACCESS_TOKEN_EXPIRES_IN
    });
  } catch (error) {
    return res.status(401).json({ error: 'Ungültiges Refresh-Token' });
  }
});

// POST /api/auth/check-password-strength
router.post('/check-password-strength', async (req, res) => {
  const { password, username, email } = req.body;

  if (!password) {
    return res.status(400).json({ 
      error: 'Passwort ist erforderlich',
      score: 0,
      valid: false
    });
  }

  // Validiere Passwort mit optionalen User-Inputs
  const userInputs: string[] = [];
  if (username) userInputs.push(username);
  if (email) userInputs.push(email);

  const validation = validatePassword(password, userInputs);

  return res.status(200).json({
    valid: validation.valid,
    score: validation.score,
    feedback: validation.feedback,
    suggestions: validation.suggestions,
    estimatedCrackTime: validation.estimatedCrackTime,
    strengthText: getPasswordStrengthText(validation.score),
    strengthPercentage: getPasswordStrengthPercentage(validation.score),
    strengthColor: getPasswordStrengthColor(validation.score)
  });
});

// GET /api/auth/roles-check (Debug-Endpoint)
router.get('/roles-check', async (req, res) => {
  try {
    const roles = await prisma.role.findMany({
      include: {
        permissions: {
          include: {
            permission: true
          }
        }
      }
    });
    
    const userCount = await prisma.user.count();
    const userRoleCount = await prisma.userRole.count();
    
    res.json({
      status: 'ok',
      roleCount: roles.length,
      roles: roles.map(r => ({
        id: r.id,
        name: r.name,
        permissionCount: r.permissions.length
      })),
      userCount,
      userRoleCount,
      seedsExecuted: roles.length > 0
    });
  } catch (error) {
    res.status(500).json({
      status: 'error',
      message: 'Fehler beim Prüfen der Rollen',
      error: error instanceof Error ? error.message : 'Unknown error'
    });
  }
});

// GET /api/auth/me
router.get('/me', authenticate, async (req: AuthenticatedRequest, res) => {
  // Permission prüfen: system.view_own (global scope)
  // Jeder authentifizierte User kann seine eigenen Daten sehen
  const allowed = await hasPermission(req.user!.id, 'system.view_own', {
    type: 'global',
    objectId: 'global'
  });

  if (!allowed) {
    return res.status(403).json({ error: 'Keine Berechtigung zum Anzeigen der eigenen Daten' });
  }

  const user = await prisma.user.findUnique({
    where: { id: req.user!.id },
    select: {
      id: true,
      username: true,
      email: true,
      roles: {
        include: {
          role: {
            include: {
              permissions: {
                include: {
                  permission: true
                }
              }
            }
          }
        }
      }
    }
  });
  if (!user) {
    return res.status(404).json({ error: 'User not found' });
  }
  res.json(user);
});

// === CSRF-Token Endpoint ===
router.get('/csrf-token', authenticate, getCsrfToken);

// === Passwort ändern ===
router.post('/change-password', 
  authenticate, 
  csrfProtection,
  authLimiter,
  async (req: AuthenticatedRequest, res) => {
    if (!req.user) {
      return res.status(401).json({ error: 'Nicht authentifiziert' });
    }

    const { currentPassword, newPassword } = req.body;
    const { ip, fingerprint } = extractClientInfo(req);

    // Validierung
    if (!currentPassword || !newPassword) {
      loggers.auth.passwordChange(req.user.username, ip, {
        success: false,
        reason: 'missing_passwords',
        userAgent: req.headers['user-agent']
      });
      return res.status(400).json({ 
        error: 'Aktuelles und neues Passwort erforderlich' 
      });
    }

    try {
      // 1. Benutzer abrufen
      const user = await prisma.user.findUnique({
        where: { id: req.user.id }
      });

      if (!user) {
        loggers.auth.passwordChange(req.user.username, ip, {
          success: false,
          reason: 'user_not_found',
          userAgent: req.headers['user-agent']
        });
        return res.status(404).json({ error: 'Benutzer nicht gefunden' });
      }

      // 2. Aktuelles Passwort verifizieren
      const isValidPassword = await bcrypt.compare(currentPassword, user.passwordHash);
      if (!isValidPassword) {
        // Rate Limiting für fehlgeschlagene Versuche
        await recordFailedLogin(user.id);
        loggers.auth.passwordChange(req.user.username, ip, {
          success: false,
          reason: 'invalid_current_password',
          userAgent: req.headers['user-agent']
        });
        return res.status(401).json({ 
          error: 'Aktuelles Passwort ist falsch' 
        });
      }

      // 3. Neues Passwort validieren
      const passwordValidation = validatePassword(newPassword, [user.username, user.email]);
      if (!passwordValidation.valid) {
        loggers.auth.passwordChange(req.user.username, ip, {
          success: false,
          reason: 'weak_new_password',
          passwordScore: passwordValidation.score,
          userAgent: req.headers['user-agent']
        });
        return res.status(400).json({
          error: 'Neues Passwort erfüllt nicht die Sicherheitsanforderungen',
          details: {
            score: passwordValidation.score,
            feedback: passwordValidation.feedback,
            suggestions: passwordValidation.suggestions,
            estimatedCrackTime: passwordValidation.estimatedCrackTime
          }
        });
      }

      // 4. Prüfen ob neues Passwort != altes Passwort
      const isSamePassword = await bcrypt.compare(newPassword, user.passwordHash);
      if (isSamePassword) {
        loggers.auth.passwordChange(req.user.username, ip, {
          success: false,
          reason: 'same_password',
          userAgent: req.headers['user-agent']
        });
        return res.status(400).json({ 
          error: 'Neues Passwort darf nicht mit dem aktuellen übereinstimmen' 
        });
      }

      // 5. Passwort hashen und speichern
      const hashedPassword = await bcrypt.hash(newPassword, 10);
      await prisma.user.update({
        where: { id: user.id },
        data: { 
          passwordHash: hashedPassword
        }
      });

      // 6. Session Rotation durchführen
      const timezone = req.headers['x-timezone'] as string;
      
      const newTokens = await rotateSession(
        user.id,
        CriticalAction.PASSWORD_CHANGE,
        ip,
        fingerprint,
        timezone
      );

      // Erfolgreiche Passwort-Änderung loggen
      loggers.auth.passwordChange(req.user.username, ip, {
        success: true,
        userId: user.id,
        sessionRotated: true,
        timezone,
        userAgent: req.headers['user-agent']
      });

      // 7. Erfolg mit neuen Tokens
      return res.status(200).json({
        message: 'Passwort erfolgreich geändert',
        ...newTokens,
        sessionRotated: true
      });

    } catch (error) {
      loggers.auth.passwordChange(req.user.username, ip, {
        success: false,
        reason: 'system_error',
        error: error instanceof Error ? error.message : 'Unknown error',
        userAgent: req.headers['user-agent']
      });
      return res.status(500).json({ 
        error: 'Interner Serverfehler' 
      });
    }
  }
);

/**
 * GET /api/auth/permissions
 * Lädt ARB-spezifische Permissions des aktuellen Users
 */
router.get('/permissions', authenticate, async (req: AuthenticatedRequest, res) => {
  try {
    const userId = req.user!.id;
    
    // Liste aller ARB-Permissions die wir prüfen wollen
    const arbPermissions = [
      'arb.view',
      'arb.edit', 
      'arb.save',
      'arb.backup.view',
      'arb.backup.restore',
      'arb.backup.delete',
      'arb.export', 
      'arb.import',
      'arb.compare'
    ];
    
    // Prüfe alle Permissions
    const permissions: Record<string, boolean> = {};
    
    for (const permission of arbPermissions) {
      permissions[permission] = await hasPermission(userId, permission, { 
        type: 'global', 
        objectId: 'global' 
      });
    }
    
    res.json({
      success: true,
      permissions,
      user: {
        id: userId,
        username: req.user!.username
      }
    });
    
  } catch (error) {
    loggers.system.error('Error loading user permissions', error, {
      userId: req.user?.id
    });
    res.status(500).json({ error: 'Fehler beim Laden der Berechtigungen' });
  }
});

export default router;
