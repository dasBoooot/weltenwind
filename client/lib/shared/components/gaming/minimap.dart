import 'dart:math' as math;
import 'dart:async';
import 'package:flutter/material.dart';
import '../../../core/services/modular_theme_service.dart';

/// 🗺️ Minimap Entity Types
enum MinimapEntityType {
  player,
  enemy,
  ally,
  npc,
  item,
  objective,
  portal,
}

/// 📍 Minimap Entity Data
class MinimapEntity {
  final String id;
  final MinimapEntityType type;
  final double x; // World position X
  final double y; // World position Y
  final double? direction; // Rotation in radians
  final Color? customColor;
  final double? customSize;
  final bool isVisible;

  const MinimapEntity({
    required this.id,
    required this.type,
    required this.x,
    required this.y,
    this.direction,
    this.customColor,
    this.customSize,
    this.isVisible = true,
  });
}

/// 🗺️ Gaming Minimap Component based on HUD Schema
/// 
/// In-game minimap with player dot, enemy tracking, and world navigation
class GameMinimap extends StatefulWidget {
  final double size;
  final double worldWidth;
  final double worldHeight;
  final double playerX;
  final double playerY;
  final double? playerDirection;
  final List<MinimapEntity> entities;
  final VoidCallback? onTap;
  final bool showGrid;
  final bool showZoom;
  final double zoomLevel;

  const GameMinimap({
    super.key,
    this.size = 150.0, // Schema default
    required this.worldWidth,
    required this.worldHeight,
    required this.playerX,
    required this.playerY,
    this.playerDirection,
    this.entities = const [],
    this.onTap,
    this.showGrid = false,
    this.showZoom = true,
    this.zoomLevel = 1.0,
  });

  @override
  State<GameMinimap> createState() => _GameMinimapState();
}

class _GameMinimapState extends State<GameMinimap> with TickerProviderStateMixin {
  late AnimationController _playerGlowController;
  late AnimationController _radarSweepController;
  late Animation<double> _playerGlowAnimation;
  late Animation<double> _radarSweepAnimation;
  
  // 🔥 PERFORMANCE FIX: Timer for entity updates
  Timer? _entityUpdateTimer;

  @override
  void initState() {
    super.initState();
    
    // Player glow animation
    _playerGlowController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    
    _playerGlowAnimation = Tween<double>(
      begin: 0.3,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _playerGlowController,
      curve: Curves.easeInOut,
    ));
    
    // 🔥 PERFORMANCE FIX: Slower radar sweep for better performance
    _radarSweepController = AnimationController(
      duration: const Duration(milliseconds: 5000), // 3s → 5s throttling
      vsync: this,
    );
    
    _radarSweepAnimation = Tween<double>(
      begin: 0.0,
      end: 2 * math.pi,
    ).animate(CurvedAnimation(
      parent: _radarSweepController,
      curve: Curves.linear,
    ));

    _playerGlowController.repeat(reverse: true);
    _radarSweepController.repeat();
    
