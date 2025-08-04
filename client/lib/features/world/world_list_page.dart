import 'package:flutter/material.dart';
import '../../config/logger.dart';
import '../../core/services/auth_service.dart';
import '../../core/services/world_service.dart';
import '../../core/models/world.dart';
import '../../core/theme/index.dart';
import '../../theme/background_widget.dart';
import '../../routing/app_router.dart';
import '../../shared/widgets/navigation_widget.dart';
import '../../shared/navigation/smart_navigation.dart';
import './widgets/world_card.dart';
import './widgets/world_filters.dart';
import '../../l10n/app_localizations.dart';
import '../../shared/dialogs/fullscreen_dialog.dart';
import '../../shared/dialogs/invite_fullscreen_dialog.dart';

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
      
    } catch (e) {
      AppLogger.app.w('⚠️ ServiceLocator Fehler - nutze direkte Instanziierung', error: e);
      _authService = AuthService();
      _worldService = WorldService();

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
              content: Text(AppLocalizations.of(context).worldListLoadingError(e.toString())),
              backgroundColor: Theme.of(context).colorScheme.error,
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
              await context.smartGoNamed('login');
            }
          }
        }
      }
    }
  }

  void _generateMockPlayerCounts() {
    for (final world in _worlds) {
      // Generate realistic player counts based on world status
      switch (world.status) {
        case WorldStatus.upcoming:
          // Mock player count generation: 5-20 players
          break;
        case WorldStatus.open:
          // Mock player count generation: 20-50 players
          break;
        case WorldStatus.running:
          // Mock player count generation: 50-150 players
          break;
        case WorldStatus.closed:
        case WorldStatus.archived:
          // Mock player count generation: 0-10 players
          break;
      }
    }
  }

  void _applyFiltersAndSorting() {
    List<World> filtered = List.from(_worlds);
    
    // Apply status filter
    if (_statusFilter != null) {
      filtered = filtered.where((world) => world.status == _statusFilter).toList();
    }
    
    // Apply category filter
    if (_categoryFilter != null) {
      filtered = filtered.where((world) => world.category == _categoryFilter).toList();
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
          comparison = a.playerCount.compareTo(b.playerCount);
          break;
      }
      return _sortAscending ? comparison : -comparison;
    });
    
    setState(() {
      _filteredWorlds = filtered;
    });
  }

  // Removed unused _getWorldCategory method

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

  Future<void> _inviteToWorld(World world, ThemeData worldTheme) async {
    // Invite-Funktion aufgerufen (relevante Aktion)
    
    try {
      await InviteFullscreenDialog.show(
        context: context, // Normaler Context für Navigation
        worldId: world.id.toString(),
        worldName: world.name,
        themeOverride: worldTheme, // 🌍 DIRECT: World-Theme direkt übergeben!
        onInviteSent: () {
          // Optional: Refresh oder andere Aktion nach erfolgreichem Invite
          AppLogger.app.i('✅ Invite sent for world: ${world.name}');
        },
      );
    } catch (e) {
      AppLogger.error.e('❌ Invite dialog error: $e');
      AppLogger.logError('Fehler beim Öffnen des Invite-Dialogs', e, context: {'worldId': world.id});
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context).errorInviteDialogOpen(e.toString())),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
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
            content: Text(AppLocalizations.of(context).worldJoinSuccess(world.name)),
            backgroundColor: Theme.of(context).colorScheme.primary,
          ),
        );
        // Navigate to world dashboard
        await context.smartGoNamed('world-dashboard', pathParameters: {'id': world.id.toString()});
      }
    } catch (e) {
      if (mounted) {
        // Prüfe ob es ein Token-Problem ist
        if (e.toString().contains('401') || e.toString().contains('Token fehlt')) {
          await _authService.logout();
          // Cache invalidieren nach Logout
          AppRouter.invalidateAuthCache();
          if (mounted) {
            await context.smartGoNamed('login');
          }
        } else {
          final errorMessage = e.toString().replaceAll('Exception: ', '');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(errorMessage),
              backgroundColor: Theme.of(context).colorScheme.error,
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
            content: Text(AppLocalizations.of(context).worldPreRegisterSuccessful(world.name)),
            backgroundColor: Theme.of(context).colorScheme.primary,
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
            await context.smartGoNamed('login');
          }
        } else {
          final errorMessage = e.toString().replaceAll('Exception: ', '');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(errorMessage),
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
          );
        }
      }
    }
  }

  Future<void> _leaveWorld(World world, ThemeData worldTheme) async {
    // Theme-aware Fullscreen Bestätigungsdialog anzeigen
    final confirmed = await FullscreenDialog.showConfirmation(
      context,
      title: AppLocalizations.of(context).worldLeaveDialogTitle,
      message: AppLocalizations.of(context).worldLeaveDialogMessage(world.name),
      confirmText: AppLocalizations.of(context).worldLeaveConfirm,
      cancelText: AppLocalizations.of(context).buttonCancel,
      confirmColor: Colors.red,
      icon: Icons.exit_to_app,
      themeOverride: worldTheme, // 🌍 DIRECT: World-Theme direkt übergeben!
    );

    if (confirmed != true) return;

    try {
      final success = await _worldService.leaveWorld(world.id);
      if (success && mounted) {
        setState(() {
          _joinedWorlds[world.id] = false;
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context).worldLeaveSuccessful(world.name)),
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
            await context.smartGoNamed('login');
          }
        } else {
          final errorMessage = e.toString().replaceAll('Exception: ', '');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(errorMessage),
              backgroundColor: Theme.of(context).colorScheme.error,
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
            content: Text(AppLocalizations.of(context).worldPreRegisterCancelled(world.name)),
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
            await context.smartGoNamed('login');
          }
        } else {
          final errorMessage = e.toString().replaceAll('Exception: ', '');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(errorMessage),
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
          );
        }
      }
    }
  }

  // Deep-Link zur World-Join-Page
  Future<void> _navigateToWorldJoin(World world) async {
    await context.smartGoNamed('world-join', pathParameters: {'id': world.id.toString()});
  }

  Future<void> _playWorld(World world) async {
    // Navigate directly to world dashboard for playing
    await context.smartGoNamed('world-dashboard', pathParameters: {'id': world.id.toString()});
  }

