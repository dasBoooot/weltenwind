import { Request, Response, NextFunction } from 'express';

/**
 * RFC7807 problem+json formatter. Should be the last error handler inserted
 * before server start. Always includes correlation id if available.
 */
export function problemDetailsMiddleware(err: any, req: Request, res: Response, _next: NextFunction) {
  const status = typeof err?.status === 'number' && err.status >= 400 ? err.status : (res.statusCode >= 400 ? res.statusCode : 500);

  const requestId = res.locals?.requestId;
  const instance = req.originalUrl || req.url;

  const problem = {
    type: err?.type || 'about:blank',
    title: err?.title || httpStatusTitle(status),
    status,
    detail: safeDetail(err),
    instance,
    correlationId: requestId,
  } as Record<string, any>;

  // optional extras provided by upstream code
  if (err?.errors) problem.errors = err.errors;
  if (err?.code) problem.code = err.code;

  // ensure content-type
  res.setHeader('Content-Type', 'application/problem+json');
  // keep X-Request-Id
  if (requestId) {
    res.setHeader('X-Request-Id', requestId);
    res.setHeader('X-Trace-Id', requestId);
  }

  res.status(status).json(problem);
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

function safeDetail(err: any): string | undefined {
  if (!err) return undefined;
  if (typeof err === 'string') return err;
  if (typeof err?.message === 'string') return err.message;
  return undefined;
}


