library;

import 'package:flutter/material.dart';
import '../../theme/extensions.dart';

/// A themed panel with gradient border, subtle glow and header area.
class ThemedPanel extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget child;
  final double maxWidth;

  const ThemedPanel({
    super.key,
    required this.title,
    this.subtitle,
    required this.child,
    this.maxWidth = 560,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final tt = theme.textTheme;
    final radius = theme.extension<AppRadiusTheme>();
    final spacing = theme.extension<AppSpacingTheme>();

    final panelRadius = radius?.radiusLarge ?? BorderRadius.circular(16);
    final pad = EdgeInsets.all(spacing?.lg ?? 24);

    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: [cs.primary.withValues(alpha: 0.45), cs.tertiary.withValues(alpha: 0.25)]),
            borderRadius: panelRadius,
          ),
          child: Padding(
            padding: const EdgeInsets.all(1.5),
            child: Container(
              decoration: BoxDecoration(
                color: cs.surface.withValues(alpha: 0.92),
                borderRadius: panelRadius,
                boxShadow: [
                  BoxShadow(color: cs.primary.withValues(alpha: 0.18), blurRadius: 24, spreadRadius: 2, offset: const Offset(0, 8)),
                ],
              ),
              child: Padding(
                padding: pad,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Top ornament bar (subtle)
                    Container(
                      height: 6,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(colors: [cs.primary.withValues(alpha: 0.6), cs.tertiary.withValues(alpha: 0.4)]),
                        borderRadius: radius?.radiusSmall ?? BorderRadius.circular(6),
                      ),
                    ),
                    SizedBox(height: spacing?.md ?? 16),
                    // Header
                    Text(
                      title,
                      style: tt.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.2,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(height: 6),
                      Text(
                        subtitle!,
                        style: tt.bodyMedium?.copyWith(color: cs.onSurface.withValues(alpha: 0.75)),
                        textAlign: TextAlign.center,
                      ),
                    ],
                    const SizedBox(height: 16),
                    Divider(color: cs.primary.withValues(alpha: 0.25), height: 1),
                    const SizedBox(height: 16),
                    // Content
                    child,
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}


