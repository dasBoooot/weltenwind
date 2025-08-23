import { loggers } from '../config/logger.config';
import prisma from '../libs/prisma';

// 📊 Metriken-Typen Definitionen
export interface APIMetrics {
  totalRequests: number;
  requestsByMethod: Record<string, number>;
  requestsByEndpoint: Record<string, number>;
  requestsByStatus: Record<string, number>;
  avgResponseTime: number;
  errorRate: number;
  requestsLast24h: number;
  slowestEndpoints: { endpoint: string; avgTime: number; count: number }[];
}

export interface UserMetrics {
  totalUsers: number;
  activeUsers: number;
  newUsersToday: number;
  loginAttempts: number;
  successfulLogins: number;
  failedLogins: number;
  passwordResets: number;
  accountLockouts: number;
}

export interface GameMetrics {
  totalWorlds: number;
  activeWorlds: number;
  worldJoins: number;
  worldsCreatedToday: number;
  totalInvites: number;
  invitesAccepted: number;
  invitesPending: number;
  preRegistrations: number;
}

export interface SystemMetrics {
  uptime: number;
  memoryUsage: {
    used: number;
    total: number;
    percentage: number;
  };
  databaseHealth: {
    responseTime: number;
    connections: number;
    status: 'healthy' | 'degraded' | 'down';
  };
  sessionMetrics: {
    total: number;
    active: number;
    suspicious: number;
  };
}

export interface PerformanceMetrics {
  avgDatabaseQueryTime: number;
  slowestQueries: { query: string; time: number; count: number }[];
  endpointPerformance: Record<string, { avgTime: number; count: number; p95: number }>;
  errorFrequency: Record<string, number>;
}

// 📈 In-Memory Metriken-Store (in Production sollte Redis verwendet werden)
class MetricsCollector {
  private apiRequests: Array<{
    method: string;
    endpoint: string;
    status: number;
    responseTime: number;
    timestamp: Date;
    userId?: number;
    ip: string;
  }> = [];

  private performanceData: Array<{
    operation: string;
    duration: number;
    timestamp: Date;
    metadata?: any;
  }> = [];

  private errors: Array<{
    type: string;
    message: string;
    stack?: string;
    endpoint?: string;
    userId?: number;
    timestamp: Date;
  }> = [];

  // Cleanup alte Daten (behalte nur letzte 24h)
  private cleanup() {
    const twentyFourHoursAgo = new Date(Date.now() - 24 * 60 * 60 * 1000);
    
    this.apiRequests = this.apiRequests.filter(req => req.timestamp > twentyFourHoursAgo);
    this.performanceData = this.performanceData.filter(perf => perf.timestamp > twentyFourHoursAgo);
    this.errors = this.errors.filter(error => error.timestamp > twentyFourHoursAgo);
  }

  // 📊 API-Request-Metriken sammeln
  recordAPIRequest(
    method: string,
    endpoint: string,
    status: number,
    responseTime: number,
    ip: string,
    userId?: number
  ) {
    this.apiRequests.push({
      method,
      endpoint: this.normalizeEndpoint(endpoint),
      status,
      responseTime,
      timestamp: new Date(),
      userId,
      ip
    });

    // Regelmäßiges Cleanup
    if (this.apiRequests.length % 1000 === 0) {
      this.cleanup();
    }
  }

  // 🚀 Performance-Metriken sammeln
  recordPerformance(operation: string, duration: number, metadata?: any) {
    this.performanceData.push({
      operation,
      duration,
      timestamp: new Date(),
      metadata
    });
  }

  // 🚨 Error-Metriken sammeln
  recordError(type: string, message: string, stack?: string, endpoint?: string, userId?: number) {
    this.errors.push({
      type,
      message,
      stack,
      endpoint,
      userId,
      timestamp: new Date()
    });
  }

  // 📊 API-Metriken berechnen
  async getAPIMetrics(): Promise<APIMetrics> {
    const now = new Date();
    const twentyFourHoursAgo = new Date(now.getTime() - 24 * 60 * 60 * 1000);
    
    const recent = this.apiRequests.filter(req => req.timestamp > twentyFourHoursAgo);
    
    // Gruppiere nach Methoden
    const requestsByMethod = recent.reduce((acc, req) => {
      acc[req.method] = (acc[req.method] || 0) + 1;
      return acc;
    }, {} as Record<string, number>);

    // Gruppiere nach Endpoints
    const requestsByEndpoint = recent.reduce((acc, req) => {
      acc[req.endpoint] = (acc[req.endpoint] || 0) + 1;
      return acc;
    }, {} as Record<string, number>);

    // Gruppiere nach Status Codes
    const requestsByStatus = recent.reduce((acc, req) => {
      const statusGroup = Math.floor(req.status / 100) * 100; // 200, 400, 500 etc.
      acc[`${statusGroup}xx`] = (acc[`${statusGroup}xx`] || 0) + 1;
      return acc;
    }, {} as Record<string, number>);

    // Durchschnittliche Response-Zeit
    const avgResponseTime = recent.length > 0 
      ? recent.reduce((sum, req) => sum + req.responseTime, 0) / recent.length
      : 0;

    // Error-Rate (4xx und 5xx Responses)
    const errorRequests = recent.filter(req => req.status >= 400).length;
    const errorRate = recent.length > 0 ? (errorRequests / recent.length) * 100 : 0;

    // Langsamste Endpoints
    const endpointTimes = recent.reduce((acc, req) => {
      if (!acc[req.endpoint]) {
        acc[req.endpoint] = { total: 0, count: 0 };
      }
      acc[req.endpoint].total += req.responseTime;
      acc[req.endpoint].count += 1;
      return acc;
    }, {} as Record<string, { total: number; count: number }>);

    const slowestEndpoints = Object.entries(endpointTimes)
      .map(([endpoint, data]) => ({
        endpoint,
        avgTime: Math.round(data.total / data.count),
        count: data.count
      }))
      .sort((a, b) => b.avgTime - a.avgTime)
      .slice(0, 10);

    return {
      totalRequests: this.apiRequests.length,
      requestsByMethod,
      requestsByEndpoint,
      requestsByStatus,
      avgResponseTime: Math.round(avgResponseTime),
      errorRate: Math.round(errorRate * 100) / 100,
      requestsLast24h: recent.length,
      slowestEndpoints
    };
  }

