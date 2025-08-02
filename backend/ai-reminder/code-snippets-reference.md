# Flutter Theme Architecture - Code Snippets & Quick Reference

## 🚀 Quick Implementation Templates

### 1. App Setup (app.dart)

```dart
import 'package:flutter/material.dart';
import 'core/providers/theme_root_provider.dart';

class WeltenwindApp extends StatefulWidget {
  @override
  Widget build(BuildContext context) {
    return SplashScreen(
      child: ThemeRootProvider(
        defaultContext: 'universal',
        defaultBundle: 'pre-game-minimal',
        child: MaterialApp.router(
          theme: _themeProvider.currentLightTheme, // Legacy Provider für globale Kontrolle
          darkTheme: _themeProvider.currentDarkTheme,
          themeMode: _themeProvider.themeMode,
          routerConfig: AppRouter.router,
          // ... rest of MaterialApp config
        ),
      ),
    );
  }
}
```

### 2. Scoped Context Pages

#### Auth Pages (Pre-game Context)
```dart
import '../../core/theme/index.dart';

class LoginPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ThemePageProvider(
      contextId: 'pre-game',
      bundleId: 'pre-game-minimal',
      child: ThemeContextConsumer(
        componentName: 'LoginPage',
        builder: (context, theme, extensions) {
          return _buildLoginPage(context, theme, extensions);
        },
      ),
    );
  }
}
```

#### World-specific Pages
```dart
class WorldJoinPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final worldTheme = _getWorldTheme(); // tolkien, space, etc.
    
    return ThemePageProvider(
      contextId: 'world-join',
      bundleId: 'world-preview',
      worldTheme: worldTheme, // 🌍 World-Override
      child: ThemeContextConsumer(
        componentName: 'WorldJoinPage',
        worldThemeOverride: worldTheme,
        fallbackBundle: 'world-preview',
        builder: (context, theme, extensions) {
          return _buildWorldJoinPage(context, theme, extensions);
        },
      ),
    );
  }
}
```

#### In-game Pages  
```dart
class DashboardPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ThemePageProvider(
      contextId: 'in-game',
      bundleId: 'full-gaming',
      worldTheme: _worldTheme, // Optional world-specific
      child: ThemeContextConsumer(
        componentName: 'WorldDashboard',
        worldThemeOverride: _worldTheme,
        fallbackBundle: 'full-gaming',
        builder: (context, theme, extensions) {
          return _buildDashboard(context, theme, extensions);
        },
      ),
    );
  }
}
```

### 3. Mixed Context Pages

```dart
class WorldListPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ThemePageProvider(
      contextId: 'world-selection',
      bundleId: 'world-preview',
      child: ThemeContextConsumer(
        componentName: 'WorldListPage',
        builder: (context, theme, extensions) {
          return Column([
            // Header verwendet Page-Theme
            WorldListHeader(),
            
            // World Cards mit eigenen Themes
            Expanded(
              child: ListView(
                children: worlds.map((world) => 
                  ThemeContextConsumer(
                    componentName: 'WorldCard_${world.id}',
                    worldThemeOverride: world.themeBundle,
                    fallbackBundle: 'world-preview',
                    builder: (cardContext, worldTheme, worldExt) {
                      return WorldCard(
                        world: world,
                        theme: worldTheme, // 🌍 World-spezifisch!
                      );
                    },
                  )
                ).toList(),
              ),
            ),
          ]);
        },
      ),
    );
  }
}
```

### 4. Component-Level Overrides

```dart
// Einfache Komponente (erbt Parent-Theme)
class SimpleComponent extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ThemeContextConsumer(
      componentName: 'SimpleComponent',
      builder: (context, theme, extensions) {
        return Container(
          color: theme.colorScheme.surface,
          child: Text(
            'Hello World',
            style: theme.textTheme.titleMedium,
          ),
        );
      },
    );
  }
}

// Component mit Theme-Override
class WorldSpecificComponent extends StatelessWidget {
  final String worldTheme;
  
  @override
  Widget build(BuildContext context) {
    return ThemeContextConsumer(
      componentName: 'WorldSpecificComponent',
      worldThemeOverride: worldTheme, // Überschreibt Parent-Theme
      fallbackBundle: 'world-preview',
      builder: (context, theme, extensions) {
        return Card(
          color: theme.colorScheme.surface, // World-spezifische Farbe
          child: ListTile(
            title: Text(
              'World Content',
              style: theme.textTheme.titleMedium, // World-spezifische Typography
            ),
          ),
        );
      },
    );
  }
}
```

---

## 🔧 Key Implementation Files

### Core Files Structure:
```
client/lib/core/
├── theme/
│   └── index.dart                    # Barrel export
├── providers/
│   ├── theme_root_provider.dart      # Global fallback
│   ├── theme_page_provider.dart      # Page-level context
│   └── theme_context_consumer.dart   # Component-level overrides
└── services/
    ├── theme_helper.dart             # Mixed-context API
    └── modular_theme_service.dart    # Theme loading service
```

### Bundle-Theme Mapping:
```dart
// In ThemePageProvider und ThemeContextConsumer
String _getBundleForTheme(String themeName) {
  switch (themeName) {
    case 'tolkien':
    case 'space':
    case 'roman':
    case 'nature':
    case 'cyberpunk':
      return 'full-gaming';
    case 'default':
      return 'pre-game-minimal';
    default:
      return 'world-preview';
  }
}
```

