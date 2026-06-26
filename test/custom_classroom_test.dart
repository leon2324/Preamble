import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:lawapp/app/app_state.dart';
import 'package:lawapp/pages/learning/know_law_page.dart';

void main() {
  testWidgets('Custom classroom card renders and generates new topic', (WidgetTester tester) async {
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

    await tester.pumpAndSettle();

    // Scroll down to reveal more items in the ListView
    await tester.drag(find.byType(ListView), const Offset(0, -1500));
    await tester.pumpAndSettle();

    // Verify custom classroom card is rendered
    expect(find.text('訂製專屬法學課堂'), findsOneWidget);

    // Tap on the card to open dialog
    await tester.tap(find.text('訂製專屬法學課堂'));
    await tester.pumpAndSettle();

    // Verify dialog has opened
    expect(find.text('請描述您面臨的生活法學困境或糾紛：'), findsOneWidget);

    // Tap on one of the quick tags
    await tester.tap(find.text('#租屋修繕責任'));
    await tester.pumpAndSettle();

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
    
    // Settles the dialog pop and transitions
    await tester.pumpAndSettle();

    // Verify dialog is closed and active topic changed
    expect(find.text('請描述您面臨的生活法學困境或糾紛：'), findsNothing);
    expect(find.textContaining('「租屋修繕責任」專屬法律課堂'), findsWidgets);
  });
}
