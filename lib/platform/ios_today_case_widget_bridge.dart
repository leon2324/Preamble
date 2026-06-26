import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// iOS 今日判決故事 Widget 的 Flutter 資料橋接。
///
/// WidgetKit extension 不能直接讀 Flutter 記憶體，也不能載入 Dart runtime；
/// 因此 Flutter 端把首頁「今天判決故事」整理成簡短 payload，
/// 透過 MethodChannel 交給 iOS 寫入 App Group UserDefaults，Widget 再從原生端讀取。
class IosTodayCaseWidgetBridge {
  const IosTodayCaseWidgetBridge._();

  static const _channel = MethodChannel('preamble/today_case_widget');

  static Future<void> syncDefaultStory() async {
    if (kIsWeb || defaultTargetPlatform != TargetPlatform.iOS) {
      return;
    }

    try {
      await _channel.invokeMethod<void>(
        'updateTodayCaseWidget',
        <String, Object>{
          'badge': '每日精選',
          'title': '罵人「毒瘤」算侮辱嗎？',
          'summary': '法院認為公開平台上的貶損用語，可能構成公然侮辱；先看白話整理再判斷下一步。',
          'category': '今日判決故事',
          'prompt': '我想知道法院對於在網路上罵人「毒瘤」被判公然侮辱的相關案例分析與白話解說。',
          'dateLabel': _todayLabel(DateTime.now()),
        },
      );
    } on MissingPluginException {
      // Widget test、Android、或 iOS plugin 尚未註冊時都可能進到這裡；
      // Widget payload 只是加分入口，不應影響 App 啟動。
    } on PlatformException {
      // App Group 尚未在簽章後台開啟時，原生端可能回報寫入失敗；
      // 這裡保持靜默，避免比賽前 Demo App 因 Widget 設定尚未完成而中斷。
    }
  }

  static String _todayLabel(DateTime date) {
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    return '$month/$day';
  }
}
