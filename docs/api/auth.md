# Auth API Dokumentation

## Übersicht

Die Auth API verwaltet Benutzer-Authentifizierung und -Autorisierung. Die meisten Endpunkte sind **öffentlich**, nur `/me` erfordert Permission-Prüfung.

## Endpunkte

### 🔐 Login

#### `POST /api/auth/login`
**Permission:** Keine (öffentlich)

Authentifiziert einen Benutzer und erstellt eine Session.

**Request:**
```bash
curl -X POST http://localhost:3000/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"username": "admin", "password": "AAbb1234!!"}'
```

**Response:**
```json
{
  "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "user": {
    "id": 1,
    "username": "admin",
    "email": "admin@weltenwind.de"
  }
}
```

### 🚪 Logout

#### `POST /api/auth/logout`
**Permission:** Keine (nur gültiges Token erforderlich)

Beendet eine Benutzer-Session.

**Request:**
```bash
curl -X POST http://localhost:3000/api/auth/logout \
  -H "Authorization: Bearer YOUR_TOKEN"
```

**Response:**
```json
{
  "success": true,
  "deleted": 1
}
```

### 📝 Registrierung

#### `POST /api/auth/register`
**Permission:** Keine (öffentlich)

Registriert einen neuen Benutzer.

**Request:**
```bash
curl -X POST http://localhost:3000/api/auth/register \
  -H "Content-Type: application/json" \
  -d '{
    "username": "newuser",
    "email": "newuser@example.com",
    "password": "securepassword123"
  }'
```

**Response:**
```json
{
  "user": {
    "id": 123,
    "username": "newuser",
    "email": "newuser@example.com"
  }
}
```

### 🔑 Passwort-Reset anfordern

#### `POST /api/auth/request-reset`
**Permission:** Keine (öffentlich)

Fordert einen Passwort-Reset an.

**Request:**
```bash
curl -X POST http://localhost:3000/api/auth/request-reset \
  -H "Content-Type: application/json" \
  -d '{"email": "user@example.com"}'
```

**Response:**
```json
{
  "message": "Reset-Mail verschickt (falls E-Mail existiert)"
}
```

### 🔄 Passwort zurücksetzen

#### `POST /api/auth/reset-password`
**Permission:** Keine (öffentlich)

Setzt das Passwort mit einem Reset-Token zurück.

**Request:**
```bash
curl -X POST http://localhost:3000/api/auth/reset-password \
  -H "Content-Type: application/json" \
  -d '{
    "token": "reset_token_here",
    "password": "newpassword123"
  }'
```

**Response:**
```json
{
  "message": "Passwort erfolgreich geändert"
}
```

### 👤 Eigene Daten abrufen

#### `GET /api/auth/me`
**Permission:** `system.view_own` (global scope)

Ruft die eigenen Benutzerdaten ab.

**Request:**
```bash
curl -X GET http://localhost:3000/api/auth/me \
  -H "Authorization: Bearer YOUR_TOKEN"
```

**Response:**
```json
{
  "id": 1,
  "username": "admin",
  "email": "admin@weltenwind.de"
}
```

## Permission-Matrix

| Endpunkt | Permission | Scope | Admin | Developer | Support | User | Mod | World-Admin |
|----------|------------|-------|-------|-----------|---------|------|-----|-------------|
| `POST /api/auth/login` | Keine | - | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ |
| `POST /api/auth/logout` | Keine | - | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ |
| `POST /api/auth/register` | Keine | - | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ |
| `POST /api/auth/request-reset` | Keine | - | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ |
| `POST /api/auth/reset-password` | Keine | - | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ |
| `GET /api/auth/me` | `system.view_own` | global | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ |

## Test-Szenarien

### 1. Login-Tests
```bash
# Erfolgreicher Login
curl -X POST http://localhost:3000/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"username": "admin", "password": "AAbb1234!!"}'

# Fehlgeschlagener Login
curl -X POST http://localhost:3000/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"username": "admin", "password": "wrongpassword"}'
# → 401 Unauthorized
```

### 2. Registrierung-Tests
```bash
# Erfolgreiche Registrierung
curl -X POST http://localhost:3000/api/auth/register \
  -H "Content-Type: application/json" \
  -d '{
    "username": "newuser",
    "email": "newuser@example.com",
    "password": "securepassword123"
  }'

# Registrierung mit existierendem Username
curl -X POST http://localhost:3000/api/auth/register \
  -H "Content-Type: application/json" \
  -d '{
    "username": "admin",
    "email": "newuser@example.com",
    "password": "securepassword123"
  }'
# → 409 Conflict
```

### 3. Me-Endpunkt-Tests
```bash
# Erfolgreicher Zugriff auf eigene Daten
curl -X GET http://localhost:3000/api/auth/me \
  -H "Authorization: Bearer ADMIN_TOKEN"

# Ohne Token
curl -X GET http://localhost:3000/api/auth/me
# → 401 Unauthorized
```

## Fehlerbehandlung

### 400 Bad Request
```json
{
  "error": "Benutzername und Passwort erforderlich"
}
```

### 401 Unauthorized
```json
{
  "error": "Zugriff verweigert"
}
```

### 403 Forbidden
```json
{
  "error": "Keine Berechtigung zum Anzeigen der eigenen Daten"
}
```

### 409 Conflict
```json
{
  "error": "Benutzername oder E-Mail bereits vergeben."
}
```

## Sicherheitshinweise

### Öffentliche Endpunkte:
- **Login** - Erfordert gültige Credentials
- **Registrierung** - Erfordert gültige Daten
- **Passwort-Reset** - Erfordert gültige E-Mail

### Geschützte Endpunkte:
- **Logout** - Erfordert gültiges Token
- **Me** - Erfordert `system.view_own` Permission

### Best Practices:
- **Starke Passwörter** verwenden
- **HTTPS** in Produktion
- **Rate Limiting** implementieren
- **Session-Management** überwachen

## Entwicklung

### Neue Auth-Endpunkte hinzufügen:
1. **Permission definieren** falls erforderlich
2. **RolePermission zuweisen** falls erforderlich
3. **hasPermission() prüfen** falls erforderlich
4. **Dokumentation aktualisieren**

### Beispiel für geschützten Endpunkt:
```typescript
router.get('/profile', authenticate, async (req: AuthenticatedRequest, res) => {
  const allowed = await hasPermission(req.user!.id, 'system.view_profile', {
    type: 'global',
    objectId: 'global'
  });

  if (!allowed) {
    return res.status(403).json({ error: 'Keine Berechtigung' });
  }
  
  // Endpunkt-Logik...
});
``` 