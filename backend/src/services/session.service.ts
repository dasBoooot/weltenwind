import { Session } from '@prisma/client';
import { createHash } from 'crypto';
import prisma from '../libs/prisma';
import { loggers } from '../config/logger.config';

// 🔍 Session-Security-Konfiguration
const MAX_CONCURRENT_SESSIONS = parseInt(process.env.MAX_CONCURRENT_SESSIONS || '3', 10);
const SESSION_INACTIVITY_TIMEOUT_HOURS = parseInt(process.env.SESSION_INACTIVITY_TIMEOUT_HOURS || '24', 10);
const SUSPICIOUS_ACTIVITY_THRESHOLD = parseInt(process.env.SUSPICIOUS_ACTIVITY_THRESHOLD || '5', 10);
const ENABLE_LOCATION_TRACKING = process.env.ENABLE_LOCATION_TRACKING === 'true';

// 🌍 Location-basierte Session-Validierung (IP-Geolocation)
interface LocationInfo {
  country?: string;
  region?: string;
  city?: string;
  timezone?: string;
}

// 📊 Session-Aktivitäts-Metriken
interface SessionMetrics {
  totalSessions: number;
  activeSessions: number;
  expiredSessions: number;
  suspiciousSessions: number;
  uniqueUsers: number;
  avgSessionDuration: number;
}

function hashIp(ip: string) {
  return createHash('sha256').update(ip).digest('hex');
}

export async function createSession(
  userId: number, 
  refreshToken: string, 
  ip: string, 
  fingerprint: string,
  timezone?: string,
  clientTime?: number
): Promise<Session> {
  // Immer Server-Zeit verwenden für Session-Berechnungen
  const now = new Date();
  const expiresAt = new Date(now.getTime() + 7 * 24 * 60 * 60 * 1000); // 7 Tage

  return prisma.session.create({
    data: {
      userId,
      token: refreshToken, // Refresh-Token als Session-Token speichern
      expiresAt,
      ipHash: hashIp(ip),
      deviceFingerprint: fingerprint,
      timezone: timezone || 'UTC'
    }
  });
}

export async function getValidSession(userId: number, refreshToken: string, fingerprint?: string): Promise<Session | null> {
  // Erst versuchen ohne Device-Fingerprint (für Swagger UI, etc.)
  const session = await prisma.session.findFirst({
    where: {
      userId,
      token: refreshToken,
      expiresAt: {
        gt: new Date()
      }
    }
  });
  
  if (session) {
    return session;
  }
  
  // Fallback: Mit Device-Fingerprint (für spezifische Clients)
  if (fingerprint && fingerprint !== 'unknown') {
    return prisma.session.findFirst({
      where: {
        userId,
        token: refreshToken,
        deviceFingerprint: fingerprint,
        expiresAt: {
          gt: new Date()
        }
      }
    });
  }
  
  return null;
}

export async function refreshSession(userId: number, refreshToken: string): Promise<{ count: number }> {
  return prisma.session.updateMany({
    where: {
      userId,
      token: refreshToken,
      expiresAt: {
        gt: new Date()
      }
    },
    data: {
      lastAccessedAt: new Date()
    }
  });
}

export async function invalidateSession(userId: number, token: string): Promise<{ count: number }> {
  return prisma.session.deleteMany({
    where: {
      userId,
      token
    }
  });
}

export async function invalidateAllUserSessions(userId: number): Promise<{ count: number }> {
  return prisma.session.deleteMany({
    where: {
      userId
    }
  });
}

