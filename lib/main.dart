import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lawapp/app/app_state.dart';
import 'package:lawapp/components/navigation/island_bottom_nav.dart';
import 'package:lawapp/pages/profile/profile_page.dart';
import 'package:lawapp/pages/home/home_page.dart';
import 'package:lawapp/pages/learning/know_law_page.dart';
import 'package:lawapp/pages/learning/statute_database_page.dart';
import 'package:lawapp/pages/search/global_search_page.dart';
import 'package:lawapp/pages/journal/journal_page.dart';
import 'package:lawapp/theme/adaptive_layout.dart';
import 'package:lawapp/theme/app_theme.dart';
import 'package:lawapp/features/case_time_machine/data/case_time_machine_repository.dart';
import 'package:lawapp/platform/ios_quick_ask_intent_bridge.dart';
import 'package:lawapp/platform/ios_statute_spotlight_bridge.dart';
import 'package:lawapp/platform/ios_today_case_widget_bridge.dart';

/// 應用程式進入點。
///
/// `ScreenUtilInit` 會先建立設計稿基準尺寸，後面的 widget 才能安全使用
/// `.w` / `.h` / `.sp` 做響應式換算。
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 初始化本地 SQLite 資料庫與記憶體快取倉庫
  await CaseTimeMachineRepository.instance.initialize();
  // 台灣繁體中文教學註解：
  // iOS WidgetKit 讀不到 Flutter widget tree，因此 App 啟動時先把今日判決故事同步到 App Group；
  // Android、測試環境或原生橋接尚未完成時會安全略過，不影響主流程。
  await IosTodayCaseWidgetBridge.syncDefaultStory();
  // 台灣繁體中文教學註解：
  // Core Spotlight 索引是系統層加分入口，不需要阻塞第一屏；先背景同步精選法條，
  // 使用者之後在 iPhone 搜尋「民法184」「租屋押金」就能回到法規資料庫。
  unawaited(IosStatuteSpotlightBridge.syncDefaultIndex());

  runApp(
    ScreenUtilInit(
      designSize: const Size(375, 812),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return const MylawApp();
      },
    ),
  );
}

/// 整個 App 的殼層，負責主題、分頁切換與底部導覽。
class MylawApp extends StatefulWidget {
  const MylawApp({super.key});

  @override
  State<MylawApp> createState() => _MylawAppState();
}

class _MylawAppState extends State<MylawApp> {
  late final GlobalKey<NavigatorState> _navigatorKey;
  late final LawAppState _appState;
  late final ValueNotifier<String?> _quickAskPromptNotifier;
  int selectedIndex = 0;
  int? _knowLawInitialTabIndex;
  String? _knowLawInitialToolTab;

