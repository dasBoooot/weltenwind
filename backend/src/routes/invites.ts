import express from 'express';
import prisma from '../libs/prisma';
import { loggers } from '../config/logger.config';
import { AuthenticatedRequest } from '../middleware/authenticate';
import { authenticate } from '../middleware/authenticate';

const router = express.Router();

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

export default router;