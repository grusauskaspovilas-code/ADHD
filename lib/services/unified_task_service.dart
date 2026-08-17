import '../models/task.dart';
import 'calendar_service.dart';
import 'task_service.dart';
import 'calendar_entry_type_service.dart';

class UnifiedTaskService {
  static Future<List<Task>> loadTasks() async {
    final appTasks = await TaskService.loadTasks();
    final calendarEvents =
        await CalendarService.getUpcomingEvents();

    final result = <Task>[
      ...appTasks,
    ];

    for (final event in calendarEvents) {
      final title = event.title.trim();

      if (title.isEmpty) {
        continue;
      }
	  final calendarId =
    CalendarEntryTypeService.createCalendarId(
  title: title,
  startDate: event.startDate,
);

final entryType =
    await CalendarEntryTypeService.getType(
  calendarId,
);

      final duplicate = result.any(
        (task) => _isDuplicate(
          task,
          title,
          event.startDate,
        ),
      );

      if (duplicate) {
        continue;
      }

      final duration = event.endDate
          .difference(event.startDate)
          .inMinutes;
result.add(
  Task(
    id: calendarId,
    title: title,
    description: event.description,
    createdAt: DateTime.now(),
    dueDate: event.startDate,
    estimatedMinutes:
        duration > 0 ? duration : null,
    priority: TaskPriority.normal,
    energyLevel: EnergyLevel.medium,
    source: TaskSource.calendar,
    type: entryType,
  ),
);
    }

    return result;
  }

  static bool _isDuplicate(
    Task task,
    String calendarTitle,
    DateTime calendarDate,
  ) {
    final taskTitle =
        _normalizeTitle(task.title);

    final eventTitle =
        _normalizeTitle(calendarTitle);

    // Visiškai vienodas pavadinimas.
    if (taskTitle == eventTitle) {
      return _datesMatch(
        task,
        calendarDate,
      );
    }

    // Tikriname panašius pavadinimus.
    if (_titlesAreSimilar(
      taskTitle,
      eventTitle,
    )) {
      return _datesMatch(
        task,
        calendarDate,
      );
    }

    return false;
  }

  static bool _datesMatch(
    Task task,
    DateTime calendarDate,
  ) {
    // Jei programėlės užduotis neturi datos,
    // panašus pavadinimas laikomas tuo pačiu darbu.
    if (task.dueDate == null) {
      return true;
    }

    return _sameDay(
      task.dueDate!,
      calendarDate,
    );
  }

  static bool _titlesAreSimilar(
    String a,
    String b,
  ) {
    final wordsA = a
        .split(' ')
        .where((word) => word.length >= 3)
        .toList();

    final wordsB = b
        .split(' ')
        .where((word) => word.length >= 3)
        .toList();

    if (wordsA.isEmpty || wordsB.isEmpty) {
      return false;
    }

    var matches = 0;

    for (final wordA in wordsA) {
      for (final wordB in wordsB) {
        if (_wordsAreSimilar(
          wordA,
          wordB,
        )) {
          matches++;
          break;
        }
      }
    }

    final requiredMatches =
        wordsA.length < wordsB.length
            ? wordsA.length
            : wordsB.length;

    // Jei sutampa visi trumpesnio pavadinimo
    // reikšmingi žodžiai, laikome panašiais.
    return matches >= requiredMatches;
  }

  static bool _wordsAreSimilar(
    String a,
    String b,
  ) {
    if (a == b) {
      return true;
    }

    // Pvz.:
    // programa / programos
    // kurimas / sukurimas
    if (a.length >= 5 &&
        b.length >= 5) {
      if (a.contains(b) ||
          b.contains(a)) {
        return true;
      }

      final prefixLength =
          a.length < b.length
              ? a.length - 2
              : b.length - 2;

      if (prefixLength >= 4) {
        return a.substring(
              0,
              prefixLength,
            ) ==
            b.substring(
              0,
              prefixLength,
            );
      }
    }

    return false;
  }

  static String _normalizeTitle(
    String text,
  ) {
    return text
        .trim()
        .toLowerCase()
        .replaceAll('ą', 'a')
        .replaceAll('č', 'c')
        .replaceAll('ę', 'e')
        .replaceAll('ė', 'e')
        .replaceAll('į', 'i')
        .replaceAll('š', 's')
        .replaceAll('ų', 'u')
        .replaceAll('ū', 'u')
        .replaceAll('ž', 'z')
        .replaceAll(
          RegExp(r'[^a-z0-9 ]'),
          '',
        )
        .replaceAll(
          RegExp(r'\s+'),
          ' ',
        );
  }

  static bool _sameDay(
    DateTime a,
    DateTime b,
  ) {
    return a.year == b.year &&
        a.month == b.month &&
        a.day == b.day;
  }

  static bool isCalendarTask(
    Task task,
  ) {
    return task.source ==
        TaskSource.calendar;
  }
}