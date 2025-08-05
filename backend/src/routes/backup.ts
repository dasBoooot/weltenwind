// 🗄️ Backup Management API Routes
import { Router, Response, NextFunction } from 'express';
import { authenticate, AuthenticatedRequest } from '../middleware/authenticate';
import { hasPermission } from '../services/access-control.service';
import { adminEndpointLimiter } from '../middleware/rateLimiter';
import { backupService } from '../services/backup.service';
import { loggers } from '../config/logger.config';

const router = Router();

// 🔐 Admin-Permission-Check Middleware
async function checkAdminPermission(req: AuthenticatedRequest, res: Response, next: NextFunction) {
  if (!req.user) {
    return res.status(401).json({ error: 'Nicht authentifiziert' });
  }

  const hasAdminPerm = await hasPermission(req.user.id, 'system.logs', {
    type: 'global',
    objectId: '*'
  });

  if (!hasAdminPerm) {
    return res.status(403).json({
      error: 'Keine Berechtigung für Backup-Management'
    });
  }

  next();
}

/**
 * @swagger
 * /api/backup:
 *   get:
 *     summary: Backup System Overview
 *     description: Returns comprehensive backup system status and statistics
 *     tags: [Backup Management]
 *     security:
 *       - bearerAuth: []
 *     responses:
 *       200:
 *         description: Backup system overview
 *         content:
 *           application/json:
 *             schema:
 *               type: object
 *               properties:
 *                 config:
 *                   type: object
 *                   description: Current backup configuration
 *                 stats:
 *                   type: object
 *                   description: Backup statistics
 *                 health:
 *                   type: object
 *                   description: System health status
 */
router.get('/',
  authenticate,
  adminEndpointLimiter,
  checkAdminPermission,
  async (req: AuthenticatedRequest, res) => {
    try {
      const [config, stats, health] = await Promise.all([
        backupService.getConfig(),
        backupService.getBackupStats(),
        backupService.performHealthCheck()
      ]);

      loggers.system.info('Backup overview requested', {
        userId: req.user!.id,
        enabled: config.enabled,
        totalBackups: stats.totalBackups
      });

      res.json({
        config: {
          enabled: config.enabled,
          backupDir: config.backupDir,
          retention: config.retention,
          compression: config.compression,
          autoDiscovery: config.autoDiscovery,
          smartScheduling: config.smartScheduling,
          healthCheckEnabled: config.healthCheckEnabled,
          autoVerification: config.autoVerification,
          offsite: {
            enabled: config.offsite.enabled,
            s3Bucket: config.offsite.s3Bucket
          }
        },
        stats,
        health,
        timestamp: Date.now()
      });

    } catch (error: any) {
      loggers.system.error('Failed to retrieve backup overview', error);
      res.status(500).json({
        error: 'Fehler beim Abrufen der Backup-Übersicht',
        details: error?.message
      });
    }
  }
);

/**
 * @swagger
 * /api/backup/health:
 *   get:
 *     summary: Backup System Health Check
 *     description: Returns detailed health status of the backup system
 *     tags: [Backup Management]
 *     security:
 *       - bearerAuth: []
 *     responses:
 *       200:
 *         description: Backup system health status
 */
router.get('/health',
  authenticate,
  adminEndpointLimiter,
  checkAdminPermission,
  async (req: AuthenticatedRequest, res) => {
    try {
      const health = await backupService.performHealthCheck();

      loggers.system.info('Backup health check requested', {
        userId: req.user!.id,
        status: health.status,
        failedChecks: health.checks.filter(c => c.status === 'fail').length
      });

      res.json(health);

    } catch (error: any) {
      loggers.system.error('Failed to perform backup health check', error);
      res.status(500).json({
        error: 'Fehler beim Backup-Health-Check',
        details: error?.message
      });
    }
  }
);

/**
 * @swagger
 * /api/backup/jobs:
 *   get:
 *     summary: Active Backup Jobs
 *     description: Returns list of currently active and recent backup jobs
 *     tags: [Backup Management]
 *     security:
 *       - bearerAuth: []
 *     responses:
 *       200:
 *         description: List of backup jobs
 */
