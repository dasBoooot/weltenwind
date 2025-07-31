import 'package:flutter/material.dart';

/// 🎨 Weltenwind Fantasy Color Tokens
/// 
/// Basiert auf mystischer Fantasy-Ästhetik mit magischen Akzenten
class AppColors {
  // ========================================
  // 🎯 PRIMÄRFARBEN - Magie & Portale
  // ========================================
  
  /// Hauptfarbe - Indigo für Magie und Mysterium
  static const Color primary = Color(0xFF4B3B79);
  static const Color primaryLight = Color(0xFF6A5394);
  static const Color primaryDark = Color(0xFF2E1F4A);
  
  /// Primäre Varianten für verschiedene Intensitäten
  static const Color primarySurface = Color(0xFF1A1025);
  static const Color primaryAccent = Color(0xFF7C6BAF);

  // ========================================
  // ✨ SEKUNDÄRFARBEN - Artefakte & Highlights
  // ========================================
  
  /// Gold für Artefakte und wichtige Elemente
  static const Color secondary = Color(0xFFD4AF37);
  static const Color secondaryLight = Color(0xFFE1C554);
  static const Color secondaryDark = Color(0xFFB8941F);
  
  /// Amber-Variante für UI-Akzente
  static const Color amber = Color(0xFFFFC107);
  static const Color amberLight = Color(0xFFFFD54F);
  static const Color amberDark = Color(0xFFFF8F00);

  // ========================================
  // 🌿 TERTIÄRFARBEN - Natur & Leben
  // ========================================
  
  /// Moosgrün für natürliche Elemente
  static const Color tertiary = Color(0xFF4C6B4A);
  static const Color tertiaryLight = Color(0xFF6B8A69);
  static const Color tertiaryDark = Color(0xFF2D4B2B);
  
  /// Cyan-Türkis für Energie und Wasser-Magie
  static const Color aqua = Color(0xFF20B2AA);
  static const Color aquaLight = Color(0xFF4DD0D1);
  static const Color aquaDark = Color(0xFF008B8B);

  // ========================================
  // 🖤 NEUTRALE FARBEN - Basis & Struktur
  // ========================================
  
  /// Dunkle Hintergründe - Mysterium und Tiefe
  static const Color surfaceDark = Color(0xFF1E1E2E);
  static const Color surfaceDarker = Color(0xFF141420);
  static const Color surfaceMedium = Color(0xFF2A2A3E);
  static const Color surfaceLight = Color(0xFF3A3A52);
  
  /// Helle Varianten für Light Mode
  static const Color surfaceWhite = Color(0xFFF8F9FA);
  static const Color surfaceGray = Color(0xFFE9ECEF);
  static const Color surfaceGrayLight = Color(0xFFF1F3F4);

  // ========================================
  // 🤍 TEXT & CONTENT - Lesbarkeit
  // ========================================
  
  /// Silberweiß für perfekte Lesbarkeit
  static const Color textPrimary = Color(0xFFE0E0E0);
  static const Color textSecondary = Color(0xFFB0B0B0);
  static const Color textTertiary = Color(0xFF808080);
  static const Color textDisabled = Color(0xFF505060);
  
  /// Text für Light Mode
  static const Color textPrimaryLight = Color(0xFF1F2937);
  static const Color textSecondaryLight = Color(0xFF6B7280);
  static const Color textTertiaryLight = Color(0xFF9CA3AF);

  // ========================================
  // 🚨 STATUS & FEEDBACK - System-Farben
  // ========================================
  
  /// Erfolg - Magisches Grün
  static const Color success = Color(0xFF10B981);
  static const Color successLight = Color(0xFF34D399);
  static const Color successDark = Color(0xFF059669);
  
  /// Warnung - Mystisches Gold
  static const Color warning = Color(0xFFF59E0B);
  static const Color warningLight = Color(0xFFFBBF24);
  static const Color warningDark = Color(0xFFD97706);
  
  /// Fehler - Feurige Röte
  static const Color error = Color(0xFFEF4444);
  static const Color errorLight = Color(0xFFF87171);
  static const Color errorDark = Color(0xFFDC2626);
  
  /// Info - Portal-Blau
  static const Color info = Color(0xFF3B82F6);
  static const Color infoLight = Color(0xFF60A5FA);
  static const Color infoDark = Color(0xFF2563EB);

  // ========================================
  // ✨ SPEZIELLE EFFEKTE - Fantasy-Akzente
  // ========================================
  
  /// Leuchtende Rahmen und Highlights
  static const Color glow = Color(0xFF9D4EDD);
  static const Color glowSoft = Color(0xFF7209B7);
  static const Color shimmer = Color(0xFFFFD700);
  
  /// Magische Verläufe
  static const LinearGradient magicGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF4B3B79), Color(0xFF7C6BAF), Color(0xFFD4AF37)],
  );
  
  static const LinearGradient portalGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFF20B2AA), Color(0xFF4B3B79), Color(0xFF2E1F4A)],
  );

  // ========================================
  // 🎭 TRANSPARENZEN - Overlay & Glaseffekte
  // ========================================
  
  /// Für Overlay-Effekte
  static const Color overlay = Color(0x80000000);
  static const Color overlayLight = Color(0x40000000);
  static const Color overlayStrong = Color(0xB3000000);
  
  /// Für Glasmorphism-Effekte
  static const Color glass = Color(0x1AFFFFFF);
  static const Color glassDark = Color(0x1A000000);

  // ========================================
  // 🏷️ HELPER METHODS
  // ========================================
  
  /// Erstellt eine Farbe mit angepasster Opacity
  static Color withOpacity(Color color, double opacity) {
    return color.withOpacity(opacity);
  }
  
  /// Mischt zwei Farben
  static Color blend(Color color1, Color color2, double factor) {
    return Color.lerp(color1, color2, factor) ?? color1;
  }
}