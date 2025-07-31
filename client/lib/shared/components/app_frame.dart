import 'package:flutter/material.dart';
import '../../theme/tokens/colors.dart';
import '../../theme/tokens/spacing.dart';
import '../../theme/tokens/typography.dart';
import '../../theme/tokens/shadows.dart';

/// 🖼️ Fantasy Frame Variants
enum AppFrameVariant {
  /// Standard-Rahmen ohne Effekte
  standard,
  /// Magischer Rahmen mit Glow
  magic,
  /// Portal-Rahmen mit Aqua-Glow
  portal,
  /// Artefakt-Rahmen in Gold
  artifact,
  /// Rune-Rahmen mit mystischen Ecken
  rune,
  /// Crystal-Rahmen mit Glitzer-Effekt
  crystal,
  /// Ancient-Rahmen für alte Schriftrollen
  ancient,
  /// Minimaler Rahmen
  minimal,
}

/// 🎭 Frame-Stile
enum AppFrameStyle {
  /// Vollständig gefüllt
  filled,
  /// Nur Umrandung
  outlined,
  /// Glasmorphism-Effekt
  glass,
  /// Gradient-Hintergrund
  gradient,
}

/// 🖼️ Weltenwind Fantasy Frame
/// 
/// Mystische Rahmen und Container für UI-Elemente
class AppFrame extends StatelessWidget {
  final Widget child;
  final AppFrameVariant variant;
  final AppFrameStyle style;
  final String? title;
  final Widget? titleWidget;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double borderRadius;
  final double borderWidth;
  final Color? customColor;
  final bool showShadow;
  final bool animated;
  final VoidCallback? onTap;

  const AppFrame({
    super.key,
    required this.child,
    this.variant = AppFrameVariant.standard,
    this.style = AppFrameStyle.filled,
    this.title,
    this.titleWidget,
    this.padding,
    this.margin,
    this.borderRadius = 16.0,
    this.borderWidth = 2.0,
    this.customColor,
    this.showShadow = true,
    this.animated = true,
    this.onTap,
  });

  // ========================================
  // 🏭 FACTORY CONSTRUCTORS
  // ========================================

  factory AppFrame.magic({
    required Widget child,
    String? title,
    EdgeInsetsGeometry? padding,
    bool showShadow = true,
  }) {
    return AppFrame(
      variant: AppFrameVariant.magic,
      title: title,
      padding: padding,
      showShadow: showShadow,
      child: child,
    );
  }

  factory AppFrame.portal({
    required Widget child,
    String? title,
    EdgeInsetsGeometry? padding,
    bool showShadow = true,
  }) {
    return AppFrame(
      variant: AppFrameVariant.portal,
      title: title,
      padding: padding,
      showShadow: showShadow,
      child: child,
    );
  }

  factory AppFrame.artifact({
    required Widget child,
    String? title,
    EdgeInsetsGeometry? padding,
    bool showShadow = true,
  }) {
    return AppFrame(
      variant: AppFrameVariant.artifact,
      title: title,
      padding: padding,
      showShadow: showShadow,
      child: child,
    );
  }

  factory AppFrame.rune({
    required Widget child,
    String? title,
    EdgeInsetsGeometry? padding,
  }) {
    return AppFrame(
      variant: AppFrameVariant.rune,
      title: title,
      padding: padding,
      borderRadius: 8.0,
      child: child,
    );
  }

  factory AppFrame.crystal({
    required Widget child,
    String? title,
    EdgeInsetsGeometry? padding,
  }) {
    return AppFrame(
      variant: AppFrameVariant.crystal,
      style: AppFrameStyle.glass,
      title: title,
      padding: padding,
      child: child,
    );
  }

  factory AppFrame.ancient({
    required Widget child,
    String? title,
    EdgeInsetsGeometry? padding,
  }) {
    return AppFrame(
      variant: AppFrameVariant.ancient,
      style: AppFrameStyle.gradient,
      title: title,
      padding: padding,
      borderRadius: 4.0,
      child: child,
    );
  }

  factory AppFrame.minimal({
    required Widget child,
    String? title,
    EdgeInsetsGeometry? padding,
  }) {
    return AppFrame(
      variant: AppFrameVariant.minimal,
      style: AppFrameStyle.outlined,
      title: title,
      padding: padding,
      showShadow: false,
      child: child,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    Widget content = _buildContent(theme, isDark);

    if (animated) {
      content = AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOutCubic,
        margin: margin ?? EdgeInsets.zero,
        child: content,
      );
    } else if (margin != null) {
      content = Container(margin: margin, child: content);
    }

    if (onTap != null) {
      content = GestureDetector(
        onTap: onTap,
        child: content,
      );
    }

    return content;
  }

