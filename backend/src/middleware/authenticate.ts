import { Request, Response, NextFunction } from 'express';
import jwt from 'jsonwebtoken';
import prisma from '../libs/prisma';
import { getValidSession, refreshSession } from '../services/session.service';

// Typisierung für JWT Payload
interface JwtPayloadExtended extends jwt.JwtPayload {
  userId: number;
  username: string;
}



// Konfiguration für Token-Management
const TOKEN_LIFETIME_SECONDS = parseInt(process.env.JWT_EXPIRES_IN_SECONDS || '900'); // 15 Minuten
const REFRESH_THRESHOLD_SECONDS = 60; // 1 Minute vor Ablauf erneuern
const INACTIVITY_LIMIT_SECONDS = 60 * 60; // 1 Stunde max Inaktivität

export interface AuthenticatedRequest extends Request {
  user?: {
    id: number;
    username: string;
  };
}

// Fingerprint aus Header extrahieren
function extractDeviceFingerprint(req: Request): string {
  return req.headers['x-device-fingerprint'] as string || req.headers['user-agent'] || 'unknown';
}

function verifyJWT(token: string): JwtPayloadExtended {
  return jwt.verify(token, process.env.JWT_SECRET || 'dev-secret') as JwtPayloadExtended;
}

export async function authenticate(req: AuthenticatedRequest, res: Response, next: NextFunction) {
  // Robuste Token-Extraktion für verschiedene Clients
  let token = null;
  
  // Standard Authorization Header
  const authHeader = req.headers.authorization;
  if (authHeader?.startsWith('Bearer ')) {
    token = authHeader.split(' ')[1];
  }
  
  // Fallback: Token aus Query-Parameter (für Swagger UI)
  if (!token && req.query.token) {
    token = req.query.token as string;
  }
  
  // Fallback: Token aus Body (für POST requests)
  if (!token && req.body?.token) {
    token = req.body.token;
  }

  if (!token) {
    return res.status(401).json({ error: 'Token fehlt oder ungültig' });
  }

  try {
    const decoded = verifyJWT(token);

    const fingerprint = extractDeviceFingerprint(req);
    const session = await getValidSession(decoded.userId, token, fingerprint);

    if (!session) {
      return res.status(440).json({ error: 'Session abgelaufen oder ungültig' });
    }

    const now = Math.floor(Date.now() / 1000);
    const exp = decoded.exp as number;
    const remaining = exp - now;

    // Session-Inaktivitäts-Check
    const lastAccess = new Date(session.lastAccessedAt).getTime();
    if (Date.now() - lastAccess > INACTIVITY_LIMIT_SECONDS * 1000) {
      return res.status(440).json({ error: 'Session Timeout (>1h)' });
    }

    // Token erneuern, wenn <60s rest
    if (remaining < REFRESH_THRESHOLD_SECONDS) {
      await refreshSession(decoded.userId, token); // verlängert DB-Session & lastAccess

      const newToken = jwt.sign(
        {
          userId: decoded.userId,
          username: decoded.username,
          iat: now
        },
        process.env.JWT_SECRET || 'dev-secret',
        {
          expiresIn: `${TOKEN_LIFETIME_SECONDS}s`,
          issuer: 'weltenwind-api',
          audience: 'weltenwind-client'
        }
      );

      res.setHeader('X-New-Token', newToken);
      res.setHeader('X-Token-Refreshed', 'true');
    } else {
      // Nur lastAccessedAt aktualisieren
      await prisma.session.updateMany({
        where: { userId: decoded.userId, token },
        data: { lastAccessedAt: new Date() }
      });
    }

    req.user = {
      id: decoded.userId,
      username: decoded.username
    };

    next();
  } catch (error) {
    return res.status(401).json({ error: 'Token ungültig oder Fehler bei der Verarbeitung' });
  }
}
