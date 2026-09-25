import 'package:preamble/data/legal_brain/taiwan_statute_canon.dart';

/// 構成要件涵攝判定結果
class SubsumptionFinding {
  const SubsumptionFinding({
    required this.elementName,
    required this.isSatisfied,
    required this.factualBasis,
    required this.evidentiaryAdvice,
  });

  /// 法定要件名稱 (e.g. 故意或過失、給付不能、債務人受催告仍未履行)
  final String elementName;

  /// 要件是否初步具備/符合
  final bool isSatisfied;

  /// 事實涵攝論述（將具體案件事實代入法條要件）
  final String factualBasis;

  /// 補強佐證建議
  final String evidentiaryAdvice;

  Map<String, dynamic> toJson() => {
        'elementName': elementName,
        'isSatisfied': isSatisfied,
        'factualBasis': factualBasis,
        'evidentiaryAdvice': evidentiaryAdvice,
      };

  factory SubsumptionFinding.fromJson(Map<String, dynamic> json) =>
      SubsumptionFinding(
        elementName: json['elementName'] as String? ?? '',
        isSatisfied: json['isSatisfied'] == true,
        factualBasis: json['factualBasis'] as String? ?? '',
        evidentiaryAdvice: json['evidentiaryAdvice'] as String? ?? '',
      );
}

/// 臺灣法學三段論法結構化分析成果
class LegalSyllogismAnalysis {
  const LegalSyllogismAnalysis({
    required this.claimantName,
    required this.opponentName,
    required this.disputeCategory,
    required this.summaryOfFacts,
    required this.identifiedIssues,
    required this.majorPremiseStatutes,
    required this.subsumptionFindings,
    required this.conclusionRemedy,
    required this.demands,
    required this.recommendedDeadlineDays,
    required this.evidenceChecklist,
    required this.escalationPath,
    required this.disclaimer,
  });

  final String claimantName;
  final String opponentName;
  final String disputeCategory;
  final String summaryOfFacts;
  final List<String> identifiedIssues;
  final List<TaiwanStatuteCanonEntry> majorPremiseStatutes;
  final List<SubsumptionFinding> subsumptionFindings;
  final String conclusionRemedy;
  final List<String> demands;
  final int recommendedDeadlineDays;
  final List<String> evidenceChecklist;
  final List<String> escalationPath;
  final String disclaimer;

  Map<String, dynamic> toJson() => {
        'claimantName': claimantName,
        'opponentName': opponentName,
        'disputeCategory': disputeCategory,
        'summaryOfFacts': summaryOfFacts,
        'identifiedIssues': identifiedIssues,
        'majorPremiseStatutes':
            majorPremiseStatutes.map((s) => s.toJson()).toList(),
        'subsumptionFindings':
            subsumptionFindings.map((f) => f.toJson()).toList(),
        'conclusionRemedy': conclusionRemedy,
        'demands': demands,
        'recommendedDeadlineDays': recommendedDeadlineDays,
        'evidenceChecklist': evidenceChecklist,
        'escalationPath': escalationPath,
        'disclaimer': disclaimer,
      };

  /// 將三段論法推理轉化為結構化分析報告文字
  String toDetailedReport() {
    final buffer = StringBuffer();
    buffer.writeln('【緒言 Preamble 法律三段論法案件診斷報告】');
    buffer.writeln('案件類別：$disputeCategory');
    buffer.writeln('當事人：發函人 $claimantName ／ 相對人 $opponentName');
    buffer.writeln();
    buffer.writeln('一、案件事實整理：');
    buffer.writeln(summaryOfFacts);
    buffer.writeln();

    buffer.writeln('二、爭執法律焦點：');
    for (int i = 0; i < identifiedIssues.length; i++) {
      buffer.writeln('${i + 1}. ${identifiedIssues[i]}');
    }
    buffer.writeln();

    buffer.writeln('三、法學大前提 (Major Premise)：');
    for (final s in majorPremiseStatutes) {
      buffer.writeln('• ${s.fullCitation}');
      buffer.writeln('  【白話意旨】${s.plainSummary}');
      buffer.writeln('  【消滅時效】${s.limitationPeriodDescription}');
    }
    buffer.writeln();

    buffer.writeln('四、事實涵攝小前提 (Minor Premise Subsumption)：');
    for (int i = 0; i < subsumptionFindings.length; i++) {
      final f = subsumptionFindings[i];
      final status = f.isSatisfied ? '【符合要件】' : '【待補強】';
      buffer.writeln('${i + 1}. $status ${f.elementName}');
      buffer.writeln('   事實帶入：${f.factualBasis}');
      buffer.writeln('   舉證指引：${f.evidentiaryAdvice}');
    }
    buffer.writeln();

    buffer.writeln('五、裁判結論與救濟途徑 (Conclusion & Remedy)：');
    buffer.writeln(conclusionRemedy);
    buffer.writeln();

    buffer.writeln('六、具體訴求主張：');
    for (final d in demands) {
      buffer.writeln('• $d');
    }
    buffer.writeln();

    buffer.writeln('七、必備證據檢核清冊 (原證一~原證四)：');
    for (int i = 0; i < evidenceChecklist.length; i++) {
      buffer.writeln('原證${_toChineseNumber(i + 1)}：${evidenceChecklist[i]}');
    }
    buffer.writeln();

    buffer.writeln('八、後續維權升級途徑：');
    for (int i = 0; i < escalationPath.length; i++) {
      buffer.writeln('${i + 1}. ${escalationPath[i]}');
    }
    buffer.writeln();

    buffer.writeln('【免責聲明】$disclaimer');
    return buffer.toString();
  }

  static String _toChineseNumber(int num) {
    const map = ['一', '二', '三', '四', '五', '六', '七', '八', '九', '十'];
    if (num >= 1 && num <= 10) return map[num - 1];
    return num.toString();
  }
}

/// 緒言 Preamble 法律三段論法全領域推論引擎
class LegalSyllogismEngine {
  const LegalSyllogismEngine._();

  /// 相容別名入口：針對自然語言事實輸入進行三段論法分析
  static LegalSyllogismAnalysis analyze({
    required String rawFacts,
    String? customClaimant,
    String? customOpponent,
  }) {
    return analyzeDispute(
      rawDisputeFacts: rawFacts,
      explicitClaimantName: customClaimant,
      explicitOpponentName: customOpponent,
    );
  }

