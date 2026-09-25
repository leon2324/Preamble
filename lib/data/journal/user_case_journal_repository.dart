import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:preamble/data/journal/user_case_journal_models.dart';
import 'package:preamble/data/law_assistant/law_assistant_models.dart';
import 'package:preamble/data/legal_brain/taiwan_statute_canon.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// 使用者個人自救案件記事數據倉庫 (User Case Journal Repository)
class UserCaseJournalRepository extends ChangeNotifier {
  UserCaseJournalRepository({SharedPreferences? prefs}) : _prefs = prefs {
    _loadFromDisk();
  }

  static const String _storageKey = 'preamble_user_case_journal_entries_v1';
  SharedPreferences? _prefs;
  final List<UserCaseJournalEntry> _entries = [];

  List<UserCaseJournalEntry> get entries => List.unmodifiable(_entries);

  bool get isEmpty => _entries.isEmpty;

  Future<void> _loadFromDisk() async {
    try {
      _prefs ??= await SharedPreferences.getInstance();
      final raw = _prefs?.getString(_storageKey);
      if (raw != null && raw.isNotEmpty) {
        final decoded = jsonDecode(raw);
        if (decoded is List) {
          _entries.clear();
          for (final item in decoded) {
            if (item is Map<String, dynamic>) {
              _entries.add(UserCaseJournalEntry.fromJson(item));
            }
          }
          notifyListeners();
          return;
        }
      }
    } catch (_) {
      // Fallback
    }

    // 若本地尚無記錄，提供一筆標準範例案（租賃押金爭議），展示完整自救追蹤能力
    if (_entries.isEmpty) {
      _entries.add(_createSeedEntry());
      notifyListeners();
    }
  }

  Future<void> _saveToDisk() async {
    try {
      _prefs ??= await SharedPreferences.getInstance();
      final encoded = jsonEncode(_entries.map((e) => e.toJson()).toList());
      await _prefs?.setString(_storageKey, encoded);
    } catch (_) {}
    notifyListeners();
  }

  /// 新增一筆自救案件
  Future<void> addEntry(UserCaseJournalEntry entry) async {
    _entries.insert(0, entry);
    await _saveToDisk();
  }

  /// 更新現有案件
  Future<void> updateEntry(UserCaseJournalEntry entry) async {
    final idx = _entries.indexWhere((e) => e.id == entry.id);
    if (idx != -1) {
      _entries[idx] = entry;
      await _saveToDisk();
    }
  }

  /// 刪除案件
  Future<void> deleteEntry(String id) async {
    _entries.removeWhere((e) => e.id == id);
    await _saveToDisk();
  }

  /// 切換證據準備勾選狀態
  Future<void> toggleEvidence(String entryId, int evidenceIndex) async {
    final idx = _entries.indexWhere((e) => e.id == entryId);
    if (idx != -1) {
      final entry = _entries[idx];
      if (evidenceIndex >= 0 && evidenceIndex < entry.evidences.length) {
        final item = entry.evidences[evidenceIndex];
        final updatedList = [...entry.evidences];
        updatedList[evidenceIndex] =
            item.copyWith(isCollected: !item.isCollected);
        _entries[idx] = entry.copyWith(evidences: updatedList);
        await _saveToDisk();
      }
    }
  }

  /// 為案件新增一則交涉日誌
  Future<void> addLog(String entryId, CaseJournalLogEntry log) async {
    final idx = _entries.indexWhere((e) => e.id == entryId);
    if (idx != -1) {
      final entry = _entries[idx];
      final updatedLogs = [log, ...entry.logs];
      _entries[idx] = entry.copyWith(logs: updatedLogs);
      await _saveToDisk();
    }
  }

