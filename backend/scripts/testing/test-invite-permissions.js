const { PrismaClient } = require('@prisma/client');

const prisma = new PrismaClient();

async function testInvitePermissions() {
  console.log('🔍 Teste Invite-Permissions für verschiedene User...\n');

  const testUsers = ['admin', 'user', 'testuser1', 'mod', 'worldadmin'];
  
  for (const username of testUsers) {
    console.log(`👤 Testing User: ${username}`);
    
    try {
      // Hole User mit allen Rollen und Permissions
      const user = await prisma.user.findUnique({ 
        where: { username },
        include: {
          roles: {
            include: {
              role: {
                include: {
                  permissions: {
                    include: {
                      permission: true
                    }
                  }
                }
              }
            }
          }
        }
      });
      
      if (!user) {
        console.log(`   ❌ User nicht gefunden\n`);
        continue;
      }
      
      console.log(`   📋 Rollen: ${user.roles.map(r => r.role.name).join(', ')}`);
      
      // Sammle alle invite.create Permissions
      const inviteCreatePermissions = [];
      for (const userRole of user.roles) {
        for (const rolePermission of userRole.role.permissions) {
          if (rolePermission.permission.name === 'invite.create') {
            inviteCreatePermissions.push({
              scope: rolePermission.scopeType,
              objectId: rolePermission.scopeObjectId,
              accessLevel: rolePermission.accessLevel
            });
          }
        }
      }
      
      console.log(`   🎫 invite.create Permissions: ${inviteCreatePermissions.length}`);
      inviteCreatePermissions.forEach(perm => {
        console.log(`      - ${perm.scope}:${perm.objectId} (${perm.accessLevel})`);
      });
      
      const hasInvitePermission = inviteCreatePermissions.length > 0;
      console.log(`   ✅ Kann Invites erstellen: ${hasInvitePermission ? '✅ JA' : '❌ NEIN'}`);
      console.log('');
      
    } catch (error) {
      console.log(`   💥 Fehler: ${error.message}\n`);
    }
  }
  
  console.log('🎯 LÖSUNG: User-Rolle braucht invite.create Permission!');
}

testInvitePermissions()
  .catch(console.error)
  .finally(() => prisma.$disconnect());