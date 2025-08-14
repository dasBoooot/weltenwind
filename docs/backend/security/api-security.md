# API Security Documentation

## 🔒 Übersicht

Diese Dokumentation beschreibt alle implementierten Sicherheitsmaßnahmen der Weltenwind API.

## 📊 Security Status

| Feature | Status | Beschreibung |
|---------|--------|--------------|
| **JWT Authentication** | ✅ Implementiert | Access & Refresh Token Strategie |
| **Rate Limiting** | ✅ Implementiert | Schutz vor Brute-Force und DoS |
| **Account Lockout** | ✅ Implementiert | Nach 5 Fehlversuchen |
| **Password Policies** | ✅ Implementiert | Intelligente Validierung mit zxcvbn |
| **Security Headers** | ✅ Implementiert | Helmet.js mit CSP, HSTS, etc. |
| **CSRF Protection** | ✅ Implementiert | Token-basierter Schutz |
| **Session Rotation** | ✅ Implementiert | Bei kritischen Aktionen |
| **Email Verification** | ⏳ Geplant | Wartet auf Mail-Server |
| **2FA** | 📅 Roadmap | Geplant für Q3 2024 |

## 🛡️ Implementierte Sicherheitsmaßnahmen

### 1. Authentifizierung (JWT)

**Konfiguration:**
- Access Token: 15 Minuten Gültigkeit
- Refresh Token: 7 Tage Gültigkeit
- JWT Secret: Mind. 32 Zeichen, sicher generiert

**Features:**
- Automatische Token-Erneuerung bei < 60 Sekunden Restlaufzeit
- Session-Management mit Cleanup
- Multi-Device Login optional

### 2. Rate Limiting

**Endpoints:**
| Endpoint | Limit | Zeitfenster | Slow-Down |
|----------|-------|-------------|-----------|
| `/api/auth/*` | 100 | 15 Min | Nach 50 Requests |
| `/api/auth/login` | 5 | 15 Min | +2s pro Request |
| `/api/auth/register` | 3 | 60 Min | - |
| `/api/auth/reset-password` | 3 | 60 Min | - |
| Alle anderen | 1000 | 15 Min | - |

### 3. Brute-Force Protection

**Account Lockout:**
- Aktivierung: Nach 5 Fehlversuchen
- Sperrzeit: 30 Minuten
- Reset: Bei erfolgreichem Login oder nach Ablauf

**Features:**
- Progressive Verzögerung
- IP-basiertes Tracking
- Automatische Bereinigung

### 4. Passwort-Sicherheit

**Validierung mit zxcvbn:**
- Mindest-Score: 3/4
- Mindestlänge: 8 Zeichen
- Prüfung auf:
  - Häufige Passwörter
  - Persönliche Informationen
  - Tastatur-Muster
  - Wörterbuch-Angriffe

**API Endpoint:**
```bash
POST /api/auth/check-password-strength
{
  "password": "TestPassword123!",
  "username": "testuser",
  "email": "test@example.com"
}
```

### 5. Security Headers

**Implementiert mit Helmet.js:**
- **CSP**: Content-Security-Policy (Production only)
- **HSTS**: Strict-Transport-Security
- **X-Frame-Options**: DENY
- **X-Content-Type-Options**: nosniff
- **Referrer-Policy**: strict-origin-when-cross-origin
- **Cross-Origin Policies**: COOP, CORP

**Development vs Production:**
- Development: Gelockerte Policies für lokale Entwicklung
- Production: Strikte Security Headers

### 6. CSRF Protection

**Token-basiert:**
- Gültigkeit: 1 Stunde
- Automatische Rotation nach Verwendung
- Required für alle state-changing Operations

**Verwendung:**
```javascript
// 1. Token abrufen
GET /api/auth/csrf-token

// 2. Mit Request senden
POST /api/auth/logout
Headers: X-CSRF-Token: <token>
```

### 7. Session Rotation

**Aktiviert bei:**
- Passwort-Änderung ✅
- Email-Änderung (geplant)
- Berechtigungen-Änderung (geplant)
- 2FA-Konfiguration (geplant)

