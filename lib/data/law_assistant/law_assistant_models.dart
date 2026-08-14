import 'package:preamble/components/shared/mvp_state_widgets.dart';
import 'package:preamble/data/documents/document_models.dart';

class LawAssistantDefenseInsight {
  const LawAssistantDefenseInsight({
    required this.disputeCategory,
    required this.defensePoints,
    required this.keyEvidences,
    required this.suggestedTemplateType,
    required this.suggestedActionLabel,
    this.extractedFacts = '',
    this.suggestedFollowUps = const [],
  });

  final String disputeCategory;
  final List<String> defensePoints;
  final List<String> keyEvidences;
  final DocumentTemplateType suggestedTemplateType;
  final String suggestedActionLabel;
  final String extractedFacts;
  final List<String> suggestedFollowUps;

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
          '租賃契約書原件（確認押金金額與修繕特約）',
          '退租交屋當日現況照片 / 錄影存證紀錄',
          '押金轉帳明細、收據或歷次繳租證明',
          '催告返還押金之通訊軟體對話紀錄截圖',
        ],
        suggestedTemplateType: DocumentTemplateType.rentalDepositNegotiation,
        suggestedActionLabel: '一鍵轉為租屋押金協商函 (PDF/草稿)',
        suggestedFollowUps: [
          '退租交屋當日是否有拍照存證？',
          '房東主張扣抵的押金金額是多少？',
          '雙方租約是否有約定修繕責任歸屬？',
        ],
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
          '道路交通事故初步分析研判表 (初判表) 與現場圖',
          '車輛原廠估價單、受損部位彩色照片與維修發票',
          '合格公立/區域醫院診斷證明書及醫療單據收據',
          '因傷請假之薪資扣繳憑單或銀行薪轉紀錄',
        ],
        suggestedTemplateType: DocumentTemplateType.carAccidentChecklist,
        suggestedActionLabel: '生成車禍求償與和解清單 (PDF/草稿)',
        suggestedFollowUps: [
          '目前事故是否已取得警方初判表？',
          '事故當下是否有申請車輛保險理賠派員？',
          '受傷人員是否已有診斷證明書載明休養天數？',
        ],
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
          '完整出勤打卡紀錄、門禁刷卡紀錄或工時系統截圖',
          '每月薪資明細表 (Pay Slip) 與銀行薪轉帳戶存摺影本',
          '通訊軟體非上班時間交辦工作之對話截圖與電子郵件',
          '勞動契約書、工作規則公告或考核記錄文件',
        ],
        suggestedTemplateType: DocumentTemplateType.laborDisputeMessage,
        suggestedActionLabel: '一鍵轉為勞資爭議溝通函 (PDF/草稿)',
        suggestedFollowUps: [
          '是否有完整留存近半年的出勤打卡紀錄？',
          '公司是否有出具非自願離職證明書？',
          '通訊軟體交辦公務是否有保留確切時間截圖？',
        ],
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
          '網路訂單明細截圖、發票或信用卡金流刷卡簽單',
          '開箱全程未剪輯錄影檔案與瑕疵部位特寫照片',
          '與商家線上客服反映問題之完整對話時間戳記紀錄',
        ],
        suggestedTemplateType: DocumentTemplateType.consumerComplaint,
        suggestedActionLabel: '轉為消費爭議申訴函 (PDF/草稿)',
        suggestedFollowUps: [
          '收到商品後是否在 7 日猶豫期內提出退換申請？',
          '是否有開箱錄影或瑕疵特寫照片？',
          '賣家目前拒絕退換貨的具體理由為何？',
        ],
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
          '雙方往來簡訊、LINE、Email 溝通對話紀錄完整截圖',
          '匯款金流明細、契約書、收據本票或出貨簽收單據',
          '先前發出之催告紀錄、存證信函或雙掛號郵件收件回條',
        ],
        suggestedTemplateType: DocumentTemplateType.depositDemand,
        suggestedActionLabel: '一鍵轉為正式存證信函草稿 (PDF)',
        suggestedFollowUps: [
          '雙方當初是否有簽署書面契約或留存通訊紀錄？',
          '目前要求給付或履行的具體金額/標的為何？',
          '先前是否曾向對方進行過口頭或書面催告？',
        ],
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
      suggestedActionLabel: json['suggestedActionLabel'] as String? ?? '轉為存證信函',
      extractedFacts: json['extractedFacts'] as String? ?? '',
      suggestedFollowUps: (json['suggestedFollowUps'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
    );
  }
}

