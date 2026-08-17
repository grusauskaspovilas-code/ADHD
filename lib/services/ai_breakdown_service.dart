import 'dart:convert';

import 'package:http/http.dart' as http;

import '../l10n/app_language.dart';
import '../models/task.dart';

class AiBreakdownService {
  static const String _functionUrl =
      'https://gybmbfrvobcjonrpjale.supabase.co/functions/v1/breakdown-task';

  static const String _publishableKey =
      'sb_publishable_at3yagsyDABYIU3iamn3mQ_CzVBE3Tf';

  static Future<List<String>?> generateSteps({
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
                'dueDate':
                    task.dueDate?.toIso8601String(),
                'priority': task.priority.name,
                'energyLevel':
                    task.energyLevel.name,
              },
            }),
          )
          .timeout(
            const Duration(seconds: 20),
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