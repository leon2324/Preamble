import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lawapp/app/app_state.dart';
import 'package:lawapp/pages/following/following_page.dart';
import 'package:lawapp/pages/home/home_page.dart';
import 'package:lawapp/pages/learning/know_law_page.dart';
import 'package:lawapp/pages/search/global_search_page.dart';
import 'package:lawapp/pages/journal/journal_page.dart';
import 'package:lawapp/theme/adaptive_layout.dart';
import 'package:lawapp/theme/app_colors.dart';
import 'package:lawapp/features/case_time_machine/data/case_time_machine_repository.dart';

/// 應用程式進入點。
///
/// `ScreenUtilInit` 會先建立設計稿基準尺寸，後面的 widget 才能安全使用
/// `.w` / `.h` / `.sp` 做響應式換算。
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 初始化本地 SQLite 資料庫與記憶體快取倉庫
  await CaseTimeMachineRepository.instance.initialize();

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
  late final LawAppState _appState;
  int selectedIndex = 0;

  static const List<_BottomNavItemData> _navItems = [
    _BottomNavItemData(
      label: '首頁',
      icon: Icons.home_outlined,
      selectedIcon: Icons.home_rounded,
    ),
    _BottomNavItemData(
      label: '學習',
      icon: Icons.menu_book_outlined,
      selectedIcon: Icons.menu_book_rounded,
    ),
    _BottomNavItemData(
      label: '小法助',
      icon: Icons.support_agent_outlined,
      selectedIcon: Icons.support_agent_rounded,
    ),
    _BottomNavItemData(
      label: '記事',
      icon: Icons.inventory_2_outlined,
      selectedIcon: Icons.inventory_2_rounded,
    ),
    _BottomNavItemData(
      label: '我的',
      icon: Icons.person_outline_rounded,
      selectedIcon: Icons.person_rounded,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _appState = LawAppState()..load();
  }

  @override
  void dispose() {
    _appState.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // 這裡集中管理主分頁，未來若改成路由系統或深層連結，
    // 可以先從這個列表與 selectedIndex 的關係下手重構。
    final pages = [
      // 台灣繁體中文教學註解：
      // 新版首頁已正式收編成 pages/home/home_page.dart；
      // 舊版首頁則搬到 pages/home/legacy 供日後設計回顧。
      HomePage(
        onNavigateToTab: (index) {
          setState(() {
            selectedIndex = index;
          });
        },
      ),
      const KnowLawPage(),
      // 台灣繁體中文教學註解：
      // 全站搜尋與 AI 小法助已完美整合為同一頁 (GlobalSearchPage)，
      // 結合了吉祥物插圖、語音搜尋、額度管理，以及強大的 AI overview 智慧卡片。
      const GlobalSearchPage(),
      const JournalPage(),
      // 台灣繁體中文教學註解：
      // 台灣繁體中文教學註解：
      // 第五格現在整合「追蹤」與「我的」成個人法律中心，
      // 所以頁面檔名仍沿用 FollowingPage，但 UI 入口命名改為「我的」。
      const FollowingPage(),
    ];

    return LawAppScope(
      state: _appState,
      child: AnimatedBuilder(
        animation: _appState,
        builder: (context, _) {
          return MaterialApp(
            locale: const Locale('zh', 'TW'),
            debugShowCheckedModeBanner: false,
            title: 'LawApp',
            theme: _buildLightTheme(),
            darkTheme: _buildDarkTheme(),
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
                            children: pages,
                          ),
                        ),
                      ),
                      Positioned(
                        left: 12,
                        right: 12,
                        bottom: 17,
                        child: SafeArea(
                          top: false,
                          child: _IslandBottomNav(
                            selectedIndex: selectedIndex,
                            items: _navItems,
                            onTap: (index) {
                              setState(() {
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

  ThemeData _buildLightTheme() {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: AppColors.background,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primary,
        primary: AppColors.primary,
        surface: AppColors.background,
      ),
      textTheme: Typography.blackMountainView.apply(
        bodyColor: AppColors.textPrimary,
        displayColor: AppColors.textPrimary,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.background,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
      ),
    );
  }

  ThemeData _buildDarkTheme() {
    // 台灣繁體中文教學註解：
    // 深色主題先處理全域背景、文字與 Material 元件基礎色；
    // 部分既有首頁插畫卡片仍保留品牌色，避免一鍵深色後失去首頁識別。
    const darkBackground = Color(0xFF0F1216);
    const darkSurface = Color(0xFF171C22);
    const darkText = Color(0xFFF2F4F7);

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: darkBackground,
      colorScheme: ColorScheme.fromSeed(
        brightness: Brightness.dark,
        seedColor: const Color(0xFF9FB0C6),
        primary: const Color(0xFF9FB0C6),
        surface: darkSurface,
      ),
      textTheme: Typography.whiteMountainView.apply(
        bodyColor: darkText,
        displayColor: darkText,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: darkBackground,
        foregroundColor: darkText,
        elevation: 0,
      ),
    );
  }
}

class _IslandBottomNav extends StatelessWidget {
  const _IslandBottomNav({
    required this.selectedIndex,
    required this.items,
    required this.onTap,
  });

  final int selectedIndex;
  final List<_BottomNavItemData> items;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final shellColor = isDark
        ? const Color(0xFF1A2028)
        : const Color.fromARGB(255, 239, 239, 239);
    final selectedColor =
        isDark ? const Color(0xFFF2F4F7) : AppColors.textPrimary;
    final unselectedColor = selectedColor.withValues(alpha: 0.42);
    // 文字縮放時一起拉高底部島的高度，避免 icon 與文字互相擠壓。
    final extraHeight = context.adaptiveBuffer(12);
    final navShellHeight = 76 + extraHeight;
    final navHeight = 70 + extraHeight;
    final iconBoxHeight = 30 + (extraHeight * 0.6);

    return SizedBox(
      height: navShellHeight,
      child: Center(
        child: Container(
          height: navHeight,
          decoration: BoxDecoration(
            color: shellColor,
            borderRadius: BorderRadius.circular(34),
            boxShadow: const [
              BoxShadow(
                color: Color(0x20000000),
                blurRadius: 18,
                spreadRadius: 1,
                offset: Offset(0, 8),
              ),
              BoxShadow(
                color: Color(0x50000000),
                blurRadius: 30,
                spreadRadius: 2,
                offset: Offset(0, 12),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(34),
            child: Row(
              children: List.generate(items.length, (index) {
                final item = items[index];
                final isSelected = index == selectedIndex;

                return Expanded(
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () => onTap(index),
                      splashFactory: NoSplash.splashFactory,
                      splashColor: Colors.transparent,
                      highlightColor: Colors.transparent,
                      hoverColor: Colors.transparent,
                      focusColor: Colors.transparent,
                      child: Padding(
                        padding: const EdgeInsets.only(top: 6, bottom: 4),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              width: 50,
                              height: iconBoxHeight,
                              alignment: Alignment.center,
                              child: Icon(
                                isSelected ? item.selectedIcon : item.icon,
                                size: 25,
                                color: isSelected
                                    ? selectedColor
                                    : unselectedColor,
                              ),
                            ),
                            const SizedBox(height: 5),
                            Text(
                              item.label,
                              style: TextStyle(
                                fontSize: 11 + context.adaptiveBuffer(1.5),
                                fontWeight: FontWeight.w400,
                                color: selectedColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),
        ),
      ),
    );
  }
}

class _BottomNavItemData {
  const _BottomNavItemData({
    required this.label,
    required this.icon,
    required this.selectedIcon,
  });

  final String label;
  final IconData icon;
  final IconData selectedIcon;
}
