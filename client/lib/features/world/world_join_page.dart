import 'package:flutter/material.dart';
import '../../config/logger.dart';
import '../../core/models/world.dart';
import '../../core/services/world_service.dart';
import '../../core/services/auth_service.dart';
import '../../core/theme/index.dart'; // Theme System für ThemePageProvider und ThemeContextConsumer
import '../../theme/background_widget.dart';
import '../../shared/widgets/navigation_widget.dart';
import '../../shared/navigation/smart_navigation.dart';
// import '../invite/widgets/invite_widget.dart'; // Replaced by fullscreen dialog system
import '../../l10n/app_localizations.dart';
import '../../shared/dialogs/fullscreen_dialog.dart';
import '../../shared/dialogs/invite_fullscreen_dialog.dart';

// ServiceLocator Import für DI
import '../../main.dart';

// Normale World-Join Page - nur für interne Navigation

class WorldJoinPage extends StatefulWidget {
  final String worldId;
  
  const WorldJoinPage({
    super.key, 
    required this.worldId,
  });

  @override
  State<WorldJoinPage> createState() => _WorldJoinPageState();
}

class _WorldJoinPageState extends State<WorldJoinPage> {
  // DI-ready: ServiceLocator verwenden
  late final WorldService _worldService;
  late final AuthService _authService;
  
  // Tab Controller
  
  bool _isLoading = false;
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

