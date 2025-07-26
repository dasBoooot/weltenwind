import { PrismaClient } from '@prisma/client';
import { createHash } from 'crypto';

const prisma = new PrismaClient();

function hashIp(ip: string) {
  return createHash('sha256').update(ip).digest('hex');
}

export async function createSession(userId: number, token: string, ip: string, fingerprint: string) {
  const expiresAt = new Date(Date.now() + 2 * 60 * 60 * 1000); // 2h

  return prisma.session.create({
    data: {
      userId,
      token,
      expiresAt,
      ipHash: hashIp(ip),
      deviceFingerprint: fingerprint
    }
  });
}

export async function getValidSession(userId: number, token: string) {
  return prisma.session.findFirst({
    where: {
      userId,
      token,
      expiresAt: {
        gte: new Date()
      }
    }
  });
}

export async function invalidateSession(userId: number, token: string) {
  return prisma.session.deleteMany({
    where: {
      userId,
      token
    }
  });
}

export async function invalidateAllSessions(userId: number) {
  return prisma.session.deleteMany({
    where: { userId }
  });
}
