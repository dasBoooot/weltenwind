import express from 'express';
import cors from 'cors';
import helmet from 'helmet';
import * as dotenv from 'dotenv';
import path from 'path';
import fs from 'fs';

// Lade Environment-Variablen VOR allen anderen Imports
dotenv.config();

// JWT-Konfiguration initialisieren (prüft JWT_SECRET)
import { jwtConfig } from './config/jwt.config';

// Logging-Konfiguration
import { loggers } from './config/logger.config';
import { requestLoggingMiddleware, errorLoggingMiddleware } from './middleware/logging.middleware';

import authRoutes from './routes/auth';
import worldRoutes from './routes/worlds';
import inviteRoutes from './routes/invites';
import logRoutes from './routes/logs';
import { cleanupExpiredSessions } from './services/session.service';
import { cleanupExpiredLockouts } from './services/brute-force-protection.service';
import prisma from './libs/prisma';
import swaggerUi from 'swagger-ui-express';
import { configureTrustProxy } from './middleware/rateLimiter';

const app = express();
const PORT = process.env.PORT || 3000;

// JWT-Konfiguration laden und validieren
console.log('🔐 JWT-Konfiguration geladen und validiert');
loggers.system.info('JWT configuration loaded and validated', {
  issuer: jwtConfig.getTokenConfig().issuer,
  audience: jwtConfig.getTokenConfig().audience,
  environment: process.env.NODE_ENV
});

// Trust Proxy für korrekte IP-Erkennung
configureTrustProxy(app);

// Security Headers mit Helmet
const isDevelopment = process.env.NODE_ENV !== 'production';

app.use(helmet({
  contentSecurityPolicy: isDevelopment ? false : {
    directives: {
      defaultSrc: ["'self'"],
      styleSrc: ["'self'", "'unsafe-inline'", "https://fonts.googleapis.com"],
      fontSrc: ["'self'", "https://fonts.gstatic.com"],
      imgSrc: ["'self'", "data:", "https:"],
      scriptSrc: ["'self'", "'unsafe-inline'", "'unsafe-eval'"], // unsafe-eval für Swagger UI
      connectSrc: ["'self'"],
      frameSrc: ["'none'"],
      objectSrc: ["'none'"],
      upgradeInsecureRequests: [],
    }
  },
  hsts: isDevelopment ? false : {
    maxAge: 31536000,
    includeSubDomains: true,
    preload: true
  },
  crossOriginOpenerPolicy: isDevelopment ? false : undefined,
  originAgentCluster: isDevelopment ? false : true,
  noSniff: true,
  dnsPrefetchControl: { allow: false },
  frameguard: { action: 'deny' },
  permittedCrossDomainPolicies: false,
  referrerPolicy: { policy: 'strict-origin-when-cross-origin' },
  xssFilter: true
}));

// CORS konfiguration - erweitert für Development
const corsOptions = {
  origin: (origin: string | undefined, callback: (err: Error | null, allow?: boolean | string | string[]) => void) => {
    // In Development alle lokalen Origins erlauben
    if (isDevelopment) {
      const allowedPatterns = [
        /^http:\/\/localhost(:\d+)?$/,
        /^http:\/\/127\.0\.0\.1(:\d+)?$/,
        /^http:\/\/192\.168\.\d+\.\d+(:\d+)?$/,
        /^http:\/\/\[::1\](:\d+)?$/ // IPv6 localhost
      ];
      
      if (!origin || allowedPatterns.some(pattern => pattern.test(origin))) {
        callback(null, true);
      } else {
        callback(new Error('Not allowed by CORS'));
      }
    } else {
      // Production: Nutze Environment Variable
      const allowedOrigins = process.env.ALLOWED_ORIGINS?.split(',') || ['http://localhost:8080'];
      callback(null, allowedOrigins);
    }
  },
  credentials: true,
  optionsSuccessStatus: 200
};
app.use(cors(corsOptions));