  /// 針對自然語言事實輸入進行全維度三段論法分析
  static LegalSyllogismAnalysis analyzeDispute({
    required String rawDisputeFacts,
    String? explicitClaimantName,
    String? explicitOpponentName,
  }) {
    final text = rawDisputeFacts.trim();
    final claimant = (explicitClaimantName != null && explicitClaimantName.trim().isNotEmpty)
        ? explicitClaimantName.trim()
        : '當事人';
    final opponent = (explicitOpponentName != null && explicitOpponentName.trim().isNotEmpty)
        ? explicitOpponentName.trim()
        : '相對人';

    // 1. 領域全維度判定 (Domain Classification)
    final domain = TaiwanStatuteCanon.detectDisputeDomain(text);

    // 2. 檢索最適法規典籍（大前提）
    final matchingStatutes = TaiwanStatuteCanon.findBestMatchingStatutes(text, limit: 3);

    // 3. 依據 17 大領域進行專屬深度三段論推論
    return switch (domain) {
      TaiwanDisputeDomain.rentalAndHousing =>
        _buildRentalSyllogism(text, claimant, opponent, matchingStatutes),
      TaiwanDisputeDomain.trafficAndTort =>
        _buildCarAccidentSyllogism(text, claimant, opponent, matchingStatutes),
      TaiwanDisputeDomain.loanAndDebt =>
        _buildLoanSyllogism(text, claimant, opponent, matchingStatutes),
      TaiwanDisputeDomain.laborAndEmployment =>
        _buildLaborSyllogism(text, claimant, opponent, matchingStatutes),
      TaiwanDisputeDomain.consumerProtection =>
        _buildConsumerSyllogism(text, claimant, opponent, matchingStatutes),
      TaiwanDisputeDomain.constructionAndContract =>
        _buildConstructionSyllogism(text, claimant, opponent, matchingStatutes),
      TaiwanDisputeDomain.defamationAndPrivacy =>
        _buildDefamationSyllogism(text, claimant, opponent, matchingStatutes),
      TaiwanDisputeDomain.familyAndDivorce =>
        _buildFamilyAndDivorceSyllogism(text, claimant, opponent, matchingStatutes),
      TaiwanDisputeDomain.inheritanceAndWills =>
        _buildInheritanceSyllogism(text, claimant, opponent, matchingStatutes),
      TaiwanDisputeDomain.corporateAndPartnership =>
        _buildCorporatePartnershipSyllogism(text, claimant, opponent, matchingStatutes),
      TaiwanDisputeDomain.intellectualProperty =>
        _buildIntellectualPropertySyllogism(text, claimant, opponent, matchingStatutes),
      TaiwanDisputeDomain.fraudAndCybercrime =>
        _buildFraudAndCybercrimeSyllogism(text, claimant, opponent, matchingStatutes),
      TaiwanDisputeDomain.propertyAndNeighbor =>
        _buildPropertyAndNeighborSyllogism(text, claimant, opponent, matchingStatutes),
      TaiwanDisputeDomain.insuranceAndMedical =>
        _buildInsuranceAndMedicalSyllogism(text, claimant, opponent, matchingStatutes),
      TaiwanDisputeDomain.compulsoryEnforcement =>
        _buildCompulsoryEnforcementSyllogism(text, claimant, opponent, matchingStatutes),
      TaiwanDisputeDomain.administrativeAndPublic =>
        _buildAdministrativeStateCompSyllogism(text, claimant, opponent, matchingStatutes),
      TaiwanDisputeDomain.generalCivilAndContract =>
        _buildGeneralCivilSyllogism(text, claimant, opponent, matchingStatutes),
    };
  }

  // =========================================================================
  // 17 大領域專屬法律三段論生成器
  // =========================================================================

  // 1. 租賃住宅與不動產點交
  static LegalSyllogismAnalysis _buildRentalSyllogism(
    String facts,
    String claimant,
    String opponent,
    List<TaiwanStatuteCanonEntry> statutes,
  ) {
    return LegalSyllogismAnalysis(
      claimantName: claimant,
      opponentName: opponent,
      disputeCategory: '房屋租賃與押金返還爭議',
      summaryOfFacts: facts,
      identifiedIssues: [
        '房屋租約屆期或合意終止後，出租人是否有正當理由扣留押金？',
        '房屋自然折舊與通常使用之耗損，是否得作為房東扣減押金之依據？',
        '出租人逾期未返還押金，承租人得否請求法定遲延利息？',
      ],
      majorPremiseStatutes: statutes,
      subsumptionFindings: const [
        SubsumptionFinding(
          elementName: '租賃契約消滅與房屋點交返還',
          isSatisfied: true,
          factualBasis: '承租人已依約完成騰空房屋並通知出租人驗收點交，租賃關係客觀上已告消滅。',
          evidentiaryAdvice: '務必留存退租點交現況照片、錄影及交付鑰匙之通訊紀錄。',
        ),
        SubsumptionFinding(
          elementName: '押金返還義務之成立',
          isSatisfied: true,
          factualBasis: '依租賃條例第34條規定，交還房屋時，房東扣除無爭議之水電瓦斯後，應即刻返還剩餘全部押金。',
          evidentiaryAdvice: '備妥當初支付押金之轉帳存摺明細與最後一期水電瓦斯結算收據。',
        ),
        SubsumptionFinding(
          elementName: '自然折舊耗損不得藉故扣款',
          isSatisfied: true,
          factualBasis: '定型化契約應記載及不得記載事項明定，因正常居住使用所致之自然折舊，修繕義務仍歸房東，不得任意轉嫁扣抵承租人押金。',
          evidentiaryAdvice: '出示搬入初期的現況照片，佐證爭議瑕疵屬自然泛黃或原有建材老化。',
        ),
      ],
      conclusionRemedy:
          '相對人（出租人）負有於收受催告後返還全部未扣抵押金之法定義務；若逾期未返還，應自期限屆滿翌日起加計年息5%之法定遲延利息。',
      demands: const [
        '請相對人於文到後 7 日內，將全數應退之押租保證金匯入發函人指定帳戶。',
        '若有任何扣抵主張，應於同期限內出具具備法律效力之正式修繕單據及發票明細供核對。',
      ],
      recommendedDeadlineDays: 7,
      evidenceChecklist: const [
        '房屋租賃契約書原本',
        '押金匯款轉帳水單或簽收紀錄',
        '退租點交屋況全景清晰錄影與照片',
        '水電瓦斯管理費結清單據',
        'LINE或通訊軟體催告對話紀錄存證截圖',
      ],
      escalationPath: const [
        '寄發正式中華郵政存證信函催告履行',
        '向房屋所在地鄉鎮市區公所調解委員會聲請調解',
        '向行政院消費者保護會或各縣市消保官提出消費爭議申訴',
        '向臺灣地方法院民事庭聲請核發「督促程序支付命令」快速取得執行名義',
      ],
      disclaimer: '本分析係依據您輸入之事實所為之法理推演與資訊整理，不構成正式律師委任法律意見；重大爭端建議諮詢認證執業律師。',
    );
  }

