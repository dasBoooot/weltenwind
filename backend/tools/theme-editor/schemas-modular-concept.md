# 🎮 Modulare Gaming Theme Architektur für Weltenwind

## 📁 Schema-Struktur

```
schemas/
├─ main.schema.json                 # Master Schema mit $refs
├─ core/
│  ├─ colors.schema.json           # Farbpaletten (6KB)
│  ├─ typography.schema.json       # Schriftarten + FontFamily (3KB)  
│  ├─ spacing.schema.json          # Margins/Paddings (2KB)
│  └─ radius.schema.json           # Border-Radius Werte (1KB)
├─ components/
│  ├─ buttons.schema.json          # Alle Button-Varianten (8KB)
│  ├─ appBar.schema.json           # App Bar + Navigation (4KB)
│  ├─ cards.schema.json            # Card Themes (5KB)
│  ├─ inputs.schema.json           # Input Fields + Forms (6KB)
│  ├─ navigation.schema.json       # Bottom Navigation (3KB)
│  └─ dialogs.schema.json          # Dialogs + Modals (4KB)
├─ gaming/
│  ├─ progress.schema.json         # Health/Mana/XP Bars (7KB)
│  ├─ inventory.schema.json        # Item Slots + Rarity (9KB)
│  ├─ tooltip.schema.json          # Gaming Tooltips (4KB)
│  ├─ hud.schema.json              # Minimap + Buff Bars (8KB)
│  ├─ achievements.schema.json     # Badge System (5KB) 
│  └─ battleEffects.schema.json    # Combat + Status Effects (6KB)
├─ effects/
│  ├─ animations.schema.json       # Transitions + Easing (5KB)
│  ├─ particles.schema.json        # Particle System (4KB)
│  ├─ visual.schema.json           # Glow + Shimmer + Magic (6KB)
│  └─ screen.schema.json           # Bloom + Weather + Parallax (5KB)
├─ accessibility/
│  └─ a11y.schema.json             # ColorBlind + Focus + Scaling (4KB)
└─ responsive.schema.json          # Breakpoints + Adaptive (3KB)
```

## 🎯 Gaming Theme Bundles

### 1. 🚪 Pre-Game Bundle (Minimal UI)
```json
{
  "name": "weltenwind-minimal",
  "includes": [
    "core/colors.schema.json",
    "core/typography.schema.json", 
    "core/spacing.schema.json",
    "components/buttons.schema.json",
    "components/inputs.schema.json",
    "effects/animations.schema.json"
  ],
  "size": "~25KB (~75% kleiner)",
  "context": "Login, Settings, Main Menu"
}
```

### 2. 🗺️ World Preview Bundle 
```json
{
  "name": "world-fire-preview",
  "extends": "weltenwind-minimal",
  "includes": [
    "components/cards.schema.json",
    "effects/visual.schema.json",
    "effects/particles.schema.json"
  ],
  "overrides": {
    "colors": "fire-world-colors.json"
  },
  "size": "~40KB (~60% kleiner)",
  "context": "World Selection Boxes"
}
```

### 3. ⚔️ Full Gaming Bundle
```json
{
  "name": "world-fire-complete", 
  "extends": "world-fire-preview",
  "includes": [
    "gaming/progress.schema.json",
    "gaming/inventory.schema.json", 
    "gaming/hud.schema.json",
    "gaming/battleEffects.schema.json",
    "gaming/achievements.schema.json",
    "components/navigation.schema.json",
    "components/dialogs.schema.json",
    "accessibility/a11y.schema.json",
    "responsive.schema.json"
  ],
  "size": "~100KB (Full Schema)",
  "context": "In-Game Vollständig"
}
```

## 🚀 Vorteile der Modularen Architektur

### 📈 Performance
- **Lazy Loading**: Nur laden was gebraucht wird
- **Bundle Splitting**: 75% weniger Daten für Pre-Game
- **Caching**: Einzelne Module cachen  
- **Hot Reload**: Nur geänderte Module neu laden

### 🛠️ Development
- **Separation of Concerns**: Jede Komponente isoliert
- **Team Work**: Parallel an verschiedenen Modulen arbeiten
- **Versionierung**: Einzelne Module updaten ohne Full-Schema zu brechen
- **Testing**: Jedes Modul einzeln testbar

