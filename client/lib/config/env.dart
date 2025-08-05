class Env {
  static const String apiUrl = 'https://192.168.2.168';
  static const String apiBasePath = '/api';
  
  // Client/Frontend URL (für Invite-Links und Web-Routing)
  static const String clientUrl = 'https://192.168.2.168/game';
  
  // ✅ Static Assets (nginx-proxied, über HTTPS)
  static const String themeEditorUrl = '$apiUrl/theme-editor';
  static const String bundleConfigsUrl = '$themeEditorUrl/bundles/bundle-configs.json';
  
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
  
  // Storage Keys
  static const String tokenKey = 'auth_token';
  static const String refreshTokenKey = 'refresh_token';
  static const String userIdKey = 'user_id';
  static const String currentWorldKey = 'current_world';
  
  static Future<void> initialize() async {
    // Future: Load from environment variables or config files
  }
} 