---

## 📚 Import Statements

### Standard Import für alle Pages:
```dart
import '../../core/theme/index.dart';
```

### Was das beinhaltet:
```dart
// client/lib/core/theme/index.dart
export '../providers/theme_root_provider.dart';
export '../providers/theme_page_provider.dart';
export '../providers/theme_context_consumer.dart';
export '../services/theme_helper.dart';
export '../services/modular_theme_service.dart';
export '../services/theme_context_manager.dart';
export '../providers/theme_provider.dart'; // Legacy für Übergangszeit
```

---

## 🎯 Context-Bundle Mapping

| Context ID | Bundle ID | Use Case | Example Pages |
|------------|-----------|----------|---------------|
| `universal` | `pre-game-minimal` | Global fallback | App-wide |
| `pre-game` | `pre-game-minimal` | Authentication & onboarding | Login, Register, Landing |
| `world-selection` | `world-preview` | World browsing & selection | WorldList, WorldSearch |
| `world-join` | `world-preview` | World joining process | WorldJoin, InviteLanding |
| `in-game` | `full-gaming` | Active gameplay | Dashboard, GameUI |

---

## 🔄 Migration Patterns

### Alt → Neu Pattern Replacement:

```dart
// ❌ ALT: Direkte ThemeContextConsumer
return ThemeContextConsumer(
  componentName: 'MyPage',
  enableMixedContext: true,
  worldThemeOverride: theme,
  fallbackTheme: 'bundle-name',
  builder: (context, theme, ext) => ...
);

// ✅ NEU: Page Provider + Consumer
return ThemePageProvider(
  contextId: 'appropriate-context',
  bundleId: 'appropriate-bundle',
  worldTheme: theme,
  child: ThemeContextConsumer(
    componentName: 'MyPage',
    worldThemeOverride: theme,
    fallbackBundle: 'bundle-name',
    builder: (context, theme, ext) => ...
  ),
);
```

### Import Updates:
```dart
// ❌ ALT
import '../../core/providers/theme_context_provider.dart';

// ✅ NEU
import '../../core/theme/index.dart';
```

### Parameter Name Changes:
```dart
// ❌ ALT
fallbackTheme: 'bundle-name'

// ✅ NEU  
fallbackBundle: 'bundle-name'
```

---

## 🚨 Debugging Snippets

### Theme Resolution Debugging:
```dart
print('🎨 [THEME-DEBUG] Loading page theme: $contextId → $bundle');
print('🌍 [THEME-DEBUG] World theme override: $worldTheme');
print('🔄 [THEME-DEBUG] Using fallback bundle: $fallbackBundle');
print('✅ [THEME-DEBUG] Theme resolved: ${theme.colorScheme.primary}');
```

### Async Loading Debugging:
```dart
print('🔄 [THEME-DEBUG] Theme not cached, loading async: $themeName ($bundleName)');
print('✅ [THEME-DEBUG] Theme loaded async: $themeName');
print('🔔 [THEME-DEBUG] Notifying UI of theme change: $themeName');
```

### Error Handling:
```dart
try {
  final theme = await ThemeHelper.getCurrentTheme(context);
  print('✅ Theme loaded successfully');
} catch (e) {
  print('❌ Theme loading failed: $e');
  // Fallback to Flutter default
  final theme = Theme.of(context);
}
```

---

## ⚡ Performance Tips

### 1. Minimize Theme Provider Nesting:
```dart
// ✅ Good: One provider per page
ThemePageProvider(
  child: ThemeContextConsumer(...)
)

// ❌ Bad: Multiple nested providers
ThemePageProvider(
  child: ThemePageProvider(
    child: ThemeContextConsumer(...)
  )
)
```

### 2. Use Cached Themes When Possible:
```dart
// Synchronous (cached only)
final cachedTheme = ThemeHelper.getCurrentThemeCached(context);
if (cachedTheme != null) {
  return _buildWithCachedTheme(cachedTheme);
}

// Asynchronous (with loading)
final theme = await ThemeHelper.getCurrentTheme(context);
return _buildWithLoadedTheme(theme);
```

### 3. Component-Level Optimization:
```dart
// ✅ Good: Specific component names for better caching
ThemeContextConsumer(
  componentName: 'WorldCard_${world.id}',
  // ...
)

// ❌ Bad: Generic names cause cache misses
ThemeContextConsumer(
  componentName: 'WorldCard',
  // ...
)
```

---

## 🎯 Best Practices Checklist

### ✅ Do:
- [ ] Use `ThemePageProvider` once per page
- [ ] Import from `core/theme/index.dart`
- [ ] Use `worldThemeOverride` for world-specific components
- [ ] Provide meaningful `componentName` for debugging
- [ ] Use `fallbackBundle` as safety net
- [ ] Test theme switching between different contexts

### ❌ Don't:
- [ ] Nest multiple `ThemePageProvider` widgets
- [ ] Use `Theme.of(context)` in mixed-context scenarios
- [ ] Call `notifyListeners()` in async theme loading
- [ ] Hardcode bundle/theme names outside bundle-configs.json
- [ ] Create circular dependencies between theme services

---

*Quick Reference | Last Updated: Januar 2025*