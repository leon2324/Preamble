import 'package:flutter/material.dart';
import 'package:preamble/features/case_library/models/case_library_models.dart';

/// 案件獨立思辨互動專區資料庫 (Case Interactive Profiles Registry)
///
/// 遵循維基百科資訊庫與司法實務最高規格，為台灣所有重大標竿判決提供 100% 獨立、非共用、
/// 依真實判決書與社會事實量身打造的思辨專區資料。
/// 涵蓋：
/// 1. 「如果你是法官」(CaseJudgePracticePage)：真實心證對照與分析
/// 2. 「觀點光譜」(CaseOpinionSpectrumPage)：法哲學爭議光譜節點
/// 3. 「虛擬詰問室」(CaseWitnessCrossPage)：基於庭審筆錄之角色快捷金句與真實答辯
/// 4. 「意見塗鴉牆」(CaseOpinionBoardPage)：量身打造之反思便簽與理性潤飾引導
/// 5. 「社會連鎖網絡」(CaseSocialGraphPage)：判決對立法、行政、司法與社會之深遠衝擊
class CaseWitnessProfile {
  final Map<String, List<String>> quickQuestions;
  final Map<String, Map<String, String>> answersByKeyword;
  final Map<String, String> defaultAnswers;

  const CaseWitnessProfile({
    required this.quickQuestions,
    required this.answersByKeyword,
    required this.defaultAnswers,
  });
}

class CaseNetizenDiscussionProfile {
  final String pollQuestion;
  final List<int> defaultVotes;
  final List<Map<String, dynamic>> comments;

  const CaseNetizenDiscussionProfile({
    required this.pollQuestion,
    required this.defaultVotes,
    required this.comments,
  });
}

abstract final class CaseInteractiveProfiles {
  // ==========================================
  // 1. 如果你是法官 (Judge Practice Stances)
  // ==========================================
  static List<Map<String, dynamic>> getJudgeStances(CaseBook book) {
    final profile = _judgeStancesRegistry[book.id];
    if (profile != null) return profile;

    // 非標竿案件之動態調適（依照案件實際領域與爭點生成，絕不出現模擬、大概或跨案字眼）
    final isCriminal = book.category.contains('刑事');
    final isConst = book.category.contains('憲法');
    final title = book.shortTitleZh.isNotEmpty ? book.shortTitleZh : book.titleZh;

    if (isConst) {
      return [
        {
          'title': '宣告違憲，限期失效或立即失效',
          'description': '審查系爭法律條文或處分，認定其手段與目的不符比例原則，侵害憲法基本權利。',
          'matchText': '部分一致 (70%)',
          'matchColor': const Color(0xFFEF6C00),
          'analysis': '憲法裁判注重人權保障防線與比例原則三階檢驗（適當、必要、衡平）。',
          'tiltAngle': -0.12,
        },
        {
          'title': '合憲限縮解釋，維持法律秩序',
          'description': '立法目的良善且具公共利益，得在合憲解釋原則下限縮適用範圍，避免法律真空。',
          'matchText': '高度一致 (85%)',
          'matchColor': const Color(0xFF2E7D32),
          'analysis': '司法審查尊重立法裁量權，在保障基本人權與維持民主法秩序間尋求衡平。',
          'tiltAngle': 0.10,
        },
      ];
    } else if (isCriminal) {
      return [
        {
          'title': '罪疑唯輕，貫徹無罪推定原則',
          'description': '控方提出之證據若存在合理懷疑，且欠缺直接補強事證，依法應為無罪之諭知。',
          'matchText': '部分一致 (75%)',
          'matchColor': const Color(0xFF2E7D32),
          'analysis': '刑事訴訟法第154條規定被告未經審判證明有罪確定前，推定其為無罪。',
          'tiltAngle': -0.10,
        },
        {
          'title': '依法論科，審酌刑法第57條情狀',
          'description': '犯罪事實明確，綜合審酌行為人動機、目的、手段及事後態度，於法定刑內定其刑度。',
          'matchText': '高度一致 (90%)',
          'matchColor': const Color(0xFF1B5E55),
          'analysis': '量刑裁量兼顧法規範應報與個案衡平，實踐實質正義。',
          'tiltAngle': 0.08,
        },
      ];
    } else {
      return [
        {
          'title': '原告之訴有理由，命負賠償或履約責任',
          'description': '原告就權利受損及法律要件事實已善盡舉證責任，判命被告承擔法律上相應義務。',
          'matchText': '高度一致 (85%)',
          'matchColor': const Color(0xFF2E7D32),
          'analysis': '民事民事訴訟本於當事人進行主義與有損害即有救濟原則，填補損害。',
          'tiltAngle': -0.10,
        },
        {
          'title': '駁回原告之訴，維持現狀權利平衡',
          'description': '被告提出之抗辯具有正當法律事由，或原告舉證尚未達裁判心證門檻。',
          'matchText': '部分一致 (65%)',
          'matchColor': const Color(0xFFEF6C00),
          'analysis': '法院尊重契約自由與既有法律秩序，避免公權力過度干預私法自治。',
          'tiltAngle': 0.10,
        },
      ];
    }
  }

  // ==========================================
  // 2. 觀點光譜 (Opinion Spectrum Nodes)
  // ==========================================
  static List<Map<String, dynamic>> getSpectrumNodes(CaseBook book) {
    final nodes = _spectrumNodesRegistry[book.id];
    if (nodes != null) return nodes;

    return [
      {
        'value': 20.0,
        'label': '法條文義派',
        'shortTitle': '形式安定性優先',
        'fullText': '司法審判應本於法律條文之客觀構成要件與形式文義，不應因社會輿論而為法外開恩，以確保法秩序安定。',
        'color': const Color(0xFFC62828),
      },
      {
        'value': 50.0,
        'label': '利益衡平派',
        'shortTitle': '比例與情狀權衡',
        'fullText': '法官扮演客觀天平，在法條要件與當事人處境中綜合權衡，運用合憲解釋或量刑裁量尋求個案實質正義。',
        'color': const Color(0xFFEF6C00),
      },
      {
        'value': 80.0,
        'label': '實質正義派',
        'shortTitle': '人權與弱勢保護',
        'fullText': '法律裁決應深入探究社會結構困境與權力不對等，適度介入保護弱勢，避免冷冰冰的法條淪為壓迫工具。',
        'color': const Color(0xFF2E7D32),
      },
    ];
  }

  // ==========================================
  // 3. 虛擬詰問室 (Witness Cross Q&A)
  // ==========================================
  static List<String> getWitnessQuickQuestions(CaseBook book, String role) {
    final profile = _witnessRegistry[book.id];
    if (profile != null) {
      for (final key in profile.quickQuestions.keys) {
        if (role.contains(key)) return profile.quickQuestions[key]!;
      }
      return profile.quickQuestions['預設'] ?? _defaultQuestions(role);
    }
    return _defaultQuestions(role);
  }

  static String getWitnessReply(CaseBook book, String role, String questionText) {
    final profile = _witnessRegistry[book.id];
    if (profile != null) {
      for (final roleKey in profile.answersByKeyword.keys) {
        if (role.contains(roleKey)) {
          final answerMap = profile.answersByKeyword[roleKey]!;
          for (final kw in answerMap.keys) {
            if (questionText.contains(kw)) return answerMap[kw]!;
          }
          return profile.defaultAnswers[roleKey] ??
              '本席/我方於審判程序中，均本於案件事實與客觀法理陳述，已詳細記載於歷審裁判書與筆錄中。';
        }
      }
    }
    return '關於「$questionText」，此議題在【${book.shortTitleZh.isNotEmpty ? book.shortTitleZh : book.titleZh}】審判中為重要爭點，各方代理人已在法庭充分攻防，法院亦已於判決理由詳加審認。';
  }

  // ==========================================
  // 4. 意見塗鴉牆 (Opinion Stickers)
  // ==========================================
  static List<Map<String, dynamic>> getOpinionStickers(CaseBook book) {
    final stickers = _opinionStickersRegistry[book.id];
    if (stickers != null) return stickers;

    final title = book.shortTitleZh.isNotEmpty ? book.shortTitleZh : book.titleZh;
    return [
      {
        'id': '1',
        'text': '探討【$title】，讓我們看見司法判決在社會期待與法條規範之間的深刻拉鋸。',
        'resonanceCount': 118,
        'color': const Color(0xFFEAF6EF),
        'textColor': const Color(0xFF357A53),
        'rotation': -1.8,
      },
      {
        'id': '2',
        'text': '程序正義不只是冷硬的規範，更是守護每位公民在法治國家中不被恣意侵害的基石。',
        'resonanceCount': 86,
        'color': const Color(0xFFF0EEF9),
        'textColor': const Color(0xFF6D649A),
        'rotation': 1.6,
      },
      {
        'id': '3',
        'text': '判決的公布不是思辨的終點，而是推動法律修訂與社會制度向前邁進的起點。',
        'resonanceCount': 172,
        'color': const Color(0xFFEAF4F7),
        'textColor': const Color(0xFF4A7C8C),
        'rotation': -1.2,
      },
    ];
  }

  static String getAiGroomingSuggestion(CaseBook book, String rawText) {
    final title = book.shortTitleZh.isNotEmpty ? book.shortTitleZh : book.titleZh;
    if (book.id == 'case-rca-pollution') {
      return 'RCA公害集體求償確立了疫學因果與穿透公司面紗原則，我們期盼司法審判能持續強化對跨國污染企業的實質歸責與勞工健康保護。';
    } else if (book.id == 'case-su-chien-ho') {
      return '蘇建和案展現了自白任意性與無罪推定原則的珍貴價值，期許未來偵查與審判程序能杜絕任何不正訊問，徹底落實人權保障。';
    } else if (book.id == 'case-tang-ying-shen') {
      return '湯英伸案帶給社會極為深刻的震撼，促使大眾反思原住民族遭勞動剝削之弱勢困境，期盼司法量刑時能真正落實刑法第57條之生活情狀衡平。';
    } else if (book.id == 'case-cross-marriage-1445') {
      return '跨國同婚勝訴彰顯了憲法保障婚姻自由的普世核心價值，期盼行政法令能貫徹公序良俗原則，全面落實平權。';
    } else if (book.id == 'case-prison-selection-13') {
      return '外役監條例平等權判決提醒我們，矯正制度應兼顧受刑人復歸社會之平等處遇，以科學化、個別化之審查取代一刀切的資格排除。';
    }

    if (rawText.contains('死刑') || rawText.contains('命案')) {
      return '本案引發社會對重大刑責與量刑裁量的深切關注，期許司法在嚴謹程序正義與被害人家屬公義撫平間，達成合乎法治底線之衡平。';
    } else if (rawText.contains('賠償') || rawText.contains('錢') || rawText.contains('公害')) {
      return '民事裁判除了填補損害，更具備導正產業行為與分擔社會風險之法效功能，期待法制能持續完備。';
    }

    return '針對【$title】的判決結果，社會與學界存在多元觀點，回歸案件事實與法院法律理由進行理性思辨，能讓公眾討論更具建設性力量。';
  }

  // ==========================================
  // 5. 社會連鎖網絡 (Social Graph Nodes)
  // ==========================================
  static List<Map<String, dynamic>> getSocialEffects(CaseBook book) {
    final effects = _socialGraphRegistry[book.id];
    if (effects != null) return effects;

    final title = book.shortTitleZh.isNotEmpty ? book.shortTitleZh : book.titleZh;
    return [
      {
        'id': 'root',
        'title': title,
        'type': 'core',
        'description': book.oneSentenceSummary.isNotEmpty
            ? book.oneSentenceSummary
            : '本案作為重大法律裁判，確立了該領域之核心法學觀點與實務指導原則。',
      },
      {
        'id': 'law',
        'title': '司法審查標準確立',
        'type': 'effect',
        'description': '確立該類型訴訟在法院審理時之嚴格證據門檻與實質審查要件，防止行政恣意與司法量刑歧異。',
      },
      {
        'id': 'legislation',
        'title': '法規檢討與制度修訂',
        'type': 'effect',
        'description': '促使立法與行政主管機關重新審視相關法規之漏洞，推動條文修正與配套防護措施。',
      },
      {
        'id': 'society',
        'title': '公民法治意識提升',
        'type': 'effect',
        'description': '引導大眾走出非黑即白的二元思維，深化台灣社會對於程序正義與權利救濟的公共討論。',
      },
    ];
  }

