import 'package:flutter/material.dart';
import 'dart:async';

/// 🎮 Gaming Performance Helper for High-Frequency Updates
class GamingPerformanceHelper {
  /// Frame rate limiter for animations
  static const int targetFPS = 60;
  static const Duration frameInterval = Duration(microseconds: 16667); // ~60 FPS

  /// Throttle high-frequency updates (e.g., minimap, health bars)
  static Timer? throttledUpdate(
    Timer? existingTimer,
    Duration interval,
    VoidCallback callback,
  ) {
    existingTimer?.cancel();
    return Timer(interval, callback);
  }

  /// Debounce user input for search/filter operations
  static Timer? debouncedUpdate(
    Timer? existingTimer,
    Duration delay,
    VoidCallback callback,
  ) {
    existingTimer?.cancel();
    return Timer(delay, callback);
  }

  /// Batch entity updates for minimap/HUD
  static List<T> batchEntityUpdates<T>(
    List<T> entities,
    bool Function(T entity) shouldUpdate,
    T Function(T entity) updateFunction,
  ) {
    final updatedEntities = <T>[];
    
    for (final entity in entities) {
      if (shouldUpdate(entity)) {
        updatedEntities.add(updateFunction(entity));
      } else {
        updatedEntities.add(entity);
      }
    }
    
    return updatedEntities;
  }

  /// Optimized painter for gaming elements
  static CustomPainter createOptimizedPainter({
    required void Function(Canvas canvas, Size size) paintFunction,
    bool repaint = false,
  }) {
    return _OptimizedGamePainter(
      paintFunction: paintFunction,
      forceRepaint: repaint,
    );
  }

  /// Viewport culling for large lists (world lists, inventory)
  static List<T> cullOutOfViewport<T>({
    required List<T> items,
    required double viewportStart,
    required double viewportEnd,
    required double Function(T item) getPosition,
    required double Function(T item) getSize,
  }) {
    return items.where((item) {
      final position = getPosition(item);
      final size = getSize(item);
      return position < viewportEnd && (position + size) > viewportStart;
    }).toList();
  }

  /// Memory-efficient entity tracking
  static Map<String, T> updateEntityCache<T>({
    required Map<String, T> cache,
    required List<T> newEntities,
    required String Function(T entity) getId,
    int maxCacheSize = 1000,
  }) {
    // Clear old entries if cache is too large
    if (cache.length > maxCacheSize) {
      final sortedKeys = cache.keys.toList()..shuffle();
      final keysToRemove = sortedKeys.take(cache.length - maxCacheSize);
      for (final key in keysToRemove) {
        cache.remove(key);
      }
    }

    // Update with new entities
    for (final entity in newEntities) {
      cache[getId(entity)] = entity;
    }

    return cache;
  }

  /// Optimized color interpolation for health bars, mana bars
  static Color interpolateHealthColor(double healthPercentage, ColorScheme colorScheme) {
    // Use theme-based colors for health state
    final healthyColor = colorScheme.primary;
    final warningColor = colorScheme.tertiary;
    final criticalColor = colorScheme.secondary;
    final dangerColor = colorScheme.error;
    
    if (healthPercentage >= 0.6) {
      // Healthy to Warning (100% to 60%)
      final t = (1.0 - healthPercentage) / 0.4;
      return Color.lerp(healthyColor, warningColor, t)!;
    } else if (healthPercentage >= 0.3) {
      // Warning to Critical (60% to 30%)
      final t = (0.6 - healthPercentage) / 0.3;
      return Color.lerp(warningColor, criticalColor, t)!;
    } else {
      // Critical to Danger (30% to 0%)
      final t = (0.3 - healthPercentage) / 0.3;
      return Color.lerp(criticalColor, dangerColor, t)!;
    }
  }

  /// Efficient distance calculation for minimap
  static double fastDistance(double x1, double y1, double x2, double y2) {
    final dx = x2 - x1;
    final dy = y2 - y1;
    return dx * dx + dy * dy; // Skip sqrt for comparison-only calculations
  }

  /// Optimized visibility check for entities
  static bool isEntityVisible({
    required double entityX,
    required double entityY,
    required double viewportX,
    required double viewportY,
    required double viewportWidth,
    required double viewportHeight,
    double buffer = 50.0,
  }) {
    return entityX >= viewportX - buffer &&
           entityX <= viewportX + viewportWidth + buffer &&
           entityY >= viewportY - buffer &&
           entityY <= viewportY + viewportHeight + buffer;
  }
}

/// Optimized custom painter for gaming elements
class _OptimizedGamePainter extends CustomPainter {
  final void Function(Canvas canvas, Size size) paintFunction;
  final bool forceRepaint;

  _OptimizedGamePainter({
    required this.paintFunction,
    this.forceRepaint = false,
  });

  @override
  void paint(Canvas canvas, Size size) {
    paintFunction(canvas, size);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return forceRepaint;
  }
}

/// Performance monitoring for gaming components
class GamingPerformanceMonitor {
  static final Map<String, DateTime> _lastUpdate = {};
  static final Map<String, int> _updateCount = {};
  static final Map<String, Duration> _totalTime = {};

  /// Start performance measurement
  static void startMeasurement(String componentName) {
    _lastUpdate[componentName] = DateTime.now();
  }

  /// End performance measurement
  static void endMeasurement(String componentName) {
    final now = DateTime.now();
    final lastUpdate = _lastUpdate[componentName];
    
    if (lastUpdate != null) {
      final duration = now.difference(lastUpdate);
      _updateCount[componentName] = (_updateCount[componentName] ?? 0) + 1;
      _totalTime[componentName] = (_totalTime[componentName] ?? Duration.zero) + duration;
    }
  }

  /// Get average update time for component
  static Duration? getAverageUpdateTime(String componentName) {
    final count = _updateCount[componentName];
    final total = _totalTime[componentName];
    
    if (count != null && total != null && count > 0) {
      return Duration(microseconds: total.inMicroseconds ~/ count);
    }
    
    return null;
  }

  /// Get performance report
  static Map<String, Map<String, dynamic>> getPerformanceReport() {
    final report = <String, Map<String, dynamic>>{};
    
    for (final componentName in _updateCount.keys) {
      final count = _updateCount[componentName] ?? 0;
      final total = _totalTime[componentName] ?? Duration.zero;
      final average = count > 0 
          ? Duration(microseconds: total.inMicroseconds ~/ count)
          : Duration.zero;
      
      report[componentName] = {
        'updateCount': count,
        'totalTime': total,
        'averageTime': average,
        'fps': count > 0 ? 1000000 / average.inMicroseconds : 0,
      };
    }
    
    return report;
  }

  /// Clear performance data
  static void clear() {
    _lastUpdate.clear();
    _updateCount.clear();
    _totalTime.clear();
  }
}