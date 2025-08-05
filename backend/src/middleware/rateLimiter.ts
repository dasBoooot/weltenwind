import rateLimit from 'express-rate-limit';
import slowDown from 'express-slow-down';
import { Request, Response } from 'express';
import { loggers } from '../config/logger.config';

// ✅ Rate Limiting Konfiguration aus .env
const AUTH_RATE_LIMIT_WINDOW_MINUTES = parseInt(process.env.AUTH_RATE_LIMIT_WINDOW_MINUTES || '5', 10);
const AUTH_RATE_LIMIT_MAX_REQUESTS = parseInt(process.env.AUTH_RATE_LIMIT_MAX_REQUESTS || '20', 10);
const AUTH_SLOWDOWN_WINDOW_MINUTES = parseInt(process.env.AUTH_SLOWDOWN_WINDOW_MINUTES || '15', 10);
const API_RATE_LIMIT_WINDOW_MINUTES = parseInt(process.env.API_RATE_LIMIT_WINDOW_MINUTES || '1', 10);
const API_RATE_LIMIT_MAX_REQUESTS = parseInt(process.env.API_RATE_LIMIT_MAX_REQUESTS || '100', 10);
const PASSWORD_RESET_WINDOW_HOURS = parseInt(process.env.PASSWORD_RESET_WINDOW_HOURS || '1', 10);
const PASSWORD_RESET_MAX_REQUESTS = parseInt(process.env.PASSWORD_RESET_MAX_REQUESTS || '3', 10);
const REGISTRATION_LIMIT_WINDOW_HOURS = parseInt(process.env.REGISTRATION_LIMIT_WINDOW_HOURS || '24', 10);
const REGISTRATION_LIMIT_MAX_REQUESTS = parseInt(process.env.REGISTRATION_LIMIT_MAX_REQUESTS || '5', 10);

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
  windowMs: AUTH_RATE_LIMIT_WINDOW_MINUTES * 60 * 1000, // Aus .env
  max: AUTH_RATE_LIMIT_MAX_REQUESTS, // Aus .env
  message: `Zu viele Anfragen. Bitte versuche es in ${AUTH_RATE_LIMIT_WINDOW_MINUTES} Minuten erneut.`,
  standardHeaders: true,
  legacyHeaders: false,
  skipSuccessfulRequests: false, // Auch erfolgreiche Requests zählen
  handler: (req: Request, res: Response) => {
    const identifier = req.ip || 'unknown';
    
    // Strukturiertes Logging
    loggers.security.rateLimitHit(identifier, req.originalUrl, {
      limitType: 'auth',
      maxRequests: AUTH_RATE_LIMIT_MAX_REQUESTS,
      windowMs: `${AUTH_RATE_LIMIT_WINDOW_MINUTES}min`,
      currentRequests: (req as any).rateLimit?.current,
      userAgent: req.headers['user-agent'],
      method: req.method
    });
    
    res.status(429).json({
      error: 'Zu viele Anfragen',
      message: `Bitte versuche es in ${AUTH_RATE_LIMIT_WINDOW_MINUTES} Minuten erneut.`,
      retryAfter: (req as any).rateLimit?.resetTime
    });
  }
});

// Progressiver Slow-Down für wiederholte Auth-Versuche
export const authSlowDown = slowDown({
  windowMs: AUTH_SLOWDOWN_WINDOW_MINUTES * 60 * 1000, // Aus .env
  delayAfter: 2, // Nach 2 Requests langsamer werden
  delayMs: (hits) => hits * 1000, // Jeder weitere Request +1 Sekunde Verzögerung
  maxDelayMs: 10000, // Max 10 Sekunden Verzögerung
});

// Moderater Limiter für API-Endpoints
export const apiLimiter = rateLimit({
  windowMs: API_RATE_LIMIT_WINDOW_MINUTES * 60 * 1000, // Aus .env
  max: API_RATE_LIMIT_MAX_REQUESTS, // Aus .env
  message: 'Zu viele API-Anfragen. Bitte reduziere die Anfragerate.',
  standardHeaders: true,
  legacyHeaders: false
});

// Sehr strenger Limiter für Password-Reset
export const passwordResetLimiter = rateLimit({
  windowMs: PASSWORD_RESET_WINDOW_HOURS * 60 * 60 * 1000, // Aus .env
  max: PASSWORD_RESET_MAX_REQUESTS, // Aus .env
  message: 'Zu viele Passwort-Reset-Anfragen. Bitte versuche es später erneut.',
  skipSuccessfulRequests: false,
  handler: (req: Request, res: Response) => {
    const identifier = req.ip || 'unknown';
    
    // Strukturiertes Logging
    loggers.security.rateLimitHit(identifier, req.originalUrl, {
      limitType: 'password_reset',
      maxRequests: PASSWORD_RESET_MAX_REQUESTS,
      windowMs: `${PASSWORD_RESET_WINDOW_HOURS}hour`,
      currentRequests: (req as any).rateLimit?.current,
      userAgent: req.headers['user-agent'],
      method: req.method,
      email: req.body?.email ? 'provided' : 'not_provided'
    });
    
    res.status(429).json({
      error: 'Zu viele Anfragen',
      message: `Du kannst maximal ${PASSWORD_RESET_MAX_REQUESTS} Passwort-Reset-Anfragen pro ${PASSWORD_RESET_WINDOW_HOURS} Stunde(n) stellen.`,
      retryAfter: (req as any).rateLimit?.resetTime
    });
  }
});

// IP-basierter Limiter für Registration (verhindert Spam-Accounts)
export const registrationLimiter = rateLimit({
  windowMs: REGISTRATION_LIMIT_WINDOW_HOURS * 60 * 60 * 1000, // Aus .env
  max: REGISTRATION_LIMIT_MAX_REQUESTS, // Aus .env
  message: `Zu viele Registrierungen von dieser IP. Bitte versuche es in ${REGISTRATION_LIMIT_WINDOW_HOURS} Stunden erneut.`,
  skipSuccessfulRequests: false
});

// Trust Proxy für korrekte IP-Erkennung hinter Reverse Proxy
export const configureTrustProxy = (app: any) => {
  // ✅ SICHER: Nur ersten Proxy vertrauen (nginx), nicht allen
  app.set('trust proxy', process.env.TRUST_PROXY === 'true' ? 1 : false);
};