  Widget _buildContent(ThemeData theme, bool isDark) {
    return Container(
      decoration: _getDecoration(isDark),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Title Section
          if (title != null || titleWidget != null)
            _buildTitle(theme, isDark),
          
          // Main Content
          Padding(
            padding: _getContentPadding(),
            child: child,
          ),
        ],
      ),
    );
  }

  Widget _buildTitle(ThemeData theme, bool isDark) {
    return Container(
      width: double.infinity,
      padding: _getTitlePadding(),
      decoration: _getTitleDecoration(isDark),
      child: titleWidget ?? _buildTitleText(theme, isDark),
    );
  }

  Widget _buildTitleText(ThemeData theme, bool isDark) {
    TextStyle titleStyle;
    
    switch (variant) {
      case AppFrameVariant.magic:
        titleStyle = AppTypography.mysticalTitle(isDark: isDark);
        break;
      case AppFrameVariant.portal:
        titleStyle = AppTypography.portalText(isDark: isDark);
        break;
      case AppFrameVariant.artifact:
        titleStyle = AppTypography.artifactName(isDark: isDark);
        break;
      case AppFrameVariant.ancient:
        titleStyle = AppTypography.h5(isDark: isDark).copyWith(
          fontStyle: FontStyle.italic,
          color: isDark ? AppColors.textSecondary : AppColors.textSecondaryLight,
        );
        break;
      default:
        titleStyle = AppTypography.h5(isDark: isDark);
    }

    return Text(
      title!,
      style: titleStyle,
      textAlign: TextAlign.center,
      maxLines: null,
    );
  }

  // ========================================
  // 🎨 STYLING METHODS
  // ========================================

  BoxDecoration _getDecoration(bool isDark) {
    return BoxDecoration(
      color: _getBackgroundColor(isDark),
      borderRadius: BorderRadius.circular(borderRadius),
      border: _getBorder(isDark),
      boxShadow: showShadow ? _getShadows() : null,
      gradient: _getGradient(isDark),
    );
  }

  Color? _getBackgroundColor(bool isDark) {
    if (style == AppFrameStyle.outlined) return Colors.transparent;
    if (style == AppFrameStyle.glass) {
      return isDark 
        ? AppColors.surfaceMedium.withOpacity(0.3)
        : AppColors.surfaceWhite.withOpacity(0.7);
    }

    if (customColor != null) return customColor;

    switch (variant) {
      case AppFrameVariant.standard:
      case AppFrameVariant.minimal:
        return isDark ? AppColors.surfaceMedium : AppColors.surfaceWhite;
      case AppFrameVariant.magic:
        return isDark ? AppColors.primarySurface : AppColors.surfaceWhite;
      case AppFrameVariant.portal:
        return isDark ? AppColors.surfaceDark : AppColors.surfaceGrayLight;
      case AppFrameVariant.artifact:
        return isDark ? AppColors.surfaceMedium : AppColors.surfaceWhite;
      case AppFrameVariant.rune:
      case AppFrameVariant.ancient:
        return isDark ? AppColors.surfaceDarker : AppColors.surfaceGray;
      case AppFrameVariant.crystal:
        return Colors.transparent;
    }
  }

  Border? _getBorder(bool isDark) {
    Color borderColor;
    
    switch (variant) {
      case AppFrameVariant.magic:
        borderColor = AppColors.glow;
        break;
      case AppFrameVariant.portal:
        borderColor = AppColors.aqua;
        break;
      case AppFrameVariant.artifact:
        borderColor = AppColors.secondary;
        break;
      case AppFrameVariant.rune:
        borderColor = isDark ? AppColors.primaryAccent : AppColors.primary;
        break;
      case AppFrameVariant.crystal:
        borderColor = AppColors.shimmer;
        break;
      case AppFrameVariant.ancient:
        borderColor = isDark ? AppColors.textSecondary : AppColors.textSecondaryLight;
        break;
      case AppFrameVariant.minimal:
        borderColor = isDark ? AppColors.surfaceLight : AppColors.surfaceGray;
        break;
      default:
        borderColor = isDark ? AppColors.surfaceLight : AppColors.surfaceGray;
    }

    return Border.all(
      color: borderColor,
      width: variant == AppFrameVariant.minimal ? 1.0 : borderWidth,
    );
  }

  List<BoxShadow>? _getShadows() {
    switch (variant) {
      case AppFrameVariant.magic:
        return AppShadows.magicGlow;
      case AppFrameVariant.portal:
        return AppShadows.portalGlow;
      case AppFrameVariant.artifact:
        return AppShadows.goldenGlow;
      case AppFrameVariant.crystal:
        return AppShadows.customGlow(
          color: AppColors.shimmer,
          intensity: 0.3,
          blurRadius: 8.0,
          spreadRadius: 1.0,
        );
      case AppFrameVariant.rune:
        return AppShadows.medium;
      case AppFrameVariant.ancient:
        return AppShadows.large;
      case AppFrameVariant.minimal:
        return AppShadows.none;
      default:
        return AppShadows.small;
    }
  }

  Gradient? _getGradient(bool isDark) {
    if (style != AppFrameStyle.gradient && style != AppFrameStyle.glass) return null;

    switch (variant) {
      case AppFrameVariant.magic:
        return AppColors.magicGradient;
      case AppFrameVariant.portal:
        return AppColors.portalGradient;
      case AppFrameVariant.crystal:
        return LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.glass,
            AppColors.glassDark,
            AppColors.shimmer.withOpacity(0.1),
          ],
        );
      case AppFrameVariant.ancient:
        return LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: isDark 
            ? [AppColors.surfaceDarker, AppColors.surfaceMedium]
            : [AppColors.surfaceGray, AppColors.surfaceWhite],
        );
      default:
        return null;
    }
  }

  BoxDecoration? _getTitleDecoration(bool isDark) {
    if (title == null && titleWidget == null) return null;

    Color? titleBgColor;
    BorderRadius? titleBorderRadius;

    switch (variant) {
      case AppFrameVariant.magic:
        titleBgColor = AppColors.glow.withOpacity(0.1);
        break;
      case AppFrameVariant.portal:
        titleBgColor = AppColors.aqua.withOpacity(0.1);
        break;
      case AppFrameVariant.artifact:
        titleBgColor = AppColors.secondary.withOpacity(0.1);
        break;
      case AppFrameVariant.ancient:
        titleBgColor = isDark 
          ? AppColors.surfaceDarker.withOpacity(0.8)
          : AppColors.surfaceGray.withOpacity(0.5);
        break;
      default:
        titleBgColor = isDark 
          ? AppColors.surfaceLight.withOpacity(0.3)
          : AppColors.surfaceGray.withOpacity(0.3);
    }

    titleBorderRadius = BorderRadius.only(
      topLeft: Radius.circular(borderRadius),
      topRight: Radius.circular(borderRadius),
    );

    return BoxDecoration(
      color: titleBgColor,
      borderRadius: titleBorderRadius,
      border: Border(
        bottom: BorderSide(
          color: _getBorder(isDark)?.top.color ?? Colors.transparent,
          width: 1.0,
        ),
      ),
    );
  }

  // ========================================
  // 📏 PADDING & SPACING
  // ========================================

  EdgeInsetsGeometry _getContentPadding() {
    final basePadding = padding ?? const EdgeInsets.all(AppSpacing.cardPaddingMedium);
    
    // Wenn Titel vorhanden ist, nur unten, links und rechts padden
    if (title != null || titleWidget != null) {
      return EdgeInsets.only(
        left: basePadding.horizontal / 2,
        right: basePadding.horizontal / 2,
        bottom: basePadding.vertical,
      );
    }
    
    return basePadding;
  }

  EdgeInsetsGeometry _getTitlePadding() {
    final basePadding = padding ?? const EdgeInsets.all(AppSpacing.cardPaddingMedium);
    
    return EdgeInsets.only(
      left: basePadding.horizontal / 2,
      right: basePadding.horizontal / 2,
      top: basePadding.vertical * 0.75,
      bottom: basePadding.vertical * 0.75,
    );
  }
}

