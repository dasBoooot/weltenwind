import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:go_router/go_router.dart';
import '../../config/logger.dart';
import '../../core/models/world.dart';
import '../../core/services/world_service.dart';
import '../../core/services/auth_service.dart';
import '../../theme/app_theme.dart';
import '../../theme/background_widget.dart';
import '../../shared/widgets/user_info_widget.dart';
import '../../shared/widgets/navigation_widget.dart';

// ServiceLocator Import für DI
import '../../main.dart';

class WorldJoinPage extends StatefulWidget {
  final String? worldId;
  final String? inviteToken;
  
  const WorldJoinPage({super.key, this.worldId, this.inviteToken});

  @override
  State<WorldJoinPage> createState() => _WorldJoinPageState();
}

class _WorldJoinPageState extends State<WorldJoinPage> with SingleTickerProviderStateMixin {
  // DI-ready: ServiceLocator verwenden
  late final WorldService _worldService;
  late final AuthService _authService;
  
  // Tab Controller
  late TabController _tabController;
  
  bool _isLoading = true;
  bool _isJoining = false;
  bool _isPreRegistering = false;
  bool _isAuthenticated = false;
  bool _isJoined = false;
  bool _isPreRegistered = false;
  World? _world;
  String? _errorMessage;
  String? _joinError;

