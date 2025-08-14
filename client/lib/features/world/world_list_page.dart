import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../config/logger.dart';
import '../../core/services/world_service.dart';
import '../../core/services/api_service.dart';
import '../../core/services/auth_service.dart';
import '../../core/models/world.dart';
import '../../main.dart';
import '../../shared/components/layout/app_scaffold.dart';
import '../../shared/components/cards/app_card.dart';
import '../../shared/components/buttons/app_button.dart';
import '../../shared/components/layout/app_container.dart';
import '../../shared/theme/theme_resolver.dart';
import '../../shared/theme/theme_manager.dart';

class WorldListPage extends StatefulWidget {
  const WorldListPage({super.key});

  @override
  State<WorldListPage> createState() => _WorldListPageState();
}

class _WorldListPageState extends State<WorldListPage> {
  List<World> _worlds = [];
  bool _isLoading = true;
  late final World _defaultWorld;

  @override
  void initState() {
    super.initState();
    _defaultWorld = World(
      id: 0,
      name: 'Default',
      status: WorldStatus.open,
      createdAt: DateTime.now(),
      startsAt: DateTime.now(),
      description: 'Default background for world list',
      assets: 'default',
    );
    // Ensure Default Theme when entering the list page
    try {
      ThemeManager().clearWorldTheme();
    } catch (_) {}
    _loadWorlds();
  }