/// 🎯 Frame-Builder für komplexere Layouts
class AppFrameBuilder extends StatelessWidget {
  final String? title;
  final List<Widget> children;
  final AppFrameVariant variant;
  final CrossAxisAlignment crossAxisAlignment;
  final MainAxisAlignment mainAxisAlignment;
  final MainAxisSize mainAxisSize;
  final EdgeInsetsGeometry? padding;
  final double spacing;

  const AppFrameBuilder({
    super.key,
    this.title,
    required this.children,
    this.variant = AppFrameVariant.standard,
    this.crossAxisAlignment = CrossAxisAlignment.start,
    this.mainAxisAlignment = MainAxisAlignment.start,
    this.mainAxisSize = MainAxisSize.min,
    this.padding,
    this.spacing = AppSpacing.md,
  });

  @override
  Widget build(BuildContext context) {
    return AppFrame(
      title: title,
      variant: variant,
      padding: padding,
      child: Column(
        crossAxisAlignment: crossAxisAlignment,
        mainAxisAlignment: mainAxisAlignment,
        mainAxisSize: mainAxisSize,
        children: [
          for (int i = 0; i < children.length; i++)
            if (i == children.length - 1)
              children[i] // Letztes Element ohne Padding
            else
              Padding(
                padding: EdgeInsets.only(bottom: spacing),
                child: children[i],
              ),
        ]
      ),
    );
  }
}