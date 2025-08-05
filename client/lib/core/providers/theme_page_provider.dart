import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../services/modular_theme_service.dart';
import '../../config/logger.dart';
import '../../config/env.dart';

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

  /// 🔍 Effektiver Bundle-Name (World-Theme hat Priorität) - NOW ASYNC!
  Future<String> getEffectiveBundleId() async {
    if (worldTheme != null) {
      // World-Theme zu Bundle-Name mapping (dynamic from server)
      return await _getBundleForTheme(worldTheme!);
    }
    return bundleId;
  }
  
  /// 🔍 Effektives Theme (World-Theme hat Priorität)
  String get effectiveTheme {
    return worldTheme ?? bundleId;
  }

  /// 🎨 Get Theme für aktuellen Page-Context (FIXED like ThemeContextConsumer)
  Future<ThemeData?> getTheme({bool isDark = false}) async {
    try {
      final bundle = await getEffectiveBundleId();
      final themeName = worldTheme; // Pass the specific theme name (like ThemeContextConsumer)
      
      AppLogger.app.d('🎨 Loading page theme: $contextId → bundle: $bundle, theme: $themeName (isDark: $isDark)');
      
      // ✅ FIXED: Pass themeName parameter like ThemeContextConsumer does
      return await _themeService.getBundle(bundle, themeName: themeName, isDark: isDark);
    } catch (e) {
      AppLogger.app.e('❌ Error loading page theme: $contextId', error: e);
      
      // Fallback: Return null, wird von Consumer gehandelt
      return null;
    }
  }

  /// 🎯 Private: Get Bundle for Theme Name (DYNAMIC like ThemeContextConsumer)
  Future<String> _getBundleForTheme(String themeName) async {
    try {
      // 1. Theme-Schema von Server laden (same as ThemeContextConsumer)
      final url = Env.getThemeSchemaUrl(themeName);
      final response = await http.get(Uri.parse(url));
      
      if (response.statusCode == 200) {
        final themeSchema = jsonDecode(response.body) as Map<String, dynamic>;
        
        // 2. Bundle-Name DIREKT aus Schema lesen - KEINE Mappings!
        final bundleName = themeSchema['bundle']?['name'] as String?;
        
        if (bundleName != null && bundleName.isNotEmpty) {
          AppLogger.app.d('✅ Found bundle name in schema: $themeName → $bundleName');
          return bundleName;
        }
      }
      
      // 3. Fallback falls Schema nicht geladen werden kann
      AppLogger.app.w('⚠️ Could not get bundle from schema for $themeName, using fallback');
      return 'full-gaming'; // World themes use full-gaming as fallback
      
    } catch (e) {
      AppLogger.app.w('⚠️ Error loading theme schema for $themeName', error: e);
      return 'full-gaming'; // Safe fallback for world themes
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