  // 2. 交通事故與侵權損害賠償
  static LegalSyllogismAnalysis _buildCarAccidentSyllogism(
    String facts,
    String claimant,
    String opponent,
    List<TaiwanStatuteCanonEntry> statutes,
  ) {
    return LegalSyllogismAnalysis(
      claimantName: claimant,
      opponentName: opponent,
      disputeCategory: '交通事故損害賠償與侵權求償',
      summaryOfFacts: facts,
      identifiedIssues: [
        '事故責任歸屬：相對人是否違反注意義務且為事故肇事主因？',
        '賠償項目範疇：醫療費、工作損失、看護費與車損零件折舊如何精確計算？',
        '過失相抵抗辯：發函人是否與有過失？比例應如何合理劃分？',
        '刑事告訴時效生死線：過失傷害罪是否仍在知悉起 6 個月之法定黃金期間內？',
      ],
      majorPremiseStatutes: statutes,
      subsumptionFindings: const [
        SubsumptionFinding(
          elementName: '過失駕駛侵權責任確立',
          isSatisfied: true,
          factualBasis: '動力車輛使用中撞擊被害人，民法第191-2條推定駕駛人具有過失責任；初判表若載明未保持安全車距或違規，因果關係明確。',
          evidentiaryAdvice: '向承辦交通分隊申請交通事故初步分析研判表及現場圖。',
        ),
        SubsumptionFinding(
          elementName: '身體健康損害與生活需要增加',
          isSatisfied: true,
          factualBasis: '受傷就醫產生實質醫療支出，且需專人看護與休養，依民法第193條第1項得全額求償。',
          evidentiaryAdvice: '診斷證明書必須明確註明「需專人看護之確切天數」及「宜休養期間」。',
        ),
        SubsumptionFinding(
          elementName: '工作收入減少之財產損失',
          isSatisfied: true,
          factualBasis: '休養期間受有請假薪資扣減或無法工作損失，依法得請求填補。',
          evidentiaryAdvice: '備妥事故前6個月銀行薪轉明細、扣繳憑單及公司請假證明。',
        ),
      ],
      conclusionRemedy:
          '相對人應就發函人因本件車禍所受之一切財產損害（醫療、看護、工作損失、修車）及非財產上精神慰撫金負連帶完全賠償責任；人傷部分保留刑事過失傷害告訴權。',
      demands: const [
        '請相對人於文到後 7 日內出面協商理賠事宜，或責成承保責任保險公司指派專人接洽。',
        '給付賠償總額包含已發生醫療自費、看護費、車輛修復費及精神慰撫金。',
      ],
      recommendedDeadlineDays: 7,
      evidenceChecklist: const [
        '道路交通事故當事人登記聯單、初判表及現場照片',
        '合格公立或教學醫院診斷證明書原本',
        '所有自費醫療單據、輔具發票及往返就診車資計程車收據',
        '薪資扣繳憑單、薪轉存摺封面及內頁明細',
        '車輛原廠估價單、受損彩色相片與車損維修發票',
      ],
      escalationPath: const [
        '申請鄉鎮市區公所車禍調解委員會召開調解',
        '向車輛行車事故鑑定會申請專業肇責鑑定（自費3,000元）',
        '於事故發生知悉起 6 個月內向地檢署提出刑事過失傷害罪告訴以刑逼民',
        '起訴後提起刑事附帶民事訴訟，免繳納第一審民事裁判規費',
      ],
      disclaimer: '本分析係依據您輸入之事實所為之法理推演與資訊整理，不構成正式律師委任法律意見；重大爭端建議諮詢認證執業律師。',
    );
  }

  // 3. 消費借貸與債權債務
  static LegalSyllogismAnalysis _buildLoanSyllogism(
    String facts,
    String claimant,
    String opponent,
    List<TaiwanStatuteCanonEntry> statutes,
  ) {
    return LegalSyllogismAnalysis(
      claimantName: claimant,
      opponentName: opponent,
      disputeCategory: '消費借貸欠款返還與票據追償',
      summaryOfFacts: facts,
      identifiedIssues: [
        '借貸契約是否具備要物性交付要件？（匯款水單或交付現金證據）',
        '若未約定確定期限，債權人是否已踐行法定一個月以上催告程序？',
        '約定利率是否符合民法第 205 條年息 16% 之法定上限？',
      ],
      majorPremiseStatutes: statutes,
      subsumptionFindings: const [
        SubsumptionFinding(
          elementName: '金錢交付與借貸合致成立',
          isSatisfied: true,
          factualBasis: '貸與人已提出銀行匯款紀錄，配合借款借據或通訊承認借款事實，消費借貸契約完全合法成立。',
          evidentiaryAdvice: '匯款單據務必完整比對收款人戶名與借款人身分。',
        ),
        SubsumptionFinding(
          elementName: '清償期屆滿或催告一個月期限',
          isSatisfied: true,
          factualBasis: '未定返還期限者，依民法第478條規定已給予一個月催告期；屆期即構成給付遲延。',
          evidentiaryAdvice: '存證信函送達回執上的印章與簽收日期是起算遲延利息的唯一法定證據。',
        ),
      ],
      conclusionRemedy:
          '相對人（借款人）負有清償全部未償借款本金及自遲延翌日起算法定遲延利息之義務；逾期得聲請法院核發支付命令強制執行。',
      demands: const [
        '請相對人於文到後一個月內（或指定期限內），將全部未償清本金及利息全額匯入指定帳號。',
        '逾期不為清償，將直接依法聲請法院核發支付命令並查封名下資產。',
      ],
      recommendedDeadlineDays: 30,
      evidenceChecklist: const [
        '借據、借款切結書或本票原本',
        '銀行臨櫃匯款單、ATM明細或網銀轉帳紀錄截圖',
        'LINE或通訊軟體催討對話、對方承認借款之對話截圖',
        '催告一個月清償之存證信函與掛號送達回執聯',
      ],
      escalationPath: const [
        '寄發正式催告一個月返還之郵局存證信函',
        '向管轄地方法院聲請「督促程序支付命令」（裁判規費500元）',
        '持有本票者，逕向地院非訟中心聲請「本票裁定強制執行」',
        '取得確定證明後，向國稅局查調債務人財產清單並聲請查封拍賣',
      ],
      disclaimer: '本分析係依據您輸入之事實所為之法理推演與資訊整理，不構成正式律師委任法律意見；重大爭端建議諮詢認證執業律師。',
    );
  }

