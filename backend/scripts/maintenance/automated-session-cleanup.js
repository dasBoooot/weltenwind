#!/usr/bin/env node

/**
 * 🔄 Automatisiertes Session-Cleanup-Script
 * 
 * Dieses Script kann als Cron-Job ausgeführt werden für:
 * - Bereinigung abgelaufener Sessions
 * - Cleanup inaktiver Sessions
 * - Lockout-Bereinigung
 * - Session-Health-Monitoring
 * 
 * Usage:
 *   node automated-session-cleanup.js [--dry-run] [--verbose]
 * 
 * Cron-Job Setup (täglich um 2:00 Uhr):
 *   0 2 * * * /usr/bin/node /srv/weltenwind/backend/scripts/maintenance/automated-session-cleanup.js
 */

const { PrismaClient } = require('@prisma/client');
const prisma = new PrismaClient();

// CLI-Argumente parsen
const args = process.argv.slice(2);
const DRY_RUN = args.includes('--dry-run');
const VERBOSE = args.includes('--verbose') || args.includes('-v');

// Konfiguration
const CONFIG = {
  // Sessions bereinigen die länger als X Stunden inaktiv sind
  INACTIVITY_TIMEOUT_HOURS: parseInt(process.env.SESSION_INACTIVITY_TIMEOUT_HOURS || '24', 10),
  
  // Alle Sessions älter als X Tage löschen (Sicherheits-Cleanup)
  MAX_SESSION_AGE_DAYS: parseInt(process.env.SESSION_MAX_AGE_DAYS || '30', 10),
  
  // Warnung wenn mehr als X% der Sessions abgelaufen sind
  EXPIRED_SESSION_WARNING_THRESHOLD: 0.5, // 50%
  
  // Max Sessions pro User (bei Überschreitung älteste löschen)
  MAX_SESSIONS_PER_USER: parseInt(process.env.MAX_SESSIONS_PER_USER || '3', 10)
};

console.log('🔄 Automatisiertes Session-Cleanup gestartet');
console.log(`📅 ${new Date().toISOString()}`);
if (DRY_RUN) console.log('🔍 DRY-RUN Modus - keine Änderungen werden gespeichert!');
console.log('');

async function getSessionStatistics() {
  const now = new Date();
  
  const [total, active, expired] = await Promise.all([
    prisma.session.count(),
    prisma.session.count({ where: { expiresAt: { gt: now } } }),
    prisma.session.count({ where: { expiresAt: { lte: now } } })
  ]);
  
  return { total, active, expired };
}

async function cleanupExpiredSessions() {
  console.log('🗑️  Bereinige abgelaufene Sessions...');
  
  const result = DRY_RUN 
    ? await prisma.session.count({ where: { expiresAt: { lt: new Date() } } })
    : await (await prisma.session.deleteMany({ where: { expiresAt: { lt: new Date() } } })).count;
  
  console.log(`   ✅ ${result} abgelaufene Sessions ${DRY_RUN ? 'gefunden' : 'gelöscht'}`);
  return result;
}

async function cleanupInactiveSessions() {
  console.log('💤 Bereinige inaktive Sessions...');
  
  const inactiveThreshold = new Date();
  inactiveThreshold.setHours(inactiveThreshold.getHours() - CONFIG.INACTIVITY_TIMEOUT_HOURS);
  
  const inactiveQuery = {
    where: {
      OR: [
        { lastAccessedAt: { lt: inactiveThreshold } },
        { 
          lastAccessedAt: null,
          createdAt: { lt: inactiveThreshold }
        }
      ]
    }
  };
  
  const result = DRY_RUN 
    ? await prisma.session.count(inactiveQuery)
    : await (await prisma.session.deleteMany(inactiveQuery)).count;
  
  console.log(`   ✅ ${result} inaktive Sessions (${CONFIG.INACTIVITY_TIMEOUT_HOURS}h+) ${DRY_RUN ? 'gefunden' : 'gelöscht'}`);
  return result;
}

async function cleanupOldSessions() {
  console.log('📅 Bereinige sehr alte Sessions...');
  
  const oldThreshold = new Date();
  oldThreshold.setDate(oldThreshold.getDate() - CONFIG.MAX_SESSION_AGE_DAYS);
  
  const result = DRY_RUN 
    ? await prisma.session.count({ where: { createdAt: { lt: oldThreshold } } })
    : await (await prisma.session.deleteMany({ where: { createdAt: { lt: oldThreshold } } })).count;
  
  console.log(`   ✅ ${result} sehr alte Sessions (${CONFIG.MAX_SESSION_AGE_DAYS}+ Tage) ${DRY_RUN ? 'gefunden' : 'gelöscht'}`);
  return result;
}

