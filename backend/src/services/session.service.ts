import { Session } from '@prisma/client';
import { createHash } from 'crypto';
import prisma from '../libs/prisma';
import { loggers } from '../config/logger.config';

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