// Middleware
app.use(express.json());

// Request-Logging Middleware (nach JSON-Parsing)
app.use(requestLoggingMiddleware);

// === API-Routen ===
app.use('/api/auth', authRoutes);
app.use('/api/worlds', worldRoutes);
app.use('/api/invites', inviteRoutes);
app.use('/api/logs', logRoutes);

// === API-Doku (OpenAPI) ===
// === API-combined.yaml direkt bereitstellen ===
app.get('/api-combined.yaml', (req, res) => {
  res.sendFile(path.resolve(__dirname, '../../docs/api-combined.yaml'));
});

// === Swagger Editor unter /docs ===
// → mit require.resolve (robuster als direkter Pfad)
const swaggerEditorPath = path.dirname(require.resolve('swagger-editor-dist/index.html'));
app.use('/docs', express.static(swaggerEditorPath));

// === Flutter-Web-App unter /game ===
// 1. Statische Dateien zuerst (für Assets)
const flutterWebPath = path.resolve(__dirname, '../../client/build/web');
console.log(`🎮 Flutter-Web-Pfad: ${flutterWebPath}`);

// Cache-Busting für kritische Flutter-Dateien
app.use('/game', (req, res, next) => {
  // Cache-Busting für main.dart.js und andere kritische Dateien
  if (req.path.endsWith('main.dart.js') || 
      req.path.endsWith('flutter.js') || 
      req.path.endsWith('flutter_bootstrap.js') ||
      req.path.endsWith('index.html')) {
    res.set({
      'Cache-Control': 'no-cache, no-store, must-revalidate',
      'Pragma': 'no-cache',
      'Expires': '0',
      'ETag': `"${Date.now()}"` // Dynamischer ETag für Cache-Busting
    });
  }
  next();
});

app.use('/game', express.static(flutterWebPath));

// 2. Fallback für alle anderen /game Routen auf index.html
app.get('/game', (req, res) => {
  res.sendFile(path.resolve(__dirname, '../../client/build/web/index.html'));
});

app.get('/game/:path', (req, res) => {
  res.sendFile(path.resolve(__dirname, '../../client/build/web/index.html'));
});

// === Info- und Status-Endpunkte ===
app.get('/', (req, res) => {
  res.send('Willkommen beim Weltenwind-API-Server 🚀');
});

app.get('/api/health', (req, res) => {
  res.status(200).json({
    status: 'ok',
    timestamp: new Date().toISOString(),
    env: process.env.NODE_ENV || 'development',
  });
});

// === Session-Cleanup-Job ===
// Alle 5 Minuten abgelaufene Sessions löschen
setInterval(async () => {
  try {
    const result = await cleanupExpiredSessions();
    if (result.count > 0) {
      console.log(`[${new Date().toISOString()}] 🧹 Cleanup: ${result.count} abgelaufene Sessions gelöscht`);
      loggers.system.info('Session cleanup completed', { 
        deletedSessions: result.count,
        cleanupType: 'expired_sessions'
      });
    }
  } catch (error) {
    console.error(`[${new Date().toISOString()}] ❌ Session-Cleanup fehlgeschlagen:`, error);
    loggers.system.error('Session cleanup failed', error, {
      cleanupType: 'expired_sessions'
    });
  }
}, 5 * 60 * 1000); // 5 Minuten

// Error-Logging Middleware (am Ende, vor Server-Start)
app.use(errorLoggingMiddleware);

// === Graceful Shutdown ===
process.on('SIGINT', async () => {
  console.log('⏹ Server wird heruntergefahren...');
  loggers.system.info('Server shutdown initiated (SIGINT)', {
    signal: 'SIGINT',
    reason: 'user_interrupt'
  });
  try {
    await prisma.$disconnect();
    console.log('✅ Prisma-Verbindung geschlossen');
    loggers.system.info('Prisma connection closed successfully', {
      shutdownStep: 'database_disconnect'
    });
  } catch (error) {
    console.error('❌ Fehler beim Schließen der Prisma-Verbindung:', error);
    loggers.system.error('Failed to close Prisma connection', error, {
      shutdownStep: 'database_disconnect'
    });
  }
  process.exit(0);
});

