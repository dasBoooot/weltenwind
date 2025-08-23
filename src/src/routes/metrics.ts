import express from 'express';
import { authenticate, AuthenticatedRequest } from '../middleware/authenticate';
import { hasPermission } from '../services/access-control.service';
import { adminEndpointLimiter } from '../middleware/rateLimiter';
import { getAllMetrics, getMetricsStats } from '../services/metrics.service';
import { loggers } from '../config/logger.config';

const router = express.Router();

/**
 * @swagger
 * /api/metrics:
 *   get:
 *     summary: Comprehensive System Metrics
 *     description: Returns detailed performance and usage metrics (Admin only)
 *     tags:
 *       - Metrics
 *     security:
 *       - bearerAuth: []
 *     responses:
 *       200:
 *         description: Comprehensive metrics data
 *       403:
 *         description: Insufficient permissions
 *       500:
 *         description: Server error
 */
router.get('/',
  authenticate,
  adminEndpointLimiter,
  async (req: AuthenticatedRequest, res) => {
    // Permission-Check: Nur Admins dürfen Metriken einsehen
    const hasAdminPerm = await hasPermission(req.user!.id, 'system.metrics', { type: 'global', objectId: '*' });
    if (!hasAdminPerm) {
      return res.status(403).json({ 
        error: 'Keine Berechtigung für Metrics-Zugriff',
        required_permission: 'system.logs'
      });
    }

    try {
      const metrics = await getAllMetrics();
      
      loggers.system.info('📊 Metrics abgerufen', {
        userId: req.user!.id,
        username: req.user!.username,
        timestamp: new Date().toISOString()
      });

      res.json({
        status: 'success',
        data: metrics,
        meta: {
          generatedAt: new Date().toISOString(),
          collectionPeriod: '24h',
          dataRetention: '24h rolling window'
        }
      });

    } catch (error: any) {
      loggers.system.error('❌ Fehler beim Abrufen der Metrics', error, {
        userId: req.user?.id,
        endpoint: req.originalUrl
      });

      res.status(500).json({
        error: 'Metrics-Abruf-Fehler',
        details: error?.message || 'Unknown error'
      });
    }
  }
);

/**
 * @swagger
 * /api/metrics/summary:
 *   get:
 *     summary: Metrics Summary Dashboard
 *     description: Returns condensed metrics for dashboard display (Admin only)
 *     tags:
 *       - Metrics
 *     security:
 *       - bearerAuth: []
 *     responses:
 *       200:
 *         description: Metrics summary
 */
router.get('/summary',
  authenticate,
  adminEndpointLimiter,
  async (req: AuthenticatedRequest, res) => {
    const hasAdminPerm = await hasPermission(req.user!.id, 'system.metrics', { type: 'global', objectId: '*' });
    if (!hasAdminPerm) {
      return res.status(403).json({ error: 'Keine Berechtigung für Metrics-Summary' });
    }

    try {
      const fullMetrics = await getAllMetrics();
      
      // Kondensierte Dashboard-Ansicht
      const summary = {
        timestamp: fullMetrics.timestamp,
        system: {
          status: fullMetrics.system.databaseHealth.status,
          uptime: fullMetrics.system.uptime,
          memoryUsage: fullMetrics.system.memoryUsage.percentage,
          databaseResponseTime: fullMetrics.system.databaseHealth.responseTime
        },
        api: {
          totalRequests24h: fullMetrics.api.requestsLast24h,
          avgResponseTime: fullMetrics.api.avgResponseTime,
          errorRate: fullMetrics.api.errorRate,
          topEndpoints: fullMetrics.api.slowestEndpoints.slice(0, 5)
        },
        users: {
          totalUsers: fullMetrics.users.totalUsers,
          activeUsers: fullMetrics.users.activeUsers,
          newUsersToday: fullMetrics.users.newUsersToday,
          loginSuccessRate: fullMetrics.users.loginAttempts > 0 
            ? Math.round((fullMetrics.users.successfulLogins / fullMetrics.users.loginAttempts) * 100)
            : 100
        },
        game: {
          totalWorlds: fullMetrics.game.totalWorlds,
          activeWorlds: fullMetrics.game.activeWorlds,
          totalInvites: fullMetrics.game.totalInvites,
          inviteAcceptanceRate: fullMetrics.game.totalInvites > 0
            ? Math.round((fullMetrics.game.invitesAccepted / fullMetrics.game.totalInvites) * 100)
            : 0
        },
        alerts: generateAlerts(fullMetrics)
      };

      res.json({
        status: 'success',
        data: summary,
        refreshInterval: 30 // Empfohlenes Refresh-Intervall in Sekunden
      });

    } catch (error: any) {
      loggers.system.error('❌ Fehler beim Abrufen der Metrics-Summary', error);
      res.status(500).json({
        error: 'Metrics-Summary-Fehler',
        details: error?.message || 'Unknown error'
      });
    }
  }
);

