import 'dart:convert';

import 'package:http/http.dart' as http;

import '../l10n/app_language.dart';

class AiTaskEstimateService {
  static const String _functionUrl =
      'https://gybmbfrvobcjonrpjale.supabase.co/functions/v1/estimate-task';

  static const String _publishableKey =
      'sb_publishable_at3yagsyDABYIU3iamn3mQ_CzVBE3Tf';

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
              'title': cleanTitle,
              'description':
                  description?.trim(),
              'language': language.name,
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

      final minutes = data['minutes'];

      if (minutes is! int) {
        return null;
      }

      const allowedMinutes = {
        5,
        15,
        30,
        60,
      };

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