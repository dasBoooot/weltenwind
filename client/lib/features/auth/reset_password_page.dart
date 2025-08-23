import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../config/logger.dart';
import '../../core/services/auth_service.dart';
import '../../main.dart';
import '../../shared/components/layout/app_scaffold.dart';
import '../../shared/components/inputs/app_text_field.dart';
import '../../shared/components/buttons/app_button.dart';
import '../../shared/components/cards/app_card.dart';
// import '../../shared/components/layout/app_container.dart';
import '../../shared/components/layout/themed_panel.dart';
import '../../core/utils/validators.dart';
import '../../core/utils/security_utils.dart';
import '../../l10n/app_localizations.dart';
import '../../shared/theme/theme_manager.dart';
import '../../core/models/world.dart';
import '../../shared/components/layout/background_image.dart';

class ResetPasswordPage extends StatefulWidget {
  final String token;
  final String? email;

  const ResetPasswordPage({
    super.key,
    required this.token,
    this.email,
  });

  @override
  State<ResetPasswordPage> createState() => _ResetPasswordPageState();
}

class _ResetPasswordPageState extends State<ResetPasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  
  bool _isLoading = false;
  bool _showPasswordRequirements = false;
  bool _tokenValid = true;
  String? _tokenValidationError;
  
  late ThemeManager _themeManager;
  late World _defaultWorld;
  final _securityUtils = SecurityUtils();

  @override
  void initState() {
    super.initState();
    _themeManager = ThemeManager();
    _loadDefaultTheme();
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _validateResetToken();
    });
    
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
      // Create a default world for the reset password page
      _defaultWorld = World(
        id: 0,
        name: 'Default',
        status: WorldStatus.open,
        createdAt: DateTime.now(),
        startsAt: DateTime.now(),
        description: 'Default world for authentication',
        assets: 'default',
      );

      await _themeManager.clearWorldTheme();
    } catch (e) {
      AppLogger.app.w('⚠️ Failed to load default theme: $e');
      // Continue with fallback theme
    }
  }

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _securityUtils.clearSensitiveData();
    super.dispose();
  }

  Future<void> _validateResetToken() async {
    final l10n = AppLocalizations.of(context);
    
    try {
      setState(() => _isLoading = true);

      if (widget.token.isEmpty || widget.token.length < 32) {
        throw SecurityException('Invalid reset token format');
      }

      final authService = ServiceLocator.get<AuthService>();
      final isValid = await authService.validateResetToken(widget.token);

      if (mounted) {
        setState(() {
          _tokenValid = isValid;
          _isLoading = false;
          if (!isValid) {
            _tokenValidationError = l10n.authResetLinkInvalidExpired;
          }
        });
      }

    } catch (e) {
      AppLogger.app.e('❌ Token validation failed', error: e);
      if (mounted) {
        setState(() {
          _tokenValid = false;
          _isLoading = false;
          _tokenValidationError = _getSecureErrorMessage(e, l10n);
        });
      }
    }
  }

  Future<void> _handleResetPassword() async {
    final l10n = AppLocalizations.of(context);
    
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isLoading = true);

    try {
      await _performSecurityChecks(l10n);

      final authService = ServiceLocator.get<AuthService>();
      final success = await authService.resetPassword(widget.token, _passwordController.text);

      if (success && mounted) {
        _showSuccess(l10n.authResetPasswordSuccess);
        
        await Future.delayed(const Duration(seconds: 2));
        
        if (mounted) {
          context.go('/login');
        }
      } else if (mounted) {
        _showError(l10n.authResetPasswordFailed);
      }

    } catch (e) {
      AppLogger.app.e('❌ Reset password failed', error: e);
      if (mounted) {
        setState(() => _isLoading = false);
        _showError(_getSecureErrorMessage(e, l10n));
      }
    }
  }

  Future<void> _performSecurityChecks(AppLocalizations l10n) async {
    final canProceed = await _securityUtils.checkRateLimit('reset_password');
    if (!canProceed) {
      throw SecurityException(l10n.authTooManyResetAttempts);
    }

    final passwordStrength = _securityUtils.calculatePasswordStrength(_passwordController.text);
    if (passwordStrength < 60) {
      throw SecurityException(l10n.authPasswordTooWeak);
    }
    
    AppLogger.app.d('✅ Reset password security checks passed');
  }

  String _getSecureErrorMessage(dynamic error, AppLocalizations l10n) {
    if (error is SecurityException) {
      return error.message;
    }

    final errorString = error.toString().toLowerCase();
    
    if (errorString.contains('token') && errorString.contains('invalid')) {
      return l10n.authResetLinkInvalidRequest;
    }
    if (errorString.contains('token') && errorString.contains('expired')) {
      return l10n.authResetLinkExpiredRequest;
    }
    if (errorString.contains('network') || errorString.contains('connection')) {
      return l10n.authNetworkError;
    }
    
    return l10n.authUnableToResetPassword;
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
      titleText: l10n.authResetPassword,
      world: _defaultWorld,
      pageType: 'auth',
      overlayType: BackgroundOverlayType.gradient,
      overlayOpacity: 0.4,
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(vertical: 24),
        child: ThemedPanel(
          title: l10n.authResetPassword,
          subtitle: l10n.authResetPasswordSubtitle,
          maxWidth: 540,
          child: _isLoading 
              ? Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(
                      Theme.of(context).colorScheme.primary,
                    ),
                  ),
                )
              : _tokenValid ? _buildResetForm(l10n) : _buildInvalidTokenView(l10n),
        ),
      ),
    );
  }

  Widget _buildResetForm(AppLocalizations l10n) {
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
                  Icons.security,
                  size: 48,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(height: 16),
                Text(
                  l10n.authCreateNewPassword,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  l10n.authResetPasswordSubtitle,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                      ),
                  textAlign: TextAlign.center,
                ),
                if (widget.email != null) ...[
                  const SizedBox(height: 12),
                  Text(
                    widget.email!,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: theme.colorScheme.primary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
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
                  label: l10n.authNewPassword,
                  controller: _passwordController,
                  type: AppTextFieldType.password,
                  hint: l10n.authPasswordHint,
                  prefixIcon: Icons.lock_outline,
                  isRequired: true,
                  validator: (value) => Validators.password(value, l10n),
                  autofocus: true,
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
                
                const SizedBox(height: 32),
                
                AppButton(
                  onPressed: _isLoading ? null : _handleResetPassword,
                  type: AppButtonType.primary,
                  size: AppButtonSize.large,
                  fullWidth: true,
                  isLoading: _isLoading,
                  icon: Icons.security,
                  child: Text(l10n.authResetPassword),
                ),
                
                const SizedBox(height: 16),
                
                _buildSecurityTips(l10n),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInvalidTokenView(AppLocalizations l10n) {
    final theme = Theme.of(context);
    return Column(
      children: [
        AppCard(
          type: AppCardType.outlined,
          padding: const EdgeInsets.all(32),
          child: Column(
            children: [
              Icon(
                Icons.error_outline,
                size: 64,
                color: theme.colorScheme.error,
              ),
              const SizedBox(height: 24),
              Text(
                l10n.authInvalidResetLink,
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.error,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                _tokenValidationError ?? l10n.authResetLinkInvalidExpired,
                style: theme.textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
              
              const SizedBox(height: 32),
              
              AppButton(
                onPressed: () => context.go('/forgot-password'),
                type: AppButtonType.primary,
                size: AppButtonSize.large,
                fullWidth: true,
                icon: Icons.email_outlined,
                child: Text(l10n.authRequestNewResetLink),
              ),
              
              const SizedBox(height: 12),
              
              TextButton(
                onPressed: () => context.go('/login'),
                child: Text(l10n.authBackToLogin),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPasswordRequirements(AppLocalizations l10n) {
    final theme = Theme.of(context);
    final password = _passwordController.text;
    final requirements = Validators.getPasswordRequirements(password, l10n);
    final strength = _securityUtils.calculatePasswordStrength(password);

    return AppCard(
      type: AppCardType.filled,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                l10n.authPasswordStrengthLabel,
                style: theme.textTheme.labelMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                _getStrengthText(strength, l10n),
                style: theme.textTheme.labelMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: _getStrengthColor(strength),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: strength / 100,
            backgroundColor: theme.colorScheme.surfaceContainerHighest,
            valueColor: AlwaysStoppedAnimation<Color>(_getStrengthColor(strength)),
          ),
          const SizedBox(height: 12),
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

  Widget _buildSecurityTips(AppLocalizations l10n) {
    final theme = Theme.of(context);
    return AppCard(
      type: AppCardType.filled,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.tips_and_updates,
                size: 16,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(width: 8),
              Text(
                l10n.authSecurityTips,
                style: theme.textTheme.labelMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ..._securityUtils.getSecurityRecommendations()
              .take(3)
              .map((tip) => _buildTipItem(tip, l10n)),
        ],
      ),
    );
  }

  Widget _buildTipItem(String tip, AppLocalizations l10n) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.authListBullet,
            style: TextStyle(
              color: theme.colorScheme.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
          Expanded(
            child: Text(
              tip,
              style: theme.textTheme.bodySmall,
            ),
          ),
        ],
      ),
    );
  }

  String _getStrengthText(int strength, AppLocalizations l10n) {
    if (strength < 30) return l10n.authPasswordStrengthVeryWeak;
    if (strength < 50) return l10n.authPasswordStrengthWeak;
    if (strength < 70) return l10n.authPasswordStrengthFair;
    if (strength < 85) return l10n.authPasswordStrengthGood;
    return l10n.authPasswordStrengthStrong;
  }

  Color _getStrengthColor(int strength) {
    final theme = Theme.of(context);
    if (strength < 30) return theme.colorScheme.error;
    if (strength < 50) return theme.colorScheme.tertiary;
    if (strength < 70) return theme.colorScheme.secondary;
    if (strength < 85) return theme.colorScheme.primaryContainer;
    return theme.colorScheme.primary;
  }
}