  @override
  void initState() {
    super.initState();
    
    // Tab Controller initialisieren
    _tabController = TabController(length: 3, vsync: this);
    
    // DI-ready: ServiceLocator verwenden mit robuster Fehlerbehandlung
    _initializeServices();
    _loadWorldData();
  }
  
  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
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
    } catch (e) {
      AppLogger.app.w('⚠️ ServiceLocator Fehler - nutze direkte Instanziierung', error: e);
      _worldService = WorldService();
      _authService = AuthService();
    }
  }

  Future<void> _loadWorldData() async {
    try {
      // Prüfe Authentifizierung
      final user = _authService.currentUser;
      
      setState(() {
        _isAuthenticated = user != null;
      });

      if (user == null) {
        // Ohne Login sind nur Basis-Infos verfügbar
        setState(() {
          _isLoading = false;
        });
        return;
      }

      // Welt-Daten laden - entweder über worldId oder inviteToken
      World? world;
      int? worldId;
      
      if (widget.worldId != null) {
        // Standard-Fall: worldId ist gegeben
        worldId = int.tryParse(widget.worldId!);
        if (worldId == null) {
          setState(() {
            _errorMessage = 'Ungültige Welt-ID';
            _isLoading = false;
          });
          return;
        }
        world = await _worldService.getWorld(worldId);
      } else if (widget.inviteToken != null) {
        // Invite-Token Fall: erst Token validieren und World-Info laden
        try {
          AppLogger.app.i('🎫 Invite-Token wird verarbeitet', error: {'token': widget.inviteToken!.substring(0, 8) + '...'});
          
          // API-Call um Welt-Info über Invite-Token zu bekommen
          final tokenData = await _worldService.validateInviteToken(widget.inviteToken!);
          
          if (tokenData != null && tokenData['world'] != null) {
            // Token ist gültig - erstelle World-Objekt aus den Daten
            final worldData = tokenData['world'];
            world = World.fromJson(worldData);
            worldId = world.id;
            
            AppLogger.app.i('✅ Invite-Token erfolgreich validiert', error: {
              'worldId': worldId,
              'worldName': world.name,
              'inviter': tokenData['invite']?['inviterName']
            });
          } else {
            setState(() {
              _errorMessage = 'Ungültiger oder abgelaufener Invite-Token';
              _isLoading = false;
            });
            return;
          }
        } catch (e) {
          AppLogger.logError('Invite-Token Verarbeitung fehlgeschlagen', e, context: {'token': widget.inviteToken});
          setState(() {
            _errorMessage = 'Fehler beim Validieren des Invite-Tokens';
            _isLoading = false;
          });
          return;
        }
      } else {
        // Weder worldId noch inviteToken - das sollte nicht passieren
        setState(() {
          _errorMessage = 'Keine Welt-Information verfügbar';
          _isLoading = false;
        });
        return;
      }
      
      // Prüfe ob der User bereits beigetreten oder vorregistriert ist
      bool isJoined = false;
      bool isPreRegistered = false;
      
      if (worldId != null && _authService.currentUser != null) {
        try {
          isJoined = await _worldService.isPlayerInWorld(worldId);
          isPreRegistered = await _worldService.isPreRegisteredForWorld(worldId);
        } catch (e) {
          AppLogger.logError('World Status Check fehlgeschlagen', e);
        }
      }
      
      setState(() {
        _world = world;
        _isJoined = isJoined;
        _isPreRegistered = isPreRegistered;
        _isLoading = false;
      });

    } catch (e) {
      AppLogger.logError('World-Daten laden fehlgeschlagen', e, context: {
        'worldId': widget.worldId,
        'inviteToken': widget.inviteToken != null ? widget.inviteToken!.substring(0, 8) + '...' : null
      });
      
      setState(() {
        _errorMessage = 'Fehler beim Laden der Welt-Daten';
        _isLoading = false;
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
      // WorldId extrahieren - entweder direkt oder über die geladene Welt
      int? worldId;
      
      if (widget.worldId != null) {
        worldId = int.tryParse(widget.worldId!);
      } else if (_world != null) {
        worldId = _world!.id;
      }
      
      if (worldId == null) {
        setState(() {
          _joinError = 'Welt-ID konnte nicht ermittelt werden';
          _isJoining = false;
        });
        return;
      }
      
      final success = await _worldService.joinWorld(worldId);
      
      if (success) {
        setState(() {
          _isJoined = true;
        });
        
        if (mounted) {
          // Erfolgreich beigetreten - zeige Erfolgsmeldung
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Erfolgreich der Welt "${_world!.name}" beigetreten!'),
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
        'worldId': widget.worldId,
        'inviteToken': widget.inviteToken != null ? widget.inviteToken!.substring(0, 8) + '...' : null,
        'worldName': _world?.name
      });
      
      setState(() {
        _joinError = 'Ein Fehler ist aufgetreten: ${e.toString()}';
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
    final world = _world;
    if (world == null) return const SizedBox.shrink();
    
    final List<Widget> buttons = [];
    
    // Status-basierte Button-Logik (wie in world_list_page)
    switch (world.status) {
      case WorldStatus.upcoming:
        // Vorregistrierung oder Zurückziehen
        if (_isPreRegistered) {
          buttons.add(
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: (_isPreRegistering || _isJoining) ? null : _cancelPreRegistration,
                icon: const Icon(Icons.cancel),
                label: Text(_isPreRegistering ? 'Wird zurückgezogen...' : 'Vorregistrierung zurückziehen'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: Colors.red[600],
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          );
        } else {
          buttons.add(
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: (_isPreRegistering || _isJoining) ? null : _preRegisterWorld,
                icon: const Icon(Icons.how_to_reg),
                label: Text(_isPreRegistering ? 'Wird registriert...' : 'Vorregistrieren'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: Colors.orange[600],
                  foregroundColor: Colors.white,
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
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _playWorld,
                icon: const Icon(Icons.play_circle_filled),
                label: const Text('Spielen'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: Colors.green[600],
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          );
          
          buttons.add(const SizedBox(height: 12));
          
          // Verlassen Button
          buttons.add(
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _isJoining ? null : _leaveWorld,
                icon: const Icon(Icons.exit_to_app),
                label: Text(_isJoining ? 'Wird verlassen...' : 'Welt verlassen'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: Colors.red[600],
                  foregroundColor: Colors.white,
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
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _isJoining ? null : _joinWorld,
                icon: const Icon(Icons.play_arrow),
                label: Text(_isJoining ? 'Wird beigetreten...' : 'Jetzt beitreten'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: AppTheme.primaryColor,
                  foregroundColor: Colors.white,
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
        // Keine Aktionen möglich
        return Container(
          width: double.infinity,
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
                color: Colors.grey.shade600,
                size: 32,
              ),
              const SizedBox(height: 8),
              Text(
                world.status == WorldStatus.closed
                    ? 'Diese Welt ist derzeit geschlossen'
                    : 'Diese Welt ist archiviert',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey.shade700,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        );
    }
    
    return Column(
      children: buttons,
    );
  }
} 