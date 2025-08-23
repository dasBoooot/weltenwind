import express from 'express';
import { authenticate, AuthenticatedRequest } from '../middleware/authenticate';
import { hasPermission } from '../services/access-control.service';
import { loggers } from '../config/logger.config';
import { csrfProtection } from '../middleware/csrf-protection';
import { adminEndpointLimiter } from '../middleware/rateLimiter';
import fs from 'fs';
import path from 'path';

const router = express.Router();
const arbLogger = loggers.system;

// Security-Middleware für alle ARB API-Routen
router.use((req, res, next) => {
  // XSS-Protection Headers für API-Responses
  res.setHeader('X-Content-Type-Options', 'nosniff');
  res.setHeader('X-Frame-Options', 'DENY');
  res.setHeader('X-XSS-Protection', '1; mode=block');
  res.setHeader('Referrer-Policy', 'strict-origin-when-cross-origin');
  
  // Cache-Control für sensible ARB-API-Daten
  res.setHeader('Cache-Control', 'no-store, no-cache, must-revalidate, private');
  res.setHeader('Pragma', 'no-cache');
  
  next();
});

// ARB-Dateien Pfad
const ARB_PATH = path.join(__dirname, '../../../client/lib/l10n');

// Sprachen dynamisch aus dem Dateisystem ermitteln (app_*.arb)
function listSupportedLanguages(): string[] {
  try {
    if (!fs.existsSync(ARB_PATH)) return [];
    return fs
      .readdirSync(ARB_PATH)
      .filter(name => name.startsWith('app_') && name.endsWith('.arb'))
      .map(name => name.replace(/^app_/, '').replace(/\.arb$/, ''))
      .filter((code, idx, arr) => code && arr.indexOf(code) === idx)
      .sort();
  } catch {
    return [];
  }
}

// Hilfsfunktion zur Sprachcode-Validierung
function validateLanguageCode(language: string): boolean {
  return listSupportedLanguages().includes(language);
}

/**
 * GET /api/arb/languages
 * Gibt verfügbare Sprachen zurück
 */
router.get('/languages', authenticate, async (req: AuthenticatedRequest, res) => {
  try {
    // Prüfe Berechtigung für ARB-Anzeige
    const canViewArb = await hasPermission(req.user!.id, 'system.arb', { type: 'global', objectId: 'global' });
    
    if (!canViewArb) {
      return res.status(403).json({ 
        error: 'Keine Berechtigung für ARB-Anzeige' 
      });
    }

    // Suche nach existierenden ARB-Dateien
    const languages: any[] = [];
    const detected = listSupportedLanguages();
    for (const lang of detected) {
      const arbFile = path.join(ARB_PATH, `app_${lang}.arb`);
      const stats = fs.statSync(arbFile);
      const content = JSON.parse(fs.readFileSync(arbFile, 'utf8'));
      const keyCount = Object.keys(content).filter(key => !key.startsWith('@')).length;
      languages.push({
        code: lang,
        name: lang === 'de' ? 'Deutsch' : (lang === 'en' ? 'English' : lang.toUpperCase()),
        keyCount,
        lastModified: stats.mtime,
        isMaster: lang === 'de'
      });
    }

    arbLogger.info('ARB languages retrieved', { 
      userId: req.user!.id, 
      languageCount: languages.length 
    });

    res.json({ languages });

  } catch (error) {
    arbLogger.error('Error retrieving ARB languages', { 
      error: error instanceof Error ? error.message : 'Unknown error',
      userId: req.user?.id 
    });
    res.status(500).json({ error: 'Fehler beim Laden der Sprachen' });
  }
});

/**
 * GET /api/arb/compare
 * Multi-Language Vergleichsansicht - lädt alle Sprachen und macht Diff-Analyse
 */
