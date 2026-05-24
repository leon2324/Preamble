import 'package:lawapp/features/case_time_machine/models/case_time_machine_models.dart';

const caseTimeMachineV2BackgroundAsset =
    'assets/images/case_time_machine_v2/ctm_v2_library_master.png';
const caseTimeMachineV2EraEmblemAsset =
    'assets/images/case_time_machine_v2/ctm_v2_era_emblem.png';
const caseTimeMachineV2ThemeEmblemAsset =
    'assets/images/case_time_machine_v2/ctm_v2_theme_emblem.png';
const caseTimeMachineV2ClassicEmblemAsset =
    'assets/images/case_time_machine_v2/ctm_v2_classic_emblem.png';
const caseTimeMachineV2CaseBookCoverAsset =
    'assets/images/case_time_machine_v2/ctm_v2_case_book_cover.png';
const caseTimeMachineV2LoginLockEmblemAsset =
    'assets/images/case_time_machine_v2/ctm_v2_login_lock_emblem.png';

const bool caseTimeMachineMockIsLoggedIn = false;

/// MVP mock data。
///
/// 台灣繁體中文教學註解：
/// 這裡先用半虛構、泛化命名的案件，避免在沒有資料授權與審稿流程前，
/// 把真實敏感案件細節放進 App。每筆資料仍保留來源欄位，提醒未來接後端時
/// 必須把來源、更新時間與是否 AI/人工整理寫清楚。
final caseTimeMachineCases = <CaseBook>[
  _caseBook(
    id: 'case-social-1997',
    titleZh: '代表性社會案件',
    titleEn: 'Representative Social Case',
    shortTitleZh: '社會案',
    shortTitleEn: 'Social',
    displayCode: 'SC-97',
    year: 1997,
    location: '台北',
    status: '已整理',
    category: '社會議題案件',
    tags: ['媒體報導', '司法程序', '制度檢討'],
    memoryLine: '一個時代如何在案件中看見制度與公共信任。',
  ),
  _caseBook(
    id: 'case-justice-1996',
    titleZh: '某判決程序爭議案',
    titleEn: 'Judicial Procedure Dispute Case',
    shortTitleZh: '程序案',
    shortTitleEn: 'Procedure',
    displayCode: 'JP-96',
    year: 1996,
    location: '司法機關',
    status: '已整理',
    category: '司法爭議案件',
    tags: ['程序保障', '證據評價', '審理透明'],
    memoryLine: '程序如何被說明，會影響人民是否相信司法。',
  ),
  _caseBook(
    id: 'case-turning-1993',
    titleZh: '制度轉折關鍵事件',
    titleEn: 'Key Turning Point Case',
    shortTitleZh: '轉折案',
    shortTitleEn: 'Turning',
    displayCode: 'KT-93',
    year: 1993,
    location: '全國性討論',
    status: '已整理',
    category: '制度改革',
    tags: ['制度改革', '公共倡議', '法制影響'],
    memoryLine: '有些案件的意義，在於它推動制度重新被檢視。',
  ),
  _caseBook(
    id: 'case-public-1992',
    titleZh: '公共安全爭議案',
    titleEn: 'Public Safety Dispute Case',
    shortTitleZh: '公安案',
    shortTitleEn: 'Safety',
    displayCode: 'PS-92',
    year: 1992,
    location: '都會區',
    status: '已整理',
    category: '社會議題案件',
    tags: ['公共安全', '行政責任', '風險治理'],
    memoryLine: '公共安全的背後，是制度能否預先辨識風險。',
  ),
  _caseBook(
    id: 'case-procedure-2001',
    titleZh: '判決程序爭議案',
    titleEn: 'Disputed Procedure Case',
    shortTitleZh: '程序案',
    shortTitleEn: 'Procedure',
    displayCode: 'JP-01',
    year: 2001,
    location: '司法機關',
    status: '示範卷宗',
    category: '司法爭議案件',
    tags: ['證據評價', '程序保障', '公開審理'],
    memoryLine: '程序是否被看見，常常決定人民是否相信判決。',
  ),
  _caseBook(
    id: 'case-campus-2014',
    titleZh: '校園安全討論事件',
    titleEn: 'Campus Safety Discussion',
    shortTitleZh: '校安案',
    shortTitleEn: 'Campus',
    displayCode: 'CS-14',
    year: 2014,
    location: '中部校園',
    status: '持續追蹤',
    category: '少年與校園案件',
    tags: ['校園安全', '通報流程', '照護責任'],
    memoryLine: '校園不是孤島，安全制度需要跨角色協作。',
  ),
  _caseBook(
    id: 'case-fraud-2020',
    titleZh: '數位詐欺財產案件',
    titleEn: 'Digital Fraud Property Case',
    shortTitleZh: '詐欺案',
    shortTitleEn: 'Fraud',
    displayCode: 'DF-20',
    year: 2020,
    location: '線上平台',
    status: '已整理',
    category: '詐欺與財產犯罪',
    tags: ['投資詐欺', '金流追蹤', '平台責任'],
    memoryLine: '新型詐欺不只考驗偵查，也考驗資訊透明與風險提醒。',
  ),
  _caseBook(
    id: 'case-public-2022',
    titleZh: '公共安全爭議案',
    titleEn: 'Public Safety Dispute',
    shortTitleZh: '公安案',
    shortTitleEn: 'Safety',
    displayCode: 'PS-22',
    year: 2022,
    location: '南部都會區',
    status: '更新中',
    category: '重大刑案',
    tags: ['公共安全', '行政稽查', '責任分工'],
    memoryLine: '公共安全案件的核心，是制度是否能在風險前先運作。',
  ),
  _caseBook(
    id: 'case-reform-2010',
    titleZh: '制度轉折關鍵事件',
    titleEn: 'Institutional Turning Point',
    shortTitleZh: '改革案',
    shortTitleEn: 'Reform',
    displayCode: 'IR-10',
    year: 2010,
    location: '全國性討論',
    status: '編輯精選',
    category: '社會議題案件',
    tags: ['制度改革', '公共倡議', '法制影響'],
    memoryLine: '有些案件的重點，不只在判決，而在它留下的制度問題。',
  ),
];

