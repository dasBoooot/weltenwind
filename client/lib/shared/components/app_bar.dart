import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/services/modular_theme_service.dart';

/// 📱 Fantasy AppBar Variants based on Theme Schema
enum AppAppBarVariant {
  /// Standard app bar
  standard,
  /// Large app bar with expanded title
  large,
  /// Magic app bar with glow effects
  magic,
  /// Portal app bar with aqua effects
  portal,
  /// Artifact app bar with golden effects
  artifact,
  /// Transparent overlay app bar
  transparent,
}

/// 📱 Weltenwind Schema-Based Fantasy AppBar
/// 
/// AppBar component built from JSON Theme Schema appBar configuration
class AppAppBar extends StatefulWidget implements PreferredSizeWidget {
  final String? title;
  final Widget? titleWidget;
  final AppAppBarVariant variant;
  final List<Widget>? actions;
  final Widget? leading;
  final bool automaticallyImplyLeading;
  final PreferredSizeWidget? bottom;
  final VoidCallback? onBackPressed;
  final bool showBackButton;

  const AppAppBar({
    super.key,
    this.title,
    this.titleWidget,
    this.variant = AppAppBarVariant.standard,
    this.actions,
    this.leading,
    this.automaticallyImplyLeading = true,
    this.bottom,
    this.onBackPressed,
    this.showBackButton = true,
  });

  @override
  State<AppAppBar> createState() => _AppAppBarState();

  @override
  Size get preferredSize {
    final double height = _getAppBarHeight();
    final double bottomHeight = bottom?.preferredSize.height ?? 0.0;
    return Size.fromHeight(height + bottomHeight);
  }

  double _getAppBarHeight() {
    switch (variant) {
      case AppAppBarVariant.large:
        return 120.0;
      default:
        return kToolbarHeight;
    }
  }
}

