import 'package:flutter/material.dart';
// REMOVED: import '../../core/providers/theme_context_provider.dart'; // DEPRECATED - using Theme.of(context)

/// 📨 Invite Status Types
enum InviteStatus {
  pending,
  accepted,
  declined,
  expired,
}

/// 📨 Invite Type
enum InviteType {
  world,
  guild,
  party,
  friend,
}

/// 📨 Invite Data Model
class InviteData {
  final String id;
  final InviteType type;
  final InviteStatus status;
  final String senderName;
  final String? senderAvatarUrl;
  final String targetName; // World/Guild/Party name
  final String? targetThumbnailUrl;
  final DateTime sentAt;
  final DateTime? expiresAt;
  final String? message;

  const InviteData({
    required this.id,
    required this.type,
    required this.status,
    required this.senderName,
    this.senderAvatarUrl,
    required this.targetName,
    this.targetThumbnailUrl,
    required this.sentAt,
    this.expiresAt,
    this.message,
  });

  /// Check if invite is expired
  bool get isExpired {
    if (expiresAt == null) return false;
    return DateTime.now().isAfter(expiresAt!);
  }

  /// Get time remaining until expiry
  Duration? get timeRemaining {
    if (expiresAt == null) return null;
    final now = DateTime.now();
    if (now.isAfter(expiresAt!)) return Duration.zero;
    return expiresAt!.difference(now);
  }
}

/// 📨 Invite Status Banner based on Schema Configuration
/// 
/// Display invitation banners with avatars, expiry times, and schema-based styling
class InviteStatusBanner extends StatefulWidget {
  final InviteData invite;
  final VoidCallback? onAccept;
  final VoidCallback? onDecline;
  final VoidCallback? onDismiss;
  final VoidCallback? onTap;
  final bool showAvatar;
  final bool showWorldThumbnail;
  final bool showExpiry;
  final bool glowEffect;
  final bool animateIn;
  final double? avatarSize;
  final double? thumbnailSize;

  const InviteStatusBanner({
    super.key,
    required this.invite,
    this.onAccept,
    this.onDecline,
    this.onDismiss,
    this.onTap,
    this.showAvatar = true,
    this.showWorldThumbnail = true,
    this.showExpiry = true,
    this.glowEffect = true,
    this.animateIn = true,
    this.avatarSize,
    this.thumbnailSize,
  });

  /// Compact invite banner
  const InviteStatusBanner.compact({
    super.key,
    required this.invite,
    this.onAccept,
    this.onDecline,
    this.onDismiss,
    this.onTap,
    this.showAvatar = true,
    this.showWorldThumbnail = false,
    this.showExpiry = false,
    this.glowEffect = false,
    this.animateIn = true,
    this.avatarSize = 24,
    this.thumbnailSize = 40,
  });

  /// Detailed invite banner with all information
  const InviteStatusBanner.detailed({
    super.key,
    required this.invite,
    this.onAccept,
    this.onDecline,
    this.onDismiss,
    this.onTap,
    this.showAvatar = true,
    this.showWorldThumbnail = true,
    this.showExpiry = true,
    this.glowEffect = true,
    this.animateIn = true,
    this.avatarSize = 40,
    this.thumbnailSize = 60,
  });

  @override
  State<InviteStatusBanner> createState() => _InviteStatusBannerState();
}

class _InviteStatusBannerState extends State<InviteStatusBanner> with TickerProviderStateMixin {
  late AnimationController _slideController;
  late AnimationController _glowController;
  
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();
    
    // Slide in animation
    _slideController = AnimationController(
      duration: _getAnimationDuration(),
      vsync: this,
    );
    
