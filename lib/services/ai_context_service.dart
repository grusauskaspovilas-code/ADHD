import 'package:device_calendar_plus/device_calendar_plus.dart';

import '../models/ai_context.dart';
import '../models/task.dart';
import '../models/user_routine.dart';

import '../services/calendar_service.dart';
import '../services/user_routine_service.dart';
import '../services/guardian_service.dart';

class AiContextService {
  static Future<AiContext> build({required List<Task> tasks}) async {
    final now = DateTime.now();

    final calendarEvents = await CalendarService.getUpcomingEvents();

    final routine = await UserRoutineService.loadRoutine();

    return _buildContext(
      now: now,
      tasks: tasks,
      calendarEvents: calendarEvents,
      routine: routine,
    );
  }

  //
  // Paleidžia Guardian analizę naudojant
  // tuos pačius realius programėlės duomenis.
  //
  static Future<List<GuardianResult>> buildGuardian({
    required List<Task> tasks,
  }) async {
    final now = DateTime.now();

    final calendarEvents = await CalendarService.getUpcomingEvents();

    final routine = await UserRoutineService.loadRoutine();

    return GuardianService.analyze(
      tasks: tasks,
      routine: routine,
      calendarEvents: calendarEvents,
      now: now,
    );
  }

  static AiContext _buildContext({
    required DateTime now,
    required List<Task> tasks,
    required List<Event> calendarEvents,
    required UserRoutine routine,
  }) {
    final currentMinutes = now.hour * 60 + now.minute;

    //
    // 1. Patikriname, ar dabar vyksta
    // rutinos blokas.
    //
    RoutineBlock? currentRoutineBlock;

    for (final block in routine.blocks) {
      final isToday = block.weekdays.contains(now.weekday);

      if (!isToday) {
        continue;
      }

      final isActive =
          currentMinutes >= block.startMinutes &&
          currentMinutes < block.endMinutes;

      if (isActive) {
        currentRoutineBlock = block;
        break;
      }
    }

    //
    // 2. Patikriname, ar dabar vyksta
    // telefono kalendoriaus įvykis.
    //
    Event? currentCalendarEvent;

    for (final event in calendarEvents) {
      if (event.isAllDay) {
        continue;
      }

      if (event.status == EventStatus.canceled) {
        continue;
      }

      final start = event.startDate;
      final end = event.endDate;

      final isActive = !now.isBefore(start) && now.isBefore(end);

      if (isActive) {
        currentCalendarEvent = event;
        break;
      }
    }

    //
    // 3. Nustatome, ar žmogus
    // dabar užimtas.
    //
    final currentlyBusy =
        currentCalendarEvent != null || currentRoutineBlock != null;

    String? currentActivity;
    DateTime? nextFreeTime;

    //
    // Kalendoriaus įvykis turi
    // prioritetą prieš rutiną.
    //
    if (currentCalendarEvent != null) {
      final title = currentCalendarEvent.title.trim();

      currentActivity = title.isEmpty ? 'Calendar event' : title;

      nextFreeTime = currentCalendarEvent.endDate;
    } else if (currentRoutineBlock != null) {
      currentActivity = currentRoutineBlock.title;

      nextFreeTime = DateTime(
        now.year,
        now.month,
        now.day,
        currentRoutineBlock.endMinutes ~/ 60,
        currentRoutineBlock.endMinutes % 60,
      );
    }

    //
    // 4. Jei dabar užimtas,
    // randame tikrą kitą
    // laisvą laiką.
    //
    if (currentlyBusy && nextFreeTime != null) {
      nextFreeTime = _findRealNextFreeTime(
        now: now,
        initialFreeTime: nextFreeTime,
        routine: routine,
        calendarEvents: calendarEvents,
      );
    }

    //
    // 5. Jei žmogus dabar laisvas,
    // randame kiek minučių liko
    // iki kito užimtumo.
    //
    int? freeMinutesNow;

    if (!currentlyBusy) {
      final nextBusyTime = _findNextBusyTime(
        now: now,
        routine: routine,
        calendarEvents: calendarEvents,
      );

      if (nextBusyTime != null) {
        final difference = nextBusyTime.difference(now);

        freeMinutesNow = difference.inMinutes;

        if (freeMinutesNow < 0) {
          freeMinutesNow = 0;
        }
      }
    } else {
      freeMinutesNow = 0;
    }

    return AiContext(
      now: now,
      tasks: tasks,
      calendarEvents: calendarEvents,
      routine: routine,
      currentlyBusy: currentlyBusy,
      currentActivity: currentActivity,
      freeMinutesNow: freeMinutesNow,
      nextFreeTime: nextFreeTime,
    );
  }

