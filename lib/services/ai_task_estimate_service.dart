import '../l10n/app_language.dart';
import 'ai_api_client.dart';

class AiTaskEstimateService {
  static Future<int?> estimateDuration({
    required String title,
    String? description,
    required AppLanguage language,
  }) async {
    final cleanTitle = title.trim();

    if (cleanTitle.isEmpty) {
      return null;
    }

    try {
      final data = await AiApiClient.postFunction(
        functionName: 'estimate-task',
        timeout: const Duration(seconds: 15),
        body: {
          'title': cleanTitle,
          'description': description?.trim(),
          'language': language.name,
        },
      );

      if (data['success'] != true) {
        return null;
      }

      final minutes = data['minutes'];

      if (minutes is! int) {
        return null;
      }

      const allowedMinutes = {5, 15, 30, 60};

      if (!allowedMinutes.contains(minutes)) {
        return null;
      }

      return minutes;
    } catch (_) {
      // Jei internetas, Supabase arba AI
      // neveikia, nieko automatiškai
      // nekeisime.
      return null;
    }
  }
}