### 🎮 Gaming-Spezifisch
- **Context Switching**: Smooth Theme-Wechsel zwischen Game-States
- **World Themes**: Jede Welt kann eigene Module haben
- **Progressive Enhancement**: Von minimal zu full gaming UI
- **Mix & Match**: Base Theme + World-spezifische Overrides

## 🔧 Technische Umsetzung

### Schema Referencing
```json
// main.schema.json
{
  "$schema": "http://json-schema.org/draft-07/schema#",
  "title": "Weltenwind Modular Theme",
  "allOf": [
    { "$ref": "./core/colors.schema.json" },
    { "$ref": "./core/typography.schema.json" },
    { "$ref": "./components/buttons.schema.json" }
  ]
}
```

### Theme Bundler
```typescript
class ThemeBundler {
  async buildTheme(bundleConfig: ThemeBundle): Promise<CompiledTheme> {
    const schemas = await this.loadSchemas(bundleConfig.includes);
    const compiled = this.mergeSchemas(schemas);
    return this.applyOverrides(compiled, bundleConfig.overrides);
  }
}
```

### Runtime Theme Switching
```typescript
// Pre-Game → World Selection
await themeService.loadBundle('world-fire-preview');

// World Selection → In-Game  
await themeService.extendBundle([
  'gaming/inventory.schema.json',
  'gaming/hud.schema.json'
]);
```

## 🎯 Gaming Use Cases

1. **Loading Screens**: Minimal Theme während Assets laden
2. **World Transitions**: Smooth Theme-Morphing zwischen Welten
3. **Performance Modes**: Reduzierte Effekte für schwächere Geräte
4. **Seasonal Events**: Temporäre Effect-Module hinzufügen
5. **Player Preferences**: User kann Module an/abschalten

## 🧠 Advanced Features & Gaming Intelligence

### 1. 🛡️ Schema Validation Helper
```typescript
// schemas/utils/validation.ts
class SchemaValidator {
  async validateModule(modulePath: string): Promise<ValidationResult> {
    const schema = await this.loadSchema(modulePath);
    const resolved = await this.resolveRefs(schema);
    return this.validate(resolved);
  }
  
  async testSnippet(moduleType: 'inventory' | 'hud' | 'progress', snippet: any) {
    const schema = await this.loadSchema(`gaming/${moduleType}.schema.json`);
    return this.validateSnippet(snippet, schema);
  }
  
  // Live-Validierung im Theme Editor!
  async validateLiveEdit(componentPath: string, newValue: any) {
    return this.validateModule(componentPath).then(result => ({
      isValid: result.valid,
      errors: result.errors,
      suggestions: this.generateSuggestions(componentPath, newValue)
    }));
  }
}
```

### 2. 📋 Theme Metadata System
```json
// Enhanced Bundle Structure
{
  "name": "shadowrealm-complete",
  "version": "1.2.0",
  "meta": {
    "author": "Sven",
    "created": "2025-08-01T12:00:00Z",
    "lastModified": "2025-08-01T15:30:00Z",
    "targetWorlds": ["shadow", "void", "nightmare"],
    "compatibleWith": {
      "client": ">=1.2.0",
      "editor": ">=0.9.0",
      "api": ">=2.1.0"
    },
    "tags": ["dark", "pvp", "hardcore", "atmospheric"],
    "screenshots": ["shadow-preview.jpg", "shadow-ingame.jpg"],
    "description": "Düsteres Shadow Realm Theme mit enhanced PvP indicators"
  },
  "extends": "weltenwind-base",
  "includes": ["gaming/hud.schema.json", "effects/dark.schema.json"]
}
```

### 3. 🎯 Dynamic Conditions System (GAMING KILLER-FEATURE!)
```json
// Context-Aware Theme Activation
{
  "name": "adaptive-fire-world",
  "conditions": {
    "world": "fire",
    "timeOfDay": "night",
    "eventActive": ["darkMoon", "dragonRaid"],
    "playerLevel": ">=25",
    "deviceTier": "high",
    "gameMode": "hardcore",
    "weather": "storm"
  },
  "conditionalOverrides": {
    "effects/particles": {
      "density": "high",
      "colors": ["#FF4500", "#8B0000", "#FF6347"]
    },
    "gaming/hud": {
      "minimap": {
        "enemyDotColor": "#FF0000",
        "dangerZoneColor": "#8B0000"
      }
    }
  }
}
```

