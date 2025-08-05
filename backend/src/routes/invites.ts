import express from 'express';
import prisma from '../libs/prisma';
import { loggers } from '../config/logger.config';
import { AuthenticatedRequest } from '../middleware/authenticate';
import { authenticate } from '../middleware/authenticate';
import { hasPermission } from '../services/access-control.service';
import { jwtConfig } from '../config/jwt.config';
import jwt from 'jsonwebtoken';
import crypto from 'crypto';

// ✅ Konfiguration aus .env
const INVITE_EXPIRY_DAYS = parseInt(process.env.INVITE_EXPIRY_DAYS || '7', 10);

const router = express.Router();

// Sichere User-Guard Funktion
function requireUser(req: AuthenticatedRequest): asserts req is Required<AuthenticatedRequest> {
  if (!req.user) {
    throw new Error('Fehlender Benutzerkontext');
  }
}

/**
 * GET /api/invites/validate/:token
 * Token validieren und Welt-Informationen abrufen
 * Prüft auch E-Mail-Berechtigung basierend auf Login-Status
 */
router.get('/validate/:token', async (req, res) => {
  const { token } = req.params;
  const authHeader = req.headers.authorization;
  let currentUser = null;

  // Optional: Aktueller User falls angemeldet
  if (authHeader?.startsWith('Bearer ')) {
    const userToken = authHeader.split(' ')[1];
    try {
      const { jwtConfig } = require('../config/jwt.config');
      const jwt = require('jsonwebtoken');
      const payload = jwt.verify(userToken, jwtConfig.getSecret()) as { userId: number };
      currentUser = await prisma.user.findUnique({ 
        where: { id: payload.userId },
        select: { id: true, username: true, email: true }
      });
    } catch (err) {
      // Token ungültig - User gilt als nicht angemeldet
      currentUser = null;
    }
  }

  if (!token) {
    loggers.system.warn('❌ Invite-Token fehlt', { endpoint: '/api/invites/validate' });
    return res.status(400).json({ error: 'Token ist erforderlich' });
  }

  try {
    loggers.system.info('🔍 Invite-Token wird validiert', { 
      token: token.substring(0, 8) + '...',
      endpoint: '/api/invites/validate',
      userLoggedIn: !!currentUser,
      currentUserEmail: currentUser?.email
    });

    // Token in der Datenbank suchen mit korrekten Feldern
    const invite = await prisma.invite.findFirst({
      where: {
        token: token,
        expiresAt: {
          gt: new Date() // Token muss noch gültig sein
        }
      },
      include: {
        world: {
          select: {
            id: true,
            name: true,
            status: true,
            themeBundle: true,
            themeVariant: true,
            createdAt: true,
            startsAt: true,
            endsAt: true
          }
        },
        invitedBy: {
          select: {
            username: true
          }
        }
      }
    });

    if (!invite) {
      loggers.system.warn('❌ Invite-Token ungültig oder abgelaufen', { 
        token: token.substring(0, 8) + '...',
        endpoint: '/api/invites/validate'
      });
      return res.status(404).json({ 
        error: 'Einladung nicht gefunden oder abgelaufen',
        details: 'Der Einladungslink ist ungültig oder bereits abgelaufen.'
      });
    }

    // Prüfe ob die Welt noch aktiv ist - Invites sind auch für zukünftige Welten (upcoming) gültig
    const activeStatuses = ['upcoming', 'open', 'running'];
    if (invite.world && !activeStatuses.includes(invite.world.status)) {
      loggers.system.warn('❌ Eingeladene Welt ist nicht verfügbar', { 
        worldId: invite.worldId,
        worldStatus: invite.world.status,
        token: token.substring(0, 8) + '...'
      });
      return res.status(400).json({ 
        error: 'Welt nicht verfügbar',
        details: `Die eingeladene Welt ist ${invite.world.status === 'closed' ? 'bereits beendet' : invite.world.status === 'archived' ? 'archiviert' : 'nicht verfügbar'}.`
      });
    }

    // E-Mail-Berechtigung prüfen
    let userStatus: 'not_logged_in' | 'user_exists_not_logged_in' | 'correct_email' | 'wrong_email';
    let requiresAction: 'register' | 'login' | 'join_world' | 'logout_and_register';

    if (currentUser) {
      if (currentUser.email === invite.email) {
        userStatus = 'correct_email';
        requiresAction = 'join_world';
      } else {
        userStatus = 'wrong_email';
        requiresAction = 'logout_and_register';
      }
    } else {
      // Prüfe ob User mit dieser E-Mail bereits existiert
      const existingUser = await prisma.user.findUnique({
        where: { email: invite.email },
        select: { id: true }
      });
      
      if (existingUser) {
        // User existiert, ist aber nicht angemeldet → Login erforderlich
        userStatus = 'user_exists_not_logged_in';
        requiresAction = 'login';
      } else {
        // User existiert nicht → Registrierung erforderlich
        userStatus = 'not_logged_in';
        requiresAction = 'register';
      }
    }

    loggers.system.info('✅ Invite-Token erfolgreich validiert', {
      worldId: invite.worldId,
      worldName: invite.world?.name,
      inviterName: invite.invitedBy?.username,
      inviteEmail: invite.email,
      userStatus,
      requiresAction,
      currentUserEmail: currentUser?.email,
      token: token.substring(0, 8) + '...'
    });

    // Erfolgreiche Antwort mit Welt-Informationen und User-Status
    res.json({
      success: true,
      data: {
        world: invite.world,
        invite: {
          email: invite.email,
          createdAt: invite.createdAt,
          expiresAt: invite.expiresAt,
          acceptedAt: invite.acceptedAt, // Wichtig für Frontend-Status
          invitedBy: invite.invitedBy ? {
            username: invite.invitedBy.username
          } : null
        },
        userStatus: {
          status: userStatus,
          requiresAction: requiresAction,
          currentUser: currentUser ? {
            username: currentUser.username,
            email: currentUser.email
          } : null
        }
      }
    });

  } catch (error) {
    loggers.system.error('❌ Fehler bei Invite-Token-Validierung', error, {
      token: token.substring(0, 8) + '...'
    });

    res.status(500).json({
      error: 'Interner Serverfehler',
      details: 'Fehler bei der Token-Validierung'
    });
  }
});

