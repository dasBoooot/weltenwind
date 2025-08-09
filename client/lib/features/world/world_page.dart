import 'dart:convert';
import 'package:flutter/material.dart';
import '../../config/logger.dart';
import '../../core/services/world_service.dart';
import '../../core/models/world.dart';
import '../../core/services/authorization_service.dart';

class WorldPage extends StatefulWidget {
  final String idOrSlug;
  const WorldPage({super.key, required this.idOrSlug});

  @override
  State<WorldPage> createState() => _WorldPageState();
}

class _WorldPageState extends State<WorldPage> {
  World? _world;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() { _loading = true; _error = null; });
    try {
      // Guard: require world.view (server-driven mapping)
      final allowed = await AuthorizationService().authorizeResourceAction(
        resource: 'world', action: 'view',
        worldId: RegExp(r'^\d+$').hasMatch(widget.idOrSlug) ? widget.idOrSlug : null,
      );
      if (!allowed) {
        setState(() { _error = 'Keine Berechtigung (world.view)'; _loading = false; });
        return;
      }
      final ws = WorldService();
      final isNumeric = RegExp(r'^\d+$').hasMatch(widget.idOrSlug);
      final world = isNumeric
          ? await ws.getWorld(int.parse(widget.idOrSlug))
          : await _getWorldBySlug(ws, widget.idOrSlug);
      setState(() { _world = world; _loading = false; });
    } catch (e) {
      AppLogger.app.e('World load failed', error: e);
      setState(() { _error = e.toString(); _loading = false; });
    }
  }

  Future<World> _getWorldBySlug(WorldService ws, String slug) async {
    // Re-using the GET /worlds/:idOrSlug endpoint through WorldService.getWorld
    final response = await ws.apiGetRaw('/worlds/$slug');
    if (response.statusCode == 200) {
      return World.fromJson(jsonDecode(response.body));
    }
    throw Exception('World not found');
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    if (_error != null) {
      return Scaffold(
        appBar: AppBar(title: const Text('World')),
        body: Center(child: Text('Error: $_error')),
      );
    }
    final world = _world!;
    return Scaffold(
      appBar: AppBar(title: Text(world.name)),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Status: ${world.statusText}'),
            const SizedBox(height: 8),
            if (world.description != null) Text(world.description!),
            const SizedBox(height: 16),
            FutureBuilder<bool>(
              future: AuthorizationService().authorizeResourceAction(resource: 'player', action: 'join', worldId: world.id.toString()),
              builder: (ctx, snap) => (snap.data == true)
                ? ElevatedButton.icon(onPressed: (){}, icon: const Icon(Icons.login), label: const Text('Join'))
                : const SizedBox.shrink(),
            ),
            const SizedBox(height: 8),
            FutureBuilder<bool>(
              future: AuthorizationService().authorizeResourceAction(resource: 'world', action: 'edit', worldId: world.id.toString()),
              builder: (ctx, snap) => (snap.data == true)
                ? ElevatedButton.icon(onPressed: (){}, icon: const Icon(Icons.edit), label: const Text('Edit'))
                : const SizedBox.shrink(),
            ),
          ],
        ),
      ),
    );
  }
}