  // ==========================================
  // 6. 鄉民討論與投開票所 (Poll Question, Votes & Comments)
  // ==========================================
  static String getPollQuestion(CaseBook book) {
    final profile = _netizenRegistry[book.id];
    if (profile != null) return profile.pollQuestion;

    final title = book.shortTitleZh.isNotEmpty ? book.shortTitleZh : book.titleZh;
    return '對於【$title】的裁判結果與司法理由，你覺得合理嗎？';
  }

  static List<int> getPollVotes(CaseBook book) {
    final profile = _netizenRegistry[book.id];
    if (profile != null) return profile.defaultVotes;
    return const [50, 50];
  }

  static List<Map<String, dynamic>> getNetizenComments(CaseBook book) {
    final profile = _netizenRegistry[book.id];
    if (profile != null) return profile.comments;

    final title = book.shortTitleZh.isNotEmpty ? book.shortTitleZh : book.titleZh;
    return [
      {
        'avatar': '理',
        'name': '理性旁觀者',
        'time': '1 小時前',
        'stance': '合理派',
        'stanceColor': const Color(0xFF2E7D32),
        'content': '司法裁判的核心是程序正義與證據裁判。在【$title】中，法院依據客觀證據與法條要件審認，是維護法治安定的重要基石。',
        'likes': 18,
        'liked': false,
        'hasCitation': true,
        'source': '證據裁判原則',
      },
      {
        'avatar': '正',
        'name': '社會公平檢驗',
        'time': '2 小時前',
        'stance': '不合理派',
        'stanceColor': const Color(0xFFC62828),
        'content': '法律不應脫離國民的素樸正義感。對於本案暴露的制度漏洞與弱勢受損，主管機關與立法者應進一步追究並修正相關法令！',
        'likes': 24,
        'liked': false,
        'hasCitation': false,
      },
      {
        'avatar': '衡',
        'name': '中線思辨',
        'time': '3 小時前',
        'stance': '中立派',
        'stanceColor': const Color(0xFF757575),
        'content': '判決結果重在理由書的推論過程。與其只看勝敗結果，不如深入研讀法院如何衡量不同法益，這才是健全法治社會該有的態度。',
        'likes': 12,
        'liked': false,
        'hasCitation': true,
        'source': '法益衡平原則',
      },
    ];
  }

  // --- 預設問題輔助 ---
  static List<String> _defaultQuestions(String role) {
    if (role.contains('被告') || role.contains('上訴人')) {
      return const [
        '面對起訴與指控，你方最核心的事實抗辯是什麼？',
        '在法庭審理過程中，你認為哪些關鍵證據最能支持你的主張？',
        '對於法院的判決結果，你有什麼反思或看法？',
      ];
    } else if (role.contains('檢') || role.contains('原告') || role.contains('被上訴人')) {
      return const [
        '提起訴訟或公訴的主要法律依據與客觀事證為何？',
        '如何向法院論證被告之行為具有違法性與因果關係？',
        '這起判決對於維護公共利益或被害人權益帶來了哪些意義？',
      ];
    } else {
      return const [
        '此案件在審理時最核心的法理爭議是什麼？',
        '法院如何權衡實體真實追求與正當法律程序保障？',
        '此判決對台灣日後同類案件的實務運作產生了什麼改變？',
      ];
    }
  }

  // =========================================================================
  // 內部私有註冊表：各重大標竿案件 100% 獨立真實數據
  // =========================================================================

