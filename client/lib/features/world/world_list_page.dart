import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:go_router/go_router.dart';
import '../../config/logger.dart';
import '../../core/services/auth_service.dart';
import '../../core/services/world_service.dart';
import '../../core/services/invite_service.dart';
import '../../core/models/world.dart';
import '../../theme/app_theme.dart';
import '../../theme/background_widget.dart';
import '../../routing/app_router.dart';
// Unused import removed
import '../../shared/widgets/invite_dialog.dart';
import '../../shared/widgets/user_info_widget.dart';
import '../../shared/widgets/navigation_widget.dart';
import './widgets/world_card.dart';
import './widgets/world_filters.dart';

// ServiceLocator Import für DI
import '../../main.dart';

class WorldListPage extends StatefulWidget {
  const WorldListPage({super.key});

  @override
  State<WorldListPage> createState() => _WorldListPageState();
}

class _WorldListPageState extends State<WorldListPage> {
  // DI-ready: ServiceLocator verwenden
  late final AuthService _authService;
  late final WorldService _worldService;
  late final InviteService _inviteService;
  
  List<World> _worlds = [];
  List<World> _filteredWorlds = [];
  bool _isLoading = true;
  String? _error;
  
  // Track button states for each world
  final Map<int, bool> _preRegisteredWorlds = {};
  final Map<int, bool> _joinedWorlds = {};
  
  // Filter und Sortierung
  WorldStatus? _statusFilter;
  WorldCategory? _categoryFilter;
  String _sortBy = 'startDate'; // 'startDate', 'name', 'status'
  bool _sortAscending = true;
  
  // Spieleranzahl (Simulation - später vom Backend)
  final Map<int, int> _playerCounts = {};

  @override
  void initState() {
    super.initState();
    
    // DI-ready: ServiceLocator verwenden mit robuster Fehlerbehandlung
    _initializeServices();
    _loadWorlds();
  }

  void _initializeServices() {
    try {
      if (ServiceLocator.has<AuthService>()) {
        _authService = ServiceLocator.get<AuthService>();
      } else {
        _authService = AuthService();
      }
      
      if (ServiceLocator.has<WorldService>()) {
        _worldService = ServiceLocator.get<WorldService>();
      } else {
        _worldService = WorldService();
      }
      
      if (ServiceLocator.has<InviteService>()) {
        _inviteService = ServiceLocator.get<InviteService>();
      } else {
        _inviteService = InviteService();
      }
    } catch (e) {
      AppLogger.app.w('⚠️ ServiceLocator Fehler - nutze direkte Instanziierung', error: e);
      _authService = AuthService();
      _worldService = WorldService();
      _inviteService = InviteService();
    }
  }

