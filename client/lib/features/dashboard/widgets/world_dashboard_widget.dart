import 'package:flutter/material.dart';
import 'tolkien_adventure_widget.dart';
import 'cyberpunk_hacking_widget.dart';
import 'space_console_widget.dart';
import 'nature_eco_widget.dart';
import 'roman_imperium_widget.dart';

/// 🌍 ULTIMATE WORLD DASHBOARD WIDGET
/// 
/// Dynamically loads the perfect widget for each world theme!
/// Each world feels like a completely different game experience!
class WorldDashboardWidget extends StatelessWidget {
  final String? worldTheme;
  final String? worldName;
  final int? worldId;
  final ThemeData theme;
  final Map<String, dynamic>? extensions;

  const WorldDashboardWidget({
    super.key,
    required this.worldTheme,
    required this.worldName,
    required this.worldId,
    required this.theme,
    required this.extensions,
  });

  @override
  Widget build(BuildContext context) {
    // 🎨 DYNAMIC WORLD EXPERIENCE SELECTION
    switch (worldTheme?.toLowerCase()) {
      case 'tolkien':
        return TolkienAdventureWidget(
          worldName: worldName,
          worldId: worldId,
          theme: theme,
          extensions: extensions,
        );
        
      case 'cyberpunk':
        return CyberpunkHackingWidget(
          worldName: worldName,
          worldId: worldId,
          theme: theme,
          extensions: extensions,
        );
        
      case 'space':
        return SpaceConsoleWidget(
          worldName: worldName,
          worldId: worldId,
          theme: theme,
          extensions: extensions,
        );
        
      case 'nature':
        return NatureEcoWidget(
          worldName: worldName,
          worldId: worldId,
          theme: theme,
          extensions: extensions,
        );
        
      case 'roman':
        return RomanImperiumWidget(
          worldName: worldName,
          worldId: worldId,
          theme: theme,
          extensions: extensions,
        );
        
      default:
        return _buildFallbackWidget(context);
    }
  }

  /// 🎯 Fallback for unknown themes
  Widget _buildFallbackWidget(BuildContext context) {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: theme.colorScheme.primary.withValues(alpha: 0.3),
            width: 2,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.explore,
              size: 64,
              color: theme.colorScheme.primary,
            ),
            const SizedBox(height: 16),
            Text(
              worldName ?? 'Unknown World',
              style: theme.textTheme.headlineMedium?.copyWith(
                color: theme.colorScheme.onSurface,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Theme: ${worldTheme ?? 'default'}',
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              '🎮 Adventure Awaits!',
              style: theme.textTheme.titleMedium?.copyWith(
                color: theme.colorScheme.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}