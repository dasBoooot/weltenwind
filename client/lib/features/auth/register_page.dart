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
import '../../core/utils/security_utils.dart';
import '../../shared/theme/theme_manager.dart';
import '../../core/models/world.dart';
import '../../shared/components/layout/background_image.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isLoading = false;
  bool _acceptTerms = false;
  bool _acceptPrivacy = false;
  bool _showPasswordRequirements = false;
  late ThemeManager _themeManager;
  late World _defaultWorld;
  final _securityUtils = SecurityUtils();

  @override
  void initState() {
    super.initState();
    _themeManager = ThemeManager();
    _loadDefaultTheme();
    
    _passwordController.addListener(() {
      if (mounted) {
        if (_passwordController.text.isNotEmpty && !_showPasswordRequirements) {
          setState(() => _showPasswordRequirements = true);
        }
        setState(() {}); // Re-render to update requirements
      }
    });
  }

  /// Load default world theme for pre-game context
  Future<void> _loadDefaultTheme() async {
    try {
      // Create a default world for the register page
      _defaultWorld = World(
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
      await _themeManager.setWorldTheme(_defaultWorld, context: 'pre-game');
    } catch (e) {
      AppLogger.app.w('⚠️ Failed to load default theme: $e');
      // Continue with fallback theme
    }
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleRegister() async {
    final l10n = AppLocalizations.of(context);
    
    if (!_formKey.currentState!.validate()) {
      _showError(l10n.authValidationFixErrors);
      return;
    }

    if (!_acceptTerms || !_acceptPrivacy) {
      _showError(l10n.authAcceptTermsRequired);
      return;
    }

    setState(() => _isLoading = true);

    try {
      await _performSecurityChecks(l10n);

      final sanitizedData = _sanitizeInputs();

      final authService = ServiceLocator.get<AuthService>();
      final user = await authService.register(
        sanitizedData['username']!,
        sanitizedData['email']!,
        sanitizedData['password']!,
      );

      if (user != null && mounted) {
        _showSuccess(l10n.authRegisterSuccessMessage);
        
        await Future.delayed(const Duration(seconds: 1));
        
        if (mounted) {
          context.go('/worlds');
        }
      } else if (mounted) {
        _showError(l10n.authRegisterFailedGeneric);
      }

    } catch (e) {
      AppLogger.app.e('❌ Registration failed', error: e);
      if (mounted) {
        _showError(_getSecureErrorMessage(e, l10n));
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _performSecurityChecks(AppLocalizations l10n) async {
    final canProceed = await _securityUtils.checkRateLimit('register');
    if (!canProceed) {
      throw SecurityException(l10n.authTooManyRegistrationAttempts);
    }

    _securityUtils.validateInputSecurity(_usernameController.text);
    _securityUtils.validateInputSecurity(_emailController.text);
    
    AppLogger.app.d('✅ Security checks passed');
  }

  Map<String, String> _sanitizeInputs() {
    return {
      'username': _securityUtils.sanitizeInput(_usernameController.text),
      'email': _securityUtils.sanitizeInput(_emailController.text.toLowerCase()),
      'password': _passwordController.text,
    };
  }

  String _getSecureErrorMessage(dynamic error, AppLocalizations l10n) {
    if (error is SecurityException) {
      return error.message;
    }
    
    final errorString = error.toString().toLowerCase();
    
    if (errorString.contains('email') && errorString.contains('exist')) {
      return l10n.authEmailExistsError;
    }
    if (errorString.contains('username') && errorString.contains('taken')) {
      return l10n.authUsernameTakenError;
    }
    if (errorString.contains('network') || errorString.contains('connection')) {
      return l10n.authNetworkError;
    }
    
    return l10n.authRegisterFailedGeneric;
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Theme.of(context).colorScheme.error,
        duration: const Duration(seconds: 4),
      ),
    );
  }

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Theme.of(context).colorScheme.primary,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return AuthScaffold(
      titleText: l10n.authRegisterTitle,
      world: _defaultWorld,
      pageType: 'register',
      overlayType: BackgroundOverlayType.gradient,
      overlayOpacity: 0.4,
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: AppContent(
          maxWidth: 500,
          child: Form(
          key: _formKey,
          child: Column(
            children: [
              AppCard(
                type: AppCardType.outlined,
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    Text(
                      '🌍 ${l10n.authJoinWeltenwind}',
                      style: theme.textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      l10n.authRegisterSubtitle,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 32),
              
              AppCard(
                type: AppCardType.elevated,
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppTextField(
                      label: l10n.authUsernameLabel,
                      controller: _usernameController,
                      type: AppTextFieldType.text,
                      hint: l10n.authRegisterUsernameHint,
                      prefixIcon: Icons.person_outline,
                      isRequired: true,
                      validator: (value) => Validators.username(value, l10n),
                    ),
                    
                    const SizedBox(height: 20),
                    
                    AppTextField(
                      label: l10n.authEmailLabel,
                      controller: _emailController,
                      type: AppTextFieldType.email,
                      hint: l10n.authEmailHint,
                      prefixIcon: Icons.email_outlined,
                      isRequired: true,
                      validator: (value) => Validators.email(value, l10n),
                    ),
                    
                    const SizedBox(height: 20),
                    
                    AppTextField(
                      label: l10n.authPasswordLabel,
                      controller: _passwordController,
                      type: AppTextFieldType.password,
                      hint: l10n.authRegisterPasswordHint,
                      prefixIcon: Icons.lock_outline,
                      isRequired: true,
                      validator: (value) => Validators.password(value, l10n),
                    ),
                    
                    if (_showPasswordRequirements) ...[
                      const SizedBox(height: 12),
                      _buildPasswordRequirements(l10n),
                    ],
                    
                    const SizedBox(height: 20),
                    
                    AppTextField(
                      label: l10n.authConfirmPassword,
                      controller: _confirmPasswordController,
                      type: AppTextFieldType.password,
                      hint: l10n.authConfirmPasswordHint,
                      prefixIcon: Icons.lock_outline,
                      isRequired: true,
                      validator: (value) => Validators.confirmPassword(value, _passwordController.text, l10n),
                    ),
                    
                    const SizedBox(height: 24),
                    
                    _buildAgreementCheckboxes(l10n),
                    
                    const SizedBox(height: 32),
                    
                    SizedBox(
                      width: double.infinity,
                      child: AppButton(
                        onPressed: _isLoading ? null : _handleRegister,
                        type: AppButtonType.primary,
                        size: AppButtonSize.large,
                        fullWidth: false,
                        isLoading: _isLoading,
                        icon: Icons.person_add,
                        child: Text(
                          l10n.authRegisterButton,
                          style: const TextStyle(
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 16),
                    
                    Center(
                      child: TextButton(
                        onPressed: () => context.go('/login'),
                        child: Text(l10n.authAlreadyHaveAccount),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    )
    );
  }

  Widget _buildPasswordRequirements(AppLocalizations l10n) {
    final theme = Theme.of(context);
    final password = _passwordController.text;
    final requirements = Validators.getPasswordRequirements(password, l10n);

    return AppCard(
      type: AppCardType.filled,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.authPasswordRequirementsTitle,
            style: theme.textTheme.labelMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          ...requirements.map((req) => _buildRequirementItem(req)),
        ],
      ),
    );
  }

  Widget _buildRequirementItem(PasswordRequirement req) {
    final theme = Theme.of(context);
          final color = req.isMet 
          ? theme.colorScheme.primary 
          : theme.colorScheme.onSurface.withValues(alpha: 0.6);
    
    final icon = req.isMet ? Icons.check_circle : Icons.radio_button_unchecked;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 8),
          Text(
            req.description,
            style: TextStyle(color: color, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildAgreementCheckboxes(AppLocalizations l10n) {
    final theme = Theme.of(context);
    return Column(
      children: [
        Row(
          children: [
            Checkbox(
              value: _acceptTerms,
              onChanged: (value) => setState(() => _acceptTerms = value ?? false),
            ),
            Expanded(
              child: GestureDetector(
                onTap: () => setState(() => _acceptTerms = !_acceptTerms),
                child: Text.rich(
                  TextSpan(
                    text: l10n.authIAgreeToThe,
                    children: [
                      TextSpan(
                        text: l10n.authTermsOfService,
                        style: TextStyle(
                          color: theme.colorScheme.primary,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ],
                  ),
                  style: theme.textTheme.bodySmall,
                ),
              ),
            ),
          ],
        ),
        
        Row(
          children: [
            Checkbox(
              value: _acceptPrivacy,
              onChanged: (value) => setState(() => _acceptPrivacy = value ?? false),
            ),
            Expanded(
              child: GestureDetector(
                onTap: () => setState(() => _acceptPrivacy = !_acceptPrivacy),
                child: Text.rich(
                  TextSpan(
                    text: l10n.authIAgreeToThe,
                    children: [
                      TextSpan(
                        text: l10n.authPrivacyPolicy,
                        style: TextStyle(
                          color: theme.colorScheme.primary,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ],
                  ),
                  style: theme.textTheme.bodySmall,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class SecurityException implements Exception {
  final String message;
  SecurityException(this.message);
  
  @override
  String toString() => 'SecurityException: $message';
}