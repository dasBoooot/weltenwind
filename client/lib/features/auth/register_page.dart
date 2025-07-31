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

// ServiceLocator Import für DI
import '../../main.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  
  late final AuthService _authService;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  
  bool _isLoading = false;
  bool _obscurePassword = true;
  String? _registerError;
  
  // Invite-Parameter
  String? _inviteToken;
  String? _prefilledEmail;
  Map<String, dynamic>? _inviteData;

  // E-Mail-Validierung Regex
  static final RegExp _emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+$');

  // Für bessere Validierung
  bool _hasInteractedWithUsername = false;
  bool _hasInteractedWithEmail = false;
  bool _hasInteractedWithPassword = false;

  @override
  void initState() {
    super.initState();
    _initializeServices();
    _loadQueryParameters();
    
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
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _initializeServices() {
    try {
      if (ServiceLocator.has<AuthService>()) {
        _authService = ServiceLocator.get<AuthService>();
      } else {
        _authService = AuthService();
      }
    } catch (e) {
      AppLogger.app.w('⚠️ ServiceLocator Fehler - nutze direkte Instanziierung', error: e);
      _authService = AuthService();
    }
  }

  void _loadQueryParameters() {
    // Load invite parameters if available
    // Implementation would depend on your routing setup
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
      _registerError = null;
    });

    try {
      final username = _usernameController.text.trim();
      final email = _emailController.text.trim();
      final password = _passwordController.text;

      final user = await _authService.register(username, email, password);

      if (user != null) {
        AppLogger.app.i('✅ Registrierung erfolgreich für User: ${user.username}');
        
        if (mounted) {
          // Nach erfolgreicher Registrierung zur Login-Seite oder direkt einloggen
          context.goNamed('login');
        }
      } else {
        setState(() {
          _registerError = AppLocalizations.of(context).errorGeneral;
        });
      }
    } catch (e) {
      AppLogger.app.e('❌ Registrierung Fehler', error: e);
      setState(() {
        _registerError = AppLocalizations.of(context).errorGeneral;
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
                      child: DynamicComponents.authFrame(
                        welcomeTitle: AppLocalizations.of(context).authLoginWelcome,
                        pageTitle: AppLocalizations.of(context).authRegisterTitle,
                        subtitle: AppLocalizations.of(context).authRegisterSubtitle,
                        padding: const EdgeInsets.all(AppSpacing.sectionMedium),
                        context: context,
                        child: Form(
                          key: _formKey,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              
                              // 📝 Username field
                              TextFormField(
                                controller: _usernameController,
                                autofillHints: const [AutofillHints.username],
                                textInputAction: TextInputAction.next,
                                onChanged: (_) {
                                  if (!_hasInteractedWithUsername) {
                                    setState(() {
                                      _hasInteractedWithUsername = true;
                                    });
                                  }
                                },
                                decoration: InputDecoration(
                                  labelText: AppLocalizations.of(context).authUsernameLabel,
                                  prefixIcon: Icon(Icons.person, color: AppColors.secondary),
                                ),
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return AppLocalizations.of(context).authUsernameRequired;
                                  }
                                  if (value.trim().length < 3) {
                                    return AppLocalizations.of(context).authUsernameMinLength;
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: AppSpacing.md),
                              
                              // 📧 Email field
                              TextFormField(
                                controller: _emailController,
                                keyboardType: TextInputType.emailAddress,
                                autofillHints: const [AutofillHints.email],
                                textInputAction: TextInputAction.next,
                                onChanged: (_) {
                                  if (!_hasInteractedWithEmail) {
                                    setState(() {
                                      _hasInteractedWithEmail = true;
                                    });
                                  }
                                },
                                decoration: InputDecoration(
                                  labelText: AppLocalizations.of(context).authEmailLabel,
                                  prefixIcon: Icon(Icons.email, color: AppColors.secondary),
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
                              const SizedBox(height: AppSpacing.md),
                              
                              // 🔒 Password field
                              TextFormField(
                                controller: _passwordController,
                                obscureText: _obscurePassword,
                                autofillHints: const [AutofillHints.newPassword],
                                textInputAction: TextInputAction.done,
                                onFieldSubmitted: (_) => _isLoading ? null : _register(),
                                onChanged: (_) {
                                  if (!_hasInteractedWithPassword) {
                                    setState(() {
                                      _hasInteractedWithPassword = true;
                                    });
                                  }
                                },
                                decoration: InputDecoration(
                                  labelText: AppLocalizations.of(context).authPasswordLabel,
                                  prefixIcon: Icon(Icons.lock, color: AppColors.secondary),
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
                                    return AppLocalizations.of(context).authPasswordRequired;
                                  }
                                  if (value.length < 6) {
                                    return AppLocalizations.of(context).authPasswordMinLength;
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: AppSpacing.lg),
                              
                              // Error message
                              if (_registerError != null)
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
                                          _registerError!,
                                          style: AppTypography.bodySmall(
                                            color: AppColors.error,
                                            isDark: isDark,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              
                              // 🎯 Magischer Register-Button
                              SizedBox(
                                width: double.infinity,
                                child: DynamicComponents.primaryButton(
                                  text: AppLocalizations.of(context).authRegisterButton,
                                  onPressed: _isLoading ? null : _register,
                                  isLoading: _isLoading,
                                  icon: Icons.person_add_rounded,
                                ),
                              ),
                              const SizedBox(height: AppSpacing.lg),
                              
                              // Login-Link
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    AppLocalizations.of(context).authHaveAccount,
                                    style: AppTypography.bodyMedium(isDark: isDark),
                                  ),
                                  const SizedBox(width: AppSpacing.sm),
                                  DynamicComponents.secondaryButton(
                                    text: AppLocalizations.of(context).authLoginButton,
                                    onPressed: () => context.goNamed('login'),
                                    size: AppButtonSize.small,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
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
}