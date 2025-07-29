import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../config/logger.dart';
import '../features/auth/login_page.dart';
import '../features/auth/register_page.dart';
import '../features/auth/forgot_password_page.dart';
import '../features/auth/reset_password_page.dart';
import '../features/world/world_list_page.dart';
import '../features/world/world_join_page.dart';
import '../features/dashboard/dashboard_page.dart';
import '../features/landing/landing_page.dart';
import '../core/services/auth_service.dart';
import '../theme/app_theme.dart';
import '../main.dart';
import '../features/world/world_join_page.dart';

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
    if (from != null && to != null) {
      AppLogger.logNavigation(from, to, params: {'action': action});
    } else if (to != null) {
      AppLogger.navigation.i('🧭 Navigation: → $to ($action)');
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
  
  static GoRouter get router {
    AppLogger.navigation.d('🔍 Router-Instanz angefragt', error: {'initialized': _routerInstance != null});
    
    if (_routerInstance != null) {
      return _routerInstance!;
    }
    
    // Router nur einmal initialisieren
    if (!_isInitialized) {
      AppLogger.navigation.i('🚀 Router wird initialisiert...');
      try {
        _routerInstance = GoRouter(
          initialLocation: '/go',
          navigatorKey: _rootNavigatorKey,
          
          // Navigation Observer für User Journey Tracking
          observers: [
            AppNavigationObserver(),
          ],
          
          // Redirect aktiviert - Services werden jetzt korrekt initialisiert
          redirect: (context, state) async {
        try {
          final authService = _getAuthService();
          if (authService == null) {
            // Services noch nicht verfügbar, zur Landing Page
            return '/go';
          }
          
          final isLoggedIn = await authService.isLoggedIn();

          final isAuthRoute = state.matchedLocation.startsWith('/go/auth');
          final isInviteRoute = state.matchedLocation.startsWith('/go/world-join/'); // Invite-Routen sind öffentlich
          final isProtectedRoute = (state.matchedLocation.startsWith('/go/worlds') ||
                                  state.matchedLocation.startsWith('/go/dashboard')) &&
                                  !isInviteRoute; // Invite-Routen ausschließen

          if (!isLoggedIn && isProtectedRoute) {
            AppLogger.navigation.i('🔒 Redirect zu Login', error: {'from': state.matchedLocation});
            return '/go/auth/login';
          }

          if (isLoggedIn && isAuthRoute) {
            AppLogger.navigation.i('🏠 Redirect zu Worlds', error: {'from': state.matchedLocation});
            return '/go/worlds';
          }

          // Invite-Routen werden durchgelassen (keine Weiterleitung)
          if (isInviteRoute) {
            AppLogger.navigation.i('🎫 Invite-Route erkannt - keine Weiterleitung', error: {'route': state.matchedLocation});
          }

          return null;
        } catch (e) {
          AppLogger.navigation.e('❌ Router Redirect Fehler', error: e, stackTrace: StackTrace.current);
          // Bei Fehlern zur Login-Seite weiterleiten
          return '/go/auth/login';
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

      // World routes - NORMALE NAVIGATION
      GoRoute(
        path: '/go/worlds',
        name: worldListRoute,
        pageBuilder: (context, state) => CustomTransitionPage(
          child: const WorldListPage(),
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
            child: DashboardPage(worldId: worldId),
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
            child: WorldJoinPage(
              worldId: worldId,
              flowType: WorldJoinFlowType.normal, // KLARE FLOW-KENNZEICHNUNG
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
      // INVITE-FLOW Route (externe Links)
      GoRoute(
        path: '/go/world-join/:token',
        name: 'world-join-by-token',
        pageBuilder: (context, state) {
          final token = state.pathParameters['token'];
          if (token == null || token.isEmpty) {
            AppLogger.navigation.w('⚠️ Invite-Token fehlt', error: {'path': state.matchedLocation});
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
          AppLogger.navigation.i('🎫 Invite-Token erkannt', error: {'token': token.substring(0, 8) + '...'});
          return CustomTransitionPage(
            child: WorldJoinPage(
              inviteToken: token,
              flowType: WorldJoinFlowType.invite, // KLARE FLOW-KENNZEICHNUNG
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
          initialLocation: '/go',
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
    AppLogger.navigation.i('🔄 Auth-Cache beim App-Start invalidiert');
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
              AppTheme.primaryColor.withOpacity(0.1),
              AppTheme.surfaceColor,
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
                  const Icon(
                    Icons.error_outline,
                    size: 64,
                    color: AppTheme.errorColor,
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Seite nicht gefunden',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: AppTheme.textPrimary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Die angeforderte Seite existiert nicht oder wurde verschoben.',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: AppTheme.textSecondary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton.icon(
                        onPressed: () => context.goNamed('landing'),
                        icon: const Icon(Icons.home),
                        label: const Text('Startseite'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primaryColor,
                          foregroundColor: Colors.white,
                        ),
                      ),
                      ElevatedButton.icon(
                        onPressed: () => context.goNamed('world-list'),
                        icon: const Icon(Icons.public),
                        label: const Text('Welten'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.surfaceColor,
                          foregroundColor: AppTheme.textPrimary,
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
              AppTheme.errorColor.withOpacity(0.1),
              AppTheme.surfaceColor,
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
                  const Icon(
                    Icons.lock_outline,
                    size: 64,
                    color: AppTheme.errorColor,
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Zugriff verweigert',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: AppTheme.textPrimary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Du musst dich anmelden, um auf diese Seite zuzugreifen.',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: AppTheme.textSecondary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),
                  ElevatedButton.icon(
                    onPressed: () => context.goNamed('login'),
                    icon: const Icon(Icons.login),
                    label: const Text('Anmelden'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryColor,
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
              AppTheme.primaryColor.withOpacity(0.1),
              AppTheme.surfaceColor,
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
                    color: AppTheme.primaryColor.withOpacity(0.7),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Welt nicht gefunden',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: AppTheme.textPrimary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Die angeforderte Welt existiert nicht oder wurde entfernt.',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: AppTheme.textSecondary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),
                  ElevatedButton.icon(
                    onPressed: () => context.goNamed('world-list'),
                    icon: const Icon(Icons.list),
                    label: const Text('Alle Welten anzeigen'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryColor,
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