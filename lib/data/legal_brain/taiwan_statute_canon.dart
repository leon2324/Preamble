/// 緒言 Preamble 臺灣核心實體與程序法規典籍庫 (Taiwan Statute Canon)
///
/// 涵蓋租賃糾紛、車禍侵權、消費借貸、勞資爭議、消費者保護、承攬瑕疵、名譽侵害與督促程序。
/// 每筆條文均包含：官方條文、白話意旨、構成要件、法律效果、消滅時效、實務攻防與舉證清冊。
class TaiwanStatuteCanonEntry {
  const TaiwanStatuteCanonEntry({
    required this.statuteId,
    required this.lawName,
    required this.articleNumber,
    required this.officialText,
    required this.plainSummary,
    required this.constituentElements,
    required this.legalEffects,
    required this.limitationPeriodYears,
    required this.limitationPeriodDescription,
    required this.defenseAndEvidenceGuide,
    required this.disputeCategories,
    this.relatedPrecedents = const [],
  });

  /// 條文唯一代碼 (e.g. civil_184_1, civil_423, labor_14)
  final String statuteId;

  /// 法規名稱 (e.g. 《民法》, 《勞動基準法》, 《租賃住宅市場發展及管理條例》)
  final String lawName;

  /// 條號 (e.g. 第 184 條第 1 項前段)
  final String articleNumber;

  /// 全國法規資料庫官方原始條文
  final String officialText;

  /// 白話法律意旨（供民眾與 AI 理解）
  final String plainSummary;

  /// 法定構成要件（法學三段論法大前提依據）
  final List<String> constituentElements;

  /// 法律效果（請求權與救濟手段）
  final List<String> legalEffects;

  /// 消滅時效或除斥期間（年數，0 表示無特別或除斥期間）
  final double limitationPeriodYears;

  /// 時效起算與說明
  final String limitationPeriodDescription;

  /// 實務攻防重點與必備佐證清冊
  final List<String> defenseAndEvidenceGuide;

  /// 關聯糾紛領域
  final List<String> disputeCategories;

  /// 司法院著名裁判字號或判例要旨
  final List<String> relatedPrecedents;

  /// 完整引用標題 (e.g. 《民法》第 184 條第 1 項前段)
  String get fullCitation => '$lawName $articleNumber';

  Map<String, dynamic> toJson() => {
        'statuteId': statuteId,
        'lawName': lawName,
        'articleNumber': articleNumber,
        'officialText': officialText,
        'plainSummary': plainSummary,
        'constituentElements': constituentElements,
        'legalEffects': legalEffects,
        'limitationPeriodYears': limitationPeriodYears,
        'limitationPeriodDescription': limitationPeriodDescription,
        'defenseAndEvidenceGuide': defenseAndEvidenceGuide,
        'disputeCategories': disputeCategories,
        if (relatedPrecedents.isNotEmpty) 'relatedPrecedents': relatedPrecedents,
      };

  factory TaiwanStatuteCanonEntry.fromJson(Map<String, dynamic> json) =>
      TaiwanStatuteCanonEntry(
        statuteId: json['statuteId'] as String? ?? '',
        lawName: json['lawName'] as String? ?? '',
        articleNumber: json['articleNumber'] as String? ?? '',
        officialText: json['officialText'] as String? ?? '',
        plainSummary: json['plainSummary'] as String? ?? '',
        constituentElements: (json['constituentElements'] as List<dynamic>?)
                ?.map((e) => e.toString())
                .toList() ??
            const [],
        legalEffects: (json['legalEffects'] as List<dynamic>?)
                ?.map((e) => e.toString())
                .toList() ??
            const [],
        limitationPeriodYears:
            (json['limitationPeriodYears'] as num?)?.toDouble() ?? 0.0,
        limitationPeriodDescription:
            json['limitationPeriodDescription'] as String? ?? '',
        defenseAndEvidenceGuide:
            (json['defenseAndEvidenceGuide'] as List<dynamic>?)
                    ?.map((e) => e.toString())
                    .toList() ??
                const [],
        disputeCategories: (json['disputeCategories'] as List<dynamic>?)
                ?.map((e) => e.toString())
                .toList() ??
            const [],
        relatedPrecedents: (json['relatedPrecedents'] as List<dynamic>?)
                ?.map((e) => e.toString())
                .toList() ??
            const [],
      );
}

