import 'package:preamble/data/documents/document_models.dart';

/// 緒言 AI 自主法律書狀生成大腦。
///
/// 核心理念：
/// 不使用預先寫好的制式模板，而是完全依據使用者輸入的自然語言案情事實（無論是合夥拆夥、
/// 借貸欠款、工程尾款、侵權賠償、租賃修繕、噪音擾鄰、著作權侵權或勞資爭議），
/// 智能解析關係人、提煉法律請求權基礎、自主編排專業條款章節並產出具備律師事務所水準的法律公文。
class DynamicLegalDrafterBrain {
  const DynamicLegalDrafterBrain._();

  /// 根據使用者任意口語描述，自主生成完整的動態法律公文結構
  static DynamicLegalDocument generateFromFactDescription({
    required String rawFacts,
    String? customSender,
    String? customReceiver,
  }) {
    final text = rawFacts.trim();
    final lower = text.toLowerCase();

    // 1. 自動偵測當事人資訊（若未指定）
    final sender = customSender?.trim().isNotEmpty == true
        ? customSender!.trim()
        : _inferSender(lower);
    final receiver = customReceiver?.trim().isNotEmpty == true
        ? customReceiver!.trim()
        : _inferReceiver(lower);

    // 2. 智慧案由分類與專門條款大腦自主生成
    if (_matchesPartnershipDispute(lower)) {
      return _generatePartnershipDissolution(text, sender, receiver);
    } else if (_matchesConstructionDispute(lower)) {
      return _generateConstructionDispute(text, sender, receiver);
    } else if (_matchesLoanDispute(lower)) {
      return _generateLoanRecovery(text, sender, receiver);
    } else if (_matchesNoiseOrNuisance(lower)) {
      return _generateNuisanceDemand(text, sender, receiver);
    } else if (_matchesCopyrightOrIP(lower)) {
      return _generateIPInfringementDemand(text, sender, receiver);
    } else if (_matchesRentalDispute(lower)) {
      return _generateRentalDemand(text, sender, receiver);
    } else if (_matchesCarAccident(lower)) {
      return _generateCarAccidentSettlement(text, sender, receiver);
    } else if (_matchesLaborDispute(lower)) {
      return _generateLaborDisputeDemand(text, sender, receiver);
    } else {
      return _generateGeneralCivilDemand(text, sender, receiver);
    }
  }

  // --- 意圖辨識啟發式 ---
  static bool _matchesPartnershipDispute(String text) =>
      text.contains('合夥') ||
      text.contains('拆夥') ||
      text.contains('出資') ||
      text.contains('退夥') ||
      text.contains('合開') ||
      text.contains('股權') ||
      text.contains('查帳');

  static bool _matchesConstructionDispute(String text) =>
      text.contains('裝潢') ||
      text.contains('工程') ||
      text.contains('尾款') ||
      text.contains('施工') ||
      text.contains('瑕疵') ||
      text.contains('延遲完工');

  static bool _matchesLoanDispute(String text) =>
      text.contains('借錢') ||
      text.contains('借貸') ||
      text.contains('欠錢') ||
      text.contains('還錢') ||
      text.contains('借據') ||
      text.contains('本票');

  static bool _matchesNoiseOrNuisance(String text) =>
      text.contains('噪音') ||
      text.contains('漏水') ||
      text.contains('樓上') ||
      text.contains('擾鄰') ||
      text.contains('半夜') ||
      text.contains('安寧');

  static bool _matchesCopyrightOrIP(String text) =>
      text.contains('侵權') ||
      text.contains('盜用') ||
      text.contains('著作權') ||
      text.contains('商標') ||
      text.contains('抄襲') ||
      text.contains('未經授權');

  static bool _matchesRentalDispute(String text) =>
      text.contains('租') || text.contains('押金') || text.contains('房東') || text.contains('房客');

  static bool _matchesCarAccident(String text) =>
      text.contains('車禍') || text.contains('撞') || text.contains('追撞') || text.contains('肇事');

  static bool _matchesLaborDispute(String text) =>
      text.contains('薪水') ||
      text.contains('加班') ||
      text.contains('資遣') ||
      text.contains('離職') ||
      text.contains('老闆') ||
      text.contains('勞基法');

