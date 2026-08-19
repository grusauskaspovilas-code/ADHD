import 'dart:convert';

import 'package:device_calendar_plus/device_calendar_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../l10n/app_language.dart';
import '../l10n/guardian_strings.dart';
import '../models/task.dart';
import '../models/user_routine.dart';

import 'calendar_service.dart';
import 'guardian_reminder_planner.dart';
import 'guardian_service.dart';
import 'language_service.dart';
import 'notification_service.dart';
import 'user_routine_service.dart';

class GuardianNotificationService {
  static const String _warningStateKey = 'guardian_warning_states';

  static Future<void> _refreshQueue = Future<void>.value();

  static Future<void> refresh({required List<Task> tasks}) {
    final taskSnapshot = List<Task>.of(tasks);

    final operation = _refreshQueue.then(
      (_) => _performRefresh(tasks: taskSnapshot),
    );

    _refreshQueue = operation.then<void>(
      (_) {},
      onError: (error, stackTrace) {},
    );

    return operation;
  }

  static Future<void> _performRefresh({required List<Task> tasks}) async {
    final routine = await UserRoutineService.loadRoutine();

    final calendarEvents = await CalendarService.getUpcomingEvents();

    final results = GuardianService.analyze(
      tasks: tasks,
      routine: routine,
      calendarEvents: calendarEvents,
    );

    final now = DateTime.now();
    final previousWarnings = await _loadWarningStates();
    final activeWarnings = <String, String>{};
    final language = LanguageService.resolve(
      await LanguageService.loadLanguage(),
    );

    //
    // Pirmiausia atšaukiame senus
    // Guardian priminimus.
    //
    for (final task in tasks) {
      await _cancelScheduledReminders(task.id);
    }

    //
    // Suplanuojame aktualius priminimus.
    //
    for (final result in results) {
      final warningType = result.isOverdue
          ? 'overdue'
          : !result.canStillFit
          ? 'no-fit'
          : null;

      if (warningType != null) {
        final signature =
            '$warningType:${result.task.dueDate!.toIso8601String()}';

        activeWarnings[result.task.id] = signature;

        if (previousWarnings[result.task.id] != signature) {
          await NotificationService.showGuardianWarning(
            id: warningNotificationId(result.task.id),
            taskId: result.task.id,
            message: _warningMessage(result: result, language: language),
          );
        }

        continue;
      }

      final reminders = GuardianReminderPlanner.build(
        result: result,
        language: language,
        now: now,
        lunchCheckTime: _findLunchCheckTime(
          result: result,
          routine: routine,
          calendarEvents: calendarEvents,
          now: now,
        ),
      );

      for (final reminder in reminders) {
        await NotificationService.scheduleGuardianReminder(
          id: _reminderNotificationId(result.task.id, reminder.stage),
          taskId: result.task.id,
          message: reminder.message,
          scheduledAt: reminder.scheduledAt,
        );
      }
    }

    for (final taskId in previousWarnings.keys) {
      if (!activeWarnings.containsKey(taskId)) {
        await NotificationService.cancelGuardianReminder(
          id: warningNotificationId(taskId),
        );
      }
    }

    await _saveWarningStates(activeWarnings);
  }

  static Future<void> cancelForTask(Task task) async {
    await _cancelScheduledReminders(task.id);

    await NotificationService.cancelGuardianReminder(
      id: warningNotificationId(task.id),
    );

    final warningStates = await _loadWarningStates();

    if (warningStates.remove(task.id) != null) {
      await _saveWarningStates(warningStates);
    }
  }

  static int notificationId(Task task) {
    return _reminderNotificationId(task.id, GuardianReminderStage.start);
  }

  static int _reminderNotificationId(
    String taskId,
    GuardianReminderStage stage,
  ) {
    final base = notificationBaseId(taskId);

    return base | (stage.index << 29);
  }

  static int warningNotificationId(String taskId) {
    final base = notificationBaseId(taskId);

    return base | (3 << 29);
  }

  static int notificationBaseId(String taskId) {
    var hash = 0;
    for (final codeUnit in taskId.codeUnits) {
      hash = ((hash * 31) + codeUnit) & 0x1fffffff;
    }
    return hash;
  }

  static Future<void> _cancelScheduledReminders(String taskId) async {
    for (final stage in GuardianReminderStage.values) {
      await NotificationService.cancelGuardianReminder(
        id: _reminderNotificationId(taskId, stage),
      );
    }
  }

  static DateTime? _findLunchCheckTime({
    required GuardianResult result,
    required UserRoutine routine,
    required List<Event> calendarEvents,
    required DateTime now,
  }) {
    final deadline = result.task.dueDate!;
    final lunchStart = DateTime(
      deadline.year,
      deadline.month,
      deadline.day,
      11,
      30,
    );
    final lunchEnd = DateTime(deadline.year, deadline.month, deadline.day, 14);
    final windowStart = now.isAfter(lunchStart) ? now : lunchStart;
    final windowEnd = deadline.isBefore(lunchEnd) ? deadline : lunchEnd;

    if (!windowEnd.isAfter(windowStart)) {
      return null;
    }

    return GuardianService.findAvailableSlot(
      windowStart: windowStart,
      windowEnd: windowEnd,
      requiredMinutes: 5,
      routine: routine,
      calendarEvents: calendarEvents,
    );
  }

  static String _warningMessage({
    required GuardianResult result,
    required AppLanguage language,
  }) {
    final title = result.task.title;
    final strings = GuardianStrings(language);

    if (result.isOverdue) {
      return strings.overdueWarning(title);
    }

    return strings.noTimeWarning(title);
  }

  static Future<Map<String, String>> _loadWarningStates() async {
    final preferences = await SharedPreferences.getInstance();
    final encoded = preferences.getString(_warningStateKey);

    if (encoded == null || encoded.isEmpty) {
      return {};
    }

    try {
      final decoded = jsonDecode(encoded);

      if (decoded is! Map) {
        return {};
      }

      return decoded.map(
        (key, value) => MapEntry(key.toString(), value.toString()),
      );
    } catch (_) {
      return {};
    }
  }

  static Future<void> _saveWarningStates(Map<String, String> states) async {
    final preferences = await SharedPreferences.getInstance();

    await preferences.setString(_warningStateKey, jsonEncode(states));
  }
}
