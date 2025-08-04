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
            children: [
              // 🔰 LEFT SIDE: User Info + Language Switcher + Logout (with overflow protection)
              Flexible(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const UserInfoWidget(),
                    const SizedBox(width: 12),
                    const LanguageSwitcher(),
                    const SizedBox(width: 12),
                    const LogoutWidget(),
                  ],
                ),
              ),
              
              // 🌟 SPACER: Flexible space between left and right
              const Spacer(),
              
              // 🧭 RIGHT SIDE: Navigation Tabs (Fixed Width)
              ..._buildNavigationTabs(context, theme),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _buildNavigationTabs(BuildContext context, ThemeData theme) {
    final tabs = <Widget>[];
    
    // 🎯 OPTIMIERTE NAVIGATION LOGIK - Nur relevante Nav-Punkte pro Page
    switch (_currentContext) {
      case NavigationContext.worldList:
        // 🏠 WORLD LIST: Keine Nav-Punkte - User ist bereits hier
        break;
        
      case NavigationContext.worldJoin:
        // 🚀 WORLD JOIN: Nur zurück zur World List
        tabs.add(_buildNavTab(
          context, theme,
          icon: Icons.public,
          label: AppLocalizations.of(context).navWorldList,
          isActive: false, // Nicht aktiv, da auf anderer Page
          index: 0,
        ));
        break;
        
      case NavigationContext.worldDashboard:
        // 🏛️ DASHBOARD: Zurück zu World List + World Join
        tabs.addAll([
          _buildNavTab(
            context, theme,
            icon: Icons.public,
            label: AppLocalizations.of(context).navWorldList,
            isActive: false, // Nicht aktiv, da auf anderer Page
            index: 0,
          ),
          const SizedBox(width: 8),
          _buildNavTab(
            context, theme,
            icon: Icons.login,
            label: AppLocalizations.of(context).worldJoinNowButton,
            isActive: false, // Nicht aktiv, da auf anderer Page
            index: 1,
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
      onTap: () => _onNavigationTap(index),
      child: Container(
        width: 120, // 🎯 FIXED WIDTH for navigation tabs
        height: 64,
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
            // Navigate to world list
            await context.smartGoNamed('world-list');
            break;
        }
        break;
        
      case NavigationContext.worldDashboard:
        switch (index) {
          case 0:
            // Navigate to world list
            await context.smartGoNamed('world-list');
            break;
          case 1:
            // Navigate back to world join
            if (worldId != null) {
              await context.smartGoNamed('world-join', pathParameters: {'id': worldId});
            }
            break;
        }
        break;
        
      default:
        // Fallback navigation - go to world list
        await context.smartGoNamed('world-list');
        break;
    }
  }
}