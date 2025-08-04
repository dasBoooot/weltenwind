import 'package:flutter/material.dart';
import '../../core/providers/locale_provider.dart';

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
    // 🎯 SMART NAVIGATION THEME: Verwendet vorgeladenes Theme
    return _buildLanguageSwitcher(context, Theme.of(context));
  }

  /// 🎨 Language Switcher Build mit Theme (Navigation Bar optimiert)
  Widget _buildLanguageSwitcher(BuildContext context, ThemeData theme) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      constraints: BoxConstraints(
        maxWidth: _isExpanded ? 180 : 48,  // Compact width for navigation bar
        maxHeight: 64,                     // Fixed height for navigation bar
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
              color: theme.colorScheme.shadow.withValues(alpha: 0.1),
              blurRadius: 4,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Icon(
          Icons.language,
          color: theme.colorScheme.primary,
          size: 24, // Slightly smaller for navigation bar
        ),
      ),
    );
  }
  
  Widget _buildExpandedView(BuildContext context, ThemeData theme) {
    final currentLanguage = _localeProvider.currentLocale.languageCode;
    
    return Container(
      height: 64, // Fixed height for navigation bar
      decoration: BoxDecoration(
        color: theme.colorScheme.surface.withValues(alpha: 0.95),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: theme.colorScheme.primary.withValues(alpha: 0.3),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.shadow.withValues(alpha: 0.1),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Close button
          GestureDetector(
            onTap: _toggleExpanded,
            child: Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.1),
              ),
              child: Icon(
                Icons.close,
                size: 16,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
              ),
            ),
          ),
          const SizedBox(width: 8),
          // Language buttons in horizontal row
          ..._availableLanguages.map((language) {
            final isSelected = currentLanguage == language['code'];
            return Padding(
              padding: const EdgeInsets.only(right: 4),
              child: GestureDetector(
                onTap: () => _switchLanguage(language['code']!),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: isSelected 
                      ? theme.colorScheme.primary.withValues(alpha: 0.2)
                      : Colors.transparent,
                    borderRadius: BorderRadius.circular(12),
                    border: isSelected 
                      ? Border.all(color: theme.colorScheme.primary, width: 1)
                      : null,
                  ),
                  child: Text(
                    language['code']!.toUpperCase(),
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: isSelected 
                        ? theme.colorScheme.primary
                        : theme.colorScheme.onSurface.withValues(alpha: 0.7),
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                    ),
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}