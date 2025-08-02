import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../config/logger.dart';
import '../services/modular_theme_service.dart';

/// 🎨 Theme Provider für Weltenwind
/// 
/// Modulares Theme System mit Bundle-Support - Clean & Modern
class ThemeProvider extends ChangeNotifier {
  static const String _themeModeKey = 'theme_mode';
  static const String _currentThemeKey = 'current_theme';
  static const String _bundleNameKey = 'bundle_name';
  
  ThemeMode _themeMode = ThemeMode.system;
  String _currentTheme = 'default'; // Neutrales Default Theme als Standard
  String _currentBundle = 'pre-game-minimal'; // Korrekte Bundle-Hyphen-Notation
  
  // 🚀 MODULARES SYSTEM - EINZIGES SYSTEM!
  final ModularThemeService _themeService = ModularThemeService();
  
  // Theme State
  ThemeData? _lightTheme;
  ThemeData? _darkTheme;
  Map<String, dynamic>? _performanceStats;

  /// Aktueller ThemeMode
  ThemeMode get themeMode => _themeMode;
  
  /// Aktueller Theme Name
  String get currentTheme => _currentTheme;
  
  /// Aktueller Bundle Name
  String get currentBundle => _currentBundle;
  
  /// Verfügbare Themes
  List<ThemeDefinition> get availableThemes {
    return _themeService.availableThemes.map((theme) => 
      ThemeDefinition(
        name: theme['name'] ?? 'Unknown',
        filename: theme['filename'] ?? theme['name']?.toString().toLowerCase().replaceAll(' ', '-') ?? 'unknown',
        description: theme['description'] ?? '',
        version: theme['version'] ?? '1.0.0',
      )
    ).toList();
  }
  
  /// Verfügbare Bundle-Konfigurationen
  Map<String, BundleConfig> get availableBundles => _themeService.bundleConfigs;
  
  /// Performance-Statistiken
  Map<String, dynamic>? get performanceStats => _performanceStats;

  /// Aktuelles Light Theme 
  ThemeData get currentLightTheme {
    return _lightTheme ?? _createFallbackTheme(Brightness.light);
  }
  
  /// Aktuelles Dark Theme
  ThemeData get currentDarkTheme {
    return _darkTheme ?? _createFallbackTheme(Brightness.dark);
  }
  
