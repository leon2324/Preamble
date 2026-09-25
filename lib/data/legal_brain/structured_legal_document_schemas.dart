import 'package:preamble/data/documents/document_models.dart';

/// 臺灣法定公文書類別
enum TaiwanLegalDocumentKind {
  attestedDemandLetter, // 郵局標準存證信函
  settlementAgreement, // 民事調解 / 和解協議書
  paymentOrderPetition, // 督促程序支付命令聲請狀
  noticeOfTermination, // 終止契約通知函
}

/// 郵局標準存證信函結構（符合中華郵政存證信函規格）
class AttestedDemandLetter {
  const AttestedDemandLetter({
    required this.senderName,
    required this.senderAddress,
    this.senderPhone = '',
    required this.receiverName,
    required this.receiverAddress,
    this.receiverPhone = '',
    this.copyReceiverName = '',
    this.copyReceiverAddress = '',
    required this.subject,
    required this.factsAndReasons,
    required this.demands,
    required this.legalBasis,
    this.deadlineDays = 7,
    this.warningDisclaimer = '本函已委由郵局存查，如蒙期限內惠予履行，至感德便；若逾期置之不理，本人定將逕循民刑事司法程序究辦到底，絕不寬貸，特此函告。',
    this.attachments = const [],
    this.sendDate,
  });

  /// 寄件人姓名（法人則為公司名稱及法定代理人）
  final String senderName;

  /// 寄件人詳細通訊地址（含郵遞區號）
  final String senderAddress;

  /// 寄件人聯絡電話
  final String senderPhone;

  /// 收件人姓名
  final String receiverName;

  /// 收件人戶籍或營業登記地址（含郵遞區號）
  final String receiverAddress;

  /// 收件人電話
  final String receiverPhone;

  /// 副本收件人（如管區分局、消保官、管理委員會等，無則免填）
  final String copyReceiverName;

  /// 副本收件人地址
  final String copyReceiverAddress;

  /// 主旨（扼要指明請求事項與期限）
  final String subject;

  /// 事實與理由（段落條列）
  final List<String> factsAndReasons;

  /// 具體請求與履行條款
  final List<String> demands;

  /// 援引之法律依據條文
  final List<String> legalBasis;

  /// 履行限期天數
  final int deadlineDays;

  /// 警告及保留追訴條款
  final String warningDisclaimer;

  /// 附件清單名稱
  final List<String> attachments;

  /// 發函日期
  final DateTime? sendDate;

  /// 轉為動態公文模型，相容現有 PDF 與 UI 渲染
  DynamicLegalDocument toDynamicLegalDocument() {
    final sections = <DynamicDocumentSection>[];

    // 主旨段
    sections.add(DynamicDocumentSection(
      heading: '主旨',
      body: subject,
    ));

    // 事實與理由段
    for (var i = 0; i < factsAndReasons.length; i++) {
      sections.add(DynamicDocumentSection(
        heading: '事實及理由第${_toChineseNumber(i + 1)}段',
        body: factsAndReasons[i],
      ));
    }

    return DynamicLegalDocument(
      title: '中華郵政標準存證信函',
      subtitle: subject,
      senderName: senderName,
      receiverName: receiverName,
      sections: sections,
      demands: demands,
      evidences: attachments,
      legalBasis: legalBasis,
      warningClause: warningDisclaimer,
      deadlineDays: deadlineDays,
    );
  }

