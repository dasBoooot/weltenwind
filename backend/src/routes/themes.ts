import express from 'express';
import fs from 'fs';
import path from 'path';
import { loggers } from '../config/logger.config';
import { csrfProtection } from '../middleware/csrf-protection';
import { adminEndpointLimiter } from '../middleware/rateLimiter';
import { authenticate } from '../middleware/authenticate';

const router = express.Router();

// Theme-Verzeichnis Pfad - Updated für modulare Schemas
const THEMES_DIR = path.join(__dirname, '../../tools/theme-editor/schemas');

// Asset-Verzeichnis Pfad für modulare Welten (im Projekt-Root)
const ASSETS_DIR = path.join(__dirname, '../../../assets/worlds');

/**
 * @swagger
 * /api/themes/named-entrypoints:
 *   get:
 *     summary: Liste aller verfügbaren Named Entrypoints (manifest.json)
 *     tags: [Themes]
 *     description: Lädt alle manifest.json Dateien aus dem assets/worlds Verzeichnis.
 *     responses:
 *       200:
 *         description: Liste der verfügbaren Named Entrypoints
 *         content:
 *           application/json:
 *             schema:
 *               type: object
 *               properties:
 *                 entrypoints:
 *                   type: array
 *                   items:
 *                     type: object
 *                     properties:
 *                       name:
 *                         type: string
 *                         description: Name des Entrypoints
 *                       filename:
 *                         type: string
 *                         description: Dateiname ohne .json Endung
 *                       description:
 *                         type: string
 *                         description: Beschreibung des Entrypoints
 *                       version:
 *                         type: string
 *                         description: Version des Entrypoints
 */
router.get('/named-entrypoints', async (req, res) => {
  try {
    // Debug: Welche Route wurde aufgerufen
    loggers.system.info('📋 Named Entrypoints Route aufgerufen', { 
      originalUrl: req.originalUrl,
      path: req.path,
      params: req.params
    });
    
    loggers.system.info('📋 Lade Named Entrypoints-Liste', {});
    
    // Debug: Pfad ausgeben
    loggers.system.info('🔍 Debug: ASSETS_DIR Pfad', { 
      assetsDir: ASSETS_DIR,
      exists: fs.existsSync(ASSETS_DIR),
      currentDir: process.cwd()
    });
    
    const entrypoints = [];
    
    if (fs.existsSync(ASSETS_DIR)) {
      const worldDirs = fs.readdirSync(ASSETS_DIR, { withFileTypes: true })
        .filter(dirent => dirent.isDirectory())
        .map(dirent => dirent.name);
      
      for (const worldDir of worldDirs) {
        try {
          const manifestPath = path.join(ASSETS_DIR, worldDir, 'manifest.json');
          if (fs.existsSync(manifestPath)) {
            const content = fs.readFileSync(manifestPath, 'utf8');
            const manifest = JSON.parse(content);
            
            entrypoints.push({
              name: manifest.name || worldDir,
              filename: worldDir,
              description: manifest.description || 'Keine Beschreibung verfügbar',
              version: manifest.version || '1.0.0'
            });
          }
        } catch (parseError) {
          loggers.system.warn('⚠️ Fehler beim Parsen der Named Entrypoint-Datei', { 
            worldDir,
            error: parseError instanceof Error ? parseError.message : 'Unknown error'
          });
        }
      }
    }
    
    loggers.system.info('✅ Named Entrypoints-Liste erfolgreich geladen', { count: entrypoints.length });
    res.json({ entrypoints });
    
  } catch (error) {
    loggers.system.error('❌ Fehler beim Laden der Named Entrypoints-Liste', error instanceof Error ? error : new Error('Unknown error'), {});
    res.status(500).json({ 
      error: 'Fehler beim Laden der Named Entrypoints-Liste',
      message: error instanceof Error ? error.message : 'Unknown error'
    });
  }
});

/**
 * @swagger
 * /api/themes/named-entrypoints/{worldId}/{context}:
 *   get:
 *     summary: Named Entrypoint für spezifische Welt und Kontext laden
 *     tags: [Themes]
 *     description: Lädt manifest.json und theme.ts für eine bestimmte Welt und einen bestimmten Kontext (pre-game, game, loading)
 *     parameters:
 *       - in: path
 *         name: worldId
 *         required: true
 *         schema:
 *           type: string
 *         description: Welt-ID (z.B. default, cyberpunk, space)
 *       - in: path
 *         name: context
 *         required: true
 *         schema:
 *           type: string
 *         description: Theme-Kontext (pre-game, game, loading)
 *     responses:
 *       200:
 *         description: Named Entrypoint Daten
 *         content:
 *           application/json:
 *             schema:
 *               type: object
 *               properties:
 *                 manifest:
 *                   type: object
 *                   description: Manifest-Daten
 *                 theme:
 *                   type: object
 *                   description: Theme-Daten
 *       404:
 *         description: Named Entrypoint nicht gefunden
 */
