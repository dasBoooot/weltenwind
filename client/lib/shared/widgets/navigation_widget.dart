import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../theme/tokens/spacing.dart';
import '../components/index.dart';
import '../utils/dynamic_components.dart';
import '../../l10n/app_localizations.dart';

/// 🧭 Smart Fantasy Navigation Widget
/// 
/// Intelligente, kontextabhängige Navigation mit DynamicComponents
class NavigationWidget extends StatefulWidget {
  final String? currentRoute;
  final Map<String, dynamic>? routeParams;
  final bool? isJoinedWorld;
  
  const NavigationWidget({
    super.key,
    this.currentRoute,
    this.routeParams,
    this.isJoinedWorld,
  });

  @override
  State<NavigationWidget> createState() => _NavigationWidgetState();
}

/// 🎯 Navigation Context - bestimmt welche Aktionen verfügbar sind
enum NavigationContext {
  worldList,      // Welten-Übersicht
  worldJoin,      // Welt-Beitritts-Seite  
  worldDashboard, // Welt-Dashboard
  invite,         // Invite-Seiten
  general,        // Fallback
}

/// 🎭 Navigation Action - definiert eine Navigation-Aktion
class NavigationAction {
  final String label;
  final IconData icon;
  final VoidCallback onTap;
  final bool isActive;
  
  NavigationAction({
    required this.label,
    required this.icon,
    required this.onTap,
    this.isActive = false,
  });
}

