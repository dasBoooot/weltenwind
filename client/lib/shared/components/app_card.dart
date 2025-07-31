import 'package:flutter/material.dart';
import '../../theme/tokens/colors.dart';
import '../../theme/tokens/spacing.dart';
import '../../theme/tokens/shadows.dart';

/// 🎴 Fantasy Card Component
/// 
/// Mystische Karten mit verschiedenen Varianten und magischen Effekten
enum AppCardVariant {
  /// Standard-Karte ohne besondere Effekte
  standard,
  /// Elevated Karte mit Schatten
  elevated,
  /// Magische Karte mit Glow-Effekt
  magic,
  /// Portal-Karte mit Aqua-Glow
  portal,
  /// Golden Artefakt-Karte
  artifact,
  /// Outlined Karte nur mit Rahmen
  outlined,
  /// Glasmorphism-Effekt
  glass,
}

class AppCard extends StatelessWidget {
  final Widget child;
  final AppCardVariant variant;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final double? width;
  final double? height;
  final Color? customColor;
  final bool isInteractive;
  final bool isSelected;
  final double borderRadius;

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
    this.isInteractive = true,
    this.isSelected = false,
    this.borderRadius = 16.0,
  });

  /// Factory Constructors für häufige Varianten
  factory AppCard.magic({
    required Widget child,
    EdgeInsetsGeometry? padding,
    VoidCallback? onTap,
    bool isSelected = false,
  }) {
    return AppCard(
      variant: AppCardVariant.magic,
      onTap: onTap,
      isSelected: isSelected,
      padding: padding,
      child: child,
    );
  }

  factory AppCard.portal({
    required Widget child,
    EdgeInsetsGeometry? padding,
    VoidCallback? onTap,
  }) {
    return AppCard(
      variant: AppCardVariant.portal,
      onTap: onTap,
      padding: padding,
      child: child,
    );
  }

  factory AppCard.artifact({
    required Widget child,
    EdgeInsetsGeometry? padding,
    VoidCallback? onTap,
  }) {
    return AppCard(
      variant: AppCardVariant.artifact,
      onTap: onTap,
      padding: padding,
      child: child,
    );
  }

  factory AppCard.glass({
    required Widget child,
    EdgeInsetsGeometry? padding,
    VoidCallback? onTap,
  }) {
    return AppCard(
      variant: AppCardVariant.glass,
      onTap: onTap,
      padding: padding,
      child: child,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeInOutCubic,
      width: width,
      height: height,
      margin: margin ?? const EdgeInsets.all(AppSpacing.xs),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isInteractive ? onTap : null,
          onLongPress: isInteractive ? onLongPress : null,
          borderRadius: BorderRadius.circular(borderRadius),
          splashColor: _getSplashColor(isDark),
          highlightColor: _getHighlightColor(isDark),
          child: Container(
            padding: padding ?? const EdgeInsets.all(AppSpacing.cardPaddingMedium),
            decoration: _getDecoration(context, isDark),
            child: child,
          ),
        ),
      ),
    );
  }

  /// Bestimmt die Splash-Farbe basierend auf Variante
  Color _getSplashColor(bool isDark) {
    switch (variant) {
      case AppCardVariant.magic:
        return AppColors.glow.withValues(alpha: 0.2);
      case AppCardVariant.portal:
        return AppColors.aqua.withValues(alpha: 0.2);
      case AppCardVariant.artifact:
        return AppColors.secondary.withValues(alpha: 0.2);
      default:
        return isDark ? AppColors.primaryAccent.withValues(alpha: 0.1) : AppColors.primary.withValues(alpha: 0.1);
    }
  }

  /// Bestimmt die Highlight-Farbe basierend auf Variante
  Color _getHighlightColor(bool isDark) {
    switch (variant) {
      case AppCardVariant.magic:
        return AppColors.glow.withValues(alpha: 0.1);
      case AppCardVariant.portal:
        return AppColors.aqua.withValues(alpha: 0.1);
      case AppCardVariant.artifact:
        return AppColors.secondary.withValues(alpha: 0.1);
      default:
        return isDark ? AppColors.primaryAccent.withValues(alpha: 0.05) : AppColors.primary.withValues(alpha: 0.05);
    }
  }

  /// Erstellt die Dekoration basierend auf Variante und Theme
  BoxDecoration _getDecoration(BuildContext context, bool isDark) {
    final baseColor = customColor ?? _getBaseColor(isDark);
    final borderColor = _getBorderColor(isDark);
    final shadows = _getShadows();

    return BoxDecoration(
      color: baseColor,
      borderRadius: BorderRadius.circular(borderRadius),
      border: _getBorder(borderColor),
      boxShadow: shadows,
      gradient: _getGradient(),
    );
  }

  /// Bestimmt die Basisfarbe der Karte
  Color _getBaseColor(bool isDark) {
    switch (variant) {
      case AppCardVariant.glass:
        return isDark 
                  ? AppColors.surfaceMedium.withValues(alpha: 0.3)
        : AppColors.surfaceWhite.withValues(alpha: 0.7);
      case AppCardVariant.outlined:
        return Colors.transparent;
      default:
        return isDark ? AppColors.surfaceMedium : AppColors.surfaceWhite;
    }
  }

  /// Bestimmt die Rahmenfarbe
  Color? _getBorderColor(bool isDark) {
    if (isSelected) {
      switch (variant) {
        case AppCardVariant.magic:
          return AppColors.glow;
        case AppCardVariant.portal:
          return AppColors.aqua;
        case AppCardVariant.artifact:
          return AppColors.secondary;
        default:
          return isDark ? AppColors.primaryAccent : AppColors.primary;
      }
    }

    switch (variant) {
      case AppCardVariant.outlined:
        return isDark ? AppColors.surfaceLight : AppColors.surfaceGray;
      case AppCardVariant.glass:
        return isDark ? AppColors.surfaceLight.withValues(alpha: 0.3) : AppColors.surfaceGray.withValues(alpha: 0.5);
      default:
        return null;
    }
  }

  /// Erstellt den Rahmen falls notwendig
  Border? _getBorder(Color? borderColor) {
    if (borderColor == null) return null;
    
    return Border.all(
      color: borderColor,
      width: isSelected ? 2.0 : 1.0,
    );
  }

  /// Bestimmt die Schatten basierend auf Variante
  List<BoxShadow> _getShadows() {
    switch (variant) {
      case AppCardVariant.elevated:
        return AppShadows.medium;
      case AppCardVariant.magic:
        return isSelected ? AppShadows.magicGlow : AppShadows.small;
      case AppCardVariant.portal:
        return isSelected ? AppShadows.portalGlow : AppShadows.small;
      case AppCardVariant.artifact:
        return isSelected ? AppShadows.goldenGlow : AppShadows.small;
      case AppCardVariant.glass:
        return AppShadows.minimal;
      case AppCardVariant.outlined:
        return AppShadows.none;
      default:
        return AppShadows.small;
    }
  }

  /// Bestimmt optionale Verläufe
  Gradient? _getGradient() {
    if (variant == AppCardVariant.glass) {
      return const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          AppColors.glass,
          AppColors.glassDark,
        ],
      );
    }
    return null;
  }
}

