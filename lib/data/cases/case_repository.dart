import 'package:preamble/data/cases/case_api_service.dart';
import 'package:preamble/data/cases/case_models.dart';

class CaseRepository {
  CaseRepository({
    List<LawCase>? seedCases,
    CaseApiService? apiService,
  })  : _cases = seedCases ?? _mockCases,
        _apiService = apiService ?? CaseApiService();

  final List<LawCase> _cases;
  final CaseApiService _apiService;
  final Set<String> _followedCaseIds = <String>{};

  Future<List<LawCase>> fetchFeaturedCases() async {
    if (_apiService.hasConfiguredBackend) {
      try {
        final remote = await _apiService.fetchFeaturedCases();
        if (remote.isNotEmpty) return remote;
      } catch (__) {
        // 降級回本機 Mock
      }
    }
    return _cases.take(3).toList(growable: false);
  }

  Future<List<LawCase>> fetchArchiveCases() async {
    if (_apiService.hasConfiguredBackend) {
      try {
        final remote = await _apiService.fetchArchiveCases();
        if (remote.isNotEmpty) return remote;
      } catch (__) {
        // 降級回本機 Mock
      }
    }
    return _cases;
  }

  Future<List<LawCase>> searchCases(String query) async {
    if (query.trim().isEmpty) return fetchArchiveCases();
    if (_apiService.hasConfiguredBackend) {
      try {
        final remote = await _apiService.searchCases(query);
        if (remote.isNotEmpty) return remote;
      } catch (__) {
        // 降級回本機 Mock
      }
    }
    return _cases.where((item) => item.matches(query)).toList(growable: false);
  }

  Future<List<LawCase>> filterByEra(String era) async {
    if (era.trim().isEmpty || era == '全部') return fetchArchiveCases();
    if (_apiService.hasConfiguredBackend) {
      try {
        final remote = await _apiService.fetchArchiveCases(era: era);
        if (remote.isNotEmpty) return remote;
      } catch (__) {
        // 降級回本機 Mock
      }
    }
    return _cases.where((item) => item.era == era).toList(growable: false);
  }

  Future<List<LawCase>> filterByCategory(String category) async {
    if (category.trim().isEmpty || category == '全部') return fetchArchiveCases();
    if (_apiService.hasConfiguredBackend) {
      try {
        final remote = await _apiService.fetchArchiveCases(category: category);
        if (remote.isNotEmpty) return remote;
      } catch (__) {
        // 降級回本機 Mock
      }
    }
    return _cases
        .where((item) => item.category.contains(category))
        .toList(growable: false);
  }

  Future<LawCase?> getCaseDetail(String id) async {
    if (_apiService.hasConfiguredBackend) {
      try {
        return await _apiService.getCaseDetail(id);
      } catch (__) {
        // 降級回本機 Mock
      }
    }
    for (final item in _cases) {
      if (item.id == id) return item;
    }
    return null;
  }

  Future<void> followCase(String id) async {
    _followedCaseIds.add(id);
  }

  Future<void> unfollowCase(String id) async {
    _followedCaseIds.remove(id);
  }

  Future<List<LawCase>> followedCases() async {
    return _cases
        .where((item) => _followedCaseIds.contains(item.id))
        .toList(growable: false);
  }

  void dispose() {
    _apiService.dispose();
  }
}