    // 🔥 PERFORMANCE FIX: Throttled entity updates via Timer.periodic
    _entityUpdateTimer = Timer.periodic(
      const Duration(milliseconds: 200), // Update every 200ms instead of every frame
      (timer) {
        if (mounted) {
          setState(() {
            // This triggers a rebuild, but only every 200ms for better performance
          });
        }
      },
    );
  }

  @override
  void dispose() {
    _playerGlowController.dispose();
    _radarSweepController.dispose();
    _entityUpdateTimer?.cancel(); // 🔥 PERFORMANCE FIX: Clean up timer
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final extensions = ModularThemeService().getCurrentThemeExtensions();
    
    return GestureDetector(
      onTap: widget.onTap,
      child: Container(
        width: _getResponsiveSize(),
        height: _getResponsiveSize(),
        decoration: _getMinimapDecoration(theme, extensions),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(_getBorderRadius()),
          child: AnimatedBuilder(
            animation: Listenable.merge([_playerGlowController, _radarSweepController]),
            builder: (context, child) {
              return CustomPaint(
                size: Size(_getResponsiveSize(), _getResponsiveSize()),
                painter: MinimapPainter(
                  worldWidth: widget.worldWidth,
                  worldHeight: widget.worldHeight,
                  playerX: widget.playerX,
                  playerY: widget.playerY,
                  playerDirection: widget.playerDirection,
                  entities: widget.entities,
                  playerGlowIntensity: _playerGlowAnimation.value,
                  radarSweepAngle: _radarSweepAnimation.value,
                  theme: theme,
                  extensions: extensions,
                  showGrid: widget.showGrid,
                  zoomLevel: widget.zoomLevel,
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  /// Minimap container decoration
  BoxDecoration _getMinimapDecoration(ThemeData theme, Map<String, dynamic>? extensions) {
    return BoxDecoration(
      color: _getBackgroundColor(theme), // Schema backgroundColor
      borderRadius: BorderRadius.circular(_getBorderRadius()),
      border: Border.all(
        color: _getBorderColor(theme), // Schema borderColor
        width: _getBorderWidth(), // Schema borderWidth
      ),
      boxShadow: [
        BoxShadow(
          color: theme.colorScheme.shadow.withValues(alpha: 0.3),
          blurRadius: 8,
          spreadRadius: 1,
          offset: const Offset(0, 2),
        ),
      ],
    );
  }

  /// Background color from schema
  Color _getBackgroundColor(ThemeData theme) {
    // Schema default: #00000080 (black with alpha)
    return const Color(0x80000000);
  }

  /// Border color from schema
  Color _getBorderColor(ThemeData theme) {
    // Schema default: #7C6BAF (purple)
    return const Color(0xFF7C6BAF);
  }

  /// Border radius from schema
  double _getBorderRadius() {
    return 8.0; // Schema default
  }

  /// Border width from schema
  double _getBorderWidth() {
    return 2.0; // Schema default
  }

  /// 🔥 RESPONSIVE FIX: Calculate responsive minimap size
  double _getResponsiveSize() {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final smallerDimension = math.min(screenWidth, screenHeight);
    
    // Use provided size if it's not the default, otherwise calculate responsive size
    if (widget.size != 150.0) {
      return widget.size; // User provided explicit size
    }
    
    // Calculate responsive size based on screen size
    if (smallerDimension < 600) {
      return 100.0; // Mobile: 100px (smaller for limited screen space)
    } else if (smallerDimension < 900) {
      return 150.0; // Tablet: 150px (default)  
    } else {
      return 200.0; // Desktop: 200px (larger for better visibility)
    }
  }
}

/// 🎨 Custom Painter for Minimap
class MinimapPainter extends CustomPainter {
  final double worldWidth;
  final double worldHeight;
  final double playerX;
  final double playerY;
  final double? playerDirection;
  final List<MinimapEntity> entities;
  final double playerGlowIntensity;
  final double radarSweepAngle;
  final ThemeData theme;
  final Map<String, dynamic>? extensions;
  final bool showGrid;
  final double zoomLevel;

  MinimapPainter({
    required this.worldWidth,
    required this.worldHeight,
    required this.playerX,
    required this.playerY,
    this.playerDirection,
    required this.entities,
    required this.playerGlowIntensity,
    required this.radarSweepAngle,
    required this.theme,
    this.extensions,
    required this.showGrid,
    required this.zoomLevel,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    
    // Draw grid if enabled
    if (showGrid) {
      _drawGrid(canvas, size);
    }
    
    // Draw radar sweep effect
    _drawRadarSweep(canvas, size, center);
    
    // Draw entities
    for (final entity in entities) {
      if (entity.isVisible) {
        _drawEntity(canvas, size, entity);
      }
    }
    
    // Draw player (always on top)
    _drawPlayer(canvas, size, center);
  }

  /// Draw grid lines
  void _drawGrid(Canvas canvas, Size size) {
    final gridPaint = Paint()
      ..color = theme.colorScheme.onSurface.withValues(alpha: 0.1)
      ..strokeWidth = 0.5;
    
    const gridSpacing = 20.0;
    for (double x = 0; x < size.width; x += gridSpacing) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), gridPaint);
    }
    for (double y = 0; y < size.height; y += gridSpacing) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }
  }

  /// Draw radar sweep effect
  void _drawRadarSweep(Canvas canvas, Size size, Offset center) {
    final sweepPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          theme.colorScheme.primary.withValues(alpha: 0.3),
          Colors.transparent,
        ],
        stops: const [0.0, 1.0],
      ).createShader(Rect.fromCircle(center: center, radius: size.width / 2))
      ..style = PaintingStyle.fill;
    
    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(radarSweepAngle);
    
    canvas.drawArc(
      Rect.fromCircle(center: Offset.zero, radius: size.width / 2),
      -math.pi / 6, // Start angle
      math.pi / 3,  // Sweep angle (60 degrees)
      true,
      sweepPaint,
    );
    
    canvas.restore();
  }

  /// Draw player dot with glow
  void _drawPlayer(Canvas canvas, Size size, Offset center) {
    // Player glow
    final glowPaint = Paint()
      ..color = _getPlayerColor().withValues(alpha: 0.5 * playerGlowIntensity)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3.0);
    
    canvas.drawCircle(center, _getPlayerGlowRadius() * playerGlowIntensity, glowPaint);
    
    // Player dot
    final playerPaint = Paint()
      ..color = _getPlayerColor()
      ..style = PaintingStyle.fill;
    
    canvas.drawCircle(center, _getPlayerSize(), playerPaint);
    
    // Direction arrow if available
    if (playerDirection != null && _showPlayerDirection()) {
      _drawPlayerDirection(canvas, center);
    }
  }

  /// Draw player direction arrow
  void _drawPlayerDirection(Canvas canvas, Offset center) {
    final arrowPaint = Paint()
      ..color = _getPlayerColor()
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;
    
    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(playerDirection! - math.pi / 2); // Adjust for up direction
    
    final arrowSize = _getPlayerSize() + 4;
    final path = Path()
      ..moveTo(0, -arrowSize)
      ..lineTo(-3, -arrowSize + 5)
      ..moveTo(0, -arrowSize)
      ..lineTo(3, -arrowSize + 5);
    
    canvas.drawPath(path, arrowPaint);
    canvas.restore();
  }

  /// Draw entity on minimap
  void _drawEntity(Canvas canvas, Size size, MinimapEntity entity) {
    final worldToMap = _worldToMapCoordinates(entity.x, entity.y, size);
    if (!_isInBounds(worldToMap, size)) return;
    
    final entityColor = entity.customColor ?? _getEntityColor(entity.type);
    final entitySize = entity.customSize ?? _getEntitySize(entity.type);
    
    final entityPaint = Paint()
      ..color = entityColor
      ..style = PaintingStyle.fill;
    
    canvas.drawCircle(worldToMap, entitySize, entityPaint);
    
    // Special effects for certain entity types
    if (entity.type == MinimapEntityType.portal) {
      _drawPortalEffect(canvas, worldToMap, entitySize);
    }
  }

  /// Draw portal glow effect
  void _drawPortalEffect(Canvas canvas, Offset position, double size) {
    final portalGlow = Paint()
      ..color = theme.colorScheme.tertiary.withValues(alpha: 0.3)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4.0);
    
    canvas.drawCircle(position, size * 2, portalGlow);
  }

  /// Convert world coordinates to minimap coordinates
  Offset _worldToMapCoordinates(double worldX, double worldY, Size size) {
    final scaleX = size.width / worldWidth * zoomLevel;
    final scaleY = size.height / worldHeight * zoomLevel;
    
    // Center on player
    final offsetX = size.width / 2 - (playerX * scaleX);
    final offsetY = size.height / 2 - (playerY * scaleY);
    
    return Offset(
      worldX * scaleX + offsetX,
      worldY * scaleY + offsetY,
    );
  }

  /// Check if position is within minimap bounds
  bool _isInBounds(Offset position, Size size) {
    return position.dx >= 0 && 
           position.dx <= size.width && 
           position.dy >= 0 && 
           position.dy <= size.height;
  }

  /// Player color from schema
  Color _getPlayerColor() {
    return const Color(0xFFFFD700); // Schema default: gold
  }

  /// Player size from schema
  double _getPlayerSize() {
    return 6.0; // Schema default
  }

  /// Player glow radius from schema
  double _getPlayerGlowRadius() {
    return 3.0; // Schema default
  }

  /// Show player direction from schema
  bool _showPlayerDirection() {
    return true; // Schema default
  }

  /// Entity color based on type
  Color _getEntityColor(MinimapEntityType type) {
    switch (type) {
      case MinimapEntityType.player:
        return const Color(0xFFFFD700); // Gold
      case MinimapEntityType.enemy:
        return const Color(0xFFE74C3C); // Red - Schema default
      case MinimapEntityType.ally:
        return const Color(0xFF2ECC71); // Green
      case MinimapEntityType.npc:
        return const Color(0xFF3498DB); // Blue
      case MinimapEntityType.item:
        return const Color(0xFFF39C12); // Orange
      case MinimapEntityType.objective:
        return const Color(0xFF9B59B6); // Purple
      case MinimapEntityType.portal:
        return const Color(0xFF1ABC9C); // Teal
    }
  }

  /// Entity size based on type
  double _getEntitySize(MinimapEntityType type) {
    switch (type) {
      case MinimapEntityType.player:
        return 6.0;
      case MinimapEntityType.enemy:
        return 4.0; // Schema default
      case MinimapEntityType.ally:
        return 4.0;
      case MinimapEntityType.npc:
        return 3.0;
      case MinimapEntityType.item:
        return 2.0;
      case MinimapEntityType.objective:
        return 5.0;
      case MinimapEntityType.portal:
        return 6.0;
    }
  }

  @override
  bool shouldRepaint(covariant MinimapPainter oldDelegate) {
    return oldDelegate.playerX != playerX ||
           oldDelegate.playerY != playerY ||
           oldDelegate.playerDirection != playerDirection ||
           oldDelegate.entities != entities ||
           oldDelegate.playerGlowIntensity != playerGlowIntensity ||
           oldDelegate.radarSweepAngle != radarSweepAngle ||
           oldDelegate.zoomLevel != zoomLevel;
  }
}