import 'dart:async';

enum NativeStartupEventType {
  quickAsk,
  statuteSpotlight,
  deepLink,
}

class NativeStartupEvent {
  const NativeStartupEvent({
    required this.type,
    required this.payload,
  });

  final NativeStartupEventType type;
  final String payload;

  String get dedupeKey => '${type.name}:$payload';
}

typedef NativeStartupPayloadConsumer = Future<String?> Function();
typedef NativeStartupEventHandler = FutureOr<void> Function(String payload);
typedef NativeStartupMountedCheck = bool Function();
typedef NativeStartupErrorHandler = void Function(
    Object error, StackTrace stack);

/// 台灣繁體中文教學註解：
/// 冷啟動時 Quick Ask、Spotlight、Deep Link 都可能在 Flutter listener 準備好之前抵達。
/// Coordinator 會先把三種 pending payload 都消費掉，再依「Quick Ask > Spotlight > Deep Link」
/// 選出本次啟動唯一要導航的事件，避免某一路徑為 null 時提早 return，也避免重複導航。
class NativeStartupCoordinator {
  final Set<String> _handledEventKeys = <String>{};
  bool _isDisposed = false;

  void dispose() {
    _isDisposed = true;
  }

  Future<NativeStartupEvent?> consumeAndHandleInitialEvents({
    required NativeStartupPayloadConsumer consumeQuickAskPrompt,
    required NativeStartupPayloadConsumer consumeStatuteQuery,
    required NativeStartupPayloadConsumer consumeDeepLink,
    required NativeStartupEventHandler handleQuickAskPrompt,
    required NativeStartupEventHandler handleStatuteQuery,
    required NativeStartupEventHandler handleDeepLink,
    required NativeStartupMountedCheck isMounted,
    NativeStartupErrorHandler? onError,
  }) async {
    final events = <NativeStartupEvent>[
      if (_validEvent(
        NativeStartupEventType.quickAsk,
        await _consumeSafely(consumeQuickAskPrompt, onError),
      )
          case final event?)
        event,
      if (_validEvent(
        NativeStartupEventType.statuteSpotlight,
        await _consumeSafely(consumeStatuteQuery, onError),
      )
          case final event?)
        event,
      if (_validEvent(
        NativeStartupEventType.deepLink,
        await _consumeSafely(consumeDeepLink, onError),
      )
          case final event?)
        event,
    ];

    for (final event in events) {
      if (_handledEventKeys.contains(event.dedupeKey)) {
        continue;
      }
      if (_isDisposed || !isMounted()) {
        return event;
      }
      final didHandle = await _handleSafely(
        event,
        handleQuickAskPrompt: handleQuickAskPrompt,
        handleStatuteQuery: handleStatuteQuery,
        handleDeepLink: handleDeepLink,
        onError: onError,
      );
      if (didHandle) {
        _handledEventKeys.add(event.dedupeKey);
      }
      return event;
    }

    return null;
  }

  Future<String?> _consumeSafely(
    NativeStartupPayloadConsumer consumer,
    NativeStartupErrorHandler? onError,
  ) async {
    try {
      return await consumer();
    } catch (error, stack) {
      onError?.call(error, stack);
      return null;
    }
  }

  NativeStartupEvent? _validEvent(NativeStartupEventType type, String? value) {
    final payload = value?.trim();
    if (payload == null || payload.isEmpty) return null;
    return NativeStartupEvent(type: type, payload: payload);
  }

  Future<bool> _handleSafely(
    NativeStartupEvent event, {
    required NativeStartupEventHandler handleQuickAskPrompt,
    required NativeStartupEventHandler handleStatuteQuery,
    required NativeStartupEventHandler handleDeepLink,
    NativeStartupErrorHandler? onError,
  }) async {
    try {
      await _handleEvent(
        event,
        handleQuickAskPrompt: handleQuickAskPrompt,
        handleStatuteQuery: handleStatuteQuery,
        handleDeepLink: handleDeepLink,
      );
      return true;
    } catch (error, stack) {
      onError?.call(error, stack);
      return false;
    }
  }

  Future<void> _handleEvent(
    NativeStartupEvent event, {
    required NativeStartupEventHandler handleQuickAskPrompt,
    required NativeStartupEventHandler handleStatuteQuery,
    required NativeStartupEventHandler handleDeepLink,
  }) async {
    switch (event.type) {
      case NativeStartupEventType.quickAsk:
        await handleQuickAskPrompt(event.payload);
        break;
      case NativeStartupEventType.statuteSpotlight:
        await handleStatuteQuery(event.payload);
        break;
      case NativeStartupEventType.deepLink:
        await handleDeepLink(event.payload);
        break;
    }
  }
}
