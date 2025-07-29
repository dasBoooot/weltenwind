import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:go_router/go_router.dart';
import '../../config/logger.dart';
import '../../core/services/auth_service.dart';
import '../../theme/app_theme.dart';
import '../../theme/background_widget.dart';
import '../../shared/widgets/user_info_widget.dart';
import '../../shared/widgets/navigation_widget.dart';

// ServiceLocator Import für DI
import '../../main.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  
  // DI-ready: ServiceLocator verwenden statt Singleton
  late final AuthService _authService;
  
  bool _isLoading = false;
  bool _obscurePassword = true;
  String? _registerError;

  // E-Mail-Validierung Regex
  static final RegExp _emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+$');

  @override
  void initState() {
    super.initState();
    // DI-ready: ServiceLocator verwenden mit robuster Fehlerbehandlung
    _initializeServices();
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
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    final formState = _formKey.currentState;
    if (formState == null || !formState.validate()) return;

    setState(() {
      _isLoading = true;
      _registerError = null;
    });

    try {
      final user = await _authService.register(
        _usernameController.text.trim(),
        _emailController.text.trim(),
        _passwordController.text,
      );

      if (user != null) {
        if (mounted) {
          // Erfolgreiche Registrierung - der AuthService hat bereits die Tokens gespeichert
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Registrierung erfolgreich! Willkommen bei Weltenwind!'),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 2),
            ),
          );
          
          // Kurze Verzögerung für bessere UX
          await Future.delayed(const Duration(milliseconds: 500));
          
          if (mounted) {
            // Direkt zum Dashboard navigieren
            context.goNamed('world-list');
          }
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          // Verbessertes Error-Handling: Spezifische Fehlermeldungen
          if (e.toString().contains('username already exists') ||
              e.toString().contains('Username already taken')) {
            _registerError = 'Dieser Benutzername ist bereits vergeben';
          } else if (e.toString().contains('email already exists') ||
                     e.toString().contains('Email already taken')) {
            _registerError = 'Diese E-Mail-Adresse ist bereits registriert';
          } else if (e.toString().contains('SocketException') ||
                     e.toString().contains('Connection refused')) {
            _registerError = 'Server nicht erreichbar. Bitte überprüfe deine Internetverbindung.';
          } else if (e.toString().contains('TimeoutException')) {
            _registerError = 'Verbindung zum Server zeitüberschritten. Bitte versuche es erneut.';
          } else {
            _registerError = e.toString().replaceAll('Exception: ', '');
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
                              child: const Icon(
                                Icons.person_add,
                                size: 40,
                                color: AppTheme.primaryColor,
                              ),
                            ),
                            const SizedBox(height: 20),
                            Text(
                              'Registrierung',
                              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 24,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Erstelle dein Konto für Weltenwind',
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
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
                                  return 'Benutzername ist erforderlich';
                                }
                                if (value.length < 3) {
                                  return 'Benutzername muss mindestens 3 Zeichen lang sein';
                                }
                                if (!RegExp(r'^[a-zA-Z0-9_]+$').hasMatch(value)) {
                                  return 'Benutzername darf nur Buchstaben, Zahlen und Unterstriche enthalten';
                                }
                                return null;
                              },
                              textInputAction: TextInputAction.next,
                            ),
                            const SizedBox(height: 16),

                            // Email field
                            TextFormField(
                              controller: _emailController,
                              style: const TextStyle(color: Colors.white),
                              decoration: InputDecoration(
                                labelText: 'E-Mail',
                                labelStyle: TextStyle(color: Colors.grey[400]),
                                prefixIcon: const Icon(Icons.email, color: AppTheme.primaryColor),
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
                                  return 'E-Mail ist erforderlich';
                                }
                                if (!_emailRegex.hasMatch(value)) {
                                  return 'Bitte gib eine gültige E-Mail-Adresse ein';
                                }
                                return null;
                              },
                              keyboardType: TextInputType.emailAddress,
                              textInputAction: TextInputAction.next,
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
                                  return 'Passwort ist erforderlich';
                                }
                                if (value.length < 6) {
                                  return 'Passwort muss mindestens 6 Zeichen lang sein';
                                }
                                return null;
                              },
                              textInputAction: TextInputAction.done,
                            ),
                            const SizedBox(height: 24),

                            // Error message
                            if (_registerError != null)
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.red[900]!.withOpacity(0.3),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: Colors.red[400]!.withOpacity(0.5)),
                                ),
                                child: Text(
                                  _registerError!,
                                  style: TextStyle(color: Colors.red[200]),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            if (_registerError != null) const SizedBox(height: 16),

                            // Register button
                            SizedBox(
                              width: double.infinity,
                              height: 56,
                              child: ElevatedButton(
                                onPressed: _isLoading ? null : _register,
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
                                        'Registrieren',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                              ),
                            ),
                            const SizedBox(height: 20),

                            // Login link
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'Bereits ein Konto? ',
                                  style: TextStyle(color: Colors.grey[400]),
                                ),
                                TextButton(
                                  onPressed: () => context.goNamed('login'),
                                  child: const Text(
                                    'Anmelden',
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