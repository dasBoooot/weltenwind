import 'package:flutter/material.dart';
import '../../l10n/app_localizations.dart';
import '../../features/invite/widgets/invite_widget.dart';
import '../../core/services/api_service.dart';
import '../../main.dart';
import 'fullscreen_dialog.dart';

/// 🎨 Theme-aware Fullscreen Invite Dialog
/// 
/// Ersetzt die alte showInviteDialog Implementierung mit:
/// - Fullscreen overlay statt kleine Box
/// - Theme-Context aware
/// - Bessere UX und Fokus
class InviteFullscreenDialog {
  
  /// 🎯 Show Theme-aware Fullscreen Invite Dialog
  static Future<T?> show<T>({
    required BuildContext context,
    required String worldId,
    required String worldName,
    VoidCallback? onInviteSent,
    ThemeData? themeOverride, // 🎨 NEW: Explizite Theme-Übertragung
  }) {
    final l10n = AppLocalizations.of(context);
    
    return FullscreenDialog.show<T>(
      context: context,
      title: l10n.inviteWidgetDialogTitle,
      barrierDismissible: true,
      barrierColor: Colors.black.withValues(alpha: 0.85), // Stärkere Abdunklung
      themeOverride: themeOverride, // 🎨 Theme explizit durchreichen
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          InviteWidget(
            worldId: worldId,
            worldName: worldName,
            onInviteSent: () {
              // Close dialog after successful invite
              Navigator.of(context).pop();
              onInviteSent?.call();
            },
            isDialog: true,
            apiService: ServiceLocator.get<ApiService>(), // Correct typed service access
          ),
          const SizedBox(height: 16),
          // Cancel Button mit korrektem Theme-Kontext
          Builder(
            builder: (context) {
              return TextButton(
                onPressed: () => Navigator.of(context).pop(),
                style: TextButton.styleFrom(
                  foregroundColor: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                ),
                child: Text(l10n.inviteWidgetCancel),
              );
            },
          ),
        ],
      ),
    );
  }
}

/// 🔧 Drop-in replacement for old showInviteDialog
/// 
/// This maintains API compatibility while using the new fullscreen system
Future<T?> showInviteDialog<T extends Object?>(
  BuildContext context, {
  required String worldId,
  required String worldName,
  VoidCallback? onInviteSent,
  ThemeData? themeOverride, // 🎨 NEW: Explizite Theme-Übertragung
}) {
  return InviteFullscreenDialog.show<T>(
    context: context,
    worldId: worldId,
    worldName: worldName,
    onInviteSent: onInviteSent,
    themeOverride: themeOverride, // 🎨 Theme explizit durchreichen
  );
}