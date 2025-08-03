import 'package:flutter/material.dart';
// REMOVED: import '../../core/providers/theme_context_provider.dart'; // DEPRECATED - using Theme.of(context)

/// ➖ App Divider Variants based on Schema Configuration
enum AppDividerVariant {
  /// Standard horizontal divider
  horizontal,
  /// Vertical divider
  vertical,
  /// Gradient divider with fade effect
  gradient,
  /// Magic divider with glow animation
  magic,
  /// Section divider with extra spacing
  section,
}

/// ➖ App Divider based on Schema Configuration
/// 
/// Visual divider component with gradient effects, animation, and schema-based styling
class AppDivider extends StatefulWidget {
  final AppDividerVariant variant;
  final double? thickness;
  final double? height;
  final double? width;
  final double? indent;
  final double? endIndent;
  final Color? color;
  final bool animated;
  final bool showGradient;
  final Duration animationDuration;

  const AppDivider({
    super.key,
    this.variant = AppDividerVariant.horizontal,
    this.thickness,
    this.height,
    this.width,
    this.indent,
    this.endIndent,
    this.color,
    this.animated = false,
    this.showGradient = true,
    this.animationDuration = const Duration(milliseconds: 1000),
  });

  /// Horizontal divider
  const AppDivider.horizontal({
    super.key,
    this.thickness,
    this.height,
    this.indent,
    this.endIndent,
    this.color,
    this.animated = false,
    this.showGradient = true,
    this.animationDuration = const Duration(milliseconds: 1000),
  }) : variant = AppDividerVariant.horizontal,
       width = null;

  /// Vertical divider
  const AppDivider.vertical({
    super.key,
    this.thickness,
    this.width,
    this.indent,
    this.endIndent,
    this.color,
    this.animated = false,
    this.showGradient = true,
    this.animationDuration = const Duration(milliseconds: 1000),
  }) : variant = AppDividerVariant.vertical,
       height = null;

  /// Gradient divider with fade effect
  const AppDivider.gradient({
    super.key,
    this.thickness,
    this.height,
    this.indent,
    this.endIndent,
    this.color,
    this.animated = false,
    this.animationDuration = const Duration(milliseconds: 1000),
  }) : variant = AppDividerVariant.gradient,
       showGradient = true,
       width = null;

  /// Magic divider with glow animation
  const AppDivider.magic({
    super.key,
    this.thickness,
    this.height,
    this.indent,
    this.endIndent,
    this.color,
    this.animationDuration = const Duration(milliseconds: 2000),
  }) : variant = AppDividerVariant.magic,
       animated = true,
       showGradient = true,
       width = null;

  /// Section divider with extra spacing
  const AppDivider.section({
    super.key,
    this.thickness,
    this.indent,
    this.endIndent,
    this.color,
    this.animated = false,
    this.showGradient = true,
    this.animationDuration = const Duration(milliseconds: 1000),
  }) : variant = AppDividerVariant.section,
       height = 40.0,
       width = null;

  @override
  State<AppDivider> createState() => _AppDividerState();
}

class _AppDividerState extends State<AppDivider> with SingleTickerProviderStateMixin {
  AnimationController? _animationController;
  Animation<double>? _opacityAnimation;

