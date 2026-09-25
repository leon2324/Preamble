import 'package:preamble/data/legal_brain/taiwan_statute_canon.dart';

/// 使用者案件記事之進行狀態
enum CaseJournalStatus {
  active, // 進行中 / 交涉中
  formalDemand, // 已寄發存證信函 / 催告中
  mediation, // 調解程序中
  litigation, // 訴訟 / 強制執行中
  settled, // 和解圓滿解決
}

extension CaseJournalStatusExt on CaseJournalStatus {
  String get label => switch (this) {
        CaseJournalStatus.active => '交涉自保中',
        CaseJournalStatus.formalDemand => '已發函催告',
        CaseJournalStatus.mediation => '調解程序中',
        CaseJournalStatus.litigation => '訴訟/執行中',
        CaseJournalStatus.settled => '已圓滿結案',
      };
}

/// 案件交涉日誌項目
class CaseJournalLogEntry {
  const CaseJournalLogEntry({
    required this.id,
    required this.timestamp,
    required this.title,
    required this.note,
    this.tag = '通話/對話',
  });

  final String id;
  final DateTime timestamp;
  final String title;
  final String note;
  final String tag;

  Map<String, dynamic> toJson() => {
        'id': id,
        'timestamp': timestamp.toIso8601String(),
        'title': title,
        'note': note,
        'tag': tag,
      };

  factory CaseJournalLogEntry.fromJson(Map<String, dynamic> json) =>
      CaseJournalLogEntry(
        id: json['id'] as String? ?? '',
        timestamp: json['timestamp'] != null
            ? DateTime.tryParse(json['timestamp'].toString()) ?? DateTime.now()
            : DateTime.now(),
        title: json['title'] as String? ?? '交涉記錄',
        note: json['note'] as String? ?? '',
        tag: json['tag'] as String? ?? '記錄',
      );
}

/// 案件佐證證據檢核項目
class CaseJournalEvidenceItem {
  const CaseJournalEvidenceItem({
    required this.title,
    this.isCollected = false,
    this.note = '',
  });

  final String title;
  final bool isCollected;
  final String note;

  CaseJournalEvidenceItem copyWith({
    String? title,
    bool? isCollected,
    String? note,
  }) {
    return CaseJournalEvidenceItem(
      title: title ?? this.title,
      isCollected: isCollected ?? this.isCollected,
      note: note ?? this.note,
    );
  }

  Map<String, dynamic> toJson() => {
        'title': title,
        'isCollected': isCollected,
        'note': note,
      };

  factory CaseJournalEvidenceItem.fromJson(Map<String, dynamic> json) =>
      CaseJournalEvidenceItem(
        title: json['title'] as String? ?? '',
        isCollected: json['isCollected'] as bool? ?? false,
        note: json['note'] as String? ?? '',
      );
}

/// 使用者個人自救案件記事模型
class UserCaseJournalEntry {
  const UserCaseJournalEntry({
    required this.id,
    required this.title,
    required this.domain,
    required this.counterparty,
    required this.disputedAmount,
    required this.status,
    required this.statuteDeadlineTitle,
    required this.statuteDeadlineBasis,
    required this.statuteDeadlineDays,
    required this.startDate,
    required this.tacticalGoldenPhrase,
    required this.evidences,
    required this.logs,
    this.initialFacts = '',
  });

  final String id;
  final String title;
  final TaiwanDisputeDomain domain;
  final String counterparty;
  final String disputedAmount;
  final CaseJournalStatus status;
  final String statuteDeadlineTitle;
  final String statuteDeadlineBasis;
  final int statuteDeadlineDays;
  final DateTime startDate;
  final String tacticalGoldenPhrase;
  final List<CaseJournalEvidenceItem> evidences;
  final List<CaseJournalLogEntry> logs;
  final String initialFacts;

  /// 計算距離法定時效剩餘天數
  int get remainingDays {
    final deadlineDate = startDate.add(Duration(days: statuteDeadlineDays));
    final diff = deadlineDate.difference(DateTime.now()).inDays;
    return diff > 0 ? diff : 0;
  }

