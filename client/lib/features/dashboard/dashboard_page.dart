import 'package:flutter/material.dart';
import '../../core/theme/index.dart';
import '../../core/services/world_service.dart';
import '../../core/models/world.dart';
import '../../theme/background_widget.dart';
import '../../shared/widgets/user_info_widget.dart';
import '../../shared/widgets/navigation_widget.dart';
import '../../shared/widgets/language_switcher.dart';
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
    print('🌍 [DASHBOARD-DEBUG] Loading world data for ID: ${widget.worldId}');
    try {
      final worldService = ServiceLocator.get<WorldService>();
      final world = await worldService.getWorld(int.parse(widget.worldId));
      
      print('🌍 [DASHBOARD-DEBUG] World loaded: ${world.name} (Theme: ${world.themeBundle})');
      
      setState(() {
        _world = world;
        _worldTheme = world.themeBundle ?? 'default'; // ✅ Theme-Name, nicht Bundle-Name
        _isLoading = false;
      });
    } catch (e) {
      print('❌ [DASHBOARD-ERROR] Failed to load world: $e');
      setState(() {
        _world = null; // Explicitly set to null
        _worldTheme = 'default'; // ✅ Theme-Name Fallback
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // 🔸 SCOPED CONTEXT: In-game Dashboard mit full-gaming Context
    return ThemePageProvider(
      contextId: 'in-game', 
      bundleId: 'full-gaming',
      worldTheme: _worldTheme, // 🌍 World-spezifisches Theme wenn verfügbar
      child: ThemeContextConsumer(
        componentName: 'WorldDashboard',
        worldThemeOverride: _worldTheme, // 🌍 Component-Level Override - async loading in ThemeContextConsumer
        fallbackBundle: 'full-gaming', // 🎮 Gaming Bundle als Fallback
        builder: (context, theme, extensions) {
          return _buildDashboard(context, theme, extensions);
        },
      ),
    );
  }

  Widget _buildDashboard(BuildContext context, ThemeData theme, Map<String, dynamic>? extensions) {
    return Scaffold(
      body: BackgroundWidget(
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
                    extensions: extensions,
                  ),
            ),
            
            // User info widget in top-left corner
            const UserInfoWidget(),
            
            // Language switcher (left of NavigationWidget)
            const Positioned(
              top: 16.0, // Fixed spacing
              right: 96, // 20px Abstand vom NavigationWidget (76 + 20)
              child: SafeArea(
              child: LanguageSwitcher(),
              ),
            ),
            
            // Navigation widget in top-right corner
            NavigationWidget(
              currentRoute: 'world-dashboard',
              routeParams: {'id': widget.worldId},
              isJoinedWorld: true, // User muss in der Welt sein um das Dashboard zu sehen
            ),
          ],
        ),
      ),
    );
  }
} 