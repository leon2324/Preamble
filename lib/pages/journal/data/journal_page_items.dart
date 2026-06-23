import 'package:flutter/material.dart';

/// 社會討論趨勢資料。
///
/// 台灣繁體中文教學註解：
/// 記事頁這裡不是直接吃首頁完整討論模型，而是先整理成排行榜與摘要 Bottom Sheet
/// 需要的最小資料形狀，未來串後端時可先在這層做轉換，避免 UI 綁死在首頁模型。
class DiscussionTrendItem {
  const DiscussionTrendItem({
    required this.rank,
    required this.title,
    required this.score,
    required this.delta,
    required this.whyHot,
    required this.relatedCases,
    required this.heatCurve,
    required this.heatLabels,
    required this.fullTopicIndex,
    required this.tint,
  });

  final int rank;
  final String title;
  final double score;
  final String delta;
  final String whyHot;
  final List<String> relatedCases;
  final List<double> heatCurve;
  final List<String> heatLabels;
  final int fullTopicIndex;
  final Color tint;
}

/// 案件觀看角度。
///
/// 台灣繁體中文教學註解：
/// 這組資料直接綁到 SVG 與卡片底色，因為這一區是偏策展型入口，
/// 之後若要改圖，只要換資產路徑與色票即可，不需要重寫 widget 佈局。
/// 若不同 SVG 的畫布留白不一樣，也可以直接用 iconScale 做視覺校正。
class CaseAngleItem {
  const CaseAngleItem({
    required this.label,
    required this.description,
    required this.assetPath,
    required this.backgroundAssetPath,
    required this.startColor,
    required this.endColor,
    required this.borderColor,
    this.iconScale = 1,
  });

  final String label;
  final String description;
  final String assetPath;
  final String backgroundAssetPath;
  final Color startColor;
  final Color endColor;
  final Color borderColor;
  final double iconScale;
}

/// 那年今日資料。
///
/// 台灣繁體中文教學註解：
/// 舊紙卡需要的不只是案名，還有日期、地點與一句有記憶點的引言，
/// 因此獨立成專屬模型，避免和一般案件列表共用欄位後變得難維護。
class OnThisDayItem {
  const OnThisDayItem({
    required this.label,
    required this.monthDay,
    required this.fullDate,
    required this.location,
    required this.title,
    required this.summary,
    required this.quote,
    required this.buttonLabel,
  });

  final String label;
  final String monthDay;
  final String fullDate;
  final String location;
  final String title;
  final String summary;
  final String quote;
  final String buttonLabel;
}

/// 資料館更新資料。
///
/// 台灣繁體中文教學註解：
/// 這裡用 type + title + summary + time 組成一則 feed item，
/// 比單純標題更接近之後資料館真的會出現的「更新記錄」。
class ArchiveUpdateItem {
  const ArchiveUpdateItem({
    required this.type,
    required this.title,
    required this.summary,
    required this.timeLabel,
    required this.tint,
    required this.caseId,
    this.initialTab,
  });

  final String type;
  final String title;
  final String summary;
  final String timeLabel;
  final Color tint;
  final String caseId;
  final String? initialTab;
}

/// 沉浸式資料館頁的精選卷宗。
class ArchiveDossierItem {
  const ArchiveDossierItem({
    required this.id,
    required this.era,
    required this.title,
    required this.summary,
    required this.tag,
    required this.fullDate,
    required this.location,
    required this.statusLabel,
    required this.lead,
    required this.timeline,
    required this.keyPoints,
    required this.sources,
    required this.tint,
  });

  final String id;
  final String era;
  final String title;
  final String summary;
  final String tag;
  final String fullDate;
  final String location;
  final String statusLabel;
  final String lead;
  final List<ArchiveTimelineItem> timeline;
  final List<String> keyPoints;
  final List<String> sources;
  final Color tint;
}

/// 資料館卷宗時間軸節點。
///
/// 台灣繁體中文教學註解：
/// 目前資料館還沒有後端，所以先把詳情頁會用到的時間軸拆成小模型；
/// 未來接 API 時只要把後端事件列表轉成這個形狀，頁面就能維持可讀且好測。
class ArchiveTimelineItem {
  const ArchiveTimelineItem({
    required this.label,
    required this.description,
  });

  final String label;
  final String description;
}

