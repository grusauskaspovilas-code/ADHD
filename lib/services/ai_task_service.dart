import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/task.dart';

class AiTaskResult {
  final String taskId;
  final String reason;

  const AiTaskResult({
    required this.taskId,
    required this.reason,
  });
}

class AiTaskService {
  static const String _functionUrl =
      'https://gybmbfrvobcjonrpjale.supabase.co/functions/v1/select-task';

  // ČIA įklijuok ką tik nukopijuotą
  // Supabase Publishable key.
  static const String _publishableKey =
      'sb_publishable_at3yagsyDABYIU3iamn3mQ_CzVBE3Tf';

static Future<AiTaskResult?> selectTask({
  required List<Task> tasks,
  int? availableMinutes,
}) async {
  final activeTasks = tasks
      .where((task) => !task.isCompleted)
      .toList();

  if (activeTasks.isEmpty) {
    print('AI DEBUG: nėra aktyvių užduočių');
    return null;
  }

  try {
    print(
      'AI DEBUG: siunčiame ${activeTasks.length} užduotis',
    );

    final response = await http
        .post(
          Uri.parse(_functionUrl),
          headers: {
            'Content-Type': 'application/json',
            'apikey': _publishableKey,
            'Authorization':
                'Bearer $_publishableKey',
          },
          body: jsonEncode({
            'availableMinutes':
                availableMinutes,
            'tasks': activeTasks
                .map(
                  (task) => {
                    'id': task.id,
                    'title': task.title,
                    'description':
                        task.description,
                    'estimatedMinutes':
                        task.estimatedMinutes,
                    'dueDate': task.dueDate
                        ?.toIso8601String(),
                    'priority':
                        task.priority.name,
                    'energyLevel':
                        task.energyLevel.name,
                  },
                )
                .toList(),
          }),
        )
        .timeout(
          const Duration(seconds: 30),
        );

    print(
      'AI DEBUG STATUS: ${response.statusCode}',
    );

    print(
      'AI DEBUG BODY: ${response.body}',
    );

   if (response.statusCode < 200 ||
    response.statusCode >= 300) {
  throw Exception(
    'AI HTTP ${response.statusCode}: ${response.body}',
  );
}

    final dynamic decoded =
        jsonDecode(response.body);

    if (decoded is! Map) {
      print(
        'AI DEBUG: atsakymas nėra JSON objektas',
      );
      return null;
    }

    final data =
        Map<String, dynamic>.from(decoded);

    if (data['success'] != true) {
      print(
        'AI DEBUG ERROR: ${data['error']}',
      );
      return null;
    }

    final taskId =
        data['taskId']?.toString();

    if (taskId == null ||
        taskId.isEmpty) {
      print(
        'AI DEBUG: nėra taskId',
      );
      return null;
    }

    print(
      'AI DEBUG TASK ID: $taskId',
    );

    final exists = activeTasks.any(
      (task) => task.id == taskId,
    );

    if (!exists) {
      print(
        'AI DEBUG: AI taskId nerastas tarp užduočių',
      );

      print(
        'AI DEBUG GALIMI ID: '
        '${activeTasks.map((task) => task.id).toList()}',
      );

      return null;
    }

    return AiTaskResult(
      taskId: taskId,
      reason:
          data['reason']?.toString() ?? '',
    );
 } catch (e) {
  throw Exception('AI klaida: $e');
}
}
}