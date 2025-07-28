import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/services/auth_service.dart';
import '../../theme/app_theme.dart';
import '../../theme/background_widget.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final AuthService _authService = AuthService();
  
  bool _isLoading = false;
  bool _isSuccess = false;
  String? _errorMessage;
  
  // E-Mail-Validierung Regex
  static final RegExp _emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+$');

  @override
  void dispose() {
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
        
        // Nach 3 Sekunden zurück zum Login
        Future.delayed(const Duration(seconds: 3), () {
          if (mounted) {
            context.goNamed('login');
          }
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString().replaceAll('Exception: ', '');
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
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          const Color(0xFF1A1A1A),
                          const Color(0xFF2A2A2A),
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
                            // Back Button
                            Align(
                              alignment: Alignment.centerLeft,
                              child: IconButton(
                                onPressed: () => context.goNamed('login'),
                                icon: const Icon(Icons.arrow_back),
                                color: Colors.grey[400],
                              ),
                            ),
                            
                            // Icon
                            Container(
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
                              child: Icon(
                                Icons.lock_reset,
                                size: 40,
                                color: AppTheme.primaryColor,
                              ),
                            ),
                            const SizedBox(height: 20),
                            
                            Text(
                              'Passwort zurücksetzen',
                              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 24,
                              ),
                            ),
                            const SizedBox(height: 8),
                            
                            Text(
                              'Gib deine E-Mail-Adresse ein und wir senden dir einen Link zum Zurücksetzen deines Passworts.',
                              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                color: Colors.grey[300],
                                fontSize: 14,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 32),
                            
                            // Success Message
                            if (_isSuccess)
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(12),
                                margin: const EdgeInsets.only(bottom: 16),
                                decoration: BoxDecoration(
                                  color: Colors.green[900]!.withOpacity(0.3),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: Colors.green[400]!.withOpacity(0.5)),
                                ),
                                child: Row(
                                  children: [
                                    Icon(Icons.check_circle_outline, color: Colors.green[400], size: 20),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        'E-Mail gesendet! Bitte überprüfe deinen Posteingang.',
                                        style: TextStyle(color: Colors.green[200], fontSize: 14),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            
                            // Email field
                            if (!_isSuccess)
                              TextFormField(
                                controller: _emailController,
                                style: const TextStyle(color: Colors.white),
                                keyboardType: TextInputType.emailAddress,
                                autofillHints: const [AutofillHints.email],
                                textInputAction: TextInputAction.done,
                                onFieldSubmitted: (_) => _isLoading ? null : _requestPasswordReset(),
                                decoration: InputDecoration(
                                  labelText: 'E-Mail-Adresse',
                                  labelStyle: TextStyle(color: Colors.grey[400]),
                                  prefixIcon: Icon(Icons.email, color: AppTheme.primaryColor),
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
                                    borderSide: BorderSide(color: AppTheme.primaryColor, width: 2),
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
                                    return 'Bitte gib deine E-Mail-Adresse ein';
                                  }
                                  if (!_emailRegex.hasMatch(value.trim())) {
                                    return 'Bitte gib eine gültige E-Mail-Adresse ein';
                                  }
                                  return null;
                                },
                              ),
                            
                            if (!_isSuccess) const SizedBox(height: 16),
                            
                            // Error message
                            if (_errorMessage != null && !_isSuccess)
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
                                  onPressed: _isLoading ? null : _requestPasswordReset,
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
                                          'Link senden',
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                ),
                              ),
                            
                            const SizedBox(height: 20),
                            
                            // Back to login link
                            TextButton(
                              onPressed: () => context.goNamed('login'),
                              child: Text(
                                _isSuccess ? 'Zurück zum Login' : 'Abbrechen',
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
    );
  }
} 