  /// 轉化為正式中華郵政存證信函完整書狀格式
  String toFormalText() {
    final date = sendDate ?? DateTime.now();
    final buffer = StringBuffer();
    buffer.writeln('【郵局存證信函】');
    buffer.writeln('發函日期：中華民國 ${date.year - 1911} 年 ${date.month} 月 ${date.day} 日');
    buffer.writeln();
    buffer.writeln('寄件人：$senderName');
    buffer.writeln('地址：$senderAddress');
    if (senderPhone.isNotEmpty) buffer.writeln('電話：$senderPhone');
    buffer.writeln();
    buffer.writeln('收件人：$receiverName');
    buffer.writeln('地址：$receiverAddress');
    if (receiverPhone.isNotEmpty) buffer.writeln('電話：$receiverPhone');
    buffer.writeln();

    if (copyReceiverName.isNotEmpty) {
      buffer.writeln('副本收件人：$copyReceiverName');
      if (copyReceiverAddress.isNotEmpty) {
        buffer.writeln('副本地址：$copyReceiverAddress');
      }
      buffer.writeln();
    }

    buffer.writeln('【主旨】');
    buffer.writeln(subject);
    buffer.writeln();

    buffer.writeln('【事實及理由】');
    for (var i = 0; i < factsAndReasons.length; i++) {
      buffer.writeln('${_toChineseNumber(i + 1)}、${factsAndReasons[i]}');
    }
    buffer.writeln();

    if (demands.isNotEmpty) {
      buffer.writeln('【履行事項及期限】');
      buffer.writeln('為此，特依相關法律規定函請 台端於文到後 $deadlineDays 日內履行下列事項：');
      for (var j = 0; j < demands.length; j++) {
        buffer.writeln('  （${_toChineseNumber(j + 1)}）${demands[j]}');
      }
      buffer.writeln();
    }

    if (legalBasis.isNotEmpty) {
      buffer.writeln('【法律依據】');
      buffer.writeln(legalBasis.join('、'));
      buffer.writeln();
    }

    if (attachments.isNotEmpty) {
      buffer.writeln('【附件清單】');
      for (var k = 0; k < attachments.length; k++) {
        buffer.writeln('  附件${k + 1}：${attachments[k]}');
      }
      buffer.writeln();
    }

    buffer.writeln('【法律警告與保留】');
    buffer.writeln(warningDisclaimer);
    buffer.writeln();
    buffer.writeln('發函人（簽章）：$senderName　　　　（蓋印）');

    return buffer.toString().trim();
  }

  /// 輸出符合郵局標準 20 行 × 20 字（每頁 400 字）分頁試算版
  String toPostOfficeGridText() {
    final raw = toFormalText();
    final lines = <String>[];
    for (final rawLine in raw.split('\n')) {
      if (rawLine.isEmpty) {
        lines.add('');
        continue;
      }
      // 每 20 字換行
      var cur = rawLine;
      while (cur.length > 20) {
        lines.add(cur.substring(0, 20));
        cur = cur.substring(20);
      }
      lines.add(cur);
    }

    final buffer = StringBuffer();
    var page = 1;
    var lineInPage = 0;

    buffer.writeln('=== 中華郵政存證信函 第 $page 頁（每頁 20 行，每行 20 字）===');
    for (final l in lines) {
      buffer.writeln('[第${(lineInPage + 1).toString().padLeft(2, '0')}行] $l');
      lineInPage++;
      if (lineInPage >= 20) {
        page++;
        lineInPage = 0;
        buffer.writeln();
        buffer.writeln('=== 中華郵政存證信函 第 $page 頁 ===');
      }
    }
    return buffer.toString().trim();
  }

  static String _toChineseNumber(int n) {
    const table = ['一', '二', '三', '四', '五', '六', '七', '八', '九', '十'];
    if (n >= 1 && n <= 10) return table[n - 1];
    return n.toString();
  }

  Map<String, dynamic> toJson() => {
        'senderName': senderName,
        'senderAddress': senderAddress,
        'senderPhone': senderPhone,
        'receiverName': receiverName,
        'receiverAddress': receiverAddress,
        'receiverPhone': receiverPhone,
        'copyReceiverName': copyReceiverName,
        'copyReceiverAddress': copyReceiverAddress,
        'subject': subject,
        'factsAndReasons': factsAndReasons,
        'demands': demands,
        'legalBasis': legalBasis,
        'deadlineDays': deadlineDays,
        'warningDisclaimer': warningDisclaimer,
        'attachments': attachments,
        if (sendDate != null) 'sendDate': sendDate!.toIso8601String(),
      };

