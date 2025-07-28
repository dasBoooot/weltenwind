import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:go_router/go_router.dart';
import '../../core/services/auth_service.dart';
import '../../core/services/world_service.dart';
import '../../core/services/invite_service.dart';
import '../../core/models/world.dart';
import '../../theme/app_theme.dart';
import '../../theme/background_widget.dart';
import '../../routing/app_router.dart';
// Unused import removed
import '../../shared/widgets/invite_dialog.dart';

// ServiceLocator Import für DI
import '../../main.dart';

// Welt-Kategorien für bessere Organisation
enum WorldCategory {
  classic,
  pvp,
  event,
  experimental,
}

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
  Map<int, bool> _preRegisteredWorlds = {};
  Map<int, bool> _joinedWorlds = {};
  
  // Filter und Sortierung
  WorldStatus? _statusFilter;
  WorldCategory? _categoryFilter;
  String _sortBy = 'startDate'; // 'startDate', 'name', 'status'
  bool _sortAscending = true;
  
  // Spieleranzahl (Simulation - später vom Backend)
  Map<int, int> _playerCounts = {};

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
      if (kDebugMode) {
        print('[WorldListPage] ServiceLocator error: $e, using direct instantiation');
      }
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

  // Unused method removed

  Color _getCategoryColor(WorldCategory category) {
    switch (category) {
      case WorldCategory.classic:
        return Colors.blue;
      case WorldCategory.pvp:
        return Colors.red;
      case WorldCategory.event:
        return Colors.purple;
      case WorldCategory.experimental:
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  double _getWorldProgress(World world) {
    final endsAt = world.endsAt;
    if (endsAt == null) return 0.0;
    
    final now = DateTime.now();
    final totalDuration = endsAt.difference(world.startsAt).inDays;
    final elapsed = now.difference(world.startsAt).inDays;
    
    if (totalDuration <= 0) return 0.0;
    if (elapsed < 0) return 0.0;
    if (elapsed >= totalDuration) return 1.0;
    
    return elapsed / totalDuration;
  }

  String _getProgressText(World world) {
    final endsAt = world.endsAt;
    if (endsAt == null) return '';
    
    final now = DateTime.now();
    final totalDuration = endsAt.difference(world.startsAt).inDays;
    final elapsed = now.difference(world.startsAt).inDays;
    
    if (elapsed < 0) {
      final daysUntilStart = -elapsed;
      return 'Startet in $daysUntilStart Tagen';
    } else if (elapsed >= totalDuration) {
      return 'Abgeschlossen';
    } else {
      final percentage = ((elapsed / totalDuration) * 100).round();
      return 'Tag ${elapsed + 1} von $totalDuration • $percentage% abgeschlossen';
    }
  }

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
          if (kDebugMode) {
            print('Error checking player status for world ${world.id}: $e');
          }
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
            if (kDebugMode) {
              print('Error checking pre-registration status for world ${world.id}: $e');
            }
          }
        }
      }
    }
  }

  Future<void> _logout() async {
    await _authService.logout();
    // Cache invalidieren nach Logout
    AppRouter.invalidateAuthCache();
    if (mounted) {
      context.goNamed('login');
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
            SnackBar(
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

  Widget _buildFilterChips() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: WorldCategory.values.map((category) {
          final isSelected = _categoryFilter == category;
          String label;
          IconData icon;
          
          switch (category) {
            case WorldCategory.classic:
              label = 'Classic';
              icon = Icons.list;
              break;
            case WorldCategory.pvp:
              label = 'PvP';
              icon = Icons.schedule;
              break;
            case WorldCategory.event:
              label = 'Event';
              icon = Icons.lock_open;
              break;
            case WorldCategory.experimental:
              label = 'Experimental';
              icon = Icons.play_arrow;
              break;
          }
          
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: Container(
              height: 40, // Konsistente Höhe
              child: FilterChip(
                selected: isSelected,
                label: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(icon, size: 16, color: isSelected ? Colors.white : Colors.grey[300]),
                    const SizedBox(width: 4),
                    Text(label, style: TextStyle(color: isSelected ? Colors.white : Colors.grey[300])),
                  ],
                ),
                onSelected: (selected) {
                  setState(() {
                    _categoryFilter = category;
                  });
                  _applyFiltersAndSorting();
                },
                backgroundColor: const Color(0xFF2D2D2D),
                selectedColor: AppTheme.primaryColor.withOpacity(0.3),
                checkmarkColor: Colors.white,
                side: BorderSide(color: isSelected ? AppTheme.primaryColor : Colors.grey[600]!),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildSortDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Text('Sortieren nach: ', style: TextStyle(color: Colors.grey[300])),
          const SizedBox(width: 8),
          Container(
            height: 40, // Konsistente Höhe
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFF2D2D2D),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey[600]!),
            ),
            child: DropdownButton<String>(
              value: _sortBy,
              dropdownColor: const Color(0xFF2D2D2D),
              style: TextStyle(color: Colors.white),
              underline: Container(),
              items: const [
                DropdownMenuItem(value: 'startDate', child: Text('Startdatum')),
                DropdownMenuItem(value: 'name', child: Text('Name')),
                DropdownMenuItem(value: 'status', child: Text('Status')),
                DropdownMenuItem(value: 'playerCount', child: Text('Spieleranzahl')),
              ],
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _sortBy = value;
                  });
                  _applyFiltersAndSorting();
                }
              },
            ),
          ),
          const SizedBox(width: 8),
          Container(
            height: 40, // Konsistente Höhe
            decoration: BoxDecoration(
              color: const Color(0xFF2D2D2D),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey[600]!),
            ),
            child: IconButton(
              icon: Icon(_sortAscending ? Icons.arrow_upward : Icons.arrow_downward, color: Colors.grey[300]),
              onPressed: () {
                setState(() {
                  _sortAscending = !_sortAscending;
                });
                _applyFiltersAndSorting();
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWorldCard(World world) {
    final playerCount = _playerCounts[world.id] ?? 0;
    final progress = _getWorldProgress(world);
    final progressText = _getProgressText(world);
    
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 0),
      elevation: 8,
      color: const Color(0xFF1A1A1A), // Dunkle Karte
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: AppTheme.primaryColor.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              const Color(0xFF1A1A1A),
              const Color(0xFF2A2A2A),
            ],
          ),
        ),
        child: InkWell(
          onTap: () => _navigateToWorldJoin(world), // Deep-Link
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header mit Name, Status und Spieleranzahl
                Row(
                  children: [
                    // Welt-Icon
                    CircleAvatar(
                      backgroundColor: _getCategoryColor(_getWorldCategory(world)),
                      child: Icon(
                        world.isActive ? Icons.play_arrow : Icons.public,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 12),
                    
                    // Welt-Name und Status
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  world.name,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: _getCategoryColor(_getWorldCategory(world)).withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: _getCategoryColor(_getWorldCategory(world)).withOpacity(0.5)),
                                ),
                                child: Text(
                                  world.statusText,
                                  style: TextStyle(
                                    color: _getCategoryColor(_getWorldCategory(world)),
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          
                          // Spieleranzahl
                          Row(
                            children: [
                              Icon(
                                Icons.people,
                                size: 16,
                                color: Colors.grey[400],
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '$playerCount Spieler aktiv',
                                style: TextStyle(
                                  color: Colors.grey[400],
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 16),
                
                // Weltlaufzeit-Fortschrittsbalken
                if (world.endsAt != null) ...[
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Weltlaufzeit',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                          Text(
                            progressText,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[400],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      LinearProgressIndicator(
                        value: progress,
                        backgroundColor: Colors.grey.withOpacity(0.3),
                        valueColor: AlwaysStoppedAnimation<Color>(
                          _getCategoryColor(_getWorldCategory(world)),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                ],
                
                // Datum-Informationen
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.calendar_today,
                                size: 16,
                                color: Colors.grey[400],
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'Start: ${world.startsAt.day}.${world.startsAt.month}.${world.startsAt.year}',
                                style: TextStyle(
                                  color: Colors.grey[400],
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                          if (world.endsAt != null) ...[
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Icon(
                                  Icons.event_busy,
                                  size: 16,
                                  color: Colors.grey[400],
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  'Ende: ${world.endsAt?.day ?? '?'}.${world.endsAt?.month ?? '?'}.${world.endsAt?.year ?? '?'}',
                                  style: TextStyle(
                                    color: Colors.grey[400],
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),
                    
                    // Action Buttons
                    _buildActionButtons(world),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActionButtons(World world) {
    final buttons = <Widget>[];
    final isJoined = _joinedWorlds[world.id] ?? false;
    final isPreRegistered = _preRegisteredWorlds[world.id] ?? false;

    // Join button for open/running worlds (if not already joined)
    if (world.canJoin && !isJoined) {
      buttons.add(
        ElevatedButton(
          onPressed: () => _joinWorld(world),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.primaryColor,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: const Text('Beitreten'),
        ),
      );
    }

    // Show "Spielen" if already joined
    if (isJoined) {
      buttons.add(
        ElevatedButton(
          onPressed: () => context.goNamed('world-dashboard', pathParameters: {'id': world.id.toString()}),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green[600],
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: const Text('Spielen'),
        ),
      );
    }

    // Pre-register button for upcoming worlds (only if can't join and not already pre-registered)
    if (world.canPreRegister && !world.canJoin && !isPreRegistered) {
      buttons.add(
        ElevatedButton(
          onPressed: () => _preRegisterWorld(world),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.orange[600],
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: const Text('Vorregistrieren'),
        ),
      );
    }

    // Show "Bereits registriert" if pre-registered
    if (isPreRegistered) {
      buttons.add(
        ElevatedButton(
          onPressed: null, // Disabled
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.grey[600],
            foregroundColor: Colors.grey[300],
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: const Text('Bereits registriert'),
        ),
      );
    }

    // Invite button for open/upcoming/running worlds
    if (world.canInvite) {
      buttons.add(
        ElevatedButton(
          onPressed: () => _createInvite(world),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.purple[600],
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: const Icon(Icons.person_add, size: 16),
        ),
      );
    }

    // If no buttons, show status
    if (buttons.isEmpty) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: const Color(0xFF2D2D2D),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey[600]!),
        ),
        child: Text(
          world.statusText,
          style: TextStyle(
            color: Colors.grey[300],
            fontSize: 12,
          ),
        ),
      );
    }

    // Return buttons in a row for better layout
    return Wrap(
      spacing: 8, // Horizontal spacing between buttons
      runSpacing: 4, // Vertical spacing if buttons wrap
      children: buttons,
    );
  }

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
                                child: Icon(
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
                                _buildFilterChips(),
                                const SizedBox(height: 16),
                                _buildSortDropdown(),
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
                                    color: Colors.red[900]!.withOpacity(0.3),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: Colors.red[400]!.withOpacity(0.5),
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
                                          color: Colors.red[200]!.withOpacity(0.8),
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
                                  children: _filteredWorlds.map((world) => _buildWorldCard(world)).toList(),
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
            
            // Logout button in top-right corner
            Positioned(
              top: 24,
              right: 24,
              child: ElevatedButton.icon(
                onPressed: _logout,
                icon: const Icon(Icons.logout),
                label: const Text('Abmelden'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red[600],
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
} 