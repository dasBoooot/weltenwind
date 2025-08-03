import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../config/logger.dart';
import 'page_preloaders.dart';
import '../../core/services/world_service.dart';
import '../../main.dart';

/// 🎨 Theme Context Information
class ThemeContext {
  final String contextId;
  final String bundleId;
  final String? worldTheme;
  
  const ThemeContext({
    required this.contextId,
    required this.bundleId,
    this.worldTheme,
  });
  
  @override
  String toString() => 'ThemeContext($contextId → $bundleId${worldTheme != null ? ' + $worldTheme' : ''})';
}

/// 🧠 Smart Context-Aware Navigation Helper
/// 
/// Zentrale Navigation-Logik mit intelligenter Theme-Context-Detection
class SmartNavigation {
  
  /// 🚀 Smart goNamed - Mit Context-Aware Theme Preloading
  static Future<void> goNamed(
    BuildContext context,
    String routeName, {
    Map<String, String>? pathParameters,
    Map<String, dynamic>? queryParameters,
    Object? extra,
    bool forcePreload = false,
    String? customLoadingText,
  }) async {
    
    AppLogger.navigation.i('🧠 SmartNavigation.goNamed: $routeName');
    
    try {
      // 1. Context-Detection: Welcher Theme-Context wird benötigt?
      final themeContext = await _detectThemeContext(routeName, pathParameters ?? {});
      AppLogger.navigation.i('🎨 Detected theme context: ${themeContext.contextId} → ${themeContext.bundleId}');
      
      // 2. Prüfe ob Preloading für diese Route verfügbar ist
      if (_shouldUsePreloading(routeName, forcePreload)) {
        AppLogger.navigation.i('✨ Using context-aware preloading for: $routeName');
        await _navigateWithContextAwarePreloading(
          context, 
          routeName, 
          pathParameters ?? {}, 
          themeContext,
          customLoadingText,
        );
      } else {
        AppLogger.navigation.i('⚡ Direct navigation for: $routeName');
        context.goNamed(routeName, pathParameters: pathParameters ?? {}, queryParameters: queryParameters ?? {}, extra: extra);
      }
      
    } catch (e) {
      AppLogger.navigation.e('❌ SmartNavigation failed for $routeName', error: e);
      // Fallback zu direkter Navigation
      context.goNamed(routeName, pathParameters: pathParameters ?? {}, queryParameters: queryParameters ?? {}, extra: extra);
    }
  }
  
  /// 🚀 Smart go - Mit automatischem Preloading falls verfügbar  
  static Future<void> go(
    BuildContext context,
    String location, {
    Object? extra,
    bool forcePreload = false,
    String? customLoadingText,
  }) async {
    
    AppLogger.navigation.i('🧠 SmartNavigation.go: $location');
    
    try {
      // 1. Route-Name aus Location extrahieren
      final routeName = _extractRouteNameFromLocation(location);
      final pathParameters = _extractPathParametersFromLocation(location);
      
      if (routeName != null) {
        // 2. Delegiere an goNamed mit extrahierten Parametern
        await goNamed(
          context, 
          routeName, 
          pathParameters: pathParameters,
          extra: extra,
          forcePreload: forcePreload,
          customLoadingText: customLoadingText,
        );
      } else {
        AppLogger.navigation.i('⚡ Direct go navigation for: $location');
        context.go(location, extra: extra);
      }
      
    } catch (e) {
      AppLogger.navigation.e('❌ SmartNavigation.go failed for $location', error: e);
      // Fallback zu direkter Navigation
      context.go(location, extra: extra);
    }
  }
  
  /// 🔍 Private: Route-Name aus location extrahieren
  static String? _extractRouteNameFromLocation(String location) {
    // Einfache Mapping-Logik - kann erweitert werden
    if (location.startsWith('/')) {
      final segments = location.split('/');
      if (segments.length >= 2) {
        switch (segments[1]) {
          case 'login':
            return 'login';
          case 'register':
            return 'register';
          case 'worlds':
            if (segments.length >= 3) {
              return 'worldList';
            }
            return 'worldList';
          case 'dashboard':
            return 'dashboard';
          case 'landing':
            return 'landing';
          case 'invite':
            return 'inviteLanding';
        }
      }
    }
    
    if (location.contains('/join')) {
      return 'worldJoin'; // /go/worlds/:id/join
    }
    
    return null; // Unbekannte Route
  }
  
  /// 🔍 Private: Path-Parameter aus location extrahieren  
  static Map<String, String> _extractPathParametersFromLocation(String location) {
    final params = <String, String>{};
    
    // Einfache Extraktion für world ID
    final segments = location.split('/');
    if (segments.length >= 4 && segments[2] == 'worlds') {
      final worldId = segments[3];
      if (worldId.isNotEmpty && worldId != 'join') {
        params['id'] = worldId;
      }
    }
    
    return params;
  }
  
  /// 🎯 Private: Sollte Preloading verwendet werden?
  static bool _shouldUsePreloading(String routeName, bool forcePreload) {
    if (forcePreload) return true;
    
    // Liste der Routen die Preloading unterstützen
    const preloadableRoutes = {
      'worldList', 'world-list',
      'dashboard', 'world-dashboard',
      'worldJoin', 'world-join',
      'landing',
      'inviteLanding', 'invite-landing',
    };
    
    return preloadableRoutes.contains(routeName);
  }
  
