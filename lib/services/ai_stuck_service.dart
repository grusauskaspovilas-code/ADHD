import 'dart:convert';

import 'package:http/http.dart' as http;

import '../l10n/app_language.dart';
import '../models/task.dart';

class AiStuckService {
  static const String _functionUrl =
      'https://gybmbfrvobcjonrpjale.supabase.co/functions/v1/bright-handler';

  static const String _publishableKey =
      'sb_publishable_at3yagsyDABYIU3iamn3mQ_CzVBE3Tf';

  static Future<String?> generateFirstStep({
    required Task task,
    required AppLanguage language,
  }) async {
    try {
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
              'language': language.name,
              'task': {
                'id': task.id,
                'title': task.title,
                'description': task.description,
                'estimatedMinutes':
                    task.estimatedMinutes,
                'priority': task.priority.name,
                'energyLevel':
                    task.energyLevel.name,
              },
            }),
          )
          .timeout(
            const Duration(seconds: 15),
          );

      if (response.statusCode < 200 ||
          response.statusCode >= 300) {
        return null;
      }

      final data = jsonDecode(
        response.body,
      );

      if (data is! Map<String, dynamic>) {
        return null;
      }

      if (data['success'] != true) {
        return null;
      }

      final step = data['step'];

      if (step is! String ||
          step.trim().isEmpty) {
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