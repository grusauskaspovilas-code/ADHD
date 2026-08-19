import '../l10n/app_language.dart';
import '../models/task.dart';
import 'ai_api_client.dart';

class AiStuckService {
  static Future<String?> generateFirstStep({
    required Task task,
    required AppLanguage language,
  }) async {
    try {
      final data = await AiApiClient.postFunction(
        functionName: 'bright-handler',
        timeout: const Duration(seconds: 15),
        body: {
          'language': language.name,
          'task': {
            'id': task.id,
            'title': task.title,
            'description': task.description,
            'estimatedMinutes': task.estimatedMinutes,
            'priority': task.priority.name,
            'energyLevel': task.energyLevel.name,
          },
        },
      );

      if (data['success'] != true) {
        return null;
      }

      final step = data['step'];

      if (step is! String || step.trim().isEmpty) {
        return null;
      }

      return step.trim();
    } catch (_) {
      // Jei internetas, Supabase arba AI
      // neveikia, grąžiname null.
      //
      // StuckScreen tada rodys seną
      // bendrinį pirmą žingsnį.
      return null;
    }
  }
}
