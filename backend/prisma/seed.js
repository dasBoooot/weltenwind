"use strict";
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
const client_1 = require("@prisma/client");
const bcrypt_1 = __importDefault(require("bcrypt"));
const prisma = new client_1.PrismaClient();
async function main() {
    console.log('⏳ Starte Seed...');
    const password = await bcrypt_1.default.hash('admin', 10);
    // Admin-Rolle
    const adminRole = await prisma.role.upsert({
        where: { name: 'admin' },
        update: {},
        create: {
            name: 'admin',
            description: 'Systemadministrator'
        }
    });
    // Rechte
    const permissions = [
        'manage_users',
        'view_worlds',
        'edit_worlds',
        'access_admin_panel'
    ];
    for (const name of permissions) {
        await prisma.permission.upsert({
            where: { name },
            update: {},
            create: {
                name,
                description: name.replace('_', ' ')
            }
        });
    }
    // Rolle-Rechte-Verknüpfung
    const allPermissions = await prisma.permission.findMany();
    for (const perm of allPermissions) {
        await prisma.rolePermission.upsert({
            where: {
                roleId_permissionId_scopeType_scopeObjectId: {
                    roleId: adminRole.id,
                    permissionId: perm.id,
                    scopeType: 'global',
                    scopeObjectId: null
                }
            },
            update: {},
            create: {
                roleId: adminRole.id,
                permissionId: perm.id,
                scopeType: 'global',
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
    // User-Rolle
    await prisma.userRole.upsert({
        where: {
            userId_roleId_scopeType_scopeObjectId: {
                userId: admin.id,
                roleId: adminRole.id,
                scopeType: 'global',
                scopeObjectId: null
            }
        },
        update: {},
        create: {
            userId: admin.id,
            roleId: adminRole.id,
            scopeType: 'global'
        }
    });
    console.log('✅ Seed abgeschlossen.');
}
main().catch((e) => {
    console.error('❌ Fehler beim Seed:', e);
    process.exit(1);
}).finally(() => prisma.$disconnect());