  Future<void> _loadWorlds() async {
    try {
      final worldService = ServiceLocator.get<WorldService>();
      final worlds = await worldService.getWorlds();
      // Optional: preload themes for smoother card rendering
      try {
        await ThemeManager().preloadWorldThemes(worlds);
      } catch (e) {
        AppLogger.app.w('Theme preload failed', error: e);
      }
      
        setState(() {
          _worlds = worlds;
          _isLoading = false;
        });
        
      AppLogger.app.i('✅ Loaded ${worlds.length} worlds');
    } catch (e) {
      AppLogger.app.e('❌ Failed to load worlds', error: e);
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load worlds: $e')),
        );
      }
    }
  }

  Future<void> _logout() async {
    try {
      final authService = ServiceLocator.get<AuthService>();
      await authService.logout();
      
      if (mounted) {
        context.go('/login');
      }
    } catch (e) {
      AppLogger.app.e('❌ Logout error', error: e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return MainScaffoldWithBackground(
      world: _defaultWorld,
      pageType: 'world_list',
      themeContext: 'pre-game',
      title: const Text('🌍 Worlds'),
      actions: [
        IconButton(
          icon: const Icon(Icons.refresh),
          onPressed: _loadWorlds,
          tooltip: 'Refresh Worlds',
        ),
        IconButton(
          icon: const Icon(Icons.person),
          onPressed: _showMe,
          tooltip: 'Test /me',
        ),
        IconButton(
          icon: const Icon(Icons.logout),
          onPressed: _logout,
          tooltip: 'Logout',
        ),
      ],
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_worlds.isEmpty) {
      return AppContent(
        child: AppSection(
          title: const Text('No Worlds Available'),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.public, size: 64),
              const SizedBox(height: 16),
              Text(
                'No worlds found',
                style: Theme.of(context).textTheme.headlineSmall,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Check back later for new worlds to explore',
                style: Theme.of(context).textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              AppButton(
                onPressed: _loadWorlds,
                type: AppButtonType.primary,
                icon: Icons.refresh,
                child: const Text('Refresh'),
              ),
            ],
          ),
        ),
      );
    }

    return AppContent(
      child: AppSection(
        title: Text('Available Worlds (${_worlds.length})'),
        subtitle: const Text('🎨 Each world has unique themes! Click to open.'),
        child: Scrollbar(
          thumbVisibility: true,
          child: GridView.builder(
            shrinkWrap: true,
            gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: 420,
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              childAspectRatio: 1.20,
            ),
            itemCount: _worlds.length,
            itemBuilder: (context, index) {
              final world = _worlds[index];
              return _buildWorldCard(world);
            },
          ),
        ),
      ),
    );
  }

  Widget _buildWorldCard(World world) {
    final statusColor = _getWorldStatusColor(context, world.status);
    final statusIcon = _getWorldStatusIcon(world.status);
    final themeInfo = _getWorldThemeInfo(world);

    return FutureBuilder<ThemeData>(
      future: ThemeResolver().resolveWorldTheme(world, context: 'pre-game'),
      builder: (ctx, snap) {
        buildCard(BuildContext useCtx) {
          final cs = Theme.of(useCtx).colorScheme;
          final tt = Theme.of(useCtx).textTheme;
          return WorldCard(
            size: AppCardSize.compact,
            worldName: world.name,
            worldStatus: '${world.status.name.toUpperCase()} • ${world.playerCount} players',
            worldIcon: statusIcon,
            onJoin: () => _openWorld(world),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  children: [
                    Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: cs.primary.withValues(alpha: 0.15),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(statusIcon, size: 16, color: cs.primary),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(world.name, style: tt.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
                          const SizedBox(height: 2),
                          Text(
                            '${world.status.name.toUpperCase()} • ${world.playerCount} players',
                            style: tt.labelSmall?.copyWith(color: cs.onSurfaceVariant),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                // Tags
                Wrap(
                  spacing: 8,
                  runSpacing: 6,
                  children: [
                    Chip(
                      label: Text(world.category.name.toUpperCase(), style: const TextStyle(fontSize: 10)),
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      backgroundColor: statusColor.withValues(alpha: 0.18),
                      labelStyle: TextStyle(color: statusColor),
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                    ),
                    if (themeInfo != null)
                      Chip(
                        label: Text('🎨 $themeInfo', style: const TextStyle(fontSize: 10)),
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        backgroundColor: cs.primary.withValues(alpha: 0.18),
                        labelStyle: TextStyle(color: cs.primary),
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                      ),
                    Chip(
                      label: Text('Created ${_formatDate(world.createdAt)}', style: const TextStyle(fontSize: 10)),
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      backgroundColor: cs.onSurface.withValues(alpha: 0.08),
                      labelStyle: TextStyle(color: cs.onSurfaceVariant),
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                    ),
                  ],
                ),
                const Spacer(),
                AppButton(
                  onPressed: () => _openWorld(world),
                  type: AppButtonType.primary,
                  size: AppButtonSize.medium,
                  fullWidth: true,
                  icon: Icons.login,
                  child: const Text('Join'),
                ),
              ],
            ),
          );
        }

        if (snap.connectionState == ConnectionState.done && snap.hasData) {
               return Theme(
             data: snap.data!,
             child: Builder(builder: (inner) => buildCard(inner)),
           );
        }
        // Fallback: render im App-Theme, bis Theme geladen
        return buildCard(context);
      },
    );
  }
  void _openWorld(World world) {
    final String pathParam = (world.slug != null && world.slug!.isNotEmpty)
        ? world.slug!
        : world.id.toString();
    context.go('/worlds/$pathParam');
  }

  Future<void> _showMe() async {
    try {
      final api = ApiService();
      final res = await api.get('/me');
      if (!mounted) return;
      if (res.statusCode == 200) {
        final data = res.body;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('ME: $data')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('ME failed: ${res.statusCode}')),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('ME error: $e')),
      );
    }
  }

  Color _getWorldStatusColor(BuildContext context, WorldStatus status) {
    final cs = Theme.of(context).colorScheme;
    switch (status) {
      case WorldStatus.open:
        return cs.secondary;
      case WorldStatus.running:
        return cs.primary;
      case WorldStatus.upcoming:
        return cs.tertiary;
      case WorldStatus.closed:
        return cs.error;
      case WorldStatus.archived:
        return cs.onSurfaceVariant;
    }
  }

  IconData _getWorldStatusIcon(WorldStatus status) {
    switch (status) {
      case WorldStatus.open:
        return Icons.door_front_door;
      case WorldStatus.running:
        return Icons.play_circle;
      case WorldStatus.upcoming:
        return Icons.schedule;
      case WorldStatus.closed:
        return Icons.lock;
      case WorldStatus.archived:
        return Icons.archive;
    }
  }

  String? _getWorldThemeInfo(World world) {
    if (world.assets != null && world.assets!.isNotEmpty) {
      return world.assets;
    }
    return null;
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date).inDays;
    
    if (difference == 0) return 'today';
    if (difference == 1) return 'yesterday';
    if (difference < 7) return '${difference}d ago';
    if (difference < 30) return '${(difference / 7).round()}w ago';
    return '${(difference / 30).round()}m ago';
  }

}