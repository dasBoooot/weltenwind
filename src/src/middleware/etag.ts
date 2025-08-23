import { Request, Response, NextFunction } from 'express';
import crypto from 'crypto';

/**
 * Simple strong ETag generator for JSON responses. If response body is set
 * via res.locals.body, it will compute an ETag and handle If-None-Match.
 * Usage patterns:
 *  - Controller sets res.locals.body = data; next(); then a sender sends JSON
 *  - Or wrap a route handler that sends JSON directly by capturing send()
 */
export function etagMiddleware(req: Request, res: Response, next: NextFunction) {
  // Intercept res.json to compute ETag
  const originalJson = res.json.bind(res);
  res.json = (body: any) => {
    try {
      // Convert legacy error bodies to RFC7807 problem+json (if not already)
      if (res.statusCode >= 400 && body && typeof body === 'object') {
        const ctype = (res.getHeader('content-type') as string | undefined) || '';
        const alreadyProblem = ctype.toLowerCase().includes('application/problem+json');
        if (!alreadyProblem) {
          const problem = toProblemJson(req, res, body);
          res.setHeader('Content-Type', 'application/problem+json');
          body = problem;
        }
      }

      // Compute strong ETag from stable JSON string
      const payload = typeof body === 'string' ? body : JSON.stringify(body);
      const hash = crypto.createHash('sha256').update(payload).digest('base64');
      const etag = `"${hash}"`;

      const ifNoneMatch = req.headers['if-none-match'];
      if (ifNoneMatch && ifNoneMatch === etag) {
        res.status(304);
        // must not send body on 304
        res.setHeader('ETag', etag);
        return res.end();
      }

      res.setHeader('ETag', etag);
    } catch {
      // ignore ETag errors
    }
    return originalJson(body);
  };

  next();
}

function toProblemJson(req: Request, res: Response, body: any) {
  const status = res.statusCode || 500;
  const requestId = (res as any).locals?.requestId;
  const detail = typeof body?.error === 'string' ? body.error : (typeof body?.message === 'string' ? body.message : undefined);
  return {
    type: 'about:blank',
    title: httpStatusTitle(status),
    status,
    detail,
    instance: req.originalUrl || req.url,
    correlationId: requestId,
    ...('code' in (body || {}) ? { code: body.code } : {}),
    ...('errors' in (body || {}) ? { errors: body.errors } : {})
  };
}

function httpStatusTitle(status: number): string {
  switch (status) {
    case 400: return 'Bad Request';
    case 401: return 'Unauthorized';
    case 403: return 'Forbidden';
    case 404: return 'Not Found';
    case 409: return 'Conflict';
    case 412: return 'Precondition Failed';
    case 415: return 'Unsupported Media Type';
    case 422: return 'Unprocessable Entity';
    case 429: return 'Too Many Requests';
    default: return status >= 500 ? 'Internal Server Error' : 'Error';
  }
}


