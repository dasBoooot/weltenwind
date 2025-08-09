import { Request, Response, NextFunction } from 'express';
import prisma from '../libs/prisma';
import { hasPermission } from '../services/access-control.service';
import { verifyToken } from './authenticate';

function pathToRegex(pathPattern: string): { regex: RegExp; paramNames: string[] } {
  const paramNames: string[] = [];
  // Escape regex special chars except ':' and '/'
  let pattern = pathPattern.replace(/[.*+?^${}()|[\]\\]/g, '\\$&');
  // Replace :param with capture group and collect names
  pattern = pattern.replace(/:([a-zA-Z_][a-zA-Z0-9_]*)/g, (_m, p1) => {
    paramNames.push(p1);
    return '([^/]+)';
  });
  return { regex: new RegExp('^' + pattern + '$'), paramNames };
}

// Normalize paths so rules may be stored with or without the /api prefix
function normalizeApiPath(p: string): string {
  return p.replace(/^\/api(?=\/|$)/, '');
}

export async function pagePermissionsMiddleware(req: Request, res: Response, next: NextFunction) {
  try {
    // Load all page permissions for this method
    const entries = await prisma.pagePermission.findMany({ where: { method: req.method.toUpperCase() } });
    if (!entries || entries.length === 0) return next();

    // Express gives req.baseUrl when mounted at '/api', and req.path is relative to that
    // We normalize both sides to be comparable regardless of /api prefix presence
    const requestPath = (req.baseUrl || '') + req.path;
    const normalizedRequestPath = normalizeApiPath(requestPath);

    for (const entry of entries) {
      // Try matching against both original and normalized rule path
      const rulePathsToTry = [entry.path, normalizeApiPath(entry.path)];

      let match: RegExpMatchArray | null = null;
      let paramNames: string[] = [];
      for (const rulePath of rulePathsToTry) {
        const compiled = pathToRegex(rulePath);
        paramNames = compiled.paramNames;
        match = normalizedRequestPath.match(compiled.regex);
        if (match) break;
      }
      if (!match) continue;

      // Ensure we have auth context (parse token here if route-level auth hasn't run yet)
      const anyReq = req as any;
      let user = anyReq.user;
      if (!user) {
        const authHeader = req.headers.authorization;
        if (authHeader?.startsWith('Bearer ')) {
          const token = authHeader.split(' ')[1];
          const decoded = verifyToken(token);
          if (decoded) {
            user = anyReq.user = { id: decoded.userId, username: decoded.username };
          }
        }
      }
      if (!user) return res.status(401).json({ error: 'Nicht authentifiziert' });

      // Determine scope object id
      let objectId = 'global';
      if (entry.scopeParam) {
        const idx = paramNames.indexOf(entry.scopeParam);
        if (idx >= 0) {
          objectId = match[idx + 1];
        }
      }

      const allowed = await hasPermission(user.id, entry.permission, {
        type: entry.scopeType as any,
        objectId
      });
      if (!allowed) {
        return res.status(403).json({ error: 'Keine Berechtigung' });
      }
      // If matched and allowed, let request pass through
      return next();
    }

    // No matching page permission rule: allow
    return next();
  } catch (err) {
    return next(err);
  }
}