class _AppAppBarState extends State<AppAppBar> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();
    
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );
    
    _glowAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    // Start glow animation for fantasy variants
    if (_shouldAnimate()) {
      _animationController.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  bool _shouldAnimate() {
    return widget.variant == AppAppBarVariant.magic ||
           widget.variant == AppAppBarVariant.portal ||
           widget.variant == AppAppBarVariant.artifact;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final extensions = ModularThemeService().getCurrentThemeExtensions();
    
    return AnimatedBuilder(
      animation: _glowAnimation,
      builder: (context, child) {
        return Container(
          decoration: _getContainerDecoration(theme, extensions),
          child: AppBar(
            // Title
            title: widget.titleWidget ?? (widget.title != null 
                ? Text(
                    widget.title!,
                    style: _getTitleStyle(theme),
                  )
                : null),
            
            // Configuration from schema
            centerTitle: _getCenterTitle(), // Schema default: true
            elevation: _getElevation(), // Schema default: 0
            scrolledUnderElevation: _getElevation(),
            
            // Colors
            backgroundColor: _getBackgroundColor(theme),
            foregroundColor: _getForegroundColor(theme),
            surfaceTintColor: _getSurfaceTintColor(theme), // Schema default: transparent
            shadowColor: _getShadowColor(theme), // Schema default: transparent
            
            // System overlay
            systemOverlayStyle: _getSystemOverlayStyle(), // Schema default: dark
            
            // Navigation
            leading: widget.leading ?? (widget.showBackButton ? _buildBackButton(theme) : null),
            automaticallyImplyLeading: widget.automaticallyImplyLeading,
            actions: widget.actions,
            
            // Bottom
            bottom: widget.bottom,
            
            // Flexibility
            flexibleSpace: widget.variant == AppAppBarVariant.large 
                ? _buildFlexibleSpace(theme, extensions)
                : null,
          ),
        );
      },
    );
  }

  /// Container decoration for fantasy glow effects
  BoxDecoration? _getContainerDecoration(ThemeData theme, Map<String, dynamic>? extensions) {
    if (!_shouldAnimate()) return null;
    
    final glowColor = _getGlowColor(theme);
    final glowIntensity = 0.1 + (0.3 * _glowAnimation.value);
    
    return BoxDecoration(
      boxShadow: [
        BoxShadow(
          color: glowColor.withValues(alpha: glowIntensity),
          blurRadius: 8 + (12 * _glowAnimation.value),
          spreadRadius: 0 + (2 * _glowAnimation.value),
          offset: const Offset(0, 2),
        ),
      ],
    );
  }

  /// Flexible space for large variant
  Widget? _buildFlexibleSpace(ThemeData theme, Map<String, dynamic>? extensions) {
    return FlexibleSpaceBar(
      background: Container(
        decoration: BoxDecoration(
          gradient: _getBackgroundGradient(theme, extensions),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (widget.title != null)
                  Text(
                    widget.title!,
                    style: theme.textTheme.headlineMedium?.copyWith(
                      color: _getForegroundColor(theme),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Back button
  Widget _buildBackButton(ThemeData theme) {
    return IconButton(
      icon: Icon(
        Icons.arrow_back,
        color: _getForegroundColor(theme),
      ),
      onPressed: widget.onBackPressed ?? () => Navigator.of(context).pop(),
    );
  }

  /// Center title from schema
  bool _getCenterTitle() {
    return true; // Schema default: true
  }

  /// Elevation from schema
  double _getElevation() {
    return 0.0; // Schema default: 0
  }

  /// Background color based on variant
  Color? _getBackgroundColor(ThemeData theme) {
    switch (widget.variant) {
      case AppAppBarVariant.transparent:
        return Colors.transparent;
      case AppAppBarVariant.magic:
        return theme.colorScheme.primaryContainer.withValues(alpha: 0.9);
      case AppAppBarVariant.portal:
        return theme.colorScheme.tertiaryContainer.withValues(alpha: 0.9);
      case AppAppBarVariant.artifact:
        return theme.colorScheme.secondaryContainer.withValues(alpha: 0.9);
      default:
        return theme.colorScheme.surface;
    }
  }

  /// Foreground color
  Color _getForegroundColor(ThemeData theme) {
    switch (widget.variant) {
      case AppAppBarVariant.transparent:
        return theme.colorScheme.onSurface;
      case AppAppBarVariant.magic:
        return theme.colorScheme.onPrimaryContainer;
      case AppAppBarVariant.portal:
        return theme.colorScheme.onTertiaryContainer;
      case AppAppBarVariant.artifact:
        return theme.colorScheme.onSecondaryContainer;
      default:
        return theme.colorScheme.onSurface;
    }
  }

  /// Surface tint color from schema
  Color _getSurfaceTintColor(ThemeData theme) {
    return Colors.transparent; // Schema default: transparent
  }

  /// Shadow color from schema
  Color _getShadowColor(ThemeData theme) {
    return Colors.transparent; // Schema default: transparent
  }

  /// System overlay style from schema
  SystemUiOverlayStyle _getSystemOverlayStyle() {
    // Schema default: dark
    return SystemUiOverlayStyle.dark;
  }

  /// Glow color for fantasy variants
  Color _getGlowColor(ThemeData theme) {
    switch (widget.variant) {
      case AppAppBarVariant.magic:
        return theme.colorScheme.primary;
      case AppAppBarVariant.portal:
        return theme.colorScheme.tertiary;
      case AppAppBarVariant.artifact:
        return theme.colorScheme.secondary;
      default:
        return theme.colorScheme.primary;
    }
  }

  /// Background gradient for fantasy variants
  LinearGradient? _getBackgroundGradient(ThemeData theme, Map<String, dynamic>? extensions) {
    switch (widget.variant) {
      case AppAppBarVariant.magic:
        if (extensions != null && extensions.containsKey('magicGradient')) {
          final colors = (extensions['magicGradient'] as List<dynamic>)
              .map((color) => _parseColor(color.toString())?.withValues(alpha: 0.8) ?? 
                   theme.colorScheme.primary.withValues(alpha: 0.8))
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
            theme.colorScheme.primary.withValues(alpha: 0.8),
            theme.colorScheme.primaryContainer.withValues(alpha: 0.6),
          ],
        );
      case AppAppBarVariant.portal:
        if (extensions != null && extensions.containsKey('portalGradient')) {
          final colors = (extensions['portalGradient'] as List<dynamic>)
              .map((color) => _parseColor(color.toString())?.withValues(alpha: 0.8) ?? 
                   theme.colorScheme.tertiary.withValues(alpha: 0.8))
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
            theme.colorScheme.tertiary.withValues(alpha: 0.8),
            theme.colorScheme.tertiaryContainer.withValues(alpha: 0.6),
          ],
        );
      default:
        return null;
    }
  }

  /// Title style
  TextStyle _getTitleStyle(ThemeData theme) {
    return theme.textTheme.titleLarge?.copyWith(
      color: _getForegroundColor(theme),
      fontWeight: FontWeight.w600,
    ) ?? TextStyle(
      color: _getForegroundColor(theme),
      fontWeight: FontWeight.w600,
      fontSize: 20,
    );
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