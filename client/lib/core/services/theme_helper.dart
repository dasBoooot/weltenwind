import 'package:flutter/material.dart';
import '../providers/theme_root_provider.dart';
import '../providers/theme_page_provider.dart';
import 'modular_theme_service.dart';
import '../../config/logger.dart';

/// 🎯 Theme Helper - Zentraler Theme-Zugriff für Mixed-Context Scenarios
/// 
/// Diese Helper-Klasse stellt die zentrale API für Theme-Zugriff bereit,
/// wie vom User spezifiziert: `ModularThemeService.getCurrentTheme(context)`
/// 
/// Sie implementiert die Prioritäten-Logik:
/// 1. Component-Level Context-Overrides (ThemeContextConsumer)
/// 2. Page-Level Context (ThemePageProvider)
/// 3. Global Context (ThemeRootProvider)
/// 4. Flutter Default Theme
class ThemeHelper {
  static final ModularThemeService _themeService = ModularThemeService();
  
  /// 🔧 Public getter für ThemeService (für externe Zugriffe)
  static ModularThemeService get themeService => _themeService;

  /// 🎨 Get Current Theme basierend auf Context-Hierarchie
  /// 
  /// Dies ist die Hauptmethode, die in Mixed-Context Scenarios verwendet wird
  /// statt `Theme.of(context)`. Sie berücksichtigt die vollständige
  /// Theme-Context-Hierarchie.
  static Future<ThemeData> getCurrentTheme(
    BuildContext context, {
    bool isDark = false,
    Map<String, String>? contextOverrides,
  }) async {
    try {
      // 🔍 1. COMPONENT-LEVEL: Context-Overrides haben höchste Priorität
      if (contextOverrides != null && contextOverrides.isNotEmpty) {
        final themeData = await _getThemeFromOverrides(contextOverrides, isDark: isDark);
        if (themeData != null) {
          AppLogger.app.d('🎯 Using component-level override theme');
          return themeData;
        }
      }

      // 🔍 2. PAGE-LEVEL: ThemePageProvider Context
      final pageProvider = ThemePageProvider.of(context);
      if (pageProvider != null) {
        final themeData = await pageProvider.getTheme(isDark: isDark);
        if (themeData != null) {
          AppLogger.app.d('🎨 Using page-level theme: ${pageProvider.contextId}');
          return themeData;
        }
      }

      // 🔍 3. GLOBAL: ThemeRootProvider Context
      final rootProvider = ThemeRootProvider.of(context);
      if (rootProvider != null) {
        final themeData = await rootProvider.getTheme(isDark: isDark);
        if (themeData != null) {
          AppLogger.app.d('🌍 Using global root theme: ${rootProvider.defaultContext}');
          return themeData;
        }
      }

      // 🔄 4. FALLBACK: Flutter Default Theme
      AppLogger.app.w('⚠️ No custom theme found, using Flutter default');
      return Theme.of(context);
      
    } catch (e) {
      AppLogger.app.e('❌ Error in getCurrentTheme', error: e);
      return Theme.of(context);
    }
  }

  /// 🎨 Get Current Theme Synchronous (nur cached)
  /// Synchrone Version für bereits gecachte Themes.
  /// Gibt null zurück wenn Theme noch nicht im Cache ist.
  static ThemeData? getCurrentThemeCached(
    BuildContext context, {
    bool isDark = false,
    Map<String, String>? contextOverrides,
  }) {
    try {
      // Component-Level Overrides
      if (contextOverrides != null && contextOverrides.isNotEmpty) {
        final themeData = _getCachedThemeFromOverrides(contextOverrides, isDark: isDark);
        if (themeData != null) return themeData;
      }

      final pageProvider = ThemePageProvider.of(context);
      if (pageProvider != null) {

        final bundle = pageProvider.bundleId;
        final cachedTheme = _themeService.getCachedTheme(bundle, isDark: isDark);
        if (cachedTheme != null) return cachedTheme;
      }

      // Global Context
      final rootProvider = ThemeRootProvider.of(context);
      if (rootProvider != null) {
        final cachedTheme = _themeService.getCachedTheme(rootProvider.defaultBundle, isDark: isDark);
        if (cachedTheme != null) return cachedTheme;
      }

      // No cached theme found
      return null;
      
    } catch (e) {
      AppLogger.app.e('❌ Error in getCurrentThemeCached', error: e);
      return null;
    }
  }

  /// 📦 Get Available Bundles für aktuellen Context
  static List<String> getAvailableBundles(BuildContext context) {
    try {
      // Hardcoded Liste der verfügbaren Bundles (aus bundle-configs.json)
      return ['pre-game-minimal', 'world-preview', 'full-gaming', 'performance-optimized'];
    } catch (e) {
      AppLogger.app.e('❌ Error getting available bundles', error: e);
      return ['pre-game-minimal', 'world-preview', 'full-gaming', 'performance-optimized'];
    }
  }

  /// 🎯 Private: Theme von Context-Overrides laden
  static Future<ThemeData?> _getThemeFromOverrides(
    Map<String, String> overrides, {
    bool isDark = false,
  }) async {
    try {
      // Implementiere Context-Override Logik
      // Für jetzt vereinfacht: nehme den ersten Override
      final firstOverride = overrides.values.first;
      return await _themeService.getBundle(firstOverride, isDark: isDark);
    } catch (e) {
      AppLogger.app.e('❌ Error loading theme from overrides', error: e);
      return null;
    }
  }

  /// 🎯 Private: Cached Theme von Context-Overrides
  static ThemeData? _getCachedThemeFromOverrides(
    Map<String, String> overrides, {
    bool isDark = false,
  }) {
    try {
      final firstOverride = overrides.values.first;
      return _themeService.getCachedTheme(firstOverride, isDark: isDark);
    } catch (e) {
      AppLogger.app.e('❌ Error getting cached theme from overrides', error: e);
      return null;
    }
  }
}