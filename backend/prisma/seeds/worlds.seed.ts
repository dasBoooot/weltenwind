import { PrismaClient, WorldStatus } from '@prisma/client';

const prisma = new PrismaClient();

// 🎨 THEME BUNDLES für verschiedene World-Typen
const WORLD_THEMES = [
  {
    name: 'Mittelerde Abenteuer',
    status: 'open' as WorldStatus,
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
    status: 'running' as WorldStatus,
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
    status: 'open' as WorldStatus,
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
    status: 'upcoming' as WorldStatus,
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
    status: 'running' as WorldStatus,
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
  for (const worldData of WORLD_THEMES) {
    await prisma.world.upsert({
      where: { name: worldData.name },
      update: {
        themeBundle: worldData.themeBundle,
        themeVariant: worldData.themeVariant,
        parentTheme: worldData.parentTheme,
        themeOverrides: worldData.themeOverrides,
      },
      create: {
        name: worldData.name,
        status: worldData.status,
        startsAt: new Date(),
        createdAt: new Date(),
        // 🎨 THEME FIELDS
        themeBundle: worldData.themeBundle,
        themeVariant: worldData.themeVariant,
        parentTheme: worldData.parentTheme,
        themeOverrides: worldData.themeOverrides,
      },
    });
  }

  // 🔄 LEGACY: Basis-Welten für jeden Status beibehalten
  for (const status of Object.values(WorldStatus)) {
    await prisma.world.upsert({
      where: { name: `Basis_${status}` },
      update: {},
      create: {
        name: `Basis_${status}`,
        status,
        startsAt: new Date(),
        createdAt: new Date(),
        // 🎨 DEFAULT THEME
        themeBundle: 'default_world_bundle',
        themeVariant: 'standard',
      },
    });
  }
} 