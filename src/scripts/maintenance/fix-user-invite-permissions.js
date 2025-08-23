const { PrismaClient } = require('@prisma/client');

const prisma = new PrismaClient();

async function fixUserInvitePermissions() {
  console.log('🔧 Erweitere User-Rolle um invite.create Permission...\n');

  try {
    // Hole Role und Permission
    const userRole = await prisma.role.findUnique({ where: { name: 'user' } });
    const inviteCreatePermission = await prisma.permission.findUnique({ where: { name: 'invite.create' } });

    if (!userRole || !inviteCreatePermission) {
      console.error('❌ Role oder Permission nicht gefunden!');
      return;
    }

    console.log(`📋 User Role ID: ${userRole.id}`);
    console.log(`🎫 invite.create Permission ID: ${inviteCreatePermission.id}`);

    // Füge invite.create Permission für world scope hinzu
    const rolePermission = await prisma.rolePermission.upsert({
      where: {
        roleId_permissionId_scopeType_scopeObjectId: {
          roleId: userRole.id,
          permissionId: inviteCreatePermission.id,
          scopeType: 'world',
          scopeObjectId: '*'
        }
      },
      update: {
        accessLevel: 'write'  // User können Invites erstellen aber nicht verwalten
      },
      create: {
        roleId: userRole.id,
        permissionId: inviteCreatePermission.id,
        scopeType: 'world',
        scopeObjectId: '*',
        accessLevel: 'write'
      }
    });

    console.log(`✅ RolePermission erstellt/updated: ID ${rolePermission.id}`);
    console.log(`   📝 Access Level: ${rolePermission.accessLevel}`);
    console.log(`   🌍 Scope: ${rolePermission.scopeType}:${rolePermission.scopeObjectId}\n`);

    // Verifikation: Teste ein paar User
    console.log('🧪 Verifikation:');
    const testUsers = ['user', 'testuser1'];
    
    for (const username of testUsers) {
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
      
      if (user) {
        const invitePermissions = [];
        for (const userRole of user.roles) {
          for (const rolePermission of userRole.role.permissions) {
            if (rolePermission.permission.name === 'invite.create') {
              invitePermissions.push(`${rolePermission.scopeType}:${rolePermission.scopeObjectId}`);
            }
          }
        }
        
        console.log(`   👤 ${username}: ${invitePermissions.length > 0 ? '✅' : '❌'} (${invitePermissions.join(', ')})`);
      }
    }

    console.log('\n🎉 User können jetzt Invites erstellen!');
    console.log('💡 Teste es im Client: Welt auswählen → Invite-Button → E-Mail eingeben');
    
  } catch (error) {
    console.error('💥 Fehler:', error.message);
    throw error;
  }
}

fixUserInvitePermissions()
  .catch(console.error)
  .finally(() => prisma.$disconnect());