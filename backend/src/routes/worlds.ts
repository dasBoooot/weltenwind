import express from 'express';
import { PrismaClient, WorldStatus } from '@prisma/client';
import { authenticate, AuthenticatedRequest } from '../middleware/authenticate';
import { hasPermission } from '../services/access-control.service';
import { Request, Response, NextFunction } from 'express';
import jwt from 'jsonwebtoken';
import prisma from '../libs/prisma';

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
      const payload = jwt.verify(token, process.env.JWT_SECRET || 'dev-secret') as { userId: number; username: string };
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
 * POST /api/worlds/:id/invites
 * Einladungen für eine Welt erstellen (authentifiziert)
 * Permission: invite.create (world scope)
 */
router.post('/:id/invites', authenticate, async (req: AuthenticatedRequest, res) => {
  const worldId = parseInt(req.params.id);
  const { email, emails } = req.body;
  if (isNaN(worldId)) {
    return res.status(400).json({ error: 'Ungültige Welt-ID' });
  }

  requireUser(req);
  
  // Permission prüfen: invite.create
  const allowed = await hasPermission(req.user.id, 'invite.create', {
    type: 'world',
    objectId: worldId.toString()
  });

  if (!allowed) {
    return res.status(403).json({ error: 'Keine Berechtigung zum Erstellen von Einladungen' });
  }

  const emailList = [];
  if (email) emailList.push(email);
  if (Array.isArray(emails)) emailList.push(...emails);
  if (emailList.length === 0) {
    return res.status(400).json({ error: 'Mindestens eine E-Mail erforderlich' });
  }

  // E-Mail-Deduplizierung
  const emailSet = new Set(emailList.map(e => e.toLowerCase().trim()));
  if (emailSet.size === 0) {
    return res.status(400).json({ error: 'Mindestens eine gültige E-Mail erforderlich' });
  }

  const invites = [];
  for (const mail of emailSet) {
    const token = require('crypto').randomBytes(32).toString('hex');
    const invite = await prisma.invite.create({
      data: {
        worldId,
        email: mail,
        token,
        invitedById: req.user.id,
        expiresAt: new Date(Date.now() + 1000 * 60 * 60 * 24 * 7) // 7 Tage gültig
      }
    });
    // TODO: Mailversand mit Token
    // await inviteService.sendInviteEmail({ email: mail, token, worldId });
    invites.push(invite);
  }
  res.status(200).json({
    success: true,
    code: 'success',
    message: 'Einladung(en) verschickt',
    data: { invites: invites.map(i => ({ email: i.email, token: i.token })) }
  });
});

/**
 * POST /api/worlds/:id/invites/public
 * Öffentliche Einladungen für eine Welt erstellen (keine Authentifizierung erforderlich)
 * Für Einladungen an nicht-registrierte Benutzer
 * 
 * TODO: Rate-Limiting hinzufügen (express-rate-limit)
 * - Max 5 Einladungen pro IP pro Stunde
 * - Spam-Schutz für öffentliche Endpunkte
 */
router.post('/:id/invites/public', async (req, res) => {
  const worldId = parseInt(req.params.id);
  const { email, emails } = req.body;
  if (isNaN(worldId)) {
    return res.status(400).json({ error: 'Ungültige Welt-ID' });
  }

  // Prüfe ob Welt existiert und öffentlich ist
  const world = await prisma.world.findUnique({ where: { id: worldId } });
  if (!world) {
    return res.status(404).json({ error: 'Welt nicht gefunden' });
  }

  // Nur für offene Welten erlauben
  if (world.status !== 'open' && world.status !== 'upcoming') {
    return res.status(403).json({ error: 'Welt ist nicht für Einladungen geöffnet' });
  }

  const emailList = [];
  if (email) emailList.push(email);
  if (Array.isArray(emails)) emailList.push(...emails);
  if (emailList.length === 0) {
    return res.status(400).json({ error: 'Mindestens eine E-Mail erforderlich' });
  }

  // E-Mail-Deduplizierung
  const emailSet = new Set(emailList.map(e => e.toLowerCase().trim()));
  if (emailSet.size === 0) {
    return res.status(400).json({ error: 'Mindestens eine gültige E-Mail erforderlich' });
  }

  const invites = [];
  for (const mail of emailSet) {
    const token = require('crypto').randomBytes(32).toString('hex');
    const invite = await prisma.invite.create({
      data: {
        worldId,
        email: mail,
        token,
        invitedById: null, // Kein authentifizierter Benutzer
        expiresAt: new Date(Date.now() + 1000 * 60 * 60 * 24 * 7) // 7 Tage gültig
      }
    });
    // TODO: Mailversand mit Token
    // await inviteService.sendInviteEmail({ email: mail, token, worldId });
    invites.push(invite);
  }
  res.status(200).json({
    success: true,
    code: 'success',
    message: 'Öffentliche Einladung(en) verschickt',
    data: { invites: invites.map(i => ({ email: i.email, token: i.token })) }
  });
});

