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
  Map<String, dynamic>? _inviteData;

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
    // 🎯 CLEAN PARAMETER LOADING: Aus GoRouter 'extra' statt Query-Parameter
    final routeData = GoRouterState.of(context);
    final extraData = routeData.extra as Map<String, dynamic>?;
    
    if (extraData != null) {
      _inviteToken = extraData['invite_token'] as String?;
      _prefilledEmail = extraData['email'] as String?;
    } else {
      // Fallback für alte Query-Parameter (Kompatibilität)
      _inviteToken = routeData.uri.queryParameters['invite_token'];
      _prefilledEmail = routeData.uri.queryParameters['email'];
    }
    
    AppLogger.app.i('📧 Registration Parameter geladen', error: {
      'hasInviteToken': _inviteToken != null,
      'hasPrefilledEmail': _prefilledEmail != null,
      'inviteToken': _inviteToken?.substring(0, 8),
      'email': _prefilledEmail,
      'source': extraData != null ? 'extra' : 'query'
    });
    
    // E-Mail vorbefüllen wenn vorhanden
    if (_prefilledEmail != null && _prefilledEmail!.isNotEmpty) {
      _emailController.text = _prefilledEmail!;
      AppLogger.app.i('📧 E-Mail vorbefüllt', error: {'email': _prefilledEmail});
    } else if (_inviteToken != null) {
      // Wenn kein Email-Parameter aber Invite-Token, dann E-Mail aus Invite laden
      _loadInviteData();
    }
  }

  Future<void> _loadInviteData() async {
    if (_inviteToken == null) return;
    
    try {
          final apiService = ServiceLocator.get<ApiService>();
    final response = await apiService.get('/invites/validate/$_inviteToken');
      
      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        if (responseData['success'] == true && responseData['data'] != null) {
          _inviteData = responseData['data'];
          final inviteEmail = _inviteData?['invite']?['email'];
        
        if (inviteEmail != null && _emailController.text.isEmpty) {
          setState(() {
            _emailController.text = inviteEmail;
          });
          
          AppLogger.app.i('📧 E-Mail aus Invite-Token geladen', error: {
            'email': inviteEmail,
            'worldName': _inviteData?['world']?['name']
          });
        }
        }
      }
    } catch (e) {
      AppLogger.app.w('⚠️ Fehler beim Laden der Invite-Daten', error: e);
      // Fehler nicht anzeigen - User kann trotzdem registrieren
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
          'hasInviteToken': _inviteToken != null
        });
        
        if (mounted) {
          // Erfolgsmeldung zeigen
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(AppLocalizations.of(context).authRegisterSuccessWelcome),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 2),
            ),
          );
          
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

  Future<void> _handleInviteAccept() async {
    if (_inviteToken == null) {
      context.goNamed('world-list');
      return;
    }

    try {
      AppLogger.app.i('🎫 Auto-Accept Invite nach Registrierung', error: {
        'token': '${_inviteToken!.substring(0, 8)}...'
      });

      final apiService = ServiceLocator.get<ApiService>();
      final response = await apiService.post('/invites/accept/$_inviteToken', {});
      
      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        if (responseData['success'] == true) {
          final worldId = responseData['data']?['world']?['id'];
          final worldName = responseData['data']?['world']?['name'];
        
        AppLogger.app.i('✅ Invite automatisch akzeptiert', error: {
          'worldId': worldId,
          'worldName': worldName
        });

        if (mounted) {
          // Zusätzliche Erfolgsmeldung für Invite
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
          // Invite-Accept fehlgeschlagen - trotzdem erfolgreich registriert
          AppLogger.app.w('⚠️ Invite-Accept nach Registrierung fehlgeschlagen', error: {
            'error': responseData['error'],
            'token': '${_inviteToken!.substring(0, 8)}...'
          });
          
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(AppLocalizations.of(context)!.authRegisterSuccessButInviteFailed),
                backgroundColor: Colors.orange,
                duration: Duration(seconds: 3),
              ),
            );
            context.goNamed('world-list');
          }
        }
      } else {
        final responseData = jsonDecode(response.body);
        // Invite-Accept fehlgeschlagen - trotzdem erfolgreich registriert
        AppLogger.app.w('⚠️ Invite-Accept nach Registrierung fehlgeschlagen', error: {
          'error': responseData['error'],
          'token': '${_inviteToken!.substring(0, 8)}...'
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(AppLocalizations.of(context)!.authRegisterSuccessButInviteFailed),
              backgroundColor: Colors.orange,
              duration: const Duration(seconds: 3),
            ),
          );
          context.goNamed('world-list');
        }
      }
    } catch (e) {
      AppLogger.app.e('❌ Fehler beim Auto-Accept von Invite', error: e);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.authRegisterSuccessButInviteFailed),
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
                                AppLocalizations.of(context).authRegisterWelcome,
                                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 24,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                AppLocalizations.of(context).authRegisterSubtitle,
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
                                    return AppLocalizations.of(context).authUsernameRequiredAlt;
                                  }
                                  if (value.length < 3) {
                                    return AppLocalizations.of(context).authUsernameMinLength;
                                  }
                                  if (!RegExp(r'^[a-zA-Z0-9_]+$').hasMatch(value)) {
                                    return AppLocalizations.of(context).authUsernameInvalidChars;
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
                                  labelText: AppLocalizations.of(context).authEmailLabel,
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
                                    return AppLocalizations.of(context).authEmailRequired;
                                  }
                                  if (!_emailRegex.hasMatch(value)) {
                                    return AppLocalizations.of(context).errorValidationEmail;
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
                                  if (value.length < 6) {
                                    return AppLocalizations.of(context).authPasswordMinLength;
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
                                      : Text(
                                          AppLocalizations.of(context).authRegisterButton,
                                          style: const TextStyle(
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
                                    AppLocalizations.of(context).authHaveAccount,
                                    style: TextStyle(color: Colors.grey[400]),
                                  ),
                                  TextButton(
                                    onPressed: () => context.goNamed('login'),
                                    child: Text(
                                      AppLocalizations.of(context).authLoginButton,
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
} 