router.get('/named-entrypoints/:worldId/:context', async (req, res) => {
  try {
    const { worldId, context } = req.params;
    
    loggers.system.info('🎨 Lade Named Entrypoint', { worldId, context });
    
    // Manifest-Datei laden
    const manifestPath = path.join(ASSETS_DIR, worldId, 'manifest.json');
    if (!fs.existsSync(manifestPath)) {
      loggers.system.warn('⚠️ Manifest nicht gefunden', { worldId });
      return res.status(404).json({ 
        error: 'Manifest nicht gefunden',
        worldId
      });
    }
    
    const manifestContent = fs.readFileSync(manifestPath, 'utf8');
    const manifest = JSON.parse(manifestContent);
    
    // Prüfen ob der gewünschte Kontext existiert
    if (!manifest.entrypoints?.themes?.[context]) {
      loggers.system.warn('⚠️ Theme-Kontext nicht gefunden', { worldId, context });
      return res.status(404).json({ 
        error: 'Theme-Kontext nicht gefunden',
        worldId,
        context,
        availableContexts: Object.keys(manifest.entrypoints?.themes || {})
      });
    }
    
    const themeEntrypoint = manifest.entrypoints.themes[context];
    const themePath = path.join(ASSETS_DIR, worldId, themeEntrypoint.file);
    
    if (!fs.existsSync(themePath)) {
      loggers.system.warn('⚠️ Theme-Datei nicht gefunden', { worldId, context, file: themeEntrypoint.file });
      return res.status(404).json({ 
        error: 'Theme-Datei nicht gefunden',
        worldId,
        context,
        file: themeEntrypoint.file
      });
    }
    
    // JSON-Datei direkt parsen (kein TypeScript mehr!)
    const themeContent = fs.readFileSync(themePath, 'utf8');
    const themeData = JSON.parse(themeContent);
    
    loggers.system.info('✅ Named Entrypoint erfolgreich geladen', { worldId, context });
    res.json({
      manifest,
      theme: {
        context,
        data: themeData
      }
    });
    
  } catch (error) {
    loggers.system.error('❌ Fehler beim Laden des Named Entrypoints', error instanceof Error ? error : new Error('Unknown error'), {
      worldId: req.params.worldId,
      context: req.params.context
    });
    res.status(500).json({ 
      error: 'Fehler beim Laden des Named Entrypoints',
      message: error instanceof Error ? error.message : 'Unknown error'
    });
  }
});

/**
 * @swagger
 * /api/themes/{name}:
 *   put:
 *     summary: Modulares Theme speichern (nur für Admins)
 *     tags: [Themes]
 *     description: Speichert ein modulares Theme mit flexibler Modul-Struktur
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - in: path
 *         name: name
 *         required: true
 *         schema:
 *           type: string
 *         description: Theme-Dateiname (ohne .json)
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             required:
 *               - name
 *               - version
 *             properties:
 *               name:
 *                 type: string
 *                 description: Theme-Name
 *               version:
 *                 type: string
 *                 description: Theme-Version (Semantic Versioning)
 *               description:
 *                 type: string
 *                 description: Theme-Beschreibung
 *               category:
 *                 type: string
 *                 description: Theme-Kategorie
 *               bundle:
 *                 type: object
 *                 description: Bundle-Konfiguration
 *               colors:
 *                 type: object
 *                 description: Farb-Modul (mindestens ein Modul erforderlich)
 *               typography:
 *                 type: object
 *                 description: Typography-Modul
 *               spacing:
 *                 type: object
 *                 description: Spacing-Modul
 *               radius:
 *                 type: object
 *                 description: Border-Radius-Modul
 *               gaming:
 *                 type: object
 *                 description: Gaming-spezifische Elemente
 *               effects:
 *                 type: object
 *                 description: Visual Effects und Animationen
 *               extensions:
 *                 type: object
 *                 description: Theme-spezifische Erweiterungen
 *     responses:
 *       200:
 *         description: Theme erfolgreich gespeichert
 *         content:
 *           application/json:
 *             schema:
 *               type: object
 *               properties:
 *                 message:
 *                   type: string
 *                 theme:
 *                   type: string
 *       401:
 *         description: Nicht autorisiert
 *       403:
 *         description: Keine Admin-Berechtigung
 *       400:
 *         description: Ungültige Theme-Daten - mindestens name, version und ein Modul erforderlich
 */
