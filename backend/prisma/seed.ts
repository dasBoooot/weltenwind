import { PrismaClient } from '@prisma/client';
import bcrypt from 'bcrypt';

const prisma = new PrismaClient();

async function main() {
  console.log('🔁 Starte Seed...');

  const password = await bcrypt.hash('admin', 10);

  // Admin-Rolle
  const adminRole = await prisma.role.upsert({
    where: { name: 'admin' },
    update: {},
    create: {
      name: 'admin',
      description: 'Systemadministrator'
    }
  });

  // Rechte definieren
  const permissionNames = [
    'manage_users',
    'view_worlds',
    'edit_worlds',
    'access_admin_panel'
  ];

  for (const name of permissionNames) {
    await prisma.permission.upsert({
      where: { name },
      update: {},
      create: {
        name,
        description: name.replace('_', ' ')
      }
    });
  }

  // Rechte zur Rolle verknüpfen
  const allPermissions = await prisma.permission.findMany();
  for (const perm of allPermissions) {
    await prisma.rolePermission.upsert({
      where: {
        roleId_permissionId_scopeType_scopeObjectId: {
          roleId: adminRole.id,
          permissionId: perm.id,
          scopeType: 'global',
          scopeObjectId: 'global'
        }
      },
      update: {},
      create: {
        roleId: adminRole.id,
        permissionId: perm.id,
        scopeType: 'global',
        scopeObjectId: 'global',
        accessLevel: 'manage'
      }
    });
  }

  // Admin-User
  const admin = await prisma.user.upsert({
    where: { username: 'admin' },
    update: {},
    create: {
      username: 'admin',
      passwordHash: password,
      isLocked: false
    }
  });

  // Admin-Rolle für User
  await prisma.userRole.upsert({
    where: {
      userId_roleId_scopeType_scopeObjectId: {
        userId: admin.id,
        roleId: adminRole.id,
        scopeType: 'global',
        scopeObjectId: 'global'
      }
    },
    update: {},
    create: {
      userId: admin.id,
      roleId: adminRole.id,
      scopeType: 'global',
      scopeObjectId: 'global'
    }
  });

  console.log('✅ Seed abgeschlossen.');
}

main()
  .catch((e) => {
    console.error('❌ Fehler beim Seed:', e);
    process.exit(1);
  })
  .finally(() => prisma.$disconnect());