  static const List<BottomNavItemData> _navItems = [
    BottomNavItemData(
      label: '首頁',
      icon: Icons.home_outlined,
      selectedIcon: Icons.home_rounded,
    ),
    BottomNavItemData(
      label: '學習',
      icon: Icons.menu_book_outlined,
      selectedIcon: Icons.menu_book_rounded,
    ),
    BottomNavItemData(
      label: '小法助',
      icon: Icons.support_agent_outlined,
      selectedIcon: Icons.support_agent_rounded,
    ),
    BottomNavItemData(
      label: '紀事',
      icon: Icons.inventory_2_outlined,
      selectedIcon: Icons.inventory_2_rounded,
    ),
    BottomNavItemData(
      label: '我的',
      icon: Icons.person_outline_rounded,
      selectedIcon: Icons.person_rounded,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _navigatorKey = GlobalKey<NavigatorState>();
    _appState = LawAppState()..load();
    _quickAskPromptNotifier = ValueNotifier<String?>(null);
    IosQuickAskIntentBridge.registerPromptHandler(_openQuickAskFromNative);
    IosStatuteSpotlightBridge.registerQueryHandler(
      _openStatuteDatabaseFromNative,
    );
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final prompt = await IosQuickAskIntentBridge.consumeInitialPrompt();
      if (!mounted) return;
      if (prompt != null) {
        _openQuickAskFromNative(prompt);
      }

      final statuteQuery =
          await IosStatuteSpotlightBridge.consumeInitialQuery();
      if (!mounted || statuteQuery == null) return;
      _openStatuteDatabaseFromNative(statuteQuery);
    });
  }

  @override
  void dispose() {
    IosQuickAskIntentBridge.unregisterPromptHandler();
    IosStatuteSpotlightBridge.unregisterQueryHandler();
    _quickAskPromptNotifier.dispose();
    _appState.dispose();
    super.dispose();
  }

  void _openQuickAskFromNative(String prompt) {
    final trimmedPrompt = prompt.trim();
    if (trimmedPrompt.isEmpty) return;

    final assistantIndex = _appState.navbarOrder.indexOf(2);
    if (assistantIndex == -1) return;

    // 台灣繁體中文教學註解：
    // Siri / Shortcuts / Widget 進來時，只由主殼層負責切換底部分頁；
    // 實際的小法助 prompt 處理仍交給 GlobalSearchPage，避免原生入口繞過既有搜尋狀態機。
    setState(() {
      _knowLawInitialTabIndex = null;
      _knowLawInitialToolTab = null;
      selectedIndex = assistantIndex;
    });
    _quickAskPromptNotifier.value = null;
    _quickAskPromptNotifier.value = trimmedPrompt;
  }

  void _openStatuteDatabaseFromNative(String query) {
    final trimmedQuery = query.trim();
    if (trimmedQuery.isEmpty) return;

    final navigator = _navigatorKey.currentState;
    if (navigator == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        _openStatuteDatabaseFromNative(trimmedQuery);
      });
      return;
    }

    // 台灣繁體中文教學註解：
    // Spotlight 點擊代表使用者已經在系統搜尋選定某個法條，因此直接 push 法規資料庫；
    // 不先切換底部 Tab，避免從 iOS 搜尋結果進 App 後還要再多點一次。
    navigator.push(
      MaterialPageRoute<void>(
        builder: (_) => StatuteDatabasePage(initialQuery: trimmedQuery),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final order = _appState.navbarOrder;

    final originalNavItems = [
      const BottomNavItemData(
        label: '首頁',
        icon: Icons.home_outlined,
        selectedIcon: Icons.home_rounded,
      ),
      const BottomNavItemData(
        label: '學習',
        icon: Icons.menu_book_outlined,
        selectedIcon: Icons.menu_book_rounded,
      ),
      const BottomNavItemData(
        label: '小法助',
        icon: Icons.support_agent_outlined,
        selectedIcon: Icons.support_agent_rounded,
      ),
      const BottomNavItemData(
        label: '紀事',
        icon: Icons.inventory_2_outlined,
        selectedIcon: Icons.inventory_2_rounded,
      ),
      const BottomNavItemData(
        label: '我的',
        icon: Icons.person_outline_rounded,
        selectedIcon: Icons.person_rounded,
      ),
    ];

    final originalPages = [
      HomePage(
        onNavigateToTab: (targetOriginalIndex, {subTabIndex, toolTab}) {
          // 台灣繁體中文教學註解：
          // 當首頁按鈕點選跳頁時，在自訂順序列表（navbarOrder）中尋找原本的目標頁排在第幾個，並更新 selectedIndex。
          final realIndex = order.indexOf(targetOriginalIndex);
          if (realIndex != -1) {
            setState(() {
              _knowLawInitialTabIndex = subTabIndex;
              _knowLawInitialToolTab = toolTab;
              selectedIndex = realIndex;
            });
          }
        },
      ),
      KnowLawPage(
        initialTabIndex: _knowLawInitialTabIndex,
        initialToolTab: _knowLawInitialToolTab,
      ),
      GlobalSearchPage(quickAskPromptListenable: _quickAskPromptNotifier),
      const JournalPage(),
      const ProfilePage(showBackButton: false),
    ];

    final displayNavItems = order.map((idx) => originalNavItems[idx]).toList();
    final displayPages = order.map((idx) => originalPages[idx]).toList();

    return LawAppScope(
      state: _appState,
      child: AnimatedBuilder(
        animation: _appState,
        builder: (context, _) {
          return MaterialApp(
            navigatorKey: _navigatorKey,
            locale: const Locale('zh', 'TW'),
            debugShowCheckedModeBanner: false,
            title: 'LawApp',
            theme: AppTheme.light(),
            darkTheme: AppTheme.dark(),
            themeMode: _appState.themeMode,
            home: Scaffold(
              extendBody: false,
              resizeToAvoidBottomInset: false,
              body: Builder(
                builder: (context) {
                  final useTopSafeArea = !context.hasLargeTopInset;
                  // 台灣繁體中文教學註解：
                  // 全域底部 Nav 維持常駐，讓「我的 LawApp」仍能像其他主分頁一樣快速切換。
                  // 個別子頁若需要沉浸式流程，請在 push 新頁時另外處理，而不要從主殼層關掉 Nav。

                  return Stack(
                    children: [
                      Positioned.fill(
                        child: SafeArea(
                          top: useTopSafeArea,
                          bottom: false,
                          child: IndexedStack(
                            index: selectedIndex,
                            children: displayPages,
                          ),
                        ),
                      ),
                      Positioned(
                        left: 12,
                        right: 12,
                        bottom: 17,
                        child: SafeArea(
                          top: false,
                          bottom: false,
                          child: IslandBottomNav(
                            selectedIndex: selectedIndex,
                            items: displayNavItems,
                            showLabels: _appState.showNavbarLabels,
                            onTap: (index) {
                              setState(() {
                                _knowLawInitialTabIndex = null;
                                _knowLawInitialToolTab = null;
                                selectedIndex = index;
                              });
                            },
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          );
        },
      ),
    );
  }
}
