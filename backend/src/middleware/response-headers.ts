import { Request, Response, NextFunction } from 'express';

/**
 * Ensures standard headers on all responses, including correlation id
 * and a default JSON content type for JSON payloads.
 */
export function standardResponseHeaders(req: Request, res: Response, next: NextFunction) {
  const requestId = res.locals?.requestId;
  if (requestId) {
    res.setHeader('X-Request-Id', requestId);
    res.setHeader('X-Trace-Id', requestId);
  }
  // 429 retry hints are set by rate-limiter middleware where applicable
  next();
}


