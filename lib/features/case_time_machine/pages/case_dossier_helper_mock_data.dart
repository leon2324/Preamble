part of 'case_dossier_detail_page.dart';

// ==========================================
// MOCK DATA GENERATION HELPERS (State Extension)
// ==========================================

extension _CaseDossierDetailPageStateMockData on _CaseDossierDetailPageState {
  List<_TrialStep> _getTrialSteps(String caseId) {
    if (caseId == '318') {
      return const [
        _TrialStep(
          stage: '第一審',
          courtName: '臺灣臺北地方法院',
          caseNumber: '104 年度矚訴字第 1 號刑事判決',
          outcome: '黃國昌等 22 人判決無罪',
          date: '2017/03/31',
          holdingDetail:
              '【判決主文與事實理由概要】\n被告黃國昌、林飛帆、陳為廷等被控煽惑他人犯罪、妨害公務、侮辱公署等罪嫌。\n\n【核心理由】\n法院認為，被告等抗議手段係針對立法院審查服貿協議之程序爭議進行表達，屬於憲法保障之言論自由與集會自由範圍。且立法院之程序瑕疵引發重大社會爭端，被告之抗爭行為符合「公民不服從」之構成要件，手段和平非暴力且具有公益目的，故宣告全體被告無罪。',
        ),
        _TrialStep(
          stage: '第二審',
          courtName: '臺灣高等法院',
          caseNumber: '106 年度矚上訴字第 2 號刑事判決',
          outcome: '檢察官上訴駁回，維持一審無罪判決',
          date: '2018/03/13',
          holdingDetail:
              '【判決主文與事實理由概要】\n檢察官針對一審判決無罪之被告提起上訴。\n\n【核心理由】\n高院審理後指出，一審判決認事用法並無違誤。憲法保障集會自由之核心價值在於保障人民向政府表達不同意見之管道。本案雖有佔領議場之形式違法，但其抗爭手段與民主防禦本質相符，且未造成不可回復之重大損害，檢察官上訴無理由，駁回上訴。',
        ),
        _TrialStep(
          stage: '第三審定讞',
          courtName: '最高法院',
          caseNumber: '107 年度台上字第 42 號刑事判決',
          outcome: '上訴駁回，全案無罪確定',
          date: '2018/03/22',
          holdingDetail:
              '【判決主文與事實理由概要】\n檢察官不服二審判決，向最高法院提起上訴。\n\n【核心理由】\n最高法院指出，刑事訴訟法關於上訴第三審有嚴格之法律限制。本案二審維持一審無罪判決，且檢察官上訴指摘事項並非違背法令之核心，不符合上訴第三審之法定要件，裁定駁回檢察官上訴，本案無罪判決定讞。',
        ),
      ];
    }

    // Fallbacks for other cases to ensure UI completeness
    return [
      _TrialStep(
        stage: '第一審',
        courtName: book.basicInfo.courtLevel.contains('/')
            ? book.basicInfo.courtLevel.split('/').last.trim()
            : book.basicInfo.courtLevel,
        caseNumber: '【模擬案號】${book.year} 年度矚訴字第 999 號',
        outcome: '裁判結果：${book.status}',
        date: book.basicInfo.updatedAt,
        holdingDetail:
            '【判決概要】\n本案為 ${book.category}，經第一審法院審判，考量相關法條事證與社會大眾爭點後做成決議。\n\n【核心判決意旨】\n詳細判決內容請參考司法院裁判書公開查詢系統。本系統已收錄該案件之核心法律關係與爭點。',
      ),
      if (book.status == '判決確定' || book.status == '已結案')
        _TrialStep(
          stage: '終審確定',
          courtName: book.basicInfo.courtLevel.contains('/')
              ? book.basicInfo.courtLevel.split('/').first.trim()
              : book.basicInfo.courtLevel,
          caseNumber: '【模擬案號】${book.year + 1} 年度台上字第 888 號',
          outcome: '上訴駁回，維持原判決確定',
          date: book.basicInfo.updatedAt,
          holdingDetail:
              '【終審裁判概要】\n本案上訴至終審法院，認原審判決認事用法尚無違誤，裁定駁回上訴或宣判確定。\n\n【判決效力】\n全案定讞，對當事人具有實質確定力。',
        ),
    ];
  }

