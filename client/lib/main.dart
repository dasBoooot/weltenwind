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
  print('🚀 MAIN FUNCTION STARTED');
  
  WidgetsFlutterBinding.ensureInitialized();
  print('✅ WidgetsFlutterBinding initialized');

  // 🌐 WEB URL-STRATEGY: Path-basierte Navigation statt Hash
  if (kIsWeb) {
    usePathUrlStrategy();
    print('✅ Path URL Strategy activated for Web');
  }

  // Initialisiere das Logging-System
  try {
    AppLogger.initialize();
    print('✅ AppLogger initialized');
    AppLogger.app.i('🚀 WeltenwindApp wird gestartet...');
  } catch (e) {
    print('❌ AppLogger initialization FAILED: $e');
  }

  // Flutter Error Handling
  FlutterError.onError = (FlutterErrorDetails details) {
    print('❌ Flutter Error: ${details.exception}');
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
    print('❌ Dart Error: $error');
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
    print('✅ Orientations set');
  } catch (e) {
    print('❌ Orientations FAILED: $e');
  }

  // 🔧 SERVICES INITIALISIEREN VOR APP-START
  try {
    print('⚙️ Starting service initialization...');
    await _initializeServices();
    print('✅ Services initialized successfully');
  } catch (e) {
    print('❌ Service initialization FAILED: $e');
    print('❌ StackTrace: ${StackTrace.current}');
  }

  print('🚀 Starting WeltenwindApp...');
  runApp(const WeltenwindApp());
  print('✅ WeltenwindApp started');
}

/// Initialisiert alle Services bevor die App gestartet wird
Future<void> _initializeServices() async {
  print('🔧 _initializeServices started');
  
  try {
    AppLogger.app.i('⚙️ Services werden initialisiert...');
    
    // AuthService importieren und initialisieren
    print('🔧 Creating AuthService...');
    final authService = await _createAuthService();
    print('🔧 Registering AuthService...');
    ServiceLocator.register<AuthService>(authService);
    print('✅ AuthService registered');
    AppLogger.app.i('✅ AuthService initialisiert');
    
    // ApiService mit AuthService initialisieren  
    print('🔧 Creating ApiService...');
    final apiService = await _createApiService(authService);
    print('🔧 Registering ApiService...');
    ServiceLocator.register<ApiService>(apiService);
    print('✅ ApiService registered');
    AppLogger.app.i('✅ ApiService initialisiert');
    
    print('🎯 All services ready!');
    AppLogger.app.i('🎯 Alle Services bereit - App kann starten!');
  } catch (e) {
    print('❌ Service initialization FAILED in _initializeServices: $e');
    AppLogger.app.e('❌ Service-Initialisierung fehlgeschlagen', error: e);
    rethrow;
  }
}

/// Erstellt AuthService (async da SharedPreferences geladen werden könnte)
Future<AuthService> _createAuthService() async {
  print('🔧 _createAuthService called');
  try {
    final authService = AuthService();
    print('✅ AuthService instance created');
    // Eventuell await authService.initialize() falls vorhanden
    return authService;
  } catch (e) {
    print('❌ AuthService creation FAILED: $e');
    rethrow;
  }
}

/// Erstellt ApiService mit AuthService-Abhängigkeit
Future<ApiService> _createApiService(AuthService authService) async {
  print('🔧 _createApiService called');
  try {
    final apiService = ApiService.withAuth(authService);
    print('✅ ApiService instance created');
    return apiService;
  } catch (e) {
    print('❌ ApiService creation FAILED: $e');
    rethrow;
  }
} 