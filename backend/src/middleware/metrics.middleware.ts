import { Request, Response, NextFunction } from 'express';
import { recordAPIRequest, recordPerformance, recordError } from '../services/metrics.service';
import { AuthenticatedRequest } from './authenticate';

// 📊 Request-Metriken automatisch sammeln
export function metricsMiddleware(req: Request, res: Response, next: NextFunction) {
  const startTime = Date.now();
  const originalSend = res.send;
  const originalJson = res.json;
  
  // IP-Adresse extrahieren
  const ip = (req.headers['x-forwarded-for'] as string)?.split(',')[0]?.trim() || 
             req.socket.remoteAddress || 'unknown';
  
  // User-ID extrahieren (falls authentifiziert)
  const userId = (req as AuthenticatedRequest).user?.id;
  
  // Response abfangen um Metriken zu sammeln
  const captureResponse = function(this: Response, body: any) {
    const responseTime = Date.now() - startTime;
    const endpoint = req.route?.path || req.path || 'unknown';
    
    // API-Request-Metriken sammeln
    recordAPIRequest(
      req.method,
      endpoint,
      this.statusCode,
      responseTime,
      ip,
      userId
    );
    
    // Performance-Metriken sammeln (für langsame Requests)
    if (responseTime > 100) { // Nur Requests > 100ms tracken
      recordPerformance(`api_${req.method.toLowerCase()}_${endpoint}`, responseTime, {
        statusCode: this.statusCode,
        userId,
        userAgent: req.headers['user-agent']
      });
    }
    
    // Fehler-Metriken sammeln (für 4xx und 5xx Responses)
    if (this.statusCode >= 400) {
      const errorType = this.statusCode >= 500 ? 'server_error' : 'client_error';
      recordError(
        errorType,
        `HTTP ${this.statusCode} on ${endpoint}`,
        undefined,
        endpoint,
        userId
      );
    }
    
    return originalSend.call(this, body);
  };
  
  // res.send und res.json überschreiben
  res.send = captureResponse;
  res.json = function(this: Response, obj: any) {
    const responseTime = Date.now() - startTime;
    const endpoint = req.route?.path || req.path || 'unknown';
    
    // API-Request-Metriken sammeln
    recordAPIRequest(
      req.method,
      endpoint,
      this.statusCode,
      responseTime,
      ip,
      userId
    );
    
    // Performance-Metriken sammeln
    if (responseTime > 100) {
      recordPerformance(`api_${req.method.toLowerCase()}_${endpoint}`, responseTime, {
        statusCode: this.statusCode,
        userId,
        userAgent: req.headers['user-agent']
      });
    }
    
    // Fehler-Metriken sammeln
    if (this.statusCode >= 400) {
      const errorType = this.statusCode >= 500 ? 'server_error' : 'client_error';
      recordError(
        errorType,
        `HTTP ${this.statusCode} on ${endpoint}`,
        undefined,
        endpoint,
        userId
      );
    }
    
    return originalJson.call(this, obj);
  };
  
  next();
}

// 🎯 Spezifische Performance-Metriken für Database-Operations
export function trackDatabaseOperation<T>(
  operation: string,
  fn: () => Promise<T>
): Promise<T> {
  const startTime = Date.now();
  
  return fn()
    .then(result => {
      const duration = Date.now() - startTime;
      recordPerformance(`db_${operation}`, duration);
      return result;
    })
    .catch(error => {
      const duration = Date.now() - startTime;
      recordPerformance(`db_${operation}_failed`, duration);
      recordError('database_error', error.message, error.stack, `db_${operation}`);
      throw error;
    });
}

// 🔧 Business-Logic-Metriken für spezifische Aktionen
export function trackBusinessAction(action: string, userId?: number, metadata?: any) {
  recordPerformance(`business_${action}`, 0, { // Duration 0 da es ein Event ist
    userId,
    timestamp: new Date(),
    ...metadata
  });
}

// 📈 Middleware für Error-Tracking
export function errorTrackingMiddleware(
  error: Error,
  req: Request,
  res: Response,
  next: NextFunction
) {
  const userId = (req as AuthenticatedRequest).user?.id;
  const endpoint = req.route?.path || req.path || 'unknown';
  
  // Unbehandelte Fehler tracken
  recordError(
    'unhandled_error',
    error.message,
    error.stack,
    endpoint,
    userId
  );
  
  // Weiterleiten an den nächsten Error-Handler
  next(error);
}

// 🚀 Memory-Performance-Tracker
export function trackMemoryUsage() {
  const usage = process.memoryUsage();
  
  recordPerformance('system_memory_heap_used', usage.heapUsed / 1024 / 1024); // MB
  recordPerformance('system_memory_heap_total', usage.heapTotal / 1024 / 1024); // MB
  recordPerformance('system_memory_rss', usage.rss / 1024 / 1024); // MB
  recordPerformance('system_memory_external', usage.external / 1024 / 1024); // MB
}

// 🔄 Regelmäßige System-Metriken sammeln
export function startSystemMetricsCollection() {
  // Alle 30 Sekunden System-Metriken sammeln
  setInterval(() => {
    trackMemoryUsage();
    
    // CPU-Usage tracken
    const cpuUsage = process.cpuUsage();
    recordPerformance('system_cpu_user', cpuUsage.user / 1000); // Mikrosekunden zu Millisekunden
    recordPerformance('system_cpu_system', cpuUsage.system / 1000);
    
    // Event-Loop-Lag messen
    const start = process.hrtime.bigint();
    setImmediate(() => {
      const lag = Number(process.hrtime.bigint() - start) / 1000000; // Nanosekunden zu Millisekunden
      recordPerformance('system_event_loop_lag', lag);
    });
    
  }, 30000); // 30 Sekunden
}

// 📊 Metriken-Sammlung für spezifische Weltenwind-Events
export const WeltenwingMetrics = {
  userRegistered: (userId: number, method: 'email' | 'invite') => {
    trackBusinessAction('user_registered', userId, { method });
  },
  
  userLoggedIn: (userId: number, ip: string, device?: string) => {
    trackBusinessAction('user_logged_in', userId, { ip, device });
  },
  
  worldJoined: (userId: number, worldId: number) => {
    trackBusinessAction('world_joined', userId, { worldId });
  },
  
  worldLeft: (userId: number, worldId: number) => {
    trackBusinessAction('world_left', userId, { worldId });
  },
  
  inviteCreated: (userId: number, worldId: number, inviteCount: number) => {
    trackBusinessAction('invite_created', userId, { worldId, inviteCount });
  },
  
  inviteAccepted: (userId: number, worldId: number, inviteId: number) => {
    trackBusinessAction('invite_accepted', userId, { worldId, inviteId });
  },
  
  passwordChanged: (userId: number) => {
    trackBusinessAction('password_changed', userId);
  },
  
  themeChanged: (userId: number, themeName: string) => {
    trackBusinessAction('theme_changed', userId, { themeName });
  },
  
  arbFileUpdated: (userId: number, language: string, keysCount: number) => {
    trackBusinessAction('arb_updated', userId, { language, keysCount });
  }
};