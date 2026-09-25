// 緒言 Preamble 臺灣核心實體與程序法規全典籍庫 (Taiwan Statute Canon - Complete Universal Edition)
//
// 本典籍庫全面涵蓋台灣當代 17 大法律爭議領域（民事、刑事、家事、商事、公法與保全強制執行）：
// 1. 租賃住宅與不動產點交
// 2. 交通事故與侵權損害賠償
// 3. 消費借貸、票據與債權債務
// 4. 勞資爭議、加班費與資遣解僱
// 5. 消費者保護、特種網購與買賣瑕疵
// 6. 裝潢修繕、承攬工程與瑕疵修補
// 7. 妨害名譽、公然侮辱與個資隱私
// 8. 婚姻家庭、裁判離婚與親權扶養
// 9. 遺產繼承、特留分扣減與遺囑效力
// 10. 公司股權、合夥拆夥與商務合約
// 11. 智慧財產權、商標侵權與營業秘密
// 12. 詐欺犯罪、人頭帳戶與網路犯罪
// 13. 不動產物權、漏水修繕與相鄰管委會
// 14. 保險理賠爭議與醫療過失損害賠償
// 15. 民事強制執行、支付命令與保全程序
// 16. 公法救濟、國家賠償與交通行政訴訟
// 17. 通用民法契約、不當得利與無因管理
//
// 每筆條文均包含：官方條文、白話意旨、構成要件、法律效果、消滅時效、實務攻防與舉證清冊。

/// 臺灣當代法律爭議領域全維度枚舉
enum TaiwanDisputeDomain {
  rentalAndHousing,
  trafficAndTort,
  loanAndDebt,
  laborAndEmployment,
  consumerProtection,
  constructionAndContract,
  defamationAndPrivacy,
  familyAndDivorce,
  inheritanceAndWills,
  corporateAndPartnership,
  intellectualProperty,
  fraudAndCybercrime,
  propertyAndNeighbor,
  insuranceAndMedical,
  compulsoryEnforcement,
  administrativeAndPublic,
  generalCivilAndContract,
}

extension TaiwanDisputeDomainExt on TaiwanDisputeDomain {
  String get displayName => switch (this) {
        TaiwanDisputeDomain.rentalAndHousing => '租賃住宅與不動產爭議',
        TaiwanDisputeDomain.trafficAndTort => '交通事故與侵權損害賠償',
        TaiwanDisputeDomain.loanAndDebt => '消費借貸、票據與債權債務',
        TaiwanDisputeDomain.laborAndEmployment => '勞資爭議、加班費與資遣解僱',
        TaiwanDisputeDomain.consumerProtection => '消費者保護、網購退換與商品瑕疵',
        TaiwanDisputeDomain.constructionAndContract => '裝潢修繕、承攬工程與瑕疵修補',
        TaiwanDisputeDomain.defamationAndPrivacy => '妨害名譽、公然侮辱與個資隱私',
        TaiwanDisputeDomain.familyAndDivorce => '婚姻家庭、裁判離婚與親權扶養',
        TaiwanDisputeDomain.inheritanceAndWills => '遺產繼承、特留分扣減與遺囑效力',
        TaiwanDisputeDomain.corporateAndPartnership => '公司股權、合夥拆夥與商務合約',
        TaiwanDisputeDomain.intellectualProperty => '智慧財產權、商標侵權與營業秘密',
        TaiwanDisputeDomain.fraudAndCybercrime => '詐欺侵占、人頭帳戶與網路犯罪',
        TaiwanDisputeDomain.propertyAndNeighbor => '不動產物權、漏水修繕與相鄰管委會',
        TaiwanDisputeDomain.insuranceAndMedical => '保險理賠爭議與醫療過失損害賠償',
        TaiwanDisputeDomain.compulsoryEnforcement => '民事強制執行、支付命令與保全程序',
        TaiwanDisputeDomain.administrativeAndPublic => '公法救濟、國家賠償與交通行政訴訟',
        TaiwanDisputeDomain.generalCivilAndContract => '通用民法契約、不當得利與無因管理',
      };
}

/// 典籍庫條目結構體
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
    this.domain = TaiwanDisputeDomain.generalCivilAndContract,
  });

  final String statuteId;
  final String lawName;
  final String articleNumber;
  final String officialText;
  final String plainSummary;
  final List<String> constituentElements;
  final List<String> legalEffects;
  final double limitationPeriodYears;
  final String limitationPeriodDescription;
  final List<String> defenseAndEvidenceGuide;
  final List<String> disputeCategories;
  final List<String> relatedPrecedents;
  final TaiwanDisputeDomain domain;

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
        'domain': domain.name,
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
        domain: TaiwanDisputeDomain.values.firstWhere(
          (d) => d.name == json['domain'],
          orElse: () => TaiwanDisputeDomain.generalCivilAndContract,
        ),
      );
}

/// 臺灣法規典籍庫檢索中心
class TaiwanStatuteCanon {
  const TaiwanStatuteCanon._();