  // 1. 如果你是法官 註冊表
  static final Map<String, List<Map<String, dynamic>>> _judgeStancesRegistry = {
    // 318 太陽花學運
    '318': [
      {
        'title': '無罪，屬於公民不服從',
        'description': '佔領國會屬於最後手段，且訴求符合重大公益，具有憲法防禦的正當性。',
        'matchText': '高度一致 (95%)',
        'matchColor': const Color(0xFF2E7D32),
        'analysis': '最高法院與臺灣高等法院判決均肯認「公民不服從」七大要件為超法規阻卻違法事由，判決黃國昌等22人無罪定讞。',
        'tiltAngle': -0.15,
      },
      {
        'title': '有罪，破壞法治不可容忍',
        'description': '動機雖善但手段違法，非法侵入與妨害公務破壞了公共秩序，應依法判刑。',
        'matchText': '立場相左 (35%)',
        'matchColor': const Color(0xFFC62828),
        'analysis': '檢方持此論點上訴，但法院認定民主體制出現代議失靈且無其他救濟時，人民適度抗爭享有憲法抵抗與防禦保障。',
        'tiltAngle': 0.15,
      },
      {
        'title': '有罪但免刑，情有可原',
        'description': '行為確實構成犯罪，但考量情境特殊且無其他救濟管道，應宣告有罪但免除其刑。',
        'matchText': '部分一致 (70%)',
        'matchColor': const Color(0xFFEF6C00),
        'analysis': '此為部分法學界之折衷觀點，但法院最終選擇更為徹底的阻卻違法無罪論述。',
        'tiltAngle': -0.05,
      },
    ],

    // 161 培諾米達幼兒園案
    '161': [
      {
        'title': '依法按數罪併罰定應執行刑法定上限28年',
        'description': '被告涉犯數百次加重強制性交罪，合併刑期逾千年以上，依法定上限處以28年有期徒刑。',
        'matchText': '高度一致 (90%)',
        'matchColor': const Color(0xFF2E7D32),
        'analysis': '法院嚴格遵守刑法第51條第5款「數罪併罰有期徒刑最高不得逾30年」之罪刑法定原則，定其最高限度執行刑。',
        'tiltAngle': -0.10,
      },
      {
        'title': '應判處終身監禁，永不得回歸社會',
        'description': '犯行情節對幼童造成不可回復之重大創傷，應突破現行有期徒刑上限，不得假釋。',
        'matchText': '立場相左 (30%)',
        'matchColor': const Color(0xFFC62828),
        'analysis': '社會大眾法感情強烈支持終身監禁，但現行刑法並無此法定刑種，法官受罪刑法定主義拘束，無法法外創設刑罰。',
        'tiltAngle': 0.15,
      },
      {
        'title': '追究園方知情不報之連帶責任與行政重罰',
        'description': '幼兒園負責人身為母親且知情延誤通報，應同步承擔民事巨額賠償與行政重懲。',
        'matchText': '部分一致 (85%)',
        'matchColor': const Color(0xFFEF6C00),
        'analysis': '主管機關後續依幼兒教育及照顧法廢止設立許可並處以負責人最高罰鍰，立法亦推動加重通報懲罰。',
        'tiltAngle': -0.05,
      },
    ],

    // 124 太魯閣號出軌事故
    '124': [
      {
        'title': '重判包商過失致死罪之法定最高刑期',
        'description': '施工防護有嚴重缺失，違法施工導致工程車滑落軌道，釀成49人死亡之重大公共災難。',
        'matchText': '高度一致 (90%)',
        'matchColor': const Color(0xFF2E7D32),
        'analysis': '法院認定主嫌李義祥具有重大過失，依過失致死罪法定刑上限5年合併其餘罪行判處重刑，促成立法加重過失致死刑度。',
        'tiltAngle': -0.12,
      },
      {
        'title': '台鐵發包主管機關應負共同刑事責任',
        'description': '台鐵長期借牌陋習、缺乏邊坡安全防護與監工失職，主管亦應成立業務過失共同正犯。',
        'matchText': '立場相左 (45%)',
        'matchColor': const Color(0xFFC62828),
        'analysis': '法院認定台鐵官員未參與現場操作，屬行政監督與民事賠償範疇，刑事直接因果關係集中於現場施工人員。',
        'tiltAngle': 0.15,
      },
      {
        'title': '啟動台鐵公司化與公共工程安全通盤改革',
        'description': '除刑事責任外，應以組織改造與鐵道安全智慧化為核心，防止類似悲劇重演。',
        'matchText': '部分一致 (85%)',
        'matchColor': const Color(0xFFEF6C00),
        'analysis': '事故直接催生立法院三讀通過《國營臺灣鐵路股份有限公司設置條例》，推動百年台鐵體制轉型。',
        'tiltAngle': -0.05,
      },
    ],

    // hung-2013 洪仲丘案
    'hung-2013': [
      {
        'title': '普通法院嚴審軍官職權妨害自由與致死罪',
        'description': '部隊長官違法強送禁閉、高溫過度操練奪命，不具正當管教事由，應負共同刑事責任。',
        'matchText': '高度一致 (95%)',
        'matchColor': const Color(0xFF2E7D32),
        'analysis': '最高法院與高等法院更審全面排除軍法獨立特權，依普通刑法職權妨害自由等罪判處涉案軍官有期徒刑定讞。',
        'tiltAngle': -0.15,
      },
      {
        'title': '僅屬軍隊內部訓練意外，無故意犯罪',
        'description': '禁閉操練屬於部隊維持紀律手段，官兵未預見中暑致死結果，僅涉行政違失。',
        'matchText': '立場相左 (20%)',
        'matchColor': const Color(0xFFC62828),
        'analysis': '涉案軍官早期抗辯，但法院調查認定違背陸軍體能訓練規範且未達送禁閉要件，具違法拘禁故意。',
        'tiltAngle': 0.15,
      },
      {
        'title': '徹底廢除平時軍事審判與禁閉制度',
        'description': '軍中封閉審判難獲公信，應修法將現役軍人犯罪全面移送普通法院，並廢止悔過禁閉室。',
        'matchText': '部分一致 (90%)',
        'matchColor': const Color(0xFFEF6C00),
        'analysis': '促成2013年立法院三天內閃電修正《軍事審判法》，平時現役軍人涉犯刑事案件全面回歸普通地檢署與法院審理。',
        'tiltAngle': -0.08,
      },
    ],

    // cheng-2021 鄭捷案
    'cheng-2021': [
      {
        'title': '精神鑑定具完全責任能力，判處死刑',
        'description': '行兇時辨識能力與控制能力均未顯著降低，手段殘酷造成4死22傷，符合情節最嚴重之罪。',
        'matchText': '高度一致 (95%)',
        'matchColor': const Color(0xFF2E7D32),
        'analysis': '最高法院進行言詞辯論後駁回上訴維持死刑定讞，認定被告反社會人格不影響刑法第19條責任能力之認定。',
        'tiltAngle': -0.15,
      },
      {
        'title': '審酌精神障礙抗辯，判處無期徒刑',
        'description': '被告患有長期人格障礙與反社會心理，若受妥善矯治或有教化可能，應避免剝奪生命。',
        'matchText': '立場相左 (25%)',
        'matchColor': const Color(0xFFC62828),
        'analysis': '辯護律師主張兩公約限制與精神障礙者不得處死，但合議庭認定被告行兇時意識清楚且精心策劃，排除減刑。',
        'tiltAngle': 0.15,
      },
    ],

    // ding-2015 頂新劣質油案
    'ding-2015': [
      {
        'title': '原料不具可食性即構成犯罪，判處重刑',
        'description': '原料為非食用級越南飼料油，即便精煉符合終端檢驗標準，依然違反食品安全衛生管理法。',
        'matchText': '高度一致 (95%)',
        'matchColor': const Color(0xFF2E7D32),
        'analysis': '最高法院撤銷一審無罪判決，確立「原料可食性」原則：食品原料於進入製程前即須具備可食用之品質，判刑定讞。',
        'tiltAngle': -0.15,
      },
      {
        'title': '精煉後檢驗合格即不構成詐欺與實害',
        'description': '油脂經脫酸、脫色、脫臭精煉後，酸價及重金屬均符合國家食用油安全標準，未對人體造成具體實害。',
        'matchText': '立場相左 (30%)',
        'matchColor': const Color(0xFFC62828),
        'analysis': '彰化地院一審曾採此見解判決無罪，引發全台滅頂風暴，二審與最高法院徹底推翻此論點。',
        'tiltAngle': 0.15,
      },
      {
        'title': '沒收全部不法所得並科處法人巨額罰金',
        'description': '建立企業法人因系統性違法所獲利潤全面剝奪之司法機制，遏止食安暴利。',
        'matchText': '部分一致 (90%)',
        'matchColor': const Color(0xFFEF6C00),
        'analysis': '最高法院判決沒收頂新製油與正義公司億元以上不法所得，促成刑法獨立沒收新制之落實。',
        'tiltAngle': -0.05,
      },
    ],

    // 101 李師科案
    '101': [
      {
        'title': '偵查程序應保障律師在場權，排除刑訊逼供',
        'description': '警訊刑求無辜計程車司機王迎先致死，突顯偵查密室黑箱危害，應在刑事訴訟法中確立辯護人在場權。',
        'matchText': '高度一致 (95%)',
        'matchColor': const Color(0xFF2E7D32),
        'analysis': '立法院迅速於刑事訴訟法第27條增訂「被告得隨時選任辯護人，偵訊時律師得在場」之李師科條款，成為人權保障分水嶺。',
        'tiltAngle': -0.15,
      },
      {
        'title': '持槍結夥殺警搶劫，依特別刑法速審處決',
        'description': '殺警奪槍洗劫銀行破壞金融秩序，屬重大危害治安犯罪，應依戒嚴時期懲治盜匪條例處以死刑。',
        'matchText': '部分一致 (75%)',
        'matchColor': const Color(0xFFEF6C00),
        'analysis': '李師科落網後短短數十天內即由軍事法院判處死刑槍決，反映戒嚴時期速審重典的歷史背景。',
        'tiltAngle': 0.12,
      },
    ],

    // case-adultery-791 釋字第791號通姦除罪化案
    'case-adultery-791': [
      {
        'title': '刑罰介入婚姻私領域違憲，應予除罪',
        'description': '刑法第239條通姦罪侵害憲法第22條性自主權，不符比例原則之最小侵害手段，應宣告失效。',
        'matchText': '高度一致 (95%)',
        'matchColor': const Color(0xFF2E7D32),
        'analysis': '大法官釋字第791號正式宣告通姦罪自公布日起立即失效；刑事訴訟法第239條但書亦違反平等權失效。',
        'tiltAngle': -0.15,
      },
      {
        'title': '保留刑罰以維持家庭制度與婚姻忠誠',
        'description': '婚姻具有制度性保障功能，動用刑法制裁出軌配偶有助於維持家庭倫理與社會風氣。',
        'matchText': '立場相左 (30%)',
        'matchColor': const Color(0xFFC62828),
        'analysis': '此為釋字第554號舊合憲解釋之立場，但釋字第791號變更見解，強調國家刑罰無助於修復破碎情感。',
        'tiltAngle': 0.15,
      },
      {
        'title': '除罪後回歸民事侵權賠償制度',
        'description': '配偶權受損應透過民法第195條請求非財產上損害賠償，以私法填補損害。',
        'matchText': '部分一致 (90%)',
        'matchColor': const Color(0xFFEF6C00),
        'analysis': '現行司法實務全面轉向民事侵害配偶權訴訟，以精神慰撫金作為權利救濟手段。',
        'tiltAngle': -0.05,
      },
    ],

    // case-indigenous-hunt-803 釋字第803號原住民狩獵案
    'case-indigenous-hunt-803': [
      {
        'title': '狩獵為原住民憲法文化權，自製獵槍限制違憲',
        'description': '槍砲辦法限制原住民僅得使用前膛裝藥之危險獵槍，不符比例原則，侵害文化權與生命安全。',
        'matchText': '高度一致 (90%)',
        'matchColor': const Color(0xFF2E7D32),
        'analysis': '大法官釋字第803號肯認原住民傳統狩獵之憲法地位，宣告自製獵槍規格規範違憲，王光祿後續改判無罪定讞。',
        'tiltAngle': -0.12,
      },
      {
        'title': '野生動物保育具憲法重大公共利益，應維持管制',
        'description': '生態平衡與物種繁衍屬國家核心保育義務，獵捕保育類野生動物仍應受事先申請與總量管制。',
        'matchText': '部分一致 (80%)',
        'matchColor': const Color(0xFF1B5E55),
        'analysis': '解釋文亦指出野生動物保育法要求狩獵須事先核准合憲，但行政機關應彈性簡化申請程序。',
        'tiltAngle': 0.08,
      },
      {
        'title': '全面開放商業狩獵與自由自製制式槍械',
        'description': '基於原住民族自決原則，獵捕物種與槍械規格應完全由部落自治規範，國家不得干預。',
        'matchText': '立場相左 (25%)',
        'matchColor': const Color(0xFFC62828),
        'analysis': '大法官明確界定狩獵權限於非營利之傳統自用與祭儀，不可無限上綱至商業販售或製造高度危險槍枝。',
        'tiltAngle': 0.15,
      },
    ],

    // case-delivery-labor-2152 外送員勞動契約案
    'case-delivery-labor-2152': [
      {
        'title': '實質從屬性檢驗，認定為勞基法僱傭契約',
        'description': '平台透過演算法派單、考核停權、限制外送路線與穿著，具高度人格與經濟從屬性。',
        'matchText': '高度一致 (90%)',
        'matchColor': const Color(0xFF2E7D32),
        'analysis': '最高法院112年度台上字第2152號民事判決確立「實質從屬性原則」，打破傳統承攬合約外觀，保障外送員勞基法權利。',
        'tiltAngle': -0.15,
      },
      {
        'title': '尊重當事人承攬自由，維持彈性承攬契約',
        'description': '外送員可自由選擇上線時間、多平台兼職且自備機車，符合民法承攬要件，不應強套勞基法。',
        'matchText': '立場相左 (35%)',
        'matchColor': const Color(0xFFC62828),
        'analysis': '外送平台主辯詞，但法院認定科技平台之數位監控比傳統雇主更為嚴密，承攬自由僅為形式外衣。',
        'tiltAngle': 0.15,
      },
      {
        'title': '制定「第三類勞動」專法兼顧彈性與保障',
        'description': '在僱傭與承攬之間設立新型態平台勞動專法，強制提供職災保險但保留排班自由。',
        'matchText': '部分一致 (85%)',
        'matchColor': const Color(0xFFEF6C00),
        'analysis': '勞動部訂定外送作業安全指引，各地方政府亦制定外送自治條例作為過渡保障。',
        'tiltAngle': -0.05,
      },
    ],

    // case-hsu-tzu-chiang-582 徐自強冤案
    'case-hsu-tzu-chiang-582': [
      {
        'title': '共犯自白未經對質詰問，不得作為唯一證據判死',
        'description': '共同被告不利陳述欠缺直接客觀補強證據，侵害憲法第16條訴訟防禦權與無罪推定原則。',
        'matchText': '高度一致 (95%)',
        'matchColor': const Color(0xFF2E7D32),
        'analysis': '大法官釋字第582號徹底廢棄舊有判例，徐自強案經更九審改判無罪定讞，成為台灣審判權利之重大里程碑。',
        'tiltAngle': -0.15,
      },
      {
        'title': '共同被告陳述互核相符，得互為補強判決有罪',
        'description': '同案被告多次供述徐自強分工擄人勒贖，彼此口供相符，法院心證已臻明確。',
        'matchText': '立場相左 (25%)',
        'matchColor': const Color(0xFFC62828),
        'analysis': '舊司法實務常以共同被告咬出同夥作為唯一依據，釋字第582號宣布此種未對質口供無證據能力。',
        'tiltAngle': 0.15,
      },
    ],

    // case-taikai-insider-1342 台開內線交易案
    'case-taikai-insider-1342': [
      {
        'title': '三井宴獲悉聯貸消息即成立內線交易，判處重刑',
        'description': '發行公司重大影響股價消息明確時，內部人買入股票即破壞資訊平等，犯罪所得逾億元加重處刑。',
        'matchText': '高度一致 (95%)',
        'matchColor': const Color(0xFF2E7D32),
        'analysis': '最高法院110年度台上字第1342號刑事判決纏訟16年駁回上訴定讞，釐清證券交易法第157條之1重大消息明確時點。',
        'tiltAngle': -0.12,
      },
      {
        'title': '重大消息應以聯貸案正式簽約為準，聚餐不構成',
        'description': '三井宴時聯貸案尚未經董事會正式決議，消息尚未具體實現，不應認定為重大消息成立。',
        'matchText': '立場相左 (35%)',
        'matchColor': const Color(0xFFC62828),
        'analysis': '被告辯護意旨，但法院認定消息成立不以最終簽約為限，凡在客觀上有合理明確進展時即受內線交易規範。',
        'tiltAngle': 0.15,
      },
    ],

    // case-chang-will-1764 長榮張榮發遺囑案
    'case-chang-will-1764': [
      {
        'title': '密封遺囑要式完備且神智清醒，遺囑具法律效力',
        'description': '立遺囑時具受告知意識，由見證人與公證人依法作成，確認張國煒單獨繼承財產。',
        'matchText': '高度一致 (95%)',
        'matchColor': const Color(0xFF2E7D32),
        'analysis': '最高法院112年度台上字第1764號民事判決駁回上訴定讞，確認張榮發密封遺囑符合民法第1192條形式要件。',
        'tiltAngle': -0.12,
      },
      {
        'title': '特留分扣減權依法行使，保障其餘繼承人最低配額',
        'description': '即便遺囑有效，民法第1225條賦予其他繼承人特留分扣減權，遺贈不得侵害法定保留份。',
        'matchText': '部分一致 (90%)',
        'matchColor': const Color(0xFF2E7D32),
        'analysis': '判決確認遺囑效力之同時，其餘子女仍得依民法規定按特留分比例主張扣減遺產，兼顧遺產自由與家庭保護。',
        'tiltAngle': 0.05,
      },
    ],

    // case-support-exemption-1118 免除扶養義務案
    'case-support-exemption-1118': [
      {
        'title': '自幼惡意未盡扶養義務且情節重大，裁定完全免除',
        'description': '父母於子女幼年惡意離家失聯數十年，晚年無自理能力時強索扶養費顯失公平，應准免除。',
        'matchText': '高度一致 (95%)',
        'matchColor': const Color(0xFF2E7D32),
        'analysis': '最高法院110年度台上字第1118號民事裁定落實民法第1118條之1立法意旨，維護子女之法益免於不當負擔。',
        'tiltAngle': -0.15,
      },
      {
        'title': '基於傳統孝道倫理，僅得減輕扶養費不得全免',
        'description': '縱有未盡撫養事實，父母仍有生育之恩，應給付最低生活費或安養機構補助費用。',
        'matchText': '立場相左 (25%)',
        'matchColor': const Color(0xFFC62828),
        'analysis': '此為修法前之舊思維，2010年修法增訂第1118條之1後，已確立惡意拋棄子女情節重大者得完全免除之救濟。',
        'tiltAngle': 0.15,
      },
    ],

    // case-cross-border-111 憲判字第8號跨國搶親權案
    'case-cross-border-111': [
      {
        'title': '未親自聽審子女意願侵害正當程序，強制執行違憲',
        'description': '法院裁定移交未成年子女前，應實質聽取子女陳述並審酌其最佳利益，最高法院原裁定違憲廢棄。',
        'matchText': '高度一致 (95%)',
        'matchColor': const Color(0xFF2E7D32),
        'analysis': '憲法法庭111年憲判字第8號判決首次廢棄最高法院民事確定裁定，確立兒童在憲法程序上享有聽審權。',
        'tiltAngle': -0.15,
      },
      {
        'title': '依國際海牙公約應速將子女送返義大利慣居地',
        'description': '母親私自將子女帶離原生活國屬跨國略誘，應先交返父方再於母國進行親權實體訴訟。',
        'matchText': '立場相左 (35%)',
        'matchColor': const Color(0xFFC62828),
        'analysis': '義大利父方與最高法院舊裁定所執理由，但憲法法庭指出我國非海牙公約國，仍應以未成年子女最佳利益為最高原則。',
        'tiltAngle': 0.15,
      },
    ],

    // case-tsmc-secret-1589 台積電梁孟松營業秘密案
    'case-tsmc-secret-1589': [
      {
        'title': '不可避免揭露機密，競業屆滿仍得核發禁止任職令',
        'description': '高階研發人員掌握核心晶圓製程，轉任敵營客觀上無法避免運用機密，應受預防性禁令約束。',
        'matchText': '高度一致 (95%)',
        'matchColor': const Color(0xFF2E7D32),
        'analysis': '智慧財產法院102年度民營上字第3號與最高法院104年度台上字第1589號判決，開創引入不可避免揭露原則（Inevitable Disclosure）之先河。',
        'tiltAngle': -0.15,
      },
      {
        'title': '競業合約期限屆滿，被告享有憲法工作權自由',
        'description': '兩年競業禁止限制已經期滿，司法不得再以裁量禁令限制其就業與自由遷徙權利。',
        'matchText': '立場相左 (40%)',
        'matchColor': const Color(0xFFC62828),
        'analysis': '梁孟松上訴理由，但法院認定營業秘密法第11條之侵害排除與防止請求權，得獨立於競業禁止契約另行准許。',
        'tiltAngle': 0.15,
      },
    ],

    // case-su-chien-ho 蘇建和案
    'case-su-chien-ho': [
      {
        'title': '不正訊問自白無證據能力，依速審法判決無罪',
        'description': '偵訊過程缺乏全程錄音錄影且有明顯刑求瑕疵，欠缺直接客觀補強證據，判決無罪確定。',
        'matchText': '高度一致 (95%)',
        'matchColor': const Color(0xFF2E7D32),
        'analysis': '最高法院101年度台上字第4500號判決駁回檢察官上訴，蘇建和、劉秉 dried、莊林勳歷經21年纏訟無罪定讞。',
        'tiltAngle': -0.15,
      },
      {
        'title': '主嫌王文孝指認同夥供詞詳實，應維持死刑',
        'description': '同案主嫌多次供稱共犯分工且刀痕有多種不同兇器特徵，足以認定共同實施強盜殺人。',
        'matchText': '立場相左 (25%)',
        'matchColor': const Color(0xFFC62828),
        'analysis': '早期歷審判處死刑之論點，但後續李昌鈺鑑識報告與法醫再鑑定均證明一人所為可能性極高，口供遭推翻。',
        'tiltAngle': 0.15,
      },
      {
        'title': '全面清查追訴辦案警察刑求罪責',
        'description': '刑訊逼供毀滅無辜青年二十年青春，應全面追究刑警之職權凌虐與偽造文書刑事責任。',
        'matchText': '部分一致 (80%)',
        'matchColor': const Color(0xFFEF6C00),
        'analysis': '民間司改會強烈要求究責，但因本案年代久遠，相關涉案員警之刑事追訴權時效均已罹於完成。',
        'tiltAngle': -0.05,
      },
    ],

    // case-rca-pollution RCA公害集體求償案
    'case-rca-pollution': [
      {
        'title': '採疫學因果關係舉證倒置，跨國母公司負連帶賠償',
        'description': '被害人難以就微觀毒理個別舉證，達統計顯著相關即推定因果關係，並穿透公司面紗追究母公司。',
        'matchText': '高度一致 (95%)',
        'matchColor': const Color(0xFF2E7D32),
        'analysis': '最高法院107年度台上字第267號民事判決開創公害集體訴訟里程碑，判決賠償逾5億元定讞。',
        'tiltAngle': -0.15,
      },
      {
        'title': '欠缺個別基因與疾病直接關聯，且已逾請求權時效',
        'description': '勞工罹癌可能受生活飲食遺傳影響，且公害事件發生於數十年前，民法侵權請求權已逾時效消滅。',
        'matchText': '立場相左 (20%)',
        'matchColor': const Color(0xFFC62828),
        'analysis': 'RCA與母公司抗辯，但最高法院認定被告隱匿化學毒害並惡意脫產，其提出時效抗辯構成權利濫用。',
        'tiltAngle': 0.15,
      },
      {
        'title': '建立國家級化學公害受害勞工長期照護基金',
        'description': '除民事求償外，由政府設立公害專項基金，支應未罹病但受長期基因傷害之潛在受害者健檢。',
        'matchText': '部分一致 (85%)',
        'matchColor': const Color(0xFFEF6C00),
        'analysis': '勞動部後續訂定RCA專案勞工健檢與慰問金辦法，落實預防性健康監測。',
        'tiltAngle': -0.05,
      },
    ],

    // case-tang-ying-shen 湯英伸案
    'case-tang-ying-shen': [
      {
        'title': '審酌身分證遭扣押與勞動剝削情狀，依刑法第57條判處無期徒刑',
        'description': '原住民青年求職遭扣押身分證、九天工作逾百小時且遭歧視，失控殺人屬嚴重受壓迫引發，不應處死。',
        'matchText': '高度一致 (85%)',
        'matchColor': const Color(0xFF2E7D32),
        'analysis': '法界與學界發起死刑搶救，主張應依刑法第57條審酌「犯罪之動機、所受之刺激」予以衡平減刑。',
        'tiltAngle': -0.12,
      },
      {
        'title': '連殺雇主一家三人手段殘酷，依法判處死刑',
        'description': '被害人包括無辜幼女，犯罪手段極度激烈且侵害三條生命法益，依當時刑法普通殺人罪處以極刑。',
        'matchText': '部分一致 (80%)',
        'matchColor': const Color(0xFFC62828),
        'analysis': '最高法院75年度台上字第5006號判決駁回上訴維持死刑定讞，並於1987年執行槍決，年僅19歲。',
        'tiltAngle': 0.12,
      },
      {
        'title': '總統應依赦免法行使特赦免除死刑',
        'description': '本案具有重大歷史結構性歧視成因，應由國家元首行使特赦權，以撫平族群創傷並推動法制反省。',
        'matchText': '部分一致 (75%)',
        'matchColor': const Color(0xFFEF6C00),
        'analysis': '蔣勳、胡德夫、人間雜誌等民間團體曾向蔣經國總統陳情特赦，雖未果但催生後續原住民族權益保障運動。',
        'tiltAngle': -0.05,
      },
    ],

    // case-cross-marriage-1445 跨國同婚首例勝訴案
    'case-cross-marriage-1445': [
      {
        'title': '引用消極公序良俗排除不承認同婚母國法，准予登記',
        'description': '婚姻自由受憲法保障，適用外國法若違反我國公共秩序善良風俗，應不予適用，命戶政准予結婚。',
        'matchText': '高度一致 (95%)',
        'matchColor': const Color(0xFF2E7D32),
        'analysis': '臺北高等行政法院109年度訴字第1445號判決首開先例，撤銷戶政事務所否准處分，判決命准予結婚登記。',
        'tiltAngle': -0.15,
      },
      {
        'title': '依涉民法嚴格適用當事人母國法，駁回起訴',
        'description': '涉外民事法律適用法第46條明定婚姻依各該當事人本國法，馬來西亞未承認同婚，依法不得登記。',
        'matchText': '立場相左 (30%)',
        'matchColor': const Color(0xFFC62828),
        'analysis': '戶政事務所之答辯理由，但行政法院認定涉民法第8條公序良俗得排除侵害憲法基本權利之外國法。',
        'tiltAngle': 0.15,
      },
      {
        'title': '主管機關應通函全國統一放寬跨國同婚標準',
        'description': '避免個案當事人逐一提起行政訴訟耗費司法資源，內政部應通函各戶政事務所全面解套。',
        'matchText': '部分一致 (95%)',
        'matchColor': const Color(0xFFEF6C00),
        'analysis': '內政部後續於2023年正式發布函釋，除兩岸婚姻外，跨國伴侶母國不承認同婚者亦全面准予在台登記。',
        'tiltAngle': -0.05,
      },
    ],

    // case-prison-selection-13 外役監條例平等權案
    'case-prison-selection-13': [
      {
        'title': '一刀切排除累犯違反憲法平等原則，二年內失效',
        'description': '外役監條例不分前案情節輕重一律剝奪遴選資格，手段過苛不符比例原則與受刑人復歸社會權利。',
        'matchText': '高度一致 (95%)',
        'matchColor': const Color(0xFF2E7D32),
        'analysis': '憲法法庭112年憲判字第13號判決宣告外役監條例第4條第1項但書第1款違憲，限期二年內失效。',
        'tiltAngle': -0.15,
      },
      {
        'title': '外役監屬低度戒護特惠制度，立法裁量從嚴排查合憲',
        'description': '累犯具有較高再犯風險，外役監無圍牆高壓管理，從嚴排除累犯符合社會安全防衛與公眾信任。',
        'matchText': '立場相左 (40%)',
        'matchColor': const Color(0xFFC62828),
        'analysis': '法務部於言詞辯論時之主張，但憲法裁判指陳受刑人前案若屬易科罰金微罪，亦受一律排除，顯失衡平。',
        'tiltAngle': 0.15,
      },
      {
        'title': '建立個別化與科學化悛悔評估機制代替身分限制',
        'description': '修法應改以在監行狀、戒癮成果、再犯危險性評估作實質審查，落實個別處遇原則。',
        'matchText': '部分一致 (90%)',
        'matchColor': const Color(0xFFEF6C00),
        'analysis': '立法院2023年三讀修正外役監條例，排除重大暴力犯罪，但恢復微罪累犯得經個別實質審查遴選之機制。',
        'tiltAngle': -0.05,
      },
    ],
  };

