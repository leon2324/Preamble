import 'package:preamble/components/shared/mvp_state_widgets.dart';
import 'package:preamble/data/documents/document_models.dart';
import 'package:preamble/data/legal_brain/taiwan_statute_canon.dart';

/// 法律時效資訊模型
class LegalStatuteDeadline {
  const LegalStatuteDeadline({
    required this.title,
    required this.legalBasis,
    required this.durationDays,
    required this.urgencyDescription,
    required this.warningNote,
  });

  final String title;
  final String legalBasis;
  final int durationDays;
  final String urgencyDescription;
  final String warningNote;

  Map<String, dynamic> toJson() => {
        'title': title,
        'legalBasis': legalBasis,
        'durationDays': durationDays,
        'urgencyDescription': urgencyDescription,
        'warningNote': warningNote,
      };

  factory LegalStatuteDeadline.fromJson(Map<String, dynamic> json) =>
      LegalStatuteDeadline(
        title: json['title'] as String? ?? '法定救濟時效',
        legalBasis: json['legalBasis'] as String? ?? '民事訴訟法相關規定',
        durationDays: json['durationDays'] as int? ?? 30,
        urgencyDescription:
            json['urgencyDescription'] as String? ?? '請於期限內主張權利以免罹於時效。',
        warningNote: json['warningNote'] as String? ?? '',
      );
}

/// 臨場談判防坑三不原則錦囊
class NegotiationDefenseKit {
  const NegotiationDefenseKit({
    required this.threeNeverSign,
    required this.threeMustAsk,
    required this.recordingLegalityTip,
  });

  final List<String> threeNeverSign;
  final List<String> threeMustAsk;
  final String recordingLegalityTip;

  Map<String, dynamic> toJson() => {
        'threeNeverSign': threeNeverSign,
        'threeMustAsk': threeMustAsk,
        'recordingLegalityTip': recordingLegalityTip,
      };

  factory NegotiationDefenseKit.fromJson(Map<String, dynamic> json) =>
      NegotiationDefenseKit(
        threeNeverSign: (json['threeNeverSign'] as List<dynamic>?)
                ?.map((e) => e.toString())
                .toList() ??
            const [],
        threeMustAsk: (json['threeMustAsk'] as List<dynamic>?)
                ?.map((e) => e.toString())
                .toList() ??
            const [],
        recordingLegalityTip: json['recordingLegalityTip'] as String? ??
            '💡 自保提醒：在台灣，談判當事人一方為保障自身權益所為之通話或現場錄音，依法不構成妨害秘密罪。',
      );
}

/// 小法助深度攻防分析模型（涵蓋全台灣 17 大法律爭議領域，含動態事實實體感知與應對金句）
class LawAssistantDefenseInsight {
  const LawAssistantDefenseInsight({
    required this.disputeCategory,
    required this.defensePoints,
    required this.keyEvidences,
    required this.suggestedTemplateType,
    required this.suggestedActionLabel,
    this.extractedFacts = '',
    this.suggestedFollowUps = const [],
    this.statuteDeadline,
    this.negotiationKit,
    this.immediateReassurance = '',
    this.tacticalGoldenPhrase = '',
    this.detectedAmount = '',
    this.detectedCounterparty = '',
  });

  final String disputeCategory;
  final List<String> defensePoints;
  final List<String> keyEvidences;
  final DocumentTemplateType suggestedTemplateType;
  final String suggestedActionLabel;
  final String extractedFacts;
  final List<String> suggestedFollowUps;
  final LegalStatuteDeadline? statuteDeadline;
  final NegotiationDefenseKit? negotiationKit;

  /// 即時定心丸（安撫當事人恐慌與焦慮情緒）
  final String immediateReassurance;

  /// 現場或 LINE 應對金句（可直接複製照著唸或發送）
  final String tacticalGoldenPhrase;

  /// 動態識別抽取之爭議金額（例如：28,000元、50萬元）
  final String detectedAmount;

  /// 動態識別抽取之相對人稱謂（例如：房東、老闆、對造駕駛）
  final String detectedCounterparty;

