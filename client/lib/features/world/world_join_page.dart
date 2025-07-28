import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:go_router/go_router.dart';
import '../../core/models/world.dart';
import '../../core/services/world_service.dart';
import '../../core/services/auth_service.dart';
import '../../theme/app_theme.dart';
import '../../theme/background_widget.dart';

// ServiceLocator Import für DI
import '../../main.dart';

class WorldJoinPage extends StatefulWidget {
  final String worldId;
  
  const WorldJoinPage({super.key, required this.worldId});

  @override
  State<WorldJoinPage> createState() => _WorldJoinPageState();
}

class _WorldJoinPageState extends State<WorldJoinPage> {
  // DI-ready: ServiceLocator verwenden
  late final WorldService _worldService;
  late final AuthService _authService;
  
  bool _isLoading = true;
  bool _isJoining = false;
  bool _isAuthenticated = false;
  World? _world;
  String? _errorMessage;
  String? _joinError;

  @override
  void initState() {
    super.initState();
    
    // DI-ready: ServiceLocator verwenden mit robuster Fehlerbehandlung
    _initializeServices();
    _loadWorldData();
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
      if (kDebugMode) {
        print('[WorldJoinPage] ServiceLocator error: $e, using direct instantiation');
      }
      _worldService = WorldService();
      _authService = AuthService();
    }
  }

  Future<void> _loadWorldData() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      // Auth-Status prüfen
      final isLoggedIn = await _authService.isLoggedIn();
      setState(() {
        _isAuthenticated = isLoggedIn;
      });

      if (!isLoggedIn) {
        setState(() {
          _errorMessage = 'Du musst angemeldet sein, um einer Welt beizutreten';
          _isLoading = false;
        });
        return;
      }

      // Welt-Daten laden
      final worldId = int.tryParse(widget.worldId);
      if (worldId == null) {
        setState(() {
          _errorMessage = 'Ungültige Welt-ID';
          _isLoading = false;
        });
        return;
      }

      final world = await _worldService.getWorld(worldId);
      setState(() {
        _world = world;
        _isLoading = false;
      });

    } catch (e) {
      if (kDebugMode) {
        print('[WorldJoinPage] Error loading world data: $e');
      }
      
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
      final worldId = int.parse(widget.worldId);
      final success = await _worldService.joinWorld(worldId);
      
      if (success) {
        if (mounted) {
          // Erfolgsmeldung anzeigen
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Erfolgreich ${_world?.name ?? 'Welt'} beigetreten!'),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 2),
            ),
          );
          
          // Kurze Verzögerung für bessere UX
          await Future.delayed(const Duration(milliseconds: 500));
          
          if (mounted) {
                      // Zur Welt-Dashboard weiterleiten
          context.goNamed('world-dashboard', pathParameters: {'id': widget.worldId});
          }
        }
      } else {
        setState(() {
          _joinError = 'Beitritt zur Welt fehlgeschlagen';
        });
      }
    } catch (e) {
      if (kDebugMode) {
        print('[WorldJoinPage] Error joining world: $e');
      }
      
      setState(() {
        if (e.toString().contains('already joined')) {
          _joinError = 'Du bist bereits dieser Welt beigetreten';
        } else if (e.toString().contains('world not found')) {
          _joinError = 'Welt nicht gefunden';
        } else if (e.toString().contains('permission denied')) {
          _joinError = 'Keine Berechtigung zum Beitritt';
        } else {
          _joinError = 'Fehler beim Beitritt zur Welt';
        }
      });
    } finally {
      if (mounted) {
        setState(() {
          _isJoining = false;
        });
      }
    }
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
  bool _canJoinWorld() {
    final world = _world;
    if (world == null || !_isAuthenticated) return false;
    
    return world.canJoin;
  }

  // Retry-Funktion
  Future<void> _retry() async {
    await _loadWorldData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Welt beitreten'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.goNamed('world-list'),
        ),
      ),
      body: BackgroundWidget(
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
                        child: Text(
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
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Welt-Header
              Card(
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
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Welt-Name und Status
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                _world?.name ?? 'Unbekannte Welt',
                                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: _getWorldStatusColor().withOpacity(0.2),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(color: _getWorldStatusColor().withOpacity(0.5)),
                              ),
                              child: Text(
                                _getWorldStatusText(),
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: _getWorldStatusColor(),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        
                        // Welt-Start- und Enddatum
                        Text(
                          'Start: ${_world?.startsAt.toString().split(' ')[0] ?? 'Unbekannt'}',
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: Colors.grey[300],
                          ),
                        ),
                        if (_world?.endsAt != null) ...[
                          const SizedBox(height: 8),
                          Text(
                            'Ende: ${_world?.endsAt.toString().split(' ')[0] ?? 'Unbekannt'}',
                            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              color: Colors.grey[300],
                            ),
                          ),
                        ],
                        const SizedBox(height: 16),
                        
                        // Welt-Info-Box
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: const Color(0xFF2D2D2D),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppTheme.primaryColor.withOpacity(0.3)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    Icons.info_outline,
                                    color: AppTheme.primaryColor,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Welt-Informationen',
                                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                      color: AppTheme.primaryColor,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              _buildInfoRow('ID', _world?.id.toString() ?? 'Unbekannt'),
                              _buildInfoRow('Erstellt', _world?.createdAt.toString().split(' ')[0] ?? 'Unbekannt'),
                              _buildInfoRow('Start', _world?.startsAt.toString().split(' ')[0] ?? 'Unbekannt'),
                              if (_world?.endsAt != null)
                                _buildInfoRow('Ende', _world?.endsAt.toString().split(' ')[0] ?? 'Unbekannt'),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Join-Button oder Status-Meldung
              if (_canJoinWorld()) ...[
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isJoining ? null : _joinWorld,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      backgroundColor: AppTheme.primaryColor,
                      foregroundColor: Colors.white,
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
                            'Jetzt beitreten',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),
              ] else ...[
                Container(
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
                        _world?.status == WorldStatus.closed
                            ? 'Diese Welt ist derzeit geschlossen'
                            : _world?.status == WorldStatus.archived
                                ? 'Diese Welt ist archiviert'
                                : 'Beitritt nicht möglich',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey.shade700,
                          fontWeight: FontWeight.w500,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ],
              
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
                      Icon(
                        Icons.error_outline,
                        color: Colors.red.shade600,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _joinError ?? 'Unbekannter Fehler',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.red.shade700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              
              const SizedBox(height: 24),
              
              // Zurück-Button
              SizedBox(
                width: double.infinity,
                child: TextButton(
                  onPressed: () => context.goNamed('world-list'),
                  child: const Text('Zurück zu den Welten'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
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
} 