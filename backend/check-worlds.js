const { PrismaClient } = require('@prisma/client');

async function checkWorlds() {
  const prisma = new PrismaClient();
  
  try {
    console.log('🌍 Prüfe World-Daten...\n');
    
    const worlds = await prisma.world.findMany({
      select: {
        id: true,
        name: true,
        themeBundle: true,
        status: true
      },
      orderBy: { id: 'asc' }
    });
    
    console.log(`📊 Anzahl Welten: ${worlds.length}\n`);
    
    worlds.forEach(world => {
      console.log(`🗺️  World ID ${world.id}: "${world.name}"`);
      console.log(`   themeBundle: "${world.themeBundle}"`);
      console.log(`   status: ${world.status}`);
      console.log('');
    });
    
  } catch (error) {
    console.error('❌ Fehler:', error);
  } finally {
    await prisma.$disconnect();
  }
}

checkWorlds();