  /// 證據準備完成率 (0.0 ~ 1.0)
  double get evidenceProgress {
    if (evidences.isEmpty) return 1.0;
    final collected = evidences.where((e) => e.isCollected).length;
    return collected / evidences.length;
  }

  UserCaseJournalEntry copyWith({
    String? id,
    String? title,
    TaiwanDisputeDomain? domain,
    String? counterparty,
    String? disputedAmount,
    CaseJournalStatus? status,
    String? statuteDeadlineTitle,
    String? statuteDeadlineBasis,
    int? statuteDeadlineDays,
    DateTime? startDate,
    String? tacticalGoldenPhrase,
    List<CaseJournalEvidenceItem>? evidences,
    List<CaseJournalLogEntry>? logs,
    String? initialFacts,
  }) {
    return UserCaseJournalEntry(
      id: id ?? this.id,
      title: title ?? this.title,
      domain: domain ?? this.domain,
      counterparty: counterparty ?? this.counterparty,
      disputedAmount: disputedAmount ?? this.disputedAmount,
      status: status ?? this.status,
      statuteDeadlineTitle: statuteDeadlineTitle ?? this.statuteDeadlineTitle,
      statuteDeadlineBasis: statuteDeadlineBasis ?? this.statuteDeadlineBasis,
      statuteDeadlineDays: statuteDeadlineDays ?? this.statuteDeadlineDays,
      startDate: startDate ?? this.startDate,
      tacticalGoldenPhrase: tacticalGoldenPhrase ?? this.tacticalGoldenPhrase,
      evidences: evidences ?? this.evidences,
      logs: logs ?? this.logs,
      initialFacts: initialFacts ?? this.initialFacts,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'domain': domain.name,
        'counterparty': counterparty,
        'disputedAmount': disputedAmount,
        'status': status.name,
        'statuteDeadlineTitle': statuteDeadlineTitle,
        'statuteDeadlineBasis': statuteDeadlineBasis,
        'statuteDeadlineDays': statuteDeadlineDays,
        'startDate': startDate.toIso8601String(),
        'tacticalGoldenPhrase': tacticalGoldenPhrase,
        'evidences': evidences.map((e) => e.toJson()).toList(),
        'logs': logs.map((l) => l.toJson()).toList(),
        'initialFacts': initialFacts,
      };

  factory UserCaseJournalEntry.fromJson(Map<String, dynamic> json) {
    return UserCaseJournalEntry(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '個人案件記事',
      domain: TaiwanDisputeDomain.values.firstWhere(
        (d) => d.name == json['domain'],
        orElse: () => TaiwanDisputeDomain.rentalAndHousing,
      ),
      counterparty: json['counterparty'] as String? ?? '相對人',
      disputedAmount: json['disputedAmount'] as String? ?? '',
      status: CaseJournalStatus.values.firstWhere(
        (s) => s.name == json['status'],
        orElse: () => CaseJournalStatus.active,
      ),
      statuteDeadlineTitle:
          json['statuteDeadlineTitle'] as String? ?? '法定救濟時效',
      statuteDeadlineBasis: json['statuteDeadlineBasis'] as String? ?? '民法相關規定',
      statuteDeadlineDays: json['statuteDeadlineDays'] as int? ?? 180,
      startDate: json['startDate'] != null
          ? DateTime.tryParse(json['startDate'].toString()) ?? DateTime.now()
          : DateTime.now(),
      tacticalGoldenPhrase: json['tacticalGoldenPhrase'] as String? ?? '',
      evidences: (json['evidences'] as List<dynamic>?)
              ?.map((e) =>
                  CaseJournalEvidenceItem.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      logs: (json['logs'] as List<dynamic>?)
              ?.map(
                  (l) => CaseJournalLogEntry.fromJson(l as Map<String, dynamic>))
              .toList() ??
          const [],
      initialFacts: json['initialFacts'] as String? ?? '',
    );
  }
}
