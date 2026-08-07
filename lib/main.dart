import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:preamble/app/app_state.dart';
import 'package:preamble/app/native_startup_coordinator.dart';
import 'package:preamble/components/navigation/island_bottom_nav.dart';
import 'package:preamble/components/navigation/app_shell_content_insets.dart';
import 'package:preamble/pages/profile/profile_page.dart';
import 'package:preamble/pages/home/home_page.dart';
import 'package:preamble/pages/learning/know_law_page.dart';
import 'package:preamble/pages/learning/statute_database_page.dart';
import 'package:preamble/pages/search/global_search_page.dart';
import 'package:preamble/pages/journal/journal_page.dart';
import 'package:preamble/theme/adaptive_layout.dart';
import 'package:preamble/theme/app_theme.dart';
import 'package:preamble/features/case_library/data/case_library_repository.dart';
import 'package:preamble/platform/ios_quick_ask_intent_bridge.dart';
import 'package:preamble/platform/ios_statute_spotlight_bridge.dart';
import 'package:preamble/platform/ios_today_case_widget_bridge.dart';
import 'package:preamble/platform/ios_deep_link_bridge.dart';
import 'package:preamble/platform/ios_intent_router.dart';
import 'package:preamble/pages/profile/apple_ecosystem_demo_page.dart';
import 'package:preamble/features/case_library/pages/case_library_entry_page.dart';
import 'package:preamble/pages/home/subpages/home_life_legal_tips_page.dart';
import 'package:preamble/features/case_library/pages/case_legal_vocabulary_page.dart';