router.put('/:name', 
  authenticate, 
  csrfProtection,  // 🔐 CSRF-Schutz für Theme-Updates
  adminEndpointLimiter,  // 👑 Rate limiting für Admin-Operationen
  async (req, res) => {
  try {
    const themeName = req.params.name;
    const themeData = req.body;
    const user = (req as any).user;
    
    loggers.system.info('💾 Speichere Theme', { 
      theme: themeName, 
      user: user?.email || 'Unknown'
    });
    
    // TODO: Admin-Check implementieren
    // if (!user?.isAdmin) {
    //   return res.status(403).json({ error: 'Admin-Berechtigung erforderlich' });
    // }
    
    // Basis-Validierung für modulare Themes
    if (!themeData.name || !themeData.version) {
      loggers.system.warn('⚠️ Ungültige Theme-Daten', { theme: themeName });
      return res.status(400).json({ 
        error: 'Ungültige Theme-Daten',
        required: ['name', 'version'],
        note: 'Modulare Themes können verschiedene Module (colors, typography, etc.) enthalten'
      });
    }
    
    // Zusätzliche Validierung für modulare Struktur
    const hasAnyModule = ['colors', 'typography', 'spacing', 'radius', 'gaming', 'effects'].some(
      module => themeData[module] !== undefined
    );
    
    if (!hasAnyModule) {
      loggers.system.warn('⚠️ Theme ohne Module', { theme: themeName });
      return res.status(400).json({ 
        error: 'Theme muss mindestens ein Modul enthalten',
        availableModules: ['colors', 'typography', 'spacing', 'radius', 'gaming', 'effects']
      });
    }
    
    const filePath = path.join(THEMES_DIR, `${themeName}.json`);
    
    // === ERWEITERTE BACKUP-FUNKTIONALITÄT MIT META-TRACKING ===
    
    // Erstelle backups Verzeichnis falls nicht vorhanden
    const backupsDir = path.join(THEMES_DIR, 'backups');
    if (!fs.existsSync(backupsDir)) {
      fs.mkdirSync(backupsDir, { recursive: true });
    }
    
    // Erstelle detailliertes Backup mit Zeitstempel und Metadaten
    if (fs.existsSync(filePath)) {
      const now = new Date();
      const date = now.toISOString().split('T')[0]; // YYYY-MM-DD
      const time = now.toTimeString().split(' ')[0].replace(/:/g, ''); // HHMMSS
      const timestamp = `${date}_${time}`;
      const backupFile = path.join(backupsDir, `${themeName}.json.backup_${timestamp}`);
      
      // Erstelle Backup der aktuellen Theme-Datei
      fs.copyFileSync(filePath, backupFile);
      
      // Lade aktuelle Theme-Daten für Vergleich
      let originalThemeData: any = null;
      let modulesModified: string[] = [];
      const moduleKeys = ['colors', 'typography', 'spacing', 'radius', 'gaming', 'effects', 'bundle'];
      
      try {
        originalThemeData = JSON.parse(fs.readFileSync(filePath, 'utf8'));
        
        // Analysiere welche Module geändert wurden
        modulesModified = moduleKeys.filter((module: string) => {
          const originalModule = JSON.stringify(originalThemeData[module] || {});
          const newModule = JSON.stringify(themeData[module] || {});
          return originalModule !== newModule;
        });
      } catch (e) {
        loggers.system.warn('⚠️ Fehler beim Analysieren der Theme-Änderungen', { theme: themeName, error: e });
      }
      
      // Speichere detaillierte Backup-Metadaten
      const metadataFile = path.join(backupsDir, `${themeName}.json.backup_${timestamp}.meta.json`);
      const backupMetadata = {
        themeName,
        timestamp,
        createdBy: user?.username || 'Unknown',
        createdById: user?.id || null,
        createdAt: new Date().toISOString(),
        originalSize: fs.statSync(filePath).size,
        originalVersion: originalThemeData?.version || 'unknown',
        newVersion: themeData.version,
        type: 'manual_save',
        modulesModified,
        totalModules: moduleKeys.filter((module: string) => themeData[module] !== undefined).length,
        backupReason: 'Theme Editor manual save',
        userAgent: 'Theme Editor Web Interface',
        originalChecksum: require('crypto').createHash('md5').update(fs.readFileSync(filePath)).digest('hex'),
        category: themeData.category || 'unknown'
      };
      
      fs.writeFileSync(metadataFile, JSON.stringify(backupMetadata, null, 2), 'utf8');
      
      // Cleanup: Nur die letzten 15 Backups behalten (mehr als ARB da Themes seltener geändert werden)
      const backupPattern = new RegExp(`^${themeName.replace(/[.*+?^${}()|[\]\\]/g, '\\$&')}\\.json\\.backup_\\d{4}-\\d{2}-\\d{2}_\\d{6}$`);
      const existingBackups = fs.readdirSync(backupsDir)
        .filter(file => backupPattern.test(file))
        .map(file => ({
          name: file,
          path: path.join(backupsDir, file),
          timestamp: fs.statSync(path.join(backupsDir, file)).mtime
        }))
        .sort((a, b) => b.timestamp.getTime() - a.timestamp.getTime()); // Neueste zuerst
      
      // Lösche Backups über das Limit hinaus
      if (existingBackups.length > 15) {
        const toDelete = existingBackups.slice(15);
        for (const backup of toDelete) {
          try {
            fs.unlinkSync(backup.path);
            // Lösche auch die entsprechende Meta-Datei
            const metaPath = `${backup.path}.meta.json`;
            if (fs.existsSync(metaPath)) {
              fs.unlinkSync(metaPath);
            }
            loggers.system.info('🗑️ Altes Theme-Backup gelöscht', { 
              theme: themeName,
              deletedFile: backup.name,
              user: user?.username || 'Unknown'
            });
          } catch (cleanupError) {
            loggers.system.warn('⚠️ Fehler beim Löschen alten Backups', { 
              theme: themeName, 
              file: backup.name,
              error: cleanupError 
            });
          }
        }
      }
      
      loggers.system.info('📋 Erweitertes Theme-Backup erstellt', { 
        theme: themeName,
        user: user?.username || 'Unknown',
        userId: user?.id || null,
        backupFile,
        metadataFile,
        timestamp,
        modulesModified,
        totalBackups: Math.min(existingBackups.length + 1, 15)
      });
    }
    
    // Theme speichern (ohne _audit Feld für saubere Theme-Dateien)
    // Audit-Informationen werden separat in Backup-Metadaten gespeichert
    fs.writeFileSync(filePath, JSON.stringify(themeData, null, 2), 'utf8');
    
    // Erstelle zusätzliche Audit-Metadatei für das gespeicherte Theme
    const auditMetadataFile = path.join(THEMES_DIR, `${themeName}.audit.json`);
    const auditMetadata = {
      themeName,
      lastModified: new Date().toISOString(),
      lastModifiedBy: user?.username || 'Unknown',
      lastModifiedById: user?.id || null,
      version: themeData.version,
      editorVersion: '2.0.0',
      category: themeData.category || 'unknown',
      totalModules: ['colors', 'typography', 'spacing', 'radius', 'gaming', 'effects', 'bundle']
        .filter((module: string) => themeData[module] !== undefined).length
    };
    
    fs.writeFileSync(auditMetadataFile, JSON.stringify(auditMetadata, null, 2), 'utf8');
    
    loggers.system.info('✅ Theme erfolgreich gespeichert', { 
      theme: themeName,
      user: user?.email || 'Unknown'
    });
    
    res.json({ 
      message: 'Theme erfolgreich gespeichert',
      theme: themeName
    });
    
  } catch (error) {
    loggers.system.error('❌ Fehler beim Speichern des Themes', error instanceof Error ? error : new Error('Unknown error'), {
      theme: req.params.name
    });
    res.status(500).json({ 
      error: 'Fehler beim Speichern des Themes',
      message: error instanceof Error ? error.message : 'Unknown error'
    });
  }
});

