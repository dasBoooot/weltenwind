import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../config/logger.dart';
import 'page_preloaders.dart';
import '../../core/services/auth_service.dart';

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
  
  /// 🚀 Smart goNamed - Mit Context-Aware Theme Preloading + Auth Check
  static Future<void> goNamed(
    BuildContext context,
    String routeName, {
    Map<String, String>? pathParameters,
    Map<String, dynamic>? queryParameters,
    Object? extra,
    bool forcePreload = false,
    bool skipPreloading = false,
    String? customLoadingText,
    bool skipAuthCheck = false,
  }) async {
    
    AppLogger.navigation.i('🧠 SmartNavigation.goNamed: $routeName');
    
    try {
      // 🔐 1. AUTH CHECK: Prüfe Authentication für geschützte Routen
      if (!skipAuthCheck && await _requiresAuth(routeName)) {
        final authValid = await _validateAuth(context, routeName);
        if (!authValid) {
          AppLogger.navigation.w('🔒 Auth failed for $routeName, redirecting to login');
          context.goNamed('login', extra: {'redirectAfterLogin': routeName, 'redirectParams': pathParameters});
          return;
        }
      }
      // 1. Context-Detection: DEAKTIVIERT - AppScaffold übernimmt Theme-Handling
      // final themeContext = await detectThemeContext(routeName, pathParameters ?? {});
      AppLogger.navigation.i('🎨 [SMART-NAV-DISABLED] Theme context handling delegated to AppScaffold');
      final themeContext = const ThemeContext(contextId: 'disabled', bundleId: 'disabled');
      
      // 2. Prüfe ob Preloading für diese Route verfügbar ist
      if (!skipPreloading && _shouldUsePreloading(routeName, forcePreload)) {
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
      'login', 'register',
      'forgot-password', 'reset-password',
    };
    
    return preloadableRoutes.contains(routeName);
  }
  
  /// 🎨 Public: Theme Context Detection - DEAKTIVIERT
  /// ⚠️ VOLLSTÄNDIG ENTFERNT: AppScaffold übernimmt komplettes Theme-Handling
  @Deprecated('Theme context detection moved to AppScaffold architecture')
  static Future<ThemeContext> detectThemeContext(String routeName, Map<String, String> pathParameters) async {
    AppLogger.navigation.w('🚫 [DEPRECATED] detectThemeContext called - should use AppScaffold instead');
    return const ThemeContext(
      contextId: 'deprecated',
      bundleId: 'deprecated',
    );
  }
  
  /// 🌍 Private: World Theme aus World ID laden - DEAKTIVIERT
  @Deprecated('Theme loading moved to individual pages via AppScaffold')
  static Future<String?> _getWorldTheme(String? worldId) async {
    AppLogger.navigation.w('🚫 [DEPRECATED] _getWorldTheme called - should use page-level theme resolution');
    return null;
  }

  /// 🛡️ Simple fallback: Bundle-Name zu Theme-Name - DEAKTIVIERT
  @Deprecated('Theme loading moved to individual pages via AppScaffold')
  static String _getBundleFallbackTheme(String bundleOrTheme) {
    AppLogger.navigation.w('🚫 [DEPRECATED] _getBundleFallbackTheme called - should use page-level theme resolution');
    return 'default';
  }
  
  /// 🎮 Private: Aktive World Theme laden - DEAKTIVIERT
  @Deprecated('Theme loading moved to individual pages via AppScaffold')
  static Future<String?> _getActiveWorldTheme() async {
    AppLogger.navigation.w('🚫 [DEPRECATED] _getActiveWorldTheme called - should use page-level theme resolution');
    return null;
  }
  
  /// 💌 Private: World Theme aus Invite-Parametern laden - DEAKTIVIERT
  @Deprecated('Theme loading moved to individual pages via AppScaffold')
  static Future<String?> _getInviteWorldTheme(Map<String, String> pathParameters) async {
    AppLogger.navigation.w('🚫 [DEPRECATED] _getInviteWorldTheme called - should use page-level theme resolution');
    return null;
  }
  
  /// 🔐 Private: Prüfe ob Route Authentication benötigt
  static Future<bool> _requiresAuth(String routeName) async {
    const protectedRoutes = {
      'world-list', 'worldList',
      'world-dashboard', 'dashboard', 'worldDashboard',
      'world-join', 'worldJoin',
      'profile', 'settings',
    };
    return protectedRoutes.contains(routeName);
  }
  
  /// 🔐 Private: Validiere Authentication
  static Future<bool> _validateAuth(BuildContext context, String routeName) async {
    try {
      final authService = AuthService();
      final isLoggedIn = await authService.isLoggedIn();
      
      if (!isLoggedIn) {
        AppLogger.navigation.i('🔒 User not authenticated for $routeName');
        return false;
      }
      
      // TODO: Erweiterte Permission-Checks für spezielle Routen
      // if (routeName.contains('admin')) {
      //   return await authService.hasPermission('admin.access');
      // }
      
      return true;
    } catch (e) {
      AppLogger.navigation.e('❌ Auth validation failed', error: e);
      return false;
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
      case 'login':
        preloader = () => PagePreloaders.preloadLoginPage();
        break;
      case 'register':
        preloader = () => PagePreloaders.preloadRegisterPage();
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
    bool skipPreloading = false,
    String? customLoadingText,
    bool skipAuthCheck = false,
  }) async {
    return SmartNavigation.goNamed(
      this,
      routeName,
      pathParameters: pathParameters,
      queryParameters: queryParameters,
      extra: extra,
      forcePreload: forcePreload,
      skipPreloading: skipPreloading,
      customLoadingText: customLoadingText,
      skipAuthCheck: skipAuthCheck,
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