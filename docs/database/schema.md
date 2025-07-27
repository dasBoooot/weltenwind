# Datenbankschema

## Übersicht
Das Weltenwind-System verwendet PostgreSQL mit Prisma ORM. Das Schema ist in `backend/prisma/schema.prisma` definiert.

## Tabellen

### User
```sql
users (
  id INT PRIMARY KEY AUTO_INCREMENT,
  username VARCHAR UNIQUE NOT NULL,
  email VARCHAR UNIQUE NOT NULL,
  password_hash VARCHAR NOT NULL,
  is_locked BOOLEAN DEFAULT FALSE
)
```
**Beziehungen:**
- `sessions` - Benutzer-Sessions
- `roles` - Benutzer-Rollen (über UserRole)
- `players` - Spieler-Einträge in Welten
- `invites` - Erstellte Einladungen
- `passwordResets` - Passwort-Reset-Tokens
- `preRegistrations` - Vorregistrierungen

### Role
```sql
roles (
  id INT PRIMARY KEY AUTO_INCREMENT,
  name VARCHAR UNIQUE NOT NULL,
  description VARCHAR
)
```
**Beziehungen:**
- `permissions` - Rollen-Berechtigungen (über RolePermission)
- `users` - Benutzer mit dieser Rolle (über UserRole)

### Permission
```sql
permissions (
  id INT PRIMARY KEY AUTO_INCREMENT,
  name VARCHAR UNIQUE NOT NULL,
  description VARCHAR
)
```
**Beziehungen:**
- `roles` - Rollen mit dieser Berechtigung (über RolePermission)

### UserRole
```sql
user_roles (
  id INT PRIMARY KEY AUTO_INCREMENT,
  user_id INT NOT NULL,
  role_id INT NOT NULL,
  scope_type VARCHAR NOT NULL,
  scope_object_id VARCHAR NOT NULL,
  condition VARCHAR,
  UNIQUE(user_id, role_id, scope_type, scope_object_id)
)
```
**Scopes:**
- `global` - Globale Berechtigung
- `world` - Welt-spezifische Berechtigung
- `module` - Modul-spezifische Berechtigung
- `player` - Spieler-spezifische Berechtigung

### RolePermission
```sql
role_permissions (
  id INT PRIMARY KEY AUTO_INCREMENT,
  role_id INT NOT NULL,
  permission_id INT NOT NULL,
  scope_type VARCHAR NOT NULL,
  scope_object_id VARCHAR NOT NULL,
  access_level VARCHAR NOT NULL,
  UNIQUE(role_id, permission_id, scope_type, scope_object_id)
)
```

### Session
```sql
sessions (
  id INT PRIMARY KEY AUTO_INCREMENT,
  user_id INT NOT NULL,
  token VARCHAR NOT NULL,
  created_at TIMESTAMP DEFAULT NOW(),
  expires_at TIMESTAMP NOT NULL,
  ip_hash VARCHAR,
  device_fingerprint VARCHAR,
  UNIQUE(user_id, token)
)
```

### World
```sql
worlds (
  id INT PRIMARY KEY AUTO_INCREMENT,
  name VARCHAR UNIQUE NOT NULL,
  status ENUM('upcoming', 'open', 'running', 'closed', 'archived') DEFAULT 'upcoming',
  created_at TIMESTAMP DEFAULT NOW(),
  starts_at TIMESTAMP NOT NULL,
  ends_at TIMESTAMP
)
```

### Player
```sql
players (
  id INT PRIMARY KEY AUTO_INCREMENT,
  user_id INT NOT NULL,
  world_id INT NOT NULL,
  joined_at TIMESTAMP DEFAULT NOW(),
  left_at TIMESTAMP,
  state VARCHAR,
  UNIQUE(user_id, world_id)
)
```

### Invite
```sql
invites (
  id INT PRIMARY KEY AUTO_INCREMENT,
  world_id INT NOT NULL,
  email VARCHAR NOT NULL,
  token VARCHAR UNIQUE NOT NULL,
  invited_by_id INT,
  created_at TIMESTAMP DEFAULT NOW(),
  accepted_at TIMESTAMP,
  expires_at TIMESTAMP
)
```

### PasswordReset
```sql
password_resets (
  id INT PRIMARY KEY AUTO_INCREMENT,
  user_id INT NOT NULL,
  token VARCHAR UNIQUE NOT NULL,
  created_at TIMESTAMP DEFAULT NOW(),
  used_at TIMESTAMP,
  expires_at TIMESTAMP NOT NULL
)
```

### PreRegistration
```sql
pre_registrations (
  id INT PRIMARY KEY AUTO_INCREMENT,
  user_id INT,
  world_id INT NOT NULL,
  email VARCHAR NOT NULL,
  config JSON,
  created_at TIMESTAMP DEFAULT NOW(),
  UNIQUE(email, world_id)
)
```

## Indizes
- Alle Primärschlüssel sind automatisch indiziert
- Unique Constraints erstellen automatisch Indizes
- Foreign Key Constraints für Referenzintegrität

## Beziehungen
Das Schema verwendet ein flexibles RBAC-System mit Scope-basierten Berechtigungen, das sowohl globale als auch objekt-spezifische Berechtigungen unterstützt. 