router.get('/compare', authenticate, async (req: AuthenticatedRequest, res) => {
  try {
    // Prüfe Berechtigung für ARB-Vergleichsansicht
    const canCompareArb = await hasPermission(req.user!.id, 'system.arb', { type: 'global', objectId: 'global' });
    
    if (!canCompareArb) {
      return res.status(403).json({ 
        error: 'Keine Berechtigung für ARB-Vergleichsansicht' 
      });
    }

    // Lade alle verfügbaren Sprachen
    const compareData: any = {
      languages: [],
      masterLanguage: 'de',
      totalKeys: 0,
      comparisonMatrix: {},
      missingKeysReport: {},
      statistics: {}
    };

    const languageData: { [key: string]: any } = {};

    // Lade alle ARB-Dateien
    const allLangs = listSupportedLanguages();
    for (const lang of allLangs) {
      const arbFile = path.join(ARB_PATH, `app_${lang}.arb`);
      
      if (fs.existsSync(arbFile)) {
        const stats = fs.statSync(arbFile);
        const content = JSON.parse(fs.readFileSync(arbFile, 'utf8'));
        
        // Separiere Keys und Metadaten
        const entries: any[] = [];
        const keys = Object.keys(content).filter(key => !key.startsWith('@'));
        
        for (const key of keys) {
          const metaKey = `@${key}`;
          entries.push({
            key,
            value: content[key],
            metadata: content[metaKey] || null
          });
        }

        languageData[lang] = {
          code: lang,
          name: lang === 'de' ? 'Deutsch' : 'English',
          entries,
          keyCount: entries.length,
          lastModified: stats.mtime,
          isMaster: lang === 'de',
          keys: keys
        };

        compareData.languages.push({
          code: lang,
          name: languageData[lang].name,
          keyCount: entries.length,
          lastModified: stats.mtime,
          isMaster: lang === 'de'
        });
      }
    }

    // Bestimme Master-Language Keys (Deutsch)
    const masterLang = 'de';
    const masterKeys = languageData[masterLang]?.keys || [];
    compareData.totalKeys = masterKeys.length;

    // Erstelle Comparison Matrix und Missing Keys Report
    for (const lang of Object.keys(languageData)) {
      if (!languageData[lang]) continue;

      const langKeys = languageData[lang].keys;
      const missingInLang = masterKeys.filter((key: string) => !langKeys.includes(key));
      const extraInLang = langKeys.filter((key: string) => !masterKeys.includes(key));

      // Vergleichsmatrix: welche Keys sind in welcher Sprache vorhanden
      compareData.comparisonMatrix[lang] = {};
      for (const key of masterKeys) {
        compareData.comparisonMatrix[lang][key] = {
          present: langKeys.includes(key),
          value: languageData[lang].entries.find((e: any) => e.key === key)?.value || null
        };
      }

      // Missing Keys Report
      compareData.missingKeysReport[lang] = {
        missing: missingInLang,
        extra: extraInLang,
        missingCount: missingInLang.length,
        extraCount: extraInLang.length,
        completeness: ((langKeys.length - extraInLang.length) / masterKeys.length * 100).toFixed(1)
      };
    }

    // Statistiken
    compareData.statistics = {
      totalLanguages: compareData.languages.length,
      masterKeyCount: masterKeys.length,
      averageCompleteness: Object.values(compareData.missingKeysReport)
        .map((report: any) => parseFloat(report.completeness))
        .reduce((sum, val) => sum + val, 0) / compareData.languages.length,
      languagesWithMissingKeys: Object.values(compareData.missingKeysReport)
        .filter((report: any) => report.missingCount > 0).length
    };

    // Füge vollständige Entry-Daten hinzu
    compareData.entries = languageData;

    arbLogger.info('Multi-language comparison generated', { 
      userId: req.user!.id, 
      languageCount: compareData.languages.length,
      totalKeys: compareData.totalKeys,
      averageCompleteness: compareData.statistics.averageCompleteness.toFixed(1) + '%'
    });

    res.json(compareData);

  } catch (error) {
    arbLogger.error('Error generating multi-language comparison', { 
      error: error instanceof Error ? error.message : 'Unknown error',
      userId: req.user?.id 
    });
    res.status(500).json({ error: 'Fehler beim Erstellen der Sprachvergleichsansicht' });
  }
});

/**
 * GET /api/arb/:language
 * Lädt eine ARB-Datei
 */
