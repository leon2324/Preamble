import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// 原生系統分享面板橋接層。
///
/// Flutter 端只負責整理要分享的文字或圖卡資料，再交給 iOS / Android 原生端開啟
/// 系統分享畫面。這樣使用者看到的是 Apple / Android 原生分享面板，而不是 App 內
/// 自己假裝完成分享；若平台尚未支援，呼叫端要準備複製連結等備援流程。
class NativeShareBridge {
  const NativeShareBridge._();

  static const _channel = MethodChannel('lawapp/native_share');

  static bool get _isSupported =>
      !kIsWeb &&
      (defaultTargetPlatform == TargetPlatform.iOS ||
          defaultTargetPlatform == TargetPlatform.android);

  static Future<bool> shareText({
    required String title,
    required String text,
  }) async {
    if (!_isSupported) return false;

    try {
      await _channel.invokeMethod<void>(
        'shareText',
        <String, Object>{
          'title': title,
          'text': text,
        },
      );
      return true;
    } on MissingPluginException {
      return false;
    } on PlatformException {
      return false;
    }
  }

  static Future<bool> shareTipCard({
    required String title,
    required String summary,
    required String source,
  }) async {
    if (!_isSupported) return false;

    try {
      await _channel.invokeMethod<void>(
        'shareTipCard',
        <String, Object>{
          'title': title,
          'summary': summary,
          'source': source,
        },
      );
      return true;
    } on MissingPluginException {
      return false;
    } on PlatformException {
      return false;
    }
  }
}
