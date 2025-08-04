import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'config/env.dart';
import 'config/logger.dart';
import 'routing/app_router.dart';
import 'shared/widgets/splash_screen.dart';
import 'main.dart';
import 'core/services/auth_service.dart';
import 'core/services/world_service.dart';
import 'core/providers/locale_provider.dart';
import 'core/providers/theme_provider.dart';
import 'core/providers/theme_context_provider.dart';
import 'package:provider/provider.dart';
import 'l10n/app_localizations.dart';

class WeltenwindApp extends StatefulWidget {
  const WeltenwindApp({super.key});

  @override
  State<WeltenwindApp> createState() => _WeltenwindAppState();
}

class _WeltenwindAppState extends State<WeltenwindApp> {
  late final LocaleProvider _localeProvider;
  late final ThemeProvider _themeProvider;

  @override
  void initState() {
    super.initState();
    _localeProvider = LocaleProvider();
    _localeProvider.addListener(_onLocaleChanged);
    _themeProvider = ThemeProvider();
    _themeProvider.addListener(_onThemeChanged);
  }

  @override
  void dispose() {
    _localeProvider.removeListener(_onLocaleChanged);
    _themeProvider.removeListener(_onThemeChanged);
    super.dispose();
  }

  void _onLocaleChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  void _onThemeChanged() {
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
      child: ChangeNotifierProvider<ThemeContextProvider>(
        create: (_) => ServiceLocator.get<ThemeContextProvider>(),
        child: Consumer<ThemeContextProvider>(
          builder: (context, themeProvider, child) {
            return MaterialApp.router(
              title: Env.appName,
              theme: themeProvider.currentTheme ?? _createFallbackTheme(false),
              darkTheme: themeProvider.currentDarkTheme ?? _createFallbackTheme(true),
              themeMode: themeProvider.isDarkMode ? ThemeMode.dark : ThemeMode.light,
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
        );
          },
        ),
      ),
    );
  }
  
  /// Erstellt ein Fallback-Theme
  ThemeData _createFallbackTheme(bool isDark) {
    return ThemeData(
      useMaterial3: true,
      brightness: isDark ? Brightness.dark : Brightness.light,
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFF6366F1),
        brightness: isDark ? Brightness.dark : Brightness.light,
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
    
    // 3. ThemeProvider initialisieren
    await ThemeProvider.initialize();
    
    AppLogger.app.i('🎨 ThemeProvider initialisiert');
    
    // 4. Services sind bereits in main.dart registriert - nur validieren
    try {
      // Services-Verfügbarkeit prüfen
      final authService = ServiceLocator.get<AuthService>();
      ServiceLocator.get<WorldService>(); // Validation check
      
      AppLogger.app.i('⚙️ Services validated - all available');
      
      // 5. Token-Validierung beim App-Start (VOR loadStoredUser)
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
      
      // 7. Gespeicherte User-Daten laden (nur wenn Tokens gültig)
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