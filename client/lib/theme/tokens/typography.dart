import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'colors.dart';

/// 📝 Weltenwind Typography System
/// 
/// Fantasy-inspirierte Typografie mit modernen Lesbarkeitsstandards
/// Headlines: Cinzel (Serif) | Body: Inter (Sans-Serif) | Code: JetBrains Mono
class AppTypography {
  // ========================================
  // 🎭 FANTASY FONT FAMILIES
  // ========================================
  
  /// Magische Headlines - Cinzel (elegante Serif)
  static TextStyle get _cinzelBase => GoogleFonts.cinzel();
  
  /// Alternative: Merriweather für weniger dramatische Headlines
  static TextStyle get _merriweatherBase => GoogleFonts.merriweather();
  
  /// Körpertext - Inter (moderne Sans-Serif)
  static TextStyle get _interBase => GoogleFonts.inter();
  
  /// Code/Zahlen - JetBrains Mono
  static TextStyle get _jetBrainsMonoBase => GoogleFonts.jetBrainsMono();

  // ========================================
  // 🏷️ HEADLINE STYLES - Mystische Titel
  // ========================================
  
  /// H1 - Haupttitel (Seitentitel, Logo)
  static TextStyle h1({Color? color, bool isDark = true}) => _cinzelBase.copyWith(
    fontSize: 32.0,
    fontWeight: FontWeight.w600,
    letterSpacing: 1.2,
    height: 1.2,
    color: color ?? (isDark ? AppColors.textPrimary : AppColors.textPrimaryLight),
  );
  
  /// H2 - Section-Titel
  static TextStyle h2({Color? color, bool isDark = true}) => _cinzelBase.copyWith(
    fontSize: 24.0,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.8,
    height: 1.3,
    color: color ?? (isDark ? AppColors.textPrimary : AppColors.textPrimaryLight),
  );
  
  /// H3 - Subsection-Titel
  static TextStyle h3({Color? color, bool isDark = true}) => _cinzelBase.copyWith(
    fontSize: 20.0,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.6,
    height: 1.3,
    color: color ?? (isDark ? AppColors.textPrimary : AppColors.textPrimaryLight),
  );
  
  /// H4 - Card-Titel
  static TextStyle h4({Color? color, bool isDark = true}) => _interBase.copyWith(
    fontSize: 18.0,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.4,
    height: 1.4,
    color: color ?? (isDark ? AppColors.textPrimary : AppColors.textPrimaryLight),
  );
  
  /// H5 - Kleine Überschriften
  static TextStyle h5({Color? color, bool isDark = true}) => _interBase.copyWith(
    fontSize: 16.0,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.2,
    height: 1.4,
    color: color ?? (isDark ? AppColors.textPrimary : AppColors.textPrimaryLight),
  );
  
  /// H6 - Mini-Überschriften
  static TextStyle h6({Color? color, bool isDark = true}) => _interBase.copyWith(
    fontSize: 14.0,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.1,
    height: 1.4,
    color: color ?? (isDark ? AppColors.textPrimary : AppColors.textPrimaryLight),
  );

  // ========================================
  // 📖 BODY TEXT STYLES - Lesbarer Content
  // ========================================
  
  /// Body Large - Haupttext, wichtige Inhalte
  static TextStyle bodyLarge({Color? color, bool isDark = true}) => _interBase.copyWith(
    fontSize: 16.0,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.1,
    height: 1.5,
    color: color ?? (isDark ? AppColors.textPrimary : AppColors.textPrimaryLight),
  );
  
  /// Body Medium - Standard-Körpertext
  static TextStyle bodyMedium({Color? color, bool isDark = true}) => _interBase.copyWith(
    fontSize: 14.0,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.0,
    height: 1.5,
    color: color ?? (isDark ? AppColors.textSecondary : AppColors.textSecondaryLight),
  );
  
  /// Body Small - Sekundärer Text, Beschreibungen
  static TextStyle bodySmall({Color? color, bool isDark = true}) => _interBase.copyWith(
    fontSize: 12.0,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.0,
    height: 1.4,
    color: color ?? (isDark ? AppColors.textTertiary : AppColors.textTertiaryLight),
  );

  // ========================================
  // 🏷️ LABEL & UI STYLES - Interface-Elemente
  // ========================================
  
  /// Label Large - Button-Text, wichtige Labels
  static TextStyle labelLarge({Color? color, bool isDark = true}) => _interBase.copyWith(
    fontSize: 14.0,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.2,
    height: 1.4,
    color: color ?? (isDark ? AppColors.textPrimary : AppColors.textPrimaryLight),
  );
  
