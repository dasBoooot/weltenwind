/// 🎨 Theme Service Interface
/// 
/// Defines the contract for world-based theme management
library;

import 'package:flutter/material.dart';

abstract class IThemeService {
  /// Get theme for specific world
  /// Returns ThemeData for world, fallback if world theme not found
  Future<ThemeData> getWorldTheme(int worldId, {bool isDark = false});
  
  /// Get theme bundle for world
  /// Returns theme bundle data for world
  Future<Map<String, dynamic>?> getWorldThemeBundle(int worldId);
  
  /// Load theme from theme name
  /// Returns ThemeData for named theme
  Future<ThemeData> loadTheme(String themeName, {bool isDark = false});
  
  /// Get available themes
  /// Returns list of available theme definitions
  Future<List<Map<String, dynamic>>> getAvailableThemes();
  
  /// Get available theme bundles
  /// Returns list of available theme bundles
  Future<List<Map<String, dynamic>>> getAvailableBundles();
  
  /// Cache theme data
  /// Stores theme data in local cache for performance
  Future<void> cacheTheme(String themeKey, ThemeData themeData);
  
  /// Get cached theme
  /// Returns cached theme if available, null otherwise
  ThemeData? getCachedTheme(String themeKey);
  
  /// Clear theme cache
  /// Removes all cached theme data
  Future<void> clearCache();
  
  /// Preload themes for worlds
  /// Preloads theme data for better performance
  Future<void> preloadWorldThemes(List<int> worldIds);
  
  /// Validate theme data
  /// Returns true if theme data is valid according to schema
  Future<bool> validateThemeData(Map<String, dynamic> themeData);
  
  /// Get theme metadata
  /// Returns metadata for theme (name, version, description, etc.)
  Future<Map<String, dynamic>?> getThemeMetadata(String themeName);
  
  /// Get fallback theme
  /// Returns default fallback theme when theme loading fails
  ThemeData getFallbackTheme({bool isDark = false});
  
  /// Register theme change listener
  /// Notifies when theme data changes
  void addThemeChangeListener(VoidCallback listener);
  
  /// Remove theme change listener
  void removeThemeChangelistener(VoidCallback listener);
  
  /// Get current theme performance metrics
  /// Returns performance data for theme operations
  Map<String, dynamic> getThemeMetrics();
}