  factory AttestedDemandLetter.fromJson(Map<String, dynamic> json) =>
      AttestedDemandLetter(
        senderName: json['senderName'] as String? ?? '',
        senderAddress: json['senderAddress'] as String? ?? '',
        senderPhone: json['senderPhone'] as String? ?? '',
        receiverName: json['receiverName'] as String? ?? '',
        receiverAddress: json['receiverAddress'] as String? ?? '',
        receiverPhone: json['receiverPhone'] as String? ?? '',
        copyReceiverName: json['copyReceiverName'] as String? ?? '',
        copyReceiverAddress: json['copyReceiverAddress'] as String? ?? '',
        subject: json['subject'] as String? ?? '',
        factsAndReasons: (json['factsAndReasons'] as List<dynamic>?)
                ?.map((e) => e.toString())
                .toList() ??
            const [],
        demands: (json['demands'] as List<dynamic>?)
                ?.map((e) => e.toString())
                .toList() ??
            const [],
        legalBasis: (json['legalBasis'] as List<dynamic>?)
                ?.map((e) => e.toString())
                .toList() ??
            const [],
        deadlineDays: json['deadlineDays'] as int? ?? 7,
        warningDisclaimer: json['warningDisclaimer'] as String? ?? '',
        attachments: (json['attachments'] as List<dynamic>?)
                ?.map((e) => e.toString())
                .toList() ??
            const [],
        sendDate: json['sendDate'] != null
            ? DateTime.tryParse(json['sendDate'].toString())
            : null,
      );
}

/// 民事和解協議書結構（適用於車禍、損害賠償、租賃退租）
class SettlementAgreement {
  const SettlementAgreement({
    required this.title,
    required this.partyA, // 甲方（身分證字號、地址、電話）
    required this.partyB, // 乙方（身分證字號、地址、電話）
    required this.incidentBackground, // 事件經過原委
    required this.settlementAmount, // 和解總金額（新台幣元）
    required this.paymentTerms, // 給付期程與方式（一次付清或分期，銀行帳號）
    this.releaseClause =
        '除本協議書另有約定外，甲乙雙方就本件事故/爭議之其餘民事損害賠償請求權均宣告拋棄；涉及告訴乃論刑事責任者，受害人同意不再追究，並於簽署本協議書時立即具狀撤回告訴。',
    this.breachClause =
        '任一方如有違反本協議書之約定，未依限給付賠償款項者，未到期部分視同全部到期，違約之一方應另行給付他方按未付金額百分之十計算之懲罰性違約金，並賠償他方因此所支出之律師費用及訴訟規費。',
    this.confidentialityClause = '雙方承諾對本和解條件及內容嚴守保密義務，不得向任何無關之第三方透露。',
    this.agreementDate,
  });

  final String title;
  final SettlementParty partyA;
  final SettlementParty partyB;
  final String incidentBackground;
  final int settlementAmount;
  final String paymentTerms;
  final String releaseClause;
  final String breachClause;
  final String confidentialityClause;
  final DateTime? agreementDate;

  /// 轉為動態公文模型相容渲染
  DynamicLegalDocument toDynamicLegalDocument() {
    return DynamicLegalDocument(
      title: title,
      subtitle: '新台幣 $settlementAmount 元整清償協議',
      senderName: '${partyA.name}（甲方）',
      receiverName: '${partyB.name}（乙方）',
      sections: [
        DynamicDocumentSection(
          heading: '緣起及事故經過',
          body: incidentBackground,
        ),
        DynamicDocumentSection(
          heading: '和解賠償金額與給付方式',
          body: '和解總金額：新台幣 $settlementAmount 元整。\n給付條件：$paymentTerms',
        ),
        DynamicDocumentSection(
          heading: '其餘請求權拋棄與刑事撤告（斷尾條款）',
          body: releaseClause,
        ),
        DynamicDocumentSection(
          heading: '違約責任與保密約定',
          body: '$breachClause\n$confidentialityClause',
        ),
      ],
      demands: [
        '依約如期將新台幣 $settlementAmount 元整交付或匯入受款人指定帳戶。',
        '向受理偵查或訴訟之機關遞交撤回告訴狀。',
      ],
      evidences: const ['雙方身分證件影本', '車禍初判表或調解筆錄'],
      legalBasis: const ['《民法》第 736 條（和解契約之效力）', '《民法》第 737 條（創設或確認法律關係之效力）'],
      warningClause: '本協議書一式兩份，由甲乙雙方各執一份為憑，自簽署日起即生效力。',
      deadlineDays: 7,
    );
  }

