import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
// REMOVED: import '../../core/providers/theme_context_provider.dart'; // DEPRECATED - using Theme.of(context)

/// 🎴 Fantasy Card Variants based on Theme Schema
enum AppCardVariant {
  /// Standard card with surface colors
  standard,
  /// Elevated card with shadows
  elevated,
  /// Fantasy magic card with glow effects
  magic,
  /// Portal card with aqua effects
  portal,
  /// Artifact card with golden effects
  artifact,
  /// Outlined card with border only
  outlined,
  /// Glass morphism effect
  glass,
  /// Game inventory slot card
  inventorySlot,
}

/// 🎨 Weltenwind Schema-Based Fantasy Card
/// 
/// Completely rebuilt based on JSON Theme Schema with ModularThemeService integration
class AppCard extends StatefulWidget {
  final Widget child;
  final AppCardVariant variant;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final double? width;
  final double? height;
  final Color? customColor;
  final bool isSelected;
  final bool isHoverable;

  const AppCard({
    super.key,
    required this.child,
    this.variant = AppCardVariant.standard,
    this.padding,
    this.margin,
    this.onTap,
    this.onLongPress,
    this.width,
    this.height,
    this.customColor,
    this.isSelected = false,
    this.isHoverable = true,
  });

  @override
  State<AppCard> createState() => _AppCardState();
}

