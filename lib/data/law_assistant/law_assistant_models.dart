import 'package:preamble/components/shared/mvp_state_widgets.dart';
import 'package:preamble/data/documents/document_models.dart';

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
        recordingLegalityTip: json['recordingLegalityTip'] as String? ?? '',
      );
}

/// 攻防洞察與人性化安全指引模型
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

  factory LawAssistantDefenseInsight.fromContext({
    required String text,
  }) {
    final lower = text.toLowerCase();

    if (lower.contains('租') || lower.contains('押金') || lower.contains('房東') || lower.contains('房客')) {
      return const LawAssistantDefenseInsight(
        disputeCategory: '租賃與押金返還爭議',
        defensePoints: [
          '主張房屋有非自然耗損或污損，要求由押金抵扣修繕清潔費',
          '主張提前終止租約需扣除 1 個月租金作為違約補償',
          '主張退租點交尚未完成或鑰匙未歸還，衍生相當於租金之不當得利',
        ],
        keyEvidences: [
          '原證一：租賃契約書原本（確認押金約定與修繕特約條款）',
          '原證二：退租交屋當日現場全景錄影與照片（需含拍攝時間）',
          '原證三：押金匯款單據與歷次水電規費結清收據',
          '原證四：向房東催告返還押金之 LINE 完整對話紀錄截圖',
        ],
        suggestedTemplateType: DocumentTemplateType.rentalDepositNegotiation,
        suggestedActionLabel: '一鍵轉為租屋押金協商函 (PDF/草稿)',
        suggestedFollowUps: [
          '退租交屋當日是否有拍照存證？',
          '房東主張扣抵的押金金額是多少？',
          '雙方租約是否有約定修繕責任歸屬？',
        ],
        statuteDeadline: LegalStatuteDeadline(
          title: '押金返還與損害賠償時效',
          legalBasis: '民法第456條（租賃損害賠償請求權6個月）',
          durationDays: 180,
          urgencyDescription: '交還租賃物後 6 個月內為損害賠償請求黃金時效，逾期權利消滅。',
          warningNote: '若房東拒退，請把握 6 個月內向消保官申訴或聲請法院調解。',
        ),
        negotiationKit: NegotiationDefenseKit(
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
    } else if (lower.contains('車禍') || lower.contains('撞') || lower.contains('肇事') || lower.contains('追撞') || lower.contains('擦撞')) {
      return const LawAssistantDefenseInsight(
        disputeCategory: '交通事故與損害賠償',
        defensePoints: [
          '主張民法第 217 條「與有過失」，要求過失相抵降低賠償比例',
          '抗辯車輛維修零件費用過高，依法應按出廠年份計算「零件折舊」',
          '抗辯醫療支出非必要費用或工作損失缺乏正式薪資扣繳證明',
        ],
        keyEvidences: [
          '原證一：道路交通事故初步分析研判表 (初判表) 與現場圖',
          '原證二：車輛原廠估價單、受損部位彩色照片與維修發票',
          '原證三：公立/區域醫院診斷證明書（載明需休養天數）與醫療單據',
          '原證四：請假工作損失之薪資扣繳憑單或銀行薪轉明細',
        ],
        suggestedTemplateType: DocumentTemplateType.carAccidentChecklist,
        suggestedActionLabel: '生成車禍求償與和解清單 (PDF/草稿)',
        suggestedFollowUps: [
          '目前事故是否已取得警方初判表？',
          '事故當下是否有申請車輛保險理賠派員？',
          '受傷人員是否已有診斷證明書載明休養天數？',
        ],
        statuteDeadline: LegalStatuteDeadline(
          title: '過失傷害告訴時效（黃金6個月）',
          legalBasis: '刑事訴訟法第237條（告訴乃論6個月告訴期間）',
          durationDays: 180,
          urgencyDescription: '涉及人傷之過失傷害告訴，自知悉肇事人之日起「6 個月內」必須提出。',
          warningNote: '若和解談判拖延超過 6 個月，將永遠喪失以刑事提告以刑逼民之權利！',
        ),
        negotiationKit: NegotiationDefenseKit(
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
    } else if (lower.contains('薪') || lower.contains('加班') || lower.contains('資遣') || lower.contains('離職') || lower.contains('老闆') || lower.contains('公司') || lower.contains('勞基法')) {
      return const LawAssistantDefenseInsight(
        disputeCategory: '勞資爭議與工資/資遣費請求',
        defensePoints: [
          '主張職務性質屬責任制或管理職，不適用勞動基準法加班費規定',
          '主張勞工係自願離職，無須發給資遣費或非自願離職證明書',
          '主張工作表現不能勝任或違反勞動契約/工作規則，予以懲戒解僱',
        ],
        keyEvidences: [
          '原證一：完整出勤打卡紀錄、門禁刷卡紀錄或工作系統工時截圖',
          '原證二：每月薪資明細表 (Pay Slip) 與銀行薪轉帳戶存摺影本',
          '原證三：非上班時間主管交辦工作之通訊軟體截圖與電子郵件',
          '原證四：勞動契約書、考核紀錄或資遣通知文件',
        ],
        suggestedTemplateType: DocumentTemplateType.laborDisputeMessage,
        suggestedActionLabel: '一鍵轉為勞資爭議溝通函 (PDF/草稿)',
        suggestedFollowUps: [
          '是否有完整留存近半年的出勤打卡紀錄？',
          '公司是否有出具非自願離職證明書？',
          '通訊軟體交辦公務是否有保留確切時間截圖？',
        ],
        statuteDeadline: LegalStatuteDeadline(
          title: '勞資爭議救濟與工資請求時效',
          legalBasis: '民法第126條（工資請求權5年）與勞資爭議處理法',
          durationDays: 30,
          urgencyDescription: '遭違法解僱或逼退時，建議於 30 日內向勞工局申請勞資爭議調解。',
          warningNote: '若欲申請失業給付，應於非自願離職退保次日起 2 年內向公立就服機構辦理。',
        ),
        negotiationKit: NegotiationDefenseKit(
          threeNeverSign: [
            '❌ 絕不在未給付資遣費與非自願證明前，簽署「自願離職申請書」。',
            '❌ 絕不簽署「自願放棄加班費與特休未休工資補償」之免責切結。',
            '❌ 絕不簽署懲戒性解僱之過失認罪書。',
          ],
          threeMustAsk: [
            '❓ 請問資遣理由是依勞基法第 11 條哪一款？非自願離職證明何時開立？',
            '❓ 依勞基法規定，特休未休折算工資與預告工資是否如期於離職日發放？',
            '❓ 請出示公司向勞動部核備之責任制工作者約定書證明。',
          ],
          recordingLegalityTip:
            '💡 面談自保提醒：與人資或主管進行資遣面談時，身為當事人可合法開啟手機錄音，記錄資遣理由與開立證明承諾。',
        ),
      );
    } else if (lower.contains('退貨') || lower.contains('買') || lower.contains('瑕疵') || lower.contains('詐騙') || lower.contains('消保') || lower.contains('網購')) {
      return const LawAssistantDefenseInsight(
        disputeCategory: '消費爭議與瑕疵擔保',
        defensePoints: [
          '主張已逾消費者保護法 7 日鑑賞期，或屬於客製化等合理例外情事',
          '主張商品瑕疵係買受人使用不當造成，出貨檢驗無異常',
          '抗辯定型化契約條款已明訂「商品售出概不退換」',
        ],
        keyEvidences: [
          '原證一：網路訂單明細截圖、發票或信用卡金流刷卡簽單',
          '原證二：開箱全程未剪輯錄影檔案與瑕疵部位特寫照片',
          '原證三：與商家線上客服反映問題之完整對話時間戳記紀錄',
        ],
        suggestedTemplateType: DocumentTemplateType.consumerComplaint,
        suggestedActionLabel: '轉為消費爭議申訴函 (PDF/草稿)',
        suggestedFollowUps: [
          '收到商品後是否在 7 日猶豫期內提出退換申請？',
          '是否有開箱錄影或瑕疵特寫照片？',
          '賣家目前拒絕退換貨的具體理由為何？',
        ],
        statuteDeadline: LegalStatuteDeadline(
          title: '消保法 7 日無條件解約權 (猶豫期)',
          legalBasis: '消費者保護法第19條（通訊交易7日解約權）',
          durationDays: 7,
          urgencyDescription: '網購收受商品後「7 日內」，無須說明理由及負擔任何費用得通知解約退貨。',
          warningNote: '請務必於 7 日內以書面或通訊軟體留下具體解約通知紀錄！',
        ),
        negotiationKit: NegotiationDefenseKit(
          threeNeverSign: [
            '❌ 絕不簽署或同意賣家違法自訂之「拆封一律不得退貨」不合理條款。',
            '❌ 絕不接受賣家要求「退貨需自行負擔跨國運費與整新費」之無端扣款。',
            '❌ 絕不私下透過不明非官方連結進行二次退款轉帳。',
          ],
          threeMustAsk: [
            '❓ 依消保法第 19 條通訊交易規範，請問退貨退款流程為何？',
            '❓ 請問商品退回地址與收件人姓名電話為何？',
            '❓ 若逾期未處理，我將直接向行政院消保會（1950）提起正式申訴。',
          ],
          recordingLegalityTip:
            '💡 證據保全提醒：將網購退貨申請畫面與商家客服對話全程截圖保存。',
        ),
      );
    } else {
      return const LawAssistantDefenseInsight(
        disputeCategory: '民事權益與催告通知',
        defensePoints: [
          '抗辯未收到任何正式書面催告，清償期限尚未屆滿不負給付遲延責任',
          '主張雙方口頭約定之履行條件與事實不符，要求提出白紙黑字證據',
          '主張法律上請求權已罹於法定消滅時效，拒絕履行給付義務',
        ],
        keyEvidences: [
          '原證一：雙方往來簡訊、LINE、Email 溝通對話紀錄完整截圖',
          '原證二：匯款金流明細、契約書、收據本票或出貨簽收單據',
          '原證三：先前發出之催告紀錄、存證信函或雙掛號郵件收件回條',
        ],
        suggestedTemplateType: DocumentTemplateType.depositDemand,
        suggestedActionLabel: '一鍵轉為正式存證信函草稿 (PDF)',
        suggestedFollowUps: [
          '雙方當初是否有簽署書面契約或留存通訊紀錄？',
          '目前要求給付或履行的具體金額/標的為何？',
          '先前是否曾向對方進行過口頭或書面催告？',
        ],
        statuteDeadline: LegalStatuteDeadline(
          title: '民事催告與異議法定時效',
          legalBasis: '民事訴訟法第516條（支付命令異議20天）',
          durationDays: 20,
          urgencyDescription: '若收到法院支付命令，必須於送達後「20 日內」提出異議，否則確定即等同勝訴判決可被強制執行！',
          warningNote: '把握 20 日黃金異議期，無須附理由向法院遞送異議狀即可使命令失效。',
        ),
        negotiationKit: NegotiationDefenseKit(
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
    );
  }
}
