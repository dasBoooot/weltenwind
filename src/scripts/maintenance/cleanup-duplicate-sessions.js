const { PrismaClient } = require('@prisma/client');
const prisma = new PrismaClient();

async function cleanupDuplicateSessions() {
  console.log('🧹 Bereinige Duplikat-Sessions...\n');
  
  try {
    // Hole alle User mit aktiven Sessions
    const usersWithSessions = await prisma.session.groupBy({
      by: ['userId'],
      _count: {
        id: true
      },
      having: {
        id: {
          _count: {
            gt: 1  // Mehr als eine Session
          }
        }
      }
    });
    
    console.log(`Gefundene User mit mehreren Sessions: ${usersWithSessions.length}`);
    
    let totalDeleted = 0;
    
    // Für jeden User mit mehreren Sessions
    for (const userGroup of usersWithSessions) {
      const userId = userGroup.userId;
      const sessionCount = userGroup._count.id;
      
      // Hole alle Sessions dieses Users
      const sessions = await prisma.session.findMany({
        where: { userId },
        orderBy: [
          { lastAccessedAt: 'desc' },  // Neueste zuerst
          { createdAt: 'desc' }         // Falls lastAccessedAt null
        ]
      });
      
      // Behalte nur die neueste Session
      const sessionsToDelete = sessions.slice(1);
      
      if (sessionsToDelete.length > 0) {
        const user = await prisma.user.findUnique({
          where: { id: userId },
          select: { username: true }
        });
        
        console.log(`\nUser: ${user?.username || 'Unknown'} (ID: ${userId})`);
        console.log(`  Aktuelle Sessions: ${sessionCount}`);
        console.log(`  Zu löschende Sessions: ${sessionsToDelete.length}`);
        
        // Lösche alte Sessions
        const deleteResult = await prisma.session.deleteMany({
          where: {
            id: {
              in: sessionsToDelete.map(s => s.id)
            }
          }
        });
        
        totalDeleted += deleteResult.count;
        console.log(`  ✅ ${deleteResult.count} Sessions gelöscht`);
      }
    }
    
    // Zusätzlich: Lösche abgelaufene Sessions
    const expiredResult = await prisma.session.deleteMany({
      where: {
        expiresAt: {
          lt: new Date()
        }
      }
    });
    
    if (expiredResult.count > 0) {
      console.log(`\n🗑️  Zusätzlich ${expiredResult.count} abgelaufene Sessions gelöscht`);
      totalDeleted += expiredResult.count;
    }
    
    console.log(`\n✅ Bereinigung abgeschlossen!`);
    console.log(`   Insgesamt ${totalDeleted} Sessions gelöscht`);
    
    // Zeige finale Statistik
    const finalStats = await prisma.session.groupBy({
      by: ['userId'],
      _count: {
        id: true
      }
    });
    
    const multiSessionUsers = finalStats.filter(s => s._count.id > 1).length;
    console.log(`\n📊 Finale Statistik:`);
    console.log(`   User mit aktiven Sessions: ${finalStats.length}`);
    console.log(`   User mit mehreren Sessions: ${multiSessionUsers}`);
    
  } catch (error) {
    console.error('❌ Fehler beim Bereinigen:', error);
  } finally {
    await prisma.$disconnect();
  }
}

// Führe das Script aus
cleanupDuplicateSessions();