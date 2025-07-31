import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'tokens/colors.dart';
import 'tokens/spacing.dart';
import 'tokens/typography.dart';

/// 🎭 Fantasy Style Presets
/// 
/// Definiert verschiedene Stil-Varianten für das Fantasy-Theme
enum FantasyStylePreset {
  /// 🔮 Mystical - Fokus auf Magic-Komponenten
  mystical,
  
  /// 📜 Ancient - Fokus auf Artifact-Komponenten  
  ancient,
  
  /// 🌀 Portal - Fokus auf Portal-Komponenten
  portal,
}


/// 🏰 Weltenwind Fantasy Theme System
/// 
/// Vollständiges Theme-System mit mystischer Fantasy-Ästhetik
/// Integriert alle Design-Tokens in ein kohärentes Erscheinungsbild
class FantasyTheme {
  // ========================================
  // 🎨 LIGHT THEME - Tageslicht-Modus
  // ========================================
  
  static ThemeData get lightTheme {
    const brightness = Brightness.light;
    const isDark = false;
    
    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      
      // === COLOR SCHEME ===
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primary,
        brightness: brightness,
        primary: AppColors.primary,
        primaryContainer: AppColors.primaryLight,
        secondary: AppColors.secondary,
        secondaryContainer: AppColors.secondaryLight,
        tertiary: AppColors.tertiary,
        surface: AppColors.surfaceWhite,
        background: AppColors.surfaceGrayLight,
        error: AppColors.error,
        onPrimary: Colors.white,
        onSecondary: AppColors.surfaceDark,
        onSurface: AppColors.textPrimaryLight,
        onBackground: AppColors.textPrimaryLight,
        outline: AppColors.surfaceGray,
      ),
      
      // === TYPOGRAPHY ===
      textTheme: AppTypography.createTextTheme(isDark: isDark),
      
