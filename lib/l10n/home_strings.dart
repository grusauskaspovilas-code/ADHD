import 'app_language.dart';

class HomeStrings {
  final AppLanguage language;

  const HomeStrings(this.language);

  String get busyTitle {
    switch (language) {
      case AppLanguage.lithuanian:
        return 'Dabar esi užimtas';
      case AppLanguage.german:
        return 'Du bist gerade beschäftigt';
      default:
        return 'You are busy right now';
    }
  }

  String busyUntil(String time) {
    switch (language) {
      case AppLanguage.lithuanian:
        return 'Iki $time';
      case AppLanguage.german:
        return 'Bis $time';
      default:
        return 'Until $time';
    }
  }

  String get suggestAnyway {
    switch (language) {
      case AppLanguage.lithuanian:
        return 'VIS TIEK PASIŪLYK UŽDUOTĮ';
      case AppLanguage.german:
        return 'TROTZDEM AUFGABE VORSCHLAGEN';
      default:
        return 'SUGGEST A TASK ANYWAY';
    }
  }

  String get busyOk {
    switch (language) {
      case AppLanguage.lithuanian:
        return 'Gerai';
      case AppLanguage.german:
        return 'Okay';
      default:
        return 'OK';
    }
  }

  String get myRoutine {
    switch (language) {
      case AppLanguage.lithuanian:
        return 'Mano rutina';
      case AppLanguage.german:
        return 'Meine Routine';
      default:
        return 'My routine';
    }
  }

  String get mySchedule {
    switch (language) {
      case AppLanguage.lithuanian:
        return 'Mano dienotvarkė';
      case AppLanguage.german:
        return 'Mein Tagesplan';
      default:
        return 'My schedule';
    }
  }

  String get importantPlaces {
    switch (language) {
      case AppLanguage.lithuanian:
        return 'Svarbios vietos';
      case AppLanguage.german:
        return 'Wichtige Orte';
      default:
        return 'Important places';
    }
  }

  String locationContext(String placeName) {
    switch (language) {
      case AppLanguage.lithuanian:
        return 'Vietos kontekstas: $placeName';
      case AppLanguage.german:
        return 'Standortkontext: $placeName';
      default:
        return 'Location context: $placeName';
    }
  }

  String get guardianTest {
    switch (language) {
      case AppLanguage.lithuanian:
        return 'Guardian testas';
      case AppLanguage.german:
        return 'Guardian-Test';
      default:
        return 'Guardian test';
    }
  }

  String get notificationTest {
    switch (language) {
      case AppLanguage.lithuanian:
        return 'Pranešimo testas';
      case AppLanguage.german:
        return 'Benachrichtigung testen';
      default:
        return 'Test notification';
    }
  }

  String get scheduledNotificationTest {
    switch (language) {
      case AppLanguage.lithuanian:
        return 'Pranešimas po 2 min.';
      case AppLanguage.german:
        return 'Benachrichtigung in 2 Min.';
      default:
        return 'Notification in 2 min';
    }
  }

  String get notificationScheduled {
    switch (language) {
      case AppLanguage.lithuanian:
        return 'Pranešimas suplanuotas po 2 min.';
      case AppLanguage.german:
        return 'Benachrichtigung für in 2 Minuten geplant.';
      default:
        return 'Notification scheduled for 2 minutes from now.';
    }
  }

  String get calendarTime {
    switch (language) {
      case AppLanguage.lithuanian:
        return 'PAGAL KALENDORIŲ';
      case AppLanguage.german:
        return 'NACH KALENDER';
      default:
        return 'USE CALENDAR';
    }
  }

  String get availableTimeTitle {
    switch (language) {
      case AppLanguage.lithuanian:
        return 'Kiek laiko turi dabar?';
      case AppLanguage.german:
        return 'Wie viel Zeit hast du jetzt?';
      default:
        return 'How much time do you have?';
    }
  }

  String get availableTimeSubtitle {
    switch (language) {
      case AppLanguage.lithuanian:
        return 'Parinksiu užduotį, kuri geriausiai tinka dabar.';
      case AppLanguage.german:
        return 'Ich wähle eine Aufgabe, die jetzt gut passt.';
      default:
        return 'I’ll pick a task that fits right now.';
    }
  }

  String get oneHour {
    switch (language) {
      case AppLanguage.lithuanian:
        return '1+ val.';
      case AppLanguage.german:
        return '1+ Std.';
      default:
        return '1+ hour';
    }
  }

  String get anyTime {
    switch (language) {
      case AppLanguage.lithuanian:
        return 'Nesvarbu';
      case AppLanguage.german:
        return 'Egal';
      default:
        return 'Any amount of time';
    }
  }

  String nothingFitsTitle(int minutes) {
    switch (language) {
      case AppLanguage.lithuanian:
        return 'Nė viena užduotis netelpa į $minutes min.';
      case AppLanguage.german:
        return 'Keine Aufgabe passt in $minutes Min.';
      default:
        return 'No task fits into $minutes min.';
    }
  }

  String get nothingFitsSubtitle {
    switch (language) {
      case AppLanguage.lithuanian:
        return 'Bet nereikia atlikti visos užduoties. '
            'Galime pradėti nuo mažo žingsnio.';
      case AppLanguage.german:
        return 'Du musst nicht die ganze Aufgabe erledigen. '
            'Wir können mit einem kleinen Schritt anfangen.';
      default:
        return "You don't need to finish the whole task. "
            'We can start with one small step.';
    }
  }

