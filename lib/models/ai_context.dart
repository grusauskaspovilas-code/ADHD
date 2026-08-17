import 'package:device_calendar_plus/device_calendar_plus.dart';

import 'task.dart';
import 'user_routine.dart';

class AiContext {
  final DateTime now;

  final List<Task> tasks;

  final List<Event> calendarEvents;

  final UserRoutine routine;

  final bool currentlyBusy;

  final String? currentActivity;

  final int? freeMinutesNow;

  final DateTime? nextFreeTime;

  const AiContext({
    required this.now,
    required this.tasks,
    required this.calendarEvents,
    required this.routine,
    required this.currentlyBusy,
    required this.currentActivity,
    required this.freeMinutesNow,
    required this.nextFreeTime,
  });

  int get weekday => now.weekday;

  int get currentMinutes =>
      now.hour * 60 + now.minute;
}