import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math' as math;
import '../../core/providers/theme_context_provider.dart';

/// 📑 Tab Item Model
class AppTab {
  final String id;
  final String label;
  final IconData? icon;
  final Widget? customIcon;
  final int? badgeCount;
  final bool showBadge;
  final bool enabled;
  final Color? color;
  final Color? activeColor;

  const AppTab({
    required this.id,
    required this.label,
    this.icon,
    this.customIcon,
    this.badgeCount,
    this.showBadge = false,
    this.enabled = true,
    this.color,
    this.activeColor,
  });
}

/// 📑 Tab Bar Variants
enum AppTabBarVariant {
  standard,
  material,
  cupertino,
  custom,
}

/// 📑 Indicator Types
enum TabIndicatorType {
  underline,
  background,
  border,
  glow,
  none,
}

/// 📑 App Tab Bar based on Tab Bar Schema
/// 
/// Comprehensive tab bar with badges, animations, and schema-based configuration
class AppTabBar extends StatefulWidget {
  final List<AppTab> tabs;
  final int selectedIndex;
  final ValueChanged<int>? onTabChanged;
  final AppTabBarVariant variant;
  final TabIndicatorType indicatorType;
  final bool isScrollable;
  final bool showBadges;
  final double? height;
  final EdgeInsetsGeometry? padding;
  final Color? backgroundColor;
  final Color? indicatorColor;
  final Color? selectedLabelColor;
  final Color? unselectedLabelColor;
  final TextStyle? labelStyle;
  final TextStyle? unselectedLabelStyle;
  final bool animateIndicator;
  final Duration animationDuration;
  
  // 🦾 Accessibility Parameters
  final String? semanticLabel;
  final String? semanticHint;

  const AppTabBar({
    super.key,
    required this.tabs,
    required this.selectedIndex,
    this.onTabChanged,
    this.variant = AppTabBarVariant.standard,
    this.indicatorType = TabIndicatorType.underline,
    this.isScrollable = false,
    this.showBadges = true,
    this.height,
    this.padding,
    this.backgroundColor,
    this.indicatorColor,
    this.selectedLabelColor,
    this.unselectedLabelColor,
    this.labelStyle,
    this.unselectedLabelStyle,
    this.animateIndicator = true,
    this.animationDuration = const Duration(milliseconds: 250),
    // 🦾 Accessibility
    this.semanticLabel,
    this.semanticHint,
  });

  /// Standard tab bar
  const AppTabBar.standard({
    super.key,
    required this.tabs,
    required this.selectedIndex,
    this.onTabChanged,
    this.isScrollable = false,
    this.showBadges = true,
    this.height,
    this.padding,
    this.backgroundColor,
    this.indicatorColor,
    this.selectedLabelColor,
    this.unselectedLabelColor,
    this.labelStyle,
    this.unselectedLabelStyle,
    this.animateIndicator = true,
    this.animationDuration = const Duration(milliseconds: 250),
    // 🦾 Accessibility
    this.semanticLabel,
    this.semanticHint,
  }) : variant = AppTabBarVariant.standard,
       indicatorType = TabIndicatorType.underline;

  /// Material tab bar
  const AppTabBar.material({
    super.key,
    required this.tabs,
    required this.selectedIndex,
    this.onTabChanged,
    this.isScrollable = false,
    this.showBadges = true,
    this.height,
    this.padding,
    this.backgroundColor,
    this.indicatorColor,
    this.selectedLabelColor,
    this.unselectedLabelColor,
    this.labelStyle,
    this.unselectedLabelStyle,
    this.animateIndicator = true,
    this.animationDuration = const Duration(milliseconds: 250),
    // 🦾 Accessibility
    this.semanticLabel,
    this.semanticHint,
  }) : variant = AppTabBarVariant.material,
       indicatorType = TabIndicatorType.underline;

  /// Background indicator tab bar
  const AppTabBar.background({
    super.key,
    required this.tabs,
    required this.selectedIndex,
    this.onTabChanged,
    this.isScrollable = false,
    this.showBadges = true,
    this.height,
    this.padding,
    this.backgroundColor,
    this.indicatorColor,
    this.selectedLabelColor,
    this.unselectedLabelColor,
    this.labelStyle,
    this.unselectedLabelStyle,
    this.animateIndicator = true,
    this.animationDuration = const Duration(milliseconds: 250),
    // 🦾 Accessibility
    this.semanticLabel,
    this.semanticHint,
  }) : variant = AppTabBarVariant.custom,
       indicatorType = TabIndicatorType.background;