/**
 * @swagger
 * /api/themes/{name}/clone:
 *   post:
 *     summary: Theme klonen (nur für Admins)
 *     tags: [Themes]
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - in: path
 *         name: name
 *         required: true
 *         schema:
 *           type: string
 *         description: Quell-Theme Name
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             properties:
 *               newName:
 *                 type: string
 *               newDescription:
 *                 type: string
 *     responses:
 *       200:
 *         description: Theme erfolgreich geklont
 *       404:
 *         description: Quell-Theme nicht gefunden
 *       409:
 *         description: Ziel-Theme existiert bereits
 */
router.post('/:name/clone', 
  authenticate, 
  csrfProtection,  // 🔐 CSRF-Schutz für Theme-Cloning
  adminEndpointLimiter,  // 👑 Rate limiting für Admin-Operationen
  async (req, res) => {
  try {
    const sourceName = req.params.name;
    const { newName, newDescription } = req.body;
    const user = (req as any).user;
    
    loggers.system.info('📋 Klone Theme', { 
      source: sourceName, 
      target: newName,
      user: user?.email || 'Unknown'
    });
    
    if (!newName) {
      return res.status(400).json({ error: 'newName ist erforderlich' });
    }
    
    const sourcePath = path.join(THEMES_DIR, `${sourceName}.json`);
    const targetPath = path.join(THEMES_DIR, `${newName}.json`);
    
    // Prüfe ob Quell-Theme existiert
    if (!fs.existsSync(sourcePath)) {
      return res.status(404).json({ error: 'Quell-Theme nicht gefunden' });
    }
    
    // Prüfe ob Ziel-Theme bereits existiert
    if (fs.existsSync(targetPath)) {
      return res.status(409).json({ error: 'Ziel-Theme existiert bereits' });
    }
    
    // Theme laden und modifizieren
    const sourceContent = fs.readFileSync(sourcePath, 'utf8');
    const sourceTheme = JSON.parse(sourceContent);
    
    const clonedTheme = {
      ...sourceTheme,
      name: newName,
      description: newDescription || `Kopie von ${sourceTheme.name}`,
      version: '1.0.0'
    };
    
    // === ERWEITERTE CLONE-FUNKTIONALITÄT MIT META-TRACKING ===
    
    // Geklontes Theme speichern (ohne _audit Feld für saubere Theme-Dateien)
    fs.writeFileSync(targetPath, JSON.stringify(clonedTheme, null, 2), 'utf8');
    
    // Erstelle separate Audit-Metadatei für das geklonte Theme
    const clonedAuditFile = path.join(THEMES_DIR, `${newName}.audit.json`);
    const clonedAuditMetadata = {
      themeName: newName,
      lastModified: new Date().toISOString(),
      lastModifiedBy: user?.username || 'Unknown',
      lastModifiedById: user?.id || null,
      version: clonedTheme.version,
      editorVersion: '2.0.0',
      category: clonedTheme.category || sourceTheme.category || 'unknown',
      clonedFrom: sourceName,
      clonedAt: new Date().toISOString(),
      totalModules: ['colors', 'typography', 'spacing', 'radius', 'gaming', 'effects', 'bundle']
        .filter((module: string) => clonedTheme[module] !== undefined).length
    };
    
    fs.writeFileSync(clonedAuditFile, JSON.stringify(clonedAuditMetadata, null, 2), 'utf8');
    
    // Erstelle Clone-Metadaten für Audit-Trail
    const backupsDir = path.join(THEMES_DIR, 'backups');
    if (!fs.existsSync(backupsDir)) {
      fs.mkdirSync(backupsDir, { recursive: true });
    }
    
    const now = new Date();
    const timestamp = `${now.toISOString().split('T')[0]}_${now.toTimeString().split(' ')[0].replace(/:/g, '')}`;
    const cloneMetadataFile = path.join(backupsDir, `${newName}.clone_${timestamp}.meta.json`);
    
    const cloneMetadata = {
      action: 'theme_clone',
      sourceTheme: sourceName,
      targetTheme: newName,
      timestamp,
      createdBy: user?.username || 'Unknown',
      createdById: user?.id || null,
      createdAt: new Date().toISOString(),
      sourceSize: fs.statSync(sourcePath).size,
      targetSize: fs.statSync(targetPath).size,
      sourceVersion: sourceTheme.version,
      targetVersion: clonedTheme.version,
      type: 'theme_clone',
      backupReason: 'Theme cloned from existing theme',
      category: clonedTheme.category || sourceTheme.category || 'unknown',
      modulesCopied: ['colors', 'typography', 'spacing', 'radius', 'gaming', 'effects', 'bundle']
        .filter(module => sourceTheme[module] !== undefined)
    };
    
    fs.writeFileSync(cloneMetadataFile, JSON.stringify(cloneMetadata, null, 2), 'utf8');
    
    loggers.system.info('✅ Theme erfolgreich geklont mit Meta-Tracking', { 
      source: sourceName, 
      target: newName,
      user: user?.username || 'Unknown',
      userId: user?.id || null,
      cloneMetadataFile,
      modulesCopied: cloneMetadata.modulesCopied.length
    });
    
    res.json({ 
      message: 'Theme erfolgreich geklont',
      source: sourceName,
      target: newName
    });
    
  } catch (error) {
    loggers.system.error('❌ Fehler beim Klonen des Themes', error instanceof Error ? error : new Error('Unknown error'), {
      source: req.params.name
    });
    res.status(500).json({ 
      error: 'Fehler beim Klonen des Themes',
      message: error instanceof Error ? error.message : 'Unknown error'
    });
  }
});

