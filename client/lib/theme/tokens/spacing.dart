/// 📏 Weltenwind Spacing System
/// 
/// Konsistente Abstände basierend auf 8pt Grid-System
/// mit Fantasy-inspirierten Proportionen
class AppSpacing {
  // ========================================
  // 🎯 BASIS-SPACING (8pt Grid)
  // ========================================
  
  /// Grundeinheit: 8px
  static const double unit = 8.0;
  
  /// Micro-Spacing für feine Abstände
  static const double micro = 2.0;   // 0.25 * unit
  static const double tiny = 4.0;    // 0.5 * unit
  
  /// Standard-Spacing-Skala
  static const double xs = 8.0;      // 1 * unit
  static const double sm = 12.0;     // 1.5 * unit
  static const double md = 16.0;     // 2 * unit
  static const double lg = 24.0;     // 3 * unit
  static const double xl = 32.0;     // 4 * unit
  static const double xxl = 48.0;    // 6 * unit
  static const double xxxl = 64.0;   // 8 * unit

  // ========================================
  // 🏗️ LAYOUT-SPACING - Container & Sections
  // ========================================
  
  /// Page-Level Spacing
  static const double pageHorizontal = 20.0;  // Mobile-optimiert
  static const double pageVertical = 24.0;
  
  /// Desktop/Tablet Breakpoints
  static const double pageHorizontalDesktop = 40.0;
  static const double pageVerticalDesktop = 32.0;
  
  /// Section-Abstände
  static const double sectionSmall = 24.0;
  static const double sectionMedium = 40.0;
  static const double sectionLarge = 56.0;
  static const double sectionXLarge = 80.0;

  // ========================================
  // 🎴 COMPONENT-SPACING - UI-Elemente
  // ========================================
  
  /// Card-interne Abstände
  static const double cardPaddingSmall = 16.0;
  static const double cardPaddingMedium = 20.0;
  static const double cardPaddingLarge = 24.0;
  
  /// Card-Abstände zueinander
  static const double cardGapSmall = 12.0;
  static const double cardGapMedium = 16.0;
  static const double cardGapLarge = 24.0;
  
  /// Button-Spacing
  static const double buttonPaddingHorizontal = 24.0;
  static const double buttonPaddingVertical = 12.0;
  static const double buttonPaddingSmall = 16.0;
  static const double buttonPaddingLarge = 32.0;
  
  /// Input-Field-Spacing
  static const double inputPaddingHorizontal = 16.0;
  static const double inputPaddingVertical = 14.0;
  static const double inputGap = 16.0;

  // ========================================
  // 🪄 FANTASY-SPEZIFISCHE ABSTÄNDE
  // ========================================
  
  /// Magische Proportionen (Goldener Schnitt inspiriert)
  static const double mysticalSmall = 13.0;   // ≈ Fibonacci
  static const double mysticalMedium = 21.0;  // ≈ Fibonacci
  static const double mysticalLarge = 34.0;   // ≈ Fibonacci
  
  /// Portal/Frame-Abstände
  static const double portalBorder = 8.0;
  static const double portalGlow = 4.0;
  static const double frameThickness = 2.0;
  
  /// Artefakt-Listen (für Inventar, Shop, etc.)
  static const double artifactGap = 12.0;
  static const double artifactPadding = 16.0;

  // ========================================
  // 📱 RESPONSIVE BREAKPOINTS
  // ========================================
  
  /// Breakpoint-abhängige Spacing-Werte
  static double responsiveHorizontal(double screenWidth) {
    if (screenWidth < 600) return pageHorizontal;
    if (screenWidth < 1024) return pageHorizontalDesktop * 0.75;
    return pageHorizontalDesktop;
  }
  
  static double responsiveVertical(double screenWidth) {
    if (screenWidth < 600) return pageVertical;
    return pageVerticalDesktop;
  }
  
  static double responsiveSection(double screenWidth) {
    if (screenWidth < 600) return sectionSmall;
    if (screenWidth < 1024) return sectionMedium;
    return sectionLarge;
  }

  // ========================================
  // 🎭 ANIMATION & TRANSITION SPACING
  // ========================================
  
  /// Bewegungs-Distanzen für Animationen
  static const double slideDistance = 32.0;
  static const double bounceDistance = 8.0;
  static const double hoverLift = 4.0;
  
  /// Stagger-Delays für Listen-Animationen
  static const double staggerBase = 50.0;  // Millisekunden
  static const double staggerIncrement = 25.0;
}