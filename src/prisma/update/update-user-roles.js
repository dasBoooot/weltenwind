// Einfaches Update-Script für bestehende User (JavaScript)
// Ausführen mit: node prisma/update/update-user-roles.js

const { PrismaClient } = require('@prisma/client');
const prisma = new PrismaClient();

async function main() {
  console.log('🔄 Aktualisiere bestehende User mit Standard-Rollen...\n');
  
  // Zuerst den problematischen User "sven" updaten
  const sven = await prisma.user.findUnique({
    where: { username: 'sven' }
  });
  
  if (sven) {
    console.log(`Gefunden: User "sven" (ID: ${sven.id})`);
    
    const userRole = await prisma.role.findUnique({
      where: { name: 'user' }
    });
    
    if (userRole) {
      // Erstelle beide Rollen-Einträge für sven
      try {
        await prisma.userRole.createMany({
          data: [
            {
              userId: sven.id,
              roleId: userRole.id,
              scopeType: 'global',
              scopeObjectId: 'global'
            },
            {
              userId: sven.id,
              roleId: userRole.id,
              scopeType: 'world',
              scopeObjectId: '*'
            }
          ],
          skipDuplicates: true // Ignoriere wenn bereits vorhanden
        });
        console.log('✅ User "sven" aktualisiert!\n');
      } catch (error) {
        console.error('Fehler beim Update von sven:', error.message);
      }
    }
  }
  
  // Optional: Alle User ohne Rollen finden und updaten
  const usersWithoutRoles = await prisma.user.findMany({
    where: {
      roles: {
        none: {}
      }
    }
  });
  
  console.log(`User ohne Rollen: ${usersWithoutRoles.length}`);
  
  if (usersWithoutRoles.length > 0) {
    const userRole = await prisma.role.findUnique({
      where: { name: 'user' }
    });
    
    if (userRole) {
      for (const user of usersWithoutRoles) {
        console.log(`  - Aktualisiere ${user.username}...`);
        await prisma.userRole.createMany({
          data: [
            {
              userId: user.id,
              roleId: userRole.id,
              scopeType: 'global', 
              scopeObjectId: 'global'
            },
            {
              userId: user.id,
              roleId: userRole.id,
              scopeType: 'world',
              scopeObjectId: '*'
            }
          ],
          skipDuplicates: true
        });
      }
      console.log('\n✅ Alle User aktualisiert!');
    }
  }
}

main()
  .catch((e) => {
    console.error('Fehler:', e);
    process.exit(1);
  })
  .finally(async () => {
    await prisma.$disconnect();
  }); 