  /// Erstellt ein Fallback-Theme wenn noch keins geladen ist
  ThemeData _createFallbackTheme(Brightness brightness) {
    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFF6366F1), // Indigo
        brightness: brightness,
      ),
    );
  }
  
  /// Singleton-Instanz
  static final ThemeProvider _instance = ThemeProvider._internal();
  factory ThemeProvider() => _instance;
  ThemeProvider._internal();
  
  /// Provider initialisieren und gespeicherte Einstellungen laden
  static Future<void> initialize() async {
    final instance = ThemeProvider();
    await instance._loadSettings();
    
    // 🚀 MODULARES SYSTEM - EINZIGES SYSTEM!
    await instance._themeService.initialize();
    
    // Theme laden
    await instance._loadCurrentTheme();
    
    AppLogger.app.i('🎨 ThemeProvider (Modular) initialisiert');
  }
  
  /// Lädt das aktuelle Theme
  Future<void> _loadCurrentTheme() async {
    try {
      AppLogger.app.i('🎨 [THEME-DEBUG] Global Theme Load: $_currentTheme + $_currentBundle');
      print('🎨 [THEME-DEBUG] Global Theme Load: $_currentTheme + $_currentBundle');
      
      final lightTheme = await _themeService.loadThemeWithBundle(
        _currentTheme, 
        _currentBundle, 
        isDark: false
      );
      
      final darkTheme = await _themeService.loadThemeWithBundle(
        _currentTheme, 
        _currentBundle, 
        isDark: true
      );
      
      if (lightTheme != null && darkTheme != null) {
        _lightTheme = lightTheme;
        _darkTheme = darkTheme;
        _performanceStats = _themeService.getPerformanceStats();
        AppLogger.app.i('✅ [THEME-DEBUG] Global Theme Applied: $_currentTheme + $_currentBundle');
        print('✅ [THEME-DEBUG] Global Theme Applied: $_currentTheme + $_currentBundle');
        notifyListeners();
      } else {
        AppLogger.app.w('⚠️ [THEME-DEBUG] Global Theme FAILED: $_currentTheme + $_currentBundle');
      }
    } catch (e) {
      AppLogger.app.e('❌ [THEME-DEBUG] Global Theme ERROR: $_currentTheme', error: e);
    }
  }
  
  /// Theme Mode ändern
  Future<void> setThemeMode(ThemeMode mode) async {
    if (_themeMode == mode) return;
    
    _themeMode = mode;
    notifyListeners();
    await _saveSettings();
    
    AppLogger.app.i('🎨 ThemeMode geändert zu: ${mode.name}');
  }
  
  /// Theme Mode durchschalten (system -> light -> dark -> system)
  Future<void> cycleThemeMode() async {
    const modes = ThemeMode.values;
    final currentIndex = modes.indexOf(_themeMode);
    final nextIndex = (currentIndex + 1) % modes.length;
    await setThemeMode(modes[nextIndex]);
  }
  
  /// Theme wechseln
  Future<void> setTheme(String themeName) async {
    if (_currentTheme == themeName) return;
    
    AppLogger.app.i('🎨 [THEME-DEBUG] User Theme Switch: $themeName');
    print('🎨 [THEME-DEBUG] User Theme Switch: $themeName');
    _currentTheme = themeName;
    
    // 🎯 Globalen Theme-State für Cross-Service-Kommunikation aktualisieren
    GlobalThemeState.setCurrentTheme(themeName);
    
    await _loadCurrentTheme();
    await _saveSettings();
    
    AppLogger.app.i('✅ [THEME-DEBUG] Theme erfolgreich geändert zu: $themeName (Bundle: $_currentBundle)');
    print('✅ [THEME-DEBUG] Theme erfolgreich geändert zu: $themeName (Bundle: $_currentBundle)');
  }
  
  /// Bundle wechseln
  Future<void> setBundle(String bundleName) async {
    if (_currentBundle == bundleName) return;
    
    AppLogger.app.i('📦 Setze Bundle: $bundleName');
    _currentBundle = bundleName;
    
    await _loadCurrentTheme();
    await _saveSettings();
    
    AppLogger.app.i('✅ Bundle erfolgreich geändert zu: $bundleName');
  }
  
  /// Theme Cache leeren und neu laden
  Future<void> refreshTheme() async {
    _themeService.clearCache();
    await _loadCurrentTheme();
    AppLogger.app.i('🔄 Theme-Cache geleert und neu geladen');
  }
  
  /// Einstellungen aus SharedPreferences laden
  Future<void> _loadSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Theme Mode laden
      final themeModeString = prefs.getString(_themeModeKey);
      if (themeModeString != null) {
        _themeMode = ThemeMode.values.firstWhere(
          (mode) => mode.name == themeModeString,
          orElse: () => ThemeMode.system,
        );
      }
      
      // Aktueller Theme laden
      final currentThemeString = prefs.getString(_currentThemeKey);
      if (currentThemeString != null) {
        _currentTheme = currentThemeString;
      }
      
      // Bundle laden
      final bundleString = prefs.getString(_bundleNameKey);
      if (bundleString != null) {
        // 🎯 CLEAN STATE: Nur autoritative Bundle-Namen akzeptieren
        final validBundles = ['pre-game-minimal', 'world-preview', 'full-gaming', 'performance-optimized'];
        if (validBundles.contains(bundleString)) {
          _currentBundle = bundleString;
        } else {
          // Legacy Bundle gefunden → Clean State Reset
          print('🧹 [THEME-DEBUG] Legacy Bundle found: $bundleString → Reset to Clean State');
          await _resetToCleanState();
          return; // Early return nach Reset
        }
      }
      
      // 🎯 Globalen Theme-State für Cross-Service-Kommunikation aktualisieren
      GlobalThemeState.setCurrentTheme(_currentTheme);
      
      AppLogger.app.i('🎨 Theme-Einstellungen geladen: ${_themeMode.name}, $_currentTheme, Bundle: $_currentBundle');
    } catch (e) {
      AppLogger.app.e('❌ Fehler beim Laden der Theme-Einstellungen', error: e);
    }
  }
  
  /// Alle Einstellungen speichern
  Future<void> _saveSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_themeModeKey, _themeMode.name);
      await prefs.setString(_currentThemeKey, _currentTheme);
      await prefs.setString(_bundleNameKey, _currentBundle);
      
      AppLogger.app.d('💾 Theme-Einstellungen gespeichert');
    } catch (e) {
      AppLogger.app.e('❌ Fehler beim Speichern der Einstellungen', error: e);
    }
  }

  /// 🧹 Private: SharedPreferences Reset für Clean State
  Future<void> _resetToCleanState() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_bundleNameKey);
      await prefs.remove(_currentThemeKey);
      
      // Clean State setzen
      _currentTheme = 'default';
      _currentBundle = 'pre-game-minimal';
      
      print('🧹 [THEME-DEBUG] Reset to Clean State: $_currentTheme + $_currentBundle');
      AppLogger.app.i('🧹 Theme System auf Clean State zurückgesetzt');
      
      await _saveSettings();
    } catch (e) {
      AppLogger.app.e('❌ Fehler beim Reset zu Clean State', error: e);
    }
  }
}

/// 🎨 Theme Mode Extensions
extension ThemeModeExtensions on ThemeMode {
  /// Benutzerfreundlicher Name
  String get displayName {
    switch (this) {
      case ThemeMode.light:
        return 'Light Mode';
      case ThemeMode.dark:
        return 'Dark Mode';
      case ThemeMode.system:
        return 'System Mode';
    }
  }
  
  /// Icon für den Mode
  IconData get icon {
    switch (this) {
      case ThemeMode.light:
        return Icons.light_mode_rounded;
      case ThemeMode.dark:
        return Icons.dark_mode_rounded;
      case ThemeMode.system:
        return Icons.auto_mode_rounded;
    }
  }
}

/// Theme-Definition
class ThemeDefinition {
  final String name;
  final String filename;
  final String description;
  final String version;
  
  const ThemeDefinition({
    required this.name,
    required this.filename,
    required this.description,
    required this.version,
  });
}