async function cleanupExcessUserSessions() {
  console.log('👥 Bereinige überschüssige User-Sessions...');
  
  // Finde User mit zu vielen Sessions
  const usersWithTooManySessions = await prisma.session.groupBy({
    by: ['userId'],
    where: {
      expiresAt: { gt: new Date() } // Nur aktive Sessions
    },
    _count: { id: true },
    having: {
      id: { _count: { gt: CONFIG.MAX_SESSIONS_PER_USER } }
    }
  });
  
  let totalDeleted = 0;
  
  for (const userGroup of usersWithTooManySessions) {
    const userId = userGroup.userId;
    const sessionCount = userGroup._count.id;
    
    // Hole alle Sessions des Users (sortiert nach Aktivität)
    const userSessions = await prisma.session.findMany({
      where: { 
        userId,
        expiresAt: { gt: new Date() }
      },
      orderBy: [
        { lastAccessedAt: 'desc' },
        { createdAt: 'desc' }
      ]
    });
    
    // Behalte nur die neuesten Sessions
    const sessionsToDelete = userSessions.slice(CONFIG.MAX_SESSIONS_PER_USER);
    
    if (sessionsToDelete.length > 0) {
      if (VERBOSE) {
        console.log(`   👤 User ${userId}: ${sessionCount} Sessions → ${sessionsToDelete.length} zu löschen`);
      }
      
      if (!DRY_RUN) {
        await prisma.session.deleteMany({
          where: { id: { in: sessionsToDelete.map(s => s.id) } }
        });
      }
      
      totalDeleted += sessionsToDelete.length;
    }
  }
  
  console.log(`   ✅ ${totalDeleted} überschüssige User-Sessions ${DRY_RUN ? 'gefunden' : 'gelöscht'}`);
  return totalDeleted;
}

async function cleanupExpiredLockouts() {
  console.log('🔓 Bereinige abgelaufene Account-Lockouts...');
  
  const result = DRY_RUN 
    ? await prisma.user.count({
        where: {
          lockedUntil: { not: null, lte: new Date() }
        }
      })
    : await (await prisma.user.updateMany({
        where: {
          lockedUntil: { not: null, lte: new Date() }
        },
        data: {
          lockedUntil: null,
          failedLoginAttempts: 0,
          lastFailedLoginAt: null
        }
      })).count;
  
  console.log(`   ✅ ${result} abgelaufene Lockouts ${DRY_RUN ? 'gefunden' : 'bereinigt'}`);
  return result;
}

async function performHealthCheck() {
  console.log('🏥 Führe Session-Health-Check durch...');
  
  const stats = await getSessionStatistics();
  const issues = [];
  
  // Check 1: Zu viele abgelaufene Sessions
  if (stats.expired > stats.total * CONFIG.EXPIRED_SESSION_WARNING_THRESHOLD) {
    issues.push(`Hoher Anteil abgelaufener Sessions: ${stats.expired}/${stats.total} (${Math.round(stats.expired/stats.total*100)}%)`);
  }
  
  // Check 2: Session-Verteilung pro User
  const sessionDistribution = await prisma.session.groupBy({
    by: ['userId'],
    where: { expiresAt: { gt: new Date() } },
    _count: { id: true }
  });
  
  const usersWithManySessions = sessionDistribution.filter(u => u._count.id > CONFIG.MAX_SESSIONS_PER_USER);
  if (usersWithManySessions.length > 0) {
    issues.push(`${usersWithManySessions.length} User mit mehr als ${CONFIG.MAX_SESSIONS_PER_USER} Sessions`);
  }
  
  console.log(`   📊 Sessions: ${stats.active} aktiv, ${stats.expired} abgelaufen, ${stats.total} gesamt`);
  console.log(`   👥 ${sessionDistribution.length} User mit aktiven Sessions`);
  
  if (issues.length > 0) {
    console.log('   ⚠️  Gefundene Issues:');
    issues.forEach(issue => console.log(`      - ${issue}`));
  } else {
    console.log('   ✅ Session-System ist gesund');
  }
  
  return { healthy: issues.length === 0, issues, stats };
}

async function main() {
  try {
    // Hole initiale Statistiken
    const initialStats = await getSessionStatistics();
    console.log(`📊 Initiale Session-Statistiken:`);
    console.log(`   Gesamt: ${initialStats.total}, Aktiv: ${initialStats.active}, Abgelaufen: ${initialStats.expired}`);
    console.log('');
    
    // Führe alle Cleanup-Operationen durch
    const results = {
      expired: await cleanupExpiredSessions(),
      inactive: await cleanupInactiveSessions(),
      old: await cleanupOldSessions(),
      excess: await cleanupExcessUserSessions(),
      lockouts: await cleanupExpiredLockouts()
    };
    
    console.log('');
    
    // Health-Check durchführen
    const healthCheck = await performHealthCheck();
    
    console.log('');
    console.log('✅ Session-Cleanup abgeschlossen!');
    console.log('📊 Bereinigungsergebnisse:');
    console.log(`   Abgelaufene Sessions: ${results.expired}`);
    console.log(`   Inaktive Sessions: ${results.inactive}`);
    console.log(`   Alte Sessions: ${results.old}`);
    console.log(`   Überschüssige Sessions: ${results.excess}`);
    console.log(`   Abgelaufene Lockouts: ${results.lockouts}`);
    
    const totalCleaned = Object.values(results).reduce((sum, count) => sum + count, 0);
    console.log(`   🗑️  Insgesamt bereinigt: ${totalCleaned} Einträge`);
    
    // Exit-Code basierend auf Health-Check
    if (!healthCheck.healthy) {
      console.log('⚠️  Session-System benötigt Aufmerksamkeit!');
      process.exit(1);
    }
    
  } catch (error) {
    console.error('❌ Fehler beim Session-Cleanup:', error);
    process.exit(1);
  } finally {
    await prisma.$disconnect();
  }
}

// Script ausführen
main();