// Neue Funktion: Bereinigt alte Sessions vor dem Erstellen einer neuen
export async function createSessionWithCleanup(
  userId: number, 
  refreshToken: string, 
  ip: string, 
  fingerprint: string,
  timezone?: string,
  clientTime?: number,
  options?: {
    keepExistingSessions?: boolean;  // Multi-Device-Login erlauben
    maxSessionsPerUser?: number;      // Max. Anzahl Sessions pro User
  }
): Promise<Session> {
  // Standard: Alle alten Sessions löschen (Single-Device-Login)
  if (!options?.keepExistingSessions) {
    await invalidateAllUserSessions(userId);
  } else if (options.maxSessionsPerUser) {
    // Optional: Nur älteste Sessions löschen wenn Limit überschritten
    const existingSessions = await getUserSessions(userId);
    if (existingSessions.length >= options.maxSessionsPerUser) {
      // Sortiere nach lastAccessedAt und lösche die ältesten
      const sessionsToDelete = existingSessions
        .sort((a, b) => (a.lastAccessedAt || a.createdAt).getTime() - (b.lastAccessedAt || b.createdAt).getTime())
        .slice(0, existingSessions.length - options.maxSessionsPerUser + 1);
      
      for (const session of sessionsToDelete) {
        await prisma.session.delete({ where: { id: session.id } });
      }
    }
  }
  
  // Neue Session erstellen
  return createSession(userId, refreshToken, ip, fingerprint, timezone, clientTime);
}

export async function getUserSessions(userId: number): Promise<Session[]> {
  return prisma.session.findMany({
    where: {
      userId,
      expiresAt: {
        gt: new Date()
      }
    },
    orderBy: {
      lastAccessedAt: 'desc'
    }
  });
}

export async function cleanupExpiredSessions(): Promise<{ count: number }> {
  const now = new Date();
  
  return prisma.session.deleteMany({
    where: {
      expiresAt: {
        lt: now
      }
    }
  });
}

// Neue Funktion: Session-Validierung mit erweiterten Checks
export async function validateSession(
  userId: number, 
  refreshToken: string, 
  ip?: string, 
  fingerprint?: string
): Promise<{ valid: boolean; session?: Session; reason?: string }> {
  const session = await getValidSession(userId, refreshToken, fingerprint);
  
  if (!session) {
    return { valid: false, reason: 'Session nicht gefunden oder abgelaufen' };
  }

  // IP-Check (optional, da IP sich ändern kann)
  if (ip && session.ipHash) {
    const currentIpHash = hashIp(ip);
    if (session.ipHash !== currentIpHash) {
      console.warn(`IP-Mismatch für Session ${session.id}: expected ${session.ipHash}, got ${currentIpHash}`);
      // Nicht sofort invalidieren, nur loggen
    }
  }

  // Device-Fingerprint-Check (optional)
  if (fingerprint && session.deviceFingerprint && fingerprint !== 'unknown') {
    if (session.deviceFingerprint !== fingerprint) {
      console.warn(`Device-Fingerprint-Mismatch für Session ${session.id}`);
      // Nicht sofort invalidieren, nur loggen
    }
  }

  return { valid: true, session };
}