    _slideAnimation = Tween<Offset>(
      begin: const Offset(1.0, 0.0), // Slide from right
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    ));
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOut,
    ));

    // Glow animation
    if (widget.glowEffect && widget.invite.status == InviteStatus.pending) {
      _glowController = AnimationController(
        duration: const Duration(milliseconds: 2000),
        vsync: this,
      );
      
      _glowAnimation = Tween<double>(
        begin: 0.3,
        end: 1.0,
      ).animate(CurvedAnimation(
        parent: _glowController,
        curve: Curves.easeInOut,
      ));
      
      _glowController.repeat(reverse: true);
    }

    // Start slide animation
    if (widget.animateIn) {
      _slideController.forward();
    } else {
      _slideController.value = 1.0;
    }
  }

  @override
  void dispose() {
    _slideController.dispose();
    if (widget.glowEffect && widget.invite.status == InviteStatus.pending) {
      _glowController.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // 🎯 NEUE KONTEXTSENSITIVE THEME-BEREITSTELLUNG
    return _buildInviteBanner(context, Theme.of(context), null);
  }

  Widget _buildInviteBanner(BuildContext context, ThemeData theme, Map<String, dynamic>? extensions) {
    Widget banner = AnimatedBuilder(
      animation: _slideController,
      builder: (context, child) {
        return SlideTransition(
          position: _slideAnimation,
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: _buildBanner(theme, extensions),
          ),
        );
      },
    );

    // Add glow effect for pending invites
    if (widget.glowEffect && 
        widget.invite.status == InviteStatus.pending) {
      banner = AnimatedBuilder(
        animation: _glowController,
        builder: (context, child) {
          return Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(_getBorderRadius()),
              boxShadow: [
                BoxShadow(
                  color: _getGlowColor(theme, extensions).withValues(alpha: 0.3 * _glowAnimation.value),
                  blurRadius: 8 * _glowAnimation.value,
                  spreadRadius: 2 * _glowAnimation.value,
                ),
              ],
            ),
            child: banner,
          );
        },
      );
    }

    return GestureDetector(
      onTap: widget.onTap,
      child: banner,
    );
  }

  Widget _buildBanner(ThemeData theme, Map<String, dynamic>? extensions) {
    return Container(
      padding: EdgeInsets.all(_getPadding()),
      decoration: _getBannerDecoration(theme, extensions),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with avatars and dismiss button
          _buildHeader(theme),
          
          const SizedBox(height: 12),
          
          // Content
          _buildContent(theme),
          
          // Expiry info
          if (widget.showExpiry && widget.invite.expiresAt != null) ...[
            const SizedBox(height: 8),
            _buildExpiryInfo(theme),
          ],
          
          // Actions for pending invites
          if (widget.invite.status == InviteStatus.pending) ...[
            const SizedBox(height: 16),
            _buildActions(theme, extensions),
          ],
        ],
      ),
    );
  }

  Widget _buildHeader(ThemeData theme) {
    return Row(
      children: [
        // Sender avatar
        if (widget.showAvatar)
          _buildAvatar(
            widget.invite.senderAvatarUrl,
            widget.invite.senderName,
            _getAvatarSize(),
          ),
        
        if (widget.showAvatar) const SizedBox(width: 12),
        
        // Target thumbnail
        if (widget.showWorldThumbnail && widget.invite.type == InviteType.world)
          _buildThumbnail(),
        
        if (widget.showWorldThumbnail && widget.invite.type == InviteType.world) 
          const SizedBox(width: 12),
        
        // Status indicator
        _buildStatusIndicator(theme),
        
        const Spacer(),
        
        // Dismiss button
        if (widget.onDismiss != null)
          IconButton(
            onPressed: widget.onDismiss,
            icon: const Icon(Icons.close),
            iconSize: 20,
            visualDensity: VisualDensity.compact,
          ),
      ],
    );
  }

  Widget _buildAvatar(String? avatarUrl, String name, double size) {
    return CircleAvatar(
      radius: size / 2,
      backgroundImage: avatarUrl != null ? NetworkImage(avatarUrl) : null,
      child: avatarUrl == null
          ? Text(
              name.isNotEmpty ? name[0].toUpperCase() : '?',
              style: TextStyle(
                fontSize: size * 0.4,
                fontWeight: FontWeight.bold,
              ),
            )
          : null,
    );
  }

  Widget _buildThumbnail() {
    return Container(
      width: _getThumbnailSize(),
      height: _getThumbnailSize(),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: Theme.of(context).colorScheme.surfaceContainer,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: widget.invite.targetThumbnailUrl != null
            ? Image.network(
                widget.invite.targetThumbnailUrl!,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Icon(
                  _getTypeIcon(),
                  size: _getThumbnailSize() * 0.5,
                ),
              )
            : Icon(
                _getTypeIcon(),
                size: _getThumbnailSize() * 0.5,
              ),
      ),
    );
  }

  Widget _buildStatusIndicator(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: _getStatusColor().withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _getStatusColor(),
          width: 1,
        ),
      ),
      child: Text(
        _getStatusText(),
        style: theme.textTheme.bodySmall?.copyWith(
          color: _getStatusColor(),
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildContent(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Main invite text
        RichText(
          text: TextSpan(
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface,
            ),
            children: [
              TextSpan(
                text: widget.invite.senderName,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              TextSpan(text: ' ${_getInviteText()} '),
              TextSpan(
                text: widget.invite.targetName,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
        
        // Custom message
        if (widget.invite.message != null && widget.invite.message!.isNotEmpty) ...[
          const SizedBox(height: 4),
          Text(
            '"${widget.invite.message}"',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildExpiryInfo(ThemeData theme) {
    final timeRemaining = widget.invite.timeRemaining;
    if (timeRemaining == null) return const SizedBox.shrink();
    
    final isExpiringSoon = timeRemaining.inHours < 1;
    
    return Row(
      children: [
        Icon(
          Icons.schedule,
          size: 16,
          color: isExpiringSoon ? theme.colorScheme.error : theme.colorScheme.onSurfaceVariant,
        ),
        const SizedBox(width: 4),
        Text(
          'Expires in ${_formatDuration(timeRemaining)}',
          style: theme.textTheme.bodySmall?.copyWith(
            color: isExpiringSoon ? theme.colorScheme.error : theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  Widget _buildActions(ThemeData theme, Map<String, dynamic>? extensions) {
    return Row(
      children: [
        // Accept button
        if (widget.onAccept != null)
          Expanded(
            child: ElevatedButton.icon(
              onPressed: widget.onAccept,
              icon: const Icon(Icons.check, size: 18),
              label: const Text('Accept'),
              style: ElevatedButton.styleFrom(
                backgroundColor: _getAcceptButtonColor(theme, extensions),
                foregroundColor: theme.colorScheme.onPrimary,
              ),
            ),
          ),
        
        if (widget.onAccept != null && widget.onDecline != null)
          const SizedBox(width: 12),
        
        // Decline button
        if (widget.onDecline != null)
          Expanded(
            child: OutlinedButton.icon(
              onPressed: widget.onDecline,
              icon: const Icon(Icons.close, size: 18),
              label: const Text('Decline'),
              style: OutlinedButton.styleFrom(
                foregroundColor: theme.colorScheme.onSurfaceVariant,
                side: BorderSide(color: theme.colorScheme.outline),
              ),
            ),
          ),
      ],
    );
  }

  /// Get banner decoration
  BoxDecoration _getBannerDecoration(ThemeData theme, Map<String, dynamic>? extensions) {
    return BoxDecoration(
      color: theme.colorScheme.surface,
      borderRadius: BorderRadius.circular(_getBorderRadius()),
      border: Border.all(
        color: _getStatusColor().withValues(alpha: 0.3),
        width: 1,
      ),
      boxShadow: [
        BoxShadow(
          color: theme.colorScheme.shadow.withValues(alpha: 0.1),
          blurRadius: 8,
          offset: const Offset(0, 2),
        ),
      ],
    );
  }

  /// Get status color based on invite status
  Color _getStatusColor() {
    switch (widget.invite.status) {
      case InviteStatus.pending:
        return const Color(0xFF3B82F6); // Blue
      case InviteStatus.accepted:
        return const Color(0xFF22C55E); // Green
      case InviteStatus.declined:
        return const Color(0xFFEF4444); // Red
      case InviteStatus.expired:
        return const Color(0xFF6B7280); // Gray
    }
  }

  /// Get status text
  String _getStatusText() {
    switch (widget.invite.status) {
      case InviteStatus.pending:
        return 'Pending';
      case InviteStatus.accepted:
        return 'Accepted';
      case InviteStatus.declined:
        return 'Declined';
      case InviteStatus.expired:
        return 'Expired';
    }
  }

  /// Get invite text based on type
  String _getInviteText() {
    switch (widget.invite.type) {
      case InviteType.world:
        return 'invited you to join';
      case InviteType.guild:
        return 'invited you to join guild';
      case InviteType.party:
        return 'invited you to join party';
      case InviteType.friend:
        return 'sent you a friend request';
    }
  }

  /// Get type icon
  IconData _getTypeIcon() {
    switch (widget.invite.type) {
      case InviteType.world:
        return Icons.public;
      case InviteType.guild:
        return Icons.groups;
      case InviteType.party:
        return Icons.people;
      case InviteType.friend:
        return Icons.person_add;
    }
  }

  /// Get glow color for pending invites
  Color _getGlowColor(ThemeData theme, Map<String, dynamic>? extensions) {
    // Try to get magic gradient color from extensions
    if (extensions != null && extensions.containsKey('magicGradient')) {
      final colors = extensions['magicGradient'] as List<dynamic>?;
      if (colors != null && colors.isNotEmpty) {
        final color = _parseColor(colors.first.toString());
        if (color != null) return color;
      }
    }
    
    return theme.colorScheme.primary;
  }

  /// Get accept button color
  Color _getAcceptButtonColor(ThemeData theme, Map<String, dynamic>? extensions) {
    return _getGlowColor(theme, extensions);
  }

  /// Get border radius from schema
  double _getBorderRadius() {
    return 12.0; // Schema default
  }

  /// Get padding from schema
  double _getPadding() {
    return 16.0; // Schema default
  }

  /// Get avatar size from schema
  double _getAvatarSize() {
    return widget.avatarSize ?? 32.0; // Schema default
  }

  /// Get thumbnail size from schema
  double _getThumbnailSize() {
    return widget.thumbnailSize ?? 60.0; // Schema default
  }

  /// Get animation duration from schema
  Duration _getAnimationDuration() {
    return const Duration(milliseconds: 400);
  }

  /// Format duration for expiry display
  String _formatDuration(Duration duration) {
    if (duration.inDays > 0) {
      return '${duration.inDays}d ${duration.inHours % 24}h';
    } else if (duration.inHours > 0) {
      return '${duration.inHours}h ${duration.inMinutes % 60}m';
    } else {
      return '${duration.inMinutes}m';
    }
  }

  /// Helper: Parse color from hex string
  Color? _parseColor(String colorString) {
    if (colorString.startsWith('#')) {
      final hex = colorString.replaceAll('#', '');
      if (hex.length == 6) {
        return Color(int.parse('FF$hex', radix: 16));
      } else if (hex.length == 8) {
        return Color(int.parse(hex, radix: 16));
      }
    }
    return null;
  }
}

/// 📨 Invite Banner List
class InviteBannerList extends StatelessWidget {
  final List<InviteData> invites;
  final Function(InviteData)? onAccept;
  final Function(InviteData)? onDecline;
  final Function(InviteData)? onDismiss;
  final Function(InviteData)? onTap;
  final EdgeInsetsGeometry? padding;

  const InviteBannerList({
    super.key,
    required this.invites,
    this.onAccept,
    this.onDecline,
    this.onDismiss,
    this.onTap,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    if (invites.isEmpty) return const SizedBox.shrink();
    
    return Padding(
      padding: padding ?? const EdgeInsets.all(16),
      child: Column(
        children: invites.map((invite) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: InviteStatusBanner(
              invite: invite,
              onAccept: onAccept != null ? () => onAccept!(invite) : null,
              onDecline: onDecline != null ? () => onDecline!(invite) : null,
              onDismiss: onDismiss != null ? () => onDismiss!(invite) : null,
              onTap: onTap != null ? () => onTap!(invite) : null,
            ),
          );
        }).toList(),
      ),
    );
  }
}