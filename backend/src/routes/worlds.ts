import express from 'express';
import { Request, Response, NextFunction } from 'express';
import { PrismaClient, WorldStatus } from '@prisma/client';
import { authenticate, AuthenticatedRequest } from '../middleware/authenticate';
import { hasPermission } from '../services/access-control.service';
import { jwtConfig } from '../config/jwt.config';
import jwt from 'jsonwebtoken';
import prisma from '../libs/prisma';

import { loggers } from '../config/logger.config';

// Sichere User-Guard Funktion
function requireUser(req: AuthenticatedRequest): asserts req is Required<AuthenticatedRequest> {
  if (!req.user) {
    throw new Error('Fehlender Benutzerkontext');
  }
}

export async function authenticateOptional(req: any, res: Response, next: NextFunction) {
  const authHeader = req.headers.authorization;
  if (authHeader?.startsWith('Bearer ')) {
    const token = authHeader.split(' ')[1];
    try {
      const payload = jwt.verify(token, jwtConfig.getSecret()) as { userId: number; username: string };
      const user = await prisma.user.findUnique({ where: { id: payload.userId } });
      if (user && !user.isLocked) {
        req.user = { id: user.id, username: user.username };
      }
    } catch (err) {
      // Kein gültiges Token, ignoriere
    }
  }
  next();
}

const router = express.Router();

// 🟢 Pfadspezifische Routen (korrekt zuerst)

/**
 * GET /api/worlds/:id/players/me
 * Eigenen Spielstatus in einer Welt abrufen
 * Permission: player.view_own (world scope)
 */
router.get('/:id/players/me', authenticate, async (req: AuthenticatedRequest, res) => {
  const worldId = parseInt(req.params.id);
  if (isNaN(worldId)) {
    return res.status(400).json({ error: 'Ungültige Welt-ID' });
  }

  requireUser(req);
  
  // Permission prüfen: player.view_own
  const allowed = await hasPermission(req.user.id, 'player.view_own', {
    type: 'world',
    objectId: worldId.toString()
  });

  if (!allowed) {
    return res.status(403).json({ error: 'Keine Berechtigung zum Anzeigen des eigenen Spielstatus' });
  }

  const player = await prisma.player.findUnique({
    where: {
      userId_worldId: {
        userId: req.user.id,
        worldId: worldId
      }
    }
  });
  if (!player) {
    return res.status(404).json({ error: 'Kein Spielstatus für diese Welt gefunden' });
  }
  res.json(player);
});

/**
 * GET /api/worlds/:id/players
 * Alle Spieler einer Welt anzeigen
 * Permission: player.view_all (world scope)
 */
router.get('/:id/players', authenticate, async (req: AuthenticatedRequest, res) => {
  const worldId = parseInt(req.params.id);
  if (isNaN(worldId)) {
    return res.status(400).json({ error: 'Ungültige Welt-ID' });
  }

  requireUser(req);
  
  // Permission prüfen: player.view_all
  const allowed = await hasPermission(req.user.id, 'player.view_all', {
    type: 'world',
    objectId: worldId.toString()
  });

  if (!allowed) {
    return res.status(403).json({ error: 'Keine Berechtigung zum Anzeigen aller Spieler' });
  }

  // Alle Spieler der Welt abrufen
  const players = await prisma.player.findMany({
    where: { worldId },
    include: {
      user: {
        select: {
          id: true,
          username: true,
          email: true
        }
      }
    }
  });
  res.json(players.map(p => p.user));
});

/**
 * POST /api/worlds/:id/join
 * Welt beitreten
 * Permission: player.join (world scope)
 */
router.post('/:id/join', authenticate, async (req: AuthenticatedRequest, res) => {
  const worldId = parseInt(req.params.id);
  const { inviteCode } = req.body;

  if (isNaN(worldId)) {
    return res.status(400).json({ error: 'Ungültige Welt-ID' });
  }

  const world = await prisma.world.findUnique({ where: { id: worldId } });
  if (!world) {
    return res.status(404).json({ error: 'Welt nicht gefunden' });
  }
  if (world.status === 'archived') {
    return res.status(403).json({ error: 'Welt ist archiviert' });
  }

  requireUser(req);
  
  // Permission prüfen: player.join
  const allowed = await hasPermission(req.user.id, 'player.join', {
    type: 'world',
    objectId: worldId.toString()
  });

  if (!allowed) {
    return res.status(403).json({ error: 'Keine Berechtigung zum Beitritt dieser Welt' });
  }

  // Invite-Code prüfen (optional, falls Welten geschlossen sind)
  // TODO: Invite-Logik ergänzen, falls benötigt

  // Prüfen, ob Player-Eintrag schon existiert
  const existing = await prisma.player.findUnique({
    where: {
      userId_worldId: {
        userId: req.user.id,
        worldId: worldId
      }
    }
  });
  if (existing) {
    return res.status(200).json({
      success: true,
      code: 'already_joined',
      message: 'Bereits beigetreten',
      data: { playerId: existing.id }
    });
  }

  // Player-Eintrag anlegen
  const player = await prisma.player.create({
    data: {
      userId: req.user.id,
      worldId: worldId,
      joinedAt: new Date()
    }
  });
  res.status(200).json({
    success: true,
    code: 'success',
    message: 'Beitritt erfolgreich',
    data: { playerId: player.id }
  });
});

