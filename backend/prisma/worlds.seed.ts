import { PrismaClient } from '@prisma/client';
const prisma = new PrismaClient();

async function main() {
  console.log('🌍 Starte Welten-Seed...');

  const baseWorlds = [
    {
      name: 'Genesis',
      status: 'active',
      startsAt: new Date('2025-08-01T00:00:00Z'),
    },
    {
      name: 'Eldoria',
      status: 'upcoming',
      startsAt: new Date('2025-09-01T00:00:00Z'),
    },
    {
      name: 'Aether',
      status: 'archived',
      startsAt: new Date('2024-01-01T00:00:00Z'),
      endsAt: new Date('2024-06-30T00:00:00Z')
    }
  ];

  for (const world of baseWorlds) {
    await prisma.world.upsert({
      where: { name: world.name },
      update: {},
      create: world
    });
  }

  console.log('✅ Welten-Seed abgeschlossen.');
}

main()
  .catch((e) => {
    console.error('❌ Fehler beim Welten-Seed:', e);
    process.exit(1);
  })
  .finally(() => prisma.$disconnect());
