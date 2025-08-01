import { PrismaClient } from '@prisma/client';

const prisma = new PrismaClient();

export async function seedPermissions() {
  const permissionNames = [
    // Welt-Management
    'world.view',
    'world.create', 
    'world.edit',
    'world.delete',
    'world.archive',
    
    // Player-Management
    'player.join',
    'player.leave',
    'player.view_own',
    'player.view_all',
    'player.invite',
    'player.kick',
    'player.ban',
    'player.mute',
    'player.promote',
    'player.demote',
    
    // Invite-Management
    'invite.create',
    'invite.view',
    'invite.manage',
    'invite.delete',
    
    // System-Management
    'system.admin',
    'system.moderation',
    'system.support',
    'system.development',
    'system.view_own',
    
    // ARB-Management (Application Resource Bundle)
    'arb.view',
    'arb.edit',
    'arb.save',
    'arb.backup.view',
    'arb.backup.restore',
    'arb.backup.delete',
    'arb.export',
    'arb.import', 
    'arb.compare',
    
    // Localization-Management (Deprecated - use arb.* instead)
    'localization.manage',
    'localization.view'
  ];

  for (const name of permissionNames) {
    await prisma.permission.upsert({
      where: { name },
      update: {},
      create: {
        name,
        description: name.replace('.', ' '), // Beschreibung generieren
      },
    });
  }
} 