// Direkter Datenbank-Check ohne API
const { PrismaClient } = require('@prisma/client');
const prisma = new PrismaClient();

async function checkDatabase() {
  try {
    console.log('Prüfe Datenbank direkt...\n');
    
    // Rollen prüfen
    const roles = await prisma.role.findMany();
    console.log(`Anzahl Rollen in DB: ${roles.length}`);
    
    if (roles.length > 0) {
      console.log('\nVerfügbare Rollen:');
      roles.forEach(role => {
        console.log(`  - ${role.name} (ID: ${role.id})`);
      });
    } else {
      console.log('\n❌ KEINE ROLLEN GEFUNDEN!');
      console.log('Führe aus: npm run seed');
    }
    
    // User-Rolle suchen
    const userRole = roles.find(r => r.name === 'user');
    if (userRole) {
      console.log(`\n✅ Standard-User-Rolle gefunden (ID: ${userRole.id})`);
    } else {
      console.log('\n⚠️  FEHLER: Standard-User-Rolle "user" fehlt!');
    }
    
    // Weitere Statistiken
    const userCount = await prisma.user.count();
    const userRoleCount = await prisma.userRole.count();
    const permissionCount = await prisma.permission.count();
    
    console.log('\nWeitere Statistiken:');
    console.log(`  - Anzahl User: ${userCount}`);
    console.log(`  - Anzahl UserRole-Einträge: ${userRoleCount}`);
    console.log(`  - Anzahl Permissions: ${permissionCount}`);
    
    // Letzte User mit Rollen anzeigen
    const lastUsers = await prisma.user.findMany({
      take: 3,
      orderBy: { id: 'desc' },
      include: {
        roles: {
          include: {
            role: true
          }
        }
      }
    });
    
    if (lastUsers.length > 0) {
      console.log('\nLetzte registrierte User:');
      lastUsers.forEach(user => {
        console.log(`  - ${user.username} (ID: ${user.id})`);
        console.log(`    Rollen: ${user.roles.length}`);
        user.roles.forEach(ur => {
          console.log(`      * ${ur.role.name} (${ur.scopeType}:${ur.scopeObjectId})`);
        });
      });
    }
    
  } catch (error) {
    console.error('Fehler:', error.message);
  } finally {
    await prisma.$disconnect();
  }
}

checkDatabase(); 