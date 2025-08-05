import express from 'express';
import fs from 'fs';
import path from 'path';
import { authenticate, AuthenticatedRequest } from '../middleware/authenticate';
import { hasPermission } from '../services/access-control.service';
import { adminEndpointLimiter } from '../middleware/rateLimiter';

const router = express.Router();
const isDevelopment = process.env.NODE_ENV !== 'production';
const logsDir = isDevelopment
  ? path.resolve(__dirname, '../../../logs')
  : '/var/log/weltenwind';

// Systemd Service Log-Pfade (nur in Production)
const systemdLogsDir = '/var/log/weltenwind';

// Log-Kategorien definieren
const logCategories = {
  // Winston Structured Logs
  winston: {
    'app.log': 'App (Alle Winston-Logs)',
    'auth.log': 'Auth (Login/Register/Logout)',
    'security.log': 'Security (Rate Limits, CSRF, Lockouts)',  
    'api.log': 'API (Requests/Responses)',
    'error.log': 'Errors (Nur Fehler)'
  },
  // Systemd Service Logs (nur Production)
  services: isDevelopment ? {} : {
    'backend.log': 'Backend Service (stdout)',
    'backend.error.log': 'Backend Service (stderr)',
    'docs.log': 'Documentation Service',
    'studio.log': 'Prisma Studio Service'
  },
  // System Logs (nur Production/Linux)
  system: isDevelopment ? {} : {
    'syslog': 'System Log',
    'auth.log': 'System Auth Log',
    'nginx/access.log': 'Nginx Access',
    'nginx/error.log': 'Nginx Errors'
  }
};

// Alle verfügbaren Log-Dateien sammeln
function getAllLogFiles(): Record<string, string> {
  const allLogs: Record<string, string> = {};
  
  // Winston Logs hinzufügen
  Object.entries(logCategories.winston).forEach(([file, description]) => {
    allLogs[file] = description;
  });
  
  // Service Logs hinzufügen (nur Production)
  if (!isDevelopment) {
    Object.entries(logCategories.services).forEach(([file, description]) => {
      allLogs[file] = description;
    });
    
    // System Logs hinzufügen (nur Production)
    Object.entries(logCategories.system).forEach(([file, description]) => {
      allLogs[file] = description;
    });
  }
  
  return allLogs;
}

// Log-Datei-Pfad auflösen
function resolveLogPath(logFile: string): string {
  // Winston Logs
  if (logFile in logCategories.winston) {
    return path.join(logsDir, logFile);
  }
  
  // Service Logs (nur Production)
  if (!isDevelopment && logFile in logCategories.services) {
    return path.join(systemdLogsDir, logFile);
  }
  
  // System Logs (nur Production)
  if (!isDevelopment && logFile in logCategories.system) {
    if (logFile.startsWith('nginx/')) {
      return path.join('/var/log', logFile);
    }
    return path.join('/var/log', logFile);
  }
  
  // Default: Winston logs
  return path.join(logsDir, logFile);
}

// API für Log-Daten
router.get('/data', 
  authenticate, 
  adminEndpointLimiter,  // 👑 Rate limiting für Admin-File-Operations
  async (req: AuthenticatedRequest, res) => {
  const hasAdminPerm = await hasPermission(req.user!.id, 'system.logs', { type: 'global', objectId: '*' });
  if (!hasAdminPerm) { return res.status(403).json({ error: 'Keine Berechtigung' }); }
  
  const logFile = req.query.file as string || 'app.log';
  const lines = parseInt(req.query.lines as string) || 100;
  
  try {
    const logPath = resolveLogPath(logFile);
    
    if (!fs.existsSync(logPath)) { 
      return res.json({ 
        logs: [], 
        message: `Log-Datei nicht gefunden: ${logFile}`,
        path: logPath
      }); 
    }
    
    const content = fs.readFileSync(logPath, 'utf8');
    const allLines = content.split('\n').filter(line => line.trim());
    const lastLines = allLines.slice(-lines);
    
    res.json({ 
      logs: lastLines, 
      totalLines: allLines.length, 
      file: logFile, 
      path: logPath,
      category: getLogCategory(logFile),
      lastModified: fs.statSync(logPath).mtime 
    });
  } catch (error: any) {
    res.status(500).json({ 
      error: 'Fehler beim Lesen der Log-Datei', 
      details: error?.message || 'Unknown error',
      file: logFile
    });
  }
});

// API für verfügbare log-Kategorien
router.get('/categories', 
  authenticate, 
  adminEndpointLimiter,  // 👑 Rate limiting für Admin-Metadata
  async (req: AuthenticatedRequest, res) => {
  const hasAdminPerm = await hasPermission(req.user!.id, 'system.logs', { type: 'global', objectId: '*' });
  if (!hasAdminPerm) { return res.status(403).json({ error: 'Keine Berechtigung' }); }
  
  res.json({
    categories: logCategories,
    allFiles: getAllLogFiles(),
    environment: isDevelopment ? 'development' : 'production',
    paths: {
      winston: logsDir,
      services: systemdLogsDir,
      system: '/var/log'
    }
  });
});

// Helper: Log-Kategorie bestimmen
function getLogCategory(logFile: string): string {
  if (logFile in logCategories.winston) return 'winston';
  if (!isDevelopment && logFile in logCategories.services) return 'services';
  if (!isDevelopment && logFile in logCategories.system) return 'system';
  return 'unknown';
}

// Log-Statistiken
router.get('/stats', 
  authenticate, 
  adminEndpointLimiter,  // 👑 Rate limiting für Admin-Statistics
  async (req: AuthenticatedRequest, res) => {
  const hasAdminPerm = await hasPermission(req.user!.id, 'system.logs', { type: 'global', objectId: '*' });
  if (!hasAdminPerm) {
    return res.status(403).json({ error: 'Keine Berechtigung' });
  }

  try {
    const logFiles = ['app.log', 'auth.log', 'security.log', 'api.log', 'error.log'];
    const stats: Record<string, any> = {};
    
    for (const file of logFiles) {
      const logPath = path.join(logsDir, file);
      if (fs.existsSync(logPath)) {
        const stat = fs.statSync(logPath);
        const content = fs.readFileSync(logPath, 'utf8');
        const lines = content.split('\n').filter(line => line.trim()).length;
        
        stats[file] = {
          size: stat.size,
          lines: lines,
          lastModified: stat.mtime,
          readable: true
        };
      } else {
        stats[file] = {
          size: 0,
          lines: 0,
          lastModified: null,
          readable: false
        };
      }
    }
    
    res.json(stats);
  } catch (error: any) {
    res.status(500).json({ 
      error: 'Fehler beim Lesen der Log-Statistiken',
      details: error?.message || 'Unknown error'
    });
  }
});

export default router;