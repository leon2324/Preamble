import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lawapp/components/home/home_content.dart';
import 'package:lawapp/components/shared/custom_toast.dart';
import 'package:lawapp/data/mock_data/home/home_mock_data.dart';
import 'package:lawapp/pages/home/subpages/home_subpage_primitives.dart';
import 'package:lawapp/pages/learning/know_law_page.dart';
import 'package:lawapp/pages/learning/statute_database_page.dart';
import 'package:lawapp/theme/app_colors.dart';
import 'package:lawapp/features/case_time_machine/widgets/case_time_machine_svg_icon.dart';

const String _svgPets = '''
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.2" stroke-linecap="round" stroke-linejoin="round">
  <circle cx="12" cy="5" r="2"></circle>
  <circle cx="7" cy="7" r="2"></circle>
  <circle cx="17" cy="7" r="2"></circle>
  <path d="M12 21c-2.8 0-5-2.2-5-5 0-1.7 1-3.2 2.5-4 .8-.4 1.7-.6 2.5-.6s1.7.2 2.5.6c1.5.8 2.5 2.3 2.5 4 0 2.8-2.2 5-5 5Z"></path>
</svg>
''';

const String _svgShareNetwork = '''
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.2" stroke-linecap="round" stroke-linejoin="round">
  <circle cx="18" cy="5" r="3"></circle>
  <circle cx="6" cy="12" r="3"></circle>
  <circle cx="18" cy="19" r="3"></circle>
  <line x1="8.59" y1="13.51" x2="15.42" y2="17.49"></line>
  <line x1="15.41" y1="6.51" x2="8.59" y2="10.49"></line>
</svg>
''';

const String _svgDownload = '''
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.2" stroke-linecap="round" stroke-linejoin="round">
  <path d="M21 15v4a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2v-4"></path>
  <polyline points="7 10 12 15 17 10"></polyline>
  <line x1="12" y1="15" x2="12" y2="3"></line>
</svg>
''';

String _svgPathForCategory(String category) {
  if (category.contains('狗') || category.contains('寵物')) return _svgPets;
  if (category.contains('租')) return CtmSvgIcons.home;
  if (category.contains('拍照') || category.contains('隱私')) {
    return CtmSvgIcons.smartphone;
  }
  if (category.contains('網購')) return CtmSvgIcons.shoppingBag;
  if (category.contains('交通')) return CtmSvgIcons.car;
  return CtmSvgIcons.idea;
}

// 台灣繁體中文教學註解：
// UI/UX 多彩平面編輯風（Flat Colorful Editorial）設計系統。
// 結合極限扁平外觀與鮮豔局部彩帶，在主頁及列表卡片左側加上「類別彩虹邊條」，
// 點亮分類滑動軌道背景色，並將詳細頁底端查法規按鈕升級為雙色漸層，大幅提升色彩多樣性。
class ProtoColors {
  static const Color sageGreen = Color(0xFFAFC3B4);
  static const Color blueGray = Color(0xFFA9B4C4);
  static const Color warmBeige = Color(0xFFF2EDE6);
  static const Color softTaupe = Color(0xFFD7CEC2);
  static const Color clay = Color(0xFFC48A7A);
  static const Color charcoal = AppColors.textPrimary;
  static const Color lightBg = AppColors.background;
  static const Color border = AppColors.border;
}

class EditorialBadge {
  final String label;
  final Color textColor;
  final Color bgColor;
  const EditorialBadge(this.label, this.textColor, this.bgColor);
}

EditorialBadge _getEditorialBadge(String title) {
  if (title.contains('租屋') || title.contains('購') || title.contains('退貨')) {
    return const EditorialBadge('編輯精選', ProtoColors.clay, Color(0xFFFFF0EC));
  }
  if (title.contains('狗') ||
      title.contains('拍') ||
      title.contains('隱私') ||
      title.contains('自拍')) {
    return const EditorialBadge('官方整理', Color(0xFF2C5E43), Color(0xFFEEF7F2));
  }
  return const EditorialBadge('開發者推薦', Color(0xFF1976D2), Color(0xFFEEF3F8));
}

class CategoryAesthetics {
  final Color primary;
  final List<Color> gradient;
  final IconData icon;

  const CategoryAesthetics({
    required this.primary,
    required this.gradient,
    required this.icon,
  });
}

CategoryAesthetics aestheticsForCategory(String category, bool isDark) {
  return switch (category) {
    '養狗' => const CategoryAesthetics(
        primary: Color(0xFF2C5E43),
        gradient: [Color(0xFF2C5E43), ProtoColors.sageGreen],
        icon: Icons.pets_rounded,
      ),
    '租屋' => const CategoryAesthetics(
        primary: ProtoColors.clay,
        gradient: [ProtoColors.clay, Color(0xFFE2B265)],
        icon: Icons.home_work_outlined,
      ),
    '拍照隱私' => const CategoryAesthetics(
        primary: Color(0xFF4C2A75),
        gradient: [Color(0xFF4C2A75), ProtoColors.blueGray],
        icon: Icons.photo_camera_outlined,
      ),
    '網購' => const CategoryAesthetics(
        primary: Color(0xFF752434),
        gradient: [Color(0xFF752434), ProtoColors.clay],
        icon: Icons.shopping_bag_outlined,
      ),
    '交通' => const CategoryAesthetics(
        primary: Color(0xFF754318),
        gradient: [Color(0xFF754318), Color(0xFFD7CEC2)],
        icon: Icons.traffic_rounded,
      ),
    _ => const CategoryAesthetics(
        primary: ProtoColors.charcoal,
        gradient: [ProtoColors.charcoal, Color(0xFF888888)],
        icon: Icons.lightbulb_outline_rounded,
      ),
  };
}

