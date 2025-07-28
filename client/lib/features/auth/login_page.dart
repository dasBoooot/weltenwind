import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:go_router/go_router.dart';
import '../../core/services/auth_service.dart';
import '../../theme/app_theme.dart';
import '../../theme/background_widget.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  
  // DI-ready: ServiceLocator verwenden statt Singleton
  late final AuthService _authService;
  
  bool _isLoading = false;
  bool _obscurePassword = true;
  String? _loginError;

  @override
  void initState() {
    super.initState();
    if (kDebugMode) {
      print('[LoginPage] Initialized');
    }
    // DI-ready: ServiceLocator verwenden mit robuster Fehlerbehandlung
    _initializeServices();
  }

  void _initializeServices() {
    if (kDebugMode) {
      print('[LoginPage] Initializing services...');
    }
    
    // Einfacher Test ohne ServiceLocator
    try {
      _authService = AuthService();
      if (kDebugMode) {
        print('[LoginPage] AuthService created successfully');
      }
    } catch (e) {
      if (kDebugMode) {
        print('[LoginPage] AuthService creation error: $e');
      }
      // Fallback: leere AuthService
      _authService = AuthService();
    }
    
    if (kDebugMode) {
      print('[LoginPage] Services initialized successfully');
    }
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (kDebugMode) {
      print('[LoginPage] Login attempt started');
    }
    
    // Form-Validierung aktivieren
    if (!_formKey.currentState!.validate()) {
      if (kDebugMode) {
        print('[LoginPage] Form validation failed');
      }
      return;
    }
    
    if (kDebugMode) {
      print('[LoginPage] Form validation passed');
      print('[LoginPage] Username: ${_usernameController.text.trim()}');
      print('[LoginPage] Password length: ${_passwordController.text.length}');
    }
    
    setState(() {
      _isLoading = true;
      _loginError = null;
    });

    try {
      if (kDebugMode) {
        print('[LoginPage] Calling AuthService.login...');
      }
      
      final user = await _authService.login(
        _usernameController.text.trim(),
        _passwordController.text,
      );

      if (kDebugMode) {
        print('[LoginPage] Login response: ${user != null ? 'success' : 'failed'}');
      }

      if (user != null) {
        if (mounted) {
          if (kDebugMode) {
            print('[LoginPage] Login successful - redirecting to worlds');
          }
          // Weiterleitung zur Weltenliste nach erfolgreichem Login
          context.goNamed('world-list');
        }
      } else {
        if (mounted) {
          setState(() {
            _loginError = 'Ungültige Anmeldedaten';
          });
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('[LoginPage] Login error: $e');
      }
      
      if (mounted) {
        setState(() {
          _loginError = 'Anmeldefehler: $e';
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
    if (kDebugMode) {
      print('[LoginPage] Building widget...');
    }
    
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
                  color: const Color(0xFF1A1A1A), // Dunkle Karte
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
                            // Logo/Title
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
                                Icons.public,
                                size: 40,
                                color: AppTheme.primaryColor,
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
                            
                            // Username field
                            TextFormField(
                              controller: _usernameController,
                              style: const TextStyle(color: Colors.white),
                              decoration: InputDecoration(
                                labelText: 'Benutzername',
                                labelStyle: TextStyle(color: Colors.grey[400]),
                                prefixIcon: Icon(Icons.person, color: AppTheme.primaryColor),
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
                                  return 'Bitte gib deinen Benutzernamen ein';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),
                            
                            // Password field
                            TextFormField(
                              controller: _passwordController,
                              obscureText: _obscurePassword,
                              style: const TextStyle(color: Colors.white),
                              decoration: InputDecoration(
                                labelText: 'Passwort',
                                labelStyle: TextStyle(color: Colors.grey[400]),
                                prefixIcon: Icon(Icons.lock, color: AppTheme.primaryColor),
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
                                if (value == null || value.isEmpty) {
                                  return 'Bitte gib dein Passwort ein';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 24),
                            
                            // Error message
                            if (_loginError != null)
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.red[900]!.withOpacity(0.3),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: Colors.red[400]!.withOpacity(0.5)),
                                ),
                                child: Text(
                                  _loginError!,
                                  style: TextStyle(color: Colors.red[200]),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            if (_loginError != null) const SizedBox(height: 16),
                            
                            // Login button
                            SizedBox(
                              width: double.infinity,
                              height: 56,
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
                                  child: Text(
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
    );
  }
} 