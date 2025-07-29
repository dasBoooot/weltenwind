import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/services/auth_service.dart';
import '../../theme/app_theme.dart';
import '../../theme/background_widget.dart';

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
      _isSuccess = false;
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
        
        // Erfolgsmeldung zeigen und nach 3 Sekunden zum Login
        await Future.delayed(const Duration(seconds: 3));
        if (mounted) {
          context.goNamed('login');
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          final error = e.toString().replaceAll('Exception: ', '');
          if (error.contains('expired') || error.contains('invalid')) {
            _errorMessage = 'Der Reset-Link ist ungültig oder abgelaufen. Bitte fordere einen neuen Link an.';
          } else {
            _errorMessage = error;
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
      body: BackgroundWidget(
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
                              // Icon with Animation
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
                                    color: _isSuccess 
                                      ? Colors.green.withOpacity(0.2)
                                      : AppTheme.primaryColor.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(
                                      color: _isSuccess
                                        ? Colors.green.withOpacity(0.5)
                                        : AppTheme.primaryColor.withOpacity(0.5),
                                      width: 2,
                                    ),
                                  ),
                                  child: Icon(
                                    _isSuccess ? Icons.check_circle : Icons.lock_reset,
                                    size: 40,
                                    color: _isSuccess ? Colors.green : AppTheme.primaryColor,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 20),
                              
                              Text(
                                _isSuccess ? 'Passwort erfolgreich geändert!' : 'Neues Passwort festlegen',
                                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 24,
                                ),
                              ),
                              const SizedBox(height: 8),
                              
                              Text(
                                _isSuccess 
                                  ? 'Du wirst automatisch zur Anmeldung weitergeleitet...'
                                  : 'Bitte gib dein neues Passwort ein.',
                                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                  color: Colors.grey[300],
                                  fontSize: 14,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 32),
                              
                              // Success Animation
                              if (_isSuccess)
                                TweenAnimationBuilder<double>(
                                  tween: Tween(begin: 0.0, end: 1.0),
                                  duration: const Duration(milliseconds: 500),
                                  builder: (context, value, child) {
                                    return Transform.scale(
                                      scale: value,
                                      child: child,
                                    );
                                  },
                                  child: const Icon(
                                    Icons.check_circle,
                                    size: 64,
                                    color: Colors.green,
                                  ),
                                ),
                              
                              // Password fields
                              if (!_isSuccess) ...[
                                // New Password field
                                TextFormField(
                                  controller: _passwordController,
                                  obscureText: _obscurePassword,
                                  style: const TextStyle(color: Colors.white),
                                  autofillHints: const [AutofillHints.newPassword],
                                  textInputAction: TextInputAction.next,
                                  onChanged: (_) {
                                    if (!_hasInteractedWithPassword) {
                                      setState(() {
                                        _hasInteractedWithPassword = true;
                                      });
                                    }
                                  },
                                  decoration: InputDecoration(
                                    labelText: 'Neues Passwort',
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
                                    helperText: 'Mindestens 6 Zeichen',
                                    helperStyle: TextStyle(color: Colors.grey[500], fontSize: 12),
                                  ),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Bitte gib ein neues Passwort ein';
                                    }
                                    if (value.length < 6) {
                                      return 'Passwort muss mindestens 6 Zeichen lang sein';
                                    }
                                    if (value.contains(' ')) {
                                      return 'Passwort darf keine Leerzeichen enthalten';
                                    }
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 16),
                                
                                // Confirm Password field
                                TextFormField(
                                  controller: _confirmPasswordController,
                                  obscureText: _obscureConfirmPassword,
                                  style: const TextStyle(color: Colors.white),
                                  textInputAction: TextInputAction.done,
                                  onFieldSubmitted: (_) => _isLoading ? null : _resetPassword(),
                                  onChanged: (_) {
                                    if (!_hasInteractedWithConfirmPassword) {
                                      setState(() {
                                        _hasInteractedWithConfirmPassword = true;
                                      });
                                    }
                                  },
                                  decoration: InputDecoration(
                                    labelText: 'Passwort bestätigen',
                                    labelStyle: TextStyle(color: Colors.grey[400]),
                                    prefixIcon: const Icon(Icons.lock_outline, color: AppTheme.primaryColor),
                                    suffixIcon: IconButton(
                                      icon: Icon(
                                        _obscureConfirmPassword ? Icons.visibility : Icons.visibility_off,
                                        color: Colors.grey[400],
                                      ),
                                      onPressed: () {
                                        setState(() {
                                          _obscureConfirmPassword = !_obscureConfirmPassword;
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
                                      return 'Bitte bestätige dein neues Passwort';
                                    }
                                    if (value != _passwordController.text) {
                                      return 'Die Passwörter stimmen nicht überein';
                                    }
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 24),
                                
                                // Password Requirements Info
                                Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: AppTheme.primaryColor.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(color: AppTheme.primaryColor.withOpacity(0.3)),
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        'Passwort-Anforderungen:',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      _buildRequirement('Mindestens 6 Zeichen', 
                                        _passwordController.text.length >= 6),
                                      _buildRequirement('Keine Leerzeichen', 
                                        !_passwordController.text.contains(' ')),
                                      _buildRequirement('Passwörter stimmen überein', 
                                        _passwordController.text.isNotEmpty && 
                                        _passwordController.text == _confirmPasswordController.text),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 16),
                              ],
                              
                              // Error message
                              if (_errorMessage != null)
                                Container(
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
                                          _errorMessage!,
                                          style: TextStyle(color: Colors.red[200], fontSize: 14),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              
                              // Submit button
                              if (!_isSuccess)
                                SizedBox(
                                  width: double.infinity,
                                  height: 56,
                                  child: ElevatedButton(
                                    onPressed: _isLoading ? null : _resetPassword,
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
                                            'Passwort zurücksetzen',
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                  ),
                                ),
                              
                              const SizedBox(height: 20),
                              
                              // Back to login link
                              if (!_isSuccess)
                                TextButton(
                                  onPressed: () => context.goNamed('login'),
                                  child: const Text(
                                    'Zurück zur Anmeldung',
                                    style: TextStyle(
                                      color: AppTheme.primaryColor,
                                      fontSize: 16,
                                    ),
                                  ),
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
    );
  }
  
  Widget _buildRequirement(String text, bool isMet) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Icon(
            isMet ? Icons.check_circle : Icons.circle_outlined,
            size: 16,
            color: isMet ? Colors.green : Colors.grey[400],
          ),
          const SizedBox(width: 8),
          Text(
            text,
            style: TextStyle(
              color: isMet ? Colors.green[300] : Colors.grey[400],
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
} 