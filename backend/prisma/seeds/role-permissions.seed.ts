import { PrismaClient } from '@prisma/client';

const prisma = new PrismaClient();

export async function seedRolePermissions() {
  const rolePermissions = [
    // Admin (global) - Vollzugriff
    { role: 'admin', permission: 'system.admin', scopeType: 'global', scopeObjectId: 'global', accessLevel: 'admin' },
    { role: 'admin', permission: 'world.view', scopeType: 'global', scopeObjectId: 'global', accessLevel: 'admin' },
    { role: 'admin', permission: 'world.create', scopeType: 'global', scopeObjectId: 'global', accessLevel: 'admin' },
    { role: 'admin', permission: 'world.edit', scopeType: 'global', scopeObjectId: 'global', accessLevel: 'admin' },
    { role: 'admin', permission: 'world.edit', scopeType: 'world', scopeObjectId: '*', accessLevel: 'admin' },
    { role: 'admin', permission: 'world.delete', scopeType: 'global', scopeObjectId: 'global', accessLevel: 'admin' },
    { role: 'admin', permission: 'world.archive', scopeType: 'global', scopeObjectId: 'global', accessLevel: 'admin' },
    { role: 'admin', permission: 'player.view_all', scopeType: 'global', scopeObjectId: 'global', accessLevel: 'admin' },
    { role: 'admin', permission: 'player.view_all', scopeType: 'world', scopeObjectId: '*', accessLevel: 'admin' },
    { role: 'admin', permission: 'player.view_own', scopeType: 'global', scopeObjectId: 'global', accessLevel: 'admin' },
    { role: 'admin', permission: 'player.view_own', scopeType: 'world', scopeObjectId: '*', accessLevel: 'admin' },
    { role: 'admin', permission: 'player.join', scopeType: 'global', scopeObjectId: 'global', accessLevel: 'admin' },
    { role: 'admin', permission: 'player.join', scopeType: 'world', scopeObjectId: '*', accessLevel: 'admin' },
    { role: 'admin', permission: 'player.leave', scopeType: 'global', scopeObjectId: 'global', accessLevel: 'admin' },
    { role: 'admin', permission: 'player.leave', scopeType: 'world', scopeObjectId: '*', accessLevel: 'admin' },
    { role: 'admin', permission: 'player.invite', scopeType: 'global', scopeObjectId: 'global', accessLevel: 'admin' },
    { role: 'admin', permission: 'player.invite', scopeType: 'world', scopeObjectId: '*', accessLevel: 'admin' },
    { role: 'admin', permission: 'player.kick', scopeType: 'global', scopeObjectId: 'global', accessLevel: 'admin' },
    { role: 'admin', permission: 'player.kick', scopeType: 'world', scopeObjectId: '*', accessLevel: 'admin' },
    { role: 'admin', permission: 'player.ban', scopeType: 'global', scopeObjectId: 'global', accessLevel: 'admin' },
    { role: 'admin', permission: 'player.ban', scopeType: 'world', scopeObjectId: '*', accessLevel: 'admin' },
    { role: 'admin', permission: 'invite.create', scopeType: 'global', scopeObjectId: 'global', accessLevel: 'admin' },
    { role: 'admin', permission: 'invite.create', scopeType: 'world', scopeObjectId: '*', accessLevel: 'admin' },
    { role: 'admin', permission: 'invite.view', scopeType: 'global', scopeObjectId: 'global', accessLevel: 'admin' },
    { role: 'admin', permission: 'invite.view', scopeType: 'world', scopeObjectId: '*', accessLevel: 'admin' },
    { role: 'admin', permission: 'invite.manage', scopeType: 'global', scopeObjectId: 'global', accessLevel: 'admin' },
    { role: 'admin', permission: 'invite.manage', scopeType: 'world', scopeObjectId: '*', accessLevel: 'admin' },
    { role: 'admin', permission: 'invite.delete', scopeType: 'global', scopeObjectId: 'global', accessLevel: 'admin' },
    { role: 'admin', permission: 'invite.delete', scopeType: 'world', scopeObjectId: '*', accessLevel: 'admin' },
    { role: 'admin', permission: 'localization.manage', scopeType: 'global', scopeObjectId: 'global', accessLevel: 'admin' },
    { role: 'admin', permission: 'localization.view', scopeType: 'global', scopeObjectId: 'global', accessLevel: 'admin' },
    { role: 'admin', permission: 'system.view_own', scopeType: 'global', scopeObjectId: 'global', accessLevel: 'admin' },

    // Developer (global) - Entwickler-Funktionen
    { role: 'developer', permission: 'system.development', scopeType: 'global', scopeObjectId: 'global', accessLevel: 'admin' },
    { role: 'developer', permission: 'world.view', scopeType: 'global', scopeObjectId: 'global', accessLevel: 'read' },
    { role: 'developer', permission: 'world.edit', scopeType: 'global', scopeObjectId: 'global', accessLevel: 'write' },
    { role: 'developer', permission: 'world.edit', scopeType: 'world', scopeObjectId: '*', accessLevel: 'write' },
    { role: 'developer', permission: 'player.view_all', scopeType: 'global', scopeObjectId: 'global', accessLevel: 'read' },
    { role: 'developer', permission: 'player.view_all', scopeType: 'world', scopeObjectId: '*', accessLevel: 'read' },
    { role: 'developer', permission: 'invite.view', scopeType: 'global', scopeObjectId: 'global', accessLevel: 'read' },
    { role: 'developer', permission: 'invite.view', scopeType: 'world', scopeObjectId: '*', accessLevel: 'read' },
    { role: 'developer', permission: 'invite.delete', scopeType: 'global', scopeObjectId: 'global', accessLevel: 'write' },
    { role: 'developer', permission: 'invite.delete', scopeType: 'world', scopeObjectId: '*', accessLevel: 'write' },
    { role: 'developer', permission: 'localization.manage', scopeType: 'global', scopeObjectId: 'global', accessLevel: 'admin' },
    { role: 'developer', permission: 'localization.view', scopeType: 'global', scopeObjectId: 'global', accessLevel: 'admin' },
    { role: 'developer', permission: 'system.view_own', scopeType: 'global', scopeObjectId: 'global', accessLevel: 'read' },

    // Support (global) - Support-Funktionen
    { role: 'support', permission: 'system.support', scopeType: 'global', scopeObjectId: 'global', accessLevel: 'moderate' },
    { role: 'support', permission: 'world.view', scopeType: 'global', scopeObjectId: 'global', accessLevel: 'read' },
    { role: 'support', permission: 'player.view_all', scopeType: 'global', scopeObjectId: 'global', accessLevel: 'read' },
    { role: 'support', permission: 'player.view_all', scopeType: 'world', scopeObjectId: '*', accessLevel: 'read' },
    { role: 'support', permission: 'player.kick', scopeType: 'global', scopeObjectId: 'global', accessLevel: 'moderate' },
    { role: 'support', permission: 'player.kick', scopeType: 'world', scopeObjectId: '*', accessLevel: 'moderate' },
    { role: 'support', permission: 'invite.view', scopeType: 'global', scopeObjectId: 'global', accessLevel: 'read' },
    { role: 'support', permission: 'invite.view', scopeType: 'world', scopeObjectId: '*', accessLevel: 'read' },
    { role: 'support', permission: 'invite.delete', scopeType: 'global', scopeObjectId: 'global', accessLevel: 'moderate' },
    { role: 'support', permission: 'invite.delete', scopeType: 'world', scopeObjectId: '*', accessLevel: 'moderate' },
    { role: 'support', permission: 'system.view_own', scopeType: 'global', scopeObjectId: 'global', accessLevel: 'read' },

    // User (global) - Grundlegende Spieler-Funktionen
    { role: 'user', permission: 'world.view', scopeType: 'global', scopeObjectId: 'global', accessLevel: 'read' },
    { role: 'user', permission: 'player.join', scopeType: 'global', scopeObjectId: 'global', accessLevel: 'write' },
    { role: 'user', permission: 'player.join', scopeType: 'world', scopeObjectId: '*', accessLevel: 'write' },
    { role: 'user', permission: 'player.leave', scopeType: 'global', scopeObjectId: 'global', accessLevel: 'write' },
    { role: 'user', permission: 'player.leave', scopeType: 'world', scopeObjectId: '*', accessLevel: 'write' },
    { role: 'user', permission: 'player.view_own', scopeType: 'global', scopeObjectId: 'global', accessLevel: 'read' },
    { role: 'user', permission: 'player.view_own', scopeType: 'world', scopeObjectId: '*', accessLevel: 'read' },
    { role: 'user', permission: 'system.view_own', scopeType: 'global', scopeObjectId: 'global', accessLevel: 'read' },

    // World-Admin (world-scoped) - Welt-Verwaltung
    { role: 'world-admin', permission: 'world.edit', scopeType: 'world', scopeObjectId: '*', accessLevel: 'admin' },
    { role: 'world-admin', permission: 'world.archive', scopeType: 'world', scopeObjectId: '*', accessLevel: 'admin' },
    { role: 'world-admin', permission: 'player.view_all', scopeType: 'world', scopeObjectId: '*', accessLevel: 'read' },
    { role: 'world-admin', permission: 'player.invite', scopeType: 'world', scopeObjectId: '*', accessLevel: 'admin' },
    { role: 'world-admin', permission: 'player.kick', scopeType: 'world', scopeObjectId: '*', accessLevel: 'admin' },
    { role: 'world-admin', permission: 'player.ban', scopeType: 'world', scopeObjectId: '*', accessLevel: 'admin' },
    { role: 'world-admin', permission: 'player.promote', scopeType: 'world', scopeObjectId: '*', accessLevel: 'admin' },
    { role: 'world-admin', permission: 'player.demote', scopeType: 'world', scopeObjectId: '*', accessLevel: 'admin' },
    { role: 'world-admin', permission: 'invite.create', scopeType: 'world', scopeObjectId: '*', accessLevel: 'admin' },
    { role: 'world-admin', permission: 'invite.view', scopeType: 'world', scopeObjectId: '*', accessLevel: 'read' },
    { role: 'world-admin', permission: 'invite.manage', scopeType: 'world', scopeObjectId: '*', accessLevel: 'admin' },
    { role: 'world-admin', permission: 'invite.delete', scopeType: 'world', scopeObjectId: '*', accessLevel: 'admin' },
    { role: 'world-admin', permission: 'system.view_own', scopeType: 'global', scopeObjectId: 'global', accessLevel: 'read' },

    // Mod (world-scoped) - Moderations-Funktionen
    { role: 'mod', permission: 'player.view_all', scopeType: 'world', scopeObjectId: '*', accessLevel: 'read' },
    { role: 'mod', permission: 'player.invite', scopeType: 'world', scopeObjectId: '*', accessLevel: 'moderate' },
    { role: 'mod', permission: 'player.kick', scopeType: 'world', scopeObjectId: '*', accessLevel: 'moderate' },
    { role: 'mod', permission: 'player.mute', scopeType: 'world', scopeObjectId: '*', accessLevel: 'moderate' },
    { role: 'mod', permission: 'invite.create', scopeType: 'world', scopeObjectId: '*', accessLevel: 'moderate' },
    { role: 'mod', permission: 'invite.view', scopeType: 'world', scopeObjectId: '*', accessLevel: 'read' },
    { role: 'mod', permission: 'system.view_own', scopeType: 'global', scopeObjectId: 'global', accessLevel: 'read' }
  ];

  for (const rolePermission of rolePermissions) {
    // Hole Role und Permission IDs
    const role = await prisma.role.findUnique({ where: { name: rolePermission.role } });
    const permission = await prisma.permission.findUnique({ where: { name: rolePermission.permission } });

    if (role && permission) {
      await prisma.rolePermission.upsert({
        where: {
          roleId_permissionId_scopeType_scopeObjectId: {
            roleId: role.id,
            permissionId: permission.id,
            scopeType: rolePermission.scopeType,
            scopeObjectId: rolePermission.scopeObjectId
          }
        },
        update: {
          accessLevel: rolePermission.accessLevel
        },
        create: {
          roleId: role.id,
          permissionId: permission.id,
          scopeType: rolePermission.scopeType,
          scopeObjectId: rolePermission.scopeObjectId,
          accessLevel: rolePermission.accessLevel
        }
      });
    }
  }
} 