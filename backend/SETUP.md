# Backend Setup - Wichtige Schritte

## Datenbank-Seeds ausführen

**WICHTIG**: Nach der Datenbank-Migration müssen die Seeds ausgeführt werden, damit Rollen und Berechtigungen korrekt angelegt werden!

```bash
cd backend
npm run seed
```

Dies erstellt:
- Standard-Rollen (admin, developer, support, user, mod, world-admin)
- Permissions
- Rollen-Permission-Zuweisungen
- Test-User

## Problembehebung

### "Standard-User-Rolle nicht gefunden" bei Registrierung

Dieser Fehler tritt auf, wenn die Seeds nicht ausgeführt wurden. Lösung:

```bash
cd backend
npm run seed
```

### Seeds komplett zurücksetzen

Falls die Datenbank in einem inkonsistenten Zustand ist:

```bash
cd backend
npm run reset  # Setzt DB zurück und führt Seeds neu aus
```

## Verfügbare Seed-Scripts

- `npm run seed` - Führt alle Seeds aus
- `npm run seed:worlds` - Nur Test-Welten erstellen
- `npm run reset` - Datenbank zurücksetzen und neu seeden 