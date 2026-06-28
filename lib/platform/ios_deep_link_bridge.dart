import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

typedef DeepLinkHandler = void Function(String url);

/// iOS Widget 點擊與生態 Deep Link 入口的 Flutter 橋接層。
class IosDeepLinkBridge {
  const IosDeepLinkBridge._();

  static const _channel = MethodChannel('preamble/deep_link');

  static bool get _isSupported =>
      !kIsWeb && defaultTargetPlatform == TargetPlatform.iOS;

  static void registerLinkHandler(DeepLinkHandler onLink) {
    if (!_isSupported) return;

    _channel.setMethodCallHandler((call) async {
      if (call.method != 'openDeepLink') return null;

      final url = _urlFrom(call.arguments);
      if (url == null) return null;
      onLink(url);
      return null;
    });
  }

  static Future<String?> consumeInitialLink() async {
    if (!_isSupported) return null;

    try {
      final result = await _channel.invokeMethod<Object?>(
        'consumeInitialDeepLink',
      );
      return _urlFrom(result);
    } on MissingPluginException {
      return null;
    } on PlatformException {
      return null;
    }
  }

  static void unregisterLinkHandler() {
    if (!_isSupported) return;
    _channel.setMethodCallHandler(null);
  }

  static String? _urlFrom(Object? value) {
    if (value is String) {
      final url = value.trim();
      return url.isEmpty ? null : url;
    }

    if (value is Map) {
      final rawUrl = value['url'];
      if (rawUrl is! String) return null;
      final url = rawUrl.trim();
      return url.isEmpty ? null : url;
    }

    return null;
  }
}
