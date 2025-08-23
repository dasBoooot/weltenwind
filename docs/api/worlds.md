# Worlds API Dokumentation

## Übersicht

Die Worlds API verwaltet Welten und deren Spieler. Alle Endpunkte verwenden das neue `scope.permission` System.

## Endpunkte

### 🔍 Welten anzeigen

#### `GET /api/worlds`
**Permission:** `world.view` (global scope)

Zeigt alle nicht archivierten Welten an.

**Request:**
```bash
curl -X GET https://<VM-IP>/api/worlds \
  -H "Authorization: Bearer YOUR_TOKEN"
```

**Response:**
```json
[
  {
    "id": 1,
    "name": "Test-Welt",
    "status": "active",
    "startsAt": "2024-01-01T00:00:00.000Z"
  }
]
```

### ✏️ Welt bearbeiten

#### `POST /api/worlds/:id/edit`
**Permission:** `world.edit` (world scope)

Ändert den Status einer Welt.

**Request:**
```bash
curl -X POST https://<VM-IP>/api/worlds/1/edit \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"status": "active"}'
```

**Response:**
```json
{
  "success": true,
  "world": {
    "id": 1,
    "name": "Test-Welt",
    "status": "active"
  }
}
```

### 🎮 Welt beitreten

#### `POST /api/worlds/:id/join`
**Permission:** `player.join` (world scope)

Tritt einer Welt bei.

**Request:**
```bash
curl -X POST https://<VM-IP>/api/worlds/1/join \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"inviteCode": "optional"}'
```

**Response:**
```json
{
  "playerId": 123,
  "message": "Beitritt erfolgreich"
}
```

### 👤 Eigenen Status anzeigen

#### `GET /api/worlds/:id/players/me`
**Permission:** `player.view_own` (world scope)

Zeigt den eigenen Spielstatus in einer Welt an.

**Request:**
```bash
curl -X GET https://<VM-IP>/api/worlds/1/players/me \
  -H "Authorization: Bearer YOUR_TOKEN"
```

**Response:**
```json
{
  "id": 123,
  "userId": 456,
  "worldId": 1,
  "joinedAt": "2024-01-01T00:00:00.000Z",
  "leftAt": null,
  "state": "active"
}
```

### 🚪 Welt verlassen

#### `DELETE /api/worlds/:id/players/me`
**Permission:** `player.leave` (world scope)

Verlässt eine Welt.

**Request:**
```bash
curl -X DELETE https://<VM-IP>/api/worlds/1/players/me \
  -H "Authorization: Bearer YOUR_TOKEN"
```

**Response:**
```json
{
  "message": "Welt erfolgreich verlassen"
}
```

### 👥 Alle Spieler anzeigen

#### `GET /api/worlds/:id/players`
**Permission:** `player.view_all` (world scope)

Zeigt alle Spieler einer Welt an.

**Request:**
```bash
curl -X GET https://<VM-IP>/api/worlds/1/players \
  -H "Authorization: Bearer YOUR_TOKEN"
```

**Response:**
```json
[
  {
    "id": 456,
    "username": "user",
    "email": "user@weltenwind.de"
  }
]
```

### 📊 Welt-Status (öffentlich)

#### `GET /api/worlds/:id/state`
**Permission:** Keine (öffentlich)

Zeigt den öffentlichen Status einer Welt an.

**Request:**
```bash
curl -X GET https://<VM-IP>/api/worlds/1/state
```

**Response:**
```json
{
  "state": "active",
  "playerCount": 5
}
```

### 🎯 Spieler einladen

#### `POST /api/worlds/:id/invites` (Authentifiziert)
**Permission:** `invite.create` (world scope)

**Beschreibung:** Erstellt Einladungen für eine Welt. Erfordert Authentifizierung und die entsprechende Permission.

**Request Body:**
```json
{
  "email": "user@example.com"
}
```
oder
```json
{
  "emails": ["user1@example.com", "user2@example.com"]
}
```

**Response:**
```json
{
  "message": "Einladung(en) verschickt",
  "invites": [
    {
      "email": "user@example.com",
      "token": "abc123..."
    }
  ]
}
```

#### `POST /api/worlds/:id/invites/public` (Öffentlich)
**Permission:** Keine (öffentlich)

**Beschreibung:** Erstellt öffentliche Einladungen für eine Welt. Keine Authentifizierung erforderlich. **Für Einladungen an nicht-registrierte Benutzer.**