/// 臺灣法規典籍庫檢索中心
class TaiwanStatuteCanon {
  const TaiwanStatuteCanon._();

  /// 典籍庫收錄之高頻生活法律核心條文
  static const List<TaiwanStatuteCanonEntry> entries = [
    // -------------------------------------------------------------
    // 一、租賃住宅糾紛 (Lease & Rental Disputes)
    // -------------------------------------------------------------
    TaiwanStatuteCanonEntry(
      statuteId: 'rental_act_34',
      lawName: '《租賃住宅市場發展及管理條例》',
      articleNumber: '第 34 條',
      officialText:
          '租賃契約租金之約定，除法律另有規定外，不得逾出租人土地及建築物申報總價額年息百分之十。押金之數額，不得超過二個月之租金總額。出租人於承租人交還房屋時，應返還押金或抵充後之剩餘押金。',
      plainSummary: '房東收取的押金上限最高為 2 個月租金；在房客租約期滿返還房屋時，房東扣除積欠水電租金後，應立即返還剩餘押金。',
      constituentElements: [
        '雙方具備合法房屋租賃契約關係',
        '承租人已依約繳納押租保證金',
        '租賃契約關係已屆期、合意終止或合法終止',
        '承租人已依約完成房屋騰空點交返還',
      ],
      legalEffects: [
        '出租人應於房屋返還時無息退還押租保證金',
        '出租人無權藉故拖延或無合理單據扣留押金',
        '逾期得加計法定遲延利息（週年利率 5%）',
      ],
      limitationPeriodYears: 15.0,
      limitationPeriodDescription: '一般債權消滅時效 15 年（民法第 125 條），自租約終止返還房屋起算。',
      defenseAndEvidenceGuide: [
        '租賃契約書原本或電子影本（確認租期與押金金額）',
        '押金轉帳匯款紀錄或房東簽收聯',
        '房屋退租點交現況錄影、照片（證明無人為毀損）',
        '結算水電瓦斯費單據收執聯',
        '向房東催告返還押金之通訊軟體 (LINE) 對話紀錄截圖',
      ],
      disputeCategories: ['租賃糾紛', '押金返還', '租屋修繕'],
      relatedPrecedents: ['最高法院 83 年台上字第 2108 號判例（押租金返還請求權之性質）'],
    ),
    TaiwanStatuteCanonEntry(
      statuteId: 'civil_423',
      lawName: '《民法》',
      articleNumber: '第 423 條',
      officialText:
          '出租人應以合於所約定使用收益之租賃物，交付承租人，並應於租賃關係存續中，保持其合於約定使用收益之狀態。',
      plainSummary: '房東有義務在租約期間內，維持房屋處於正常可居住、使用的良好狀態（包含結構無安全疑慮、不漏水）。',
      constituentElements: [
        '租賃契約有效存續中',
        '租賃物（如天花板漏水、熱水器故障、電路失靈）發生妨礙通常居住之瑕疵',
        '該瑕疵非因承租人故意或重大過失所致',
      ],
      legalEffects: [
        '出租人負有修繕保持義務',
        '承租人得催告出租人於相當期限內修繕',
      ],
      limitationPeriodYears: 15.0,
      limitationPeriodDescription: '債務不履行請求權消滅時效 15 年。',
      defenseAndEvidenceGuide: [
        '瑕疵受損部位清晰照片與錄影（如漏水滴水、壁癌滲水）',
        '通知房東修繕之簡訊、對話截圖與時間戳記',
      ],
      disputeCategories: ['租賃糾紛', '房屋修繕', '漏水修繕'],
    ),
    TaiwanStatuteCanonEntry(
      statuteId: 'civil_430',
      lawName: '《民法》',
      articleNumber: '第 430 條',
      officialText:
          '租賃物有修繕之必要，應由出租人負擔者，承租人得定相當期限，催告出租人修繕，如出租人於其期限內不為修繕者，承租人得終止契約或自行修繕而請求償還其費用或於租金中扣除之。',
      plainSummary: '房屋有修繕必要時，房客可給房東合理期限修繕；如果房東拖延不修，房客可以自費找人修繕並從下個月租金扣除，或直接提前終止租約。',
      constituentElements: [
        '租賃物有應由出租人負責之修繕瑕疵',
        '承租人已定相當期限（通常至少 3 至 7 日）催告出租人修繕',
        '出租人受催告後逾期仍未履行修繕',
      ],
      legalEffects: [
        '承租人得自行發包修繕，並請求出租人償還修繕費用',
        '修繕費用得直接由後續租金中抵扣',
        '承租人得無條件提前終止租賃契約，房東不得收取違約金',
      ],
      limitationPeriodYears: 2.0,
      limitationPeriodDescription: '承租人支出修繕費用返還請求權，自租賃關係終止起 2 年不行使而消滅（民法第 456 條）。',
      defenseAndEvidenceGuide: [
        '定相當期限催告修繕之通訊紀錄或存證信函',
        '水電工程行/泥作水電之正式報價單與發票收據',
        '施工前後對比照片',
      ],
      disputeCategories: ['租賃糾紛', '房屋修繕', '自費扣抵租金'],
    ),

    // -------------------------------------------------------------
    // 二、車禍侵權與損害賠償 (Traffic Tort & Damages)
    // -------------------------------------------------------------
    TaiwanStatuteCanonEntry(
      statuteId: 'civil_184_1',
      lawName: '《民法》',
      articleNumber: '第 184 條第 1 項前段',
      officialText: '因故意或過失，不法侵害他人之權利者，負損害賠償責任。',
      plainSummary: '因為故意或疏忽過失，違法侵害了他人的身體、生命或財物（如車輛毀損），就必須負擔全部賠償責任。',
      constituentElements: [
        '加害人有加害行為（如未注意車前狀況、未保持安全距離、闖紅燈）',
        '侵害他人之權利（身體權、健康權、車輛財產權）',
        '被害人受有實質損害（醫藥費、維修費、工作損失）',
        '加害行為與損害間具有相當因果關係',
        '加害人具備故意或過失之可歸責事由',
      ],
      legalEffects: [
        '負損害賠償責任（以回復原狀或金錢賠償受損財物及人身損害）',
      ],
      limitationPeriodYears: 2.0,
      limitationPeriodDescription:
          '自請求權人知有損害及賠償義務人時起，二年間不行使而消滅；自有侵權行為時起，逾十年者亦同（民法第 197 條第 1 項）。',
      defenseAndEvidenceGuide: [
        '道路交通事故當事人登記聯單',
        '警察機關道路交通事故初步分析研判表（初判表）',
        '車輛損害維修估價單與修繕發票明細（列明工資與零件費用）',
        '醫院診斷證明書（正本）與醫療收據',
        '行車紀錄器錄影檔案或現場事故照片',
      ],
      disputeCategories: ['車禍侵權', '損害賠償', '物損賠償'],
      relatedPrecedents: ['最高法院 48 年台上字第 481 號判例（相當因果關係之認定標準）'],
    ),
    TaiwanStatuteCanonEntry(
      statuteId: 'civil_193_1',
      lawName: '《民法》',
      articleNumber: '第 193 條第 1 項',
      officialText: '不法侵害他人之身體或健康者，對於被害人因此喪失或減少勞動能力或增加生活上之需要時，應負損害賠償責任。',
      plainSummary: '因車禍等侵權行為導致受傷者，加害人必須賠償醫療復健費、看護費、輔具器材、因傷休養期間的薪資工作損失，以及勞動能力減損。',
      constituentElements: [
        '身體或健康受有不法侵害（有具體診斷成傷）',
        '被害人因此增加生活上之需要（如就醫交通費、專人看護費、醫療輔具）',
        '或被害人因此喪失/減少工作勞動能力（請假休養或失能評估）',
      ],
      legalEffects: [
        '加害人應賠償因傷增加之一切必要生活費用',
        '加害人應賠償休養期間不能工作之薪資損失及勞動能力減損折算金',
      ],
      limitationPeriodYears: 2.0,
      limitationPeriodDescription: '自知有損害及賠償義務人起算 2 年（民法第 197 條）。',
      defenseAndEvidenceGuide: [
        '合格醫院開立之「宜休養日數」醫師診斷證明書',
        '就醫往返計程車費單據、看護費用收據',
        '請假前之扣繳憑單、薪資轉帳存摺明細證明受傷前原領薪資',
        '雇主出具之請假留職扣薪證明',
      ],
      disputeCategories: ['車禍侵權', '人身傷害', '薪資損失', '醫療補償'],
    ),
    TaiwanStatuteCanonEntry(
      statuteId: 'civil_195_1',
      lawName: '《民法》',
      articleNumber: '第 195 條第 1 項',
      officialText:
          '不法侵害他人之身體、健康、名譽、自由、信用、隱私、貞操，或不法侵害其他人格法益而情節重大者，被害人雖非財產上之損害，亦得請求賠償相當之金額。其名譽被侵害者，並得請求回復名譽之適當處分。',
      plainSummary: '當身體、健康或名譽受到嚴重侵害時，即使沒有實體發票單據，被害人仍然可以依法請求合理的精神慰撫金。',
      constituentElements: [
        '身體、健康、名譽或重大個人法益受侵害',
        '侵害情節客觀上已達重大程度',
        '被害人心理受有相當之精神痛苦',
      ],
      legalEffects: [
        '得請求加害人賠償相當金額之精神慰撫金',
        '名譽受侵害者，得請求適當回復處分（如刊登道歉澄清或移除侵權貼文）',
      ],
      limitationPeriodYears: 2.0,
      limitationPeriodDescription: '時效 2 年（民法第 197 條）。',
      defenseAndEvidenceGuide: [
        '受傷驗傷單或精神身心科就醫紀錄',
        '雙方身分、地位、資力、職業證明（法院審酌慰撫金數額之依據）',
        '名譽侵權時之網路社群公開截圖、貼文網址與公證留存紀錄',
      ],
      disputeCategories: ['車禍侵權', '名譽侵權', '精神慰撫金'],
      relatedPrecedents: ['最高法院 51 年台上字第 223 號判例（慰撫金斟酌雙方身分地位經濟狀況）'],
    ),

    // -------------------------------------------------------------
    // 三、金錢借貸與催款清償 (Loans & Debt Recovery)
    // -------------------------------------------------------------
    TaiwanStatuteCanonEntry(
      statuteId: 'civil_474',
      lawName: '《民法》',
      articleNumber: '第 474 條',
      officialText:
          '稱消費借貸者，謂當事人一方移轉金錢或其他代替物之所有權於他方，而約定他方以種類、品質、數量相同之物返還之契約。當事人之一方對他方負金錢或其他代替物之給付義務而約定以此作為消費借貸之標的者，亦同。',
      plainSummary: '借錢契約要成立，必須要有兩大關鍵：一是「雙方有借錢還錢的合意」，二是「出借人確實把錢交付給對方（如匯款或現金交付）」。',
      constituentElements: [
        '雙方當事人有成立消費借貸之合意',
        '出借人確實已將金錢交付相對人所有（要物性）',
        '約定相對人負有於日後返還同額金錢之義務',
      ],
      legalEffects: [
        '借款人負有依約返還本金及約定利息之義務',
      ],
      limitationPeriodYears: 15.0,
      limitationPeriodDescription: '本金返還請求權消滅時效為 15 年（民法第 125 條）；利息請求權時效為 5 年（民法第 126 條）。',
      defenseAndEvidenceGuide: [
        '借據、借貸契約書、借款收據原本',
        '銀行跨行匯款單、網路銀行轉帳成功水單明細',
        '通訊對話中借款人確認收訖款項及承認欠款金額之訊息截圖',
        '本票、支票等票據原本（若有開立）',
      ],
      disputeCategories: ['金錢借貸', '欠款催討', '本金追索'],
    ),
    TaiwanStatuteCanonEntry(
      statuteId: 'civil_478',
      lawName: '《民法》',
      articleNumber: '第 478 條',
      officialText:
          '借用人應於約定期限內，返還與借用物種類、品質、數量相同之物，未定返還期限者，借用人得隨時返還，貸與人亦得定一個月以上之相當期限，催告返還。',
      plainSummary: '借錢如果當初沒有約定明確的還款日期，債權人不能明天就要對方還錢，必須先發函給對方「至少一個月以上的寬限催告期」，期滿對方才構成違約遲延。',
      constituentElements: [
        '消費借貸契約已有效成立並交付款項',
        '契約中未定有確定之返還期限',
        '出借人已定一個月以上之期限合法催告借用人返還',
        '催告期限屆滿借用人仍未清償',
      ],
      legalEffects: [
        '催告一個月期限屆滿時，借用人始負遲延給付責任',
        '自期限屆滿翌日起，出借人得請求加計法定遲延利息（週年利率 5%）',
      ],
      limitationPeriodYears: 15.0,
      limitationPeriodDescription: '自催告期限屆滿日起算 15 年。',
      defenseAndEvidenceGuide: [
        '寄發定一個月以上還款期限之正式存證信函與郵局掛號收執回執',
        '催告函內容明確載明借款金額與還款期限',
      ],
      disputeCategories: ['金錢借貸', '欠款催討', '未定期限催告'],
    ),
    TaiwanStatuteCanonEntry(
      statuteId: 'civil_203',
      lawName: '《民法》',
      articleNumber: '第 203 條 & 第 233 條',
      officialText:
          '應付利息之債務，其利率未經約定，亦無法律可據者，週年利率為百分之五。遲延之債務，以支付金錢為標的者，債權人得請求依法定利率計算之遲延利息。',
      plainSummary: '債務人欠錢逾期不還時，就算當初沒有特別講好利息，債權人也有權依法向債務人收取每年 5% 的法定遲延利息。',
      constituentElements: [
        '金錢給付之債務已屆清償期',
        '債務人因可歸責於己之事由給付遲延',
        '未約定遲延利率或約定不明',
      ],
      legalEffects: [
        '自遲延之日起，按年息 5% 計算遲延利息直至清償日止',
      ],
      limitationPeriodYears: 5.0,
      limitationPeriodDescription: '利息給付請求權，因五年間不行使而消滅（民法第 126 條）。',
      defenseAndEvidenceGuide: [
        '清償期屆至或催告到期日之送達證明',
        '本金借貸成立證明',
      ],
      disputeCategories: ['金錢借貸', '法定利息', '遲延利息'],
    ),

    // -------------------------------------------------------------
    // 四、勞資爭議與資遣工資 (Labor Law & Severance)
    // -------------------------------------------------------------
    TaiwanStatuteCanonEntry(
      statuteId: 'labor_14_1_5',
      lawName: '《勞動基準法》',
      articleNumber: '第 14 條第 1 項第 5、6 款',
      officialText:
          '有下列情形之一者，勞工得不經預告終止契約：五、雇主不依勞動契約給付工作報酬，或對於按件計酬之勞工不供給充分之工作者。六、雇主違反勞動契約或勞工法令，致有損害勞工權益之虞者。',
      plainSummary: '如果老闆不按時發薪水、少發工資、或者違反勞基法損害勞工權益，員工可以直接發函離職（不需提前預告），並且老闆依然必須給付資遣費與非自願離職證明書！',
      constituentElements: [
        '雇主有欠薪、未全額給付工資、未付加班費，或違法調職等情事',
        '致有實質損害勞工權益之事實',
        '勞工於知悉其情形之日起三十日內主張終止（第6款情事）',
      ],
      legalEffects: [
        '勞工得不經預告立即終止勞動契約',
        '準用勞基法第 17 條規定，雇主應依法給付資遣費',
        '雇主應依法開立非自願離職證明書（勞基法第 19 條）',
      ],
      limitationPeriodYears: 5.0,
      limitationPeriodDescription: '除斥期間：勞工知悉違反勞工法令情事起 30 日內須提出主張；資遣費與工資請求權時效 5 年。',
      defenseAndEvidenceGuide: [
        '勞動契約書原本或錄取通知聘書',
        '薪資存摺轉帳明細、薪資單（核對欠薪或未發加班費金額）',
        '打卡上下班紀錄清單、出勤明細表',
        '向雇主主張依勞基法第 14 條終止勞動契約之書面存證信函或簽收文件',
      ],
      disputeCategories: ['勞資爭議', '資遣費討回', '違法欠薪', '非自願離職'],
    ),
    TaiwanStatuteCanonEntry(
      statuteId: 'labor_pension_12',
      lawName: '《勞工退休金條例》',
      articleNumber: '第 12 條',
      officialText:
          '勞工適用本條例之退休金制度者，其資遣費由雇主按其工作年資，每滿一年發給二分之一個月之平均工資，未滿一年者，以比例計給；最高以發給六個月平均工資為限，並應於終止勞動契約後三十日內發給。',
      plainSummary: '新制勞工資遣費計算方式：工作每滿 1 年發半個月平均工資，最高以 6 個月為上限，老闆必須在離職後 30 天內一次給清。',
      constituentElements: [
        '勞工受適用勞退新制（94年7月1日以後新進或選擇新制）',
        '勞動契約依勞基法第 11 條或第 14 條事由合法終止',
        '具有累計之受僱工作年資',
      ],
      legalEffects: [
        '雇主應於契約終止後 30 日內發給新制資遣費',
        '逾期不給付者，主管機關得處新台幣三十萬元以上一百五十萬元以下罰鍰',
      ],
      limitationPeriodYears: 5.0,
      limitationPeriodDescription: '資遣費請求權消滅時效為 5 年（勞基法第 17 條）。',
      defenseAndEvidenceGuide: [
        '勞工保險投保明細表（證明在職實際起訖年資）',
        '離職前六個月之完整薪資明細表（用以精確計算平均工資）',
      ],
      disputeCategories: ['勞資爭議', '資遣費計算', '勞退新制'],
    ),

    // -------------------------------------------------------------
    // 五、消費者保護與定型化契約 (Consumer Protection)
    // -------------------------------------------------------------
    TaiwanStatuteCanonEntry(
      statuteId: 'consumer_19',
      lawName: '《消費者保護法》',
      articleNumber: '第 19 條第 1 項',
      officialText:
          '通訊交易或訪問交易之消費者，得於收受商品或接受服務後七日內，以書面通知方式解除契約，無須說明理由及負擔任何費用或對價。',
      plainSummary: '網購（通訊交易）消費者收到商品後享有 7 天猶豫期（鑑賞期），可以在 7 天內以書面或通訊方式通知賣家退貨退款，賣家不得收取任何手續費或運費。',
      constituentElements: [
        '屬於通訊交易（如網路購物、電視購物、APP 購買）或訪問交易',
        '非屬行政院定之合理例外情事（如易腐生鮮食品、已拆封個人衛生用品、客製化給付）',
        '消費者於收受商品翌日起算 7 日內發出解約通知',
      ],
      legalEffects: [
        '買賣契約自通知到達時解除',
        '賣家應於收到退貨後 15 日內無息全額退款',
        '賣家不得要求消費者負擔退貨運費或包裝整新費',
      ],
      limitationPeriodYears: 0.02, // 7 日除斥期間
      limitationPeriodDescription: '7 日法定猶豫期除斥期間，自收受商品之次日起算。',
      defenseAndEvidenceGuide: [
        '商品簽收單據、超商取貨簡訊或物流送達簽收時間紀錄',
        '於 7 日內通知賣家退貨退款之截圖紀錄',
        '商品包裝及退回之照片與物流寄送單據',
      ],
      disputeCategories: ['消費者保護', '網購退貨', '七日鑑賞期'],
    ),

    // -------------------------------------------------------------
    // 六、承攬工程與裝潢瑕疵 (Construction & Contractor Defects)
    // -------------------------------------------------------------
    TaiwanStatuteCanonEntry(
      statuteId: 'civil_493',
      lawName: '《民法》',
      articleNumber: '第 493 條',
      officialText:
          '工作有瑕疵者，定作人得定相當期限，請求承攬人修補之。承攬人不於前項期限內修補者，定作人得自行修補，並得向承攬人請求償還修補必要之費用。如修補所需費用過鉅者，承攬人得拒絕修補，前項規定，不適用之。',
      plainSummary: '裝潢或施工發現瑕疵時，業主應先給統包/設計師合理期限修補；如果對方裝死逾期不修，業主可以找其他工班修繕，並將全部修補費用向原承攬人求償或從尾款扣抵。',
      constituentElements: [
        '承攬契約關係有效存在',
        '承攬人交付之工作物存有不合約定或通常效用之瑕疵',
        '定作人已定期限催告承攬人進行修補瑕疵',
        '承攬人於期限內未予修補或拒絕修補',
      ],
      legalEffects: [
        '定作人得自行僱工修補瑕疵',
        '得向承攬人請求償還修補之必要費用',
        '得直接自主張瑕疵修補之款項抵銷尚未給付之承攬尾款',
      ],
      limitationPeriodYears: 1.0,
      limitationPeriodDescription: '定作人之瑕疵修補請求權、償還費用請求權，因瑕疵發見後一年間不行使而消滅（民法第 514 條第 1 項）。',
      defenseAndEvidenceGuide: [
        '室內裝修/裝潢工程合約書、施工報價單圖說',
        '驗收瑕疵缺失清單、現場瑕疵照片及錄影',
        '定相當期限催告修補之存證信函或通訊紀錄',
        '第三方公正檢驗單位鑑定報告或後續工班修復報價單與發票',
      ],
      disputeCategories: ['裝潢工程', '承攬瑕疵', '尾款扣抵'],
    ),

    // -------------------------------------------------------------
    // 七、督促程序與支付命令 (Payment Order Summary Procedure)
    // -------------------------------------------------------------
    TaiwanStatuteCanonEntry(
      statuteId: 'civil_procedure_508',
      lawName: '《民事訴訟法》',
      articleNumber: '第 508 條 & 第 511 條',
      officialText:
          '債權人之請求，以給付金錢或其他代替物或有價證券之一定數量為標的者，得聲請法院依督促程序發支付命令。聲請應表明當事人及法定代理人、請求之標的及其數量、請求之原因事實、應發支付命令之陳述及管轄法院。',
      plainSummary: '只要對方欠你的是確定金額的金錢（如借款 10 萬元、未付租金 3 萬元），不需要花大錢請律師打冗長官司，只要花 500 元聲請費向法院聲請「支付命令」，對方如果 20 天內沒提異議，就具備法院確定判決效力，可直接查封拍賣對方財產！',
      constituentElements: [
        '請求標的為一定金額之金錢債權（確定數額）',
        '債權已屆清償期，且有釋明債權之具體證據（借據、對話、匯款單）',
        '債務人在我國有送達地址（非國外亦非公示送達）',
        '向債務人戶籍所在地之管轄地方法院提出聲請',
      ],
      legalEffects: [
        '法院形式審查通過後核發支付命令',
        '債務人收受後 20 日內未合法異議者，支付命令得為執行名義',
        '債權人得執此確定證明書向民事執行處聲請強制執行（查封薪水、存款、不動產）',
      ],
      limitationPeriodYears: 0.05, // 20 日異議期
      limitationPeriodDescription: '債務人於收受送達後二十日之不變期間內得提出異議；逾期異議不合法。',
      defenseAndEvidenceGuide: [
        '民事支付命令聲請狀（記載請求標的與原因事實）',
        '證明金錢債權存在之證據原本（契約、借據、本票、匯款明細、通訊確認欠款紀錄）',
        '相對人（債務人）最新個人戶籍謄本（法院命補正時繳納）',
        '裁判費新台幣 500 元繳納收據',
      ],
      disputeCategories: ['支付命令', '督促程序', '強制執行', '欠款催收'],
    ),
  ];

