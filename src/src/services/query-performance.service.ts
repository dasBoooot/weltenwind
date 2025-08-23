// 🔍 Query Performance Analysis Service
import { PrismaClient } from '@prisma/client';
import { loggers } from '../config/logger.config';

const prisma = new PrismaClient();

// 📊 Query Performance Metrics
interface QueryMetric {
  operation: string;
  table: string;
  duration: number;
  timestamp: number;
  success: boolean;
  error?: string;
  params?: any;
  resultCount?: number;
}

interface SlowQuery {
  operation: string;
  table: string;
  avgDuration: number;
  count: number;
  maxDuration: number;
  lastOccurrence: number;
  recommendations: string[];
}

interface IndexRecommendation {
  table: string;
  columns: string[];
  reason: string;
  impact: 'high' | 'medium' | 'low';
  query: string;
}

// 🎯 In-Memory Query Metrics Store
class QueryPerformanceTracker {
  private metrics: QueryMetric[] = [];
  private slowQueryThreshold = 100; // ms
  private maxMetricsStore = 10000;

  // 📝 Query ausführen und Performance tracken
  async trackQuery<T>(
    operation: string,
    table: string,
    queryFn: () => Promise<T>,
    params?: any
  ): Promise<T> {
    const startTime = Date.now();
    const timestamp = Date.now();

    try {
      const result = await queryFn();
      const duration = Date.now() - startTime;
      
      // Anzahl Ergebnisse ermitteln
      let resultCount: number | undefined;
      if (Array.isArray(result)) {
        resultCount = result.length;
      } else if (typeof result === 'number') {
        resultCount = result;
      }

      const metric: QueryMetric = {
        operation,
        table,
        duration,
        timestamp,
        success: true,
        params,
        resultCount
      };

      this.addMetric(metric);

      // Slow Query Detection
      if (duration > this.slowQueryThreshold) {
        loggers.system.warn('Slow query detected', {
          operation,
          table,
          duration: `${duration}ms`,
          params,
          resultCount,
          threshold: `${this.slowQueryThreshold}ms`
        });
      }

      return result;
    } catch (error: any) {
      const duration = Date.now() - startTime;
      
      const metric: QueryMetric = {
        operation,
        table,
        duration,
        timestamp,
        success: false,
        error: error.message,
        params
      };

      this.addMetric(metric);
      
      loggers.system.error('Query execution failed', {
        operation,
        table,
        duration: `${duration}ms`,
        error: error.message,
        params
      });

      throw error;
    }
  }

  private addMetric(metric: QueryMetric) {
    this.metrics.push(metric);
    
    // Speicher-Management: Älteste Metriken löschen
    if (this.metrics.length > this.maxMetricsStore) {
      this.metrics = this.metrics.slice(-this.maxMetricsStore);
    }
  }

  // 📈 Performance-Statistiken berechnen
  getPerformanceStats(timeframe: number = 3600000): {
    totalQueries: number;
    slowQueries: number;
    avgDuration: number;
    maxDuration: number;
    errorRate: number;
    topSlowQueries: SlowQuery[];
  } {
    const now = Date.now();
    const relevantMetrics = this.metrics.filter(m => m.timestamp > now - timeframe);

    if (relevantMetrics.length === 0) {
      return {
        totalQueries: 0,
        slowQueries: 0,
        avgDuration: 0,
        maxDuration: 0,
        errorRate: 0,
        topSlowQueries: []
      };
    }

    const slowQueries = relevantMetrics.filter(m => m.duration > this.slowQueryThreshold);
    const totalDuration = relevantMetrics.reduce((sum, m) => sum + m.duration, 0);
    const errors = relevantMetrics.filter(m => !m.success);

    // Slow Queries nach Operation/Tabelle gruppieren
    const slowQueryGroups: { [key: string]: QueryMetric[] } = {};
    slowQueries.forEach(metric => {
      const key = `${metric.operation}_${metric.table}`;
      if (!slowQueryGroups[key]) {
        slowQueryGroups[key] = [];
      }
      slowQueryGroups[key].push(metric);
    });

    const topSlowQueries: SlowQuery[] = Object.entries(slowQueryGroups)
      .map(([key, metrics]) => {
        const durations = metrics.map(m => m.duration);
        const avgDuration = durations.reduce((sum, d) => sum + d, 0) / durations.length;
        const maxDuration = Math.max(...durations);
        const lastOccurrence = Math.max(...metrics.map(m => m.timestamp));

        return {
          operation: metrics[0].operation,
          table: metrics[0].table,
          avgDuration,
          count: metrics.length,
          maxDuration,
          lastOccurrence,
          recommendations: this.generateRecommendations(metrics[0])
        };
      })
      .sort((a, b) => b.avgDuration - a.avgDuration)
      .slice(0, 10);

    return {
      totalQueries: relevantMetrics.length,
      slowQueries: slowQueries.length,
      avgDuration: Math.round(totalDuration / relevantMetrics.length * 100) / 100,
      maxDuration: Math.max(...relevantMetrics.map(m => m.duration)),
      errorRate: Math.round((errors.length / relevantMetrics.length) * 100 * 100) / 100,
      topSlowQueries
    };
  }

