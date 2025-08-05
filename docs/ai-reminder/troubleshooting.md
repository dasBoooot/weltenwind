# 🐛 Debugging & Troubleshooting - Weltenwind

**Systematischer Approach zur Problemlösung**

---

## 🔍 **Debugging-Workflow**

### **1. 📋 Problem systematisch analysieren**

**User erwartet, dass Bugs durch direktes Code-Lesen gefunden werden, NICHT durch Debugging-Logs.**

```
1. ✅ Symptom genau beschreiben
2. ✅ Betroffene Code-Bereiche identifizieren  
3. ✅ Code systematisch durchgehen
4. ✅ Logisch durchdenken was passieren könnte
5. ✅ Hypothese formulieren
6. ✅ Fix implementieren
7. ✅ Testen und verifizieren

❌ NICHT: "Kannst du mal Logs hinzufügen?"
❌ NICHT: Spekulieren oder raten
```

### **2. 🧹 Clean Code Debugging**

**User bevorzugt, dass kein Debug-Code eingefügt wird, der den Code "verschmutzt".**

```dart
// ❌ NIEMALS so debuggen:
print('Debug: user data = $userData');  // Verschmutzt Code
debugPrint('Entering function...');     // Temporary debugging

// ✅ IMMER so debuggen:
AppLogger.app.d('User authentication', {'userId': user.id}); // Structured
AppLogger.app.w('Potential issue detected', {'context': 'theme-loading'});
```

---

## 🚨 **Häufige Probleme & Systematische Lösungen**

### **1. 🎨 Theme-Loading Probleme**

#### **Symptom**: Default Flutter Theme wird verwendet statt Custom Theme

**Debugging-Workflow:**
```dart
// 1. ✅ Bundle-Name prüfen:
final bundleExists = await themeService.bundleExists('full-gaming');

// 2. ✅ World-Theme prüfen:  
final worldThemeExists = await themeService.themeExists('medieval');

// 3. ✅ AppScaffold korrekt implementiert:
AppScaffold(
  themeContextId: 'world-dashboard',  // ✅ Korrekt definiert?
  themeBundleId: 'full-gaming',       // ✅ Bundle existiert?
  worldThemeOverride: 'medieval',     // ✅ Theme existiert?
  // ...
)

// 4. ✅ Error State Handling:
final worldTheme = (_error == null && _inviteData != null) 
  ? _getWorldTheme() 
  : null; // Bei Fehlern = default theme
```

### **2. 🧭 Navigation Probleme**

#### **Symptom**: Navigation führt zu falschen Pages oder Auth-Fehlern

**Debugging-Workflow:**
```dart
// 1. ✅ Smart Navigation verwenden:
await context.smartGoNamed('dashboard'); // NICHT context.go()!

// 2. ✅ Auth-Status proofen:
final isLoggedIn = await authService.isLoggedIn(); // ASYNC!
if (!isLoggedIn) {
  await context.smartGoNamed('login');
  return;
}

// 3. ✅ Session-Management bei kritischen Navigationen:
if (await authService.isLoggedIn()) {
  await authService.logout();
  await Future.delayed(const Duration(milliseconds: 100));
}
```

### **3. 📱 UI-Text Probleme**

#### **Symptom**: Hardcoded Texte oder fehlende Übersetzungen

**Debugging-Workflow:**
```dart
// 1. ✅ AppLocalizations verfügbar prüfen:
final l10n = AppLocalizations.of(context);

// 2. ✅ ARB-Key existiert prüfen:
// In app_de.arb und app_en.arb nach Key suchen

// 3. ✅ Generated Code aktuell prüfen:
flutter gen-l10n
flutter clean  
flutter pub get

// 4. ✅ Korrekte Usage:
Text(l10n.buttonSave)  // ✅ RICHTIG
// Text('Speichern')   // ❌ NIEMALS!
```

### **4. 🔐 Authentication Probleme**

#### **Symptom**: Unerwartete Logouts oder Auth-Loops

**Debugging-Workflow:**
```dart
// 1. ✅ AuthService.isLoggedIn ist ASYNC:
final stillLoggedIn = await authService.isLoggedIn(); // NICHT ohne await!

// 2. ✅ Session-Status systematisch prüfen:
final currentUser = await authService.getCurrentUser();
final hasValidToken = await authService.hasValidToken();

// 3. ✅ Explicit Logout wenn nötig:
await authService.logout();
await Future.delayed(const Duration(milliseconds: 100)); // State settling
```

---

## ⚡ **Performance Debugging**

### **1. 🐌 Langsames Theme-Loading**

**Systematische Performance-Analyse:**

