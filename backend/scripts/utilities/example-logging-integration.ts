// ==========================================
// BEISPIEL: Integration in server.ts
// ==========================================

import { requestLoggingMiddleware, errorLoggingMiddleware } from './src/middleware/logging.middleware';
import { loggers } from './src/config/logger.config';

// In server.ts nach den anderen Middlewares hinzufügen:
// app.use(requestLoggingMiddleware); // Automatisches Request-Logging

// Startup-Log
loggers.system.info('Weltenwind Backend starting up', {
  port: PORT,
  nodeEnv: process.env.NODE_ENV,
  version: require('./package.json').version
});

// ==========================================
// BEISPIEL: Integration in auth.ts Routes
// ==========================================

// In den Login-Endpoint:
router.post('/login', authLimiter, authSlowDown, async (req, res) => {
  const { username, password } = req.body;
  const ip = req.headers['x-forwarded-for'] as string || req.socket.remoteAddress || 'unknown';
  
  try {
    const user = await prisma.user.findUnique({ where: { username } });
    
    if (!user) {
      // Failed Login loggen
      loggers.auth.login(username, ip, false, { reason: 'user_not_found' });
      return res.status(401).json({ error: 'Ungültige Zugangsdaten' });
    }
    
    const lockStatus = await isAccountLocked(user.id);
    if (lockStatus.locked) {
      // Account locked loggen
      loggers.security.accountLocked(username, ip, { 
        lockedUntil: lockStatus.lockedUntil,
        attempts: lockStatus.attempts 
      });
      return res.status(423).json({
        error: 'Account gesperrt',
        lockedUntil: lockStatus.lockedUntil
      });
    }
    
    const pwValid = await bcrypt.compare(password, user.passwordHash);
    if (!pwValid) {
      const attemptResult = await recordFailedLogin(user.id);
      
      // Failed login mit Attempts loggen
      loggers.auth.login(username, ip, false, { 
        reason: 'invalid_password',
        remainingAttempts: attemptResult.remainingAttempts,
        totalAttempts: attemptResult.totalAttempts
      });
      
      return res.status(401).json({
        error: 'Ungültige Zugangsdaten',
        remainingAttempts: attemptResult.remainingAttempts
      });
    }
    
    // Successful login
    await recordSuccessfulLogin(user.id);
    
    // Success Login loggen
    loggers.auth.login(username, ip, true, {
      userId: user.id,
      email: user.email,
      sessionType: 'access_refresh_tokens'
    });
    
    // ... Token-Generierung ...
    
  } catch (error) {
    loggers.system.error('Login endpoint error', error, { username, ip });
    return res.status(500).json({ error: 'Interner Serverfehler' });
  }
});

// ==========================================
// BEISPIEL: Rate Limiter Integration
// ==========================================

// In rateLimiter.ts - Handler für Rate Limit Exceeded:
export const authLimiter = rateLimit({
  windowMs: 15 * 60 * 1000,
  limit: 100,
  handler: (req, res) => {
    const ip = req.headers['x-forwarded-for'] as string || req.socket.remoteAddress || 'unknown';
    
    // Rate Limit Hit loggen
    loggers.security.rateLimitHit(ip, req.originalUrl, {
      userAgent: req.headers['user-agent'],
      limit: 100,
      windowMs: '15min'
    });
    
    res.status(429).json({
      error: 'Zu viele Anfragen',
      retryAfter: Math.round(15 * 60)
    });
  }
});

// ==========================================
// BEISPIEL: Session Rotation Integration
// ==========================================

// In session-rotation.service.ts:
export async function rotateSession(
  userId: number,
  action: CriticalAction,
  ip: string,
  fingerprint: string,
  timezone?: string
): Promise<TokenPair> {
  const user = await prisma.user.findUnique({ where: { id: userId } });
  
  if (user) {
    // Session Rotation loggen
    loggers.security.sessionRotation(user.username, ip, action, {
      userId,
      fingerprint,
      timezone,
      reason: action
    });
  }
  
  // ... Rest der Funktion ...
}

// ==========================================
// BEISPIEL: CSRF Protection Integration  
// ==========================================

// In csrf-protection.ts:
export function csrfProtection(req: CsrfRequest, res: Response, next: NextFunction) {
  // ... existing validation logic ...
  
  if (!validateCsrfToken(req.user.id.toString(), token)) {
    const ip = req.headers['x-forwarded-for'] as string || req.socket.remoteAddress || 'unknown';
    
    // CSRF Violation loggen
    loggers.security.csrfTokenInvalid(
      req.user?.username || 'unknown',
      ip,
      req.originalUrl,
      {
        userId: req.user?.id,
        providedToken: token ? 'present' : 'missing',
        userAgent: req.headers['user-agent']
      }
    );
    
    return res.status(403).json({
      error: 'Ungültiger CSRF-Token'
    });
  }
  
  next();
}

// ==========================================
// BEISPIEL: Passwort-Änderungs-Logging
// ==========================================

// In change-password endpoint:
router.post('/change-password', authenticate, csrfProtection, async (req: AuthenticatedRequest, res) => {
  const ip = req.headers['x-forwarded-for'] as string || req.socket.remoteAddress || 'unknown';
  
  try {
    // ... password change logic ...
    
    // Erfolgreiche Passwort-Änderung loggen
    loggers.auth.passwordChange(req.user.username, ip, {
      userId: req.user.id,
      sessionRotated: true,
      userAgent: req.headers['user-agent']
    });
    
    // Session Rotation wird bereits in rotateSession() geloggt
    
  } catch (error) {
    loggers.system.error('Password change failed', error, {
      username: req.user?.username,
      ip,
      userId: req.user?.id
    });
  }
});

// ==========================================
// BEISPIEL: Beispiel-Log-Output (JSON)
// ==========================================

/*
Beispiel auth.log Eintrag nach erfolgreichem Login:
{
  "timestamp": "2025-07-29 10:30:15.123",
  "level": "INFO", 
  "module": "AUTH",
  "message": "Login successful",
  "action": "LOGIN",
  "username": "testuser1",
  "ip": "192.168.2.100",
  "success": true,
  "metadata": {
    "userId": 1,
    "email": "test@example.com",
    "sessionType": "access_refresh_tokens"
  }
}

Beispiel security.log Eintrag nach Rate Limit:
{
  "timestamp": "2025-07-29 10:31:22.456",
  "level": "WARN",
  "module": "SECURITY", 
  "message": "Rate limit exceeded",
  "action": "RATE_LIMIT",
  "ip": "192.168.2.100",
  "endpoint": "/api/auth/login",
  "metadata": {
    "userAgent": "Mozilla/5.0...",
    "limit": 100,
    "windowMs": "15min"
  }
}
*/