router.get('/:language', authenticate, async (req: AuthenticatedRequest, res) => {
  try {
    const { language } = req.params;
    
    // Validiere Sprache
    if (!validateLanguageCode(language)) {
      return res.status(400).json({ error: 'Ungültige Sprache' });
    }

    // Prüfe Berechtigung für ARB-Anzeige
    const canViewArb = await hasPermission(req.user!.id, 'system.arb', { type: 'global', objectId: 'global' });
    
    if (!canViewArb) {
      return res.status(403).json({ 
        error: 'Keine Berechtigung für ARB-Anzeige' 
      });
    }

    const arbFile = path.join(ARB_PATH, `app_${language}.arb`);
    
    if (!fs.existsSync(arbFile)) {
      return res.status(404).json({ error: 'ARB-Datei nicht gefunden' });
    }

    const content = JSON.parse(fs.readFileSync(arbFile, 'utf8'));
    
    // Separiere Keys und Metadaten
    const entries = [];
    const keys = Object.keys(content).filter(key => !key.startsWith('@'));
    
    for (const key of keys) {
      const metaKey = `@${key}`;
      entries.push({
        key,
        value: content[key],
        metadata: content[metaKey] || null
      });
    }

    arbLogger.info('ARB file loaded', { 
      userId: req.user!.id, 
      language, 
      entryCount: entries.length 
    });

    res.json({
      language,
      entries,
      metadata: {
        keyCount: entries.length,
        isMaster: language === 'de'
      }
    });

  } catch (error) {
    arbLogger.error('Error loading ARB file', { 
      error: error instanceof Error ? error.message : 'Unknown error',
      userId: req.user?.id,
      language: req.params.language 
    });
    res.status(500).json({ error: 'Fehler beim Laden der ARB-Datei' });
  }
});

/**
 * PUT /api/arb/:language
 * Aktualisiert eine ARB-Datei (alle unterstützten Sprachen)
 */
