import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../features/auth/login_page.dart';
import '../features/auth/register_page.dart';
import '../features/auth/forgot_password_page.dart';
import '../features/auth/reset_password_page.dart';
import '../features/world/world_list_page.dart';
import '../features/world/world_page.dart';
import '../config/logger.dart';
import '../core/services/auth_service.dart';
import '../main.dart';
import '../shared/navigation/transitions.dart';

class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: '/login',
    redirect: _redirect,
    routes: [
      GoRoute(
        path: '/login',
        name: 'login',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const LoginPage(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return ElegantTransitions.elegantSlideWithOverlay(
              context,
              animation,
              secondaryAnimation,
              child,
              direction: SlideDirection.fromBottom,
            );
          },
        ),
      ),
      GoRoute(
        path: '/register',
        name: 'register',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const RegisterPage(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return ElegantTransitions.elegantSlideWithOverlay(
              context,
              animation,
              secondaryAnimation,
              child,
              direction: SlideDirection.fromBottom,
            );
          },
        ),
      ),
      GoRoute(
        path: '/forgot-password',
        name: 'forgot-password',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const ForgotPasswordPage(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return ElegantTransitions.elegantSlideWithOverlay(
              context,
              animation,
              secondaryAnimation,
              child,
              direction: SlideDirection.fromBottom,
            );
          },
        ),
      ),
      GoRoute(
        path: '/reset-password',
        name: 'reset-password',
        pageBuilder: (context, state) {
          final token = state.uri.queryParameters['token'] ?? '';
          final email = state.uri.queryParameters['email'];
          
          return CustomTransitionPage(
            key: state.pageKey,
            child: ResetPasswordPage(
              token: token,
              email: email,
            ),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              return ElegantTransitions.elegantSlideWithOverlay(
                context,
                animation,
                secondaryAnimation,
                child,
                direction: SlideDirection.fromBottom,
              );
            },
          );
        },
      ),
      GoRoute(
        path: '/worlds',
        name: 'worlds',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const WorldListPage(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return ElegantTransitions.elegantSlideWithOverlay(
              context,
              animation,
              secondaryAnimation,
              child,
              direction: SlideDirection.fromRight,
            );
          },
        ),
      ),
      GoRoute(
        path: '/worlds/:idOrSlug',
        name: 'world-detail',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: WorldPage(idOrSlug: state.pathParameters['idOrSlug']!),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return ElegantTransitions.elegantSlideWithOverlay(
              context,
              animation,
              secondaryAnimation,
              child,
              direction: SlideDirection.fromRight,
            );
          },
        ),
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text('Page not found: ${state.matchedLocation}'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => context.go('/login'),
              child: const Text('Go to Login'),
            ),
          ],
        ),
      ),
    ),
  );

  static String? _redirect(BuildContext context, GoRouterState state) {
    try {
      final authService = ServiceLocator.get<AuthService>();
      final isAuthenticated = authService.isAuthenticated.value;
      final currentPath = state.matchedLocation;
      
      // Public auth routes (no redirect needed)
      final publicAuthRoutes = ['/login', '/register', '/forgot-password', '/reset-password'];
      final isOnPublicAuthRoute = publicAuthRoutes.any((route) => currentPath.startsWith(route));

      // If not authenticated and not on a public auth route, go to login
      if (!isAuthenticated && !isOnPublicAuthRoute) {
        AppLogger.app.d('🔒 Redirecting to login - not authenticated');
        return '/login';
      }

      // If authenticated and on login/register page, go to worlds
      if (isAuthenticated && (currentPath == '/login' || currentPath == '/register')) {
        AppLogger.app.d('✅ Redirecting to worlds - already authenticated');
        return '/worlds';
      }

      return null; // No redirect needed
    } catch (e) {
      AppLogger.app.e('❌ Auth redirect failed', error: e);
      // Safe fallback: nicht hart zum Login, lasse App zeigen was es kann
      return null;
    }
  }
}