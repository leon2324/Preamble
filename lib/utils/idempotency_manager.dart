import 'package:uuid/uuid.dart';
import 'package:flutter/foundation.dart';

/// 管理 API 請求的防重發機制 (Idempotency Key)
class IdempotencyManager {
  IdempotencyManager._privateConstructor();
  static final IdempotencyManager instance = IdempotencyManager._privateConstructor();

  final _uuid = const Uuid();
  
  // 記錄已經發送並成功處理的 key (In-Memory MVP，實務上可放 SharedPreferences)
  final Set<String> _usedKeys = {};

  /// 產生一組新的 Idempotency-Key (UUID v4)
  String generateKey() {
    return _uuid.v4();
  }

  /// 標記該 Key 已經使用，如果已經存在則回傳 false (代表重複請求)
  bool markAsUsed(String key) {
    if (_usedKeys.contains(key)) {
      debugPrint('IdempotencyManager: Blocked duplicate request with key $key');
      return false; // 已被使用過，阻擋重發
    }
    
    _usedKeys.add(key);
    
    // 簡單的 GC 機制，避免 Set 無限膨脹 (保留最近的 100 筆)
    if (_usedKeys.length > 100) {
      _usedKeys.remove(_usedKeys.first);
    }
    
    return true; // 成功標記為已使用
  }

  /// 清除快取 (登出時呼叫)
  void clear() {
    _usedKeys.clear();
  }
}