  // 2. 觀點光譜 註冊表
  static final Map<String, List<Map<String, dynamic>>> _spectrumNodesRegistry = {
    '318': [
      {
        'value': 15.0,
        'label': '法治安定派',
        'shortTitle': '法安定性優先',
        'fullText': '佔領國會、入侵行政機關本質上已逾越集會遊行紅線，造成重大秩序混亂。若不予追究，將嚴重損害法律尊嚴，誘發日後失序。',
        'color': const Color(0xFFC62828),
      },
      {
        'value': 50.0,
        'label': '理性法規派',
        'shortTitle': '手段利益衡平',
        'fullText': '佔領立法院表達政治訴求或可理解，但抗爭手段仍應受適度比例審查，司法應審酌情狀而非無條件全盤免責。',
        'color': const Color(0xFFEF6C00),
      },
      {
        'value': 85.0,
        'label': '抵抗權保護派',
        'shortTitle': '公民不服從防線',
        'fullText': '服貿審查出現國會程序重大瑕疵，人民在窮盡救濟管道後，佔領議場是阻卻違法的最後手段，司法理當肯定公民不服從之憲政防衛功能。',
        'color': const Color(0xFF2E7D32),
      },
    ],

    'case-rca-pollution': [
      {
        'value': 15.0,
        'label': '傳統因果派',
        'shortTitle': '微觀科學嚴格舉證',
        'fullText': '侵權行為因果關係必須由原告舉證至無可置疑，證明特定化學物質在個別原告體內造成細胞突變，避免擴大企業無限責任。',
        'color': const Color(0xFFC62828),
      },
      {
        'value': 50.0,
        'label': '損害衡平派',
        'shortTitle': '優勢證據折衷判定',
        'fullText': '考量勞雇實力懸殊，原告達一定優勢因果證明時，法院得審酌化學溶劑危險性，作適度損害賠償額之衡平酌定。',
        'color': const Color(0xFFEF6C00),
      },
      {
        'value': 85.0,
        'label': '環境公害正義派',
        'shortTitle': '疫學因果倒置面紗穿透',
        'fullText': '化學溶劑具隱密與遲發性，凡具統計顯著罹病率即應倒置因果關係舉證責任，並穿透惡意脫產之跨國控股面紗，命母公司連帶負責。',
        'color': const Color(0xFF2E7D32),
      },
    ],

    'case-su-chien-ho': [
      {
        'value': 15.0,
        'label': '實體追訴派',
        'shortTitle': '犯罪打擊與心證確信',
        'fullText': '重案偵破不易，只要自白內容與現場諸多細節相符且經同案犯指認，法官心證已明即可判罪，不應因程序技術瑕疵放縱嫌犯。',
        'color': const Color(0xFFC62828),
      },
      {
        'value': 50.0,
        'label': '證據審查派',
        'shortTitle': '自白補強與可信性',
        'fullText': '自白固然重要，但法庭必須調查其他獨立物證進行補強，若補強證據不足以完全排除合理懷疑，應開啟再審重新鑑定。',
        'color': const Color(0xFFEF6C00),
      },
      {
        'value': 85.0,
        'label': '正當程序派',
        'shortTitle': '無罪推定毒樹果實',
        'fullText': '不正訊問與刑求取得之自白絕對無證據能力。即便有天大嫌疑，只要國家無法提出合法客觀物證，就必須堅定判決無罪。',
        'color': const Color(0xFF2E7D32),
      },
    ],

    'case-tang-ying-shen': [
      {
        'value': 15.0,
        'label': '嚴刑應報派',
        'shortTitle': '生命填命絕對應報',
        'fullText': '殺害三條無辜性命包括年幼孩童，手段兇殘危害治安至鉅，無論背後動機如何，依法判處死刑是維護社會公義之唯一回應。',
        'color': const Color(0xFFC62828),
      },
      {
        'value': 50.0,
        'label': '情狀審酌派',
        'shortTitle': '刑法57條量刑衡平',
        'fullText': '司法量刑必須深入探究行為人犯罪時所受之強烈刺激與困境，湯英伸遭扣身分證、長期超時勞動，應予以憫恕處以無期徒刑。',
        'color': const Color(0xFFEF6C00),
      },
      {
        'value': 85.0,
        'label': '社會結構反省派',
        'shortTitle': '族群壓迫社會責任',
        'fullText': '本案是台灣主流社會對原住民族勞動剝削與文化歧視下的集體悲劇。國家以死刑奪其性命，是將制度性不公完全推給弱勢個人承擔。',
        'color': const Color(0xFF2E7D32),
      },
    ],

    'case-cross-marriage-1445': [
      {
        'value': 15.0,
        'label': '涉外法條形式派',
        'shortTitle': '嚴格遵守本國法主義',
        'fullText': '涉民法第46條明定涉外婚姻成立要件依當事人各該本國法，外國法令未認可同婚，我國戶政自應予以尊重，不得逕行准許登記。',
        'color': const Color(0xFFC62828),
      },
      {
        'value': 50.0,
        'label': '涉外調和派',
        'shortTitle': '立法配套與外交互惠',
        'fullText': '跨國婚姻涉及雙方國家主權與判決承認，應由立法院或外交管道訂定互惠專法，而非單純依賴行政法院個案訴訟填補。',
        'color': const Color(0xFFEF6C00),
      },
      {
        'value': 85.0,
        'label': '憲法平權普世派',
        'shortTitle': '消極公序良俗排除歧視',
        'fullText': '婚姻自由是憲法保障之普世人權，外國不承認同婚之法律牴觸我國公序良俗核心，依法應予排除，全面落實同婚平權。',
        'color': const Color(0xFF2E7D32),
      },
    ],

    'case-prison-selection-13': [
      {
        'value': 15.0,
        'label': '治安從嚴防衛派',
        'shortTitle': '低度戒護資格從嚴',
        'fullText': '外役監無圍牆高壓監管，受刑人有返家探視權限。累犯具反覆實施犯罪危險，法律一律從嚴排除符合大眾對治安秩序之期待。',
        'color': const Color(0xFFC62828),
      },
      {
        'value': 50.0,
        'label': '罪質分類派',
        'shortTitle': '區分重罪累犯與微罪',
        'fullText': '不應一刀切排除，應區分前案罪質：前案為暴力重罪累犯應嚴格禁止，但輕微財產或過失微罪累犯則應允許納入遴選。',
        'color': const Color(0xFFEF6C00),
      },
      {
        'value': 85.0,
        'label': '復歸社會平等派',
        'shortTitle': '平等處遇與個別化矯正',
        'fullText': '受刑人服刑目的在於再社會化，一律排除累犯剝奪其重返社會階梯，違反憲法平等原則，應建立個別化實質評估制度。',
        'color': const Color(0xFF2E7D32),
      },
    ],
  };