  static String _inferSender(String text) {
    if (text.contains('房客') || text.contains('承租人')) return '承租人（本人）';
    if (text.contains('房東') || text.contains('出租人')) return '出租人（本人）';
    if (text.contains('員工') || text.contains('勞工')) return '勞工（本人）';
    if (text.contains('債權人') || text.contains('出借人')) return '債權人（本人）';
    return '發函人（立書人本人）';
  }

  static String _inferReceiver(String text) {
    if (text.contains('房東') || text.contains('出租人')) return '出租人（房東）';
    if (text.contains('房客') || text.contains('承租人')) return '承租人（房客）';
    if (text.contains('老闆') || text.contains('公司')) return '雇主（相對人公司）';
    if (text.contains('債務人') || text.contains('借款人')) return '債務人（相對人）';
    if (text.contains('合夥人')) return '合夥人（相對人）';
    return '相對人（受函人）';
  }

  // --- 自主條款生成邏輯 ---

  static DynamicLegalDocument _generatePartnershipDissolution(
      String rawFacts, String sender, String receiver) {
    return DynamicLegalDocument(
      title: '合夥聲明退夥暨財產結算請求函',
      subtitle: '依民法第686條、第689條聲明退夥並限期辦理清算',
      senderName: sender,
      receiverName: receiver,
      sections: [
        DynamicDocumentSection(
          heading: '合夥出資與經營背景',
          body: '發函人與相對人前共同約定出資經營合夥事業，發函人已依約全額繳足合夥出資款項，此有歷次出資匯款憑證與合作協議可稽。',
          subPoints: [
            '出資金額與約定權利義務載明於原始合作備忘錄。',
            '雙方均負有共同推展業務及維護合夥財產安全之忠實義務。',
          ],
        ),
        DynamicDocumentSection(
          heading: '違約事由與退夥宣告',
          body: '查相對人近來未經合夥人全體同意，私自處分合夥財產或拒絕提供營業帳目，嚴重損害合夥信任基礎。事證如下：$rawFacts',
          subPoints: [
            '相對人拒不配合定期召開合夥會議並說明營業收支明細。',
            '發函人爰依民法第686條規定，正式向相對人為聲明退夥之意思表示。',
          ],
        ),
        DynamicDocumentSection(
          heading: '退夥結算與法律依據',
          body: '依民法第689條規定，退夥人與他合夥人間之結算，應以退夥時合夥財產之狀況為準。合夥事務於退夥時尚未了結者，於了結後計算並分配其損益。',
        ),
      ],
      demands: [
        '請相對人於文到後 7 日內，備妥自合夥成立迄今之完整財務報表、銀行存摺影本及營收帳冊以供查核。',
        '雙方會同選定之會計人員清算合夥資產，並將發函人應得之賸餘財產與出資額全額返還。',
      ],
      evidences: [
        '原始合夥出資匯款憑證與對話紀錄。',
        '合夥營業場所租約或相關營業證明文件。',
      ],
      legalBasis: ['民法第686條（退夥之聲明）', '民法第689條（退夥人之結算）', '刑法第336條（業務侵占罪警示）'],
      warningClause:
          '若相對人逾期仍拒絕提出帳冊清算或涉嫌私自挪用合夥公款，發函人將立即委請律師依法向管轄地方法院提起返還出資與損害賠償訴訟，並就涉及業務侵占、背信之刑事不法行為向地檢署提出告訴，絕不寬貸。',
      deadlineDays: 7,
    );
  }

