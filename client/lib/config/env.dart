class Env {
  // Runtime Configuration (can be overridden)
  static String? _apiUrl;
  static String? _clientUrl;
  static String? _assetUrl;
  
  // Default values (fallback)
  static const String _defaultApiUrl = 'https://192.168.2.168';
  static const String _defaultClientUrl = 'https://192.168.2.168/game';
  static const String _defaultAssetUrl = 'https://192.168.2.168';
  
  // Getters with fallback
  static String get apiUrl => _apiUrl ?? _defaultApiUrl;
  static String get clientUrl => _clientUrl ?? _defaultClientUrl;
  static String get assetUrl => _assetUrl ?? _defaultAssetUrl;
  
  // Setters for runtime configuration
  static void setApiUrl(String url) => _apiUrl = url;
  static void setClientUrl(String url) => _clientUrl = url;
  static void setAssetUrl(String url) => _assetUrl = url;
  
  // Configuration loading
  static Future<void> loadFromEnvironment() async {
    // TODO: Load from environment variables or config files
    // For now, keep defaults
  }
  
  // API Base Path
  static const String apiBasePath = '/api/v1';
  
  // ✅ Static Assets (nginx-proxied, über HTTPS)
  static String get themeEditorUrl => '$apiUrl/theme-editor';
  static String get bundleConfigsUrl => '$themeEditorUrl/bundles/bundle-configs.json';
  
  // ✅ Asset Server Configuration für modulare Welten
  static String get assetBaseUrl => '$assetUrl/assets';
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
  static String get authEndpoint => '$apiBasePath/auth';
  static String get worldsEndpoint => '$apiBasePath/worlds';
  static String get themesEndpoint => '$apiBasePath/themes';
  
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