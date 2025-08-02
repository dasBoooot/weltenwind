import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'accessibility_provider.dart';
import '../../../core/providers/theme_context_provider.dart';

/// 💎 Accessible Rarity Indicator based on Accessibility Schema
/// 
/// Color-blind safe rarity indicator with symbols, shapes, and high contrast
class AccessibleRarityIndicator extends StatelessWidget {
  final String rarity;
  final double size;
  final bool showSymbol;
  final bool showShape;
  final bool showPattern;

  const AccessibleRarityIndicator({
    super.key,
    required this.rarity,
    this.size = 24.0,
    this.showSymbol = true,
    this.showShape = true,
    this.showPattern = false,
  });

  @override
  Widget build(BuildContext context) {
    // 🎯 NEUE KONTEXTSENSITIVE THEME-BEREITSTELLUNG
    return ThemeContextConsumer(
      componentName: 'AccessibleRarityIndicator',
      contextOverrides: {
        'rarity': rarity,
        'size': size.toString(),
        'showSymbol': showSymbol.toString(),
      },
      builder: (context, contextTheme, extensions) {
        final accessibilityProvider = AccessibilityProviderWidget.of(context);
        
        if (accessibilityProvider == null) {
          return _buildDefaultIndicator(contextTheme);
        }
        
        final settings = accessibilityProvider.settings;
        
        return Container(
          width: size,
          height: size,
          decoration: _getDecoration(contextTheme, accessibilityProvider),
          child: _buildContent(contextTheme, accessibilityProvider),
        );
      },
    );
  }

  /// Build default indicator when no accessibility provider
  Widget _buildDefaultIndicator(ThemeData theme) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: _getDefaultRarityColor(),
        shape: BoxShape.circle,
      ),
    );
  }

  /// Get container decoration with accessibility features
  BoxDecoration _getDecoration(ThemeData theme, AccessibilityProvider provider) {
    final settings = provider.settings;
    final rarityColor = provider.getRarityColor(rarity, theme);
    final contrastMultiplier = provider.getContrastMultiplier();
    
    return BoxDecoration(
      color: rarityColor.withValues(alpha: 0.2 * contrastMultiplier),
      border: Border.all(
        color: rarityColor,
        width: settings.increasedContrast ? 3.0 : 2.0,
      ),
      borderRadius: settings.useShapesForRarity 
          ? _getShapeBorderRadius()
          : BorderRadius.circular(size / 2),
      boxShadow: settings.increasedContrast ? [
        BoxShadow(
          color: rarityColor.withValues(alpha: 0.3),
          blurRadius: 4,
          spreadRadius: 1,
        ),
      ] : null,
    );
  }

  /// Get border radius based on rarity shape
  BorderRadius _getShapeBorderRadius() {
    switch (rarity.toLowerCase()) {
      case 'common':
        return BorderRadius.circular(size / 2); // Circle
      case 'uncommon':
        return BorderRadius.circular(4);        // Rounded square
      case 'rare':
        return BorderRadius.circular(0);        // Square
      case 'epic':
        return BorderRadius.circular(size / 4);  // Less rounded
      case 'legendary':
        return BorderRadius.circular(size / 8);  // Star-like
      case 'mythic':
        return BorderRadius.circular(2);        // Almost square
      default:
        return BorderRadius.circular(size / 2);
    }
  }

  /// Build content with symbol and pattern
  Widget _buildContent(ThemeData theme, AccessibilityProvider provider) {
    final settings = provider.settings;
    final rarityColor = provider.getRarityColor(rarity, theme);
    final symbol = provider.getRaritySymbol(rarity);
    
    if (!showSymbol || !settings.useSymbolsForRarity || symbol.isEmpty) {
      return const SizedBox.shrink();
    }
    
    return Center(
      child: Stack(
        children: [
          // Pattern background (if enabled)
          if (showPattern && settings.usePatternsForRarity)
            _buildPattern(rarityColor),
          
          // Symbol
          Text(
            symbol,
            style: TextStyle(
              color: rarityColor,
              fontSize: size * 0.6,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  /// Build pattern background for additional differentiation
  Widget _buildPattern(Color color) {
    return Positioned.fill(
      child: CustomPaint(
        painter: RarityPatternPainter(
          rarity: rarity,
          color: color.withValues(alpha: 0.2),
        ),
      ),
    );
  }

  /// Get default rarity color (fallback)
  Color _getDefaultRarityColor() {
    switch (rarity.toLowerCase()) {
      case 'common':
        return Colors.grey;
      case 'uncommon':
        return Colors.green;
      case 'rare':
        return Colors.blue;
      case 'epic':
        return Colors.purple;
      case 'legendary':
        return Colors.orange;
      case 'mythic':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}

/// 🎨 Rarity Pattern Painter for additional visual differentiation
class RarityPatternPainter extends CustomPainter {
  final String rarity;
  final Color color;

  RarityPatternPainter({
    required this.rarity,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;

    switch (rarity.toLowerCase()) {
      case 'common':
        // No pattern - solid
        break;
      case 'uncommon':
        _drawDiagonalLines(canvas, size, paint);
        break;
      case 'rare':
        _drawDots(canvas, size, paint);
        break;
      case 'epic':
        _drawCross(canvas, size, paint);
        break;
      case 'legendary':
        _drawStarPattern(canvas, size, paint);
        break;
      case 'mythic':
        _drawSpiral(canvas, size, paint);
        break;
    }
  }

  void _drawDiagonalLines(Canvas canvas, Size size, Paint paint) {
    final spacing = size.width / 4;
    for (double i = 0; i < size.width + size.height; i += spacing) {
      canvas.drawLine(
        Offset(i, 0),
        Offset(i - size.height, size.height),
        paint,
      );
    }
  }

  void _drawDots(Canvas canvas, Size size, Paint paint) {
    paint.style = PaintingStyle.fill;
    final spacing = size.width / 6;
    for (double x = spacing; x < size.width; x += spacing) {
      for (double y = spacing; y < size.height; y += spacing) {
        canvas.drawCircle(Offset(x, y), 1, paint);
      }
    }
  }

  void _drawCross(Canvas canvas, Size size, Paint paint) {
    final center = Offset(size.width / 2, size.height / 2);
    canvas.drawLine(
      Offset(center.dx - size.width / 4, center.dy),
      Offset(center.dx + size.width / 4, center.dy),
      paint,
    );
    canvas.drawLine(
      Offset(center.dx, center.dy - size.height / 4),
      Offset(center.dx, center.dy + size.height / 4),
      paint,
    );
  }

  void _drawStarPattern(Canvas canvas, Size size, Paint paint) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 4;
    
    for (int i = 0; i < 8; i++) {
      final angle = (i * 45) * (3.14159 / 180);
      canvas.drawLine(
        center,
        Offset(
          center.dx + radius * 0.5 * (i % 2 == 0 ? 1 : 0.5) * (angle).cos(),
          center.dy + radius * 0.5 * (i % 2 == 0 ? 1 : 0.5) * (angle).sin(),
        ),
        paint,
      );
    }
  }

  void _drawSpiral(Canvas canvas, Size size, Paint paint) {
    final center = Offset(size.width / 2, size.height / 2);
    final path = Path();
    
    for (double t = 0; t < 6.28; t += 0.2) {
      final radius = (t / 6.28) * (size.width / 4);
      final x = center.dx + radius * t.cos();
      final y = center.dy + radius * t.sin();
      
      if (t == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant RarityPatternPainter oldDelegate) {
    return oldDelegate.rarity != rarity || oldDelegate.color != color;
  }
}