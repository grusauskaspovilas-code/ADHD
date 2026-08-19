import '../l10n/app_language.dart';
import '../models/task.dart';
import 'ai_api_client.dart';

class AiBreakdownService {
  static Future<List<String>?> generateSteps({
    required Task task,
    required AppLanguage language,
  }) async {
    try {
      final data = await AiApiClient.postFunction(
        functionName: 'breakdown-task',
        timeout: const Duration(seconds: 20),
        body: {
          'language': language.name,
          'task': {
            'id': task.id,
            'title': task.title,
            'description': task.description,
            'estimatedMinutes': task.estimatedMinutes,
            'dueDate': task.dueDate?.toIso8601String(),
            'priority': task.priority.name,
            'energyLevel': task.energyLevel.name,
          },
        },
      );

      if (data['success'] != true) {
        return null;
      }

      final rawSteps = data['steps'];

      if (rawSteps is! List) {
        return null;
      }

      final steps = rawSteps
          .whereType<String>()
          .map((step) => step.trim())
          .where((step) => step.isNotEmpty)
          .toList();

      if (steps.isEmpty) {
        return null;
      }

      return steps;
    } catch (_) {
      // AI neveikia -> BreakdownScreen
      // galės naudoti seną BreakdownService.
      return null;
    }
  }
}