class _NavigationWidgetState extends State<NavigationWidget> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  bool _isExpanded = false;
  
  /// 🎯 Bestimmt den aktuellen Navigation-Context
  NavigationContext get _currentContext {
    final route = widget.currentRoute;
    
    if (route == null) return NavigationContext.general;
    
    switch (route) {
      case 'world-list':
        return NavigationContext.worldList;
      case 'world-join':
        return NavigationContext.worldJoin;
      case 'world-dashboard':
        return NavigationContext.worldDashboard;
      case 'invite-landing':
      case 'invite':
        return NavigationContext.invite;
      default:
        return NavigationContext.general;
    }
  }
  
  /// 🎨 Bestimmt das Context-Icon für den Compact View
  IconData get _contextIcon {
    switch (_currentContext) {
      case NavigationContext.worldList:
        return Icons.public; // 🌍 Welten
      case NavigationContext.worldJoin:
        return Icons.login; // 🚪 Beitritt
      case NavigationContext.worldDashboard:
        return Icons.dashboard; // 📊 Dashboard
      case NavigationContext.invite:
        return Icons.mail; // 💌 Invite
      case NavigationContext.general:
        return Icons.explore; // 🧭 Allgemein
    }
  }
  
  /// 🧠 Generiert die intelligenten Navigation-Aktionen
  List<NavigationAction> get _navigationActions {
    switch (_currentContext) {
      case NavigationContext.worldList:
        // Auf world-list: Keine Navigation nötig (Hauptseite)
        return [];
        
      case NavigationContext.worldJoin:
        return [
          NavigationAction(
            label: AppLocalizations.of(context).navigationWorldOverview,
            icon: Icons.arrow_back,
            onTap: () => context.goNamed('world-list'),
          ),
        ];
        
      case NavigationContext.worldDashboard:
        final worldId = widget.routeParams?['id']?.toString();
        return [
          NavigationAction(
            label: AppLocalizations.of(context).navigationWorldOverview,
            icon: Icons.arrow_back,
            onTap: () => context.goNamed('world-list'),
          ),
          if (worldId != null)
            NavigationAction(
              label: AppLocalizations.of(context).navigationWorldDetails,
              icon: Icons.info,
              onTap: () => context.goNamed('world-join', pathParameters: {'id': worldId}),
            ),
        ];
        
      case NavigationContext.invite:
        return [
          NavigationAction(
            label: AppLocalizations.of(context).navigationWorldOverview,
            icon: Icons.public,
            onTap: () => context.goNamed('world-list'),
          ),
        ];
        
      case NavigationContext.general:
        return [
          NavigationAction(
            label: AppLocalizations.of(context).navigationWorldOverview,
            icon: Icons.public,
            onTap: () => context.goNamed('world-list'),
          ),
        ];
    }
  }
  
  /// 🤔 Soll das Widget angezeigt werden?
  bool get _shouldShow {
    // Auf world-list verstecken wir das Widget (keine Navigation nötig)
    return _currentContext != NavigationContext.worldList || _navigationActions.isNotEmpty;
  }
  
  @override
  void initState() {
    super.initState();
    
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    
    _animationController.forward();
  }
  
  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }
  
  void _toggleExpanded() {
    setState(() {
      _isExpanded = !_isExpanded;
    });
  }
  
  /// 🎨 Bestimmt den Titel basierend auf Kontext
  String get _contextTitle {
    switch (_currentContext) {
      case NavigationContext.worldJoin:
        return 'Navigation';
      case NavigationContext.worldDashboard:
        return 'Navigation';
      case NavigationContext.invite:
        return 'Navigation';
      default:
        return 'Navigation';
    }
  }
  
  @override
  Widget build(BuildContext context) {
    // Widget nur anzeigen wenn Navigation-Aktionen verfügbar sind
    if (!_shouldShow) {
      return const SizedBox.shrink();
    }
    
    final actions = _navigationActions;
    
    return Positioned(
      top: AppSpacing.md,
      right: AppSpacing.md,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          constraints: BoxConstraints(
            minWidth: _isExpanded ? 200 : 60,
            maxWidth: _isExpanded ? 250 : 60,
          ),
          child: _isExpanded 
            ? _buildExpandedView(actions) 
            : _buildCompactView(),
        ),
      ),
    );
  }
  
  /// 🔘 Kompakter Kreis-View 
  Widget _buildCompactView() {
    return GestureDetector(
      onTap: _toggleExpanded,
      child: Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Theme.of(context).colorScheme.primary,
              Theme.of(context).colorScheme.primary.withValues(alpha: 0.8),
            ],
          ),
          boxShadow: [
            BoxShadow(
              color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.3),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Icon(
          _contextIcon,
          color: Theme.of(context).colorScheme.onPrimary,
          size: 28,
        ),
      ),
    );
  }
  
  /// 📋 Erweiterte Navigation-Liste
  Widget _buildExpandedView(List<NavigationAction> actions) {
    return DynamicComponents.frame(
      title: _contextTitle,
      padding: const EdgeInsets.all(AppSpacing.sm),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 🔼 Collapse Header
          GestureDetector(
            onTap: _toggleExpanded,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
              child: Row(
                children: [
                  Icon(
                    _contextIcon,
                    color: Theme.of(context).colorScheme.primary,
                    size: 20,
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Text(
                      _contextTitle,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ),
                  Icon(
                    Icons.keyboard_arrow_up,
                    color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                    size: 20,
                  ),
                ],
              ),
            ),
          ),
          
          if (actions.isNotEmpty) ...[
            // 🌟 Divider
            Divider(
              color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.3),
              height: 1,
              thickness: 1,
            ),
            const SizedBox(height: AppSpacing.sm),
            
            // 🧭 Navigation Actions als DynamicComponents Buttons
            ...actions.map((action) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: SizedBox(
                width: double.infinity,
                child: action.isActive
                  ? DynamicComponents.primaryButton(
                      text: action.label,
                      onPressed: () {
                        action.onTap();
                        _toggleExpanded();
                      },
                      icon: action.icon,
                      isLoading: false,
                      size: AppButtonSize.medium,
                    )
                  : DynamicComponents.secondaryButton(
                      text: action.label,
                      onPressed: () {
                        action.onTap();
                        _toggleExpanded();
                      },
                      icon: action.icon,
                      size: AppButtonSize.medium,
                    ),
              ),
            )),
          ],
        ],
      ),
    );
  }
  
} 