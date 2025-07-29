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
  
  // Response Ende abfangen für Logging
  const originalSend = res.send;
  res.send = function(body) {
    const duration = req.startTime ? Date.now() - req.startTime : 0;
    
    // Log des API-Requests
    loggers.api.request(
      req.method,
      req.originalUrl,
      ip,
      username,
      res.statusCode,
      duration,
      {
        userAgent: req.headers['user-agent'],
        contentLength: res.get('content-length'),
        ...(req.body && Object.keys(req.body).length > 0 && {
          bodyKeys: Object.keys(req.body)
        })
      }
    );
    
    // Original send aufrufen
    return originalSend.call(this, body);
  };
  
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
  loggers.api.error(
    req.method,
    req.originalUrl,
    ip,
    error,
    username,
    {
      userAgent: req.headers['user-agent'],
      body: req.body
    }
  );
  
  next(error);
}