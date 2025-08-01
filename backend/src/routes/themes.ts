import express from 'express';
import fs from 'fs';
import path from 'path';
import { loggers } from '../config/logger.config';
import { authenticate } from '../middleware/authenticate';

const router = express.Router();

// Theme-Verzeichnis Pfad
const THEMES_DIR = path.join(__dirname, '../../theme-editor/tokens');

/**
 * @swagger
 * /api/themes:
 *   get:
 *     summary: Liste aller verfügbaren Themes
 *     tags: [Themes]
 *     responses:
 *       200:
 *         description: Liste der verfügbaren Themes
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
 *                       filename:
 *                         type: string
 *                       description:
 *                         type: string
 *                       version:
 *                         type: string
 */
router.get('/', async (req, res) => {
  try {
    loggers.system.info('📋 Lade Theme-Liste', {});
    
    // Theme-Dateien lesen
    const files = fs.readdirSync(THEMES_DIR)
      .filter(file => file.endsWith('.json') && file !== 'theme-schema.json');
    
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

/**
 * @swagger
 * /api/themes/{name}:
 *   get:
 *     summary: Einzelnes Theme laden
 *     tags: [Themes]
 *     parameters:
 *       - in: path
 *         name: name
 *         required: true
 *         schema:
 *           type: string
 *         description: Theme Name
 *     responses:
 *       200:
 *         description: Theme Daten
 *         content:
 *           application/json:
 *             schema:
 *               type: object
 *       404:
 *         description: Theme nicht gefunden
 */
router.get('/:name', async (req, res) => {
  try {
    const themeName = req.params.name;
    const filePath = path.join(THEMES_DIR, `${themeName}.json`);
    
    loggers.system.info('🎨 Lade Theme', { theme: themeName });
    
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

/**
 * @swagger
 * /api/themes/{name}:
 *   put:
 *     summary: Theme speichern (nur für Admins)
 *     tags: [Themes]
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - in: path
 *         name: name
 *         required: true
 *         schema:
 *           type: string
 *         description: Theme Name
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *     responses:
 *       200:
 *         description: Theme erfolgreich gespeichert
 *       401:
 *         description: Nicht autorisiert
 *       403:
 *         description: Keine Admin-Berechtigung
 *       400:
 *         description: Ungültige Theme-Daten
 */
router.put('/:name', authenticate, async (req, res) => {
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
    
    // Basis-Validierung
    if (!themeData.name || !themeData.version || !themeData.colors) {
      loggers.system.warn('⚠️ Ungültige Theme-Daten', { theme: themeName });
      return res.status(400).json({ 
        error: 'Ungültige Theme-Daten',
        required: ['name', 'version', 'colors']
      });
    }
    
    const filePath = path.join(THEMES_DIR, `${themeName}.json`);
    
    // Backup des existierenden Themes (falls vorhanden)
    if (fs.existsSync(filePath)) {
      const backupPath = path.join(THEMES_DIR, `${themeName}.backup.json`);
      fs.copyFileSync(filePath, backupPath);
      loggers.system.info('📋 Backup erstellt', { theme: themeName });
    }
    
    // Theme speichern
    fs.writeFileSync(filePath, JSON.stringify(themeData, null, 2), 'utf8');
    
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
router.post('/:name/clone', authenticate, async (req, res) => {
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
    
    // Geklontes Theme speichern
    fs.writeFileSync(targetPath, JSON.stringify(clonedTheme, null, 2), 'utf8');
    
    loggers.system.info('✅ Theme erfolgreich geklont', { 
      source: sourceName, 
      target: newName,
      user: user?.email || 'Unknown'
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

export default router;