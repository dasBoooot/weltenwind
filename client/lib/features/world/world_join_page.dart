import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:go_router/go_router.dart';
import '../../config/logger.dart';
import '../../core/models/world.dart';
import '../../core/services/world_service.dart';
import '../../core/services/auth_service.dart';
import '../../core/services/api_service.dart';
import '../../theme/app_theme.dart';
import '../../theme/background_widget.dart';
import '../../shared/widgets/user_info_widget.dart';
import '../../shared/widgets/navigation_widget.dart';

// ServiceLocator Import für DI
import '../../main.dart';

// Flow-Type-Enum für klare Trennung der beiden User-Journeys
enum WorldJoinFlowType {
  normal,   // Normale Navigation: User kommt von World-List
  invite,   // Invite-Flow: User kommt über externen Link
}

class WorldJoinPage extends StatefulWidget {
  final String? worldId;
  final String? inviteToken;
  final WorldJoinFlowType flowType;
  
  const WorldJoinPage({
    super.key, 
    this.worldId, 
    this.inviteToken,
    required this.flowType,
  });

  @override
  State<WorldJoinPage> createState() => _WorldJoinPageState();
}

class _WorldJoinPageState extends State<WorldJoinPage> with SingleTickerProviderStateMixin {
  // DI-ready: ServiceLocator verwenden
  late final WorldService _worldService;
  late final AuthService _authService;
  
  // Tab Controller
  late TabController _tabController;
  
  bool _isLoading = false;
  bool _isJoining = false;
  bool _isPreRegistering = false;
  bool _isAuthenticated = false;
  bool _isJoined = false;
  bool _isPreRegistered = false;
  World? _world;
  String? _errorMessage;
  String? _infoMessage;
  String? _joinError;
  bool _showRegistrationButton = false;
  bool _showLogoutButton = false;
  String? _inviteEmail;
  bool _showLoginButton = false;
  bool _showAcceptInviteButton = false;
  bool isInviteValid = true; // Neue Variable für Gültigkeit der Einladung

