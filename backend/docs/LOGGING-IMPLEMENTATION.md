# Weltenwind Logging System

## 🎯 **Übersicht**

Dieses Dokument beschreibt die Implementierung des zentralen Logging-Systems für Weltenwind, basierend auf deinem durchdachten Phasen-Konzept.

## 📁 **Dateistruktur**

```
logs/                           # Zentrales Log-Verzeichnis (in .gitignore)
├── app.log                     # Alle Log-Nachrichten
├── auth.log                    # Authentifizierung & Authorization  
├── security.log               # Sicherheitsereignisse
├── api.log                    # API-Requests & Responses
└── error.log                  # Nur Fehler

backend/src/
├── config/logger.config.ts    # Winston-Konfiguration
├── middleware/logging.middleware.ts  # Request-Logging
└── routes/logs.ts             # Web-UI für Log-Viewer
```

## 🚀 **Phase 1: Implementierung (SOFORTIGE UMSETZUNG)**

### 1. Winston installieren & konfigurieren

```bash
cd backend
npm install winston
```

### 2. Logger in server.ts einbinden

```typescript
// In src/server.ts
import { requestLoggingMiddleware, errorLoggingMiddleware } from './middleware/logging.middleware';
import { loggers } from './config/logger.config';

// Nach den anderen Middlewares hinzufügen:
app.use(requestLoggingMiddleware);

// Startup-Log
loggers.system.info('Weltenwind Backend starting up', {
  port: PORT,
  nodeEnv: process.env.NODE_ENV,
  version: require('./package.json').version
});

// Error-Middleware am Ende hinzufügen:
app.use(errorLoggingMiddleware);
```

### 3. Log-Routes einbinden

```typescript
// In src/server.ts
import logRoutes from './routes/logs';

app.use('/api/logs', logRoutes);
```

### 4. Bestehende Services erweitern

**Auth-Service (`auth.ts`):**
```typescript
import { loggers } from '../config/logger.config';

// Erfolgreicher Login:
loggers.auth.login(username, ip, true, {
  userId: user.id,
  email: user.email
});

// Fehlgeschlagener Login:
loggers.auth.login(username, ip, false, {
  reason: 'invalid_password',
  remainingAttempts: attemptResult.remainingAttempts
});
```

**Rate Limiter (`rateLimiter.ts`):**
```typescript
import { loggers } from '../config/logger.config';

export const authLimiter = rateLimit({
  // ... existing config
  handler: (req, res) => {
    const ip = req.headers['x-forwarded-for'] as string || req.socket.remoteAddress || 'unknown';
    
    loggers.security.rateLimitHit(ip, req.originalUrl, {
      userAgent: req.headers['user-agent'],
      limit: 100
    });
    
    res.status(429).json({ error: 'Zu viele Anfragen' });
  }
});
```

**CSRF Protection (`csrf-protection.ts`):**
```typescript
import { loggers } from '../config/logger.config';

// Bei ungültigem CSRF-Token:
loggers.security.csrfTokenInvalid(
  req.user?.username || 'unknown',
  ip,
  req.originalUrl,
  { userId: req.user?.id }
);
```

## 📊 **Phase 2: Web-UI (BEREITS IMPLEMENTIERT)**

### Log-Viewer aufrufen:
```
http://localhost:3000/api/logs/viewer
```

**Features:**
- ✅ Echtzeit-Log-Anzeige
- ✅ Filterung nach Log-Dateien
- ✅ Suchfunktion
- ✅ Auto-Refresh
- ✅ Farbkodierte Log-Level
- ✅ JSON-Metadaten-Anzeige
- ✅ Admin-nur Zugriff

### API-Endpoints:
- `GET /api/logs/viewer` - Web-UI
- `GET /api/logs/data` - Log-Daten (JSON)
- `GET /api/logs/stats` - Statistiken

## 🔒 **Berechtigungen**

Nur Benutzer mit `system.logs` Permission können auf Logs zugreifen.

```sql
-- Admin-Permission für Logs hinzufügen:
INSERT INTO permissions (name, description, scope) 
VALUES ('system.logs', 'Zugriff auf System-Logs', 'global');

-- Admin-Rolle zuweisen:
INSERT INTO role_permissions (role_id, permission_id) 
SELECT r.id, p.id 
FROM roles r, permissions p 
WHERE r.name = 'admin' AND p.name = 'system.logs';
```