/**
 * GET /api/worlds/:id/invites
 * Alle Einladungen einer Welt anzeigen (öffentlich, keine Authentifizierung erforderlich)
 */
router.get('/:id/invites', async (req, res) => {
  const worldId = parseInt(req.params.id);
  
  if (isNaN(worldId)) {
    return res.status(400).json({ error: 'Ungültige Welt-ID' });
  }

  const invites = await prisma.invite.findMany({
    where: { worldId },
    select: {
      id: true,
      email: true,
      token: true,
      createdAt: true,
      expiresAt: true,
      invitedBy: {
        select: {
          username: true
        }
      }
    },
    orderBy: { createdAt: 'desc' }
  });

  res.json(invites);
});

/**
 * DELETE /api/worlds/:id/invites/:inviteId
 * Einladung löschen (hybrid: JWT für authentifizierte Benutzer, Token für nicht-authentifizierte)
 */
router.delete('/:id/invites/:inviteId', async (req, res) => {
  const worldId = parseInt(req.params.id);
  const inviteId = parseInt(req.params.inviteId);
  
  if (isNaN(worldId) || isNaN(inviteId)) {
    return res.status(400).json({ error: 'Ungültige Welt-ID oder Invite-ID' });
  }

  // Prüfe ob Invite existiert
  const invite = await prisma.invite.findFirst({
    where: {
      id: inviteId,
      worldId: worldId
    },
    include: {
      invitedBy: {
        select: {
          id: true,
          username: true
        }
      }
    }
  });

  if (!invite) {
    return res.status(404).json({ error: 'Einladung nicht gefunden' });
  }

  // Fall 1: Authentifizierter Benutzer (JWT)
  if (req.headers.authorization && req.headers.authorization.trim() !== '' && req.headers.authorization.startsWith('Bearer ')) {
    try {
      // JWT Token verifizieren
      const token = req.headers.authorization.replace('Bearer ', '').trim();
      if (!token) {
        return res.status(401).json({ error: 'Token fehlt im Authorization Header' });
      }
      
      const decoded = jwt.verify(token, process.env.JWT_SECRET!) as any;
      // JWT.verify prüft automatisch die Ablaufzeit gegen Server-Zeit
      
      // Permission prüfen: invite.delete
      const allowed = await hasPermission(decoded.userId, 'invite.delete', {
        type: 'world',
        objectId: worldId.toString()
      });

      if (!allowed) {
        return res.status(403).json({ error: 'Keine Berechtigung zum Löschen von Einladungen' });
      }

      // Privilegierter Benutzer kann alle Einladungen löschen
      await prisma.invite.delete({ where: { id: inviteId } });
      return res.json({ message: 'Einladung erfolgreich gelöscht' });
    } catch (error) {
      return res.status(401).json({ error: 'Ungültiger JWT Token' });
    }
  }

  // Fall 2: Nicht-authentifizierter Benutzer (Token-basiert)
  const { token } = req.body;
  if (typeof token !== 'string' || !token.trim()) {
    return res.status(400).json({ error: 'Gültiger Token erforderlich' });
  }

  // Prüfe ob Token stimmt
  if (invite.token !== token) {
    return res.status(403).json({ error: 'Ungültiger Token für diese Einladung' });
  }

  // Nur der Einladende kann seine eigene Einladung löschen (wenn invitedById nicht null ist)
  if (invite.invitedById) {
    // Hier könnten wir zusätzliche Logik hinzufügen, um zu prüfen ob der Token-Besitzer
    // tatsächlich der Einladende ist (z.B. über E-Mail-Verifikation)
    // Für jetzt erlauben wir es, wenn der Token stimmt
  }

  await prisma.invite.delete({ where: { id: inviteId } });
  res.json({ message: 'Einladung erfolgreich gelöscht' });
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

export default router;