  /// 🎨 Private: Theme Context Detection - Intelligente Theme-Auswahl
  static Future<ThemeContext> _detectThemeContext(String routeName, Map<String, String> pathParameters) async {
    try {
      switch (routeName) {
        case 'landing':
          return const ThemeContext(
            contextId: 'pre-game',
            bundleId: 'pre-game-minimal',
          );
          
        case 'login':
        case 'register':
        case 'forgotPassword':
        case 'resetPassword':
          return const ThemeContext(
            contextId: 'auth',
            bundleId: 'pre-game-minimal',
          );
          
        case 'worldList':
        case 'world-list': // Backward compatibility
          return const ThemeContext(
            contextId: 'world-selection',
            bundleId: 'world-preview',
          );
          
        case 'worldJoin':
        case 'world-join': // Backward compatibility
          // World-spezifisches Theme aus Parameter laden
          final worldId = pathParameters['worldId'] ?? pathParameters['id'];
          final worldTheme = await _getWorldTheme(worldId);
          
          return ThemeContext(
            contextId: 'world-join',  
            bundleId: 'world-preview',
            worldTheme: worldTheme,
          );
          
        case 'dashboard':
        case 'world-dashboard': // Backward compatibility
          // Aktuell aktive World aus Service laden
          final activeWorldTheme = await _getActiveWorldTheme();
          
          return ThemeContext(
            contextId: 'in-game',
            bundleId: 'dashboard-base',
            worldTheme: activeWorldTheme,
          );
          
        case 'inviteLanding':
        case 'invite-landing': // Backward compatibility  
          final inviteWorldTheme = await _getInviteWorldTheme(pathParameters);
          
          return ThemeContext(
            contextId: 'pre-game',
            bundleId: 'pre-game-minimal',
            worldTheme: inviteWorldTheme,
          );
          
        default:
          return const ThemeContext(
            contextId: 'universal',
            bundleId: 'pre-game-minimal',
          );
      }
    } catch (e) {
      AppLogger.navigation.w('⚠️ Theme context detection failed for $routeName', error: e);
      return const ThemeContext(
        contextId: 'universal',
        bundleId: 'pre-game-minimal',
      );
    }
  }
  
  /// 🌍 Private: World Theme aus World ID laden
  static Future<String?> _getWorldTheme(String? worldId) async {
    if (worldId == null) return null;
    
    try {
      final worldService = ServiceLocator.get<WorldService>();
      final world = await worldService.getWorld(int.parse(worldId));
      return world.themeBundle;
    } catch (e) {
      AppLogger.navigation.w('⚠️ Failed to load world theme for $worldId', error: e);
      return null;
    }
  }
  
  /// 🎮 Private: Aktive World Theme laden  
  static Future<String?> _getActiveWorldTheme() async {
    try {
      // TODO: Implement getCurrentWorld method in WorldService
      return null;
    } catch (e) {
      AppLogger.navigation.w('⚠️ Failed to load active world theme', error: e);
      return null;
    }
  }
  
  /// 💌 Private: World Theme aus Invite-Parametern laden
  static Future<String?> _getInviteWorldTheme(Map<String, String> pathParameters) async {
    final inviteCode = pathParameters['inviteCode'];
    if (inviteCode == null) return null;
    
    try {
      // TODO: Implement invite service integration
      return null;
    } catch (e) {
      AppLogger.navigation.w('⚠️ Failed to load invite world theme for $inviteCode', error: e);
      return null;
    }
  }
  
  /// 🚀 Private: Navigation mit Context-Aware Preloading
  static Future<void> _navigateWithContextAwarePreloading(
    BuildContext context,
    String routeName,
    Map<String, String> pathParameters,
    ThemeContext themeContext,
    String? customLoadingText,
  ) async {
    Future<void> Function()? preloader;
    
    switch (routeName) {
      case 'landing':
        preloader = () => PagePreloaders.preloadLandingPage(themeContext);
        break;
      case 'worldList':
      case 'world-list':
        preloader = () => PagePreloaders.preloadWorldListPage(themeContext);
        break;
      case 'worldJoin':
      case 'world-join':
        preloader = () => PagePreloaders.preloadWorldJoinPage(pathParameters['worldId'] ?? pathParameters['id'], themeContext);
        break;
      case 'dashboard':
      case 'world-dashboard':
        preloader = () => PagePreloaders.preloadDashboardPage(themeContext);
        break;
      case 'inviteLanding':
      case 'invite-landing':
        preloader = () => PagePreloaders.preloadInviteLandingPage(pathParameters['inviteCode'], themeContext);
        break;
    }
    
    if (preloader != null) {
      try {
        // Preloader ausführen
        await preloader();
        // Navigation nach erfolgreichem Preloading
        context.goNamed(routeName, pathParameters: pathParameters);
      } catch (e) {
        AppLogger.navigation.w('⚠️ Preloading failed, falling back to direct navigation', error: e);
        context.goNamed(routeName, pathParameters: pathParameters);
      }
    } else {
      context.goNamed(routeName, pathParameters: pathParameters);
    }
  }
}

/// 🔧 Extension für bequemere Verwendung
extension SmartNavigationExtension on BuildContext {
  
  /// 🧠 Smart Navigation Extension
  Future<void> smartGoNamed(
    String routeName, {
    Map<String, String>? pathParameters,
    Map<String, dynamic>? queryParameters,
    Object? extra,
    bool forcePreload = false,
    String? customLoadingText,
  }) async {
    return SmartNavigation.goNamed(
      this,
      routeName,
      pathParameters: pathParameters,
      queryParameters: queryParameters,
      extra: extra,
      forcePreload: forcePreload,
      customLoadingText: customLoadingText,
    );
  }
  
  /// 🧠 Smart Go Extension
  Future<void> smartGo(
    String location, {
    Object? extra,
    bool forcePreload = false,
    String? customLoadingText,
  }) async {
    return SmartNavigation.go(
      this,
      location,
      extra: extra,
      forcePreload: forcePreload,
      customLoadingText: customLoadingText,
    );
  }
}