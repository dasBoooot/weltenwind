import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../config/logger.dart';
import '../../shared/theme/theme_manager.dart';

/// 🎨 Theme Provider für Weltenwind
/// Integriert mit dem ThemeManager für world-basierte Themes
class ThemeProvider extends ChangeNotifier {
  static const String _themeModeKey = 'theme_mode';
  static const String _currentThemeKey = 'current_theme';
  
  ThemeMode _themeMode = ThemeMode.system;
  String _currentTheme = 'default';
  
  // ThemeManager Integration
  final ThemeManager _themeManager = ThemeManager();

  /// Aktueller ThemeMode
  ThemeMode get themeMode => _themeMode;
  
  /// Aktueller Theme Name
  String get currentTheme => _currentTheme;

  /// Aktuelles Light Theme 
  ThemeData get currentLightTheme {
    return _themeManager.currentLightTheme;
  }
  
  /// Aktuelles Dark Theme
  ThemeData get currentDarkTheme {
    return _themeManager.currentDarkTheme;
  }
  
  /// Dark Mode Status
  bool get isDarkMode => _themeManager.isDarkMode;
  
  /// Singleton-Instanz
  static final ThemeProvider _instance = ThemeProvider._internal();
  factory ThemeProvider() => _instance;
  ThemeProvider._internal();
  
  /// Provider initialisieren und gespeicherte Einstellungen laden
  static Future<void> initialize() async {
    final instance = ThemeProvider();
    
    // ThemeManager als Listener hinzufügen
    instance._themeManager.addListener(instance._onThemeManagerChanged);
    
    await instance._loadSettings();
    
    // Initial Theme Mode setzen
    await instance._applyThemeMode();
    
    // Theme Variant setzen (nur wenn nicht 'default')
    if (instance._currentTheme != 'default') {
      await instance._themeManager.setPreferredVariant(instance._currentTheme);
    }
    
    AppLogger.app.i('🎨 ThemeProvider mit ThemeManager Integration initialisiert');
  }
  
  /// Lädt gespeicherte Theme-Einstellungen
  Future<void> _loadSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Theme Mode laden
      final themeModeIndex = prefs.getInt(_themeModeKey) ?? ThemeMode.system.index;
      _themeMode = ThemeMode.values[themeModeIndex];
      
      // Aktuelles Theme laden
      _currentTheme = prefs.getString(_currentThemeKey) ?? 'default';
      
      AppLogger.app.d('🎨 ThemeManager Integration aktiv');
      
      AppLogger.app.i('🎨 Theme-Einstellungen geladen: $_themeMode, $_currentTheme');
    } catch (e) {
      AppLogger.app.e('❌ Fehler beim Laden der Theme-Einstellungen', error: e);
      // Fallback auf Standard-Werte
      _themeMode = ThemeMode.system;
      _currentTheme = 'default';
    }
  }
  
  /// Theme Mode setzen (light, dark, system)
  Future<void> setThemeMode(ThemeMode mode) async {
    if (_themeMode != mode) {
      _themeMode = mode;
      
      // ThemeManager Dark Mode entsprechend setzen
      switch (mode) {
        case ThemeMode.light:
          await _themeManager.setDarkMode(false);
          break;
        case ThemeMode.dark:
          await _themeManager.setDarkMode(true);
          break;
        case ThemeMode.system:
          // System Dark Mode verwenden
          final isDark = _getSystemDarkMode();
          await _themeManager.setDarkMode(isDark);
          break;
      }
      
      notifyListeners();
      
      try {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setInt(_themeModeKey, mode.index);
        AppLogger.app.i('🎨 Theme Mode geändert: $mode');
      } catch (e) {
        AppLogger.app.e('❌ Fehler beim Speichern des Theme Mode', error: e);
      }
    }
  }
  
  /// Theme für spezifische Welt setzen
  Future<void> setWorldTheme(String themeName) async {
    if (_currentTheme != themeName) {
      _currentTheme = themeName;
      
      // ThemeManager mit dem neuen Theme aktualisieren
      await _themeManager.setPreferredVariant(themeName);
      
      notifyListeners();
      
      try {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(_currentThemeKey, themeName);
        AppLogger.app.i('🎨 World Theme geändert: $themeName');
      } catch (e) {
        AppLogger.app.e('❌ Fehler beim Speichern des World Theme', error: e);
      }
    }
  }
  
  /// Theme Mode umschalten
  Future<void> toggleThemeMode() async {
    switch (_themeMode) {
      case ThemeMode.system:
        await setThemeMode(ThemeMode.light);
        break;
      case ThemeMode.light:
        await setThemeMode(ThemeMode.dark);
        break;
      case ThemeMode.dark:
        await setThemeMode(ThemeMode.system);
        break;
    }
  }
  
  /// Callback für ThemeManager Änderungen
  void _onThemeManagerChanged() {
    notifyListeners();
  }
  
  /// System Dark Mode erkennen
  bool _getSystemDarkMode() {
    // TODO: Implement proper system dark mode detection
    // For now, return false (light mode default)
    return false;
  }
  
  /// Theme Mode auf ThemeManager anwenden
  Future<void> _applyThemeMode() async {
    switch (_themeMode) {
      case ThemeMode.light:
        await _themeManager.setDarkMode(false);
        break;
      case ThemeMode.dark:
        await _themeManager.setDarkMode(true);
        break;
      case ThemeMode.system:
        final isDark = _getSystemDarkMode();
        await _themeManager.setDarkMode(isDark);
        break;
    }
  }
}