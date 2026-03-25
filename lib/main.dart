import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lawapp/pages/followed_updates/followed_updates_page.dart';
import 'package:lawapp/pages/home/home_page.dart';
import 'package:lawapp/pages/learning/know_law_page.dart';
import 'package:lawapp/pages/profile/about_me_page.dart';
import 'package:lawapp/pages/trending/trending_page.dart';
import 'package:lawapp/theme/adaptive_layout.dart';
import 'package:lawapp/theme/app_colors.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
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

class MylawApp extends StatefulWidget {
  const MylawApp({super.key});

  @override
  State<MylawApp> createState() => _MylawAppState();
}

class _MylawAppState extends State<MylawApp> {
  int selectedIndex = 0;

  void _handleLearningQuizTap() {}

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
      label: '追蹤',
      icon: Icons.bookmark_border_rounded,
      selectedIcon: Icons.bookmark_rounded,
    ),
    _BottomNavItemData(
      label: '熱門',
      icon: Icons.local_fire_department_outlined,
      selectedIcon: Icons.local_fire_department_rounded,
    ),
    _BottomNavItemData(
      label: '我的',
      icon: Icons.person_outline_rounded,
      selectedIcon: Icons.person_rounded,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final pages = [
      HomePage(
        onNavigateToTab: (index) {
          setState(() {
            selectedIndex = index;
          });
        },
      ),
      const KnowLawPage(),
      const FollowedUpdatesPage(),
      const TrendingPage(),
      const AboutMePage(),
    ];

    return MaterialApp(
      locale: const Locale('zh', 'TW'),
      debugShowCheckedModeBanner: false,
      title: 'MylawApp',
      theme: ThemeData(
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
      ),
      home: Scaffold(
        extendBody: false,
        body: Builder(
          builder: (context) {
            final useTopSafeArea = !context.hasLargeTopInset;

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
                if (selectedIndex == 1)
                  Positioned(
                    right: 24,
                    bottom: 110,
                    child: SafeArea(
                      top: false,
                      child: SizedBox(
                        height: 70,
                        width: 70,
                        child: FloatingActionButton(
                          backgroundColor: const Color.fromARGB(
                            255,
                            248,
                            204,
                            111,
                          ),
                          onPressed: _handleLearningQuizTap,
                          shape: const CircleBorder(),
                          child: const Icon(
                            Icons.quiz_outlined,
                            color: Color(0xFF101828),
                            size: 32,
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
            color: const Color.fromARGB(255, 239, 239, 239),
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
                                    ? AppColors.textPrimary
                                    : AppColors.textPrimary
                                        .withValues(alpha: 0.42),
                              ),
                            ),
                            const SizedBox(height: 5),
                            Text(
                              item.label,
                              style: TextStyle(
                                fontSize: 11 + context.adaptiveBuffer(1.5),
                                fontWeight: FontWeight.w400,
                                color: AppColors.textPrimary,
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