/// 🎴 Card-Builder für komplexere Layouts
class AppCardBuilder extends StatelessWidget {
  final String? title;
  final String? subtitle;
  final Widget? leading;
  final Widget? trailing;
  final Widget? content;
  final List<Widget>? actions;
  final AppCardVariant variant;
  final VoidCallback? onTap;
  final bool isSelected;

  const AppCardBuilder({
    super.key,
    this.title,
    this.subtitle,
    this.leading,
    this.trailing,
    this.content,
    this.actions,
    this.variant = AppCardVariant.standard,
    this.onTap,
    this.isSelected = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return AppCard(
      variant: variant,
      onTap: onTap,
      isSelected: isSelected,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header mit Title/Subtitle und Leading/Trailing
          if (title != null || leading != null || trailing != null)
            _buildHeader(theme),
          
          // Content
          if (content != null) ...[
            if (title != null || subtitle != null) 
              const SizedBox(height: AppSpacing.md),
            content!,
          ],
          
          // Actions
          if (actions != null && actions!.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.md),
            _buildActions(),
          ],
        ],
      ),
    );
  }

  Widget _buildHeader(ThemeData theme) {
    return Row(
      children: [
        if (leading != null) ...[
          leading!,
          const SizedBox(width: AppSpacing.md),
        ],
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (title != null) 
                Text(
                  title!,
                  style: theme.textTheme.titleMedium,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              if (subtitle != null) ...[
                if (title != null) const SizedBox(height: AppSpacing.tiny),
                Text(
                  subtitle!,
                  style: theme.textTheme.bodySmall,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ],
          ),
        ),
        if (trailing != null) ...[
          const SizedBox(width: AppSpacing.md),
          trailing!,
        ],
      ],
    );
  }

  Widget _buildActions() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: actions!
          .map((action) => Padding(
                padding: const EdgeInsets.only(left: AppSpacing.sm),
                child: action,
              ))
          .toList(),
    );
  }
}