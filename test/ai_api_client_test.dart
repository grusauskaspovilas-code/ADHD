import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

import 'package:focus_assistant/services/ai_api_client.dart';

void main() {
  test('posts JSON to a Supabase function and decodes the response', () async {
    final client = MockClient((request) async {
      expect(request.url.path, endsWith('/functions/v1/test-function'));
      expect(request.headers['content-type'], 'application/json');
      expect(request.headers['apikey'], isNotEmpty);
      expect(jsonDecode(request.body), {'value': 42});

      return http.Response(jsonEncode({'success': true, 'answer': 42}), 200);
    });

    final response = await AiApiClient.postFunction(
      functionName: 'test-function',
      body: const {'value': 42},
      timeout: const Duration(seconds: 1),
      client: client,
    );

    expect(response['success'], isTrue);
    expect(response['answer'], 42);
  });

  test('throws a typed error for unsuccessful HTTP responses', () async {
    final client = MockClient((_) async => http.Response('Server error', 500));

    expect(
      () => AiApiClient.postFunction(
        functionName: 'test-function',
        body: const {},
        timeout: const Duration(seconds: 1),
        client: client,
      ),
      throwsA(isA<AiApiException>()),
    );
  });

  test('rejects a JSON response that is not an object', () async {
    final client = MockClient((_) async => http.Response('[1, 2, 3]', 200));

    expect(
      () => AiApiClient.postFunction(
        functionName: 'test-function',
        body: const {},
        timeout: const Duration(seconds: 1),
        client: client,
      ),
      throwsA(isA<AiApiException>()),
    );
  });
}
