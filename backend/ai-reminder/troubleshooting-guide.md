# Flutter Theme Architecture - Troubleshooting Guide

## 🚨 Common Issues & Solutions

### 1. Theme nicht gefunden / Flutter Default Theme wird verwendet

#### Symptom:
```
⚠️ [THEME-DEBUG] Context using Flutter Default Theme (Component: MyPage)
```

#### Mögliche Ursachen:
1. **Bundle Name falsch:** Bundle existiert nicht in bundle-configs.json
2. **Theme Name falsch:** Theme-Datei existiert nicht im backend
3. **Mapping Problem:** World-Theme zu Bundle-Mapping fehlerhaft
4. **Server Problem:** Backend liefert 404 für Theme-Request

#### Lösungsschritte:
```bash
# 1. Check bundle-configs.json
cat backend/theme-editor/bundles/bundle-configs.json | grep "bundleName"

# 2. Check theme files
ls backend/theme-editor/schemas/

# 3. Check server logs
tail -f backend/logs/app.log | grep THEME

# 4. Test API directly
curl http://192.168.2.168:3000/api/themes/tolkien
```

#### Code Fix:
```dart
// Ensure correct bundle names
ThemePageProvider(
  contextId: 'world-join',
  bundleId: 'world-preview', // ✅ Correct
  // bundleId: 'world_preview', // ❌ Wrong (underscore)
  worldTheme: 'tolkien', // ✅ Correct
  // worldTheme: 'mystical-fantasy', // ❌ Wrong (doesn't exist)
)
```

---

### 2. Endlos-Schleife / Performance Probleme

#### Symptom:
```
🔄 [THEME-DEBUG] Loading theme async: tolkien (full-gaming)
🔄 [THEME-DEBUG] Loading theme async: tolkien (full-gaming)
🔄 [THEME-DEBUG] Loading theme async: tolkien (full-gaming)
...
```

#### Ursache:
- `notifyListeners()` im async loading triggert rebuild → neues async loading

#### Lösung:
```dart
// ❌ BAD: notifyListeners() in async method
Future<void> _loadThemeAsync() async {
  final theme = await _themeService.getBundle(bundleName);
  notifyListeners(); // ← Triggert Loop!
}

// ✅ GOOD: State management in StatefulWidget
class _ThemeContextConsumerState extends State<ThemeContextConsumer> {
  ThemeData? _cachedTheme;
  bool _isLoading = false;
  final Set<String> _loadingThemes = <String>{}; // Loop prevention

  Future<void> _loadTheme() async {
    final loadKey = '$themeName:$bundleName';
    if (_loadingThemes.contains(loadKey)) return; // Prevent duplicates
    
    _loadingThemes.add(loadKey);
    setState(() => _isLoading = true);
    
    try {
      final theme = await _themeService.getBundle(bundleName);
      if (mounted) {
        setState(() {
          _cachedTheme = theme;
          _isLoading = false;
        });
      }
    } finally {
      _loadingThemes.remove(loadKey);
    }
  }
}
```

---

### 3. World Theme Override funktioniert nicht

#### Symptom:
```
🌍 [THEME-DEBUG] World theme override: tolkien
🔍 [THEME-DEBUG] getThemeFromBundle: world-preview  // ← Wrong bundle!
```

#### Ursache:
- `worldThemeOverride` wird nicht korrekt zu Bundle-Name gemappt

#### Lösung:
```dart
// In ThemeContextConsumer
String _getBundleForWorldTheme(String worldTheme) {
  switch (worldTheme) {
    case 'tolkien':
    case 'space':
    case 'roman':
    case 'nature':
    case 'cyberpunk':
      return 'full-gaming'; // ✅ Correct mapping
    case 'default':
      return 'pre-game-minimal';
    default:
      return 'world-preview';
  }
}

// Usage
final bundleName = _getBundleForWorldTheme(worldThemeOverride);
final theme = await _themeService.getBundle(bundleName);
```

---

### 4. Mixed Context funktioniert nicht richtig

#### Symptom:
- Page-Theme wird auf alle Components angewandt
- Component-Overrides werden ignoriert

#### Ursache:
- `ThemeHelper.getCurrentTheme()` nicht verwendet
- Theme.of(context) in mixed-context scenario

