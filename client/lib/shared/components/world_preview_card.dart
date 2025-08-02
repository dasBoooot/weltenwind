import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/providers/theme_context_provider.dart';

/// 🌍 World Status Types
enum WorldStatus {
  online,
  offline,
  maintenance,
  full,
}

/// 🌍 World Data Model
class WorldData {
  final String id;
  final String name;
  final String? description;
  final String? thumbnailUrl;
  final WorldStatus status;
  final int currentPlayers;
  final int maxPlayers;
  final String? creator;
  final List<String> tags;
  final bool isFavorite;
  final DateTime? lastPlayed;

  const WorldData({
    required this.id,
    required this.name,
    this.description,
    this.thumbnailUrl,
    required this.status,
    required this.currentPlayers,
    required this.maxPlayers,
    this.creator,
    this.tags = const [],
    this.isFavorite = false,
    this.lastPlayed,
  });
}

/// 🌍 World Preview Card based on World Preview Schema
/// 
/// Fantasy world cards with thumbnails, status indicators, and schema-based configuration
class WorldPreviewCard extends StatefulWidget {
  final WorldData world;
  final VoidCallback? onJoin;
  final VoidCallback? onFavorite;
  final VoidCallback? onInfo;
  final VoidCallback? onTap;
  final double? width;
  final double? height;
  final bool showThumbnail;
  final bool showPlayerCount;
  final bool showStatus;
  final bool showFavoriteButton;
  final bool showJoinButton;
  final bool hoverEffect;
  final bool glowOnHover;
  final bool magicBorder;
  
  // 🦾 Accessibility Parameters
  final String? semanticLabel;
  final String? semanticHint;

  const WorldPreviewCard({
    super.key,
    required this.world,
    this.onJoin,
    this.onFavorite,
    this.onInfo,
    this.onTap,
    this.width,
    this.height,
    this.showThumbnail = true,
    this.showPlayerCount = true,
    this.showStatus = true,
    this.showFavoriteButton = true,
    this.showJoinButton = true,
    this.hoverEffect = true,
    this.glowOnHover = true,
    this.magicBorder = true,
    // 🦾 Accessibility
    this.semanticLabel,
    this.semanticHint,
  });

  /// Compact world card
  const WorldPreviewCard.compact({
    super.key,
    required this.world,
    this.onJoin,
    this.onFavorite,
    this.onInfo,
    this.onTap,
    this.width = 250,
    this.height = 180,
    this.showThumbnail = true,
    this.showPlayerCount = true,
    this.showStatus = true,
    this.showFavoriteButton = false,
    this.showJoinButton = true,
    this.hoverEffect = true,
    this.glowOnHover = false,
    this.magicBorder = false,
    // 🦾 Accessibility
    this.semanticLabel,
    this.semanticHint,
  });

  /// Large world card with all details
  const WorldPreviewCard.detailed({
    super.key,
    required this.world,
    this.onJoin,
    this.onFavorite,
    this.onInfo,
    this.onTap,
    this.width = 380,
    this.height = 280,
    this.showThumbnail = true,
    this.showPlayerCount = true,
    this.showStatus = true,
    this.showFavoriteButton = true,
    this.showJoinButton = true,
    this.hoverEffect = true,
    this.glowOnHover = true,
    this.magicBorder = true,
    // 🦾 Accessibility
    this.semanticLabel,
    this.semanticHint,
  });

  @override
  State<WorldPreviewCard> createState() => _WorldPreviewCardState();
}

class _WorldPreviewCardState extends State<WorldPreviewCard> with TickerProviderStateMixin {
  late AnimationController _hoverController;
  late AnimationController _glowController;
  