  String get helpMeStart {
    switch (language) {
      case AppLanguage.lithuanian:
        return 'PADĖK MAN PRADĖTI';
      case AppLanguage.german:
        return 'HILF MIR ANZUFANGEN';
      default:
        return 'HELP ME START';
    }
  }

  String get notNow {
    switch (language) {
      case AppLanguage.lithuanian:
        return 'Ne dabar';
      case AppLanguage.german:
        return 'Nicht jetzt';
      default:
        return 'Not now';
    }
  }

  String get noTasks {
    switch (language) {
      case AppLanguage.lithuanian:
        return 'Kol kas nėra užduočių. Pridėk užduotį arba '
            'kalendoriuje pažymėk įrašą kaip „Užduotis“.';
      case AppLanguage.german:
        return 'Noch keine Aufgaben vorhanden.';
      default:
        return 'There are no tasks yet.';
    }
  }

  String get noUpcomingEvent {
    switch (language) {
      case AppLanguage.lithuanian:
        return 'Artimiausio kalendoriaus įvykio nerasta.';
      case AppLanguage.german:
        return 'Kein kommender Kalendereintrag gefunden.';
      default:
        return 'No upcoming calendar event found.';
    }
  }

  String get noFreeTime {
    switch (language) {
      case AppLanguage.lithuanian:
        return 'Dabar nėra laisvo laiko iki kito įvykio.';
      case AppLanguage.german:
        return 'Bis zum nächsten Termin ist keine freie Zeit.';
      default:
        return 'There is no free time before the next event.';
    }
  }

  String get noCalendarEventTitle {
    switch (language) {
      case AppLanguage.lithuanian:
        return 'Artimiausių įvykių nėra';
      case AppLanguage.german:
        return 'Keine kommenden Termine';
      default:
        return 'No upcoming events';
    }
  }

  String get noCalendarEventSubtitle {
    switch (language) {
      case AppLanguage.lithuanian:
        return 'Galiu parinkti užduotį neatsižvelgdamas į kalendorių.';
      case AppLanguage.german:
        return 'Ich kann eine Aufgabe auswählen, ohne den Kalender zu berücksichtigen.';
      default:
        return 'I can choose a task without using your calendar.';
    }
  }

  String get selectTaskAnyway {
    switch (language) {
      case AppLanguage.lithuanian:
        return 'PARINKTI UŽDUOTĮ';
      case AppLanguage.german:
        return 'AUFGABE AUSWÄHLEN';
      default:
        return 'CHOOSE A TASK';
    }
  }

  String get cancel {
    switch (language) {
      case AppLanguage.lithuanian:
        return 'Atšaukti';
      case AppLanguage.german:
        return 'Abbrechen';
      default:
        return 'Cancel';
    }
  }

  String get today {
    switch (language) {
      case AppLanguage.lithuanian:
        return 'Šiandien';
      case AppLanguage.german:
        return 'Heute';
      default:
        return 'Today';
    }
  }

  String get tomorrow {
    switch (language) {
      case AppLanguage.lithuanian:
        return 'Rytoj';
      case AppLanguage.german:
        return 'Morgen';
      default:
        return 'Tomorrow';
    }
  }

  String get overdue {
    switch (language) {
      case AppLanguage.lithuanian:
        return 'Terminas praėjo';
      case AppLanguage.german:
        return 'Überfällig';
      default:
        return 'Overdue';
    }
  }

  String get noDeadline {
    switch (language) {
      case AppLanguage.lithuanian:
        return 'Be termino';
      case AppLanguage.german:
        return 'Kein Termin';
      default:
        return 'No deadline';
    }
  }

  String get aiLoadingTitle {
    switch (language) {
      case AppLanguage.lithuanian:
        return 'AI renka užduotį...';
      case AppLanguage.german:
        return 'KI wählt eine Aufgabe aus...';
      default:
        return 'AI is choosing a task...';
    }
  }

  String get aiLoadingSubtitle {
    switch (language) {
      case AppLanguage.lithuanian:
        return 'Atsižvelgiu į tavo laiką, prioritetus ir užduotis.';
      case AppLanguage.german:
        return 'Ich berücksichtige deine Zeit, Prioritäten und Aufgaben.';
      default:
        return 'Considering your time, priorities, and tasks.';
    }
  }

  String get unknownDuration {
    switch (language) {
      case AppLanguage.lithuanian:
        return 'Trukmė nežinoma';
      case AppLanguage.german:
        return 'Dauer unbekannt';
      default:
        return 'Duration unknown';
    }
  }

  String formatDueDate(DateTime? dueDate) {
    if (dueDate == null) {
      return noDeadline;
    }

    final now = DateTime.now();

    final todayDate = DateTime(now.year, now.month, now.day);

    final taskDate = DateTime(dueDate.year, dueDate.month, dueDate.day);

    final difference = taskDate.difference(todayDate).inDays;

    if (difference < 0) {
      return overdue;
    }

    if (difference == 0) {
      return today;
    }

    if (difference == 1) {
      return tomorrow;
    }

    return '${dueDate.day.toString().padLeft(2, '0')}.'
        '${dueDate.month.toString().padLeft(2, '0')}.'
        '${dueDate.year}';
  }

  String formatDuration(int? minutes) {
    if (minutes == null) {
      return unknownDuration;
    }

    if (minutes < 60) {
      return '~$minutes min';
    }

    if (minutes == 60) {
      switch (language) {
        case AppLanguage.lithuanian:
          return '~1 val.';
        case AppLanguage.german:
          return '~1 Std.';
        default:
          return '~1 hour';
      }
    }

    return '~$minutes min';
  }
}
