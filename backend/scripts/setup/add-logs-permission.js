const { PrismaClient } = require('@prisma/client');

const prisma = new PrismaClient();

async function addLogsPermission() {
  try {
    console.log('🔧 Füge system.logs Permission hinzu...');
    
    // Prüfe ob Permission bereits existiert
    const existingPermission = await prisma.permission.findUnique({
      where: { name: 'system.logs' }
    });
    
    if (existingPermission) {
      console.log('✅ system.logs Permission existiert bereits');
    } else {
      // Permission erstellen
      const permission = await prisma.permission.create({
        data: {
          name: 'system.logs',
          description: 'Zugriff auf System-Logs und Log-Viewer'
        }
      });
      console.log(`✅ Permission erstellt: ${permission.name}`);
    }
    
    // Admin-Rolle finden
    const adminRole = await prisma.role.findUnique({
      where: { name: 'admin' },
      include: { 
        permissions: {
          include: {
            permission: true
          }
        }
      }
    });
    
    if (!adminRole) {
      console.log('❌ Admin-Rolle nicht gefunden');
      return;
    }
    
    // Prüfe ob Admin bereits die Permission hat
    const hasPermission = adminRole.permissions.some(p => p.permission.name === 'system.logs');
    
    if (hasPermission) {
      console.log('✅ Admin-Rolle hat bereits system.logs Permission');
    } else {
      // Permission der Admin-Rolle zuweisen
      const logsPermission = await prisma.permission.findUnique({
        where: { name: 'system.logs' }
      });
      
      await prisma.rolePermission.create({
        data: {
          roleId: adminRole.id,
          permissionId: logsPermission.id,
          scopeType: 'global',
          scopeObjectId: '*',
          accessLevel: 'read'
        }
      });
      console.log('✅ system.logs Permission der Admin-Rolle zugewiesen');
    }
    
    console.log('🎉 Log-Permission Setup abgeschlossen!');
    
  } catch (error) {
    console.error('❌ Fehler beim Hinzufügen der Log-Permission:', error);
  } finally {
    await prisma.$disconnect();
  }
}

addLogsPermission();