/// 生活避坑筆記列表頁
class LifeLegalTipsPage extends StatefulWidget {
  const LifeLegalTipsPage({super.key});

  @override
  State<LifeLegalTipsPage> createState() => _LifeLegalTipsPageState();
}

class _LifeLegalTipsPageState extends State<LifeLegalTipsPage> {
  static const _categories = ['全部', '養狗', '租屋', '拍照隱私', '網購', '交通'];

  late final PageController _featuredController;
  late final TextEditingController _searchController;
  Timer? _featuredTimer;
  var _selectedCategory = '全部';
  var _featuredIndex = 0;
  var _query = '';
  double _pageOffset = 0.0;

  @override
  void initState() {
    super.initState();
    _featuredController = PageController(viewportFraction: 0.85);
    _searchController = TextEditingController();

    _featuredController.addListener(() {
      if (_featuredController.hasClients) {
        setState(() {
          _pageOffset = _featuredController.page ?? 0.0;
        });
      }
    });

    _searchController.addListener(() {
      setState(() {
        _query = _searchController.text.trim();
      });
    });

    _featuredTimer = Timer.periodic(const Duration(seconds: 5), (__) {
      if (!_featuredController.hasClients) return;
      final next = (_featuredIndex + 1) % 5;
      _featuredController.animateToPage(
        next,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOutCubic,
      );
    });
  }

