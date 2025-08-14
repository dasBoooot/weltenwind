# Security Headers & CSRF-Protection

## Übersicht

Dieses Dokument beschreibt die implementierten Sicherheitsmaßnahmen durch HTTP Security Headers und CSRF-Protection.

## Security Headers (Helmet.js)

### Implementierte Headers

1. **Content-Security-Policy (CSP)**
   - Verhindert XSS-Angriffe durch Kontrolle erlaubter Ressourcen
   - Konfiguration:
     ```javascript
     defaultSrc: ["'self'"]  // Nur eigene Ressourcen
     scriptSrc: ["'self'", "'unsafe-inline'", "'unsafe-eval'"]  // Für Swagger UI
     styleSrc: ["'self'", "'unsafe-inline'", "https://fonts.googleapis.com"]
     imgSrc: ["'self'", "data:", "https:"]
     ```

2. **Strict-Transport-Security (HSTS)**
   - Erzwingt HTTPS-Verbindungen
   - `max-age: 31536000` (1 Jahr)
   - `includeSubDomains: true`
   - `preload: true`

3. **X-Content-Type-Options: nosniff**
   - Verhindert MIME-Type Sniffing

4. **X-Frame-Options: DENY**
   - Verhindert Clickjacking durch Verbot von iframes

5. **X-XSS-Protection: 1; mode=block**
   - Aktiviert Browser XSS-Filter

6. **Referrer-Policy: strict-origin-when-cross-origin**
   - Kontrolliert Referrer-Informationen

7. **Permissions-Policy**
   - Deaktiviert nicht benötigte Browser-Features

## CSRF-Protection

### Funktionsweise

1. **Token-Generierung**
   - 32-Byte zufälliger Token pro User
   - Gültigkeit: 1 Stunde
   - Automatische Rotation nach Verwendung

2. **Token-Abruf**
   ```bash
   GET /api/auth/csrf-token
   Authorization: Bearer <access-token>
   
   Response:
   {
     "csrfToken": "...",
     "expiresIn": 3600
   }
   ```

3. **Token-Verwendung**
   - Bei allen state-changing Operations (POST, PUT, DELETE, PATCH)
   - Token im Header: `X-CSRF-Token: <token>`
   - Oder im Body: `_csrf: <token>`

### Geschützte Endpoints

- `POST /api/auth/logout` ✓
- Weitere kritische Endpoints werden nach Bedarf geschützt

### Client-Implementation

```javascript
// Token abrufen
const response = await fetch('/api/auth/csrf-token', {
  headers: {
    'Authorization': `Bearer ${accessToken}`
  }
});
const { csrfToken } = await response.json();

// Token verwenden
await fetch('/api/auth/logout', {
  method: 'POST',
  headers: {
    'Authorization': `Bearer ${accessToken}`,
    'X-CSRF-Token': csrfToken
  }
});
```

## CORS-Konfiguration

```javascript
{
  origin: process.env.ALLOWED_ORIGINS?.split(',') || ['http://localhost:8080'],
  credentials: true,
  optionsSuccessStatus: 200
}
```

## Best Practices

1. **Development vs Production**
   - CSP ist in Development weniger restriktiv (für Swagger UI)
   - HSTS wird nur in Production mit preload aktiviert

2. **Token-Management**
   - Tokens werden automatisch nach 5 Minuten bereinigt
   - Pro User nur ein aktiver Token

3. **Error Handling**
   - 403 Forbidden bei fehlendem/ungültigem CSRF-Token
   - Klare Fehlermeldungen für Debugging

## Testing

```bash
# Security Headers testen
curl -I https://<VM-IP>/api/auth/me

# CSRF-Token abrufen
curl https://<VM-IP>/api/auth/csrf-token \
  -H "Authorization: Bearer <access-token>"

# Mit CSRF-Token ausloggen
curl -X POST https://<VM-IP>/api/auth/logout \
  -H "Authorization: Bearer <access-token>" \
  -H "X-CSRF-Token: <csrf-token>"
```

## Zukünftige Verbesserungen

1. **Redis für Token-Storage**
   - Aktuell: In-Memory Map
   - Besser: Redis für Multi-Server Setup

2. **Weitere Endpoints schützen**
   - Password-Change
   - Account-Delete
   - Kritische Admin-Funktionen

3. **SameSite Cookies**
   - Zusätzlicher CSRF-Schutz für Cookie-basierte Auth