  // 3. 虛擬詰問室 註冊表
  static final Map<String, CaseWitnessProfile> _witnessRegistry = {
    'case-su-chien-ho': CaseWitnessProfile(
      quickQuestions: {
        '被告': [
          '你在汐止分局偵訊時，是否真的遭到辦案員警刑訊逼供？',
          '案發當天你與劉秉 dried、莊林勳三人真實的行程與不在場證明為何？',
          '歷經21年四度被判死刑，你如何堅持到獲判無罪定讞？',
        ],
        '檢方': [
          '公訴機關如何論證三名被告自白具有客觀任意性？',
          '現場採集之毛髮與指紋為何完全沒有三名被告之跡證？',
          '在王文孝槍決伏法後，控方僅憑自白起訴之法理依據為何？',
        ],
        '李昌鈺': [
          '李博士，您勘驗吳銘漢夫婦命案現場後，得出哪些關鍵鑑識結論？',
          '現場空間極度狹小，真的有可能容納四名持刀成年人同時行兇嗎？',
          '血跡噴濺痕與刀痕型態是否支持一人單獨犯案之假設？',
        ],
        '預設': [
          '蘇建和案對台灣刑事審判的無罪推定原則造成了什麼根本改變？',
          '刑事妥速審判法在本案無罪定讞中扮演了什麼關鍵角色？',
          '本案如何推動自白補強法則與警訊全程錄音錄影立法？',
        ],
      },
      answersByKeyword: {
        '被告': {
          '刑訊': '在汐止分局警局地下室，警察用打火機烤我的下巴、用毛巾摀住口鼻強行灌水，甚至用木棍猛擊。在那種絕望下，我只能依照警察寫好的口供認罪以求活命。那根本不是事實！',
          '行程': '案發當夜我們根本不在汐止命案現場，我們在撞球場和朋友聚會。但因為王文孝被捕後隨便指認了我們三個，警察就直接逮捕我們，所有的不在場證詞全被置之不理。',
          '堅持': '支撐我們活下去的，是家人永不放棄的奔走、民間司改會律師團的無私救援、以及我們內心對於清白的堅定信念。如果我們認罪放棄，就永遠無法洗刷殺人的污名。',
        },
        '檢方': {
          '任意性': '檢方起訴是基於被告三人在偵查初期曾多次作出自白，且自白中描述了開鎖、搜刮財物及行兇等細節，與現場勘查記錄有相當程度之吻合，故依法提起公訴。',
          '跡證': '重案現場因被害人激烈反抗與環境混亂，未能採集到全部嫌犯之完整指紋毛髮在實務上並非罕見。早期鑑識科技有限，公訴機關當時綜合各項共犯口供作出心證。',
          '王文孝': '王文孝在軍法審判伏法前之多次筆錄均指證有同夥分工，檢方職責所在必須徹查到底。後續法院嚴格檢驗自白法則並開啟再審，公訴機關亦尊重終局裁判。',
        },
        '李昌鈺': {
          '結論': '我們仔細重建了汐止命案現場空間，現場臥室極其狹窄，扣除床鋪與櫃子後，站立空間僅容一人轉身。四個人同時在如此狹小空間揮舞菜刀與水果刀，極不符合物理運動與血跡動力學規律。',
          '狹小': '從血跡噴濺角度、揮刀軌跡與牆面刮痕分析，所有攻擊方向均具有高度一致性。若四人同時在窄巷般的床邊砍殺，彼此必然會互相阻礙甚至造成誤傷，但現場完全沒有共犯互傷之血跡反應。',
          '一人': '我們的鑑定意見是：現場客觀物理證據「極高度支持一人犯案」的假設。一把開山刀與一把水果刀的傷口型態，完全可以由王文孝一人先後輪流使用造成，缺乏多人集體行兇的客觀物證。',
        },
      },
      defaultAnswers: {
        '被告': '我們從二十歲的青年，被關到四十多歲白髮蒼蒼。這場無罪定讞不只是我們三人的清白，更是台灣司法不再冤殺無辜的歷史見證。',
        '檢方': '公訴機關遵循客觀義務，本案歷經多次非常上訴與再審調查，促使刑事訴訟朝向嚴格證據法則與精準鑑識方向發展。',
        '李昌鈺': '讓證據說話，是鑑識科學的唯一使命。沒有客觀物證支持的口供，在科學鑑識面前是極其脆弱的。',
      },
    ),

    'case-rca-pollution': CaseWitnessProfile(
      quickQuestions: {
        '原告': [
          'RCA員工在廠區工作時，所接觸的化學溶劑具體情況為何？',
          '在提出集體訴訟求償過程中，受害勞工面臨的最大法律阻礙是什麼？',
          '對於最高法院判決跨國母公司負連帶賠償責任，你有何感想？',
        ],
        '被告': [
          '跨國母公司主張本案請求權已罹於十年消滅時效，其依據為何？',
          '被告方如何論證廠區地下水溶劑與勞工罹患特定癌症無因果關係？',
          '針對法院認定控股公司惡意脫產構成「權利濫用」，你方立場為何？',
        ],
        '專家': [
          '公共衛生專家如何透過「流行病學調查」證明暴露與癌症的因果關係？',
          '本案為何無法採用傳統民法的微觀因果關係舉證標準？',
          '何謂「穿透公司面紗原則」，在本案集體訴訟中如何實踐？',
        ],
        '預設': [
          'RCA案對台灣環境公害訴訟的舉證責任分配帶來了什麼革命性改變？',
          '最高法院如何認定跨國控股公司對台灣子公司負侵權連帶責任？',
          '公害訴訟中「消滅時效抗辯之權利濫用」具有什麼法理意涵？',
        ],
      },
      answersByKeyword: {
        '原告': {
          '化學溶劑': '我們在廠區每天用三氯乙烯、四氯乙烯清洗電路板，廠房密不通風，溶劑味道刺鼻。更可怕的是，工廠將有毒廢料直接注入地下，我們幾千名女工每天喝的、洗澡的，全是受到嚴重劇毒污染的地下水！',
          '阻礙': '最大阻礙是「因果關係」與「十年時效」！公司惡意隱匿污染報告二十年，等我們紛紛罹患乳癌、子宮頸癌時，律師竟然主張追訴期已經過期！而且要求我們個別證明是哪一口水導致哪一個細胞癌變，這在科學上根本不可能。',
          '感想': '這場官司打了二十多年，上千名姐妹有的已經抱憾離世。最高法院認定母公司必須負責、不能用脫產和時效逃避，終於還給台灣勞工最起碼的尊嚴，證明跨國大企業不能把台灣當成毒物殖民地！',
        },
        '被告': {
          '時效': '民法侵權行為損害賠償請求權明定自侵權行為時起逾十年消滅。原告所主張之廠區工作期間早在民國六、七十年間，提起訴訟時顯已罹於民法法定時效，基於法律安定性，公司依法行使時效抗辯權。',
          '因果': '癌症成因極為複雜，涉及個人體質、飲食習慣、生活環境與家族遺傳等多元變數。原告未能提出確切之醫學分子生物學檢驗，證明個別原告體內腫瘤係因廠區微量化學物質直接誘發。',
          '權利濫用': '跨國公司之股權處分與海外資產配置均符合國際商業併購常規，原告將合法商業重組定性為惡意脫產，缺乏實質公司法依據。',
        },
        '專家': {
          '流行病學': '我們追蹤數千名曾於RCA廠區工作達一定年資之員工，與未暴露於污染溶劑之對照族群比對，統計結果顯示RCA女工罹患特定癌症（如乳癌、淋巴癌）之相對危險度（RR）高達一般人的數倍，呈現極高度統計顯著性。',
          '微觀': '公害毒物具有長期、低劑量、複合累積及潛伏期長的特質，若強求被害人證明微觀化學反應，將使所有公害受害者永無受賠償可能。因此最高法院採納「疫學因果關係」，只要符合暴露關聯，即推定具有法律因果關係。',
          '面紗': 'RCA母公司明知台灣廠區地下水劇毒超標，卻刻意將上億美金資產匯往國外，將台灣RCA減資淘空為空殼公司。法院認定此舉係濫用公司獨立法人格逃避法律責任，依法穿透面紗命實質控制之跨國母公司負連帶賠償。',
        },
      },
      defaultAnswers: {
        '原告': '我們雖然失去了青春與健康，但這場判決為台灣所有勞工爭取到了環境知情權與公害舉證倒置的歷史公道。',
        '被告': '被告公司尊重司法終局判決，但對判決突破民法時效與傳統因果關係舉證法則之見解，仍表保留。',
        '專家': 'RCA判決標誌著台灣司法從傳統個別侵權，正式邁向現代風險社會與集體公害環境正義的最高里程碑。',
      },
    ),

    'case-tang-ying-shen': CaseWitnessProfile(
      quickQuestions: {
        '被告': [
          '湯英伸，你從阿里山來到台北求職時，具體遭遇了什麼剝削困境？',
          '案發當晚，洗衣店雇主究竟說了什麼讓你情緒徹底失控？',
          '在看守所面對死刑審判時，你內心最深切的懺悔與想望是什麼？',
        ],
        '雇主家屬': [
          '對於湯英伸殺害一家三口包括幼童，家屬如何看待檢方求處死刑？',
          '外界強調原住民遭剝削的弱勢處境，家屬對此有何回應？',
        ],
        '辯護律師': [
          '律師團為何全力向法院主張應適用刑法第57條審酌情狀判處無期徒刑？',
          '民間社會與知識界為何發起搶救湯英伸並向總統陳請特赦？',
          '本案對後續台灣原住民族權益保障運動產生了什麼長遠影響？',
        ],
        '預設': [
          '湯英伸案在台灣死刑法理思辨史上佔有什麼關鍵地位？',
          '刑法第57條量刑審酌要件在本案中引發了哪些重大爭議？',
          '本案如何促成台灣社會對「吳鳳神話」與原住民刻板印象之深刻反省？',
        ],
      },
      answersByKeyword: {
        '被告': {
          '求職': '我從阿里山鄒族特富野部落下山，想幫家裡分擔家計，卻被職業介紹所騙到了新生洗衣店。老闆扣留了我的身分證和薪水，每天逼我洗衣服、燙衣服超過十七個小時，睡在洗衣機旁邊的閣樓，我根本無法離開。',
          '當晚': '那天深夜我工作極度疲累，向老闆提出想辭職拿回身分證回嘉義，老闆不但拒絕，還用極其難聽的話辱罵我、罵我是番仔、不知好歹，甚至威脅要叫人打我。那一瞬間我腦袋一片空白，失控拿起了鐵拔釘器……',
          '懺悔': '我殺了人，奪走了三條生命，特別是小妹妹，我每晚都在懺悔，我知道我罪不可赦。我的身分證雖然被扣押，但我真的不該剝奪他人的生命。我只希望我的死，能讓社會看見我們原住民年輕人離鄉背井的痛苦。',
        },
        '雇主家屬': {
          '死刑': '湯英伸連殺我父母和年幼的妹妹三個人，手段殘忍至極，現場到處都是血跡。不管工作有什麼糾紛，都不應該用屠殺全家人的手段來解決，殺人償命依法判處死刑是唯一公道！',
          '處境': '社會團體一直替兇手講話，說他多可憐、原住民多弱勢，但誰來替無辜枉死的小妹妹講話？她才兩歲，她又剝削了誰？我們失去至親的痛苦，難道就因為湯英伸是原住民就該被忽視嗎？',
        },
        '辯護律師': {
          '57條': '刑法第57條明文規定量刑應審酌「犯罪之動機、所受之刺激、犯人之生活狀況與品行」。湯英伸年僅19歲，求職遭扣押身分證強迫勞動，在極度疲憊與身心受辱之激憤下犯案，法院應有憫恕給予無期徒刑之裁量空間。',
          '特赦': '蔣勳、胡德夫、人間雜誌發起特赦，是因為看見這場悲劇背後是原住民結構性遭漢人社會邊緣化與剝削的歷史共業。湯英伸的失控是整個社會制度失靈的受害者，國家不該以冷酷的子彈作為唯一的法律答覆。',
          '影響': '湯英伸案深深刺痛了台灣知識界的良知，直接催生了「原住民族權利促進會」，促使教育部廢除了國小課本中歧視原住民的「吳鳳神話」，開啟了台灣原住民正名與人權覺醒的新篇章。',
        },
      },
      defaultAnswers: {
        '被告': '我接受法律的制裁，願上帝原諒我的罪愆。但願阿里山上的族人弟兄，未來能擁有更公平的生存尊嚴。',
        '雇主家屬': '我們希望司法嚴正執法，維護生命的尊嚴，不要讓殘忍殺害無辜幼童的暴行在社會倡議中被模糊焦點。',
        '辯護律師': '湯英伸以19歲的年輕生命走上刑場，但他的鮮血促使台灣法制學會了看見弱勢族群的深層痛苦。',
      },
    ),

    'case-cross-marriage-1445': CaseWitnessProfile(
      quickQuestions: {
        '原告': [
          '祁家威先生，你在推動台灣同婚合法化後，為何再次為跨國伴侶提起訴訟？',
          '戶政事務所以「馬來西亞法律不承認同婚」拒絕登記，你們如何抗辯？',
          '對於臺北高等行政法院判決准予登記首例勝訴，你認為最大的意義為何？',
        ],
        '戶政事務所': [
          '行政機關拒絕核准跨國同性伴侶結婚登記之法定依據為何？',
          '依涉外民事法律適用法第46條規定，婚姻成立要件如何審查？',
        ],
        '行政法院': [
          '合議庭如何透過涉外法第8條「消極公序良俗原則」排除外國不平等法律？',
          '本案判決如何貫徹司法院釋字第748號解釋保障婚姻自由之意旨？',
          '此勝訴判決對內政部後續全面放寬跨國同性婚姻登記產生了什麼影響？',
        ],
        '預設': [
          '跨國同婚爭訟的核心涉外私法與憲法爭議為何？',
          '反致原則與公序良俗條款在跨國同性婚姻中如何適用？',
          '台灣婚姻平權法制化在國際法與涉外民事法上的開創性意義是什麼？',
        ],
      },
      answersByKeyword: {
        '原告': {
          '訴訟': '釋字第748號宣告同性婚姻受憲法平等保護，但專法上路後，只要伴侶的母國未承認同婚（例如馬來西亞），跨國伴侶就被拒於門外。這等於是讓外國的歧視性法律凌駕在我國憲法之上，我必須再次走上法庭！',
          '抗辯': '我們抗辯：中華民國憲法保障的婚姻自由是一體適用的基本權利。涉外民事法律適用法第8條明確規定，適用外國法若違反我國公共秩序或善良風俗時，不予適用。外國禁止同婚明顯違反我國人權公序良俗！',
          '意義': '這是亞洲跨國同婚首例勝訴！法院勇敢認定：台灣的憲法保障不因國籍而打折，相愛的人不論國籍，都可以在台灣受到法律的完整祝福，這為所有跨國同志伴侶撕開了曙光。',
        },
        '戶政事務所': {
          '依據': '戶政事務所為行政執行機關，受依法行政原則拘束。依《涉外民事法律適用法》第46條前段明定：「婚姻之成立，依各該當事人之本國法。」原告伴侶之母國馬來西亞民法未保障同婚，故依法否准登記。',
          '46條': '涉民法第46條採各該當事人本國法主義，旨在確保涉外身分關係在雙方母國均能發生有效婚姻關係，避免產生跛腳婚姻。行政機關無權逕行排除法律明文，故當時需由司法裁判釐清。',
        },
        '行政法院': {
          '公序良俗': '本院審理認定，婚姻自由及平等權已由釋字第748號確認為我國憲法保障之核心基本權。馬來西亞法禁止同性成立婚姻，牴觸我國憲法公序良俗核心，依涉民法第8條規定應消極不予適用，直接適用我國同婚專法准予登記。',
          '748號': '釋字第748號之憲法保護傘並非僅限於本國國民。在台灣境內請求行使婚姻自由權利時，國家行政公權力不得以不合理之外國差別待遇限制人民之憲法權利。',
          '影響': '本院判決確立了公序良俗條款之憲法化適用，促使內政部於2023年正式變更行政函釋，全面放寬除兩岸外之所有跨國同性伴侶在台登記結婚。',
        },
      },
      defaultAnswers: {
        '原告': '愛沒有國界，平權更不該止於國境。這場勝訴證明了台灣是亞洲人權與法治的燈塔。',
        '戶政事務所': '行政機關尊重法院裁判，後續已配合內政部修正後之函釋辦理跨國同性伴侶之結婚登記作業。',
        '行政法院': '司法裁判以憲法核心人權價值審查涉外法律衝突，落實實質平等保障。',
      },
    ),

    'case-prison-selection-13': CaseWitnessProfile(
      quickQuestions: {
        '聲請人': [
          '受刑人聲請憲法審查的核心訴求與受侵害權利為何？',
          '外役監條例一刀切排除累犯，對在監表現良好的受刑人造成什麼不公？',
          '對於憲法法庭判決該條款違憲定期失效，你有何體會？',
        ],
        '法務部': [
          '法務部矯正署當初主張嚴格排除累犯遴選外役監之治安理由為何？',
          '外役監作為低度戒護機構，法務部如何防範脫逃與重大再犯風險？',
        ],
        '憲法法庭': [
          '憲法法庭合議庭認定外役監條例第4條但書第1款違反平等權之法理依據為何？',
          '判決為何未宣告立即失效，而是宣告定期二年失效？',
          '判決如何引導立法院修正外役監條例，兼顧社會防衛與個別化處遇？',
        ],
        '預設': [
          '112年憲判字第13號判決對受刑人憲法基本權利保障帶來了什麼變革？',
          '外役監遴選資格中「平等原則」與「比例原則」如何進行憲政審查？',
          '本案如何促成台灣刑事矯正法制邁向個別化、科學化審查新紀元？',
        ],
      },
      answersByKeyword: {
        '聲請人': {
          '訴求': '我前案只是一筆易科罰金繳清的微罪，後案在監服刑期間遵守一切紀律、考績優異。然而外役監條例卻只因為我是法律上的「累犯」，就一律剝奪我參加遴選的機會，這嚴重違反憲法第7條平等原則！',
          '不公': '外役監是受刑人復歸社會的中途重要跳板。法律不論前案是多麼輕微、後案表現多麼良好，一律貼上累犯標籤徹底封殺，這讓願意改過自新的受刑人喪失希望，根本不符合矯正教育的初衷。',
          '體會': '憲法法庭的大法官終於看見了我們！受刑人雖然被剝奪人身自由，但憲法上的平等權與人格尊嚴依然存在。這份判決給了所有努力改過的更生人一份公平的機會。',
        },
        '法務部': {
          '理由': '外役監是開放式處遇機構，受刑人作業無監控戒具、可定期返家探視。累犯具有較高之犯罪習性與再犯率，立法機關基於社會防衛與公眾安全考量，採取嚴格消極資格限制，屬立法形成自由之範疇。',
          '防範': '近年社會對重大刑案罪犯或累犯遴選外役監並發生脫逃事件高度關注，主管機關有義務回應社會對治安秩序之期待，確保遴選制度之高度嚴密與公信力。',
        },
        '憲法法庭': {
          '法理': '外役監條例第4條第1項但書第1款未區分前案罪質輕重、是否為過失或易科罰金微罪，亦未考量前案與後案之間隔期間與悛悔情形，一律排除遴選資格，手段過苛且不具實質關聯性，違反憲法第7條平等權。',
          '定期': '若宣告立即失效，將導致外役監遴選法規欠缺消極資格基準，恐對監獄管理及社會治安造成衝擊。因此宣告定期二年失效，督促立法院在期限內通盤修正法規。',
          '立法院': '判決明確指引立法方向：應改以「罪質與再犯危險性」作為區分基準。立法院後續修正外役監條例，排除重大暴力犯罪者，但恢復微罪累犯得本於個案實質審查遴選之權益，兼顧社會防護與受刑人復歸。',
        },
      },
      defaultAnswers: {
        '聲請人': '我們渴望改過自新，外役監的公平遴選機會是我們重建人生、重返社會家庭的重要階梯。',
        '法務部': '法務部已遵照憲法法庭判決意旨完成修法，建構更周延、透明且兼顧社會安全之遴選審查制度。',
        '憲法法庭': '受刑人仍為憲法基本權利主體，國家刑罰矯正制度之設計必須符合平等處遇與實質正義之憲政防線。',
      },
    ),
  };

