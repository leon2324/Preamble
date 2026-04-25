import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lawapp/data/moj/moj_feed_item.dart';
import 'package:lawapp/main.dart';
import 'package:lawapp/pages/home/home_subpages.dart';
import 'package:shared_preferences/shared_preferences.dart';

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

    expect(find.text('AI 法律輔助'), findsOneWidget);
    expect(find.text('法規資料庫'), findsOneWidget);

    await tester.drag(find.byType(CustomScrollView), const Offset(0, -900));
    await tester.pumpAndSettle();

    expect(find.text('給你的小任務(*¯︶¯*)'), findsOneWidget);
    expect(find.text('法律新知小報'), findsAtLeastNWidgets(1));
    expect(find.text('今日新聞'), findsAtLeastNWidgets(1));

    await tester.drag(find.byType(CustomScrollView), const Offset(0, -900));
    await tester.pumpAndSettle();

    expect(find.text('大家都在討論'), findsOneWidget);
    expect(find.text('專題'), findsOneWidget);

    // 台灣繁體中文教學註解：
    // 搜尋現在是底部 Nav 的中間分頁；這裡確認使用者不必回首頁也能進全站搜尋。
    await tester.tap(find.text('搜尋'));
    await tester.pumpAndSettle();

    expect(find.text('搜尋法條、案例、新聞、關鍵字...'), findsOneWidget);
    expect(find.text('熱門搜尋'), findsOneWidget);
  });

  testWidgets('Learning page shows redesigned sections', (
    WidgetTester tester,
  ) async {
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

    await tester.tap(find.byIcon(Icons.menu_book_outlined));
    await tester.pumpAndSettle();

    expect(find.text('專題'), findsOneWidget);

    await tester.drag(find.byType(ListView).first, const Offset(0, -900));
    await tester.pumpAndSettle();

    expect(find.text('法條資料庫'), findsOneWidget);
    expect(find.text('法律翻譯機'), findsOneWidget);
  });

  testWidgets('Home AI assistant card opens law assistant search page', (
    WidgetTester tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
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

    // 台灣繁體中文教學註解：
    // 這個測試鎖住首頁 AI 卡片的真導流行為，避免日後重構時只剩假輸入框。
    await tester.tap(find.text('AI 法律輔助'));
    await tester.pumpAndSettle();

    expect(find.text('問小法助'), findsOneWidget);
    expect(find.text('也可以先這樣問'), findsOneWidget);
  });

  testWidgets('Learning page opens mock detail page', (
    WidgetTester tester,
  ) async {
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

    await tester.tap(find.byIcon(Icons.menu_book_outlined));
    await tester.pumpAndSettle();

    await tester.tap(find.text('租屋糾紛怎麼看懂').first);
    await tester.pumpAndSettle();

    expect(find.text('這頁會帶你先抓住三個重點'), findsOneWidget);
  });

  testWidgets('Home mission opens quiz detail page', (
    WidgetTester tester,
  ) async {
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

    // 台灣繁體中文教學註解：
    // 用 scrollUntilVisible 取代固定距離拖曳，避免首頁內容高度微調後，
    // 「更多題目」剛好被滑到螢幕外而導致 tap 打不到。
    await tester.scrollUntilVisible(
      find.text('更多題目'),
      240,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('更多題目'));
    await tester.pumpAndSettle();

    expect(find.text('小任務測驗'), findsOneWidget);
    expect(find.textContaining('第 1 題 / 共'), findsOneWidget);
  });

  testWidgets('Home page stays stable on small screen with larger text scale', (
    WidgetTester tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    tester.view.devicePixelRatio = 2.0;
    tester.view.physicalSize = const Size(640, 1136);
    addTearDown(() {
      tester.view.resetDevicePixelRatio();
      tester.view.resetPhysicalSize();
    });

    await tester.pumpWidget(
      MediaQuery(
        data: const MediaQueryData(
          size: Size(320, 568),
          textScaler: TextScaler.linear(1.25),
        ),
        child: ScreenUtilInit(
          designSize: const Size(375, 812),
          minTextAdapt: true,
          splitScreenMode: true,
          builder: (_, __) => const MylawApp(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('AI 法律輔助'), findsOneWidget);
    expect(find.text('文件產生'), findsOneWidget);
    expect(find.text('會員權限'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Home subpages stay stable on compact larger text layout', (
    WidgetTester tester,
  ) async {
    tester.view.devicePixelRatio = 2.0;
    tester.view.physicalSize = const Size(640, 1136);
    addTearDown(() {
      tester.view.resetDevicePixelRatio();
      tester.view.resetPhysicalSize();
    });

    Widget testFrame(Widget child) {
      return MediaQuery(
        data: const MediaQueryData(
          size: Size(320, 568),
          textScaler: TextScaler.linear(1.22),
        ),
        child: ScreenUtilInit(
          designSize: const Size(375, 812),
          minTextAdapt: true,
          splitScreenMode: true,
          builder: (_, __) => MaterialApp(home: child),
        ),
      );
    }

    // 台灣繁體中文教學註解：
    // 首頁子頁的 Hero 會在小螢幕或大字級時改為上下排列，避免 icon 壓縮標題。
    await tester.pumpWidget(testFrame(const CommonLegalIssuesPage()));
    await tester.pumpAndSettle();
    expect(find.text('常見法律問題'), findsOneWidget);
    expect(tester.takeException(), isNull);

    await tester.pumpWidget(testFrame(const HomeLearningTopicsPage()));
    await tester.pumpAndSettle();
    expect(find.text('法律學習專題'), findsOneWidget);
    expect(tester.takeException(), isNull);

    await tester.pumpWidget(
      testFrame(
        const OfficialFeedDetailPage(
          item: MojFeedItem(
            title: '法務部發布重要政策說明',
            url: 'https://www.moj.gov.tw/2204/2795/2796/987654/',
            category: MojFeedCategory.news,
            index: 1,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('開啟官方頁面'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
