import { Request, Response, NextFunction } from 'express';
import crypto from 'crypto';
import { AuthenticatedRequest } from './authenticate';
import { loggers } from '../config/logger.config';

interface CsrfRequest extends AuthenticatedRequest {
  csrfToken?: string;
}

// Helper function to extract IP
function extractClientIp(req: Request): string {
  return (req.headers['x-forwarded-for'] as string)?.split(',')[0]?.trim() || 
         req.socket.remoteAddress || 'unknown';
}

// In-Memory Token Storage (in Production sollte Redis verwendet werden)
const csrfTokens = new Map<string, { token: string; expires: Date }>();

// Token Cleanup alle 5 Minuten
setInterval(() => {
  const now = new Date();
  for (const [userId, data] of csrfTokens.entries()) {
    if (data.expires < now) {
      csrfTokens.delete(userId);
    }
  }
}, 5 * 60 * 1000);

/**
 * Generiert einen neuen CSRF-Token für den Benutzer
 */
export function generateCsrfToken(userId: string): string {
  const token = crypto.randomBytes(32).toString('hex');
  const expires = new Date(Date.now() + 60 * 60 * 1000); // 1 Stunde
  
  csrfTokens.set(userId, { token, expires });
  return token;
}

/**
 * Validiert den CSRF-Token
 */
export function validateCsrfToken(userId: string, token: string): boolean {
  const stored = csrfTokens.get(userId);
  if (!stored) return false;
  
  const now = new Date();
  if (stored.expires < now) {
    csrfTokens.delete(userId);
    return false;
  }
  
  return crypto.timingSafeEqual(
    Buffer.from(stored.token),
    Buffer.from(token)
  );
}

/**
 * CSRF-Protection Middleware für state-changing operations
 */
export function csrfProtection(req: CsrfRequest, res: Response, next: NextFunction) {
  // Skip für sichere Methoden
  if (['GET', 'HEAD', 'OPTIONS'].includes(req.method)) {
    return next();
  }
  
  // Skip wenn kein User authentifiziert ist (wird von authenticate middleware gehandelt)
  if (!req.user) {
    return next();
  }
  
  const ip = extractClientIp(req);
  
  // CSRF-Token aus Header oder Body lesen
  const token = req.headers['x-csrf-token'] as string || req.body?._csrf;
  
  if (!token) {
    loggers.security.csrfTokenInvalid(
      req.user.username || 'unknown',
      ip,
      req.originalUrl,
      {
        reason: 'token_missing',
        method: req.method,
        userAgent: req.headers['user-agent'],
        userId: req.user.id
      }
    );
    
    return res.status(403).json({
      error: 'CSRF-Token fehlt',
      message: 'Diese Aktion erfordert einen gültigen CSRF-Token'
    });
  }
  
  if (!validateCsrfToken(req.user.id.toString(), token)) {
    loggers.security.csrfTokenInvalid(
      req.user.username || 'unknown',
      ip,
      req.originalUrl,
      {
        reason: 'token_invalid_or_expired',
        method: req.method,
        userAgent: req.headers['user-agent'],
        userId: req.user.id,
        tokenPresent: true
      }
    );
    
    return res.status(403).json({
      error: 'Ungültiger CSRF-Token',
      message: 'Der CSRF-Token ist ungültig oder abgelaufen'
    });
  }
  
  // Bei erfolgreicher Validierung neuen Token generieren (Token Rotation)
  const newToken = generateCsrfToken(req.user.id.toString());
  res.setHeader('X-CSRF-Token', newToken);
  
  // Erfolgreiche CSRF-Validierung loggen (nur bei wichtigen Endpoints)
  if (req.originalUrl.includes('/change-password') || req.originalUrl.includes('/logout')) {
    loggers.security.csrfTokenInvalid(
      req.user.username || 'unknown',
      ip,
      req.originalUrl,
      {
        reason: 'token_valid',
        method: req.method,
        userAgent: req.headers['user-agent'],
        userId: req.user.id,
        tokenRotated: true
      }
    );
  }
  
  next();
}

/**
 * Endpoint zum Abrufen eines neuen CSRF-Tokens
 */
export function getCsrfToken(req: AuthenticatedRequest, res: Response) {
  if (!req.user) {
    return res.status(401).json({ error: 'Nicht authentifiziert' });
  }
  
  const token = generateCsrfToken(req.user.id.toString());
  return res.json({ 
    csrfToken: token,
    expiresIn: 3600 // 1 Stunde in Sekunden
  });
}