import 'package:flutter/material.dart';

class BackgroundWidget extends StatelessWidget {
  final Widget child;
  final bool showOverlay;

  const BackgroundWidget({
    super.key,
    required this.child,
    this.showOverlay = false, // Changed default to false
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return Container(
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/images/weltenwind-background-1.png'),
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
                    colorScheme.surface.withValues(alpha: 0.8),
                    colorScheme.surface.withValues(alpha: 0.9),
                  ],
                ),
              ),
              child: child,
            )
          : child,
    );
  }
} 