  @override
  void dispose() {
    _featuredTimer?.cancel();
    _featuredController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.paddingOf(context).top;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final featuredItems = homeNewsletterItems.take(5).toList(growable: false);
    final filteredItems = homeNewsletterItems.where((item) {
      final matchesCategory =
          _selectedCategory == '全部' || item.category == _selectedCategory;
      final matchesQuery = _query.isEmpty ||
          item.title.contains(_query) ||
          item.summary.contains(_query) ||
          item.tip.contains(_query) ||
          item.category.contains(_query);
      return matchesCategory && matchesQuery;
    }).toList(growable: false);

    final activeColor =
        aestheticsForCategory(_selectedCategory, isDark).primary;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0F1216) : ProtoColors.lightBg,
      body: Stack(
        children: [
          ListView(
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            physics: const BouncingScrollPhysics(),
            padding: EdgeInsets.fromLTRB(16.w, topPadding + 146.h, 16.w, 40.h),
            children: [
              _LifeTipCategoryRail(
                labels: _categories,
                selectedLabel: _selectedCategory,
                onSelected: (label) {
                  setState(() => _selectedCategory = label);
                },
              ),
              SizedBox(height: 10.h),
              _buildSorterRow(isDark),
              SizedBox(height: 20.h),
              _SubpageInlineHeader(
                  title: '今日焦點精選', count: featuredItems.length),
              SizedBox(height: 12.h),
              // 3D 視差縮放輪播
              SizedBox(
                height: 164.h,
                child: PageView.builder(
                  controller: _featuredController,
                  physics: const BouncingScrollPhysics(),
                  itemCount: featuredItems.length,
                  onPageChanged: (index) {
                    setState(() => _featuredIndex = index);
                  },
                  itemBuilder: (context, index) {
                    final item = featuredItems[index];
                    return AnimatedBuilder(
                      animation: _featuredController,
                      builder: (context, child) {
                        double value = 0.0;
                        if (_featuredController.position.haveDimensions) {
                          value = index - _pageOffset;
                        } else {
                          value = (index - _featuredIndex).toDouble();
                        }

                        final double scale =
                            (1.0 - (value.abs() * 0.06)).clamp(0.92, 1.0);
                        final double opacity =
                            (1.0 - (value.abs() * 0.35)).clamp(0.6, 1.0);

                        return Transform.scale(
                          scale: scale,
                          child: Opacity(
                            opacity: opacity,
                            child: Padding(
                              padding: EdgeInsets.symmetric(horizontal: 4.w),
                              child: _LifeTipFeaturedCard(
                                item: item,
                                onTap: () => _openTip(context, item),
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
              SizedBox(height: 12.h),
              _LifeTipPageDots(
                count: featuredItems.length,
                activeIndex: _featuredIndex,
                pageOffset: _pageOffset,
                accentColor: activeColor,
              ),
              SizedBox(height: 24.h),
              _SubpageInlineHeader(
                title: _selectedCategory == '全部' ? '全部避坑筆記' : _selectedCategory,
                count: filteredItems.length,
              ),
              SizedBox(height: 12.h),
              if (filteredItems.isEmpty)
                const SubpageStatusCard(message: '目前沒有符合條件的避坑筆記，換個關鍵字試試看。')
              else
                ...filteredItems.map(
                  (item) => Padding(
                    padding: EdgeInsets.only(bottom: 12.h),
                    child: _LifeTipListCard(
                      item: item,
                      onTap: () => _openTip(context, item),
                    ),
                  ),
                ),
              SizedBox(height: 12.h),
              const SubpageStatusCard(
                message: '生活避坑筆記僅提供一般法律常識與風險預防參考，非正式律師意見。若遇具體糾紛，請尋求專業法律服務。',
              ),
            ],
          ),
          _LifeTrapTopFrostMask(topPadding: topPadding),
          Positioned(
            top: topPadding + 8.h,
            left: 16.w,
            right: 16.w,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _LifeTrapAppBar(onBack: () => Navigator.of(context).pop()),
                SizedBox(height: 14.h),
                _LifeTrapSearchBar(controller: _searchController),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSorterRow(bool isDark) {
    return Row(
      children: [
        _buildFilterCapsule('最新更新 ▾', isDark),
        SizedBox(width: 8.w),
        _buildFilterCapsule('官方整理優先 ▾', isDark),
      ],
    );
  }

  Widget _buildFilterCapsule(String label, bool isDark) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E2228) : Colors.white,
        borderRadius: BorderRadius.circular(6.r),
        border: Border.all(
          color: isDark ? const Color(0xFF2D333F) : ProtoColors.border,
          width: 0.8.w,
        ),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 10.sp,
          fontWeight: FontWeight.bold,
          color: isDark ? const Color(0xFF94A3B8) : ProtoColors.charcoal,
        ),
      ),
    );
  }

  void _openTip(BuildContext context, HomeNewsletterItem item) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (__) => LifeLegalTipDetailPage(item: item)),
    );
  }
}

/// 避坑筆記詳細頁
class LifeLegalTipDetailPage extends StatefulWidget {
  const LifeLegalTipDetailPage({
    super.key,
    required this.item,
  });

  final HomeNewsletterItem item;

  @override
  State<LifeLegalTipDetailPage> createState() => _LifeLegalTipDetailPageState();
}

class _LifeLegalTipDetailPageState extends State<LifeLegalTipDetailPage> {
  late final ScrollController _scrollController;
  late final List<String> _steps;
  late List<bool> _stepsChecked;
  double _readingProgress = 0.0;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollController.addListener(_onScroll);

    _steps = _buildActionSteps(widget.item);
    _stepsChecked = List.generate(_steps.length, (_) => false);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    final maxScroll = _scrollController.position.maxScrollExtent;
    if (maxScroll <= 0) return;
    setState(() {
      _readingProgress = (_scrollController.offset / maxScroll).clamp(0.0, 1.0);
    });
  }

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.paddingOf(context).top;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final aes = aestheticsForCategory(widget.item.category, isDark);
    final badge = _getEditorialBadge(widget.item.title);

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0F1216) : ProtoColors.lightBg,
      body: Stack(
        children: [
          ListView(
            controller: _scrollController,
            physics: const BouncingScrollPhysics(),
            padding: EdgeInsets.fromLTRB(
              16.w,
              topPadding + 64.h,
              16.w,
              124.h,
            ),
            children: [
              // 頂部首部資訊區
              _buildHeaderSection(isDark, badge),
              SizedBox(height: 20.h),

              // 1. 踩坑情境
              _buildScenarioSection(isDark, aes),
              SizedBox(height: 20.h),

              // 2. 你要注意
              _buildWarningSection(isDark, aes),
              SizedBox(height: 20.h),

              // 3. 避坑做法
              _buildStepsSection(isDark, aes),
              SizedBox(height: 20.h),

              // 4. 相關法規 / 生活提醒
              _buildLawsSection(isDark, aes),
            ],
          ),
          // 頂部導覽列 (使用 SafeArea 自動計算安全區域)
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                child: Row(
                  children: [
                    SubpageTopBar(onBack: () => Navigator.of(context).pop()),
                    SizedBox(width: 8.w),
                    Text(
                      '避坑指引',
                      style: TextStyle(
                        fontSize: 16.5.sp,
                        fontWeight: FontWeight.w900,
                        color: isDark ? Colors.white : AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          // 極簡進度條
          Positioned(
            top: topPadding + 52.h,
            left: 0,
            right: 0,
            child: Container(
              alignment: Alignment.centerLeft,
              height: 2.5.h,
              color: isDark
                  ? Colors.white.withValues(alpha: 0.03)
                  : Colors.black.withValues(alpha: 0.02),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 80),
                width: MediaQuery.of(context).size.width * _readingProgress,
                height: 2.5.h,
                color: aes.primary,
              ),
            ),
          ),
          _buildBottomStickyPanel(isDark, aes),
        ],
      ),
    );
  }

  Widget _buildHeaderSection(bool isDark, EditorialBadge badge) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
          decoration: BoxDecoration(
            color: badge.bgColor,
            borderRadius: BorderRadius.circular(4.r),
            border: Border.all(
                color: badge.textColor.withValues(alpha: 0.2), width: 0.8.w),
          ),
          child: Text(
            badge.label,
            style: TextStyle(
              color: badge.textColor,
              fontSize: 10.sp,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
        SizedBox(height: 10.h),
        Text(
          widget.item.title,
          style: TextStyle(
            fontSize: 20.sp,
            fontWeight: FontWeight.w900,
            color: isDark ? Colors.white : ProtoColors.charcoal,
            height: 1.35,
          ),
        ),
        SizedBox(height: 8.h),
        Row(
          children: [
            Text(
              widget.item.category,
              style: TextStyle(
                fontSize: 12.sp,
                fontWeight: FontWeight.bold,
                color:
                    aestheticsForCategory(widget.item.category, isDark).primary,
              ),
            ),
            SizedBox(width: 8.w),
            Container(width: 1.w, height: 12.h, color: Colors.grey.shade400),
            SizedBox(width: 8.w),
            Text(
              '更新日期：2024/05/12',
              style: TextStyle(
                fontSize: 11.sp,
                color:
                    isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8),
              ),
            ),
          ],
        ),
        SizedBox(height: 16.h),
        Divider(
            color: isDark ? const Color(0xFF2D333F) : ProtoColors.border,
            height: 1.w),
      ],
    );
  }

