import 'package:flutter/material.dart';
import '../../../l10n/app_localizations.dart';
import '../../../core/providers/theme_context_consumer.dart';

class WorldListLoadingState extends StatelessWidget {
  const WorldListLoadingState({super.key});

  @override
  Widget build(BuildContext context) {
    return ThemeContextConsumer(
      componentName: 'WorldListLoadingState',
      fallbackBundle: 'world-preview',
      builder: (context, theme, extensions) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(theme.colorScheme.primary),
              ),
              const SizedBox(height: 16),
              Text(
                AppLocalizations.of(context).loadingText,
                style: TextStyle(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                  fontSize: 16,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class WorldListEmptyState extends StatelessWidget {
  final VoidCallback? onRefresh;
  final bool hasActiveFilters;

  const WorldListEmptyState({
    super.key,
    this.onRefresh,
    this.hasActiveFilters = false,
  });

  @override
  Widget build(BuildContext context) {
    return ThemeContextConsumer(
      componentName: 'WorldListEmptyState',
      fallbackBundle: 'world-preview',
      builder: (context, theme, extensions) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.public_off,
                size: 64,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
              ),
              const SizedBox(height: 16),
              Text(
                hasActiveFilters
                    ? 'Keine Welten gefunden'
                    : 'Noch keine Welten verfügbar',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.8),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                hasActiveFilters
                    ? 'Versuche die Filter anzupassen oder zurückzusetzen.'
                    : 'Schaue später noch einmal vorbei oder erstelle eine neue Welt.',
                style: TextStyle(
                  fontSize: 14,
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                ),
                textAlign: TextAlign.center,
              ),
              if (onRefresh != null) ...[
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: onRefresh,
                  icon: const Icon(Icons.refresh, size: 18),
                  label: Text(AppLocalizations.of(context).buttonRetry),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.colorScheme.primary,
                    foregroundColor: theme.colorScheme.onPrimary,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}

class WorldListErrorState extends StatelessWidget {
  final String error;
  final VoidCallback? onRetry;

  const WorldListErrorState({
    super.key,
    required this.error,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return ThemeContextConsumer(
      componentName: 'WorldListErrorState',
      fallbackBundle: 'world-preview',
      builder: (context, theme, extensions) {
        return Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.error.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: theme.colorScheme.error.withValues(alpha: 0.5),
                    ),
                  ),
                  child: Icon(
                    Icons.error_outline,
                    size: 48,
                    color: theme.colorScheme.error,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  AppLocalizations.of(context).worldLoadingError,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.error,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  error,
                  style: TextStyle(
                    fontSize: 14,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                  ),
                  textAlign: TextAlign.center,
                ),
                if (onRetry != null) ...[
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: onRetry,
                    icon: const Icon(Icons.refresh, size: 18),
                    label: Text(AppLocalizations.of(context).buttonRetry),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.colorScheme.primary,
                      foregroundColor: theme.colorScheme.onPrimary,
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}

class WorldListRefreshIndicator extends StatelessWidget {
  final Widget child;
  final Future<void> Function() onRefresh;

  const WorldListRefreshIndicator({
    super.key,
    required this.child,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    return ThemeContextConsumer(
      componentName: 'WorldListRefreshIndicator',
      fallbackBundle: 'world-preview',
      builder: (context, theme, extensions) {
        return RefreshIndicator(
          onRefresh: onRefresh,
          color: theme.colorScheme.primary,
          backgroundColor: theme.colorScheme.surface,
          child: child,
        );
      },
    );
  }
} 