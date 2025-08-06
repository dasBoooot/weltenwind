import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/scheduler.dart';
import '../../config/logger.dart';

class PerformanceMonitor {
  static final PerformanceMonitor _instance = PerformanceMonitor._internal();
  factory PerformanceMonitor() => _instance;
  PerformanceMonitor._internal();

  Timer? _monitoringTimer;
  final List<double> _frameRates = [];
  final Map<String, Duration> _operationTimes = {};
  final Map<String, int> _counters = {};

  bool _isMonitoring = false;

  /// Initialize performance monitoring
  static Future<void> initialize() async {
    final monitor = PerformanceMonitor();
    await monitor.startMonitoring();
    AppLogger.app.i('⚡ Performance Monitor initialized');
  }

  /// Start performance monitoring
  Future<void> startMonitoring() async {
    if (_isMonitoring) return;

    _isMonitoring = true;
    
    // Monitor frame rates (only in debug mode to avoid production overhead)
    if (kDebugMode) {
      _startFrameRateMonitoring();
    }
    
    // Start periodic monitoring
    _monitoringTimer = Timer.periodic(
      const Duration(seconds: 30),
      (_) => _collectMetrics(),
    );

    AppLogger.app.d('⚡ Performance monitoring started');
  }

  /// Stop performance monitoring
  void stopMonitoring() {
    _isMonitoring = false;
    _monitoringTimer?.cancel();
    _monitoringTimer = null;
    AppLogger.app.d('⚡ Performance monitoring stopped');
  }

  /// Start frame rate monitoring
  void _startFrameRateMonitoring() {
    SchedulerBinding.instance.addPersistentFrameCallback(_onFrame);
  }

  DateTime? _lastFrameTime;
  void _onFrame(Duration timestamp) {
    if (!_isMonitoring) return;

    final now = DateTime.now();
    if (_lastFrameTime != null) {
      final frameDuration = now.difference(_lastFrameTime!);
      final frameRate = 1000 / frameDuration.inMilliseconds;
      
      _frameRates.add(frameRate);
      
      // Keep only last 100 frame rates
      if (_frameRates.length > 100) {
        _frameRates.removeAt(0);
      }
    }
    _lastFrameTime = now;
  }

  /// Record operation timing
  void startOperation(String operationName) {
    _operationTimes['${operationName}_start'] = DateTime.now().difference(DateTime.fromMillisecondsSinceEpoch(0));
  }

  /// End operation timing and record duration
  void endOperation(String operationName) {
    final endTime = DateTime.now().difference(DateTime.fromMillisecondsSinceEpoch(0));
    final startTime = _operationTimes.remove('${operationName}_start');
    
    if (startTime != null) {
      final duration = endTime - startTime;
      _operationTimes[operationName] = duration;
      
      // Log slow operations
      if (duration.inMilliseconds > 1000) {
        AppLogger.app.w('🐌 Slow operation: $operationName took ${duration.inMilliseconds}ms');
      }
    }
  }

  /// Record a counter metric
  void incrementCounter(String counterName, [int increment = 1]) {
    _counters[counterName] = (_counters[counterName] ?? 0) + increment;
  }

  /// Record memory usage
  void recordMemoryUsage() {
    if (!kDebugMode) return;

    try {
      // Note: Memory monitoring is limited on Flutter
      // This is a placeholder for more sophisticated memory tracking
      _counters['memory_checks'] = (_counters['memory_checks'] ?? 0) + 1;
      
      AppLogger.app.d('📊 Memory usage check recorded');
    } catch (e) {
      AppLogger.app.w('⚠️ Memory usage recording failed: $e');
    }
  }

  /// Collect periodic metrics
  void _collectMetrics() {
    final metrics = getCurrentMetrics();
    
    // Log performance summary
    AppLogger.app.d('📊 Performance Metrics: ${metrics['summary']}');
    
    // TODO: Send metrics to analytics service
    _sendMetricsToAnalytics(metrics);
  }

  /// Get current performance metrics
  Map<String, dynamic> getCurrentMetrics() {
    final avgFrameRate = _frameRates.isNotEmpty 
        ? _frameRates.reduce((a, b) => a + b) / _frameRates.length 
        : 0.0;

    final slowOperations = _operationTimes.entries
        .where((entry) => entry.value.inMilliseconds > 500)
        .map((entry) => '${entry.key}: ${entry.value.inMilliseconds}ms')
        .toList();

    return {
      'timestamp': DateTime.now().toIso8601String(),
      'frame_rate': {
        'average': avgFrameRate.toStringAsFixed(1),
        'current_samples': _frameRates.length,
      },
      'operations': {
        'total_tracked': _operationTimes.length,
        'slow_operations': slowOperations,
      },
      'counters': Map.from(_counters),
      'summary': 'FPS: ${avgFrameRate.toStringAsFixed(1)}, Operations: ${_operationTimes.length}, Counters: ${_counters.length}',
    };
  }

  /// Send metrics to analytics service (placeholder)
  void _sendMetricsToAnalytics(Map<String, dynamic> metrics) {
    // TODO: Implement analytics service integration
    // Examples: Firebase Analytics, custom analytics endpoint
    
    AppLogger.app.d('📤 Would send metrics to analytics service');
  }

  /// Clear all collected metrics
  void clearMetrics() {
    _frameRates.clear();
    _operationTimes.clear();
    _counters.clear();
    AppLogger.app.d('🗑️ Performance metrics cleared');
  }

  /// Get performance health status
  PerformanceHealth getHealthStatus() {
    final avgFrameRate = _frameRates.isNotEmpty 
        ? _frameRates.reduce((a, b) => a + b) / _frameRates.length 
        : 60.0;

    final slowOperationCount = _operationTimes.values
        .where((duration) => duration.inMilliseconds > 1000)
        .length;

    if (avgFrameRate < 30 || slowOperationCount > 5) {
      return PerformanceHealth.poor;
    } else if (avgFrameRate < 45 || slowOperationCount > 2) {
      return PerformanceHealth.fair;
    } else {
      return PerformanceHealth.good;
    }
  }
}

enum PerformanceHealth {
  good,
  fair,
  poor,
}

/// Extension for easy performance timing
extension PerformanceTimingExtension on Object {
  /// Time an async operation
  Future<T> timeOperation<T>(String operationName, Future<T> Function() operation) async {
    PerformanceMonitor().startOperation(operationName);
    try {
      final result = await operation();
      return result;
    } finally {
      PerformanceMonitor().endOperation(operationName);
    }
  }
}