/// 🎯 Base Component
/// 
/// Foundation for all UI components with theme integration
library;

import 'package:flutter/material.dart';
import '../../theme/theme_manager.dart';
import '../../theme/extensions.dart';

abstract class BaseComponent extends StatelessWidget {
  const BaseComponent({super.key});

  /// Get current theme from ThemeManager
  ThemeData getCurrentTheme(BuildContext context) {
    final themeManager = ThemeManager();
    return themeManager.currentTheme;
  }

  /// Get current color scheme
  ColorScheme getColorScheme(BuildContext context) {
    return getCurrentTheme(context).colorScheme;
  }

  /// Get current text theme
  TextTheme getTextTheme(BuildContext context) {
    return getCurrentTheme(context).textTheme;
  }

  /// Check if current theme is dark mode
  bool isDarkMode(BuildContext context) {
    return getCurrentTheme(context).brightness == Brightness.dark;
  }

  /// Get theme-aware elevation
  double getElevation(BuildContext context, {double base = 2.0}) {
    return isDarkMode(context) ? base * 1.5 : base;
  }

  /// Get theme-aware border radius
  BorderRadius getBorderRadius(BuildContext context, {double radius = 12.0}) {
    final ext = Theme.of(context).extension<AppRadiusTheme>();
    if (radius == 12.0 && ext != null) return ext.radiusMedium;
    return BorderRadius.circular(radius);
  }

  /// Get theme-aware shadow
  List<BoxShadow> getShadow(BuildContext context, {double elevation = 2.0}) {
    final isDark = isDarkMode(context);
    return [
      BoxShadow(
        color: isDark 
            ? Colors.black.withValues(alpha: 0.3)
            : Colors.black.withValues(alpha: 0.1),
        spreadRadius: 1,
        blurRadius: elevation * 2,
        offset: Offset(0, elevation),
      ),
    ];
  }

  /// Get responsive padding based on screen size
  EdgeInsets getResponsivePadding(BuildContext context, {
    double mobile = 16.0,
    double tablet = 24.0,
    double desktop = 32.0,
  }) {
    final screenWidth = MediaQuery.of(context).size.width;
    final spacing = Theme.of(context).extension<AppSpacingTheme>();
    
    if (screenWidth < 768) {
      return EdgeInsets.all(spacing?.md ?? mobile);
    } else if (screenWidth < 1024) {
      return EdgeInsets.all(spacing?.lg ?? tablet);
    } else {
      return EdgeInsets.all(spacing?.xl ?? desktop);
    }
  }

  /// Get responsive font size
  double getResponsiveFontSize(BuildContext context, {
    double mobile = 14.0,
    double tablet = 16.0,
    double desktop = 18.0,
  }) {
    final screenWidth = MediaQuery.of(context).size.width;
    
    if (screenWidth < 768) {
      return mobile;
    } else if (screenWidth < 1024) {
      return tablet;
    } else {
      return desktop;
    }
  }

  /// Get screen size category
  ScreenSize getScreenSize(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    
    if (screenWidth < 768) {
      return ScreenSize.mobile;
    } else if (screenWidth < 1024) {
      return ScreenSize.tablet;
    } else {
      return ScreenSize.desktop;
    }
  }
}

/// Screen size categories for responsive design
enum ScreenSize {
  mobile,
  tablet,
  desktop,
}

/// Base Stateful Component for components that need state
abstract class BaseStatefulComponent extends StatefulWidget {
  const BaseStatefulComponent({super.key});
}

abstract class BaseStatefulComponentState<T extends BaseStatefulComponent> 
    extends State<T> {
  
  /// Get current theme from ThemeManager
  ThemeData getCurrentTheme() {
    final themeManager = ThemeManager();
    return themeManager.currentTheme;
  }

  /// Get current color scheme
  ColorScheme getColorScheme() {
    return getCurrentTheme().colorScheme;
  }

  /// Get current text theme
  TextTheme getTextTheme() {
    return getCurrentTheme().textTheme;
  }

  /// Check if current theme is dark mode
  bool isDarkMode() {
    return getCurrentTheme().brightness == Brightness.dark;
  }

  /// Get theme-aware elevation
  double getElevation({double base = 2.0}) {
    return isDarkMode() ? base * 1.5 : base;
  }

  /// Get theme-aware border radius
  BorderRadius getBorderRadius({double radius = 12.0}) {
    return BorderRadius.circular(radius);
  }

  /// Get theme-aware shadow
  List<BoxShadow> getShadow({double elevation = 2.0}) {
    final isDark = isDarkMode();
    return [
      BoxShadow(
        color: isDark 
          ? Colors.black.withValues(alpha: 0.3)
          : Colors.black.withValues(alpha: 0.1),
        spreadRadius: 1,
        blurRadius: elevation * 2,
        offset: Offset(0, elevation),
      ),
    ];
  }

  /// Get responsive padding based on screen size
  EdgeInsets getResponsivePadding({
    double mobile = 16.0,
    double tablet = 24.0,
    double desktop = 32.0,
  }) {
    final screenWidth = MediaQuery.of(context).size.width;
    
    if (screenWidth < 768) {
      return EdgeInsets.all(mobile);
    } else if (screenWidth < 1024) {
      return EdgeInsets.all(tablet);
    } else {
      return EdgeInsets.all(desktop);
    }
  }

  /// Get responsive font size
  double getResponsiveFontSize({
    double mobile = 14.0,
    double tablet = 16.0,
    double desktop = 18.0,
  }) {
    final screenWidth = MediaQuery.of(context).size.width;
    
    if (screenWidth < 768) {
      return mobile;
    } else if (screenWidth < 1024) {
      return tablet;
    } else {
      return desktop;
    }
  }

  /// Get screen size category
  ScreenSize getScreenSize() {
    final screenWidth = MediaQuery.of(context).size.width;
    
    if (screenWidth < 768) {
      return ScreenSize.mobile;
    } else if (screenWidth < 1024) {
      return ScreenSize.tablet;
    } else {
      return ScreenSize.desktop;
    }
  }
}