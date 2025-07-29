import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'config/env.dart';
import 'config/logger.dart';
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
    AppLogger.app.d('🏗️ WeltenwindApp wird gebaut...');
    
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
    AppLogger.app.i('🚀 App startet...');
    
    // 1. Environment initialisieren
    await Env.initialize();
    
    AppLogger.app.i('🌍 Environment initialisiert');
    
    // 2. Services initialisieren (jetzt sicher, da App bereits läuft)
    try {
      final authService = AuthService();
      final apiService = ApiService.withAuth(authService);
      final worldService = WorldService();
      final inviteService = InviteService();

      ServiceLocator.register<AuthService>(authService);
      ServiceLocator.register<ApiService>(apiService);
      ServiceLocator.register<WorldService>(worldService);
      ServiceLocator.register<InviteService>(inviteService);
      
      AppLogger.app.i('⚙️ Services registriert');
      
      // 3. Token-Validierung beim App-Start (VOR loadStoredUser)
      bool isValid = false;
      try {
        isValid = await authService.validateTokensOnStart();
        AppLogger.app.i('🔑 Tokens valid: $isValid');
        
        if (!isValid) {
          AppLogger.app.w('⚠️ Tokens ungültig - logout');
          await authService.logout();
        }
      } catch (e) {
        AppLogger.app.e('❌ Token-Validierung fehlgeschlagen', error: e);
        // Bei Token-Validierungsfehlern einfach ausloggen
        await authService.logout();
      }
      
      // 4. Gespeicherte User-Daten laden (nur wenn Tokens gültig)
      if (isValid) {
        try {
          final user = await authService.loadStoredUser();
          if (user != null) {
            authService.isAuthenticated.value = true;
            AppLogger.app.i('👤 User geladen und authentifiziert');
          } else {
            AppLogger.app.i('👤 Kein gespeicherter User gefunden');
          }
        } catch (e) {
          AppLogger.app.e('❌ User-Load fehlgeschlagen', error: e);
        }
      } else {
        AppLogger.app.i('👤 Keine gültigen Tokens - User-Load übersprungen');
      }
      
      // Auth-Cache beim App-Start invalidieren
      AppRouter.invalidateCacheOnStart();
      
      AppLogger.app.i('✅ Initialisierung abgeschlossen');
    } catch (e) {
      AppLogger.app.e('❌ Service-Initialisierung fehlgeschlagen', error: e);
      // Bei Auth-Service-Fehlern einfach weitermachen
      // Die App kann auch ohne gültige Tokens funktionieren
    }
  }
  
  // Timeout-Callback für SplashScreen
  void _onTimeout() {
    AppLogger.app.w('⏰ Initialisierung timeout - fortfahren');
  }
} 