import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../config/logger.dart';
import '../../core/services/auth_service.dart';
import '../../core/services/api_service.dart';
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
  bool _autoAcceptInvite = false;

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

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadQueryParameters();
  }

  void _loadQueryParameters() {
    // Load invite token from route extra data
    try {
      final routeState = GoRouterState.of(context);
      final extra = routeState.extra;
      
      if (extra is Map<String, dynamic>) {
        final newInviteToken = extra['invite_token'] as String?;
        final prefilledEmail = extra['email'] as String?;
        final autoAccept = extra['auto_accept_invite'] as bool? ?? false;
        
        if (newInviteToken != null && newInviteToken != _inviteToken) {
          _inviteToken = newInviteToken;
          _autoAcceptInvite = autoAccept;
          AppLogger.app.i('🎫 Invite token loaded from route: $_inviteToken (auto-accept: $autoAccept)');
        }
        
        if (prefilledEmail != null && prefilledEmail.isNotEmpty && _emailController.text.isEmpty) {
          _emailController.text = prefilledEmail;
        }
      }
    } catch (e) {
      AppLogger.app.w('⚠️ Could not load route parameters: $e');
    }
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
        AppLogger.app.i('✅ Registration successful: ${user.username}');
        
        if (mounted) {
          // Nach erfolgreicher Registrierung zur Login-Seite oder direkt einloggen
          // Wenn ein Invite-Token vorhanden ist, zurück zum Invite
          await _handlePostRegistration();
        }
      } else {
        setState(() {
          _registerError = AppLocalizations.of(context).errorGeneral;
        });
      }
    } catch (e) {
      AppLogger.error.e('❌ Registration failed', error: e);
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

  Future<void> _handlePostRegistration() async {
    AppLogger.app.i('🔄 _handlePostRegistration called with token: $_inviteToken (auto-accept: $_autoAcceptInvite)');
    
    if (_inviteToken == null) {
      AppLogger.app.i('❌ No invite token found, going to login');
      context.goNamed('login');
      return;
    }

    // Nur auto-akzeptieren wenn das Flag gesetzt ist (von Invite-Landing-Page)
    if (_autoAcceptInvite) {
      try {
        // Invite direkt akzeptieren statt nur zur Invite-Seite zurück
        AppLogger.app.i('🎫 Auto-accepting invite after registration: $_inviteToken');
        final apiService = ServiceLocator.get<ApiService>();
        final response = await apiService.post('/invites/accept/$_inviteToken', {});
        
        if (response.statusCode == 200) {
          final responseData = jsonDecode(response.body);
          if (responseData['success'] == true) {
            final worldId = responseData['data']?['world']?['id'];
            final worldName = responseData['data']?['world']?['name'];
            
            AppLogger.app.i('✅ Invite auto-accepted successfully: $worldName');
            
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Erfolgreich der Welt "$worldName" beigetreten!'),
                  backgroundColor: Colors.green,
                ),
              );
              
              if (worldId != null) {
                context.go('/go/worlds/$worldId/join');
              } else {
                context.goNamed('world-list');
              }
            }
            return;
          }
        }
        
        // Fallback: Bei Fehler zur Invite-Seite leiten
        AppLogger.app.w('⚠️ Auto-accept failed, redirecting to invite page');
        if (mounted) context.go('/go/invite/$_inviteToken');
        
      } catch (e) {
        AppLogger.error.e('❌ Fehler beim Auto-Accept von Invite', error: e);
        // Fallback: Bei Fehler zur Invite-Seite leiten
        if (mounted) context.go('/go/invite/$_inviteToken');
      }
    } else {
      // Normale Registrierung ohne Auto-Accept -> zu Login
      AppLogger.app.i('🏠 Normal registration, going to login');
      if (mounted) context.goNamed('login');
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
                                  prefixIcon: const Icon(Icons.person, color: AppColors.secondary),
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
                                  prefixIcon: const Icon(Icons.email, color: AppColors.secondary),
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
                                  prefixIcon: const Icon(Icons.lock, color: AppColors.secondary),
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
                                      const Icon(
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
}