  static DynamicLegalDocument _generateConstructionDispute(
      String rawFacts, String sender, String receiver) {
    return DynamicLegalDocument(
      title: '工程裝修瑕疵修繕催告暨給付結算函',
      subtitle: '依民法第492條、第493條請求限期修補瑕疵',
      senderName: sender,
      receiverName: receiver,
      sections: [
        DynamicDocumentSection(
          heading: '承攬契約成立與約定項目',
          body: '發函人前與相對人成立室內裝修承攬契約，約定由相對人承攬施工，發函人已依工程進度如期給付各期工程款項。',
        ),
        DynamicDocumentSection(
          heading: '施工瑕疵或工期延誤事證',
          body: '查相對人施作之工程項目存在多處重大瑕疵，未達合約約定之品質標準或遲延未完工：$rawFacts',
          subPoints: [
            '瑕疵部位經發函人多次口頭及通訊軟體催促，相對人均未積極進場修繕改善。',
            '依民法第492條規定，承攬人應擔保其完成之工作無瑕疵。',
          ],
        ),
      ],
      demands: [
        '請相對人於文到後 10 日內，指派合格工班進場完成所有列管缺失項目之修補及復原驗收。',
        '若逾期未進場修補，發函人將自行委請第三方廠商進行修復，所衍生之工料費用將全額由未付尾款扣抵，不足部分依法追償。',
      ],
      evidences: [
        '工程承攬合約書與估價單。',
        '現場瑕疵現況彩色照片清冊。',
        '催告修繕之通訊對話紀錄截圖。',
      ],
      legalBasis: ['民法第492條（承攬瑕疵擔保）', '民法第493條（定作人之瑕疵修補請求權）', '民法第494條（解除契約或減少報酬）'],
      warningClause: '本函所載瑕疵若逾期未獲改善，發函人將依法行使契約解除權、請求減少報酬並追償因工期遲延所生之租金與營業損失。',
      deadlineDays: 10,
    );
  }

  static DynamicLegalDocument _generateLoanRecovery(
      String rawFacts, String sender, String receiver) {
    return DynamicLegalDocument(
      title: '消費借貸款項清償催告函',
      subtitle: '依民法第474條、第478條請求定期返還借款',
      senderName: sender,
      receiverName: receiver,
      sections: [
        DynamicDocumentSection(
          heading: '消費借貸契約成立事實',
          body: '緣相對人前向發函人商借款項，發函人基於信賴已將約定借貸款項交付相對人收訖，有轉帳交易憑證或本票借據為證。',
        ),
        DynamicDocumentSection(
          heading: '清償期屆至或催告返還事實',
          body: '詎料清償期限屆至後，經發函人屢次催告，相對人迄今仍分文未償：$rawFacts',
        ),
      ],
      demands: [
        '請相對人於文到後 7 日內，將積欠本金及依法計算之法定利息匯入發函人指定之金融機構帳戶。',
      ],
      evidences: [
        '銀行轉帳交易明細或匯款單據。',
        '雙方借據、本票正本或借款通訊對話紀錄。',
      ],
      legalBasis: ['民法第474條（消費借貸）', '民法第478條（借用人之返還義務）', '民法第233條（遲延利息）'],
      warningClause: '若逾期仍未清償，發函人將逕行向管轄地方法院聲請核發支付命令或提起給付借款訴訟，並向法院聲請強制執行相對人名下財產（包括存款、薪資、動產及不動產），屆時所需訴訟費用及執行費用悉由相對人負擔。',
      deadlineDays: 7,
    );
  }

  static DynamicLegalDocument _generateNuisanceDemand(
      String rawFacts, String sender, String receiver) {
    return DynamicLegalDocument(
      title: '排除侵害安寧生活秩序與損害賠償催告函',
      subtitle: '依民法第793條、第184條、第195條請求立即停止侵權行為',
      senderName: sender,
      receiverName: receiver,
      sections: [
        DynamicDocumentSection(
          heading: '相鄰關係與侵權事實',
          body: '發函人與相對人為鄰里關係，相對人住處或所有處所近來持續發生逾越一般人社會生活所能容忍標準之干擾行為：$rawFacts',
          subPoints: [
            '該行為已嚴重妨害發函人居住安寧與身心健康，經多次溝通均未見改善。',
          ],
        ),
      ],
      demands: [
        '請相對人於文到後立即停止上述干擾行為，並妥善採取隔音防制或修繕防堵措施。',
        '就已造成之財物損壞或身心就醫損害，雙方協議具體賠償方案。',
      ],
      evidences: [
        '分貝計量測紀錄、錄音錄影存證光碟。',
        '管委會投訴紀錄或警局報案處理紀錄單。',
        '就診就醫診斷證明書。',
      ],
      legalBasis: ['民法第793條（氣響之侵入）', '民法第184條（侵權行為責任）', '公寓大廈管理條例第16條'],
      warningClause: '若相對人仍置若罔聞，發函人除將持續通報環保局與警察機關依社會秩序維護法裁罰外，並將向地方法院提起排除侵害之訴並請求非財產上損害賠償（慰撫金）。',
      deadlineDays: 3,
    );
  }

