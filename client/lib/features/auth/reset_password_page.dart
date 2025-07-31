import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../config/logger.dart';
import '../../core/services/auth_service.dart';
import '../../theme/tokens/colors.dart';
import '../../theme/tokens/spacing.dart';
import '../../theme/tokens/typography.dart';
import '../../shared/components/index.dart';
import '../../theme/background_widget.dart';
import '../../l10n/app_localizations.dart';
import '../../shared/widgets/language_switcher.dart';
import '../../shared/widgets/theme_switcher.dart';
import '../../shared/utils/dynamic_components.dart';
import '../../core/providers/theme_provider.dart';

class ResetPasswordPage extends StatefulWidget {
  final String token;
  
  const ResetPasswordPage({
    super.key,
    required this.token,
  });

  @override
  State<ResetPasswordPage> createState() => _ResetPasswordPageState();
}

class _ResetPasswordPageState extends State<ResetPasswordPage> with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final AuthService _authService = AuthService();
  
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  
  bool _isLoading = false;
  bool _isSuccess = false;
  String? _errorMessage;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  
  // Für bessere Validierung
  bool _hasInteractedWithPassword = false;
  bool _hasInteractedWithConfirmPassword = false;

  @override
  void initState() {
    super.initState();
    
    // Animation Setup
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeIn,
    ));
    
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _resetPassword() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final success = await _authService.resetPassword(
        widget.token,
        _passwordController.text,
      );

      if (success && mounted) {
        setState(() {
          _isSuccess = true;
        });
        AppLogger.app.i('✅ Password Reset erfolgreich');
        
        // Nach 3 Sekunden zur Login-Seite weiterleiten
        Future.delayed(const Duration(seconds: 3), () {
          if (mounted) {
            context.goNamed('login');
          }
        });
      } else {
        setState(() {
          _errorMessage = AppLocalizations.of(context).errorGeneral;
        });
      }
    } catch (e) {
      AppLogger.app.e('❌ Password Reset Fehler', error: e);
      final error = e.toString().replaceAll('Exception: ', '');
      
      setState(() {
        if (error.contains('expired') || error.contains('invalid')) {
          _errorMessage = AppLocalizations.of(context).authResetPasswordInvalidToken;
        } else {
          _errorMessage = AppLocalizations.of(context).errorGeneral;
        }
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  bool get _passwordsMatch => 
      _passwordController.text.isNotEmpty && 
      _passwordController.text == _confirmPasswordController.text;

  bool get _passwordLengthValid => _passwordController.text.length >= 6;

  bool get _passwordHasNoSpaces => !_passwordController.text.contains(' ');

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return Scaffold(
      body: Stack(
        children: [
          BackgroundWidget(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(AppSpacing.pageHorizontal),
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 420),
                      child: _isSuccess
                          ? _buildSuccessView(isDark)
                          : _buildFormView(isDark),
                    ),
                  ),
                ),
              ),
            ),
          ),
          
          // Loading Overlay
          if (_isLoading)
            Container(
              color: Colors.black.withValues(alpha: 0.7),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(AppColors.secondary),
                      strokeWidth: 3,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Text(
                      AppLocalizations.of(context).authLoginLoading,
                      style: AppTypography.bodyLarge(
                        color: Colors.white,
                        isDark: true,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          
          // Language Switcher
          const Positioned(
            top: 40.0,
            left: 20.0,
            child: SafeArea(
              child: LanguageSwitcher(
                showLabel: false,
                isCompact: true,
              ),
            ),
          ),
          
          // Theme Switcher
          Positioned(
            top: 40.0,
            right: 20.0,
            child: SafeArea(
              child: ThemeSwitcher(
                currentThemeMode: ThemeProvider().themeMode,
                onThemeModeChanged: (mode) => ThemeProvider().setThemeMode(mode),
                currentStylePreset: ThemeProvider().stylePreset,
                onStylePresetChanged: (preset) => ThemeProvider().setStylePreset(preset),
                isCompact: true,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFormView(bool isDark) {
    return DynamicComponents.authFrame(
      welcomeTitle: AppLocalizations.of(context).authLoginWelcome,
      pageTitle: AppLocalizations.of(context).authResetPasswordTitle,
      subtitle: AppLocalizations.of(context).authResetPasswordDescription,
      padding: const EdgeInsets.all(AppSpacing.sectionMedium),
      context: context,
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            
            // 🔒 New Password field
            TextFormField(
              controller: _passwordController,
              obscureText: _obscurePassword,
              autofillHints: const [AutofillHints.newPassword],
              textInputAction: TextInputAction.next,
              onChanged: (_) {
                if (!_hasInteractedWithPassword) {
                  setState(() {
                    _hasInteractedWithPassword = true;
                  });
                } else {
                  setState(() {}); // Rebuild for real-time validation
                }
              },
              decoration: InputDecoration(
                labelText: AppLocalizations.of(context).authNewPasswordLabel,
                helperText: AppLocalizations.of(context).authPasswordHelperText,
                prefixIcon: const Icon(Icons.lock_outline, color: AppColors.secondary),
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscurePassword ? Icons.visibility : Icons.visibility_off,
                  ),
                  onPressed: () {
                    setState(() {
                      _obscurePassword = !_obscurePassword;
                    });
                  },
                ),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return AppLocalizations.of(context).authNewPasswordRequired;
                }
                if (value.length < 6) {
                  return AppLocalizations.of(context).authPasswordMinLength;
                }
                if (value.contains(' ')) {
                  return AppLocalizations.of(context).authPasswordNoSpaces;
                }
                return null;
              },
            ),
            const SizedBox(height: AppSpacing.md),
            
            // 🔒 Confirm Password field
            TextFormField(
              controller: _confirmPasswordController,
              obscureText: _obscureConfirmPassword,
              autofillHints: const [AutofillHints.newPassword],
              textInputAction: TextInputAction.done,
              onFieldSubmitted: (_) => _isLoading ? null : _resetPassword(),
              onChanged: (_) {
                if (!_hasInteractedWithConfirmPassword) {
                  setState(() {
                    _hasInteractedWithConfirmPassword = true;
                  });
                } else {
                  setState(() {}); // Rebuild for real-time validation
                }
              },
              decoration: InputDecoration(
                labelText: AppLocalizations.of(context).authConfirmPasswordLabel,
                prefixIcon: const Icon(Icons.lock, color: AppColors.secondary),
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscureConfirmPassword ? Icons.visibility : Icons.visibility_off,
                  ),
                  onPressed: () {
                    setState(() {
                      _obscureConfirmPassword = !_obscureConfirmPassword;
                    });
                  },
                ),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return AppLocalizations.of(context).authConfirmPasswordRequired;
                }
                if (value != _passwordController.text) {
                  return AppLocalizations.of(context).authPasswordsDoNotMatch;
                }
                return null;
              },
            ),
            const SizedBox(height: AppSpacing.md),
            
            // 📋 Password Requirements
            if (_hasInteractedWithPassword)
              Container(
                padding: const EdgeInsets.all(AppSpacing.sm),
                decoration: BoxDecoration(
                  color: AppColors.primaryAccent.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: AppColors.primaryAccent.withValues(alpha: 0.3),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppLocalizations.of(context).authPasswordRequirementsTitle,
                      style: AppTypography.labelLarge(isDark: isDark),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    _buildRequirement(
                      AppLocalizations.of(context).authRequirementMinLength,
                      _passwordLengthValid,
                      isDark,
                    ),
                    _buildRequirement(
                      AppLocalizations.of(context).authRequirementNoSpaces,
                      _passwordHasNoSpaces,
                      isDark,
                    ),
                    _buildRequirement(
                      AppLocalizations.of(context).authRequirementPasswordsMatch,
                      _passwordsMatch,
                      isDark,
                    ),
                  ],
                ),
              ),
            const SizedBox(height: AppSpacing.lg),
            
            // Error message
            if (_errorMessage != null)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(AppSpacing.sm),
                margin: const EdgeInsets.only(bottom: AppSpacing.md),
                decoration: BoxDecoration(
                  color: AppColors.error.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: AppColors.error.withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.error_outline,
                      color: AppColors.error,
                      size: 20,
                    ),
                    const SizedBox(width: AppSpacing.xs),
                    Expanded(
                      child: Text(
                        _errorMessage!,
                        style: AppTypography.bodySmall(
                          color: AppColors.error,
                          isDark: isDark,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            
            // 🎯 Reset Password Button
            SizedBox(
              width: double.infinity,
              child: DynamicComponents.primaryButton(
                text: AppLocalizations.of(context).authResetPasswordButton,
                onPressed: _isLoading ? null : _resetPassword,
                isLoading: _isLoading,
                icon: Icons.lock_reset_rounded,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            
            // Back to Login
            DynamicComponents.tertiaryButton(
              text: AppLocalizations.of(context).authBackToLogin,
              onPressed: () => context.goNamed('login'),
              size: AppButtonSize.small,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSuccessView(bool isDark) {
    return DynamicComponents.authFrame(
      welcomeTitle: AppLocalizations.of(context).authLoginWelcome,
      pageTitle: AppLocalizations.of(context).authResetPasswordTitle,
      subtitle: AppLocalizations.of(context).authBackToLogin,
      padding: const EdgeInsets.all(AppSpacing.sectionMedium),
      context: context,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Success Icon
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0.0, end: 1.0),
            duration: const Duration(milliseconds: 800),
            curve: Curves.elasticOut,
            builder: (context, value, child) {
              return Transform.scale(
                scale: value,
                child: child,
              );
            },
            child: Container(
              padding: const EdgeInsets.all(AppSpacing.lg),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.success.withValues(alpha: 0.1),
                border: Border.all(
                  color: AppColors.success.withValues(alpha: 0.3),
                  width: 2,
                ),
              ),
              child: const Icon(
                Icons.check_circle_rounded,
                size: 48,
                color: AppColors.success,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          
          // Success Message
          Text(
            AppLocalizations.of(context).authResetPasswordSuccessTitle,
            style: AppTypography.h4(isDark: isDark),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            AppLocalizations.of(context).authResetPasswordSuccessMessage,
            style: AppTypography.bodyMedium(isDark: isDark),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.sectionSmall),
          

          const SizedBox(height: AppSpacing.lg),
          
          // Manual redirect button
          SizedBox(
            width: double.infinity,
            child: DynamicComponents.secondaryButton(
              text: AppLocalizations.of(context).authBackToLogin,
              onPressed: () => context.goNamed('login'),
              size: AppButtonSize.medium,
              icon: Icons.arrow_forward_rounded,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRequirement(String text, bool isMet, bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Icon(
            isMet ? Icons.check_circle : Icons.circle_outlined,
            size: 16,
            color: isMet ? AppColors.success : AppColors.textSecondary,
          ),
          const SizedBox(width: AppSpacing.xs),
          Expanded(
            child: Text(
              text,
              style: AppTypography.bodySmall(
                color: isMet ? AppColors.success : AppColors.textSecondary,
                isDark: isDark,
              ),
            ),
          ),
        ],
      ),
    );
  }
}