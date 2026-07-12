import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:preamble/app/app_state.dart';
import 'package:preamble/pages/learning/know_law_page.dart';

void main() {
  testWidgets('Custom classroom card renders and generates new topic',
      (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});

    tester.view.devicePixelRatio = 3.0;
    tester.view.physicalSize = const Size(1179, 6000);
    addTearDown(() {
      tester.view.resetDevicePixelRatio();
      tester.view.resetPhysicalSize();
    });

    final appState = PreambleState();
    addTearDown(appState.dispose);
    await appState.load();

    await tester.pumpWidget(
      ScreenUtilInit(
        designSize: const Size(375, 812),
        minTextAdapt: true,
        splitScreenMode: true,
        builder: (context, __) => PreambleScope(
          state: appState,
          child: MaterialApp(
            home: const KnowLawPage(),
          ),
        ),
      ),
    );

    await tester.pumpForVerification();

    // Scroll down to reveal more items in the ListView
    await tester.drag(find.byType(ListView), const Offset(0, -1500));
    await tester.pumpForVerification();

    // Verify custom classroom card is rendered
    expect(find.text('訂製專屬法學課堂'), findsOneWidget);

    // Tap on the card to open dialog
    await tester.tap(find.text('訂製專屬法學課堂'));
    await tester.pumpForVerification();

    // Verify dialog has opened
    expect(find.text('請描述您面臨的生活法學困境或糾紛：'), findsOneWidget);

    // Tap on one of the quick tags
    await tester.tap(find.text('#租屋修繕責任'));
    await tester.pumpForVerification();

    // Verify textfield is populated
    expect(find.text('租屋修繕責任'), findsOneWidget);

    // Click on start generation button
    await tester.tap(find.text('開始訂製專屬課堂'));
    await tester.pump(); // Start generation, triggers timer

    // Verify loading screen is shown
    expect(find.text('法律 AI 起草中'), findsOneWidget);

    // Advance timer step-by-step to simulate AI drafting (800ms * 4 = 3200ms)
    await tester.pump(const Duration(milliseconds: 800));
    await tester.pump(const Duration(milliseconds: 800));
    await tester.pump(const Duration(milliseconds: 800));
    await tester.pump(const Duration(milliseconds: 800));

    // Settles the dialog pop and transitions without waiting for page-level repeating animations.
    await tester.pumpForVerification();

    // Verify dialog is closed and active topic changed
    expect(find.text('請描述您面臨的生活法學困境或糾紛：'), findsNothing);
    expect(find.textContaining('「租屋修繕責任」專屬法律課堂'), findsWidgets);

    // 台灣繁體中文教學註解：
    // 產生課堂後會顯示 CustomToast，它用 1.5 秒 Timer 自動移除。
    // 測試結束前主動推進時間並清空 widget tree，避免留下 pending timer。
    await tester.pump(const Duration(milliseconds: 1600));
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump();
  });
}

extension _VerificationPump on WidgetTester {
  Future<void> pumpForVerification([
    Duration duration = const Duration(milliseconds: 500),
  ]) async {
    // 台灣繁體中文教學註解：
    // 自訂課堂卡所在頁面有長駐動畫，測試改用固定時間推進，仍會讓 dialog 動畫與 Timer 回呼完成，
    // 但不會把「動畫持續存在」誤判成測試卡住。
    await pump();
    await pump(duration);
  }
}