  Widget _buildScenarioSection(bool isDark, CategoryAesthetics aes) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF232018) : const Color(0xFFFCF8EC),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: isDark ? const Color(0xFF3B3425) : const Color(0xFFEFE4C7),
          width: 0.8.w,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.03),
            blurRadius: 4,
            offset: const Offset(1, 2),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CtmSvgIcon(CtmSvgIcons.question,
                    color: const Color(0xFFC48A7A), size: 18.sp),
                SizedBox(width: 8.w),
                Text(
                  '踩坑情境',
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w900,
                    color: isDark ? Colors.white : AppColors.textPrimary,
                  ),
                ),
              ],
            ),
            SizedBox(height: 8.h),
            Text(
              '退租時房東能扣哪些費用？哪些情況屬於不當扣款？快速掌握重點，保障你的權益。',
              style: TextStyle(
                fontSize: 13.sp,
                height: 1.5,
                color:
                    isDark ? const Color(0xFFCBD5E1) : const Color(0xFF475467),
              ),
            ),
            SizedBox(height: 10.h),
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(12.w),
              decoration: BoxDecoration(
                color:
                    isDark ? const Color(0xFF332D23) : const Color(0xFFF7EED2),
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Text(
                '情境範例：退租時房東以『清潔費』『油漆費』等名義，從押金中扣款，但未提供明確證據或收據。',
                style: TextStyle(
                  fontSize: 12.5.sp,
                  height: 1.5,
                  color: isDark
                      ? const Color(0xFFE2B095)
                      : const Color(0xFF7A624A),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWarningSection(bool isDark, CategoryAesthetics aes) {
    final bullets = const [
      '押金扣除需符合《租賃專法》規定。',
      '房東應提出實際損壞證明與修繕單據。',
      '一般正常使用造成之耗損，不得扣款。',
    ];
    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF232018) : const Color(0xFFFCF8EC),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: isDark ? const Color(0xFF3B3425) : const Color(0xFFEFE4C7),
          width: 0.8.w,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.03),
            blurRadius: 4,
            offset: const Offset(1, 2),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CtmSvgIcon(CtmSvgIcons.idea,
                    color: const Color(0xFFD6A85F), size: 18.sp),
                SizedBox(width: 8.w),
                Text(
                  '你要注意',
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w900,
                    color: isDark ? Colors.white : AppColors.textPrimary,
                  ),
                ),
              ],
            ),
            SizedBox(height: 10.h),
            ...bullets.map((bullet) => Padding(
                  padding: EdgeInsets.only(bottom: 6.h),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        margin: EdgeInsets.only(top: 6.h),
                        width: 5.w,
                        height: 5.w,
                        decoration: const BoxDecoration(
                          color: Color(0xFFD6A85F),
                          shape: BoxShape.circle,
                        ),
                      ),
                      SizedBox(width: 8.w),
                      Expanded(
                        child: Text(
                          bullet,
                          style: TextStyle(
                            fontSize: 13.sp,
                            height: 1.45,
                            color: isDark
                                ? const Color(0xFFCBD5E1)
                                : const Color(0xFF334155),
                          ),
                        ),
                      ),
                    ],
                  ),
                )),
          ],
        ),
      ),
    );
  }

  Widget _buildStepsSection(bool isDark, CategoryAesthetics aes) {
    final completedCount = _stepsChecked.where((c) => c).length;
    final progress = _steps.isEmpty ? 0.0 : completedCount / _steps.length;

    return ClipRRect(
      borderRadius: BorderRadius.circular(12.r),
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF181C23) : Colors.white,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
              color: isDark ? const Color(0xFF2D333F) : const Color(0xFFE5E7EB),
              width: 0.8.w),
        ),
        child: Stack(
          children: [
            Positioned(
              left: 0,
              top: 0,
              bottom: 0,
              width: 4.w,
              child: Container(color: ProtoColors.sageGreen),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(16.w, 14.h, 14.w, 14.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          CtmSvgIcon(CtmSvgIcons.filePen,
                              color: ProtoColors.sageGreen, size: 18.sp),
                          SizedBox(width: 8.w),
                          Text(
                            '避坑做法',
                            style: TextStyle(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w900,
                              color:
                                  isDark ? Colors.white : AppColors.textPrimary,
                            ),
                          ),
                        ],
                      ),
                      CircularProgressRing(
                        progress: progress,
                        accentColor: ProtoColors.sageGreen,
                      ),
                    ],
                  ),
                  SizedBox(height: 12.h),
                  ...List.generate(_steps.length, (index) {
                    final step = _steps[index];
                    final isChecked = _stepsChecked[index];
                    return GestureDetector(
                      onTap: () {
                        if (!isChecked) {
                          HapticFeedback.mediumImpact();
                        } else {
                          HapticFeedback.lightImpact();
                        }
                        setState(() {
                          _stepsChecked[index] = !_stepsChecked[index];
                        });
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        margin: EdgeInsets.only(bottom: 8.h),
                        padding: EdgeInsets.symmetric(
                            horizontal: 12.w, vertical: 10.h),
                        decoration: BoxDecoration(
                          color: isChecked
                              ? (isDark
                                  ? const Color(0xFF14241B)
                                  : AppColors.success.withValues(alpha: 0.12))
                              : (isDark
                                  ? const Color(0xFF1E2228)
                                  : Colors.white),
                          borderRadius: BorderRadius.circular(8.r),
                          border: Border.all(
                            color: isChecked
                                ? AppColors.success
                                : (isDark
                                    ? const Color(0xFF2D333F)
                                    : ProtoColors.border),
                            width: 0.8.w,
                          ),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 18.w,
                              height: 18.w,
                              decoration: BoxDecoration(
                                color: isChecked
                                    ? AppColors.success
                                    : Colors.transparent,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: isChecked
                                      ? AppColors.success
                                      : ProtoColors.sageGreen,
                                  width: 1.5.w,
                                ),
                              ),
                              child: Center(
                                child: isChecked
                                    ? Icon(Icons.check,
                                        size: 12.sp,
                                        color: isDark
                                            ? Colors.black
                                            : Colors.white)
                                    : Text(
                                        '${index + 1}',
                                        style: TextStyle(
                                          fontSize: 10.sp,
                                          fontWeight: FontWeight.bold,
                                          color: ProtoColors.sageGreen,
                                        ),
                                      ),
                              ),
                            ),
                            SizedBox(width: 10.w),
                            Expanded(
                              child: Text(
                                step,
                                style: TextStyle(
                                  fontSize: 12.5.sp,
                                  height: 1.45,
                                  color: isChecked
                                      ? (isDark
                                          ? const Color(0xFF8CAF96)
                                          : const Color(0xFF3B5E4A))
                                      : (isDark
                                          ? const Color(0xFFE2E8F0)
                                          : const Color(0xFF334155)),
                                  decoration: isChecked
                                      ? TextDecoration.lineThrough
                                      : null,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLawsSection(bool isDark, CategoryAesthetics aes) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12.r),
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF181C23) : Colors.white,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
              color: isDark ? const Color(0xFF2D333F) : const Color(0xFFE5E7EB),
              width: 0.8.w),
        ),
        child: Stack(
          children: [
            Positioned(
              left: 0,
              top: 0,
              bottom: 0,
              width: 4.w,
              child: Container(color: AppColors.accent),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(16.w, 14.h, 14.w, 14.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CtmSvgIcon(CtmSvgIcons.gavel,
                          color: AppColors.accent, size: 18.sp),
                      SizedBox(width: 8.w),
                      Text(
                        '相關法規 / 生活提醒',
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w900,
                          color: isDark ? Colors.white : AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 10.h),
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(12.w),
                    decoration: BoxDecoration(
                      color: isDark
                          ? const Color(0xFF2E2719)
                          : const Color(0xFFFFF9E6),
                      borderRadius: BorderRadius.circular(8.r),
                      border: Border.all(
                        color: isDark
                            ? const Color(0xFF3D3425)
                            : const Color(0xFFF1E4C3),
                        width: 0.8.w,
                      ),
                    ),
                    child: Text(
                      '法規依據：《住宅租賃定型化契約應記載及不得記載事項》第 11 點、第 12 點。',
                      style: TextStyle(
                        fontSize: 12.5.sp,
                        height: 1.5,
                        color: isDark
                            ? const Color(0xFFE2B095)
                            : const Color(0xFF7A624A),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomStickyPanel(bool isDark, CategoryAesthetics aes) {
    final foregroundCol = isDark ? Colors.white : AppColors.textPrimary;
    return Positioned(
      bottom: MediaQuery.paddingOf(context).bottom + 16.h,
      left: 16.w,
      right: 16.w,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF181C23) : Colors.white,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
            color: isDark ? const Color(0xFF2D333F) : ProtoColors.border,
            width: 0.8.w,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.04),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            // 收藏 Outlined
            Expanded(
              flex: 3,
              child: SizedBox(
                height: 48.h,
                child: OutlinedButton.icon(
                  onPressed: () {
                    HapticFeedback.lightImpact();
                    CustomToast.show(context, '已加入收藏',
                        icon: Icons.bookmark_rounded);
                  },
                  style: OutlinedButton.styleFrom(
                    padding: EdgeInsets.zero,
                    side: BorderSide(
                        color: isDark
                            ? const Color(0xFF2D333F)
                            : ProtoColors.border,
                        width: 1.w),
                    foregroundColor: foregroundCol,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.r)),
                  ),
                  icon: CtmSvgIcon(CtmSvgIcons.bookmark,
                      size: 16.sp, color: foregroundCol),
                  label: Text('收藏',
                      style: TextStyle(
                          fontSize: 12.sp, fontWeight: FontWeight.bold)),
                ),
              ),
            ),
            SizedBox(width: 8.w),
            // 問法助 Outlined Green
            Expanded(
              flex: 3,
              child: SizedBox(
                height: 48.h,
                child: OutlinedButton.icon(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (__) => LawAssistantChatPage(
                          initialPrompt:
                              '我想了解「${widget.item.title}」這個生活法律問題，可以怎麼處理？',
                        ),
                      ),
                    );
                  },
                  style: OutlinedButton.styleFrom(
                    padding: EdgeInsets.zero,
                    side: BorderSide(color: ProtoColors.sageGreen, width: 1.w),
                    foregroundColor: isDark
                        ? ProtoColors.sageGreen
                        : const Color(0xFF2C5E43),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.r)),
                  ),
                  icon: CtmSvgIcon(CtmSvgIcons.brain,
                      size: 16.sp,
                      color: isDark
                          ? ProtoColors.sageGreen
                          : const Color(0xFF2C5E43)),
                  label: Text('問法助',
                      style: TextStyle(
                          fontSize: 12.sp, fontWeight: FontWeight.bold)),
                ),
              ),
            ),
            SizedBox(width: 8.w),
            // 查法規 Filled Category Gradient
            Expanded(
              flex: 4,
              child: Container(
                height: 48.h,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: aes.gradient,
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: FilledButton.icon(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (__) => StatuteDatabasePage(
                          initialQuery: _statuteQueryForTip(widget.item),
                        ),
                      ),
                    );
                  },
                  style: FilledButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    padding: EdgeInsets.zero,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.r)),
                  ),
                  icon: CtmSvgIcon(CtmSvgIcons.search,
                      size: 16.sp, color: Colors.white),
                  label: Text('查法規',
                      style: TextStyle(
                          fontSize: 12.sp, fontWeight: FontWeight.bold)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  static List<String> _buildActionSteps(HomeNewsletterItem item) {
    if (item.title.contains('狗')) {
      return const [
        '確認是否有受傷，並前往醫院開立就醫診斷證明。',
        '保留現場照片、調閱監視器畫面，留存牽繩防護細節或飼主身分。',
        '如需和解或訴訟，請整理好醫療收據及其他財產損失單據。'
      ];
    }
    if (item.title.contains('自拍') || item.title.contains('拍照')) {
      return const [
        '公開上傳照片或影片前，檢查背景是否有明顯可辨識的路人。',
        '避免將他人清晰的特寫、車牌號碼、或門牌住家當作照片主體。',
        '若用於商業營利、自媒體置入或醜化言論，務必取得當事人授權。'
      ];
    }
    return const [
      '翻出契約，詳閱是否有提前終止條款、違約金規定或修繕義務分配。',
      '點交退租前，務必對房屋現狀進行拍照或錄影存證。',
      '若房東無故扣押金，請其出示折抵修繕項目的估價單或收據。'
    ];
  }

  static String _statuteQueryForTip(HomeNewsletterItem item) {
    if (item.title.contains('狗')) return '民法 動物';
    if (item.title.contains('自拍')) return '肖像權';
    return '租賃 押金';
  }
}

