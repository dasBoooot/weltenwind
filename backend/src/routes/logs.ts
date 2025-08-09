import express from 'express';
import fs from 'fs';
import path from 'path';
import { authenticate, AuthenticatedRequest } from '../middleware/authenticate';
import { hasPermission } from '../services/access-control.service';
import { adminEndpointLimiter } from '../middleware/rateLimiter';

const router = express.Router();

// Log-Verzeichnis wie im originalen Logger (spiegelt logger.config.ts)
const isDevelopment = process.env.NODE_ENV !== 'production';
const explicitLogDir = (process.env.LOG_DIR || '').trim();
const logsDir = explicitLogDir
  ? path.resolve(explicitLogDir)
  : (isDevelopment
      // Development: top-level logs directory (project root)
      // Production: systemd-Standard-Verzeichnis
      ? path.resolve(__dirname, '../../../logs')
      : '/var/log/weltenwind');

// Bekannte Unterordner-Struktur der Winston-Logs
const LOG_SUBDIRS = ['system', 'auth', 'api', 'security', 'worlds', 'modules'];

// Systemd Service Log-Pfade (nur in Production)
const systemdLogsDir = '/var/log/weltenwind';

// Aktuelle Log-Kategorien (nur die wirklich verwendeten)
const logCategories = {
  // Winston Application Logs
  application: {
    'app.log': '📋 App (System + Allgemein)',
    'auth.log': '🔐 Auth (Login/Register/Logout)', 
    'api.log': '🌐 API (HTTP Requests)',
    'error.log': '❌ Errors (Nur Fehler)'
  },
  // Service Logs (nur Production)
  services: isDevelopment ? {} : {
    'backend.log': '⚙️ Backend Service (stdout)',
    'backend.error.log': '🔥 Backend Service (stderr)',
    'studio.log': '🎨 Prisma Studio Service',
    'studio.error.log': '💥 Studio Errors'
  },
  // Infrastructure Logs (nur Production/Linux)
  infrastructure: isDevelopment ? {} : {
    'nginx.error.log': '🌐 Nginx Errors',
    'docs.error.log': '📚 Docs Errors'
  }
};

// Alle verfügbaren Log-Dateien sammeln
function getAllLogFiles(): Record<string, string> {
  const allLogs: Record<string, string> = {};
  
  // Application Logs hinzufügen
  Object.entries(logCategories.application).forEach(([file, description]) => {
    allLogs[file] = description;
  });
  
  // Service Logs hinzufügen (nur Production)
  if (!isDevelopment) {
    Object.entries(logCategories.services).forEach(([file, description]) => {
      allLogs[file] = description;
    });
    
    // Infrastructure Logs hinzufügen (nur Production)
    Object.entries(logCategories.infrastructure).forEach(([file, description]) => {
      allLogs[file] = description;
    });
  }
  
  return allLogs;
}

// Effizient die letzten N Zeilen einer Datei lesen
function readLastLines(filePath: string, lines: number): string {
  const stat = fs.statSync(filePath);
  const fileSize = stat.size;
  
  if (fileSize === 0) return '';
  
  // Für kleine Dateien: ganze Datei lesen
  if (fileSize < 64 * 1024) { // 64KB
    const content = fs.readFileSync(filePath, 'utf8');
    const allLines = content.split('\n');
    return allLines.slice(-lines).join('\n');
  }
  
  // Für große Dateien: von hinten lesen
  const buffer = Buffer.alloc(Math.min(fileSize, 1024 * 1024)); // Max 1MB
  const fd = fs.openSync(filePath, 'r');
  
  try {
    const readSize = Math.min(buffer.length, fileSize);
    const startPos = Math.max(0, fileSize - readSize);
    
    fs.readSync(fd, buffer, 0, readSize, startPos);
    const content = buffer.toString('utf8', 0, readSize);
    
    const allLines = content.split('\n');
    const lastLines = allLines.slice(-lines - 1); // +1 für potentiell unvollständige erste Zeile
    
    // Entferne erste Zeile wenn sie unvollständig ist (nicht am Dateianfang)
    if (startPos > 0 && lastLines.length > 0) {
      lastLines.shift();
    }
    
    return lastLines.join('\n');
  } finally {
    fs.closeSync(fd);
  }
}

