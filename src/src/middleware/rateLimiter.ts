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

// 🔐 Erweiterte Rate Limiting Konfiguration
const PUBLIC_ENDPOINT_WINDOW_MINUTES = parseInt(process.env.PUBLIC_ENDPOINT_WINDOW_MINUTES || '60', 10);
const PUBLIC_ENDPOINT_MAX_REQUESTS = parseInt(process.env.PUBLIC_ENDPOINT_MAX_REQUESTS || '10', 10);
const INVITE_CREATION_WINDOW_MINUTES = parseInt(process.env.INVITE_CREATION_WINDOW_MINUTES || '10', 10);
const INVITE_CREATION_MAX_REQUESTS = parseInt(process.env.INVITE_CREATION_MAX_REQUESTS || '20', 10);
const ADMIN_ENDPOINT_WINDOW_MINUTES = parseInt(process.env.ADMIN_ENDPOINT_WINDOW_MINUTES || '5', 10);
const ADMIN_ENDPOINT_MAX_REQUESTS = parseInt(process.env.ADMIN_ENDPOINT_MAX_REQUESTS || '200', 10);
const WORLD_OPERATIONS_WINDOW_MINUTES = parseInt(process.env.WORLD_OPERATIONS_WINDOW_MINUTES || '15', 10);
const WORLD_OPERATIONS_MAX_REQUESTS = parseInt(process.env.WORLD_OPERATIONS_MAX_REQUESTS || '30', 10);

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

// 🔐 Sehr strenger Limiter für öffentliche Endpoints (Spam-Schutz)
export const publicEndpointLimiter = rateLimit({
  windowMs: PUBLIC_ENDPOINT_WINDOW_MINUTES * 60 * 1000,
  max: PUBLIC_ENDPOINT_MAX_REQUESTS,
  message: 'Zu viele Anfragen von dieser IP. Bitte versuche es später erneut.',
  standardHeaders: true,
  legacyHeaders: false,
  skipSuccessfulRequests: false,
  handler: (req: Request, res: Response) => {
    const identifier = req.ip || 'unknown';
    
    loggers.security.rateLimitHit(identifier, req.originalUrl, {
      limitType: 'public_endpoint',
      maxRequests: PUBLIC_ENDPOINT_MAX_REQUESTS,
      windowMs: `${PUBLIC_ENDPOINT_WINDOW_MINUTES}min`,
      currentRequests: (req as any).rateLimit?.current,
      userAgent: req.headers['user-agent'],
      method: req.method,
      severity: 'HIGH' // Öffentliche Endpoints sind kritisch
    });
    
    res.status(429).json({
      error: 'Rate limit exceeded',
      message: `Du kannst maximal ${PUBLIC_ENDPOINT_MAX_REQUESTS} Anfragen pro ${PUBLIC_ENDPOINT_WINDOW_MINUTES} Minuten von dieser IP stellen.`,
      retryAfter: (req as any).rateLimit?.resetTime,
      type: 'public_endpoint_limit'
    });
  }
});

// 🎯 Spezieller Limiter für Invite-Operationen
export const inviteOperationsLimiter = rateLimit({
  windowMs: INVITE_CREATION_WINDOW_MINUTES * 60 * 1000,
  max: INVITE_CREATION_MAX_REQUESTS,
  message: 'Zu viele Invite-Operationen. Bitte reduziere die Anfragerate.',
  standardHeaders: true,
  legacyHeaders: false,
  skipSuccessfulRequests: false,
  handler: (req: Request, res: Response) => {
    const identifier = req.ip || 'unknown';
    
    loggers.security.rateLimitHit(identifier, req.originalUrl, {
      limitType: 'invite_operations',
      maxRequests: INVITE_CREATION_MAX_REQUESTS,
      windowMs: `${INVITE_CREATION_WINDOW_MINUTES}min`,
      currentRequests: (req as any).rateLimit?.current,
      userAgent: req.headers['user-agent'],
      method: req.method
    });
    
    res.status(429).json({
      error: 'Invite rate limit exceeded',
      message: `Du kannst maximal ${INVITE_CREATION_MAX_REQUESTS} Invite-Operationen pro ${INVITE_CREATION_WINDOW_MINUTES} Minuten durchführen.`,
      retryAfter: (req as any).rateLimit?.resetTime,
      type: 'invite_limit'
    });
  }
});

