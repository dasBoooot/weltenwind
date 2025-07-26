import { Request, Response, NextFunction } from 'express';
import jwt from 'jsonwebtoken';
import { PrismaClient } from '@prisma/client';
import { getValidSession } from '../services/session.service';

const prisma = new PrismaClient();

export interface AuthenticatedRequest extends Request {
  user?: {
    id: number;
    username: string;
    roles: {
      roleId: number;
      scopeType: string;
      scopeObjectId: string;
    }[];
  };
}

export async function authenticate(req: AuthenticatedRequest, res: Response, next: NextFunction) {
  const authHeader = req.headers.authorization;

  if (!authHeader?.startsWith('Bearer ')) {
    return res.status(401).json({ error: 'Kein gültiges Token übergeben' });
  }

  const token = authHeader.split(' ')[1];

  try {
    const payload = jwt.verify(token, process.env.JWT_SECRET || 'dev-secret') as {
      userId: number;
      username: string;
    };

    // Session prüfen
    const session = await getValidSession(payload.userId, token);
    if (!session) {
      return res.status(401).json({ error: 'Session nicht gefunden oder abgelaufen' });
    }

    // User + Rollen laden
    const user = await prisma.user.findUnique({
      where: { id: payload.userId },
      include: {
        roles: true
      }
    });

    if (!user || user.isLocked) {
      return res.status(403).json({ error: 'Zugriff gesperrt' });
    }

    req.user = {
      id: user.id,
      username: user.username,
      roles: user.roles.map((r) => ({
        roleId: r.roleId,
        scopeType: r.scopeType,
        scopeObjectId: r.scopeObjectId
      }))
    };

    next();
  } catch (err) {
    return res.status(401).json({ error: 'Ungültiges oder abgelaufenes Token' });
  }
}
