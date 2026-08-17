import '../models/task.dart';

import 'calendar_service.dart';
import 'guardian_service.dart';
import 'notification_service.dart';
import 'user_routine_service.dart';

class GuardianNotificationService {
  static Future<void> refresh({
    required List<Task> tasks,
  }) async {
    final routine =
        await UserRoutineService.loadRoutine();

    final calendarEvents =
        await CalendarService
            .getUpcomingEvents();

    final results =
        GuardianService.analyze(
      tasks: tasks,
      routine: routine,
      calendarEvents: calendarEvents,
    );

    final now = DateTime.now();

    //
    // Pirmiausia atšaukiame senus
    // Guardian priminimus.
    //
    for (final task in tasks) {
      await NotificationService
          .cancelGuardianReminder(
        id: notificationId(task),
      );
    }

    //
    // Suplanuojame aktualius priminimus.
    //
    for (final result in results) {
      if (result.isOverdue) {
        continue;
      }

      final suggestedStart =
          result.suggestedStart;

      if (suggestedStart == null) {
        continue;
      }

      if (!suggestedStart.isAfter(now)) {
        continue;
      }

      await NotificationService
          .scheduleGuardianReminder(
        id: notificationId(
          result.task,
        ),

        //
        // Notification dabar žinos,
        // kuriai užduočiai priklauso.
        //
        taskId: result.task.id,

        taskTitle:
            result.task.title,

        scheduledAt:
            suggestedStart,
      );
    }
  }

  static Future<void> cancelForTask(
    Task task,
  ) async {
    await NotificationService
        .cancelGuardianReminder(
      id: notificationId(task),
    );
  }

  static int notificationId(
    Task task,
  ) {
    return task.id.hashCode &
        0x7fffffff;
  }
}