process.on('SIGTERM', async () => {
  console.log('⏹ Server wird heruntergefahren (SIGTERM)...');
  loggers.system.info('Server shutdown initiated (SIGTERM)', {
    signal: 'SIGTERM',
    reason: 'system_termination'
  });
  try {
    await prisma.$disconnect();
    console.log('✅ Prisma-Verbindung geschlossen');
    loggers.system.info('Prisma connection closed successfully', {
      shutdownStep: 'database_disconnect'
    });
  } catch (error) {
    console.error('❌ Fehler beim Schließen der Prisma-Verbindung:', error);
    loggers.system.error('Failed to close Prisma connection', error, {
      shutdownStep: 'database_disconnect'
    });
  }
  process.exit(0);
});

// === Server starten ===
app.listen(PORT, () => {
  console.log(`🚀 Weltenwind-API läuft auf Port ${PORT}`);
  console.log(`🎮 Flutter-Game verfügbar unter: http://localhost:${PORT}/game`);
  console.log(`📘 Swagger Editor verfügbar unter: http://localhost:${PORT}/docs`);
  console.log(`📄 API-Doku YAML erreichbar unter: http://localhost:${PORT}/api-combined.yaml`);
  console.log(`🔍 Log-Viewer verfügbar unter: http://localhost:${PORT}/api/logs/viewer`);
  console.log(`🧹 Session-Cleanup alle 5 Minuten aktiv`);

  // Startup-Log
  loggers.system.info('Weltenwind Backend started successfully', {
    port: PORT,
    nodeEnv: process.env.NODE_ENV || 'development',
    version: require('../package.json').version,
    features: {
      sessionCleanup: '5min',
      multiDeviceLogin: process.env.ALLOW_MULTI_DEVICE_LOGIN === 'true',
      maxSessionsPerUser: parseInt(process.env.MAX_SESSIONS_PER_USER || '1', 10)
    },
    endpoints: {
      api: `http://localhost:${PORT}/api`,
      game: `http://localhost:${PORT}/game`,
      docs: `http://localhost:${PORT}/docs`,
      logs: `http://localhost:${PORT}/api/logs/viewer`,
      openapi: `http://localhost:${PORT}/api-combined.yaml`
    }
  });

  // Session-Cleanup (detailliertere Intervals)
  setInterval(async () => {
    try {
      const result = await cleanupExpiredSessions();
      console.log(`[Session-Cleanup] ${result.count} abgelaufene Sessions entfernt`);
      loggers.system.info('Detailed session cleanup completed', {
        deletedSessions: result.count,
        cleanupType: 'expired_sessions_detailed',
        interval: '10min'
      });
    } catch (error) {
      console.error('[Session-Cleanup] Fehler:', error);
      loggers.system.error('Detailed session cleanup failed', error, {
        cleanupType: 'expired_sessions_detailed'
      });
    }
  }, 10 * 60 * 1000); // 10 Minuten

  // Cleanup für abgelaufene Account-Lockouts
  setInterval(async () => {
    try {
      const count = await cleanupExpiredLockouts();
      console.log(`[Lockout-Cleanup] ${count} abgelaufene Account-Sperren aufgehoben`);
      loggers.system.info('Account lockout cleanup completed', {
        unlockedAccounts: count,
        cleanupType: 'expired_lockouts',
        interval: '15min'
      });
    } catch (error) {
      console.error('[Lockout-Cleanup] Fehler:', error);
      loggers.system.error('Account lockout cleanup failed', error, {
        cleanupType: 'expired_lockouts'
      });
    }
  }, 15 * 60 * 1000); // 15 Minuten
});
