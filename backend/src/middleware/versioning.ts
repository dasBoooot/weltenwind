import { Request, Response, NextFunction } from 'express';

/**
 * Ensures all APIs are accessible under /api/v1 in addition to existing /api routes.
 * This middleware rewrites URLs starting with /api/v1 to /api to reuse existing routers.
 */
export function apiV1Rewriter(req: Request, _res: Response, next: NextFunction) {
  if (req.url.startsWith('/api/v1')) {
    req.url = req.url.replace(/^\/api\/v1/, '/api');
  }
  next();
}


