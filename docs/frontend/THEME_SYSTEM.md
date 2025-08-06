# Theme System Documentation

## Overview

The Weltenwind theme system is built around the concept of **Named Entrypoints** - a modular, context-aware theming solution that allows different visual styles for different parts of the application (pre-game, game, loading, etc.) while maintaining consistency within each context.

## Architecture

### Core Concepts

1. **Named Entrypoints**: Each world can have multiple theme contexts (e.g., `pre-game`, `game`, `loading`)
2. **Modular Assets**: Theme assets are organized in a modular structure under `assets/worlds/{worldId}/themes/{context}/`
3. **Context-Specific Themes**: Different visual styles for different application contexts
4. **Bundle System**: Themes are bundled with their assets for efficient delivery

### File Structure

```
assets/
├── worlds/
│   ├── default/
│   │   ├── manifest.json          # World configuration
│   │   └── themes/
│   │       ├── pre-game/
│   │       │   ├── theme.json     # Theme configuration
│   │       │   ├── icons/         # Context-specific icons
│   │       │   ├── sounds/        # Context-specific sounds
│   │       │   └── materials/     # Context-specific materials
│   │       ├── game/
│   │       │   └── ...
│   │       └── loading/
│   │           └── ...
│   └── medieval/
│       └── ...
```

## Data Flow: From External Files to Game

### 1. Backend API Layer

**File**: `backend/src/routes/themes.ts`

The backend serves theme data through two main endpoints:

- `GET /api/themes/named-entrypoints` - Lists all available worlds and their entrypoints
- `GET /api/themes/named-entrypoints/{worldId}/{context}` - Returns theme data for a specific world and context

**Responsibilities**:
- Reads world manifests from `assets/worlds/{worldId}/manifest.json`
- Serves context-specific theme files from `assets/worlds/{worldId}/themes/{context}/theme.json`
- Combines world info with theme data in the response

### 2. Client-Side Service Layer

**File**: `client/lib/core/services/named_entrypoints_service.dart`

**Responsibilities**:
- Makes HTTP requests to the backend theme API
- Handles network communication and error handling
- Returns raw JSON theme data to the resolver

### 3. Theme Resolution Layer

**File**: `client/lib/shared/theme/theme_resolver.dart`

**Responsibilities**:
- Converts raw JSON theme data into Flutter `ThemeData` objects
- Parses all theme properties (colors, typography, spacing, effects)
- Creates comprehensive Material 3 theme configurations
- Handles both light and dark mode variants

**Key Methods**:
- `_createThemeDataFromJson()` - Main conversion method
- `_parseSpacing()`, `_parseLineHeight()`, etc. - Helper parsers
- `resolveTheme()` - Public API for theme resolution

### 4. Theme Management Layer

**File**: `client/lib/shared/theme/theme_manager.dart`

**Responsibilities**:
- Manages current theme state
- Orchestrates theme resolution and caching
- Handles theme switching between contexts
- Integrates with `ThemeResolver` and `ThemeCache`

**Key Methods**:
- `setWorldTheme()` - Sets theme for a specific world and context
- `getCurrentTheme()` - Returns current theme data
- `switchContext()` - Switches between theme contexts

### 5. Caching Layer

**File**: `client/lib/shared/theme/theme_cache.dart`

**Responsibilities**:
- Caches resolved `ThemeData` objects for performance
- Prevents redundant theme resolution
- Manages cache invalidation

### 6. Provider Layer

**File**: `client/lib/shared/theme/theme_provider.dart`

**Responsibilities**:
- Flutter `ChangeNotifier` for theme state
- Exposes theme data to the UI via `Provider`
- Handles theme mode changes (light/dark)

### 7. UI Integration Layer

**File**: `client/lib/app.dart`

**Responsibilities**:
- Root widget that integrates the theme system
- Uses `MultiProvider` to make `ThemeProvider` available
- Applies resolved themes to `MaterialApp.router`

## Theme Data Structure

### Theme JSON Schema

The `theme.json` file contains comprehensive theme configuration:

