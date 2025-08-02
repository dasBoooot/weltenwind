import 'package:flutter/material.dart';
import '../services/modular_theme_service.dart';
import '../../config/logger.dart';

/// 🎯 Theme Page Provider - Page-Level Theme Context
/// 
/// Stellt einen spezifischen Theme-Context für eine ganze Seite bereit.
/// Dieser Provider überschreibt den globalen Context vom ThemeRootProvider
/// und definiert das Theme für alle Child-Widgets auf dieser Seite,
/// außer sie haben einen eigenen Context-Override.
class ThemePageProvider extends InheritedWidget {
  /// Context-ID für diese Seite (z.B. 'pre-game', 'in-game', 'world-join')
  final String contextId;
  
  /// Bundle-ID für diese Seite (z.B. 'pre-game-minimal', 'full-gaming')
  final String bundleId;
  
  /// Optional: World-spezifisches Theme überschreiben
  final String? worldTheme;
  
  /// ModularThemeService für Theme-Bereitstellung
  final ModularThemeService _themeService = ModularThemeService();
  
  ThemePageProvider({
    super.key,
    required this.contextId,
    required this.bundleId,
    this.worldTheme,
    required super.child,
  }) {
    final themeInfo = worldTheme != null ? '$worldTheme (world-override)' : bundleId;
    AppLogger.app.i('🎨 ThemePageProvider initialized: $contextId → $themeInfo');
  }

  /// 🔍 Effektiver Bundle-Name (World-Theme hat Priorität)
  String get effectiveBundleId {
    if (worldTheme != null) {
      // World-Theme zu Bundle-Name mapping
      return _getBundleForTheme(worldTheme!);
    }
    return bundleId;
  }
  
  /// 🔍 Effektives Theme (World-Theme hat Priorität)
  String get effectiveTheme {
    return worldTheme ?? bundleId;
  }

  /// 🎨 Get Theme für aktuellen Page-Context
  Future<ThemeData?> getTheme({bool isDark = false}) async {
    try {
      final bundle = effectiveBundleId;
      AppLogger.app.d('🎨 Loading page theme: $contextId → $bundle (isDark: $isDark)');
      return await _themeService.getBundle(bundle, isDark: isDark);
    } catch (e) {
      AppLogger.app.e('❌ Error loading page theme: $contextId ($effectiveBundleId)', error: e);
      
      // Fallback: Return null, wird von Consumer gehandelt
      return null;
    }
  }

  /// 🎯 Private: Get Bundle for Theme Name (World-Theme Mapping)
  String _getBundleForTheme(String themeName) {
    // Theme-to-Bundle Mapping (basierend auf bundle-configs.json)
    switch (themeName) {
      case 'tolkien':
      case 'space':
      case 'roman':
      case 'nature':
      case 'cyberpunk':
        return 'full-gaming';
      case 'default':
        return 'pre-game-minimal';
      default:
        AppLogger.app.w('⚠️ Unknown theme: $themeName, using pre-game-minimal');
        return 'pre-game-minimal';
    }
  }

  /// 🔍 Theme von Context abrufen
  static ThemePageProvider? of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<ThemePageProvider>();
  }
  
  /// 🔍 Theme von Context abrufen (required)
  static ThemePageProvider ofRequired(BuildContext context) {
    final provider = of(context);
    if (provider == null) {
      throw FlutterError(
        'ThemePageProvider.ofRequired() called with a context that does not contain a ThemePageProvider.\n'
        'No ThemePageProvider ancestor could be found starting from the context that was passed '
        'to ThemePageProvider.ofRequired(). This can happen if the page does not have a ThemePageProvider.\n'
        'The context used was:\n'
        '  $context'
      );
    }
    return provider;
  }

  @override
  bool updateShouldNotify(ThemePageProvider oldWidget) {
    return contextId != oldWidget.contextId || 
           bundleId != oldWidget.bundleId ||
           worldTheme != oldWidget.worldTheme;
  }
}