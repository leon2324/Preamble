import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lawapp/app/app_state.dart';
import 'package:lawapp/data/common/app_loading_quotes.dart';
import 'package:lawapp/data/mock_data/cases/case_story_mock_data.dart';
import 'package:lawapp/data/mock_data/home/home_mock_data.dart';
import 'package:lawapp/data/moj/moj_feed_item.dart';
import 'package:lawapp/data/search/search_repository.dart';
import 'package:lawapp/data/statutes/statute_api_service.dart';
import 'package:lawapp/data/statutes/statute_item.dart';
import 'package:lawapp/data/statutes/statute_repository.dart';
import 'package:lawapp/features/case_time_machine/data/case_time_machine_mock_data.dart';
import 'package:lawapp/features/case_time_machine/pages/case_dossier_detail_page.dart';
import 'package:lawapp/features/case_time_machine/pages/case_time_machine_entry_page.dart';
import 'package:lawapp/main.dart';
import 'package:lawapp/pages/home/home_subpages.dart';
import 'package:lawapp/pages/following/following_page.dart';
import 'package:lawapp/pages/journal/legacy/case_story_detail_page.dart';
import 'package:lawapp/pages/journal/legacy/journal_archive_page.dart';
import 'package:lawapp/pages/journal/widgets/archive_activity_section.dart';
import 'package:lawapp/pages/journal/widgets/case_time_machine_card.dart';
import 'package:lawapp/pages/journal/widgets/discussing_now_section.dart';
import 'package:lawapp/pages/journal/widgets/journal_page_header.dart';
import 'package:lawapp/pages/journal/widgets/journal_palette.dart';
import 'package:lawapp/pages/journal/widgets/on_this_day_card.dart';
import 'package:lawapp/pages/learning/statute_database_page.dart';
import 'package:lawapp/pages/journal/journal_page.dart';
import 'package:lawapp/pages/profile/profile_page.dart';
import 'package:lawapp/pages/search/global_search_page.dart';
import 'package:lawapp/pages/tools/legal_tools_page.dart';
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
    expect(find.text('生活避坑筆記'), findsAtLeastNWidgets(1));
    expect(find.text('今日新聞'), findsAtLeastNWidgets(1));

    await tester.drag(find.byType(CustomScrollView), const Offset(0, -900));
    await tester.pumpAndSettle();

    expect(find.text('大家都在討論'), findsOneWidget);
    expect(find.text('專題'), findsOneWidget);

    // 台灣繁體中文教學註解：
    // 搜尋現在是底部 Nav 的中間分頁；這裡確認使用者不必回首頁也能進全站搜尋。
    await tester.tap(find.text('搜尋'));
    await tester.pumpAndSettle();

    expect(find.text('搜尋法條、案件、生活筆記、官方資料'), findsOneWidget);
    expect(find.text('熱門搜尋'), findsOneWidget);

    // 台灣繁體中文教學註解：
    // 原本底部 Nav 的「案例」已改為「記事」，這裡同時守住 label 與入口內容。
    await tester.tap(find.text('記事'));
    await tester.pumpAndSettle();

    expect(find.text('大家都在討論'), findsOneWidget);
    expect(find.text('案件圖書館'), findsOneWidget);
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

    expect(find.text('學堂與工具箱'), findsOneWidget);
    expect(find.text('法學課堂'), findsOneWidget);
    expect(find.text('公民法律小擂台'), findsOneWidget);
    expect(find.text('精選專題'), findsOneWidget);
    expect(find.text('租屋糾紛'), findsOneWidget);
    expect(find.text('全部專題'), findsOneWidget);

    // 台灣繁體中文教學註解：
    // 新版學習頁把工具內容收進「生活工具箱」分頁，測試需點分頁，而不是沿用舊版向下滑找工具卡。
    await tester.tap(find.text('生活工具箱'));
    await tester.pumpAndSettle();

    expect(find.text('法律術語白話翻譯機'), findsOneWidget);
    expect(find.text('證據準備與文件清單'), findsOneWidget);

    await tester.scrollUntilVisible(
      find.text('常用法規快速查詢'),
      120,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();

    expect(find.text('常用法規快速查詢'), findsOneWidget);
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

    // 台灣繁體中文教學註解：
    // 小法助入口已改成 prototype 的首頁狀態，右上角時鐘會進入第 7 張對話紀錄頁。
    expect(find.text('小法助'), findsOneWidget);
    expect(find.text('熱門提問'), findsOneWidget);
    expect(find.byIcon(Icons.history_rounded), findsOneWidget);

    await tester.tap(find.byIcon(Icons.history_rounded));
    await tester.pumpAndSettle();

    expect(find.text('對話記錄'), findsOneWidget);
    expect(find.text('搜尋對話紀錄'), findsOneWidget);
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

    final firstUnit = find.text('STEP 1：押金的法律角色是什麼？');
    // 台灣繁體中文教學註解：
    // 主題標題只負責展示進度；真正會開啟詳情頁的是下方 STEP 單元列。
    await tester.scrollUntilVisible(
      firstUnit,
      120,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();

    await tester.tap(firstUnit);
    await tester.pumpAndSettle();

    expect(find.text('單元 1：押金的法律角色是什麼？'), findsOneWidget);
    expect(find.textContaining('三個核心法律思考點'), findsOneWidget);
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
    // 首頁 SectionHeader 的「更多」已改為 iOS 箭頭圖示，測試改走語意標籤，
    // 讓畫面維持精簡但自動化仍能確認導頁功能。
    final moreMissionButton = find.bySemanticsLabel('更多題目');
    await tester.scrollUntilVisible(
      moreMissionButton,
      240,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();

    await tester.tap(moreMissionButton);
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

    await tester.pumpWidget(testFrame(const LifeLegalTipsPage()));
    await tester.pumpAndSettle();
    expect(find.text('生活避坑筆記'), findsOneWidget);
    expect(find.text('最近筆記'), findsOneWidget);
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

  testWidgets('Side reference screens match compact app layout', (
    WidgetTester tester,
  ) async {
    tester.view.devicePixelRatio = 2.0;
    tester.view.physicalSize = const Size(640, 1136);
    final appState = LawAppState();
    addTearDown(() {
      tester.view.resetDevicePixelRatio();
      tester.view.resetPhysicalSize();
      appState.dispose();
    });

    Widget testFrame(Widget child) {
      return MediaQuery(
        data: const MediaQueryData(
          size: Size(320, 568),
          textScaler: TextScaler.linear(1.18),
        ),
        child: ScreenUtilInit(
          designSize: const Size(375, 812),
          minTextAdapt: true,
          splitScreenMode: true,
          builder: (_, __) => LawAppScope(
            state: appState,
            child: MaterialApp(home: child),
          ),
        ),
      );
    }

    // 台灣繁體中文教學註解：
    // 左右兩張參考圖對應法規資料庫與案件解析，這裡鎖住初始入口與詳細頁不爆版。
    await tester.pumpWidget(testFrame(const StatuteDatabasePage()));
    await tester.pumpAndSettle();
    expect(find.text('熱門查詢'), findsOneWidget);
    expect(find.text('最近瀏覽'), findsOneWidget);
    expect(tester.takeException(), isNull);

    await tester.pumpWidget(testFrame(const JournalPage()));
    await tester.pumpAndSettle();
    expect(find.byType(JournalPageHeader), findsOneWidget);
    expect(find.text('大家都在討論'), findsOneWidget);
    await tester.scrollUntilVisible(
      find.text('案件圖書館'),
      180,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();
    expect(find.text('案件圖書館'), findsOneWidget);
    await tester.scrollUntilVisible(
      find.text('圖書館動態'),
      180,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();
    expect(find.text('圖書館動態'), findsOneWidget);
    expect(tester.takeException(), isNull);

    await tester.pumpWidget(
      testFrame(CaseStoryDetailPage(item: caseStoryItems.last)),
    );
    await tester.pumpAndSettle();
    expect(find.text('案件解析'), findsOneWidget);
    expect(find.text('一句話結論'), findsOneWidget);
    expect(find.text('案件時光機'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Journal page does not overflow on compact larger text layout', (
    WidgetTester tester,
  ) async {
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
          textScaler: TextScaler.linear(1.18),
        ),
        child: ScreenUtilInit(
          designSize: const Size(375, 812),
          minTextAdapt: true,
          splitScreenMode: true,
          builder: (_, __) => const MaterialApp(home: JournalPage()),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // 台灣繁體中文教學註解：
    // 記事頁有大量橫向密集文字與插畫，這裡用 iPhone SE 尺寸加大字級逐段滾動，
    // 讓 RenderFlex overflow 會在測試中直接被 tester.takeException() 抓出來。
    expect(find.byType(JournalPageHeader), findsOneWidget);
    expect(tester.takeException(), isNull);

    await tester.scrollUntilVisible(
      find.text('大家都在討論'),
      180,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);

    await tester.scrollUntilVisible(
      find.text('案件圖書館'),
      180,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);

    await tester.scrollUntilVisible(
      find.text('圖書館動態'),
      180,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });

  testWidgets('Journal page uses repository results for initial query', (
    WidgetTester tester,
  ) async {
    _setMvpPhoneSize(tester);

    await tester.pumpWidget(
      ScreenUtilInit(
        designSize: const Size(375, 812),
        minTextAdapt: true,
        splitScreenMode: true,
        builder: (_, __) => const MaterialApp(
          home: JournalPage(initialQuery: '詐騙'),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('「詐騙」的前端資料結果'), findsOneWidget);
    expect(find.text('詐騙車手與洗錢鏈'), findsWidgets);
  });

  testWidgets('Journal archive filters dossiers and opens detail page', (
    WidgetTester tester,
  ) async {
    tester.view.devicePixelRatio = 2.0;
    tester.view.physicalSize = const Size(750, 1624);
    addTearDown(() {
      tester.view.resetDevicePixelRatio();
      tester.view.resetPhysicalSize();
    });

    Widget testFrame(Widget child) {
      return ScreenUtilInit(
        designSize: const Size(375, 812),
        minTextAdapt: true,
        splitScreenMode: true,
        builder: (_, __) => MaterialApp(home: child),
      );
    }

    await tester.pumpWidget(
      testFrame(
        const JournalArchivePage(
          entryLabel: '那年今日',
          focusTitle: '鄭南榕事件',
        ),
      ),
    );
    await tester.pumpAndSettle();

    // 台灣繁體中文教學註解：
    // 資料館不能只停在策展卡；這裡鎖住焦點入口、年代篩選與詳情頁三段真流程。
    expect(find.text('入口焦點'), findsOneWidget);
    expect(find.text('1980s 目前有 1 份示範卷宗。'), findsOneWidget);

    await tester.scrollUntilVisible(
      find.text('2010s'),
      180,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('2010s'));
    await tester.pumpAndSettle();
    expect(find.text('2010s 目前有 1 份示範卷宗。'), findsOneWidget);

    final sunflowerDossier = find.text('太陽花運動相關案件');
    await tester.scrollUntilVisible(
      sunflowerDossier,
      180,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();
    await tester.tap(sunflowerDossier);
    await tester.pumpAndSettle();

    expect(find.text('卷宗導讀'), findsWidgets);
    expect(find.text('案件時間軸'), findsWidgets);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Journal sections stay stable individually on compact layout', (
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
          textScaler: TextScaler.linear(1.18),
        ),
        child: ScreenUtilInit(
          designSize: const Size(375, 812),
          minTextAdapt: true,
          splitScreenMode: true,
          builder: (context, _) {
            final palette = JournalPalette.of(context);
            return MaterialApp(
              home: Scaffold(
                backgroundColor: palette.background,
                body: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: child,
                ),
              ),
            );
          },
        ),
      );
    }

    await tester.pumpWidget(
      testFrame(Builder(
        builder: (context) => JournalPageHeader(
          palette: JournalPalette.of(context),
        ),
      )),
    );
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);

    await tester.pumpWidget(
      testFrame(Builder(
        builder: (context) => DiscussingNowSection(
          palette: JournalPalette.of(context),
        ),
      )),
    );
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);

    await tester.pumpWidget(
      testFrame(Builder(
        builder: (context) => CaseTimeMachineCard(
          palette: JournalPalette.of(context),
        ),
      )),
    );
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);

    await tester.pumpWidget(
      testFrame(Builder(
        builder: (context) => OnThisDayCard(
          palette: JournalPalette.of(context),
        ),
      )),
    );
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);

    await tester.pumpWidget(
      testFrame(Builder(
        builder: (context) => ArchiveActivitySection(
          palette: JournalPalette.of(context),
        ),
      )),
    );
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });

  testWidgets('Legal tools prototype switches steps and shows preview', (
    WidgetTester tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    _setMvpPhoneSize(tester);
    final appState = LawAppState();
    addTearDown(appState.dispose);
    await appState.load();
    await appState.signInDemo();

    await tester.pumpWidget(_mvpTestFrame(appState, const LegalToolsPage()));
    await tester.pumpAndSettle();

    // 台灣繁體中文教學註解：
    // 法律工具箱改成 prototype 的單頁多子狀態流程，測試要從首頁入口一路走到預覽，
    // 才能同時守住主頁、Step 1、Step 2 與 Step 3 的切換。
    expect(find.text('法律文件工具箱'), findsOneWidget);
    expect(find.text('3-step 輕鬆產生法律文件'), findsOneWidget);

    await tester.scrollUntilVisible(
      find.text('開始產生草稿'),
      160,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pump(const Duration(milliseconds: 120));
    await tester.tap(find.text('開始產生草稿'));
    await tester.pumpAndSettle();
    expect(find.text('你想產生哪一種文件？'), findsOneWidget);

    await tester.tap(find.text('下一步'));
    await tester.pumpAndSettle();
    expect(find.text('請補充相關資料'), findsOneWidget);

    await tester.scrollUntilVisible(
      find.widgetWithText(FilledButton, '下一步'),
      160,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pump(const Duration(milliseconds: 120));
    await tester.tap(find.widgetWithText(FilledButton, '下一步'));
    await tester.pumpAndSettle();
    expect(find.text('你的文件草稿已完成！'), findsOneWidget);
    expect(find.text('協商語氣'), findsOneWidget);
  });

  testWidgets('My LawApp prototype opens tracking center and detail', (
    WidgetTester tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    _setMvpPhoneSize(tester);
    final appState = LawAppState();
    addTearDown(appState.dispose);
    await appState.load();
    await appState.signInDemo();

    await tester.pumpWidget(_mvpTestFrame(appState, const FollowingPage()));
    await tester.pumpAndSettle();

    // 台灣繁體中文教學註解：
    // 「追蹤」與「我的」已整合成個人中心，測試從首頁進追蹤中心，再打開案件詳情。
    expect(find.text('我的 LawApp'), findsOneWidget);
    expect(find.text('今天的重點動態'), findsOneWidget);
    expect(find.text('我的追蹤總覽'), findsOneWidget);
    expect(find.textContaining('詐欺與洗錢'), findsWidgets);

    await tester.tap(find.text('12').first);
    await tester.pumpAndSettle();

    expect(find.text('追蹤案件'), findsOneWidget);
    expect(find.text('追蹤的案件 4 個'), findsOneWidget);

    await tester.tap(find.text('詐欺與洗錢案件整理'));
    await tester.pumpAndSettle();

    expect(find.text('最新更新'), findsOneWidget);
    expect(find.text('追蹤設定'), findsOneWidget);
  });

  testWidgets('Profile page shows data center sections', (
    WidgetTester tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    _setMvpPhoneSize(tester);
    final appState = LawAppState();
    addTearDown(appState.dispose);
    await appState.load();

    await tester.pumpWidget(_mvpTestFrame(appState, const ProfilePage()));
    await tester.pumpAndSettle();

    expect(find.text('我的收藏'), findsOneWidget);
    expect(find.text('我的筆記'), findsOneWidget);
    expect(find.text('我的文件草稿'), findsOneWidget);
    await tester.scrollUntilVisible(
      find.text('即將支援'),
      180,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('即將支援'), findsOneWidget);
  });

  testWidgets('Global search shows mixed result sections after query', (
    WidgetTester tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    _setMvpPhoneSize(tester);
    final appState = LawAppState();
    addTearDown(appState.dispose);
    await appState.load();

    final searchRepository = SearchRepository(
      statuteRepository: StatuteRepository(
        apiService: _WidgetFakeStatuteApiService([
          const StatuteItem(
            codeName: '刑法',
            articleNumber: '第 339 條',
            articleText: '意圖為自己或第三人不法之所有，以詐術使人將本人或第三人之物交付者。',
            lawUrl: 'https://law.moj.gov.tw/',
            category: '法律',
            updatedDate: '2025-12-31',
            isRepealed: false,
            tags: ['詐欺', '刑事'],
            plainLanguageSummary: '詐欺罪會看是否以詐術讓對方陷於錯誤並交付財物。',
          ),
        ]),
      ),
    );
    addTearDown(searchRepository.dispose);

    await tester.pumpWidget(
      _mvpTestFrame(
        appState,
        GlobalSearchPage(searchRepository: searchRepository),
      ),
    );
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField).first, '詐欺');
    await tester.testTextInput.receiveAction(TextInputAction.search);
    await tester.pumpAndSettle();

    expect(find.text('法規'), findsWidgets);
    expect(find.text('刑法 第 339 條'), findsOneWidget);
    expect(find.text('進階查詢路徑'), findsOneWidget);

    // 台灣繁體中文教學註解：
    // 搜尋結果頁的頂部分類要能真的切換資料，不只是視覺上的 tab。
    await tester.tap(find.text('案件').first);
    await tester.pumpAndSettle();

    expect(find.textContaining('詐欺案'), findsAtLeastNWidgets(1));

    // 台灣繁體中文教學註解：
    // 結果頁沒有大標題列時，仍要保留回主搜尋頁的路徑，避免使用者卡在子頁。
    await tester.tap(find.byIcon(Icons.arrow_back_ios_new_rounded).first);
    await tester.pumpAndSettle();

    expect(find.text('全站搜尋'), findsOneWidget);
    expect(find.text('最近搜尋'), findsOneWidget);
  });

  testWidgets('Statute database searches through repository results', (
    WidgetTester tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    _setMvpPhoneSize(tester);
    final appState = LawAppState();
    addTearDown(appState.dispose);
    await appState.load();
    final repository = StatuteRepository(
      apiService: _WidgetFakeStatuteApiService([
        const StatuteItem(
          codeName: '民法',
          articleNumber: '第 184 條',
          articleText: '因故意或過失，不法侵害他人之權利者，負損害賠償責任。',
          lawUrl: 'https://law.moj.gov.tw/',
          category: '法律',
          updatedDate: '2025-12-31',
          isRepealed: false,
          tags: ['侵權行為'],
        ),
        const StatuteItem(
          codeName: '勞動基準法',
          articleNumber: '第 24 條',
          articleText: '雇主延長勞工工作時間者，其延長工作時間之工資依本條標準加給。',
          lawUrl: 'https://law.moj.gov.tw/',
          category: '法律',
          updatedDate: '2025-12-31',
          isRepealed: false,
          tags: ['加班費', '工時'],
        ),
      ]),
    );
    addTearDown(repository.dispose);

    await tester.pumpWidget(
      _mvpTestFrame(
        appState,
        StatuteDatabasePage(
          initialQuery: '加班',
          repository: repository,
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('勞動基準法 第 24 條'), findsOneWidget);
    expect(find.text('民法 第 184 條'), findsNothing);

    await tester.enterText(find.byType(TextField).first, '民法 184');
    await tester.testTextInput.receiveAction(TextInputAction.search);
    await tester.pumpAndSettle();

    expect(find.text('民法 第 184 條'), findsOneWidget);
    expect(find.text('勞動基準法 第 24 條'), findsNothing);
  });

  testWidgets('Statute detail shows life example and assistant CTA', (
    WidgetTester tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    _setMvpPhoneSize(tester);
    final appState = LawAppState();
    addTearDown(appState.dispose);
    await appState.load();

    await tester.pumpWidget(
      _mvpTestFrame(
        appState,
        const StatuteDetailPage(
          item: StatuteItem(
            codeName: '民法',
            articleNumber: '第 184 條',
            articleText: '因故意或過失，不法侵害他人之權利者，負損害賠償責任。',
            lawUrl: 'https://law.moj.gov.tw/',
            category: '法律',
            updatedDate: '2026-05-05',
            isRepealed: false,
            tags: ['損害賠償', '車禍'],
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('生活例子'), findsOneWidget);
    expect(find.text('可能相關情境'), findsOneWidget);
    expect(find.text('用這條法規問小法助'), findsOneWidget);
  });

  testWidgets('Case time machine walks through halls shelves book and dossier',
      (
    WidgetTester tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    _setMvpPhoneSize(tester);
    final appState = LawAppState();
    addTearDown(appState.dispose);
    await appState.load();

    await tester.pumpWidget(
      _mvpTestFrame(appState, const CaseTimeMachineEntryPage()),
    );
    await tester.pumpAndSettle();

    // 台灣繁體中文教學註解：
    // 案件時光機的核心不是列表，而是「館 → 書架 → 書 → 卷宗」；
    // 這個測試守住完整沉浸式路徑，避免未來重構退回普通卡片清單。
    expect(find.text('案件圖書館'), findsOneWidget);
    await tester.tap(find.text('查看全部').first);
    await tester.pumpAndSettle();

    await tester.tap(find.text('年代館'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('查看案件').first);
    await tester.pumpAndSettle();

    // 台灣繁體中文教學註解：
    // 在一體化滾動的直向版面上，我們需要向上滑動以露出「案件背景」與「關鍵時間軸」等內容。
    for (int i = 0; i < 3; i++) {
      await tester.drag(find.byType(ListView).first, const Offset(0, -250));
      await tester.pumpAndSettle();
    }

    expect(find.text('案件背景'), findsWidgets);

    // 台灣繁體中文教學註解：
    // 所有卷宗內容皆在同一個 ListView 中，我們直接向上滾動以尋找「關鍵時間軸」區塊。
    await tester.scrollUntilVisible(
      find.text('關鍵時間軸').last,
      260,
      scrollable: find.byType(Scrollable).last,
    );
    await tester.pumpAndSettle();
    expect(find.text('關鍵時間軸'), findsWidgets);

    // 台灣繁體中文教學註解：
    // 繼續向下滾動以檢索「延伸書架 / 相關案件」區塊。
    await tester.scrollUntilVisible(
      find.text('延伸書架 / 相關案件'),
      260,
      scrollable: find.byType(Scrollable).last,
    );
    await tester.pumpAndSettle();
    expect(find.text('延伸書架 / 相關案件'), findsOneWidget);
  });

  testWidgets('Case time machine shelf supports landscape two column layout', (
    WidgetTester tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    tester.view.devicePixelRatio = 3.0;
    tester.view.physicalSize = const Size(2556, 1179);
    addTearDown(() {
      tester.view.resetDevicePixelRatio();
      tester.view.resetPhysicalSize();
    });
    final appState = LawAppState();
    addTearDown(appState.dispose);
    await appState.load();
    final hall = caseTimeMachineHalls.first;
    final shelf = hall.shelves.first;

    await tester.pumpWidget(
      _mvpTestFrame(
          appState, CaseDossierDetailPage(book: caseTimeMachineCases.first)),
    );
    await tester.pumpAndSettle();

    // 台灣繁體中文教學註解：
    // 橫向模式要變成雙欄佈局（包含卷宗導讀、案件基本資料等版面）。
    // 台灣繁體中文教學註解：
    // 橫向模式下，TabBarView 的高度受限，基本資料卡片預設在畫面下方尚未被 Lazy-load 建立。
    // 我們需要先向上滑動外層的 SingleChildScrollView 將 TabBarView 帶上來，
    // 再向上滑動內層的 ListView 露出「案件基本資料」。
    // 在 2x3 六宮格與大圖的雙吸頂新版面上，橫向模式高度受限，需要多次向上滑動外層滾動區以露出詳細 Tab 內容。
    for (int i = 0; i < 5; i++) {
      await tester.dragFrom(const Offset(200, 250), const Offset(0, -250));
      await tester.pumpAndSettle();
    }
    expect(find.text('案件基本資料'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  test('legacy profile and trend drafts are not formal entry pages', () {
    final aboutLegacy = File(
      'lib/pages/profile/legacy/about_me_page_legacy.dart',
    ).readAsStringSync();
    final trendLegacy = File(
      'lib/pages/trending/legacy/trend_page_legacy.dart',
    ).readAsStringSync();

    expect(aboutLegacy, contains('AboutMePageLegacy'));
    expect(trendLegacy, contains('TrendPageLegacy'));
    expect(File('lib/pages/profile/about_me_page.dart').existsSync(), isFalse);
    expect(File('lib/pages/trending/trend_page.dart').existsSync(), isFalse);
  });

  test('Life trap notes and loading quotes have enough content', () {
    // 台灣繁體中文教學註解：
    // 這個測試守住首頁與子頁的內容量，避免未來整理 mock data 時不小心刪太多。
    expect(homeNewsletterItems.length, greaterThanOrEqualTo(500));
    expect(appLoadingQuotes.length, 200);
  });
}

Widget _mvpTestFrame(LawAppState appState, Widget child) {
  return ScreenUtilInit(
    designSize: const Size(375, 812),
    minTextAdapt: true,
    splitScreenMode: true,
    builder: (_, __) => LawAppScope(
      state: appState,
      child: MaterialApp(home: child),
    ),
  );
}

class _WidgetFakeStatuteApiService extends StatuteApiService {
  _WidgetFakeStatuteApiService(this.items);

  final List<StatuteItem> items;

  @override
  Future<List<StatuteItem>> fetchChineseLawItems() async => items;

  @override
  void dispose() {}
}

void _setMvpPhoneSize(WidgetTester tester) {
  // 台灣繁體中文教學註解：
  // MVP 頁面大量使用手機版卡片與底部 CTA，測試時固定成常見手機尺寸，
  // 才能避免預設 800x600 桌面視窗誤判「按鈕在畫面外」。
  tester.view.devicePixelRatio = 3.0;
  tester.view.physicalSize = const Size(1179, 2556);
  addTearDown(() {
    tester.view.resetDevicePixelRatio();
    tester.view.resetPhysicalSize();
  });
}