// POST /api/invites/accept/:token - Invite akzeptieren und User der Welt hinzufügen
router.post('/accept/:token', authenticate, async (req: AuthenticatedRequest, res) => {
  const { token } = req.params;
  const userId = req.user!.id;

  loggers.system.info('🎫 Invite-Accept-Request empfangen', {
    token: token.substring(0, 8) + '...',
    userId
  });

  if (!token) {
    loggers.system.warn('⚠️ Invite-Accept ohne Token', { userId });
    return res.status(400).json({
      error: 'Token erforderlich'
    });
  }

  try {
    // Transaktion für Invite-Akzeptierung
    const result = await prisma.$transaction(async (tx) => {
      // 1. User-E-Mail laden
      const user = await tx.user.findUnique({
        where: { id: userId },
        select: { email: true }
      });

      if (!user) {
        throw new Error('USER_NOT_FOUND');
      }

      const userEmail = user.email;

      // 2. Invite finden und validieren
      const invite = await tx.invite.findUnique({
        where: { token },
        include: {
          world: {
            select: { 
              id: true, 
              name: true, 
              status: true,
              startsAt: true,
              endsAt: true
            }
          },
          invitedBy: {
            select: { 
              id: true, 
              username: true 
            }
          }
        }
      });

      if (!invite) {
        loggers.system.warn('⚠️ Ungültiger Invite-Token bei Accept', {
          token: token.substring(0, 8) + '...',
          userId
        });
        throw new Error('INVALID_TOKEN');
      }

      // 3. Prüfe ob Invite bereits akzeptiert
      if (invite.acceptedAt) {
        loggers.system.warn('⚠️ Invite bereits akzeptiert', {
          token: token.substring(0, 8) + '...',
          acceptedAt: invite.acceptedAt,
          userId
        });
        throw new Error('ALREADY_ACCEPTED');
      }

      // 4. Prüfe ob Invite abgelaufen
      if (invite.expiresAt && invite.expiresAt < new Date()) {
        loggers.system.warn('⚠️ Abgelaufener Invite-Token bei Accept', {
          token: token.substring(0, 8) + '...',
          expiresAt: invite.expiresAt,
          userId
        });
        throw new Error('TOKEN_EXPIRED');
      }

      // 5. Prüfe E-Mail-Match
      if (invite.email !== userEmail) {
        loggers.system.warn('⚠️ E-Mail-Mismatch bei Invite-Accept', {
          inviteEmail: invite.email,
          userEmail,
          userId
        });
        throw new Error('EMAIL_MISMATCH');
      }

      // 6. Prüfe ob Welt verfügbar (upcoming oder active)
      const allowedStatuses = ['upcoming', 'active', 'open'];
      if (!allowedStatuses.includes(invite.world?.status || '')) {
        loggers.system.warn('⚠️ Welt nicht verfügbar für Join', {
          worldStatus: invite.world?.status,
          worldId: invite.worldId,
          userId
        });
        throw new Error('WORLD_NOT_AVAILABLE');
      }

      const worldStatus = invite.world?.status;

      // 7. Prüfe ob User bereits Teilnehmer ist
      const existingPlayer = await tx.player.findUnique({
        where: {
          userId_worldId: {
            userId: userId,
            worldId: invite.worldId
          }
        }
      });

      const existingPreRegistration = await tx.preRegistration.findUnique({
        where: {
          email_worldId: {
            email: userEmail,
            worldId: invite.worldId
          }
        }
      });

      if (worldStatus === 'upcoming') {
        // Upcoming World: Nur Vorregistrierung
        if (existingPreRegistration) {
          loggers.system.info('✅ User bereits vorregistriert - markiere Invite als akzeptiert', {
            worldId: invite.worldId,
            userId
          });
        } else {
          // Vorregistrierung erstellen
          await tx.preRegistration.create({
            data: {
              worldId: invite.worldId,
              userId: userId,
              email: userEmail,
              createdAt: new Date()
            }
          });

          loggers.system.info('✅ User für Welt vorregistriert', {
            worldId: invite.worldId,
            worldName: invite.world?.name,
            userId
          });
        }
      } else {
        // Active/Open World: Direkter Join
        if (existingPlayer) {
          loggers.system.info('✅ User bereits in Welt - markiere Invite als akzeptiert', {
            worldId: invite.worldId,
            userId
          });
        } else {
          // User zur Welt hinzufügen
          await tx.player.create({
            data: {
              worldId: invite.worldId,
              userId: userId,
              joinedAt: new Date()
            }
          });

          loggers.system.info('✅ User der Welt hinzugefügt', {
            worldId: invite.worldId,
            worldName: invite.world?.name,
            userId
          });
        }
      }

      // 9. Invite als akzeptiert markieren
      const updatedInvite = await tx.invite.update({
        where: { id: invite.id },
        data: { acceptedAt: new Date() }
      });

      loggers.system.info('✅ Invite erfolgreich akzeptiert', {
        inviteId: invite.id,
        worldId: invite.worldId,
        worldName: invite.world?.name,
        userId,
        acceptedAt: updatedInvite.acceptedAt
      });

      return {
        invite: updatedInvite,
        world: invite.world,
        invitedBy: invite.invitedBy
      };
    });

    // Erfolgreich - Welt-Info zurückgeben
    res.json({
      success: true,
      data: {
        message: 'Invite erfolgreich akzeptiert',
        world: {
          id: result.world?.id,
          name: result.world?.name,
          status: result.world?.status
        },
        invitedBy: result.invitedBy?.username,
        acceptedAt: result.invite.acceptedAt
      }
    });

  } catch (error) {
    // Spezifische Fehlerbehandlung
    if (error instanceof Error) {
      switch (error.message) {
        case 'USER_NOT_FOUND':
          return res.status(404).json({
            error: 'Benutzer nicht gefunden'
          });
        case 'INVALID_TOKEN':
          return res.status(404).json({
            error: 'Ungültiger Invite-Token'
          });
        case 'ALREADY_ACCEPTED':
          return res.status(409).json({
            error: 'Invite bereits akzeptiert'
          });
        case 'TOKEN_EXPIRED':
          return res.status(410).json({
            error: 'Invite-Token ist abgelaufen'
          });
        case 'EMAIL_MISMATCH':
          return res.status(403).json({
            error: 'Diese Einladung ist nicht für deine E-Mail-Adresse bestimmt'
          });
        case 'WORLD_NOT_AVAILABLE':
          return res.status(400).json({
            error: 'Welt ist derzeit nicht verfügbar'
          });
      }
    }

    loggers.system.error('❌ Fehler bei Invite-Akzeptierung', error, {
      token: token.substring(0, 8) + '...',
      userId
    });

    res.status(500).json({
      error: 'Interner Serverfehler',
      details: 'Fehler bei der Invite-Akzeptierung'
    });
  }
});

