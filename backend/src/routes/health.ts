import { Router, Request, Response } from 'express';
import prisma from '../libs/prisma';
import { loggers } from '../config/logger.config';

const router = Router();

/**
 * @swagger
 * /api/health:
 *   get:
 *     summary: Health Check Endpoint
 *     description: Returns the health status of the Weltenwind Backend API
 *     tags:
 *       - System
 *     responses:
 *       200:
 *         description: Service is healthy
 *         content:
 *           application/json:
 *             schema:
 *               type: object
 *               properties:
 *                 status:
 *                   type: string
 *                   example: "OK"
 *                 timestamp:
 *                   type: number
 *                   example: 1640995200000
 *                 uptime:
 *                   type: number
 *                   example: 12345.67
 *                 environment:
 *                   type: string
 *                   example: "production"
 *                 version:
 *                   type: string
 *                   example: "1.0.0"
 *                 memory:
 *                   type: object
 *                   properties:
 *                     used:
 *                       type: number
 *                       example: 45
 *                     total:
 *                       type: number
 *                       example: 128
 *                 database:
 *                   type: object
 *                   properties:
 *                     status:
 *                       type: string
 *                       example: "connected"
 *                     responseTime:
 *                       type: number
 *                       example: 12.34
 *       503:
 *         description: Service is unhealthy
 *         content:
 *           application/json:
 *             schema:
 *               type: object
 *               properties:
 *                 status:
 *                   type: string
 *                   example: "ERROR"
 *                 error:
 *                   type: string
 *                   example: "Database connection failed"
 */
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
      loggers.system.error('Database health check failed', { error: dbError });
      
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
    loggers.system.error('Health check endpoint failed', { 
      error: error instanceof Error ? error.message : 'Unknown error',
      stack: error instanceof Error ? error.stack : undefined
    });

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
    loggers.system.error('Detailed health check failed', { error });
    res.status(503).json({
      status: 'ERROR',
      error: error instanceof Error ? error.message : 'Detailed health check failed',
      timestamp: Date.now()
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

export default router;