  /// 根據使用者諮詢內容自動辨識爭議領域、動態抽取爭議實體並產生全方位攻防指引
  factory LawAssistantDefenseInsight.fromContext({
    required String text,
  }) {
    final domain = TaiwanStatuteCanon.detectDisputeDomain(text);
    final amount = _extractAmountFromText(text);
    final party = _extractCounterpartyFromText(text, domain);
    final amountSuffix = amount.isNotEmpty ? '新台幣 $amount' : '全數爭議款項';

    switch (domain) {
      case TaiwanDisputeDomain.rentalAndHousing:
        final targetParty = party.isNotEmpty ? party : '房東';
        return LawAssistantDefenseInsight(
          disputeCategory: '租賃住宅與不動產點交爭議',
          detectedAmount: amount,
          detectedCounterparty: targetParty,
          immediateReassurance: '💡 先別慌！依租賃住宅專法與內政部定型化契約，房屋自然折舊與通常使用耗損修繕義務在房東，房東依法無權任意扣留${amount.isNotEmpty ? amount : "押金"}。',
          tacticalGoldenPhrase: '「$targetParty您好，依租賃住宅市場發展及管理條例第34條與內政部定型化契約規定，房屋自然折舊老化依法由出租人負擔。交還房屋時，除無爭議之水電規費外，請依法於點交後返還$amountSuffix；若有修繕扣款主張，請出具正式廠商修繕發票明細供核對，謝謝。」',
          defensePoints: const [
            '主張房屋有非自然耗損或污損，要求由押金抵扣修繕清潔費',
            '主張提前終止租約需扣除 1 個月租金作為法定上限違約補償',
            '主張退租點交尚未完成或鑰匙未歸還，衍生相當於租金之不當得利',
          ],
          keyEvidences: const [
            '原證一：租賃契約書原本（確認押金約定與修繕特約條款）',
            '原證二：退租交屋當日現場全景錄影與照片（需含拍攝時間戳記）',
            '原證三：押金匯款單據與歷次水電瓦斯管理費結清收據',
            '原證四：向房東催告返還押金之 LINE 完整對話紀錄截圖',
          ],
          suggestedTemplateType: DocumentTemplateType.rentalDepositNegotiation,
          suggestedActionLabel: '一鍵轉為租屋押金協商函 (PDF/草稿)',
          suggestedFollowUps: [
            if (amount.isNotEmpty) '目前主張扣除的 $amount 是否有出具修繕單據？' else '房東目前主張扣除的押金金額是多少？',
            '退租交屋當日是否有拍照存證並完成點交清冊？',
            '雙方租約是否有約定修繕責任歸屬？',
          ],
          statuteDeadline: const LegalStatuteDeadline(
            title: '押金返還與損害賠償時效',
            legalBasis: '民法第456條（租賃物損害賠償請求權6個月）',
            durationDays: 180,
            urgencyDescription: '交還租賃物後 6 個月內為損害賠償請求黃金時效，逾期權利消滅。',
            warningNote: '若房東拒退，請把握 6 個月內向消保官申訴或聲請法院調解。',
          ),
          negotiationKit: const NegotiationDefenseKit(
            threeNeverSign: [
              '❌ 絕不簽署含有「放棄其餘押金返還請求權」的點交切結書。',
              '❌ 絕不簽署空白修繕估價單或未載明修繕明細之扣款單。',
              '❌ 絕不簽署「概括承認屋況全部損壞均由房客造成」之確認單。',
            ],
            threeMustAsk: [
              '❓ 請問修繕估價單與單據明細是否能提供正本核對？',
              '❓ 自然折舊老化依法應由出租人負擔，請問扣款折舊基準為何？',
              '❓ 扣除必要水電後，剩餘無爭議押金何時能先匯回？',
            ],
            recordingLegalityTip:
                '💡 自保錄音合法性：在台灣，身為點交當事人一方，為了自保而錄下現場對話，依法不構成妨害秘密罪。',
          ),
        );

      case TaiwanDisputeDomain.trafficAndTort:
        final targetParty = party.isNotEmpty ? party : '對方駕駛';
        return LawAssistantDefenseInsight(
          disputeCategory: '交通事故與侵權損害賠償',
          detectedAmount: amount,
          detectedCounterparty: targetParty,
          immediateReassurance: '💡 人身安全第一，請先別慌！在警察初判表核發與傷勢穩定前，切勿私下承諾${amount.isNotEmpty ? "賠償 $amount" : "賠償金額"}或簽署任何拋棄權利之和解書。',
          tacticalGoldenPhrase: '「$targetParty您好，本件事故已由警方現場處理成案，後續過失責任與肇責比例，請依交通大隊 30 日後核發之『初步分析研判表』及承保保險公司之認定為準。目前我方傷勢與車損仍在依法評估中${amount.isNotEmpty ? "（初估損失約 $amount）" : ""}，在責任釐清前暫不簽署任何私下和解協議，一切依正式程序辦理。」',
          defensePoints: const [
            '主張民法第 217 條「與有過失」，要求過失相抵降低賠償比例',
            '抗辯車輛維修零件費用過高，依法應按出廠年份計算「零件折舊」',
            '抗辯醫療支出非必要費用或工作損失缺乏正式薪資扣繳證明',
          ],
          keyEvidences: const [
            '原證一：道路交通事故初步分析研判表 (初判表) 與現場圖',
            '原證二：車輛原廠估價單、受損部位彩色照片與維修發票',
            '原證三：公立/區域醫院診斷證明書（載明需休養天數）與醫療單據',
            '原證四：請假工作損失之薪資扣繳憑單或銀行薪轉明細',
          ],
          suggestedTemplateType: DocumentTemplateType.carAccidentChecklist,
          suggestedActionLabel: '生成車禍過失侵權求償與和解清單 (PDF/草稿)',
          suggestedFollowUps: [
            '目前事故是否已取得警方初判表或車鑑會鑑定意見書？',
            '事故當下是否有申請車輛保險理賠派員？',
            '受傷人員是否已有診斷證明書載明休養天數與醫囑？',
          ],
          statuteDeadline: const LegalStatuteDeadline(
            title: '過失傷害告訴時效（黃金6個月）',
            legalBasis: '刑事訴訟法第237條（告訴乃論6個月告訴期間）',
            durationDays: 180,
            urgencyDescription: '涉及人傷之過失傷害告訴，自知悉肇事人之日起「6 個月內」必須提出。',
            warningNote: '若和解談判拖延超過 6 個月，將永遠喪失以刑事提告以刑逼民之權利！',
          ),
          negotiationKit: const NegotiationDefenseKit(
            threeNeverSign: [
              '❌ 在傷勢完全痊癒前，絕不簽署「拋棄民刑事一切請求權」之和解書。',
              '❌ 絕不簽署保險理賠金未扣抵前之全額自賠認可協議。',
              '❌ 對方保險理賠員私下要求簽字時，未仔細審閱條款前絕不簽名。',
            ],
            threeMustAsk: [
              '❓ 請問對方強制險與第三人責任險的理賠案號為何？',
              '❓ 針對工作損失與看護費用，保險公司核定賠付標準為何？',
              '❓ 初步分析研判表已載明肇事責任，請問何時召開鄉鎮市調解？',
            ],
            recordingLegalityTip:
                '💡 談判通話錄音提醒：與對造或保險理賠員溝通理賠細節時，保留電話錄音為自身合法保障權益之重要佐證。',
          ),
        );

      case TaiwanDisputeDomain.loanAndDebt:
        final targetParty = party.isNotEmpty ? party : '借款人';
        return LawAssistantDefenseInsight(
          disputeCategory: '消費借貸、票據與債權債務爭議',
          detectedAmount: amount,
          detectedCounterparty: targetParty,
          immediateReassurance: '💡 債務協商請冷靜！法律明文保障：年息超過 16% 部分依法無效；若收到法院支付命令，必須在 20 天內提出異議！',
          tacticalGoldenPhrase: '「$targetParty您好，關於本件${amount.isNotEmpty ? "借款 $amount" : "款項"}之清償爭端，請提供完整的借貸金流憑證與本息抵充對帳明細。若有利息約定，亦請確認符合民法第205條法定最高年息16%之限制；為確保雙方權益，本件建議以書面正式核對或由鄉鎮市調解委員會召開客觀調解。」',
          defensePoints: const [
            '抗辯借款約定利率超過法定年息16%上限，依民法第205條超過部分無效',
            '抗辯未定返還期限之消費借貸未經一個月以上催告，不負遲延給付責任',
            '主張債權本息或票據追索權已罹於法定消滅時效，行使時效抗辯',
          ],
          keyEvidences: const [
            '原證一：借貸契約借據原本、借款協議書或商務借款合約',
            '原證二：銀行跨行轉帳明細、匯款單、存摺收支紀錄或金流憑證',
            '原證三：系爭本票、支票正背面清晰影本及退票理由單',
            '原證四：催告還款之存證信函、通訊軟體對話紀錄催討截圖',
          ],
          suggestedTemplateType: DocumentTemplateType.depositDemand,
          suggestedActionLabel: '生成借貸清償催告存證信函/支付命令聲請狀 (PDF)',
          suggestedFollowUps: [
            '是否有雙方借據、本票或完整的跨行匯款金流明細？',
            '雙方有無約定還款期限？是否已寄發存證信函進行定一個月以上催告？',
            '借款約定利息是否超出法定年息 16% 之最高上限？',
          ],
          statuteDeadline: const LegalStatuteDeadline(
            title: '本票裁定或支付命令法定時效',
            legalBasis: '票據法第22條（票據時效3年）與民事訴訟法第516條（20日異議期）',
            durationDays: 20,
            urgencyDescription: '收到法院支付命令應於「20 日內」提出異議，否則確定後即得逕行強制執行。',
            warningNote: '本票對發票人追索權時效為 3 年，利息請求權為 5 年，一般借貸本金為 15 年。',
          ),
          negotiationKit: const NegotiationDefenseKit(
            threeNeverSign: [
              '❌ 絕不簽署未確認金流債權真實性之「本票」或空白借據。',
              '❌ 絕不簽署利息滾入本金計算複利且超過年息16%之高利協商合約。',
              '❌ 絕不簽署拋棄時效抗辯或逕行認諾不實債務之同意書。',
            ],
            threeMustAsk: [
              '❓ 請問借款之實際交付金流帳戶與明細何在？',
              '❓ 歷次還款本金與利息抵充明細為何？',
              '❓ 雙方約定利率是否符合民法第205條年利率16%上限？',
            ],
            recordingLegalityTip:
                '💡 面談自保提醒：與相對人進行債務協商時，請完整留存通話及對話紀錄作為日後法院清償抵充佐證。',
          ),
        );

      case TaiwanDisputeDomain.laborAndEmployment:
        final targetParty = party.isNotEmpty ? party : '公司主管/人資';
        return LawAssistantDefenseInsight(
          disputeCategory: '勞資爭議、加班費與資遣解僱',
          detectedAmount: amount,
          detectedCounterparty: targetParty,
          immediateReassurance: '💡 絕對不要在未拿到資遣費前簽署自願離職單！雇主單方口頭開除即屬違法，打卡紀錄與交辦公務截圖是您的最強王牌。',
          tacticalGoldenPhrase: '「$targetParty您好，若公司因業務緊縮或不能勝任終止勞動契約，請依法出具載明勞動基準法第11條具體款項之『非自願離職證明書』，並依法結算特休未休工資、預告工資及${amount.isNotEmpty ? "未發款項 $amount" : "法定資遣費"}；在未收到正式資遣文件前，我方保留勞動契約相關一切權利。」',
          defensePoints: const [
            '主張職務性質屬責任制或主管職，不適用勞動基準法一般加班費規定',
            '主張勞工係自願離職或合意終止，無須發給資遣費或非自願離職證明',
            '主張勞工嚴重違反勞動契約或工作規則，依勞基法第12條懲戒解僱',
          ],
          keyEvidences: const [
            '原證一：完整出勤打卡紀錄、門禁刷卡紀錄或公司電腦登入時間記錄',
            '原證二：每月薪資明細表 (Pay Slip) 與銀行薪資轉帳帳戶存摺影本',
            '原證三：非正常工時主管以 LINE、Email 交辦公務與回報成果截圖',
            '原證四：勞動契約書、績效考核表、資遣通知書或離職證明文件',
          ],
          suggestedTemplateType: DocumentTemplateType.laborDisputeMessage,
          suggestedActionLabel: '一鍵轉為勞資爭議協調申訴函 (PDF/草稿)',
          suggestedFollowUps: [
            '公司是否有提供最近一年的出勤打卡紀錄及薪資明細單？',
            '終止勞動契約時雇主所持之法定條款依據為何？',
            '加班是否有留下具體主管指派工作或交辦任務截圖？',
          ],
          statuteDeadline: const LegalStatuteDeadline(
            title: '勞資爭議救濟與工資請求時效',
            legalBasis: '民法第126條（工資請求權5年）與勞動基準法',
            durationDays: 30,
            urgencyDescription: '遭違法解僱或逼退時，建議於 30 日內向勞工局申請勞資爭議調解。',
            warningNote: '失業給付請領應於非自願離職退保次日起 2 年內向公立就業服務機構提出。',
          ),
          negotiationKit: const NegotiationDefenseKit(
            threeNeverSign: [
              '❌ 絕不在未給付全額資遣費前，簽署任何形式之「自願離職切結書」。',
              '❌ 絕不簽署「拋棄加班費、特休未休折算工資及退職金」之免責條款。',
              '❌ 絕不簽署未經查證之懲戒性解僱自白書。',
            ],
            threeMustAsk: [
              '❓ 請問資遣理由是依勞動基準法第11條第幾款？何時開立非自願離職證明？',
              '❓ 依勞基法規定，特休未休日數與預告期間工資是否如期折算發放？',
              '❓ 若主張責任制，請問有無勞動部核備並送地方主管機關備查之書面約定？',
            ],
            recordingLegalityTip:
                '💡 面談自保提醒：與人資或主管進行資遣或考績面談時，身為當事人可合法開啟錄音記錄資遣事由與承諾。',
          ),
        );

      case TaiwanDisputeDomain.consumerProtection:
        final targetParty = party.isNotEmpty ? party : '賣家';
        return LawAssistantDefenseInsight(
          disputeCategory: '消費者保護、特種網購與買賣瑕疵',
          detectedAmount: amount,
          detectedCounterparty: targetParty,
          immediateReassurance: '💡 網購拆封絕非不能退！依消保法第 19 條，通訊交易消費者享有 7 日猶豫期，賣家自訂之『拆封概不退換』條款依法無效。',
          tacticalGoldenPhrase: '「$targetParty您好，依消費者保護法第19條特種通訊交易規定，消費者於收受商品後7日內享有法定無條件解除契約權，賣方不得要求負擔任何費用或收取整新費。商品開箱影像已完整存證，請於文到後提供退貨寄送資訊並依約辦理全額退款$amountSuffix，謝謝。」',
          defensePoints: const [
            '主張已逾消費者保護法 7 日猶豫期，或屬於客製化/易腐等合理例外情事',
            '主張商品瑕疵係買受人使用不當造成，出貨時檢驗完好合格',
            '抗辯買受人怠於民法第356條檢查通知義務，視為承認所受領之物',
          ],
          keyEvidences: const [
            '原證一：網路交易訂單明細截圖、發票憑證或信用卡授權紀錄',
            '原證二：收受商品開箱全程未剪輯錄影影像與商品瑕疵特寫照片',
            '原證三：商品廣告文宣、說明書與賣家客服對話時間戳記截圖',
            '原證四：七日內向賣家發送退貨解約通知之通訊文字截圖或存證信函',
          ],
          suggestedTemplateType: DocumentTemplateType.consumerComplaint,
          suggestedActionLabel: '轉為消保爭議申訴與解除契約存證函 (PDF/草稿)',
          suggestedFollowUps: [
            '收受商品後是否在 7 日猶豫期內以書面或文字通知解除契約？',
            '商品是否存在客製化、已拆封個人衛生用品等消保法定例外事由？',
            '是否有完整保存開箱錄影與商品瑕疵部位特寫證據？',
          ],
          statuteDeadline: const LegalStatuteDeadline(
            title: '消保法 7 日無條件解約權 (猶豫期)',
            legalBasis: '消費者保護法第19條（特種交易7日無條件解除權）',
            durationDays: 7,
            urgencyDescription: '通訊交易收受商品後 7 日內，無須說明理由及負擔任何費用得通知解約。',
            warningNote: '請務必於 7 日內以書面或通訊軟體留下具體解約通知紀錄以免失權！',
          ),
          negotiationKit: const NegotiationDefenseKit(
            threeNeverSign: [
              '❌ 絕不接受賣家自訂「拆封一律不得退貨」之違法定型化約款。',
              '❌ 絕不答應賣家扣取顯不相當之「整新費」或要求買家負擔退貨運費。',
              '❌ 絕不私下透過外部未知連結進行二次身分認證或轉帳退款操作。',
            ],
            threeMustAsk: [
              '❓ 依消保法第19條通訊交易解約規範，請問退款帳號確認與退回寄送地址為何？',
              '❓ 商品廣告之特定效能是否具備原廠檢驗報告與保證書？',
              '❓ 若無法達成退款共識，是否接受至行政院消保會或鄉鎮市調解會調解？',
            ],
            recordingLegalityTip:
                '💡 證據保全提醒：將網購下單頁面、商品廣告文案及向賣家反映問題全程截圖保存。',
          ),
        );

      case TaiwanDisputeDomain.constructionAndContract:
        final targetParty = party.isNotEmpty ? party : '設計師/統包工程';
        return LawAssistantDefenseInsight(
          disputeCategory: '裝潢修繕、承攬工程與瑕疵修補爭議',
          detectedAmount: amount,
          detectedCounterparty: targetParty,
          immediateReassurance: '💡 驗收未過切勿草率給付尾款！承攬人依法負有瑕疵擔保責任，定作人有權定相當期限要求進場修補，修補前得暫停撥付尾款。',
          tacticalGoldenPhrase: '「$targetParty您好，現場經查驗有多處未完工及施工瑕疵（已拍照錄影存證）。依民法第493條規定，請於 7 日內提出工期修補計畫並進場修復；若逾期未修繕完畢，我方將委請第三方專業廠商代為修補，相關費用將自工程保留款中逕行扣抵。」',
          defensePoints: const [
            '主張施工瑕疵係定作人指示或材料性質所致，承攬人不負瑕疵擔保責任',
            '抗辯定作人未定相當期限催告修補，不得逕行主張自行修補償還費用或解除契約',
            '主張工作物業已完工點交，定作人瑕疵修補請求權已逾民法第514條1年時效',
          ],
          keyEvidences: const [
            '原證一：裝潢承攬契約書原本、工程估價單及工程圖說規範',
            '原證二：工程各期款匯款水單、請款單及未完成工程項目清冊',
            '原證三：工程施工瑕疵現場高畫質錄影、照片與專業結構/防水檢驗報告',
            '原證四：催告承攬人於期限內修補瑕疵之正式存證信函與通訊紀錄',
          ],
          suggestedTemplateType: DocumentTemplateType.dynamicCustom,
          suggestedActionLabel: '生成裝潢工程瑕疵修補催告與扣款通知函 (PDF)',
          suggestedFollowUps: [
            '工程合約是否有約定各階段驗收標準、完工期限與逾期罰則？',
            '是否已定相當期限書面催告設計師/工班進場進行瑕疵修補？',
            '各期工程款項支付進度與實際施工進度是否相符？',
          ],
          statuteDeadline: const LegalStatuteDeadline(
            title: '承攬工程瑕疵修補與解約權時效（黃金1年）',
            legalBasis: '民法第514條第1項（承攬瑕疵擔保請求權1年時效）',
            durationDays: 365,
            urgencyDescription: '定作人之瑕疵修補請求權、修補費用償還請求權，自發現瑕疵後 1 年間不行使而消滅。',
            warningNote: '發現瑕疵必須即刻寄發存證信函定相當期限催告修補，以免 1 年短期時效罹於消滅！',
          ),
          negotiationKit: const NegotiationDefenseKit(
            threeNeverSign: [
              '❌ 在瑕疵完全修繕驗收通過前，絕不簽署「工程完工總驗收點交單」。',
              '❌ 絕不答應工班口頭承諾而提前支付保留款或尾款。',
              '❌ 絕不簽署承攬人提出之「免除日後一切結構與滲漏水保固責任切結」。',
            ],
            threeMustAsk: [
              '❓ 針對目前未完工及瑕疵項目，承攬人預計進場修補與複驗之確切工期表為何？',
              '❓ 施工所使用建材與原合約報價單品牌規格是否相符，能否出具出廠進貨單據？',
              '❓ 若逾期未進場修補，同意由定作人委託第三方修繕並自工程尾款逕行扣除？',
            ],
            recordingLegalityTip:
                '💡 現場點交自保：工程驗收會勘時，建議全程配戴密錄設備或攝影存證各瑕疵處工班之回應。',
          ),
        );

      case TaiwanDisputeDomain.defamationAndPrivacy:
        return LawAssistantDefenseInsight(
          disputeCategory: '妨害名譽、公然侮辱與個資隱私侵權',
          detectedAmount: amount,
          detectedCounterparty: party.isNotEmpty ? party : '發文者',
          immediateReassurance: '💡 網路抹黑言論隨時會被刪除，請立即全螢幕截圖並錄影存證！妨害名譽刑事告訴期間為知悉起 6 個月，民事侵權請求權為 2 年。',
          tacticalGoldenPhrase: '「台端於公開社群/群組發表針對本人之不實指摘與侮辱性言論，已嚴重貶損本人社會評價，涉犯刑法公然侮辱罪、誹謗罪及民法侵權行為。相關網路電磁紀錄已完整存證，請於24小時內刪除所有侵權內容並公開澄清道歉，否則將依法追究刑事告訴與民事求償。」',
          defensePoints: const [
            '抗辯發表言論屬憲法言論自由保障，係出於善意發表且為可受公評之事',
            '主張陳述事實有相當理由確信其為真實，不具備誹謗之真實惡意',
            '抗辯對話場合屬私密通訊或封閉群組，不符合「公然」或「散布於眾」之構成要件',
          ],
          keyEvidences: const [
            '原證一：社群網路平台、通訊軟體辱罵貼文、留言串或影音內容完整截圖錄影（含網址URL與時間）',
            '原證二：發文者帳號個人主頁資訊、IP 歷程紀錄或實體傳播文宣品',
            '原證三：名譽受損之具體影響證明（就醫紀錄、客戶解約、工作解聘等）',
            '原證四：向平台提出檢舉刪文申請或寄發律師警告函之佐證',
          ],
          suggestedTemplateType: DocumentTemplateType.dynamicCustom,
          suggestedActionLabel: '生成妨害名譽澄清道歉要求函/刑事告訴狀草稿 (PDF)',
          suggestedFollowUps: [
            '誹謗或侮辱之言論發表於何種平台？是否具備「多數人得共見共聞」之公然性？',
            '言論發布至今是否已超過告訴乃論之 6 個月刑事告訴期間？',
            '是否有及時將爭議網頁、貼文留言及個人檔案截圖並保存電子紀錄？',
          ],
          statuteDeadline: const LegalStatuteDeadline(
            title: '妨害名譽刑事告訴期間（告訴乃論6個月）',
            legalBasis: '刑事訴訟法第237條第1項與民法第197條（侵權行為2年時效）',
            durationDays: 180,
            urgencyDescription: '刑法公然侮辱與誹謗罪均為告訴乃論，自知悉犯人之時起「6 個月內」必須遞狀告訴。',
            warningNote: '民事非財產上損害賠償（精神慰撫金）時效為 2 年，切勿延宕證據保全！',
          ),
          negotiationKit: const NegotiationDefenseKit(
            threeNeverSign: [
              '❌ 絕不簽署未載明登報道歉或公開澄清條款之草率和解書。',
              '❌ 絕不簽署放棄追究轉傳、二度散布者民刑事責任之概括免責協議。',
              '❌ 絕不在未諮詢專業意見前，公開發文與對方進行情緒性對罵互相提告。',
            ],
            threeMustAsk: [
              '❓ 發表系爭不實言論前，有無進行合理查證之具體依據與資訊來源？',
              '❓ 是否同意立即刪除全部涉及侵權之貼文、留言並在同版面公開刊登澄清道歉啟事？',
              '❓ 針對名譽貶損所造成之實質損害，具體賠償方案與和解條件為何？',
            ],
            recordingLegalityTip:
                '💡 證據保全提醒：網路抹黑言論隨時可能遭刪除，建議立即使用公證人辦理網頁公證或完整錄影備份存證。',
          ),
        );

      case TaiwanDisputeDomain.familyAndDivorce:
        return LawAssistantDefenseInsight(
          disputeCategory: '婚姻家庭、裁判離婚與親權扶養費爭議',
          detectedAmount: amount,
          detectedCounterparty: party.isNotEmpty ? party : '配偶',
          immediateReassurance: '💡 先保護好自己與未成年孩子！有家暴請立即就醫驗傷並通報 113，切勿在強迫下簽署放棄監護權或拋棄夫妻財產的協議。',
          tacticalGoldenPhrase: '「關於雙方婚姻狀況及未成年子女日後之照顧方案，我方堅持以『未成年子女最佳利益』為最高原則。關於子女監護權、會面交往方式、每月扶養費分攤以及婚後剩餘財產之結算，請以書面理性協商，或共同至法院家事調解庭由調解委員居中協調。」',
          defensePoints: const [
            '抗辯婚姻破綻原因應歸責於他方，依民法第1052條第2項責任較重之一方無權請求離婚',
            '主張未成年子女主要照顧者地位，行使親權最符合子女最佳利益原則',
            '抗辯剩餘財產差額分配請求權顯失公平，依民法第1030條之1聲請法院調整或免除',
          ],
          keyEvidences: const [
            '原證一：戶籍謄本（含現戶全戶與除戶謄本）、結婚登記證明',
            '原證二：家庭暴力驗傷診斷證明書、通報紀錄或保護令裁定',
            '原證三：子女親職照顧日記、學雜費醫療費支出單據及學校親師聯絡簿',
            '原證四：婚後財產與負債清冊（國稅局財產所得清單、銀行存款交易明細及不動產謄本）',
          ],
          suggestedTemplateType: DocumentTemplateType.dynamicCustom,
          suggestedActionLabel: '生成家事親權扶養費與夫妻財產分配請求書狀 (PDF)',
          suggestedFollowUps: [
            '雙方目前是否已分居？分居期間由何方實際照顧未成年子女？',
            '有無家暴、外遇出軌或重大難以維持婚姻之法定破綻事由？',
            '雙方婚後財產差額約略多少？是否有隱匿移轉婚後財產之情事？',
          ],
          statuteDeadline: const LegalStatuteDeadline(
            title: '夫妻剩餘財產分配請求權時效（2年）',
            legalBasis: '民法第1030條之1第5項（自知悉時起2年，法定消滅時效5年）',
            durationDays: 730,
            urgencyDescription: '剩餘財產差額分配請求權，自知有剩餘財產之差額時起，2 年間不行使而消滅。',
            warningNote: '若知悉配偶隱匿移轉婚後財產，應即時聲請法院假扣押或追加計算入婚後財產！',
          ),
          negotiationKit: const NegotiationDefenseKit(
            threeNeverSign: [
              '❌ 絕不簽署放棄未成年子女親權、會面交往權之不平等協議書。',
              '❌ 絕不簽署在財產查核明確前，概括拋棄夫妻剩餘財產分配請求權之約定。',
              '❌ 絕不簽署約定扶養費金額顯著過低或得單方無條件免除之調解條款。',
            ],
            threeMustAsk: [
              '❓ 雙方婚後取得之所有不動產、存款與股票投資清冊何時能完整揭露？',
              '❓ 關於未成年子女未來監護與探視方案，具體照顧時間分配計畫為何？',
              '❓ 每月未成年子女扶養費之分攤比例與匯款專戶如何設定？',
            ],
            recordingLegalityTip:
                '💡 溝通錄音合法性：家庭成員間討論子女探視與財產安排時，身為對話當事人之錄音在台灣家事法庭具證據能力。',
          ),
        );

      case TaiwanDisputeDomain.inheritanceAndWills:
        return LawAssistantDefenseInsight(
          disputeCategory: '遺產繼承、特留分扣減與遺囑效力爭議',
          detectedAmount: amount,
          detectedCounterparty: party.isNotEmpty ? party : '全體繼承人',
          immediateReassurance: '💡 繼承有債務風險！知悉得繼承起 3 個月內可向法院陳報遺產清冊或聲請拋棄繼承；遺產即便有遺囑獨厚一人，法定繼承人仍享有特留分保障！',
          tacticalGoldenPhrase: '「各位繼承人好，被繼承人之遺產分割應由全體法定繼承人共同協議。縱有生前遺囑，依民法第1225條規定，亦不得侵害各繼承人之法定特留分。請依法出具被繼承人完整全國財產清冊及金融遺產明細，共同依法開會協商分割方案。」',
          defensePoints: const [
            '抗辯遺囑不符合民法法定要式（自書、公證、代筆等要件），遺囑依法無效',
            '主張拋棄繼承已逾法定知悉後 3 個月期限，拋棄不生效力',
            '主張特留分受侵害，依民法第1225條行使特留分扣減權',
          ],
          keyEvidences: const [
            '原證一：被繼承人除戶戶籍謄本、全體法定繼承人之現戶謄本及繼承系統表',
            '原證二：系爭遺囑原本或公證書、見證人簽名證明文件',
            '原證三：國稅局被繼承人遺產稅免稅/繳清證明書及全國財產總歸戶清單',
            '原證四：向其他繼承人行使特留分扣減權之存證信函與掛號回執',
          ],
          suggestedTemplateType: DocumentTemplateType.dynamicCustom,
          suggestedActionLabel: '生成遺產繼承分割請求與特留分扣減主張函 (PDF)',
          suggestedFollowUps: [
            '知悉繼承之時起是否已向法院辦理拋棄繼承或陳報遺產清冊？',
            '被繼承人所立遺囑是否具備法定方式？見證人是否符合法定資格？',
            '是否有繼承人於繼承開始前因結婚、分居或營業受有特種贈與需歸扣？',
          ],
          statuteDeadline: const LegalStatuteDeadline(
            title: '拋棄繼承3個月期限與特留分扣減2年時效',
            legalBasis: '民法第1174條（知悉3個月拋棄繼承）與第1146/1225條扣減時效',
            durationDays: 90,
            urgencyDescription: '知悉得繼承之時起「3 個月內」，必須以書面向被繼承人住所地法院聲請拋棄繼承。',
            warningNote: '侵害特留分之扣減權行使時效為 2 年，逾期權利消滅無法再主張回復！',
          ),
          negotiationKit: const NegotiationDefenseKit(
            threeNeverSign: [
              '❌ 絕不簽署在未查明被繼承人負債總額前之「自願清償被繼承人債務切結」。',
              '❌ 絕不簽署未載明全體繼承人完整名冊之遺產分割協議書。',
              '❌ 絕不簽署拋棄特留分扣減權之口頭承諾書。',
            ],
            threeMustAsk: [
              '❓ 遺產清冊（含動產、不動產、股票及銀行帳戶）完整資料何時能提供核對？',
              '❓ 系爭遺囑作成時被繼承人之精神狀態及見證人是否具備法定合法資格？',
              '❓ 遺產稅申報及稅捐繳納由何人負責代繳並自遺產墊付？',
            ],
            recordingLegalityTip:
                '💡 親屬會議自保：家族討論遺產分割協議時，建議保留會議全程錄音與出席簽到紀錄。',
          ),
        );

      case TaiwanDisputeDomain.corporateAndPartnership:
        final targetParty = party.isNotEmpty ? party : '合夥人/負責人';
        return LawAssistantDefenseInsight(
          disputeCategory: '公司股權、合夥拆夥與商務合約爭議',
          detectedAmount: amount,
          detectedCounterparty: targetParty,
          immediateReassurance: '💡 拆夥清算帳目最關鍵！合夥人與股東享有法定查帳權，負責人若私自挪用公款涉犯業務侵占罪，切勿簽署未經查帳之免責協議。',
          tacticalGoldenPhrase: '「$targetParty您好，依民法合夥及公司法規定，本人身為合夥人/出資股東，依法享有查閱公司會計帳簿、營業憑證及存款帳戶明細之法定權限。請於 10 日內提供近兩年度完整財務報表以利核對，並依法啟動${amount.isNotEmpty ? "出資額 $amount" : "出資額"}之結算退夥程序。」',
          defensePoints: const [
            '抗辯公司負責人已盡忠實義務與善良管理人注意義務，不負公司法第23條賠償責任',
            '主張股權轉讓未經合夥人全體同意或違反公司法特別表決程序，轉讓無效',
            '主張商務合約已依約履行交付標的，對造行使解除契約無法律上理由',
          ],
          keyEvidences: const [
            '原證一：公司最新設立/變更登記事項表、公司章程或合夥出資契約原本',
            '原證二：系爭商務合約書、採購單、報價單及驗收受領簽署憑單',
            '原證三：歷次股東會、董事會或合夥人會議事錄及表決簽到簿',
            '原證四：銀行商業往來帳戶明細、出資匯款水單與財務審計查核報告',
          ],
          suggestedTemplateType: DocumentTemplateType.dynamicCustom,
          suggestedActionLabel: '生成商務合約履行催告/股權結算通知函 (PDF)',
          suggestedFollowUps: [
            '雙方合作架構為民法合夥、隱名合夥亦或公司法有限公司/股份有限公司？',
            '退夥、拆夥或轉讓出資額是否具備章程約定或全體合夥人之同意？',
            '公司負責人是否存在挪用公款、利益衝突或違反競業禁止義務之情事？',
          ],
          statuteDeadline: const LegalStatuteDeadline(
            title: '商務契約違約救濟與異議時效',
            legalBasis: '民法第125條（一般請求權15年）與公司法相關程序',
            durationDays: 30,
            urgencyDescription: '商務履行重大違約催告，應定 15 至 30 日相當期限催告補正或履約。',
            warningNote: '股東會決議瑕疵撤銷之訴，必須於決議作成之日起 30 日內向法院起訴！',
          ),
          negotiationKit: const NegotiationDefenseKit(
            threeNeverSign: [
              '❌ 絕不簽署未經合格會計師查核簽證之「概括結算免責協議書」。',
              '❌ 絕不簽署連帶保證個人無限責任之未載明上限商務融資保證條款。',
              '❌ 絕不簽署放棄查閱公司帳簿傳票權利之股東切結書。',
            ],
            threeMustAsk: [
              '❓ 請問合夥或公司最新資產負債表與損益表是否能立即供各出資人查閱？',
              '❓ 退夥結算金之計算基準係以淨值計算或公允市價估值？',
              '❓ 對方負責人是否存在以個人帳戶收受公司貨款之違法情事？',
            ],
            recordingLegalityTip:
                '💡 商務談判存證：股東或合夥人間清算談判，請備齊書面會議記錄並由全體當場簽名確認。',
          ),
        );

      case TaiwanDisputeDomain.intellectualProperty:
        return LawAssistantDefenseInsight(
          disputeCategory: '智慧財產權、商標侵權與營業秘密爭議',
          detectedAmount: amount,
          detectedCounterparty: party.isNotEmpty ? party : '對造侵權人',
          immediateReassurance: '💡 仿冒與抄襲具備急迫性！購買侵權仿冒品並取得發票作為證物，可即時聲請法院裁定定暫時狀態處分勒令下架。',
          tacticalGoldenPhrase: '「敬啟者：查台端/貴公司於各大銷售平台未經授權使用與本人商標註冊證相同或近似之圖樣，已構成商標法第68條侵害商標權。侵權實體證物已完成公證購買，請於文到 3 日內全面停止販售並下架所有侵權商品，否則將依法訴請刑事偵辦並請求懲罰性損害賠償。」',
          defensePoints: const [
            '抗辯使用行為符合著作權法合理使用範圍，未侵害權利人潛在市場價值',
            '主張商標不具備混淆誤認之虞，或屬商標先使用權與善意先使用抗辯',
            '抗辯系爭資訊不符合營業秘密之秘密性、經濟價值及合理保密措施三要件',
          ],
          keyEvidences: const [
            '原證一：智慧財產局商標註冊證、專利證書或著作創作完成公開發表之初稿日期紀錄',
            '原證二：侵權商品實物購買簽單、外觀包裝對比彩色照片及型錄',
            '原證三：保密協議書 (NDA)、員工離職競業禁止與營業秘密資訊保密措施管理規範',
            '原證四：向侵權行為人寄發之排除侵害警告律師函與回執',
          ],
          suggestedTemplateType: DocumentTemplateType.dynamicCustom,
          suggestedActionLabel: '生成智財侵權停止侵害排除律師警告函草稿 (PDF)',
          suggestedFollowUps: [
            '系爭商標或專利是否在台灣依法取得有效登記註冊？',
            '受侵害之營業秘密是否已採取門禁權限、加密等「合理保密措施」？',
            '是否已取得侵權仿冒品之實體販售證據、開立發票與宣傳網址？',
          ],
          statuteDeadline: const LegalStatuteDeadline(
            title: '智慧財產侵權損害賠償時效（2年）',
            legalBasis: '商標法第69條、著作權法第89條之1與營業秘密法第12條',
            durationDays: 730,
            urgencyDescription: '知悉侵權行為人及損害起 2 年內必須提起訴訟，逾期消滅。',
            warningNote: '營業秘密外洩具極高度不可逆性，應即時聲請定暫時狀態處分禁止使用！',
          ),
          negotiationKit: const NegotiationDefenseKit(
            threeNeverSign: [
              '❌ 絕不簽署未釐清技術範圍前之「全面技術移轉或專屬授權協議」。',
              '❌ 絕不簽署承認故意侵害智慧財產權之超額懲罰性賠償承諾書。',
              '❌ 絕不簽署拋棄先前合法在先使用抗辯權利之和解條款。',
            ],
            threeMustAsk: [
              '❓ 請問請求侵害排除之專利請求項對應比對表 (Chart) 為何？',
              '❓ 宣稱受侵害之營業秘密具體範圍與合理保密措施依據何在？',
              '❓ 侵權賠償金額之計算方式係依侵害人所得利益或授權權利金倍數？',
            ],
            recordingLegalityTip:
                '💡 智財取證存證：購買涉嫌侵權商品時，建議進行全程錄影並開立載明品名之統一發票。',
          ),
        );

      case TaiwanDisputeDomain.fraudAndCybercrime:
        return LawAssistantDefenseInsight(
          disputeCategory: '詐欺犯罪、人頭帳戶與網路犯罪爭議',
          detectedAmount: amount,
          detectedCounterparty: '偵辦機關/承辦警員',
          immediateReassurance: '💡 帳戶遭警示切勿再聽信詐團話術繳保證金！立即帶著求職或貸款的完整對話紀錄與寄件單據至派出所報案澄清。',
          tacticalGoldenPhrase: '「警員/檢察官您好，本人係因網路上應徵工作/辦理合法貸款，遭詐騙集團施用詐術騙取金融卡與帳戶資料，本人自始自終不知情且未獲取任何報酬。本件有完整對話截圖歷程、求職廣告與寄件物流單據可證明本人亦為受害者，本人全力配合調查並主動提供全部證據以釐清案情。」',
          defensePoints: const [
            '抗辯提供帳戶係因求職租約遭騙取詐用，欠缺幫助詐欺之不確定故意',
            '主張未曾獲取任何犯罪不法所得或抽成，主觀上完全不知情',
            '抗辯網路電磁紀錄有遭駭客入侵、冒名盜用或惡意偽冒IP之情事',
          ],
          keyEvidences: const [
            '原證一：詐騙求職、貸款、投資假廣告截圖及詐騙集團完整對話歷程',
            '原證二：銀行警示帳戶通報單、遭通報警示公文及交易明細清單',
            '原證三：寄送提款卡/存摺之超商交貨便寄件條碼單據或對話紀錄',
            '原證四：至派出所報案受理案件證明單 (報案三聯單) 影本',
          ],
          suggestedTemplateType: DocumentTemplateType.dynamicCustom,
          suggestedActionLabel: '生成詐欺犯罪刑事報案告訴自白與求償書狀 (PDF)',
          suggestedFollowUps: [
            '金融帳戶是否已遭列為警示帳戶？衍生管制帳戶影響範圍為何？',
            '當初交付提款卡或帳戶資訊之對話紀錄是否有完整截圖備份？',
            '是否已主動至警察局報案並說明遭冒用/騙取情節？',
          ],
          statuteDeadline: const LegalStatuteDeadline(
            title: '警示帳戶申訴與詐欺告訴救濟時效',
            legalBasis: '洗錢防制法、刑法第339條（非告訴乃論）與存款帳戶及其疑似洗錢管制辦法',
            durationDays: 30,
            urgencyDescription: '帳戶遭警示應即刻向開戶銀行及偵辦警察機關提出遭詐騙佐證澄清。',
            warningNote: '刑事詐欺雖屬非告訴乃論，但若涉人頭帳戶應儘速尋求自白澄清以免遭聲押！',
          ),
          negotiationKit: const NegotiationDefenseKit(
            threeNeverSign: [
              '❌ 絕不簽署未向律師諮詢前之警方詢問「自願承認幫助洗錢」筆錄。',
              '❌ 絕不簽署未確認受害人真偽前之私人私下和解賠付協議。',
              '❌ 絕不再聽信任何「繳交解凍保證金才能解除警示」之二次詐騙手法。',
            ],
            threeMustAsk: [
              '❓ 請問目前帳戶被通報警示之案由編號與承辦偵查隊為何？',
              '❓ 檢警調卷宗內被害人遭詐騙之匯入金額與確切匯款時間為何？',
              '❓ 和解方案是否能由承辦檢察官或法院調解庭出具正式和解筆錄？',
            ],
            recordingLegalityTip:
                '💡 警詢自保叮嚀：前往警局製作筆錄時，有權要求委任律師到場陪同辯護以維權益。',
          ),
        );

      case TaiwanDisputeDomain.propertyAndNeighbor:
        final targetParty = party.isNotEmpty ? party : '樓上鄰居';
        return LawAssistantDefenseInsight(
          disputeCategory: '不動產物權、漏水修繕與相鄰管委會爭議',
          detectedAmount: amount,
          detectedCounterparty: targetParty,
          immediateReassurance: '💡 樓上漏水拒開門有法可管！依公寓大廈管理條例第6條，他戶拒不配合修繕時得報請主管機關裁罰或訴請法院命其容忍進入修繕。',
          tacticalGoldenPhrase: '「$targetParty您好，本戶天花板滲漏水經水電專業師傅初步判定係源自貴戶專有浴室管線滲漏。依公寓大廈管理條例第6條規定，住戶因維護修繕有進入他戶必要時不得拒絕。請於 5 日內協調共同會勘抓漏時間；若持續拒絕配合致損害擴大，我方將依法訴請法院命容忍進入並請求全額裝潢損害賠償$amountSuffix。」',
          defensePoints: const [
            '抗辯漏水點屬於大樓共有部分或公共管線，修繕責任應由管委會負擔',
            '抗辯鄰地通行請求顯非必要或非屬最小損害通行方案，拒絕通行',
            '抗辯已盡善良管理人注意義務，漏水非因專有部分改裝管線所致',
          ],
          keyEvidences: const [
            '原證一：建物登記第一類謄本、不動產買賣契約書原本',
            '原證二：台灣土木技師公會或台北市土木建築技術公會之專業漏水鑑定報告',
            '原證三：漏水現場壁癌、剝落、持續滲漏高畫質錄影與紅外線熱顯像儀測漏照片',
            '原證四：寄發要求樓上住戶容忍進入修繕或管委會出面協調之存證信函',
          ],
          suggestedTemplateType: DocumentTemplateType.dynamicCustom,
          suggestedActionLabel: '生成房屋漏水管線修繕責任催告與進入修繕請求函 (PDF)',
          suggestedFollowUps: [
            '漏水位置是否涉及公共垂直主幹管線，亦或專屬於樓上住戶之支管線？',
            '樓上住戶是否拒絕配合水電師傅或專業技師進屋查驗？',
            '公寓大廈管委會是否曾介入協調或留存協調紀錄？',
          ],
          statuteDeadline: const LegalStatuteDeadline(
            title: '相鄰關係排除侵害與損害賠償時效（2年）',
            legalBasis: '民法第197條（侵權行為2年時效）與第767條物上請求權',
            durationDays: 730,
            urgencyDescription: '漏水造成裝潢損壞之侵權損害賠償請求權為 2 年，妨害除去請求權則無消滅時效。',
            warningNote: '依公寓大廈管理條例第6條，他戶拒絕配合維修時得報請主管機關裁罰或訴請法院命容忍進入！',
          ),
          negotiationKit: const NegotiationDefenseKit(
            threeNeverSign: [
              '❌ 絕不簽署未釐清漏水成因前之「各自負擔修繕責任」和解書。',
              '❌ 絕不簽署放棄因漏水造成木地板裝潢霉爛損害求償之切結條款。',
              '❌ 絕不接受未具甲種水電或結構專業證照之非專業人員草率估價扣款。',
            ],
            threeMustAsk: [
              '❓ 雙方是否同意共同委任公正第三方公會技師進行抓漏鑑定？',
              '❓ 若鑑定結果確認為樓上專有管線滲漏，對方是否同意於7日內進場修復？',
              '❓ 漏水修繕施工期間造成之租金損失或裝潢重置費用如何補償？',
            ],
            recordingLegalityTip:
                '💡 抓漏現場存證：邀請鄰居及里長/總幹事共同會勘時，建議拍照、錄影及記錄出勤會勘單。',
          ),
        );

      case TaiwanDisputeDomain.insuranceAndMedical:
        final targetParty = party.isNotEmpty ? party : '保險公司理賠主管/醫療院所';
        return LawAssistantDefenseInsight(
          disputeCategory: '保險理賠爭議與醫療過失損害賠償',
          detectedAmount: amount,
          detectedCounterparty: targetParty,
          immediateReassurance: '💡 保險公司拒賠不代表沒有救！保險金請求權時效為 2 年，可先向保險公司申訴，30 日未獲解決可向金融消費評議中心申請評議。',
          tacticalGoldenPhrase: '「$targetParty您好，關於本件理賠爭端，本人投保已超過保險法第64條解除權之2年除斥期間，且就醫病況與投保告知並無直接因果關係。請於 7 日內重新審查並給付保險金$amountSuffix，若仍遭拒賠，本人將逕向財團法人金融消費評議中心（1998）提出申訴評議並請求遲延利息。」',
          defensePoints: const [
            '抗辯要保人或被保險人投保時違反民法及保險法第64條據實告知義務',
            '抗辯醫療行為符合醫療常規及現有醫療水準，已盡相當注意義務無過失',
            '抗辯事故發生非屬保險承保範圍，或屬於保單明訂除外不保事項',
          ],
          keyEvidences: const [
            '原證一：完整醫療病歷影本（含護理紀錄、手術紀錄單及麻醉同意書）',
            '原證二：人壽/產物保險單保險契約原本與要保書影本',
            '原證三：衛福部醫事審議委員會 (醫審會) 醫療爭議鑑定書或法醫相驗解剖報告',
            '原證四：保險公司出具之理賠拒賠通知書或醫療爭議調處不成立證明書',
          ],
          suggestedTemplateType: DocumentTemplateType.dynamicCustom,
          suggestedActionLabel: '生成保險理賠異議申訴與醫療爭議鑑定申請書 (PDF)',
          suggestedFollowUps: [
            '是否有向醫療機構申請全本完整病歷紀錄與各項檢驗影像報告光碟？',
            '保險公司拒絕理賠之公函所引用之具體保單條款為何？',
            '投保前二年內是否有與系爭疾病相關之就醫紀錄或健康檢查異常？',
          ],
          statuteDeadline: const LegalStatuteDeadline(
            title: '保險金請求權時效（黃金2年）',
            legalBasis: '保險法第65條（由保險契約所生之權利自得為請求之日起2年不行使而消滅）',
            durationDays: 730,
            urgencyDescription: '保險金請求權時效僅 2 年，一旦逾期未起訴或申請評議，保險公司得依法拒賠！',
            warningNote: '保險爭議若不服拒賠，應先向保險公司申訴，申訴後 30 日未獲妥適處理得向金評中心聲請評議。',
          ),
          negotiationKit: const NegotiationDefenseKit(
            threeNeverSign: [
              '❌ 絕不簽署未確認理賠計算基礎前之「打折和解同意書」或「拋棄申訴權切結」。',
              '❌ 絕不簽署醫院未具體說明後遺症成因前之醫療過失免責證明。',
              '❌ 絕不接受保險理賠員私下要求簽字退保並撤回理賠申請。',
            ],
            threeMustAsk: [
              '❓ 保險公司拒賠之具體醫學審查意見依據何在？能否提供特約醫師審查意見書？',
              '❓ 醫療過程中突發狀況是否符合可預見性，有無依常規即時採取急救作為？',
              '❓ 爭議金額是否符合金融消費評議中心一定額度以下對金融機構具拘束力之標準？',
            ],
            recordingLegalityTip:
                '💡 醫療與理賠溝通自保：與醫師進行術後說明會談或與保險理賠主管面談，保留錄音為自身權益關鍵保障。',
          ),
        );

      case TaiwanDisputeDomain.compulsoryEnforcement:
        return LawAssistantDefenseInsight(
          disputeCategory: '民事強制執行、支付命令與保全程序',
          detectedAmount: amount,
          detectedCounterparty: '民事執行處/債權人',
          immediateReassurance: '💡 收到法院支付命令 20 天內無須理由即可聲明異議！扣薪命令依法必須保留債務人每月最低生活費用之 1.2 倍。',
          tacticalGoldenPhrase: '「民事執行處公鑒：關於案號之執行命令，債務人名下受扣押之財產薪資，已嚴重侵害維持最低生活所必需。依強制執行法第122條規定，扣押金額應扣除每人每月最低生活費1.2倍，為此依法具狀聲明異議，請求撤銷超額扣押之命令。」',
          defensePoints: const [
            '抗辯執行名義尚未確定或已清償完畢，提起債務人異議之訴請求撤銷執行',
            '主張扣押薪資或動產已違反維持債務人及其家屬生活所必需之法定比例保障',
            '抗辯債權人行使強制執行已逾執行名義所載請求權之消滅時效',
          ],
          keyEvidences: const [
            '原證一：法院確定判決書、本票裁定裁定書原本及確定證明書',
            '原證二：民事執行處扣押命令、收取命令或移轉命令公函',
            '原證三：債務人戶籍謄本、全戶所得清單及維持生活所必需支出之單據明細',
            '原證四：歷次清償收據、匯款單或向執行法院提出異議狀之收狀戳記',
          ],
          suggestedTemplateType: DocumentTemplateType.dynamicCustom,
          suggestedActionLabel: '生成民事強制執行聲請狀/假扣押保全裁定聲請狀 (PDF)',
          suggestedFollowUps: [
            '目前收到的法院執行名義為何種文書？是否具備確定證明書？',
            '被扣押之財產項目（銀行帳戶、薪資、不動產或動產）為何？',
            '債權債務關係是否已全額清償或曾有實質和解協議？',
          ],
          statuteDeadline: const LegalStatuteDeadline(
            title: '支付命令異議20日與強制執行異議期限',
            legalBasis: '民事訴訟法第516條（20日內異議）與強制執行法第12條聲明異議',
            durationDays: 20,
            urgencyDescription: '收到支付命令必須在 20 日內向核發法院具狀聲明異議，否則確定即得逕行強制執行。',
            warningNote: '收到法院扣押命令若侵害最低生活保障，應於收受命令 10 日內向執行處聲明異議！',
          ),
          negotiationKit: const NegotiationDefenseKit(
            threeNeverSign: [
              '❌ 收到執行命令時，絕不私自簽署放棄最低生活必需保障之全額扣薪協議。',
              '❌ 絕不簽署未確認債權數額之承認全部強制執行標的切結書。',
              '❌ 絕不在未辦理法院提存擔保前擅自隱匿或毀損已被查封之動產。',
            ],
            threeMustAsk: [
              '❓ 請問本件強制執行所依據之執行名義案號與確定日期為何？',
              '❓ 薪資扣押計算是否已依法扣除行政院主計總處公告每人每月最低生活費之1.2倍？',
              '❓ 是否接受向執行處聲請分期清償並啟動債務和解方案？',
            ],
            recordingLegalityTip:
                '💡 查封現場存證：法院書記官與執達員至現場查封動產時，當事人有權在場並核對查封筆錄記載品項。',
          ),
        );

      case TaiwanDisputeDomain.administrativeAndPublic:
        final targetParty = party.isNotEmpty ? party : '行政主管機關';
        return LawAssistantDefenseInsight(
          disputeCategory: '公法救濟、國家賠償與行政訴訟爭議',
          detectedAmount: amount,
          detectedCounterparty: targetParty,
          immediateReassurance: '💡 收到違法行政罰單 30 天內一定要提起訴願！公共設施（如路面坑洞）導致車損人傷，政府機關負客觀無過失賠償責任。',
          tacticalGoldenPhrase: '「$targetParty您好，關於貴機關作成之裁處書，因採樣程序及認定事實有重大瑕疵，本人已於法定30日內備妥正式對照檢驗報告提起訴願；在訴願審理終結前，依行政訴訟程序得申請停止執行，請貴機關依法調卷審查。」',
          defensePoints: const [
            '抗辯公務員執行職務並無故意或過失，亦無怠於執行公法上職務情事',
            '主張原處分具備實質公法上授權依據，裁量處分並無裁量逾越或裁量濫用',
            '抗辯受處分人未於法定 30 日內提起訴願，原處分業已形式確定不可撤銷',
          ],
          keyEvidences: const [
            '原證一：行政機關原處分書、違反行政法規裁處書或檢舉處分函文',
            '原證二：國家賠償請求書副本、行政機關拒絕賠償理由書或協議不成立證明',
            '原證三：公務員違法執行職務、公共設施設置欠缺致生損害之現場照片錄影及報案紀錄',
            '原證四：訴願書副本、訴願機關收狀證明或行政法院起訴狀繕本',
          ],
          suggestedTemplateType: DocumentTemplateType.dynamicCustom,
          suggestedActionLabel: '生成國家賠償請求書/訴願復審申請書 (PDF)',
          suggestedFollowUps: [
            '收受行政處分書之日期為何？是否已逾訴願法第14條之 30 日訴願期間？',
            '國家賠償請求所指涉之公有公共設施或公務員行為是否有明確事證？',
            '是否已先向該管賠償義務機關進行書面協議？',
          ],
          statuteDeadline: const LegalStatuteDeadline(
            title: '訴願救濟30日與國家賠償請求時效（2年）',
            legalBasis: '訴願法第14條（處分達到次日起30日內）與國家賠償法第8條第1項',
            durationDays: 30,
            urgencyDescription: '不服行政處分，必須在處分書達到次日起「30 日內」提起訴願，逾期處分即告確定！',
            warningNote: '國家賠償自知有損害時起，2 年間不行使而消滅；自損害發生時起逾 5 年者亦同。',
          ),
          negotiationKit: const NegotiationDefenseKit(
            threeNeverSign: [
              '❌ 絕不簽署含有「拋棄公法上一切救濟權利」之行政和解書。',
              '❌ 絕不在未確認裁處事實前簽署承認重大違章罰鍰之認定清冊。',
              '❌ 絕不接受機關口頭承諾撤銷處分而放棄在法定30日內正式遞交訴願書。',
            ],
            threeMustAsk: [
              '❓ 請問本件行政處分之具體法規授權依據與裁量基準標準表為何？',
              '❓ 機關作成不利處分前，是否已踐行行政程序法給予當事人陳述意見之機會？',
              '❓ 國家賠償書面協議何時能召開協議會議並提出賠償方案？',
            ],
            recordingLegalityTip:
                '💡 公法陳情存證：向行政機關申請閱覽卷宗或進行陳述意見會時，依法可申請複製卷宗全卷資料。',
          ),
        );

      case TaiwanDisputeDomain.generalCivilAndContract:
        final targetParty = party.isNotEmpty ? party : '相對人';
        return LawAssistantDefenseInsight(
          disputeCategory: '通用民法契約、不當得利與權益催告',
          detectedAmount: amount,
          detectedCounterparty: targetParty,
          immediateReassurance: '💡 未簽正式紙本契約不代表口頭契約無效！LINE 對話紀錄、銀行匯款明細、通話錄音均為民法上的有力契約與金流證據。',
          tacticalGoldenPhrase: '「$targetParty您好，雙方先前約定委託代辦事務及代墊費用，受領利益缺乏法律上原因已構成民法第179條不當得利。金流轉帳水單及通訊對話均已完整截圖備存，請於文到後 7 日內將代墊款項$amountSuffix匯入指定帳戶；若屆期未履行，將依法聲請法院支付命令並追討法定利息，請查照。」',
          defensePoints: const [
            '抗辯未收到任何正式書面催告，清償期限尚未屆滿不負給付遲延責任',
            '主張雙方口頭約定之履行條件與事實不符，要求提出白紙黑字契約證據',
            '主張法律上請求權已罹於法定消滅時效，行使時效抗辯拒絕履行給付',
          ],
          keyEvidences: const [
            '原證一：雙方往來簡訊、LINE、Email 溝通對話紀錄完整截圖',
            '原證二：匯款金流明細、契約書、收據本票或出貨簽收單據',
            '原證三：先前發出之催告紀錄、存證信函或雙掛號郵件收件回條',
            '原證四：主張不當得利或損害賠償之具體財務損益計算憑證',
          ],
          suggestedTemplateType: DocumentTemplateType.depositDemand,
          suggestedActionLabel: '一鍵轉為正式存證信函/債權履行催告書 (PDF)',
          suggestedFollowUps: [
            '雙方當初是否有簽署書面契約或留存通訊紀錄？',
            '目前要求給付或履行的具體金額/標的為何？',
            '先前是否曾向對方進行過口頭或書面催告？',
          ],
          statuteDeadline: const LegalStatuteDeadline(
            title: '民事催告與異議法定時效',
            legalBasis: '民事訴訟法第516條（支付命令異議20天）與民法第125條',
            durationDays: 20,
            urgencyDescription: '若收到法院支付命令，必須於送達後「20 日內」提出異議，否則確定即等同勝訴判決可被強制執行！',
            warningNote: '把握 20 日黃金異議期，無須附理由向法院遞送異議狀即可使命令失效。',
          ),
          negotiationKit: const NegotiationDefenseKit(
            threeNeverSign: [
              '❌ 絕不簽署未確認債權真實性之「本票」或「自願承擔債務切結書」。',
              '❌ 絕不在未經法律專業審核前簽字同意「願意接受強制執行」。',
              '❌ 絕不簽署拋棄時效抗辯之口頭或書面聲明。',
            ],
            threeMustAsk: [
              '❓ 請問請求給付之具體契約依據與債權憑證為何？',
              '❓ 催告履行期限為何？能否提供正式對帳單？',
              '❓ 是否同意至地方調解委員會以客觀第三方公證和解？',
            ],
            recordingLegalityTip:
                '💡 面談自保提醒：與相對人進行債務或權益交涉時，留存雙方往來對話紀錄作為日後佐證。',
          ),
        );
    }
  }

