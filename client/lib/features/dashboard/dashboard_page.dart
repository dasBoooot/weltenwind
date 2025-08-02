import 'package:flutter/material.dart';
import '../../core/providers/theme_context_provider.dart';
import '../../core/services/world_service.dart';
import '../../core/models/world.dart';
import '../../theme/background_widget.dart';
import '../../shared/widgets/user_info_widget.dart';
import '../../shared/widgets/navigation_widget.dart';
import '../../shared/widgets/language_switcher.dart';
import '../../main.dart';

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
    try {
      final worldService = ServiceLocator.get<WorldService>();
      final world = await worldService.getWorld(int.parse(widget.worldId));
      
      setState(() {
        _world = world;
        _worldTheme = world.themeBundle ?? 'default_world_bundle';
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _worldTheme = 'default_world_bundle'; // Fallback
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // 🌍 WORLD-DASHBOARD: Finaler Einstiegspunkt im World-Theme!
    return ThemeContextConsumer(
      componentName: 'WorldDashboard',
      enableMixedContext: true,
      worldThemeOverride: _worldTheme ?? 'default_world_bundle',
      fallbackTheme: 'default_world_bundle',
      contextOverrides: {
        'uiContext': 'world-dashboard',
        'pageType': 'dashboard',
        'context': 'world-themed',
        'worldId': widget.worldId,
        'immersiveExperience': 'true',
        'brandingElements': 'true',
        'finalEntry': 'true', // Finaler Welten-Einstieg
      },
      builder: (context, theme, extensions) {
        return _buildDashboard(context, theme, extensions);
      },
    );
  }

  Widget _buildDashboard(BuildContext context, ThemeData theme, Map<String, dynamic>? extensions) {
    return Scaffold(
      body: BackgroundWidget(
        child: Stack(
          children: [
            // Main content
            Center(
              child: _isLoading 
                ? CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(theme.colorScheme.primary),
                  )
                : Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 600),
                      child: Card(
                        elevation: 12,
                        color: const Color(0xFF1A1A1A), // Dunkle Karte
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
                            // Icon
                            Container(
                              width: 80,
                              height: 80,
                              decoration: BoxDecoration(
                                color: theme.colorScheme.primary.withValues(alpha: 0.2),
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: theme.colorScheme.primary.withValues(alpha: 0.5),
                                  width: 2,
                                ),
                              ),
                              child: Icon(
                                Icons.rocket_launch,
                                size: 40,
                                color: theme.colorScheme.primary,
                              ),
                            ),
                            const SizedBox(height: 24),
                            
                            // Title
                            Text(
                              _world?.name ?? 'Welt-Dashboard',
                              style: theme.textTheme.headlineMedium?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 16),
                            
                            // Subtitle
                            Text(
                              'Welt: ${_world?.name ?? 'Unbekannt'} (ID: ${widget.worldId})',
                              style: theme.textTheme.bodyLarge?.copyWith(
                                color: Colors.grey[300],
                              ),
                            ),
                            const SizedBox(height: 32),
                            
                            // Info message
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: theme.colorScheme.primary.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: theme.colorScheme.primary.withValues(alpha: 0.3),
                                ),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.rocket_launch,
                                    color: theme.colorScheme.primary,
                                    size: 24,
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      'Willkommen in der Welt "${_world?.name ?? 'Unbekannt'}"! Das Dashboard wird bald verfügbar sein.',
                                      style: TextStyle(
                                        color: Colors.grey[300],
                                        fontSize: 16,
                                      ),
                                    ),
                                  ),
                                ],
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