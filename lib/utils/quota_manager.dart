import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class QuotaExceededException implements Exception {
  const QuotaExceededException(this.message);
  final String message;

  @override
  String toString() => 'QuotaExceededException: $message';
}

/// 管理使用者的每日 AI 諮詢免費配額 (MVP 採本地端紀錄)
class QuotaManager {
  QuotaManager._privateConstructor();
  static final QuotaManager instance = QuotaManager._privateConstructor();

  static const int _dailyLimit = 5;
  static const String _quotaKey = 'preamble_daily_quota_used';
  static const String _dateKey = 'preamble_quota_date';

  SharedPreferences? _prefs;
  int _usedQuota = 0;
  String _lastRecordedDate = '';

  Future<void> init(SharedPreferences prefs) async {
    _prefs = prefs;
    _loadState();
  }

  void _loadState() {
    if (_prefs == null) return;
    
    final today = _getTodayDateString();
    _lastRecordedDate = _prefs!.getString(_dateKey) ?? '';
    
    if (_lastRecordedDate != today) {
      // 跨日，重置點數
      _usedQuota = 0;
      _lastRecordedDate = today;
      _saveState();
    } else {
      _usedQuota = _prefs!.getInt(_quotaKey) ?? 0;
    }
  }

  void _saveState() {
    if (_prefs == null) return;
    _prefs!.setInt(_quotaKey, _usedQuota);
    _prefs!.setString(_dateKey, _lastRecordedDate);
  }

  String _getTodayDateString() {
    final now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
  }

  /// 取得今日剩餘額度
  int get remainingQuota {
    _loadState(); // 每次存取前檢查是否跨日
    return _dailyLimit - _usedQuota;
  }

  /// 消耗一次額度，若不足則拋出 QuotaExceededException
  void consumeQuota() {
    _loadState();
    if (remainingQuota <= 0) {
      debugPrint('QuotaManager: 每日免費用量已達上限');
      throw const QuotaExceededException('每日免費 AI 諮詢額度已達上限，請升級方案以繼續使用。');
    }
    
    _usedQuota++;
    _saveState();
    debugPrint('QuotaManager: 扣減點數成功，剩餘 $remainingQuota 次');
  }

  /// 用於單元測試強制作為特定日期
  @visibleForTesting
  void testForceSetDateAndQuota(String dateString, int used) {
    _lastRecordedDate = dateString;
    _usedQuota = used;
    _saveState();
  }
}
