/// 🎯 App Container Component
/// 
/// Professional container component with responsive design
library;

import 'package:flutter/material.dart';
import '../base/base_component.dart';

enum AppContainerType {
  normal,
  surface,
  elevated,
  outlined,
}

class AppContainer extends BaseComponent {
  const AppContainer({
    super.key,
    required this.child,
    this.type = AppContainerType.normal,
    this.padding,
    this.margin,
    this.width,
    this.height,
    this.constraints,
    this.alignment,
    this.backgroundColor,
    this.borderColor,
    this.borderRadius,
    this.elevation,
    this.clipBehavior = Clip.none,
    this.responsive = true,
  });

  final Widget child;
  final AppContainerType type;
  final EdgeInsets? padding;
  final EdgeInsets? margin;
  final double? width;
  final double? height;
  final BoxConstraints? constraints;
  final AlignmentGeometry? alignment;
  final Color? backgroundColor;
  final Color? borderColor;
  final BorderRadius? borderRadius;
  final double? elevation;
  final Clip clipBehavior;
  final bool responsive;

  @override
  Widget build(BuildContext context) {
    final colorScheme = getColorScheme(context);
    final isDark = isDarkMode(context);

    // Apply responsive constraints if enabled
    Widget container = _buildContainer(context, colorScheme, isDark);

    if (responsive) {
      final screenSize = getScreenSize(context);
      
      // Apply desktop constraints
      if (screenSize == ScreenSize.desktop && constraints == null) {
        container = ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800),
          child: container,
        );
      }
    }

    return container;
  }

  /// Build the container with decoration
  Widget _buildContainer(
    BuildContext context,
    ColorScheme colorScheme,
    bool isDark,
  ) {
    final decoration = _getContainerDecoration(context, colorScheme, isDark);
    final containerPadding = padding ?? _getDefaultPadding(context);
    final containerMargin = margin ?? _getDefaultMargin(context);

    return Container(
      width: width,
      height: height,
      constraints: constraints,
      alignment: alignment,
      margin: containerMargin,
      padding: containerPadding,
      decoration: decoration,
      clipBehavior: clipBehavior,
      child: child,
    );
  }

  /// Get container decoration based on type
  BoxDecoration _getContainerDecoration(
    BuildContext context,
    ColorScheme colorScheme,
    bool isDark,
  ) {
    final containerBorderRadius = borderRadius ?? getBorderRadius(context);

    switch (type) {
      case AppContainerType.normal:
        return BoxDecoration(
          color: backgroundColor ?? Colors.transparent,
          borderRadius: containerBorderRadius,
        );

      case AppContainerType.surface:
        return BoxDecoration(
          color: backgroundColor ?? colorScheme.surface,
          borderRadius: containerBorderRadius,
        );

      case AppContainerType.elevated:
        return BoxDecoration(
          color: backgroundColor ?? colorScheme.surface,
          borderRadius: containerBorderRadius,
          boxShadow: getShadow(
            context,
            elevation: elevation ?? getElevation(context),
          ),
        );

      case AppContainerType.outlined:
        return BoxDecoration(
          color: backgroundColor ?? colorScheme.surface,
          borderRadius: containerBorderRadius,
          border: Border.all(
            color: borderColor ?? colorScheme.outline.withValues(alpha: 0.5),
            width: 1.0,
          ),
        );
    }
  }

  /// Get default padding
  EdgeInsets _getDefaultPadding(BuildContext context) {
    if (!responsive) return EdgeInsets.zero;
    
    return getResponsivePadding(
      context,
      mobile: 16.0,
      tablet: 20.0,
      desktop: 24.0,
    );
  }

  /// Get default margin
  EdgeInsets _getDefaultMargin(BuildContext context) {
    return EdgeInsets.zero; // No default margin
  }
}

/// Section container for grouping related content
class AppSection extends AppContainer {
  const AppSection({
    super.key,
    required super.child,
    this.title,
    this.subtitle,
    this.titleActions,
    super.type = AppContainerType.surface,
    super.padding,
    super.margin,
    super.backgroundColor,
    super.borderRadius,
    super.elevation,
  });

  final Widget? title;
  final Widget? subtitle;
  final List<Widget>? titleActions;

  @override
  Widget build(BuildContext context) {
    final textTheme = getTextTheme(context);
    final colorScheme = getColorScheme(context);

    Widget content = child;

    // Add title and subtitle if provided
    if (title != null || subtitle != null) {
      content = Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          _buildSectionHeader(context, textTheme, colorScheme),
          const SizedBox(height: 16),
          
          // Content
          child,
        ],
      );
    }

    return AppContainer(
      type: type,
      padding: padding,
      margin: margin,
      backgroundColor: backgroundColor,
      borderRadius: borderRadius,
      elevation: elevation,
      child: content,
    );
  }

  /// Build section header
  Widget _buildSectionHeader(
    BuildContext context,
    TextTheme textTheme,
    ColorScheme colorScheme,
  ) {
    return Row(
      children: [
        // Title and subtitle
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (title != null)
                DefaultTextStyle(
                  style: textTheme.headlineSmall?.copyWith(
                    color: colorScheme.onSurface,
                    fontWeight: FontWeight.w600,
                  ) ?? const TextStyle(),
                  child: title!,
                ),
              if (subtitle != null) ...[
                const SizedBox(height: 4),
                DefaultTextStyle(
                  style: textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurface.withValues(alpha: 0.7),
                  ) ?? const TextStyle(),
                  child: subtitle!,
                ),
              ],
            ],
          ),
        ),
        
        // Title actions
        if (titleActions != null) ...[
          const SizedBox(width: 16),
          Row(children: titleActions!),
        ],
      ],
    );
  }
}

/// Content container with max width constraints
class AppContent extends AppContainer {
  const AppContent({
    super.key,
    required super.child,
    this.maxWidth = 800,
    super.padding,
    super.margin,
    super.alignment = Alignment.topCenter,
  }) : super(
          responsive: true,
        );

  final double maxWidth;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: AppContainer(
          padding: padding,
          margin: margin,
          alignment: alignment,
          child: child,
        ),
      ),
    );
  }
}