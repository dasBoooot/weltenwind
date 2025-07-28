const { PrismaClient } = require('@prisma/client');

const prisma = new PrismaClient();

async function cleanupSessions() {
  try {
    console.log('🔄 Starte Session-Bereinigung...');
    
    // Alle abgelaufenen Sessions löschen
    const expiredSessions = await prisma.session.deleteMany({
      where: {
        expiresAt: {
          lt: new Date()
        }
      }
    });
    
    console.log(`✅ ${expiredSessions.count} abgelaufene Sessions gelöscht`);
    
    // Alle Sessions älter als 30 Tage löschen (zusätzliche Sicherheit)
    const thirtyDaysAgo = new Date();
    thirtyDaysAgo.setDate(thirtyDaysAgo.getDate() - 30);
    
    const oldSessions = await prisma.session.deleteMany({
      where: {
        createdAt: {
          lt: thirtyDaysAgo
        }
      }
    });
    
    console.log(`✅ ${oldSessions.count} alte Sessions (30+ Tage) gelöscht`);
    
    // Verbleibende Sessions anzeigen
    const remainingSessions = await prisma.session.findMany({
      include: {
        user: {
          select: {
            username: true
          }
        }
      }
    });
    
    console.log(`\n📊 Verbleibende Sessions: ${remainingSessions.length}`);
    remainingSessions.forEach(session => {
      console.log(`  - ID: ${session.id}, User: ${session.user.username}, Expires: ${session.expiresAt}`);
    });
    
  } catch (error) {
    console.error('❌ Fehler bei der Session-Bereinigung:', error);
  } finally {
    await prisma.$disconnect();
  }
}

// Script ausführen
cleanupSessions(); 