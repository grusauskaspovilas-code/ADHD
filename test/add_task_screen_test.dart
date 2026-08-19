import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:focus_assistant/l10n/app_language.dart';
import 'package:focus_assistant/models/task.dart';
import 'package:focus_assistant/screens/add_task_screen.dart';

void main() {
  testWidgets('prefills the form when editing an existing task', (
    WidgetTester tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(600, 3000));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    final task = Task(
      id: 'existing-task',
      title: 'Reply to the client',
      description: 'Include the updated proposal',
      createdAt: DateTime(2026, 8, 18, 9),
      dueDate: DateTime(2026, 8, 18, 16),
      estimatedMinutes: 30,
      isRequired: true,
      actionType: TaskActionType.email,
      emailAddress: 'client@example.com',
    );

    await tester.pumpWidget(
      MaterialApp(
        home: AddTaskScreen(language: AppLanguage.english, existingTask: task),
      ),
    );

    expect(find.text('Edit task'), findsOneWidget);
    expect(find.text('Reply to the client'), findsOneWidget);
    expect(find.text('Include the updated proposal'), findsOneWidget);
    expect(find.text('client@example.com'), findsOneWidget);

    expect(find.text('SAVE CHANGES'), findsOneWidget);
  });
}
