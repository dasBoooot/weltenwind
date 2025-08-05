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
import '../../shared/components/app_snackbar.dart';
import '../../shared/components/app_scaffold.dart';

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

  /// 🎯 Get correct theme for a world (prioritizes themeVariant over themeBundle)
  String _getWorldTheme(World world) {
    // 🔍 DEBUG: World theme data ausgeben
    AppLogger.app.d('🔍 [WORLD-LIST-DEBUG] Processing world ${world.id} "${world.name}":', error: {
      'themeVariant': world.themeVariant,
      'themeBundle': world.themeBundle,
      'parentTheme': world.parentTheme,
    });
    
    // 1. Prioritize themeVariant (new API field)
    if (world.themeVariant != null && world.themeVariant!.isNotEmpty && world.themeVariant != 'standard') {
      AppLogger.app.d('✅ [WORLD-LIST-THEME] Using world.themeVariant: ${world.themeVariant} for world ${world.id}');
      return world.themeVariant!;
    }
    
    // 2. ✅ DYNAMIC: themeBundle IS the theme name (no hardcoded mapping needed!)
    final themeBundle = world.themeBundle ?? 'default';
    AppLogger.app.d('🎯 [WORLD-LIST-THEME] Using themeBundle directly: $themeBundle for world ${world.id}');
    return themeBundle;
  }

  // ✅ REMOVED: _getBundleFallbackTheme - no hardcoded mappings needed!

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
          
          SnackbarHelpers.showError(
            context,
            AppLocalizations.of(context).worldListLoadingError(e.toString()),
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
        SnackbarHelpers.showError(
          context,
          AppLocalizations.of(context).errorInviteDialogOpen(e.toString()),
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
        
        SnackbarHelpers.showSuccess(
          context,
          AppLocalizations.of(context).worldJoinSuccess(world.name),
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
          SnackbarHelpers.showError(
            context,
            errorMessage,
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
        
        SnackbarHelpers.showSuccess(
          context,
          AppLocalizations.of(context).worldPreRegisterSuccessful(world.name),
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
          SnackbarHelpers.showError(
            context,
            errorMessage,
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
        
        SnackbarHelpers.showInfo(
          context,
          AppLocalizations.of(context).worldLeaveSuccessful(world.name),
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
          SnackbarHelpers.showError(
            context,
            errorMessage,
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
        
        SnackbarHelpers.showInfo(
          context,
          AppLocalizations.of(context).worldPreRegisterCancelled(world.name),
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
          SnackbarHelpers.showError(
            context,
            errorMessage,
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

  /// 🍔 Build themed hamburger drawer for filters
  Widget _buildDrawer() {
    return Builder(
      builder: (context) {
        final theme = Theme.of(context);
        
        return Drawer(
          backgroundColor: theme.colorScheme.surface,
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              DrawerHeader(
                decoration: BoxDecoration(color: theme.colorScheme.primary),
                child: Text(
                  'Filter & Settings', 
                  style: TextStyle(
                    color: theme.colorScheme.onPrimary, 
                    fontSize: 24
                  )
                ),
              ),
              ListTile(
                leading: const Icon(Icons.filter_list), 
                title: const Text('Status Filter'), 
                onTap: () => Navigator.pop(context)
              ),
              ListTile(
                leading: const Icon(Icons.category), 
                title: const Text('Category Filter'), 
                onTap: () => Navigator.pop(context)
              ),
              ListTile(
                leading: const Icon(Icons.sort), 
                title: const Text('Sortierung'), 
                onTap: () => Navigator.pop(context)
              ),
            ],
          ),
        );
      },
    );
  }

  /// 🌍 Build main world list body with mixed themes
  Widget _buildWorldListBody() {
    return BackgroundWidget( // 🖼️ World-specific background images
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 800),
            child: _buildWorldListCard(),
          ),
        ),
      ),
    );
  }

  /// 🎴 Build the main world list card
  Widget _buildWorldListCard() {
    return Builder(
      builder: (context) {
        final theme = Theme.of(context);
        final l10n = AppLocalizations.of(context);
        
        return Card(
          elevation: 12,
          color: theme.colorScheme.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: BorderSide(
              color: theme.colorScheme.primary.withValues(alpha: 0.3),
              width: 1,
            ),
          ),
          child: Container(
            padding: const EdgeInsets.all(32.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l10n.worldListTitle,
                            style: theme.textTheme.headlineMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: theme.colorScheme.onSurface,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            l10n.worldListSubtitle,
                            style: theme.textTheme.bodyLarge?.copyWith(
                              color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 32),
                
                // Filters
                WorldFilters(
                  statusFilter: _statusFilter,
                  categoryFilter: _categoryFilter,
                  sortBy: _sortBy,
                  sortAscending: _sortAscending,
                  onStatusChanged: (status) => setState(() {
                    _statusFilter = status;
                    _applyFiltersAndSorting();
                  }),
                  onCategoryChanged: (category) => setState(() {
                    _categoryFilter = category;
                    _applyFiltersAndSorting();
                  }),
                  onSortByChanged: (sortBy) => setState(() {
                    _sortBy = sortBy;
                    _applyFiltersAndSorting();
                  }),
                  onSortOrderChanged: () => setState(() {
                    _sortAscending = !_sortAscending;
                    _applyFiltersAndSorting();
                  }),
                  onResetFilters: () => setState(() {
                    _statusFilter = null;
                    _categoryFilter = null;
                    _sortBy = 'startDate';
                    _sortAscending = true;
                    _applyFiltersAndSorting();
                  }),
                ),
                
                const SizedBox(height: 32),
                
                // Content
                if (_isLoading)
                  _buildLoadingState(theme)
                else if (_error != null)
                  _buildErrorState(theme, l10n)
                else
                  _buildWorldsList(),
                
                const SizedBox(height: 24),
                
                // Action buttons
                _buildActionButtons(theme, l10n),
              ],
            ),
          ),
        );
      },
    );
  }

  /// 🔄 Build loading state
  Widget _buildLoadingState(ThemeData theme) {
    return Center(
      child: Column(
        children: [
          CircularProgressIndicator(color: theme.colorScheme.primary),
          const SizedBox(height: 16),
          Text(
            'Loading worlds...',
            style: theme.textTheme.bodyLarge,
          ),
        ],
      ),
    );
  }

  /// ❌ Build error state
  Widget _buildErrorState(ThemeData theme, AppLocalizations l10n) {
    return Center(
      child: Column(
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: theme.colorScheme.error,
          ),
          const SizedBox(height: 16),
          Text(
            'Error: $_error',
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.error,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  /// 🌍 Build worlds list with mixed themes (THE CORE!)
  Widget _buildWorldsList() {
    if (_filteredWorlds.isEmpty) {
      return Builder(
        builder: (context) {
          final theme = Theme.of(context);
          return Center(
            child: Column(
              children: [
                Icon(
                  Icons.public_off,
                  size: 64,
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                ),
                const SizedBox(height: 16),
                Text(
                  'No worlds available',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                  ),
                ),
              ],
            ),
          );
        },
      );
    }

    // 🎭 MIXED-THEME MAGIC: Each WorldCard gets its own theme!
    return Column(
      children: _filteredWorlds.map((world) {
        final worldTheme = _getWorldTheme(world); // ✅ NEW: Use themeVariant logic!
        
        return Padding(
          padding: const EdgeInsets.only(bottom: 16.0),
          child: ThemeContextConsumer(
            componentName: 'WorldCard_${world.id}',
            worldThemeOverride: worldTheme, // 🎯 Dynamic theme resolution!
            fallbackBundle: 'full-gaming', // ✅ Use existing bundle
            builder: (cardContext, resolvedTheme, worldExtensions) {
              return Theme(
                data: resolvedTheme,
                child: WorldCard(
                  world: world,
                  isPreRegistered: _preRegisteredWorlds[world.id] ?? false,
                  isJoined: _joinedWorlds[world.id] ?? false,
                  onJoin: world.canJoin && !(_joinedWorlds[world.id] ?? false) 
                    ? () => _joinWorld(world) 
                    : null,
                  onLeave: (_joinedWorlds[world.id] ?? false)
                    ? () => _leaveWorld(world, resolvedTheme) 
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
                    ? () => _inviteToWorld(world, resolvedTheme) 
                    : null,
                  onTap: () => _navigateToWorldJoin(world),
                ),
              );
            },
          ),
        );
      }).toList(),
    );
  }

  /// 🔧 Build action buttons
  Widget _buildActionButtons(ThemeData theme, AppLocalizations l10n) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        SizedBox(
          height: 48,
          child: ElevatedButton.icon(
            onPressed: _loadWorlds,
            icon: const Icon(Icons.refresh),
            label: Text(l10n.worldListRefreshButton),
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.colorScheme.primary,
              foregroundColor: theme.colorScheme.onPrimary,
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
    );
  }

// Filter and sort methods removed - now using WorldFilters widget

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    
    return AppScaffold(
      themeContextId: 'world-list',
      themeBundleId: 'full-gaming', // ✅ Use existing bundle for consistency
      componentName: 'WorldListPage',
      showBackgroundGradient: false, // Use BackgroundWidget instead
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(l10n.appTitle),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 8.0),
            child: const NavigationWidget(
              currentContext: NavigationContext.worldList,
            ),
          ),
        ],
      ),
      drawer: _buildDrawer(),
      body: _buildWorldListBody(),
    );
  }
}