import 'package:flutter/material.dart';
import '../../core/services/auth_service.dart';
import '../../main.dart';
import '../../l10n/app_localizations.dart';
import '../dialogs/user_info_fullscreen_dialog.dart';

/// 👤 User Info Widget mit Dialog
/// 
/// Zeigt nur ein User-Icon, Details im Dialog
class UserInfoWidget extends StatefulWidget {
  const UserInfoWidget({super.key});

  @override
  State<UserInfoWidget> createState() => _UserInfoWidgetState();
}

class _UserInfoWidgetState extends State<UserInfoWidget> {
  late final AuthService _authService;
  
  @override
  void initState() {
    super.initState();
    _authService = ServiceLocator.get<AuthService>();
  }
  
  @override
  Widget build(BuildContext context) {
    final user = _authService.currentUser;
    if (user == null) return const SizedBox.shrink();
    
    // 🎯 SMART NAVIGATION THEME: Verwendet vorgeladenes Theme
    return _buildUserIcon(context, Theme.of(context), user);
  }

  /// 👤 User Icon Button (48x48px)
  Widget _buildUserIcon(BuildContext context, ThemeData theme, dynamic user) {
    return GestureDetector(
              onTap: () => _showUserDialog(context, user),
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: theme.colorScheme.primary.withValues(alpha: 0.2),
          shape: BoxShape.circle,
          border: Border.all(
            color: theme.colorScheme.primary.withValues(alpha: 0.5),
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
        child: Center(
          child: Text(
            user.username.substring(0, 1).toUpperCase(),
            style: theme.textTheme.labelLarge?.copyWith(
              color: theme.colorScheme.primary,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }

  /// 📋 User Dialog anzeigen - Fullscreen Version
  Future<void> _showUserDialog(BuildContext context, dynamic user) async {
    showUserInfoDialog(context, user);
  }

  /// 📋 OLD User Dialog (replaced by fullscreen version)
  Future<void> _showUserDialogOld(BuildContext context, dynamic user) async {
    await showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext dialogContext) {
        // 🎯 GENAUSO WIE PAGES: Theme.of(context) verwenden!
        final theme = Theme.of(dialogContext);
        final l10n = AppLocalizations.of(dialogContext);
        
        // 🔍 DEBUG: Problem gefunden - user.role existiert nicht, nur user.roles!
        return AlertDialog(
          backgroundColor: theme.colorScheme.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(
              color: theme.colorScheme.outline.withValues(alpha: 0.2),
              width: 1,
            ),
          ),
          title: Row(
            children: [
              // User Avatar
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: theme.colorScheme.primary.withValues(alpha: 0.5),
                    width: 2,
                  ),
                ),
                child: Center(
                  child: Text(
                    user.username.substring(0, 1).toUpperCase(),
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              // Username
              Flexible(
                child: Text(
                  user.username,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    color: theme.colorScheme.onSurface,
                    fontWeight: FontWeight.w600,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          content: Material(
            color: theme.colorScheme.surface,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
              // 🎭 ALLE Rollen anzeigen (für Testing/Vergleich)
              if (user.roles != null && user.roles.isNotEmpty) ...[
                Text(
                  'Rollen (${user.roles.length}):',
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: theme.colorScheme.onSurface,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                // Rollen als scrollbare Liste
                Container(
                  constraints: const BoxConstraints(maxHeight: 200),
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: user.roles.map<Widget>((userRole) {
                        final roleName = userRole.role.name;
                        final roleColor = _getRoleColor(roleName.toLowerCase(), theme);
                        
                        return Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: roleColor.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: roleColor.withValues(alpha: 0.3),
                              width: 1,
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Rollen-Name
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: roleColor.withValues(alpha: 0.2),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      roleName,
                                      style: theme.textTheme.labelMedium?.copyWith(
                                        color: roleColor,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                  if (userRole.role.description != null) ...[
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        userRole.role.description!,
                                        style: theme.textTheme.bodySmall?.copyWith(
                                          color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                              // Scope Information
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  Icon(
                                    userRole.scopeType == 'global' ? Icons.public : Icons.location_on,
                                    size: 14,
                                    color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    '${userRole.scopeType}${userRole.scopeObjectId != 'null' ? ' (${userRole.scopeObjectId})' : ''}',
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                                    ),
                                  ),
                                ],
                              ),
                              // Condition (falls vorhanden)
                              if (userRole.condition != null) ...[
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    Icon(
                                      Icons.rule,
                                      size: 14,
                                      color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                                    ),
                                    const SizedBox(width: 4),
                                    Expanded(
                                      child: Text(
                                        'Bedingung: ${userRole.condition}',
                                        style: theme.textTheme.bodySmall?.copyWith(
                                          color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),
              ] else ...[
                // Fallback wenn keine Rollen vorhanden
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.person,
                        color: theme.colorScheme.onSurfaceVariant,
                        size: 16,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Standardbenutzer (keine speziellen Rollen)',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              
              if (user.email != null) ...[
                const SizedBox(height: 16),
                Row(
                  children: [
                    Icon(
                      Icons.email,
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                      size: 16,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        user.email,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurface.withValues(alpha: 0.8),
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
              
              if (user.isLocked ?? false) ...[
                const SizedBox(height: 12),
                Row(
                  children: [
                    Icon(
                      Icons.warning,
                      color: theme.colorScheme.error,
                      size: 16,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      l10n.authAccountLocked,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.error,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
              ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              style: TextButton.styleFrom(
                foregroundColor: theme.colorScheme.primary,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              ),
              child: Text(l10n.buttonCancel),
            ),
          ],
        );

      },
    );
  }

  /// 🎯 Primäre Rolle aus user.roles Liste holen (da user.role nicht existiert!)
  String _getPrimaryRole(dynamic user) {
    if (user?.roles == null || user.roles.isEmpty) return 'user';
    
    // Priorität: admin > moderator > world_admin > user
    final roleNames = user.roles.map((r) => r.role.name.toLowerCase()).toList();
    
    if (roleNames.contains('admin') || roleNames.contains('super_admin')) return 'admin';
    if (roleNames.contains('moderator')) return 'moderator';  
    if (roleNames.contains('world_admin')) return 'world_admin';
    
    return roleNames.isNotEmpty ? roleNames.first : 'user';
  }

  /// 🌈 Rolle zu Farbe Mapping (Theme-sicher mit Null-Checks)
  Color _getRoleColor(String role, ThemeData theme) {
    try {
      // Null-Safety checks
      switch (role.toLowerCase()) {
        case 'admin':
        case 'super_admin':
          return theme.colorScheme.error ?? theme.colorScheme.primary;
        case 'moderator':
          return theme.colorScheme.secondary ?? theme.colorScheme.primary;
        case 'world_admin':
          return theme.colorScheme.primary;
        case 'user':
        default:
          return theme.colorScheme.primary;
      }
    } catch (e) {
      // Absoluter Fallback bei Theme-Problemen - theme-aware
      return theme.colorScheme.primary;
    }
  }
}