router.get('/jobs',
  authenticate,
  adminEndpointLimiter,
  checkAdminPermission,
  async (req: AuthenticatedRequest, res) => {
    try {
      const jobs = await backupService.getActiveJobs();

      loggers.system.info('Backup jobs requested', {
        userId: req.user!.id,
        activeJobs: jobs.filter(j => j.status === 'running').length,
        totalJobs: jobs.length
      });

      res.json({
        jobs,
        summary: {
          active: jobs.filter(j => j.status === 'running').length,
          completed: jobs.filter(j => j.status === 'completed').length,
          failed: jobs.filter(j => j.status === 'failed').length,
          total: jobs.length
        },
        timestamp: Date.now()
      });

    } catch (error: any) {
      loggers.system.error('Failed to retrieve backup jobs', error);
      res.status(500).json({
        error: 'Fehler beim Abrufen der Backup-Jobs',
        details: error?.message
      });
    }
  }
);

/**
 * @swagger
 * /api/backup/tables:
 *   get:
 *     summary: Database Table Information
 *     description: Returns intelligent analysis of database tables with backup strategies
 *     tags: [Backup Management]
 *     security:
 *       - bearerAuth: []
 *     responses:
 *       200:
 *         description: Database table analysis
 */
router.get('/tables',
  authenticate,
  adminEndpointLimiter,
  checkAdminPermission,
  async (req: AuthenticatedRequest, res) => {
    try {
      const tables = await backupService.getTableInfo();

      const summary = {
        totalTables: tables.length,
        totalSizeMB: Math.round(tables.reduce((sum, t) => sum + t.estimatedSizeMB, 0) * 100) / 100,
        categories: {} as Record<string, number>,
        strategies: {} as Record<string, number>,
        priorities: {
          high: tables.filter(t => t.backupPriority >= 8).length,
          medium: tables.filter(t => t.backupPriority >= 5 && t.backupPriority < 8).length,
          low: tables.filter(t => t.backupPriority < 5).length
        }
      };

      for (const table of tables) {
        summary.categories[table.category] = (summary.categories[table.category] || 0) + 1;
        summary.strategies[table.backupStrategy] = (summary.strategies[table.backupStrategy] || 0) + 1;
      }

      loggers.system.info('Backup table analysis requested', {
        userId: req.user!.id,
        totalTables: summary.totalTables,
        totalSizeMB: summary.totalSizeMB
      });

      res.json({
        tables: tables.sort((a, b) => b.backupPriority - a.backupPriority),
        summary,
        timestamp: Date.now()
      });

    } catch (error: any) {
      loggers.system.error('Failed to retrieve table information', error);
      res.status(500).json({
        error: 'Fehler beim Abrufen der Tabellen-Informationen',
        details: error?.message
      });
    }
  }
);

/**
 * @swagger
 * /api/backup/create:
 *   post:
 *     summary: Create Manual Backup
 *     description: Creates a manual backup with optional table selection
 *     tags: [Backup Management]
 *     security:
 *       - bearerAuth: []
 *     requestBody:
 *       required: false
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             properties:
 *               type:
 *                 type: string
 *                 enum: [manual, daily, weekly, monthly]
 *                 default: manual
 *               tables:
 *                 type: array
 *                 items:
 *                   type: string
 *                 description: Specific tables to backup (optional)
 *     responses:
 *       202:
 *         description: Backup job started
 *       400:
 *         description: Invalid request
 *       503:
 *         description: Backup system disabled or unavailable
 */
