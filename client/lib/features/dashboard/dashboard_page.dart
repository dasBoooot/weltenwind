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
  String? _worldTheme;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadWorldData();
  }

  Future<void> _loadWorldData() async {
    AppLogger.app.d('🌍 [DASHBOARD-DEBUG] Loading world data for ID: ${widget.worldId}');
    try {
      final worldService = ServiceLocator.get<WorldService>();
      final world = await worldService.getWorld(int.parse(widget.worldId));
      
      AppLogger.app.d('🌍 [DASHBOARD-DEBUG] World loaded: ${world.name} (Theme: ${world.themeBundle})');
      
      setState(() {
        _world = world;
        _worldTheme = world.themeBundle ?? 'default'; // ✅ Theme-Name, nicht Bundle-Name
        _isLoading = false;
      });
    } catch (e) {
      AppLogger.app.e('❌ [DASHBOARD-ERROR] Failed to load world: $e');
      setState(() {
        _world = null; // Explicitly set to null
        _worldTheme = 'default'; // ✅ Theme-Name Fallback
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // 🎮 NEW: Using AppScaffold with integrated game theme system
    return AppScaffoldBuilder.forGameWithTheme(
      themeContext: 'in-game',
      themeBundle: 'full-gaming',
      worldTheme: _worldTheme,
      componentName: 'WorldDashboard',
      body: _buildDashboardBody(context),
    );
  }

  Widget _buildDashboardBody(BuildContext context) {
    final theme = Theme.of(context);
    return BackgroundWidget(
      worldTheme: _worldTheme,  // 🌍 World-specific background
      child: Stack(
        children: [
          // Main content
          Center(
            child: _isLoading 
              ? CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(theme.colorScheme.primary),
                )
              : WorldDashboardWidget(
                  worldTheme: _worldTheme,
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