/// 懸浮毛玻璃頂部背景裝飾
class _LifeTrapTopFrostMask extends StatelessWidget {
  const _LifeTrapTopFrostMask({required this.topPadding});

  final double topPadding;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: IgnorePointer(
        child: Container(
          height: topPadding + 146.h,
          color: ProtoColors.lightBg,
        ),
      ),
    );
  }
}

/// 頂部 AppBar
class _LifeTrapAppBar extends StatelessWidget {
  const _LifeTrapAppBar({required this.onBack});

  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return SizedBox(
      height: 42.h,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: SubpageTopBar(onBack: onBack),
          ),
          Text(
            '生活避坑筆記',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 17.sp,
              fontWeight: FontWeight.w900,
              color: isDark ? Colors.white : ProtoColors.charcoal,
            ),
          ),
        ],
      ),
    );
  }
}

/// 搜尋框 (帶聚焦光暈)
class _LifeTrapSearchBar extends StatefulWidget {
  const _LifeTrapSearchBar({required this.controller});

  final TextEditingController controller;

  @override
  State<_LifeTrapSearchBar> createState() => _LifeTrapSearchBarState();
}

class _LifeTrapSearchBarState extends State<_LifeTrapSearchBar> {
  late final FocusNode _focusNode;
  var _isFocused = false;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
    _focusNode.addListener(() {
      setState(() {
        _isFocused = _focusNode.hasFocus;
      });
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = AppColors.primary;
    final secondaryColor =
        isDark ? const Color(0xFF64748B) : AppColors.textSecondary;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 2.h),
      decoration: BoxDecoration(
        color: _isFocused
            ? (isDark ? const Color(0xFF1E2228) : AppColors.surface)
            : (isDark ? const Color(0xFF1E2228) : AppColors.searchSurface),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: _isFocused ? primaryColor : Colors.transparent,
          width: 0.8.w,
        ),
      ),
      child: TextField(
        controller: widget.controller,
        focusNode: _focusNode,
        onTapOutside: (event) {
          _focusNode.unfocus();
        },
        textInputAction: TextInputAction.search,
        decoration: InputDecoration(
          hintText: '搜尋筆記標題或關鍵字',
          hintStyle: TextStyle(
            color: isDark ? const Color(0xFF64748B) : AppColors.textMuted,
            fontSize: 12.5.sp,
          ),
          border: InputBorder.none,
          icon: Icon(
            Icons.search_rounded,
            color: _isFocused ? primaryColor : secondaryColor,
            size: 20.sp,
          ),
          suffixIcon: widget.controller.text.isEmpty
              ? null
              : IconButton(
                  onPressed: widget.controller.clear,
                  icon: Icon(Icons.close_rounded,
                      size: 18.sp, color: secondaryColor),
                ),
        ),
        style: TextStyle(
          fontSize: 12.5.sp,
          fontWeight: FontWeight.w700,
          color: isDark ? Colors.white : AppColors.textSecondary,
        ),
      ),
    );
  }
}

