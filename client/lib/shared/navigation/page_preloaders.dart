import '../../config/logger.dart';
import '../../core/services/world_service.dart';
import '../../core/services/auth_service.dart';
import '../../core/providers/theme_context_provider.dart';
import '../../main.dart';
import 'smart_navigation.dart';

/// 📋 Page-spezifische Preload-Funktionen
/// 
/// Jede Funktion lädt alle benötigten Daten vor dem Anzeigen der Seite
class PagePreloaders {
  
  /// 🛡️ Private: Service Dependencies validieren
  static Future<void> _validateServiceDependencies() async {
    try {
      // Core Services prüfen
      ServiceLocator.get<AuthService>();
      ServiceLocator.get<WorldService>();
      ServiceLocator.get<ThemeContextProvider>();
      
      AppLogger.navigation.d('✅ All service dependencies validated');
    } catch (e) {
      AppLogger.navigation.e('❌ Service dependency validation failed', error: e);
      throw Exception('Required services not available: $e');
    }
  }
  
  /// 🏠 Landing Page Preloader - Context-Aware
  static Future<void> preloadLandingPage(ThemeContext themeContext) async {
    AppLogger.navigation.i('🔄 Preloading LandingPage with context: $themeContext');
    
    try {
      // 1. Context-spezifisches Theme laden
      await _preloadContextTheme(themeContext);
      
      AppLogger.navigation.i('✅ LandingPage preload completed');
    } catch (e) {
      AppLogger.navigation.e('❌ LandingPage preload failed', error: e);
      rethrow;
    }
  }
  
  /// 🔐 Login Page Preloader
  static Future<void> preloadLoginPage() async {
    AppLogger.navigation.i('🔄 Preloading LoginPage...');
    
    try {
      // 1. Auth themes preloaden - verwende ThemePageProvider-kompatibles Preloading
      await _preloadPageTheme('pre-game', 'pre-game-minimal');
      
      AppLogger.navigation.i('✅ LoginPage preload completed');
    } catch (e) {
      AppLogger.navigation.e('❌ LoginPage preload failed', error: e);
      rethrow;
    }
  }
  
  /// 📝 Register Page Preloader
  static Future<void> preloadRegisterPage() async {
    AppLogger.navigation.i('🔄 Preloading RegisterPage...');
    
    try {
      // 1. Auth themes preloaden - verwende ThemePageProvider-kompatibles Preloading
      await _preloadPageTheme('pre-game', 'pre-game-minimal');
      
      AppLogger.navigation.i('✅ RegisterPage preload completed');
    } catch (e) {
      AppLogger.navigation.e('❌ RegisterPage preload failed', error: e);
      rethrow;
    }
  }
  
  /// 💌 Invite Landing Page Preloader - Context-Aware
  static Future<void> preloadInviteLandingPage(String? inviteCode, ThemeContext themeContext) async {
    AppLogger.navigation.i('🔄 Preloading InviteLandingPage for invite: $inviteCode with context: $themeContext');
    
    try {
      // 1. Invite Theme (mit möglichem World-Theme) laden
      await _preloadContextTheme(themeContext);
      
      AppLogger.navigation.i('✅ InviteLandingPage preload completed');
    } catch (e) {
      AppLogger.navigation.e('❌ InviteLandingPage preload failed', error: e);
      rethrow;
    }
  }
  
  /// 🌍 World List Page Preloader - Context-Aware
  static Future<void> preloadWorldListPage(ThemeContext themeContext) async {
    AppLogger.navigation.i('🔄 Preloading WorldListPage with context: $themeContext');
    
    try {
      // 1. Service Dependencies prüfen
      await _validateServiceDependencies();
      
      final worldService = ServiceLocator.get<WorldService>();
      final authService = ServiceLocator.get<AuthService>();
      
      // 2. Auth-Status validieren mit Token-Refresh Versuch
      final isAuthenticated = await _validateAuthWithRefresh(authService);
      if (!isAuthenticated) {
        throw Exception('User not authenticated after refresh attempt');
      }
      
      // 3. Welten laden und Theme preloaden (parallel)
      final futures = <Future>[
        worldService.getWorlds(),
        _preloadContextTheme(themeContext),
      ];
      
      await Future.wait(futures);
      
      AppLogger.navigation.i('✅ WorldListPage preload completed');
    } catch (e) {
      AppLogger.navigation.e('❌ WorldListPage preload failed', error: e);
      rethrow;
    }
  }
  
