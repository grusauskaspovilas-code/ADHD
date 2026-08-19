import 'app_language.dart';

class GuardianStrings {
  final AppLanguage language;

  const GuardianStrings(this.language);

  String get noMonitoredTasks {
    switch (language) {
      case AppLanguage.lithuanian:
        return 'Guardian neturi stebimų būtinų užduočių.';
      case AppLanguage.german:
        return 'Guardian hat keine überwachten Pflichtaufgaben.';
      default:
        return 'Guardian has no required tasks to monitor.';
    }
  }

  String get deadlineAlreadyPassed {
    switch (language) {
      case AppLanguage.lithuanian:
        return 'Terminas jau praėjo.';
      case AppLanguage.german:
        return 'Die Frist ist bereits abgelaufen.';
      default:
        return 'The deadline has already passed.';
    }
  }

  String get noSufficientSlot {
    switch (language) {
      case AppLanguage.lithuanian:
        return '⚠️ Iki termino neberasta pakankamai ilgo laisvo laiko.';
      case AppLanguage.german:
        return '⚠️ Vor der Frist wurde kein ausreichend großes Zeitfenster gefunden.';
      default:
        return '⚠️ No sufficiently long free slot was found before the deadline.';
    }
  }

  String suggestedTime(String time) {
    switch (language) {
      case AppLanguage.lithuanian:
        return 'Siūlomas laikas: $time';
      case AppLanguage.german:
        return 'Vorgeschlagene Zeit: $time';
      default:
        return 'Suggested time: $time';
    }
  }

  String deadlineLabel(String deadline) {
    switch (language) {
      case AppLanguage.lithuanian:
        return 'Terminas: $deadline';
      case AppLanguage.german:
        return 'Frist: $deadline';
      default:
        return 'Deadline: $deadline';
    }
  }

  String durationLabel(int minutes) {
    switch (language) {
      case AppLanguage.lithuanian:
        return 'Trukmė: $minutes min.';
      case AppLanguage.german:
        return 'Dauer: $minutes Min.';
      default:
        return 'Duration: $minutes min';
    }
  }

  String get ok {
    switch (language) {
      case AppLanguage.lithuanian:
        return 'GERAI';
      default:
        return 'OK';
    }
  }

  String startReminder(String title) {
    switch (language) {
      case AppLanguage.lithuanian:
        return 'Dabar yra tinkamas laikas pradėti: $title';
      case AppLanguage.german:
        return 'Jetzt ist ein guter Zeitpunkt anzufangen: $title';
      default:
        return 'Now is a good time to start: $title';
    }
  }

  String lunchReminder(String title) {
    switch (language) {
      case AppLanguage.lithuanian:
        return 'Patikrinkime prieš terminą: ar jau atlikai „$title“?';
      case AppLanguage.german:
        return 'Kurzer Frist-Check: Ist „$title“ schon erledigt?';
      default:
        return 'Deadline check: have you completed “$title” yet?';
    }
  }

  String finalReminder(String title) {
    switch (language) {
      case AppLanguage.lithuanian:
        return 'Liko 30 minučių iki termino: $title';
      case AppLanguage.german:
        return 'Noch 30 Minuten bis zur Frist: $title';
      default:
        return '30 minutes remain until the deadline: $title';
    }
  }

  String overdueWarning(String title) {
    switch (language) {
      case AppLanguage.lithuanian:
        return 'Terminas praleistas: $title';
      case AppLanguage.german:
        return 'Frist verpasst: $title';
      default:
        return 'Deadline missed: $title';
    }
  }

  String noTimeWarning(String title) {
    switch (language) {
      case AppLanguage.lithuanian:
        return 'Iki termino neberasta pakankamai laiko: $title';
      case AppLanguage.german:
        return 'Nicht mehr genug freie Zeit vor der Frist: $title';
      default:
        return 'Not enough free time remains before the deadline: $title';
    }
  }
}