class _SubpageInlineHeader extends StatelessWidget {
  const _SubpageInlineHeader({
    required this.title,
    required this.count,
  });

  final String title;
  final int count;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 15.sp,
              fontWeight: FontWeight.w900,
              color: isDark ? Colors.white : ProtoColors.charcoal,
            ),
          ),
        ),
        Text(
          '$count 則',
          style: TextStyle(
            fontSize: 10.5.sp,
            fontWeight: FontWeight.w800,
            color: isDark ? const Color(0xFF64748B) : AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}

/// 彈性拉伸 page dots
class _LifeTipPageDots extends StatelessWidget {
  const _LifeTipPageDots({
    required this.count,
    required this.activeIndex,
    required this.pageOffset,
    required this.accentColor,
  });

  final int count;
  final int activeIndex;
  final double pageOffset;
  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final activeCol = isDark ? Colors.white : AppColors.primary;
    final inactiveCol = isDark
        ? Colors.white.withValues(alpha: 0.2)
        : Colors.black.withValues(alpha: 0.1);

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(count, (index) {
        final double distance = (index - pageOffset).abs();
        final double activeWeight = (1.0 - distance).clamp(0.0, 1.0);
        final double width = 4.w + (12.w * activeWeight);

        return Container(
          width: width,
          height: 3.h,
          margin: EdgeInsets.symmetric(horizontal: 2.w),
          decoration: BoxDecoration(
            color: Color.lerp(
              inactiveCol,
              activeCol,
              activeWeight,
            ),
            borderRadius: BorderRadius.circular(100.r),
          ),
        );
      }),
    );
  }
}