```json
{
  "colors": {
    "primary": { "main": "#3B82F6", "light": "#60A5FA", "dark": "#2563EB", "contrast": "#FFFFFF" },
    "secondary": { ... },
    "background": { ... },
    "text": { ... },
    "status": { "success": "#10B981", "warning": "#F59E0B", "error": "#EF4444" },
    "border": { "default": "#E5E7EB", "muted": "#F3F4F6" },
    "interactive": { "hover": "#F8FAFC", "active": "#F1F5F9", "focus": "#DBEAFE" }
  },
  "fonts": {
    "primary": {
      "family": "Inter",
      "fallback": ["system-ui", "sans-serif"],
      "weights": { "light": 300, "normal": 400, "medium": 500, "semibold": 600, "bold": 700 }
    }
  },
  "typography": {
    "headings": { "h1": "2.25rem", "h2": "1.875rem", ... },
    "body": { "xs": "0.75rem", "sm": "0.875rem", "base": "1rem", ... },
    "lineHeights": { "tight": "1.25", "normal": "1.5", "relaxed": "1.75" },
    "fontWeights": { "light": 300, "normal": 400, ... },
    "letterSpacing": { "tight": "-0.025em", "normal": "0em", "wide": "0.025em" }
  },
  "spacing": {
    "xs": "0.25rem", "sm": "0.5rem", "md": "1rem", "lg": "1.5rem",
    "xl": "2rem", "xxl": "3rem", "xxxl": "4rem", "section": "6rem"
  },
  "radius": {
    "none": "0", "sm": "0.125rem", "md": "0.375rem",
    "lg": "0.5rem", "xl": "0.75rem", "full": "9999px"
  },
  "effects": {
    "animations": {
      "easing": "cubic-bezier(0.4, 0, 0.2, 1)",
      "duration": { "fast": "150ms", "normal": "300ms", "slow": "500ms" },
      "scale": { "hover": "1.05", "active": "0.95" }
    },
    "shadows": {
      "softGlow": "0 4px 6px -1px rgba(0, 0, 0, 0.1)",
      "focusRing": "0 0 0 3px rgba(59, 130, 246, 0.5)"
    }
  }
}
```

### Flutter ThemeData Conversion

The `ThemeResolver` converts this JSON into a complete Flutter `ThemeData` object including:

- **ColorScheme**: All color variants and semantic colors
- **TextTheme**: Typography configuration for all text styles
- **Component Themes**: Button, input, card, app bar, navigation themes
- **Material 3**: Full Material 3 design system integration

## Usage Examples

### Setting a Theme in UI Components

```dart
class LoginPage extends StatefulWidget {
  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  late ThemeManager _themeManager;

  @override
  void initState() {
    super.initState();
    _themeManager = ThemeManager();
    _loadDefaultTheme();
  }

  Future<void> _loadDefaultTheme() async {
    try {
      final defaultWorld = World(
        id: 0,
        name: 'Default',
        status: WorldStatus.open,
        createdAt: DateTime.now(),
        startsAt: DateTime.now(),
        description: 'Default world for authentication',
        themeBundle: 'default',
        themeVariant: 'pre-game',
        parentTheme: null,
        themeOverrides: null,
      );

      await _themeManager.setWorldTheme(defaultWorld, context: 'pre-game');
    } catch (e) {
      AppLogger.app.w('⚠️ Failed to load default theme: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Theme is automatically applied via ThemeProvider
      body: Column(
        children: [
          // All widgets automatically use the resolved theme
          Text('Login', style: Theme.of(context).textTheme.headlineMedium),
          ElevatedButton(
            onPressed: () {},
            child: Text('Sign In'),
          ),
        ],
      ),
    );
  }
}
```

### Switching Between Contexts

```dart
// Switch from pre-game to game context
await _themeManager.setWorldTheme(currentWorld, context: 'game');

// Switch to loading context
await _themeManager.setWorldTheme(currentWorld, context: 'loading');
```

## Error Handling

The theme system includes comprehensive error handling:

- **Network Errors**: Graceful fallback to default themes
- **Invalid JSON**: Validation and error logging
- **Missing Files**: Fallback to system defaults
- **Cache Errors**: Automatic cache invalidation and retry

## Performance Considerations

- **Caching**: Resolved themes are cached to avoid redundant processing
- **Lazy Loading**: Themes are loaded only when needed
- **Tree Shaking**: Unused theme properties are optimized out
- **Asset Optimization**: Theme assets are bundled efficiently

## Development Guidelines

### Adding New Theme Contexts

1. Create the context directory: `assets/worlds/{worldId}/themes/{newContext}/`
2. Add `theme.json` with complete theme configuration
3. Update world `manifest.json` to include the new context
4. Test the context in the UI

### Creating New Worlds

1. Create world directory: `assets/worlds/{newWorldId}/`
2. Add `manifest.json` with world configuration
3. Create theme contexts as needed
4. Test the world in the application

### Extending Theme Properties

1. Add new properties to `theme.json`
2. Update `ThemeResolver._createThemeDataFromJson()` to parse new properties
3. Update OpenAPI specification in `docs/openapi/specs/themes.yaml`
4. Test the new properties in the UI

## API Documentation

For complete API documentation, see:
- OpenAPI Specification: `docs/openapi/specs/themes.yaml`
- Generated Documentation: `docs/openapi/generated/`

## Testing

The theme system can be tested at multiple levels:

1. **API Testing**: Test backend endpoints with curl or Postman
2. **Unit Testing**: Test individual components (resolver, manager, cache)
3. **Integration Testing**: Test complete theme flow
4. **UI Testing**: Test theme application in the Flutter app

Example API test:
```bash
# List all worlds and entrypoints
curl http://localhost:3000/api/themes/named-entrypoints

# Get theme data for default world, pre-game context
curl http://localhost:3000/api/themes/named-entrypoints/default/pre-game
```
