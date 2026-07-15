import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';

enum ResponsiveFailureKind { layout, unexpected }

/// layout 錯誤的穩定辨識欄位，避免逐字依賴 Flutter 的完整診斷文字。
///
/// 台灣繁體中文教學註解：方向、Render 物件型別與造成錯誤的 widget 型別通常
/// 比完整例外字串穩定。widget 型別未取得時保留 null，baseline 便不會假裝
/// 已驗證該條件。
class ResponsiveLayoutSignature {
  const ResponsiveLayoutSignature({
    required this.layoutType,
    required this.direction,
    this.widgetType,
    this.library,
  });

  final String layoutType;
  final String direction;
  final String? widgetType;
  final String? library;

  factory ResponsiveLayoutSignature.fromDetails({
    required String message,
    required String? diagnosticText,
    required String? library,
  }) {
    final layoutType = message.contains('RenderFlex')
        ? 'RenderFlex'
        : message.contains('RenderViewport')
            ? 'RenderViewport'
            : 'RenderBox';
    final directionMatch = RegExp(
      r'on the (left|right|top|bottom)',
      caseSensitive: false,
    ).firstMatch(message);
    final widgetMatch = RegExp(
      r'error-causing widget was:\s*\n?\s*([A-Za-z0-9_]+)',
      caseSensitive: false,
    ).firstMatch(diagnosticText ?? '');
    return ResponsiveLayoutSignature(
      layoutType: layoutType,
      direction: directionMatch?.group(1)?.toLowerCase() ?? 'unknown',
      widgetType: widgetMatch?.group(1),
      library: library,
    );
  }

  bool matches(ResponsiveLayoutSignature actual) {
    return layoutType == actual.layoutType &&
        direction == actual.direction &&
        (widgetType == null || widgetType == actual.widgetType) &&
        (library == null || library == actual.library);
  }

  String get description {
    final parts = <String>[layoutType, direction];
    if (widgetType != null) parts.add(widgetType!);
    if (library != null) parts.add(library!);
    return parts.join('/');
  }
}

class ResponsiveFailure {
  const ResponsiveFailure({
    required this.kind,
    required this.message,
    this.library,
    this.layoutSignature,
  });

  final ResponsiveFailureKind kind;
  final String message;
  final String? library;
  final ResponsiveLayoutSignature? layoutSignature;

  bool get isLayout => kind == ResponsiveFailureKind.layout;

  ResponsiveLayoutSignature? get effectiveLayoutSignature {
    if (!isLayout) return null;
    return layoutSignature ??
        ResponsiveLayoutSignature.fromDetails(
          message: message,
          diagnosticText: null,
          library: library,
        );
  }

  /// `RenderFlex` 訊息的像素值可用來偵測既有問題明顯惡化。
  double? get overflowPixels {
    final match =
        RegExp(r'by ([0-9]+(?:\\.[0-9]+)?) pixels').firstMatch(message);
    return match == null ? null : double.tryParse(match.group(1)!);
  }
}

/// 暫時收集 framework layout 錯誤，讓 audit 可以跑完一組矩陣後再彙整。
///
/// 台灣繁體中文教學註解：此 collector 只在單一測試案例期間替換
/// `FlutterError.onError`，結束後立刻還原；非 layout 錯誤仍會在案例結束時
/// 以 TestFailure 重新拋出，不能被 audit 靜默吃掉。
class ResponsiveErrorCollector {
  FlutterExceptionHandler? _previousHandler;
  final List<ResponsiveFailure> _failures = <ResponsiveFailure>[];

  List<ResponsiveFailure> get failures => List.unmodifiable(_failures);
  List<ResponsiveFailure> get layoutFailures =>
      _failures.where((failure) => failure.isLayout).toList(growable: false);
  List<ResponsiveFailure> get unexpectedFailures =>
      _failures.where((failure) => !failure.isLayout).toList(growable: false);

  void install() {
    _previousHandler = FlutterError.onError;
    FlutterError.onError = (FlutterErrorDetails details) {
      _record(
        details.exceptionAsString(),
        library: details.library,
        diagnosticText: details.toString(),
      );
    };
  }

  void captureTesterException(WidgetTester tester) {
    Object? exception;
    while ((exception = tester.takeException()) != null) {
      _record(exception.toString());
    }
  }

  void recordException(Object exception, {String? library}) {
    _record(exception.toString(), library: library);
  }

  void restore() {
    FlutterError.onError = _previousHandler;
    _previousHandler = null;
  }

  void throwIfUnexpectedFailures() {
    if (unexpectedFailures.isEmpty) return;
    final details =
        unexpectedFailures.map((failure) => failure.message).join('\n\n');
    throw TestFailure(
        'Responsive audit captured a non-layout exception:\n$details');
  }

  void _record(
    String message, {
    String? library,
    String? diagnosticText,
  }) {
    final kind = _isLayoutMessage(message)
        ? ResponsiveFailureKind.layout
        : ResponsiveFailureKind.unexpected;
    if (_failures.any(
      (failure) =>
          failure.kind == kind &&
          failure.message == message &&
          failure.library == library,
    )) {
      return;
    }
    _failures.add(
      ResponsiveFailure(
        kind: kind,
        message: message,
        library: library,
        layoutSignature: kind == ResponsiveFailureKind.layout
            ? ResponsiveLayoutSignature.fromDetails(
                message: message,
                diagnosticText: diagnosticText,
                library: library,
              )
            : null,
      ),
    );
  }

  bool _isLayoutMessage(String message) {
    const fragments = <String>[
      'RenderFlex overflowed',
      'A RenderBox was not laid out',
      'BoxConstraints forces an infinite',
      'was given an infinite size',
      'viewport was given unbounded',
      'A RenderViewport expected a bounded',
      'was not laid out',
    ];
    return fragments.any(message.contains);
  }
}
