# 🔧 Dynamic Configuration System

**Dynamische Client-Konfiguration für Weltenwind**

Das Weltenwind-System unterstützt jetzt **dynamische URL-Konfiguration** zur Laufzeit, um Skalierung und Multi-Server-Deployments zu ermöglichen.

---

## 📋 **Übersicht**

### **Problem gelöst:**
- ❌ **Hardcodierte IPs** in Client-Code
- ❌ **Manuelle Konfiguration** bei Server-Änderungen
- ❌ **Keine Skalierbarkeit** für Multi-Server-Setups

### **Lösung:**
- ✅ **Backend-basierte Konfiguration** zur Laufzeit
- ✅ **Automatische URL-Aktualisierung** beim App-Start
- ✅ **Fallback-System** für Offline-Betrieb
- ✅ **Caching-Mechanismus** für Performance

---

## 🏗️ **Architektur**

### **Backend: Environment Variables**
```bash
# backend/.env
PUBLIC_API_URL="https://api.weltenwind.com/api"
PUBLIC_CLIENT_URL="https://game.weltenwind.com"
PUBLIC_ASSETS_URL="https://assets.weltenwind.com"
```

### **Backend: Configuration Endpoint**
```typescript
// GET /api/health/client-config
{
  "apiUrl": "https://api.weltenwind.com/api",
  "clientUrl": "https://game.weltenwind.com",
  "assetUrl": "https://assets.weltenwind.com",
  "environment": "production",
  "timestamp": 1640995200000,
  "version": "1.0.0"
}
```

### **Client: Dynamic Loading**
```dart
// Client lädt Konfiguration beim Start
final clientConfigService = ClientConfigService();
await clientConfigService.initialize();

// URLs werden automatisch aktualisiert
Env.apiUrl = "https://api.weltenwind.com"
Env.clientUrl = "https://game.weltenwind.com/game"
Env.assetUrl = "https://assets.weltenwind.com"
```

---

## 🔧 **Implementation**

### **1. Backend Configuration Endpoint**

**Datei:** `backend/src/routes/health.ts`

```typescript
router.get('/client-config', async (req: Request, res: Response) => {
  const clientConfig = {
    apiUrl: process.env.PUBLIC_API_URL || 'https://192.168.2.168/api',
    clientUrl: process.env.PUBLIC_CLIENT_URL || 'https://192.168.2.168',
    assetUrl: process.env.PUBLIC_ASSETS_URL || 'https://192.168.2.168',
    environment: process.env.NODE_ENV || 'development',
    timestamp: Date.now(),
    version: '1.0.0'
  };

  res.json(clientConfig);
});
```

### **2. Client Configuration Service**

**Datei:** `client/lib/core/services/client_config_service.dart`

```dart
class ClientConfigService {
  Future<bool> loadConfiguration() async {
    final response = await http.get(
      Uri.parse('${Env.apiUrl}/api/health/client-config'),
    );

    if (response.statusCode == 200) {
      final configData = json.decode(response.body);
      
      // URLs aktualisieren
      Env.setApiUrl(configData['apiUrl']);
      Env.setClientUrl(configData['clientUrl']);
      Env.setAssetUrl(configData['assetUrl']);
      
      return true;
    }
    return false;
  }
}
```

### **3. App Initialization**

**Datei:** `client/lib/main.dart`

```dart
void main() async {
  // 1. Client-Konfiguration laden (muss vor anderen Services passieren)
  await _initializeClientConfiguration();
  
  // 2. Alle anderen Services initialisieren
  await _initializeServices();
  
  runApp(const WeltenwindApp());
}
```

---

## 🚀 **Deployment-Szenarien**

### **Szenario 1: Single Server**
```bash
# backend/.env
PUBLIC_API_URL="https://192.168.2.168/api"
PUBLIC_CLIENT_URL="https://192.168.2.168"
PUBLIC_ASSETS_URL="https://192.168.2.168"
```

### **Szenario 2: Multi-Server Setup**
```bash
# backend/.env
PUBLIC_API_URL="https://api.weltenwind.com/api"
PUBLIC_CLIENT_URL="https://game.weltenwind.com"
PUBLIC_ASSETS_URL="https://assets.weltenwind.com"
```

