# 🎨 Named Entrypoints Theme System

**Das Weltenwind Theme System** ist eine modulare, context-aware Architektur für dynamische Themes und Assets.

---

## 📋 **Inhaltsverzeichnis**

1. [🏗️ System-Architektur](#️-system-architektur)
2. [🎯 Named Entrypoints](#-named-entrypoints)
3. [🖼️ Asset Management](#️-asset-management)
4. [🔧 Implementation](#-implementation)
5. [📱 Flutter Integration](#-flutter-integration)
6. [⚡ Performance & Caching](#-performance--caching)
7. [🚀 Deployment & Production](#-deployment--production)

---

## 🏗️ **System-Architektur**

### **Modulare Theme-Struktur**
```
assets/
├── worlds/
│   ├── default/
│   │   ├── manifest.json          # 🌍 World-Metadaten & Entrypoints
│   │   ├── themes/
│   │   │   ├── pre-game/
│   │   │   │   └── theme.json     # 🎨 Pre-Game Theme
│   │   │   ├── game/
│   │   │   │   └── theme.ts       # 🎮 Game Theme
│   │   │   └── loading/
│   │   │       └── theme.ts       # ⏳ Loading Theme
│   │   └── ui/
│   │       └── backgrounds/
│   │           ├── default.png    # 🖼️ Standard-Hintergrund
│   │           ├── login.png      # 🔐 Login-Hintergrund
│   │           └── game.png       # 🎮 Game-Hintergrund
│   └── custom-world/
│       └── ...                    # 🌍 Benutzerdefinierte Welten
```

### **Context-Aware Theme Resolution**
- **Pre-Game**: Login, Register, Setup, Invite-Landing
- **Game**: Aktives Spiel, Game-UI, HUD
- **Loading**: Ladebildschirme, Transitions

---

## 🎯 **Named Entrypoints**

### **Manifest.json Structure**
```json
{
  "manifest": {
    "id": "default",
    "name": "Weltenwind Default",
    "version": "1.3.0",
    "entrypoints": {
      "themes": {
        "pre-game": {
          "file": "themes/pre-game/theme.json"
        },
        "game": {
          "file": "themes/game/theme.ts",
          "export": "defaultGameTheme"
        },
        "loading": {
          "file": "themes/loading/theme.ts",
          "export": "defaultLoadingTheme"
        }
      }
    }
  }
}
```

### **API Endpoints**
- `GET /api/themes/manifest/{worldId}` - Manifest abrufen
- `GET /api/themes/named-entrypoints/{worldId}/{context}` - Theme für Context

---

## 🖼️ **Asset Management**

### **Nginx-basierte Asset-Serving**
Das Asset-System verwendet **nginx `alias`** für optimale Performance:

```nginx
location /api/assets/ {
    alias /srv/weltenwind/assets/;

    # CORS für Web-Nutzung (z. B. von Flutter Web)
    add_header Access-Control-Allow-Origin "*" always;
    add_header Access-Control-Allow-Methods "GET, OPTIONS" always;
    add_header Access-Control-Allow-Headers "DNT,User-Agent,X-Requested-With,If-Modified-Since,Cache-Control,Content-Type,Range" always;

    # Browser-Caching
    expires 1h;
    add_header Cache-Control "public, immutable";
}
```

### **Asset-URL-Struktur**
```
https://192.168.2.168/api/assets/worlds/{worldId}/ui/backgrounds/{pageType}.png
```

**Beispiele:**
- `https://192.168.2.168/api/assets/worlds/default/ui/backgrounds/default.png`
- `https://192.168.2.168/api/assets/worlds/default/ui/backgrounds/login.png`
- `https://192.168.2.168/api/assets/worlds/custom/ui/backgrounds/game.png`

### **Vorteile der nginx-Lösung**
- ✅ **Direkte Asset-Serving** - Kein Backend-Overhead
- ✅ **Optimale Performance** - Statische Dateien von nginx
- ✅ **CORS-Support** - Korrekte Headers für Web-Nutzung
- ✅ **Caching** - Browser-Caching für bessere Performance
- ✅ **Skalierbar** - Einfache Auslagerung auf CDN möglich

### **Asset-Discovery**
Das System unterstützt **dynamische Asset-Erkennung**:

1. **Theme-basierte Pfade** - Aus `theme.json` Backgrounds
2. **Fallback-Pfade** - Standard-Namenskonventionen
3. **World-spezifische Assets** - Pro Welt eigene Assets

---

## 🔧 **Implementation**

### **Backend: Theme Resolution**
```typescript
// routes/themes.ts
router.get('/named-entrypoints/:worldId/:context', async (req, res) => {
  const { worldId, context } = req.params;
  
  // 1. Manifest laden
  const manifest = await loadManifest(worldId);
  
  // 2. Theme für Context auflösen
  const theme = await resolveTheme(worldId, context);
  
  // 3. Assets mit korrekten URLs zurückgeben
  res.json({
    manifest,
    theme: {
      context,
      data: theme,
      assets: {
        backgrounds: {
          auth: `ui/backgrounds/default.png`,
          login: `ui/backgrounds/default.png`,
          // ...
        }
      }
    }
  });
});
```

### **Client: Asset Loading**
```dart
// shared/services/dynamic_asset_service.dart
class DynamicAssetService {
  static const String assetBaseUrl = 'https://192.168.2.168/api/assets';
  
  Future<String?> findExistingAsset(List<String> possiblePaths) async {
    for (String path in possiblePaths) {
      if (path.contains('{{ASSET_IP}}')) {
        path = path.replaceAll('{{ASSET_IP}}', assetBaseUrl);
      }
      
      // Asset-Check über HTTP HEAD Request
      if (await _checkAssetExists(path)) {
        return path;
      }
    }
    return null;
  }
}
```

---

## 📱 **Flutter Integration**

### **BackgroundImage Widget**
```dart
class BackgroundImage extends StatelessWidget {
  final World world;
  final String? pageType;
  
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String?>(
      future: ThemeResolver().resolveBackgroundImage(world, pageType: pageType),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return Image.network(
            snapshot.data!,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return _buildFallbackBackground(context);
            },
          );
        }
        return _buildFallbackBackground(context);
      },
    );
  }
}
```

### **ThemeResolver Service**
```dart
class ThemeResolver {
  Future<String?> resolveBackgroundImage(World world, {String? pageType}) async {
    // 1. Named Entrypoint Theme laden
    final theme = await NamedEntrypointsService().getTheme(world.themeBundle, 'pre-game');
    
    // 2. Background-Pfad aus Theme extrahieren
    final backgroundPath = theme['backgrounds'][pageType ?? 'auth'];
    
    // 3. Asset-URL mit nginx-Pfad konstruieren
    return 'https://192.168.2.168/api/assets/worlds/${world.themeBundle}/$backgroundPath';
  }
}
```

---

## ⚡ **Performance & Caching**

### **Multi-Level Caching**
1. **Browser-Cache** - nginx `expires 1h`
2. **Flutter-Cache** - `Image.network` mit `gaplessPlayback`
3. **Theme-Cache** - In-Memory Theme-Caching
4. **Asset-Cache** - Dynamische Asset-Discovery-Cache

### **Lazy Loading**
- **Theme-Daten** werden nur bei Bedarf geladen
- **Assets** werden erst bei Widget-Build angefordert
- **Fallback-System** für fehlende Assets

---

## 🚀 **Deployment & Production**

### **Production Setup**
1. **Assets** in `/srv/weltenwind/assets/` deployen
2. **Nginx-Konfiguration** mit Asset-Alias aktivieren
3. **CORS-Headers** für Web-Nutzung konfigurieren
4. **Caching-Strategien** für Performance optimieren

### **CDN Integration (Future)**
```nginx
# Zukünftige CDN-Integration
location /api/assets/ {
    proxy_pass https://cdn.weltenwind.com/assets/;
    # ... CORS & Caching Headers
}
```

### **Monitoring**
- **Asset-Requests** über nginx-Logs
- **Theme-Loading** über Backend-Logs
- **Performance-Metriken** über Flutter Analytics

---

## 📚 **Verwandte Dokumentation**

- **[Backend Theme API](api/themes.md)** - Vollständige API-Dokumentation
- **[Frontend Architecture](README.md)** - Flutter Client-Architektur
- **[Deployment Guide](guides/deployment-guide.md)** - Production Setup
- **[Security Guide](backend/security/)** - Asset-Security & CORS

---

**Status**: ✅ Production Ready  
**Version**: 1.3.0  
**Letzte Aktualisierung**: Januar 2025
