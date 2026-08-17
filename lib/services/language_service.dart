import 'dart:ui';

import 'package:shared_preferences/shared_preferences.dart';

import '../l10n/app_language.dart';

class LanguageService {
  static const String _languageKey = 'selected_language';

  static AppLanguage getSystemLanguage() {
    final languageCode =
        PlatformDispatcher.instance.locale.languageCode.toLowerCase();

    switch (languageCode) {
      case 'de':
        return AppLanguage.german;

      case 'lt':
        return AppLanguage.lithuanian;

      default:
        return AppLanguage.english;
    }
  }

  static AppLanguage resolve(AppLanguage selectedLanguage) {
    if (selectedLanguage == AppLanguage.automatic) {
      return getSystemLanguage();
    }

    return selectedLanguage;
  }

  static Future<void> saveLanguage(AppLanguage language) async {
    final preferences = await SharedPreferences.getInstance();

    await preferences.setString(
      _languageKey,
      language.name,
    );
  }

  static Future<AppLanguage> loadLanguage() async {
    final preferences = await SharedPreferences.getInstance();

    final savedLanguage =
        preferences.getString(_languageKey);

    if (savedLanguage == null) {
      return AppLanguage.automatic;
    }

    for (final language in AppLanguage.values) {
      if (language.name == savedLanguage) {
        return language;
      }
    }

    return AppLanguage.automatic;
  }
}