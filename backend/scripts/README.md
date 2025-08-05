# 🛠️ Backend-Scripts - Weltenwind

**Organisierte Sammlung von Test-, Utility- und Maintenance-Scripts für das Weltenwind Backend**

---

## 📁 **Script-Kategorien Übersicht**

### **🧪 Testing** (`/testing/`) - 8 Scripts
**Test-Scripts für System-Validation und Feature-Testing**

| Script | Zweck | Beschreibung |
|--------|-------|--------------|
| `test-system-no-mail.js` | System-Test ohne Mail | Testet Backend ohne Mail-Server |
| `test-password-validation.js` | Password-Policy-Test | Validiert Password-Strength-Regeln |
| `test-production-headers.js` | Production-Headers-Test | Testet Security-Headers in Production |
| `test-security-headers.js` | Security-Headers-Test | Validiert Helmet.js-Konfiguration |
| `test-invite-permissions.js` | Invite-Permissions-Test | Testet Invite-System-Berechtigungen |
| `test-mail-config.js` | Mail-Konfiguration-Test | Testet Mail-Server-Konfiguration |
| `test-gmail-config.js` | Gmail-Konfiguration-Test | Testet Gmail-SMTP-Setup |
| `test-change-password.js` | Password-Change-Test | Testet Password-Change-Flow |

### **🧹 Maintenance** (`/maintenance/`) - 5 Scripts  
**Cleanup- und Wartungs-Scripts für System-Maintenance**

| Script | Zweck | Beschreibung |
|--------|-------|--------------|
| `cleanup-duplicate-sessions.js` | Session-Cleanup | Entfernt doppelte User-Sessions |
| `cleanup-sessions.js` | Session-Bereinigung | Bereinigt abgelaufene Sessions |
| `clear-all-sessions.js` | All-Sessions-Clear | Löscht ALLE Sessions (Emergency) |
| `fix-world-themes.js` | World-Theme-Fix | Repariert World-Theme-Zuordnungen |
| `fix-user-invite-permissions.js` | Invite-Permission-Fix | Repariert Invite-Berechtigungen |

### **⚙️ Setup** (`/setup/`) - 5 Scripts/Docs
**Initial-Setup und Konfigurations-Scripts**

| Script | Zweck | Beschreibung |
|--------|-------|--------------|
| `generate-jwt-secret.js` | JWT-Secret-Generator | Generiert sichere JWT-Secrets |
| `add-logs-permission.js` | Logs-Permission-Setup | Fügt `system.logs` Permission hinzu |
| `MAIL-SETUP.md` | Mail-Setup-Guide | Vollständige Mail-Server-Konfiguration |
| `SETUP.md` | General-Setup-Guide | Allgemeine Setup-Anleitung |
| `mail-config-template.env` | Mail-Config-Template | Template für Mail-Umgebungsvariablen |

### **💾 Database** (`/database/`) - 6 Scripts/SQL
**Datenbank-Operations und -Maintenance**

| Script | Zweck | Beschreibung |
|--------|-------|--------------|
| `delete-user.js` | User-Deletion | Sicheres Löschen von Benutzern |
| `USER-DELETE-README.md` | User-Delete-Guide | Dokumentation für User-Deletion |
| `check-db-direct.js` | Direct-DB-Check | Direkter DB-Zugriff für Debugging |
| `check-roles.js` | Role-Validation | Überprüft User-Rollen und Permissions |
| `theme-system-cleanup.sql` | Theme-DB-Cleanup | SQL für Theme-System-Bereinigung |
| `fix-theme-bundles.sql` | Theme-Bundle-Fix | SQL für Theme-Bundle-Reparatur |

### **🔧 Utilities** (`/utilities/`) - 6 Scripts
**General-Purpose Utility-Scripts**

| Script | Zweck | Beschreibung |
|--------|-------|--------------|
| `show-tokens-from-db.js` | Token-Inspector | Zeigt alle Tokens aus der DB |
| `check-worlds.js` | World-Validation | Überprüft World-Konfigurationen |
| `debug-startup.js` | Startup-Debugging | Debuggt Backend-Startup-Issues |
| `context-cleanup-verification.js` | Context-Cleanup-Check | Verifiziert Context-Cleanup |
| `theme-verification.js` | Theme-Validation | Verifiziert Theme-System-Integrität |
| `example-logging-integration.ts` | Logging-Example | Beispiel für Logging-Integration |

---

## 🚀 **Quick-Start für häufige Tasks**

### **🔧 Development Setup**:
```bash
# JWT-Secret generieren (first-time setup)
node backend/scripts/setup/generate-jwt-secret.js

# Logs-Permission hinzufügen (first-time setup)
node backend/scripts/setup/add-logs-permission.js

# Mail-Server testen
node backend/scripts/testing/test-mail-config.js
```

### **🧹 Maintenance Tasks**:
```bash
# Session-Cleanup (regelmäßig)
node backend/scripts/maintenance/cleanup-sessions.js

# World-Themes reparieren (bei Theme-Problemen)
node backend/scripts/maintenance/fix-world-themes.js

# Emergency: Alle Sessions löschen
node backend/scripts/maintenance/clear-all-sessions.js
```

