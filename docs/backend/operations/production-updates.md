# Produktions-Updates & Datenbank-Migrationen

## Prisma in Produktion

**Prisma ist definitiv für Produktion geeignet!** Es bietet verschiedene Mechanismen für sichere Datenbank-Updates:

## 1. Schema-Migrationen (Struktur-Änderungen)

Für Änderungen an der Datenbank-Struktur:

```bash
# Entwicklung: Erstelle neue Migration
npx prisma migrate dev --name add_new_feature

# Produktion: Wende Migrationen an
npx prisma migrate deploy
```

## 2. Daten-Migrationen (bestehende Daten updaten)

### Option A: Update-Scripts (Empfohlen für einmalige Updates)

```bash
# JavaScript (einfach)
node prisma/update/update-user-roles.js

# TypeScript (typsicher)
npx ts-node prisma/update/update-existing-users.ts
```

**Vorteile:**
- Volle Kontrolle
- Kann schrittweise ausgeführt werden
- Einfach zu testen

### Option B: Prisma Seed (für initiale Daten)

In `package.json`:
```json
{
  "prisma": {
    "seed": "ts-node prisma/seed.ts"
  }
}
```

Seed ausführen:
```bash
npx prisma db seed
```

**Achtung:** Seeds sind für initiale Daten gedacht, nicht für Updates!

### Option C: SQL-Migrationen

Für komplexe Updates direkt in SQL:

```sql
-- prisma/migrations/20250728_update_user_roles/migration.sql
-- Füge fehlende User-Rollen hinzu
INSERT INTO user_roles (user_id, role_id, scope_type, scope_object_id)
SELECT u.id, r.id, 'global', 'global'
FROM users u
CROSS JOIN roles r
WHERE r.name = 'user'
AND NOT EXISTS (
  SELECT 1 FROM user_roles ur 
  WHERE ur.user_id = u.id 
  AND ur.role_id = r.id 
  AND ur.scope_type = 'global'
);
```

## 3. Best Practices für Produktions-Updates

### Vor dem Update:
1. **Backup erstellen**
   ```bash
   pg_dump weltenwind > backup_$(date +%Y%m%d).sql
   ```

2. **Test-Umgebung nutzen**
   - Kopie der Produktions-DB
   - Update-Script testen
   - Performance prüfen

3. **Rollback-Plan**
   - Wie macht man das Update rückgängig?
   - Backup bereit halten

### Update-Strategie:

```bash
# 1. Code deployen (mit neuer Logik)
git pull
npm install
npx prisma generate

# 2. Services stoppen
sudo systemctl stop weltenwind-backend

# 3. DB-Migrationen
npx prisma migrate deploy

# 4. Daten-Updates
node update-user-roles.js

# 5. Services starten
sudo systemctl start weltenwind-backend
```

## 4. Automatische Updates bei Schema-Erweiterungen

Für zukünftige Erweiterungen kannst du einen "Smart Seeder" bauen:

```typescript
// prisma/smart-seeder.ts
async function ensureUserHasAllScopes(userId: number) {
  const requiredScopes = [
    { scopeType: 'global', scopeObjectId: 'global' },
    { scopeType: 'world', scopeObjectId: '*' },
    // Neue Scopes hier hinzufügen
    // { scopeType: 'game', scopeObjectId: '*' },
  ];
  
  for (const scope of requiredScopes) {
    await prisma.userRole.upsert({
      where: {
        userId_roleId_scopeType_scopeObjectId: {
          userId,
          roleId: userRoleId,
          scopeType: scope.scopeType,
          scopeObjectId: scope.scopeObjectId
        }
      },
      create: {
        userId,
        roleId: userRoleId,
        scopeType: scope.scopeType,
        scopeObjectId: scope.scopeObjectId
      },
      update: {} // Nichts updaten wenn vorhanden
    });
  }
}
```

## 5. Monitoring & Logging

Wichtig für Produktion:

```typescript
// Bei Updates immer loggen
console.log(`[${new Date().toISOString()}] Updated user ${username}`);

// Prisma Logs aktivieren
const prisma = new PrismaClient({
  log: ['query', 'info', 'warn', 'error'],
});
```

## 6. Checkliste für Rollen-Erweiterungen

- [ ] Schema erweitern (falls neue Felder)
- [ ] Registrierungs-Logik anpassen
- [ ] Update-Script für bestehende User schreiben
- [ ] In Test-Umgebung testen
- [ ] Backup erstellen
- [ ] Update durchführen
- [ ] Verifizieren (check-db-direct.js)

## Zusammenfassung

- **Prisma ist produktionsreif** und wird von vielen großen Projekten genutzt
- **Schema-Migrationen** für Struktur-Änderungen
- **Update-Scripts** für Daten-Änderungen
- **Immer testen** bevor Produktion
- **Backups** sind Pflicht!

Bei Fragen zu spezifischen Update-Szenarien, frag gerne nach! 