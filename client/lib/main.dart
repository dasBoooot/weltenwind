import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'app.dart';
import 'config/logger.dart';
import 'core/services/auth_service.dart';
import 'core/services/api_service.dart';
import 'core/services/world_service.dart';
import 'core/services/invite_service.dart';
import 'core/services/client_config_service.dart';
import 'core/infrastructure/error_handler.dart';
import 'core/infrastructure/performance_monitor.dart';
import 'shared/theme/theme_manager.dart';
import 'core/providers/theme_provider.dart';


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

  // 📋 INFRASTRUCTURE LAYER INITIALISIERUNG
  try {
    // 1. Logging-System
    AppLogger.initialize();
    AppLogger.app.i('🚀 Weltenwind App starting...');
    
    // 2. Professional Error Handling
    await ErrorHandler.initialize();
    
    // 3. Performance Monitoring
    await PerformanceMonitor.initialize();
    
    // 4. Theme Management System
    await _initializeThemeSystem();
    
    AppLogger.app.i('🏗️ Infrastructure layer initialized');
  } catch (e) {
    AppLogger.error.e('❌ Infrastructure initialization FAILED: $e');
    // Continue app startup even if infrastructure fails
  }

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
    // 1. Client-Konfiguration laden (muss vor anderen Services passieren)
    await _initializeClientConfiguration();
    
    // 2. Alle anderen Services initialisieren
    await _initializeServices();
    
    // 3. ThemeManager initialisieren
    await ThemeManager.initialize();
    
    // 4. ThemeProvider initialisieren (mit ThemeManager Integration)
    await ThemeProvider.initialize();
    
    AppLogger.app.i('✅ All services initialized - App ready');
  } catch (e) {
    AppLogger.error.e('❌ Service initialization FAILED: $e');
    // App trotzdem starten, aber mit Fehlerzustand
  }

  runApp(const WeltenwindApp());
}

/// Initialize client configuration from backend
Future<void> _initializeClientConfiguration() async {
  try {
    final clientConfigService = ClientConfigService();
    final success = await clientConfigService.initialize();
    
    if (success) {
      AppLogger.app.i('✅ Client configuration loaded from backend');
    } else {
      AppLogger.app.w('⚠️ Using default configuration (backend unavailable)');
    }
  } catch (e) {
    AppLogger.app.w('⚠️ Client configuration initialization failed - using defaults', error: e);
  }
}

/// Initialize theme management system
Future<void> _initializeThemeSystem() async {
  try {
    // Initialize theme manager directly
    await ThemeManager.initialize();
    AppLogger.app.i('🎨 Theme Manager initialized');
  } catch (e) {
    AppLogger.app.w('⚠️ Theme Manager initialization failed - using defaults', error: e);
  }
}

/// Initialisiert alle Services bevor die App gestartet wird
Future<void> _initializeServices() async {
  try {
    // 1. AuthService initialisieren (Basis-Service)
    final authService = await _createAuthService();
    ServiceLocator.register<AuthService>(authService);
    
    // 2. ApiService mit AuthService-Abhängigkeit
    final apiService = await _createApiService(authService);
    ServiceLocator.register<ApiService>(apiService);
    
    // 3. WorldService initialisieren
    final worldService = WorldService();
    ServiceLocator.register<WorldService>(worldService);
    
    // 4. InviteService initialisieren
    final inviteService = InviteService();
    ServiceLocator.register<InviteService>(inviteService);
    

    
    AppLogger.app.i('⚙️ All services registered in ServiceLocator');
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