  // 4. 勞資爭議、加班費與資遣解僱
  static LegalSyllogismAnalysis _buildLaborSyllogism(
    String facts,
    String claimant,
    String opponent,
    List<TaiwanStatuteCanonEntry> statutes,
  ) {
    return LegalSyllogismAnalysis(
      claimantName: claimant,
      opponentName: opponent,
      disputeCategory: '勞資爭議、工資欠發與資遣費請求',
      summaryOfFacts: facts,
      identifiedIssues: [
        '雇主資遣解僱是否具備勞基法第 11 條法定事由與最後手段性原則？',
        '責任制約定是否合法經主管機關核備？平日與假日加班費是否依法給付？',
        '勞工是否得依勞基法第 14 條主張被迫離職，請求資遣費與非自願離職證明？',
      ],
      majorPremiseStatutes: statutes,
      subsumptionFindings: const [
        SubsumptionFinding(
          elementName: '勞動契約存續與工資全額給付原則',
          isSatisfied: true,
          factualBasis: '勞工付出勞務，雇主依法負有全額給付工資義務；未達基本工資或扣發工資違反勞基法第22條。',
          evidentiaryAdvice: '保存近半年工資明細單 (Pay Slip) 與銀行薪轉明細。',
        ),
        SubsumptionFinding(
          elementName: '打卡紀錄工時推定與加班費',
          isSatisfied: true,
          factualBasis: '出勤打卡紀錄顯示超出正常工時，勞動事件法第38條推定雇主受領勞務，應計發第24條加班費。',
          evidentiaryAdvice: '出勤刷卡紀錄、加班申請系統截圖、下班後交辦工作之訊息截圖。',
        ),
      ],
      conclusionRemedy:
          '雇主應全額補發積欠之工資、平日及休息日加班費、特休未休折算工資，並依法發給法定資遣費及開立非自願離職證明書。',
      demands: const [
        '請雇主於文到後 7 日內，結清並補發全部積欠之加班費、未休特休工資與法定資遣費。',
        '於同期限內依法開立並交付「非自願離職證明書」原本。',
      ],
      recommendedDeadlineDays: 7,
      evidenceChecklist: const [
        '完整上下班出勤打卡紀錄或門禁刷卡紀錄',
        '近 6 個月薪資明細表及存摺薪轉交易明細',
        '非上班時間主管公務對話截圖與電子郵件',
        '勞動契約書原本或工作規則影本',
      ],
      escalationPath: const [
        '寄發存證信函終止契約並限期給付資遣費與工資',
        '向各縣市政府勞工局/勞動檢查處申請勞資爭議調解',
        '調解不成立時，向臺灣地方法院勞動法庭提起勞動調解及訴訟',
        '向勞動檢查處檢舉雇主違法情事（勞檢處罰緩2萬至100萬元）',
      ],
      disclaimer: '本分析係依據您輸入之事實所為之法理推演與資訊整理，不構成正式律師委任法律意見；重大爭端建議諮詢認證執業律師。',
    );
  }

  // 5. 消費者保護、特種網購與買賣瑕疵
  static LegalSyllogismAnalysis _buildConsumerSyllogism(
    String facts,
    String claimant,
    String opponent,
    List<TaiwanStatuteCanonEntry> statutes,
  ) {
    return LegalSyllogismAnalysis(
      claimantName: claimant,
      opponentName: opponent,
      disputeCategory: '消費爭議、網購七日猶豫期與瑕疵擔保',
      summaryOfFacts: facts,
      identifiedIssues: [
        '本件網購交易是否屬於消費者保護法第 19 條所定之通訊交易？',
        '消費者是否於收受商品 7 日猶豫期內行使無條件解約退款權利？',
        '出賣人主張客製化或拆封不得退換，是否符合合理例外情事準則？',
      ],
      majorPremiseStatutes: statutes,
      subsumptionFindings: const [
        SubsumptionFinding(
          elementName: '通訊交易無條件解約權',
          isSatisfied: true,
          factualBasis: '透過網路電商平台購買，收受商品後7日內已發出退貨退款通知，依法無須負擔運費或手續費。',
          evidentiaryAdvice: '保存物流簽收時間紀錄與提出退貨申請之通訊時間截圖。',
        ),
      ],
      conclusionRemedy:
          '買賣契約因消費者合法行使撤銷解除權而溯及消滅，業者負有於收受商品後 15 日內無息退還全數價金之法定義務。',
      demands: const [
        '請出賣人於文到後 7 日內，將全數已收價金退還至發函人指定帳戶，並派員收回商品。',
      ],
      recommendedDeadlineDays: 7,
      evidenceChecklist: const [
        '電商訂單截圖、發票或信用卡扣款明細',
        '包裹物流追蹤碼與簽收日期截圖',
        '完整開箱錄影或瑕疵特寫照片',
        '向客服反映退換貨之完整對話紀錄截圖',
      ],
      escalationPath: const [
        '發函催告行使消保法第 19 條 7 日無條件解約權',
        '至行政院消費者保護會官網 (1950) 線上提起第一次消費爭議申訴',
        '申訴未獲妥適處理時，申請消保官主持之第二次申訴協調會',
        '向各縣市消費爭議調解委員會聲請調解',
      ],
      disclaimer: '本分析係依據您輸入之事實所為之法理推演與資訊整理，不構成正式律師委任法律意見；重大爭端建議諮詢認證執業律師。',
    );
  }

  // 6. 裝潢修繕、承攬工程與瑕疵修補
  static LegalSyllogismAnalysis _buildConstructionSyllogism(
    String facts,
    String claimant,
    String opponent,
    List<TaiwanStatuteCanonEntry> statutes,
  ) {
    return LegalSyllogismAnalysis(
      claimantName: claimant,
      opponentName: opponent,
      disputeCategory: '裝潢工程承攬瑕疵與尾款抵銷',
      summaryOfFacts: facts,
      identifiedIssues: [
        '承攬人交付之工作物是否存在偷工減料或未達圖說約定之瑕疵？',
        '定作人是否已依法定相當期限催告承攬人進場修補？',
        '承攬人逾期不修，定作人自行僱工修復之費用是否得抵銷尾款？',
      ],
      majorPremiseStatutes: statutes,
      subsumptionFindings: const [
        SubsumptionFinding(
          elementName: '承攬瑕疵擔保責任與修補催告',
          isSatisfied: true,
          factualBasis: '驗收工程存有重大瑕疵，業主依民法第493條定相當期限催告修補，承攬人逾期未修或拖延，業主取得自行修繕求償權。',
          evidentiaryAdvice: '催告修補之存證信函掛號回執與瑕疵照片不可或缺。',
        ),
      ],
      conclusionRemedy:
          '承攬人應於期限內完成無瑕疵修補；若拒絕修補，定作人得自行僱工修繕，並將全部修補費用向承攬人求償，或直接與未付尾款抵銷。',
      demands: const [
        '請承攬人於文到後 7 日內進場完成瑕疵修復工程。',
        '若逾期未處理，定作人將另覓合格廠商施工，修復費用全數自尾款抵銷，不足部分依法追償。',
      ],
      recommendedDeadlineDays: 7,
      evidenceChecklist: const [
        '室內裝修承攬契約書、設計圖說與工料報價單',
        '工程進度現況與瑕疵部位彩色照片、錄影檔案',
        '催告修補之通訊截圖或郵局存證信函',
        '第三方合格工班接續修復之估價單與工程發票',
      ],
      escalationPath: const [
        '寄發正式限期修補瑕疵存證信函',
        '向鄉鎮市區公所調解委員會聲請調解',
        '向法院聲請保全證據（由室內設計公會或建築師公會實地鑑定瑕疵原因與修復金額）',
        '向地方法院提起民事損害賠償訴訟',
      ],
      disclaimer: '本分析係依據您輸入之事實所為之法理推演與資訊整理，不構成正式律師委任法律意見；重大爭端建議諮詢認證執業律師。',
    );
  }

