import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// 未登入使用者的小法助使用次數限制。
///
/// 第一版產品規則是 guest 只能問一次；這裡集中保存 key，日後改成後端
/// 驗證或登入系統後，UI 不需要散落 shared_preferences 細節。
class GuestLawAssistantUsage {
  static const _usedKey = 'guestLawAssistantUsed';

  const GuestLawAssistantUsage();

  Future<bool> hasUsed() async {
    try {
      final preferences = await SharedPreferences.getInstance();
      return preferences.getBool(_usedKey) ?? false;
    } on MissingPluginException {
      // 教學註解：新增原生 plugin 後，如果只 hot restart，iOS/Android 可能尚未
      // 完成 plugin 註冊。這裡先回退成「尚未使用」，避免開發畫面直接崩潰。
      return false;
    }
  }

  Future<void> markUsed() async {
    try {
      final preferences = await SharedPreferences.getInstance();
      await preferences.setBool(_usedKey, true);
    } on MissingPluginException {
      // 教學註解：正式重新編譯後會正常持久化；開發中的 plugin 註冊空窗期
      // 則先略過寫入，讓小法助流程可以繼續被預覽。
    }
  }

  Future<void> resetForDebug() async {
    try {
      final preferences = await SharedPreferences.getInstance();
      await preferences.remove(_usedKey);
    } on MissingPluginException {
      // plugin 尚未註冊時沒有本機值可清，直接略過即可。
    }
  }
}