/// 分類篩選藥丸軌道
class _LifeTipCategoryRail extends StatelessWidget {
  const _LifeTipCategoryRail({
    required this.labels,
    required this.selectedLabel,
    required this.onSelected,
  });

  final List<String> labels;
  final String selectedLabel;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SizedBox(
      height: 38.h,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        padding: EdgeInsets.symmetric(horizontal: 4.w),
        itemBuilder: (context, index) {
          final label = labels[index];
          final isSelected = label == selectedLabel;
          final aes = aestheticsForCategory(label, isDark);
          final pillBg = isSelected
              ? AppColors.primary
              : (isDark ? const Color(0xFF1E2228) : AppColors.chipSurface);
          final textCol = isSelected
              ? Colors.white
              : (isDark ? const Color(0xFF94A3B8) : AppColors.textSecondary);

          return AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () => onSelected(label),
                borderRadius: BorderRadius.circular(8.r),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding:
                      EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                  decoration: BoxDecoration(
                    color: pillBg,
                    borderRadius: BorderRadius.circular(8.r),
                    border: Border.all(
                      color:
                          isSelected ? AppColors.primary : Colors.transparent,
                      width: 1.w,
                    ),
                  ),
                  child: Center(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (isSelected && label != '全部') ...[
                          Icon(aes.icon, size: 13.sp, color: Colors.white),
                          SizedBox(width: 6.w),
                        ],
                        Text(
                          label,
                          style: TextStyle(
                            fontSize: 11.5.sp,
                            fontWeight: FontWeight.w900,
                            color: textCol,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
        separatorBuilder: (_, __) => SizedBox(width: 8.w),
        itemCount: labels.length,
      ),
    );
  }
}

/// 輪播專用精簡大卡片 (平面設計)
class _LifeTipFeaturedCard extends StatelessWidget {
  const _LifeTipFeaturedCard({
    required this.item,
    required this.onTap,
  });

  final HomeNewsletterItem item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final aes = aestheticsForCategory(item.category, isDark);
    final badge = _getEditorialBadge(item.title);
    final cleanTip = item.tip
        .replaceFirst(RegExp(r'^小提醒：'), '')
        .replaceFirst(RegExp(r'^💡\s*'), '');

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(14.w),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF181C23) : const Color(0xFFFAF5EC),
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
            color: isDark ? const Color(0xFF2D333F) : const Color(0xFFEDE4D8),
            width: 0.8.w,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // 編輯推薦特色標籤
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
                  decoration: BoxDecoration(
                    color: badge.bgColor,
                    borderRadius: BorderRadius.circular(4.r),
                    border: Border.all(
                        color: badge.textColor.withValues(alpha: 0.2),
                        width: 0.8.w),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CtmSvgIcon(_svgPathForCategory(item.category),
                          size: 10.sp, color: badge.textColor),
                      SizedBox(width: 4.w),
                      Text(
                        badge.label,
                        style: TextStyle(
                          color: badge.textColor,
                          fontSize: 9.5.sp,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ],
                  ),
                ),
                CtmSvgIcon(
                  CtmSvgIcons.arrowRight,
                  color: isDark
                      ? const Color(0xFF64748B)
                      : AppColors.textSecondary,
                  size: 15.sp,
                ),
              ],
            ),
            SizedBox(height: 6.h),
            Text(
              item.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: isDark ? Colors.white : const Color(0xFF243B63),
                fontSize: 15.sp,
                fontWeight: FontWeight.w900,
              ),
            ),
            SizedBox(height: 4.h),
            Expanded(
              child: Text(
                item.summary,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: isDark
                      ? const Color(0xFF94A3B8)
                      : const Color(0xFF667085),
                  fontSize: 11.5.sp,
                  height: 1.4,
                ),
              ),
            ),
            SizedBox(height: 6.h),
            // 平面化的小提醒一行條 (綠色底線版)
            Container(
              padding: EdgeInsets.symmetric(vertical: 6.h, horizontal: 8.w),
              decoration: BoxDecoration(
                color:
                    isDark ? const Color(0xFF22252A) : const Color(0xFFEEF7F2),
                borderRadius: BorderRadius.circular(6.r),
              ),
              child: Row(
                children: [
                  CtmSvgIcon(
                    CtmSvgIcons.idea,
                    color: isDark
                        ? const Color(0xFF8BF45F)
                        : const Color(0xFF2E7D32),
                    size: 13.sp,
                  ),
                  SizedBox(width: 6.w),
                  Expanded(
                    child: Text(
                      cleanTip,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: isDark
                            ? const Color(0xFFCBD5E1)
                            : const Color(0xFF2E7D32),
                        fontSize: 10.5.sp,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 列表專用精美大卡片 (左側多彩邊條與漸層左圖右文平面設計)
class _LifeTipListCard extends StatefulWidget {
  const _LifeTipListCard({
    required this.item,
    this.onTap,
  });

  final HomeNewsletterItem item;
  final VoidCallback? onTap;

  @override
  State<_LifeTipListCard> createState() => _LifeTipListCardState();
}

class _LifeTipListCardState extends State<_LifeTipListCard> {
  @override
  Widget build(BuildContext context) {
    final item = widget.item;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final aes = aestheticsForCategory(item.category, isDark);
    final badge = _getEditorialBadge(item.title);

    return Material(
      color: Colors.transparent,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12.r),
        child: Container(
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E2228) : const Color(0xFFFAF5EC),
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(
                color:
                    isDark ? const Color(0xFF2D333F) : const Color(0xFFEDE4D8),
                width: 0.8.w),
          ),
          child: Stack(
            children: [
              // 左側類別彩虹邊條
              Positioned(
                left: 0,
                top: 0,
                bottom: 0,
                width: 4.w,
                child: Container(color: aes.primary),
              ),
              InkWell(
                onTap: widget.onTap,
                child: Padding(
                  padding: EdgeInsets.fromLTRB(16.w, 12.h, 12.w, 12.h),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 左側：縮圖預留框 (色彩飽和漸層)
                      Container(
                        width: 80.w,
                        height: 80.w,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              aes.primary
                                  .withValues(alpha: isDark ? 0.2 : 0.12),
                              aes.primary
                                  .withValues(alpha: isDark ? 0.08 : 0.05),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(8.r),
                          border: Border.all(
                            color: aes.primary.withValues(alpha: 0.2),
                            width: 0.8.w,
                          ),
                        ),
                        child: Center(
                          child: CtmSvgIcon(
                            CtmSvgIcons.bookOpen,
                            color: aes.primary,
                            size: 26.sp,
                          ),
                        ),
                      ),
                      SizedBox(width: 12.w),
                      // 右側資訊
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              item.title,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 13.5.sp,
                                fontWeight: FontWeight.w900,
                                color: isDark
                                    ? Colors.white
                                    : const Color(0xFF243B63),
                                height: 1.35,
                              ),
                            ),
                            SizedBox(height: 12.h),
                            Row(
                              children: [
                                // 分類標籤 (如「租屋」)
                                Container(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 6.w, vertical: 2.h),
                                  decoration: BoxDecoration(
                                    color: isDark
                                        ? const Color(0xFF282F3B)
                                        : const Color(0xFFF1F5F9),
                                    borderRadius: BorderRadius.circular(4.r),
                                  ),
                                  child: Text(
                                    item.category,
                                    style: TextStyle(
                                      fontSize: 9.sp,
                                      fontWeight: FontWeight.bold,
                                      color: isDark
                                          ? const Color(0xFF94A3B8)
                                          : const Color(0xFF475467),
                                    ),
                                  ),
                                ),
                                SizedBox(width: 6.w),
                                // 官方整理/編輯精選標籤
                                Container(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 6.w, vertical: 2.h),
                                  decoration: BoxDecoration(
                                    color: badge.bgColor,
                                    borderRadius: BorderRadius.circular(4.r),
                                    border: Border.all(
                                        color: badge.textColor
                                            .withValues(alpha: 0.2),
                                        width: 0.8.w),
                                  ),
                                  child: Text(
                                    badge.label,
                                    style: TextStyle(
                                      fontSize: 9.sp,
                                      fontWeight: FontWeight.bold,
                                      color: badge.textColor,
                                    ),
                                  ),
                                ),
                                const Spacer(),
                                Text(
                                  '05/12 更新',
                                  style: TextStyle(
                                    fontSize: 9.5.sp,
                                    color: isDark
                                        ? const Color(0xFF64748B)
                                        : const Color(0xFF94A3B8),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// 自定義的圓形進度環 (Apple Watch 風格)
class CircularProgressRing extends StatelessWidget {
  const CircularProgressRing({
    super.key,
    required this.progress,
    this.size = 56.0,
    required this.accentColor,
  });

  final double progress;
  final double size;
  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final trackColor = isDark
        ? Colors.white.withValues(alpha: 0.08)
        : Colors.black.withValues(alpha: 0.05);
    final List<Color> ringGradient = [
      accentColor.withValues(alpha: 0.6),
      accentColor,
      accentColor.withValues(alpha: 0.9),
    ];

    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: ProgressRingPainter(
          progress: progress,
          trackColor: trackColor,
          ringGradient: ringGradient,
        ),
        child: Center(
          child: Text(
            '${(progress * 100).toInt()}%',
            style: TextStyle(
              fontSize: 11.sp,
              fontWeight: FontWeight.w900,
              color: accentColor,
            ),
          ),
        ),
      ),
    );
  }
}

class ProgressRingPainter extends CustomPainter {
  final double progress;
  final Color trackColor;
  final List<Color> ringGradient;

  ProgressRingPainter({
    required this.progress,
    required this.trackColor,
    required this.ringGradient,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - 6.w) / 2;

    final trackPaint = Paint()
      ..color = trackColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5.w;
    canvas.drawCircle(center, radius, trackPaint);

    if (progress > 0) {
      final rect = Rect.fromCircle(center: center, radius: radius);
      final ringPaint = Paint()
        ..shader = SweepGradient(
          colors: ringGradient,
          startAngle: -3.14159 / 2,
          endAngle: 3 * 3.14159 / 2,
        ).createShader(rect)
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeWidth = 5.w;

      canvas.drawArc(
          rect, -3.14159 / 2, progress * 2 * 3.14159, false, ringPaint);
    }
  }

  @override
  bool shouldRepaint(covariant ProgressRingPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