  static DateTime? _findNextBusyTime({
    required DateTime now,
    required UserRoutine routine,
    required List<Event> calendarEvents,
  }) {
    final candidates = <DateTime>[];

    final currentMinutes = now.hour * 60 + now.minute;

    //
    // Šiandienos rutinos blokai.
    //
    for (final block in routine.blocks) {
      if (!block.weekdays.contains(now.weekday)) {
        continue;
      }

      if (block.startMinutes <= currentMinutes) {
        continue;
      }

      candidates.add(
        DateTime(
          now.year,
          now.month,
          now.day,
          block.startMinutes ~/ 60,
          block.startMinutes % 60,
        ),
      );
    }

    //
    // Artimiausi kalendoriaus
    // įvykiai.
    //
    for (final event in calendarEvents) {
      if (event.isAllDay) {
        continue;
      }

      if (event.status == EventStatus.canceled) {
        continue;
      }

      if (event.startDate.isAfter(now)) {
        candidates.add(event.startDate);
      }
    }

    //
    // Miego pradžia.
    //
    final sleepMinutes = routine.sleepStartMinutes;

    if (sleepMinutes != null && sleepMinutes > currentMinutes) {
      candidates.add(
        DateTime(
          now.year,
          now.month,
          now.day,
          sleepMinutes ~/ 60,
          sleepMinutes % 60,
        ),
      );
    }

    if (candidates.isEmpty) {
      return null;
    }

    candidates.sort();

    return candidates.first;
  }

  static DateTime _findRealNextFreeTime({
    required DateTime now,
    required DateTime initialFreeTime,
    required UserRoutine routine,
    required List<Event> calendarEvents,
  }) {
    var freeTime = initialFreeTime;

    //
    // Gali būti keli vienas po kito
    // einantys užimtumo blokai.
    //
    // Pvz:
    //
    // Darbas iki 17:00
    // Kalendorius 16:30–17:30
    // Sportas 17:30–19:00
    //
    // Tikras laisvas laikas = 19:00.
    //
    for (var i = 0; i < 20; i++) {
      DateTime? extendedUntil;

      //
      // Rutinos blokai.
      //
      for (final block in routine.blocks) {
        if (!block.weekdays.contains(freeTime.weekday)) {
          continue;
        }

        final blockStart = DateTime(
          freeTime.year,
          freeTime.month,
          freeTime.day,
          block.startMinutes ~/ 60,
          block.startMinutes % 60,
        );

        final blockEnd = DateTime(
          freeTime.year,
          freeTime.month,
          freeTime.day,
          block.endMinutes ~/ 60,
          block.endMinutes % 60,
        );

        if (!blockStart.isAfter(freeTime) && blockEnd.isAfter(freeTime)) {
          if (extendedUntil == null || blockEnd.isAfter(extendedUntil)) {
            extendedUntil = blockEnd;
          }
        }
      }

      //
      // Kalendoriaus įvykiai.
      //
      for (final event in calendarEvents) {
        if (event.isAllDay) {
          continue;
        }

        if (event.status == EventStatus.canceled) {
          continue;
        }

        final end = event.endDate;

        if (!event.startDate.isAfter(freeTime) && end.isAfter(freeTime)) {
          if (extendedUntil == null || end.isAfter(extendedUntil)) {
            extendedUntil = end;
          }
        }
      }

      if (extendedUntil == null || !extendedUntil.isAfter(freeTime)) {
        break;
      }

      freeTime = extendedUntil;
    }

    return freeTime;
  }
}
