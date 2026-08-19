import 'package:flutter_test/flutter_test.dart';

import 'package:focus_assistant/models/task.dart';
import 'package:focus_assistant/models/user_routine.dart';
import 'package:focus_assistant/services/guardian_service.dart';

void main() {
  Task requiredTask({
    required String id,
    required DateTime deadline,
    int estimatedMinutes = 30,
  }) {
    return Task(
      id: id,
      title: 'Required task',
      createdAt: deadline.subtract(const Duration(days: 1)),
      dueDate: deadline,
      estimatedMinutes: estimatedMinutes,
      isRequired: true,
    );
  }

  test('marks a task as overdue after its deadline', () {
    final now = DateTime(2026, 8, 18, 12);
    final task = requiredTask(
      id: 'overdue',
      deadline: now.subtract(const Duration(minutes: 1)),
    );

    final result = GuardianService.analyze(
      tasks: [task],
      routine: const UserRoutine(),
      calendarEvents: const [],
      now: now,
    ).single;

    expect(result.isOverdue, isTrue);
    expect(result.isUrgent, isTrue);
    expect(result.canStillFit, isFalse);
    expect(result.suggestedStart, isNull);
  });

  test('suggests the next quarter-hour when it is free', () {
    final now = DateTime(2026, 8, 18, 10, 7);
    final task = requiredTask(
      id: 'available',
      deadline: DateTime(2026, 8, 18, 13),
    );

    final result = GuardianService.analyze(
      tasks: [task],
      routine: const UserRoutine(),
      calendarEvents: const [],
      now: now,
    ).single;

    expect(result.canStillFit, isTrue);
    expect(result.suggestedStart, DateTime(2026, 8, 18, 10, 15));
  });

  test('reports that a task cannot fit around a routine block', () {
    final now = DateTime(2026, 8, 18, 10);
    final task = requiredTask(
      id: 'blocked',
      deadline: DateTime(2026, 8, 18, 12),
    );

    final result = GuardianService.analyze(
      tasks: [task],
      routine: const UserRoutine(
        blocks: [
          RoutineBlock(
            id: 'work',
            title: 'Work',
            weekdays: [DateTime.tuesday],
            startMinutes: 10 * 60,
            endMinutes: 12 * 60,
          ),
        ],
      ),
      calendarEvents: const [],
      now: now,
    ).single;

    expect(result.canStillFit, isFalse);
    expect(result.isUrgent, isTrue);
  });

  test('does not schedule work across the sleep boundary', () {
    final now = DateTime(2026, 8, 18, 22, 20);
    final task = requiredTask(
      id: 'sleep-boundary',
      deadline: DateTime(2026, 8, 19, 2),
      estimatedMinutes: 120,
    );

    final result = GuardianService.analyze(
      tasks: [task],
      routine: const UserRoutine(
        wakeUpMinutes: 7 * 60,
        sleepStartMinutes: 23 * 60,
      ),
      calendarEvents: const [],
      now: now,
    ).single;

    expect(result.canStillFit, isFalse);
    expect(result.suggestedStart, isNull);
  });

  test('finds a free lunch check after a routine block', () {
    final slot = GuardianService.findAvailableSlot(
      windowStart: DateTime(2026, 8, 18, 11, 30),
      windowEnd: DateTime(2026, 8, 18, 14),
      requiredMinutes: 5,
      routine: const UserRoutine(
        blocks: [
          RoutineBlock(
            id: 'meeting',
            title: 'Meeting',
            weekdays: [DateTime.tuesday],
            startMinutes: 11 * 60 + 30,
            endMinutes: 12 * 60 + 30,
          ),
        ],
      ),
      calendarEvents: const [],
    );

    expect(slot, DateTime(2026, 8, 18, 12, 30));
  });
}
