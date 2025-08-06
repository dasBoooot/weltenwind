/// 🎯 App Card Component
/// 
/// Professional card component with theme integration
library;

import 'package:flutter/material.dart';
import '../base/base_component.dart';

enum AppCardType {
  elevated,
  outlined,
  filled,
}

enum AppCardSize {
  compact,
  standard,
  expanded,
}

class AppCard extends BaseComponent {
  const AppCard({
    super.key,
    required this.child,
    this.type = AppCardType.elevated,
    this.size = AppCardSize.standard,
    this.title,
    this.subtitle,
    this.leading,
    this.trailing,
    this.onTap,
    this.onLongPress,
    this.margin,
    this.padding,
    this.elevation,
    this.borderRadius,
    this.backgroundColor,
    this.borderColor,
    this.width,
    this.height,
    this.constraints,
  });

  final Widget child;
  final AppCardType type;
  final AppCardSize size;
  final Widget? title;
  final Widget? subtitle;
  final Widget? leading;
  final Widget? trailing;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final EdgeInsets? margin;
  final EdgeInsets? padding;
  final double? elevation;
  final BorderRadius? borderRadius;
  final Color? backgroundColor;
  final Color? borderColor;
  final double? width;
  final double? height;
  final BoxConstraints? constraints;

  @override
  Widget build(BuildContext context) {
    final colorScheme = getColorScheme(context);
    final isDark = isDarkMode(context);

    Widget cardContent = _buildCardContent(context);

    // Apply card decoration based on type
    final decoration = _getCardDecoration(context, colorScheme, isDark);
    
    Widget card = Container(
      width: width,
      height: height,
      constraints: constraints,
      margin: margin ?? _getDefaultMargin(context),
      decoration: decoration,
      child: ClipRRect(
        borderRadius: borderRadius ?? getBorderRadius(context),
        child: cardContent,
      ),
    );

    // Add tap functionality if provided
    if (onTap != null || onLongPress != null) {
      card = InkWell(
        onTap: onTap,
        onLongPress: onLongPress,
        borderRadius: borderRadius ?? getBorderRadius(context),
        child: card,
      );
    }

    return card;
  }

  /// Build card content with optional header
  Widget _buildCardContent(BuildContext context) {
    final hasHeader = title != null || subtitle != null || leading != null || trailing != null;
    final cardPadding = padding ?? _getDefaultPadding(context);

    if (!hasHeader) {
      return Padding(
        padding: cardPadding,
        child: child,
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        _buildCardHeader(context, cardPadding),
        
        // Content
        Padding(
          padding: cardPadding.copyWith(top: 0),
          child: child,
        ),
      ],
    );
  }

  /// Build card header
  Widget _buildCardHeader(BuildContext context, EdgeInsets cardPadding) {
    final textTheme = getTextTheme(context);
    final colorScheme = getColorScheme(context);

    return Padding(
      padding: cardPadding.copyWith(bottom: 8),
      child: Row(
        children: [
          // Leading widget
          if (leading != null) ...[
            leading!,
            const SizedBox(width: 12),
          ],
          
          // Title and subtitle
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (title != null)
                  DefaultTextStyle(
                    style: textTheme.titleMedium?.copyWith(
                      color: colorScheme.onSurface,
                      fontWeight: FontWeight.w600,
                    ) ?? const TextStyle(),
                    child: title!,
                  ),
                if (subtitle != null) ...[
                  const SizedBox(height: 2),
                  DefaultTextStyle(
                    style: textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurface.withValues(alpha: 0.7),
                    ) ?? const TextStyle(),
                    child: subtitle!,
                  ),
                ],
              ],
            ),
          ),
          
          // Trailing widget
          if (trailing != null) ...[
            const SizedBox(width: 12),
            trailing!,
          ],
        ],
      ),
    );
  }

  /// Get card decoration based on type
  BoxDecoration _getCardDecoration(
    BuildContext context,
    ColorScheme colorScheme,
    bool isDark,
  ) {
    final cardBorderRadius = borderRadius ?? getBorderRadius(context);

    switch (type) {
      case AppCardType.elevated:
        return BoxDecoration(
          color: backgroundColor ?? colorScheme.surface,
          borderRadius: cardBorderRadius,
          boxShadow: getShadow(
            context,
            elevation: elevation ?? getElevation(context),
          ),
        );

      case AppCardType.outlined:
        return BoxDecoration(
          color: backgroundColor ?? colorScheme.surface,
          borderRadius: cardBorderRadius,
          border: Border.all(
            color: borderColor ?? colorScheme.outline.withValues(alpha: 0.5),
            width: 1.0,
          ),
        );

      case AppCardType.filled:
        return BoxDecoration(
          color: backgroundColor ?? (isDark 
              ? colorScheme.surfaceContainerHighest.withValues(alpha: 0.3)
              : colorScheme.surfaceContainerHighest.withValues(alpha: 0.5)),
          borderRadius: cardBorderRadius,
        );
    }
  }

  /// Get default margin based on size
  EdgeInsets _getDefaultMargin(BuildContext context) {
    final isCompact = getScreenSize(context) == ScreenSize.mobile;
    
    switch (size) {
      case AppCardSize.compact:
        return EdgeInsets.all(isCompact ? 4.0 : 8.0);
      case AppCardSize.standard:
        return EdgeInsets.all(isCompact ? 8.0 : 12.0);
      case AppCardSize.expanded:
        return EdgeInsets.all(isCompact ? 12.0 : 16.0);
    }
  }

  /// Get default padding based on size
  EdgeInsets _getDefaultPadding(BuildContext context) {
    final isCompact = getScreenSize(context) == ScreenSize.mobile;
    
    switch (size) {
      case AppCardSize.compact:
        return EdgeInsets.all(isCompact ? 12.0 : 16.0);
      case AppCardSize.standard:
        return EdgeInsets.all(isCompact ? 16.0 : 20.0);
      case AppCardSize.expanded:
        return EdgeInsets.all(isCompact ? 20.0 : 24.0);
    }
  }
}

/// Specialized card for world display
class WorldCard extends AppCard {
  WorldCard({
    super.key,
    required super.child,
    String? worldName,
    String? worldStatus,
    IconData? worldIcon,
    VoidCallback? onJoin,
    super.size,
  }) : super(
          type: AppCardType.elevated,
          title: worldName != null ? Text(worldName) : null,
          subtitle: worldStatus != null ? Text(worldStatus) : null,
          leading: worldIcon != null ? Icon(worldIcon) : null,
          trailing: onJoin != null 
              ? IconButton(
                  onPressed: onJoin,
                  icon: const Icon(Icons.play_arrow),
                  tooltip: 'Join World',
                )
              : null,
        );
}

/// Specialized card for user profile display
class ProfileCard extends AppCard {
  ProfileCard({
    super.key,
    required super.child,
    String? userName,
    String? userRole,
    Widget? avatar,
    VoidCallback? onProfile,
    super.size,
  }) : super(
          type: AppCardType.outlined,
          title: userName != null ? Text(userName) : null,
          subtitle: userRole != null ? Text(userRole) : null,
          leading: avatar,
          onTap: onProfile,
        );
}