// 🔍 Query Performance Monitoring Dashboard
import { Router, Response, NextFunction } from 'express';
import { authenticate, AuthenticatedRequest } from '../middleware/authenticate';
import { hasPermission } from '../services/access-control.service';
import { adminEndpointLimiter } from '../middleware/rateLimiter';
import { 
  getQueryPerformanceStats, 
  getIndexRecommendations, 
  getQueryHealthStatus 
} from '../services/query-performance.service';
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
      error: 'Keine Berechtigung für Query-Performance-Monitoring'
    });
  }

  next();
}

/**
 * @swagger
 * /api/query-performance:
 *   get:
 *     summary: Query Performance Overview
 *     description: Provides comprehensive database query performance metrics
 *     tags: [Query Performance]
 *     security:
 *       - bearerAuth: []
 *     responses:
 *       200:
 *         description: Query performance statistics
 *         content:
 *           application/json:
 *             schema:
 *               type: object
 *               properties:
 *                 totalQueries:
 *                   type: number
 *                   description: Total queries in timeframe
 *                 slowQueries:
 *                   type: number
 *                   description: Number of slow queries
 *                 avgDuration:
 *                   type: number
 *                   description: Average query duration in ms
 *                 errorRate:
 *                   type: number
 *                   description: Error rate as percentage
 *                 topSlowQueries:
 *                   type: array
 *                   description: Top slow query operations
 */
router.get('/',
  authenticate,
  adminEndpointLimiter,
  checkAdminPermission,
  async (req: AuthenticatedRequest, res) => {
    try {
      const timeframe = parseInt(req.query.timeframe as string) || 3600000; // 1h default
      const stats = getQueryPerformanceStats(timeframe);
      
      loggers.system.info('Query Performance Stats requested', {
        userId: req.user!.id,
        timeframe: `${timeframe / 1000}s`,
        totalQueries: stats.totalQueries
      });

      res.json({
        ...stats,
        timeframe,
        timestamp: Date.now()
      });

    } catch (error: any) {
      loggers.system.error('Failed to retrieve query performance stats', error);
      res.status(500).json({
        error: 'Fehler beim Abrufen der Query-Performance-Statistiken',
        details: error?.message
      });
    }
  }
);

/**
 * @swagger
 * /api/query-performance/health:
 *   get:
 *     summary: Query Performance Health Status
 *     description: Returns health status of database query performance
 *     tags: [Query Performance]
 *     security:
 *       - bearerAuth: []
 *     responses:
 *       200:
 *         description: Query performance health status
 */
router.get('/health',
  authenticate,
  adminEndpointLimiter,
  checkAdminPermission,
  async (req: AuthenticatedRequest, res) => {
    try {
      const healthStatus = getQueryHealthStatus();
      
      loggers.system.info('Query Performance Health Check requested', {
        userId: req.user!.id,
        status: healthStatus.status,
        avgResponseTime: healthStatus.avgResponseTime
      });

      res.json(healthStatus);

    } catch (error: any) {
      loggers.system.error('Failed to retrieve query performance health', error);
      res.status(500).json({
        error: 'Fehler beim Abrufen des Query-Performance-Health-Status',
        details: error?.message
      });
    }
  }
);

/**
 * @swagger
 * /api/query-performance/recommendations:
 *   get:
 *     summary: Database Index Recommendations
 *     description: Returns recommendations for database indexes to improve performance
 *     tags: [Query Performance]
 *     security:
 *       - bearerAuth: []
 *     responses:
 *       200:
 *         description: Index recommendations for database optimization
 */
router.get('/recommendations',
  authenticate,
  adminEndpointLimiter,
  checkAdminPermission,
  async (req: AuthenticatedRequest, res) => {
    try {
      const recommendations = getIndexRecommendations();
      
      loggers.system.info('Index Recommendations requested', {
        userId: req.user!.id,
        recommendationCount: recommendations.length
      });

      res.json({
        recommendations,
        timestamp: Date.now(),
        note: 'Execute index creation during low-traffic periods',
        warning: 'Always test index impact on staging environment first'
      });

    } catch (error: any) {
      loggers.system.error('Failed to retrieve index recommendations', error);
      res.status(500).json({
        error: 'Fehler beim Abrufen der Index-Empfehlungen',
        details: error?.message
      });
    }
  }
);

/**
 * @swagger
 * /api/query-performance/slow-queries:
 *   get:
 *     summary: Top Slow Queries
 *     description: Returns detailed information about the slowest database queries
 *     tags: [Query Performance]
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - in: query
 *         name: limit
 *         schema:
 *           type: integer
 *           default: 20
 *         description: Maximum number of slow queries to return
 *       - in: query
 *         name: timeframe
 *         schema:
 *           type: integer
 *           default: 3600000
 *         description: Timeframe in milliseconds (default 1 hour)
 *     responses:
 *       200:
 *         description: List of slowest database queries with recommendations
 */
router.get('/slow-queries',
  authenticate,
  adminEndpointLimiter,
  checkAdminPermission,
  async (req: AuthenticatedRequest, res) => {
    try {
      const limit = parseInt(req.query.limit as string) || 20;
      const timeframe = parseInt(req.query.timeframe as string) || 3600000;
      
      const stats = getQueryPerformanceStats(timeframe);
      const slowQueries = stats.topSlowQueries.slice(0, limit);
      
      loggers.system.info('Slow Queries Analysis requested', {
        userId: req.user!.id,
        timeframe: `${timeframe / 1000}s`,
        limit,
        slowQueryCount: slowQueries.length
      });

      res.json({
        slowQueries,
        summary: {
          totalQueries: stats.totalQueries,
          slowQueryCount: stats.slowQueries,
          slowQueryPercentage: Math.round((stats.slowQueries / stats.totalQueries) * 100 * 100) / 100
        },
        timeframe,
        timestamp: Date.now()
      });

    } catch (error: any) {
      loggers.system.error('Failed to retrieve slow queries analysis', error);
      res.status(500).json({
        error: 'Fehler beim Abrufen der Slow-Query-Analyse',
        details: error?.message
      });
    }
  }
);

/**
 * @swagger
 * /api/query-performance/summary:
 *   get:
 *     summary: Quick Performance Summary
 *     description: Returns a concise summary of database performance metrics
 *     tags: [Query Performance]
 *     security:
 *       - bearerAuth: []
 *     responses:
 *       200:
 *         description: Quick performance summary for dashboards
 */
router.get('/summary',
  authenticate,
  adminEndpointLimiter,
  checkAdminPermission,
  async (req: AuthenticatedRequest, res) => {
    try {
      const stats = getQueryPerformanceStats();
      const health = getQueryHealthStatus();
      
      const summary = {
        status: health.status,
        avgResponseTime: stats.avgDuration,
        totalQueries: stats.totalQueries,
        slowQueries: stats.slowQueries,
        errorRate: stats.errorRate,
        recommendations: health.recommendations.length,
        timestamp: Date.now()
      };

      loggers.system.info('Performance Summary requested', {
        userId: req.user!.id,
        status: summary.status,
        totalQueries: summary.totalQueries
      });

      res.json(summary);

    } catch (error: any) {
      loggers.system.error('Failed to retrieve performance summary', error);
      res.status(500).json({
        error: 'Fehler beim Abrufen der Performance-Zusammenfassung',
        details: error?.message
      });
    }
  }
);

export default router;