```dart
// 1. ✅ Theme-Cache prüfen:
final cacheHit = themeService.isThemeCached('medieval');

// 2. ✅ Bundle-Loading-Zeit messen:
final stopwatch = Stopwatch()..start();
final bundle = await themeService.loadBundle('full-gaming');
AppLogger.app.d('Bundle loading time: ${stopwatch.elapsedMilliseconds}ms');

// 3. ✅ Race Conditions vermeiden:
BackgroundWidget(
  waitForWorldTheme: _error == null, // Nicht warten bei Errors
  child: content,
)
```

### **2. 🔄 Widget Rebuild-Loops**

**Systematische Loop-Detection:**

```dart
// 1. ✅ setState-Calls minimieren:
// Nur bei tatsächlichen State-Änderungen

// 2. ✅ Provider-Lookups optimieren:
// Nicht in build() method, sondern als late final

// 3. ✅ ValueKey für Performance-kritische Widgets:
AppScaffold(
  key: ValueKey('invite-${worldTheme ?? 'default'}-${worldId}'),
  // ...
)
```

---

## 🛠️ **Debugging-Tools**

### **1. 📊 Flutter-spezifische Tools**

```bash
# ✅ Code-Qualität prüfen:
flutter analyze

# ✅ Performance-Profiling:
flutter run --profile

# ✅ Widget-Tree inspizieren:
# Flutter Inspector in VS Code/Android Studio

# ✅ Network-Calls debuggen:
# Network tab in Flutter Inspector
```

### **2. 🌐 Backend/API Debugging**

```bash
# ✅ API-Endpunkte direkt testen:
curl http://192.168.2.168:3000/api/auth/me -H "Authorization: Bearer TOKEN"

# ✅ Backend-Logs verfolgen:
# Logs sind verfügbar unter: C:\Users\Admin\Documents\Virtual Machines\Weltenwind\sharedFolder\logs

# ✅ Swagger-UI für API-Testing:
# http://192.168.2.168:3000/api/docs
```

### **3. 🎨 Theme-System Debugging**

```bash
# ✅ Bundle-Konfiguration prüfen:
Get-Content backend/theme-editor/bundles/bundle-configs.json

# ✅ Theme-Files prüfen:
Get-ChildItem backend/theme-editor/schemas/

# ✅ Combined OpenAPI nach Theme-Updates:
cd docs/openapi
node generate-openapi.js
```

---

## 🔬 **Systematische Fehler-Analyse**

### **1. 📝 Problem-Template**

**Für jedes Problem systematisch dokumentieren:**

```
🐛 PROBLEM:
- Symptom: [Was passiert?]
- Erwartung: [Was sollte passieren?]
- Betroffener Code: [Welche Files/Functions?]
- Reproduzierbare Schritte: [Wie reproduzieren?]

🔍 ANALYSE:
- Hypothese: [Was könnte die Ursache sein?]
- Code-Review: [Relevante Code-Stellen analysiert]
- Dependencies: [Welche Services/APIs betroffen?]

✅ LÖSUNG:
- Fix: [Was wurde geändert?]
- Testing: [Wie wurde getestet?]
- Verification: [Problem behoben bestätigt?]
```

### **2. 🎯 Root-Cause-Analysis**

**Immer die eigentliche Ursache finden, nicht nur Symptome behandeln:**

1. ✅ **Symptom**: Was ist das sichtbare Problem?
2. ✅ **Immediate Cause**: Was hat das Symptom direkt verursacht?
3. ✅ **Root Cause**: Was ist die grundlegende Ursache?
4. ✅ **System Fix**: Wie kann das systematisch verhindert werden?

---

## 🚀 **Prevention Strategies**

### **1. 🛡️ Defensive Programming**

```dart
// ✅ Null-Safety konsequent verwenden:
final worldData = widget.worldData;
if (worldData == null) {
  return ErrorWidget('World data not available');
}

// ✅ Error-Boundaries für kritische Operations:
try {
  final result = await apiService.loadData();
  return SuccessWidget(result);
} catch (e) {
  AppLogger.app.e('Data loading failed', {'error': e.toString()});
  return ErrorWidget('Failed to load data: ${e.toString()}');
}
```

### **2. 📋 Pre-Deployment Checklists**

**Vor jedem Deployment systematisch prüfen:**

- ✅ `flutter analyze` ohne Errors
- ✅ Alle ARB-Keys vorhanden und übersetzt  
- ✅ AppScaffold korrekt implementiert
- ✅ Smart Navigation verwendet
- ✅ Keine hardcoded UI-Texte
- ✅ API-Dokumentation aktualisiert

---

**Letztes Update**: Januar 2025  
**Status**: 🔧 Aktiv - Systematisches Debugging für höhere Code-Qualität!