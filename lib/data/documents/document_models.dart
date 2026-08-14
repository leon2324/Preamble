import 'dart:convert';
import 'dart:typed_data';

enum DocumentTemplateType {
  depositDemand,
  rentalDepositNegotiation,
  carAccidentChecklist,
  consumerComplaint,
  laborDisputeMessage,
  dynamicCustom, // 100% 動態 AI 自主生成書狀
}

/// 動態章節條款模型
class DynamicDocumentSection {
  const DynamicDocumentSection({
    required this.heading,
    required this.body,
    this.subPoints = const [],
  });

  final String heading;
  final String body;
  final List<String> subPoints;

  Map<String, dynamic> toJson() => {
        'heading': heading,
        'body': body,
        if (subPoints.isNotEmpty) 'subPoints': subPoints,
      };

  factory DynamicDocumentSection.fromJson(Map<String, dynamic> json) =>
      DynamicDocumentSection(
        heading: json['heading'] as String? ?? '',
        body: json['body'] as String? ?? '',
        subPoints: (json['subPoints'] as List<dynamic>?)
                ?.map((e) => e.toString())
                .toList() ??
            const [],
      );
}

/// 100% AI 動態法律書狀結構模型（完全擺脫制式模板束縛）
class DynamicLegalDocument {
  const DynamicLegalDocument({
    required this.title,
    required this.subtitle,
    required this.senderName,
    required this.receiverName,
    required this.sections,
    required this.demands,
    required this.evidences,
    required this.legalBasis,
    required this.warningClause,
    this.deadlineDays = 7,
  });

  final String title;
  final String subtitle;
  final String senderName;
  final String receiverName;
  final List<DynamicDocumentSection> sections;
  final List<String> demands;
  final List<String> evidences;
  final List<String> legalBasis;
  final String warningClause;
  final int deadlineDays;

  /// 將動態結構編排為完整的繁體中文法律公文字串
  String toFormalDocumentText() {
    final buffer = StringBuffer();
    buffer.writeln('【$title】');
    if (subtitle.isNotEmpty) {
      buffer.writeln('—— $subtitle');
    }
    buffer.writeln();
    buffer.writeln('發函人（立書人）：$senderName');
    buffer.writeln('相對人（收件人）：$receiverName');
    buffer.writeln();

    for (var i = 0; i < sections.length; i++) {
      final s = sections[i];
      buffer.writeln('${_numberToChinese(i + 1)}、${s.heading}');
      if (s.body.isNotEmpty) {
        buffer.writeln(s.body);
      }
      for (final pt in s.subPoints) {
        buffer.writeln('  （一）$pt');
      }
      buffer.writeln();
    }

    if (demands.isNotEmpty) {
      buffer.writeln('${_numberToChinese(sections.length + 1)}、請求及履行事項');
      for (var j = 0; j < demands.length; j++) {
        buffer.writeln('  ${j + 1}. ${demands[j]}');
      }
      buffer.writeln('  ※ 履行期限：請於文到後 $deadlineDays 日內完成上述事項。');
      buffer.writeln();
    }

    if (evidences.isNotEmpty) {
      buffer.writeln('${_numberToChinese(sections.length + 2)}、附件與佐證清冊');
      for (var k = 0; k < evidences.length; k++) {
        buffer.writeln('  附件${k + 1}：${evidences[k]}');
      }
      buffer.writeln();
    }

    if (warningClause.isNotEmpty) {
      buffer.writeln('【法律聲明與權益保留】');
      buffer.writeln(warningClause);
      buffer.writeln();
    }

    return buffer.toString().trim();
  }

  static String _numberToChinese(int num) {
    const list = ['一', '二', '三', '四', '五', '六', '七', '八', '九', '十'];
    if (num >= 1 && num <= 10) return list[num - 1];
    return num.toString();
  }

  Map<String, dynamic> toJson() => {
        'title': title,
        'subtitle': subtitle,
        'senderName': senderName,
        'receiverName': receiverName,
        'sections': sections.map((s) => s.toJson()).toList(),
        'demands': demands,
        'evidences': evidences,
        'legalBasis': legalBasis,
        'warningClause': warningClause,
        'deadlineDays': deadlineDays,
      };