  /// Label Medium - Standard-Labels
  static TextStyle labelMedium({Color? color, bool isDark = true}) => _interBase.copyWith(
    fontSize: 12.0,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.4,
    height: 1.3,
    color: color ?? (isDark ? AppColors.textSecondary : AppColors.textSecondaryLight),
  );
  
  /// Label Small - Kleine UI-Labels, Hints
  static TextStyle labelSmall({Color? color, bool isDark = true}) => _interBase.copyWith(
    fontSize: 10.0,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.6,
    height: 1.2,
    color: color ?? (isDark ? AppColors.textTertiary : AppColors.textTertiaryLight),
  );

  // ========================================
  // 🔢 SPECIAL PURPOSE STYLES
  // ========================================
  
  /// Code/Monospace - Zahlen, IDs, Code
  static TextStyle code({Color? color, bool isDark = true}) => _jetBrainsMonoBase.copyWith(
    fontSize: 13.0,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.0,
    height: 1.4,
    color: color ?? (isDark ? AppColors.aqua : AppColors.aquaDark),
  );
  
  /// Caption - Bildunterschriften, Timestamps
  static TextStyle caption({Color? color, bool isDark = true}) => _interBase.copyWith(
    fontSize: 11.0,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.2,
    height: 1.3,
    color: color ?? (isDark ? AppColors.textTertiary : AppColors.textTertiaryLight),
  );
  
  /// Overline - Über-Bezeichnungen, Kategorien
  static TextStyle overline({Color? color, bool isDark = true}) => _interBase.copyWith(
    fontSize: 10.0,
    fontWeight: FontWeight.w600,
    letterSpacing: 1.0,
    height: 1.2,
    color: color ?? (isDark ? AppColors.secondary : AppColors.secondaryDark),
  );

  // ========================================
  // ✨ FANTASY-SPEZIELLE STYLES
  // ========================================
  
  /// Mystical Title - Für besondere Titel mit magischem Flair
  static TextStyle mysticalTitle({Color? color, bool isDark = true}) => _cinzelBase.copyWith(
    fontSize: 28.0,
    fontWeight: FontWeight.w700,
    letterSpacing: 2.0,
    height: 1.2,
    color: color ?? AppColors.secondary,
    shadows: [
      Shadow(
        offset: const Offset(0, 2),
        blurRadius: 8.0,
        color: AppColors.glow.withOpacity(0.3),
      ),
    ],
  );
  
  /// Portal Text - Für magische UI-Elemente
  static TextStyle portalText({Color? color, bool isDark = true}) => _interBase.copyWith(
    fontSize: 14.0,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.8,
    height: 1.4,
    color: color ?? AppColors.aqua,
  );
  
  /// Artifact Name - Für Item-Namen mit Glamour
  static TextStyle artifactName({Color? color, bool isDark = true}) => _merriweatherBase.copyWith(
    fontSize: 16.0,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.3,
    height: 1.3,
    color: color ?? AppColors.secondary,
  );

  // ========================================
  // 🎨 THEME HELPER METHODS
  // ========================================
  
  /// Erstellt TextTheme für Flutter Theme
  static TextTheme createTextTheme({bool isDark = true}) {
    return TextTheme(
      // Headlines
      headlineLarge: h1(isDark: isDark),
      headlineMedium: h2(isDark: isDark),
      headlineSmall: h3(isDark: isDark),
      
      // Titles
      titleLarge: h4(isDark: isDark),
      titleMedium: h5(isDark: isDark),
      titleSmall: h6(isDark: isDark),
      
      // Body
      bodyLarge: bodyLarge(isDark: isDark),
      bodyMedium: bodyMedium(isDark: isDark),
      bodySmall: bodySmall(isDark: isDark),
      
      // Labels
      labelLarge: labelLarge(isDark: isDark),
      labelMedium: labelMedium(isDark: isDark),
      labelSmall: labelSmall(isDark: isDark),
    );
  }
  
  /// Lädt alle Google Fonts vorab (Performance-Optimierung)
  static Future<void> preloadFonts() async {
    // Fonts durch Aufrufen der Base-Getters preloaden
    _cinzelBase;
    _interBase;
    _jetBrainsMonoBase;
    _merriweatherBase;
    
    // Alternative: Spezifische Fonts vorab laden
    await Future.wait([
      GoogleFonts.pendingFonts([
        GoogleFonts.cinzel(),
        GoogleFonts.inter(),
        GoogleFonts.jetBrainsMono(),
        GoogleFonts.merriweather(),
      ]),
    ]);
  }
}