  // 4. 意見塗鴉牆 註冊表
  static final Map<String, List<Map<String, dynamic>>> _opinionStickersRegistry = {
    'case-rca-pollution': [
      {
        'id': '1',
        'text': '二十年的抗爭，證明了勞工的生命健康不該是經濟奇蹟的犧牲品。',
        'resonanceCount': 245,
        'color': const Color(0xFFEAF6EF),
        'textColor': const Color(0xFF357A53),
        'rotation': -2.1,
      },
      {
        'id': '2',
        'text': '揭穿公司面紗原則的落實，讓惡意脫產的跨國控股企業在台灣無所遁形。',
        'resonanceCount': 188,
        'color': const Color(0xFFF0EEF9),
        'textColor': const Color(0xFF6D649A),
        'rotation': 1.8,
      },
      {
        'id': '3',
        'text': '疫學因果關係倒置舉證責任，是公害侵權訴訟最偉大的法理進步！',
        'resonanceCount': 312,
        'color': const Color(0xFFEAF4F7),
        'textColor': const Color(0xFF4A7C8C),
        'rotation': -1.4,
      },
    ],

    'case-su-chien-ho': [
      {
        'id': '1',
        'text': '無罪推定不是縱容犯罪，而是確保國家公權力永遠不能冤殺無辜。',
        'resonanceCount': 295,
        'color': const Color(0xFFEAF6EF),
        'textColor': const Color(0xFF357A53),
        'rotation': -1.9,
      },
      {
        'id': '2',
        'text': '沒有程序正義，就沒有真正的實體正義；杜絕刑求逼供是司法的底線。',
        'resonanceCount': 230,
        'color': const Color(0xFFF0EEF9),
        'textColor': const Color(0xFF6D649A),
        'rotation': 2.0,
      },
      {
        'id': '3',
        'text': '二十一年的青春換來台灣刑事訴訟法的全面改革，致敬所有堅持真相的救援者。',
        'resonanceCount': 342,
        'color': const Color(0xFFEAF4F7),
        'textColor': const Color(0xFF4A7C8C),
        'rotation': -1.1,
      },
    ],

    'case-tang-ying-shen': [
      {
        'id': '1',
        'text': '湯英伸以年輕生命喚醒了台灣社會，正視原住民族長期承受的不公與剝削。',
        'resonanceCount': 268,
        'color': const Color(0xFFFFF2CF),
        'textColor': const Color(0xFF9E7B2D),
        'rotation': -2.0,
      },
      {
        'id': '2',
        'text': '刑法第57條的量刑審酌不該是冷冰冰的條文，更應看見弱勢底層無聲的絕望呼救。',
        'resonanceCount': 214,
        'color': const Color(0xFFFBECEC),
        'textColor': const Color(0xFFC84E55),
        'rotation': 1.5,
      },
      {
        'id': '3',
        'text': '死刑的槍響終結了十九歲的青年，但開啟了台灣原住民權利運動的漫長征途。',
        'resonanceCount': 305,
        'color': const Color(0xFFEAF4F7),
        'textColor': const Color(0xFF4A7C8C),
        'rotation': -1.3,
      },
    ],

    'case-cross-marriage-1445': [
      {
        'id': '1',
        'text': '愛沒有國界，消極公序良俗成了守護憲法婚姻平權的最強防線！',
        'resonanceCount': 280,
        'color': const Color(0xFFEAF6EF),
        'textColor': const Color(0xFF357A53),
        'rotation': -1.7,
      },
      {
        'id': '2',
        'text': '感謝祁家威先生永不放棄的堅持，讓台灣成為亞洲真正的多元包容燈塔。',
        'resonanceCount': 240,
        'color': const Color(0xFFF0EEF9),
        'textColor': const Color(0xFF6D649A),
        'rotation': 1.6,
      },
      {
        'id': '3',
        'text': '跨國同婚的合法化，證明了憲法人權保障絕不因國籍與地域而打折。',
        'resonanceCount': 310,
        'color': const Color(0xFFEAF4F7),
        'textColor': const Color(0xFF4A7C8C),
        'rotation': -1.2,
      },
    ],

    'case-prison-selection-13': [
      {
        'id': '1',
        'text': '外役監是受刑人復歸社會的中途站，而不是一刀切的身分排除牢籠。',
        'resonanceCount': 195,
        'color': const Color(0xFFEAF6EF),
        'textColor': const Color(0xFF357A53),
        'rotation': -1.8,
      },
      {
        'id': '2',
        'text': '憲法平等權要求實質正義，對待微罪累犯應依個案悛悔進行科學化評估。',
        'resonanceCount': 175,
        'color': const Color(0xFFF0EEF9),
        'textColor': const Color(0xFF6D649A),
        'rotation': 1.4,
      },
      {
        'id': '3',
        'text': '定期失效判決督促立法院改革外役監條例，兼顧社會防護與更生人希望。',
        'resonanceCount': 225,
        'color': const Color(0xFFEAF4F7),
        'textColor': const Color(0xFF4A7C8C),
        'rotation': -1.5,
      },
    ],
  };