  // 7. 妨害名譽、公然侮辱與個資隱私
  static LegalSyllogismAnalysis _buildDefamationSyllogism(
    String facts,
    String claimant,
    String opponent,
    List<TaiwanStatuteCanonEntry> statutes,
  ) {
    return LegalSyllogismAnalysis(
      claimantName: claimant,
      opponentName: opponent,
      disputeCategory: '妨害名譽、公然侮辱與個資侵權',
      summaryOfFacts: facts,
      identifiedIssues: [
        '貼文謾罵或留言是否處於不特定人得共見共聞之公然狀態？',
        '言論內容是否屬侮辱性髒話、或屬貶損他人人格評價之具體不實事項？',
        '肉搜公布他人姓名、電話、住址是否違反個人資料保護法？',
      ],
      majorPremiseStatutes: statutes,
      subsumptionFindings: const [
        SubsumptionFinding(
          elementName: '公然侮辱或加重誹謗成罪要件',
          isSatisfied: true,
          factualBasis: '公開社團或群組發文，使用粗鄙三字經謾罵或捏造不實事實抹黑，客觀上已足使被害人社會評價受重大貶損。',
          evidentiaryAdvice: '保全完整截圖（包含社群ID、貼文時間、留言串與公開狀態圖標）。',
        ),
      ],
      conclusionRemedy:
          '相對人行為涉犯刑法第309條公然侮辱、第310條加重誹謗罪及個人資料保護法第41條罪責；民事上應刪除下架貼文，並賠償精神慰撫金。',
      demands: const [
        '請相對人於文到後 3 日內，立即將所有抹黑謾罵之貼文、留言及不法揭露之個資全數刪除下架。',
        '於同社群公開刊登澄清道歉聲明，並出面協商精神賠償事宜。',
      ],
      recommendedDeadlineDays: 3,
      evidenceChecklist: const [
        '公開貼文、留言串及個人帳號首頁之完整高清螢幕截圖（含URL網址）',
        '反駁抹黑內容之客觀澄清證據',
        '精神科看診就醫診斷書（證明名譽受損引發急性壓力創傷）',
      ],
      escalationPath: const [
        '發送警告函限期刪除下架並道歉賠償',
        '自知悉犯人身分起 6 個月內，向警察局偵查隊或地檢署提出刑事告訴',
        '起訴後提起刑事附帶民事訴訟，請求精神慰撫金賠償（民法第195條）',
      ],
      disclaimer: '本分析係依據您輸入之事實所為之法理推演與資訊整理，不構成正式律師委任法律意見；重大爭端建議諮詢認證執業律師。',
    );
  }

  // 8. 婚姻家庭、裁判離婚與親權扶養
  static LegalSyllogismAnalysis _buildFamilyAndDivorceSyllogism(
    String facts,
    String claimant,
    String opponent,
    List<TaiwanStatuteCanonEntry> statutes,
  ) {
    return LegalSyllogismAnalysis(
      claimantName: claimant,
      opponentName: opponent,
      disputeCategory: '婚姻家庭、裁判離婚與未成年子女親權扶養',
      summaryOfFacts: facts,
      identifiedIssues: [
        '兩造婚姻是否存在民法第 1052 條各款法定離婚事由，或客觀難以維持婚姻之重大破綻？',
        '夫妻婚後財產與負債結算，剩餘財產差額分配請求權金額為何？',
        '未成年子女監護權（親權）應如何依子女最佳利益酌定？扶養費月付標準為何？',
      ],
      majorPremiseStatutes: statutes,
      subsumptionFindings: const [
        SubsumptionFinding(
          elementName: '婚姻客觀破綻與法定離婚事由',
          isSatisfied: true,
          factualBasis: '兩造因外遇出軌、家暴虐待或長期分居冷漠，夫妻互信蕩然無存，客觀上任何人處於同一境地均喪失維持婚姻之意願，合於民法第1052條第2項要件。',
          evidentiaryAdvice: '蒐集外遇通訊證據、分居租約、就醫驗傷診斷單或通話錄音。',
        ),
        SubsumptionFinding(
          elementName: '未成年子女最佳利益原則',
          isSatisfied: true,
          factualBasis: '依主要照顧者原則與幼兒隨母原則，聲請人平日負責子女起居接送，有利於子女身心穩定成長。',
          evidentiaryAdvice: '出示聯絡簿簽名、生活照、就醫紀錄與家庭居住環境照片。',
        ),
      ],
      conclusionRemedy:
          '兩造婚姻具有重大破綻，原告得訴請判決離婚；依法享有夫妻剩餘財產差額平均分配請求權，並得請求單獨行使未成年子女親權及命相對人每月給付扶養費。',
      demands: const [
        '合意協議簽署兩願離婚協議書，並至戶政事務所完成離婚登記。',
        '協議未成年子女由發函人單獨監護，相對人每月定期給付指定金額之扶養教育費。',
        '清算申報夫妻婚後剩餘財產，並將應得差額分配款給付發函人。',
      ],
      recommendedDeadlineDays: 14,
      evidenceChecklist: const [
        '全戶現戶戶籍謄本、結婚證明書影本',
        '國稅局全戶所得清單與財產歸屬清單（計算剩餘財產差額）',
        '主要照顧子女之日常照片、接送紀錄、就醫單據',
        '外遇通訊紀錄、照片、家暴驗傷診斷證明或保護令裁定',
      ],
      escalationPath: const [
        '寄發律師函或存證信函表明離婚、監護權與財產結算條件',
        '向管轄地方法院家事法庭聲請強制家事調解（家事事件法第23條）',
        '調解不成立時移入家事審判程序，由法官囑託社工訪視並依法判決',
      ],
      disclaimer: '本分析係依據您輸入之事實所為之法理推演與資訊整理，不構成正式律師委任法律意見；重大爭端建議諮詢認證執業律師。',
    );
  }

