import 'package:flutter_test/flutter_test.dart';
import 'package:preamble/app/native_startup_coordinator.dart';

void main() {
  test('returns null when every startup payload is null', () async {
    final coordinator = NativeStartupCoordinator();
    final handled = <String>[];

    final result = await coordinator.consumeAndHandleInitialEvents(
      consumeQuickAskPrompt: () async => null,
      consumeStatuteQuery: () async => null,
      consumeDeepLink: () async => null,
      handleQuickAskPrompt: (payload) => handled.add('quick:$payload'),
      handleStatuteQuery: (payload) => handled.add('statute:$payload'),
      handleDeepLink: (payload) => handled.add('link:$payload'),
      isMounted: () => true,
    );

    expect(result, isNull);
    expect(handled, isEmpty);
  });

  test('handles quick ask when only quick ask has a value', () async {
    final handled = await _handleStartup(quickAsk: '租屋押金');

    expect(handled, ['quick:租屋押金']);
  });

  test('handles spotlight when only spotlight has a value', () async {
    final handled = await _handleStartup(statute: '民法 184');

    expect(handled, ['statute:民法 184']);
  });

  test('handles deep link when spotlight is null', () async {
    final handled = await _handleStartup(deepLink: 'preamble://tips');

    expect(handled, ['link:preamble://tips']);
  });

  test('quick ask wins when quick ask and deep link both exist', () async {
    final handled = await _handleStartup(
      quickAsk: '我要問問題',
      deepLink: 'preamble://chat',
    );

    expect(handled, ['quick:我要問問題']);
  });

  test('spotlight wins when spotlight and deep link both exist', () async {
    final handled = await _handleStartup(
      statute: '勞基法 24',
      deepLink: 'preamble://tips',
    );

    expect(handled, ['statute:勞基法 24']);
  });

  test('quick ask wins when every startup payload exists', () async {
    final handled = await _handleStartup(
      quickAsk: '快問',
      statute: '民法 421',
      deepLink: 'preamble://time-machine',
    );

    expect(handled, ['quick:快問']);
  });

  test('blank strings are ignored', () async {
    final handled = await _handleStartup(
      quickAsk: '   ',
      statute: '\n',
      deepLink: 'preamble://tips',
    );

    expect(handled, ['link:preamble://tips']);
  });

  test('the same payload is not handled twice', () async {
    final coordinator = NativeStartupCoordinator();
    final handled = <String>[];

    Future<void> run() {
      return coordinator.consumeAndHandleInitialEvents(
        consumeQuickAskPrompt: () async => '租屋押金',
        consumeStatuteQuery: () async => null,
        consumeDeepLink: () async => null,
        handleQuickAskPrompt: (payload) => handled.add('quick:$payload'),
        handleStatuteQuery: (payload) => handled.add('statute:$payload'),
        handleDeepLink: (payload) => handled.add('link:$payload'),
        isMounted: () => true,
      );
    }

    await run();
    await run();

    expect(handled, ['quick:租屋押金']);
  });

  test('does not run callbacks after dispose', () async {
    final coordinator = NativeStartupCoordinator()..dispose();
    final handled = <String>[];

    final result = await coordinator.consumeAndHandleInitialEvents(
      consumeQuickAskPrompt: () async => '租屋押金',
      consumeStatuteQuery: () async => null,
      consumeDeepLink: () async => null,
      handleQuickAskPrompt: (payload) => handled.add('quick:$payload'),
      handleStatuteQuery: (payload) => handled.add('statute:$payload'),
      handleDeepLink: (payload) => handled.add('link:$payload'),
      isMounted: () => true,
    );

    expect(result?.type, NativeStartupEventType.quickAsk);
    expect(handled, isEmpty);
  });

  test('does not run callbacks when widget is unmounted', () async {
    final handled = await _handleStartup(quickAsk: '租屋押金', mounted: false);

    expect(handled, isEmpty);
  });

  test('other startup paths still run when one consumer throws', () async {
    final coordinator = NativeStartupCoordinator();
    final handled = <String>[];
    final errors = <Object>[];

    await coordinator.consumeAndHandleInitialEvents(
      consumeQuickAskPrompt: () async => throw StateError('quick failed'),
      consumeStatuteQuery: () async => null,
      consumeDeepLink: () async => 'preamble://tips',
      handleQuickAskPrompt: (payload) => handled.add('quick:$payload'),
      handleStatuteQuery: (payload) => handled.add('statute:$payload'),
      handleDeepLink: (payload) => handled.add('link:$payload'),
      isMounted: () => true,
      onError: (error, stack) => errors.add(error),
    );

    expect(errors.single, isA<StateError>());
    expect(handled, ['link:preamble://tips']);
  });

  test('handler exception is reported without falling through', () async {
    final coordinator = NativeStartupCoordinator();
    final handled = <String>[];
    final errors = <Object>[];

    final result = await coordinator.consumeAndHandleInitialEvents(
      consumeQuickAskPrompt: () async => '租屋押金',
      consumeStatuteQuery: () async => '民法 184',
      consumeDeepLink: () async => 'preamble://tips',
      handleQuickAskPrompt: (payload) => throw StateError('handler failed'),
      handleStatuteQuery: (payload) => handled.add('statute:$payload'),
      handleDeepLink: (payload) => handled.add('link:$payload'),
      isMounted: () => true,
      onError: (error, stack) => errors.add(error),
    );

    expect(result?.type, NativeStartupEventType.quickAsk);
    expect(errors.single, isA<StateError>());
    expect(handled, isEmpty);
  });

  test('failed handler does not mark event as deduped', () async {
    final coordinator = NativeStartupCoordinator();
    final handled = <String>[];
    final errors = <Object>[];
    var shouldThrow = true;

    Future<NativeStartupEvent?> run() {
      return coordinator.consumeAndHandleInitialEvents(
        consumeQuickAskPrompt: () async => '租屋押金',
        consumeStatuteQuery: () async => null,
        consumeDeepLink: () async => null,
        handleQuickAskPrompt: (payload) {
          if (shouldThrow) {
            throw StateError('try again later');
          }
          handled.add('quick:$payload');
        },
        handleStatuteQuery: (payload) => handled.add('statute:$payload'),
        handleDeepLink: (payload) => handled.add('link:$payload'),
        isMounted: () => true,
        onError: (error, stack) => errors.add(error),
      );
    }

    final firstResult = await run();
    shouldThrow = false;
    final secondResult = await run();

    expect(firstResult?.type, NativeStartupEventType.quickAsk);
    expect(secondResult?.type, NativeStartupEventType.quickAsk);
    expect(errors.single, isA<StateError>());
    expect(handled, ['quick:租屋押金']);
  });
}

Future<List<String>> _handleStartup({
  String? quickAsk,
  String? statute,
  String? deepLink,
  bool mounted = true,
}) async {
  final coordinator = NativeStartupCoordinator();
  final handled = <String>[];

  await coordinator.consumeAndHandleInitialEvents(
    consumeQuickAskPrompt: () async => quickAsk,
    consumeStatuteQuery: () async => statute,
    consumeDeepLink: () async => deepLink,
    handleQuickAskPrompt: (payload) => handled.add('quick:$payload'),
    handleStatuteQuery: (payload) => handled.add('statute:$payload'),
    handleDeepLink: (payload) => handled.add('link:$payload'),
    isMounted: () => mounted,
  );

  return handled;
}
