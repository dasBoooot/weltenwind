import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../config/logger.dart';
import '../../core/services/auth_service.dart';
import '../../core/services/api_service.dart';
import '../../core/theme/index.dart';
import '../../shared/navigation/smart_navigation.dart';
import '../../shared/components/index.dart' hide ThemeSwitcher;
import '../../theme/background_widget.dart';
import '../../l10n/app_localizations.dart';
import '../../shared/widgets/language_switcher.dart';
import '../../shared/widgets/theme_switcher.dart';
import '../../shared/utils/dynamic_components.dart';

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

  // Für bessere Validierung (removed unused variables to fix focus loss)

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
              await context.smartGoNamed('login');
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
                  content: Text(AppLocalizations.of(context)!.worldJoinSuccess(worldName ?? '')),
                  backgroundColor: Theme.of(context).colorScheme.primary,
                ),
              );
              
              if (worldId != null) {
                await context.smartGo('/go/worlds/$worldId/join');
              } else {
                await context.smartGoNamed('world-list');
              }
            }
            return;
          }
        }
        
        // Fallback: Bei Fehler zur Invite-Seite leiten
        AppLogger.app.w('⚠️ Auto-accept failed, redirecting to invite page');
        if (mounted) await context.smartGo('/go/invite/$_inviteToken');
        
      } catch (e) {
        AppLogger.error.e('❌ Fehler beim Auto-Accept von Invite', error: e);
        // Fallback: Bei Fehler zur Invite-Seite leiten
        if (mounted) await context.smartGo('/go/invite/$_inviteToken');
      }
    } else {
      // Normale Registrierung ohne Auto-Accept -> zu Login
      AppLogger.app.i('🏠 Normal registration, going to login');
      if (mounted) await context.smartGoNamed('login');
    }
  }

  @override
  Widget build(BuildContext context) {
    // 🎯 SMART NAVIGATION THEME: Verwendet vorgeladenes Theme aus Smart Navigation
    return _buildRegisterPage(context, Theme.of(context), null);
  }

  Widget _buildRegisterPage(BuildContext context, ThemeData theme, Map<String, dynamic>? extensions) {
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
                      child: DynamicComponents.authFrame(
                        welcomeTitle: AppLocalizations.of(context).authLoginWelcome,
                        pageTitle: AppLocalizations.of(context).authRegisterTitle,
                        subtitle: AppLocalizations.of(context).authRegisterSubtitle,
                        padding: theme.dialogTheme.contentTextStyle != null 
                          ? EdgeInsets.all(theme.textTheme.headlineSmall?.fontSize ?? 32.0)
                          : const EdgeInsets.all(32.0),
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
                                                                  // Fix: Removed setState to prevent focus loss during typing
                                },
                                decoration: InputDecoration(
                                  labelText: AppLocalizations.of(context).authUsernameLabel,
                                  prefixIcon: Icon(Icons.person, color: theme.colorScheme.primary),
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
                              SizedBox(height: theme.textTheme.bodyMedium?.fontSize ?? 16.0),
                              
                              // 📧 Email field
                              TextFormField(
                                controller: _emailController,
                                keyboardType: TextInputType.emailAddress,
                                autofillHints: const [AutofillHints.email],
                                textInputAction: TextInputAction.next,
                                onChanged: (_) {
                                                                  // Fix: Removed setState to prevent focus loss during typing
                                },
                                decoration: InputDecoration(
                                  labelText: AppLocalizations.of(context).authEmailLabel,
                                  prefixIcon: Icon(Icons.email, color: theme.colorScheme.primary),
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
                              SizedBox(height: theme.textTheme.bodyMedium?.fontSize ?? 16.0),
                              
                              // 🔒 Password field
                              TextFormField(
                                controller: _passwordController,
                                obscureText: _obscurePassword,
                                autofillHints: const [AutofillHints.newPassword],
                                textInputAction: TextInputAction.done,
                                onFieldSubmitted: (_) => _isLoading ? null : _register(),
                                onChanged: (_) {
                                                                  // Fix: Removed setState to prevent focus loss during typing
                                },
                                decoration: InputDecoration(
                                  labelText: AppLocalizations.of(context).authPasswordLabel,
                                  prefixIcon: Icon(Icons.lock, color: theme.colorScheme.primary),
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
                              SizedBox(height: theme.textTheme.headlineSmall?.fontSize ?? 24.0),
                              
                              // Error message
                              if (_registerError != null)
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
                                          _registerError!,
                                          style: theme.textTheme.bodySmall?.copyWith(
                                            color: theme.colorScheme.error,
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
                              SizedBox(height: theme.textTheme.headlineSmall?.fontSize ?? 24.0),
                              
                              // Login-Link
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    AppLocalizations.of(context).authHaveAccount,
                                    style: theme.textTheme.bodyMedium,
                                  ),
                                  SizedBox(width: theme.textTheme.bodySmall?.fontSize ?? 8.0),
                                  DynamicComponents.secondaryButton(
                                    text: AppLocalizations.of(context).authLoginButton,
                                    onPressed: () async => await context.smartGoNamed('login'),
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
}