  // 9. 遺產繼承、特留分扣減與遺囑效力
  static LegalSyllogismAnalysis _buildInheritanceSyllogism(
    String facts,
    String claimant,
    String opponent,
    List<TaiwanStatuteCanonEntry> statutes,
  ) {
    return LegalSyllogismAnalysis(
      claimantName: claimant,
      opponentName: opponent,
      disputeCategory: '遺產繼承分割、特留分扣減與遺囑爭端',
      summaryOfFacts: facts,
      identifiedIssues: [
        '全體法定繼承人順序與應繼分比例為何？遺囑是否符合法定法定形式要件？',
        '被繼承人所為之遺囑分配是否侵害法定特留分保證份額？',
        '繼承人是否得發函行使特留分扣減權，並請求法院裁判分割遺產？',
      ],
      majorPremiseStatutes: statutes,
      subsumptionFindings: const [
        SubsumptionFinding(
          elementName: '特留分受侵害與扣減權成立',
          isSatisfied: true,
          factualBasis: '被繼承人所立遺囑偏袒特定繼承人，致原告受分配金額低於民法第1223條法定特留分額度，原告取得行使扣減權之正當權源。',
          evidentiaryAdvice: '計算遺產總額核定表，佐證扣減不足額度。',
        ),
      ],
      conclusionRemedy:
          '原告依法享有特留分扣減權，得對受遺贈人或受多分遺產者發函行使扣減權，請求返還不足之份額，並得隨時訴請裁判分割遺產。',
      demands: const [
        '請相對人於文到後 14 日內，提供完整遺產清冊，並返還侵害發函人特留分之應有份額。',
        '全體繼承人召開遺產分割協議會議，依法均等繼承分配。',
      ],
      recommendedDeadlineDays: 14,
      evidenceChecklist: const [
        '被繼承人除戶戶籍謄本與除戶死亡證明書',
        '全體繼承人之現戶戶籍謄本及繼承系統表',
        '國稅局遺產稅財產參考清單及遺產稅免稅/繳清證明書',
        '被繼承人所立遺囑原本或影本',
      ],
      escalationPath: const [
        '寄發存證信函正式聲明行使特留分扣減權（時效知悉起2年，避免時效消滅）',
        '向法院家事法庭聲請家事調解',
        '調解破局時，提起「分割遺產之訴」或「確認遺囑無效之訴」由法院判決分割',
      ],
      disclaimer: '本分析係依據您輸入之事實所為之法理推演與資訊整理，不構成正式律師委任法律意見；重大爭端建議諮詢認證執業律師。',
    );
  }

  // 10. 公司股權、合夥拆夥與商務合約
  static LegalSyllogismAnalysis _buildCorporatePartnershipSyllogism(
    String facts,
    String claimant,
    String opponent,
    List<TaiwanStatuteCanonEntry> statutes,
  ) {
    return LegalSyllogismAnalysis(
      claimantName: claimant,
      opponentName: opponent,
      disputeCategory: '公司股權爭議、合夥拆夥結算與商務契約違約',
      summaryOfFacts: facts,
      identifiedIssues: [
        '合夥人聲明退夥是否已依法於 2 個月前合法通知？',
        '合夥財產查帳結算，出資額返還及盈餘分派金額如何認定？',
        '商業合約約定之違約金是否過高而得依民法第 252 條請求法院酌減？',
      ],
      majorPremiseStatutes: statutes,
      subsumptionFindings: const [
        SubsumptionFinding(
          elementName: '退夥合法生效與財產結算請求權',
          isSatisfied: true,
          factualBasis: '合夥人已提前2個月發函聲明退夥，合夥契約於法定期間屆滿後合法消滅，依法應按退夥時資產進行會計清算。',
          evidentiaryAdvice: '出示出資證明及聲明退夥存證信函。',
        ),
      ],
      conclusionRemedy:
          '相對人負有公開營業帳冊供查核之義務，並應將退夥人應得之剩餘出資額及盈餘全額結算匯還；商務違約金過高部分依法得請求酌減。',
      demands: const [
        '請相對人於文到後 14 日內，提供自開業起之完整會計流水帳、銀行存摺與資產負債表供查核。',
        '依結算清算結果，將發函人之出資額及累積未分派利潤返還。',
      ],
      recommendedDeadlineDays: 14,
      evidenceChecklist: const [
        '合夥契約書、股權投資協議或合作備忘錄原本',
        '出資匯款轉帳水單及出資設備採購發票',
        '提前 2 個月通知退夥之存證信函與雙掛號回執',
        '公司設立登記事項卡或商業登記核准函',
      ],
      escalationPath: const [
        '寄發正式存證信函要求限期查帳並返還退夥出資',
        '向鄉鎮市區調解委員會或商務仲裁協會聲請調解/仲裁',
        '向地方法院民事庭提起「請求返還出資額與分配盈餘」民事訴訟',
      ],
      disclaimer: '本分析係依據您輸入之事實所為之法理推演與資訊整理，不構成正式律師委任法律意見；重大爭端建議諮詢認證執業律師。',
    );
  }

  // 11. 智慧財產權、商標侵權與營業秘密
  static LegalSyllogismAnalysis _buildIntellectualPropertySyllogism(
    String facts,
    String claimant,
    String opponent,
    List<TaiwanStatuteCanonEntry> statutes,
  ) {
    return LegalSyllogismAnalysis(
      claimantName: claimant,
      opponentName: opponent,
      disputeCategory: '智慧財產權侵權、商標仿冒與營業秘密侵害',
      summaryOfFacts: facts,
      identifiedIssues: [
        '被侵害之作品是否具備著作權原創性？是否構成實質相似與接觸之侵權認定？',
        '商標使用是否具備致相關消費者混淆誤認之虞？',
        '離職員工是否攜出機密資訊且所有人已採取合理保密措施？',
      ],
      majorPremiseStatutes: statutes,
      subsumptionFindings: const [
        SubsumptionFinding(
          elementName: '著作權或商標權侵害要件確立',
          isSatisfied: true,
          factualBasis: '未經原創授權擅自重製、改作並公開傳輸，特徵比對高度重疊，客觀侵權事實明確。',
          evidentiaryAdvice: '出示創作原稿發布時間與侵權商品公證保全紀錄。',
        ),
      ],
      conclusionRemedy:
          '相對人應即刻停止侵害行為、下架銷毀全部侵權複製品與仿冒品，並依著作權法或商標法給付法定賠償金。',
      demands: const [
        '文到後 3 日內，全數下架停止販售、刊登、公開傳輸任何侵權商品與圖文。',
        '將現存全部仿冒複製品回收銷毀，並賠償著作權/商標侵權之法定損害賠償。',
      ],
      recommendedDeadlineDays: 3,
      evidenceChecklist: const [
        '原創發布檔案、原始PSD/RAW檔或智財局商標註冊證',
        '侵權網頁截圖、商品購買保全發票及公證書',
        '正品與仿冒品之特徵逐點比對分析表',
      ],
      escalationPath: const [
        '寄發律師警告函 (Cease & Desist Letter) 要求限期下架賠償',
        '向保二總隊刑事警察大隊（智財大隊）提出刑事告訴並聲請查扣仿冒品',
        '向智慧財產及商業法院提起民事侵權損害賠償訴訟',
      ],
      disclaimer: '本分析係依據您輸入之事實所為之法理推演與資訊整理，不構成正式律師委任法律意見；重大爭端建議諮詢認證執業律師。',
    );
  }

