import 'package:device_calendar_plus/device_calendar_plus.dart';

import '../models/task.dart';
import '../models/user_routine.dart';

class GuardianResult {
  final Task task;

  // Kiek laiko liko iki termino.
  final Duration timeUntilDeadline;

  // Ar terminas jau praėjo.
  final bool isOverdue;

  // Ar užduotis jau tampa skubi.
  final bool isUrgent;

  // Ar nuo dabar iki termino dar yra
  // pakankamai laisvo laiko užduočiai.
  final bool canStillFit;

  // Artimiausias rastas laisvas langas.
  final DateTime? suggestedStart;

  const GuardianResult({
    required this.task,
    required this.timeUntilDeadline,
    required this.isOverdue,
    required this.isUrgent,
    required this.canStillFit,
    required this.suggestedStart,
  });
}

class GuardianService {
  //
  // Kol kas Guardian analizuoja tik
  // būtinas, nebaigtas užduotis,
  // kurios turi terminą.
  //
  static List<GuardianResult> analyze({
    required List<Task> tasks,
    required UserRoutine routine,
    required List<Event> calendarEvents,
    DateTime? now,
  }) {
    final currentTime = now ?? DateTime.now();

    final requiredTasks = tasks.where((task) {
      return task.isRequired && !task.isCompleted && task.dueDate != null;
    }).toList();

    final results = <GuardianResult>[];

    for (final task in requiredTasks) {
      final deadline = task.dueDate!;

      final timeUntilDeadline = deadline.difference(currentTime);

      final isOverdue = !deadline.isAfter(currentTime);

      final estimatedMinutes = task.estimatedMinutes ?? 30;

      DateTime? suggestedStart;

      if (!isOverdue) {
        suggestedStart = _findNextFreeSlot(
          now: currentTime,
          deadline: deadline,
          requiredMinutes: estimatedMinutes,
          routine: routine,
          calendarEvents: calendarEvents,
        );
      }

      final canStillFit = suggestedStart != null;

      //
      // Pirmoji Guardian versija.
      //
      // Užduotis laikoma skubia, jeigu:
      //
      // 1. terminas jau praėjo;
      // 2. liko <= 24 val.;
      // 3. arba iki termino neberandame
      //    tinkamo laisvo lango.
      //
      final isUrgent =
          isOverdue || timeUntilDeadline.inHours <= 24 || !canStillFit;

      results.add(
        GuardianResult(
          task: task,
          timeUntilDeadline: timeUntilDeadline,
          isOverdue: isOverdue,
          isUrgent: isUrgent,
          canStillFit: canStillFit,
          suggestedStart: suggestedStart,
        ),
      );
    }

    //
    // Pavojingiausios užduotys viršuje.
    //
    results.sort((a, b) {
      if (a.isOverdue != b.isOverdue) {
        return a.isOverdue ? -1 : 1;
      }

      if (a.isUrgent != b.isUrgent) {
        return a.isUrgent ? -1 : 1;
      }

      return a.task.dueDate!.compareTo(b.task.dueDate!);
    });

    return results;
  }

  static DateTime? findAvailableSlot({
    required DateTime windowStart,
    required DateTime windowEnd,
    required int requiredMinutes,
    required UserRoutine routine,
    required List<Event> calendarEvents,
  }) {
    return _findNextFreeSlot(
      now: windowStart,
      deadline: windowEnd,
      requiredMinutes: requiredMinutes,
      routine: routine,
      calendarEvents: calendarEvents,
    );
  }

  static DateTime? _findNextFreeSlot({
    required DateTime now,
    required DateTime deadline,
    required int requiredMinutes,
    required UserRoutine routine,
    required List<Event> calendarEvents,
  }) {
    if (!deadline.isAfter(now)) {
      return null;
    }

    //
    // Ieškome 15 minučių žingsniais.
    //
    var candidate = _roundUpToQuarterHour(now);

    while (candidate.isBefore(deadline)) {
      final end = candidate.add(Duration(minutes: requiredMinutes));

      //
      // Užduotis privalo pasibaigti
      // iki termino.
      //
      if (end.isAfter(deadline)) {
        return null;
      }

      if (_isAvailable(
        start: candidate,
        end: end,
        routine: routine,
        calendarEvents: calendarEvents,
      )) {
        return candidate;
      }

      candidate = candidate.add(const Duration(minutes: 15));
    }

    return null;
  }

  static bool _isAvailable({
    required DateTime start,
    required DateTime end,
    required UserRoutine routine,
    required List<Event> calendarEvents,
  }) {
    //
    // Miego laikas.
    //
    if (!_isInsideAwakeTime(start, end, routine)) {
      return false;
    }

    //
    // Rutinos blokai.
    //
    for (final block in routine.blocks) {
      if (!block.weekdays.contains(start.weekday)) {
        continue;
      }

      final blockStart = DateTime(
        start.year,
        start.month,
        start.day,
      ).add(Duration(minutes: block.startMinutes));

      final blockEnd = DateTime(
        start.year,
        start.month,
        start.day,
      ).add(Duration(minutes: block.endMinutes));

      if (_overlaps(start, end, blockStart, blockEnd)) {
        return false;
      }
    }

    //
    // Telefono kalendorius.
    //
    for (final event in calendarEvents) {
      if (event.isAllDay) {
        continue;
      }

      if (event.status == EventStatus.canceled) {
        continue;
      }

      final eventStart = event.startDate;

      final eventEnd = event.endDate;

      if (_overlaps(start, end, eventStart, eventEnd)) {
        return false;
      }
    }

    return true;
  }

  static bool _isInsideAwakeTime(
    DateTime start,
    DateTime end,
    UserRoutine routine,
  ) {
    final wakeUp = routine.wakeUpMinutes;

    final sleep = routine.sleepStartMinutes;

    //
    // Jei žmogus dar nenustatė miego
    // režimo, Guardian šio apribojimo
    // netaiko.
    //
    if (wakeUp == null || sleep == null) {
      return true;
    }

    final startDay = DateTime(start.year, start.month, start.day);

    for (final dayOffset in [-1, 0]) {
      final day = startDay.add(Duration(days: dayOffset));

      final awakeStart = day.add(Duration(minutes: wakeUp));

      final awakeEnd = sleep > wakeUp
          ? day.add(Duration(minutes: sleep))
          : day.add(const Duration(days: 1)).add(Duration(minutes: sleep));

      final startsInside = !start.isBefore(awakeStart);
      final endsInside = !end.isAfter(awakeEnd);

      if (startsInside && endsInside) {
        return true;
      }
    }

    return false;
  }

  static bool _overlaps(
    DateTime startA,
    DateTime endA,
    DateTime startB,
    DateTime endB,
  ) {
    return startA.isBefore(endB) && endA.isAfter(startB);
  }

  static DateTime _roundUpToQuarterHour(DateTime date) {
    final remainder = date.minute % 15;

    if (remainder == 0 &&
        date.second == 0 &&
        date.millisecond == 0 &&
        date.microsecond == 0) {
      return date;
    }

    final minutesToAdd = remainder == 0 ? 15 : 15 - remainder;

    return DateTime(
      date.year,
      date.month,
      date.day,
      date.hour,
      date.minute,
    ).add(Duration(minutes: minutesToAdd));
  }
}
