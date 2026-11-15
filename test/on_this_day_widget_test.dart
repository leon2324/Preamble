import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:preamble/app/app_state.dart';
import 'package:preamble/features/on_this_day/pages/on_this_day_home_page.dart';
import 'package:preamble/features/on_this_day/data/on_this_day_mock_data.dart';
import 'package:preamble/features/on_this_day/pages/on_this_day_detail_page.dart';

void main() {
  testWidgets(
      'On This Day flow uses the real date, opens detail tabs and category list',
      (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    _setPhoneSize(tester);

    final appState = PreambleState();
    addTearDown(appState.dispose);
    await appState.load();

    await tester.pumpWidget(
      _testFrame(appState, const OnThisDayHomePage()),
    );
    await tester.pumpAndSettle();

    // 1. Home：標題與「今日座標」必須使用真實日期，而非寫死的 4/7。
    final now = DateTime.now();
    expect(find.text('歷史上的今日'), findsOneWidget);
    expect(find.text('今日座標 · ${now.month}月${now.day}日'), findsOneWidget);

    // 2. 類別列表頁
    await tester.ensureVisible(find.text('查看全部'));
    await tester.tap(find.text('查看全部'));
    await tester.pumpAndSettle();
    expect(find.text('法治歷史事件總覽'), findsOneWidget);
    expect(find.text('全部'), findsWidgets);
    expect(find.text('言論自由'), findsWidgets);
    expect(find.text('民主運動'), findsWidgets);
    expect(find.text('公共安全'), findsWidgets);
    expect(find.text('司法爭議'), findsWidgets);
  });

  testWidgets('On This Day detail page has only real content tabs',
      (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    _setPhoneSize(tester);

    final appState = PreambleState();
    addTearDown(appState.dispose);
    await appState.load();

    await tester.pumpWidget(
      _testFrame(
        appState,
        OnThisDayDetailPage(caseId: onThisDayCases.first.id),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('案件簡略'), findsOneWidget);
    expect(find.text('時間線'), findsOneWidget);
    expect(find.text('時代背景'), findsOneWidget);
    expect(find.text('延伸影響'), findsOneWidget);
    expect(find.text('資料來源'), findsOneWidget);
    // 已移除空白的「歷史照片」假分頁。
    expect(find.text('歷史照片'), findsNothing);

    expect(find.text('事件簡介'), findsOneWidget);
    expect(find.text('要旨速覽'), findsOneWidget);

    for (final entry in const {
      '時間線': '事件發展脈絡',
      '時代背景': '時代背景脈絡',
      '延伸影響': '社會與憲政影響',
      '資料來源': '資料來源與修訂紀錄',
    }.entries) {
      await tester.ensureVisible(find.text(entry.key));
      await tester.tap(find.text(entry.key));
      await tester.pumpAndSettle();
      expect(find.text(entry.value), findsOneWidget);
    }
  });
}

void _setPhoneSize(WidgetTester tester) {
  tester.view.devicePixelRatio = 3.0;
  tester.view.physicalSize = const Size(1179, 2556);
  addTearDown(() {
    tester.view.resetDevicePixelRatio();
    tester.view.resetPhysicalSize();
  });
}

Widget _testFrame(PreambleState appState, Widget child) {
  return ScreenUtilInit(
    designSize: const Size(375, 812),
    minTextAdapt: true,
    splitScreenMode: true,
    builder: (_, __) => PreambleScope(
      state: appState,
      child: MaterialApp(
        home: child,
      ),
    ),
  );
}

class PreambleScope extends InheritedWidget {
  const PreambleScope({
    super.key,
    required this.state,
    required super.child,
  });

  final PreambleState state;

  static PreambleState of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<PreambleScope>();
    return scope!.state;
  }

  @override
  bool updateShouldNotify(covariant PreambleScope oldWidget) =>
      state != oldWidget.state;
}
