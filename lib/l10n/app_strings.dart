import 'app_language.dart';

class AppStrings {
  final AppLanguage language;

  const AppStrings(this.language);

  // HOME

  String get homeTitle {
    switch (language) {
      case AppLanguage.german:
        return 'Was soll ich jetzt tun?';
      case AppLanguage.lithuanian:
        return 'Ką man daryti dabar?';
      default:
        return 'What should I do now?';
    }
  }

  String get homeSubtitle {
    switch (language) {
      case AppLanguage.german:
        return 'Du musst nicht an alles denken.\nWählen wir eine Sache aus.';
      case AppLanguage.lithuanian:
        return 'Tau nereikia galvoti apie viską.\nIšsirinkime vieną dalyką.';
      default:
        return "You don't need to think about everything.\nLet's choose one thing.";
    }
  }

  String get whatShouldIDo {
    switch (language) {
      case AppLanguage.german:
        return 'WAS SOLL ICH TUN?';
      case AppLanguage.lithuanian:
        return 'KĄ MAN DARYTI?';
      default:
        return 'WHAT SHOULD I DO?';
    }
  }

  String get imStuck {
    switch (language) {
      case AppLanguage.german:
        return 'Ich komme nicht weiter';
      case AppLanguage.lithuanian:
        return 'Aš užstrigau';
      default:
        return "I'm stuck";
    }
  }

  String get addTask {
    switch (language) {
      case AppLanguage.german:
        return 'Aufgabe hinzufügen';
      case AppLanguage.lithuanian:
        return 'Pridėti užduotį';
      default:
        return 'Add task';
    }
  }

  String get languageLabel {
    switch (language) {
      case AppLanguage.german:
        return 'Sprache';
      case AppLanguage.lithuanian:
        return 'Kalba';
      default:
        return 'Language';
    }
  }

  String get priority {
    switch (language) {
      case AppLanguage.german:
        return 'Priorität';
      case AppLanguage.lithuanian:
        return 'Prioritetas';
      default:
        return 'Priority';
    }
  }

  // ADD TASK

  String get whatDoYouNeedToDo {
    switch (language) {
      case AppLanguage.german:
        return 'Was musst du erledigen?';
      case AppLanguage.lithuanian:
        return 'Ką turi padaryti?';
      default:
        return 'What do you need to do?';
    }
  }

  String get task {
    switch (language) {
      case AppLanguage.german:
        return 'Aufgabe';
      case AppLanguage.lithuanian:
        return 'Užduotis';
      default:
        return 'Task';
    }
  }

  String get taskExample {
    switch (language) {
      case AppLanguage.german:
        return 'z. B. Präsentation vorbereiten';
      case AppLanguage.lithuanian:
        return 'pvz. Paruošti prezentaciją';
      default:
        return 'e.g. Prepare presentation';
    }
  }

  String get notes {
    switch (language) {
      case AppLanguage.german:
        return 'Notizen';
      case AppLanguage.lithuanian:
        return 'Pastabos';
      default:
        return 'Notes';
    }
  }

  String get optional {
    switch (language) {
      case AppLanguage.german:
        return 'Optional';
      case AppLanguage.lithuanian:
        return 'Nebūtina';
      default:
        return 'Optional';
    }
  }

  String get energyQuestion {
    switch (language) {
      case AppLanguage.german:
        return 'Wie viel Energie braucht die Aufgabe?';
      case AppLanguage.lithuanian:
        return 'Kiek energijos reikia šiai užduočiai?';
      default:
        return 'How much energy does it need?';
    }
  }

  String get saveTask {
    switch (language) {
      case AppLanguage.german:
        return 'AUFGABE SPEICHERN';
      case AppLanguage.lithuanian:
        return 'IŠSAUGOTI UŽDUOTĮ';
      default:
        return 'SAVE TASK';
    }
  }

  String get enterTask {
    switch (language) {
      case AppLanguage.german:
        return 'Bitte gib eine Aufgabe ein';
      case AppLanguage.lithuanian:
        return 'Įrašyk užduotį';
      default:
        return 'Please enter a task';
    }
  }

  // NEXT TASK

  String get doThisNow {
    switch (language) {
      case AppLanguage.german:
        return 'MACH DAS JETZT';
      case AppLanguage.lithuanian:
        return 'DARYK TAI DABAR';
      default:
        return 'DO THIS NOW';
    }
  }

  String get energy {
    switch (language) {
      case AppLanguage.german:
        return 'Energie';
      case AppLanguage.lithuanian:
        return 'Energija';
      default:
        return 'Energy';
    }
  }

  String get done {
    switch (language) {
      case AppLanguage.german:
        return 'ERLEDIGT';
      case AppLanguage.lithuanian:
        return 'PADARYTA';
      default:
        return 'DONE';
    }
  }

  String get cantStart {
    switch (language) {
      case AppLanguage.german:
        return 'ICH KANN NICHT ANFANGEN';
      case AppLanguage.lithuanian:
        return 'NEGALIU PRADĖTI';
      default:
        return "I CAN'T START";
    }
  }

  // VALUES

  String priorityName(String value) {
    switch (value) {
      case 'low':
        switch (language) {
          case AppLanguage.german:
            return 'Niedrig';
          case AppLanguage.lithuanian:
            return 'Žemas';
          default:
            return 'Low';
        }

      case 'high':
        switch (language) {
          case AppLanguage.german:
            return 'Hoch';
          case AppLanguage.lithuanian:
            return 'Aukštas';
          default:
            return 'High';
        }

      case 'urgent':
        switch (language) {
          case AppLanguage.german:
            return 'Dringend';
          case AppLanguage.lithuanian:
            return 'Skubus';
          default:
            return 'Urgent';
        }

      default:
        switch (language) {
          case AppLanguage.german:
            return 'Normal';
          case AppLanguage.lithuanian:
            return 'Normalus';
          default:
            return 'Normal';
        }
    }
  }

  String energyName(String value) {
    switch (value) {
      case 'low':
        switch (language) {
          case AppLanguage.german:
            return 'Niedrig';
          case AppLanguage.lithuanian:
            return 'Mažai';
          default:
            return 'Low';
        }

      case 'high':
        switch (language) {
          case AppLanguage.german:
            return 'Hoch';
          case AppLanguage.lithuanian:
            return 'Daug';
          default:
            return 'High';
        }

      default:
        switch (language) {
          case AppLanguage.german:
            return 'Mittel';
          case AppLanguage.lithuanian:
            return 'Vidutiniškai';
          default:
            return 'Medium';
        }
    }
  }
}