/**
 * DELETE /api/worlds/:id/players/me
 * Welt verlassen
 * Permission: player.leave (world scope)
 */
router.delete('/:id/players/me', authenticate, async (req: AuthenticatedRequest, res) => {
  const worldId = parseInt(req.params.id);
  if (isNaN(worldId)) {
    return res.status(400).json({ error: 'Ungültige Welt-ID' });
  }

  requireUser(req);
  
  // Permission prüfen: player.leave
  const allowed = await hasPermission(req.user.id, 'player.leave', {
    type: 'world',
    objectId: worldId.toString()
  });

  if (!allowed) {
    return res.status(403).json({ error: 'Keine Berechtigung zum Verlassen dieser Welt' });
  }

  const player = await prisma.player.findUnique({
    where: {
      userId_worldId: {
        userId: req.user.id,
        worldId
      }
    }
  });
  if (!player) {
    return res.status(404).json({ error: 'Kein Spielstatus für diese Welt gefunden' });
  }
  await prisma.player.delete({ where: { id: player.id } });
  res.json({
    success: true,
    code: 'success',
    message: 'Welt erfolgreich verlassen'
  });
});

/**
 * POST /api/worlds/:id/edit
 * Status einer Welt ändern (z. B. "active", "upcoming", "archived")
 * Permission: world.edit (world scope)
 */
router.post('/:id/edit', authenticate, async (req: AuthenticatedRequest, res) => {
  const worldId = parseInt(req.params.id);
  const { status } = req.body;

  if (isNaN(worldId)) {
    return res.status(400).json({ error: 'Ungültige Welt-ID' });
  }

  if (!status || typeof status !== 'string') {
    return res.status(400).json({ error: 'Neuer Status erforderlich' });
  }
  if (!Object.values(WorldStatus).includes(status as WorldStatus)) {
    return res.status(400).json({ error: 'Ungültiger Status-Wert' });
  }

  const world = await prisma.world.findUnique({ where: { id: worldId } });

  if (!world) {
    return res.status(404).json({ error: 'Welt nicht gefunden' });
  }

  requireUser(req);
  
  const allowed = await hasPermission(req.user.id, 'world.edit', {
    type: 'world',
    objectId: worldId.toString()
  });

  if (!allowed) {
    return res.status(403).json({ error: 'Keine Bearbeitungsberechtigung für diese Welt' });
  }

  const updated = await prisma.world.update({
    where: { id: worldId },
    data: { status: status as WorldStatus }
  });

  res.json({ success: true, world: updated });
});

/**
 * POST /api/worlds/:id/pre-register
 * Vorregistrierung für eine Welt (öffentlich, keine Authentifizierung erforderlich)
 * 
 * TODO: Rate-Limiting hinzufügen (express-rate-limit)
 * - Max 3 Pre-Registrations pro IP pro Stunde
 * - Spam-Schutz für öffentliche Endpunkte
 */
router.post('/:id/pre-register', async (req, res) => {
  const worldId = parseInt(req.params.id);
  const { email, config } = req.body;
  if (isNaN(worldId)) {
    return res.status(400).json({ error: 'Ungültige Welt-ID' });
  }
  if (!email) {
    return res.status(400).json({ error: 'E-Mail erforderlich' });
  }
  // Prüfen, ob PreRegistration schon existiert
  const existing = await prisma.preRegistration.findUnique({
    where: {
      email_worldId: {
        email,
        worldId
      }
    }
  });
  if (existing) {
    return res.status(200).json({
      success: true,
      code: 'already_registered',
      message: 'Bereits vorregistriert'
    });
  }
  const preReg = await prisma.preRegistration.create({
    data: {
      email,
      worldId,
      config: config || null
    }
  });
  res.status(200).json({
    success: true,
    code: 'success',
    message: 'Pre-Registration erfolgreich',
    data: { id: preReg.id }
  });
});

/**
 * GET /api/worlds/:id/pre-register/me
 * Eigenen Pre-Register-Status in einer Welt abrufen
 * Permission: player.view_own (world scope)
 */
