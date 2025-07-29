import 'package:logger/logger.dart';
import 'package:flutter/foundation.dart';

/// Zentrale Logger-Konfiguration für Weltenwind Flutter Client
class AppLogger {
  static late Logger _logger;
  static late Logger _apiLogger;
  static late Logger _authLogger;
  static late Logger _navigationLogger;
  static late Logger _errorLogger;

  /// Initialisiere alle Logger
  static void initialize() {
    // Base Logger mit Custom Printer
    _logger = Logger(
      printer: _getLogPrinter(),
      level: kDebugMode ? Level.debug : Level.info,
      output: _getLogOutput(),
    );

    // Spezielle Logger für verschiedene Bereiche
    _apiLogger = Logger(
      printer: _getLogPrinter(prefix: '[API]'),
      level: kDebugMode ? Level.debug : Level.info,
      output: _getLogOutput(),
    );

    _authLogger = Logger(
      printer: _getLogPrinter(prefix: '[AUTH]'),
      level: kDebugMode ? Level.debug : Level.info,
      output: _getLogOutput(),
    );

    _navigationLogger = Logger(
      printer: _getLogPrinter(prefix: '[NAV]'),
      level: kDebugMode ? Level.debug : Level.info,
      output: _getLogOutput(),
    );

    _errorLogger = Logger(
      printer: _getLogPrinter(prefix: '[ERROR]'),
      level: Level.warning,
      output: _getLogOutput(),
    );
  }

  /// Custom Log Printer mit strukturiertem Format
  static LogPrinter _getLogPrinter({String? prefix}) {
    return PrettyPrinter(
      methodCount: 2, // Stack trace depth
      errorMethodCount: 8, // Error stack trace depth
      lineLength: 120, // Width of the output
      colors: kDebugMode, // Colorful log in debug mode
      printEmojis: true, // Print emoji for each log level
      dateTimeFormat: DateTimeFormat.onlyTimeAndSinceStart, // Include timestamp
      noBoxingByDefault: false,
    );
  }

  /// Log Output - Debug: Console, Release: File + Remote
  static LogOutput _getLogOutput() {
    if (kDebugMode) {
      return ConsoleOutput();
    } else {
      // In Production: File + Remote Upload
      return MultiOutput([
        ConsoleOutput(),
        FileOutput(), // Local file storage
        // TODO: RemoteOutput(), // Upload to backend
      ]);
    }
  }

  // === Public API ===

  /// General App Logger
  static Logger get app => _logger;

  /// API Calls & Responses
  static Logger get api => _apiLogger;

  /// Authentication Events
  static Logger get auth => _authLogger;

  /// Navigation & Routing
  static Logger get navigation => _navigationLogger;

  /// Errors & Crashes
  static Logger get error => _errorLogger;

  // === Convenience Methods ===

  /// Log API Request
  static void logApiRequest(String method, String url, {Map<String, dynamic>? headers, dynamic body}) {
    api.i('🔄 $method $url', error: {
      'method': method,
      'url': url,
      'headers': headers,
      'body': body,
      'timestamp': DateTime.now().toIso8601String(),
    });
  }

  /// Log API Response
  static void logApiResponse(String method, String url, int statusCode, {dynamic body}) {
    final isSuccess = statusCode >= 200 && statusCode < 300;
    final logger = isSuccess ? api.i : api.w;
    
    logger('${isSuccess ? '✅' : '⚠️'} $method $url → $statusCode', error: {
      'method': method,
      'url': url,
      'statusCode': statusCode,
      'body': body,
      'success': isSuccess,
      'timestamp': DateTime.now().toIso8601String(),
    });
  }

  /// Log API Error
  static void logApiError(String method, String url, dynamic error, {StackTrace? stackTrace}) {
    api.e('❌ $method $url', error: error, stackTrace: stackTrace);
  }

  /// Log Authentication Event 
  static void logAuthEvent(String event, {String? username, Map<String, dynamic>? metadata}) {
    auth.i('🔐 $event', error: {
      'event': event,
      'username': username,
      'metadata': metadata,
      'timestamp': DateTime.now().toIso8601String(),
    });
  }

  /// Log Navigation Event
  static void logNavigation(String from, String to, {Map<String, dynamic>? params}) {
    navigation.i('🧭 $from → $to', error: {
      'from': from,
      'to': to,
      'params': params,
      'timestamp': DateTime.now().toIso8601String(),
    });
  }

  /// Log Error with Context
  static void logError(String message, dynamic error, {StackTrace? stackTrace, Map<String, dynamic>? context}) {
    AppLogger.error.e('💥 $message', error: {
      'message': message,
      'error': error.toString(),
      'context': context,
      'timestamp': DateTime.now().toIso8601String(),
    }, stackTrace: stackTrace);
  }

  /// Log User Action
  static void logUserAction(String action, {Map<String, dynamic>? context}) {
    app.i('👤 User: $action', error: {
      'action': action,
      'context': context,
      'timestamp': DateTime.now().toIso8601String(),
    });
  }
}

/// File Output für lokale Log-Speicherung
class FileOutput extends LogOutput {
  @override
  void output(OutputEvent event) {
    // TODO: Implement local file storage
    // Für jetzt: Console Output in Release Mode
    for (var line in event.lines) {
      // ignore: avoid_print
      print(line);
    }
  }
}