      // === APP BAR ===
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.surfaceWhite,
        foregroundColor: AppColors.textPrimaryLight,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: AppTypography.h4(isDark: isDark),
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        shadowColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
      ),
      
      // === CARD THEME ===
      cardTheme: CardThemeData(
        color: AppColors.surfaceWhite,
        elevation: 0,
        shadowColor: Colors.black26,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.0),
        ),
        clipBehavior: Clip.antiAlias,
        margin: const EdgeInsets.all(AppSpacing.xs),
      ),
      
      // === ELEVATED BUTTON ===
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          elevation: 0,
          shadowColor: Colors.transparent,
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.buttonPaddingHorizontal,
            vertical: AppSpacing.buttonPaddingVertical,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.0),
          ),
          textStyle: AppTypography.labelLarge(isDark: isDark),
        ).copyWith(
          overlayColor: MaterialStateProperty.resolveWith((states) {
            if (states.contains(MaterialState.pressed)) {
              return AppColors.primaryDark.withOpacity(0.2);
            }
            if (states.contains(MaterialState.hovered)) {
              return AppColors.primaryLight.withOpacity(0.1);
            }
            return null;
          }),
        ),
      ),
      
      // === OUTLINED BUTTON ===
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primary,
          side: const BorderSide(color: AppColors.primary, width: 1.5),
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.buttonPaddingHorizontal,
            vertical: AppSpacing.buttonPaddingVertical,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.0),
          ),
          textStyle: AppTypography.labelLarge(isDark: isDark),
        ),
      ),
      
      // === TEXT BUTTON ===
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primary,
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm,
          ),
          textStyle: AppTypography.labelLarge(isDark: isDark),
        ),
      ),
      
      // === INPUT DECORATION ===
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surfaceGray,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.inputPaddingHorizontal,
          vertical: AppSpacing.inputPaddingVertical,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
          borderSide: const BorderSide(color: AppColors.surfaceGray),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
          borderSide: const BorderSide(color: AppColors.surfaceGray),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
          borderSide: const BorderSide(color: AppColors.primary, width: 2.0),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
          borderSide: const BorderSide(color: AppColors.error, width: 1.5),
        ),
        labelStyle: AppTypography.labelMedium(isDark: isDark),
        hintStyle: AppTypography.bodyMedium(
          color: AppColors.textTertiaryLight,
          isDark: isDark,
        ),
      ),
      
      // === FLOATING ACTION BUTTON ===
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: AppColors.secondary,
        foregroundColor: AppColors.surfaceDark,
        elevation: 6.0,
        highlightElevation: 12.0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(16.0)),
        ),
      ),
      
      // === NAVIGATION ===
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: AppColors.surfaceWhite,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.textTertiaryLight,
        type: BottomNavigationBarType.fixed,
        elevation: 8.0,
        selectedLabelStyle: AppTypography.labelSmall(isDark: isDark),
        unselectedLabelStyle: AppTypography.labelSmall(isDark: isDark),
      ),
      
      // === DIVIDER ===
      dividerTheme: const DividerThemeData(
        color: AppColors.surfaceGray,
        thickness: 1.0,
        space: AppSpacing.md,
      ),
      
      // === DIALOG ===
      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.surfaceWhite,
        elevation: 24.0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.0),
        ),
        titleTextStyle: AppTypography.h4(isDark: isDark),
        contentTextStyle: AppTypography.bodyMedium(isDark: isDark),
      ),
      
      // === BOTTOM SHEET ===
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: AppColors.surfaceWhite,
        elevation: 16.0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(20.0),
          ),
        ),
        clipBehavior: Clip.antiAlias,
      ),
    );
  }
  
  // ========================================
  // 🌙 DARK THEME - Nachts-Modus (Fantasy-Fokus)
  // ========================================
  
  static ThemeData get darkTheme {
    const brightness = Brightness.dark;
    const isDark = true;
    
    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      
      // === COLOR SCHEME ===
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primary,
        brightness: brightness,
        primary: AppColors.primaryAccent,
        primaryContainer: AppColors.primary,
        secondary: AppColors.secondary,
        secondaryContainer: AppColors.secondaryDark,
        tertiary: AppColors.aqua,
        surface: AppColors.surfaceMedium,
        background: AppColors.surfaceDark,
        error: AppColors.error,
        onPrimary: AppColors.surfaceDark,
        onSecondary: AppColors.surfaceDark,
        onSurface: AppColors.textPrimary,
        onBackground: AppColors.textPrimary,
        outline: AppColors.surfaceLight,
      ),
      
      // === TYPOGRAPHY ===
      textTheme: AppTypography.createTextTheme(isDark: isDark),
      
      // === APP BAR ===
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.surfaceDarker,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: AppTypography.h4(isDark: isDark),
        systemOverlayStyle: SystemUiOverlayStyle.light,
        shadowColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
      ),
      
      // === CARD THEME ===
      cardTheme: CardThemeData(
        color: AppColors.surfaceMedium,
        elevation: 0,
        shadowColor: Colors.black54,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.0),
          side: BorderSide(
            color: AppColors.surfaceLight.withOpacity(0.2),
            width: 1.0,
          ),
        ),
        clipBehavior: Clip.antiAlias,
        margin: const EdgeInsets.all(AppSpacing.xs),
      ),
      
      // === ELEVATED BUTTON ===
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryAccent,
          foregroundColor: AppColors.surfaceDark,
          elevation: 0,
          shadowColor: Colors.transparent,
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.buttonPaddingHorizontal,
            vertical: AppSpacing.buttonPaddingVertical,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.0),
          ),
          textStyle: AppTypography.labelLarge(
            color: AppColors.surfaceDark,
            isDark: isDark,
          ),
        ).copyWith(
          overlayColor: MaterialStateProperty.resolveWith((states) {
            if (states.contains(MaterialState.pressed)) {
              return AppColors.primary.withOpacity(0.3);
            }
            if (states.contains(MaterialState.hovered)) {
              return AppColors.primaryLight.withOpacity(0.2);
            }
            return null;
          }),
        ),
      ),
      
      // === OUTLINED BUTTON ===
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primaryAccent,
          side: const BorderSide(color: AppColors.primaryAccent, width: 1.5),
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.buttonPaddingHorizontal,
            vertical: AppSpacing.buttonPaddingVertical,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.0),
          ),
          textStyle: AppTypography.labelLarge(isDark: isDark),
        ),
      ),
      
      // === TEXT BUTTON ===
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primaryAccent,
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm,
          ),
          textStyle: AppTypography.labelLarge(isDark: isDark),
        ),
      ),
      
      // === INPUT DECORATION ===
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surfaceLight,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.inputPaddingHorizontal,
          vertical: AppSpacing.inputPaddingVertical,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
          borderSide: const BorderSide(color: AppColors.surfaceLight),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
          borderSide: const BorderSide(color: AppColors.surfaceLight),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
          borderSide: const BorderSide(color: AppColors.primaryAccent, width: 2.0),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
          borderSide: const BorderSide(color: AppColors.error, width: 1.5),
        ),
        labelStyle: AppTypography.labelMedium(isDark: isDark),
        hintStyle: AppTypography.bodyMedium(
          color: AppColors.textTertiary,
          isDark: isDark,
        ),
      ),
      
      // === FLOATING ACTION BUTTON ===
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: AppColors.secondary,
        foregroundColor: AppColors.surfaceDark,
        elevation: 8.0,
        highlightElevation: 16.0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(16.0)),
        ),
      ),
      
      // === NAVIGATION ===
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: AppColors.surfaceDarker,
        selectedItemColor: AppColors.secondary,
        unselectedItemColor: AppColors.textTertiary,
        type: BottomNavigationBarType.fixed,
        elevation: 12.0,
        selectedLabelStyle: AppTypography.labelSmall(isDark: isDark),
        unselectedLabelStyle: AppTypography.labelSmall(isDark: isDark),
      ),
      
      // === DIVIDER ===
      dividerTheme: const DividerThemeData(
        color: AppColors.surfaceLight,
        thickness: 1.0,
        space: AppSpacing.md,
      ),
      
      // === DIALOG ===
      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.surfaceMedium,
        elevation: 32.0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.0),
          side: BorderSide(
            color: AppColors.primaryAccent.withOpacity(0.3),
            width: 1.0,
          ),
        ),
        titleTextStyle: AppTypography.h4(isDark: isDark),
        contentTextStyle: AppTypography.bodyMedium(isDark: isDark),
      ),
      
      // === BOTTOM SHEET ===
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: AppColors.surfaceMedium,
        elevation: 24.0,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(20.0),
          ),
        ),
        clipBehavior: Clip.antiAlias,
      ),
      
      // === SCAFFOLD ===
      scaffoldBackgroundColor: AppColors.surfaceDark,
    );
  }
  
  // ========================================
  // 🎨 THEME EXTENSIONS - Spezielle Fantasy-Elemente
  // ========================================
  
  /// Custom Theme Extension für Fantasy-spezifische Styles
  static ThemeExtension<FantasyThemeExtension> get _fantasyExtension {
    return const FantasyThemeExtension(
      magicGradient: AppColors.magicGradient,
      portalGradient: AppColors.portalGradient,
      glowColor: AppColors.glow,
      shimmerColor: AppColors.shimmer,
    );
  }
  
  // ========================================
  // 🛠️ HELPER METHODS
  // ========================================
  
  /// Erweitert das Light Theme mit Fantasy-Extensions
  static ThemeData get enhancedLightTheme {
    return lightTheme.copyWith(
      extensions: [_fantasyExtension],
    );
  }
  
  /// Erweitert das Dark Theme mit Fantasy-Extensions
  static ThemeData get enhancedDarkTheme {
    return darkTheme.copyWith(
      extensions: [_fantasyExtension],
    );
  }
  
  /// Erstellt ein Theme basierend auf Style-Preset
  static ThemeData getThemeForPreset({
    required Brightness brightness,
    required FantasyStylePreset preset,
  }) {
    final baseTheme = brightness == Brightness.light ? lightTheme : darkTheme;
    final extension = _getExtensionForPreset(preset);
    
    return baseTheme.copyWith(
      extensions: [extension],
      // Preset-spezifische Farbanpassungen
      colorScheme: _getColorSchemeForPreset(brightness, preset),
    );
  }
  
  /// Erstellt Theme-Extension basierend auf Style-Preset
  static FantasyThemeExtension _getExtensionForPreset(FantasyStylePreset preset) {
    switch (preset) {
      case FantasyStylePreset.mystical:
        return FantasyThemeExtension(
          magicGradient: AppColors.magicGradient,
          portalGradient: AppColors.portalGradient,
          glowColor: AppColors.glow,
          shimmerColor: AppColors.shimmer,
        );
      case FantasyStylePreset.ancient:
        return FantasyThemeExtension(
          magicGradient: LinearGradient(
            colors: [AppColors.secondary, AppColors.amber],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          portalGradient: LinearGradient(
            colors: [AppColors.amber, AppColors.secondary],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          glowColor: AppColors.amber,
          shimmerColor: AppColors.secondary,
        );
      case FantasyStylePreset.portal:
        return FantasyThemeExtension(
          magicGradient: LinearGradient(
            colors: [AppColors.aqua, AppColors.primary],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          portalGradient: LinearGradient(
            colors: [AppColors.primary, AppColors.aqua],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          glowColor: AppColors.aqua,
          shimmerColor: AppColors.primary,
        );
    }
  }
  
  /// Erstellt ColorScheme basierend auf Style-Preset
  static ColorScheme _getColorSchemeForPreset(Brightness brightness, FantasyStylePreset preset) {
    final baseScheme = brightness == Brightness.light 
        ? ColorScheme.fromSeed(seedColor: AppColors.primary, brightness: brightness)
        : ColorScheme.fromSeed(seedColor: AppColors.primary, brightness: brightness);
    
    switch (preset) {
      case FantasyStylePreset.mystical:
        return baseScheme.copyWith(
          primary: AppColors.primary,
          secondary: AppColors.secondary,
          tertiary: AppColors.aqua,
        );
      case FantasyStylePreset.ancient:
        return baseScheme.copyWith(
          primary: AppColors.secondary,
          secondary: AppColors.amber,
          tertiary: AppColors.secondary,
        );
      case FantasyStylePreset.portal:
        return baseScheme.copyWith(
          primary: AppColors.aqua,
          secondary: AppColors.primary,
          tertiary: AppColors.primaryAccent,
        );
    }
  }
  
  /// Preloads alle Fonts für bessere Performance
  static Future<void> preloadAssets() async {
    await AppTypography.preloadFonts();
  }
}

/// Custom Theme Extension für Fantasy-spezifische Designelemente
@immutable
class FantasyThemeExtension extends ThemeExtension<FantasyThemeExtension> {
  final LinearGradient magicGradient;
  final LinearGradient portalGradient;
  final Color glowColor;
  final Color shimmerColor;
  
  const FantasyThemeExtension({
    required this.magicGradient,
    required this.portalGradient,
    required this.glowColor,
    required this.shimmerColor,
  });
  
  @override
  FantasyThemeExtension copyWith({
    LinearGradient? magicGradient,
    LinearGradient? portalGradient,
    Color? glowColor,
    Color? shimmerColor,
  }) {
    return FantasyThemeExtension(
      magicGradient: magicGradient ?? this.magicGradient,
      portalGradient: portalGradient ?? this.portalGradient,
      glowColor: glowColor ?? this.glowColor,
      shimmerColor: shimmerColor ?? this.shimmerColor,
    );
  }
  
  @override
  FantasyThemeExtension lerp(FantasyThemeExtension? other, double t) {
    if (other is! FantasyThemeExtension) return this;
    return FantasyThemeExtension(
      magicGradient: LinearGradient.lerp(magicGradient, other.magicGradient, t) ?? magicGradient,
      portalGradient: LinearGradient.lerp(portalGradient, other.portalGradient, t) ?? portalGradient,
      glowColor: Color.lerp(glowColor, other.glowColor, t) ?? glowColor,
      shimmerColor: Color.lerp(shimmerColor, other.shimmerColor, t) ?? shimmerColor,
    );
  }
}