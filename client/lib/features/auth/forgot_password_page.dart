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
import '../../core/utils/validators.dart';
import '../../core/utils/security_utils.dart';
import '../../l10n/app_localizations.dart';
import '../../shared/theme/theme_manager.dart';
import '../../core/models/world.dart';
import '../../shared/components/layout/background_image.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  
  bool _isLoading = false;
  bool _emailSent = false;
  int _resendCooldown = 0;
  
  late ThemeManager _themeManager;
  late World _defaultWorld;
  final _securityUtils = SecurityUtils();

  @override
  void initState() {
    super.initState();
    _themeManager = ThemeManager();
    _loadDefaultTheme();
  }

  /// Load default world theme for pre-game context
  Future<void> _loadDefaultTheme() async {
    try {
      // Create a default world for the forgot password page
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
    _emailController.dispose();
    _securityUtils.clearSensitiveData();
    super.dispose();
  }

  Future<void> _handleForgotPassword() async {
    final l10n = AppLocalizations.of(context);
    
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isLoading = true);

    try {
      await _performSecurityChecks(l10n);

      final email = _securityUtils.sanitizeInput(_emailController.text.toLowerCase());

      final authService = ServiceLocator.get<AuthService>();
      await authService.requestPasswordReset(email);

      if (mounted) {
        setState(() {
          _emailSent = true;
          _isLoading = false;
          _resendCooldown = 60;
        });

        _showSuccess(l10n.authPasswordResetSentMessage);
        _startResendCooldown();
      }

    } catch (e) {
      AppLogger.app.e('❌ Forgot password failed', error: e);
      if (mounted) {
        setState(() => _isLoading = false);
        _showError(_getSecureErrorMessage(e, l10n));
      }
    }
  }

  Future<void> _handleResendEmail() async {
    final l10n = AppLocalizations.of(context);
    
    if (_resendCooldown > 0) return;

    try {
      final canResend = await _securityUtils.checkRateLimit('resend_password_reset');
      if (!canResend) {
        _showError(l10n.authTooManyResendAttempts);
        return;
      }

      setState(() => _isLoading = true);

      final email = _securityUtils.sanitizeInput(_emailController.text.toLowerCase());
      final authService = ServiceLocator.get<AuthService>();
      
      await authService.requestPasswordReset(email);

      if (mounted) {
        setState(() {
          _isLoading = false;
          _resendCooldown = 120;
        });

        _showSuccess(l10n.authResendEmailSuccess);
        _startResendCooldown();
      }

    } catch (e) {
      AppLogger.app.e('❌ Resend email failed', error: e);
      if (mounted) {
        setState(() => _isLoading = false);
        _showError(l10n.authResendEmailFailed);
      }
    }
  }

  Future<void> _performSecurityChecks(AppLocalizations l10n) async {
    final canProceed = await _securityUtils.checkRateLimit('forgot_password');
    if (!canProceed) {
      throw SecurityException(l10n.authTooManyResetAttempts);
    }

    _securityUtils.validateInputSecurity(_emailController.text);
    
    AppLogger.app.d('✅ Forgot password security checks passed');
  }

  void _startResendCooldown() {
    if (_resendCooldown <= 0) return;

    Future.delayed(const Duration(seconds: 1), () {
      if (mounted && _resendCooldown > 0) {
        setState(() => _resendCooldown--);
        _startResendCooldown();
      }
    });
  }

  String _getSecureErrorMessage(dynamic error, AppLocalizations l10n) {
    if (error is SecurityException) {
      return error.message;
    }

    final errorString = error.toString().toLowerCase();
    
    if (errorString.contains('network') || errorString.contains('connection')) {
      return l10n.authNetworkError;
    }
    if (errorString.contains('email') && errorString.contains('not found')) {
      return l10n.authEmailNotFoundSecure;
    }
    
    return l10n.authUnableToProcessRequest;
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

    return AuthScaffold(
      titleText: l10n.authForgotPassword,
      world: _defaultWorld,
      pageType: 'forgotPassword',
      overlayType: BackgroundOverlayType.gradient,
      overlayOpacity: 0.4,
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: AppContent(
          maxWidth: 450,
          child: _emailSent ? _buildEmailSentView(l10n) : _buildEmailInputView(l10n),
        ),
      ),
    );
  }

  Widget _buildEmailInputView(AppLocalizations l10n) {
    final theme = Theme.of(context);
    
    return Form(
      key: _formKey,
      child: Column(
        children: [
          AppCard(
            type: AppCardType.outlined,
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                Icon(
                  Icons.lock_reset,
                  size: 48,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(height: 16),
                Text(
                  l10n.authForgotPasswordTitle,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  l10n.authForgotPasswordSubtitle,
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
              children: [
                AppTextField(
                  label: l10n.authEmailLabel,
                  controller: _emailController,
                  type: AppTextFieldType.email,
                  hint: l10n.authEmailHint,
                  prefixIcon: Icons.email_outlined,
                  isRequired: true,
                  validator: (value) => Validators.email(value, l10n),
                  autofocus: true,
                ),
                
                const SizedBox(height: 24),
                
                AppButton(
                  onPressed: _isLoading ? null : _handleForgotPassword,
                  type: AppButtonType.primary,
                  size: AppButtonSize.large,
                  fullWidth: true,
                  isLoading: _isLoading,
                  icon: Icons.email_outlined,
                  child: Text(l10n.authSendResetEmail),
                ),
                
                const SizedBox(height: 16),
                
                Center(
                  child: TextButton(
                    onPressed: () => context.go('/login'),
                    child: Text(l10n.authBackToLogin),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmailSentView(AppLocalizations l10n) {
    final theme = Theme.of(context);
    
    return Column(
      children: [
        AppCard(
          type: AppCardType.outlined,
          padding: const EdgeInsets.all(32),
          child: Column(
            children: [
              Icon(
                Icons.mark_email_read,
                size: 64,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(height: 24),
              Text(
                l10n.authEmailSentTitle,
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.primary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                l10n.authEmailSentMessage,
                style: theme.textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                _emailController.text,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.primary,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
        
        const SizedBox(height: 32),
        
        AppCard(
          type: AppCardType.filled,
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.authNextStepsTitle,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),
              _buildInstructionItem(
                l10n.authStepCheckEmail,
                Icons.inbox,
              ),
              _buildInstructionItem(
                l10n.authStepClickLink,
                Icons.link,
              ),
              _buildInstructionItem(
                l10n.authStepCreatePassword,
                Icons.security,
              ),
              _buildInstructionItem(
                l10n.authStepLogin,
                Icons.login,
              ),
              
              const SizedBox(height: 16),
              
              AppButton(
                onPressed: _resendCooldown > 0 ? null : _handleResendEmail,
                type: AppButtonType.outlined,
                size: AppButtonSize.medium,
                fullWidth: true,
                isLoading: _isLoading,
                icon: Icons.refresh,
                child: Text(
                  _resendCooldown > 0 
                      ? '${l10n.authResendEmail} (${_resendCooldown}s)'
                      : l10n.authResendEmail,
                ),
              ),
              
              const SizedBox(height: 12),
              
              Center(
                child: TextButton(
                  onPressed: () => context.go('/login'),
                  child: Text(l10n.authBackToLogin),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildInstructionItem(String text, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(
            icon,
            size: 16,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
        ],
      ),
    );
  }
}

class SecurityException implements Exception {
  final String message;
  SecurityException(this.message);
  
  @override
  String toString() => 'SecurityException: $message';
}