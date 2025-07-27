# Test-User Übersicht

## Übersicht
Das Weltenwind-System enthält **10 Test-User** mit verschiedenen Rollen für Entwicklungs- und Testzwecke.

## Login-Daten
**Passwort für alle User:** `AAbb1234!!`

## User nach Rollen

### 🔧 Admin-Rolle
| Username | Email | Rolle | Scope | Beschreibung |
|----------|-------|-------|-------|--------------|
| `admin` | admin@weltenwind.de | admin | global + world | Vollzugriff auf alle Funktionen |

### 👨‍💻 Developer-Rolle
| Username | Email | Rolle | Scope | Beschreibung |
|----------|-------|-------|-------|--------------|
| `developer` | developer@weltenwind.de | developer | global + world | Systemtests, Balancing, Events |

### 🛠️ Support-Rolle
| Username | Email | Rolle | Scope | Beschreibung |
|----------|-------|-------|-------|--------------|
| `support` | support@weltenwind.de | support | global + world | Moderation, Support, Logs |

### 👤 User-Rolle
| Username | Email | Rolle | Scope | Beschreibung |
|----------|-------|-------|-------|--------------|
| `user` | user@weltenwind.de | user | global + world | Grundlegende Spieler-Funktionen |
| `testuser1` | testuser1@weltenwind.de | user | global + world | Zusätzlicher Test-User |
| `testuser2` | testuser2@weltenwind.de | user | global + world | Zusätzlicher Test-User |

### 🛡️ Mod-Rolle
| Username | Email | Rolle | Scope | Beschreibung |
|----------|-------|-------|-------|--------------|
| `mod` | mod@weltenwind.de | mod | world | Welt-Moderation |
| `moderator1` | moderator1@weltenwind.de | mod | world | Zusätzlicher Moderator |

### 🌍 World-Admin-Rolle
| Username | Email | Rolle | Scope | Beschreibung |
|----------|-------|-------|-------|--------------|
| `worldadmin` | worldadmin@weltenwind.de | world-admin | world | Welt-Besitzer/Ersteller |
| `worldowner1` | worldowner1@weltenwind.de | world-admin | world | Zusätzlicher Welt-Besitzer |

## Scope-Erklärung

### Global Scope
- **Bereich:** System-weit
- **ObjectId:** `global`
- **Verwendung:** Für globale Berechtigungen

### World Scope
- **Bereich:** Welt-spezifisch
- **ObjectId:** `*` (für alle Welten)
- **Verwendung:** Für welt-spezifische Berechtigungen

## Test-Szenarien

### 🔐 Login-Test
```bash
# Admin-Login
curl -X POST http://localhost:3000/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"username":"admin","password":"AAbb1234!!"}'
```

### 🌍 Welt-Funktionen testen
```bash
# Alle Welten anzeigen (admin)
curl -X GET http://localhost:3000/api/worlds \
  -H "Authorization: Bearer YOUR_TOKEN"

# Welt bearbeiten (admin)
curl -X POST http://localhost:3000/api/worlds/1/edit \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"status":"open"}'

# Spieler einladen (admin)
curl -X POST http://localhost:3000/api/worlds/1/invites \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"email":"newuser@example.com"}'

# Alle Spieler anzeigen (admin)
curl -X GET http://localhost:3000/api/worlds/1/players \
  -H "Authorization: Bearer YOUR_TOKEN"
```

### 👤 User-Funktionen testen
```bash
# Welt beitreten (user)
curl -X POST http://localhost:3000/api/worlds/1/join \
  -H "Authorization: Bearer USER_TOKEN"

# Eigenen Status anzeigen (user)
curl -X GET http://localhost:3000/api/worlds/1/players/me \
  -H "Authorization: Bearer USER_TOKEN"

# Welt verlassen (user)
curl -X DELETE http://localhost:3000/api/worlds/1/players/me \
  -H "Authorization: Bearer USER_TOKEN"
```

## Permission-Matrix

### Admin (global + world scope)
| Permission | Global | World | Beschreibung |
|------------|--------|-------|--------------|
| `world.view` | ✅ | ✅ | Alle Welten anzeigen |
| `world.edit` | ✅ | ✅ | Welten bearbeiten |
| `player.view_all` | ✅ | ✅ | Alle Spieler anzeigen |
| `invite.create` | ✅ | ✅ | Spieler einladen |
| `system.view_own` | ✅ | - | Eigene Daten anzeigen |

### User (global + world scope)
| Permission | Global | World | Beschreibung |
|------------|--------|-------|--------------|
| `world.view` | ✅ | ✅ | Welten anzeigen |
| `player.join` | ✅ | ✅ | Welt beitreten |
| `player.leave` | ✅ | ✅ | Welt verlassen |
| `player.view_own` | ✅ | ✅ | Eigenen Status anzeigen |
| `system.view_own` | ✅ | - | Eigene Daten anzeigen |

### Mod (world scope only)
| Permission | Global | World | Beschreibung |
|------------|--------|-------|--------------|
| `player.view_all` | ❌ | ✅ | Alle Spieler anzeigen |
| `player.kick` | ❌ | ✅ | Spieler kicken |
| `invite.create` | ❌ | ✅ | Spieler einladen |
| `system.view_own` | ✅ | - | Eigene Daten anzeigen |

## Troubleshooting

### Permission-Denied Fehler
1. **Prüfe User-Role-Zuordnung** in der Datenbank
2. **Prüfe Role-Permission-Mapping** für den Scope
3. **Prüfe Access Level** der Permission

### Scope-Probleme
- **Global Scope:** Für system-weite Berechtigungen
- **World Scope:** Für welt-spezifische Berechtigungen
- **Admin hat beide:** global + world scope
- **User hat beide:** global + world scope
- **Mod nur world:** Nur welt-spezifische Berechtigungen 