final caseTimeMachineHalls = <CaseLibraryHall>[
  CaseLibraryHall(
    id: 'timeline',
    name: '年代館',
    description: '沿著時間線，回到那些被記住的年份。',
    type: CaseLibraryHallType.timeline,
    shelves: const [
      CaseShelf(
        id: 'timeline-1990s',
        hallId: 'timeline',
        name: '1990s 書架',
        description: '理解社會轉型期的媒體、司法與公共討論。',
        coverStyle: 'timeline',
        caseIds: [
          'case-social-1997',
          'case-justice-1996',
          'case-turning-1993',
          'case-public-1992',
        ],
      ),
      CaseShelf(
        id: 'timeline-2000s',
        hallId: 'timeline',
        name: '2000s 書架',
        description: '程序保障與司法透明逐漸被社會看見。',
        coverStyle: 'timeline',
        caseIds: ['case-procedure-2001'],
      ),
      CaseShelf(
        id: 'timeline-2010s',
        hallId: 'timeline',
        name: '2010s 書架',
        description: '校園、改革與公共倡議交織的年代。',
        coverStyle: 'timeline',
        caseIds: ['case-campus-2014', 'case-reform-2010'],
      ),
      CaseShelf(
        id: 'timeline-2020s',
        hallId: 'timeline',
        name: '2020s 書架',
        description: '數位風險、公共安全與平台責任成為新議題。',
        coverStyle: 'timeline',
        caseIds: ['case-fraud-2020', 'case-public-2022'],
      ),
    ],
  ),
  CaseLibraryHall(
    id: 'theme',
    name: '主題館',
    description: '從案件類型切入，看見不同社會議題與法律爭點。',
    type: CaseLibraryHallType.theme,
    shelves: const [
      CaseShelf(
        id: 'theme-major-criminal',
        hallId: 'theme',
        name: '重大刑案',
        description: '以程序、證據與公共安全角度閱讀重大案件。',
        coverStyle: 'theme',
        caseIds: ['case-public-2022'],
      ),
      CaseShelf(
        id: 'theme-social',
        hallId: 'theme',
        name: '社會議題案件',
        description: '從公共討論與制度影響看見案件背後的脈絡。',
        coverStyle: 'theme',
        caseIds: ['case-social-1997', 'case-reform-2010'],
      ),
      CaseShelf(
        id: 'theme-campus',
        hallId: 'theme',
        name: '少年與校園案件',
        description: '聚焦教育現場、保護責任與通報制度。',
        coverStyle: 'theme',
        caseIds: ['case-campus-2014'],
      ),
      CaseShelf(
        id: 'theme-fraud',
        hallId: 'theme',
        name: '詐欺與財產犯罪',
        description: '整理財產犯罪、金流、平台治理與被害保護。',
        coverStyle: 'theme',
        caseIds: ['case-fraud-2020'],
      ),
      CaseShelf(
        id: 'theme-judicial',
        hallId: 'theme',
        name: '司法爭議案件',
        description: '閱讀程序保障、證據評價與法院認定的界線。',
        coverStyle: 'theme',
        caseIds: ['case-procedure-2001'],
      ),
    ],
  ),
  CaseLibraryHall(
    id: 'classic',
    name: '經典館',
    description: '翻開那些被反覆討論、影響深遠的案件之書。',
    type: CaseLibraryHallType.classic,
    shelves: const [
      CaseShelf(
        id: 'classic-editor',
        hallId: 'classic',
        name: '編輯精選',
        description: '適合第一次進館閱讀的代表案件。',
        coverStyle: 'classic',
        caseIds: ['case-social-1997', 'case-reform-2010'],
      ),
      CaseShelf(
        id: 'classic-hot',
        hallId: 'classic',
        name: '高討論度案件',
        description: '社會討論度高、值得拆解脈絡的案件。',
        coverStyle: 'classic',
        caseIds: ['case-public-2022', 'case-fraud-2020'],
      ),
      CaseShelf(
        id: 'classic-law',
        hallId: 'classic',
        name: '影響法制',
        description: '可看見制度檢討與法制改革的案件。',
        coverStyle: 'classic',
        caseIds: ['case-reform-2010', 'case-procedure-2001'],
      ),
      CaseShelf(
        id: 'classic-learning',
        hallId: 'classic',
        name: '法律學習推薦',
        description: '適合用來理解法條、程序與社會影響。',
        coverStyle: 'classic',
        caseIds: ['case-campus-2014', 'case-procedure-2001'],
      ),
    ],
  ),
];

