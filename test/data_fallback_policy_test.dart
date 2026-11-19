import 'package:flutter_test/flutter_test.dart';
import 'package:preamble/data/cases/case_api_service.dart';
import 'package:preamble/data/cases/case_models.dart';
import 'package:preamble/data/cases/case_repository.dart';
import 'package:preamble/data/common/data_fallback_policy.dart';
import 'package:preamble/data/moj/moj_feed_item.dart';
import 'package:preamble/data/moj/moj_feed_service.dart';
import 'package:preamble/data/official/official_feed_api_service.dart';
import 'package:preamble/data/official/official_feed_repository.dart';
import 'package:preamble/data/search/search_api_service.dart';
import 'package:preamble/data/search/search_models.dart';
import 'package:preamble/data/search/search_repository.dart';
import 'package:preamble/data/statutes/statute_api_service.dart';
import 'package:preamble/data/statutes/statute_item.dart';
import 'package:preamble/data/statutes/statute_repository.dart';

// 台灣繁體中文教學註解：用可切換的假遠端明確區分「成功但空」與「請求失敗」。
// 測試不連線正式後端，因此失敗時不會被網路狀態或展示資料內容影響。
class _CaseApi extends CaseApiService {
  _CaseApi({bool configured = true})
      : super(baseUrl: configured ? 'https://example.test' : '');

  bool fail = false;

  @override
  Future<List<LawCase>> fetchFeaturedCases() async {
    if (fail) throw StateError('case offline');
    return const [];
  }

  @override
  Future<LawCase> getCaseDetail(String id) async =>
      throw StateError('case offline');
}

class _StatuteApi extends StatuteApiService {
  bool fail = false;

  @override
  Future<List<StatuteItem>> fetchChineseLawItems() async {
    if (fail) throw StateError('statute offline');
    return const [];
  }
}

class _OfficialApi extends OfficialFeedApiService {
  _OfficialApi({bool configured = true})
      : super(baseUrl: configured ? 'https://example.test' : '');

  bool fail = false;

  @override
  Future<List<MojFeedItem>> fetchNews() async {
    if (fail) throw StateError('official offline');
    return const [];
  }
}

class _MojFeed extends MojFeedService {
  int calls = 0;

  @override
  Future<List<MojFeedItem>> fetchItems(MojFeedCategory category) async {
    calls++;
    return [
      MojFeedItem(
        title: 'MOJ 正式來源',
        url: 'https://www.moj.gov.tw/',
        category: category,
        index: 1,
      ),
    ];
  }
}

class _SearchApi extends SearchApiService {
  _SearchApi({bool configured = true})
      : super(baseUrl: configured ? 'https://example.test' : '');

  bool fail = false;

  @override
  Future<List<SearchResultItem>> searchAll(String query, {String? type}) async {
    if (fail) throw StateError('search offline');
    return const [];
  }
}

SearchResultItem _seedResult() => SearchResultItem(
      id: 'local-deposit',
      title: '押金本機結果',
      subtitle: '示範',
      snippet: '押金',
      type: SearchResultType.document,
      destination: 'documents:deposit',
      score: 10,
      source: 'local',
      updatedAt: DateTime(2026),
    );

