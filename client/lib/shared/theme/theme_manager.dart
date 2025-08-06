library;
import 'package:flutter/material.dart';
import '../../config/logger.dart';
import '../../core/models/world.dart';
import '../../core/infrastructure/app_exception.dart';
import '../../core/infrastructure/performance_monitor.dart';
import 'theme_resolver.dart';
import 'theme_cache.dart';

class ThemeManager extends ChangeNotifier {
  static final ThemeManager _instance = ThemeManager._internal();
  factory ThemeManager() => _instance;
  ThemeManager._internal();

  final ThemeResolver _resolver = ThemeResolver();
  final ThemeCache _cache = ThemeCache();
  
  // Current theme state
  World? _currentWorld;
  ThemeData? _currentLightTheme;
  ThemeData? _currentDarkTheme;
  bool _isDarkMode = false;
  String? _userPreferredVariant;
  
  // Performance tracking
  final PerformanceMonitor _performance = PerformanceMonitor();

  /// Current world (if any)
  World? get currentWorld => _currentWorld;
  
  /// Current light theme
  ThemeData get currentLightTheme => 
      _currentLightTheme ?? _getSystemFallbackTheme(false);
  
  /// Current dark theme
  ThemeData get currentDarkTheme => 
      _currentDarkTheme ?? _getSystemFallbackTheme(true);
  
  /// Current active theme (based on dark mode setting)
  ThemeData get currentTheme => 
      _isDarkMode ? currentDarkTheme : currentLightTheme;
  
  /// Whether dark mode is currently active
  bool get isDarkMode => _isDarkMode;
  
  /// User's preferred theme variant
  String? get userPreferredVariant => _userPreferredVariant;

  /// Initialize theme manager
  static Future<void> initialize() async {
    final manager = ThemeManager();
    await manager._initialize();
    AppLogger.app.i('🎨 Theme Manager initialized');
  }

  Future<void> _initialize() async {
    try {
      // Initialize cache
      await _cache.initialize();
      
      // Load system theme preference
      await _loadSystemPreferences();
      
      // Set initial fallback themes
      _currentLightTheme = _getSystemFallbackTheme(false);
      _currentDarkTheme = _getSystemFallbackTheme(true);
      
      AppLogger.app.d('🎨 Theme Manager initialization complete');
    } catch (e) {
      AppLogger.app.e('❌ Theme Manager initialization failed');
      throw ThemeException(
        'Theme Manager initialization failed',
        context: {'error': e.toString()},
        themeErrorType: ThemeErrorType.themeLoadFailed,
      );
    }
  }

  /// Set theme for specific world
  Future<void> setWorldTheme(World world, {bool forceReload = false, String context = 'pre-game'}) async {
    return _performance.timeOperation('setWorldTheme', () async {
      try {
        AppLogger.app.i('🎨 Setting theme for world: ${world.name} (${world.id}) in context: $context');

        // Check if world changed or force reload
        if (_currentWorld?.id == world.id && !forceReload) {
          AppLogger.app.d('🎯 World theme already loaded, skipping');
          return;
        }

        _currentWorld = world;

        // Resolve themes for both light and dark modes using Named Entrypoints
        final lightTheme = await _resolver.resolveWorldTheme(
          world,
          isDarkMode: false,
          userPreferredVariant: _userPreferredVariant,
          context: context,
        );

        final darkTheme = await _resolver.resolveWorldTheme(
          world,
          isDarkMode: true,
          userPreferredVariant: _userPreferredVariant,
          context: context,
        );

        // Cache the themes
        final cacheKey = world.id.toString();
        await _cache.cacheTheme('${cacheKey}_light', lightTheme);
        await _cache.cacheTheme('${cacheKey}_dark', darkTheme);

        // Update current themes
        _currentLightTheme = lightTheme;
        _currentDarkTheme = darkTheme;

        // Notify listeners
        notifyListeners();

        AppLogger.app.i('✅ World theme set successfully');
        _performance.incrementCounter('world_theme_changes');

      } catch (e) {
        AppLogger.app.e('❌ Failed to set world theme');
        
        // Use fallback themes on error
        _currentLightTheme = _getSystemFallbackTheme(false);
        _currentDarkTheme = _getSystemFallbackTheme(true);
        notifyListeners();

        throw ThemeException(
          'Failed to set world theme',
          context: {
            'worldId': world.id,
            'worldName': world.name,
            'error': e.toString(),
          },
          themeErrorType: ThemeErrorType.themeLoadFailed,
        );
      }
    });
  }

  /// Clear world theme (back to default)
  Future<void> clearWorldTheme() async {
    try {
      AppLogger.app.i('🎨 Clearing world theme');

      _currentWorld = null;
      _currentLightTheme = _getSystemFallbackTheme(false);
      _currentDarkTheme = _getSystemFallbackTheme(true);

      notifyListeners();

      AppLogger.app.i('✅ World theme cleared');
    } catch (e) {
      AppLogger.app.e('❌ Failed to clear world theme');
    }
  }