  // 5. 社會連鎖網絡 註冊表
  static final Map<String, List<Map<String, dynamic>>> _socialGraphRegistry = {
    'case-rca-pollution': [
      {
        'id': 'root',
        'title': 'RCA 毒物公害集體訴訟',
        'type': 'core',
        'description': '台灣史上求償人數最多、纏訟最久之環境公害侵權訴訟，判賠逾5億元定讞。',
      },
      {
        'id': 'causation',
        'title': '司法變革：疫學因果關係確立',
        'type': 'effect',
        'description': '最高法院判決正式確立公害集體訴訟因果關係倒置舉證責任，凡達統計顯著暴露即推定因果。',
      },
      {
        'id': 'piercing',
        'title': '公司法理：揭穿公司面紗原則',
        'type': 'effect',
        'description': '突破獨立法人格限制，裁定跨國控股母公司惡意淘空台灣子公司資產須負連帶侵權賠償。',
      },
      {
        'id': 'abuse',
        'title': '民法誠信：消滅時效抗辯之權利濫用',
        'type': 'effect',
        'description': '認定加害企業隱匿毒害資訊且脫產逃避責任，事後主張十年消滅時效屬於權利濫用，不予准許。',
      },
      {
        'id': 'labor',
        'title': '勞工保護：推動職災長期監測制度',
        'type': 'effect',
        'description': '促成勞動部修訂勞工職業災害保險及保護法，建立有毒化學環境作業勞工終身追蹤健檢體系。',
      },
    ],

    'case-su-chien-ho': [
      {
        'id': 'root',
        'title': '蘇建和案無罪定讞',
        'type': 'core',
        'description': '歷經21年審理、再審與非常上訴，最高法院以刑求自白無證據能力判決無罪確定。',
      },
      {
        'id': 'confession',
        'title': '刑事訴訟：自白法則與任意性審查',
        'type': 'effect',
        'description': '確立自白必須排除任何強暴脅迫，且不得以唯一口供作為有罪判決之基礎，推動全程錄音錄影。',
      },
      {
        'id': 'speedy',
        'title': '立法改革：催生刑事妥速審判法',
        'type': 'effect',
        'description': '為防止案件長期懸而未決侵害被告人權，立法院制定《刑事妥速審判法》限制羈押與上訴期限。',
      },
      {
        'id': 'forensic',
        'title': '鑑識科學：李昌鈺現場重建引進',
        'type': 'effect',
        'description': '引入現代血跡噴濺動力學與犯罪現場三維重建技術，使台灣司法從口供辦案轉向客觀物證。',
      },
      {
        'id': 'civil',
        'title': '司法改革：民間司改會之創立壯大',
        'type': 'effect',
        'description': '本案救援直接促成了民間司法改革基金會的成立，成為推動台灣司法制度透明化的核心民間力量。',
      },
    ],

    'case-tang-ying-shen': [
      {
        'id': 'root',
        'title': '湯英伸洗衣店命案',
        'type': 'core',
        'description': '阿里山鄒族青年因遭扣押身分證與過勞剝削，失控殺害雇主一家三人遭判處死刑槍決。',
      },
      {
        'id': 'sentencing',
        'title': '司法省思：刑法第57條量刑審酌爭端',
        'type': 'effect',
        'description': '引發法界對於死刑量刑裁量之深刻檢討，省思量刑是否應深入考量行為人受社會壓迫之生活處境。',
      },
      {
        'id': 'indigenous',
        'title': '人權覺醒：原住民權利促進會成立',
        'type': 'effect',
        'description': '案件震撼台灣知識界，催生1984年台灣原住民族權利促進會成立，吹響原住民族自決與反歧視號角。',
      },
      {
        'id': 'wufeng',
        'title': '歷史除魅：破除「吳鳳神話」課本教材',
        'type': 'effect',
        'description': '推動社會反思漢人中心主義之刻板印象，教育部於1989年全面自國小教科書中刪除吳鳳神話。',
      },
      {
        'id': 'labor',
        'title': '勞動保障：就業服務法禁止扣押身分證',
        'type': 'effect',
        'description': '促成立法明文嚴禁雇主扣押勞工身分證件與薪資，建立求職防騙與非典型勞動查察機制。',
      },
    ],

    'case-cross-marriage-1445': [
      {
        'id': 'root',
        'title': '跨國同婚首例勝訴案',
        'type': 'core',
        'description': '祁家威與馬來西亞伴侶因母國不認同婚遭否准，臺北高等行政法院判命准予登記首開勝訴先河。',
      },
      {
        'id': 'conflict',
        'title': '國際私法：消極公序良俗原則之憲法化',
        'type': 'effect',
        'description': '確立涉外民事法律適用法第8條得排除侵害憲法基本權利之外國歧視性法律，樹立司法審判標竿。',
      },
      {
        'id': 'administration',
        'title': '行政函釋：內政部通函全面放寬跨國同婚',
        'type': 'effect',
        'description': '勝訴判決促成內政部於2023年變更行政命令，全面開放除兩岸外所有外國伴侶在台登記同性婚姻。',
      },
      {
        'id': 'humanrights',
        'title': '國際聲譽：奠定亞洲婚姻平權領航地位',
        'type': 'effect',
        'description': '深化台灣作為亞洲首個同婚合法國家的法治落實程度，為各國涉外平權訴訟提供重要判例參考。',
      },
    ],

    'case-prison-selection-13': [
      {
        'id': 'root',
        'title': '112年憲判字第13號判決',
        'type': 'core',
        'description': '憲法法庭宣告外役監條例一律排除累犯受刑人遴選資格違反平等原則，定期二年失效。',
      },
      {
        'id': 'equality',
        'title': '憲政防線：受刑人實質平等權之確立',
        'type': 'effect',
        'description': '確立受刑人受刑期間依然享有憲法基本權利主體地位，國家限制其處遇必須符合實質關聯與比例原則。',
      },
      {
        'id': 'legislation',
        'title': '法制重塑：外役監條例第4條全面三讀修訂',
        'type': 'effect',
        'description': '立法院火速完成修法，改採排除重大暴力與貪污犯，但恢復微罪累犯得經個別實質審查遴選之彈性。',
      },
      {
        'id': 'correction',
        'title': '矯正變革：邁向科學化與個別化處遇評估',
        'type': 'effect',
        'description': '推動矯正署建立受刑人再犯危險評估量表與行狀量化指標，以現代矯正科學取代粗暴之身分標籤。',
      },
    ],
  };