CaseLibraryHall caseTimeMachineHallById(String id) =>
    caseTimeMachineHalls.firstWhere(
      (hall) => hall.id == id,
      orElse: () => caseTimeMachineHalls.first,
    );

CaseShelf caseTimeMachineShelfById(String id) {
  final shelves = caseTimeMachineHalls.expand((hall) => hall.shelves);
  return shelves.firstWhere(
    (shelf) => shelf.id == id,
    orElse: () => caseTimeMachineHalls.first.shelves.first,
  );
}

CaseBook caseTimeMachineCaseById(String id) => caseTimeMachineCases.firstWhere(
      (item) => item.id == id,
      orElse: () => caseTimeMachineCases.first,
    );

List<CaseBook> caseTimeMachineCasesForShelf(CaseShelf shelf) =>
    shelf.caseIds.map(caseTimeMachineCaseById).toList(growable: false);

CaseBook _caseBook({
  required String id,
  required String titleZh,
  required String titleEn,
  required String shortTitleZh,
  required String shortTitleEn,
  required String displayCode,
  required int year,
  required String location,
  required String status,
  required String category,
  required List<String> tags,
  required String memoryLine,
}) {
  return CaseBook(
    id: id,
    titleZh: titleZh,
    titleEn: titleEn,
    shortTitleZh: shortTitleZh,
    shortTitleEn: shortTitleEn,
    displayCode: displayCode,
    year: year,
    location: location,
    status: status,
    category: category,
    tags: tags,
    memoryLine: memoryLine,
    shortDescription: '本卷宗以中性方式整理事件脈絡、司法程序、主要爭點與後續社會影響，供法律知識學習使用。',
    basicInfo: CaseBasicInfo(
      caseType: category,
      procedureStage: status,
      courtLevel: '示範資料',
      updatedAt: '2026-05-12',
    ),
    oneSentenceSummary: memoryLine,
    background: '本案被整理為案件圖書館示範卷宗，重點不在獵奇細節，而是理解事件如何進入司法程序、公共討論與制度檢討。',
    fullStory: '事件發生後，相關人員、主管機關與社會團體陸續提出不同觀點。卷宗以時間順序整理爭點，協助使用者看見法律與社會脈絡。',
    timeline: [
      CaseTimelineItem(
          dateLabel: '$year/03',
          title: '事件進入公共視野',
          description: '事件被記錄並開始受到討論。'),
      CaseTimelineItem(
          dateLabel: '$year/04',
          title: '程序與調查展開',
          description: '主管機關或司法程序釐清事實與責任。'),
      CaseTimelineItem(
          dateLabel: '$year/06',
          title: '社會討論升溫',
          description: '公共討論聚焦程序、責任與制度補強。'),
      CaseTimelineItem(
          dateLabel: '$year/12',
          title: '後續整理',
          description: '相關制度建議與案例學習資料被整理。'),
    ],
    people: const [
      CasePersonRole(role: '當事人', description: '卷宗中涉及權益、責任或程序保障的核心角色。'),
      CasePersonRole(role: '司法機關', description: '負責偵查、審理、證據評價與法律適用。'),
      CasePersonRole(role: '社會觀察者', description: '包含媒體、團體、專家與公眾討論。'),
    ],
    legalIssues: const [
      LegalIssue(
        title: '程序保障',
        plainExplanation: '案件處理過程是否清楚、透明並保障當事人權利。',
        relationToCase: '協助理解法院或主管機關如何建立人民信任。',
        relatedLawIds: ['criminal-procedure', 'constitution'],
      ),
      LegalIssue(
        title: '責任歸屬',
        plainExplanation: '判斷誰應負責、責任範圍與證據基礎。',
        relationToCase: '是理解卷宗中法律爭點的核心。',
        relatedLawIds: ['civil-184', 'criminal-general'],
      ),
    ],
    investigationAndTrial: '偵查與審理歷程會依時間整理程序節點，包含資料蒐集、證據檢視、雙方主張與法院審酌方向。',
    courtReasoning: '法院認定重點通常包含事實認定、證據可信度、法律構成要件與責任範圍。本 MVP 以示範語氣呈現，不替代正式判決閱讀。',
    judgmentResult: '目前以示範狀態呈現。未來接正式資料後，需列明判決字號、審級、日期與資料來源。',
    relatedLaws: const [
      RelatedLaw(
        lawName: '民法',
        articleNumber: '第184條',
        plainSummary: '一般侵權行為責任的基礎條文。',
        relationToCase: '可用來理解損害與責任歸屬。',
      ),
      RelatedLaw(
        lawName: '刑事訴訟法',
        articleNumber: '程序保障相關規定',
        plainSummary: '理解偵查、審判與證據程序的基本框架。',
        relationToCase: '可對照案件處理過程是否符合程序正義。',
      ),
    ],
    socialImpact: '本案在社會層面提醒制度透明、資訊判讀與公共討論的重要。LawApp 以學習角度整理，不作情緒化或獵奇呈現。',
    relatedCases: const [
      RelatedCase(
          caseId: 'case-social-1997',
          title: '代表性社會案件',
          yearLabel: '1997',
          reason: '同樣涉及公共討論與制度檢討。'),
      RelatedCase(
          caseId: 'case-procedure-2001',
          title: '判決程序爭議案',
          yearLabel: '2001',
          reason: '可對照程序保障與法院認定。'),
    ],
    sources: const [
      CaseSource(
          title: '官方公開資料摘要', sourceType: 'official', updatedAt: '2026-05-12'),
      CaseSource(
          title: 'LawApp 編輯部示範整理',
          sourceType: 'editorial_mock',
          updatedAt: '2026-05-12'),
    ],
  );
}