// === THEME BACKUP MANAGEMENT (basierend auf ARB-Manager Pattern) ===



/**
 * @swagger
 * /api/themes:
 *   get:
 *     summary: Liste aller verfügbaren modularen Themes
 *     tags: [Themes]
 *     description: Lädt alle verfügbaren modularen Themes aus dem schemas-Verzeichnis
 *     responses:
 *       200:
 *         description: Liste der verfügbaren modularen Themes
 *         content:
 *           application/json:
 *             schema:
 *               type: object
 *               properties:
 *                 themes:
 *                   type: array
 *                   items:
 *                     type: object
 *                     properties:
 *                       name:
 *                         type: string
 *                         description: Theme-Name
 *                       filename:
 *                         type: string
 *                         description: Dateiname ohne .json Endung
 *                       description:
 *                         type: string
 *                         description: Theme-Beschreibung
 *                       version:
 *                         type: string
 *                         description: Theme-Version (Semantic Versioning)
 */
router.get('/', async (req, res) => {
  try {
    loggers.system.info('📋 Lade Theme-Liste', {});
    
    // Theme-Dateien lesen (Schema-Dateien, Audit-Dateien und Backup-Dateien ausschließen)
    const files = fs.readdirSync(THEMES_DIR)
      .filter(file => 
        file.endsWith('.json') && 
        !file.includes('.schema.json') && 
        !file.includes('.audit.json') &&
        !file.includes('.backup_') &&
        file !== 'main.schema.json'
      );
    
    const themes = [];
    
    for (const file of files) {
      try {
        const filePath = path.join(THEMES_DIR, file);
        const content = fs.readFileSync(filePath, 'utf8');
        const theme = JSON.parse(content);
        
        themes.push({
          name: theme.name || file.replace('.json', ''),
          filename: file.replace('.json', ''),
          description: theme.description || 'Kein Beschreibung verfügbar',
          version: theme.version || '1.0.0'
        });
      } catch (parseError) {
        loggers.system.warn('⚠️ Fehler beim Parsen der Theme-Datei', { 
          file,
          error: parseError instanceof Error ? parseError.message : 'Unknown error'
        });
      }
    }
    
    loggers.system.info('✅ Theme-Liste erfolgreich geladen', { count: themes.length });
    res.json({ themes });
    
  } catch (error) {
    loggers.system.error('❌ Fehler beim Laden der Theme-Liste', error instanceof Error ? error : new Error('Unknown error'), {});
    res.status(500).json({ 
      error: 'Fehler beim Laden der Theme-Liste',
      message: error instanceof Error ? error.message : 'Unknown error'
    });
  }
});