  late Animation<double> _scaleAnimation;
  late Animation<double> _glowAnimation;
  
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    
    // Hover animation
    _hoverController = AnimationController(
      duration: _getAnimationDuration(),
      vsync: this,
    );
    
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: _getScaleOnHover(),
    ).animate(CurvedAnimation(
      parent: _hoverController,
      curve: Curves.easeInOut,
    ));

    // Glow animation
    if (widget.glowOnHover) {
      _glowController = AnimationController(
        duration: const Duration(milliseconds: 1500),
        vsync: this,
      );
      
      _glowAnimation = Tween<double>(
        begin: 0.3,
        end: 1.0,
      ).animate(CurvedAnimation(
        parent: _glowController,
        curve: Curves.easeInOut,
      ));
    }
  }

  @override
  void dispose() {
    _hoverController.dispose();
    if (widget.glowOnHover) {
      _glowController.dispose();
    }
    super.dispose();
  }

  void _onEnter(PointerEnterEvent event) {
    if (!widget.hoverEffect) return;
    
    setState(() => _isHovered = true);
    _hoverController.forward();
    
    if (widget.glowOnHover) {
      _glowController.repeat(reverse: true);
    }
  }

  void _onExit(PointerExitEvent event) {
    if (!widget.hoverEffect) return;
    
    setState(() => _isHovered = false);
    _hoverController.reverse();
    
    if (widget.glowOnHover) {
      _glowController.stop();
      _glowController.reset();
    }
  }

  @override
  Widget build(BuildContext context) {
    // 🎯 NEUE KONTEXTSENSITIVE THEME-BEREITSTELLUNG
    return ThemeContextConsumer(
      componentName: 'WorldPreviewCard',
      contextOverrides: {
        'status': widget.world.status.name,
        'hoverEffect': widget.hoverEffect.toString(),
        'interactive': widget.onTap != null ? 'true' : 'false',
      },
      builder: (context, contextTheme, extensions) {
        return _buildWorldCard(context, contextTheme, extensions);
      },
    );
  }

  Widget _buildWorldCard(BuildContext context, ThemeData theme, Map<String, dynamic>? extensions) {
    Widget card = AnimatedBuilder(
      animation: _hoverController,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: _buildCard(theme, extensions),
        );
      },
    );

    // Add glow effect
    if (widget.glowOnHover) {
      card = AnimatedBuilder(
        animation: _glowController,
        builder: (context, child) {
          return Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(_getBorderRadius()),
              boxShadow: _isHovered ? [
                BoxShadow(
                  color: _getGlowColor(theme, extensions).withValues(alpha: 0.3 * _glowAnimation.value),
                  blurRadius: 12 * _glowAnimation.value,
                  spreadRadius: 3 * _glowAnimation.value,
                ),
                BoxShadow(
                  color: _getGlowColor(theme, extensions).withValues(alpha: 0.1 * _glowAnimation.value),
                  blurRadius: 24 * _glowAnimation.value,
                  spreadRadius: 6 * _glowAnimation.value,
                ),
              ] : null,
            ),
            child: card,
          );
        },
      );
    }

    return Semantics(
      label: _getSemanticLabel(),
      hint: _getSemanticHint(),
      button: widget.onTap != null,
      enabled: widget.world.status == WorldStatus.online,
      onTap: widget.onTap,
      child: MouseRegion(
        onEnter: _onEnter,
        onExit: _onExit,
        child: GestureDetector(
          onTap: widget.onTap,
          child: card,
        ),
      ),
    );
  }

  Widget _buildCard(ThemeData theme, Map<String, dynamic>? extensions) {
    return Container(
      width: _getWidth(),
      height: _getHeight(),
      decoration: _getCardDecoration(theme, extensions),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Thumbnail
          if (widget.showThumbnail)
            _buildThumbnail(theme, extensions),
          
          // Content
          Expanded(
            child: Padding(
              padding: EdgeInsets.all(_getPadding()),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header with name and status
                  _buildHeader(theme),
                  
                  const SizedBox(height: 8),
                  
                  // Description
                  if (widget.world.description != null)
                    _buildDescription(theme),
                  
                  const Spacer(),
                  
                  // Footer with player count and actions
                  _buildFooter(theme, extensions),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildThumbnail(ThemeData theme, Map<String, dynamic>? extensions) {
    return Container(
      height: _getThumbnailHeight(),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(_getBorderRadius()),
          topRight: Radius.circular(_getBorderRadius()),
        ),
        color: theme.colorScheme.surfaceContainer,
      ),
      child: Stack(
        children: [
          // Thumbnail image or fallback
          Positioned.fill(
            child: ClipRRect(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(_getBorderRadius()),
                topRight: Radius.circular(_getBorderRadius()),
              ),
              child: widget.world.thumbnailUrl != null
                  ? Image.network(
                      widget.world.thumbnailUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => _buildFallbackIcon(theme),
                    )
                  : _buildFallbackIcon(theme),
            ),
          ),
          
          // Gradient overlay
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(_getBorderRadius()),
                  topRight: Radius.circular(_getBorderRadius()),
                ),
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withValues(alpha: 0.3),
                  ],
                ),
              ),
            ),
          ),
          
          // Status indicator
          if (widget.showStatus)
            Positioned(
              top: 12,
              right: 12,
              child: _buildStatusIndicator(theme),
            ),
        ],
      ),
    );
  }

  Widget _buildFallbackIcon(ThemeData theme) {
    return Container(
      color: theme.colorScheme.surfaceContainer,
      child: Icon(
        Icons.public,
        size: 48,
        color: theme.colorScheme.onSurfaceVariant,
      ),
    );
  }

  Widget _buildStatusIndicator(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: _getStatusColor().withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: _getStatusIndicatorSize(),
            height: _getStatusIndicatorSize(),
            decoration: BoxDecoration(
              color: _getStatusColor(),
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            _getStatusText(),
            style: theme.textTheme.bodySmall?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(ThemeData theme) {
    return Row(
      children: [
        Expanded(
          child: Text(
            widget.world.name,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        
        if (widget.showFavoriteButton)
          IconButton(
            onPressed: widget.onFavorite,
            icon: Icon(
              widget.world.isFavorite ? Icons.favorite : Icons.favorite_border,
              color: widget.world.isFavorite ? Colors.red : theme.colorScheme.onSurfaceVariant,
              size: 20,
            ),
            visualDensity: VisualDensity.compact,
          ),
      ],
    );
  }

  Widget _buildDescription(ThemeData theme) {
    return Text(
      widget.world.description!,
      style: theme.textTheme.bodySmall?.copyWith(
        color: theme.colorScheme.onSurfaceVariant,
      ),
      maxLines: _getMaxDescriptionLines(),
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget _buildFooter(ThemeData theme, Map<String, dynamic>? extensions) {
    return Row(
      children: [
        // Player count
        if (widget.showPlayerCount) ...[
          Icon(
            Icons.people,
            size: 16,
            color: theme.colorScheme.onSurfaceVariant,
          ),
          const SizedBox(width: 4),
          Text(
            '${widget.world.currentPlayers}/${widget.world.maxPlayers}',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
        
        const Spacer(),
        
        // Join button
        if (widget.showJoinButton)
          ElevatedButton(
            onPressed: widget.world.status == WorldStatus.online ? widget.onJoin : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: _getJoinButtonColor(theme, extensions),
              foregroundColor: theme.colorScheme.onPrimary,
              minimumSize: const Size(80, 32),
              visualDensity: VisualDensity.compact,
            ),
            child: Text(_getJoinButtonText()),
          ),
      ],
    );
  }

  /// Get card decoration with magic border
  BoxDecoration _getCardDecoration(ThemeData theme, Map<String, dynamic>? extensions) {
    return BoxDecoration(
      color: theme.colorScheme.surface,
      borderRadius: BorderRadius.circular(_getBorderRadius()),
      border: widget.magicBorder ? Border.all(
        color: _getMagicBorderColor(theme, extensions),
        width: 1.5,
      ) : null,
      boxShadow: [
        BoxShadow(
          color: theme.colorScheme.shadow.withValues(alpha: 0.1),
          blurRadius: 8,
          offset: const Offset(0, 2),
        ),
      ],
    );
  }

  /// Get glow color for hover effect
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

  /// Get magic border color
  Color _getMagicBorderColor(ThemeData theme, Map<String, dynamic>? extensions) {
    return _getGlowColor(theme, extensions).withValues(alpha: 0.3);
  }

  /// Get status color based on world status
  Color _getStatusColor() {
    switch (widget.world.status) {
      case WorldStatus.online:
        return const Color(0xFF22C55E); // Schema default: green
      case WorldStatus.offline:
        return const Color(0xFFEF4444); // Schema default: red
      case WorldStatus.maintenance:
        return const Color(0xFFF59E0B); // Schema default: amber
      case WorldStatus.full:
        return const Color(0xFF8B5CF6); // Schema default: violet
    }
  }

  /// Get status text
  String _getStatusText() {
    switch (widget.world.status) {
      case WorldStatus.online:
        return 'Online';
      case WorldStatus.offline:
        return 'Offline';
      case WorldStatus.maintenance:
        return 'Maintenance';
      case WorldStatus.full:
        return 'Full';
    }
  }

  /// Get join button color
  Color _getJoinButtonColor(ThemeData theme, Map<String, dynamic>? extensions) {
    if (widget.world.status != WorldStatus.online) {
      return theme.colorScheme.surfaceContainer;
    }
    return _getGlowColor(theme, extensions);
  }

  /// Get join button text
  String _getJoinButtonText() {
    switch (widget.world.status) {
      case WorldStatus.online:
        return 'Join';
      case WorldStatus.offline:
        return 'Offline';
      case WorldStatus.maintenance:
        return 'Maintenance';
      case WorldStatus.full:
        return 'Full';
    }
  }

  /// Get width from schema
  double _getWidth() {
    return widget.width ?? 320.0; // Schema default
  }

  /// Get height from schema
  double _getHeight() {
    return widget.height ?? 240.0; // Schema default
  }

  /// Get border radius from schema
  double _getBorderRadius() {
    return 16.0; // Schema default
  }

  /// Get padding from schema
  double _getPadding() {
    return 16.0; // Schema default
  }

  /// Get thumbnail height from schema
  double _getThumbnailHeight() {
    return 120.0; // Schema default
  }

  /// Get status indicator size from schema
  double _getStatusIndicatorSize() {
    return 12.0; // Schema default
  }

  /// Get max description lines from schema
  int _getMaxDescriptionLines() {
    return 2; // Schema default
  }

  /// Get scale on hover from schema
  double _getScaleOnHover() {
    return 1.02; // Schema default
  }

  /// Get animation duration from schema
  Duration _getAnimationDuration() {
    return const Duration(milliseconds: 200); // Schema default
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

  /// 🦾 ACCESSIBILITY FIX: Generate semantic label with world info
  String _getSemanticLabel() {
    if (widget.semanticLabel != null) return widget.semanticLabel!;
    
    List<String> labelParts = [];
    
    // World name
    labelParts.add(widget.world.name);
    
    // Status
    labelParts.add(_getStatusText());
    
    // Player count
    if (widget.showPlayerCount) {
      final ratio = '${widget.world.currentPlayers}/${widget.world.maxPlayers}';
      labelParts.add('$ratio players');
    }
    
    // Creator
    if (widget.world.creator != null) {
      labelParts.add('by ${widget.world.creator}');
    }
    
    return labelParts.join(', ');
  }

  /// 🦾 ACCESSIBILITY FIX: Generate semantic hint with actions
  String? _getSemanticHint() {
    if (widget.semanticHint != null) return widget.semanticHint!;
    
    List<String> hints = [];
    
    // Description
    if (widget.world.description != null && widget.world.description!.isNotEmpty) {
      hints.add(widget.world.description!);
    }
    
    // Tags
    if (widget.world.tags.isNotEmpty) {
      hints.add('Tags: ${widget.world.tags.join(', ')}');
    }
    
    // Favorite status
    if (widget.world.isFavorite) {
      hints.add('Favorite world');
    }
    
    // Available actions
    List<String> actions = [];
    if (widget.onJoin != null && widget.world.status == WorldStatus.online) {
      actions.add('Double tap to join');
    }
    if (widget.onFavorite != null) {
      actions.add('Favorite');
    }
    if (widget.onInfo != null) {
      actions.add('More info');
    }
    
    if (actions.isNotEmpty) {
      hints.add('Actions: ${actions.join(', ')}');
    }
    
    return hints.isNotEmpty ? hints.join('. ') : null;
  }


}