#### Lösung:
```dart
// ❌ BAD: Theme.of(context) ignoriert Component-Overrides
Widget build(BuildContext context) {
  final theme = Theme.of(context); // ← Wrong!
  return Card(color: theme.colorScheme.surface);
}

// ✅ GOOD: ThemeHelper berücksichtigt alle Context-Level
Widget build(BuildContext context) {
  return FutureBuilder<ThemeData>(
    future: ThemeHelper.getCurrentTheme(context),
    builder: (context, snapshot) {
      final theme = snapshot.data ?? Theme.of(context);
      return Card(color: theme.colorScheme.surface);
    },
  );
}

// ✅ BETTER: ThemeContextConsumer handled das automatisch
return ThemeContextConsumer(
  componentName: 'MyComponent',
  worldThemeOverride: world.themeBundle,
  builder: (context, theme, extensions) {
    return Card(color: theme.colorScheme.surface); // ✅ Correct theme!
  },
);
```

---

### 5. Theme Provider Hierarchy Fehler

#### Symptom:
```
FlutterError: ThemePageProvider.ofRequired() called with a context that does not contain a ThemePageProvider.
```

#### Ursache:
- `ThemeContextConsumer` ohne Parent `ThemePageProvider`
- Context-Lookup außerhalb der Widget-Hierarchie

#### Lösung:
```dart
// ❌ BAD: Consumer ohne Provider
class MyPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ThemeContextConsumer( // ← Fehler: Kein Parent Provider!
      componentName: 'MyPage',
      builder: (context, theme, ext) => Scaffold(...)
    );
  }
}

// ✅ GOOD: Provider → Consumer Hierarchie
class MyPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ThemePageProvider(
      contextId: 'my-context',
      bundleId: 'my-bundle',
      child: ThemeContextConsumer(
        componentName: 'MyPage',
        builder: (context, theme, ext) => Scaffold(...)
      ),
    );
  }
}
```

---

### 6. Server-side Theme Loading Probleme

#### Symptom:
```
❌ [API] GET /api/themes/tolkien 500 (Internal Server Error)
```

#### Debugging:
```bash
# Check server logs
tail -f backend/logs/app.log

# Check theme file exists
ls -la backend/theme-editor/schemas/tolkien.json

# Test API manually
curl -v http://192.168.2.168:3000/api/themes/tolkien

# Check server restart (Node.js caching)
cd backend
pm2 restart weltenwind-api
```

#### Häufige Server-Probleme:
1. **Caching:** Node.js cached alte Version → `pm2 restart`
2. **File Path:** Theme-Datei im falschen Verzeichnis
3. **JSON Syntax:** Invalid JSON in theme file
4. **Permissions:** Backend kann Datei nicht lesen

---

### 7. Bundle-Config Inkonsistenzen

#### Symptom:
- Themes laden, aber falsche Module
- Missing theme properties

#### Check:
```bash
# Validate bundle-configs.json
cd backend/theme-editor/bundles
node -e "console.log(JSON.parse(require('fs').readFileSync('bundle-configs.json', 'utf8')))"

# Check for authoritative bundle names
grep -E "(pre-game-minimal|world-preview|full-gaming|performance-optimized)" bundle-configs.json
```

#### Fix:
```json
// Ensure bundle-configs.json has correct structure
{
  "bundles": {
    "pre-game-minimal": {
      "modules": ["colors", "typography", "spacing"]
    },
    "world-preview": {
      "modules": ["colors", "typography", "spacing", "effects"]
    },
    "full-gaming": {
      "modules": ["colors", "typography", "spacing", "gaming", "effects", "radius"]
    }
  },
  "bundleResolver": {
    "contextMapping": {
      "pre-game": "pre-game-minimal",
      "world-preview": "world-preview",
      "in-game": "full-gaming"
    },
    "themeMapping": {
      "default": "pre-game-minimal",
      "tolkien": "full-gaming",
      "space": "full-gaming"
    }
  }
}
```

---

### 8. Race Conditions bei Theme Loading

#### Symptom:
- UI rendert mit Default Theme obwohl korrektes Theme verfügbar
- Theme "flackert" zwischen Default und Custom

