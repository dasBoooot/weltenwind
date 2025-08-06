import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../config/logger.dart';
import '../../core/services/auth_service.dart';
import '../../main.dart';
import '../../shared/components/layout/app_scaffold.dart';
import '../../shared/components/inputs/app_text_field.dart';
import '../../shared/components/buttons/app_button.dart';
import '../../shared/components/cards/app_card.dart';
import '../../shared/components/layout/app_container.dart';
import '../../l10n/app_localizations.dart';
import '../../core/utils/validators.dart';
import '../../shared/theme/theme_manager.dart';
import '../../core/models/world.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  late ThemeManager _themeManager;

  @override
  void initState() {
    super.initState();
    _themeManager = ThemeManager();
    _loadDefaultTheme();
  }

  /// Load default world theme for pre-game context
  Future<void> _loadDefaultTheme() async {
    try {
      // Create a default world for the login page
      final defaultWorld = World(
        id: 0,
        name: 'Default',
        status: WorldStatus.open,
        createdAt: DateTime.now(),
        startsAt: DateTime.now(),
        description: 'Default world for authentication',
        themeBundle: 'default',
        themeVariant: 'pre-game',
        parentTheme: null,
        themeOverrides: null,
      );

      // Set the theme for pre-game context
      await _themeManager.setWorldTheme(defaultWorld, context: 'pre-game');
    } catch (e) {
      AppLogger.app.w('⚠️ Failed to load default theme: $e');
      // Continue with fallback theme
    }
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    final l10n = AppLocalizations.of(context);
    
    AppLogger.app.d('🔍 Login attempt started', error: {
      'username': _usernameController.text.trim(),
      'hasPassword': _passwordController.text.isNotEmpty,
    });

    if (!_formKey.currentState!.validate()) {
      AppLogger.app.w('❌ Form validation failed');
      return;
    }

    AppLogger.app.d('✅ Form validation passed, proceeding with login');

    setState(() => _isLoading = true);

    try {
      final authService = ServiceLocator.get<AuthService>();
      AppLogger.app.d('🔐 Calling authService.login()');
      
      final user = await authService.login(
        _usernameController.text.trim(),
        _passwordController.text,
      );

      AppLogger.app.d('🔐 Login response received', error: {
        'user': user?.username,
        'success': user != null,
      });

      if (user != null && mounted) {
        AppLogger.app.i('✅ Login successful, navigating to /worlds');
        context.go('/worlds');
      } else if (mounted) {
        AppLogger.app.w('❌ Login failed - invalid credentials');
        _showError(l10n.authLoginFailedCredentials);
      }
    } catch (e) {
      AppLogger.app.e('❌ Login error', error: e);
      if (mounted) {
        _showError(e.toString());
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Theme.of(context).colorScheme.error,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return AuthScaffold(
      titleText: l10n.authLoginTitle,
      body: AppContent(
        maxWidth: 400,
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Welcome Card
              AppCard(
                type: AppCardType.outlined,
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    Text(
                      '🌍 ${l10n.authLoginWelcome}',
                      style: theme.textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      l10n.authLoginSubtitle,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 32),
              
              // Login Form Card
              AppCard(
                type: AppCardType.elevated,
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    AppTextField(
                       label: l10n.authUsernameLabel,
                       controller: _usernameController,
                       type: AppTextFieldType.text,
                       hint: l10n.authUsernameHint,
                       prefixIcon: Icons.person_outline,
                       isRequired: true,
                       validator: (value) => Validators.requiredText(value, l10n, fieldName: l10n.authUsernameLabel),
                     ),
                    
                    const SizedBox(height: 24),
                    
                    AppTextField(
                      label: l10n.authPasswordLabel,
                      controller: _passwordController,
                      type: AppTextFieldType.password,
                      hint: l10n.authPasswordHint,
                      prefixIcon: Icons.lock_outline,
                      isRequired: true,
                      validator: (value) => Validators.requiredText(value, l10n, fieldName: l10n.authPasswordLabel),
                    ),
                    
                    const SizedBox(height: 32),
                    
                    AppButton(
                      onPressed: _isLoading ? null : _login,
                      type: AppButtonType.primary,
                      size: AppButtonSize.large,
                      fullWidth: true,
                      isLoading: _isLoading,
                      icon: Icons.login,
                      child: Flexible(
                        child: Text(
                          l10n.authLoginButton,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // Register and Forgot Password Links
                    Wrap(
                      alignment: WrapAlignment.center,
                      spacing: 8.0,
                      runSpacing: 4.0,
                      children: [
                        TextButton(
                          onPressed: () => context.go('/forgot-password'),
                          child: Text(l10n.authForgotPassword),
                        ),
                        Text(
                          '|',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                          ),
                        ),
                        TextButton(
                          onPressed: () => context.go('/register'),
                          child: Text(l10n.authRegisterButton),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
