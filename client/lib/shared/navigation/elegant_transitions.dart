import 'package:flutter/material.dart';

/// 🎨 Elegant Page Transitions - Theme-aware & Beautiful
/// 
/// Implementiert "Elegant Slide with Fade Overlay" - eine 3-phasige Animation:
/// Phase 1: Theme-Overlay slides in (halbtransparent)
/// Phase 2: Overlay wird heller, neue Seite durchscheinen  
/// Phase 3: Overlay slides out, neue Seite übernimmt
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
    Duration duration = const Duration(milliseconds: 2400),
  }) {
    
    final theme = Theme.of(context);
    
    // 🎨 Theme-aware Overlay-Farbe (kein Hardcoding!)
    final overlayColor = theme.colorScheme.primary;
    final backgroundColor = theme.colorScheme.surface;
    
    // 🎭 Animation Curves für die 3 Phasen
    const slideInCurve = Curves.easeInOutCubic;
    const fadeInCurve = Curves.easeInOut;
    const slideOutCurve = Curves.easeInOutCubic;
    
    // 📐 Slide-Offsets basierend auf Richtung
    final slideOffset = _getSlideOffset(direction);
    
    return AnimatedBuilder(
      animation: animation,
      builder: (context, _) {
        
        // 🎯 3-Phasen Logic - Sanftere Übergänge
        final progress = animation.value;
        
        if (progress < 0.25) {
          // PHASE 1: Overlay slides in (0.0 → 0.25)
          return _buildPhase1(context, progress, overlayColor, slideOffset, slideInCurve);
          
        } else if (progress < 0.75) {
          // PHASE 2: Overlay heller, neue Seite durchscheinen (0.25 → 0.75)
          return _buildPhase2(context, progress, child, overlayColor, backgroundColor, fadeInCurve);
          
        } else {
          // PHASE 3: Overlay slides out, neue Seite übernimmt (0.75 → 1.0)
          return _buildPhase3(context, progress, child, overlayColor, slideOffset, slideOutCurve);
        }
      },
    );
  }
  
  /// 🎨 Phase 1: Theme-Overlay slides in
  static Widget _buildPhase1(
    BuildContext context, 
    double progress, 
    Color overlayColor, 
    Offset slideOffset,
    Curve curve,
  ) {
    // Normalize progress for phase 1 (0.0 → 0.25 becomes 0.0 → 1.0)
    final phaseProgress = (progress / 0.25).clamp(0.0, 1.0);
    final curvedProgress = curve.transform(phaseProgress);
    
    return Stack(
      children: [
        // 🌫️ Subtle backdrop blur
        Container(
          color: overlayColor.withValues(alpha: 0.05 * curvedProgress),
        ),
        
        // 🎨 Main overlay sliding in
        SlideTransition(
          position: Tween<Offset>(
            begin: slideOffset,
            end: Offset.zero,
          ).animate(CurvedAnimation(
            parent: AlwaysStoppedAnimation(curvedProgress),
            curve: Curves.linear,
          )),
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  overlayColor.withValues(alpha: 0.4 * curvedProgress),
                  overlayColor.withValues(alpha: 0.6 * curvedProgress),
                  overlayColor.withValues(alpha: 0.4 * curvedProgress),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
  
  /// 🎨 Phase 2: Overlay heller, neue Seite durchscheinen
  static Widget _buildPhase2(
    BuildContext context, 
    double progress, 
    Widget child,
    Color overlayColor,
    Color backgroundColor,
    Curve curve,
  ) {
    // Normalize progress for phase 2 (0.25 → 0.75 becomes 0.0 → 1.0)
    final phaseProgress = ((progress - 0.25) / 0.5).clamp(0.0, 1.0);
    final curvedProgress = curve.transform(phaseProgress);
    
    return Stack(
      children: [
        // 🌟 Neue Seite wird sichtbar (mit subtiler Skalierung für Tiefe)
        Transform.scale(
          scale: 0.95 + (0.05 * curvedProgress),
          child: Opacity(
            opacity: 0.3 + (0.7 * curvedProgress),
            child: child,
          ),
        ),
        
        // 🎨 Overlay wird heller und durchscheinender
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                overlayColor.withValues(alpha: 0.6 * (1.0 - curvedProgress * 0.8)),
                backgroundColor.withValues(alpha: 0.4 * (1.0 - curvedProgress * 0.9)),
                overlayColor.withValues(alpha: 0.6 * (1.0 - curvedProgress * 0.8)),
              ],
            ),
          ),
        ),
      ],
    );
  }
  
  /// 🎨 Phase 3: Overlay slides out, neue Seite übernimmt
  static Widget _buildPhase3(
    BuildContext context, 
    double progress, 
    Widget child,
    Color overlayColor,
    Offset slideOffset,
    Curve curve,
  ) {
    // Normalize progress for phase 3 (0.75 → 1.0 becomes 0.0 → 1.0)
    final phaseProgress = ((progress - 0.75) / 0.25).clamp(0.0, 1.0);
    final curvedProgress = curve.transform(phaseProgress);
    
    return Stack(
      children: [
        // 🌟 Neue Seite voll sichtbar
        Transform.scale(
          scale: 0.95 + (0.05 * curvedProgress),
          child: child,
        ),
        
        // 🎨 Overlay slides out
        SlideTransition(
          position: Tween<Offset>(
            begin: Offset.zero,
            end: -slideOffset, // Opposite direction
          ).animate(CurvedAnimation(
            parent: AlwaysStoppedAnimation(curvedProgress),
            curve: Curves.linear,
          )),
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  overlayColor.withValues(alpha: 0.3 * (1.0 - curvedProgress)),
                  overlayColor.withValues(alpha: 0.5 * (1.0 - curvedProgress)),
                  overlayColor.withValues(alpha: 0.3 * (1.0 - curvedProgress)),
                ],
              ),
            ),
          ),
        ),
      ],
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