import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../config/logger.dart';
import '../../core/services/auth_service.dart';
import '../../core/services/world_service.dart';
import '../../theme/app_theme.dart';
import '../../theme/background_widget.dart';

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
  
  // Invite-Parameter
  String? _inviteToken;
  String? _prefilledEmail;

  // E-Mail-Validierung Regex
  static final RegExp _emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+$');

  @override
  void initState() {
    super.initState();
    // DI-ready: ServiceLocator verwenden mit robuster Fehlerbehandlung
    _initializeServices();
    _loadQueryParameters();
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
    // Query-Parameter aus der URL lesen
    final routeData = GoRouterState.of(context);
    _inviteToken = routeData.uri.queryParameters['invite_token'];
    _prefilledEmail = routeData.uri.queryParameters['email'];
    
    AppLogger.app.i('📧 Registration Query-Parameter geladen', error: {
      'hasInviteToken': _inviteToken != null,
      'hasPrefilledEmail': _prefilledEmail != null,
      'inviteToken': _inviteToken?.substring(0, 8),
      'email': _prefilledEmail
    });
    
    // E-Mail vorbefüllen wenn vorhanden
    if (_prefilledEmail != null && _prefilledEmail!.isNotEmpty) {
      _emailController.text = _prefilledEmail!;
      AppLogger.app.i('📧 E-Mail vorbefüllt', error: {'email': _prefilledEmail});
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
    if (formState == null || !formState.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
      _registerError = null;
    });

    try {
      final user = await _authService.register(
        _usernameController.text.trim(),
        _emailController.text.trim().toLowerCase(),
        _passwordController.text,
      );

      if (user != null) {
        AppLogger.app.i('✅ Registrierung erfolgreich', error: {
          'userId': user.id,
          'username': user.username,
          'email': user.email,
        });
        
        if (mounted) {
          // HINZUGEFÜGT: Post-Auth-Redirect prüfen
          final pendingRedirect = _authService.getPendingRedirect();
          
          if (pendingRedirect != null) {
            AppLogger.app.i('🎫 Post-Auth-Redirect nach Registration erkannt', error: pendingRedirect);
            _authService.clearPendingRedirect();
            
            // Redirect zur ursprünglichen Invite-Seite
            final routeName = pendingRedirect['route'] as String;
            final params = pendingRedirect['params'] as Map<String, String>?;
            
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Registrierung erfolgreich! Du wirst zur Einladung weitergeleitet...'),
                backgroundColor: Colors.green,
                duration: Duration(seconds: 2),
              ),
            );
            
            // Kurze Verzögerung für bessere UX
            await Future.delayed(const Duration(milliseconds: 500));
            
            if (mounted) {
              if (params != null) {
                context.goNamed(routeName, pathParameters: params);
              } else {
                context.goNamed(routeName);
              }
            }
          } else if (_inviteToken != null) {
            // Fallback: Wenn Invite-Token in Query-Parametern, direkt zur Invite-Seite
            AppLogger.app.i('🎫 Invite-Token in Query nach Registration - direkte Navigation', error: {'token': _inviteToken!.substring(0, 8) + '...'});
            
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Registrierung erfolgreich! Du wirst zur Einladung weitergeleitet...'),
                backgroundColor: Colors.green,
                duration: Duration(seconds: 2),
              ),
            );
            
            // Kurze Verzögerung für bessere UX
            await Future.delayed(const Duration(milliseconds: 500));
            
            if (mounted) {
              context.goNamed('world-join-by-token', pathParameters: {'token': _inviteToken!});
            }
          } else {
            // Standard-Redirect zu Welten-Liste
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Registrierung erfolgreich! Willkommen bei Weltenwind!'),
                backgroundColor: Colors.green,
                duration: Duration(seconds: 2),
              ),
            );
            
            context.goNamed('world-list');
          }
        }
      }
    } catch (e) {
      AppLogger.logError('Registrierung fehlgeschlagen', e, context: {
        'username': _usernameController.text.trim(),
        'email': _emailController.text.trim().toLowerCase(),
      });
      
      setState(() {
        _registerError = e.toString().replaceAll('Exception: ', '');
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