### **Szenario 3: Load Balancer**
```bash
# backend/.env
PUBLIC_API_URL="https://lb.weltenwind.com/api"
PUBLIC_CLIENT_URL="https://lb.weltenwind.com"
PUBLIC_ASSETS_URL="https://lb.weltenwind.com"
```

---

## ⚡ **Performance & Caching**

### **Caching-Strategie**
- **Cache-Dauer:** 5 Minuten
- **Automatische Invalidierung** nach Timeout
- **Manuelles Reload** möglich
- **Fallback** auf Default-Konfiguration

### **Ladezeiten**
- **Erster Start:** ~100-500ms (HTTP Request)
- **Folgende Starts:** ~1-5ms (Cache)
- **Offline-Modus:** ~1ms (Default-Konfiguration)

---

## 🔄 **Migration Guide**

### **Von Hardcoded zu Dynamic**

**Vorher:**
```dart
class Env {
  static const String apiUrl = 'https://192.168.2.168';
  static const String clientUrl = 'https://192.168.2.168/game';
  static const String assetUrl = 'https://192.168.2.168';
}
```

**Nachher:**
```dart
class Env {
  static String? _apiUrl;
  static String? _clientUrl;
  static String? _assetUrl;
  
  static String get apiUrl => _apiUrl ?? _defaultApiUrl;
  static String get clientUrl => _clientUrl ?? _defaultClientUrl;
  static String get assetUrl => _assetUrl ?? _defaultAssetUrl;
  
  static void setApiUrl(String url) => _apiUrl = url;
  static void setClientUrl(String url) => _clientUrl = url;
  static void setAssetUrl(String url) => _assetUrl = url;
}
```

---

## 🛡️ **Security & Error Handling**

### **Security Features**
- ✅ **Keine Auth erforderlich** für Config-Endpoint
- ✅ **Rate Limiting** auf Backend-Seite
- ✅ **CORS-Headers** korrekt gesetzt
- ✅ **Timeout-Protection** (10 Sekunden)

### **Error Handling**
- ✅ **Graceful Degradation** bei Backend-Unverfügbarkeit
- ✅ **Fallback auf Defaults** bei Fehlern
- ✅ **Retry-Mechanismus** (optional)
- ✅ **Logging** für Debugging

### **Monitoring**
```dart
// Debug-Informationen abrufen
final debugInfo = clientConfigService.getDebugInfo();
print('Config Status: ${debugInfo['isConfigurationCurrent']}');
print('Last Load: ${debugInfo['lastLoadTime']}');
```

---

## 📊 **Monitoring & Debugging**

### **Backend Logs**
```typescript
loggers.system.info('Client configuration requested', {
  ip: req.ip,
  userAgent: req.get('User-Agent'),
  config: {
    environment: clientConfig.environment,
    apiUrl: clientConfig.apiUrl,
    clientUrl: clientConfig.clientUrl,
    assetUrl: clientConfig.assetUrl
  }
});
```

### **Client Logs**
```dart
AppLogger.app.i('✅ Client configuration loaded successfully', error: {
  'environment': environment,
  'apiUrl': Env.apiUrl,
  'clientUrl': Env.clientUrl,
  'assetUrl': Env.assetUrl,
  'timestamp': _lastLoadTime!.toIso8601String(),
});
```

---

## 🔮 **Future Enhancements**

### **Geplante Features**
- 🔄 **Automatic Retry** bei Konfigurationsfehlern
- 📱 **Push-Notifications** bei URL-Änderungen
- 🔐 **Signed Configuration** für Security
- 📊 **Configuration Analytics** für Monitoring
- 🌐 **Multi-Region Support** für CDN

### **Advanced Scenarios**
- **Blue-Green Deployment** mit URL-Switching
- **A/B Testing** mit verschiedenen Configs
- **Feature Flags** über Configuration
- **Environment-Specific** Configs

---

## 📚 **Verwandte Dokumentation**

- **[Backend Environment Variables](backend/infrastructure/environment-variables.md)**
- **[SSL & nginx Setup](backend/infrastructure/ssl-nginx-setup.md)**
- **[Theme System](frontend/THEME_SYSTEM.md)**
- **[Deployment Guide](guides/deployment-guide.md)**

---

**Status:** ✅ Production Ready  
**Version:** 1.0.0  
**Letzte Aktualisierung:** Januar 2025
