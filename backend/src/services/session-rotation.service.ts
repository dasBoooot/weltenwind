import { User } from '@prisma/client';
import jwt from 'jsonwebtoken';
import { jwtConfig } from '../config/jwt.config';
import { invalidateAllUserSessions, createSession } from './session.service';
import prisma from '../libs/prisma';
import crypto from 'crypto';

// Token-Konfiguration
const ACCESS_TOKEN_EXPIRES_IN = 15 * 60; // 15 Minuten
const REFRESH_TOKEN_EXPIRES_IN = 7 * 24 * 60 * 60; // 7 Tage

interface TokenPair {
  accessToken: string;
  refreshToken: string;
  expiresIn: number;
  refreshExpiresIn: number;
}

/**
 * Kritische Aktionen die Session-Rotation erfordern
 */
export enum CriticalAction {
  PASSWORD_CHANGE = 'password_change',
  EMAIL_CHANGE = 'email_change',
  PERMISSION_CHANGE = 'permission_change',
  TWO_FACTOR_ENABLE = 'two_factor_enable',
  TWO_FACTOR_DISABLE = 'two_factor_disable',
  ACCOUNT_RECOVERY = 'account_recovery'
}

/**
 * Generiert sichere Tokens
 */
function generateSecureToken(): string {
  return crypto.randomBytes(32).toString('hex');
}

/**
 * Rotiert die Session eines Benutzers bei kritischen Aktionen
 * 
 * @param userId - Benutzer-ID
 * @param action - Die kritische Aktion
 * @param ip - IP-Adresse des Clients
 * @param fingerprint - Device Fingerprint
 * @param timezone - Zeitzone des Clients
 * @returns Neue Token-Pair
 */
export async function rotateSession(
  userId: number,
  action: CriticalAction,
  ip: string,
  fingerprint: string,
  timezone?: string
): Promise<TokenPair> {
  // 1. Alle bestehenden Sessions invalidieren
  await invalidateAllUserSessions(userId);
  
  // 2. Audit-Log erstellen
  await logSessionRotation(userId, action, ip);
  
  // 3. Neue Tokens generieren
  const refreshToken = generateSecureToken();
  const accessToken = jwt.sign(
    { 
      userId, 
      type: 'access',
      rotatedAt: new Date().toISOString(),
      action 
    },
    jwtConfig.getSecret(),
    { expiresIn: ACCESS_TOKEN_EXPIRES_IN }
  );
  
  // 4. Neue Session erstellen
  await createSession(
    userId,
    refreshToken,
    ip,
    fingerprint,
    timezone
  );
  
  return {
    accessToken,
    refreshToken,
    expiresIn: ACCESS_TOKEN_EXPIRES_IN,
    refreshExpiresIn: REFRESH_TOKEN_EXPIRES_IN
  };
}

/**
 * Prüft ob eine Aktion Session-Rotation erfordert
 */
export function requiresSessionRotation(action: string): boolean {
  return Object.values(CriticalAction).includes(action as CriticalAction);
}

/**
 * Erstellt einen Audit-Log-Eintrag für Session-Rotation
 */
async function logSessionRotation(
  userId: number,
  action: CriticalAction,
  ip: string
): Promise<void> {
  // Hier könnte ein Audit-Log-System implementiert werden
  console.log(`[SECURITY] Session rotation for user ${userId}:`, {
    action,
    ip,
    timestamp: new Date().toISOString()
  });
  
  // Optional: In Datenbank speichern
  // await prisma.auditLog.create({
  //   data: {
  //     userId,
  //     action: `session_rotation_${action}`,
  //     ip,
  //     timestamp: new Date()
  //   }
  // });
}

/**
 * Validiert dass ein Token nach Rotation noch gültig ist
 */
export function validateRotatedToken(token: string): boolean {
  try {
    const decoded = jwt.verify(token, jwtConfig.getSecret()) as any;
    
    // Prüfe ob Token rotiert wurde
    if (decoded.rotatedAt) {
      const rotatedAt = new Date(decoded.rotatedAt);
      const now = new Date();
      const timeDiff = now.getTime() - rotatedAt.getTime();
      
      // Token ist maximal 24 Stunden nach Rotation gültig
      const maxValidTime = 24 * 60 * 60 * 1000; // 24 Stunden
      
      return timeDiff <= maxValidTime;
    }
    
    return true;
  } catch (error) {
    return false;
  }
}

/**
 * Middleware-Helper für Session-Rotation
 */
export async function rotateSessionIfRequired(
  user: User,
  action: string,
  ip: string,
  fingerprint: string,
  timezone?: string
): Promise<TokenPair | null> {
  if (requiresSessionRotation(action)) {
    return rotateSession(
      user.id,
      action as CriticalAction,
      ip,
      fingerprint,
      timezone
    );
  }
  return null;
}