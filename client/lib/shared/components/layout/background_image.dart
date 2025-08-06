import 'package:flutter/material.dart';
import '../../../core/models/world.dart';
import '../../../shared/theme/theme_resolver.dart';
import '../../../config/logger.dart';
import '../../../config/env.dart';

/// 🖼️ Theme-aware Background Image Component
/// 
/// Zeigt ein Hintergrundbild basierend auf der aktuellen Welt und dem Theme an.
/// Unterstützt verschiedene Overlay-Typen für bessere Lesbarkeit.
class BackgroundImage extends StatelessWidget {
  final World world;
  final String? pageType;
  final String themeContext;
  final Widget child;
  final BackgroundOverlayType overlayType;
  final double overlayOpacity;
  final BoxFit fit;
  final Alignment alignment;

  const BackgroundImage({
    super.key,
    required this.world,
    required this.child,
    this.pageType,
    this.themeContext = 'pre-game',
    this.overlayType = BackgroundOverlayType.gradient,
    this.overlayOpacity = 0.3,
    this.fit = BoxFit.cover,
    this.alignment = Alignment.center,
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String?>(
      future: ThemeResolver().resolveBackgroundImage(
        world,
        context: themeContext,
        pageType: pageType,
      ),
      builder: (context, snapshot) {
        AppLogger.app.d('🖼️ BackgroundImage build', error: {
          'hasData': snapshot.hasData,
          'data': snapshot.data,
          'error': snapshot.error,
          'world': world.themeBundle,
          'pageType': pageType,
          'context': themeContext,
          'connectionState': snapshot.connectionState.toString(),
        });
        
        // Show loading indicator while waiting
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Stack(
            children: [
              _buildFallbackBackground(context),
              child,
            ],
          );
        }
        
        return Stack(
          children: [
            // Background (mit IgnorePointer)
            if (snapshot.hasData && snapshot.data != null)
              _buildBackgroundWithImage(context, snapshot.data!)
            else
              _buildFallbackBackground(context),
            
            // Content (ohne IgnorePointer)
            child,
          ],
        );
      },
    );
  }

  Widget _buildBackgroundWithImage(BuildContext context, String imagePath) {
    AppLogger.app.d('🖼️ Building background with image: $imagePath');
    
    return IgnorePointer(
      child: Stack(
        children: [
          // 🖼️ Background Image - Full screen
          Positioned.fill(
            child: _buildImageWidget(imagePath),
          ),
          
          // 🎨 Overlay - Full screen
          Positioned.fill(
            child: _buildOverlay(context),
          ),
        ],
      ),
    );
  }

  Widget _buildOverlay(BuildContext context) {
    final theme = Theme.of(context);
    
    switch (overlayType) {
      case BackgroundOverlayType.none:
        return const SizedBox.shrink();
        
      case BackgroundOverlayType.solid:
        return Container(
          color: theme.colorScheme.surface.withValues(alpha: overlayOpacity),
        );
        
      case BackgroundOverlayType.gradient:
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                theme.colorScheme.surface.withValues(alpha: overlayOpacity),
                theme.colorScheme.surface.withValues(alpha: overlayOpacity * 0.7),
                theme.colorScheme.surface.withValues(alpha: overlayOpacity),
              ],
            ),
          ),
        );
        
      case BackgroundOverlayType.theme:
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                theme.colorScheme.primary.withValues(alpha: overlayOpacity * 0.5),
                theme.colorScheme.secondary.withValues(alpha: overlayOpacity * 0.3),
                theme.colorScheme.tertiary.withValues(alpha: overlayOpacity * 0.4),
              ],
            ),
          ),
        );
    }
  }

  Widget _buildImageWidget(String imagePath) {
    // Check if it's a backend URL (contains http/https) or has placeholder
    if (imagePath.startsWith('http://') || 
        imagePath.startsWith('https://') ||
        imagePath.contains('{{ASSET_IP}}')) {
      
      // Replace placeholder with actual URL if needed
      String resolvedPath = imagePath;
      if (imagePath.contains('{{ASSET_IP}}')) {
        resolvedPath = imagePath.replaceAll('{{ASSET_IP}}', Env.assetUrl);
        AppLogger.app.d('🔍 Resolved asset path: $imagePath -> $resolvedPath');
      }
      
      return Image.network(
        resolvedPath,
        fit: BoxFit.cover,
        gaplessPlayback: true, // Prevent flickering
        errorBuilder: (context, error, stackTrace) {
          AppLogger.app.e('❌ Background image network error: $error');
          AppLogger.app.e('❌ Image path: $resolvedPath');
          return _buildFallbackBackground(context);
        },
      );
    } else {
      // Local asset
      return Image.asset(
        imagePath,
        fit: BoxFit.cover,
        gaplessPlayback: true, // Prevent flickering
        errorBuilder: (context, error, stackTrace) {
          AppLogger.app.e('❌ Background image asset error: $error');
          AppLogger.app.e('❌ Image path: $imagePath');
          return _buildFallbackBackground(context);
        },
      );
    }
  }

  Widget _buildFallbackBackground(BuildContext context) {
    final theme = Theme.of(context);
    return IgnorePointer(
      child: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              theme.colorScheme.surface,
              theme.colorScheme.surfaceVariant,
            ],
          ),
        ),
      ),
    );
  }
}

/// 🎨 Overlay-Typen für Hintergrundbilder
enum BackgroundOverlayType {
  /// Kein Overlay
  none,
  
  /// Solider Overlay
  solid,
  
  /// Gradient Overlay (Standard)
  gradient,
  
  /// Theme-basierter Overlay
  theme,
}