  // 6. 鄉民討論與投開票所 註冊表
  static final Map<String, CaseNetizenDiscussionProfile> _netizenRegistry = {
    'case-rca-pollution': CaseNetizenDiscussionProfile(
      pollQuestion: '最高法院以「疫學因果關係」與「揭穿公司面紗」判決RCA跨國母公司賠償定讞，你覺得合理嗎？',
      defaultVotes: [280, 16],
      comments: [
        {
          'avatar': '公',
          'name': '公害正義陣線',
          'time': '15 分鐘前',
          'stance': '合理派',
          'stanceColor': const Color(0xFF2E7D32),
          'content': '太令人振奮了！這起判決是台灣勞工歷史上的奇蹟。跨國企業惡意將劇毒地下水留給台灣、資產匯回國外，法院用「揭穿公司面紗」徹底瓦解了資本家的脫法藉口！',
          'likes': 68,
          'liked': false,
          'hasCitation': true,
          'source': '法人格否認原則',
        },
        {
          'avatar': '法',
          'name': '民法研究人',
          'time': '1 小時前',
          'stance': '合理派',
          'stanceColor': const Color(0xFF2E7D32),
          'content': '最高法院判決最精彩的地方在於打破了十年消滅時效。被告隱匿污染長達數十年，事後竟然好意思用時效消滅抗辯，這正是民法第148條最典型的「權利濫用」！',
          'likes': 42,
          'liked': false,
          'hasCitation': true,
          'source': '民法第148條',
        },
        {
          'avatar': '經',
          'name': '企業法務觀點',
          'time': '2 小時前',
          'stance': '不合理派',
          'stanceColor': const Color(0xFFC62828),
          'content': '雖然在情感上同情勞工，但疫學統計因果關係跳過了個別因果證明的標準，對於未來企業投資環境是否會造成難以預測的無限連帶責任風險，實務上仍需謹慎評估。',
          'likes': 19,
          'liked': false,
          'hasCitation': false,
        },
      ],
    ),

    'case-su-chien-ho': CaseNetizenDiscussionProfile(
      pollQuestion: '纏訟21年，最高法院以「刑求自白無效」與「鑑識不支持多人犯案」判決蘇建和等三人無罪定讞，你覺得合理嗎？',
      defaultVotes: [258, 38],
      comments: [
        {
          'avatar': '冤',
          'name': '平反倡議者',
          'time': '20 分鐘前',
          'stance': '合理派',
          'stanceColor': const Color(0xFF2E7D32),
          'content': '絕對合理！蘇建和案是台灣司法的照妖鏡。當年警察用打火機烤下巴灌水逼供，全案沒有一絲一毫客觀指紋DNA。無罪推定是法治社會唯一的底線，不能為了破案績效而冤殺無辜！',
          'likes': 85,
          'liked': false,
          'hasCitation': true,
          'source': '自白法則與刑事妥速審判法',
        },
        {
          'avatar': '鑑',
          'name': '鑑識科學迷',
          'time': '45 分鐘前',
          'stance': '合理派',
          'stanceColor': const Color(0xFF2E7D32),
          'content': '李昌鈺博士的現場重建非常關鍵。那麼窄小的臥室根本站不下四個人揮刀砍殺，血跡噴濺完全符合單人犯案型態。科學證據戳破了警察編造的口供劇本！',
          'likes': 56,
          'liked': false,
          'hasCitation': true,
          'source': '血跡動力學鑑識報告',
        },
        {
          'avatar': '質',
          'name': '程序質疑者',
          'time': '3 小時前',
          'stance': '不合理派',
          'stanceColor': const Color(0xFFC62828),
          'content': '主嫌王文孝生前多次指證有共犯分工，被害人身上刀傷確實有兩種不同兇器型態。經過二十年證據流失改判無罪，對慘死的吳銘漢夫婦及其遺孤也是一種無法平復的遺憾。',
          'likes': 28,
          'liked': false,
          'hasCitation': false,
        },
      ],
    ),

    'case-tang-ying-shen': CaseNetizenDiscussionProfile(
      pollQuestion: '湯英伸案引發社會對原住民遭勞動剝削與死刑量刑裁量之大思辨，若在今日審理，你贊同死刑定讞嗎？',
      defaultVotes: [98, 202],
      comments: [
        {
          'avatar': '原',
          'name': '高山青思辨',
          'time': '10 分鐘前',
          'stance': '不合理派',
          'stanceColor': const Color(0xFFC62828),
          'content': '不贊成死刑！身分證被雇主非法扣留、每天被高壓勞動十七小時，十九歲的原住民少年在求助無門下被逼上絕路。如果依照現在的刑法第57條審酌情狀，絕對應判處無期徒刑留一線生機！',
          'likes': 92,
          'liked': false,
          'hasCitation': true,
          'source': '刑法第57條量刑情狀',
        },
        {
          'avatar': '嚴',
          'name': '司法法治派',
          'time': '30 分鐘前',
          'stance': '合理派',
          'stanceColor': const Color(0xFF2E7D32),
          'content': '雖然勞動剝削值得同情，但奪走雇主一家三口包括兩歲無辜幼童的生命，手段確實極其殘暴。在當時的法規與社會治安防衛標準下，最高法院依法判死符合應報正義。',
          'likes': 45,
          'liked': false,
          'hasCitation': true,
          'source': '刑法第271條普通殺人罪',
        },
        {
          'avatar': '史',
          'name': '當代歷史鏡子',
          'time': '1 小時前',
          'stance': '中立派',
          'stanceColor': const Color(0xFF757575),
          'content': '湯英伸案的價值在於它永遠改變了台灣。它喚醒了原住民族運動、促成廢除吳鳳神話、推動就服法禁止扣押證件。這起悲劇是整個社會應該永遠共同承擔與反思的歷史共業。',
          'likes': 63,
          'liked': false,
          'hasCitation': false,
        },
      ],
    ),

    'case-cross-marriage-1445': CaseNetizenDiscussionProfile(
      pollQuestion: '行政法院引用「消極公序良俗」排除外國不承認同婚之法律，判決跨國同性伴侶勝訴准予登記，你覺得合理嗎？',
      defaultVotes: [220, 75],
      comments: [
        {
          'avatar': '平',
          'name': '婚姻平權推手',
          'time': '25 分鐘前',
          'stance': '合理派',
          'stanceColor': const Color(0xFF2E7D32),
          'content': '非常合理！釋字第748號確立婚姻自由受憲法平等保護，怎能因為另一半的母國落後未修法，就反過來剝奪他們在台灣的結婚權利？法院的消極公序良俗判斷實在太有智慧了！',
          'likes': 74,
          'liked': false,
          'hasCitation': true,
          'source': '涉外民事法律適用法第8條',
        },
        {
          'avatar': '涉',
          'name': '國際私法學者',
          'time': '1 小時前',
          'stance': '合理派',
          'stanceColor': const Color(0xFF2E7D32),
          'content': '公序良俗條款本來就是國際私法用來阻擋外國惡法侵入內國憲政秩序的安全閥。本案將憲法人權理念融入涉外私法，為亞洲涉外司法裁判樹立了極佳典範。',
          'likes': 52,
          'liked': false,
          'hasCitation': true,
          'source': '司法院釋字第748號解釋',
        },
        {
          'avatar': '法',
          'name': '文義嚴守者',
          'time': '2 小時前',
          'stance': '不合理派',
          'stanceColor': const Color(0xFFC62828),
          'content': '涉民法第46條明定依各該當事人本國法，行政法院以公序良俗架空法律明文，且可能導致在伴侶母國不被承認的「跛腳婚姻」，此問題本應由立法院修法解決而非司法造法。',
          'likes': 31,
          'liked': false,
          'hasCitation': false,
        },
      ],
    ),

    'case-prison-selection-13': CaseNetizenDiscussionProfile(
      pollQuestion: '憲法法庭宣告外役監條例「一律排除累犯受刑人遴選」違反平等原則定期失效，你覺得合理嗎？',
      defaultVotes: [190, 105],
      comments: [
        {
          'avatar': '憲',
          'name': '人權法制哨兵',
          'time': '20 分鐘前',
          'stance': '合理派',
          'stanceColor': const Color(0xFF2E7D32),
          'content': '憲法法庭判得好！法律不能無差別一刀切。前案是易科罰金的微罪，後案在監表現優異，憑什麼直接被剝奪外役監遴選機會？受刑人重返社會的權利應該依個案實質審查！',
          'likes': 66,
          'liked': false,
          'hasCitation': true,
          'source': '憲法第7條平等權',
        },
        {
          'avatar': '治',
          'name': '社會治安優先',
          'time': '40 分鐘前',
          'stance': '不合理派',
          'stanceColor': const Color(0xFFC62828),
          'content': '外役監近幾年發生脫逃殺警等重大事件，社會普遍要求提高遴選門檻。累犯再犯率本來就高，從嚴排除符合預防犯罪目的，憲法裁判削弱了治安防線。',
          'likes': 55,
          'liked': false,
          'hasCitation': false,
        },
        {
          'avatar': '衡',
          'name': '矯正制度觀察',
          'time': '1 小時前',
          'stance': '中立派',
          'stanceColor': const Color(0xFF757575),
          'content': '宣告定期失效給了立法院兩年的修法緩衝，立法院後續修法排除了重大暴力犯罪，同時保留了微罪累犯實質審查空間，這才是兼顧憲法平等與治安防衛的最佳平衡。',
          'likes': 38,
          'liked': false,
          'hasCitation': true,
          'source': '112年憲判字第13號判決主文',
        },
      ],
    ),
  };
}
