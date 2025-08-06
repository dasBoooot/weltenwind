import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'config/env.dart';
import 'config/logger.dart';
import 'routing/app_router.dart';
import 'core/providers/locale_provider.dart';
import 'core/providers/theme_provider.dart';
import 'l10n/app_localizations.dart';

class WeltenwindApp extends StatefulWidget {
  const WeltenwindApp({super.key});

  @override
  State<WeltenwindApp> createState() => _WeltenwindAppState();
}

class _WeltenwindAppState extends State<WeltenwindApp> {
  late final LocaleProvider _localeProvider;
  late final ThemeProvider _themeProvider;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _localeProvider = LocaleProvider();
    _themeProvider = ThemeProvider();
    _initialize();
  }

  Future<void> _initialize() async {
    try {
      await Env.initialize();
      await LocaleProvider.initialize();
      await ThemeProvider.initialize();
      
      _localeProvider.addListener(_onLocaleChanged);
      _themeProvider.addListener(_onThemeChanged);
      
      setState(() {
        _isInitialized = true;
      });
      
      AppLogger.app.i('✅ App initialized successfully');
    } catch (e) {
      AppLogger.app.e('❌ App initialization failed', error: e);
      // Show error but continue
      setState(() {
        _isInitialized = true;
      });
    }
  }

  @override
  void dispose() {
    _localeProvider.removeListener(_onLocaleChanged);
    _themeProvider.removeListener(_onThemeChanged);
    super.dispose();
  }

  void _onLocaleChanged() {
    if (mounted) setState(() {});
  }

  void _onThemeChanged() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized) {
      return const MaterialApp(
        home: Scaffold(
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('Loading...'),
              ],
            ),
          ),
        ),
      );
    }
    
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: _localeProvider),
        ChangeNotifierProvider.value(value: _themeProvider),
      ],
      child: MaterialApp.router(
        title: Env.appName,
        theme: _themeProvider.currentLightTheme,
        darkTheme: _themeProvider.currentDarkTheme,
        themeMode: _themeProvider.themeMode,
        routerConfig: AppRouter.router,
        debugShowCheckedModeBanner: false,
        
        // Localization
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
        locale: _localeProvider.currentLocale,
      ),
    );
  }
}