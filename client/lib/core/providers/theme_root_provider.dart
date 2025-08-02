import 'package:flutter/material.dart';
import '../services/modular_theme_service.dart';
import '../../config/logger.dart';

/// 🎯 Theme Root Provider - Globaler Theme-Fallback für die gesamte App
/// 
/// Stellt den grundlegenden Theme-Context für die gesamte Anwendung bereit.
/// Dieser Provider wird einmal am App-Level eingesetzt und liefert den
/// Standard-Context für alle Child-Widgets, die keinen spezifischen 
/// Context-Override haben.
class ThemeRootProvider extends InheritedWidget {
  /// Standard-Kontext für die gesamte App
  final String defaultContext;
  
  /// Standard-Bundle für die gesamte App  
  final String defaultBundle;
  
  /// ModularThemeService für Theme-Bereitstellung
  final ModularThemeService _themeService = ModularThemeService();
  
  ThemeRootProvider({
    super.key,
    required this.defaultContext,
    required this.defaultBundle,
    required super.child,
  }) {
    AppLogger.app.i('🎯 ThemeRootProvider initialized: $defaultContext ($defaultBundle)');
  }

  /// 🔍 Aktueller globaler Theme-Context
  String get currentContext => defaultContext;
  
  /// 📦 Aktuelles globales Bundle
  String get currentBundle => defaultBundle;
  
  /// 🎨 Get Theme für aktuellen Context
  Future<ThemeData?> getTheme({bool isDark = false}) async {
    try {
      return await _themeService.getBundle(defaultBundle, isDark: isDark);
    } catch (e) {
      AppLogger.app.e('❌ Error loading root theme: $defaultBundle', error: e);
      return null;
    }
  }

  /// 🔍 Theme von Context abrufen
  static ThemeRootProvider? of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<ThemeRootProvider>();
  }
  
  /// 🔍 Theme von Context abrufen (required)
  static ThemeRootProvider ofRequired(BuildContext context) {
    final provider = of(context);
    if (provider == null) {
      throw FlutterError(
        'ThemeRootProvider.ofRequired() called with a context that does not contain a ThemeRootProvider.\n'
        'No ThemeRootProvider ancestor could be found starting from the context that was passed '
        'to ThemeRootProvider.ofRequired(). This can happen if you forgot to wrap your app with a ThemeRootProvider.\n'
        'The context used was:\n'
        '  $context'
      );
    }
    return provider;
  }

  @override
  bool updateShouldNotify(ThemeRootProvider oldWidget) {
    return defaultContext != oldWidget.defaultContext || 
           defaultBundle != oldWidget.defaultBundle;
  }
}