  // 🎮 Game-Metriken berechnen
  async getGameMetrics(): Promise<GameMetrics> {
    const now = new Date();
    const today = new Date(now.getFullYear(), now.getMonth(), now.getDate());

    const [
      totalWorlds,
      activeWorlds,
      worldsToday,
      totalInvites,
      invitesAccepted,
      invitesPending,
      preRegistrations,
      worldJoins
    ] = await Promise.all([
      prisma.world.count(),
      prisma.world.count({ where: { status: 'open' } }),
      // TODO: Implementiere wenn createdAt-Feld im World-Schema verfügbar ist
      Promise.resolve(0), // worldsToday placeholder
      prisma.invite.count(),
      prisma.invite.count({ where: { acceptedAt: { not: null } } }),
      prisma.invite.count({ where: { acceptedAt: null, expiresAt: { gt: now } } }),
      prisma.preRegistration.count(),
      // World-Joins approximieren durch User-World-Relationen
      prisma.user.count() // Vereinfacht - sollte durch dedizierte Join-Tabelle ersetzt werden
    ]);

    return {
      totalWorlds,
      activeWorlds,
      worldJoins,
      worldsCreatedToday: worldsToday,
      totalInvites,
      invitesAccepted,
      invitesPending,
      preRegistrations
    };
  }

  // 👥 User-Metriken berechnen
  async getUserMetrics(): Promise<UserMetrics> {
    const now = new Date();
    const today = new Date(now.getFullYear(), now.getMonth(), now.getDate());

    const [
      totalUsers,
      newUsersToday,
      lockedUsers
    ] = await Promise.all([
      prisma.user.count(),
      // TODO: Implementiere wenn createdAt-Feld im User-Schema verfügbar ist
      Promise.resolve(0), // newUsersToday placeholder
      prisma.user.count({ where: { OR: [{ isLocked: true }, { lockedUntil: { gt: now } }] } })
    ]);

    // Aktive Users (haben Session in letzten 7 Tagen)
    const sevenDaysAgo = new Date(now.getTime() - 7 * 24 * 60 * 60 * 1000);
    const activeUsers = await prisma.session.groupBy({
      by: ['userId'],
      where: {
        // Vereinfacht: nur auf lastAccessedAt prüfen
        lastAccessedAt: { gte: sevenDaysAgo }
      }
    });

    // Login-Statistiken aus API-Requests ableiten
    const loginRequests = this.apiRequests.filter(req => req.endpoint === '/auth/login');
    const successfulLogins = loginRequests.filter(req => req.status === 200).length;
    const failedLogins = loginRequests.filter(req => req.status === 401).length;

    // Password-Reset-Requests
    const passwordResets = this.apiRequests.filter(req => req.endpoint === '/auth/request-reset').length;

    return {
      totalUsers,
      activeUsers: activeUsers.length,
      newUsersToday,
      loginAttempts: loginRequests.length,
      successfulLogins,
      failedLogins,
      passwordResets,
      accountLockouts: lockedUsers
    };
  }

