# 📱 Weltenwind Frontend (Flutter)

**Das Weltenwind Frontend** ist eine moderne Flutter-Anwendung, die als **Cross-Platform Client** für Web, iOS und Android fungiert. Es bietet eine nahtlose, responsive Gaming-Erfahrung mit dynamischen Themes und intelligenter Navigation.

---

## 🏗️ **Architektur-Übersicht**

### **Design-Prinzipien**
- **Cross-Platform First**: Ein Codebase für Web, iOS, Android
- **Material 3 Design**: Moderne, barrierefreie UI-Komponenten
- **Service-Oriented**: Klare Trennung von UI und Business Logic
- **Theme-Driven**: Dynamische visuelle Anpassung pro Welt
- **Internationalization-Ready**: Multi-Language von Grund auf

### **Technologie-Stack**
```yaml
Framework: Flutter 3.x
Language: Dart 3.x
State Management: Provider Pattern + Service Locator
Navigation: GoRouter mit Smart Navigation
UI Design: Material 3 + Custom Components
Build Tool: Flutter Web, iOS, Android builds
```

---

## 📂 **Projekt-Struktur**

```
client/lib/
├── main.dart                    # App Entry Point + Service Locator
├── app.dart                     # Material App + Global Configuration
│
├── config/                      # Konfiguration & Environment
│   ├── env.dart                 # Environment Variables
│   └── logger.dart              # Logging Configuration
│
├── core/                        # Core Services & Providers
│   ├── services/                # Business Logic Services
│   │   ├── api_service.dart     # HTTP API Client
│   │   ├── auth_service.dart    # Authentication Service
│   │   ├── world_service.dart   # World Management
│   │   └── invite_service.dart  # Invite System
│   └── providers/               # State Management
│       ├── locale_provider.dart # Language Switching
│       └── theme_provider.dart  # Global Theme State
│
├── features/                    # Feature-based UI Organization
│   ├── auth/                    # Authentication Pages
│   │   ├── login_page.dart
│   │   ├── register_page.dart
│   │   └── password_reset_page.dart
│   ├── world/                   # World Management
│   │   ├── world_list_page.dart
│   │   ├── world_join_page.dart
│   │   └── world_details_page.dart
│   ├── invite/                  # Invite System
│   │   └── invite_landing_page.dart
│   ├── dashboard/               # Gaming Dashboard
│   │   └── dashboard_page.dart
│   └── landing/                 # Marketing Landing
│       └── landing_page.dart
│
├── shared/                      # Wiederverwendbare Komponenten
│   ├── components/              # UI Components
│   │   ├── app_scaffold.dart    # Main Layout + Theme Integration
│   │   ├── app_dropdown.dart    # Styled Dropdown
│   │   └── world_preview_card.dart
│   ├── widgets/                 # Small Widgets
│   │   ├── language_switcher.dart
│   │   └── splash_screen.dart
│   └── navigation/              # Navigation System
│       ├── smart_navigation.dart # Intelligent Routing
│       └── page_preloaders.dart  # Page Preloading
│
├── theme/                       # Theme & Design System
│   └── background_widget.dart   # Dynamic Background System
│
├── routing/                     # Navigation Configuration
│   ├── app_router.dart          # GoRouter Configuration
│   └── initial_theme_detector.dart
│
└── l10n/                        # Internationalization
    ├── app_localizations.dart   # Generated Localizations
    ├── app_en.arb               # English Strings
    ├── app_de.arb               # German Strings
    └── app_localizations_*.dart # Generated Language Files
```

---

## 🎨 **Theme-System**

### **AppScaffold - Das Herzstück**
```dart
AppScaffold(
  themeContextId: 'world-dashboard',    // Theme Context
  themeBundleId: 'full-gaming',         // Theme Bundle  
  worldThemeOverride: 'medieval',       // World-specific Theme
  componentName: 'DashboardPage',       // Debugging
  body: YourPageContent(),
)
```

### **Theme-Hierarchie**
1. **Global Theme**: Basis Material 3 Theme
2. **Bundle Theme**: Gaming-optimierte Anpassungen  
3. **World Theme**: Welt-spezifische visuelle Identität
4. **Component Theme**: Komponenten-spezifische Overrides

### **Theme-Bundles**
- `full-gaming`: Vollständige Gaming-Experience
- `mobile-optimized`: Für schwächere Geräte
- `accessibility`: Barrierefreiheit-optimiert

---

## 🧭 **Smart Navigation System**

### **Context-Aware Routing**
```dart
// Intelligente Navigation basierend auf User-State
await context.smartGoNamed('world-dashboard', 
  params: {'worldId': '123'},
  extra: {'transition': 'fade'}
);

// Automatische Umleitung basierend auf Auth-Status
await context.smartGo('/dashboard'); // Redirects wenn nicht angemeldet
```

