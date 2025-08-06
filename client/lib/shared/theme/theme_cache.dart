/// 💾 Theme Cache
/// 
/// High-performance caching system for theme data
library;

import 'package:flutter/material.dart';
import '../../config/logger.dart';

class ThemeCache {
  static final ThemeCache _instance = ThemeCache._internal();
  factory ThemeCache() => _instance;
  ThemeCache._internal();

  final Map<String, ThemeData> _themeCache = {};
  final Map<String, DateTime> _cacheTimestamps = {};
  final Map<String, int> _accessCounts = {};
  
  // Cache configuration
  static const int maxCacheSize = 50;
  static const Duration cacheExpiry = Duration(hours: 2);
  
  // Cache statistics
  int _hits = 0;
  int _misses = 0;
  int _evictions = 0;

  /// Initialize cache system
  Future<void> initialize() async {
    AppLogger.app.d('💾 Theme cache initialized');
  }

  /// Cache a theme with key
  Future<void> cacheTheme(String key, ThemeData theme) async {
    try {
      // Check cache size limit
      if (_themeCache.length >= maxCacheSize) {
        await _evictOldestEntry();
      }

      _themeCache[key] = theme;
      _cacheTimestamps[key] = DateTime.now();
      _accessCounts[key] = 0;

      AppLogger.app.d('💾 Theme cached: $key');
    } catch (e) {
      AppLogger.app.e('❌ Failed to cache theme: $key', error: e);
    }
  }

  /// Get cached theme by key
  ThemeData? getCachedTheme(String key) {
    try {
      // Check if theme exists in cache
      if (!_themeCache.containsKey(key)) {
        _misses++;
        return null;
      }

      // Check if cache entry is expired
      final timestamp = _cacheTimestamps[key];
      if (timestamp != null && DateTime.now().difference(timestamp) > cacheExpiry) {
        _removeFromCache(key);
        _misses++;
        return null;
      }

      // Update access statistics
      _hits++;
      _accessCounts[key] = (_accessCounts[key] ?? 0) + 1;

      final theme = _themeCache[key];
      if (theme != null) {
        AppLogger.app.d('💾 Theme cache hit: $key');
      }

      return theme;
    } catch (e) {
      AppLogger.app.e('❌ Failed to get cached theme: $key', error: e);
      _misses++;
      return null;
    }
  }

  /// Check if theme exists in cache
  bool hasTheme(String key) {
    return _themeCache.containsKey(key) && !_isExpired(key);
  }

  /// Remove theme from cache
  void removeTheme(String key) {
    _removeFromCache(key);
    AppLogger.app.d('💾 Theme removed from cache: $key');
  }

  /// Clear all cached themes
  Future<void> clearAll() async {
    final count = _themeCache.length;
    _themeCache.clear();
    _cacheTimestamps.clear();
    _accessCounts.clear();
    
    // Reset statistics
    _hits = 0;
    _misses = 0;
    _evictions = 0;
    
    AppLogger.app.i('💾 Theme cache cleared: $count themes removed');
  }

  /// Get cache statistics and metrics
  Map<String, dynamic> getMetrics() {
    final totalRequests = _hits + _misses;
    final hitRate = totalRequests > 0 ? (_hits / totalRequests * 100) : 0.0;

    return {
      'size': _themeCache.length,
      'maxSize': maxCacheSize,
      'hits': _hits,
      'misses': _misses,
      'hitRate': '${hitRate.toStringAsFixed(1)}%',
      'evictions': _evictions,
      'oldestEntry': _getOldestEntryAge(),
      'newestEntry': _getNewestEntryAge(),
      'topAccessedThemes': _getTopAccessedThemes(5),
    };
  }

  /// Get cache usage information
  Map<String, dynamic> getCacheUsage() {
    final now = DateTime.now();
    final entries = <Map<String, dynamic>>[];

    for (final key in _themeCache.keys) {
      final timestamp = _cacheTimestamps[key];
      final accessCount = _accessCounts[key] ?? 0;
      final age = timestamp != null ? now.difference(timestamp) : Duration.zero;

      entries.add({
        'key': key,
        'age': '${age.inMinutes}m',
        'accessCount': accessCount,
        'expired': _isExpired(key),
      });
    }

    entries.sort((a, b) => (b['accessCount'] as int).compareTo(a['accessCount'] as int));

    return {
      'entries': entries,
      'totalSize': _themeCache.length,
      'statistics': getMetrics(),
    };
  }

