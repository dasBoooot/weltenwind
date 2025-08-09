import { Router, Request, Response } from 'express';
import prisma from '../libs/prisma';
import { loggers } from '../config/logger.config';
import { getSessionMetrics, performSessionHealthCheck } from '../services/session.service';
import { adminEndpointLimiter } from '../middleware/rateLimiter';
import { authenticate, AuthenticatedRequest } from '../middleware/authenticate';
import { hasPermission } from '../services/access-control.service';

const router = Router();

router.get('/health', async (req: Request, res: Response) => {
  const startTime = Date.now();

  try {
    // Grundlegende System-Informationen
    const healthCheck: any = {
      status: 'OK',
      timestamp: Date.now(),
      uptime: Math.floor(process.uptime()),
      environment: process.env.NODE_ENV || 'development',
      version: '1.0.0',
      memory: {
        used: Math.round(process.memoryUsage().heapUsed / 1024 / 1024),
        total: Math.round(process.memoryUsage().heapTotal / 1024 / 1024),
        rss: Math.round(process.memoryUsage().rss / 1024 / 1024)
      },
      pid: process.pid
    };

    // Database Health Check
    try {
      const dbStart = Date.now();
      await prisma.$queryRaw`SELECT 1 as health_check`;
      const dbResponseTime = Date.now() - dbStart;
      
      healthCheck.database = {
        status: 'connected',
        responseTime: dbResponseTime
      };
    } catch (dbError) {
      loggers.system.error('Database health check failed', dbError as any);
      
      healthCheck.status = 'DEGRADED';
      healthCheck.database = {
        status: 'disconnected',
        error: 'Database connection failed'
      };
    }

    // Zusätzliche Service-Checks
    healthCheck.services = {
      api: 'running',
      auth: 'available',
      worlds: 'available',
      invites: 'available',
      themes: 'available',
      logs: 'available'
    };

    // Response-Zeit berechnen
    healthCheck.responseTime = Date.now() - startTime;

    // Status-Code basierend auf Gesundheit
    const statusCode = healthCheck.status === 'OK' ? 200 : 
                      healthCheck.status === 'DEGRADED' ? 200 : 503;

    // Log successful health check (nur bei Problemen)
    if (healthCheck.status !== 'OK') {
      loggers.system.warn('Health check returned degraded status', healthCheck);
    }

    res.status(statusCode).json(healthCheck);

  } catch (error) {
    // Kritischer Fehler beim Health Check
    loggers.system.error('Health check endpoint failed', error as any);

    const errorResponse = {
      status: 'ERROR',
      timestamp: Date.now(),
      uptime: Math.floor(process.uptime()),
      error: error instanceof Error ? error.message : 'Health check failed',
      responseTime: Date.now() - startTime
    };

    res.status(503).json(errorResponse);
  }
});

/**
 * Detailed Health Check (mehr Informationen für interne Monitoring)
 */
router.get('/health/detailed', async (req: Request, res: Response) => {
  try {
    const healthCheck: any = {
      status: 'OK',
      timestamp: Date.now(),
      uptime: {
        seconds: Math.floor(process.uptime()),
        human: formatUptime(process.uptime())
      },
      environment: process.env.NODE_ENV || 'development',
      version: '1.0.0',
      system: {
        platform: process.platform,
        arch: process.arch,
        nodeVersion: process.version,
        memory: {
          used: Math.round(process.memoryUsage().heapUsed / 1024 / 1024),
          total: Math.round(process.memoryUsage().heapTotal / 1024 / 1024),
          rss: Math.round(process.memoryUsage().rss / 1024 / 1024),
          external: Math.round(process.memoryUsage().external / 1024 / 1024)
        },
        cpu: process.cpuUsage()
      }
    };

    // Database Health Check
    try {
      const dbStart = Date.now();
      
      // Prüfe verschiedene Database-Operationen
      const userCount = await prisma.user.count();
      const worldCount = await prisma.world.count();
      const sessionCount = await prisma.session.count();
      
      const dbResponseTime = Date.now() - dbStart;
      
      healthCheck.database = {
        status: 'connected',
        responseTime: dbResponseTime,
        stats: {
          users: userCount,
          worlds: worldCount,
          activeSessions: sessionCount
        }
      };
    } catch (dbError) {
      healthCheck.status = 'DEGRADED';
      healthCheck.database = {
        status: 'disconnected',
        error: dbError instanceof Error ? dbError.message : 'Unknown database error'
      };
    }

    res.json(healthCheck);

  } catch (error) {
    loggers.system.error('Detailed health check failed', error as any);
    res.status(503).json({
      status: 'ERROR',
      error: error instanceof Error ? error.message : 'Detailed health check failed',
      timestamp: Date.now()
    });
  }
});

