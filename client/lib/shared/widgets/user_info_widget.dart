import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/services/auth_service.dart';
import '../../theme/app_theme.dart';
import '../../main.dart';

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
  
  Color _getRoleColor(String roleName) {
    switch (roleName.toLowerCase()) {
      case 'admin':
        return Colors.red[400] ?? Colors.red;
      case 'developer':
        return Colors.purple[400] ?? Colors.purple;
      case 'support':
        return Colors.blue[400] ?? Colors.blue;
      case 'mod':
        return Colors.orange[400] ?? Colors.orange;
      case 'world-admin':
        return Colors.indigo[400] ?? Colors.indigo;
      case 'user':
      default:
        return Colors.green[400] ?? Colors.green;
    }
  }
  
  @override
  Widget build(BuildContext context) {
    final user = _authService.currentUser;
    if (user == null) return const SizedBox.shrink();
    
    return Positioned(
      top: 16,
      left: 16,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: GestureDetector(
          onTap: _toggleExpanded,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            width: _isExpanded ? 320 : 180,
            decoration: BoxDecoration(
              color: const Color(0xFF1A1A1A).withOpacity(0.95),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: AppTheme.primaryColor.withOpacity(0.3),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: _toggleExpanded,
                borderRadius: BorderRadius.circular(16),
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header mit Avatar und Name
                      Row(
                        children: [
                          // Avatar
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: AppTheme.primaryColor.withOpacity(0.2),
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: AppTheme.primaryColor.withOpacity(0.5),
                                width: 2,
                              ),
                            ),
                            child: Center(
                              child: Text(
                                user.username.substring(0, 1).toUpperCase(),
                                style: const TextStyle(
                                  color: AppTheme.primaryColor,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          // Name und Status
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Flexible(
                                      child: Text(
                                        user.username,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    if (user.isLocked ?? false) ...[
                                      const SizedBox(width: 8),
                                      Icon(
                                        Icons.lock,
                                        color: Colors.red[400],
                                        size: 16,
                                      ),
                                    ],
                                  ],
                                ),
                                if (!_isExpanded)
                                  Text(
                                    'Klicken für Details',
                                    style: TextStyle(
                                      color: Colors.grey[400],
                                      fontSize: 12,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          // Expand/Collapse Icon
                          Icon(
                            _isExpanded ? Icons.expand_less : Icons.expand_more,
                            color: Colors.grey[400],
                            size: 20,
                          ),
                        ],
                      ),
                      
                      // Erweiterte Details
                      if (_isExpanded) ...[
                        const SizedBox(height: 12),
                        const Divider(color: Colors.grey, height: 1),
                        const SizedBox(height: 12),
                        
                        // Email
                        Row(
                          children: [
                            Icon(Icons.email_outlined, size: 16, color: Colors.grey[400]),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                user.email,
                                style: TextStyle(
                                  color: Colors.grey[300],
                                  fontSize: 14,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        
                        const SizedBox(height: 8),
                        
                                            // Rollen
                    if (user.roles != null && user.roles!.isNotEmpty) ...[
                      Row(
                        children: [
                          Icon(Icons.security, size: 16, color: Colors.grey[400]),
                          const SizedBox(width: 8),
                          Text(
                            'Rollen:',
                            style: TextStyle(
                              color: Colors.grey[400],
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children: (user.roles ?? []).map((userRole) {
                              final roleName = userRole.role.name;
                              final scopeInfo = userRole.scopeType == 'global' 
                                  ? '' 
                                  : ' (${userRole.scopeType})';
                              
                              return Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: _getRoleColor(roleName).withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: _getRoleColor(roleName).withOpacity(0.5),
                                    width: 1,
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.badge,
                                      size: 12,
                                      color: _getRoleColor(roleName),
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      '$roleName$scopeInfo',
                                      style: TextStyle(
                                        color: _getRoleColor(roleName),
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }).toList(),
                          ),
                        ],
                        
                        const SizedBox(height: 12),
                        const Divider(color: Colors.grey, height: 1),
                        const SizedBox(height: 8),
                        
                        // Logout Button
                        SizedBox(
                          width: double.infinity,
                          child: TextButton.icon(
                            onPressed: () async {
                              await _authService.logout();
                              if (context.mounted) {
                                context.goNamed('login');
                              }
                            },
                            icon: const Icon(Icons.logout, size: 16),
                            label: const Text('Abmelden'),
                            style: TextButton.styleFrom(
                              foregroundColor: Colors.red[400],
                              padding: const EdgeInsets.symmetric(vertical: 8),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
} 