import { PrismaClient } from '@prisma/client';

const prisma = new PrismaClient();

// 🎯 Definierte Welten mit Assets-Bundles (Manifest-Ordner unter assets/worlds/<assets>)
const WORLD_THEMES = [
  {
    name: 'Mittelerde Abenteuer',
    status: 'open' as any,
    assets: 'tolkien'
  },
  {
    name: 'Cyberpunk 2177',
    status: 'running' as any,
    assets: 'cyberpunk'
  },
  {
    name: 'Antikes Rom',
    status: 'open' as any,
    assets: 'roman'
  },
  {
    name: 'Mystische Wälder',
    status: 'upcoming' as any,
    assets: 'nature'
  },
  {
    name: 'Weltraum Station Alpha',
    status: 'running' as any,
    assets: 'space'
  }
];

export async function seedWorlds() {
  // 🎨 THEME-SPEZIFISCHE WELTEN erstellen
  function toSlug(name: string): string {
    return name
      .toLowerCase()
      .normalize('NFD')
      .replace(/[^\w\s-]/g, '')
      .trim()
      .replace(/\s+/g, '-')
      .replace(/-+/g, '-');
  }

  // 🧹 Nur die fünf definierten Welten erstellen/aktualisieren
  for (const world of WORLD_THEMES) {
    const slug = toSlug(world.name);
    await prisma.world.upsert({
      where: { name: world.name },
      update: {
        status: world.status,
        assets: world.assets,
      } as any,
      create: ({
        name: world.name,
        slug,
        status: world.status,
        startsAt: new Date(),
        createdAt: new Date(),
        assets: world.assets,
      } as any),
    });
  }
} 