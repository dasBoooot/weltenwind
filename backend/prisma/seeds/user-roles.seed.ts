import { PrismaClient } from '@prisma/client';

const prisma = new PrismaClient();

export async function seedUserRoles() {
  // Spezifische User-Rollen-Zuordnungen
  const userRoles = [
    // Admin-User (hat sowohl global als auch world scope)
    { username: 'admin', role: 'admin', scopeType: 'global', scopeObjectId: 'global' },
    { username: 'admin', role: 'admin', scopeType: 'world', scopeObjectId: '*' },
    
    // Developer-User (hat sowohl global als auch world scope)
    { username: 'developer', role: 'developer', scopeType: 'global', scopeObjectId: 'global' },
    { username: 'developer', role: 'developer', scopeType: 'world', scopeObjectId: '*' },
    
    // Support-User (hat sowohl global als auch world scope)
    { username: 'support', role: 'support', scopeType: 'global', scopeObjectId: 'global' },
    { username: 'support', role: 'support', scopeType: 'world', scopeObjectId: '*' },
    
    // Standard-User (hat sowohl global als auch world scope)
    { username: 'user', role: 'user', scopeType: 'global', scopeObjectId: 'global' },
    { username: 'user', role: 'user', scopeType: 'world', scopeObjectId: '*' },
    
    // Mod-User (Welt-Moderator) - nur world scope
    { username: 'mod', role: 'mod', scopeType: 'world', scopeObjectId: '*' },
    
    // World-Admin-User (Welt-Besitzer) - nur world scope
    { username: 'worldadmin', role: 'world-admin', scopeType: 'world', scopeObjectId: '*' },
    
    // Zusätzliche Test-User
    { username: 'testuser1', role: 'user', scopeType: 'global', scopeObjectId: 'global' },
    { username: 'testuser1', role: 'user', scopeType: 'world', scopeObjectId: '*' },
    { username: 'testuser2', role: 'user', scopeType: 'global', scopeObjectId: 'global' },
    { username: 'testuser2', role: 'user', scopeType: 'world', scopeObjectId: '*' },
    { username: 'moderator1', role: 'mod', scopeType: 'world', scopeObjectId: '*' },
    { username: 'worldowner1', role: 'world-admin', scopeType: 'world', scopeObjectId: '*' }
  ];

  for (const userRole of userRoles) {
    const user = await prisma.user.findUnique({ where: { username: userRole.username } });
    const role = await prisma.role.findUnique({ where: { name: userRole.role } });

    if (user && role) {
      await prisma.userRole.upsert({
        where: {
          userId_roleId_scopeType_scopeObjectId: {
            userId: user.id,
            roleId: role.id,
            scopeType: userRole.scopeType,
            scopeObjectId: userRole.scopeObjectId
          }
        },
        update: {},
        create: {
          userId: user.id,
          roleId: role.id,
          scopeType: userRole.scopeType,
          scopeObjectId: userRole.scopeObjectId
        }
      });
    }
  }

  // Alle anderen Benutzer bekommen automatisch die User-Rolle (Fallback)
  const userRole = await prisma.role.findUnique({ where: { name: 'user' } });
  if (userRole) {
    const allUsers = await prisma.user.findMany();
    const assignedUsers = userRoles.map(ur => ur.username);
    
    for (const user of allUsers) {
      if (!assignedUsers.includes(user.username)) {
        // Prüfe ob User bereits eine Rolle hat
        const existingRole = await prisma.userRole.findFirst({
          where: { userId: user.id }
        });
        
        if (!existingRole) {
          await prisma.userRole.create({
            data: {
              userId: user.id,
              roleId: userRole.id,
              scopeType: 'global',
              scopeObjectId: 'global'
            }
          });
        }
      }
    }
  }
} 