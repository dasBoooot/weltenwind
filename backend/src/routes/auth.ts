import express from 'express';
import bcrypt from 'bcrypt';
import jwt from 'jsonwebtoken';
import { createSession, invalidateSession, refreshSession, getValidSession } from '../services/session.service';
import { authenticate, AuthenticatedRequest } from '../middleware/authenticate';
import { hasPermission } from '../services/access-control.service';
import crypto from 'crypto';
import prisma from '../libs/prisma';

const router = express.Router();

// Konfiguration für Token-Lebensdauer
const ACCESS_TOKEN_EXPIRES_IN = 15 * 60; // 15 Minuten
const REFRESH_TOKEN_EXPIRES_IN = 7 * 24 * 60 * 60; // 7 Tage

// Hilfsfunktion: Sichere Token-Generierung
function generateSecureToken(): string {
  return crypto.randomBytes(32).toString('hex'); // 256 Bit Entropie
}

// Hilfsfunktion: Access-Token generieren
function generateAccessToken(userId: number, username: string, timezone: string): string {
  return jwt.sign(
    {
      userId,
      username,
      type: 'access',
      timezone
    },
    process.env.JWT_SECRET || 'dev-secret',
    { 
      expiresIn: ACCESS_TOKEN_EXPIRES_IN,
      issuer: 'weltenwind-api',
      audience: 'weltenwind-client'
    }
  );
}

// Hilfsfunktion: Refresh-Token generieren
function generateRefreshToken(userId: number): string {
  return jwt.sign(
    {
      userId,
      type: 'refresh'
    },
    process.env.JWT_SECRET || 'dev-secret',
    { 
      expiresIn: REFRESH_TOKEN_EXPIRES_IN,
      issuer: 'weltenwind-api',
      audience: 'weltenwind-client'
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
router.post('/login', async (req: express.Request<{}, {}, { username: string; password: string }>, res) => {
  const { username, password } = req.body;

  if (!username || !password) {
    return res.status(400).json({ error: 'Benutzername und Passwort erforderlich' });
  }

  const user = await prisma.user.findUnique({
    where: { username },
    include: { roles: true }
  });

  if (!user || user.isLocked) {
    const clientIp = req.headers['x-forwarded-for'] || req.ip || req.socket.remoteAddress || 'unknown';
    console.warn(`Login-Fail for ${username} (user not found or locked) from ${clientIp}`);
    return res.status(401).json({ error: 'Zugriff verweigert' });
  }

  const pwValid = await bcrypt.compare(password, user.passwordHash);
  if (!pwValid) {
    const clientIp = req.headers['x-forwarded-for'] || req.ip || req.socket.remoteAddress || 'unknown';
    console.warn(`Login-Fail for ${username} (wrong password) from ${clientIp}`);
    return res.status(401).json({ error: 'Ungültige Zugangsdaten' });
  }

  const { ip, fingerprint } = extractClientInfo(req);
  const { timezone, clientTime } = extractClientTimezone(req);

  // Zwei-Token-System: Access-Token + Refresh-Token
  const accessToken = generateAccessToken(user.id, user.username, timezone);
  const refreshToken = generateRefreshToken(user.id);

  // Session mit Refresh-Token speichern
  try {
    await createSession(user.id, refreshToken, ip, fingerprint, timezone, clientTime || undefined);
  } catch (error) {
    console.error('Session-Erstellung fehlgeschlagen:', error);
    return res.status(500).json({ error: 'Session-Erstellung fehlgeschlagen' });
  }

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
router.post('/logout', async (req, res) => {
  const authHeader = req.headers.authorization;
  if (!authHeader?.startsWith('Bearer ')) {
    return res.status(401).json({ error: 'Kein gültiges Token übergeben' });
  }

  const token = authHeader.split(' ')[1];

  try {
    // Token verifizieren (kann Access- oder Refresh-Token sein)
    const payload = jwt.verify(
      token,
      process.env.JWT_SECRET || 'dev-secret'
    ) as { userId: number; type?: string };

    // Session invalidieren (Refresh-Token löschen)
    const result = await invalidateSession(payload.userId, token);

    return res.status(200).json({ success: true, deleted: result.count });
  } catch (err) {
    return res.status(401).json({ error: 'Ungültiges oder abgelaufenes Token' });
  }
});

// POST /api/auth/register
router.post('/register', async (req: express.Request<{}, {}, { username: string; email: string; password: string }>, res) => {
  const { username, email, password } = req.body;

  const emailRegex = /^[^@]+@[^@]+\.[^@]+$/;
  if (!username || !email || !password) {
    return res.status(400).json({ error: 'Alle Felder (username, email, password) sind erforderlich.' });
  }
  if (!emailRegex.test(email)) {
    return res.status(400).json({ error: 'Ungültige E-Mail-Adresse.' });
  }
  if (password.length < 8) {
    return res.status(400).json({ error: 'Passwort muss mindestens 8 Zeichen lang sein.' });
  }

  // Prüfe auf vorhandenen User
  const userByUsername = await prisma.user.findUnique({ where: { username } });
  const userByEmail = await prisma.user.findUnique({ where: { email } });
  if (userByUsername || userByEmail) {
    return res.status(409).json({ error: 'Benutzername oder E-Mail bereits vergeben.' });
  }

  // Passwort hashen
  const passwordHash = await bcrypt.hash(password, 10);

  // User anlegen mit Standard-User-Rolle
  const user = await prisma.user.create({
    data: {
      username,
      email,
      passwordHash,
    }
  });

  // Standard-User-Rolle zuweisen
  const userRole = await prisma.role.findUnique({
    where: { name: 'user' }
  });

  if (userRole) {
    await prisma.userRole.create({
      data: {
        userId: user.id,
        roleId: userRole.id,
        scopeType: 'global',
        scopeObjectId: 'global'
      }
    });
  }

  return res.status(201).json({
    user: {
      id: user.id,
      username: user.username,
      email: user.email
    }
  });
});

// POST /api/auth/request-reset
router.post('/request-reset', async (req, res) => {
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
  // TODO: Mail-Versand mit Token
  return res.status(200).json({ message: 'Reset-Mail verschickt (falls E-Mail existiert)' });
});

// POST /api/auth/reset-password
router.post('/reset-password', async (req, res) => {
  const { token, password } = req.body;
  if (!token || !password) {
    return res.status(400).json({ error: 'Token und neues Passwort erforderlich' });
  }
  const reset = await prisma.passwordReset.findUnique({ where: { token } });
  if (!reset || reset.usedAt || reset.expiresAt < new Date()) {
    return res.status(400).json({ error: 'Ungültiger oder abgelaufener Token' });
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
  return res.status(200).json({ message: 'Passwort erfolgreich geändert' });
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
      process.env.JWT_SECRET || 'dev-secret'
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

export default router;
