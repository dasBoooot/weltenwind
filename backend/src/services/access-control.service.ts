import { PrismaClient } from '@prisma/client';

const prisma = new PrismaClient();

export interface ScopeContext {
  type: string;        // z. B. 'global', 'world', 'module', 'player'
  objectId: string;    // z. B. 'w123'
}

export async function hasPermission(
  userId: number,
  permissionName: string,
  scope: ScopeContext
): Promise<boolean> {
  // 1. Hole Rollen des Users (spezifische, Wildcard und globale)
  const userRoles = await prisma.userRole.findMany({
    where: {
      userId,
      scopeType: {
        in: [scope.type, 'global'] // Prüfe spezifische Scope und globale
      },
      scopeObjectId: {
        in: [scope.objectId, '*', 'global'] // Prüfe spezifische ID, Wildcard und global
      }
    }
  });

  if (userRoles.length === 0) {
    return false;
  }

  const roleIds = userRoles.map((r: { roleId: number }) => r.roleId);

  // 2. Hole Berechtigungen dieser Rollen (spezifische, Wildcard und globale)
  const matchingPermissions = await prisma.rolePermission.findMany({
    where: {
      roleId: { in: roleIds },
      scopeType: {
        in: [scope.type, 'global'] // Prüfe spezifische Scope und globale
      },
      scopeObjectId: {
        in: [scope.objectId, '*', 'global'] // Prüfe spezifische ID, Wildcard und global
      },
      permission: { name: permissionName },
      accessLevel: { not: 'none' }
    },
    include: {
      role: { select: { name: true } },
      permission: { select: { name: true } }
    }
  });

  return matchingPermissions.length > 0;
}
