import { seedPermissions } from './seeds/permissions.seed';
import { seedRoles } from './seeds/roles.seed';
import { seedRolePermissions } from './seeds/role-permissions.seed';
import { seedUsers } from './seeds/users.seed';
import { seedUserRoles } from './seeds/user-roles.seed';
import { seedWorlds } from './seeds/worlds.seed';

async function main() {
  console.log('🌱 Starting database seeding...');
  
  console.log('📋 Seeding permissions...');
  await seedPermissions();
  
  console.log('👥 Seeding roles...');
  await seedRoles();
  
  console.log('🔗 Seeding role permissions...');
  await seedRolePermissions();
  
  console.log('👤 Seeding users...');
  await seedUsers();
  
  console.log('👤👥 Seeding user roles...');
  await seedUserRoles();
  
  console.log('🌍 Seeding worlds...');
  await seedWorlds();
  
  console.log('✅ Database seeding completed!');
}

main()
  .catch((e) => {
    console.error('❌ Seeding failed:', e);
    process.exit(1);
  });
