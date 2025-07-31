import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../config/logger.dart';
import '../../core/services/auth_service.dart';
import '../../core/services/api_service.dart';
import '../../theme/app_theme.dart';
import '../../theme/background_widget.dart';
import '../../l10n/app_localizations.dart';
import '../../shared/widgets/language_switcher.dart';

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
  
  // Für bessere Validierung
  bool _hasInteractedWithUsername = false;
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
    // 🎯 CLEAN PARAMETER LOADING: Aus GoRouter 'extra' statt Query-Parameter
    final routeData = GoRouterState.of(context);
    final extraData = routeData.extra as Map<String, dynamic>?;
    
    if (extraData != null) {
      _inviteToken = extraData['invite_token'] as String?;
    } else {
      // Fallback für alte Query-Parameter (Kompatibilität)
      _inviteToken = routeData.uri.queryParameters['invite_token'];
    }
    
    AppLogger.app.i('🎫 Login Parameter geladen', error: {
      'hasInviteToken': _inviteToken != null,
      'inviteToken': _inviteToken?.substring(0, 8),
      'source': extraData != null ? 'extra' : 'query'
    });
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _loginError = null;
    });

    try {
      final user = await _authService.login(
        _usernameController.text.trim(),
        _passwordController.text,
      );

      if (user != null) {
        AppLogger.app.i('✅ Login erfolgreich', error: {
          'userId': user.id, 
          'username': user.username,
          'hasInviteToken': _inviteToken != null
        });
        
        if (mounted) {
          // Wenn Invite-Token vorhanden, versuche Auto-Accept
          if (_inviteToken != null) {
            await _handleInviteAccept();
          } else {
            // Standard-Redirect zu Welten-Liste
            context.goNamed('world-list');
          }
        }
      }
    } catch (e) {
      AppLogger.logError('Login fehlgeschlagen', e);
      setState(() {
        _loginError = e.toString().replaceAll('Exception: ', '');
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
    if (_inviteToken == null) {
      context.goNamed('world-list');
      return;
    }

    try {
      AppLogger.app.i('🎫 Auto-Accept Invite nach Login', error: {
        'token': '${_inviteToken!.substring(0, 8)}...'
      });

      final apiService = ServiceLocator.get<ApiService>();
      final response = await apiService.post('/invites/accept/$_inviteToken', {});
      
      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        if (responseData['success'] == true) {
          final worldId = responseData['data']?['world']?['id'];
          final worldName = responseData['data']?['world']?['name'];
        
        AppLogger.app.i('✅ Invite automatisch akzeptiert nach Login', error: {
          'worldId': worldId,
          'worldName': worldName
        });

        if (mounted) {
          // Erfolgsmeldung für Invite
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(AppLocalizations.of(context)!.worldJoinSuccess(worldName ?? AppLocalizations.of(context)!.worldJoinUnknownWorld)),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 3),
            ),
          );

          // Zur Welt-Join-Seite navigieren wenn möglich, sonst zur Weltenliste
          if (worldId != null) {
            context.go('/go/worlds/$worldId/join');
          } else {
            context.goNamed('world-list');
          }
          }
        } else {
          final responseData = jsonDecode(response.body);
          // Invite-Accept fehlgeschlagen - trotzdem erfolgreich eingeloggt
          AppLogger.app.w('⚠️ Invite-Accept nach Login fehlgeschlagen', error: {
            'error': responseData['error'],
            'token': '${_inviteToken!.substring(0, 8)}...'
          });
          
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(AppLocalizations.of(context)!.authLoginSuccessButInviteFailed),
                backgroundColor: Colors.orange,
                duration: Duration(seconds: 3),
              ),
            );
            context.goNamed('world-list');
          }
        }
      } else {
        final responseData = jsonDecode(response.body);
        // Invite-Accept fehlgeschlagen - trotzdem erfolgreich eingeloggt
        AppLogger.app.w('⚠️ Invite-Accept nach Login fehlgeschlagen', error: {
          'error': responseData['error'],
          'token': '${_inviteToken!.substring(0, 8)}...'
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(AppLocalizations.of(context)!.authLoginSuccessButInviteFailed),
              backgroundColor: Colors.orange,
              duration: const Duration(seconds: 3),
            ),
          );
          context.goNamed('world-list');
        }
      }
    } catch (e) {
      AppLogger.app.e('❌ Fehler beim Auto-Accept von Invite nach Login', error: e);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.authLoginSuccessButInviteFailed),
            backgroundColor: Colors.orange,
            duration: const Duration(seconds: 3),
          ),
        );
        context.goNamed('world-list');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          BackgroundWidget(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24.0),
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 400),
                      child: Card(
                        elevation: 12,
                        color: const Color(0xFF1A1A1A),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                          side: BorderSide(
                            color: AppTheme.primaryColor.withOpacity(0.3),
                            width: 1,
                          ),
                        ),
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            gradient: const LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                Color(0xFF1A1A1A),
                                Color(0xFF2A2A2A),
                              ],
                            ),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(32.0),
                            child: Form(
                              key: _formKey,
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  // Logo/Title with Animation
                                  TweenAnimationBuilder<double>(
                                    tween: Tween(begin: 0.8, end: 1.0),
                                    duration: const Duration(milliseconds: 600),
                                    curve: Curves.elasticOut,
                                    builder: (context, value, child) {
                                      return Transform.scale(
                                        scale: value,
                                        child: child,
                                      );
                                    },
                                    child: Container(
                                      width: 80,
                                      height: 80,
                                      decoration: BoxDecoration(
                                        color: AppTheme.primaryColor.withOpacity(0.2),
                                        borderRadius: BorderRadius.circular(20),
                                        border: Border.all(
                                          color: AppTheme.primaryColor.withOpacity(0.5),
                                          width: 2,
                                        ),
                                      ),
                                      child: const Icon(
                                        Icons.public,
                                        size: 40,
                                        color: AppTheme.primaryColor,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 20),
                                  Text(
                                    AppLocalizations.of(context).authLoginWelcome,
                                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 24,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    AppLocalizations.of(context).authLoginSubtitle,
                                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                      color: Colors.grey[300],
                                      fontSize: 16,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                  const SizedBox(height: 32),
                                  
                                  // Username field with better validation
                                  TextFormField(
                                    controller: _usernameController,
                                    style: const TextStyle(color: Colors.white),
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
                                      labelStyle: TextStyle(color: Colors.grey[400]),
                                      prefixIcon: const Icon(Icons.person, color: AppTheme.primaryColor),
                                      filled: true,
                                      fillColor: const Color(0xFF2D2D2D),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: BorderSide(color: Colors.grey[600]!),
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: BorderSide(color: Colors.grey[600]!),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: const BorderSide(color: AppTheme.primaryColor, width: 2),
                                      ),
                                      errorBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: BorderSide(color: Colors.red[400]!),
                                      ),
                                      focusedErrorBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: BorderSide(color: Colors.red[400]!, width: 2),
                                      ),
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
                                  const SizedBox(height: 16),
                                  
                                  // Password field with better validation
                                  TextFormField(
                                    controller: _passwordController,
                                    obscureText: _obscurePassword,
                                    style: const TextStyle(color: Colors.white),
                                    autofillHints: const [AutofillHints.password],
                                    textInputAction: TextInputAction.done,
                                    onFieldSubmitted: (_) => _isLoading ? null : _login(),
                                    onChanged: (_) {
                                      if (!_hasInteractedWithPassword) {
                                        setState(() {
                                          _hasInteractedWithPassword = true;
                                        });
                                      }
                                    },
                                    decoration: InputDecoration(
                                      labelText: AppLocalizations.of(context).authPasswordLabel,
                                      labelStyle: TextStyle(color: Colors.grey[400]),
                                      prefixIcon: const Icon(Icons.lock, color: AppTheme.primaryColor),
                                      suffixIcon: IconButton(
                                        icon: Icon(
                                          _obscurePassword ? Icons.visibility : Icons.visibility_off,
                                          color: Colors.grey[400],
                                        ),
                                        onPressed: () {
                                          setState(() {
                                            _obscurePassword = !_obscurePassword;
                                          });
                                        },
                                      ),
                                      filled: true,
                                      fillColor: const Color(0xFF2D2D2D),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: BorderSide(color: Colors.grey[600]!),
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: BorderSide(color: Colors.grey[600]!),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: const BorderSide(color: AppTheme.primaryColor, width: 2),
                                      ),
                                      errorBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: BorderSide(color: Colors.red[400]!),
                                      ),
                                      focusedErrorBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: BorderSide(color: Colors.red[400]!, width: 2),
                                      ),
                                    ),
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return AppLocalizations.of(context).authPasswordRequired;
                                      }
                                      if (_hasInteractedWithPassword && value.length < 6) {
                                        return AppLocalizations.of(context).authPasswordMinLength;
                                      }
                                      return null;
                                    },
                                  ),
                                  const SizedBox(height: 12),
                                  
                                  // Remember Me & Forgot Password Row
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      // Remember Me Checkbox
                                      Row(
                                        children: [
                                          Transform.scale(
                                            scale: 1.2,
                                            child: Checkbox(
                                              value: _rememberMe,
                                              onChanged: (value) {
                                                setState(() {
                                                  _rememberMe = value ?? false;
                                                });
                                              },
                                              fillColor: WidgetStateProperty.resolveWith<Color>((states) {
                                                if (states.contains(WidgetState.selected)) {
                                                  return AppTheme.primaryColor;
                                                }
                                                return Colors.grey[600]!;
                                              }),
                                              side: BorderSide(color: Colors.grey[600]!, width: 2),
                                            ),
                                          ),
                                          GestureDetector(
                                            onTap: () {
                                              setState(() {
                                                _rememberMe = !_rememberMe;
                                              });
                                            },
                                            child: Text(
                                              AppLocalizations.of(context).authRememberMe,
                                              style: TextStyle(
                                                color: Colors.grey[300],
                                                fontSize: 14,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      
                                      // Forgot Password Link
                                      TextButton(
                                        onPressed: () => context.goNamed('forgot-password'),
                                        child: Text(
                                          AppLocalizations.of(context).authForgotPassword,
                                          style: const TextStyle(
                                            color: AppTheme.primaryColor,
                                            fontSize: 14,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  
                                  // Error message with animation
                                  AnimatedContainer(
                                    duration: const Duration(milliseconds: 300),
                                    height: _loginError != null ? null : 0,
                                    child: _loginError != null
                                      ? Container(
                                          width: double.infinity,
                                          padding: const EdgeInsets.all(12),
                                          margin: const EdgeInsets.only(bottom: 16),
                                          decoration: BoxDecoration(
                                            color: Colors.red[900]!.withOpacity(0.3),
                                            borderRadius: BorderRadius.circular(8),
                                            border: Border.all(color: Colors.red[400]!.withOpacity(0.5)),
                                          ),
                                          child: Row(
                                            children: [
                                              Icon(Icons.error_outline, color: Colors.red[400], size: 20),
                                              const SizedBox(width: 8),
                                              Expanded(
                                                child: Text(
                                                  _loginError!,
                                                  style: TextStyle(color: Colors.red[200], fontSize: 14),
                                                ),
                                              ),
                                            ],
                                          ),
                                        )
                                      : const SizedBox.shrink(),
                                  ),
                                  
                                  // Login button with hover effect
                                  SizedBox(
                                    width: double.infinity,
                                    height: 56,
                                    child: AnimatedContainer(
                                      duration: const Duration(milliseconds: 200),
                                      child: ElevatedButton(
                                        onPressed: _isLoading ? null : _login,
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: AppTheme.primaryColor,
                                          foregroundColor: Colors.white,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                          elevation: 8,
                                          shadowColor: AppTheme.primaryColor.withOpacity(0.5),
                                        ),
                                        child: _isLoading
                                            ? const SizedBox(
                                                height: 20,
                                                width: 20,
                                                child: CircularProgressIndicator(
                                                  strokeWidth: 2,
                                                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                                ),
                                              )
                                            : Text(
                                                AppLocalizations.of(context).authLoginButton,
                                                style: const TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 24),
                                  
                                  // Divider with text
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Divider(
                                          color: Colors.grey[600],
                                          thickness: 1,
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.symmetric(horizontal: 16),
                                        child: Text(
                                          AppLocalizations.of(context).commonOr,
                                          style: TextStyle(
                                            color: Colors.grey[400],
                                            fontSize: 14,
                                          ),
                                        ),
                                      ),
                                      Expanded(
                                        child: Divider(
                                          color: Colors.grey[600],
                                          thickness: 1,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 16),
                                  
                                  // Social Login Buttons (Placeholder)
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      // Google Login
                                      _buildSocialLoginButton(
                                        onPressed: () {
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            SnackBar(
                                              content: Text(AppLocalizations.of(context).authGoogleComingSoon),
                                            ),
                                          );
                                        },
                                        icon: Icons.g_mobiledata,
                                        label: AppLocalizations.of(context).authGoogleLabel,
                                      ),
                                      const SizedBox(width: 16),
                                      // GitHub Login
                                      _buildSocialLoginButton(
                                        onPressed: () {
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            SnackBar(
                                              content: Text(AppLocalizations.of(context).authGithubComingSoon),
                                            ),
                                          );
                                        },
                                        icon: Icons.code,
                                        label: AppLocalizations.of(context).authGithubLabel,
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 20),
                                  
                                  // Register link
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        AppLocalizations.of(context).authNoAccount,
                                        style: TextStyle(color: Colors.grey[400]),
                                      ),
                                      TextButton(
                                        onPressed: () => context.goNamed('register'),
                                        child: Text(
                                          AppLocalizations.of(context).authRegisterButton,
                                          style: const TextStyle(
                                            color: AppTheme.primaryColor,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                          ),
                                        ),
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
            ),
          ),
          
          // Loading Overlay
          if (_isLoading)
            AnimatedOpacity(
              opacity: _isLoading ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 200),
              child: Container(
                color: Colors.black.withOpacity(0.7),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        AppLocalizations.of(context).authLoginLoading,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          
          // Language Switcher (oben links)
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
        ],
      ),
    );
  }
  
  Widget _buildSocialLoginButton({
    required VoidCallback onPressed,
    required IconData icon,
    required String label,
  }) {
    return OutlinedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 20),
      label: Text(label),
      style: OutlinedButton.styleFrom(
        foregroundColor: Colors.grey[300],
        side: BorderSide(color: Colors.grey[600]!),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }
} 