  /// 依自然語言事實尋找最相符之法規典籍（前 N 筆）
  static List<TaiwanStatuteCanonEntry> findBestMatchingStatutes(
    String queryFacts, {
    int limit = 4,
  }) {
    final text = queryFacts.trim().toLowerCase();
    if (text.isEmpty) return entries.take(limit).toList();

    final scored = <TaiwanStatuteCanonEntry, double>{};

    for (final entry in entries) {
      double score = 0.0;

      // 1. 領域標籤匹配 (+10 分)
      for (final cat in entry.disputeCategories) {
        if (text.contains(cat.toLowerCase())) {
          score += 10.0;
        }
      }

      // 2. 關鍵字比對
      final keywords = [
        ...entry.constituentElements,
        ...entry.plainSummary.split('，'),
      ];
      for (final kw in keywords) {
        if (kw.length >= 2 && text.contains(kw)) {
          score += 3.0;
        }
      }

      // 3. 領域意圖特色加權
      if (entry.statuteId.startsWith('rental') || entry.statuteId.startsWith('civil_42') || entry.statuteId.startsWith('civil_43')) {
        if (text.contains('租') || text.contains('房東') || text.contains('押金') || text.contains('房客') || text.contains('退租')) {
          score += 15.0;
        }
      } else if (entry.statuteId.startsWith('civil_184') || entry.statuteId.startsWith('civil_19')) {
        if (text.contains('車禍') || text.contains('撞') || text.contains('追撞') || text.contains('受傷') || text.contains('初判表')) {
          score += 15.0;
        }
      } else if (entry.statuteId.startsWith('civil_47')) {
        if (text.contains('借') || text.contains('欠') || text.contains('還錢') || text.contains('借據') || text.contains('本票')) {
          score += 15.0;
        }
      } else if (entry.statuteId.startsWith('labor')) {
        if (text.contains('工資') || text.contains('加班') || text.contains('資遣') || text.contains('老闆') || text.contains('離職')) {
          score += 15.0;
        }
      } else if (entry.statuteId.startsWith('consumer')) {
        if (text.contains('網購') || text.contains('鑑賞期') || text.contains('退貨') || text.contains('七天')) {
          score += 15.0;
        }
      } else if (entry.statuteId.startsWith('civil_49')) {
        if (text.contains('裝潢') || text.contains('工程') || text.contains('瑕疵') || text.contains('修補') || text.contains('尾款')) {
          score += 15.0;
        }
      } else if (entry.statuteId.startsWith('civil_procedure')) {
        if (text.contains('支付命令') || text.contains('強制執行') || text.contains('查封')) {
          score += 15.0;
        }
      }

      if (score > 0) {
        scored[entry] = score;
      }
    }

    final sorted = scored.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    if (sorted.isEmpty) {
      return entries.take(limit).toList();
    }

    return sorted.take(limit).map((e) => e.key).toList();
  }

  /// 根據條文代碼精準獲取條文
  static TaiwanStatuteCanonEntry? findByStatuteId(String id) {
    for (final entry in entries) {
      if (entry.statuteId == id) return entry;
    }
    return null;
  }

  /// 根據法規名稱與條號精準查找
  static TaiwanStatuteCanonEntry? findByCitation(String lawName, String articleNumber) {
    for (final entry in entries) {
      if (entry.lawName.contains(lawName) &&
          (entry.articleNumber.contains(articleNumber) || articleNumber.contains(entry.articleNumber))) {
        return entry;
      }
    }
    return null;
  }
}
