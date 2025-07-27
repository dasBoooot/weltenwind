import { PrismaClient } from '@prisma/client';

const prisma = new PrismaClient();

export async function seedRoles() {
  const roles = [
    { 
      name: 'admin', 
      description: 'Plattform-Verwaltung - Vollzugriff auf alle Funktionen' 
    },
    { 
      name: 'developer', 
      description: 'Systemtests, Balancing, Events - Entwickler-Funktionen' 
    },
    { 
      name: 'support', 
      description: 'Moderation, Support, Logs - Support-Funktionen' 
    },
    { 
      name: 'user', 
      description: 'Spielerrolle - Grundlegende Spieler-Funktionen' 
    },
    { 
      name: 'mod', 
      description: 'Welt-Mod - Moderations-Funktionen in Welten' 
    },
    { 
      name: 'world-admin', 
      description: 'Besitzer/Ersteller einer Welt - Welt-Verwaltung' 
    }
  ];
  
  for (const role of roles) {
    await prisma.role.upsert({
      where: { name: role.name },
      update: {},
      create: role,
    });
  }
} 