class _AppCardState extends State<AppCard> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.98,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    if (widget.onTap != null) {
      _animationController.forward();
    }
  }

  void _handleTapUp(TapUpDetails details) {
    _animationController.reverse();
  }

  void _handleTapCancel() {
    _animationController.reverse();
  }

  void _handleHoverEnter(PointerEnterEvent event) {
    if (widget.isHoverable) {
      setState(() => _isHovered = true);
    }
  }

  void _handleHoverExit(PointerExitEvent event) {
    if (widget.isHoverable) {
      setState(() => _isHovered = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    // 🎯 SMART NAVIGATION THEME: Verwendet globales Theme
    return _buildCard(context, Theme.of(context), null);
  }

  Widget _buildCard(BuildContext context, ThemeData theme, Map<String, dynamic>? extensions) {
    return MouseRegion(
      onEnter: _handleHoverEnter,
      onExit: _handleHoverExit,
      child: GestureDetector(
        onTapDown: _handleTapDown,
        onTapUp: _handleTapUp,
        onTapCancel: _handleTapCancel,
        onTap: widget.onTap,
        onLongPress: widget.onLongPress,
        child: ScaleTransition(
          scale: _scaleAnimation,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: widget.width,
            height: widget.height,
            margin: widget.margin ?? _getDefaultMargin(theme),
            decoration: _getDecoration(theme, extensions),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(_getBorderRadius(theme)),
              child: Material(
                color: Colors.transparent,
                child: Padding(
                  padding: widget.padding ?? _getDefaultPadding(theme),
                  child: widget.child,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Get decoration based on schema and fantasy extensions
  BoxDecoration _getDecoration(ThemeData theme, Map<String, dynamic>? extensions) {
    return BoxDecoration(
      color: _getBackgroundColor(theme, extensions),
      borderRadius: BorderRadius.circular(_getBorderRadius(theme)),
      border: _getBorder(theme),
      gradient: _getGradient(theme, extensions),
      boxShadow: _getShadows(theme, extensions),
    );
  }

  /// Background color based on variant and theme
  Color? _getBackgroundColor(ThemeData theme, Map<String, dynamic>? extensions) {
    if (widget.customColor != null) {
      return widget.customColor;
    }

    switch (widget.variant) {
      case AppCardVariant.standard:
      case AppCardVariant.elevated:
        return theme.colorScheme.surface;
      case AppCardVariant.outlined:
        return Colors.transparent;
      case AppCardVariant.glass:
        return theme.colorScheme.surface.withValues(alpha: 0.1);
      case AppCardVariant.magic:
        return theme.colorScheme.primaryContainer.withValues(alpha: 0.3);
      case AppCardVariant.portal:
        return theme.colorScheme.tertiaryContainer.withValues(alpha: 0.3);
      case AppCardVariant.artifact:
        return theme.colorScheme.secondaryContainer.withValues(alpha: 0.3);
      case AppCardVariant.inventorySlot:
        // Try to get from gaming schema
        return theme.colorScheme.surfaceContainerHighest;
    }
  }

  /// Border based on variant and selection state
  Border? _getBorder(ThemeData theme) {
    switch (widget.variant) {
      case AppCardVariant.outlined:
        return Border.all(
          color: widget.isSelected 
              ? theme.colorScheme.primary 
              : theme.colorScheme.outline,
          width: widget.isSelected ? 2.0 : 1.0,
        );
      case AppCardVariant.inventorySlot:
        return Border.all(
          color: widget.isSelected 
              ? theme.colorScheme.primary 
              : theme.colorScheme.outline.withValues(alpha: 0.5),
          width: 2.0,
        );
      default:
        if (widget.isSelected) {
          return Border.all(
            color: theme.colorScheme.primary,
            width: 2.0,
          );
        }
        return null;
    }
  }

  /// Fantasy gradients from extensions
  Gradient? _getGradient(ThemeData theme, Map<String, dynamic>? extensions) {
    switch (widget.variant) {
      case AppCardVariant.magic:
        if (extensions != null && extensions.containsKey('magicGradient')) {
          final colors = (extensions['magicGradient'] as List<dynamic>)
              .map((color) => _parseColor(color.toString())?.withValues(alpha: 0.2) ?? 
                   theme.colorScheme.primary.withValues(alpha: 0.2))
              .toList();
          return LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: colors,
          );
        }
        return LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            theme.colorScheme.primary.withValues(alpha: 0.1),
            theme.colorScheme.primaryContainer.withValues(alpha: 0.2),
          ],
        );
      case AppCardVariant.portal:
        if (extensions != null && extensions.containsKey('portalGradient')) {
          final colors = (extensions['portalGradient'] as List<dynamic>)
              .map((color) => _parseColor(color.toString())?.withValues(alpha: 0.2) ?? 
                   theme.colorScheme.tertiary.withValues(alpha: 0.2))
              .toList();
          return LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: colors,
          );
        }
        return LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            theme.colorScheme.tertiary.withValues(alpha: 0.1),
            theme.colorScheme.tertiaryContainer.withValues(alpha: 0.2),
          ],
        );
      case AppCardVariant.glass:
        return LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            theme.colorScheme.surface.withValues(alpha: 0.1),
            theme.colorScheme.surface.withValues(alpha: 0.05),
          ],
        );
      default:
        return null;
    }
  }

  /// Fantasy shadows and glow effects
  List<BoxShadow> _getShadows(ThemeData theme, Map<String, dynamic>? extensions) {
    final baseElevation = _getElevation(theme);
    
    switch (widget.variant) {
      case AppCardVariant.elevated:
        return [
          BoxShadow(
            color: theme.colorScheme.shadow.withValues(alpha: 0.1),
            blurRadius: baseElevation * 2,
            spreadRadius: 0,
            offset: Offset(0, baseElevation / 2),
          ),
        ];
      case AppCardVariant.magic:
        final glowIntensity = _isHovered ? 1.0 : 0.6;
        return [
          BoxShadow(
            color: theme.colorScheme.primary.withValues(alpha: 0.3 * glowIntensity),
            blurRadius: _isHovered ? 16 : 12,
            spreadRadius: _isHovered ? 2 : 1,
            offset: const Offset(0, 2),
          ),
          BoxShadow(
            color: theme.colorScheme.shadow.withValues(alpha: 0.1),
            blurRadius: 8,
            spreadRadius: 0,
            offset: const Offset(0, 4),
          ),
        ];
      case AppCardVariant.portal:
        final glowIntensity = _isHovered ? 1.0 : 0.6;
        return [
          BoxShadow(
            color: theme.colorScheme.tertiary.withValues(alpha: 0.3 * glowIntensity),
            blurRadius: _isHovered ? 16 : 12,
            spreadRadius: _isHovered ? 2 : 1,
            offset: const Offset(0, 2),
          ),
        ];
      case AppCardVariant.artifact:
        final glowIntensity = _isHovered ? 1.0 : 0.6;
        return [
          BoxShadow(
            color: theme.colorScheme.secondary.withValues(alpha: 0.3 * glowIntensity),
            blurRadius: _isHovered ? 14 : 10,
            spreadRadius: _isHovered ? 1 : 0,
            offset: const Offset(0, 2),
          ),
        ];
      case AppCardVariant.glass:
        return [
          BoxShadow(
            color: theme.colorScheme.shadow.withValues(alpha: 0.05),
            blurRadius: 20,
            spreadRadius: 0,
            offset: const Offset(0, 8),
          ),
        ];
      case AppCardVariant.inventorySlot:
        if (widget.isSelected) {
          return [
            BoxShadow(
              color: theme.colorScheme.primary.withValues(alpha: 0.4),
              blurRadius: 8,
              spreadRadius: 1,
              offset: const Offset(0, 2),
            ),
          ];
        }
        return [
          BoxShadow(
            color: theme.colorScheme.shadow.withValues(alpha: 0.1),
            blurRadius: 4,
            spreadRadius: 0,
            offset: const Offset(0, 2),
          ),
        ];
      default:
        return [];
    }
  }

  /// Border radius from schema components.card configuration
  double _getBorderRadius(ThemeData theme) {
    // TODO: Get from schema - for now use reasonable defaults
    switch (widget.variant) {
      case AppCardVariant.inventorySlot:
        return 8.0;
      default:
        return 16.0;
    }
  }

  /// Elevation from schema components.card configuration
  double _getElevation(ThemeData theme) {
    // TODO: Get from schema - for now use reasonable defaults
    switch (widget.variant) {
      case AppCardVariant.elevated:
        return 4.0;
      case AppCardVariant.magic:
      case AppCardVariant.portal:
      case AppCardVariant.artifact:
        return 6.0;
      default:
        return 0.0;
    }
  }

  /// Default margin from schema
  EdgeInsetsGeometry _getDefaultMargin(ThemeData theme) {
    // TODO: Get from schema components.card.margin
    return const EdgeInsets.all(4.0);
  }

  /// Default padding from schema  
  EdgeInsetsGeometry _getDefaultPadding(ThemeData theme) {
    switch (widget.variant) {
      case AppCardVariant.inventorySlot:
        return const EdgeInsets.all(8.0);
      default:
        return const EdgeInsets.all(16.0);
    }
  }

  /// Helper: Parse color from hex string
  Color? _parseColor(String colorString) {
    if (colorString.startsWith('#')) {
      final hex = colorString.replaceAll('#', '');
      if (hex.length == 6) {
        return Color(int.parse('FF$hex', radix: 16));
      }
    }
    return null;
  }
}