**Ablauf:**
1. Alle Sessions werden invalidiert
2. Neue Tokens werden generiert
3. Audit-Log wird erstellt
4. Client erhält neue Tokens

## 🔐 Best Practices für Clients

### Token-Management
```javascript
// Sichere Token-Speicherung
// Web: httpOnly Cookies oder sessionStorage
// Mobile: Secure Storage (Keychain/Keystore)

// Token-Refresh Logic
if (tokenExpiresIn < 60) {
  const newTokens = await refreshTokens();
  updateStoredTokens(newTokens);
}
```

### CSRF-Token Handling
```javascript
// Bei jeder state-changing Operation
const csrfToken = await getCsrfToken();
const response = await fetch('/api/resource', {
  method: 'POST',
  headers: {
    'Authorization': `Bearer ${accessToken}`,
    'X-CSRF-Token': csrfToken
  }
});
```

### Session-Rotation Handling
```javascript
// Nach kritischen Aktionen
if (response.sessionRotated) {
  // Neue Tokens speichern
  await updateTokens(response.accessToken, response.refreshToken);
  // User informieren
  showNotification('Aus Sicherheitsgründen wurden andere Sitzungen beendet');
}
```

## 🚨 Fehlerbehandlung

### Rate Limiting
```javascript
// 429 Too Many Requests
if (response.status === 429) {
  const retryAfter = response.headers.get('Retry-After');
  const message = response.headers.get('X-RateLimit-Message');
  showError(`Zu viele Anfragen. Bitte ${retryAfter}s warten.`);
}
```

### Account Lockout
```javascript
// 423 Locked
if (response.status === 423) {
  const data = await response.json();
  showError(`Account gesperrt bis: ${data.lockedUntil}`);
}
```

## 🧪 Security Testing

### Automatisierte Tests
```bash
# Rate Limiting testen
for i in {1..10}; do
  curl -X POST https://<VM-IP>/api/auth/login \
    -H "Content-Type: application/json" \
    -d '{"username":"test","password":"wrong"}'
done

# Security Headers prüfen
node test-security-headers.js

# Passwort-Validierung testen
node test-password-validation.js
```

### Penetration Testing Checklist
- [ ] SQL Injection
- [ ] XSS (Cross-Site Scripting)
- [ ] CSRF (Cross-Site Request Forgery)
- [ ] Session Hijacking
- [ ] Brute Force
- [ ] Directory Traversal
- [ ] API Rate Limiting Bypass
- [ ] JWT Vulnerabilities

## 📈 Monitoring & Logging

### Security Events
```javascript
// Beispiel Audit-Log
{
  "event": "session_rotation",
  "userId": 123,
  "action": "password_change",
  "ip": "192.168.1.1",
  "timestamp": "2024-01-15T10:30:00Z"
}
```

### Alerts konfigurieren für:
- Mehrfache fehlgeschlagene Login-Versuche
- Ungewöhnliche API-Nutzungsmuster
- Session-Rotation Events
- CSRF-Token Fehler

## 🔄 Update & Maintenance

### Regelmäßige Aufgaben
1. **Monatlich:**
   - Dependencies updaten
   - Security Patches einspielen
   
2. **Quartalweise:**
   - JWT Secret rotieren
   - Security Audit durchführen
   
3. **Jährlich:**
   - Penetration Test
   - Security Policy Review

## 📞 Incident Response

Bei Sicherheitsvorfällen:
1. Betroffene Sessions invalidieren
2. Passwort-Reset für betroffene User
3. Audit-Logs analysieren
4. Security Patches deployen
5. User informieren

## 🔗 Weitere Ressourcen

- [OWASP API Security Top 10](https://owasp.org/www-project-api-security/)
- [JWT Best Practices](https://tools.ietf.org/html/rfc8725)
- [Node.js Security Checklist](https://blog.risingstack.com/node-js-security-checklist/)
- [Express Security Best Practices](https://expressjs.com/en/advanced/best-practice-security.html)