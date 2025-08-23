# Entwicklungssetup

## Voraussetzungen

### System-Anforderungen
- **Node.js** (Version 18 oder höher)
- **PostgreSQL** (Version 13 oder höher)
- **Git**

### Installation

1. **Node.js installieren**
   ```bash
   # Windows: https://nodejs.org/
   # Linux: sudo apt install nodejs npm
   # macOS: brew install node
   ```

2. **PostgreSQL installieren**
   ```bash
   # Windows: https://www.postgresql.org/download/windows/
   # Linux: sudo apt install postgresql postgresql-contrib
   # macOS: brew install postgresql
   ```

## Projekt-Setup

### 1. Repository klonen
```bash
git clone <repository-url>
cd weltenwind
```

### 2. Backend-Dependencies installieren
```bash
cd backend
npm install
```

### 3. Umgebungsvariablen konfigurieren
Erstellen Sie eine `.env` Datei im `backend/` Verzeichnis:
```env
# Datenbank
DATABASE_URL="postgresql://username:password@localhost:5432/weltenwind"

# JWT
JWT_SECRET="your-secret-key-here"

# Server
PORT=3000
NODE_ENV=development
```

### 4. Datenbank einrichten
```bash
# Prisma Client generieren
npx prisma generate

# Migrationen ausführen
npx prisma migrate dev

# Seed-Daten laden (optional)
npx prisma db seed
```

### 5. Server starten
```bash
# Entwicklungsserver
npm run dev

# Oder direkt mit ts-node
npx ts-node src/server.ts
```

## Entwicklungstools

### Prisma Studio
```bash
# Datenbank-GUI öffnen
npx prisma studio
```

### API-Dokumentation
```bash
# OpenAPI kombinierte Spezifikation generieren
cd docs/openapi
npm install
node generate-openapi.js
# Swagger UI ist über das Backend erreichbar: https://<VM-IP>/api/docs
```

### Datenbank-Migrationen
```bash
# Neue Migration erstellen
npx prisma migrate dev --name migration_name

# Migrationen zurücksetzen
npx prisma migrate reset

# Migration-Status prüfen
npx prisma migrate status
```

## Debugging

### Logs aktivieren
```bash
# Debug-Modus
DEBUG=* npm run dev

# Oder in der .env
DEBUG=prisma:query,express:*
```

### Datenbank-Debugging
```bash
# Prisma Query Logs
npx prisma studio --log-level debug
```

## Tests

### Unit Tests
```bash
npm test
```

### Integration Tests
```bash
npm run test:integration
```

## Plattform-Hinweise (Projekt-Setup)
- Windows PowerShell verwenden (keine Linux-Only Befehle).
- API-Tests gegen `https://<VM-IP>/api` (kein `localhost` im VM-Setup).

## Deployment

### Produktions-Build
```bash
npm run build
```

### Docker (optional)
```bash
docker build -t weltenwind-backend .
docker run -p 3000:3000 weltenwind-backend
```

## Troubleshooting

### Häufige Probleme

1. **Prisma Client nicht gefunden**
   ```bash
   npx prisma generate
   ```

2. **Datenbank-Verbindung fehlgeschlagen**
   - PostgreSQL-Service prüfen
   - DATABASE_URL in .env überprüfen
   - Firewall-Einstellungen prüfen

3. **JWT-Fehler**
   - JWT_SECRET in .env setzen
   - Token-Format prüfen

4. **Port bereits belegt**
   - Anderen Port in .env setzen
   - Prozess auf Port 3000 beenden 