# 📚 Weltenwind Dokumentation

**Willkommen zur umfassenden Weltenwind-Dokumentation!** Hier findest du alles, was du über das Weltenwind-System wissen musst - von der ersten Installation bis zur Production-Deployment.

---

## 🎯 **Quick Navigation**

### **👨‍💻 Für Entwickler**
- 🚀 **[Quick Start Guide](guides/quick-start.md)** - In 5 Minuten startklar
- 🏗️ **[Frontend-Architektur](frontend/README.md)** - Flutter Client Deep-Dive
- ⚡ **[Backend-Architektur](backend/README.md)** - Node.js Server Deep-Dive
- 🔌 **[API-Referenz](api/README.md)** - Vollständige REST API Dokumentation

### **🖥️ Für Administratoren**
- 🚀 **[Deployment Guide](guides/deployment-guide.md)** - Production Setup
- 🔐 **[Security Guide](backend/authentication.md)** - Sicherheits-Best-Practices
- 📊 **[Monitoring](development/monitoring.md)** - System-Überwachung
- 💾 **[Datenbank-Schema](database/schema.md)** - DB-Struktur & Migrations

### **🎮 Für Benutzer**
- 📖 **[User Guide](guides/user-guide.md)** - Spieler-Handbuch
- 📨 **[Invite-System](api/invites.md)** - Freunde einladen
- 🌍 **[Welt-Management](api/worlds.md)** - Welten erstellen & verwalten
- 🎨 **[Personalisierung](guides/customization.md)** - Themes & Settings

---

## 📂 **Dokumentations-Struktur**

```
docs/
├── 📄 PROJECT_OVERVIEW.md       # 🎯 Projekt-Vision & Übersicht
├── 📄 README.md                 # 📚 Diese Datei - Dokumentations-Index
│
├── 📁 frontend/                 # 📱 Flutter Client Dokumentation
│   ├── README.md                # Frontend-Architektur & Übersicht
│   ├── theming-system.md        # Theme & Design System
│   ├── navigation.md            # Smart Navigation System
│   ├── internationalization.md  # i18n & Localization
│   └── deployment.md            # Build & Deployment
│
├── 📁 backend/                  # ⚡ Node.js Backend Dokumentation
│   ├── README.md                # Backend-Architektur & Übersicht
│   ├── security/                # 🔐 Security & Authentication
│   │   ├── api-security.md      # API-Sicherheitsmaßnahmen
│   │   ├── jwt-security.md      # JWT Token Management
│   │   ├── password-policy.md   # Password-Policies & Validation
│   │   ├── security-headers.md  # Helmet.js & CSP Configuration
│   │   └── session-rotation.md  # Session-Management & Security
│   ├── infrastructure/          # 🏗️ System & Infrastructure
│   │   ├── logging-implementation.md # Winston-Logging-System
│   │   ├── session-config.md    # Session-Management-Config
│   │   └── error-handling-patterns.md # Error-Handling-Strategies
│   └── operations/              # ⚡ Development & Operations
│       ├── development-troubleshooting.md # Dev-Setup-Probleme
│       └── production-updates.md # Production-Deployment
│
├── 📁 api/                      # 🔌 REST API Dokumentation
│   ├── README.md                # API-Übersicht & Standards
│   ├── auth.md                  # Authentication & User Management
│   ├── worlds.md                # World Management API
│   ├── invites.md               # Invite System API (✨ Neu überarbeitet!)
│   ├── themes.md                # Theme System API
│   └── errors.md                # Error Handling & Codes
│
├── 📁 guides/                   # 📋 Praktische Anleitungen
│   ├── quick-start.md           # 🚀 5-Minuten-Setup für alle
│   ├── development-setup.md     # Development Environment
│   ├── deployment-guide.md      # Production Deployment
│   ├── user-guide.md            # End-User Manual
│   └── contribution-guide.md    # Contribution Guidelines
│
├── 📁 architecture/             # 🏗️ System-Architektur
│   ├── overview.md              # System-Übersicht & Design-Prinzipien
│   ├── security.md              # Security Konzept & Best Practices
│   ├── scaling-strategy.md      # Multiplayer Scaling (Future)
│   └── future-roadmap.md        # Vision & Roadmap
│
├── 📁 database/                 # 💾 Datenbank-Dokumentation
│   ├── schema.md                # DB-Schema & Models
│   ├── migrations.md            # Migration Management
│   └── seeds.md                 # Seed-Daten & Test-Users
│
└── 📁 development/              # 🔧 Development & Operations
    ├── setup.md                 # Development Environment
    ├── testing.md               # Testing Strategies
    ├── monitoring.md            # Logging & Analytics
    └── debugging.md             # Debugging & Troubleshooting
```

---

## 🌟 **Was ist neu? (Januar 2025)**