  /// Glow indicator tab bar
  const AppTabBar.glow({
    super.key,
    required this.tabs,
    required this.selectedIndex,
    this.onTabChanged,
    this.isScrollable = false,
    this.showBadges = true,
    this.height,
    this.padding,
    this.backgroundColor,
    this.indicatorColor,
    this.selectedLabelColor,
    this.unselectedLabelColor,
    this.labelStyle,
    this.unselectedLabelStyle,
    this.animateIndicator = true,
    this.animationDuration = const Duration(milliseconds: 250),
    // 🦾 Accessibility
    this.semanticLabel,
    this.semanticHint,
  }) : variant = AppTabBarVariant.custom,
       indicatorType = TabIndicatorType.glow;

  @override
  State<AppTabBar> createState() => _AppTabBarState();
}

class _AppTabBarState extends State<AppTabBar> with TickerProviderStateMixin {
  late AnimationController _indicatorController;
  late Animation<double> _indicatorAnimation;
  late TabController _tabController;
  
  // 🦾 Keyboard navigation
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    
    _tabController = TabController(
      length: widget.tabs.length,
      initialIndex: widget.selectedIndex,
      vsync: this,
    );
    
    // Indicator animation
    _indicatorController = AnimationController(
      duration: widget.animationDuration,
      vsync: this,
    );
    
