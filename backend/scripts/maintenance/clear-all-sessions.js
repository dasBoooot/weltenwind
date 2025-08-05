const { PrismaClient } = require('@prisma/client');

const prisma = new PrismaClient();

async function clearAllSessions() {
  try {
    console.log('🔄 Lösche alle Sessions...');
    
    // Alle Sessions löschen
    const result = await prisma.session.deleteMany({});
    
    console.log(`✅ ${result.count} Sessions gelöscht`);
    
    // Verbleibende Sessions prüfen
    const remainingSessions = await prisma.session.findMany();
    console.log(`📊 Verbleibende Sessions: ${remainingSessions.length}`);
    
  } catch (error) {
    console.error('❌ Fehler beim Löschen der Sessions:', error);
  } finally {
    await prisma.$disconnect();
  }
}

// Script ausführen
clearAllSessions(); 