import 'dart:async';
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

  test('正式案件詳情由雲端確認，不能從種子或舊快取直接返回', () async {
    var status = 200;
    var calls = 0;
    final client = MockClient((request) async {
      calls++;
      expect(request.url.path, '/rest/v1/cases');
      expect(request.url.queryParameters['id'], 'eq.318');
      return http.Response(
        status == 200
            ? jsonEncode([
                {'id': '318', 'titleZh': '雲端確認的案件', 'year': 2026}
              ])
            : '[]',
        status,
        headers: {'content-type': 'application/json; charset=utf-8'},
      );
    });
    final service = SupabaseCaseService(client: client, configured: true);
    final repository = CaseLibraryRepository.forTesting(service);
    addTearDown(client.close);

    expect(repository.getCaseById('318').titleZh, '案件載入中...');
    expect(repository.getRecommendedCases(), isEmpty);
    expect((await repository.getCaseDetail('318')).titleZh, '雲端確認的案件');
    expect(repository.getCaseById('318').titleZh, '雲端確認的案件');
    status = 404;
    await expectLater(repository.getCaseDetail('318'), throwsException);
    expect(calls, 2);
  });

  test('正式推薦只使用雲端清單，後續空結果會清除舊推薦', () async {
    var populated = true;
    final client = MockClient((request) async => http.Response(
          jsonEncode(populated
              ? [
                  {
                    'id': 'case-chiang-kuo-ching',
                    'titleZh': '雲端精選案件',
                    'year': 2026,
                  },
                ]
              : []),
          200,
          headers: {'content-type': 'application/json; charset=utf-8'},
        ));
    final service = SupabaseCaseService(client: client, configured: true);
    final repository = CaseLibraryRepository.forTesting(service);
    addTearDown(client.close);

    expect(await repository.getCasesPaginated(20, 0), hasLength(1));
    expect(repository.getRecommendedCases().single.titleZh, '雲端精選案件');
    populated = false;
    expect(await repository.getCasesPaginated(20, 0), isEmpty);
    expect(repository.getRecommendedCases(), isEmpty);
  });

  test('較慢的舊案件回應不覆蓋較新的正式推薦快照', () async {
    final first = Completer<http.Response>();
    final second = Completer<http.Response>();
    var calls = 0;
    final client =
        MockClient((request) => ++calls == 1 ? first.future : second.future);
    final service = SupabaseCaseService(client: client, configured: true);
    final repository = CaseLibraryRepository.forTesting(service);
    addTearDown(client.close);

    http.Response response(String id, String title) => http.Response(
          jsonEncode([
            {'id': id, 'titleZh': title, 'year': 2026}
          ]),
          200,
          headers: {'content-type': 'application/json; charset=utf-8'},
        );

    final older = repository.getCasesPaginated(20, 0);
    final newer = repository.getCasesPaginated(20, 0);
    second.complete(response('new-case', '較新雲端結果'));
    await newer;
    first.complete(response('old-case', '較舊雲端結果'));
    await older;
    expect(repository.getRecommendedCases().single.titleZh, '較新雲端結果');
  });

  test('未設定案件來源時保留本機展示，查無 ID 不回傳無關案件', () async {
    final service = SupabaseCaseService(configured: false);
    addTearDown(service.dispose);
    final repository = CaseLibraryRepository.forTesting(service);
    expect(repository.getCaseById('318').titleZh, isNot('案件載入中...'));
    expect(repository.getRecommendedCases(), isNotEmpty);
    await expectLater(
        service.fetchCaseDetail('missing-case'), throwsStateError);
  });
}