    _indicatorAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _indicatorController,
      curve: Curves.easeOut,
    ));

    _indicatorController.forward();
  }

  @override
  void didUpdateWidget(AppTabBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    if (widget.selectedIndex != oldWidget.selectedIndex) {
      _tabController.animateTo(widget.selectedIndex);
      
      if (widget.animateIndicator) {
        _indicatorController.forward(from: 0.0);
      }
    }
  }

  @override
  void dispose() {
    _indicatorController.dispose();
    _tabController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onTabTapped(int index) {
    if (widget.tabs[index].enabled) {
      widget.onTabChanged?.call(index);
    }
  }

  @override
  Widget build(BuildContext context) {
    // 🎯 NEUE KONTEXTSENSITIVE THEME-BEREITSTELLUNG
    return ThemeContextConsumer(
      componentName: 'AppTabBar',
      contextOverrides: {
        'variant': widget.variant.name,
        'currentTab': 'default',
        'hasIndicator': (widget.indicatorType != TabIndicatorType.none).toString(),
      },
      builder: (context, contextTheme, extensions) {
        return _buildTabBarContent(context, contextTheme, extensions);
      },
    );
  }

  Widget _buildTabBarContent(BuildContext context, ThemeData theme, Map<String, dynamic>? extensions) {
    return Semantics(
      label: _getSemanticLabel(),
      hint: _getSemanticHint(),
      enabled: widget.onTabChanged != null,
      child: KeyboardListener(
        focusNode: _focusNode,
        onKeyEvent: (event) {
          _handleKeyEvent(event);
        },
        child: Container(
          height: widget.height ?? _getHeight(),
          padding: widget.padding ?? EdgeInsets.all(_getPadding()),
          decoration: _getTabBarDecoration(theme, extensions),
          child: _buildTabBar(theme, extensions),
        ),
      ),
    );
  }

  Widget _buildTabBar(ThemeData theme, Map<String, dynamic>? extensions) {
    switch (widget.variant) {
      case AppTabBarVariant.material:
        return _buildMaterialTabBar(theme, extensions);
      case AppTabBarVariant.cupertino:
        return _buildCupertinoTabBar(theme, extensions);
      case AppTabBarVariant.custom:
        return _buildCustomTabBar(theme, extensions);
      case AppTabBarVariant.standard:
        return _buildStandardTabBar(theme, extensions);
    }
  }

  Widget _buildStandardTabBar(ThemeData theme, Map<String, dynamic>? extensions) {
    return TabBar(
      controller: _tabController,
      isScrollable: widget.isScrollable,
      indicatorColor: _getIndicatorColor(theme, extensions),
      indicatorWeight: _getIndicatorThickness(),
      labelColor: _getSelectedLabelColor(theme, extensions),
      unselectedLabelColor: _getUnselectedLabelColor(theme, extensions),
      labelStyle: _getLabelStyle(theme),
      unselectedLabelStyle: _getUnselectedLabelStyle(theme),
      onTap: _onTabTapped,
      tabs: widget.tabs.asMap().entries.map((entry) {
        final index = entry.key;
        final tab = entry.value;
        return _buildTab(tab, index, theme, extensions);
      }).toList(),
    );
  }

  Widget _buildMaterialTabBar(ThemeData theme, Map<String, dynamic>? extensions) {
    return Material(
      color: Colors.transparent,
      child: TabBar(
        controller: _tabController,
        isScrollable: widget.isScrollable,
        indicator: _getCustomDecoration(theme, extensions),
        labelColor: _getSelectedLabelColor(theme, extensions),
        unselectedLabelColor: _getUnselectedLabelColor(theme, extensions),
        labelStyle: _getLabelStyle(theme),
        unselectedLabelStyle: _getUnselectedLabelStyle(theme),
        onTap: _onTabTapped,
        tabs: widget.tabs.asMap().entries.map((entry) {
          final index = entry.key;
          final tab = entry.value;
          return _buildTab(tab, index, theme, extensions);
        }).toList(),
      ),
    );
  }

  Widget _buildCupertinoTabBar(ThemeData theme, Map<String, dynamic>? extensions) {
    return Row(
      children: widget.tabs.asMap().entries.map((entry) {
        final index = entry.key;
        final tab = entry.value;
        final isSelected = index == widget.selectedIndex;
        
        return Expanded(
          child: GestureDetector(
            onTap: () => _onTabTapped(index),
            child: Container(
              height: _getTabHeight(),
              decoration: BoxDecoration(
                color: isSelected 
                    ? _getSelectedBackgroundColor(theme, extensions)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(_getBorderRadius()),
              ),
              child: _buildTabContent(tab, index, isSelected, theme, extensions),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildCustomTabBar(ThemeData theme, Map<String, dynamic>? extensions) {
    return Stack(
      children: [
        // Custom indicator
        if (widget.indicatorType != TabIndicatorType.none)
          AnimatedBuilder(
            animation: _indicatorAnimation,
            builder: (context, child) {
              return _buildAnimatedIndicator(theme, extensions);
            },
          ),
        
        // Tabs
        Row(
          children: widget.tabs.asMap().entries.map((entry) {
            final index = entry.key;
            final tab = entry.value;
            
            return Expanded(
              child: GestureDetector(
                onTap: () => _onTabTapped(index),
                child: SizedBox(
                  height: _getTabHeight(),
                  child: _buildTabContent(tab, index, index == widget.selectedIndex, theme, extensions),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildTab(AppTab tab, int index, ThemeData theme, Map<String, dynamic>? extensions) {
    return Tab(
      child: _buildTabContent(tab, index, index == widget.selectedIndex, theme, extensions),
    );
  }

  Widget _buildTabContent(AppTab tab, int index, bool isSelected, ThemeData theme, Map<String, dynamic>? extensions) {
    return Stack(
      children: [
        // Tab content
        Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Icon
              if (tab.customIcon != null || tab.icon != null) ...[
                AnimatedScale(
                  scale: isSelected ? _getActiveScale() : _getDefaultScale(),
                  duration: widget.animationDuration,
                  child: AnimatedOpacity(
                    opacity: tab.enabled 
                        ? (isSelected ? _getActiveOpacity() : _getDefaultOpacity())
                        : _getDisabledOpacity(),
                    duration: widget.animationDuration,
                    child: tab.customIcon ?? Icon(
                      tab.icon,
                      size: _getIconSize(),
                      color: isSelected 
                          ? (tab.activeColor ?? _getSelectedLabelColor(theme, extensions))
                          : (tab.color ?? _getUnselectedLabelColor(theme, extensions)),
                    ),
                  ),
                ),
                const SizedBox(height: 4),
              ],
              
              // Label
              AnimatedDefaultTextStyle(
                style: isSelected 
                    ? _getLabelStyle(theme).copyWith(
                        color: tab.activeColor ?? _getSelectedLabelColor(theme, extensions),
                        fontWeight: _getActiveFontWeight(),
                      )
                    : _getUnselectedLabelStyle(theme).copyWith(
                        color: tab.color ?? _getUnselectedLabelColor(theme, extensions),
                      ),
                duration: widget.animationDuration,
                child: AnimatedOpacity(
                  opacity: tab.enabled 
                      ? (isSelected ? _getActiveOpacity() : _getDefaultOpacity())
                      : _getDisabledOpacity(),
                  duration: widget.animationDuration,
                  child: Text(
                    tab.label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
            ],
          ),
        ),
        
        // Badge
        if (widget.showBadges && (tab.showBadge || (tab.badgeCount != null && tab.badgeCount! > 0)))
          _buildBadge(tab, theme, extensions),
        
        // Glow effect for selected tab
        if (isSelected && widget.indicatorType == TabIndicatorType.glow)
          _buildGlowEffect(theme, extensions),
      ],
    );
  }

  Widget _buildBadge(AppTab tab, ThemeData theme, Map<String, dynamic>? extensions) {
    return Positioned(
      top: 0,
      right: 0,
      child: AnimatedScale(
        scale: tab.showBadge || (tab.badgeCount != null && tab.badgeCount! > 0) ? 1.0 : 0.0,
        duration: widget.animationDuration,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: BoxDecoration(
            color: theme.colorScheme.error,
            borderRadius: BorderRadius.circular(_getBadgeSize() / 2),
          ),
          constraints: BoxConstraints(
            minWidth: _getBadgeSize(),
            minHeight: _getBadgeSize(),
          ),
          child: Center(
            child: tab.badgeCount != null && tab.badgeCount! > 0
                ? Text(
                    tab.badgeCount! > _getMaxBadgeCount() 
                        ? '${_getMaxBadgeCount()}+'
                        : tab.badgeCount.toString(),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onError,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  )
                : null,
          ),
        ),
      ),
    );
  }

  Widget _buildGlowEffect(ThemeData theme, Map<String, dynamic>? extensions) {
    return Positioned.fill(
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(_getBorderRadius()),
          boxShadow: [
            BoxShadow(
              color: _getIndicatorColor(theme, extensions).withValues(alpha: 0.3),
              blurRadius: 8,
              spreadRadius: 2,
            ),
          ],
        ),
      ),
    );
  }

  /// Get custom decoration for TabBar indicator
  Decoration _getCustomDecoration(ThemeData theme, Map<String, dynamic>? extensions) {
    switch (widget.indicatorType) {
      case TabIndicatorType.background:
        return BoxDecoration(
          color: _getIndicatorColor(theme, extensions).withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(_getBorderRadius()),
        );
      
      case TabIndicatorType.border:
        return BoxDecoration(
          border: Border.all(
            color: _getIndicatorColor(theme, extensions),
            width: _getIndicatorThickness(),
          ),
          borderRadius: BorderRadius.circular(_getBorderRadius()),
        );
      
      case TabIndicatorType.underline:
        return UnderlineTabIndicator(
          borderSide: BorderSide(
            color: _getIndicatorColor(theme, extensions),
            width: _getIndicatorThickness(),
          ),
        );
      
      case TabIndicatorType.glow:
        return BoxDecoration(
          color: _getIndicatorColor(theme, extensions).withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(_getBorderRadius()),
          boxShadow: [
            BoxShadow(
              color: _getIndicatorColor(theme, extensions).withValues(alpha: 0.4),
              blurRadius: 8,
              spreadRadius: 2,
            ),
          ],
        );
      
      case TabIndicatorType.none:
        return const BoxDecoration(); // Empty decoration
    }
  }

  Widget _buildAnimatedIndicator(ThemeData theme, Map<String, dynamic>? extensions) {
    final tabWidth = _getResponsiveTabWidth(context);
    final indicatorWidth = tabWidth * 0.6; // 60% of tab width
    final indicatorOffset = (widget.selectedIndex * tabWidth) + (tabWidth - indicatorWidth) / 2;
    
    return AnimatedPositioned(
      duration: widget.animationDuration,
      left: indicatorOffset,
      bottom: 0,
      child: Container(
        width: indicatorWidth,
        height: _getIndicatorThickness(),
        decoration: BoxDecoration(
          color: _getIndicatorColor(theme, extensions),
          borderRadius: BorderRadius.circular(_getIndicatorThickness() / 2),
        ),
      ),
    );
  }

  /// Get tab bar decoration
  BoxDecoration _getTabBarDecoration(ThemeData theme, Map<String, dynamic>? extensions) {
    return BoxDecoration(
      color: widget.backgroundColor ?? theme.colorScheme.surface,
      border: Border(
        bottom: BorderSide(
          color: theme.colorScheme.outline.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
    );
  }

  /// Get indicator color
  Color _getIndicatorColor(ThemeData theme, Map<String, dynamic>? extensions) {
    if (widget.indicatorColor != null) return widget.indicatorColor!;
    
    // Try to get magic gradient color from extensions
    if (extensions != null && extensions.containsKey('magicGradient')) {
      final colors = extensions['magicGradient'] as List<dynamic>?;
      if (colors != null && colors.isNotEmpty) {
        final color = _parseColor(colors.first.toString());
        if (color != null) return color;
      }
    }
    
    return theme.colorScheme.primary;
  }

  /// Get selected label color
  Color _getSelectedLabelColor(ThemeData theme, Map<String, dynamic>? extensions) {
    if (widget.selectedLabelColor != null) return widget.selectedLabelColor!;
    return _getIndicatorColor(theme, extensions);
  }

  /// Get unselected label color
  Color _getUnselectedLabelColor(ThemeData theme, Map<String, dynamic>? extensions) {
    if (widget.unselectedLabelColor != null) return widget.unselectedLabelColor!;
    return theme.colorScheme.onSurfaceVariant;
  }

  /// Get selected background color
  Color _getSelectedBackgroundColor(ThemeData theme, Map<String, dynamic>? extensions) {
    return _getIndicatorColor(theme, extensions).withValues(alpha: 0.1);
  }

  /// Get label style
  TextStyle _getLabelStyle(ThemeData theme) {
    return widget.labelStyle ?? theme.textTheme.bodyMedium?.copyWith(
      fontWeight: FontWeight.w500,
    ) ?? const TextStyle(fontWeight: FontWeight.w500);
  }

  /// Get unselected label style
  TextStyle _getUnselectedLabelStyle(ThemeData theme) {
    return widget.unselectedLabelStyle ?? theme.textTheme.bodyMedium ?? const TextStyle();
  }

  // Schema-based getters
  double _getHeight() => 48.0; // Schema default
  double _getTabHeight() => 40.0; // Schema default
  double _getPadding() => 4.0; // Schema default
  double _getBorderRadius() => 8.0; // Schema default
  double _getIconSize() => 20.0; // Schema default
  double _getIndicatorThickness() => 2.0; // Schema default
  double _getBadgeSize() => 16.0; // Schema default
  int _getMaxBadgeCount() => 99; // Schema default
  
  double _getDefaultOpacity() => 0.7; // Schema default
  double _getActiveOpacity() => 1.0; // Schema default
  double _getDisabledOpacity() => 0.4; // Schema default
  double _getDefaultScale() => 1.0; // Schema default
  double _getActiveScale() => 1.0; // Schema default
  FontWeight _getActiveFontWeight() => FontWeight.w600; // Schema default

  /// 🔥 RESPONSIVE FIX: Calculate responsive tab width with minimum touch targets
  double _getResponsiveTabWidth(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final availableWidth = screenWidth - (widget.padding?.horizontal ?? (_getPadding() * 2));
    
    // Define minimum tab widths based on screen size
    double minTabWidth;
    if (screenWidth < 600) {
      minTabWidth = 80.0; // Mobile: 80px minimum
    } else if (screenWidth < 900) {
      minTabWidth = 100.0; // Tablet: 100px minimum
    } else {
      minTabWidth = 120.0; // Desktop: 120px minimum
    }
    
    // Calculate ideal width (divide available width by tab count)
    final idealTabWidth = availableWidth / widget.tabs.length;
    
    // Return the maximum of minimum width and ideal width
    return math.max(minTabWidth, idealTabWidth);
  }

  /// Helper: Parse color from hex string
  Color? _parseColor(String colorString) {
    if (colorString.startsWith('#')) {
      final hex = colorString.replaceAll('#', '');
      if (hex.length == 6) {
        return Color(int.parse('FF$hex', radix: 16));
      } else if (hex.length == 8) {
        return Color(int.parse(hex, radix: 16));
      }
    }
    return null;
  }

  /// 🦾 ACCESSIBILITY FIX: Handle keyboard navigation
  void _handleKeyEvent(KeyEvent event) {
    if (event is KeyDownEvent) {
              switch (event.logicalKey) {
        case LogicalKeyboardKey.arrowLeft:
          _navigateLeft();
          break;
        case LogicalKeyboardKey.arrowRight:
          _navigateRight();
          break;
        case LogicalKeyboardKey.home:
          _navigateToFirst();
          break;
        case LogicalKeyboardKey.end:
          _navigateToLast();
          break;
      }
    }
  }

  /// Navigate to previous tab
  void _navigateLeft() {
    int newIndex = widget.selectedIndex - 1;
    while (newIndex >= 0 && !widget.tabs[newIndex].enabled) {
      newIndex--;
    }
    if (newIndex >= 0) {
      widget.onTabChanged?.call(newIndex);
    }
  }

  /// Navigate to next tab
  void _navigateRight() {
    int newIndex = widget.selectedIndex + 1;
    while (newIndex < widget.tabs.length && !widget.tabs[newIndex].enabled) {
      newIndex++;
    }
    if (newIndex < widget.tabs.length) {
      widget.onTabChanged?.call(newIndex);
    }
  }

  /// Navigate to first enabled tab
  void _navigateToFirst() {
    for (int i = 0; i < widget.tabs.length; i++) {
      if (widget.tabs[i].enabled) {
        widget.onTabChanged?.call(i);
        break;
      }
    }
  }

  /// Navigate to last enabled tab
  void _navigateToLast() {
    for (int i = widget.tabs.length - 1; i >= 0; i--) {
      if (widget.tabs[i].enabled) {
        widget.onTabChanged?.call(i);
        break;
      }
    }
  }

  /// Get semantic label for tab bar
  String _getSemanticLabel() {
    if (widget.semanticLabel != null) return widget.semanticLabel!;
    
    final currentTab = widget.tabs[widget.selectedIndex];
    return 'Tab bar, ${currentTab.label} selected';
  }

  /// Get semantic hint for tab bar
  String? _getSemanticHint() {
    if (widget.semanticHint != null) return widget.semanticHint!;
    
    List<String> hints = [];
    
    final enabledTabs = widget.tabs.where((tab) => tab.enabled).length;
    hints.add('$enabledTabs tabs available');
    
    hints.add('Use left and right arrow keys to navigate');
    
    return hints.join(', ');
  }
}

/// 📑 Tab Bar Helpers
class TabBarHelpers {
  /// Create world category tabs
  static List<AppTab> worldCategories() {
    return [
      const AppTab(
        id: 'all',
        label: 'All',
        icon: Icons.public,
      ),
      const AppTab(
        id: 'fantasy',
        label: 'Fantasy',
        icon: Icons.auto_awesome,
        color: Colors.purple,
        activeColor: Colors.purple,
      ),
      const AppTab(
        id: 'scifi',
        label: 'Sci-Fi',
        icon: Icons.rocket_launch,
        color: Colors.blue,
        activeColor: Colors.blue,
      ),
      const AppTab(
        id: 'modern',
        label: 'Modern',
        icon: Icons.location_city,
        color: Colors.grey,
        activeColor: Colors.grey,
      ),
    ];
  }

  /// Create user dashboard tabs
  static List<AppTab> userDashboard() {
    return [
      const AppTab(
        id: 'overview',
        label: 'Overview',
        icon: Icons.dashboard,
      ),
      const AppTab(
        id: 'worlds',
        label: 'Worlds',
        icon: Icons.public,
        badgeCount: 3,
        showBadge: true,
      ),
      const AppTab(
        id: 'friends',
        label: 'Friends',
        icon: Icons.people,
        badgeCount: 12,
        showBadge: true,
      ),
      const AppTab(
        id: 'settings',
        label: 'Settings',
        icon: Icons.settings,
      ),
    ];
  }

  /// Create game mode tabs
  static List<AppTab> gameModes() {
    return [
      const AppTab(
        id: 'explore',
        label: 'Explore',
        icon: Icons.explore,
      ),
      const AppTab(
        id: 'build',
        label: 'Build',
        icon: Icons.construction,
      ),
      const AppTab(
        id: 'fight',
        label: 'Fight',
        icon: Icons.sports_kabaddi,
      ),
      const AppTab(
        id: 'trade',
        label: 'Trade',
        icon: Icons.store,
      ),
    ];
  }
}