// Log-Datei-Pfad auflösen
function resolveLogPath(logFile: string): string {
  // Prüfe zuerst ob es eine .log Datei im Winston-Verzeichnis ist
  if (logFile.endsWith('.log')) {
    const winstonPath = path.join(logsDir, logFile);
    if (fs.existsSync(winstonPath)) {
      return winstonPath;
    }

    // In bekannten Unterordnern suchen (neue Struktur)
    for (const sub of LOG_SUBDIRS) {
      const candidate = path.join(logsDir, sub, logFile);
      if (fs.existsSync(candidate)) {
        return candidate;
      }
    }
  }
  
  // Application Logs (statische Kategorien)
  if (logFile in logCategories.application) {
    return path.join(logsDir, logFile);
  }
  
  // Service Logs (nur Production)
  if (!isDevelopment && logFile in logCategories.services) {
    return path.join(systemdLogsDir, logFile);
  }
  
  // Infrastructure Logs (nur Production)
  if (!isDevelopment && logFile in logCategories.infrastructure) {
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
      // Versuche verfügbare Dateien aus Root und Unterordnern zusammenzustellen
      const discovered: string[] = [];
      try {
        if (fs.existsSync(logsDir)) {
          discovered.push(...fs.readdirSync(logsDir).filter(f => f.endsWith('.log')));
          for (const sub of LOG_SUBDIRS) {
            const subDir = path.join(logsDir, sub);
            if (fs.existsSync(subDir)) {
              const subFiles = fs.readdirSync(subDir).filter(f => f.endsWith('.log')).map(f => `${sub}/${f}`);
              discovered.push(...subFiles);
            }
          }
        }
      } catch {}

      return res.json({ 
        logs: [], 
        message: `Log-Datei nicht gefunden: ${logFile}`,
        path: logPath,
        debug: {
          requestedFile: logFile,
          resolvedPath: logPath,
          logsDir: logsDir,
          availableFiles: discovered
        }
      }); 
    }
    
    // Optimiert: Nur die letzten Zeilen lesen statt die ganze Datei
    const content = readLastLines(logPath, lines);
    const allLines = content.split('\n').filter(line => line.trim());
    const lastLines = allLines;
    
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

// GET /api/logs/info - Log-Verzeichnis und Konfiguration anzeigen
router.get('/info', 
  authenticate, 
  adminEndpointLimiter,
  async (req: AuthenticatedRequest, res) => {
    try {
      const hasAdminPerm = await hasPermission(req.user!.id, 'system.logs', { type: 'global', objectId: '*' });
      if (!hasAdminPerm) {
        return res.status(403).json({ error: 'Admin-Berechtigung erforderlich' });
      }

      const logInfo = {
        logDirectory: logsDir,
        systemdDirectory: systemdLogsDir,
        environment: process.env.NODE_ENV,
        isDevelopment,
        logLevel: process.env.LOG_LEVEL || 'info',
        logToFile: process.env.LOG_TO_FILE !== 'false',
        logToConsole: process.env.LOG_TO_CONSOLE !== 'false',
        availableFiles: [] as string[]
      };

    // Prüfe welche Log-Dateien tatsächlich existieren (Root + Unterordner)
    try {
      const found: string[] = [];
      if (fs.existsSync(logsDir)) {
        found.push(...fs.readdirSync(logsDir).filter(file => file.endsWith('.log')));
        for (const sub of LOG_SUBDIRS) {
          const subDir = path.join(logsDir, sub);
          if (fs.existsSync(subDir)) {
            const subFiles = fs.readdirSync(subDir).filter(f => f.endsWith('.log')).map(f => `${sub}/${f}`);
            found.push(...subFiles);
          }
        }
      }
      logInfo.availableFiles = found;
    } catch (error) {
      logInfo.availableFiles = [`Error reading directory: ${error instanceof Error ? error.message : String(error)}`];
    }

      res.json(logInfo);
    } catch (error) {
      res.status(500).json({ error: 'Fehler beim Abrufen der Log-Informationen' });
    }
  }
);

// API für verfügbare log-Kategorien
router.get('/categories', 
  authenticate, 
  adminEndpointLimiter,  // 👑 Rate limiting für Admin-Metadata
  async (req: AuthenticatedRequest, res) => {
  const hasAdminPerm = await hasPermission(req.user!.id, 'system.logs', { type: 'global', objectId: '*' });
  if (!hasAdminPerm) { return res.status(403).json({ error: 'Keine Berechtigung' }); }
  
  // Dynamische Kategorien basierend auf verfügbaren Dateien
  const dynamicCategories: any = { ...logCategories };
  
  try {
    const availableRootFiles = fs.existsSync(logsDir)
      ? fs.readdirSync(logsDir).filter(file => file.endsWith('.log'))
      : [];
    
    // Unterordner durchsuchen und Dateinamen als "sub/file.log" aufnehmen
    const availableSubFiles: string[] = [];
    for (const sub of LOG_SUBDIRS) {
      const subDir = path.join(logsDir, sub);
      if (fs.existsSync(subDir)) {
        const files = fs.readdirSync(subDir).filter(f => f.endsWith('.log'));
        files.forEach(f => availableSubFiles.push(`${sub}/${f}`));
      }
    }

    const allAvailable = new Set<string>([...availableRootFiles, ...availableSubFiles]);

    // Aktualisiere application-Kategorie nur mit verfügbaren Dateien
    const availableApplicationFiles: Record<string, string> = {};
    Object.entries(logCategories.application).forEach(([file, description]) => {
      if (allAvailable.has(file)) {
        availableApplicationFiles[file] = description;
      }
    });
    
    // Füge zusätzliche gefundene .log Dateien zur application-Kategorie hinzu (Root + Subdirs)
    allAvailable.forEach(file => {
      if (!availableApplicationFiles[file] && 
          !Object.keys(logCategories.services).includes(file) &&
          !Object.keys(logCategories.infrastructure).includes(file)) {
        availableApplicationFiles[file] = `📄 ${file} (Automatisch erkannt)`;
      }
    });
    
    dynamicCategories.application = availableApplicationFiles;
    
    // Aktualisiere services-Kategorie nur mit verfügbaren Dateien (nur Production)
    if (!isDevelopment) {
      const availableServiceFiles: Record<string, string> = {};
      Object.entries(logCategories.services).forEach(([file, description]) => {
        if (allAvailable.has(file)) {
          availableServiceFiles[file] = description;
        }
      });
      dynamicCategories.services = availableServiceFiles;
      
      // Aktualisiere infrastructure-Kategorie nur mit verfügbaren Dateien  
      const availableInfraFiles: Record<string, string> = {};
      Object.entries(logCategories.infrastructure).forEach(([file, description]) => {
        if (allAvailable.has(file)) {
          availableInfraFiles[file] = description;
        }
      });
      dynamicCategories.infrastructure = availableInfraFiles;
    }
  } catch (error) {
    // Fallback zu statischen Kategorien bei Fehler
  }
  
  res.json({
    categories: dynamicCategories,
    allFiles: getAllLogFiles(),
    environment: isDevelopment ? 'development' : 'production',
    paths: {
      application: logsDir,
      services: systemdLogsDir,
      infrastructure: '/var/log'
    }
  });
});

// Helper: Log-Kategorie bestimmen
function getLogCategory(logFile: string): string {
  if (logFile in logCategories.application) return 'application';
  if (!isDevelopment && logFile in logCategories.services) return 'services';
  if (!isDevelopment && logFile in logCategories.infrastructure) return 'infrastructure';
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
    const logFiles = ['app.log', 'auth.log', 'error.log', 'backend.log', 'backend.error.log'];
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