  /// Preload themes (warm up cache)
  Future<void> preload(Map<String, ThemeData> themes) async {
    try {
      AppLogger.app.d('💾 Preloading ${themes.length} themes');

      for (final entry in themes.entries) {
        await cacheTheme(entry.key, entry.value);
      }

      AppLogger.app.i('💾 Theme preload complete: ${themes.length} themes');
    } catch (e) {
      AppLogger.app.e('❌ Theme preload failed', error: e);
    }
  }

  /// Clean expired entries
  Future<void> cleanExpired() async {
    final expiredKeys = <String>[];
    
    for (final key in _themeCache.keys) {
      if (_isExpired(key)) {
        expiredKeys.add(key);
      }
    }

    for (final key in expiredKeys) {
      _removeFromCache(key);
    }

    if (expiredKeys.isNotEmpty) {
      AppLogger.app.i('💾 Cleaned ${expiredKeys.length} expired cache entries');
    }
  }

  /// Check if cache entry is expired
  bool _isExpired(String key) {
    final timestamp = _cacheTimestamps[key];
    if (timestamp == null) return true;
    return DateTime.now().difference(timestamp) > cacheExpiry;
  }

  /// Remove entry from all cache maps
  void _removeFromCache(String key) {
    _themeCache.remove(key);
    _cacheTimestamps.remove(key);
    _accessCounts.remove(key);
  }

  /// Evict oldest cache entry (LRU strategy)
  Future<void> _evictOldestEntry() async {
    if (_themeCache.isEmpty) return;

    // Find least recently used entry (lowest access count + oldest timestamp)
    String? oldestKey;
    int minAccessCount = 999999999;
    DateTime? oldestTime;

    for (final key in _themeCache.keys) {
      final accessCount = _accessCounts[key] ?? 0;
      final timestamp = _cacheTimestamps[key];

      if (accessCount < minAccessCount || 
          (accessCount == minAccessCount && 
           (oldestTime == null || (timestamp != null && timestamp.isBefore(oldestTime))))) {
        oldestKey = key;
        minAccessCount = accessCount;
        oldestTime = timestamp;
      }
    }

    if (oldestKey != null) {
      _removeFromCache(oldestKey);
      _evictions++;
      AppLogger.app.d('💾 Evicted cache entry: $oldestKey');
    }
  }

  /// Get age of oldest cache entry
  String _getOldestEntryAge() {
    if (_cacheTimestamps.isEmpty) return 'N/A';
    
    final now = DateTime.now();
    var oldest = _cacheTimestamps.values.first;
    
    for (final timestamp in _cacheTimestamps.values) {
      if (timestamp.isBefore(oldest)) {
        oldest = timestamp;
      }
    }
    
    final age = now.difference(oldest);
    return '${age.inMinutes}m';
  }

  /// Get age of newest cache entry
  String _getNewestEntryAge() {
    if (_cacheTimestamps.isEmpty) return 'N/A';
    
    final now = DateTime.now();
    var newest = _cacheTimestamps.values.first;
    
    for (final timestamp in _cacheTimestamps.values) {
      if (timestamp.isAfter(newest)) {
        newest = timestamp;
      }
    }
    
    final age = now.difference(newest);
    return '${age.inMinutes}m';
  }

  /// Get top accessed themes
  List<Map<String, dynamic>> _getTopAccessedThemes(int count) {
    final entries = <Map<String, dynamic>>[];
    
    for (final key in _accessCounts.keys) {
      entries.add({
        'key': key,
        'count': _accessCounts[key] ?? 0,
      });
    }
    
    entries.sort((a, b) => (b['count'] as int).compareTo(a['count'] as int));
    
    return entries.take(count).toList();
  }

  /// Dispose cache resources
  void dispose() {
    clearAll();
    AppLogger.app.d('💾 Theme cache disposed');
  }
}