  factory DynamicLegalDocument.fromJson(Map<String, dynamic> json) =>
      DynamicLegalDocument(
        title: json['title'] as String? ?? '法律函件',
        subtitle: json['subtitle'] as String? ?? '',
        senderName: json['senderName'] as String? ?? '本人',
        receiverName: json['receiverName'] as String? ?? '相對人',
        sections: (json['sections'] as List<dynamic>?)
                ?.map((e) =>
                    DynamicDocumentSection.fromJson(e as Map<String, dynamic>))
                .toList() ??
            const [],
        demands: (json['demands'] as List<dynamic>?)
                ?.map((e) => e.toString())
                .toList() ??
            const [],
        evidences: (json['evidences'] as List<dynamic>?)
                ?.map((e) => e.toString())
                .toList() ??
            const [],
        legalBasis: (json['legalBasis'] as List<dynamic>?)
                ?.map((e) => e.toString())
                .toList() ??
            const [],
        warningClause: json['warningClause'] as String? ?? '',
        deadlineDays: json['deadlineDays'] as int? ?? 7,
      );
}

class DocumentTemplateInput {
  const DocumentTemplateInput({
    required this.senderName,
    required this.receiverName,
    required this.facts,
    this.extraRequest = '',
    this.eventDate = '',
    this.eventPlace = '',
    this.evidence = '',
    this.toneLabel = '',
    this.dynamicDocument,
  });

  final String senderName;
  final String receiverName;
  final String facts;
  final String extraRequest;
  final String eventDate;
  final String eventPlace;
  final String evidence;
  final String toneLabel;
  final DynamicLegalDocument? dynamicDocument;

  Map<String, dynamic> toJson() => {
        'senderName': senderName,
        'receiverName': receiverName,
        'facts': facts,
        'extraRequest': extraRequest,
        'eventDate': eventDate,
        'eventPlace': eventPlace,
        'evidence': evidence,
        'toneLabel': toneLabel,
        if (dynamicDocument != null) 'dynamicDocument': dynamicDocument!.toJson(),
      };
}

class DocumentVersion {
  const DocumentVersion({
    required this.content,
    required this.savedAt,
  });

  final String content;
  final DateTime savedAt;

  Map<String, dynamic> toJson() => {
        'content': content,
        'savedAt': savedAt.toIso8601String(),
      };

  factory DocumentVersion.fromJson(Map<String, dynamic> json) => DocumentVersion(
        content: json['content'] as String,
        savedAt: DateTime.parse(json['savedAt'] as String),
      );
}

class DocumentDraft {
  const DocumentDraft({
    required this.id,
    required this.title,
    required this.content,
    required this.templateType,
    required this.createdAt,
    required this.isMock,
    required this.disclaimer,
    this.isSyncedToBackend = false,
    this.sourceLabel = '本機暫存',
    this.versions = const [],
    this.signatureBytes,
    this.dynamicDocument,
  });

  final String id;
  final String title;
  final String content;
  final DocumentTemplateType templateType;
  final DateTime createdAt;
  final bool isMock;
  final String disclaimer;
  final bool isSyncedToBackend;
  final String sourceLabel;
  final List<DocumentVersion> versions;
  final Uint8List? signatureBytes;
  final DynamicLegalDocument? dynamicDocument;

  factory DocumentDraft.fromJson(Map<String, dynamic> json) {
    return DocumentDraft(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      content: json['content']?.toString() ?? '',
      templateType: DocumentTemplateType.values.firstWhere(
        (type) =>
            type.name ==
            (json['templateType'] ?? json['template_type'])?.toString(),
        orElse: () => DocumentTemplateType.depositDemand,
      ),
      createdAt: DateTime.tryParse(
            (json['createdAt'] ?? json['created_at'])?.toString() ?? '',
          ) ??
          DateTime.now(),
      isMock: json['isMock'] == true || json['is_mock'] == true,
      disclaimer: json['disclaimer']?.toString() ?? '',
      isSyncedToBackend:
          json['isSyncedToBackend'] == true || json['is_synced'] == true,
      sourceLabel: json['sourceLabel']?.toString() ??
          json['source_label']?.toString() ??
          '後端同步',
      versions: (json['versions'] as List<dynamic>?)
              ?.map((e) => DocumentVersion.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      signatureBytes: json['signatureBytes'] != null
          ? base64Decode(json['signatureBytes'] as String)
          : null,
      dynamicDocument: json['dynamicDocument'] is Map<String, dynamic>
          ? DynamicLegalDocument.fromJson(
              json['dynamicDocument'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'content': content,
        'templateType': templateType.name,
        'createdAt': createdAt.toIso8601String(),
        'isMock': isMock,
        'disclaimer': disclaimer,
        'isSyncedToBackend': isSyncedToBackend,
        'sourceLabel': sourceLabel,
        'versions': versions.map((e) => e.toJson()).toList(),
        if (signatureBytes != null)
          'signatureBytes': base64Encode(signatureBytes!),
        if (dynamicDocument != null)
          'dynamicDocument': dynamicDocument!.toJson(),
      };
}
