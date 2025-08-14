# 🌍 Weltenwind - Projekt Übersicht

**Weltenwind** ist eine moderne, browser-basierte Fantasy-Engine für das Management multipler interaktiver Welten. Das System ist darauf ausgelegt, sowohl Spieler als auch Ersteller zu befähigen, dynamische Realms zu erkunden, zu gestalten und zu erobern — alles von einer skalierbaren Plattform aus.

---

## 🎯 **Vision & Mission**

### **Vision**
*"Ein Universum unendlicher Welten, in dem jeder Spieler zum Helden seiner eigenen Geschichte wird."*

### **Mission**
- **Für Spieler**: Nahtlose, immersive Gaming-Erfahrung über Welten-Grenzen hinweg
- **Für Ersteller**: Mächtige, aber einfache Tools zur Welt-Erschaffung
- **Für Communities**: Soziale Features, die Gemeinschaften stärken

---

## 🏗️ **System-Architektur**

### **Technology Stack**

#### **Backend** 🚀
- **Runtime**: Node.js 18+ mit TypeScript
- **Framework**: Express.js mit modularem Routing
- **Datenbank**: PostgreSQL 14+ mit Prisma ORM
- **Authentifizierung**: JWT + Session-basiert
- **API-Design**: RESTful mit OpenAPI/Swagger-Dokumentation

#### **Frontend** 📱
- **Framework**: Flutter 3.x (Cross-Platform)
- **Plattformen**: Web, iOS, Android
- **UI-Design**: Material 3 mit Custom Theme System
- **State Management**: Provider Pattern + Service Locator
- **Navigation**: GoRouter mit Smart Navigation System
- **Internationalisierung**: ARB-basiert (DE/EN)

#### **Infrastructure** 🛠️
- **Hosting**: Flexibel (VM, Docker, Cloud)
- **Development**: Hot Reload, Development Server
- **Logging**: Strukturiertes Logging (Backend + Frontend)
- **Build**: Flutter Web mit optimierter Bundle-Strategie

---

## 🎮 **Kern-Features**

### **1. Multi-World Management**
- **Welt-Lifecycle**: `upcoming → open → running → closed → archived`
- **Welt-Typen**: Verschiedene Genres und Spielstile
- **Theme-System**: Visuelle Anpassung pro Welt
- **Player-Management**: Dynamisches Beitreten/Verlassen

### **2. Invite-System**
- **Token-basiert**: Sichere, zeitlich begrenzte Einladungen
- **Email-Integration**: Personalisierte Einladungs-Erfahrung
- **Smart Onboarding**: Automatisches Account-Setup
- **Social Preview**: Welt-Informationen vor Beitritt

### **3. Theme & Branding System**
- **Dynamic Themes**: Welt-spezifische visuelle Identität
- **Bundle-System**: Optimiert für verschiedene Geräte-Klassen
- **Race-Condition-Safe**: Sauberes Theme-Loading
- **Fallback-Strategy**: Graceful Degradation bei Theme-Fehlern

### **4. Benutzer-Experience**
- **Progressive Web App**: App-ähnliche Erfahrung im Browser
- **Responsive Design**: Optimiert für alle Bildschirmgrößen
- **Smart Navigation**: Kontextuelle Navigation mit History-Management
- **Multi-Language**: Vollständige Internationalisierung

### **5. Sicherheit & Performance**
- **RBAC**: Role-Based Access Control mit Scopes
- **Session-Management**: Sichere, skalierbare User-Sessions
- **Input-Validation**: Comprehensive API + Client-side Validation
- **Error-Handling**: Graceful Error Recovery + User Feedback
- **Dynamic Configuration**: Runtime URL-Konfiguration für Skalierung
- **Asset Optimization**: nginx-basiertes Asset-Serving mit Caching

---

## 📊 **Projekt-Status (Stand: Januar 2025)**

### **✅ Vollständig Implementiert**
- ✅ Backend API (Auth, Worlds, Invites, Themes)
- ✅ Frontend Core (Navigation, Theming, i18n)
- ✅ Benutzer-Authentication & Sessions  
- ✅ Welt-Management & Listings
- ✅ Invite-System mit verbesserter UX
- ✅ Theme-System mit World-spezifischen Designs
- ✅ Multi-Language Support (DE/EN)
- ✅ OpenAPI/Swagger Dokumentation
- ✅ **Dynamic Configuration System** (Skalierbare URL-Konfiguration)
- ✅ **Remote Asset Management** (nginx-basiertes Asset-Serving)
- ✅ **Gradle 8.14.3** (Java 24 Support)

### **🔄 In Entwicklung**
- 🔄 Gaming-Features & Real-time Updates
- 🔄 Advanced Player-Interactions
- 🔄 Welt-Editor Tools
- 🔄 Mobile App Optimierungen

### **📋 Geplant**
- 📋 WebSocket Integration für Real-time Gaming
- 📋 Advanced Analytics & Reporting
- 📋 Plugin-System für Erweiterungen
- 📋 Community Features & Social Tools

---

## 📚 **Dokumentations-Struktur**

```
docs/
├── PROJECT_OVERVIEW.md          # Diese Datei - Projekt-Übersicht
├── README.md                    # Haupt-Dokumentations-Index
│
├── frontend/                    # Flutter Client Dokumentation
│   ├── README.md                # Frontend-Übersicht  
│   ├── THEME_SYSTEM.md          # Theme & Design System
│   └── DYNAMIC_CONFIGURATION.md # Runtime-Konfiguration
│
├── backend/                     # API & Backend Dokumentation 
│   ├── README.md                # Backend-Übersicht
│   ├── security/                # Security & Auth
│   ├── infrastructure/          # Infrastruktur & Ops
│   └── operations/              # Development & Deployment
│
├── api/                         # API-spezifische Docs
│   ├── README.md                # API-Übersicht
│   ├── auth.md                  # Authentication Endpoints
│   ├── worlds.md                # World Management API
│   ├── invites.md               # Invite System API
│   └── themes.md                # Theme System API
│
├── guides/                      # User & Developer Guides
│   ├── quick-start.md           # Schnellstart-Guide
│   ├── user-guide.md            # End-User Manual
│   └── contribution-guide.md    # Contribution Guidelines
│
└── architecture/                # System-Architektur
    ├── overview.md              # System-Overview (bereits vorhanden)  
    ├── security.md              # Security Konzept
    ├── scaling-strategy.md       # Skalierungs-Strategie
    └── future-roadmap.md        # Roadmap & Vision
```

---

## 🚀 **Quick Start**

### **Für Entwickler**
1. **Setup**: [Development Setup Guide](development/setup.md)
2. **API**: [API Reference](api/README.md)  
3. **Frontend**: [Frontend Architecture](frontend/README.md)

### **Für Administratoren**
1. **Deployment**: [Production Deployment](backend/operations/production-updates.md)
2. **Configuration**: [Backend Configuration](backend/infrastructure/environment-variables.md)
3. **Monitoring**: [Logging & Monitoring](backend/infrastructure/logging-implementation.md)

### **Für Benutzer**
1. **Worlds**: [World Management](api/worlds.md)
2. **Einladungen**: [Invite System](api/invites.md)

---

## 🤝 **Community & Support**

- **GitHub**: [https://github.com/dasBoooot/weltenwind](https://github.com/dasBoooot/weltenwind)
- **Entwicklung**: Aktive Feature-Entwicklung
- **Dokumentation**: Kontinuierliche Updates
- **Support**: Community-driven Support

---

**Erstellt**: Januar 2025  
**Version**: 1.0.0  
**Status**: 🚀 Aktive Entwicklung