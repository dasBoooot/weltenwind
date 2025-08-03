import 'package:flutter/material.dart';
import '../../core/models/world.dart';
import '../../shared/navigation/smart_navigation.dart';

/// 🧭 Navigation Context
enum NavigationContext {
  landing,
  worldList,
  worldDashboard,
  worldJoin,
  invite,
}

/// 🧭 Smart Navigation Widget
/// 
/// Context-bewusste Navigation die automatisch das richtige Theme erbt
class NavigationWidget extends StatefulWidget {
  final NavigationContext currentContext;
  final Map<String, String>? routeParams;
  final List<World>? availableWorlds;
  
  const NavigationWidget({
    super.key,
    required this.currentContext,
    this.routeParams,
    this.availableWorlds,
  });

  @override
  State<NavigationWidget> createState() => _NavigationWidgetState();
}

class _NavigationWidgetState extends State<NavigationWidget> {
  NavigationContext get _currentContext => widget.currentContext;
  
  @override
  Widget build(BuildContext context) {
    // 🎯 SMART NAVIGATION THEME: Verwendet vorgeladenes Theme
    return _buildNavigation(context, Theme.of(context), null);
  }

  Widget _buildNavigation(BuildContext context, ThemeData theme, Map<String, dynamic>? extensions) {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      backgroundColor: theme.colorScheme.surface,
      selectedItemColor: theme.colorScheme.primary,
      unselectedItemColor: theme.colorScheme.onSurface.withValues(alpha: 0.6),
      currentIndex: _getCurrentIndex(),
      onTap: _onNavigationTap,
      items: _buildNavigationItems(context),
    );
  }

  List<BottomNavigationBarItem> _buildNavigationItems(BuildContext context) {
    final baseItems = <BottomNavigationBarItem>[
      const BottomNavigationBarItem(
        icon: Icon(Icons.public),
        label: 'Welten',
      ),
    ];

    // Context-spezifische Items hinzufügen
    switch (_currentContext) {
      case NavigationContext.worldDashboard:
        baseItems.addAll([
          const BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.inventory),
            label: 'Inventar',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profil',
          ),
        ]);
        break;
        
      case NavigationContext.worldJoin:
        baseItems.addAll([
          const BottomNavigationBarItem(
            icon: Icon(Icons.info),
            label: 'Info',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.people),
            label: 'Spieler',
          ),
        ]);
        break;
        
      default:
        baseItems.addAll([
          const BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profil',
          ),
        ]);
    }

    return baseItems;
  }

  int _getCurrentIndex() {
    switch (_currentContext) {
      case NavigationContext.landing:
      case NavigationContext.worldList:
        return 0;
      case NavigationContext.worldDashboard:
        return 1;
      case NavigationContext.worldJoin:
        return 0;
      case NavigationContext.invite:
        return 0;
    }
  }

  void _onNavigationTap(int index) async {
    switch (_currentContext) {
      case NavigationContext.worldList:
        if (index == 0) return; // Already on worlds
        if (index == 1) {
          await context.smartGoNamed('profile');
        }
        break;
        
      case NavigationContext.worldDashboard:
        final worldId = widget.routeParams?['id'];
        if (worldId == null) return;
        
        switch (index) {
          case 0:
            await context.smartGoNamed('worldList');
            break;
          case 1:
            return; // Already on dashboard
          case 2:
            await context.smartGoNamed('inventory', pathParameters: {'id': worldId});
            break;
          case 3:
            await context.smartGoNamed('profile');
            break;
        }
        break;
        
      case NavigationContext.worldJoin:
        final worldId = widget.routeParams?['id'];
        if (worldId == null) return;
        
        switch (index) {
          case 0:
            return; // Already on world join
          case 1:
            await context.smartGoNamed('worldInfo', pathParameters: {'id': worldId});
            break;
          case 2:
            await context.smartGoNamed('worldPlayers', pathParameters: {'id': worldId});
            break;
        }
        break;
        
      default:
        break;
    }
  }
}