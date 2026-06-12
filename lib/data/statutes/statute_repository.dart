import 'package:lawapp/data/statutes/statute_api_service.dart';
import 'package:lawapp/data/statutes/statute_item.dart';

class StatuteSearchResult {
  const StatuteSearchResult({
    required this.items,
    required this.isMock,
    this.errorMessage,
  });

  final List<StatuteItem> items;
  final bool isMock;
  final String? errorMessage;
}

/// 法規資料 repository。
///
/// 台灣繁體中文教學註解：
/// API service 只負責抓 MOJ 原始資料；搜尋、快取、mock fallback 放在 repository，
/// 讓 UI 可以穩定處理 loading/error/empty，而不是每個頁面自己 try/catch。
class StatuteRepository {
  StatuteRepository({StatuteApiService? apiService})
      : _apiService = apiService ?? StatuteApiService();

  final StatuteApiService _apiService;
  List<StatuteItem>? _cache;

  Future<List<StatuteItem>> fetchAllStatutes(
      {bool forceRefresh = false}) async {
    if (!forceRefresh && _cache != null) return _cache!;

    try {
      _cache = await _apiService.fetchChineseLawItems();
      return _cache!;
    } catch (__) {
      _cache = _mockStatutes;
      return _cache!;
    }
  }

  Future<StatuteSearchResult> searchStatutes({
    String query = '',
    String lawName = '',
    String articleNumber = '',
    String category = '',
    bool forceRefresh = false,
  }) async {
    final items = await fetchAllStatutes(forceRefresh: forceRefresh);
    final results = items.where((item) {
      final matchesQuery = query.trim().isEmpty || item.matches(query);
      final matchesLaw =
          lawName.trim().isEmpty || item.codeName.contains(lawName.trim());
      final matchesArticle = articleNumber.trim().isEmpty ||
          item.articleNumber.contains(articleNumber.trim());
      final matchesCategory =
          category.trim().isEmpty || item.category.contains(category.trim());
      return matchesQuery &&
          matchesLaw &&
          matchesArticle &&
          matchesCategory &&
          !item.isRepealed;
    }).toList(growable: false);

    results.sort((a, b) => _score(b, query).compareTo(_score(a, query)));
    return StatuteSearchResult(
      items: results,
      isMock: identical(items, _mockStatutes),
    );
  }

  void dispose() {
    _apiService.dispose();
  }

  int _score(StatuteItem item, String query) {
    if (query.trim().isEmpty) return 0;
    var score = 0;
    for (final token in query.split(RegExp(r'\s+'))) {
      if (item.codeName.contains(token)) score += 10;
      if (item.articleNumber.contains(token)) score += 8;
      if (item.articleText.contains(token)) score += 3;
      if (item.tags.any((tag) => tag.contains(token))) score += 2;
    }
    return score;
  }
}

const _mockStatutes = [
  StatuteItem(
    codeName: '民法',
    articleNumber: '第 184 條',
    articleText: '因故意或過失，不法侵害他人之權利者，負損害賠償責任。',
    lawUrl: 'https://law.moj.gov.tw/LawClass/LawAll.aspx?pcode=B0000001',
    category: '法律',
    updatedDate: '2025-12-31',
    isRepealed: false,
    tags: ['侵權行為', '損害賠償'],
    plainLanguageSummary: '如果因故意或過失侵害他人權利，可能需要負損害賠償責任。',
    relatedKeywords: ['車禍', '損害', '賠償'],
  ),
  StatuteItem(
    codeName: '勞動基準法',
    articleNumber: '第 24 條',
    articleText: '雇主延長勞工工作時間者，其延長工作時間之工資依本條標準加給。',
    lawUrl: 'https://law.moj.gov.tw/LawClass/LawAll.aspx?pcode=N0030001',
    category: '法律',
    updatedDate: '2025-12-31',
    isRepealed: false,
    tags: ['加班費', '工時'],
    plainLanguageSummary: '公司要求加班時，通常需要依照法定標準給付加班費。',
    relatedKeywords: ['加班', '補休', '薪資'],
  ),
  StatuteItem(
    codeName: '消費者保護法',
    articleNumber: '第 19 條',
    articleText: '通訊交易或訪問交易之消費者，得於收受商品或接受服務後七日內解除契約。',
    lawUrl: 'https://law.moj.gov.tw/LawClass/LawAll.aspx?pcode=J0170001',
    category: '法律',
    updatedDate: '2025-12-31',
    isRepealed: false,
    tags: ['網購', '七日鑑賞期'],
    plainLanguageSummary: '多數網購情境可在收受商品後七日內主張解除契約，但仍有例外。',
    relatedKeywords: ['退貨', '消費爭議'],
  ),
];
