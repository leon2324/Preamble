import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:preamble/app/app_state.dart';
import 'package:preamble/theme/app_theme.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'responsive_error_collector.dart';
import 'responsive_test_case.dart';

typedef ResponsiveWidgetBuilder = Widget Function();
typedef ResponsiveAuditInteraction = Future<void> Function(WidgetTester tester);

class ResponsiveAuditEntry {
  const ResponsiveAuditEntry({
    required this.id,
    required this.label,
    required this.builder,
    required this.primaryLabels,
    required this.declaredStates,
    this.requiresScroll = false,
    this.ownsAppShell = false,
    this.usesBoundedSettle = false,
    this.supportsEnglish = false,
    this.tappablePrimaryLabels = const <String>[],
    this.allowedTruncatedLabels = const <String>[],
    this.interaction,
  });

  final String id;
  final String label;
  final ResponsiveWidgetBuilder builder;
  final List<String> primaryLabels;

  /// 已知產品狀態的文件宣告，不代表目前每個 fixture 都會切換狀態。
  ///
  /// 台灣繁體中文教學註解：若一個 state 沒有獨立 builder 或 fake 資料，不能
  /// 在報告裡宣稱已自動測試；這個欄位只保留給後續補齊 fixture 時追蹤。
  final List<String> declaredStates;
  final bool requiresScroll;
  final bool ownsAppShell;
  final bool usesBoundedSettle;
  final bool supportsEnglish;
  final List<String> tappablePrimaryLabels;
  final List<String> allowedTruncatedLabels;
  final ResponsiveAuditInteraction? interaction;
}

class ResponsiveAuditResult {
  const ResponsiveAuditResult({
    required this.entry,
    required this.testCase,
    required this.failures,
    required this.missingPrimaryLabels,
    required this.unreachablePrimaryLabels,
    required this.clippedText,
    required this.mediaQueryMismatch,
  });

  final ResponsiveAuditEntry entry;
  final ResponsiveTestCase testCase;
  final List<ResponsiveFailure> failures;
  final List<String> missingPrimaryLabels;
  final List<String> unreachablePrimaryLabels;
  final List<String> clippedText;
  final String? mediaQueryMismatch;

  bool get hasLayoutFailure => failures.any((failure) => failure.isLayout);
  bool get hasMissingPrimaryAction => missingPrimaryLabels.isNotEmpty;
  bool get hasViolation =>
      hasLayoutFailure ||
      hasMissingPrimaryAction ||
      unreachablePrimaryLabels.isNotEmpty ||
      clippedText.isNotEmpty ||
      mediaQueryMismatch != null;

  String get summary {
    final issueCount = failures.length +
        missingPrimaryLabels.length +
        unreachablePrimaryLabels.length +
        clippedText.length +
        (mediaQueryMismatch == null ? 0 : 1);
    return '${entry.id}/${testCase.id}: '
        '${hasViolation ? 'VIOLATION' : 'PASS'} '
        '${testCase.description}'
        '${missingPrimaryLabels.isEmpty ? '' : ' missing=${missingPrimaryLabels.join(',')}'}'
        '${unreachablePrimaryLabels.isEmpty ? '' : ' unreachable=${unreachablePrimaryLabels.join(',')}'}'
        '${clippedText.isEmpty ? '' : ' clipped=${clippedText.length}'}'
        '${mediaQueryMismatch == null ? '' : ' mismatch=$mediaQueryMismatch'}'
        '${issueCount == 0 ? '' : ' issues=$issueCount'}';
  }
}

/// 讓真實產品 widget 在統一的裝置條件下啟動。
class ResponsiveTestHarness {
  Future<ResponsiveAuditResult> pumpEntry(
    WidgetTester tester, {
    required ResponsiveAuditEntry entry,
    required ResponsiveTestCase testCase,
    bool failOnUnexpectedFailures = false,
  }) async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = testCase.viewport;
    addTearDown(() {
      tester.view.resetDevicePixelRatio();
      tester.view.resetPhysicalSize();
    });

