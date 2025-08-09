import { PrismaClient } from '@prisma/client';

const prisma = new PrismaClient();

// 🎨 THEME BUNDLES für verschiedene World-Typen
const WORLD_THEMES = [
  {
    name: 'Mittelerde Abenteuer',
    status: 'open' as any,
    themeBundle: 'fantasy_world_bundle',
    themeVariant: 'tolkien',
    parentTheme: 'default_world_bundle',
    themeOverrides: {
      primaryColor: '#8B4513',
      accentColor: '#DAA520',
      backgroundStyle: 'medieval'
    }
  },
  {
    name: 'Cyberpunk 2177',
    status: 'running' as any,
    themeBundle: 'sci_fi_world_bundle',
    themeVariant: 'cyberpunk',
    parentTheme: 'default_world_bundle',
    themeOverrides: {
      primaryColor: '#00FFFF',
      accentColor: '#FF00FF',
      backgroundStyle: 'neon'
    }
  },
  {
    name: 'Antikes Rom',
    status: 'open' as any,
    themeBundle: 'ancient_world_bundle',
    themeVariant: 'roman',
    parentTheme: 'default_world_bundle',
    themeOverrides: {
      primaryColor: '#800020',
      accentColor: '#FFD700',
      backgroundStyle: 'marble'
    }
  },
  {
    name: 'Mystische Wälder',
    status: 'upcoming' as any,
    themeBundle: 'fantasy_world_bundle',
    themeVariant: 'nature',
    parentTheme: 'fantasy_world_bundle',
    themeOverrides: {
      primaryColor: '#228B22',
      accentColor: '#32CD32',
      backgroundStyle: 'forest'
    }
  },
  {
    name: 'Weltraum Station Alpha',
    status: 'running' as any,
    themeBundle: 'sci_fi_world_bundle',
    themeVariant: 'space',
    parentTheme: 'sci_fi_world_bundle',
    themeOverrides: {
      primaryColor: '#191970',
      accentColor: '#00CED1',
      backgroundStyle: 'stars'
    }
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

  for (const worldData of WORLD_THEMES) {
    const slug = toSlug(worldData.name);
    await prisma.world.upsert({
      where: { name: worldData.name },
      update: {
        themeBundle: worldData.themeBundle,
        themeVariant: worldData.themeVariant,
        parentTheme: worldData.parentTheme,
        themeOverrides: worldData.themeOverrides,
      },
      create: ({
        name: worldData.name,
        slug,
        status: worldData.status as any,
        startsAt: new Date(),
        createdAt: new Date(),
        // 🎨 THEME FIELDS
        themeBundle: worldData.themeBundle,
        themeVariant: worldData.themeVariant,
        parentTheme: worldData.parentTheme,
        themeOverrides: worldData.themeOverrides,
      } as any),
    });
  }

  // 🔄 LEGACY: Basis-Welten für jeden Status beibehalten
  const statuses = ['upcoming','open','running','active','closed','archived'] as const;
  for (const status of statuses) {
    const name = `Basis_${status}`;
    const slug = toSlug(name);
    await prisma.world.upsert({
      where: { name },
      update: {},
      create: ({
        name,
        slug,
        status: status as any,
        startsAt: new Date(),
        createdAt: new Date(),
        // 🎨 DEFAULT THEME
        themeBundle: 'default_world_bundle',
        themeVariant: 'standard',
      } as any),
    });
  }
} 