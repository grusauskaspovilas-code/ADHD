import 'dart:convert';

import 'package:http/http.dart' as http;

class AiApiException implements Exception {
  final String message;

  const AiApiException(this.message);

  @override
  String toString() => 'AiApiException: $message';
}

class AiApiClient {
  static const String _baseUrl =
      'https://gybmbfrvobcjonrpjale.supabase.co/functions/v1';

  static const String _publishableKey =
      'sb_publishable_at3yagsyDABYIU3iamn3mQ_CzVBE3Tf';

  static Future<Map<String, dynamic>> postFunction({
    required String functionName,
    required Map<String, dynamic> body,
    required Duration timeout,
    http.Client? client,
  }) async {
    final uri = Uri.parse('$_baseUrl/$functionName');
    final encodedBody = jsonEncode(body);
    final headers = {
      'Content-Type': 'application/json',
      'apikey': _publishableKey,
      'Authorization': 'Bearer $_publishableKey',
    };

    final response =
        await (client == null
                ? http.post(uri, headers: headers, body: encodedBody)
                : client.post(uri, headers: headers, body: encodedBody))
            .timeout(timeout);

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw AiApiException('HTTP ${response.statusCode}');
    }

    final decoded = jsonDecode(response.body);

    if (decoded is! Map) {
      throw const AiApiException('Response is not a JSON object');
    }

    return Map<String, dynamic>.from(decoded);
  }
}
