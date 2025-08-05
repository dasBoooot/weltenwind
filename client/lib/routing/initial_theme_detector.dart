import 'package:flutter/material.dart';
import '../config/logger.dart';
import '../shared/navigation/smart_navigation.dart';
// ❌ REMOVED: Theme provider imports - AppScaffold handles themes!
// import '../core/providers/theme_context_provider.dart';
// import '../main.dart';

/// 🎨 Initial Theme Detector - F5 Refresh Protection
/// 
/// Löst das Problem, dass bei F5-Refresh (Browser) die Theme-Context-Detection
/// nicht läuft, da kein Smart Navigation ausgelöst wird.
/// 
/// Erkennt aus der aktuellen Route das benötigte Theme und setzt es
/// beim App-Start / Page-Reload.
class InitialThemeDetector {
  
  /// 🔍 Detect Theme from Current Route - F5 Refresh Safe
  static Future<void> detectAndSetThemeFromRoute(BuildContext context, String initialRoute) async {
    try {
      AppLogger.navigation.i('🎨 Initial theme detection for route: $initialRoute');
      
      // Extract route name and parameters from path
      final routeInfo = _parseRoute(initialRoute);
      if (routeInfo == null) {
        AppLogger.navigation.w('⚠️ Could not parse route: $initialRoute');
        return;
      }
      
      // Use Smart Navigation theme detection logic
      final themeContext = await SmartNavigation.detectThemeContext(
        routeInfo.routeName, 
        routeInfo.pathParameters,
      );
      
      AppLogger.navigation.i('🎯 Detected theme context: ${themeContext.contextId} → ${themeContext.bundleId}');
      
      // ❌ REMOVED: Global theme loading - AppScaffold handles themes per page!
      // final themeProvider = ServiceLocator.get<ThemeContextProvider>();
      // await themeProvider.switchToBundle(themeContext.bundleId);
      
      AppLogger.navigation.i('✅ Initial theme detection completed (AppScaffold handles actual theme loading)');
      
    } catch (e) {
      AppLogger.navigation.e('❌ Initial theme detection failed', error: e);
      // ❌ REMOVED: Global theme fallback - AppScaffold provides fallbacks per page!
      AppLogger.navigation.i('ℹ️ No global theme fallback needed - AppScaffold handles per-page themes');
    }
  }
  
  /// 🔍 Parse Route Path to extract route name and parameters
  static RouteInfo? _parseRoute(String path) {
    try {
      // Remove query parameters and fragments
      final cleanPath = path.split('?').first.split('#').first;
      final segments = cleanPath.split('/').where((s) => s.isNotEmpty).toList();
      
      if (segments.isEmpty) return null;
      
      // Handle different route patterns
      if (segments.length >= 2 && segments[0] == 'go') {
        switch (segments[1]) {
          case 'auth':
            if (segments.length >= 3) {
              return RouteInfo(
                routeName: segments[2], // login, register, etc.
                pathParameters: {},
              );
            }
            break;
            
          case 'worlds':
            if (segments.length >= 3) {
              final worldId = segments[2];
              if (segments.length >= 4 && segments[3] == 'join') {
                // /go/worlds/:id/join
                return RouteInfo(
                  routeName: 'world-join',
                  pathParameters: {'id': worldId},
                );
              } else {
                // /go/worlds/:id (dashboard)
                return RouteInfo(
                  routeName: 'world-dashboard',
                  pathParameters: {'id': worldId},
                );
              }
            } else {
              // /go/worlds (world list)
              return const RouteInfo(
                routeName: 'world-list',
                pathParameters: {},
              );
            }
            
          case 'invite':
            if (segments.length >= 3) {
              return RouteInfo(
                routeName: 'invite-landing',
                pathParameters: {'inviteCode': segments[2]},
              );
            }
            
          default:
            // /go or /go/something-else
            return const RouteInfo(
              routeName: 'landing',
              pathParameters: {},
            );
        }
      }
      
      return null;
    } catch (e) {
      AppLogger.navigation.w('⚠️ Route parsing failed for: $path', error: e);
      return null;
    }
  }
}

/// 📍 Route Information Container
class RouteInfo {
  final String routeName;
  final Map<String, String> pathParameters;
  
  const RouteInfo({
    required this.routeName,
    required this.pathParameters,
  });
  
  @override
  String toString() => 'RouteInfo($routeName, $pathParameters)';
}
