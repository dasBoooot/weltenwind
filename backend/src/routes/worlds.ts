import express from 'express';
import { PrismaClient } from '@prisma/client';
import { authenticate, AuthenticatedRequest } from '../middleware/authenticate';
import { hasPermission } from '../services/access-control.service';

const router = express.Router();
const prisma = new PrismaClient();

/**
 * GET /api/worlds
 * Abrufen aller nicht archivierten Welten
 */
router.get('/', authenticate, async (req: AuthenticatedRequest, res) => {
  const allowed = await hasPermission(req.user!.id, 'view_worlds', {
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
 * Status einer Welt ändern (z. B. "active", "upcoming", "archived")
 * Erfordert Berechtigung im Scope der jeweiligen Welt
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

  const world = await prisma.world.findUnique({ where: { id: worldId } });

  if (!world) {
    return res.status(404).json({ error: 'Welt nicht gefunden' });
  }

  const allowed = await hasPermission(req.user!.id, 'edit_worlds', {
    type: 'world',
    objectId: worldId.toString()
  });

  if (!allowed) {
    return res.status(403).json({ error: 'Keine Bearbeitungsberechtigung für diese Welt' });
  }

  const updated = await prisma.world.update({
    where: { id: worldId },
    data: { status }
  });

  res.json({ success: true, world: updated });
});

export default router;
