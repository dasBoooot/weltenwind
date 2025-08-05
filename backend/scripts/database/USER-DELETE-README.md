# 🗑️ User Delete Tool

Dieses Skript löscht einen User **komplett und unwiderruflich** aus der Weltenwind-Datenbank inklusive aller abhängigen Daten.

## ⚠️ WARNUNG

**Diese Aktion ist IRREVERSIBEL!** 

Das Skript löscht:
- ✅ User-Account (users)
- ✅ Alle Rollen-Zuweisungen (user_roles)  
- ✅ Alle aktiven Sessions (sessions)
- ✅ Alle Welt-Mitgliedschaften (players)
- ✅ Alle Vorregistrierungen (pre_registrations)
- ✅ Alle Password-Reset-Tokens (password_resets)
- ✅ Setzt Invite-Referenzen auf NULL (invites.invitedById)

## 🚀 Usage

### Basis-Syntax
```bash
# User per Username löschen
node delete-user.js <username>

# User per E-Mail löschen  
node delete-user.js <email>

# User per ID löschen
node delete-user.js --id <userId>
```

### Beispiele
```bash
# Über Username
node delete-user.js testuser

# Über E-Mail
node delete-user.js test@example.com

# Über User-ID
node delete-user.js --id 5
```

## 🧪 Sicherheit & Test

### Dry Run (Testlauf)
```bash
# Zeigt was gelöscht würde, ohne tatsächlich zu löschen
DRY_RUN=true node delete-user.js testuser
```

### Bestätigung
Das Skript fordert eine explizite Bestätigung:
- Gib `DELETE` ein um zu bestätigen
- Gib `ABBRUCH` oder `ABORT` ein um abzubrechen
- Jede andere Eingabe bricht ab

## 📊 Output-Beispiel

```
🗑️ WELTENWIND USER DELETE TOOL
==================================

🔍 Suche User: testuser

📊 USER-INFORMATIONEN:
========================
👤 ID: 5
📧 E-Mail: test@example.com
🏷️ Username: testuser
🔒 Gesperrt: Nein
❌ Fehlversuche: 0

🔗 ABHÄNGIGE DATEN:
===================
👑 Rollen: 2
🔑 Sessions: 1
🎮 Welt-Mitgliedschaften: 3
📝 Vorregistrierungen: 1
🔐 Password-Resets: 0
📬 Versendete Invites: 2

🌍 Mitglied in Welten:
   • Welt_open (seit 29.7.2025)
   • Welt_upcoming (seit 28.7.2025)

📨 Versendete Invites:
   • Welt_open → holger@otto.de (29.7.2025)

🗑️ LÖSCHVORGANG:
=================
📋 Löschplan:
   1. Rollen-Zuweisungen löschen: 2 Einträge
   2. Aktive Sessions löschen: 1 Einträge  
   3. Welt-Mitgliedschaften löschen: 3 Einträge
   4. Vorregistrierungen löschen: 1 Einträge
   5. Invite-Referenzen auf NULL setzen: 2 Einträge
   6. User-Account löschen: 1 Einträge

📊 Gesamt: 10 Operationen

⚠️ WARNUNG: Diese Aktion ist IRREVERSIBEL!
Möchten Sie fortfahren? Geben Sie "DELETE" ein:
```

## 🔧 Technische Details

### Lösch-Reihenfolge
Das Skript löscht in der korrekten Reihenfolge um Foreign Key Constraints zu beachten:

1. **UserRole** - Rollen-Zuweisungen
2. **Session** - Aktive Sessions  
3. **Player** - Welt-Mitgliedschaften
4. **PreRegistration** - Vorregistrierungen
5. **PasswordReset** - Password-Reset-Tokens
6. **Invite.invitedById** - Auf NULL setzen (Invites bleiben erhalten)
7. **User** - User-Account selbst

### Transaktionale Sicherheit
- Alle Löschungen erfolgen in einer **Prisma-Transaktion**
- Bei Fehlern wird **alles zurückgerollt**
- **Atomare Operation** - entweder alles oder nichts

### Error Handling
- Validates User-Existenz vor Löschung
- Graceful Shutdown bei CTRL+C
- Ausführliche Fehlerberichterstattung

## 🚨 Produktions-Hinweise

1. **Backup erstellen** vor Verwendung
2. **Dry Run** zuerst ausführen  
3. **Nur in Notfällen** verwenden
4. **Admin-Rechte** erforderlich
5. **Logs prüfen** nach Ausführung

## 🤝 Support

Bei Problemen:
- Logs in `../logs/` prüfen
- Prisma Studio für DB-Status
- Backup aus letzter Nacht wiederherstellen