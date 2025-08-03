import 'package:flutter/material.dart';
import '../../config/logger.dart';
import '../../l10n/app_localizations.dart';

/// 🧭 Navigation Splash Screen
/// 
/// Zeigt einen Loading-Screen während Navigation wenn das Laden länger dauert
class NavigationSplashScreen extends StatefulWidget {
  final Future<void> Function() preloadFunction;
  final Widget child;
  final String? loadingText;
  final Duration delayBeforeShow;
  final Duration? timeout;
  final VoidCallback? onTimeout;
  final String targetRouteName;

  const NavigationSplashScreen({
    super.key,
    required this.preloadFunction,
    required this.child,
    required this.targetRouteName,
    this.loadingText,
    this.delayBeforeShow = const Duration(milliseconds: 500), // Nur bei längerem Laden anzeigen
    this.timeout = const Duration(seconds: 10),
    this.onTimeout,
  });

  @override
  State<NavigationSplashScreen> createState() => _NavigationSplashScreenState();
}

class _NavigationSplashScreenState extends State<NavigationSplashScreen> with TickerProviderStateMixin {
  late AnimationController _animationController;
  bool _isLoaded = false;
  bool _showLoading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _preloadWithDelayedUI();
  }

  Future<void> _preloadWithDelayedUI() async {
    AppLogger.navigation.i('🔄 Navigation preload started for: ${widget.targetRouteName}');
    
    try {
      // Start preloading
      final preloadFuture = widget.preloadFunction();
      
      // Start delay timer für UI
      final delayFuture = Future.delayed(widget.delayBeforeShow);
      
      // Wait für delay - wenn preload noch läuft, zeige Loading UI
      await delayFuture;
      
      if (!_isLoaded && mounted) {
        setState(() {
          _showLoading = true;
        });
        _animationController.forward();
        AppLogger.navigation.i('📺 Navigation loading UI shown after delay');
      }
      
      // Wait für preload completion (mit Timeout)
      if (widget.timeout != null) {
        final result = await Future.any([
          preloadFuture.then((_) => 'success'),
          Future.delayed(widget.timeout!).then((_) => 'timeout'),
        ]);
        
        if (result == 'timeout') {
          AppLogger.navigation.w('⏰ Navigation preload timeout für: ${widget.targetRouteName}');
          widget.onTimeout?.call();
        }
      } else {
        await preloadFuture;
      }
      
      if (mounted) {
        setState(() {
          _isLoaded = true;
        });
        
        AppLogger.navigation.i('✅ Navigation preload completed for: ${widget.targetRouteName}');
        
        // Kurze Verzögerung für smooth transition
        if (_showLoading) {
          await Future.delayed(const Duration(milliseconds: 200));
        }
      }
    } catch (e) {
      AppLogger.navigation.e('❌ Navigation preload failed für: ${widget.targetRouteName}', error: e);
      
      if (mounted) {
        // 🔍 Error-spezifische Behandlung
        if (e.toString().contains('not authenticated')) {
          // Auth-Fehler → zur Login-Page
          AppLogger.navigation.w('🔐 Auth error detected, redirecting to login');
          Navigator.of(context).pushReplacementNamed('/login');
          return;
        }
        
        setState(() {
          _error = _categorizeError(e);
          _isLoaded = true; // Error-Screen anzeigen
        });
      }
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // ❌ Error state
    if (_error != null) {
      return _buildErrorScreen(context);
    }
    
    // ✅ Loaded - zeige target page
    if (_isLoaded) {
      return widget.child;
    }
    
    // ⏳ Loading state (nur wenn showLoading aktiv)
    if (_showLoading) {
      return _buildLoadingScreen(context);
    }
    
    // 🫥 Invisible während delay - zeige nichts
    return const SizedBox.shrink();
  }

  Widget _buildLoadingScreen(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: FadeTransition(
        opacity: _animationController,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Navigation Loading Indicator
              Container(
                width: (Theme.of(context).textTheme.displayMedium?.fontSize ?? 40) * 2,
                height: (Theme.of(context).textTheme.displayMedium?.fontSize ?? 40) * 2,
                decoration: BoxDecoration(
                  color: colorScheme.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: colorScheme.primary.withValues(alpha: 0.3),
                    width: 2,
                  ),
                ),
                child: Icon(
                  Icons.navigation,
                  size: Theme.of(context).textTheme.displayMedium?.fontSize ?? 40,
                  color: colorScheme.primary,
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Loading Text
              Text(
                widget.loadingText ?? AppLocalizations.of(context).navigationLoadingGeneric,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.w500,
                  color: colorScheme.onSurface.withValues(alpha: 0.8),
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Progress Indicator
              SizedBox(
                width: Theme.of(context).textTheme.displayMedium?.fontSize ?? 40,
                height: Theme.of(context).textTheme.displayMedium?.fontSize ?? 40,
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(colorScheme.primary),
                  strokeWidth: 3,
                ),
              ),
              
              const SizedBox(height: 8),
              
              // Target Route Info entfernt um Dead Code warning zu vermeiden
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildErrorScreen(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text(
              AppLocalizations.of(context).navigationLoadingError,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w500,
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _error!,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurface.withValues(alpha: 0.6),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _error = null;
                  _isLoaded = false;
                });
                _preloadWithDelayedUI();
              },
              child: Text(AppLocalizations.of(context).navigationLoadingRetry),
            ),
          ],
        ),
      ),
    );
  }
  
  /// 🔍 Private: Error-Kategorisierung für bessere User-Experience
  String _categorizeError(dynamic error) {
    final errorStr = error.toString().toLowerCase();
    
    if (errorStr.contains('service') && errorStr.contains('not registered')) {
      return AppLocalizations.of(context).navigationErrorServiceUnavailable;
    }
    
    if (errorStr.contains('network') || errorStr.contains('connection')) {
      return AppLocalizations.of(context).navigationErrorNetwork;
    }
    
    if (errorStr.contains('timeout')) {
      return AppLocalizations.of(context).navigationErrorTimeout;
    }
    
    if (errorStr.contains('theme') || errorStr.contains('bundle')) {
      return AppLocalizations.of(context).navigationErrorTheme;
    }
    
    // Fallback für unbekannte Fehler
    return AppLocalizations.of(context).navigationErrorGeneric;
  }
}

/// 🧭 Navigation Manager - Centralized Navigation mit Preloading
class NavigationManager {
  static final Map<String, Future<void> Function()> _preloadFunctions = {};

  /// Register eine Preload-Funktion für eine Route
  static void registerPreloadFunction(String routeName, Future<void> Function() preloadFunction) {
    _preloadFunctions[routeName] = preloadFunction;
    AppLogger.navigation.d('📝 Preload function registered for: $routeName');
  }

  /// Navigate mit automatischem Preloading
  static Widget wrapWithPreloading({
    required String routeName,
    required Widget child,
    String? loadingText,
  }) {
    final preloadFunction = _preloadFunctions[routeName];
    
    if (preloadFunction == null) {
      AppLogger.navigation.d('⚡ No preload function for $routeName - showing directly');
      return child;
    }

    return NavigationSplashScreen(
      targetRouteName: routeName,
      preloadFunction: preloadFunction,
      loadingText: loadingText,
      child: child,
    );
  }

  /// Cleanup - remove preload function
  static void unregisterPreloadFunction(String routeName) {
    _preloadFunctions.remove(routeName);
    AppLogger.navigation.d('🗑️ Preload function unregistered for: $routeName');
  }

  /// Get all registered routes
  static List<String> get registeredRoutes => _preloadFunctions.keys.toList();
}