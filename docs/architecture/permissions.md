# Permission-System Dokumentation

## Übersicht
Das Weltenwind-System verwendet ein **Role-Based Access Control (RBAC)** System mit **Scope-basierten Berechtigungen**. Das System folgt der Konvention `scope.permission`.

## Naming Convention
- **Format:** `scope.permission`
- **Beispiele:** `world.view`, `player.join`, `invite.create`, `system.admin`

## Permission-Kategorien

### 1. Welt-Management (`world.*`)
| Permission | Beschreibung | Scope | Access Level |
|------------|--------------|-------|--------------|
| `world.view` | Welten anzeigen | global | read |
| `world.create` | Welten erstellen | global | write |
| `world.edit` | Welten bearbeiten | global/world | write/admin |
| `world.delete` | Welten löschen | global | admin |
| `world.archive` | Welten archivieren | global/world | admin |

### 2. Player-Management (`player.*`)
| Permission | Beschreibung | Scope | Access Level |
|------------|--------------|-------|--------------|
| `player.join` | Welt beitreten | global/world | write |
| `player.leave` | Welt verlassen | global/world | write |
| `player.view_own` | Eigenen Status anzeigen | global/world | read |
| `player.view_all` | Alle Spieler anzeigen | global/world | read |
| `player.invite` | Spieler einladen | global/world | moderate/admin |
| `player.kick` | Spieler kicken | global/world | moderate/admin |
| `player.ban` | Spieler bannen | global/world | admin |
| `player.mute` | Spieler stummschalten | world | moderate |
| `player.promote` | Spieler befördern | world | admin |
| `player.demote` | Spieler degradieren | world | admin |

### 3. Invite-Management (`invite.*`)
| Permission | Beschreibung | Scope | Access Level |
|------------|--------------|-------|--------------|
| `invite.create` | Einladungen erstellen | global/world | moderate/admin |
| `invite.view` | Einladungen anzeigen | global/world | read |
| `invite.manage` | Einladungen verwalten | global/world | admin |
| `invite.delete` | Einladungen löschen | global/world | admin |

### 4. System-Management (`system.*`)
| Permission | Beschreibung | Scope | Access Level |
|------------|--------------|-------|--------------|
| `system.admin` | Vollzugriff | global | admin |
| `system.moderation` | Moderation | global | moderate |
| `system.support` | Support-Funktionen | global | moderate |
| `system.development` | Entwickler-Funktionen | global | admin |
| `system.view_own` | Eigene Daten anzeigen | global | read |

## Rollen und ihre Permissions

### 🔧 Admin-Rolle
- **Scope:** global + world
- **Permissions:** Alle Permissions mit admin access level
- **Besonderheit:** Hat sowohl global als auch world scope für alle relevanten Permissions

### 👨‍💻 Developer-Rolle
- **Scope:** global + world
- **Permissions:** 
  - `system.development` (global, admin)
  - `world.view` (global, read)
  - `world.edit` (global/world, write)
  - `player.view_all` (global/world, read)
  - `system.view_own` (global, read)

### 🛠️ Support-Rolle
- **Scope:** global + world
- **Permissions:**
  - `system.support` (global, moderate)
  - `world.view` (global, read)
  - `player.view_all` (global/world, read)
  - `player.kick` (global/world, moderate)
  - `system.view_own` (global, read)

### 👤 User-Rolle
- **Scope:** global + world
- **Permissions:**
  - `world.view` (global, read)
  - `player.join` (global/world, write)
  - `player.leave` (global/world, write)
  - `player.view_own` (global/world, read)
  - `system.view_own` (global, read)

### 🌍 World-Admin-Rolle
- **Scope:** world (spezifisch für Welten)
- **Permissions:** Alle world-scoped Permissions mit admin access level
- **Besonderheit:** Nur für spezifische Welten, nicht global

### 🛡️ Mod-Rolle
- **Scope:** world (spezifisch für Welten)
- **Permissions:** Moderations-Permissions mit moderate access level
- **Besonderheit:** Nur für spezifische Welten, nicht global

## Access Levels

### 1. `none` - Keine Berechtigung
- Kein Zugriff auf die Funktion

### 2. `read` - Lesen
- Daten anzeigen, aber nicht ändern

### 3. `write` - Schreiben
- Daten lesen und ändern

### 4. `moderate` - Moderieren
- Erweiterte Rechte für Moderation

### 5. `admin` - Administrator
- Vollzugriff auf die Funktion

## Scope Types

### 1. `global` - Globale Berechtigung
- Gilt für das gesamte System
- Beispiel: `world.view` (global) - Alle Welten anzeigen

### 2. `world` - Welt-spezifische Berechtigung
- Gilt nur für eine bestimmte Welt
- Beispiel: `player.view_all` (world) - Alle Spieler einer Welt anzeigen

### 3. `module` - Modul-spezifische Berechtigung
- Gilt für ein bestimmtes Modul
- Beispiel: `chat.moderate` (module) - Chat in einem Modul moderieren

### 4. `player` - Spieler-spezifische Berechtigung
- Gilt für einen bestimmten Spieler
- Beispiel: `player.manage` (player) - Einen Spieler verwalten

## Implementation

### Permission-Check
```typescript
const allowed = await hasPermission(userId, 'player.view_all', {
  type: 'world',
  objectId: worldId.toString()
});
```

### Scope-Context
```typescript
interface ScopeContext {
  type: string;        // z. B. 'global', 'world', 'module', 'player'
  objectId: string;    // z. B. 'w123'
}
```

## Extensibility

### Neue Permissions hinzufügen
1. **Permission in `permissions.seed.ts` hinzufügen**
2. **Role-Permission-Mapping in `role-permissions.seed.ts`**
3. **API-Endpoint mit `hasPermission` schützen**
4. **Swagger-Dokumentation aktualisieren**

### Neue Rollen hinzufügen
1. **Rolle in `roles.seed.ts` hinzufügen**
2. **Role-Permission-Mapping in `role-permissions.seed.ts`**
3. **User-Role-Assignments in `user-roles.seed.ts`**

## Best Practices

### 1. Permission-Naming
- Verwende `scope.permission` Format
- Sei spezifisch und eindeutig
- Gruppiere verwandte Permissions

### 2. Scope-Verwendung
- Verwende `global` für system-weite Berechtigungen
- Verwende `world` für welt-spezifische Berechtigungen
- Verwende spezifische Scopes für granularere Kontrolle

### 3. Access Level-Verwendung
- Verwende `read` für Datenanzeige
- Verwende `write` für Datenänderungen
- Verwende `moderate` für Moderations-Funktionen
- Verwende `admin` für Verwaltungs-Funktionen

## Migration Strategy

### 1. **Alte Permissions** identifizieren
### 2. **Code schrittweise** migrieren
### 3. **Alte Permissions** entfernen
### 4. **Tests** aktualisieren

## Aktuelle Implementierung

### ✅ Implementiert
- **24 Permissions** in 4 Kategorien
- **6 Rollen** mit spezifischen Berechtigungen
- **Scope-basierte** Permission-Checks
- **API-Endpoints** geschützt
- **Swagger-Dokumentation** mit Permission-Hinweisen

### 🔄 In Arbeit
- **World-scope Permissions** für alle Rollen
- **Granularere** Permission-Kontrolle
- **Performance-Optimierung** der Permission-Checks 