  List<_GlossaryItem> _getGlossaries(String caseId) {
    if (caseId == '318') {
      return const [
        _GlossaryItem(
          term: '公民不服從',
          pinyin: 'Civil Disobedience',
          definition:
              '出於對於公共利益或維護憲法體制之公益動機，以公開、和平、非暴力且願意承擔法律後果之最後手段，刻意違反特定法律之抗議行為。',
          importance: '法院肯認「公民不服從」在符合特定構成要件時，可作為刑法超法規之阻卻違法事由。',
        ),
        _GlossaryItem(
          term: '阻卻違法事由',
          pinyin: 'Justification / Excuse',
          definition:
              '指行為形式上雖符合特定刑罰條文，但實質上不具社會侵害性，而具法律容許之正當理由（如正當防衛、緊急避難或超法規事由）而不予處罰。',
          importance: '本案抗爭之核心動機具有高度公益性，且為防禦民主之最後手段，因而判決無罪。',
        ),
        _GlossaryItem(
          term: '比例原則',
          pinyin: 'Principle of Proportionality',
          definition:
              '國家行使權利限制人民自由時，手段必須符合適當性（有助於目的達成）、必要性（最小侵害）、以及衡量性（手段所造成損害不可大於追求之公益）。',
          importance: '學運相關之驅離訴訟案中，常用以檢視執法機關施放警械或水砲之妥當性。',
        ),
      ];
    }
    return const [
      _GlossaryItem(
        term: '無罪推定原則',
        pinyin: 'Presumption of Innocence',
        definition: '未經審判證明有罪確定前，推定被告為無罪。犯罪事實應依證據認定之，無證據不得認定犯罪事實。',
        importance: '刑事司法制度最核心之人權保障準則，舉證責任落在檢察官身上。',
      ),
      _GlossaryItem(
        term: '比例原則',
        pinyin: 'Principle of Proportionality',
        definition: '國家行使權利限制人民權益時，必須注意手段與目的之衡平，具備適當、必要、最小侵害之特性。',
        importance: '我國司法違憲審查與裁判見解中最常引年的憲法核心防線。',
      ),
    ];
  }

  List<_LiteratureItem> _getLiteratures(String caseId) {
    if (caseId == '318') {
      return const [
        _LiteratureItem(
          title: '代議失靈與公民不服從之憲法防禦權爭議',
          author: '張文貞教授',
          journal: '《台灣法學雜誌》第 246 期 (2014)',
          sourceType: '學術期刊',
        ),
        _LiteratureItem(
          title: '集會自由之預防性限制與緊急即時強制：兼論釋字第 718 號之落實',
          author: '葉俊榮教授',
          journal: '《台大法學論叢》第 43 卷第 4 期 (2014)',
          sourceType: '學術期刊',
        ),
        _LiteratureItem(
          title: '街頭抗爭的法律邊界：從太陽花學運無罪判決看阻卻違法事由',
          author: '法白編輯部',
          journal: '《法律實務白話文評析專欄》 (2018)',
          sourceType: '實務評析',
        ),
      ];
    }
    return const [
      _LiteratureItem(
        title: '重大刑案中精神鑑定與量刑因子之實務審查標準',
        author: '法學研究中心',
        journal: '《司法官月刊》第 620 期',
        sourceType: '實務評析',
      ),
      _LiteratureItem(
        title: '比例原則在限制身體自由與刑後強制治療案件之適用界線',
        author: '憲法研究基金會',
        journal: '《憲政時代》第 46 卷',
        sourceType: '學術期刊',
      ),
    ];
  }
}

// ==========================================
// TOP-LEVEL HELPERS & DATA MODELS
// ==========================================

