import rateLimit from 'express-rate-limit';
import slowDown from 'express-slow-down';
import { Request, Response } from 'express';
import { loggers } from '../config/logger.config';

// Erweitere Request-Type für rate-limit
declare module 'express' {
  interface Request {
    rateLimit?: {
      limit: number;
      current: number;
      remaining: number;
      resetTime?: Date;
    };
  }
}

// Verwende den standardmäßigen keyGenerator (IPv6-kompatibel)
// Der kombiniert IP + User-Agent automatisch und ist sicher für IPv6

// Strenger Rate-Limiter für Auth-Endpoints (Login/Register)
export const authLimiter = rateLimit({
  windowMs: 5 * 60 * 1000, // 5 Minuten (reduziert für Development)
  max: 20, // Max 20 Requests pro Window (erhöht für Development)
  message: 'Zu viele Anfragen. Bitte versuche es in 5 Minuten erneut.',
  standardHeaders: true,
  legacyHeaders: false,
  // Kein custom keyGenerator - verwende den Standard (IP-basiert, IPv6-sicher)
  skipSuccessfulRequests: false, // Auch erfolgreiche Requests zählen
  handler: (req: Request, res: Response) => {
    const identifier = req.ip || 'unknown';
    
    // Strukturiertes Logging
    loggers.security.rateLimitHit(identifier, req.originalUrl, {
      limitType: 'auth',
      maxRequests: 20,
      windowMs: '5min',
      currentRequests: (req as any).rateLimit?.current,
      userAgent: req.headers['user-agent'],
      method: req.method
    });
    
    res.status(429).json({
      error: 'Zu viele Anfragen',
      message: 'Bitte versuche es in 5 Minuten erneut.',
      retryAfter: (req as any).rateLimit?.resetTime
    });
  }
});

// Progressiver Slow-Down für wiederholte Auth-Versuche
export const authSlowDown = slowDown({
  windowMs: 15 * 60 * 1000, // 15 Minuten
  delayAfter: 2, // Nach 2 Requests langsamer werden
  delayMs: (hits) => hits * 1000, // Jeder weitere Request +1 Sekunde Verzögerung
  maxDelayMs: 10000, // Max 10 Sekunden Verzögerung
  // Kein custom keyGenerator - verwende den Standard
});

// Moderater Limiter für API-Endpoints
export const apiLimiter = rateLimit({
  windowMs: 1 * 60 * 1000, // 1 Minute
  max: 100, // Max 100 Requests pro Minute
  message: 'Zu viele API-Anfragen. Bitte reduziere die Anfragerate.',
  standardHeaders: true,
  legacyHeaders: false,
  // Kein custom keyGenerator - verwende den Standard
});

// Sehr strenger Limiter für Password-Reset
export const passwordResetLimiter = rateLimit({
  windowMs: 60 * 60 * 1000, // 1 Stunde
  max: 3, // Max 3 Reset-Anfragen pro Stunde
  message: 'Zu viele Passwort-Reset-Anfragen. Bitte versuche es später erneut.',
  skipSuccessfulRequests: false,
  handler: (req: Request, res: Response) => {
    const identifier = req.ip || 'unknown';
    
    // Strukturiertes Logging
    loggers.security.rateLimitHit(identifier, req.originalUrl, {
      limitType: 'password_reset',
      maxRequests: 3,
      windowMs: '1hour',
      currentRequests: (req as any).rateLimit?.current,
      userAgent: req.headers['user-agent'],
      method: req.method,
      email: req.body?.email ? 'provided' : 'not_provided'
    });
    
    res.status(429).json({
      error: 'Zu viele Anfragen',
      message: 'Du kannst maximal 3 Passwort-Reset-Anfragen pro Stunde stellen.',
      retryAfter: (req as any).rateLimit?.resetTime
    });
  }
});

// IP-basierter Limiter für Registration (verhindert Spam-Accounts)
export const registrationLimiter = rateLimit({
  windowMs: 24 * 60 * 60 * 1000, // 24 Stunden
  max: 5, // Max 5 Registrierungen pro IP pro Tag
  message: 'Zu viele Registrierungen von dieser IP. Bitte versuche es morgen erneut.',
  skipSuccessfulRequests: false,
  // Kein custom keyGenerator - der Standard ist bereits IP-basiert
});

// Trust Proxy für korrekte IP-Erkennung hinter Reverse Proxy
export const configureTrustProxy = (app: any) => {
  app.set('trust proxy', true);
};