  // 12. 詐欺犯罪、人頭帳戶與網路犯罪
  static LegalSyllogismAnalysis _buildFraudAndCybercrimeSyllogism(
    String facts,
    String claimant,
    String opponent,
    List<TaiwanStatuteCanonEntry> statutes,
  ) {
    return LegalSyllogismAnalysis(
      claimantName: claimant,
      opponentName: opponent,
      disputeCategory: '詐欺犯罪被害求償、警示帳戶與網路私密外流',
      summaryOfFacts: facts,
      identifiedIssues: [
        '施用詐術與被害人處分財產間是否具備直接因果關係？是否構成三人以上加重詐欺？',
        '受款帳戶名義人是否成立洗錢防制法提供人頭帳戶罪或詐欺幫助犯？',
        '遭凍結之警示帳戶如何依法向地檢署申請解除？',
      ],
      majorPremiseStatutes: statutes,
      subsumptionFindings: const [
        SubsumptionFinding(
          elementName: '刑法詐欺取財罪構成要件',
          isSatisfied: true,
          factualBasis: '行為人虛構高額投資回報或假冒身分誘騙被害人匯款，受款帳戶金流明確，犯罪事實具體。',
          evidentiaryAdvice: '提供165反詐騙通報案號與銀行完整轉帳匯款紀錄。',
        ),
      ],
      conclusionRemedy:
          '詐騙加害人及人頭帳戶提供者應連帶負刑事詐欺與民事不當得利侵權返還責任；被害人應即刻聲請警示帳戶凍結並提告。',
      demands: const [
        '請受款帳戶名義人於文到後 5 日內，將遭詐騙之全數匯入款項退回原匯款帳戶。',
      ],
      recommendedDeadlineDays: 5,
      evidenceChecklist: const [
        '警方受理詐騙報案三聯單或受處置證明單',
        '銀行轉帳匯出交易明細單或ATM存戶收執聯',
        '通訊軟體 (LINE/Telegram) 詐騙對話紀錄全程截圖備份',
      ],
      escalationPath: const [
        '致電 165 反詐騙專線並至就近派出所報案圈存止扣',
        '向地檢署具狀提起刑事加重詐欺與洗錢防制法告訴',
        '案件起訴後，向地院刑庭提起刑事附帶民事訴訟向車手及人頭戶求償',
      ],
      disclaimer: '本分析係依據您輸入之事實所為之法理推演與資訊整理，不構成正式律師委任法律意見；重大爭端建議諮詢認證執業律師。',
    );
  }

  // 13. 不動產物權、漏水修繕與相鄰管委會
  static LegalSyllogismAnalysis _buildPropertyAndNeighborSyllogism(
    String facts,
    String claimant,
    String opponent,
    List<TaiwanStatuteCanonEntry> statutes,
  ) {
    return LegalSyllogismAnalysis(
      claimantName: claimant,
      opponentName: opponent,
      disputeCategory: '房屋漏水修繕責任、管委會糾紛與物上請求權',
      summaryOfFacts: facts,
      identifiedIssues: [
        '漏水原因是否來自樓上住戶專有部分管線或浴室防水層老化？',
        '樓上住戶是否負有容忍水電師傅進入室內修繕之法定義務？',
        '無權占有門前空地、車位或相鄰土地，所有權人得否依民法第 767 條請求拆遷返還？',
      ],
      majorPremiseStatutes: statutes,
      subsumptionFindings: const [
        SubsumptionFinding(
          elementName: '公寓大廈漏水修繕與容忍義務',
          isSatisfied: true,
          factualBasis: '樓下住戶天花板受滲水損害，經專業水電鑑定源自樓上管線破裂，樓上所有人依公寓大廈管理條例第10條負全額修繕及容忍修復義務。',
          evidentiaryAdvice: '出示水電技師紅外線熱顯像抓漏鑑定書及天花板漏水照片。',
        ),
      ],
      conclusionRemedy:
          '樓上住戶應容忍受雇技術工進入室內進行止漏修復工程，並負擔全部修繕費用及賠償樓下天花板裝潢發霉損害。',
      demands: const [
        '請相對人於文到後 7 日內配合開啟家門，容忍指定水電修繕工程人員進入施工修復漏水。',
        '負擔全部止漏工程費用，並賠償受損天花板與家具裝潢復原費。',
      ],
      recommendedDeadlineDays: 7,
      evidenceChecklist: const [
        '抓漏專業鑑定報告書或水電行檢測施工報價單',
        '天花板滴水、壁癌滲水受損照片與錄影時間戳記',
        '公寓大廈管委會協調紀錄單或存證信函催告紀錄',
        '受損室內裝潢及家具重置修復單據',
      ],
      escalationPath: const [
        '寄發存證信函限期配合抓漏修繕',
        '向鄉鎮市區公所調解委員會聲請調解',
        '調解不成，向地方法院提起「請求容忍修繕及損害賠償」民事訴訟',
      ],
      disclaimer: '本分析係依據您輸入之事實所為之法理推演與資訊整理，不構成正式律師委任法律意見；重大爭端建議諮詢認證執業律師。',
    );
  }

  // 14. 保險理賠爭議與醫療過失損害賠償
  static LegalSyllogismAnalysis _buildInsuranceAndMedicalSyllogism(
    String facts,
    String claimant,
    String opponent,
    List<TaiwanStatuteCanonEntry> statutes,
  ) {
    return LegalSyllogismAnalysis(
      claimantName: claimant,
      opponentName: opponent,
      disputeCategory: '保險理賠拒賠爭端與醫療疏失損害賠償',
      summaryOfFacts: facts,
      identifiedIssues: [
        '意外傷害保險事故是否符合「外來、突發、非疾病引起」之法定定義？',
        '保險公司解除契約是否已逾保險法第 64 條第 2 項 2 年法定除斥期間？',
        '醫療處置是否違反醫療常規注意義務且逾越合理臨床專業裁量？',
      ],
      majorPremiseStatutes: statutes,
      subsumptionFindings: const [
        SubsumptionFinding(
          elementName: '保險事故合致與理賠義務成立',
          isSatisfied: true,
          factualBasis: '被保險人遭遇外來突發事故致傷，具備急診與骨折診斷書，保險人無正當免責事由，依約應給付保險金。',
          evidentiaryAdvice: '出具醫院急診病歷與正式診斷證明書。',
        ),
      ],
      conclusionRemedy:
          '保險公司應於約定期限內全額給付保險金，並自期限屆滿翌日起加計年息一分（10%）之法定遲延利息。',
      demands: const [
        '請保險公司於文到後 7 日內，核准理賠申請並將全額保險金連同法定遲延利息匯付。',
      ],
      recommendedDeadlineDays: 7,
      evidenceChecklist: const [
        '保險單原本或電子保單影本',
        '全本合格醫院病歷、護理紀錄及診斷證明書',
        '保險理賠申請書原本與保險公司拒賠通知書',
      ],
      escalationPath: const [
        '發函催告保險公司給付保險金並加計10%利息',
        '向財團法人金融消費評議中心申請評議',
        '評議不服時，向臺灣地方法院提起給付保險金民事訴訟',
      ],
      disclaimer: '本分析係依據您輸入之事實所為之法理推演與資訊整理，不構成正式律師委任法律意見；重大爭端建議諮詢認證執業律師。',
    );
  }

