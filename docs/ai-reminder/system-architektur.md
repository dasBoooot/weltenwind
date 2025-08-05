# 🏗️ System-Architektur - Weltenwind

**Wichtige Architektur-Prinzipien die wir immer befolgen**

---

## 🎨 **Theme-System Architektur**

### **✅ AppScaffold ist das Herzstück**

**AppScaffold integriert alle Theme-Systeme und ist der zentrale Layout-Container.**

```dart
// ✅ Korrekte Theme-Integration:
AppScaffold(
  themeContextId: 'world-dashboard',     // Theme Context
  themeBundleId: 'full-gaming',          // Theme Bundle  
  worldThemeOverride: 'medieval',        // World-specific Theme
  componentName: 'DashboardPage',        // Debugging
  appBar: AppBar(title: Text(l10n.title)), // AppBar als Parameter!
  body: YourPageContent(),
)

// ❌ NIEMALS AppBar manuell in body definieren!
// ❌ NIEMALS Theme-Loading im Widget-Body!
```

### **✅ Theme-Hierarchie beachten**

**Themes werden in dieser Reihenfolge angewendet:**

1. **Global Theme**: Basis Material 3 Theme
2. **Bundle Theme**: Gaming-optimierte Anpassungen  
3. **World Theme**: Welt-spezifische visuelle Identität
4. **Component Theme**: Komponenten-spezifische Overrides

### **✅ Conditional Theme Loading für Error States**

```dart
// ✅ Fehler-sicheres Theme Loading:
final worldTheme = (_error == null && _inviteData != null) 
  ? _getWorldTheme() 
  : null; // Default theme bei Fehlern

// ✅ Background Widget mit Error-Handling:
BackgroundWidget(
  waitForWorldTheme: _error == null, // Nicht auf Theme warten bei Fehlern
  child: YourContent(),
)
```

---

## 🧭 **Smart Navigation System**

### **✅ Context-Aware Routing verwenden**

**SmartNavigation ist intelligenter und robuster als normale Navigation.**

```dart
// ✅ Smart Navigation mit automatischem Preloading:
await context.smartGoNamed('world-dashboard', 
  params: {'worldId': '123'},
  extra: {'transition': 'fade'}
);

// ✅ Intelligente Umleitung basierend auf Auth-Status:
await context.smartGo('/dashboard'); // Redirects wenn nicht angemeldet

// ❌ NIEMALS direkte GoRouter Navigation in Weltenwind:
// context.go('/dashboard'); // Fehlt Preloading und Auth-Checks
```

### **✅ Navigation-Contexts befolgen**

**Verschiedene App-Bereiche haben eigene Navigation-Contexts:**

- `landing`: Öffentliche Marketing-Seiten
- `auth`: Login/Register-Flow  
- `dashboard`: Authentifizierte Hauptnavigation
- `world`: World-spezifische Navigation
- `invite`: Invite-Landing-Pages

### **✅ Session-Management bei Navigation**

**Bei Auth-relevanten Navigationen immer Session clearen:**

```dart
// ✅ Session-Management bei kritischen Navigationen:
final authService = ServiceLocator.get<AuthService>();
if (await authService.isLoggedIn()) {
  await authService.logout();
  await Future.delayed(const Duration(milliseconds: 100));
}
await context.smartGoNamed('register', extra: {...});
```

---

## 🛠️ **Service-Architecture Prinzipien**

### **✅ Service Locator Pattern**

**Dependency Injection über zentralen Service Locator.**

```dart
// ✅ Service Registration (main.dart):
ServiceLocator.register<ApiService>(ApiService());
ServiceLocator.register<AuthService>(AuthService());

// ✅ Service Usage überall:
final authService = ServiceLocator.get<AuthService>();
final isAuthenticated = await authService.isLoggedIn();
```

### **✅ Async Service Calls richtig verwenden**

**AuthService.isLoggedIn ist eine ASYNC FUNCTION, nicht ein Property!**

```dart
// ❌ FALSCH - authService.isLoggedIn ist kein Property:
if (authService.isLoggedIn) { /* ... */ }

// ✅ RICHTIG - authService.isLoggedIn() ist async function:
if (await authService.isLoggedIn()) { /* ... */ }
```