  Future<void> _loadWorlds() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final worlds = await _worldService.getWorlds();
      if (mounted) {
        setState(() {
          _worlds = worlds;
          _isLoading = false;
        });
        
        // Simuliere Spieleranzahl für Demo-Zwecke
        _generateMockPlayerCounts();
        
        // Check player status for each world (silently handle 404s)
        _checkPlayerStatuses();
        _checkPreRegistrationStatuses();
        
        // Initial filter anwenden
        _applyFiltersAndSorting();
      }
    } catch (e) {
      if (mounted) {
        // Only show error for non-401/404 errors
        if (!e.toString().contains('401') && !e.toString().contains('404') && !e.toString().contains('Token fehlt')) {
          setState(() {
            _error = e.toString();
            _isLoading = false;
          });
          
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Fehler beim Laden der Welten: ${e.toString()}'),
              backgroundColor: AppTheme.errorColor,
            ),
          );
        } else {
          // For 401/404/token errors, just set loading to false
          setState(() {
            _isLoading = false;
          });
          
          // If token is invalid, redirect to login
          if (e.toString().contains('401') || e.toString().contains('Token fehlt')) {
            await _authService.logout();
            // Cache invalidieren nach Logout
            AppRouter.invalidateAuthCache();
            if (mounted) {
              context.goNamed('login');
            }
          }
        }
      }
    }
  }

  void _generateMockPlayerCounts() {
    final random = DateTime.now().millisecondsSinceEpoch;
    for (final world in _worlds) {
      // Generate realistic player counts based on world status
      int baseCount = 0;
      switch (world.status) {
        case WorldStatus.upcoming:
          baseCount = 5 + (random % 15); // 5-20 players
          break;
        case WorldStatus.open:
          baseCount = 20 + (random % 30); // 20-50 players
          break;
        case WorldStatus.running:
          baseCount = 50 + (random % 100); // 50-150 players
          break;
        case WorldStatus.closed:
        case WorldStatus.archived:
          baseCount = 0 + (random % 10); // 0-10 players
          break;
      }
      _playerCounts[world.id] = baseCount;
    }
  }

  void _applyFiltersAndSorting() {
    List<World> filtered = List.from(_worlds);
    
    // Apply status filter
    if (_statusFilter != null) {
      filtered = filtered.where((world) => world.status == _statusFilter).toList();
    }
    
    // Apply category filter (mock implementation)
    if (_categoryFilter != null) {
      // In real app, this would be based on world.category field
      // For now, we'll use a simple hash-based categorization
      filtered = filtered.where((world) {
        final categoryHash = world.id % 4;
        switch (_categoryFilter) {
          case WorldCategory.classic:
            return categoryHash == 0;
          case WorldCategory.pvp:
            return categoryHash == 1;
          case WorldCategory.event:
            return categoryHash == 2;
          case WorldCategory.experimental:
            return categoryHash == 3;
          default:
            return false;
        }
      }).toList();
    }
    
    // Apply sorting
    filtered.sort((a, b) {
      int comparison = 0;
      switch (_sortBy) {
        case 'startDate':
          comparison = a.startsAt.compareTo(b.startsAt);
          break;
        case 'name':
          comparison = a.name.compareTo(b.name);
          break;
        case 'status':
          comparison = a.status.index.compareTo(b.status.index);
          break;
        case 'playerCount':
          final countA = _playerCounts[a.id] ?? 0;
          final countB = _playerCounts[b.id] ?? 0;
          comparison = countA.compareTo(countB);
          break;
      }
      return _sortAscending ? comparison : -comparison;
    });
    
    setState(() {
      _filteredWorlds = filtered;
    });
  }

  WorldCategory _getWorldCategory(World world) {
    // Mock categorization based on world ID
    final categoryHash = world.id % 4;
    switch (categoryHash) {
      case 0:
        return WorldCategory.classic;
      case 1:
        return WorldCategory.pvp;
      case 2:
        return WorldCategory.event;
      case 3:
        return WorldCategory.experimental;
      default:
        return WorldCategory.classic;
    }
  }

  // Unused methods removed - now handled in WorldCard widget

  Future<void> _checkPlayerStatuses() async {
    for (final world in _worlds) {
      try {
        final isPlayer = await _worldService.isPlayerInWorld(world.id);
        if (mounted) {
          setState(() {
            _joinedWorlds[world.id] = isPlayer;
          });
        }
      } catch (e) {
        // 404 means user is not in this world, which is normal
        if (e.toString().contains('404')) {
          if (mounted) {
            setState(() {
              _joinedWorlds[world.id] = false;
            });
          }
        } else {
          // Only log other errors
          AppLogger.logError('Player-Status Check fehlgeschlagen', e, context: {'worldId': world.id});
        }
      }
    }
  }

  Future<void> _checkPreRegistrationStatuses() async {
    for (final world in _worlds) {
      // Only check for worlds that support pre-registration
      if (world.canPreRegister) {
        try {
          final isPreRegistered = await _worldService.isPreRegisteredForWorld(world.id);
          if (mounted) {
            setState(() {
              _preRegisteredWorlds[world.id] = isPreRegistered;
            });
          }
        } catch (e) {
          // 404 means user is not pre-registered, which is normal
          if (e.toString().contains('404')) {
            if (mounted) {
              setState(() {
                _preRegisteredWorlds[world.id] = false;
              });
            }
          } else {
            // Only log other errors
            AppLogger.logError('Pre-Registration Status Check fehlgeschlagen', e, context: {'worldId': world.id});
          }
        }
      }
    }
  }

  Future<void> _joinWorld(World world) async {
    try {
      final success = await _worldService.joinWorld(world.id);
      if (success && mounted) {
        setState(() {
          _joinedWorlds[world.id] = true;
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erfolgreich zu ${world.name} beigetreten!'),
            backgroundColor: Colors.green,
          ),
        );
        // Navigate to world dashboard
        context.goNamed('world-dashboard', pathParameters: {'id': world.id.toString()});
      }
    } catch (e) {
      if (mounted) {
        // Prüfe ob es ein Token-Problem ist
        if (e.toString().contains('401') || e.toString().contains('Token fehlt')) {
          await _authService.logout();
          // Cache invalidieren nach Logout
          AppRouter.invalidateAuthCache();
          if (mounted) {
            context.goNamed('login');
          }
        } else {
          final errorMessage = e.toString().replaceAll('Exception: ', '');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(errorMessage),
              backgroundColor: AppTheme.errorColor,
            ),
          );
        }
      }
    }
  }

  Future<void> _preRegisterWorld(World world) async {
    try {
      final success = await _worldService.preRegisterWorldAuthenticated(world.id);
      if (success && mounted) {
        setState(() {
          _preRegisteredWorlds[world.id] = true;
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erfolgreich für ${world.name} vorregistriert!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        // Prüfe ob es ein Token-Problem ist
        if (e.toString().contains('401') || e.toString().contains('Token fehlt')) {
          await _authService.logout();
          // Cache invalidieren nach Logout
          AppRouter.invalidateAuthCache();
          if (mounted) {
            context.goNamed('login');
          }
        } else {
          final errorMessage = e.toString().replaceAll('Exception: ', '');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(errorMessage),
              backgroundColor: AppTheme.errorColor,
            ),
          );
        }
      }
    }
  }

  Future<void> _leaveWorld(World world) async {
    // Zeige Bestätigungsdialog
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

    try {
      final success = await _worldService.leaveWorld(world.id);
      if (success && mounted) {
        setState(() {
          _joinedWorlds[world.id] = false;
          // Update player count
          final currentCount = _playerCounts[world.id] ?? 0;
          if (currentCount > 0) {
            _playerCounts[world.id] = currentCount - 1;
          }
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Du hast ${world.name} verlassen.'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        // Prüfe ob es ein Token-Problem ist
        if (e.toString().contains('401') || e.toString().contains('Token fehlt')) {
          await _authService.logout();
          // Cache invalidieren nach Logout
          AppRouter.invalidateAuthCache();
          if (mounted) {
            context.goNamed('login');
          }
        } else {
          final errorMessage = e.toString().replaceAll('Exception: ', '');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(errorMessage),
              backgroundColor: AppTheme.errorColor,
            ),
          );
        }
      }
    }
  }

  Future<void> _cancelPreRegistration(World world) async {
    try {
      final success = await _worldService.cancelPreRegistrationAuthenticated(world.id);
      
      if (success && mounted) {
        setState(() {
          _preRegisteredWorlds[world.id] = false;
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Vorregistrierung für ${world.name} zurückgezogen.'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        // Prüfe ob es ein Token-Problem ist
        if (e.toString().contains('401') || e.toString().contains('Token fehlt')) {
          await _authService.logout();
          // Cache invalidieren nach Logout
          AppRouter.invalidateAuthCache();
          if (mounted) {
            context.goNamed('login');
          }
        } else {
          final errorMessage = e.toString().replaceAll('Exception: ', '');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(errorMessage),
              backgroundColor: AppTheme.errorColor,
            ),
          );
        }
      }
    }
  }

  Future<void> _createInvite(World world) async {
    final result = await showDialog<String>(
      context: context,
      builder: (context) => InviteDialog(worldName: world.name),
    );

    if (result != null && result.isNotEmpty) {
      try {
        final success = await _inviteService.createInvite(world.id, result);
        if (success && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Einladung erfolgreich versendet!'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          // Prüfe ob es ein Token-Problem ist
          if (e.toString().contains('401') || e.toString().contains('Token fehlt')) {
            await _authService.logout();
            // Cache invalidieren nach Logout
            AppRouter.invalidateAuthCache();
            if (mounted) {
              context.goNamed('login');
            }
          } else {
            final errorMessage = e.toString().replaceAll('Exception: ', '');
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(errorMessage),
                backgroundColor: AppTheme.errorColor,
              ),
            );
          }
        }
      }
    }
  }

  // Deep-Link zur World-Join-Page
  void _navigateToWorldJoin(World world) {
    context.goNamed('world-join', pathParameters: {'id': world.id.toString()});
  }

  void _playWorld(World world) {
    // Navigate directly to world dashboard for playing
    context.goNamed('world-dashboard', pathParameters: {'id': world.id.toString()});
  }