/**
 * POST /api/invites
 * Einladungen erstellen (authentifiziert)
 * Body: { worldId: number, email?: string, emails?: string[] }
 * Permission: invite.create (world scope)
 */
router.post('/', authenticate, async (req: AuthenticatedRequest, res) => {
  const { worldId, email, emails, sendEmail = true } = req.body;
  
  if (!worldId || isNaN(parseInt(worldId))) {
    return res.status(400).json({ error: 'Gültige Welt-ID erforderlich' });
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

  try {
    const invites = [];
    for (const mail of emailSet) {
      // Prüfe ob bereits eine Einladung für diese E-Mail existiert
      const existingInvite = await prisma.invite.findFirst({
        where: {
          worldId: parseInt(worldId),
          email: mail.toLowerCase().trim()
        }
      });

      if (existingInvite) {
        // Überspringe bereits existierende Einladungen
        continue;
      }

      const token = crypto.randomBytes(32).toString('hex');
      const invite = await prisma.invite.create({
        data: {
          worldId: parseInt(worldId),
          email: mail,
          token,
          invitedById: req.user.id,
          expiresAt: new Date(Date.now() + 1000 * 60 * 60 * 24 * INVITE_EXPIRY_DAYS) // Aus .env
        }
      });
      
      invites.push(invite);
      
      loggers.system.info('✅ Invite erstellt', {
        inviteId: invite.id,
        worldId: parseInt(worldId),
        email: mail,
        inviterId: req.user.id
      });
    }
    
    if (invites.length === 0) {
      return res.status(400).json({ error: 'Alle E-Mail-Adressen haben bereits eine Einladung erhalten' });
    }
    
    res.status(200).json({
      success: true,
      message: 'Einladung(en) erfolgreich erstellt',
      data: { 
        invites: invites.map(i => ({ 
          id: i.id,
          email: i.email, 
          token: i.token,
          link: `${process.env.PUBLIC_CLIENT_URL || 'https://192.168.2.168'}/game/go/invite/${i.token}`,
          worldId: i.worldId,
          expiresAt: i.expiresAt
        })) 
      }
    });
    
  } catch (error) {
    loggers.system.error('❌ Fehler beim Erstellen von Invites', error, {
      worldId,
      userId: req.user.id
    });
    
    res.status(500).json({
      error: 'Interner Serverfehler',
      details: 'Fehler beim Erstellen der Einladungen'
    });
  }
});

/**
 * POST /api/invites/public
 * Öffentliche Einladungen erstellen (keine Authentifizierung erforderlich)
 * Body: { worldId: number, email?: string, emails?: string[] }
 * Für Einladungen an nicht-registrierte Benutzer
 */
router.post('/public', async (req, res) => {
  const { worldId, email, emails } = req.body;
  
  if (!worldId || isNaN(parseInt(worldId))) {
    return res.status(400).json({ error: 'Gültige Welt-ID erforderlich' });
  }

  try {
    // Prüfe ob Welt existiert und öffentlich ist
    const world = await prisma.world.findUnique({ where: { id: parseInt(worldId) } });
    if (!world) {
      return res.status(404).json({ error: 'Welt nicht gefunden' });
    }

    // Nur für offene Welten erlauben
    if (world.status !== 'open' && world.status !== 'upcoming') {
      return res.status(403).json({ error: 'Welt ist nicht für öffentliche Einladungen geöffnet' });
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
      const token = crypto.randomBytes(32).toString('hex');
      const invite = await prisma.invite.create({
        data: {
          worldId: parseInt(worldId),
          email: mail,
          token,
          invitedById: null, // Kein authentifizierter Benutzer
          expiresAt: new Date(Date.now() + 1000 * 60 * 60 * 24 * INVITE_EXPIRY_DAYS) // Aus .env
        }
      });
      
      invites.push(invite);
      
      loggers.system.info('✅ Öffentlicher Invite erstellt', {
        inviteId: invite.id,
        worldId: parseInt(worldId),
        email: mail
      });
    }
    
    res.status(200).json({
      success: true,
      message: 'Öffentliche Einladung(en) erfolgreich erstellt',
      data: { 
        invites: invites.map(i => ({ 
          id: i.id,
          email: i.email, 
          token: i.token,
          worldId: i.worldId,
          expiresAt: i.expiresAt
        })) 
      }
    });
    
  } catch (error) {
    loggers.system.error('❌ Fehler beim Erstellen öffentlicher Invites', error, {
      worldId
    });
    
    res.status(500).json({
      error: 'Interner Serverfehler',
      details: 'Fehler beim Erstellen der öffentlichen Einladungen'
    });
  }
});

/**
 * GET /api/invites/world/:worldId
 * Alle Einladungen einer Welt anzeigen 
 */
router.get('/world/:worldId', async (req, res) => {
  const worldId = parseInt(req.params.worldId);
  
  if (isNaN(worldId)) {
    return res.status(400).json({ error: 'Ungültige Welt-ID' });
  }

  try {
    const invites = await prisma.invite.findMany({
      where: { worldId },
      select: {
        id: true,
        email: true,
        token: true,
        createdAt: true,
        expiresAt: true,
        acceptedAt: true,
        invitedBy: {
          select: {
            username: true
          }
        }
      },
      orderBy: { createdAt: 'desc' }
    });

    loggers.system.info('📋 Invites abgerufen', {
      worldId,
      count: invites.length
    });

    res.json({
      success: true,
      data: invites
    });
    
  } catch (error) {
    loggers.system.error('❌ Fehler beim Abrufen von Invites', error, {
      worldId
    });
    
    res.status(500).json({
      error: 'Interner Serverfehler',
      details: 'Fehler beim Abrufen der Einladungen'
    });
  }
});

/**
 * DELETE /api/invites/:id
 * Einladung löschen (authentifiziert)
 * Permission: invite.delete (world scope)
 */
router.delete('/:id', authenticate, async (req: AuthenticatedRequest, res) => {
  const inviteId = parseInt(req.params.id);
  
  if (isNaN(inviteId)) {
    return res.status(400).json({ error: 'Ungültige Invite-ID' });
  }

  requireUser(req);

  try {
    // Prüfe ob Invite existiert
    const invite = await prisma.invite.findFirst({
      where: { id: inviteId },
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

    // Permission prüfen: invite.delete
    const allowed = await hasPermission(req.user.id, 'invite.delete', {
      type: 'world',
      objectId: invite.worldId.toString()
    });

    if (!allowed) {
      return res.status(403).json({ error: 'Keine Berechtigung zum Löschen von Einladungen' });
    }

    await prisma.invite.delete({ where: { id: inviteId } });

    loggers.system.info('✅ Invite gelöscht', {
      inviteId,
      worldId: invite.worldId,
      deletedBy: req.user.id
    });

    res.json({
      success: true,
      message: 'Einladung erfolgreich gelöscht'
    });
    
  } catch (error) {
    loggers.system.error('❌ Fehler beim Löschen von Invite', error, {
      inviteId,
      userId: req.user.id
    });
    
    res.status(500).json({
      error: 'Interner Serverfehler',
      details: 'Fehler beim Löschen der Einladung'
    });
  }
});

/**
 * POST /api/invites/decline/:token
 * Einladung ablehnen (markiert als declined, löscht nicht)
 */
router.post('/decline/:token', async (req, res) => {
  const { token } = req.params;

  if (!token) {
    return res.status(400).json({
      error: 'Token erforderlich'
    });
  }

  try {
    // Finde und validiere Invite
    const invite = await prisma.invite.findUnique({
      where: { token },
      include: {
        world: {
          select: { 
            id: true, 
            name: true, 
            status: true
          }
        },
        invitedBy: {
          select: { 
            username: true
          }
        }
      }
    });

    if (!invite) {
      loggers.system.warn('⚠️ Ungültiger Invite-Token bei Decline', {
        token: token.substring(0, 8) + '...'
      });
      return res.status(404).json({
        error: 'Ungültiger Invite-Token'
      });
    }

    // Prüfe ob bereits akzeptiert oder abgelaufen
    if (invite.acceptedAt) {
      return res.status(409).json({
        error: 'Invite bereits akzeptiert - kann nicht mehr abgelehnt werden'
      });
    }

    if (invite.expiresAt && invite.expiresAt < new Date()) {
      return res.status(410).json({
        error: 'Invite-Token ist abgelaufen'
      });
    }

    // Lösche den Invite (Decline = Löschen)
    await prisma.invite.delete({
      where: { id: invite.id }
    });

    loggers.system.info('✅ Invite abgelehnt (gelöscht)', {
      inviteId: invite.id,
      worldId: invite.worldId,
      worldName: invite.world?.name,
      email: invite.email
    });

    res.json({
      success: true,
      message: 'Einladung erfolgreich abgelehnt',
      data: {
        world: {
          id: invite.world?.id,
          name: invite.world?.name
        },
        invitedBy: invite.invitedBy?.username
      }
    });
    
  } catch (error) {
    loggers.system.error('❌ Fehler beim Ablehnen von Invite', error, {
      token: token.substring(0, 8) + '...'
    });

    res.status(500).json({
      error: 'Interner Serverfehler',
      details: 'Fehler beim Ablehnen der Einladung'
    });
  }
});

export default router;