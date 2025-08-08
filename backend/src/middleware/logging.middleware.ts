import { Request, Response, NextFunction } from 'express';
import { loggers } from '../config/logger.config';
import { AuthenticatedRequest } from './authenticate';

interface RequestWithStartTime extends Request {
  startTime?: number;
}

/**
 * Middleware für automatisches Request-Logging
 */
export function requestLoggingMiddleware(req: RequestWithStartTime, res: Response, next: NextFunction) {
  // Start-Zeit für Performance-Messung
  req.startTime = Date.now();
  
  // IP-Adresse ermitteln
  const ip = (req.headers['x-forwarded-for'] as string)?.split(',')[0]?.trim() || 
             req.socket.remoteAddress || 'unknown';
  
  // Username falls authentifiziert
  const username = (req as AuthenticatedRequest).user?.username;
  const traceEnabled = process.env.LOG_TRACE_REQUESTS === 'true';
  if (traceEnabled) {
    try {
      loggers.system.info('TRACE request start', {
        method: req.method,
        url: req.originalUrl,
        ip,
        userAgent: req.headers['user-agent']
      });
    } catch {}
  }
  
  
  // Logging am Ende der Response (robust für alle Antworttypen)
  res.on('finish', () => {
    const duration = req.startTime ? Date.now() - req.startTime : 0;
    try {
      loggers.api.request(
        req.method,
        req.originalUrl,
        res.statusCode,
        ip,
        req.headers['user-agent'],
        duration,
        {
          username,
          statusCode: res.statusCode,
          contentLength: res.get('content-length'),
          ...(req.body && Object.keys(req.body).length > 0 && {
            bodyKeys: Object.keys(req.body)
          })
        }
      );
    } catch (e) {
      try {
        loggers.system.error('API logging failed', e as any, {
          method: req.method,
          url: req.originalUrl,
          statusCode: res.statusCode
        });
      } catch {}
    }
    if (traceEnabled) {
      try {
        loggers.system.info('TRACE request finish', {
          method: req.method,
          url: req.originalUrl,
          statusCode: res.statusCode,
          duration
        });
      } catch {}
    }
  });
  
  next();
}

/**
 * Error-Logging Middleware (sollte als letztes verwendet werden)
 */
export function errorLoggingMiddleware(error: any, req: Request, res: Response, next: NextFunction) {
  const ip = (req.headers['x-forwarded-for'] as string)?.split(',')[0]?.trim() || 
             req.socket.remoteAddress || 'unknown';
  const username = (req as AuthenticatedRequest).user?.username;
  
  // Fehler loggen
  loggers.api.error(`API Error: ${req.method} ${req.originalUrl}`, {
    method: req.method,
    url: req.originalUrl,
    ip,
    username,
    error: error.message,
    stack: error.stack,
    userAgent: req.headers['user-agent'],
    body: req.body
  });
  
  next(error);
}