import '../models/task.dart';
import 'ai_task_service.dart';

class AIService {
  static Future<Task?> selectBestTask({
    required List<Task> tasks,
    int? availableMinutes,
  }) async {
    if (tasks.isEmpty) {
      return null;
    }

    final result = await AiTaskService.selectTask(
      tasks: tasks,
      availableMinutes: availableMinutes,
    );

    if (result == null) {
      return null;
    }

    for (final task in tasks) {
      if (task.id == result.taskId) {
        return task;
      }
    }

    return null;
  }
}