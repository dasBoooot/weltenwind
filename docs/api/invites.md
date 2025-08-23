# 📨 Weltenwind Invite System API

**Das Invite-System** ermöglicht es Spielern, Freunde zu ihren Welten einzuladen. Es bietet sichere, token-basierte Einladungen mit personalisierten Landing-Pages und automatischem Onboarding.

---

## 🎯 **System-Übersicht**

### **Invite-Workflow**
```
1. Spieler erstellt Einladung → Token generiert
2. Email wird an Eingeladenen gesendet
3. Eingeladener klickt Link → Invite Landing Page  
4. Automatisches Onboarding → Account-Erstellung falls nötig
5. Einladung akzeptieren → Automatischer Welt-Beitritt
```

### **Token-Security**
- **Zeitlich begrenzt**: Einladungen laufen nach konfigurierbarer Zeit ab
- **Einmalig verwendbar**: Token kann nur einmal akzeptiert werden
- **Email-gebunden**: Einladung ist an spezifische Email-Adresse gekoppelt
- **Sichere Generierung**: Kryptographisch sichere Token-Generierung

---

## 📡 **API-Endpunkte**

### **📤 Einladung erstellen**

```http
POST /api/invites
Authorization: Bearer YOUR_JWT_TOKEN
Content-Type: application/json
```

**Request Body:**
```json
{
  "worldId": 123,
  "email": "friend@example.com",
  "message": "Komm und spiele mit uns!" // Optional
}
```

**Response:**
```json
{
  "success": true,
  "data": {
    "id": 456,
    "token": "abc123xyz789",
    "worldId": 123,
    "email": "friend@example.com",
    "inviterUserId": 789,
    "message": "Komm und spiele mit uns!",
    "createdAt": "2025-01-05T10:30:00Z",
    "expiresAt": "2025-01-12T10:30:00Z",
    "status": "pending",
    "inviteUrl": "https://weltenwind.com/invite/abc123xyz789"
  },
  "message": "Invite created successfully"
}
```

**Error Cases:**
```json
// World nicht gefunden
{
  "success": false,
  "error": {
    "code": "WORLD_NOT_FOUND",
    "message": "World not found"
  }
}

// Keine Berechtigung für diese Welt
{
  "success": false,
  "error": {
    "code": "WORLD_ACCESS_DENIED", 
    "message": "You don't have permission to invite players to this world"
  }
}

// Email bereits Mitglied
{
  "success": false,
  "error": {
    "code": "USER_ALREADY_MEMBER",
    "message": "User is already a member of this world"
  }
}
```

---

### **🔍 Einladung validieren**

```http
GET /api/invites/validate/:token
```

**Response (Gültige Einladung):**
```json
{
  "success": true,
  "data": {
    "invite": {
      "id": 456,
      "email": "friend@example.com",
      "message": "Komm und spiele mit uns!",
      "createdAt": "2025-01-05T10:30:00Z",
      "expiresAt": "2025-01-12T10:30:00Z"
    },
    "world": {
      "id": 123,
      "name": "Mittelalter-Abenteuer",
      "description": "Eine epische mittelalterliche Welt voller Abenteuer",
      "themeBundle": "medieval",
      "themeVariant": "castle",
      "status": "open",
      "playerCount": 42,
      "maxPlayers": 100,
      "creator": {
        "username": "gamemaster"
      }
    },
    "inviter": {
      "id": 789,
      "username": "buddy123"
    },
    "userStatus": "not_registered" // Siehe User Status Types
  }
}
```

**Response (Ungültige Einladung):**
```json
{
  "success": false,
  "error": {
    "code": "INVITE_TOKEN_INVALID",
    "message": "Invitation token is invalid or expired"
  }
}
```

**User Status Types:**
- `not_registered`: User existiert nicht, muss sich registrieren
- `not_logged_in`: User existiert, ist aber nicht angemeldet
- `needs_login`: User ist angemeldet, aber als anderer User
- `wrong_email`: User ist angemeldet, aber mit anderer Email
- `can_accept`: User kann Einladung direkt akzeptieren
- `already_accepted`: Einladung bereits akzeptiert

