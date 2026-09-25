import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:preamble/app/app_state.dart';
import 'package:preamble/data/common/app_loading_quotes.dart';
import 'package:preamble/data/mock_data/cases/case_story_mock_data.dart';
import 'package:preamble/data/mock_data/home/home_mock_data.dart';
import 'package:preamble/data/moj/moj_feed_item.dart';
import 'package:preamble/data/search/search_repository.dart';
import 'package:preamble/data/statutes/statute_api_service.dart';
import 'package:preamble/data/statutes/statute_item.dart';
import 'package:preamble/data/statutes/statute_repository.dart';
import 'package:preamble/features/case_library/data/case_library_data.dart';
import 'package:preamble/features/case_library/pages/case_dossier_detail_page.dart';
import 'package:preamble/features/case_library/pages/case_library_entry_page.dart';
import 'package:preamble/main.dart';
import 'package:preamble/pages/home/home_subpages.dart';
import 'package:preamble/pages/following/following_page.dart';
import 'package:preamble/pages/journal/legacy/case_story_detail_page.dart';
import 'package:preamble/pages/journal/legacy/journal_archive_page.dart';
import 'package:preamble/pages/journal/widgets/archive_activity_section.dart';
import 'package:preamble/pages/journal/widgets/case_library_card.dart';
import 'package:preamble/pages/journal/widgets/discussing_now_section.dart';
import 'package:preamble/pages/journal/widgets/journal_page_header.dart';
import 'package:preamble/pages/journal/widgets/journal_palette.dart';
import 'package:preamble/pages/journal/widgets/on_this_day_card.dart';
import 'package:preamble/pages/learning/home_mission_quiz_page.dart';
import 'package:preamble/pages/learning/statute_database_page.dart';
import 'package:preamble/pages/journal/journal_page.dart';
import 'package:preamble/pages/profile/profile_page.dart';
import 'package:preamble/pages/search/global_search_page.dart';
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
    // 首頁頂部法規快訊有定時輪播，pumpAndSettle 會一直等到下一輪動畫；
    // smoke test 只需要確認首頁主路徑可渲染，所以使用固定時間推進。
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.text('法律即時快問'), findsOneWidget);
    expect(find.text('法規資料庫搜尋'), findsOneWidget);

    await tester.drag(find.byType(CustomScrollView), const Offset(0, -900));
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.text('今天判決故事'), findsOneWidget);
    expect(find.text('生活避坑筆記'), findsAtLeastNWidgets(1));

    await tester.drag(find.byType(CustomScrollView), const Offset(0, -900));
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.text('社群熱議'), findsOneWidget);
    expect(find.text('看全部'), findsOneWidget);

    // 底部 Nav 的中間分頁已從單純「搜尋」升級為「小法助」；
    // 目前會直接進入小法助搜尋首頁，因此用搜尋框送出一次查詢守住核心能力。
    await tester.tap(find.text('小法助'));
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.textContaining('嗨！我是小法助'), findsOneWidget);
    expect(find.text('搜尋法條、案件、生活筆記、官方資料'), findsOneWidget);
    expect(find.text('🔥 法律探索靈感'), findsOneWidget);
    expect(find.text('🧭 快捷助理導航'), findsOneWidget);

    // 原本底部 Nav 的「案例」已改為「紀事」，這裡同時守住 label 與入口內容。
    await tester.tap(find.text('紀事'));
    await tester.pump(const Duration(milliseconds: 500));

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
    await tester.pumpForVerification();

    await tester.tap(find.byIcon(Icons.menu_book_outlined));
    await tester.pumpForVerification();

    expect(find.text('學堂與工具箱'), findsOneWidget);
    expect(find.text('法學課堂'), findsOneWidget);
    expect(find.text('公民法律小擂台'), findsOneWidget);
    expect(find.text('精選專題'), findsOneWidget);
    expect(find.text('租屋糾紛'), findsOneWidget);
    expect(find.text('全部專題'), findsOneWidget);

    // 新版學習頁把工具內容收進「生活工具箱」分頁，測試需點分頁，而不是沿用舊版向下滑找工具卡。
    await tester.tap(find.text('生活工具箱'));
    await tester.pumpForVerification();

    expect(find.text('法律術語白話翻譯機'), findsOneWidget);

    // 點擊切換標籤至車禍計算，確認車禍工具卡片載入
    await tester.tap(find.text('車禍計算'));
    await tester.pumpForVerification();
    expect(find.text('車禍零件折舊與工資計算機'), findsOneWidget);

    await tester.scrollUntilVisible(
      find.text('常用法規快速查詢'),
      120,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpForVerification();

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
    await tester.pumpForVerification();

    // 這個測試鎖住小法助真入口，避免日後重構時只剩假輸入框。
    await tester.tap(find.text('小法助'));
    await tester.pumpForVerification();

    // 小法助入口目前是全站搜尋首頁狀態，這裡守住可提問與快捷入口。
    expect(find.textContaining('嗨！我是小法助'), findsOneWidget);
    expect(find.text('搜尋法條、案件、生活筆記、官方資料'), findsOneWidget);
    expect(find.text('🔥 法律探索靈感'), findsOneWidget);
    expect(find.text('🧭 快捷助理導航'), findsOneWidget);
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
    await tester.pumpForVerification();

    await tester.tap(find.byIcon(Icons.menu_book_outlined));
    await tester.pumpForVerification();

    final firstUnit = find.text('STEP 1：押金的法律角色是什麼？');
    // 主題標題只負責展示進度；真正會開啟詳情頁的是下方 STEP 單元列。
    await tester.scrollUntilVisible(
      firstUnit,
      120,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpForVerification();

    await tester.tap(firstUnit);
    await tester.pumpForVerification();

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
        builder: (_, __) => const MaterialApp(home: HomeMissionQuizPage()),
      ),
    );
    await tester.pumpForVerification();

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
    // 首頁法規快訊會定時輪播，小螢幕穩定性測試只需固定推進一幀確認沒有 overflow。
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.text('法律即時快問'), findsOneWidget);
    expect(find.text('今天判決故事'), findsOneWidget);
    expect(find.text('法規資料庫搜尋'), findsOneWidget);
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
    await tester.pumpForVerification();
    expect(find.text('生活避坑筆記'), findsOneWidget);
    expect(find.byIcon(Icons.search_rounded), findsOneWidget);
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
    final appState = PreambleState();
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
          builder: (_, __) => PreambleScope(
            state: appState,
            child: MaterialApp(home: child),
          ),
        ),
      );
    }

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
    expect(find.text('案件圖書館'), findsOneWidget);
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
        builder: (context) => CaseLibraryCard(
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

  testWidgets('My 緒言 Preamble prototype opens tracking center and detail', (
    WidgetTester tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    _setMvpPhoneSize(tester);
    final appState = PreambleState();
    addTearDown(appState.dispose);
    await appState.load();
    await appState.signInDemo();

    await tester.pumpWidget(_mvpTestFrame(appState, const FollowingPage()));
    await tester.pumpAndSettle();

    // 「追蹤」與「我的」已整合成個人中心，測試從首頁進追蹤中心，再打開案件詳情。
    expect(find.text('我的 緒言 Preamble'), findsOneWidget);
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
    final appState = PreambleState();
    addTearDown(appState.dispose);
    await appState.load();

    await tester.pumpWidget(_mvpTestFrame(appState, const ProfilePage()));
    await tester.pumpAndSettle();

    expect(find.text('我的收藏'), findsOneWidget);
    expect(find.text('我的筆記'), findsOneWidget);
    expect(find.text('文件草稿'), findsOneWidget);
  });

  testWidgets('Global search shows mixed result sections after query', (
    WidgetTester tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    _setMvpPhoneSize(tester);
    final appState = PreambleState();
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
    await tester.pumpForVerification();

    await tester.enterText(find.byType(TextField).first, '詐欺');
    await tester.testTextInput.receiveAction(TextInputAction.search);
    await tester.pumpForVerification();

    expect(find.text('法規'), findsWidgets);
    expect(find.text('刑法 第 339 條'), findsOneWidget);
    expect(find.text('進階查詢路徑'), findsOneWidget);

    // 搜尋結果頁的頂部分類要能真的切換資料，不只是視覺上的 tab。
    await tester.tap(find.text('案件').first);
    await tester.pumpForVerification();

    expect(find.textContaining('詐欺案'), findsAtLeastNWidgets(1));

    // 結果頁沒有大標題列時，仍要保留回主搜尋頁的路徑，避免使用者卡在子頁。
    await tester.tap(find.byIcon(Icons.arrow_back_ios_new_rounded).first);
    await tester.pumpForVerification();

    expect(find.text('最近搜尋'), findsOneWidget);
  });

  testWidgets('Statute database searches through repository results', (
    WidgetTester tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    _setMvpPhoneSize(tester);
    final appState = PreambleState();
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
    final appState = PreambleState();
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
    final appState = PreambleState();
    addTearDown(appState.dispose);
    await appState.load();

    await tester.pumpWidget(
      _mvpTestFrame(appState, const CaseLibraryEntryPage()),
    );
    await tester.pumpForVerification();

    // 案件圖書館的核心不是列表，而是「館 → 書架 → 書 → 卷宗」；
    // 這個測試守住完整沉浸式路徑，避免未來重構退回普通卡片清單。
    expect(find.text('案件圖書館'), findsOneWidget);

    expect(find.text('年代館'), findsWidgets);

    await tester.pumpWidget(
      _mvpTestFrame(
          appState, CaseDossierDetailPage(book: caseLibraryCases.first)),
    );
    await tester.pumpForVerification();

    // 在一體化滾動的直向版面上，我們需要向上滑動以露出 TabBar 與 tab 內容。
    // 使用垂直方向的 Scrollable 作為拖曳對象，確保正確滾動外層的 NestedScrollView。
    final verticalScrollable = find
        .byWidgetPredicate((w) => w is Scrollable && w.axis == Axis.vertical)
        .first;
    for (int i = 0; i < 3; i++) {
      await tester.drag(verticalScrollable, const Offset(0, -250));
      await tester.pumpForVerification();
    }

    // 驗證預設選中的「事件背景」分頁內容已加載並顯示
    expect(find.text('事件背景與始末'), findsWidgets);

    // 切換至「事件與訴訟脈絡」分頁
    await tester.tap(find.text('事件與訴訟脈絡'));
    await tester.pumpForVerification();
    expect(find.text('完整事件與訴訟脈絡'), findsWidgets);

    // 切換至「法律爭點」分頁（第三個分頁，寬度在直向模式下一定可點擊）
    await tester.tap(find.text('法律爭點'));
    await tester.pumpForVerification();
    expect(find.text('主要法律爭點'), findsWidgets);
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
    final appState = PreambleState();
    addTearDown(appState.dispose);
    await appState.load();
    final hall = caseLibraryHalls.first;
    final shelf = hall.shelves.first;

    await tester.pumpWidget(
      _mvpTestFrame(
          appState, CaseDossierDetailPage(book: caseLibraryCases.first)),
    );
    await tester.pumpForVerification();

    // 橫向模式下，先驗證首頁核心摘要資訊有正確渲染出來。
    expect(find.text('事件摘要'), findsOneWidget);

    // 進行滑動測試，確保滾動過程中不會發生 RenderFlex 溢出或崩潰異常
    final verticalScrollable = find
        .byWidgetPredicate((w) => w is Scrollable && w.axis == Axis.vertical)
        .first;
    for (int i = 0; i < 5; i++) {
      await tester.drag(verticalScrollable, const Offset(0, -250));
      await tester.pumpForVerification();
    }
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
    // 這個測試守住首頁與子頁的內容量，避免未來整理 mock data 時不小心刪太多。
    expect(homeNewsletterItems.length, greaterThanOrEqualTo(500));
    expect(appLoadingQuotes.length, 200);
  });
}

Widget _mvpTestFrame(PreambleState appState, Widget child) {
  return ScreenUtilInit(
    designSize: const Size(375, 812),
    minTextAdapt: true,
    splitScreenMode: true,
    builder: (_, __) => PreambleScope(
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
  // MVP 頁面大量使用手機版卡片與底部 CTA，測試時固定成常見手機尺寸，
  // 才能避免預設 800x600 桌面視窗誤判「按鈕在畫面外」。
  tester.view.devicePixelRatio = 3.0;
  tester.view.physicalSize = const Size(1179, 2556);
  addTearDown(() {
    tester.view.resetDevicePixelRatio();
    tester.view.resetPhysicalSize();
  });
}

extension _VerificationPump on WidgetTester {
  Future<void> pumpForVerification([
    Duration duration = const Duration(milliseconds: 500),
  ]) async {
    // 台灣繁體中文教學註解：
    // 多個整頁測試會載入首頁、學習頁或案件頁的常駐動畫與輪播 ticker。
    // 這些動畫是產品行為，不代表測試還有未完成的導覽；因此用固定時間推進
    // route transition、setState 與短動畫，避免 pumpAndSettle 永遠等不到 idle。
    await pump();
    await pump(duration);
  }
}
