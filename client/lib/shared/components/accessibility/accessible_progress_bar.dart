import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'accessibility_provider.dart';
import '../../../core/providers/theme_context_provider.dart';

/// 📊 Accessible Progress Bar based on Gaming Accessibility Schema
/// 
/// Color-blind safe progress bars for health, mana, stamina with high contrast and patterns
class AccessibleProgressBar extends StatelessWidget {
  final String resourceType; // health, mana, stamina, experience
  final double value; // 0.0 to 1.0
  final double height;
  final bool showText;
  final bool showPattern;
  final String? label;
  final Color? customColor;

  const AccessibleProgressBar({
    super.key,
    required this.resourceType,
    required this.value,
    this.height = 20.0,
    this.showText = true,
    this.showPattern = false,
    this.label,
    this.customColor,
  });

  @override
  Widget build(BuildContext context) {
    // 🎯 NEUE KONTEXTSENSITIVE THEME-BEREITSTELLUNG
    return ThemeContextConsumer(
      componentName: 'AccessibleProgressBar',
      contextOverrides: {
        'type': resourceType,
        'value': value.toString(),
        'showPattern': showPattern.toString(),
      },
      builder: (context, contextTheme, extensions) {
        final accessibilityProvider = AccessibilityProviderWidget.of(context);
        
        if (accessibilityProvider == null) {
          return _buildDefaultProgressBar(contextTheme);
        }
        
        return _buildAccessibleProgressBar(context, contextTheme, accessibilityProvider);
      },
    );
  }

  /// Build default progress bar when no accessibility provider
  Widget _buildDefaultProgressBar(ThemeData theme) {
    return LinearProgressIndicator(
      value: value,
      backgroundColor: theme.colorScheme.surfaceContainer,
      valueColor: AlwaysStoppedAnimation<Color>(
        customColor ?? _getDefaultResourceColor(resourceType, theme),
      ),
      minHeight: height,
    );
  }

  /// Build accessible progress bar with all accessibility features
  Widget _buildAccessibleProgressBar(
    BuildContext context,
    ThemeData theme,
    AccessibilityProvider provider,
  ) {
    final settings = provider.settings;
    final resourceColor = customColor ?? provider.getResourceColor(resourceType, theme);
    final shouldAvoidGradients = provider.shouldAvoidGradients();
    final contrastMultiplier = provider.getContrastMultiplier();
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Label
        if (showText && (label != null || resourceType.isNotEmpty))
          Padding(
            padding: const EdgeInsets.only(bottom: 4.0),
            child: Text(
              label ?? _getResourceLabel(resourceType),
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.onSurface,
              ),
            ),
          ),
        
        // Progress bar container
        Container(
          height: height,
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainer,
            borderRadius: BorderRadius.circular(height / 2),
            border: settings.increasedContrast ? Border.all(
              color: theme.colorScheme.outline,
              width: 1.0,
            ) : null,
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(height / 2),
            child: Stack(
              children: [
                // Background pattern (if enabled)
                if (showPattern && settings.usePatternsForRarity)
                  _buildBackgroundPattern(resourceColor),
                
                // Progress fill
                Align(
                  alignment: Alignment.centerLeft,
                  child: FractionallySizedBox(
                    widthFactor: value.clamp(0.0, 1.0),
                    child: Container(
                      height: height,
                      decoration: BoxDecoration(
                        color: shouldAvoidGradients
                            ? resourceColor
                            : null,
                        gradient: shouldAvoidGradients
                            ? null
                            : _buildGradient(resourceColor),
                        borderRadius: BorderRadius.circular(height / 2),
                      ),
                    ),
                  ),
                ),
                
                // Progress text overlay
                if (showText)
                  Center(
                    child: Text(
                      '${(value * 100).round()}%',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: _getTextColor(resourceColor, theme),
                        fontWeight: FontWeight.bold,
                        fontSize: (height * 0.6).clamp(8.0, 14.0),
                      ),
                    ),
                  ),
                
                // High contrast border overlay
                if (settings.increasedContrast)
                  Container(
                    height: height,
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: resourceColor.withValues(alpha: 0.5 * contrastMultiplier),
                        width: 2.0,
                      ),
                      borderRadius: BorderRadius.circular(height / 2),
                    ),
                  ),
              ],
            ),
          ),
        ),
        
        // Value text (if enabled)
        if (showText)
          Padding(
            padding: const EdgeInsets.only(top: 2.0),
            child: Text(
              _getValueText(),
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
              ),
            ),
          ),
      ],
    );
  }

  /// Build background pattern for additional visual differentiation
  Widget _buildBackgroundPattern(Color color) {
    return Positioned.fill(
      child: CustomPaint(
        painter: ProgressPatternPainter(
          resourceType: resourceType,
          color: color.withValues(alpha: 0.1),
        ),
      ),
    );
  }

  /// Build gradient for progress fill
  LinearGradient _buildGradient(Color color) {
    switch (resourceType.toLowerCase()) {
      case 'health':
        return LinearGradient(
          colors: [
            color.withValues(alpha: 0.8),
            color,
            color.withValues(alpha: 0.9),
          ],
          stops: const [0.0, 0.5, 1.0],
        );
      case 'mana':
        return LinearGradient(
          colors: [
            color,
            color.withValues(alpha: 0.7),
            color,
          ],
          stops: const [0.0, 0.5, 1.0],
        );
      default:
        return LinearGradient(
          colors: [color.withValues(alpha: 0.9), color],
        );
    }
  }

  /// Get text color with good contrast
  Color _getTextColor(Color backgroundColor, ThemeData theme) {
    // Calculate luminance to determine if we need light or dark text
    final luminance = backgroundColor.computeLuminance();
    return luminance > 0.5 
        ? theme.colorScheme.onSurface
        : theme.colorScheme.surface;
  }

  /// Get resource label text
  String _getResourceLabel(String resourceType) {
    switch (resourceType.toLowerCase()) {
      case 'health':
        return 'Health';
      case 'mana':
        return 'Mana';
      case 'stamina':
        return 'Stamina';
      case 'experience':
        return 'Experience';
      default:
        return resourceType.toUpperCase();
    }
  }

  /// Get value text with current/max format
  String _getValueText() {
    final percentage = (value * 100).round();
    return '$percentage%';
  }

  /// Get default resource color (fallback)
  Color _getDefaultResourceColor(String resourceType, ThemeData theme) {
    switch (resourceType.toLowerCase()) {
      case 'health':
        return Colors.red;
      case 'mana':
        return Colors.blue;
      case 'stamina':
        return Colors.yellow;
      case 'experience':
        return Colors.purple;
      default:
        return theme.colorScheme.primary;
    }
  }
}

