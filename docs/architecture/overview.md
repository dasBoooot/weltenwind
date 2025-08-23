# System-Architektur Übersicht

## Weltenwind Backend-System

### Technologie-Stack
- **Runtime**: Node.js mit TypeScript
- **Framework**: Express.js
- **Datenbank**: PostgreSQL mit Prisma ORM
- **Authentifizierung**: JWT + Session-Management
- **Autorisierung**: RBAC (Role-Based Access Control)

### System-Komponenten

```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   Client Apps   │    │   API Gateway   │    │   Backend API   │
│                 │◄──►│   (Express)     │◄──►│   (Node.js)     │
└─────────────────┘    └─────────────────┘    └─────────────────┘
                                                       │
                                                       ▼
                                              ┌─────────────────┐
                                              │   PostgreSQL    │
                                              │   Database      │
                                              └─────────────────┘
```

### Architektur-Prinzipien

#### 1. **Layered Architecture**
- **Presentation Layer**: Express Routes
- **Business Logic Layer**: Services
- **Data Access Layer**: Prisma ORM
- **Database Layer**: PostgreSQL

#### 2. **Service-Oriented Design**
- **Session Service**: Session-Management
- **Access Control Service**: Berechtigungsprüfung
- **Auth Service**: Authentifizierung (in Routes)
- **World Service**: Welten-Management (in Routes)

#### 3. **Security-First**
- JWT-basierte Authentifizierung
- Scope-basierte Autorisierung
- IP-Hashing für Sessions
- Device-Fingerprinting

### Datenfluss

#### Authentifizierung
```
1. Client → POST /api/auth/login
2. Server → Validierung (Username/Password)
3. Server → JWT Token generieren
4. Server → Session in DB speichern
5. Server → Token an Client zurückgeben
```

#### API-Zugriff
```
1. Client → Request mit JWT Token
2. Middleware → Token validieren
3. Middleware → User aus Token extrahieren
4. Route → Business Logic ausführen
5. Service → Berechtigungen prüfen
6. Service → Datenbank-Operation
7. Server → Response an Client
```

### Welten-System

#### Welt-Lebenszyklus
```
upcoming → open → running → closed → archived
```

#### Player-Management
- **Beitreten**: Player-Eintrag erstellen
- **Verlassen**: Player-Eintrag löschen
- **Status**: Spieler-Status verfolgen

#### Invite-System
- **Einladung erstellen**: Token generieren
- **Einladung akzeptieren**: Token validieren
- **Automatischer Beitritt**: Nach Token-Validierung

### Berechtigungssystem (RBAC)

#### Scope-Typen
- **global**: System-weite Berechtigungen
- **world**: Welt-spezifische Berechtigungen
- **module**: Modul-spezifische Berechtigungen
- **player**: Spieler-spezifische Berechtigungen

#### Berechtigungs-Hierarchie
```
User → UserRole → Role → RolePermission → Permission
```

#### Beispiel-Berechtigungen
- `view_worlds` (global)
- `edit_worlds` (world-scoped)
- `invite_players` (world-scoped)
- `view_world_players` (world-scoped)

### Skalierbarkeit

#### Horizontale Skalierung
- **Stateless Design**: JWT-basierte Auth
- **Session-Management**: Datenbank-basiert
- **Load Balancing**: Mehrere Instanzen möglich

#### Vertikale Skalierung
- **Connection Pooling**: Prisma ORM
- **Query Optimization**: Prisma Query Builder
- **Indexing**: Datenbank-Indizes

### Monitoring & Logging

#### Logging-Strategie
- **Request Logging**: Express Middleware
- **Error Logging**: Try-Catch Blocks
- **Security Logging**: Login-Attempts
- **Performance Logging**: Query-Times

#### Metriken
- **API Response Times**
- **Database Query Performance**
- **Error Rates**
- **User Activity**

### Deployment

#### Umgebungen
- **Development**: Lokale Entwicklung
- **Staging**: Test-Umgebung
- **Production**: Live-System

#### Containerisierung
- **Docker**: Container-basiertes Deployment
- **Environment Variables**: Konfiguration
- **Health Checks**: System-Monitoring 