  static DynamicLegalDocument _generateIPInfringementDemand(
      String rawFacts, String sender, String receiver) {
    return DynamicLegalDocument(
      title: '侵害著作權 / 商標權停止侵害暨損害賠償警告函',
      subtitle: '依著作權法第84條、第88條請求立即下架侵權內容',
      senderName: sender,
      receiverName: receiver,
      sections: [
        DynamicDocumentSection(
          heading: '智慧財產權權利歸屬',
          body: '發函人依法享有原創作品之完整著作財產權及著作人格權，受中華民國著作權法之完全保護。',
        ),
        DynamicDocumentSection(
          heading: '未經授權重製與公開傳輸事證',
          body: '查相對人未經發函人事前書面同意或授權，擅自於其公開管道重製、改作或散布發函人之創作成果：$rawFacts',
        ),
      ],
      demands: [
        '立即將所有侵權圖片、文字、影音或商品自全平台下架並永久刪除銷毀。',
        '於指定期限內主動聯繫發函人洽商侵權損害賠償及授權金補償事宜。',
      ],
      evidences: [
        '原創作品原始發布時間戳記與檔案著作證明。',
        '相對人侵權網頁、社群截圖與存證錄影。',
      ],
      legalBasis: ['著作權法第84條（侵害之排除與防止）', '著作權法第88條（損害賠償）', '著作權法第91條（刑事擅自重製罪）'],
      warningClause: '著作權法侵害罪責屬民刑併罰之重罪。若相對人未於期限內全數下架並出面和解，發函人將保全公證證據後，具狀向保二總隊刑事警察大隊提起告訴並附帶民事求償。',
      deadlineDays: 3,
    );
  }

  static DynamicLegalDocument _generateRentalDemand(
      String rawFacts, String sender, String receiver) {
    return DynamicLegalDocument(
      title: '租賃契約押金返還暨權利結清催告函',
      subtitle: '依民法第423條及租賃住宅市場發展條例請求全額返還押租金',
      senderName: sender,
      receiverName: receiver,
      sections: [
        DynamicDocumentSection(
          heading: '租約起訖與點交現況',
          body: '雙方租賃關係業已合法終止，承租人已依約騰空房屋並完成現場點交手續，將房屋及鑰匙返還出租人受領。',
        ),
        DynamicDocumentSection(
          heading: '押金返還爭議事實',
          body: '按租賃契約約定，出租人於租約終止交屋後應即結算並返還押租金。詎料出租人無正當理由扣抵拖延：$rawFacts',
        ),
      ],
      demands: [
        '請出租人於文到後 5 日內，將扣除必要水電規費後之全額押金匯回承租人原約定帳戶。',
      ],
      evidences: [
        '租賃契約書原本影本。',
        '退租交屋當日現況錄影照片。',
        '押金收據與匯款明細。',
      ],
      legalBasis: ['民法第423條（租賃物之交付及修繕）', '租賃住宅市場發展及管理條例第7條', '消費者保護法定型化契約應記載事項'],
      warningClause: '若逾期未返還，承租人將依法向行政院消保官提出申訴，並向地方法院聲請調解及核發支付命令，並依法請求給付法定遲延利息。',
      deadlineDays: 5,
    );
  }