  @override
  void initState() {
    super.initState();
    
    if (widget.animated) {
      _animationController = AnimationController(
        duration: widget.animationDuration,
        vsync: this,
      );
      
      _opacityAnimation = Tween<double>(
        begin: 0.3,
        end: 1.0,
      ).animate(CurvedAnimation(
        parent: _animationController!,
        curve: Curves.easeInOut,
      ));

      _animationController!.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _animationController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // 🎯 NEUE KONTEXTSENSITIVE THEME-BEREITSTELLUNG
    return _buildDivider(context, Theme.of(context), null);
  }

  Widget _buildDivider(BuildContext context, ThemeData theme, Map<String, dynamic>? extensions) {
    
    if (widget.animated && _animationController != null) {
      return AnimatedBuilder(
        animation: _animationController!,
        builder: (context, child) {
          return _buildDividerContent(theme, extensions);
        },
      );
    }
    
    return _buildDividerContent(theme, extensions);
  }

  Widget _buildDividerContent(ThemeData theme, Map<String, dynamic>? extensions) {
    switch (widget.variant) {
      case AppDividerVariant.horizontal:
        return _buildHorizontalDivider(theme, extensions);
      case AppDividerVariant.vertical:
        return _buildVerticalDivider(theme, extensions);
      case AppDividerVariant.gradient:
        return _buildGradientDivider(theme, extensions);
      case AppDividerVariant.magic:
        return _buildMagicDivider(theme, extensions);
      case AppDividerVariant.section:
        return _buildSectionDivider(theme, extensions);
    }
  }

  /// Build horizontal divider
  Widget _buildHorizontalDivider(ThemeData theme, Map<String, dynamic>? extensions) {
    if (widget.showGradient) {
      return Container(
        height: _getHeight(),
        margin: EdgeInsets.only(
          left: _getIndent(),
          right: _getEndIndent(),
        ),
        child: Center(
          child: Container(
            height: _getThickness(),
            decoration: BoxDecoration(
              gradient: _getGradient(theme, extensions, true),
            ),
          ),
        ),
      );
    }

    return Divider(
      thickness: _getThickness(),
      height: _getHeight(),
      indent: _getIndent(),
      endIndent: _getEndIndent(),
      color: _getColor(theme, extensions),
    );
  }

  /// Build vertical divider
  Widget _buildVerticalDivider(ThemeData theme, Map<String, dynamic>? extensions) {
    if (widget.showGradient) {
      return Container(
        width: _getWidth(),
        margin: EdgeInsets.only(
          top: _getIndent(),
          bottom: _getEndIndent(),
        ),
        child: Center(
          child: Container(
            width: _getThickness(),
            decoration: BoxDecoration(
              gradient: _getGradient(theme, extensions, false),
            ),
          ),
        ),
      );
    }

    return VerticalDivider(
      thickness: _getThickness(),
      width: _getWidth(),
      indent: _getIndent(),
      endIndent: _getEndIndent(),
      color: _getColor(theme, extensions),
    );
  }

  /// Build gradient divider with fade effect
  Widget _buildGradientDivider(ThemeData theme, Map<String, dynamic>? extensions) {
    return Container(
      height: _getHeight(),
      margin: EdgeInsets.only(
        left: _getIndent(),
        right: _getEndIndent(),
      ),
      child: Center(
        child: Container(
          height: _getThickness(),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.transparent,
                _getColor(theme, extensions),
                Colors.transparent,
              ],
              stops: const [0.0, 0.5, 1.0],
            ),
          ),
        ),
      ),
    );
  }

  /// Build magic divider with glow animation
  Widget _buildMagicDivider(ThemeData theme, Map<String, dynamic>? extensions) {
    final glowIntensity = _opacityAnimation?.value ?? 1.0;
    final dividerColor = _getColor(theme, extensions);
    
    return Container(
      height: _getHeight(),
      margin: EdgeInsets.only(
        left: _getIndent(),
        right: _getEndIndent(),
      ),
      child: Center(
        child: Container(
          height: _getThickness(),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.transparent,
                dividerColor.withValues(alpha: 0.3 * glowIntensity),
                dividerColor.withValues(alpha: glowIntensity),
                dividerColor.withValues(alpha: 0.3 * glowIntensity),
                Colors.transparent,
              ],
              stops: const [0.0, 0.25, 0.5, 0.75, 1.0],
            ),
            boxShadow: [
              BoxShadow(
                color: dividerColor.withValues(alpha: 0.5 * glowIntensity),
                blurRadius: 4 * glowIntensity,
                spreadRadius: 1 * glowIntensity,
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Build section divider with extra spacing
  Widget _buildSectionDivider(ThemeData theme, Map<String, dynamic>? extensions) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: _getHeight() / 4),
      child: _buildGradientDivider(theme, extensions),
    );
  }

  /// Get gradient for divider
  LinearGradient _getGradient(ThemeData theme, Map<String, dynamic>? extensions, bool isHorizontal) {
    final colors = [
      Colors.transparent,
      _getColor(theme, extensions),
      Colors.transparent,
    ];

    if (isHorizontal) {
      return LinearGradient(colors: colors);
    } else {
      return LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: colors,
      );
    }
  }

  /// Get divider color from schema and theme
  Color _getColor(ThemeData theme, Map<String, dynamic>? extensions) {
    if (widget.color != null) return widget.color!;
    
    // Try to get magic gradient color from extensions
    if (extensions != null && extensions.containsKey('magicGradient')) {
      final colors = extensions['magicGradient'] as List<dynamic>?;
      if (colors != null && colors.isNotEmpty) {
        final color = _parseColor(colors.first.toString());
        if (color != null) {
          return color.withValues(alpha: _getOpacity());
        }
      }
    }
    
    return theme.colorScheme.outline.withValues(alpha: _getOpacity());
  }

  /// Get thickness from schema
  double _getThickness() {
    return widget.thickness ?? 1.0; // Schema default
  }

  /// Get height from schema
  double _getHeight() {
    return widget.height ?? 20.0; // Schema default
  }

  /// Get width from schema
  double _getWidth() {
    return widget.width ?? 20.0; // Schema default for vertical
  }

  /// Get indent from schema
  double _getIndent() {
    return widget.indent ?? 0.0; // Schema default
  }

  /// Get end indent from schema
  double _getEndIndent() {
    return widget.endIndent ?? 0.0; // Schema default
  }

  /// Get opacity from schema
  double _getOpacity() {
    return 0.3; // Schema default
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