---

### **✅ Einladung akzeptieren**

```http
POST /api/invites/accept/:token
Authorization: Bearer YOUR_JWT_TOKEN (falls angemeldet)
```

**Response (Erfolgreich):**
```json
{
  "success": true,
  "data": {
    "world": {
      "id": 123,
      "name": "Mittelalter-Abenteuer"
    },
    "player": {
      "id": 999,
      "userId": 456,
      "worldId": 123,
      "joinedAt": "2025-01-05T11:00:00Z",
      "status": "active"
    },
    "invite": {
      "id": 456,
      "acceptedAt": "2025-01-05T11:00:00Z",
      "status": "accepted"
    }
  },
  "message": "Invite accepted successfully"
}
```

**Error Cases:**
```json
// Token abgelaufen
{
  "success": false,
  "error": {
    "code": "INVITE_EXPIRED",
    "message": "Invitation has expired"
  }
}

// Bereits verwendet
{
  "success": false,
  "error": {
    "code": "INVITE_ALREADY_USED", 
    "message": "Invitation has already been used"
  }
}

// Falsche Email
{
  "success": false,
  "error": {
    "code": "INVITE_EMAIL_MISMATCH",
    "message": "Invitation is for different email address"
  }
}
```

---

### **❌ Einladung ablehnen**

```http
POST /api/invites/decline/:token
```

**Response:**
```json
{
  "success": true,
  "data": {
    "invite": {
      "id": 456,
      "declinedAt": "2025-01-05T11:15:00Z",
      "status": "declined"
    }
  },
  "message": "Invite declined successfully"
}
```

---

### **📋 Meine Einladungen auflisten**

```http
GET /api/invites
Authorization: Bearer YOUR_JWT_TOKEN
```

**Query-Parameter:**
- `status`: `pending`, `accepted`, `declined`, `expired`
- `worldId`: Nur Einladungen für bestimmte Welt
- `page`: Seiten-Nummer (default: 1)
- `limit`: Einträge pro Seite (default: 20)

**Response:**
```json
{
  "success": true,
  "data": [
    {
      "id": 456,
      "email": "friend@example.com",
      "worldId": 123,
      "worldName": "Mittelalter-Abenteuer",
      "message": "Komm und spiele mit uns!",
      "status": "pending",
      "createdAt": "2025-01-05T10:30:00Z",
      "expiresAt": "2025-01-12T10:30:00Z",
      "inviteUrl": "https://weltenwind.com/invite/abc123xyz789"
    }
  ],
  "pagination": {
    "page": 1,
    "limit": 20,
    "total": 5,
    "pages": 1
  }
}
```

---

### **🗑️ Einladung löschen**

```http
DELETE /api/invites/:id
Authorization: Bearer YOUR_JWT_TOKEN
```

**Response:**
```json
{
  "success": true,
  "message": "Invite deleted successfully"
}
```

**Permissions:**
- Nur der Ersteller der Einladung kann sie löschen
- World-Administratoren können alle Einladungen für ihre Welt löschen
- System-Administratoren können alle Einladungen löschen

---

## 🎨 **Frontend Integration**

### **Invite Landing Page**

Die Invite Landing Page (`/invite/:token`) bietet eine personalisierte Erfahrung:

#### **Komponenten:**
1. **App Branding**: Weltenwind-Logo und Beschreibung
2. **World Preview Card**: 
   - Emotionale Headline: `"{inviterName} lädt dich zu {worldName} ein!"`
   - World-Beschreibung und Theme-Information
   - Creator und Spieleranzahl
   - Call-to-Action: "Bereit für ein neues Abenteuer?"
3. **Status-spezifische Actions**: Je nach `userStatus`
4. **Technical Details**: Expandable mit Einladungs-Details

#### **User Status Handling:**

