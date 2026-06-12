import 'package:flutter_test/flutter_test.dart';
import 'package:lawapp/app/app_state.dart';
import 'package:lawapp/data/auth/auth_service.dart';
import 'package:lawapp/data/cases/case_models.dart';
import 'package:lawapp/data/cases/case_repository.dart';
import 'package:lawapp/data/documents/document_models.dart';
import 'package:lawapp/data/documents/document_repository.dart';
import 'package:lawapp/data/following/following_repository.dart';
import 'package:lawapp/data/journal/journal_repository.dart';
import 'package:lawapp/data/law_assistant/law_assistant_repository.dart';
import 'package:lawapp/data/search/search_models.dart';
import 'package:lawapp/data/search/search_repository.dart';
import 'package:lawapp/data/statutes/statute_api_service.dart';
import 'package:lawapp/data/statutes/statute_item.dart';
import 'package:lawapp/data/statutes/statute_repository.dart';
import 'package:lawapp/data/user/law_app_user.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  test('LawAppUser parses quota and access tier', () {
    final user = LawAppUser.fromJson({
      'id': 'u1',
      'displayName': '小明',
      'email': 'ming@example.test',
      'accessTier': 'subscriber',
      'createdAt': '2026-05-05T00:00:00Z',
      'updatedAt': '2026-05-05T00:00:00Z',
      'usageQuota': 200,
      'usedQuotaToday': 3,
      'savedCaseIds': ['case-a'],
    });

    expect(user.accessTier, LawAppAccessTier.subscriber);
    expect(user.remainingAiQuota, 197);
    expect(user.savedCaseIds, ['case-a']);
  });

  test('LawAppState centralizes permissions', () async {
    SharedPreferences.setMockInitialValues({});
    final appState = LawAppState(authService: DemoAuthService());
    addTearDown(appState.dispose);

    await appState.load();
    expect(appState.canSaveCase, isFalse);
    expect(appState.remainingAiQuota, 1);

    await appState.setStatuteFollowed('statute-民法第184條', true);
    await appState.setStatuteSaved('statute-民法第184條', true);
    expect(appState.isStatuteFollowed('statute-民法第184條'), isTrue);
    expect(appState.isStatuteSaved('statute-民法第184條'), isTrue);

    await appState.activateSubscriberDemo();
    expect(appState.canGenerateDocument, isTrue);
    expect(appState.canUseAdvancedSearch, isTrue);
  });

  test('LawAssistantRepository returns mock conversation without backend',
      () async {
    final repository = LawAssistantRepository();
    addTearDown(repository.dispose);

    final conversation = await repository.createConversation(
      prompt: '房東不退押金怎麼辦？',
      isGuestSession: true,
    );

    expect(repository.isBackendConfigured, isFalse);
    expect(conversation.isMock, isTrue);
    expect(conversation.messages.last.answer?.evidenceNeeded, isNotEmpty);
    expect(conversation.messages.last.citations, isNotEmpty);
  });

  test('StatuteRepository searches and filters local service results',
      () async {
    final repository = StatuteRepository(
      apiService: _FakeStatuteApiService([
        _statute('民法', '第 184 條', '侵權行為與損害賠償'),
        _statute('勞動基準法', '第 24 條', '延長工作時間工資'),
      ]),
    );

    final result = await repository.searchStatutes(query: '民法 184');

    expect(result.items, hasLength(1));
    expect(result.items.single.codeName, '民法');
  });

  test('CaseRepository filters by era and search query', () async {
    final repository = CaseRepository(seedCases: [_case('c1', '2010s')]);

    expect(await repository.filterByEra('2010s'), hasLength(1));
    expect(await repository.searchCases('太陽花'), hasLength(1));
    expect(await repository.searchCases('不存在'), isEmpty);
  });

  test('SearchRepository returns mixed results', () async {
    final searchRepository = SearchRepository(
      caseRepository: CaseRepository(seedCases: [_case('c1', '2010s')]),
      statuteRepository: StatuteRepository(
        apiService: _FakeStatuteApiService([
          _statute('民法', '第 184 條', '侵權行為與損害賠償'),
        ]),
      ),
      seedResults: [
        SearchResultItem(
          id: 'tool-1',
          title: '小法助',
          subtitle: 'AI',
          snippet: '押金問題可以先問小法助',
          type: SearchResultType.assistant,
          destination: 'assistant',
          score: 10,
          source: 'LawApp',
          updatedAt: DateTime(2026, 5, 5),
          tags: const ['押金'],
        ),
      ],
    );

    final results = await searchRepository.searchAll('押金');
    final statuteResults = await searchRepository.searchAll('民法 184');
    final journalResults = await searchRepository.searchAll('公共安全');

    expect(
        results.map((item) => item.type), contains(SearchResultType.assistant));
    expect(
        results.map((item) => item.type), contains(SearchResultType.caseItem));
    final statuteResult = statuteResults.firstWhere(
      (item) => item.type == SearchResultType.statute,
    );
    expect(statuteResult.officialUrl, 'https://law.moj.gov.tw/');
    expect(statuteResult.preferredSourceUrl, 'https://law.moj.gov.tw/');
    expect(journalResults.map((item) => item.title), contains('台鐵太魯閣號列車出軌事故案'));
  });

  test('JournalRepository searches trends, dossiers, and case books', () async {
    const repository = JournalRepository();

    final fraudResults = await repository.searchJournal('詐騙');
    final publicSafetyResults = await repository.searchJournal('公共安全');

    // 台灣繁體中文教學註解：
    // 記事搜尋同時涵蓋首頁趨勢、資料館動態與案件時光機書籍；
    // 這裡守住資料層索引，避免之後 UI 各自重新實作關鍵字比對。
    expect(fraudResults.map((item) => item.title), contains('詐騙車手與洗錢鏈'));
    expect(
      fraudResults.map((item) => item.type),
      contains(JournalSearchResultType.trend),
    );
    expect(
      publicSafetyResults.map((item) => item.type),
      contains(JournalSearchResultType.caseBook),
    );
  });

  test('DocumentRepository creates local template draft', () async {
    final repository = DocumentRepository(baseUrl: '');

    final draft = await repository.createDraft(
      templateType: DocumentTemplateType.consumerComplaint,
      input: const DocumentTemplateInput(
        senderName: '王小明',
        receiverName: '店家',
        facts: '網購商品有瑕疵，客服尚未回覆。',
      ),
    );

    expect(draft.isMock, isTrue);
    expect(draft.content, contains('消費爭議'));
    expect(draft.disclaimer, contains('不構成正式法律意見'));
    // 台灣繁體中文教學註解：
    // 工具箱與「我的 LawApp」都讀同一個 repository 清單；這裡守住建立後會立刻
    // 寫進前端共用資料來源，避免兩個頁面又各自長出一份草稿假資料。
    expect(repository.drafts.map((item) => item.id), contains(draft.id));
    expect(repository.backendStatusLabel, contains('本機暫存模式'));
  });

  test('FollowingRepository can follow and unfollow items', () async {
    final repository = FollowingRepository();

    await repository.followCase('case-a');
    var summary = await repository.getFollowingSummary();
    expect(summary.followedCaseIds, ['case-a']);

    await repository.unfollowCase('case-a');
    summary = await repository.getFollowingSummary();
    expect(summary.followedCaseIds, isEmpty);

    await repository.saveStatute('statute-a');
    summary = await repository.getFollowingSummary();
    expect(summary.savedStatuteIds, ['statute-a']);
  });
}

class _FakeStatuteApiService extends StatuteApiService {
  _FakeStatuteApiService(this.items);

  final List<StatuteItem> items;

  @override
  Future<List<StatuteItem>> fetchChineseLawItems() async => items;

  @override
  void dispose() {}
}

StatuteItem _statute(String lawName, String article, String text) {
  return StatuteItem(
    codeName: lawName,
    articleNumber: article,
    articleText: text,
    lawUrl: 'https://law.moj.gov.tw/',
    category: '法律',
    updatedDate: '2026-05-05',
    isRepealed: false,
    tags: [lawName, article],
  );
}

LawCase _case(String id, String era) {
  return LawCase(
    id: id,
    title: '太陽花運動相關案件',
    subtitle: '社會運動',
    summary: '押金以外的案件資料示範',
    oneSentenceTakeaway: '公共抗爭也會進入司法程序。',
    country: '台灣',
    location: '台北',
    happenedAt: DateTime(2014, 3, 18),
    updatedAt: DateTime(2026, 5, 5),
    status: 'mock',
    category: '公民抗爭',
    tags: const ['太陽花', '押金'],
    era: era,
  );
}
