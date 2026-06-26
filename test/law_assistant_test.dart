import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:preamble/data/law_assistant/guest_law_assistant_usage.dart';
import 'package:preamble/data/law_assistant/law_assistant_api_service.dart';
import 'package:preamble/data/law_assistant/law_assistant_models.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  test('LawAssistantConversation parses nested answer JSON', () {
    final conversation = LawAssistantConversation.fromJson({
      'id': 'c1',
      'title': '押金問題',
      'preview': '房東說押金不能退',
      'updatedAt': '2026-04-18T08:00:00Z',
      'categoryLabel': '租屋',
      'messages': [
        {
          'id': 'm1',
          'role': 'user',
          'content': '押金不能退嗎？',
          'createdAt': '2026-04-18T08:00:00Z',
        },
        {
          'id': 'm2',
          'role': 'assistant',
          'content': '先看租約和扣款理由。',
          'createdAt': '2026-04-18T08:00:01Z',
          'answer': {
            'problemDirection': '租屋押金返還',
            'relatedContent': '先確認租約、點交紀錄和扣款明細。',
            'nextStep': '補充提前解約原因與房東扣款項目。',
          },
        },
      ],
    });

    expect(conversation.id, 'c1');
    expect(conversation.messages, hasLength(2));
    expect(conversation.messages.last.role, LawAssistantMessageRole.assistant);
    expect(conversation.messages.last.answer?.problemDirection, '租屋押金返還');
  });

  test('LawAssistantApiService creates conversation through backend proxy',
      () async {
    final service = LawAssistantApiService(
      baseUrl: 'https://api.example.test',
      client: MockClient((request) async {
        expect(request.method, 'POST');
        expect(request.url.path, '/law-assistant/conversations');
        expect(jsonDecode(request.body)['prompt'], '押金不能退嗎？');

        return http.Response(
          jsonEncode({
            'id': 'c1',
            'title': '押金問題',
            'preview': '押金不能退嗎？',
            'updatedAt': '2026-04-18T08:00:00Z',
            'categoryLabel': '租屋',
            'messages': [],
          }),
          200,
          headers: {'content-type': 'application/json'},
        );
      }),
    );

    final conversation = await service.createConversation(prompt: '押金不能退嗎？');

    expect(conversation.id, 'c1');
    expect(conversation.categoryLabel, '租屋');
  });

  test('LawAssistantApiService maps backend errors', () async {
    final service = LawAssistantApiService(
      baseUrl: 'https://api.example.test',
      client: MockClient((_) async {
        return http.Response.bytes(
          utf8.encode(jsonEncode({'message': '配額已用完'})),
          429,
        );
      }),
    );

    expect(
      () => service.createConversation(prompt: '押金不能退嗎？'),
      throwsA(isA<LawAssistantApiException>()),
    );
  });

  test('GuestLawAssistantUsage stores one-time usage flag', () async {
    SharedPreferences.setMockInitialValues({});
    const usage = GuestLawAssistantUsage();

    expect(await usage.hasUsed(), isFalse);

    await usage.markUsed();

    expect(await usage.hasUsed(), isTrue);
  });
}