**Einschränkungen:**
- Nur für Welten mit Status `open` oder `upcoming`
- Keine Permission-Prüfung erforderlich

**Request Body:**
```json
{
  "email": "newuser@example.com"
}
```

**Response:**
```json
{
  "message": "Öffentliche Einladung(en) verschickt",
  "invites": [
    {
      "email": "newuser@example.com",
      "token": "xyz789..."
    }
  ]
}
```

### 📝 Vorregistrierung

#### `POST /api/worlds/:id/pre-register`
**Permission:** Keine (öffentlich)

Vorregistrierung für eine Welt.

**Request:**
```bash
curl -X POST https://<VM-IP>/api/worlds/1/pre-register \
  -H "Content-Type: application/json" \
  -d '{"email": "user@example.com", "config": {}}'
```

**Response:**
```json
{
  "message": "Pre-Registration erfolgreich",
  "id": 789
}
```

#### `DELETE /api/worlds/:id/pre-register`
**Permission:** Keine (öffentlich)

Vorregistrierung zurückziehen.

**Request:**
```bash
curl -X DELETE "https://<VM-IP>/api/worlds/1/pre-register?email=user@example.com"
```

**Response:**
```json
{
  "message": "Pre-Registration zurückgezogen"
}
```

## Permission-Matrix

| Endpunkt | Permission | Scope | Admin | Developer | Support | User | Mod | World-Admin |
|----------|------------|-------|-------|-----------|---------|------|-----|-------------|
| `GET /api/worlds` | `world.view` | global | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ |
| `POST /api/worlds/:id/edit` | `world.edit` | world | ✅ | ❌ | ❌ | ❌ | ❌ | ✅ |
| `POST /api/worlds/:id/join` | `player.join` | world | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ |
| `GET /api/worlds/:id/players/me` | `player.view_own` | world | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ |
| `DELETE /api/worlds/:id/players/me` | `player.leave` | world | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ |
| `GET /api/worlds/:id/players` | `player.view_all` | world | ✅ | ✅ | ✅ | ❌ | ✅ | ✅ |
| `POST /api/worlds/:id/invites` | `invite.create` | world | ✅ | ❌ | ❌ | ❌ | ✅ | ✅ |
| `POST /api/worlds/:id/invites/public` | Keine | - | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ |

## Test-Szenarien

### 1. Admin-Tests
```bash
# Admin kann alles
curl -X POST https://<VM-IP>/api/worlds/1/edit \
  -H "Authorization: Bearer ADMIN_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"status": "active"}'
```

### 2. User-Tests
```bash
# User kann beitreten
curl -X POST https://<VM-IP>/api/worlds/1/join \
  -H "Authorization: Bearer USER_TOKEN"

# User kann nicht bearbeiten
curl -X POST https://<VM-IP>/api/worlds/1/edit \
  -H "Authorization: Bearer USER_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"status": "active"}'
# → 403 Forbidden
```

### 3. Mod-Tests
```bash
# Mod kann Einladungen erstellen
curl -X POST https://<VM-IP>/api/worlds/1/invites \
  -H "Authorization: Bearer MOD_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"email": "user@example.com"}'

# Mod kann nicht bearbeiten
curl -X POST https://<VM-IP>/api/worlds/1/edit \
  -H "Authorization: Bearer MOD_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"status": "active"}'
# → 403 Forbidden
```

## Fehlerbehandlung

### 403 Forbidden
```json
{
  "error": "Keine Berechtigung zum Weltzugriff"
}
```

### 404 Not Found
```json
{
  "error": "Welt nicht gefunden"
}
```

### 400 Bad Request
```json
{
  "error": "Ungültige Welt-ID"
}
```

## Entwicklung

### Neue Endpunkte hinzufügen:
1. **Permission definieren** in `permissions.seed.ts`
2. **RolePermission zuweisen** in `role-permissions.seed.ts`
3. **hasPermission() prüfen** im Endpunkt
4. **Dokumentation aktualisieren**

### Beispiel:
```typescript
// Permission prüfen
const allowed = await hasPermission(req.user!.id, 'world.delete', {
  type: 'world',
  objectId: worldId.toString()
});

if (!allowed) {
  return res.status(403).json({ error: 'Keine Löschberechtigung' });
}
``` 