List<CaseImage> _getDefaultImagesForCase(CaseBook book) {
  if (book.id == '318') {
    return const [
      CaseImage(
        url: 'https://images.unsplash.com/photo-1540910419892-4a36d2c3266c?auto=format&fit=crop&w=800&q=80',
        source: '太陽花學運現場抗議人潮',
      ),
      CaseImage(
        url: 'https://images.unsplash.com/photo-1552581234-2612b75379ae?auto=format&fit=crop&w=800&q=80',
        source: '學生領袖發表公民不服從演說',
      ),
      CaseImage(
        url: 'https://images.unsplash.com/photo-1569025690938-a00729c9e1f9?auto=format&fit=crop&w=800&q=80',
        source: '立法院外部集會與民主講堂',
      ),
    ];
  }
  
  if (book.id == '124') {
    return const [
      CaseImage(
        url: 'https://images.unsplash.com/photo-1474487548417-781cb71495f3?auto=format&fit=crop&w=800&q=80',
        source: '事故現場清水隧道前軌道與警示線',
      ),
      CaseImage(
        url: 'https://images.unsplash.com/photo-1515162305285-0293e4767cc2?auto=format&fit=crop&w=800&q=80',
        source: '警消與搜救大隊於清水隧道口集結救援',
      ),
      CaseImage(
        url: 'https://images.unsplash.com/photo-1586162234057-dfd68377e8be?auto=format&fit=crop&w=800&q=80',
        source: '花蓮清水隧道清水段邊坡工程區',
      ),
    ];
  }

  // 根據分類進行自適應
  final cat = book.category;
  if (cat == '車禍賠償') {
    return const [
      CaseImage(
        url: 'https://images.unsplash.com/photo-1590674899484-d5640e854abe?auto=format&fit=crop&w=800&q=80',
        source: '交通事故現場與道路警示',
      ),
      CaseImage(
        url: 'https://images.unsplash.com/photo-1494976388531-d1058494cdd8?auto=format&fit=crop&w=800&q=80',
        source: '行車紀錄器與車道標線軌跡鑑定',
      ),
    ];
  } else if (cat == '租屋糾紛' || cat == '借款返還' || cat == '給付價金') {
    return const [
      CaseImage(
        url: 'https://images.unsplash.com/photo-1560518883-ce09059eeffa?auto=format&fit=crop&w=800&q=80',
        source: '相鄰建物與租用房屋外觀點交確認',
      ),
      CaseImage(
        url: 'https://images.unsplash.com/photo-1450133064473-71024230f91b?auto=format&fit=crop&w=800&q=80',
        source: '當事人簽署書面契約與交付金金款項證物',
      ),
    ];
  } else if (cat == '不當解雇') {
    return const [
      CaseImage(
        url: 'https://images.unsplash.com/photo-1497366216548-37526070297c?auto=format&fit=crop&w=800&q=80',
        source: '勞資爭議調解委員會辦公空間',
      ),
      CaseImage(
        url: 'https://images.unsplash.com/photo-1521791136364-7286472b5399?auto=format&fit=crop&w=800&q=80',
        source: '勞動契約簽署與在職考核紀錄',
      ),
    ];
  } else if (cat == '離婚親權') {
    return const [
      CaseImage(
        url: 'https://images.unsplash.com/photo-1502086223501-7ea6ecd79368?auto=format&fit=crop&w=800&q=80',
        source: '家事法庭社工陪同未成年子女會面審查',
      ),
      CaseImage(
        url: 'https://images.unsplash.com/photo-1476703993599-0035a21b17a9?auto=format&fit=crop&w=800&q=80',
        source: '子女監護權行使與日常生活探視紀錄',
      ),
    ];
  } else if (cat == '竊盜') {
    return const [
      CaseImage(
        url: 'https://images.unsplash.com/photo-1525498128493-380d1990a112?auto=format&fit=crop&w=800&q=80',
        source: '監視器錄影畫面與採證跡證地點',
      ),
      CaseImage(
        url: 'https://images.unsplash.com/photo-1557597774-9d273605dfa9?auto=format&fit=crop&w=800&q=80',
        source: '遭竊現場之實體防護鎖具與侵入點',
      ),
    ];
  } else if (cat == '傷害') {
    return const [
      CaseImage(
        url: 'https://images.unsplash.com/photo-1512428559087-560fa5ceab42?auto=format&fit=crop&w=800&q=80',
        source: '警車警示燈與現場緊急管制圍籬',
      ),
      CaseImage(
        url: 'https://images.unsplash.com/photo-1516574187841-cb9cc2ca948b?auto=format&fit=crop&w=800&q=80',
        source: '醫院驗傷診斷書與急診傷病就診紀錄',
      ),
    ];
  }

  // 預設民事/刑事/行政公版法院圖片
  return const [
    CaseImage(
      url: 'https://images.unsplash.com/photo-1589829545856-d10d557cf95f?auto=format&fit=crop&w=800&q=80',
      source: '法院司法天平與審判法庭現場',
    ),
    CaseImage(
      url: 'https://images.unsplash.com/photo-1505664194779-8bebcb95df84?auto=format&fit=crop&w=800&q=80',
      source: '最高法院司法卷宗圖書館',
    ),
    CaseImage(
      url: 'https://images.unsplash.com/photo-1521587760476-6c12a4b040da?auto=format&fit=crop&w=800&q=80',
      source: '法規沿革與憲法判決法典典藏',
    ),
  ];
}

class _TrialStep {
  const _TrialStep({
    required this.stage,
    required this.courtName,
    required this.caseNumber,
    required this.outcome,
    required this.date,
    required this.holdingDetail,
  });

  final String stage;
  final String courtName;
  final String caseNumber;
  final String outcome;
  final String date;
  final String holdingDetail;
}

class _CombinedTimelineNode {
  final String date;
  final String title;
  final String description;
  final String type; // 'event' or 'trial'
  final _TrialStep? trialStep;

  const _CombinedTimelineNode({
    required this.date,
    required this.title,
    required this.description,
    required this.type,
    this.trialStep,
  });
}

class _GlossaryItem {
  const _GlossaryItem({
    required this.term,
    required this.pinyin,
    required this.definition,
    required this.importance,
  });
  final String term;
  final String pinyin;
  final String definition;
  final String importance;
}

class _LiteratureItem {
  const _LiteratureItem({
    required this.title,
    required this.author,
    required this.journal,
    required this.sourceType,
  });
  final String title;
  final String author;
  final String journal;
  final String sourceType;
}