const discussionTrendItems = [
  DiscussionTrendItem(
    rank: 1,
    title: '國會擴權釋憲案',
    score: 98.6,
    delta: '24h +12%',
    whyHot: '釋憲庭期逼近後，立法院職權界線、程序正義與權力分立再次成為新聞與社群焦點。',
    relatedCases: ['憲法法庭程序爭議', '國會改革法案攻防', '程序表決效力案'],
    heatCurve: [24, 32, 48, 72, 90, 98],
    heatLabels: ['週一', '週二', '週三', '週四', '週五', '今天'],
    fullTopicIndex: 0,
    tint: Color(0xFF1E7B66),
  ),
  DiscussionTrendItem(
    rank: 2,
    title: 'im.B 吸金詐騙案',
    score: 87.4,
    delta: '24h +8%',
    whyHot: '被害人求償、名人站台責任與平台監管是否失靈，再次被放到社會討論中心。',
    relatedCases: ['虛擬投資詐欺鏈', '洗錢防制責任', '平台廣告代言爭議'],
    heatCurve: [18, 28, 42, 55, 73, 87],
    heatLabels: ['週一', '週二', '週三', '週四', '週五', '今天'],
    fullTopicIndex: 1,
    tint: Color(0xFF2F6D99),
  ),
  DiscussionTrendItem(
    rank: 3,
    title: '勞基法工時修法',
    score: 76.1,
    delta: '24h +6%',
    whyHot: '修法條文通過後，輪班、加班與工時上限怎麼算，成了上班族與企業都在追的題目。',
    relatedCases: ['加班費計算爭議', '輪班間隔案件', '補休與工時上限解釋'],
    heatCurve: [16, 21, 34, 51, 64, 76],
    heatLabels: ['週一', '週二', '週三', '週四', '週五', '今天'],
    fullTopicIndex: 2,
    tint: Color(0xFF9F6A26),
  ),
  DiscussionTrendItem(
    rank: 4,
    title: '職場性騷擾通報案',
    score: 71.8,
    delta: '24h +5%',
    whyHot: '企業內部調查透明度、補救機制與申訴後的二次傷害，讓許多舊案再度被提起。',
    relatedCases: ['申訴保密義務', '雇主防治責任', '調查程序瑕疵案'],
    heatCurve: [14, 17, 26, 45, 57, 72],
    heatLabels: ['週一', '週二', '週三', '週四', '週五', '今天'],
    fullTopicIndex: 3,
    tint: Color(0xFF7A5D9A),
  ),
  DiscussionTrendItem(
    rank: 5,
    title: '租屋押金扣抵糾紛',
    score: 68.2,
    delta: '24h +15%',
    whyHot: '畢業季與租屋潮來臨，房東點交扣押金、折舊計算與房屋還原義務成熱議焦點。',
    relatedCases: ['民法租賃契約', '租屋點交糾紛', '押金返還調解'],
    heatCurve: [10, 18, 30, 48, 59, 68],
    heatLabels: ['週一', '週二', '週三', '週四', '週五', '今天'],
    fullTopicIndex: 4,
    tint: Color(0xFF355668),
  ),
];

const caseAngleItems = [
  CaseAngleItem(
    label: '正在發酵',
    description: '即時關注社會焦點',
    assetPath:
        'assets/images/journal/School-Science-Test-Flask--Streamline-Pixel.svg',
    backgroundAssetPath: 'assets/images/journal/frement_kraft_paper.png',
    startColor: Color(0xFF32473F),
    endColor: Color(0xFF23332D),
    borderColor: Color(0xFF99A98C),
    iconScale: 0.9,
  ),
  CaseAngleItem(
    label: '已經落幕',
    description: '結局已定的案件',
    assetPath: 'assets/images/journal/hourglass_icon.svg',
    backgroundAssetPath: 'assets/images/journal/closed_case_kraft_paper.png',
    startColor: Color(0xFF355668),
    endColor: Color(0xFF27404E),
    borderColor: Color(0xFF90AEBF),
    iconScale: 0.82,
  ),
  CaseAngleItem(
    label: '仍有爭議',
    description: '觀點分歧持續中',
    assetPath: 'assets/images/journal/scale_icon.svg',
    backgroundAssetPath:
        'assets/images/journal/still_arguing_kraft_paper.png.png',
    startColor: Color(0xFF8D5A43),
    endColor: Color(0xFF6F4331),
    borderColor: Color(0xFFD6B28A),
    iconScale: 0.94,
  ),
  CaseAngleItem(
    label: '值得回看',
    description: '經典案件再思考',
    assetPath: 'assets/images/journal/book_icon.svg',
    backgroundAssetPath:
        'assets/images/journal/worth_review_kraft_paper.png.png',
    startColor: Color(0xFFB08E55),
    endColor: Color(0xFF947342),
    borderColor: Color(0xFFF1D7A5),
    iconScale: 0.94,
  ),
];