  /// 🎮 Dashboard Page Preloader - Context-Aware
  static Future<void> preloadDashboardPage(ThemeContext themeContext) async {
    AppLogger.navigation.i('🔄 Preloading DashboardPage with context: $themeContext');
    
    try {
      // 1. Service Dependencies prüfen
      await _validateServiceDependencies();
      
      final authService = ServiceLocator.get<AuthService>();
      
      // 2. Auth-Status validieren
      final isAuthenticated = await _validateAuthWithRefresh(authService);
      if (!isAuthenticated) {
        throw Exception('User not authenticated after refresh attempt');
      }
      
      // 3. Dashboard Theme (mit World-Theme) laden
      await _preloadContextTheme(themeContext);
      
      // 4. Dashboard-spezifische Daten laden
      await _preloadDashboardData();
      
      AppLogger.navigation.i('✅ DashboardPage preload completed');
    } catch (e) {
      AppLogger.navigation.e('❌ DashboardPage preload failed', error: e);
      rethrow;
    }
  }
  
  /// 🚀 World Join Page Preloader - Context-Aware
  static Future<void> preloadWorldJoinPage(String? worldId, ThemeContext themeContext) async {
    AppLogger.navigation.i('🔄 Preloading WorldJoinPage for world: $worldId with context: $themeContext');
    
    try {
      // 1. Service Dependencies prüfen
      await _validateServiceDependencies();
      
      final authService = ServiceLocator.get<AuthService>();
      
      // 2. Auth-Status validieren
      final isAuthenticated = await _validateAuthWithRefresh(authService);
      if (!isAuthenticated) {
        throw Exception('User not authenticated after refresh attempt');
      }
      
      // 3. World-Join Theme (mit World-Theme) laden
      await _preloadContextTheme(themeContext);
      
      // 4. World-spezifische Daten laden
      if (worldId != null) {
        await _preloadWorldJoinData(worldId);
      }
      
      AppLogger.navigation.i('✅ WorldJoinPage preload completed');
    } catch (e) {
      AppLogger.navigation.e('❌ WorldJoinPage preload failed', error: e);
      rethrow;
    }
  }

  /// 🎨 Private: Context-Aware Theme preloaden 
  static Future<void> _preloadContextTheme(ThemeContext themeContext) async {
    try {
      final themeProvider = ServiceLocator.get<ThemeContextProvider>();
      
      AppLogger.navigation.d('🎨 Loading context theme: $themeContext');
      
      // 1. Base Bundle laden
      final cachedTheme = themeProvider.themeService.getCachedTheme(themeContext.bundleId, isDark: false);
      if (cachedTheme == null) {
        AppLogger.navigation.d('🔄 Loading base bundle: ${themeContext.bundleId}');
        final theme = await themeProvider.themeService.getBundle(themeContext.bundleId, isDark: false);
        
        if (theme != null) {
          await themeProvider.switchToBundle(themeContext.bundleId);
          AppLogger.navigation.d('✅ Base theme loaded: ${themeContext.bundleId}');
        } else {
          AppLogger.navigation.w('⚠️ Base theme load failed: ${themeContext.bundleId}');
        }
      } else {
        AppLogger.navigation.d('✅ Base theme already cached: ${themeContext.bundleId}');
      }
      
      // 2. World-spezifisches Theme laden (falls vorhanden)
      if (themeContext.worldTheme != null && themeContext.worldTheme != 'null') {
        final worldCached = themeProvider.themeService.getCachedTheme(themeContext.worldTheme!, isDark: false);
        if (worldCached == null) {
          AppLogger.navigation.d('🔄 Loading world theme: ${themeContext.worldTheme}');
          final worldTheme = await themeProvider.themeService.getBundle(themeContext.worldTheme!, isDark: false);
          
          if (worldTheme != null) {
            // World Theme hat Vorrang über Base Theme
            await themeProvider.switchToBundle(themeContext.worldTheme!);
            AppLogger.navigation.d('✅ World theme loaded and applied: ${themeContext.worldTheme}');
          } else {
            AppLogger.navigation.w('⚠️ World theme load failed: ${themeContext.worldTheme}');
          }
        } else {
          AppLogger.navigation.d('✅ World theme already cached: ${themeContext.worldTheme}');
          // World Theme reaktivieren
          await themeProvider.switchToBundle(themeContext.worldTheme!);
        }
      }
      
      AppLogger.navigation.d('✅ Context theme preload completed: $themeContext');
    } catch (e) {
      AppLogger.navigation.w('⚠️ Context theme preload failed: $themeContext', error: e);
      // Theme-Fehler nicht weiterwerfen - Fallback Theme wird verwendet
    }
  }
  
