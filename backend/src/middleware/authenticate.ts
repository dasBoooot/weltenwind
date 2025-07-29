import { Request, Response, NextFunction } from 'express';
import jwt from 'jsonwebtoken';
import { jwtConfig } from '../config/jwt.config';

// Typisierung für JWT Payload
interface JwtPayloadExtended extends jwt.JwtPayload {
  userId: number;
  username: string;
  type: string;
  timezone?: string;
}

// Konfiguration für Token-Management
const ACCESS_TOKEN_LIFETIME_SECONDS = 15 * 60; // 15 Minuten
const REFRESH_THRESHOLD_SECONDS = 60; // 1 Minute vor Ablauf erneuern

export interface AuthenticatedRequest extends Request {
  user?: {
    id: number;
    username: string;
    timezone?: string;
  };
}

// Fingerprint aus Header extrahieren
function extractDeviceFingerprint(req: Request): string {
  return req.headers['x-device-fingerprint'] as string || req.headers['user-agent'] || 'unknown';
}

// Token verifizieren
export function verifyToken(token: string): JwtPayloadExtended | null {
  try {
    return jwt.verify(token, jwtConfig.getSecret()) as JwtPayloadExtended;
  } catch (error) {
    return null;
  }
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
    const decoded = verifyToken(token);

    if (!decoded) {
      return res.status(401).json({ error: 'Token ungültig oder Fehler bei der Verarbeitung' });
    }

    // Prüfen ob es ein Access-Token ist
    if (decoded.type !== 'access') {
      return res.status(401).json({ error: 'Ungültiger Token-Typ. Access-Token erforderlich.' });
    }

    const now = Math.floor(Date.now() / 1000);
    const exp = decoded.exp as number;
    const remaining = exp - now;

    // Token ist abgelaufen
    if (remaining <= 0) {
      return res.status(401).json({ error: 'Access-Token abgelaufen. Bitte mit Refresh-Token erneuern.' });
    }

    // Token erneuern, wenn <60s rest
    if (remaining < REFRESH_THRESHOLD_SECONDS) {
      // Header setzen, damit Client weiß, dass Token erneuert werden muss
      res.setHeader('X-Token-Expires-Soon', 'true');
      res.setHeader('X-Token-Expires-In', remaining.toString());
    }

    req.user = {
      id: decoded.userId,
      username: decoded.username,
      timezone: decoded.timezone
    };

    next();
  } catch (error) {
    return res.status(401).json({ error: 'Token ungültig oder Fehler bei der Verarbeitung' });
  }
}