final _mockCases = [
  LawCase(
    id: 'nylon-cheng-1989',
    title: '鄭南榕事件',
    subtitle: '言論自由、民主運動與社會記憶',
    summary: '1989 年鄭南榕事件成為台灣民主化與言論自由的重要記憶座標。',
    oneSentenceTakeaway: '自由權保障常在具體事件中被社會重新確認。',
    country: '台灣',
    location: '台北市大安區',
    happenedAt: DateTime(1989, 4, 7),
    updatedAt: DateTime(2026, 5, 5),
    status: '歷史案件整理',
    category: '民主運動',
    tags: ['言論自由', '出版自由', '民主運動'],
    era: '1980s',
    discussionPoints: ['國家權力界線', '公共紀念', '自由權保障'],
    learningPoints: ['先分清楚事實、程序與後續社會影響。'],
    relatedStatutes: ['憲法第 11 條'],
    timeline: [
      LawCaseTimelineItem(
        date: DateTime(1989, 4, 7),
        title: '事件發生',
        description: '事件成為台灣言論自由與民主運動記憶的重要節點。',
      ),
    ],
    legalIssues: [
      LawCaseLegalIssue(
        title: '言論自由',
        explanation: '觀察國家追訴權與人民表意自由的界線。',
        relatedLawName: '中華民國憲法',
        relatedArticleNumber: '第 11 條',
      ),
    ],
    sourceLinks: [
      LawCaseSourceLink(
        title: '公開歷史資料',
        url: 'https://example.preamble.local/mock/nylon-cheng',
        sourceType: 'mock',
        publisher: '緒言 Preamble mock data',
        accessedAt: DateTime(2026, 5, 5),
      ),
    ],
  ),
  LawCase(
    id: 'sunflower-2014',
    title: '太陽花運動相關案件',
    subtitle: '社會運動、議事程序與司法評價',
    summary: '從佔領國會到後續訴訟，整理程序、刑責與公共討論如何互相影響。',
    oneSentenceTakeaway: '公共抗爭進入法院後，會被拆成程序、事實與刑責界線。',
    country: '台灣',
    location: '台北市中正區',
    happenedAt: DateTime(2014, 3, 18),
    updatedAt: DateTime(2026, 5, 5),
    status: '社會運動與司法程序',
    category: '公民抗爭',
    tags: ['集會自由', '議事程序', '公民不服從'],
    era: '2010s',
    discussionPoints: ['集會自由', '程序正義', '政治責任'],
    learningPoints: ['同一事件可同時有政治評價與法律評價。'],
    relatedStatutes: ['集會遊行法', '刑法'],
    timeline: [
      LawCaseTimelineItem(
        date: DateTime(2014, 3, 18),
        title: '議事程序爭議升溫',
        description: '服貿協議審查與程序透明度成為行動前背景。',
      ),
    ],
    legalIssues: [
      LawCaseLegalIssue(
        title: '刑事責任界線',
        explanation: '法院會檢視行為、目的、比例與阻卻違法可能性。',
        riskLevel: 'medium',
      ),
    ],
    sourceLinks: [
      LawCaseSourceLink(
        title: '法院公開裁判與新聞整理',
        url: 'https://example.preamble.local/mock/sunflower',
        sourceType: 'mock',
        publisher: '緒言 Preamble mock data',
        accessedAt: DateTime(2026, 5, 5),
      ),
    ],
  ),
  LawCase(
    id: 'fraud-money-laundering-recent',
    title: '詐騙車手與洗錢鏈',
    subtitle: '帳戶、人頭、提款與詐欺集團分工',
    summary: '理解近年詐欺案件為何高發，以及法院如何檢視角色分工。',
    oneSentenceTakeaway: '帳戶與提款行為是否知情，常是案件判斷核心。',
    country: '台灣',
    location: '全台',
    happenedAt: DateTime(2024),
    updatedAt: DateTime(2026, 5, 5),
    status: '偵查與起訴高發',
    category: '刑事 / 金融',
    tags: ['詐欺', '洗錢', '車手'],
    era: '近年熱議',
    discussionPoints: ['人頭帳戶', '洗錢防制', '幫助犯'],
    learningPoints: ['不要出租或出借帳戶，資金流向會成為偵查重點。'],
    relatedStatutes: ['刑法詐欺罪', '洗錢防制法'],
    legalIssues: [
      LawCaseLegalIssue(
        title: '主觀知情',
        explanation: '法院會看行為人是否知道帳戶或提款與詐欺款項有關。',
        riskLevel: 'high',
      ),
    ],
    sourceLinks: [
      LawCaseSourceLink(
        title: '司法院裁判書與警政宣導整理',
        url: 'https://example.preamble.local/mock/fraud-chain',
        sourceType: 'mock',
        publisher: '緒言 Preamble mock data',
        accessedAt: DateTime(2026, 5, 5),
      ),
    ],
  ),
  LawCase(
    id: 'tripartite-fraud-2025',
    title: '網拍三方詐騙損害賠償案',
    subtitle: '三方交易、不當得利與善意受讓',
    summary: '買家透過第三方平台向賣家下單，卻遭詐騙集團利用第三方金流轉帳，造成買家受害、賣家帳戶遭凍結。法院檢視不當得利與損害賠償責任。',
    oneSentenceTakeaway: '三方交易中，金流的真實流向與當事人的善意無過失是責任釐清關鍵。',
    country: '台灣',
    location: '台中市',
    happenedAt: DateTime(2025, 3, 15),
    updatedAt: DateTime(2026, 5, 5),
    status: '二審判決確定',
    category: '刑事 / 民事糾紛',
    tags: ['詐欺', '三方詐騙', '損害賠償', '不當得利'],
    era: '近年熱議',
    discussionPoints: ['三方交易法律風險', '第三方金流責任', '警示帳戶解凍'],
    learningPoints: ['網拍交易應儘量使用平台官方安全交易機制，避免私下轉帳或代收。'],
    relatedStatutes: ['刑法第 339 條', '民法第 184 條'],
    legalIssues: [
      LawCaseLegalIssue(
        title: '不當得利返還',
        explanation: '無法律上原因受利益致他人受損害者，應返還其利益。',
        riskLevel: 'medium',
      ),
    ],
    sourceLinks: [
      LawCaseSourceLink(
        title: '臺灣臺中地方法院民事判決',
        url: 'https://example.preamble.local/mock/tripartite-fraud',
        sourceType: 'mock',
        publisher: '緒言 Preamble mock data',
        accessedAt: DateTime(2026, 5, 5),
      ),
    ],
  ),
  LawCase(
    id: 'rental-deposit-2025',
    title: '租屋退租返還押金爭議案',
    subtitle: '押金返還義務、房屋折舊與點交爭議',
    summary:
        '租約期滿房客退租點交，房東主張房屋牆壁髒污與自然折舊修繕費用應由押金全額扣抵，房客向法院訴請全額返還押金。法院判決確認折舊與扣款範圍。',
    oneSentenceTakeaway: '自然折舊修繕費用不得任意扣減押金，房東僅能針對人為惡意毀損提出合理扣款。',
    country: '台灣',
    location: '新北市',
    happenedAt: DateTime(2025, 2, 28),
    updatedAt: DateTime(2026, 5, 5),
    status: '民事小額判決',
    category: '民事 / 租屋糾紛',
    tags: ['租屋糾紛', '租屋', '押金', '折舊'],
    era: '2020s',
    discussionPoints: ['點交紀錄之重要性', '自然折舊認定標準', '定金與押金區別'],
    learningPoints: ['退租點交時務必拍照存證並簽署點交協議書，避免事後爭議。'],
    relatedStatutes: ['民法第 421 條', '民法第 179 條'],
    legalIssues: [
      LawCaseLegalIssue(
        title: '押金返還請求權',
        explanation: '租賃關係消滅時，房東應返還未扣抵之押金餘額。',
        riskLevel: 'medium',
      ),
    ],
    sourceLinks: [
      LawCaseSourceLink(
        title: '臺灣新北地方法院民事判決',
        url: 'https://example.preamble.local/mock/rental-deposit',
        sourceType: 'mock',
        publisher: '緒言 Preamble mock data',
        accessedAt: DateTime(2026, 5, 5),
      ),
    ],
  ),
  LawCase(
    id: 'online-shopping-return-2025',
    title: '網購七日鑑賞期退換貨爭議案',
    subtitle: '消費者保護法第 19 條、通訊交易、解除契約',
    summary:
        '買家於網路平台購買商品，收受後六日內主張消保法第 19 條七日鑑賞期要求退貨退款。賣家以「商品已拆封、非屬瑕疵品」為由拒絕退款。法院判決解除契約合法，賣家應返還價金。',
    oneSentenceTakeaway: '通訊交易之消費者原則上享有七日無條件退貨權，賣家不得以拆封為由剝奪其權利。',
    country: '台灣',
    location: '台北市',
    happenedAt: DateTime(2025, 4, 10),
    updatedAt: DateTime(2026, 5, 5),
    status: '民事小額判決',
    category: '民事 / 消費糾紛',
    tags: ['網購', '七日鑑賞期', '退貨', '消費爭議', '7天', '7天鑑賞期', '網購7天鑑賞期'],
    era: '近年熱議',
    discussionPoints: ['合理例外情事之認定', '拆封是否影響退貨權', '解約之回復原狀'],
    learningPoints: ['網購商品收受後七日內可主張無條件退貨，但應注意保存包裝，避免惡意毀損。'],
    relatedStatutes: ['消費者保護法第 19 條'],
    legalIssues: [
      LawCaseLegalIssue(
        title: '通訊交易解除權',
        explanation: '消費者得於收受商品後七日內，以退回商品或書面通知方式解除契約，無須說明理由及負擔任何費用。',
        riskLevel: 'low',
      ),
    ],
    sourceLinks: [
      LawCaseSourceLink(
        title: '臺灣臺北地方法院民事判決',
        url: 'https://example.preamble.local/mock/consumer-return',
        sourceType: 'mock',
        publisher: '緒言 Preamble mock data',
        accessedAt: DateTime(2026, 5, 5),
      ),
    ],
  ),
  LawCase(
    id: 'used-goods-return-2026',
    title: '個人賣家二手拍賣七日鑑賞期排除案',
    subtitle: '消費者保護法第 2 條、通訊交易、企業經營者認定',
    summary:
        '買家於網路拍賣平台購買二手皮包，收受後主張七日鑑賞期要求退貨。賣家主張其為個人賣家出清舊物、非企業經營者，因此拒絕退貨。法院判決原告（買家）之訴駁回，確認非經營者不適用消保法。',
    oneSentenceTakeaway: '非以設計、生產、製造、輸入、經銷商品或提供服務為營業之個人賣家，不適用消保法七日無條件退貨規定。',
    country: '台灣',
    location: '台中市',
    happenedAt: DateTime(2025, 8, 12),
    updatedAt: DateTime(2026, 5, 5),
    status: '民事判決確定',
    category: '民事 / 消費糾紛',
    tags: [
      '網購',
      '七日鑑賞期',
      '退貨',
      '消費爭議',
      '7天',
      '7天鑑賞期',
      '網購7天鑑賞期',
      '個人賣家',
      '二手拍賣'
    ],
    era: '近年熱議',
    discussionPoints: ['企業經營者之認定標準', '個人出清私物之排除', '民法瑕疵擔保之適用'],
    learningPoints: ['跟一般網路個人賣家買二手物，除有重大瑕疵，否則無法無條件要求七天退貨。'],
    relatedStatutes: ['消費者保護法第 2 條', '消費者保護法第 19 條'],
    legalIssues: [
      LawCaseLegalIssue(
        title: '企業經營者認定',
        explanation: '消保法所稱之企業經營者，須以營業為目的，且持續性從事交易行為。單純出清私人物品之賣家不在此限。',
        riskLevel: 'high',
      ),
    ],
    sourceLinks: [
      LawCaseSourceLink(
        title: '臺灣臺中地方法院民事判決',
        url: 'https://example.preamble.local/mock/used-goods-return',
        sourceType: 'mock',
        publisher: '緒言 Preamble mock data',
        accessedAt: DateTime(2026, 5, 5),
      ),
    ],
  ),
  LawCase(
    id: 'rational-exception-return-2026',
    title: '客製化生鮮商品排除七日鑑賞期案',
    subtitle: '通訊交易解除權合理例外情事適用準則、通訊交易',
    summary:
        '買家於網路購買客製化蛋糕與生鮮水果，送達後主張七日鑑賞期要求退貨退款。賣家以「易於腐敗、客製化給付」符合消保法合理例外為由拒絕。法院判決賣家主張有理，駁回買家解約請求。',
    oneSentenceTakeaway: '生鮮食品、客製化給付商品等，依法屬於合理例外情事，一旦售出不適用七日無條件退貨。',
    country: '台灣',
    location: '高雄市',
    happenedAt: DateTime(2025, 11, 20),
    updatedAt: DateTime(2026, 5, 5),
    status: '民事小額判決',
    category: '民事 / 消費糾紛',
    tags: [
      '網購',
      '七日鑑賞期',
      '退貨',
      '消費爭議',
      '7天',
      '7天鑑賞期',
      '網購7天鑑賞期',
      '合理例外',
      '客製化'
    ],
    era: '近年熱議',
    discussionPoints: ['合理例外情事分類', '易於腐敗之認定', '客製化給付定義'],
    learningPoints: ['購買鮮食或客製化姓名刻字等商品前應三思，因其法律上不適用無條件退換貨。'],
    relatedStatutes: ['消費者保護法第 19 條', '通訊交易解除權合理例外情事適用準則'],
    legalIssues: [
      LawCaseLegalIssue(
        title: '解除權合理例外',
        explanation:
            '消保法第19條第1項但書規定，通訊交易有合理例外情事者，得排除解除權。如易於腐敗、客製化商品、影音或電腦軟體已拆封等。',
        riskLevel: 'medium',
      ),
    ],
    sourceLinks: [
      LawCaseSourceLink(
        title: '臺灣高雄地方法院民事判決',
        url: 'https://example.preamble.local/mock/rational-exception-return',
        sourceType: 'mock',
        publisher: '緒言 Preamble mock data',
        accessedAt: DateTime(2026, 5, 5),
      ),
    ],
  ),
];
