import 'package:flutter/material.dart';

/// 🌟 Weltenwind Shadow & Glow System
/// 
/// Mystische Schatten und Leuchteffekte für Fantasy-UI
class AppShadows {
  // ========================================
  // 🖤 STANDARD SHADOWS - Tiefe & Struktur
  // ========================================
  
  /// Keine Elevation - flache Elemente
  static const List<BoxShadow> none = [];
  
  /// Minimal - Subtile Abhebung (Cards auf Background)
  static const List<BoxShadow> minimal = [
    BoxShadow(
      offset: Offset(0, 1),
      blurRadius: 2.0,
      spreadRadius: 0,
      color: Color(0x1A000000),
    ),
  ];
  
  /// Small - Leichte Elevation (Buttons, kleine Cards)
  static const List<BoxShadow> small = [
    BoxShadow(
      offset: Offset(0, 2),
      blurRadius: 4.0,
      spreadRadius: 0,
      color: Color(0x1F000000),
    ),
    BoxShadow(
      offset: Offset(0, 1),
      blurRadius: 2.0,
      spreadRadius: 0,
      color: Color(0x0A000000),
    ),
  ];
  
  /// Medium - Standard-Elevation (Cards, Panels)
  static const List<BoxShadow> medium = [
    BoxShadow(
      offset: Offset(0, 4),
      blurRadius: 8.0,
      spreadRadius: 0,
      color: Color(0x1F000000),
    ),
    BoxShadow(
      offset: Offset(0, 2),
      blurRadius: 4.0,
      spreadRadius: 0,
      color: Color(0x0F000000),
    ),
  ];
  
  /// Large - Hohe Elevation (Modals, wichtige Elemente)
  static const List<BoxShadow> large = [
    BoxShadow(
      offset: Offset(0, 8),
      blurRadius: 16.0,
      spreadRadius: 0,
      color: Color(0x24000000),
    ),
    BoxShadow(
      offset: Offset(0, 4),
      blurRadius: 8.0,
      spreadRadius: 0,
      color: Color(0x14000000),
    ),
  ];
  
  /// XLarge - Maximale Elevation (Overlays, wichtige Dialoge)
  static const List<BoxShadow> xlarge = [
    BoxShadow(
      offset: Offset(0, 16),
      blurRadius: 32.0,
      spreadRadius: 0,
      color: Color(0x2E000000),
    ),
    BoxShadow(
      offset: Offset(0, 8),
      blurRadius: 16.0,
      spreadRadius: 0,
      color: Color(0x19000000),
    ),
  ];

  // ========================================
  // ✨ MAGICAL GLOWS - Fantasy-Leuchteffekte
  // ========================================
  
  /// Magischer Glow - Violett für mystische Elemente
  static const List<BoxShadow> magicGlow = [
    BoxShadow(
      offset: Offset(0, 0),
      blurRadius: 12.0,
      spreadRadius: 2.0,
      color: Color(0x409D4EDD), // AppColors.glow mit Transparenz
    ),
    BoxShadow(
      offset: Offset(0, 4),
      blurRadius: 8.0,
      spreadRadius: 0,
      color: Color(0x1F000000),
    ),
  ];
  
  /// Portal Glow - Cyan-Aqua für Portale und Wasser-Magie
  static const List<BoxShadow> portalGlow = [
    BoxShadow(
      offset: Offset(0, 0),
      blurRadius: 16.0,
      spreadRadius: 1.0,
      color: Color(0x4020B2AA), // AppColors.aqua mit Transparenz
    ),
    BoxShadow(
      offset: Offset(0, 6),
      blurRadius: 12.0,
      spreadRadius: 0,
      color: Color(0x24000000),
    ),
  ];
  
  /// Golden Glow - Für Artefakte und wertvolle Items
  static const List<BoxShadow> goldenGlow = [
    BoxShadow(
      offset: Offset(0, 0),
      blurRadius: 14.0,
      spreadRadius: 1.0,
      color: Color(0x40D4AF37), // AppColors.secondary mit Transparenz
    ),
    BoxShadow(
      offset: Offset(0, 4),
      blurRadius: 8.0,
      spreadRadius: 0,
      color: Color(0x1F000000),
    ),
  ];
  
  /// Success Glow - Grün für positive Aktionen
  static const List<BoxShadow> successGlow = [
    BoxShadow(
      offset: Offset(0, 0),
      blurRadius: 10.0,
      spreadRadius: 1.0,
      color: Color(0x4010B981), // AppColors.success mit Transparenz
    ),
    BoxShadow(
      offset: Offset(0, 2),
      blurRadius: 4.0,
      spreadRadius: 0,
      color: Color(0x1F000000),
    ),
  ];
  
