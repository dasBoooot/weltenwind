import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:go_router/go_router.dart';
import '../config/logger.dart';
import '../features/auth/login_page.dart';
import '../features/auth/register_page.dart';
import '../features/auth/forgot_password_page.dart';
import '../features/auth/reset_password_page.dart';
import '../features/world/world_list_page.dart';
import '../features/world/world_join_page.dart';
import '../features/invite/invite_landing_page.dart';
import '../features/dashboard/dashboard_page.dart';
import '../features/landing/landing_page.dart';
import '../core/services/auth_service.dart';
import '../shared/widgets/navigation_splash_screen.dart';
import '../shared/navigation/page_preloaders.dart';
import '../shared/navigation/smart_navigation.dart';
import '../main.dart';

// Custom Navigation Observer für Logging
class AppNavigationObserver extends NavigatorObserver {
  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    super.didReplace(newRoute: newRoute, oldRoute: oldRoute);
    _logNavigation(oldRoute?.settings.name, newRoute?.settings.name, 'replace');
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPop(route, previousRoute);
    _logNavigation(route.settings.name, previousRoute?.settings.name, 'pop');
  }

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPush(route, previousRoute);
    _logNavigation(previousRoute?.settings.name, route.settings.name, 'push');
  }

  void _logNavigation(String? from, String? to, String action) {
    // Nur wichtige Navigation-Events loggen (Fehler werden separat gehandelt)
    if (to != null && (to.contains('error') || to.contains('invite'))) {
      AppLogger.navigation.i('🧭 Navigation: → $to');
    }
  }
}

class AppRouter {
  // Named Routes für bessere Navigation
  static const String landingRoute = 'landing';
  static const String loginRoute = 'login';
  static const String registerRoute = 'register';
  static const String forgotPasswordRoute = 'forgot-password';
  static const String resetPasswordRoute = 'reset-password';
  static const String worldListRoute = 'world-list';
  static const String worldDashboardRoute = 'world-dashboard';
  static const String worldJoinRoute = 'world-join';
  static const String errorRoute = 'error';

  // NavigatorKey für zukünftige Shell-Integration (z.B. BottomNav)
  static final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>();

  static GoRouter? _routerInstance;
  static bool _isInitialized = false;
  
  // Helper method to safely get AuthService - komplett unabhängig von ServiceLocator
  static AuthService? _getAuthService() {
    try {
      if (ServiceLocator.has<AuthService>()) {
        return ServiceLocator.get<AuthService>();
      }
    } catch (e) {
      AppLogger.navigation.w('⚠️ ServiceLocator Fehler', error: e);
    }
    // Kein Fallback - Services sind nicht verfügbar
    return null;
  }
  
  /// 🧭 Helper: Wrap Page with Navigation Loading (nur für spezielle Routen)
  static Widget _wrapWithNavigationLoading({
    required String routeName,
    required Widget child,
    Map<String, String>? parameters,
    String? customLoadingText,
  }) {
    try {
      // Nur für definierte Routen mit Preload-Funktionen
      if (!_shouldUseNavigationLoading(routeName)) {
        return child;
      }
      
      // Erstelle preload function basierend auf route name
      Future<void> Function() preloadFunction;
      switch (routeName) {
        case 'worldList':
        case 'world-list':
          preloadFunction = () => PagePreloaders.preloadWorldListPage(
            ThemeContext(contextId: 'world-preview', bundleId: 'world-preview')
          );
          break;
        case 'dashboard':
        case 'world-dashboard':
          final worldId = parameters?['id'];
          preloadFunction = () => PagePreloaders.preloadDashboardPage(
            ThemeContext(contextId: 'dashboard-base', bundleId: 'dashboard-base', worldTheme: worldId != null ? 'world-$worldId' : null)
          );
          break;
        case 'worldJoin':
        case 'world-join':
          final worldId = parameters?['id'];
          preloadFunction = () => PagePreloaders.preloadWorldJoinPage(
            worldId,
            ThemeContext(contextId: 'world-preview', bundleId: 'world-preview', worldTheme: worldId != null ? 'world-$worldId' : null)
          );
          break;
        default:
          return child; // No preloading for this route
      }
      
      return NavigationSplashScreen(
        targetRouteName: routeName,
        preloadFunction: preloadFunction,
        loadingText: customLoadingText,
        child: child,
      );
    } catch (e) {
      AppLogger.navigation.w('⚠️ Navigation loading setup failed for $routeName - showing directly', error: e);
      return child;
    }
  }
  
