import 'package:lawapp/data/cases/case_models.dart';

class CaseRepository {
  CaseRepository({List<LawCase>? seedCases}) : _cases = seedCases ?? _mockCases;

  final List<LawCase> _cases;
  final Set<String> _followedCaseIds = <String>{};

  Future<List<LawCase>> fetchFeaturedCases() async {
    return _cases.take(3).toList(growable: false);
  }

  Future<List<LawCase>> fetchArchiveCases() async => _cases;

  Future<List<LawCase>> searchCases(String query) async {
    if (query.trim().isEmpty) return _cases;
    return _cases.where((item) => item.matches(query)).toList(growable: false);
  }

  Future<List<LawCase>> filterByEra(String era) async {
    if (era.trim().isEmpty || era == '全部') return _cases;
    return _cases.where((item) => item.era == era).toList(growable: false);
  }

  Future<List<LawCase>> filterByCategory(String category) async {
    if (category.trim().isEmpty || category == '全部') return _cases;
    return _cases
        .where((item) => item.category.contains(category))
        .toList(growable: false);
  }

  Future<LawCase?> getCaseDetail(String id) async {
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
        url: 'https://example.lawapp.local/mock/nylon-cheng',
        sourceType: 'mock',
        publisher: 'LawApp mock data',
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
        url: 'https://example.lawapp.local/mock/sunflower',
        sourceType: 'mock',
        publisher: 'LawApp mock data',
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
        url: 'https://example.lawapp.local/mock/fraud-chain',
        sourceType: 'mock',
        publisher: 'LawApp mock data',
        accessedAt: DateTime(2026, 5, 5),
      ),
    ],
  ),
];