  /// Error Glow - Rot für Fehler und Warnungen
  static const List<BoxShadow> errorGlow = [
    BoxShadow(
      offset: Offset(0, 0),
      blurRadius: 10.0,
      spreadRadius: 1.0,
      color: Color(0x40EF4444), // AppColors.error mit Transparenz
    ),
    BoxShadow(
      offset: Offset(0, 2),
      blurRadius: 4.0,
      spreadRadius: 0,
      color: Color(0x1F000000),
    ),
  ];

  // ========================================
  // 🎭 SPECIAL EFFECTS - Dramatische Effekte
  // ========================================
  
  /// Inner Glow - Für glasartige Effekte
  static const List<BoxShadow> innerGlow = [
    BoxShadow(
      offset: Offset(0, 0),
      blurRadius: 8.0,
      spreadRadius: -2.0,
      color: Color(0x4AFFFFFF),
    ),
  ];
  
  /// Pressed State - Für gedrückte Buttons
  static const List<BoxShadow> pressed = [
    BoxShadow(
      offset: Offset(0, 1),
      blurRadius: 2.0,
      spreadRadius: 0,
      color: Color(0x14000000),
    ),
  ];
  
  /// Hover State - Für schwebende Elemente
  static const List<BoxShadow> hover = [
    BoxShadow(
      offset: Offset(0, 6),
      blurRadius: 12.0,
      spreadRadius: 0,
      color: Color(0x24000000),
    ),
    BoxShadow(
      offset: Offset(0, 3),
      blurRadius: 6.0,
      spreadRadius: 0,
      color: Color(0x14000000),
    ),
  ];

  // ========================================
  // 📱 RESPONSIVE SHADOWS - Geräte-abhängig
  // ========================================
  
  /// Mobile-optimierte Schatten (weniger intensiv)
  static const List<BoxShadow> mobileMedium = [
    BoxShadow(
      offset: Offset(0, 2),
      blurRadius: 4.0,
      spreadRadius: 0,
      color: Color(0x1A000000),
    ),
  ];
  
  /// Desktop-Schatten (intensiver für größere Bildschirme)
  static const List<BoxShadow> desktopMedium = [
    BoxShadow(
      offset: Offset(0, 6),
      blurRadius: 12.0,
      spreadRadius: 0,
      color: Color(0x24000000),
    ),
    BoxShadow(
      offset: Offset(0, 3),
      blurRadius: 6.0,
      spreadRadius: 0,
      color: Color(0x14000000),
    ),
  ];

  // ========================================
  // 🎨 TEXT SHADOWS - Für Typografie
  // ========================================
  
  /// Subtiler Text-Schatten für bessere Lesbarkeit
  static const List<Shadow> textSubtle = [
    Shadow(
      offset: Offset(0, 1),
      blurRadius: 2.0,
      color: Color(0x40000000),
    ),
  ];
  
  /// Mystischer Text-Glow
  static const List<Shadow> textMystic = [
    Shadow(
      offset: Offset(0, 0),
      blurRadius: 8.0,
      color: Color(0x609D4EDD), // AppColors.glow
    ),
    Shadow(
      offset: Offset(0, 2),
      blurRadius: 4.0,
      color: Color(0x40000000),
    ),
  ];
  
  /// Goldener Text-Glow für Titel
  static const List<Shadow> textGolden = [
    Shadow(
      offset: Offset(0, 0),
      blurRadius: 6.0,
      color: Color(0x60D4AF37), // AppColors.secondary
    ),
    Shadow(
      offset: Offset(0, 1),
      blurRadius: 2.0,
      color: Color(0x40000000),
    ),
  ];

  // ========================================
  // 🛠️ HELPER METHODS
  // ========================================
  
  /// Erstellt angepasste Schatten mit eigener Farbe
  static List<BoxShadow> customGlow({
    required Color color,
    double intensity = 0.4,
    double blurRadius = 12.0,
    double spreadRadius = 2.0,
    Offset offset = const Offset(0, 0),
  }) {
    return [
      BoxShadow(
        offset: offset,
        blurRadius: blurRadius,
        spreadRadius: spreadRadius,
        color: color.withValues(alpha: intensity),
      ),
      const BoxShadow(
        offset: Offset(0, 4),
        blurRadius: 8.0,
        spreadRadius: 0,
        color: Color(0x1F000000),
      ),
    ];
  }
  
  /// Responsive Schatten basierend auf Bildschirmgröße
  static List<BoxShadow> responsive(double screenWidth) {
    if (screenWidth < 600) return mobileMedium;
    return desktopMedium;
  }
}