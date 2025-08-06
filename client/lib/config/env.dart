class Env {
  static const String apiUrl = 'https://192.168.2.168';
  static const String apiBasePath = '/api';
  
  // Client/Frontend URL (für Invite-Links und Web-Routing)
  static const String clientUrl = 'https://192.168.2.168/game';
  
  // ✅ Asset Server URL (separate für zukünftige Auslagerung)
  static const String assetUrl = 'https://192.168.2.168';
  
  // ✅ Static Assets (nginx-proxied, über HTTPS)
  static const String themeEditorUrl = '$apiUrl/theme-editor';
  static const String bundleConfigsUrl = '$themeEditorUrl/bundles/bundle-configs.json';
  
  // ✅ Asset Server Configuration für modulare Welten
  static const String assetBaseUrl = '$assetUrl/assets';
  static const String assetWorldsPath = '/worlds';
  static const String assetManifestFile = 'manifest.json';
  
  // ✅ Helper für Asset URLs
  static String getWorldAssetUrl(String worldId) => 
    '$assetBaseUrl$assetWorldsPath/$worldId';
  
  static String getWorldManifestUrl(String worldId) => 
    '$assetBaseUrl$assetWorldsPath/$worldId/$assetManifestFile';
  
  static String getWorldThemeUrl(String worldId) => 
    '$assetBaseUrl$assetWorldsPath/$worldId/theme.ts';
  
  static String getWorldAssetPath(String worldId, String assetPath) => 
    '$assetBaseUrl$assetWorldsPath/$worldId/$assetPath';
  
  // ✅ Helper für Theme-Schema URLs
  static String getThemeSchemaUrl(String themeName) => 
    '$themeEditorUrl/schemas/$themeName.json';
  
  // API Endpoints
  static const String authEndpoint = '$apiBasePath/auth';
  static const String worldsEndpoint = '$apiBasePath/worlds';
  static const String themesEndpoint = '$apiBasePath/themes';
  
  // App Configuration
  static const String appName = 'Weltenwind';
  static const String appVersion = '1.0.0';
  
  // Theme Configuration
  static const String themeDefault = 'default';
  static const String themeFallback = 'default';
  
  // Localization
  static const String defaultLocale = 'de';
  static const List<String> supportedLocales = ['de', 'en'];
  
  // Storage Keys
  static const String tokenKey = 'auth_token';
  static const String refreshTokenKey = 'refresh_token';
  static const String userIdKey = 'user_id';
  static const String currentWorldKey = 'current_world';
  static const String currentThemeKey = 'current_theme';
  static const String themeModeKey = 'theme_mode';
  
  static Future<void> initialize() async {
    // Future: Load from environment variables or config files
  }
} 