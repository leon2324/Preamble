import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:preamble/components/shared/inline_citation_parser.dart';
import 'package:preamble/data/law_assistant/law_assistant_api_service.dart';
import 'package:preamble/data/law_assistant/law_assistant_models.dart';
import 'package:preamble/data/law_assistant/law_assistant_repository.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('LawAssistantStreamChunk & Models Tests', () {
    test('LawAssistantStreamChunk parses json correctly', () {
      final json = {
        'textChunk': '民法第 184 條：',
        'isFinished': false,
        'citations': [
          {
            'title': '全國法規資料庫',
            'sourceType': 'statute',
            'url': 'https://law.moj.gov.tw/',
          }
        ],
      };

      final chunk = LawAssistantStreamChunk.fromJson(json);
      expect(chunk.textChunk, '民法第 184 條：');
      expect(chunk.isFinished, false);
      expect(chunk.citations.length, 1);
      expect(chunk.citations.first.title, '全國法規資料庫');
    });
  });

  group('LawAssistantApiService SSE Streaming Tests', () {
    test('sendMessageStream parses SSE data chunks', () async {
      final client = MockClient.streaming((request, bodyStream) async {
        final stream = Stream.fromIterable([
          utf8.encode('data: {"textChunk":"你好，我是小法助","isFinished":false}\n\n'),
          utf8.encode('data: {"textChunk":"[民法第 184 條] 規定侵權行為。","isFinished":false}\n\n'),
          utf8.encode('data: [DONE]\n\n'),
        ]);
        return http.StreamedResponse(stream, 200, headers: {
          'content-type': 'text/event-stream; charset=utf-8',
        });
      });

      final service = LawAssistantApiService(
        client: client,
        baseUrl: 'https://api.preamble.local',
      );

      final chunks = await service
          .sendMessageStream(
            conversationId: 'conv-123',
            prompt: '車禍責任',
          )
          .toList();

      expect(chunks.length, 3);
      expect(chunks[0].textChunk, '你好，我是小法助');
      expect(chunks[1].textChunk, '[民法第 184 條] 規定侵權行為。');
      expect(chunks[2].isFinished, true);
    });
  });

  group('LawAssistantRepository Dual-Track Streaming Tests', () {
    test('sendMessageStream uses local typewriter fallback when backend is not configured', () async {
      final repository = LawAssistantRepository(
        apiService: LawAssistantApiService(baseUrl: ''),
      );

      final chunks = await repository
          .sendMessageStream(
            conversationId: 'mock-conv',
            prompt: '租屋押金未退',
          )
          .toList();

      expect(chunks.isNotEmpty, true);
      expect(chunks.last.isFinished, true);

      final accumulatedText = chunks.map((c) => c.textChunk).join();
      expect(accumulatedText.contains('問題方向'), true);
      expect(accumulatedText.contains('建議行動'), true);
    });
  });

  group('InlineCitationText RegExp Parser Tests', () {
    testWidgets('InlineCitationText renders StatuteTagChip for law article tags', (tester) async {
      await tester.pumpWidget(
        ScreenUtilInit(
          designSize: const Size(393, 852),
          builder: (context, child) => const MaterialApp(
            home: Scaffold(
              body: InlineCitationText(
                text: '根據 [民法第 184 條] 與 [刑法第 339 條] 規定。',
              ),
            ),
          ),
        ),
      );

      expect(find.byType(StatuteTagChip), findsNWidgets(2));
      expect(find.text('民法第 184 條'), findsOneWidget);
      expect(find.text('刑法第 339 條'), findsOneWidget);
    });
  });
}
