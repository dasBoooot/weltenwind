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
    // 🎯 SMART NAVIGATION THEME: Verwendet vorgeladenes Theme aus Smart Navigation
    return _buildForgotPasswordPage(context, Theme.of(context), null);
  }

  Widget _buildForgotPasswordPage(BuildContext context, ThemeData theme, Map<String, dynamic>? extensions) {
    return Scaffold(
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
      pageTitle: AppLocalizations.of(context).authForgotPasswordTitle,
      subtitle: AppLocalizations.of(context).authForgotPasswordDescription,
      padding: theme.dialogTheme.contentTextStyle != null 
          ? EdgeInsets.all(theme.textTheme.headlineSmall?.fontSize ?? 32.0)
          : const EdgeInsets.all(32.0),
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
                prefixIcon: Icon(Icons.email_outlined, color: theme.colorScheme.primary),

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
            SizedBox(height: theme.textTheme.headlineSmall?.fontSize ?? 24.0),
            
              // Back to Login
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  DynamicComponents.secondaryButton(
                    text: AppLocalizations.of(context).authBackToLogin,
                    onPressed: () async => await context.smartGoNamed('login'),
                    size: AppButtonSize.small,
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSuccessView(ThemeData theme) {
    return DynamicComponents.authFrame(
      welcomeTitle: AppLocalizations.of(context).authLoginWelcome,
      pageTitle: AppLocalizations.of(context).authForgotPasswordSuccess,
      subtitle: AppLocalizations.of(context).authForgotPasswordDescription,
      padding: theme.dialogTheme.contentTextStyle != null 
          ? EdgeInsets.all(theme.textTheme.headlineSmall?.fontSize ?? 32.0)
          : const EdgeInsets.all(32.0),
      context: context,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Success Icon
          Container(
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
              Icons.mark_email_read_rounded,
              size: 48,
              color: theme.colorScheme.tertiary,
            ),
          ),
          SizedBox(height: theme.textTheme.headlineSmall?.fontSize ?? 24.0),
          
          // Success Message
          Text(
            AppLocalizations.of(context).authForgotPasswordTitle,
            style: theme.textTheme.headlineMedium,
            textAlign: TextAlign.center,
          ),
          SizedBox(height: theme.textTheme.bodySmall?.fontSize ?? 8.0),
          Text(
            AppLocalizations.of(context).authForgotPasswordSuccess,
            style: theme.textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
          SizedBox(height: theme.textTheme.bodyLarge?.fontSize ?? 18.0),
          
          // Actions
          Column(
            children: [
              SizedBox(
                width: double.infinity,
                child: DynamicComponents.secondaryButton(
                  text: AppLocalizations.of(context).authForgotPasswordBackToLogin,
                  onPressed: () async => await context.smartGoNamed('login'),
                  size: AppButtonSize.medium,
                  icon: Icons.arrow_back_rounded,
                ),
              ),
              SizedBox(height: theme.textTheme.bodySmall?.fontSize ?? 8.0),
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