router.post('/create',
  authenticate,
  adminEndpointLimiter,
  checkAdminPermission,
  async (req: AuthenticatedRequest, res) => {
    try {
      const { type = 'manual', tables } = req.body;

      // Validate backup type
      if (!['manual', 'daily', 'weekly', 'monthly'].includes(type)) {
        return res.status(400).json({
          error: 'Ungültiger Backup-Typ',
          validTypes: ['manual', 'daily', 'weekly', 'monthly']
        });
      }

      // Validate tables if provided
      if (tables && (!Array.isArray(tables) || tables.some(t => typeof t !== 'string'))) {
        return res.status(400).json({
          error: 'Ungültiges Tabellen-Array',
          expected: 'Array von Tabellennamen (Strings)'
        });
      }

      loggers.system.info('Manual backup requested', {
        userId: req.user!.id,
        type,
        tablesSpecified: tables?.length || 'all',
        requestedBy: req.user!.username
      });

      // Start backup job (async)
      const job = await backupService.createBackup(type, tables);

      res.status(202).json({
        message: 'Backup-Job gestartet',
        job: {
          id: job.id,
          type: job.type,
          status: job.status,
          startTime: job.startTime,
          tables: job.tables.length
        },
        estimatedDuration: '2-10 Minuten'
      });

    } catch (error: any) {
      loggers.system.error('Failed to create backup', error);
      
      let statusCode = 500;
      let message = 'Fehler beim Erstellen des Backups';
      
      if (error.message.includes('disabled')) {
        statusCode = 503;
        message = 'Backup-System ist deaktiviert';
      }

      res.status(statusCode).json({
        error: message,
        details: error?.message
      });
    }
  }
);

/**
 * @swagger
 * /api/backup/stats:
 *   get:
 *     summary: Backup Statistics
 *     description: Returns detailed backup system statistics
 *     tags: [Backup Management]
 *     security:
 *       - bearerAuth: []
 *     responses:
 *       200:
 *         description: Backup statistics
 */
router.get('/stats',
  authenticate,
  adminEndpointLimiter,
  checkAdminPermission,
  async (req: AuthenticatedRequest, res) => {
    try {
      const stats = await backupService.getBackupStats();

      loggers.system.info('Backup statistics requested', {
        userId: req.user!.id,
        totalBackups: stats.totalBackups,
        totalSizeMB: Math.round(stats.totalSize / 1024 / 1024)
      });

      res.json({
        ...stats,
        totalSizeMB: Math.round(stats.totalSize / 1024 / 1024 * 100) / 100,
        diskUsage: {
          ...stats.diskUsage,
          usedMB: Math.round(stats.diskUsage.used / 1024 / 1024),
          availableMB: Math.round(stats.diskUsage.available / 1024 / 1024)
        },
        timestamp: Date.now()
      });

    } catch (error: any) {
      loggers.system.error('Failed to retrieve backup statistics', error);
      res.status(500).json({
        error: 'Fehler beim Abrufen der Backup-Statistiken',
        details: error?.message
      });
    }
  }
);

/**
 * @swagger
 * /api/backup/discover:
 *   post:
 *     summary: Rediscover Database Structure
 *     description: Forces rediscovery of database structure and table analysis
 *     tags: [Backup Management]
 *     security:
 *       - bearerAuth: []
 *     responses:
 *       200:
 *         description: Database structure rediscovered successfully
 */
router.post('/discover',
  authenticate,
  adminEndpointLimiter,
  checkAdminPermission,
  async (req: AuthenticatedRequest, res) => {
    try {
      loggers.system.info('Database structure rediscovery requested', {
        userId: req.user!.id,
        requestedBy: req.user!.username
      });

      const startTime = Date.now();
      await backupService.discoverDatabaseStructure();
      const duration = Date.now() - startTime;

      const tables = await backupService.getTableInfo();

      res.json({
        message: 'Datenbank-Struktur erfolgreich analysiert',
        duration: `${duration}ms`,
        tablesDiscovered: tables.length,
        summary: {
          categories: {} as Record<string, number>,
          totalSizeMB: Math.round(tables.reduce((sum, t) => sum + t.estimatedSizeMB, 0) * 100) / 100
        },
        timestamp: Date.now()
      });

    } catch (error: any) {
      loggers.system.error('Failed to rediscover database structure', error);
      res.status(500).json({
        error: 'Fehler bei der Datenbank-Analyse',
        details: error?.message
      });
    }
  }
);

export default router;