  // 💻 System-Metriken berechnen
  async getSystemMetrics(): Promise<SystemMetrics> {
    const memUsage = process.memoryUsage();
    
    // Database Health Check
    const dbStart = Date.now();
    try {
      await prisma.$queryRaw`SELECT 1`;
      const dbResponseTime = Date.now() - dbStart;
      
      const sessionCount = await prisma.session.count();
      const activeSessionCount = await prisma.session.count({
        where: { expiresAt: { gt: new Date() } }
      });

      return {
        uptime: Math.floor(process.uptime()),
        memoryUsage: {
          used: Math.round(memUsage.heapUsed / 1024 / 1024),
          total: Math.round(memUsage.heapTotal / 1024 / 1024),
          percentage: Math.round((memUsage.heapUsed / memUsage.heapTotal) * 100)
        },
        databaseHealth: {
          responseTime: dbResponseTime,
          connections: 1, // Prisma Pool-Info wäre hier besser
          status: dbResponseTime < 100 ? 'healthy' : dbResponseTime < 500 ? 'degraded' : 'down'
        },
        sessionMetrics: {
          total: sessionCount,
          active: activeSessionCount,
          suspicious: 0 // TODO: Implement suspicious session detection
        }
      };
    } catch (error) {
      return {
        uptime: Math.floor(process.uptime()),
        memoryUsage: {
          used: Math.round(memUsage.heapUsed / 1024 / 1024),
          total: Math.round(memUsage.heapTotal / 1024 / 1024),
          percentage: Math.round((memUsage.heapUsed / memUsage.heapTotal) * 100)
        },
        databaseHealth: {
          responseTime: -1,
          connections: 0,
          status: 'down'
        },
        sessionMetrics: {
          total: 0,
          active: 0,
          suspicious: 0
        }
      };
    }
  }

  // 🚀 Performance-Metriken berechnen
  getPerformanceMetrics(): PerformanceMetrics {
    const dbQueries = this.performanceData.filter(p => p.operation.startsWith('db_'));
    const avgDatabaseQueryTime = dbQueries.length > 0
      ? dbQueries.reduce((sum, q) => sum + q.duration, 0) / dbQueries.length
      : 0;

    // Gruppiere Performance-Daten nach Operationen
    const operationGroups = this.performanceData.reduce((acc, perf) => {
      if (!acc[perf.operation]) {
        acc[perf.operation] = { times: [], count: 0 };
      }
      acc[perf.operation].times.push(perf.duration);
      acc[perf.operation].count++;
      return acc;
    }, {} as Record<string, { times: number[]; count: number }>);

    // Berechne Endpoint-Performance mit P95
    const endpointPerformance = Object.entries(operationGroups).reduce((acc, [op, data]) => {
      const sortedTimes = data.times.sort((a, b) => a - b);
      const p95Index = Math.floor(sortedTimes.length * 0.95);
      const avgTime = data.times.reduce((sum, time) => sum + time, 0) / data.times.length;
      
      acc[op] = {
        avgTime: Math.round(avgTime),
        count: data.count,
        p95: sortedTimes[p95Index] || 0
      };
      return acc;
    }, {} as Record<string, { avgTime: number; count: number; p95: number }>);

    // Error-Frequenz
    const errorFrequency = this.errors.reduce((acc, error) => {
      acc[error.type] = (acc[error.type] || 0) + 1;
      return acc;
    }, {} as Record<string, number>);

    return {
      avgDatabaseQueryTime: Math.round(avgDatabaseQueryTime),
      slowestQueries: [], // TODO: Implement query tracking
      endpointPerformance,
      errorFrequency
    };
  }

  // 🔧 Hilfsfunktionen
  private normalizeEndpoint(url: string): string {
    // Normalisiere URLs (entferne IDs und Parameter)
    return url
      .replace(/\/\d+/g, '/:id')
      .replace(/\?.*$/, '')
      .replace(/\/$/, '') || '/';
  }

  // 📊 Alle Metriken zusammenfassen
  async getAllMetrics() {
    const [apiMetrics, userMetrics, gameMetrics, systemMetrics] = await Promise.all([
      this.getAPIMetrics(),
      this.getUserMetrics(),
      this.getGameMetrics(),
      this.getSystemMetrics()
    ]);

    const performanceMetrics = this.getPerformanceMetrics();

    return {
      timestamp: new Date().toISOString(),
      api: apiMetrics,
      users: userMetrics,
      game: gameMetrics,
      system: systemMetrics,
      performance: performanceMetrics,
      summary: {
        totalRequests24h: apiMetrics.requestsLast24h,
        errorRate: apiMetrics.errorRate,
        avgResponseTime: apiMetrics.avgResponseTime,
        activeUsers: userMetrics.activeUsers,
        systemHealth: systemMetrics.databaseHealth.status,
        memoryUsage: systemMetrics.memoryUsage.percentage
      }
    };
  }

  // 📈 Metriken-Statistiken für Admins
  getMetricsStats() {
    return {
      collected: {
        apiRequests: this.apiRequests.length,
        performanceData: this.performanceData.length,
        errors: this.errors.length
      },
      oldestEntry: this.apiRequests.length > 0 
        ? this.apiRequests[0].timestamp 
        : null,
      newestEntry: this.apiRequests.length > 0 
        ? this.apiRequests[this.apiRequests.length - 1].timestamp 
        : null
    };
  }
}

// Singleton-Instanz
export const metricsCollector = new MetricsCollector();

// 📊 Convenience-Funktionen für externe Nutzung
export const recordAPIRequest = metricsCollector.recordAPIRequest.bind(metricsCollector);
export const recordPerformance = metricsCollector.recordPerformance.bind(metricsCollector);
export const recordError = metricsCollector.recordError.bind(metricsCollector);
export const getAllMetrics = metricsCollector.getAllMetrics.bind(metricsCollector);
export const getMetricsStats = metricsCollector.getMetricsStats.bind(metricsCollector);