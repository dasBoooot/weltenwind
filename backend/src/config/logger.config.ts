import winston from 'winston';
import * as dotenv from 'dotenv';
// Ensure env vars are loaded BEFORE reading process.env
dotenv.config();
import path from 'path';
import fs from 'fs';

// Environment Setup
const isDevelopment = process.env.NODE_ENV !== 'production';
const LOG_LEVEL = process.env.LOG_LEVEL || (isDevelopment ? 'debug' : 'info');
const LOG_TO_FILE = process.env.LOG_TO_FILE !== 'false';
const LOG_TO_CONSOLE = process.env.LOG_TO_CONSOLE !== 'false';

// Parse helpers for ENV-driven limits
function parseFileSizeToBytes(sizeInput: string | undefined, defaultBytes: number): number {
  if (!sizeInput) return defaultBytes;
  const normalized = String(sizeInput).trim().replace(/"/g, '');
  const match = normalized.match(/^(\d+)([kKmMgG])?$/);
  if (!match) return defaultBytes;
  const value = parseInt(match[1], 10);
  const unit = match[2]?.toLowerCase();
  switch (unit) {
    case 'k':
      return value * 1024;
    case 'm':
      return value * 1024 * 1024;
    case 'g':
      return value * 1024 * 1024 * 1024;
    default:
      return value; // bytes
  }
}

function parsePositiveInt(input: string | undefined, defaultValue: number): number {
  if (!input) return defaultValue;
  const n = parseInt(String(input).trim().replace(/"/g, ''), 10);
  return Number.isFinite(n) && n > 0 ? n : defaultValue;
}

const LOG_FILE_MAX_SIZE_BYTES = parseFileSizeToBytes(process.env.LOG_FILE_MAX_SIZE, 10 * 1024 * 1024); // default 10m
const LOG_FILE_MAX_FILES = parsePositiveInt(process.env.LOG_FILE_MAX_FILES, 5);
const ERROR_LOG_MAX_FILES = parsePositiveInt(process.env.ERROR_LOG_MAX_FILES, 10);

// Log Directory Resolution
// Priority: explicit LOG_DIR -> dev project-root logs -> production /var/log/weltenwind
// Sanitize LOG_DIR to avoid inline comments and quotes leaking into the path
const rawLogDir = process.env.LOG_DIR;
const sanitizedLogDir = rawLogDir
  ? rawLogDir.split('#')[0] // strip inline comments like "# ..."
      .replace(/"/g, '')    // remove quotes
      .trim()
  : undefined;

const explicitLogDir = sanitizedLogDir && sanitizedLogDir.length > 0
  ? sanitizedLogDir
  : undefined;

const LOGS_ROOT = explicitLogDir
  ? path.resolve(explicitLogDir)
  : (isDevelopment
      ? path.resolve(__dirname, '../../../logs')
      : path.resolve('/var/log/weltenwind'));

// Log Directories
const LOG_DIRS = {
  system: path.join(LOGS_ROOT, 'system'),
  auth: path.join(LOGS_ROOT, 'auth'),
  api: path.join(LOGS_ROOT, 'api'),
  security: path.join(LOGS_ROOT, 'security')
};

// Create log directories (including root)
const ensureDirectory = (dirPath: string) => {
  if (!fs.existsSync(dirPath)) {
    try {
      fs.mkdirSync(dirPath, { recursive: true, mode: 0o777 });
    } catch {
      // fallback ohne mode (z. B. auf HGFS wird mode ignoriert)
      try { fs.mkdirSync(dirPath, { recursive: true }); } catch {}
    }
  }
};

ensureDirectory(LOGS_ROOT);
Object.values(LOG_DIRS).forEach(ensureDirectory);
// Dynamic roots for worlds and modules
const WORLDS_ROOT = path.join(LOGS_ROOT, 'worlds');
const MODULES_ROOT = path.join(LOGS_ROOT, 'modules');

// Lazily created when first used

// Common Log Format
const logFormat = winston.format.combine(
  winston.format.timestamp({ format: 'YYYY-MM-DD HH:mm:ss.SSS' }),
  winston.format.errors({ stack: true }),
  winston.format.json()
);

// Ensure log file exists and is writable by all users (useful on shared mounts like HGFS)
function ensureFileWritable(filePath: string) {
  try {
    ensureDirectory(path.dirname(filePath));
    if (!fs.existsSync(filePath)) {
      // Create file with permissive mode; umask may still reduce it on some systems
      const fd = fs.openSync(filePath, 'a', 0o666);
      fs.closeSync(fd);
    }
    try {
      fs.chmodSync(filePath, 0o666);
    } catch { /* ignore chmod errors on mounts that don't support it */ }
  } catch {
    // ignore
  }
}

// File Transport Helper
const createFileTransport = (filePath: string, level?: string, isErrorLog: boolean = false) => {
  // Best-effort ensure the file can be written by the running service user
  ensureFileWritable(filePath);
  return new winston.transports.File({
    filename: filePath,
    level: level || LOG_LEVEL,
    maxsize: LOG_FILE_MAX_SIZE_BYTES,
    maxFiles: isErrorLog ? ERROR_LOG_MAX_FILES : LOG_FILE_MAX_FILES,
    tailable: true,
    format: logFormat,
    // Force permissive mode for new files (may still be affected by umask/mount)
    options: { flags: 'a', mode: 0o666 }
  });
};

// Build transports list based on ENV toggles
const withFileTransports = (transports: winston.transport[]): winston.transport[] => {
  return LOG_TO_FILE ? transports : [];
};

// Console transport factory for dynamic loggers
const createConsoleTransport = () => new winston.transports.Console({
  level: LOG_LEVEL,
  format: winston.format.combine(
    winston.format.colorize(),
    winston.format.timestamp({ format: 'HH:mm:ss' }),
    winston.format.printf(({ timestamp, level, message, module, action, ...meta }) => {
      const moduleStr = module ? `[${module}]` : '';
      const actionStr = action ? `[${action}]` : '';
      const metaStr = Object.keys(meta).length > 0 ? ` | ${JSON.stringify(meta)}` : '';
      return `${timestamp} ${level} ${moduleStr}${actionStr}: ${message}${metaStr}`;
    })
  )
});

// Individual Loggers for Each Category
const systemLogger = winston.createLogger({
  level: LOG_LEVEL,
  transports: withFileTransports([
    // Structured files (no root-level duplicates)
    createFileTransport(path.join(LOG_DIRS.system, 'app.log')),
    createFileTransport(path.join(LOG_DIRS.system, 'error.log'), 'error', true),
    createFileTransport(path.join(LOG_DIRS.system, 'startup.log'))
  ]),
  exceptionHandlers: withFileTransports([
    createFileTransport(path.join(LOG_DIRS.system, 'uncaught-exceptions.log'), 'error', true)
  ]),
  rejectionHandlers: withFileTransports([
    createFileTransport(path.join(LOG_DIRS.system, 'unhandled-rejections.log'), 'error', true)
  ]),
  exitOnError: false
});

const authLogger = winston.createLogger({
  level: LOG_LEVEL,
  transports: withFileTransports([
    createFileTransport(path.join(LOG_DIRS.auth, 'login.log')),
    createFileTransport(path.join(LOG_DIRS.auth, 'register.log')),
    createFileTransport(path.join(LOG_DIRS.auth, 'tokens.log')),
    createFileTransport(path.join(LOG_DIRS.auth, 'password-reset.log'))
  ])
});

const apiLogger = winston.createLogger({
  level: LOG_LEVEL,
  transports: withFileTransports([
    createFileTransport(path.join(LOG_DIRS.api, 'requests.log')),
    createFileTransport(path.join(LOG_DIRS.api, 'errors.log'), 'error', true)
  ])
});

const securityLogger = winston.createLogger({
  level: LOG_LEVEL,
  transports: withFileTransports([
    createFileTransport(path.join(LOG_DIRS.security, 'events.log')),
    createFileTransport(path.join(LOG_DIRS.security, 'csrf.log')),
    createFileTransport(path.join(LOG_DIRS.security, 'rate-limit.log')),
    createFileTransport(path.join(LOG_DIRS.security, 'sessions.log'))
  ])
});

// Console Transport for Development (and when enabled)
if (isDevelopment && LOG_TO_CONSOLE) {
  const consoleTransport = new winston.transports.Console({
    level: LOG_LEVEL,
    format: winston.format.combine(
      winston.format.colorize(),
      winston.format.timestamp({ format: 'HH:mm:ss' }),
      winston.format.printf(({ timestamp, level, message, module, action, ...meta }) => {
        const moduleStr = module ? `[${module}]` : '';
        const actionStr = action ? `[${action}]` : '';
        const metaStr = Object.keys(meta).length > 0 ? ` | ${JSON.stringify(meta)}` : '';
        return `${timestamp} ${level} ${moduleStr}${actionStr}: ${message}${metaStr}`;
      })
    )
  });

  systemLogger.add(consoleTransport);
  authLogger.add(consoleTransport);
  apiLogger.add(consoleTransport);
  securityLogger.add(consoleTransport);
}

// EXACT Logger API - matching ALL existing calls
export const loggers = {
  // System Logs - ALL variations used in codebase
  system: {
    info: (message: string, meta?: any) =>
      systemLogger.info(message, { module: 'SYSTEM', ...meta }),
    
    warn: (message: string, meta?: any) =>
      systemLogger.warn(message, { module: 'SYSTEM', ...meta }),
    
    // Flexible: supports (message, error, meta) OR (message, meta)
    error: (message: string, errorOrMeta?: any, maybeMeta?: any) => {
      const isError = errorOrMeta instanceof Error;
      const errorObj = isError ? errorOrMeta : (maybeMeta instanceof Error ? maybeMeta : undefined);
      const metaBase = isError ? maybeMeta : errorOrMeta;
      systemLogger.error(message, {
        module: 'SYSTEM',
        error: errorObj?.message,
        stack: errorObj?.stack,
        ...metaBase
      });
    },
    
    startup: (message: string, meta?: any) =>
      systemLogger.info(message, { module: 'SYSTEM', category: 'startup', ...meta })
  },

  // Dynamic World Logs
  worlds: {
    // Usage: loggers.worlds.for(worldId).info('message', meta?)
    for: (worldId: string) => {
      if (!worldId || String(worldId).trim().length === 0) {
        throw new Error('worldId is required for world logger');
      }
      ensureDirectory(WORLDS_ROOT);
      const worldDir = path.join(WORLDS_ROOT, String(worldId));
      ensureDirectory(worldDir);

      // Cache by worldId
      const existing = (loggers as any)._worldCache?.get(worldId);
      if (existing) {
        return existing;
      }

      const worldLogger = winston.createLogger({
        level: LOG_LEVEL,
        transports: withFileTransports([
          createFileTransport(path.join(worldDir, 'app.log')),
          createFileTransport(path.join(worldDir, 'error.log'), 'error', true)
        ]),
        exitOnError: false
      });

      if (isDevelopment && LOG_TO_CONSOLE) {
        worldLogger.add(createConsoleTransport());
      }

      const api = {
        info: (message: string, meta?: any) => worldLogger.info(message, { module: 'WORLD', worldId, ...meta }),
        warn: (message: string, meta?: any) => worldLogger.warn(message, { module: 'WORLD', worldId, ...meta }),
        error: (message: string, error?: any, meta?: any) =>
          worldLogger.error(message, { module: 'WORLD', worldId, error: error?.message, stack: error?.stack, ...meta })
      };

      // initialize cache holder on first use
      if (!(loggers as any)._worldCache) {
        (loggers as any)._worldCache = new Map<string, any>();
      }
      (loggers as any)._worldCache.set(worldId, api);
      return api;
    }
  },

  // Dynamic Module Logs
  modules: {
    // Usage: loggers.modules.for(moduleName).info('message', meta?)
    for: (moduleName: string) => {
      if (!moduleName || String(moduleName).trim().length === 0) {
        throw new Error('moduleName is required for module logger');
      }
      ensureDirectory(MODULES_ROOT);
      const modDir = path.join(MODULES_ROOT, String(moduleName));
      ensureDirectory(modDir);

      // Cache by moduleName
      const existing = (loggers as any)._moduleCache?.get(moduleName);
      if (existing) {
        return existing;
      }

      const moduleLogger = winston.createLogger({
        level: LOG_LEVEL,
        transports: withFileTransports([
          createFileTransport(path.join(modDir, 'events.log')),
          createFileTransport(path.join(modDir, 'errors.log'), 'error', true)
        ]),
        exitOnError: false
      });

      if (isDevelopment && LOG_TO_CONSOLE) {
        moduleLogger.add(createConsoleTransport());
      }

      const api = {
        info: (message: string, meta?: any) => moduleLogger.info(message, { module: 'MODULE', moduleName, ...meta }),
        warn: (message: string, meta?: any) => moduleLogger.warn(message, { module: 'MODULE', moduleName, ...meta }),
        error: (message: string, error?: any, meta?: any) =>
          moduleLogger.error(message, { module: 'MODULE', moduleName, error: error?.message, stack: error?.stack, ...meta })
      };

      if (!(loggers as any)._moduleCache) {
        (loggers as any)._moduleCache = new Map<string, any>();
      }
      (loggers as any)._moduleCache.set(moduleName, api);
      return api;
    }
  },

  // Auth Logs - EXACT signatures from auth.ts
  auth: {
    // loggers.auth.login(loginIdentifier, ip, success, reason/meta)
    login: (username: string, ip: string, success: boolean, meta?: any) =>
      authLogger.info(`Login ${success ? 'successful' : 'failed'}`, {
        module: 'AUTH',
        category: 'login',
        username,
        ip,
        success,
        ...meta
      }),
    
    // loggers.auth.logout(username, ip, meta)
    logout: (username: string, ip: string, meta?: any) =>
      authLogger.info('User logged out', {
        module: 'AUTH',
        category: 'logout',
        username,
        ip,
        ...meta
      }),
    
    // loggers.auth.register(username, email, ip, meta)
    register: (username: string, email: string, ip: string, meta?: any) =>
      authLogger.info('User registration attempt', {
        module: 'AUTH',
        category: 'register',
        username,
        email,
        ip,
        ...meta
      }),
    
    // loggers.auth.passwordChange(username, ip, meta)
    passwordChange: (username: string, ip: string, meta?: any) =>
      authLogger.info('Password change attempt', {
        module: 'AUTH',
        category: 'password-change',
        username,
        ip,
        ...meta
      }),
    
    // loggers.auth.info(message, action, meta)
    info: (message: string, action?: string, meta?: any) =>
      authLogger.info(message, {
        module: 'AUTH',
        action,
        ...meta
      }),
    
    warn: (message: string, action?: string, meta?: any) =>
      authLogger.warn(message, {
        module: 'AUTH',
        action,
        ...meta
      }),
    
    // Flexible: supports (message, action, meta) OR (message, metaOnly)
    error: (message: string, actionOrMeta?: any, maybeMeta?: any) => {
      const hasAction = typeof actionOrMeta === 'string';
      const action = hasAction ? actionOrMeta : undefined;
      const meta = hasAction ? maybeMeta : actionOrMeta;
      authLogger.error(message, {
        module: 'AUTH',
        action,
        ...meta
      });
    }
  },

  // API Logs - EXACT signatures from logging.middleware.ts
  api: {
    // loggers.api.request(method, url, status, ip, userAgent, duration, meta)
    request: (method: string, url: string, status: number, ip: string, userAgent?: string, duration?: number, meta?: any) =>
      apiLogger.info(`${method} ${url} ${status}`, {
        module: 'API',
        category: 'request',
        method,
        url,
        status,
        ip,
        userAgent,
        duration,
        ...meta
      }),
    
    // loggers.api.error(message, meta)
    error: (message: string, meta?: any) =>
      apiLogger.error(message, {
        module: 'API',
        category: 'error',
        ...meta
      })
  },

  // Security Logs - EXACT signatures from all security files
  security: {
    // loggers.security.rateLimitHit(ip, endpoint, meta)
    rateLimitHit: (ip: string, endpoint: string, meta?: any) =>
      securityLogger.warn('Rate limit exceeded', {
        module: 'SECURITY',
        category: 'rate-limit',
        event: 'rate_limit',
        ip,
        endpoint,
        ...meta
      }),
    
    // loggers.security.csrfTokenInvalid(ip, meta)
    csrfTokenInvalid: (ip: string, meta?: any) =>
      securityLogger.warn('Invalid CSRF token', {
        module: 'SECURITY',
        category: 'csrf',
        event: 'csrf_invalid',
        ip,
        ...meta
      }),
    
    // loggers.security.sessionSecurityCheck(userId, ip, meta)
    sessionSecurityCheck: (userId: number, ip: string, meta?: any) =>
      securityLogger.warn('Session security check', {
        module: 'SECURITY',
        category: 'session',
        event: 'session_check',
        userId,
        ip,
        ...meta
      }),
    
    // loggers.security.sessionRotation(userId, ip, action, meta)
    sessionRotation: (userId: string, ip: string, action: string, meta?: any) =>
      securityLogger.info('Session rotated', {
        module: 'SECURITY',
        category: 'session',
        event: 'session_rotation',
        userId,
        ip,
        action,
        ...meta
      }),
    
    // Additional security methods for completeness
    accountLocked: (username: string, ip: string, meta?: any) =>
      securityLogger.warn('Account locked', {
        module: 'SECURITY',
        category: 'security',
        event: 'account_locked',
        username,
        ip,
        ...meta
      }),
    
    suspiciousSessionActivity: (userId: number, ip: string, reasons: string[], meta?: any) =>
      securityLogger.warn('Suspicious session activity', {
        module: 'SECURITY',
        category: 'security',
        event: 'suspicious_activity',
        userId,
        ip,
        reasons,
        ...meta
      }),
    
    sessionCleanup: (action: string, count: number, meta?: any) =>
      securityLogger.info('Session cleanup', {
        module: 'SECURITY',
        category: 'security',
        event: 'session_cleanup',
        action,
        count,
        ...meta
      })
  },

  // ARB/Localization Logs - for backward compatibility
  arb: {
    info: (message: string, meta?: any) =>
      systemLogger.info(message, { module: 'ARB', category: 'localization', ...meta }),
    
    warn: (message: string, meta?: any) =>
      systemLogger.warn(message, { module: 'ARB', category: 'localization', ...meta }),
    
    error: (message: string, error?: any, meta?: any) =>
      systemLogger.error(message, { 
        module: 'ARB', 
        category: 'localization',
        error: error?.message,
        stack: error?.stack,
        ...meta 
      })
  },

  // Client Config Logs - for backward compatibility
  clientConfig: {
    requested: (ip: string, userAgent?: string, meta?: any) =>
      systemLogger.info('Client config requested', {
        module: 'CLIENT_CONFIG',
        category: 'config',
        ip,
        userAgent,
        ...meta
      }),
    
    served: (ip: string, config: any, meta?: any) =>
      systemLogger.info('Client config served', {
        module: 'CLIENT_CONFIG',
        category: 'config',
        ip,
        configKeys: Object.keys(config),
        ...meta
      })
  }
};

// Startup Log
loggers.system.startup('🚀 Winston Logger initialized with clean structure', {
  logLevel: LOG_LEVEL,
  isDevelopment,
  logDirectories: Object.keys(LOG_DIRS),
  logRoot: LOGS_ROOT,
  logToFile: LOG_TO_FILE,
  logToConsole: LOG_TO_CONSOLE,
  winston_version: require('winston/package.json').version
});

// Export main logger for compatibility
export const logger = systemLogger;
export default systemLogger;

// Development smoke logs to verify subdirectory outputs
if (isDevelopment) {
  try {
    loggers.system.info('SMOKE: system/app log write');
    loggers.system.error('SMOKE: system/error log write (simulated error)', undefined, { simulated: true });

    loggers.api.request('GET', '/dev/smoke', 200, '127.0.0.1', 'weltenwind-smoke', 3, { smoke: true });
    loggers.api.error('SMOKE: api/errors log write', { smoke: true });

    loggers.auth.login('smoke-user', '127.0.0.1', false, { reason: 'dev-smoke' });
    loggers.auth.register('smoke-user', 'smoke@example.com', '127.0.0.1', { reason: 'dev-smoke' });

    loggers.security.csrfTokenInvalid('127.0.0.1', { reason: 'dev-smoke' });
    loggers.security.rateLimitHit('127.0.0.1', '/dev/smoke', { reason: 'dev-smoke' });

    // Dynamic world/module
    loggers.worlds.for('dev-world').info('SMOKE: world/app log write', { smoke: true });
    loggers.modules.for('dev-module').info('SMOKE: module/events log write', { smoke: true });
  } catch (err) {
    // no-op
  }
}