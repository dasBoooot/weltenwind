import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/services/auth_service.dart';
import '../../core/providers/theme_context_provider.dart';
import '../components/index.dart';
import '../utils/dynamic_components.dart';
import '../../main.dart';
import '../../l10n/app_localizations.dart';

/// 👤 Fantasy User Info Widget
/// 
/// Magisches User-Info Widget mit DynamicComponents und Theme-Integration
class UserInfoWidget extends StatefulWidget {
  const UserInfoWidget({super.key});

  @override
  State<UserInfoWidget> createState() => _UserInfoWidgetState();
}

class _UserInfoWidgetState extends State<UserInfoWidget> with SingleTickerProviderStateMixin {
  late final AuthService _authService;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  bool _isExpanded = false;
  
  @override
  void initState() {
    super.initState();
    _authService = ServiceLocator.get<AuthService>();
    
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    
    _animationController.forward();
    
    // Fetch current user data to ensure we have roles
    _fetchUserData();
  }
  
  Future<void> _fetchUserData() async {
    final user = await _authService.fetchCurrentUser();
    if (user != null && mounted) {
      setState(() {});
    }
  }
  
  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }
  
  void _toggleExpanded() {
    setState(() {
      _isExpanded = !_isExpanded;
    });
  }
  
  /// 🛡️ Bestimmt die Rolle-Farbe basierend auf Theme-System
  Color _getRoleColor(String roleName, ThemeData theme) {
    switch (roleName.toLowerCase()) {
      case 'admin':
        return theme.colorScheme.error; // 🔴 Admin = Rot
      case 'developer':
        return const Color(0xFF9D4EDD); // 🔮 Developer = Magisches Lila
      case 'support':
        return theme.colorScheme.tertiary; // 🔵 Support = Blau
      case 'mod':
        return const Color(0xFFF77F00); // 🟠 Mod = Orange
      case 'world-admin':
        return theme.colorScheme.primary; // 🟣 World-Admin = Primary
      case 'user':
      default:
        return const Color(0xFF52B788); // 🟢 User = Grün
    }
  }
  
  @override
  Widget build(BuildContext context) {
    final user = _authService.currentUser;
    if (user == null) return const SizedBox.shrink();
    
    // 🎯 MIXED-CONTEXT THEME: Universal Theme-Vererbung
    return ThemeContextConsumer(
      componentName: 'UserInfoWidget',
      enableMixedContext: true,
      contextOverrides: const {
        'uiContext': 'user-info',
        'context': 'inherit', // Erbt Theme vom Parent (Pre-Game oder World-themed)
        'inherit': 'parent-theme',
        'universalComponent': 'true', // Universelles UI-Element
      },
      fallbackTheme: 'pre_game_bundle',
      builder: (context, theme, extensions) {
        return _buildUserInfo(context, theme, extensions, user);
      },
    );
  }

  /// 🎨 User Info Build mit Theme
  Widget _buildUserInfo(BuildContext context, ThemeData theme, Map<String, dynamic>? extensions, user) {
    final isDark = theme.brightness == Brightness.dark;
    
    return Positioned(
      top: 24.0, // md
      left: 24.0, // md
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          constraints: BoxConstraints(
            minWidth: _isExpanded ? 280 : 200,
            maxWidth: _isExpanded ? 320 : 220,
          ),
          child: DynamicComponents.frame(
            title: user.username,
            padding: const EdgeInsets.all(16.0), // sm
            child: GestureDetector(
              onTap: _toggleExpanded,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 👤 Compact Header
                  _buildUserHeader(user, isDark, theme),
                  
                  // 📋 Erweiterte Details
                  if (_isExpanded) ...[
                    const SizedBox(height: 16.0), // sm
                    Divider(
                      color: theme.colorScheme.primary.withValues(alpha: 0.3),
                      height: 1,
                      thickness: 1,
                    ),
                    const SizedBox(height: 16.0), // sm
                    _buildExpandedDetails(user, theme),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
  
  /// 👤 User Header (Avatar + Name + Status)
  Widget _buildUserHeader(dynamic user, bool isDark, ThemeData theme) {
    return Row(
      children: [
        // 🎭 Avatar Circle
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
                style: theme.textTheme.headlineSmall?.copyWith(
                color: theme.colorScheme.primary,
              ),
            ),
          ),
        ),
                            const SizedBox(width: 16.0), // sm
        // 📝 Name und Status
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Flexible(
                    child: Text(
                      user.username,
                      style: theme.textTheme.labelLarge?.copyWith(color: theme.colorScheme.onSurface),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (user.isLocked ?? false) ...[
                    const SizedBox(width: 8.0), // xs
                    Icon(
                      Icons.lock,
                      color: theme.colorScheme.error,
                      size: 16,
                    ),
                  ],
                ],
              ),
              if (!_isExpanded)
                Text(
                  AppLocalizations.of(context).userInfoClickForDetails,
                    style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                  ),
                ),
            ],
          ),
        ),
        // 🔽 Expand/Collapse Icon
        Icon(
          _isExpanded ? Icons.expand_less : Icons.expand_more,
          color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
          size: 20,
        ),
      ],
    );
  }
  
  /// 📋 Erweiterte User-Details
  Widget _buildExpandedDetails(dynamic user, ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ✉️ Email
        Row(
          children: [
            Icon(
              Icons.email_outlined, 
              size: 16, 
              color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
            ),
            const SizedBox(width: 8.0), // xs
            Expanded(
              child: Text(
                user.email,
                style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurface),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        
        const SizedBox(height: 16.0), // sm
        
        // 🛡️ Rollen
        if (user.roles != null && user.roles!.isNotEmpty) ...[
          Row(
            children: [
              Icon(
                Icons.security, 
                size: 16, 
                color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
              ),
              const SizedBox(width: 8.0), // xs
              Text(
                AppLocalizations.of(context).userInfoRoles,
                  style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8.0), // xs
           _buildRoleBadges(user.roles!, theme),
          const SizedBox(height: 16.0), // sm
        ],
        
        // 🌟 Divider
        Divider(
          color: theme.colorScheme.primary.withValues(alpha: 0.3),
          height: 1,
          thickness: 1,
        ),
        const SizedBox(height: 16.0), // sm
        
        // 🚪 Logout Button mit DynamicComponents
        SizedBox(
          width: double.infinity,
          child: DynamicComponents.secondaryButton(
            text: AppLocalizations.of(context).authLogoutButton,
            onPressed: () async {
              await _authService.logout();
              if (mounted) {
                context.goNamed('login');
              }
            },
            icon: Icons.logout,
            size: AppButtonSize.medium,
          ),
        ),
      ],
    );
  }
  
  /// 🛡️ Rolle-Badges mit Fantasy-Theme-Colors
  Widget _buildRoleBadges(List<dynamic> userRoles, ThemeData theme) {
    return Wrap(
      spacing: 8.0, // xs
      runSpacing: 8.0, // xs
      children: userRoles.map((userRole) {
        final roleName = userRole.role.name;
        final scopeInfo = userRole.scopeType == 'global' 
            ? '' 
            : ' (${userRole.scopeType})';
        final roleColor = _getRoleColor(roleName, theme);
        
        return Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 8.0, // xs
            vertical: 4,
          ),
          decoration: BoxDecoration(
            color: roleColor.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: roleColor.withValues(alpha: 0.5),
              width: 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.badge,
                size: 12,
                color: roleColor,
              ),
              const SizedBox(width: 4),
              Text(
                '$roleName$scopeInfo',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: roleColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
} 