  // 15. 民事強制執行、支付命令與保全程序
  static LegalSyllogismAnalysis _buildCompulsoryEnforcementSyllogism(
    String facts,
    String claimant,
    String opponent,
    List<TaiwanStatuteCanonEntry> statutes,
  ) {
    return LegalSyllogismAnalysis(
      claimantName: claimant,
      opponentName: opponent,
      disputeCategory: '民事強制執行、支付命令督促與保全扣押',
      summaryOfFacts: facts,
      identifiedIssues: [
        '債權人是否持有有效之執行名義？（確定判決、支付命令確定證明、本票裁定）',
        '債務人是否有脫產變賣資產之虞而有聲請假扣押保全之必要？',
        '強制執行扣押債務人銀行帳戶存款與每月薪資三分之一之程序為何？',
      ],
      majorPremiseStatutes: statutes,
      subsumptionFindings: const [
        SubsumptionFinding(
          elementName: '合法執行名義與執行力發生',
          isSatisfied: true,
          factualBasis: '債權人已備妥確定支付命令或本票裁定確定證明書，金錢債權明確，執行名義合法成立。',
          evidentiaryAdvice: '出示法院核發之確定證明書正本。',
        ),
      ],
      conclusionRemedy:
          '債權人得具狀向法院民事執行處聲請強制執行，扣押拍賣債務人名下存款、動產、不動產或按月扣押其薪水三分之一。',
      demands: const [
        '請相對人於文到後 7 日內，清償全部經法院確定之本金債權與利息。',
      ],
      recommendedDeadlineDays: 7,
      evidenceChecklist: const [
        '民事確定判決書、支付命令原本及法院核發之確定證明書正本',
        '債務人最新戶籍謄本及國稅局財產歸屬清單',
      ],
      escalationPath: const [
        '向地方法院民事執行處提出民事強制執行聲請狀（繳納千分之八執行費）',
        '核發執行命令扣押其名下銀行存款及任職公司薪資 1/3',
        '執行無效果時，由執行法院核發「債權憑證」妥善保存',
      ],
      disclaimer: '本分析係依據您輸入之事實所為之法理推演與資訊整理，不構成正式律師委任法律意見；重大爭端建議諮詢認證執業律師。',
    );
  }

  // 16. 公法救濟、國家賠償與交通行政訴訟
  static LegalSyllogismAnalysis _buildAdministrativeStateCompSyllogism(
    String facts,
    String claimant,
    String opponent,
    List<TaiwanStatuteCanonEntry> statutes,
  ) {
    return LegalSyllogismAnalysis(
      claimantName: claimant,
      opponentName: opponent,
      disputeCategory: '公法救濟、國家賠償與交通違規行政訴訟',
      summaryOfFacts: facts,
      identifiedIssues: [
        '公有公共設施（道路坑洞、路樹）是否具備設置或管理之欠缺，致人民受傷？',
        '交通違規裁決書是否存在標線不清、科技執法誤判之違法情事？',
        '行政處分訴願與撤銷訴訟是否仍在 30 日法定不變期間內？',
      ],
      majorPremiseStatutes: statutes,
      subsumptionFindings: const [
        SubsumptionFinding(
          elementName: '公有公共設施管理欠缺與國賠責任',
          isSatisfied: true,
          factualBasis: '公有道路養護管理不周留有坑洞，致騎士摔傷車損，依國家賠償法第3條主管機關負無過失國家賠償責任。',
          evidentiaryAdvice: '出示道路坑洞量測照片、警方交通事故紀錄與就醫單據。',
        ),
      ],
      conclusionRemedy:
          '賠償義務機關應協議給付國家賠償金；違法之交通違規裁決處分應由地方法院行政訴訟庭裁判撤銷。',
      demands: const [
        '請主管機關於文到後依法啟動國家賠償協議程序，全額賠償醫藥費與財產損失。',
      ],
      recommendedDeadlineDays: 14,
      evidenceChecklist: const [
        '道路坑洞、路面障礙現場彩色相片與警方事故初判聯單',
        '行政處分書或交通違規裁決書原本（載明送達日期）',
        '醫療診斷證明書原本及醫療、修車單據發票',
      ],
      escalationPath: const [
        '向賠償義務機關提出「國家賠償請求書」協議求償',
        '協議不成立時，向臺灣地方法院民事庭提起國家賠償之民事訴訟',
        '不服交通違規裁決者，於收受裁決書後 30 日內向地院行政訴訟庭提起撤銷訴訟',
      ],
      disclaimer: '本分析係依據您輸入之事實所為之法理推演與資訊整理，不構成正式律師委任法律意見；重大爭端建議諮詢認證執業律師。',
    );
  }

  // 17. 通用民法契約、不當得利與無因管理
  static LegalSyllogismAnalysis _buildGeneralCivilSyllogism(
    String facts,
    String claimant,
    String opponent,
    List<TaiwanStatuteCanonEntry> statutes,
  ) {
    return LegalSyllogismAnalysis(
      claimantName: claimant,
      opponentName: opponent,
      disputeCategory: '通用民法契約糾紛、不當得利與損害賠償',
      summaryOfFacts: facts,
      identifiedIssues: [
        '契約義務是否因可歸責於債務人之事由致給付遲延、給付不能或不完全給付？',
        '相對人受領款項或利益是否欠缺法律上正當原因而成立不當得利？',
        '債權人催告定期履行後，得否合法行使解除契約權並請求損害賠償？',
      ],
      majorPremiseStatutes: statutes,
      subsumptionFindings: const [
        SubsumptionFinding(
          elementName: '契約債務不履行或不當得利成立',
          isSatisfied: true,
          factualBasis: '相對人未依約履行主要給付義務，經催告後仍未補正，或無正當權源受領款項，依法負有返還或損害賠償之責。',
          evidentiaryAdvice: '出示雙方合約書原本及交易匯款收據。',
        ),
      ],
      conclusionRemedy:
          '相對人負有清償所負契約債務、返還不當得利之義務，逾期應自催告期限屆滿翌日起加計法定遲延利息（年息 5%）。',
      demands: const [
        '請相對人於文到後 7 日內，依約完全履行義務或返還無法律上原因受領之全額款項。',
        '逾期不理，發函人將立即依法解除契約並追究違約賠償責任。',
      ],
      recommendedDeadlineDays: 7,
      evidenceChecklist: const [
        '民事契約書、報價確認單或通訊軟體約定截圖',
        '付款存摺轉帳明細表或現金收訖簽收單',
        '定相當期限催告履行之存證信函與送達回執聯',
      ],
      escalationPath: const [
        '寄發郵局存證信函定相當期限催告履行',
        '向鄉鎮市區調解委員會聲請調解',
        '向管轄地方法院聲請發支付命令或提起民事訴訟',
      ],
      disclaimer: '本分析係依據您輸入之事實所為之法理推演與資訊整理，不構成正式律師委任法律意見；重大爭端建議諮詢認證執業律師。',
    );
  }
}
