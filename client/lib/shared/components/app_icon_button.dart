import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/services/modular_theme_service.dart';

/// 🔘 Icon Button Sizes
enum AppIconButtonSize {
  small,
  medium,
  large,
}

/// 🔘 Icon Button Shapes
enum AppIconButtonShape {
  circle,
  square,
  rounded,
}

/// 🔘 Icon Button Variants
enum AppIconButtonVariant {
  filled,
  outlined,
  ghost,
  tonal,
}

/// 🔘 App Icon Button based on Schema Configuration
/// 
/// Schema-based icon button with variants, animations, and fantasy styling
class AppIconButton extends StatefulWidget {
  final IconData icon;
  final Widget? customIcon;
  final VoidCallback? onPressed;
  final VoidCallback? onLongPress;
  final AppIconButtonSize size;
  final AppIconButtonShape shape;
  final AppIconButtonVariant variant;
  final Color? color;
  final Color? backgroundColor;
  final Color? focusColor;
  final Color? hoverColor;
  final Color? splashColor;
  final bool showTooltip;
  final String? tooltip;
  final bool rippleEffect;
  final bool glowOnHover;
  final Duration animationDuration;
  final double? iconSize;
  final EdgeInsetsGeometry? padding;
  final BoxConstraints? constraints;
  final bool autofocus;
  final FocusNode? focusNode;

  const AppIconButton({
    super.key,
    required this.icon,
    this.customIcon,
    required this.onPressed,
    this.onLongPress,
    this.size = AppIconButtonSize.medium,
    this.shape = AppIconButtonShape.circle,
    this.variant = AppIconButtonVariant.ghost,
    this.color,
    this.backgroundColor,
    this.focusColor,
    this.hoverColor,
    this.splashColor,
    this.showTooltip = false,
    this.tooltip,
    this.rippleEffect = true,
    this.glowOnHover = false,
    this.animationDuration = const Duration(milliseconds: 200),
    this.iconSize,
    this.padding,
    this.constraints,
    this.autofocus = false,
    this.focusNode,
  });

  /// Small icon button
  const AppIconButton.small({
    super.key,
    required this.icon,
    this.customIcon,
    required this.onPressed,
    this.onLongPress,
    this.shape = AppIconButtonShape.circle,
    this.variant = AppIconButtonVariant.ghost,
    this.color,
    this.backgroundColor,
    this.focusColor,
    this.hoverColor,
    this.splashColor,
    this.showTooltip = false,
    this.tooltip,
    this.rippleEffect = true,
    this.glowOnHover = false,
    this.animationDuration = const Duration(milliseconds: 200),
    this.iconSize,
    this.padding,
    this.constraints,
    this.autofocus = false,
    this.focusNode,
  }) : size = AppIconButtonSize.small;

  /// Medium icon button
  const AppIconButton.medium({
    super.key,
    required this.icon,
    this.customIcon,
    required this.onPressed,
    this.onLongPress,
    this.shape = AppIconButtonShape.circle,
    this.variant = AppIconButtonVariant.ghost,
    this.color,
    this.backgroundColor,
    this.focusColor,
    this.hoverColor,
    this.splashColor,
    this.showTooltip = false,
    this.tooltip,
    this.rippleEffect = true,
    this.glowOnHover = false,
    this.animationDuration = const Duration(milliseconds: 200),
    this.iconSize,
    this.padding,
    this.constraints,
    this.autofocus = false,
    this.focusNode,
  }) : size = AppIconButtonSize.medium;

  /// Large icon button
  const AppIconButton.large({
    super.key,
    required this.icon,
    this.customIcon,
    required this.onPressed,
    this.onLongPress,
    this.shape = AppIconButtonShape.circle,
    this.variant = AppIconButtonVariant.ghost,
    this.color,
    this.backgroundColor,
    this.focusColor,
    this.hoverColor,
    this.splashColor,
    this.showTooltip = false,
    this.tooltip,
    this.rippleEffect = true,
    this.glowOnHover = false,
    this.animationDuration = const Duration(milliseconds: 200),
    this.iconSize,
    this.padding,
    this.constraints,
    this.autofocus = false,
    this.focusNode,
  }) : size = AppIconButtonSize.large;