```typescript
switch (userStatus) {
  case 'not_registered':
    // Zeige Register-Button mit Auto-Accept
    // Email vorausgefüllt
    break;
    
  case 'needs_login':
    // Zeige Login-Button mit Redirect zurück
    break;
    
  case 'can_accept':
    // Zeige Accept/Decline Buttons
    break;
    
  case 'wrong_email':
    // Zeige Logout + Register für korrekte Email
    break;
    
  case 'already_accepted':
    // Zeige "Bereits akzeptiert" + Link zur Welt
    break;
}
```

### **Session Management Fix**

**Problem**: Gecachte Admin-Sessions führten zu unerwarteten Weiterleitungen.

**Lösung**: Vor jeder Navigation wird die Auth-Session gecleart:
```typescript
const authService = ServiceLocator.get<AuthService>();
if (await authService.isLoggedIn()) {
  await authService.logout();
  await Future.delayed(Duration(milliseconds: 100));
}
await context.smartGoNamed('register', extra: {...});
```

---

## 🔐 **Security & Validation**

### **Token-Sicherheit**
- **Länge**: 32 Zeichen, kryptographisch sicher
- **Gültigkeit**: 7 Tage (konfigurierbar)
- **Storage**: Gehashed in Datenbank
- **Rate Limiting**: Max 10 Einladungen pro Stunde pro User

### **Email-Validation**
```json
{
  "email": {
    "required": true,
    "format": "email",
    "maxLength": 255
  }
}
```

### **Permission-Checks**
- User muss Mitglied der Welt sein
- User muss `invite_players` Permission haben
- World muss Status `open` oder `running` haben

### **Spam-Prevention**
- Max 3 Einladungen pro Email pro Welt
- Cooldown: 24h zwischen Einladungen für gleiche Email
- Email-Blacklist-Support

---

## 📧 **Email-Integration**

### **Email-Template**
```html
<h1>🌍 Einladung zu {worldName}</h1>
<p>Hallo!</p>
<p>{inviterName} lädt dich zur Welt "{worldName}" ein!</p>

{message && <blockquote>{message}</blockquote>}

<p>Klicke hier um beizutreten:</p>
<a href="{inviteUrl}">Zur Einladung →</a>

<p>Diese Einladung läuft ab am: {expiresAt}</p>
```

### **Email-Provider**
- **SMTP-Support**: Konfigurierbar über Environment
- **Template-Engine**: Handlebars für dynamischen Content
- **Fallback**: Einfache Text-Emails wenn HTML nicht verfügbar

---

## 📊 **Analytics & Monitoring**

### **Tracked Events**
- `invite_created`: Einladung erstellt
- `invite_sent`: Email gesendet
- `invite_viewed`: Landing Page besucht
- `invite_accepted`: Einladung akzeptiert
- `invite_declined`: Einladung abgelehnt
- `invite_expired`: Einladung abgelaufen

### **Metrics**
```typescript
interface InviteMetrics {
  totalInvites: number;
  acceptanceRate: number; // accepted / (accepted + declined)
  conversionRate: number; // accepted / total
  averageResponseTime: number; // in hours
  topInvitingUsers: User[];
  topTargetWorlds: World[];
}
```

---

## 🧪 **Testing**

### **API-Tests**
```bash
# Invite erstellen
curl -X POST http://localhost:3000/api/invites \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"worldId": 1, "email": "test@example.com"}'

# Invite validieren  
curl http://localhost:3000/api/invites/validate/TOKEN

# Invite akzeptieren
curl -X POST http://localhost:3000/api/invites/accept/TOKEN \
  -H "Authorization: Bearer USER_TOKEN"
```

### **Frontend-Tests**
```typescript
// Landing Page für verschiedene User-Status testen
testInviteLandingPage('not_registered');
testInviteLandingPage('needs_login');
testInviteLandingPage('can_accept');
testInviteLandingPage('wrong_email');
```

---

**Erstellt**: Januar 2025  
**Version**: 1.0  
**Status**: ✅ Fully Implemented mit UX-Verbesserungen