import '../models/task.dart';
import 'ai_api_client.dart';

class AiTaskResult {
  final String taskId;
  final String reason;

  const AiTaskResult({required this.taskId, required this.reason});
}

class AiTaskService {
  static Future<AiTaskResult?> selectTask({
    required List<Task> tasks,
    int? availableMinutes,
  }) async {
    final activeTasks = tasks.where((task) => !task.isCompleted).toList();

    if (activeTasks.isEmpty) {
      return null;
    }

    try {
      final data = await AiApiClient.postFunction(
        functionName: 'select-task',
        timeout: const Duration(seconds: 30),
        body: {
          'availableMinutes': availableMinutes,
          'tasks': activeTasks
              .map(
                (task) => {
                  'id': task.id,
                  'title': task.title,
                  'description': task.description,
                  'estimatedMinutes': task.estimatedMinutes,
                  'dueDate': task.dueDate?.toIso8601String(),
                  'priority': task.priority.name,
                  'energyLevel': task.energyLevel.name,
                },
              )
              .toList(),
        },
      );

      if (data['success'] != true) {
        return null;
      }

      final taskId = data['taskId']?.toString();

      if (taskId == null || taskId.isEmpty) {
        return null;
      }

      final exists = activeTasks.any((task) => task.id == taskId);

      if (!exists) {
        return null;
      }

      return AiTaskResult(
        taskId: taskId,
        reason: data['reason']?.toString() ?? '',
      );
    } catch (e) {
      throw Exception('AI klaida: $e');
    }
  }
}