  /// 完整和解契約書公文文字
  String toFormalText() {
    final d = agreementDate ?? DateTime.now();
    final buffer = StringBuffer();
    buffer.writeln('【$title】');
    buffer.writeln();
    buffer.writeln('立協議書人：');
    buffer.writeln('甲方：${partyA.name}　身分證字號：${partyA.idNumber}');
    buffer.writeln('地址：${partyA.address}　電話：${partyA.phone}');
    buffer.writeln();
    buffer.writeln('乙方：${partyB.name}　身分證字號：${partyB.idNumber}');
    buffer.writeln('地址：${partyB.address}　電話：${partyB.phone}');
    buffer.writeln();
    buffer.writeln('雙方就下列事件所生之民刑事爭議，本於互諒互讓精神，達成和解協議如下：');
    buffer.writeln();

    buffer.writeln('第一條（事件原委）：');
    buffer.writeln(incidentBackground);
    buffer.writeln();

    buffer.writeln('第二條（賠償金額及給付方式）：');
    buffer.writeln('乙方同意給付甲方和解金新台幣 $settlementAmount 元整。給付方式：$paymentTerms。');
    buffer.writeln();

    buffer.writeln('第三條（拋棄請求權與撤回告訴）：');
    buffer.writeln(releaseClause);
    buffer.writeln();

    buffer.writeln('第四條（違約責任）：');
    buffer.writeln(breachClause);
    buffer.writeln();

    buffer.writeln('第五條（保密條款）：');
    buffer.writeln(confidentialityClause);
    buffer.writeln();

    buffer.writeln('第六條（契約收執）：');
    buffer.writeln('本和解協議書一式二份，甲乙雙方各執乙份為憑，簽署後即生法律拘束力。');
    buffer.writeln();

    buffer.writeln('立書人甲方（簽名蓋章）：___________________');
    buffer.writeln('立書人乙方（簽名蓋章）：___________________');
    buffer.writeln('中　華　民　國　${d.year - 1911}　年　${d.month}　月　${d.day}　日');

    return buffer.toString().trim();
  }

  Map<String, dynamic> toJson() => {
        'title': title,
        'partyA': partyA.toJson(),
        'partyB': partyB.toJson(),
        'incidentBackground': incidentBackground,
        'settlementAmount': settlementAmount,
        'paymentTerms': paymentTerms,
        'releaseClause': releaseClause,
        'breachClause': breachClause,
        'confidentialityClause': confidentialityClause,
        if (agreementDate != null)
          'agreementDate': agreementDate!.toIso8601String(),
      };
}

class SettlementParty {
  const SettlementParty({
    required this.name,
    this.idNumber = '',
    this.address = '',
    this.phone = '',
  });

  final String name;
  final String idNumber;
  final String address;
  final String phone;

  Map<String, dynamic> toJson() => {
        'name': name,
        'idNumber': idNumber,
        'address': address,
        'phone': phone,
      };

  factory SettlementParty.fromJson(Map<String, dynamic> json) =>
      SettlementParty(
        name: json['name'] as String? ?? '',
        idNumber: json['idNumber'] as String? ?? '',
        address: json['address'] as String? ?? '',
        phone: json['phone'] as String? ?? '',
      );
}

/// 民事督促程序支付命令聲請狀（向管轄地方法院聲請）
class PaymentOrderPetition {
  const PaymentOrderPetition({
    required this.courtName, // e.g. 臺灣臺北地方法院民事庭
    required this.petitionerName, // 聲請人
    required this.petitionerId,
    required this.petitionerAddress,
    this.petitionerPhone = '',
    required this.respondentName, // 相對人（債務人）
    required this.respondentId,
    required this.respondentAddress,
    this.respondentPhone = '',
    required this.claimAmount, // 請求標的金額
    this.annualInterestRate = 5.0, // 利息週年利率 (法定 5%)
    required this.interestStartDateDescription, // 自支付命令送達翌日起
    required this.causeAndFacts, // 請求之原因事實
    required this.evidenceList, // 證物名稱
    this.petitionDate,
  });

  final String courtName;
  final String petitionerName;
  final String petitionerId;
  final String petitionerAddress;
  final String petitionerPhone;

  final String respondentName;
  final String respondentId;
  final String respondentAddress;
  final String respondentPhone;

  final int claimAmount;
  final double annualInterestRate;
  final String interestStartDateDescription;
  final String causeAndFacts;
  final List<String> evidenceList;
  final DateTime? petitionDate;

