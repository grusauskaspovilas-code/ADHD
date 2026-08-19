import '../l10n/app_language.dart';
import '../l10n/guardian_strings.dart';

import 'guardian_service.dart';

enum GuardianReminderStage { start, lunchCheck, finalWarning }

class GuardianReminder {
  final GuardianReminderStage stage;
  final DateTime scheduledAt;
  final String message;

  const GuardianReminder({
    required this.stage,
    required this.scheduledAt,
    required this.message,
  });
}

class GuardianReminderPlanner {
  static List<GuardianReminder> build({
    required GuardianResult result,
    required AppLanguage language,
    required DateTime now,
    DateTime? lunchCheckTime,
  }) {
    final deadline = result.task.dueDate!;
    final strings = GuardianStrings(language);
    final reminders = <GuardianReminder>[];
    final suggestedStart = result.suggestedStart;

    if (suggestedStart != null && suggestedStart.isAfter(now)) {
      reminders.add(
        GuardianReminder(
          stage: GuardianReminderStage.start,
          scheduledAt: suggestedStart,
          message: strings.startReminder(result.task.title),
        ),
      );
    }

    final lunchCheck =
        lunchCheckTime ??
        DateTime(deadline.year, deadline.month, deadline.day, 12);

    if (lunchCheck.isAfter(now) && lunchCheck.isBefore(deadline)) {
      reminders.add(
        GuardianReminder(
          stage: GuardianReminderStage.lunchCheck,
          scheduledAt: lunchCheck,
          message: strings.lunchReminder(result.task.title),
        ),
      );
    }

    final finalWarning = deadline.subtract(const Duration(minutes: 30));

    if (finalWarning.isAfter(now)) {
      reminders.add(
        GuardianReminder(
          stage: GuardianReminderStage.finalWarning,
          scheduledAt: finalWarning,
          message: strings.finalReminder(result.task.title),
        ),
      );
    }

    reminders.sort((a, b) => a.scheduledAt.compareTo(b.scheduledAt));

    final usedTimes = <DateTime>{};

    return reminders.where((reminder) {
      return usedTimes.add(reminder.scheduledAt);
    }).toList();
  }
}