// 🔍 Erweiterte Session-Sicherheitsüberprüfung
export async function performSecurityCheck(
  userId: number, 
  ip: string, 
  userAgent?: string,
  location?: LocationInfo
): Promise<{ secure: boolean; risk: 'low' | 'medium' | 'high'; reasons: string[] }> {
  const reasons: string[] = [];
  let riskLevel: 'low' | 'medium' | 'high' = 'low';

  // 📊 Hole aktuelle Sessions des Users
  const userSessions = await getUserSessions(userId);
  
  // ⚠️ Check 1: Zu viele gleichzeitige Sessions
  if (userSessions.length > MAX_CONCURRENT_SESSIONS) {
    reasons.push(`Mehr als ${MAX_CONCURRENT_SESSIONS} gleichzeitige Sessions`);
    riskLevel = 'medium';
  }

  // ⚠️ Check 2: Verdächtige IP-Wechsel
  const recentSessions = userSessions.slice(0, 3);
  const ipHashes = recentSessions.map(s => s.ipHash).filter(Boolean);
  const uniqueIPs = new Set(ipHashes);
  
  if (uniqueIPs.size > SUSPICIOUS_ACTIVITY_THRESHOLD) {
    reasons.push(`${uniqueIPs.size} verschiedene IPs in kurzer Zeit`);
    riskLevel = 'medium';
  }

  // ⚠️ Check 3: Inaktive Sessions bereinigen
  const inactiveThreshold = new Date();
  inactiveThreshold.setHours(inactiveThreshold.getHours() - SESSION_INACTIVITY_TIMEOUT_HOURS);
  
  const inactiveSessions = userSessions.filter(s => 
    (s.lastAccessedAt || s.createdAt) < inactiveThreshold
  );
  
  if (inactiveSessions.length > 0) {
    reasons.push(`${inactiveSessions.length} inaktive Sessions gefunden`);
    // Bereinige inaktive Sessions automatisch
    await cleanupInactiveSessions(userId, SESSION_INACTIVITY_TIMEOUT_HOURS);
  }

  // 🌍 Check 4: Location-basierte Validierung (optional)
  if (ENABLE_LOCATION_TRACKING && location) {
    const recentLocations = await getRecentSessionLocations(userId);
    if (recentLocations.length > 0) {
      const hasUnusualLocation = !recentLocations.some(loc => 
        loc.country === location.country
      );
      
      if (hasUnusualLocation) {
        reasons.push(`Login aus ungewöhnlichem Land: ${location.country}`);
        riskLevel = 'high';
      }
    }
  }

  loggers.security.sessionSecurityCheck(userId, ip, {
    riskLevel,
    reasons,
    sessionCount: userSessions.length,
    userAgent
  });

  return {
    secure: riskLevel === 'low',
    risk: riskLevel,
    reasons
  };
}

// 📊 Session-Metriken für Monitoring
export async function getSessionMetrics(): Promise<SessionMetrics> {
  const now = new Date();
  
  // Alle Sessions zählen
  const totalSessions = await prisma.session.count();
  
  // Aktive Sessions (nicht abgelaufen)
  const activeSessions = await prisma.session.count({
    where: {
      expiresAt: { gt: now }
    }
  });
  
  // Abgelaufene Sessions
  const expiredSessions = totalSessions - activeSessions;
  
  // Verdächtige Sessions (mehrere IPs pro User)
  const sessionsWithMultipleIPs = await prisma.session.groupBy({
    by: ['userId'],
    having: {
      ipHash: {
        _count: {
          gt: 2 // Mehr als 2 verschiedene IPs
        }
      }
    },
    _count: {
      id: true
    }
  });
  
  // Unique Users mit aktiven Sessions
  const uniqueUsers = await prisma.session.groupBy({
    by: ['userId'],
    where: {
      expiresAt: { gt: now }
    }
  });
  
  // Durchschnittliche Session-Dauer berechnen (vereinfacht)
  const avgSessionDuration = 0; // TODO: Implementiere später mit korrekter Prisma-Syntax

  return {
    totalSessions,
    activeSessions,
    expiredSessions,
    suspiciousSessions: sessionsWithMultipleIPs.length,
    uniqueUsers: uniqueUsers.length,
    avgSessionDuration: Math.round(avgSessionDuration * 100) / 100 // 2 Dezimalstellen
  };
}

// 🔄 Erweiterte Session-Rotation für kritische Aktionen
export async function rotateSessionForCriticalAction(
  userId: number,
  currentToken: string,
  action: string,
  ip: string,
  fingerprint: string
): Promise<{ newToken: string; rotated: boolean; reason: string }> {
  // Prüfe ob Session-Rotation nötig ist
  const session = await getValidSession(userId, currentToken, fingerprint);
  
  if (!session) {
    return { newToken: currentToken, rotated: false, reason: 'Session ungültig' };
  }
  
  // Kritische Aktionen die Session-Rotation auslösen
  const criticalActions = [
    'password_change',
    'email_change', 
    'admin_action',
    'sensitive_data_access',
    'role_change'
  ];
  
  if (!criticalActions.includes(action)) {
    return { newToken: currentToken, rotated: false, reason: 'Aktion nicht kritisch' };
  }
  
  // Generiere neuen Token
  const newToken = require('crypto').randomBytes(32).toString('hex');
  
  // Update Session mit neuem Token
  await prisma.session.update({
    where: { id: session.id },
    data: {
      token: newToken,
      lastAccessedAt: new Date()
    }
  });
  
  loggers.security.sessionRotation(userId.toString(), ip, action, {
    oldTokenHash: require('crypto').createHash('sha256').update(currentToken).digest('hex').substring(0, 8),
    newTokenHash: require('crypto').createHash('sha256').update(newToken).digest('hex').substring(0, 8),
    reason: `Critical action: ${action}`
  });
  
  return { newToken, rotated: true, reason: `Session rotiert für: ${action}` };
}

