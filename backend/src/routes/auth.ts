import express from 'express';
import bcrypt from 'bcrypt';
import jwt from 'jsonwebtoken';
import { createSession, invalidateSession, refreshSession } from '../services/session.service';
import { authenticate, AuthenticatedRequest } from '../middleware/authenticate';
import { hasPermission } from '../services/access-control.service';
import crypto from 'crypto';
import prisma from '../libs/prisma';

const router = express.Router();

// Hilfsfunktion: Sichere Token-Generierung
function generateSecureToken(): string {
  return crypto.randomBytes(32).toString('hex'); // 256 Bit Entropie
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

  // JWT erzeugen mit Client-Zeitzonen-Berücksichtigung
  const serverNow = Math.floor(Date.now() / 1000);
  // Verwende Server-Zeit für JWT, aber speichere Client-Zeitzone
  const jwtNow = Math.floor(Date.now() / 1000); // Server-Zeit in Sekunden
  const expiresIn = parseInt(process.env.JWT_EXPIRES_IN_SECONDS || '900'); // 15 Minuten
  
  const token = jwt.sign(
    {
      userId: user.id,
      username: user.username,
      iat: jwtNow,
      exp: jwtNow + expiresIn,
      timezone: timezone
    },
    process.env.JWT_SECRET || 'dev-secret',
    { 
      issuer: 'weltenwind-api',
      audience: 'weltenwind-client'
    }
  );

  // Session erzeugen mit Client-Zeitzonen-Informationen
  try {
    await createSession(user.id, token, ip, fingerprint, timezone, clientTime || undefined);
  } catch (error) {
    // Bei Session-Erstellungsfehler trotzdem Token zurückgeben
    console.error('Session-Erstellung fehlgeschlagen:', error);
  }

  return res.status(200).json({
    token,
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
    const payload = jwt.verify(
      token,
      process.env.JWT_SECRET || 'dev-secret'
    ) as { userId: number };

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

  // User anlegen
  const user = await prisma.user.create({
    data: {
      username,
      email,
      passwordHash,
    }
  });

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
    // Token verifizieren (mit Toleranz für abgelaufene Tokens)
    const decoded = jwt.verify(
      token,
      process.env.JWT_SECRET || 'dev-secret'
    ) as { userId: number; exp: number };

    // Prüfen ob Token noch nicht zu alt ist (max 1 Stunde Toleranz)
    const now = Math.floor(Date.now() / 1000);
    if (decoded.exp < now - 3600) { // 1 Stunde Toleranz
      return res.status(401).json({ error: 'Token zu alt für Refresh' });
    }

    // Session aktualisieren
    const result = await refreshSession(decoded.userId, token);
    
    if (result.count === 0) {
      return res.status(401).json({ error: 'Session nicht gefunden oder abgelaufen' });
    }

    // Neuen Token generieren (konsistent mit authenticate-Middleware)
    const newToken = jwt.sign(
      {
        userId: decoded.userId,
        username: (decoded as any).username || 'user',
        iat: now
      },
      process.env.JWT_SECRET || 'dev-secret',
      {
        expiresIn: '900s', // 15 Minuten
        issuer: 'weltenwind-api',
        audience: 'weltenwind-client'
      }
    );

    // Response-Headers setzen (konsistent mit authenticate-Middleware)
    res.setHeader('X-New-Token', newToken);
    res.setHeader('X-Token-Refreshed', 'true');

    return res.status(200).json({ 
      success: true, 
      message: 'Session verlängert',
      expiresIn: 15 * 60, // 15 Minuten in Sekunden
      token: newToken // Token auch im Body für direkten Zugriff
    });
  } catch (error) {
    return res.status(401).json({ error: 'Ungültiges Token oder Session-Refresh fehlgeschlagen' });
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
      email: true
    }
  });
  if (!user) {
    return res.status(404).json({ error: 'User not found' });
  }
  res.json(user);
});

export default router;
