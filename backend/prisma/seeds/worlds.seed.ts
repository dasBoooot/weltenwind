import { PrismaClient, WorldStatus } from '@prisma/client';

const prisma = new PrismaClient();

export async function seedWorlds() {
  for (const status of Object.values(WorldStatus)) {
    await prisma.world.upsert({
      where: { name: `Welt_${status}` },
      update: {},
      create: {
        name: `Welt_${status}`,
        status,
        startsAt: new Date(),
        createdAt: new Date(),
      },
    });
  }
} 