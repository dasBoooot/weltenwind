import 'package:flutter/material.dart';
import '../../core/providers/locale_provider.dart';
import '../../l10n/app_localizations.dart';
import '../../theme/app_theme.dart';

class LanguageSwitcher extends StatefulWidget {
  final bool showLabel;
  final bool isCompact;
  
  const LanguageSwitcher({
    super.key,
    this.showLabel = true,
    this.isCompact = false,
  });

  @override
  State<LanguageSwitcher> createState() => _LanguageSwitcherState();
}

class _LanguageSwitcherState extends State<LanguageSwitcher> {
  late final LocaleProvider _localeProvider;
  
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
  
  Future<void> _switchLanguage(String languageCode) async {
    final newLocale = Locale(languageCode);
    await _localeProvider.setLocale(newLocale);
  }
  
  @override
  Widget build(BuildContext context) {
    final currentLanguage = _localeProvider.currentLocale.languageCode;
    
    if (widget.isCompact) {
      return _buildCompactSwitcher(currentLanguage);
    } else {
      return _buildFullSwitcher(context, currentLanguage);
    }
  }
  
  Widget _buildCompactSwitcher(String currentLanguage) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppTheme.primaryColor.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildLanguageButton('DE', 'de', currentLanguage, isFirst: true),
          _buildLanguageButton('EN', 'en', currentLanguage, isLast: true),
        ],
      ),
    );
  }
  
  Widget _buildFullSwitcher(BuildContext context, String currentLanguage) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.primaryColor.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (widget.showLabel) ...[
            Row(
              children: [
                const Icon(
                  Icons.language,
                  color: AppTheme.primaryColor,
                  size: 16,
                ),
                const SizedBox(width: 6),
                Text(
                  AppLocalizations.of(context).commonLanguage,
                  style: TextStyle(
                    color: Colors.grey[300],
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
          ],
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildLanguageButton('Deutsch', 'de', currentLanguage, isFirst: true),
              const SizedBox(width: 8),
              _buildLanguageButton('English', 'en', currentLanguage, isLast: true),
            ],
          ),
        ],
      ),
    );
  }
  
  Widget _buildLanguageButton(
    String label, 
    String languageCode, 
    String currentLanguage, {
    bool isFirst = false,
    bool isLast = false,
  }) {
    final isSelected = currentLanguage == languageCode;
    
    return GestureDetector(
      onTap: () => _switchLanguage(languageCode),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(
          horizontal: widget.isCompact ? 12 : 16,
          vertical: widget.isCompact ? 6 : 8,
        ),
        decoration: BoxDecoration(
          color: isSelected 
            ? AppTheme.primaryColor 
            : Colors.transparent,
          borderRadius: BorderRadius.circular(widget.isCompact ? 16 : 8),
          border: isSelected 
            ? null 
            : Border.all(
                color: Colors.grey[600]!.withValues(alpha: 0.5),
                width: 1,
              ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.grey[300],
            fontSize: widget.isCompact ? 12 : 14,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
          ),
        ),
      ),
    );
  }
}