const onThisDayItem = OnThisDayItem(
  label: '那年今日',
  monthDay: '4 / 7',
  fullDate: '1989.04.07',
  location: '台北市大安區',
  title: '鄭南榕事件',
  summary: '1989 年，鄭南榕因《自由時代》與政治主張遭追訴，事件成為台灣言論自由與民主運動的重要記憶座標。',
  quote: '有些日子不是過去，而是社會仍在回頭確認自己曾經如何選擇自由。',
  buttonLabel: '回到那一天',
);

const archiveUpdateItems = [
  ArchiveUpdateItem(
    type: '新增判決',
    title: '太魯閣列車事故',
    summary: '補上二審判決摘要、過失責任與相關法條。',
    timeLabel: '2 小時前',
    tint: Color(0xFF6EAE46),
    caseId: '124',
    initialTab: '完整判決書',
  ),
  ArchiveUpdateItem(
    type: '時間軸更新',
    title: '113年憲判8',
    summary: '新增庭訊節點、聲請理由與歷次社會討論脈絡。',
    timeLabel: '5 小時前',
    tint: Color(0xFF4C8CCB),
    caseId: '103',
    initialTab: '事件與訴訟脈絡',
  ),
  ArchiveUpdateItem(
    type: '資料補完',
    title: '鄭性澤平反事件',
    summary: '補齊再審新事證、彈道鑑定與無罪平反歷程。',
    timeLabel: '1 天前',
    tint: Color(0xFF8B6DB4),
    caseId: 'cheng-2021',
    initialTab: '事件背景',
  ),
  ArchiveUpdateItem(
    type: '新增卷宗',
    title: '信義幼兒園性侵案',
    summary: '整理教保員侵害爭議、兒少法保密限制與公眾知情權討論。',
    timeLabel: '2 天前',
    tint: Color(0xFFC08C44),
    caseId: '161',
    initialTab: '事件背景',
  ),
  ArchiveUpdateItem(
    type: '生活避坑',
    title: '租屋退租押金返還指南',
    summary: '整理民法租賃規定、折舊計算、點交拍照存證技巧與糾紛調解申請流程。',
    timeLabel: '3 小時前',
    tint: Color(0xFF2F6D99),
    caseId: 'rent-dispute-guidelines',
    initialTab: '點交注意事項',
  ),
  ArchiveUpdateItem(
    type: '防詐筆記',
    title: '網拍三方詐騙手法與預防',
    summary: '剖析假買家假賣家雙向詐騙手法，提醒匯款與收貨時的查證關鍵。',
    timeLabel: '6 小時前',
    tint: Color(0xFF9F6A26),
    caseId: 'three-party-fraud-notes',
    initialTab: '詐騙手法剖析',
  ),
  ArchiveUpdateItem(
    type: '生活避坑',
    title: '網購七日鑑賞期退貨指南',
    summary:
        '詳細整理網購七日無條件退貨權利範圍、不適用商品清單與遇到賣家刁難時的申訴步驟。適合7天鑑賞期、網購7天鑑賞期等常見退換貨消費爭議。',
    timeLabel: '4 小時前',
    tint: Color(0xFF1E7B66),
    caseId: 'online-shopping-return-2025',
    initialTab: '退貨權利範圍',
  ),
  ArchiveUpdateItem(
    type: '生活避坑',
    title: '二手拍賣與個人賣家退貨爭議',
    summary:
        '解析個人出清二手舊物是否適用消保法七日鑑賞期？深入討論企業經營者之認定，並提供買賣雙方合理自保與協商手段。符合7天鑑賞期、網購7天鑑賞期、個人賣家退貨等爭議情境。',
    timeLabel: '5 小時前',
    tint: Color(0xFFC69C55),
    caseId: 'used-goods-return-2026',
    initialTab: '企業經營者認定',
  ),
  ArchiveUpdateItem(
    type: '生活避坑',
    title: '網購合理例外與客製化排除指南',
    summary:
        '生鮮食品、已拆封之影音軟體、客製化姓名商品均不適用七日鑑賞期無條件退換貨。整理通訊交易合理例外情事，教您如何判斷可排除的商品範圍。符合7天鑑賞期、網購7天鑑賞期排除規定。',
    timeLabel: '8 小時前',
    tint: Color(0xFF4A7C9D),
    caseId: 'rational-exception-return-2026',
    initialTab: '合理例外情事',
  ),
];