### **✅ Core Services korrekt strukturieren**

**Jeder Service hat klare Verantwortlichkeiten:**

- **ApiService**: HTTP Client für Backend-Kommunikation
- **AuthService**: User Authentication Management  
- **WorldService**: World Data Management
- **InviteService**: Invite System Management
- **ThemeService**: Theme Loading & Caching

---

## 🌍 **Internationalization (i18n) Architektur**

### **✅ ARB-File-Struktur befolgen**

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

### **✅ Sprach-Context immer verfügbar machen**

```dart
// ✅ AppLocalizations in allen Widgets verfügbar:
final l10n = AppLocalizations.of(context);
Text(l10n.buttonLogin)

// ✅ Parameter-unterstützte Übersetzungen:
Text(l10n.welcomeMessage(userName))
```

---

## 📡 **API-Architecture Prinzipien**

### **✅ REST API Standards befolgen**

**Konsistente Request/Response-Strukturen:**

```typescript
// ✅ Erfolgreiche Response:
{
  "success": true,
  "data": { /* response data */ },
  "message": "Operation successful"
}

// ✅ Fehler-Response:
{
  "success": false,
  "error": {
    "code": "ERROR_CODE",
    "message": "Human-readable error message",
    "details": "Additional error details"
  }
}
```

### **✅ Permission-basierte API-Security**

**RBAC (Role-Based Access Control) mit Scopes:**

- `global`: System-weite Berechtigungen
- `world`: Welt-spezifische Berechtigungen  
- `module`: Modul-spezifische Berechtigungen
- `player`: Spieler-spezifische Berechtigungen

### **✅ OpenAPI-Dokumentation synchronized halten**

**API-Implementierung und Swagger-Docs immer synchron:**

1. **Neue Endpunkte** → sofort in entsprechende `specs/*.yaml`
2. **Schema-Änderungen** → Request/Response-Schemas updaten
3. **Build & Test** → `generate-openapi.js` ausführen
4. **Verify** → Swagger UI testen

---

## 🗃️ **Database Architecture**

### **✅ Single Public Schema verwenden**

**User bevorzugt, default public schema in Prisma zu verwenden und Multi-Schema-Konfigurationen zu vermeiden.**

### **✅ Prisma-Schema und API synchronized**

**Datenbank-Schema und API-Endpunkte müssen immer zusammenpassen.**

- ✅ **Migration → Schema Update → API Update → Swagger Update**
- ✅ **Konsistente Feld-Namen** zwischen DB und API
- ✅ **Validation Rules** sowohl in DB als auch API

---

## 🔧 **Build & Deployment Architecture**

### **✅ Flutter Web Build-Konfiguration**

```bash
# ✅ Korrekter Web-Build-Befehl:
flutter build web --base-href /game/

# ✅ Build-Output-Location:
# build/web/ → für Web-Deployment optimiert
```

### **✅ Development vs Production**

**Verschiedene Konfigurationen für verschiedene Umgebungen:**

```dart
// ✅ Environment-based Configuration:
final apiBaseUrl = Env.isDevelopment 
  ? 'http://192.168.2.168:3000/api'  // Dev server IP
  : 'https://api.weltenwind.com/api'; // Production
```

### **✅ VM-basiertes Service Management**

**In diesem Projekt müssen Service-Restarts in der VM gemacht werden, da wir über einen Shared Folder mit Symlinks arbeiten.**

- ✅ **Service-Restarts in der VM**
- ❌ **Nicht in der Console** - funktioniert nicht wegen Symlinks

---

## 📊 **Performance Architecture**

### **✅ Efficient State Management**

- ✅ **Minimale Rebuilds** durch gezielten Provider Usage
- ✅ **Efficient List Updates** mit Keys
- ✅ **Memory-efficient Caching** Strategies

### **✅ Asset & Bundle Management**

- ✅ **Compressed Image Assets**
- ✅ **Lazy Loading** für große Listen
- ✅ **Platform-optimized Asset Bundles**
- ✅ **Tree Shaking** für unused Code elimination

---

**Letztes Update**: Januar 2025  
**Status**: 🏗️ Production-Ready Architecture - Diese Prinzipien sind bewährt und getestet!