class LawAssistantMessage {
  const LawAssistantMessage({
    required this.id,
    required this.role,
    required this.content,
    required this.createdAt,
    this.answer,
    this.citations = const [],
    this.warningText = '',
    this.insight,
  });

  final String id;
  final LawAssistantMessageRole role;
  final String content;
  final DateTime createdAt;
  final LawAssistantAnswer? answer;
  final List<LawAssistantCitation> citations;
  final String warningText;
  final LawAssistantDefenseInsight? insight;

  factory LawAssistantMessage.fromJson(Map<String, dynamic> json) {
    final answerJson = json['answer'] ?? json['answerSections'];
    final roleText = _stringValue(json, const ['role']).toLowerCase();
    final role = LawAssistantMessageRole.values.firstWhere(
      (r) => r.name == roleText,
      orElse: () => LawAssistantMessageRole.user,
    );
    final content = _stringValue(json, const ['content', 'text', 'message']);

    LawAssistantDefenseInsight? insight;
    if (json['insight'] is Map<String, dynamic>) {
      insight = LawAssistantDefenseInsight.fromJson(
        json['insight'] as Map<String, dynamic>,
      );
    } else if (role == LawAssistantMessageRole.assistant && content.isNotEmpty) {
      insight = LawAssistantDefenseInsight.fromContext(text: content);
    }

    return LawAssistantMessage(
      id: _stringValue(json, const ['id', 'messageId', 'message_id']),
      role: role,
      content: content,
      createdAt: _dateTimeValue(json, const ['createdAt', 'created_at']),
      answer: answerJson is Map<String, dynamic>
          ? LawAssistantAnswer.fromJson(answerJson)
          : null,
      citations: _citations(json['citations']),
      warningText: _stringValue(json, const ['warningText', 'warning_text']),
      insight: insight,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'role': role.name,
      'content': content,
      'createdAt': createdAt.toIso8601String(),
      if (answer != null) 'answer': answer!.toJson(),
      if (citations.isNotEmpty)
        'citations': citations.map((citation) => citation.toJson()).toList(),
      if (warningText.isNotEmpty) 'warningText': warningText,
      if (insight != null) 'insight': insight!.toJson(),
    };
  }
}

enum LawAssistantMessageRole {
  user,
  assistant,
  system,
}

enum LawAssistantCitationSourceType {
  statute,
  judgment,
  official,
  news,
  other,
}

/// AI 回答的引用來源。
///
/// 引用來源要和回答一起被保存，避免 UI 只顯示 AI 文字卻看不到法規、判決或官方資料來源。
class LawAssistantCitation {
  const LawAssistantCitation({
    required this.title,
    required this.sourceType,
    this.url = '',
    this.publishedAt,
    this.updatedAt,
    this.lawName = '',
    this.articleNumber = '',
  });

  final String title;
  final LawAssistantCitationSourceType sourceType;
  final String url;
  final DateTime? publishedAt;
  final DateTime? updatedAt;
  final String lawName;
  final String articleNumber;

  factory LawAssistantCitation.fromJson(Map<String, dynamic> json) {
    return LawAssistantCitation(
      title: _stringValue(json, const ['title', 'name']),
      sourceType: _citationType(
        _stringValue(json, const ['sourceType', 'source_type']),
      ),
      url: _stringValue(json, const ['url', 'sourceUrl', 'source_url']),
      publishedAt: _nullableDateTime(json, const ['publishedAt']),
      updatedAt: _nullableDateTime(json, const ['updatedAt', 'updated_at']),
      lawName: _stringValue(json, const ['lawName', 'law_name']),
      articleNumber: _stringValue(
        json,
        const ['articleNumber', 'article_number'],
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'sourceType': sourceType.name,
      if (url.isNotEmpty) 'url': url,
      if (publishedAt != null) 'publishedAt': publishedAt!.toIso8601String(),
      if (updatedAt != null) 'updatedAt': updatedAt!.toIso8601String(),
      if (lawName.isNotEmpty) 'lawName': lawName,
      if (articleNumber.isNotEmpty) 'articleNumber': articleNumber,
    };
  }

  SourceCitationViewData toViewData() {
    return SourceCitationViewData(
      title: title,
      sourceType: sourceType.name,
      url: url,
      updatedAt: updatedAt,
      lawName: lawName,
      articleNumber: articleNumber,
    );
  }
}

/// 小法助回覆的分段資料。
class LawAssistantAnswer {
  const LawAssistantAnswer({
    required this.problemDirection,
    required this.relatedContent,
    required this.nextStep,
    this.evidenceNeeded = '',
    this.possibleLegalIssues = '',
    this.recommendedActions = '',
    this.disclaimer = lawAppLegalDisclaimer,
  });

