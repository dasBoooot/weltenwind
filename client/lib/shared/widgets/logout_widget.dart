import 'package:flutter/material.dart';
import '../../core/services/auth_service.dart';
import '../navigation/smart_navigation.dart';
import '../../main.dart';
import '../../l10n/app_localizations.dart';

/// 🚪 Logout Widget - Kompaktes Logout für Navigation Bar
class LogoutWidget extends StatefulWidget {
  const LogoutWidget({super.key});

  @override
  State<LogoutWidget> createState() => _LogoutWidgetState();
}

class _LogoutWidgetState extends State<LogoutWidget> with SingleTickerProviderStateMixin {
  late final AuthService _authService;
  late AnimationController _animationController;
  bool _isLoggingOut = false;
  
  @override
  void initState() {
    super.initState();
    _authService = ServiceLocator.get<AuthService>();
    
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
  }
  
  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }
  
  Future<void> _showLogoutDialog() async {
    if (_isLoggingOut) return;
    
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    
    final shouldLogout = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          backgroundColor: theme.colorScheme.surface,
          surfaceTintColor: theme.colorScheme.surfaceTint,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(
              color: theme.colorScheme.outline.withValues(alpha: 0.2),
              width: 1,
            ),
          ),
          title: Row(
            children: [
              Icon(
                Icons.logout,
                color: theme.colorScheme.error,
                size: 24,
              ),
              const SizedBox(width: 12),
              Text(
                l10n.authLogoutButton,
                style: theme.textTheme.headlineSmall?.copyWith(
                  color: theme.colorScheme.onSurface,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          content: Text(
            l10n.authLogoutConfirmMessage,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.8),
            ),
          ),
          actions: [
            // Cancel Button
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              style: TextButton.styleFrom(
                foregroundColor: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              ),
              child: Text(l10n.buttonCancel),
            ),
            // Logout Button
            ElevatedButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.colorScheme.error,
                foregroundColor: theme.colorScheme.onError,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.logout, size: 18),
                  const SizedBox(width: 8),
                  Text(l10n.authLogoutButton),
                ],
              ),
            ),
          ],
        );
      },
    );

    if (shouldLogout == true) {
      await _performLogout();
    }
  }

  Future<void> _performLogout() async {
    if (_isLoggingOut) return;
    
    setState(() {
      _isLoggingOut = true;
    });
    
    _animationController.forward();
    
    try {
      await _authService.logout();
      
      if (mounted) {
        // 🎯 Smart Navigation zum Login
        await context.smartGoNamed('login');
      }
    } catch (e) {
      // Error handling falls nötig
      if (mounted) {
        final l10n = AppLocalizations.of(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${l10n.worldLogoutError}: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoggingOut = false;
        });
        _animationController.reverse();
      }
    }
  }
  
  @override
  Widget build(BuildContext context) {
    // 🎯 SMART NAVIGATION THEME: Verwendet vorgeladenes Theme
    final theme = Theme.of(context);
    return _buildLogoutButton(context, theme);
  }

  /// 🚪 Logout Button Build
  Widget _buildLogoutButton(BuildContext context, ThemeData theme) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return GestureDetector(
          onTap: _isLoggingOut ? null : _showLogoutDialog,
          child: Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: _isLoggingOut
                  ? theme.colorScheme.error.withValues(alpha: 0.2)
                  : theme.colorScheme.surface.withValues(alpha: 0.9),
              shape: BoxShape.circle,
              border: Border.all(
                color: _isLoggingOut
                    ? theme.colorScheme.error.withValues(alpha: 0.5)
                    : theme.colorScheme.outline.withValues(alpha: 0.3),
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: theme.colorScheme.shadow.withValues(alpha: 0.1),
                  blurRadius: 4,
                  offset: const Offset(0, 1),
                ),
              ],
            ),
            child: _isLoggingOut
                ? SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        theme.colorScheme.error,
                      ),
                    ),
                  )
                : Transform.rotate(
                    angle: _animationController.value * 0.1,
                    child: Icon(
                      Icons.logout,
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                      size: 24,
                    ),
                  ),
          ),
        );
      },
    );
  }
}