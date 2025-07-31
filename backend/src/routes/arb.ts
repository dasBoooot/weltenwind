import express from 'express';
import { authenticate, AuthenticatedRequest } from '../middleware/authenticate';
import { hasPermission } from '../services/access-control.service';
import { loggers } from '../config/logger.config';
import fs from 'fs';
import path from 'path';

const router = express.Router();
const arbLogger = loggers.arb;

// ARB-Dateien Pfad
const ARB_PATH = path.join(__dirname, '../../../client/lib/l10n');

// Verfügbare Sprachen
const SUPPORTED_LANGUAGES = ['de', 'en'];

/**
 * GET /api/arb/languages
 * Gibt verfügbare Sprachen zurück
 */
router.get('/languages', authenticate, async (req: AuthenticatedRequest, res) => {
  try {
    // Prüfe Berechtigung für Lokalisierung
    const canManageLocalization = await hasPermission(req.user!.id, 'localization.manage', { type: 'global', objectId: '*' });
    
    if (!canManageLocalization) {
      return res.status(403).json({ 
        error: 'Keine Berechtigung für Lokalisierungs-Management' 
      });
    }

    // Suche nach existierenden ARB-Dateien
    const languages = [];
    
    for (const lang of SUPPORTED_LANGUAGES) {
      const arbFile = path.join(ARB_PATH, `app_${lang}.arb`);
      if (fs.existsSync(arbFile)) {
        const stats = fs.statSync(arbFile);
        const content = JSON.parse(fs.readFileSync(arbFile, 'utf8'));
        
        // Zähle Keys (ohne @-Keys)
        const keyCount = Object.keys(content).filter(key => !key.startsWith('@')).length;
        
        languages.push({
          code: lang,
          name: lang === 'de' ? 'Deutsch' : 'English',
          keyCount,
          lastModified: stats.mtime,
          isMaster: lang === 'de' // Deutsche ARB ist Master
        });
      }
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
 * GET /api/arb/:language
 * Lädt eine ARB-Datei
 */
router.get('/:language', authenticate, async (req: AuthenticatedRequest, res) => {
  try {
    const { language } = req.params;
    
    // Validiere Sprache
    if (!SUPPORTED_LANGUAGES.includes(language)) {
      return res.status(400).json({ error: 'Ungültige Sprache' });
    }

    // Prüfe Berechtigung
    const canManageLocalization = await hasPermission(req.user!.id, 'localization.manage', { type: 'global', objectId: '*' });
    
    if (!canManageLocalization) {
      return res.status(403).json({ 
        error: 'Keine Berechtigung für Lokalisierungs-Management' 
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
 * Aktualisiert eine ARB-Datei (nur Master-Language DE)
 */
router.put('/:language', authenticate, async (req: AuthenticatedRequest, res) => {
  try {
    const { language } = req.params;
    const { entries } = req.body;

    // Nur Deutsche ARB kann visuell bearbeitet werden
    if (language !== 'de') {
      return res.status(400).json({ 
        error: 'Nur die deutsche Master-ARB kann bearbeitet werden. Andere Sprachen werden automatisch übersetzt.' 
      });
    }

    // Prüfe Berechtigung
    const canManageLocalization = await hasPermission(req.user!.id, 'localization.manage', { type: 'global', objectId: '*' });
    
    if (!canManageLocalization) {
      return res.status(403).json({ 
        error: 'Keine Berechtigung für Lokalisierungs-Management' 
      });
    }

    // Validiere Eingabe
    if (!Array.isArray(entries)) {
      return res.status(400).json({ error: 'Ungültiges Eingabeformat' });
    }

    // Erstelle neue ARB-Struktur
    const newContent: any = {};
    
    for (const entry of entries) {
      if (!entry.key || typeof entry.value !== 'string') {
        return res.status(400).json({ 
          error: `Ungültiger Eintrag: ${entry.key || 'unbekannt'}` 
        });
      }

      newContent[entry.key] = entry.value;
      
      if (entry.metadata) {
        newContent[`@${entry.key}`] = entry.metadata;
      }
    }

    // Backup der alten Datei (nur einmaliges Initial-Backup)
    const arbFile = path.join(ARB_PATH, `app_${language}.arb`);
    const backupFile = path.join(ARB_PATH, `app_${language}.arb.backup`);
    
    // Erstelle Backup nur wenn noch keins existiert
    if (fs.existsSync(arbFile) && !fs.existsSync(backupFile)) {
      fs.copyFileSync(arbFile, backupFile);
      arbLogger.info('Initial ARB backup created', { 
        userId: req.user!.id, 
        language, 
        backupFile 
      });
    }

    // Schreibe neue ARB-Datei
    fs.writeFileSync(arbFile, JSON.stringify(newContent, null, 2), 'utf8');

    arbLogger.info('ARB file updated', { 
      userId: req.user!.id, 
      language, 
      entryCount: entries.length,
      backupExists: fs.existsSync(backupFile)
    });

    res.json({
      success: true,
      message: 'ARB-Datei erfolgreich aktualisiert',
      entryCount: entries.length,
      nextStep: 'Führe das translate.ps1 Script aus um andere Sprachen zu aktualisieren'
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
 * POST /api/arb/translate
 * Triggert automatische Übersetzung via CLI
 */
router.post('/translate', authenticate, async (req: AuthenticatedRequest, res) => {
  try {
    // Prüfe Berechtigung
    const canManageLocalization = await hasPermission(req.user!.id, 'localization.manage', { type: 'global', objectId: '*' });
    
    if (!canManageLocalization) {
      return res.status(403).json({ 
        error: 'Keine Berechtigung für Lokalisierungs-Management' 
      });
    }

    // Hier könnte man das PowerShell-Script ausführen
    // Für jetzt nur eine Anleitung zurückgeben
    arbLogger.info('Translation requested', { userId: req.user!.id });

    res.json({
      success: true,
      message: 'Übersetzung bereit',
      instruction: 'Führe im client-Verzeichnis das Script aus: ./translate.ps1',
      command: 'cd client && ./translate.ps1'
    });

  } catch (error) {
    arbLogger.error('Error requesting translation', { 
      error: error instanceof Error ? error.message : 'Unknown error',
      userId: req.user?.id 
    });
    res.status(500).json({ error: 'Fehler beim Starten der Übersetzung' });
  }
});

export default router;