    final collector = ResponsiveErrorCollector()..install();
    MediaQueryData? actualMediaQuery;
    try {
      await tester.pumpWidget(
        _buildTestTree(
          entry,
          testCase,
          onMediaQueryRead: (data) => actualMediaQuery = data,
        ),
      );
      await tester.pump();

      if (entry.usesBoundedSettle) {
        try {
          await tester.pumpAndSettle(
            const Duration(milliseconds: 100),
            EnginePhase.sendSemanticsUpdate,
            const Duration(seconds: 3),
          );
        } on TestFailure catch (error) {
          collector.captureTesterException(tester);
          // timeout 需要保留在摘要，但其他頁面仍可繼續完成矩陣。
          collector.recordException(error, library: 'responsive_audit');
        }
      } else {
        // 常駐輪播不會 idle，固定推進可驗證首幀與短動畫而不誤判為 timeout。
        await tester.pump(const Duration(milliseconds: 500));
      }

      final beforeInteraction = await _inspectPrimaryContent(
        tester,
        entry: entry,
        testCase: testCase,
      );

      if (entry.interaction != null) {
        await entry.interaction!(tester);
        await tester.pump(const Duration(milliseconds: 300));
      }
      final afterInteraction = await _inspectPrimaryContent(
        tester,
        entry: entry,
        testCase: testCase,
      );
      await _tapRegisteredActions(tester, entry);
      collector.captureTesterException(tester);

      return ResponsiveAuditResult(
        entry: entry,
        testCase: testCase,
        failures: collector.failures,
        missingPrimaryLabels: <String>{
          ...beforeInteraction.missing,
          ...afterInteraction.missing,
        }.toList(growable: false),
        unreachablePrimaryLabels: <String>{
          ...beforeInteraction.unreachable,
          ...afterInteraction.unreachable,
        }.toList(growable: false),
        clippedText: <String>{
          ...beforeInteraction.clipped,
          ...afterInteraction.clipped,
        }.toList(growable: false),
        mediaQueryMismatch: _mediaQueryMismatch(actualMediaQuery, testCase),
      );
    } finally {
      collector.restore();
      if (failOnUnexpectedFailures) {
        collector.throwIfUnexpectedFailures();
      }
    }
  }

  Widget _buildTestTree(
    ResponsiveAuditEntry entry,
    ResponsiveTestCase testCase, {
    required ValueChanged<MediaQueryData> onMediaQueryRead,
  }) {
    final mediaQuery = MediaQueryData(
      size: testCase.viewport,
      padding: testCase.padding,
      viewPadding: testCase.viewPadding,
      viewInsets: testCase.viewInsets,
      textScaler: TextScaler.linear(testCase.textScale),
    );

    return MediaQuery(
      data: mediaQuery,
      child: _ResponsiveMediaQueryProbe(
        onMediaQueryRead: onMediaQueryRead,
        child: ScreenUtilInit(
          designSize: const Size(375, 812),
          minTextAdapt: true,
          splitScreenMode: true,
          builder: (_, __) {
            if (entry.ownsAppShell) return entry.builder();
            return PreambleScope(
              state: PreambleState(),
              child: MaterialApp(
                locale: testCase.locale,
                debugShowCheckedModeBanner: false,
                theme: AppTheme.light(),
                home: entry.builder(),
              ),
            );
          },
        ),
      ),
    );
  }

  Future<_PrimaryInspection> _inspectPrimaryContent(
    WidgetTester tester, {
    required ResponsiveAuditEntry entry,
    required ResponsiveTestCase testCase,
  }) async {
    final missing = <String>[];
    final unreachable = <String>[];
    final clipped = <String>[];
    final viewport = Offset.zero & testCase.viewport;

    for (final label in entry.primaryLabels) {
      final finder = find.textContaining(label);
      if (finder.evaluate().isEmpty) {
        missing.add(label);
        continue;
      }
      if (entry.requiresScroll) {
        await tester.ensureVisible(finder.first);
        await tester.pump();
      }
      final visibleCandidates = finder.evaluate().where((element) {
        final renderObject = element.renderObject;
        if (renderObject is! RenderBox || !renderObject.hasSize) return false;
        return (renderObject.localToGlobal(Offset.zero) & renderObject.size)
            .overlaps(viewport);
      }).toList(growable: false);
      if (visibleCandidates.isEmpty) {
        unreachable.add(label);
        continue;
      }
      if (_isPrimaryLabelClipped(tester, finder, entry, label)) {
        clipped.add(label);
      }
    }
    return _PrimaryInspection(
      missing: missing,
      unreachable: unreachable,
      clipped: clipped,
    );
  }

  Future<void> _tapRegisteredActions(
    WidgetTester tester,
    ResponsiveAuditEntry entry,
  ) async {
    for (final label in entry.tappablePrimaryLabels) {
      final finder = find.textContaining(label).hitTestable();
      if (finder.evaluate().isEmpty) continue;
      await tester.tap(finder.first, warnIfMissed: false);
      await tester.pump(const Duration(milliseconds: 100));
    }
  }

  bool _isPrimaryLabelClipped(
    WidgetTester tester,
    Finder finder,
    ResponsiveAuditEntry entry,
    String label,
  ) {
    if (entry.allowedTruncatedLabels.contains(label)) return false;
    for (final element in finder.evaluate()) {
      final widget = element.widget;
      if (widget is! Text) continue;
      final renderObject = element.renderObject;
      if (renderObject is RenderParagraph) {
        if (renderObject.didExceedMaxLines ||
            (renderObject.hasSize &&
                (renderObject.size.width > renderObject.constraints.maxWidth ||
                    renderObject.size.height >
                        renderObject.constraints.maxHeight))) {
          return true;
        }
      }
      if ((widget.overflow == TextOverflow.ellipsis ||
              widget.overflow == TextOverflow.fade ||
              widget.overflow == TextOverflow.clip) &&
          renderObject is RenderParagraph &&
          renderObject.didExceedMaxLines) {
        return true;
      }
      final clipAncestors = find
          .ancestor(
            of: find.byElementPredicate((candidate) => candidate == element),
            matching: find.byType(ClipRect),
          )
          .evaluate();
      for (final clipAncestor in clipAncestors) {
        final clipRenderObject = clipAncestor.renderObject;
        if (renderObject is RenderBox &&
            clipRenderObject is RenderBox &&
            renderObject.hasSize &&
            clipRenderObject.hasSize &&
            (renderObject.size.width > clipRenderObject.size.width ||
                renderObject.size.height > clipRenderObject.size.height)) {
          return true;
        }
      }
    }
    return false;
  }

  String? _mediaQueryMismatch(
    MediaQueryData? actual,
    ResponsiveTestCase testCase,
  ) {
    if (actual == null) return 'MediaQuery probe did not build.';
    final expectedPadding = testCase.padding;
    final expectedViewPadding = testCase.viewPadding;
    final expectedViewInsets = testCase.viewInsets;
    if (actual.size != testCase.viewport ||
        actual.padding != expectedPadding ||
        actual.viewPadding != expectedViewPadding ||
        actual.viewInsets != expectedViewInsets ||
        _textScaleOf(actual.textScaler) != testCase.textScale) {
      return 'Expected ${testCase.description}; received '
          'size=${actual.size} text=${_textScaleOf(actual.textScaler)} '
          'padding=${actual.padding} viewPadding=${actual.viewPadding} '
          'viewInsets=${actual.viewInsets}.';
    }
    return null;
  }

  double _textScaleOf(TextScaler textScaler) {
    return textScaler.scale(100) / 100;
  }
}

class _PrimaryInspection {
  const _PrimaryInspection({
    required this.missing,
    required this.unreachable,
    required this.clipped,
  });

  final List<String> missing;
  final List<String> unreachable;
  final List<String> clipped;
}

class _ResponsiveMediaQueryProbe extends StatelessWidget {
  const _ResponsiveMediaQueryProbe({
    required this.onMediaQueryRead,
    required this.child,
  });

  final ValueChanged<MediaQueryData> onMediaQueryRead;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    onMediaQueryRead(MediaQuery.of(context));
    return child;
  }
}
