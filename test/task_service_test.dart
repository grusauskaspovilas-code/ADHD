import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:focus_assistant/models/task.dart';
import 'package:focus_assistant/services/task_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('saves and restores task data', () async {
    final task = Task(
      id: 'task-1',
      title: 'Reply to email',
      description: 'Important client response',
      createdAt: DateTime(2026, 8, 18, 9),
      dueDate: DateTime(2026, 8, 18, 16),
      estimatedMinutes: 30,
      priority: TaskPriority.urgent,
      energyLevel: EnergyLevel.high,
      isRequired: true,
      actionType: TaskActionType.email,
      emailAddress: 'client@example.com',
      steps: ['Open email', 'Write response'],
      placeRequirement: TaskPlaceRequirement.work,
    );

    await TaskService.saveTasks([task]);

    final restored = await TaskService.loadTasks();

    expect(restored, hasLength(1));
    expect(restored.single.id, task.id);
    expect(restored.single.title, task.title);
    expect(restored.single.dueDate, task.dueDate);
    expect(restored.single.priority, TaskPriority.urgent);
    expect(restored.single.isRequired, isTrue);
    expect(restored.single.actionType, TaskActionType.email);
    expect(restored.single.emailAddress, 'client@example.com');
    expect(restored.single.steps, task.steps);
    expect(restored.single.placeRequirement, TaskPlaceRequirement.work);
  });

  test('old tasks without a place remain available anywhere', () async {
    final oldTask = Task(
      id: 'old-task',
      title: 'Old task',
      createdAt: DateTime(2026, 8, 18),
    ).toJson()..remove('placeRequirement');
    SharedPreferences.setMockInitialValues({
      'tasks': jsonEncode([oldTask]),
    });

    final restored = await TaskService.loadTasks();

    expect(restored.single.placeRequirement, TaskPlaceRequirement.anywhere);
  });

  test('recovers valid tasks when one stored item is damaged', () async {
    final validTask = Task(
      id: 'valid',
      title: 'Valid task',
      createdAt: DateTime(2026, 8, 18),
    );

    SharedPreferences.setMockInitialValues({
      'tasks': jsonEncode([
        validTask.toJson(),
        {'id': 'broken', 'title': 'Broken task', 'createdAt': 'not-a-date'},
        'not-a-task',
      ]),
    });

    final restored = await TaskService.loadTasks();

    expect(restored, hasLength(1));
    expect(restored.single.id, 'valid');
  });

  test('returns an empty list for invalid stored JSON', () async {
    SharedPreferences.setMockInitialValues({'tasks': '{invalid json'});

    expect(await TaskService.loadTasks(), isEmpty);
  });
}
