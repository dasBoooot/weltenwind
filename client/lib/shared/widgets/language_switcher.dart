import 'package:flutter/material.dart';
import '../../core/providers/locale_provider.dart';
import '../../core/providers/theme_context_provider.dart';
import '../../l10n/app_localizations.dart';

import '../components/index.dart';
import '../utils/dynamic_components.dart';

/// Language switcher widget that displays as an expandable icon.
/// Shows a language globe icon when collapsed, expands to show language options when tapped.
class LanguageSwitcher extends StatefulWidget {
  const LanguageSwitcher({super.key});

  @override
  State<LanguageSwitcher> createState() => _LanguageSwitcherState();
}

class _LanguageSwitcherState extends State<LanguageSwitcher> {
  late final LocaleProvider _localeProvider;
  bool _isExpanded = false;
  
  @override
  void initState() {
    super.initState();
    _localeProvider = LocaleProvider();
    _localeProvider.addListener(_onLocaleChanged);
  }
  
  @override
  void dispose() {
    _localeProvider.removeListener(_onLocaleChanged);
    super.dispose();
  }
  
  void _onLocaleChanged() {
    if (mounted) {
      setState(() {});
    }
  }
  
  void _toggleExpanded() {
    setState(() {
      _isExpanded = !_isExpanded;
    });
  }
  
  Future<void> _switchLanguage(String languageCode) async {
    final newLocale = Locale(languageCode);
    await _localeProvider.setLocale(newLocale);
  }
  
  /// Liste der verfügbaren Sprachen - hier können neue Sprachen hinzugefügt werden
  List<Map<String, String>> get _availableLanguages => [
    {'code': 'de', 'name': 'Deutsch'},
    {'code': 'en', 'name': 'English'},
    // Hier können weitere Sprachen hinzugefügt werden:
    // {'code': 'fr', 'name': 'Français'},
    // {'code': 'es', 'name': 'Español'},
  ];
  
  @override
  Widget build(BuildContext context) {
    // 🎯 MIXED-CONTEXT THEME: Universal Language Switcher
    return ThemeContextConsumer(
      componentName: 'LanguageSwitcher',
      enableMixedContext: true,
      contextOverrides: const {
        'uiContext': 'language-switcher',
        'context': 'inherit', // Erbt Theme vom Parent (Pre-Game oder World-themed)
        'inherit': 'parent-theme',
        'universalComponent': 'true', // Universelles UI-Element
      },
      fallbackTheme: 'pre_game_bundle',
      builder: (context, theme, extensions) {
        return _buildLanguageSwitcher(context, theme);
      },
    );
  }

  /// 🎨 Language Switcher Build mit Theme
  Widget _buildLanguageSwitcher(BuildContext context, ThemeData theme) {
    // Dynamische Größenberechnung basierend auf verfügbaren Sprachen
    final dynamicHeight = _isExpanded 
        ? 90.0 + (_availableLanguages.length * 50.0) // Header + Buttons
        : 48.0;
    
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      constraints: BoxConstraints(
        maxWidth: _isExpanded ? 200 : 48,  // Sichere feste Maximalbreite
        maxHeight: dynamicHeight,
      ),
      child: _isExpanded ? _buildExpandedView(context, theme) : _buildCompactView(theme),
    );
  }
  
  Widget _buildCompactView(ThemeData theme) {
    return GestureDetector(
      onTap: _toggleExpanded,
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: theme.colorScheme.surface.withValues(alpha: 0.9),
          border: Border.all(
            color: theme.colorScheme.primary.withValues(alpha: 0.3),
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: theme.colorScheme.shadow.withValues(alpha: 0.2),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Icon(
          Icons.language,
          color: theme.colorScheme.primary,
          size: 28, // Exakt gleiche Größe wie NavigationWidget
        ),
      ),
    );
  }
  
  Widget _buildExpandedView(BuildContext context, ThemeData theme) {
    final currentLanguage = _localeProvider.currentLocale.languageCode;
    
    return DynamicComponents.frame(
      title: AppLocalizations.of(context).commonLanguage,
      padding: const EdgeInsets.all(16.0), // sm
      child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with close button
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.language,
                      color: theme.colorScheme.primary,
                      size: 16,
                    ),
                    const SizedBox(width: 8.0), // xs
                    Text(
                      AppLocalizations.of(context).commonLanguage,
                      style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface,
                      ),
                    ),
                  ],
                ),
                GestureDetector(
                  onTap: _toggleExpanded,
                  child: Icon(
                    Icons.close,
                    size: 16,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16.0), // sm
            // Language buttons - dynamisch generiert
            Column(
              mainAxisSize: MainAxisSize.min,
              children: _availableLanguages.map((language) {
                final isSelected = currentLanguage == language['code'];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8.0), // xs
                  child: SizedBox(
                    width: double.infinity, // Feste Breite für Row-Kompatibilität
                    child: isSelected
                        ? DynamicComponents.primaryButton(
                            text: language['name']!,
                            onPressed: () => _switchLanguage(language['code']!),
                            size: AppButtonSize.small,
                            isLoading: false,
                            icon: Icons.check,
                          )
                        : DynamicComponents.secondaryButton(
                            text: language['name']!,
                            onPressed: () => _switchLanguage(language['code']!),
                            size: AppButtonSize.small,
                          ),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
    );
  }
}