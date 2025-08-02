import 'package:flutter/material.dart';
import 'accessibility_provider.dart';
import '../../../core/providers/theme_context_provider.dart';

/// 🎯 Focus Indicator Types from Accessibility Schema
enum FocusIndicatorType {
  outline,
  glow,
  underline,
  background,
  border,
}

/// 🎯 Focus Indicator based on Gaming Accessibility Schema
/// 
/// High-visibility focus indicators for keyboard navigation and motor disabilities
class FocusIndicator extends StatefulWidget {
  final Widget child;
  final FocusIndicatorType type;
  final bool isVisible;
  final Color? customColor;
  final double? customWidth;
  final bool animated;

  const FocusIndicator({
    super.key,
    required this.child,
    this.type = FocusIndicatorType.outline,
    this.isVisible = false,
    this.customColor,
    this.customWidth,
    this.animated = true,
  });

  @override
  State<FocusIndicator> createState() => _FocusIndicatorState();
}

class _FocusIndicatorState extends State<FocusIndicator> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    
    _animation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    if (widget.isVisible) {
      _animationController.forward();
    }
  }

  @override
  void didUpdateWidget(FocusIndicator oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    if (widget.isVisible != oldWidget.isVisible) {
      if (widget.isVisible) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.isVisible && !widget.animated) {
      return widget.child;
    }

    // 🎯 NEUE KONTEXTSENSITIVE THEME-BEREITSTELLUNG
    return ThemeContextConsumer(
      componentName: 'FocusIndicator',
      contextOverrides: {
        'type': widget.type.name,
        'visible': widget.isVisible.toString(),
        'animated': widget.animated.toString(),
      },
      builder: (context, contextTheme, extensions) {
        return _buildFocusIndicator(context, contextTheme, extensions);
      },
    );
  }

  Widget _buildFocusIndicator(BuildContext context, ThemeData theme, Map<String, dynamic>? extensions) {
    final accessibilityProvider = AccessibilityProviderWidget.of(context);
    
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return _buildIndicator(theme, accessibilityProvider);
      },
    );
  }

  Widget _buildIndicator(ThemeData theme, AccessibilityProvider? provider) {
    final sizeMultiplier = provider?.getFocusIndicatorSize() ?? 1.0;
    final shouldReduceMotion = provider?.shouldReduceMotion() ?? false;
    final animationValue = shouldReduceMotion ? (widget.isVisible ? 1.0 : 0.0) : _animation.value;
    
    switch (widget.type) {
      case FocusIndicatorType.outline:
        return _buildOutlineIndicator(theme, sizeMultiplier, animationValue);
      case FocusIndicatorType.glow:
        return _buildGlowIndicator(theme, sizeMultiplier, animationValue);
      case FocusIndicatorType.underline:
        return _buildUnderlineIndicator(theme, sizeMultiplier, animationValue);
      case FocusIndicatorType.background:
        return _buildBackgroundIndicator(theme, sizeMultiplier, animationValue);
      case FocusIndicatorType.border:
        return _buildBorderIndicator(theme, sizeMultiplier, animationValue);
    }
  }

  /// Build outline focus indicator
  Widget _buildOutlineIndicator(ThemeData theme, double sizeMultiplier, double animationValue) {
    final color = _getFocusColor(theme);
    final width = _getFocusWidth(sizeMultiplier);
    
    return Stack(
      children: [
        widget.child,
        if (animationValue > 0)
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(
                  color: color.withValues(alpha: animationValue),
                  width: width * animationValue,
                ),
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
      ],
    );
  }

  /// Build glow focus indicator
  Widget _buildGlowIndicator(ThemeData theme, double sizeMultiplier, double animationValue) {
    final color = _getFocusColor(theme);
    final glowRadius = 8.0 * sizeMultiplier;
    
    return Container(
      decoration: animationValue > 0 ? BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.3 * animationValue),
            blurRadius: glowRadius * animationValue,
            spreadRadius: 2 * animationValue,
          ),
          BoxShadow(
            color: color.withValues(alpha: 0.1 * animationValue),
            blurRadius: glowRadius * 2 * animationValue,
            spreadRadius: 4 * animationValue,
          ),
        ],
      ) : null,
      child: widget.child,
    );
  }

  /// Build underline focus indicator
  Widget _buildUnderlineIndicator(ThemeData theme, double sizeMultiplier, double animationValue) {
    final color = _getFocusColor(theme);
    final width = _getFocusWidth(sizeMultiplier);
    
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        widget.child,
        if (animationValue > 0)
          Container(
            height: width * animationValue,
            decoration: BoxDecoration(
              color: color.withValues(alpha: animationValue),
              borderRadius: BorderRadius.circular(width / 2),
            ),
          ),
      ],
    );
  }

  /// Build background focus indicator
  Widget _buildBackgroundIndicator(ThemeData theme, double sizeMultiplier, double animationValue) {
    final color = _getFocusColor(theme);
    
    return Container(
      decoration: animationValue > 0 ? BoxDecoration(
        color: color.withValues(alpha: 0.1 * animationValue),
        borderRadius: BorderRadius.circular(8),
      ) : null,
      child: widget.child,
    );
  }

  /// Build border focus indicator
  Widget _buildBorderIndicator(ThemeData theme, double sizeMultiplier, double animationValue) {
    final color = _getFocusColor(theme);
    final width = _getFocusWidth(sizeMultiplier);
    
    return Container(
      decoration: animationValue > 0 ? BoxDecoration(
        border: Border.all(
          color: color.withValues(alpha: animationValue),
          width: width * animationValue,
        ),
        borderRadius: BorderRadius.circular(8),
      ) : null,
      child: widget.child,
    );
  }

  /// Get focus indicator color
  Color _getFocusColor(ThemeData theme) {
    return widget.customColor ?? theme.colorScheme.primary;
  }

  /// Get focus indicator width with accessibility multiplier
  double _getFocusWidth(double sizeMultiplier) {
    final baseWidth = widget.customWidth ?? 3.0; // Schema default: increased from 2.0
    return baseWidth * sizeMultiplier;
  }
}

/// 🎯 Focus Wrapper Widget for automatic focus handling
class AccessibleFocusWrapper extends StatefulWidget {
  final Widget child;
  final FocusIndicatorType indicatorType;
  final bool autofocus;
  final ValueChanged<bool>? onFocusChange;

  const AccessibleFocusWrapper({
    super.key,
    required this.child,
    this.indicatorType = FocusIndicatorType.outline,
    this.autofocus = false,
    this.onFocusChange,
  });

  @override
  State<AccessibleFocusWrapper> createState() => _AccessibleFocusWrapperState();
}

class _AccessibleFocusWrapperState extends State<AccessibleFocusWrapper> {
  late FocusNode _focusNode;
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
    _focusNode.addListener(_onFocusChange);
  }

  @override
  void dispose() {
    _focusNode.removeListener(_onFocusChange);
    _focusNode.dispose();
    super.dispose();
  }

  void _onFocusChange() {
    setState(() {
      _isFocused = _focusNode.hasFocus;
    });
    widget.onFocusChange?.call(_isFocused);
  }

  @override
  Widget build(BuildContext context) {
    return Focus(
      focusNode: _focusNode,
      autofocus: widget.autofocus,
      child: FocusIndicator(
        type: widget.indicatorType,
        isVisible: _isFocused,
        child: widget.child,
      ),
    );
  }
}