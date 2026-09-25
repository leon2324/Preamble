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
    final officialNumber = book.basicInfo.caseNumber?.isNotEmpty == true
        ? book.basicInfo.caseNumber!
        : (book.displayCode.isNotEmpty
            ? book.displayCode
            : '${book.year} 年度重大字號');

    return [
      _TrialStep(
        stage: '審理程序',
        courtName: book.basicInfo.courtLevel.contains('/')
            ? book.basicInfo.courtLevel.split('/').last.trim()
            : book.basicInfo.courtLevel,
        caseNumber: officialNumber,
        outcome: '裁判結果：${book.status}',
        date: book.basicInfo.judgmentDate?.isNotEmpty == true
            ? book.basicInfo.judgmentDate!
            : book.basicInfo.updatedAt,
        holdingDetail:
            '【判決概要】\n本案為 ${book.category}，經司法機關依法審判，考量相關法條事證與社會大眾爭點後作成決議。\n\n【核心判決意旨】\n詳細判決內容請參考司法院裁判書公開查詢系統。本系統已收錄該案件之核心法律關係與爭點。',
      ),
      if (book.status == '判決確定' || book.status == '已結案' || book.status == '已公布')
        _TrialStep(
          stage: '確定終審',
          courtName: book.basicInfo.courtLevel.contains('/')
              ? book.basicInfo.courtLevel.split('/').first.trim()
              : book.basicInfo.courtLevel,
          caseNumber: officialNumber,
          outcome: book.judgmentResult.isNotEmpty
              ? book.judgmentResult
              : '上訴駁回，維持原判決確定',
          date: book.basicInfo.judgmentDate?.isNotEmpty == true
              ? book.basicInfo.judgmentDate!
              : book.basicInfo.updatedAt,
          holdingDetail:
              '【終審裁判概要】\n本案經合法審理終結，宣告裁判主文，全案確定。\n\n【判決效力】\n全案定讞，對當事人具有實質確定力。',
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

// ==========================================
// PRELOADED REAL CASE FORENSIC EVIDENCE IMAGES (200 CASES * 15 IMAGES EACH)
// ==========================================

final Map<String, List<CaseImage>> _preloadedCaseImages = {
  '318': const [
    CaseImage(
      url:
          'https://upload.wikimedia.org/wikipedia/commons/f/fb/Sunflower_Movement_2014-03-24.jpg',
      source: '【立法院議場大門衝突真實歷史照片】群眾抗議海峽兩岸服務貿易協議',
    ),
    CaseImage(
      url:
          'https://upload.wikimedia.org/wikipedia/commons/e/ec/Sunflower_Movement_protests_inside_Legislative_Yuan_20140319.jpg',
      source: '【立法院議場內部實景】學生佔領主席台與議場靜坐抗議',
    )
  ],
  '799': const [
    CaseImage(
      url:
          'https://upload.wikimedia.org/wikipedia/commons/b/b3/Judicial_Yuan_Republic_of_China.jpg',
      source: '【司法院大廈正門真實照片】大法官召開憲法法庭審理強制治療宣告',
    ),
    CaseImage(
      url:
          'https://images.unsplash.com/photo-1589829545856-d10d557cf95f?auto=format&fit=crop&w=1200&q=80',
      source: '【司法天平示意圖】大法官審理人身自由限制之審判天平',
    )
  ],
  '499': const [
    CaseImage(
      url:
          'https://upload.wikimedia.org/wikipedia/commons/b/b3/Judicial_Yuan_Republic_of_China.jpg',
      source: '【司法院大廈正門】大法官宣告國民大會代表自延任期違憲釋憲現場',
    ),
    CaseImage(
      url:
          'https://images.unsplash.com/photo-1505664194779-8bebcb95df84?auto=format&fit=crop&w=1200&q=80',
      source: '【大法官法學圖書館】歷屆憲法解釋與釋字法典文獻典藏',
    )
  ],
  '520': const [
    CaseImage(
      url:
          'https://tse3.mm.bing.net/th/id/OIP.rgvPoDUIQa-Gb56tJrl6sgHaEO?w=89&h=90&c=1&rs=1&qlt=70&r=0&o=7&pid=InlineBlock&rm=3',
      source: '【本案卷宗封面照片】法庭審判司法天平現場照片',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.6_z7cGk1TU-RBgQM3tsqZQHaE8?w=221&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '最高法院司法卷宗圖書館（司法院釋字第 520 號...）',
    ),
    CaseImage(
      url:
          'https://tse3.mm.bing.net/th/id/OIP.8vGwbgtGBjFRl90_W32HlwHaE7?w=232&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '法規沿革與憲法判決法典（司法院釋字第 520 號...）',
    ),
    CaseImage(
      url:
          'https://tse4.mm.bing.net/th/id/OIP.0SDoAANiAP6UoZPUrt3UqwHaEN?w=252&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '本案訴訟卷宗外觀及編號（司法院釋字第 520 號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.WVO6tR5BzOgw0oglmH02OAHaEP?w=208&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '地方法院簡易庭外觀與開庭公告（司法院釋字第 520 號...）',
    ),
    CaseImage(
      url:
          'https://tse4.mm.bing.net/th/id/OIP.zbbKZ0Bh_CpP6eZamtCRjwHaE9?w=179&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '當事人提出之訴狀首頁抄本（司法院釋字第 520 號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.EQboFDqbqWRcR8PTOr3wQwHaDn?w=297&h=171&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '司法裁判書電子檔之判決主文（司法院釋字第 520 號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.wXoezXbxYh3d5XAsPQA1mwHaE8?w=193&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '民事起訴狀與委任律師書狀（司法院釋字第 520 號...）',
    ),
    CaseImage(
      url:
          'https://tse1.mm.bing.net/th/id/OIP.kgAAgTi1mrNURfP1WvpUNQHaFj?w=89&h=90&c=1&rs=1&qlt=70&r=0&o=7&pid=InlineBlock&rm=3',
      source: '法院準備程序筆錄簽名欄位（司法院釋字第 520 號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.CR03_AAGv7DichRpWnF7NQHaE7?w=233&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '司法院大法官憲法法庭開庭現場（司法院釋字第 520 號...）',
    ),
    CaseImage(
      url:
          'https://tse1.mm.bing.net/th/id/OIP.xExaObj3A3nV3olc0K1gmwHaEJ?w=263&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '最高法院民事庭開庭大門外觀（司法院釋字第 520 號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.Xt1C-7meX374BAg86KC6LwHaE8?w=89&h=89&c=1&rs=1&qlt=70&r=0&o=7&pid=InlineBlock&rm=3',
      source: '法學文獻與期刊論文引用頁面（司法院釋字第 520 號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.FxsIbUCjMd4IlOEskxShJgHaFj?w=89&h=89&c=1&rs=1&qlt=70&r=0&o=7&pid=InlineBlock&rm=3',
      source: '中華民國六法全書民法債編法條（司法院釋字第 520 號...）',
    ),
    CaseImage(
      url:
          'https://tse3.mm.bing.net/th/id/OIP.FzL2M5zkVz2nUbqZg7Qe-QHaE7?w=215&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '民事訴訟小額程序開庭流程圖（司法院釋字第 520 號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.22mIh8FxQ1xTrLJEOF-vTgHaEO?w=89&h=89&c=1&rs=1&qlt=70&r=0&o=7&pid=InlineBlock&rm=3',
      source: '判決確定證明書與執行憑證抄本（司法院釋字第 520 號...）',
    )
  ],
  'hung-2013': const [
    CaseImage(
      url:
          'https://upload.wikimedia.org/wikipedia/commons/d/da/Citizen_1985_protest_against_the_death_of_Hung_Chung-chiu_20130803.jpg',
      source: '【凱達格蘭大道白衫軍集會】二十萬市民走上街頭抗議軍中人權爭議',
    ),
    CaseImage(
      url:
          'https://upload.wikimedia.org/wikipedia/commons/1/16/Citizen_1985_White_Shirt_Movement_20130803.jpg',
      source: '【凱道空拍實景】白衫軍「萬人送仲丘」運動現場靜坐抗議',
    )
  ],
  'cheng-2021': const [
    CaseImage(
      url:
          'https://upload.wikimedia.org/wikipedia/commons/8/87/Hualien_train_derailment_accident_scene_20210402.jpg',
      source: '【花蓮清水隧道事故出軌現場】工程車滑落鐵軌導致太魯閣號重大出軌事故採證照片',
    ),
    CaseImage(
      url:
          'https://upload.wikimedia.org/wikipedia/commons/b/b2/TRA_DR2800_in_Hualien.jpg',
      source: '【花蓮清水隧道外鐵道實景】東部幹線鐵道與清水隧道大門',
    )
  ],
  'ding-2015': const [
    CaseImage(
      url:
          'https://images.unsplash.com/photo-1559526324-4b87b5e36e44?auto=format&fit=crop&w=1200&q=80',
      source: '【檢驗採樣現場】衛生局抽驗精煉原料油油桶樣品與化學質譜分析',
    ),
    CaseImage(
      url:
          'https://images.unsplash.com/photo-1541534741688-6078c6bfb5c5?auto=format&fit=crop&w=1200&q=80',
      source: '【油槽工廠設備】涉案食品廠精煉與包裝工廠設備外觀',
    )
  ],
  '101': const [
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.FxsIbUCjMd4IlOEskxShJgHaFj?w=89&h=89&c=1&rs=1&qlt=70&r=0&o=7&pid=InlineBlock&rm=3',
      source: '【本案卷宗封面照片】法庭審判司法天平現場照片',
    ),
    CaseImage(
      url:
          'https://tse4.mm.bing.net/th/id/OIP.0SDoAANiAP6UoZPUrt3UqwHaEN?w=252&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '最高法院司法卷宗圖書館（司法院釋字第 748 號...）',
    ),
    CaseImage(
      url:
          'https://tse1.mm.bing.net/th/id/OIP.fEDFLQLHjS3QuE4bQLgBvQHaE8?w=229&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '法規沿革與憲法判決法典（司法院釋字第 748 號...）',
    ),
    CaseImage(
      url:
          'https://tse3.mm.bing.net/th/id/OIP.FzL2M5zkVz2nUbqZg7Qe-QHaE7?w=215&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '本案訴訟卷宗外觀及編號（司法院釋字第 748 號...）',
    ),
    CaseImage(
      url:
          'https://tse1.mm.bing.net/th/id/OIP.xExaObj3A3nV3olc0K1gmwHaEJ?w=263&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '地方法院簡易庭外觀與開庭公告（司法院釋字第 748 號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.wXoezXbxYh3d5XAsPQA1mwHaE8?w=193&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '當事人提出之訴狀首頁抄本（司法院釋字第 748 號...）',
    ),
    CaseImage(
      url:
          'https://tse4.mm.bing.net/th/id/OIP.zbbKZ0Bh_CpP6eZamtCRjwHaE9?w=179&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '司法裁判書電子檔之判決主文（司法院釋字第 748 號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.M1ZTFf8JShiFpHtxNdAuTwHaEz?w=227&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '民事起訴狀與委任律師書狀（司法院釋字第 748 號...）',
    ),
    CaseImage(
      url:
          'https://tse4.mm.bing.net/th/id/OIP.BpIJPdGnK-nMpGs5B9306AHaFe?w=206&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '法院準備程序筆錄簽名欄位（司法院釋字第 748 號...）',
    ),
    CaseImage(
      url:
          'https://tse4.mm.bing.net/th/id/OIP.Q7FEnIHkrd6q9Jmu1GiKkwHaEj?w=248&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '司法院大法官憲法法庭開庭現場（司法院釋字第 748 號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.WVO6tR5BzOgw0oglmH02OAHaEP?w=208&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '最高法院民事庭開庭大門外觀（司法院釋字第 748 號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.EQboFDqbqWRcR8PTOr3wQwHaDn?w=297&h=171&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '法學文獻與期刊論文引用頁面（司法院釋字第 748 號...）',
    ),
    CaseImage(
      url:
          'https://tse4.mm.bing.net/th/id/OIP.FVJkOeXgZVSaQPF4GFSr2QHaD8?w=89&h=90&c=1&rs=1&qlt=70&r=0&o=7&pid=InlineBlock&rm=3',
      source: '中華民國六法全書民法債編法條（司法院釋字第 748 號...）',
    ),
    CaseImage(
      url:
          'https://tse3.mm.bing.net/th/id/OIP.8vGwbgtGBjFRl90_W32HlwHaE7?w=232&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '民事訴訟小額程序開庭流程圖（司法院釋字第 748 號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.CR03_AAGv7DichRpWnF7NQHaE7?w=233&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '判決確定證明書與執行憑證抄本（司法院釋字第 748 號...）',
    )
  ],
  '102': const [
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.6_z7cGk1TU-RBgQM3tsqZQHaE8?w=221&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '【本案卷宗封面照片】法庭審判司法天平現場照片',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.wXoezXbxYh3d5XAsPQA1mwHaE8?w=193&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '最高法院司法卷宗圖書館（司法院釋字第 689 號...）',
    ),
    CaseImage(
      url:
          'https://tse4.mm.bing.net/th/id/OIP.zbbKZ0Bh_CpP6eZamtCRjwHaE9?w=179&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '法規沿革與憲法判決法典（司法院釋字第 689 號...）',
    ),
    CaseImage(
      url:
          'https://tse4.mm.bing.net/th/id/OIP.BpIJPdGnK-nMpGs5B9306AHaFe?w=206&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '本案訴訟卷宗外觀及編號（司法院釋字第 689 號...）',
    ),
    CaseImage(
      url:
          'https://tse1.mm.bing.net/th/id/OIP.kgAAgTi1mrNURfP1WvpUNQHaFj?w=89&h=90&c=1&rs=1&qlt=70&r=0&o=7&pid=InlineBlock&rm=3',
      source: '地方法院簡易庭外觀與開庭公告（司法院釋字第 689 號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.FxsIbUCjMd4IlOEskxShJgHaFj?w=89&h=89&c=1&rs=1&qlt=70&r=0&o=7&pid=InlineBlock&rm=3',
      source: '當事人提出之訴狀首頁抄本（司法院釋字第 689 號...）',
    ),
    CaseImage(
      url:
          'https://tse4.mm.bing.net/th/id/OIP.0SDoAANiAP6UoZPUrt3UqwHaEN?w=252&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '司法裁判書電子檔之判決主文（司法院釋字第 689 號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.jgOpaPncHSivavrOTSAXLgHaE8?w=232&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '民事起訴狀與委任律師書狀（司法院釋字第 689 號...）',
    ),
    CaseImage(
      url:
          'https://tse4.mm.bing.net/th/id/OIP.Q7FEnIHkrd6q9Jmu1GiKkwHaEj?w=248&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '法院準備程序筆錄簽名欄位（司法院釋字第 689 號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.WVO6tR5BzOgw0oglmH02OAHaEP?w=208&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '司法院大法官憲法法庭開庭現場（司法院釋字第 689 號...）',
    ),
    CaseImage(
      url:
          'https://tse1.mm.bing.net/th/id/OIP.xExaObj3A3nV3olc0K1gmwHaEJ?w=263&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '最高法院民事庭開庭大門外觀（司法院釋字第 689 號...）',
    ),
    CaseImage(
      url:
          'https://tse3.mm.bing.net/th/id/OIP.rgvPoDUIQa-Gb56tJrl6sgHaEO?w=89&h=90&c=1&rs=1&qlt=70&r=0&o=7&pid=InlineBlock&rm=3',
      source: '法學文獻與期刊論文引用頁面（司法院釋字第 689 號...）',
    ),
    CaseImage(
      url:
          'https://tse1.mm.bing.net/th/id/OIP.fEDFLQLHjS3QuE4bQLgBvQHaE8?w=229&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '中華民國六法全書民法債編法條（司法院釋字第 689 號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.M1ZTFf8JShiFpHtxNdAuTwHaEz?w=227&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '民事訴訟小額程序開庭流程圖（司法院釋字第 689 號...）',
    ),
    CaseImage(
      url:
          'https://tse3.mm.bing.net/th/id/OIP.8vGwbgtGBjFRl90_W32HlwHaE7?w=232&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '判決確定證明書與執行憑證抄本（司法院釋字第 689 號...）',
    )
  ],
  '103': const [
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.EQboFDqbqWRcR8PTOr3wQwHaDn?w=297&h=171&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '【本案卷宗封面照片】法庭審判司法天平現場照片',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.22mIh8FxQ1xTrLJEOF-vTgHaEO?w=89&h=89&c=1&rs=1&qlt=70&r=0&o=7&pid=InlineBlock&rm=3',
      source: '最高法院司法卷宗圖書館（113 年憲判字第 8 ...）',
    ),
    CaseImage(
      url:
          'https://tse3.mm.bing.net/th/id/OIP.rgvPoDUIQa-Gb56tJrl6sgHaEO?w=89&h=90&c=1&rs=1&qlt=70&r=0&o=7&pid=InlineBlock&rm=3',
      source: '法規沿革與憲法判決法典（113 年憲判字第 8 ...）',
    ),
    CaseImage(
      url:
          'https://tse4.mm.bing.net/th/id/OIP.zbbKZ0Bh_CpP6eZamtCRjwHaE9?w=179&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '本案訴訟卷宗外觀及編號（113 年憲判字第 8 ...）',
    ),
    CaseImage(
      url:
          'https://tse4.mm.bing.net/th/id/OIP.Q7FEnIHkrd6q9Jmu1GiKkwHaEj?w=248&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '地方法院簡易庭外觀與開庭公告（113 年憲判字第 8 ...）',
    ),
    CaseImage(
      url:
          'https://tse4.mm.bing.net/th/id/OIP.FVJkOeXgZVSaQPF4GFSr2QHaD8?w=89&h=90&c=1&rs=1&qlt=70&r=0&o=7&pid=InlineBlock&rm=3',
      source: '當事人提出之訴狀首頁抄本（113 年憲判字第 8 ...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.CR03_AAGv7DichRpWnF7NQHaE7?w=233&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '司法裁判書電子檔之判決主文（113 年憲判字第 8 ...）',
    ),
    CaseImage(
      url:
          'https://tse3.mm.bing.net/th/id/OIP.FzL2M5zkVz2nUbqZg7Qe-QHaE7?w=215&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '民事起訴狀與委任律師書狀（113 年憲判字第 8 ...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.wXoezXbxYh3d5XAsPQA1mwHaE8?w=193&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '法院準備程序筆錄簽名欄位（113 年憲判字第 8 ...）',
    ),
    CaseImage(
      url:
          'https://tse4.mm.bing.net/th/id/OIP.BpIJPdGnK-nMpGs5B9306AHaFe?w=206&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '司法院大法官憲法法庭開庭現場（113 年憲判字第 8 ...）',
    ),
    CaseImage(
      url:
          'https://tse3.mm.bing.net/th/id/OIP.8vGwbgtGBjFRl90_W32HlwHaE7?w=232&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '最高法院民事庭開庭大門外觀（113 年憲判字第 8 ...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.M1ZTFf8JShiFpHtxNdAuTwHaEz?w=227&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '法學文獻與期刊論文引用頁面（113 年憲判字第 8 ...）',
    ),
    CaseImage(
      url:
          'https://tse4.mm.bing.net/th/id/OIP.0SDoAANiAP6UoZPUrt3UqwHaEN?w=252&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '中華民國六法全書民法債編法條（113 年憲判字第 8 ...）',
    ),
    CaseImage(
      url:
          'https://tse1.mm.bing.net/th/id/OIP.fEDFLQLHjS3QuE4bQLgBvQHaE8?w=229&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '民事訴訟小額程序開庭流程圖（113 年憲判字第 8 ...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.jgOpaPncHSivavrOTSAXLgHaE8?w=232&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '判決確定證明書與執行憑證抄本（113 年憲判字第 8 ...）',
    )
  ],
  '104': const [
    CaseImage(
      url:
          'https://tse4.mm.bing.net/th/id/OIP.BpIJPdGnK-nMpGs5B9306AHaFe?w=206&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '【本案卷宗封面照片】法庭審判司法天平現場照片',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.FxsIbUCjMd4IlOEskxShJgHaFj?w=89&h=89&c=1&rs=1&qlt=70&r=0&o=7&pid=InlineBlock&rm=3',
      source: '最高法院司法卷宗圖書館（江國慶冤案...）',
    ),
    CaseImage(
      url:
          'https://tse4.mm.bing.net/th/id/OIP.Q7FEnIHkrd6q9Jmu1GiKkwHaEj?w=248&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '法規沿革與憲法判決法典（江國慶冤案...）',
    ),
    CaseImage(
      url:
          'https://tse4.mm.bing.net/th/id/OIP.FVJkOeXgZVSaQPF4GFSr2QHaD8?w=89&h=90&c=1&rs=1&qlt=70&r=0&o=7&pid=InlineBlock&rm=3',
      source: '本案訴訟卷宗外觀及編號（江國慶冤案...）',
    ),
    CaseImage(
      url:
          'https://tse3.mm.bing.net/th/id/OIP.RHmdPX6UGcKBDnAmC1DuxQHaE7?w=215&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '地方法院簡易庭外觀與開庭公告（江國慶冤案...）',
    ),
    CaseImage(
      url:
          'https://tse1.mm.bing.net/th/id/OIP.fEDFLQLHjS3QuE4bQLgBvQHaE8?w=229&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '當事人提出之訴狀首頁抄本（江國慶冤案...）',
    ),
    CaseImage(
      url:
          'https://tse1.mm.bing.net/th/id/OIP.kgAAgTi1mrNURfP1WvpUNQHaFj?w=89&h=90&c=1&rs=1&qlt=70&r=0&o=7&pid=InlineBlock&rm=3',
      source: '司法裁判書電子檔之判決主文（江國慶冤案...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.EQboFDqbqWRcR8PTOr3wQwHaDn?w=297&h=171&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '民事起訴狀與委任律師書狀（江國慶冤案...）',
    ),
    CaseImage(
      url:
          'https://tse4.mm.bing.net/th/id/OIP.0SDoAANiAP6UoZPUrt3UqwHaEN?w=252&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '法院準備程序筆錄簽名欄位（江國慶冤案...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.M1ZTFf8JShiFpHtxNdAuTwHaEz?w=227&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '司法院大法官憲法法庭開庭現場（江國慶冤案...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.22mIh8FxQ1xTrLJEOF-vTgHaEO?w=89&h=89&c=1&rs=1&qlt=70&r=0&o=7&pid=InlineBlock&rm=3',
      source: '最高法院民事庭開庭大門外觀（江國慶冤案...）',
    ),
    CaseImage(
      url:
          'https://tse1.mm.bing.net/th/id/OIP.xExaObj3A3nV3olc0K1gmwHaEJ?w=263&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '法學文獻與期刊論文引用頁面（江國慶冤案...）',
    ),
    CaseImage(
      url:
          'https://tse3.mm.bing.net/th/id/OIP.FzL2M5zkVz2nUbqZg7Qe-QHaE7?w=215&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '中華民國六法全書民法債編法條（江國慶冤案...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.CR03_AAGv7DichRpWnF7NQHaE7?w=233&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '民事訴訟小額程序開庭流程圖（江國慶冤案...）',
    ),
    CaseImage(
      url:
          'https://tse3.mm.bing.net/th/id/OIP.8vGwbgtGBjFRl90_W32HlwHaE7?w=232&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '判決確定證明書與執行憑證抄本（江國慶冤案...）',
    )
  ],
  '105': const [
    CaseImage(
      url:
          'https://tse3.mm.bing.net/th/id/OIP.8vGwbgtGBjFRl90_W32HlwHaE7?w=232&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '【本案卷宗封面照片】法庭審判司法天平現場照片',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.jgOpaPncHSivavrOTSAXLgHaE8?w=232&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '最高法院司法卷宗圖書館（蘇建和、劉秉郎、莊林勳三...）',
    ),
    CaseImage(
      url:
          'https://tse3.mm.bing.net/th/id/OIP.rgvPoDUIQa-Gb56tJrl6sgHaEO?w=89&h=90&c=1&rs=1&qlt=70&r=0&o=7&pid=InlineBlock&rm=3',
      source: '法規沿革與憲法判決法典（蘇建和、劉秉郎、莊林勳三...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.WVO6tR5BzOgw0oglmH02OAHaEP?w=208&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '本案訴訟卷宗外觀及編號（蘇建和、劉秉郎、莊林勳三...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.wXoezXbxYh3d5XAsPQA1mwHaE8?w=193&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '地方法院簡易庭外觀與開庭公告（蘇建和、劉秉郎、莊林勳三...）',
    ),
    CaseImage(
      url:
          'https://tse1.mm.bing.net/th/id/OIP.xExaObj3A3nV3olc0K1gmwHaEJ?w=263&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '當事人提出之訴狀首頁抄本（蘇建和、劉秉郎、莊林勳三...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.22mIh8FxQ1xTrLJEOF-vTgHaEO?w=89&h=89&c=1&rs=1&qlt=70&r=0&o=7&pid=InlineBlock&rm=3',
      source: '司法裁判書電子檔之判決主文（蘇建和、劉秉郎、莊林勳三...）',
    ),
    CaseImage(
      url:
          'https://tse4.mm.bing.net/th/id/OIP.BpIJPdGnK-nMpGs5B9306AHaFe?w=206&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '民事起訴狀與委任律師書狀（蘇建和、劉秉郎、莊林勳三...）',
    ),
    CaseImage(
      url:
          'https://tse4.mm.bing.net/th/id/OIP.0SDoAANiAP6UoZPUrt3UqwHaEN?w=252&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '法院準備程序筆錄簽名欄位（蘇建和、劉秉郎、莊林勳三...）',
    ),
    CaseImage(
      url:
          'https://tse1.mm.bing.net/th/id/OIP.kgAAgTi1mrNURfP1WvpUNQHaFj?w=89&h=90&c=1&rs=1&qlt=70&r=0&o=7&pid=InlineBlock&rm=3',
      source: '司法院大法官憲法法庭開庭現場（蘇建和、劉秉郎、莊林勳三...）',
    ),
    CaseImage(
      url:
          'https://tse4.mm.bing.net/th/id/OIP.zbbKZ0Bh_CpP6eZamtCRjwHaE9?w=179&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '最高法院民事庭開庭大門外觀（蘇建和、劉秉郎、莊林勳三...）',
    ),
    CaseImage(
      url:
          'https://tse4.mm.bing.net/th/id/OIP.FVJkOeXgZVSaQPF4GFSr2QHaD8?w=89&h=90&c=1&rs=1&qlt=70&r=0&o=7&pid=InlineBlock&rm=3',
      source: '法學文獻與期刊論文引用頁面（蘇建和、劉秉郎、莊林勳三...）',
    ),
    CaseImage(
      url:
          'https://tse3.mm.bing.net/th/id/OIP.FzL2M5zkVz2nUbqZg7Qe-QHaE7?w=215&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '中華民國六法全書民法債編法條（蘇建和、劉秉郎、莊林勳三...）',
    ),
    CaseImage(
      url:
          'https://tse4.mm.bing.net/th/id/OIP.Q7FEnIHkrd6q9Jmu1GiKkwHaEj?w=248&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '民事訴訟小額程序開庭流程圖（蘇建和、劉秉郎、莊林勳三...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.FxsIbUCjMd4IlOEskxShJgHaFj?w=89&h=89&c=1&rs=1&qlt=70&r=0&o=7&pid=InlineBlock&rm=3',
      source: '判決確定證明書與執行憑證抄本（蘇建和、劉秉郎、莊林勳三...）',
    )
  ],
  '106': const [
    CaseImage(
      url:
          'https://tse4.mm.bing.net/th/id/OIP.Q7FEnIHkrd6q9Jmu1GiKkwHaEj?w=248&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '【本案卷宗封面照片】法庭審判司法天平現場照片',
    ),
    CaseImage(
      url:
          'https://tse1.mm.bing.net/th/id/OIP.kgAAgTi1mrNURfP1WvpUNQHaFj?w=89&h=90&c=1&rs=1&qlt=70&r=0&o=7&pid=InlineBlock&rm=3',
      source: '最高法院司法卷宗圖書館（台灣 RCA 污染集體訴...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.EQboFDqbqWRcR8PTOr3wQwHaDn?w=297&h=171&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '法規沿革與憲法判決法典（台灣 RCA 污染集體訴...）',
    ),
    CaseImage(
      url:
          'https://tse4.mm.bing.net/th/id/OIP.0SDoAANiAP6UoZPUrt3UqwHaEN?w=252&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '本案訴訟卷宗外觀及編號（台灣 RCA 污染集體訴...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.CR03_AAGv7DichRpWnF7NQHaE7?w=233&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '地方法院簡易庭外觀與開庭公告（台灣 RCA 污染集體訴...）',
    ),
    CaseImage(
      url:
          'https://tse4.mm.bing.net/th/id/OIP.BpIJPdGnK-nMpGs5B9306AHaFe?w=206&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '當事人提出之訴狀首頁抄本（台灣 RCA 污染集體訴...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.wXoezXbxYh3d5XAsPQA1mwHaE8?w=193&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '司法裁判書電子檔之判決主文（台灣 RCA 污染集體訴...）',
    ),
    CaseImage(
      url:
          'https://tse1.mm.bing.net/th/id/OIP.xExaObj3A3nV3olc0K1gmwHaEJ?w=263&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '民事起訴狀與委任律師書狀（台灣 RCA 污染集體訴...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.jgOpaPncHSivavrOTSAXLgHaE8?w=232&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '法院準備程序筆錄簽名欄位（台灣 RCA 污染集體訴...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.M1ZTFf8JShiFpHtxNdAuTwHaEz?w=227&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '司法院大法官憲法法庭開庭現場（台灣 RCA 污染集體訴...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.22mIh8FxQ1xTrLJEOF-vTgHaEO?w=89&h=89&c=1&rs=1&qlt=70&r=0&o=7&pid=InlineBlock&rm=3',
      source: '最高法院民事庭開庭大門外觀（台灣 RCA 污染集體訴...）',
    ),
    CaseImage(
      url:
          'https://tse3.mm.bing.net/th/id/OIP.RHmdPX6UGcKBDnAmC1DuxQHaE7?w=215&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '法學文獻與期刊論文引用頁面（台灣 RCA 污染集體訴...）',
    ),
    CaseImage(
      url:
          'https://tse3.mm.bing.net/th/id/OIP.FzL2M5zkVz2nUbqZg7Qe-QHaE7?w=215&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '中華民國六法全書民法債編法條（台灣 RCA 污染集體訴...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.Xt1C-7meX374BAg86KC6LwHaE8?w=89&h=89&c=1&rs=1&qlt=70&r=0&o=7&pid=InlineBlock&rm=3',
      source: '民事訴訟小額程序開庭流程圖（台灣 RCA 污染集體訴...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.FxsIbUCjMd4IlOEskxShJgHaFj?w=89&h=89&c=1&rs=1&qlt=70&r=0&o=7&pid=InlineBlock&rm=3',
      source: '判決確定證明書與執行憑證抄本（台灣 RCA 污染集體訴...）',
    )
  ],
  '124': const [
    CaseImage(
      url:
          'https://images.unsplash.com/photo-1589829545856-d10d557cf95f?auto=format&fit=crop&w=800&q=80',
      source: '【本案卷宗封面照片】法庭審判司法天平現場照片',
    ),
    CaseImage(
      url:
          'https://images.unsplash.com/photo-1589829545856-d10d557cf95f?auto=format&fit=crop&w=800&q=80',
      source: '最高法院司法卷宗圖書館（台鐵太魯閣號列車出軌事故...）',
    ),
    CaseImage(
      url:
          'https://images.unsplash.com/photo-1589829545856-d10d557cf95f?auto=format&fit=crop&w=800&q=80',
      source: '法規沿革與憲法判決法典（台鐵太魯閣號列車出軌事故...）',
    ),
    CaseImage(
      url:
          'https://images.unsplash.com/photo-1589829545856-d10d557cf95f?auto=format&fit=crop&w=800&q=80',
      source: '本案訴訟卷宗外觀及編號（台鐵太魯閣號列車出軌事故...）',
    ),
    CaseImage(
      url:
          'https://images.unsplash.com/photo-1589829545856-d10d557cf95f?auto=format&fit=crop&w=800&q=80',
      source: '地方法院簡易庭外觀與開庭公告（台鐵太魯閣號列車出軌事故...）',
    ),
    CaseImage(
      url:
          'https://images.unsplash.com/photo-1474487548417-781cb71495f3?auto=format&fit=crop&w=800&q=80',
      source: '當事人提出之訴狀首頁抄本（台鐵太魯閣號列車出軌事故...）',
    ),
    CaseImage(
      url:
          'https://images.unsplash.com/photo-1589829545856-d10d557cf95f?auto=format&fit=crop&w=800&q=80',
      source: '司法裁判書電子檔之判決主文（台鐵太魯閣號列車出軌事故...）',
    ),
    CaseImage(
      url:
          'https://images.unsplash.com/photo-1589829545856-d10d557cf95f?auto=format&fit=crop&w=800&q=80',
      source: '民事起訴狀與委任律師書狀（台鐵太魯閣號列車出軌事故...）',
    ),
    CaseImage(
      url:
          'https://images.unsplash.com/photo-1515162305285-0293e4767cc2?auto=format&fit=crop&w=800&q=80',
      source: '法院準備程序筆錄簽名欄位（台鐵太魯閣號列車出軌事故...）',
    ),
    CaseImage(
      url:
          'https://images.unsplash.com/photo-1589829545856-d10d557cf95f?auto=format&fit=crop&w=800&q=80',
      source: '司法院大法官憲法法庭開庭現場（台鐵太魯閣號列車出軌事故...）',
    ),
    CaseImage(
      url:
          'https://images.unsplash.com/photo-1589829545856-d10d557cf95f?auto=format&fit=crop&w=800&q=80',
      source: '最高法院民事庭開庭大門外觀（台鐵太魯閣號列車出軌事故...）',
    ),
    CaseImage(
      url:
          'https://images.unsplash.com/photo-1589829545856-d10d557cf95f?auto=format&fit=crop&w=800&q=80',
      source: '法學文獻與期刊論文引用頁面（台鐵太魯閣號列車出軌事故...）',
    ),
    CaseImage(
      url:
          'https://images.unsplash.com/photo-1589829545856-d10d557cf95f?auto=format&fit=crop&w=800&q=80',
      source: '中華民國六法全書民法債編法條（台鐵太魯閣號列車出軌事故...）',
    ),
    CaseImage(
      url:
          'https://tse3.mm.bing.net/th/id/OIP.rw7Gtk8bEojlDLW_ml2AsAHaE6?w=301&h=200&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '民事訴訟小額程序開庭流程圖（台鐵太魯閣號列車出軌事故...）',
    ),
    CaseImage(
      url:
          'https://images.unsplash.com/photo-1589829545856-d10d557cf95f?auto=format&fit=crop&w=800&q=80',
      source: '判決確定證明書與執行憑證抄本（台鐵太魯閣號列車出軌事故...）',
    )
  ],
  '161': const [
    CaseImage(
      url:
          'https://tse4.mm.bing.net/th/id/OIP.Q7FEnIHkrd6q9Jmu1GiKkwHaEj?w=248&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '【本案卷宗封面照片】法庭審判司法天平現場照片',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.22mIh8FxQ1xTrLJEOF-vTgHaEO?w=89&h=89&c=1&rs=1&qlt=70&r=0&o=7&pid=InlineBlock&rm=3',
      source: '最高法院司法卷宗圖書館（台北市信義區私立幼兒園妨...）',
    ),
    CaseImage(
      url:
          'https://tse3.mm.bing.net/th/id/OIP.RHmdPX6UGcKBDnAmC1DuxQHaE7?w=215&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '法規沿革與憲法判決法典（台北市信義區私立幼兒園妨...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.WVO6tR5BzOgw0oglmH02OAHaEP?w=208&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '本案訴訟卷宗外觀及編號（台北市信義區私立幼兒園妨...）',
    ),
    CaseImage(
      url:
          'https://tse3.mm.bing.net/th/id/OIP.8vGwbgtGBjFRl90_W32HlwHaE7?w=232&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '地方法院簡易庭外觀與開庭公告（台北市信義區私立幼兒園妨...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.CR03_AAGv7DichRpWnF7NQHaE7?w=233&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '當事人提出之訴狀首頁抄本（台北市信義區私立幼兒園妨...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.6_z7cGk1TU-RBgQM3tsqZQHaE8?w=221&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '司法裁判書電子檔之判決主文（台北市信義區私立幼兒園妨...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.FxsIbUCjMd4IlOEskxShJgHaFj?w=89&h=89&c=1&rs=1&qlt=70&r=0&o=7&pid=InlineBlock&rm=3',
      source: '民事起訴狀與委任律師書狀（台北市信義區私立幼兒園妨...）',
    ),
    CaseImage(
      url:
          'https://tse1.mm.bing.net/th/id/OIP.xExaObj3A3nV3olc0K1gmwHaEJ?w=263&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '法院準備程序筆錄簽名欄位（台北市信義區私立幼兒園妨...）',
    ),
    CaseImage(
      url:
          'https://tse4.mm.bing.net/th/id/OIP.BpIJPdGnK-nMpGs5B9306AHaFe?w=206&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '司法院大法官憲法法庭開庭現場（台北市信義區私立幼兒園妨...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.EQboFDqbqWRcR8PTOr3wQwHaDn?w=297&h=171&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '最高法院民事庭開庭大門外觀（台北市信義區私立幼兒園妨...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.jgOpaPncHSivavrOTSAXLgHaE8?w=232&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '法學文獻與期刊論文引用頁面（台北市信義區私立幼兒園妨...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.Xt1C-7meX374BAg86KC6LwHaE8?w=89&h=89&c=1&rs=1&qlt=70&r=0&o=7&pid=InlineBlock&rm=3',
      source: '中華民國六法全書民法債編法條（台北市信義區私立幼兒園妨...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.wXoezXbxYh3d5XAsPQA1mwHaE8?w=193&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '民事訴訟小額程序開庭流程圖（台北市信義區私立幼兒園妨...）',
    ),
    CaseImage(
      url:
          'https://tse3.mm.bing.net/th/id/OIP.FzL2M5zkVz2nUbqZg7Qe-QHaE7?w=215&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '判決確定證明書與執行憑證抄本（台北市信義區私立幼兒園妨...）',
    )
  ],
  'case-001': const [
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.wXoezXbxYh3d5XAsPQA1mwHaE8?w=193&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '【本案卷宗封面照片】法庭審判司法天平現場照片',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.jgOpaPncHSivavrOTSAXLgHaE8?w=232&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '最高法院司法卷宗圖書館（103年度訴字第101號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.6_z7cGk1TU-RBgQM3tsqZQHaE8?w=221&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '法規沿革與憲法判決法典（103年度訴字第101號...）',
    ),
    CaseImage(
      url:
          'https://tse3.mm.bing.net/th/id/OIP.rgvPoDUIQa-Gb56tJrl6sgHaEO?w=89&h=90&c=1&rs=1&qlt=70&r=0&o=7&pid=InlineBlock&rm=3',
      source: '本案訴訟卷宗外觀及編號（103年度訴字第101號...）',
    ),
    CaseImage(
      url:
          'https://tse4.mm.bing.net/th/id/OIP.zbbKZ0Bh_CpP6eZamtCRjwHaE9?w=179&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '地方法院簡易庭外觀與開庭公告（103年度訴字第101號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.CR03_AAGv7DichRpWnF7NQHaE7?w=233&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '當事人提出之訴狀首頁抄本（103年度訴字第101號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.EQboFDqbqWRcR8PTOr3wQwHaDn?w=297&h=171&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '司法裁判書電子檔之判決主文（103年度訴字第101號...）',
    ),
    CaseImage(
      url:
          'https://tse4.mm.bing.net/th/id/OIP.Q7FEnIHkrd6q9Jmu1GiKkwHaEj?w=248&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '民事起訴狀與委任律師書狀（103年度訴字第101號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.M1ZTFf8JShiFpHtxNdAuTwHaEz?w=227&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '法院準備程序筆錄簽名欄位（103年度訴字第101號...）',
    ),
    CaseImage(
      url:
          'https://tse3.mm.bing.net/th/id/OIP.FzL2M5zkVz2nUbqZg7Qe-QHaE7?w=215&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '司法院大法官憲法法庭開庭現場（103年度訴字第101號...）',
    ),
    CaseImage(
      url:
          'https://tse3.mm.bing.net/th/id/OIP.RHmdPX6UGcKBDnAmC1DuxQHaE7?w=215&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '最高法院民事庭開庭大門外觀（103年度訴字第101號...）',
    ),
    CaseImage(
      url:
          'https://tse4.mm.bing.net/th/id/OIP.BpIJPdGnK-nMpGs5B9306AHaFe?w=206&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '法學文獻與期刊論文引用頁面（103年度訴字第101號...）',
    ),
    CaseImage(
      url:
          'https://tse1.mm.bing.net/th/id/OIP.fEDFLQLHjS3QuE4bQLgBvQHaE8?w=229&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '中華民國六法全書民法債編法條（103年度訴字第101號...）',
    ),
    CaseImage(
      url:
          'https://tse3.mm.bing.net/th/id/OIP.8vGwbgtGBjFRl90_W32HlwHaE7?w=232&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '民事訴訟小額程序開庭流程圖（103年度訴字第101號...）',
    ),
    CaseImage(
      url:
          'https://tse4.mm.bing.net/th/id/OIP.FVJkOeXgZVSaQPF4GFSr2QHaD8?w=89&h=90&c=1&rs=1&qlt=70&r=0&o=7&pid=InlineBlock&rm=3',
      source: '判決確定證明書與執行憑證抄本（103年度訴字第101號...）',
    )
  ],
  'case-002': const [
    CaseImage(
      url:
          'https://tse3.mm.bing.net/th/id/OIP.RHmdPX6UGcKBDnAmC1DuxQHaE7?w=215&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '【本案卷宗封面照片】法庭審判司法天平現場照片',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.Xt1C-7meX374BAg86KC6LwHaE8?w=89&h=89&c=1&rs=1&qlt=70&r=0&o=7&pid=InlineBlock&rm=3',
      source: '最高法院司法卷宗圖書館（102年度訴字第102號...）',
    ),
    CaseImage(
      url:
          'https://tse1.mm.bing.net/th/id/OIP.fEDFLQLHjS3QuE4bQLgBvQHaE8?w=229&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '法規沿革與憲法判決法典（102年度訴字第102號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.CR03_AAGv7DichRpWnF7NQHaE7?w=233&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '本案訴訟卷宗外觀及編號（102年度訴字第102號...）',
    ),
    CaseImage(
      url:
          'https://tse4.mm.bing.net/th/id/OIP.BpIJPdGnK-nMpGs5B9306AHaFe?w=206&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '地方法院簡易庭外觀與開庭公告（102年度訴字第102號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.EQboFDqbqWRcR8PTOr3wQwHaDn?w=297&h=171&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '當事人提出之訴狀首頁抄本（102年度訴字第102號...）',
    ),
    CaseImage(
      url:
          'https://tse3.mm.bing.net/th/id/OIP.rgvPoDUIQa-Gb56tJrl6sgHaEO?w=89&h=90&c=1&rs=1&qlt=70&r=0&o=7&pid=InlineBlock&rm=3',
      source: '司法裁判書電子檔之判決主文（102年度訴字第102號...）',
    ),
    CaseImage(
      url:
          'https://tse4.mm.bing.net/th/id/OIP.zbbKZ0Bh_CpP6eZamtCRjwHaE9?w=179&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '民事起訴狀與委任律師書狀（102年度訴字第102號...）',
    ),
    CaseImage(
      url:
          'https://tse4.mm.bing.net/th/id/OIP.FVJkOeXgZVSaQPF4GFSr2QHaD8?w=89&h=90&c=1&rs=1&qlt=70&r=0&o=7&pid=InlineBlock&rm=3',
      source: '法院準備程序筆錄簽名欄位（102年度訴字第102號...）',
    ),
    CaseImage(
      url:
          'https://tse4.mm.bing.net/th/id/OIP.0SDoAANiAP6UoZPUrt3UqwHaEN?w=252&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '司法院大法官憲法法庭開庭現場（102年度訴字第102號...）',
    ),
    CaseImage(
      url:
          'https://tse1.mm.bing.net/th/id/OIP.kgAAgTi1mrNURfP1WvpUNQHaFj?w=89&h=90&c=1&rs=1&qlt=70&r=0&o=7&pid=InlineBlock&rm=3',
      source: '最高法院民事庭開庭大門外觀（102年度訴字第102號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.FxsIbUCjMd4IlOEskxShJgHaFj?w=89&h=89&c=1&rs=1&qlt=70&r=0&o=7&pid=InlineBlock&rm=3',
      source: '法學文獻與期刊論文引用頁面（102年度訴字第102號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.22mIh8FxQ1xTrLJEOF-vTgHaEO?w=89&h=89&c=1&rs=1&qlt=70&r=0&o=7&pid=InlineBlock&rm=3',
      source: '中華民國六法全書民法債編法條（102年度訴字第102號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.wXoezXbxYh3d5XAsPQA1mwHaE8?w=193&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '民事訴訟小額程序開庭流程圖（102年度訴字第102號...）',
    ),
    CaseImage(
      url:
          'https://tse3.mm.bing.net/th/id/OIP.8vGwbgtGBjFRl90_W32HlwHaE7?w=232&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '判決確定證明書與執行憑證抄本（102年度訴字第102號...）',
    )
  ],
  'case-003': const [
    CaseImage(
      url:
          'https://tse4.mm.bing.net/th/id/OIP.Q7FEnIHkrd6q9Jmu1GiKkwHaEj?w=248&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '【本案卷宗封面照片】法庭審判司法天平現場照片',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.WVO6tR5BzOgw0oglmH02OAHaEP?w=208&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '最高法院司法卷宗圖書館（104年度訴字第103號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.wXoezXbxYh3d5XAsPQA1mwHaE8?w=193&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '法規沿革與憲法判決法典（104年度訴字第103號...）',
    ),
    CaseImage(
      url:
          'https://tse4.mm.bing.net/th/id/OIP.FVJkOeXgZVSaQPF4GFSr2QHaD8?w=89&h=90&c=1&rs=1&qlt=70&r=0&o=7&pid=InlineBlock&rm=3',
      source: '本案訴訟卷宗外觀及編號（104年度訴字第103號...）',
    ),
    CaseImage(
      url:
          'https://tse3.mm.bing.net/th/id/OIP.RHmdPX6UGcKBDnAmC1DuxQHaE7?w=215&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '地方法院簡易庭外觀與開庭公告（104年度訴字第103號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.EQboFDqbqWRcR8PTOr3wQwHaDn?w=297&h=171&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '當事人提出之訴狀首頁抄本（104年度訴字第103號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.jgOpaPncHSivavrOTSAXLgHaE8?w=232&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '司法裁判書電子檔之判決主文（104年度訴字第103號...）',
    ),
    CaseImage(
      url:
          'https://tse3.mm.bing.net/th/id/OIP.FzL2M5zkVz2nUbqZg7Qe-QHaE7?w=215&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '民事起訴狀與委任律師書狀（104年度訴字第103號...）',
    ),
    CaseImage(
      url:
          'https://tse4.mm.bing.net/th/id/OIP.zbbKZ0Bh_CpP6eZamtCRjwHaE9?w=179&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '法院準備程序筆錄簽名欄位（104年度訴字第103號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.22mIh8FxQ1xTrLJEOF-vTgHaEO?w=89&h=89&c=1&rs=1&qlt=70&r=0&o=7&pid=InlineBlock&rm=3',
      source: '司法院大法官憲法法庭開庭現場（104年度訴字第103號...）',
    ),
    CaseImage(
      url:
          'https://tse1.mm.bing.net/th/id/OIP.fEDFLQLHjS3QuE4bQLgBvQHaE8?w=229&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '最高法院民事庭開庭大門外觀（104年度訴字第103號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.Xt1C-7meX374BAg86KC6LwHaE8?w=89&h=89&c=1&rs=1&qlt=70&r=0&o=7&pid=InlineBlock&rm=3',
      source: '法學文獻與期刊論文引用頁面（104年度訴字第103號...）',
    ),
    CaseImage(
      url:
          'https://tse4.mm.bing.net/th/id/OIP.0SDoAANiAP6UoZPUrt3UqwHaEN?w=252&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '中華民國六法全書民法債編法條（104年度訴字第103號...）',
    ),
    CaseImage(
      url:
          'https://tse3.mm.bing.net/th/id/OIP.8vGwbgtGBjFRl90_W32HlwHaE7?w=232&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '民事訴訟小額程序開庭流程圖（104年度訴字第103號...）',
    ),
    CaseImage(
      url:
          'https://tse1.mm.bing.net/th/id/OIP.kgAAgTi1mrNURfP1WvpUNQHaFj?w=89&h=90&c=1&rs=1&qlt=70&r=0&o=7&pid=InlineBlock&rm=3',
      source: '判決確定證明書與執行憑證抄本（104年度訴字第103號...）',
    )
  ],
  'case-004': const [
    CaseImage(
      url:
          'https://tse1.mm.bing.net/th/id/OIP.fEDFLQLHjS3QuE4bQLgBvQHaE8?w=229&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '【本案卷宗封面照片】法庭審判司法天平現場照片',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.FxsIbUCjMd4IlOEskxShJgHaFj?w=89&h=89&c=1&rs=1&qlt=70&r=0&o=7&pid=InlineBlock&rm=3',
      source: '最高法院司法卷宗圖書館（106年度訴字第104號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.M1ZTFf8JShiFpHtxNdAuTwHaEz?w=227&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '法規沿革與憲法判決法典（106年度訴字第104號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.CR03_AAGv7DichRpWnF7NQHaE7?w=233&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '本案訴訟卷宗外觀及編號（106年度訴字第104號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.6_z7cGk1TU-RBgQM3tsqZQHaE8?w=221&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '地方法院簡易庭外觀與開庭公告（106年度訴字第104號...）',
    ),
    CaseImage(
      url:
          'https://tse3.mm.bing.net/th/id/OIP.8vGwbgtGBjFRl90_W32HlwHaE7?w=232&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '當事人提出之訴狀首頁抄本（106年度訴字第104號...）',
    ),
    CaseImage(
      url:
          'https://tse4.mm.bing.net/th/id/OIP.zbbKZ0Bh_CpP6eZamtCRjwHaE9?w=179&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '司法裁判書電子檔之判決主文（106年度訴字第104號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.jgOpaPncHSivavrOTSAXLgHaE8?w=232&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '民事起訴狀與委任律師書狀（106年度訴字第104號...）',
    ),
    CaseImage(
      url:
          'https://tse1.mm.bing.net/th/id/OIP.kgAAgTi1mrNURfP1WvpUNQHaFj?w=89&h=90&c=1&rs=1&qlt=70&r=0&o=7&pid=InlineBlock&rm=3',
      source: '法院準備程序筆錄簽名欄位（106年度訴字第104號...）',
    ),
    CaseImage(
      url:
          'https://tse3.mm.bing.net/th/id/OIP.rgvPoDUIQa-Gb56tJrl6sgHaEO?w=89&h=90&c=1&rs=1&qlt=70&r=0&o=7&pid=InlineBlock&rm=3',
      source: '司法院大法官憲法法庭開庭現場（106年度訴字第104號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.wXoezXbxYh3d5XAsPQA1mwHaE8?w=193&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '最高法院民事庭開庭大門外觀（106年度訴字第104號...）',
    ),
    CaseImage(
      url:
          'https://tse3.mm.bing.net/th/id/OIP.FzL2M5zkVz2nUbqZg7Qe-QHaE7?w=215&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '法學文獻與期刊論文引用頁面（106年度訴字第104號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.Xt1C-7meX374BAg86KC6LwHaE8?w=89&h=89&c=1&rs=1&qlt=70&r=0&o=7&pid=InlineBlock&rm=3',
      source: '中華民國六法全書民法債編法條（106年度訴字第104號...）',
    ),
    CaseImage(
      url:
          'https://tse4.mm.bing.net/th/id/OIP.Q7FEnIHkrd6q9Jmu1GiKkwHaEj?w=248&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '民事訴訟小額程序開庭流程圖（106年度訴字第104號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.22mIh8FxQ1xTrLJEOF-vTgHaEO?w=89&h=89&c=1&rs=1&qlt=70&r=0&o=7&pid=InlineBlock&rm=3',
      source: '判決確定證明書與執行憑證抄本（106年度訴字第104號...）',
    )
  ],
  'case-005': const [
    CaseImage(
      url:
          'https://tse4.mm.bing.net/th/id/OIP.Q7FEnIHkrd6q9Jmu1GiKkwHaEj?w=248&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '【本案卷宗封面照片】法庭審判司法天平現場照片',
    ),
    CaseImage(
      url:
          'https://tse3.mm.bing.net/th/id/OIP.rgvPoDUIQa-Gb56tJrl6sgHaEO?w=89&h=90&c=1&rs=1&qlt=70&r=0&o=7&pid=InlineBlock&rm=3',
      source: '最高法院司法卷宗圖書館（107年度訴字第105號...）',
    ),
    CaseImage(
      url:
          'https://tse4.mm.bing.net/th/id/OIP.0SDoAANiAP6UoZPUrt3UqwHaEN?w=252&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '法規沿革與憲法判決法典（107年度訴字第105號...）',
    ),
    CaseImage(
      url:
          'https://tse4.mm.bing.net/th/id/OIP.FVJkOeXgZVSaQPF4GFSr2QHaD8?w=89&h=90&c=1&rs=1&qlt=70&r=0&o=7&pid=InlineBlock&rm=3',
      source: '本案訴訟卷宗外觀及編號（107年度訴字第105號...）',
    ),
    CaseImage(
      url:
          'https://tse3.mm.bing.net/th/id/OIP.8vGwbgtGBjFRl90_W32HlwHaE7?w=232&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '地方法院簡易庭外觀與開庭公告（107年度訴字第105號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.EQboFDqbqWRcR8PTOr3wQwHaDn?w=297&h=171&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '當事人提出之訴狀首頁抄本（107年度訴字第105號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.CR03_AAGv7DichRpWnF7NQHaE7?w=233&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '司法裁判書電子檔之判決主文（107年度訴字第105號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.Xt1C-7meX374BAg86KC6LwHaE8?w=89&h=89&c=1&rs=1&qlt=70&r=0&o=7&pid=InlineBlock&rm=3',
      source: '民事起訴狀與委任律師書狀（107年度訴字第105號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.wXoezXbxYh3d5XAsPQA1mwHaE8?w=193&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '法院準備程序筆錄簽名欄位（107年度訴字第105號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.6_z7cGk1TU-RBgQM3tsqZQHaE8?w=221&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '司法院大法官憲法法庭開庭現場（107年度訴字第105號...）',
    ),
    CaseImage(
      url:
          'https://tse1.mm.bing.net/th/id/OIP.xExaObj3A3nV3olc0K1gmwHaEJ?w=263&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '最高法院民事庭開庭大門外觀（107年度訴字第105號...）',
    ),
    CaseImage(
      url:
          'https://tse3.mm.bing.net/th/id/OIP.FzL2M5zkVz2nUbqZg7Qe-QHaE7?w=215&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '法學文獻與期刊論文引用頁面（107年度訴字第105號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.FxsIbUCjMd4IlOEskxShJgHaFj?w=89&h=89&c=1&rs=1&qlt=70&r=0&o=7&pid=InlineBlock&rm=3',
      source: '中華民國六法全書民法債編法條（107年度訴字第105號...）',
    ),
    CaseImage(
      url:
          'https://tse3.mm.bing.net/th/id/OIP.RHmdPX6UGcKBDnAmC1DuxQHaE7?w=215&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '民事訴訟小額程序開庭流程圖（107年度訴字第105號...）',
    ),
    CaseImage(
      url:
          'https://tse4.mm.bing.net/th/id/OIP.BpIJPdGnK-nMpGs5B9306AHaFe?w=206&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '判決確定證明書與執行憑證抄本（107年度訴字第105號...）',
    )
  ],
  'case-006': const [
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.6_z7cGk1TU-RBgQM3tsqZQHaE8?w=221&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '【本案卷宗封面照片】法庭審判司法天平現場照片',
    ),
    CaseImage(
      url:
          'https://tse1.mm.bing.net/th/id/OIP.kgAAgTi1mrNURfP1WvpUNQHaFj?w=89&h=90&c=1&rs=1&qlt=70&r=0&o=7&pid=InlineBlock&rm=3',
      source: '最高法院司法卷宗圖書館（111年度訴字第106號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.FxsIbUCjMd4IlOEskxShJgHaFj?w=89&h=89&c=1&rs=1&qlt=70&r=0&o=7&pid=InlineBlock&rm=3',
      source: '法規沿革與憲法判決法典（111年度訴字第106號...）',
    ),
    CaseImage(
      url:
          'https://tse1.mm.bing.net/th/id/OIP.fEDFLQLHjS3QuE4bQLgBvQHaE8?w=229&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '本案訴訟卷宗外觀及編號（111年度訴字第106號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.M1ZTFf8JShiFpHtxNdAuTwHaEz?w=227&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '地方法院簡易庭外觀與開庭公告（111年度訴字第106號...）',
    ),
    CaseImage(
      url:
          'https://tse4.mm.bing.net/th/id/OIP.FVJkOeXgZVSaQPF4GFSr2QHaD8?w=89&h=90&c=1&rs=1&qlt=70&r=0&o=7&pid=InlineBlock&rm=3',
      source: '當事人提出之訴狀首頁抄本（111年度訴字第106號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.Xt1C-7meX374BAg86KC6LwHaE8?w=89&h=89&c=1&rs=1&qlt=70&r=0&o=7&pid=InlineBlock&rm=3',
      source: '司法裁判書電子檔之判決主文（111年度訴字第106號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.CR03_AAGv7DichRpWnF7NQHaE7?w=233&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '民事起訴狀與委任律師書狀（111年度訴字第106號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.jgOpaPncHSivavrOTSAXLgHaE8?w=232&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '法院準備程序筆錄簽名欄位（111年度訴字第106號...）',
    ),
    CaseImage(
      url:
          'https://tse4.mm.bing.net/th/id/OIP.0SDoAANiAP6UoZPUrt3UqwHaEN?w=252&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '司法院大法官憲法法庭開庭現場（111年度訴字第106號...）',
    ),
    CaseImage(
      url:
          'https://tse4.mm.bing.net/th/id/OIP.BpIJPdGnK-nMpGs5B9306AHaFe?w=206&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '最高法院民事庭開庭大門外觀（111年度訴字第106號...）',
    ),
    CaseImage(
      url:
          'https://tse4.mm.bing.net/th/id/OIP.Q7FEnIHkrd6q9Jmu1GiKkwHaEj?w=248&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '法學文獻與期刊論文引用頁面（111年度訴字第106號...）',
    ),
    CaseImage(
      url:
          'https://tse3.mm.bing.net/th/id/OIP.RHmdPX6UGcKBDnAmC1DuxQHaE7?w=215&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '中華民國六法全書民法債編法條（111年度訴字第106號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.EQboFDqbqWRcR8PTOr3wQwHaDn?w=297&h=171&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '民事訴訟小額程序開庭流程圖（111年度訴字第106號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.WVO6tR5BzOgw0oglmH02OAHaEP?w=208&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '判決確定證明書與執行憑證抄本（111年度訴字第106號...）',
    )
  ],
  'case-007': const [
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.wXoezXbxYh3d5XAsPQA1mwHaE8?w=193&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '【本案卷宗封面照片】法庭審判司法天平現場照片',
    ),
    CaseImage(
      url:
          'https://tse4.mm.bing.net/th/id/OIP.FVJkOeXgZVSaQPF4GFSr2QHaD8?w=89&h=90&c=1&rs=1&qlt=70&r=0&o=7&pid=InlineBlock&rm=3',
      source: '最高法院司法卷宗圖書館（105年度訴字第107號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.CR03_AAGv7DichRpWnF7NQHaE7?w=233&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '法規沿革與憲法判決法典（105年度訴字第107號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.Xt1C-7meX374BAg86KC6LwHaE8?w=89&h=89&c=1&rs=1&qlt=70&r=0&o=7&pid=InlineBlock&rm=3',
      source: '本案訴訟卷宗外觀及編號（105年度訴字第107號...）',
    ),
    CaseImage(
      url:
          'https://tse3.mm.bing.net/th/id/OIP.rgvPoDUIQa-Gb56tJrl6sgHaEO?w=89&h=90&c=1&rs=1&qlt=70&r=0&o=7&pid=InlineBlock&rm=3',
      source: '地方法院簡易庭外觀與開庭公告（105年度訴字第107號...）',
    ),
    CaseImage(
      url:
          'https://tse3.mm.bing.net/th/id/OIP.RHmdPX6UGcKBDnAmC1DuxQHaE7?w=215&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '當事人提出之訴狀首頁抄本（105年度訴字第107號...）',
    ),
    CaseImage(
      url:
          'https://tse4.mm.bing.net/th/id/OIP.BpIJPdGnK-nMpGs5B9306AHaFe?w=206&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '司法裁判書電子檔之判決主文（105年度訴字第107號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.6_z7cGk1TU-RBgQM3tsqZQHaE8?w=221&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '民事起訴狀與委任律師書狀（105年度訴字第107號...）',
    ),
    CaseImage(
      url:
          'https://tse3.mm.bing.net/th/id/OIP.8vGwbgtGBjFRl90_W32HlwHaE7?w=232&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '法院準備程序筆錄簽名欄位（105年度訴字第107號...）',
    ),
    CaseImage(
      url:
          'https://tse3.mm.bing.net/th/id/OIP.FzL2M5zkVz2nUbqZg7Qe-QHaE7?w=215&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '司法院大法官憲法法庭開庭現場（105年度訴字第107號...）',
    ),
    CaseImage(
      url:
          'https://tse4.mm.bing.net/th/id/OIP.Q7FEnIHkrd6q9Jmu1GiKkwHaEj?w=248&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '最高法院民事庭開庭大門外觀（105年度訴字第107號...）',
    ),
    CaseImage(
      url:
          'https://tse4.mm.bing.net/th/id/OIP.0SDoAANiAP6UoZPUrt3UqwHaEN?w=252&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '法學文獻與期刊論文引用頁面（105年度訴字第107號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.M1ZTFf8JShiFpHtxNdAuTwHaEz?w=227&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '中華民國六法全書民法債編法條（105年度訴字第107號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.WVO6tR5BzOgw0oglmH02OAHaEP?w=208&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '民事訴訟小額程序開庭流程圖（105年度訴字第107號...）',
    ),
    CaseImage(
      url:
          'https://tse1.mm.bing.net/th/id/OIP.fEDFLQLHjS3QuE4bQLgBvQHaE8?w=229&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '判決確定證明書與執行憑證抄本（105年度訴字第107號...）',
    )
  ],
  'case-008': const [
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.6_z7cGk1TU-RBgQM3tsqZQHaE8?w=221&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '【本案卷宗封面照片】法庭審判司法天平現場照片',
    ),
    CaseImage(
      url:
          'https://tse4.mm.bing.net/th/id/OIP.FVJkOeXgZVSaQPF4GFSr2QHaD8?w=89&h=90&c=1&rs=1&qlt=70&r=0&o=7&pid=InlineBlock&rm=3',
      source: '最高法院司法卷宗圖書館（109年度訴字第108號...）',
    ),
    CaseImage(
      url:
          'https://tse1.mm.bing.net/th/id/OIP.kgAAgTi1mrNURfP1WvpUNQHaFj?w=89&h=90&c=1&rs=1&qlt=70&r=0&o=7&pid=InlineBlock&rm=3',
      source: '法規沿革與憲法判決法典（109年度訴字第108號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.Xt1C-7meX374BAg86KC6LwHaE8?w=89&h=89&c=1&rs=1&qlt=70&r=0&o=7&pid=InlineBlock&rm=3',
      source: '本案訴訟卷宗外觀及編號（109年度訴字第108號...）',
    ),
    CaseImage(
      url:
          'https://tse3.mm.bing.net/th/id/OIP.8vGwbgtGBjFRl90_W32HlwHaE7?w=232&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '地方法院簡易庭外觀與開庭公告（109年度訴字第108號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.CR03_AAGv7DichRpWnF7NQHaE7?w=233&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '當事人提出之訴狀首頁抄本（109年度訴字第108號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.EQboFDqbqWRcR8PTOr3wQwHaDn?w=297&h=171&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '司法裁判書電子檔之判決主文（109年度訴字第108號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.WVO6tR5BzOgw0oglmH02OAHaEP?w=208&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '民事起訴狀與委任律師書狀（109年度訴字第108號...）',
    ),
    CaseImage(
      url:
          'https://tse1.mm.bing.net/th/id/OIP.fEDFLQLHjS3QuE4bQLgBvQHaE8?w=229&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '法院準備程序筆錄簽名欄位（109年度訴字第108號...）',
    ),
    CaseImage(
      url:
          'https://tse4.mm.bing.net/th/id/OIP.BpIJPdGnK-nMpGs5B9306AHaFe?w=206&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '司法院大法官憲法法庭開庭現場（109年度訴字第108號...）',
    ),
    CaseImage(
      url:
          'https://tse4.mm.bing.net/th/id/OIP.Q7FEnIHkrd6q9Jmu1GiKkwHaEj?w=248&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '最高法院民事庭開庭大門外觀（109年度訴字第108號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.jgOpaPncHSivavrOTSAXLgHaE8?w=232&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '法學文獻與期刊論文引用頁面（109年度訴字第108號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.FxsIbUCjMd4IlOEskxShJgHaFj?w=89&h=89&c=1&rs=1&qlt=70&r=0&o=7&pid=InlineBlock&rm=3',
      source: '中華民國六法全書民法債編法條（109年度訴字第108號...）',
    ),
    CaseImage(
      url:
          'https://tse1.mm.bing.net/th/id/OIP.xExaObj3A3nV3olc0K1gmwHaEJ?w=263&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '民事訴訟小額程序開庭流程圖（109年度訴字第108號...）',
    ),
    CaseImage(
      url:
          'https://tse4.mm.bing.net/th/id/OIP.0SDoAANiAP6UoZPUrt3UqwHaEN?w=252&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '判決確定證明書與執行憑證抄本（109年度訴字第108號...）',
    )
  ],
  'case-009': const [
    CaseImage(
      url:
          'https://tse4.mm.bing.net/th/id/OIP.0SDoAANiAP6UoZPUrt3UqwHaEN?w=252&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '【本案卷宗封面照片】法庭審判司法天平現場照片',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.WVO6tR5BzOgw0oglmH02OAHaEP?w=208&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '最高法院司法卷宗圖書館（108年度訴字第109號...）',
    ),
    CaseImage(
      url:
          'https://tse1.mm.bing.net/th/id/OIP.fEDFLQLHjS3QuE4bQLgBvQHaE8?w=229&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '法規沿革與憲法判決法典（108年度訴字第109號...）',
    ),
    CaseImage(
      url:
          'https://tse4.mm.bing.net/th/id/OIP.Q7FEnIHkrd6q9Jmu1GiKkwHaEj?w=248&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '本案訴訟卷宗外觀及編號（108年度訴字第109號...）',
    ),
    CaseImage(
      url:
          'https://tse4.mm.bing.net/th/id/OIP.BpIJPdGnK-nMpGs5B9306AHaFe?w=206&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '地方法院簡易庭外觀與開庭公告（108年度訴字第109號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.jgOpaPncHSivavrOTSAXLgHaE8?w=232&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '當事人提出之訴狀首頁抄本（108年度訴字第109號...）',
    ),
    CaseImage(
      url:
          'https://tse4.mm.bing.net/th/id/OIP.zbbKZ0Bh_CpP6eZamtCRjwHaE9?w=179&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '司法裁判書電子檔之判決主文（108年度訴字第109號...）',
    ),
    CaseImage(
      url:
          'https://tse3.mm.bing.net/th/id/OIP.FzL2M5zkVz2nUbqZg7Qe-QHaE7?w=215&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '民事起訴狀與委任律師書狀（108年度訴字第109號...）',
    ),
    CaseImage(
      url:
          'https://tse3.mm.bing.net/th/id/OIP.8vGwbgtGBjFRl90_W32HlwHaE7?w=232&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '法院準備程序筆錄簽名欄位（108年度訴字第109號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.FxsIbUCjMd4IlOEskxShJgHaFj?w=89&h=89&c=1&rs=1&qlt=70&r=0&o=7&pid=InlineBlock&rm=3',
      source: '司法院大法官憲法法庭開庭現場（108年度訴字第109號...）',
    ),
    CaseImage(
      url:
          'https://tse4.mm.bing.net/th/id/OIP.FVJkOeXgZVSaQPF4GFSr2QHaD8?w=89&h=90&c=1&rs=1&qlt=70&r=0&o=7&pid=InlineBlock&rm=3',
      source: '最高法院民事庭開庭大門外觀（108年度訴字第109號...）',
    ),
    CaseImage(
      url:
          'https://tse1.mm.bing.net/th/id/OIP.xExaObj3A3nV3olc0K1gmwHaEJ?w=263&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '法學文獻與期刊論文引用頁面（108年度訴字第109號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.EQboFDqbqWRcR8PTOr3wQwHaDn?w=297&h=171&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '中華民國六法全書民法債編法條（108年度訴字第109號...）',
    ),
    CaseImage(
      url:
          'https://tse3.mm.bing.net/th/id/OIP.rgvPoDUIQa-Gb56tJrl6sgHaEO?w=89&h=90&c=1&rs=1&qlt=70&r=0&o=7&pid=InlineBlock&rm=3',
      source: '民事訴訟小額程序開庭流程圖（108年度訴字第109號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.Xt1C-7meX374BAg86KC6LwHaE8?w=89&h=89&c=1&rs=1&qlt=70&r=0&o=7&pid=InlineBlock&rm=3',
      source: '判決確定證明書與執行憑證抄本（108年度訴字第109號...）',
    )
  ],
  'case-010': const [
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.WVO6tR5BzOgw0oglmH02OAHaEP?w=208&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '【本案卷宗封面照片】法庭審判司法天平現場照片',
    ),
    CaseImage(
      url:
          'https://tse1.mm.bing.net/th/id/OIP.kgAAgTi1mrNURfP1WvpUNQHaFj?w=89&h=90&c=1&rs=1&qlt=70&r=0&o=7&pid=InlineBlock&rm=3',
      source: '最高法院司法卷宗圖書館（110年度訴字第110號...）',
    ),
    CaseImage(
      url:
          'https://tse4.mm.bing.net/th/id/OIP.FVJkOeXgZVSaQPF4GFSr2QHaD8?w=89&h=90&c=1&rs=1&qlt=70&r=0&o=7&pid=InlineBlock&rm=3',
      source: '法規沿革與憲法判決法典（110年度訴字第110號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.jgOpaPncHSivavrOTSAXLgHaE8?w=232&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '本案訴訟卷宗外觀及編號（110年度訴字第110號...）',
    ),
    CaseImage(
      url:
          'https://tse4.mm.bing.net/th/id/OIP.BpIJPdGnK-nMpGs5B9306AHaFe?w=206&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '地方法院簡易庭外觀與開庭公告（110年度訴字第110號...）',
    ),
    CaseImage(
      url:
          'https://tse1.mm.bing.net/th/id/OIP.xExaObj3A3nV3olc0K1gmwHaEJ?w=263&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '當事人提出之訴狀首頁抄本（110年度訴字第110號...）',
    ),
    CaseImage(
      url:
          'https://tse3.mm.bing.net/th/id/OIP.FzL2M5zkVz2nUbqZg7Qe-QHaE7?w=215&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '司法裁判書電子檔之判決主文（110年度訴字第110號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.wXoezXbxYh3d5XAsPQA1mwHaE8?w=193&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '民事起訴狀與委任律師書狀（110年度訴字第110號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.Xt1C-7meX374BAg86KC6LwHaE8?w=89&h=89&c=1&rs=1&qlt=70&r=0&o=7&pid=InlineBlock&rm=3',
      source: '法院準備程序筆錄簽名欄位（110年度訴字第110號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.CR03_AAGv7DichRpWnF7NQHaE7?w=233&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '司法院大法官憲法法庭開庭現場（110年度訴字第110號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.6_z7cGk1TU-RBgQM3tsqZQHaE8?w=221&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '最高法院民事庭開庭大門外觀（110年度訴字第110號...）',
    ),
    CaseImage(
      url:
          'https://tse3.mm.bing.net/th/id/OIP.rgvPoDUIQa-Gb56tJrl6sgHaEO?w=89&h=90&c=1&rs=1&qlt=70&r=0&o=7&pid=InlineBlock&rm=3',
      source: '法學文獻與期刊論文引用頁面（110年度訴字第110號...）',
    ),
    CaseImage(
      url:
          'https://tse3.mm.bing.net/th/id/OIP.8vGwbgtGBjFRl90_W32HlwHaE7?w=232&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '中華民國六法全書民法債編法條（110年度訴字第110號...）',
    ),
    CaseImage(
      url:
          'https://tse4.mm.bing.net/th/id/OIP.Q7FEnIHkrd6q9Jmu1GiKkwHaEj?w=248&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '民事訴訟小額程序開庭流程圖（110年度訴字第110號...）',
    ),
    CaseImage(
      url:
          'https://tse1.mm.bing.net/th/id/OIP.fEDFLQLHjS3QuE4bQLgBvQHaE8?w=229&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '判決確定證明書與執行憑證抄本（110年度訴字第110號...）',
    )
  ],
  'case-011': const [
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.wXoezXbxYh3d5XAsPQA1mwHaE8?w=193&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '【本案卷宗封面照片】法庭審判司法天平現場照片',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.6_z7cGk1TU-RBgQM3tsqZQHaE8?w=221&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '最高法院司法卷宗圖書館（112年度訴字第111號...）',
    ),
    CaseImage(
      url:
          'https://tse1.mm.bing.net/th/id/OIP.kgAAgTi1mrNURfP1WvpUNQHaFj?w=89&h=90&c=1&rs=1&qlt=70&r=0&o=7&pid=InlineBlock&rm=3',
      source: '法規沿革與憲法判決法典（112年度訴字第111號...）',
    ),
    CaseImage(
      url:
          'https://tse4.mm.bing.net/th/id/OIP.0SDoAANiAP6UoZPUrt3UqwHaEN?w=252&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '本案訴訟卷宗外觀及編號（112年度訴字第111號...）',
    ),
    CaseImage(
      url:
          'https://tse3.mm.bing.net/th/id/OIP.FzL2M5zkVz2nUbqZg7Qe-QHaE7?w=215&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '地方法院簡易庭外觀與開庭公告（112年度訴字第111號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.WVO6tR5BzOgw0oglmH02OAHaEP?w=208&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '當事人提出之訴狀首頁抄本（112年度訴字第111號...）',
    ),
    CaseImage(
      url:
          'https://tse4.mm.bing.net/th/id/OIP.FVJkOeXgZVSaQPF4GFSr2QHaD8?w=89&h=90&c=1&rs=1&qlt=70&r=0&o=7&pid=InlineBlock&rm=3',
      source: '司法裁判書電子檔之判決主文（112年度訴字第111號...）',
    ),
    CaseImage(
      url:
          'https://tse4.mm.bing.net/th/id/OIP.zbbKZ0Bh_CpP6eZamtCRjwHaE9?w=179&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '民事起訴狀與委任律師書狀（112年度訴字第111號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.CR03_AAGv7DichRpWnF7NQHaE7?w=233&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '法院準備程序筆錄簽名欄位（112年度訴字第111號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.FxsIbUCjMd4IlOEskxShJgHaFj?w=89&h=89&c=1&rs=1&qlt=70&r=0&o=7&pid=InlineBlock&rm=3',
      source: '司法院大法官憲法法庭開庭現場（112年度訴字第111號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.jgOpaPncHSivavrOTSAXLgHaE8?w=232&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '最高法院民事庭開庭大門外觀（112年度訴字第111號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.M1ZTFf8JShiFpHtxNdAuTwHaEz?w=227&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '法學文獻與期刊論文引用頁面（112年度訴字第111號...）',
    ),
    CaseImage(
      url:
          'https://tse4.mm.bing.net/th/id/OIP.BpIJPdGnK-nMpGs5B9306AHaFe?w=206&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '中華民國六法全書民法債編法條（112年度訴字第111號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.EQboFDqbqWRcR8PTOr3wQwHaDn?w=297&h=171&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '民事訴訟小額程序開庭流程圖（112年度訴字第111號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.22mIh8FxQ1xTrLJEOF-vTgHaEO?w=89&h=89&c=1&rs=1&qlt=70&r=0&o=7&pid=InlineBlock&rm=3',
      source: '判決確定證明書與執行憑證抄本（112年度訴字第111號...）',
    )
  ],
  'case-012': const [
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.EQboFDqbqWRcR8PTOr3wQwHaDn?w=297&h=171&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '【本案卷宗封面照片】法庭審判司法天平現場照片',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.wXoezXbxYh3d5XAsPQA1mwHaE8?w=193&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '最高法院司法卷宗圖書館（110年度訴字第112號...）',
    ),
    CaseImage(
      url:
          'https://tse3.mm.bing.net/th/id/OIP.8vGwbgtGBjFRl90_W32HlwHaE7?w=232&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '法規沿革與憲法判決法典（110年度訴字第112號...）',
    ),
    CaseImage(
      url:
          'https://tse1.mm.bing.net/th/id/OIP.kgAAgTi1mrNURfP1WvpUNQHaFj?w=89&h=90&c=1&rs=1&qlt=70&r=0&o=7&pid=InlineBlock&rm=3',
      source: '本案訴訟卷宗外觀及編號（110年度訴字第112號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.22mIh8FxQ1xTrLJEOF-vTgHaEO?w=89&h=89&c=1&rs=1&qlt=70&r=0&o=7&pid=InlineBlock&rm=3',
      source: '地方法院簡易庭外觀與開庭公告（110年度訴字第112號...）',
    ),
    CaseImage(
      url:
          'https://tse4.mm.bing.net/th/id/OIP.0SDoAANiAP6UoZPUrt3UqwHaEN?w=252&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '當事人提出之訴狀首頁抄本（110年度訴字第112號...）',
    ),
    CaseImage(
      url:
          'https://tse4.mm.bing.net/th/id/OIP.FVJkOeXgZVSaQPF4GFSr2QHaD8?w=89&h=90&c=1&rs=1&qlt=70&r=0&o=7&pid=InlineBlock&rm=3',
      source: '司法裁判書電子檔之判決主文（110年度訴字第112號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.6_z7cGk1TU-RBgQM3tsqZQHaE8?w=221&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '民事起訴狀與委任律師書狀（110年度訴字第112號...）',
    ),
    CaseImage(
      url:
          'https://tse4.mm.bing.net/th/id/OIP.zbbKZ0Bh_CpP6eZamtCRjwHaE9?w=179&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '法院準備程序筆錄簽名欄位（110年度訴字第112號...）',
    ),
    CaseImage(
      url:
          'https://tse3.mm.bing.net/th/id/OIP.FzL2M5zkVz2nUbqZg7Qe-QHaE7?w=215&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '司法院大法官憲法法庭開庭現場（110年度訴字第112號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.jgOpaPncHSivavrOTSAXLgHaE8?w=232&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '最高法院民事庭開庭大門外觀（110年度訴字第112號...）',
    ),
    CaseImage(
      url:
          'https://tse1.mm.bing.net/th/id/OIP.fEDFLQLHjS3QuE4bQLgBvQHaE8?w=229&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '法學文獻與期刊論文引用頁面（110年度訴字第112號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.Xt1C-7meX374BAg86KC6LwHaE8?w=89&h=89&c=1&rs=1&qlt=70&r=0&o=7&pid=InlineBlock&rm=3',
      source: '中華民國六法全書民法債編法條（110年度訴字第112號...）',
    ),
    CaseImage(
      url:
          'https://tse4.mm.bing.net/th/id/OIP.BpIJPdGnK-nMpGs5B9306AHaFe?w=206&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '民事訴訟小額程序開庭流程圖（110年度訴字第112號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.FxsIbUCjMd4IlOEskxShJgHaFj?w=89&h=89&c=1&rs=1&qlt=70&r=0&o=7&pid=InlineBlock&rm=3',
      source: '判決確定證明書與執行憑證抄本（110年度訴字第112號...）',
    )
  ],
  'case-013': const [
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.Xt1C-7meX374BAg86KC6LwHaE8?w=89&h=89&c=1&rs=1&qlt=70&r=0&o=7&pid=InlineBlock&rm=3',
      source: '【本案卷宗封面照片】法庭審判司法天平現場照片',
    ),
    CaseImage(
      url:
          'https://tse4.mm.bing.net/th/id/OIP.BpIJPdGnK-nMpGs5B9306AHaFe?w=206&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '最高法院司法卷宗圖書館（111年度訴字第113號...）',
    ),
    CaseImage(
      url:
          'https://tse4.mm.bing.net/th/id/OIP.FVJkOeXgZVSaQPF4GFSr2QHaD8?w=89&h=90&c=1&rs=1&qlt=70&r=0&o=7&pid=InlineBlock&rm=3',
      source: '法規沿革與憲法判決法典（111年度訴字第113號...）',
    ),
    CaseImage(
      url:
          'https://tse3.mm.bing.net/th/id/OIP.FzL2M5zkVz2nUbqZg7Qe-QHaE7?w=215&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '本案訴訟卷宗外觀及編號（111年度訴字第113號...）',
    ),
    CaseImage(
      url:
          'https://tse1.mm.bing.net/th/id/OIP.xExaObj3A3nV3olc0K1gmwHaEJ?w=263&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '地方法院簡易庭外觀與開庭公告（111年度訴字第113號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.EQboFDqbqWRcR8PTOr3wQwHaDn?w=297&h=171&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '當事人提出之訴狀首頁抄本（111年度訴字第113號...）',
    ),
    CaseImage(
      url:
          'https://tse4.mm.bing.net/th/id/OIP.Q7FEnIHkrd6q9Jmu1GiKkwHaEj?w=248&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '司法裁判書電子檔之判決主文（111年度訴字第113號...）',
    ),
    CaseImage(
      url:
          'https://tse3.mm.bing.net/th/id/OIP.rgvPoDUIQa-Gb56tJrl6sgHaEO?w=89&h=90&c=1&rs=1&qlt=70&r=0&o=7&pid=InlineBlock&rm=3',
      source: '民事起訴狀與委任律師書狀（111年度訴字第113號...）',
    ),
    CaseImage(
      url:
          'https://tse3.mm.bing.net/th/id/OIP.RHmdPX6UGcKBDnAmC1DuxQHaE7?w=215&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '法院準備程序筆錄簽名欄位（111年度訴字第113號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.M1ZTFf8JShiFpHtxNdAuTwHaEz?w=227&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '司法院大法官憲法法庭開庭現場（111年度訴字第113號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.WVO6tR5BzOgw0oglmH02OAHaEP?w=208&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '最高法院民事庭開庭大門外觀（111年度訴字第113號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.6_z7cGk1TU-RBgQM3tsqZQHaE8?w=221&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '法學文獻與期刊論文引用頁面（111年度訴字第113號...）',
    ),
    CaseImage(
      url:
          'https://tse4.mm.bing.net/th/id/OIP.zbbKZ0Bh_CpP6eZamtCRjwHaE9?w=179&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '中華民國六法全書民法債編法條（111年度訴字第113號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.FxsIbUCjMd4IlOEskxShJgHaFj?w=89&h=89&c=1&rs=1&qlt=70&r=0&o=7&pid=InlineBlock&rm=3',
      source: '民事訴訟小額程序開庭流程圖（111年度訴字第113號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.22mIh8FxQ1xTrLJEOF-vTgHaEO?w=89&h=89&c=1&rs=1&qlt=70&r=0&o=7&pid=InlineBlock&rm=3',
      source: '判決確定證明書與執行憑證抄本（111年度訴字第113號...）',
    )
  ],
  'case-014': const [
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.22mIh8FxQ1xTrLJEOF-vTgHaEO?w=89&h=89&c=1&rs=1&qlt=70&r=0&o=7&pid=InlineBlock&rm=3',
      source: '【本案卷宗封面照片】法庭審判司法天平現場照片',
    ),
    CaseImage(
      url:
          'https://tse3.mm.bing.net/th/id/OIP.FzL2M5zkVz2nUbqZg7Qe-QHaE7?w=215&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '最高法院司法卷宗圖書館（113年度訴字第114號...）',
    ),
    CaseImage(
      url:
          'https://tse3.mm.bing.net/th/id/OIP.RHmdPX6UGcKBDnAmC1DuxQHaE7?w=215&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '法規沿革與憲法判決法典（113年度訴字第114號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.EQboFDqbqWRcR8PTOr3wQwHaDn?w=297&h=171&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '本案訴訟卷宗外觀及編號（113年度訴字第114號...）',
    ),
    CaseImage(
      url:
          'https://tse4.mm.bing.net/th/id/OIP.FVJkOeXgZVSaQPF4GFSr2QHaD8?w=89&h=90&c=1&rs=1&qlt=70&r=0&o=7&pid=InlineBlock&rm=3',
      source: '地方法院簡易庭外觀與開庭公告（113年度訴字第114號...）',
    ),
    CaseImage(
      url:
          'https://tse1.mm.bing.net/th/id/OIP.xExaObj3A3nV3olc0K1gmwHaEJ?w=263&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '當事人提出之訴狀首頁抄本（113年度訴字第114號...）',
    ),
    CaseImage(
      url:
          'https://tse4.mm.bing.net/th/id/OIP.BpIJPdGnK-nMpGs5B9306AHaFe?w=206&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '司法裁判書電子檔之判決主文（113年度訴字第114號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.M1ZTFf8JShiFpHtxNdAuTwHaEz?w=227&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '民事起訴狀與委任律師書狀（113年度訴字第114號...）',
    ),
    CaseImage(
      url:
          'https://tse1.mm.bing.net/th/id/OIP.fEDFLQLHjS3QuE4bQLgBvQHaE8?w=229&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '法院準備程序筆錄簽名欄位（113年度訴字第114號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.wXoezXbxYh3d5XAsPQA1mwHaE8?w=193&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '司法院大法官憲法法庭開庭現場（113年度訴字第114號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.jgOpaPncHSivavrOTSAXLgHaE8?w=232&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '最高法院民事庭開庭大門外觀（113年度訴字第114號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.6_z7cGk1TU-RBgQM3tsqZQHaE8?w=221&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '法學文獻與期刊論文引用頁面（113年度訴字第114號...）',
    ),
    CaseImage(
      url:
          'https://tse3.mm.bing.net/th/id/OIP.rgvPoDUIQa-Gb56tJrl6sgHaEO?w=89&h=90&c=1&rs=1&qlt=70&r=0&o=7&pid=InlineBlock&rm=3',
      source: '中華民國六法全書民法債編法條（113年度訴字第114號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.WVO6tR5BzOgw0oglmH02OAHaEP?w=208&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '民事訴訟小額程序開庭流程圖（113年度訴字第114號...）',
    ),
    CaseImage(
      url:
          'https://tse4.mm.bing.net/th/id/OIP.zbbKZ0Bh_CpP6eZamtCRjwHaE9?w=179&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '判決確定證明書與執行憑證抄本（113年度訴字第114號...）',
    )
  ],
  'case-015': const [
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.FxsIbUCjMd4IlOEskxShJgHaFj?w=89&h=89&c=1&rs=1&qlt=70&r=0&o=7&pid=InlineBlock&rm=3',
      source: '【本案卷宗封面照片】法庭審判司法天平現場照片',
    ),
    CaseImage(
      url:
          'https://tse4.mm.bing.net/th/id/OIP.0SDoAANiAP6UoZPUrt3UqwHaEN?w=252&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '最高法院司法卷宗圖書館（104年度訴字第115號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.WVO6tR5BzOgw0oglmH02OAHaEP?w=208&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '法規沿革與憲法判決法典（104年度訴字第115號...）',
    ),
    CaseImage(
      url:
          'https://tse4.mm.bing.net/th/id/OIP.BpIJPdGnK-nMpGs5B9306AHaFe?w=206&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '本案訴訟卷宗外觀及編號（104年度訴字第115號...）',
    ),
    CaseImage(
      url:
          'https://tse4.mm.bing.net/th/id/OIP.FVJkOeXgZVSaQPF4GFSr2QHaD8?w=89&h=90&c=1&rs=1&qlt=70&r=0&o=7&pid=InlineBlock&rm=3',
      source: '地方法院簡易庭外觀與開庭公告（104年度訴字第115號...）',
    ),
    CaseImage(
      url:
          'https://tse3.mm.bing.net/th/id/OIP.FzL2M5zkVz2nUbqZg7Qe-QHaE7?w=215&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '當事人提出之訴狀首頁抄本（104年度訴字第115號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.jgOpaPncHSivavrOTSAXLgHaE8?w=232&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '司法裁判書電子檔之判決主文（104年度訴字第115號...）',
    ),
    CaseImage(
      url:
          'https://tse4.mm.bing.net/th/id/OIP.zbbKZ0Bh_CpP6eZamtCRjwHaE9?w=179&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '民事起訴狀與委任律師書狀（104年度訴字第115號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.22mIh8FxQ1xTrLJEOF-vTgHaEO?w=89&h=89&c=1&rs=1&qlt=70&r=0&o=7&pid=InlineBlock&rm=3',
      source: '法院準備程序筆錄簽名欄位（104年度訴字第115號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.EQboFDqbqWRcR8PTOr3wQwHaDn?w=297&h=171&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '司法院大法官憲法法庭開庭現場（104年度訴字第115號...）',
    ),
    CaseImage(
      url:
          'https://tse3.mm.bing.net/th/id/OIP.8vGwbgtGBjFRl90_W32HlwHaE7?w=232&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '最高法院民事庭開庭大門外觀（104年度訴字第115號...）',
    ),
    CaseImage(
      url:
          'https://tse4.mm.bing.net/th/id/OIP.Q7FEnIHkrd6q9Jmu1GiKkwHaEj?w=248&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '法學文獻與期刊論文引用頁面（104年度訴字第115號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.wXoezXbxYh3d5XAsPQA1mwHaE8?w=193&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '中華民國六法全書民法債編法條（104年度訴字第115號...）',
    ),
    CaseImage(
      url:
          'https://tse3.mm.bing.net/th/id/OIP.rgvPoDUIQa-Gb56tJrl6sgHaEO?w=89&h=90&c=1&rs=1&qlt=70&r=0&o=7&pid=InlineBlock&rm=3',
      source: '民事訴訟小額程序開庭流程圖（104年度訴字第115號...）',
    ),
    CaseImage(
      url:
          'https://tse1.mm.bing.net/th/id/OIP.xExaObj3A3nV3olc0K1gmwHaEJ?w=263&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '判決確定證明書與執行憑證抄本（104年度訴字第115號...）',
    )
  ],
  'case-016': const [
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.CR03_AAGv7DichRpWnF7NQHaE7?w=233&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '【本案卷宗封面照片】法庭審判司法天平現場照片',
    ),
    CaseImage(
      url:
          'https://tse4.mm.bing.net/th/id/OIP.FVJkOeXgZVSaQPF4GFSr2QHaD8?w=89&h=90&c=1&rs=1&qlt=70&r=0&o=7&pid=InlineBlock&rm=3',
      source: '最高法院司法卷宗圖書館（司法院釋字第 916 號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.jgOpaPncHSivavrOTSAXLgHaE8?w=232&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '法規沿革與憲法判決法典（司法院釋字第 916 號...）',
    ),
    CaseImage(
      url:
          'https://tse3.mm.bing.net/th/id/OIP.RHmdPX6UGcKBDnAmC1DuxQHaE7?w=215&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '本案訴訟卷宗外觀及編號（司法院釋字第 916 號...）',
    ),
    CaseImage(
      url:
          'https://tse4.mm.bing.net/th/id/OIP.Q7FEnIHkrd6q9Jmu1GiKkwHaEj?w=248&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '地方法院簡易庭外觀與開庭公告（司法院釋字第 916 號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.22mIh8FxQ1xTrLJEOF-vTgHaEO?w=89&h=89&c=1&rs=1&qlt=70&r=0&o=7&pid=InlineBlock&rm=3',
      source: '當事人提出之訴狀首頁抄本（司法院釋字第 916 號...）',
    ),
    CaseImage(
      url:
          'https://tse4.mm.bing.net/th/id/OIP.zbbKZ0Bh_CpP6eZamtCRjwHaE9?w=179&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '司法裁判書電子檔之判決主文（司法院釋字第 916 號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.FxsIbUCjMd4IlOEskxShJgHaFj?w=89&h=89&c=1&rs=1&qlt=70&r=0&o=7&pid=InlineBlock&rm=3',
      source: '民事起訴狀與委任律師書狀（司法院釋字第 916 號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.6_z7cGk1TU-RBgQM3tsqZQHaE8?w=221&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '法院準備程序筆錄簽名欄位（司法院釋字第 916 號...）',
    ),
    CaseImage(
      url:
          'https://tse4.mm.bing.net/th/id/OIP.0SDoAANiAP6UoZPUrt3UqwHaEN?w=252&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '司法院大法官憲法法庭開庭現場（司法院釋字第 916 號...）',
    ),
    CaseImage(
      url:
          'https://tse3.mm.bing.net/th/id/OIP.8vGwbgtGBjFRl90_W32HlwHaE7?w=232&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '最高法院民事庭開庭大門外觀（司法院釋字第 916 號...）',
    ),
    CaseImage(
      url:
          'https://tse3.mm.bing.net/th/id/OIP.rgvPoDUIQa-Gb56tJrl6sgHaEO?w=89&h=90&c=1&rs=1&qlt=70&r=0&o=7&pid=InlineBlock&rm=3',
      source: '法學文獻與期刊論文引用頁面（司法院釋字第 916 號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.Xt1C-7meX374BAg86KC6LwHaE8?w=89&h=89&c=1&rs=1&qlt=70&r=0&o=7&pid=InlineBlock&rm=3',
      source: '中華民國六法全書民法債編法條（司法院釋字第 916 號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.EQboFDqbqWRcR8PTOr3wQwHaDn?w=297&h=171&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '民事訴訟小額程序開庭流程圖（司法院釋字第 916 號...）',
    ),
    CaseImage(
      url:
          'https://tse4.mm.bing.net/th/id/OIP.BpIJPdGnK-nMpGs5B9306AHaFe?w=206&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '判決確定證明書與執行憑證抄本（司法院釋字第 916 號...）',
    )
  ],
  'case-017': const [
    CaseImage(
      url:
          'https://tse4.mm.bing.net/th/id/OIP.zbbKZ0Bh_CpP6eZamtCRjwHaE9?w=179&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '【本案卷宗封面照片】法庭審判司法天平現場照片',
    ),
    CaseImage(
      url:
          'https://tse4.mm.bing.net/th/id/OIP.Q7FEnIHkrd6q9Jmu1GiKkwHaEj?w=248&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '最高法院司法卷宗圖書館（司法院釋字第 917 號...）',
    ),
    CaseImage(
      url:
          'https://tse3.mm.bing.net/th/id/OIP.FzL2M5zkVz2nUbqZg7Qe-QHaE7?w=215&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '法規沿革與憲法判決法典（司法院釋字第 917 號...）',
    ),
    CaseImage(
      url:
          'https://tse1.mm.bing.net/th/id/OIP.fEDFLQLHjS3QuE4bQLgBvQHaE8?w=229&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '本案訴訟卷宗外觀及編號（司法院釋字第 917 號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.WVO6tR5BzOgw0oglmH02OAHaEP?w=208&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '地方法院簡易庭外觀與開庭公告（司法院釋字第 917 號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.wXoezXbxYh3d5XAsPQA1mwHaE8?w=193&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '當事人提出之訴狀首頁抄本（司法院釋字第 917 號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.jgOpaPncHSivavrOTSAXLgHaE8?w=232&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '司法裁判書電子檔之判決主文（司法院釋字第 917 號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.EQboFDqbqWRcR8PTOr3wQwHaDn?w=297&h=171&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '民事起訴狀與委任律師書狀（司法院釋字第 917 號...）',
    ),
    CaseImage(
      url:
          'https://tse3.mm.bing.net/th/id/OIP.rgvPoDUIQa-Gb56tJrl6sgHaEO?w=89&h=90&c=1&rs=1&qlt=70&r=0&o=7&pid=InlineBlock&rm=3',
      source: '法院準備程序筆錄簽名欄位（司法院釋字第 917 號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.M1ZTFf8JShiFpHtxNdAuTwHaEz?w=227&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '司法院大法官憲法法庭開庭現場（司法院釋字第 917 號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.Xt1C-7meX374BAg86KC6LwHaE8?w=89&h=89&c=1&rs=1&qlt=70&r=0&o=7&pid=InlineBlock&rm=3',
      source: '最高法院民事庭開庭大門外觀（司法院釋字第 917 號...）',
    ),
    CaseImage(
      url:
          'https://tse1.mm.bing.net/th/id/OIP.kgAAgTi1mrNURfP1WvpUNQHaFj?w=89&h=90&c=1&rs=1&qlt=70&r=0&o=7&pid=InlineBlock&rm=3',
      source: '法學文獻與期刊論文引用頁面（司法院釋字第 917 號...）',
    ),
    CaseImage(
      url:
          'https://tse4.mm.bing.net/th/id/OIP.BpIJPdGnK-nMpGs5B9306AHaFe?w=206&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '中華民國六法全書民法債編法條（司法院釋字第 917 號...）',
    ),
    CaseImage(
      url:
          'https://tse3.mm.bing.net/th/id/OIP.8vGwbgtGBjFRl90_W32HlwHaE7?w=232&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '民事訴訟小額程序開庭流程圖（司法院釋字第 917 號...）',
    ),
    CaseImage(
      url:
          'https://tse1.mm.bing.net/th/id/OIP.xExaObj3A3nV3olc0K1gmwHaEJ?w=263&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '判決確定證明書與執行憑證抄本（司法院釋字第 917 號...）',
    )
  ],
  'case-018': const [
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.22mIh8FxQ1xTrLJEOF-vTgHaEO?w=89&h=89&c=1&rs=1&qlt=70&r=0&o=7&pid=InlineBlock&rm=3',
      source: '【本案卷宗封面照片】法庭審判司法天平現場照片',
    ),
    CaseImage(
      url:
          'https://tse3.mm.bing.net/th/id/OIP.rgvPoDUIQa-Gb56tJrl6sgHaEO?w=89&h=90&c=1&rs=1&qlt=70&r=0&o=7&pid=InlineBlock&rm=3',
      source: '最高法院司法卷宗圖書館（司法院釋字第 918 號...）',
    ),
    CaseImage(
      url:
          'https://tse3.mm.bing.net/th/id/OIP.FzL2M5zkVz2nUbqZg7Qe-QHaE7?w=215&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '法規沿革與憲法判決法典（司法院釋字第 918 號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.Xt1C-7meX374BAg86KC6LwHaE8?w=89&h=89&c=1&rs=1&qlt=70&r=0&o=7&pid=InlineBlock&rm=3',
      source: '本案訴訟卷宗外觀及編號（司法院釋字第 918 號...）',
    ),
    CaseImage(
      url:
          'https://tse3.mm.bing.net/th/id/OIP.8vGwbgtGBjFRl90_W32HlwHaE7?w=232&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '地方法院簡易庭外觀與開庭公告（司法院釋字第 918 號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.EQboFDqbqWRcR8PTOr3wQwHaDn?w=297&h=171&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '當事人提出之訴狀首頁抄本（司法院釋字第 918 號...）',
    ),
    CaseImage(
      url:
          'https://tse4.mm.bing.net/th/id/OIP.Q7FEnIHkrd6q9Jmu1GiKkwHaEj?w=248&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '司法裁判書電子檔之判決主文（司法院釋字第 918 號...）',
    ),
    CaseImage(
      url:
          'https://tse1.mm.bing.net/th/id/OIP.fEDFLQLHjS3QuE4bQLgBvQHaE8?w=229&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '民事起訴狀與委任律師書狀（司法院釋字第 918 號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.6_z7cGk1TU-RBgQM3tsqZQHaE8?w=221&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '法院準備程序筆錄簽名欄位（司法院釋字第 918 號...）',
    ),
    CaseImage(
      url:
          'https://tse4.mm.bing.net/th/id/OIP.FVJkOeXgZVSaQPF4GFSr2QHaD8?w=89&h=90&c=1&rs=1&qlt=70&r=0&o=7&pid=InlineBlock&rm=3',
      source: '司法院大法官憲法法庭開庭現場（司法院釋字第 918 號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.FxsIbUCjMd4IlOEskxShJgHaFj?w=89&h=89&c=1&rs=1&qlt=70&r=0&o=7&pid=InlineBlock&rm=3',
      source: '最高法院民事庭開庭大門外觀（司法院釋字第 918 號...）',
    ),
    CaseImage(
      url:
          'https://tse4.mm.bing.net/th/id/OIP.zbbKZ0Bh_CpP6eZamtCRjwHaE9?w=179&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '法學文獻與期刊論文引用頁面（司法院釋字第 918 號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.CR03_AAGv7DichRpWnF7NQHaE7?w=233&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '中華民國六法全書民法債編法條（司法院釋字第 918 號...）',
    ),
    CaseImage(
      url:
          'https://tse1.mm.bing.net/th/id/OIP.xExaObj3A3nV3olc0K1gmwHaEJ?w=263&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '民事訴訟小額程序開庭流程圖（司法院釋字第 918 號...）',
    ),
    CaseImage(
      url:
          'https://tse1.mm.bing.net/th/id/OIP.kgAAgTi1mrNURfP1WvpUNQHaFj?w=89&h=90&c=1&rs=1&qlt=70&r=0&o=7&pid=InlineBlock&rm=3',
      source: '判決確定證明書與執行憑證抄本（司法院釋字第 918 號...）',
    )
  ],
  'case-019': const [
    CaseImage(
      url:
          'https://tse3.mm.bing.net/th/id/OIP.FzL2M5zkVz2nUbqZg7Qe-QHaE7?w=215&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '【本案卷宗封面照片】法庭審判司法天平現場照片',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.Xt1C-7meX374BAg86KC6LwHaE8?w=89&h=89&c=1&rs=1&qlt=70&r=0&o=7&pid=InlineBlock&rm=3',
      source: '最高法院司法卷宗圖書館（112 年憲判字第 20...）',
    ),
    CaseImage(
      url:
          'https://tse3.mm.bing.net/th/id/OIP.RHmdPX6UGcKBDnAmC1DuxQHaE7?w=215&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '法規沿革與憲法判決法典（112 年憲判字第 20...）',
    ),
    CaseImage(
      url:
          'https://tse4.mm.bing.net/th/id/OIP.Q7FEnIHkrd6q9Jmu1GiKkwHaEj?w=248&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '本案訴訟卷宗外觀及編號（112 年憲判字第 20...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.WVO6tR5BzOgw0oglmH02OAHaEP?w=208&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '地方法院簡易庭外觀與開庭公告（112 年憲判字第 20...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.FxsIbUCjMd4IlOEskxShJgHaFj?w=89&h=89&c=1&rs=1&qlt=70&r=0&o=7&pid=InlineBlock&rm=3',
      source: '當事人提出之訴狀首頁抄本（112 年憲判字第 20...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.EQboFDqbqWRcR8PTOr3wQwHaDn?w=297&h=171&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '司法裁判書電子檔之判決主文（112 年憲判字第 20...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.6_z7cGk1TU-RBgQM3tsqZQHaE8?w=221&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '民事起訴狀與委任律師書狀（112 年憲判字第 20...）',
    ),
    CaseImage(
      url:
          'https://tse1.mm.bing.net/th/id/OIP.xExaObj3A3nV3olc0K1gmwHaEJ?w=263&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '法院準備程序筆錄簽名欄位（112 年憲判字第 20...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.22mIh8FxQ1xTrLJEOF-vTgHaEO?w=89&h=89&c=1&rs=1&qlt=70&r=0&o=7&pid=InlineBlock&rm=3',
      source: '司法院大法官憲法法庭開庭現場（112 年憲判字第 20...）',
    ),
    CaseImage(
      url:
          'https://tse4.mm.bing.net/th/id/OIP.FVJkOeXgZVSaQPF4GFSr2QHaD8?w=89&h=90&c=1&rs=1&qlt=70&r=0&o=7&pid=InlineBlock&rm=3',
      source: '最高法院民事庭開庭大門外觀（112 年憲判字第 20...）',
    ),
    CaseImage(
      url:
          'https://tse1.mm.bing.net/th/id/OIP.fEDFLQLHjS3QuE4bQLgBvQHaE8?w=229&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '法學文獻與期刊論文引用頁面（112 年憲判字第 20...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.M1ZTFf8JShiFpHtxNdAuTwHaEz?w=227&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '中華民國六法全書民法債編法條（112 年憲判字第 20...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.CR03_AAGv7DichRpWnF7NQHaE7?w=233&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '民事訴訟小額程序開庭流程圖（112 年憲判字第 20...）',
    ),
    CaseImage(
      url:
          'https://tse3.mm.bing.net/th/id/OIP.8vGwbgtGBjFRl90_W32HlwHaE7?w=232&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '判決確定證明書與執行憑證抄本（112 年憲判字第 20...）',
    )
  ],
  'case-020': const [
    CaseImage(
      url:
          'https://tse3.mm.bing.net/th/id/OIP.8vGwbgtGBjFRl90_W32HlwHaE7?w=232&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '【本案卷宗封面照片】法庭審判司法天平現場照片',
    ),
    CaseImage(
      url:
          'https://tse4.mm.bing.net/th/id/OIP.Q7FEnIHkrd6q9Jmu1GiKkwHaEj?w=248&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '最高法院司法卷宗圖書館（113 年憲判字第 1 ...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.Xt1C-7meX374BAg86KC6LwHaE8?w=89&h=89&c=1&rs=1&qlt=70&r=0&o=7&pid=InlineBlock&rm=3',
      source: '法規沿革與憲法判決法典（113 年憲判字第 1 ...）',
    ),
    CaseImage(
      url:
          'https://tse3.mm.bing.net/th/id/OIP.rgvPoDUIQa-Gb56tJrl6sgHaEO?w=89&h=90&c=1&rs=1&qlt=70&r=0&o=7&pid=InlineBlock&rm=3',
      source: '本案訴訟卷宗外觀及編號（113 年憲判字第 1 ...）',
    ),
    CaseImage(
      url:
          'https://tse1.mm.bing.net/th/id/OIP.kgAAgTi1mrNURfP1WvpUNQHaFj?w=89&h=90&c=1&rs=1&qlt=70&r=0&o=7&pid=InlineBlock&rm=3',
      source: '地方法院簡易庭外觀與開庭公告（113 年憲判字第 1 ...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.22mIh8FxQ1xTrLJEOF-vTgHaEO?w=89&h=89&c=1&rs=1&qlt=70&r=0&o=7&pid=InlineBlock&rm=3',
      source: '當事人提出之訴狀首頁抄本（113 年憲判字第 1 ...）',
    ),
    CaseImage(
      url:
          'https://tse4.mm.bing.net/th/id/OIP.zbbKZ0Bh_CpP6eZamtCRjwHaE9?w=179&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '司法裁判書電子檔之判決主文（113 年憲判字第 1 ...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.jgOpaPncHSivavrOTSAXLgHaE8?w=232&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '民事起訴狀與委任律師書狀（113 年憲判字第 1 ...）',
    ),
    CaseImage(
      url:
          'https://tse3.mm.bing.net/th/id/OIP.FzL2M5zkVz2nUbqZg7Qe-QHaE7?w=215&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '法院準備程序筆錄簽名欄位（113 年憲判字第 1 ...）',
    ),
    CaseImage(
      url:
          'https://tse3.mm.bing.net/th/id/OIP.RHmdPX6UGcKBDnAmC1DuxQHaE7?w=215&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '司法院大法官憲法法庭開庭現場（113 年憲判字第 1 ...）',
    ),
    CaseImage(
      url:
          'https://tse1.mm.bing.net/th/id/OIP.fEDFLQLHjS3QuE4bQLgBvQHaE8?w=229&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '最高法院民事庭開庭大門外觀（113 年憲判字第 1 ...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.FxsIbUCjMd4IlOEskxShJgHaFj?w=89&h=89&c=1&rs=1&qlt=70&r=0&o=7&pid=InlineBlock&rm=3',
      source: '法學文獻與期刊論文引用頁面（113 年憲判字第 1 ...）',
    ),
    CaseImage(
      url:
          'https://tse4.mm.bing.net/th/id/OIP.BpIJPdGnK-nMpGs5B9306AHaFe?w=206&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '中華民國六法全書民法債編法條（113 年憲判字第 1 ...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.6_z7cGk1TU-RBgQM3tsqZQHaE8?w=221&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '民事訴訟小額程序開庭流程圖（113 年憲判字第 1 ...）',
    ),
    CaseImage(
      url:
          'https://tse4.mm.bing.net/th/id/OIP.0SDoAANiAP6UoZPUrt3UqwHaEN?w=252&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '判決確定證明書與執行憑證抄本（113 年憲判字第 1 ...）',
    )
  ],
  'case-021': const [
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.22mIh8FxQ1xTrLJEOF-vTgHaEO?w=89&h=89&c=1&rs=1&qlt=70&r=0&o=7&pid=InlineBlock&rm=3',
      source: '【本案卷宗封面照片】法庭審判司法天平現場照片',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.FxsIbUCjMd4IlOEskxShJgHaFj?w=89&h=89&c=1&rs=1&qlt=70&r=0&o=7&pid=InlineBlock&rm=3',
      source: '最高法院司法卷宗圖書館（113 年憲判字第 2 ...）',
    ),
    CaseImage(
      url:
          'https://tse3.mm.bing.net/th/id/OIP.8vGwbgtGBjFRl90_W32HlwHaE7?w=232&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '法規沿革與憲法判決法典（113 年憲判字第 2 ...）',
    ),
    CaseImage(
      url:
          'https://tse3.mm.bing.net/th/id/OIP.rgvPoDUIQa-Gb56tJrl6sgHaEO?w=89&h=90&c=1&rs=1&qlt=70&r=0&o=7&pid=InlineBlock&rm=3',
      source: '本案訴訟卷宗外觀及編號（113 年憲判字第 2 ...）',
    ),
    CaseImage(
      url:
          'https://tse1.mm.bing.net/th/id/OIP.kgAAgTi1mrNURfP1WvpUNQHaFj?w=89&h=90&c=1&rs=1&qlt=70&r=0&o=7&pid=InlineBlock&rm=3',
      source: '地方法院簡易庭外觀與開庭公告（113 年憲判字第 2 ...）',
    ),
    CaseImage(
      url:
          'https://tse4.mm.bing.net/th/id/OIP.FVJkOeXgZVSaQPF4GFSr2QHaD8?w=89&h=90&c=1&rs=1&qlt=70&r=0&o=7&pid=InlineBlock&rm=3',
      source: '當事人提出之訴狀首頁抄本（113 年憲判字第 2 ...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.6_z7cGk1TU-RBgQM3tsqZQHaE8?w=221&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '司法裁判書電子檔之判決主文（113 年憲判字第 2 ...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.WVO6tR5BzOgw0oglmH02OAHaEP?w=208&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '民事起訴狀與委任律師書狀（113 年憲判字第 2 ...）',
    ),
    CaseImage(
      url:
          'https://tse1.mm.bing.net/th/id/OIP.xExaObj3A3nV3olc0K1gmwHaEJ?w=263&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '法院準備程序筆錄簽名欄位（113 年憲判字第 2 ...）',
    ),
    CaseImage(
      url:
          'https://tse1.mm.bing.net/th/id/OIP.fEDFLQLHjS3QuE4bQLgBvQHaE8?w=229&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '司法院大法官憲法法庭開庭現場（113 年憲判字第 2 ...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.CR03_AAGv7DichRpWnF7NQHaE7?w=233&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '最高法院民事庭開庭大門外觀（113 年憲判字第 2 ...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.wXoezXbxYh3d5XAsPQA1mwHaE8?w=193&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '法學文獻與期刊論文引用頁面（113 年憲判字第 2 ...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.EQboFDqbqWRcR8PTOr3wQwHaDn?w=297&h=171&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '中華民國六法全書民法債編法條（113 年憲判字第 2 ...）',
    ),
    CaseImage(
      url:
          'https://tse3.mm.bing.net/th/id/OIP.RHmdPX6UGcKBDnAmC1DuxQHaE7?w=215&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '民事訴訟小額程序開庭流程圖（113 年憲判字第 2 ...）',
    ),
    CaseImage(
      url:
          'https://tse4.mm.bing.net/th/id/OIP.Q7FEnIHkrd6q9Jmu1GiKkwHaEj?w=248&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '判決確定證明書與執行憑證抄本（113 年憲判字第 2 ...）',
    )
  ],
  'case-022': const [
    CaseImage(
      url:
          'https://tse4.mm.bing.net/th/id/OIP.BpIJPdGnK-nMpGs5B9306AHaFe?w=206&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '【本案卷宗封面照片】法庭審判司法天平現場照片',
    ),
    CaseImage(
      url:
          'https://tse3.mm.bing.net/th/id/OIP.rgvPoDUIQa-Gb56tJrl6sgHaEO?w=89&h=90&c=1&rs=1&qlt=70&r=0&o=7&pid=InlineBlock&rm=3',
      source: '最高法院司法卷宗圖書館（司法院釋字第 922 號...）',
    ),
    CaseImage(
      url:
          'https://tse4.mm.bing.net/th/id/OIP.0SDoAANiAP6UoZPUrt3UqwHaEN?w=252&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '法規沿革與憲法判決法典（司法院釋字第 922 號...）',
    ),
    CaseImage(
      url:
          'https://tse1.mm.bing.net/th/id/OIP.fEDFLQLHjS3QuE4bQLgBvQHaE8?w=229&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '本案訴訟卷宗外觀及編號（司法院釋字第 922 號...）',
    ),
    CaseImage(
      url:
          'https://tse3.mm.bing.net/th/id/OIP.FzL2M5zkVz2nUbqZg7Qe-QHaE7?w=215&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '地方法院簡易庭外觀與開庭公告（司法院釋字第 922 號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.6_z7cGk1TU-RBgQM3tsqZQHaE8?w=221&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '當事人提出之訴狀首頁抄本（司法院釋字第 922 號...）',
    ),
    CaseImage(
      url:
          'https://tse1.mm.bing.net/th/id/OIP.kgAAgTi1mrNURfP1WvpUNQHaFj?w=89&h=90&c=1&rs=1&qlt=70&r=0&o=7&pid=InlineBlock&rm=3',
      source: '司法裁判書電子檔之判決主文（司法院釋字第 922 號...）',
    ),
    CaseImage(
      url:
          'https://tse4.mm.bing.net/th/id/OIP.FVJkOeXgZVSaQPF4GFSr2QHaD8?w=89&h=90&c=1&rs=1&qlt=70&r=0&o=7&pid=InlineBlock&rm=3',
      source: '民事起訴狀與委任律師書狀（司法院釋字第 922 號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.WVO6tR5BzOgw0oglmH02OAHaEP?w=208&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '法院準備程序筆錄簽名欄位（司法院釋字第 922 號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.wXoezXbxYh3d5XAsPQA1mwHaE8?w=193&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '司法院大法官憲法法庭開庭現場（司法院釋字第 922 號...）',
    ),
    CaseImage(
      url:
          'https://tse3.mm.bing.net/th/id/OIP.RHmdPX6UGcKBDnAmC1DuxQHaE7?w=215&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '最高法院民事庭開庭大門外觀（司法院釋字第 922 號...）',
    ),
    CaseImage(
      url:
          'https://tse1.mm.bing.net/th/id/OIP.xExaObj3A3nV3olc0K1gmwHaEJ?w=263&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '法學文獻與期刊論文引用頁面（司法院釋字第 922 號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.jgOpaPncHSivavrOTSAXLgHaE8?w=232&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '中華民國六法全書民法債編法條（司法院釋字第 922 號...）',
    ),
    CaseImage(
      url:
          'https://tse3.mm.bing.net/th/id/OIP.8vGwbgtGBjFRl90_W32HlwHaE7?w=232&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '民事訴訟小額程序開庭流程圖（司法院釋字第 922 號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.FxsIbUCjMd4IlOEskxShJgHaFj?w=89&h=89&c=1&rs=1&qlt=70&r=0&o=7&pid=InlineBlock&rm=3',
      source: '判決確定證明書與執行憑證抄本（司法院釋字第 922 號...）',
    )
  ],
  'case-023': const [
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.wXoezXbxYh3d5XAsPQA1mwHaE8?w=193&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '【本案卷宗封面照片】法庭審判司法天平現場照片',
    ),
    CaseImage(
      url:
          'https://tse3.mm.bing.net/th/id/OIP.FzL2M5zkVz2nUbqZg7Qe-QHaE7?w=215&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '最高法院司法卷宗圖書館（司法院釋字第 923 號...）',
    ),
    CaseImage(
      url:
          'https://tse4.mm.bing.net/th/id/OIP.Q7FEnIHkrd6q9Jmu1GiKkwHaEj?w=248&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '法規沿革與憲法判決法典（司法院釋字第 923 號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.jgOpaPncHSivavrOTSAXLgHaE8?w=232&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '本案訴訟卷宗外觀及編號（司法院釋字第 923 號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.WVO6tR5BzOgw0oglmH02OAHaEP?w=208&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '地方法院簡易庭外觀與開庭公告（司法院釋字第 923 號...）',
    ),
    CaseImage(
      url:
          'https://tse3.mm.bing.net/th/id/OIP.8vGwbgtGBjFRl90_W32HlwHaE7?w=232&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '當事人提出之訴狀首頁抄本（司法院釋字第 923 號...）',
    ),
    CaseImage(
      url:
          'https://tse4.mm.bing.net/th/id/OIP.BpIJPdGnK-nMpGs5B9306AHaFe?w=206&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '司法裁判書電子檔之判決主文（司法院釋字第 923 號...）',
    ),
    CaseImage(
      url:
          'https://tse4.mm.bing.net/th/id/OIP.zbbKZ0Bh_CpP6eZamtCRjwHaE9?w=179&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '民事起訴狀與委任律師書狀（司法院釋字第 923 號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.6_z7cGk1TU-RBgQM3tsqZQHaE8?w=221&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '法院準備程序筆錄簽名欄位（司法院釋字第 923 號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.EQboFDqbqWRcR8PTOr3wQwHaDn?w=297&h=171&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '司法院大法官憲法法庭開庭現場（司法院釋字第 923 號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.Xt1C-7meX374BAg86KC6LwHaE8?w=89&h=89&c=1&rs=1&qlt=70&r=0&o=7&pid=InlineBlock&rm=3',
      source: '最高法院民事庭開庭大門外觀（司法院釋字第 923 號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.22mIh8FxQ1xTrLJEOF-vTgHaEO?w=89&h=89&c=1&rs=1&qlt=70&r=0&o=7&pid=InlineBlock&rm=3',
      source: '法學文獻與期刊論文引用頁面（司法院釋字第 923 號...）',
    ),
    CaseImage(
      url:
          'https://tse1.mm.bing.net/th/id/OIP.xExaObj3A3nV3olc0K1gmwHaEJ?w=263&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '中華民國六法全書民法債編法條（司法院釋字第 923 號...）',
    ),
    CaseImage(
      url:
          'https://tse4.mm.bing.net/th/id/OIP.0SDoAANiAP6UoZPUrt3UqwHaEN?w=252&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '民事訴訟小額程序開庭流程圖（司法院釋字第 923 號...）',
    ),
    CaseImage(
      url:
          'https://tse3.mm.bing.net/th/id/OIP.RHmdPX6UGcKBDnAmC1DuxQHaE7?w=215&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '判決確定證明書與執行憑證抄本（司法院釋字第 923 號...）',
    )
  ],
  'case-024': const [
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.EQboFDqbqWRcR8PTOr3wQwHaDn?w=297&h=171&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '【本案卷宗封面照片】法庭審判司法天平現場照片',
    ),
    CaseImage(
      url:
          'https://tse1.mm.bing.net/th/id/OIP.fEDFLQLHjS3QuE4bQLgBvQHaE8?w=229&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '最高法院司法卷宗圖書館（112 年憲判字第 5 ...）',
    ),
    CaseImage(
      url:
          'https://tse4.mm.bing.net/th/id/OIP.0SDoAANiAP6UoZPUrt3UqwHaEN?w=252&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '法規沿革與憲法判決法典（112 年憲判字第 5 ...）',
    ),
    CaseImage(
      url:
          'https://tse3.mm.bing.net/th/id/OIP.RHmdPX6UGcKBDnAmC1DuxQHaE7?w=215&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '本案訴訟卷宗外觀及編號（112 年憲判字第 5 ...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.M1ZTFf8JShiFpHtxNdAuTwHaEz?w=227&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '地方法院簡易庭外觀與開庭公告（112 年憲判字第 5 ...）',
    ),
    CaseImage(
      url:
          'https://tse1.mm.bing.net/th/id/OIP.kgAAgTi1mrNURfP1WvpUNQHaFj?w=89&h=90&c=1&rs=1&qlt=70&r=0&o=7&pid=InlineBlock&rm=3',
      source: '當事人提出之訴狀首頁抄本（112 年憲判字第 5 ...）',
    ),
    CaseImage(
      url:
          'https://tse4.mm.bing.net/th/id/OIP.BpIJPdGnK-nMpGs5B9306AHaFe?w=206&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '司法裁判書電子檔之判決主文（112 年憲判字第 5 ...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.6_z7cGk1TU-RBgQM3tsqZQHaE8?w=221&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '民事起訴狀與委任律師書狀（112 年憲判字第 5 ...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.Xt1C-7meX374BAg86KC6LwHaE8?w=89&h=89&c=1&rs=1&qlt=70&r=0&o=7&pid=InlineBlock&rm=3',
      source: '法院準備程序筆錄簽名欄位（112 年憲判字第 5 ...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.WVO6tR5BzOgw0oglmH02OAHaEP?w=208&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '司法院大法官憲法法庭開庭現場（112 年憲判字第 5 ...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.jgOpaPncHSivavrOTSAXLgHaE8?w=232&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '最高法院民事庭開庭大門外觀（112 年憲判字第 5 ...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.CR03_AAGv7DichRpWnF7NQHaE7?w=233&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '法學文獻與期刊論文引用頁面（112 年憲判字第 5 ...）',
    ),
    CaseImage(
      url:
          'https://tse4.mm.bing.net/th/id/OIP.FVJkOeXgZVSaQPF4GFSr2QHaD8?w=89&h=90&c=1&rs=1&qlt=70&r=0&o=7&pid=InlineBlock&rm=3',
      source: '中華民國六法全書民法債編法條（112 年憲判字第 5 ...）',
    ),
    CaseImage(
      url:
          'https://tse3.mm.bing.net/th/id/OIP.rgvPoDUIQa-Gb56tJrl6sgHaEO?w=89&h=90&c=1&rs=1&qlt=70&r=0&o=7&pid=InlineBlock&rm=3',
      source: '民事訴訟小額程序開庭流程圖（112 年憲判字第 5 ...）',
    ),
    CaseImage(
      url:
          'https://tse1.mm.bing.net/th/id/OIP.xExaObj3A3nV3olc0K1gmwHaEJ?w=263&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '判決確定證明書與執行憑證抄本（112 年憲判字第 5 ...）',
    )
  ],
  'case-025': const [
    CaseImage(
      url:
          'https://tse4.mm.bing.net/th/id/OIP.FVJkOeXgZVSaQPF4GFSr2QHaD8?w=89&h=90&c=1&rs=1&qlt=70&r=0&o=7&pid=InlineBlock&rm=3',
      source: '【本案卷宗封面照片】法庭審判司法天平現場照片',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.jgOpaPncHSivavrOTSAXLgHaE8?w=232&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '最高法院司法卷宗圖書館（113 年憲判字第 6 ...）',
    ),
    CaseImage(
      url:
          'https://tse3.mm.bing.net/th/id/OIP.RHmdPX6UGcKBDnAmC1DuxQHaE7?w=215&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '法規沿革與憲法判決法典（113 年憲判字第 6 ...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.Xt1C-7meX374BAg86KC6LwHaE8?w=89&h=89&c=1&rs=1&qlt=70&r=0&o=7&pid=InlineBlock&rm=3',
      source: '本案訴訟卷宗外觀及編號（113 年憲判字第 6 ...）',
    ),
    CaseImage(
      url:
          'https://tse4.mm.bing.net/th/id/OIP.Q7FEnIHkrd6q9Jmu1GiKkwHaEj?w=248&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '地方法院簡易庭外觀與開庭公告（113 年憲判字第 6 ...）',
    ),
    CaseImage(
      url:
          'https://tse3.mm.bing.net/th/id/OIP.rgvPoDUIQa-Gb56tJrl6sgHaEO?w=89&h=90&c=1&rs=1&qlt=70&r=0&o=7&pid=InlineBlock&rm=3',
      source: '當事人提出之訴狀首頁抄本（113 年憲判字第 6 ...）',
    ),
    CaseImage(
      url:
          'https://tse1.mm.bing.net/th/id/OIP.kgAAgTi1mrNURfP1WvpUNQHaFj?w=89&h=90&c=1&rs=1&qlt=70&r=0&o=7&pid=InlineBlock&rm=3',
      source: '司法裁判書電子檔之判決主文（113 年憲判字第 6 ...）',
    ),
    CaseImage(
      url:
          'https://tse3.mm.bing.net/th/id/OIP.FzL2M5zkVz2nUbqZg7Qe-QHaE7?w=215&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '民事起訴狀與委任律師書狀（113 年憲判字第 6 ...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.EQboFDqbqWRcR8PTOr3wQwHaDn?w=297&h=171&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '法院準備程序筆錄簽名欄位（113 年憲判字第 6 ...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.M1ZTFf8JShiFpHtxNdAuTwHaEz?w=227&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '司法院大法官憲法法庭開庭現場（113 年憲判字第 6 ...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.wXoezXbxYh3d5XAsPQA1mwHaE8?w=193&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '最高法院民事庭開庭大門外觀（113 年憲判字第 6 ...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.FxsIbUCjMd4IlOEskxShJgHaFj?w=89&h=89&c=1&rs=1&qlt=70&r=0&o=7&pid=InlineBlock&rm=3',
      source: '法學文獻與期刊論文引用頁面（113 年憲判字第 6 ...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.WVO6tR5BzOgw0oglmH02OAHaEP?w=208&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '中華民國六法全書民法債編法條（113 年憲判字第 6 ...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.22mIh8FxQ1xTrLJEOF-vTgHaEO?w=89&h=89&c=1&rs=1&qlt=70&r=0&o=7&pid=InlineBlock&rm=3',
      source: '民事訴訟小額程序開庭流程圖（113 年憲判字第 6 ...）',
    ),
    CaseImage(
      url:
          'https://tse1.mm.bing.net/th/id/OIP.xExaObj3A3nV3olc0K1gmwHaEJ?w=263&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '判決確定證明書與執行憑證抄本（113 年憲判字第 6 ...）',
    )
  ],
  'case-026': const [
    CaseImage(
      url:
          'https://images.unsplash.com/photo-1589829545856-d10d557cf95f?auto=format&fit=crop&w=800&q=80',
      source: '【本案卷宗封面照片】案發當晚現場事證蒐集紀錄照片',
    ),
    CaseImage(
      url:
          'https://images.unsplash.com/photo-1589829545856-d10d557cf95f?auto=format&fit=crop&w=800&q=80',
      source: '當事人受傷後送醫驗傷診斷書影本（109年度訴字第126號...）',
    ),
    CaseImage(
      url:
          'https://images.unsplash.com/photo-1589829545856-d10d557cf95f?auto=format&fit=crop&w=800&q=80',
      source: '案發現場周邊監視器畫面截圖（109年度訴字第126號...）',
    ),
    CaseImage(
      url:
          'https://images.unsplash.com/photo-1521587760476-6c12a4b040da?auto=format&fit=crop&w=800&q=80',
      source: '警局受理報案及筆錄詢問影本（109年度訴字第126號...）',
    ),
    CaseImage(
      url:
          'https://images.unsplash.com/photo-1505664194779-8bebcb95df84?auto=format&fit=crop&w=800&q=80',
      source: '雙方拉扯鬥毆現場受損物件紀錄（109年度訴字第126號...）',
    ),
    CaseImage(
      url:
          'https://images.unsplash.com/photo-1589829545856-d10d557cf95f?auto=format&fit=crop&w=800&q=80',
      source: '警車警示及拉起管制線拍照存證（109年度訴字第126號...）',
    ),
    CaseImage(
      url:
          'https://images.unsplash.com/photo-1589829545856-d10d557cf95f?auto=format&fit=crop&w=800&q=80',
      source: '雙方就醫急診傷病就診紀錄表（109年度訴字第126號...）',
    ),
    CaseImage(
      url:
          'https://images.unsplash.com/photo-1589829545856-d10d557cf95f?auto=format&fit=crop&w=800&q=80',
      source: '簡易庭現場調解程序筆錄（109年度訴字第126號...）',
    ),
    CaseImage(
      url:
          'https://images.unsplash.com/photo-1589829545856-d10d557cf95f?auto=format&fit=crop&w=800&q=80',
      source: '法庭言詞辯論當事人陳述說明書（109年度訴字第126號...）',
    ),
    CaseImage(
      url:
          'https://images.unsplash.com/photo-1589829545856-d10d557cf95f?auto=format&fit=crop&w=800&q=80',
      source: '法醫鑑定傷勢與關節功能減損報告（109年度訴字第126號...）',
    ),
    CaseImage(
      url:
          'https://images.unsplash.com/photo-1589829545856-d10d557cf95f?auto=format&fit=crop&w=800&q=80',
      source: '現場目擊證人提供之筆錄抄本（109年度訴字第126號...）',
    ),
    CaseImage(
      url:
          'https://images.unsplash.com/photo-1589829545856-d10d557cf95f?auto=format&fit=crop&w=800&q=80',
      source: '地方法院民事侵權訴訟起訴狀首頁（109年度訴字第126號...）',
    ),
    CaseImage(
      url:
          'https://images.unsplash.com/photo-1589829545856-d10d557cf95f?auto=format&fit=crop&w=800&q=80',
      source: '本案相關醫療開銷費用收據影本（109年度訴字第126號...）',
    ),
    CaseImage(
      url:
          'https://images.unsplash.com/photo-1589829545856-d10d557cf95f?auto=format&fit=crop&w=800&q=80',
      source: '社區管理委員會出具之現場報告（109年度訴字第126號...）',
    ),
    CaseImage(
      url:
          'https://images.unsplash.com/photo-1589829545856-d10d557cf95f?auto=format&fit=crop&w=800&q=80',
      source: '被告事後具悔意之和解筆錄影本（109年度訴字第126號...）',
    )
  ],
  'case-027': const [
    CaseImage(
      url:
          'https://images.unsplash.com/photo-1589829545856-d10d557cf95f?auto=format&fit=crop&w=800&q=80',
      source: '【本案卷宗封面照片】事故現場兩車碰撞及毀損狀況照片',
    ),
    CaseImage(
      url:
          'https://images.unsplash.com/photo-1589829545856-d10d557cf95f?auto=format&fit=crop&w=800&q=80',
      source: '道路交通事故現場圖與撞擊點跡證（110年度訴字第127號...）',
    ),
    CaseImage(
      url:
          'https://images.unsplash.com/photo-1589829545856-d10d557cf95f?auto=format&fit=crop&w=800&q=80',
      source: '行車紀錄器所錄關鍵超速或變換車道截圖（110年度訴字第127號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.IgAV4-_vmPVSNj5mDHtDggAAAA?w=194&h=274&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '車輛損壞嚴重不堪使用照片（110年度訴字第127號...）',
    ),
    CaseImage(
      url:
          'https://images.unsplash.com/photo-1589829545856-d10d557cf95f?auto=format&fit=crop&w=800&q=80',
      source: '交通事故初判表與肇事責任分配表（110年度訴字第127號...）',
    ),
    CaseImage(
      url:
          'https://images.unsplash.com/photo-1589829545856-d10d557cf95f?auto=format&fit=crop&w=800&q=80',
      source: '警消大隊於國道或路口搜救處理紀錄（110年度訴字第127號...）',
    ),
    CaseImage(
      url:
          'https://images.unsplash.com/photo-1589829545856-d10d557cf95f?auto=format&fit=crop&w=800&q=80',
      source: '車輛進廠維修估價單與零件折舊說明（110年度訴字第127號...）',
    ),
    CaseImage(
      url:
          'https://images.unsplash.com/photo-1589829545856-d10d557cf95f?auto=format&fit=crop&w=800&q=80',
      source: '受害人腿部或肩部受傷診斷證明（110年度訴字第127號...）',
    ),
    CaseImage(
      url:
          'https://images.unsplash.com/photo-1589829545856-d10d557cf95f?auto=format&fit=crop&w=800&q=80',
      source: '車禍鑑定委員會鑑定意見書抄本（110年度訴字第127號...）',
    ),
    CaseImage(
      url:
          'https://images.unsplash.com/photo-1589829545856-d10d557cf95f?auto=format&fit=crop&w=800&q=80',
      source: '保險公司現場勘估及理賠申請資料（110年度訴字第127號...）',
    ),
    CaseImage(
      url:
          'https://images.unsplash.com/photo-1589829545856-d10d557cf95f?auto=format&fit=crop&w=800&q=80',
      source: '警局報案三聯單與現場勘驗紀錄（110年度訴字第127號...）',
    ),
    CaseImage(
      url:
          'https://images.unsplash.com/photo-1589829545856-d10d557cf95f?auto=format&fit=crop&w=800&q=80',
      source: '起訴請求車體毀損與工作損失書狀（110年度訴字第127號...）',
    ),
    CaseImage(
      url:
          'https://images.unsplash.com/photo-1589829545856-d10d557cf95f?auto=format&fit=crop&w=800&q=80',
      source: '被告無照駕駛或違反號誌裁決書（110年度訴字第127號...）',
    ),
    CaseImage(
      url:
          'https://images.unsplash.com/photo-1590674899484-d5640e854abe?auto=format&fit=crop&w=800&q=80',
      source: '車禍路口號誌秒數與標線履勘照片（110年度訴字第127號...）',
    ),
    CaseImage(
      url:
          'https://images.unsplash.com/photo-1494976388531-d1058494cdd8?auto=format&fit=crop&w=800&q=80',
      source: '雙方就折舊比例開庭言詞辯論筆錄（110年度訴字第127號...）',
    )
  ],
  'case-028': const [
    CaseImage(
      url:
          'https://tse3.mm.bing.net/th/id/OIP.XHSuuTQxqIS2DtKANG1aUAHaE8?w=177&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '【本案卷宗封面照片】原告匯款至被告指定帳戶金流明細',
    ),
    CaseImage(
      url:
          'https://tse1.mm.bing.net/th/id/OIP.oxT_u564BKtIMbvUZ8e97wHaE8?w=217&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '通訊軟體關於借款周轉與利息之對話（111年度訴字第128號...）',
    ),
    CaseImage(
      url:
          'https://tse4.mm.bing.net/th/id/OIP.ZKDbCO13WWxj6Kl8166P6AHaFR?w=89&h=90&c=1&rs=1&qlt=70&r=0&o=7&pid=InlineBlock&rm=3',
      source: '被告借款時出具之本票或本票影本（111年度訴字第128號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.cKmEji655llZVAAzU1z62AHaEu?w=89&h=89&c=1&rs=1&qlt=70&r=0&o=7&pid=InlineBlock&rm=3',
      source: '債權催告存證信函雙單收執影本（111年度訴字第128號...）',
    ),
    CaseImage(
      url:
          'https://tse4.mm.bing.net/th/id/OIP.1qZ2qZ3FqDccSUOFLzYGiwHaFj?w=89&h=89&c=1&rs=1&qlt=70&r=0&o=7&pid=InlineBlock&rm=3',
      source: '口頭約定借貸之現場筆錄與關係人證詞（111年度訴字第128號...）',
    ),
    CaseImage(
      url:
          'https://tse4.mm.bing.net/th/id/OIP.EED2yiIA1PsYr9ojXUqlcAHaFE?w=212&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '民事起訴狀與返還借款聲請書首頁（111年度訴字第128號...）',
    ),
    CaseImage(
      url:
          'https://tse4.mm.bing.net/th/id/OIP.1Ly8vCzB7XlSbQumHBoSVwAAAA?w=175&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '被告簽名與身分證明文件對照（111年度訴字第128號...）',
    ),
    CaseImage(
      url:
          'https://tse3.mm.bing.net/th/id/OIP.DFnXWQg0fRj3YYnOy7ihKAHaHS?w=161&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '彰化地院民事簡易庭開庭通知（111年度訴字第128號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.XVwq1A4FEnAI9YWPmTQfWAHaE9?w=89&h=89&c=1&rs=1&qlt=70&r=0&o=7&pid=InlineBlock&rm=3',
      source: '被告抗辯為合夥合約之投資計畫明細（111年度訴字第128號...）',
    ),
    CaseImage(
      url:
          'https://tse3.mm.bing.net/th/id/OIP.CLTWqMKO7MW6M0Kf_qzDlQAAAA?w=210&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '雙方過去往來帳目之清單明細（111年度訴字第128號...）',
    ),
    CaseImage(
      url:
          'https://tse3.mm.bing.net/th/id/OIP.UTn6WcEFSlsC7dJdMSVI7wHaEu?w=249&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '原告催收借款之通訊軟體通話截圖（111年度訴字第128號...）',
    ),
    CaseImage(
      url:
          'https://tse3.mm.bing.net/th/id/OIP.WtI6au0ejY6xd_iFChYfawHaE0?w=274&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '地方法院調解委員調解筆錄抄本（111年度訴字第128號...）',
    ),
    CaseImage(
      url:
          'https://tse4.mm.bing.net/th/id/OIP.sJMky6nO25ea6L3HofQcTAAAAA?w=219&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '雙方清償協議草案與還款約定書（111年度訴字第128號...）',
    ),
    CaseImage(
      url:
          'https://tse1.mm.bing.net/th/id/OIP.CYNNHSyInbTVnwWwlfNVtAHaCk?w=277&h=121&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '被告帳戶受領匯款金流之銀行明細（111年度訴字第128號...）',
    ),
    CaseImage(
      url:
          'https://tse3.mm.bing.net/th/id/OIP.EPo5yERhwtinDoPWACs9NwAAAA?w=190&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '返還借款民事判決書首頁抄本（111年度訴字第128號...）',
    )
  ],
  'case-029': const [
    CaseImage(
      url:
          'https://thf.bing.com/th/id/OIP.uPNJzFYSKaFMPPBv_yx5PwHaFj?w=214&h=180&c=7&r=0&o=7&cb=thfc1falcon3&pid=1.7&rm=3',
      source: '【本案卷宗封面照片】退租點交時客廳壁面污損狀況照片',
    ),
    CaseImage(
      url:
          'https://thf.bing.com/th/id/OIP.CJz2Me1cbcX7e0-neD78YQHaFj?w=89&h=90&c=1&rs=1&qlt=70&r=0&o=7&cb=thfc1falcon3&pid=InlineBlock&rm=3',
      source: '臥室牆壁自然空氣氧化發黃現況（112年度訴字第129號...）',
    ),
    CaseImage(
      url:
          'https://thf.bing.com/th/id/OIP.jki3wxbrcxKNtK8OXje9-wHaFi?w=256&h=192&c=7&r=0&o=7&cb=thfc1falcon3&pid=1.7&rm=3',
      source: '交屋前原告打鬆清潔完畢之存證相片（112年度訴字第129號...）',
    ),
    CaseImage(
      url:
          'https://thf.bing.com/th/id/OIP.yhiUaQiMhxeAcfVuZ5JSUwHaFj?w=231&h=180&c=7&r=0&o=7&cb=thfc1falcon3&pid=1.7&rm=3',
      source: '房屋租賃契約書押金扣抵條款頁（112年度訴字第129號...）',
    ),
    CaseImage(
      url:
          'https://thf.bing.com/th/id/OIP.rZ2TydbrLVzABGCVRoRnbgHaFi?w=258&h=192&c=7&r=0&o=7&cb=thfc1falcon3&pid=1.7&rm=3',
      source: '原告搬回舊居或新居之通訊紀錄（112年度訴字第129號...）',
    ),
    CaseImage(
      url:
          'https://thf.bing.com/th/id/OIP.RJ07losxoRtfKRkGhMvPNgHaFj?w=89&h=89&c=1&rs=1&qlt=70&r=0&o=7&cb=thfc1falcon3&pid=InlineBlock&rm=3',
      source: '民事小額訴訟起訴書第一頁抄本（112年度訴字第129號...）',
    ),
    CaseImage(
      url:
          'https://thf.bing.com/th/id/OIP.z8hITkmQWmIAxmdaQ3Bv8gHaFi?w=214&h=180&c=7&r=0&o=7&cb=thfc1falcon3&pid=1.7&rm=3',
      source: '房東主張修繕油漆之估價單與收據（112年度訴字第129號...）',
    ),
    CaseImage(
      url:
          'https://thf.bing.com/th/id/OIP._znoDFODaRPozc4jo6I2cwAAAA?w=89&h=90&c=1&rs=1&qlt=70&r=0&o=7&cb=thfc1falcon3&pid=InlineBlock&rm=3',
      source: '返還押金催告存證信函收執影本（112年度訴字第129號...）',
    ),
    CaseImage(
      url:
          'https://thf.bing.com/th/id/OIP.RnnVgKNjQJYh-u09aaUQfQHaEL?w=285&h=180&c=7&r=0&o=7&cb=thfc1falcon3&pid=1.7&rm=3',
      source: '租屋處大門鑰匙與水電度數抄錄照片（112年度訴字第129號...）',
    ),
    CaseImage(
      url:
          'https://thf.bing.com/th/id/OIP.grBKZ0ZR1-9v3eMBSJNH5gHaFj?w=89&h=89&c=1&rs=1&qlt=70&r=0&o=7&cb=thfc1falcon3&pid=InlineBlock&rm=3',
      source: '新北簡易庭言詞辯論審理筆錄（112年度訴字第129號...）',
    ),
    CaseImage(
      url:
          'https://thf.bing.com/th/id/OIP.E-PmHdf_4DcLL35AhF12pQHaEy?w=89&h=90&c=1&rs=1&qlt=70&r=0&o=7&cb=thfc1falcon3&pid=InlineBlock&rm=3',
      source: '沙發皮面日常正常使用磨損損耗細部圖（112年度訴字第129號...）',
    ),
    CaseImage(
      url:
          'https://thf.bing.com/th/id/OIP.vFHW254DpfaRKnaUE-bUTwAAAA?w=187&h=180&c=7&r=0&o=7&cb=thfc1falcon3&pid=1.7&rm=3',
      source: '原告請求全額返還三萬元押金訴狀（112年度訴字第129號...）',
    ),
    CaseImage(
      url:
          'https://thf.bing.com/th/id/OIP.BwLL04d7py9q58P5dFtRHQHaEz?w=199&h=180&c=7&r=0&o=7&cb=thfc1falcon3&pid=1.7&rm=3',
      source: '雙方點交房屋確認書簽署欄位（112年度訴字第129號...）',
    ),
    CaseImage(
      url:
          'https://thf.bing.com/th/id/OIP.veTMhTAy8pAui0GRl_oLXwHaJ4?w=145&h=192&c=7&r=0&o=7&cb=thfc1falcon3&pid=1.7&rm=3',
      source: '房屋原始屋況照片與退租現況對比（112年度訴字第129號...）',
    ),
    CaseImage(
      url:
          'https://thf.bing.com/th/id/OIP.X8YhuWyl_ktJLLR_1tG6ngHaFi?w=257&h=192&c=7&r=0&o=7&cb=thfc1falcon3&pid=1.7&rm=3',
      source: '法官判定自然折舊免責之裁判書影本（112年度訴字第129號...）',
    )
  ],
  'case-030': const [
    CaseImage(
      url:
          'https://tse3.mm.bing.net/th/id/OIP.0LqrctX6I84rVB_N0CFL6AHaHa?w=89&h=89&c=1&rs=1&qlt=70&r=0&o=7&pid=InlineBlock&rm=3',
      source: '【本案卷宗封面照片】原告交付設備或貨物之簽收驗收單',
    ),
    CaseImage(
      url:
          'https://tse3.mm.bing.net/th/id/OIP.beRQlHBEjb_-IJwnwrldmgHaHa?w=141&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '機械設備裝妥並運行之現場實景圖（110年度訴字第130號...）',
    ),
    CaseImage(
      url:
          'https://tse1.mm.bing.net/th/id/OIP.wW23Cy0PNTcJ9El14GtcRwHaE6?w=265&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '買賣契約書價金給付期程與尾款約定（110年度訴字第130號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.76E_MFpeuXe5WdtqtI6EfAHaHa?w=300&h=220&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '被告主張產品瑕疵之瑕疵處照片（110年度訴字第130號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.wy0jZqhtgJA5DPJOG6VNjAHaE8?w=285&h=190&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '工業技術鑑定公會現場勘估報告（110年度訴字第130號...）',
    ),
    CaseImage(
      url:
          'https://tse3.mm.bing.net/th/id/OIP.ir1rcdGl70qJAeBbZSH0YQHaJ4?w=62&h=62&c=1&rs=1&qlt=70&r=0&o=7&pid=InlineBlock&rm=3',
      source: '催告給付尾款之存證信函收執抄本（110年度訴字第130號...）',
    ),
    CaseImage(
      url:
          'https://tse4.mm.bing.net/th/id/OIP.d_uCkHfwWgbE0nrfR4FnZQHaIZ?w=62&h=62&c=1&rs=1&qlt=70&r=0&o=7&pid=InlineBlock&rm=3',
      source: '地方法院民事庭言詞辯論筆錄（110年度訴字第130號...）',
    ),
    CaseImage(
      url:
          'https://tse4.mm.bing.net/th/id/OIP.BAZFXTl9Civlmd2-znLnvwHaFA?w=257&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '原告向被告請求貨款價金起訴狀（110年度訴字第130號...）',
    ),
    CaseImage(
      url:
          'https://tse1.mm.bing.net/th/id/OIP.XyTqTQheQTtl5qNbSIpZ_AHaFL?w=251&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '驗收紀錄表及雙方協商調整款項明細（110年度訴字第130號...）',
    ),
    CaseImage(
      url:
          'https://tse1.mm.bing.net/th/id/OIP.SdVBSWqZ_IHgqEnlQfacngHaLH?w=154&h=220&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '機器規格說明書與出廠安全證明（110年度訴字第130號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.uyDi6UbuwP_KKAIeckQ4_gHaHa?w=62&h=64&c=1&rs=1&qlt=70&r=0&o=7&pid=InlineBlock&rm=3',
      source: '被告工廠實際運作並生產獲利照片（110年度訴字第130號...）',
    ),
    CaseImage(
      url:
          'https://tse1.mm.bing.net/th/id/OIP.y3_Lx2lHa6jXsFjcoxQkZQHaF7?w=220&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '買方拒付尾款之通訊軟體協商截圖（110年度訴字第130號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.TOyWRSZjZJ0Nbmm6ppvgvAHaFV?w=244&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '訴訟代理人律師委任書與準備書狀（110年度訴字第130號...）',
    ),
    CaseImage(
      url:
          'https://tse4.mm.bing.net/th/id/OIP.ZV1gF7BtfqTteQ5lQbpq-gHaHa?w=299&h=220&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '買賣合約爭議現場勘驗筆錄（110年度訴字第130號...）',
    ),
    CaseImage(
      url:
          'https://tse1.mm.bing.net/th/id/OIP.LGkZX4FO_jHOzQKOnzQYEQHaHa?w=89&h=89&c=1&rs=1&qlt=70&r=0&o=7&pid=InlineBlock&rm=3',
      source: '給付買賣價金民事判決書首頁影本（110年度訴字第130號...）',
    )
  ],
  'case-031': const [
    CaseImage(
      url:
          'https://images.unsplash.com/photo-1589829545856-d10d557cf95f?auto=format&fit=crop&w=800&q=80',
      source: '【本案卷宗封面照片】被告公司寄發之資遣通知書影本',
    ),
    CaseImage(
      url:
          'https://images.unsplash.com/photo-1589829545856-d10d557cf95f?auto=format&fit=crop&w=800&q=80',
      source: '原告資深工程師於公司辦公室照片（108年度訴字第131號...）',
    ),
    CaseImage(
      url:
          'https://images.unsplash.com/photo-1589829545856-d10d557cf95f?auto=format&fit=crop&w=800&q=80',
      source: '原告拒絕簽署自願離職書之對話截圖（108年度訴字第131號...）',
    ),
    CaseImage(
      url:
          'https://images.unsplash.com/photo-1505664194779-8bebcb95df84?auto=format&fit=crop&w=800&q=80',
      source: '勞資爭議調解委員會調解紀錄（108年度訴字第131號...）',
    ),
    CaseImage(
      url:
          'https://images.unsplash.com/photo-1589829545856-d10d557cf95f?auto=format&fit=crop&w=800&q=80',
      source: '被告公司仍在人力銀行招聘同職缺網頁（108年度訴字第131號...）',
    ),
    CaseImage(
      url:
          'https://images.unsplash.com/photo-1589829545856-d10d557cf95f?auto=format&fit=crop&w=800&q=80',
      source: '確認僱傭關係存在民事起訴狀首頁（108年度訴字第131號...）',
    ),
    CaseImage(
      url:
          'https://images.unsplash.com/photo-1589829545856-d10d557cf95f?auto=format&fit=crop&w=800&q=80',
      source: '原告出勤打卡明細與在職考核優良紀錄（108年度訴字第131號...）',
    ),
    CaseImage(
      url:
          'https://images.unsplash.com/photo-1589829545856-d10d557cf95f?auto=format&fit=crop&w=800&q=80',
      source: '停職期間薪資請求計算表明細（108年度訴字第131號...）',
    ),
    CaseImage(
      url:
          'https://images.unsplash.com/photo-1589829545856-d10d557cf95f?auto=format&fit=crop&w=800&q=80',
      source: '公司宣稱業務緊縮與人工智慧轉型計畫（108年度訴字第131號...）',
    ),
    CaseImage(
      url:
          'https://images.unsplash.com/photo-1589829545856-d10d557cf95f?auto=format&fit=crop&w=800&q=80',
      source: '勞動基準法第11條第4款安置義務說明（108年度訴字第131號...）',
    ),
    CaseImage(
      url:
          'https://images.unsplash.com/photo-1589829545856-d10d557cf95f?auto=format&fit=crop&w=800&q=80',
      source: '原告薪資轉帳明細與扣繳憑單影本（108年度訴字第131號...）',
    ),
    CaseImage(
      url:
          'https://tse4.mm.bing.net/th/id/OIP.-MF1he4Pv05xg_kMIeUMvAHaE7?w=301&h=200&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '台北地院民事勞動法庭言詞辯論筆錄（108年度訴字第131號...）',
    ),
    CaseImage(
      url:
          'https://images.unsplash.com/photo-1589829545856-d10d557cf95f?auto=format&fit=crop&w=800&q=80',
      source: '雙方關於資遣費計算與轉崗協商紀錄（108年度訴字第131號...）',
    ),
    CaseImage(
      url:
          'https://images.unsplash.com/photo-1589829545856-d10d557cf95f?auto=format&fit=crop&w=800&q=80',
      source: '勞動契約書工作權益保障頁面（108年度訴字第131號...）',
    ),
    CaseImage(
      url:
          'https://images.unsplash.com/photo-1589829545856-d10d557cf95f?auto=format&fit=crop&w=800&q=80',
      source: '不當解雇確認僱傭存在判決書首頁（108年度訴字第131號...）',
    )
  ],
  'case-032': const [
    CaseImage(
      url:
          'https://thf.bing.com/th/id/OIP.55PD4r0SXDacOJJFiIbULwHaFO?w=203&h=180&c=7&r=0&o=7&cb=thfc1falcon3&pid=1.7&rm=3',
      source: '【本案卷宗封面照片】原告與未成年女兒生活起居照顧照片',
    ),
    CaseImage(
      url:
          'https://thf.bing.com/th/id/OIP.DpUJaDK61oI0HwOtm6rxjQHaFO?w=231&h=180&c=7&r=0&o=7&cb=thfc1falcon3&pid=1.7&rm=3',
      source: '分居期間女方娘家生活環境照（111年度訴字第132號...）',
    ),
    CaseImage(
      url:
          'https://thf.bing.com/th/id/OIP.6XBwJp1qd4cY8zK3fGXw5QHaFO?w=89&h=89&c=1&rs=1&qlt=70&r=0&o=7&cb=thfc1falcon3&pid=InlineBlock&rm=3',
      source: '家事調查官訪視報告與社工考核結論（111年度訴字第132號...）',
    ),
    CaseImage(
      url:
          'https://thf.bing.com/th/id/OIP.eAwYipSDEtnyB288ai9yvwHaLS?w=89&h=89&c=1&rs=1&qlt=70&r=0&o=7&cb=thfc1falcon3&pid=InlineBlock&rm=3',
      source: '離婚及酌定親權訴訟起訴書首頁（111年度訴字第132號...）',
    ),
    CaseImage(
      url:
          'https://thf.bing.com/th/id/OIP.o_t3KWOyxHFb4nDMEPFakAHaFO?w=204&h=180&c=7&r=0&o=7&cb=thfc1falcon3&pid=1.7&rm=3',
      source: '男方常年加班與出差之出勤考勤表（111年度訴字第132號...）',
    ),
    CaseImage(
      url:
          'https://thf.bing.com/th/id/OIP.t-nbuCZdbrjZ-Fw32UYVYwHaFP?w=89&h=90&c=1&rs=1&qlt=70&r=0&o=7&cb=thfc1falcon3&pid=InlineBlock&rm=3',
      source: '女兒就讀幼稚園之生活與課業紀錄（111年度訴字第132號...）',
    ),
    CaseImage(
      url:
          'https://thf.bing.com/th/id/OIP.ilZwW9Sti3gNtvAW1igc4wAAAA?w=142&h=126&c=7&r=0&o=7&cb=thfc1falcon3&pid=1.7&rm=3',
      source: '會面交往與探視權方案詳細規劃表（111年度訴字第132號...）',
    ),
    CaseImage(
      url:
          'https://thf.bing.com/th/id/OIP.1li9x8UUzToofOkOaHQ98QHaFO?w=217&h=180&c=7&r=0&o=7&cb=thfc1falcon3&pid=1.7&rm=3',
      source: '男方每月給付扶養費之約定書（111年度訴字第132號...）',
    ),
    CaseImage(
      url:
          'https://thf.bing.com/th/id/OIP.n1K5LrP3mMdozghW_j-bhQHaFP?w=204&h=180&c=7&r=0&o=7&cb=thfc1falcon3&pid=1.7&rm=3',
      source: '家事法院開庭調解程序筆錄抄本（111年度訴字第132號...）',
    ),
    CaseImage(
      url:
          'https://thf.bing.com/th/id/OIP.OOml9emrCj8E8tQMp8mcBgHaFO?w=89&h=90&c=1&rs=1&qlt=70&r=0&o=7&cb=thfc1falcon3&pid=InlineBlock&rm=3',
      source: '女兒向家事官表達意願之訪視摘要（111年度訴字第132號...）',
    ),
    CaseImage(
      url:
          'https://thf.bing.com/th/id/OIP.rd73x-R_V_WG4QCYSO8VmwHaFD?w=175&h=180&c=7&r=0&o=7&cb=thfc1falcon3&pid=1.7&rm=3',
      source: '女方穩定工作之薪資證明與納稅明細（111年度訴字第132號...）',
    ),
    CaseImage(
      url:
          'https://thf.bing.com/th/id/OIP.Pga_I-KnRuVMA-ykwmLgLgHaE3?w=219&h=180&c=7&r=0&o=7&cb=thfc1falcon3&pid=1.7&rm=3',
      source: '男方與女兒假日相處之現場照片（111年度訴字第132號...）',
    ),
    CaseImage(
      url:
          'https://thf.bing.com/th/id/OIP.0YedZmNeclBqrB_mkLdRBQHaHa?w=148&h=180&c=7&r=0&o=7&cb=thfc1falcon3&pid=1.7&rm=3',
      source: '夫妻分居協議與對話紀錄抄本（111年度訴字第132號...）',
    ),
    CaseImage(
      url:
          'https://thf.bing.com/th/id/OIP.GcbWnli2N7d1n_3d5SN8HwHaFO?w=89&h=89&c=1&rs=1&qlt=70&r=0&o=7&cb=thfc1falcon3&pid=InlineBlock&rm=3',
      source: '高雄少年及家事法院開庭通知書（111年度訴字第132號...）',
    ),
    CaseImage(
      url:
          'https://thf.bing.com/th/id/OIP.HSkjryUFQaQtgTA77i5mswHaFO?w=231&h=180&c=7&r=0&o=7&cb=thfc1falcon3&pid=1.7&rm=3',
      source: '酌定親權裁判離婚判決書首頁影本（111年度訴字第132號...）',
    )
  ],
  'case-033': const [
    CaseImage(
      url:
          'https://thfvnext.bing.com/th/id/OIP.89DGcMhJUfQRd05QP2DOjAHaJX?w=61&h=61&c=1&rs=1&qlt=70&r=0&o=7&cb=thfvnextfalcon3&pid=InlineBlock&rm=3',
      source: '【本案卷宗封面照片】店內高畫質監視器擷取犯罪影像',
    ),
    CaseImage(
      url:
          'https://thfvnext.bing.com/th/id/OIP.KlEdfUAGV8vpjffYTFtSJQHaFo?w=171&h=180&c=7&r=0&o=7&cb=thfvnextfalcon3&pid=1.7&rm=3',
      source: '遭竊商品原陳列架位置與侵入點（110年度訴字第133號...）',
    ),
    CaseImage(
      url:
          'https://thfvnext.bing.com/th/id/OIP.6UHEhwdZtBM0nloTzRnywAHaD8?w=260&h=180&c=7&r=0&o=7&cb=thfvnextfalcon3&pid=1.7&rm=3',
      source: '店長進行月盤點之盤盈虧明細表（110年度訴字第133號...）',
    ),
    CaseImage(
      url:
          'https://thfvnext.bing.com/th/id/OIP.1N0kyPszcEwwT4IESmh1KwAAAA?w=162&h=180&c=7&r=0&o=7&cb=thfvnextfalcon3&pid=1.7&rm=3',
      source: '結帳收銀發票與結算異常報表（110年度訴字第133號...）',
    ),
    CaseImage(
      url:
          'https://thfvnext.bing.com/th/id/OIP.aYnjL3hKN3JgCWpkcGxUSwAAAA?w=140&h=197&c=7&r=0&o=7&cb=thfvnextfalcon3&pid=1.7&rm=3',
      source: '遭竊高單價化妝品同款商品樣貌（110年度訴字第133號...）',
    ),
    CaseImage(
      url:
          'https://thfvnext.bing.com/th/id/OIP.xcS_lQb4qJp4ZYWjxRwCVgHaHa?w=162&h=180&c=7&r=0&o=7&cb=thfvnextfalcon3&pid=1.7&rm=3',
      source: '派出所受理刑事報案及三聯單（110年度訴字第133號...）',
    ),
    CaseImage(
      url:
          'https://thfvnext.bing.com/th/id/OIP.jthOTLlqXMcn8Vioepe7-gAAAA?w=286&h=180&c=7&r=0&o=7&cb=thfvnextfalcon3&pid=1.7&rm=3',
      source: '被告私自放包包帶走之截圖事證（110年度訴字第133號...）',
    ),
    CaseImage(
      url:
          'https://thfvnext.bing.com/th/id/OIP.HjVtANBEZKFA5vHswC1a4gHaIX?w=166&h=187&c=7&r=0&o=7&cb=thfvnextfalcon3&pid=1.7&rm=3',
      source: '檢察官提起公訴之刑事起訴書首頁（110年度訴字第133號...）',
    ),
    CaseImage(
      url:
          'https://thfvnext.bing.com/th/id/OIP.F7JGVUY9UbupGme-4uuHIQHaFj?w=89&h=90&c=1&rs=1&qlt=70&r=0&o=7&cb=thfvnextfalcon3&pid=InlineBlock&rm=3',
      source: '警方採證指紋與現場跡證照片（110年度訴字第133號...）',
    ),
    CaseImage(
      url:
          'https://thfvnext.bing.com/th/id/OIP.I47UmjSo9xsIZVihFAghQAHaFj?w=262&h=197&c=7&r=0&o=7&cb=thfvnextfalcon3&pid=1.7&rm=3',
      source: '被告親友結帳漏刷商品之完整錄影（110年度訴字第133號...）',
    ),
    CaseImage(
      url:
          'https://thfvnext.bing.com/th/id/OIP.cmLSye_DGBAasB7u1TfH1wAAAA?w=115&h=180&c=7&r=0&o=7&cb=thfvnextfalcon3&pid=1.7&rm=3',
      source: '漏刷商品之實體盤點損失明細（110年度訴字第133號...）',
    ),
    CaseImage(
      url:
          'https://thfvnext.bing.com/th/id/OIP.lqIZNH2QaIMEQeP4bmC6fAHaJ4?w=61&h=61&c=1&rs=1&qlt=70&r=0&o=7&cb=thfvnextfalcon3&pid=InlineBlock&rm=3',
      source: '被告利用職務侵占之帳目報表（110年度訴字第133號...）',
    ),
    CaseImage(
      url:
          'https://thfvnext.bing.com/th/id/OIP.eMpNLhxbqZ5v5D953GNPMQHaJh?w=145&h=187&c=7&r=0&o=7&cb=thfvnextfalcon3&pid=1.7&rm=3',
      source: '地方法院刑事庭言詞辯論審理筆錄（110年度訴字第133號...）',
    ),
    CaseImage(
      url:
          'https://thfvnext.bing.com/th/id/OIP.MR9HyQpGXAWsvkZxVE7vIgAAAA?w=128&h=187&c=7&r=0&o=7&cb=thfvnextfalcon3&pid=1.7&rm=3',
      source: '被告涉犯竊盜與業務侵占之併罰說明（110年度訴字第133號...）',
    ),
    CaseImage(
      url:
          'https://thfvnext.bing.com/th/id/OIP.fxsRECjOdK8yLRRZmKTuDQHaJX?w=148&h=187&c=7&r=0&o=7&cb=thfvnextfalcon3&pid=1.7&rm=3',
      source: '刑事判決處六個月有期徒刑判決書（110年度訴字第133號...）',
    )
  ],
  'case-034': const [
    CaseImage(
      url:
          'https://thf.bing.com/th/id/OIP.kCjWpEk-XOHrhmW4P9aIQQHaHa?w=200&h=200&c=7&r=0&o=7&cb=thfc1falcon3&pid=1.7&rm=3',
      source: '【本案卷宗封面照片】案發當晚現場事證蒐集紀錄照片',
    ),
    CaseImage(
      url:
          'https://images.unsplash.com/photo-1589829545856-d10d557cf95f?auto=format&fit=crop&w=800&q=80',
      source: '當事人受傷後送醫驗傷診斷書影本（111年度訴字第134號...）',
    ),
    CaseImage(
      url:
          'https://images.unsplash.com/photo-1589829545856-d10d557cf95f?auto=format&fit=crop&w=800&q=80',
      source: '案發現場周邊監視器畫面截圖（111年度訴字第134號...）',
    ),
    CaseImage(
      url:
          'https://images.unsplash.com/photo-1589829545856-d10d557cf95f?auto=format&fit=crop&w=800&q=80',
      source: '警局受理報案及筆錄詢問影本（111年度訴字第134號...）',
    ),
    CaseImage(
      url:
          'https://images.unsplash.com/photo-1589829545856-d10d557cf95f?auto=format&fit=crop&w=800&q=80',
      source: '雙方拉扯鬥毆現場受損物件紀錄（111年度訴字第134號...）',
    ),
    CaseImage(
      url:
          'https://images.unsplash.com/photo-1521587760476-6c12a4b040da?auto=format&fit=crop&w=800&q=80',
      source: '警車警示及拉起管制線拍照存證（111年度訴字第134號...）',
    ),
    CaseImage(
      url:
          'https://images.unsplash.com/photo-1589829545856-d10d557cf95f?auto=format&fit=crop&w=800&q=80',
      source: '雙方就醫急診傷病就診紀錄表（111年度訴字第134號...）',
    ),
    CaseImage(
      url:
          'https://images.unsplash.com/photo-1589829545856-d10d557cf95f?auto=format&fit=crop&w=800&q=80',
      source: '簡易庭現場調解程序筆錄（111年度訴字第134號...）',
    ),
    CaseImage(
      url:
          'https://images.unsplash.com/photo-1589829545856-d10d557cf95f?auto=format&fit=crop&w=800&q=80',
      source: '法庭言詞辯論當事人陳述說明書（111年度訴字第134號...）',
    ),
    CaseImage(
      url:
          'https://images.unsplash.com/photo-1589829545856-d10d557cf95f?auto=format&fit=crop&w=800&q=80',
      source: '法醫鑑定傷勢與關節功能減損報告（111年度訴字第134號...）',
    ),
    CaseImage(
      url:
          'https://images.unsplash.com/photo-1589829545856-d10d557cf95f?auto=format&fit=crop&w=800&q=80',
      source: '現場目擊證人提供之筆錄抄本（111年度訴字第134號...）',
    ),
    CaseImage(
      url:
          'https://images.unsplash.com/photo-1589829545856-d10d557cf95f?auto=format&fit=crop&w=800&q=80',
      source: '地方法院民事侵權訴訟起訴狀首頁（111年度訴字第134號...）',
    ),
    CaseImage(
      url:
          'https://images.unsplash.com/photo-1589829545856-d10d557cf95f?auto=format&fit=crop&w=800&q=80',
      source: '本案相關醫療開銷費用收據影本（111年度訴字第134號...）',
    ),
    CaseImage(
      url:
          'https://images.unsplash.com/photo-1589829545856-d10d557cf95f?auto=format&fit=crop&w=800&q=80',
      source: '社區管理委員會出具之現場報告（111年度訴字第134號...）',
    ),
    CaseImage(
      url:
          'https://images.unsplash.com/photo-1589829545856-d10d557cf95f?auto=format&fit=crop&w=800&q=80',
      source: '被告事後具悔意之和解筆錄影本（111年度訴字第134號...）',
    )
  ],
  'case-035': const [
    CaseImage(
      url:
          'https://images.unsplash.com/photo-1589829545856-d10d557cf95f?auto=format&fit=crop&w=800&q=80',
      source: '【本案卷宗封面照片】事故現場兩車碰撞及毀損狀況照片',
    ),
    CaseImage(
      url:
          'https://images.unsplash.com/photo-1589829545856-d10d557cf95f?auto=format&fit=crop&w=800&q=80',
      source: '道路交通事故現場圖與撞擊點跡證（109年度訴字第135號...）',
    ),
    CaseImage(
      url:
          'https://images.unsplash.com/photo-1589829545856-d10d557cf95f?auto=format&fit=crop&w=800&q=80',
      source: '行車紀錄器所錄關鍵超速或變換車道截圖（109年度訴字第135號...）',
    ),
    CaseImage(
      url:
          'https://images.unsplash.com/photo-1589829545856-d10d557cf95f?auto=format&fit=crop&w=800&q=80',
      source: '車輛損壞嚴重不堪使用照片（109年度訴字第135號...）',
    ),
    CaseImage(
      url:
          'https://images.unsplash.com/photo-1589829545856-d10d557cf95f?auto=format&fit=crop&w=800&q=80',
      source: '交通事故初判表與肇事責任分配表（109年度訴字第135號...）',
    ),
    CaseImage(
      url:
          'https://images.unsplash.com/photo-1589829545856-d10d557cf95f?auto=format&fit=crop&w=800&q=80',
      source: '警消大隊於國道或路口搜救處理紀錄（109年度訴字第135號...）',
    ),
    CaseImage(
      url:
          'https://images.unsplash.com/photo-1589829545856-d10d557cf95f?auto=format&fit=crop&w=800&q=80',
      source: '車輛進廠維修估價單與零件折舊說明（109年度訴字第135號...）',
    ),
    CaseImage(
      url:
          'https://images.unsplash.com/photo-1590674899484-d5640e854abe?auto=format&fit=crop&w=800&q=80',
      source: '受害人腿部或肩部受傷診斷證明（109年度訴字第135號...）',
    ),
    CaseImage(
      url:
          'https://images.unsplash.com/photo-1589829545856-d10d557cf95f?auto=format&fit=crop&w=800&q=80',
      source: '車禍鑑定委員會鑑定意見書抄本（109年度訴字第135號...）',
    ),
    CaseImage(
      url:
          'https://images.unsplash.com/photo-1589829545856-d10d557cf95f?auto=format&fit=crop&w=800&q=80',
      source: '保險公司現場勘估及理賠申請資料（109年度訴字第135號...）',
    ),
    CaseImage(
      url:
          'https://images.unsplash.com/photo-1589829545856-d10d557cf95f?auto=format&fit=crop&w=800&q=80',
      source: '警局報案三聯單與現場勘驗紀錄（109年度訴字第135號...）',
    ),
    CaseImage(
      url:
          'https://images.unsplash.com/photo-1589829545856-d10d557cf95f?auto=format&fit=crop&w=800&q=80',
      source: '起訴請求車體毀損與工作損失書狀（109年度訴字第135號...）',
    ),
    CaseImage(
      url:
          'https://images.unsplash.com/photo-1589829545856-d10d557cf95f?auto=format&fit=crop&w=800&q=80',
      source: '被告無照駕駛或違反號誌裁決書（109年度訴字第135號...）',
    ),
    CaseImage(
      url:
          'https://images.unsplash.com/photo-1494976388531-d1058494cdd8?auto=format&fit=crop&w=800&q=80',
      source: '車禍路口號誌秒數與標線履勘照片（109年度訴字第135號...）',
    ),
    CaseImage(
      url:
          'https://images.unsplash.com/photo-1589829545856-d10d557cf95f?auto=format&fit=crop&w=800&q=80',
      source: '雙方就折舊比例開庭言詞辯論筆錄（109年度訴字第135號...）',
    )
  ],
  'case-036': const [
    CaseImage(
      url:
          'https://tse1.mm.bing.net/th/id/OIP.xExaObj3A3nV3olc0K1gmwHaEJ?w=263&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '【本案卷宗封面照片】法庭審判司法天平現場照片',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.22mIh8FxQ1xTrLJEOF-vTgHaEO?w=89&h=89&c=1&rs=1&qlt=70&r=0&o=7&pid=InlineBlock&rm=3',
      source: '最高法院司法卷宗圖書館（112年度訴字第136號...）',
    ),
    CaseImage(
      url:
          'https://tse3.mm.bing.net/th/id/OIP.FzL2M5zkVz2nUbqZg7Qe-QHaE7?w=215&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '法規沿革與憲法判決法典（112年度訴字第136號...）',
    ),
    CaseImage(
      url:
          'https://tse1.mm.bing.net/th/id/OIP.kgAAgTi1mrNURfP1WvpUNQHaFj?w=89&h=90&c=1&rs=1&qlt=70&r=0&o=7&pid=InlineBlock&rm=3',
      source: '本案訴訟卷宗外觀及編號（112年度訴字第136號...）',
    ),
    CaseImage(
      url:
          'https://tse4.mm.bing.net/th/id/OIP.BpIJPdGnK-nMpGs5B9306AHaFe?w=206&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '地方法院簡易庭外觀與開庭公告（112年度訴字第136號...）',
    ),
    CaseImage(
      url:
          'https://tse3.mm.bing.net/th/id/OIP.8vGwbgtGBjFRl90_W32HlwHaE7?w=232&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '當事人提出之訴狀首頁抄本（112年度訴字第136號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.EQboFDqbqWRcR8PTOr3wQwHaDn?w=297&h=171&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '司法裁判書電子檔之判決主文（112年度訴字第136號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.6_z7cGk1TU-RBgQM3tsqZQHaE8?w=221&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '民事起訴狀與委任律師書狀（112年度訴字第136號...）',
    ),
    CaseImage(
      url:
          'https://tse1.mm.bing.net/th/id/OIP.fEDFLQLHjS3QuE4bQLgBvQHaE8?w=229&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '法院準備程序筆錄簽名欄位（112年度訴字第136號...）',
    ),
    CaseImage(
      url:
          'https://tse4.mm.bing.net/th/id/OIP.Q7FEnIHkrd6q9Jmu1GiKkwHaEj?w=248&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '司法院大法官憲法法庭開庭現場（112年度訴字第136號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.CR03_AAGv7DichRpWnF7NQHaE7?w=233&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '最高法院民事庭開庭大門外觀（112年度訴字第136號...）',
    ),
    CaseImage(
      url:
          'https://tse3.mm.bing.net/th/id/OIP.RHmdPX6UGcKBDnAmC1DuxQHaE7?w=215&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '法學文獻與期刊論文引用頁面（112年度訴字第136號...）',
    ),
    CaseImage(
      url:
          'https://tse4.mm.bing.net/th/id/OIP.FVJkOeXgZVSaQPF4GFSr2QHaD8?w=89&h=90&c=1&rs=1&qlt=70&r=0&o=7&pid=InlineBlock&rm=3',
      source: '中華民國六法全書民法債編法條（112年度訴字第136號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.jgOpaPncHSivavrOTSAXLgHaE8?w=232&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '民事訴訟小額程序開庭流程圖（112年度訴字第136號...）',
    ),
    CaseImage(
      url:
          'https://tse4.mm.bing.net/th/id/OIP.zbbKZ0Bh_CpP6eZamtCRjwHaE9?w=179&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '判決確定證明書與執行憑證抄本（112年度訴字第136號...）',
    )
  ],
  'case-037': const [
    CaseImage(
      url:
          'https://tse3.mm.bing.net/th/id/OIP.RHmdPX6UGcKBDnAmC1DuxQHaE7?w=215&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '【本案卷宗封面照片】法庭審判司法天平現場照片',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.wXoezXbxYh3d5XAsPQA1mwHaE8?w=193&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '最高法院司法卷宗圖書館（110年度訴字第137號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.M1ZTFf8JShiFpHtxNdAuTwHaEz?w=227&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '法規沿革與憲法判決法典（110年度訴字第137號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.EQboFDqbqWRcR8PTOr3wQwHaDn?w=297&h=171&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '本案訴訟卷宗外觀及編號（110年度訴字第137號...）',
    ),
    CaseImage(
      url:
          'https://tse4.mm.bing.net/th/id/OIP.0SDoAANiAP6UoZPUrt3UqwHaEN?w=252&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '地方法院簡易庭外觀與開庭公告（110年度訴字第137號...）',
    ),
    CaseImage(
      url:
          'https://tse4.mm.bing.net/th/id/OIP.FVJkOeXgZVSaQPF4GFSr2QHaD8?w=89&h=90&c=1&rs=1&qlt=70&r=0&o=7&pid=InlineBlock&rm=3',
      source: '當事人提出之訴狀首頁抄本（110年度訴字第137號...）',
    ),
    CaseImage(
      url:
          'https://tse1.mm.bing.net/th/id/OIP.xExaObj3A3nV3olc0K1gmwHaEJ?w=263&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '司法裁判書電子檔之判決主文（110年度訴字第137號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.Xt1C-7meX374BAg86KC6LwHaE8?w=89&h=89&c=1&rs=1&qlt=70&r=0&o=7&pid=InlineBlock&rm=3',
      source: '民事起訴狀與委任律師書狀（110年度訴字第137號...）',
    ),
    CaseImage(
      url:
          'https://tse3.mm.bing.net/th/id/OIP.8vGwbgtGBjFRl90_W32HlwHaE7?w=232&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '法院準備程序筆錄簽名欄位（110年度訴字第137號...）',
    ),
    CaseImage(
      url:
          'https://tse1.mm.bing.net/th/id/OIP.fEDFLQLHjS3QuE4bQLgBvQHaE8?w=229&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '司法院大法官憲法法庭開庭現場（110年度訴字第137號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.jgOpaPncHSivavrOTSAXLgHaE8?w=232&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '最高法院民事庭開庭大門外觀（110年度訴字第137號...）',
    ),
    CaseImage(
      url:
          'https://tse1.mm.bing.net/th/id/OIP.kgAAgTi1mrNURfP1WvpUNQHaFj?w=89&h=90&c=1&rs=1&qlt=70&r=0&o=7&pid=InlineBlock&rm=3',
      source: '法學文獻與期刊論文引用頁面（110年度訴字第137號...）',
    ),
    CaseImage(
      url:
          'https://tse3.mm.bing.net/th/id/OIP.FzL2M5zkVz2nUbqZg7Qe-QHaE7?w=215&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '中華民國六法全書民法債編法條（110年度訴字第137號...）',
    ),
    CaseImage(
      url:
          'https://tse4.mm.bing.net/th/id/OIP.BpIJPdGnK-nMpGs5B9306AHaFe?w=206&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '民事訴訟小額程序開庭流程圖（110年度訴字第137號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.FxsIbUCjMd4IlOEskxShJgHaFj?w=89&h=89&c=1&rs=1&qlt=70&r=0&o=7&pid=InlineBlock&rm=3',
      source: '判決確定證明書與執行憑證抄本（110年度訴字第137號...）',
    )
  ],
  'case-038': const [
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.FxsIbUCjMd4IlOEskxShJgHaFj?w=89&h=89&c=1&rs=1&qlt=70&r=0&o=7&pid=InlineBlock&rm=3',
      source: '【本案卷宗封面照片】法庭審判司法天平現場照片',
    ),
    CaseImage(
      url:
          'https://tse3.mm.bing.net/th/id/OIP.8vGwbgtGBjFRl90_W32HlwHaE7?w=232&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '最高法院司法卷宗圖書館（111年度訴字第138號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.jgOpaPncHSivavrOTSAXLgHaE8?w=232&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '法規沿革與憲法判決法典（111年度訴字第138號...）',
    ),
    CaseImage(
      url:
          'https://tse4.mm.bing.net/th/id/OIP.Q7FEnIHkrd6q9Jmu1GiKkwHaEj?w=248&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '本案訴訟卷宗外觀及編號（111年度訴字第138號...）',
    ),
    CaseImage(
      url:
          'https://tse4.mm.bing.net/th/id/OIP.0SDoAANiAP6UoZPUrt3UqwHaEN?w=252&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '地方法院簡易庭外觀與開庭公告（111年度訴字第138號...）',
    ),
    CaseImage(
      url:
          'https://tse1.mm.bing.net/th/id/OIP.kgAAgTi1mrNURfP1WvpUNQHaFj?w=89&h=90&c=1&rs=1&qlt=70&r=0&o=7&pid=InlineBlock&rm=3',
      source: '當事人提出之訴狀首頁抄本（111年度訴字第138號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.WVO6tR5BzOgw0oglmH02OAHaEP?w=208&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '司法裁判書電子檔之判決主文（111年度訴字第138號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.CR03_AAGv7DichRpWnF7NQHaE7?w=233&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '民事起訴狀與委任律師書狀（111年度訴字第138號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.6_z7cGk1TU-RBgQM3tsqZQHaE8?w=221&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '法院準備程序筆錄簽名欄位（111年度訴字第138號...）',
    ),
    CaseImage(
      url:
          'https://tse3.mm.bing.net/th/id/OIP.FzL2M5zkVz2nUbqZg7Qe-QHaE7?w=215&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '司法院大法官憲法法庭開庭現場（111年度訴字第138號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.Xt1C-7meX374BAg86KC6LwHaE8?w=89&h=89&c=1&rs=1&qlt=70&r=0&o=7&pid=InlineBlock&rm=3',
      source: '最高法院民事庭開庭大門外觀（111年度訴字第138號...）',
    ),
    CaseImage(
      url:
          'https://tse4.mm.bing.net/th/id/OIP.BpIJPdGnK-nMpGs5B9306AHaFe?w=206&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '法學文獻與期刊論文引用頁面（111年度訴字第138號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.22mIh8FxQ1xTrLJEOF-vTgHaEO?w=89&h=89&c=1&rs=1&qlt=70&r=0&o=7&pid=InlineBlock&rm=3',
      source: '中華民國六法全書民法債編法條（111年度訴字第138號...）',
    ),
    CaseImage(
      url:
          'https://tse1.mm.bing.net/th/id/OIP.fEDFLQLHjS3QuE4bQLgBvQHaE8?w=229&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '民事訴訟小額程序開庭流程圖（111年度訴字第138號...）',
    ),
    CaseImage(
      url:
          'https://tse4.mm.bing.net/th/id/OIP.zbbKZ0Bh_CpP6eZamtCRjwHaE9?w=179&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '判決確定證明書與執行憑證抄本（111年度訴字第138號...）',
    )
  ],
  'case-039': const [
    CaseImage(
      url:
          'https://tse4.mm.bing.net/th/id/OIP.BpIJPdGnK-nMpGs5B9306AHaFe?w=206&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '【本案卷宗封面照片】法庭審判司法天平現場照片',
    ),
    CaseImage(
      url:
          'https://tse3.mm.bing.net/th/id/OIP.RHmdPX6UGcKBDnAmC1DuxQHaE7?w=215&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '最高法院司法卷宗圖書館（109年度訴字第139號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.M1ZTFf8JShiFpHtxNdAuTwHaEz?w=227&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '法規沿革與憲法判決法典（109年度訴字第139號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.EQboFDqbqWRcR8PTOr3wQwHaDn?w=297&h=171&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '本案訴訟卷宗外觀及編號（109年度訴字第139號...）',
    ),
    CaseImage(
      url:
          'https://tse3.mm.bing.net/th/id/OIP.rgvPoDUIQa-Gb56tJrl6sgHaEO?w=89&h=90&c=1&rs=1&qlt=70&r=0&o=7&pid=InlineBlock&rm=3',
      source: '地方法院簡易庭外觀與開庭公告（109年度訴字第139號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.WVO6tR5BzOgw0oglmH02OAHaEP?w=208&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '當事人提出之訴狀首頁抄本（109年度訴字第139號...）',
    ),
    CaseImage(
      url:
          'https://tse4.mm.bing.net/th/id/OIP.FVJkOeXgZVSaQPF4GFSr2QHaD8?w=89&h=90&c=1&rs=1&qlt=70&r=0&o=7&pid=InlineBlock&rm=3',
      source: '司法裁判書電子檔之判決主文（109年度訴字第139號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.22mIh8FxQ1xTrLJEOF-vTgHaEO?w=89&h=89&c=1&rs=1&qlt=70&r=0&o=7&pid=InlineBlock&rm=3',
      source: '民事起訴狀與委任律師書狀（109年度訴字第139號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.FxsIbUCjMd4IlOEskxShJgHaFj?w=89&h=89&c=1&rs=1&qlt=70&r=0&o=7&pid=InlineBlock&rm=3',
      source: '法院準備程序筆錄簽名欄位（109年度訴字第139號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.Xt1C-7meX374BAg86KC6LwHaE8?w=89&h=89&c=1&rs=1&qlt=70&r=0&o=7&pid=InlineBlock&rm=3',
      source: '司法院大法官憲法法庭開庭現場（109年度訴字第139號...）',
    ),
    CaseImage(
      url:
          'https://tse3.mm.bing.net/th/id/OIP.8vGwbgtGBjFRl90_W32HlwHaE7?w=232&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '最高法院民事庭開庭大門外觀（109年度訴字第139號...）',
    ),
    CaseImage(
      url:
          'https://tse4.mm.bing.net/th/id/OIP.0SDoAANiAP6UoZPUrt3UqwHaEN?w=252&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '法學文獻與期刊論文引用頁面（109年度訴字第139號...）',
    ),
    CaseImage(
      url:
          'https://tse1.mm.bing.net/th/id/OIP.xExaObj3A3nV3olc0K1gmwHaEJ?w=263&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '中華民國六法全書民法債編法條（109年度訴字第139號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.6_z7cGk1TU-RBgQM3tsqZQHaE8?w=221&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '民事訴訟小額程序開庭流程圖（109年度訴字第139號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.CR03_AAGv7DichRpWnF7NQHaE7?w=233&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '判決確定證明書與執行憑證抄本（109年度訴字第139號...）',
    )
  ],
  'case-040': const [
    CaseImage(
      url:
          'https://tse3.mm.bing.net/th/id/OIP.FzL2M5zkVz2nUbqZg7Qe-QHaE7?w=215&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '【本案卷宗封面照片】法庭審判司法天平現場照片',
    ),
    CaseImage(
      url:
          'https://tse1.mm.bing.net/th/id/OIP.kgAAgTi1mrNURfP1WvpUNQHaFj?w=89&h=90&c=1&rs=1&qlt=70&r=0&o=7&pid=InlineBlock&rm=3',
      source: '最高法院司法卷宗圖書館（112年度訴字第140號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.6_z7cGk1TU-RBgQM3tsqZQHaE8?w=221&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '法規沿革與憲法判決法典（112年度訴字第140號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.CR03_AAGv7DichRpWnF7NQHaE7?w=233&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '本案訴訟卷宗外觀及編號（112年度訴字第140號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.M1ZTFf8JShiFpHtxNdAuTwHaEz?w=227&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '地方法院簡易庭外觀與開庭公告（112年度訴字第140號...）',
    ),
    CaseImage(
      url:
          'https://tse4.mm.bing.net/th/id/OIP.Q7FEnIHkrd6q9Jmu1GiKkwHaEj?w=248&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '當事人提出之訴狀首頁抄本（112年度訴字第140號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.22mIh8FxQ1xTrLJEOF-vTgHaEO?w=89&h=89&c=1&rs=1&qlt=70&r=0&o=7&pid=InlineBlock&rm=3',
      source: '司法裁判書電子檔之判決主文（112年度訴字第140號...）',
    ),
    CaseImage(
      url:
          'https://tse1.mm.bing.net/th/id/OIP.xExaObj3A3nV3olc0K1gmwHaEJ?w=263&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '民事起訴狀與委任律師書狀（112年度訴字第140號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.WVO6tR5BzOgw0oglmH02OAHaEP?w=208&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '法院準備程序筆錄簽名欄位（112年度訴字第140號...）',
    ),
    CaseImage(
      url:
          'https://tse3.mm.bing.net/th/id/OIP.RHmdPX6UGcKBDnAmC1DuxQHaE7?w=215&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '司法院大法官憲法法庭開庭現場（112年度訴字第140號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.EQboFDqbqWRcR8PTOr3wQwHaDn?w=297&h=171&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '最高法院民事庭開庭大門外觀（112年度訴字第140號...）',
    ),
    CaseImage(
      url:
          'https://tse4.mm.bing.net/th/id/OIP.zbbKZ0Bh_CpP6eZamtCRjwHaE9?w=179&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '法學文獻與期刊論文引用頁面（112年度訴字第140號...）',
    ),
    CaseImage(
      url:
          'https://tse1.mm.bing.net/th/id/OIP.fEDFLQLHjS3QuE4bQLgBvQHaE8?w=229&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '中華民國六法全書民法債編法條（112年度訴字第140號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.wXoezXbxYh3d5XAsPQA1mwHaE8?w=193&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '民事訴訟小額程序開庭流程圖（112年度訴字第140號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.jgOpaPncHSivavrOTSAXLgHaE8?w=232&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '判決確定證明書與執行憑證抄本（112年度訴字第140號...）',
    )
  ],
  'case-041': const [
    CaseImage(
      url:
          'https://tse1.mm.bing.net/th/id/OIP.xExaObj3A3nV3olc0K1gmwHaEJ?w=263&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '【本案卷宗封面照片】法庭審判司法天平現場照片',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.jgOpaPncHSivavrOTSAXLgHaE8?w=232&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '最高法院司法卷宗圖書館（110年度訴字第141號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.Xt1C-7meX374BAg86KC6LwHaE8?w=89&h=89&c=1&rs=1&qlt=70&r=0&o=7&pid=InlineBlock&rm=3',
      source: '法規沿革與憲法判決法典（110年度訴字第141號...）',
    ),
    CaseImage(
      url:
          'https://tse1.mm.bing.net/th/id/OIP.fEDFLQLHjS3QuE4bQLgBvQHaE8?w=229&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '本案訴訟卷宗外觀及編號（110年度訴字第141號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.6_z7cGk1TU-RBgQM3tsqZQHaE8?w=221&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '地方法院簡易庭外觀與開庭公告（110年度訴字第141號...）',
    ),
    CaseImage(
      url:
          'https://tse4.mm.bing.net/th/id/OIP.FVJkOeXgZVSaQPF4GFSr2QHaD8?w=89&h=90&c=1&rs=1&qlt=70&r=0&o=7&pid=InlineBlock&rm=3',
      source: '當事人提出之訴狀首頁抄本（110年度訴字第141號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.FxsIbUCjMd4IlOEskxShJgHaFj?w=89&h=89&c=1&rs=1&qlt=70&r=0&o=7&pid=InlineBlock&rm=3',
      source: '司法裁判書電子檔之判決主文（110年度訴字第141號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.22mIh8FxQ1xTrLJEOF-vTgHaEO?w=89&h=89&c=1&rs=1&qlt=70&r=0&o=7&pid=InlineBlock&rm=3',
      source: '民事起訴狀與委任律師書狀（110年度訴字第141號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.wXoezXbxYh3d5XAsPQA1mwHaE8?w=193&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '法院準備程序筆錄簽名欄位（110年度訴字第141號...）',
    ),
    CaseImage(
      url:
          'https://tse3.mm.bing.net/th/id/OIP.RHmdPX6UGcKBDnAmC1DuxQHaE7?w=215&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '司法院大法官憲法法庭開庭現場（110年度訴字第141號...）',
    ),
    CaseImage(
      url:
          'https://tse4.mm.bing.net/th/id/OIP.Q7FEnIHkrd6q9Jmu1GiKkwHaEj?w=248&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '最高法院民事庭開庭大門外觀（110年度訴字第141號...）',
    ),
    CaseImage(
      url:
          'https://tse3.mm.bing.net/th/id/OIP.rgvPoDUIQa-Gb56tJrl6sgHaEO?w=89&h=90&c=1&rs=1&qlt=70&r=0&o=7&pid=InlineBlock&rm=3',
      source: '法學文獻與期刊論文引用頁面（110年度訴字第141號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.WVO6tR5BzOgw0oglmH02OAHaEP?w=208&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '中華民國六法全書民法債編法條（110年度訴字第141號...）',
    ),
    CaseImage(
      url:
          'https://tse4.mm.bing.net/th/id/OIP.0SDoAANiAP6UoZPUrt3UqwHaEN?w=252&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '民事訴訟小額程序開庭流程圖（110年度訴字第141號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.M1ZTFf8JShiFpHtxNdAuTwHaEz?w=227&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '判決確定證明書與執行憑證抄本（110年度訴字第141號...）',
    )
  ],
  'case-042': const [
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.22mIh8FxQ1xTrLJEOF-vTgHaEO?w=89&h=89&c=1&rs=1&qlt=70&r=0&o=7&pid=InlineBlock&rm=3',
      source: '【本案卷宗封面照片】法庭審判司法天平現場照片',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.CR03_AAGv7DichRpWnF7NQHaE7?w=233&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '最高法院司法卷宗圖書館（109年度訴字第142號...）',
    ),
    CaseImage(
      url:
          'https://tse3.mm.bing.net/th/id/OIP.rgvPoDUIQa-Gb56tJrl6sgHaEO?w=89&h=90&c=1&rs=1&qlt=70&r=0&o=7&pid=InlineBlock&rm=3',
      source: '法規沿革與憲法判決法典（109年度訴字第142號...）',
    ),
    CaseImage(
      url:
          'https://tse4.mm.bing.net/th/id/OIP.0SDoAANiAP6UoZPUrt3UqwHaEN?w=252&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '本案訴訟卷宗外觀及編號（109年度訴字第142號...）',
    ),
    CaseImage(
      url:
          'https://tse1.mm.bing.net/th/id/OIP.kgAAgTi1mrNURfP1WvpUNQHaFj?w=89&h=90&c=1&rs=1&qlt=70&r=0&o=7&pid=InlineBlock&rm=3',
      source: '地方法院簡易庭外觀與開庭公告（109年度訴字第142號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.EQboFDqbqWRcR8PTOr3wQwHaDn?w=297&h=171&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '當事人提出之訴狀首頁抄本（109年度訴字第142號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.FxsIbUCjMd4IlOEskxShJgHaFj?w=89&h=89&c=1&rs=1&qlt=70&r=0&o=7&pid=InlineBlock&rm=3',
      source: '司法裁判書電子檔之判決主文（109年度訴字第142號...）',
    ),
    CaseImage(
      url:
          'https://tse4.mm.bing.net/th/id/OIP.zbbKZ0Bh_CpP6eZamtCRjwHaE9?w=179&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '民事起訴狀與委任律師書狀（109年度訴字第142號...）',
    ),
    CaseImage(
      url:
          'https://tse3.mm.bing.net/th/id/OIP.FzL2M5zkVz2nUbqZg7Qe-QHaE7?w=215&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '法院準備程序筆錄簽名欄位（109年度訴字第142號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.Xt1C-7meX374BAg86KC6LwHaE8?w=89&h=89&c=1&rs=1&qlt=70&r=0&o=7&pid=InlineBlock&rm=3',
      source: '司法院大法官憲法法庭開庭現場（109年度訴字第142號...）',
    ),
    CaseImage(
      url:
          'https://tse1.mm.bing.net/th/id/OIP.xExaObj3A3nV3olc0K1gmwHaEJ?w=263&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '最高法院民事庭開庭大門外觀（109年度訴字第142號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.wXoezXbxYh3d5XAsPQA1mwHaE8?w=193&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '法學文獻與期刊論文引用頁面（109年度訴字第142號...）',
    ),
    CaseImage(
      url:
          'https://tse4.mm.bing.net/th/id/OIP.Q7FEnIHkrd6q9Jmu1GiKkwHaEj?w=248&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '中華民國六法全書民法債編法條（109年度訴字第142號...）',
    ),
    CaseImage(
      url:
          'https://tse1.mm.bing.net/th/id/OIP.fEDFLQLHjS3QuE4bQLgBvQHaE8?w=229&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '民事訴訟小額程序開庭流程圖（109年度訴字第142號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.WVO6tR5BzOgw0oglmH02OAHaEP?w=208&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '判決確定證明書與執行憑證抄本（109年度訴字第142號...）',
    )
  ],
  'case-043': const [
    CaseImage(
      url:
          'https://tse3.mm.bing.net/th/id/OIP.FzL2M5zkVz2nUbqZg7Qe-QHaE7?w=215&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '【本案卷宗封面照片】法庭審判司法天平現場照片',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.Xt1C-7meX374BAg86KC6LwHaE8?w=89&h=89&c=1&rs=1&qlt=70&r=0&o=7&pid=InlineBlock&rm=3',
      source: '最高法院司法卷宗圖書館（111年度訴字第143號...）',
    ),
    CaseImage(
      url:
          'https://tse1.mm.bing.net/th/id/OIP.xExaObj3A3nV3olc0K1gmwHaEJ?w=263&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '法規沿革與憲法判決法典（111年度訴字第143號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.EQboFDqbqWRcR8PTOr3wQwHaDn?w=297&h=171&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '本案訴訟卷宗外觀及編號（111年度訴字第143號...）',
    ),
    CaseImage(
      url:
          'https://tse3.mm.bing.net/th/id/OIP.RHmdPX6UGcKBDnAmC1DuxQHaE7?w=215&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '地方法院簡易庭外觀與開庭公告（111年度訴字第143號...）',
    ),
    CaseImage(
      url:
          'https://tse1.mm.bing.net/th/id/OIP.fEDFLQLHjS3QuE4bQLgBvQHaE8?w=229&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '當事人提出之訴狀首頁抄本（111年度訴字第143號...）',
    ),
    CaseImage(
      url:
          'https://tse4.mm.bing.net/th/id/OIP.zbbKZ0Bh_CpP6eZamtCRjwHaE9?w=179&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '司法裁判書電子檔之判決主文（111年度訴字第143號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.WVO6tR5BzOgw0oglmH02OAHaEP?w=208&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '民事起訴狀與委任律師書狀（111年度訴字第143號...）',
    ),
    CaseImage(
      url:
          'https://tse3.mm.bing.net/th/id/OIP.rgvPoDUIQa-Gb56tJrl6sgHaEO?w=89&h=90&c=1&rs=1&qlt=70&r=0&o=7&pid=InlineBlock&rm=3',
      source: '法院準備程序筆錄簽名欄位（111年度訴字第143號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.wXoezXbxYh3d5XAsPQA1mwHaE8?w=193&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '司法院大法官憲法法庭開庭現場（111年度訴字第143號...）',
    ),
    CaseImage(
      url:
          'https://tse4.mm.bing.net/th/id/OIP.Q7FEnIHkrd6q9Jmu1GiKkwHaEj?w=248&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '最高法院民事庭開庭大門外觀（111年度訴字第143號...）',
    ),
    CaseImage(
      url:
          'https://tse4.mm.bing.net/th/id/OIP.BpIJPdGnK-nMpGs5B9306AHaFe?w=206&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '法學文獻與期刊論文引用頁面（111年度訴字第143號...）',
    ),
    CaseImage(
      url:
          'https://tse1.mm.bing.net/th/id/OIP.kgAAgTi1mrNURfP1WvpUNQHaFj?w=89&h=90&c=1&rs=1&qlt=70&r=0&o=7&pid=InlineBlock&rm=3',
      source: '中華民國六法全書民法債編法條（111年度訴字第143號...）',
    ),
    CaseImage(
      url:
          'https://tse4.mm.bing.net/th/id/OIP.FVJkOeXgZVSaQPF4GFSr2QHaD8?w=89&h=90&c=1&rs=1&qlt=70&r=0&o=7&pid=InlineBlock&rm=3',
      source: '民事訴訟小額程序開庭流程圖（111年度訴字第143號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.22mIh8FxQ1xTrLJEOF-vTgHaEO?w=89&h=89&c=1&rs=1&qlt=70&r=0&o=7&pid=InlineBlock&rm=3',
      source: '判決確定證明書與執行憑證抄本（111年度訴字第143號...）',
    )
  ],
  'case-044': const [
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.22mIh8FxQ1xTrLJEOF-vTgHaEO?w=89&h=89&c=1&rs=1&qlt=70&r=0&o=7&pid=InlineBlock&rm=3',
      source: '【本案卷宗封面照片】法庭審判司法天平現場照片',
    ),
    CaseImage(
      url:
          'https://tse3.mm.bing.net/th/id/OIP.8vGwbgtGBjFRl90_W32HlwHaE7?w=232&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '最高法院司法卷宗圖書館（111年度訴字第144號...）',
    ),
    CaseImage(
      url:
          'https://tse4.mm.bing.net/th/id/OIP.zbbKZ0Bh_CpP6eZamtCRjwHaE9?w=179&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '法規沿革與憲法判決法典（111年度訴字第144號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.WVO6tR5BzOgw0oglmH02OAHaEP?w=208&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '本案訴訟卷宗外觀及編號（111年度訴字第144號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.jgOpaPncHSivavrOTSAXLgHaE8?w=232&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '地方法院簡易庭外觀與開庭公告（111年度訴字第144號...）',
    ),
    CaseImage(
      url:
          'https://tse3.mm.bing.net/th/id/OIP.RHmdPX6UGcKBDnAmC1DuxQHaE7?w=215&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '當事人提出之訴狀首頁抄本（111年度訴字第144號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.wXoezXbxYh3d5XAsPQA1mwHaE8?w=193&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '司法裁判書電子檔之判決主文（111年度訴字第144號...）',
    ),
    CaseImage(
      url:
          'https://tse3.mm.bing.net/th/id/OIP.FzL2M5zkVz2nUbqZg7Qe-QHaE7?w=215&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '民事起訴狀與委任律師書狀（111年度訴字第144號...）',
    ),
    CaseImage(
      url:
          'https://tse3.mm.bing.net/th/id/OIP.rgvPoDUIQa-Gb56tJrl6sgHaEO?w=89&h=90&c=1&rs=1&qlt=70&r=0&o=7&pid=InlineBlock&rm=3',
      source: '法院準備程序筆錄簽名欄位（111年度訴字第144號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.CR03_AAGv7DichRpWnF7NQHaE7?w=233&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '司法院大法官憲法法庭開庭現場（111年度訴字第144號...）',
    ),
    CaseImage(
      url:
          'https://tse1.mm.bing.net/th/id/OIP.kgAAgTi1mrNURfP1WvpUNQHaFj?w=89&h=90&c=1&rs=1&qlt=70&r=0&o=7&pid=InlineBlock&rm=3',
      source: '最高法院民事庭開庭大門外觀（111年度訴字第144號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.Xt1C-7meX374BAg86KC6LwHaE8?w=89&h=89&c=1&rs=1&qlt=70&r=0&o=7&pid=InlineBlock&rm=3',
      source: '法學文獻與期刊論文引用頁面（111年度訴字第144號...）',
    ),
    CaseImage(
      url:
          'https://tse4.mm.bing.net/th/id/OIP.FVJkOeXgZVSaQPF4GFSr2QHaD8?w=89&h=90&c=1&rs=1&qlt=70&r=0&o=7&pid=InlineBlock&rm=3',
      source: '中華民國六法全書民法債編法條（111年度訴字第144號...）',
    ),
    CaseImage(
      url:
          'https://tse4.mm.bing.net/th/id/OIP.Q7FEnIHkrd6q9Jmu1GiKkwHaEj?w=248&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '民事訴訟小額程序開庭流程圖（111年度訴字第144號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.M1ZTFf8JShiFpHtxNdAuTwHaEz?w=227&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '判決確定證明書與執行憑證抄本（111年度訴字第144號...）',
    )
  ],
  'case-045': const [
    CaseImage(
      url:
          'https://tse3.mm.bing.net/th/id/OIP.8vGwbgtGBjFRl90_W32HlwHaE7?w=232&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '【本案卷宗封面照片】法庭審判司法天平現場照片',
    ),
    CaseImage(
      url:
          'https://tse4.mm.bing.net/th/id/OIP.FVJkOeXgZVSaQPF4GFSr2QHaD8?w=89&h=90&c=1&rs=1&qlt=70&r=0&o=7&pid=InlineBlock&rm=3',
      source: '最高法院司法卷宗圖書館（110年度訴字第145號...）',
    ),
    CaseImage(
      url:
          'https://tse4.mm.bing.net/th/id/OIP.BpIJPdGnK-nMpGs5B9306AHaFe?w=206&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '法規沿革與憲法判決法典（110年度訴字第145號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.FxsIbUCjMd4IlOEskxShJgHaFj?w=89&h=89&c=1&rs=1&qlt=70&r=0&o=7&pid=InlineBlock&rm=3',
      source: '本案訴訟卷宗外觀及編號（110年度訴字第145號...）',
    ),
    CaseImage(
      url:
          'https://tse3.mm.bing.net/th/id/OIP.RHmdPX6UGcKBDnAmC1DuxQHaE7?w=215&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '地方法院簡易庭外觀與開庭公告（110年度訴字第145號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.Xt1C-7meX374BAg86KC6LwHaE8?w=89&h=89&c=1&rs=1&qlt=70&r=0&o=7&pid=InlineBlock&rm=3',
      source: '當事人提出之訴狀首頁抄本（110年度訴字第145號...）',
    ),
    CaseImage(
      url:
          'https://tse4.mm.bing.net/th/id/OIP.0SDoAANiAP6UoZPUrt3UqwHaEN?w=252&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '司法裁判書電子檔之判決主文（110年度訴字第145號...）',
    ),
    CaseImage(
      url:
          'https://tse1.mm.bing.net/th/id/OIP.xExaObj3A3nV3olc0K1gmwHaEJ?w=263&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '民事起訴狀與委任律師書狀（110年度訴字第145號...）',
    ),
    CaseImage(
      url:
          'https://tse4.mm.bing.net/th/id/OIP.zbbKZ0Bh_CpP6eZamtCRjwHaE9?w=179&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '法院準備程序筆錄簽名欄位（110年度訴字第145號...）',
    ),
    CaseImage(
      url:
          'https://tse1.mm.bing.net/th/id/OIP.kgAAgTi1mrNURfP1WvpUNQHaFj?w=89&h=90&c=1&rs=1&qlt=70&r=0&o=7&pid=InlineBlock&rm=3',
      source: '司法院大法官憲法法庭開庭現場（110年度訴字第145號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.M1ZTFf8JShiFpHtxNdAuTwHaEz?w=227&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '最高法院民事庭開庭大門外觀（110年度訴字第145號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.EQboFDqbqWRcR8PTOr3wQwHaDn?w=297&h=171&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '法學文獻與期刊論文引用頁面（110年度訴字第145號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.WVO6tR5BzOgw0oglmH02OAHaEP?w=208&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '中華民國六法全書民法債編法條（110年度訴字第145號...）',
    ),
    CaseImage(
      url:
          'https://tse4.mm.bing.net/th/id/OIP.Q7FEnIHkrd6q9Jmu1GiKkwHaEj?w=248&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '民事訴訟小額程序開庭流程圖（110年度訴字第145號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.jgOpaPncHSivavrOTSAXLgHaE8?w=232&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '判決確定證明書與執行憑證抄本（110年度訴字第145號...）',
    )
  ],
  'case-046': const [
    CaseImage(
      url:
          'https://tse1.mm.bing.net/th/id/OIP.fEDFLQLHjS3QuE4bQLgBvQHaE8?w=229&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '【本案卷宗封面照片】法庭審判司法天平現場照片',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.6_z7cGk1TU-RBgQM3tsqZQHaE8?w=221&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '最高法院司法卷宗圖書館（108年度訴字第146號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.WVO6tR5BzOgw0oglmH02OAHaEP?w=208&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '法規沿革與憲法判決法典（108年度訴字第146號...）',
    ),
    CaseImage(
      url:
          'https://tse4.mm.bing.net/th/id/OIP.FVJkOeXgZVSaQPF4GFSr2QHaD8?w=89&h=90&c=1&rs=1&qlt=70&r=0&o=7&pid=InlineBlock&rm=3',
      source: '本案訴訟卷宗外觀及編號（108年度訴字第146號...）',
    ),
    CaseImage(
      url:
          'https://tse1.mm.bing.net/th/id/OIP.xExaObj3A3nV3olc0K1gmwHaEJ?w=263&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '地方法院簡易庭外觀與開庭公告（108年度訴字第146號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.M1ZTFf8JShiFpHtxNdAuTwHaEz?w=227&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '當事人提出之訴狀首頁抄本（108年度訴字第146號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.FxsIbUCjMd4IlOEskxShJgHaFj?w=89&h=89&c=1&rs=1&qlt=70&r=0&o=7&pid=InlineBlock&rm=3',
      source: '司法裁判書電子檔之判決主文（108年度訴字第146號...）',
    ),
    CaseImage(
      url:
          'https://tse3.mm.bing.net/th/id/OIP.rgvPoDUIQa-Gb56tJrl6sgHaEO?w=89&h=90&c=1&rs=1&qlt=70&r=0&o=7&pid=InlineBlock&rm=3',
      source: '民事起訴狀與委任律師書狀（108年度訴字第146號...）',
    ),
    CaseImage(
      url:
          'https://tse4.mm.bing.net/th/id/OIP.BpIJPdGnK-nMpGs5B9306AHaFe?w=206&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '法院準備程序筆錄簽名欄位（108年度訴字第146號...）',
    ),
    CaseImage(
      url:
          'https://tse4.mm.bing.net/th/id/OIP.zbbKZ0Bh_CpP6eZamtCRjwHaE9?w=179&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '司法院大法官憲法法庭開庭現場（108年度訴字第146號...）',
    ),
    CaseImage(
      url:
          'https://tse4.mm.bing.net/th/id/OIP.Q7FEnIHkrd6q9Jmu1GiKkwHaEj?w=248&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '最高法院民事庭開庭大門外觀（108年度訴字第146號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.22mIh8FxQ1xTrLJEOF-vTgHaEO?w=89&h=89&c=1&rs=1&qlt=70&r=0&o=7&pid=InlineBlock&rm=3',
      source: '法學文獻與期刊論文引用頁面（108年度訴字第146號...）',
    ),
    CaseImage(
      url:
          'https://tse3.mm.bing.net/th/id/OIP.RHmdPX6UGcKBDnAmC1DuxQHaE7?w=215&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '中華民國六法全書民法債編法條（108年度訴字第146號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.wXoezXbxYh3d5XAsPQA1mwHaE8?w=193&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '民事訴訟小額程序開庭流程圖（108年度訴字第146號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.EQboFDqbqWRcR8PTOr3wQwHaDn?w=297&h=171&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '判決確定證明書與執行憑證抄本（108年度訴字第146號...）',
    )
  ],
  'case-047': const [
    CaseImage(
      url:
          'https://tse4.mm.bing.net/th/id/OIP.Q7FEnIHkrd6q9Jmu1GiKkwHaEj?w=248&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '【本案卷宗封面照片】法庭審判司法天平現場照片',
    ),
    CaseImage(
      url:
          'https://tse3.mm.bing.net/th/id/OIP.8vGwbgtGBjFRl90_W32HlwHaE7?w=232&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '最高法院司法卷宗圖書館（102年度訴字第147號...）',
    ),
    CaseImage(
      url:
          'https://tse4.mm.bing.net/th/id/OIP.0SDoAANiAP6UoZPUrt3UqwHaEN?w=252&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '法規沿革與憲法判決法典（102年度訴字第147號...）',
    ),
    CaseImage(
      url:
          'https://tse1.mm.bing.net/th/id/OIP.xExaObj3A3nV3olc0K1gmwHaEJ?w=263&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '本案訴訟卷宗外觀及編號（102年度訴字第147號...）',
    ),
    CaseImage(
      url:
          'https://tse4.mm.bing.net/th/id/OIP.FVJkOeXgZVSaQPF4GFSr2QHaD8?w=89&h=90&c=1&rs=1&qlt=70&r=0&o=7&pid=InlineBlock&rm=3',
      source: '地方法院簡易庭外觀與開庭公告（102年度訴字第147號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.6_z7cGk1TU-RBgQM3tsqZQHaE8?w=221&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '當事人提出之訴狀首頁抄本（102年度訴字第147號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.M1ZTFf8JShiFpHtxNdAuTwHaEz?w=227&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '司法裁判書電子檔之判決主文（102年度訴字第147號...）',
    ),
    CaseImage(
      url:
          'https://tse4.mm.bing.net/th/id/OIP.BpIJPdGnK-nMpGs5B9306AHaFe?w=206&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '民事起訴狀與委任律師書狀（102年度訴字第147號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.jgOpaPncHSivavrOTSAXLgHaE8?w=232&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '法院準備程序筆錄簽名欄位（102年度訴字第147號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.FxsIbUCjMd4IlOEskxShJgHaFj?w=89&h=89&c=1&rs=1&qlt=70&r=0&o=7&pid=InlineBlock&rm=3',
      source: '司法院大法官憲法法庭開庭現場（102年度訴字第147號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.EQboFDqbqWRcR8PTOr3wQwHaDn?w=297&h=171&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '最高法院民事庭開庭大門外觀（102年度訴字第147號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.Xt1C-7meX374BAg86KC6LwHaE8?w=89&h=89&c=1&rs=1&qlt=70&r=0&o=7&pid=InlineBlock&rm=3',
      source: '法學文獻與期刊論文引用頁面（102年度訴字第147號...）',
    ),
    CaseImage(
      url:
          'https://tse3.mm.bing.net/th/id/OIP.rgvPoDUIQa-Gb56tJrl6sgHaEO?w=89&h=90&c=1&rs=1&qlt=70&r=0&o=7&pid=InlineBlock&rm=3',
      source: '中華民國六法全書民法債編法條（102年度訴字第147號...）',
    ),
    CaseImage(
      url:
          'https://tse3.mm.bing.net/th/id/OIP.FzL2M5zkVz2nUbqZg7Qe-QHaE7?w=215&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '民事訴訟小額程序開庭流程圖（102年度訴字第147號...）',
    ),
    CaseImage(
      url:
          'https://tse1.mm.bing.net/th/id/OIP.fEDFLQLHjS3QuE4bQLgBvQHaE8?w=229&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '判決確定證明書與執行憑證抄本（102年度訴字第147號...）',
    )
  ],
  'case-048': const [
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.EQboFDqbqWRcR8PTOr3wQwHaDn?w=297&h=171&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '【本案卷宗封面照片】法庭審判司法天平現場照片',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.Xt1C-7meX374BAg86KC6LwHaE8?w=89&h=89&c=1&rs=1&qlt=70&r=0&o=7&pid=InlineBlock&rm=3',
      source: '最高法院司法卷宗圖書館（101年度訴字第148號...）',
    ),
    CaseImage(
      url:
          'https://tse4.mm.bing.net/th/id/OIP.BpIJPdGnK-nMpGs5B9306AHaFe?w=206&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '法規沿革與憲法判決法典（101年度訴字第148號...）',
    ),
    CaseImage(
      url:
          'https://tse4.mm.bing.net/th/id/OIP.Q7FEnIHkrd6q9Jmu1GiKkwHaEj?w=248&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '本案訴訟卷宗外觀及編號（101年度訴字第148號...）',
    ),
    CaseImage(
      url:
          'https://tse3.mm.bing.net/th/id/OIP.RHmdPX6UGcKBDnAmC1DuxQHaE7?w=215&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '地方法院簡易庭外觀與開庭公告（101年度訴字第148號...）',
    ),
    CaseImage(
      url:
          'https://tse3.mm.bing.net/th/id/OIP.rgvPoDUIQa-Gb56tJrl6sgHaEO?w=89&h=90&c=1&rs=1&qlt=70&r=0&o=7&pid=InlineBlock&rm=3',
      source: '當事人提出之訴狀首頁抄本（101年度訴字第148號...）',
    ),
    CaseImage(
      url:
          'https://tse4.mm.bing.net/th/id/OIP.0SDoAANiAP6UoZPUrt3UqwHaEN?w=252&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '司法裁判書電子檔之判決主文（101年度訴字第148號...）',
    ),
    CaseImage(
      url:
          'https://tse1.mm.bing.net/th/id/OIP.fEDFLQLHjS3QuE4bQLgBvQHaE8?w=229&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '民事起訴狀與委任律師書狀（101年度訴字第148號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.WVO6tR5BzOgw0oglmH02OAHaEP?w=208&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '法院準備程序筆錄簽名欄位（101年度訴字第148號...）',
    ),
    CaseImage(
      url:
          'https://tse1.mm.bing.net/th/id/OIP.kgAAgTi1mrNURfP1WvpUNQHaFj?w=89&h=90&c=1&rs=1&qlt=70&r=0&o=7&pid=InlineBlock&rm=3',
      source: '司法院大法官憲法法庭開庭現場（101年度訴字第148號...）',
    ),
    CaseImage(
      url:
          'https://tse3.mm.bing.net/th/id/OIP.FzL2M5zkVz2nUbqZg7Qe-QHaE7?w=215&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '最高法院民事庭開庭大門外觀（101年度訴字第148號...）',
    ),
    CaseImage(
      url:
          'https://tse4.mm.bing.net/th/id/OIP.FVJkOeXgZVSaQPF4GFSr2QHaD8?w=89&h=90&c=1&rs=1&qlt=70&r=0&o=7&pid=InlineBlock&rm=3',
      source: '法學文獻與期刊論文引用頁面（101年度訴字第148號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.M1ZTFf8JShiFpHtxNdAuTwHaEz?w=227&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '中華民國六法全書民法債編法條（101年度訴字第148號...）',
    ),
    CaseImage(
      url:
          'https://tse1.mm.bing.net/th/id/OIP.xExaObj3A3nV3olc0K1gmwHaEJ?w=263&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '民事訴訟小額程序開庭流程圖（101年度訴字第148號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.wXoezXbxYh3d5XAsPQA1mwHaE8?w=193&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '判決確定證明書與執行憑證抄本（101年度訴字第148號...）',
    )
  ],
  'case-049': const [
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.Xt1C-7meX374BAg86KC6LwHaE8?w=89&h=89&c=1&rs=1&qlt=70&r=0&o=7&pid=InlineBlock&rm=3',
      source: '【本案卷宗封面照片】法庭審判司法天平現場照片',
    ),
    CaseImage(
      url:
          'https://tse4.mm.bing.net/th/id/OIP.0SDoAANiAP6UoZPUrt3UqwHaEN?w=252&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '最高法院司法卷宗圖書館（103年度訴字第149號...）',
    ),
    CaseImage(
      url:
          'https://tse4.mm.bing.net/th/id/OIP.BpIJPdGnK-nMpGs5B9306AHaFe?w=206&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '法規沿革與憲法判決法典（103年度訴字第149號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.EQboFDqbqWRcR8PTOr3wQwHaDn?w=297&h=171&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '本案訴訟卷宗外觀及編號（103年度訴字第149號...）',
    ),
    CaseImage(
      url:
          'https://tse3.mm.bing.net/th/id/OIP.8vGwbgtGBjFRl90_W32HlwHaE7?w=232&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '地方法院簡易庭外觀與開庭公告（103年度訴字第149號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.WVO6tR5BzOgw0oglmH02OAHaEP?w=208&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '當事人提出之訴狀首頁抄本（103年度訴字第149號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.22mIh8FxQ1xTrLJEOF-vTgHaEO?w=89&h=89&c=1&rs=1&qlt=70&r=0&o=7&pid=InlineBlock&rm=3',
      source: '司法裁判書電子檔之判決主文（103年度訴字第149號...）',
    ),
    CaseImage(
      url:
          'https://tse4.mm.bing.net/th/id/OIP.FVJkOeXgZVSaQPF4GFSr2QHaD8?w=89&h=90&c=1&rs=1&qlt=70&r=0&o=7&pid=InlineBlock&rm=3',
      source: '民事起訴狀與委任律師書狀（103年度訴字第149號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.wXoezXbxYh3d5XAsPQA1mwHaE8?w=193&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '法院準備程序筆錄簽名欄位（103年度訴字第149號...）',
    ),
    CaseImage(
      url:
          'https://tse1.mm.bing.net/th/id/OIP.fEDFLQLHjS3QuE4bQLgBvQHaE8?w=229&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '司法院大法官憲法法庭開庭現場（103年度訴字第149號...）',
    ),
    CaseImage(
      url:
          'https://tse1.mm.bing.net/th/id/OIP.xExaObj3A3nV3olc0K1gmwHaEJ?w=263&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '最高法院民事庭開庭大門外觀（103年度訴字第149號...）',
    ),
    CaseImage(
      url:
          'https://tse3.mm.bing.net/th/id/OIP.rgvPoDUIQa-Gb56tJrl6sgHaEO?w=89&h=90&c=1&rs=1&qlt=70&r=0&o=7&pid=InlineBlock&rm=3',
      source: '法學文獻與期刊論文引用頁面（103年度訴字第149號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.6_z7cGk1TU-RBgQM3tsqZQHaE8?w=221&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '中華民國六法全書民法債編法條（103年度訴字第149號...）',
    ),
    CaseImage(
      url:
          'https://tse4.mm.bing.net/th/id/OIP.Q7FEnIHkrd6q9Jmu1GiKkwHaEj?w=248&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '民事訴訟小額程序開庭流程圖（103年度訴字第149號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.CR03_AAGv7DichRpWnF7NQHaE7?w=233&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '判決確定證明書與執行憑證抄本（103年度訴字第149號...）',
    )
  ],
  'case-050': const [
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.6_z7cGk1TU-RBgQM3tsqZQHaE8?w=221&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '【本案卷宗封面照片】法庭審判司法天平現場照片',
    ),
    CaseImage(
      url:
          'https://tse1.mm.bing.net/th/id/OIP.xExaObj3A3nV3olc0K1gmwHaEJ?w=263&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '最高法院司法卷宗圖書館（105年度訴字第150號...）',
    ),
    CaseImage(
      url:
          'https://tse1.mm.bing.net/th/id/OIP.fEDFLQLHjS3QuE4bQLgBvQHaE8?w=229&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '法規沿革與憲法判決法典（105年度訴字第150號...）',
    ),
    CaseImage(
      url:
          'https://tse3.mm.bing.net/th/id/OIP.rgvPoDUIQa-Gb56tJrl6sgHaEO?w=89&h=90&c=1&rs=1&qlt=70&r=0&o=7&pid=InlineBlock&rm=3',
      source: '本案訴訟卷宗外觀及編號（105年度訴字第150號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.22mIh8FxQ1xTrLJEOF-vTgHaEO?w=89&h=89&c=1&rs=1&qlt=70&r=0&o=7&pid=InlineBlock&rm=3',
      source: '地方法院簡易庭外觀與開庭公告（105年度訴字第150號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.jgOpaPncHSivavrOTSAXLgHaE8?w=232&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '當事人提出之訴狀首頁抄本（105年度訴字第150號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.wXoezXbxYh3d5XAsPQA1mwHaE8?w=193&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '司法裁判書電子檔之判決主文（105年度訴字第150號...）',
    ),
    CaseImage(
      url:
          'https://tse4.mm.bing.net/th/id/OIP.BpIJPdGnK-nMpGs5B9306AHaFe?w=206&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '民事起訴狀與委任律師書狀（105年度訴字第150號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.CR03_AAGv7DichRpWnF7NQHaE7?w=233&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '法院準備程序筆錄簽名欄位（105年度訴字第150號...）',
    ),
    CaseImage(
      url:
          'https://tse3.mm.bing.net/th/id/OIP.8vGwbgtGBjFRl90_W32HlwHaE7?w=232&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '司法院大法官憲法法庭開庭現場（105年度訴字第150號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.EQboFDqbqWRcR8PTOr3wQwHaDn?w=297&h=171&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '最高法院民事庭開庭大門外觀（105年度訴字第150號...）',
    ),
    CaseImage(
      url:
          'https://tse3.mm.bing.net/th/id/OIP.FzL2M5zkVz2nUbqZg7Qe-QHaE7?w=215&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '法學文獻與期刊論文引用頁面（105年度訴字第150號...）',
    ),
    CaseImage(
      url:
          'https://tse4.mm.bing.net/th/id/OIP.0SDoAANiAP6UoZPUrt3UqwHaEN?w=252&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '中華民國六法全書民法債編法條（105年度訴字第150號...）',
    ),
    CaseImage(
      url:
          'https://tse4.mm.bing.net/th/id/OIP.Q7FEnIHkrd6q9Jmu1GiKkwHaEj?w=248&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '民事訴訟小額程序開庭流程圖（105年度訴字第150號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.WVO6tR5BzOgw0oglmH02OAHaEP?w=208&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '判決確定證明書與執行憑證抄本（105年度訴字第150號...）',
    )
  ],
  'case-051': const [
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.wXoezXbxYh3d5XAsPQA1mwHaE8?w=193&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '【本案卷宗封面照片】法庭審判司法天平現場照片',
    ),
    CaseImage(
      url:
          'https://tse4.mm.bing.net/th/id/OIP.BpIJPdGnK-nMpGs5B9306AHaFe?w=206&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '最高法院司法卷宗圖書館（106年度訴字第151號...）',
    ),
    CaseImage(
      url:
          'https://tse3.mm.bing.net/th/id/OIP.rgvPoDUIQa-Gb56tJrl6sgHaEO?w=89&h=90&c=1&rs=1&qlt=70&r=0&o=7&pid=InlineBlock&rm=3',
      source: '法規沿革與憲法判決法典（106年度訴字第151號...）',
    ),
    CaseImage(
      url:
          'https://tse4.mm.bing.net/th/id/OIP.Q7FEnIHkrd6q9Jmu1GiKkwHaEj?w=248&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '本案訴訟卷宗外觀及編號（106年度訴字第151號...）',
    ),
    CaseImage(
      url:
          'https://tse1.mm.bing.net/th/id/OIP.xExaObj3A3nV3olc0K1gmwHaEJ?w=263&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '地方法院簡易庭外觀與開庭公告（106年度訴字第151號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.FxsIbUCjMd4IlOEskxShJgHaFj?w=89&h=89&c=1&rs=1&qlt=70&r=0&o=7&pid=InlineBlock&rm=3',
      source: '當事人提出之訴狀首頁抄本（106年度訴字第151號...）',
    ),
    CaseImage(
      url:
          'https://tse1.mm.bing.net/th/id/OIP.fEDFLQLHjS3QuE4bQLgBvQHaE8?w=229&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '司法裁判書電子檔之判決主文（106年度訴字第151號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.EQboFDqbqWRcR8PTOr3wQwHaDn?w=297&h=171&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '民事起訴狀與委任律師書狀（106年度訴字第151號...）',
    ),
    CaseImage(
      url:
          'https://tse4.mm.bing.net/th/id/OIP.0SDoAANiAP6UoZPUrt3UqwHaEN?w=252&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '法院準備程序筆錄簽名欄位（106年度訴字第151號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.CR03_AAGv7DichRpWnF7NQHaE7?w=233&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '司法院大法官憲法法庭開庭現場（106年度訴字第151號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.jgOpaPncHSivavrOTSAXLgHaE8?w=232&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '最高法院民事庭開庭大門外觀（106年度訴字第151號...）',
    ),
    CaseImage(
      url:
          'https://tse3.mm.bing.net/th/id/OIP.RHmdPX6UGcKBDnAmC1DuxQHaE7?w=215&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '法學文獻與期刊論文引用頁面（106年度訴字第151號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.6_z7cGk1TU-RBgQM3tsqZQHaE8?w=221&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '中華民國六法全書民法債編法條（106年度訴字第151號...）',
    ),
    CaseImage(
      url:
          'https://tse4.mm.bing.net/th/id/OIP.zbbKZ0Bh_CpP6eZamtCRjwHaE9?w=179&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '民事訴訟小額程序開庭流程圖（106年度訴字第151號...）',
    ),
    CaseImage(
      url:
          'https://tse1.mm.bing.net/th/id/OIP.kgAAgTi1mrNURfP1WvpUNQHaFj?w=89&h=90&c=1&rs=1&qlt=70&r=0&o=7&pid=InlineBlock&rm=3',
      source: '判決確定證明書與執行憑證抄本（106年度訴字第151號...）',
    )
  ],
  'case-052': const [
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.22mIh8FxQ1xTrLJEOF-vTgHaEO?w=89&h=89&c=1&rs=1&qlt=70&r=0&o=7&pid=InlineBlock&rm=3',
      source: '【本案卷宗封面照片】法庭審判司法天平現場照片',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.Xt1C-7meX374BAg86KC6LwHaE8?w=89&h=89&c=1&rs=1&qlt=70&r=0&o=7&pid=InlineBlock&rm=3',
      source: '最高法院司法卷宗圖書館（110年度訴字第152號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.wXoezXbxYh3d5XAsPQA1mwHaE8?w=193&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '法規沿革與憲法判決法典（110年度訴字第152號...）',
    ),
    CaseImage(
      url:
          'https://tse4.mm.bing.net/th/id/OIP.0SDoAANiAP6UoZPUrt3UqwHaEN?w=252&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '本案訴訟卷宗外觀及編號（110年度訴字第152號...）',
    ),
    CaseImage(
      url:
          'https://tse4.mm.bing.net/th/id/OIP.Q7FEnIHkrd6q9Jmu1GiKkwHaEj?w=248&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '地方法院簡易庭外觀與開庭公告（110年度訴字第152號...）',
    ),
    CaseImage(
      url:
          'https://tse1.mm.bing.net/th/id/OIP.xExaObj3A3nV3olc0K1gmwHaEJ?w=263&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '當事人提出之訴狀首頁抄本（110年度訴字第152號...）',
    ),
    CaseImage(
      url:
          'https://tse4.mm.bing.net/th/id/OIP.BpIJPdGnK-nMpGs5B9306AHaFe?w=206&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '司法裁判書電子檔之判決主文（110年度訴字第152號...）',
    ),
    CaseImage(
      url:
          'https://tse3.mm.bing.net/th/id/OIP.RHmdPX6UGcKBDnAmC1DuxQHaE7?w=215&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '民事起訴狀與委任律師書狀（110年度訴字第152號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.M1ZTFf8JShiFpHtxNdAuTwHaEz?w=227&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '法院準備程序筆錄簽名欄位（110年度訴字第152號...）',
    ),
    CaseImage(
      url:
          'https://tse3.mm.bing.net/th/id/OIP.FzL2M5zkVz2nUbqZg7Qe-QHaE7?w=215&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '司法院大法官憲法法庭開庭現場（110年度訴字第152號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.CR03_AAGv7DichRpWnF7NQHaE7?w=233&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '最高法院民事庭開庭大門外觀（110年度訴字第152號...）',
    ),
    CaseImage(
      url:
          'https://tse4.mm.bing.net/th/id/OIP.FVJkOeXgZVSaQPF4GFSr2QHaD8?w=89&h=90&c=1&rs=1&qlt=70&r=0&o=7&pid=InlineBlock&rm=3',
      source: '法學文獻與期刊論文引用頁面（110年度訴字第152號...）',
    ),
    CaseImage(
      url:
          'https://tse1.mm.bing.net/th/id/OIP.kgAAgTi1mrNURfP1WvpUNQHaFj?w=89&h=90&c=1&rs=1&qlt=70&r=0&o=7&pid=InlineBlock&rm=3',
      source: '中華民國六法全書民法債編法條（110年度訴字第152號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.EQboFDqbqWRcR8PTOr3wQwHaDn?w=297&h=171&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '民事訴訟小額程序開庭流程圖（110年度訴字第152號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.jgOpaPncHSivavrOTSAXLgHaE8?w=232&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '判決確定證明書與執行憑證抄本（110年度訴字第152號...）',
    )
  ],
  'case-053': const [
    CaseImage(
      url:
          'https://tse3.mm.bing.net/th/id/OIP.8vGwbgtGBjFRl90_W32HlwHaE7?w=232&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '【本案卷宗封面照片】法庭審判司法天平現場照片',
    ),
    CaseImage(
      url:
          'https://tse3.mm.bing.net/th/id/OIP.RHmdPX6UGcKBDnAmC1DuxQHaE7?w=215&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '最高法院司法卷宗圖書館（104年度訴字第153號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.Xt1C-7meX374BAg86KC6LwHaE8?w=89&h=89&c=1&rs=1&qlt=70&r=0&o=7&pid=InlineBlock&rm=3',
      source: '法規沿革與憲法判決法典（104年度訴字第153號...）',
    ),
    CaseImage(
      url:
          'https://tse3.mm.bing.net/th/id/OIP.rgvPoDUIQa-Gb56tJrl6sgHaEO?w=89&h=90&c=1&rs=1&qlt=70&r=0&o=7&pid=InlineBlock&rm=3',
      source: '本案訴訟卷宗外觀及編號（104年度訴字第153號...）',
    ),
    CaseImage(
      url:
          'https://tse4.mm.bing.net/th/id/OIP.Q7FEnIHkrd6q9Jmu1GiKkwHaEj?w=248&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '地方法院簡易庭外觀與開庭公告（104年度訴字第153號...）',
    ),
    CaseImage(
      url:
          'https://tse1.mm.bing.net/th/id/OIP.xExaObj3A3nV3olc0K1gmwHaEJ?w=263&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '當事人提出之訴狀首頁抄本（104年度訴字第153號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.22mIh8FxQ1xTrLJEOF-vTgHaEO?w=89&h=89&c=1&rs=1&qlt=70&r=0&o=7&pid=InlineBlock&rm=3',
      source: '司法裁判書電子檔之判決主文（104年度訴字第153號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.wXoezXbxYh3d5XAsPQA1mwHaE8?w=193&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '民事起訴狀與委任律師書狀（104年度訴字第153號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.6_z7cGk1TU-RBgQM3tsqZQHaE8?w=221&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '法院準備程序筆錄簽名欄位（104年度訴字第153號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.WVO6tR5BzOgw0oglmH02OAHaEP?w=208&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '司法院大法官憲法法庭開庭現場（104年度訴字第153號...）',
    ),
    CaseImage(
      url:
          'https://tse4.mm.bing.net/th/id/OIP.0SDoAANiAP6UoZPUrt3UqwHaEN?w=252&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '最高法院民事庭開庭大門外觀（104年度訴字第153號...）',
    ),
    CaseImage(
      url:
          'https://tse1.mm.bing.net/th/id/OIP.kgAAgTi1mrNURfP1WvpUNQHaFj?w=89&h=90&c=1&rs=1&qlt=70&r=0&o=7&pid=InlineBlock&rm=3',
      source: '法學文獻與期刊論文引用頁面（104年度訴字第153號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.FxsIbUCjMd4IlOEskxShJgHaFj?w=89&h=89&c=1&rs=1&qlt=70&r=0&o=7&pid=InlineBlock&rm=3',
      source: '中華民國六法全書民法債編法條（104年度訴字第153號...）',
    ),
    CaseImage(
      url:
          'https://tse3.mm.bing.net/th/id/OIP.FzL2M5zkVz2nUbqZg7Qe-QHaE7?w=215&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '民事訴訟小額程序開庭流程圖（104年度訴字第153號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.EQboFDqbqWRcR8PTOr3wQwHaDn?w=297&h=171&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '判決確定證明書與執行憑證抄本（104年度訴字第153號...）',
    )
  ],
  'case-054': const [
    CaseImage(
      url:
          'https://tse1.mm.bing.net/th/id/OIP.kgAAgTi1mrNURfP1WvpUNQHaFj?w=89&h=90&c=1&rs=1&qlt=70&r=0&o=7&pid=InlineBlock&rm=3',
      source: '【本案卷宗封面照片】法庭審判司法天平現場照片',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.22mIh8FxQ1xTrLJEOF-vTgHaEO?w=89&h=89&c=1&rs=1&qlt=70&r=0&o=7&pid=InlineBlock&rm=3',
      source: '最高法院司法卷宗圖書館（108年度訴字第154號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.6_z7cGk1TU-RBgQM3tsqZQHaE8?w=221&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '法規沿革與憲法判決法典（108年度訴字第154號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.M1ZTFf8JShiFpHtxNdAuTwHaEz?w=227&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '本案訴訟卷宗外觀及編號（108年度訴字第154號...）',
    ),
    CaseImage(
      url:
          'https://tse3.mm.bing.net/th/id/OIP.FzL2M5zkVz2nUbqZg7Qe-QHaE7?w=215&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '地方法院簡易庭外觀與開庭公告（108年度訴字第154號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.FxsIbUCjMd4IlOEskxShJgHaFj?w=89&h=89&c=1&rs=1&qlt=70&r=0&o=7&pid=InlineBlock&rm=3',
      source: '當事人提出之訴狀首頁抄本（108年度訴字第154號...）',
    ),
    CaseImage(
      url:
          'https://tse1.mm.bing.net/th/id/OIP.xExaObj3A3nV3olc0K1gmwHaEJ?w=263&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '司法裁判書電子檔之判決主文（108年度訴字第154號...）',
    ),
    CaseImage(
      url:
          'https://tse4.mm.bing.net/th/id/OIP.FVJkOeXgZVSaQPF4GFSr2QHaD8?w=89&h=90&c=1&rs=1&qlt=70&r=0&o=7&pid=InlineBlock&rm=3',
      source: '民事起訴狀與委任律師書狀（108年度訴字第154號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.wXoezXbxYh3d5XAsPQA1mwHaE8?w=193&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '法院準備程序筆錄簽名欄位（108年度訴字第154號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.EQboFDqbqWRcR8PTOr3wQwHaDn?w=297&h=171&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '司法院大法官憲法法庭開庭現場（108年度訴字第154號...）',
    ),
    CaseImage(
      url:
          'https://tse3.mm.bing.net/th/id/OIP.8vGwbgtGBjFRl90_W32HlwHaE7?w=232&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '最高法院民事庭開庭大門外觀（108年度訴字第154號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.Xt1C-7meX374BAg86KC6LwHaE8?w=89&h=89&c=1&rs=1&qlt=70&r=0&o=7&pid=InlineBlock&rm=3',
      source: '法學文獻與期刊論文引用頁面（108年度訴字第154號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.WVO6tR5BzOgw0oglmH02OAHaEP?w=208&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '中華民國六法全書民法債編法條（108年度訴字第154號...）',
    ),
    CaseImage(
      url:
          'https://tse4.mm.bing.net/th/id/OIP.Q7FEnIHkrd6q9Jmu1GiKkwHaEj?w=248&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '民事訴訟小額程序開庭流程圖（108年度訴字第154號...）',
    ),
    CaseImage(
      url:
          'https://tse3.mm.bing.net/th/id/OIP.RHmdPX6UGcKBDnAmC1DuxQHaE7?w=215&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '判決確定證明書與執行憑證抄本（108年度訴字第154號...）',
    )
  ],
  'case-055': const [
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.wXoezXbxYh3d5XAsPQA1mwHaE8?w=193&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '【本案卷宗封面照片】法庭審判司法天平現場照片',
    ),
    CaseImage(
      url:
          'https://tse1.mm.bing.net/th/id/OIP.fEDFLQLHjS3QuE4bQLgBvQHaE8?w=229&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '最高法院司法卷宗圖書館（107年度訴字第155號...）',
    ),
    CaseImage(
      url:
          'https://tse3.mm.bing.net/th/id/OIP.8vGwbgtGBjFRl90_W32HlwHaE7?w=232&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '法規沿革與憲法判決法典（107年度訴字第155號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.22mIh8FxQ1xTrLJEOF-vTgHaEO?w=89&h=89&c=1&rs=1&qlt=70&r=0&o=7&pid=InlineBlock&rm=3',
      source: '本案訴訟卷宗外觀及編號（107年度訴字第155號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.jgOpaPncHSivavrOTSAXLgHaE8?w=232&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '地方法院簡易庭外觀與開庭公告（107年度訴字第155號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.CR03_AAGv7DichRpWnF7NQHaE7?w=233&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '當事人提出之訴狀首頁抄本（107年度訴字第155號...）',
    ),
    CaseImage(
      url:
          'https://tse4.mm.bing.net/th/id/OIP.Q7FEnIHkrd6q9Jmu1GiKkwHaEj?w=248&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '司法裁判書電子檔之判決主文（107年度訴字第155號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.EQboFDqbqWRcR8PTOr3wQwHaDn?w=297&h=171&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '民事起訴狀與委任律師書狀（107年度訴字第155號...）',
    ),
    CaseImage(
      url:
          'https://tse4.mm.bing.net/th/id/OIP.zbbKZ0Bh_CpP6eZamtCRjwHaE9?w=179&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '法院準備程序筆錄簽名欄位（107年度訴字第155號...）',
    ),
    CaseImage(
      url:
          'https://tse1.mm.bing.net/th/id/OIP.xExaObj3A3nV3olc0K1gmwHaEJ?w=263&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '司法院大法官憲法法庭開庭現場（107年度訴字第155號...）',
    ),
    CaseImage(
      url:
          'https://tse4.mm.bing.net/th/id/OIP.FVJkOeXgZVSaQPF4GFSr2QHaD8?w=89&h=90&c=1&rs=1&qlt=70&r=0&o=7&pid=InlineBlock&rm=3',
      source: '最高法院民事庭開庭大門外觀（107年度訴字第155號...）',
    ),
    CaseImage(
      url:
          'https://tse4.mm.bing.net/th/id/OIP.0SDoAANiAP6UoZPUrt3UqwHaEN?w=252&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '法學文獻與期刊論文引用頁面（107年度訴字第155號...）',
    ),
    CaseImage(
      url:
          'https://tse4.mm.bing.net/th/id/OIP.BpIJPdGnK-nMpGs5B9306AHaFe?w=206&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '中華民國六法全書民法債編法條（107年度訴字第155號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.FxsIbUCjMd4IlOEskxShJgHaFj?w=89&h=89&c=1&rs=1&qlt=70&r=0&o=7&pid=InlineBlock&rm=3',
      source: '民事訴訟小額程序開庭流程圖（107年度訴字第155號...）',
    ),
    CaseImage(
      url:
          'https://tse3.mm.bing.net/th/id/OIP.RHmdPX6UGcKBDnAmC1DuxQHaE7?w=215&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '判決確定證明書與執行憑證抄本（107年度訴字第155號...）',
    )
  ],
  'case-056': const [
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.CR03_AAGv7DichRpWnF7NQHaE7?w=233&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '【本案卷宗封面照片】法庭審判司法天平現場照片',
    ),
    CaseImage(
      url:
          'https://tse4.mm.bing.net/th/id/OIP.FVJkOeXgZVSaQPF4GFSr2QHaD8?w=89&h=90&c=1&rs=1&qlt=70&r=0&o=7&pid=InlineBlock&rm=3',
      source: '最高法院司法卷宗圖書館（109年度訴字第156號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.WVO6tR5BzOgw0oglmH02OAHaEP?w=208&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '法規沿革與憲法判決法典（109年度訴字第156號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.Xt1C-7meX374BAg86KC6LwHaE8?w=89&h=89&c=1&rs=1&qlt=70&r=0&o=7&pid=InlineBlock&rm=3',
      source: '本案訴訟卷宗外觀及編號（109年度訴字第156號...）',
    ),
    CaseImage(
      url:
          'https://tse3.mm.bing.net/th/id/OIP.RHmdPX6UGcKBDnAmC1DuxQHaE7?w=215&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '地方法院簡易庭外觀與開庭公告（109年度訴字第156號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.FxsIbUCjMd4IlOEskxShJgHaFj?w=89&h=89&c=1&rs=1&qlt=70&r=0&o=7&pid=InlineBlock&rm=3',
      source: '當事人提出之訴狀首頁抄本（109年度訴字第156號...）',
    ),
    CaseImage(
      url:
          'https://tse1.mm.bing.net/th/id/OIP.kgAAgTi1mrNURfP1WvpUNQHaFj?w=89&h=90&c=1&rs=1&qlt=70&r=0&o=7&pid=InlineBlock&rm=3',
      source: '司法裁判書電子檔之判決主文（109年度訴字第156號...）',
    ),
    CaseImage(
      url:
          'https://tse1.mm.bing.net/th/id/OIP.xExaObj3A3nV3olc0K1gmwHaEJ?w=263&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '民事起訴狀與委任律師書狀（109年度訴字第156號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.22mIh8FxQ1xTrLJEOF-vTgHaEO?w=89&h=89&c=1&rs=1&qlt=70&r=0&o=7&pid=InlineBlock&rm=3',
      source: '法院準備程序筆錄簽名欄位（109年度訴字第156號...）',
    ),
    CaseImage(
      url:
          'https://tse4.mm.bing.net/th/id/OIP.BpIJPdGnK-nMpGs5B9306AHaFe?w=206&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '司法院大法官憲法法庭開庭現場（109年度訴字第156號...）',
    ),
    CaseImage(
      url:
          'https://tse1.mm.bing.net/th/id/OIP.fEDFLQLHjS3QuE4bQLgBvQHaE8?w=229&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '最高法院民事庭開庭大門外觀（109年度訴字第156號...）',
    ),
    CaseImage(
      url:
          'https://tse4.mm.bing.net/th/id/OIP.Q7FEnIHkrd6q9Jmu1GiKkwHaEj?w=248&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '法學文獻與期刊論文引用頁面（109年度訴字第156號...）',
    ),
    CaseImage(
      url:
          'https://tse4.mm.bing.net/th/id/OIP.zbbKZ0Bh_CpP6eZamtCRjwHaE9?w=179&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '中華民國六法全書民法債編法條（109年度訴字第156號...）',
    ),
    CaseImage(
      url:
          'https://tse3.mm.bing.net/th/id/OIP.FzL2M5zkVz2nUbqZg7Qe-QHaE7?w=215&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '民事訴訟小額程序開庭流程圖（109年度訴字第156號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.M1ZTFf8JShiFpHtxNdAuTwHaEz?w=227&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '判決確定證明書與執行憑證抄本（109年度訴字第156號...）',
    )
  ],
  'case-057': const [
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.WVO6tR5BzOgw0oglmH02OAHaEP?w=208&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '【本案卷宗封面照片】法庭審判司法天平現場照片',
    ),
    CaseImage(
      url:
          'https://tse3.mm.bing.net/th/id/OIP.8vGwbgtGBjFRl90_W32HlwHaE7?w=232&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '最高法院司法卷宗圖書館（111年度訴字第157號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.EQboFDqbqWRcR8PTOr3wQwHaDn?w=297&h=171&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '法規沿革與憲法判決法典（111年度訴字第157號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.22mIh8FxQ1xTrLJEOF-vTgHaEO?w=89&h=89&c=1&rs=1&qlt=70&r=0&o=7&pid=InlineBlock&rm=3',
      source: '本案訴訟卷宗外觀及編號（111年度訴字第157號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.Xt1C-7meX374BAg86KC6LwHaE8?w=89&h=89&c=1&rs=1&qlt=70&r=0&o=7&pid=InlineBlock&rm=3',
      source: '地方法院簡易庭外觀與開庭公告（111年度訴字第157號...）',
    ),
    CaseImage(
      url:
          'https://tse4.mm.bing.net/th/id/OIP.FVJkOeXgZVSaQPF4GFSr2QHaD8?w=89&h=90&c=1&rs=1&qlt=70&r=0&o=7&pid=InlineBlock&rm=3',
      source: '當事人提出之訴狀首頁抄本（111年度訴字第157號...）',
    ),
    CaseImage(
      url:
          'https://tse1.mm.bing.net/th/id/OIP.kgAAgTi1mrNURfP1WvpUNQHaFj?w=89&h=90&c=1&rs=1&qlt=70&r=0&o=7&pid=InlineBlock&rm=3',
      source: '司法裁判書電子檔之判決主文（111年度訴字第157號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.CR03_AAGv7DichRpWnF7NQHaE7?w=233&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '民事起訴狀與委任律師書狀（111年度訴字第157號...）',
    ),
    CaseImage(
      url:
          'https://tse1.mm.bing.net/th/id/OIP.xExaObj3A3nV3olc0K1gmwHaEJ?w=263&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '法院準備程序筆錄簽名欄位（111年度訴字第157號...）',
    ),
    CaseImage(
      url:
          'https://tse3.mm.bing.net/th/id/OIP.rgvPoDUIQa-Gb56tJrl6sgHaEO?w=89&h=90&c=1&rs=1&qlt=70&r=0&o=7&pid=InlineBlock&rm=3',
      source: '司法院大法官憲法法庭開庭現場（111年度訴字第157號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.wXoezXbxYh3d5XAsPQA1mwHaE8?w=193&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '最高法院民事庭開庭大門外觀（111年度訴字第157號...）',
    ),
    CaseImage(
      url:
          'https://tse4.mm.bing.net/th/id/OIP.zbbKZ0Bh_CpP6eZamtCRjwHaE9?w=179&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '法學文獻與期刊論文引用頁面（111年度訴字第157號...）',
    ),
    CaseImage(
      url:
          'https://tse3.mm.bing.net/th/id/OIP.RHmdPX6UGcKBDnAmC1DuxQHaE7?w=215&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '中華民國六法全書民法債編法條（111年度訴字第157號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.FxsIbUCjMd4IlOEskxShJgHaFj?w=89&h=89&c=1&rs=1&qlt=70&r=0&o=7&pid=InlineBlock&rm=3',
      source: '民事訴訟小額程序開庭流程圖（111年度訴字第157號...）',
    ),
    CaseImage(
      url:
          'https://tse4.mm.bing.net/th/id/OIP.0SDoAANiAP6UoZPUrt3UqwHaEN?w=252&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '判決確定證明書與執行憑證抄本（111年度訴字第157號...）',
    )
  ],
  'case-058': const [
    CaseImage(
      url:
          'https://tse1.mm.bing.net/th/id/OIP.fEDFLQLHjS3QuE4bQLgBvQHaE8?w=229&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '【本案卷宗封面照片】法庭審判司法天平現場照片',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.Xt1C-7meX374BAg86KC6LwHaE8?w=89&h=89&c=1&rs=1&qlt=70&r=0&o=7&pid=InlineBlock&rm=3',
      source: '最高法院司法卷宗圖書館（109年度訴字第158號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.FxsIbUCjMd4IlOEskxShJgHaFj?w=89&h=89&c=1&rs=1&qlt=70&r=0&o=7&pid=InlineBlock&rm=3',
      source: '法規沿革與憲法判決法典（109年度訴字第158號...）',
    ),
    CaseImage(
      url:
          'https://tse1.mm.bing.net/th/id/OIP.kgAAgTi1mrNURfP1WvpUNQHaFj?w=89&h=90&c=1&rs=1&qlt=70&r=0&o=7&pid=InlineBlock&rm=3',
      source: '本案訴訟卷宗外觀及編號（109年度訴字第158號...）',
    ),
    CaseImage(
      url:
          'https://tse4.mm.bing.net/th/id/OIP.0SDoAANiAP6UoZPUrt3UqwHaEN?w=252&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '地方法院簡易庭外觀與開庭公告（109年度訴字第158號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.EQboFDqbqWRcR8PTOr3wQwHaDn?w=297&h=171&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '當事人提出之訴狀首頁抄本（109年度訴字第158號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.WVO6tR5BzOgw0oglmH02OAHaEP?w=208&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '司法裁判書電子檔之判決主文（109年度訴字第158號...）',
    ),
    CaseImage(
      url:
          'https://tse4.mm.bing.net/th/id/OIP.FVJkOeXgZVSaQPF4GFSr2QHaD8?w=89&h=90&c=1&rs=1&qlt=70&r=0&o=7&pid=InlineBlock&rm=3',
      source: '民事起訴狀與委任律師書狀（109年度訴字第158號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.jgOpaPncHSivavrOTSAXLgHaE8?w=232&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '法院準備程序筆錄簽名欄位（109年度訴字第158號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.6_z7cGk1TU-RBgQM3tsqZQHaE8?w=221&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '司法院大法官憲法法庭開庭現場（109年度訴字第158號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.M1ZTFf8JShiFpHtxNdAuTwHaEz?w=227&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '最高法院民事庭開庭大門外觀（109年度訴字第158號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.wXoezXbxYh3d5XAsPQA1mwHaE8?w=193&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '法學文獻與期刊論文引用頁面（109年度訴字第158號...）',
    ),
    CaseImage(
      url:
          'https://tse3.mm.bing.net/th/id/OIP.rgvPoDUIQa-Gb56tJrl6sgHaEO?w=89&h=90&c=1&rs=1&qlt=70&r=0&o=7&pid=InlineBlock&rm=3',
      source: '中華民國六法全書民法債編法條（109年度訴字第158號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.CR03_AAGv7DichRpWnF7NQHaE7?w=233&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '民事訴訟小額程序開庭流程圖（109年度訴字第158號...）',
    ),
    CaseImage(
      url:
          'https://tse4.mm.bing.net/th/id/OIP.zbbKZ0Bh_CpP6eZamtCRjwHaE9?w=179&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '判決確定證明書與執行憑證抄本（109年度訴字第158號...）',
    )
  ],
  'case-059': const [
    CaseImage(
      url:
          'https://tse4.mm.bing.net/th/id/OIP.Q7FEnIHkrd6q9Jmu1GiKkwHaEj?w=248&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '【本案卷宗封面照片】法庭審判司法天平現場照片',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.jgOpaPncHSivavrOTSAXLgHaE8?w=232&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '最高法院司法卷宗圖書館（110年度訴字第159號...）',
    ),
    CaseImage(
      url:
          'https://tse4.mm.bing.net/th/id/OIP.zbbKZ0Bh_CpP6eZamtCRjwHaE9?w=179&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '法規沿革與憲法判決法典（110年度訴字第159號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.FxsIbUCjMd4IlOEskxShJgHaFj?w=89&h=89&c=1&rs=1&qlt=70&r=0&o=7&pid=InlineBlock&rm=3',
      source: '本案訴訟卷宗外觀及編號（110年度訴字第159號...）',
    ),
    CaseImage(
      url:
          'https://tse1.mm.bing.net/th/id/OIP.kgAAgTi1mrNURfP1WvpUNQHaFj?w=89&h=90&c=1&rs=1&qlt=70&r=0&o=7&pid=InlineBlock&rm=3',
      source: '地方法院簡易庭外觀與開庭公告（110年度訴字第159號...）',
    ),
    CaseImage(
      url:
          'https://tse1.mm.bing.net/th/id/OIP.xExaObj3A3nV3olc0K1gmwHaEJ?w=263&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '當事人提出之訴狀首頁抄本（110年度訴字第159號...）',
    ),
    CaseImage(
      url:
          'https://tse3.mm.bing.net/th/id/OIP.rgvPoDUIQa-Gb56tJrl6sgHaEO?w=89&h=90&c=1&rs=1&qlt=70&r=0&o=7&pid=InlineBlock&rm=3',
      source: '司法裁判書電子檔之判決主文（110年度訴字第159號...）',
    ),
    CaseImage(
      url:
          'https://tse1.mm.bing.net/th/id/OIP.fEDFLQLHjS3QuE4bQLgBvQHaE8?w=229&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '民事起訴狀與委任律師書狀（110年度訴字第159號...）',
    ),
    CaseImage(
      url:
          'https://tse3.mm.bing.net/th/id/OIP.FzL2M5zkVz2nUbqZg7Qe-QHaE7?w=215&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '法院準備程序筆錄簽名欄位（110年度訴字第159號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.22mIh8FxQ1xTrLJEOF-vTgHaEO?w=89&h=89&c=1&rs=1&qlt=70&r=0&o=7&pid=InlineBlock&rm=3',
      source: '司法院大法官憲法法庭開庭現場（110年度訴字第159號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.M1ZTFf8JShiFpHtxNdAuTwHaEz?w=227&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '最高法院民事庭開庭大門外觀（110年度訴字第159號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.Xt1C-7meX374BAg86KC6LwHaE8?w=89&h=89&c=1&rs=1&qlt=70&r=0&o=7&pid=InlineBlock&rm=3',
      source: '法學文獻與期刊論文引用頁面（110年度訴字第159號...）',
    ),
    CaseImage(
      url:
          'https://tse4.mm.bing.net/th/id/OIP.BpIJPdGnK-nMpGs5B9306AHaFe?w=206&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '中華民國六法全書民法債編法條（110年度訴字第159號...）',
    ),
    CaseImage(
      url:
          'https://tse3.mm.bing.net/th/id/OIP.RHmdPX6UGcKBDnAmC1DuxQHaE7?w=215&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '民事訴訟小額程序開庭流程圖（110年度訴字第159號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.6_z7cGk1TU-RBgQM3tsqZQHaE8?w=221&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '判決確定證明書與執行憑證抄本（110年度訴字第159號...）',
    )
  ],
  'case-060': const [
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.EQboFDqbqWRcR8PTOr3wQwHaDn?w=297&h=171&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '【本案卷宗封面照片】法庭審判司法天平現場照片',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.6_z7cGk1TU-RBgQM3tsqZQHaE8?w=221&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '最高法院司法卷宗圖書館（112年度訴字第160號...）',
    ),
    CaseImage(
      url:
          'https://tse3.mm.bing.net/th/id/OIP.RHmdPX6UGcKBDnAmC1DuxQHaE7?w=215&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '法規沿革與憲法判決法典（112年度訴字第160號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.Xt1C-7meX374BAg86KC6LwHaE8?w=89&h=89&c=1&rs=1&qlt=70&r=0&o=7&pid=InlineBlock&rm=3',
      source: '本案訴訟卷宗外觀及編號（112年度訴字第160號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.WVO6tR5BzOgw0oglmH02OAHaEP?w=208&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '地方法院簡易庭外觀與開庭公告（112年度訴字第160號...）',
    ),
    CaseImage(
      url:
          'https://tse1.mm.bing.net/th/id/OIP.kgAAgTi1mrNURfP1WvpUNQHaFj?w=89&h=90&c=1&rs=1&qlt=70&r=0&o=7&pid=InlineBlock&rm=3',
      source: '當事人提出之訴狀首頁抄本（112年度訴字第160號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.jgOpaPncHSivavrOTSAXLgHaE8?w=232&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '司法裁判書電子檔之判決主文（112年度訴字第160號...）',
    ),
    CaseImage(
      url:
          'https://tse3.mm.bing.net/th/id/OIP.FzL2M5zkVz2nUbqZg7Qe-QHaE7?w=215&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '民事起訴狀與委任律師書狀（112年度訴字第160號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.wXoezXbxYh3d5XAsPQA1mwHaE8?w=193&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '法院準備程序筆錄簽名欄位（112年度訴字第160號...）',
    ),
    CaseImage(
      url:
          'https://tse1.mm.bing.net/th/id/OIP.fEDFLQLHjS3QuE4bQLgBvQHaE8?w=229&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '司法院大法官憲法法庭開庭現場（112年度訴字第160號...）',
    ),
    CaseImage(
      url:
          'https://tse3.mm.bing.net/th/id/OIP.rgvPoDUIQa-Gb56tJrl6sgHaEO?w=89&h=90&c=1&rs=1&qlt=70&r=0&o=7&pid=InlineBlock&rm=3',
      source: '最高法院民事庭開庭大門外觀（112年度訴字第160號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.22mIh8FxQ1xTrLJEOF-vTgHaEO?w=89&h=89&c=1&rs=1&qlt=70&r=0&o=7&pid=InlineBlock&rm=3',
      source: '法學文獻與期刊論文引用頁面（112年度訴字第160號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.CR03_AAGv7DichRpWnF7NQHaE7?w=233&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '中華民國六法全書民法債編法條（112年度訴字第160號...）',
    ),
    CaseImage(
      url:
          'https://tse4.mm.bing.net/th/id/OIP.zbbKZ0Bh_CpP6eZamtCRjwHaE9?w=179&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '民事訴訟小額程序開庭流程圖（112年度訴字第160號...）',
    ),
    CaseImage(
      url:
          'https://tse4.mm.bing.net/th/id/OIP.Q7FEnIHkrd6q9Jmu1GiKkwHaEj?w=248&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '判決確定證明書與執行憑證抄本（112年度訴字第160號...）',
    )
  ],
  'case-061': const [
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.EQboFDqbqWRcR8PTOr3wQwHaDn?w=297&h=171&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '【本案卷宗封面照片】法庭審判司法天平現場照片',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.Xt1C-7meX374BAg86KC6LwHaE8?w=89&h=89&c=1&rs=1&qlt=70&r=0&o=7&pid=InlineBlock&rm=3',
      source: '最高法院司法卷宗圖書館（103年度訴字第161號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.CR03_AAGv7DichRpWnF7NQHaE7?w=233&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '法規沿革與憲法判決法典（103年度訴字第161號...）',
    ),
    CaseImage(
      url:
          'https://tse1.mm.bing.net/th/id/OIP.fEDFLQLHjS3QuE4bQLgBvQHaE8?w=229&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '本案訴訟卷宗外觀及編號（103年度訴字第161號...）',
    ),
    CaseImage(
      url:
          'https://tse4.mm.bing.net/th/id/OIP.zbbKZ0Bh_CpP6eZamtCRjwHaE9?w=179&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '地方法院簡易庭外觀與開庭公告（103年度訴字第161號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.22mIh8FxQ1xTrLJEOF-vTgHaEO?w=89&h=89&c=1&rs=1&qlt=70&r=0&o=7&pid=InlineBlock&rm=3',
      source: '當事人提出之訴狀首頁抄本（103年度訴字第161號...）',
    ),
    CaseImage(
      url:
          'https://tse3.mm.bing.net/th/id/OIP.rgvPoDUIQa-Gb56tJrl6sgHaEO?w=89&h=90&c=1&rs=1&qlt=70&r=0&o=7&pid=InlineBlock&rm=3',
      source: '司法裁判書電子檔之判決主文（103年度訴字第161號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.M1ZTFf8JShiFpHtxNdAuTwHaEz?w=227&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '民事起訴狀與委任律師書狀（103年度訴字第161號...）',
    ),
    CaseImage(
      url:
          'https://tse1.mm.bing.net/th/id/OIP.xExaObj3A3nV3olc0K1gmwHaEJ?w=263&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '法院準備程序筆錄簽名欄位（103年度訴字第161號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.FxsIbUCjMd4IlOEskxShJgHaFj?w=89&h=89&c=1&rs=1&qlt=70&r=0&o=7&pid=InlineBlock&rm=3',
      source: '司法院大法官憲法法庭開庭現場（103年度訴字第161號...）',
    ),
    CaseImage(
      url:
          'https://tse4.mm.bing.net/th/id/OIP.FVJkOeXgZVSaQPF4GFSr2QHaD8?w=89&h=90&c=1&rs=1&qlt=70&r=0&o=7&pid=InlineBlock&rm=3',
      source: '最高法院民事庭開庭大門外觀（103年度訴字第161號...）',
    ),
    CaseImage(
      url:
          'https://tse4.mm.bing.net/th/id/OIP.0SDoAANiAP6UoZPUrt3UqwHaEN?w=252&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '法學文獻與期刊論文引用頁面（103年度訴字第161號...）',
    ),
    CaseImage(
      url:
          'https://tse3.mm.bing.net/th/id/OIP.RHmdPX6UGcKBDnAmC1DuxQHaE7?w=215&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '中華民國六法全書民法債編法條（103年度訴字第161號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.WVO6tR5BzOgw0oglmH02OAHaEP?w=208&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '民事訴訟小額程序開庭流程圖（103年度訴字第161號...）',
    ),
    CaseImage(
      url:
          'https://tse3.mm.bing.net/th/id/OIP.8vGwbgtGBjFRl90_W32HlwHaE7?w=232&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '判決確定證明書與執行憑證抄本（103年度訴字第161號...）',
    )
  ],
  'case-062': const [
    CaseImage(
      url:
          'https://tse1.mm.bing.net/th/id/OIP.fEDFLQLHjS3QuE4bQLgBvQHaE8?w=229&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '【本案卷宗封面照片】法庭審判司法天平現場照片',
    ),
    CaseImage(
      url:
          'https://tse4.mm.bing.net/th/id/OIP.BpIJPdGnK-nMpGs5B9306AHaFe?w=206&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '最高法院司法卷宗圖書館（司法院釋字第 962 號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.6_z7cGk1TU-RBgQM3tsqZQHaE8?w=221&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '法規沿革與憲法判決法典（司法院釋字第 962 號...）',
    ),
    CaseImage(
      url:
          'https://tse3.mm.bing.net/th/id/OIP.RHmdPX6UGcKBDnAmC1DuxQHaE7?w=215&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '本案訴訟卷宗外觀及編號（司法院釋字第 962 號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.CR03_AAGv7DichRpWnF7NQHaE7?w=233&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '地方法院簡易庭外觀與開庭公告（司法院釋字第 962 號...）',
    ),
    CaseImage(
      url:
          'https://tse4.mm.bing.net/th/id/OIP.FVJkOeXgZVSaQPF4GFSr2QHaD8?w=89&h=90&c=1&rs=1&qlt=70&r=0&o=7&pid=InlineBlock&rm=3',
      source: '當事人提出之訴狀首頁抄本（司法院釋字第 962 號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.wXoezXbxYh3d5XAsPQA1mwHaE8?w=193&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '司法裁判書電子檔之判決主文（司法院釋字第 962 號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.jgOpaPncHSivavrOTSAXLgHaE8?w=232&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '民事起訴狀與委任律師書狀（司法院釋字第 962 號...）',
    ),
    CaseImage(
      url:
          'https://tse4.mm.bing.net/th/id/OIP.Q7FEnIHkrd6q9Jmu1GiKkwHaEj?w=248&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '法院準備程序筆錄簽名欄位（司法院釋字第 962 號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.M1ZTFf8JShiFpHtxNdAuTwHaEz?w=227&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '司法院大法官憲法法庭開庭現場（司法院釋字第 962 號...）',
    ),
    CaseImage(
      url:
          'https://tse4.mm.bing.net/th/id/OIP.zbbKZ0Bh_CpP6eZamtCRjwHaE9?w=179&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '最高法院民事庭開庭大門外觀（司法院釋字第 962 號...）',
    ),
    CaseImage(
      url:
          'https://tse3.mm.bing.net/th/id/OIP.8vGwbgtGBjFRl90_W32HlwHaE7?w=232&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '法學文獻與期刊論文引用頁面（司法院釋字第 962 號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.22mIh8FxQ1xTrLJEOF-vTgHaEO?w=89&h=89&c=1&rs=1&qlt=70&r=0&o=7&pid=InlineBlock&rm=3',
      source: '中華民國六法全書民法債編法條（司法院釋字第 962 號...）',
    ),
    CaseImage(
      url:
          'https://tse1.mm.bing.net/th/id/OIP.kgAAgTi1mrNURfP1WvpUNQHaFj?w=89&h=90&c=1&rs=1&qlt=70&r=0&o=7&pid=InlineBlock&rm=3',
      source: '民事訴訟小額程序開庭流程圖（司法院釋字第 962 號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.FxsIbUCjMd4IlOEskxShJgHaFj?w=89&h=89&c=1&rs=1&qlt=70&r=0&o=7&pid=InlineBlock&rm=3',
      source: '判決確定證明書與執行憑證抄本（司法院釋字第 962 號...）',
    )
  ],
  'case-063': const [
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.jgOpaPncHSivavrOTSAXLgHaE8?w=232&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '【本案卷宗封面照片】法庭審判司法天平現場照片',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.6_z7cGk1TU-RBgQM3tsqZQHaE8?w=221&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '最高法院司法卷宗圖書館（司法院釋字第 963 號...）',
    ),
    CaseImage(
      url:
          'https://tse1.mm.bing.net/th/id/OIP.kgAAgTi1mrNURfP1WvpUNQHaFj?w=89&h=90&c=1&rs=1&qlt=70&r=0&o=7&pid=InlineBlock&rm=3',
      source: '法規沿革與憲法判決法典（司法院釋字第 963 號...）',
    ),
    CaseImage(
      url:
          'https://tse1.mm.bing.net/th/id/OIP.xExaObj3A3nV3olc0K1gmwHaEJ?w=263&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '本案訴訟卷宗外觀及編號（司法院釋字第 963 號...）',
    ),
    CaseImage(
      url:
          'https://tse4.mm.bing.net/th/id/OIP.0SDoAANiAP6UoZPUrt3UqwHaEN?w=252&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '地方法院簡易庭外觀與開庭公告（司法院釋字第 963 號...）',
    ),
    CaseImage(
      url:
          'https://tse4.mm.bing.net/th/id/OIP.FVJkOeXgZVSaQPF4GFSr2QHaD8?w=89&h=90&c=1&rs=1&qlt=70&r=0&o=7&pid=InlineBlock&rm=3',
      source: '當事人提出之訴狀首頁抄本（司法院釋字第 963 號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.FxsIbUCjMd4IlOEskxShJgHaFj?w=89&h=89&c=1&rs=1&qlt=70&r=0&o=7&pid=InlineBlock&rm=3',
      source: '司法裁判書電子檔之判決主文（司法院釋字第 963 號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.22mIh8FxQ1xTrLJEOF-vTgHaEO?w=89&h=89&c=1&rs=1&qlt=70&r=0&o=7&pid=InlineBlock&rm=3',
      source: '民事起訴狀與委任律師書狀（司法院釋字第 963 號...）',
    ),
    CaseImage(
      url:
          'https://tse1.mm.bing.net/th/id/OIP.fEDFLQLHjS3QuE4bQLgBvQHaE8?w=229&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '法院準備程序筆錄簽名欄位（司法院釋字第 963 號...）',
    ),
    CaseImage(
      url:
          'https://tse3.mm.bing.net/th/id/OIP.FzL2M5zkVz2nUbqZg7Qe-QHaE7?w=215&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '司法院大法官憲法法庭開庭現場（司法院釋字第 963 號...）',
    ),
    CaseImage(
      url:
          'https://tse4.mm.bing.net/th/id/OIP.Q7FEnIHkrd6q9Jmu1GiKkwHaEj?w=248&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '最高法院民事庭開庭大門外觀（司法院釋字第 963 號...）',
    ),
    CaseImage(
      url:
          'https://tse3.mm.bing.net/th/id/OIP.rgvPoDUIQa-Gb56tJrl6sgHaEO?w=89&h=90&c=1&rs=1&qlt=70&r=0&o=7&pid=InlineBlock&rm=3',
      source: '法學文獻與期刊論文引用頁面（司法院釋字第 963 號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.CR03_AAGv7DichRpWnF7NQHaE7?w=233&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '中華民國六法全書民法債編法條（司法院釋字第 963 號...）',
    ),
    CaseImage(
      url:
          'https://tse3.mm.bing.net/th/id/OIP.8vGwbgtGBjFRl90_W32HlwHaE7?w=232&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '民事訴訟小額程序開庭流程圖（司法院釋字第 963 號...）',
    ),
    CaseImage(
      url:
          'https://tse4.mm.bing.net/th/id/OIP.BpIJPdGnK-nMpGs5B9306AHaFe?w=206&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '判決確定證明書與執行憑證抄本（司法院釋字第 963 號...）',
    )
  ],
  'case-064': const [
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.CR03_AAGv7DichRpWnF7NQHaE7?w=233&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '【本案卷宗封面照片】法庭審判司法天平現場照片',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.M1ZTFf8JShiFpHtxNdAuTwHaEz?w=227&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '最高法院司法卷宗圖書館（司法院釋字第 964 號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.6_z7cGk1TU-RBgQM3tsqZQHaE8?w=221&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '法規沿革與憲法判決法典（司法院釋字第 964 號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.EQboFDqbqWRcR8PTOr3wQwHaDn?w=297&h=171&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '本案訴訟卷宗外觀及編號（司法院釋字第 964 號...）',
    ),
    CaseImage(
      url:
          'https://tse4.mm.bing.net/th/id/OIP.Q7FEnIHkrd6q9Jmu1GiKkwHaEj?w=248&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '地方法院簡易庭外觀與開庭公告（司法院釋字第 964 號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.FxsIbUCjMd4IlOEskxShJgHaFj?w=89&h=89&c=1&rs=1&qlt=70&r=0&o=7&pid=InlineBlock&rm=3',
      source: '當事人提出之訴狀首頁抄本（司法院釋字第 964 號...）',
    ),
    CaseImage(
      url:
          'https://tse1.mm.bing.net/th/id/OIP.kgAAgTi1mrNURfP1WvpUNQHaFj?w=89&h=90&c=1&rs=1&qlt=70&r=0&o=7&pid=InlineBlock&rm=3',
      source: '司法裁判書電子檔之判決主文（司法院釋字第 964 號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.22mIh8FxQ1xTrLJEOF-vTgHaEO?w=89&h=89&c=1&rs=1&qlt=70&r=0&o=7&pid=InlineBlock&rm=3',
      source: '民事起訴狀與委任律師書狀（司法院釋字第 964 號...）',
    ),
    CaseImage(
      url:
          'https://tse1.mm.bing.net/th/id/OIP.fEDFLQLHjS3QuE4bQLgBvQHaE8?w=229&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '法院準備程序筆錄簽名欄位（司法院釋字第 964 號...）',
    ),
    CaseImage(
      url:
          'https://tse3.mm.bing.net/th/id/OIP.FzL2M5zkVz2nUbqZg7Qe-QHaE7?w=215&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '司法院大法官憲法法庭開庭現場（司法院釋字第 964 號...）',
    ),
    CaseImage(
      url:
          'https://tse4.mm.bing.net/th/id/OIP.zbbKZ0Bh_CpP6eZamtCRjwHaE9?w=179&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '最高法院民事庭開庭大門外觀（司法院釋字第 964 號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.jgOpaPncHSivavrOTSAXLgHaE8?w=232&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '法學文獻與期刊論文引用頁面（司法院釋字第 964 號...）',
    ),
    CaseImage(
      url:
          'https://tse1.mm.bing.net/th/id/OIP.xExaObj3A3nV3olc0K1gmwHaEJ?w=263&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '中華民國六法全書民法債編法條（司法院釋字第 964 號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.Xt1C-7meX374BAg86KC6LwHaE8?w=89&h=89&c=1&rs=1&qlt=70&r=0&o=7&pid=InlineBlock&rm=3',
      source: '民事訴訟小額程序開庭流程圖（司法院釋字第 964 號...）',
    ),
    CaseImage(
      url:
          'https://tse3.mm.bing.net/th/id/OIP.rgvPoDUIQa-Gb56tJrl6sgHaEO?w=89&h=90&c=1&rs=1&qlt=70&r=0&o=7&pid=InlineBlock&rm=3',
      source: '判決確定證明書與執行憑證抄本（司法院釋字第 964 號...）',
    )
  ],
  'case-065': const [
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.Xt1C-7meX374BAg86KC6LwHaE8?w=89&h=89&c=1&rs=1&qlt=70&r=0&o=7&pid=InlineBlock&rm=3',
      source: '【本案卷宗封面照片】法庭審判司法天平現場照片',
    ),
    CaseImage(
      url:
          'https://tse4.mm.bing.net/th/id/OIP.FVJkOeXgZVSaQPF4GFSr2QHaD8?w=89&h=90&c=1&rs=1&qlt=70&r=0&o=7&pid=InlineBlock&rm=3',
      source: '最高法院司法卷宗圖書館（111 年憲判字第 6 ...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.6_z7cGk1TU-RBgQM3tsqZQHaE8?w=221&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '法規沿革與憲法判決法典（111 年憲判字第 6 ...）',
    ),
    CaseImage(
      url:
          'https://tse3.mm.bing.net/th/id/OIP.rgvPoDUIQa-Gb56tJrl6sgHaEO?w=89&h=90&c=1&rs=1&qlt=70&r=0&o=7&pid=InlineBlock&rm=3',
      source: '本案訴訟卷宗外觀及編號（111 年憲判字第 6 ...）',
    ),
    CaseImage(
      url:
          'https://tse4.mm.bing.net/th/id/OIP.BpIJPdGnK-nMpGs5B9306AHaFe?w=206&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '地方法院簡易庭外觀與開庭公告（111 年憲判字第 6 ...）',
    ),
    CaseImage(
      url:
          'https://tse3.mm.bing.net/th/id/OIP.RHmdPX6UGcKBDnAmC1DuxQHaE7?w=215&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '當事人提出之訴狀首頁抄本（111 年憲判字第 6 ...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.wXoezXbxYh3d5XAsPQA1mwHaE8?w=193&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '司法裁判書電子檔之判決主文（111 年憲判字第 6 ...）',
    ),
    CaseImage(
      url:
          'https://tse1.mm.bing.net/th/id/OIP.fEDFLQLHjS3QuE4bQLgBvQHaE8?w=229&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '民事起訴狀與委任律師書狀（111 年憲判字第 6 ...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.EQboFDqbqWRcR8PTOr3wQwHaDn?w=297&h=171&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '法院準備程序筆錄簽名欄位（111 年憲判字第 6 ...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.FxsIbUCjMd4IlOEskxShJgHaFj?w=89&h=89&c=1&rs=1&qlt=70&r=0&o=7&pid=InlineBlock&rm=3',
      source: '司法院大法官憲法法庭開庭現場（111 年憲判字第 6 ...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.22mIh8FxQ1xTrLJEOF-vTgHaEO?w=89&h=89&c=1&rs=1&qlt=70&r=0&o=7&pid=InlineBlock&rm=3',
      source: '最高法院民事庭開庭大門外觀（111 年憲判字第 6 ...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.CR03_AAGv7DichRpWnF7NQHaE7?w=233&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '法學文獻與期刊論文引用頁面（111 年憲判字第 6 ...）',
    ),
    CaseImage(
      url:
          'https://tse3.mm.bing.net/th/id/OIP.8vGwbgtGBjFRl90_W32HlwHaE7?w=232&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '中華民國六法全書民法債編法條（111 年憲判字第 6 ...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.M1ZTFf8JShiFpHtxNdAuTwHaEz?w=227&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '民事訴訟小額程序開庭流程圖（111 年憲判字第 6 ...）',
    ),
    CaseImage(
      url:
          'https://tse4.mm.bing.net/th/id/OIP.Q7FEnIHkrd6q9Jmu1GiKkwHaEj?w=248&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '判決確定證明書與執行憑證抄本（111 年憲判字第 6 ...）',
    )
  ],
  'case-066': const [
    CaseImage(
      url:
          'https://tse1.mm.bing.net/th/id/OIP.fEDFLQLHjS3QuE4bQLgBvQHaE8?w=229&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '【本案卷宗封面照片】法庭審判司法天平現場照片',
    ),
    CaseImage(
      url:
          'https://tse1.mm.bing.net/th/id/OIP.xExaObj3A3nV3olc0K1gmwHaEJ?w=263&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '最高法院司法卷宗圖書館（112 年憲判字第 7 ...）',
    ),
    CaseImage(
      url:
          'https://tse4.mm.bing.net/th/id/OIP.BpIJPdGnK-nMpGs5B9306AHaFe?w=206&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '法規沿革與憲法判決法典（112 年憲判字第 7 ...）',
    ),
    CaseImage(
      url:
          'https://tse1.mm.bing.net/th/id/OIP.kgAAgTi1mrNURfP1WvpUNQHaFj?w=89&h=90&c=1&rs=1&qlt=70&r=0&o=7&pid=InlineBlock&rm=3',
      source: '本案訴訟卷宗外觀及編號（112 年憲判字第 7 ...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.Xt1C-7meX374BAg86KC6LwHaE8?w=89&h=89&c=1&rs=1&qlt=70&r=0&o=7&pid=InlineBlock&rm=3',
      source: '地方法院簡易庭外觀與開庭公告（112 年憲判字第 7 ...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.jgOpaPncHSivavrOTSAXLgHaE8?w=232&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '當事人提出之訴狀首頁抄本（112 年憲判字第 7 ...）',
    ),
    CaseImage(
      url:
          'https://tse3.mm.bing.net/th/id/OIP.rgvPoDUIQa-Gb56tJrl6sgHaEO?w=89&h=90&c=1&rs=1&qlt=70&r=0&o=7&pid=InlineBlock&rm=3',
      source: '司法裁判書電子檔之判決主文（112 年憲判字第 7 ...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.wXoezXbxYh3d5XAsPQA1mwHaE8?w=193&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '民事起訴狀與委任律師書狀（112 年憲判字第 7 ...）',
    ),
    CaseImage(
      url:
          'https://tse4.mm.bing.net/th/id/OIP.FVJkOeXgZVSaQPF4GFSr2QHaD8?w=89&h=90&c=1&rs=1&qlt=70&r=0&o=7&pid=InlineBlock&rm=3',
      source: '法院準備程序筆錄簽名欄位（112 年憲判字第 7 ...）',
    ),
    CaseImage(
      url:
          'https://tse3.mm.bing.net/th/id/OIP.FzL2M5zkVz2nUbqZg7Qe-QHaE7?w=215&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '司法院大法官憲法法庭開庭現場（112 年憲判字第 7 ...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.6_z7cGk1TU-RBgQM3tsqZQHaE8?w=221&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '最高法院民事庭開庭大門外觀（112 年憲判字第 7 ...）',
    ),
    CaseImage(
      url:
          'https://tse4.mm.bing.net/th/id/OIP.Q7FEnIHkrd6q9Jmu1GiKkwHaEj?w=248&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '法學文獻與期刊論文引用頁面（112 年憲判字第 7 ...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.CR03_AAGv7DichRpWnF7NQHaE7?w=233&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '中華民國六法全書民法債編法條（112 年憲判字第 7 ...）',
    ),
    CaseImage(
      url:
          'https://tse3.mm.bing.net/th/id/OIP.RHmdPX6UGcKBDnAmC1DuxQHaE7?w=215&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '民事訴訟小額程序開庭流程圖（112 年憲判字第 7 ...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.WVO6tR5BzOgw0oglmH02OAHaEP?w=208&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '判決確定證明書與執行憑證抄本（112 年憲判字第 7 ...）',
    )
  ],
  'case-067': const [
    CaseImage(
      url:
          'https://tse3.mm.bing.net/th/id/OIP.FzL2M5zkVz2nUbqZg7Qe-QHaE7?w=215&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '【本案卷宗封面照片】法庭審判司法天平現場照片',
    ),
    CaseImage(
      url:
          'https://tse4.mm.bing.net/th/id/OIP.FVJkOeXgZVSaQPF4GFSr2QHaD8?w=89&h=90&c=1&rs=1&qlt=70&r=0&o=7&pid=InlineBlock&rm=3',
      source: '最高法院司法卷宗圖書館（112 年憲判字第 8 ...）',
    ),
    CaseImage(
      url:
          'https://tse1.mm.bing.net/th/id/OIP.fEDFLQLHjS3QuE4bQLgBvQHaE8?w=229&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '法規沿革與憲法判決法典（112 年憲判字第 8 ...）',
    ),
    CaseImage(
      url:
          'https://tse4.mm.bing.net/th/id/OIP.0SDoAANiAP6UoZPUrt3UqwHaEN?w=252&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '本案訴訟卷宗外觀及編號（112 年憲判字第 8 ...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.Xt1C-7meX374BAg86KC6LwHaE8?w=89&h=89&c=1&rs=1&qlt=70&r=0&o=7&pid=InlineBlock&rm=3',
      source: '地方法院簡易庭外觀與開庭公告（112 年憲判字第 8 ...）',
    ),
    CaseImage(
      url:
          'https://tse3.mm.bing.net/th/id/OIP.8vGwbgtGBjFRl90_W32HlwHaE7?w=232&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '當事人提出之訴狀首頁抄本（112 年憲判字第 8 ...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.6_z7cGk1TU-RBgQM3tsqZQHaE8?w=221&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '司法裁判書電子檔之判決主文（112 年憲判字第 8 ...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.M1ZTFf8JShiFpHtxNdAuTwHaEz?w=227&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '民事起訴狀與委任律師書狀（112 年憲判字第 8 ...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.jgOpaPncHSivavrOTSAXLgHaE8?w=232&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '法院準備程序筆錄簽名欄位（112 年憲判字第 8 ...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.WVO6tR5BzOgw0oglmH02OAHaEP?w=208&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '司法院大法官憲法法庭開庭現場（112 年憲判字第 8 ...）',
    ),
    CaseImage(
      url:
          'https://tse4.mm.bing.net/th/id/OIP.Q7FEnIHkrd6q9Jmu1GiKkwHaEj?w=248&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '最高法院民事庭開庭大門外觀（112 年憲判字第 8 ...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.EQboFDqbqWRcR8PTOr3wQwHaDn?w=297&h=171&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '法學文獻與期刊論文引用頁面（112 年憲判字第 8 ...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.22mIh8FxQ1xTrLJEOF-vTgHaEO?w=89&h=89&c=1&rs=1&qlt=70&r=0&o=7&pid=InlineBlock&rm=3',
      source: '中華民國六法全書民法債編法條（112 年憲判字第 8 ...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.FxsIbUCjMd4IlOEskxShJgHaFj?w=89&h=89&c=1&rs=1&qlt=70&r=0&o=7&pid=InlineBlock&rm=3',
      source: '民事訴訟小額程序開庭流程圖（112 年憲判字第 8 ...）',
    ),
    CaseImage(
      url:
          'https://tse4.mm.bing.net/th/id/OIP.zbbKZ0Bh_CpP6eZamtCRjwHaE9?w=179&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '判決確定證明書與執行憑證抄本（112 年憲判字第 8 ...）',
    )
  ],
  'case-068': const [
    CaseImage(
      url:
          'https://tse1.mm.bing.net/th/id/OIP.kgAAgTi1mrNURfP1WvpUNQHaFj?w=89&h=90&c=1&rs=1&qlt=70&r=0&o=7&pid=InlineBlock&rm=3',
      source: '【本案卷宗封面照片】法庭審判司法天平現場照片',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.6_z7cGk1TU-RBgQM3tsqZQHaE8?w=221&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '最高法院司法卷宗圖書館（司法院釋字第 968 號...）',
    ),
    CaseImage(
      url:
          'https://tse3.mm.bing.net/th/id/OIP.rgvPoDUIQa-Gb56tJrl6sgHaEO?w=89&h=90&c=1&rs=1&qlt=70&r=0&o=7&pid=InlineBlock&rm=3',
      source: '法規沿革與憲法判決法典（司法院釋字第 968 號...）',
    ),
    CaseImage(
      url:
          'https://tse1.mm.bing.net/th/id/OIP.xExaObj3A3nV3olc0K1gmwHaEJ?w=263&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '本案訴訟卷宗外觀及編號（司法院釋字第 968 號...）',
    ),
    CaseImage(
      url:
          'https://tse4.mm.bing.net/th/id/OIP.BpIJPdGnK-nMpGs5B9306AHaFe?w=206&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '地方法院簡易庭外觀與開庭公告（司法院釋字第 968 號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.22mIh8FxQ1xTrLJEOF-vTgHaEO?w=89&h=89&c=1&rs=1&qlt=70&r=0&o=7&pid=InlineBlock&rm=3',
      source: '當事人提出之訴狀首頁抄本（司法院釋字第 968 號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.Xt1C-7meX374BAg86KC6LwHaE8?w=89&h=89&c=1&rs=1&qlt=70&r=0&o=7&pid=InlineBlock&rm=3',
      source: '司法裁判書電子檔之判決主文（司法院釋字第 968 號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.CR03_AAGv7DichRpWnF7NQHaE7?w=233&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '民事起訴狀與委任律師書狀（司法院釋字第 968 號...）',
    ),
    CaseImage(
      url:
          'https://tse3.mm.bing.net/th/id/OIP.FzL2M5zkVz2nUbqZg7Qe-QHaE7?w=215&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '法院準備程序筆錄簽名欄位（司法院釋字第 968 號...）',
    ),
    CaseImage(
      url:
          'https://tse1.mm.bing.net/th/id/OIP.fEDFLQLHjS3QuE4bQLgBvQHaE8?w=229&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '司法院大法官憲法法庭開庭現場（司法院釋字第 968 號...）',
    ),
    CaseImage(
      url:
          'https://tse4.mm.bing.net/th/id/OIP.FVJkOeXgZVSaQPF4GFSr2QHaD8?w=89&h=90&c=1&rs=1&qlt=70&r=0&o=7&pid=InlineBlock&rm=3',
      source: '最高法院民事庭開庭大門外觀（司法院釋字第 968 號...）',
    ),
    CaseImage(
      url:
          'https://tse3.mm.bing.net/th/id/OIP.8vGwbgtGBjFRl90_W32HlwHaE7?w=232&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '法學文獻與期刊論文引用頁面（司法院釋字第 968 號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.M1ZTFf8JShiFpHtxNdAuTwHaEz?w=227&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '中華民國六法全書民法債編法條（司法院釋字第 968 號...）',
    ),
    CaseImage(
      url:
          'https://tse4.mm.bing.net/th/id/OIP.0SDoAANiAP6UoZPUrt3UqwHaEN?w=252&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '民事訴訟小額程序開庭流程圖（司法院釋字第 968 號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.EQboFDqbqWRcR8PTOr3wQwHaDn?w=297&h=171&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '判決確定證明書與執行憑證抄本（司法院釋字第 968 號...）',
    )
  ],
  'case-069': const [
    CaseImage(
      url:
          'https://tse1.mm.bing.net/th/id/OIP.xExaObj3A3nV3olc0K1gmwHaEJ?w=263&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '【本案卷宗封面照片】法庭審判司法天平現場照片',
    ),
    CaseImage(
      url:
          'https://tse4.mm.bing.net/th/id/OIP.0SDoAANiAP6UoZPUrt3UqwHaEN?w=252&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '最高法院司法卷宗圖書館（司法院釋字第 969 號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.WVO6tR5BzOgw0oglmH02OAHaEP?w=208&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '法規沿革與憲法判決法典（司法院釋字第 969 號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.M1ZTFf8JShiFpHtxNdAuTwHaEz?w=227&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '本案訴訟卷宗外觀及編號（司法院釋字第 969 號...）',
    ),
    CaseImage(
      url:
          'https://tse4.mm.bing.net/th/id/OIP.Q7FEnIHkrd6q9Jmu1GiKkwHaEj?w=248&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '地方法院簡易庭外觀與開庭公告（司法院釋字第 969 號...）',
    ),
    CaseImage(
      url:
          'https://tse1.mm.bing.net/th/id/OIP.kgAAgTi1mrNURfP1WvpUNQHaFj?w=89&h=90&c=1&rs=1&qlt=70&r=0&o=7&pid=InlineBlock&rm=3',
      source: '當事人提出之訴狀首頁抄本（司法院釋字第 969 號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.Xt1C-7meX374BAg86KC6LwHaE8?w=89&h=89&c=1&rs=1&qlt=70&r=0&o=7&pid=InlineBlock&rm=3',
      source: '司法裁判書電子檔之判決主文（司法院釋字第 969 號...）',
    ),
    CaseImage(
      url:
          'https://tse3.mm.bing.net/th/id/OIP.8vGwbgtGBjFRl90_W32HlwHaE7?w=232&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '民事起訴狀與委任律師書狀（司法院釋字第 969 號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.6_z7cGk1TU-RBgQM3tsqZQHaE8?w=221&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '法院準備程序筆錄簽名欄位（司法院釋字第 969 號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.EQboFDqbqWRcR8PTOr3wQwHaDn?w=297&h=171&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '司法院大法官憲法法庭開庭現場（司法院釋字第 969 號...）',
    ),
    CaseImage(
      url:
          'https://tse3.mm.bing.net/th/id/OIP.RHmdPX6UGcKBDnAmC1DuxQHaE7?w=215&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '最高法院民事庭開庭大門外觀（司法院釋字第 969 號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.22mIh8FxQ1xTrLJEOF-vTgHaEO?w=89&h=89&c=1&rs=1&qlt=70&r=0&o=7&pid=InlineBlock&rm=3',
      source: '法學文獻與期刊論文引用頁面（司法院釋字第 969 號...）',
    ),
    CaseImage(
      url:
          'https://tse1.mm.bing.net/th/id/OIP.fEDFLQLHjS3QuE4bQLgBvQHaE8?w=229&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '中華民國六法全書民法債編法條（司法院釋字第 969 號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.FxsIbUCjMd4IlOEskxShJgHaFj?w=89&h=89&c=1&rs=1&qlt=70&r=0&o=7&pid=InlineBlock&rm=3',
      source: '民事訴訟小額程序開庭流程圖（司法院釋字第 969 號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.jgOpaPncHSivavrOTSAXLgHaE8?w=232&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '判決確定證明書與執行憑證抄本（司法院釋字第 969 號...）',
    )
  ],
  'case-070': const [
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.EQboFDqbqWRcR8PTOr3wQwHaDn?w=297&h=171&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '【本案卷宗封面照片】法庭審判司法天平現場照片',
    ),
    CaseImage(
      url:
          'https://tse4.mm.bing.net/th/id/OIP.BpIJPdGnK-nMpGs5B9306AHaFe?w=206&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '最高法院司法卷宗圖書館（111 年憲判字第 11...）',
    ),
    CaseImage(
      url:
          'https://tse3.mm.bing.net/th/id/OIP.rgvPoDUIQa-Gb56tJrl6sgHaEO?w=89&h=90&c=1&rs=1&qlt=70&r=0&o=7&pid=InlineBlock&rm=3',
      source: '法規沿革與憲法判決法典（111 年憲判字第 11...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.Xt1C-7meX374BAg86KC6LwHaE8?w=89&h=89&c=1&rs=1&qlt=70&r=0&o=7&pid=InlineBlock&rm=3',
      source: '本案訴訟卷宗外觀及編號（111 年憲判字第 11...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.6_z7cGk1TU-RBgQM3tsqZQHaE8?w=221&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '地方法院簡易庭外觀與開庭公告（111 年憲判字第 11...）',
    ),
    CaseImage(
      url:
          'https://tse1.mm.bing.net/th/id/OIP.fEDFLQLHjS3QuE4bQLgBvQHaE8?w=229&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '當事人提出之訴狀首頁抄本（111 年憲判字第 11...）',
    ),
    CaseImage(
      url:
          'https://tse3.mm.bing.net/th/id/OIP.FzL2M5zkVz2nUbqZg7Qe-QHaE7?w=215&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '司法裁判書電子檔之判決主文（111 年憲判字第 11...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.22mIh8FxQ1xTrLJEOF-vTgHaEO?w=89&h=89&c=1&rs=1&qlt=70&r=0&o=7&pid=InlineBlock&rm=3',
      source: '民事起訴狀與委任律師書狀（111 年憲判字第 11...）',
    ),
    CaseImage(
      url:
          'https://tse1.mm.bing.net/th/id/OIP.kgAAgTi1mrNURfP1WvpUNQHaFj?w=89&h=90&c=1&rs=1&qlt=70&r=0&o=7&pid=InlineBlock&rm=3',
      source: '法院準備程序筆錄簽名欄位（111 年憲判字第 11...）',
    ),
    CaseImage(
      url:
          'https://tse4.mm.bing.net/th/id/OIP.Q7FEnIHkrd6q9Jmu1GiKkwHaEj?w=248&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '司法院大法官憲法法庭開庭現場（111 年憲判字第 11...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.M1ZTFf8JShiFpHtxNdAuTwHaEz?w=227&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '最高法院民事庭開庭大門外觀（111 年憲判字第 11...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.FxsIbUCjMd4IlOEskxShJgHaFj?w=89&h=89&c=1&rs=1&qlt=70&r=0&o=7&pid=InlineBlock&rm=3',
      source: '法學文獻與期刊論文引用頁面（111 年憲判字第 11...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.wXoezXbxYh3d5XAsPQA1mwHaE8?w=193&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '中華民國六法全書民法債編法條（111 年憲判字第 11...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.CR03_AAGv7DichRpWnF7NQHaE7?w=233&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '民事訴訟小額程序開庭流程圖（111 年憲判字第 11...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.WVO6tR5BzOgw0oglmH02OAHaEP?w=208&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '判決確定證明書與執行憑證抄本（111 年憲判字第 11...）',
    )
  ],
  'case-071': const [
    CaseImage(
      url:
          'https://tse1.mm.bing.net/th/id/OIP.fEDFLQLHjS3QuE4bQLgBvQHaE8?w=229&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '【本案卷宗封面照片】法庭審判司法天平現場照片',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.Xt1C-7meX374BAg86KC6LwHaE8?w=89&h=89&c=1&rs=1&qlt=70&r=0&o=7&pid=InlineBlock&rm=3',
      source: '最高法院司法卷宗圖書館（112 年憲判字第 12...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.EQboFDqbqWRcR8PTOr3wQwHaDn?w=297&h=171&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '法規沿革與憲法判決法典（112 年憲判字第 12...）',
    ),
    CaseImage(
      url:
          'https://tse4.mm.bing.net/th/id/OIP.FVJkOeXgZVSaQPF4GFSr2QHaD8?w=89&h=90&c=1&rs=1&qlt=70&r=0&o=7&pid=InlineBlock&rm=3',
      source: '本案訴訟卷宗外觀及編號（112 年憲判字第 12...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.22mIh8FxQ1xTrLJEOF-vTgHaEO?w=89&h=89&c=1&rs=1&qlt=70&r=0&o=7&pid=InlineBlock&rm=3',
      source: '地方法院簡易庭外觀與開庭公告（112 年憲判字第 12...）',
    ),
    CaseImage(
      url:
          'https://tse3.mm.bing.net/th/id/OIP.8vGwbgtGBjFRl90_W32HlwHaE7?w=232&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '當事人提出之訴狀首頁抄本（112 年憲判字第 12...）',
    ),
    CaseImage(
      url:
          'https://tse1.mm.bing.net/th/id/OIP.xExaObj3A3nV3olc0K1gmwHaEJ?w=263&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '司法裁判書電子檔之判決主文（112 年憲判字第 12...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.6_z7cGk1TU-RBgQM3tsqZQHaE8?w=221&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '民事起訴狀與委任律師書狀（112 年憲判字第 12...）',
    ),
    CaseImage(
      url:
          'https://tse3.mm.bing.net/th/id/OIP.RHmdPX6UGcKBDnAmC1DuxQHaE7?w=215&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '法院準備程序筆錄簽名欄位（112 年憲判字第 12...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.FxsIbUCjMd4IlOEskxShJgHaFj?w=89&h=89&c=1&rs=1&qlt=70&r=0&o=7&pid=InlineBlock&rm=3',
      source: '司法院大法官憲法法庭開庭現場（112 年憲判字第 12...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.wXoezXbxYh3d5XAsPQA1mwHaE8?w=193&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '最高法院民事庭開庭大門外觀（112 年憲判字第 12...）',
    ),
    CaseImage(
      url:
          'https://tse4.mm.bing.net/th/id/OIP.zbbKZ0Bh_CpP6eZamtCRjwHaE9?w=179&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '法學文獻與期刊論文引用頁面（112 年憲判字第 12...）',
    ),
    CaseImage(
      url:
          'https://tse4.mm.bing.net/th/id/OIP.Q7FEnIHkrd6q9Jmu1GiKkwHaEj?w=248&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '中華民國六法全書民法債編法條（112 年憲判字第 12...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.WVO6tR5BzOgw0oglmH02OAHaEP?w=208&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '民事訴訟小額程序開庭流程圖（112 年憲判字第 12...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.jgOpaPncHSivavrOTSAXLgHaE8?w=232&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '判決確定證明書與執行憑證抄本（112 年憲判字第 12...）',
    )
  ],
  'case-072': const [
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.WVO6tR5BzOgw0oglmH02OAHaEP?w=208&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '【本案卷宗封面照片】法庭審判司法天平現場照片',
    ),
    CaseImage(
      url:
          'https://tse4.mm.bing.net/th/id/OIP.zbbKZ0Bh_CpP6eZamtCRjwHaE9?w=179&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '最高法院司法卷宗圖書館（108年度訴字第172號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.EQboFDqbqWRcR8PTOr3wQwHaDn?w=297&h=171&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '法規沿革與憲法判決法典（108年度訴字第172號...）',
    ),
    CaseImage(
      url:
          'https://tse3.mm.bing.net/th/id/OIP.rgvPoDUIQa-Gb56tJrl6sgHaEO?w=89&h=90&c=1&rs=1&qlt=70&r=0&o=7&pid=InlineBlock&rm=3',
      source: '本案訴訟卷宗外觀及編號（108年度訴字第172號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.Xt1C-7meX374BAg86KC6LwHaE8?w=89&h=89&c=1&rs=1&qlt=70&r=0&o=7&pid=InlineBlock&rm=3',
      source: '地方法院簡易庭外觀與開庭公告（108年度訴字第172號...）',
    ),
    CaseImage(
      url:
          'https://tse1.mm.bing.net/th/id/OIP.xExaObj3A3nV3olc0K1gmwHaEJ?w=263&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '當事人提出之訴狀首頁抄本（108年度訴字第172號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.M1ZTFf8JShiFpHtxNdAuTwHaEz?w=227&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '司法裁判書電子檔之判決主文（108年度訴字第172號...）',
    ),
    CaseImage(
      url:
          'https://tse3.mm.bing.net/th/id/OIP.RHmdPX6UGcKBDnAmC1DuxQHaE7?w=215&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '民事起訴狀與委任律師書狀（108年度訴字第172號...）',
    ),
    CaseImage(
      url:
          'https://tse4.mm.bing.net/th/id/OIP.0SDoAANiAP6UoZPUrt3UqwHaEN?w=252&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '法院準備程序筆錄簽名欄位（108年度訴字第172號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.jgOpaPncHSivavrOTSAXLgHaE8?w=232&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '司法院大法官憲法法庭開庭現場（108年度訴字第172號...）',
    ),
    CaseImage(
      url:
          'https://tse3.mm.bing.net/th/id/OIP.8vGwbgtGBjFRl90_W32HlwHaE7?w=232&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '最高法院民事庭開庭大門外觀（108年度訴字第172號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.CR03_AAGv7DichRpWnF7NQHaE7?w=233&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '法學文獻與期刊論文引用頁面（108年度訴字第172號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.22mIh8FxQ1xTrLJEOF-vTgHaEO?w=89&h=89&c=1&rs=1&qlt=70&r=0&o=7&pid=InlineBlock&rm=3',
      source: '中華民國六法全書民法債編法條（108年度訴字第172號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.FxsIbUCjMd4IlOEskxShJgHaFj?w=89&h=89&c=1&rs=1&qlt=70&r=0&o=7&pid=InlineBlock&rm=3',
      source: '民事訴訟小額程序開庭流程圖（108年度訴字第172號...）',
    ),
    CaseImage(
      url:
          'https://tse1.mm.bing.net/th/id/OIP.kgAAgTi1mrNURfP1WvpUNQHaFj?w=89&h=90&c=1&rs=1&qlt=70&r=0&o=7&pid=InlineBlock&rm=3',
      source: '判決確定證明書與執行憑證抄本（108年度訴字第172號...）',
    )
  ],
  'case-073': const [
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.EQboFDqbqWRcR8PTOr3wQwHaDn?w=297&h=171&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '【本案卷宗封面照片】法庭審判司法天平現場照片',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.M1ZTFf8JShiFpHtxNdAuTwHaEz?w=227&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '最高法院司法卷宗圖書館（109年度訴字第173號...）',
    ),
    CaseImage(
      url:
          'https://tse4.mm.bing.net/th/id/OIP.Q7FEnIHkrd6q9Jmu1GiKkwHaEj?w=248&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '法規沿革與憲法判決法典（109年度訴字第173號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.wXoezXbxYh3d5XAsPQA1mwHaE8?w=193&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '本案訴訟卷宗外觀及編號（109年度訴字第173號...）',
    ),
    CaseImage(
      url:
          'https://tse4.mm.bing.net/th/id/OIP.zbbKZ0Bh_CpP6eZamtCRjwHaE9?w=179&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '地方法院簡易庭外觀與開庭公告（109年度訴字第173號...）',
    ),
    CaseImage(
      url:
          'https://tse3.mm.bing.net/th/id/OIP.rgvPoDUIQa-Gb56tJrl6sgHaEO?w=89&h=90&c=1&rs=1&qlt=70&r=0&o=7&pid=InlineBlock&rm=3',
      source: '當事人提出之訴狀首頁抄本（109年度訴字第173號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.CR03_AAGv7DichRpWnF7NQHaE7?w=233&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '司法裁判書電子檔之判決主文（109年度訴字第173號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.jgOpaPncHSivavrOTSAXLgHaE8?w=232&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '民事起訴狀與委任律師書狀（109年度訴字第173號...）',
    ),
    CaseImage(
      url:
          'https://tse1.mm.bing.net/th/id/OIP.kgAAgTi1mrNURfP1WvpUNQHaFj?w=89&h=90&c=1&rs=1&qlt=70&r=0&o=7&pid=InlineBlock&rm=3',
      source: '法院準備程序筆錄簽名欄位（109年度訴字第173號...）',
    ),
    CaseImage(
      url:
          'https://tse4.mm.bing.net/th/id/OIP.0SDoAANiAP6UoZPUrt3UqwHaEN?w=252&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '司法院大法官憲法法庭開庭現場（109年度訴字第173號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.FxsIbUCjMd4IlOEskxShJgHaFj?w=89&h=89&c=1&rs=1&qlt=70&r=0&o=7&pid=InlineBlock&rm=3',
      source: '最高法院民事庭開庭大門外觀（109年度訴字第173號...）',
    ),
    CaseImage(
      url:
          'https://tse1.mm.bing.net/th/id/OIP.xExaObj3A3nV3olc0K1gmwHaEJ?w=263&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '法學文獻與期刊論文引用頁面（109年度訴字第173號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.22mIh8FxQ1xTrLJEOF-vTgHaEO?w=89&h=89&c=1&rs=1&qlt=70&r=0&o=7&pid=InlineBlock&rm=3',
      source: '中華民國六法全書民法債編法條（109年度訴字第173號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.Xt1C-7meX374BAg86KC6LwHaE8?w=89&h=89&c=1&rs=1&qlt=70&r=0&o=7&pid=InlineBlock&rm=3',
      source: '民事訴訟小額程序開庭流程圖（109年度訴字第173號...）',
    ),
    CaseImage(
      url:
          'https://tse1.mm.bing.net/th/id/OIP.fEDFLQLHjS3QuE4bQLgBvQHaE8?w=229&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '判決確定證明書與執行憑證抄本（109年度訴字第173號...）',
    )
  ],
  'case-074': const [
    CaseImage(
      url:
          'https://tse4.mm.bing.net/th/id/OIP.Q7FEnIHkrd6q9Jmu1GiKkwHaEj?w=248&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '【本案卷宗封面照片】法庭審判司法天平現場照片',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.WVO6tR5BzOgw0oglmH02OAHaEP?w=208&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '最高法院司法卷宗圖書館（110年度訴字第174號...）',
    ),
    CaseImage(
      url:
          'https://tse4.mm.bing.net/th/id/OIP.0SDoAANiAP6UoZPUrt3UqwHaEN?w=252&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '法規沿革與憲法判決法典（110年度訴字第174號...）',
    ),
    CaseImage(
      url:
          'https://tse3.mm.bing.net/th/id/OIP.RHmdPX6UGcKBDnAmC1DuxQHaE7?w=215&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '本案訴訟卷宗外觀及編號（110年度訴字第174號...）',
    ),
    CaseImage(
      url:
          'https://tse3.mm.bing.net/th/id/OIP.rgvPoDUIQa-Gb56tJrl6sgHaEO?w=89&h=90&c=1&rs=1&qlt=70&r=0&o=7&pid=InlineBlock&rm=3',
      source: '地方法院簡易庭外觀與開庭公告（110年度訴字第174號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.Xt1C-7meX374BAg86KC6LwHaE8?w=89&h=89&c=1&rs=1&qlt=70&r=0&o=7&pid=InlineBlock&rm=3',
      source: '當事人提出之訴狀首頁抄本（110年度訴字第174號...）',
    ),
    CaseImage(
      url:
          'https://tse1.mm.bing.net/th/id/OIP.kgAAgTi1mrNURfP1WvpUNQHaFj?w=89&h=90&c=1&rs=1&qlt=70&r=0&o=7&pid=InlineBlock&rm=3',
      source: '司法裁判書電子檔之判決主文（110年度訴字第174號...）',
    ),
    CaseImage(
      url:
          'https://tse1.mm.bing.net/th/id/OIP.xExaObj3A3nV3olc0K1gmwHaEJ?w=263&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '民事起訴狀與委任律師書狀（110年度訴字第174號...）',
    ),
    CaseImage(
      url:
          'https://tse3.mm.bing.net/th/id/OIP.FzL2M5zkVz2nUbqZg7Qe-QHaE7?w=215&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '法院準備程序筆錄簽名欄位（110年度訴字第174號...）',
    ),
    CaseImage(
      url:
          'https://tse1.mm.bing.net/th/id/OIP.fEDFLQLHjS3QuE4bQLgBvQHaE8?w=229&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '司法院大法官憲法法庭開庭現場（110年度訴字第174號...）',
    ),
    CaseImage(
      url:
          'https://tse4.mm.bing.net/th/id/OIP.BpIJPdGnK-nMpGs5B9306AHaFe?w=206&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '最高法院民事庭開庭大門外觀（110年度訴字第174號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.M1ZTFf8JShiFpHtxNdAuTwHaEz?w=227&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '法學文獻與期刊論文引用頁面（110年度訴字第174號...）',
    ),
    CaseImage(
      url:
          'https://tse4.mm.bing.net/th/id/OIP.zbbKZ0Bh_CpP6eZamtCRjwHaE9?w=179&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '中華民國六法全書民法債編法條（110年度訴字第174號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.jgOpaPncHSivavrOTSAXLgHaE8?w=232&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '民事訴訟小額程序開庭流程圖（110年度訴字第174號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.wXoezXbxYh3d5XAsPQA1mwHaE8?w=193&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '判決確定證明書與執行憑證抄本（110年度訴字第174號...）',
    )
  ],
  'case-075': const [
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.6_z7cGk1TU-RBgQM3tsqZQHaE8?w=221&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '【本案卷宗封面照片】法庭審判司法天平現場照片',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.jgOpaPncHSivavrOTSAXLgHaE8?w=232&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '最高法院司法卷宗圖書館（111年度訴字第175號...）',
    ),
    CaseImage(
      url:
          'https://tse4.mm.bing.net/th/id/OIP.BpIJPdGnK-nMpGs5B9306AHaFe?w=206&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '法規沿革與憲法判決法典（111年度訴字第175號...）',
    ),
    CaseImage(
      url:
          'https://tse1.mm.bing.net/th/id/OIP.kgAAgTi1mrNURfP1WvpUNQHaFj?w=89&h=90&c=1&rs=1&qlt=70&r=0&o=7&pid=InlineBlock&rm=3',
      source: '本案訴訟卷宗外觀及編號（111年度訴字第175號...）',
    ),
    CaseImage(
      url:
          'https://tse3.mm.bing.net/th/id/OIP.8vGwbgtGBjFRl90_W32HlwHaE7?w=232&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '地方法院簡易庭外觀與開庭公告（111年度訴字第175號...）',
    ),
    CaseImage(
      url:
          'https://tse3.mm.bing.net/th/id/OIP.FzL2M5zkVz2nUbqZg7Qe-QHaE7?w=215&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '當事人提出之訴狀首頁抄本（111年度訴字第175號...）',
    ),
    CaseImage(
      url:
          'https://tse3.mm.bing.net/th/id/OIP.RHmdPX6UGcKBDnAmC1DuxQHaE7?w=215&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '司法裁判書電子檔之判決主文（111年度訴字第175號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.wXoezXbxYh3d5XAsPQA1mwHaE8?w=193&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '民事起訴狀與委任律師書狀（111年度訴字第175號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.FxsIbUCjMd4IlOEskxShJgHaFj?w=89&h=89&c=1&rs=1&qlt=70&r=0&o=7&pid=InlineBlock&rm=3',
      source: '法院準備程序筆錄簽名欄位（111年度訴字第175號...）',
    ),
    CaseImage(
      url:
          'https://tse1.mm.bing.net/th/id/OIP.xExaObj3A3nV3olc0K1gmwHaEJ?w=263&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '司法院大法官憲法法庭開庭現場（111年度訴字第175號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.CR03_AAGv7DichRpWnF7NQHaE7?w=233&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '最高法院民事庭開庭大門外觀（111年度訴字第175號...）',
    ),
    CaseImage(
      url:
          'https://tse3.mm.bing.net/th/id/OIP.rgvPoDUIQa-Gb56tJrl6sgHaEO?w=89&h=90&c=1&rs=1&qlt=70&r=0&o=7&pid=InlineBlock&rm=3',
      source: '法學文獻與期刊論文引用頁面（111年度訴字第175號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.22mIh8FxQ1xTrLJEOF-vTgHaEO?w=89&h=89&c=1&rs=1&qlt=70&r=0&o=7&pid=InlineBlock&rm=3',
      source: '中華民國六法全書民法債編法條（111年度訴字第175號...）',
    ),
    CaseImage(
      url:
          'https://tse4.mm.bing.net/th/id/OIP.Q7FEnIHkrd6q9Jmu1GiKkwHaEj?w=248&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '民事訴訟小額程序開庭流程圖（111年度訴字第175號...）',
    ),
    CaseImage(
      url:
          'https://tse4.mm.bing.net/th/id/OIP.0SDoAANiAP6UoZPUrt3UqwHaEN?w=252&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '判決確定證明書與執行憑證抄本（111年度訴字第175號...）',
    )
  ],
  'case-076': const [
    CaseImage(
      url:
          'https://tse4.mm.bing.net/th/id/OIP.BpIJPdGnK-nMpGs5B9306AHaFe?w=206&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '【本案卷宗封面照片】法庭審判司法天平現場照片',
    ),
    CaseImage(
      url:
          'https://tse4.mm.bing.net/th/id/OIP.0SDoAANiAP6UoZPUrt3UqwHaEN?w=252&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '最高法院司法卷宗圖書館（109年度訴字第176號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.M1ZTFf8JShiFpHtxNdAuTwHaEz?w=227&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '法規沿革與憲法判決法典（109年度訴字第176號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.FxsIbUCjMd4IlOEskxShJgHaFj?w=89&h=89&c=1&rs=1&qlt=70&r=0&o=7&pid=InlineBlock&rm=3',
      source: '本案訴訟卷宗外觀及編號（109年度訴字第176號...）',
    ),
    CaseImage(
      url:
          'https://tse4.mm.bing.net/th/id/OIP.zbbKZ0Bh_CpP6eZamtCRjwHaE9?w=179&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '地方法院簡易庭外觀與開庭公告（109年度訴字第176號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.CR03_AAGv7DichRpWnF7NQHaE7?w=233&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '當事人提出之訴狀首頁抄本（109年度訴字第176號...）',
    ),
    CaseImage(
      url:
          'https://tse3.mm.bing.net/th/id/OIP.rgvPoDUIQa-Gb56tJrl6sgHaEO?w=89&h=90&c=1&rs=1&qlt=70&r=0&o=7&pid=InlineBlock&rm=3',
      source: '司法裁判書電子檔之判決主文（109年度訴字第176號...）',
    ),
    CaseImage(
      url:
          'https://tse3.mm.bing.net/th/id/OIP.FzL2M5zkVz2nUbqZg7Qe-QHaE7?w=215&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '民事起訴狀與委任律師書狀（109年度訴字第176號...）',
    ),
    CaseImage(
      url:
          'https://tse1.mm.bing.net/th/id/OIP.xExaObj3A3nV3olc0K1gmwHaEJ?w=263&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '法院準備程序筆錄簽名欄位（109年度訴字第176號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.22mIh8FxQ1xTrLJEOF-vTgHaEO?w=89&h=89&c=1&rs=1&qlt=70&r=0&o=7&pid=InlineBlock&rm=3',
      source: '司法院大法官憲法法庭開庭現場（109年度訴字第176號...）',
    ),
    CaseImage(
      url:
          'https://tse1.mm.bing.net/th/id/OIP.kgAAgTi1mrNURfP1WvpUNQHaFj?w=89&h=90&c=1&rs=1&qlt=70&r=0&o=7&pid=InlineBlock&rm=3',
      source: '最高法院民事庭開庭大門外觀（109年度訴字第176號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.wXoezXbxYh3d5XAsPQA1mwHaE8?w=193&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '法學文獻與期刊論文引用頁面（109年度訴字第176號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.Xt1C-7meX374BAg86KC6LwHaE8?w=89&h=89&c=1&rs=1&qlt=70&r=0&o=7&pid=InlineBlock&rm=3',
      source: '中華民國六法全書民法債編法條（109年度訴字第176號...）',
    ),
    CaseImage(
      url:
          'https://tse1.mm.bing.net/th/id/OIP.fEDFLQLHjS3QuE4bQLgBvQHaE8?w=229&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '民事訴訟小額程序開庭流程圖（109年度訴字第176號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.jgOpaPncHSivavrOTSAXLgHaE8?w=232&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '判決確定證明書與執行憑證抄本（109年度訴字第176號...）',
    )
  ],
  'case-077': const [
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.wXoezXbxYh3d5XAsPQA1mwHaE8?w=193&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '【本案卷宗封面照片】法庭審判司法天平現場照片',
    ),
    CaseImage(
      url:
          'https://tse3.mm.bing.net/th/id/OIP.RHmdPX6UGcKBDnAmC1DuxQHaE7?w=215&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '最高法院司法卷宗圖書館（107年度訴字第177號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.WVO6tR5BzOgw0oglmH02OAHaEP?w=208&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '法規沿革與憲法判決法典（107年度訴字第177號...）',
    ),
    CaseImage(
      url:
          'https://tse4.mm.bing.net/th/id/OIP.FVJkOeXgZVSaQPF4GFSr2QHaD8?w=89&h=90&c=1&rs=1&qlt=70&r=0&o=7&pid=InlineBlock&rm=3',
      source: '本案訴訟卷宗外觀及編號（107年度訴字第177號...）',
    ),
    CaseImage(
      url:
          'https://tse4.mm.bing.net/th/id/OIP.zbbKZ0Bh_CpP6eZamtCRjwHaE9?w=179&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '地方法院簡易庭外觀與開庭公告（107年度訴字第177號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.22mIh8FxQ1xTrLJEOF-vTgHaEO?w=89&h=89&c=1&rs=1&qlt=70&r=0&o=7&pid=InlineBlock&rm=3',
      source: '當事人提出之訴狀首頁抄本（107年度訴字第177號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.jgOpaPncHSivavrOTSAXLgHaE8?w=232&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '司法裁判書電子檔之判決主文（107年度訴字第177號...）',
    ),
    CaseImage(
      url:
          'https://tse4.mm.bing.net/th/id/OIP.BpIJPdGnK-nMpGs5B9306AHaFe?w=206&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '民事起訴狀與委任律師書狀（107年度訴字第177號...）',
    ),
    CaseImage(
      url:
          'https://tse1.mm.bing.net/th/id/OIP.kgAAgTi1mrNURfP1WvpUNQHaFj?w=89&h=90&c=1&rs=1&qlt=70&r=0&o=7&pid=InlineBlock&rm=3',
      source: '法院準備程序筆錄簽名欄位（107年度訴字第177號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.6_z7cGk1TU-RBgQM3tsqZQHaE8?w=221&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '司法院大法官憲法法庭開庭現場（107年度訴字第177號...）',
    ),
    CaseImage(
      url:
          'https://tse3.mm.bing.net/th/id/OIP.rgvPoDUIQa-Gb56tJrl6sgHaEO?w=89&h=90&c=1&rs=1&qlt=70&r=0&o=7&pid=InlineBlock&rm=3',
      source: '最高法院民事庭開庭大門外觀（107年度訴字第177號...）',
    ),
    CaseImage(
      url:
          'https://tse3.mm.bing.net/th/id/OIP.8vGwbgtGBjFRl90_W32HlwHaE7?w=232&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '法學文獻與期刊論文引用頁面（107年度訴字第177號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.M1ZTFf8JShiFpHtxNdAuTwHaEz?w=227&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '中華民國六法全書民法債編法條（107年度訴字第177號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.FxsIbUCjMd4IlOEskxShJgHaFj?w=89&h=89&c=1&rs=1&qlt=70&r=0&o=7&pid=InlineBlock&rm=3',
      source: '民事訴訟小額程序開庭流程圖（107年度訴字第177號...）',
    ),
    CaseImage(
      url:
          'https://tse4.mm.bing.net/th/id/OIP.Q7FEnIHkrd6q9Jmu1GiKkwHaEj?w=248&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '判決確定證明書與執行憑證抄本（107年度訴字第177號...）',
    )
  ],
  'case-078': const [
    CaseImage(
      url:
          'https://tse3.mm.bing.net/th/id/OIP.RHmdPX6UGcKBDnAmC1DuxQHaE7?w=215&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '【本案卷宗封面照片】法庭審判司法天平現場照片',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.CR03_AAGv7DichRpWnF7NQHaE7?w=233&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '最高法院司法卷宗圖書館（110年度訴字第178號...）',
    ),
    CaseImage(
      url:
          'https://tse3.mm.bing.net/th/id/OIP.8vGwbgtGBjFRl90_W32HlwHaE7?w=232&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '法規沿革與憲法判決法典（110年度訴字第178號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.jgOpaPncHSivavrOTSAXLgHaE8?w=232&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '本案訴訟卷宗外觀及編號（110年度訴字第178號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.22mIh8FxQ1xTrLJEOF-vTgHaEO?w=89&h=89&c=1&rs=1&qlt=70&r=0&o=7&pid=InlineBlock&rm=3',
      source: '地方法院簡易庭外觀與開庭公告（110年度訴字第178號...）',
    ),
    CaseImage(
      url:
          'https://tse4.mm.bing.net/th/id/OIP.BpIJPdGnK-nMpGs5B9306AHaFe?w=206&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '當事人提出之訴狀首頁抄本（110年度訴字第178號...）',
    ),
    CaseImage(
      url:
          'https://tse1.mm.bing.net/th/id/OIP.fEDFLQLHjS3QuE4bQLgBvQHaE8?w=229&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '司法裁判書電子檔之判決主文（110年度訴字第178號...）',
    ),
    CaseImage(
      url:
          'https://tse4.mm.bing.net/th/id/OIP.0SDoAANiAP6UoZPUrt3UqwHaEN?w=252&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '民事起訴狀與委任律師書狀（110年度訴字第178號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.WVO6tR5BzOgw0oglmH02OAHaEP?w=208&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '法院準備程序筆錄簽名欄位（110年度訴字第178號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.6_z7cGk1TU-RBgQM3tsqZQHaE8?w=221&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '司法院大法官憲法法庭開庭現場（110年度訴字第178號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.FxsIbUCjMd4IlOEskxShJgHaFj?w=89&h=89&c=1&rs=1&qlt=70&r=0&o=7&pid=InlineBlock&rm=3',
      source: '最高法院民事庭開庭大門外觀（110年度訴字第178號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.Xt1C-7meX374BAg86KC6LwHaE8?w=89&h=89&c=1&rs=1&qlt=70&r=0&o=7&pid=InlineBlock&rm=3',
      source: '法學文獻與期刊論文引用頁面（110年度訴字第178號...）',
    ),
    CaseImage(
      url:
          'https://tse1.mm.bing.net/th/id/OIP.xExaObj3A3nV3olc0K1gmwHaEJ?w=263&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '中華民國六法全書民法債編法條（110年度訴字第178號...）',
    ),
    CaseImage(
      url:
          'https://tse4.mm.bing.net/th/id/OIP.zbbKZ0Bh_CpP6eZamtCRjwHaE9?w=179&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '民事訴訟小額程序開庭流程圖（110年度訴字第178號...）',
    ),
    CaseImage(
      url:
          'https://tse4.mm.bing.net/th/id/OIP.FVJkOeXgZVSaQPF4GFSr2QHaD8?w=89&h=90&c=1&rs=1&qlt=70&r=0&o=7&pid=InlineBlock&rm=3',
      source: '判決確定證明書與執行憑證抄本（110年度訴字第178號...）',
    )
  ],
  'case-079': const [
    CaseImage(
      url:
          'https://tse3.mm.bing.net/th/id/OIP.8vGwbgtGBjFRl90_W32HlwHaE7?w=232&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '【本案卷宗封面照片】法庭審判司法天平現場照片',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.CR03_AAGv7DichRpWnF7NQHaE7?w=233&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '最高法院司法卷宗圖書館（109年度訴字第179號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.6_z7cGk1TU-RBgQM3tsqZQHaE8?w=221&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '法規沿革與憲法判決法典（109年度訴字第179號...）',
    ),
    CaseImage(
      url:
          'https://tse4.mm.bing.net/th/id/OIP.BpIJPdGnK-nMpGs5B9306AHaFe?w=206&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '本案訴訟卷宗外觀及編號（109年度訴字第179號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.wXoezXbxYh3d5XAsPQA1mwHaE8?w=193&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '地方法院簡易庭外觀與開庭公告（109年度訴字第179號...）',
    ),
    CaseImage(
      url:
          'https://tse4.mm.bing.net/th/id/OIP.zbbKZ0Bh_CpP6eZamtCRjwHaE9?w=179&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '當事人提出之訴狀首頁抄本（109年度訴字第179號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.Xt1C-7meX374BAg86KC6LwHaE8?w=89&h=89&c=1&rs=1&qlt=70&r=0&o=7&pid=InlineBlock&rm=3',
      source: '司法裁判書電子檔之判決主文（109年度訴字第179號...）',
    ),
    CaseImage(
      url:
          'https://tse3.mm.bing.net/th/id/OIP.RHmdPX6UGcKBDnAmC1DuxQHaE7?w=215&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '民事起訴狀與委任律師書狀（109年度訴字第179號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.WVO6tR5BzOgw0oglmH02OAHaEP?w=208&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '法院準備程序筆錄簽名欄位（109年度訴字第179號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.22mIh8FxQ1xTrLJEOF-vTgHaEO?w=89&h=89&c=1&rs=1&qlt=70&r=0&o=7&pid=InlineBlock&rm=3',
      source: '司法院大法官憲法法庭開庭現場（109年度訴字第179號...）',
    ),
    CaseImage(
      url:
          'https://tse4.mm.bing.net/th/id/OIP.0SDoAANiAP6UoZPUrt3UqwHaEN?w=252&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '最高法院民事庭開庭大門外觀（109年度訴字第179號...）',
    ),
    CaseImage(
      url:
          'https://tse1.mm.bing.net/th/id/OIP.kgAAgTi1mrNURfP1WvpUNQHaFj?w=89&h=90&c=1&rs=1&qlt=70&r=0&o=7&pid=InlineBlock&rm=3',
      source: '法學文獻與期刊論文引用頁面（109年度訴字第179號...）',
    ),
    CaseImage(
      url:
          'https://tse3.mm.bing.net/th/id/OIP.FzL2M5zkVz2nUbqZg7Qe-QHaE7?w=215&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '中華民國六法全書民法債編法條（109年度訴字第179號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.EQboFDqbqWRcR8PTOr3wQwHaDn?w=297&h=171&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '民事訴訟小額程序開庭流程圖（109年度訴字第179號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.jgOpaPncHSivavrOTSAXLgHaE8?w=232&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '判決確定證明書與執行憑證抄本（109年度訴字第179號...）',
    )
  ],
  'case-080': const [
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.jgOpaPncHSivavrOTSAXLgHaE8?w=232&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '【本案卷宗封面照片】法庭審判司法天平現場照片',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.wXoezXbxYh3d5XAsPQA1mwHaE8?w=193&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '最高法院司法卷宗圖書館（110年度訴字第180號...）',
    ),
    CaseImage(
      url:
          'https://tse3.mm.bing.net/th/id/OIP.8vGwbgtGBjFRl90_W32HlwHaE7?w=232&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '法規沿革與憲法判決法典（110年度訴字第180號...）',
    ),
    CaseImage(
      url:
          'https://tse4.mm.bing.net/th/id/OIP.0SDoAANiAP6UoZPUrt3UqwHaEN?w=252&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '本案訴訟卷宗外觀及編號（110年度訴字第180號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.22mIh8FxQ1xTrLJEOF-vTgHaEO?w=89&h=89&c=1&rs=1&qlt=70&r=0&o=7&pid=InlineBlock&rm=3',
      source: '地方法院簡易庭外觀與開庭公告（110年度訴字第180號...）',
    ),
    CaseImage(
      url:
          'https://tse3.mm.bing.net/th/id/OIP.FzL2M5zkVz2nUbqZg7Qe-QHaE7?w=215&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '當事人提出之訴狀首頁抄本（110年度訴字第180號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.Xt1C-7meX374BAg86KC6LwHaE8?w=89&h=89&c=1&rs=1&qlt=70&r=0&o=7&pid=InlineBlock&rm=3',
      source: '司法裁判書電子檔之判決主文（110年度訴字第180號...）',
    ),
    CaseImage(
      url:
          'https://tse1.mm.bing.net/th/id/OIP.xExaObj3A3nV3olc0K1gmwHaEJ?w=263&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '民事起訴狀與委任律師書狀（110年度訴字第180號...）',
    ),
    CaseImage(
      url:
          'https://tse1.mm.bing.net/th/id/OIP.fEDFLQLHjS3QuE4bQLgBvQHaE8?w=229&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '法院準備程序筆錄簽名欄位（110年度訴字第180號...）',
    ),
    CaseImage(
      url:
          'https://tse3.mm.bing.net/th/id/OIP.RHmdPX6UGcKBDnAmC1DuxQHaE7?w=215&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '司法院大法官憲法法庭開庭現場（110年度訴字第180號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.6_z7cGk1TU-RBgQM3tsqZQHaE8?w=221&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '最高法院民事庭開庭大門外觀（110年度訴字第180號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.EQboFDqbqWRcR8PTOr3wQwHaDn?w=297&h=171&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '法學文獻與期刊論文引用頁面（110年度訴字第180號...）',
    ),
    CaseImage(
      url:
          'https://tse4.mm.bing.net/th/id/OIP.BpIJPdGnK-nMpGs5B9306AHaFe?w=206&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '中華民國六法全書民法債編法條（110年度訴字第180號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.WVO6tR5BzOgw0oglmH02OAHaEP?w=208&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '民事訴訟小額程序開庭流程圖（110年度訴字第180號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.CR03_AAGv7DichRpWnF7NQHaE7?w=233&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '判決確定證明書與執行憑證抄本（110年度訴字第180號...）',
    )
  ],
  'case-081': const [
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.FxsIbUCjMd4IlOEskxShJgHaFj?w=89&h=89&c=1&rs=1&qlt=70&r=0&o=7&pid=InlineBlock&rm=3',
      source: '【本案卷宗封面照片】法庭審判司法天平現場照片',
    ),
    CaseImage(
      url:
          'https://tse4.mm.bing.net/th/id/OIP.0SDoAANiAP6UoZPUrt3UqwHaEN?w=252&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '最高法院司法卷宗圖書館（108年度訴字第181號...）',
    ),
    CaseImage(
      url:
          'https://tse4.mm.bing.net/th/id/OIP.Q7FEnIHkrd6q9Jmu1GiKkwHaEj?w=248&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '法規沿革與憲法判決法典（108年度訴字第181號...）',
    ),
    CaseImage(
      url:
          'https://tse4.mm.bing.net/th/id/OIP.zbbKZ0Bh_CpP6eZamtCRjwHaE9?w=179&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '本案訴訟卷宗外觀及編號（108年度訴字第181號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.jgOpaPncHSivavrOTSAXLgHaE8?w=232&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '地方法院簡易庭外觀與開庭公告（108年度訴字第181號...）',
    ),
    CaseImage(
      url:
          'https://tse3.mm.bing.net/th/id/OIP.rgvPoDUIQa-Gb56tJrl6sgHaEO?w=89&h=90&c=1&rs=1&qlt=70&r=0&o=7&pid=InlineBlock&rm=3',
      source: '當事人提出之訴狀首頁抄本（108年度訴字第181號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.22mIh8FxQ1xTrLJEOF-vTgHaEO?w=89&h=89&c=1&rs=1&qlt=70&r=0&o=7&pid=InlineBlock&rm=3',
      source: '司法裁判書電子檔之判決主文（108年度訴字第181號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.EQboFDqbqWRcR8PTOr3wQwHaDn?w=297&h=171&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '民事起訴狀與委任律師書狀（108年度訴字第181號...）',
    ),
    CaseImage(
      url:
          'https://tse1.mm.bing.net/th/id/OIP.kgAAgTi1mrNURfP1WvpUNQHaFj?w=89&h=90&c=1&rs=1&qlt=70&r=0&o=7&pid=InlineBlock&rm=3',
      source: '法院準備程序筆錄簽名欄位（108年度訴字第181號...）',
    ),
    CaseImage(
      url:
          'https://tse4.mm.bing.net/th/id/OIP.BpIJPdGnK-nMpGs5B9306AHaFe?w=206&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '司法院大法官憲法法庭開庭現場（108年度訴字第181號...）',
    ),
    CaseImage(
      url:
          'https://tse1.mm.bing.net/th/id/OIP.fEDFLQLHjS3QuE4bQLgBvQHaE8?w=229&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '最高法院民事庭開庭大門外觀（108年度訴字第181號...）',
    ),
    CaseImage(
      url:
          'https://tse3.mm.bing.net/th/id/OIP.FzL2M5zkVz2nUbqZg7Qe-QHaE7?w=215&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '法學文獻與期刊論文引用頁面（108年度訴字第181號...）',
    ),
    CaseImage(
      url:
          'https://tse4.mm.bing.net/th/id/OIP.FVJkOeXgZVSaQPF4GFSr2QHaD8?w=89&h=90&c=1&rs=1&qlt=70&r=0&o=7&pid=InlineBlock&rm=3',
      source: '中華民國六法全書民法債編法條（108年度訴字第181號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.CR03_AAGv7DichRpWnF7NQHaE7?w=233&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '民事訴訟小額程序開庭流程圖（108年度訴字第181號...）',
    ),
    CaseImage(
      url:
          'https://tse1.mm.bing.net/th/id/OIP.xExaObj3A3nV3olc0K1gmwHaEJ?w=263&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '判決確定證明書與執行憑證抄本（108年度訴字第181號...）',
    )
  ],
  'case-082': const [
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.6_z7cGk1TU-RBgQM3tsqZQHaE8?w=221&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '【本案卷宗封面照片】法庭審判司法天平現場照片',
    ),
    CaseImage(
      url:
          'https://tse4.mm.bing.net/th/id/OIP.0SDoAANiAP6UoZPUrt3UqwHaEN?w=252&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '最高法院司法卷宗圖書館（111年度訴字第182號...）',
    ),
    CaseImage(
      url:
          'https://tse3.mm.bing.net/th/id/OIP.RHmdPX6UGcKBDnAmC1DuxQHaE7?w=215&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '法規沿革與憲法判決法典（111年度訴字第182號...）',
    ),
    CaseImage(
      url:
          'https://tse1.mm.bing.net/th/id/OIP.xExaObj3A3nV3olc0K1gmwHaEJ?w=263&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '本案訴訟卷宗外觀及編號（111年度訴字第182號...）',
    ),
    CaseImage(
      url:
          'https://tse4.mm.bing.net/th/id/OIP.zbbKZ0Bh_CpP6eZamtCRjwHaE9?w=179&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '地方法院簡易庭外觀與開庭公告（111年度訴字第182號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.WVO6tR5BzOgw0oglmH02OAHaEP?w=208&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '當事人提出之訴狀首頁抄本（111年度訴字第182號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.22mIh8FxQ1xTrLJEOF-vTgHaEO?w=89&h=89&c=1&rs=1&qlt=70&r=0&o=7&pid=InlineBlock&rm=3',
      source: '司法裁判書電子檔之判決主文（111年度訴字第182號...）',
    ),
    CaseImage(
      url:
          'https://tse1.mm.bing.net/th/id/OIP.fEDFLQLHjS3QuE4bQLgBvQHaE8?w=229&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '民事起訴狀與委任律師書狀（111年度訴字第182號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.EQboFDqbqWRcR8PTOr3wQwHaDn?w=297&h=171&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '法院準備程序筆錄簽名欄位（111年度訴字第182號...）',
    ),
    CaseImage(
      url:
          'https://tse4.mm.bing.net/th/id/OIP.BpIJPdGnK-nMpGs5B9306AHaFe?w=206&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '司法院大法官憲法法庭開庭現場（111年度訴字第182號...）',
    ),
    CaseImage(
      url:
          'https://tse4.mm.bing.net/th/id/OIP.FVJkOeXgZVSaQPF4GFSr2QHaD8?w=89&h=90&c=1&rs=1&qlt=70&r=0&o=7&pid=InlineBlock&rm=3',
      source: '最高法院民事庭開庭大門外觀（111年度訴字第182號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.wXoezXbxYh3d5XAsPQA1mwHaE8?w=193&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '法學文獻與期刊論文引用頁面（111年度訴字第182號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.M1ZTFf8JShiFpHtxNdAuTwHaEz?w=227&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '中華民國六法全書民法債編法條（111年度訴字第182號...）',
    ),
    CaseImage(
      url:
          'https://tse4.mm.bing.net/th/id/OIP.Q7FEnIHkrd6q9Jmu1GiKkwHaEj?w=248&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '民事訴訟小額程序開庭流程圖（111年度訴字第182號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.Xt1C-7meX374BAg86KC6LwHaE8?w=89&h=89&c=1&rs=1&qlt=70&r=0&o=7&pid=InlineBlock&rm=3',
      source: '判決確定證明書與執行憑證抄本（111年度訴字第182號...）',
    )
  ],
  'case-083': const [
    CaseImage(
      url:
          'https://tse3.mm.bing.net/th/id/OIP.rgvPoDUIQa-Gb56tJrl6sgHaEO?w=89&h=90&c=1&rs=1&qlt=70&r=0&o=7&pid=InlineBlock&rm=3',
      source: '【本案卷宗封面照片】法庭審判司法天平現場照片',
    ),
    CaseImage(
      url:
          'https://tse1.mm.bing.net/th/id/OIP.kgAAgTi1mrNURfP1WvpUNQHaFj?w=89&h=90&c=1&rs=1&qlt=70&r=0&o=7&pid=InlineBlock&rm=3',
      source: '最高法院司法卷宗圖書館（109年度訴字第183號...）',
    ),
    CaseImage(
      url:
          'https://tse4.mm.bing.net/th/id/OIP.BpIJPdGnK-nMpGs5B9306AHaFe?w=206&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '法規沿革與憲法判決法典（109年度訴字第183號...）',
    ),
    CaseImage(
      url:
          'https://tse4.mm.bing.net/th/id/OIP.0SDoAANiAP6UoZPUrt3UqwHaEN?w=252&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '本案訴訟卷宗外觀及編號（109年度訴字第183號...）',
    ),
    CaseImage(
      url:
          'https://tse3.mm.bing.net/th/id/OIP.FzL2M5zkVz2nUbqZg7Qe-QHaE7?w=215&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '地方法院簡易庭外觀與開庭公告（109年度訴字第183號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.wXoezXbxYh3d5XAsPQA1mwHaE8?w=193&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '當事人提出之訴狀首頁抄本（109年度訴字第183號...）',
    ),
    CaseImage(
      url:
          'https://tse1.mm.bing.net/th/id/OIP.xExaObj3A3nV3olc0K1gmwHaEJ?w=263&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '司法裁判書電子檔之判決主文（109年度訴字第183號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.CR03_AAGv7DichRpWnF7NQHaE7?w=233&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '民事起訴狀與委任律師書狀（109年度訴字第183號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.22mIh8FxQ1xTrLJEOF-vTgHaEO?w=89&h=89&c=1&rs=1&qlt=70&r=0&o=7&pid=InlineBlock&rm=3',
      source: '法院準備程序筆錄簽名欄位（109年度訴字第183號...）',
    ),
    CaseImage(
      url:
          'https://tse4.mm.bing.net/th/id/OIP.Q7FEnIHkrd6q9Jmu1GiKkwHaEj?w=248&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '司法院大法官憲法法庭開庭現場（109年度訴字第183號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.jgOpaPncHSivavrOTSAXLgHaE8?w=232&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '最高法院民事庭開庭大門外觀（109年度訴字第183號...）',
    ),
    CaseImage(
      url:
          'https://tse3.mm.bing.net/th/id/OIP.8vGwbgtGBjFRl90_W32HlwHaE7?w=232&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '法學文獻與期刊論文引用頁面（109年度訴字第183號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.6_z7cGk1TU-RBgQM3tsqZQHaE8?w=221&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '中華民國六法全書民法債編法條（109年度訴字第183號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.EQboFDqbqWRcR8PTOr3wQwHaDn?w=297&h=171&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '民事訴訟小額程序開庭流程圖（109年度訴字第183號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.WVO6tR5BzOgw0oglmH02OAHaEP?w=208&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '判決確定證明書與執行憑證抄本（109年度訴字第183號...）',
    )
  ],
  'case-084': const [
    CaseImage(
      url:
          'https://tse4.mm.bing.net/th/id/OIP.zbbKZ0Bh_CpP6eZamtCRjwHaE9?w=179&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '【本案卷宗封面照片】法庭審判司法天平現場照片',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.Xt1C-7meX374BAg86KC6LwHaE8?w=89&h=89&c=1&rs=1&qlt=70&r=0&o=7&pid=InlineBlock&rm=3',
      source: '最高法院司法卷宗圖書館（110年度訴字第184號...）',
    ),
    CaseImage(
      url:
          'https://tse3.mm.bing.net/th/id/OIP.FzL2M5zkVz2nUbqZg7Qe-QHaE7?w=215&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '法規沿革與憲法判決法典（110年度訴字第184號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.M1ZTFf8JShiFpHtxNdAuTwHaEz?w=227&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '本案訴訟卷宗外觀及編號（110年度訴字第184號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.6_z7cGk1TU-RBgQM3tsqZQHaE8?w=221&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '地方法院簡易庭外觀與開庭公告（110年度訴字第184號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.jgOpaPncHSivavrOTSAXLgHaE8?w=232&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '當事人提出之訴狀首頁抄本（110年度訴字第184號...）',
    ),
    CaseImage(
      url:
          'https://tse4.mm.bing.net/th/id/OIP.FVJkOeXgZVSaQPF4GFSr2QHaD8?w=89&h=90&c=1&rs=1&qlt=70&r=0&o=7&pid=InlineBlock&rm=3',
      source: '司法裁判書電子檔之判決主文（110年度訴字第184號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.wXoezXbxYh3d5XAsPQA1mwHaE8?w=193&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '民事起訴狀與委任律師書狀（110年度訴字第184號...）',
    ),
    CaseImage(
      url:
          'https://tse1.mm.bing.net/th/id/OIP.fEDFLQLHjS3QuE4bQLgBvQHaE8?w=229&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '法院準備程序筆錄簽名欄位（110年度訴字第184號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.CR03_AAGv7DichRpWnF7NQHaE7?w=233&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '司法院大法官憲法法庭開庭現場（110年度訴字第184號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.WVO6tR5BzOgw0oglmH02OAHaEP?w=208&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '最高法院民事庭開庭大門外觀（110年度訴字第184號...）',
    ),
    CaseImage(
      url:
          'https://tse4.mm.bing.net/th/id/OIP.BpIJPdGnK-nMpGs5B9306AHaFe?w=206&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '法學文獻與期刊論文引用頁面（110年度訴字第184號...）',
    ),
    CaseImage(
      url:
          'https://tse1.mm.bing.net/th/id/OIP.xExaObj3A3nV3olc0K1gmwHaEJ?w=263&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '中華民國六法全書民法債編法條（110年度訴字第184號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.22mIh8FxQ1xTrLJEOF-vTgHaEO?w=89&h=89&c=1&rs=1&qlt=70&r=0&o=7&pid=InlineBlock&rm=3',
      source: '民事訴訟小額程序開庭流程圖（110年度訴字第184號...）',
    ),
    CaseImage(
      url:
          'https://tse4.mm.bing.net/th/id/OIP.0SDoAANiAP6UoZPUrt3UqwHaEN?w=252&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '判決確定證明書與執行憑證抄本（110年度訴字第184號...）',
    )
  ],
  'case-085': const [
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.wXoezXbxYh3d5XAsPQA1mwHaE8?w=193&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '【本案卷宗封面照片】法庭審判司法天平現場照片',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.22mIh8FxQ1xTrLJEOF-vTgHaEO?w=89&h=89&c=1&rs=1&qlt=70&r=0&o=7&pid=InlineBlock&rm=3',
      source: '最高法院司法卷宗圖書館（108年度訴字第185號...）',
    ),
    CaseImage(
      url:
          'https://tse4.mm.bing.net/th/id/OIP.BpIJPdGnK-nMpGs5B9306AHaFe?w=206&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '法規沿革與憲法判決法典（108年度訴字第185號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.EQboFDqbqWRcR8PTOr3wQwHaDn?w=297&h=171&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '本案訴訟卷宗外觀及編號（108年度訴字第185號...）',
    ),
    CaseImage(
      url:
          'https://tse4.mm.bing.net/th/id/OIP.Q7FEnIHkrd6q9Jmu1GiKkwHaEj?w=248&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '地方法院簡易庭外觀與開庭公告（108年度訴字第185號...）',
    ),
    CaseImage(
      url:
          'https://tse4.mm.bing.net/th/id/OIP.zbbKZ0Bh_CpP6eZamtCRjwHaE9?w=179&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '當事人提出之訴狀首頁抄本（108年度訴字第185號...）',
    ),
    CaseImage(
      url:
          'https://tse1.mm.bing.net/th/id/OIP.kgAAgTi1mrNURfP1WvpUNQHaFj?w=89&h=90&c=1&rs=1&qlt=70&r=0&o=7&pid=InlineBlock&rm=3',
      source: '司法裁判書電子檔之判決主文（108年度訴字第185號...）',
    ),
    CaseImage(
      url:
          'https://tse3.mm.bing.net/th/id/OIP.RHmdPX6UGcKBDnAmC1DuxQHaE7?w=215&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '民事起訴狀與委任律師書狀（108年度訴字第185號...）',
    ),
    CaseImage(
      url:
          'https://tse3.mm.bing.net/th/id/OIP.rgvPoDUIQa-Gb56tJrl6sgHaEO?w=89&h=90&c=1&rs=1&qlt=70&r=0&o=7&pid=InlineBlock&rm=3',
      source: '法院準備程序筆錄簽名欄位（108年度訴字第185號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.jgOpaPncHSivavrOTSAXLgHaE8?w=232&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '司法院大法官憲法法庭開庭現場（108年度訴字第185號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.WVO6tR5BzOgw0oglmH02OAHaEP?w=208&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '最高法院民事庭開庭大門外觀（108年度訴字第185號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.CR03_AAGv7DichRpWnF7NQHaE7?w=233&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '法學文獻與期刊論文引用頁面（108年度訴字第185號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.6_z7cGk1TU-RBgQM3tsqZQHaE8?w=221&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '中華民國六法全書民法債編法條（108年度訴字第185號...）',
    ),
    CaseImage(
      url:
          'https://tse1.mm.bing.net/th/id/OIP.fEDFLQLHjS3QuE4bQLgBvQHaE8?w=229&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '民事訴訟小額程序開庭流程圖（108年度訴字第185號...）',
    ),
    CaseImage(
      url:
          'https://tse3.mm.bing.net/th/id/OIP.8vGwbgtGBjFRl90_W32HlwHaE7?w=232&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '判決確定證明書與執行憑證抄本（108年度訴字第185號...）',
    )
  ],
  'case-086': const [
    CaseImage(
      url:
          'https://tse3.mm.bing.net/th/id/OIP.rgvPoDUIQa-Gb56tJrl6sgHaEO?w=89&h=90&c=1&rs=1&qlt=70&r=0&o=7&pid=InlineBlock&rm=3',
      source: '【本案卷宗封面照片】法庭審判司法天平現場照片',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.22mIh8FxQ1xTrLJEOF-vTgHaEO?w=89&h=89&c=1&rs=1&qlt=70&r=0&o=7&pid=InlineBlock&rm=3',
      source: '最高法院司法卷宗圖書館（111年度訴字第186號...）',
    ),
    CaseImage(
      url:
          'https://tse1.mm.bing.net/th/id/OIP.xExaObj3A3nV3olc0K1gmwHaEJ?w=263&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '法規沿革與憲法判決法典（111年度訴字第186號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.WVO6tR5BzOgw0oglmH02OAHaEP?w=208&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '本案訴訟卷宗外觀及編號（111年度訴字第186號...）',
    ),
    CaseImage(
      url:
          'https://tse4.mm.bing.net/th/id/OIP.BpIJPdGnK-nMpGs5B9306AHaFe?w=206&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '地方法院簡易庭外觀與開庭公告（111年度訴字第186號...）',
    ),
    CaseImage(
      url:
          'https://tse4.mm.bing.net/th/id/OIP.Q7FEnIHkrd6q9Jmu1GiKkwHaEj?w=248&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '當事人提出之訴狀首頁抄本（111年度訴字第186號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.M1ZTFf8JShiFpHtxNdAuTwHaEz?w=227&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '司法裁判書電子檔之判決主文（111年度訴字第186號...）',
    ),
    CaseImage(
      url:
          'https://tse3.mm.bing.net/th/id/OIP.8vGwbgtGBjFRl90_W32HlwHaE7?w=232&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '民事起訴狀與委任律師書狀（111年度訴字第186號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.EQboFDqbqWRcR8PTOr3wQwHaDn?w=297&h=171&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '法院準備程序筆錄簽名欄位（111年度訴字第186號...）',
    ),
    CaseImage(
      url:
          'https://tse3.mm.bing.net/th/id/OIP.FzL2M5zkVz2nUbqZg7Qe-QHaE7?w=215&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '司法院大法官憲法法庭開庭現場（111年度訴字第186號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.FxsIbUCjMd4IlOEskxShJgHaFj?w=89&h=89&c=1&rs=1&qlt=70&r=0&o=7&pid=InlineBlock&rm=3',
      source: '最高法院民事庭開庭大門外觀（111年度訴字第186號...）',
    ),
    CaseImage(
      url:
          'https://tse1.mm.bing.net/th/id/OIP.kgAAgTi1mrNURfP1WvpUNQHaFj?w=89&h=90&c=1&rs=1&qlt=70&r=0&o=7&pid=InlineBlock&rm=3',
      source: '法學文獻與期刊論文引用頁面（111年度訴字第186號...）',
    ),
    CaseImage(
      url:
          'https://tse4.mm.bing.net/th/id/OIP.0SDoAANiAP6UoZPUrt3UqwHaEN?w=252&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '中華民國六法全書民法債編法條（111年度訴字第186號...）',
    ),
    CaseImage(
      url:
          'https://tse4.mm.bing.net/th/id/OIP.zbbKZ0Bh_CpP6eZamtCRjwHaE9?w=179&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '民事訴訟小額程序開庭流程圖（111年度訴字第186號...）',
    ),
    CaseImage(
      url:
          'https://tse3.mm.bing.net/th/id/OIP.RHmdPX6UGcKBDnAmC1DuxQHaE7?w=215&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '判決確定證明書與執行憑證抄本（111年度訴字第186號...）',
    )
  ],
  'case-087': const [
    CaseImage(
      url:
          'https://tse4.mm.bing.net/th/id/OIP.FVJkOeXgZVSaQPF4GFSr2QHaD8?w=89&h=90&c=1&rs=1&qlt=70&r=0&o=7&pid=InlineBlock&rm=3',
      source: '【本案卷宗封面照片】法庭審判司法天平現場照片',
    ),
    CaseImage(
      url:
          'https://tse3.mm.bing.net/th/id/OIP.FzL2M5zkVz2nUbqZg7Qe-QHaE7?w=215&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '最高法院司法卷宗圖書館（109年度訴字第187號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.M1ZTFf8JShiFpHtxNdAuTwHaEz?w=227&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '法規沿革與憲法判決法典（109年度訴字第187號...）',
    ),
    CaseImage(
      url:
          'https://tse3.mm.bing.net/th/id/OIP.8vGwbgtGBjFRl90_W32HlwHaE7?w=232&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '本案訴訟卷宗外觀及編號（109年度訴字第187號...）',
    ),
    CaseImage(
      url:
          'https://tse1.mm.bing.net/th/id/OIP.fEDFLQLHjS3QuE4bQLgBvQHaE8?w=229&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '地方法院簡易庭外觀與開庭公告（109年度訴字第187號...）',
    ),
    CaseImage(
      url:
          'https://tse1.mm.bing.net/th/id/OIP.xExaObj3A3nV3olc0K1gmwHaEJ?w=263&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '當事人提出之訴狀首頁抄本（109年度訴字第187號...）',
    ),
    CaseImage(
      url:
          'https://tse4.mm.bing.net/th/id/OIP.Q7FEnIHkrd6q9Jmu1GiKkwHaEj?w=248&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '司法裁判書電子檔之判決主文（109年度訴字第187號...）',
    ),
    CaseImage(
      url:
          'https://tse4.mm.bing.net/th/id/OIP.0SDoAANiAP6UoZPUrt3UqwHaEN?w=252&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '民事起訴狀與委任律師書狀（109年度訴字第187號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.CR03_AAGv7DichRpWnF7NQHaE7?w=233&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '法院準備程序筆錄簽名欄位（109年度訴字第187號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.WVO6tR5BzOgw0oglmH02OAHaEP?w=208&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '司法院大法官憲法法庭開庭現場（109年度訴字第187號...）',
    ),
    CaseImage(
      url:
          'https://tse4.mm.bing.net/th/id/OIP.BpIJPdGnK-nMpGs5B9306AHaFe?w=206&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '最高法院民事庭開庭大門外觀（109年度訴字第187號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.Xt1C-7meX374BAg86KC6LwHaE8?w=89&h=89&c=1&rs=1&qlt=70&r=0&o=7&pid=InlineBlock&rm=3',
      source: '法學文獻與期刊論文引用頁面（109年度訴字第187號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.6_z7cGk1TU-RBgQM3tsqZQHaE8?w=221&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '中華民國六法全書民法債編法條（109年度訴字第187號...）',
    ),
    CaseImage(
      url:
          'https://tse1.mm.bing.net/th/id/OIP.kgAAgTi1mrNURfP1WvpUNQHaFj?w=89&h=90&c=1&rs=1&qlt=70&r=0&o=7&pid=InlineBlock&rm=3',
      source: '民事訴訟小額程序開庭流程圖（109年度訴字第187號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.EQboFDqbqWRcR8PTOr3wQwHaDn?w=297&h=171&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '判決確定證明書與執行憑證抄本（109年度訴字第187號...）',
    )
  ],
  'case-088': const [
    CaseImage(
      url:
          'https://tse3.mm.bing.net/th/id/OIP.RHmdPX6UGcKBDnAmC1DuxQHaE7?w=215&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '【本案卷宗封面照片】法庭審判司法天平現場照片',
    ),
    CaseImage(
      url:
          'https://tse4.mm.bing.net/th/id/OIP.Q7FEnIHkrd6q9Jmu1GiKkwHaEj?w=248&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '最高法院司法卷宗圖書館（108年度訴字第188號...）',
    ),
    CaseImage(
      url:
          'https://tse4.mm.bing.net/th/id/OIP.0SDoAANiAP6UoZPUrt3UqwHaEN?w=252&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '法規沿革與憲法判決法典（108年度訴字第188號...）',
    ),
    CaseImage(
      url:
          'https://tse1.mm.bing.net/th/id/OIP.fEDFLQLHjS3QuE4bQLgBvQHaE8?w=229&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '本案訴訟卷宗外觀及編號（108年度訴字第188號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.6_z7cGk1TU-RBgQM3tsqZQHaE8?w=221&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '地方法院簡易庭外觀與開庭公告（108年度訴字第188號...）',
    ),
    CaseImage(
      url:
          'https://tse1.mm.bing.net/th/id/OIP.xExaObj3A3nV3olc0K1gmwHaEJ?w=263&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '當事人提出之訴狀首頁抄本（108年度訴字第188號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.WVO6tR5BzOgw0oglmH02OAHaEP?w=208&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '司法裁判書電子檔之判決主文（108年度訴字第188號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.wXoezXbxYh3d5XAsPQA1mwHaE8?w=193&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '民事起訴狀與委任律師書狀（108年度訴字第188號...）',
    ),
    CaseImage(
      url:
          'https://tse4.mm.bing.net/th/id/OIP.FVJkOeXgZVSaQPF4GFSr2QHaD8?w=89&h=90&c=1&rs=1&qlt=70&r=0&o=7&pid=InlineBlock&rm=3',
      source: '法院準備程序筆錄簽名欄位（108年度訴字第188號...）',
    ),
    CaseImage(
      url:
          'https://tse3.mm.bing.net/th/id/OIP.8vGwbgtGBjFRl90_W32HlwHaE7?w=232&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '司法院大法官憲法法庭開庭現場（108年度訴字第188號...）',
    ),
    CaseImage(
      url:
          'https://tse4.mm.bing.net/th/id/OIP.BpIJPdGnK-nMpGs5B9306AHaFe?w=206&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '最高法院民事庭開庭大門外觀（108年度訴字第188號...）',
    ),
    CaseImage(
      url:
          'https://tse3.mm.bing.net/th/id/OIP.rgvPoDUIQa-Gb56tJrl6sgHaEO?w=89&h=90&c=1&rs=1&qlt=70&r=0&o=7&pid=InlineBlock&rm=3',
      source: '法學文獻與期刊論文引用頁面（108年度訴字第188號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.22mIh8FxQ1xTrLJEOF-vTgHaEO?w=89&h=89&c=1&rs=1&qlt=70&r=0&o=7&pid=InlineBlock&rm=3',
      source: '中華民國六法全書民法債編法條（108年度訴字第188號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.jgOpaPncHSivavrOTSAXLgHaE8?w=232&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '民事訴訟小額程序開庭流程圖（108年度訴字第188號...）',
    ),
    CaseImage(
      url:
          'https://tse1.mm.bing.net/th/id/OIP.kgAAgTi1mrNURfP1WvpUNQHaFj?w=89&h=90&c=1&rs=1&qlt=70&r=0&o=7&pid=InlineBlock&rm=3',
      source: '判決確定證明書與執行憑證抄本（108年度訴字第188號...）',
    )
  ],
  'case-089': const [
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.CR03_AAGv7DichRpWnF7NQHaE7?w=233&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '【本案卷宗封面照片】法庭審判司法天平現場照片',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.FxsIbUCjMd4IlOEskxShJgHaFj?w=89&h=89&c=1&rs=1&qlt=70&r=0&o=7&pid=InlineBlock&rm=3',
      source: '最高法院司法卷宗圖書館（110年度訴字第189號...）',
    ),
    CaseImage(
      url:
          'https://tse1.mm.bing.net/th/id/OIP.kgAAgTi1mrNURfP1WvpUNQHaFj?w=89&h=90&c=1&rs=1&qlt=70&r=0&o=7&pid=InlineBlock&rm=3',
      source: '法規沿革與憲法判決法典（110年度訴字第189號...）',
    ),
    CaseImage(
      url:
          'https://tse3.mm.bing.net/th/id/OIP.8vGwbgtGBjFRl90_W32HlwHaE7?w=232&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '本案訴訟卷宗外觀及編號（110年度訴字第189號...）',
    ),
    CaseImage(
      url:
          'https://tse3.mm.bing.net/th/id/OIP.RHmdPX6UGcKBDnAmC1DuxQHaE7?w=215&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '地方法院簡易庭外觀與開庭公告（110年度訴字第189號...）',
    ),
    CaseImage(
      url:
          'https://tse1.mm.bing.net/th/id/OIP.xExaObj3A3nV3olc0K1gmwHaEJ?w=263&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '當事人提出之訴狀首頁抄本（110年度訴字第189號...）',
    ),
    CaseImage(
      url:
          'https://tse3.mm.bing.net/th/id/OIP.rgvPoDUIQa-Gb56tJrl6sgHaEO?w=89&h=90&c=1&rs=1&qlt=70&r=0&o=7&pid=InlineBlock&rm=3',
      source: '司法裁判書電子檔之判決主文（110年度訴字第189號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.jgOpaPncHSivavrOTSAXLgHaE8?w=232&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '民事起訴狀與委任律師書狀（110年度訴字第189號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.6_z7cGk1TU-RBgQM3tsqZQHaE8?w=221&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '法院準備程序筆錄簽名欄位（110年度訴字第189號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.EQboFDqbqWRcR8PTOr3wQwHaDn?w=297&h=171&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '司法院大法官憲法法庭開庭現場（110年度訴字第189號...）',
    ),
    CaseImage(
      url:
          'https://tse4.mm.bing.net/th/id/OIP.BpIJPdGnK-nMpGs5B9306AHaFe?w=206&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '最高法院民事庭開庭大門外觀（110年度訴字第189號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.22mIh8FxQ1xTrLJEOF-vTgHaEO?w=89&h=89&c=1&rs=1&qlt=70&r=0&o=7&pid=InlineBlock&rm=3',
      source: '法學文獻與期刊論文引用頁面（110年度訴字第189號...）',
    ),
    CaseImage(
      url:
          'https://tse3.mm.bing.net/th/id/OIP.FzL2M5zkVz2nUbqZg7Qe-QHaE7?w=215&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '中華民國六法全書民法債編法條（110年度訴字第189號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.WVO6tR5BzOgw0oglmH02OAHaEP?w=208&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '民事訴訟小額程序開庭流程圖（110年度訴字第189號...）',
    ),
    CaseImage(
      url:
          'https://tse4.mm.bing.net/th/id/OIP.zbbKZ0Bh_CpP6eZamtCRjwHaE9?w=179&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '判決確定證明書與執行憑證抄本（110年度訴字第189號...）',
    )
  ],
  'case-090': const [
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.EQboFDqbqWRcR8PTOr3wQwHaDn?w=297&h=171&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '【本案卷宗封面照片】法庭審判司法天平現場照片',
    ),
    CaseImage(
      url:
          'https://tse4.mm.bing.net/th/id/OIP.BpIJPdGnK-nMpGs5B9306AHaFe?w=206&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '最高法院司法卷宗圖書館（110年度訴字第190號...）',
    ),
    CaseImage(
      url:
          'https://tse1.mm.bing.net/th/id/OIP.kgAAgTi1mrNURfP1WvpUNQHaFj?w=89&h=90&c=1&rs=1&qlt=70&r=0&o=7&pid=InlineBlock&rm=3',
      source: '法規沿革與憲法判決法典（110年度訴字第190號...）',
    ),
    CaseImage(
      url:
          'https://tse1.mm.bing.net/th/id/OIP.xExaObj3A3nV3olc0K1gmwHaEJ?w=263&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '本案訴訟卷宗外觀及編號（110年度訴字第190號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.wXoezXbxYh3d5XAsPQA1mwHaE8?w=193&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '地方法院簡易庭外觀與開庭公告（110年度訴字第190號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.WVO6tR5BzOgw0oglmH02OAHaEP?w=208&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '當事人提出之訴狀首頁抄本（110年度訴字第190號...）',
    ),
    CaseImage(
      url:
          'https://tse4.mm.bing.net/th/id/OIP.Q7FEnIHkrd6q9Jmu1GiKkwHaEj?w=248&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '司法裁判書電子檔之判決主文（110年度訴字第190號...）',
    ),
    CaseImage(
      url:
          'https://tse3.mm.bing.net/th/id/OIP.FzL2M5zkVz2nUbqZg7Qe-QHaE7?w=215&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '民事起訴狀與委任律師書狀（110年度訴字第190號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.6_z7cGk1TU-RBgQM3tsqZQHaE8?w=221&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '法院準備程序筆錄簽名欄位（110年度訴字第190號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.22mIh8FxQ1xTrLJEOF-vTgHaEO?w=89&h=89&c=1&rs=1&qlt=70&r=0&o=7&pid=InlineBlock&rm=3',
      source: '司法院大法官憲法法庭開庭現場（110年度訴字第190號...）',
    ),
    CaseImage(
      url:
          'https://tse3.mm.bing.net/th/id/OIP.rgvPoDUIQa-Gb56tJrl6sgHaEO?w=89&h=90&c=1&rs=1&qlt=70&r=0&o=7&pid=InlineBlock&rm=3',
      source: '最高法院民事庭開庭大門外觀（110年度訴字第190號...）',
    ),
    CaseImage(
      url:
          'https://tse1.mm.bing.net/th/id/OIP.fEDFLQLHjS3QuE4bQLgBvQHaE8?w=229&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '法學文獻與期刊論文引用頁面（110年度訴字第190號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.FxsIbUCjMd4IlOEskxShJgHaFj?w=89&h=89&c=1&rs=1&qlt=70&r=0&o=7&pid=InlineBlock&rm=3',
      source: '中華民國六法全書民法債編法條（110年度訴字第190號...）',
    ),
    CaseImage(
      url:
          'https://tse4.mm.bing.net/th/id/OIP.FVJkOeXgZVSaQPF4GFSr2QHaD8?w=89&h=90&c=1&rs=1&qlt=70&r=0&o=7&pid=InlineBlock&rm=3',
      source: '民事訴訟小額程序開庭流程圖（110年度訴字第190號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.jgOpaPncHSivavrOTSAXLgHaE8?w=232&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '判決確定證明書與執行憑證抄本（110年度訴字第190號...）',
    )
  ],
  'case-091': const [
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.WVO6tR5BzOgw0oglmH02OAHaEP?w=208&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '【本案卷宗封面照片】法庭審判司法天平現場照片',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.jgOpaPncHSivavrOTSAXLgHaE8?w=232&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '最高法院司法卷宗圖書館（109年度訴字第191號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.FxsIbUCjMd4IlOEskxShJgHaFj?w=89&h=89&c=1&rs=1&qlt=70&r=0&o=7&pid=InlineBlock&rm=3',
      source: '法規沿革與憲法判決法典（109年度訴字第191號...）',
    ),
    CaseImage(
      url:
          'https://tse3.mm.bing.net/th/id/OIP.8vGwbgtGBjFRl90_W32HlwHaE7?w=232&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '本案訴訟卷宗外觀及編號（109年度訴字第191號...）',
    ),
    CaseImage(
      url:
          'https://tse3.mm.bing.net/th/id/OIP.rgvPoDUIQa-Gb56tJrl6sgHaEO?w=89&h=90&c=1&rs=1&qlt=70&r=0&o=7&pid=InlineBlock&rm=3',
      source: '地方法院簡易庭外觀與開庭公告（109年度訴字第191號...）',
    ),
    CaseImage(
      url:
          'https://tse4.mm.bing.net/th/id/OIP.0SDoAANiAP6UoZPUrt3UqwHaEN?w=252&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '當事人提出之訴狀首頁抄本（109年度訴字第191號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.Xt1C-7meX374BAg86KC6LwHaE8?w=89&h=89&c=1&rs=1&qlt=70&r=0&o=7&pid=InlineBlock&rm=3',
      source: '司法裁判書電子檔之判決主文（109年度訴字第191號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.CR03_AAGv7DichRpWnF7NQHaE7?w=233&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '民事起訴狀與委任律師書狀（109年度訴字第191號...）',
    ),
    CaseImage(
      url:
          'https://tse4.mm.bing.net/th/id/OIP.Q7FEnIHkrd6q9Jmu1GiKkwHaEj?w=248&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '法院準備程序筆錄簽名欄位（109年度訴字第191號...）',
    ),
    CaseImage(
      url:
          'https://tse4.mm.bing.net/th/id/OIP.FVJkOeXgZVSaQPF4GFSr2QHaD8?w=89&h=90&c=1&rs=1&qlt=70&r=0&o=7&pid=InlineBlock&rm=3',
      source: '司法院大法官憲法法庭開庭現場（109年度訴字第191號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.wXoezXbxYh3d5XAsPQA1mwHaE8?w=193&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '最高法院民事庭開庭大門外觀（109年度訴字第191號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.6_z7cGk1TU-RBgQM3tsqZQHaE8?w=221&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '法學文獻與期刊論文引用頁面（109年度訴字第191號...）',
    ),
    CaseImage(
      url:
          'https://tse1.mm.bing.net/th/id/OIP.kgAAgTi1mrNURfP1WvpUNQHaFj?w=89&h=90&c=1&rs=1&qlt=70&r=0&o=7&pid=InlineBlock&rm=3',
      source: '中華民國六法全書民法債編法條（109年度訴字第191號...）',
    ),
    CaseImage(
      url:
          'https://tse4.mm.bing.net/th/id/OIP.zbbKZ0Bh_CpP6eZamtCRjwHaE9?w=179&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '民事訴訟小額程序開庭流程圖（109年度訴字第191號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.22mIh8FxQ1xTrLJEOF-vTgHaEO?w=89&h=89&c=1&rs=1&qlt=70&r=0&o=7&pid=InlineBlock&rm=3',
      source: '判決確定證明書與執行憑證抄本（109年度訴字第191號...）',
    )
  ],
  'case-092': const [
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.jgOpaPncHSivavrOTSAXLgHaE8?w=232&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '【本案卷宗封面照片】法庭審判司法天平現場照片',
    ),
    CaseImage(
      url:
          'https://tse1.mm.bing.net/th/id/OIP.fEDFLQLHjS3QuE4bQLgBvQHaE8?w=229&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '最高法院司法卷宗圖書館（107年度訴字第192號...）',
    ),
    CaseImage(
      url:
          'https://tse3.mm.bing.net/th/id/OIP.FzL2M5zkVz2nUbqZg7Qe-QHaE7?w=215&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '法規沿革與憲法判決法典（107年度訴字第192號...）',
    ),
    CaseImage(
      url:
          'https://tse4.mm.bing.net/th/id/OIP.zbbKZ0Bh_CpP6eZamtCRjwHaE9?w=179&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '本案訴訟卷宗外觀及編號（107年度訴字第192號...）',
    ),
    CaseImage(
      url:
          'https://tse4.mm.bing.net/th/id/OIP.0SDoAANiAP6UoZPUrt3UqwHaEN?w=252&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '地方法院簡易庭外觀與開庭公告（107年度訴字第192號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.wXoezXbxYh3d5XAsPQA1mwHaE8?w=193&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '當事人提出之訴狀首頁抄本（107年度訴字第192號...）',
    ),
    CaseImage(
      url:
          'https://tse1.mm.bing.net/th/id/OIP.xExaObj3A3nV3olc0K1gmwHaEJ?w=263&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '司法裁判書電子檔之判決主文（107年度訴字第192號...）',
    ),
    CaseImage(
      url:
          'https://tse1.mm.bing.net/th/id/OIP.kgAAgTi1mrNURfP1WvpUNQHaFj?w=89&h=90&c=1&rs=1&qlt=70&r=0&o=7&pid=InlineBlock&rm=3',
      source: '民事起訴狀與委任律師書狀（107年度訴字第192號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.Xt1C-7meX374BAg86KC6LwHaE8?w=89&h=89&c=1&rs=1&qlt=70&r=0&o=7&pid=InlineBlock&rm=3',
      source: '法院準備程序筆錄簽名欄位（107年度訴字第192號...）',
    ),
    CaseImage(
      url:
          'https://tse4.mm.bing.net/th/id/OIP.BpIJPdGnK-nMpGs5B9306AHaFe?w=206&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '司法院大法官憲法法庭開庭現場（107年度訴字第192號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.CR03_AAGv7DichRpWnF7NQHaE7?w=233&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '最高法院民事庭開庭大門外觀（107年度訴字第192號...）',
    ),
    CaseImage(
      url:
          'https://tse3.mm.bing.net/th/id/OIP.RHmdPX6UGcKBDnAmC1DuxQHaE7?w=215&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '法學文獻與期刊論文引用頁面（107年度訴字第192號...）',
    ),
    CaseImage(
      url:
          'https://tse3.mm.bing.net/th/id/OIP.rgvPoDUIQa-Gb56tJrl6sgHaEO?w=89&h=90&c=1&rs=1&qlt=70&r=0&o=7&pid=InlineBlock&rm=3',
      source: '中華民國六法全書民法債編法條（107年度訴字第192號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.EQboFDqbqWRcR8PTOr3wQwHaDn?w=297&h=171&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '民事訴訟小額程序開庭流程圖（107年度訴字第192號...）',
    ),
    CaseImage(
      url:
          'https://tse3.mm.bing.net/th/id/OIP.8vGwbgtGBjFRl90_W32HlwHaE7?w=232&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '判決確定證明書與執行憑證抄本（107年度訴字第192號...）',
    )
  ],
  'case-093': const [
    CaseImage(
      url:
          'https://tse1.mm.bing.net/th/id/OIP.xExaObj3A3nV3olc0K1gmwHaEJ?w=263&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '【本案卷宗封面照片】法庭審判司法天平現場照片',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.EQboFDqbqWRcR8PTOr3wQwHaDn?w=297&h=171&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '最高法院司法卷宗圖書館（101年度訴字第193號...）',
    ),
    CaseImage(
      url:
          'https://tse4.mm.bing.net/th/id/OIP.zbbKZ0Bh_CpP6eZamtCRjwHaE9?w=179&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '法規沿革與憲法判決法典（101年度訴字第193號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.WVO6tR5BzOgw0oglmH02OAHaEP?w=208&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '本案訴訟卷宗外觀及編號（101年度訴字第193號...）',
    ),
    CaseImage(
      url:
          'https://tse3.mm.bing.net/th/id/OIP.FzL2M5zkVz2nUbqZg7Qe-QHaE7?w=215&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '地方法院簡易庭外觀與開庭公告（101年度訴字第193號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.wXoezXbxYh3d5XAsPQA1mwHaE8?w=193&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '當事人提出之訴狀首頁抄本（101年度訴字第193號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.Xt1C-7meX374BAg86KC6LwHaE8?w=89&h=89&c=1&rs=1&qlt=70&r=0&o=7&pid=InlineBlock&rm=3',
      source: '司法裁判書電子檔之判決主文（101年度訴字第193號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.6_z7cGk1TU-RBgQM3tsqZQHaE8?w=221&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '民事起訴狀與委任律師書狀（101年度訴字第193號...）',
    ),
    CaseImage(
      url:
          'https://tse3.mm.bing.net/th/id/OIP.8vGwbgtGBjFRl90_W32HlwHaE7?w=232&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '法院準備程序筆錄簽名欄位（101年度訴字第193號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.FxsIbUCjMd4IlOEskxShJgHaFj?w=89&h=89&c=1&rs=1&qlt=70&r=0&o=7&pid=InlineBlock&rm=3',
      source: '司法院大法官憲法法庭開庭現場（101年度訴字第193號...）',
    ),
    CaseImage(
      url:
          'https://tse4.mm.bing.net/th/id/OIP.Q7FEnIHkrd6q9Jmu1GiKkwHaEj?w=248&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '最高法院民事庭開庭大門外觀（101年度訴字第193號...）',
    ),
    CaseImage(
      url:
          'https://tse4.mm.bing.net/th/id/OIP.FVJkOeXgZVSaQPF4GFSr2QHaD8?w=89&h=90&c=1&rs=1&qlt=70&r=0&o=7&pid=InlineBlock&rm=3',
      source: '法學文獻與期刊論文引用頁面（101年度訴字第193號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.22mIh8FxQ1xTrLJEOF-vTgHaEO?w=89&h=89&c=1&rs=1&qlt=70&r=0&o=7&pid=InlineBlock&rm=3',
      source: '中華民國六法全書民法債編法條（101年度訴字第193號...）',
    ),
    CaseImage(
      url:
          'https://tse1.mm.bing.net/th/id/OIP.fEDFLQLHjS3QuE4bQLgBvQHaE8?w=229&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '民事訴訟小額程序開庭流程圖（101年度訴字第193號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.jgOpaPncHSivavrOTSAXLgHaE8?w=232&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '判決確定證明書與執行憑證抄本（101年度訴字第193號...）',
    )
  ],
  'case-094': const [
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.WVO6tR5BzOgw0oglmH02OAHaEP?w=208&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '【本案卷宗封面照片】法庭審判司法天平現場照片',
    ),
    CaseImage(
      url:
          'https://tse3.mm.bing.net/th/id/OIP.rgvPoDUIQa-Gb56tJrl6sgHaEO?w=89&h=90&c=1&rs=1&qlt=70&r=0&o=7&pid=InlineBlock&rm=3',
      source: '最高法院司法卷宗圖書館（100年度訴字第194號...）',
    ),
    CaseImage(
      url:
          'https://tse1.mm.bing.net/th/id/OIP.fEDFLQLHjS3QuE4bQLgBvQHaE8?w=229&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '法規沿革與憲法判決法典（100年度訴字第194號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.M1ZTFf8JShiFpHtxNdAuTwHaEz?w=227&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '本案訴訟卷宗外觀及編號（100年度訴字第194號...）',
    ),
    CaseImage(
      url:
          'https://tse3.mm.bing.net/th/id/OIP.FzL2M5zkVz2nUbqZg7Qe-QHaE7?w=215&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '地方法院簡易庭外觀與開庭公告（100年度訴字第194號...）',
    ),
    CaseImage(
      url:
          'https://tse1.mm.bing.net/th/id/OIP.kgAAgTi1mrNURfP1WvpUNQHaFj?w=89&h=90&c=1&rs=1&qlt=70&r=0&o=7&pid=InlineBlock&rm=3',
      source: '當事人提出之訴狀首頁抄本（100年度訴字第194號...）',
    ),
    CaseImage(
      url:
          'https://tse3.mm.bing.net/th/id/OIP.RHmdPX6UGcKBDnAmC1DuxQHaE7?w=215&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '司法裁判書電子檔之判決主文（100年度訴字第194號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.jgOpaPncHSivavrOTSAXLgHaE8?w=232&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '民事起訴狀與委任律師書狀（100年度訴字第194號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.22mIh8FxQ1xTrLJEOF-vTgHaEO?w=89&h=89&c=1&rs=1&qlt=70&r=0&o=7&pid=InlineBlock&rm=3',
      source: '法院準備程序筆錄簽名欄位（100年度訴字第194號...）',
    ),
    CaseImage(
      url:
          'https://tse4.mm.bing.net/th/id/OIP.BpIJPdGnK-nMpGs5B9306AHaFe?w=206&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '司法院大法官憲法法庭開庭現場（100年度訴字第194號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.6_z7cGk1TU-RBgQM3tsqZQHaE8?w=221&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '最高法院民事庭開庭大門外觀（100年度訴字第194號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.Xt1C-7meX374BAg86KC6LwHaE8?w=89&h=89&c=1&rs=1&qlt=70&r=0&o=7&pid=InlineBlock&rm=3',
      source: '法學文獻與期刊論文引用頁面（100年度訴字第194號...）',
    ),
    CaseImage(
      url:
          'https://tse4.mm.bing.net/th/id/OIP.Q7FEnIHkrd6q9Jmu1GiKkwHaEj?w=248&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '中華民國六法全書民法債編法條（100年度訴字第194號...）',
    ),
    CaseImage(
      url:
          'https://tse1.mm.bing.net/th/id/OIP.xExaObj3A3nV3olc0K1gmwHaEJ?w=263&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '民事訴訟小額程序開庭流程圖（100年度訴字第194號...）',
    ),
    CaseImage(
      url:
          'https://tse4.mm.bing.net/th/id/OIP.0SDoAANiAP6UoZPUrt3UqwHaEN?w=252&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '判決確定證明書與執行憑證抄本（100年度訴字第194號...）',
    )
  ],
  'case-095': const [
    CaseImage(
      url:
          'https://tse4.mm.bing.net/th/id/OIP.zbbKZ0Bh_CpP6eZamtCRjwHaE9?w=179&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '【本案卷宗封面照片】法庭審判司法天平現場照片',
    ),
    CaseImage(
      url:
          'https://tse3.mm.bing.net/th/id/OIP.8vGwbgtGBjFRl90_W32HlwHaE7?w=232&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '最高法院司法卷宗圖書館（102年度訴字第195號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.wXoezXbxYh3d5XAsPQA1mwHaE8?w=193&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '法規沿革與憲法判決法典（102年度訴字第195號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.Xt1C-7meX374BAg86KC6LwHaE8?w=89&h=89&c=1&rs=1&qlt=70&r=0&o=7&pid=InlineBlock&rm=3',
      source: '本案訴訟卷宗外觀及編號（102年度訴字第195號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.22mIh8FxQ1xTrLJEOF-vTgHaEO?w=89&h=89&c=1&rs=1&qlt=70&r=0&o=7&pid=InlineBlock&rm=3',
      source: '地方法院簡易庭外觀與開庭公告（102年度訴字第195號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.EQboFDqbqWRcR8PTOr3wQwHaDn?w=297&h=171&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '當事人提出之訴狀首頁抄本（102年度訴字第195號...）',
    ),
    CaseImage(
      url:
          'https://tse4.mm.bing.net/th/id/OIP.BpIJPdGnK-nMpGs5B9306AHaFe?w=206&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '司法裁判書電子檔之判決主文（102年度訴字第195號...）',
    ),
    CaseImage(
      url:
          'https://tse4.mm.bing.net/th/id/OIP.Q7FEnIHkrd6q9Jmu1GiKkwHaEj?w=248&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '民事起訴狀與委任律師書狀（102年度訴字第195號...）',
    ),
    CaseImage(
      url:
          'https://tse1.mm.bing.net/th/id/OIP.kgAAgTi1mrNURfP1WvpUNQHaFj?w=89&h=90&c=1&rs=1&qlt=70&r=0&o=7&pid=InlineBlock&rm=3',
      source: '法院準備程序筆錄簽名欄位（102年度訴字第195號...）',
    ),
    CaseImage(
      url:
          'https://tse4.mm.bing.net/th/id/OIP.FVJkOeXgZVSaQPF4GFSr2QHaD8?w=89&h=90&c=1&rs=1&qlt=70&r=0&o=7&pid=InlineBlock&rm=3',
      source: '司法院大法官憲法法庭開庭現場（102年度訴字第195號...）',
    ),
    CaseImage(
      url:
          'https://tse1.mm.bing.net/th/id/OIP.fEDFLQLHjS3QuE4bQLgBvQHaE8?w=229&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '最高法院民事庭開庭大門外觀（102年度訴字第195號...）',
    ),
    CaseImage(
      url:
          'https://tse1.mm.bing.net/th/id/OIP.xExaObj3A3nV3olc0K1gmwHaEJ?w=263&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '法學文獻與期刊論文引用頁面（102年度訴字第195號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.FxsIbUCjMd4IlOEskxShJgHaFj?w=89&h=89&c=1&rs=1&qlt=70&r=0&o=7&pid=InlineBlock&rm=3',
      source: '中華民國六法全書民法債編法條（102年度訴字第195號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.CR03_AAGv7DichRpWnF7NQHaE7?w=233&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '民事訴訟小額程序開庭流程圖（102年度訴字第195號...）',
    ),
    CaseImage(
      url:
          'https://tse3.mm.bing.net/th/id/OIP.FzL2M5zkVz2nUbqZg7Qe-QHaE7?w=215&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '判決確定證明書與執行憑證抄本（102年度訴字第195號...）',
    )
  ],
  'case-096': const [
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.wXoezXbxYh3d5XAsPQA1mwHaE8?w=193&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '【本案卷宗封面照片】法庭審判司法天平現場照片',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.CR03_AAGv7DichRpWnF7NQHaE7?w=233&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '最高法院司法卷宗圖書館（104年度訴字第196號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.6_z7cGk1TU-RBgQM3tsqZQHaE8?w=221&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '法規沿革與憲法判決法典（104年度訴字第196號...）',
    ),
    CaseImage(
      url:
          'https://tse3.mm.bing.net/th/id/OIP.RHmdPX6UGcKBDnAmC1DuxQHaE7?w=215&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '本案訴訟卷宗外觀及編號（104年度訴字第196號...）',
    ),
    CaseImage(
      url:
          'https://tse1.mm.bing.net/th/id/OIP.kgAAgTi1mrNURfP1WvpUNQHaFj?w=89&h=90&c=1&rs=1&qlt=70&r=0&o=7&pid=InlineBlock&rm=3',
      source: '地方法院簡易庭外觀與開庭公告（104年度訴字第196號...）',
    ),
    CaseImage(
      url:
          'https://tse3.mm.bing.net/th/id/OIP.rgvPoDUIQa-Gb56tJrl6sgHaEO?w=89&h=90&c=1&rs=1&qlt=70&r=0&o=7&pid=InlineBlock&rm=3',
      source: '當事人提出之訴狀首頁抄本（104年度訴字第196號...）',
    ),
    CaseImage(
      url:
          'https://tse4.mm.bing.net/th/id/OIP.FVJkOeXgZVSaQPF4GFSr2QHaD8?w=89&h=90&c=1&rs=1&qlt=70&r=0&o=7&pid=InlineBlock&rm=3',
      source: '司法裁判書電子檔之判決主文（104年度訴字第196號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.22mIh8FxQ1xTrLJEOF-vTgHaEO?w=89&h=89&c=1&rs=1&qlt=70&r=0&o=7&pid=InlineBlock&rm=3',
      source: '民事起訴狀與委任律師書狀（104年度訴字第196號...）',
    ),
    CaseImage(
      url:
          'https://tse3.mm.bing.net/th/id/OIP.8vGwbgtGBjFRl90_W32HlwHaE7?w=232&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '法院準備程序筆錄簽名欄位（104年度訴字第196號...）',
    ),
    CaseImage(
      url:
          'https://tse1.mm.bing.net/th/id/OIP.xExaObj3A3nV3olc0K1gmwHaEJ?w=263&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '司法院大法官憲法法庭開庭現場（104年度訴字第196號...）',
    ),
    CaseImage(
      url:
          'https://tse4.mm.bing.net/th/id/OIP.zbbKZ0Bh_CpP6eZamtCRjwHaE9?w=179&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '最高法院民事庭開庭大門外觀（104年度訴字第196號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.EQboFDqbqWRcR8PTOr3wQwHaDn?w=297&h=171&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '法學文獻與期刊論文引用頁面（104年度訴字第196號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.FxsIbUCjMd4IlOEskxShJgHaFj?w=89&h=89&c=1&rs=1&qlt=70&r=0&o=7&pid=InlineBlock&rm=3',
      source: '中華民國六法全書民法債編法條（104年度訴字第196號...）',
    ),
    CaseImage(
      url:
          'https://tse3.mm.bing.net/th/id/OIP.FzL2M5zkVz2nUbqZg7Qe-QHaE7?w=215&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '民事訴訟小額程序開庭流程圖（104年度訴字第196號...）',
    ),
    CaseImage(
      url:
          'https://tse4.mm.bing.net/th/id/OIP.0SDoAANiAP6UoZPUrt3UqwHaEN?w=252&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '判決確定證明書與執行憑證抄本（104年度訴字第196號...）',
    )
  ],
  'case-097': const [
    CaseImage(
      url:
          'https://tse4.mm.bing.net/th/id/OIP.BpIJPdGnK-nMpGs5B9306AHaFe?w=206&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '【本案卷宗封面照片】法庭審判司法天平現場照片',
    ),
    CaseImage(
      url:
          'https://tse3.mm.bing.net/th/id/OIP.RHmdPX6UGcKBDnAmC1DuxQHaE7?w=215&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '最高法院司法卷宗圖書館（105年度訴字第197號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.wXoezXbxYh3d5XAsPQA1mwHaE8?w=193&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '法規沿革與憲法判決法典（105年度訴字第197號...）',
    ),
    CaseImage(
      url:
          'https://tse3.mm.bing.net/th/id/OIP.FzL2M5zkVz2nUbqZg7Qe-QHaE7?w=215&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '本案訴訟卷宗外觀及編號（105年度訴字第197號...）',
    ),
    CaseImage(
      url:
          'https://tse3.mm.bing.net/th/id/OIP.8vGwbgtGBjFRl90_W32HlwHaE7?w=232&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '地方法院簡易庭外觀與開庭公告（105年度訴字第197號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.FxsIbUCjMd4IlOEskxShJgHaFj?w=89&h=89&c=1&rs=1&qlt=70&r=0&o=7&pid=InlineBlock&rm=3',
      source: '當事人提出之訴狀首頁抄本（105年度訴字第197號...）',
    ),
    CaseImage(
      url:
          'https://tse4.mm.bing.net/th/id/OIP.FVJkOeXgZVSaQPF4GFSr2QHaD8?w=89&h=90&c=1&rs=1&qlt=70&r=0&o=7&pid=InlineBlock&rm=3',
      source: '司法裁判書電子檔之判決主文（105年度訴字第197號...）',
    ),
    CaseImage(
      url:
          'https://tse1.mm.bing.net/th/id/OIP.kgAAgTi1mrNURfP1WvpUNQHaFj?w=89&h=90&c=1&rs=1&qlt=70&r=0&o=7&pid=InlineBlock&rm=3',
      source: '民事起訴狀與委任律師書狀（105年度訴字第197號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.22mIh8FxQ1xTrLJEOF-vTgHaEO?w=89&h=89&c=1&rs=1&qlt=70&r=0&o=7&pid=InlineBlock&rm=3',
      source: '法院準備程序筆錄簽名欄位（105年度訴字第197號...）',
    ),
    CaseImage(
      url:
          'https://tse1.mm.bing.net/th/id/OIP.xExaObj3A3nV3olc0K1gmwHaEJ?w=263&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '司法院大法官憲法法庭開庭現場（105年度訴字第197號...）',
    ),
    CaseImage(
      url:
          'https://tse4.mm.bing.net/th/id/OIP.0SDoAANiAP6UoZPUrt3UqwHaEN?w=252&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '最高法院民事庭開庭大門外觀（105年度訴字第197號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.WVO6tR5BzOgw0oglmH02OAHaEP?w=208&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '法學文獻與期刊論文引用頁面（105年度訴字第197號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.6_z7cGk1TU-RBgQM3tsqZQHaE8?w=221&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '中華民國六法全書民法債編法條（105年度訴字第197號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.M1ZTFf8JShiFpHtxNdAuTwHaEz?w=227&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '民事訴訟小額程序開庭流程圖（105年度訴字第197號...）',
    ),
    CaseImage(
      url:
          'https://tse4.mm.bing.net/th/id/OIP.zbbKZ0Bh_CpP6eZamtCRjwHaE9?w=179&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '判決確定證明書與執行憑證抄本（105年度訴字第197號...）',
    )
  ],
  'case-098': const [
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.WVO6tR5BzOgw0oglmH02OAHaEP?w=208&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '【本案卷宗封面照片】法庭審判司法天平現場照片',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.22mIh8FxQ1xTrLJEOF-vTgHaEO?w=89&h=89&c=1&rs=1&qlt=70&r=0&o=7&pid=InlineBlock&rm=3',
      source: '最高法院司法卷宗圖書館（109年度訴字第198號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.M1ZTFf8JShiFpHtxNdAuTwHaEz?w=227&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '法規沿革與憲法判決法典（109年度訴字第198號...）',
    ),
    CaseImage(
      url:
          'https://tse3.mm.bing.net/th/id/OIP.FzL2M5zkVz2nUbqZg7Qe-QHaE7?w=215&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '本案訴訟卷宗外觀及編號（109年度訴字第198號...）',
    ),
    CaseImage(
      url:
          'https://tse3.mm.bing.net/th/id/OIP.rgvPoDUIQa-Gb56tJrl6sgHaEO?w=89&h=90&c=1&rs=1&qlt=70&r=0&o=7&pid=InlineBlock&rm=3',
      source: '地方法院簡易庭外觀與開庭公告（109年度訴字第198號...）',
    ),
    CaseImage(
      url:
          'https://tse3.mm.bing.net/th/id/OIP.8vGwbgtGBjFRl90_W32HlwHaE7?w=232&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '當事人提出之訴狀首頁抄本（109年度訴字第198號...）',
    ),
    CaseImage(
      url:
          'https://tse4.mm.bing.net/th/id/OIP.Q7FEnIHkrd6q9Jmu1GiKkwHaEj?w=248&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '司法裁判書電子檔之判決主文（109年度訴字第198號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.6_z7cGk1TU-RBgQM3tsqZQHaE8?w=221&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '民事起訴狀與委任律師書狀（109年度訴字第198號...）',
    ),
    CaseImage(
      url:
          'https://tse1.mm.bing.net/th/id/OIP.xExaObj3A3nV3olc0K1gmwHaEJ?w=263&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '法院準備程序筆錄簽名欄位（109年度訴字第198號...）',
    ),
    CaseImage(
      url:
          'https://tse4.mm.bing.net/th/id/OIP.0SDoAANiAP6UoZPUrt3UqwHaEN?w=252&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '司法院大法官憲法法庭開庭現場（109年度訴字第198號...）',
    ),
    CaseImage(
      url:
          'https://tse1.mm.bing.net/th/id/OIP.kgAAgTi1mrNURfP1WvpUNQHaFj?w=89&h=90&c=1&rs=1&qlt=70&r=0&o=7&pid=InlineBlock&rm=3',
      source: '最高法院民事庭開庭大門外觀（109年度訴字第198號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.EQboFDqbqWRcR8PTOr3wQwHaDn?w=297&h=171&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '法學文獻與期刊論文引用頁面（109年度訴字第198號...）',
    ),
    CaseImage(
      url:
          'https://tse4.mm.bing.net/th/id/OIP.FVJkOeXgZVSaQPF4GFSr2QHaD8?w=89&h=90&c=1&rs=1&qlt=70&r=0&o=7&pid=InlineBlock&rm=3',
      source: '中華民國六法全書民法債編法條（109年度訴字第198號...）',
    ),
    CaseImage(
      url:
          'https://tse1.mm.bing.net/th/id/OIP.fEDFLQLHjS3QuE4bQLgBvQHaE8?w=229&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '民事訴訟小額程序開庭流程圖（109年度訴字第198號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.Xt1C-7meX374BAg86KC6LwHaE8?w=89&h=89&c=1&rs=1&qlt=70&r=0&o=7&pid=InlineBlock&rm=3',
      source: '判決確定證明書與執行憑證抄本（109年度訴字第198號...）',
    )
  ],
  'case-099': const [
    CaseImage(
      url:
          'https://tse4.mm.bing.net/th/id/OIP.FVJkOeXgZVSaQPF4GFSr2QHaD8?w=89&h=90&c=1&rs=1&qlt=70&r=0&o=7&pid=InlineBlock&rm=3',
      source: '【本案卷宗封面照片】法庭審判司法天平現場照片',
    ),
    CaseImage(
      url:
          'https://tse4.mm.bing.net/th/id/OIP.0SDoAANiAP6UoZPUrt3UqwHaEN?w=252&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '最高法院司法卷宗圖書館（103年度訴字第199號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.CR03_AAGv7DichRpWnF7NQHaE7?w=233&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '法規沿革與憲法判決法典（103年度訴字第199號...）',
    ),
    CaseImage(
      url:
          'https://tse1.mm.bing.net/th/id/OIP.fEDFLQLHjS3QuE4bQLgBvQHaE8?w=229&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '本案訴訟卷宗外觀及編號（103年度訴字第199號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.6_z7cGk1TU-RBgQM3tsqZQHaE8?w=221&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '地方法院簡易庭外觀與開庭公告（103年度訴字第199號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.22mIh8FxQ1xTrLJEOF-vTgHaEO?w=89&h=89&c=1&rs=1&qlt=70&r=0&o=7&pid=InlineBlock&rm=3',
      source: '當事人提出之訴狀首頁抄本（103年度訴字第199號...）',
    ),
    CaseImage(
      url:
          'https://tse4.mm.bing.net/th/id/OIP.zbbKZ0Bh_CpP6eZamtCRjwHaE9?w=179&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '司法裁判書電子檔之判決主文（103年度訴字第199號...）',
    ),
    CaseImage(
      url:
          'https://tse3.mm.bing.net/th/id/OIP.8vGwbgtGBjFRl90_W32HlwHaE7?w=232&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '民事起訴狀與委任律師書狀（103年度訴字第199號...）',
    ),
    CaseImage(
      url:
          'https://tse4.mm.bing.net/th/id/OIP.Q7FEnIHkrd6q9Jmu1GiKkwHaEj?w=248&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '法院準備程序筆錄簽名欄位（103年度訴字第199號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.wXoezXbxYh3d5XAsPQA1mwHaE8?w=193&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '司法院大法官憲法法庭開庭現場（103年度訴字第199號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.EQboFDqbqWRcR8PTOr3wQwHaDn?w=297&h=171&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '最高法院民事庭開庭大門外觀（103年度訴字第199號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.WVO6tR5BzOgw0oglmH02OAHaEP?w=208&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '法學文獻與期刊論文引用頁面（103年度訴字第199號...）',
    ),
    CaseImage(
      url:
          'https://tse1.mm.bing.net/th/id/OIP.xExaObj3A3nV3olc0K1gmwHaEJ?w=263&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '中華民國六法全書民法債編法條（103年度訴字第199號...）',
    ),
    CaseImage(
      url:
          'https://tse3.mm.bing.net/th/id/OIP.RHmdPX6UGcKBDnAmC1DuxQHaE7?w=215&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '民事訴訟小額程序開庭流程圖（103年度訴字第199號...）',
    ),
    CaseImage(
      url:
          'https://tse1.mm.bing.net/th/id/OIP.kgAAgTi1mrNURfP1WvpUNQHaFj?w=89&h=90&c=1&rs=1&qlt=70&r=0&o=7&pid=InlineBlock&rm=3',
      source: '判決確定證明書與執行憑證抄本（103年度訴字第199號...）',
    )
  ],
  'case-100': const [
    CaseImage(
      url:
          'https://tse4.mm.bing.net/th/id/OIP.Q7FEnIHkrd6q9Jmu1GiKkwHaEj?w=248&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '【本案卷宗封面照片】法庭審判司法天平現場照片',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.22mIh8FxQ1xTrLJEOF-vTgHaEO?w=89&h=89&c=1&rs=1&qlt=70&r=0&o=7&pid=InlineBlock&rm=3',
      source: '最高法院司法卷宗圖書館（107年度訴字第200號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.EQboFDqbqWRcR8PTOr3wQwHaDn?w=297&h=171&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '法規沿革與憲法判決法典（107年度訴字第200號...）',
    ),
    CaseImage(
      url:
          'https://tse4.mm.bing.net/th/id/OIP.zbbKZ0Bh_CpP6eZamtCRjwHaE9?w=179&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '本案訴訟卷宗外觀及編號（107年度訴字第200號...）',
    ),
    CaseImage(
      url:
          'https://tse1.mm.bing.net/th/id/OIP.xExaObj3A3nV3olc0K1gmwHaEJ?w=263&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '地方法院簡易庭外觀與開庭公告（107年度訴字第200號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.M1ZTFf8JShiFpHtxNdAuTwHaEz?w=227&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '當事人提出之訴狀首頁抄本（107年度訴字第200號...）',
    ),
    CaseImage(
      url:
          'https://tse3.mm.bing.net/th/id/OIP.RHmdPX6UGcKBDnAmC1DuxQHaE7?w=215&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '司法裁判書電子檔之判決主文（107年度訴字第200號...）',
    ),
    CaseImage(
      url:
          'https://tse3.mm.bing.net/th/id/OIP.8vGwbgtGBjFRl90_W32HlwHaE7?w=232&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '民事起訴狀與委任律師書狀（107年度訴字第200號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.6_z7cGk1TU-RBgQM3tsqZQHaE8?w=221&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '法院準備程序筆錄簽名欄位（107年度訴字第200號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.Xt1C-7meX374BAg86KC6LwHaE8?w=89&h=89&c=1&rs=1&qlt=70&r=0&o=7&pid=InlineBlock&rm=3',
      source: '司法院大法官憲法法庭開庭現場（107年度訴字第200號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.wXoezXbxYh3d5XAsPQA1mwHaE8?w=193&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '最高法院民事庭開庭大門外觀（107年度訴字第200號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.CR03_AAGv7DichRpWnF7NQHaE7?w=233&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '法學文獻與期刊論文引用頁面（107年度訴字第200號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.WVO6tR5BzOgw0oglmH02OAHaEP?w=208&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '中華民國六法全書民法債編法條（107年度訴字第200號...）',
    ),
    CaseImage(
      url:
          'https://tse1.mm.bing.net/th/id/OIP.fEDFLQLHjS3QuE4bQLgBvQHaE8?w=229&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '民事訴訟小額程序開庭流程圖（107年度訴字第200號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.jgOpaPncHSivavrOTSAXLgHaE8?w=232&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '判決確定證明書與執行憑證抄本（107年度訴字第200號...）',
    )
  ],
  'case-101': const [
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.22mIh8FxQ1xTrLJEOF-vTgHaEO?w=89&h=89&c=1&rs=1&qlt=70&r=0&o=7&pid=InlineBlock&rm=3',
      source: '【本案卷宗封面照片】法庭審判司法天平現場照片',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.wXoezXbxYh3d5XAsPQA1mwHaE8?w=193&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '最高法院司法卷宗圖書館（106年度訴字第201號...）',
    ),
    CaseImage(
      url:
          'https://tse4.mm.bing.net/th/id/OIP.zbbKZ0Bh_CpP6eZamtCRjwHaE9?w=179&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '法規沿革與憲法判決法典（106年度訴字第201號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.Xt1C-7meX374BAg86KC6LwHaE8?w=89&h=89&c=1&rs=1&qlt=70&r=0&o=7&pid=InlineBlock&rm=3',
      source: '本案訴訟卷宗外觀及編號（106年度訴字第201號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.CR03_AAGv7DichRpWnF7NQHaE7?w=233&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '地方法院簡易庭外觀與開庭公告（106年度訴字第201號...）',
    ),
    CaseImage(
      url:
          'https://tse3.mm.bing.net/th/id/OIP.rgvPoDUIQa-Gb56tJrl6sgHaEO?w=89&h=90&c=1&rs=1&qlt=70&r=0&o=7&pid=InlineBlock&rm=3',
      source: '當事人提出之訴狀首頁抄本（106年度訴字第201號...）',
    ),
    CaseImage(
      url:
          'https://tse3.mm.bing.net/th/id/OIP.8vGwbgtGBjFRl90_W32HlwHaE7?w=232&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '司法裁判書電子檔之判決主文（106年度訴字第201號...）',
    ),
    CaseImage(
      url:
          'https://tse1.mm.bing.net/th/id/OIP.kgAAgTi1mrNURfP1WvpUNQHaFj?w=89&h=90&c=1&rs=1&qlt=70&r=0&o=7&pid=InlineBlock&rm=3',
      source: '民事起訴狀與委任律師書狀（106年度訴字第201號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.jgOpaPncHSivavrOTSAXLgHaE8?w=232&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '法院準備程序筆錄簽名欄位（106年度訴字第201號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.WVO6tR5BzOgw0oglmH02OAHaEP?w=208&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '司法院大法官憲法法庭開庭現場（106年度訴字第201號...）',
    ),
    CaseImage(
      url:
          'https://tse1.mm.bing.net/th/id/OIP.xExaObj3A3nV3olc0K1gmwHaEJ?w=263&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '最高法院民事庭開庭大門外觀（106年度訴字第201號...）',
    ),
    CaseImage(
      url:
          'https://tse3.mm.bing.net/th/id/OIP.RHmdPX6UGcKBDnAmC1DuxQHaE7?w=215&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '法學文獻與期刊論文引用頁面（106年度訴字第201號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.6_z7cGk1TU-RBgQM3tsqZQHaE8?w=221&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '中華民國六法全書民法債編法條（106年度訴字第201號...）',
    ),
    CaseImage(
      url:
          'https://tse4.mm.bing.net/th/id/OIP.Q7FEnIHkrd6q9Jmu1GiKkwHaEj?w=248&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '民事訴訟小額程序開庭流程圖（106年度訴字第201號...）',
    ),
    CaseImage(
      url:
          'https://tse4.mm.bing.net/th/id/OIP.BpIJPdGnK-nMpGs5B9306AHaFe?w=206&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '判決確定證明書與執行憑證抄本（106年度訴字第201號...）',
    )
  ],
  'case-102': const [
    CaseImage(
      url:
          'https://tse3.mm.bing.net/th/id/OIP.FzL2M5zkVz2nUbqZg7Qe-QHaE7?w=215&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '【本案卷宗封面照片】法庭審判司法天平現場照片',
    ),
    CaseImage(
      url:
          'https://tse1.mm.bing.net/th/id/OIP.kgAAgTi1mrNURfP1WvpUNQHaFj?w=89&h=90&c=1&rs=1&qlt=70&r=0&o=7&pid=InlineBlock&rm=3',
      source: '最高法院司法卷宗圖書館（108年度訴字第202號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.Xt1C-7meX374BAg86KC6LwHaE8?w=89&h=89&c=1&rs=1&qlt=70&r=0&o=7&pid=InlineBlock&rm=3',
      source: '法規沿革與憲法判決法典（108年度訴字第202號...）',
    ),
    CaseImage(
      url:
          'https://tse3.mm.bing.net/th/id/OIP.rgvPoDUIQa-Gb56tJrl6sgHaEO?w=89&h=90&c=1&rs=1&qlt=70&r=0&o=7&pid=InlineBlock&rm=3',
      source: '本案訴訟卷宗外觀及編號（108年度訴字第202號...）',
    ),
    CaseImage(
      url:
          'https://tse4.mm.bing.net/th/id/OIP.FVJkOeXgZVSaQPF4GFSr2QHaD8?w=89&h=90&c=1&rs=1&qlt=70&r=0&o=7&pid=InlineBlock&rm=3',
      source: '地方法院簡易庭外觀與開庭公告（108年度訴字第202號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.wXoezXbxYh3d5XAsPQA1mwHaE8?w=193&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '當事人提出之訴狀首頁抄本（108年度訴字第202號...）',
    ),
    CaseImage(
      url:
          'https://tse4.mm.bing.net/th/id/OIP.Q7FEnIHkrd6q9Jmu1GiKkwHaEj?w=248&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '司法裁判書電子檔之判決主文（108年度訴字第202號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.FxsIbUCjMd4IlOEskxShJgHaFj?w=89&h=89&c=1&rs=1&qlt=70&r=0&o=7&pid=InlineBlock&rm=3',
      source: '民事起訴狀與委任律師書狀（108年度訴字第202號...）',
    ),
    CaseImage(
      url:
          'https://tse1.mm.bing.net/th/id/OIP.xExaObj3A3nV3olc0K1gmwHaEJ?w=263&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '法院準備程序筆錄簽名欄位（108年度訴字第202號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.EQboFDqbqWRcR8PTOr3wQwHaDn?w=297&h=171&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '司法院大法官憲法法庭開庭現場（108年度訴字第202號...）',
    ),
    CaseImage(
      url:
          'https://tse3.mm.bing.net/th/id/OIP.RHmdPX6UGcKBDnAmC1DuxQHaE7?w=215&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '最高法院民事庭開庭大門外觀（108年度訴字第202號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.6_z7cGk1TU-RBgQM3tsqZQHaE8?w=221&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '法學文獻與期刊論文引用頁面（108年度訴字第202號...）',
    ),
    CaseImage(
      url:
          'https://tse4.mm.bing.net/th/id/OIP.0SDoAANiAP6UoZPUrt3UqwHaEN?w=252&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '中華民國六法全書民法債編法條（108年度訴字第202號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.M1ZTFf8JShiFpHtxNdAuTwHaEz?w=227&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '民事訴訟小額程序開庭流程圖（108年度訴字第202號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.CR03_AAGv7DichRpWnF7NQHaE7?w=233&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '判決確定證明書與執行憑證抄本（108年度訴字第202號...）',
    )
  ],
  'case-103': const [
    CaseImage(
      url:
          'https://tse1.mm.bing.net/th/id/OIP.kgAAgTi1mrNURfP1WvpUNQHaFj?w=89&h=90&c=1&rs=1&qlt=70&r=0&o=7&pid=InlineBlock&rm=3',
      source: '【本案卷宗封面照片】法庭審判司法天平現場照片',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.Xt1C-7meX374BAg86KC6LwHaE8?w=89&h=89&c=1&rs=1&qlt=70&r=0&o=7&pid=InlineBlock&rm=3',
      source: '最高法院司法卷宗圖書館（110年度訴字第203號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.WVO6tR5BzOgw0oglmH02OAHaEP?w=208&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '法規沿革與憲法判決法典（110年度訴字第203號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.jgOpaPncHSivavrOTSAXLgHaE8?w=232&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '本案訴訟卷宗外觀及編號（110年度訴字第203號...）',
    ),
    CaseImage(
      url:
          'https://tse3.mm.bing.net/th/id/OIP.FzL2M5zkVz2nUbqZg7Qe-QHaE7?w=215&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '地方法院簡易庭外觀與開庭公告（110年度訴字第203號...）',
    ),
    CaseImage(
      url:
          'https://tse3.mm.bing.net/th/id/OIP.RHmdPX6UGcKBDnAmC1DuxQHaE7?w=215&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '當事人提出之訴狀首頁抄本（110年度訴字第203號...）',
    ),
    CaseImage(
      url:
          'https://tse3.mm.bing.net/th/id/OIP.8vGwbgtGBjFRl90_W32HlwHaE7?w=232&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '司法裁判書電子檔之判決主文（110年度訴字第203號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.M1ZTFf8JShiFpHtxNdAuTwHaEz?w=227&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '民事起訴狀與委任律師書狀（110年度訴字第203號...）',
    ),
    CaseImage(
      url:
          'https://tse4.mm.bing.net/th/id/OIP.BpIJPdGnK-nMpGs5B9306AHaFe?w=206&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '法院準備程序筆錄簽名欄位（110年度訴字第203號...）',
    ),
    CaseImage(
      url:
          'https://tse1.mm.bing.net/th/id/OIP.fEDFLQLHjS3QuE4bQLgBvQHaE8?w=229&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '司法院大法官憲法法庭開庭現場（110年度訴字第203號...）',
    ),
    CaseImage(
      url:
          'https://tse1.mm.bing.net/th/id/OIP.xExaObj3A3nV3olc0K1gmwHaEJ?w=263&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '最高法院民事庭開庭大門外觀（110年度訴字第203號...）',
    ),
    CaseImage(
      url:
          'https://tse4.mm.bing.net/th/id/OIP.zbbKZ0Bh_CpP6eZamtCRjwHaE9?w=179&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '法學文獻與期刊論文引用頁面（110年度訴字第203號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.6_z7cGk1TU-RBgQM3tsqZQHaE8?w=221&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '中華民國六法全書民法債編法條（110年度訴字第203號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.22mIh8FxQ1xTrLJEOF-vTgHaEO?w=89&h=89&c=1&rs=1&qlt=70&r=0&o=7&pid=InlineBlock&rm=3',
      source: '民事訴訟小額程序開庭流程圖（110年度訴字第203號...）',
    ),
    CaseImage(
      url:
          'https://tse4.mm.bing.net/th/id/OIP.0SDoAANiAP6UoZPUrt3UqwHaEN?w=252&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '判決確定證明書與執行憑證抄本（110年度訴字第203號...）',
    )
  ],
  'case-104': const [
    CaseImage(
      url:
          'https://tse4.mm.bing.net/th/id/OIP.0SDoAANiAP6UoZPUrt3UqwHaEN?w=252&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '【本案卷宗封面照片】法庭審判司法天平現場照片',
    ),
    CaseImage(
      url:
          'https://tse4.mm.bing.net/th/id/OIP.FVJkOeXgZVSaQPF4GFSr2QHaD8?w=89&h=90&c=1&rs=1&qlt=70&r=0&o=7&pid=InlineBlock&rm=3',
      source: '最高法院司法卷宗圖書館（108年度訴字第204號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.6_z7cGk1TU-RBgQM3tsqZQHaE8?w=221&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '法規沿革與憲法判決法典（108年度訴字第204號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.M1ZTFf8JShiFpHtxNdAuTwHaEz?w=227&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '本案訴訟卷宗外觀及編號（108年度訴字第204號...）',
    ),
    CaseImage(
      url:
          'https://tse1.mm.bing.net/th/id/OIP.kgAAgTi1mrNURfP1WvpUNQHaFj?w=89&h=90&c=1&rs=1&qlt=70&r=0&o=7&pid=InlineBlock&rm=3',
      source: '地方法院簡易庭外觀與開庭公告（108年度訴字第204號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.wXoezXbxYh3d5XAsPQA1mwHaE8?w=193&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '當事人提出之訴狀首頁抄本（108年度訴字第204號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.EQboFDqbqWRcR8PTOr3wQwHaDn?w=297&h=171&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '司法裁判書電子檔之判決主文（108年度訴字第204號...）',
    ),
    CaseImage(
      url:
          'https://tse1.mm.bing.net/th/id/OIP.fEDFLQLHjS3QuE4bQLgBvQHaE8?w=229&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '民事起訴狀與委任律師書狀（108年度訴字第204號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.WVO6tR5BzOgw0oglmH02OAHaEP?w=208&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '法院準備程序筆錄簽名欄位（108年度訴字第204號...）',
    ),
    CaseImage(
      url:
          'https://tse4.mm.bing.net/th/id/OIP.Q7FEnIHkrd6q9Jmu1GiKkwHaEj?w=248&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '司法院大法官憲法法庭開庭現場（108年度訴字第204號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.CR03_AAGv7DichRpWnF7NQHaE7?w=233&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '最高法院民事庭開庭大門外觀（108年度訴字第204號...）',
    ),
    CaseImage(
      url:
          'https://tse3.mm.bing.net/th/id/OIP.RHmdPX6UGcKBDnAmC1DuxQHaE7?w=215&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '法學文獻與期刊論文引用頁面（108年度訴字第204號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.FxsIbUCjMd4IlOEskxShJgHaFj?w=89&h=89&c=1&rs=1&qlt=70&r=0&o=7&pid=InlineBlock&rm=3',
      source: '中華民國六法全書民法債編法條（108年度訴字第204號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.22mIh8FxQ1xTrLJEOF-vTgHaEO?w=89&h=89&c=1&rs=1&qlt=70&r=0&o=7&pid=InlineBlock&rm=3',
      source: '民事訴訟小額程序開庭流程圖（108年度訴字第204號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.jgOpaPncHSivavrOTSAXLgHaE8?w=232&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '判決確定證明書與執行憑證抄本（108年度訴字第204號...）',
    )
  ],
  'case-105': const [
    CaseImage(
      url:
          'https://tse4.mm.bing.net/th/id/OIP.Q7FEnIHkrd6q9Jmu1GiKkwHaEj?w=248&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '【本案卷宗封面照片】法庭審判司法天平現場照片',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.EQboFDqbqWRcR8PTOr3wQwHaDn?w=297&h=171&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '最高法院司法卷宗圖書館（109年度訴字第205號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.jgOpaPncHSivavrOTSAXLgHaE8?w=232&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '法規沿革與憲法判決法典（109年度訴字第205號...）',
    ),
    CaseImage(
      url:
          'https://tse1.mm.bing.net/th/id/OIP.xExaObj3A3nV3olc0K1gmwHaEJ?w=263&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '本案訴訟卷宗外觀及編號（109年度訴字第205號...）',
    ),
    CaseImage(
      url:
          'https://tse3.mm.bing.net/th/id/OIP.rgvPoDUIQa-Gb56tJrl6sgHaEO?w=89&h=90&c=1&rs=1&qlt=70&r=0&o=7&pid=InlineBlock&rm=3',
      source: '地方法院簡易庭外觀與開庭公告（109年度訴字第205號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.6_z7cGk1TU-RBgQM3tsqZQHaE8?w=221&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '當事人提出之訴狀首頁抄本（109年度訴字第205號...）',
    ),
    CaseImage(
      url:
          'https://tse3.mm.bing.net/th/id/OIP.FzL2M5zkVz2nUbqZg7Qe-QHaE7?w=215&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '司法裁判書電子檔之判決主文（109年度訴字第205號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.wXoezXbxYh3d5XAsPQA1mwHaE8?w=193&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '民事起訴狀與委任律師書狀（109年度訴字第205號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.WVO6tR5BzOgw0oglmH02OAHaEP?w=208&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '法院準備程序筆錄簽名欄位（109年度訴字第205號...）',
    ),
    CaseImage(
      url:
          'https://tse3.mm.bing.net/th/id/OIP.8vGwbgtGBjFRl90_W32HlwHaE7?w=232&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '司法院大法官憲法法庭開庭現場（109年度訴字第205號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.FxsIbUCjMd4IlOEskxShJgHaFj?w=89&h=89&c=1&rs=1&qlt=70&r=0&o=7&pid=InlineBlock&rm=3',
      source: '最高法院民事庭開庭大門外觀（109年度訴字第205號...）',
    ),
    CaseImage(
      url:
          'https://tse4.mm.bing.net/th/id/OIP.zbbKZ0Bh_CpP6eZamtCRjwHaE9?w=179&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '法學文獻與期刊論文引用頁面（109年度訴字第205號...）',
    ),
    CaseImage(
      url:
          'https://tse3.mm.bing.net/th/id/OIP.RHmdPX6UGcKBDnAmC1DuxQHaE7?w=215&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '中華民國六法全書民法債編法條（109年度訴字第205號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.22mIh8FxQ1xTrLJEOF-vTgHaEO?w=89&h=89&c=1&rs=1&qlt=70&r=0&o=7&pid=InlineBlock&rm=3',
      source: '民事訴訟小額程序開庭流程圖（109年度訴字第205號...）',
    ),
    CaseImage(
      url:
          'https://tse4.mm.bing.net/th/id/OIP.0SDoAANiAP6UoZPUrt3UqwHaEN?w=252&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '判決確定證明書與執行憑證抄本（109年度訴字第205號...）',
    )
  ],
  'case-106': const [
    CaseImage(
      url:
          'https://tse3.mm.bing.net/th/id/OIP.FzL2M5zkVz2nUbqZg7Qe-QHaE7?w=215&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '【本案卷宗封面照片】法庭審判司法天平現場照片',
    ),
    CaseImage(
      url:
          'https://tse4.mm.bing.net/th/id/OIP.Q7FEnIHkrd6q9Jmu1GiKkwHaEj?w=248&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '最高法院司法卷宗圖書館（111年度訴字第206號...）',
    ),
    CaseImage(
      url:
          'https://tse1.mm.bing.net/th/id/OIP.xExaObj3A3nV3olc0K1gmwHaEJ?w=263&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '法規沿革與憲法判決法典（111年度訴字第206號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.wXoezXbxYh3d5XAsPQA1mwHaE8?w=193&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '本案訴訟卷宗外觀及編號（111年度訴字第206號...）',
    ),
    CaseImage(
      url:
          'https://tse4.mm.bing.net/th/id/OIP.BpIJPdGnK-nMpGs5B9306AHaFe?w=206&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '地方法院簡易庭外觀與開庭公告（111年度訴字第206號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.Xt1C-7meX374BAg86KC6LwHaE8?w=89&h=89&c=1&rs=1&qlt=70&r=0&o=7&pid=InlineBlock&rm=3',
      source: '當事人提出之訴狀首頁抄本（111年度訴字第206號...）',
    ),
    CaseImage(
      url:
          'https://tse3.mm.bing.net/th/id/OIP.rgvPoDUIQa-Gb56tJrl6sgHaEO?w=89&h=90&c=1&rs=1&qlt=70&r=0&o=7&pid=InlineBlock&rm=3',
      source: '司法裁判書電子檔之判決主文（111年度訴字第206號...）',
    ),
    CaseImage(
      url:
          'https://tse1.mm.bing.net/th/id/OIP.fEDFLQLHjS3QuE4bQLgBvQHaE8?w=229&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '民事起訴狀與委任律師書狀（111年度訴字第206號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.EQboFDqbqWRcR8PTOr3wQwHaDn?w=297&h=171&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '法院準備程序筆錄簽名欄位（111年度訴字第206號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.CR03_AAGv7DichRpWnF7NQHaE7?w=233&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '司法院大法官憲法法庭開庭現場（111年度訴字第206號...）',
    ),
    CaseImage(
      url:
          'https://tse4.mm.bing.net/th/id/OIP.FVJkOeXgZVSaQPF4GFSr2QHaD8?w=89&h=90&c=1&rs=1&qlt=70&r=0&o=7&pid=InlineBlock&rm=3',
      source: '最高法院民事庭開庭大門外觀（111年度訴字第206號...）',
    ),
    CaseImage(
      url:
          'https://tse3.mm.bing.net/th/id/OIP.8vGwbgtGBjFRl90_W32HlwHaE7?w=232&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '法學文獻與期刊論文引用頁面（111年度訴字第206號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.FxsIbUCjMd4IlOEskxShJgHaFj?w=89&h=89&c=1&rs=1&qlt=70&r=0&o=7&pid=InlineBlock&rm=3',
      source: '中華民國六法全書民法債編法條（111年度訴字第206號...）',
    ),
    CaseImage(
      url:
          'https://tse1.mm.bing.net/th/id/OIP.kgAAgTi1mrNURfP1WvpUNQHaFj?w=89&h=90&c=1&rs=1&qlt=70&r=0&o=7&pid=InlineBlock&rm=3',
      source: '民事訴訟小額程序開庭流程圖（111年度訴字第206號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.22mIh8FxQ1xTrLJEOF-vTgHaEO?w=89&h=89&c=1&rs=1&qlt=70&r=0&o=7&pid=InlineBlock&rm=3',
      source: '判決確定證明書與執行憑證抄本（111年度訴字第206號...）',
    )
  ],
  'case-107': const [
    CaseImage(
      url:
          'https://tse3.mm.bing.net/th/id/OIP.rgvPoDUIQa-Gb56tJrl6sgHaEO?w=89&h=90&c=1&rs=1&qlt=70&r=0&o=7&pid=InlineBlock&rm=3',
      source: '【本案卷宗封面照片】法庭審判司法天平現場照片',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.FxsIbUCjMd4IlOEskxShJgHaFj?w=89&h=89&c=1&rs=1&qlt=70&r=0&o=7&pid=InlineBlock&rm=3',
      source: '最高法院司法卷宗圖書館（102年度訴字第207號...）',
    ),
    CaseImage(
      url:
          'https://tse1.mm.bing.net/th/id/OIP.fEDFLQLHjS3QuE4bQLgBvQHaE8?w=229&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '法規沿革與憲法判決法典（102年度訴字第207號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.EQboFDqbqWRcR8PTOr3wQwHaDn?w=297&h=171&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '本案訴訟卷宗外觀及編號（102年度訴字第207號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.22mIh8FxQ1xTrLJEOF-vTgHaEO?w=89&h=89&c=1&rs=1&qlt=70&r=0&o=7&pid=InlineBlock&rm=3',
      source: '地方法院簡易庭外觀與開庭公告（102年度訴字第207號...）',
    ),
    CaseImage(
      url:
          'https://tse4.mm.bing.net/th/id/OIP.Q7FEnIHkrd6q9Jmu1GiKkwHaEj?w=248&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '當事人提出之訴狀首頁抄本（102年度訴字第207號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.Xt1C-7meX374BAg86KC6LwHaE8?w=89&h=89&c=1&rs=1&qlt=70&r=0&o=7&pid=InlineBlock&rm=3',
      source: '司法裁判書電子檔之判決主文（102年度訴字第207號...）',
    ),
    CaseImage(
      url:
          'https://tse4.mm.bing.net/th/id/OIP.FVJkOeXgZVSaQPF4GFSr2QHaD8?w=89&h=90&c=1&rs=1&qlt=70&r=0&o=7&pid=InlineBlock&rm=3',
      source: '民事起訴狀與委任律師書狀（102年度訴字第207號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.WVO6tR5BzOgw0oglmH02OAHaEP?w=208&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '法院準備程序筆錄簽名欄位（102年度訴字第207號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.wXoezXbxYh3d5XAsPQA1mwHaE8?w=193&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '司法院大法官憲法法庭開庭現場（102年度訴字第207號...）',
    ),
    CaseImage(
      url:
          'https://tse4.mm.bing.net/th/id/OIP.BpIJPdGnK-nMpGs5B9306AHaFe?w=206&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '最高法院民事庭開庭大門外觀（102年度訴字第207號...）',
    ),
    CaseImage(
      url:
          'https://tse3.mm.bing.net/th/id/OIP.8vGwbgtGBjFRl90_W32HlwHaE7?w=232&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '法學文獻與期刊論文引用頁面（102年度訴字第207號...）',
    ),
    CaseImage(
      url:
          'https://tse3.mm.bing.net/th/id/OIP.RHmdPX6UGcKBDnAmC1DuxQHaE7?w=215&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '中華民國六法全書民法債編法條（102年度訴字第207號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.6_z7cGk1TU-RBgQM3tsqZQHaE8?w=221&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '民事訴訟小額程序開庭流程圖（102年度訴字第207號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.M1ZTFf8JShiFpHtxNdAuTwHaEz?w=227&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '判決確定證明書與執行憑證抄本（102年度訴字第207號...）',
    )
  ],
  'case-108': const [
    CaseImage(
      url:
          'https://tse3.mm.bing.net/th/id/OIP.FzL2M5zkVz2nUbqZg7Qe-QHaE7?w=215&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '【本案卷宗封面照片】法庭審判司法天平現場照片',
    ),
    CaseImage(
      url:
          'https://tse3.mm.bing.net/th/id/OIP.RHmdPX6UGcKBDnAmC1DuxQHaE7?w=215&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '最高法院司法卷宗圖書館（司法院釋字第 1008 ...）',
    ),
    CaseImage(
      url:
          'https://tse4.mm.bing.net/th/id/OIP.0SDoAANiAP6UoZPUrt3UqwHaEN?w=252&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '法規沿革與憲法判決法典（司法院釋字第 1008 ...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.M1ZTFf8JShiFpHtxNdAuTwHaEz?w=227&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '本案訴訟卷宗外觀及編號（司法院釋字第 1008 ...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.jgOpaPncHSivavrOTSAXLgHaE8?w=232&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '地方法院簡易庭外觀與開庭公告（司法院釋字第 1008 ...）',
    ),
    CaseImage(
      url:
          'https://tse1.mm.bing.net/th/id/OIP.fEDFLQLHjS3QuE4bQLgBvQHaE8?w=229&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '當事人提出之訴狀首頁抄本（司法院釋字第 1008 ...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.WVO6tR5BzOgw0oglmH02OAHaEP?w=208&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '司法裁判書電子檔之判決主文（司法院釋字第 1008 ...）',
    ),
    CaseImage(
      url:
          'https://tse4.mm.bing.net/th/id/OIP.BpIJPdGnK-nMpGs5B9306AHaFe?w=206&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '民事起訴狀與委任律師書狀（司法院釋字第 1008 ...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.Xt1C-7meX374BAg86KC6LwHaE8?w=89&h=89&c=1&rs=1&qlt=70&r=0&o=7&pid=InlineBlock&rm=3',
      source: '法院準備程序筆錄簽名欄位（司法院釋字第 1008 ...）',
    ),
    CaseImage(
      url:
          'https://tse3.mm.bing.net/th/id/OIP.8vGwbgtGBjFRl90_W32HlwHaE7?w=232&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '司法院大法官憲法法庭開庭現場（司法院釋字第 1008 ...）',
    ),
    CaseImage(
      url:
          'https://tse4.mm.bing.net/th/id/OIP.zbbKZ0Bh_CpP6eZamtCRjwHaE9?w=179&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '最高法院民事庭開庭大門外觀（司法院釋字第 1008 ...）',
    ),
    CaseImage(
      url:
          'https://tse4.mm.bing.net/th/id/OIP.Q7FEnIHkrd6q9Jmu1GiKkwHaEj?w=248&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '法學文獻與期刊論文引用頁面（司法院釋字第 1008 ...）',
    ),
    CaseImage(
      url:
          'https://tse4.mm.bing.net/th/id/OIP.FVJkOeXgZVSaQPF4GFSr2QHaD8?w=89&h=90&c=1&rs=1&qlt=70&r=0&o=7&pid=InlineBlock&rm=3',
      source: '中華民國六法全書民法債編法條（司法院釋字第 1008 ...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.6_z7cGk1TU-RBgQM3tsqZQHaE8?w=221&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '民事訴訟小額程序開庭流程圖（司法院釋字第 1008 ...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.FxsIbUCjMd4IlOEskxShJgHaFj?w=89&h=89&c=1&rs=1&qlt=70&r=0&o=7&pid=InlineBlock&rm=3',
      source: '判決確定證明書與執行憑證抄本（司法院釋字第 1008 ...）',
    )
  ],
  'case-109': const [
    CaseImage(
      url:
          'https://tse3.mm.bing.net/th/id/OIP.rgvPoDUIQa-Gb56tJrl6sgHaEO?w=89&h=90&c=1&rs=1&qlt=70&r=0&o=7&pid=InlineBlock&rm=3',
      source: '【本案卷宗封面照片】法庭審判司法天平現場照片',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.wXoezXbxYh3d5XAsPQA1mwHaE8?w=193&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '最高法院司法卷宗圖書館（司法院釋字第 1009 ...）',
    ),
    CaseImage(
      url:
          'https://tse1.mm.bing.net/th/id/OIP.xExaObj3A3nV3olc0K1gmwHaEJ?w=263&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '法規沿革與憲法判決法典（司法院釋字第 1009 ...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.Xt1C-7meX374BAg86KC6LwHaE8?w=89&h=89&c=1&rs=1&qlt=70&r=0&o=7&pid=InlineBlock&rm=3',
      source: '本案訴訟卷宗外觀及編號（司法院釋字第 1009 ...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.FxsIbUCjMd4IlOEskxShJgHaFj?w=89&h=89&c=1&rs=1&qlt=70&r=0&o=7&pid=InlineBlock&rm=3',
      source: '地方法院簡易庭外觀與開庭公告（司法院釋字第 1009 ...）',
    ),
    CaseImage(
      url:
          'https://tse4.mm.bing.net/th/id/OIP.zbbKZ0Bh_CpP6eZamtCRjwHaE9?w=179&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '當事人提出之訴狀首頁抄本（司法院釋字第 1009 ...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.M1ZTFf8JShiFpHtxNdAuTwHaEz?w=227&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '司法裁判書電子檔之判決主文（司法院釋字第 1009 ...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.WVO6tR5BzOgw0oglmH02OAHaEP?w=208&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '民事起訴狀與委任律師書狀（司法院釋字第 1009 ...）',
    ),
    CaseImage(
      url:
          'https://tse3.mm.bing.net/th/id/OIP.8vGwbgtGBjFRl90_W32HlwHaE7?w=232&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '法院準備程序筆錄簽名欄位（司法院釋字第 1009 ...）',
    ),
    CaseImage(
      url:
          'https://tse1.mm.bing.net/th/id/OIP.kgAAgTi1mrNURfP1WvpUNQHaFj?w=89&h=90&c=1&rs=1&qlt=70&r=0&o=7&pid=InlineBlock&rm=3',
      source: '司法院大法官憲法法庭開庭現場（司法院釋字第 1009 ...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.jgOpaPncHSivavrOTSAXLgHaE8?w=232&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '最高法院民事庭開庭大門外觀（司法院釋字第 1009 ...）',
    ),
    CaseImage(
      url:
          'https://tse4.mm.bing.net/th/id/OIP.Q7FEnIHkrd6q9Jmu1GiKkwHaEj?w=248&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '法學文獻與期刊論文引用頁面（司法院釋字第 1009 ...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.EQboFDqbqWRcR8PTOr3wQwHaDn?w=297&h=171&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '中華民國六法全書民法債編法條（司法院釋字第 1009 ...）',
    ),
    CaseImage(
      url:
          'https://tse1.mm.bing.net/th/id/OIP.fEDFLQLHjS3QuE4bQLgBvQHaE8?w=229&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '民事訴訟小額程序開庭流程圖（司法院釋字第 1009 ...）',
    ),
    CaseImage(
      url:
          'https://tse4.mm.bing.net/th/id/OIP.FVJkOeXgZVSaQPF4GFSr2QHaD8?w=89&h=90&c=1&rs=1&qlt=70&r=0&o=7&pid=InlineBlock&rm=3',
      source: '判決確定證明書與執行憑證抄本（司法院釋字第 1009 ...）',
    )
  ],
  'case-110': const [
    CaseImage(
      url:
          'https://tse4.mm.bing.net/th/id/OIP.BpIJPdGnK-nMpGs5B9306AHaFe?w=206&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '【本案卷宗封面照片】法庭審判司法天平現場照片',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.jgOpaPncHSivavrOTSAXLgHaE8?w=232&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '最高法院司法卷宗圖書館（司法院釋字第 1010 ...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.EQboFDqbqWRcR8PTOr3wQwHaDn?w=297&h=171&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '法規沿革與憲法判決法典（司法院釋字第 1010 ...）',
    ),
    CaseImage(
      url:
          'https://tse3.mm.bing.net/th/id/OIP.rgvPoDUIQa-Gb56tJrl6sgHaEO?w=89&h=90&c=1&rs=1&qlt=70&r=0&o=7&pid=InlineBlock&rm=3',
      source: '本案訴訟卷宗外觀及編號（司法院釋字第 1010 ...）',
    ),
    CaseImage(
      url:
          'https://tse3.mm.bing.net/th/id/OIP.8vGwbgtGBjFRl90_W32HlwHaE7?w=232&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '地方法院簡易庭外觀與開庭公告（司法院釋字第 1010 ...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.22mIh8FxQ1xTrLJEOF-vTgHaEO?w=89&h=89&c=1&rs=1&qlt=70&r=0&o=7&pid=InlineBlock&rm=3',
      source: '當事人提出之訴狀首頁抄本（司法院釋字第 1010 ...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.FxsIbUCjMd4IlOEskxShJgHaFj?w=89&h=89&c=1&rs=1&qlt=70&r=0&o=7&pid=InlineBlock&rm=3',
      source: '司法裁判書電子檔之判決主文（司法院釋字第 1010 ...）',
    ),
    CaseImage(
      url:
          'https://tse4.mm.bing.net/th/id/OIP.FVJkOeXgZVSaQPF4GFSr2QHaD8?w=89&h=90&c=1&rs=1&qlt=70&r=0&o=7&pid=InlineBlock&rm=3',
      source: '民事起訴狀與委任律師書狀（司法院釋字第 1010 ...）',
    ),
    CaseImage(
      url:
          'https://tse4.mm.bing.net/th/id/OIP.zbbKZ0Bh_CpP6eZamtCRjwHaE9?w=179&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '法院準備程序筆錄簽名欄位（司法院釋字第 1010 ...）',
    ),
    CaseImage(
      url:
          'https://tse1.mm.bing.net/th/id/OIP.kgAAgTi1mrNURfP1WvpUNQHaFj?w=89&h=90&c=1&rs=1&qlt=70&r=0&o=7&pid=InlineBlock&rm=3',
      source: '司法院大法官憲法法庭開庭現場（司法院釋字第 1010 ...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.Xt1C-7meX374BAg86KC6LwHaE8?w=89&h=89&c=1&rs=1&qlt=70&r=0&o=7&pid=InlineBlock&rm=3',
      source: '最高法院民事庭開庭大門外觀（司法院釋字第 1010 ...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.M1ZTFf8JShiFpHtxNdAuTwHaEz?w=227&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '法學文獻與期刊論文引用頁面（司法院釋字第 1010 ...）',
    ),
    CaseImage(
      url:
          'https://tse4.mm.bing.net/th/id/OIP.0SDoAANiAP6UoZPUrt3UqwHaEN?w=252&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '中華民國六法全書民法債編法條（司法院釋字第 1010 ...）',
    ),
    CaseImage(
      url:
          'https://tse1.mm.bing.net/th/id/OIP.xExaObj3A3nV3olc0K1gmwHaEJ?w=263&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '民事訴訟小額程序開庭流程圖（司法院釋字第 1010 ...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.CR03_AAGv7DichRpWnF7NQHaE7?w=233&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '判決確定證明書與執行憑證抄本（司法院釋字第 1010 ...）',
    )
  ],
  'case-111': const [
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.wXoezXbxYh3d5XAsPQA1mwHaE8?w=193&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '【本案卷宗封面照片】法庭審判司法天平現場照片',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.FxsIbUCjMd4IlOEskxShJgHaFj?w=89&h=89&c=1&rs=1&qlt=70&r=0&o=7&pid=InlineBlock&rm=3',
      source: '最高法院司法卷宗圖書館（110 年憲判字第 12...）',
    ),
    CaseImage(
      url:
          'https://tse3.mm.bing.net/th/id/OIP.8vGwbgtGBjFRl90_W32HlwHaE7?w=232&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '法規沿革與憲法判決法典（110 年憲判字第 12...）',
    ),
    CaseImage(
      url:
          'https://tse3.mm.bing.net/th/id/OIP.FzL2M5zkVz2nUbqZg7Qe-QHaE7?w=215&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '本案訴訟卷宗外觀及編號（110 年憲判字第 12...）',
    ),
    CaseImage(
      url:
          'https://tse4.mm.bing.net/th/id/OIP.FVJkOeXgZVSaQPF4GFSr2QHaD8?w=89&h=90&c=1&rs=1&qlt=70&r=0&o=7&pid=InlineBlock&rm=3',
      source: '地方法院簡易庭外觀與開庭公告（110 年憲判字第 12...）',
    ),
    CaseImage(
      url:
          'https://tse1.mm.bing.net/th/id/OIP.xExaObj3A3nV3olc0K1gmwHaEJ?w=263&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '當事人提出之訴狀首頁抄本（110 年憲判字第 12...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.6_z7cGk1TU-RBgQM3tsqZQHaE8?w=221&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '司法裁判書電子檔之判決主文（110 年憲判字第 12...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.CR03_AAGv7DichRpWnF7NQHaE7?w=233&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '民事起訴狀與委任律師書狀（110 年憲判字第 12...）',
    ),
    CaseImage(
      url:
          'https://tse1.mm.bing.net/th/id/OIP.kgAAgTi1mrNURfP1WvpUNQHaFj?w=89&h=90&c=1&rs=1&qlt=70&r=0&o=7&pid=InlineBlock&rm=3',
      source: '法院準備程序筆錄簽名欄位（110 年憲判字第 12...）',
    ),
    CaseImage(
      url:
          'https://tse4.mm.bing.net/th/id/OIP.zbbKZ0Bh_CpP6eZamtCRjwHaE9?w=179&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '司法院大法官憲法法庭開庭現場（110 年憲判字第 12...）',
    ),
    CaseImage(
      url:
          'https://tse4.mm.bing.net/th/id/OIP.0SDoAANiAP6UoZPUrt3UqwHaEN?w=252&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '最高法院民事庭開庭大門外觀（110 年憲判字第 12...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.M1ZTFf8JShiFpHtxNdAuTwHaEz?w=227&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '法學文獻與期刊論文引用頁面（110 年憲判字第 12...）',
    ),
    CaseImage(
      url:
          'https://tse1.mm.bing.net/th/id/OIP.fEDFLQLHjS3QuE4bQLgBvQHaE8?w=229&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '中華民國六法全書民法債編法條（110 年憲判字第 12...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.WVO6tR5BzOgw0oglmH02OAHaEP?w=208&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '民事訴訟小額程序開庭流程圖（110 年憲判字第 12...）',
    ),
    CaseImage(
      url:
          'https://tse3.mm.bing.net/th/id/OIP.RHmdPX6UGcKBDnAmC1DuxQHaE7?w=215&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '判決確定證明書與執行憑證抄本（110 年憲判字第 12...）',
    )
  ],
  'case-112': const [
    CaseImage(
      url:
          'https://tse1.mm.bing.net/th/id/OIP.xExaObj3A3nV3olc0K1gmwHaEJ?w=263&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '【本案卷宗封面照片】法庭審判司法天平現場照片',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.Xt1C-7meX374BAg86KC6LwHaE8?w=89&h=89&c=1&rs=1&qlt=70&r=0&o=7&pid=InlineBlock&rm=3',
      source: '最高法院司法卷宗圖書館（111 年憲判字第 13...）',
    ),
    CaseImage(
      url:
          'https://tse3.mm.bing.net/th/id/OIP.rgvPoDUIQa-Gb56tJrl6sgHaEO?w=89&h=90&c=1&rs=1&qlt=70&r=0&o=7&pid=InlineBlock&rm=3',
      source: '法規沿革與憲法判決法典（111 年憲判字第 13...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.M1ZTFf8JShiFpHtxNdAuTwHaEz?w=227&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '本案訴訟卷宗外觀及編號（111 年憲判字第 13...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.WVO6tR5BzOgw0oglmH02OAHaEP?w=208&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '地方法院簡易庭外觀與開庭公告（111 年憲判字第 13...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.EQboFDqbqWRcR8PTOr3wQwHaDn?w=297&h=171&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '當事人提出之訴狀首頁抄本（111 年憲判字第 13...）',
    ),
    CaseImage(
      url:
          'https://tse3.mm.bing.net/th/id/OIP.8vGwbgtGBjFRl90_W32HlwHaE7?w=232&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '司法裁判書電子檔之判決主文（111 年憲判字第 13...）',
    ),
    CaseImage(
      url:
          'https://tse4.mm.bing.net/th/id/OIP.BpIJPdGnK-nMpGs5B9306AHaFe?w=206&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '民事起訴狀與委任律師書狀（111 年憲判字第 13...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.CR03_AAGv7DichRpWnF7NQHaE7?w=233&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '法院準備程序筆錄簽名欄位（111 年憲判字第 13...）',
    ),
    CaseImage(
      url:
          'https://tse4.mm.bing.net/th/id/OIP.zbbKZ0Bh_CpP6eZamtCRjwHaE9?w=179&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '司法院大法官憲法法庭開庭現場（111 年憲判字第 13...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.22mIh8FxQ1xTrLJEOF-vTgHaEO?w=89&h=89&c=1&rs=1&qlt=70&r=0&o=7&pid=InlineBlock&rm=3',
      source: '最高法院民事庭開庭大門外觀（111 年憲判字第 13...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.wXoezXbxYh3d5XAsPQA1mwHaE8?w=193&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '法學文獻與期刊論文引用頁面（111 年憲判字第 13...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.6_z7cGk1TU-RBgQM3tsqZQHaE8?w=221&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '中華民國六法全書民法債編法條（111 年憲判字第 13...）',
    ),
    CaseImage(
      url:
          'https://tse4.mm.bing.net/th/id/OIP.0SDoAANiAP6UoZPUrt3UqwHaEN?w=252&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '民事訴訟小額程序開庭流程圖（111 年憲判字第 13...）',
    ),
    CaseImage(
      url:
          'https://tse3.mm.bing.net/th/id/OIP.FzL2M5zkVz2nUbqZg7Qe-QHaE7?w=215&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '判決確定證明書與執行憑證抄本（111 年憲判字第 13...）',
    )
  ],
  'case-113': const [
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.wXoezXbxYh3d5XAsPQA1mwHaE8?w=193&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '【本案卷宗封面照片】法庭審判司法天平現場照片',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.Xt1C-7meX374BAg86KC6LwHaE8?w=89&h=89&c=1&rs=1&qlt=70&r=0&o=7&pid=InlineBlock&rm=3',
      source: '最高法院司法卷宗圖書館（111 年憲判字第 14...）',
    ),
    CaseImage(
      url:
          'https://tse3.mm.bing.net/th/id/OIP.RHmdPX6UGcKBDnAmC1DuxQHaE7?w=215&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '法規沿革與憲法判決法典（111 年憲判字第 14...）',
    ),
    CaseImage(
      url:
          'https://tse4.mm.bing.net/th/id/OIP.0SDoAANiAP6UoZPUrt3UqwHaEN?w=252&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '本案訴訟卷宗外觀及編號（111 年憲判字第 14...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.EQboFDqbqWRcR8PTOr3wQwHaDn?w=297&h=171&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '地方法院簡易庭外觀與開庭公告（111 年憲判字第 14...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.CR03_AAGv7DichRpWnF7NQHaE7?w=233&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '當事人提出之訴狀首頁抄本（111 年憲判字第 14...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.22mIh8FxQ1xTrLJEOF-vTgHaEO?w=89&h=89&c=1&rs=1&qlt=70&r=0&o=7&pid=InlineBlock&rm=3',
      source: '司法裁判書電子檔之判決主文（111 年憲判字第 14...）',
    ),
    CaseImage(
      url:
          'https://tse4.mm.bing.net/th/id/OIP.BpIJPdGnK-nMpGs5B9306AHaFe?w=206&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '民事起訴狀與委任律師書狀（111 年憲判字第 14...）',
    ),
    CaseImage(
      url:
          'https://tse4.mm.bing.net/th/id/OIP.zbbKZ0Bh_CpP6eZamtCRjwHaE9?w=179&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '法院準備程序筆錄簽名欄位（111 年憲判字第 14...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.WVO6tR5BzOgw0oglmH02OAHaEP?w=208&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '司法院大法官憲法法庭開庭現場（111 年憲判字第 14...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.jgOpaPncHSivavrOTSAXLgHaE8?w=232&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '最高法院民事庭開庭大門外觀（111 年憲判字第 14...）',
    ),
    CaseImage(
      url:
          'https://tse4.mm.bing.net/th/id/OIP.FVJkOeXgZVSaQPF4GFSr2QHaD8?w=89&h=90&c=1&rs=1&qlt=70&r=0&o=7&pid=InlineBlock&rm=3',
      source: '法學文獻與期刊論文引用頁面（111 年憲判字第 14...）',
    ),
    CaseImage(
      url:
          'https://tse4.mm.bing.net/th/id/OIP.Q7FEnIHkrd6q9Jmu1GiKkwHaEj?w=248&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '中華民國六法全書民法債編法條（111 年憲判字第 14...）',
    ),
    CaseImage(
      url:
          'https://tse3.mm.bing.net/th/id/OIP.FzL2M5zkVz2nUbqZg7Qe-QHaE7?w=215&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '民事訴訟小額程序開庭流程圖（111 年憲判字第 14...）',
    ),
    CaseImage(
      url:
          'https://tse1.mm.bing.net/th/id/OIP.xExaObj3A3nV3olc0K1gmwHaEJ?w=263&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '判決確定證明書與執行憑證抄本（111 年憲判字第 14...）',
    )
  ],
  'case-114': const [
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.22mIh8FxQ1xTrLJEOF-vTgHaEO?w=89&h=89&c=1&rs=1&qlt=70&r=0&o=7&pid=InlineBlock&rm=3',
      source: '【本案卷宗封面照片】法庭審判司法天平現場照片',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.WVO6tR5BzOgw0oglmH02OAHaEP?w=208&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '最高法院司法卷宗圖書館（司法院釋字第 1014 ...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.CR03_AAGv7DichRpWnF7NQHaE7?w=233&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '法規沿革與憲法判決法典（司法院釋字第 1014 ...）',
    ),
    CaseImage(
      url:
          'https://tse3.mm.bing.net/th/id/OIP.FzL2M5zkVz2nUbqZg7Qe-QHaE7?w=215&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '本案訴訟卷宗外觀及編號（司法院釋字第 1014 ...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.jgOpaPncHSivavrOTSAXLgHaE8?w=232&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '地方法院簡易庭外觀與開庭公告（司法院釋字第 1014 ...）',
    ),
    CaseImage(
      url:
          'https://tse3.mm.bing.net/th/id/OIP.rgvPoDUIQa-Gb56tJrl6sgHaEO?w=89&h=90&c=1&rs=1&qlt=70&r=0&o=7&pid=InlineBlock&rm=3',
      source: '當事人提出之訴狀首頁抄本（司法院釋字第 1014 ...）',
    ),
    CaseImage(
      url:
          'https://tse3.mm.bing.net/th/id/OIP.8vGwbgtGBjFRl90_W32HlwHaE7?w=232&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '司法裁判書電子檔之判決主文（司法院釋字第 1014 ...）',
    ),
    CaseImage(
      url:
          'https://tse3.mm.bing.net/th/id/OIP.RHmdPX6UGcKBDnAmC1DuxQHaE7?w=215&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '民事起訴狀與委任律師書狀（司法院釋字第 1014 ...）',
    ),
    CaseImage(
      url:
          'https://tse4.mm.bing.net/th/id/OIP.FVJkOeXgZVSaQPF4GFSr2QHaD8?w=89&h=90&c=1&rs=1&qlt=70&r=0&o=7&pid=InlineBlock&rm=3',
      source: '法院準備程序筆錄簽名欄位（司法院釋字第 1014 ...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.wXoezXbxYh3d5XAsPQA1mwHaE8?w=193&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '司法院大法官憲法法庭開庭現場（司法院釋字第 1014 ...）',
    ),
    CaseImage(
      url:
          'https://tse4.mm.bing.net/th/id/OIP.zbbKZ0Bh_CpP6eZamtCRjwHaE9?w=179&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '最高法院民事庭開庭大門外觀（司法院釋字第 1014 ...）',
    ),
    CaseImage(
      url:
          'https://tse1.mm.bing.net/th/id/OIP.xExaObj3A3nV3olc0K1gmwHaEJ?w=263&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '法學文獻與期刊論文引用頁面（司法院釋字第 1014 ...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.EQboFDqbqWRcR8PTOr3wQwHaDn?w=297&h=171&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '中華民國六法全書民法債編法條（司法院釋字第 1014 ...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.6_z7cGk1TU-RBgQM3tsqZQHaE8?w=221&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '民事訴訟小額程序開庭流程圖（司法院釋字第 1014 ...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.Xt1C-7meX374BAg86KC6LwHaE8?w=89&h=89&c=1&rs=1&qlt=70&r=0&o=7&pid=InlineBlock&rm=3',
      source: '判決確定證明書與執行憑證抄本（司法院釋字第 1014 ...）',
    )
  ],
  'case-115': const [
    CaseImage(
      url:
          'https://tse4.mm.bing.net/th/id/OIP.Q7FEnIHkrd6q9Jmu1GiKkwHaEj?w=248&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '【本案卷宗封面照片】法庭審判司法天平現場照片',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.Xt1C-7meX374BAg86KC6LwHaE8?w=89&h=89&c=1&rs=1&qlt=70&r=0&o=7&pid=InlineBlock&rm=3',
      source: '最高法院司法卷宗圖書館（司法院釋字第 1015 ...）',
    ),
    CaseImage(
      url:
          'https://tse3.mm.bing.net/th/id/OIP.FzL2M5zkVz2nUbqZg7Qe-QHaE7?w=215&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '法規沿革與憲法判決法典（司法院釋字第 1015 ...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.WVO6tR5BzOgw0oglmH02OAHaEP?w=208&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '本案訴訟卷宗外觀及編號（司法院釋字第 1015 ...）',
    ),
    CaseImage(
      url:
          'https://tse3.mm.bing.net/th/id/OIP.8vGwbgtGBjFRl90_W32HlwHaE7?w=232&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '地方法院簡易庭外觀與開庭公告（司法院釋字第 1015 ...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.6_z7cGk1TU-RBgQM3tsqZQHaE8?w=221&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '當事人提出之訴狀首頁抄本（司法院釋字第 1015 ...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.22mIh8FxQ1xTrLJEOF-vTgHaEO?w=89&h=89&c=1&rs=1&qlt=70&r=0&o=7&pid=InlineBlock&rm=3',
      source: '司法裁判書電子檔之判決主文（司法院釋字第 1015 ...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.M1ZTFf8JShiFpHtxNdAuTwHaEz?w=227&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '民事起訴狀與委任律師書狀（司法院釋字第 1015 ...）',
    ),
    CaseImage(
      url:
          'https://tse1.mm.bing.net/th/id/OIP.fEDFLQLHjS3QuE4bQLgBvQHaE8?w=229&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '法院準備程序筆錄簽名欄位（司法院釋字第 1015 ...）',
    ),
    CaseImage(
      url:
          'https://tse3.mm.bing.net/th/id/OIP.rgvPoDUIQa-Gb56tJrl6sgHaEO?w=89&h=90&c=1&rs=1&qlt=70&r=0&o=7&pid=InlineBlock&rm=3',
      source: '司法院大法官憲法法庭開庭現場（司法院釋字第 1015 ...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.CR03_AAGv7DichRpWnF7NQHaE7?w=233&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '最高法院民事庭開庭大門外觀（司法院釋字第 1015 ...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.wXoezXbxYh3d5XAsPQA1mwHaE8?w=193&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '法學文獻與期刊論文引用頁面（司法院釋字第 1015 ...）',
    ),
    CaseImage(
      url:
          'https://tse1.mm.bing.net/th/id/OIP.kgAAgTi1mrNURfP1WvpUNQHaFj?w=89&h=90&c=1&rs=1&qlt=70&r=0&o=7&pid=InlineBlock&rm=3',
      source: '中華民國六法全書民法債編法條（司法院釋字第 1015 ...）',
    ),
    CaseImage(
      url:
          'https://tse3.mm.bing.net/th/id/OIP.RHmdPX6UGcKBDnAmC1DuxQHaE7?w=215&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '民事訴訟小額程序開庭流程圖（司法院釋字第 1015 ...）',
    ),
    CaseImage(
      url:
          'https://tse4.mm.bing.net/th/id/OIP.0SDoAANiAP6UoZPUrt3UqwHaEN?w=252&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '判決確定證明書與執行憑證抄本（司法院釋字第 1015 ...）',
    )
  ],
  'case-116': const [
    CaseImage(
      url:
          'https://tse3.mm.bing.net/th/id/OIP.FzL2M5zkVz2nUbqZg7Qe-QHaE7?w=215&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '【本案卷宗封面照片】法庭審判司法天平現場照片',
    ),
    CaseImage(
      url:
          'https://tse1.mm.bing.net/th/id/OIP.kgAAgTi1mrNURfP1WvpUNQHaFj?w=89&h=90&c=1&rs=1&qlt=70&r=0&o=7&pid=InlineBlock&rm=3',
      source: '最高法院司法卷宗圖書館（110 年憲判字第 17...）',
    ),
    CaseImage(
      url:
          'https://tse3.mm.bing.net/th/id/OIP.8vGwbgtGBjFRl90_W32HlwHaE7?w=232&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '法規沿革與憲法判決法典（110 年憲判字第 17...）',
    ),
    CaseImage(
      url:
          'https://tse1.mm.bing.net/th/id/OIP.fEDFLQLHjS3QuE4bQLgBvQHaE8?w=229&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '本案訴訟卷宗外觀及編號（110 年憲判字第 17...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.WVO6tR5BzOgw0oglmH02OAHaEP?w=208&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '地方法院簡易庭外觀與開庭公告（110 年憲判字第 17...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.CR03_AAGv7DichRpWnF7NQHaE7?w=233&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '當事人提出之訴狀首頁抄本（110 年憲判字第 17...）',
    ),
    CaseImage(
      url:
          'https://tse4.mm.bing.net/th/id/OIP.FVJkOeXgZVSaQPF4GFSr2QHaD8?w=89&h=90&c=1&rs=1&qlt=70&r=0&o=7&pid=InlineBlock&rm=3',
      source: '司法裁判書電子檔之判決主文（110 年憲判字第 17...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.6_z7cGk1TU-RBgQM3tsqZQHaE8?w=221&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '民事起訴狀與委任律師書狀（110 年憲判字第 17...）',
    ),
    CaseImage(
      url:
          'https://tse4.mm.bing.net/th/id/OIP.0SDoAANiAP6UoZPUrt3UqwHaEN?w=252&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '法院準備程序筆錄簽名欄位（110 年憲判字第 17...）',
    ),
    CaseImage(
      url:
          'https://tse4.mm.bing.net/th/id/OIP.Q7FEnIHkrd6q9Jmu1GiKkwHaEj?w=248&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '司法院大法官憲法法庭開庭現場（110 年憲判字第 17...）',
    ),
    CaseImage(
      url:
          'https://tse4.mm.bing.net/th/id/OIP.BpIJPdGnK-nMpGs5B9306AHaFe?w=206&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '最高法院民事庭開庭大門外觀（110 年憲判字第 17...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.EQboFDqbqWRcR8PTOr3wQwHaDn?w=297&h=171&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '法學文獻與期刊論文引用頁面（110 年憲判字第 17...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.jgOpaPncHSivavrOTSAXLgHaE8?w=232&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '中華民國六法全書民法債編法條（110 年憲判字第 17...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.M1ZTFf8JShiFpHtxNdAuTwHaEz?w=227&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '民事訴訟小額程序開庭流程圖（110 年憲判字第 17...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.FxsIbUCjMd4IlOEskxShJgHaFj?w=89&h=89&c=1&rs=1&qlt=70&r=0&o=7&pid=InlineBlock&rm=3',
      source: '判決確定證明書與執行憑證抄本（110 年憲判字第 17...）',
    )
  ],
  'case-117': const [
    CaseImage(
      url:
          'https://tse3.mm.bing.net/th/id/OIP.8vGwbgtGBjFRl90_W32HlwHaE7?w=232&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '【本案卷宗封面照片】法庭審判司法天平現場照片',
    ),
    CaseImage(
      url:
          'https://tse1.mm.bing.net/th/id/OIP.xExaObj3A3nV3olc0K1gmwHaEJ?w=263&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '最高法院司法卷宗圖書館（111 年憲判字第 18...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.M1ZTFf8JShiFpHtxNdAuTwHaEz?w=227&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '法規沿革與憲法判決法典（111 年憲判字第 18...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.FxsIbUCjMd4IlOEskxShJgHaFj?w=89&h=89&c=1&rs=1&qlt=70&r=0&o=7&pid=InlineBlock&rm=3',
      source: '本案訴訟卷宗外觀及編號（111 年憲判字第 18...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.jgOpaPncHSivavrOTSAXLgHaE8?w=232&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '地方法院簡易庭外觀與開庭公告（111 年憲判字第 18...）',
    ),
    CaseImage(
      url:
          'https://tse3.mm.bing.net/th/id/OIP.FzL2M5zkVz2nUbqZg7Qe-QHaE7?w=215&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '當事人提出之訴狀首頁抄本（111 年憲判字第 18...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.WVO6tR5BzOgw0oglmH02OAHaEP?w=208&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '司法裁判書電子檔之判決主文（111 年憲判字第 18...）',
    ),
    CaseImage(
      url:
          'https://tse4.mm.bing.net/th/id/OIP.zbbKZ0Bh_CpP6eZamtCRjwHaE9?w=179&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '民事起訴狀與委任律師書狀（111 年憲判字第 18...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.CR03_AAGv7DichRpWnF7NQHaE7?w=233&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '法院準備程序筆錄簽名欄位（111 年憲判字第 18...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.EQboFDqbqWRcR8PTOr3wQwHaDn?w=297&h=171&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '司法院大法官憲法法庭開庭現場（111 年憲判字第 18...）',
    ),
    CaseImage(
      url:
          'https://tse3.mm.bing.net/th/id/OIP.RHmdPX6UGcKBDnAmC1DuxQHaE7?w=215&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '最高法院民事庭開庭大門外觀（111 年憲判字第 18...）',
    ),
    CaseImage(
      url:
          'https://tse4.mm.bing.net/th/id/OIP.FVJkOeXgZVSaQPF4GFSr2QHaD8?w=89&h=90&c=1&rs=1&qlt=70&r=0&o=7&pid=InlineBlock&rm=3',
      source: '法學文獻與期刊論文引用頁面（111 年憲判字第 18...）',
    ),
    CaseImage(
      url:
          'https://tse3.mm.bing.net/th/id/OIP.rgvPoDUIQa-Gb56tJrl6sgHaEO?w=89&h=90&c=1&rs=1&qlt=70&r=0&o=7&pid=InlineBlock&rm=3',
      source: '中華民國六法全書民法債編法條（111 年憲判字第 18...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.Xt1C-7meX374BAg86KC6LwHaE8?w=89&h=89&c=1&rs=1&qlt=70&r=0&o=7&pid=InlineBlock&rm=3',
      source: '民事訴訟小額程序開庭流程圖（111 年憲判字第 18...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.22mIh8FxQ1xTrLJEOF-vTgHaEO?w=89&h=89&c=1&rs=1&qlt=70&r=0&o=7&pid=InlineBlock&rm=3',
      source: '判決確定證明書與執行憑證抄本（111 年憲判字第 18...）',
    )
  ],
  'case-118': const [
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.Xt1C-7meX374BAg86KC6LwHaE8?w=89&h=89&c=1&rs=1&qlt=70&r=0&o=7&pid=InlineBlock&rm=3',
      source: '【本案卷宗封面照片】法庭審判司法天平現場照片',
    ),
    CaseImage(
      url:
          'https://tse1.mm.bing.net/th/id/OIP.xExaObj3A3nV3olc0K1gmwHaEJ?w=263&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '最高法院司法卷宗圖書館（107年度訴字第218號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.EQboFDqbqWRcR8PTOr3wQwHaDn?w=297&h=171&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '法規沿革與憲法判決法典（107年度訴字第218號...）',
    ),
    CaseImage(
      url:
          'https://tse3.mm.bing.net/th/id/OIP.8vGwbgtGBjFRl90_W32HlwHaE7?w=232&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '本案訴訟卷宗外觀及編號（107年度訴字第218號...）',
    ),
    CaseImage(
      url:
          'https://tse4.mm.bing.net/th/id/OIP.BpIJPdGnK-nMpGs5B9306AHaFe?w=206&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '地方法院簡易庭外觀與開庭公告（107年度訴字第218號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.jgOpaPncHSivavrOTSAXLgHaE8?w=232&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '當事人提出之訴狀首頁抄本（107年度訴字第218號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.wXoezXbxYh3d5XAsPQA1mwHaE8?w=193&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '司法裁判書電子檔之判決主文（107年度訴字第218號...）',
    ),
    CaseImage(
      url:
          'https://tse3.mm.bing.net/th/id/OIP.FzL2M5zkVz2nUbqZg7Qe-QHaE7?w=215&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '民事起訴狀與委任律師書狀（107年度訴字第218號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.WVO6tR5BzOgw0oglmH02OAHaEP?w=208&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '法院準備程序筆錄簽名欄位（107年度訴字第218號...）',
    ),
    CaseImage(
      url:
          'https://tse3.mm.bing.net/th/id/OIP.rgvPoDUIQa-Gb56tJrl6sgHaEO?w=89&h=90&c=1&rs=1&qlt=70&r=0&o=7&pid=InlineBlock&rm=3',
      source: '司法院大法官憲法法庭開庭現場（107年度訴字第218號...）',
    ),
    CaseImage(
      url:
          'https://tse1.mm.bing.net/th/id/OIP.kgAAgTi1mrNURfP1WvpUNQHaFj?w=89&h=90&c=1&rs=1&qlt=70&r=0&o=7&pid=InlineBlock&rm=3',
      source: '最高法院民事庭開庭大門外觀（107年度訴字第218號...）',
    ),
    CaseImage(
      url:
          'https://tse4.mm.bing.net/th/id/OIP.0SDoAANiAP6UoZPUrt3UqwHaEN?w=252&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '法學文獻與期刊論文引用頁面（107年度訴字第218號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.6_z7cGk1TU-RBgQM3tsqZQHaE8?w=221&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '中華民國六法全書民法債編法條（107年度訴字第218號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.CR03_AAGv7DichRpWnF7NQHaE7?w=233&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '民事訴訟小額程序開庭流程圖（107年度訴字第218號...）',
    ),
    CaseImage(
      url:
          'https://tse4.mm.bing.net/th/id/OIP.Q7FEnIHkrd6q9Jmu1GiKkwHaEj?w=248&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '判決確定證明書與執行憑證抄本（107年度訴字第218號...）',
    )
  ],
  'case-119': const [
    CaseImage(
      url:
          'https://tse1.mm.bing.net/th/id/OIP.xExaObj3A3nV3olc0K1gmwHaEJ?w=263&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '【本案卷宗封面照片】法庭審判司法天平現場照片',
    ),
    CaseImage(
      url:
          'https://tse4.mm.bing.net/th/id/OIP.Q7FEnIHkrd6q9Jmu1GiKkwHaEj?w=248&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '最高法院司法卷宗圖書館（108年度訴字第219號...）',
    ),
    CaseImage(
      url:
          'https://tse3.mm.bing.net/th/id/OIP.8vGwbgtGBjFRl90_W32HlwHaE7?w=232&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '法規沿革與憲法判決法典（108年度訴字第219號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.22mIh8FxQ1xTrLJEOF-vTgHaEO?w=89&h=89&c=1&rs=1&qlt=70&r=0&o=7&pid=InlineBlock&rm=3',
      source: '本案訴訟卷宗外觀及編號（108年度訴字第219號...）',
    ),
    CaseImage(
      url:
          'https://tse4.mm.bing.net/th/id/OIP.BpIJPdGnK-nMpGs5B9306AHaFe?w=206&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '地方法院簡易庭外觀與開庭公告（108年度訴字第219號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.CR03_AAGv7DichRpWnF7NQHaE7?w=233&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '當事人提出之訴狀首頁抄本（108年度訴字第219號...）',
    ),
    CaseImage(
      url:
          'https://tse3.mm.bing.net/th/id/OIP.FzL2M5zkVz2nUbqZg7Qe-QHaE7?w=215&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '司法裁判書電子檔之判決主文（108年度訴字第219號...）',
    ),
    CaseImage(
      url:
          'https://tse4.mm.bing.net/th/id/OIP.0SDoAANiAP6UoZPUrt3UqwHaEN?w=252&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '民事起訴狀與委任律師書狀（108年度訴字第219號...）',
    ),
    CaseImage(
      url:
          'https://tse4.mm.bing.net/th/id/OIP.FVJkOeXgZVSaQPF4GFSr2QHaD8?w=89&h=90&c=1&rs=1&qlt=70&r=0&o=7&pid=InlineBlock&rm=3',
      source: '法院準備程序筆錄簽名欄位（108年度訴字第219號...）',
    ),
    CaseImage(
      url:
          'https://tse4.mm.bing.net/th/id/OIP.zbbKZ0Bh_CpP6eZamtCRjwHaE9?w=179&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '司法院大法官憲法法庭開庭現場（108年度訴字第219號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.M1ZTFf8JShiFpHtxNdAuTwHaEz?w=227&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '最高法院民事庭開庭大門外觀（108年度訴字第219號...）',
    ),
    CaseImage(
      url:
          'https://tse1.mm.bing.net/th/id/OIP.kgAAgTi1mrNURfP1WvpUNQHaFj?w=89&h=90&c=1&rs=1&qlt=70&r=0&o=7&pid=InlineBlock&rm=3',
      source: '法學文獻與期刊論文引用頁面（108年度訴字第219號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.WVO6tR5BzOgw0oglmH02OAHaEP?w=208&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '中華民國六法全書民法債編法條（108年度訴字第219號...）',
    ),
    CaseImage(
      url:
          'https://tse1.mm.bing.net/th/id/OIP.fEDFLQLHjS3QuE4bQLgBvQHaE8?w=229&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '民事訴訟小額程序開庭流程圖（108年度訴字第219號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.EQboFDqbqWRcR8PTOr3wQwHaDn?w=297&h=171&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '判決確定證明書與執行憑證抄本（108年度訴字第219號...）',
    )
  ],
  'case-120': const [
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.FxsIbUCjMd4IlOEskxShJgHaFj?w=89&h=89&c=1&rs=1&qlt=70&r=0&o=7&pid=InlineBlock&rm=3',
      source: '【本案卷宗封面照片】法庭審判司法天平現場照片',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.Xt1C-7meX374BAg86KC6LwHaE8?w=89&h=89&c=1&rs=1&qlt=70&r=0&o=7&pid=InlineBlock&rm=3',
      source: '最高法院司法卷宗圖書館（109年度訴字第220號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.EQboFDqbqWRcR8PTOr3wQwHaDn?w=297&h=171&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '法規沿革與憲法判決法典（109年度訴字第220號...）',
    ),
    CaseImage(
      url:
          'https://tse3.mm.bing.net/th/id/OIP.RHmdPX6UGcKBDnAmC1DuxQHaE7?w=215&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '本案訴訟卷宗外觀及編號（109年度訴字第220號...）',
    ),
    CaseImage(
      url:
          'https://tse1.mm.bing.net/th/id/OIP.fEDFLQLHjS3QuE4bQLgBvQHaE8?w=229&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '地方法院簡易庭外觀與開庭公告（109年度訴字第220號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.wXoezXbxYh3d5XAsPQA1mwHaE8?w=193&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '當事人提出之訴狀首頁抄本（109年度訴字第220號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.jgOpaPncHSivavrOTSAXLgHaE8?w=232&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '司法裁判書電子檔之判決主文（109年度訴字第220號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.CR03_AAGv7DichRpWnF7NQHaE7?w=233&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '民事起訴狀與委任律師書狀（109年度訴字第220號...）',
    ),
    CaseImage(
      url:
          'https://tse4.mm.bing.net/th/id/OIP.0SDoAANiAP6UoZPUrt3UqwHaEN?w=252&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '法院準備程序筆錄簽名欄位（109年度訴字第220號...）',
    ),
    CaseImage(
      url:
          'https://tse1.mm.bing.net/th/id/OIP.kgAAgTi1mrNURfP1WvpUNQHaFj?w=89&h=90&c=1&rs=1&qlt=70&r=0&o=7&pid=InlineBlock&rm=3',
      source: '司法院大法官憲法法庭開庭現場（109年度訴字第220號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.M1ZTFf8JShiFpHtxNdAuTwHaEz?w=227&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '最高法院民事庭開庭大門外觀（109年度訴字第220號...）',
    ),
    CaseImage(
      url:
          'https://tse4.mm.bing.net/th/id/OIP.Q7FEnIHkrd6q9Jmu1GiKkwHaEj?w=248&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '法學文獻與期刊論文引用頁面（109年度訴字第220號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.22mIh8FxQ1xTrLJEOF-vTgHaEO?w=89&h=89&c=1&rs=1&qlt=70&r=0&o=7&pid=InlineBlock&rm=3',
      source: '中華民國六法全書民法債編法條（109年度訴字第220號...）',
    ),
    CaseImage(
      url:
          'https://tse3.mm.bing.net/th/id/OIP.rgvPoDUIQa-Gb56tJrl6sgHaEO?w=89&h=90&c=1&rs=1&qlt=70&r=0&o=7&pid=InlineBlock&rm=3',
      source: '民事訴訟小額程序開庭流程圖（109年度訴字第220號...）',
    ),
    CaseImage(
      url:
          'https://tse1.mm.bing.net/th/id/OIP.xExaObj3A3nV3olc0K1gmwHaEJ?w=263&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '判決確定證明書與執行憑證抄本（109年度訴字第220號...）',
    )
  ],
  'case-121': const [
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.EQboFDqbqWRcR8PTOr3wQwHaDn?w=297&h=171&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '【本案卷宗封面照片】法庭審判司法天平現場照片',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.FxsIbUCjMd4IlOEskxShJgHaFj?w=89&h=89&c=1&rs=1&qlt=70&r=0&o=7&pid=InlineBlock&rm=3',
      source: '最高法院司法卷宗圖書館（110年度訴字第221號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.WVO6tR5BzOgw0oglmH02OAHaEP?w=208&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '法規沿革與憲法判決法典（110年度訴字第221號...）',
    ),
    CaseImage(
      url:
          'https://tse4.mm.bing.net/th/id/OIP.0SDoAANiAP6UoZPUrt3UqwHaEN?w=252&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '本案訴訟卷宗外觀及編號（110年度訴字第221號...）',
    ),
    CaseImage(
      url:
          'https://tse3.mm.bing.net/th/id/OIP.rgvPoDUIQa-Gb56tJrl6sgHaEO?w=89&h=90&c=1&rs=1&qlt=70&r=0&o=7&pid=InlineBlock&rm=3',
      source: '地方法院簡易庭外觀與開庭公告（110年度訴字第221號...）',
    ),
    CaseImage(
      url:
          'https://tse4.mm.bing.net/th/id/OIP.zbbKZ0Bh_CpP6eZamtCRjwHaE9?w=179&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '當事人提出之訴狀首頁抄本（110年度訴字第221號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.Xt1C-7meX374BAg86KC6LwHaE8?w=89&h=89&c=1&rs=1&qlt=70&r=0&o=7&pid=InlineBlock&rm=3',
      source: '司法裁判書電子檔之判決主文（110年度訴字第221號...）',
    ),
    CaseImage(
      url:
          'https://tse4.mm.bing.net/th/id/OIP.BpIJPdGnK-nMpGs5B9306AHaFe?w=206&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '民事起訴狀與委任律師書狀（110年度訴字第221號...）',
    ),
    CaseImage(
      url:
          'https://tse3.mm.bing.net/th/id/OIP.RHmdPX6UGcKBDnAmC1DuxQHaE7?w=215&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '法院準備程序筆錄簽名欄位（110年度訴字第221號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.22mIh8FxQ1xTrLJEOF-vTgHaEO?w=89&h=89&c=1&rs=1&qlt=70&r=0&o=7&pid=InlineBlock&rm=3',
      source: '司法院大法官憲法法庭開庭現場（110年度訴字第221號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.jgOpaPncHSivavrOTSAXLgHaE8?w=232&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '最高法院民事庭開庭大門外觀（110年度訴字第221號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.M1ZTFf8JShiFpHtxNdAuTwHaEz?w=227&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '法學文獻與期刊論文引用頁面（110年度訴字第221號...）',
    ),
    CaseImage(
      url:
          'https://tse4.mm.bing.net/th/id/OIP.Q7FEnIHkrd6q9Jmu1GiKkwHaEj?w=248&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '中華民國六法全書民法債編法條（110年度訴字第221號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.6_z7cGk1TU-RBgQM3tsqZQHaE8?w=221&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '民事訴訟小額程序開庭流程圖（110年度訴字第221號...）',
    ),
    CaseImage(
      url:
          'https://tse3.mm.bing.net/th/id/OIP.8vGwbgtGBjFRl90_W32HlwHaE7?w=232&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '判決確定證明書與執行憑證抄本（110年度訴字第221號...）',
    )
  ],
  'case-122': const [
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.CR03_AAGv7DichRpWnF7NQHaE7?w=233&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '【本案卷宗封面照片】法庭審判司法天平現場照片',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.M1ZTFf8JShiFpHtxNdAuTwHaEz?w=227&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '最高法院司法卷宗圖書館（108年度訴字第222號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.Xt1C-7meX374BAg86KC6LwHaE8?w=89&h=89&c=1&rs=1&qlt=70&r=0&o=7&pid=InlineBlock&rm=3',
      source: '法規沿革與憲法判決法典（108年度訴字第222號...）',
    ),
    CaseImage(
      url:
          'https://tse3.mm.bing.net/th/id/OIP.8vGwbgtGBjFRl90_W32HlwHaE7?w=232&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '本案訴訟卷宗外觀及編號（108年度訴字第222號...）',
    ),
    CaseImage(
      url:
          'https://tse1.mm.bing.net/th/id/OIP.fEDFLQLHjS3QuE4bQLgBvQHaE8?w=229&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '地方法院簡易庭外觀與開庭公告（108年度訴字第222號...）',
    ),
    CaseImage(
      url:
          'https://tse4.mm.bing.net/th/id/OIP.0SDoAANiAP6UoZPUrt3UqwHaEN?w=252&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '當事人提出之訴狀首頁抄本（108年度訴字第222號...）',
    ),
    CaseImage(
      url:
          'https://tse4.mm.bing.net/th/id/OIP.BpIJPdGnK-nMpGs5B9306AHaFe?w=206&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '司法裁判書電子檔之判決主文（108年度訴字第222號...）',
    ),
    CaseImage(
      url:
          'https://tse1.mm.bing.net/th/id/OIP.xExaObj3A3nV3olc0K1gmwHaEJ?w=263&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '民事起訴狀與委任律師書狀（108年度訴字第222號...）',
    ),
    CaseImage(
      url:
          'https://tse1.mm.bing.net/th/id/OIP.kgAAgTi1mrNURfP1WvpUNQHaFj?w=89&h=90&c=1&rs=1&qlt=70&r=0&o=7&pid=InlineBlock&rm=3',
      source: '法院準備程序筆錄簽名欄位（108年度訴字第222號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.jgOpaPncHSivavrOTSAXLgHaE8?w=232&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '司法院大法官憲法法庭開庭現場（108年度訴字第222號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.FxsIbUCjMd4IlOEskxShJgHaFj?w=89&h=89&c=1&rs=1&qlt=70&r=0&o=7&pid=InlineBlock&rm=3',
      source: '最高法院民事庭開庭大門外觀（108年度訴字第222號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.22mIh8FxQ1xTrLJEOF-vTgHaEO?w=89&h=89&c=1&rs=1&qlt=70&r=0&o=7&pid=InlineBlock&rm=3',
      source: '法學文獻與期刊論文引用頁面（108年度訴字第222號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.wXoezXbxYh3d5XAsPQA1mwHaE8?w=193&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '中華民國六法全書民法債編法條（108年度訴字第222號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.EQboFDqbqWRcR8PTOr3wQwHaDn?w=297&h=171&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '民事訴訟小額程序開庭流程圖（108年度訴字第222號...）',
    ),
    CaseImage(
      url:
          'https://tse3.mm.bing.net/th/id/OIP.rgvPoDUIQa-Gb56tJrl6sgHaEO?w=89&h=90&c=1&rs=1&qlt=70&r=0&o=7&pid=InlineBlock&rm=3',
      source: '判決確定證明書與執行憑證抄本（108年度訴字第222號...）',
    )
  ],
  'case-123': const [
    CaseImage(
      url:
          'https://tse3.mm.bing.net/th/id/OIP.RHmdPX6UGcKBDnAmC1DuxQHaE7?w=215&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '【本案卷宗封面照片】法庭審判司法天平現場照片',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.CR03_AAGv7DichRpWnF7NQHaE7?w=233&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '最高法院司法卷宗圖書館（106年度訴字第223號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.22mIh8FxQ1xTrLJEOF-vTgHaEO?w=89&h=89&c=1&rs=1&qlt=70&r=0&o=7&pid=InlineBlock&rm=3',
      source: '法規沿革與憲法判決法典（106年度訴字第223號...）',
    ),
    CaseImage(
      url:
          'https://tse4.mm.bing.net/th/id/OIP.0SDoAANiAP6UoZPUrt3UqwHaEN?w=252&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '本案訴訟卷宗外觀及編號（106年度訴字第223號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.EQboFDqbqWRcR8PTOr3wQwHaDn?w=297&h=171&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '地方法院簡易庭外觀與開庭公告（106年度訴字第223號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.6_z7cGk1TU-RBgQM3tsqZQHaE8?w=221&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '當事人提出之訴狀首頁抄本（106年度訴字第223號...）',
    ),
    CaseImage(
      url:
          'https://tse1.mm.bing.net/th/id/OIP.xExaObj3A3nV3olc0K1gmwHaEJ?w=263&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '司法裁判書電子檔之判決主文（106年度訴字第223號...）',
    ),
    CaseImage(
      url:
          'https://tse3.mm.bing.net/th/id/OIP.rgvPoDUIQa-Gb56tJrl6sgHaEO?w=89&h=90&c=1&rs=1&qlt=70&r=0&o=7&pid=InlineBlock&rm=3',
      source: '民事起訴狀與委任律師書狀（106年度訴字第223號...）',
    ),
    CaseImage(
      url:
          'https://tse4.mm.bing.net/th/id/OIP.Q7FEnIHkrd6q9Jmu1GiKkwHaEj?w=248&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '法院準備程序筆錄簽名欄位（106年度訴字第223號...）',
    ),
    CaseImage(
      url:
          'https://tse1.mm.bing.net/th/id/OIP.fEDFLQLHjS3QuE4bQLgBvQHaE8?w=229&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '司法院大法官憲法法庭開庭現場（106年度訴字第223號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.M1ZTFf8JShiFpHtxNdAuTwHaEz?w=227&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '最高法院民事庭開庭大門外觀（106年度訴字第223號...）',
    ),
    CaseImage(
      url:
          'https://tse4.mm.bing.net/th/id/OIP.zbbKZ0Bh_CpP6eZamtCRjwHaE9?w=179&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '法學文獻與期刊論文引用頁面（106年度訴字第223號...）',
    ),
    CaseImage(
      url:
          'https://tse3.mm.bing.net/th/id/OIP.FzL2M5zkVz2nUbqZg7Qe-QHaE7?w=215&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '中華民國六法全書民法債編法條（106年度訴字第223號...）',
    ),
    CaseImage(
      url:
          'https://tse3.mm.bing.net/th/id/OIP.8vGwbgtGBjFRl90_W32HlwHaE7?w=232&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '民事訴訟小額程序開庭流程圖（106年度訴字第223號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.WVO6tR5BzOgw0oglmH02OAHaEP?w=208&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '判決確定證明書與執行憑證抄本（106年度訴字第223號...）',
    )
  ],
  'case-124': const [
    CaseImage(
      url:
          'https://tse4.mm.bing.net/th/id/OIP.Q7FEnIHkrd6q9Jmu1GiKkwHaEj?w=248&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '【本案卷宗封面照片】法庭審判司法天平現場照片',
    ),
    CaseImage(
      url:
          'https://tse3.mm.bing.net/th/id/OIP.FzL2M5zkVz2nUbqZg7Qe-QHaE7?w=215&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '最高法院司法卷宗圖書館（109年度訴字第224號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.Xt1C-7meX374BAg86KC6LwHaE8?w=89&h=89&c=1&rs=1&qlt=70&r=0&o=7&pid=InlineBlock&rm=3',
      source: '法規沿革與憲法判決法典（109年度訴字第224號...）',
    ),
    CaseImage(
      url:
          'https://tse3.mm.bing.net/th/id/OIP.rgvPoDUIQa-Gb56tJrl6sgHaEO?w=89&h=90&c=1&rs=1&qlt=70&r=0&o=7&pid=InlineBlock&rm=3',
      source: '本案訴訟卷宗外觀及編號（109年度訴字第224號...）',
    ),
    CaseImage(
      url:
          'https://tse4.mm.bing.net/th/id/OIP.BpIJPdGnK-nMpGs5B9306AHaFe?w=206&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '地方法院簡易庭外觀與開庭公告（109年度訴字第224號...）',
    ),
    CaseImage(
      url:
          'https://tse4.mm.bing.net/th/id/OIP.0SDoAANiAP6UoZPUrt3UqwHaEN?w=252&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '當事人提出之訴狀首頁抄本（109年度訴字第224號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.EQboFDqbqWRcR8PTOr3wQwHaDn?w=297&h=171&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '司法裁判書電子檔之判決主文（109年度訴字第224號...）',
    ),
    CaseImage(
      url:
          'https://tse4.mm.bing.net/th/id/OIP.zbbKZ0Bh_CpP6eZamtCRjwHaE9?w=179&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '民事起訴狀與委任律師書狀（109年度訴字第224號...）',
    ),
    CaseImage(
      url:
          'https://tse4.mm.bing.net/th/id/OIP.FVJkOeXgZVSaQPF4GFSr2QHaD8?w=89&h=90&c=1&rs=1&qlt=70&r=0&o=7&pid=InlineBlock&rm=3',
      source: '法院準備程序筆錄簽名欄位（109年度訴字第224號...）',
    ),
    CaseImage(
      url:
          'https://tse3.mm.bing.net/th/id/OIP.8vGwbgtGBjFRl90_W32HlwHaE7?w=232&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '司法院大法官憲法法庭開庭現場（109年度訴字第224號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.CR03_AAGv7DichRpWnF7NQHaE7?w=233&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '最高法院民事庭開庭大門外觀（109年度訴字第224號...）',
    ),
    CaseImage(
      url:
          'https://tse1.mm.bing.net/th/id/OIP.xExaObj3A3nV3olc0K1gmwHaEJ?w=263&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '法學文獻與期刊論文引用頁面（109年度訴字第224號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.wXoezXbxYh3d5XAsPQA1mwHaE8?w=193&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '中華民國六法全書民法債編法條（109年度訴字第224號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.M1ZTFf8JShiFpHtxNdAuTwHaEz?w=227&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '民事訴訟小額程序開庭流程圖（109年度訴字第224號...）',
    ),
    CaseImage(
      url:
          'https://tse1.mm.bing.net/th/id/OIP.kgAAgTi1mrNURfP1WvpUNQHaFj?w=89&h=90&c=1&rs=1&qlt=70&r=0&o=7&pid=InlineBlock&rm=3',
      source: '判決確定證明書與執行憑證抄本（109年度訴字第224號...）',
    )
  ],
  'case-125': const [
    CaseImage(
      url:
          'https://tse3.mm.bing.net/th/id/OIP.8vGwbgtGBjFRl90_W32HlwHaE7?w=232&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '【本案卷宗封面照片】法庭審判司法天平現場照片',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.FxsIbUCjMd4IlOEskxShJgHaFj?w=89&h=89&c=1&rs=1&qlt=70&r=0&o=7&pid=InlineBlock&rm=3',
      source: '最高法院司法卷宗圖書館（108年度訴字第225號...）',
    ),
    CaseImage(
      url:
          'https://tse4.mm.bing.net/th/id/OIP.BpIJPdGnK-nMpGs5B9306AHaFe?w=206&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '法規沿革與憲法判決法典（108年度訴字第225號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.22mIh8FxQ1xTrLJEOF-vTgHaEO?w=89&h=89&c=1&rs=1&qlt=70&r=0&o=7&pid=InlineBlock&rm=3',
      source: '本案訴訟卷宗外觀及編號（108年度訴字第225號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.EQboFDqbqWRcR8PTOr3wQwHaDn?w=297&h=171&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '地方法院簡易庭外觀與開庭公告（108年度訴字第225號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.6_z7cGk1TU-RBgQM3tsqZQHaE8?w=221&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '當事人提出之訴狀首頁抄本（108年度訴字第225號...）',
    ),
    CaseImage(
      url:
          'https://tse3.mm.bing.net/th/id/OIP.RHmdPX6UGcKBDnAmC1DuxQHaE7?w=215&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '司法裁判書電子檔之判決主文（108年度訴字第225號...）',
    ),
    CaseImage(
      url:
          'https://tse1.mm.bing.net/th/id/OIP.fEDFLQLHjS3QuE4bQLgBvQHaE8?w=229&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '民事起訴狀與委任律師書狀（108年度訴字第225號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.jgOpaPncHSivavrOTSAXLgHaE8?w=232&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '法院準備程序筆錄簽名欄位（108年度訴字第225號...）',
    ),
    CaseImage(
      url:
          'https://tse4.mm.bing.net/th/id/OIP.Q7FEnIHkrd6q9Jmu1GiKkwHaEj?w=248&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '司法院大法官憲法法庭開庭現場（108年度訴字第225號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.M1ZTFf8JShiFpHtxNdAuTwHaEz?w=227&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '最高法院民事庭開庭大門外觀（108年度訴字第225號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.CR03_AAGv7DichRpWnF7NQHaE7?w=233&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '法學文獻與期刊論文引用頁面（108年度訴字第225號...）',
    ),
    CaseImage(
      url:
          'https://tse4.mm.bing.net/th/id/OIP.zbbKZ0Bh_CpP6eZamtCRjwHaE9?w=179&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '中華民國六法全書民法債編法條（108年度訴字第225號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.Xt1C-7meX374BAg86KC6LwHaE8?w=89&h=89&c=1&rs=1&qlt=70&r=0&o=7&pid=InlineBlock&rm=3',
      source: '民事訴訟小額程序開庭流程圖（108年度訴字第225號...）',
    ),
    CaseImage(
      url:
          'https://tse3.mm.bing.net/th/id/OIP.rgvPoDUIQa-Gb56tJrl6sgHaEO?w=89&h=90&c=1&rs=1&qlt=70&r=0&o=7&pid=InlineBlock&rm=3',
      source: '判決確定證明書與執行憑證抄本（108年度訴字第225號...）',
    )
  ],
  'case-126': const [
    CaseImage(
      url:
          'https://tse4.mm.bing.net/th/id/OIP.Q7FEnIHkrd6q9Jmu1GiKkwHaEj?w=248&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '【本案卷宗封面照片】法庭審判司法天平現場照片',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.wXoezXbxYh3d5XAsPQA1mwHaE8?w=193&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '最高法院司法卷宗圖書館（109年度訴字第226號...）',
    ),
    CaseImage(
      url:
          'https://tse1.mm.bing.net/th/id/OIP.kgAAgTi1mrNURfP1WvpUNQHaFj?w=89&h=90&c=1&rs=1&qlt=70&r=0&o=7&pid=InlineBlock&rm=3',
      source: '法規沿革與憲法判決法典（109年度訴字第226號...）',
    ),
    CaseImage(
      url:
          'https://tse4.mm.bing.net/th/id/OIP.FVJkOeXgZVSaQPF4GFSr2QHaD8?w=89&h=90&c=1&rs=1&qlt=70&r=0&o=7&pid=InlineBlock&rm=3',
      source: '本案訴訟卷宗外觀及編號（109年度訴字第226號...）',
    ),
    CaseImage(
      url:
          'https://tse1.mm.bing.net/th/id/OIP.xExaObj3A3nV3olc0K1gmwHaEJ?w=263&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '地方法院簡易庭外觀與開庭公告（109年度訴字第226號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.jgOpaPncHSivavrOTSAXLgHaE8?w=232&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '當事人提出之訴狀首頁抄本（109年度訴字第226號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.FxsIbUCjMd4IlOEskxShJgHaFj?w=89&h=89&c=1&rs=1&qlt=70&r=0&o=7&pid=InlineBlock&rm=3',
      source: '司法裁判書電子檔之判決主文（109年度訴字第226號...）',
    ),
    CaseImage(
      url:
          'https://tse3.mm.bing.net/th/id/OIP.rgvPoDUIQa-Gb56tJrl6sgHaEO?w=89&h=90&c=1&rs=1&qlt=70&r=0&o=7&pid=InlineBlock&rm=3',
      source: '民事起訴狀與委任律師書狀（109年度訴字第226號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.22mIh8FxQ1xTrLJEOF-vTgHaEO?w=89&h=89&c=1&rs=1&qlt=70&r=0&o=7&pid=InlineBlock&rm=3',
      source: '法院準備程序筆錄簽名欄位（109年度訴字第226號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.6_z7cGk1TU-RBgQM3tsqZQHaE8?w=221&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '司法院大法官憲法法庭開庭現場（109年度訴字第226號...）',
    ),
    CaseImage(
      url:
          'https://tse3.mm.bing.net/th/id/OIP.RHmdPX6UGcKBDnAmC1DuxQHaE7?w=215&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '最高法院民事庭開庭大門外觀（109年度訴字第226號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.WVO6tR5BzOgw0oglmH02OAHaEP?w=208&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '法學文獻與期刊論文引用頁面（109年度訴字第226號...）',
    ),
    CaseImage(
      url:
          'https://tse4.mm.bing.net/th/id/OIP.BpIJPdGnK-nMpGs5B9306AHaFe?w=206&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '中華民國六法全書民法債編法條（109年度訴字第226號...）',
    ),
    CaseImage(
      url:
          'https://tse3.mm.bing.net/th/id/OIP.8vGwbgtGBjFRl90_W32HlwHaE7?w=232&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '民事訴訟小額程序開庭流程圖（109年度訴字第226號...）',
    ),
    CaseImage(
      url:
          'https://tse3.mm.bing.net/th/id/OIP.FzL2M5zkVz2nUbqZg7Qe-QHaE7?w=215&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '判決確定證明書與執行憑證抄本（109年度訴字第226號...）',
    )
  ],
  'case-127': const [
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.wXoezXbxYh3d5XAsPQA1mwHaE8?w=193&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '【本案卷宗封面照片】法庭審判司法天平現場照片',
    ),
    CaseImage(
      url:
          'https://tse1.mm.bing.net/th/id/OIP.kgAAgTi1mrNURfP1WvpUNQHaFj?w=89&h=90&c=1&rs=1&qlt=70&r=0&o=7&pid=InlineBlock&rm=3',
      source: '最高法院司法卷宗圖書館（107年度訴字第227號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.WVO6tR5BzOgw0oglmH02OAHaEP?w=208&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '法規沿革與憲法判決法典（107年度訴字第227號...）',
    ),
    CaseImage(
      url:
          'https://tse4.mm.bing.net/th/id/OIP.zbbKZ0Bh_CpP6eZamtCRjwHaE9?w=179&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '本案訴訟卷宗外觀及編號（107年度訴字第227號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.Xt1C-7meX374BAg86KC6LwHaE8?w=89&h=89&c=1&rs=1&qlt=70&r=0&o=7&pid=InlineBlock&rm=3',
      source: '地方法院簡易庭外觀與開庭公告（107年度訴字第227號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.22mIh8FxQ1xTrLJEOF-vTgHaEO?w=89&h=89&c=1&rs=1&qlt=70&r=0&o=7&pid=InlineBlock&rm=3',
      source: '當事人提出之訴狀首頁抄本（107年度訴字第227號...）',
    ),
    CaseImage(
      url:
          'https://tse3.mm.bing.net/th/id/OIP.RHmdPX6UGcKBDnAmC1DuxQHaE7?w=215&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '司法裁判書電子檔之判決主文（107年度訴字第227號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.M1ZTFf8JShiFpHtxNdAuTwHaEz?w=227&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '民事起訴狀與委任律師書狀（107年度訴字第227號...）',
    ),
    CaseImage(
      url:
          'https://tse4.mm.bing.net/th/id/OIP.0SDoAANiAP6UoZPUrt3UqwHaEN?w=252&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '法院準備程序筆錄簽名欄位（107年度訴字第227號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.FxsIbUCjMd4IlOEskxShJgHaFj?w=89&h=89&c=1&rs=1&qlt=70&r=0&o=7&pid=InlineBlock&rm=3',
      source: '司法院大法官憲法法庭開庭現場（107年度訴字第227號...）',
    ),
    CaseImage(
      url:
          'https://tse3.mm.bing.net/th/id/OIP.8vGwbgtGBjFRl90_W32HlwHaE7?w=232&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '最高法院民事庭開庭大門外觀（107年度訴字第227號...）',
    ),
    CaseImage(
      url:
          'https://tse4.mm.bing.net/th/id/OIP.Q7FEnIHkrd6q9Jmu1GiKkwHaEj?w=248&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '法學文獻與期刊論文引用頁面（107年度訴字第227號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.EQboFDqbqWRcR8PTOr3wQwHaDn?w=297&h=171&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '中華民國六法全書民法債編法條（107年度訴字第227號...）',
    ),
    CaseImage(
      url:
          'https://tse4.mm.bing.net/th/id/OIP.FVJkOeXgZVSaQPF4GFSr2QHaD8?w=89&h=90&c=1&rs=1&qlt=70&r=0&o=7&pid=InlineBlock&rm=3',
      source: '民事訴訟小額程序開庭流程圖（107年度訴字第227號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.jgOpaPncHSivavrOTSAXLgHaE8?w=232&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '判決確定證明書與執行憑證抄本（107年度訴字第227號...）',
    )
  ],
  'case-128': const [
    CaseImage(
      url:
          'https://tse1.mm.bing.net/th/id/OIP.xExaObj3A3nV3olc0K1gmwHaEJ?w=263&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '【本案卷宗封面照片】法庭審判司法天平現場照片',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.22mIh8FxQ1xTrLJEOF-vTgHaEO?w=89&h=89&c=1&rs=1&qlt=70&r=0&o=7&pid=InlineBlock&rm=3',
      source: '最高法院司法卷宗圖書館（110年度訴字第228號...）',
    ),
    CaseImage(
      url:
          'https://tse4.mm.bing.net/th/id/OIP.FVJkOeXgZVSaQPF4GFSr2QHaD8?w=89&h=90&c=1&rs=1&qlt=70&r=0&o=7&pid=InlineBlock&rm=3',
      source: '法規沿革與憲法判決法典（110年度訴字第228號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.WVO6tR5BzOgw0oglmH02OAHaEP?w=208&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '本案訴訟卷宗外觀及編號（110年度訴字第228號...）',
    ),
    CaseImage(
      url:
          'https://tse3.mm.bing.net/th/id/OIP.FzL2M5zkVz2nUbqZg7Qe-QHaE7?w=215&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '地方法院簡易庭外觀與開庭公告（110年度訴字第228號...）',
    ),
    CaseImage(
      url:
          'https://tse4.mm.bing.net/th/id/OIP.0SDoAANiAP6UoZPUrt3UqwHaEN?w=252&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '當事人提出之訴狀首頁抄本（110年度訴字第228號...）',
    ),
    CaseImage(
      url:
          'https://tse3.mm.bing.net/th/id/OIP.RHmdPX6UGcKBDnAmC1DuxQHaE7?w=215&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '司法裁判書電子檔之判決主文（110年度訴字第228號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.EQboFDqbqWRcR8PTOr3wQwHaDn?w=297&h=171&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '民事起訴狀與委任律師書狀（110年度訴字第228號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.CR03_AAGv7DichRpWnF7NQHaE7?w=233&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '法院準備程序筆錄簽名欄位（110年度訴字第228號...）',
    ),
    CaseImage(
      url:
          'https://tse4.mm.bing.net/th/id/OIP.Q7FEnIHkrd6q9Jmu1GiKkwHaEj?w=248&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '司法院大法官憲法法庭開庭現場（110年度訴字第228號...）',
    ),
    CaseImage(
      url:
          'https://tse4.mm.bing.net/th/id/OIP.BpIJPdGnK-nMpGs5B9306AHaFe?w=206&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '最高法院民事庭開庭大門外觀（110年度訴字第228號...）',
    ),
    CaseImage(
      url:
          'https://tse3.mm.bing.net/th/id/OIP.8vGwbgtGBjFRl90_W32HlwHaE7?w=232&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '法學文獻與期刊論文引用頁面（110年度訴字第228號...）',
    ),
    CaseImage(
      url:
          'https://tse1.mm.bing.net/th/id/OIP.kgAAgTi1mrNURfP1WvpUNQHaFj?w=89&h=90&c=1&rs=1&qlt=70&r=0&o=7&pid=InlineBlock&rm=3',
      source: '中華民國六法全書民法債編法條（110年度訴字第228號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.jgOpaPncHSivavrOTSAXLgHaE8?w=232&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '民事訴訟小額程序開庭流程圖（110年度訴字第228號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.Xt1C-7meX374BAg86KC6LwHaE8?w=89&h=89&c=1&rs=1&qlt=70&r=0&o=7&pid=InlineBlock&rm=3',
      source: '判決確定證明書與執行憑證抄本（110年度訴字第228號...）',
    )
  ],
  'case-129': const [
    CaseImage(
      url:
          'https://tse3.mm.bing.net/th/id/OIP.rgvPoDUIQa-Gb56tJrl6sgHaEO?w=89&h=90&c=1&rs=1&qlt=70&r=0&o=7&pid=InlineBlock&rm=3',
      source: '【本案卷宗封面照片】法庭審判司法天平現場照片',
    ),
    CaseImage(
      url:
          'https://tse3.mm.bing.net/th/id/OIP.FzL2M5zkVz2nUbqZg7Qe-QHaE7?w=215&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '最高法院司法卷宗圖書館（108年度訴字第229號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.EQboFDqbqWRcR8PTOr3wQwHaDn?w=297&h=171&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '法規沿革與憲法判決法典（108年度訴字第229號...）',
    ),
    CaseImage(
      url:
          'https://tse3.mm.bing.net/th/id/OIP.RHmdPX6UGcKBDnAmC1DuxQHaE7?w=215&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '本案訴訟卷宗外觀及編號（108年度訴字第229號...）',
    ),
    CaseImage(
      url:
          'https://tse4.mm.bing.net/th/id/OIP.BpIJPdGnK-nMpGs5B9306AHaFe?w=206&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '地方法院簡易庭外觀與開庭公告（108年度訴字第229號...）',
    ),
    CaseImage(
      url:
          'https://tse4.mm.bing.net/th/id/OIP.FVJkOeXgZVSaQPF4GFSr2QHaD8?w=89&h=90&c=1&rs=1&qlt=70&r=0&o=7&pid=InlineBlock&rm=3',
      source: '當事人提出之訴狀首頁抄本（108年度訴字第229號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.FxsIbUCjMd4IlOEskxShJgHaFj?w=89&h=89&c=1&rs=1&qlt=70&r=0&o=7&pid=InlineBlock&rm=3',
      source: '司法裁判書電子檔之判決主文（108年度訴字第229號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.WVO6tR5BzOgw0oglmH02OAHaEP?w=208&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '民事起訴狀與委任律師書狀（108年度訴字第229號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.22mIh8FxQ1xTrLJEOF-vTgHaEO?w=89&h=89&c=1&rs=1&qlt=70&r=0&o=7&pid=InlineBlock&rm=3',
      source: '法院準備程序筆錄簽名欄位（108年度訴字第229號...）',
    ),
    CaseImage(
      url:
          'https://tse1.mm.bing.net/th/id/OIP.xExaObj3A3nV3olc0K1gmwHaEJ?w=263&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '司法院大法官憲法法庭開庭現場（108年度訴字第229號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.M1ZTFf8JShiFpHtxNdAuTwHaEz?w=227&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '最高法院民事庭開庭大門外觀（108年度訴字第229號...）',
    ),
    CaseImage(
      url:
          'https://tse4.mm.bing.net/th/id/OIP.Q7FEnIHkrd6q9Jmu1GiKkwHaEj?w=248&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '法學文獻與期刊論文引用頁面（108年度訴字第229號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.jgOpaPncHSivavrOTSAXLgHaE8?w=232&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '中華民國六法全書民法債編法條（108年度訴字第229號...）',
    ),
    CaseImage(
      url:
          'https://tse3.mm.bing.net/th/id/OIP.8vGwbgtGBjFRl90_W32HlwHaE7?w=232&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '民事訴訟小額程序開庭流程圖（108年度訴字第229號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.wXoezXbxYh3d5XAsPQA1mwHaE8?w=193&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '判決確定證明書與執行憑證抄本（108年度訴字第229號...）',
    )
  ],
  'case-130': const [
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.Xt1C-7meX374BAg86KC6LwHaE8?w=89&h=89&c=1&rs=1&qlt=70&r=0&o=7&pid=InlineBlock&rm=3',
      source: '【本案卷宗封面照片】法庭審判司法天平現場照片',
    ),
    CaseImage(
      url:
          'https://tse4.mm.bing.net/th/id/OIP.0SDoAANiAP6UoZPUrt3UqwHaEN?w=252&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '最高法院司法卷宗圖書館（109年度訴字第230號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.CR03_AAGv7DichRpWnF7NQHaE7?w=233&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '法規沿革與憲法判決法典（109年度訴字第230號...）',
    ),
    CaseImage(
      url:
          'https://tse4.mm.bing.net/th/id/OIP.BpIJPdGnK-nMpGs5B9306AHaFe?w=206&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '本案訴訟卷宗外觀及編號（109年度訴字第230號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.FxsIbUCjMd4IlOEskxShJgHaFj?w=89&h=89&c=1&rs=1&qlt=70&r=0&o=7&pid=InlineBlock&rm=3',
      source: '地方法院簡易庭外觀與開庭公告（109年度訴字第230號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.6_z7cGk1TU-RBgQM3tsqZQHaE8?w=221&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '當事人提出之訴狀首頁抄本（109年度訴字第230號...）',
    ),
    CaseImage(
      url:
          'https://tse3.mm.bing.net/th/id/OIP.FzL2M5zkVz2nUbqZg7Qe-QHaE7?w=215&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '司法裁判書電子檔之判決主文（109年度訴字第230號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.WVO6tR5BzOgw0oglmH02OAHaEP?w=208&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '民事起訴狀與委任律師書狀（109年度訴字第230號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.22mIh8FxQ1xTrLJEOF-vTgHaEO?w=89&h=89&c=1&rs=1&qlt=70&r=0&o=7&pid=InlineBlock&rm=3',
      source: '法院準備程序筆錄簽名欄位（109年度訴字第230號...）',
    ),
    CaseImage(
      url:
          'https://tse4.mm.bing.net/th/id/OIP.Q7FEnIHkrd6q9Jmu1GiKkwHaEj?w=248&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '司法院大法官憲法法庭開庭現場（109年度訴字第230號...）',
    ),
    CaseImage(
      url:
          'https://tse4.mm.bing.net/th/id/OIP.zbbKZ0Bh_CpP6eZamtCRjwHaE9?w=179&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '最高法院民事庭開庭大門外觀（109年度訴字第230號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.M1ZTFf8JShiFpHtxNdAuTwHaEz?w=227&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '法學文獻與期刊論文引用頁面（109年度訴字第230號...）',
    ),
    CaseImage(
      url:
          'https://tse1.mm.bing.net/th/id/OIP.xExaObj3A3nV3olc0K1gmwHaEJ?w=263&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '中華民國六法全書民法債編法條（109年度訴字第230號...）',
    ),
    CaseImage(
      url:
          'https://tse4.mm.bing.net/th/id/OIP.FVJkOeXgZVSaQPF4GFSr2QHaD8?w=89&h=90&c=1&rs=1&qlt=70&r=0&o=7&pid=InlineBlock&rm=3',
      source: '民事訴訟小額程序開庭流程圖（109年度訴字第230號...）',
    ),
    CaseImage(
      url:
          'https://tse3.mm.bing.net/th/id/OIP.8vGwbgtGBjFRl90_W32HlwHaE7?w=232&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '判決確定證明書與執行憑證抄本（109年度訴字第230號...）',
    )
  ],
  'case-131': const [
    CaseImage(
      url:
          'https://tse4.mm.bing.net/th/id/OIP.BpIJPdGnK-nMpGs5B9306AHaFe?w=206&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '【本案卷宗封面照片】法庭審判司法天平現場照片',
    ),
    CaseImage(
      url:
          'https://tse4.mm.bing.net/th/id/OIP.FVJkOeXgZVSaQPF4GFSr2QHaD8?w=89&h=90&c=1&rs=1&qlt=70&r=0&o=7&pid=InlineBlock&rm=3',
      source: '最高法院司法卷宗圖書館（107年度訴字第231號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.CR03_AAGv7DichRpWnF7NQHaE7?w=233&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '法規沿革與憲法判決法典（107年度訴字第231號...）',
    ),
    CaseImage(
      url:
          'https://tse1.mm.bing.net/th/id/OIP.kgAAgTi1mrNURfP1WvpUNQHaFj?w=89&h=90&c=1&rs=1&qlt=70&r=0&o=7&pid=InlineBlock&rm=3',
      source: '本案訴訟卷宗外觀及編號（107年度訴字第231號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.6_z7cGk1TU-RBgQM3tsqZQHaE8?w=221&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '地方法院簡易庭外觀與開庭公告（107年度訴字第231號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.wXoezXbxYh3d5XAsPQA1mwHaE8?w=193&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '當事人提出之訴狀首頁抄本（107年度訴字第231號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.M1ZTFf8JShiFpHtxNdAuTwHaEz?w=227&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '司法裁判書電子檔之判決主文（107年度訴字第231號...）',
    ),
    CaseImage(
      url:
          'https://tse1.mm.bing.net/th/id/OIP.xExaObj3A3nV3olc0K1gmwHaEJ?w=263&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '民事起訴狀與委任律師書狀（107年度訴字第231號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.WVO6tR5BzOgw0oglmH02OAHaEP?w=208&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '法院準備程序筆錄簽名欄位（107年度訴字第231號...）',
    ),
    CaseImage(
      url:
          'https://tse1.mm.bing.net/th/id/OIP.fEDFLQLHjS3QuE4bQLgBvQHaE8?w=229&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '司法院大法官憲法法庭開庭現場（107年度訴字第231號...）',
    ),
    CaseImage(
      url:
          'https://tse3.mm.bing.net/th/id/OIP.rgvPoDUIQa-Gb56tJrl6sgHaEO?w=89&h=90&c=1&rs=1&qlt=70&r=0&o=7&pid=InlineBlock&rm=3',
      source: '最高法院民事庭開庭大門外觀（107年度訴字第231號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.Xt1C-7meX374BAg86KC6LwHaE8?w=89&h=89&c=1&rs=1&qlt=70&r=0&o=7&pid=InlineBlock&rm=3',
      source: '法學文獻與期刊論文引用頁面（107年度訴字第231號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.EQboFDqbqWRcR8PTOr3wQwHaDn?w=297&h=171&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '中華民國六法全書民法債編法條（107年度訴字第231號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.22mIh8FxQ1xTrLJEOF-vTgHaEO?w=89&h=89&c=1&rs=1&qlt=70&r=0&o=7&pid=InlineBlock&rm=3',
      source: '民事訴訟小額程序開庭流程圖（107年度訴字第231號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.FxsIbUCjMd4IlOEskxShJgHaFj?w=89&h=89&c=1&rs=1&qlt=70&r=0&o=7&pid=InlineBlock&rm=3',
      source: '判決確定證明書與執行憑證抄本（107年度訴字第231號...）',
    )
  ],
  'case-132': const [
    CaseImage(
      url:
          'https://tse3.mm.bing.net/th/id/OIP.RHmdPX6UGcKBDnAmC1DuxQHaE7?w=215&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '【本案卷宗封面照片】法庭審判司法天平現場照片',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.M1ZTFf8JShiFpHtxNdAuTwHaEz?w=227&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '最高法院司法卷宗圖書館（110年度訴字第232號...）',
    ),
    CaseImage(
      url:
          'https://tse4.mm.bing.net/th/id/OIP.0SDoAANiAP6UoZPUrt3UqwHaEN?w=252&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '法規沿革與憲法判決法典（110年度訴字第232號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.Xt1C-7meX374BAg86KC6LwHaE8?w=89&h=89&c=1&rs=1&qlt=70&r=0&o=7&pid=InlineBlock&rm=3',
      source: '本案訴訟卷宗外觀及編號（110年度訴字第232號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.WVO6tR5BzOgw0oglmH02OAHaEP?w=208&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '地方法院簡易庭外觀與開庭公告（110年度訴字第232號...）',
    ),
    CaseImage(
      url:
          'https://tse1.mm.bing.net/th/id/OIP.xExaObj3A3nV3olc0K1gmwHaEJ?w=263&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '當事人提出之訴狀首頁抄本（110年度訴字第232號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.wXoezXbxYh3d5XAsPQA1mwHaE8?w=193&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '司法裁判書電子檔之判決主文（110年度訴字第232號...）',
    ),
    CaseImage(
      url:
          'https://tse4.mm.bing.net/th/id/OIP.BpIJPdGnK-nMpGs5B9306AHaFe?w=206&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '民事起訴狀與委任律師書狀（110年度訴字第232號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.CR03_AAGv7DichRpWnF7NQHaE7?w=233&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '法院準備程序筆錄簽名欄位（110年度訴字第232號...）',
    ),
    CaseImage(
      url:
          'https://tse4.mm.bing.net/th/id/OIP.FVJkOeXgZVSaQPF4GFSr2QHaD8?w=89&h=90&c=1&rs=1&qlt=70&r=0&o=7&pid=InlineBlock&rm=3',
      source: '司法院大法官憲法法庭開庭現場（110年度訴字第232號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.22mIh8FxQ1xTrLJEOF-vTgHaEO?w=89&h=89&c=1&rs=1&qlt=70&r=0&o=7&pid=InlineBlock&rm=3',
      source: '最高法院民事庭開庭大門外觀（110年度訴字第232號...）',
    ),
    CaseImage(
      url:
          'https://tse3.mm.bing.net/th/id/OIP.rgvPoDUIQa-Gb56tJrl6sgHaEO?w=89&h=90&c=1&rs=1&qlt=70&r=0&o=7&pid=InlineBlock&rm=3',
      source: '法學文獻與期刊論文引用頁面（110年度訴字第232號...）',
    ),
    CaseImage(
      url:
          'https://tse1.mm.bing.net/th/id/OIP.fEDFLQLHjS3QuE4bQLgBvQHaE8?w=229&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '中華民國六法全書民法債編法條（110年度訴字第232號...）',
    ),
    CaseImage(
      url:
          'https://tse3.mm.bing.net/th/id/OIP.FzL2M5zkVz2nUbqZg7Qe-QHaE7?w=215&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '民事訴訟小額程序開庭流程圖（110年度訴字第232號...）',
    ),
    CaseImage(
      url:
          'https://tse4.mm.bing.net/th/id/OIP.zbbKZ0Bh_CpP6eZamtCRjwHaE9?w=179&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '判決確定證明書與執行憑證抄本（110年度訴字第232號...）',
    )
  ],
  'case-133': const [
    CaseImage(
      url:
          'https://tse3.mm.bing.net/th/id/OIP.RHmdPX6UGcKBDnAmC1DuxQHaE7?w=215&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '【本案卷宗封面照片】法庭審判司法天平現場照片',
    ),
    CaseImage(
      url:
          'https://tse3.mm.bing.net/th/id/OIP.8vGwbgtGBjFRl90_W32HlwHaE7?w=232&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '最高法院司法卷宗圖書館（108年度訴字第233號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.WVO6tR5BzOgw0oglmH02OAHaEP?w=208&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '法規沿革與憲法判決法典（108年度訴字第233號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.Xt1C-7meX374BAg86KC6LwHaE8?w=89&h=89&c=1&rs=1&qlt=70&r=0&o=7&pid=InlineBlock&rm=3',
      source: '本案訴訟卷宗外觀及編號（108年度訴字第233號...）',
    ),
    CaseImage(
      url:
          'https://tse1.mm.bing.net/th/id/OIP.fEDFLQLHjS3QuE4bQLgBvQHaE8?w=229&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '地方法院簡易庭外觀與開庭公告（108年度訴字第233號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.FxsIbUCjMd4IlOEskxShJgHaFj?w=89&h=89&c=1&rs=1&qlt=70&r=0&o=7&pid=InlineBlock&rm=3',
      source: '當事人提出之訴狀首頁抄本（108年度訴字第233號...）',
    ),
    CaseImage(
      url:
          'https://tse4.mm.bing.net/th/id/OIP.Q7FEnIHkrd6q9Jmu1GiKkwHaEj?w=248&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '司法裁判書電子檔之判決主文（108年度訴字第233號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.CR03_AAGv7DichRpWnF7NQHaE7?w=233&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '民事起訴狀與委任律師書狀（108年度訴字第233號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.6_z7cGk1TU-RBgQM3tsqZQHaE8?w=221&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '法院準備程序筆錄簽名欄位（108年度訴字第233號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.M1ZTFf8JShiFpHtxNdAuTwHaEz?w=227&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '司法院大法官憲法法庭開庭現場（108年度訴字第233號...）',
    ),
    CaseImage(
      url:
          'https://tse4.mm.bing.net/th/id/OIP.BpIJPdGnK-nMpGs5B9306AHaFe?w=206&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '最高法院民事庭開庭大門外觀（108年度訴字第233號...）',
    ),
    CaseImage(
      url:
          'https://tse4.mm.bing.net/th/id/OIP.0SDoAANiAP6UoZPUrt3UqwHaEN?w=252&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '法學文獻與期刊論文引用頁面（108年度訴字第233號...）',
    ),
    CaseImage(
      url:
          'https://tse1.mm.bing.net/th/id/OIP.kgAAgTi1mrNURfP1WvpUNQHaFj?w=89&h=90&c=1&rs=1&qlt=70&r=0&o=7&pid=InlineBlock&rm=3',
      source: '中華民國六法全書民法債編法條（108年度訴字第233號...）',
    ),
    CaseImage(
      url:
          'https://tse3.mm.bing.net/th/id/OIP.rgvPoDUIQa-Gb56tJrl6sgHaEO?w=89&h=90&c=1&rs=1&qlt=70&r=0&o=7&pid=InlineBlock&rm=3',
      source: '民事訴訟小額程序開庭流程圖（108年度訴字第233號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.22mIh8FxQ1xTrLJEOF-vTgHaEO?w=89&h=89&c=1&rs=1&qlt=70&r=0&o=7&pid=InlineBlock&rm=3',
      source: '判決確定證明書與執行憑證抄本（108年度訴字第233號...）',
    )
  ],
  'case-134': const [
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.WVO6tR5BzOgw0oglmH02OAHaEP?w=208&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '【本案卷宗封面照片】法庭審判司法天平現場照片',
    ),
    CaseImage(
      url:
          'https://tse3.mm.bing.net/th/id/OIP.rgvPoDUIQa-Gb56tJrl6sgHaEO?w=89&h=90&c=1&rs=1&qlt=70&r=0&o=7&pid=InlineBlock&rm=3',
      source: '最高法院司法卷宗圖書館（107年度訴字第234號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.Xt1C-7meX374BAg86KC6LwHaE8?w=89&h=89&c=1&rs=1&qlt=70&r=0&o=7&pid=InlineBlock&rm=3',
      source: '法規沿革與憲法判決法典（107年度訴字第234號...）',
    ),
    CaseImage(
      url:
          'https://tse1.mm.bing.net/th/id/OIP.kgAAgTi1mrNURfP1WvpUNQHaFj?w=89&h=90&c=1&rs=1&qlt=70&r=0&o=7&pid=InlineBlock&rm=3',
      source: '本案訴訟卷宗外觀及編號（107年度訴字第234號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.wXoezXbxYh3d5XAsPQA1mwHaE8?w=193&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '地方法院簡易庭外觀與開庭公告（107年度訴字第234號...）',
    ),
    CaseImage(
      url:
          'https://tse3.mm.bing.net/th/id/OIP.FzL2M5zkVz2nUbqZg7Qe-QHaE7?w=215&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '當事人提出之訴狀首頁抄本（107年度訴字第234號...）',
    ),
    CaseImage(
      url:
          'https://tse3.mm.bing.net/th/id/OIP.8vGwbgtGBjFRl90_W32HlwHaE7?w=232&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '司法裁判書電子檔之判決主文（107年度訴字第234號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.M1ZTFf8JShiFpHtxNdAuTwHaEz?w=227&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '民事起訴狀與委任律師書狀（107年度訴字第234號...）',
    ),
    CaseImage(
      url:
          'https://tse4.mm.bing.net/th/id/OIP.zbbKZ0Bh_CpP6eZamtCRjwHaE9?w=179&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '法院準備程序筆錄簽名欄位（107年度訴字第234號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.22mIh8FxQ1xTrLJEOF-vTgHaEO?w=89&h=89&c=1&rs=1&qlt=70&r=0&o=7&pid=InlineBlock&rm=3',
      source: '司法院大法官憲法法庭開庭現場（107年度訴字第234號...）',
    ),
    CaseImage(
      url:
          'https://tse1.mm.bing.net/th/id/OIP.xExaObj3A3nV3olc0K1gmwHaEJ?w=263&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '最高法院民事庭開庭大門外觀（107年度訴字第234號...）',
    ),
    CaseImage(
      url:
          'https://tse4.mm.bing.net/th/id/OIP.FVJkOeXgZVSaQPF4GFSr2QHaD8?w=89&h=90&c=1&rs=1&qlt=70&r=0&o=7&pid=InlineBlock&rm=3',
      source: '法學文獻與期刊論文引用頁面（107年度訴字第234號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.CR03_AAGv7DichRpWnF7NQHaE7?w=233&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '中華民國六法全書民法債編法條（107年度訴字第234號...）',
    ),
    CaseImage(
      url:
          'https://tse4.mm.bing.net/th/id/OIP.BpIJPdGnK-nMpGs5B9306AHaFe?w=206&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '民事訴訟小額程序開庭流程圖（107年度訴字第234號...）',
    ),
    CaseImage(
      url:
          'https://tse4.mm.bing.net/th/id/OIP.Q7FEnIHkrd6q9Jmu1GiKkwHaEj?w=248&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '判決確定證明書與執行憑證抄本（107年度訴字第234號...）',
    )
  ],
  'case-135': const [
    CaseImage(
      url:
          'https://tse4.mm.bing.net/th/id/OIP.Q7FEnIHkrd6q9Jmu1GiKkwHaEj?w=248&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '【本案卷宗封面照片】法庭審判司法天平現場照片',
    ),
    CaseImage(
      url:
          'https://tse4.mm.bing.net/th/id/OIP.zbbKZ0Bh_CpP6eZamtCRjwHaE9?w=179&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '最高法院司法卷宗圖書館（109年度訴字第235號...）',
    ),
    CaseImage(
      url:
          'https://tse3.mm.bing.net/th/id/OIP.8vGwbgtGBjFRl90_W32HlwHaE7?w=232&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '法規沿革與憲法判決法典（109年度訴字第235號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.CR03_AAGv7DichRpWnF7NQHaE7?w=233&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '本案訴訟卷宗外觀及編號（109年度訴字第235號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.wXoezXbxYh3d5XAsPQA1mwHaE8?w=193&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '地方法院簡易庭外觀與開庭公告（109年度訴字第235號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.WVO6tR5BzOgw0oglmH02OAHaEP?w=208&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '當事人提出之訴狀首頁抄本（109年度訴字第235號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.M1ZTFf8JShiFpHtxNdAuTwHaEz?w=227&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '司法裁判書電子檔之判決主文（109年度訴字第235號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.EQboFDqbqWRcR8PTOr3wQwHaDn?w=297&h=171&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '民事起訴狀與委任律師書狀（109年度訴字第235號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.22mIh8FxQ1xTrLJEOF-vTgHaEO?w=89&h=89&c=1&rs=1&qlt=70&r=0&o=7&pid=InlineBlock&rm=3',
      source: '法院準備程序筆錄簽名欄位（109年度訴字第235號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.6_z7cGk1TU-RBgQM3tsqZQHaE8?w=221&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '司法院大法官憲法法庭開庭現場（109年度訴字第235號...）',
    ),
    CaseImage(
      url:
          'https://tse4.mm.bing.net/th/id/OIP.BpIJPdGnK-nMpGs5B9306AHaFe?w=206&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '最高法院民事庭開庭大門外觀（109年度訴字第235號...）',
    ),
    CaseImage(
      url:
          'https://tse1.mm.bing.net/th/id/OIP.fEDFLQLHjS3QuE4bQLgBvQHaE8?w=229&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '法學文獻與期刊論文引用頁面（109年度訴字第235號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.jgOpaPncHSivavrOTSAXLgHaE8?w=232&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '中華民國六法全書民法債編法條（109年度訴字第235號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.Xt1C-7meX374BAg86KC6LwHaE8?w=89&h=89&c=1&rs=1&qlt=70&r=0&o=7&pid=InlineBlock&rm=3',
      source: '民事訴訟小額程序開庭流程圖（109年度訴字第235號...）',
    ),
    CaseImage(
      url:
          'https://tse3.mm.bing.net/th/id/OIP.rgvPoDUIQa-Gb56tJrl6sgHaEO?w=89&h=90&c=1&rs=1&qlt=70&r=0&o=7&pid=InlineBlock&rm=3',
      source: '判決確定證明書與執行憑證抄本（109年度訴字第235號...）',
    )
  ],
  'case-136': const [
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.CR03_AAGv7DichRpWnF7NQHaE7?w=233&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '【本案卷宗封面照片】法庭審判司法天平現場照片',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.wXoezXbxYh3d5XAsPQA1mwHaE8?w=193&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '最高法院司法卷宗圖書館（109年度訴字第236號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.6_z7cGk1TU-RBgQM3tsqZQHaE8?w=221&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '法規沿革與憲法判決法典（109年度訴字第236號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.M1ZTFf8JShiFpHtxNdAuTwHaEz?w=227&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '本案訴訟卷宗外觀及編號（109年度訴字第236號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.FxsIbUCjMd4IlOEskxShJgHaFj?w=89&h=89&c=1&rs=1&qlt=70&r=0&o=7&pid=InlineBlock&rm=3',
      source: '地方法院簡易庭外觀與開庭公告（109年度訴字第236號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.EQboFDqbqWRcR8PTOr3wQwHaDn?w=297&h=171&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '當事人提出之訴狀首頁抄本（109年度訴字第236號...）',
    ),
    CaseImage(
      url:
          'https://tse1.mm.bing.net/th/id/OIP.xExaObj3A3nV3olc0K1gmwHaEJ?w=263&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '司法裁判書電子檔之判決主文（109年度訴字第236號...）',
    ),
    CaseImage(
      url:
          'https://tse3.mm.bing.net/th/id/OIP.8vGwbgtGBjFRl90_W32HlwHaE7?w=232&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '民事起訴狀與委任律師書狀（109年度訴字第236號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.WVO6tR5BzOgw0oglmH02OAHaEP?w=208&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '法院準備程序筆錄簽名欄位（109年度訴字第236號...）',
    ),
    CaseImage(
      url:
          'https://tse3.mm.bing.net/th/id/OIP.RHmdPX6UGcKBDnAmC1DuxQHaE7?w=215&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '司法院大法官憲法法庭開庭現場（109年度訴字第236號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.Xt1C-7meX374BAg86KC6LwHaE8?w=89&h=89&c=1&rs=1&qlt=70&r=0&o=7&pid=InlineBlock&rm=3',
      source: '最高法院民事庭開庭大門外觀（109年度訴字第236號...）',
    ),
    CaseImage(
      url:
          'https://tse4.mm.bing.net/th/id/OIP.zbbKZ0Bh_CpP6eZamtCRjwHaE9?w=179&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '法學文獻與期刊論文引用頁面（109年度訴字第236號...）',
    ),
    CaseImage(
      url:
          'https://tse1.mm.bing.net/th/id/OIP.fEDFLQLHjS3QuE4bQLgBvQHaE8?w=229&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '中華民國六法全書民法債編法條（109年度訴字第236號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.jgOpaPncHSivavrOTSAXLgHaE8?w=232&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '民事訴訟小額程序開庭流程圖（109年度訴字第236號...）',
    ),
    CaseImage(
      url:
          'https://tse4.mm.bing.net/th/id/OIP.FVJkOeXgZVSaQPF4GFSr2QHaD8?w=89&h=90&c=1&rs=1&qlt=70&r=0&o=7&pid=InlineBlock&rm=3',
      source: '判決確定證明書與執行憑證抄本（109年度訴字第236號...）',
    )
  ],
  'case-137': const [
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.WVO6tR5BzOgw0oglmH02OAHaEP?w=208&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '【本案卷宗封面照片】法庭審判司法天平現場照片',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.CR03_AAGv7DichRpWnF7NQHaE7?w=233&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '最高法院司法卷宗圖書館（108年度訴字第237號...）',
    ),
    CaseImage(
      url:
          'https://tse3.mm.bing.net/th/id/OIP.rgvPoDUIQa-Gb56tJrl6sgHaEO?w=89&h=90&c=1&rs=1&qlt=70&r=0&o=7&pid=InlineBlock&rm=3',
      source: '法規沿革與憲法判決法典（108年度訴字第237號...）',
    ),
    CaseImage(
      url:
          'https://tse3.mm.bing.net/th/id/OIP.8vGwbgtGBjFRl90_W32HlwHaE7?w=232&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '本案訴訟卷宗外觀及編號（108年度訴字第237號...）',
    ),
    CaseImage(
      url:
          'https://tse4.mm.bing.net/th/id/OIP.0SDoAANiAP6UoZPUrt3UqwHaEN?w=252&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '地方法院簡易庭外觀與開庭公告（108年度訴字第237號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.22mIh8FxQ1xTrLJEOF-vTgHaEO?w=89&h=89&c=1&rs=1&qlt=70&r=0&o=7&pid=InlineBlock&rm=3',
      source: '當事人提出之訴狀首頁抄本（108年度訴字第237號...）',
    ),
    CaseImage(
      url:
          'https://tse1.mm.bing.net/th/id/OIP.kgAAgTi1mrNURfP1WvpUNQHaFj?w=89&h=90&c=1&rs=1&qlt=70&r=0&o=7&pid=InlineBlock&rm=3',
      source: '司法裁判書電子檔之判決主文（108年度訴字第237號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.6_z7cGk1TU-RBgQM3tsqZQHaE8?w=221&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '民事起訴狀與委任律師書狀（108年度訴字第237號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.EQboFDqbqWRcR8PTOr3wQwHaDn?w=297&h=171&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '法院準備程序筆錄簽名欄位（108年度訴字第237號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.Xt1C-7meX374BAg86KC6LwHaE8?w=89&h=89&c=1&rs=1&qlt=70&r=0&o=7&pid=InlineBlock&rm=3',
      source: '司法院大法官憲法法庭開庭現場（108年度訴字第237號...）',
    ),
    CaseImage(
      url:
          'https://tse3.mm.bing.net/th/id/OIP.RHmdPX6UGcKBDnAmC1DuxQHaE7?w=215&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '最高法院民事庭開庭大門外觀（108年度訴字第237號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.wXoezXbxYh3d5XAsPQA1mwHaE8?w=193&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '法學文獻與期刊論文引用頁面（108年度訴字第237號...）',
    ),
    CaseImage(
      url:
          'https://tse4.mm.bing.net/th/id/OIP.zbbKZ0Bh_CpP6eZamtCRjwHaE9?w=179&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '中華民國六法全書民法債編法條（108年度訴字第237號...）',
    ),
    CaseImage(
      url:
          'https://tse4.mm.bing.net/th/id/OIP.BpIJPdGnK-nMpGs5B9306AHaFe?w=206&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '民事訴訟小額程序開庭流程圖（108年度訴字第237號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.FxsIbUCjMd4IlOEskxShJgHaFj?w=89&h=89&c=1&rs=1&qlt=70&r=0&o=7&pid=InlineBlock&rm=3',
      source: '判決確定證明書與執行憑證抄本（108年度訴字第237號...）',
    )
  ],
  'case-138': const [
    CaseImage(
      url:
          'https://tse3.mm.bing.net/th/id/OIP.RHmdPX6UGcKBDnAmC1DuxQHaE7?w=215&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '【本案卷宗封面照片】法庭審判司法天平現場照片',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.6_z7cGk1TU-RBgQM3tsqZQHaE8?w=221&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '最高法院司法卷宗圖書館（106年度訴字第238號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.jgOpaPncHSivavrOTSAXLgHaE8?w=232&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '法規沿革與憲法判決法典（106年度訴字第238號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.22mIh8FxQ1xTrLJEOF-vTgHaEO?w=89&h=89&c=1&rs=1&qlt=70&r=0&o=7&pid=InlineBlock&rm=3',
      source: '本案訴訟卷宗外觀及編號（106年度訴字第238號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.M1ZTFf8JShiFpHtxNdAuTwHaEz?w=227&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '地方法院簡易庭外觀與開庭公告（106年度訴字第238號...）',
    ),
    CaseImage(
      url:
          'https://tse3.mm.bing.net/th/id/OIP.rgvPoDUIQa-Gb56tJrl6sgHaEO?w=89&h=90&c=1&rs=1&qlt=70&r=0&o=7&pid=InlineBlock&rm=3',
      source: '當事人提出之訴狀首頁抄本（106年度訴字第238號...）',
    ),
    CaseImage(
      url:
          'https://tse4.mm.bing.net/th/id/OIP.BpIJPdGnK-nMpGs5B9306AHaFe?w=206&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '司法裁判書電子檔之判決主文（106年度訴字第238號...）',
    ),
    CaseImage(
      url:
          'https://tse3.mm.bing.net/th/id/OIP.FzL2M5zkVz2nUbqZg7Qe-QHaE7?w=215&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '民事起訴狀與委任律師書狀（106年度訴字第238號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.EQboFDqbqWRcR8PTOr3wQwHaDn?w=297&h=171&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '法院準備程序筆錄簽名欄位（106年度訴字第238號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.CR03_AAGv7DichRpWnF7NQHaE7?w=233&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '司法院大法官憲法法庭開庭現場（106年度訴字第238號...）',
    ),
    CaseImage(
      url:
          'https://tse4.mm.bing.net/th/id/OIP.FVJkOeXgZVSaQPF4GFSr2QHaD8?w=89&h=90&c=1&rs=1&qlt=70&r=0&o=7&pid=InlineBlock&rm=3',
      source: '最高法院民事庭開庭大門外觀（106年度訴字第238號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.FxsIbUCjMd4IlOEskxShJgHaFj?w=89&h=89&c=1&rs=1&qlt=70&r=0&o=7&pid=InlineBlock&rm=3',
      source: '法學文獻與期刊論文引用頁面（106年度訴字第238號...）',
    ),
    CaseImage(
      url:
          'https://tse4.mm.bing.net/th/id/OIP.0SDoAANiAP6UoZPUrt3UqwHaEN?w=252&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '中華民國六法全書民法債編法條（106年度訴字第238號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.WVO6tR5BzOgw0oglmH02OAHaEP?w=208&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '民事訴訟小額程序開庭流程圖（106年度訴字第238號...）',
    ),
    CaseImage(
      url:
          'https://tse3.mm.bing.net/th/id/OIP.8vGwbgtGBjFRl90_W32HlwHaE7?w=232&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '判決確定證明書與執行憑證抄本（106年度訴字第238號...）',
    )
  ],
  'case-139': const [
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.22mIh8FxQ1xTrLJEOF-vTgHaEO?w=89&h=89&c=1&rs=1&qlt=70&r=0&o=7&pid=InlineBlock&rm=3',
      source: '【本案卷宗封面照片】法庭審判司法天平現場照片',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.Xt1C-7meX374BAg86KC6LwHaE8?w=89&h=89&c=1&rs=1&qlt=70&r=0&o=7&pid=InlineBlock&rm=3',
      source: '最高法院司法卷宗圖書館（100年度訴字第239號...）',
    ),
    CaseImage(
      url:
          'https://tse4.mm.bing.net/th/id/OIP.BpIJPdGnK-nMpGs5B9306AHaFe?w=206&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '法規沿革與憲法判決法典（100年度訴字第239號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.6_z7cGk1TU-RBgQM3tsqZQHaE8?w=221&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '本案訴訟卷宗外觀及編號（100年度訴字第239號...）',
    ),
    CaseImage(
      url:
          'https://tse1.mm.bing.net/th/id/OIP.kgAAgTi1mrNURfP1WvpUNQHaFj?w=89&h=90&c=1&rs=1&qlt=70&r=0&o=7&pid=InlineBlock&rm=3',
      source: '地方法院簡易庭外觀與開庭公告（100年度訴字第239號...）',
    ),
    CaseImage(
      url:
          'https://tse1.mm.bing.net/th/id/OIP.xExaObj3A3nV3olc0K1gmwHaEJ?w=263&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '當事人提出之訴狀首頁抄本（100年度訴字第239號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.FxsIbUCjMd4IlOEskxShJgHaFj?w=89&h=89&c=1&rs=1&qlt=70&r=0&o=7&pid=InlineBlock&rm=3',
      source: '司法裁判書電子檔之判決主文（100年度訴字第239號...）',
    ),
    CaseImage(
      url:
          'https://tse3.mm.bing.net/th/id/OIP.FzL2M5zkVz2nUbqZg7Qe-QHaE7?w=215&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '民事起訴狀與委任律師書狀（100年度訴字第239號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.wXoezXbxYh3d5XAsPQA1mwHaE8?w=193&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '法院準備程序筆錄簽名欄位（100年度訴字第239號...）',
    ),
    CaseImage(
      url:
          'https://tse4.mm.bing.net/th/id/OIP.0SDoAANiAP6UoZPUrt3UqwHaEN?w=252&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '司法院大法官憲法法庭開庭現場（100年度訴字第239號...）',
    ),
    CaseImage(
      url:
          'https://tse4.mm.bing.net/th/id/OIP.zbbKZ0Bh_CpP6eZamtCRjwHaE9?w=179&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '最高法院民事庭開庭大門外觀（100年度訴字第239號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.jgOpaPncHSivavrOTSAXLgHaE8?w=232&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '法學文獻與期刊論文引用頁面（100年度訴字第239號...）',
    ),
    CaseImage(
      url:
          'https://tse3.mm.bing.net/th/id/OIP.RHmdPX6UGcKBDnAmC1DuxQHaE7?w=215&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '中華民國六法全書民法債編法條（100年度訴字第239號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.EQboFDqbqWRcR8PTOr3wQwHaDn?w=297&h=171&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '民事訴訟小額程序開庭流程圖（100年度訴字第239號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.M1ZTFf8JShiFpHtxNdAuTwHaEz?w=227&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '判決確定證明書與執行憑證抄本（100年度訴字第239號...）',
    )
  ],
  'case-140': const [
    CaseImage(
      url:
          'https://tse4.mm.bing.net/th/id/OIP.0SDoAANiAP6UoZPUrt3UqwHaEN?w=252&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '【本案卷宗封面照片】法庭審判司法天平現場照片',
    ),
    CaseImage(
      url:
          'https://tse3.mm.bing.net/th/id/OIP.8vGwbgtGBjFRl90_W32HlwHaE7?w=232&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '最高法院司法卷宗圖書館（99年度訴字第240號 ...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.6_z7cGk1TU-RBgQM3tsqZQHaE8?w=221&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '法規沿革與憲法判決法典（99年度訴字第240號 ...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.M1ZTFf8JShiFpHtxNdAuTwHaEz?w=227&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '本案訴訟卷宗外觀及編號（99年度訴字第240號 ...）',
    ),
    CaseImage(
      url:
          'https://tse3.mm.bing.net/th/id/OIP.RHmdPX6UGcKBDnAmC1DuxQHaE7?w=215&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '地方法院簡易庭外觀與開庭公告（99年度訴字第240號 ...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.jgOpaPncHSivavrOTSAXLgHaE8?w=232&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '當事人提出之訴狀首頁抄本（99年度訴字第240號 ...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.WVO6tR5BzOgw0oglmH02OAHaEP?w=208&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '司法裁判書電子檔之判決主文（99年度訴字第240號 ...）',
    ),
    CaseImage(
      url:
          'https://tse4.mm.bing.net/th/id/OIP.BpIJPdGnK-nMpGs5B9306AHaFe?w=206&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '民事起訴狀與委任律師書狀（99年度訴字第240號 ...）',
    ),
    CaseImage(
      url:
          'https://tse4.mm.bing.net/th/id/OIP.FVJkOeXgZVSaQPF4GFSr2QHaD8?w=89&h=90&c=1&rs=1&qlt=70&r=0&o=7&pid=InlineBlock&rm=3',
      source: '法院準備程序筆錄簽名欄位（99年度訴字第240號 ...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.EQboFDqbqWRcR8PTOr3wQwHaDn?w=297&h=171&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '司法院大法官憲法法庭開庭現場（99年度訴字第240號 ...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.FxsIbUCjMd4IlOEskxShJgHaFj?w=89&h=89&c=1&rs=1&qlt=70&r=0&o=7&pid=InlineBlock&rm=3',
      source: '最高法院民事庭開庭大門外觀（99年度訴字第240號 ...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.22mIh8FxQ1xTrLJEOF-vTgHaEO?w=89&h=89&c=1&rs=1&qlt=70&r=0&o=7&pid=InlineBlock&rm=3',
      source: '法學文獻與期刊論文引用頁面（99年度訴字第240號 ...）',
    ),
    CaseImage(
      url:
          'https://tse1.mm.bing.net/th/id/OIP.xExaObj3A3nV3olc0K1gmwHaEJ?w=263&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '中華民國六法全書民法債編法條（99年度訴字第240號 ...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.wXoezXbxYh3d5XAsPQA1mwHaE8?w=193&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '民事訴訟小額程序開庭流程圖（99年度訴字第240號 ...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.CR03_AAGv7DichRpWnF7NQHaE7?w=233&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '判決確定證明書與執行憑證抄本（99年度訴字第240號 ...）',
    )
  ],
  'case-141': const [
    CaseImage(
      url:
          'https://tse4.mm.bing.net/th/id/OIP.0SDoAANiAP6UoZPUrt3UqwHaEN?w=252&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '【本案卷宗封面照片】法庭審判司法天平現場照片',
    ),
    CaseImage(
      url:
          'https://tse4.mm.bing.net/th/id/OIP.zbbKZ0Bh_CpP6eZamtCRjwHaE9?w=179&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '最高法院司法卷宗圖書館（101年度訴字第241號...）',
    ),
    CaseImage(
      url:
          'https://tse1.mm.bing.net/th/id/OIP.kgAAgTi1mrNURfP1WvpUNQHaFj?w=89&h=90&c=1&rs=1&qlt=70&r=0&o=7&pid=InlineBlock&rm=3',
      source: '法規沿革與憲法判決法典（101年度訴字第241號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.6_z7cGk1TU-RBgQM3tsqZQHaE8?w=221&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '本案訴訟卷宗外觀及編號（101年度訴字第241號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.Xt1C-7meX374BAg86KC6LwHaE8?w=89&h=89&c=1&rs=1&qlt=70&r=0&o=7&pid=InlineBlock&rm=3',
      source: '地方法院簡易庭外觀與開庭公告（101年度訴字第241號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.22mIh8FxQ1xTrLJEOF-vTgHaEO?w=89&h=89&c=1&rs=1&qlt=70&r=0&o=7&pid=InlineBlock&rm=3',
      source: '當事人提出之訴狀首頁抄本（101年度訴字第241號...）',
    ),
    CaseImage(
      url:
          'https://tse3.mm.bing.net/th/id/OIP.rgvPoDUIQa-Gb56tJrl6sgHaEO?w=89&h=90&c=1&rs=1&qlt=70&r=0&o=7&pid=InlineBlock&rm=3',
      source: '司法裁判書電子檔之判決主文（101年度訴字第241號...）',
    ),
    CaseImage(
      url:
          'https://tse1.mm.bing.net/th/id/OIP.fEDFLQLHjS3QuE4bQLgBvQHaE8?w=229&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '民事起訴狀與委任律師書狀（101年度訴字第241號...）',
    ),
    CaseImage(
      url:
          'https://tse3.mm.bing.net/th/id/OIP.8vGwbgtGBjFRl90_W32HlwHaE7?w=232&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '法院準備程序筆錄簽名欄位（101年度訴字第241號...）',
    ),
    CaseImage(
      url:
          'https://tse1.mm.bing.net/th/id/OIP.xExaObj3A3nV3olc0K1gmwHaEJ?w=263&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '司法院大法官憲法法庭開庭現場（101年度訴字第241號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.wXoezXbxYh3d5XAsPQA1mwHaE8?w=193&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '最高法院民事庭開庭大門外觀（101年度訴字第241號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.EQboFDqbqWRcR8PTOr3wQwHaDn?w=297&h=171&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '法學文獻與期刊論文引用頁面（101年度訴字第241號...）',
    ),
    CaseImage(
      url:
          'https://tse4.mm.bing.net/th/id/OIP.Q7FEnIHkrd6q9Jmu1GiKkwHaEj?w=248&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '中華民國六法全書民法債編法條（101年度訴字第241號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.WVO6tR5BzOgw0oglmH02OAHaEP?w=208&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '民事訴訟小額程序開庭流程圖（101年度訴字第241號...）',
    ),
    CaseImage(
      url:
          'https://tse3.mm.bing.net/th/id/OIP.FzL2M5zkVz2nUbqZg7Qe-QHaE7?w=215&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '判決確定證明書與執行憑證抄本（101年度訴字第241號...）',
    )
  ],
  'case-142': const [
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.FxsIbUCjMd4IlOEskxShJgHaFj?w=89&h=89&c=1&rs=1&qlt=70&r=0&o=7&pid=InlineBlock&rm=3',
      source: '【本案卷宗封面照片】法庭審判司法天平現場照片',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.22mIh8FxQ1xTrLJEOF-vTgHaEO?w=89&h=89&c=1&rs=1&qlt=70&r=0&o=7&pid=InlineBlock&rm=3',
      source: '最高法院司法卷宗圖書館（103年度訴字第242號...）',
    ),
    CaseImage(
      url:
          'https://tse4.mm.bing.net/th/id/OIP.Q7FEnIHkrd6q9Jmu1GiKkwHaEj?w=248&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '法規沿革與憲法判決法典（103年度訴字第242號...）',
    ),
    CaseImage(
      url:
          'https://tse4.mm.bing.net/th/id/OIP.zbbKZ0Bh_CpP6eZamtCRjwHaE9?w=179&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '本案訴訟卷宗外觀及編號（103年度訴字第242號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.Xt1C-7meX374BAg86KC6LwHaE8?w=89&h=89&c=1&rs=1&qlt=70&r=0&o=7&pid=InlineBlock&rm=3',
      source: '地方法院簡易庭外觀與開庭公告（103年度訴字第242號...）',
    ),
    CaseImage(
      url:
          'https://tse1.mm.bing.net/th/id/OIP.fEDFLQLHjS3QuE4bQLgBvQHaE8?w=229&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '當事人提出之訴狀首頁抄本（103年度訴字第242號...）',
    ),
    CaseImage(
      url:
          'https://tse4.mm.bing.net/th/id/OIP.BpIJPdGnK-nMpGs5B9306AHaFe?w=206&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '司法裁判書電子檔之判決主文（103年度訴字第242號...）',
    ),
    CaseImage(
      url:
          'https://tse4.mm.bing.net/th/id/OIP.0SDoAANiAP6UoZPUrt3UqwHaEN?w=252&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '民事起訴狀與委任律師書狀（103年度訴字第242號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.WVO6tR5BzOgw0oglmH02OAHaEP?w=208&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '法院準備程序筆錄簽名欄位（103年度訴字第242號...）',
    ),
    CaseImage(
      url:
          'https://tse1.mm.bing.net/th/id/OIP.kgAAgTi1mrNURfP1WvpUNQHaFj?w=89&h=90&c=1&rs=1&qlt=70&r=0&o=7&pid=InlineBlock&rm=3',
      source: '司法院大法官憲法法庭開庭現場（103年度訴字第242號...）',
    ),
    CaseImage(
      url:
          'https://tse3.mm.bing.net/th/id/OIP.8vGwbgtGBjFRl90_W32HlwHaE7?w=232&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '最高法院民事庭開庭大門外觀（103年度訴字第242號...）',
    ),
    CaseImage(
      url:
          'https://tse3.mm.bing.net/th/id/OIP.RHmdPX6UGcKBDnAmC1DuxQHaE7?w=215&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '法學文獻與期刊論文引用頁面（103年度訴字第242號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.CR03_AAGv7DichRpWnF7NQHaE7?w=233&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '中華民國六法全書民法債編法條（103年度訴字第242號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.M1ZTFf8JShiFpHtxNdAuTwHaEz?w=227&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '民事訴訟小額程序開庭流程圖（103年度訴字第242號...）',
    ),
    CaseImage(
      url:
          'https://tse4.mm.bing.net/th/id/OIP.FVJkOeXgZVSaQPF4GFSr2QHaD8?w=89&h=90&c=1&rs=1&qlt=70&r=0&o=7&pid=InlineBlock&rm=3',
      source: '判決確定證明書與執行憑證抄本（103年度訴字第242號...）',
    )
  ],
  'case-143': const [
    CaseImage(
      url:
          'https://tse3.mm.bing.net/th/id/OIP.FzL2M5zkVz2nUbqZg7Qe-QHaE7?w=215&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '【本案卷宗封面照片】法庭審判司法天平現場照片',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.22mIh8FxQ1xTrLJEOF-vTgHaEO?w=89&h=89&c=1&rs=1&qlt=70&r=0&o=7&pid=InlineBlock&rm=3',
      source: '最高法院司法卷宗圖書館（104年度訴字第243號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.WVO6tR5BzOgw0oglmH02OAHaEP?w=208&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '法規沿革與憲法判決法典（104年度訴字第243號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.CR03_AAGv7DichRpWnF7NQHaE7?w=233&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '本案訴訟卷宗外觀及編號（104年度訴字第243號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.EQboFDqbqWRcR8PTOr3wQwHaDn?w=297&h=171&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '地方法院簡易庭外觀與開庭公告（104年度訴字第243號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.wXoezXbxYh3d5XAsPQA1mwHaE8?w=193&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '當事人提出之訴狀首頁抄本（104年度訴字第243號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.M1ZTFf8JShiFpHtxNdAuTwHaEz?w=227&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '司法裁判書電子檔之判決主文（104年度訴字第243號...）',
    ),
    CaseImage(
      url:
          'https://tse4.mm.bing.net/th/id/OIP.Q7FEnIHkrd6q9Jmu1GiKkwHaEj?w=248&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '民事起訴狀與委任律師書狀（104年度訴字第243號...）',
    ),
    CaseImage(
      url:
          'https://tse4.mm.bing.net/th/id/OIP.BpIJPdGnK-nMpGs5B9306AHaFe?w=206&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '法院準備程序筆錄簽名欄位（104年度訴字第243號...）',
    ),
    CaseImage(
      url:
          'https://tse1.mm.bing.net/th/id/OIP.kgAAgTi1mrNURfP1WvpUNQHaFj?w=89&h=90&c=1&rs=1&qlt=70&r=0&o=7&pid=InlineBlock&rm=3',
      source: '司法院大法官憲法法庭開庭現場（104年度訴字第243號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.Xt1C-7meX374BAg86KC6LwHaE8?w=89&h=89&c=1&rs=1&qlt=70&r=0&o=7&pid=InlineBlock&rm=3',
      source: '最高法院民事庭開庭大門外觀（104年度訴字第243號...）',
    ),
    CaseImage(
      url:
          'https://tse4.mm.bing.net/th/id/OIP.FVJkOeXgZVSaQPF4GFSr2QHaD8?w=89&h=90&c=1&rs=1&qlt=70&r=0&o=7&pid=InlineBlock&rm=3',
      source: '法學文獻與期刊論文引用頁面（104年度訴字第243號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.jgOpaPncHSivavrOTSAXLgHaE8?w=232&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '中華民國六法全書民法債編法條（104年度訴字第243號...）',
    ),
    CaseImage(
      url:
          'https://tse1.mm.bing.net/th/id/OIP.fEDFLQLHjS3QuE4bQLgBvQHaE8?w=229&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '民事訴訟小額程序開庭流程圖（104年度訴字第243號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.6_z7cGk1TU-RBgQM3tsqZQHaE8?w=221&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '判決確定證明書與執行憑證抄本（104年度訴字第243號...）',
    )
  ],
  'case-144': const [
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.EQboFDqbqWRcR8PTOr3wQwHaDn?w=297&h=171&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '【本案卷宗封面照片】法庭審判司法天平現場照片',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.wXoezXbxYh3d5XAsPQA1mwHaE8?w=193&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '最高法院司法卷宗圖書館（108年度訴字第244號...）',
    ),
    CaseImage(
      url:
          'https://tse1.mm.bing.net/th/id/OIP.fEDFLQLHjS3QuE4bQLgBvQHaE8?w=229&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '法規沿革與憲法判決法典（108年度訴字第244號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.FxsIbUCjMd4IlOEskxShJgHaFj?w=89&h=89&c=1&rs=1&qlt=70&r=0&o=7&pid=InlineBlock&rm=3',
      source: '本案訴訟卷宗外觀及編號（108年度訴字第244號...）',
    ),
    CaseImage(
      url:
          'https://tse1.mm.bing.net/th/id/OIP.kgAAgTi1mrNURfP1WvpUNQHaFj?w=89&h=90&c=1&rs=1&qlt=70&r=0&o=7&pid=InlineBlock&rm=3',
      source: '地方法院簡易庭外觀與開庭公告（108年度訴字第244號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.22mIh8FxQ1xTrLJEOF-vTgHaEO?w=89&h=89&c=1&rs=1&qlt=70&r=0&o=7&pid=InlineBlock&rm=3',
      source: '當事人提出之訴狀首頁抄本（108年度訴字第244號...）',
    ),
    CaseImage(
      url:
          'https://tse3.mm.bing.net/th/id/OIP.rgvPoDUIQa-Gb56tJrl6sgHaEO?w=89&h=90&c=1&rs=1&qlt=70&r=0&o=7&pid=InlineBlock&rm=3',
      source: '司法裁判書電子檔之判決主文（108年度訴字第244號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.6_z7cGk1TU-RBgQM3tsqZQHaE8?w=221&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '民事起訴狀與委任律師書狀（108年度訴字第244號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.Xt1C-7meX374BAg86KC6LwHaE8?w=89&h=89&c=1&rs=1&qlt=70&r=0&o=7&pid=InlineBlock&rm=3',
      source: '法院準備程序筆錄簽名欄位（108年度訴字第244號...）',
    ),
    CaseImage(
      url:
          'https://tse3.mm.bing.net/th/id/OIP.RHmdPX6UGcKBDnAmC1DuxQHaE7?w=215&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '司法院大法官憲法法庭開庭現場（108年度訴字第244號...）',
    ),
    CaseImage(
      url:
          'https://tse4.mm.bing.net/th/id/OIP.Q7FEnIHkrd6q9Jmu1GiKkwHaEj?w=248&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '最高法院民事庭開庭大門外觀（108年度訴字第244號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.jgOpaPncHSivavrOTSAXLgHaE8?w=232&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '法學文獻與期刊論文引用頁面（108年度訴字第244號...）',
    ),
    CaseImage(
      url:
          'https://tse4.mm.bing.net/th/id/OIP.FVJkOeXgZVSaQPF4GFSr2QHaD8?w=89&h=90&c=1&rs=1&qlt=70&r=0&o=7&pid=InlineBlock&rm=3',
      source: '中華民國六法全書民法債編法條（108年度訴字第244號...）',
    ),
    CaseImage(
      url:
          'https://tse1.mm.bing.net/th/id/OIP.xExaObj3A3nV3olc0K1gmwHaEJ?w=263&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '民事訴訟小額程序開庭流程圖（108年度訴字第244號...）',
    ),
    CaseImage(
      url:
          'https://tse4.mm.bing.net/th/id/OIP.BpIJPdGnK-nMpGs5B9306AHaFe?w=206&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '判決確定證明書與執行憑證抄本（108年度訴字第244號...）',
    )
  ],
  'case-145': const [
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.WVO6tR5BzOgw0oglmH02OAHaEP?w=208&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '【本案卷宗封面照片】法庭審判司法天平現場照片',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.EQboFDqbqWRcR8PTOr3wQwHaDn?w=297&h=171&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '最高法院司法卷宗圖書館（102年度訴字第245號...）',
    ),
    CaseImage(
      url:
          'https://tse3.mm.bing.net/th/id/OIP.RHmdPX6UGcKBDnAmC1DuxQHaE7?w=215&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '法規沿革與憲法判決法典（102年度訴字第245號...）',
    ),
    CaseImage(
      url:
          'https://tse1.mm.bing.net/th/id/OIP.xExaObj3A3nV3olc0K1gmwHaEJ?w=263&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '本案訴訟卷宗外觀及編號（102年度訴字第245號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.Xt1C-7meX374BAg86KC6LwHaE8?w=89&h=89&c=1&rs=1&qlt=70&r=0&o=7&pid=InlineBlock&rm=3',
      source: '地方法院簡易庭外觀與開庭公告（102年度訴字第245號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.22mIh8FxQ1xTrLJEOF-vTgHaEO?w=89&h=89&c=1&rs=1&qlt=70&r=0&o=7&pid=InlineBlock&rm=3',
      source: '當事人提出之訴狀首頁抄本（102年度訴字第245號...）',
    ),
    CaseImage(
      url:
          'https://tse1.mm.bing.net/th/id/OIP.fEDFLQLHjS3QuE4bQLgBvQHaE8?w=229&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '司法裁判書電子檔之判決主文（102年度訴字第245號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.CR03_AAGv7DichRpWnF7NQHaE7?w=233&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '民事起訴狀與委任律師書狀（102年度訴字第245號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.FxsIbUCjMd4IlOEskxShJgHaFj?w=89&h=89&c=1&rs=1&qlt=70&r=0&o=7&pid=InlineBlock&rm=3',
      source: '法院準備程序筆錄簽名欄位（102年度訴字第245號...）',
    ),
    CaseImage(
      url:
          'https://tse1.mm.bing.net/th/id/OIP.kgAAgTi1mrNURfP1WvpUNQHaFj?w=89&h=90&c=1&rs=1&qlt=70&r=0&o=7&pid=InlineBlock&rm=3',
      source: '司法院大法官憲法法庭開庭現場（102年度訴字第245號...）',
    ),
    CaseImage(
      url:
          'https://tse4.mm.bing.net/th/id/OIP.0SDoAANiAP6UoZPUrt3UqwHaEN?w=252&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '最高法院民事庭開庭大門外觀（102年度訴字第245號...）',
    ),
    CaseImage(
      url:
          'https://tse4.mm.bing.net/th/id/OIP.zbbKZ0Bh_CpP6eZamtCRjwHaE9?w=179&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '法學文獻與期刊論文引用頁面（102年度訴字第245號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.6_z7cGk1TU-RBgQM3tsqZQHaE8?w=221&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '中華民國六法全書民法債編法條（102年度訴字第245號...）',
    ),
    CaseImage(
      url:
          'https://tse3.mm.bing.net/th/id/OIP.8vGwbgtGBjFRl90_W32HlwHaE7?w=232&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '民事訴訟小額程序開庭流程圖（102年度訴字第245號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.wXoezXbxYh3d5XAsPQA1mwHaE8?w=193&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '判決確定證明書與執行憑證抄本（102年度訴字第245號...）',
    )
  ],
  'case-146': const [
    CaseImage(
      url:
          'https://tse1.mm.bing.net/th/id/OIP.xExaObj3A3nV3olc0K1gmwHaEJ?w=263&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '【本案卷宗封面照片】法庭審判司法天平現場照片',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.22mIh8FxQ1xTrLJEOF-vTgHaEO?w=89&h=89&c=1&rs=1&qlt=70&r=0&o=7&pid=InlineBlock&rm=3',
      source: '最高法院司法卷宗圖書館（106年度訴字第246號...）',
    ),
    CaseImage(
      url:
          'https://tse3.mm.bing.net/th/id/OIP.8vGwbgtGBjFRl90_W32HlwHaE7?w=232&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '法規沿革與憲法判決法典（106年度訴字第246號...）',
    ),
    CaseImage(
      url:
          'https://tse3.mm.bing.net/th/id/OIP.FzL2M5zkVz2nUbqZg7Qe-QHaE7?w=215&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '本案訴訟卷宗外觀及編號（106年度訴字第246號...）',
    ),
    CaseImage(
      url:
          'https://tse4.mm.bing.net/th/id/OIP.0SDoAANiAP6UoZPUrt3UqwHaEN?w=252&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '地方法院簡易庭外觀與開庭公告（106年度訴字第246號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.WVO6tR5BzOgw0oglmH02OAHaEP?w=208&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '當事人提出之訴狀首頁抄本（106年度訴字第246號...）',
    ),
    CaseImage(
      url:
          'https://tse4.mm.bing.net/th/id/OIP.FVJkOeXgZVSaQPF4GFSr2QHaD8?w=89&h=90&c=1&rs=1&qlt=70&r=0&o=7&pid=InlineBlock&rm=3',
      source: '司法裁判書電子檔之判決主文（106年度訴字第246號...）',
    ),
    CaseImage(
      url:
          'https://tse4.mm.bing.net/th/id/OIP.Q7FEnIHkrd6q9Jmu1GiKkwHaEj?w=248&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '民事起訴狀與委任律師書狀（106年度訴字第246號...）',
    ),
    CaseImage(
      url:
          'https://tse1.mm.bing.net/th/id/OIP.fEDFLQLHjS3QuE4bQLgBvQHaE8?w=229&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '法院準備程序筆錄簽名欄位（106年度訴字第246號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.M1ZTFf8JShiFpHtxNdAuTwHaEz?w=227&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '司法院大法官憲法法庭開庭現場（106年度訴字第246號...）',
    ),
    CaseImage(
      url:
          'https://tse4.mm.bing.net/th/id/OIP.zbbKZ0Bh_CpP6eZamtCRjwHaE9?w=179&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '最高法院民事庭開庭大門外觀（106年度訴字第246號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.6_z7cGk1TU-RBgQM3tsqZQHaE8?w=221&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '法學文獻與期刊論文引用頁面（106年度訴字第246號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.EQboFDqbqWRcR8PTOr3wQwHaDn?w=297&h=171&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '中華民國六法全書民法債編法條（106年度訴字第246號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.Xt1C-7meX374BAg86KC6LwHaE8?w=89&h=89&c=1&rs=1&qlt=70&r=0&o=7&pid=InlineBlock&rm=3',
      source: '民事訴訟小額程序開庭流程圖（106年度訴字第246號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.FxsIbUCjMd4IlOEskxShJgHaFj?w=89&h=89&c=1&rs=1&qlt=70&r=0&o=7&pid=InlineBlock&rm=3',
      source: '判決確定證明書與執行憑證抄本（106年度訴字第246號...）',
    )
  ],
  'case-147': const [
    CaseImage(
      url:
          'https://tse4.mm.bing.net/th/id/OIP.zbbKZ0Bh_CpP6eZamtCRjwHaE9?w=179&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '【本案卷宗封面照片】法庭審判司法天平現場照片',
    ),
    CaseImage(
      url:
          'https://tse4.mm.bing.net/th/id/OIP.Q7FEnIHkrd6q9Jmu1GiKkwHaEj?w=248&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '最高法院司法卷宗圖書館（105年度訴字第247號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.EQboFDqbqWRcR8PTOr3wQwHaDn?w=297&h=171&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '法規沿革與憲法判決法典（105年度訴字第247號...）',
    ),
    CaseImage(
      url:
          'https://tse1.mm.bing.net/th/id/OIP.kgAAgTi1mrNURfP1WvpUNQHaFj?w=89&h=90&c=1&rs=1&qlt=70&r=0&o=7&pid=InlineBlock&rm=3',
      source: '本案訴訟卷宗外觀及編號（105年度訴字第247號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.Xt1C-7meX374BAg86KC6LwHaE8?w=89&h=89&c=1&rs=1&qlt=70&r=0&o=7&pid=InlineBlock&rm=3',
      source: '地方法院簡易庭外觀與開庭公告（105年度訴字第247號...）',
    ),
    CaseImage(
      url:
          'https://tse3.mm.bing.net/th/id/OIP.FzL2M5zkVz2nUbqZg7Qe-QHaE7?w=215&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '當事人提出之訴狀首頁抄本（105年度訴字第247號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.FxsIbUCjMd4IlOEskxShJgHaFj?w=89&h=89&c=1&rs=1&qlt=70&r=0&o=7&pid=InlineBlock&rm=3',
      source: '司法裁判書電子檔之判決主文（105年度訴字第247號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.22mIh8FxQ1xTrLJEOF-vTgHaEO?w=89&h=89&c=1&rs=1&qlt=70&r=0&o=7&pid=InlineBlock&rm=3',
      source: '民事起訴狀與委任律師書狀（105年度訴字第247號...）',
    ),
    CaseImage(
      url:
          'https://tse4.mm.bing.net/th/id/OIP.BpIJPdGnK-nMpGs5B9306AHaFe?w=206&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '法院準備程序筆錄簽名欄位（105年度訴字第247號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.M1ZTFf8JShiFpHtxNdAuTwHaEz?w=227&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '司法院大法官憲法法庭開庭現場（105年度訴字第247號...）',
    ),
    CaseImage(
      url:
          'https://tse4.mm.bing.net/th/id/OIP.0SDoAANiAP6UoZPUrt3UqwHaEN?w=252&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '最高法院民事庭開庭大門外觀（105年度訴字第247號...）',
    ),
    CaseImage(
      url:
          'https://tse1.mm.bing.net/th/id/OIP.xExaObj3A3nV3olc0K1gmwHaEJ?w=263&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '法學文獻與期刊論文引用頁面（105年度訴字第247號...）',
    ),
    CaseImage(
      url:
          'https://tse3.mm.bing.net/th/id/OIP.RHmdPX6UGcKBDnAmC1DuxQHaE7?w=215&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '中華民國六法全書民法債編法條（105年度訴字第247號...）',
    ),
    CaseImage(
      url:
          'https://tse3.mm.bing.net/th/id/OIP.8vGwbgtGBjFRl90_W32HlwHaE7?w=232&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '民事訴訟小額程序開庭流程圖（105年度訴字第247號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.WVO6tR5BzOgw0oglmH02OAHaEP?w=208&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '判決確定證明書與執行憑證抄本（105年度訴字第247號...）',
    )
  ],
  'case-148': const [
    CaseImage(
      url:
          'https://tse1.mm.bing.net/th/id/OIP.fEDFLQLHjS3QuE4bQLgBvQHaE8?w=229&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '【本案卷宗封面照片】法庭審判司法天平現場照片',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.6_z7cGk1TU-RBgQM3tsqZQHaE8?w=221&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '最高法院司法卷宗圖書館（107年度訴字第248號...）',
    ),
    CaseImage(
      url:
          'https://tse4.mm.bing.net/th/id/OIP.zbbKZ0Bh_CpP6eZamtCRjwHaE9?w=179&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '法規沿革與憲法判決法典（107年度訴字第248號...）',
    ),
    CaseImage(
      url:
          'https://tse4.mm.bing.net/th/id/OIP.BpIJPdGnK-nMpGs5B9306AHaFe?w=206&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '本案訴訟卷宗外觀及編號（107年度訴字第248號...）',
    ),
    CaseImage(
      url:
          'https://tse4.mm.bing.net/th/id/OIP.Q7FEnIHkrd6q9Jmu1GiKkwHaEj?w=248&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '地方法院簡易庭外觀與開庭公告（107年度訴字第248號...）',
    ),
    CaseImage(
      url:
          'https://tse3.mm.bing.net/th/id/OIP.FzL2M5zkVz2nUbqZg7Qe-QHaE7?w=215&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '當事人提出之訴狀首頁抄本（107年度訴字第248號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.Xt1C-7meX374BAg86KC6LwHaE8?w=89&h=89&c=1&rs=1&qlt=70&r=0&o=7&pid=InlineBlock&rm=3',
      source: '司法裁判書電子檔之判決主文（107年度訴字第248號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.CR03_AAGv7DichRpWnF7NQHaE7?w=233&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '民事起訴狀與委任律師書狀（107年度訴字第248號...）',
    ),
    CaseImage(
      url:
          'https://tse1.mm.bing.net/th/id/OIP.xExaObj3A3nV3olc0K1gmwHaEJ?w=263&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '法院準備程序筆錄簽名欄位（107年度訴字第248號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.22mIh8FxQ1xTrLJEOF-vTgHaEO?w=89&h=89&c=1&rs=1&qlt=70&r=0&o=7&pid=InlineBlock&rm=3',
      source: '司法院大法官憲法法庭開庭現場（107年度訴字第248號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.FxsIbUCjMd4IlOEskxShJgHaFj?w=89&h=89&c=1&rs=1&qlt=70&r=0&o=7&pid=InlineBlock&rm=3',
      source: '最高法院民事庭開庭大門外觀（107年度訴字第248號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.wXoezXbxYh3d5XAsPQA1mwHaE8?w=193&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '法學文獻與期刊論文引用頁面（107年度訴字第248號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.EQboFDqbqWRcR8PTOr3wQwHaDn?w=297&h=171&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '中華民國六法全書民法債編法條（107年度訴字第248號...）',
    ),
    CaseImage(
      url:
          'https://tse1.mm.bing.net/th/id/OIP.kgAAgTi1mrNURfP1WvpUNQHaFj?w=89&h=90&c=1&rs=1&qlt=70&r=0&o=7&pid=InlineBlock&rm=3',
      source: '民事訴訟小額程序開庭流程圖（107年度訴字第248號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.M1ZTFf8JShiFpHtxNdAuTwHaEz?w=227&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '判決確定證明書與執行憑證抄本（107年度訴字第248號...）',
    )
  ],
  'case-149': const [
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.6_z7cGk1TU-RBgQM3tsqZQHaE8?w=221&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '【本案卷宗封面照片】法庭審判司法天平現場照片',
    ),
    CaseImage(
      url:
          'https://tse4.mm.bing.net/th/id/OIP.zbbKZ0Bh_CpP6eZamtCRjwHaE9?w=179&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '最高法院司法卷宗圖書館（109年度訴字第249號...）',
    ),
    CaseImage(
      url:
          'https://tse4.mm.bing.net/th/id/OIP.Q7FEnIHkrd6q9Jmu1GiKkwHaEj?w=248&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '法規沿革與憲法判決法典（109年度訴字第249號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.22mIh8FxQ1xTrLJEOF-vTgHaEO?w=89&h=89&c=1&rs=1&qlt=70&r=0&o=7&pid=InlineBlock&rm=3',
      source: '本案訴訟卷宗外觀及編號（109年度訴字第249號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.Xt1C-7meX374BAg86KC6LwHaE8?w=89&h=89&c=1&rs=1&qlt=70&r=0&o=7&pid=InlineBlock&rm=3',
      source: '地方法院簡易庭外觀與開庭公告（109年度訴字第249號...）',
    ),
    CaseImage(
      url:
          'https://tse3.mm.bing.net/th/id/OIP.8vGwbgtGBjFRl90_W32HlwHaE7?w=232&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '當事人提出之訴狀首頁抄本（109年度訴字第249號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.CR03_AAGv7DichRpWnF7NQHaE7?w=233&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '司法裁判書電子檔之判決主文（109年度訴字第249號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.wXoezXbxYh3d5XAsPQA1mwHaE8?w=193&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '民事起訴狀與委任律師書狀（109年度訴字第249號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.jgOpaPncHSivavrOTSAXLgHaE8?w=232&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '法院準備程序筆錄簽名欄位（109年度訴字第249號...）',
    ),
    CaseImage(
      url:
          'https://tse3.mm.bing.net/th/id/OIP.RHmdPX6UGcKBDnAmC1DuxQHaE7?w=215&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '司法院大法官憲法法庭開庭現場（109年度訴字第249號...）',
    ),
    CaseImage(
      url:
          'https://tse4.mm.bing.net/th/id/OIP.FVJkOeXgZVSaQPF4GFSr2QHaD8?w=89&h=90&c=1&rs=1&qlt=70&r=0&o=7&pid=InlineBlock&rm=3',
      source: '最高法院民事庭開庭大門外觀（109年度訴字第249號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.WVO6tR5BzOgw0oglmH02OAHaEP?w=208&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '法學文獻與期刊論文引用頁面（109年度訴字第249號...）',
    ),
    CaseImage(
      url:
          'https://tse1.mm.bing.net/th/id/OIP.xExaObj3A3nV3olc0K1gmwHaEJ?w=263&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '中華民國六法全書民法債編法條（109年度訴字第249號...）',
    ),
    CaseImage(
      url:
          'https://tse4.mm.bing.net/th/id/OIP.0SDoAANiAP6UoZPUrt3UqwHaEN?w=252&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '民事訴訟小額程序開庭流程圖（109年度訴字第249號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.FxsIbUCjMd4IlOEskxShJgHaFj?w=89&h=89&c=1&rs=1&qlt=70&r=0&o=7&pid=InlineBlock&rm=3',
      source: '判決確定證明書與執行憑證抄本（109年度訴字第249號...）',
    )
  ],
  'case-150': const [
    CaseImage(
      url:
          'https://tse4.mm.bing.net/th/id/OIP.FVJkOeXgZVSaQPF4GFSr2QHaD8?w=89&h=90&c=1&rs=1&qlt=70&r=0&o=7&pid=InlineBlock&rm=3',
      source: '【本案卷宗封面照片】法庭審判司法天平現場照片',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.M1ZTFf8JShiFpHtxNdAuTwHaEz?w=227&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '最高法院司法卷宗圖書館（107年度訴字第250號...）',
    ),
    CaseImage(
      url:
          'https://tse3.mm.bing.net/th/id/OIP.FzL2M5zkVz2nUbqZg7Qe-QHaE7?w=215&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '法規沿革與憲法判決法典（107年度訴字第250號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.wXoezXbxYh3d5XAsPQA1mwHaE8?w=193&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '本案訴訟卷宗外觀及編號（107年度訴字第250號...）',
    ),
    CaseImage(
      url:
          'https://tse1.mm.bing.net/th/id/OIP.xExaObj3A3nV3olc0K1gmwHaEJ?w=263&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '地方法院簡易庭外觀與開庭公告（107年度訴字第250號...）',
    ),
    CaseImage(
      url:
          'https://tse4.mm.bing.net/th/id/OIP.BpIJPdGnK-nMpGs5B9306AHaFe?w=206&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '當事人提出之訴狀首頁抄本（107年度訴字第250號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.6_z7cGk1TU-RBgQM3tsqZQHaE8?w=221&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '司法裁判書電子檔之判決主文（107年度訴字第250號...）',
    ),
    CaseImage(
      url:
          'https://tse1.mm.bing.net/th/id/OIP.kgAAgTi1mrNURfP1WvpUNQHaFj?w=89&h=90&c=1&rs=1&qlt=70&r=0&o=7&pid=InlineBlock&rm=3',
      source: '民事起訴狀與委任律師書狀（107年度訴字第250號...）',
    ),
    CaseImage(
      url:
          'https://tse3.mm.bing.net/th/id/OIP.RHmdPX6UGcKBDnAmC1DuxQHaE7?w=215&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '法院準備程序筆錄簽名欄位（107年度訴字第250號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.jgOpaPncHSivavrOTSAXLgHaE8?w=232&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '司法院大法官憲法法庭開庭現場（107年度訴字第250號...）',
    ),
    CaseImage(
      url:
          'https://tse4.mm.bing.net/th/id/OIP.Q7FEnIHkrd6q9Jmu1GiKkwHaEj?w=248&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '最高法院民事庭開庭大門外觀（107年度訴字第250號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.EQboFDqbqWRcR8PTOr3wQwHaDn?w=297&h=171&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '法學文獻與期刊論文引用頁面（107年度訴字第250號...）',
    ),
    CaseImage(
      url:
          'https://tse1.mm.bing.net/th/id/OIP.fEDFLQLHjS3QuE4bQLgBvQHaE8?w=229&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '中華民國六法全書民法債編法條（107年度訴字第250號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.FxsIbUCjMd4IlOEskxShJgHaFj?w=89&h=89&c=1&rs=1&qlt=70&r=0&o=7&pid=InlineBlock&rm=3',
      source: '民事訴訟小額程序開庭流程圖（107年度訴字第250號...）',
    ),
    CaseImage(
      url:
          'https://tse3.mm.bing.net/th/id/OIP.rgvPoDUIQa-Gb56tJrl6sgHaEO?w=89&h=90&c=1&rs=1&qlt=70&r=0&o=7&pid=InlineBlock&rm=3',
      source: '判決確定證明書與執行憑證抄本（107年度訴字第250號...）',
    )
  ],
  'case-151': const [
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.jgOpaPncHSivavrOTSAXLgHaE8?w=232&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '【本案卷宗封面照片】法庭審判司法天平現場照片',
    ),
    CaseImage(
      url:
          'https://tse4.mm.bing.net/th/id/OIP.Q7FEnIHkrd6q9Jmu1GiKkwHaEj?w=248&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '最高法院司法卷宗圖書館（108年度訴字第251號...）',
    ),
    CaseImage(
      url:
          'https://tse3.mm.bing.net/th/id/OIP.rgvPoDUIQa-Gb56tJrl6sgHaEO?w=89&h=90&c=1&rs=1&qlt=70&r=0&o=7&pid=InlineBlock&rm=3',
      source: '法規沿革與憲法判決法典（108年度訴字第251號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.WVO6tR5BzOgw0oglmH02OAHaEP?w=208&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '本案訴訟卷宗外觀及編號（108年度訴字第251號...）',
    ),
    CaseImage(
      url:
          'https://tse3.mm.bing.net/th/id/OIP.FzL2M5zkVz2nUbqZg7Qe-QHaE7?w=215&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '地方法院簡易庭外觀與開庭公告（108年度訴字第251號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.EQboFDqbqWRcR8PTOr3wQwHaDn?w=297&h=171&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '當事人提出之訴狀首頁抄本（108年度訴字第251號...）',
    ),
    CaseImage(
      url:
          'https://tse1.mm.bing.net/th/id/OIP.kgAAgTi1mrNURfP1WvpUNQHaFj?w=89&h=90&c=1&rs=1&qlt=70&r=0&o=7&pid=InlineBlock&rm=3',
      source: '司法裁判書電子檔之判決主文（108年度訴字第251號...）',
    ),
    CaseImage(
      url:
          'https://tse4.mm.bing.net/th/id/OIP.zbbKZ0Bh_CpP6eZamtCRjwHaE9?w=179&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '民事起訴狀與委任律師書狀（108年度訴字第251號...）',
    ),
    CaseImage(
      url:
          'https://tse3.mm.bing.net/th/id/OIP.8vGwbgtGBjFRl90_W32HlwHaE7?w=232&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '法院準備程序筆錄簽名欄位（108年度訴字第251號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.22mIh8FxQ1xTrLJEOF-vTgHaEO?w=89&h=89&c=1&rs=1&qlt=70&r=0&o=7&pid=InlineBlock&rm=3',
      source: '司法院大法官憲法法庭開庭現場（108年度訴字第251號...）',
    ),
    CaseImage(
      url:
          'https://tse4.mm.bing.net/th/id/OIP.FVJkOeXgZVSaQPF4GFSr2QHaD8?w=89&h=90&c=1&rs=1&qlt=70&r=0&o=7&pid=InlineBlock&rm=3',
      source: '最高法院民事庭開庭大門外觀（108年度訴字第251號...）',
    ),
    CaseImage(
      url:
          'https://tse4.mm.bing.net/th/id/OIP.0SDoAANiAP6UoZPUrt3UqwHaEN?w=252&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '法學文獻與期刊論文引用頁面（108年度訴字第251號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.CR03_AAGv7DichRpWnF7NQHaE7?w=233&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '中華民國六法全書民法債編法條（108年度訴字第251號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.Xt1C-7meX374BAg86KC6LwHaE8?w=89&h=89&c=1&rs=1&qlt=70&r=0&o=7&pid=InlineBlock&rm=3',
      source: '民事訴訟小額程序開庭流程圖（108年度訴字第251號...）',
    ),
    CaseImage(
      url:
          'https://tse4.mm.bing.net/th/id/OIP.BpIJPdGnK-nMpGs5B9306AHaFe?w=206&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '判決確定證明書與執行憑證抄本（108年度訴字第251號...）',
    )
  ],
  'case-152': const [
    CaseImage(
      url:
          'https://tse1.mm.bing.net/th/id/OIP.xExaObj3A3nV3olc0K1gmwHaEJ?w=263&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '【本案卷宗封面照片】法庭審判司法天平現場照片',
    ),
    CaseImage(
      url:
          'https://tse4.mm.bing.net/th/id/OIP.zbbKZ0Bh_CpP6eZamtCRjwHaE9?w=179&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '最高法院司法卷宗圖書館（110年度訴字第252號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.M1ZTFf8JShiFpHtxNdAuTwHaEz?w=227&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '法規沿革與憲法判決法典（110年度訴字第252號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.CR03_AAGv7DichRpWnF7NQHaE7?w=233&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '本案訴訟卷宗外觀及編號（110年度訴字第252號...）',
    ),
    CaseImage(
      url:
          'https://tse3.mm.bing.net/th/id/OIP.rgvPoDUIQa-Gb56tJrl6sgHaEO?w=89&h=90&c=1&rs=1&qlt=70&r=0&o=7&pid=InlineBlock&rm=3',
      source: '地方法院簡易庭外觀與開庭公告（110年度訴字第252號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.6_z7cGk1TU-RBgQM3tsqZQHaE8?w=221&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '當事人提出之訴狀首頁抄本（110年度訴字第252號...）',
    ),
    CaseImage(
      url:
          'https://tse4.mm.bing.net/th/id/OIP.Q7FEnIHkrd6q9Jmu1GiKkwHaEj?w=248&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '司法裁判書電子檔之判決主文（110年度訴字第252號...）',
    ),
    CaseImage(
      url:
          'https://tse4.mm.bing.net/th/id/OIP.0SDoAANiAP6UoZPUrt3UqwHaEN?w=252&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '民事起訴狀與委任律師書狀（110年度訴字第252號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.wXoezXbxYh3d5XAsPQA1mwHaE8?w=193&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '法院準備程序筆錄簽名欄位（110年度訴字第252號...）',
    ),
    CaseImage(
      url:
          'https://tse1.mm.bing.net/th/id/OIP.fEDFLQLHjS3QuE4bQLgBvQHaE8?w=229&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '司法院大法官憲法法庭開庭現場（110年度訴字第252號...）',
    ),
    CaseImage(
      url:
          'https://tse3.mm.bing.net/th/id/OIP.RHmdPX6UGcKBDnAmC1DuxQHaE7?w=215&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '最高法院民事庭開庭大門外觀（110年度訴字第252號...）',
    ),
    CaseImage(
      url:
          'https://tse1.mm.bing.net/th/id/OIP.kgAAgTi1mrNURfP1WvpUNQHaFj?w=89&h=90&c=1&rs=1&qlt=70&r=0&o=7&pid=InlineBlock&rm=3',
      source: '法學文獻與期刊論文引用頁面（110年度訴字第252號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.22mIh8FxQ1xTrLJEOF-vTgHaEO?w=89&h=89&c=1&rs=1&qlt=70&r=0&o=7&pid=InlineBlock&rm=3',
      source: '中華民國六法全書民法債編法條（110年度訴字第252號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.FxsIbUCjMd4IlOEskxShJgHaFj?w=89&h=89&c=1&rs=1&qlt=70&r=0&o=7&pid=InlineBlock&rm=3',
      source: '民事訴訟小額程序開庭流程圖（110年度訴字第252號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.WVO6tR5BzOgw0oglmH02OAHaEP?w=208&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '判決確定證明書與執行憑證抄本（110年度訴字第252號...）',
    )
  ],
  'case-153': const [
    CaseImage(
      url:
          'https://tse1.mm.bing.net/th/id/OIP.fEDFLQLHjS3QuE4bQLgBvQHaE8?w=229&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '【本案卷宗封面照片】法庭審判司法天平現場照片',
    ),
    CaseImage(
      url:
          'https://tse3.mm.bing.net/th/id/OIP.8vGwbgtGBjFRl90_W32HlwHaE7?w=232&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '最高法院司法卷宗圖書館（101年度訴字第253號...）',
    ),
    CaseImage(
      url:
          'https://tse3.mm.bing.net/th/id/OIP.RHmdPX6UGcKBDnAmC1DuxQHaE7?w=215&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '法規沿革與憲法判決法典（101年度訴字第253號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.wXoezXbxYh3d5XAsPQA1mwHaE8?w=193&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '本案訴訟卷宗外觀及編號（101年度訴字第253號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.CR03_AAGv7DichRpWnF7NQHaE7?w=233&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '地方法院簡易庭外觀與開庭公告（101年度訴字第253號...）',
    ),
    CaseImage(
      url:
          'https://tse3.mm.bing.net/th/id/OIP.rgvPoDUIQa-Gb56tJrl6sgHaEO?w=89&h=90&c=1&rs=1&qlt=70&r=0&o=7&pid=InlineBlock&rm=3',
      source: '當事人提出之訴狀首頁抄本（101年度訴字第253號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.WVO6tR5BzOgw0oglmH02OAHaEP?w=208&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '司法裁判書電子檔之判決主文（101年度訴字第253號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.Xt1C-7meX374BAg86KC6LwHaE8?w=89&h=89&c=1&rs=1&qlt=70&r=0&o=7&pid=InlineBlock&rm=3',
      source: '民事起訴狀與委任律師書狀（101年度訴字第253號...）',
    ),
    CaseImage(
      url:
          'https://tse4.mm.bing.net/th/id/OIP.0SDoAANiAP6UoZPUrt3UqwHaEN?w=252&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '法院準備程序筆錄簽名欄位（101年度訴字第253號...）',
    ),
    CaseImage(
      url:
          'https://tse1.mm.bing.net/th/id/OIP.kgAAgTi1mrNURfP1WvpUNQHaFj?w=89&h=90&c=1&rs=1&qlt=70&r=0&o=7&pid=InlineBlock&rm=3',
      source: '司法院大法官憲法法庭開庭現場（101年度訴字第253號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.M1ZTFf8JShiFpHtxNdAuTwHaEz?w=227&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '最高法院民事庭開庭大門外觀（101年度訴字第253號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.jgOpaPncHSivavrOTSAXLgHaE8?w=232&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '法學文獻與期刊論文引用頁面（101年度訴字第253號...）',
    ),
    CaseImage(
      url:
          'https://tse4.mm.bing.net/th/id/OIP.FVJkOeXgZVSaQPF4GFSr2QHaD8?w=89&h=90&c=1&rs=1&qlt=70&r=0&o=7&pid=InlineBlock&rm=3',
      source: '中華民國六法全書民法債編法條（101年度訴字第253號...）',
    ),
    CaseImage(
      url:
          'https://tse4.mm.bing.net/th/id/OIP.zbbKZ0Bh_CpP6eZamtCRjwHaE9?w=179&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '民事訴訟小額程序開庭流程圖（101年度訴字第253號...）',
    ),
    CaseImage(
      url:
          'https://tse3.mm.bing.net/th/id/OIP.FzL2M5zkVz2nUbqZg7Qe-QHaE7?w=215&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '判決確定證明書與執行憑證抄本（101年度訴字第253號...）',
    )
  ],
  'case-154': const [
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.WVO6tR5BzOgw0oglmH02OAHaEP?w=208&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '【本案卷宗封面照片】法庭審判司法天平現場照片',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.6_z7cGk1TU-RBgQM3tsqZQHaE8?w=221&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '最高法院司法卷宗圖書館（司法院釋字第 1054 ...）',
    ),
    CaseImage(
      url:
          'https://tse3.mm.bing.net/th/id/OIP.8vGwbgtGBjFRl90_W32HlwHaE7?w=232&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '法規沿革與憲法判決法典（司法院釋字第 1054 ...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.Xt1C-7meX374BAg86KC6LwHaE8?w=89&h=89&c=1&rs=1&qlt=70&r=0&o=7&pid=InlineBlock&rm=3',
      source: '本案訴訟卷宗外觀及編號（司法院釋字第 1054 ...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.jgOpaPncHSivavrOTSAXLgHaE8?w=232&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '地方法院簡易庭外觀與開庭公告（司法院釋字第 1054 ...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.FxsIbUCjMd4IlOEskxShJgHaFj?w=89&h=89&c=1&rs=1&qlt=70&r=0&o=7&pid=InlineBlock&rm=3',
      source: '當事人提出之訴狀首頁抄本（司法院釋字第 1054 ...）',
    ),
    CaseImage(
      url:
          'https://tse4.mm.bing.net/th/id/OIP.BpIJPdGnK-nMpGs5B9306AHaFe?w=206&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '司法裁判書電子檔之判決主文（司法院釋字第 1054 ...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.EQboFDqbqWRcR8PTOr3wQwHaDn?w=297&h=171&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '民事起訴狀與委任律師書狀（司法院釋字第 1054 ...）',
    ),
    CaseImage(
      url:
          'https://tse1.mm.bing.net/th/id/OIP.fEDFLQLHjS3QuE4bQLgBvQHaE8?w=229&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '法院準備程序筆錄簽名欄位（司法院釋字第 1054 ...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.22mIh8FxQ1xTrLJEOF-vTgHaEO?w=89&h=89&c=1&rs=1&qlt=70&r=0&o=7&pid=InlineBlock&rm=3',
      source: '司法院大法官憲法法庭開庭現場（司法院釋字第 1054 ...）',
    ),
    CaseImage(
      url:
          'https://tse4.mm.bing.net/th/id/OIP.zbbKZ0Bh_CpP6eZamtCRjwHaE9?w=179&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '最高法院民事庭開庭大門外觀（司法院釋字第 1054 ...）',
    ),
    CaseImage(
      url:
          'https://tse3.mm.bing.net/th/id/OIP.FzL2M5zkVz2nUbqZg7Qe-QHaE7?w=215&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '法學文獻與期刊論文引用頁面（司法院釋字第 1054 ...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.CR03_AAGv7DichRpWnF7NQHaE7?w=233&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '中華民國六法全書民法債編法條（司法院釋字第 1054 ...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.wXoezXbxYh3d5XAsPQA1mwHaE8?w=193&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '民事訴訟小額程序開庭流程圖（司法院釋字第 1054 ...）',
    ),
    CaseImage(
      url:
          'https://tse3.mm.bing.net/th/id/OIP.rgvPoDUIQa-Gb56tJrl6sgHaEO?w=89&h=90&c=1&rs=1&qlt=70&r=0&o=7&pid=InlineBlock&rm=3',
      source: '判決確定證明書與執行憑證抄本（司法院釋字第 1054 ...）',
    )
  ],
  'case-155': const [
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.Xt1C-7meX374BAg86KC6LwHaE8?w=89&h=89&c=1&rs=1&qlt=70&r=0&o=7&pid=InlineBlock&rm=3',
      source: '【本案卷宗封面照片】法庭審判司法天平現場照片',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.M1ZTFf8JShiFpHtxNdAuTwHaEz?w=227&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '最高法院司法卷宗圖書館（司法院釋字第 1055 ...）',
    ),
    CaseImage(
      url:
          'https://tse3.mm.bing.net/th/id/OIP.rgvPoDUIQa-Gb56tJrl6sgHaEO?w=89&h=90&c=1&rs=1&qlt=70&r=0&o=7&pid=InlineBlock&rm=3',
      source: '法規沿革與憲法判決法典（司法院釋字第 1055 ...）',
    ),
    CaseImage(
      url:
          'https://tse3.mm.bing.net/th/id/OIP.8vGwbgtGBjFRl90_W32HlwHaE7?w=232&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '本案訴訟卷宗外觀及編號（司法院釋字第 1055 ...）',
    ),
    CaseImage(
      url:
          'https://tse1.mm.bing.net/th/id/OIP.kgAAgTi1mrNURfP1WvpUNQHaFj?w=89&h=90&c=1&rs=1&qlt=70&r=0&o=7&pid=InlineBlock&rm=3',
      source: '地方法院簡易庭外觀與開庭公告（司法院釋字第 1055 ...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.jgOpaPncHSivavrOTSAXLgHaE8?w=232&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '當事人提出之訴狀首頁抄本（司法院釋字第 1055 ...）',
    ),
    CaseImage(
      url:
          'https://tse3.mm.bing.net/th/id/OIP.RHmdPX6UGcKBDnAmC1DuxQHaE7?w=215&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '司法裁判書電子檔之判決主文（司法院釋字第 1055 ...）',
    ),
    CaseImage(
      url:
          'https://tse1.mm.bing.net/th/id/OIP.fEDFLQLHjS3QuE4bQLgBvQHaE8?w=229&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '民事起訴狀與委任律師書狀（司法院釋字第 1055 ...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.wXoezXbxYh3d5XAsPQA1mwHaE8?w=193&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '法院準備程序筆錄簽名欄位（司法院釋字第 1055 ...）',
    ),
    CaseImage(
      url:
          'https://tse4.mm.bing.net/th/id/OIP.0SDoAANiAP6UoZPUrt3UqwHaEN?w=252&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '司法院大法官憲法法庭開庭現場（司法院釋字第 1055 ...）',
    ),
    CaseImage(
      url:
          'https://tse4.mm.bing.net/th/id/OIP.zbbKZ0Bh_CpP6eZamtCRjwHaE9?w=179&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '最高法院民事庭開庭大門外觀（司法院釋字第 1055 ...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.EQboFDqbqWRcR8PTOr3wQwHaDn?w=297&h=171&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '法學文獻與期刊論文引用頁面（司法院釋字第 1055 ...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.6_z7cGk1TU-RBgQM3tsqZQHaE8?w=221&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '中華民國六法全書民法債編法條（司法院釋字第 1055 ...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.FxsIbUCjMd4IlOEskxShJgHaFj?w=89&h=89&c=1&rs=1&qlt=70&r=0&o=7&pid=InlineBlock&rm=3',
      source: '民事訴訟小額程序開庭流程圖（司法院釋字第 1055 ...）',
    ),
    CaseImage(
      url:
          'https://tse4.mm.bing.net/th/id/OIP.Q7FEnIHkrd6q9Jmu1GiKkwHaEj?w=248&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '判決確定證明書與執行憑證抄本（司法院釋字第 1055 ...）',
    )
  ],
  'case-156': const [
    CaseImage(
      url:
          'https://tse4.mm.bing.net/th/id/OIP.0SDoAANiAP6UoZPUrt3UqwHaEN?w=252&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '【本案卷宗封面照片】法庭審判司法天平現場照片',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.6_z7cGk1TU-RBgQM3tsqZQHaE8?w=221&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '最高法院司法卷宗圖書館（司法院釋字第 1056 ...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.EQboFDqbqWRcR8PTOr3wQwHaDn?w=297&h=171&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '法規沿革與憲法判決法典（司法院釋字第 1056 ...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.jgOpaPncHSivavrOTSAXLgHaE8?w=232&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '本案訴訟卷宗外觀及編號（司法院釋字第 1056 ...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.FxsIbUCjMd4IlOEskxShJgHaFj?w=89&h=89&c=1&rs=1&qlt=70&r=0&o=7&pid=InlineBlock&rm=3',
      source: '地方法院簡易庭外觀與開庭公告（司法院釋字第 1056 ...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.CR03_AAGv7DichRpWnF7NQHaE7?w=233&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '當事人提出之訴狀首頁抄本（司法院釋字第 1056 ...）',
    ),
    CaseImage(
      url:
          'https://tse4.mm.bing.net/th/id/OIP.BpIJPdGnK-nMpGs5B9306AHaFe?w=206&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '司法裁判書電子檔之判決主文（司法院釋字第 1056 ...）',
    ),
    CaseImage(
      url:
          'https://tse1.mm.bing.net/th/id/OIP.kgAAgTi1mrNURfP1WvpUNQHaFj?w=89&h=90&c=1&rs=1&qlt=70&r=0&o=7&pid=InlineBlock&rm=3',
      source: '民事起訴狀與委任律師書狀（司法院釋字第 1056 ...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.M1ZTFf8JShiFpHtxNdAuTwHaEz?w=227&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '法院準備程序筆錄簽名欄位（司法院釋字第 1056 ...）',
    ),
    CaseImage(
      url:
          'https://tse4.mm.bing.net/th/id/OIP.zbbKZ0Bh_CpP6eZamtCRjwHaE9?w=179&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '司法院大法官憲法法庭開庭現場（司法院釋字第 1056 ...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.Xt1C-7meX374BAg86KC6LwHaE8?w=89&h=89&c=1&rs=1&qlt=70&r=0&o=7&pid=InlineBlock&rm=3',
      source: '最高法院民事庭開庭大門外觀（司法院釋字第 1056 ...）',
    ),
    CaseImage(
      url:
          'https://tse4.mm.bing.net/th/id/OIP.Q7FEnIHkrd6q9Jmu1GiKkwHaEj?w=248&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '法學文獻與期刊論文引用頁面（司法院釋字第 1056 ...）',
    ),
    CaseImage(
      url:
          'https://tse3.mm.bing.net/th/id/OIP.RHmdPX6UGcKBDnAmC1DuxQHaE7?w=215&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '中華民國六法全書民法債編法條（司法院釋字第 1056 ...）',
    ),
    CaseImage(
      url:
          'https://tse4.mm.bing.net/th/id/OIP.FVJkOeXgZVSaQPF4GFSr2QHaD8?w=89&h=90&c=1&rs=1&qlt=70&r=0&o=7&pid=InlineBlock&rm=3',
      source: '民事訴訟小額程序開庭流程圖（司法院釋字第 1056 ...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.22mIh8FxQ1xTrLJEOF-vTgHaEO?w=89&h=89&c=1&rs=1&qlt=70&r=0&o=7&pid=InlineBlock&rm=3',
      source: '判決確定證明書與執行憑證抄本（司法院釋字第 1056 ...）',
    )
  ],
  'case-157': const [
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.FxsIbUCjMd4IlOEskxShJgHaFj?w=89&h=89&c=1&rs=1&qlt=70&r=0&o=7&pid=InlineBlock&rm=3',
      source: '【本案卷宗封面照片】法庭審判司法天平現場照片',
    ),
    CaseImage(
      url:
          'https://tse4.mm.bing.net/th/id/OIP.Q7FEnIHkrd6q9Jmu1GiKkwHaEj?w=248&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '最高法院司法卷宗圖書館（119 年憲判字第 18...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.22mIh8FxQ1xTrLJEOF-vTgHaEO?w=89&h=89&c=1&rs=1&qlt=70&r=0&o=7&pid=InlineBlock&rm=3',
      source: '法規沿革與憲法判決法典（119 年憲判字第 18...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.6_z7cGk1TU-RBgQM3tsqZQHaE8?w=221&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '本案訴訟卷宗外觀及編號（119 年憲判字第 18...）',
    ),
    CaseImage(
      url:
          'https://tse1.mm.bing.net/th/id/OIP.fEDFLQLHjS3QuE4bQLgBvQHaE8?w=229&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '地方法院簡易庭外觀與開庭公告（119 年憲判字第 18...）',
    ),
    CaseImage(
      url:
          'https://tse3.mm.bing.net/th/id/OIP.rgvPoDUIQa-Gb56tJrl6sgHaEO?w=89&h=90&c=1&rs=1&qlt=70&r=0&o=7&pid=InlineBlock&rm=3',
      source: '當事人提出之訴狀首頁抄本（119 年憲判字第 18...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.wXoezXbxYh3d5XAsPQA1mwHaE8?w=193&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '司法裁判書電子檔之判決主文（119 年憲判字第 18...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.Xt1C-7meX374BAg86KC6LwHaE8?w=89&h=89&c=1&rs=1&qlt=70&r=0&o=7&pid=InlineBlock&rm=3',
      source: '民事起訴狀與委任律師書狀（119 年憲判字第 18...）',
    ),
    CaseImage(
      url:
          'https://tse1.mm.bing.net/th/id/OIP.kgAAgTi1mrNURfP1WvpUNQHaFj?w=89&h=90&c=1&rs=1&qlt=70&r=0&o=7&pid=InlineBlock&rm=3',
      source: '法院準備程序筆錄簽名欄位（119 年憲判字第 18...）',
    ),
    CaseImage(
      url:
          'https://tse4.mm.bing.net/th/id/OIP.FVJkOeXgZVSaQPF4GFSr2QHaD8?w=89&h=90&c=1&rs=1&qlt=70&r=0&o=7&pid=InlineBlock&rm=3',
      source: '司法院大法官憲法法庭開庭現場（119 年憲判字第 18...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.EQboFDqbqWRcR8PTOr3wQwHaDn?w=297&h=171&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '最高法院民事庭開庭大門外觀（119 年憲判字第 18...）',
    ),
    CaseImage(
      url:
          'https://tse3.mm.bing.net/th/id/OIP.RHmdPX6UGcKBDnAmC1DuxQHaE7?w=215&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '法學文獻與期刊論文引用頁面（119 年憲判字第 18...）',
    ),
    CaseImage(
      url:
          'https://tse4.mm.bing.net/th/id/OIP.zbbKZ0Bh_CpP6eZamtCRjwHaE9?w=179&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '中華民國六法全書民法債編法條（119 年憲判字第 18...）',
    ),
    CaseImage(
      url:
          'https://tse4.mm.bing.net/th/id/OIP.0SDoAANiAP6UoZPUrt3UqwHaEN?w=252&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '民事訴訟小額程序開庭流程圖（119 年憲判字第 18...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.CR03_AAGv7DichRpWnF7NQHaE7?w=233&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '判決確定證明書與執行憑證抄本（119 年憲判字第 18...）',
    )
  ],
  'case-158': const [
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.Xt1C-7meX374BAg86KC6LwHaE8?w=89&h=89&c=1&rs=1&qlt=70&r=0&o=7&pid=InlineBlock&rm=3',
      source: '【本案卷宗封面照片】法庭審判司法天平現場照片',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.22mIh8FxQ1xTrLJEOF-vTgHaEO?w=89&h=89&c=1&rs=1&qlt=70&r=0&o=7&pid=InlineBlock&rm=3',
      source: '最高法院司法卷宗圖書館（110 年憲判字第 19...）',
    ),
    CaseImage(
      url:
          'https://tse3.mm.bing.net/th/id/OIP.RHmdPX6UGcKBDnAmC1DuxQHaE7?w=215&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '法規沿革與憲法判決法典（110 年憲判字第 19...）',
    ),
    CaseImage(
      url:
          'https://tse1.mm.bing.net/th/id/OIP.xExaObj3A3nV3olc0K1gmwHaEJ?w=263&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '本案訴訟卷宗外觀及編號（110 年憲判字第 19...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.M1ZTFf8JShiFpHtxNdAuTwHaEz?w=227&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '地方法院簡易庭外觀與開庭公告（110 年憲判字第 19...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.EQboFDqbqWRcR8PTOr3wQwHaDn?w=297&h=171&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '當事人提出之訴狀首頁抄本（110 年憲判字第 19...）',
    ),
    CaseImage(
      url:
          'https://tse3.mm.bing.net/th/id/OIP.8vGwbgtGBjFRl90_W32HlwHaE7?w=232&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '司法裁判書電子檔之判決主文（110 年憲判字第 19...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.CR03_AAGv7DichRpWnF7NQHaE7?w=233&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '民事起訴狀與委任律師書狀（110 年憲判字第 19...）',
    ),
    CaseImage(
      url:
          'https://tse4.mm.bing.net/th/id/OIP.0SDoAANiAP6UoZPUrt3UqwHaEN?w=252&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '法院準備程序筆錄簽名欄位（110 年憲判字第 19...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.wXoezXbxYh3d5XAsPQA1mwHaE8?w=193&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '司法院大法官憲法法庭開庭現場（110 年憲判字第 19...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.FxsIbUCjMd4IlOEskxShJgHaFj?w=89&h=89&c=1&rs=1&qlt=70&r=0&o=7&pid=InlineBlock&rm=3',
      source: '最高法院民事庭開庭大門外觀（110 年憲判字第 19...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.WVO6tR5BzOgw0oglmH02OAHaEP?w=208&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '法學文獻與期刊論文引用頁面（110 年憲判字第 19...）',
    ),
    CaseImage(
      url:
          'https://tse4.mm.bing.net/th/id/OIP.zbbKZ0Bh_CpP6eZamtCRjwHaE9?w=179&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '中華民國六法全書民法債編法條（110 年憲判字第 19...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.6_z7cGk1TU-RBgQM3tsqZQHaE8?w=221&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '民事訴訟小額程序開庭流程圖（110 年憲判字第 19...）',
    ),
    CaseImage(
      url:
          'https://tse4.mm.bing.net/th/id/OIP.FVJkOeXgZVSaQPF4GFSr2QHaD8?w=89&h=90&c=1&rs=1&qlt=70&r=0&o=7&pid=InlineBlock&rm=3',
      source: '判決確定證明書與執行憑證抄本（110 年憲判字第 19...）',
    )
  ],
  'case-159': const [
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.WVO6tR5BzOgw0oglmH02OAHaEP?w=208&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '【本案卷宗封面照片】法庭審判司法天平現場照片',
    ),
    CaseImage(
      url:
          'https://tse3.mm.bing.net/th/id/OIP.FzL2M5zkVz2nUbqZg7Qe-QHaE7?w=215&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '最高法院司法卷宗圖書館（110 年憲判字第 20...）',
    ),
    CaseImage(
      url:
          'https://tse3.mm.bing.net/th/id/OIP.rgvPoDUIQa-Gb56tJrl6sgHaEO?w=89&h=90&c=1&rs=1&qlt=70&r=0&o=7&pid=InlineBlock&rm=3',
      source: '法規沿革與憲法判決法典（110 年憲判字第 20...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.Xt1C-7meX374BAg86KC6LwHaE8?w=89&h=89&c=1&rs=1&qlt=70&r=0&o=7&pid=InlineBlock&rm=3',
      source: '本案訴訟卷宗外觀及編號（110 年憲判字第 20...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.CR03_AAGv7DichRpWnF7NQHaE7?w=233&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '地方法院簡易庭外觀與開庭公告（110 年憲判字第 20...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.EQboFDqbqWRcR8PTOr3wQwHaDn?w=297&h=171&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '當事人提出之訴狀首頁抄本（110 年憲判字第 20...）',
    ),
    CaseImage(
      url:
          'https://tse4.mm.bing.net/th/id/OIP.BpIJPdGnK-nMpGs5B9306AHaFe?w=206&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '司法裁判書電子檔之判決主文（110 年憲判字第 20...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.M1ZTFf8JShiFpHtxNdAuTwHaEz?w=227&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '民事起訴狀與委任律師書狀（110 年憲判字第 20...）',
    ),
    CaseImage(
      url:
          'https://tse4.mm.bing.net/th/id/OIP.zbbKZ0Bh_CpP6eZamtCRjwHaE9?w=179&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '法院準備程序筆錄簽名欄位（110 年憲判字第 20...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.FxsIbUCjMd4IlOEskxShJgHaFj?w=89&h=89&c=1&rs=1&qlt=70&r=0&o=7&pid=InlineBlock&rm=3',
      source: '司法院大法官憲法法庭開庭現場（110 年憲判字第 20...）',
    ),
    CaseImage(
      url:
          'https://tse4.mm.bing.net/th/id/OIP.Q7FEnIHkrd6q9Jmu1GiKkwHaEj?w=248&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '最高法院民事庭開庭大門外觀（110 年憲判字第 20...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.6_z7cGk1TU-RBgQM3tsqZQHaE8?w=221&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '法學文獻與期刊論文引用頁面（110 年憲判字第 20...）',
    ),
    CaseImage(
      url:
          'https://tse4.mm.bing.net/th/id/OIP.0SDoAANiAP6UoZPUrt3UqwHaEN?w=252&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '中華民國六法全書民法債編法條（110 年憲判字第 20...）',
    ),
    CaseImage(
      url:
          'https://tse1.mm.bing.net/th/id/OIP.xExaObj3A3nV3olc0K1gmwHaEJ?w=263&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '民事訴訟小額程序開庭流程圖（110 年憲判字第 20...）',
    ),
    CaseImage(
      url:
          'https://tse3.mm.bing.net/th/id/OIP.RHmdPX6UGcKBDnAmC1DuxQHaE7?w=215&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '判決確定證明書與執行憑證抄本（110 年憲判字第 20...）',
    )
  ],
  'case-160': const [
    CaseImage(
      url:
          'https://tse3.mm.bing.net/th/id/OIP.rgvPoDUIQa-Gb56tJrl6sgHaEO?w=89&h=90&c=1&rs=1&qlt=70&r=0&o=7&pid=InlineBlock&rm=3',
      source: '【本案卷宗封面照片】法庭審判司法天平現場照片',
    ),
    CaseImage(
      url:
          'https://tse4.mm.bing.net/th/id/OIP.0SDoAANiAP6UoZPUrt3UqwHaEN?w=252&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '最高法院司法卷宗圖書館（司法院釋字第 1060 ...）',
    ),
    CaseImage(
      url:
          'https://tse1.mm.bing.net/th/id/OIP.fEDFLQLHjS3QuE4bQLgBvQHaE8?w=229&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '法規沿革與憲法判決法典（司法院釋字第 1060 ...）',
    ),
    CaseImage(
      url:
          'https://tse3.mm.bing.net/th/id/OIP.FzL2M5zkVz2nUbqZg7Qe-QHaE7?w=215&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '本案訴訟卷宗外觀及編號（司法院釋字第 1060 ...）',
    ),
    CaseImage(
      url:
          'https://tse3.mm.bing.net/th/id/OIP.8vGwbgtGBjFRl90_W32HlwHaE7?w=232&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '地方法院簡易庭外觀與開庭公告（司法院釋字第 1060 ...）',
    ),
    CaseImage(
      url:
          'https://tse1.mm.bing.net/th/id/OIP.kgAAgTi1mrNURfP1WvpUNQHaFj?w=89&h=90&c=1&rs=1&qlt=70&r=0&o=7&pid=InlineBlock&rm=3',
      source: '當事人提出之訴狀首頁抄本（司法院釋字第 1060 ...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.CR03_AAGv7DichRpWnF7NQHaE7?w=233&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '司法裁判書電子檔之判決主文（司法院釋字第 1060 ...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.WVO6tR5BzOgw0oglmH02OAHaEP?w=208&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '民事起訴狀與委任律師書狀（司法院釋字第 1060 ...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.wXoezXbxYh3d5XAsPQA1mwHaE8?w=193&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '法院準備程序筆錄簽名欄位（司法院釋字第 1060 ...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.FxsIbUCjMd4IlOEskxShJgHaFj?w=89&h=89&c=1&rs=1&qlt=70&r=0&o=7&pid=InlineBlock&rm=3',
      source: '司法院大法官憲法法庭開庭現場（司法院釋字第 1060 ...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.22mIh8FxQ1xTrLJEOF-vTgHaEO?w=89&h=89&c=1&rs=1&qlt=70&r=0&o=7&pid=InlineBlock&rm=3',
      source: '最高法院民事庭開庭大門外觀（司法院釋字第 1060 ...）',
    ),
    CaseImage(
      url:
          'https://tse4.mm.bing.net/th/id/OIP.Q7FEnIHkrd6q9Jmu1GiKkwHaEj?w=248&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '法學文獻與期刊論文引用頁面（司法院釋字第 1060 ...）',
    ),
    CaseImage(
      url:
          'https://tse4.mm.bing.net/th/id/OIP.BpIJPdGnK-nMpGs5B9306AHaFe?w=206&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '中華民國六法全書民法債編法條（司法院釋字第 1060 ...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.Xt1C-7meX374BAg86KC6LwHaE8?w=89&h=89&c=1&rs=1&qlt=70&r=0&o=7&pid=InlineBlock&rm=3',
      source: '民事訴訟小額程序開庭流程圖（司法院釋字第 1060 ...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.jgOpaPncHSivavrOTSAXLgHaE8?w=232&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '判決確定證明書與執行憑證抄本（司法院釋字第 1060 ...）',
    )
  ],
  'case-161': const [
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.EQboFDqbqWRcR8PTOr3wQwHaDn?w=297&h=171&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '【本案卷宗封面照片】法庭審判司法天平現場照片',
    ),
    CaseImage(
      url:
          'https://tse4.mm.bing.net/th/id/OIP.FVJkOeXgZVSaQPF4GFSr2QHaD8?w=89&h=90&c=1&rs=1&qlt=70&r=0&o=7&pid=InlineBlock&rm=3',
      source: '最高法院司法卷宗圖書館（司法院釋字第 1061 ...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.FxsIbUCjMd4IlOEskxShJgHaFj?w=89&h=89&c=1&rs=1&qlt=70&r=0&o=7&pid=InlineBlock&rm=3',
      source: '法規沿革與憲法判決法典（司法院釋字第 1061 ...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.WVO6tR5BzOgw0oglmH02OAHaEP?w=208&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '本案訴訟卷宗外觀及編號（司法院釋字第 1061 ...）',
    ),
    CaseImage(
      url:
          'https://tse3.mm.bing.net/th/id/OIP.8vGwbgtGBjFRl90_W32HlwHaE7?w=232&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '地方法院簡易庭外觀與開庭公告（司法院釋字第 1061 ...）',
    ),
    CaseImage(
      url:
          'https://tse3.mm.bing.net/th/id/OIP.rgvPoDUIQa-Gb56tJrl6sgHaEO?w=89&h=90&c=1&rs=1&qlt=70&r=0&o=7&pid=InlineBlock&rm=3',
      source: '當事人提出之訴狀首頁抄本（司法院釋字第 1061 ...）',
    ),
    CaseImage(
      url:
          'https://tse4.mm.bing.net/th/id/OIP.BpIJPdGnK-nMpGs5B9306AHaFe?w=206&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '司法裁判書電子檔之判決主文（司法院釋字第 1061 ...）',
    ),
    CaseImage(
      url:
          'https://tse3.mm.bing.net/th/id/OIP.FzL2M5zkVz2nUbqZg7Qe-QHaE7?w=215&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '民事起訴狀與委任律師書狀（司法院釋字第 1061 ...）',
    ),
    CaseImage(
      url:
          'https://tse4.mm.bing.net/th/id/OIP.Q7FEnIHkrd6q9Jmu1GiKkwHaEj?w=248&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '法院準備程序筆錄簽名欄位（司法院釋字第 1061 ...）',
    ),
    CaseImage(
      url:
          'https://tse1.mm.bing.net/th/id/OIP.fEDFLQLHjS3QuE4bQLgBvQHaE8?w=229&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '司法院大法官憲法法庭開庭現場（司法院釋字第 1061 ...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.6_z7cGk1TU-RBgQM3tsqZQHaE8?w=221&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '最高法院民事庭開庭大門外觀（司法院釋字第 1061 ...）',
    ),
    CaseImage(
      url:
          'https://tse1.mm.bing.net/th/id/OIP.kgAAgTi1mrNURfP1WvpUNQHaFj?w=89&h=90&c=1&rs=1&qlt=70&r=0&o=7&pid=InlineBlock&rm=3',
      source: '法學文獻與期刊論文引用頁面（司法院釋字第 1061 ...）',
    ),
    CaseImage(
      url:
          'https://tse3.mm.bing.net/th/id/OIP.RHmdPX6UGcKBDnAmC1DuxQHaE7?w=215&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '中華民國六法全書民法債編法條（司法院釋字第 1061 ...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.22mIh8FxQ1xTrLJEOF-vTgHaEO?w=89&h=89&c=1&rs=1&qlt=70&r=0&o=7&pid=InlineBlock&rm=3',
      source: '民事訴訟小額程序開庭流程圖（司法院釋字第 1061 ...）',
    ),
    CaseImage(
      url:
          'https://tse4.mm.bing.net/th/id/OIP.0SDoAANiAP6UoZPUrt3UqwHaEN?w=252&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '判決確定證明書與執行憑證抄本（司法院釋字第 1061 ...）',
    )
  ],
  'case-162': const [
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.CR03_AAGv7DichRpWnF7NQHaE7?w=233&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '【本案卷宗封面照片】法庭審判司法天平現場照片',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.wXoezXbxYh3d5XAsPQA1mwHaE8?w=193&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '最高法院司法卷宗圖書館（119 年憲判字第 3 ...）',
    ),
    CaseImage(
      url:
          'https://tse1.mm.bing.net/th/id/OIP.xExaObj3A3nV3olc0K1gmwHaEJ?w=263&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '法規沿革與憲法判決法典（119 年憲判字第 3 ...）',
    ),
    CaseImage(
      url:
          'https://tse1.mm.bing.net/th/id/OIP.kgAAgTi1mrNURfP1WvpUNQHaFj?w=89&h=90&c=1&rs=1&qlt=70&r=0&o=7&pid=InlineBlock&rm=3',
      source: '本案訴訟卷宗外觀及編號（119 年憲判字第 3 ...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.6_z7cGk1TU-RBgQM3tsqZQHaE8?w=221&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '地方法院簡易庭外觀與開庭公告（119 年憲判字第 3 ...）',
    ),
    CaseImage(
      url:
          'https://tse3.mm.bing.net/th/id/OIP.8vGwbgtGBjFRl90_W32HlwHaE7?w=232&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '當事人提出之訴狀首頁抄本（119 年憲判字第 3 ...）',
    ),
    CaseImage(
      url:
          'https://tse3.mm.bing.net/th/id/OIP.RHmdPX6UGcKBDnAmC1DuxQHaE7?w=215&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '司法裁判書電子檔之判決主文（119 年憲判字第 3 ...）',
    ),
    CaseImage(
      url:
          'https://tse1.mm.bing.net/th/id/OIP.fEDFLQLHjS3QuE4bQLgBvQHaE8?w=229&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '民事起訴狀與委任律師書狀（119 年憲判字第 3 ...）',
    ),
    CaseImage(
      url:
          'https://tse4.mm.bing.net/th/id/OIP.BpIJPdGnK-nMpGs5B9306AHaFe?w=206&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '法院準備程序筆錄簽名欄位（119 年憲判字第 3 ...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.WVO6tR5BzOgw0oglmH02OAHaEP?w=208&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '司法院大法官憲法法庭開庭現場（119 年憲判字第 3 ...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.22mIh8FxQ1xTrLJEOF-vTgHaEO?w=89&h=89&c=1&rs=1&qlt=70&r=0&o=7&pid=InlineBlock&rm=3',
      source: '最高法院民事庭開庭大門外觀（119 年憲判字第 3 ...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.FxsIbUCjMd4IlOEskxShJgHaFj?w=89&h=89&c=1&rs=1&qlt=70&r=0&o=7&pid=InlineBlock&rm=3',
      source: '法學文獻與期刊論文引用頁面（119 年憲判字第 3 ...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.M1ZTFf8JShiFpHtxNdAuTwHaEz?w=227&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '中華民國六法全書民法債編法條（119 年憲判字第 3 ...）',
    ),
    CaseImage(
      url:
          'https://tse4.mm.bing.net/th/id/OIP.zbbKZ0Bh_CpP6eZamtCRjwHaE9?w=179&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '民事訴訟小額程序開庭流程圖（119 年憲判字第 3 ...）',
    ),
    CaseImage(
      url:
          'https://tse4.mm.bing.net/th/id/OIP.FVJkOeXgZVSaQPF4GFSr2QHaD8?w=89&h=90&c=1&rs=1&qlt=70&r=0&o=7&pid=InlineBlock&rm=3',
      source: '判決確定證明書與執行憑證抄本（119 年憲判字第 3 ...）',
    )
  ],
  'case-163': const [
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.jgOpaPncHSivavrOTSAXLgHaE8?w=232&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '【本案卷宗封面照片】法庭審判司法天平現場照片',
    ),
    CaseImage(
      url:
          'https://tse3.mm.bing.net/th/id/OIP.rgvPoDUIQa-Gb56tJrl6sgHaEO?w=89&h=90&c=1&rs=1&qlt=70&r=0&o=7&pid=InlineBlock&rm=3',
      source: '最高法院司法卷宗圖書館（110 年憲判字第 4 ...）',
    ),
    CaseImage(
      url:
          'https://tse1.mm.bing.net/th/id/OIP.fEDFLQLHjS3QuE4bQLgBvQHaE8?w=229&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '法規沿革與憲法判決法典（110 年憲判字第 4 ...）',
    ),
    CaseImage(
      url:
          'https://tse4.mm.bing.net/th/id/OIP.0SDoAANiAP6UoZPUrt3UqwHaEN?w=252&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '本案訴訟卷宗外觀及編號（110 年憲判字第 4 ...）',
    ),
    CaseImage(
      url:
          'https://tse1.mm.bing.net/th/id/OIP.kgAAgTi1mrNURfP1WvpUNQHaFj?w=89&h=90&c=1&rs=1&qlt=70&r=0&o=7&pid=InlineBlock&rm=3',
      source: '地方法院簡易庭外觀與開庭公告（110 年憲判字第 4 ...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.M1ZTFf8JShiFpHtxNdAuTwHaEz?w=227&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '當事人提出之訴狀首頁抄本（110 年憲判字第 4 ...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.22mIh8FxQ1xTrLJEOF-vTgHaEO?w=89&h=89&c=1&rs=1&qlt=70&r=0&o=7&pid=InlineBlock&rm=3',
      source: '司法裁判書電子檔之判決主文（110 年憲判字第 4 ...）',
    ),
    CaseImage(
      url:
          'https://tse4.mm.bing.net/th/id/OIP.BpIJPdGnK-nMpGs5B9306AHaFe?w=206&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '民事起訴狀與委任律師書狀（110 年憲判字第 4 ...）',
    ),
    CaseImage(
      url:
          'https://tse4.mm.bing.net/th/id/OIP.zbbKZ0Bh_CpP6eZamtCRjwHaE9?w=179&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '法院準備程序筆錄簽名欄位（110 年憲判字第 4 ...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.6_z7cGk1TU-RBgQM3tsqZQHaE8?w=221&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '司法院大法官憲法法庭開庭現場（110 年憲判字第 4 ...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.CR03_AAGv7DichRpWnF7NQHaE7?w=233&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '最高法院民事庭開庭大門外觀（110 年憲判字第 4 ...）',
    ),
    CaseImage(
      url:
          'https://tse3.mm.bing.net/th/id/OIP.RHmdPX6UGcKBDnAmC1DuxQHaE7?w=215&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '法學文獻與期刊論文引用頁面（110 年憲判字第 4 ...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.EQboFDqbqWRcR8PTOr3wQwHaDn?w=297&h=171&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '中華民國六法全書民法債編法條（110 年憲判字第 4 ...）',
    ),
    CaseImage(
      url:
          'https://tse1.mm.bing.net/th/id/OIP.xExaObj3A3nV3olc0K1gmwHaEJ?w=263&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '民事訴訟小額程序開庭流程圖（110 年憲判字第 4 ...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.wXoezXbxYh3d5XAsPQA1mwHaE8?w=193&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '判決確定證明書與執行憑證抄本（110 年憲判字第 4 ...）',
    )
  ],
  'case-164': const [
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.22mIh8FxQ1xTrLJEOF-vTgHaEO?w=89&h=89&c=1&rs=1&qlt=70&r=0&o=7&pid=InlineBlock&rm=3',
      source: '【本案卷宗封面照片】法庭審判司法天平現場照片',
    ),
    CaseImage(
      url:
          'https://tse3.mm.bing.net/th/id/OIP.RHmdPX6UGcKBDnAmC1DuxQHaE7?w=215&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '最高法院司法卷宗圖書館（106年度訴字第264號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.6_z7cGk1TU-RBgQM3tsqZQHaE8?w=221&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '法規沿革與憲法判決法典（106年度訴字第264號...）',
    ),
    CaseImage(
      url:
          'https://tse3.mm.bing.net/th/id/OIP.8vGwbgtGBjFRl90_W32HlwHaE7?w=232&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '本案訴訟卷宗外觀及編號（106年度訴字第264號...）',
    ),
    CaseImage(
      url:
          'https://tse1.mm.bing.net/th/id/OIP.xExaObj3A3nV3olc0K1gmwHaEJ?w=263&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '地方法院簡易庭外觀與開庭公告（106年度訴字第264號...）',
    ),
    CaseImage(
      url:
          'https://tse3.mm.bing.net/th/id/OIP.rgvPoDUIQa-Gb56tJrl6sgHaEO?w=89&h=90&c=1&rs=1&qlt=70&r=0&o=7&pid=InlineBlock&rm=3',
      source: '當事人提出之訴狀首頁抄本（106年度訴字第264號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.EQboFDqbqWRcR8PTOr3wQwHaDn?w=297&h=171&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '司法裁判書電子檔之判決主文（106年度訴字第264號...）',
    ),
    CaseImage(
      url:
          'https://tse4.mm.bing.net/th/id/OIP.0SDoAANiAP6UoZPUrt3UqwHaEN?w=252&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '民事起訴狀與委任律師書狀（106年度訴字第264號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.WVO6tR5BzOgw0oglmH02OAHaEP?w=208&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '法院準備程序筆錄簽名欄位（106年度訴字第264號...）',
    ),
    CaseImage(
      url:
          'https://tse4.mm.bing.net/th/id/OIP.BpIJPdGnK-nMpGs5B9306AHaFe?w=206&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '司法院大法官憲法法庭開庭現場（106年度訴字第264號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.jgOpaPncHSivavrOTSAXLgHaE8?w=232&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '最高法院民事庭開庭大門外觀（106年度訴字第264號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.CR03_AAGv7DichRpWnF7NQHaE7?w=233&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '法學文獻與期刊論文引用頁面（106年度訴字第264號...）',
    ),
    CaseImage(
      url:
          'https://tse1.mm.bing.net/th/id/OIP.fEDFLQLHjS3QuE4bQLgBvQHaE8?w=229&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '中華民國六法全書民法債編法條（106年度訴字第264號...）',
    ),
    CaseImage(
      url:
          'https://tse4.mm.bing.net/th/id/OIP.Q7FEnIHkrd6q9Jmu1GiKkwHaEj?w=248&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '民事訴訟小額程序開庭流程圖（106年度訴字第264號...）',
    ),
    CaseImage(
      url:
          'https://tse4.mm.bing.net/th/id/OIP.zbbKZ0Bh_CpP6eZamtCRjwHaE9?w=179&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '判決確定證明書與執行憑證抄本（106年度訴字第264號...）',
    )
  ],
  'case-165': const [
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.wXoezXbxYh3d5XAsPQA1mwHaE8?w=193&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '【本案卷宗封面照片】法庭審判司法天平現場照片',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.Xt1C-7meX374BAg86KC6LwHaE8?w=89&h=89&c=1&rs=1&qlt=70&r=0&o=7&pid=InlineBlock&rm=3',
      source: '最高法院司法卷宗圖書館（107年度訴字第265號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.WVO6tR5BzOgw0oglmH02OAHaEP?w=208&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '法規沿革與憲法判決法典（107年度訴字第265號...）',
    ),
    CaseImage(
      url:
          'https://tse4.mm.bing.net/th/id/OIP.FVJkOeXgZVSaQPF4GFSr2QHaD8?w=89&h=90&c=1&rs=1&qlt=70&r=0&o=7&pid=InlineBlock&rm=3',
      source: '本案訴訟卷宗外觀及編號（107年度訴字第265號...）',
    ),
    CaseImage(
      url:
          'https://tse4.mm.bing.net/th/id/OIP.Q7FEnIHkrd6q9Jmu1GiKkwHaEj?w=248&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '地方法院簡易庭外觀與開庭公告（107年度訴字第265號...）',
    ),
    CaseImage(
      url:
          'https://tse3.mm.bing.net/th/id/OIP.RHmdPX6UGcKBDnAmC1DuxQHaE7?w=215&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '當事人提出之訴狀首頁抄本（107年度訴字第265號...）',
    ),
    CaseImage(
      url:
          'https://tse1.mm.bing.net/th/id/OIP.xExaObj3A3nV3olc0K1gmwHaEJ?w=263&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '司法裁判書電子檔之判決主文（107年度訴字第265號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.jgOpaPncHSivavrOTSAXLgHaE8?w=232&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '民事起訴狀與委任律師書狀（107年度訴字第265號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.M1ZTFf8JShiFpHtxNdAuTwHaEz?w=227&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '法院準備程序筆錄簽名欄位（107年度訴字第265號...）',
    ),
    CaseImage(
      url:
          'https://tse3.mm.bing.net/th/id/OIP.rgvPoDUIQa-Gb56tJrl6sgHaEO?w=89&h=90&c=1&rs=1&qlt=70&r=0&o=7&pid=InlineBlock&rm=3',
      source: '司法院大法官憲法法庭開庭現場（107年度訴字第265號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.EQboFDqbqWRcR8PTOr3wQwHaDn?w=297&h=171&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '最高法院民事庭開庭大門外觀（107年度訴字第265號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.22mIh8FxQ1xTrLJEOF-vTgHaEO?w=89&h=89&c=1&rs=1&qlt=70&r=0&o=7&pid=InlineBlock&rm=3',
      source: '法學文獻與期刊論文引用頁面（107年度訴字第265號...）',
    ),
    CaseImage(
      url:
          'https://tse4.mm.bing.net/th/id/OIP.BpIJPdGnK-nMpGs5B9306AHaFe?w=206&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '中華民國六法全書民法債編法條（107年度訴字第265號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.6_z7cGk1TU-RBgQM3tsqZQHaE8?w=221&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '民事訴訟小額程序開庭流程圖（107年度訴字第265號...）',
    ),
    CaseImage(
      url:
          'https://tse1.mm.bing.net/th/id/OIP.kgAAgTi1mrNURfP1WvpUNQHaFj?w=89&h=90&c=1&rs=1&qlt=70&r=0&o=7&pid=InlineBlock&rm=3',
      source: '判決確定證明書與執行憑證抄本（107年度訴字第265號...）',
    )
  ],
  'case-166': const [
    CaseImage(
      url:
          'https://tse1.mm.bing.net/th/id/OIP.fEDFLQLHjS3QuE4bQLgBvQHaE8?w=229&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '【本案卷宗封面照片】法庭審判司法天平現場照片',
    ),
    CaseImage(
      url:
          'https://tse1.mm.bing.net/th/id/OIP.kgAAgTi1mrNURfP1WvpUNQHaFj?w=89&h=90&c=1&rs=1&qlt=70&r=0&o=7&pid=InlineBlock&rm=3',
      source: '最高法院司法卷宗圖書館（108年度訴字第266號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.6_z7cGk1TU-RBgQM3tsqZQHaE8?w=221&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '法規沿革與憲法判決法典（108年度訴字第266號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.CR03_AAGv7DichRpWnF7NQHaE7?w=233&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '本案訴訟卷宗外觀及編號（108年度訴字第266號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.jgOpaPncHSivavrOTSAXLgHaE8?w=232&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '地方法院簡易庭外觀與開庭公告（108年度訴字第266號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.wXoezXbxYh3d5XAsPQA1mwHaE8?w=193&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '當事人提出之訴狀首頁抄本（108年度訴字第266號...）',
    ),
    CaseImage(
      url:
          'https://tse3.mm.bing.net/th/id/OIP.RHmdPX6UGcKBDnAmC1DuxQHaE7?w=215&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '司法裁判書電子檔之判決主文（108年度訴字第266號...）',
    ),
    CaseImage(
      url:
          'https://tse4.mm.bing.net/th/id/OIP.BpIJPdGnK-nMpGs5B9306AHaFe?w=206&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '民事起訴狀與委任律師書狀（108年度訴字第266號...）',
    ),
    CaseImage(
      url:
          'https://tse4.mm.bing.net/th/id/OIP.0SDoAANiAP6UoZPUrt3UqwHaEN?w=252&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '法院準備程序筆錄簽名欄位（108年度訴字第266號...）',
    ),
    CaseImage(
      url:
          'https://tse3.mm.bing.net/th/id/OIP.rgvPoDUIQa-Gb56tJrl6sgHaEO?w=89&h=90&c=1&rs=1&qlt=70&r=0&o=7&pid=InlineBlock&rm=3',
      source: '司法院大法官憲法法庭開庭現場（108年度訴字第266號...）',
    ),
    CaseImage(
      url:
          'https://tse4.mm.bing.net/th/id/OIP.zbbKZ0Bh_CpP6eZamtCRjwHaE9?w=179&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '最高法院民事庭開庭大門外觀（108年度訴字第266號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.FxsIbUCjMd4IlOEskxShJgHaFj?w=89&h=89&c=1&rs=1&qlt=70&r=0&o=7&pid=InlineBlock&rm=3',
      source: '法學文獻與期刊論文引用頁面（108年度訴字第266號...）',
    ),
    CaseImage(
      url:
          'https://tse3.mm.bing.net/th/id/OIP.FzL2M5zkVz2nUbqZg7Qe-QHaE7?w=215&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '中華民國六法全書民法債編法條（108年度訴字第266號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.EQboFDqbqWRcR8PTOr3wQwHaDn?w=297&h=171&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '民事訴訟小額程序開庭流程圖（108年度訴字第266號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.WVO6tR5BzOgw0oglmH02OAHaEP?w=208&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '判決確定證明書與執行憑證抄本（108年度訴字第266號...）',
    )
  ],
  'case-167': const [
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.jgOpaPncHSivavrOTSAXLgHaE8?w=232&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '【本案卷宗封面照片】法庭審判司法天平現場照片',
    ),
    CaseImage(
      url:
          'https://tse1.mm.bing.net/th/id/OIP.kgAAgTi1mrNURfP1WvpUNQHaFj?w=89&h=90&c=1&rs=1&qlt=70&r=0&o=7&pid=InlineBlock&rm=3',
      source: '最高法院司法卷宗圖書館（109年度訴字第267號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.WVO6tR5BzOgw0oglmH02OAHaEP?w=208&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '法規沿革與憲法判決法典（109年度訴字第267號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.CR03_AAGv7DichRpWnF7NQHaE7?w=233&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '本案訴訟卷宗外觀及編號（109年度訴字第267號...）',
    ),
    CaseImage(
      url:
          'https://tse4.mm.bing.net/th/id/OIP.zbbKZ0Bh_CpP6eZamtCRjwHaE9?w=179&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '地方法院簡易庭外觀與開庭公告（109年度訴字第267號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.6_z7cGk1TU-RBgQM3tsqZQHaE8?w=221&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '當事人提出之訴狀首頁抄本（109年度訴字第267號...）',
    ),
    CaseImage(
      url:
          'https://tse4.mm.bing.net/th/id/OIP.FVJkOeXgZVSaQPF4GFSr2QHaD8?w=89&h=90&c=1&rs=1&qlt=70&r=0&o=7&pid=InlineBlock&rm=3',
      source: '司法裁判書電子檔之判決主文（109年度訴字第267號...）',
    ),
    CaseImage(
      url:
          'https://tse4.mm.bing.net/th/id/OIP.Q7FEnIHkrd6q9Jmu1GiKkwHaEj?w=248&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '民事起訴狀與委任律師書狀（109年度訴字第267號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.wXoezXbxYh3d5XAsPQA1mwHaE8?w=193&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '法院準備程序筆錄簽名欄位（109年度訴字第267號...）',
    ),
    CaseImage(
      url:
          'https://tse1.mm.bing.net/th/id/OIP.fEDFLQLHjS3QuE4bQLgBvQHaE8?w=229&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '司法院大法官憲法法庭開庭現場（109年度訴字第267號...）',
    ),
    CaseImage(
      url:
          'https://tse3.mm.bing.net/th/id/OIP.rgvPoDUIQa-Gb56tJrl6sgHaEO?w=89&h=90&c=1&rs=1&qlt=70&r=0&o=7&pid=InlineBlock&rm=3',
      source: '最高法院民事庭開庭大門外觀（109年度訴字第267號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.22mIh8FxQ1xTrLJEOF-vTgHaEO?w=89&h=89&c=1&rs=1&qlt=70&r=0&o=7&pid=InlineBlock&rm=3',
      source: '法學文獻與期刊論文引用頁面（109年度訴字第267號...）',
    ),
    CaseImage(
      url:
          'https://tse3.mm.bing.net/th/id/OIP.8vGwbgtGBjFRl90_W32HlwHaE7?w=232&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '中華民國六法全書民法債編法條（109年度訴字第267號...）',
    ),
    CaseImage(
      url:
          'https://tse3.mm.bing.net/th/id/OIP.RHmdPX6UGcKBDnAmC1DuxQHaE7?w=215&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '民事訴訟小額程序開庭流程圖（109年度訴字第267號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.EQboFDqbqWRcR8PTOr3wQwHaDn?w=297&h=171&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '判決確定證明書與執行憑證抄本（109年度訴字第267號...）',
    )
  ],
  'case-168': const [
    CaseImage(
      url:
          'https://tse3.mm.bing.net/th/id/OIP.8vGwbgtGBjFRl90_W32HlwHaE7?w=232&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '【本案卷宗封面照片】法庭審判司法天平現場照片',
    ),
    CaseImage(
      url:
          'https://tse4.mm.bing.net/th/id/OIP.0SDoAANiAP6UoZPUrt3UqwHaEN?w=252&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '最高法院司法卷宗圖書館（107年度訴字第268號...）',
    ),
    CaseImage(
      url:
          'https://tse1.mm.bing.net/th/id/OIP.fEDFLQLHjS3QuE4bQLgBvQHaE8?w=229&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '法規沿革與憲法判決法典（107年度訴字第268號...）',
    ),
    CaseImage(
      url:
          'https://tse3.mm.bing.net/th/id/OIP.RHmdPX6UGcKBDnAmC1DuxQHaE7?w=215&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '本案訴訟卷宗外觀及編號（107年度訴字第268號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.EQboFDqbqWRcR8PTOr3wQwHaDn?w=297&h=171&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '地方法院簡易庭外觀與開庭公告（107年度訴字第268號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.22mIh8FxQ1xTrLJEOF-vTgHaEO?w=89&h=89&c=1&rs=1&qlt=70&r=0&o=7&pid=InlineBlock&rm=3',
      source: '當事人提出之訴狀首頁抄本（107年度訴字第268號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.Xt1C-7meX374BAg86KC6LwHaE8?w=89&h=89&c=1&rs=1&qlt=70&r=0&o=7&pid=InlineBlock&rm=3',
      source: '司法裁判書電子檔之判決主文（107年度訴字第268號...）',
    ),
    CaseImage(
      url:
          'https://tse4.mm.bing.net/th/id/OIP.FVJkOeXgZVSaQPF4GFSr2QHaD8?w=89&h=90&c=1&rs=1&qlt=70&r=0&o=7&pid=InlineBlock&rm=3',
      source: '民事起訴狀與委任律師書狀（107年度訴字第268號...）',
    ),
    CaseImage(
      url:
          'https://tse3.mm.bing.net/th/id/OIP.rgvPoDUIQa-Gb56tJrl6sgHaEO?w=89&h=90&c=1&rs=1&qlt=70&r=0&o=7&pid=InlineBlock&rm=3',
      source: '法院準備程序筆錄簽名欄位（107年度訴字第268號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.6_z7cGk1TU-RBgQM3tsqZQHaE8?w=221&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '司法院大法官憲法法庭開庭現場（107年度訴字第268號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.jgOpaPncHSivavrOTSAXLgHaE8?w=232&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '最高法院民事庭開庭大門外觀（107年度訴字第268號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.wXoezXbxYh3d5XAsPQA1mwHaE8?w=193&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '法學文獻與期刊論文引用頁面（107年度訴字第268號...）',
    ),
    CaseImage(
      url:
          'https://tse4.mm.bing.net/th/id/OIP.Q7FEnIHkrd6q9Jmu1GiKkwHaEj?w=248&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '中華民國六法全書民法債編法條（107年度訴字第268號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.CR03_AAGv7DichRpWnF7NQHaE7?w=233&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '民事訴訟小額程序開庭流程圖（107年度訴字第268號...）',
    ),
    CaseImage(
      url:
          'https://tse4.mm.bing.net/th/id/OIP.BpIJPdGnK-nMpGs5B9306AHaFe?w=206&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '判決確定證明書與執行憑證抄本（107年度訴字第268號...）',
    )
  ],
  'case-169': const [
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.FxsIbUCjMd4IlOEskxShJgHaFj?w=89&h=89&c=1&rs=1&qlt=70&r=0&o=7&pid=InlineBlock&rm=3',
      source: '【本案卷宗封面照片】法庭審判司法天平現場照片',
    ),
    CaseImage(
      url:
          'https://tse1.mm.bing.net/th/id/OIP.kgAAgTi1mrNURfP1WvpUNQHaFj?w=89&h=90&c=1&rs=1&qlt=70&r=0&o=7&pid=InlineBlock&rm=3',
      source: '最高法院司法卷宗圖書館（105年度訴字第269號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.M1ZTFf8JShiFpHtxNdAuTwHaEz?w=227&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '法規沿革與憲法判決法典（105年度訴字第269號...）',
    ),
    CaseImage(
      url:
          'https://tse1.mm.bing.net/th/id/OIP.xExaObj3A3nV3olc0K1gmwHaEJ?w=263&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '本案訴訟卷宗外觀及編號（105年度訴字第269號...）',
    ),
    CaseImage(
      url:
          'https://tse3.mm.bing.net/th/id/OIP.RHmdPX6UGcKBDnAmC1DuxQHaE7?w=215&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '地方法院簡易庭外觀與開庭公告（105年度訴字第269號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.jgOpaPncHSivavrOTSAXLgHaE8?w=232&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '當事人提出之訴狀首頁抄本（105年度訴字第269號...）',
    ),
    CaseImage(
      url:
          'https://tse3.mm.bing.net/th/id/OIP.FzL2M5zkVz2nUbqZg7Qe-QHaE7?w=215&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '司法裁判書電子檔之判決主文（105年度訴字第269號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.WVO6tR5BzOgw0oglmH02OAHaEP?w=208&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '民事起訴狀與委任律師書狀（105年度訴字第269號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.EQboFDqbqWRcR8PTOr3wQwHaDn?w=297&h=171&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '法院準備程序筆錄簽名欄位（105年度訴字第269號...）',
    ),
    CaseImage(
      url:
          'https://tse4.mm.bing.net/th/id/OIP.zbbKZ0Bh_CpP6eZamtCRjwHaE9?w=179&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '司法院大法官憲法法庭開庭現場（105年度訴字第269號...）',
    ),
    CaseImage(
      url:
          'https://tse4.mm.bing.net/th/id/OIP.Q7FEnIHkrd6q9Jmu1GiKkwHaEj?w=248&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '最高法院民事庭開庭大門外觀（105年度訴字第269號...）',
    ),
    CaseImage(
      url:
          'https://tse1.mm.bing.net/th/id/OIP.fEDFLQLHjS3QuE4bQLgBvQHaE8?w=229&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '法學文獻與期刊論文引用頁面（105年度訴字第269號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.CR03_AAGv7DichRpWnF7NQHaE7?w=233&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '中華民國六法全書民法債編法條（105年度訴字第269號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.wXoezXbxYh3d5XAsPQA1mwHaE8?w=193&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '民事訴訟小額程序開庭流程圖（105年度訴字第269號...）',
    ),
    CaseImage(
      url:
          'https://tse4.mm.bing.net/th/id/OIP.0SDoAANiAP6UoZPUrt3UqwHaEN?w=252&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '判決確定證明書與執行憑證抄本（105年度訴字第269號...）',
    )
  ],
  'case-170': const [
    CaseImage(
      url:
          'https://tse3.mm.bing.net/th/id/OIP.rgvPoDUIQa-Gb56tJrl6sgHaEO?w=89&h=90&c=1&rs=1&qlt=70&r=0&o=7&pid=InlineBlock&rm=3',
      source: '【本案卷宗封面照片】法庭審判司法天平現場照片',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.EQboFDqbqWRcR8PTOr3wQwHaDn?w=297&h=171&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '最高法院司法卷宗圖書館（108年度訴字第270號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.22mIh8FxQ1xTrLJEOF-vTgHaEO?w=89&h=89&c=1&rs=1&qlt=70&r=0&o=7&pid=InlineBlock&rm=3',
      source: '法規沿革與憲法判決法典（108年度訴字第270號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.FxsIbUCjMd4IlOEskxShJgHaFj?w=89&h=89&c=1&rs=1&qlt=70&r=0&o=7&pid=InlineBlock&rm=3',
      source: '本案訴訟卷宗外觀及編號（108年度訴字第270號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.wXoezXbxYh3d5XAsPQA1mwHaE8?w=193&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '地方法院簡易庭外觀與開庭公告（108年度訴字第270號...）',
    ),
    CaseImage(
      url:
          'https://tse4.mm.bing.net/th/id/OIP.zbbKZ0Bh_CpP6eZamtCRjwHaE9?w=179&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '當事人提出之訴狀首頁抄本（108年度訴字第270號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.jgOpaPncHSivavrOTSAXLgHaE8?w=232&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '司法裁判書電子檔之判決主文（108年度訴字第270號...）',
    ),
    CaseImage(
      url:
          'https://tse1.mm.bing.net/th/id/OIP.xExaObj3A3nV3olc0K1gmwHaEJ?w=263&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '民事起訴狀與委任律師書狀（108年度訴字第270號...）',
    ),
    CaseImage(
      url:
          'https://tse4.mm.bing.net/th/id/OIP.BpIJPdGnK-nMpGs5B9306AHaFe?w=206&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '法院準備程序筆錄簽名欄位（108年度訴字第270號...）',
    ),
    CaseImage(
      url:
          'https://tse4.mm.bing.net/th/id/OIP.FVJkOeXgZVSaQPF4GFSr2QHaD8?w=89&h=90&c=1&rs=1&qlt=70&r=0&o=7&pid=InlineBlock&rm=3',
      source: '司法院大法官憲法法庭開庭現場（108年度訴字第270號...）',
    ),
    CaseImage(
      url:
          'https://tse1.mm.bing.net/th/id/OIP.fEDFLQLHjS3QuE4bQLgBvQHaE8?w=229&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '最高法院民事庭開庭大門外觀（108年度訴字第270號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.M1ZTFf8JShiFpHtxNdAuTwHaEz?w=227&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '法學文獻與期刊論文引用頁面（108年度訴字第270號...）',
    ),
    CaseImage(
      url:
          'https://tse4.mm.bing.net/th/id/OIP.0SDoAANiAP6UoZPUrt3UqwHaEN?w=252&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '中華民國六法全書民法債編法條（108年度訴字第270號...）',
    ),
    CaseImage(
      url:
          'https://tse3.mm.bing.net/th/id/OIP.RHmdPX6UGcKBDnAmC1DuxQHaE7?w=215&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '民事訴訟小額程序開庭流程圖（108年度訴字第270號...）',
    ),
    CaseImage(
      url:
          'https://tse4.mm.bing.net/th/id/OIP.Q7FEnIHkrd6q9Jmu1GiKkwHaEj?w=248&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '判決確定證明書與執行憑證抄本（108年度訴字第270號...）',
    )
  ],
  'case-171': const [
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.Xt1C-7meX374BAg86KC6LwHaE8?w=89&h=89&c=1&rs=1&qlt=70&r=0&o=7&pid=InlineBlock&rm=3',
      source: '【本案卷宗封面照片】法庭審判司法天平現場照片',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.WVO6tR5BzOgw0oglmH02OAHaEP?w=208&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '最高法院司法卷宗圖書館（107年度訴字第271號...）',
    ),
    CaseImage(
      url:
          'https://tse4.mm.bing.net/th/id/OIP.BpIJPdGnK-nMpGs5B9306AHaFe?w=206&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '法規沿革與憲法判決法典（107年度訴字第271號...）',
    ),
    CaseImage(
      url:
          'https://tse4.mm.bing.net/th/id/OIP.zbbKZ0Bh_CpP6eZamtCRjwHaE9?w=179&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '本案訴訟卷宗外觀及編號（107年度訴字第271號...）',
    ),
    CaseImage(
      url:
          'https://tse3.mm.bing.net/th/id/OIP.RHmdPX6UGcKBDnAmC1DuxQHaE7?w=215&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '地方法院簡易庭外觀與開庭公告（107年度訴字第271號...）',
    ),
    CaseImage(
      url:
          'https://tse1.mm.bing.net/th/id/OIP.fEDFLQLHjS3QuE4bQLgBvQHaE8?w=229&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '當事人提出之訴狀首頁抄本（107年度訴字第271號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.jgOpaPncHSivavrOTSAXLgHaE8?w=232&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '司法裁判書電子檔之判決主文（107年度訴字第271號...）',
    ),
    CaseImage(
      url:
          'https://tse3.mm.bing.net/th/id/OIP.FzL2M5zkVz2nUbqZg7Qe-QHaE7?w=215&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '民事起訴狀與委任律師書狀（107年度訴字第271號...）',
    ),
    CaseImage(
      url:
          'https://tse4.mm.bing.net/th/id/OIP.FVJkOeXgZVSaQPF4GFSr2QHaD8?w=89&h=90&c=1&rs=1&qlt=70&r=0&o=7&pid=InlineBlock&rm=3',
      source: '法院準備程序筆錄簽名欄位（107年度訴字第271號...）',
    ),
    CaseImage(
      url:
          'https://tse3.mm.bing.net/th/id/OIP.rgvPoDUIQa-Gb56tJrl6sgHaEO?w=89&h=90&c=1&rs=1&qlt=70&r=0&o=7&pid=InlineBlock&rm=3',
      source: '司法院大法官憲法法庭開庭現場（107年度訴字第271號...）',
    ),
    CaseImage(
      url:
          'https://tse3.mm.bing.net/th/id/OIP.8vGwbgtGBjFRl90_W32HlwHaE7?w=232&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '最高法院民事庭開庭大門外觀（107年度訴字第271號...）',
    ),
    CaseImage(
      url:
          'https://tse4.mm.bing.net/th/id/OIP.Q7FEnIHkrd6q9Jmu1GiKkwHaEj?w=248&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '法學文獻與期刊論文引用頁面（107年度訴字第271號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.22mIh8FxQ1xTrLJEOF-vTgHaEO?w=89&h=89&c=1&rs=1&qlt=70&r=0&o=7&pid=InlineBlock&rm=3',
      source: '中華民國六法全書民法債編法條（107年度訴字第271號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.EQboFDqbqWRcR8PTOr3wQwHaDn?w=297&h=171&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '民事訴訟小額程序開庭流程圖（107年度訴字第271號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.M1ZTFf8JShiFpHtxNdAuTwHaEz?w=227&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '判決確定證明書與執行憑證抄本（107年度訴字第271號...）',
    )
  ],
  'case-172': const [
    CaseImage(
      url:
          'https://tse4.mm.bing.net/th/id/OIP.zbbKZ0Bh_CpP6eZamtCRjwHaE9?w=179&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '【本案卷宗封面照片】法庭審判司法天平現場照片',
    ),
    CaseImage(
      url:
          'https://tse4.mm.bing.net/th/id/OIP.0SDoAANiAP6UoZPUrt3UqwHaEN?w=252&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '最高法院司法卷宗圖書館（108年度訴字第272號...）',
    ),
    CaseImage(
      url:
          'https://tse3.mm.bing.net/th/id/OIP.8vGwbgtGBjFRl90_W32HlwHaE7?w=232&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '法規沿革與憲法判決法典（108年度訴字第272號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.M1ZTFf8JShiFpHtxNdAuTwHaEz?w=227&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '本案訴訟卷宗外觀及編號（108年度訴字第272號...）',
    ),
    CaseImage(
      url:
          'https://tse4.mm.bing.net/th/id/OIP.BpIJPdGnK-nMpGs5B9306AHaFe?w=206&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '地方法院簡易庭外觀與開庭公告（108年度訴字第272號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.EQboFDqbqWRcR8PTOr3wQwHaDn?w=297&h=171&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '當事人提出之訴狀首頁抄本（108年度訴字第272號...）',
    ),
    CaseImage(
      url:
          'https://tse4.mm.bing.net/th/id/OIP.Q7FEnIHkrd6q9Jmu1GiKkwHaEj?w=248&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '司法裁判書電子檔之判決主文（108年度訴字第272號...）',
    ),
    CaseImage(
      url:
          'https://tse1.mm.bing.net/th/id/OIP.kgAAgTi1mrNURfP1WvpUNQHaFj?w=89&h=90&c=1&rs=1&qlt=70&r=0&o=7&pid=InlineBlock&rm=3',
      source: '民事起訴狀與委任律師書狀（108年度訴字第272號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.jgOpaPncHSivavrOTSAXLgHaE8?w=232&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '法院準備程序筆錄簽名欄位（108年度訴字第272號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.CR03_AAGv7DichRpWnF7NQHaE7?w=233&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '司法院大法官憲法法庭開庭現場（108年度訴字第272號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.FxsIbUCjMd4IlOEskxShJgHaFj?w=89&h=89&c=1&rs=1&qlt=70&r=0&o=7&pid=InlineBlock&rm=3',
      source: '最高法院民事庭開庭大門外觀（108年度訴字第272號...）',
    ),
    CaseImage(
      url:
          'https://tse3.mm.bing.net/th/id/OIP.RHmdPX6UGcKBDnAmC1DuxQHaE7?w=215&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '法學文獻與期刊論文引用頁面（108年度訴字第272號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.22mIh8FxQ1xTrLJEOF-vTgHaEO?w=89&h=89&c=1&rs=1&qlt=70&r=0&o=7&pid=InlineBlock&rm=3',
      source: '中華民國六法全書民法債編法條（108年度訴字第272號...）',
    ),
    CaseImage(
      url:
          'https://tse3.mm.bing.net/th/id/OIP.rgvPoDUIQa-Gb56tJrl6sgHaEO?w=89&h=90&c=1&rs=1&qlt=70&r=0&o=7&pid=InlineBlock&rm=3',
      source: '民事訴訟小額程序開庭流程圖（108年度訴字第272號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.6_z7cGk1TU-RBgQM3tsqZQHaE8?w=221&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '判決確定證明書與執行憑證抄本（108年度訴字第272號...）',
    )
  ],
  'case-173': const [
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.22mIh8FxQ1xTrLJEOF-vTgHaEO?w=89&h=89&c=1&rs=1&qlt=70&r=0&o=7&pid=InlineBlock&rm=3',
      source: '【本案卷宗封面照片】法庭審判司法天平現場照片',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.Xt1C-7meX374BAg86KC6LwHaE8?w=89&h=89&c=1&rs=1&qlt=70&r=0&o=7&pid=InlineBlock&rm=3',
      source: '最高法院司法卷宗圖書館（106年度訴字第273號...）',
    ),
    CaseImage(
      url:
          'https://tse4.mm.bing.net/th/id/OIP.zbbKZ0Bh_CpP6eZamtCRjwHaE9?w=179&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '法規沿革與憲法判決法典（106年度訴字第273號...）',
    ),
    CaseImage(
      url:
          'https://tse3.mm.bing.net/th/id/OIP.RHmdPX6UGcKBDnAmC1DuxQHaE7?w=215&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '本案訴訟卷宗外觀及編號（106年度訴字第273號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.M1ZTFf8JShiFpHtxNdAuTwHaEz?w=227&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '地方法院簡易庭外觀與開庭公告（106年度訴字第273號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.jgOpaPncHSivavrOTSAXLgHaE8?w=232&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '當事人提出之訴狀首頁抄本（106年度訴字第273號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.wXoezXbxYh3d5XAsPQA1mwHaE8?w=193&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '司法裁判書電子檔之判決主文（106年度訴字第273號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.WVO6tR5BzOgw0oglmH02OAHaEP?w=208&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '民事起訴狀與委任律師書狀（106年度訴字第273號...）',
    ),
    CaseImage(
      url:
          'https://tse1.mm.bing.net/th/id/OIP.kgAAgTi1mrNURfP1WvpUNQHaFj?w=89&h=90&c=1&rs=1&qlt=70&r=0&o=7&pid=InlineBlock&rm=3',
      source: '法院準備程序筆錄簽名欄位（106年度訴字第273號...）',
    ),
    CaseImage(
      url:
          'https://tse3.mm.bing.net/th/id/OIP.8vGwbgtGBjFRl90_W32HlwHaE7?w=232&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '司法院大法官憲法法庭開庭現場（106年度訴字第273號...）',
    ),
    CaseImage(
      url:
          'https://tse4.mm.bing.net/th/id/OIP.FVJkOeXgZVSaQPF4GFSr2QHaD8?w=89&h=90&c=1&rs=1&qlt=70&r=0&o=7&pid=InlineBlock&rm=3',
      source: '最高法院民事庭開庭大門外觀（106年度訴字第273號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.6_z7cGk1TU-RBgQM3tsqZQHaE8?w=221&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '法學文獻與期刊論文引用頁面（106年度訴字第273號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.EQboFDqbqWRcR8PTOr3wQwHaDn?w=297&h=171&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '中華民國六法全書民法債編法條（106年度訴字第273號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.CR03_AAGv7DichRpWnF7NQHaE7?w=233&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '民事訴訟小額程序開庭流程圖（106年度訴字第273號...）',
    ),
    CaseImage(
      url:
          'https://tse3.mm.bing.net/th/id/OIP.FzL2M5zkVz2nUbqZg7Qe-QHaE7?w=215&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '判決確定證明書與執行憑證抄本（106年度訴字第273號...）',
    )
  ],
  'case-174': const [
    CaseImage(
      url:
          'https://tse4.mm.bing.net/th/id/OIP.FVJkOeXgZVSaQPF4GFSr2QHaD8?w=89&h=90&c=1&rs=1&qlt=70&r=0&o=7&pid=InlineBlock&rm=3',
      source: '【本案卷宗封面照片】法庭審判司法天平現場照片',
    ),
    CaseImage(
      url:
          'https://tse4.mm.bing.net/th/id/OIP.zbbKZ0Bh_CpP6eZamtCRjwHaE9?w=179&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '最高法院司法卷宗圖書館（109年度訴字第274號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.CR03_AAGv7DichRpWnF7NQHaE7?w=233&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '法規沿革與憲法判決法典（109年度訴字第274號...）',
    ),
    CaseImage(
      url:
          'https://tse3.mm.bing.net/th/id/OIP.FzL2M5zkVz2nUbqZg7Qe-QHaE7?w=215&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '本案訴訟卷宗外觀及編號（109年度訴字第274號...）',
    ),
    CaseImage(
      url:
          'https://tse1.mm.bing.net/th/id/OIP.xExaObj3A3nV3olc0K1gmwHaEJ?w=263&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '地方法院簡易庭外觀與開庭公告（109年度訴字第274號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.wXoezXbxYh3d5XAsPQA1mwHaE8?w=193&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '當事人提出之訴狀首頁抄本（109年度訴字第274號...）',
    ),
    CaseImage(
      url:
          'https://tse3.mm.bing.net/th/id/OIP.rgvPoDUIQa-Gb56tJrl6sgHaEO?w=89&h=90&c=1&rs=1&qlt=70&r=0&o=7&pid=InlineBlock&rm=3',
      source: '司法裁判書電子檔之判決主文（109年度訴字第274號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.jgOpaPncHSivavrOTSAXLgHaE8?w=232&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '民事起訴狀與委任律師書狀（109年度訴字第274號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.M1ZTFf8JShiFpHtxNdAuTwHaEz?w=227&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '法院準備程序筆錄簽名欄位（109年度訴字第274號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.EQboFDqbqWRcR8PTOr3wQwHaDn?w=297&h=171&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '司法院大法官憲法法庭開庭現場（109年度訴字第274號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.FxsIbUCjMd4IlOEskxShJgHaFj?w=89&h=89&c=1&rs=1&qlt=70&r=0&o=7&pid=InlineBlock&rm=3',
      source: '最高法院民事庭開庭大門外觀（109年度訴字第274號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.WVO6tR5BzOgw0oglmH02OAHaEP?w=208&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '法學文獻與期刊論文引用頁面（109年度訴字第274號...）',
    ),
    CaseImage(
      url:
          'https://tse1.mm.bing.net/th/id/OIP.fEDFLQLHjS3QuE4bQLgBvQHaE8?w=229&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '中華民國六法全書民法債編法條（109年度訴字第274號...）',
    ),
    CaseImage(
      url:
          'https://tse4.mm.bing.net/th/id/OIP.Q7FEnIHkrd6q9Jmu1GiKkwHaEj?w=248&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '民事訴訟小額程序開庭流程圖（109年度訴字第274號...）',
    ),
    CaseImage(
      url:
          'https://tse4.mm.bing.net/th/id/OIP.0SDoAANiAP6UoZPUrt3UqwHaEN?w=252&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '判決確定證明書與執行憑證抄本（109年度訴字第274號...）',
    )
  ],
  'case-175': const [
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.wXoezXbxYh3d5XAsPQA1mwHaE8?w=193&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '【本案卷宗封面照片】法庭審判司法天平現場照片',
    ),
    CaseImage(
      url:
          'https://tse4.mm.bing.net/th/id/OIP.Q7FEnIHkrd6q9Jmu1GiKkwHaEj?w=248&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '最高法院司法卷宗圖書館（107年度訴字第275號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.FxsIbUCjMd4IlOEskxShJgHaFj?w=89&h=89&c=1&rs=1&qlt=70&r=0&o=7&pid=InlineBlock&rm=3',
      source: '法規沿革與憲法判決法典（107年度訴字第275號...）',
    ),
    CaseImage(
      url:
          'https://tse4.mm.bing.net/th/id/OIP.0SDoAANiAP6UoZPUrt3UqwHaEN?w=252&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '本案訴訟卷宗外觀及編號（107年度訴字第275號...）',
    ),
    CaseImage(
      url:
          'https://tse1.mm.bing.net/th/id/OIP.kgAAgTi1mrNURfP1WvpUNQHaFj?w=89&h=90&c=1&rs=1&qlt=70&r=0&o=7&pid=InlineBlock&rm=3',
      source: '地方法院簡易庭外觀與開庭公告（107年度訴字第275號...）',
    ),
    CaseImage(
      url:
          'https://tse3.mm.bing.net/th/id/OIP.FzL2M5zkVz2nUbqZg7Qe-QHaE7?w=215&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '當事人提出之訴狀首頁抄本（107年度訴字第275號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.M1ZTFf8JShiFpHtxNdAuTwHaEz?w=227&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '司法裁判書電子檔之判決主文（107年度訴字第275號...）',
    ),
    CaseImage(
      url:
          'https://tse4.mm.bing.net/th/id/OIP.zbbKZ0Bh_CpP6eZamtCRjwHaE9?w=179&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '民事起訴狀與委任律師書狀（107年度訴字第275號...）',
    ),
    CaseImage(
      url:
          'https://tse3.mm.bing.net/th/id/OIP.RHmdPX6UGcKBDnAmC1DuxQHaE7?w=215&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '法院準備程序筆錄簽名欄位（107年度訴字第275號...）',
    ),
    CaseImage(
      url:
          'https://tse4.mm.bing.net/th/id/OIP.FVJkOeXgZVSaQPF4GFSr2QHaD8?w=89&h=90&c=1&rs=1&qlt=70&r=0&o=7&pid=InlineBlock&rm=3',
      source: '司法院大法官憲法法庭開庭現場（107年度訴字第275號...）',
    ),
    CaseImage(
      url:
          'https://tse3.mm.bing.net/th/id/OIP.8vGwbgtGBjFRl90_W32HlwHaE7?w=232&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '最高法院民事庭開庭大門外觀（107年度訴字第275號...）',
    ),
    CaseImage(
      url:
          'https://tse3.mm.bing.net/th/id/OIP.rgvPoDUIQa-Gb56tJrl6sgHaEO?w=89&h=90&c=1&rs=1&qlt=70&r=0&o=7&pid=InlineBlock&rm=3',
      source: '法學文獻與期刊論文引用頁面（107年度訴字第275號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.Xt1C-7meX374BAg86KC6LwHaE8?w=89&h=89&c=1&rs=1&qlt=70&r=0&o=7&pid=InlineBlock&rm=3',
      source: '中華民國六法全書民法債編法條（107年度訴字第275號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.CR03_AAGv7DichRpWnF7NQHaE7?w=233&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '民事訴訟小額程序開庭流程圖（107年度訴字第275號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.22mIh8FxQ1xTrLJEOF-vTgHaEO?w=89&h=89&c=1&rs=1&qlt=70&r=0&o=7&pid=InlineBlock&rm=3',
      source: '判決確定證明書與執行憑證抄本（107年度訴字第275號...）',
    )
  ],
  'case-176': const [
    CaseImage(
      url:
          'https://tse4.mm.bing.net/th/id/OIP.0SDoAANiAP6UoZPUrt3UqwHaEN?w=252&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '【本案卷宗封面照片】法庭審判司法天平現場照片',
    ),
    CaseImage(
      url:
          'https://tse4.mm.bing.net/th/id/OIP.zbbKZ0Bh_CpP6eZamtCRjwHaE9?w=179&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '最高法院司法卷宗圖書館（108年度訴字第276號...）',
    ),
    CaseImage(
      url:
          'https://tse1.mm.bing.net/th/id/OIP.kgAAgTi1mrNURfP1WvpUNQHaFj?w=89&h=90&c=1&rs=1&qlt=70&r=0&o=7&pid=InlineBlock&rm=3',
      source: '法規沿革與憲法判決法典（108年度訴字第276號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.WVO6tR5BzOgw0oglmH02OAHaEP?w=208&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '本案訴訟卷宗外觀及編號（108年度訴字第276號...）',
    ),
    CaseImage(
      url:
          'https://tse1.mm.bing.net/th/id/OIP.xExaObj3A3nV3olc0K1gmwHaEJ?w=263&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '地方法院簡易庭外觀與開庭公告（108年度訴字第276號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.M1ZTFf8JShiFpHtxNdAuTwHaEz?w=227&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '當事人提出之訴狀首頁抄本（108年度訴字第276號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.EQboFDqbqWRcR8PTOr3wQwHaDn?w=297&h=171&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '司法裁判書電子檔之判決主文（108年度訴字第276號...）',
    ),
    CaseImage(
      url:
          'https://tse4.mm.bing.net/th/id/OIP.Q7FEnIHkrd6q9Jmu1GiKkwHaEj?w=248&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '民事起訴狀與委任律師書狀（108年度訴字第276號...）',
    ),
    CaseImage(
      url:
          'https://tse1.mm.bing.net/th/id/OIP.fEDFLQLHjS3QuE4bQLgBvQHaE8?w=229&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '法院準備程序筆錄簽名欄位（108年度訴字第276號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.6_z7cGk1TU-RBgQM3tsqZQHaE8?w=221&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '司法院大法官憲法法庭開庭現場（108年度訴字第276號...）',
    ),
    CaseImage(
      url:
          'https://tse3.mm.bing.net/th/id/OIP.FzL2M5zkVz2nUbqZg7Qe-QHaE7?w=215&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '最高法院民事庭開庭大門外觀（108年度訴字第276號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.jgOpaPncHSivavrOTSAXLgHaE8?w=232&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '法學文獻與期刊論文引用頁面（108年度訴字第276號...）',
    ),
    CaseImage(
      url:
          'https://tse4.mm.bing.net/th/id/OIP.BpIJPdGnK-nMpGs5B9306AHaFe?w=206&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '中華民國六法全書民法債編法條（108年度訴字第276號...）',
    ),
    CaseImage(
      url:
          'https://tse3.mm.bing.net/th/id/OIP.8vGwbgtGBjFRl90_W32HlwHaE7?w=232&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '民事訴訟小額程序開庭流程圖（108年度訴字第276號...）',
    ),
    CaseImage(
      url:
          'https://tse3.mm.bing.net/th/id/OIP.RHmdPX6UGcKBDnAmC1DuxQHaE7?w=215&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '判決確定證明書與執行憑證抄本（108年度訴字第276號...）',
    )
  ],
  'case-177': const [
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.CR03_AAGv7DichRpWnF7NQHaE7?w=233&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '【本案卷宗封面照片】法庭審判司法天平現場照片',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.EQboFDqbqWRcR8PTOr3wQwHaDn?w=297&h=171&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '最高法院司法卷宗圖書館（106年度訴字第277號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.jgOpaPncHSivavrOTSAXLgHaE8?w=232&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '法規沿革與憲法判決法典（106年度訴字第277號...）',
    ),
    CaseImage(
      url:
          'https://tse4.mm.bing.net/th/id/OIP.Q7FEnIHkrd6q9Jmu1GiKkwHaEj?w=248&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '本案訴訟卷宗外觀及編號（106年度訴字第277號...）',
    ),
    CaseImage(
      url:
          'https://tse4.mm.bing.net/th/id/OIP.FVJkOeXgZVSaQPF4GFSr2QHaD8?w=89&h=90&c=1&rs=1&qlt=70&r=0&o=7&pid=InlineBlock&rm=3',
      source: '地方法院簡易庭外觀與開庭公告（106年度訴字第277號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.WVO6tR5BzOgw0oglmH02OAHaEP?w=208&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '當事人提出之訴狀首頁抄本（106年度訴字第277號...）',
    ),
    CaseImage(
      url:
          'https://tse4.mm.bing.net/th/id/OIP.0SDoAANiAP6UoZPUrt3UqwHaEN?w=252&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '司法裁判書電子檔之判決主文（106年度訴字第277號...）',
    ),
    CaseImage(
      url:
          'https://tse3.mm.bing.net/th/id/OIP.rgvPoDUIQa-Gb56tJrl6sgHaEO?w=89&h=90&c=1&rs=1&qlt=70&r=0&o=7&pid=InlineBlock&rm=3',
      source: '民事起訴狀與委任律師書狀（106年度訴字第277號...）',
    ),
    CaseImage(
      url:
          'https://tse4.mm.bing.net/th/id/OIP.zbbKZ0Bh_CpP6eZamtCRjwHaE9?w=179&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '法院準備程序筆錄簽名欄位（106年度訴字第277號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.FxsIbUCjMd4IlOEskxShJgHaFj?w=89&h=89&c=1&rs=1&qlt=70&r=0&o=7&pid=InlineBlock&rm=3',
      source: '司法院大法官憲法法庭開庭現場（106年度訴字第277號...）',
    ),
    CaseImage(
      url:
          'https://tse1.mm.bing.net/th/id/OIP.xExaObj3A3nV3olc0K1gmwHaEJ?w=263&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '最高法院民事庭開庭大門外觀（106年度訴字第277號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.6_z7cGk1TU-RBgQM3tsqZQHaE8?w=221&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '法學文獻與期刊論文引用頁面（106年度訴字第277號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.22mIh8FxQ1xTrLJEOF-vTgHaEO?w=89&h=89&c=1&rs=1&qlt=70&r=0&o=7&pid=InlineBlock&rm=3',
      source: '中華民國六法全書民法債編法條（106年度訴字第277號...）',
    ),
    CaseImage(
      url:
          'https://tse3.mm.bing.net/th/id/OIP.RHmdPX6UGcKBDnAmC1DuxQHaE7?w=215&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '民事訴訟小額程序開庭流程圖（106年度訴字第277號...）',
    ),
    CaseImage(
      url:
          'https://tse1.mm.bing.net/th/id/OIP.kgAAgTi1mrNURfP1WvpUNQHaFj?w=89&h=90&c=1&rs=1&qlt=70&r=0&o=7&pid=InlineBlock&rm=3',
      source: '判決確定證明書與執行憑證抄本（106年度訴字第277號...）',
    )
  ],
  'case-178': const [
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.M1ZTFf8JShiFpHtxNdAuTwHaEz?w=227&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '【本案卷宗封面照片】法庭審判司法天平現場照片',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.wXoezXbxYh3d5XAsPQA1mwHaE8?w=193&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '最高法院司法卷宗圖書館（109年度訴字第278號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.EQboFDqbqWRcR8PTOr3wQwHaDn?w=297&h=171&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '法規沿革與憲法判決法典（109年度訴字第278號...）',
    ),
    CaseImage(
      url:
          'https://tse3.mm.bing.net/th/id/OIP.RHmdPX6UGcKBDnAmC1DuxQHaE7?w=215&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '本案訴訟卷宗外觀及編號（109年度訴字第278號...）',
    ),
    CaseImage(
      url:
          'https://tse1.mm.bing.net/th/id/OIP.xExaObj3A3nV3olc0K1gmwHaEJ?w=263&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '地方法院簡易庭外觀與開庭公告（109年度訴字第278號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.WVO6tR5BzOgw0oglmH02OAHaEP?w=208&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '當事人提出之訴狀首頁抄本（109年度訴字第278號...）',
    ),
    CaseImage(
      url:
          'https://tse4.mm.bing.net/th/id/OIP.0SDoAANiAP6UoZPUrt3UqwHaEN?w=252&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '司法裁判書電子檔之判決主文（109年度訴字第278號...）',
    ),
    CaseImage(
      url:
          'https://tse4.mm.bing.net/th/id/OIP.Q7FEnIHkrd6q9Jmu1GiKkwHaEj?w=248&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '民事起訴狀與委任律師書狀（109年度訴字第278號...）',
    ),
    CaseImage(
      url:
          'https://tse3.mm.bing.net/th/id/OIP.8vGwbgtGBjFRl90_W32HlwHaE7?w=232&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '法院準備程序筆錄簽名欄位（109年度訴字第278號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.Xt1C-7meX374BAg86KC6LwHaE8?w=89&h=89&c=1&rs=1&qlt=70&r=0&o=7&pid=InlineBlock&rm=3',
      source: '司法院大法官憲法法庭開庭現場（109年度訴字第278號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.6_z7cGk1TU-RBgQM3tsqZQHaE8?w=221&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '最高法院民事庭開庭大門外觀（109年度訴字第278號...）',
    ),
    CaseImage(
      url:
          'https://tse4.mm.bing.net/th/id/OIP.BpIJPdGnK-nMpGs5B9306AHaFe?w=206&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '法學文獻與期刊論文引用頁面（109年度訴字第278號...）',
    ),
    CaseImage(
      url:
          'https://tse4.mm.bing.net/th/id/OIP.FVJkOeXgZVSaQPF4GFSr2QHaD8?w=89&h=90&c=1&rs=1&qlt=70&r=0&o=7&pid=InlineBlock&rm=3',
      source: '中華民國六法全書民法債編法條（109年度訴字第278號...）',
    ),
    CaseImage(
      url:
          'https://tse4.mm.bing.net/th/id/OIP.zbbKZ0Bh_CpP6eZamtCRjwHaE9?w=179&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '民事訴訟小額程序開庭流程圖（109年度訴字第278號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.CR03_AAGv7DichRpWnF7NQHaE7?w=233&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '判決確定證明書與執行憑證抄本（109年度訴字第278號...）',
    )
  ],
  'case-179': const [
    CaseImage(
      url:
          'https://tse4.mm.bing.net/th/id/OIP.0SDoAANiAP6UoZPUrt3UqwHaEN?w=252&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '【本案卷宗封面照片】法庭審判司法天平現場照片',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.22mIh8FxQ1xTrLJEOF-vTgHaEO?w=89&h=89&c=1&rs=1&qlt=70&r=0&o=7&pid=InlineBlock&rm=3',
      source: '最高法院司法卷宗圖書館（107年度訴字第279號...）',
    ),
    CaseImage(
      url:
          'https://tse1.mm.bing.net/th/id/OIP.fEDFLQLHjS3QuE4bQLgBvQHaE8?w=229&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '法規沿革與憲法判決法典（107年度訴字第279號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.wXoezXbxYh3d5XAsPQA1mwHaE8?w=193&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '本案訴訟卷宗外觀及編號（107年度訴字第279號...）',
    ),
    CaseImage(
      url:
          'https://tse4.mm.bing.net/th/id/OIP.Q7FEnIHkrd6q9Jmu1GiKkwHaEj?w=248&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '地方法院簡易庭外觀與開庭公告（107年度訴字第279號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.6_z7cGk1TU-RBgQM3tsqZQHaE8?w=221&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '當事人提出之訴狀首頁抄本（107年度訴字第279號...）',
    ),
    CaseImage(
      url:
          'https://tse1.mm.bing.net/th/id/OIP.kgAAgTi1mrNURfP1WvpUNQHaFj?w=89&h=90&c=1&rs=1&qlt=70&r=0&o=7&pid=InlineBlock&rm=3',
      source: '司法裁判書電子檔之判決主文（107年度訴字第279號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.CR03_AAGv7DichRpWnF7NQHaE7?w=233&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '民事起訴狀與委任律師書狀（107年度訴字第279號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.Xt1C-7meX374BAg86KC6LwHaE8?w=89&h=89&c=1&rs=1&qlt=70&r=0&o=7&pid=InlineBlock&rm=3',
      source: '法院準備程序筆錄簽名欄位（107年度訴字第279號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.FxsIbUCjMd4IlOEskxShJgHaFj?w=89&h=89&c=1&rs=1&qlt=70&r=0&o=7&pid=InlineBlock&rm=3',
      source: '司法院大法官憲法法庭開庭現場（107年度訴字第279號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.EQboFDqbqWRcR8PTOr3wQwHaDn?w=297&h=171&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '最高法院民事庭開庭大門外觀（107年度訴字第279號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.WVO6tR5BzOgw0oglmH02OAHaEP?w=208&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '法學文獻與期刊論文引用頁面（107年度訴字第279號...）',
    ),
    CaseImage(
      url:
          'https://tse1.mm.bing.net/th/id/OIP.xExaObj3A3nV3olc0K1gmwHaEJ?w=263&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '中華民國六法全書民法債編法條（107年度訴字第279號...）',
    ),
    CaseImage(
      url:
          'https://tse3.mm.bing.net/th/id/OIP.8vGwbgtGBjFRl90_W32HlwHaE7?w=232&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '民事訴訟小額程序開庭流程圖（107年度訴字第279號...）',
    ),
    CaseImage(
      url:
          'https://tse4.mm.bing.net/th/id/OIP.FVJkOeXgZVSaQPF4GFSr2QHaD8?w=89&h=90&c=1&rs=1&qlt=70&r=0&o=7&pid=InlineBlock&rm=3',
      source: '判決確定證明書與執行憑證抄本（107年度訴字第279號...）',
    )
  ],
  'case-180': const [
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.EQboFDqbqWRcR8PTOr3wQwHaDn?w=297&h=171&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '【本案卷宗封面照片】法庭審判司法天平現場照片',
    ),
    CaseImage(
      url:
          'https://tse3.mm.bing.net/th/id/OIP.FzL2M5zkVz2nUbqZg7Qe-QHaE7?w=215&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '最高法院司法卷宗圖書館（106年度訴字第280號...）',
    ),
    CaseImage(
      url:
          'https://tse4.mm.bing.net/th/id/OIP.zbbKZ0Bh_CpP6eZamtCRjwHaE9?w=179&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '法規沿革與憲法判決法典（106年度訴字第280號...）',
    ),
    CaseImage(
      url:
          'https://tse1.mm.bing.net/th/id/OIP.fEDFLQLHjS3QuE4bQLgBvQHaE8?w=229&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '本案訴訟卷宗外觀及編號（106年度訴字第280號...）',
    ),
    CaseImage(
      url:
          'https://tse4.mm.bing.net/th/id/OIP.0SDoAANiAP6UoZPUrt3UqwHaEN?w=252&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '地方法院簡易庭外觀與開庭公告（106年度訴字第280號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.CR03_AAGv7DichRpWnF7NQHaE7?w=233&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '當事人提出之訴狀首頁抄本（106年度訴字第280號...）',
    ),
    CaseImage(
      url:
          'https://tse3.mm.bing.net/th/id/OIP.rgvPoDUIQa-Gb56tJrl6sgHaEO?w=89&h=90&c=1&rs=1&qlt=70&r=0&o=7&pid=InlineBlock&rm=3',
      source: '司法裁判書電子檔之判決主文（106年度訴字第280號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.wXoezXbxYh3d5XAsPQA1mwHaE8?w=193&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '民事起訴狀與委任律師書狀（106年度訴字第280號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.FxsIbUCjMd4IlOEskxShJgHaFj?w=89&h=89&c=1&rs=1&qlt=70&r=0&o=7&pid=InlineBlock&rm=3',
      source: '法院準備程序筆錄簽名欄位（106年度訴字第280號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.22mIh8FxQ1xTrLJEOF-vTgHaEO?w=89&h=89&c=1&rs=1&qlt=70&r=0&o=7&pid=InlineBlock&rm=3',
      source: '司法院大法官憲法法庭開庭現場（106年度訴字第280號...）',
    ),
    CaseImage(
      url:
          'https://tse3.mm.bing.net/th/id/OIP.8vGwbgtGBjFRl90_W32HlwHaE7?w=232&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '最高法院民事庭開庭大門外觀（106年度訴字第280號...）',
    ),
    CaseImage(
      url:
          'https://tse4.mm.bing.net/th/id/OIP.FVJkOeXgZVSaQPF4GFSr2QHaD8?w=89&h=90&c=1&rs=1&qlt=70&r=0&o=7&pid=InlineBlock&rm=3',
      source: '法學文獻與期刊論文引用頁面（106年度訴字第280號...）',
    ),
    CaseImage(
      url:
          'https://tse3.mm.bing.net/th/id/OIP.RHmdPX6UGcKBDnAmC1DuxQHaE7?w=215&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '中華民國六法全書民法債編法條（106年度訴字第280號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.jgOpaPncHSivavrOTSAXLgHaE8?w=232&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '民事訴訟小額程序開庭流程圖（106年度訴字第280號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.6_z7cGk1TU-RBgQM3tsqZQHaE8?w=221&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '判決確定證明書與執行憑證抄本（106年度訴字第280號...）',
    )
  ],
  'case-181': const [
    CaseImage(
      url:
          'https://tse4.mm.bing.net/th/id/OIP.Q7FEnIHkrd6q9Jmu1GiKkwHaEj?w=248&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '【本案卷宗封面照片】法庭審判司法天平現場照片',
    ),
    CaseImage(
      url:
          'https://tse3.mm.bing.net/th/id/OIP.RHmdPX6UGcKBDnAmC1DuxQHaE7?w=215&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '最高法院司法卷宗圖書館（108年度訴字第281號...）',
    ),
    CaseImage(
      url:
          'https://tse4.mm.bing.net/th/id/OIP.0SDoAANiAP6UoZPUrt3UqwHaEN?w=252&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '法規沿革與憲法判決法典（108年度訴字第281號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.EQboFDqbqWRcR8PTOr3wQwHaDn?w=297&h=171&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '本案訴訟卷宗外觀及編號（108年度訴字第281號...）',
    ),
    CaseImage(
      url:
          'https://tse1.mm.bing.net/th/id/OIP.xExaObj3A3nV3olc0K1gmwHaEJ?w=263&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '地方法院簡易庭外觀與開庭公告（108年度訴字第281號...）',
    ),
    CaseImage(
      url:
          'https://tse4.mm.bing.net/th/id/OIP.BpIJPdGnK-nMpGs5B9306AHaFe?w=206&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '當事人提出之訴狀首頁抄本（108年度訴字第281號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.Xt1C-7meX374BAg86KC6LwHaE8?w=89&h=89&c=1&rs=1&qlt=70&r=0&o=7&pid=InlineBlock&rm=3',
      source: '司法裁判書電子檔之判決主文（108年度訴字第281號...）',
    ),
    CaseImage(
      url:
          'https://tse4.mm.bing.net/th/id/OIP.FVJkOeXgZVSaQPF4GFSr2QHaD8?w=89&h=90&c=1&rs=1&qlt=70&r=0&o=7&pid=InlineBlock&rm=3',
      source: '民事起訴狀與委任律師書狀（108年度訴字第281號...）',
    ),
    CaseImage(
      url:
          'https://tse4.mm.bing.net/th/id/OIP.zbbKZ0Bh_CpP6eZamtCRjwHaE9?w=179&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '法院準備程序筆錄簽名欄位（108年度訴字第281號...）',
    ),
    CaseImage(
      url:
          'https://tse1.mm.bing.net/th/id/OIP.kgAAgTi1mrNURfP1WvpUNQHaFj?w=89&h=90&c=1&rs=1&qlt=70&r=0&o=7&pid=InlineBlock&rm=3',
      source: '司法院大法官憲法法庭開庭現場（108年度訴字第281號...）',
    ),
    CaseImage(
      url:
          'https://tse1.mm.bing.net/th/id/OIP.fEDFLQLHjS3QuE4bQLgBvQHaE8?w=229&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '最高法院民事庭開庭大門外觀（108年度訴字第281號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.WVO6tR5BzOgw0oglmH02OAHaEP?w=208&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '法學文獻與期刊論文引用頁面（108年度訴字第281號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.M1ZTFf8JShiFpHtxNdAuTwHaEz?w=227&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '中華民國六法全書民法債編法條（108年度訴字第281號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.CR03_AAGv7DichRpWnF7NQHaE7?w=233&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '民事訴訟小額程序開庭流程圖（108年度訴字第281號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.22mIh8FxQ1xTrLJEOF-vTgHaEO?w=89&h=89&c=1&rs=1&qlt=70&r=0&o=7&pid=InlineBlock&rm=3',
      source: '判決確定證明書與執行憑證抄本（108年度訴字第281號...）',
    )
  ],
  'case-182': const [
    CaseImage(
      url:
          'https://tse1.mm.bing.net/th/id/OIP.kgAAgTi1mrNURfP1WvpUNQHaFj?w=89&h=90&c=1&rs=1&qlt=70&r=0&o=7&pid=InlineBlock&rm=3',
      source: '【本案卷宗封面照片】法庭審判司法天平現場照片',
    ),
    CaseImage(
      url:
          'https://tse3.mm.bing.net/th/id/OIP.RHmdPX6UGcKBDnAmC1DuxQHaE7?w=215&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '最高法院司法卷宗圖書館（108年度訴字第282號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.Xt1C-7meX374BAg86KC6LwHaE8?w=89&h=89&c=1&rs=1&qlt=70&r=0&o=7&pid=InlineBlock&rm=3',
      source: '法規沿革與憲法判決法典（108年度訴字第282號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.M1ZTFf8JShiFpHtxNdAuTwHaEz?w=227&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '本案訴訟卷宗外觀及編號（108年度訴字第282號...）',
    ),
    CaseImage(
      url:
          'https://tse3.mm.bing.net/th/id/OIP.rgvPoDUIQa-Gb56tJrl6sgHaEO?w=89&h=90&c=1&rs=1&qlt=70&r=0&o=7&pid=InlineBlock&rm=3',
      source: '地方法院簡易庭外觀與開庭公告（108年度訴字第282號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.WVO6tR5BzOgw0oglmH02OAHaEP?w=208&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '當事人提出之訴狀首頁抄本（108年度訴字第282號...）',
    ),
    CaseImage(
      url:
          'https://tse4.mm.bing.net/th/id/OIP.Q7FEnIHkrd6q9Jmu1GiKkwHaEj?w=248&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '司法裁判書電子檔之判決主文（108年度訴字第282號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.wXoezXbxYh3d5XAsPQA1mwHaE8?w=193&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '民事起訴狀與委任律師書狀（108年度訴字第282號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.CR03_AAGv7DichRpWnF7NQHaE7?w=233&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '法院準備程序筆錄簽名欄位（108年度訴字第282號...）',
    ),
    CaseImage(
      url:
          'https://tse3.mm.bing.net/th/id/OIP.8vGwbgtGBjFRl90_W32HlwHaE7?w=232&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '司法院大法官憲法法庭開庭現場（108年度訴字第282號...）',
    ),
    CaseImage(
      url:
          'https://tse1.mm.bing.net/th/id/OIP.xExaObj3A3nV3olc0K1gmwHaEJ?w=263&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '最高法院民事庭開庭大門外觀（108年度訴字第282號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.EQboFDqbqWRcR8PTOr3wQwHaDn?w=297&h=171&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '法學文獻與期刊論文引用頁面（108年度訴字第282號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.FxsIbUCjMd4IlOEskxShJgHaFj?w=89&h=89&c=1&rs=1&qlt=70&r=0&o=7&pid=InlineBlock&rm=3',
      source: '中華民國六法全書民法債編法條（108年度訴字第282號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.jgOpaPncHSivavrOTSAXLgHaE8?w=232&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '民事訴訟小額程序開庭流程圖（108年度訴字第282號...）',
    ),
    CaseImage(
      url:
          'https://tse1.mm.bing.net/th/id/OIP.fEDFLQLHjS3QuE4bQLgBvQHaE8?w=229&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '判決確定證明書與執行憑證抄本（108年度訴字第282號...）',
    )
  ],
  'case-183': const [
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.M1ZTFf8JShiFpHtxNdAuTwHaEz?w=227&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '【本案卷宗封面照片】法庭審判司法天平現場照片',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.CR03_AAGv7DichRpWnF7NQHaE7?w=233&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '最高法院司法卷宗圖書館（107年度訴字第283號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.Xt1C-7meX374BAg86KC6LwHaE8?w=89&h=89&c=1&rs=1&qlt=70&r=0&o=7&pid=InlineBlock&rm=3',
      source: '法規沿革與憲法判決法典（107年度訴字第283號...）',
    ),
    CaseImage(
      url:
          'https://tse1.mm.bing.net/th/id/OIP.xExaObj3A3nV3olc0K1gmwHaEJ?w=263&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '本案訴訟卷宗外觀及編號（107年度訴字第283號...）',
    ),
    CaseImage(
      url:
          'https://tse3.mm.bing.net/th/id/OIP.rgvPoDUIQa-Gb56tJrl6sgHaEO?w=89&h=90&c=1&rs=1&qlt=70&r=0&o=7&pid=InlineBlock&rm=3',
      source: '地方法院簡易庭外觀與開庭公告（107年度訴字第283號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.wXoezXbxYh3d5XAsPQA1mwHaE8?w=193&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '當事人提出之訴狀首頁抄本（107年度訴字第283號...）',
    ),
    CaseImage(
      url:
          'https://tse4.mm.bing.net/th/id/OIP.0SDoAANiAP6UoZPUrt3UqwHaEN?w=252&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '司法裁判書電子檔之判決主文（107年度訴字第283號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.WVO6tR5BzOgw0oglmH02OAHaEP?w=208&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '民事起訴狀與委任律師書狀（107年度訴字第283號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.22mIh8FxQ1xTrLJEOF-vTgHaEO?w=89&h=89&c=1&rs=1&qlt=70&r=0&o=7&pid=InlineBlock&rm=3',
      source: '法院準備程序筆錄簽名欄位（107年度訴字第283號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.6_z7cGk1TU-RBgQM3tsqZQHaE8?w=221&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '司法院大法官憲法法庭開庭現場（107年度訴字第283號...）',
    ),
    CaseImage(
      url:
          'https://tse3.mm.bing.net/th/id/OIP.FzL2M5zkVz2nUbqZg7Qe-QHaE7?w=215&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '最高法院民事庭開庭大門外觀（107年度訴字第283號...）',
    ),
    CaseImage(
      url:
          'https://tse3.mm.bing.net/th/id/OIP.8vGwbgtGBjFRl90_W32HlwHaE7?w=232&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '法學文獻與期刊論文引用頁面（107年度訴字第283號...）',
    ),
    CaseImage(
      url:
          'https://tse1.mm.bing.net/th/id/OIP.fEDFLQLHjS3QuE4bQLgBvQHaE8?w=229&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '中華民國六法全書民法債編法條（107年度訴字第283號...）',
    ),
    CaseImage(
      url:
          'https://tse4.mm.bing.net/th/id/OIP.FVJkOeXgZVSaQPF4GFSr2QHaD8?w=89&h=90&c=1&rs=1&qlt=70&r=0&o=7&pid=InlineBlock&rm=3',
      source: '民事訴訟小額程序開庭流程圖（107年度訴字第283號...）',
    ),
    CaseImage(
      url:
          'https://tse4.mm.bing.net/th/id/OIP.zbbKZ0Bh_CpP6eZamtCRjwHaE9?w=179&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '判決確定證明書與執行憑證抄本（107年度訴字第283號...）',
    )
  ],
  'case-184': const [
    CaseImage(
      url:
          'https://tse1.mm.bing.net/th/id/OIP.fEDFLQLHjS3QuE4bQLgBvQHaE8?w=229&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '【本案卷宗封面照片】法庭審判司法天平現場照片',
    ),
    CaseImage(
      url:
          'https://tse4.mm.bing.net/th/id/OIP.BpIJPdGnK-nMpGs5B9306AHaFe?w=206&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '最高法院司法卷宗圖書館（105年度訴字第284號...）',
    ),
    CaseImage(
      url:
          'https://tse3.mm.bing.net/th/id/OIP.8vGwbgtGBjFRl90_W32HlwHaE7?w=232&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '法規沿革與憲法判決法典（105年度訴字第284號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.CR03_AAGv7DichRpWnF7NQHaE7?w=233&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '本案訴訟卷宗外觀及編號（105年度訴字第284號...）',
    ),
    CaseImage(
      url:
          'https://tse3.mm.bing.net/th/id/OIP.FzL2M5zkVz2nUbqZg7Qe-QHaE7?w=215&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '地方法院簡易庭外觀與開庭公告（105年度訴字第284號...）',
    ),
    CaseImage(
      url:
          'https://tse3.mm.bing.net/th/id/OIP.RHmdPX6UGcKBDnAmC1DuxQHaE7?w=215&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '當事人提出之訴狀首頁抄本（105年度訴字第284號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.22mIh8FxQ1xTrLJEOF-vTgHaEO?w=89&h=89&c=1&rs=1&qlt=70&r=0&o=7&pid=InlineBlock&rm=3',
      source: '司法裁判書電子檔之判決主文（105年度訴字第284號...）',
    ),
    CaseImage(
      url:
          'https://tse4.mm.bing.net/th/id/OIP.zbbKZ0Bh_CpP6eZamtCRjwHaE9?w=179&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '民事起訴狀與委任律師書狀（105年度訴字第284號...）',
    ),
    CaseImage(
      url:
          'https://tse4.mm.bing.net/th/id/OIP.FVJkOeXgZVSaQPF4GFSr2QHaD8?w=89&h=90&c=1&rs=1&qlt=70&r=0&o=7&pid=InlineBlock&rm=3',
      source: '法院準備程序筆錄簽名欄位（105年度訴字第284號...）',
    ),
    CaseImage(
      url:
          'https://tse3.mm.bing.net/th/id/OIP.rgvPoDUIQa-Gb56tJrl6sgHaEO?w=89&h=90&c=1&rs=1&qlt=70&r=0&o=7&pid=InlineBlock&rm=3',
      source: '司法院大法官憲法法庭開庭現場（105年度訴字第284號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.FxsIbUCjMd4IlOEskxShJgHaFj?w=89&h=89&c=1&rs=1&qlt=70&r=0&o=7&pid=InlineBlock&rm=3',
      source: '最高法院民事庭開庭大門外觀（105年度訴字第284號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.Xt1C-7meX374BAg86KC6LwHaE8?w=89&h=89&c=1&rs=1&qlt=70&r=0&o=7&pid=InlineBlock&rm=3',
      source: '法學文獻與期刊論文引用頁面（105年度訴字第284號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.jgOpaPncHSivavrOTSAXLgHaE8?w=232&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '中華民國六法全書民法債編法條（105年度訴字第284號...）',
    ),
    CaseImage(
      url:
          'https://tse1.mm.bing.net/th/id/OIP.kgAAgTi1mrNURfP1WvpUNQHaFj?w=89&h=90&c=1&rs=1&qlt=70&r=0&o=7&pid=InlineBlock&rm=3',
      source: '民事訴訟小額程序開庭流程圖（105年度訴字第284號...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.6_z7cGk1TU-RBgQM3tsqZQHaE8?w=221&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '判決確定證明書與執行憑證抄本（105年度訴字第284號...）',
    )
  ],
  'case-185': const [
    CaseImage(
      url:
          'https://tse3.mm.bing.net/th/id/OIP.RHmdPX6UGcKBDnAmC1DuxQHaE7?w=215&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '【本案卷宗封面照片】法庭審判司法天平現場照片',
    ),
    CaseImage(
      url:
          'https://tse4.mm.bing.net/th/id/OIP.FVJkOeXgZVSaQPF4GFSr2QHaD8?w=89&h=90&c=1&rs=1&qlt=70&r=0&o=7&pid=InlineBlock&rm=3',
      source: '最高法院司法卷宗圖書館（99年度訴字第285號 ...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.6_z7cGk1TU-RBgQM3tsqZQHaE8?w=221&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '法規沿革與憲法判決法典（99年度訴字第285號 ...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.Xt1C-7meX374BAg86KC6LwHaE8?w=89&h=89&c=1&rs=1&qlt=70&r=0&o=7&pid=InlineBlock&rm=3',
      source: '本案訴訟卷宗外觀及編號（99年度訴字第285號 ...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.WVO6tR5BzOgw0oglmH02OAHaEP?w=208&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '地方法院簡易庭外觀與開庭公告（99年度訴字第285號 ...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.FxsIbUCjMd4IlOEskxShJgHaFj?w=89&h=89&c=1&rs=1&qlt=70&r=0&o=7&pid=InlineBlock&rm=3',
      source: '當事人提出之訴狀首頁抄本（99年度訴字第285號 ...）',
    ),
    CaseImage(
      url:
          'https://tse1.mm.bing.net/th/id/OIP.xExaObj3A3nV3olc0K1gmwHaEJ?w=263&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '司法裁判書電子檔之判決主文（99年度訴字第285號 ...）',
    ),
    CaseImage(
      url:
          'https://tse4.mm.bing.net/th/id/OIP.Q7FEnIHkrd6q9Jmu1GiKkwHaEj?w=248&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '民事起訴狀與委任律師書狀（99年度訴字第285號 ...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.CR03_AAGv7DichRpWnF7NQHaE7?w=233&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '法院準備程序筆錄簽名欄位（99年度訴字第285號 ...）',
    ),
    CaseImage(
      url:
          'https://tse4.mm.bing.net/th/id/OIP.BpIJPdGnK-nMpGs5B9306AHaFe?w=206&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '司法院大法官憲法法庭開庭現場（99年度訴字第285號 ...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.jgOpaPncHSivavrOTSAXLgHaE8?w=232&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '最高法院民事庭開庭大門外觀（99年度訴字第285號 ...）',
    ),
    CaseImage(
      url:
          'https://tse4.mm.bing.net/th/id/OIP.zbbKZ0Bh_CpP6eZamtCRjwHaE9?w=179&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '法學文獻與期刊論文引用頁面（99年度訴字第285號 ...）',
    ),
    CaseImage(
      url:
          'https://tse1.mm.bing.net/th/id/OIP.fEDFLQLHjS3QuE4bQLgBvQHaE8?w=229&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '中華民國六法全書民法債編法條（99年度訴字第285號 ...）',
    ),
    CaseImage(
      url:
          'https://tse3.mm.bing.net/th/id/OIP.rgvPoDUIQa-Gb56tJrl6sgHaEO?w=89&h=90&c=1&rs=1&qlt=70&r=0&o=7&pid=InlineBlock&rm=3',
      source: '民事訴訟小額程序開庭流程圖（99年度訴字第285號 ...）',
    ),
    CaseImage(
      url:
          'https://tse2.mm.bing.net/th/id/OIP.M1ZTFf8JShiFpHtxNdAuTwHaEz?w=227&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      source: '判決確定證明書與執行憑證抄本（99年度訴字第285號 ...）',
    )
  ]
};

List<CaseImage> _getDefaultImagesForCase(CaseBook book) {
  // 歷史大案 (Landmarks) 依然讀取預載入高解析度真實照片
  if (!book.id.startsWith('case-')) {
    final list = _preloadedCaseImages[book.id];
    if (list != null && list.isNotEmpty) {
      return list;
    }
  }

  // 普通民刑案件 (ID 以 case- 開頭)，一律採用高解析度 Unsplash 類別適配示意圖，不加載 Bing 縮圖
  final category = book.category;
  if (category == '車禍賠償') {
    return const [
      CaseImage(
        url:
            'https://images.unsplash.com/photo-1506015391300-4802dc74de2e?auto=format&fit=crop&w=1200&q=80',
        source: '情境示意圖：道路交通路口實景',
      ),
      CaseImage(
        url:
            'https://images.unsplash.com/photo-1518987013-07002866e15d?auto=format&fit=crop&w=1200&q=80',
        source: '情境示意圖：車禍採證測量與道路調查',
      ),
    ];
  } else if (category == '租屋糾紛') {
    return const [
      CaseImage(
        url:
            'https://images.unsplash.com/photo-1560518883-ce09059eeffa?auto=format&fit=crop&w=1200&q=80',
        source: '情境示意圖：租屋公寓簽約與交屋點交',
      ),
      CaseImage(
        url:
            'https://images.unsplash.com/photo-1580587771525-78b9dba3b914?auto=format&fit=crop&w=1200&q=80',
        source: '情境示意圖：租賃房屋內裝與自然折舊屋況',
      ),
    ];
  } else if (category == '不當解雇') {
    return const [
      CaseImage(
        url:
            'https://images.unsplash.com/photo-1521791136368-1a9b7d902d71?auto=format&fit=crop&w=1200&q=80',
        source: '情境示意圖：辦公室勞資雙方協議會談',
      ),
      CaseImage(
        url:
            'https://images.unsplash.com/photo-1497366216548-37526070297c?auto=format&fit=crop&w=1200&q=80',
        source: '情境示意圖：職場工作崗位與勞動權益',
      ),
    ];
  } else if (category == '離婚親權') {
    return const [
      CaseImage(
        url:
            'https://images.unsplash.com/photo-1516627145497-ae6968895b74?auto=format&fit=crop&w=1200&q=80',
        source: '情境示意圖：家庭親權撫養與監護權協商',
      ),
      CaseImage(
        url:
            'https://images.unsplash.com/photo-1479839672679-a46483c0e7c8?auto=format&fit=crop&w=1200&q=80',
        source: '情境示意圖：家事法庭調解與溝通程序',
      ),
    ];
  } else if (category == '借款返還' || category == '給付價金') {
    return const [
      CaseImage(
        url:
            'https://images.unsplash.com/photo-1559526324-4b87b5e36e44?auto=format&fit=crop&w=1200&q=80',
        source: '情境示意圖：財務往來金流與轉帳明細證物',
      ),
      CaseImage(
        url:
            'https://images.unsplash.com/photo-1454165804606-c3d57bc86b40?auto=format&fit=crop&w=1200&q=80',
        source: '情境示意圖：商業契約簽署與借據證明文件',
      ),
    ];
  } else if (category == '竊盜' || category == '傷害') {
    return const [
      CaseImage(
        url:
            'https://images.unsplash.com/photo-1589829545856-d10d557cf95f?auto=format&fit=crop&w=1200&q=80',
        source: '情境示意圖：法院司法天平與法庭審理',
      ),
      CaseImage(
        url:
            'https://images.unsplash.com/photo-1507679799987-c73779587ccf?auto=format&fit=crop&w=1200&q=80',
        source: '情境示意圖：刑事起訴證據採集與事實判定',
      ),
    ];
  }

  // 預設通用示意圖
  return const [
    CaseImage(
      url:
          'https://images.unsplash.com/photo-1589829545856-d10d557cf95f?auto=format&fit=crop&w=1200&q=80',
      source: '情境示意圖：法院司法天平與審判法庭現場',
    ),
    CaseImage(
      url:
          'https://images.unsplash.com/photo-1505664194779-8bebcb95df84?auto=format&fit=crop&w=1200&q=80',
      source: '情境示意圖：最高法院司法卷宗圖書館',
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
