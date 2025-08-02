import 'package:flutter/widgets.dart';
import 'dart:math' as math;

/// 📱 Responsive Breakpoints for Weltenwind
class ResponsiveBreakpoints {
  static const double mobile = 480;
  static const double tablet = 768; 
  static const double desktop = 1024;
  static const double largeDesktop = 1440;
}

/// 📐 Device Types
enum DeviceType {
  mobile,
  tablet,
  desktop,
  largeDesktop,
}

/// 📱 Responsive Helper for Schema-based Components
class ResponsiveHelper {
  static DeviceType getDeviceType(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    
    if (width >= ResponsiveBreakpoints.largeDesktop) {
      return DeviceType.largeDesktop;
    } else if (width >= ResponsiveBreakpoints.desktop) {
      return DeviceType.desktop;
    } else if (width >= ResponsiveBreakpoints.tablet) {
      return DeviceType.tablet;
    } else {
      return DeviceType.mobile;
    }
  }
  
  static bool isMobile(BuildContext context) {
    return getDeviceType(context) == DeviceType.mobile;
  }
  
  static bool isTablet(BuildContext context) {
    return getDeviceType(context) == DeviceType.tablet;
  }
  
  static bool isDesktop(BuildContext context) {
    final type = getDeviceType(context);
    return type == DeviceType.desktop || type == DeviceType.largeDesktop;
  }
  
  /// Get responsive value based on device type
  static T responsive<T>(
    BuildContext context, {
    required T mobile,
    T? tablet,
    T? desktop,
    T? largeDesktop,
  }) {
    switch (getDeviceType(context)) {
      case DeviceType.largeDesktop:
        return largeDesktop ?? desktop ?? tablet ?? mobile;
      case DeviceType.desktop:
        return desktop ?? tablet ?? mobile;
      case DeviceType.tablet:
        return tablet ?? mobile;
      case DeviceType.mobile:
        return mobile;
    }
  }
  
  /// Gaming-specific responsive values
  static double getGameElementSize(BuildContext context, {
    required double mobile,
    double? tablet,
    double? desktop,
  }) {
    return responsive(
      context,
      mobile: mobile,
      tablet: tablet ?? mobile * 1.2,
      desktop: desktop ?? mobile * 1.5,
    );
  }
  
  /// Touch target size for mobile
  static double getTouchTargetSize(BuildContext context) {
    return isMobile(context) ? 48.0 : 40.0;
  }
  
  /// Safe area aware padding
  static EdgeInsets getSafeAreaPadding(BuildContext context) {
    final padding = MediaQuery.of(context).padding;
    return EdgeInsets.only(
      top: padding.top,
      bottom: padding.bottom,
    );
  }
}

/// 📱 Responsive Widget Builder
class ResponsiveBuilder extends StatelessWidget {
  final Widget Function(BuildContext context, DeviceType deviceType) builder;

  const ResponsiveBuilder({
    super.key,
    required this.builder,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final deviceType = ResponsiveHelper.getDeviceType(context);
        return builder(context, deviceType);
      },
    );
  }
}

/// 🎮 Gaming Context Responsive Helper
class GamingResponsiveHelper {
  /// HUD element sizes for different devices
  static double getHudElementSize(BuildContext context, String elementType) {
    final baseSize = {
      'minimap': 120.0,
      'healthBar': 200.0,
      'buffIcon': 32.0,
      'inventorySlot': 48.0,
    }[elementType] ?? 48.0;
    
    return ResponsiveHelper.responsive(
      context,
      mobile: baseSize,
      tablet: baseSize * 1.2,
      desktop: baseSize * 1.4,
    );
  }
  
  /// Touch-friendly sizing for mobile gaming
  static double getTouchFriendlySize(BuildContext context, double baseSize) {
    return ResponsiveHelper.isMobile(context) 
        ? math.max(baseSize, 48.0) // Minimum touch target
        : baseSize;
  }
}