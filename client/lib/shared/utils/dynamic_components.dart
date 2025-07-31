import 'package:flutter/material.dart';
import '../../core/providers/theme_provider.dart';
import '../../theme/fantasy_theme.dart';
import '../../theme/tokens/spacing.dart';
import '../../theme/tokens/typography.dart';
import '../components/index.dart';

/// 🎨 Dynamische UI-Komponenten basierend auf dem aktuellen Style-Preset
/// 
/// Diese Klasse stellt statische Methoden zur Verfügung, um UI-Komponenten
/// dynamisch basierend auf dem aktuellen FantasyStylePreset zu erstellen.
class DynamicComponents {
  
  /// Erstellt einen dynamischen Frame basierend auf dem aktuellen Style-Preset
  static Widget frame({
    required String title,
    required EdgeInsetsGeometry padding,
    required Widget child,
  }) {
    final preset = ThemeProvider().stylePreset;
    
    switch (preset) {
      case FantasyStylePreset.mystical:
        return AppFrame.magic(
          title: title,
          padding: padding,
          child: child,
        );
      case FantasyStylePreset.ancient:
        return AppFrame.artifact(
          title: title,
          padding: padding,
          child: child,
        );
      case FantasyStylePreset.portal:
        return AppFrame.portal(
          title: title,
          padding: padding,
          child: child,
        );
    }
  }
  
  /// Erstellt einen dynamischen Auth-Frame mit Trennlinie und Titel-Struktur
  static Widget authFrame({
    required String welcomeTitle,
    required String pageTitle,
    required String? subtitle,
    required EdgeInsetsGeometry padding,
    required Widget child,
    required BuildContext context,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return frame(
      title: welcomeTitle,
      padding: padding,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // ✨ Trennlinie mit Abstand
          Container(
            width: double.infinity,
            height: 1,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.transparent,
                  theme.colorScheme.primary.withValues(alpha: 0.3),
                  Colors.transparent,
                ],
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.sectionMedium),
          
          // 🏰 Seiten-Titel
          Text(
            pageTitle,
            style: AppTypography.h2(isDark: isDark),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.sm),
          
          // 📝 Subtitle (optional)
          if (subtitle != null) ...[
            Text(
              subtitle,
              style: AppTypography.bodyLarge(isDark: isDark),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.sectionSmall),
          ],
          
          // 📝 Inhalt
          child,
        ],
      ),
    );
  }
  
  /// Erstellt einen dynamischen Primary-Button basierend auf dem aktuellen Style-Preset
  static Widget primaryButton({
    required String text,
    required VoidCallback? onPressed,
    required bool isLoading,
    required IconData icon,
    AppButtonSize size = AppButtonSize.large,
  }) {
    final preset = ThemeProvider().stylePreset;
    
    switch (preset) {
      case FantasyStylePreset.mystical:
        return AppButton.magic(
          text: text,
          onPressed: onPressed,
          size: size,
          isLoading: isLoading,
          icon: icon,
        );
      case FantasyStylePreset.ancient:
        return AppButton.artifact(
          text: text,
          onPressed: onPressed,
          size: size,
          isLoading: isLoading,
          icon: icon,
        );
      case FantasyStylePreset.portal:
        return AppButton.portal(
          text: text,
          onPressed: onPressed,
          size: size,
          isLoading: isLoading,
          icon: icon,
        );
    }
  }
  
  /// Erstellt einen dynamischen Secondary-Button (immer Ghost für Konsistenz)
  static Widget secondaryButton({
    required String text,
    required VoidCallback? onPressed,
    required AppButtonSize size,
    IconData? icon,
  }) {
    return AppButton.ghost(
      text: text,
      onPressed: onPressed,
      size: size,
      icon: icon,
    );
  }
  
  /// Erstellt einen dynamischen Tertiary-Button (kleiner Ghost)
  static Widget tertiaryButton({
    required String text,
    required VoidCallback? onPressed,
    AppButtonSize size = AppButtonSize.small,
  }) {
    return AppButton.ghost(
      text: text,
      onPressed: onPressed,
      size: size,
    );
  }
}