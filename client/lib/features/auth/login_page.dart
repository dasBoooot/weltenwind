import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../config/logger.dart';
import '../../core/services/auth_service.dart';
import '../../theme/app_theme.dart';
import '../../theme/background_widget.dart';

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
  
  // Für bessere Validierung
  bool _hasInteractedWithUsername = false;
  bool _hasInteractedWithPassword = false;

  @override
  void initState() {
    super.initState();
    _authService = AuthService();
    
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

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    
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
        if (mounted) {
          // Success Animation
          await _animationController.reverse();
          
          // Handle Remember Me
          if (_rememberMe) {
            // TODO: Save credentials securely
            AppLogger.logUserAction('remember_me_checked');
          }
          
          context.goNamed('world-list');
        }
      } else {
        if (mounted) {
          setState(() {
            _loginError = 'Ungültige Anmeldedaten. Bitte überprüfe deinen Benutzernamen und dein Passwort.';
          });
        }
      }
    } catch (e) {
      AppLogger.logError('Login-Fehler auf LoginPage', e);
      
      if (mounted) {
        setState(() {
          // Bessere Fehlermeldungen basierend auf Fehlertyp
          if (e.toString().contains('network') || e.toString().contains('connection')) {
            _loginError = 'Netzwerkfehler. Bitte überprüfe deine Internetverbindung.';
          } else if (e.toString().contains('timeout')) {
            _loginError = 'Zeitüberschreitung. Bitte versuche es später erneut.';
          } else if (e.toString().contains('locked')) {
            _loginError = 'Dein Konto wurde gesperrt. Bitte kontaktiere den Support.';
          } else {
            _loginError = 'Ein unerwarteter Fehler ist aufgetreten. Bitte versuche es später erneut.';
          }
        });
      }
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
                                    'Willkommen bei Weltenwind',
                                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 24,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Melde dich an, um deine Welten zu verwalten',
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
                                      labelText: 'Benutzername',
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
                                        return 'Bitte gib deinen Benutzernamen ein';
                                      }
                                      if (value.trim().length < 3) {
                                        return 'Benutzername muss mindestens 3 Zeichen lang sein';
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
                                      labelText: 'Passwort',
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
                                        return 'Bitte gib dein Passwort ein';
                                      }
                                      if (_hasInteractedWithPassword && value.length < 6) {
                                        return 'Passwort muss mindestens 6 Zeichen lang sein';
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
                                              'Angemeldet bleiben',
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
                                        child: const Text(
                                          'Passwort vergessen?',
                                          style: TextStyle(
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
                                            : const Text(
                                                'Anmelden',
                                                style: TextStyle(
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
                                          'oder',
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
                                            const SnackBar(
                                              content: Text('Google Login wird bald verfügbar sein'),
                                            ),
                                          );
                                        },
                                        icon: Icons.g_mobiledata,
                                        label: 'Google',
                                      ),
                                      const SizedBox(width: 16),
                                      // GitHub Login
                                      _buildSocialLoginButton(
                                        onPressed: () {
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            const SnackBar(
                                              content: Text('GitHub Login wird bald verfügbar sein'),
                                            ),
                                          );
                                        },
                                        icon: Icons.code,
                                        label: 'GitHub',
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 20),
                                  
                                  // Register link
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        'Noch kein Konto? ',
                                        style: TextStyle(color: Colors.grey[400]),
                                      ),
                                      TextButton(
                                        onPressed: () => context.goNamed('register'),
                                        child: const Text(
                                          'Registrieren',
                                          style: TextStyle(
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
                child: const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                      SizedBox(height: 16),
                      Text(
                        'Anmeldung läuft...',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
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