router.put('/:language', 
  authenticate, 
  csrfProtection,  // 🔐 CSRF-Schutz für Language-Updates
  adminEndpointLimiter,  // 👑 Rate limiting für Admin-Operationen
  async (req: AuthenticatedRequest, res) => {
  try {
    const { language } = req.params;
    const { entries } = req.body;

    // Prüfe ob Sprache unterstützt wird
    if (!validateLanguageCode(language)) {
      return res.status(400).json({ 
        error: `Sprache '${language}' wird nicht unterstützt.`,
        supportedLanguages: listSupportedLanguages()
      });
    }

    // Prüfe Berechtigung für ARB-Speicherung
    const canSaveArb = await hasPermission(req.user!.id, 'system.arb', { type: 'global', objectId: 'global' });
    
    if (!canSaveArb) {
      return res.status(403).json({ 
        error: 'Keine Berechtigung für ARB-Speicherung' 
      });
    }

    // Validiere Eingabe
    if (!Array.isArray(entries)) {
      return res.status(400).json({ error: 'Ungültiges Eingabeformat' });
    }

    // Security: Input-Sanitization und -Validierung
    const sanitizeInput = (text: string): string => {
      if (typeof text !== 'string') return '';
      
      return text
        // HTML-Tags escapen
        .replace(/</g, '&lt;')
        .replace(/>/g, '&gt;')
        // JavaScript-Events entfernen (erweitert)
        .replace(/on\w+\s*=/gi, '')
        .replace(/on\w+\s*\(/gi, 'blocked(')
        // Script-Tags komplett entfernen
        .replace(/<script\b[^<]*(?:(?!<\/script>)<[^<]*)*<\/script>/gi, '')
        // JavaScript-URLs entfernen
        .replace(/javascript:/gi, 'blocked:')
        .replace(/vbscript:/gi, 'blocked:')
        // Data-URLs mit JavaScript entfernen
        .replace(/data:\s*text\/html/gi, 'blocked:text/html')
        .replace(/data:\s*application\/javascript/gi, 'blocked:javascript')
        // Expression() und eval() blockieren
        .replace(/expression\s*\(/gi, 'blocked(')
        .replace(/eval\s*\(/gi, 'blocked(')
        .trim();
    };

    const detectXSSPatterns = (text: string): string[] => {
      if (typeof text !== 'string') return [];
      
      const xssPatterns = [
        // Script-Tags und Events
        /<script\b/gi,
        /on\w+\s*=/gi,
        /javascript:/gi,
        /vbscript:/gi,
        // Gefährliche Functions
        /eval\s*\(/gi,
        /expression\s*\(/gi,
        /setTimeout\s*\(/gi,
        /setInterval\s*\(/gi,
        // Data-URLs
        /data:\s*text\/html/gi,
        /data:\s*application\/javascript/gi,
        // Meta-Tags
        /<meta\b[^>]*http-equiv/gi,
        // Iframe/Object/Embed
        /<iframe\b/gi,
        /<object\b/gi,
        /<embed\b/gi,
        // Form-Actions
        /<form\b[^>]*action/gi
      ];
      
      const detectedPatterns: string[] = [];
      for (const pattern of xssPatterns) {
        if (pattern.test(text)) {
          detectedPatterns.push(pattern.toString());
        }
      }
      
      return detectedPatterns;
    };

    const validateARBEntry = (key: string, value: string): string[] => {
      const errors: string[] = [];
      
      // Key-Validation
      if (!key || typeof key !== 'string') {
        errors.push('Key ist erforderlich');
      } else if (key.length > 100) {
        errors.push('Key zu lang (max. 100 Zeichen)');
      } else if (!/^[a-zA-Z][a-zA-Z0-9_]*$/.test(key)) {
        errors.push('Key darf nur Buchstaben, Zahlen und _ enthalten');
      }
      
      // Value-Validation
      if (typeof value !== 'string') {
        errors.push('Value muss ein String sein');
      } else if (value.length > 1000) {
        errors.push('Value zu lang (max. 1000 Zeichen)');
      }
      
      // XSS-Pattern Detection
      const xssPatterns = detectXSSPatterns(value);
      if (xssPatterns.length > 0) {
        errors.push(`Gefährliche Patterns erkannt: ${xssPatterns.length} XSS-Risiken`);
      }
      
      // Zusätzliche Content-Validierung
      if (value.includes('\0')) {
        errors.push('Null-Bytes nicht erlaubt');
      }
      
      // Übermäßige Sonderzeichen prüfen
      const specialCharMatches = value.match(/[<>'"&;(){}[\]]/g);
      const specialCharCount = specialCharMatches ? specialCharMatches.length : 0;
      if (specialCharCount > value.length * 0.3) {
        errors.push('Zu viele Sonderzeichen (verdächtig)');
      }
      
      return errors;
    };

    // Erstelle neue ARB-Struktur mit Sanitization und Header
    const newContent: any = {
      "@@locale": language,
      "@@context": "weltenwind-game"
    };
    const validationErrors: string[] = [];
    
    for (const entry of entries) {
      if (!entry.key || typeof entry.value !== 'string') {
        return res.status(400).json({ 
          error: `Ungültiger Eintrag: ${entry.key || 'unbekannt'}` 
        });
      }

      // Sanitize und validiere
      const sanitizedValue = sanitizeInput(entry.value);
      const errors = validateARBEntry(entry.key, sanitizedValue);
      
      if (errors.length > 0) {
        validationErrors.push(`${entry.key}: ${errors.join(', ')}`);
        continue;
      }

      newContent[entry.key] = sanitizedValue;
      
      if (entry.metadata) {
        newContent[`@${entry.key}`] = entry.metadata;
      }
    }

    // Prüfe auf Validierungsfehler
    if (validationErrors.length > 0) {
      arbLogger.warn('ARB validation errors', { 
        userId: req.user!.id, 
        errors: validationErrors 
      });
      return res.status(400).json({ 
        error: 'Validierungsfehler', 
        details: validationErrors 
      });
    }

    // Backup der alten Datei mit Zeitstempel und Versionierung
    const arbFile = path.join(ARB_PATH, `app_${language}.arb`);
    const backupsDir = path.join(ARB_PATH, 'backups');
    
    // Erstelle backups Verzeichnis falls nicht vorhanden
    if (!fs.existsSync(backupsDir)) {
      fs.mkdirSync(backupsDir);
    }
    
    // Erstelle Backup mit Zeitstempel bei jeder Speicherung
    if (fs.existsSync(arbFile)) {
      const now = new Date();
      const date = now.toISOString().split('T')[0]; // YYYY-MM-DD
      const time = now.toTimeString().split(' ')[0].replace(/:/g, ''); // HHMMSS
      const timestamp = `${date}_${time}`;
      const backupFile = path.join(backupsDir, `app_${language}.arb.backup_${timestamp}`);
      
      fs.copyFileSync(arbFile, backupFile);
      
      // Cleanup: Nur die letzten 10 Backups behalten
      const backupPattern = new RegExp(`^app_${language}\\.arb\\.backup_\\d{4}-\\d{2}-\\d{2}_(\\d{2}|\\d{6})$`);
      const existingBackups = fs.readdirSync(backupsDir)
        .filter(file => backupPattern.test(file))
        .map(file => ({
          name: file,
          path: path.join(backupsDir, file),
          timestamp: fs.statSync(path.join(backupsDir, file)).mtime
        }))
        .sort((a, b) => b.timestamp.getTime() - a.timestamp.getTime()); // Neueste zuerst
      
      // Lösche Backups über das Limit hinaus
      if (existingBackups.length > 10) {
        const toDelete = existingBackups.slice(10);
        for (const backup of toDelete) {
          fs.unlinkSync(backup.path);
          arbLogger.info('Old backup deleted', { 
        userId: req.user!.id, 
        language, 
            deletedFile: backup.name 
          });
        }
      }
      
      // Speichere Backup-Metadaten als separate JSON-Datei
      const metadataFile = path.join(backupsDir, `app_${language}.arb.backup_${timestamp}.meta.json`);
      const backupMetadata = {
        language,
        timestamp,
        createdBy: req.user!.username,
        createdById: req.user!.id,
        createdAt: new Date().toISOString(),
        originalSize: fs.existsSync(arbFile) ? fs.statSync(arbFile).size : 0,
        type: 'manual_save'
      };
      fs.writeFileSync(metadataFile, JSON.stringify(backupMetadata, null, 2), 'utf8');

      arbLogger.info('ARB backup created', { 
        userId: req.user!.id, 
        username: req.user!.username,
        language, 
        backupFile,
        metadataFile,
        timestamp,
        totalBackups: Math.min(existingBackups.length + 1, 10)
      });
    }

    // Schreibe neue ARB-Datei
    fs.writeFileSync(arbFile, JSON.stringify(newContent, null, 2), 'utf8');

    arbLogger.info('ARB file updated', { 
      userId: req.user!.id, 
      language, 
      entryCount: entries.length,
      backupCreated: true
    });

    res.json({
      success: true,
      message: `${language.toUpperCase()}-ARB erfolgreich aktualisiert`,
      entryCount: entries.length,
      nextStep: 'Ein Backup wurde automatisch erstellt. Lade die Seite neu um die Änderungen zu sehen.'
    });

  } catch (error) {
    arbLogger.error('Error updating ARB file', { 
      error: error instanceof Error ? error.message : 'Unknown error',
      userId: req.user?.id,
      language: req.params.language 
    });
    res.status(500).json({ error: 'Fehler beim Aktualisieren der ARB-Datei' });
  }
});

/**
 * GET /api/arb/:language/export
 * Exportiert ARB-Datei als Download
 */
router.get('/:language/export', authenticate, async (req: AuthenticatedRequest, res) => {
  try {
    const { language } = req.params;
    const { format = 'arb' } = req.query;
    
    // Validiere Sprache
    if (!validateLanguageCode(language)) {
      return res.status(400).json({ error: 'Ungültige Sprache' });
    }

    // Prüfe Berechtigung für ARB-Export
    const canExportArb = await hasPermission(req.user!.id, 'system.arb', { type: 'global', objectId: 'global' });
    
    if (!canExportArb) {
      return res.status(403).json({ 
        error: 'Keine Berechtigung für ARB-Export' 
      });
    }

    const arbFile = path.join(ARB_PATH, `app_${language}.arb`);
    
    if (!fs.existsSync(arbFile)) {
      return res.status(404).json({ error: 'ARB-Datei nicht gefunden' });
    }

    const content = JSON.parse(fs.readFileSync(arbFile, 'utf8'));
    
    let exportData: string;
    let filename: string;
    let contentType: string;
    
    if (format === 'json') {
      // Strukturiertes JSON-Export
      const entries = [];
      const keys = Object.keys(content).filter(key => !key.startsWith('@'));
      
      for (const key of keys) {
        const metaKey = `@${key}`;
        entries.push({
          key,
          value: content[key],
          metadata: content[metaKey] || null
        });
      }
      
      const jsonContent = {
        metadata: {
          language,
          exportDate: new Date().toISOString(),
          keyCount: entries.length,
          exportedBy: 'Weltenwind ARB Manager',
          exportedByUser: req.user!.username
        },
        entries
      };
      
      exportData = JSON.stringify(jsonContent, null, 2);
      filename = `weltenwind_arb_${language}_${new Date().toISOString().slice(0, 10)}.json`;
      contentType = 'application/json';
      
    } else {
      // Standard ARB-Format
      exportData = JSON.stringify(content, null, 2);
      filename = `app_${language}_export_${new Date().toISOString().slice(0, 10)}.arb`;
      contentType = 'application/json';
    }

    // Set download headers
    res.setHeader('Content-Type', contentType);
    res.setHeader('Content-Disposition', `attachment; filename="${filename}"`);
    res.setHeader('Content-Length', Buffer.byteLength(exportData, 'utf8'));

    arbLogger.info('ARB file exported', { 
      userId: req.user!.id, 
      language, 
      format,
      filename,
      size: Buffer.byteLength(exportData, 'utf8')
    });

    res.send(exportData);

  } catch (error) {
    arbLogger.error('Error exporting ARB file', { 
      error: error instanceof Error ? error.message : 'Unknown error',
      userId: req.user?.id,
      language: req.params.language 
    });

    res.status(500).json({ error: 'Fehler beim Exportieren der ARB-Datei' });
  }
});

// === BACKUP MANAGEMENT ===

// Liste aller Backups für eine Sprache
router.get('/:language/backups', authenticate, async (req: AuthenticatedRequest, res) => {
  try {
    const { language } = req.params;
    
    if (!validateLanguageCode(language)) {
      return res.status(400).json({ error: 'Ungültiger Sprachcode' });
    }

    // Prüfe Berechtigung für Backup-Anzeige
    const canViewBackups = await hasPermission(req.user!.id, 'system.arb', { type: 'global', objectId: 'global' });
    
    if (!canViewBackups) {
      return res.status(403).json({ 
        error: 'Keine Berechtigung für Backup-Anzeige' 
      });
    }

    const backupsDir = path.join(ARB_PATH, 'backups');
    
    if (!fs.existsSync(backupsDir)) {
      return res.json({ backups: [] });
    }

    const backupPattern = new RegExp(`^app_${language}\\.arb\\.backup_(\\d{4}-\\d{2}-\\d{2}_(\\d{2}|\\d{6}))$`);
    const backups = fs.readdirSync(backupsDir)
      .filter(file => backupPattern.test(file))
      .map(file => {
        const match = file.match(backupPattern);
        const timestamp = match ? match[1] : '';
        const filePath = path.join(backupsDir, file);
        const stats = fs.statSync(filePath);
        
        // Intelligente Zeitformatierung für verschiedene Backup-Formate
        const formatDisplayName = (ts: string): string => {
          const [date, time] = ts.split('_');
          const formattedDate = date.replace(/-/g, '.');
          
          if (time.length === 2) {
            // Altes Format: nur Stunden (z.B. "11")
            return `${formattedDate} um ${time}:00`;
          } else if (time.length === 6) {
            // Neues Format: HHMMSS (z.B. "143022")
            const hours = time.substring(0, 2);
            const minutes = time.substring(2, 4);
            const seconds = time.substring(4, 6);
            return `${formattedDate} um ${hours}:${minutes}:${seconds}`;
          } else {
            // Fallback
            return `${formattedDate} um ${time}`;
          }
        };

        // Versuche Metadaten zu laden
        const metadataFile = path.join(backupsDir, `${file}.meta.json`);
        let metadata = null;
        let createdBy = 'Unknown';
        let backupType = 'manual_save';
        
        if (fs.existsSync(metadataFile)) {
          try {
            const metaContent = fs.readFileSync(metadataFile, 'utf8');
            metadata = JSON.parse(metaContent);
            createdBy = metadata.createdBy || 'Unknown';
            backupType = metadata.type || 'manual_save';
          } catch (e) {
            // Ignore metadata parsing errors
          }
        }
        
        return {
          filename: file,
          timestamp,
          created: stats.mtime,
          size: stats.size,
          displayName: formatDisplayName(timestamp),
          createdBy,
          type: backupType,
          metadata
        };
      })
      .sort((a, b) => b.created.getTime() - a.created.getTime()); // Neueste zuerst

    arbLogger.info('Backups listed', { 
      userId: req.user!.id, 
      language: req.params.language, 
      backupCount: backups.length 
    });

    res.json({ 
      success: true, 
      language: req.params.language,
      backups 
    });

  } catch (error) {
    arbLogger.error('Error listing backups', { 
      userId: req.user!.id, 
      error: error instanceof Error ? error.message : 'Unknown error' 
    });
    res.status(500).json({ 
      error: 'Fehler beim Laden der Backup-Liste' 
    });
  }
});

// Backup wiederherstellen
router.post('/:language/restore/:timestamp', 
  authenticate, 
  csrfProtection,  // 🔐 CSRF-Schutz für Language-Restore
  adminEndpointLimiter,  // 👑 Rate limiting für Admin-Operationen
  async (req: AuthenticatedRequest, res) => {
  try {
    const { language, timestamp } = req.params;
    
    if (!validateLanguageCode(language)) {
      return res.status(400).json({ error: 'Ungültiger Sprachcode' });
    }

    // Prüfe Berechtigung für Backup-Wiederherstellung
    const canRestoreBackup = await hasPermission(req.user!.id, 'system.arb', { type: 'global', objectId: 'global' });
    
    if (!canRestoreBackup) {
      return res.status(403).json({ 
        error: 'Keine Berechtigung für Backup-Wiederherstellung' 
      });
    }

    const backupsDir = path.join(ARB_PATH, 'backups');
    const backupFile = path.join(backupsDir, `app_${language}.arb.backup_${timestamp}`);
    const currentFile = path.join(ARB_PATH, `app_${language}.arb`);

    if (!fs.existsSync(backupFile)) {
      return res.status(404).json({ 
        error: 'Backup-Datei nicht gefunden' 
      });
    }

    // Erstelle Backup der aktuellen Datei bevor wir wiederherstellen
    if (fs.existsSync(currentFile)) {
      const restoreNow = new Date();
      const restoreDate = restoreNow.toISOString().split('T')[0]; // YYYY-MM-DD
      const restoreTime = restoreNow.toTimeString().split(' ')[0].replace(/:/g, ''); // HHMMSS
      const restoreTimestamp = `${restoreDate}_${restoreTime}`;
      const preRestoreBackup = path.join(backupsDir, `app_${language}.arb.backup_${restoreTimestamp}`);
      fs.copyFileSync(currentFile, preRestoreBackup);

      // Metadaten für Pre-Restore Backup
      const preRestoreMetaFile = path.join(backupsDir, `app_${language}.arb.backup_${restoreTimestamp}.meta.json`);
      const preRestoreMetadata = {
        language,
        timestamp: restoreTimestamp,
        createdBy: req.user!.username,
        createdById: req.user!.id,
        createdAt: new Date().toISOString(),
        originalSize: fs.statSync(currentFile).size,
        type: 'pre_restore',
        restoredFrom: timestamp
      };
      fs.writeFileSync(preRestoreMetaFile, JSON.stringify(preRestoreMetadata, null, 2), 'utf8');
    }

    // Stelle Backup wieder her
    fs.copyFileSync(backupFile, currentFile);

    arbLogger.info('Backup restored', { 
      userId: req.user!.id, 
      language: req.params.language, 
      restoredFrom: req.params.timestamp,
      backupFile: backupFile 
    });

    res.json({
      success: true,
      message: `${req.params.language.toUpperCase()}-ARB erfolgreich aus Backup wiederhergestellt`,
      restoredFrom: req.params.timestamp,
      nextStep: 'Lade die Seite neu um die wiederhergestellten Daten zu sehen'
    });

  } catch (error) {
    arbLogger.error('Error restoring backup', { 
      userId: req.user!.id, 
      language: req.params.language, 
      timestamp: req.params.timestamp, 
      error: error instanceof Error ? error.message : 'Unknown error' 
    });
    res.status(500).json({ 
      error: 'Fehler beim Wiederherstellen des Backups' 
    });
  }
});

/**
 * DELETE /api/arb/:language/backups/:timestamp
 * Löscht ein spezifisches Backup
 */
router.delete('/:language/backups/:timestamp', 
  authenticate, 
  csrfProtection,  // 🔐 CSRF-Schutz für Backup-Deletion
  adminEndpointLimiter,  // 👑 Rate limiting für Admin-Operationen
  async (req: AuthenticatedRequest, res) => {
  try {
    const { language, timestamp } = req.params;
    
    if (!validateLanguageCode(language)) {
      return res.status(400).json({ 
        error: `Sprache '${language}' wird nicht unterstützt. Unterstützte Sprachen: ${listSupportedLanguages().join(', ')}` 
      });
    }

    // Prüfe Berechtigung für Backup-Löschung
    const canDeleteBackup = await hasPermission(req.user!.id, 'system.arb', { type: 'global', objectId: 'global' });
    
    if (!canDeleteBackup) {
      return res.status(403).json({ 
        error: 'Keine Berechtigung für Backup-Löschung' 
      });
    }

    const backupsDir = path.join(ARB_PATH, 'backups');
    const backupFile = path.join(backupsDir, `app_${language}.arb.backup_${timestamp}`);
    const metadataFile = path.join(backupsDir, `app_${language}.arb.backup_${timestamp}.meta.json`);

    // Prüfe ob Backup existiert
    if (!fs.existsSync(backupFile)) {
      return res.status(404).json({ 
        error: 'Backup-Datei nicht gefunden' 
      });
    }

    // Lösche Backup und Metadaten
    fs.unlinkSync(backupFile);
    if (fs.existsSync(metadataFile)) {
      fs.unlinkSync(metadataFile);
    }

    arbLogger.info('Backup deleted', { 
      userId: req.user!.id, 
      username: req.user!.username,
      language: req.params.language,
      timestamp: req.params.timestamp,
      backupFile,
      metadataFile
    });

    res.json({
      success: true,
      message: `Backup vom ${timestamp.replace('_', ' um ').replace(/-/g, '.')} wurde gelöscht`,
      deletedFile: `app_${language}.arb.backup_${timestamp}`
    });

  } catch (error) {
    arbLogger.error('Error deleting backup', { 
      userId: req.user!.id, 
      language: req.params.language,
      timestamp: req.params.timestamp,
      error: error instanceof Error ? error.message : 'Unknown error' 
    });
    res.status(500).json({ error: 'Fehler beim Löschen des Backups' });
  }
});

// === ARB AUDIT TRAIL ===

/**
 * GET /api/arb/:language/audit
 * Vollständiger Audit-Trail für eine ARB-Sprache (Backups + Änderungshistorie)
 */
router.get('/:language/audit', authenticate, async (req: AuthenticatedRequest, res) => {
  try {
    const { language } = req.params;
    
    // Validiere Sprachcode
    if (!validateLanguageCode(language)) {
      return res.status(400).json({ 
        error: 'Ungültiger Sprachcode',
        supportedLanguages: listSupportedLanguages()
      });
    }

    // Prüfe Berechtigung für ARB-Audit-Anzeige
    const canViewAudit = await hasPermission(req.user!.id, 'arb.backup.view', { type: 'global', objectId: 'global' });
    
    if (!canViewAudit) {
      return res.status(403).json({ 
        error: 'Keine Berechtigung für ARB-Audit-Anzeige' 
      });
    }

    const backupsDir = path.join(ARB_PATH, 'backups');
    const auditTrail: any[] = [];
    let totalKeyChanges = 0;
    
    if (fs.existsSync(backupsDir)) {
      // Lade alle Backup-Metadaten für die Sprache
      const backupMetaPattern = new RegExp(`^app_${language}\\.arb\\.backup_\\d{4}-\\d{2}-\\d{2}_(\\d{2}|\\d{6})\\.meta\\.json$`);
      
      const metaFiles = fs.readdirSync(backupsDir)
        .filter(file => backupMetaPattern.test(file));
      
      for (const metaFile of metaFiles) {
        try {
          const metaPath = path.join(backupsDir, metaFile);
          const metadata = JSON.parse(fs.readFileSync(metaPath, 'utf8'));
          
          // Zähle Key-Änderungen
          if (metadata.keysAdded) totalKeyChanges += metadata.keysAdded;
          if (metadata.keysModified) totalKeyChanges += metadata.keysModified;
          if (metadata.keysRemoved) totalKeyChanges += metadata.keysRemoved;
          
          auditTrail.push({
            ...metadata,
            metaFile,
            sortDate: new Date(metadata.createdAt).getTime(),
            action: metadata.type || 'manual_save',
            type: metadata.type || 'manual_save'
          });
        } catch (e) {
          arbLogger.warn('Error loading ARB audit metadata', { 
            language, 
            metaFile, 
            error: e 
          });
        }
      }
    }
    
    // Sortiere nach Datum (neueste zuerst)
    auditTrail.sort((a, b) => b.sortDate - a.sortDate);
    
    arbLogger.info('ARB audit trail loaded', { 
      language,
      userId: req.user!.id,
      auditEntries: auditTrail.length,
      totalKeyChanges
    });

    res.json({ 
      success: true, 
      language,
      auditTrail,
      totalEntries: auditTrail.length,
      totalKeyChanges,
      oldestEntry: auditTrail.length > 0 ? auditTrail[auditTrail.length - 1].createdAt : null,
      newestEntry: auditTrail.length > 0 ? auditTrail[0].createdAt : null
    });

  } catch (error) {
    arbLogger.error('Error loading ARB audit trail', {
      language: req.params.language,
      error: error instanceof Error ? error.message : 'Unknown error',
      userId: req.user?.id
    });
    res.status(500).json({ 
      error: 'Fehler beim Laden des ARB-Audit-Trails' 
    });
  }
});

export default router;