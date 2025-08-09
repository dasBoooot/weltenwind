import { Request, Response, NextFunction } from 'express';

// In-memory idempotency store with TTL (dev baseline; for prod use DB/Redis)
const memoryStore = new Map<string, { status: number; body: any; headers: Record<string, string>; expiresAt: number }>();
const DEFAULT_TTL_MS = 10 * 60 * 1000; // 10 minutes

function cleanupExpired() {
  const now = Date.now();
  for (const [key, value] of memoryStore.entries()) {
    if (value.expiresAt <= now) memoryStore.delete(key);
  }
}

setInterval(cleanupExpired, 60 * 1000).unref?.();

export function idempotencyMiddleware(req: Request, res: Response, next: NextFunction) {
  const method = req.method.toUpperCase();
  // Apply only to mutating methods
  if (!['POST', 'PUT', 'PATCH', 'DELETE'].includes(method)) return next();

  const idempotencyKey = (req.headers['idempotency-key'] as string) || (req.headers['x-idempotency-key'] as string);
  if (!idempotencyKey) return next();

  const storeKey = `${idempotencyKey}:${req.originalUrl}`;
  const cached = memoryStore.get(storeKey);
  if (cached) {
    // Replay cached response
    for (const [h, v] of Object.entries(cached.headers)) {
      res.setHeader(h, v);
    }
    res.setHeader('Idempotency-Replay', 'true');
    return res.status(cached.status).send(cached.body);
  }

  // Capture response to cache it
  const originalJson = res.json.bind(res);
  const originalSend = res.send.bind(res);

  const cacheAndReturn = (payload: any, sender: (b: any) => any) => {
    try {
      const headers: Record<string, string> = {};
      for (const [name, values] of Object.entries(res.getHeaders())) {
        const value = Array.isArray(values) ? values.join(',') : String(values);
        headers[name] = value;
      }
      memoryStore.set(storeKey, {
        status: res.statusCode,
        body: payload,
        headers,
        expiresAt: Date.now() + DEFAULT_TTL_MS
      });
      res.setHeader('Idempotency-Cached', 'true');
    } catch {
      // ignore cache errors
    }
    return sender(payload);
  };

  res.json = (body: any) => cacheAndReturn(body, originalJson);
  res.send = (body?: any) => cacheAndReturn(body, originalSend);

  next();
}