  @override
  void initState() {
    super.initState();
    
    _tabController = TabController(length: 1, vsync: this);
    _initializeServices();
    _loadWorldData();
  }
  
  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Authentication-Status bei Kontext-Änderungen prüfen
    _checkAuthenticationStatus();
  }

  void _initializeServices() {
    try {
      if (ServiceLocator.has<WorldService>()) {
        _worldService = ServiceLocator.get<WorldService>();
      } else {
        _worldService = WorldService();
      }
      
      if (ServiceLocator.has<AuthService>()) {
        _authService = ServiceLocator.get<AuthService>();
      } else {
        _authService = AuthService();
      }
      
      // Authentication-Status prüfen
      _checkAuthenticationStatus();
    } catch (e) {
      AppLogger.app.w('⚠️ ServiceLocator Fehler - nutze direkte Instanziierung', error: e);
      _worldService = WorldService();
      _authService = AuthService();
      
      // Auch bei Fallback Authentication-Status prüfen
      _checkAuthenticationStatus();
    }
  }

  void _checkAuthenticationStatus() {
    try {
      final currentUser = _authService.currentUser;
      final wasAuthenticated = _isAuthenticated;
      _isAuthenticated = currentUser != null;
      
      AppLogger.app.i('🔒 Authentication Status geprüft', error: {
        'isAuthenticated': _isAuthenticated,
        'userId': currentUser?.id,
        'username': currentUser?.username,
        'changed': wasAuthenticated != _isAuthenticated
      });
      
      // UI aktualisieren wenn sich Status geändert hat
      if (wasAuthenticated != _isAuthenticated && mounted) {
        setState(() {});
      }
    } catch (e) {
      AppLogger.logError('Fehler beim Prüfen des Authentication-Status', e);
      _isAuthenticated = false;
    }
  }

  Future<void> _loadWorldData() async {
    // FIXED: Robustere Loading-State Verwaltung
    if (_isLoading) {
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // **KLARE FLOW-TRENNUNG**
      switch (widget.flowType) {
        case WorldJoinFlowType.normal:
          await _handleNormalFlow();
          break;
        case WorldJoinFlowType.invite:
          await _handleInviteFlow();
          break;
      }
      
    } catch (e) {
      AppLogger.app.w('💥 FEHLER in _loadWorldData: $e');
      setState(() {
        _errorMessage = 'Fehler beim Laden der Welt-Daten: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  // **NORMALE NAVIGATION: Einfach und direkt**
  Future<void> _handleNormalFlow() async {
    if (widget.worldId == null) {
      setState(() {
        _errorMessage = 'Keine Welt-ID gefunden';
        _isLoading = false;
      });
      return;
    }
    
    // World laden
    _world = await _worldService.getWorld(int.parse(widget.worldId!));
    
    // Status prüfen
    await _checkWorldStatus();
    
    // Fertig!
    setState(() {
      _isLoading = false;
    });
  }

  // **INVITE-FLOW: Komplex mit Auth-Prüfung**
  Future<void> _handleInviteFlow() async {
    if (widget.inviteToken == null) {
      setState(() {
        _errorMessage = 'Kein Einladungstoken gefunden';
        _isLoading = false;
      });
      return;
    }
    
    // Token validieren
    final tokenData = await _worldService.validateInviteToken(widget.inviteToken!);
    
    if (tokenData == null || tokenData['world'] == null) {
      setState(() {
        _errorMessage = 'Ungültiger oder abgelaufener Einladungslink';
        _isLoading = false;
      });
      return;
    }
    
    // World aus Token-Daten laden
    _world = World.fromJson(tokenData['world']);
    
    // Invite-Details extrahieren
    final inviteData = tokenData['invite'];
    final inviteEmail = inviteData['email'];
    final invitedByData = inviteData['invitedBy'];
    final invitedByName = invitedByData?['username'] ?? 'Unbekannt';
    
    // Invite-Zeitstempel verarbeiten
    final expiresAtString = inviteData['expiresAt'];
    final createdAtString = inviteData['createdAt'];
    final acceptedAtString = inviteData['acceptedAt']; // Falls bereits akzeptiert
    
    DateTime? expiresAt;
    bool isExpired = false;
    bool isAccepted = false;
    
    try {
      if (expiresAtString != null) {
        expiresAt = DateTime.parse(expiresAtString);
        isExpired = DateTime.now().isAfter(expiresAt);
      }
      if (acceptedAtString != null) {
        isAccepted = true;
      }
    } catch (e) {
      AppLogger.app.w('⚠️ Fehler beim Parsen der Invite-Zeitstempel: $e');
    }
    
    isInviteValid = !isExpired && !isAccepted;
    
    // World-Details
    final worldName = _world?.name ?? 'Unbekannte Welt';
    final worldStatus = _world?.status ?? WorldStatus.upcoming;
    final isUpcoming = worldStatus == WorldStatus.upcoming;
    
    // User-Status analysieren
    final userStatusData = tokenData['userStatus'];
    final status = userStatusData['status'];
    final requiresAction = userStatusData['requiresAction'];
    
    // **NEUE INTELLIGENTE BUTTON-LOGIK**
    String actionText = '';
    String infoText = '';
    bool showLoginButton = false;
    bool showRegisterButton = false;
    bool showAcceptButton = false;
    bool showLogoutButton = false;
    
    // Basis-Info-Text mit Einlader, Welt und Gültigkeitsstatus
    final inviterText = invitedByName;
    
    final actionTypeText = isUpcoming 
      ? 'dich vorab zu registrieren für' 
      : 'beizutreten';
    
    // Gültigkeitstext erstellen
    String validityText = '';
    if (expiresAt != null) {
      final expiresAtLocal = expiresAt.toLocal();
      final dateStr = '${expiresAtLocal.day.toString().padLeft(2, '0')}.${expiresAtLocal.month.toString().padLeft(2, '0')}.${expiresAtLocal.year} ${expiresAtLocal.hour.toString().padLeft(2, '0')}:${expiresAtLocal.minute.toString().padLeft(2, '0')}';
      
      if (isAccepted) {
        validityText = '\n\n✅ Diese Einladung wurde bereits akzeptiert.';
      } else if (isExpired) {
        validityText = '\n\n❌ Diese Einladung ist am $dateStr abgelaufen.';
      } else {
        validityText = '\n\n⏰ Gültig bis: $dateStr';
      }
    }
    
    final baseInfoText = 'Du wurdest von $inviterText eingeladen, der Welt "$worldName" $actionTypeText.$validityText';
    
    // Je nach Status unterschiedliche Logik
    switch (status) {
      case 'not_logged_in':
        if (requiresAction == 'register') {
          // Mail ist unbekannt -> nur Register
          actionText = 'Du musst dich mit der E-Mail-Adresse $inviteEmail registrieren.';
          infoText = '$baseInfoText\n\n$actionText';
          showRegisterButton = isInviteValid; // Nur bei gültigen Invites
        }
        break;
        
      case 'user_exists_not_logged_in':
        if (requiresAction == 'login') {
          // Mail ist bekannt, User nicht angemeldet -> nur Login
          actionText = 'Dein Account mit $inviteEmail ist bereits registriert. Bitte melde dich an.';
          infoText = '$baseInfoText\n\n$actionText';
          showLoginButton = isInviteValid; // Nur bei gültigen Invites
        }
        break;
        
      case 'wrong_email':
        if (requiresAction == 'logout_and_register') {
          final currentUserEmail = userStatusData['currentUser']?['email'];
          // User mit falscher Mail angemeldet -> Logout + Register
          actionText = 'Diese Einladung ist für $inviteEmail bestimmt, aber du bist als $currentUserEmail angemeldet.';
          infoText = '$baseInfoText\n\n$actionText\n\nBitte melde dich ab und registriere dich mit der richtigen E-Mail-Adresse.';
          showLogoutButton = isInviteValid; // Nur bei gültigen Invites
        }
        break;
        
      case 'correct_email':
        if (requiresAction == 'join_world') {
          // User richtig angemeldet -> nur Accept Button (KEIN Auto-Accept!)
          actionText = 'Du bist mit der richtigen E-Mail-Adresse angemeldet und kannst die Einladung jetzt annehmen.';
          infoText = '$baseInfoText\n\n$actionText';
          showAcceptButton = isInviteValid; // Nur bei gültigen Invites
          
          // Auto-Accept entfernt: User soll bewusst entscheiden!
        }
        break;
        
      default:
        AppLogger.app.w('❌ Unbekannter User-Status: $status');
        actionText = 'Unbekannter Status: $status';
        infoText = '$baseInfoText\n\n$actionText';
    }
    
    // Bei ungültigen Invites zusätzliche Info
    if (!isInviteValid) {
      infoText += '\n\n⚠️ Diese Einladung kann nicht mehr verwendet werden.';
    }
    
    setState(() {
      _infoMessage = infoText;
      _inviteEmail = inviteEmail;
      
      // Button-Flags setzen
      _showLoginButton = showLoginButton;
      _showRegistrationButton = showRegisterButton; 
      _showLogoutButton = showLogoutButton;
      _showAcceptInviteButton = showAcceptButton;
      
      // WICHTIG: Alte Fehlermeldung zurücksetzen!
      _errorMessage = null;
      
      _isLoading = false;
    });
  }

  // Neue Methode: World-Status für normale Navigation prüfen
  Future<void> _checkWorldStatus() async {
    if (_world == null) return;
    
    try {
      // Prüfe ob User bereits Mitglied ist
      _isJoined = await _worldService.isPlayerInWorld(_world!.id);
      
      // Prüfe Vorregistrierung
      final preRegStatus = await _worldService.getPreRegistrationStatus(_world!.id);
      _isPreRegistered = preRegStatus.isPreRegistered;
      
      AppLogger.app.d('✅ World-Status geprüft', error: {
        'worldName': _world!.name,
        'isJoined': _isJoined,
        'isPreRegistered': _isPreRegistered
      });
    } catch (e) {
      AppLogger.logError('Fehler beim Prüfen des World-Status', e);
    }
  }

  // Neue Methode: Automatische Invite-Akzeptierung
  Future<void> _autoAcceptInvite() async {
    if (widget.inviteToken == null) return;
    
    try {
      final result = await _worldService.acceptInvite(widget.inviteToken!);
      
      if (result != null) {
        setState(() {
          _isJoined = true;
          _infoMessage = 'Willkommen in der Welt "${_world?.name}"! Das Invite wurde automatisch akzeptiert.';
        });
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Erfolgreich der Welt "${_world!.name}" beigetreten!'),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 3),
            ),
          );
        }
      }
    } catch (e) {
      // SPEZIALBEHANDLUNG: "Invite bereits akzeptiert" ist KEIN Fehler!
      if (e.toString().contains('Invite bereits akzeptiert')) {
        setState(() {
          _isJoined = true;
          _infoMessage = 'Du bist bereits Mitglied dieser Welt "${_world?.name}"!';
        });
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Du bist bereits Mitglied der Welt "${_world?.name}"!'),
              backgroundColor: Colors.orange,
              duration: const Duration(seconds: 3),
            ),
          );
        }
        return; // Erfolgreicher Exit
      }
      
      // Andere Fehler normal behandeln
      AppLogger.logError('Automatische Invite-Akzeptierung fehlgeschlagen', e);
      // Fehler nicht als kritisch behandeln - User kann manuell beitreten
      setState(() {
        _infoMessage = 'Du kannst nun der Welt beitreten.';
      });
    }
  }

  Future<void> _joinWorld() async {
    if (_world == null) return;

    setState(() {
      _isJoining = true;
      _joinError = null;
    });

    try {
      bool success = false;
      
      // **INVITE-TOKEN FLOW: Invite akzeptieren**
      if (widget.inviteToken != null) {
        AppLogger.app.i('🎫 Versuche Invite-Akzeptierung für World-Join');
        final inviteResult = await _worldService.acceptInvite(widget.inviteToken!);
        
        if (inviteResult != null) {
          success = true;
          AppLogger.app.i('✅ Invite erfolgreich akzeptiert', error: {
            'worldId': _world!.id,
            'worldName': _world!.name
          });
        }
      } else {
        // **NORMALE NAVIGATION: Standard World-Join**
        AppLogger.app.i('🌍 Versuche normalen World-Join');
        success = await _worldService.joinWorld(_world!.id);
      }
      
      if (success) {
        setState(() {
          _isJoined = true;
        });
        
        if (mounted) {
          final message = widget.inviteToken != null 
            ? 'Einladung akzeptiert! Willkommen in der Welt "${_world!.name}"!'
            : 'Erfolgreich der Welt "${_world!.name}" beigetreten!';
            
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(message),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 3),
            ),
          );
        }
      } else {
        setState(() {
          _joinError = 'Beitritt fehlgeschlagen. Versuche es erneut.';
        });
      }
    } catch (e) {
      AppLogger.logError('World Join fehlgeschlagen', e, context: {
        'worldId': _world?.id,
        'worldName': _world?.name,
        'hasInviteToken': widget.inviteToken != null,
        'inviteToken': widget.inviteToken?.substring(0, 8)
      });
      
      setState(() {
        // Bessere Fehlermeldungen für verschiedene Szenarien
        if (e.toString().contains('bereits akzeptiert')) {
          _joinError = 'Diese Einladung wurde bereits akzeptiert.';
          _isJoined = true; // User ist bereits Mitglied
        } else if (e.toString().contains('nicht für deine E-Mail-Adresse')) {
          _joinError = 'Diese Einladung ist nicht für deine E-Mail-Adresse bestimmt.';
        } else if (e.toString().contains('abgelaufen')) {
          _joinError = 'Diese Einladung ist abgelaufen.';
        } else {
          _joinError = 'Ein Fehler ist aufgetreten: ${e.toString().replaceAll('Exception: ', '')}';
        }
      });
    } finally {
      setState(() {
        _isJoining = false;
      });
    }
  }
  
  Future<void> _preRegisterWorld() async {
    final world = _world;
    if (world == null) return;

    setState(() {
      _isPreRegistering = true;
      _joinError = null;
    });

    try {
      final success = await _worldService.preRegisterWorldAuthenticated(world.id);
      
      if (success) {
        setState(() {
          _isPreRegistered = true;
        });
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Erfolgreich für ${world.name} vorregistriert!'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        setState(() {
          _joinError = 'Fehler bei der Vorregistrierung';
        });
      }
    } catch (e) {
      setState(() {
        _joinError = e.toString().replaceAll('Exception: ', '');
      });
    } finally {
      if (mounted) {
        setState(() {
          _isPreRegistering = false;
        });
      }
    }
  }
  
  Future<void> _cancelPreRegistration() async {
    final world = _world;
    if (world == null) return;

    setState(() {
      _isPreRegistering = true;
      _joinError = null;
    });

    try {
      final success = await _worldService.cancelPreRegistrationAuthenticated(world.id);
      if (success) {
        setState(() {
          _isPreRegistered = false;
        });
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Vorregistrierung für ${world.name} zurückgezogen.'),
              backgroundColor: Colors.orange,
            ),
          );
        }
      } else {
        setState(() {
          _joinError = 'Fehler beim Zurückziehen der Vorregistrierung';
        });
      }
    } catch (e) {
      setState(() {
        _joinError = e.toString().replaceAll('Exception: ', '');
      });
    } finally {
      if (mounted) {
        setState(() {
          _isPreRegistering = false;
        });
      }
    }
  }
  
  Future<void> _leaveWorld() async {
    final world = _world;
    if (world == null) return;
    
    // Bestätigungsdialog anzeigen
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Welt verlassen?'),
        content: Text('Möchtest du die Welt "${world.name}" wirklich verlassen?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Abbrechen'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: const Text('Verlassen'),
          ),
        ],
      ),
    );
    
    if (confirmed != true) return;

    setState(() {
      _isJoining = true;
      _joinError = null;
    });

    try {
      await _worldService.leaveWorld(world.id);
      setState(() {
        _isJoined = false;
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Du hast ${world.name} verlassen.'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    } catch (e) {
      setState(() {
        _joinError = e.toString().replaceAll('Exception: ', '');
      });
    } finally {
      if (mounted) {
        setState(() {
          _isJoining = false;
        });
      }
    }
  }
  
  void _playWorld() {
    final world = _world;
    if (world == null) return;
    // Navigate directly to world dashboard for playing
    context.goNamed('world-dashboard', pathParameters: {'id': world.id.toString()});
  }

  // Welt-Status bestimmen
  String _getWorldStatusText() {
    final world = _world;
    if (world == null) return 'Unbekannt';
    return world.statusText;
  }

  // Welt-Status-Farbe
  Color _getWorldStatusColor() {
    final world = _world;
    if (world == null) return Colors.grey;
    
    switch (world.status) {
      case WorldStatus.upcoming:
        return Colors.orange;
      case WorldStatus.open:
        return Colors.green;
      case WorldStatus.running:
        return Colors.blue;
      case WorldStatus.closed:
        return Colors.red;
      case WorldStatus.archived:
        return Colors.grey;
    }
  }

  // Kann der Benutzer beitreten?
  // Retry-Funktion
  Future<void> _retry() async {
    await _loadWorldData();
  }

  // Navigation zu Registration mit vorausgefüllter E-Mail
  void _navigateToRegistration(String email) {
    AppLogger.app.i('🎫 Navigation zur Registration mit Invite-E-Mail', error: {'email': email});
    
    // FIXED: Invite-Token für Post-Auth-Redirect setzen
    if (widget.inviteToken != null) {
      _authService.setPendingInviteRedirect(widget.inviteToken!);
    }
    
    context.goNamed('register', queryParameters: {'email': email, 'invite_token': widget.inviteToken});
  }

  // Navigation zu Login 
  void _navigateToLogin(String email) {
    AppLogger.app.i('🎫 Navigation zum Login für Invite', error: {'email': email});
    
    // FIXED: Invite-Token für Post-Auth-Redirect setzen
    if (widget.inviteToken != null) {
      _authService.setPendingInviteRedirect(widget.inviteToken!);
    }
    
    context.goNamed('login', queryParameters: {'invite_token': widget.inviteToken});
  }

  // User abmelden und zur Registration weiterleiten
  Future<void> _logout() async {
    try {
      AppLogger.app.i('🎫 User logout für Invite-Umleitung', error: {'inviteEmail': _inviteEmail});
      
      // FIXED: Invite-Token für Post-Auth-Redirect setzen BEVOR logout
      if (widget.inviteToken != null) {
        _authService.setPendingInviteRedirect(widget.inviteToken!);
      }
      
      await _authService.logout();
      
      if (mounted && _inviteEmail != null) {
        // Nach Logout zur Registration mit korrekter E-Mail
        context.goNamed('register', queryParameters: {
          'email': _inviteEmail!,
          'invite_token': widget.inviteToken ?? ''
        });
      }
    } catch (e) {
      AppLogger.logError('Logout für Invite fehlgeschlagen', e);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Fehler beim Abmelden'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    
    return Scaffold(
      body: BackgroundWidget(
        child: Stack(
          children: [
            // Main content
            SafeArea(
              child: _isLoading
                  ? const Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryColor),
                      ),
                    )
                  : _errorMessage != null
                      ? _buildErrorState()
                      : _infoMessage != null
                          ? _buildInfoState()
                          : _world == null
                              ? _buildNotFoundState()
                              : _buildWorldContent(),
            ),
            
            // User info widget (only show when authenticated)
            if (_isAuthenticated)
              const UserInfoWidget(),
            
            // Navigation widget (only show when authenticated)
            if (_isAuthenticated)
              NavigationWidget(
                currentRoute: 'world-join',
                routeParams: {'id': widget.worldId},
                isJoinedWorld: _isJoined,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 500),
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
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.error_outline,
                        size: 80,
                        color: Colors.red[400],
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'Fehler beim Laden',
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        _errorMessage ?? 'Unbekannter Fehler',
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: Colors.grey[300],
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 32),
                      
                      // Verschiedene Action-Buttons je nach Szenario
                      if (_showRegistrationButton && _inviteEmail != null) ...[
                        // Registration Button für neuen User
                        SizedBox(
                          width: double.infinity,
                          height: 48,
                          child: ElevatedButton.icon(
                            onPressed: () => _navigateToRegistration(_inviteEmail!),
                            icon: const Icon(Icons.person_add),
                            label: const Text('Jetzt registrieren'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.primaryColor,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        // Login Button als Alternative
                        SizedBox(
                          width: double.infinity,
                          height: 48,
                          child: OutlinedButton.icon(
                            onPressed: () => _navigateToLogin(_inviteEmail!),
                            icon: const Icon(Icons.login),
                            label: const Text('Bereits registriert? Anmelden'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppTheme.primaryColor,
                              side: const BorderSide(color: AppTheme.primaryColor),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                      ] else if (_showLogoutButton && _inviteEmail != null) ...[
                        // Logout Button für falschen User
                        SizedBox(
                          width: double.infinity,
                          height: 48,
                          child: ElevatedButton.icon(
                            onPressed: _logout,
                            icon: const Icon(Icons.logout),
                            label: const Text('Abmelden & neu registrieren'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.orange,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        // Abbrechen Button
                        SizedBox(
                          width: double.infinity,
                          height: 48,
                          child: OutlinedButton.icon(
                            onPressed: () => context.goNamed('landing'),
                            icon: const Icon(Icons.arrow_back),
                            label: const Text('Zurück zur Startseite'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.grey,
                              side: const BorderSide(color: Colors.grey),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                      ] else ...[
                        // Standard Retry Button
                        SizedBox(
                          width: double.infinity,
                          height: 48,
                          child: ElevatedButton.icon(
                            onPressed: _retry,
                            icon: const Icon(Icons.refresh),
                            label: const Text('Erneut versuchen'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.primaryColor,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                      ],
                      const SizedBox(height: 16),
                      TextButton(
                        onPressed: () => context.goNamed('world-list'),
                        child: const Text(
                          'Zurück zu den Welten',
                          style: TextStyle(
                            color: AppTheme.primaryColor,
                            fontWeight: FontWeight.bold,
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
    );
  }

  Widget _buildInfoState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 500),
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
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.info_outline,
                        size: 80,
                        color: Colors.blue[400],
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'Information',
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        _infoMessage ?? 'Keine Information verfügbar',
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: Colors.grey[300],
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 32),
                      
                      // **NEUE INTELLIGENTE BUTTONS**
                      _buildActionButtons(),
                      
                      // **INVITE-FLOWS: Kein "Zurück"-Link (User kommt von externem Link)**
                      if (widget.inviteToken == null) ...[
                        const SizedBox(height: 16),
                        TextButton(
                          onPressed: () => context.goNamed('world-list'),
                          child: const Text(
                            'Zurück zu den Welten',
                            style: TextStyle(
                              color: AppTheme.primaryColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNotFoundState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 500),
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
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.public_off,
                        size: 80,
                        color: Colors.orange[400],
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'Welt nicht gefunden',
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Die angeforderte Welt existiert nicht oder ist nicht verfügbar.',
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: Colors.grey[300],
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 32),
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: ElevatedButton(
                          onPressed: () => context.goNamed('world-list'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.primaryColor,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text('Zurück zu den Welten'),
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
    );
  }

  Widget _buildWorldContent() {
    return Center(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 900),
        margin: const EdgeInsets.all(24),
        child: Card(
          elevation: 16,
          color: const Color(0xFF1A1A1A),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
            side: BorderSide(
              color: AppTheme.primaryColor.withOpacity(0.3),
              width: 1,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header mit Welt-Name und Status
              Container(
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(24),
                    topRight: Radius.circular(24),
                  ),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppTheme.primaryColor.withOpacity(0.1),
                      AppTheme.primaryColor.withOpacity(0.05),
                    ],
                  ),
                ),
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    // Welt-Name und Status
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _world?.name ?? 'Unbekannte Welt',
                                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  Icon(Icons.calendar_today, size: 16, color: Colors.grey[400]),
                                  const SizedBox(width: 4),
                                  Text(
                                    'Start: ${_world?.startsAt.toString().split(' ')[0] ?? 'Unbekannt'}',
                                    style: TextStyle(color: Colors.grey[400], fontSize: 14),
                                  ),
                                  if (_world?.endsAt != null) ...[
                                    const SizedBox(width: 16),
                                    Icon(Icons.event, size: 16, color: Colors.grey[400]),
                                    const SizedBox(width: 4),
                                    Text(
                                      'Ende: ${_world?.endsAt.toString().split(' ')[0] ?? 'Unbekannt'}',
                                      style: TextStyle(color: Colors.grey[400], fontSize: 14),
                                    ),
                                  ],
                                ],
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: _getWorldStatusColor().withOpacity(0.2),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: _getWorldStatusColor().withOpacity(0.5)),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                _getWorldStatusIcon(),
                                color: _getWorldStatusColor(),
                                size: 16,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                _getWorldStatusText(),
                                style: TextStyle(
                                  color: _getWorldStatusColor(),
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              
              // Tab Bar
              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF2A2A2A),
                  border: Border(
                    bottom: BorderSide(
                      color: AppTheme.primaryColor.withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                ),
                child: TabBar(
                  controller: _tabController,
                  indicatorColor: AppTheme.primaryColor,
                  indicatorWeight: 3,
                  labelColor: AppTheme.primaryColor,
                  unselectedLabelColor: Colors.grey[400],
                  labelStyle: const TextStyle(fontWeight: FontWeight.w600),
                  tabs: const [
                    Tab(
                      icon: Icon(Icons.description_outlined),
                      text: 'Beschreibung',
                    ),
                    Tab(
                      icon: Icon(Icons.rule_outlined),
                      text: 'Spielregeln',
                    ),
                    Tab(
                      icon: Icon(Icons.analytics_outlined),
                      text: 'Statistiken',
                    ),
                  ],
                ),
              ),
              
              // Tab Content
              SizedBox(
                height: 300, // Feste Höhe für Tab-Content
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildDescriptionTab(),
                    _buildRulesTab(),
                    _buildStatisticsTab(),
                  ],
                ),
              ),
              
              // Action Buttons
              Container(
                padding: const EdgeInsets.all(24),
                decoration: const BoxDecoration(
                  color: Color(0xFF1A1A1A),
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(24),
                    bottomRight: Radius.circular(24),
                  ),
                ),
                child: Column(
                  children: [
                    _buildActionButtons(),
                    
                    // Join-Fehler anzeigen
                    if (_joinError != null) ...[
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.red.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.red.withOpacity(0.3)),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.error_outline, color: Colors.red[400], size: 20),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                _joinError ?? 'Unbekannter Fehler',
                                style: TextStyle(color: Colors.red[400], fontSize: 14),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildDescriptionTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.info_outline, color: AppTheme.primaryColor, size: 24),
              SizedBox(width: 8),
              Text(
                'Über diese Welt',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'Dies ist eine spannende Welt voller Abenteuer und Herausforderungen. '
            'Erkunde unbekannte Gebiete, schließe Allianzen und werde zur Legende!',
            style: TextStyle(color: Colors.grey[300], height: 1.5),
          ),
          const SizedBox(height: 24),
          _buildInfoCard('Kategorie', 'Standard', Icons.category),
          _buildInfoCard('Welt-ID', '#${_world?.id ?? 'N/A'}', Icons.tag),
          _buildInfoCard('Erstellt', _world?.createdAt.toString().split(' ')[0] ?? 'Unbekannt', Icons.access_time),
        ],
      ),
    );
  }
  
  Widget _buildRulesTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.rule, color: AppTheme.primaryColor, size: 24),
              SizedBox(width: 8),
              Text(
                'Spielregeln',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildRuleItem('1.', 'Respektiere andere Spieler'),
          _buildRuleItem('2.', 'Keine Cheats oder Exploits verwenden'),
          _buildRuleItem('3.', 'Faire Spielweise ist Pflicht'),
          _buildRuleItem('4.', 'Kommunikation nur im Spielchat'),
          _buildRuleItem('5.', 'Entscheidungen der Spielleitung sind final'),
        ],
      ),
    );
  }
  
  Widget _buildStatisticsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.bar_chart, color: AppTheme.primaryColor, size: 24),
              SizedBox(width: 8),
              Text(
                'Welt-Statistiken',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(child: _buildStatCard('Spieler', '0 / 50', Icons.people)),
              const SizedBox(width: 16),
              Expanded(child: _buildStatCard('Dauer', '30 Tage', Icons.timer)),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(child: _buildStatCard('Status', _getWorldStatusText(), Icons.circle)),
              const SizedBox(width: 16),
              Expanded(child: _buildStatCard('Typ', 'Standard', Icons.public)),
            ],
          ),
        ],
      ),
    );
  }
  
  Widget _buildInfoCard(String label, String value, IconData icon) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF2A2A2A),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[800] ?? Colors.grey),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppTheme.primaryColor, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(color: Colors.grey[400], fontSize: 12),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildRuleItem(String number, String rule) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF2A2A2A),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[800] ?? Colors.grey),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                number,
                style: const TextStyle(
                  color: AppTheme.primaryColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              rule,
              style: TextStyle(color: Colors.grey[300], height: 1.3),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildStatCard(String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF2A2A2A),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.primaryColor.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: AppTheme.primaryColor, size: 32),
          const SizedBox(height: 12),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: Colors.grey[400],
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
  
  IconData _getWorldStatusIcon() {
    switch (_world?.status) {
      case WorldStatus.upcoming:
        return Icons.schedule;
      case WorldStatus.open:
        return Icons.lock_open;
      case WorldStatus.running:
        return Icons.play_circle_outline;
      case WorldStatus.closed:
        return Icons.lock;
      default:
        return Icons.help_outline;
    }
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              '$label:',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.grey[400],
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildActionButtons() {
    List<Widget> buttons = [];

    // **LOGIN BUTTON (wenn User existiert aber nicht angemeldet)**
    if (_showLoginButton && _inviteEmail != null) {
      buttons.add(
        Container(
          width: double.infinity,
          margin: const EdgeInsets.only(bottom: 12.0),
          child: ElevatedButton(
            onPressed: () {
              // Redirect auf Login-Seite mit E-Mail vorausgefüllt
              final loginRoute = '/go/auth/login?email=${Uri.encodeComponent(_inviteEmail!)}';
              
              // Pending Redirect setzen für Post-Auth-Redirect
              _authService.setPendingInviteRedirect(widget.inviteToken!);
              
              context.go(loginRoute);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              'Anmelden',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
        ),
      );
    }

    // **REGISTRATION BUTTON**
    if (_showRegistrationButton && _inviteEmail != null) {
      buttons.add(
        Container(
          width: double.infinity,
          margin: const EdgeInsets.only(bottom: 12.0),
          child: ElevatedButton(
            onPressed: () {
              // Redirect auf Register-Seite mit E-Mail vorausgefüllt
              final registerRoute = '/go/auth/register?email=${Uri.encodeComponent(_inviteEmail!)}';
              
              // Pending Redirect setzen für Post-Auth-Redirect
              _authService.setPendingInviteRedirect(widget.inviteToken!);
              
              context.go(registerRoute);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.secondaryColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              'Registrieren',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
        ),
      );
    }

    // **ACCEPT INVITE BUTTON (wenn User korrekt angemeldet)**
    if (_showAcceptInviteButton && widget.inviteToken != null) {
      buttons.add(
        Container(
          width: double.infinity,
          margin: const EdgeInsets.only(bottom: 12.0),
          child: ElevatedButton(
            onPressed: _isJoining || !isInviteValid ? null : () => _joinWorld(),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green[600],
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: _isJoining
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : const Text(
                    'Einladung annehmen',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
          ),
        ),
      );
    }

    // **LOGOUT BUTTON (wenn User mit falscher E-Mail angemeldet)**
    if (_showLogoutButton) {
      buttons.add(
        Container(
          width: double.infinity,
          margin: const EdgeInsets.only(bottom: 12.0),
          child: ElevatedButton(
            onPressed: () async {
              await _authService.logout();
              // Nach Logout zur Landing-Page
              if (mounted) {
                context.go('/go/landing');
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red[600],
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              'Abmelden',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
        ),
      );
    }

    // FALLBACK: Normale World-Join-Buttons wenn keine spezifischen Buttons
    if (buttons.isEmpty) {
      // **NORMALE WORLD-JOIN LOGIC** (wenn kein Invite-Token)
      if (widget.inviteToken == null && _world != null) {
        final world = _world!;
        
        // **STATUS-BASIERTE INTELLIGENTE BUTTON-LOGIK**
        switch (world.status) {
          case WorldStatus.upcoming:
            // Vorregistrierung oder Zurückziehen
            if (_isPreRegistered) {
              buttons.add(
                Container(
                  width: double.infinity,
                  margin: const EdgeInsets.only(bottom: 12.0),
                  child: ElevatedButton.icon(
                    onPressed: (_isPreRegistering || _isJoining) ? null : _cancelPreRegistration,
                    icon: const Icon(Icons.cancel),
                    label: Text(_isPreRegistering ? 'Wird zurückgezogen...' : 'Vorregistrierung zurückziehen'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red[600],
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              );
            } else {
              buttons.add(
                Container(
                  width: double.infinity,
                  margin: const EdgeInsets.only(bottom: 12.0),
                  child: ElevatedButton.icon(
                    onPressed: (_isPreRegistering || _isJoining) ? null : _preRegisterWorld,
                    icon: const Icon(Icons.how_to_reg),
                    label: Text(_isPreRegistering ? 'Wird registriert...' : 'Vorregistrieren'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange[600],
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              );
            }
            break;
            
          case WorldStatus.open:
          case WorldStatus.running:
            // Beitreten, Spielen oder Verlassen
            if (_isJoined) {
              // Spielen Button
              buttons.add(
                Container(
                  width: double.infinity,
                  margin: const EdgeInsets.only(bottom: 12.0),
                  child: ElevatedButton.icon(
                    onPressed: _playWorld,
                    icon: const Icon(Icons.play_circle_filled),
                    label: const Text('Spielen'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green[600],
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              );
              
              // Verlassen Button
              buttons.add(
                Container(
                  width: double.infinity,
                  margin: const EdgeInsets.only(bottom: 12.0),
                  child: ElevatedButton.icon(
                    onPressed: _isJoining ? null : _leaveWorld,
                    icon: const Icon(Icons.exit_to_app),
                    label: Text(_isJoining ? 'Wird verlassen...' : 'Welt verlassen'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red[600],
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              );
            } else {
              // Beitreten Button
              buttons.add(
                Container(
                  width: double.infinity,
                  margin: const EdgeInsets.only(bottom: 12.0),
                  child: ElevatedButton.icon(
                    onPressed: _isJoining ? null : _joinWorld,
                    icon: const Icon(Icons.play_arrow),
                    label: Text(_isJoining ? 'Wird beigetreten...' : 'Jetzt beitreten'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              );
            }
            break;
            
          case WorldStatus.closed:
          case WorldStatus.archived:
            // Keine Aktionen möglich - Status-Info
            buttons.add(
              Container(
                width: double.infinity,
                margin: const EdgeInsets.only(bottom: 12.0),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.withOpacity(0.3)),
                ),
                child: Column(
                  children: [
                    Icon(
                      Icons.lock_outline,
                      color: Colors.grey[600],
                      size: 32,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      world.status == WorldStatus.closed
                          ? 'Diese Welt ist derzeit geschlossen'
                          : 'Diese Welt ist archiviert',
                      style: TextStyle(
                        color: Colors.grey[700],
                        fontWeight: FontWeight.w500,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            );
            break;
        }
      }
    }

    return Column(
      children: buttons,
    );
  }
} 