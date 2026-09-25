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

    buffer.writeln('二、關鍵爭點歸納：');
    for (var i = 0; i < identifiedIssues.length; i++) {
      buffer.writeln('${i + 1}. ${identifiedIssues[i]}');
    }
    buffer.writeln();

    buffer.writeln('三、大前提（法律規範與請求權基礎）：');
    for (final s in majorPremiseStatutes) {
      buffer.writeln('• ${s.fullCitation}：${s.plainSummary}');
      buffer.writeln('  消滅時效：${s.limitationPeriodDescription}');
    }
    buffer.writeln();

    buffer.writeln('四、小前提（事實涵攝與要件檢驗）：');
    for (final f in subsumptionFindings) {
      final status = f.isSatisfied ? '【符合】' : '【待補強佐證】';
      buffer.writeln('$status ${f.elementName}：${f.factualBasis}');
      if (f.evidentiaryAdvice.isNotEmpty) {
        buffer.writeln('   👉 舉證建議：${f.evidentiaryAdvice}');
      }
    }
    buffer.writeln();

    buffer.writeln('五、結論與主張（法律效果）：');
    buffer.writeln(conclusionRemedy);
    buffer.writeln('具體請求清單（限期 $recommendedDeadlineDays 日內履行）：');
    for (var j = 0; j < demands.length; j++) {
      buffer.writeln('${j + 1}. ${demands[j]}');
    }
    buffer.writeln();

    buffer.writeln('六、舉證必備清冊：');
    for (final ev in evidenceChecklist) {
      buffer.writeln('□ $ev');
    }
    buffer.writeln();

    buffer.writeln('七、逾期救濟途徑：');
    for (final step in escalationPath) {
      buffer.writeln('➔ $step');
    }
    buffer.writeln();
    buffer.writeln('※ 警語：$disclaimer');

    return buffer.toString().trim();
  }
}

/// 臺灣法學三段論法自主推理引擎
class LegalSyllogismEngine {
  const LegalSyllogismEngine._();

  /// 根據當事人陳述，執行完整法學三段論法推理
  static LegalSyllogismAnalysis analyze({
    required String rawFacts,
    String? customClaimant,
    String? customOpponent,
  }) {
    final text = rawFacts.trim();
    final lower = text.toLowerCase();

    // 1. 當事人推斷
    final claimant = customClaimant?.trim().isNotEmpty == true
        ? customClaimant!.trim()
        : _inferClaimant(lower);
    final opponent = customOpponent?.trim().isNotEmpty == true
        ? customOpponent!.trim()
        : _inferOpponent(lower);

    // 2. 檢索最適法規典籍（大前提）
    final matchingStatutes = TaiwanStatuteCanon.findBestMatchingStatutes(text, limit: 3);

    // 3. 領域意圖辨識與三段論生成
    if (_isRentalDispute(lower)) {
      return _buildRentalSyllogism(text, claimant, opponent, matchingStatutes);
    } else if (_isCarAccident(lower)) {
      return _buildCarAccidentSyllogism(text, claimant, opponent, matchingStatutes);
    } else if (_isLoanDispute(lower)) {
      return _buildLoanSyllogism(text, claimant, opponent, matchingStatutes);
    } else if (_isLaborDispute(lower)) {
      return _buildLaborSyllogism(text, claimant, opponent, matchingStatutes);
    } else if (_isConsumerDispute(lower)) {
      return _buildConsumerSyllogism(text, claimant, opponent, matchingStatutes);
    } else if (_isConstructionDispute(lower)) {
      return _buildConstructionSyllogism(text, claimant, opponent, matchingStatutes);
    } else {
      return _buildGeneralCivilSyllogism(text, claimant, opponent, matchingStatutes);
    }
  }

  // --- 意圖辨識 ---
  static bool _isRentalDispute(String text) =>
      text.contains('租') || text.contains('房東') || text.contains('押金') || text.contains('房客');

  static bool _isCarAccident(String text) =>
      text.contains('車禍') || text.contains('撞') || text.contains('追撞') || text.contains('初判表');

