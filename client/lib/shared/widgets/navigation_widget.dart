import 'package:flutter/material.dart';
import '../../core/models/world.dart';
import '../../shared/navigation/smart_navigation.dart';
import '../../l10n/app_localizations.dart';
import 'user_info_widget.dart';
import 'language_switcher.dart';
import 'logout_widget.dart';

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
    // 🎯 SMART NAVIGATION THEME: Theme wird durch Smart Navigation preloaded oder explizit gesetzt
    final theme = Theme.of(context);
    return _buildNavigation(context, theme, null);
  }

  Widget _buildNavigation(BuildContext context, ThemeData theme, Map<String, dynamic>? extensions) {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: SafeArea(
        child: Container(
          height: 80,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface.withValues(alpha: 0.95),
            border: Border(
              bottom: BorderSide(
                color: theme.colorScheme.outline.withValues(alpha: 0.2),
                width: 1,
              ),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // 🔰 LEFT SIDE: User Info + Language Switcher + Logout (with overflow protection)
              const Flexible(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    LogoutWidget(),
                    SizedBox(width: 12),
                    UserInfoWidget(),
                    SizedBox(width: 12),
                    LanguageSwitcher(),
                  ],
                ),
              ),
              
              // 🧭 RIGHT SIDE: Navigation Tabs (Rechtsbündig)
              Row(
                mainAxisSize: MainAxisSize.min,
                children: _buildNavigationTabs(context, theme),
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _buildNavigationTabs(BuildContext context, ThemeData theme) {
    final tabs = <Widget>[];
    
    // 🎯 OPTIMIERTE NAVIGATION LOGIK - Mit Active Page
    switch (_currentContext) {
      case NavigationContext.worldList:
        // 🏠 WORLD LIST: Aktuelle Page als aktiv anzeigen
        tabs.add(_buildNavTab(
          context, theme,
          icon: Icons.public,
          label: AppLocalizations.of(context).navWorldList,
          isActive: true, // Aktuelle Page
          index: -1, // Kein Navigation bei aktiver Page
        ));
        break;
        
      case NavigationContext.worldJoin:
        // 🚀 WORLD JOIN: Aktuelle Page + World List
        tabs.addAll([
          _buildNavTab(
            context, theme,
            icon: Icons.public,
            label: AppLocalizations.of(context).navWorldList,
            isActive: false,
            index: 0,
          ),
          const SizedBox(width: 8),
          _buildNavTab(
            context, theme,
            icon: Icons.login,
            label: AppLocalizations.of(context).worldJoinNowButton,
            isActive: true, // Aktuelle Page
            index: -1, // Kein Navigation bei aktiver Page
          ),
        ]);
        break;
        
      case NavigationContext.worldDashboard:
        // 🏛️ DASHBOARD: Aktuelle Page + World List + World Join
        tabs.addAll([
          _buildNavTab(
            context, theme,
            icon: Icons.public,
            label: AppLocalizations.of(context).navWorldList,
            isActive: false,
            index: 0,
          ),
          const SizedBox(width: 8),
          _buildNavTab(
            context, theme,
            icon: Icons.login,
            label: AppLocalizations.of(context).worldJoinNowButton,
            isActive: false,
            index: 1,
          ),
          const SizedBox(width: 8),
          _buildNavTab(
            context, theme,
            icon: Icons.dashboard,
            label: 'Dashboard', // TODO: Add to AppLocalizations
            isActive: true, // Aktuelle Page
            index: -1, // Kein Navigation bei aktiver Page
          ),
        ]);
        break;
        
      default:
        // Fallback: Keine Navigation
        break;
    }
    
    return tabs;
  }
  
  Widget _buildNavTab(
    BuildContext context, 
    ThemeData theme, {
    required IconData icon,
    required String label,
    required bool isActive,
    required int index,
  }) {
    return GestureDetector(
      onTap: index >= 0 ? () => _onNavigationTap(index) : null, // Kein Tap für aktive Pages
      child: Container(
        constraints: const BoxConstraints(minWidth: 80, maxWidth: 100), // 🎯 FLEXIBLE WIDTH
        height: 64,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        decoration: BoxDecoration(
          color: isActive 
            ? theme.colorScheme.primary.withValues(alpha: 0.1)
            : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: isActive 
            ? Border.all(color: theme.colorScheme.primary.withValues(alpha: 0.3))
            : null,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 20,
              color: isActive 
                ? theme.colorScheme.primary
                : theme.colorScheme.onSurface.withValues(alpha: 0.7),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: theme.textTheme.labelSmall?.copyWith(
                color: isActive 
                  ? theme.colorScheme.primary
                  : theme.colorScheme.onSurface.withValues(alpha: 0.7),
                fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  void _onNavigationTap(int index) async {
    final worldId = widget.routeParams?['id'];
    
    // 🎯 VEREINFACHTE NAVIGATION LOGIK - Jeder Nav-Punkt führt zu spezifischer Page
    switch (_currentContext) {
      case NavigationContext.worldList:
        // 🏠 WORLD LIST: Keine Nav-Punkte vorhanden
        break;
        
      case NavigationContext.worldJoin:
        switch (index) {
          case 0:
            // Navigate to world list (needs theme context preloading)
            await context.smartGoNamed('world-list');
            break;
        }
        break;
        
      case NavigationContext.worldDashboard:
        switch (index) {
          case 0:
            // Navigate to world list (needs theme context preloading)
            await context.smartGoNamed('world-list');
            break;
          case 1:
            // Navigate back to world join (Tab Navigation - skip preloading)
            if (worldId != null) {
              await context.smartGoNamed('world-join', pathParameters: {'id': worldId}, skipPreloading: true);
            }
            break;
        }
        break;
        
      default:
        // Fallback navigation - go to world list (needs theme context preloading)
        await context.smartGoNamed('world-list');
        break;
    }
  }
}