/// 🎨 Progress Pattern Painter for visual differentiation
class ProgressPatternPainter extends CustomPainter {
  final String resourceType;
  final Color color;

  ProgressPatternPainter({
    required this.resourceType,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;

    switch (resourceType.toLowerCase()) {
      case 'health':
        _drawCrossPattern(canvas, size, paint);
        break;
      case 'mana':
        _drawWavePattern(canvas, size, paint);
        break;
      case 'stamina':
        _drawLightningPattern(canvas, size, paint);
        break;
      case 'experience':
        _drawStarPattern(canvas, size, paint);
        break;
      default:
        _drawDiagonalLines(canvas, size, paint);
        break;
    }
  }

  void _drawCrossPattern(Canvas canvas, Size size, Paint paint) {
    final spacing = size.height / 3;
    for (double x = spacing; x < size.width; x += spacing * 2) {
      final centerY = size.height / 2;
      final crossSize = spacing * 0.6;
      
      // Horizontal line
      canvas.drawLine(
        Offset(x - crossSize / 2, centerY),
        Offset(x + crossSize / 2, centerY),
        paint,
      );
      // Vertical line
      canvas.drawLine(
        Offset(x, centerY - crossSize / 2),
        Offset(x, centerY + crossSize / 2),
        paint,
      );
    }
  }

  void _drawWavePattern(Canvas canvas, Size size, Paint paint) {
    final path = Path();
    final waveHeight = size.height * 0.3;
    final waveLength = size.width / 4;
    
    path.moveTo(0, size.height / 2);
    for (double x = 0; x <= size.width; x += waveLength) {
      path.quadraticBezierTo(
        x + waveLength / 2, size.height / 2 + waveHeight,
        x + waveLength, size.height / 2,
      );
    }
    
    canvas.drawPath(path, paint);
  }

  void _drawLightningPattern(Canvas canvas, Size size, Paint paint) {
    final spacing = size.width / 6;
    for (double x = spacing; x < size.width; x += spacing) {
      final path = Path()
        ..moveTo(x, size.height * 0.2)
        ..lineTo(x - spacing * 0.2, size.height * 0.5)
        ..lineTo(x + spacing * 0.1, size.height * 0.5)
        ..lineTo(x - spacing * 0.1, size.height * 0.8);
      
      canvas.drawPath(path, paint);
    }
  }

  void _drawStarPattern(Canvas canvas, Size size, Paint paint) {
    final spacing = size.height;
    for (double x = spacing; x < size.width; x += spacing * 1.5) {
      final centerY = size.height / 2;
      final starSize = size.height * 0.3;
      
      // Draw simple star
      for (int i = 0; i < 5; i++) {
        final angle1 = (i * 72) * (3.14159 / 180);
        final angle2 = ((i + 1) * 72) * (3.14159 / 180);
        
        canvas.drawLine(
          Offset(
            x + starSize * angle1.cos(),
            centerY + starSize * angle1.sin(),
          ),
          Offset(
            x + starSize * angle2.cos(),
            centerY + starSize * angle2.sin(),
          ),
          paint,
        );
      }
    }
  }

  void _drawDiagonalLines(Canvas canvas, Size size, Paint paint) {
    final spacing = size.height / 2;
    for (double x = 0; x < size.width + size.height; x += spacing) {
      canvas.drawLine(
        Offset(x, 0),
        Offset(x - size.height, size.height),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant ProgressPatternPainter oldDelegate) {
    return oldDelegate.resourceType != resourceType || oldDelegate.color != color;
  }
}