import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../theme/app_theme.dart';
import '../../l10n/app_localizations.dart';

class NavigationWidget extends StatefulWidget {
  final String? currentRoute;
  final Map<String, dynamic>? routeParams;
  final bool? isJoinedWorld; // Ob der User in der aktuellen Welt registriert ist
  
  const NavigationWidget({
    super.key,
    this.currentRoute,
    this.routeParams,
    this.isJoinedWorld,
  });

  @override
  State<NavigationWidget> createState() => _NavigationWidgetState();
}

class _NavigationWidgetState extends State<NavigationWidget> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  bool _isExpanded = false;
  
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
  
  void _showJoinRequiredMessage() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(AppLocalizations.of(context).navigationJoinRequiredMessage),
        backgroundColor: Colors.orange[700],
        duration: const Duration(seconds: 3),
      ),
    );
  }
  
  List<NavigationItem> _getNavigationItems() {
    final items = <NavigationItem>[];
    
    // Zurück-Button (wenn nicht auf world-list)
    if (widget.currentRoute != 'world-list') {
      items.add(NavigationItem(
        icon: Icons.arrow_back,
        label: AppLocalizations.of(context).navigationBack,
        onTap: () => Navigator.of(context).canPop() 
          ? Navigator.of(context).pop()
          : context.goNamed('world-list'),
      ));
      
      items.add(NavigationItem(
        icon: Icons.remove,
        label: '',
        onTap: () {},
        isDivider: true,
      ));
    }
    
    // Immer zur Welten-Liste
    items.add(NavigationItem(
      icon: Icons.public,
              label: AppLocalizations.of(context).navigationWorldOverview,
      onTap: () => context.goNamed('world-list'),
      isActive: widget.currentRoute == 'world-list',
    ));
    
    // Welt-Details anzeigen (von Dashboard oder wenn auf Join-Page)
    if ((widget.currentRoute == 'world-dashboard' || widget.currentRoute == 'world-join') 
        && widget.routeParams?['id'] != null) {
      final worldIdParam = widget.routeParams?['id'];
      if (worldIdParam != null) {
        items.add(NavigationItem(
          icon: Icons.info_outline,
          label: AppLocalizations.of(context).navigationWorldDetails,
          onTap: () => context.goNamed('world-join', 
            pathParameters: {'id': worldIdParam.toString()}
          ),
          isActive: widget.currentRoute == 'world-join',
        ));
      }
    }
    
    // Dashboard Link - nur aktiv wenn User in der Welt ist
    if ((widget.currentRoute == 'world-join' || widget.currentRoute == 'world-dashboard') 
        && widget.routeParams?['id'] != null) {
      final worldIdParam = widget.routeParams?['id'];
      if (worldIdParam != null) {
        final worldId = worldIdParam.toString();
        final isJoined = widget.isJoinedWorld ?? false;
        
        items.add(NavigationItem(
          icon: Icons.dashboard,
          label: isJoined ? AppLocalizations.of(context).navigationDashboard : AppLocalizations.of(context).navigationDashboardRequiresJoin,
          onTap: isJoined 
            ? () => context.goNamed('world-dashboard', pathParameters: {'id': worldId})
            : () => _showJoinRequiredMessage(),
          isActive: widget.currentRoute == 'world-dashboard',
          isDisabled: !isJoined,
        ));
      }
    }
    
    // Weitere Navigation Items können hier hinzugefügt werden
    // z.B. Settings, Profile, etc.
    
    return items;
  }
  
  @override
  Widget build(BuildContext context) {
    final navItems = _getNavigationItems();
    
    return Positioned(
      top: 16,
      right: 16,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          decoration: BoxDecoration(
            color: const Color(0xFF1A1A1A).withOpacity(0.95),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: AppTheme.primaryColor.withOpacity(0.3),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: _isExpanded ? _buildExpandedView(navItems) : _buildCompactView(),
          ),
        ),
      ),
    );
  }
  
  Widget _buildCompactView() {
    return InkWell(
      onTap: _toggleExpanded,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.explore,
                color: AppTheme.primaryColor,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  AppLocalizations.of(context).navigationTitle,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  AppLocalizations.of(context).navigationOpenMenu,
                  style: TextStyle(
                    color: Colors.grey[400],
                    fontSize: 12,
                  ),
                ),
              ],
            ),
            const SizedBox(width: 12),
            Icon(
              Icons.keyboard_arrow_down,
              color: Colors.grey[400],
              size: 24,
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildExpandedView(List<NavigationItem> items) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        InkWell(
          onTap: _toggleExpanded,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(16),
            topRight: Radius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.explore,
                    color: AppTheme.primaryColor,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  AppLocalizations.of(context).navigationTitle,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 40),
                Icon(
                  Icons.keyboard_arrow_up,
                  color: Colors.grey[400],
                  size: 24,
                ),
              ],
            ),
          ),
        ),
        
        const Divider(color: Colors.grey, height: 1),
        
        // Navigation Items
        ...items.map((item) => _buildNavigationItem(item)),
      ],
    );
  }
  
  Widget _buildNavigationItem(NavigationItem item) {
    if (item.isDivider) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 4),
        child: Divider(color: Colors.grey, height: 1),
      );
    }
    
    final isActive = item.isActive;
    final isDisabled = item.isDisabled;
    
    final widget = InkWell(
      onTap: isDisabled ? null : () {
        item.onTap();
        if (!isDisabled) _toggleExpanded();
      },
      child: Container(
        width: 220,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isActive ? AppTheme.primaryColor.withOpacity(0.1) : Colors.transparent,
          border: Border(
            left: BorderSide(
              color: isActive ? AppTheme.primaryColor : Colors.transparent,
              width: 3,
            ),
          ),
        ),
        child: Row(
          children: [
            Icon(
              item.icon,
              color: isDisabled 
                ? Colors.grey[600] 
                : (isActive ? AppTheme.primaryColor : Colors.grey[400]),
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                item.label,
                style: TextStyle(
                  color: isDisabled 
                    ? Colors.grey[600] 
                    : (isActive ? AppTheme.primaryColor : Colors.white),
                  fontSize: 14,
                  fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
                  decoration: isDisabled ? TextDecoration.lineThrough : null,
                ),
              ),
            ),
            if (isActive && !isDisabled)
              const Icon(
                Icons.check_circle,
                color: AppTheme.primaryColor,
                size: 16,
              ),
            if (isDisabled)
              Icon(
                Icons.lock,
                color: Colors.grey[600],
                size: 16,
              ),
          ],
        ),
      ),
    );
    
    // Tooltip hinzufügen wenn disabled
    if (isDisabled && item.label.contains('Dashboard')) {
      return Tooltip(
        message: AppLocalizations.of(context).navigationTooltipJoinRequired,
        child: widget,
      );
    }
    
    return widget;
  }
}

class NavigationItem {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool isActive;
  final bool isDivider;
  final bool isDisabled;
  
  NavigationItem({
    required this.icon,
    required this.label,
    required this.onTap,
    this.isActive = false,
    this.isDivider = false,
    this.isDisabled = false,
  });
} 