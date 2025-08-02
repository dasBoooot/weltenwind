import 'package:flutter/material.dart';
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
    // Standard Frame für das neue modulare Theme System
    return AppFrame.magic(
      title: title,
      padding: padding,
      child: child,
    );
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
          const SizedBox(height: 32.0), // sectionMedium
          
          // 🏰 Seiten-Titel
          Text(
            pageTitle,
            style: theme.textTheme.headlineLarge?.copyWith(
              color: theme.colorScheme.onSurface,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16.0), // sm
          
          // 📝 Subtitle (optional)
          if (subtitle != null) ...[
            Text(
              subtitle,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.onSurface,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24.0), // sectionSmall
          ],
          
          // 📝 Inhalt
          child,
        ],
      ),
    );
  }
  
  /// Erstellt einen dynamischen Primary-Button für das neue modulare Theme System
  static Widget primaryButton({
    required String text,
    required VoidCallback? onPressed,
    required bool isLoading,
    required IconData icon,
    AppButtonSize size = AppButtonSize.large,
  }) {
    // Standard Button für das neue modulare Theme System
    return AppButton.magic(
      text: text,
      onPressed: onPressed,
      size: size,
      isLoading: isLoading,
      icon: icon,
    );
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