import prisma from '../libs/prisma';
import { loggers } from '../config/logger.config';

// Konfiguration
const MAX_FAILED_ATTEMPTS = 5;           // Nach 5 fehlgeschlagenen Versuchen
const LOCKOUT_DURATION_MINUTES = 30;     // 30 Minuten Sperrzeit
const RESET_WINDOW_MINUTES = 15;         // Zähler zurücksetzen nach 15 Min ohne Fehler

export interface LoginAttemptResult {
  success: boolean;
  isLocked: boolean;
  remainingAttempts?: number;
  lockoutUntil?: Date;
  message?: string;
}

// Prüft ob Account gesperrt ist
export async function isAccountLocked(userId: number): Promise<{locked: boolean; until?: Date}> {
  const user = await prisma.user.findUnique({
    where: { id: userId },
    select: { isLocked: true, lockedUntil: true }
  });

  if (!user) {
    return { locked: false };
  }

  // Permanente Sperre (Admin-Aktion)
  if (user.isLocked && !user.lockedUntil) {
    return { locked: true };
  }

  // Temporäre Sperre
  if (user.lockedUntil && user.lockedUntil > new Date()) {
    return { locked: true, until: user.lockedUntil };
  }

  // Sperre abgelaufen - automatisch entsperren
  if (user.lockedUntil && user.lockedUntil <= new Date()) {
    await prisma.user.update({
      where: { id: userId },
      data: {
        lockedUntil: null,
        failedLoginAttempts: 0,
        lastFailedLoginAt: null
      }
    });
    return { locked: false };
  }

  return { locked: false };
}

// Registriert erfolgreichen Login
export async function recordSuccessfulLogin(userId: number): Promise<void> {
  await prisma.user.update({
    where: { id: userId },
    data: {
      failedLoginAttempts: 0,
      lastFailedLoginAt: null,
      lockedUntil: null
    }
  });
}

// Registriert fehlgeschlagenen Login
export async function recordFailedLogin(userId: number): Promise<LoginAttemptResult> {
  const user = await prisma.user.findUnique({
    where: { id: userId },
    select: {
      failedLoginAttempts: true,
      lastFailedLoginAt: true,
      lockedUntil: true,
      isLocked: true
    }
  });

  if (!user) {
    return { success: false, isLocked: false };
  }

  // Prüfe ob bereits gesperrt
  const lockStatus = await isAccountLocked(userId);
  if (lockStatus.locked) {
    return {
      success: false,
      isLocked: true,
      lockoutUntil: lockStatus.until,
      message: lockStatus.until 
        ? `Account gesperrt bis ${lockStatus.until.toLocaleString('de-DE')}`
        : 'Account ist gesperrt. Bitte kontaktiere den Support.'
    };
  }

  // Reset-Window prüfen
  const now = new Date();
  const resetWindow = new Date(now.getTime() - RESET_WINDOW_MINUTES * 60 * 1000);
  
  let failedAttempts = user.failedLoginAttempts;
  
  // Wenn letzter Fehler außerhalb Reset-Window, Zähler zurücksetzen
  if (user.lastFailedLoginAt && user.lastFailedLoginAt < resetWindow) {
    failedAttempts = 0;
  }

  // Erhöhe Fehlversuche
  failedAttempts++;

  // Prüfe ob Sperrung nötig
  if (failedAttempts >= MAX_FAILED_ATTEMPTS) {
    const lockoutUntil = new Date(now.getTime() + LOCKOUT_DURATION_MINUTES * 60 * 1000);
    
    await prisma.user.update({
      where: { id: userId },
      data: {
        failedLoginAttempts: failedAttempts,
        lastFailedLoginAt: now,
        lockedUntil: lockoutUntil
      }
    });

    // Account-Lockout ist bereits im strukturierten Log erfasst
    
    return {
      success: false,
      isLocked: true,
      lockoutUntil,
      remainingAttempts: 0,
      message: `Zu viele fehlgeschlagene Versuche. Account gesperrt bis ${lockoutUntil.toLocaleString('de-DE')}`
    };
  }

  // Update Fehlversuche
  await prisma.user.update({
    where: { id: userId },
    data: {
      failedLoginAttempts: failedAttempts,
      lastFailedLoginAt: now
    }
  });

  const remainingAttempts = MAX_FAILED_ATTEMPTS - failedAttempts;

  return {
    success: false,
    isLocked: false,
    remainingAttempts,
    message: `Falsches Passwort. ${remainingAttempts} Versuche verbleibend.`
  };
}

// Admin-Funktion: Account entsperren
export async function unlockAccount(userId: number): Promise<void> {
  await prisma.user.update({
    where: { id: userId },
    data: {
      isLocked: false,
      lockedUntil: null,
      failedLoginAttempts: 0,
      lastFailedLoginAt: null
    }
  });
}

// Admin-Funktion: Account permanent sperren
export async function lockAccountPermanently(userId: number): Promise<void> {
  await prisma.user.update({
    where: { id: userId },
    data: {
      isLocked: true,
      lockedUntil: null
    }
  });
}

// Cleanup-Funktion für abgelaufene temporäre Sperren
export async function cleanupExpiredLockouts(): Promise<number> {
  const result = await prisma.user.updateMany({
    where: {
      lockedUntil: {
        not: null,
        lte: new Date()
      }
    },
    data: {
      lockedUntil: null,
      failedLoginAttempts: 0,
      lastFailedLoginAt: null
    }
  });

  return result.count;
}