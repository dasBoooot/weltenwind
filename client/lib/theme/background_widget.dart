import 'package:flutter/material.dart';

class BackgroundWidget extends StatelessWidget {
  final Widget child;
  final bool showOverlay;
  final String? worldTheme;  // NEW: For world-specific backgrounds

  const BackgroundWidget({
    super.key,
    required this.child,
    this.showOverlay = false, // Changed default to false
    this.worldTheme,  // NEW: Optional world theme for background selection
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return Container(
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage(_getBackgroundImage()),
          fit: BoxFit.cover,
        ),
      ),
      child: showOverlay
          ? Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    colorScheme.surface.withValues(alpha: 0.2),  // 🎨 Light overlay for readability
                    colorScheme.surface.withValues(alpha: 0.4),  // 🎨 Light overlay for readability
                  ],
                ),
              ),
              child: child,
            )
          : child,
    );
  }

  /// Get the appropriate background image based on world theme
  String _getBackgroundImage() {
    if (worldTheme != null && worldTheme!.isNotEmpty) {
      // Use world-specific background dynamically (no hardcoded mappings!)
      return 'assets/images/worlds/${worldTheme!.toLowerCase()}.png';
    }
    
    // Default background for non-world pages
    return 'assets/images/weltenwind-background-1.png';
  }
} 