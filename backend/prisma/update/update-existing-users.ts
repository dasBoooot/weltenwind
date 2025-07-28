import { PrismaClient } from '@prisma/client';

const prisma = new PrismaClient();

/**
 * Dieses Script aktualisiert bestehende User mit fehlenden Rollen-Verknüpfungen
 * Führe es aus mit: npx ts-node prisma/update/update-existing-users.ts
 */
async function updateExistingUsers() {
  console.log('🔄 Starte Update für bestehende User...\n');

  try {
    // Finde die Standard-User-Rolle
    const userRole = await prisma.role.findUnique({
      where: { name: 'user' }
    });

    if (!userRole) {
      throw new Error('Standard-User-Rolle nicht gefunden!');
    }

    // Hole alle User
    const allUsers = await prisma.user.findMany({
      include: {
        roles: true
      }
    });

    console.log(`Gefundene User: ${allUsers.length}\n`);

    let updatedCount = 0;

    for (const user of allUsers) {
      console.log(`Prüfe User: ${user.username} (ID: ${user.id})`);
      
      // Prüfe ob global scope existiert
      const hasGlobalScope = user.roles.some(r => 
        r.roleId === userRole.id && 
        r.scopeType === 'global' && 
        r.scopeObjectId === 'global'
      );
      
      // Prüfe ob world scope existiert  
      const hasWorldScope = user.roles.some(r => 
        r.roleId === userRole.id && 
        r.scopeType === 'world' && 
        r.scopeObjectId === '*'
      );

      const updates = [];

      // Füge fehlende Scopes hinzu
      if (!hasGlobalScope) {
        updates.push(
          prisma.userRole.create({
            data: {
              userId: user.id,
              roleId: userRole.id,
              scopeType: 'global',
              scopeObjectId: 'global'
            }
          })
        );
        console.log(`  ➕ Füge global scope hinzu`);
      }

      if (!hasWorldScope) {
        updates.push(
          prisma.userRole.create({
            data: {
              userId: user.id,
              roleId: userRole.id,
              scopeType: 'world',
              scopeObjectId: '*'
            }
          })
        );
        console.log(`  ➕ Füge world scope hinzu`);
      }

      // Beispiel: Neuer game scope (wenn du das später brauchst)
      /*
      const hasGameScope = user.roles.some(r => 
        r.roleId === userRole.id && 
        r.scopeType === 'game' && 
        r.scopeObjectId === '*'
      );
      
      if (!hasGameScope) {
        updates.push(
          prisma.userRole.create({
            data: {
              userId: user.id,
              roleId: userRole.id,
              scopeType: 'game',
              scopeObjectId: '*'
            }
          })
        );
        console.log(`  ➕ Füge game scope hinzu`);
      }
      */

      if (updates.length > 0) {
        await prisma.$transaction(updates);
        updatedCount++;
        console.log(`  ✅ User aktualisiert\n`);
      } else {
        console.log(`  ✓ User hat bereits alle Rollen\n`);
      }
    }

    console.log(`\n🎉 Update abgeschlossen!`);
    console.log(`   Aktualisierte User: ${updatedCount}`);
    console.log(`   Bereits vollständig: ${allUsers.length - updatedCount}`);

  } catch (error) {
    console.error('❌ Fehler beim Update:', error);
    throw error;
  } finally {
    await prisma.$disconnect();
  }
}

// Script ausführen
updateExistingUsers()
  .catch((error) => {
    console.error('Script fehlgeschlagen:', error);
    process.exit(1);
  }); 