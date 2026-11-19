import 'dart:async';
import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:preamble/data/auth/auth_service.dart';
import 'package:preamble/data/cases/case_api_service.dart';
import 'package:preamble/data/cases/case_repository.dart';
import 'package:preamble/data/official/official_feed_api_service.dart';
import 'package:preamble/data/official/official_feed_repository.dart';
import 'package:preamble/data/search/search_api_service.dart';
import 'package:preamble/data/search/search_repository.dart';
import 'package:preamble/data/statutes/statute_api_service.dart';
import 'package:preamble/data/statutes/statute_repository.dart';
import 'package:preamble/data/user/quota_api_service.dart';

void main() {
  group('BackendAuthService & 401 Interceptor Tests', () {
    test('signInDemoMember returns user and updates token', () async {
      final client = MockClient((request) async {
        expect(request.url.path, '/auth/demo/member');
        expect(request.method, 'POST');
        return http.Response(
          jsonEncode({
            'token': 'jwt-member-123',
            'user': {
              'id': 'u_member_1',
              'displayName': '測試會員',
              'email': 'member@example.com',
              'accessTier': 'member',
              'createdAt': '2026-05-05T00:00:00Z',
              'updatedAt': '2026-05-05T00:00:00Z',
              'usageQuota': 20,
              'usedQuotaToday': 2,
            }
          }),
          200,
          headers: {'content-type': 'application/json; charset=utf-8'},
        );
      });

      final service = BackendAuthService(
        client: client,
        baseUrl: 'https://api.preamble.local',
      );

      final user = await service.signInDemoMember();
      expect(user.displayName, '測試會員');
      expect(user.isMember, true);
      expect(service.token, 'jwt-member-123');
    });

    test(
        'AuthHttpClient 401 Interceptor automatically refreshes token and retries request',
        () async {
      var requestCount = 0;
      var refreshCalled = false;

      final client = MockClient((request) async {
        if (request.url.path == '/auth/refresh') {
          refreshCalled = true;
          return http.Response(
            jsonEncode({'token': 'new-jwt-token-456'}),
            200,
            headers: {'content-type': 'application/json; charset=utf-8'},
          );
        }

        requestCount++;
        if (requestCount == 1) {
          // 首次請求回傳 401
          expect(request.headers['Authorization'], 'Bearer old-token');
          return http.Response(
            jsonEncode({'message': 'Token expired'}),
            401,
            headers: {'content-type': 'application/json; charset=utf-8'},
          );
        } else {
          // 重試請求帶入新 Token
          expect(request.headers['Authorization'], 'Bearer new-jwt-token-456');
          return http.Response(
            jsonEncode({
              'id': 'u_member_1',
              'displayName': '刷新後會員',
              'accessTier': 'member',
            }),
            200,
            headers: {'content-type': 'application/json; charset=utf-8'},
          );
        }
      });

      final service = BackendAuthService(
        client: client,
        baseUrl: 'https://api.preamble.local',
        initialToken: 'old-token',
      );

      final user = await service.refreshUser();
      expect(refreshCalled, true);
      expect(requestCount, 2);
      expect(user?.displayName, '刷新後會員');
      expect(service.token, 'new-jwt-token-456');
    });

    test('並發 401 共用一次刷新，且兩個請求都使用新 Token', () async {
      var token = 'old-token';
      var refreshCount = 0;
      final refreshGate = Completer<void>();
      final client = AuthHttpClient(
        inner: MockClient((request) async {
          if (request.headers['Authorization'] == 'Bearer old-token') {
            return http.Response('', 401);
          }
          expect(request.headers['Authorization'], 'Bearer new-token');
          return http.Response('ok', 200);
        }),
        tokenGetter: () => token,
        onRefreshToken: () async {
          refreshCount++;
          await refreshGate.future;
          token = 'new-token';
          return token;
        },
      );

      final first = client.get(Uri.parse('https://example.test/one'));
      final second = client.get(Uri.parse('https://example.test/two'));
      await Future<void>.delayed(Duration.zero);
      expect(refreshCount, 1);
      refreshGate.complete();
      final responses = await Future.wait([first, second]);
      expect(responses.map((response) => response.statusCode), [200, 200]);
      expect(refreshCount, 1);
      client.close();
    });

    test('不可重送的串流請求收到 401 時保留原回應', () async {
      var refreshCount = 0;
      var sendCount = 0;
      final client = AuthHttpClient(
        inner: MockClient((request) async {
          sendCount++;
          return http.Response('', 401);
        }),
        tokenGetter: () => 'old-token',
        onRefreshToken: () async {
          refreshCount++;
          return 'new-token';
        },
      );
      final request = http.StreamedRequest(
        'POST',
        Uri.parse('https://example.test/upload'),
      );
      request.sink.add(utf8.encode('payload'));
      // 台灣繁體中文教學註解：先送出請求讓 MockClient 訂閱 stream；
      // 若在 send 前等待 sink.close()，沒有讀取者時測試會永久等待。
      unawaited(request.sink.close());

      final response = await client.send(request);
      expect(response.statusCode, 401);
      expect(sendCount, 1);
      expect(refreshCount, 0);
      client.close();
    });

    test('外部指定的授權標頭不觸發受管理 Token 刷新', () async {
      var refreshCount = 0;
      final client = AuthHttpClient(
        inner: MockClient((request) async {
          expect(request.headers['Authorization'], 'Bearer external-token');
          return http.Response('', 401);
        }),
        tokenGetter: () => 'managed-token',
        onRefreshToken: () async {
          refreshCount++;
          return 'new-managed-token';
        },
      );
      final response = await client.get(
        Uri.parse('https://example.test/external'),
        headers: {'Authorization': 'Bearer external-token'},
      );
      expect(response.statusCode, 401);
      expect(refreshCount, 0);
      client.close();
    });
  });

  group('CaseApiService & CaseRepository Fallback Tests', () {
    test('CaseApiService parses featured cases correctly', () async {
      final client = MockClient((request) async {
        expect(request.url.path, '/cases/featured');
        return http.Response(
          jsonEncode({
            'cases': [
              {
                'id': 'remote-case-1',
                'title:': '遠端精選案件',
                'title': '遠端精選案件',
                'subtitle': '測試副標題',
                'summary': '測試摘要',
                'oneSentenceTakeaway': '測試核心點',
                'country': '台灣',
                'happenedAt': '2026-01-01T00:00:00Z',
                'updatedAt': '2026-05-05T00:00:00Z',
                'status': '確定判決',
                'category': '民事',
                'tags': ['租屋'],
                'era': '2020s',
                'timeline': [],
                'legalIssues': [],
                'sourceLinks': [],
              }
            ]
          }),
          200,
          headers: {'content-type': 'application/json; charset=utf-8'},
        );
      });

      final apiService = CaseApiService(
        client: client,
        baseUrl: 'https://api.preamble.local',
      );

      final cases = await apiService.fetchFeaturedCases();
      expect(cases.length, 1);
      expect(cases.first.id, 'remote-case-1');
      expect(cases.first.title, '遠端精選案件');
    });

    test(
        'CaseRepository seamlessly falls back to mock cases when backend fails',
        () async {
      final client = MockClient((request) async {
        return http.Response('Server Error', 500);
      });

      final apiService = CaseApiService(
        client: client,
        baseUrl: 'https://api.preamble.local',
      );
      final repository = CaseRepository(apiService: apiService);

      final cases = await repository.fetchFeaturedCases();
      expect(cases.isNotEmpty, true);
      expect(cases.first.id, 'nylon-cheng-1989');
    });
  });

  group('SearchApiService & SearchRepository Tests', () {
    test('SearchApiService parses unified search results', () async {
      final client = MockClient((request) async {
        expect(request.url.path, '/search');
        expect(request.url.queryParameters['q'], '租屋');
        return http.Response(
          jsonEncode({
            'results': [
              {
                'id': 'remote-search-1',
                'title': '租屋押金說明',
                'subtitle': '民事/租屋',
                'snippet': '線上搜尋結果',
                'type': 'statute',
                'destination': 'statutes:民法:421',
                'score': 90.0,
                'source': '緒言 Preamble backend',
                'updatedAt': '2026-05-05T00:00:00Z',
                'tags': ['租屋', '押金'],
              }
            ]
          }),
          200,
          headers: {'content-type': 'application/json; charset=utf-8'},
        );
      });

      final apiService = SearchApiService(
        client: client,
        baseUrl: 'https://api.preamble.local',
      );

      final results = await apiService.searchAll('租屋');
      expect(results.length, 1);
      expect(results.first.title, '租屋押金說明');
    });

    test(
        'SearchRepository falls back to multi-repository search when backend fails',
        () async {
      final client = MockClient((request) async {
        return http.Response('Network Error', 503);
      });

      final apiService = SearchApiService(
        client: client,
        baseUrl: 'https://api.preamble.local',
      );
      final repository = SearchRepository(
        searchApiService: apiService,
        caseRepository: CaseRepository(
          apiService: CaseApiService(client: client),
        ),
        statuteRepository: StatuteRepository(
          apiService: StatuteApiService(client: client),
        ),
      );

      final results = await repository.searchAll('押金');
      expect(results.isNotEmpty, true);
    });
  });

  group('OfficialFeedApiService & QuotaApiService Tests', () {
    test('OfficialFeedApiService fetches official news items', () async {
      final client = MockClient((request) async {
        expect(request.url.path, '/official-feeds/news');
        return http.Response(
          jsonEncode({
            'items': [
              {
                'title': '法務部線上新聞發布',
                'url': 'https://www.moj.gov.tw/news/1',
                'index': 1,
              }
            ]
          }),
          200,
          headers: {'content-type': 'application/json; charset=utf-8'},
        );
      });

      final apiService = OfficialFeedApiService(
        client: client,
        baseUrl: 'https://api.preamble.local',
      );
      final repository = OfficialFeedRepository(apiService: apiService);

      final news = await repository.fetchOfficialNews();
      expect(news.length, 1);
      expect(news.first.title, '法務部線上新聞發布');
    });

    test('QuotaApiService fetches and consumes quota', () async {
      final client = MockClient((request) async {
        if (request.method == 'GET') {
          expect(request.url.path, '/quota');
          return http.Response(
            jsonEncode({'usageQuota': 20, 'usedQuotaToday': 5}),
            200,
            headers: {'content-type': 'application/json; charset=utf-8'},
          );
        } else {
          expect(request.url.path, '/quota/consume');
          final body = jsonDecode(request.body) as Map<String, dynamic>;
          expect(body['count'], 1);
          return http.Response(
            jsonEncode({'usageQuota': 20, 'usedQuotaToday': 6}),
            200,
            headers: {'content-type': 'application/json; charset=utf-8'},
          );
        }
      });

      final quotaService = QuotaApiService(
        client: client,
        baseUrl: 'https://api.preamble.local',
      );

      final info = await quotaService.fetchQuota();
      expect(info.usageQuota, 20);
      expect(info.usedQuotaToday, 5);
      expect(info.remainingQuota, 15);

      final updated = await quotaService.consumeQuota(count: 1);
      expect(updated.usedQuotaToday, 6);
      expect(updated.remainingQuota, 14);
    });
  });
}