  /// Set dark mode preference
  Future<void> setDarkMode(bool isDark) async {
    if (_isDarkMode != isDark) {
      _isDarkMode = isDark;
      notifyListeners();
      
      // TODO: Save to preferences
      AppLogger.app.i('🌙 Dark mode ${isDark ? 'enabled' : 'disabled'}');
      _performance.incrementCounter('dark_mode_toggles');
    }
  }

  /// Set user's preferred theme variant
  Future<void> setPreferredVariant(String? variant) async {
    if (_userPreferredVariant != variant) {
      _userPreferredVariant = variant;
      
      // Reload current world theme with new variant
      if (_currentWorld != null) {
        await setWorldTheme(_currentWorld!, forceReload: true);
      }
      
      // TODO: Save to preferences
      AppLogger.app.i('🎭 Theme variant set to: $variant');
    }
  }

  /// Preload themes for worlds (performance optimization)
  Future<void> preloadWorldThemes(List<World> worlds) async {
    return _performance.timeOperation('preloadWorldThemes', () async {
      try {
        AppLogger.app.d('🚀 Preloading themes for ${worlds.length} worlds');

        for (final world in worlds) {
          try {
            // Check if already cached
            final cacheKey = world.id.toString();
            if (_cache.hasTheme('${cacheKey}_light') && 
                _cache.hasTheme('${cacheKey}_dark')) {
              continue; // Already cached
            }

            // Resolve and cache themes
            final lightTheme = await _resolver.resolveWorldTheme(
              world,
              isDarkMode: false,
              userPreferredVariant: _userPreferredVariant,
            );

            final darkTheme = await _resolver.resolveWorldTheme(
              world,
              isDarkMode: true,
              userPreferredVariant: _userPreferredVariant,
            );

            await _cache.cacheTheme('${cacheKey}_light', lightTheme);
            await _cache.cacheTheme('${cacheKey}_dark', darkTheme);

            _performance.incrementCounter('themes_preloaded');

          } catch (e) {
            AppLogger.app.w('⚠️ Failed to preload theme for world ${world.id}', error: e);
            // Continue with other worlds
          }
        }

        AppLogger.app.d('✅ Theme preloading complete');
      } catch (e) {
        AppLogger.app.e('❌ Theme preloading failed');
      }
    });
  }

  /// Get available theme bundles
  Future<List<Map<String, dynamic>>> getAvailableBundles() async {
    try {
      // TODO: Load from API/storage
      // For now, return hardcoded list
      return [
        {
          'id': 'default',
          'name': 'Default',
          'description': 'Standard app theme',
          'category': 'system',
        },
        {
          'id': 'cyberpunk',
          'name': 'Cyberpunk',
          'description': 'Neon-lit cyber future',
          'category': 'sci-fi',
        },
        {
          'id': 'fantasy',
          'name': 'Fantasy',
          'description': 'Medieval fantasy world',
          'category': 'fantasy',
        },
      ];
    } catch (e) {
      AppLogger.app.e('❌ Failed to get available bundles');
      return [];
    }
  }

  /// Get theme performance metrics
  Map<String, dynamic> getThemeMetrics() {
    final performanceMetrics = _performance.getCurrentMetrics();
    final cacheMetrics = _cache.getMetrics();

    return {
      'current_world': _currentWorld?.id,
      'dark_mode': _isDarkMode,
      'preferred_variant': _userPreferredVariant,
      'performance': performanceMetrics,
      'cache': cacheMetrics,
    };
  }

  /// Clear all theme caches
  Future<void> clearAllCaches() async {
    await _cache.clearAll();
    _resolver.clearCache();
    AppLogger.app.i('🗑️ All theme caches cleared');
  }

  /// Load system preferences
  Future<void> _loadSystemPreferences() async {
    try {
      // TODO: Load from SharedPreferences
      // For now, detect system dark mode
      _isDarkMode = _getSystemDarkMode();
      
      AppLogger.app.d('🎨 System preferences loaded: darkMode=$_isDarkMode');
    } catch (e) {
      AppLogger.app.e('❌ Failed to load system preferences', error: e);
    }
  }

  /// Get system dark mode preference
  bool _getSystemDarkMode() {
    // TODO: Implement proper system dark mode detection
    // For now, return false (light mode default)
    return false;
  }

  /// Get system fallback theme
  ThemeData _getSystemFallbackTheme(bool isDark) {
    // For now, return a simple fallback theme
    // The ThemeResolver will handle proper theme loading when needed
    return ThemeData(
      useMaterial3: true,
      brightness: isDark ? Brightness.dark : Brightness.light,
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFF6366F1), // Indigo
        brightness: isDark ? Brightness.dark : Brightness.light,
      ),
    );
  }



  @override
  void dispose() {
    _cache.dispose();
    super.dispose();
  }
}