// Filter and sort methods removed - now using WorldFilters widget

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BackgroundWidget(
        child: Stack(
          children: [
            // Main content
            Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24.0),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 800),
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
                              // Logo
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
                                  Icons.public,
                                  size: 40,
                                  color: AppTheme.primaryColor,
                                ),
                              ),
                              const SizedBox(height: 24),
                              
                              // Title
                              Text(
                                'Weltenwind',
                                style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),
                              
                              // Subtitle
                              Text(
                                'Wähle deine Welt aus',
                                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                  color: Colors.grey[300],
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 24),
                              
                              // Filter und Sortierung
                              if (!_isLoading && _worlds.isNotEmpty) ...[
                                WorldFilters(
                                  statusFilter: _statusFilter,
                                  categoryFilter: _categoryFilter,
                                  sortBy: _sortBy,
                                  sortAscending: _sortAscending,
                                  onStatusChanged: (status) {
                                    setState(() {
                                      _statusFilter = status;
                                    });
                                    _applyFiltersAndSorting();
                                  },
                                  onCategoryChanged: (category) {
                                    setState(() {
                                      _categoryFilter = category;
                                    });
                                    _applyFiltersAndSorting();
                                  },
                                  onSortByChanged: (sortBy) {
                                    setState(() {
                                      _sortBy = sortBy;
                                    });
                                    _applyFiltersAndSorting();
                                  },
                                  onSortOrderChanged: () {
                                    setState(() {
                                      _sortAscending = !_sortAscending;
                                    });
                                    _applyFiltersAndSorting();
                                  },
                                  onResetFilters: () {
                                    setState(() {
                                      _statusFilter = null;
                                      _categoryFilter = null;
                                      _sortBy = 'startDate';
                                      _sortAscending = true;
                                    });
                                    _applyFiltersAndSorting();
                                  },
                                ),
                                const SizedBox(height: 16),
                              ],
                              
                              // World list
                              if (_isLoading)
                                const Center(
                                  child: CircularProgressIndicator(
                                    valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryColor),
                                  ),
                                )
                              else if (_error != null)
                                Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: (Colors.red[900] ?? Colors.red).withOpacity(0.3),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: (Colors.red[400] ?? Colors.red).withOpacity(0.5),
                                    ),
                                  ),
                                  child: Column(
                                    children: [
                                      Icon(
                                        Icons.error,
                                        size: 48,
                                        color: Colors.red[400],
                                      ),
                                      const SizedBox(height: 16),
                                      Text(
                                        'Fehler beim Laden der Welten',
                                        style: TextStyle(
                                          color: Colors.red[200],
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        _error ?? 'Unbekannter Fehler',
                                        style: TextStyle(
                                          color: (Colors.red[200] ?? Colors.red).withOpacity(0.8),
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                    ],
                                  ),
                                )
                              else if (_filteredWorlds.isEmpty)
                                Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF2D2D2D),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: AppTheme.primaryColor.withOpacity(0.3),
                                    ),
                                  ),
                                  child: Column(
                                    children: [
                                      Icon(
                                        Icons.filter_list,
                                        size: 48,
                                        color: AppTheme.primaryColor.withOpacity(0.7),
                                      ),
                                      const SizedBox(height: 16),
                                      Text(
                                        'Keine Welten gefunden',
                                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                          color: Colors.grey[300],
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        'Versuche andere Filter-Einstellungen.',
                                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                          color: Colors.grey[400],
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                    ],
                                  ),
                                )
                              else
                                Column(
                                  children: _filteredWorlds.map((world) => WorldCard(
                                    world: world,
                                    playerCount: _playerCounts[world.id] ?? 0,
                                    category: _getWorldCategory(world),
                                    isPreRegistered: _preRegisteredWorlds[world.id] ?? false,
                                    isJoined: _joinedWorlds[world.id] ?? false,
                                    onJoin: world.canJoin && !(_joinedWorlds[world.id] ?? false) 
                                      ? () => _joinWorld(world) 
                                      : null,
                                    onLeave: (_joinedWorlds[world.id] ?? false)
                                      ? () => _leaveWorld(world)
                                      : null,
                                    onPlay: (_joinedWorlds[world.id] ?? false) && 
                                            (world.status == WorldStatus.open || world.status == WorldStatus.running)
                                      ? () => _playWorld(world)
                                      : null,
                                    onPreRegister: world.canPreRegister && !(_preRegisteredWorlds[world.id] ?? false)
                                      ? () => _preRegisterWorld(world)
                                      : null,
                                    onCancelPreRegistration: (_preRegisteredWorlds[world.id] ?? false)
                                      ? () => _cancelPreRegistration(world)
                                      : null,
                                    onInvite: world.canInvite
                                      ? () => _createInvite(world)
                                      : null,
                                    onTap: () => _navigateToWorldJoin(world),
                                  )).toList(),
                                ),
                              
                              const SizedBox(height: 24),
                              
                              // Action buttons
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                children: [
                                  SizedBox(
                                    height: 48,
                                    child: ElevatedButton.icon(
                                      onPressed: _loadWorlds,
                                      icon: const Icon(Icons.refresh),
                                      label: const Text('Aktualisieren'),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: AppTheme.primaryColor,
                                        foregroundColor: Colors.white,
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 24,
                                          vertical: 12,
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(12),
                                        ),
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
            
            // User info widget in top-left corner
            const UserInfoWidget(),
            
            // Navigation widget in top-right corner
            const NavigationWidget(currentRoute: 'world-list'),
          ],
        ),
      ),
    );
  }
} 