  /// 🔍 Helper: Check if route should use navigation loading
  static bool _shouldUseNavigationLoading(String routeName) {
    const loadingRoutes = {
      worldListRoute,
      worldDashboardRoute, 
      worldJoinRoute,
    };
    return loadingRoutes.contains(routeName);
  }
  
  static GoRouter get router {
    if (_routerInstance != null) {
      return _routerInstance!;
    }
    
    // Router nur einmal initialisieren
    if (!_isInitialized) {
      try {
        _routerInstance = GoRouter(
          navigatorKey: _rootNavigatorKey,
          
          // Navigation Observer für User Journey Tracking
          observers: [
            AppNavigationObserver(),
          ],
          
          // 🎯 HYBRID ROUTER - Cross-Platform Deep-Link Fix
          redirect: (context, state) async {
        try {
          final uriPath = state.uri.path;
          
          // Navigation handling...
          
          // 🌐 WEB-SPEZIFISCHE DEEP-LINK-FIXES
          if (kIsWeb) {
            // 🔧 Deep-Link-Fix: Wenn GoRouter "/go" zeigt, aber Browser mehr hat
            if (uriPath == '/go') {
              final browserPath = Uri.base.path;
              if (browserPath.contains('/invite/')) {
                // Extrahiere echte Route aus Browser-URL
                String realPath = browserPath;
                if (realPath.startsWith('/game/')) {
                  realPath = realPath.substring(5); // Entferne "/game" Prefix
                }
                AppLogger.navigation.i('🔧 Web Deep-Link-Fix: $uriPath → $realPath');
                return realPath;
              }
            }
          }
          
          // ✅ INVITE-ROUTES: Immer direkt erlauben (Cross-Platform)
          if (uriPath.startsWith('/go/invite/')) {
            return null; // Invite-Routes immer erlauben
          }
          
          // 🔄 STANDARD AUTH & PROTECTION LOGIC
          final authService = _getAuthService();
          if (authService == null) {
            AppLogger.navigation.w('❌ AuthService nicht verfügbar');
            return uriPath == '/' || uriPath.isEmpty ? '/go' : null;
          }
          
          final isLoggedIn = await authService.isLoggedIn();
          final isAuthRoute = uriPath.startsWith('/go/auth');
          final isProtectedRoute = (uriPath.startsWith('/go/worlds') ||
                                  uriPath.startsWith('/go/dashboard'));

          if (!isLoggedIn && isProtectedRoute) {
            AppLogger.navigation.i('🔒 Auth required for: $uriPath');
            return '/go/auth/login';
          }

          if (isLoggedIn && isAuthRoute) {
            return '/go/worlds'; // Redirect authenticated users
          }
          
          // 📍 ROOT FALLBACK
          if (uriPath == '/' || uriPath.isEmpty) {
            return '/go';
          }
          
          return null;
        } catch (e) {
          AppLogger.navigation.e('❌ Router Redirect Fehler', error: e);
          return null; // Bei Fehlern KEINEN Redirect
        }
      },
    
    routes: [
      // Landing page
      GoRoute(
        path: '/go',
        name: landingRoute,
        pageBuilder: (context, state) => CustomTransitionPage(
          child: const LandingPage(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) =>
            FadeTransition(opacity: animation, child: child),
        ),
      ),

      // Auth routes
      GoRoute(
        path: '/go/auth/login',
        name: loginRoute,
        pageBuilder: (context, state) => CustomTransitionPage(
          child: const LoginPage(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) =>
            FadeTransition(opacity: animation, child: child),
        ),
      ),
      GoRoute(
        path: '/go/auth/register',
        name: registerRoute,
        pageBuilder: (context, state) => CustomTransitionPage(
          child: const RegisterPage(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) =>
            FadeTransition(opacity: animation, child: child),
        ),
      ),
      GoRoute(
        path: '/go/auth/forgot-password',
        name: forgotPasswordRoute,
        pageBuilder: (context, state) => CustomTransitionPage(
          child: const ForgotPasswordPage(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) =>
            FadeTransition(opacity: animation, child: child),
        ),
      ),
      GoRoute(
        path: '/go/auth/reset-password',
        name: resetPasswordRoute,
        pageBuilder: (context, state) {
          // Token aus Query-Parametern holen
          final token = state.uri.queryParameters['token'];
          if (token == null || token.isEmpty) {
            // Ohne Token zur Passwort-vergessen Seite weiterleiten
            return CustomTransitionPage(
              child: const ForgotPasswordPage(),
              transitionsBuilder: (context, animation, secondaryAnimation, child) =>
                FadeTransition(opacity: animation, child: child),
            );
          }
          return CustomTransitionPage(
            child: ResetPasswordPage(token: token),
            transitionsBuilder: (context, animation, secondaryAnimation, child) =>
              FadeTransition(opacity: animation, child: child),
          );
        },
      ),

      // 🎟️ INVITE ROUTES - Cross-Platform Deep-Links
      GoRoute(
        path: '/go/invite/:token',
        pageBuilder: (context, state) {
          final token = state.pathParameters['token'];
          if (token == null || token.isEmpty) {
            return CustomTransitionPage(
              child: const ErrorPage(),
              transitionsBuilder: (context, animation, secondaryAnimation, child) =>
                FadeTransition(opacity: animation, child: child),
            );
          }
          return CustomTransitionPage(
            child: InviteLandingPage(token: token),
            transitionsBuilder: (context, animation, secondaryAnimation, child) =>
              SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0.0, 1.0),
                  end: Offset.zero,
                ).animate(CurvedAnimation(
                  parent: animation,
                  curve: Curves.easeInOut,
                )),
                child: child,
              ),
          );
        },
      ),

      // World routes - MIT NAVIGATION LOADING
      GoRoute(
        path: '/go/worlds',
        name: worldListRoute,
        pageBuilder: (context, state) => CustomTransitionPage(
          child: _wrapWithNavigationLoading(
            routeName: worldListRoute,
            child: const WorldListPage(),
          ),
          transitionsBuilder: (context, animation, secondaryAnimation, child) =>
            FadeTransition(opacity: animation, child: child),
        ),
      ),
      GoRoute(
        path: '/go/worlds/:id',
        name: worldDashboardRoute,
        pageBuilder: (context, state) {
          final worldId = state.pathParameters['id'];
          if (worldId == null) {
            return CustomTransitionPage(
              child: const ErrorPage(),
              transitionsBuilder: (context, animation, secondaryAnimation, child) =>
                SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0.0, 1.0),
                    end: Offset.zero,
                  ).animate(CurvedAnimation(
                    parent: animation,
                    curve: Curves.easeInOut,
                  )),
                  child: child,
                ),
            );
          }
          return CustomTransitionPage(
            child: _wrapWithNavigationLoading(
              routeName: worldDashboardRoute,
              parameters: {'id': worldId},
              child: DashboardPage(worldId: worldId),
            ),
            transitionsBuilder: (context, animation, secondaryAnimation, child) =>
              SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0.0, 1.0),
                  end: Offset.zero,
                ).animate(CurvedAnimation(
                  parent: animation,
                  curve: Curves.easeInOut,
                )),
                child: child,
              ),
          );
        },
      ),
      // NORMALE WORLD-JOIN Route (über interne Navigation)
      GoRoute(
        path: '/go/worlds/:id/join',
        name: worldJoinRoute,
        pageBuilder: (context, state) {
          final worldId = state.pathParameters['id'];
          if (worldId == null) {
            return CustomTransitionPage(
              child: const ErrorPage(),
              transitionsBuilder: (context, animation, secondaryAnimation, child) =>
                SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0.0, 1.0),
                    end: Offset.zero,
                  ).animate(CurvedAnimation(
                    parent: animation,
                    curve: Curves.easeInOut,
                  )),
                  child: child,
                ),
            );
          }
          return CustomTransitionPage(
            child: _wrapWithNavigationLoading(
              routeName: worldJoinRoute,
              parameters: {'id': worldId},
              child: WorldJoinPage(
                worldId: worldId,
              ),
            ),
            transitionsBuilder: (context, animation, secondaryAnimation, child) =>
              SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0.0, 1.0),
                  end: Offset.zero,
                ).animate(CurvedAnimation(
                  parent: animation,
                  curve: Curves.easeInOut,
                )),
                child: child,
              ),
          );
        },
      ),
    ],
    
    // Verbesserte Fehlerbehandlung mit robuster 404-Erkennung
    errorBuilder: (context, state) {
      // Spezifische Fehlerbehandlung basierend auf Error-Typ
      if (state.error is GoException) {
        final goException = state.error as GoException;
        
        // Auth-Fehler
        if (goException.message.contains('401')) {
          return const AuthErrorPage();
        }
        
        // Welt nicht gefunden - robuste Erkennung
        if (goException.message.contains('404') && 
            (state.matchedLocation.contains('/worlds/') || 
             state.uri.pathSegments.contains('worlds'))) {
          return const WorldNotFoundPage();
        }
      }
      
      // Standard 404-Fehlerseite
      return const ErrorPage();
    },
  );
        
        _isInitialized = true;
      } catch (e) {
        // Bei Fehler während der Initialisierung
        AppLogger.navigation.e('❌ Router Initialisierungs-Fehler', error: e);
        // Fallback: Minimaler Router nur mit Error Page
        _routerInstance = GoRouter(
          routes: [
            GoRoute(
              path: '/go',
              builder: (context, state) => const ErrorPage(),
            ),
          ],
        );
        _isInitialized = true;
      }
    }
    return _routerInstance!;
  }

  // Getter für NavigatorKey (für zukünftige Shell-Integration)
  static GlobalKey<NavigatorState> get rootNavigatorKey => _rootNavigatorKey;
  
  // Public Methoden für Cache-Management
  static void invalidateAuthCache() {
    // Caching entfernt, daher keine Cache-Invalidierung mehr nötig
  }
  static bool? get cachedLoginState => null; // Caching entfernt
  
  // Cache beim App-Start invalidieren
  static void invalidateCacheOnStart() {
    // Caching entfernt, daher keine Cache-Invalidierung mehr nötig
  }
}

