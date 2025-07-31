import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'config/env.dart';
import 'config/logger.dart';
import 'routing/app_router.dart';
import 'shared/widgets/splash_screen.dart';
import 'theme/app_theme.dart';
import 'main.dart';
import 'core/services/auth_service.dart';
import 'core/services/api_service.dart';
import 'core/services/world_service.dart';
import 'core/services/invite_service.dart';
import 'core/providers/locale_provider.dart';
import 'l10n/app_localizations.dart';

class WeltenwindApp extends StatefulWidget {
  const WeltenwindApp({super.key});

  @override
  State<WeltenwindApp> createState() => _WeltenwindAppState();
}

class _WeltenwindAppState extends State<WeltenwindApp> {
  late final LocaleProvider _localeProvider;

  @override
  void initState() {
    super.initState();
    _localeProvider = LocaleProvider();
    _localeProvider.addListener(_onLocaleChanged);
  }

  @override
  void dispose() {
    _localeProvider.removeListener(_onLocaleChanged);
    super.dispose();
  }

  void _onLocaleChanged() {
    if (mounted) {
      setState(() {});
    }
  }

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
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.system, // Automatisch Dark/Light basierend auf System
        routerConfig: AppRouter.router,
        debugShowCheckedModeBanner: false,
        
        // Lokalisierungs-Konfiguration
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [
          Locale('de'),
          Locale('en'),
        ],
        locale: _localeProvider.currentLocale, // Dynamische Sprache vom Provider
      ),
    );
  }

  // Korrekte Initialisierungsfunktion NACH App-Start
  Future<void> _initializeApp() async {
    AppLogger.app.i('🚀 App startet...');
    
    // 1. Environment initialisieren
    await Env.initialize();
    
    AppLogger.app.i('🌍 Environment initialisiert');
    
    // 2. LocaleProvider initialisieren
    await LocaleProvider.initialize();
    
    AppLogger.app.i('🌐 LocaleProvider initialisiert');
    
    // 3. Services initialisieren (jetzt sicher, da App bereits läuft)
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
      
      // 4. Token-Validierung beim App-Start (VOR loadStoredUser)
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
      
      // 5. Gespeicherte User-Daten laden (nur wenn Tokens gültig)
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