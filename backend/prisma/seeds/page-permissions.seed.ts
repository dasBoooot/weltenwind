import { PrismaClient } from '@prisma/client';

const prisma = new PrismaClient();

export async function seedPagePermissions() {
  // World view: GET /api/worlds/:idOrSlug
  await prisma.pagePermission.upsert({
    where: { path_method_permission: { path: '/api/worlds/:idOrSlug', method: 'GET', permission: 'world.view' } as any },
    update: {},
    create: {
      path: '/api/worlds/:idOrSlug',
      method: 'GET',
      permission: 'world.view',
      scopeType: 'global',
      scopeParam: null
    }
  });

  // World state: GET /api/worlds/:idOrSlug/state (optional public; omit rule)

  // Join world: POST /api/worlds/:id/players/me
  await prisma.pagePermission.upsert({
    where: { path_method_permission: { path: '/api/worlds/:id/players/me', method: 'POST', permission: 'player.join' } as any },
    update: {},
    create: {
      path: '/api/worlds/:id/players/me',
      method: 'POST',
      permission: 'player.join',
      scopeType: 'world',
      scopeParam: 'id'
    }
  });
}


