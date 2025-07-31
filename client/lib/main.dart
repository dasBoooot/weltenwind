import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'app.dart';
import 'config/logger.dart';
import 'core/services/auth_service.dart';
import 'core/services/api_service.dart';

// Service-Container für Dependency Injection
class ServiceLocator {
  static final Map<Type, dynamic> _services = {};

  static void register<T>(T service) {
    _services[T] = service;
  }

  static T get<T>() {
    final service = _services[T];
    if (service == null) {
      throw Exception('Service $T not registered');
    }
    return service as T;
  }

  static bool has<T>() {
    return _services.containsKey(T);
  }

  static void clear() {
    _services.clear();
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 🌐 WEB URL-STRATEGY: Path-basierte Navigation statt Hash
  if (kIsWeb) {
    usePathUrlStrategy();
  }

  // Initialisiere das Logging-System
  try {
    AppLogger.initialize();
    AppLogger.app.i('🚀 Weltenwind App starting...');
  } catch (e) {
    AppLogger.error.e('❌ AppLogger initialization FAILED: $e');
  }

  // Flutter Error Handling
  FlutterError.onError = (FlutterErrorDetails details) {
    AppLogger.error.e('❌ Flutter Error: ${details.exception}');
    AppLogger.logError(
      'Flutter Framework Error',
      details.exception,
      stackTrace: details.stack,
      context: {
        'library': details.library,
        'context': details.context?.toString(),
        'informationCollector': details.informationCollector?.toString(),
      },
    );
    
    // In Debug Mode auch zur Console
    if (kDebugMode) {
      FlutterError.presentError(details);
    }
  };

  // Dart Error Handling (für unhandled exceptions)
  WidgetsBinding.instance.platformDispatcher.onError = (error, stack) {
    AppLogger.error.e('❌ Dart Error: $error');
    AppLogger.logError(
      'Unhandled Dart Error',
      error,
      stackTrace: stack,
      context: {
        'type': 'dart_unhandled',
        'isolate': 'main',
      },
    );
    return true; // Handled
  };

  // Set preferred orientations
  try {
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
  } catch (e) {
    AppLogger.error.e('❌ Orientations setup failed: $e');
  }

  // 🔧 SERVICES INITIALISIEREN VOR APP-START
  try {
    await _initializeServices();
    AppLogger.app.i('✅ Services initialized - App ready');
  } catch (e) {
    AppLogger.error.e('❌ Service initialization FAILED: $e');
  }

  runApp(const WeltenwindApp());
}

/// Initialisiert alle Services bevor die App gestartet wird
Future<void> _initializeServices() async {
  try {
    // AuthService importieren und initialisieren
    final authService = await _createAuthService();
    ServiceLocator.register<AuthService>(authService);
    
    // ApiService mit AuthService initialisieren  
    final apiService = await _createApiService(authService);
    ServiceLocator.register<ApiService>(apiService);
  } catch (e) {
    AppLogger.error.e('❌ Service initialization failed: $e');
    rethrow;
  }
}

/// Erstellt AuthService (async da SharedPreferences geladen werden könnte)
Future<AuthService> _createAuthService() async {
  try {
    final authService = AuthService();
    // Eventuell await authService.initialize() falls vorhanden
    return authService;
  } catch (e) {
    AppLogger.error.e('❌ AuthService creation failed: $e');
    rethrow;
  }
}

/// Erstellt ApiService mit AuthService-Abhängigkeit
Future<ApiService> _createApiService(AuthService authService) async {
  try {
    final apiService = ApiService.withAuth(authService);
    return apiService;
  } catch (e) {
    AppLogger.error.e('❌ ApiService creation failed: $e');
    rethrow;
  }
} 