import { PrismaClient } from '@prisma/client';
import bcrypt from 'bcrypt';

const prisma = new PrismaClient();

export async function seedUsers() {
  const passwordHash = await bcrypt.hash('AAbb1234!!', 10);

  const users = [
    // Admin-Rolle
    {
      username: 'admin',
      email: 'admin@weltenwind.de',
      passwordHash,
      isLocked: false,
      role: 'admin'
    },
    // Developer-Rolle
    {
      username: 'developer',
      email: 'developer@weltenwind.de',
      passwordHash,
      isLocked: false,
      role: 'developer'
    },
    // Support-Rolle
    {
      username: 'support',
      email: 'support@weltenwind.de',
      passwordHash,
      isLocked: false,
      role: 'support'
    },
    // User-Rolle (Standard-Spieler)
    {
      username: 'user',
      email: 'user@weltenwind.de',
      passwordHash,
      isLocked: false,
      role: 'user'
    },
    // Mod-Rolle (Welt-Moderator)
    {
      username: 'mod',
      email: 'mod@weltenwind.de',
      passwordHash,
      isLocked: false,
      role: 'mod'
    },
    // World-Admin-Rolle (Welt-Besitzer)
    {
      username: 'worldadmin',
      email: 'worldadmin@weltenwind.de',
      passwordHash,
      isLocked: false,
      role: 'world-admin'
    },
    // Zusätzliche Test-User für verschiedene Szenarien
    {
      username: 'testuser1',
      email: 'testuser1@weltenwind.de',
      passwordHash,
      isLocked: false,
      role: 'user'
    },
    {
      username: 'testuser2',
      email: 'testuser2@weltenwind.de',
      passwordHash,
      isLocked: false,
      role: 'user'
    },
    {
      username: 'moderator1',
      email: 'moderator1@weltenwind.de',
      passwordHash,
      isLocked: false,
      role: 'mod'
    },
    {
      username: 'worldowner1',
      email: 'worldowner1@weltenwind.de',
      passwordHash,
      isLocked: false,
      role: 'world-admin'
    }
  ];

  for (const userData of users) {
    const { role, ...userCreateData } = userData;
    
    await prisma.user.upsert({
      where: { username: userData.username },
      update: {},
      create: userCreateData,
    });
  }
} 