  static const List<TaiwanStatuteCanonEntry> entries = [
    // -------------------------------------------------------------
    // 一、租賃住宅糾紛 (Lease & Rental Disputes)
    // -------------------------------------------------------------
    TaiwanStatuteCanonEntry(
      statuteId: 'rental_act_34',
      lawName: '《租賃住宅市場發展及管理條例》',
      articleNumber: '第 34 條',
      domain: TaiwanDisputeDomain.rentalAndHousing,
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
      domain: TaiwanDisputeDomain.rentalAndHousing,
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
      domain: TaiwanDisputeDomain.rentalAndHousing,
      officialText:
          '租賃物有修繕之必要，應由出租人負擔者，承租人得定相當期限，催告出租人修繕，如出租人於其期限內不為修繕者，承租人得終止契約或自行修繕而請求償還其費用或於租金中扣除之。',
      plainSummary: '房屋有修繕必要時，房客可給房東合理期限修繕；如果房東拖延不修，房客可以自費找人修繕並從下個月租金扣除，或直接提前終止租約。',
      constituentElements: [
        '租賃物有應由出租人負擔之修繕必要',
        '承租人已定期限催告出租人進行修繕',
        '出租人於期限內未予修繕或拒絕修繕',
      ],
      legalEffects: [
        '承租人得合法終止租賃契約，不受提前解約賠償拘束',
        '承租人得自行修繕，並請求出租人償還修繕費用',
        '承租人得將自行修繕之費用直接由租金中扣除',
      ],
      limitationPeriodYears: 2.0,
      limitationPeriodDescription: '承租人償還修繕費用請求權，自租約終止返還租賃物起 2 年間不行使而消滅（民法第 456 條）。',
      defenseAndEvidenceGuide: [
        '定相當期限催告修繕之通訊截圖或存證信函掛號回執',
        '自行僱工修繕之估價單、發票或收據原本',
        '修繕施工前後之對比相片',
      ],
      disputeCategories: ['租賃糾紛', '房屋修繕', '自行修繕扣抵'],
    ),
    TaiwanStatuteCanonEntry(
      statuteId: 'civil_440',
      lawName: '《民法》',
      articleNumber: '第 440 條',
      domain: TaiwanDisputeDomain.rentalAndHousing,
      officialText:
          '承租人租金支付有遲延者，出租人得定相當期限，催告其支付租金，如承租人於其期限內不為支付，出租人得終止契約。房屋租賃總額達二個月之租額，並經定相當期限催告而仍不為支付者，出租人始得終止租約。',
      plainSummary: '房客欠租必須扣除押金後，實際積欠租金總額達「2 個月」以上，且經房東定相當期限催告仍不給付時，房東才可以依法提前終止租約收回房屋。',
      constituentElements: [
        '承租人遲延支付租金',
        '欠租金額經抵銷押租金後，累計實質達 2 個月租金總額',
        '出租人已定相當期限催告承租人給付',
        '承租人於催告期限屆滿後仍未清償欠租',
      ],
      legalEffects: [
        '出租人取得租約終止權，得合法發函終止租賃契約',
        '得請求承租人騰空交還房屋',
        '得請求積欠之租金及自催告翌日起算之遲延利息與相當於租金之不當得利',
      ],
      limitationPeriodYears: 5.0,
      limitationPeriodDescription: '租金給付請求權因 5 年間不行使而消滅（民法第 126 條）。',
      defenseAndEvidenceGuide: [
        '租賃契約書原本（核對租金繳納約定日期）',
        '房東存摺帳戶交易明細（佐證未入帳紀錄）',
        '定相當期限催告給付之存證信函及收件回執',
      ],
      disputeCategories: ['租賃糾紛', '欠租終止', '收回房屋'],
    ),

    // -------------------------------------------------------------
    // 二、交通事故與侵權損害賠償 (Traffic Accident & Tort)
    // -------------------------------------------------------------
    TaiwanStatuteCanonEntry(
      statuteId: 'civil_184_1',
      lawName: '《民法》',
      articleNumber: '第 184 條第 1 項前段',
      domain: TaiwanDisputeDomain.trafficAndTort,
      officialText:
          '因故意或過失，不法侵害他人之權利者，負損害賠償責任。',
      plainSummary: '任何人因為疏忽或故意，撞傷他人或造成他人財物受損，都必須負起法律賠償責任。',
      constituentElements: [
        '行為人有加害行為',
        '行為具有不法性',
        '侵害他人之權利（生命、身體、健康、財產權）',
        '行為人主觀上有故意或過失',
        '被害人受有實際損害',
        '加害行為與損害結果間具備相當因果關係',
      ],
      legalEffects: [
        '被害人得請求行為人負損害賠償責任',
        '賠償方法以回復原狀為原則，不能回復或回復顯有重大困難者以金錢賠償',
      ],
      limitationPeriodYears: 2.0,
      limitationPeriodDescription: '自請求權人知有損害及賠償義務人時起，二年間不行使而消滅；自有侵權行為時起，逾十年者亦同（民法第 197 條第 1 項）。',
      defenseAndEvidenceGuide: [
        '道路交通事故現場圖、現場照片及初判表',
        '車輛行車記錄器錄影光碟或路口監視器檔案',
        '公立或教學醫院開具之診斷證明書原本',
        '車輛維修報價單、統一發票與受損相片（注意零件折舊抗辯）',
      ],
      disputeCategories: ['車禍賠償', '侵權損害', '過失致傷'],
    ),
    TaiwanStatuteCanonEntry(
      statuteId: 'civil_191_2',
      lawName: '《民法》',
      articleNumber: '第 191 條之 2',
      domain: TaiwanDisputeDomain.trafficAndTort,
      officialText:
          '汽車、機車或其他非依軌道行駛之動力車輛，在使用中加損害於他人者，駕駛人應負賠償責任。但於防止損害之發生，已盡相當之注意者，不在此限。',
      plainSummary: '開車或騎機車撞傷人或撞壞車，法律推定駕駛人有過失，駕駛人若想免責，必須自己舉證當時已盡完全注意而無法避免。',
      constituentElements: [
        '動力車輛駕駛人於車輛行駛使用中',
        '造成他人生命、身體、健康或財物受損',
      ],
      legalEffects: [
        '法定推定過失責任，舉證責任倒置至肇事駕駛人身上',
      ],
      limitationPeriodYears: 2.0,
      limitationPeriodDescription: '知悉損害及加害人起算 2 年短期消滅時效。',
      defenseAndEvidenceGuide: [
        '車輛碰撞跡證與行車記錄器畫面',
        '車輛行車事故鑑定委員會之正式鑑定意見書',
      ],
      disputeCategories: ['車禍責任', '動力車輛', '推定過失'],
    ),
    TaiwanStatuteCanonEntry(
      statuteId: 'civil_193',
      lawName: '《民法》',
      articleNumber: '第 193 條第 1 項',
      domain: TaiwanDisputeDomain.trafficAndTort,
      officialText:
          '不法侵害他人之身體或健康者，對於被害人因此喪失或減少勞動能力或增加生活上之需要時，應負損害賠償責任。',
      plainSummary: '撞傷他人時，除了醫療費外，傷者受傷請假無法上班的薪水損失、未來勞動能力減損、看診交通費與專人看護照顧費用，肇事者均須賠償。',
      constituentElements: [
        '不法侵害他人身體或健康權',
        '被害人受有實際財產上損害：喪失/減少勞動能力、或增加生活上額外支出（醫療、輔具、看護）',
      ],
      legalEffects: [
        '得請求醫療自費費用、醫療器材及往返門診交通費',
        '得請求受傷休養期間之薪資工作損失',
        '得請求親屬或專業看護費用（縱由家人照料亦得評價為金錢求償）',
        '成殘者得按勞工保險失能給付標準請求終身勞動能力減損折現',
      ],
      limitationPeriodYears: 2.0,
      limitationPeriodDescription: '侵權行為 2 年短期消滅時效。',
      defenseAndEvidenceGuide: [
        '公立或教學醫院診斷證明書（須載明需專人看護天數及宜休養天數）',
        '醫療收據、藥品明細與醫療耗材發票',
        '傷前 6 個月之薪資扣繳憑單、薪轉存摺或勞保投保薪資證明',
        '請假出勤證明卡或留職停薪證明書',
      ],
      disputeCategories: ['車禍受傷', '工作損失', '看護費用', '勞動能力減損'],
    ),
    TaiwanStatuteCanonEntry(
      statuteId: 'civil_195',
      lawName: '《民法》',
      articleNumber: '第 195 條第 1 項',
      domain: TaiwanDisputeDomain.trafficAndTort,
      officialText:
          '不法侵害他人之身體、健康、名譽、自由、信用、隱私、貞操，或不法侵害其他人格法益而情節重大者，被害人雖非財產上之損害，亦得請求賠償相當之金額。其名譽被侵害者，並得請求回復名譽之適當處分。',
      plainSummary: '身體受傷或名譽、隱私、信用被侵害且情節重大時，即使沒有發票單據，被害人依然可以向加害人請求金錢精神慰撫金（精神賠償）。',
      constituentElements: [
        '侵害生命、身體、健康、名譽、自由、信用或人格法益',
        '侵害情節達到客觀上重大之程度',
        '被害人受有精神上痛苦',
      ],
      legalEffects: [
        '得請求給付相當之精神慰撫金',
        '得請求適當回復名譽之處分（但不得強制下跪或違背良心道歉）',
      ],
      limitationPeriodYears: 2.0,
      limitationPeriodDescription: '自知悉損害及加害人起 2 年。',
      defenseAndEvidenceGuide: [
        '傷勢照片、手術紀錄與重大創傷診斷書',
        '雙方身分、社會地位、年齡、職業與經濟收入狀況證明（稅務財產清冊）',
        '精神科門診就醫紀錄或心理諮商單據（佐證創傷後壓力症候群）',
      ],
      disputeCategories: ['精神賠償', '慰撫金', '名譽侵權'],
    ),
    TaiwanStatuteCanonEntry(
      statuteId: 'civil_217',
      lawName: '《民法》',
      articleNumber: '第 217 條第 1 項',
      domain: TaiwanDisputeDomain.trafficAndTort,
      officialText:
          '損害之發生或擴大，被害人與有過失者，法院得減輕賠償金額，或免除之。',
      plainSummary: '如果被害人自己也有違規或疏忽（例如超速、未打方向燈、未戴安全帽），法院可以依責任比例減輕加害人的賠償金額（過失相抵）。',
      constituentElements: [
        '被害人對於損害之發生或擴大亦具備不小心、疏忽或違規之與有過失',
        '被害人之疏忽與損害結果具備關聯',
      ],
      legalEffects: [
        '賠償義務人得主張過失相抵抗辯，扣減賠償總額比例',
      ],
      limitationPeriodYears: 0.0,
      limitationPeriodDescription: '為抗辯權，於訴訟或和解中隨時得提出主張。',
      defenseAndEvidenceGuide: [
        '警方初判表、道路交通事故現場圖',
        '車輛行車事故鑑定會之鑑定意見書（釐清肇事主因與肇事次因比例，如 7:3 或 5:5）',
      ],
      disputeCategories: ['過失相抵', '車禍責任比例', '防禦抗辯'],
    ),
    TaiwanStatuteCanonEntry(
      statuteId: 'penal_284',
      lawName: '《刑法》',
      articleNumber: '第 284 條',
      domain: TaiwanDisputeDomain.trafficAndTort,
      officialText:
          '因過失傷害人者，處一年以下有期徒刑、拘役或十萬元以下罰金；致重傷者，處三年以下有期徒刑、拘役或三十萬元以下罰金。',
      plainSummary: '因為不小心發生車禍造成他人受傷，會構成刑事「過失傷害罪」；被害人可以在知悉肇事人之日起「6 個月內」提出刑事告訴。',
      constituentElements: [
        '行為人主觀上具備注意義務且能注意而不注意之過失',
        '被害人受有身體成傷或重傷之結果',
        '過失與成傷間具備相當因果關係',
      ],
      legalEffects: [
        '成立刑事過失傷害罪，移送地檢署偵辦',
        '告訴人得於檢察官起訴後提起刑事附帶民事訴訟，免繳納第一審民事裁判費',
      ],
      limitationPeriodYears: 0.5,
      limitationPeriodDescription: '刑事訴訟法第 237 條規定：告訴乃論之罪，應自知悉犯人之時起「六個月」內提出告訴，逾期喪失告訴權！',
      defenseAndEvidenceGuide: [
        '公立或教學醫院開具之傷勢診斷證明書（載明傷名）',
        '交通事故聯單或警員受理報案三聯單',
      ],
      disputeCategories: ['車禍刑事', '過失傷害', '以刑逼民'],
    ),

    // -------------------------------------------------------------
    // 三、消費借貸與票據債務 (Loans & Debt Collection)
    // -------------------------------------------------------------
    TaiwanStatuteCanonEntry(
      statuteId: 'civil_474',
      lawName: '《民法》',
      articleNumber: '第 474 條',
      domain: TaiwanDisputeDomain.loanAndDebt,
      officialText:
          '稱消費借貸者，謂當事人一方移轉金錢或其他代替物之所有權於他方，而約定他方以種類、品質、數量相同之物返還之契約。當事人之一方對他方負金錢或其他代替物之給付義務而約定以之作為消費借貸之標的者，亦成立消費借貸。',
      plainSummary: '朋友借錢在法律上成立「消費借貸契約」，成立要件除了雙方說好要借錢外，最重要的是一定要有「把錢真正交給或匯給對方」的交付事實。',
      constituentElements: [
        '借貸雙方達成借貸意思表示合致',
        '貸與人已將借款交付借用人（要物契約：現金交付或銀行匯款完成）',
      ],
      legalEffects: [
        '借用人負有依約返還同額本金與約定利息之債務',
      ],
      limitationPeriodYears: 15.0,
      limitationPeriodDescription: '本金請求權消滅時效 15 年；約定利息請求權消滅時效 5 年（民法第 126 條）。',
      defenseAndEvidenceGuide: [
        '載明借款人姓名、借款金額與日期的正式借據或借款切結書原本',
        '銀行轉帳匯款明細水單或ATM明細表（佐證交付事實）',
        '通訊軟體 (LINE) 對話紀錄截圖（對方承認借款、請求寬限或承諾還款日期）',
      ],
      disputeCategories: ['借貸欠款', '借據借約', '金錢返還'],
    ),
    TaiwanStatuteCanonEntry(
      statuteId: 'civil_478',
      lawName: '《民法》',
      articleNumber: '第 478 條',
      domain: TaiwanDisputeDomain.loanAndDebt,
      officialText:
          '借用人應於約定期限內，返還與借用物種類、品質、數量相同之物，未定返還期限者，借用人得隨時返還，貸與人亦得定一個月以上之相當期限，催告返還。',
      plainSummary: '如果當初借錢時沒有講好哪一天一定要還，債權人不能今天叫他明天還，依法必須給對方「一個月以上」的催告準備期，期滿後對方才算違約遲延！',
      constituentElements: [
        '消費借貸契約未約定確定期限',
        '貸與人定一個月以上之相當期限催告借用人返還',
      ],
      legalEffects: [
        '催告期限屆滿後，借用人負遲延給付責任',
        '貸與人得自期限屆滿翌日起請求法定遲延利息（年息 5%）',
      ],
      limitationPeriodYears: 15.0,
      limitationPeriodDescription: '自催告期限屆滿翌日起算 15 年。',
      defenseAndEvidenceGuide: [
        '載明「限期於文到後一個月內清償」之存證信函原本及雙掛號送達回執聯',
      ],
      disputeCategories: ['借款催告', '未定還款期限', '催告一個月'],
    ),
    TaiwanStatuteCanonEntry(
      statuteId: 'civil_205',
      lawName: '《民法》',
      articleNumber: '第 205 條',
      domain: TaiwanDisputeDomain.loanAndDebt,
      officialText:
          '約定利率，超過週年百分之十六者，超過部分之約定，無效。',
      plainSummary: '民間借貸法律規定的「年利率上限最高為 16%」；如果對方約定超過 16%（例如每個月 2 分、3 分利），超過 16% 部分在法律上「無效」，借款人依法不用支付！',
      constituentElements: [
        '金錢債務之約定利息',
        '約定利率超過週年百分之十六',
      ],
      legalEffects: [
        '超過 16% 之利息約定自始無效',
        '債權人對於超過部分無請求權；債務人若已誤付，得依不當得利主張抵充本金或請求返還',
      ],
      limitationPeriodYears: 5.0,
      limitationPeriodDescription: '利息請求權 5 年。',
      defenseAndEvidenceGuide: [
        '借據載明之約定利率條款',
        '歷次支付利息之存摺轉帳明細或簽收單據',
      ],
      disputeCategories: ['高利貸', '法定最高利率', '利息爭議'],
    ),
    TaiwanStatuteCanonEntry(
      statuteId: 'negotiable_123',
      lawName: '《票據法》',
      articleNumber: '第 123 條',
      domain: TaiwanDisputeDomain.loanAndDebt,
      officialText:
          '執票人向本票發票人行使追索權時，得聲請法院裁定後強制執行。',
      plainSummary: '手上有借款人簽發的本票且到期未付款時，可以直接向法院聲請「本票裁定」，法院只作形式審查不用開庭，很快就能核發裁定並查封對方的財產！',
      constituentElements: [
        '持有有效之本票原本（具備發票人簽章、記載表明其為本票之字樣、一定金額、無條件擔任支付、發票年月日）',
        '本票已屆到期日，或見票即付之本票經提示未獲付款',
      ],
      legalEffects: [
        '法院審查無誤後迅速核發本票許可強制執行裁定',
        '執票人持裁定及確定證明書得直接聲請強制執行查封拍賣發票人財產',
      ],
      limitationPeriodYears: 3.0,
      limitationPeriodDescription: '票據法第 22 條第 1 項：票據上之權利，對本票發票人，自到期日起算；見票即付之本票，自發票日起算；三年間不行使，因時效而消滅。',
      defenseAndEvidenceGuide: [
        '本票原本（檢查發票日、金額與簽名齊全）',
        '向發票人提示付款之紀錄或存證信函',
      ],
      disputeCategories: ['本票裁定', '票據追索', '快速強制執行'],
    ),

    // -------------------------------------------------------------
    // 四、勞資爭議與勞工權益 (Labor & Employment)
    // -------------------------------------------------------------
    TaiwanStatuteCanonEntry(
      statuteId: 'labor_11',
      lawName: '《勞動基準法》',
      articleNumber: '第 11 條',
      domain: TaiwanDisputeDomain.laborAndEmployment,
      officialText:
          '非有左列情形之一者，雇主不得預告勞工終止勞動契約：一、歇業或轉讓時。二、虧損或業務緊縮時。三、不可抗力暫停工作在一個月以上時。四、業務性質變更，有減少勞工之必要，又無適當工作可供安置時。五、勞工對於所擔任之工作確不能勝任時。',
      plainSummary: '老闆不能隨便開除員工！只有在公司虧損、業務緊縮，或勞工客觀能力態度經輔導確實不能勝任工作時，老闆才可以資遣，且必須提前預告並發給資遣費與非自願離職證明。',
      constituentElements: [
        '雇主主動通知勞工終止勞動契約',
        '具備法定第 11 條各款法定實質事由之一',
      ],
      legalEffects: [
        '雇主應依第 16 條給予預告期間或發給預告工資',
        '雇主應依勞工退休金條例第 12 條發給法定資遣費',
        '雇主應依就業服務法通報資遣，並開立「非自願離職證明書」',
      ],
      limitationPeriodYears: 15.0,
      limitationPeriodDescription: '資遣費請求權消滅時效 15 年；但申請失業給付應於非自願離職退保 2 年內向就服機構申請。',
      defenseAndEvidenceGuide: [
        '雇主資遣通知函或電子郵件',
        '公司開具之非自願離職證明書或服務證明書',
        '過往績效考核紀錄（反駁第5款不能勝任之不實指控）',
      ],
      disputeCategories: ['資遣解僱', '非自願離職', '失業給付'],
    ),
    TaiwanStatuteCanonEntry(
      statuteId: 'labor_14',
      lawName: '《勞動基準法》',
      articleNumber: '第 14 條第 1 項',
      domain: TaiwanDisputeDomain.laborAndEmployment,
      officialText:
          '有左列情形之一者，勞工得不經預告終止契約：一、雇主於訂立勞動契約時為虛偽之意思表示，使勞工誤信而有受損害之虞者。二、雇主、雇主家屬、雇主代理人對於勞工，實施暴行或有重大侮辱之行為者。五、雇主不依勞動契約給付工作報酬。六、雇主違反勞動契約或勞工法令，致有損害勞工權益之虞者。',
      plainSummary: '如果老闆欠薪、高薪低報、打罵侮辱員工、或強迫違法加班，勞工可以主動發函「被迫離職」，不用預告直接走人，而且老闆依然必須全額發給資遣費！',
      constituentElements: [
        '雇主有欠薪、高薪低報、重大侮辱或違反勞動法令之客觀情事',
        '勞工於知悉之日起 30 日內行使終止權（適用第1、6款情形）',
      ],
      legalEffects: [
        '勞工合法取得即時終止勞動契約之權利，無須預告',
        '準用第 17 條規定，雇主仍應給付法定資遣費並開立非自願離職證明',
      ],
      limitationPeriodYears: 0.08,
      limitationPeriodDescription: '勞工依第 1 款、第 6 款終止契約者，應自知悉其情形之日起「三十日內」為之（第 14 條第 2 項）。',
      defenseAndEvidenceGuide: [
        '欠薪之銀行存摺明細與薪資單',
        '勞保投保明細表（佐證高薪低報事實）',
        '記載依勞動基準法第 14 條終止契約之存證信函原本及送達回執',
      ],
      disputeCategories: ['被迫離職', '欠薪資遣', '高薪低報'],
    ),
    TaiwanStatuteCanonEntry(
      statuteId: 'labor_17',
      lawName: '《勞動基準法》第 17 條 &《勞工退休金條例》',
      articleNumber: '第 12 條',
      domain: TaiwanDisputeDomain.laborAndEmployment,
      officialText:
          '勞工適用本條例之退休金制度者，其資遣費由雇主按其工作年資，每滿一年發給二分之一個月之平均工資，未滿一年者，以比例計給；最高以發給六個月平均工資為限。',
      plainSummary: '勞退新制資遣費計算標準：每在公司工作滿 1 年，老闆就要給「半個月平均工資」的資遣費；未滿 1 年依比例計算，最高上限為 6 個月薪水。',
      constituentElements: [
        '勞工適用勞工退休金條例新制',
        '契約依勞基法第 11 條或第 14 條終止',
      ],
      legalEffects: [
        '雇主應於契約終止後「三十日內」給付資遣費；逾期得處新台幣 30 萬以上 150 萬元以下罰鍰',
      ],
      limitationPeriodYears: 5.0,
      limitationPeriodDescription: '請求權時效 5 年。',
      defenseAndEvidenceGuide: [
        '在職近 6 個月之完整薪資單（包含固定底薪、績效獎金及津貼）',
        '勞退提繳年資明細',
      ],
      disputeCategories: ['資遣費計算', '平均工資', '勞工退休金條例'],
    ),
    TaiwanStatuteCanonEntry(
      statuteId: 'labor_24',
      lawName: '《勞動基準法》',
      articleNumber: '第 24 條',
      domain: TaiwanDisputeDomain.laborAndEmployment,
      officialText:
          '雇主延長勞工工作時間者，其延長工作時間之工資，依左列標準加給：一、延長工作時間在二小時以內者，按平日每小時工資額加給三分之一以上。二、再延長工作時間在二小時以內者，按平日每小時工資額加給三分之二以上。',
      plainSummary: '平日加班前 2 小時，時薪要加乘 1.34 倍；第 3、4 小時要加乘 1.67 倍。老闆不能以責任制為藉口不給加班費！',
      constituentElements: [
        '雇主指派、默示同意或受領勞工於正常工作時間外提供勞務',
      ],
      legalEffects: [
        '雇主應按法定比例計算並全額給付平日延時加班費',
      ],
      limitationPeriodYears: 5.0,
      limitationPeriodDescription: '工資請求權消滅時效 5 年（民法第 126 條）。',
      defenseAndEvidenceGuide: [
        '上下班出勤打卡紀錄、門禁刷卡紀錄、電腦登入登出時間戳記',
        '非上班時間主管透過通訊軟體交辦公務之對話截圖與時間',
        '薪資單（核對加班費項目是否有短少給付）',
      ],
      disputeCategories: ['加班費', '責任制違法', '平日延長工時'],
    ),
    TaiwanStatuteCanonEntry(
      statuteId: 'labor_38',
      lawName: '《勞動基準法》',
      articleNumber: '第 38 條',
      domain: TaiwanDisputeDomain.laborAndEmployment,
      officialText:
          '勞工在同一雇主或事業單位，繼續工作滿一定期間者，應依規定給予特別休假。勞工之特別休假，因年度終結或契約終止而未休之日數，雇主應發給工資。',
      plainSummary: '每年沒休完的特休假，或者是離職退保時還剩下的特休，老闆必須「折算法定一日工資」折算現金發給員工，不能直接將特休歸零蒸發！',
      constituentElements: [
        '勞工具有法定特別休假額度',
        '年度終結或離職終止契約時，仍有尚未休畢之日數',
      ],
      legalEffects: [
        '雇主負有將未休特休日數折算發給一日工資之法定義務',
      ],
      limitationPeriodYears: 5.0,
      limitationPeriodDescription: '工資請求權消滅時效 5 年。',
      defenseAndEvidenceGuide: [
        '公司人事特休假剩餘天數截圖或出勤假單紀錄',
        '離職月薪資結算明細單',
      ],
      disputeCategories: ['特休未休工資', '特休折現', '特別休假'],
    ),
    TaiwanStatuteCanonEntry(
      statuteId: 'labor_59',
      lawName: '《勞動基準法》',
      articleNumber: '第 59 條',
      domain: TaiwanDisputeDomain.laborAndEmployment,
      officialText:
          '勞工因遭遇職業災害而致死亡、失能、傷害或疾病時，雇主應依左列規定予以補償：一、勞工受傷或罹患職業病時，雇主應補償其必需之醫療費用。二、勞工在醫療中不能工作時，雇主應按其原領工資數額予以補償。',
      plainSummary: '勞工因公受傷（包含上下班通勤車禍），老闆要全額補償醫療費，且在醫療不能上班期間，老闆每個月要照常給付「100% 原領工資」！',
      constituentElements: [
        '勞工遭遇工作執行或合理上下班必經途中之職業災害',
        '勞工因而受傷、罹病、失能或死亡',
      ],
      legalEffects: [
        '雇主負無過失之法定補償責任',
        '醫療期間雇主不得終止勞動契約（第 13 條）',
        '雇主已依法給付勞保職災保險金者得主張抵充',
      ],
      limitationPeriodYears: 2.0,
      limitationPeriodDescription: '受領補償之權利，自得受領之日起，因二年間不行使而消滅（第 61 條）。',
      defenseAndEvidenceGuide: [
        '勞動部勞保局核定之職業傷病給付核准函',
        '診斷證明書載明就診原因為職業傷病',
      ],
      disputeCategories: ['職業災害', '原領工資補償', '職災醫療費用'],
    ),

    // -------------------------------------------------------------
    // 五、消費者保護與瑕疵擔保 (Consumer Protection & Sales Defect)
    // -------------------------------------------------------------
    TaiwanStatuteCanonEntry(
      statuteId: 'consumer_19',
      lawName: '《消費者保護法》',
      articleNumber: '第 19 條第 1 項',
      domain: TaiwanDisputeDomain.consumerProtection,
      officialText:
          '通訊交易或訪問交易之消費者，得於收受商品或接受服務後七日內，以書面通知方式解除契約，無須說明理由及負擔任何費用或對價。',
      plainSummary: '網路購物、電視購物等「通訊交易」，消費者在收到貨的「7 天鑑賞期內」，不需要任何理由就可以退貨退款，賣家不能強迫買家自付退貨運費或手續費！',
      constituentElements: [
        '屬於消費者對企業經營者之消費關係',
        '交易型態屬於通訊交易（如網購、App 訂購、直播購物）',
        '消費者於收受商品後 7 日內提出解約退款意思表示',
        '不屬於通訊交易解除權合理例外情事準則所定項目（如易腐生鮮、客製化等）',
      ],
      legalEffects: [
        '買賣契約溯及消滅',
        '消費者無須負擔退回商品之運費或任何對價費用（第 19 條第 1 項但書）',
        '業者應於收回商品後 15 日內無息退還已收全部價金（第 19-2 條）',
      ],
      limitationPeriodYears: 0.02,
      limitationPeriodDescription: '消保法 7 日猶豫除斥期間，收受次日起算第 7 日屆滿。',
      defenseAndEvidenceGuide: [
        '網購電商平台訂單明細與收件物流簽收追蹤截圖（證明 7 日內發動）',
        '向賣家反映退貨之通訊對話截圖或存證信函',
        '未拆封或為檢查必要而拆封之完整開箱錄影',
      ],
      disputeCategories: ['網購退貨', '7天鑑賞期', '猶豫期退款'],
    ),
    TaiwanStatuteCanonEntry(
      statuteId: 'consumer_7',
      lawName: '《消費者保護法》',
      articleNumber: '第 7 條',
      domain: TaiwanDisputeDomain.consumerProtection,
      officialText:
          '從事設計、生產、製造商品或提供服務之企業經營者，於提供商品流通進入市場，或提供服務時，應確保該商品或服務，符合當時科技或專業水準可合理期待之安全性。商品或服務具有危害消費者生命、身體、健康、財產之可能者，應於明顯處為警告標示及緊急處理危險之方法。',
      plainSummary: '廠商生產的商品如果品質有安全危險（如除濕機自燃、化妝品過敏潰爛、食品中毒），造成消費者身體或財物損害，製造商必須負無過失之商品責任！',
      constituentElements: [
        '企業經營者生產、製造或提供商品流通於市場',
        '商品欠缺當時科技水準可合理期待之安全性',
        '致消費者生命、身體、健康或財產受有損害',
      ],
      legalEffects: [
        '企業經營者應負無過失之連帶損害賠償責任',
        '消費者得請求最高三倍之懲罰性賠償金（第 51 條）',
      ],
      limitationPeriodYears: 2.0,
      limitationPeriodDescription: '侵權責任 2 年。',
      defenseAndEvidenceGuide: [
        '商品原本、發票、瑕疵自燃特寫照片',
        '消防局火災調查鑑定書或公立醫院診斷證明',
      ],
      disputeCategories: ['產品責任', '商品安全', '懲罰性賠償'],
    ),
    TaiwanStatuteCanonEntry(
      statuteId: 'civil_354',
      lawName: '《民法》',
      articleNumber: '第 354 條',
      domain: TaiwanDisputeDomain.consumerProtection,
      officialText:
          '物之出賣人對於買受人，應擔保其物依第三百七十三條之規定危險移轉於買受人時無滅失或減少其價值之瑕疵，亦無滅失或減少其通常效用或契約預定效用之瑕疵。',
      plainSummary: '賣家賣出的東西，負有保證交貨時「沒有瑕疵、具備通常正常功能」的法定義務（例如買二手車不能是泡水車、買手機不能黑屏）。',
      constituentElements: [
        '買賣契約關係成立並交付標的物',
        '標的物存在減少其價值或通常效用之客觀瑕疵',
      ],
      legalEffects: [
        '出賣人負物之瑕疵擔保責任（無過失責任）',
      ],
      limitationPeriodYears: 5.0,
      limitationPeriodDescription: '通知出賣人後 6 個月不行使而消滅（民法第 365 條）。',
      defenseAndEvidenceGuide: [
        '買賣契約書、商品保證書、對話紀錄',
        '開箱受損照片、第三方維修檢驗報告',
      ],
      disputeCategories: ['物之瑕疵', '二手買賣', '瑕疵擔保'],
    ),
    TaiwanStatuteCanonEntry(
      statuteId: 'civil_359',
      lawName: '《民法》',
      articleNumber: '第 359 條',
      domain: TaiwanDisputeDomain.consumerProtection,
      officialText:
          '買賣因物有瑕疵，而出賣人依前五條之規定，應負擔保之責者，買受人得解除其契約或請求減少其價金。但依情形，解除契約顯失公平者，買受人僅得請求減少價金。',
      plainSummary: '買到的東西有重大瑕疵時，買家可以要求「全額退貨退款（解約）」；若瑕疵輕微，買家可以要求「扣減價金折讓金額」。',
      constituentElements: [
        '出賣人物之瑕疵擔保責任成立',
        '買受人已踐行檢查與即時通知義務（民法第 356 條）',
      ],
      legalEffects: [
        '買受人得發函向出賣人行使解除契約權，請求退還價金',
        '或行使減少價金請求權，請求返還溢付之折讓差額',
      ],
      limitationPeriodYears: 0.5,
      limitationPeriodDescription: '買受人依第 359 條規定所得為之解除契約或減少價金請求權，於買受人依第 356 條規定為通知後「六個月」間不行使或自物之交付時起經過五年而消滅（民法第 365 條）。',
      defenseAndEvidenceGuide: [
        '收到貨即刻向賣家反映瑕疵之通訊截圖',
        '專業原廠技師檢測出具之瑕疵故障判定單',
      ],
      disputeCategories: ['解約退款', '減少價金', '退換瑕疵品'],
    ),

    // -------------------------------------------------------------
    // 六、裝潢修繕與承攬工程 (Construction & Contractor)
    // -------------------------------------------------------------
    TaiwanStatuteCanonEntry(
      statuteId: 'civil_492',
      lawName: '《民法》',
      articleNumber: '第 492 條',
      domain: TaiwanDisputeDomain.constructionAndContract,
      officialText:
          '承攬人完成工作，應使其具備約定之品質及無減少或滅失價值或不適於通常或約定使用之瑕疵。',
      plainSummary: '統包工程或裝潢設計師施工完成後，必須保證品質符合當初報價單圖說合約，且沒有偷工減料或漏水傾斜等瑕疵。',
      constituentElements: [
        '成立承攬契約',
        '承攬人交付之工作物存在瑕疵',
      ],
      legalEffects: [
        '承攬人負法定無過失工作物瑕疵擔保責任',
      ],
      limitationPeriodYears: 1.0,
      limitationPeriodDescription: '瑕疵發見後 1 年（第 514 條）。',
      defenseAndEvidenceGuide: [
        '工程承攬契約書、報價單工料明細表',
        '施工後現場瑕疵拍照存證',
      ],
      disputeCategories: ['裝潢糾紛', '承攬品質', '工程驗收'],
    ),
    TaiwanStatuteCanonEntry(
      statuteId: 'civil_493',
      lawName: '《民法》',
      articleNumber: '第 493 條',
      domain: TaiwanDisputeDomain.constructionAndContract,
      officialText:
          '工作有瑕疵者，定作人得定相當期限，請求承攬人修補之。承攬人不於前項期限內修補者，定作人得自行修補，並得向承攬人請求償還修補必要之費用。如修補所需費用過鉅者，承攬人得拒絕修補，前項規定，不適用之。',
      plainSummary: '裝潢工程發現瑕疵時，業主應先給統包/設計師合理期限修補；如果對方拖延不理，業主可以找其他工班修繕，並將全部修補費用向原承攬人求償或從尾款扣抵。',
      constituentElements: [
        '承攬人交付之工作物存有不合約定之瑕疵',
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
    TaiwanStatuteCanonEntry(
      statuteId: 'civil_494',
      lawName: '《民法》',
      articleNumber: '第 494 條',
      domain: TaiwanDisputeDomain.constructionAndContract,
      officialText:
          '承攬人不於前條第一項所定期限內修補瑕疵，或依前條第三項之規定拒絕修補或其瑕疵不能修補者，定作人得解除契約或請求減少報酬。但瑕疵非重要，或所承攬之工作為建築物或其他土地上之工作物者，定作人不得解除契約。',
      plainSummary: '工程若無法修補或承攬人拒絕修補，業主可以依法請求「減少工程款（扣工程款）」；若非房屋建築物且瑕疵重大，甚至可以解除契約。',
      constituentElements: [
        '承攬人逾期不修補或拒絕修補',
      ],
      legalEffects: [
        '定作人得行使減少報酬請求權，直接扣除工程款',
      ],
      limitationPeriodYears: 1.0,
      limitationPeriodDescription: '1 年短期消滅時效。',
      defenseAndEvidenceGuide: [
        '減價計算書、第三方建築師或室內設計公會鑑定報價',
      ],
      disputeCategories: ['減少報酬', '工程扣款', '承攬解約'],
    ),

    // -------------------------------------------------------------
    // 七、妨害名譽與個資隱私 (Defamation & Privacy)
    // -------------------------------------------------------------
    TaiwanStatuteCanonEntry(
      statuteId: 'penal_309',
      lawName: '《刑法》',
      articleNumber: '第 309 條第 1 項',
      domain: TaiwanDisputeDomain.defamationAndPrivacy,
      officialText:
          '公然侮辱人者，處拘役或九千元以下罰金。',
      plainSummary: '在公開場合、網路公開社團、遊戲大廳、LINE公開群組等不特定人可看見之處，以髒話、三字經辱罵他人，會構成刑事「公然侮辱罪」。',
      constituentElements: [
        '行為處於公然狀態（多數人或不特定人得共見共聞之情狀）',
        '未指摘具體具備證明之事實，單純謾罵侮辱使人難堪',
      ],
      legalEffects: [
        '處拘役或罰金',
        '成立刑事犯罪，被害人得附帶民事請求民法 195 條精神賠償',
      ],
      limitationPeriodYears: 0.5,
      limitationPeriodDescription: '告訴乃論罪，自知悉犯人之時起「6 個月」內須向地檢署或警察局提出告訴。',
      defenseAndEvidenceGuide: [
        '完整未裁切之螢幕截圖（包含發文者帳號ID、社群網址URL、發言時間與群組人數）',
      ],
      disputeCategories: ['公然侮辱', '網路罵人', '妨害名譽'],
    ),
    TaiwanStatuteCanonEntry(
      statuteId: 'penal_310',
      lawName: '《刑法》',
      articleNumber: '第 310 條',
      domain: TaiwanDisputeDomain.defamationAndPrivacy,
      officialText:
          '意圖散布於眾，而指摘或傳述足以毀損他人名譽之事者，為誹謗罪，處一年以下有期徒刑、拘役或一萬五千元以下罰金。散布文字、圖畫犯前項之罪者，處二年以下有期徒刑、拘役或三萬元以下罰金。',
      plainSummary: '意圖讓大家知道，而在網路上爆料發文或用文字抹黑、造謠、指控特定人具體不實事項，足以毀損他人社會評價者，構成刑事「加重誹謗罪」。',
      constituentElements: [
        '意圖散布於眾',
        '指摘或傳述足以貶損他人社會評價之具體事件事實',
        '以文字、截圖、圖畫或網路貼文方式散布',
      ],
      legalEffects: [
        '處二年以下有期徒刑',
      ],
      limitationPeriodYears: 0.5,
      limitationPeriodDescription: '告訴乃論罪，告訴期間 6 個月。',
      defenseAndEvidenceGuide: [
        '網路抹黑貼文、留言串及轉貼數量之備份截圖與網址',
        '反駁該虛構不實事實之客觀澄情報導或官方公文',
      ],
      disputeCategories: ['誹謗罪', '網路爆料抹黑', '加重誹謗'],
    ),
    TaiwanStatuteCanonEntry(
      statuteId: 'privacy_act_19',
      lawName: '《個人資料保護法》',
      articleNumber: '第 19 條 & 第 41 條',
      domain: TaiwanDisputeDomain.defamationAndPrivacy,
      officialText:
          '非公務機關對個人資料之蒐集或處理，應有特定目的，並符合法定情形之一。意圖為自己或第三人不法之利益或損害他人之利益，而違反規定足生損害於他人者，處五年以下有期徒刑。',
      plainSummary: '未經同意擅自將他人的姓名、身分證字號、手機號碼、私人住址或個人照片PO到網路上「肉搜」或「公審」，會違反個人資料保護法並構成刑事犯罪！',
      constituentElements: [
        '非公務機關或個人違法蒐集、利用個人身分識別資料',
        '足生損害於當事人之權益或隱私',
      ],
      legalEffects: [
        '五年以下有期徒刑刑事責任',
        '依第 28 條請求被害人每人每一事件 500 元至 2 萬元之損害賠償',
      ],
      limitationPeriodYears: 2.0,
      limitationPeriodDescription: '民事請求權 2 年。',
      defenseAndEvidenceGuide: [
        '肉搜公審貼文之未碼個資截圖與網址存證',
      ],
      disputeCategories: ['肉搜公審', '個資外洩', '隱私侵權'],
    ),

    // -------------------------------------------------------------
    // 八、婚姻家庭與親屬糾紛 (Family & Divorce)
    // -------------------------------------------------------------
    TaiwanStatuteCanonEntry(
      statuteId: 'civil_1052',
      lawName: '《民法》',
      articleNumber: '第 1052 條',
      domain: TaiwanDisputeDomain.familyAndDivorce,
      officialText:
          '夫妻之一方，有左列情形之一者，他方得向法院請求離婚：一、重婚。二、與配偶以外之人合意性交。三、夫妻之一方對他方為不堪同居之虐待。……有前項以外之重大事由，難以維持婚姻者，夫妻之一方得請求離婚。但其事由應由夫妻之一方負責者，僅他方得請求離婚。',
      plainSummary: '配偶有外遇出軌、家暴虐待、遺棄惡意離家，或者夫妻長期分居、互不溝通感情破裂等重大事由，難以維持婚姻時，無過失或過失較輕的一方可以向法院訴請判決離婚。',
      constituentElements: [
        '具備法定判決離婚第 1 項各款客觀事由，或第 2 項難以維持婚姻之重大客觀破綻',
        '原告並非該破綻事由之唯一或主要可歸責者',
      ],
      legalEffects: [
        '法院判決宣告兩造婚姻關係消滅',
        '無過失配偶得請求他方賠償非財產上之精神損害賠償（民法第 1056 條）',
      ],
      limitationPeriodYears: 1.0,
      limitationPeriodDescription: '知悉外遇性交或虐待之事由者，自知悉後 1 年內須起訴（第 1053、1054 條）。',
      defenseAndEvidenceGuide: [
        '外遇曖昧通訊紀錄、共同出入摩鐵照片、徵信錄影',
        '驗傷診斷證明書、家暴通報紀錄、保護令裁定',
        '長期分居租賃合約、戶籍分遷證明',
      ],
      disputeCategories: ['裁判離婚', '外遇出軌', '家暴離婚', '夫妻分居'],
    ),
    TaiwanStatuteCanonEntry(
      statuteId: 'civil_1030_1',
      lawName: '《民法》',
      articleNumber: '第 1030 條之 1',
      domain: TaiwanDisputeDomain.familyAndDivorce,
      officialText:
          '法定財產制關係消滅時，夫或妻現存之婚後財產，扣除婚姻關係存續所負債務後，如有剩餘，其雙方剩餘財產之差額，應平均分配。但因繼承或其他無償取得之財產及慰撫金不在此限。',
      plainSummary: '離婚時夫妻各自清算「結婚後賺的財產與存款（扣除房貸負債）」，雙方差額可以「平分一半」；但是婚前財產、繼承的遺產或受贈財產不用平分。',
      constituentElements: [
        '法定財產制因離婚、死亡或改定財產制而歸於消滅',
        '夫或妻一方現存之婚後財產扣除負債後，大於他方之剩餘財產',
      ],
      legalEffects: [
        '財產較少之一方享有向財產較多之一方請求差額二分之一之金錢給付請求權',
      ],
      limitationPeriodYears: 2.0,
      limitationPeriodDescription: '自請求權人知有剩餘財產之差額時起，二年間不行使而消滅；自法定財產制關係消滅時起，逾五年者亦同（第 1030-1 條第 5 項）。',
      defenseAndEvidenceGuide: [
        '離婚起訴時雙方之全戶國稅局財產歸屬清單及年度所得清單',
        '銀行存款存摺、股票證券庫存對帳單、不動產登記謄本',
        '房貸或信貸餘額證明（扣除婚後負債）',
      ],
      disputeCategories: ['夫妻剩餘財產分配', '離婚分財產', '婚後財產差額'],
    ),
    TaiwanStatuteCanonEntry(
      statuteId: 'civil_1055',
      lawName: '《民法》',
      articleNumber: '第 1055 條 & 第 1055 條之 1',
      domain: TaiwanDisputeDomain.familyAndDivorce,
      officialText:
          '夫妻離婚者，對於未成年子女權利義務之行使或負擔，依協議由一方或雙方行使或負擔之。未為協議或協議不成者，法院得依夫妻之一方、主管機關、社會福利機構或其他利害關係人之請求或依職權酌定之。審酌時應以子女之最佳利益為考量。',
      plainSummary: '離婚時小孩監護權（親權）的歸屬，法院完全以「小孩最佳利益」為準則（主要照顧者原則、幼兒隨母原則、手足不分離原則），未照顧方每個月須負擔小孩生活扶養費。',
      constituentElements: [
        '兩造協議離婚或判決離婚，雙方對未成年子女親權行使或探視方式有爭執',
      ],
      legalEffects: [
        '法院依社工訪視報告酌定由單獨一方或雙方共同監護',
        '未行使親權之一方享有會面交往探視權',
        '命他方定期給付未成年子女扶養費至成年滿 18 歲為止',
      ],
      limitationPeriodYears: 15.0,
      limitationPeriodDescription: '未成年子女扶養費請求權直至成年為止。',
      defenseAndEvidenceGuide: [
        '平日親自接送、陪伴、就醫、聯絡簿簽名等日常照顧佐證照片',
        '家庭居住環境照片、收入工作穩定證明（薪轉、所得清單）',
        '小孩自身意願表達或社工訪視報告',
      ],
      disputeCategories: ['子女監護權', '親權爭取', '未成年子女扶養費', '探視權'],
    ),
    TaiwanStatuteCanonEntry(
      statuteId: 'domestic_violence_14',
      lawName: '《家庭暴力防治法》',
      articleNumber: '第 14 條',
      domain: TaiwanDisputeDomain.familyAndDivorce,
      officialText:
          '法院於審理終結後，認有家庭暴力之事實且有必要者，應依聲請或依職權核發包括下列一款或數款之通常保護令：一、禁止相對人對於被害人、目睹家庭暴力兒童及少年或其特定家庭成員實施家庭暴力。二、禁止相對人對於被害人為騷擾、接觸、跟蹤、通話、通信或其他非必要之聯絡行為。三、命相對人遷出被害人之住居所。四、命相對人遠離特定場所一定距離。',
      plainSummary: '遭遇同住家人或配偶、前配偶肢體暴力、言語恐嚇、精神虐待或騷擾，可以向法院聲請民事保護令；保護令核發後對方若敢再靠近或騷擾，會構成刑事「違反保護令罪」，警察可當場逮捕！',
      constituentElements: [
        '家庭成員或同居伴侶間存有身體或精神上之不法侵害暴力行為',
        '客觀上認有核發保護令防免繼續遭受家暴之實質必要性',
      ],
      legalEffects: [
        '核發禁止暴力、遠離令、遷出令、交出鑰匙',
        '違反者依第 61 條處三年以下有期徒刑之刑責',
      ],
      limitationPeriodYears: 2.0,
      limitationPeriodDescription: '通常保護令有效期間為二年以下，期滿得聲請延長。',
      defenseAndEvidenceGuide: [
        '醫院急診驗傷診斷書（詳載受傷範圍及成因）',
        '遭施暴施虐時之錄音、錄影或恐嚇辱罵通訊對話截圖',
        '向 113 或 110 報案警員出勤受處置紀錄單',
      ],
      disputeCategories: ['家庭暴力', '民事保護令', '精神騷擾', '遠離令'],
    ),

    // -------------------------------------------------------------
    // 九、遺產繼承與特留分 (Inheritance & Wills)
    // -------------------------------------------------------------
    TaiwanStatuteCanonEntry(
      statuteId: 'civil_1138',
      lawName: '《民法》',
      articleNumber: '第 1138 條 & 第 1144 條',
      domain: TaiwanDisputeDomain.inheritanceAndWills,
      officialText:
          '遺產繼承人，除配偶外，依左列順序定之：一、直系血親卑親屬。二、父母。三、兄弟姊妹。四、祖父母。配偶與第一順序之繼承人同為繼承時，其應繼分與他繼承人平均。',
      plainSummary: '長輩過世後，配偶是當然繼承人；子女（直系血親卑親屬）為第一順位，與配偶所有人平分遺產（應繼分均分）；無子女時才輪到父母或兄弟姊妹。',
      constituentElements: [
        '被繼承人死亡事實發生（繼承開始）',
        '具備法定法定繼承權資格（婚生子女、養子女享有完全同等權利）',
      ],
      legalEffects: [
        '繼承人自繼承開始時，承受被繼承人財產上之一切權利、義務',
        '按法定應繼分比例共有遺產，得隨時請求分割遺產',
      ],
      limitationPeriodYears: 15.0,
      limitationPeriodDescription: '遺產分割請求權無消滅時效；繼承回復請求權為知悉侵害起 2 年，繼承開始起 10 年（第 1146 條）。',
      defenseAndEvidenceGuide: [
        '被繼承人除戶戶籍謄本、除戶證明',
        '全體法定繼承人之現戶戶籍謄本與繼承系統表',
        '國稅局遺產稅財產參考清單及免稅/繳清證明書',
      ],
      disputeCategories: ['遺產繼承', '法定應繼分', '繼承人順位'],
    ),
    TaiwanStatuteCanonEntry(
      statuteId: 'civil_1148_2',
      lawName: '《民法》',
      articleNumber: '第 1148 條第 2 項',
      domain: TaiwanDisputeDomain.inheritanceAndWills,
      officialText:
          '繼承人對於被繼承人之債務，以因繼承所得遺產為限，負清償責任。',
      plainSummary: '台灣法律已全面改為「限定繼承」！長輩過世留下的債務，子女只用「拿到的遺產金額」去還，絕對不用掏出自己原本賺的私人財產去替父母還債！',
      constituentElements: [
        '被繼承人遺有超過遺產總額之債務',
        '繼承人依法開具遺產清冊陳報法院（民法第 1156 條）',
      ],
      legalEffects: [
        '有限責任：債權人不得強制執行繼承人之固有特有財產',
      ],
      limitationPeriodYears: 0.25,
      limitationPeriodDescription: '繼承人得於知悉得繼承之時起「三個月」內開具遺產清冊陳報法院（第 1156 條）。',
      defenseAndEvidenceGuide: [
        '向法院家事庭陳報遺產清冊之裁定證明',
        '被繼承人之聯徵中心信用報告及金融遺產查詢清單',
      ],
      disputeCategories: ['限定繼承', '拋棄繼承', '父債子還無效'],
    ),
    TaiwanStatuteCanonEntry(
      statuteId: 'civil_1223',
      lawName: '《民法》',
      articleNumber: '第 1223 條 & 第 1225 條',
      domain: TaiwanDisputeDomain.inheritanceAndWills,
      officialText:
          '繼承人之特留分，依左列各款之規定：一、直系血親卑親屬之特留分，為其應繼分二分之一。應得特留分之人，如因被繼承人所為之遺贈，致其應得之數不足者，得按其不足之數由遺贈財產扣減之。受贈人有數人時，應按其受贈價額比例扣減。',
      plainSummary: '就算長輩立遺囑說「全部遺產都給大哥，其他子女一毛都沒有」，其他子女依然享有法律強制保障的「特留分（應繼分的一半）」！子女可發函行使扣減權討回特留分。',
      constituentElements: [
        '法定特留分權利人（配偶、直系血親卑親屬、父母、兄弟姊妹）',
        '被繼承人之遺囑或生前特定贈與侵害特留分之法定保證份額',
      ],
      legalEffects: [
        '得發函行使「特留分扣減權」，自受遺贈人或受分配者處扣減返還應得份額',
      ],
      limitationPeriodYears: 2.0,
      limitationPeriodDescription: '特留分扣減權之消滅時效，實務依民法第 1146 條類推適用：自知悉侵害特留分時起二年間，或自繼承開始起逾十年不行使而消滅。',
      defenseAndEvidenceGuide: [
        '被繼承人所立遺囑原本或影本',
        '遺產總額價值清單（計算應繼分與特留分不足金額）',
        '行使特留分扣減之存證信函及收執證明',
      ],
      disputeCategories: ['特留分爭議', '扣減權', '遺囑偏袒侵害'],
    ),
    TaiwanStatuteCanonEntry(
      statuteId: 'civil_1190',
      lawName: '《民法》',
      articleNumber: '第 1190 條',
      domain: TaiwanDisputeDomain.inheritanceAndWills,
      officialText:
          '自書遺囑者，應自書遺囑全文，記明年、月、日，並親自簽名；如有增減、塗改，應註明增減、塗改之處所及字數，另行簽名。',
      plainSummary: '自己寫遺囑（自書遺囑）一定要「從頭到尾親筆手寫、記明年月日、親自簽名」；絕對不能用電腦打字列印出來再簽名，電腦打字印出的自書遺囑在法律上「完全無效」！',
      constituentElements: [
        '立遺囑人具備立遺囑能力（滿 16 歲且心智健全）',
        '親筆自書遺囑全部文句（不得以打字代之）',
        '完整載明年、月、日',
        '親自簽名（不得僅以蓋章或按指印代之）',
      ],
      legalEffects: [
        '遺囑自立遺囑人死亡時發生法定效力',
        '違反法定任一要件者，遺囑依民法第 73 條無效',
      ],
      limitationPeriodYears: 0.0,
      limitationPeriodDescription: '無效之法律行為自始、當然、確定無效。',
      defenseAndEvidenceGuide: [
        '親筆自書遺囑手稿原本',
        '立遺囑人生前平時親筆字跡筆記、書信或簽名比對樣本',
        '醫院生前無失智之精神心智能力診斷證明（防範被指控無行為能力）',
      ],
      disputeCategories: ['自書遺囑', '遺囑效力', '遺產分割爭議'],
    ),

    // -------------------------------------------------------------
    // 十、公司商務與合夥爭議 (Corporate & Partnership)
    // -------------------------------------------------------------
    TaiwanStatuteCanonEntry(
      statuteId: 'civil_686',
      lawName: '《民法》',
      articleNumber: '第 686 條 & 第 689 條',
      domain: TaiwanDisputeDomain.corporateAndPartnership,
      officialText:
          '合夥未定有存續期間，或經約定以合夥人中一人之終身為其存續期間者，各合夥人得聲明退夥，但應於兩個月前通知他合夥人。退夥人與他合夥人間之結算，應以退夥時合夥財產之狀況為準。合夥財產不足清償合夥之債務，退夥人應分擔其虧損。',
      plainSummary: '和朋友合夥做生意、開工作室鬧翻拆夥，合夥人可以提前 2 個月通知聲明退夥；退夥時必須以當下資產狀況完整查帳「結算退還出資額與盈餘款項」！',
      constituentElements: [
        '當事人具備合夥契約關係',
        '合夥人於 2 個月前合法發函聲明退夥通知',
      ],
      legalEffects: [
        '發生退夥之法定效力，兩造應依退夥時之資產狀況進行合夥財產查帳清算',
        '退夥人享有請求返還剩餘出資額及分派利益之請求權',
      ],
      limitationPeriodYears: 15.0,
      limitationPeriodDescription: '合夥利益與出資額結算返還請求權消滅時效 15 年。',
      defenseAndEvidenceGuide: [
        '合夥契約書、合作意向書或出資協議原本',
        '合夥出資匯款水單或資金投入設備發票',
        '提前 2 個月聲明退夥之存證信函及回執',
        '合夥營業銀行存摺明細、流水帳本及庫存資產清冊',
      ],
      disputeCategories: ['合夥拆夥', '退夥結算', '出資額返還', '查帳清算'],
    ),
    TaiwanStatuteCanonEntry(
      statuteId: 'company_23',
      lawName: '《公司法》',
      articleNumber: '第 23 條第 1 項',
      domain: TaiwanDisputeDomain.corporateAndPartnership,
      officialText:
          '公司負責人應忠實執行業務並盡善良管理人之注意義務，如有違反致公司受有損害者，負損害賠償責任。',
      plainSummary: '公司董事長、董事或經理人，必須為公司利益誠實經營，不能把公司公款中飽私囊、五鬼搬運或輸送利益給自己名下的私人公司，否則要賠償公司全部損失！',
      constituentElements: [
        '行為人為公司法所定之負責人（董事、清算人、經理人）',
        '違反忠實義務或善良管理人注意義務之執行業務行為',
        '造成公司受有實質財產損害',
      ],
      legalEffects: [
        '負責人對公司負法定損害賠償責任',
        '股東得依公司法第 214 條提起股東代表訴訟追償',
      ],
      limitationPeriodYears: 15.0,
      limitationPeriodDescription: '賠償請求權消滅時效 15 年。',
      defenseAndEvidenceGuide: [
        '公司設立登記事項卡（確認負責人身分）',
        '不合營業常規之關係人交易合約或不當資金挪用單據',
        '公司損益表與第三方會計師查核報告',
      ],
      disputeCategories: ['董事責任', '公司負責人掏空', '忠實義務', '背信賠償'],
    ),
    TaiwanStatuteCanonEntry(
      statuteId: 'company_111',
      lawName: '《公司法》',
      articleNumber: '第 111 條',
      domain: TaiwanDisputeDomain.corporateAndPartnership,
      officialText:
          '股東非得其他股東表決權過半數之同意，不得以其出資之全部或一部，轉讓於他人。董事非得其他全體股東同意，不得以其出資之全部或一部，轉讓於他人。',
      plainSummary: '有限公司的股東想把股份出資賣給外面的人，必須得到其他股東過半數同意；如果其他人不同意，其他股東依法享有優先受讓購買該出資額之權利。',
      constituentElements: [
        '有限公司股東欲轉讓其出資額',
        '踐行徵詢其他股東同意與優先受讓程序',
      ],
      legalEffects: [
        '未得法定同意所為之股權移轉對公司不生效力',
      ],
      limitationPeriodYears: 0.0,
      limitationPeriodDescription: '未得同意之處分行為效力未定。',
      defenseAndEvidenceGuide: [
        '股東出資額轉讓徵詢同意之正式函件',
        '股東會決議或全體股東同意書',
      ],
      disputeCategories: ['股權轉讓', '出資額變更', '有限公司股東糾紛'],
    ),
    TaiwanStatuteCanonEntry(
      statuteId: 'civil_250',
      lawName: '《民法》',
      articleNumber: '第 250 條 & 第 252 條',
      domain: TaiwanDisputeDomain.corporateAndPartnership,
      officialText:
          '當事人得約定債務人於債務不履行時，應支付違約金。約定之違約金額過高者，法院得減至相當之數額。',
      plainSummary: '商業合約或加盟契約裡如果寫了幾百萬、幾千萬天價的離譜違約金，被求償的一方可以依法向法院主張「違約金過高」，請求法官職權大幅酌減金額！',
      constituentElements: [
        '合約雙方約定有違約金條款',
        '約定之違約金與債權人實際所受損害顯不相當，客觀上過高',
      ],
      legalEffects: [
        '法院享有職權酌減權，得調降至合理之賠償數額',
      ],
      limitationPeriodYears: 15.0,
      limitationPeriodDescription: '違約金請求權消滅時效 15 年。',
      defenseAndEvidenceGuide: [
        '商業契約書原本（違約金約定文字）',
        '對造實際受損害極微或根本未受損害之佐證證據',
        '同業一般通常違約金行情報價水準',
      ],
      disputeCategories: ['違約金過高', '合約違約', '法院酌減違約金'],
    ),

    // -------------------------------------------------------------
    // 十一、智慧財產權與營業秘密 (Intellectual Property & Trade Secrets)
    // -------------------------------------------------------------
    TaiwanStatuteCanonEntry(
      statuteId: 'copyright_88',
      lawName: '《著作權法》',
      articleNumber: '第 88 條',
      domain: TaiwanDisputeDomain.intellectualProperty,
      officialText:
          '因故意或過失不法侵害他人之著作財產權或製版權者，負損害賠償責任。被害人得請求由侵害人因侵害行為所得之利益；如被害人不易證明其實際損害額，得請求法院依侵害情節，在新臺幣一萬元以上一百萬元以下酌定賠償額。如損害行為係故意且情節重大者，賠償額得增至新臺幣五百萬元。',
      plainSummary: '未經授權盜用抄襲他人的攝影照片、文章、插畫圖檔或軟體代碼，侵權者要負民事損害賠償；即使原創者算不出損失，也可以直接請求法院判賠 1 萬到 100 萬元法定賠償金！',
      constituentElements: [
        '原告享有原創性之著作權（著作完成即受保護，無須登記）',
        '被告未經授權實施重製、改作、公開傳輸等侵害行為',
        '具備接觸可能與實質相似之客觀要件',
      ],
      legalEffects: [
        '得請求排除侵害、銷毀侵權物品（第 84 條）',
        '得請求實際損害或 1 萬至 100 萬元（故意重大至 500 萬元）法定賠償金',
        '刑事依第 91 條負三年以下有期徒刑刑責',
      ],
      limitationPeriodYears: 2.0,
      limitationPeriodDescription: '知悉侵權及賠償義務人起 2 年，侵權行為時起逾 10 年消滅（第 89-1 條）。',
      defenseAndEvidenceGuide: [
        '著作原始發布時間戳記檔案、Raw 檔、原始工程碼提交紀錄（證明創作在先）',
        '對方抄襲比對表格（逐點列出構成實質相似之特徵）',
        '侵權網頁截圖及購買侵權商品之公證保全發票',
      ],
      disputeCategories: ['著作權侵權', '照片盜用', '文章抄襲', '法定賠償金'],
    ),
    TaiwanStatuteCanonEntry(
      statuteId: 'trademark_68',
      lawName: '《商標法》',
      articleNumber: '第 68 條 & 第 69 條',
      domain: TaiwanDisputeDomain.intellectualProperty,
      officialText:
          '未得商標權人同意，為行銷目的而有下列情形之一，為侵害商標權：一、於同一商品或服務，使用相同於註冊商標之商標者。二、於類似之商品或服務，使用相同或近似於註冊商標之商標，有致相關消費者混淆誤認之虞者。商標權人對於侵害其商標權者，得請求除去之；有侵害之虞者，得請求防止之。商標權人並得請求損害賠償。',
      plainSummary: '賣山寨仿冒品、或在類似商品上使用極度雷同的商標名字/LOGO造成買家混淆誤認，會構成商標侵權；商標權人可以要求全數銷毀下架，並依法請求高額查扣商品單價倍數賠償！',
      constituentElements: [
        '原告具備智慧財產局核准有效之商標註冊證',
        '被告為商業行銷目的使用相同或近似商標於同一或類似商品',
        '客觀上具有致消費者混淆誤認之虞',
      ],
      legalEffects: [
        '得請求排除及防止侵害（下架回收銷毀山寨品）',
        '依第 71 條得請求查獲仿冒品零售單價 1,500 倍之損害賠償金',
        '刑事依第 95 條處三年以下有期徒刑',
      ],
      limitationPeriodYears: 2.0,
      limitationPeriodDescription: '民事請求權知悉起 2 年。',
      defenseAndEvidenceGuide: [
        '經濟部智慧財產局商標註冊證影本',
        '公證人出具之侵權商品購買保全公證書或正仿品比對鑑定書',
      ],
      disputeCategories: ['商標侵權', '山寨仿冒', '混淆誤認', '商標求償'],
    ),
    TaiwanStatuteCanonEntry(
      statuteId: 'trade_secret_12',
      lawName: '《營業秘密法》',
      articleNumber: '第 12 條 & 第 13 條之 1',
      domain: TaiwanDisputeDomain.intellectualProperty,
      officialText:
          '因故意或過失不法侵害他人之營業秘密者，負損害賠償責任。如侵害行為屬故意者，法院得因被害人之請求，依侵害情節，酌定損害額以上之賠償。但不得超過已證明損害額之三倍。',
      plainSummary: '員工跳槽或離職時把老東家的客戶名單、未公開底價、技術配方或機密代碼打包帶走跳槽到競爭對手，要負民事最高 3 倍懲罰性賠償，且有 5 年以下有期徒刑的刑事責任！',
      constituentElements: [
        '該資訊具備秘密性（非一般人所知）',
        '具備經濟價值（能帶來商業競爭優勢）',
        '所有人已採取合理之保密措施（簽立保密協定NDA、設密碼權限控管）',
        '行為人以不正當方法取得、洩漏或使用',
      ],
      legalEffects: [
        '排除侵害及銷毀載體',
        '民事得請求證明損害額最高 3 倍之懲罰性賠償金',
        '刑事處五年以下有期徒刑（意圖域外使用者最高十年）',
      ],
      limitationPeriodYears: 2.0,
      limitationPeriodDescription: '知悉侵權及賠償義務人起 2 年，侵權行為起 10 年（第 12 條）。',
      defenseAndEvidenceGuide: [
        '離職員工簽署之員工保密合約 (NDA)',
        '伺服器檔案存取下載紀錄、外接隨身碟拷貝日誌 (Audit Log)',
        '證明該資料具備合理保密措施與存取權限控管證明',
      ],
      disputeCategories: ['營業秘密', '帶走客戶名單', '跳槽洩密', '懲罰性賠償'],
    ),

    // -------------------------------------------------------------
    // 十二、詐欺犯罪與人頭帳戶 (Fraud & Cybercrime)
    // -------------------------------------------------------------
    TaiwanStatuteCanonEntry(
      statuteId: 'penal_339',
      lawName: '《刑法》',
      articleNumber: '第 339 條 & 第 339 條之 4',
      domain: TaiwanDisputeDomain.fraudAndCybercrime,
      officialText:
          '意圖為自己或第三人不法之所有，以詐術使人將本人或第三人之物交付者，處五年以下有期徒刑、拘役或科或併科五十萬元以下罰金。犯詐欺罪而有下列情形之一者，處一年以上七年以下有期徒刑，得併科一百萬元以下罰金：一、冒用政府機關或公務員名義犯之。二、三人以上共同犯之。三、以廣播電視、電子通訊、網際網路或其他媒體等傳播工具，以散布於眾之方法犯之。',
      plainSummary: '透過投資群組話術、假交友、虛擬貨幣假平台騙錢，會構成「加重詐欺罪」，最輕要判 1 年以上、最重 7 年有期徒刑！被害人報警後應即刻要求銀行通報「警示帳戶」凍結款項。',
      constituentElements: [
        '行為人施用詐術（虛構不實高獲利投資、假檢警假公務員、假電商）',
        '使被害人陷於錯誤而處分交付財產或匯出款項',
        '具備三人以上、電信網路或冒充公務員等加重事由',
      ],
      legalEffects: [
        '加重詐欺處一年以上七年以下有期徒刑',
        '犯罪所得依法全額宣告沒收並發還被害人（刑法第 38-1 條）',
        '起訴後得提起刑事附帶民事訴訟，請求返還遭詐騙金額',
      ],
      limitationPeriodYears: 2.0,
      limitationPeriodDescription: '侵權損害賠償知悉起 2 年。',
      defenseAndEvidenceGuide: [
        '詐騙投資群組完整通訊截圖（LINE/Telegram）',
        '銀行臨櫃匯款水單、虛擬貨幣鏈上轉帳 Hash 與錢包地址',
        '警局報案三聯單及受理案件證明單',
      ],
      disputeCategories: ['投資詐騙', '假檢警詐欺', '網路交友詐騙', '加重詐欺'],
    ),
    TaiwanStatuteCanonEntry(
      statuteId: 'money_laundering_15_2',
      lawName: '《洗錢防制法》',
      articleNumber: '第 15 條之 2',
      domain: TaiwanDisputeDomain.fraudAndCybercrime,
      officialText:
          '任何人無正當理由不得將自己或他人向金融機構申請開立之帳戶、向提供虛擬資產服務或第三方支付服務之事業或人員申請之帳號交付、提供予他人使用。違反者由警察機關裁處告誡；經告誡後五年以內再犯者，處三年以下有期徒刑、拘役或科或併科新臺幣一百萬元以下罰金。',
      plainSummary: '把自己的銀行存摺、提款卡密碼借給或賣給別人（人頭帳戶），只要被詐騙集團當洗錢工具，帳戶會立刻被列為「警示帳戶」導致名下全部銀行卡被凍結，還會面臨刑事洗錢幫助犯起訴！',
      constituentElements: [
        '無正當理由將個人金融機構帳戶、提款卡、網路銀行帳號密碼交付他人',
        '提供之帳戶供他人作為收受犯罪不法所得之用',
      ],
      legalEffects: [
        '帳戶被警察機關通報為警示帳戶，所有衍生帳戶全部暫停非臨櫃交易',
        '面臨刑法詐欺幫助犯與洗錢防制法刑責追訴',
      ],
      limitationPeriodYears: 2.0,
      limitationPeriodDescription: '刑事追訴權時效 20 年；被害人民事求償 2 年。',
      defenseAndEvidenceGuide: [
        '當初受騙求職、貸款遭騙走提款卡之對話截圖（證明欠缺幫助洗錢故意）',
        '向警察機關掛失提款卡之報案記錄時間戳記',
      ],
      disputeCategories: ['人頭帳戶', '警示帳戶凍結', '洗錢防制法', '車手幫助犯'],
    ),
    TaiwanStatuteCanonEntry(
      statuteId: 'penal_315_1',
      lawName: '《刑法》',
      articleNumber: '第 315 條之 1 & 第 319 條之 3',
      domain: TaiwanDisputeDomain.fraudAndCybercrime,
      officialText:
          '有下列行為之一者，處三年以下有期徒刑、拘役或三十萬元以下罰金：一、無故利用工具或設備窺視、竊聽他人非公開之活動、言論、談話或身體隱私部位者。二、無故以錄音、照相、錄影或電磁紀錄竊錄他人非公開之活動、言論、談話或身體隱私部位者。未經他人同意，散布、播送、交付或公然陳列其性影像，處五年以下有期徒刑。',
      plainSummary: '在廁所、更衣室裝針孔偷拍，或分手後未經同意惡意在群組散布外流前任的性私密照片/影片（復仇式色情），最重可判處 5 年有期徒刑！',
      constituentElements: [
        '無故竊錄他人非公開之隱私活動或身體部位',
        '或未經同意散布他人性影像',
      ],
      legalEffects: [
        '處三年至五年以下有期徒刑',
        '被害人得請求高額非財產上精神慰撫金（民法第 195 條）',
      ],
      limitationPeriodYears: 0.5,
      limitationPeriodDescription: '刑法 315-1 為告訴乃論（6 個月）；散布性影像（319-3）為非告訴乃論公訴罪。',
      defenseAndEvidenceGuide: [
        '遭外流散布之群組截圖、貼文網址、下載原始檔案',
        '偷拍設備器物扣押照片',
      ],
      disputeCategories: ['針孔偷拍', '散布性影像', '妨害秘密', '私密照外流'],
    ),

    // -------------------------------------------------------------
    // 十三、物權相鄰與房屋漏水 (Property & Neighbor Disputes)
    // -------------------------------------------------------------
    TaiwanStatuteCanonEntry(
      statuteId: 'civil_767',
      lawName: '《民法》',
      articleNumber: '第 767 條第 1 項',
      domain: TaiwanDisputeDomain.propertyAndNeighbor,
      officialText:
          '所有人對於無權占有或侵奪其所有物者，得請求返還之。對於妨害其所有權者，得請求除去之。有妨害其所有權之虞者，得請求防止之。',
      plainSummary: '鄰居雜物堆到我家門口、車位被霸佔、土地被別人越界蓋圍牆，屋主可以依據民法第 767 條「物上請求權」，要求對方全部拆除搬走、清理乾淨並交還土地！',
      constituentElements: [
        '原告為不動產或動產之合法所有權人',
        '被告客觀上無正當合法權源占有或妨害該所有物',
      ],
      legalEffects: [
        '得請求遷讓返還房屋、土地',
        '得請求拆屋還地、清除路障雜物',
        '得同時請求相當於租金之不當得利（民法第 179 條）',
      ],
      limitationPeriodYears: 15.0,
      limitationPeriodDescription: '已登記之不動產所有物返還請求權，無消滅時效之適用（大法官釋字第 107 號解釋）。',
      defenseAndEvidenceGuide: [
        '地政事務所建物及土地所有權狀、最新第一類土地謄本',
        '遭無權侵占、堆放雜物現場照片及地政事務所測量成果圖',
      ],
      disputeCategories: ['物上請求權', '拆屋還地', '霸佔車位', '侵占土地'],
    ),
    TaiwanStatuteCanonEntry(
      statuteId: 'condo_management_10',
      lawName: '《公寓大廈管理條例》第 10 條 &《民法》',
      articleNumber: '第 12 條',
      domain: TaiwanDisputeDomain.propertyAndNeighbor,
      officialText:
          '專有部分之共同壁及樓地板或其內之管線，其維修費用由該共同壁雙方或樓上一方及樓下一方負擔。但修繕費係因可歸責於專有部分之所有人者，由該所有人負擔。專有部分、約定專用部分之修繕、管理、維護，由各該所有人或約定專用部分之使用人為之，並負擔其費用。',
      plainSummary: '樓上鄰居水管破裂造成樓下天花板滴水發霉，修繕費用原則由樓上全額負擔；樓上鄰居有義務配合開門讓水電工進去抓漏修復，不得拒絕！',
      constituentElements: [
        '公寓大廈區分所有建築物專有部分發生漏水瑕疵',
        '漏水源頭經查明係因樓上管線年久失修或改裝不良所致',
      ],
      legalEffects: [
        '樓下住戶得依第 6 條請求樓上容忍進入室內進行修繕工程',
        '樓上負擔全部止漏修繕工程費用',
        '得請求賠償天花板木作受損發霉及家具損害（民法第 184 條）',
      ],
      limitationPeriodYears: 2.0,
      limitationPeriodDescription: '損害賠償時效 2 年。',
      defenseAndEvidenceGuide: [
        '水電抓漏技師出具之滲漏水原因鑑定檢測報告書',
        '天花板滴水、壁癌受損照片及高階紅外線熱顯像儀檢測照',
        '催告樓上鄰居配合修繕之存證信函',
      ],
      disputeCategories: ['房屋漏水', '樓上漏水不修', '公寓大廈管委會', '鄰損求償'],
    ),
    TaiwanStatuteCanonEntry(
      statuteId: 'civil_787',
      lawName: '《民法》',
      articleNumber: '第 787 條',
      domain: TaiwanDisputeDomain.propertyAndNeighbor,
      officialText:
          '土地因與公路無適宜之聯絡，致不能為通常使用者，土地所有人得通行周圍地以至公路。前項情形，有通行權人應於通行必要之範圍內，擇其損害最少之處所及方法為之，對於通行地因此所受之損害，並應支付償金。',
      plainSummary: '土地四周都被別人的地包圍、沒有路可以通到對外公路（袋地），地主有權利通行周圍鄰居的土地出去，但要選擇對鄰居損害最小的路線，並補償地主租金。',
      constituentElements: [
        '土地與公路無適宜聯絡，無法為通常使用之袋地',
        '擇損害最小之通行處所及方法',
      ],
      legalEffects: [
        '享有袋地通行權，鄰地地主負容忍通行之義務，不得私設鐵門或圍籬阻擋',
      ],
      limitationPeriodYears: 0.0,
      limitationPeriodDescription: '隨物權存在，無時效消滅。',
      defenseAndEvidenceGuide: [
        '地政地籍圖謄本（證明土地四周均為他人土地無臨路）',
        '通行現況測量套繪圖與地主阻擋照片',
      ],
      disputeCategories: ['袋地通行權', '土地通行', '相鄰關係'],
    ),
    TaiwanStatuteCanonEntry(
      statuteId: 'civil_823',
      lawName: '《民法》',
      articleNumber: '第 823 條 & 第 824 條',
      domain: TaiwanDisputeDomain.propertyAndNeighbor,
      officialText:
          '各共有人，除法令另有規定外，得隨時請求分割共有物。共有物之分割，依共有人協議之方法行之。分割之方法不能協議決定者，法院得因任何共有人之請求，命為原物分割或變價分割以價金分配於各共有人。',
      plainSummary: '兄弟姊妹共同繼承或多人共同持有一塊地、一間房子，只要大家談不攏，任何一個共有人都可以隨時向法院起訴聲請「裁判分割共有物」，法院可判決變賣拍賣大家分錢！',
      constituentElements: [
        '數人按應有部分共有動產或不動產',
        '共有人間無法達成協議分割之合意',
        '無禁止分割之法令或合約約定',
      ],
      legalEffects: [
        '法院裁判命原物分割、金錢補償或整棟房屋公開變價拍賣分配價金',
      ],
      limitationPeriodYears: 0.0,
      limitationPeriodDescription: '分割請求權隨同共有物所有權存在，無消滅時效。',
      defenseAndEvidenceGuide: [
        '土地建物登記謄本（證明共有人持分比例）',
        '調解不成立證明書或協商破局證據',
        '原物分割方案草圖或變價拍賣主張書狀',
      ],
      disputeCategories: ['共有物分割', '變價拍賣', '共同持分土地', '祖產分割'],
    ),

    // -------------------------------------------------------------
    // 十四、保險理賠與醫療糾紛 (Insurance & Medical Malpractice)
    // -------------------------------------------------------------
    TaiwanStatuteCanonEntry(
      statuteId: 'insurance_29',
      lawName: '《保險法》第 29 條 &',
      articleNumber: '第 131 條',
      domain: TaiwanDisputeDomain.insuranceAndMedical,
      officialText:
          '保險人對於由不可預料或不可抗力之事故所致之損害，負賠償責任。傷害保險人於被保險人遭受意外傷害及其所致失能或死亡時，負給付保險金額之責。前項意外傷害，指非由疾病引起之外來突發事故所致者。',
      plainSummary: '買了意外險，只要受傷或死亡是「非疾病、外來的、突發的」（例如走在路上摔倒、車禍骨折），保險公司就必須全額理賠，不得無故藉口是個人既往體質而拒賠！',
      constituentElements: [
        '被保險人投保有效意外傷害保險',
        '事故具備「外來性」、「突發性」及「非疾病引起」三大法定要件',
      ],
      legalEffects: [
        '保險公司應於約定期限內給付保險金，逾期依第 34 條加計年息一分（10%）之遲延利息',
      ],
      limitationPeriodYears: 2.0,
      limitationPeriodDescription: '保險法第 65 條：由保險契約所生之權利，自得為請求之日起，經過二年不行使而消滅。',
      defenseAndEvidenceGuide: [
        '保險單原本或電子保單號碼',
        '醫院急診病歷、診斷證明書（載明外傷成因）',
        '向保險公司申請理賠之收件證明及保險公司正式拒賠函',
      ],
      disputeCategories: ['保險拒賠', '意外險爭議', '外來突發事故', '遲延利息10%'],
    ),
    TaiwanStatuteCanonEntry(
      statuteId: 'insurance_64',
      lawName: '《保險法》',
      articleNumber: '第 64 條',
      domain: TaiwanDisputeDomain.insuranceAndMedical,
      officialText:
          '訂立契約時，要保人對於保險人之書面詢問，應據實說明。要保人有為隱匿或遺漏不實之說明，足以變更或減少保險人對於危險之估計者，保險人得解除契約；其危險發生後亦同。但自保險人知有解除之原因後，經過一個月不行使而消滅；或契約訂立後經過二年，即有可以解除之原因，亦不得解除契約。',
      plainSummary: '投保時雖然有告知義務，但如果保險買了已經超過「2 年」，就算當初健康告知有疏漏，保險公司法律上也「絕對不能解除契約」或拒賠！',
      constituentElements: [
        '要保人於投保時告知事項之爭端',
        '契約訂立至今是否已逾二年之法定除斥期間',
      ],
      legalEffects: [
        '契約訂立超過二年後，保險公司喪失契約解除權，仍負理賠之責',
      ],
      limitationPeriodYears: 2.0,
      limitationPeriodDescription: '保險公司解除權於知悉後 1 個月或契約訂立後 2 年消滅。',
      defenseAndEvidenceGuide: [
        '保險投保日生效紀錄（佐證契約生效已滿 2 年）',
        '保險公司解約通知函',
      ],
      disputeCategories: ['保險告知義務', '保險公司解約無效', '二年除斥期間'],
    ),
    TaiwanStatuteCanonEntry(
      statuteId: 'medical_act_82',
      lawName: '《醫療法》第 82 條 &《民法》',
      articleNumber: '第 184 條',
      domain: TaiwanDisputeDomain.insuranceAndMedical,
      officialText:
          '醫療機構及其醫事人員因執行業務致損害於病人，以故意或違反醫療上必要之注意義務且逾越合理臨床專業裁量所致者為限，負損害賠償責任。醫事人員執行業務致病人死傷者，以故意或違反醫療上必要之注意義務且逾越合理臨床專業裁量，範圍內所致者，負刑事責任。',
      plainSummary: '發生醫療糾紛時，醫師如果違反常規注意義務（如開錯藥、手術遺留紗布、重大漏診），病患及家屬可以請求損害賠償；應第一時間向醫院申請複製「全本全份完整病歷」！',
      constituentElements: [
        '醫事人員有執行醫療業務行為',
        '違反醫療上必要之注意義務且逾越合理臨床專業裁量（醫療常規過失）',
        '病患因此受有身體死傷之損害結果',
      ],
      legalEffects: [
        '醫療機構與醫師連帶負民事損害賠償責任',
      ],
      limitationPeriodYears: 2.0,
      limitationPeriodDescription: '民事侵權 2 年；業務過失致死傷刑事追訴時效 20 年。',
      defenseAndEvidenceGuide: [
        '向醫院依醫療法第 71 條全額申請之完整病歷（含護理紀錄、手術紀錄、麻醉紀錄、檢驗報告影像光碟）',
        '衛福部醫事審議委員會鑑定意見書',
      ],
      disputeCategories: ['醫療糾紛', '醫療過失', '病歷申請', '醫預法調解'],
    ),

    // -------------------------------------------------------------
    // 十五、強制執行與保全程序 (Compulsory Enforcement & Injunctions)
    // -------------------------------------------------------------
    TaiwanStatuteCanonEntry(
      statuteId: 'civil_procedure_508',
      lawName: '《民事訴訟法》',
      articleNumber: '第 508 條 & 第 511 條',
      domain: TaiwanDisputeDomain.compulsoryEnforcement,
      officialText:
          '債權人之請求，以給付金錢或其他代替物或有價證券之一定數量為標的者，得聲請法院依督促程序發支付命令。聲請應表明當事人及法定代理人、請求之標的及其數量、請求之原因事實、應發支付命令之陳述及管轄法院。',
      plainSummary: '對方欠錢不還，只要花 500 元向法院聲請「支付命令」，對方在收到後「20 天內」如果沒有提異議，支付命令就會確定，可以直接拿去查封對方的薪水、存款或名下房屋！',
      constituentElements: [
        '請求標的為一定金額之金錢債權（確定數額）',
        '債權已屆清償期，且有釋明債權之具體證據（借據、對話、匯款單）',
        '債務人在我國有送達地址（非國外亦非公示送達）',
        '向債務人戶籍所在地之管轄地方法院提出聲請',
      ],
      legalEffects: [
        '法院形式審查通過後核發支付命令',
        '債務人收受後 20 日內未合法異議者，支付命令得為執行名義',
        '債權人得執確定證明書聲請強制執行（查封薪水、存款、不動產）',
      ],
      limitationPeriodYears: 0.05,
      limitationPeriodDescription: '債務人於收受送達後二十日之不變期間內得提出異議；逾期異議不合法。',
      defenseAndEvidenceGuide: [
        '民事支付命令聲請狀（記載請求標的與原因事實）',
        '證明金錢債權存在之證據原本（契約、借據、本票、匯款明細、通訊確認欠款紀錄）',
        '相對人（債務人）最新個人戶籍謄本（法院命補正時繳納）',
        '裁判費新台幣 500 元繳納收據',
      ],
      disputeCategories: ['支付命令', '督促程序', '強制執行', '欠款催收'],
    ),
    TaiwanStatuteCanonEntry(
      statuteId: 'civil_procedure_522',
      lawName: '《民事訴訟法》',
      articleNumber: '第 522 條 & 第 532 條',
      domain: TaiwanDisputeDomain.compulsoryEnforcement,
      officialText:
          '債權人就金錢請求或得易為金錢請求之請求，欲保全強制執行者，得聲請假扣押。債權人就金錢請求以外之請求，欲保全強制執行者，得聲請假處分。假扣押、假處分之聲請，應釋明其請求及假扣押、假處分之原因。',
      plainSummary: '打官司前如果發現對方正在偷偷脫產、賣房子或領光存款，債權人可以先向法院聲請「假扣押（凍結資產）」或「假處分（禁止賣房）」，防止贏了官司卻拿不到一毛錢！',
      constituentElements: [
        '有金錢請求之本案請求存在',
        '有日後不能強制執行或甚難執行之虞（如債務人頻繁脫產、變賣唯一房屋、逃匿）',
        '債權人釋明原因並提供擔保金（通常為債權額三分之一）',
      ],
      legalEffects: [
        '法院裁定准予假扣押，債權人提存擔保金後立即查封扣押相對人存款與房產',
      ],
      limitationPeriodYears: 0.0,
      limitationPeriodDescription: '保全處分，本案訴訟提起前或進行中均得隨時為之。',
      defenseAndEvidenceGuide: [
        '債權證明單據',
        '債務人企圖脫產之證據（房屋掛牌急售截圖、開脫產通訊對話）',
      ],
      disputeCategories: ['假扣押', '假處分', '保全程序', '防範脫產'],
    ),
    TaiwanStatuteCanonEntry(
      statuteId: 'enforcement_act_115',
      lawName: '《強制執行法》',
      articleNumber: '第 115 條 & 第 115 條之 1',
      domain: TaiwanDisputeDomain.compulsoryEnforcement,
      officialText:
          '就債務人對於第三人之金錢債權為執行時，執行法院應發扣押命令，禁止債務人收取或為其他處分，並禁止第三人向債務人清償。對於薪津或其他繼續性給付之債權所為強制執行，於加計生活費用之扣除額後，以扣押其每月得受領數額三分之一為限。',
      plainSummary: '拿到法院勝訴判決或確定支付命令後，可以請法院強制執行扣押債務人的銀行戶頭存款，或者發命令給對方公司，每個月直接扣走對方薪水的「三分之一」直到還清為止！',
      constituentElements: [
        '債權人持有合法有效之執行名義（判決、支付命令確定證明、本票裁定、公證書）',
        '查明債務人任職公司或有往來之金融機構帳戶',
      ],
      legalEffects: [
        '法院核發執行命令扣押其銀行存款及每月薪資三分之一',
        '核發收取命令或移轉命令直接將款項交付債權人',
      ],
      limitationPeriodYears: 5.0,
      limitationPeriodDescription: '執行名義因換發債權憑證得中斷時效；債權憑證應於法定期間內定期聲請換發。',
      defenseAndEvidenceGuide: [
        '民事確定判決書及確定證明書原本、或確定之支付命令原本',
        '向國稅局調取之債務人年度財產所得清單（查出任職公司與銀行帳號）',
      ],
      disputeCategories: ['扣押薪水', '強制執行查封', '銀行存款扣押', '債權憑證'],
    ),

    // -------------------------------------------------------------
    // 十六、公法救濟與國家賠償 (Administrative & State Compensation)
    // -------------------------------------------------------------
    TaiwanStatuteCanonEntry(
      statuteId: 'state_compensation_2',
      lawName: '《國家賠償法》',
      articleNumber: '第 2 條 & 第 3 條',
      domain: TaiwanDisputeDomain.administrativeAndPublic,
      officialText:
          '公務員於執行職務行使公權力時，因故意或過失不法侵害人民自由或權利者，國家應負損害賠償責任。公有公共設施因設置或管理有欠缺，致人民生命、身體、人身自由或財產受損害者，國家應負損害賠償責任。',
      plainSummary: '走在路上因為公有道路大坑洞摔成重傷、路樹倒塌砸爛車輛，或者是警察/公務員違法執行公權力造成人民傷亡損失，可以依法向政府機關申請「國家賠償」！',
      constituentElements: [
        '公務員違法行使公權力侵害人民權利，或公有公共設施之設置或管理有客觀欠缺',
        '人民受有生命、身體、人身自由或財產之實質損害',
        '兩者間具備相當因果關係',
      ],
      legalEffects: [
        '由賠償義務機關進行協議並負金錢賠償責任',
        '協議不成立時，得向地方法院提起國家賠償之民事訴訟（第 11 條）',
      ],
      limitationPeriodYears: 2.0,
      limitationPeriodDescription: '賠償請求權，自請求權人知有損害時起，因二年間不行使而消滅；自損害發生時起，逾五年者亦同（第 8 條第 1 項）。',
      defenseAndEvidenceGuide: [
        '公有道路坑洞、人孔蓋凹陷或倒塌路樹之現場特寫照片及全景錄影',
        '警方交通事故處理紀錄單',
        '醫療診斷證明書、醫藥費單據及車輛受損維修報價發票',
        '向該管工務局或公所提出之「國家賠償請求書」',
      ],
      disputeCategories: ['國家賠償', '道路坑洞摔車', '公有設施欠缺', '公務員違法'],
    ),
    TaiwanStatuteCanonEntry(
      statuteId: 'traffic_penalty_87',
      lawName: '《道路交通管理處罰條例》第 87 條 &《行政訴訟法》',
      articleNumber: '第 237 條之 1',
      domain: TaiwanDisputeDomain.administrativeAndPublic,
      officialText:
          '受處分人，不服第八條主管機關所為之處罰，得適用行政訴訟法簡易訴訟程序，向地方法院行政訴訟庭提起撤銷訴訟。應於裁決書送達後三十日之不變期間內為之。',
      plainSummary: '收到不合理的交通違規罰單（例如標線不清被冤枉闖紅燈、科技執法誤判），在拿到正式裁決書後「30 天內」，可以向地方法院行政訴訟庭提起「撤銷交通罰單之訴」！',
      constituentElements: [
        '收受各縣市交通事件裁決所開立之正式違規裁決書',
        '處分具備標線模糊、機器誤判、違規事證缺乏等違法瑕疵',
        '於裁決書送達後 30 日內提出起訴',
      ],
      legalEffects: [
        '法院裁判撤銷原違規罰鍰處分及記點處分，退還已繳納罰鍰',
      ],
      limitationPeriodYears: 0.08,
      limitationPeriodDescription: '自裁決書送達後 30 日之法定不變期間。',
      defenseAndEvidenceGuide: [
        '交通違規裁決書原本及舉發紅單',
        '行車記錄器錄影檔案或現場標線模糊不清特寫照片',
        '地方法院行政訴訟起訴狀（裁判費 300 元）',
      ],
      disputeCategories: ['交通罰單申訴', '撤銷裁決', '交審訴訟', '科技執法申訴'],
    ),
    TaiwanStatuteCanonEntry(
      statuteId: 'administrative_appeal_1',
      lawName: '《訴願法》第 1 條 & 14 條 及《行政訴訟法》',
      articleNumber: '第 4 條',
      domain: TaiwanDisputeDomain.administrativeAndPublic,
      officialText:
          '人民對於中央或地方機關之行政處分，認為違法或不當，致損害其權利或利益者，得依本法提起訴願。訴願之提起，應自行政處分達到或公告期滿之次日起三十日內為之。訴願決定逾期不為決定或不服訴願決定者，得向行政法院提起撤銷訴訟。',
      plainSummary: '政府機關（如環保局、建管處、國稅局）做出違法亂罰款、違法拆除或開罰處分，老百姓必須在收到處分書次日起「30 天內」提起「訴願」，才能進一步打行政訴訟撤銷罰單！',
      constituentElements: [
        '收受行政機關對外發生具體法律效果之違法行政處分',
        '於處分達到次日起 30 日內提起訴願（先行程序）',
      ],
      legalEffects: [
        '上級訴願管轄機關審查決定撤銷原處分',
        '若訴願遭駁回，得於二個月內向行政法院提起撤銷訴訟',
      ],
      limitationPeriodYears: 0.08,
      limitationPeriodDescription: '收受處分之次日起算「三十日」不變期間；逾期訴願將遭不受理駁回。',
      defenseAndEvidenceGuide: [
        '行政處分書原本及掛號送達郵戳（確認 30 日起算日）',
        '行政訴願書（載明處分違法侵害權益之法律理由與事實）',
      ],
      disputeCategories: ['行政訴願', '撤銷行政處分', '行政訴訟', '稅務環保裁罰申訴'],
    ),

    // -------------------------------------------------------------
    // 十七、通用民法契約與不當得利 (General Civil & Contract Fallback)
    // -------------------------------------------------------------
    TaiwanStatuteCanonEntry(
      statuteId: 'civil_179',
      lawName: '《民法》',
      articleNumber: '第 179 條',
      domain: TaiwanDisputeDomain.generalCivilAndContract,
      officialText:
          '無法律上之原因而受利益，致他人受損害者，應返還其利益。雖有法律上之原因，而其後已不存在者，亦同。',
      plainSummary: '在法律上如果「平白無故拿到好處或錢財，導致別人受損失」（例如銀行轉帳匯錯帳號對方不肯還、買賣解約後對方扣住貨款不退），可以依法請求「返還不當得利」！',
      constituentElements: [
        '一方受有財產上之客觀利益',
        '他方因此受有財產上損害',
        '受利益與受損害之間具備直接損益變動因果關係',
        '該利益之受領客觀上「欠缺法律上正當原因」',
      ],
      legalEffects: [
        '受領人應返還所受之利益（原物返還，不能返還者償還其價額）',
        '如為惡意受領人，並應加計法定利息（年息 5%）一併返還（第 182 條第 2 項）',
      ],
      limitationPeriodYears: 15.0,
      limitationPeriodDescription: '一般債權請求權消滅時效 15 年（民法第 125 條）。',
      defenseAndEvidenceGuide: [
        '銀行轉帳匯款紀錄或交易水單（證明受損方確實給付）',
        '合約已解除、無效或誤匯款項之事實存證',
        '催告返還款項之存證信函及送達回執',
      ],
      disputeCategories: ['不當得利', '匯錯帳號', '無法律上原因', '返還利益'],
    ),
    TaiwanStatuteCanonEntry(
      statuteId: 'civil_227',
      lawName: '《民法》',
      articleNumber: '第 227 條',
      domain: TaiwanDisputeDomain.generalCivilAndContract,
      officialText:
          '因可歸責於債務人之事由，致為不完全給付者，債權人得依關於給付遲延或給付不能之規定行使其權利。因不完全給付而生前項以外之損害者，債權人並得請求賠償。',
      plainSummary: '簽了合約買東西或委託服務，如果對方提供的東西殘缺不全、做一半爛尾，或者因為瑕疵導致你其他財物受損（加害給付），你可以向對方請求完全賠償！',
      constituentElements: [
        '債之關係有效成立',
        '債務人已提出給付但給付內容不合債之本旨（瑕疵給付）',
        '或因該瑕疵擴大造成債權人人身或財產受損（加害給付）',
        '具有可歸責於債務人之事由',
      ],
      legalEffects: [
        '得準用給付遲延催告補正或給付不能請求損害賠償並解除契約',
        '得請求加害給付之擴大損害賠償',
      ],
      limitationPeriodYears: 15.0,
      limitationPeriodDescription: '一般債務不履行請求權消滅時效 15 年。',
      defenseAndEvidenceGuide: [
        '民事合約書、委任合約或採購協議原本',
        '給付不完全、未達履約標準之檢驗紀錄與照片',
        '因瑕疵所致額外損失之發票及維修單據',
      ],
      disputeCategories: ['不完全給付', '債務不履行', '契約違約', '加害給付'],
    ),
    TaiwanStatuteCanonEntry(
      statuteId: 'civil_226',
      lawName: '《民法》',
      articleNumber: '第 226 條',
      domain: TaiwanDisputeDomain.generalCivilAndContract,
      officialText:
          '因可歸責於債務人之事由，致給付不能者，債權人得請求賠償損害。前項情形，給付一部不能者，若其他部分之履行，於債權人無利益時，債權人得拒絕該部之給付，並請求全部不履行之損害賠償。',
      plainSummary: '如果因為對方的過失（例如把賣給你的限量品或房屋偷偷賣給別人過戶），導致契約根本「無法履行（給付不能）」，你可以直接解除合約，並要求對方賠償全部損失！',
      constituentElements: [
        '成立有效契約債務',
        '給付已客觀或主觀確定不能履行',
        '給付不能之原因具有可歸責於債務人之事由',
      ],
      legalEffects: [
        '債權人得免除對待給付義務',
        '得依民法第 256 條直接解除契約（無須催告）',
        '得請求填補全部履行利益之損害賠償',
      ],
      limitationPeriodYears: 15.0,
      limitationPeriodDescription: '請求權時效 15 年。',
      defenseAndEvidenceGuide: [
        '合約原本、定金收據',
        '證明標的物已滅失、一物二賣他人或客觀無法給付之存證',
        '催告返還價金及損害賠償之函件',
      ],
      disputeCategories: ['給付不能', '解約求償', '違約賠償', '一物二賣'],
    ),
    TaiwanStatuteCanonEntry(
      statuteId: 'civil_172',
      lawName: '《民法》',
      articleNumber: '第 172 條 & 第 176 條',
      domain: TaiwanDisputeDomain.generalCivilAndContract,
      officialText:
          '未受委任，並無義務，而為他人管理事務者，其管理應依本人明示或可得而推知之意思，以有利於本人之方法為之。管理事務，利於本人，並不違反本人明示或可得而推知之意思者，管理人為本人支出必要或有益之費用，或負擔債務，或受損害時，得請求本人償還其費用及自支出時起之利息，或清償其所負擔之債務，或賠償其損害。',
      plainSummary: '沒有受託也沒有義務，為了鄰居或朋友好幫忙處理緊急事務（例如鄰居家失火幫忙叫救火隊滅火、幫受傷鄰居墊付急診費），幫忙的人可以依法向對方要求全額「償還墊付費用」！',
      constituentElements: [
        '未受委任亦無法律上義務',
        '客觀上為他人管理事務，且利於本人並合於本人意思',
        '管理人因此支出必要或有益費用',
      ],
      legalEffects: [
        '得向本人請求償還必要費用及自支出時起算法定利息（年息 5%）',
      ],
      limitationPeriodYears: 15.0,
      limitationPeriodDescription: '請求權時效 15 年。',
      defenseAndEvidenceGuide: [
        '墊付緊急支出之發票單據原本',
        '緊急處理狀況現場照片與通訊記錄',
      ],
      disputeCategories: ['無因管理', '代墊費用', '償還支出'],
    ),
  ];

  /// 智能判定文字所屬之爭議領域 (Domain Classifier)
  static TaiwanDisputeDomain detectDisputeDomain(String text) {
    final lower = text.toLowerCase();

    // 1. 強制執行、支付命令與保全程序（程序法優先）
    if (lower.contains('強制執行') || (lower.contains('扣押') && !lower.contains('押金')) || lower.contains('假扣押') || lower.contains('假處分') || lower.contains('查封') || lower.contains('拍賣') || lower.contains('支付命令')) {
      return TaiwanDisputeDomain.compulsoryEnforcement;
    }
    // 2. 租賃與不動產點交
    if (lower.contains('租') || lower.contains('房東') || lower.contains('房客') || lower.contains('押金') || lower.contains('退租') || lower.contains('租賃')) {
      return TaiwanDisputeDomain.rentalAndHousing;
    }
    // 3. 交通事故與侵權損害賠償
    if (lower.contains('車禍') || lower.contains('撞') || lower.contains('肇事') || lower.contains('追撞') || lower.contains('擦撞') || lower.contains('初判表')) {
      return TaiwanDisputeDomain.trafficAndTort;
    }
    // 4. 借貸、票據與欠款
    if (lower.contains('借據') || lower.contains('借錢') || lower.contains('借款') || lower.contains('借給') || lower.contains('借貸') || lower.contains('欠錢') || lower.contains('還錢') || lower.contains('本票') || lower.contains('支票') || lower.contains('消費借貸') || lower.contains('清償期限')) {
      return TaiwanDisputeDomain.loanAndDebt;
    }
    // 5. 勞資工資與資遣
    if (lower.contains('工資') || lower.contains('加班') || lower.contains('資遣') || lower.contains('薪水') || lower.contains('離職') || lower.contains('勞基法') || lower.contains('職災')) {
      return TaiwanDisputeDomain.laborAndEmployment;
    }
    // 6. 消費保護與網購退換
    if (lower.contains('網購') || lower.contains('鑑賞期') || lower.contains('退貨') || lower.contains('消保') || lower.contains('七天') || lower.contains('猶豫期')) {
      return TaiwanDisputeDomain.consumerProtection;
    }
    // 7. 裝潢修繕與工程承攬
    if (lower.contains('裝潢') || lower.contains('工程') || lower.contains('統包') || lower.contains('泥作') || lower.contains('尾款') || lower.contains('承攬') || lower.contains('裝修')) {
      return TaiwanDisputeDomain.constructionAndContract;
    }
    // 8. 妨害名譽、公然侮辱與個資
    if (lower.contains('公然侮辱') || lower.contains('誹謗') || lower.contains('罵人') || lower.contains('三字經') || lower.contains('肉搜') || lower.contains('個資') || lower.contains('名譽')) {
      return TaiwanDisputeDomain.defamationAndPrivacy;
    }
    // 9. 婚姻家庭與離婚親權
    if (lower.contains('離婚') || lower.contains('外遇') || lower.contains('出軌') || lower.contains('剩餘財產') || lower.contains('監護權') || lower.contains('親權') || lower.contains('扶養費') || lower.contains('家暴') || lower.contains('保護令')) {
      return TaiwanDisputeDomain.familyAndDivorce;
    }
    // 10. 遺產繼承與特留分
    if (lower.contains('繼承') || lower.contains('遺產') || lower.contains('特留分') || lower.contains('應繼分') || lower.contains('遺囑') || lower.contains('過世') || lower.contains('被繼承人')) {
      return TaiwanDisputeDomain.inheritanceAndWills;
    }
    // 11. 公司股權與合夥拆夥
    if (lower.contains('合夥') || lower.contains('拆夥') || lower.contains('股東') || lower.contains('出資額') || lower.contains('董事') || lower.contains('股份') || lower.contains('商業合約')) {
      return TaiwanDisputeDomain.corporateAndPartnership;
    }
    // 12. 智慧財產與商標著作權
    if (lower.contains('著作權') || lower.contains('商標') || lower.contains('抄襲') || lower.contains('盜用') || lower.contains('仿冒') || lower.contains('山寨') || lower.contains('營業秘密')) {
      return TaiwanDisputeDomain.intellectualProperty;
    }
    // 13. 詐欺犯罪與人頭帳戶
    if (lower.contains('詐騙') || lower.contains('詐欺') || lower.contains('人頭帳戶') || lower.contains('警示帳戶') || lower.contains('洗錢') || lower.contains('偷拍') || lower.contains('外流')) {
      return TaiwanDisputeDomain.fraudAndCybercrime;
    }
    // 14. 物權相鄰與房屋漏水
    if (lower.contains('漏水') || lower.contains('管委會') || lower.contains('壁癌') || lower.contains('天花板') || lower.contains('袋地') || lower.contains('共有物') || lower.contains('分割共有') || lower.contains('拆屋還地')) {
      return TaiwanDisputeDomain.propertyAndNeighbor;
    }
    // 15. 保險拒賠與醫療過失
    if (lower.contains('保險') || lower.contains('拒賠') || lower.contains('意外險') || lower.contains('醫療糾紛') || lower.contains('醫療過失') || lower.contains('開刀') || lower.contains('病歷')) {
      return TaiwanDisputeDomain.insuranceAndMedical;
    }
    // 16. 公法救濟、國家賠償與交通裁罰
    if (lower.contains('國家賠償') || lower.contains('國賠') || lower.contains('交通罰單') || lower.contains('科技執法') || lower.contains('訴願') || lower.contains('行政訴訟') || lower.contains('撤銷處分') || lower.contains('公務員')) {
      return TaiwanDisputeDomain.administrativeAndPublic;
    }

    // 17. 預設通用民法契約與不當得利
    return TaiwanDisputeDomain.generalCivilAndContract;
  }

  /// 依自然語言事實尋找最相符之法規典籍（前 N 筆）
  static List<TaiwanStatuteCanonEntry> findBestMatchingStatutes(
    String queryFacts, {
    int limit = 4,
  }) {
    final text = queryFacts.trim().toLowerCase();
    if (text.isEmpty) return entries.take(limit).toList();

    final detectedDomain = detectDisputeDomain(text);
    final scored = <TaiwanStatuteCanonEntry, double>{};

    for (final entry in entries) {
      double score = 0.0;

      // 1. 所屬領域加權 (+30 分)
      if (entry.domain == detectedDomain) {
        score += 30.0;
      }

      // 2. 領域標籤匹配 (+10 分)
      for (final cat in entry.disputeCategories) {
        if (text.contains(cat.toLowerCase())) {
          score += 10.0;
        }
      }

      // 3. 構成要件與白話關鍵字比對 (+3 分)
      final keywords = [
        ...entry.constituentElements,
        ...entry.plainSummary.split('，'),
      ];
      for (final kw in keywords) {
        if (kw.length >= 2 && text.contains(kw)) {
          score += 3.0;
        }
      }

      if (score > 0) {
        scored[entry] = score;
      }
    }

    final sorted = scored.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    if (sorted.isEmpty) {
      // 降級回該領域條文，或通用條文
      final domainEntries = entries.where((e) => e.domain == detectedDomain).toList();
      if (domainEntries.isNotEmpty) return domainEntries.take(limit).toList();
      return entries.where((e) => e.domain == TaiwanDisputeDomain.generalCivilAndContract).take(limit).toList();
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

  /// 取得指定領域之所有典籍條文
  static List<TaiwanStatuteCanonEntry> getEntriesByDomain(TaiwanDisputeDomain domain) {
    return entries.where((e) => e.domain == domain).toList(growable: false);
  }
}
