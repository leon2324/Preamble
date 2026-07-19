import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:preamble/app/app_state.dart';
import 'package:preamble/pages/learning/know_law_page.dart';
import 'package:preamble/pages/learning/widgets/notebook_aesthetics.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'support/responsive_error_collector.dart';

void main() {
  Future<void> pumpLearningPage(
    WidgetTester tester, {
    required Size size,
    required EdgeInsets padding,
    required double textScale,
    bool shellConsumesTopInset = false,
  }) async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = size;
    addTearDown(() {
      tester.view.resetDevicePixelRatio();
      tester.view.resetPhysicalSize();
    });

    final appState = PreambleState();
    addTearDown(appState.dispose);
    await tester.pumpWidget(
      MediaQuery(
        data: MediaQueryData(
          size: size,
          padding: padding,
          viewPadding: padding,
          textScaler: TextScaler.linear(textScale),
        ),
        child: ScreenUtilInit(
          designSize: const Size(375, 812),
          minTextAdapt: true,
          splitScreenMode: true,
          builder: (_, __) => PreambleScope(
            state: appState,
            child: MaterialApp(
              home: shellConsumesTopInset
                  ? SafeArea(child: const KnowLawPage())
                  : const KnowLawPage(),
            ),
          ),
        ),
      ),
    );
    await tester.pump(const Duration(milliseconds: 500));
  }

  testWidgets(
      'learning page uses content inset while notebook background reaches status bar',
      (tester) async {
    await pumpLearningPage(
      tester,
      size: const Size(393, 852),
      padding: const EdgeInsets.only(top: 59, bottom: 34),
      textScale: 1,
    );

    final backgroundRect = tester.getRect(find.byType(NotebookBackground));
    final titleRect = tester.getRect(find.text('學堂與工具箱'));
    final listView = tester.widget<ListView>(find.byType(ListView).first);

    expect(backgroundRect.top, 0);
    expect(titleRect.top, greaterThanOrEqualTo(59));
    expect(titleRect.top, lessThan(100));
    expect(find.byTooltip('編輯我的筆記本封面').hitTestable(), findsOneWidget);
    expect(
      find.ancestor(
        of: find.byType(ListView).first,
        matching: find.byType(SafeArea),
      ),
      findsNothing,
    );
    expect((listView.padding! as EdgeInsets).bottom, greaterThanOrEqualTo(34));
    expect(tester.takeException(), isNull);
  });

  testWidgets('learning page does not double count a shell-consumed top inset',
      (tester) async {
    await pumpLearningPage(
      tester,
      size: const Size(393, 852),
      padding: const EdgeInsets.only(top: 59, bottom: 34),
      textScale: 1,
      shellConsumesTopInset: true,
    );

    final titleRect = tester.getRect(find.text('學堂與工具箱'));
    expect(titleRect.top, greaterThanOrEqualTo(59));
    expect(titleRect.top, lessThan(100));
    expect(tester.takeException(), isNull);
  });

  testWidgets(
      'learning content retains inset safety at 160%, 200%, and landscape',
      (tester) async {
    for (final scenario in [
      (const Size(393, 852), const EdgeInsets.only(top: 59, bottom: 34), 1.6),
      (const Size(393, 852), const EdgeInsets.only(top: 59, bottom: 34), 2.0),
      (const Size(852, 393), const EdgeInsets.only(left: 44, right: 44), 1.0),
    ]) {
      final collector = ResponsiveErrorCollector()..install();
      try {
        await pumpLearningPage(
          tester,
          size: scenario.$1,
          padding: scenario.$2,
          textScale: scenario.$3,
        );
      } finally {
        collector.captureTesterException(tester);
        collector.restore();
      }

      final titleRect = tester.getRect(find.text('學堂與工具箱'));
      final listView = tester.widget<ListView>(find.byType(ListView).first);
      final padding = listView.padding! as EdgeInsets;
      expect(titleRect.top, greaterThanOrEqualTo(scenario.$2.top));
      expect(padding.left, greaterThanOrEqualTo(scenario.$2.left));
      expect(padding.right, greaterThanOrEqualTo(scenario.$2.right));
      expect(find.byType(ListView), findsOneWidget);
      // 台灣繁體中文教學註解：160%／200% 的既有 Learning tab switcher
      // RenderFlex baseline 由完整 responsive audit 比對；此 focused test 只
      // 守住 inset，任何非 layout 例外都不能被當成既有問題略過。
      collector.throwIfUnexpectedFailures();
    }
  });
}