#### Ursache:
- Async Theme Loading während Widget Build
- Theme nicht gecacht beim ersten Build

#### Lösung:
```dart
class _ThemeContextConsumerState extends State<ThemeContextConsumer> {
  @override
  void initState() {
    super.initState();
    _loadTheme(isDark: false); // Pre-load theme
  }

  @override
  Widget build(BuildContext context) {
    // Loading State während async Theme Loading
    if (_isLoading && _cachedTheme == null) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    // Use cached theme or fallback
    final effectiveTheme = _cachedTheme ?? Theme.of(context);
    
    return widget.builder(context, effectiveTheme, _cachedExtensions);
  }
}
```

---

### 9. Import Probleme

#### Symptom:
```
Error: Undefined name 'ThemePageProvider'
Error: Undefined name 'ThemeContextConsumer'
```

#### Lösung:
```dart
// ✅ Correct import
import '../../core/theme/index.dart';

// ❌ Wrong imports (old)
import '../../core/providers/theme_context_provider.dart';
```

#### Check barrel export:
```dart
// client/lib/core/theme/index.dart should contain:
export '../providers/theme_root_provider.dart';
export '../providers/theme_page_provider.dart';
export '../providers/theme_context_consumer.dart';
export '../services/theme_helper.dart';
```

---

### 10. Parameter Name Confusion

#### Symptom:
```
Error: The named parameter 'fallbackTheme' isn't defined
```

#### Ursache:
- Alte API Parameter verwendet

#### Lösung:
```dart
// ❌ OLD API
ThemeContextConsumer(
  enableMixedContext: true,      // ← Removed
  staticAreas: {...},            // ← Removed
  fallbackTheme: 'bundle-name',  // ← Renamed
)

// ✅ NEW API
ThemeContextConsumer(
  worldThemeOverride: 'theme-name',    // ← For overrides
  fallbackBundle: 'bundle-name',       // ← Renamed from fallbackTheme
)
```

---

## 🔧 Debug Commands Cheatsheet

### Flutter Debugging:
```bash
# Analyze code
flutter analyze

# Hot reload with verbose
flutter run --verbose

# Check theme loading in console
flutter run | grep THEME-DEBUG
```

### Backend Debugging:
```bash
# Server logs
tail -f backend/logs/app.log | grep -E "(THEME|ERROR)"

# Theme API test
curl http://192.168.2.168:3000/api/themes

# Check theme file
cat backend/theme-editor/schemas/tolkien.json | jq .

# Restart backend
cd backend
pm2 restart weltenwind-api
pm2 logs weltenwind-api
```

### Bundle Config Validation:
```bash
# Validate JSON
cd backend/theme-editor/bundles
python -m json.tool bundle-configs.json

# Check bundle names
grep -o '"[^"]*bundle[^"]*"' bundle-configs.json | sort | uniq
```

---

## 📊 Performance Debugging

### Theme Loading Performance:
```dart
// Add timing measurements
final stopwatch = Stopwatch()..start();
final theme = await _themeService.getBundle(bundleName);
stopwatch.stop();
print('🕒 Theme loaded in ${stopwatch.elapsedMilliseconds}ms');
```

### Widget Build Performance:
```dart
// Monitor rebuild frequency
class _MyWidgetState extends State<MyWidget> {
  int buildCount = 0;
  
  @override
  Widget build(BuildContext context) {
    buildCount++;
    print('🔄 Build #$buildCount for ${widget.componentName}');
    return ...;
  }
}
```

---

## ✅ Health Check Commands

Run these to verify theme system health:

```bash
# 1. Code Analysis
flutter analyze | grep -E "(error|warning)" | wc -l

# 2. Theme Files Exist
ls backend/theme-editor/schemas/{default,tolkien,space,roman,nature,cyberpunk}.json

# 3. Bundle Config Valid
node -e "JSON.parse(require('fs').readFileSync('backend/theme-editor/bundles/bundle-configs.json'))" && echo "✅ Valid JSON"

# 4. API Responsive
curl -s http://192.168.2.168:3000/api/themes | jq . > /dev/null && echo "✅ API OK"

# 5. Server Running
pm2 status | grep weltenwind-api
```

---

*Troubleshooting Guide | Last Updated: Januar 2025*