import 'package:flutter/material.dart';
import '../../l10n/app_localizations.dart';

/// 🎨 Fullscreen Dialog System - Theme-aware & Focus-optimized
/// 
/// Ersetzt standard AlertDialog mit:
/// - Fullscreen overlay mit Abdunklung
/// - Mittig zentrierter Content  
/// - Theme-Context aware (World-Theme Support!)
/// - Besserer Fokus und UX
class FullscreenDialog {
  
  /// 🎯 Show Theme-aware Fullscreen Dialog
  static Future<T?> show<T>({
    required BuildContext context,
    required Widget content,
    String? title,
    List<Widget>? actions,
    bool barrierDismissible = true,
    Color? barrierColor,
    String? barrierLabel,
    Duration transitionDuration = const Duration(milliseconds: 300),
    ThemeData? themeOverride, // 🎨 NEW: Explizite Theme-Übertragung
  }) {
    return showGeneralDialog<T>(
      context: context,
      barrierDismissible: barrierDismissible,
      barrierLabel: barrierLabel ?? MaterialLocalizations.of(context).modalBarrierDismissLabel,
      barrierColor: barrierColor ?? Colors.black.withValues(alpha: 0.85), // Stärkere Abdunklung
      transitionDuration: transitionDuration,
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        // Smooth fade + scale animation
        return FadeTransition(
          opacity: CurvedAnimation(
            parent: animation,
            curve: Curves.easeInOutCubic,
          ),
          child: ScaleTransition(
            scale: CurvedAnimation(
              parent: animation,
              curve: Curves.easeInOutCubic,
            ).drive(Tween(begin: 0.8, end: 1.0)),
            child: child,
          ),
        );
      },
      pageBuilder: (dialogContext, animation, secondaryAnimation) {
        // 🎨 CRITICAL: Theme explizit oder aus dialogContext
        final effectiveTheme = themeOverride ?? Theme.of(dialogContext);
        
        return Theme(
          data: effectiveTheme, // 🌍 Explizite oder automatische Theme-Übertragung!
          child: _buildDialogContent(effectiveTheme, title, content, actions),
        );
      },
    );
  }

  /// 🎨 Build Dialog Content with explicit theme
  static Widget _buildDialogContent(ThemeData theme, String? title, Widget content, List<Widget>? actions) {
    final colorScheme = theme.colorScheme;
    
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: 500,
              minWidth: 320,
            ),
            child: Card(
              elevation: 16,
              shadowColor: colorScheme.shadow.withValues(alpha: 0.3),
              color: colorScheme.surface,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(
                  color: colorScheme.outline.withValues(alpha: 0.2),
                  width: 1,
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Header mit Titel und Close Button
                  if (title?.isNotEmpty == true)
                    Container(
                      padding: const EdgeInsets.fromLTRB(24, 20, 20, 16),
                      decoration: BoxDecoration(
                        // 🎨 VISUAL TEST: Verwende PRIMARY für bessere Sichtbarkeit des Themes
                        color: colorScheme.primary.withValues(alpha: 0.1),
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(16),
                          topRight: Radius.circular(16),
                        ),
                        border: Border(
                          bottom: BorderSide(
                            color: colorScheme.primary.withValues(alpha: 0.3), // PRIMARY für Theme-Test
                            width: 2, // Dicker für bessere Sichtbarkeit
                          ),
                        ),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              title!,
                              style: theme.textTheme.headlineSmall?.copyWith(
                                color: colorScheme.primary, // 🎨 PRIMARY für Theme-Test
                                fontWeight: FontWeight.w700, // Dicker für bessere Sichtbarkeit
                              ),
                            ),
                          ),
                          Builder(
                            builder: (context) => IconButton(
                              onPressed: () => Navigator.of(context).pop(),
                              icon: Icon(
                                Icons.close,
                                color: colorScheme.onSurface.withValues(alpha: 0.7),
                              ),
                              tooltip: AppLocalizations.of(context).tooltipClose,
                            ),
                          ),
                        ],
                      ),
                    ),
                  
                  // Content
                  Container(
                    padding: const EdgeInsets.all(24),
                    child: content,
                  ),
                  
                  // Actions
                  if (actions?.isNotEmpty == true)
                    Container(
                      padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
                      decoration: BoxDecoration(
                        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                        borderRadius: const BorderRadius.only(
                          bottomLeft: Radius.circular(16),
                          bottomRight: Radius.circular(16),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: actions!.length == 1 
                          ? actions
                          : [
                              for (int i = 0; i < actions.length; i++) ...[
                                if (i > 0) const SizedBox(width: 12),
                                actions[i],
                              ],
                            ],
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// 🎯 Convenience method for simple confirmation dialogs
  static Future<bool?> showConfirmation(
    BuildContext context, {
    required String title,
    required String message,
    String? confirmText,
    String? cancelText,
    bool isDestructive = false,
    Color? confirmColor,
    IconData? icon,
    ThemeData? themeOverride, // 🎨 NEW: Explizite Theme-Übertragung
  }) {
    final theme = themeOverride ?? Theme.of(context);
    final l10n = AppLocalizations.of(context);
    
    return show<bool>(
      context: context,
      title: title,
      themeOverride: themeOverride, // 🎨 Theme explizit durchreichen
      content: Row(
        children: [
          if (icon != null) ...[
            Icon(
              icon,
              color: isDestructive ? theme.colorScheme.error : theme.colorScheme.primary,
              size: 24,
            ),
            const SizedBox(width: 16),
          ],
          Expanded(
            child: Text(
              message,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.8),
              ),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          style: TextButton.styleFrom(
            foregroundColor: theme.colorScheme.onSurface.withValues(alpha: 0.7),
          ),
          child: Text(cancelText ?? l10n.buttonCancel),
        ),
        ElevatedButton(
          onPressed: () => Navigator.of(context).pop(true),
          style: ElevatedButton.styleFrom(
            backgroundColor: confirmColor ?? (isDestructive ? theme.colorScheme.error : theme.colorScheme.primary),
            foregroundColor: isDestructive ? theme.colorScheme.onError : theme.colorScheme.onPrimary,
          ),
          child: Text(confirmText ?? l10n.buttonConfirm),
        ),
      ],
    );
  }
}