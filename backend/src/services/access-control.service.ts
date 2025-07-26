import { PrismaClient } from '@prisma/client';

const prisma = new PrismaClient();

export interface ScopeContext {
  type: string;        // z. B. 'global', 'world', 'module', 'player'
  objectId: string;    // z. B. 'w123'
}

export async function hasPermission(
  userId: number,
  permissionName: string,
  scope: ScopeContext
): Promise<boolean> {
  // 1. Hole Rollen des Users
  const userRoles = await prisma.userRole.findMany({
    where: {
      userId,
      scopeType: scope.type,
      scopeObjectId: scope.objectId
    }
  });

  if (userRoles.length === 0) return false;

  const roleIds = userRoles.map((r) => r.roleId);

  // 2. Hole Berechtigungen dieser Rollen
  const matchingPermissions = await prisma.rolePermission.findMany({
    where: {
      roleId: { in: roleIds },
      scopeType: scope.type,
      scopeObjectId: scope.objectId,
      permission: { name: permissionName },
      accessLevel: { not: 'none' }
    }
  });

  return matchingPermissions.length > 0;
}