  static bool _isLoanDispute(String text) =>
      text.contains('借') || text.contains('欠') || text.contains('還錢') || text.contains('借據') || text.contains('本票');

  static bool _isLaborDispute(String text) =>
      text.contains('工資') || text.contains('加班') || text.contains('資遣') || text.contains('薪水') || text.contains('離職') || text.contains('老闆');

  static bool _isConsumerDispute(String text) =>
      text.contains('網購') || text.contains('鑑賞期') || text.contains('退貨') || text.contains('買賣');

  static bool _isConstructionDispute(String text) =>
      text.contains('裝潢') || text.contains('工程') || text.contains('瑕疵') || text.contains('尾款') || text.contains('修補');

  // --- 專屬三段論生成器 ---

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
      subsumptionFindings: [
        const SubsumptionFinding(
          elementName: '租賃契約消滅與房屋點交返還',
          isSatisfied: true,
          factualBasis: '承租人已依約完成騰空房屋並通知出租人驗收點交，租賃關係客觀上已告消滅。',
          evidentiaryAdvice: '務必留存退租點交現況照片、錄影及交付鑰匙之通訊紀錄。',
        ),
        const SubsumptionFinding(
          elementName: '押金返還義務之成立',
          isSatisfied: true,
          factualBasis: '依租賃條例第34條規定，交還房屋時，房東扣除無爭議之水電瓦斯後，應即刻返還剩餘全部押金。',
          evidentiaryAdvice: '備妥當初支付押金之轉帳存摺明細與最後一期水電瓦斯結算收據。',
        ),
        const SubsumptionFinding(
          elementName: '自然折舊耗損不得藉故扣款',
          isSatisfied: true,
          factualBasis: '內政部房屋租賃定型化契約應記載及不得記載事項明定，因正常居住使用所致之自然污損折舊，修繕義務仍歸房東，不得任意轉嫁扣抵承租人押金。',
          evidentiaryAdvice: '出示搬入初期的現況照片，佐證爭議瑕疵屬自然泛黃或原有建材老化。',
        ),
      ],
      conclusionRemedy:
          '相對人（出租人）負有於收受催告後返還全部未扣抵押金之法定義務；若逾期未返還，應自期限屆滿翌日起加計年息5%之法定遲延利息。',
      demands: [
        '請相對人於文到後 7 日內，將全數應退之押租保證金匯入發函人指定帳戶。',
        '若有任何扣抵主張，應於同期限內出具具備法律效力之正式修繕單據及發票明細供核對。',
      ],
      recommendedDeadlineDays: 7,
      evidenceChecklist: [
        '房屋租賃契約書原本',
        '押金匯款轉帳水單或簽收紀錄',
        '退租點交屋況全景清晰錄影與照片',
        '水電瓦斯管理費結清單據',
        'LINE或通訊軟體催告對話紀錄存證截圖',
      ],
      escalationPath: [
        '寄發正式中華郵政存證信函催告履行',
        '向房屋所在地鄉鎮市區公所調解委員會聲請調解',
        '向行政院消費者保護會或各縣市消保官提出消費爭議申訴',
        '向臺灣地方法院民事庭聲請核發「督促程序支付命令」快速取得執行名義',
      ],
      disclaimer: '本分析係依據您輸入之事實所為之法理推演與資訊整理，不構成正式律師委任法律意見；重大金額或爭訟案件建議轉介認證律師審閱。',
    );
  }

  static LegalSyllogismAnalysis _buildCarAccidentSyllogism(
    String facts,
    String claimant,
    String opponent,
    List<TaiwanStatuteCanonEntry> statutes,
  ) {
    return LegalSyllogismAnalysis(
      claimantName: claimant,
      opponentName: opponent,
      disputeCategory: '交通事故侵權行為損害賠償',
      summaryOfFacts: facts,
      identifiedIssues: [
        '相對人駕駛行為是否存有未注意車前狀況或違規過失？',
        '被害人車損修復費用、醫療支出及工作薪資損失與該事故是否有相當因果關係？',
        '雙方過失責任比例如何劃分（民法第217條過失相抵）？',
      ],
      majorPremiseStatutes: statutes,
      subsumptionFindings: [
        const SubsumptionFinding(
          elementName: '過失不法侵權行為成立',
          isSatisfied: true,
          factualBasis: '相對人駕駛車輛因疏於注意肇事，違反道路交通安全規則，客觀上已構成民法第184條之過失侵權。',
          evidentiaryAdvice: '請向處理警察機關申請「道路交通事故初步分析研判表（初判表）」及事故現場圖。',
        ),
        const SubsumptionFinding(
          elementName: '實質損害之發生與相當因果關係',
          isSatisfied: true,
          factualBasis: '發函人因該碰撞事故，受有車輛毀損修復費、人身就醫治療費及因傷休養期間之薪資停工損失。',
          evidentiaryAdvice: '修車估價單需工料分列（折舊只折零件不折工資）、醫療診斷證明書需載明「宜休養日數」。',
        ),
      ],
      conclusionRemedy:
          '相對人應負民法第184條及第191條之2之損害賠償責任，賠償發函人因本件車禍所生之財產上與非財產上損害。',
      demands: [
        '賠償車輛受損修復必要費用（包含零件及工資）。',
        '賠償因傷就醫支出之健保自付醫療費用及必要交通費。',
        '賠償受傷休養期間之工作薪資損失，並定 10 日內完成協商或給付。',
      ],
      recommendedDeadlineDays: 10,
      evidenceChecklist: [
        '道路交通事故當事人登記聯單',
        '道路交通事故初步分析研判表（初判表）',
        '行車紀錄器碰撞關鍵影片檔案',
        '合格修車廠正式估價單與施工明細發票',
        '醫院診斷證明書正本與收據明細',
        '請假前六個月薪資扣繳憑單或存摺明細',
      ],
      escalationPath: [
        '申請鄉鎮市區調解委員會進行車禍民事調解',
        '向直轄市/縣市車輛行車事故鑑定會申請肇事責任鑑定',
        '若有人員受傷，於車禍發生起 6 個月內向地檢署提出「過失傷害罪」告訴以刑逼民',
        '向地方法院民事庭提起損害賠償民事訴訟',
      ],
      disclaimer: '車禍侵權損害賠償消滅時效為 2 年，過失傷害刑事告訴期間僅有 6 個月，請務必掌握時效進行法定主張。',
    );
  }

  static LegalSyllogismAnalysis _buildLoanSyllogism(
    String facts,
    String claimant,
    String opponent,
    List<TaiwanStatuteCanonEntry> statutes,
  ) {
    return LegalSyllogismAnalysis(
      claimantName: claimant,
      opponentName: opponent,
      disputeCategory: '金錢消費借貸清償與催討',
      summaryOfFacts: facts,
      identifiedIssues: [
        '借貸契約是否成立（交付金錢之要物性是否具備）？',
        '借款是否有約定確定返還期限？若無，是否已為一個月以上之相當期限催告？',
        '逾期遲延利息之起算點與利率（年息5%）。',
      ],
      majorPremiseStatutes: statutes,
      subsumptionFindings: [
        const SubsumptionFinding(
          elementName: '消費借貸合意與金錢交付要物性',
          isSatisfied: true,
          factualBasis: '出借人已透過銀行匯款或交付現金，相對人亦承認借貸或收訖，民法第474條借貸契約已有效成立。',
          evidentiaryAdvice: '保留銀行匯款單、轉帳存摺明細，以及LINE對話中「謝謝借我錢、我下個月還」等承認借貸對話。',
        ),
        const SubsumptionFinding(
          elementName: '清償期屆至或催告催告期滿',
          isSatisfied: true,
          factualBasis: '若原約定還款期已過，債務人即負給付遲延責任；若未定期限，定一個月期限催告送達後即生遲延效力。',
          evidentiaryAdvice: '發送正式存證信函定一個月以上寬限期，作為民法第478條之合法催告依據。',
        ),
      ],
      conclusionRemedy:
          '相對人應依民法第474條及第478條規定，返還借款本金，並自清償期屆滿翌日起加計年息5%之法定遲延利息。',
      demands: [
        '請相對人於收受催告期限內，全數清償積欠之借款本金。',
        '若逾期不還，將依法追討自遲延日起按年息百分之五計算之法定利息直至清償日止。',
      ],
      recommendedDeadlineDays: 30,
      evidenceChecklist: [
        '借據、借貸合約書或借款收據正本',
        '銀行匯款水單或存摺提領匯款對帳單',
        '通訊軟體內相對人承諾借款及還款之對話紀錄截圖',
        '本票原本（若有開立）',
      ],
      escalationPath: [
        '寄發郵局存證信函限期一個月催告清償',
        '向地方法院聲請發「支付命令」，僅需規費500元，迅速取得執行名義',
        '若有簽發本票，向法院聲請「本票裁定」快速查封相對人名下財產',
        '向地方法院提起返還消費借貸款民事訴訟',
      ],
      disclaimer: '金錢借款本金時效 15 年，利息時效 5 年；催告未定期限借款必須給予「一個月以上」法定期間。',
    );
  }

  static LegalSyllogismAnalysis _buildLaborSyllogism(
    String facts,
    String claimant,
    String opponent,
    List<TaiwanStatuteCanonEntry> statutes,
  ) {
    return LegalSyllogismAnalysis(
      claimantName: claimant,
      opponentName: opponent,
      disputeCategory: '勞資爭議、違法欠薪與資遣費追討',
      summaryOfFacts: facts,
      identifiedIssues: [
        '雇主是否有遲延給付工資、未全額給付或未付平日及休息日加班費之情事？',
        '勞工得否依勞動基準法第14條第1項第5、6款不經預告直接終止勞動契約？',
        '勞工終止契約後，雇主發給新制資遣費及非自願離職證明書之法定義務。',
      ],
      majorPremiseStatutes: statutes,
      subsumptionFindings: [
        const SubsumptionFinding(
          elementName: '雇主違反勞動法令與勞動契約',
          isSatisfied: true,
          factualBasis: '雇主未依約給付工資或違法扣發勞工薪資，已符合勞動基準法第14條終止勞動契約之法定事由。',
          evidentiaryAdvice: '完整保存打卡出勤紀錄表、薪資單、勞健保投保紀錄與銀行存摺入帳明細。',
        ),
      ],
      conclusionRemedy:
          '雇主應於契約終止後30日內，全額結清積欠之工資、加班費及新制資遣費，並開具非自願離職證明書。',
      demands: [
        '立即補發全數積欠之工資及延長工時加班費。',
        '依勞工退休金條例第12條規定，依法核發新制資遣費。',
        '依法開立並交付非自願離職證明書及服務證明書。',
      ],
      recommendedDeadlineDays: 7,
      evidenceChecklist: [
        '勞動契約書原本或聘僱通知信函',
        '任職期間全部打卡出勤紀錄與排班表',
        '薪資單或薪資入帳存摺明細',
        '勞工保險投保明細表（勞保局申請）',
        '向雇主主張終止勞動契約之書面通知或存證信函存查聯',
      ],
      escalationPath: [
        '向公司登記所在地之縣市政府勞動局/勞工處申請勞資爭議調解',
        '向勞動檢查處檢舉雇主違反勞動基準法事項',
        '向地方法院勞動法庭提起勞動訴訟程序',
      ],
      disclaimer: '勞工依勞基法第 14 條第 1 項第 6 款主張終止，知悉違法情事起有 30 日除斥期間，請務必及時發函主張。',
    );
  }

  static LegalSyllogismAnalysis _buildConsumerSyllogism(
    String facts,
    String claimant,
    String opponent,
    List<TaiwanStatuteCanonEntry> statutes,
  ) {
    return LegalSyllogismAnalysis(
      claimantName: claimant,
      opponentName: opponent,
      disputeCategory: '消費者保護與網購七日猶豫期退換退款',
      summaryOfFacts: facts,
      identifiedIssues: [
        '本件買賣是否屬消費者保護法第19條之通訊交易？',
        '消費者是否於收受商品翌日起算七日內為解除契約之通知？',
        '賣家要求額外負擔整新費或運費是否合於消保法規定？',
      ],
      majorPremiseStatutes: statutes,
      subsumptionFindings: [
        const SubsumptionFinding(
          elementName: '通訊交易七日無條件解除權成立',
          isSatisfied: true,
          factualBasis: '消費者透過網路電商平台購買，未親自檢視商品，依法享有7日猶豫期，無須說明理由即可無條件退貨。',
          evidentiaryAdvice: '保留物流簽收時間紀錄（超商取件簡訊/黑貓宅配簽單）及7日內向賣家發出退貨退款之通訊截圖。',
        ),
      ],
      conclusionRemedy:
          '契約已合法解除，賣家應於收到退回商品後15日內全額退款，且不得扣除任何包裝費或運費。',
      demands: [
        '請相對人於文到後 7 日內，將商品買賣價金全額無息退還。',
        '請相對人指派物流前來收回商品，運費由賣家負擔。',
      ],
      recommendedDeadlineDays: 7,
      evidenceChecklist: [
        '網路電商平台訂單明細與發票載具紀錄',
        '物流送達簽收單據（確認起算日期）',
        '於7日內向賣方客服要求退貨退款之文字對話截圖',
        '商品未經不當破壞之原始包裝照片',
      ],
      escalationPath: [
        '於行政院消費者保護會線上申訴系統提起第一輪消費爭議申訴',
        '由各縣市政府消保官召開消費爭議協調會',
        '向鄉鎮市區調解委員會申請民事調解',
        '向地方法院簡易庭提起小額民事訴訟',
      ],
      disclaimer: '通訊交易 7 日猶豫期為法定不變除斥期間，請確認是否於期限內完成書面或通訊意思表示。',
    );
  }

  static LegalSyllogismAnalysis _buildConstructionSyllogism(
    String facts,
    String claimant,
    String opponent,
    List<TaiwanStatuteCanonEntry> statutes,
  ) {
    return LegalSyllogismAnalysis(
      claimantName: claimant,
      opponentName: opponent,
      disputeCategory: '室內裝修承攬工程瑕疵與尾款爭議',
      summaryOfFacts: facts,
      identifiedIssues: [
        '工程工作物是否存在與契約約定或通常品質不符之瑕疵？',
        '定作人是否已依法定相當期限催告承攬人進行瑕疵修補？',
        '承攬人拒絕或怠於修補時，定作人得否自行僱工修補並抵扣工程尾款？',
      ],
      majorPremiseStatutes: statutes,
      subsumptionFindings: [
        const SubsumptionFinding(
          elementName: '承攬工作物瑕疵與催告程序合法性',
          isSatisfied: true,
          factualBasis: '承攬人交付之裝修工程存有施工瑕疵，定作人依民法第493條定相當期限催告修補，承攬人逾期未修。',
          evidentiaryAdvice: '具備合格設計合約、詳細報價單圖說，並留存載有具體修補期限之正式存證信函。',
        ),
      ],
      conclusionRemedy:
          '定作人得自行委請其他工班修補瑕疵，並依民法第493條請求承攬人償還修補費用，並得直接與未付尾款為抵銷主張。',
      demands: [
        '請相對人於文到後 7 日內進場完成瑕疵缺失清單所列項目之修補。',
        '若逾期未進場，發函人將另行僱工修復，所需一切工程費用將全額向相對人求償並抵扣尾款。',
      ],
      recommendedDeadlineDays: 7,
      evidenceChecklist: [
        '工程承攬契約書原本、圖說及工程估價單',
        '驗收未通過之缺失瑕疵照片、影片清冊',
        '定相當期限催告修補之存證信函與回執',
        '第三方公正檢驗單位鑑定書或新工班修繕報價單與發票',
      ],
      escalationPath: [
        '寄發郵局存證信函完成民法第493條催告程序',
        '向鄉鎮市區調解委員會聲請工程爭議調解',
        '向地方法院民事庭起訴請求償還修補費用或損害賠償',
      ],
      disclaimer: '定作人瑕疵修補或償還費用請求權時效為 1 年（民法第 514 條），發見瑕疵後應迅速定相當期限催告。',
    );
  }

  static LegalSyllogismAnalysis _buildGeneralCivilSyllogism(
    String facts,
    String claimant,
    String opponent,
    List<TaiwanStatuteCanonEntry> statutes,
  ) {
    return LegalSyllogismAnalysis(
      claimantName: claimant,
      opponentName: opponent,
      disputeCategory: '一般民事債務履行與催告',
      summaryOfFacts: facts,
      identifiedIssues: [
        '雙方是否存在有效之民事法律關係與權利義務？',
        '相對人是否有債務不履行或侵害發函人合法權益之情事？',
        '催告期限屆滿後之法律效果與損害賠償責任。',
      ],
      majorPremiseStatutes: statutes,
      subsumptionFindings: [
        const SubsumptionFinding(
          elementName: '權利義務關係與給付遲延',
          isSatisfied: true,
          factualBasis: '相對人未依契約或民法誠信原則履行義務，已陷於給付遲延或造成損害。',
          evidentiaryAdvice: '出示雙方往來契約、文字通訊紀錄及受損單據。',
        ),
      ],
      conclusionRemedy:
          '相對人應依誠信原則於相當期限內履行法定義務，逾期發函人將依法追究全部民事及刑事責任。',
      demands: [
        '請相對人於文到後 7 日內履行約定事項或清償積欠款項。',
        '若逾期未理，將依法聲請法院核發支付命令或提起民事訴訟，並請求損害賠償。',
      ],
      recommendedDeadlineDays: 7,
      evidenceChecklist: [
        '相關契約協議書、收據或出貨單據',
        '通訊軟體對話紀錄與通話錄音譯文',
        '受有財產損害之憑證及發票',
      ],
      escalationPath: [
        '寄發郵局存證信函完成催告',
        '向鄉鎮市區調解委員會聲請調解',
        '向法院聲請支付命令或提起民事訴訟',
      ],
      disclaimer: '本分析供法律行動預備參考，具體個案權益建議諮詢專業執業律師。',
    );
  }

  static String _inferClaimant(String text) {
    if (text.contains('我是房客') || text.contains('租客') || text.contains('我租') || text.contains('承租人')) {
      return '本人（承租人）';
    }
    if (text.contains('我是房東') || text.contains('出租人')) {
      return '本人（出租人）';
    }
    if (text.contains('被撞') || text.contains('車禍') || text.contains('受傷')) {
      return '本人（被害人）';
    }
    if (text.contains('借他') || text.contains('借給') || text.contains('債權人')) {
      return '本人（債權人）';
    }
    if (text.contains('員工') || text.contains('勞工') || text.contains('上班') || text.contains('被資遣')) {
      return '本人（勞工）';
    }
    return '本人（發函人）';
  }

  static String _inferOpponent(String text) {
    if (text.contains('房東') || text.contains('房仲')) return '房東（出租人）';
    if (text.contains('房客') || text.contains('租客')) return '房客（承租人）';
    if (text.contains('後車') || text.contains('對方車') || text.contains('肇事')) return '肇事車輛駕駛人（相對人）';
    if (text.contains('借錢') || text.contains('借款人') || text.contains('債務人')) return '借款人（債務人）';
    if (text.contains('老闆') || text.contains('雇主') || text.contains('公司')) return '事業單位（雇主）';
    if (text.contains('統包') || text.contains('設計師') || text.contains('師傅')) return '裝修工程承攬人';
    return '相對人';
  }
}