    _initializeServices();
    _loadWorldData();
  }
  
  @override
  void dispose() {
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Authentication-Status bei Kontext-Änderungen prüfen
    _checkAuthenticationStatus();
  }

  /// 🎯 Theme Early Detection: Bestimme Theme schon vor API-Load
  String _getWorldTheme() {
    // 1. Wenn World bereits geladen → verwende themeBundle aber korrigiere Bundle-zu-Theme
    if (_world != null) {
      final worldBundle = _world!.themeBundle ?? 'world-preview';
      print('🔍 [THEME-DEBUG] World loaded: themeBundle = $worldBundle');
      
      // 🛡️ BUNDLE-zu-THEME Korrektur (falls DB Bundle-Namen statt Theme-Namen hat)
      final correctedTheme = _correctBundleToTheme(worldBundle);
      print('🔄 [THEME-DEBUG] Bundle corrected: $worldBundle → $correctedTheme');
      return correctedTheme;
    }
    
    // 2. Early Detection basierend auf World-ID (Demo Worlds haben bekannte IDs)
    final worldId = int.tryParse(widget.worldId) ?? 0;
    final earlyTheme = switch (worldId) {
      6 => 'tolkien',     // Mittelerde
      7 => 'space',       // Galactic Empire
      8 => 'roman',       // Römisches Reich
      9 => 'nature',      // Waldreich
      10 => 'cyberpunk',  // Neo Tokyo
      _ => 'world-preview', // Fallback
    };
    print('🎯 [THEME-DEBUG] Early detection for ID $worldId: $earlyTheme');
    return earlyTheme;
  }

    /// 🎨 Build Navigation with correct theme context
  Widget _buildNavigationWithTheme(ThemeData theme) {
    return Theme(
      data: theme,
      child: NavigationWidget(
        currentContext: NavigationContext.worldJoin,
        routeParams: {'id': widget.worldId.toString()},
      ),
    );
  }

  /// 🛡️ Helper: Bundle-Name zu Theme-Name Korrektur
  String _correctBundleToTheme(String bundleOrTheme) {
    // Falls die DB Bundle-Namen statt Theme-Namen gespeichert hat
    switch (bundleOrTheme) {
      case 'full-gaming': 
        // ✅ KORREKT: full-gaming Bundle kann verschiedene Themes haben
        // Hier sollten wir die World-ID berücksichtigen, nicht pauschal tolkien
        final worldId = int.tryParse(widget.worldId) ?? 0;
        switch (worldId) {
          case 6: return 'tolkien';    // Mittelerde
          case 7: return 'space';      // Galactic Empire  
          case 8: return 'roman';      // Römisches Reich
          case 9: return 'nature';     // Waldreich
          case 10: return 'cyberpunk'; // Neo Tokyo
          default: return 'default';   // Fallback für unbekannte Welten
        }
      case 'world-preview': return 'default'; // ✅ KORREKTUR: Neutrales Preview-Theme
      case 'pre-game-minimal': return 'default';
      default: return bundleOrTheme; // Assume it's already a theme name
    }
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
    // Robustere Loading-State Verwaltung
    if (_isLoading) {
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // World laden
      _world = await _worldService.getWorld(int.parse(widget.worldId));
      
      // Status prüfen
      await _checkWorldStatus();
      
      // Fertig!
      setState(() {
        _isLoading = false;
      });
      
    } catch (e) {
      AppLogger.app.w('💥 FEHLER in _loadWorldData: $e');
      setState(() {
        _errorMessage = AppLocalizations.of(context).worldJoinErrorLoadingWorldData(e.toString());
        _isLoading = false;
      });
    }
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



  Future<void> _inviteToWorld(ThemeData worldTheme) async {
    if (_world == null) return;
    
    try {
      await InviteFullscreenDialog.show(
        context: context, // Normaler Context für Navigation
        worldId: _world!.id.toString(),
        worldName: _world!.name,
        themeOverride: worldTheme, // 🌍 DIRECT: World-Theme direkt übergeben!
        onInviteSent: () {
          // Optional: Refresh oder andere Aktion nach erfolgreichem Invite
          AppLogger.app.i('✅ Invite sent for world: ${_world!.name}');
        },
      );
    } catch (e) {
      AppLogger.logError('Fehler beim Öffnen des Invite-Dialogs', e, context: {'worldId': _world!.id});
      
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

  Future<void> _joinWorld() async {
    if (_world == null) return;

    setState(() {
      _isJoining = true;
      _joinError = null;
    });

    try {
      // World-Join wird versucht
      final success = await _worldService.joinWorld(_world!.id);
      
      if (success) {
        setState(() {
          _isJoined = true;
        });
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(AppLocalizations.of(context).worldJoinSuccess(_world!.name)),
              backgroundColor: Theme.of(context).colorScheme.primary,
              duration: const Duration(seconds: 3),
            ),
          );
        }
      } else {
        setState(() {
          _joinError = AppLocalizations.of(context).worldJoinFailed;
        });
      }
    } catch (e) {
      AppLogger.logError('World Join fehlgeschlagen', e, context: {
        'worldId': _world?.id,
        'worldName': _world?.name,
      });
      
      setState(() {
        _joinError = AppLocalizations.of(context).worldJoinGenericError(e.toString().replaceAll('Exception: ', ''));
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
              content: Text(AppLocalizations.of(context).worldPreRegisterSuccessful(world.name)),
              backgroundColor: Theme.of(context).colorScheme.primary,
            ),
          );
        }
      } else {
        setState(() {
          _joinError = AppLocalizations.of(context).worldJoinPreRegistrationError;
        });
      }
    } catch (e) {
      setState(() {
        _joinError = AppLocalizations.of(context).worldJoinGenericError(e.toString().replaceAll('Exception: ', ''));
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
              content: Text(AppLocalizations.of(context).worldPreRegisterCancelled(world.name)),
              backgroundColor: Theme.of(context).colorScheme.tertiary,
            ),
          );
        }
      } else {
        setState(() {
          _joinError = AppLocalizations.of(context).worldJoinCancelPreRegistrationError;
        });
      }
    } catch (e) {
      setState(() {
        _joinError = AppLocalizations.of(context).worldJoinGenericError(e.toString().replaceAll('Exception: ', ''));
      });
    } finally {
      if (mounted) {
        setState(() {
          _isPreRegistering = false;
        });
      }
    }
  }
  
  Future<void> _leaveWorld(ThemeData worldTheme) async {
    final world = _world;
    if (world == null) return;
    
    // Theme-aware Fullscreen Bestätigungsdialog anzeigen
    final confirmed = await FullscreenDialog.showConfirmation(
      context,
      title: AppLocalizations.of(context).worldJoinLeaveDialogTitle,
      message: AppLocalizations.of(context).worldJoinLeaveDialogContent(world.name),
      confirmText: AppLocalizations.of(context).worldLeaveButton,
      cancelText: AppLocalizations.of(context).buttonCancel,
      confirmColor: Colors.red,
      icon: Icons.exit_to_app,
      themeOverride: worldTheme, // 🌍 DIRECT: World-Theme direkt übergeben!
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
            content: Text(AppLocalizations.of(context).worldLeaveSuccessful(world.name)),
            backgroundColor: Theme.of(context).colorScheme.tertiary,
          ),
        );
      }
    } catch (e) {
      setState(() {
        _joinError = AppLocalizations.of(context).worldJoinGenericError(e.toString().replaceAll('Exception: ', ''));
      });
    } finally {
      if (mounted) {
        setState(() {
          _isJoining = false;
        });
      }
    }
  }
  
  Future<void> _playWorld() async {
    final world = _world;
    if (world == null) return;
    // Navigate directly to world dashboard for playing
    await context.smartGoNamed('world-dashboard', pathParameters: {'id': world.id.toString()});
  }

  // Welt-Status bestimmen
  String _getWorldStatusText() {
    final world = _world;
    if (world == null) return AppLocalizations.of(context).worldJoinUnknownWorld;
    return world.status.getDisplayName(context);
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
    // 🌍 WORLD-SPECIFIC THEME: Korrekte Integration mit preloaded world theme
    final worldTheme = _getWorldTheme();
    
    return ThemePageProvider(
      contextId: 'world-join',
      bundleId: 'world-preview',
      worldTheme: worldTheme,
      child: ThemeContextConsumer(
        componentName: 'WorldJoinPage',
        worldThemeOverride: worldTheme,
        fallbackBundle: 'world-preview',
        builder: (context, theme, extensions) {
          return _buildWorldJoinPage(context, theme, extensions);
        },
      ),
    );
  }

  Widget _buildWorldJoinPage(BuildContext context, ThemeData theme, Map<String, dynamic>? extensions) {
    final worldTheme = _getWorldTheme();
    
    return Scaffold(
      body: BackgroundWidget(
        worldTheme: worldTheme,  // 🌍 World-specific background
        child: Stack(
          children: [
            // Main content
            SafeArea(
              child: _isLoading
                  ? Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(theme.colorScheme.primary),
                      ),
                    )
                  : _errorMessage != null
                      ? _buildErrorState(theme)
                      : _world == null
                          ? _buildNotFoundState(theme)
                          : _buildWorldContent(theme),
            ),
            
            // 🧭 INTEGRATED NAVIGATION: Now gets correct themes from context (only show when authenticated)
            if (_isAuthenticated)
              _buildNavigationWithTheme(theme),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(ThemeData theme) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 500),
            child: Card(
              elevation: 12,
              color: theme.colorScheme.surface, // Dunkle Karte
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
                        AppLocalizations.of(context).worldLoadingError,
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          color: theme.colorScheme.onSurface,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        _errorMessage ?? AppLocalizations.of(context).worldJoinUnknownError,
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 32),
                      
                      // Standard Retry Button
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: ElevatedButton.icon(
                          onPressed: _retry,
                          icon: const Icon(Icons.refresh),
                          label: Text(AppLocalizations.of(context).buttonRetry),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: theme.colorScheme.primary,
                            foregroundColor: theme.colorScheme.onPrimary,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextButton(
                        onPressed: () => context.smartGoNamed('world-list'),
                        child: Text(
                          AppLocalizations.of(context).worldJoinBackToWorldsButton,
                          style: TextStyle(
                            color: theme.colorScheme.primary,
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



  Widget _buildNotFoundState(ThemeData theme) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 500),
            child: Card(
              elevation: 12,
              color: theme.colorScheme.surface, // Dunkle Karte
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
                        AppLocalizations.of(context).worldNotFoundTitle,
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          color: theme.colorScheme.onSurface,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        AppLocalizations.of(context).worldNotFoundMessage,
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 32),
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: ElevatedButton(
                          onPressed: () => context.smartGoNamed('world-list'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: theme.colorScheme.primary,
                            foregroundColor: theme.colorScheme.onPrimary,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Text(AppLocalizations.of(context).worldBackToWorlds),
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

  Widget _buildWorldContent(ThemeData theme) {
    return Center(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 900),
        margin: const EdgeInsets.all(24),
        child: Card(
          elevation: 16,
          color: theme.colorScheme.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
            side: BorderSide(
              color: theme.colorScheme.primary.withValues(alpha: 0.3),
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
                      theme.colorScheme.primary.withValues(alpha: 0.1),
                      theme.colorScheme.primary.withValues(alpha: 0.05),
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
                                _world?.name ?? AppLocalizations.of(context).worldJoinUnknownWorldName,
                                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                  color: theme.colorScheme.onSurface,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  Icon(Icons.calendar_today, size: 16, color: Colors.grey[400]),
                                  const SizedBox(width: 4),
                                  Text(
                                    AppLocalizations.of(context).worldStartDate(_world?.startsAt.toString().split(' ')[0] ?? AppLocalizations.of(context).worldDateUnknown),
                                    style: TextStyle(color: Colors.grey[400], fontSize: 14),
                                  ),
                                  if (_world?.endsAt != null) ...[
                                    const SizedBox(width: 16),
                                    Icon(Icons.event, size: 16, color: Colors.grey[400]),
                                    const SizedBox(width: 4),
                                    Text(
                                      AppLocalizations.of(context).worldEndDate(_world?.endsAt.toString().split(' ')[0] ?? AppLocalizations.of(context).worldDateUnknown),
                                      style: TextStyle(color: Colors.grey[400], fontSize: 14),
                                    ),
                                  ],
                                ],
                              ),
                            ],
                          ),
                        ),
                        // Status Badge
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: _getWorldStatusColor().withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: _getWorldStatusColor().withValues(alpha: 0.5)),
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
                        const SizedBox(width: 8),
                        // Category Badge
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: _world!.category.color.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: _world!.category.color.withValues(alpha: 0.5)),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                _world!.category.icon,
                                color: _world!.category.color,
                                size: 16,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                _world!.category.getDisplayName(context),
                                style: TextStyle(
                                  color: _world!.category.color,
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
                    _buildActionButtons(theme),
                    
                    // Join-Fehler anzeigen
                    if (_joinError != null) ...[
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.red.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.red.withValues(alpha: 0.3)),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.error_outline, color: Colors.red[400], size: 20),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                _joinError ?? AppLocalizations.of(context).worldJoinUnknownError,
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

  Widget _buildActionButtons(ThemeData theme) {
    if (_world == null) return const SizedBox.shrink();
    
    List<Widget> buttons = [];
    final world = _world!;
    
    // STATUS-BASIERTE INTELLIGENTE BUTTON-LOGIK
    switch (world.status) {
      case WorldStatus.upcoming:
        // Vorregistrierung oder Zurückziehen
        if (_isPreRegistered) {
          buttons.add(
            ElevatedButton.icon(
                onPressed: (_isPreRegistering || _isJoining) ? null : _cancelPreRegistration,
                icon: const Icon(Icons.cancel),
                label: Text(_isPreRegistering ? AppLocalizations.of(context).worldJoinCancelPreRegistrationInProgress : AppLocalizations.of(context).worldJoinCancelPreRegistrationButton),
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.colorScheme.error,  // World-theme based cancel color
                  foregroundColor: theme.colorScheme.onPrimary,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
          );
          
          // Invite Button als LETZTER Button für pre-registered upcoming worlds
          buttons.add(
            ElevatedButton.icon(
                onPressed: () => _inviteToWorld(theme), // 🎨 DIRECT: World-Theme direkt übergeben!
                icon: const Icon(Icons.person_add),
                label: Text(AppLocalizations.of(context).worldInviteButton),
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.colorScheme.tertiary,  // World-theme based invite color
                  foregroundColor: theme.colorScheme.onPrimary,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
          );
        } else {
          buttons.add(
            ElevatedButton.icon(
                onPressed: (_isPreRegistering || _isJoining) ? null : _preRegisterWorld,
                icon: const Icon(Icons.how_to_reg),
                label: Text(_isPreRegistering ? AppLocalizations.of(context).worldJoinPreRegisterInProgress : AppLocalizations.of(context).worldJoinPreRegisterButton),
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.colorScheme.secondary,  // World-theme based preregister color
                  foregroundColor: theme.colorScheme.onPrimary,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
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
              ElevatedButton.icon(
                onPressed: _playWorld,
                icon: const Icon(Icons.play_circle_filled),
                label: Text(AppLocalizations.of(context).worldPlayButton),
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.colorScheme.secondary,  // World-theme based play color
                  foregroundColor: theme.colorScheme.onPrimary,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
          );

          // Verlassen Button
          buttons.add(
            ElevatedButton.icon(
                onPressed: _isJoining ? null : () => _leaveWorld(theme), // 🎨 DIRECT: World-Theme direkt übergeben!
                icon: const Icon(Icons.exit_to_app),
                label: Text(_isJoining ? AppLocalizations.of(context).worldJoinLeaveInProgress : AppLocalizations.of(context).worldLeaveButton),
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.colorScheme.error,  // World-theme based leave color
                  foregroundColor: theme.colorScheme.onPrimary,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
          );
          
          // Invite Button als LETZTER Button
          buttons.add(
            ElevatedButton.icon(
                onPressed: () => _inviteToWorld(theme), // 🎨 DIRECT: World-Theme direkt übergeben!
                icon: const Icon(Icons.person_add),
                label: Text(AppLocalizations.of(context).worldInviteButton),
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.colorScheme.tertiary,  // World-theme based invite color
                  foregroundColor: theme.colorScheme.onPrimary,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
          );
        } else {
          // Beitreten Button
          buttons.add(
            ElevatedButton.icon(
                onPressed: _isJoining ? null : _joinWorld,
                icon: const Icon(Icons.play_arrow),
                label: Text(_isJoining ? AppLocalizations.of(context).worldJoinInProgress : AppLocalizations.of(context).worldJoinNowButton),
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.colorScheme.primary,
                  foregroundColor: theme.colorScheme.onPrimary,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
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
              color: Colors.grey.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.withValues(alpha: 0.3)),
            ),
            child: Column(
              children: [
                Icon(
                  Icons.lock_outline,
                  color: theme.colorScheme.outline,  // World-theme based disabled icon color
                  size: 32,
                ),
                const SizedBox(height: 8),
                Text(
                  world.status == WorldStatus.closed
                              ? AppLocalizations.of(context).worldJoinWorldClosedStatus
    : AppLocalizations.of(context).worldJoinWorldArchivedStatus,
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

    // Wenn keine Buttons vorhanden, zeige leeren Container
    if (buttons.isEmpty) {
      return const SizedBox.shrink();
    }

    return Wrap(
      spacing: 8,
      runSpacing: 4,
      children: buttons,
    );
  }
} 