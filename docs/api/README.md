# Weltenwind API Übersicht

## Authentifizierung
Alle geschützten Endpunkte erfordern einen gültigen JWT-Token im Authorization-Header:
```
Authorization: Bearer <token>
```

## Endpunkte

### Authentifizierung (`/api/auth`)
- `POST /api/auth/login` - Benutzer anmelden
- `POST /api/auth/logout` - Benutzer abmelden
- `POST /api/auth/register` - Neuen Benutzer registrieren
- `POST /api/auth/request-reset` - Passwort-Reset anfordern
- `POST /api/auth/reset-password` - Passwort zurücksetzen
- `GET /api/auth/me` - Aktuelle Benutzerdaten abrufen

### Welten (`/api/worlds`)
- `GET /api/worlds` - Alle nicht archivierten Welten abrufen
- `POST /api/worlds/:id/edit` - Welt-Status ändern
- `POST /api/worlds/:id/join` - Welt beitreten
- `DELETE /api/worlds/:id/players/me` - Welt verlassen
- `GET /api/worlds/:id/players/me` - Eigenen Spielstatus abrufen
- `GET /api/worlds/:id/players` - Alle Spieler einer Welt (Admin)
- `GET /api/worlds/:id/state` - Welt-Status abrufen
- `POST /api/worlds/:id/invites` - Einladungen erstellen
- `POST /api/worlds/:id/pre-register` - Vorregistrierung
- `DELETE /api/worlds/:id/pre-register` - Vorregistrierung zurückziehen

## Status-Codes
- `200` - Erfolg
- `201` - Erstellt
- `400` - Ungültige Anfrage
- `401` - Nicht authentifiziert
- `403` - Keine Berechtigung
- `404` - Nicht gefunden
- `409` - Konflikt (z.B. bereits existierend)

## Fehlerbehandlung
Alle Fehlerantworten folgen dem Format:
```json
{
  "error": "Fehlermeldung"
}
``` 