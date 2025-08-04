import 'package:flutter/material.dart';
import '../../config/logger.dart';
import '../../core/services/auth_service.dart';
import '../../core/theme/index.dart';
import '../../shared/navigation/smart_navigation.dart';
import '../../shared/components/index.dart' hide ThemeSwitcher;
import '../../theme/background_widget.dart';
import '../../l10n/app_localizations.dart';
import '../../shared/widgets/language_switcher.dart';
import '../../shared/widgets/theme_switcher.dart';
import '../../shared/utils/dynamic_components.dart';

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
  
  // Für bessere Validierung (removed unused variables to fix focus loss)
  // bool _hasInteractedWithPassword = false;  // Removed to prevent setState focus issues
  // bool _hasInteractedWithConfirmPassword = false;  // Removed to prevent setState focus issues

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
        Future.delayed(const Duration(seconds: 3), () async {
          if (mounted) {
            await context.smartGoNamed('login');
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
    // 🎯 SMART NAVIGATION THEME: Verwendet vorgeladenes Theme aus Smart Navigation
    return _buildResetPasswordPage(context, Theme.of(context), null);
  }

  Widget _buildResetPasswordPage(BuildContext context, ThemeData theme, Map<String, dynamic>? extensions) {
    return AppScaffold(
      showBackgroundGradient: false, // 🎨 HYBRID: Disable AppScaffold gradient, use BackgroundWidget images
      body: Stack(
        children: [
          BackgroundWidget(
            child: Center(
              child: SingleChildScrollView(
                padding: theme.cardTheme.margin ?? const EdgeInsets.all(24.0),
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 420),
                      child: _isSuccess
                          ? _buildSuccessView(theme)
                          : _buildFormView(theme),
                    ),
                  ),
                ),
              ),
            ),
          ),
          
          // Loading Overlay
          if (_isLoading)
            Container(
              color: theme.colorScheme.surface.withValues(alpha: 0.9),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(theme.colorScheme.primary),
                      strokeWidth: 3,
                    ),
                    SizedBox(height: theme.textTheme.bodyMedium?.fontSize ?? 16.0),
                    Text(
                      AppLocalizations.of(context).authLoginLoading,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: theme.colorScheme.onSurface,
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
              child: LanguageSwitcher(),
            ),
          ),
          
          // Theme Switcher
          Positioned(
            top: 40.0,
            right: 20.0,
            child: SafeArea(
              child: ThemeSwitcher(
                themeProvider: ThemeProvider(),
                isCompact: true,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFormView(ThemeData theme) {
    return DynamicComponents.authFrame(
      welcomeTitle: AppLocalizations.of(context).authLoginWelcome,
      pageTitle: AppLocalizations.of(context).authResetPasswordTitle,
      subtitle: AppLocalizations.of(context).authResetPasswordDescription,
      padding: theme.dialogTheme.contentTextStyle != null 
          ? EdgeInsets.all(theme.textTheme.headlineSmall?.fontSize ?? 32.0)
          : const EdgeInsets.all(32.0),
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
                  // Fix: Removed setState to prevent focus loss during typing
                  // Password validation will happen on form submission
                },
              decoration: InputDecoration(
                labelText: AppLocalizations.of(context).authNewPasswordLabel,
                helperText: AppLocalizations.of(context).authPasswordHelperText,
                prefixIcon: Icon(Icons.lock_outline, color: theme.colorScheme.primary),
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
            SizedBox(height: theme.textTheme.bodyMedium?.fontSize ?? 16.0),
            
            // 🔒 Confirm Password field
            TextFormField(
              controller: _confirmPasswordController,
              obscureText: _obscureConfirmPassword,
              autofillHints: const [AutofillHints.newPassword],
              textInputAction: TextInputAction.done,
              onFieldSubmitted: (_) => _isLoading ? null : _resetPassword(),
                              onChanged: (_) {
                  // Fix: Removed setState to prevent focus loss during typing
                  // Password validation will happen on form submission
                },
              decoration: InputDecoration(
                labelText: AppLocalizations.of(context).authConfirmPasswordLabel,
                prefixIcon: Icon(Icons.lock, color: theme.colorScheme.primary),
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
            SizedBox(height: theme.textTheme.bodyMedium?.fontSize ?? 16.0),
            
            // 📋 Password Requirements
            // Always show password requirements (was: if (_hasInteractedWithPassword))
            if (true)
              Container(
                padding: EdgeInsets.all(theme.textTheme.bodySmall?.fontSize ?? 8.0),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: theme.colorScheme.primary.withValues(alpha: 0.3),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppLocalizations.of(context).authPasswordRequirementsTitle,
                      style: theme.textTheme.labelLarge,
                    ),
                    SizedBox(height: theme.textTheme.bodySmall?.fontSize ?? 4.0),
                    _buildRequirement(
                      AppLocalizations.of(context).authRequirementMinLength,
                      _passwordLengthValid,
                      theme,
                    ),
                    _buildRequirement(
                      AppLocalizations.of(context).authRequirementNoSpaces,
                      _passwordHasNoSpaces,
                      theme,
                    ),
                    _buildRequirement(
                      AppLocalizations.of(context).authRequirementPasswordsMatch,
                      _passwordsMatch,
                      theme,
                    ),
                  ],
                ),
              ),
              SizedBox(height: theme.textTheme.headlineSmall?.fontSize ?? 24.0),
            
            // Error message
            if (_errorMessage != null)
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(theme.textTheme.bodySmall?.fontSize ?? 8.0),
                margin: EdgeInsets.only(bottom: theme.textTheme.bodyMedium?.fontSize ?? 16.0),
                decoration: BoxDecoration(
                  color: theme.colorScheme.error.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: theme.colorScheme.error.withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.error_outline,
                      color: theme.colorScheme.error,
                      size: 20,
                    ),
                    SizedBox(width: theme.textTheme.bodySmall?.fontSize ?? 4.0),
                    Expanded(
                      child: Text(
                        _errorMessage!,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.error,
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
            SizedBox(height: theme.textTheme.headlineSmall?.fontSize ?? 24.0),
            
            // Back to Login
            DynamicComponents.tertiaryButton(
              text: AppLocalizations.of(context).authBackToLogin,
              onPressed: () async => await context.smartGoNamed('login'),
              size: AppButtonSize.small,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSuccessView(ThemeData theme) {
    return DynamicComponents.authFrame(
      welcomeTitle: AppLocalizations.of(context).authLoginWelcome,
      pageTitle: AppLocalizations.of(context).authResetPasswordTitle,
      subtitle: AppLocalizations.of(context).authBackToLogin,
      padding: theme.dialogTheme.contentTextStyle != null 
          ? EdgeInsets.all(theme.textTheme.headlineSmall?.fontSize ?? 32.0)
          : const EdgeInsets.all(32.0),
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
              padding: EdgeInsets.all(theme.textTheme.headlineSmall?.fontSize ?? 24.0),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: theme.colorScheme.tertiary.withValues(alpha: 0.1),
                border: Border.all(
                  color: theme.colorScheme.tertiary.withValues(alpha: 0.3),
                  width: 2,
                ),
              ),
              child: Icon(
                Icons.check_circle_rounded,
                size: 48,
                color: theme.colorScheme.tertiary,
              ),
            ),
          ),
          SizedBox(height: theme.textTheme.headlineSmall?.fontSize ?? 24.0),
          
          // Success Message
          Text(
            AppLocalizations.of(context).authResetPasswordSuccessTitle,
            style: theme.textTheme.headlineMedium,
            textAlign: TextAlign.center,
          ),
          SizedBox(height: theme.textTheme.bodySmall?.fontSize ?? 8.0),
          Text(
            AppLocalizations.of(context).authResetPasswordSuccessMessage,
            style: theme.textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
          SizedBox(height: theme.textTheme.bodyLarge?.fontSize ?? 18.0),
          SizedBox(height: theme.textTheme.headlineSmall?.fontSize ?? 24.0),
          
          // Manual redirect button
          SizedBox(
            width: double.infinity,
            child: DynamicComponents.secondaryButton(
              text: AppLocalizations.of(context).authBackToLogin,
              onPressed: () async => await context.smartGoNamed('login'),
              size: AppButtonSize.medium,
              icon: Icons.arrow_forward_rounded,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRequirement(String text, bool isMet, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Icon(
            isMet ? Icons.check_circle : Icons.circle_outlined,
            size: 16,
            color: isMet ? theme.colorScheme.tertiary : theme.colorScheme.onSurface.withValues(alpha: 0.6),
          ),
          SizedBox(width: theme.textTheme.bodySmall?.fontSize ?? 4.0),
          Expanded(
            child: Text(
              text,
              style: theme.textTheme.bodySmall?.copyWith(
                color: isMet ? theme.colorScheme.tertiary : theme.colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
          ),
        ],
      ),
    );
  }
}