### **✨ Invite System Überarbeitung**
- **Neue Landing Page UX**: Emotionale, informative Einladungs-Erfahrung
- **World Preview Cards**: Welt-Informationen vor Beitritt  
- **Session Management Fix**: Robuste Auth-Handling
- **Vollständige API-Dokumentation**: [Invite System Guide](api/invites.md)

### **🎨 Theme System Enhancement**
- **World-spezifische Themes**: Visuelle Identität pro Welt
- **Race-Condition-Safe**: Sauberes Theme-Loading
- **Bundle-System**: Optimiert für verschiedene Geräte
- **AppScaffold Integration**: Einheitliche Theme-Anwendung

### **📱 Frontend Architecture**
- **Flutter 3.x Migration**: Moderne Cross-Platform-Architektur
- **Smart Navigation**: Intelligente, kontextuale Navigation
- **Service Locator Pattern**: Saubere Dependency Injection
- **Multi-Language**: Vollständige DE/EN Internationalisierung

### **⚡ Backend Infrastructure**
- **Enterprise Security**: JWT-Rotation, OWASP-compliance, Rate-Limiting
- **Professional Logging**: Winston-basiert mit Web-UI-Monitoring
- **Documentation Migration**: Technische Docs zentral organisiert
- **Admin-Tools**: Unified `/tools/` Architecture für ARB-Editor, Theme-Editor, Log-Viewer

---

## 🚀 **Schnellstart-Optionen**

### **Option 1: Komplette lokale Entwicklung**
```bash
git clone https://github.com/dasBoooot/weltenwind.git
cd weltenwind
```
➡️ **[Vollständige Anleitung](guides/quick-start.md#für-entwickler)**

### **Option 2: Nur Frontend testen**
```bash
cd client
flutter run -d chrome
```
➡️ **[Frontend-Setup](frontend/README.md#development)**

### **Option 3: API erkunden**
```bash
cd backend
npm run dev
# Öffne: http://localhost:3000/api/docs
```
➡️ **[API-Dokumentation](api/README.md)**

---

## 🎯 **Wichtige Features**

| Feature | Status | Dokumentation |
|---------|--------|---------------|
| **🔐 Authentication System** | ✅ Production Ready | [auth.md](api/auth.md) |
| **🌍 Multi-World Management** | ✅ Production Ready | [worlds.md](api/worlds.md) |
| **📨 Invite System** | ✅ Neu überarbeitet | [invites.md](api/invites.md) |
| **🎨 Dynamic Theme System** | ✅ Production Ready | [theming-system.md](frontend/theming-system.md) |
| **📱 Cross-Platform Client** | ✅ Web/iOS/Android | [frontend/README.md](frontend/README.md) |
| **🌐 Internationalization** | ✅ DE/EN Support | [i18n.md](frontend/internationalization.md) |
| **⚡ Enterprise Security** | ✅ Production Ready | [security/](backend/security/) |
| **📊 Professional Logging** | ✅ Production Ready | [logging-implementation.md](backend/infrastructure/logging-implementation.md) |
| **🛠️ Admin Tools Suite** | ✅ Production Ready | [tools/README.md](../backend/tools/README.md) |
| **🔄 Real-time Gaming** | 📋 Planned | [scaling-strategy.md](architecture/scaling-strategy.md) |

---

## 🤝 **Community & Support**

### **Getting Help**
- 📖 **Dokumentation durchsuchen**: Nutze die Navigation oben
- 🐛 **Bug Report**: [GitHub Issues](https://github.com/dasBoooot/weltenwind/issues)
- 💡 **Feature Request**: [GitHub Discussions](https://github.com/dasBoooot/weltenwind/discussions)
- 📧 **Direkter Kontakt**: Siehe [Contribution Guide](guides/contribution-guide.md)

### **Contributing**
- 🔄 **Pull Requests**: Willkommen für alle Verbesserungen
- 📝 **Dokumentation**: Hilf beim Erweitern der Docs
- 🐛 **Testing**: Teste neue Features und melde Bugs
- 🌍 **Translations**: Hilf bei weiteren Sprach-Unterstützungen

---

## 📊 **Projekt-Status**

**Weltenwind** ist ein aktiv entwickeltes, Open-Source-Projekt:

- **🔥 Aktive Entwicklung**: Regelmäßige Updates & Features
- **🚀 Production Ready**: Core-Features stabil und getestet
- **📱 Cross-Platform**: Web, iOS, Android Support
- **🌍 International**: Multi-Language von Grund auf
- **🔐 Enterprise-Grade**: Sicherheit & Skalierbarkeit im Fokus

---

**Projekt-Version**: 1.0.0  
**Dokumentation**: Januar 2025  
**Repository**: [github.com/dasBoooot/weltenwind](https://github.com/dasBoooot/weltenwind)  
**Status**: 🚀 Aktive Entwicklung 