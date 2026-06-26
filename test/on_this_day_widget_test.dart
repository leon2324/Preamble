import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:lawapp/app/app_state.dart';
import 'package:lawapp/features/on_this_day/pages/on_this_day_home_page.dart';
import 'package:lawapp/features/on_this_day/pages/on_this_day_date_discovery_page.dart';

void main() {
  testWidgets('On This Day flow walks through home, detail, discovery and categories list',
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

    // 1. Home Page Checks
    expect(find.text('那年今日'), findsOneWidget);
    expect(find.text('鄭南榕事件'), findsWidgets);
    expect(find.text('4 / 7'), findsOneWidget);
    expect(find.text('倒回前一天'), findsOneWidget);

    // Tap "回到那一天" to enter Case Detail Page
    await tester.tap(find.text('回到那一天'));
    await tester.pumpAndSettle();

    // 2. Case Detail Page Checks
    expect(find.text('案件簡略'), findsOneWidget);
    expect(find.text('時間線'), findsOneWidget);
    expect(find.text('歷史照片'), findsOneWidget);
    expect(find.text('時代背景'), findsOneWidget);
    expect(find.text('延伸影響'), findsOneWidget);
    expect(find.text('資料來源'), findsOneWidget);

    // Tab 0: 案件簡略 content
    expect(find.text('事件簡介'), findsOneWidget);
    expect(find.text('要旨速覽'), findsOneWidget);

    // Switch to Tab 1: 時間線
    await tester.ensureVisible(find.text('時間線'));
    await tester.tap(find.text('時間線'));
    await tester.pumpAndSettle();
    expect(find.text('事件發展脈絡'), findsOneWidget);

    // Switch to Tab 2: 歷史照片
    await tester.ensureVisible(find.text('歷史照片'));
    await tester.tap(find.text('歷史照片'));
    await tester.pumpAndSettle();
    expect(find.text('現場與歷史見證'), findsOneWidget);

    // Switch to Tab 3: 時代背景
    await tester.ensureVisible(find.text('時代背景'));
    await tester.tap(find.text('時代背景'));
    await tester.pumpAndSettle();
    expect(find.text('時代背景脈絡'), findsOneWidget);

    // Switch to Tab 4: 延伸影響
    await tester.ensureVisible(find.text('延伸影響'));
    await tester.tap(find.text('延伸影響'));
    await tester.pumpAndSettle();
    expect(find.text('社會影響效應'), findsOneWidget);
    expect(find.text('相關延伸案件'), findsOneWidget);

    // Switch to Tab 5: 資料來源
    await tester.ensureVisible(find.text('資料來源'));
    await tester.tap(find.text('資料來源'));
    await tester.pumpAndSettle();
    expect(find.text('資料來源與修訂'), findsOneWidget);
    expect(find.textContaining('免責聲明：'), findsOneWidget);

    // Tap bottom button to return home
    await tester.tap(find.text('查看更多歷史案件'));
    await tester.pumpAndSettle();

    // Back to Home, check Date Discovery Page
    expect(find.text('那年今日'), findsOneWidget);
    await tester.tap(find.text('本月'));
    await tester.pumpAndSettle();

    // 3. Date Discovery Page Checks
    expect(find.text('日期探索'), findsOneWidget);
    expect(find.text('4月7日'), findsOneWidget);
    expect(find.text('在 4月7日 發生的重要事件'), findsOneWidget);
    expect(find.text('查看案件').first, findsOneWidget);

    // Go back
    await tester.tap(find.descendant(
      of: find.byType(OnThisDayDateDiscoveryPage),
      matching: find.byIcon(Icons.arrow_back_ios_new_rounded),
    ));
    await tester.pumpAndSettle();

    // Back to Home, check Category List Page
    expect(find.text('那年今日'), findsOneWidget);
    await tester.tap(find.text('查看全部'));
    await tester.pumpAndSettle();

    // 4. Category List Page Checks
    expect(find.text('歷史案件'), findsOneWidget);
    expect(find.text('全部'), findsOneWidget);
    expect(find.text('言論自由'), findsOneWidget);
    expect(find.text('民主運動'), findsOneWidget);
    expect(find.text('公共安全'), findsOneWidget);
    expect(find.text('司法爭議'), findsOneWidget);
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
