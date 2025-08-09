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
import '../../shared/theme/theme_manager.dart';

class WorldListPage extends StatefulWidget {
  const WorldListPage({super.key});

  @override
  State<WorldListPage> createState() => _WorldListPageState();
}

class _WorldListPageState extends State<WorldListPage> {
  List<World> _worlds = [];
  bool _isLoading = true;
  final ThemeManager _themeManager = ThemeManager();

  @override
  void initState() {
    super.initState();
    _loadWorlds();
  }

  Future<void> _loadWorlds() async {
    try {
      final worldService = ServiceLocator.get<WorldService>();
      final worlds = await worldService.getWorlds();
      
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
    return MainScaffold(
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
        subtitle: const Text('🎨 Each world has unique themes! Click to join and experience them.'),
        child: GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: _getCrossAxisCount(context),
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: _getChildAspectRatio(context),
          ),
          itemCount: _worlds.length,
          itemBuilder: (context, index) {
            final world = _worlds[index];
            return _buildWorldCard(world);
          },
        ),
      ),
    );
  }

  Widget _buildWorldCard(World world) {
    final statusColor = _getWorldStatusColor(world.status);
    final statusIcon = _getWorldStatusIcon(world.status);
    final themeInfo = _getWorldThemeInfo(world);

    return WorldCard(
      worldName: world.name,
      worldStatus: '${world.status.name.toUpperCase()} • ${world.playerCount} players',
      worldIcon: statusIcon,
      onJoin: () => _openWorld(world),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
          // World description
          if (world.description != null && world.description!.isNotEmpty) ...[
                          Text(
              world.description!,
              style: Theme.of(context).textTheme.bodySmall,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 12),
          ],
          
          // World info chips
          Wrap(
            spacing: 8,
            runSpacing: 4,
            children: [
              // Category chip
              Chip(
                label: Text(
                  world.category.name.toUpperCase(),
                  style: const TextStyle(fontSize: 10),
                ),
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                backgroundColor: statusColor.withValues(alpha: 0.2),
                labelStyle: TextStyle(color: statusColor),
              ),
              
              // Theme chip (MIXED THEME HIGHLIGHT!)
              if (themeInfo != null)
                Chip(
                  label: Text(
                    '🎨 $themeInfo',
                    style: const TextStyle(fontSize: 10),
                  ),
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  backgroundColor: Theme.of(context).colorScheme.primary.withValues(alpha: 0.2),
                  labelStyle: TextStyle(color: Theme.of(context).colorScheme.primary),
                ),
              
              // Date info
              Chip(
                label: Text(
                  'Created ${_formatDate(world.createdAt)}',
                  style: const TextStyle(fontSize: 10),
                ),
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                backgroundColor: Colors.grey.withValues(alpha: 0.2),
                labelStyle: const TextStyle(color: Colors.grey),
              ),
            ],
          ),
          
          const Spacer(),
          
          // Join button
          AppButton(
            onPressed: () => _joinWorld(world),
            type: AppButtonType.primary,
            size: AppButtonSize.medium,
            fullWidth: true,
            icon: Icons.rocket_launch,
            child: const Text('Join World'),
          ),
        ],
      ),
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

  Color _getWorldStatusColor(WorldStatus status) {
    switch (status) {
      case WorldStatus.open:
        return Colors.green;
      case WorldStatus.running:
        return Colors.blue;
      case WorldStatus.upcoming:
        return Colors.orange;
      case WorldStatus.closed:
        return Colors.red;
      case WorldStatus.archived:
        return Colors.grey;
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
    if (world.themeBundle != null) {
      return world.themeVariant != null 
          ? '${world.themeBundle} (${world.themeVariant})'
          : world.themeBundle;
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

  int _getCrossAxisCount(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    if (screenWidth < 768) return 1; // Mobile: 1 column
    if (screenWidth < 1024) return 2; // Tablet: 2 columns
    return 3; // Desktop: 3 columns
  }

  double _getChildAspectRatio(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    if (screenWidth < 768) return 1.2; // Mobile: taller cards
    return 0.8; // Tablet/Desktop: square-ish cards
  }

  Future<void> _joinWorld(World world) async {
    try {
      AppLogger.app.i('🎯 Joining world: ${world.name} (Theme: ${world.themeBundle})');
      
      // 🎨 APPLY WORLD THEME BEFORE JOINING!
      if (world.themeBundle != null) {
        await _themeManager.setWorldTheme(world);
        AppLogger.app.i('✅ World theme applied: ${world.themeBundle}');
        
        if (mounted) {
          // Show theme change notification
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('🎨 Theme changed to: ${world.themeBundle}'),
              duration: const Duration(seconds: 2),
              backgroundColor: Theme.of(context).colorScheme.primary,
            ),
          );
        }
      }
      
      // TODO: Implement actual world joining logic
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('🚀 Joining ${world.name}...'),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      AppLogger.error.e('Failed to join world', error: e);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Failed to join world: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }
}