  /// 從小法助問診結果直接生成自救案件記事
  static UserCaseJournalEntry fromAssistantInsight({
    required LawAssistantDefenseInsight insight,
    required String rawFacts,
  }) {
    final domain = TaiwanStatuteCanon.detectDisputeDomain(rawFacts);
    final deadlineDays = insight.statuteDeadline?.durationDays ?? 180;

    return UserCaseJournalEntry(
      id: 'case-${DateTime.now().microsecondsSinceEpoch}',
      title: insight.disputeCategory,
      domain: domain,
      counterparty: insight.detectedCounterparty.isNotEmpty
          ? insight.detectedCounterparty
          : '相對人',
      disputedAmount: insight.detectedAmount.isNotEmpty
          ? insight.detectedAmount
          : '全數爭議款項',
      status: CaseJournalStatus.active,
      statuteDeadlineTitle: insight.statuteDeadline?.title ?? '法定救濟時效',
      statuteDeadlineBasis:
          insight.statuteDeadline?.legalBasis ?? '民法相關規定',
      statuteDeadlineDays: deadlineDays,
      startDate: DateTime.now(),
      tacticalGoldenPhrase: insight.tacticalGoldenPhrase,
      initialFacts: rawFacts,
      evidences: insight.keyEvidences.map((e) {
        return CaseJournalEvidenceItem(title: e, isCollected: false);
      }).toList(),
      logs: [
        CaseJournalLogEntry(
          id: 'log-init',
          timestamp: DateTime.now(),
          title: '小法助 AI 完成法律診斷',
          note:
              '已完成全方位法學三段論推導，鎖定時效依據與談判金句。建議先整理證據並於期限內行使權利。',
          tag: 'AI 診斷',
        ),
      ],
    );
  }

  static UserCaseJournalEntry _createSeedEntry() {
    return UserCaseJournalEntry(
      id: 'seed-case-rental-01',
      title: '租賃住宅退租押金返還請求案',
      domain: TaiwanDisputeDomain.rentalAndHousing,
      counterparty: '房東',
      disputedAmount: '32,000元',
      status: CaseJournalStatus.active,
      statuteDeadlineTitle: '租賃物返還損害賠償時效 (6個月)',
      statuteDeadlineBasis: '民法第456條及租賃住宅市場發展條例第34條',
      statuteDeadlineDays: 180,
      startDate: DateTime.now().subtract(const Duration(days: 38)),
      tacticalGoldenPhrase:
          '「房東您好，依租賃專法第34條，房屋自然折舊老化依法由出租人負擔。交還房屋時除無爭議水電費外，請於點交後返還新台幣 32,000元；若有修繕扣款主張，請出具正式廠商發票明細供核對，謝謝。」',
      initialFacts: '租約到期退租交屋，房東稱牆壁有擦痕及自然泛黃要扣全部押金 32,000 元。',
      evidences: const [
        CaseJournalEvidenceItem(
          title: '原證一：租賃契約書原本（確認押金特約）',
          isCollected: true,
          note: '已掃描紙本合約備存',
        ),
        CaseJournalEvidenceItem(
          title: '原證二：退租交屋當日現場全景錄影與拍照',
          isCollected: true,
          note: '手機內有點交照片42張含時間戳記',
        ),
        CaseJournalEvidenceItem(
          title: '原證三：押金匯款水單與水電費結清單據',
          isCollected: true,
          note: '網銀匯款水單已匯出 PDF',
        ),
        CaseJournalEvidenceItem(
          title: '原證四：向房東催告返還押金之 LINE 完整對話截圖',
          isCollected: false,
          note: '尚待補全完整對話時間軸',
        ),
      ],
      logs: [
        CaseJournalLogEntry(
          id: 'log-01',
          timestamp: DateTime.now().subtract(const Duration(days: 38)),
          title: '退租點交現場紀錄',
          note: '交還房屋鑰匙，房東口頭表示牆面油漆需扣押金，雙方無共識未簽切結。',
          tag: '現場點交',
        ),
        CaseJournalLogEntry(
          id: 'log-02',
          timestamp: DateTime.now().subtract(const Duration(days: 15)),
          title: 'LINE 文字正式催告',
          note: '使用小法助應對金句發送租賃專法規定，要求房東提示廠商修繕估價發票。',
          tag: '文字催告',
        ),
        CaseJournalLogEntry(
          id: 'log-03',
          timestamp: DateTime.now().subtract(const Duration(days: 2)),
          title: '小法助防禦大腦檢核',
          note: '審查民法第456條時效剩餘142天，若月底前未匯款，準備寄發存證信函。',
          tag: '自保評估',
        ),
      ],
    );
  }
}
