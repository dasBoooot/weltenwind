import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'config/env.dart';
import 'routing/app_router.dart';
import 'shared/widgets/splash_screen.dart';
import 'main.dart';
import 'core/services/auth_service.dart';
import 'core/services/api_service.dart';
import 'core/services/world_service.dart';
import 'core/services/invite_service.dart';

class WeltenwindApp extends StatelessWidget {
  const WeltenwindApp({super.key});

  @override
  Widget build(BuildContext context) {
    if (kDebugMode) {
      print('[WeltenwindApp] Building app...');
    }
    
    return SplashScreen(
      initializationFunction: _initializeApp,
      timeout: const Duration(seconds: 8),
      onTimeout: _onTimeout,
      initSteps: const [
        'Initialisiere App...',
        'Lade Konfiguration...',
        'Starte Services...',
        'Prüfe Authentifizierung...',
        'Bereit!',
      ],
      appName: Env.appName,
      child: MaterialApp.router(
        title: Env.appName,
        theme: ThemeData(
          primarySwatch: Colors.blue,
          useMaterial3: true,
        ),
        routerConfig: AppRouter.router,
        debugShowCheckedModeBanner: false,
      ),
    );
  }

  // Korrekte Initialisierungsfunktion NACH App-Start
  Future<void> _initializeApp() async {
    if (kDebugMode) {
      print('[WeltenwindApp] App starting...');
    }
    
    // 1. Environment initialisieren
    await Env.initialize();
    
    if (kDebugMode) {
      print('[WeltenwindApp] Environment initialized');
    }
    
    // 2. Services initialisieren (jetzt sicher, da App bereits läuft)
    try {
      final authService = AuthService();
      final apiService = ApiService();
      final worldService = WorldService();
      final inviteService = InviteService();
      
      // Register services for dependency injection
      ServiceLocator.register<AuthService>(authService);
      ServiceLocator.register<ApiService>(apiService);
      ServiceLocator.register<WorldService>(worldService);
      ServiceLocator.register<InviteService>(inviteService);
      
      if (kDebugMode) {
        print('[WeltenwindApp] Services registered');
      }
      
      // 3. Token-Validierung beim App-Start (VOR loadStoredUser)
      bool isValid = false;
      try {
        isValid = await authService.validateTokensOnStart();
        if (kDebugMode) {
          print('[WeltenwindApp] Tokens valid: $isValid');
        }
        
        if (!isValid) {
          if (kDebugMode) {
            print('[WeltenwindApp] Tokens invalid, logging out');
          }
          await authService.logout();
        }
      } catch (e) {
        if (kDebugMode) {
          print('[WeltenwindApp] Token validation error: $e');
        }
        // Bei Token-Validierungsfehlern einfach ausloggen
        await authService.logout();
      }
      
      // 4. Load stored user only if tokens are valid
      if (isValid) {
        final user = await authService.loadStoredUser();
        if (user != null) {
          authService.isAuthenticated.value = true;
          if (kDebugMode) {
            print('[WeltenwindApp] Stored user loaded and authenticated');
          }
        } else {
          if (kDebugMode) {
            print('[WeltenwindApp] No stored user found');
          }
        }
      } else {
        if (kDebugMode) {
          print('[WeltenwindApp] No valid tokens, skipping user load');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('[WeltenwindApp] Service initialization error: $e');
      }
      // Bei Auth-Service-Fehlern einfach weitermachen
      // Die App kann auch ohne gültige Tokens funktionieren
    }
    
    // 5. Auth-Cache invalidieren beim App-Start
    AppRouter.invalidateCacheOnStart();
    
    if (kDebugMode) {
      print('[WeltenwindApp] Initialization complete');
    }
  }

  // Timeout-Callback für SplashScreen
  void _onTimeout() {
    if (kDebugMode) {
      print('[WeltenwindApp] Initialization timeout reached - continuing anyway');
    }
  }
} 