  /// 轉為動態公文模型相容渲染
  DynamicLegalDocument toDynamicLegalDocument() {
    return DynamicLegalDocument(
      title: '民事支付命令聲請狀',
      subtitle: courtName,
      senderName: '$petitionerName（聲請人）',
      receiverName: '$respondentName（相對人）',
      sections: [
        DynamicDocumentSection(
          heading: '聲請之標的及數量',
          body:
              '一、相對人應向聲請人清償新台幣 $claimAmount 元整，及自$interestStartDateDescription起至清償日止，按年息百分之 $annualInterestRate 計算之利息。\n二、督促程序聲請費用新台幣 500 元由相對人負擔。',
        ),
        DynamicDocumentSection(
          heading: '請求之原因事實',
          body: causeAndFacts,
        ),
      ],
      demands: [
        '依民事訴訟法第 508 條規定發支付命令。',
        '飭令相對人給付新台幣 $claimAmount 元整本息及程序費用。',
      ],
      evidences: evidenceList,
      legalBasis: const [
        '《民事訴訟法》第 508 條（督促程序之要件）',
        '《民事訴訟法》第 511 條（支付命令聲請狀之應記載事項）',
      ],
      warningClause: '債務人收受支付命令後，得於二十日之不變期間內提出異議；逾期未提出者，支付命令得為強制執行名義。',
      deadlineDays: 20,
    );
  }

  /// 完整法院書狀標準格式
  String toFormalText() {
    final d = petitionDate ?? DateTime.now();
    final buffer = StringBuffer();
    buffer.writeln('民事支付命令聲請狀');
    buffer.writeln('案號：　　年度　　　字第　　　　　號');
    buffer.writeln('股別：');
    buffer.writeln();
    buffer.writeln('聲請人（即債權人）：$petitionerName');
    buffer.writeln('國民身分證統一編號：$petitionerId');
    buffer.writeln('住址：$petitionerAddress');
    if (petitionerPhone.isNotEmpty) buffer.writeln('聯絡電話：$petitionerPhone');
    buffer.writeln();
    buffer.writeln('相對人（即債務人）：$respondentName');
    buffer.writeln('國民身分證統一編號：$respondentId');
    buffer.writeln('住址：$respondentAddress');
    if (respondentPhone.isNotEmpty) buffer.writeln('聯絡電話：$respondentPhone');
    buffer.writeln();

    buffer.writeln('為聲請發支付命令事：');
    buffer.writeln('【聲請之標的及數量】');
    buffer.writeln('一、相對人應向聲請人給付新台幣 $claimAmount 元整，及自$interestStartDateDescription起至清償日止，按週年利率百分之 $annualInterestRate 計算之利息。');
    buffer.writeln('二、督促程序費用由相對人負擔。');
    buffer.writeln();

    buffer.writeln('【請求之原因事實】');
    buffer.writeln(causeAndFacts);
    buffer.writeln('依民事訴訟法第 508 條規定，債權人之請求以給付金錢為標的者，得聲請法院發支付命令。為此，特狀請　貴院鑒核，准賜對相對人發給如聲請標的所載之支付命令，以維權益，實感德便。');
    buffer.writeln();

    if (evidenceList.isNotEmpty) {
      buffer.writeln('【附繳證物】');
      for (var i = 0; i < evidenceList.length; i++) {
        buffer.writeln('證物${i + 1}：${evidenceList[i]}');
      }
      buffer.writeln();
    }

    buffer.writeln('謹　狀');
    buffer.writeln('$courtName　公鑒');
    buffer.writeln();
    buffer.writeln('具狀人：$petitionerName　　　（蓋印）');
    buffer.writeln('中　華　民　國　${d.year - 1911}　年　${d.month}　月　${d.day}　日');

    return buffer.toString().trim();
  }

  Map<String, dynamic> toJson() => {
        'courtName': courtName,
        'petitionerName': petitionerName,
        'petitionerId': petitionerId,
        'petitionerAddress': petitionerAddress,
        'petitionerPhone': petitionerPhone,
        'respondentName': respondentName,
        'respondentId': respondentId,
        'respondentAddress': respondentAddress,
        'respondentPhone': respondentPhone,
        'claimAmount': claimAmount,
        'annualInterestRate': annualInterestRate,
        'interestStartDateDescription': interestStartDateDescription,
        'causeAndFacts': causeAndFacts,
        'evidenceList': evidenceList,
        if (petitionDate != null)
          'petitionDate': petitionDate!.toIso8601String(),
      };
}