/**
 * @swagger
 * /api/metrics/api:
 *   get:
 *     summary: API-specific Metrics
 *     description: Returns detailed API performance metrics (Admin only)
 *     tags:
 *       - Metrics
 */
router.get('/api',
  authenticate,
  adminEndpointLimiter,
  async (req: AuthenticatedRequest, res) => {
    const hasAdminPerm = await hasPermission(req.user!.id, 'system.metrics', { type: 'global', objectId: '*' });
    if (!hasAdminPerm) {
      return res.status(403).json({ error: 'Keine Berechtigung für API-Metrics' });
    }

    try {
      const fullMetrics = await getAllMetrics();
      
      res.json({
        status: 'success',
        data: {
          api: fullMetrics.api,
          performance: fullMetrics.performance,
          timestamp: fullMetrics.timestamp
        },
        insights: {
          mostUsedEndpoint: Object.entries(fullMetrics.api.requestsByEndpoint)
            .sort(([,a], [,b]) => b - a)[0]?.[0] || 'N/A',
          mostUsedMethod: Object.entries(fullMetrics.api.requestsByMethod)
            .sort(([,a], [,b]) => b - a)[0]?.[0] || 'N/A',
          errorHotspots: fullMetrics.api.slowestEndpoints
            .filter(endpoint => endpoint.avgTime > 1000)
            .map(e => e.endpoint)
        }
      });

    } catch (error: any) {
      loggers.system.error('❌ Fehler beim Abrufen der API-Metrics', error);
      res.status(500).json({
        error: 'API-Metrics-Fehler',
        details: error?.message || 'Unknown error'
      });
    }
  }
);

/**
 * @swagger
 * /api/metrics/users:
 *   get:
 *     summary: User-specific Metrics
 *     description: Returns user behavior and engagement metrics (Admin only)
 *     tags:
 *       - Metrics
 */
router.get('/users',
  authenticate,
  adminEndpointLimiter,
  async (req: AuthenticatedRequest, res) => {
    const hasAdminPerm = await hasPermission(req.user!.id, 'system.metrics', { type: 'global', objectId: '*' });
    if (!hasAdminPerm) {
      return res.status(403).json({ error: 'Keine Berechtigung für User-Metrics' });
    }

    try {
      const fullMetrics = await getAllMetrics();
      
      res.json({
        status: 'success',
        data: {
          users: fullMetrics.users,
          timestamp: fullMetrics.timestamp
        },
        insights: {
          userGrowthToday: fullMetrics.users.newUsersToday,
          userEngagement: fullMetrics.users.totalUsers > 0
            ? Math.round((fullMetrics.users.activeUsers / fullMetrics.users.totalUsers) * 100)
            : 0,
          securityIssues: {
            accountLockouts: fullMetrics.users.accountLockouts,
            failedLoginRate: fullMetrics.users.loginAttempts > 0
              ? Math.round((fullMetrics.users.failedLogins / fullMetrics.users.loginAttempts) * 100)
              : 0
          }
        }
      });

    } catch (error: any) {
      loggers.system.error('❌ Fehler beim Abrufen der User-Metrics', error);
      res.status(500).json({
        error: 'User-Metrics-Fehler',
        details: error?.message || 'Unknown error'
      });
    }
  }
);

/**
 * @swagger
 * /api/metrics/game:
 *   get:
 *     summary: Game-specific Metrics
 *     description: Returns game performance and engagement metrics (Admin only)
 *     tags:
 *       - Metrics
 */
router.get('/game',
  authenticate,
  adminEndpointLimiter,
  async (req: AuthenticatedRequest, res) => {
    const hasAdminPerm = await hasPermission(req.user!.id, 'system.logs', { type: 'global', objectId: '*' });
    if (!hasAdminPerm) {
      return res.status(403).json({ error: 'Keine Berechtigung für Game-Metrics' });
    }

    try {
      const fullMetrics = await getAllMetrics();
      
      res.json({
        status: 'success',
        data: {
          game: fullMetrics.game,
          timestamp: fullMetrics.timestamp
        },
        insights: {
          worldEngagement: fullMetrics.game.totalWorlds > 0
            ? Math.round((fullMetrics.game.activeWorlds / fullMetrics.game.totalWorlds) * 100)
            : 0,
          inviteEffectiveness: fullMetrics.game.totalInvites > 0
            ? Math.round((fullMetrics.game.invitesAccepted / fullMetrics.game.totalInvites) * 100)
            : 0,
          communityGrowth: {
            preRegistrations: fullMetrics.game.preRegistrations,
            pendingInvites: fullMetrics.game.invitesPending
          }
        }
      });

    } catch (error: any) {
      loggers.system.error('❌ Fehler beim Abrufen der Game-Metrics', error);
      res.status(500).json({
        error: 'Game-Metrics-Fehler',
        details: error?.message || 'Unknown error'
      });
    }
  }
);

