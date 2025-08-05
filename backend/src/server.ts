import express from 'express';
import cors from 'cors';
import helmet from 'helmet';
import * as dotenv from 'dotenv';
import path from 'path';
import fs from 'fs';

// Lade Environment-Variablen VOR allen anderen Imports
dotenv.config();

// ===========================================
// 🌐 URL CONFIGURATION (SSL-Ready)
// ===========================================

// SSL & Proxy Konfiguration aus .env
const SSL_ENABLED = process.env.SSL_ENABLED === 'true';
const TRUST_PROXY_ENABLED = process.env.TRUST_PROXY === 'true';

// Backend Internal URLs (für Logs, Health-Checks, interne Calls)
const BASE_URL = process.env.BASE_URL || `http://localhost:${process.env.PORT || 3000}`;

// Public/External URLs (für Clients über nginx)
const PUBLIC_API_URL = process.env.PUBLIC_API_URL || 'https://192.168.2.168/api';
const PUBLIC_CLIENT_URL = process.env.PUBLIC_CLIENT_URL || 'https://192.168.2.168';
const PUBLIC_ASSETS_URL = process.env.PUBLIC_ASSETS_URL || 'https://192.168.2.168';

// JWT-Konfiguration initialisieren (prüft JWT_SECRET)
import { jwtConfig } from './config/jwt.config';

// Logging-Konfiguration
import { loggers } from './config/logger.config';
import { requestLoggingMiddleware, errorLoggingMiddleware } from './middleware/logging.middleware';

import authRoutes from './routes/auth';
import worldRoutes from './routes/worlds';
import inviteRoutes from './routes/invites';
import logRoutes from './routes/logs';
import arbRoutes from './routes/arb';
import themeRoutes from './routes/themes';
import healthRoutes from './routes/health';
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

console.log(`🔐 SECURITY: isDevelopment=${isDevelopment}, NODE_ENV=${process.env.NODE_ENV}`);

// ✅ Trust Proxy (für nginx Reverse Proxy) - SICHER konfiguriert
if (TRUST_PROXY_ENABLED) {
  app.set('trust proxy', 1); // Nur ersten Proxy (nginx) vertrauen - SICHERER!
  console.log('🔗 Trust Proxy: AKTIVIERT (nginx Reverse Proxy - nur 1 Hop)');
}

