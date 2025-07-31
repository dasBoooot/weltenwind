import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/services/auth_service.dart';
import '../../theme/tokens/colors.dart';
import '../../theme/tokens/spacing.dart';
import '../../theme/tokens/typography.dart';
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
  Color _getRoleColor(String roleName) {
    switch (roleName.toLowerCase()) {
      case 'admin':
        return AppColors.error; // 🔴 Admin = Rot
      case 'developer':
        return AppColors.glow; // 🔮 Developer = Magisches Lila
      case 'support':
        return AppColors.info; // 🔵 Support = Blau
      case 'mod':
        return AppColors.warning; // 🟠 Mod = Orange
      case 'world-admin':
        return AppColors.primary; // 🟣 World-Admin = Primary
      case 'user':
      default:
        return AppColors.success; // 🟢 User = Grün
    }
  }
  
  @override
  Widget build(BuildContext context) {
    final user = _authService.currentUser;
    if (user == null) return const SizedBox.shrink();
    
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Positioned(
      top: AppSpacing.md,
      left: AppSpacing.md,
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
            padding: const EdgeInsets.all(AppSpacing.sm),
            child: GestureDetector(
              onTap: _toggleExpanded,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 👤 Compact Header
                  _buildUserHeader(user, isDark),
                  
                  // 📋 Erweiterte Details
                  if (_isExpanded) ...[
                    const SizedBox(height: AppSpacing.sm),
                    Divider(
                      color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.3),
                      height: 1,
                      thickness: 1,
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    _buildExpandedDetails(user, isDark),
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
  Widget _buildUserHeader(dynamic user, bool isDark) {
    return Row(
      children: [
        // 🎭 Avatar Circle
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.2),
            shape: BoxShape.circle,
            border: Border.all(
              color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.5),
              width: 2,
            ),
          ),
          child: Center(
            child: Text(
              user.username.substring(0, 1).toUpperCase(),
              style: AppTypography.h4(isDark: isDark).copyWith(
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
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
                      style: AppTypography.labelLarge(isDark: isDark),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (user.isLocked ?? false) ...[
                    const SizedBox(width: AppSpacing.xs),
                    const Icon(
                      Icons.lock,
                      color: AppColors.error,
                      size: 16,
                    ),
                  ],
                ],
              ),
              if (!_isExpanded)
                Text(
                  AppLocalizations.of(context).userInfoClickForDetails,
                  style: AppTypography.bodySmall(isDark: isDark).copyWith(
                    color: isDark ? AppColors.textSecondary : AppColors.textSecondaryLight,
                  ),
                ),
            ],
          ),
        ),
        // 🔽 Expand/Collapse Icon
        Icon(
          _isExpanded ? Icons.expand_less : Icons.expand_more,
          color: isDark ? AppColors.textSecondary : AppColors.textSecondaryLight,
          size: 20,
        ),
      ],
    );
  }
  
  /// 📋 Erweiterte User-Details
  Widget _buildExpandedDetails(dynamic user, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ✉️ Email
        Row(
          children: [
            Icon(
              Icons.email_outlined, 
              size: 16, 
              color: isDark ? AppColors.textSecondary : AppColors.textSecondaryLight,
            ),
            const SizedBox(width: AppSpacing.xs),
            Expanded(
              child: Text(
                user.email,
                style: AppTypography.bodyMedium(isDark: isDark),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        
        const SizedBox(height: AppSpacing.sm),
        
        // 🛡️ Rollen
        if (user.roles != null && user.roles!.isNotEmpty) ...[
          Row(
            children: [
              Icon(
                Icons.security, 
                size: 16, 
                color: isDark ? AppColors.textSecondary : AppColors.textSecondaryLight,
              ),
              const SizedBox(width: AppSpacing.xs),
              Text(
                AppLocalizations.of(context).userInfoRoles,
                style: AppTypography.bodyMedium(isDark: isDark).copyWith(
                  color: isDark ? AppColors.textSecondary : AppColors.textSecondaryLight,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          _buildRoleBadges(user.roles!),
          const SizedBox(height: AppSpacing.sm),
        ],
        
        // 🌟 Divider
        Divider(
          color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.3),
          height: 1,
          thickness: 1,
        ),
        const SizedBox(height: AppSpacing.sm),
        
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
  Widget _buildRoleBadges(List<dynamic> userRoles) {
    return Wrap(
      spacing: AppSpacing.xs,
      runSpacing: AppSpacing.xs,
      children: userRoles.map((userRole) {
        final roleName = userRole.role.name;
        final scopeInfo = userRole.scopeType == 'global' 
            ? '' 
            : ' (${userRole.scopeType})';
        final roleColor = _getRoleColor(roleName);
        
        return Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.xs,
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
                style: AppTypography.bodySmall(isDark: true).copyWith(
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