  /// Filled icon button
  const AppIconButton.filled({
    super.key,
    required this.icon,
    this.customIcon,
    required this.onPressed,
    this.onLongPress,
    this.size = AppIconButtonSize.medium,
    this.shape = AppIconButtonShape.circle,
    this.color,
    this.backgroundColor,
    this.focusColor,
    this.hoverColor,
    this.splashColor,
    this.showTooltip = false,
    this.tooltip,
    this.rippleEffect = true,
    this.glowOnHover = false,
    this.animationDuration = const Duration(milliseconds: 200),
    this.iconSize,
    this.padding,
    this.constraints,
    this.autofocus = false,
    this.focusNode,
  }) : variant = AppIconButtonVariant.filled;

  /// Outlined icon button
  const AppIconButton.outlined({
    super.key,
    required this.icon,
    this.customIcon,
    required this.onPressed,
    this.onLongPress,
    this.size = AppIconButtonSize.medium,
    this.shape = AppIconButtonShape.circle,
    this.color,
    this.backgroundColor,
    this.focusColor,
    this.hoverColor,
    this.splashColor,
    this.showTooltip = false,
    this.tooltip,
    this.rippleEffect = true,
    this.glowOnHover = false,
    this.animationDuration = const Duration(milliseconds: 200),
    this.iconSize,
    this.padding,
    this.constraints,
    this.autofocus = false,
    this.focusNode,
  }) : variant = AppIconButtonVariant.outlined;

  /// Tonal icon button
  const AppIconButton.tonal({
    super.key,
    required this.icon,
    this.customIcon,
    required this.onPressed,
    this.onLongPress,
    this.size = AppIconButtonSize.medium,
    this.shape = AppIconButtonShape.circle,
    this.color,
    this.backgroundColor,
    this.focusColor,
    this.hoverColor,
    this.splashColor,
    this.showTooltip = false,
    this.tooltip,
    this.rippleEffect = true,
    this.glowOnHover = false,
    this.animationDuration = const Duration(milliseconds: 200),
    this.iconSize,
    this.padding,
    this.constraints,
    this.autofocus = false,
    this.focusNode,
  }) : variant = AppIconButtonVariant.tonal;

  @override
  State<AppIconButton> createState() => _AppIconButtonState();
}

class _AppIconButtonState extends State<AppIconButton> with TickerProviderStateMixin {
  late AnimationController _hoverController;
  late AnimationController _glowController;
  
  late Animation<double> _scaleAnimation;
  late Animation<double> _glowAnimation;
  
