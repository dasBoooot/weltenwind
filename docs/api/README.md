# 🔌 Weltenwind API Reference

**Die Weltenwind API** ist eine moderne RESTful API, die das Herzstück der Weltenwind-Plattform bildet. Sie ermöglicht vollständiges Management von Benutzern, Welten, Einladungen und Themes über HTTP-Endpunkte.

---

## 📋 **API-Übersicht**

### **Base URL**
```
Production:  https://your-domain.com/api
Development (Projekt-Setup mit VM): https://<VM-IP>/api
```

### **Authentifizierung**
```http
Authorization: Bearer YOUR_JWT_TOKEN
```

### **Content-Type**
```http
Content-Type: application/json
```

### **API-Version**
```
Current Version: v1
Versioning: Path-based (/api/v1/...)
```

---

## 🗂️ **API-Endpunkt-Kategorien**

### **🔐 Authentication & Users**
| Endpunkt | Beschreibung | Dokumentation |
|----------|--------------|---------------|
| `POST /auth/login` | Benutzer-Anmeldung | [auth.md](auth.md#login) |
| `POST /auth/register` | Benutzer-Registrierung | [auth.md](auth.md#register) |
| `POST /auth/logout` | Benutzer-Abmeldung | [auth.md](auth.md#logout) |
| `GET /auth/me` | Aktueller Benutzer | [auth.md](auth.md#current-user) |
| `POST /auth/refresh` | Token erneuern | [auth.md](auth.md#refresh-token) |

### **🌍 World Management**  
| Endpunkt | Beschreibung | Dokumentation |
|----------|--------------|---------------|
| `GET /worlds` | Alle Welten auflisten | [worlds.md](worlds.md#list-worlds) |
| `POST /worlds` | Neue Welt erstellen | [worlds.md](worlds.md#create-world) |
| `GET /worlds/:id` | Welt-Details abrufen | [worlds.md](worlds.md#get-world) |
| `PUT /worlds/:id` | Welt aktualisieren | [worlds.md](worlds.md#update-world) |
| `DELETE /worlds/:id` | Welt löschen | [worlds.md](worlds.md#delete-world) |
| `POST /worlds/:id/join` | Welt beitreten | [worlds.md](worlds.md#join-world) |
| `POST /worlds/:id/leave` | Welt verlassen | [worlds.md](worlds.md#leave-world) |
| `GET /worlds/:id/players` | Welt-Spieler auflisten | [worlds.md](worlds.md#list-players) |

### **📨 Invite System**
| Endpunkt | Beschreibung | Dokumentation |
|----------|--------------|---------------|
| `POST /invites` | Einladung erstellen | [invites.md](invites.md#create-invite) |
| `GET /invites/validate/:token` | Einladung validieren | [invites.md](invites.md#validate-invite) |
| `POST /invites/accept/:token` | Einladung annehmen | [invites.md](invites.md#accept-invite) |
| `POST /invites/decline/:token` | Einladung ablehnen | [invites.md](invites.md#decline-invite) |
| `GET /invites` | Meine Einladungen | [invites.md](invites.md#list-invites) |
| `DELETE /invites/:id` | Einladung löschen | [invites.md](invites.md#delete-invite) |

### **🎨 Theme System**
| Endpunkt | Beschreibung | Dokumentation |
|----------|--------------|---------------|
| `GET /themes` | Verfügbare Themes | Swagger `/api/docs` |
| `GET /themes/:id` | Theme-Details | Swagger `/api/docs` |
| `GET /themes/bundles` | Theme-Bundles | Swagger `/api/docs` |
| `GET /themes/world/:worldId` | Welt-spezifisches Theme | Swagger `/api/docs` |

### **⚙️ System & Health**
| Endpunkt | Beschreibung | Dokumentation |
|----------|--------------|---------------|
| `GET /health` | System-Status | Swagger `/api/docs` |
| `GET /version` | API-Version | Swagger `/api/docs` |
| `GET /docs` | Swagger-Dokumentation | Auto-generiert |

---

## 📊 **Standard API-Responses**

### **Erfolgreiche Response**
```json
{
  "success": true,
  "data": {
    // Response-spezifische Daten
  },
  "message": "Operation successful"
}
```

### **Fehler-Response**
```json
{
  "success": false,
  "error": {
    "code": "ERROR_CODE",
    "message": "Human-readable error message",
    "details": "Additional error details"
  }
}
```

### **Validierungsfehler**
```json
{
  "success": false,
  "error": {
    "code": "VALIDATION_ERROR",
    "message": "Validation failed",
    "fields": {
      "email": ["Email is required", "Email format is invalid"],
      "password": ["Password must be at least 8 characters"]
    }
  }
}
```

---

## 🔒 **Authentifizierung & Autorisierung**

### **JWT Token Structure**
```json
{
  "user": {
    "id": 123,
    "username": "player1",
    "email": "player@example.com",
    "roles": ["player"]
  },
  "permissions": [
    "view_worlds",
    "join_worlds", 
    "create_invites"
  ],
  "iat": 1704067200,
  "exp": 1704153600
}
```

### **Permission Scopes**
- **global**: System-weite Berechtigungen
- **world**: Welt-spezifische Berechtigungen  
- **module**: Modul-spezifische Berechtigungen
- **player**: Spieler-spezifische Berechtigungen

### **Common Permissions**
```yaml
# World Management
view_worlds: "Welten anzeigen"
edit_worlds: "Welten bearbeiten"
create_worlds: "Welten erstellen"
delete_worlds: "Welten löschen"

# Player Management  
join_worlds: "Welten beitreten"
leave_worlds: "Welten verlassen"
invite_players: "Spieler einladen"
view_world_players: "Welt-Spieler anzeigen"

# System Administration
admin_access: "Administrative Rechte"
user_management: "Benutzer-Verwaltung"
system_config: "System-Konfiguration"
```

---

## 📨 **Request/Response-Beispiele**

### **Benutzer-Registrierung**
```http
POST /api/auth/register
Content-Type: application/json

{
  "username": "newplayer",
  "email": "newplayer@example.com",
  "password": "securePassword123"
}
```

**Response:**
```json
{
  "success": true,
  "data": {
    "user": {
      "id": 456,
      "username": "newplayer", 
      "email": "newplayer@example.com",
      "createdAt": "2025-01-05T10:30:00Z"
    },
    "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
  },
  "message": "User registered successfully"
}
```

### **Welt beitreten**
```http
POST /api/worlds/123/join
Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
```

**Response:**
```json
{
  "success": true,
  "data": {
    "worldId": 123,
    "playerId": 456,
    "joinedAt": "2025-01-05T10:45:00Z",
    "status": "active"
  },
  "message": "Successfully joined world"
}
```

---

## ⚡ **Rate Limiting**

### **Limits pro Endpunkt**
```yaml
# Authentication
/auth/login: 5 requests/minute
/auth/register: 3 requests/minute

# General API
/api/*: 100 requests/minute/user

# Invite System  
/invites: 10 creates/hour/user

# Theme System
/themes: 50 requests/minute/user
```

### **Rate Limit Headers**
```http
X-RateLimit-Limit: 100
X-RateLimit-Remaining: 87
X-RateLimit-Reset: 1704067800
```

---

## 🔍 **Filtering & Pagination**

### **Query-Parameter**
```http
GET /api/worlds?status=open&page=2&limit=10&sort=name&order=asc
```

### **Standard Query-Parameter**
- `page`: Seiten-Nummer (default: 1)
- `limit`: Einträge pro Seite (default: 20, max: 100)
- `sort`: Sortier-Feld
- `order`: Sortier-Richtung (`asc`, `desc`)
- `search`: Text-Suche
- `filter[field]`: Feld-spezifische Filter

### **Pagination Response**
```json
{
  "success": true,
  "data": [
    // ... Array von Einträgen
  ],
  "pagination": {
    "page": 2,
    "limit": 10,
    "total": 157,
    "pages": 16,
    "hasNext": true,
    "hasPrev": true
  }
}
```

---

## 🚨 **Fehler-Codes**

### **HTTP Status Codes**
- `200`: OK - Erfolgreich
- `201`: Created - Ressource erstellt
- `400`: Bad Request - Ungültige Anfrage
- `401`: Unauthorized - Authentifizierung erforderlich
- `403`: Forbidden - Keine Berechtigung
- `404`: Not Found - Ressource nicht gefunden
- `409`: Conflict - Konflikt (z.B. Email bereits vergeben)
- `422`: Unprocessable Entity - Validierungsfehler
- `429`: Too Many Requests - Rate Limit überschritten
- `500`: Internal Server Error - Server-Fehler

### **Custom Error Codes**
```yaml
# Authentication
AUTH_INVALID_CREDENTIALS: "Username oder Passwort falsch"
AUTH_TOKEN_EXPIRED: "Token ist abgelaufen"
AUTH_TOKEN_INVALID: "Token ist ungültig"

# Validation
VALIDATION_EMAIL_INVALID: "Email-Format ist ungültig"
VALIDATION_PASSWORD_WEAK: "Passwort zu schwach"
VALIDATION_USERNAME_TAKEN: "Username bereits vergeben"

# World Management
WORLD_NOT_FOUND: "Welt nicht gefunden"
WORLD_ACCESS_DENIED: "Zugriff auf Welt verweigert"
WORLD_ALREADY_JOINED: "Bereits Mitglied dieser Welt"

# Invite System
INVITE_TOKEN_INVALID: "Einladungs-Token ungültig"
INVITE_EXPIRED: "Einladung ist abgelaufen"
INVITE_ALREADY_USED: "Einladung bereits verwendet"
```

---

## 🛠️ **Development Tools**

### **Swagger/OpenAPI**
- **URL**: `https://<VM-IP>/api/docs`
- **Interactive**: Alle Endpunkte testbar
- **Schema**: Vollständige Request/Response-Schemas
- **Authentication**: JWT-Token-Support

### **Postman Collection**
```bash
# Postman Collection exportieren
curl https://<VM-IP>/api/docs/json > weltenwind-api.json
```

### **API Testing**
```bash
# Health Check
curl https://<VM-IP>/api/health

# Authentication Test
curl -X POST https://<VM-IP>/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"username": "testuser", "password": "testpass"}'
```

---

## 📚 **Detaillierte Dokumentation**

- **[Authentication](auth.md)**: Benutzer-Management & Security
- **[World Management](worlds.md)**: Welten erstellen & verwalten
- **[Invite System](invites.md)**: Einladungs-Funktionen
- **[Theme System](themes.md)**: Visuelle Anpassungen
- **[Error Handling](errors.md)**: Fehlerbehandlung & Debugging

---

**API-Version**: v1.0  
**Erstellt**: Januar 2025  
**Swagger-Docs**: `/api/docs`  
**Support**: [GitHub Issues](https://github.com/dasBoooot/weltenwind/issues)