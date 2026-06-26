import 'package:flutter/material.dart';

class CaseStoryItem {
  const CaseStoryItem({
    required this.title,
    required this.subtitle,
    required this.category,
    required this.country,
    required this.occurredAt,
    required this.location,
    required this.statusLabel,
    required this.publicInterest,
    required this.courtName,
    required this.caseNumber,
    required this.oneSentenceConclusion,
    required this.summary,
    required this.timeline,
    required this.legalIssues,
    required this.watchPoints,
    required this.sources,
    required this.accentColor,
  });

  final String title;
  final String subtitle;
  final String category;
  final String country;

  /// 詳情頁頂端只需要讓使用者快速抓到「何時、何地」；
  /// 先用可讀字串，未來若要排序或篩選再拆成 DateTime 與地點代碼。
  final String occurredAt;
  final String location;
  final String statusLabel;
  final int publicInterest;
  final String courtName;
  final String caseNumber;
  final String oneSentenceConclusion;
  final String summary;
  final List<CaseTimelineItem> timeline;
  final List<String> legalIssues;
  final List<String> watchPoints;
  final List<String> sources;
  final Color accentColor;

  /// 目前案件資料仍是 mock，但收藏與筆記已經會寫入本機；
  /// 用標題與案號組成穩定 ID，之後後端補正式 caseId 時只要改這個 getter。
  String get storageId => '${title}__$caseNumber';
}

class CaseTimelineItem {
  const CaseTimelineItem({
    required this.label,
    required this.description,
  });

  final String label;
  final String description;
}

/// 記事頁社會案件示範資料。
///
/// 這裡故意用「社會案件整理」的語氣，而不是只放裁判書標題；
/// 目標使用者包含愛看犯罪 Podcast、調查節目與社會新聞回顧的人，
/// 所以每筆資料都要有時間線、法律爭點與可繼續追的觀察點。
const caseStoryItems = [
  CaseStoryItem(
    title: '廢死釋憲與死刑個案',
    subtitle: '死刑制度、憲法審查與重大刑案判決的交會',
    category: '刑事 / 憲法',
    country: '台灣',
    occurredAt: '2024 年 9 月',
    location: '台灣',
    statusLabel: '憲法法庭判決後追蹤',
    publicInterest: 96,
    courtName: '憲法法庭及各級法院公開裁判',
    caseNumber: '憲法法庭與刑事確定判決資料',
    oneSentenceConclusion: '制度爭點不能只看單一案件結果，法院會同時處理量刑、救濟與憲法界線。',
    summary: '從重大刑案被害情緒、死刑制度合憲性，到法庭如何看待量刑與救濟程序，這類案件常把社會價值衝突推到最前線。',
    timeline: [
      CaseTimelineItem(label: '案件定讞', description: '個案進入死刑確定判決與後續救濟階段。'),
      CaseTimelineItem(label: '聲請釋憲', description: '爭點轉向死刑制度是否符合憲法保障。'),
      CaseTimelineItem(label: '社會討論', description: '被害者權益、矯正可能性與國家刑罰界線同步被討論。'),
    ],
    legalIssues: ['生命權', '比例原則', '量刑審查', '刑事救濟'],
    watchPoints: ['判決理由如何處理被害者權益', '制度審查與個案救濟是否分流', '後續修法方向'],
    sources: ['司法院裁判書', '憲法法庭公告', '公開新聞資料'],
    accentColor: Color(0xFFDCE7F5),
  ),
  CaseStoryItem(
    title: '詐騙車手與洗錢鏈',
    subtitle: '從帳戶、人頭、提款到詐欺集團分工',
    category: '刑事 / 金融',
    country: '台灣',
    occurredAt: '2024 年至今',
    location: '全台',
    statusLabel: '偵查與起訴高發',
    publicInterest: 91,
    courtName: '各級法院公開刑事裁判',
    caseNumber: '詐欺、洗錢防制相關裁判整理',
    oneSentenceConclusion: '法院通常會細看帳戶提供者、提款者是否知道資金來源與分工角色。',
    summary: '詐騙案件常不只是一通電話，背後包含收簿、轉帳、提款、洗錢與組織分工。一般民眾最需要知道的是如何避免被利用成犯罪鏈的一段。',
    timeline: [
      CaseTimelineItem(label: '帳戶取得', description: '犯罪者透過收購、租用或誘騙取得帳戶。'),
      CaseTimelineItem(label: '被害匯款', description: '被害人受話術影響，將款項匯入指定帳戶。'),
      CaseTimelineItem(label: '車手提款', description: '車手依指示提領或轉交現金，形成後續追訴重點。'),
    ],
    legalIssues: ['詐欺取財', '洗錢防制', '幫助犯', '組織犯罪'],
    watchPoints: ['提供帳戶是否知道用途', '提款者如何辯稱不知情', '金融機構通報與阻詐責任'],
    sources: ['司法院裁判書', '警政公開宣導', '金融監理資料'],
    accentColor: Color(0xFFEAF3E6),
  ),
  CaseStoryItem(
    title: '租屋押金與提前解約',
    subtitle: '看似日常，卻最容易進入調解與小額訴訟',
    category: '民事 / 租賃',
    country: '台灣',
    occurredAt: '2023 年 8 月',
    location: '台北市',
    statusLabel: '二審判決',
    publicInterest: 84,
    courtName: '臺灣高等法院',
    caseNumber: '112 年度上字第 123 號判決',
    oneSentenceConclusion: '房東未能證明租屋有造成損害，法院認定不得扣除押金，應全額返還。',
    summary: '房東不退押金、提前解約、修繕費與點交紀錄，是民眾最常搜尋的法律場景之一。它適合作為一般人學會「事實整理」的第一個案例。',
    timeline: [
      CaseTimelineItem(label: '簽約入住', description: '雙方約定押金、租期、修繕與提前解約條款。'),
      CaseTimelineItem(label: '退租爭議', description: '房東主張扣款，房客要求返還押金。'),
      CaseTimelineItem(label: '調解或訴訟', description: '證據會集中在合約、照片、點交紀錄與修繕單據。'),
    ],
    legalIssues: ['租賃契約', '押金返還', '損害賠償', '證據保存'],
    watchPoints: ['自然耗損與人為損害怎麼分', '扣款是否有明細', '提前解約條款是否合理'],
    sources: ['全國法規資料庫', '法院公開判決', '地方調解資訊'],
    accentColor: Color(0xFFF6E8D7),
  ),
];