  // 💡 Recommendations für Query-Optimierung
  private generateRecommendations(metric: QueryMetric): string[] {
    const recommendations: string[] = [];
    const { operation, table } = metric;

    // Basis-Empfehlungen basierend auf Operation und Tabelle
    if (operation.includes('findMany') || operation.includes('findFirst')) {
      if (table === 'session') {
        recommendations.push('Add index on (userId, expiresAt) for session lookups');
        recommendations.push('Add index on (token) for token-based queries');
      }
      if (table === 'userRole') {
        recommendations.push('Add composite index on (userId, roleId, scopeType)');
      }
      if (table === 'invite') {
        recommendations.push('Add index on (email, worldId) for invite lookups');
        recommendations.push('Add index on (expiresAt) for cleanup queries');
      }
      if (table === 'player') {
        recommendations.push('Add index on (worldId, userId) for player queries');
      }
    }

    if (operation.includes('count')) {
      recommendations.push('Consider caching count results for frequently accessed data');
      if (table === 'session') {
        recommendations.push('Add partial index on active sessions (expiresAt > NOW())');
      }
    }

    if (operation.includes('update') || operation.includes('delete')) {
      recommendations.push('Ensure WHERE clause uses indexed columns');
      if (table === 'session') {
        recommendations.push('Batch cleanup operations during low-traffic periods');
      }
    }

    return recommendations.length > 0 ? recommendations : ['Monitor query execution plan'];
  }

  // 🎯 Index-Recommendations basierend auf aktuellen Queries
  getIndexRecommendations(): IndexRecommendation[] {
    const recommendations: IndexRecommendation[] = [
      // Session-Performance
      {
        table: 'sessions',
        columns: ['user_id', 'expires_at'],
        reason: 'Frequent lookups for active user sessions',
        impact: 'high',
        query: 'CREATE INDEX CONCURRENTLY idx_sessions_user_expires ON sessions (user_id, expires_at);'
      },
      {
        table: 'sessions',
        columns: ['token'],
        reason: 'Token-based session validation',
        impact: 'high',
        query: 'CREATE INDEX CONCURRENTLY idx_sessions_token ON sessions (token);'
      },
      {
        table: 'sessions', 
        columns: ['last_accessed_at'],
        reason: 'Session cleanup and inactivity tracking',
        impact: 'medium',
        query: 'CREATE INDEX CONCURRENTLY idx_sessions_last_accessed ON sessions (last_accessed_at);'
      },

      // Access Control Performance
      {
        table: 'user_roles',
        columns: ['user_id', 'scope_type', 'scope_object_id'],
        reason: 'Permission checks with scope filtering',
        impact: 'high',
        query: 'CREATE INDEX CONCURRENTLY idx_user_roles_scope ON user_roles (user_id, scope_type, scope_object_id);'
      },
      {
        table: 'role_permissions',
        columns: ['role_id', 'scope_type', 'scope_object_id'],
        reason: 'Permission resolution for specific scopes',
        impact: 'high',
        query: 'CREATE INDEX CONCURRENTLY idx_role_permissions_scope ON role_permissions (role_id, scope_type, scope_object_id);'
      },

      // Invite System Performance
      {
        table: 'invites',
        columns: ['email', 'world_id'],
        reason: 'Duplicate invite prevention',
        impact: 'medium',
        query: 'CREATE INDEX CONCURRENTLY idx_invites_email_world ON invites (email, world_id);'
      },
      {
        table: 'invites',
        columns: ['expires_at'],
        reason: 'Expired invite cleanup',
        impact: 'medium',
        query: 'CREATE INDEX CONCURRENTLY idx_invites_expires ON invites (expires_at) WHERE expires_at IS NOT NULL;'
      },

      // World/Player Performance
      {
        table: 'players',
        columns: ['world_id', 'left_at'],
        reason: 'Active player counts per world',
        impact: 'medium',
        query: 'CREATE INDEX CONCURRENTLY idx_players_world_active ON players (world_id, left_at);'
      },
      {
        table: 'pre_registrations',
        columns: ['world_id', 'email'],
        reason: 'Pre-registration duplicate prevention',
        impact: 'low',
        query: 'CREATE INDEX CONCURRENTLY idx_preregistrations_world_email ON pre_registrations (world_id, email);'
      },

      // User Management Performance
      {
        table: 'users',
        columns: ['is_locked', 'locked_until'],
        reason: 'Account lockout status checks',
        impact: 'low',
        query: 'CREATE INDEX CONCURRENTLY idx_users_lockout ON users (is_locked, locked_until) WHERE is_locked = true OR locked_until IS NOT NULL;'
      }
    ];

    return recommendations;
  }