const archiveDossierItems = [
  ArchiveDossierItem(
    id: 'nylon-cheng-1989',
    era: '1980s',
    title: '鄭南榕事件',
    summary: '從言論自由走向社會記憶，回看那一年媒體、國家與公民之間的拉扯。',
    tag: '民主運動',
    fullDate: '1989.04.07',
    location: '台北市大安區',
    statusLabel: '歷史案件整理',
    lead: '這份卷宗先以公開歷史資料與既有 mock 摘要整理脈絡，讓使用者能從日期、地點、程序與社會記憶四個角度重新進入事件。',
    timeline: [
      ArchiveTimelineItem(
        label: '雜誌與政治主張成為追訴焦點',
        description: '言論自由、出版自由與國家權力界線開始被放到公共討論中心。',
      ),
      ArchiveTimelineItem(
        label: '1989.04.07',
        description: '事件發生後，鄭南榕成為台灣民主化與言論自由記憶的重要象徵。',
      ),
      ArchiveTimelineItem(
        label: '後續紀念與制度討論',
        description: '社會持續透過紀念日、教育與公共討論回看自由權保障的代價。',
      ),
    ],
    keyPoints: ['言論自由與出版自由', '國家追訴權界線', '民主運動記憶', '公共紀念如何形成'],
    sources: ['公開歷史資料', '民主運動紀念資料', '新聞回顧整理'],
    tint: Color(0xFFE6F0EA),
  ),
  ArchiveDossierItem(
    id: 'pai-hsiao-yen-1990s',
    era: '1990s',
    title: '白曉燕案',
    summary: '媒體報導、治安政策與死刑討論如何被快速推上社會中心。',
    tag: '治安與媒體',
    fullDate: '1997.04',
    location: '台北都會區',
    statusLabel: '重大刑案回顧',
    lead: '這份卷宗聚焦在重大刑案如何牽動媒體倫理、治安政策與刑罰討論，幫助讀者把新聞記憶拆成可理解的法律與社會問題。',
    timeline: [
      ArchiveTimelineItem(
        label: '案件曝光',
        description: '被害事件快速引發全國關注，媒體追逐與資訊揭露方式成為爭議。',
      ),
      ArchiveTimelineItem(
        label: '偵辦與追緝',
        description: '社會對治安、警政量能與偵查公開界線提出強烈要求。',
      ),
      ArchiveTimelineItem(
        label: '政策與刑罰討論',
        description: '死刑、重刑化與媒體自律等議題被推上長期公共辯論。',
      ),
    ],
    keyPoints: ['媒體倫理', '偵查不公開', '刑罰政策', '被害者保護'],
    sources: ['公開新聞資料', '司法與警政公開資訊', '媒體倫理討論整理'],
    tint: Color(0xFFF1E7D5),
  ),
  ArchiveDossierItem(
    id: 'judicial-reform-2000s',
    era: '2000s',
    title: '司法改革與冤案救濟',
    summary: '從個案救濟到制度修補，觀察證據、再審與司法信任如何被重新討論。',
    tag: '司法改革',
    fullDate: '2000s',
    location: '台灣',
    statusLabel: '制度型卷宗',
    lead: '這份卷宗先用示範資料整理司法改革常見爭點，誠實標示為 mock 內容，提供未來接正式冤案資料庫前的瀏覽骨架。',
    timeline: [
      ArchiveTimelineItem(
        label: '個案疑義浮現',
        description: '證據採集、鑑定可靠性與自白任意性常成為重新檢視案件的起點。',
      ),
      ArchiveTimelineItem(
        label: '聲請救濟',
        description: '再審、非常上訴與平反倡議把個案推回司法系統。',
      ),
      ArchiveTimelineItem(
        label: '制度修補',
        description: '程序保障、辯護權與證據法則逐步成為改革討論核心。',
      ),
    ],
    keyPoints: ['再審制度', '證據法則', '自白任意性', '司法信任'],
    sources: ['司法院公開資料', '司法改革倡議資料', '公開新聞資料'],
    tint: Color(0xFFE8EDF6),
  ),
  ArchiveDossierItem(
    id: 'sunflower-2014',
    era: '2010s',
    title: '太陽花運動相關案件',
    summary: '從佔領國會到後續訴訟，整理程序、刑責與公共討論如何互相影響。',
    tag: '公民抗爭',
    fullDate: '2014.03',
    location: '台北市中正區',
    statusLabel: '社會運動與司法程序',
    lead: '這份卷宗把社會運動、議事程序與後續司法案件放在同一條線上看，協助使用者理解「公共抗爭」如何被翻譯成法律爭點。',
    timeline: [
      ArchiveTimelineItem(
        label: '議事程序爭議升溫',
        description: '服貿協議審查與程序透明度成為行動前的核心背景。',
      ),
      ArchiveTimelineItem(
        label: '佔領與集會',
        description: '學生與公民團體進入立法院周邊，公共討論轉向民主程序與抗爭正當性。',
      ),
      ArchiveTimelineItem(
        label: '後續訴訟與評價',
        description: '刑責、阻卻違法、集會自由與政治責任被法院與社會持續檢視。',
      ),
    ],
    keyPoints: ['集會自由', '議事程序', '公民不服從', '刑事責任界線'],
    sources: ['法院公開裁判', '立法院公開資料', '新聞與研究資料'],
    tint: Color(0xFFEAF2DC),
  ),
  ArchiveDossierItem(
    id: 'fraud-money-laundering-recent',
    era: '近年熱議',
    title: '詐騙車手與洗錢鏈',
    summary: '把帳戶、人頭、提款與洗錢分工拆開，理解近年詐欺案件為何高發。',
    tag: '詐欺與金融',
    fullDate: '2024 至今',
    location: '全台',
    statusLabel: '偵查與起訴高發',
    lead: '這份卷宗沿用現有案例 mock data 的整理方向，讓資料館不只展示舊案，也能收納仍在大量發生的生活型刑事案件。',
    timeline: [
      ArchiveTimelineItem(
        label: '帳戶取得',
        description: '犯罪者可能透過收購、租用或誘騙取得金融帳戶。',
      ),
      ArchiveTimelineItem(
        label: '被害匯款',
        description: '被害人受話術影響匯款，資金流向成為偵查重點。',
      ),
      ArchiveTimelineItem(
        label: '提款與洗錢',
        description: '車手提領或轉交款項，法院會檢視角色分工與主觀認知。',
      ),
    ],
    keyPoints: ['詐欺取財', '洗錢防制', '幫助犯', '金融帳戶風險'],
    sources: ['司法院裁判書', '警政公開宣導', '金融監理資料'],
    tint: Color(0xFFEAF3E6),
  ),
];