  /// 🎨 Private: Legacy Theme preloaden (für Backward Compatibility)
  static Future<void> _preloadPageTheme(String contextId, String bundleId) async {
    final themeContext = ThemeContext(contextId: contextId, bundleId: bundleId);
    await _preloadContextTheme(themeContext);
  }
  
  /// 🔐 Private: Auth Validation mit Token-Refresh Versuch
  static Future<bool> _validateAuthWithRefresh(AuthService authService) async {
    try {
      // 1. Erste Prüfung: Ist User eingeloggt?
      bool isAuthenticated = await authService.isLoggedIn();
      if (isAuthenticated) {
        AppLogger.navigation.d('✅ User already authenticated');
        return true;
      }
      
      AppLogger.navigation.i('🔄 User not authenticated, attempting token refresh...');
      
      // 2. Token-Refresh Versuch
      try {
        final refreshSuccess = await authService.refreshTokenIfNeeded();
        if (refreshSuccess) {
          AppLogger.navigation.i('✅ Token refresh successful');
          return true;
        } else {
          AppLogger.navigation.w('⚠️ Token refresh failed');
          return false;
        }
      } catch (refreshError) {
        AppLogger.navigation.w('⚠️ Token refresh threw error', error: refreshError);
        return false;
      }
      
    } catch (e) {
      AppLogger.navigation.e('❌ Auth validation failed', error: e);
      return false;
    }
  }
  
  /// 🚀 Private: World Join spezifische Daten preloaden
  static Future<void> _preloadWorldJoinData(String worldId) async {
    try {
      final worldService = ServiceLocator.get<WorldService>();
      
      // World-spezifische Daten laden (Server-Status, Player-Count, etc.)
      final futures = <Future>[
        worldService.getWorld(int.parse(worldId)),
        _preloadPlayerStatus(worldService, int.parse(worldId)),
      ];
      
      await Future.wait(futures);
      AppLogger.navigation.d('✅ World join data preload completed for world: $worldId');
    } catch (e) {
      AppLogger.navigation.w('⚠️ World join data preload failed for world: $worldId', error: e);
      // Daten-Fehler nicht weiterwerfen - UI kann damit umgehen
    }
  }
  
  /// 🎮 Private: Dashboard spezifische Daten preloaden
  static Future<void> _preloadDashboardData() async {
    try {
      // Dashboard-spezifische Daten laden (User-Status, Benachrichtigungen, etc.)
      // TODO: Implement dashboard-specific data loading
      
      AppLogger.navigation.d('✅ Dashboard data preload completed');
    } catch (e) {
      AppLogger.navigation.w('⚠️ Dashboard data preload failed', error: e);
      // Daten-Fehler nicht weiterwerfen - UI kann damit umgehen
    }
  }

  /// 🎮 Private: Player Status für World preloaden
  static Future<void> _preloadPlayerStatus(WorldService worldService, int worldId) async {
    try {
      // TODO: Implement player status loading
      AppLogger.navigation.d('✅ Player status preload completed for world: $worldId');
    } catch (e) {
      AppLogger.navigation.w('⚠️ Player status preload failed for world: $worldId', error: e);
      // Player Status-Fehler nicht weiterwerfen - UI kann damit umgehen
    }
  }
}