/**
 * @swagger
 * /api/metrics/system:
 *   get:
 *     summary: System Health Metrics
 *     description: Returns system performance and health metrics (Admin only)
 *     tags:
 *       - Metrics
 */
router.get('/system',
  authenticate,
  adminEndpointLimiter,
  async (req: AuthenticatedRequest, res) => {
    const hasAdminPerm = await hasPermission(req.user!.id, 'system.logs', { type: 'global', objectId: '*' });
    if (!hasAdminPerm) {
      return res.status(403).json({ error: 'Keine Berechtigung für System-Metrics' });
    }

    try {
      const fullMetrics = await getAllMetrics();
      const stats = getMetricsStats();
      
      res.json({
        status: 'success',
        data: {
          system: fullMetrics.system,
          performance: fullMetrics.performance,
          timestamp: fullMetrics.timestamp
        },
        collection: {
          stats,
          dataPoints: stats.collected,
          uptimeFormatted: formatUptime(fullMetrics.system.uptime)
        },
        health: {
          overall: determineOverallHealth(fullMetrics),
          database: fullMetrics.system.databaseHealth.status,
          memory: fullMetrics.system.memoryUsage.percentage < 80 ? 'healthy' : 'warning',
          performance: fullMetrics.api.avgResponseTime < 200 ? 'healthy' : 'degraded'
        }
      });

    } catch (error: any) {
      loggers.system.error('❌ Fehler beim Abrufen der System-Metrics', error);
      res.status(500).json({
        error: 'System-Metrics-Fehler',
        details: error?.message || 'Unknown error'
      });
    }
  }
);

// 🚨 Alert-Generator für wichtige Metriken
function generateAlerts(metrics: any): Array<{type: string; severity: 'info' | 'warning' | 'critical'; message: string}> {
  const alerts = [];

  // Performance-Alerts
  if (metrics.api.avgResponseTime > 500) {
    alerts.push({
      type: 'performance',
      severity: 'warning' as const,
      message: `Hohe API-Response-Zeit: ${metrics.api.avgResponseTime}ms`
    });
  }

  if (metrics.api.errorRate > 5) {
    alerts.push({
      type: 'errors',
      severity: 'critical' as const,
      message: `Hohe Fehlerrate: ${metrics.api.errorRate}%`
    });
  }

  // System-Alerts
  if (metrics.system.memoryUsage.percentage > 90) {
    alerts.push({
      type: 'memory',
      severity: 'critical' as const,
      message: `Kritische Speicher-Nutzung: ${metrics.system.memoryUsage.percentage}%`
    });
  } else if (metrics.system.memoryUsage.percentage > 80) {
    alerts.push({
      type: 'memory',
      severity: 'warning' as const,
      message: `Hohe Speicher-Nutzung: ${metrics.system.memoryUsage.percentage}%`
    });
  }

  // Database-Alerts
  if (metrics.system.databaseHealth.status === 'down') {
    alerts.push({
      type: 'database',
      severity: 'critical' as const,
      message: 'Datenbank nicht erreichbar'
    });
  } else if (metrics.system.databaseHealth.status === 'degraded') {
    alerts.push({
      type: 'database',
      severity: 'warning' as const,
      message: `Langsame Datenbank-Response: ${metrics.system.databaseHealth.responseTime}ms`
    });
  }

  // Security-Alerts
  if (metrics.users.accountLockouts > 0) {
    alerts.push({
      type: 'security',
      severity: 'warning' as const,
      message: `${metrics.users.accountLockouts} gesperrte Accounts`
    });
  }

  return alerts;
}

// 🏥 Overall-Health-Bestimmung
function determineOverallHealth(metrics: any): 'healthy' | 'warning' | 'critical' {
  const alerts = generateAlerts(metrics);
  
  if (alerts.some(alert => alert.severity === 'critical')) {
    return 'critical';
  }
  
  if (alerts.some(alert => alert.severity === 'warning')) {
    return 'warning';
  }
  
  return 'healthy';
}

// ⏰ Uptime-Formatierung
function formatUptime(seconds: number): string {
  const days = Math.floor(seconds / 86400);
  const hours = Math.floor((seconds % 86400) / 3600);
  const minutes = Math.floor((seconds % 3600) / 60);
  
  const parts = [];
  if (days > 0) parts.push(`${days}d`);
  if (hours > 0) parts.push(`${hours}h`);
  if (minutes > 0) parts.push(`${minutes}m`);
  
  return parts.join(' ') || '< 1m';
}

export default router;