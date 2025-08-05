import 'package:flutter/material.dart';
import '../../config/logger.dart';
import '../../core/services/world_service.dart';
import '../../core/models/world.dart';
import '../../theme/background_widget.dart';
import '../../shared/widgets/navigation_widget.dart';
import '../../shared/components/app_scaffold.dart';
import '../../main.dart';
import 'widgets/world_dashboard_widget.dart';

class DashboardPage extends StatefulWidget {
  final String worldId;
  
  const DashboardPage({super.key, required this.worldId});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  World? _world;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadWorldData();
  }

  /// 🎯 Get World Theme from loaded world data (similar to world_list_page)
  String? _getWorldTheme() {
    if (_world == null) {
      return null; // Let AppScaffold use default theme while loading
    }
    
    // 1. Prioritize themeVariant (new API field)
    if (_world!.themeVariant != null && _world!.themeVariant!.isNotEmpty && _world!.themeVariant != 'standard') {
      AppLogger.app.d('✅ [DASHBOARD-THEME] Using world.themeVariant: ${_world!.themeVariant}');
      return _world!.themeVariant!;
    }
    
    // 2. ✅ DYNAMIC: themeBundle IS the theme name (no hardcoded mapping needed!)
    final themeBundle = _world!.themeBundle ?? 'default';
    AppLogger.app.d('🎯 [DASHBOARD-THEME] Using themeBundle directly: $themeBundle');
    return themeBundle;
  }

  // ✅ REMOVED: _getBundleFallbackTheme - no hardcoded mappings needed!

  Future<void> _loadWorldData() async {
    AppLogger.app.d('🌍 [DASHBOARD-DEBUG] Loading world data for ID: ${widget.worldId}');
    try {
      final worldService = ServiceLocator.get<WorldService>();
      final world = await worldService.getWorld(int.parse(widget.worldId));
      
      AppLogger.app.d('🌍 [DASHBOARD-DEBUG] World loaded: ${world.name} (Theme: ${world.themeBundle})');
      
      setState(() {
        _world = world;
        _isLoading = false;
      });
    } catch (e) {
      AppLogger.app.e('❌ [DASHBOARD-ERROR] Failed to load world: $e');
      setState(() {
        _world = null; // Explicitly set to null
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final worldTheme = _getWorldTheme();
    AppLogger.app.d('🎯 [DASHBOARD-FIXED] Using AppScaffold with world theme: $worldTheme');
    
    return AppScaffold(
      key: ValueKey('dashboard-${widget.worldId}-${worldTheme ?? 'loading'}'), // ✅ FORCE REBUILD when theme changes!
      themeContextId: 'in-game',
      themeBundleId: 'full-gaming',
      worldThemeOverride: worldTheme, // ✅ RESTORED: AppScaffold needs this parameter!
      componentName: 'WorldDashboard',
      showBackgroundGradient: false,
      extendBodyBehindAppBar: true,
      body: _buildDashboardBody(context, worldTheme),
    );
  }

  Widget _buildDashboardBody(BuildContext context, String? worldTheme) {
    final theme = Theme.of(context);
    
    // 🔍 DEBUG: Check what theme we actually get
    print('🎨 [DASHBOARD-BODY] Theme primary color: ${theme.colorScheme.primary.toString()}, worldTheme: $worldTheme');
    AppLogger.app.d('🎨 [DASHBOARD-BODY] Theme primary color: ${theme.colorScheme.primary.toString()}, worldTheme: $worldTheme');
    return BackgroundWidget(
      worldTheme: worldTheme, // ✅ World-specific background
      waitForWorldTheme: true, // 🔄 RACE CONDITION FIX: Wait for world theme
      child: Stack(
        children: [
          // Main content
          Center(
            child: _isLoading 
              ? CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(theme.colorScheme.primary),
                )
              : WorldDashboardWidget(
                  worldTheme: worldTheme, // ✅ Pass worldTheme to widget
                  worldName: _world?.name,
                  worldId: int.tryParse(widget.worldId),
                  theme: theme,
                  extensions: null, // Extensions now handled by AppScaffold
                ),
          ),
          
          // 🧭 INTEGRATED NAVIGATION: Now gets correct themes from context
          _buildNavigationWithTheme(theme),
        ],
      ),
    );
  }

  /// 🎨 Build Navigation with correct theme context
  Widget _buildNavigationWithTheme(ThemeData theme) {
    return Theme(
      data: theme,
      child: NavigationWidget(
        currentContext: NavigationContext.worldDashboard,
        routeParams: {'id': widget.worldId.toString()},
      ),
    );
  }
} 