### **🔍 Debugging & Inspection**:
```bash
# Token-Status anzeigen
node backend/scripts/utilities/show-tokens-from-db.js

# Worlds validieren
node backend/scripts/utilities/check-worlds.js

# Theme-System überprüfen
node backend/scripts/utilities/theme-verification.js
```

### **🧪 Testing vor Deployment**:
```bash
# System ohne Mail testen
node backend/scripts/testing/test-system-no-mail.js

# Security-Headers validieren
node backend/scripts/testing/test-security-headers.js

# Password-Policy testen
node backend/scripts/testing/test-password-validation.js
```

---

## 📊 **Script-Statistiken**

### **Kategorien-Verteilung**:
- **Testing**: 8 Scripts (30%) - Umfassende Test-Abdeckung
- **Utilities**: 6 Scripts (23%) - Vielseitige Debugging-Tools  
- **Database**: 6 Scripts (23%) - Robuste DB-Operations
- **Maintenance**: 5 Scripts (19%) - Effiziente System-Wartung
- **Setup**: 5 Scripts (19%) - Vollständige Setup-Unterstützung

### **Code-Umfang**:
- **Gesamt**: ~30 Scripts/Docs mit ~2,500 Zeilen Code
- **Größte Scripts**: `delete-user.js` (398 Zeilen), `example-logging-integration.ts` (233 Zeilen)
- **Dokumentation**: 3 README/Setup-Guides für komplexe Prozesse

---

## 🎯 **Best Practices für Script-Usage**

### **⚠️ Vor Production-Deployment**:
```bash
# 1. System-Tests durchführen
node backend/scripts/testing/test-production-headers.js
node backend/scripts/testing/test-security-headers.js

# 2. DB-Integrität prüfen
node backend/scripts/database/check-roles.js
node backend/scripts/utilities/theme-verification.js

# 3. Sessions bereinigen
node backend/scripts/maintenance/cleanup-sessions.js
```

### **🔧 Development Workflow**:
```bash
# 1. Setup (nur einmal)
node backend/scripts/setup/generate-jwt-secret.js
node backend/scripts/setup/add-logs-permission.js

# 2. Testing (bei Änderungen)
node backend/scripts/testing/test-password-validation.js
node backend/scripts/testing/test-invite-permissions.js

# 3. Debugging (bei Problemen)
node backend/scripts/utilities/debug-startup.js
node backend/scripts/utilities/show-tokens-from-db.js
```

### **🚨 Emergency Procedures**:
```bash
# Session-Probleme
node backend/scripts/maintenance/clear-all-sessions.js

# Theme-Probleme  
node backend/scripts/maintenance/fix-world-themes.js

# Permission-Probleme
node backend/scripts/maintenance/fix-user-invite-permissions.js
```

---

## 🔐 **Security-Hinweise**

### **⚠️ Sensitive Scripts**:
- **`delete-user.js`**: Löscht User permanent - VORSICHT!
- **`clear-all-sessions.js`**: Loggt ALLE User aus - nur im Notfall!
- **`generate-jwt-secret.js`**: Generiert kritische Security-Keys

### **🛡️ Production-Safety**:
- **Testing-Scripts**: Können sicher in Production laufen
- **Maintenance-Scripts**: Mit Bedacht verwenden - können User-Experience beeinträchtigen
- **Database-Scripts**: Immer erst in Development testen!

### **📊 Logging & Monitoring**:
- Alle Scripts verwenden **structured logging**
- **Execution-Logs** werden in `logs/` gespeichert
- **Critical Operations** werden auditiert

---

## 🔮 **Future Script-Development**

### **Geplante Erweiterungen**:
- **Performance-Testing**: Scripts für Load-Testing
- **Automated-Deployment**: CI/CD-Integration-Scripts
- **Health-Checks**: Comprehensive System-Health-Scripts
- **Data-Migration**: Scripts für Schema-Migrations

### **Script-Development-Guidelines**:
1. **Kategorie-Zuordnung**: Neue Scripts in passende Kategorie einordnen
2. **Naming-Convention**: `purpose-description.js` (kebab-case)
3. **Documentation**: Zweck und Usage im Script-Header dokumentieren
4. **Error-Handling**: Robuste Fehlerbehandlung implementieren
5. **Logging**: Structured Logging für alle Operations

---

## 📞 **Support & Troubleshooting**

### **Bei Script-Problemen**:
1. **Log-Files prüfen**: `logs/` Verzeichnis für Execution-Logs
2. **Permissions checken**: Script-Execution-Permissions
3. **DB-Connection**: Sicherstellen dass DB erreichbar ist
4. **Environment**: .env-Variablen korrekt konfiguriert

### **Script-Entwicklung & Contribution**:
- **Neue Scripts**: In passende Kategorie einordnen
- **Updates**: README entsprechend aktualisieren
- **Testing**: Neue Scripts erst in Development testen
- **Documentation**: Zweck und Usage dokumentieren

---

**Status**: 🚀 Production Ready  
**Total Scripts**: 30 Scripts organisiert in 5 Kategorien  
**Code Coverage**: ~2,500 Zeilen für Testing, Maintenance & Utilities  
**Last Updated**: Januar 2025 - Komplette Reorganisation aus Backend-Root