router.get('/:id/pre-register/me', authenticate, async (req: AuthenticatedRequest, res) => {
  const worldId = parseInt(req.params.id);
  if (isNaN(worldId)) {
    return res.status(400).json({ error: 'Ungültige Welt-ID' });
  }

  requireUser(req);
  
  // Permission prüfen: player.view_own
  const allowed = await hasPermission(req.user.id, 'player.view_own', {
    type: 'world',
    objectId: worldId.toString()
  });

  if (!allowed) {
    return res.status(403).json({ error: 'Keine Berechtigung zum Anzeigen des eigenen Pre-Register-Status' });
  }

  // User mit E-Mail abrufen
  const user = await prisma.user.findUnique({
    where: { id: req.user.id },
    select: { email: true }
  });

  if (!user) {
    return res.status(404).json({ error: 'Benutzer nicht gefunden' });
  }

  const preRegistration = await prisma.preRegistration.findFirst({
    where: {
      worldId: worldId,
      email: user.email
    }
  });

  res.json({
    success: true,
    isPreRegistered: !!preRegistration,
    data: preRegistration ? {
      id: preRegistration.id,
      email: preRegistration.email,
      createdAt: preRegistration.createdAt,
      config: preRegistration.config
    } : null
  });
});

/**
 * DELETE /api/worlds/:id/pre-register
 * Vorregistrierung zurückziehen (öffentlich, keine Authentifizierung erforderlich)
 */
router.delete('/:id/pre-register', async (req, res) => {
  const worldId = parseInt(req.params.id);
  const email = req.query.email as string | undefined;
  if (isNaN(worldId)) {
    return res.status(400).json({ error: 'Ungültige Welt-ID' });
  }
  if (!email) {
    return res.status(400).json({ error: 'E-Mail erforderlich' });
  }
  const preReg = await prisma.preRegistration.findUnique({
    where: {
      email_worldId: {
        email,
        worldId
      }
    }
  });
  if (!preReg) {
    return res.status(404).json({ error: 'Keine Pre-Registration für diese Welt und E-Mail gefunden' });
  }
  await prisma.preRegistration.delete({ where: { id: preReg.id } });
  res.json({
    success: true,
    code: 'success',
    message: 'Pre-Registration zurückgezogen'
  });
});

// 🟡 Allgemeinere Routen (gehören ans Ende)

/**
 * GET /api/worlds/:id/state
 * Welt-Status öffentlich abrufen (keine Authentifizierung erforderlich)
 */
router.get('/:id/state', async (req, res) => {
  const worldId = parseInt(req.params.id);
  if (isNaN(worldId)) {
    return res.status(400).json({ error: 'Ungültige Welt-ID' });
  }
  const world = await prisma.world.findUnique({ where: { id: worldId } });
  if (!world) {
    return res.status(404).json({ error: 'Welt nicht gefunden' });
  }
  const playerCount = await prisma.player.count({ where: { worldId } });
  res.json({ state: world.status, playerCount });
});

/**
 * GET /api/worlds
 * Abrufen aller nicht archivierten Welten
 * Permission: world.view (global scope)
 */
router.get('/', authenticate, async (req: AuthenticatedRequest, res) => {
  requireUser(req);
  
  const allowed = await hasPermission(req.user.id, 'world.view', {
    type: 'global',
    objectId: 'global'
  });

  if (!allowed) {
    return res.status(403).json({ error: 'Keine Berechtigung zum Weltzugriff' });
  }

  const worlds = await prisma.world.findMany({
    where: { status: { not: 'archived' } },
    orderBy: { startsAt: 'asc' }
  });

  res.json(worlds);
});

/**
 * GET /api/worlds/:id
 * Abrufen einer einzelnen Welt
 * Permission: world.view (global scope)
 */
router.get('/:id', authenticate, async (req: AuthenticatedRequest, res) => {
  // Debug-Info entfernt - bereits in API-Logging erfasst
  const worldId = parseInt(req.params.id, 10);
  
  if (isNaN(worldId)) {
    return res.status(400).json({ error: 'Ungültige Welt-ID' });
  }

  requireUser(req);
  
  const allowed = await hasPermission(req.user.id, 'world.view', {
    type: 'global',
    objectId: 'global'
  });

  if (!allowed) {
    return res.status(403).json({ error: 'Keine Berechtigung zum Weltzugriff' });
  }

  const world = await prisma.world.findUnique({
    where: { id: worldId }
  });

  if (!world) {
    return res.status(404).json({ error: 'Welt nicht gefunden' });
  }

  res.json(world);
});

export default router;
