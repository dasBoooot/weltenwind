import winston from 'winston';
import path from 'path';
import fs from 'fs';

// Logs-Verzeichnis je nach Environment
const isDevelopment = process.env.NODE_ENV !== 'production';
const logsDir = isDevelopment 
  ? path.resolve(__dirname, '../../../logs')           // Development: ./logs/
  : '/var/log/weltenwind';                             // Production: systemd-Standard

// Logs-Verzeichnis erstellen falls nicht vorhanden (nur in Development)
if (isDevelopment && !fs.existsSync(logsDir)) {
  fs.mkdirSync(logsDir, { recursive: true });
}

// Custom Format für strukturierte Logs
const logFormat = winston.format.combine(
  winston.format.timestamp({
    format: 'YYYY-MM-DD HH:mm:ss.SSS'
  }),
  winston.format.errors({ stack: true }),
  winston.format.json(),
  winston.format.printf((info) => {
    const logEntry: any = {
      timestamp: info.timestamp,
      level: info.level.toUpperCase(),
      module: info.module || 'SYSTEM',
      message: info.message
    };

    // Conditionally add optional fields
    if (info.userId) logEntry.userId = info.userId;
    if (info.username) logEntry.username = info.username;
    if (info.ip) logEntry.ip = info.ip;
    if (info.endpoint) logEntry.endpoint = info.endpoint;
    if (info.action) logEntry.action = info.action;
    if (info.error) logEntry.error = info.error;
    if (info.stack) logEntry.stack = info.stack;
    if (info.metadata) logEntry.metadata = info.metadata;

    return JSON.stringify(logEntry);
  })
);

// File-Transport Konfiguration
const createFileTransport = (filename: string, options: any = {}) => {
  return new winston.transports.File({
    filename: path.join(logsDir, filename),
    maxsize: isDevelopment ? 50 * 1024 * 1024 : 100 * 1024 * 1024, // Dev: 50MB, Prod: 100MB
    maxFiles: isDevelopment ? 10 : 20,                               // Dev: 10, Prod: 20
    tailable: true,
    ...options
  });
};

// Logger-Konfiguration
export const logger = winston.createLogger({
  level: process.env.LOG_LEVEL || (isDevelopment ? 'debug' : 'info'),
  format: logFormat,
  transports: [
    // Haupt-Log (alle Nachrichten)
    createFileTransport('app.log'),
    
    // Error-Log (nur Fehler)
    createFileTransport('error.log', { 
      level: 'error',
      maxFiles: isDevelopment ? 5 : 10
    }),
    
    // Auth-spezifische Logs
    createFileTransport('auth.log', {
      format: winston.format.combine(
        logFormat,
        winston.format((info) => {
          return info.module === 'AUTH' ? info : false;
        })()
      )
    }),
    
    // Security-Events
    createFileTransport('security.log', {
      format: winston.format.combine(
        logFormat,
        winston.format((info) => {
          return info.module === 'SECURITY' ? info : false;
        })()
      )
    }),
    
    // API-Requests
    createFileTransport('api.log', {
      format: winston.format.combine(
        logFormat,
        winston.format((info) => {
          return info.module === 'API' ? info : false;
        })()
      )
    })
  ]
});

// Console-Ausgabe in Development
if (isDevelopment) {
  logger.add(new winston.transports.Console({
    format: winston.format.combine(
      winston.format.colorize(),
      winston.format.timestamp({ format: 'HH:mm:ss' }),
      winston.format.printf((info) => {
        const module = info.module ? `[${info.module}]` : '';
        const user = info.username ? `{${info.username}}` : '';
        return `${info.timestamp} ${info.level} ${module}${user}: ${info.message}`;
      })
    )
  }));
}

// Startup-Log mit Environment-Info
logger.info('Winston Logger initialized', {
  module: 'SYSTEM',
  metadata: {
    environment: process.env.NODE_ENV,
    logDirectory: logsDir,
    logLevel: process.env.LOG_LEVEL || (isDevelopment ? 'debug' : 'info'),
    isDevelopment,
    winston_version: require('winston/package.json').version
  }
});

// Helper-Funktionen für strukturiertes Logging
export const loggers = {
  // System-Logs
  system: {
    info: (message: string, metadata?: any) => 
      logger.info(message, { module: 'SYSTEM', metadata }),
    warn: (message: string, metadata?: any) => 
      logger.warn(message, { module: 'SYSTEM', metadata }),
    error: (message: string, error?: any, metadata?: any) => 
      logger.error(message, { module: 'SYSTEM', error: error?.message, stack: error?.stack, metadata })
  },

  // Auth-Logs
  auth: {
    login: (username: string, ip: string, success: boolean, metadata?: any) =>
      logger.info(`Login ${success ? 'successful' : 'failed'}`, {
        module: 'AUTH',
        action: 'LOGIN',
        username,
        ip,
        success,
        metadata
      }),
    
    register: (username: string, email: string, ip: string, metadata?: any) =>
      logger.info('User registered', {
        module: 'AUTH',
        action: 'REGISTER',
        username,
        email,
        ip,
        metadata
      }),
    
    logout: (username: string, ip: string, metadata?: any) =>
      logger.info('User logged out', {
        module: 'AUTH',
        action: 'LOGOUT',
        username,
        ip,
        metadata
      }),
    
    passwordChange: (username: string, ip: string, metadata?: any) =>
      logger.info('Password changed', {
        module: 'AUTH',
        action: 'PASSWORD_CHANGE',
        username,
        ip,
        metadata
      })
  },

  // Security-Logs
  security: {
    rateLimitHit: (ip: string, endpoint: string, metadata?: any) =>
      logger.warn('Rate limit exceeded', {
        module: 'SECURITY',
        action: 'RATE_LIMIT',
        ip,
        endpoint,
        metadata
      }),
    
    accountLocked: (username: string, ip: string, metadata?: any) =>
      logger.warn('Account locked due to failed attempts', {
        module: 'SECURITY',
        action: 'ACCOUNT_LOCKED',
        username,
        ip,
        metadata
      }),
    
    csrfTokenInvalid: (username: string, ip: string, endpoint: string, metadata?: any) =>
      logger.warn('Invalid CSRF token', {
        module: 'SECURITY',
        action: 'CSRF_INVALID',
        username,
        ip,
        endpoint,
        metadata
      }),
    
    sessionRotation: (username: string, ip: string, action: string, metadata?: any) =>
      logger.info('Session rotated', {
        module: 'SECURITY',
        action: 'SESSION_ROTATION',
        username,
        ip,
        rotationReason: action,
        metadata
      })
  },

  // API-Logs
  api: {
    request: (method: string, endpoint: string, ip: string, username?: string, status?: number, duration?: number, metadata?: any) =>
      logger.info(`${method} ${endpoint}`, {
        module: 'API',
        action: 'REQUEST',
        method,
        endpoint,
        ip,
        username,
        status,
        duration,
        metadata
      }),
    
    error: (method: string, endpoint: string, ip: string, error: any, username?: string, metadata?: any) =>
      logger.error(`API Error: ${method} ${endpoint}`, {
        module: 'API',
        action: 'ERROR',
        method,
        endpoint,
        ip,
        username,
        error: error?.message,
        stack: error?.stack,
        metadata
      })
  }
};

export default logger;