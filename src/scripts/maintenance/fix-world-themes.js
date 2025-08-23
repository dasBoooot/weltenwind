const { PrismaClient } = require('@prisma/client');

async function fixWorldThemes() {
  const prisma = new PrismaClient();
  
  try {
    console.log('🔧 Repariere World-Theme-Zuordnungen...\n');
    
    // World ID 6: "Mittelerde Abenteuer" → tolkien
    await prisma.world.update({
      where: { id: 6 },
      data: { themeBundle: 'tolkien' }
    });
    console.log('✅ World 6 (Mittelerde): full-gaming → tolkien');
    
    // World ID 7: "Cyberpunk 2177" → cyberpunk  
    await prisma.world.update({
      where: { id: 7 },
      data: { themeBundle: 'cyberpunk' }
    });
    console.log('✅ World 7 (Cyberpunk): full-gaming → cyberpunk');
    
    // World ID 8: "Antikes Rom" → roman
    await prisma.world.update({
      where: { id: 8 },
      data: { themeBundle: 'roman' }
    });
    console.log('✅ World 8 (Antikes Rom): full-gaming → roman');
    
    // World ID 9: "Mystische Wälder" → nature
    await prisma.world.update({
      where: { id: 9 },
      data: { themeBundle: 'nature' }
    });
    console.log('✅ World 9 (Mystische Wälder): full-gaming → nature');
    
    // World ID 10: "Weltraum Station Alpha" → space
    await prisma.world.update({
      where: { id: 10 },
      data: { themeBundle: 'space' }
    });
    console.log('✅ World 10 (Weltraum Station): full-gaming → space');
    
    console.log('\n🎉 Alle World-Themes erfolgreich repariert!');
    console.log('Die Themes verwenden jetzt korrekte Theme-Namen statt Bundle-Namen.');
    
  } catch (error) {
    console.error('❌ Fehler:', error);
  } finally {
    await prisma.$disconnect();
  }
}

fixWorldThemes();