const archiveEraLabels = ['1980s', '1990s', '2000s', '2010s', '近年熱議'];

/// 主題策展特展架模型。
class CuratedExhibition {
  const CuratedExhibition({
    required this.title,
    required this.description,
    required this.caseIds,
    required this.readProgress,
    required this.themeColor,
  });

  final String title;
  final String description;
  final List<String> caseIds;
  final String readProgress;
  final Color themeColor;
}

const curatedExhibitionItems = [
  CuratedExhibition(
    title: '言論自由的邊界特展',
    description: '從街頭抗爭到數位言論，回顧台灣言論自由與憲法保障的演進歷程。',
    caseIds: ['318', '799', '499'],
    readProgress: '1 / 3',
    themeColor: Color(0xFF1E7B66),
  ),
  CuratedExhibition(
    title: '性別與婚姻平權之路',
    description: '多元性別與婚姻自由的憲法審查，見證平權路上的重要司法判決。',
    caseIds: ['520', '103', '161'],
    readProgress: '2 / 3',
    themeColor: Color(0xFF7A5D9A),
  ),
  CuratedExhibition(
    title: '重大職災與公共安全',
    description: '從太魯閣事故到公共安全事件，釐清過失責任與制度防線。',
    caseIds: ['124', 'cheng-2021', 'hung-2013'],
    readProgress: '0 / 3',
    themeColor: Color(0xFF9F6A26),
  ),
];
