import 'package:preamble/data/statutes/statute_api_service.dart';
import 'package:preamble/data/statutes/statute_item.dart';
import 'package:preamble/data/common/data_fallback_policy.dart';

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
/// API service 只負責抓 MOJ 原始資料；搜尋、快取、mock fallback 放在 repository，
/// 讓 UI 可以穩定處理 loading/error/empty，而不是每個頁面自己 try/catch。
class StatuteRepository {
  StatuteRepository({
    StatuteApiService? apiService,
    this.fallbackPolicy = DataFallbackPolicy.liveWhenConfigured,
  })  : _apiService = apiService ?? StatuteApiService(),
        _ownsApiService = apiService == null;

  final StatuteApiService _apiService;
  final DataFallbackPolicy fallbackPolicy;
  // 台灣繁體中文教學註解：外部注入的 service 可被其他 repository 共用，不由此處關閉。
  final bool _ownsApiService;
  // 台灣繁體中文教學註解：全國法規資料庫壓縮檔體積較大，改以跨實例靜態記憶體快取與共用請求，
  // 避免每次切換頁面都重新下載解析。
  static List<StatuteItem>? _sharedCache;
  static Future<List<StatuteItem>>? _sharedInFlight;
  List<StatuteItem>? _instanceCache;

  Future<List<StatuteItem>> fetchAllStatutes(
      {bool forceRefresh = false}) async {
    if (!forceRefresh && _instanceCache != null) return _instanceCache!;
    if (!forceRefresh && _ownsApiService && _sharedCache != null) {
      return _sharedCache!;
    }

    try {
      if (_ownsApiService) {
        final future =
            (!forceRefresh ? _sharedInFlight : null) ??
                _apiService.fetchChineseLawItems();
        _sharedInFlight = future;
        final items = await future;
        _sharedCache = items;
        _instanceCache = items;
        return items;
      } else {
        _instanceCache = await _apiService.fetchChineseLawItems();
        return _instanceCache!;
      }
    } catch (__) {
      // 台灣繁體中文教學註解：法規 API 沒有「未設定後端」分支；成功的空清單
      // 一律照實回傳。只有讀取錯誤且政策允許時才降級至內建法規。
      if (!fallbackPolicy.onRemoteError) rethrow;
      _instanceCache = _mockStatutes;
      return _instanceCache!;
    } finally {
      if (_ownsApiService) {
        _sharedInFlight = null;
      }
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
    if (_ownsApiService) _apiService.dispose();
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
    tags: ['網購', '七日鑑賞期', '7天鑑賞期', '網購7天鑑賞期'],
    plainLanguageSummary: '多數網購情境可在收受商品後七日內主張解除契約，但仍有例外。',
    relatedKeywords: ['退貨', '消費爭議', '7天'],
  ),
  StatuteItem(
    codeName: '消費者保護法',
    articleNumber: '第 19 條之 2',
    articleText:
        '消費者依第十九條第一項規定解除契約者，除依第七條之二規定或契約另有約定外，企業經營者應於收到退回商品或解除契約通知後十五日內，返還價金。',
    lawUrl: 'https://law.moj.gov.tw/LawClass/LawAll.aspx?pcode=J0170001',
    category: '法律',
    updatedDate: '2025-12-31',
    isRepealed: false,
    tags: ['網購', '七日鑑賞期', '退款期限', '7天', '7天鑑賞期', '網購7天鑑賞期'],
    plainLanguageSummary: '退回商品或解除契約後，賣家應在收到退貨或通知後 15 天內返還退款。',
    relatedKeywords: ['退款', '消費爭議', '十五日'],
  ),
  StatuteItem(
    codeName: '民法',
    articleNumber: '第 259 條',
    articleText:
        '契約解除時，當事人雙方回復原狀之義務，除法律另有規定或契約另有訂定外，依左列之規定：一、由他方受領之給付物，應返還之。二、受領之給付為金錢者，應附加自受領時起之利息償還之。...',
    lawUrl: 'https://law.moj.gov.tw/LawClass/LawAll.aspx?pcode=B0000001',
    category: '法律',
    updatedDate: '2025-12-31',
    isRepealed: false,
    tags: ['契約解除', '回復原狀', '退貨退款', '7天', '7天鑑賞期', '網購7天鑑賞期'],
    plainLanguageSummary: '契約解除後，雙方負有回復原狀義務，即買家應退還商品，賣家應退還價金。',
    relatedKeywords: ['解除契約', '返還給付', '退費'],
  ),
  StatuteItem(
    codeName: '中華民國刑法',
    articleNumber: '第 339 條',
    articleText: '意圖為自己或第三人不法之所有，以詐術使人將本人或第三人之物交付者，處五年以下有期徒刑、拘役或科或併科五十萬元以下罰金。',
    lawUrl: 'https://law.moj.gov.tw/LawClass/LawAll.aspx?pcode=C0000001',
    category: '法律',
    updatedDate: '2025-12-31',
    isRepealed: false,
    tags: ['詐欺罪', '財產犯罪'],
    plainLanguageSummary: '如果故意使用欺騙手段（施用詐術）騙取他人財物，即可能構成刑事詐欺罪。',
    relatedKeywords: ['詐欺', '詐騙', '騙錢'],
  ),
  StatuteItem(
    codeName: '民法',
    articleNumber: '第 421 條',
    articleText: '稱租賃者，謂當事人約定，一方以物租與他方使用收益，他方支付租金之契約。',
    lawUrl: 'https://law.moj.gov.tw/LawClass/LawAll.aspx?pcode=B0000001',
    category: '法律',
    updatedDate: '2025-12-31',
    isRepealed: false,
    tags: ['租賃契約', '租屋'],
    plainLanguageSummary: '租屋是一種租賃關係，雙方約定房東提供房子給房客使用，房客則需要定期支付租金。',
    relatedKeywords: ['租屋糾紛', '押金', '房東', '退租'],
  ),
];
