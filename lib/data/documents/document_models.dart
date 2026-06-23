enum DocumentTemplateType {
  depositDemand,
  rentalDepositNegotiation,
  carAccidentChecklist,
  consumerComplaint,
  laborDisputeMessage,
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
  });

  final String senderName;
  final String receiverName;
  final String facts;
  final String extraRequest;
  final String eventDate;
  final String eventPlace;
  final String evidence;
  final String toneLabel;

  Map<String, dynamic> toJson() => {
        'senderName': senderName,
        'receiverName': receiverName,
        'facts': facts,
        'extraRequest': extraRequest,
        'eventDate': eventDate,
        'eventPlace': eventPlace,
        'evidence': evidence,
        'toneLabel': toneLabel,
      };
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
      };
}
