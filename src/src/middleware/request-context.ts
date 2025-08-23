import { Request, Response, NextFunction } from 'express';
import crypto from 'crypto';

function generateRequestId(): string {
  if (typeof (crypto as any).randomUUID === 'function') {
    return (crypto as any).randomUUID();
  }
  return crypto.randomBytes(16).toString('hex');
}

/**
 * Attaches a stable request id to each request and response for correlation.
 * Sets headers: X-Request-Id and X-Trace-Id (alias)
 */
export function requestContextMiddleware(req: Request, res: Response, next: NextFunction) {
  const incomingId = (req.headers['x-request-id'] as string) || (req.headers['x-trace-id'] as string);
  const requestId = (incomingId && String(incomingId).trim().slice(0, 128)) || generateRequestId();

  // store on res.locals for easy access
  res.locals.requestId = requestId;

  // expose to client
  res.setHeader('X-Request-Id', requestId);
  res.setHeader('X-Trace-Id', requestId);

  next();
}


