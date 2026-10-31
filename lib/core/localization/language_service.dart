import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'app_strings.dart';

class LanguageService extends ChangeNotifier {
  LanguageService._();
  static final LanguageService instance = LanguageService._();

  static const String _prefKey = 'app_language_selected';
  String _currentLanguage = 'fr'; // 'fr' (default on fresh install) or 'en'

  String get currentLanguage => _currentLanguage;
  bool get isFrench => _currentLanguage == 'fr';
  bool get isEnglish => _currentLanguage == 'en';

  /// Initialize language from local preferences.
  /// On fresh install: Defaults to French ('fr').
  /// If the user previously selected English ('en') or French ('fr'), restores their choice.
  Future<void> init() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final saved = prefs.getString(_prefKey);
      if (saved != null && (saved == 'fr' || saved == 'en')) {
        _currentLanguage = saved;
      } else {
        _currentLanguage = 'fr'; // French by default on new install
        await prefs.setString(_prefKey, 'fr');
      }
      notifyListeners();
    } catch (_) {
      _currentLanguage = 'fr';
    }
  }

  /// Change active app language and persist to disk
  Future<void> setLanguage(String langCode) async {
    if (langCode != 'fr' && langCode != 'en') return;
    if (_currentLanguage == langCode) return;

    _currentLanguage = langCode;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_prefKey, langCode);
    } catch (_) {}
  }

  /// Toggle language between French and English
  Future<void> toggleLanguage() async {
    final next = isFrench ? 'en' : 'fr';
    await setLanguage(next);
  }

  /// Translate string by key
  String tr(String key) {
    return AppStrings.get(key, _currentLanguage);
  }
}

/// Convenience global helper: tr('key')
String tr(String key) => LanguageService.instance.tr(key);