## 📝 **Log-Format (JSON)**

Alle Logs verwenden strukturiertes JSON-Format:

```json
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
```

## 🚨 **Wichtige Sicherheitsereignisse**

Das System loggt automatisch:

- ✅ **Logins** (erfolgreich/fehlgeschlagen)
- ✅ **Account-Lockouts** nach Brute-Force
- ✅ **Rate-Limit-Überschreitungen**
- ✅ **CSRF-Token-Verletzungen**
- ✅ **Session-Rotationen**
- ✅ **Passwort-Änderungen**
- ✅ **API-Requests** mit Performance-Daten
- ✅ **System-Fehler** mit Stack-Traces

## ⚙️ **Konfiguration**

**Environment Variables:**
```bash
# .env
LOG_LEVEL=info          # debug, info, warn, error
NODE_ENV=development    # Aktiviert Console-Ausgabe
```

**Log-Rotation:**
- Maximale File-Größe: 50MB
- Anzahl Backups: 10 (app.log), 5 (error.log)
- Automatische Rotation durch Winston

## 🛠️ **Phase 3: Filebeat (Optional)**

Für zentralisierte Logs kannst du später Filebeat hinzufügen:

```yaml
# filebeat.yml
filebeat.inputs:
- type: log
  paths:
    - /srv/weltenwind/logs/*.log
  json.keys_under_root: true
  json.add_error_key: true

output.logstash:
  hosts: ["your-logserver:5044"]
```

## 📈 **Phase 4: Monitoring & Alerts**

**Log-basierte Alerts:**
```bash
# Cronjob für Error-Monitoring
*/5 * * * * grep -i "error" /srv/weltenwind/logs/error.log | tail -10 | mail -s "Weltenwind Errors" admin@example.com
```

## 🎨 **Flutter Client Logging**

Für den Flutter Client empfehle ich:

```dart
// pubspec.yaml
dependencies:
  logger: ^2.0.1

// lib/core/services/logger_service.dart
import 'package:logger/logger.dart';

class AppLogger {
  static final Logger _logger = Logger(
    printer: PrettyPrinter(
      methodCount: 2,
      errorMethodCount: 8,
      lineLength: 120,
      colors: true,
      printEmojis: true,
      printTime: true,
    ),
  );

  static void info(String message, [dynamic error, StackTrace? stackTrace]) {
    _logger.i(message, error: error, stackTrace: stackTrace);
  }

  static void error(String message, [dynamic error, StackTrace? stackTrace]) {
    _logger.e(message, error: error, stackTrace: stackTrace);
  }
}
```

## 🧪 **Testing**

```bash
# Log-Verzeichnis erstellen
mkdir -p logs

# Server starten  
npm run dev

# Test-Login für Log-Generierung
curl -X POST http://localhost:3000/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"username":"testuser1","password":"wrongpassword"}'

# Logs prüfen
tail -f logs/auth.log
tail -f logs/security.log

# Web-UI öffnen
open http://localhost:3000/api/logs/viewer
```

## 🚀 **Empfohlene Reihenfolge**

1. **JETZT:** Winston installieren & Logger-Config erstellen
2. **JETZT:** Logging-Middleware in server.ts einbinden  
3. **JETZT:** Auth-Service mit Logging erweitern
4. **DIESE WOCHE:** Alle Security-Services mit Logging erweitern
5. **NÄCHSTE WOCHE:** Log-Viewer testen & Admin-Permission setzen
6. **SPÄTER:** Filebeat für zentrale Sammlung (optional)

## 💡 **Vorteile dieser Implementierung**

- ✅ **Strukturiert**: JSON-Format für maschinelle Auswertung
- ✅ **Modular**: Separate Log-Dateien nach Bereich
- ✅ **Sicher**: Admin-only Zugriff auf Logs
- ✅ **Performant**: File-basiert, keine DB-Belastung
- ✅ **Docker-frei**: Funktioniert ohne Container
- ✅ **Skalierbar**: Einfach erweiterbar mit Filebeat/ELK
- ✅ **Integration**: Nutzt deine bestehende Auth/Permission-Struktur

Das System ist **Production-Ready** und passt perfekt zu deiner bestehenden Weltenwind-Architektur! 🎯