app.use(helmet({
  // ✅ CSP für HTTPS-Development aktivieren (SSL-Testing)
  contentSecurityPolicy: {
    directives: {
      defaultSrc: ["'self'"],
      styleSrc: ["'self'", "'unsafe-inline'", "https://fonts.googleapis.com"],
      fontSrc: ["'self'", "https://fonts.gstatic.com"],
      imgSrc: ["'self'", "data:", "https:"],
      scriptSrc: ["'self'", "'unsafe-inline'", "'unsafe-eval'", "https://www.gstatic.com"], // Flutter CanvasKit
      scriptSrcElem: ["'self'", "'unsafe-inline'", "https://www.gstatic.com"], // Flutter CanvasKit scripts
      connectSrc: ["'self'", "https://192.168.2.168", "https://www.gstatic.com", "https://fonts.gstatic.com"], // Flutter + Backend + Fonts
      frameSrc: ["'none'"],
      objectSrc: ["'none'"],
      // ⚠️ upgradeInsecureRequests nur in Production
      ...(isDevelopment ? {} : { upgradeInsecureRequests: [] }),
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
        // HTTP für Development
        /^http:\/\/localhost(:\d+)?$/,
        /^http:\/\/127\.0\.0\.1(:\d+)?$/,
        /^http:\/\/192\.168\.\d+\.\d+(:\d+)?$/,
        /^http:\/\/\[::1\](:\d+)?$/,
        // HTTPS für SSL-Setup
        /^https:\/\/localhost(:\d+)?$/,
        /^https:\/\/127\.0\.0\.1(:\d+)?$/,
        /^https:\/\/192\.168\.\d+\.\d+(:\d+)?$/,
        /^https:\/\/\[::1\](:\d+)?$/
      ];
      
      if (!origin || allowedPatterns.some(pattern => pattern.test(origin))) {
        callback(null, true);
      } else {
        callback(new Error('Not allowed by CORS'));
      }
    } else {
      // Production: Nutze Environment Variable
      const allowedOrigins = process.env.ALLOWED_ORIGINS?.split(',') || [PUBLIC_CLIENT_URL];
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
app.use('/api', healthRoutes);  // Health-Check ohne Authentifizierung
app.use('/api/auth', authRoutes);
app.use('/api/worlds', worldRoutes);
app.use('/api/invites', inviteRoutes);
app.use('/api/logs', logRoutes);
app.use('/api/arb', arbRoutes);
app.use('/api/themes', themeRoutes);

// === API-Doku (OpenAPI) ===
// === API-combined.yaml direkt bereitstellen ===
app.get('/api-combined.yaml', (req, res) => {
  res.sendFile(path.resolve(__dirname, '../../docs/openapi/generated/api-combined.yaml'));
});

// === Swagger UI unter /docs ===
// swagger-ui-express mit korrigierter YAML-URL
const swaggerOptions = {
  customCss: '.swagger-ui .topbar { display: none }',
  customSiteTitle: 'Weltenwind API Documentation',
  swaggerOptions: {
    // ✅ Hardcoded HTTPS-URL für nginx (statt HTTP:3000)
    url: 'https://192.168.2.168/api-combined.yaml'
  }
};

app.use('/docs', swaggerUi.serve);
app.get('/docs', swaggerUi.setup(null, swaggerOptions));

// === ARB Manager unter /arb-manager ===
const publicPath = path.resolve(__dirname, '../tools/arb-editor');
console.log(`🌍 ARB Manager-Pfad: ${publicPath}`);

// Security-Middleware für ARB Manager
app.use('/arb-manager', (req, res, next) => {
  // XSS-Protection Headers
  res.setHeader('X-Content-Type-Options', 'nosniff');
  res.setHeader('X-Frame-Options', 'DENY');
  res.setHeader('X-XSS-Protection', '1; mode=block');
  res.setHeader('Referrer-Policy', 'strict-origin-when-cross-origin');
  
  // Content Security Policy für ARB Manager
  res.setHeader('Content-Security-Policy', [
    "default-src 'self'",
    "script-src 'self' 'unsafe-inline'", // Für inline Event-Handler wie onclick
    "style-src 'self' 'unsafe-inline'",  // Für inline Styles
    "connect-src 'self'",                // Für API-Calls
    "img-src 'self' data:",              // Für Base64-Bilder falls nötig
    "font-src 'self'",                   // Für Web-Fonts
    "object-src 'none'",                 // Plugins blockieren
    "base-uri 'self'",                   // Base-Tag Manipulation verhindern
    "form-action 'self'"                 // Form-Submissions nur an eigene Domain
  ].join('; '));
  
  // Cache-Control für sensible ARB-Daten
  res.setHeader('Cache-Control', 'no-store, no-cache, must-revalidate, private');
  res.setHeader('Pragma', 'no-cache');
  res.setHeader('Expires', '0');
  
  next();
});

app.use('/arb-manager', express.static(publicPath));

// === Theme Editor unter /theme-editor ===
const themeEditorPath = path.resolve(__dirname, '../tools/theme-editor');
console.log(`🎨 Theme-Editor-Pfad: ${themeEditorPath}`);

// Cache-Busting für Theme Editor
app.use('/theme-editor', (req, res, next) => {
  if (req.path.endsWith('.js') || req.path.endsWith('.css') || req.path.endsWith('.html')) {
    res.set({
      'Cache-Control': 'no-cache, no-store, must-revalidate',
      'Pragma': 'no-cache',
      'Expires': '0'
    });
  }
  next();
});

app.use('/theme-editor', express.static(themeEditorPath));

// === Log Viewer unter /log-viewer ===
const logViewerPath = path.resolve(__dirname, '../tools/log-viewer');
console.log(`🔍 Log-Viewer-Pfad: ${logViewerPath}`);

// Security-Middleware für Log Viewer
app.use('/log-viewer', (req, res, next) => {
  // XSS-Protection Headers
  res.setHeader('X-Content-Type-Options', 'nosniff');
  res.setHeader('X-Frame-Options', 'DENY');
  res.setHeader('X-XSS-Protection', '1; mode=block');
  res.setHeader('Referrer-Policy', 'strict-origin-when-cross-origin');
  
  // Content Security Policy für Log Viewer
  res.setHeader('Content-Security-Policy', [
    "default-src 'self'",
    "script-src 'self' 'unsafe-inline'", // Für onclick Event-Handler
    "style-src 'self' 'unsafe-inline'",  // Für inline Styles
    "connect-src 'self'",                // Für API-Calls
    "img-src 'self' data:",              // Für Base64-Bilder falls nötig
    "font-src 'self'",                   // Für Web-Fonts
    "object-src 'none'",                 // Plugins blockieren
    "base-uri 'self'",                   // Base-Tag Manipulation verhindern
    "form-action 'self'"                 // Form-Submissions nur an eigene Domain
  ].join('; '));
  
  // Cache-Control für sensible Log-Daten
  res.setHeader('Cache-Control', 'no-store, no-cache, must-revalidate, private');
  res.setHeader('Pragma', 'no-cache');
  res.setHeader('Expires', '0');
  
  next();
});

app.use('/log-viewer', express.static(logViewerPath));

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

// DEBUG: Alle /game Requests loggen
app.use('/game', (req, res, next) => {
  console.log(`📁 GAME REQUEST: ${req.method} ${req.path}`);
  next();
});

app.use('/game', express.static(flutterWebPath));

// SPA Fallback für alle /game Sub-Routen (z.B. /game/go/invite/token)  
app.get(/^\/game\/.*/, (req, res) => {
  const file = path.resolve(__dirname, '../../client/build/web/index.html');
  console.log(`📦 FALLBACK TRIGGERED: ${req.path}`);
  console.log(`📦 ORIGINAL URL: ${req.originalUrl}`);
  console.log(`📦 FULL URL: ${req.protocol}://${req.get('host')}${req.originalUrl}`);
  console.log(`📦 QUERY: ${JSON.stringify(req.query)}`);
  console.log(`📦 SENDING FILE: ${file}`);
  
  // Prüfe ob Datei existiert
  if (!fs.existsSync(file)) {
    console.log('❌ INDEX.HTML NICHT GEFUNDEN!');
    return res.status(404).send('index.html not found');
  }
  
  res.set({
    'Cache-Control': 'no-cache, no-store, must-revalidate',
    'Pragma': 'no-cache',
    'Expires': '0'
  });
  res.sendFile(file);
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
// Cleanup-Konfiguration aus .env
const AUTO_CLEANUP_ENABLED = process.env.AUTO_CLEANUP_EXPIRED_SESSIONS === 'true';
const SESSION_CLEANUP_INTERVAL = parseInt(process.env.SESSION_CLEANUP_INTERVAL_MINUTES || '5', 10) * 60 * 1000;

// Nur Cleanup starten wenn aktiviert
if (AUTO_CLEANUP_ENABLED) {
  console.log('🧹 Auto Session Cleanup: AKTIVIERT');
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
  }, SESSION_CLEANUP_INTERVAL);
} else {
  console.log('🧹 Auto Session Cleanup: DEAKTIVIERT');
}

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
  console.log(`🚀 Weltenwind-API läuft auf Port ${PORT} (intern: ${BASE_URL})`);
  console.log(`🎮 Flutter-Game verfügbar unter: ${PUBLIC_CLIENT_URL}/game`);
  console.log(`🌍 ARB Manager verfügbar unter: ${PUBLIC_ASSETS_URL}/arb-manager/`);
  console.log(`🎨 Theme Editor verfügbar unter: ${PUBLIC_ASSETS_URL}/theme-editor/`);
  console.log(`📘 Swagger Editor verfügbar unter: ${PUBLIC_CLIENT_URL}/docs`);
  console.log(`📄 API-Doku YAML erreichbar unter: ${PUBLIC_CLIENT_URL}/api-combined.yaml`);
  console.log(`🔍 Log-Viewer verfügbar unter: ${PUBLIC_ASSETS_URL}/log-viewer/`);
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
      api: PUBLIC_API_URL,
      game: `${PUBLIC_CLIENT_URL}/game`,
      arbManager: `${PUBLIC_ASSETS_URL}/arb-manager/`,
      themeEditor: `${PUBLIC_ASSETS_URL}/theme-editor/`,
      docs: `${PUBLIC_CLIENT_URL}/docs`,
      logs: `${PUBLIC_ASSETS_URL}/log-viewer/`,
      openapi: `${PUBLIC_CLIENT_URL}/api-combined.yaml`
    }
  });

  // Session-Cleanup (detailliertere Intervals - 2x Session-Cleanup-Intervall)
  setInterval(async () => {
    try {
      const result = await cleanupExpiredSessions();
      console.log(`[Session-Cleanup] ${result.count} abgelaufene Sessions entfernt`);
      loggers.system.info('Detailed session cleanup completed', {
        deletedSessions: result.count,
        cleanupType: 'expired_sessions_detailed',
        interval: `${SESSION_CLEANUP_INTERVAL * 2 / 60000}min`
      });
    } catch (error) {
      console.error('[Session-Cleanup] Fehler:', error);
      loggers.system.error('Detailed session cleanup failed', error, {
        cleanupType: 'expired_sessions_detailed'
      });
    }
  }, SESSION_CLEANUP_INTERVAL * 2); // 2x Session-Cleanup-Intervall

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
  }, SESSION_CLEANUP_INTERVAL * 3); // 3x Session-Cleanup-Intervall
});
