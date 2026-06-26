import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

typedef QuickAskPromptHandler = void Function(String prompt);

/// iOS App Intents / Siri 快問入口的 Flutter 橋接層。
///
/// App Intents 是 Apple 原生系統入口，不能直接操作 Flutter widget tree；
/// iOS 端會先把 Siri 或 Shortcuts 傳來的法律問題轉成 MethodChannel 事件，
/// Flutter 主殼層再切到「小法助」分頁並把 prompt 交給搜尋頁狀態機。
class IosQuickAskIntentBridge {
  const IosQuickAskIntentBridge._();

  static const _channel = MethodChannel('preamble/quick_ask_intent');

  static bool get _isSupported =>
      !kIsWeb && defaultTargetPlatform == TargetPlatform.iOS;

  static void registerPromptHandler(QuickAskPromptHandler onPrompt) {
    if (!_isSupported) return;

    _channel.setMethodCallHandler((call) async {
      if (call.method != 'openQuickAsk') return null;

      final prompt = _promptFrom(call.arguments);
      if (prompt == null) return null;
      onPrompt(prompt);
      return null;
    });
  }

  static Future<String?> consumeInitialPrompt() async {
    if (!_isSupported) return null;

    try {
      final result = await _channel.invokeMethod<Object?>(
        'consumeInitialQuickAsk',
      );
      return _promptFrom(result);
    } on MissingPluginException {
      // Widget test、Android 或原生尚未註冊 MethodChannel 時會進到這裡；
      // Siri 快問是 iOS 加分入口，不應讓主 App 啟動失敗。
      return null;
    } on PlatformException {
      return null;
    }
  }

  static void unregisterPromptHandler() {
    if (!_isSupported) return;
    _channel.setMethodCallHandler(null);
  }

  static String? _promptFrom(Object? value) {
    if (value is String) {
      final prompt = value.trim();
      return prompt.isEmpty ? null : prompt;
    }

    if (value is Map) {
      final rawPrompt = value['prompt'];
      if (rawPrompt is! String) return null;
      final prompt = rawPrompt.trim();
      return prompt.isEmpty ? null : prompt;
    }

    return null;
  }
}
