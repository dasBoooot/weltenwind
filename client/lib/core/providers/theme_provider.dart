import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../theme/fantasy_theme.dart';
import '../../config/logger.dart';

/// 🎨 Theme Provider für Weltenwind
/// 
/// Verwaltet ThemeMode und Fantasy-Style-Presets global
class ThemeProvider extends ChangeNotifier {
  static const String _themeModeKey = 'theme_mode';
  static const String _stylePresetKey = 'fantasy_style_preset';
  
  ThemeMode _themeMode = ThemeMode.system;
  FantasyStylePreset _stylePreset = FantasyStylePreset.mystical;
  
  /// Aktueller ThemeMode
  ThemeMode get themeMode => _themeMode;
  
  /// Aktuelles Fantasy-Style-Preset
  FantasyStylePreset get stylePreset => _stylePreset;
  
  /// Singleton-Instanz
  static final ThemeProvider _instance = ThemeProvider._internal();
  factory ThemeProvider() => _instance;
  ThemeProvider._internal();
  
  /// Provider initialisieren und gespeicherte Einstellungen laden
  static Future<void> initialize() async {
    final instance = ThemeProvider();
    await instance._loadSettings();
    AppLogger.app.i('🎨 ThemeProvider initialisiert');
  }
  
  /// Theme Mode ändern
  Future<void> setThemeMode(ThemeMode mode) async {
    if (_themeMode == mode) return;
    
    _themeMode = mode;
    notifyListeners();
    await _saveThemeMode();
    
    AppLogger.app.i('🎨 ThemeMode geändert zu: ${mode.name}');
  }
  
  /// Fantasy Style Preset ändern
  Future<void> setStylePreset(FantasyStylePreset preset) async {
    if (_stylePreset == preset) return;
    
    _stylePreset = preset;
    notifyListeners();
    await _saveStylePreset();
    
    AppLogger.app.i('🎭 StylePreset geändert zu: ${preset.name}');
  }
  
  /// Theme Mode durchschalten (system -> light -> dark -> system)
  Future<void> cycleThemeMode() async {
    const modes = ThemeMode.values;
    final currentIndex = modes.indexOf(_themeMode);
    final nextIndex = (currentIndex + 1) % modes.length;
    await setThemeMode(modes[nextIndex]);
  }
  
  /// Style Preset durchschalten
  Future<void> cycleStylePreset() async {
    const presets = FantasyStylePreset.values;
    final currentIndex = presets.indexOf(_stylePreset);
    final nextIndex = (currentIndex + 1) % presets.length;
    await setStylePreset(presets[nextIndex]);
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
      
      // Style Preset laden
      final stylePresetString = prefs.getString(_stylePresetKey);
      if (stylePresetString != null) {
        _stylePreset = FantasyStylePreset.values.firstWhere(
          (preset) => preset.name == stylePresetString,
          orElse: () => FantasyStylePreset.mystical,
        );
      }
      
      AppLogger.app.i('🎨 Theme-Einstellungen geladen: ${_themeMode.name}, ${_stylePreset.name}');
    } catch (e) {
      AppLogger.app.e('❌ Fehler beim Laden der Theme-Einstellungen', error: e);
    }
  }
  
  /// Theme Mode in SharedPreferences speichern
  Future<void> _saveThemeMode() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_themeModeKey, _themeMode.name);
    } catch (e) {
      AppLogger.app.e('❌ Fehler beim Speichern des ThemeMode', error: e);
    }
  }
  
  /// Style Preset in SharedPreferences speichern
  Future<void> _saveStylePreset() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_stylePresetKey, _stylePreset.name);
    } catch (e) {
      AppLogger.app.e('❌ Fehler beim Speichern des StylePreset', error: e);
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

/// 🎭 Fantasy Style Preset Extensions für Provider
extension FantasyStylePresetProviderExtensions on FantasyStylePreset {
  /// Benutzerfreundlicher Name
  String get displayName {
    switch (this) {
      case FantasyStylePreset.mystical:
        return 'Mystical';
      case FantasyStylePreset.ancient:
        return 'Ancient';
      case FantasyStylePreset.portal:
        return 'Portal';
    }
  }
  
  /// Icon für das Preset
  IconData get icon {
    switch (this) {
      case FantasyStylePreset.mystical:
        return Icons.auto_fix_high_rounded;
      case FantasyStylePreset.ancient:
        return Icons.menu_book_rounded;
      case FantasyStylePreset.portal:
        return Icons.radio_button_unchecked_rounded;
    }
  }
  
  /// Beschreibung des Presets
  String get description {
    switch (this) {
      case FantasyStylePreset.mystical:
        return 'Magic-focused UI with glowing effects';
      case FantasyStylePreset.ancient:
        return 'Artifact-themed UI with ancient aesthetics';
      case FantasyStylePreset.portal:
        return 'Portal-themed UI for world exploration';
    }
  }
}