  static DynamicLegalDocument _generateCarAccidentSettlement(
      String rawFacts, String sender, String receiver) {
    return DynamicLegalDocument(
      title: '交通事故損害賠償與和解請求函',
      subtitle: '依民法第184條、第191條之2請求損害賠償',
      senderName: sender,
      receiverName: receiver,
      sections: [
        DynamicDocumentSection(
          heading: '事故發生事實經過',
          body: '雙方車輛於道路發生碰撞交通事故，經轄區交通警察大隊到場測繪處理在案：$rawFacts',
        ),
        DynamicDocumentSection(
          heading: '肇事責任與損害項目說明',
          body: '依道路交通事故初步分析研判表，相對人駕駛行為具有肇事過失。發函人受有車輛修復費用、醫療支出及代步損失。',
        ),
      ],
      demands: [
        '請相對人於文到後 7 日內，主動聯繫發函人或委由承保產物保險公司出面協商理賠金額及和解事宜。',
      ],
      evidences: [
        '道路交通事故初步分析研判表及現場圖。',
        '車輛原廠受損維修估價單及照片。',
        '醫院診斷證明書與醫療單據。',
      ],
      legalBasis: ['民法第184條（一般侵權行為）', '民法第191條之2（動力車輛駕駛人責任）', '民法第193條（身體健康之損害賠償）'],
      warningClause: '若相對人拒絕出面處理或保險公司拖延理賠，發函人將向管轄鄉鎮市區調解委員會申請調解，必要時將具狀向地方法院提起損害賠償訴訟（若涉及人傷將併提過失傷害告訴）。',
      deadlineDays: 7,
    );
  }

  static DynamicLegalDocument _generateLaborDisputeDemand(
      String rawFacts, String sender, String receiver) {
    return DynamicLegalDocument(
      title: '勞資爭議給付工資/資遣費暨開立非自願離職證明催告函',
      subtitle: '依勞動基準法第24條、第17條請求給付法定權益',
      senderName: sender,
      receiverName: receiver,
      sections: [
        DynamicDocumentSection(
          heading: '勞動契約關係與出勤事實',
          body: '發函人前受僱於相對人公司擔任職務，於任職期間均克盡職責提供勞務，出勤打卡紀錄明確可稽。',
        ),
        DynamicDocumentSection(
          heading: '雇主違反勞動法令事由',
          body: '查相對人公司在工資給付、工時計算或終止勞動契約程序上，存在違反勞動基準法之情事：$rawFacts',
        ),
      ],
      demands: [
        '請相對人公司於文到後 7 日內，如數補發積欠之加班費/工資/資遣費，並依法開立非自願離職證明書予發函人。',
      ],
      evidences: [
        '出勤打卡記錄截圖或門禁刷卡紀錄。',
        '每月薪資轉帳存摺明細與薪資單。',
        '通訊軟體非上班時間交付工作事證。',
      ],
      legalBasis: ['勞動基準法第24條（延長工時工資）', '勞動基準法第17條（資遣費發給）', '勞動基準法第19條（服務證明書之發給）'],
      warningClause: '若逾期未處理，發函人將直接向所在地直轄市/縣市政府勞工局申請勞資爭議調解，並檢舉雇主違法情事申請實施勞動檢查，同時依法追償損害。',
      deadlineDays: 7,
    );
  }

  static DynamicLegalDocument _generateGeneralCivilDemand(
      String rawFacts, String sender, String receiver) {
    return DynamicLegalDocument(
      title: '民事權益履行與最後通牒催告函',
      subtitle: '依民法相關規定請求限期履行義務',
      senderName: sender,
      receiverName: receiver,
      sections: [
        DynamicDocumentSection(
          heading: '法律關係與約定事實',
          body: '雙方前就特定法律關係有所約定與往來，發函人已誠信履行相關義務，此有雙方通訊與交易憑證在卷可稽。',
        ),
        DynamicDocumentSection(
          heading: '相對人未履行義務之事實',
          body: '詎料相對人迄今尚未依約履行義務，經發函人多次溝通未果，事實摘要如下：$rawFacts',
        ),
      ],
      demands: [
        '特此函告相對人於文到後 7 日內，確實履行上述約定事項或妥善提出解決方案。',
      ],
      evidences: [
        '雙方往來通訊紀錄截圖。',
        '金流轉帳或合約相關單據。',
      ],
      legalBasis: ['民法第229條（給付遲延責任）', '民法第231條（遲延之損害賠償）'],
      warningClause: '本函係依法所為之正式催告。如相對人屆期仍不予理會，發函人當即依法採取民刑事司法途徑追究到底，以維權益。',
      deadlineDays: 7,
    );
  }
}
