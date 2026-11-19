import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:preamble/data/learning/supabase_learning_service.dart';
import 'package:preamble/data/learning/supabase_life_tips_service.dart';
import 'package:preamble/features/case_library/data/case_library_repository.dart';
import 'package:preamble/features/case_library/data/supabase_case_service.dart';

void main() {
  test('學習文章的正式空結果與 HTTP 失敗不顯示本機示範文章', () async {
    var status = 200;
    final client = MockClient((request) async {
      expect(request.url.path, '/rest/v1/learning_articles');
      return http.Response(status == 200 ? '[]' : '{}', status);
    });
    final service = SupabaseLearningService(client: client, configured: true);
    addTearDown(client.close);

    expect(await service.fetchArticles(), isEmpty);
    status = 503;
    await expectLater(service.fetchArticles(), throwsException);
  });

  test('生活筆記的正式空結果與 HTTP 失敗不顯示本機示範筆記', () async {
    var status = 200;
    final client = MockClient((request) async {
      expect(request.url.path, '/rest/v1/life_legal_tips');
      return http.Response(status == 200 ? '[]' : '{}', status);
    });
    final service = SupabaseLifeTipsService(client: client, configured: true);
    addTearDown(client.close);

    expect(await service.fetchLifeTips(), isEmpty);
    status = 503;
    await expectLater(service.fetchLifeTips(), throwsException);
  });

  test('每日專題從真實可用 ID 讀取；空清單不改用固定專題', () async {
    final seen = <String>[];
    final client = MockClient((request) async {
      seen.add(request.url.query);
      if (request.url.queryParameters['select'] == 'topic_id') {
        return http.Response('[{"topic_id":314},{"topic_id":314}]', 200);
      }
      expect(request.url.queryParameters['topic_id'], 'in.(314)');
      return http.Response(
        jsonEncode([
          for (var step = 1; step <= 5; step++)
            {
              'topic_id': 314,
              'step_number': step,
              'title': '單元 $step',
              'summary': '摘要',
              'category': '租屋',
            },
        ]),
        200,
        headers: {'content-type': 'application/json; charset=utf-8'},
      );
    });
    final service = SupabaseLearningService(client: client, configured: true);
    addTearDown(client.close);
    final topics =
        await service.fetchDailyFeaturedTopics(DateTime(2026, 11, 19));
    expect(topics, hasLength(1));
    expect(topics.single.units, hasLength(5));
    expect(seen, hasLength(2));
  });

  test('每日專題資料表為空時不顯示固定專題', () async {
    final client = MockClient((request) async => http.Response('[]', 200));
    final service = SupabaseLearningService(client: client, configured: true);
    addTearDown(client.close);
    expect(await service.fetchDailyFeaturedTopics(DateTime(2026)), isEmpty);
  });

  test('案件庫正式空結果及 HTTP 失敗不讀取 SQLite 或種子案件', () async {
    var status = 200;
    final client = MockClient((request) async {
      expect(request.url.path, '/rest/v1/cases');
      return http.Response(status == 200 ? '[]' : '{}', status);
    });
    final service = SupabaseCaseService(client: client, configured: true);
    final repository = CaseLibraryRepository.forTesting(service);
    addTearDown(client.close);

    expect(await repository.getCasesPaginated(20, 0), isEmpty);
    status = 503;
    await expectLater(repository.getCasesPaginated(20, 0), throwsException);
  });
}