// === THEME BACKUP MANAGEMENT (basierend auf ARB-Manager Pattern) ===

/**
 * @swagger
 * /api/themes/{name}/backups:
 *   get:
 *     summary: Liste aller Backups für ein Theme
 *     tags: [Themes]
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - in: path
 *         name: name
 *         required: true
 *         schema:
 *           type: string
 *         description: Theme-Name
 *     responses:
 *       200:
 *         description: Liste der Theme-Backups mit Metadaten
 *         content:
 *           application/json:
 *             schema:
 *               type: object
 *               properties:
 *                 success:
 *                   type: boolean
 *                 theme:
 *                   type: string
 *                 backups:
 *                   type: array
 *                   items:
 *                     type: object
 *                     properties:
 *                       filename:
 *                         type: string
 *                       timestamp:
 *                         type: string
 *                       created:
 *                         type: string
 *                         format: date-time
 *                       size:
 *                         type: number
 *                       createdBy:
 *                         type: string
 *                       type:
 *                         type: string
 *                       modulesModified:
 *                         type: array
 *                         items:
 *                           type: string
 *                       metadata:
 *                         type: object
 *       403:
 *         description: Keine Berechtigung für Backup-Anzeige
 *       404:
 *         description: Theme nicht gefunden
 */
router.get('/:name/backups', authenticate, async (req, res) => {
  try {
    const { name: themeName } = req.params;
    const user = (req as any).user;
    
    // TODO: Implementiere Theme-specific Berechtigungen
    // Für jetzt: alle authentifizierten Benutzer können Backups anzeigen
    
    const backupsDir = path.join(THEMES_DIR, 'backups');
    
    if (!fs.existsSync(backupsDir)) {
      return res.json({ 
        success: true, 
        theme: themeName, 
        backups: [] 
      });
    }

    // Sichere Regex für Theme-Namen (escape special characters)  
    const escapedThemeName = themeName.replace(/[.*+?^${}()|[\]\\]/g, '\\$&');
    const backupPattern = new RegExp(`^${escapedThemeName}\\.json\\.backup_(\\d{4}-\\d{2}-\\d{2}_\\d{6})$`);
    
    const backups = fs.readdirSync(backupsDir)
      .filter(file => backupPattern.test(file))
      .map(file => {
        const match = file.match(backupPattern);
        const timestamp = match ? match[1] : '';
        const filePath = path.join(backupsDir, file);
        const stats = fs.statSync(filePath);
        
        // Formatiere Zeitstempel für Anzeige
        const formatDisplayName = (ts: string): string => {
          const [date, time] = ts.split('_');
          const formattedDate = date.replace(/-/g, '.');
          const hours = time.substring(0, 2);
          const minutes = time.substring(2, 4);
          const seconds = time.substring(4, 6);
          return `${formattedDate} um ${hours}:${minutes}:${seconds}`;
        };

        // Lade Metadaten falls vorhanden
        const metadataFile = path.join(backupsDir, `${file}.meta.json`);
        let metadata = null;
        let createdBy = 'Unknown';
        let backupType = 'manual_save';
        let modulesModified: string[] = [];
        let originalVersion = 'unknown';
        let newVersion = 'unknown';
        
        if (fs.existsSync(metadataFile)) {
          try {
            const metaContent = fs.readFileSync(metadataFile, 'utf8');
            metadata = JSON.parse(metaContent);
            createdBy = metadata.createdBy || 'Unknown';
            backupType = metadata.type || 'manual_save';
            modulesModified = metadata.modulesModified || [];
            originalVersion = metadata.originalVersion || 'unknown';
            newVersion = metadata.newVersion || 'unknown';
          } catch (e) {
            loggers.system.warn('⚠️ Fehler beim Laden der Backup-Metadaten', { 
              theme: themeName, 
              metadataFile, 
              error: e 
            });
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
          modulesModified,
          originalVersion,
          newVersion,
          metadata
        };
      })
      .sort((a, b) => b.created.getTime() - a.created.getTime()); // Neueste zuerst

    loggers.system.info('📋 Theme-Backups aufgelistet', { 
      theme: themeName,
      user: user?.username || 'Unknown',
      userId: user?.id || null,
      backupCount: backups.length 
    });

    res.json({ 
      success: true, 
      theme: themeName,
      backups 
    });

  } catch (error) {
    loggers.system.error('❌ Fehler beim Laden der Theme-Backup-Liste', error instanceof Error ? error : new Error('Unknown error'), {
      theme: req.params.name
    });
    res.status(500).json({ 
      error: 'Fehler beim Laden der Backup-Liste' 
    });
  }
});

/**
 * @swagger
 * /api/themes/{name}/audit:
 *   get:
 *     summary: Audit-Trail für ein Theme (Backups + Clone-History)
 *     tags: [Themes]
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - in: path
 *         name: name
 *         required: true
 *         schema:
 *           type: string
 *         description: Theme-Name
 *     responses:
 *       200:
 *         description: Vollständiger Audit-Trail mit allen Theme-Aktivitäten
 */
router.get('/:name/audit', authenticate, async (req, res) => {
  try {
    const { name: themeName } = req.params;
    const user = (req as any).user;
    
    const backupsDir = path.join(THEMES_DIR, 'backups');
    const auditTrail: any[] = [];
    
    if (fs.existsSync(backupsDir)) {
      // Lade alle Backup-Metadaten
      const backupMetaPattern = new RegExp(`^${themeName.replace(/[.*+?^${}()|[\]\\]/g, '\\$&')}\\.json\\.backup_\\d{4}-\\d{2}-\\d{2}_\\d{6}\\.meta\\.json$`);
      const cloneMetaPattern = new RegExp(`^${themeName.replace(/[.*+?^${}()|[\]\\]/g, '\\$&')}\\.clone_\\d{4}-\\d{2}-\\d{2}_\\d{6}\\.meta\\.json$`);
      
      const metaFiles = fs.readdirSync(backupsDir)
        .filter(file => backupMetaPattern.test(file) || cloneMetaPattern.test(file));
      
      for (const metaFile of metaFiles) {
        try {
          const metaPath = path.join(backupsDir, metaFile);
          const metadata = JSON.parse(fs.readFileSync(metaPath, 'utf8'));
          
          auditTrail.push({
            ...metadata,
            metaFile,
            sortDate: new Date(metadata.createdAt).getTime()
          });
        } catch (e) {
          loggers.system.warn('⚠️ Fehler beim Laden von Audit-Metadaten', { 
            theme: themeName, 
            metaFile, 
            error: e 
          });
        }
      }
    }
    
    // Sortiere nach Datum (neueste zuerst)
    auditTrail.sort((a, b) => b.sortDate - a.sortDate);
    
    loggers.system.info('📊 Theme-Audit-Trail geladen', { 
      theme: themeName,
      user: user?.username || 'Unknown',
      userId: user?.id || null,
      auditEntries: auditTrail.length 
    });

    res.json({ 
      success: true, 
      theme: themeName,
      auditTrail,
      totalEntries: auditTrail.length,
      oldestEntry: auditTrail.length > 0 ? auditTrail[auditTrail.length - 1].createdAt : null,
      newestEntry: auditTrail.length > 0 ? auditTrail[0].createdAt : null
    });

  } catch (error) {
    loggers.system.error('❌ Fehler beim Laden des Theme-Audit-Trails', error instanceof Error ? error : new Error('Unknown error'), {
      theme: req.params.name
    });
    res.status(500).json({ 
      error: 'Fehler beim Laden des Audit-Trails' 
    });
  }
});

/**
 * @swagger
 * /api/themes/{name}:
 *   get:
 *     summary: Einzelnes modulares Theme laden
 *     tags: [Themes]
 *     description: Lädt ein spezifisches modulares Theme mit allen verfügbaren Modulen
 *     parameters:
 *       - in: path
 *         name: name
 *         required: true
 *         schema:
 *           type: string
 *         description: Theme-Dateiname (ohne .json)
 *     responses:
 *       200:
 *         description: Modulare Theme-Daten
 *         content:
 *           application/json:
 *             schema:
 *               type: object
 *               properties:
 *                 name:
 *                   type: string
 *                   description: Theme-Name
 *                 version:
 *                   type: string
 *                   description: Theme-Version
 *                 description:
 *                   type: string
 *                   description: Theme-Beschreibung
 *                 category:
 *                   type: string
 *                   description: Theme-Kategorie (fantasy, sci-fi, etc.)
 *                 bundle:
 *                   type: object
 *                   description: Bundle-Konfiguration
 *                 colors:
 *                   type: object
 *                   description: Farb-Modul (optional)
 *                 typography:
 *                   type: object
 *                   description: Typography-Modul (optional)
 *                 spacing:
 *                   type: object
 *                   description: Spacing-Modul (optional)
 *                 radius:
 *                   type: object
 *                   description: Border-Radius-Modul (optional)
 *                 gaming:
 *                   type: object
 *                   description: Gaming-spezifische Elemente (optional)
 *                 effects:
 *                   type: object
 *                   description: Visual Effects und Animationen (optional)
 *                 extensions:
 *                   type: object
 *                   description: Theme-spezifische Erweiterungen (optional)
 *       404:
 *         description: Theme nicht gefunden
 */
router.get('/:name', async (req, res) => {
  try {
    const themeName = req.params.name;
    const filePath = path.join(THEMES_DIR, `${themeName}.json`);
    
    // Debug: Welche Route wurde aufgerufen
    loggers.system.info('🎨 Lade Theme (/:name Route)', { 
      theme: themeName,
      originalUrl: req.originalUrl,
      path: req.path,
      params: req.params
    });
    
    if (!fs.existsSync(filePath)) {
      loggers.system.warn('⚠️ Theme nicht gefunden', { theme: themeName });
      return res.status(404).json({ 
        error: 'Theme nicht gefunden',
        theme: themeName
      });
    }
    
    const content = fs.readFileSync(filePath, 'utf8');
    const theme = JSON.parse(content);
    
    loggers.system.info('✅ Theme erfolgreich geladen', { theme: themeName });
    res.json(theme);
    
  } catch (error) {
    loggers.system.error('❌ Fehler beim Laden des Themes', error instanceof Error ? error : new Error('Unknown error'), {
      theme: req.params.name
    });
    res.status(500).json({ 
      error: 'Fehler beim Laden des Themes',
      message: error instanceof Error ? error.message : 'Unknown error'
    });
  }
});

export default router;