### 4. 🔗 Intelligent Dependency Resolver
```typescript
// Auto-Dependency Resolution
class BundleResolver {
  async resolveDependencies(bundleConfig: ThemeBundle): Promise<ResolvedBundle> {
    const dependencies = new Map();
    
    // Automatische Dependencies
    const deps = {
      'gaming/hud': ['gaming/progress', 'core/colors'],
      'gaming/inventory': ['core/colors', 'effects/visual'],
      'gaming/battleEffects': ['gaming/progress', 'effects/animations'],
      'effects/particles': ['core/colors', 'effects/visual']
    };
    
    for (const module of bundleConfig.includes) {
      const moduleDeps = deps[module] || [];
      moduleDeps.forEach(dep => dependencies.set(dep, true));
    }
    
    return {
      ...bundleConfig,
      resolvedIncludes: [...bundleConfig.includes, ...dependencies.keys()],
      dependencyTree: this.buildDependencyTree(dependencies)
    };
  }
}
```

## 🎮 Advanced Gaming Context Features

### 5. 🌟 Dynamic Theme Morphing
```json
// Smooth Theme Transitions zwischen Game States
{
  "name": "fire-to-ice-transition",
  "morphing": {
    "duration": 2000,
    "easing": "cubic-bezier(0.4, 0, 0.2, 1)",
    "properties": {
      "colors.primary": {
        "from": "#FF4500",
        "to": "#00BFFF"
      },
      "effects.particles.colors": {
        "from": ["#FF4500", "#FF6347"],
        "to": ["#00BFFF", "#87CEEB"]
      }
    }
  }
}
```

### 6. 🎲 Conditional Gaming Logic
```json
// Erweiterte Gaming Conditions
{
  "conditions": {
    "playerStats": {
      "health": "<25%",
      "mana": ">80%",
      "level": ">=50"
    },
    "worldState": {
      "bossActive": true,
      "pvpZone": true,
      "questCompleted": ["fireTemple", "iceCorvus"]
    },
    "performance": {
      "fps": "<30",
      "memory": ">80%",
      "networkLatency": ">200ms"
    }
  },
  "adaptiveSettings": {
    "lowHealth": {
      "effects.screenEffects.vignetteStrength": 0.8,
      "colors.effects.overlay": "#FF000020"
    },
    "lowPerformance": {
      "effects.particles.enabled": false,
      "gaming.animations.defaultDurationMs": 150
    }
  }
}
```

### 7. 🔄 Runtime Theme Hot-Swapping
```typescript
// Live Theme Updates ohne Reload
class RuntimeThemeEngine {
  async applyConditionalTheme(gameState: GameState) {
    const activeConditions = this.evaluateConditions(gameState);
    const applicableThemes = this.findMatchingThemes(activeConditions);
    
    if (applicableThemes.length > 0) {
      const mergedTheme = this.mergeThemes(applicableThemes);
      await this.morphToTheme(mergedTheme, { duration: 1000 });
    }
  }
  
  // Event-basierte Theme Changes
  onGameEvent(event: 'worldEnter' | 'bossSpawn' | 'playerDeath' | 'questComplete') {
    this.queueThemeEvaluation(event);
  }
}
```

### 8. 🎪 Theme A/B Testing Framework
```json
{
  "experiments": {
    "inventoryLayout": {
      "variants": ["compact", "expanded", "grid"],
      "weights": [33, 33, 34],
      "metrics": ["clickRate", "userSatisfaction", "taskCompletion"]
    },
    "combatUI": {
      "variants": ["minimal", "detailed"],
      "conditions": {
        "playerLevel": ">=10"
      }
    }
  }
}
```

Diese Architektur macht Weltenwind zu einem **adaptiven, intelligenten Gaming Theme System** das auf jeden Game Context perfekt reagiert! 🚀