/// 應用程式進入點。
///
/// `ScreenUtilInit` 會先建立設計稿基準尺寸，後面的 widget 才能安全使用
/// `.w` / `.h` / `.sp` 做響應式換算。
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 初始化移至 WidgetTree 掛載後，避免阻塞啟動速度
  // iOS WidgetKit 同步也改由 _MylawAppState 的 addPostFrameCallback 觸發

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
  late final PreambleState _appState;
  late final ValueNotifier<String?> _quickAskPromptNotifier;
  late final NativeStartupCoordinator _nativeStartupCoordinator;
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
    _appState = PreambleState()..load();
    _quickAskPromptNotifier = ValueNotifier<String?>(null);
    _nativeStartupCoordinator = NativeStartupCoordinator();
    IosQuickAskIntentBridge.registerPromptHandler(_openQuickAskFromNative);
    IosStatuteSpotlightBridge.registerQueryHandler(
      _openStatuteDatabaseFromNative,
    );
    IosDeepLinkBridge.registerLinkHandler(_handleDeepLink);
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      // 延遲載入：第一幀渲染後再初始化資料庫與跨進程 Widget 同步
      unawaited(CaseLibraryRepository.instance.initialize());
      unawaited(IosTodayCaseWidgetBridge.syncDefaultStory());
      unawaited(IosStatuteSpotlightBridge.syncDefaultIndex());

      if (mounted) {
        IosIntentRouter.register(context);
        await IosIntentRouter.checkInitialIntents(context);
      }
      await _nativeStartupCoordinator.consumeAndHandleInitialEvents(
        consumeQuickAskPrompt: IosQuickAskIntentBridge.consumeInitialPrompt,
        consumeStatuteQuery: IosStatuteSpotlightBridge.consumeInitialQuery,
        consumeDeepLink: IosDeepLinkBridge.consumeInitialLink,
        handleQuickAskPrompt: _openQuickAskFromNative,
        handleStatuteQuery: _openStatuteDatabaseFromNative,
        handleDeepLink: _handleDeepLink,
        isMounted: () => mounted,
      );
    });
  }

  @override
  void dispose() {
    IosQuickAskIntentBridge.unregisterPromptHandler();
    IosStatuteSpotlightBridge.unregisterQueryHandler();
    IosDeepLinkBridge.unregisterLinkHandler();
    _nativeStartupCoordinator.dispose();
    _quickAskPromptNotifier.dispose();
    _appState.dispose();
    super.dispose();
  }

  void _openQuickAskFromNative(String prompt) {
    final trimmedPrompt = prompt.trim();
    if (trimmedPrompt.isEmpty) return;

    final assistantIndex = _appState.navbarOrder.indexOf(2);
    if (assistantIndex == -1) return;

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

    // Spotlight 點擊代表使用者已經在系統搜尋選定某個法條，因此直接 push 法規資料庫；
    // 不先切換底部 Tab，避免從 iOS 搜尋結果進 App 後還要再多點一次。
    navigator.push(
      MaterialPageRoute<void>(
        builder: (_) => StatuteDatabasePage(initialQuery: trimmedQuery),
      ),
    );
  }

  void _handleDeepLink(String urlString) {
    final uri = Uri.parse(urlString);
    if (uri.scheme != 'preamble') return;

    final navigator = _navigatorKey.currentState;
    if (navigator == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        _handleDeepLink(urlString);
      });
      return;
    }

    final host = uri.host;
    switch (host) {
      case 'todo-list':
        navigator.push(
          MaterialPageRoute<void>(
            builder: (_) => const AppleEcosystemDemoPage(),
          ),
        );
        break;
      case 'time-machine':
        navigator.push(
          MaterialPageRoute<void>(
            builder: (_) => const CaseLibraryEntryPage(),
          ),
        );
        break;
      case 'chat':
        final assistantIndex = _appState.navbarOrder.indexOf(2);
        if (assistantIndex != -1) {
          setState(() {
            _knowLawInitialTabIndex = null;
            _knowLawInitialToolTab = null;
            selectedIndex = assistantIndex;
          });
        }
        break;
      case 'tips':
        navigator.push(
          MaterialPageRoute<void>(
            builder: (_) => const LifeLegalTipsPage(),
          ),
        );
        break;
      case 'vocabulary':
        navigator.push(
          MaterialPageRoute<void>(
            builder: (_) => const CaseLegalVocabularyPage(),
          ),
        );
        break;
    }
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

    return PreambleScope(
      state: _appState,
      child: AnimatedBuilder(
        animation: _appState,
        builder: (context, _) {
          return MaterialApp(
            navigatorKey: _navigatorKey,
            locale: const Locale('zh', 'TW'),
            debugShowCheckedModeBanner: false,
            title: '緒言 Preamble',
            theme: AppTheme.light(),
            darkTheme: AppTheme.dark(),
            themeMode: _appState.themeMode,
            home: Scaffold(
              extendBody: true,
              resizeToAvoidBottomInset: false,
              body: Builder(
                builder: (context) {
                  final useTopSafeArea = !context.hasLargeTopInset;
                  // 全域底部 Nav 維持常駐，讓「我的 Preamble」仍能像其他主分頁一樣快速切換。
                  // 個別子頁若需要沉浸式流程，請在 push 新頁時另外處理，而不要從主殼層關掉 Nav。

                  return LayoutBuilder(
                    builder: (context, constraints) {
                      final navMetrics = IslandBottomNavLayoutMetrics.compute(
                        context,
                        // 導覽列左右各保留 12pt；Nav 與 shell 讀取同一份可用寬度，
                        // Dynamic Type 換行時才不會各自算出不同高度。
                        availableWidth: constraints.maxWidth - 24,
                        items: displayNavItems,
                        showLabels: _appState.showNavbarLabels,
                        bottomOffset: 17,
                      );

                      return Stack(
                        children: [
                          Positioned.fill(
                            child: SafeArea(
                              top: useTopSafeArea,
                              bottom: false,
                              child: AppShellContentInsets(
                                // 台灣繁體中文教學註解：只傳遞 Nav 大字級的額外
                                // 成長量；SafeArea 的 Home Indicator 與 17pt 外距
                                // 仍由 Nav 自己處理，不能在這裡重複加入。
                                additionalBottom:
                                    navMetrics.additionalBodyReservation,
                                child: IndexedStack(
                                  index: selectedIndex,
                                  children: displayPages,
                                ),
                              ),
                            ),
                          ),
                          // 全域狀態列霧面遮罩：防止滾動內容與上方時間、狀態列重疊
                          Positioned(
                            top: 0,
                            left: 0,
                            right: 0,
                            child: IgnorePointer(
                              child: Container(
                                height: MediaQuery.paddingOf(context).top + 10,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                    stops: const [0.0, 0.75, 1.0],
                                    colors: [
                                      Theme.of(context).scaffoldBackgroundColor,
                                      Theme.of(context)
                                          .scaffoldBackgroundColor
                                          .withValues(alpha: 0.88),
                                      Theme.of(context)
                                          .scaffoldBackgroundColor
                                          .withValues(alpha: 0.0),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Positioned(
                            left: 12,
                            right: 12,
                            bottom: 17,
                            child: SafeArea(
                              top: false,
                              child: IslandBottomNav(
                                selectedIndex: selectedIndex,
                                items: displayNavItems,
                                showLabels: _appState.showNavbarLabels,
                                layoutMetrics: navMetrics,
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