// Verbesserte Fehlerseiten
class ErrorPage extends StatelessWidget {
  const ErrorPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
              Theme.of(context).colorScheme.surface,
            ],
          ),
        ),
        child: Center(
          child: Card(
            elevation: 8,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(32.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 64,
                    color: Theme.of(context).colorScheme.error,
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Seite nicht gefunden',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurface,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Die angeforderte Seite existiert nicht oder wurde verschoben.',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton.icon(
                        onPressed: () async => await context.smartGoNamed('landing'),
                        icon: const Icon(Icons.home),
                        label: const Text('Startseite'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(context).colorScheme.primary,
                          foregroundColor: Colors.white,
                        ),
                      ),
                      ElevatedButton.icon(
                        onPressed: () async => await context.smartGoNamed('world-list'),
                        icon: const Icon(Icons.public),
                        label: const Text('Welten'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(context).colorScheme.surface,
                          foregroundColor: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class AuthErrorPage extends StatelessWidget {
  const AuthErrorPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Theme.of(context).colorScheme.error.withValues(alpha: 0.1),
              Theme.of(context).colorScheme.surface,
            ],
          ),
        ),
        child: Center(
          child: Card(
            elevation: 8,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(32.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.lock_outline,
                    size: 64,
                    color: Theme.of(context).colorScheme.error,
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Zugriff verweigert',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurface,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Du musst dich anmelden, um auf diese Seite zuzugreifen.',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),
                  ElevatedButton.icon(
                    onPressed: () async => await context.smartGoNamed('login'),
                    icon: const Icon(Icons.login),
                    label: const Text('Anmelden'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class WorldNotFoundPage extends StatelessWidget {
  const WorldNotFoundPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
              Theme.of(context).colorScheme.surface,
            ],
          ),
        ),
        child: Center(
          child: Card(
            elevation: 8,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(32.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.public_off,
                    size: 64,
                    color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.7),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Welt nicht gefunden',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurface,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Die angeforderte Welt existiert nicht oder wurde entfernt.',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),
                  ElevatedButton.icon(
                    onPressed: () async => await context.smartGoNamed('world-list'),
                    icon: const Icon(Icons.list),
                    label: const Text('Alle Welten anzeigen'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
} 