# 🌍 Weltenwind - Infinite Worlds, Infinite Possibilities

[![GitHub](https://img.shields.io/github/license/dasBoooot/weltenwind)](LICENSE)
[![Status](https://img.shields.io/badge/status-active%20development-green)](https://github.com/dasBoooot/weltenwind)
[![Platform](https://img.shields.io/badge/platform-web%20%7C%20ios%20%7C%20android-blue)](#)

**Weltenwind** ist eine moderne, browser-basierte Fantasy-Engine für das Management multipler interaktiver Welten. Built für Strategie, Roleplay und Custom Events - es empowers Spieler und Ersteller gleichermaßen, dynamische Realms zu erkunden, zu gestalten und zu erobern — alles von einer skalierbaren Plattform aus.

---

## ✨ **Highlights**

### 🎮 **Gaming Features**
- **Multi-World Platform**: Unbegrenzte, einzigartige Spielwelten
- **Cross-Platform**: Web, iOS, Android - ein Codebase
- **Real-time Ready**: WebSocket-Architektur für Live-Gaming (coming soon)
- **Theme-driven Design**: Jede Welt hat ihre eigene visuelle Identität

### 🔐 **Enterprise-Grade Security**
- **JWT + Session-basierte Auth**: Sichere, skalierbare Authentifizierung
- **RBAC Permission System**: Granulare Berechtigungssteuerung
- **Input Validation**: Comprehensive Client + Server-side Validation
- **Security-First Architecture**: Built mit Security im Fokus

### 🌍 **International & Accessible**
- **Multi-Language Support**: Deutsch & Englisch (erweiterbar)
- **Responsive Design**: Optimiert für alle Bildschirmgrößen
- **Material 3 Design**: Moderne, barrierefreie UI-Komponenten
- **Progressive Web App**: App-ähnliche Erfahrung im Browser

---

## 🚀 **Quick Start**

### **Schritt 1: Repository klonen**
```bash
git clone https://github.com/dasBoooot/weltenwind.git
cd weltenwind
```

### **Schritt 2: Backend starten**
```bash
cd backend
npm install
cp .env.example .env
# Editiere .env mit deinen Datenbank-Credentials
npx prisma migrate dev
npm run dev
```

### **Schritt 3: Frontend starten**
```bash
cd ../client  
flutter pub get
flutter gen-l10n
flutter run -d chrome --web-port 8080
```

### **Schritt 4: Loslegen! 🎉**
- **Frontend**: http://localhost:8080
- **API-Docs**: http://localhost:3000/api/docs
- **Erste Schritte**: Registriere einen Account und erkunde Welten!

**Detaillierte Anleitung**: 📖 **[Complete Setup Guide](docs/guides/quick-start.md)**

---

## 🏗️ **Tech Stack**

### **Backend**
- **Runtime**: Node.js 18+ mit TypeScript
- **Framework**: Express.js mit modularem Routing
- **Database**: PostgreSQL 14+ mit Prisma ORM
- **Auth**: JWT + Session-Management
- **API**: RESTful mit OpenAPI/Swagger

### **Frontend**  
- **Framework**: Flutter 3.x (Dart)
- **Platforms**: Web, iOS, Android
- **UI**: Material 3 + Custom Theme System
- **State**: Provider Pattern + Service Locator
- **Navigation**: GoRouter mit Smart Navigation
- **i18n**: ARB-based (DE/EN)

---

## 📱 **Screenshots**

<div align="center">
  <table>
    <tr>
      <td align="center">
        <img src="docs/images/landing-page.png" alt="Landing Page" width="300"/>
        <br><b>🏠 Landing Page</b>
      </td>
      <td align="center">
        <img src="docs/images/world-list.png" alt="World List" width="300"/>
        <br><b>🌍 World List</b>
      </td>
    </tr>
    <tr>
      <td align="center">
        <img src="docs/images/invite-page.png" alt="Invite Landing" width="300"/>
        <br><b>📨 Invite Landing</b>
      </td>
      <td align="center">
        <img src="docs/images/dashboard.png" alt="Dashboard" width="300"/>
        <br><b>🎮 Gaming Dashboard</b>
      </td>
    </tr>
  </table>
</div>

*Screenshots zeigen das moderne Material 3 Design mit world-spezifischen Themes*

---

## 🎯 **Core Features**

| Feature | Status | Description |
|---------|--------|-------------|
| 🔐 **Authentication** | ✅ Ready | JWT + Session-based user management |
| 🌍 **Multi-World System** | ✅ Ready | Create, join, manage multiple game worlds |
| 📨 **Invite System** | ✅ Enhanced | Token-based invitations with rich landing pages |
| 🎨 **Dynamic Themes** | ✅ Ready | World-specific visual themes and branding |
| 📱 **Cross-Platform** | ✅ Ready | Web, iOS, Android from single codebase |
| 🌐 **Internationalization** | ✅ Ready | German & English support, easily extensible |
| 📊 **Monitoring & Metrics** | ✅ Ready | Real-time performance monitoring with web dashboard |
| 🗄️ **Intelligent Backup** | ✅ Ready | Auto-discovery backup system with recovery tools |
| 🔍 **Query Performance** | ✅ Ready | Database optimization with slow-query detection |
| 🔄 **Real-time Gaming** | 📋 Planned | WebSocket integration for live multiplayer |
| 🎮 **Advanced Gaming** | 📋 Planned | Rich game mechanics and interactions |

---

## 📚 **Documentation**

### **Quick Links**
- 📖 **[Complete Documentation](docs/README.md)** - Comprehensive guide
- 🚀 **[Quick Start Guide](docs/guides/quick-start.md)** - Get started in 5 minutes
- 🔌 **[API Reference](docs/api/README.md)** - Complete REST API docs
- 🏗️ **[Architecture Overview](docs/architecture/overview.md)** - System design

### **For Developers**
- 📱 **[Frontend Architecture](docs/frontend/README.md)** - Flutter client deep-dive
- 🎨 **[Theme System](docs/frontend/theming-system.md)** - Dynamic theming guide
- 🧭 **[Smart Navigation](docs/frontend/navigation.md)** - Routing system
- 🌍 **[Internationalization](docs/frontend/internationalization.md)** - i18n setup

### **For Administrators**
- 🚀 **[Deployment Guide](docs/guides/deployment-guide.md)** - Production setup
- 🔐 **[Security Guide](docs/backend/authentication.md)** - Security best practices
- 💾 **[Database Schema](docs/database/schema.md)** - DB structure & migrations

### **🔧 Admin Web Tools**
- 📊 **[Metrics Viewer](https://your-domain/metrics-viewer)** - Real-time performance monitoring
- 🗄️ **[Backup Manager](https://your-domain/backup-manager)** - Intelligent backup management
- 🎨 **[Theme Editor](https://your-domain/theme-editor)** - Visual theme customization
- 🔍 **[Log Viewer](https://your-domain/log-viewer)** - System log monitoring

---

## 🤝 **Contributing**

We welcome contributions from developers of all skill levels!

### **How to Contribute**
1. **Fork** the repository
2. **Create** a feature branch (`git checkout -b feature/amazing-feature`)
3. **Commit** your changes (`git commit -m 'Add amazing feature'`)
4. **Push** to the branch (`git push origin feature/amazing-feature`)
5. **Open** a Pull Request

### **Areas for Contribution**
- 🐛 **Bug Fixes**: Help us squash bugs
- ✨ **New Features**: Implement cool new functionality
- 📝 **Documentation**: Improve or translate docs
- 🎨 **UI/UX**: Enhance the user experience
- 🌍 **i18n**: Add support for more languages
- 🧪 **Testing**: Improve test coverage

**Contribution Guide**: 📋 **[Contributing Guidelines](docs/guides/contribution-guide.md)**

---

## 🏃‍♂️ **Development Status**

**Current Phase**: 🚀 **Active Development** 

### **Recently Completed (Januar 2025)**
- ✅ **Major Invite System Overhaul** - Rich landing pages with world previews
- ✅ **Theme System Enhancement** - World-specific visual identities  
- ✅ **Frontend Architecture Migration** - Modern Flutter 3.x structure
- ✅ **Complete API Documentation** - Comprehensive REST API guides
- ✅ **Cross-Platform Stability** - Reliable Web/iOS/Android support

### **Up Next**
- 🔄 **WebSocket Integration** - Real-time multiplayer foundation
- 🎮 **Advanced Gaming Features** - Rich game mechanics
- 📊 **Analytics & Monitoring** - Performance and usage insights
- 🎨 **Visual Enhancements** - More themes and customization options

---

## 📊 **Project Stats**

<div align="center">
  <table>
    <tr>
      <td align="center"><b>Languages</b><br>TypeScript, Dart</td>
      <td align="center"><b>Frameworks</b><br>Flutter, Express.js</td>
      <td align="center"><b>Database</b><br>PostgreSQL + Prisma</td>
    </tr>
    <tr>
      <td align="center"><b>Platforms</b><br>Web, iOS, Android</td>
      <td align="center"><b>Architecture</b><br>REST API + Cross-Platform Client</td>
      <td align="center"><b>Languages</b><br>German, English</td>
    </tr>
  </table>
</div>

---

## 📄 **License**

This project is licensed under the **BSD 2-Clause License** - see the [LICENSE](LICENSE) file for details.

---

## 🙏 **Acknowledgments**

- **Flutter Team** - For the amazing cross-platform framework
- **Express.js Community** - For the robust web framework  
- **Prisma Team** - For the excellent database toolkit
- **Material Design** - For the beautiful design system
- **Open Source Community** - For inspiration and tools

---

## 📞 **Connect & Support**

<div align="center">
  
  **Ready to explore infinite worlds?**
  
  [![GitHub](https://img.shields.io/badge/GitHub-Repository-black?logo=github)](https://github.com/dasBoooot/weltenwind)
  [![Documentation](https://img.shields.io/badge/📚-Documentation-blue)](docs/README.md)
  [![API Docs](https://img.shields.io/badge/🔌-API%20Reference-green)](docs/api/README.md)
  
  **[⭐ Star this project](https://github.com/dasBoooot/weltenwind) if you like it!**
  
</div>

---

<div align="center">
  <i>🌍 Built with ❤️ for the gaming community</i><br>
  <i>Creating infinite worlds, one commit at a time</i>
</div>