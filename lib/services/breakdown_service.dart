import '../l10n/app_language.dart';
import '../models/task.dart';

class BreakdownService {
  static List<String> createSteps(
    Task task,
    AppLanguage language,
  ) {
    switch (language) {
      case AppLanguage.lithuanian:
        return [
          'Atsidaryk tai, ko reikia užduočiai pradėti.',
          'Padaryk vieną mažiausią įmanomą veiksmą.',
          'Skirk užduočiai tik 2 minutes.',
          'Po 2 minučių nuspręsk, ar nori tęsti.',
        ];

      case AppLanguage.german:
        return [
          'Öffne, was du für die Aufgabe brauchst.',
          'Mach nur den kleinstmöglichen ersten Schritt.',
          'Arbeite nur 2 Minuten daran.',
          'Entscheide danach, ob du weitermachen möchtest.',
        ];

      default:
        return [
          'Open what you need to begin the task.',
          'Do the smallest possible first action.',
          'Work on it for just 2 minutes.',
          'Then decide whether you want to continue.',
        ];
    }
  }
}