  /// 從使用者口語輸入中動態抽取金額（例如：35,000元、50萬、八萬元）
  static String _extractAmountFromText(String text) {
    final regex = RegExp(r'(\d+[\d,]*\s*(?:萬|千)?元|[一二三四五六七八九十百千萬]+\s*元|\d+[\d,]*\s*萬)');
    final match = regex.firstMatch(text);
    return match != null ? match.group(0)!.trim() : '';
  }

  /// 從使用者口語輸入中動態抽取相對人稱謂
  static String _extractCounterpartyFromText(String text, TaiwanDisputeDomain domain) {
    final lower = text.toLowerCase();
    if (lower.contains('房東')) return '房東';
    if (lower.contains('房客')) return '房客';
    if (lower.contains('建商')) return '建商';
    if (lower.contains('統包') || lower.contains('設計師') || lower.contains('工班')) return '統包工程/設計師';
    if (lower.contains('老闆') || lower.contains('人資') || lower.contains('主管') || lower.contains('公司')) return '公司主管/人資';
    if (lower.contains('賣家') || lower.contains('店家') || lower.contains('廠商')) return '賣家';
    if (lower.contains('合夥人') || lower.contains('股東')) return '合夥人/股東';
    if (lower.contains('配偶') || lower.contains('先生') || lower.contains('太太') || lower.contains('前夫') || lower.contains('前妻')) return '配偶';
    if (lower.contains('鄰居') || lower.contains('樓上') || lower.contains('管委會')) return '樓上鄰居/管委會';
    if (lower.contains('保險公司') || lower.contains('理賠員')) return '保險公司理賠部';
    return '';
  }