### **Navigation-Contexts**
- `landing`: Öffentliche Marketing-Seiten
- `auth`: Login/Register-Flow
- `dashboard`: Authentifizierte Hauptnavigation
- `world`: World-spezifische Navigation
- `invite`: Invite-Landing-Pages

---

## 🌍 **Internationalization (i18n)**

### **Unterstützte Sprachen**
- **Deutsch (DE)**: Primäre Sprache
- **Englisch (EN)**: Sekundäre Sprache
- **Erweiterbar**: ARB-basiertes System

### **Usage in Code**
```dart
final l10n = AppLocalizations.of(context);

Text(l10n.buttonLogin),                    // Einfacher Text
Text(l10n.welcomeMessage(userName)),       // Mit Parametern  
Text(l10n.itemCount(count)),               // Mit Pluralisierung
```

### **ARB-File-Struktur**
```json
{
  "buttonLogin": "Anmelden",
  "@buttonLogin": {
    "description": "Login button text",
    "context": "auth"
  },
  "welcomeMessage": "Willkommen, {userName}!",
  "@welcomeMessage": {
    "description": "Welcome message with username",
    "placeholders": {
      "userName": {"type": "String"}
    }
  }
}
```

---

## 🔧 **Service-Architecture**

### **Service Locator Pattern**
```dart
// Service Registration (main.dart)
ServiceLocator.register<ApiService>(ApiService());
ServiceLocator.register<AuthService>(AuthService());

// Service Usage
final authService = ServiceLocator.get<AuthService>();
final isAuthenticated = await authService.isLoggedIn();
```

### **Core Services**

#### **ApiService**
- HTTP Client für Backend-Kommunikation
- Automatic JWT Token Handling
- Request/Response Interceptors
- Error Handling & Retry Logic

#### **AuthService**  
- User Authentication Management
- JWT Token Storage & Refresh
- Login State Management
- Automatic Session Cleanup

#### **WorldService**
- World Data Management
- World-specific Theme Loading
- Player Status Management
- World State Caching

---

## 📦 **Build & Deployment**

### **Development**
```bash
# Development Server starten
flutter run -d chrome --web-port 8080

# Hot Reload aktiviert für schnelle Entwicklung
# Debug-Build mit allen Entwickler-Tools
```

### **Production Build**
```bash
# Web Build für Production
flutter build web --base-href /game/

# Build-Output: build/web/
# Optimiert für Web-Deployment
```

### **Platform-specific Builds**
```bash
# iOS Build (nur auf macOS)
flutter build ios --release

# Android Build
flutter build apk --release
flutter build appbundle --release
```

---

## 🐛 **Debugging & Development**

### **Logging-System**
```dart
AppLogger.app.i('Info message');          // Info
AppLogger.app.w('Warning message');       // Warning  
AppLogger.app.e('Error message');         // Error
AppLogger.app.d('Debug message');         // Debug (nur in Development)
```

### **Debug-Features**
- **Hot Reload**: Sofortige Code-Änderungen
- **Flutter Inspector**: UI-Tree Debugging
- **Network Inspector**: API-Call Monitoring
- **Theme Inspector**: Theme-Debugging-Tools

### **Performance Monitoring**
- **Build-Time Tracking**: Page-Load-Performance
- **Theme-Load-Performance**: Theme-Switch-Zeiten
- **Navigation-Performance**: Route-Change-Tracking

---

## 🔐 **Security & Best Practices**

### **Authentication Security**
- JWT Tokens in Secure Storage
- Automatic Token Refresh
- Session Timeout Handling
- CSRF Protection

### **Input Validation**
- Client-side Validation für UX
- Server-side Validation für Security
- Sanitization von User Input
- XSS Prevention

### **Error Handling**
```dart
try {
  final result = await apiService.getData();
  // Handle success
} catch (e) {
  AppLogger.app.e('API Error: $e');
  // Show user-friendly error message
  if (mounted) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(l10n.errorNetwork))
    );
  }
}
```

---

## 📈 **Performance Optimizations**

### **Image & Asset Management**
- Compressed Image Assets
- Lazy Loading für große Listen
- Cached Network Images
- Platform-optimized Asset Bundles

### **State Management Optimizations**
- Minimal Rebuilds durch gezielten Provider Usage
- Efficient List Updates mit Keys
- Memory-efficient Caching Strategies

### **Bundle Size Optimization**
- Tree Shaking für ungenutzte Code-Elimination
- Optimized Font Loading
- Conditional Feature Loading

---

**Erstellt**: Januar 2025  
**Maintainer**: Weltenwind Development Team  
**Status**: 📱 Production Ready