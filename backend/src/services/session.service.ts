import { Session } from '@prisma/client';
import { createHash } from 'crypto';
import prisma from '../libs/prisma';

function hashIp(ip: string) {
  return createHash('sha256').update(ip).digest('hex');
}

export async function createSession(
  userId: number, 
  token: string, 
  ip: string, 
  fingerprint: string,
  timezone?: string,
  clientTime?: number
): Promise<Session> {
  // Immer Server-Zeit verwenden für Session-Berechnungen
  const now = Date.now();
  const expiresAt = new Date(now + 15 * 60 * 1000); // 15 Minuten

  return prisma.session.create({
    data: {
      userId,
      token,
      expiresAt,
      ipHash: hashIp(ip),
      deviceFingerprint: fingerprint,
      timezone: timezone || 'UTC'
    }
  });
}

export async function getValidSession(userId: number, token: string, fingerprint?: string): Promise<Session | null> {
  // Erst versuchen ohne Device-Fingerprint (für Swagger UI, etc.)
  const session = await prisma.session.findFirst({
    where: {
      userId,
      token,
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
        token,
        deviceFingerprint: fingerprint,
        expiresAt: {
          gt: new Date()
        }
      }
    });
  }
  
  return null;
}

export async function refreshSession(userId: number, token: string): Promise<{ count: number }> {
  const now = new Date();
  const newExpiresAt = new Date(now.getTime() + 15 * 60 * 1000); // 15 Minuten

  return prisma.session.updateMany({
    where: {
      userId,
      token,
      expiresAt: {
        gt: now // Nur aktive Sessions aktualisieren
      }
    },
    data: {
      expiresAt: newExpiresAt
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

export async function invalidateAllSessions(userId: number): Promise<{ count: number }> {
  return prisma.session.deleteMany({
    where: { userId }
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