  final String problemDirection;
  final String relatedContent;
  final String nextStep;
  final String evidenceNeeded;
  final String possibleLegalIssues;
  final String recommendedActions;
  final String disclaimer;

  factory LawAssistantAnswer.fromJson(Map<String, dynamic> json) {
    return LawAssistantAnswer(
      problemDirection: _stringValue(
        json,
        const ['problemDirection', 'problem_direction', 'direction'],
      ),
      relatedContent: _stringValue(
        json,
        const ['relatedContent', 'related_content', 'related'],
      ),
      nextStep: _stringValue(json, const ['nextStep', 'next_step', 'next']),
      evidenceNeeded: _stringValue(
        json,
        const ['evidenceNeeded', 'evidence_needed'],
      ),
      possibleLegalIssues: _stringValue(
        json,
        const ['possibleLegalIssues', 'possible_legal_issues'],
      ),
      recommendedActions: _stringValue(
        json,
        const ['recommendedActions', 'recommended_actions'],
      ),
      disclaimer: _stringValue(json, const ['disclaimer']).isEmpty
          ? lawAppLegalDisclaimer
          : _stringValue(json, const ['disclaimer']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'problemDirection': problemDirection,
      'relatedContent': relatedContent,
      'nextStep': nextStep,
      if (evidenceNeeded.isNotEmpty) 'evidenceNeeded': evidenceNeeded,
      if (possibleLegalIssues.isNotEmpty)
        'possibleLegalIssues': possibleLegalIssues,
      if (recommendedActions.isNotEmpty)
        'recommendedActions': recommendedActions,
      'disclaimer': disclaimer,
    };
  }

  bool get isEmpty =>
      problemDirection.isEmpty &&
      relatedContent.isEmpty &&
      nextStep.isEmpty &&
      evidenceNeeded.isEmpty &&
      possibleLegalIssues.isEmpty &&
      recommendedActions.isEmpty;
}

class LawAssistantConversation {
  const LawAssistantConversation({
    required this.id,
    required this.title,
    required this.preview,
    required this.updatedAt,
    required this.categoryLabel,
    this.messages = const [],
    this.sourceCitations = const [],
    this.disclaimer = lawAppLegalDisclaimer,
    this.isGuest = false,
    this.isMock = false,
  });

  final String id;
  final String title;
  final String preview;
  final DateTime updatedAt;
  final String categoryLabel;
  final List<LawAssistantMessage> messages;
  final List<LawAssistantCitation> sourceCitations;
  final String disclaimer;
  final bool isGuest;
  final bool isMock;

  factory LawAssistantConversation.fromJson(Map<String, dynamic> json) {
    final messagesJson = json['messages'];

    return LawAssistantConversation(
      id: _stringValue(json, const ['id', 'conversationId', 'conversation_id']),
      title: _stringValue(json, const ['title']),
      preview: _stringValue(json, const ['preview', 'summary']),
      updatedAt: _dateTimeValue(json, const ['updatedAt', 'updated_at']),
      categoryLabel: _stringValue(
        json,
        const ['categoryLabel', 'category_label', 'category'],
      ),
      messages: messagesJson is List
          ? messagesJson
              .whereType<Map<String, dynamic>>()
              .map(LawAssistantMessage.fromJson)
              .toList(growable: false)
          : const [],
      sourceCitations: _citations(
        json['sourceCitations'] ?? json['source_citations'],
      ),
      disclaimer: _stringValue(json, const ['disclaimer']).isEmpty
          ? lawAppLegalDisclaimer
          : _stringValue(json, const ['disclaimer']),
      isGuest: json['isGuest'] == true,
      isMock: json['isMock'] == true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'preview': preview,
      'updatedAt': updatedAt.toIso8601String(),
      'categoryLabel': categoryLabel,
      'messages': messages.map((message) => message.toJson()).toList(),
      if (sourceCitations.isNotEmpty)
        'sourceCitations': sourceCitations
            .map((citation) => citation.toJson())
            .toList(growable: false),
      'disclaimer': disclaimer,
      'isGuest': isGuest,
      'isMock': isMock,
    };
  }

