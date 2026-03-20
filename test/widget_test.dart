import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lawapp/main.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    tester.view.devicePixelRatio = 3.0;
    tester.view.physicalSize = const Size(1179, 2556);
    addTearDown(() {
      tester.view.resetDevicePixelRatio();
      tester.view.resetPhysicalSize();
    });

    await tester.pumpWidget(
      ScreenUtilInit(
        designSize: const Size(375, 812),
        minTextAdapt: true,
        splitScreenMode: true,
        builder: (_, __) => const MylawApp(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('今日新聞'), findsOneWidget);
    expect(find.text('法律新知小報'), findsOneWidget);

    await tester.drag(find.byType(CustomScrollView), const Offset(0, -900));
    await tester.pumpAndSettle();

    expect(find.text('你關心的'), findsOneWidget);
    expect(find.text('給你的小任務(*¯︶¯*)'), findsOneWidget);
    expect(find.text('大家都在討論'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.person_outline_rounded));
    await tester.pumpAndSettle();

    expect(find.text('想搜尋的內容....'), findsOneWidget);
  });
}
