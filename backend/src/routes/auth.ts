import express from 'express';
import { PrismaClient } from '@prisma/client';
import bcrypt from 'bcrypt';
import jwt from 'jsonwebtoken';
import { createSession, invalidateSession } from '../services/session.service';

const router = express.Router();
const prisma = new PrismaClient();

// Hilfsfunktion: IP & Fingerprint extrahieren
function extractClientInfo(req: express.Request) {
  const ip = req.ip || req.headers['x-forwarded-for'] || req.socket.remoteAddress || '';
  const fingerprint = req.headers['user-agent'] || 'unknown';
  return { ip: ip.toString(), fingerprint };
}

// POST /api/auth/login
router.post('/login', async (req, res) => {
  const { username, password } = req.body;

  if (!username || !password) {
    return res.status(400).json({ error: 'Benutzername und Passwort erforderlich' });
  }

  const user = await prisma.user.findUnique({
    where: { username },
    include: { roles: true }
  });

  if (!user || user.isLocked) {
    return res.status(401).json({ error: 'Zugriff verweigert' });
  }

  const pwValid = await bcrypt.compare(password, user.passwordHash);
  if (!pwValid) {
    return res.status(401).json({ error: 'Ungültige Zugangsdaten' });
  }

  // JWT erzeugen
  const token = jwt.sign(
    {
      userId: user.id,
      username: user.username
    },
    process.env.JWT_SECRET || 'dev-secret',
    { expiresIn: '2h' }
  );

  const { ip, fingerprint } = extractClientInfo(req);

  // Session erzeugen
  await createSession(user.id, token, ip, fingerprint);

  return res.status(200).json({
    token,
    user: {
      id: user.id,
      username: user.username
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

export default router;