  // 🧹 Cleanup alte Metriken
  cleanup(maxAge: number = 86400000) { // 24h default
    const cutoff = Date.now() - maxAge;
    this.metrics = this.metrics.filter(m => m.timestamp > cutoff);
  }

  // 📊 Health Check für Query Performance
  getHealthStatus(): {
    status: 'healthy' | 'degraded' | 'critical';
    avgResponseTime: number;
    slowQueryCount: number;
    errorRate: number;
    recommendations: string[];
  } {
    const stats = this.getPerformanceStats();
    
    let status: 'healthy' | 'degraded' | 'critical' = 'healthy';
    const recommendations: string[] = [];

    // Bewertungskriterien
    if (stats.avgDuration > 50) {
      status = 'degraded';
      recommendations.push('Average query time is elevated');
    }
    if (stats.avgDuration > 200) {
      status = 'critical';
      recommendations.push('Average query time is critically high');
    }
    if (stats.errorRate > 1) {
      status = 'degraded';
      recommendations.push('Database error rate is elevated');
    }
    if (stats.errorRate > 5) {
      status = 'critical';
      recommendations.push('Database error rate is critically high');
    }

    return {
      status,
      avgResponseTime: stats.avgDuration,
      slowQueryCount: stats.slowQueries,
      errorRate: stats.errorRate,
      recommendations
    };
  }
}

// 🚀 Global Query Tracker Instance
export const queryTracker = new QueryPerformanceTracker();

// 🎯 Wrapper-Funktionen für häufige Queries
export async function trackSessionQuery<T>(
  operation: string,
  queryFn: () => Promise<T>,
  params?: any
): Promise<T> {
  return queryTracker.trackQuery(operation, 'session', queryFn, params);
}

export async function trackUserQuery<T>(
  operation: string,
  queryFn: () => Promise<T>,
  params?: any  
): Promise<T> {
  return queryTracker.trackQuery(operation, 'user', queryFn, params);
}

export async function trackWorldQuery<T>(
  operation: string,
  queryFn: () => Promise<T>,
  params?: any
): Promise<T> {
  return queryTracker.trackQuery(operation, 'world', queryFn, params);
}

export async function trackInviteQuery<T>(
  operation: string,
  queryFn: () => Promise<T>,
  params?: any
): Promise<T> {
  return queryTracker.trackQuery(operation, 'invite', queryFn, params);
}

// 📊 Export aller Funktionen
export function getQueryPerformanceStats(timeframe?: number) {
  return queryTracker.getPerformanceStats(timeframe);
}

export function getIndexRecommendations() {
  return queryTracker.getIndexRecommendations();
}

export function getQueryHealthStatus() {
  return queryTracker.getHealthStatus();
}

// 🧹 Maintenance-Funktion für Cronjobs
export function cleanupQueryMetrics() {
  queryTracker.cleanup();
}