// 👑 Moderater Limiter für Admin-Endpoints
export const adminEndpointLimiter = rateLimit({
  windowMs: ADMIN_ENDPOINT_WINDOW_MINUTES * 60 * 1000,
  max: ADMIN_ENDPOINT_MAX_REQUESTS,
  message: 'Admin-Rate-Limit erreicht. Bitte reduziere die Anfragerate.',
  standardHeaders: true,
  legacyHeaders: false,
  skipSuccessfulRequests: true, // Erfolgreiche Admin-Requests nicht zählen
  handler: (req: Request, res: Response) => {
    const identifier = req.ip || 'unknown';
    
    loggers.security.rateLimitHit(identifier, req.originalUrl, {
      limitType: 'admin_endpoint',
      maxRequests: ADMIN_ENDPOINT_MAX_REQUESTS,
      windowMs: `${ADMIN_ENDPOINT_WINDOW_MINUTES}min`,
      currentRequests: (req as any).rateLimit?.current,
      userAgent: req.headers['user-agent'],
      method: req.method,
      note: 'Admin user hitting rate limits'
    });
    
    res.status(429).json({
      error: 'Admin rate limit exceeded',
      message: `Admin-Rate-Limit erreicht: ${ADMIN_ENDPOINT_MAX_REQUESTS} requests/${ADMIN_ENDPOINT_WINDOW_MINUTES}min.`,
      retryAfter: (req as any).rateLimit?.resetTime,
      type: 'admin_limit'
    });
  }
});

// 🌍 Spezifischer Limiter für World-Operationen
export const worldOperationsLimiter = rateLimit({
  windowMs: WORLD_OPERATIONS_WINDOW_MINUTES * 60 * 1000,
  max: WORLD_OPERATIONS_MAX_REQUESTS,
  message: 'Zu viele World-Operationen. Bitte reduziere die Anfragerate.',
  standardHeaders: true,
  legacyHeaders: false,
  handler: (req: Request, res: Response) => {
    const identifier = req.ip || 'unknown';
    
    loggers.security.rateLimitHit(identifier, req.originalUrl, {
      limitType: 'world_operations',
      maxRequests: WORLD_OPERATIONS_MAX_REQUESTS,
      windowMs: `${WORLD_OPERATIONS_WINDOW_MINUTES}min`,
      currentRequests: (req as any).rateLimit?.current,
      userAgent: req.headers['user-agent'],
      method: req.method
    });
    
    res.status(429).json({
      error: 'World operations rate limit exceeded',
      message: `Du kannst maximal ${WORLD_OPERATIONS_MAX_REQUESTS} World-Operationen pro ${WORLD_OPERATIONS_WINDOW_MINUTES} Minuten durchführen.`,
      retryAfter: (req as any).rateLimit?.resetTime,
      type: 'world_limit'
    });
  }
});

// 🔑 User-spezifischer Rate Limiter (kombiniert IP + User ID)
export const createUserSpecificLimiter = (windowMs: number, max: number, limitType: string) => {
  return rateLimit({
    windowMs,
    max,
    // Kombiniere IP + User ID für genauere Limits
    keyGenerator: (req: Request) => {
      const ip = req.ip || 'unknown';
      const userId = (req as any).user?.id || 'anonymous';
      return `${ip}:${userId}`;
    },
    handler: (req: Request, res: Response) => {
      const ip = req.ip || 'unknown';
      const userId = (req as any).user?.id || 'anonymous';
      const username = (req as any).user?.username || 'anonymous';
      
      loggers.security.rateLimitHit(ip, req.originalUrl, {
        limitType: `user_specific_${limitType}`,
        maxRequests: max,
        windowMs: `${windowMs/1000/60}min`,
        currentRequests: (req as any).rateLimit?.current,
        userId,
        username,
        userAgent: req.headers['user-agent'],
        method: req.method
      });
      
      res.status(429).json({
        error: 'User-specific rate limit exceeded',
        message: `Du hast dein persönliches Rate-Limit für diese Operation erreicht.`,
        retryAfter: (req as any).rateLimit?.resetTime,
        type: `user_${limitType}_limit`
      });
    }
  });
};

// Trust Proxy für korrekte IP-Erkennung hinter Reverse Proxy
export const configureTrustProxy = (app: any) => {
  // ✅ SICHER: Nur ersten Proxy vertrauen (nginx), nicht allen
  app.set('trust proxy', process.env.TRUST_PROXY === 'true' ? 1 : false);
};