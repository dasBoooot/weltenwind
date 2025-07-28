# Prisma Update Scripts

Dieses Verzeichnis enthält Update-Scripts für Datenbank-Wartung und Daten-Migrationen.

## ⚠️ Wichtig

Dieses Verzeichnis ist **SICHER** vor `prisma migrate reset` - es wird NICHT gelöscht!

Das `migrations/` Verzeichnis hingegen wird bei einem Reset komplett entfernt.

## 📁 Inhalt

- `update-user-roles.js` - JavaScript-Script zum Updaten bestehender User mit Standard-Rollen
- `update-existing-users.ts` - TypeScript-Version mit erweiterten Features

## 🚀 Verwendung

### User-Rollen updaten (JavaScript)

```bash
cd backend
node prisma/update/update-user-roles.js
```

### User-Rollen updaten (TypeScript)

```bash
cd backend
npx ts-node prisma/update/update-existing-users.ts
```

## 📝 Neue Update-Scripts erstellen

Lege neue Update-Scripts immer hier ab, NICHT im `migrations/` Ordner!

### Namenskonvention

- `update-[feature].js` - für einfache JavaScript-Scripts
- `update-[feature].ts` - für TypeScript-Scripts
- `fix-[problem].js` - für Bugfix-Scripts
- `migrate-[data].js` - für Daten-Migrationen

### Beispiel-Template

```javascript
// update-new-feature.js
const { PrismaClient } = require('@prisma/client');
const prisma = new PrismaClient();

async function main() {
  console.log('🔄 Starte Update...');
  
  // Dein Update-Code hier
  
  console.log('✅ Update abgeschlossen!');
}

main()
  .catch((e) => {
    console.error('❌ Fehler:', e);
    process.exit(1);
  })
  .finally(async () => {
    await prisma.$disconnect();
  });
```

## 🔒 Backup

Vor jedem Update in Produktion:

```bash
pg_dump weltenwind > backup_$(date +%Y%m%d_%H%M%S).sql
``` 