  bool _isHovered = false;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    
    // Hover animation
    _hoverController = AnimationController(
      duration: widget.animationDuration,
      vsync: this,
    );
    
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.05,
    ).animate(CurvedAnimation(
      parent: _hoverController,
      curve: Curves.easeInOut,
    ));

    // Glow animation
    if (widget.glowOnHover) {
      _glowController = AnimationController(
        duration: const Duration(milliseconds: 1500),
        vsync: this,
      );
      
      _glowAnimation = Tween<double>(
        begin: 0.3,
        end: 1.0,
      ).animate(CurvedAnimation(
        parent: _glowController,
        curve: Curves.easeInOut,
      ));
    }
  }

  @override
  void dispose() {
    _hoverController.dispose();
    if (widget.glowOnHover) {
      _glowController.dispose();
    }
    super.dispose();
  }

  void _onEnter() {
    setState(() => _isHovered = true);
    _hoverController.forward();
    
    if (widget.glowOnHover) {
      _glowController.repeat(reverse: true);
    }
  }

  void _onExit() {
    setState(() => _isHovered = false);
    _hoverController.reverse();
    
    if (widget.glowOnHover) {
      _glowController.stop();
      _glowController.reset();
    }
  }

  void _onTapDown() {
    setState(() => _isPressed = true);
    
    // Haptic feedback
    if (widget.rippleEffect) {
      HapticFeedback.lightImpact();
    }
  }

  void _onTapUp() {
    setState(() => _isPressed = false);
  }

  void _onTapCancel() {
    setState(() => _isPressed = false);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final extensions = ModularThemeService().getCurrentThemeExtensions();
    
    Widget iconButton = AnimatedBuilder(
      animation: _hoverController,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: _buildButton(theme, extensions),
        );
      },
    );

    // Add glow effect
    if (widget.glowOnHover && _isHovered && _glowController != null) {
      iconButton = AnimatedBuilder(
        animation: _glowController,
        builder: (context, child) {
          return Container(
            decoration: BoxDecoration(
              shape: _getBoxShape(),
              borderRadius: _getBoxShape() == BoxShape.rectangle 
                  ? BorderRadius.circular(_getBorderRadius())
                  : null,
              boxShadow: [
                BoxShadow(
                  color: _getIconColor(theme, extensions).withValues(alpha: 0.3 * _glowAnimation.value),
                  blurRadius: 8 * _glowAnimation.value,
                  spreadRadius: 2 * _glowAnimation.value,
                ),
              ],
            ),
            child: iconButton,
          );
        },
      );
    }

    // Add tooltip
    if (widget.showTooltip && (widget.tooltip != null || widget.onPressed != null)) {
      iconButton = Tooltip(
        message: widget.tooltip ?? 'Button',
        child: iconButton,
      );
    }

    return iconButton;
  }

  Widget _buildButton(ThemeData theme, Map<String, dynamic>? extensions) {
    final buttonSize = _getButtonSize();
    
    return MouseRegion(
      onEnter: (_) => _onEnter(),
      onExit: (_) => _onExit(),
      child: GestureDetector(
        onTapDown: (_) => _onTapDown(),
        onTapUp: (_) => _onTapUp(),
        onTapCancel: _onTapCancel,
        onTap: widget.onPressed,
        onLongPress: widget.onLongPress,
        child: Container(
          width: buttonSize,
          height: buttonSize,
          constraints: widget.constraints,
          padding: widget.padding ?? EdgeInsets.all(_getPadding()),
          decoration: _getButtonDecoration(theme, extensions),
          child: Center(
            child: AnimatedScale(
              scale: _isPressed ? 0.9 : 1.0,
              duration: const Duration(milliseconds: 100),
              child: widget.customIcon ?? Icon(
                widget.icon,
                size: widget.iconSize ?? _getIconSize(),
                color: _getIconColor(theme, extensions),
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Get button decoration based on variant and state
  BoxDecoration _getButtonDecoration(ThemeData theme, Map<String, dynamic>? extensions) {
    Color? backgroundColor;
    Border? border;
    
    switch (widget.variant) {
      case AppIconButtonVariant.filled:
        backgroundColor = widget.backgroundColor ?? _getPrimaryColor(theme, extensions);
        break;
      
      case AppIconButtonVariant.outlined:
        backgroundColor = _isHovered 
            ? (widget.hoverColor ?? _getPrimaryColor(theme, extensions).withValues(alpha: 0.1))
            : Colors.transparent;
        border = Border.all(
          color: _getPrimaryColor(theme, extensions),
          width: 1.5,
        );
        break;
      
      case AppIconButtonVariant.tonal:
        backgroundColor = widget.backgroundColor ?? 
            _getPrimaryColor(theme, extensions).withValues(alpha: _isHovered ? 0.2 : 0.1);
        break;
      
      case AppIconButtonVariant.ghost:
      default:
        backgroundColor = _isHovered 
            ? (widget.hoverColor ?? theme.colorScheme.onSurface.withValues(alpha: 0.1))
            : Colors.transparent;
        break;
    }

    return BoxDecoration(
      color: backgroundColor,
      border: border,
      shape: _getBoxShape(),
      borderRadius: _getBoxShape() == BoxShape.rectangle 
          ? BorderRadius.circular(_getBorderRadius())
          : null,
      boxShadow: widget.variant == AppIconButtonVariant.filled ? [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.1),
          blurRadius: 2,
          offset: const Offset(0, 1),
        ),
      ] : null,
    );
  }

  /// Get icon color based on variant and state
  Color _getIconColor(ThemeData theme, Map<String, dynamic>? extensions) {
    if (widget.color != null) return widget.color!;
    
    switch (widget.variant) {
      case AppIconButtonVariant.filled:
        return theme.colorScheme.onPrimary;
      
      case AppIconButtonVariant.outlined:
      case AppIconButtonVariant.tonal:
        return _getPrimaryColor(theme, extensions);
      
      case AppIconButtonVariant.ghost:
      default:
        return theme.colorScheme.onSurface;
    }
  }

  /// Get primary color from theme or extensions
  Color _getPrimaryColor(ThemeData theme, Map<String, dynamic>? extensions) {
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

  /// Get box shape based on button shape
  BoxShape _getBoxShape() {
    switch (widget.shape) {
      case AppIconButtonShape.circle:
        return BoxShape.circle;
      case AppIconButtonShape.square:
      case AppIconButtonShape.rounded:
        return BoxShape.rectangle;
    }
  }

  /// Get border radius based on button shape
  double _getBorderRadius() {
    switch (widget.shape) {
      case AppIconButtonShape.circle:
        return 0; // Circle shape doesn't use border radius
      case AppIconButtonShape.square:
        return 0;
      case AppIconButtonShape.rounded:
        return _getButtonSize() / 4;
    }
  }

  /// Get button size based on size enum
  double _getButtonSize() {
    // 🔥 RESPONSIVE FIX: Minimum touch targets for accessibility
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;
    
    switch (widget.size) {
      case AppIconButtonSize.small:
        return isMobile ? 36.0 : 32.0; // Slightly larger on mobile
      case AppIconButtonSize.medium:
        return isMobile ? 44.0 : 48.0; // WCAG compliant 44px minimum on mobile
      case AppIconButtonSize.large:
        return isMobile ? 48.0 : 56.0; // Larger touch target on mobile
    }
  }

  /// Get icon size based on button size
  double _getIconSize() {
    switch (widget.size) {
      case AppIconButtonSize.small:
        return 16.0;
      case AppIconButtonSize.medium:
        return 20.0;
      case AppIconButtonSize.large:
        return 24.0;
    }
  }

  /// Get padding based on button size
  double _getPadding() {
    switch (widget.size) {
      case AppIconButtonSize.small:
        return 6.0;
      case AppIconButtonSize.medium:
        return 8.0;
      case AppIconButtonSize.large:
        return 10.0;
    }
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
}

/// 🔘 Icon Button Helpers
class IconButtonHelpers {
  /// Settings button
  static Widget settings({
    required VoidCallback onPressed,
    AppIconButtonSize size = AppIconButtonSize.medium,
    String? tooltip,
  }) {
    return AppIconButton(
      icon: Icons.settings,
      onPressed: onPressed,
      size: size,
      variant: AppIconButtonVariant.ghost,
      showTooltip: true,
      tooltip: tooltip ?? 'Settings',
    );
  }

  /// Close button
  static Widget close({
    required VoidCallback onPressed,
    AppIconButtonSize size = AppIconButtonSize.small,
    String? tooltip,
  }) {
    return AppIconButton(
      icon: Icons.close,
      onPressed: onPressed,
      size: size,
      variant: AppIconButtonVariant.ghost,
      showTooltip: true,
      tooltip: tooltip ?? 'Close',
    );
  }

  /// Back button
  static Widget back({
    required VoidCallback onPressed,
    AppIconButtonSize size = AppIconButtonSize.medium,
    String? tooltip,
  }) {
    return AppIconButton(
      icon: Icons.arrow_back,
      onPressed: onPressed,
      size: size,
      variant: AppIconButtonVariant.ghost,
      showTooltip: true,
      tooltip: tooltip ?? 'Back',
    );
  }

  /// Menu button
  static Widget menu({
    required VoidCallback onPressed,
    AppIconButtonSize size = AppIconButtonSize.medium,
    String? tooltip,
  }) {
    return AppIconButton(
      icon: Icons.menu,
      onPressed: onPressed,
      size: size,
      variant: AppIconButtonVariant.ghost,
      showTooltip: true,
      tooltip: tooltip ?? 'Menu',
    );
  }

  /// Search button
  static Widget search({
    required VoidCallback onPressed,
    AppIconButtonSize size = AppIconButtonSize.medium,
    String? tooltip,
  }) {
    return AppIconButton(
      icon: Icons.search,
      onPressed: onPressed,
      size: size,
      variant: AppIconButtonVariant.ghost,
      showTooltip: true,
      tooltip: tooltip ?? 'Search',
    );
  }

  /// Add/Create button
  static Widget add({
    required VoidCallback onPressed,
    AppIconButtonSize size = AppIconButtonSize.medium,
    String? tooltip,
  }) {
    return AppIconButton.filled(
      icon: Icons.add,
      onPressed: onPressed,
      size: size,
      showTooltip: true,
      tooltip: tooltip ?? 'Add',
    );
  }

  /// Edit button
  static Widget edit({
    required VoidCallback onPressed,
    AppIconButtonSize size = AppIconButtonSize.small,
    String? tooltip,
  }) {
    return AppIconButton(
      icon: Icons.edit,
      onPressed: onPressed,
      size: size,
      variant: AppIconButtonVariant.outlined,
      showTooltip: true,
      tooltip: tooltip ?? 'Edit',
    );
  }

  /// Delete button
  static Widget delete({
    required VoidCallback onPressed,
    AppIconButtonSize size = AppIconButtonSize.small,
    String? tooltip,
  }) {
    return AppIconButton(
      icon: Icons.delete_outline,
      onPressed: onPressed,
      size: size,
      variant: AppIconButtonVariant.ghost,
      color: Colors.red,
      showTooltip: true,
      tooltip: tooltip ?? 'Delete',
    );
  }

  /// Favorite toggle button
  static Widget favorite({
    required bool isFavorite,
    required VoidCallback onPressed,
    AppIconButtonSize size = AppIconButtonSize.medium,
    String? tooltip,
  }) {
    return AppIconButton(
      icon: isFavorite ? Icons.favorite : Icons.favorite_border,
      onPressed: onPressed,
      size: size,
      variant: AppIconButtonVariant.ghost,
      color: isFavorite ? Colors.red : null,
      showTooltip: true,
      tooltip: tooltip ?? (isFavorite ? 'Remove from favorites' : 'Add to favorites'),
    );
  }

  /// Share button
  static Widget share({
    required VoidCallback onPressed,
    AppIconButtonSize size = AppIconButtonSize.medium,
    String? tooltip,
  }) {
    return AppIconButton(
      icon: Icons.share,
      onPressed: onPressed,
      size: size,
      variant: AppIconButtonVariant.outlined,
      showTooltip: true,
      tooltip: tooltip ?? 'Share',
    );
  }

  /// Refresh button
  static Widget refresh({
    required VoidCallback onPressed,
    AppIconButtonSize size = AppIconButtonSize.medium,
    String? tooltip,
  }) {
    return AppIconButton(
      icon: Icons.refresh,
      onPressed: onPressed,
      size: size,
      variant: AppIconButtonVariant.ghost,
      showTooltip: true,
      tooltip: tooltip ?? 'Refresh',
    );
  }

  /// More options button
  static Widget moreOptions({
    required VoidCallback onPressed,
    AppIconButtonSize size = AppIconButtonSize.medium,
    String? tooltip,
  }) {
    return AppIconButton(
      icon: Icons.more_vert,
      onPressed: onPressed,
      size: size,
      variant: AppIconButtonVariant.ghost,
      showTooltip: true,
      tooltip: tooltip ?? 'More options',
    );
  }
}