// Filter and sort methods removed - now using WorldFilters widget

  @override
  Widget build(BuildContext context) {
    // 🎯 ORIGINAL BEHAVIOR: Page uses default theme, only World Cards use their specific themes
    return _buildWorldListPage(context, Theme.of(context), null);
  }

  Widget _buildWorldListPage(BuildContext context, ThemeData theme, Map<String, dynamic>? extensions) {
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
                      color: theme.colorScheme.surface, // Theme-basierte Kartenfarbe
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                        side: BorderSide(
                          color: theme.colorScheme.primary.withValues(alpha: 0.3),
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
                              Color(0xFF1A1A1A), // Themed via ThemeData colorScheme
                              Color(0xFF2A2A2A), // Themed via ThemeData colorScheme
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
                                  color: theme.colorScheme.primary.withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: theme.colorScheme.primary.withValues(alpha: 0.5),
                                    width: 2,
                                  ),
                                ),
                                child: Icon(
                                  Icons.public,
                                  size: 40,
                                  color: theme.colorScheme.primary,
                                ),
                              ),
                              const SizedBox(height: 24),
                              
                              // Title
                              Text(
                                AppLocalizations.of(context).appTitle,
                                style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                                  color: theme.colorScheme.onSurface,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),
                              
                              // Subtitle
                              Text(
                                AppLocalizations.of(context).worldListSubtitle,
                                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                  color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
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
                                Center(
                                  child: CircularProgressIndicator(
                                    valueColor: AlwaysStoppedAnimation<Color>(theme.colorScheme.primary),
                                  ),
                                )
                              else if (_error != null)
                                Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: theme.colorScheme.error.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: theme.colorScheme.error.withValues(alpha: 0.5),
                                    ),
                                  ),
                                  child: Column(
                                    children: [
                                      Icon(
                                        Icons.error,
                                        size: 48,
                                        color: theme.colorScheme.error,
                                      ),
                                      const SizedBox(height: 16),
                                      Text(
                                        AppLocalizations.of(context).worldListErrorTitle,
                                        style: TextStyle(
                                          color: theme.colorScheme.error,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        _error ?? AppLocalizations.of(context).worldListErrorUnknown,
                                        style: TextStyle(
                                          color: theme.colorScheme.error.withValues(alpha: 0.8),
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
                                      color: theme.colorScheme.primary.withValues(alpha: 0.3),
                                    ),
                                  ),
                                  child: Column(
                                    children: [
                                      Icon(
                                        Icons.filter_list,
                                        size: 48,
                                        color: theme.colorScheme.primary.withValues(alpha: 0.7),
                                      ),
                                      const SizedBox(height: 16),
                                      Text(
                                        AppLocalizations.of(context).worldListEmptyTitle,
                                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                          color: Colors.grey[300],
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        AppLocalizations.of(context).worldListEmptyMessage,
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
                                  children: _filteredWorlds.map((world) => 
                                    // 🌍 WORLD-SPECIFIC THEME: Jede World Card in ihrem eigenen Theme mit bestehender Architektur!
                                    ThemeContextConsumer(
                                      componentName: 'WorldCard_${world.id}',
                                      worldThemeOverride: world.themeBundle ?? 'world-preview', // async loading in ThemeContextConsumer
                                      fallbackBundle: 'world-preview',
                                      // ✅ CLEAN: Automatische world-preview Logik für World Cards
                                      builder: (cardContext, worldTheme, worldExtensions) {
                                        return Theme(
                                          data: worldTheme,
                                          child: WorldCard(
                                            world: world,
                                            isPreRegistered: _preRegisteredWorlds[world.id] ?? false,
                                            isJoined: _joinedWorlds[world.id] ?? false,
                                            onJoin: world.canJoin && !(_joinedWorlds[world.id] ?? false) 
                                              ? () => _joinWorld(world) 
                                              : null,
                                            onLeave: (_joinedWorlds[world.id] ?? false)
                                              ? () => _leaveWorld(world, worldTheme) // 🎨 DIRECT: World-Theme direkt übergeben!
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
                                          onInvite: ((_joinedWorlds[world.id] ?? false) || (_preRegisteredWorlds[world.id] ?? false)) &&
                                                   (world.status != WorldStatus.closed && world.status != WorldStatus.archived)
                                              ? () => _inviteToWorld(world, worldTheme) // 🎨 DIRECT: World-Theme direkt übergeben!
                                              : null,
                                          onTap: () => _navigateToWorldJoin(world),
                                        ),
                                      );
                                      },
                                    )
                                  ).toList(),
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
                                      label: Text(AppLocalizations.of(context).worldListRefreshButton),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: theme.colorScheme.primary,
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
            // 🧭 INTEGRATED NAVIGATION: Uses preloaded theme from Smart Navigation
            const NavigationWidget(currentContext: NavigationContext.worldList),        
          ],
        ),
      ),
    );
  }
} 