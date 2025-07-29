import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import 'app.dart';
import 'config/logger.dart';

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

  // Initialisiere das Logging-System
  AppLogger.initialize();
  AppLogger.app.i('🚀 WeltenwindApp wird gestartet...');

  // Flutter Error Handling
  FlutterError.onError = (FlutterErrorDetails details) {
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
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  AppLogger.app.i('📱 Orientations gesetzt');

  // WeltenwindApp starten - Initialisierung erfolgt im SplashScreen
  runApp(const WeltenwindApp());
} 