void main() {
  test('政策明確區分未設定、空結果及遠端錯誤', () {
    for (final reason in DataFallbackReason.values) {
      expect(DataFallbackPolicy.demo.allows(reason), isTrue);
      expect(DataFallbackPolicy.strict.allows(reason), isFalse);
    }
    expect(DataFallbackPolicy.liveWhenConfigured.onUnconfigured, isTrue);
    expect(DataFallbackPolicy.liveWhenConfigured.onRemoteEmpty, isFalse);
    expect(DataFallbackPolicy.liveWhenConfigured.onRemoteError, isFalse);
  });

  test('案件預設尊重正式空結果及錯誤；demo 明確允許回退', () async {
    final api = _CaseApi();
    addTearDown(api.dispose);
    final demo = CaseRepository(
        apiService: api, fallbackPolicy: DataFallbackPolicy.demo);
    final live = CaseRepository(apiService: api);
    final strict = CaseRepository(
      apiService: api,
      fallbackPolicy: DataFallbackPolicy.strict,
    );
    expect(await demo.fetchFeaturedCases(), isNotEmpty);
    expect(await live.fetchFeaturedCases(), isEmpty);
    expect(await strict.fetchFeaturedCases(), isEmpty);
    api.fail = true;
    expect(await demo.fetchFeaturedCases(), isNotEmpty);
    await expectLater(live.fetchFeaturedCases(), throwsA(isA<StateError>()));
    await expectLater(strict.fetchFeaturedCases(), throwsA(isA<StateError>()));
    await expectLater(
        strict.getCaseDetail('missing'), throwsA(isA<StateError>()));
  });

  test('案件未設定後端時 demo 回退、strict 明確報錯', () async {
    final api = _CaseApi(configured: false);
    addTearDown(api.dispose);
    expect(
        await CaseRepository(apiService: api).fetchFeaturedCases(), isNotEmpty);
    await expectLater(
      CaseRepository(apiService: api, fallbackPolicy: DataFallbackPolicy.strict)
          .fetchFeaturedCases(),
      throwsA(isA<DataSourceUnavailableException>()),
    );
  });

  test('法規成功空清單不改用 mock；只有 demo 在錯誤時回退', () async {
    final api = _StatuteApi();
    addTearDown(api.dispose);
    final demo = StatuteRepository(
        apiService: api, fallbackPolicy: DataFallbackPolicy.demo);
    final live = StatuteRepository(apiService: api);
    final strict = StatuteRepository(
      apiService: api,
      fallbackPolicy: DataFallbackPolicy.strict,
    );
    expect(await demo.fetchAllStatutes(), isEmpty);
    expect(await live.fetchAllStatutes(), isEmpty);
    expect(await strict.fetchAllStatutes(), isEmpty);
    api.fail = true;
    expect(await demo.fetchAllStatutes(forceRefresh: true), isNotEmpty);
    await expectLater(
        live.fetchAllStatutes(forceRefresh: true), throwsA(isA<StateError>()));
    await expectLater(
      strict.fetchAllStatutes(forceRefresh: true),
      throwsA(isA<StateError>()),
    );
  });

  test('官方消息預設保留正式空結果；demo 明確允許 MOJ 回退', () async {
    final api = _OfficialApi();
    final moj = _MojFeed();
    addTearDown(api.dispose);
    addTearDown(moj.dispose);
    final demo = OfficialFeedRepository(
        apiService: api,
        mojFeedService: moj,
        fallbackPolicy: DataFallbackPolicy.demo);
    final live = OfficialFeedRepository(apiService: api, mojFeedService: moj);
    final strict = OfficialFeedRepository(
      apiService: api,
      mojFeedService: moj,
      fallbackPolicy: DataFallbackPolicy.strict,
    );
    expect((await demo.fetchOfficialNews()).single.title, 'MOJ 正式來源');
    expect(await live.fetchOfficialNews(), isEmpty);
    expect(await strict.fetchOfficialNews(), isEmpty);
    api.fail = true;
    expect((await demo.fetchOfficialNews()).single.title, 'MOJ 正式來源');
    await expectLater(live.fetchOfficialNews(), throwsA(isA<StateError>()));
    await expectLater(strict.fetchOfficialNews(), throwsA(isA<StateError>()));
    expect(moj.calls, 2);
  });

  test('官方消息未設定後端時 strict 不顯示替代來源', () async {
    final api = _OfficialApi(configured: false);
    final moj = _MojFeed();
    addTearDown(api.dispose);
    addTearDown(moj.dispose);
    final repository = OfficialFeedRepository(
      apiService: api,
      mojFeedService: moj,
      fallbackPolicy: DataFallbackPolicy.strict,
    );
    await expectLater(
      repository.fetchOfficialNews(),
      throwsA(isA<DataSourceUnavailableException>()),
    );
    expect(moj.calls, 0);
  });

  test('搜尋 strict 不把遠端空結果或錯誤換成本機索引', () async {
    final api = _SearchApi();
    addTearDown(api.dispose);
    final statuteApi = _StatuteApi();
    addTearDown(statuteApi.dispose);
    final caseRepository = CaseRepository(seedCases: const []);
    final statuteRepository = StatuteRepository(apiService: statuteApi);
    addTearDown(caseRepository.dispose);
    addTearDown(statuteRepository.dispose);
    final demo = SearchRepository(
      searchApiService: api,
      caseRepository: caseRepository,
      statuteRepository: statuteRepository,
      seedResults: [_seedResult()],
      fallbackPolicy: DataFallbackPolicy.demo,
    );
    final live =
        SearchRepository(searchApiService: api, seedResults: [_seedResult()]);
    final strict = SearchRepository(
      searchApiService: api,
      fallbackPolicy: DataFallbackPolicy.strict,
      seedResults: [_seedResult()],
    );
    addTearDown(demo.dispose);
    addTearDown(live.dispose);
    addTearDown(strict.dispose);
    expect(
        (await demo.searchAll('押金')).any((item) => item.id == 'local-deposit'),
        isTrue);
    expect(await live.searchAll('押金'), isEmpty);
    expect(await strict.searchAll('押金'), isEmpty);
    api.fail = true;
    await expectLater(live.searchAll('押金'), throwsA(isA<StateError>()));
    await expectLater(strict.searchAll('押金'), throwsA(isA<StateError>()));
  });

  test('搜尋未設定後端時 strict 明確報錯', () async {
    final api = _SearchApi(configured: false);
    addTearDown(api.dispose);
    final repository = SearchRepository(
      searchApiService: api,
      fallbackPolicy: DataFallbackPolicy.strict,
    );
    addTearDown(repository.dispose);
    await expectLater(
      repository.searchAll('押金'),
      throwsA(isA<DataSourceUnavailableException>()),
    );
  });
}