// 🗺️ Location-basierte Hilfsfunktionen
export async function getRecentSessionLocations(userId: number): Promise<LocationInfo[]> {
  // Placeholder - würde mit IP-Geolocation-Service integriert werden
  // z.B. MaxMind GeoIP, ipapi.co, etc.
  const recentSessions = await prisma.session.findMany({
    where: {
      userId,
      createdAt: {
        gte: new Date(Date.now() - 7 * 24 * 60 * 60 * 1000) // Letzte 7 Tage
      }
    },
    select: { ipHash: true, createdAt: true },
    orderBy: { createdAt: 'desc' },
    take: 10
  });
  
  // Würde echte Geolocation-Daten zurückgeben
  return [];
}

// 🧹 Inaktive Sessions bereinigen
export async function cleanupInactiveSessions(userId: number, inactiveHours: number): Promise<number> {
  const inactiveThreshold = new Date();
  inactiveThreshold.setHours(inactiveThreshold.getHours() - inactiveHours);
  
  // Vereinfachte Query: Nutze nur lastAccessedAt falls vorhanden, sonst createdAt
  const sessionsToDelete = await prisma.session.findMany({
    where: {
      userId,
      createdAt: {
        lt: inactiveThreshold
      }
    },
    select: {
      id: true,
      lastAccessedAt: true,
      createdAt: true
    }
  });
  
  // Filter Sessions die wirklich inaktiv sind
  const inactiveSessionIds = sessionsToDelete
    .filter(session => {
      const lastActivity = session.lastAccessedAt || session.createdAt;
      return lastActivity < inactiveThreshold;
    })
    .map(session => session.id);
  
  if (inactiveSessionIds.length === 0) {
    return 0;
  }
  
  const result = await prisma.session.deleteMany({
    where: {
      id: {
        in: inactiveSessionIds
      }
    }
  });
  
  if (result.count > 0) {
    loggers.system.info('🧹 Inaktive Sessions bereinigt', {
      userId,
      cleanedSessions: result.count,
      inactiveHours
    });
  }
  
  return result.count;
}

// 📊 Session-Health-Check für Monitoring
export async function performSessionHealthCheck(): Promise<{
  healthy: boolean;
  issues: string[];
  metrics: SessionMetrics;
}> {
  const issues: string[] = [];
  const metrics = await getSessionMetrics();
  
  // Check 1: Zu viele abgelaufene Sessions
  if (metrics.expiredSessions > metrics.activeSessions * 2) {
    issues.push(`Viele abgelaufene Sessions: ${metrics.expiredSessions}`);
  }
  
  // Check 2: Verdächtige Aktivitäten
  if (metrics.suspiciousSessions > metrics.uniqueUsers * 0.1) {
    issues.push(`Verdächtige Sessions: ${metrics.suspiciousSessions}`);
  }
  
  // Check 3: Sehr kurze Session-Dauer (könnte auf Probleme hindeuten)
  if (metrics.avgSessionDuration < 0.5) { // Weniger als 30 Minuten
    issues.push(`Sehr kurze Session-Dauer: ${metrics.avgSessionDuration}h`);
  }
  
  return {
    healthy: issues.length === 0,
    issues,
    metrics
  };
}
