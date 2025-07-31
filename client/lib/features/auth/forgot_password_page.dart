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

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final AuthService _authService = AuthService();
  
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  
  bool _isLoading = false;
  bool _isSuccess = false;
  String? _errorMessage;
  
  // E-Mail-Validierung Regex
  static final RegExp _emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+$');

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
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _requestPasswordReset() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _isSuccess = false;
    });

    try {
      final success = await _authService.requestPasswordReset(
        _emailController.text.trim(),
      );

      if (success && mounted) {
        setState(() {
          _isSuccess = true;
        });
        AppLogger.app.i('✅ Password Reset Request erfolgreich');
      } else {
        setState(() {
          _errorMessage = AppLocalizations.of(context).errorGeneral;
        });
      }
    } catch (e) {
      AppLogger.app.e('❌ Password Reset Request Fehler', error: e);
      setState(() {
        _errorMessage = AppLocalizations.of(context).errorNetwork;
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

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
                      valueColor: AlwaysStoppedAnimation<Color>(AppColors.aqua),
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
      pageTitle: AppLocalizations.of(context).authForgotPasswordTitle,
      subtitle: AppLocalizations.of(context).authForgotPasswordDescription,
      padding: const EdgeInsets.all(AppSpacing.sectionMedium),
      context: context,
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            
            // 📧 Email field
            TextFormField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              autofillHints: const [AutofillHints.email],
              textInputAction: TextInputAction.done,
              onFieldSubmitted: (_) => _isLoading ? null : _requestPasswordReset(),
              decoration: InputDecoration(
                labelText: AppLocalizations.of(context).authEmailLabel,
                prefixIcon: Icon(Icons.email_outlined, color: AppColors.aqua),

              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return AppLocalizations.of(context).authEmailRequired;
                }
                if (!_emailRegex.hasMatch(value.trim())) {
                  return AppLocalizations.of(context).errorValidationEmail;
                }
                return null;
              },
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
                    Icon(
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
            
            // 🎯 Magischer Reset-Button
            SizedBox(
              width: double.infinity,
              child: DynamicComponents.primaryButton(
                text: AppLocalizations.of(context).authForgotPasswordSendButton,
                onPressed: _isLoading ? null : _requestPasswordReset,
                isLoading: _isLoading,
                icon: Icons.send_rounded,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            
              // Back to Login
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  DynamicComponents.secondaryButton(
                    text: AppLocalizations.of(context).authBackToLogin,
                    onPressed: () => context.goNamed('login'),
                    size: AppButtonSize.small,
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSuccessView(bool isDark) {
    return DynamicComponents.authFrame(
      welcomeTitle: AppLocalizations.of(context).authLoginWelcome,
      pageTitle: AppLocalizations.of(context).authForgotPasswordSuccess,
      subtitle: AppLocalizations.of(context).authForgotPasswordDescription,
      padding: const EdgeInsets.all(AppSpacing.sectionMedium),
      context: context,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Success Icon
          Container(
            padding: const EdgeInsets.all(AppSpacing.lg),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.success.withValues(alpha: 0.1),
              border: Border.all(
                color: AppColors.success.withValues(alpha: 0.3),
                width: 2,
              ),
            ),
            child: Icon(
              Icons.mark_email_read_rounded,
              size: 48,
              color: AppColors.success,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          
          // Success Message
          Text(
            AppLocalizations.of(context).authForgotPasswordTitle,
            style: AppTypography.h4(isDark: isDark),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            AppLocalizations.of(context).authForgotPasswordSuccess,
            style: AppTypography.bodyMedium(isDark: isDark),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.sectionSmall),
          
          // Actions
          Column(
            children: [
              SizedBox(
                width: double.infinity,
                child: DynamicComponents.secondaryButton(
                  text: AppLocalizations.of(context).authForgotPasswordBackToLogin,
                  onPressed: () => context.goNamed('login'),
                  size: AppButtonSize.medium,
                  icon: Icons.arrow_back_rounded,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              DynamicComponents.secondaryButton(
                text: AppLocalizations.of(context).authForgotPasswordSendButton,
                onPressed: () {
                  setState(() {
                    _isSuccess = false;
                    _errorMessage = null;
                  });
                },
                size: AppButtonSize.small,
              ),
            ],
          ),
        ],
      ),
    );
  }
}