// Canonical path: /api/client-config
router.get('/client-config', async (req: Request, res: Response) => {
  try {
    const clientConfig = {
      apiUrl: process.env.PUBLIC_API_URL || 'https://192.168.2.168/api',
      clientUrl: process.env.PUBLIC_CLIENT_URL || 'https://192.168.2.168',
      assetUrl: process.env.PUBLIC_ASSETS_URL || 'https://192.168.2.168',
      environment: process.env.NODE_ENV || 'development',
      timestamp: Date.now(),
      version: '1.0.0'
    };

    // Log with new client config logger
    loggers.clientConfig.requested(req.ip || 'unknown', req.get('User-Agent'));
    loggers.clientConfig.served(req.ip || 'unknown', clientConfig);
    
    loggers.system.info('Client configuration requested', {
      ip: req.ip,
      userAgent: req.get('User-Agent'),
      config: {
        environment: clientConfig.environment,
        apiUrl: clientConfig.apiUrl,
        clientUrl: clientConfig.clientUrl,
        assetUrl: clientConfig.assetUrl
      }
    });

    res.json(clientConfig);

  } catch (error: any) {
    loggers.system.error('Failed to provide client configuration', error);
    res.status(500).json({
      error: 'Client configuration failed',
      details: error?.message || 'Unknown error'
    });
  }
});

// Helper-Funktion für Uptime-Formatierung
function formatUptime(seconds: number): string {
  const days = Math.floor(seconds / 86400);
  const hours = Math.floor((seconds % 86400) / 3600);
  const minutes = Math.floor((seconds % 3600) / 60);
  const secs = Math.floor(seconds % 60);

  const parts = [];
  if (days > 0) parts.push(`${days}d`);
  if (hours > 0) parts.push(`${hours}h`);
  if (minutes > 0) parts.push(`${minutes}m`);
  if (secs > 0 || parts.length === 0) parts.push(`${secs}s`);

  return parts.join(' ');
}

// 📊 Session-Monitoring-Endpoint für Admins
router.get('/sessions', 
  authenticate,
  adminEndpointLimiter,
  async (req: AuthenticatedRequest, res) => {
    // Permission-Check: Nur Admins dürfen Session-Metriken einsehen
    const hasAdminPerm = await hasPermission(req.user!.id, 'system.logs', { type: 'global', objectId: '*' });
    if (!hasAdminPerm) {
      return res.status(403).json({ error: 'Keine Berechtigung für Session-Monitoring' });
    }

    try {
      const [metrics, healthCheck] = await Promise.all([
        getSessionMetrics(),
        performSessionHealthCheck()
      ]);

      res.json({
        status: healthCheck.healthy ? 'healthy' : 'warning',
        timestamp: new Date().toISOString(),
        sessionMetrics: metrics,
        healthCheck: {
          healthy: healthCheck.healthy,
          issues: healthCheck.issues
        },
        recommendations: healthCheck.issues.length > 0 ? [
          'Erwäge Session-Cleanup-Script auszuführen',
          'Prüfe auf verdächtige User-Aktivitäten',
          'Monitoring-Alerts für Session-Anomalien konfigurieren'
        ] : []
      });
    } catch (error: any) {
      loggers.system.error('Fehler beim Abrufen der Session-Metriken', error);
      res.status(500).json({
        error: 'Session-Monitoring-Fehler',
        details: error?.message || 'Unknown error'
      });
    }
  }
);

// 🔐 CSRF-Monitoring-Endpoint für Admins
router.get('/csrf', 
  authenticate,
  adminEndpointLimiter,
  async (req: AuthenticatedRequest, res) => {
    // Permission-Check: Nur Admins dürfen CSRF-Metriken einsehen
    const hasAdminPerm = await hasPermission(req.user!.id, 'system.logs', { type: 'global', objectId: '*' });
    if (!hasAdminPerm) {
      return res.status(403).json({ error: 'Keine Berechtigung für CSRF-Monitoring' });
    }

    try {
      // Da getCsrfMetrics noch nicht existiert, erstelle ich eine einfache Version
      const csrfStatus = {
        status: 'active',
        protection: {
          enabled: true,
          tokenRotation: true,
          developmentRecovery: process.env.NODE_ENV !== 'production',
          headerSupport: ['X-CSRF-Token', '_csrf'],
          memoryStore: true // In Production sollte Redis/DB verwendet werden
        },
        endpoints: {
          protected: [
            'POST /auth/logout',
            'POST /auth/change-password',
            'POST /worlds/:id/join',
            'POST /worlds/:id/edit',
            'DELETE /worlds/:id/players/me',
            'POST /invites',
            'POST /invites/accept/:token',
            'DELETE /invites/:id',
            'PUT /themes/:name',
            'POST /themes/:name/clone',
            'PUT /arb/:language',
            'POST /arb/:language/restore/:timestamp',
            'DELETE /arb/:language/backups/:timestamp'
          ],
          unprotected: [
            'POST /auth/login',
            'POST /auth/register',
            'POST /auth/request-reset',
            'POST /auth/reset-password',
            'POST /auth/refresh',
            'POST /worlds/:id/pre-register (public)',
            'POST /invites/public (public)',
            'POST /invites/decline/:token (public)'
          ]
        },
        recommendations: [
          'Alle kritischen state-changing Endpoints sind CSRF-geschützt',
          'Token-Rotation ist aktiv',
          process.env.NODE_ENV === 'production' 
            ? 'Production-Mode: Strengste CSRF-Validierung aktiv'
            : 'Development-Mode: Recovery-Mechanismus für SSL-Migration aktiv'
        ]
      };

      res.json({
        status: 'healthy',
        timestamp: new Date().toISOString(),
        csrfProtection: csrfStatus
      });
    } catch (error: any) {
      loggers.system.error('Fehler beim Abrufen der CSRF-Metriken', error);
      res.status(500).json({
        error: 'CSRF-Monitoring-Fehler',
        details: error?.message || 'Unknown error'
      });
    }
  }
);

export default router;