import 'package:flutter_test/flutter_test.dart';

import 'package:focus_assistant/l10n/app_language.dart';
import 'package:focus_assistant/models/task.dart';
import 'package:focus_assistant/services/guardian_reminder_planner.dart';
import 'package:focus_assistant/services/guardian_notification_service.dart';
import 'package:focus_assistant/services/guardian_service.dart';

void main() {
  test('notification base id is deterministic', () {
    expect(
      GuardianNotificationService.notificationBaseId('task-123'),
      125509098,
    );
    expect(
      GuardianNotificationService.notificationBaseId('task-123'),
      isNot(GuardianNotificationService.notificationBaseId('task-124')),
    );
  });

  GuardianResult result({
    required DateTime deadline,
    required DateTime suggestedStart,
  }) {
    final task = Task(
      id: 'email-reply',
      title: 'Atsakyti į laišką',
      createdAt: deadline.subtract(const Duration(days: 1)),
      dueDate: deadline,
      estimatedMinutes: 30,
      isRequired: true,
    );

    return GuardianResult(
      task: task,
      timeUntilDeadline: deadline.difference(suggestedStart),
      isOverdue: false,
      isUrgent: true,
      canStillFit: true,
      suggestedStart: suggestedStart,
    );
  }

  test('plans start, lunch and final reminders for a 16:00 deadline', () {
    final now = DateTime(2026, 8, 18, 8);
    final reminders = GuardianReminderPlanner.build(
      result: result(
        deadline: DateTime(2026, 8, 18, 16),
        suggestedStart: DateTime(2026, 8, 18, 9),
      ),
      language: AppLanguage.lithuanian,
      now: now,
    );

    expect(reminders.map((reminder) => reminder.stage), [
      GuardianReminderStage.start,
      GuardianReminderStage.lunchCheck,
      GuardianReminderStage.finalWarning,
    ]);
    expect(reminders.map((reminder) => reminder.scheduledAt), [
      DateTime(2026, 8, 18, 9),
      DateTime(2026, 8, 18, 12),
      DateTime(2026, 8, 18, 15, 30),
    ]);
  });

  test('does not plan reminder stages whose time has passed', () {
    final reminders = GuardianReminderPlanner.build(
      result: result(
        deadline: DateTime(2026, 8, 18, 16),
        suggestedStart: DateTime(2026, 8, 18, 9),
      ),
      language: AppLanguage.english,
      now: DateTime(2026, 8, 18, 14),
    );

    expect(reminders, hasLength(1));
    expect(reminders.single.stage, GuardianReminderStage.finalWarning);
  });
}
