import express from 'express';
import { PrismaClient } from '@prisma/client';
import prisma from '../libs/prisma';
import { loggers } from '../config/logger.config';

const router = express.Router();

/**
 * GET /api/invites/validate/:token
 * Token validieren und Welt-Informationen abrufen
 * Keine Authentifizierung erforderlich (öffentlicher Link)
 */
router.get('/validate/:token', async (req, res) => {
  const { token } = req.params;

  if (!token) {
    loggers.api.warn('❌ Invite-Token fehlt', { endpoint: '/api/invites/validate' });
    return res.status(400).json({ error: 'Token ist erforderlich' });
  }

  try {
    loggers.api.info('🔍 Invite-Token wird validiert', { 
      token: token.substring(0, 8) + '...',
      endpoint: '/api/invites/validate'
    });

    // Token in der Datenbank suchen
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
            description: true,
            status: true,
            isPublic: true,
            maxPlayers: true,
            playerCount: true
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
      loggers.api.warn('❌ Invite-Token ungültig oder abgelaufen', { 
        token: token.substring(0, 8) + '...',
        endpoint: '/api/invites/validate'
      });
      return res.status(404).json({ 
        error: 'Einladung nicht gefunden oder abgelaufen',
        details: 'Der Einladungslink ist ungültig oder bereits abgelaufen.'
      });
    }

    // Prüfe ob die Welt noch aktiv ist
    if (invite.world.status !== 'ACTIVE') {
      loggers.api.warn('❌ Eingeladene Welt ist nicht aktiv', { 
        worldId: invite.worldId,
        worldStatus: invite.world.status,
        token: token.substring(0, 8) + '...'
      });
      return res.status(400).json({ 
        error: 'Welt nicht verfügbar',
        details: 'Die eingeladene Welt ist derzeit nicht aktiv.'
      });
    }

    loggers.api.info('✅ Invite-Token erfolgreich validiert', {
      worldId: invite.worldId,
      worldName: invite.world.name,
      inviterName: invite.invitedBy?.username,
      email: invite.email,
      token: token.substring(0, 8) + '...'
    });

    // Erfolgreiche Antwort mit Welt-Informationen
    res.json({
      success: true,
      data: {
        world: invite.world,
        invite: {
          email: invite.email,
          createdAt: invite.createdAt,
          expiresAt: invite.expiresAt,
          inviterName: invite.invitedBy?.username || 'System'
        }
      }
    });

  } catch (error) {
    loggers.api.error('❌ Fehler bei Invite-Token-Validierung', {
      error: error instanceof Error ? error.message : String(error),
      token: token.substring(0, 8) + '...',
      stack: error instanceof Error ? error.stack : undefined
    });

    res.status(500).json({
      error: 'Interner Serverfehler',
      details: 'Fehler bei der Token-Validierung'
    });
  }
});

export default router;