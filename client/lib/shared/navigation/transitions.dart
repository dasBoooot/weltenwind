import 'package:flutter/material.dart';

/// Implementiert "Elegant Slide with Fade Overlay" - eine flüssige Animation
/// ohne abrupte Phasenübergänge für bessere Performance
class ElegantTransitions {
  
  /// 🎨 Elegant Slide with Fade Overlay - Die Haupt-Transition
  /// 
  /// Parameters:
  /// - context: BuildContext für Theme-Zugriff
  /// - animation: Primary animation (0.0 → 1.0)  
  /// - secondaryAnimation: Secondary animation (für exit transition)
  /// - child: Die neue Page
  /// - direction: Slide-Richtung (optional, default: from bottom)
  static Widget elegantSlideWithOverlay(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child, {
    SlideDirection direction = SlideDirection.fromBottom,
    Duration duration = const Duration(milliseconds: 600),
  }) {
    
    final theme = Theme.of(context);
    
    // 🎨 Theme-aware Overlay-Farbe (kein Hardcoding!)
    final overlayColor = theme.colorScheme.primary;
    
    // 📐 Slide-Offsets basierend auf Richtung (für zukünftige Erweiterungen)
    // final slideOffset = _getSlideOffset(direction);
    
    return AnimatedBuilder(
      animation: animation,
      builder: (context, _) {
        final progress = animation.value;
        
        // 🎭 Flüssigere Animation ohne abrupte Phasenübergänge
        return Stack(
          children: [
            // 🌟 Neue Seite mit sanfter Skalierung und Opacity
            Transform.scale(
              scale: 0.98 + (0.02 * progress),
              child: Opacity(
                opacity: 0.1 + (0.9 * progress),
                child: child,
              ),
            ),
            
            // 🎨 Sanfter Overlay mit Gradient (ignoriert Klicks)
             Opacity(
               opacity: (1.0 - progress) * 0.7,
               child: IgnorePointer(
                 child: Container(
                   decoration: BoxDecoration(
                     gradient: LinearGradient(
                       begin: Alignment.topCenter,
                       end: Alignment.bottomCenter,
                       colors: [
                         overlayColor.withValues(alpha: 0.3),
                         overlayColor.withValues(alpha: 0.5),
                         overlayColor.withValues(alpha: 0.3),
                       ],
                     ),
                   ),
                 ),
               ),
             ),
          ],
        );
      },
    );
  }
  
  /// 📐 Helper: Slide-Offset basierend auf Richtung
  static Offset _getSlideOffset(SlideDirection direction) {
    switch (direction) {
      case SlideDirection.fromBottom:
        return const Offset(0.0, 1.0);
      case SlideDirection.fromTop:
        return const Offset(0.0, -1.0);
      case SlideDirection.fromLeft:
        return const Offset(-1.0, 0.0);
      case SlideDirection.fromRight:
        return const Offset(1.0, 0.0);
    }
  }
  
  /// 🔄 Fade Transition für einfachere Navigationen (Auth pages)
  static Widget elegantFade(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    return FadeTransition(
      opacity: CurvedAnimation(
        parent: animation,
        curve: Curves.easeInOutCubic,
      ),
      child: child,
    );
  }
}

/// 📐 Slide-Richtungen für die Transition
enum SlideDirection {
  fromBottom,
  fromTop,
  fromLeft,
  fromRight,
}