  LawAssistantConversation copyWith({
    String? id,
    String? title,
    String? preview,
    DateTime? updatedAt,
    String? categoryLabel,
    List<LawAssistantMessage>? messages,
    List<LawAssistantCitation>? sourceCitations,
    String? disclaimer,
    bool? isGuest,
    bool? isMock,
  }) {
    return LawAssistantConversation(
      id: id ?? this.id,
      title: title ?? this.title,
      preview: preview ?? this.preview,
      updatedAt: updatedAt ?? this.updatedAt,
      categoryLabel: categoryLabel ?? this.categoryLabel,
      messages: messages ?? this.messages,
      sourceCitations: sourceCitations ?? this.sourceCitations,
      disclaimer: disclaimer ?? this.disclaimer,
      isGuest: isGuest ?? this.isGuest,
      isMock: isMock ?? this.isMock,
    );
  }
}

/// 小法助 AI 流式打字機傳輸片段。
class LawAssistantStreamChunk {
  const LawAssistantStreamChunk({
    required this.textChunk,
    this.isFinished = false,
    this.citations = const [],
    this.error,
    this.fullAnswer,
  });

  final String textChunk;
  final bool isFinished;
  final List<LawAssistantCitation> citations;
  final String? error;
  final LawAssistantAnswer? fullAnswer;

  factory LawAssistantStreamChunk.fromJson(Map<String, dynamic> json) {
    final answerJson = json['answer'] ?? json['answerSections'];
    return LawAssistantStreamChunk(
      textChunk: _stringValue(json, const ['textChunk', 'chunk', 'text', 'delta']),
      isFinished: json['isFinished'] == true || json['done'] == true,
      citations: _citations(json['citations']),
      error: json['error']?.toString(),
      fullAnswer: answerJson is Map<String, dynamic>
          ? LawAssistantAnswer.fromJson(answerJson)
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'textChunk': textChunk,
        'isFinished': isFinished,
        if (citations.isNotEmpty)
          'citations': citations.map((c) => c.toJson()).toList(),
        if (error != null) 'error': error,
        if (fullAnswer != null) 'answer': fullAnswer!.toJson(),
      };
}

List<LawAssistantCitation> _citations(Object? value) {
  if (value is! List) return const [];
  return value
      .whereType<Map<String, dynamic>>()
      .map(LawAssistantCitation.fromJson)
      .toList(growable: false);
}

LawAssistantCitationSourceType _citationType(String value) {
  return LawAssistantCitationSourceType.values.firstWhere(
    (type) => type.name == value,
    orElse: () => LawAssistantCitationSourceType.other,
  );
}

String _stringValue(Map<String, dynamic> json, List<String> keys) {
  for (final key in keys) {
    final value = json[key];
    if (value == null) continue;
    final text = value.toString().trim();
    if (text.isNotEmpty) return text;
  }
  return '';
}

DateTime _dateTimeValue(Map<String, dynamic> json, List<String> keys) {
  for (final key in keys) {
    final value = json[key];
    if (value == null) continue;
    final parsed = DateTime.tryParse(value.toString());
    if (parsed != null) return parsed;
  }
  return DateTime.now();
}

DateTime? _nullableDateTime(Map<String, dynamic> json, List<String> keys) {
  for (final key in keys) {
    final value = json[key];
    if (value == null) continue;
    final parsed = DateTime.tryParse(value.toString());
    if (parsed != null) return parsed;
  }
  return null;
}
