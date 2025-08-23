import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocaleProvider extends ChangeNotifier {
  static final LocaleProvider _instance = LocaleProvider._internal();
  factory LocaleProvider() => _instance;
  LocaleProvider._internal() {
    _loadLocale();
  }

  Locale _currentLocale = const Locale('de');
  static const String _localeKey = 'selected_locale';

  Locale get currentLocale => _currentLocale;

  // Gespeicherte Sprache laden
  Future<void> _loadLocale() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final languageCode = prefs.getString(_localeKey) ?? 'de';
      _currentLocale = Locale(languageCode);
      notifyListeners();
    } catch (e) {
      // Falls SharedPreferences fehlschlägt, bleibe bei Standard-Sprache
      _currentLocale = const Locale('de');
    }
  }

  // Sprache setzen und speichern
  Future<void> setLocale(Locale locale) async {
    if (_currentLocale != locale) {
      _currentLocale = locale;
      notifyListeners();
      
      try {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(_localeKey, locale.languageCode);
      } catch (e) {
        // Logging könnte hier hinzugefügt werden
        // Falls Speichern fehlschlägt, funktioniert die App trotzdem
      }
    }
  }

  // Sprache wechseln zwischen Deutsch und Englisch
  Future<void> switchLanguage() async {
    Locale newLocale = _currentLocale.languageCode == 'de' 
        ? const Locale('en') 
        : const Locale('de');
    await setLocale(newLocale);
  }
  
  // Für einfache Verwendung in Widgets
  static Locale of(BuildContext context) {
    return _instance.currentLocale;
  }
  
  // Initialisierung für App-Start
  static Future<void> initialize() async {
    await _instance._loadLocale();
  }
}