  Map<String, dynamic> toJson() => {
        'disputeCategory': disputeCategory,
        'defensePoints': defensePoints,
        'keyEvidences': keyEvidences,
        'suggestedTemplateType': suggestedTemplateType.name,
        'suggestedActionLabel': suggestedActionLabel,
        'extractedFacts': extractedFacts,
        'suggestedFollowUps': suggestedFollowUps,
        if (statuteDeadline != null)
          'statuteDeadline': statuteDeadline!.toJson(),
        if (negotiationKit != null)
          'negotiationKit': negotiationKit!.toJson(),
        'immediateReassurance': immediateReassurance,
        'tacticalGoldenPhrase': tacticalGoldenPhrase,
        'detectedAmount': detectedAmount,
        'detectedCounterparty': detectedCounterparty,
      };

  factory LawAssistantDefenseInsight.fromJson(Map<String, dynamic> json) {
    return LawAssistantDefenseInsight(
      disputeCategory: json['disputeCategory'] as String? ?? '民事糾紛',
      defensePoints: (json['defensePoints'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
      keyEvidences: (json['keyEvidences'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
      suggestedTemplateType: DocumentTemplateType.values.firstWhere(
        (t) => t.name == json['suggestedTemplateType'],
        orElse: () => DocumentTemplateType.depositDemand,
      ),
      suggestedActionLabel: json['suggestedActionLabel'] as String? ??
          '轉為正式存證信函 (PDF)',
      extractedFacts: json['extractedFacts'] as String? ?? '',
      suggestedFollowUps: (json['suggestedFollowUps'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
      statuteDeadline: json['statuteDeadline'] is Map<String, dynamic>
          ? LegalStatuteDeadline.fromJson(
              json['statuteDeadline'] as Map<String, dynamic>)
          : null,
      negotiationKit: json['negotiationKit'] is Map<String, dynamic>
          ? NegotiationDefenseKit.fromJson(
              json['negotiationKit'] as Map<String, dynamic>)
          : null,
      immediateReassurance: json['immediateReassurance'] as String? ?? '',
      tacticalGoldenPhrase: json['tacticalGoldenPhrase'] as String? ?? '',
      detectedAmount: json['detectedAmount'] as String? ?? '',
      detectedCounterparty: json['detectedCounterparty'] as String? ?? '',
    );
  }
}

/// 小法助訊息角色 (教學型註解：定義訊息發送者)
enum LawAssistantMessageRole {
  user,
  assistant,
}

/// 來源類型 (教學型註解：定義引用的來源為官方或其他)
enum LawAssistantCitationSourceType {
  official,
  other,
}

/// 小法助引用來源 (教學型註解：儲存引用的標題與網址等資訊)
class LawAssistantCitation {
  const LawAssistantCitation({
    required this.title,
    required this.sourceType,
    this.url,
    this.updatedAt,
  });

  final String title;
  final LawAssistantCitationSourceType sourceType;
  final String? url;
  final DateTime? updatedAt;

  SourceCitationViewData toViewData() {
    return SourceCitationViewData(
      title: title,
      sourceType: sourceType.name == 'official' ? '官方資料' : '其他資料',
      url: url ?? '',
      updatedAt: updatedAt,
    );
  }

  Map<String, dynamic> toJson() => {
        'title': title,
        'sourceType': sourceType.name,
        if (url != null) 'url': url,
        if (updatedAt != null) 'updatedAt': updatedAt!.toIso8601String(),
      };

  factory LawAssistantCitation.fromJson(Map<String, dynamic> json) {
    final rawSourceType = json['sourceType']?.toString().toLowerCase();
    final sourceType = (rawSourceType == 'official' || rawSourceType == 'statute')
        ? LawAssistantCitationSourceType.official
        : LawAssistantCitationSourceType.other;
    return LawAssistantCitation(
      title: json['title'] as String? ?? '',
      sourceType: sourceType,
      url: json['url'] as String?,
      updatedAt: json['updatedAt'] != null
          ? DateTime.tryParse(json['updatedAt'].toString())
          : null,
    );
  }
}

/// 結構化法律建議與解答 (教學型註解：儲存小法助結構化的分析結果)
class LawAssistantAnswer {
  const LawAssistantAnswer({
    required this.problemDirection,
    required this.relatedContent,
    required this.nextStep,
    required this.evidenceNeeded,
    required this.possibleLegalIssues,
    required this.recommendedActions,
    required this.disclaimer,
  });

  final String problemDirection;
  final String relatedContent;
  final String nextStep;
  final String evidenceNeeded;
  final String possibleLegalIssues;
  final String recommendedActions;
  final String disclaimer;

  Map<String, dynamic> toJson() => {
        'problemDirection': problemDirection,
        'relatedContent': relatedContent,
        'nextStep': nextStep,
        'evidenceNeeded': evidenceNeeded,
        'possibleLegalIssues': possibleLegalIssues,
        'recommendedActions': recommendedActions,
        'disclaimer': disclaimer,
      };

  factory LawAssistantAnswer.fromJson(Map<String, dynamic> json) {
    return LawAssistantAnswer(
      problemDirection: json['problemDirection'] as String? ?? '',
      relatedContent: json['relatedContent'] as String? ?? '',
      nextStep: json['nextStep'] as String? ?? '',
      evidenceNeeded: json['evidenceNeeded'] as String? ?? '',
      possibleLegalIssues: json['possibleLegalIssues'] as String? ?? '',
      recommendedActions: json['recommendedActions'] as String? ?? '',
      disclaimer: json['disclaimer'] as String? ?? '',
    );
  }
}

/// 小法助聊天訊息 (教學型註解：儲存單則聊天記錄)
class LawAssistantMessage {
  const LawAssistantMessage({
    required this.id,
    required this.role,
    required this.content,
    required this.createdAt,
    this.answer,
    this.citations,
    this.warningText,
    this.insight,
  });

  final String id;
  final LawAssistantMessageRole role;
  final String content;
  final DateTime createdAt;
  final LawAssistantAnswer? answer;
  final List<LawAssistantCitation>? citations;
  final String? warningText;
  final LawAssistantDefenseInsight? insight;

  Map<String, dynamic> toJson() => {
        'id': id,
        'role': role.name,
        'content': content,
        'createdAt': createdAt.toIso8601String(),
        if (answer != null) 'answer': answer!.toJson(),
        if (citations != null)
          'citations': citations!.map((c) => c.toJson()).toList(),
        if (warningText != null) 'warningText': warningText,
        if (insight != null) 'insight': insight!.toJson(),
      };

  factory LawAssistantMessage.fromJson(Map<String, dynamic> json) {
    return LawAssistantMessage(
      id: json['id'] as String? ?? '',
      role: json['role'] == 'user'
          ? LawAssistantMessageRole.user
          : LawAssistantMessageRole.assistant,
      content: json['content'] as String? ?? '',
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString()) ?? DateTime.now()
          : DateTime.now(),
      answer: json['answer'] is Map<String, dynamic>
          ? LawAssistantAnswer.fromJson(json['answer'] as Map<String, dynamic>)
          : null,
      citations: (json['citations'] as List<dynamic>?)
          ?.map((c) => LawAssistantCitation.fromJson(c as Map<String, dynamic>))
          .toList(),
      warningText: json['warningText'] as String?,
      insight: json['insight'] is Map<String, dynamic>
          ? LawAssistantDefenseInsight.fromJson(
              json['insight'] as Map<String, dynamic>)
          : null,
    );
  }
}

/// 小法助對話工作階段 (教學型註解：儲存完整對話串資訊)
class LawAssistantConversation {
  const LawAssistantConversation({
    required this.id,
    required this.title,
    required this.preview,
    required this.updatedAt,
    this.categoryLabel,
    required this.isGuest,
    required this.isMock,
    this.sourceCitations,
    required this.messages,
  });

  final String id;
  final String title;
  final String preview;
  final DateTime updatedAt;
  final String? categoryLabel;
  final bool isGuest;
  final bool isMock;
  final List<LawAssistantCitation>? sourceCitations;
  final List<LawAssistantMessage> messages;

  LawAssistantConversation copyWith({
    String? id,
    String? title,
    String? preview,
    DateTime? updatedAt,
    String? categoryLabel,
    bool? isGuest,
    bool? isMock,
    List<LawAssistantCitation>? sourceCitations,
    List<LawAssistantMessage>? messages,
  }) {
    return LawAssistantConversation(
      id: id ?? this.id,
      title: title ?? this.title,
      preview: preview ?? this.preview,
      updatedAt: updatedAt ?? this.updatedAt,
      categoryLabel: categoryLabel ?? this.categoryLabel,
      isGuest: isGuest ?? this.isGuest,
      isMock: isMock ?? this.isMock,
      sourceCitations: sourceCitations ?? this.sourceCitations,
      messages: messages ?? this.messages,
    );
  }

  factory LawAssistantConversation.fromJson(Map<String, dynamic> json) {
    return LawAssistantConversation(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      preview: json['preview'] as String? ?? '',
      updatedAt: json['updatedAt'] != null
          ? DateTime.tryParse(json['updatedAt'].toString()) ?? DateTime.now()
          : DateTime.now(),
      categoryLabel: json['categoryLabel'] as String?,
      isGuest: json['isGuest'] as bool? ?? false,
      isMock: json['isMock'] as bool? ?? false,
      sourceCitations: (json['sourceCitations'] as List<dynamic>?)
          ?.map((c) => LawAssistantCitation.fromJson(c as Map<String, dynamic>))
          .toList(),
      messages: (json['messages'] as List<dynamic>?)
              ?.map((m) =>
                  LawAssistantMessage.fromJson(m as Map<String, dynamic>))
              .toList() ??
          const [],
    );
  }
}

/// 小法助串流對話區塊 (教學型註解：用於串流接收對話的內容)
class LawAssistantStreamChunk {
  const LawAssistantStreamChunk({
    required this.textChunk,
    this.isFinished = false,
    this.citations,
    this.fullAnswer,
  });

  final String textChunk;
  final bool? isFinished;
  final List<LawAssistantCitation>? citations;
  final LawAssistantAnswer? fullAnswer;

  factory LawAssistantStreamChunk.fromJson(Map<String, dynamic> json) {
    return LawAssistantStreamChunk(
      textChunk: json['textChunk'] as String? ?? '',
      isFinished: json['isFinished'] as bool? ?? false,
      citations: (json['citations'] as List<dynamic>?)
          ?.map((c) => LawAssistantCitation.fromJson(c as Map<String, dynamic>))
          .toList(),
      fullAnswer: json['fullAnswer'] is Map<String, dynamic>
          ? LawAssistantAnswer.fromJson(
              json['fullAnswer'] as Map<String, dynamic>)
          : null,
    );
  }
}
