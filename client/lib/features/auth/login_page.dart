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

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  
  late final AuthService _authService;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  
  bool _isLoading = false;
  bool _obscurePassword = true;
  String? _loginError;
  bool _rememberMe = false;
  
  // Invite-Parameter
  String? _inviteToken;
  bool _autoAcceptInvite = false;
  
  // Für bessere Validierung (removed unused variables)

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
        final autoAccept = extra['auto_accept_invite'] as bool? ?? false;
        
        if (newInviteToken != null && newInviteToken != _inviteToken) {
          _inviteToken = newInviteToken;
          _autoAcceptInvite = autoAccept;
          AppLogger.app.i('🎫 Invite token loaded from route: $_inviteToken (auto-accept: $autoAccept)');
        }
      }
    } catch (e) {
      AppLogger.app.w('⚠️ Could not load route parameters: $e');
    }
  }

  Future<void> _login() async {
    // Edge Case: User ist bereits angemeldet, aber kam von Invite-Page
    final isAlreadyLoggedIn = await _authService.isLoggedIn();
    if (isAlreadyLoggedIn && _inviteToken != null) {
      AppLogger.app.i('🔍 User already logged in, checking auto-accept for invite');
      await _handleInviteAccept();
      return;
    }

    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
      _loginError = null;
    });

    try {
      final username = _usernameController.text.trim();
      final password = _passwordController.text;

      final user = await _authService.login(username, password);

      if (user != null) {
        AppLogger.app.i('✅ Login successful: ${user.username}');
        
        if (mounted) {
          await _handleInviteAccept();
        }
      } else {
        setState(() {
          _loginError = AppLocalizations.of(context).errorUnauthorized;
        });
      }
    } catch (e) {
      AppLogger.error.e('❌ Login failed', error: e);
      setState(() {
        _loginError = AppLocalizations.of(context).errorGeneral;
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _handleInviteAccept() async {
    AppLogger.app.i('🔄 _handleInviteAccept called with token: $_inviteToken (auto-accept: $_autoAcceptInvite)');
    
    if (_inviteToken == null) {
      AppLogger.app.i('❌ No invite token found, going to world-list');
      await context.smartGoNamed('world-list');
      return;
    }

    // Auto-akzeptieren wenn das Flag gesetzt ist ODER User bereits angemeldet war (Edge Case)
    if (_autoAcceptInvite || await _authService.isLoggedIn()) {
      try {
        // Invite direkt akzeptieren statt nur zur Invite-Seite zurück
        AppLogger.app.i('🎫 Auto-accepting invite after login: $_inviteToken');
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
                  content: Text(AppLocalizations.of(context).worldJoinSuccess(worldName ?? '')),
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
      // Normales Login ohne Auto-Accept -> zu World-List
      AppLogger.app.i('🏠 Normal login, going to world-list');
      if (mounted) await context.smartGoNamed('worldList');
    }
  }

  @override
  Widget build(BuildContext context) {
    // 🎨 NEW: Using AppScaffold with integrated theme system
    return AppScaffoldBuilder.forAuthWithTheme(
      themeContext: 'auth',
      themeBundle: 'pre-game-minimal',
      body: _buildLoginBody(context),
    );
  }

  Widget _buildLoginBody(BuildContext context) {
    return Stack(
      children: [
        BackgroundWidget(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 420),
                    child: _buildLoginForm(context),
                  ),
                ),
              ),
            ),
          ),
        ),
        _buildLoadingOverlay(context),
        _buildLanguageSwitcher(),
        _buildThemeSwitcher(context),
      ],
    );
  }

  Widget _buildLoginForm(BuildContext context) {
    final theme = Theme.of(context);
    return DynamicComponents.authFrame(
      welcomeTitle: AppLocalizations.of(context).authLoginWelcome,
      pageTitle: AppLocalizations.of(context).authLoginTitle,
      subtitle: AppLocalizations.of(context).authLoginSubtitle,
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
            
            // 🔒 Password field
            TextFormField(
              controller: _passwordController,
              obscureText: _obscurePassword,
              autofillHints: const [AutofillHints.password],
              textInputAction: TextInputAction.done,
              onFieldSubmitted: (_) => _isLoading ? null : _login(),
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
                return null;
              },
            ),
            SizedBox(height: theme.textTheme.bodyMedium?.fontSize ?? 16.0),
            
            // Remember me + forgot password
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Checkbox(
                      value: _rememberMe,
                      onChanged: (value) {
                        setState(() {
                          _rememberMe = value ?? false;
                        });
                      },
                      activeColor: theme.colorScheme.primary,
                    ),
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          _rememberMe = !_rememberMe;
                        });
                      },
                      child: Text(
                        AppLocalizations.of(context).authRememberMe,
                        style: theme.textTheme.bodyMedium,
                      ),
                    ),
                  ],
                ),
                
                // 🔮 Passwort vergessen
                DynamicComponents.secondaryButton(
                  text: AppLocalizations.of(context).authForgotPassword,
                  onPressed: () async => await context.smartGoNamed('forgot-password'),
                  size: AppButtonSize.small,
                ),
              ],
            ),
            const SizedBox(height: kTextTabBarHeight / 3),
            
            // Error message
            if (_loginError != null)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(kTextTabBarHeight / 3),
                margin: const EdgeInsets.only(bottom: kTextTabBarHeight / 2),
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
                    const SizedBox(width: kTextTabBarHeight / 6),
                    Expanded(
                      child: Text(
                        _loginError!,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.error,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            
            // 🎯 Dynamischer Login-Button
            SizedBox(
              width: double.infinity,
              child: DynamicComponents.primaryButton(
                text: AppLocalizations.of(context).authLoginButton,
                onPressed: _isLoading ? null : _login,
                isLoading: _isLoading,
                icon: Icons.login_rounded,
              ),
            ),
            SizedBox(height: theme.textTheme.headlineSmall?.fontSize ?? 24.0),
            
            // Register-Bereich
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  AppLocalizations.of(context).authNoAccount,
                  style: theme.textTheme.bodyMedium,
                ),
                SizedBox(width: theme.textTheme.bodySmall?.fontSize ?? 8.0),
                DynamicComponents.secondaryButton(
                  text: AppLocalizations.of(context).authRegisterButton,
                  onPressed: () async => await context.smartGoNamed('register'),
                  size: AppButtonSize.small,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingOverlay(BuildContext context) {
    final theme = Theme.of(context);
    if (!_isLoading) return const SizedBox.shrink();
    
    return Container(
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
    );
  }

  Widget _buildLanguageSwitcher() {
    return const Positioned(
      top: 40.0,
      left: 20.0,
      child: SafeArea(
        child: LanguageSwitcher(),
      ),
    );
  }

  Widget _buildThemeSwitcher(BuildContext context) {
    return Positioned(
      top: 40.0,
      right: 20.0,
      child: SafeArea(
        child: ThemeSwitcher(
          themeProvider: ThemeProvider(),
          isCompact: true,
        ),
      ),
    );
  }
}