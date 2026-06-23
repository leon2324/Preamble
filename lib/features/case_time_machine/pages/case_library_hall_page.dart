import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lawapp/features/case_time_machine/models/case_time_machine_models.dart';
import 'package:lawapp/features/case_time_machine/pages/case_dossier_detail_page.dart';
import 'package:lawapp/features/case_time_machine/pages/case_time_machine_search_page.dart';
import 'package:lawapp/features/case_time_machine/theme/case_time_machine_theme.dart';
import 'package:lawapp/features/case_time_machine/widgets/case_time_machine_scaffold.dart';
import 'package:lawapp/features/case_time_machine/widgets/case_time_machine_svg_icon.dart';
import 'package:lawapp/features/case_time_machine/data/case_time_machine_repository.dart';

class CaseLibraryHallPage extends StatefulWidget {
  const CaseLibraryHallPage({super.key, required this.hall});

  final CaseLibraryHall hall;

  @override
  State<CaseLibraryHallPage> createState() => _CaseLibraryHallPageState();
}

class _CaseLibraryHallPageState extends State<CaseLibraryHallPage> {
  // Timeline State
  String _selectedEra = '全部';

  // Theme State
  String _selectedThemeTab = '車禍賠償';

  // 動態加載真實案件 State
  List<CaseBook> _allCases = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCases();
  }

  Future<void> _loadCases() async {
    if (!mounted) return;
    setState(() => _isLoading = true);
    try {
      if (widget.hall.type == CaseLibraryHallType.timeline ||
          widget.hall.type == CaseLibraryHallType.classic ||
          widget.hall.type == CaseLibraryHallType.status) {
        // 年代、經典、審判狀態館：從倉庫/Supabase 異步拉取較多真實裁判筆數進行過濾展示
        final books =
            await CaseTimeMachineRepository.instance.getCasesPaginated(60, 0);
        if (mounted) {
          setState(() {
            _allCases = books;
            _isLoading = false;
          });
        }
      } else if (widget.hall.type == CaseLibraryHallType.theme) {
        // 主題議題館：拉取特定真實類別的裁判
        final books = await CaseTimeMachineRepository.instance
            .getCasesPaginated(30, 0, category: _selectedThemeTab);
        if (mounted) {
          setState(() {
            _allCases = books;
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      print('Error loading cases for hall: $e');
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  // 台灣繁體中文教學註解：
  // 類別→顏色對照表，更新為 8 大真實裁判類別，並套用莫蘭迪色系
  static const Map<String, Color> _categoryColorMap = {
    '車禍賠償': Color(0xFF4A7C8C),
    '借款返還': Color(0xFF6D649A),
    '租屋糾紛': Color(0xFF8C4A5A),
    '給付價金': Color(0xFF357A53),
    '不當解雇': Color(0xFF9E7B2D),
    '離婚親權': Color(0xFF8C5C4A),
    '竊盜': Color(0xFF5C5C45),
    '傷害': Color(0xFF7A3535),
  };

  // 台灣繁體中文教學註解：
  // 主題分頁→表情符號前綴對照表，更新為真實類別圖示
  static const Map<String, String> _themeEmojiMap = {
    '車禍賠償': '🚗 ',
    '借款返還': '💰 ',
    '租屋糾紛': '🏢 ',
    '給付價金': '💳 ',
    '不當解雇': '👔 ',
    '離婚親權': '👨‍👩‍👧‍👦 ',
    '竊盜': '🔑 ',
    '傷害': '🩹 ',
  };

  /// 台灣繁體中文教學註解：
  /// 根據案件類別取得對應的莫蘭迪色系強調色。
  /// 若類別不在對照表中，則回傳主題色 primaryGreen 作為預設值。
  Color _getCategoryAccentColor(String category) {
    return _categoryColorMap[category] ?? CaseTimeMachineColors.primaryGreen;
  }

  void _openCaseDetail(BuildContext context, CaseBook book) {
    Navigator.of(context).push(
      CupertinoPageRoute<void>(
        builder: (__) => CaseDossierDetailPage(book: book),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return CaseTimeMachineScaffold(
        scene: _getScene(widget.hall.type),
        showBackButton: false,
        useSafeArea: false,
        child: Container(
          color: CaseTimeMachineColors.bgCream,
          child: const Center(
            child: CupertinoActivityIndicator(
              radius: 14,
              color: CaseTimeMachineColors.primaryGreen,
            ),
          ),
        ),
      );
    }

    Widget content;
    switch (widget.hall.type) {
      case CaseLibraryHallType.timeline:
        content = _buildTimelineView(context);
        break;
      case CaseLibraryHallType.theme:
        content = _buildThemeView(context);
        break;
      case CaseLibraryHallType.classic:
        content = _buildClassicView(context);
        break;
      case CaseLibraryHallType.status:
        content = _buildStatusView(context);
        break;
    }

    return CaseTimeMachineScaffold(
      scene: _getScene(widget.hall.type),
      showBackButton: false,
      useSafeArea: false,
      child: Container(
        color: CaseTimeMachineColors.bgCream,
        child: SafeArea(
          bottom: false,
          child: Column(
            children: [
              // Top App Bar
              // 台灣繁體中文教學註解：
              // 為了在各種尺寸螢幕上保持標題置中，此處將 Row 佈局重構為 Stack。
              // 使用 Positioned 定位返回按鈕與搜尋按鈕，以確保中間的標題文字不偏斜。
              // 滿版寬度能避免 Stack 依標題縮小，讓左右操作鍵真正靠近 AppBar 邊界。
              Padding(
                padding: EdgeInsets.fromLTRB(6.w, 12.h, 18.w, 8.h),
                child: SizedBox(
                  width: double.infinity,
                  height: 48.h,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Positioned(
                        left: 0,
                        child: IconButton(
                          icon: CtmSvgIcon(
                            CtmSvgIcons.chevronLeft,
                            size: 20.w,
                            color: CaseTimeMachineColors.primaryGreen,
                          ),
                          onPressed: () => Navigator.of(context).pop(),
                        ),
                      ),
                      Text(
                        widget.hall.type == CaseLibraryHallType.theme
                            ? '依議題探索'
                            : widget.hall.name,
                        style: CaseTimeMachineTextStyles.pageTitle(context)
                            .copyWith(
                          fontSize: 20.sp,
                          color: CaseTimeMachineColors.primaryGreen,
                        ),
                      ),
                      if (widget.hall.type == CaseLibraryHallType.theme)
                        Positioned(
                          right: 0,
                          child: IconButton(
                            icon: CtmSvgIcon(
                              CtmSvgIcons.search,
                              size: 22.w,
                              color: CaseTimeMachineColors.primaryGreen,
                            ),
                            onPressed: () {
                              Navigator.of(context).push(
                                CupertinoPageRoute<void>(
                                  builder: (__) =>
                                      const CaseTimeMachineSearchPage(),
                                ),
                              );
                            },
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              Expanded(child: content),
            ],
          ),
        ),
      ),
    );
  }

  CaseTimeMachineScene _getScene(CaseLibraryHallType type) {
    return switch (type) {
      CaseLibraryHallType.timeline => CaseTimeMachineScene.timeline,
      CaseLibraryHallType.theme => CaseTimeMachineScene.theme,
      CaseLibraryHallType.classic => CaseTimeMachineScene.classic,
      CaseLibraryHallType.status => CaseTimeMachineScene.classic,
    };
  }

  // --- 1. SCREEN 3: TIMELINE VIEW (年代館) ---
  Widget _buildTimelineView(BuildContext context) {
    final eras = ['全部', '2020s', '2010s', '2000s', '1990s'];

    // Get all cases or filter by era shelf dynamically
    List<CaseBook> displayCases;
    if (_selectedEra == '全部') {
      displayCases = _allCases;
    } else {
      int startYear = 2020;
      if (_selectedEra == '2020s') {
        startYear = 2020;
      } else if (_selectedEra == '2010s') {
        startYear = 2010;
      } else if (_selectedEra == '2000s') {
        startYear = 2000;
      } else if (_selectedEra == '1990s') {
        startYear = 1990;
      }
      displayCases = _allCases
          .where((b) => b.year >= startYear && b.year < startYear + 10)
          .toList();
    }

    return Column(
      children: [
        // Horizontal Era Tab Bar
        SizedBox(
          height: 38.h,
          child: ListView.separated(
            padding: EdgeInsets.symmetric(horizontal: 18.w),
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            itemCount: eras.length,
            separatorBuilder: (_, __) => SizedBox(width: 8.w),
            itemBuilder: (context, index) {
              final era = eras[index];
              final isSelected = era == _selectedEra;
              return GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedEra = era;
                  });
                },
                child: Container(
                  padding:
                      EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? CaseTimeMachineColors.primaryGreen
                        : CaseTimeMachineColors.bgWhite,
                    borderRadius: BorderRadius.circular(18.r),
                    border:
                        Border.all(color: CaseTimeMachineColors.borderLight),
                  ),
                  child: Text(
                    era,
                    style: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w800,
                      color: isSelected
                          ? CaseTimeMachineColors.bgWhite
                          : CaseTimeMachineColors.textSecondary,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        SizedBox(height: 16.h),

        // Case Cards List
        Expanded(
          child: ListView.separated(
            padding: EdgeInsets.fromLTRB(18.w, 0, 18.w, 24.h),
            itemCount: displayCases.length,
            separatorBuilder: (_, __) => SizedBox(height: 14.h),
            itemBuilder: (context, index) {
              final book = displayCases[index];
              // 台灣繁體中文教學註解：
              // 取得此案件類別對應的莫蘭迪強調色，用於左側邊條、
              // 討論數徽章背景，以及卡片底部的微漸層。
              final accentColor = _getCategoryAccentColor(book.category);
              // 台灣繁體中文教學註解：
              // 利用案件 id 的 hashCode 產生偽隨機討論數，讓每張卡片
              // 呈現不同但穩定的數值，無需額外資料欄位。
              final discussionCount = (book.id.hashCode % 80 + 5).abs();
              return Container(
                decoration: BoxDecoration(
                  // 台灣繁體中文教學註解：
                  // 使用從純白到類別色 3% 透明度的線性漸層，
                  // 取代原本的純白背景，為卡片增添一絲色彩暗示。
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      CaseTimeMachineColors.bgWhite,
                      accentColor.withValues(alpha: 0.03),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(
                      CaseTimeMachineRadii.radiusMedium.r),
                  border: Border.all(color: CaseTimeMachineColors.borderLight),
                  boxShadow: [CaseTimeMachineShadows.softShadow],
                ),
                child: IntrinsicHeight(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // 台灣繁體中文教學註解：
                      // 左側彩色邊條（4.w 寬，圓角），依類別上色，
                      // 讓使用者快速掃視即可辨識案件類型。
                      Container(
                        width: 4.w,
                        decoration: BoxDecoration(
                          color: accentColor,
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(
                                CaseTimeMachineRadii.radiusMedium.r),
                            bottomLeft: Radius.circular(
                                CaseTimeMachineRadii.radiusMedium.r),
                          ),
                        ),
                      ),
                      // 台灣繁體中文教學註解：
                      // 卡片主要內容區塊，以 Expanded 填滿扣除邊條後的空間。
                      Expanded(
                        child: Padding(
                          padding: EdgeInsets.all(16.w),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        '${book.year}',
                                        style: TextStyle(
                                          fontSize: 12.sp,
                                          fontWeight: FontWeight.w800,
                                          color:
                                              CaseTimeMachineColors.accentGold,
                                        ),
                                      ),
                                      SizedBox(width: 8.w),
                                      Container(
                                        padding: EdgeInsets.symmetric(
                                            horizontal: 6.w, vertical: 2.h),
                                        decoration: BoxDecoration(
                                          color: accentColor.withValues(
                                              alpha: 0.1),
                                          borderRadius:
                                              BorderRadius.circular(4.r),
                                        ),
                                        child: Text(
                                          book.category,
                                          style: TextStyle(
                                            fontSize: 9.5.sp,
                                            fontWeight: FontWeight.w800,
                                            color: accentColor,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  CtmSvgIcon(
                                    CtmSvgIcons.bookmark,
                                    size: 22.sp,
                                    color: CaseTimeMachineColors.accentGold,
                                  ),
                                ],
                              ),
                              SizedBox(height: 8.h),
                              Text(
                                book.titleZh,
                                style:
                                    CaseTimeMachineTextStyles.cardTitle(context)
                                        .copyWith(
                                            fontSize: 15.sp,
                                            color: CaseTimeMachineColors
                                                .textPrimary),
                              ),
                              SizedBox(height: 6.h),
                              Text(
                                book.shortDescription,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style:
                                    CaseTimeMachineTextStyles.bodySmall(context)
                                        .copyWith(
                                  color: CaseTimeMachineColors.textMuted,
                                ),
                              ),
                              SizedBox(height: 14.h),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  // 台灣繁體中文教學註解：
                                  // 討論數徽章 — 以類別色 12% 透明度為底色，
                                  // 搭配小圖示與數字文字，營造社群互動感。
                                  Container(
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 8.w, vertical: 4.h),
                                    decoration: BoxDecoration(
                                      color:
                                          accentColor.withValues(alpha: 0.12),
                                      borderRadius: BorderRadius.circular(6.r),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          Icons.forum_outlined,
                                          size: 12.sp,
                                          color: accentColor,
                                        ),
                                        SizedBox(width: 4.w),
                                        Text(
                                          '$discussionCount 則討論',
                                          style: TextStyle(
                                            fontSize: 10.sp,
                                            fontWeight: FontWeight.w700,
                                            color: accentColor,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  TextButton(
                                    style: TextButton.styleFrom(
                                      backgroundColor:
                                          CaseTimeMachineColors.primaryGreen,
                                      padding: EdgeInsets.symmetric(
                                          horizontal: 16.w, vertical: 8.h),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(
                                            CaseTimeMachineRadii.radiusSmall.r),
                                      ),
                                    ),
                                    onPressed: () =>
                                        _openCaseDetail(context, book),
                                    child: Text(
                                      '查看案件',
                                      style: TextStyle(
                                        fontSize: 11.5.sp,
                                        fontWeight: FontWeight.w800,
                                        color: CaseTimeMachineColors.bgWhite,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  // --- 2. SCREEN 4: THEME VIEW (主題館) ---
  Widget _buildThemeView(BuildContext context) {
    final themeTabs = [
      '車禍賠償',
      '借款返還',
      '租屋糾紛',
      '給付價金',
      '不當解雇',
      '離婚親權',
      '竊盜',
      '傷害'
    ];

    // 直接使用動態拉取並快取的真實案件
    List<CaseBook> displayCases = _allCases;

    return Column(
      children: [
        // Horizontal Scrollable Category Tab Bar
        SizedBox(
          height: 38.h,
          child: ListView.separated(
            padding: EdgeInsets.symmetric(horizontal: 18.w),
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            itemCount: themeTabs.length,
            separatorBuilder: (_, __) => SizedBox(width: 8.w),
            itemBuilder: (context, index) {
              final tab = themeTabs[index];
              final isSelected = tab == _selectedThemeTab;
              return GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedThemeTab = tab;
                  });
                  _loadCases(); // 點選新類別時非同步向資料倉庫載入真實資料
                },
                child: Container(
                  padding:
                      EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: isSelected
                        ? CaseTimeMachineColors.primaryGreen
                        : CaseTimeMachineColors.bgWhite,
                    borderRadius: BorderRadius.circular(18.r),
                    border: Border.all(
                      color: isSelected
                          ? CaseTimeMachineColors.primaryGreen
                          : CaseTimeMachineColors.borderLight,
                    ),
                  ),
                  child: Text(
                    tab,
                    style: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w800,
                      color: isSelected
                          ? CaseTimeMachineColors.bgWhite
                          : CaseTimeMachineColors.textSecondary,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        SizedBox(height: 16.h),

        // Case Cards List
        Expanded(
          child: ListView(
            padding: EdgeInsets.fromLTRB(18.w, 0, 18.w, 24.h),
            children: [
              // Section Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '$_selectedThemeTab案件',
                    style: CaseTimeMachineTextStyles.sectionTitle(context)
                        .copyWith(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w900,
                      color: CaseTimeMachineColors.primaryGreen,
                    ),
                  ),
                  Text(
                    '查看全部',
                    style: CaseTimeMachineTextStyles.caption(context).copyWith(
                      color: CaseTimeMachineColors.textMuted,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 12.h),

              // Sub-cards list
              for (final book in displayCases) ...[
                _buildThemeCaseCard(context, book),
                SizedBox(height: 12.h),
              ],
            ],
          ),
        ),
      ],
    );
  }

  // Visual card builder for the theme cases
  Widget _buildThemeCaseCard(BuildContext context, CaseBook book) {
    // Map database properties to mockup design properties
    final mapped = _getThemeCaseDisplay(book);
    // 台灣繁體中文教學註解：
    // 取得當前主題分頁對應的 emoji 前綴，讓標題更具視覺辨識度。
    final emojiPrefix = _themeEmojiMap[_selectedThemeTab] ?? '';
    // 台灣繁體中文教學註解：
    // 取得此案件類別的莫蘭迪強調色，用於左側邊條著色。
    final accentColor = _getCategoryAccentColor(book.category);

    return GestureDetector(
      onTap: () => _openCaseDetail(context, book),
      child: Container(
        decoration: BoxDecoration(
          color: CaseTimeMachineColors.bgWhite,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: CaseTimeMachineColors.borderLight),
          boxShadow: [CaseTimeMachineShadows.softShadow],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 台灣繁體中文教學註解：
            // 左側彩色邊條 — 與年代館卡片相同的設計語言，
            // 使用 IntrinsicHeight 讓邊條高度自動匹配右側內容。
            Container(
              width: 4.w,
              decoration: BoxDecoration(
                color: accentColor,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(12.r),
                  bottomLeft: Radius.circular(12.r),
                ),
              ),
            ),
            // Left Thumbnail
            Padding(
              padding: EdgeInsets.only(left: 12.w, top: 12.w, bottom: 12.w),
              child: _buildThemeCaseThumbnail(book),
            ),
            SizedBox(width: 14.w),
            // Middle Details
            Expanded(
              child: Padding(
                padding: EdgeInsets.only(top: 12.w, bottom: 12.w, right: 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 台灣繁體中文教學註解：
                    // 標題前加上對應主題的 emoji 前綴，增添視覺趣味。
                    Text(
                      '$emojiPrefix${mapped.title}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style:
                          CaseTimeMachineTextStyles.cardTitle(context).copyWith(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w900,
                        color: CaseTimeMachineColors.textPrimary,
                      ),
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      '${mapped.year} | ${mapped.location} | ${mapped.status}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 10.sp,
                        color: CaseTimeMachineColors.textMuted,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 6.h),
                    Text(
                      mapped.summary,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style:
                          CaseTimeMachineTextStyles.bodySmall(context).copyWith(
                        color: CaseTimeMachineColors.textSecondary,
                      ),
                    ),
                    SizedBox(height: 8.h),
                    // Tags Row
                    // 台灣繁體中文教學註解：
                    // 當卡片內標籤過多或螢幕較窄時，Row 會產生 Layout Overflow 溢出警告。
                    // 此處使用 SingleChildScrollView 將其改為水平滾動，並搭配 GestureDetector
                    // 讓使用者可以點選標籤，直接跳轉到搜尋頁篩選此標籤。
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      physics: const BouncingScrollPhysics(),
                      child: Row(
                        children: mapped.tags.map((t) {
                          return GestureDetector(
                            onTap: () {
                              Navigator.of(context).push(
                                CupertinoPageRoute<void>(
                                  builder: (__) => CaseTimeMachineSearchPage(
                                      initialQuery: t),
                                ),
                              );
                            },
                            child: Container(
                              margin: EdgeInsets.only(right: 6.w),
                              padding: EdgeInsets.symmetric(
                                  horizontal: 8.w, vertical: 2.h),
                              decoration: BoxDecoration(
                                color: accentColor.withValues(alpha: 0.06),
                                borderRadius: BorderRadius.circular(4.r),
                              ),
                              child: Text(
                                '#$t',
                                style: TextStyle(
                                  fontSize: 8.5.sp,
                                  color: accentColor,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Right Bookmark
            Padding(
              padding: EdgeInsets.only(top: 12.w, right: 12.w),
              child: IconButton(
                alignment: Alignment.topRight,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                icon: CtmSvgIcon(
                  CtmSvgIcons.bookmark,
                  size: 21.sp,
                  color: CaseTimeMachineColors.accentGold,
                ),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('已追蹤「${mapped.title}」')),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildThemeCaseThumbnail(CaseBook book) {
    final images = book.displayImages;
    final url = images.isNotEmpty ? images.first.url : null;
    return ClipRRect(
      borderRadius: BorderRadius.circular(8.r),
      child: url != null && url.startsWith('http')
          ? Image.network(
              url,
              width: 80.w,
              height: 80.h,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(
                width: 80.w,
                height: 80.h,
                color: CaseTimeMachineColors.bgCream,
                child: Center(
                  child: CtmSvgIcon(
                    CtmSvgIcons.gavel,
                    size: 24.w,
                    color: CaseTimeMachineColors.primaryGreen,
                  ),
                ),
              ),
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return Container(
                  width: 80.w,
                  height: 80.h,
                  color:
                      CaseTimeMachineColors.borderLight.withValues(alpha: 0.5),
                  child: const Center(child: CupertinoActivityIndicator()),
                );
              },
            )
          : Image.asset(
              'assets/images/case_time_machine_v2/ctm_v2_case_book_cover.png',
              width: 80.w,
              height: 80.h,
              fit: BoxFit.cover,
            ),
    );
  }

  _ThemeCaseDisplayModel _getThemeCaseDisplay(CaseBook book) {
    // Default fallback from database
    return _ThemeCaseDisplayModel(
      title: book.shortTitleZh.isNotEmpty ? book.shortTitleZh : book.titleZh,
      year: book.year,
      location: book.location,
      status: book.status,
      summary: book.memoryLine,
      tags: book.tags.take(3).toList(),
    );
  }

  // --- 3. SCREEN 5: CLASSIC VIEW (經典館) ---
  Widget _buildClassicView(BuildContext context) {
    // Featured Case dynamically selected
    final featuredBook = _allCases.isNotEmpty
        ? _allCases.first
        : CaseTimeMachineRepository.instance.getCaseById('featured');

    // Representative list cases (others)
    final representativeCases =
        _allCases.isNotEmpty ? _allCases.skip(1).toList() : <CaseBook>[];

    return ListView(
      padding: EdgeInsets.fromLTRB(18.w, 4.h, 18.w, 24.h),
      children: [
        // Featured Case Card
        Container(
          decoration: BoxDecoration(
            color: CaseTimeMachineColors.primaryGreen,
            borderRadius:
                BorderRadius.circular(CaseTimeMachineRadii.radiusLarge.r),
            boxShadow: [CaseTimeMachineShadows.cardShadow],
          ),
          clipBehavior: Clip.antiAlias,
          child: Stack(
            children: [
              Positioned(
                right: -20.w,
                bottom: -20.h,
                child: Opacity(
                  opacity: 0.1,
                  child: CtmSvgIcon(
                    CtmSvgIcons.award,
                    size: 150.sp,
                    color: CaseTimeMachineColors.bgWhite,
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.all(20.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${featuredBook.year} ${featuredBook.category}',
                      style: TextStyle(
                        fontSize: 11.sp,
                        fontWeight: FontWeight.w800,
                        color: CaseTimeMachineColors.accentGold,
                      ),
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      featuredBook.titleZh,
                      style: TextStyle(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.w900,
                        color: CaseTimeMachineColors.bgWhite,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      featuredBook.memoryLine,
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: CaseTimeMachineColors.bgCream,
                      ),
                    ),
                    SizedBox(height: 16.h),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: CaseTimeMachineColors.accentGold,
                        foregroundColor: CaseTimeMachineColors.primaryGreen,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                              CaseTimeMachineRadii.radiusSmall.r),
                        ),
                      ),
                      onPressed: () => _openCaseDetail(context, featuredBook),
                      child: const Text('查看詳情',
                          style: TextStyle(fontWeight: FontWeight.w900)),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 24.h),

        // Section Title
        Text(
          '最具代表性的案件',
          style: CaseTimeMachineTextStyles.sectionTitle(context).copyWith(
            color: CaseTimeMachineColors.primaryGreen,
          ),
        ),
        SizedBox(height: 12.h),

        // Representative List Cards with Thumbnails
        for (final book in representativeCases) ...[
          GestureDetector(
            onTap: () => _openCaseDetail(context, book),
            child: Container(
              padding: EdgeInsets.all(12.w),
              decoration: BoxDecoration(
                color: CaseTimeMachineColors.bgWhite,
                borderRadius:
                    BorderRadius.circular(CaseTimeMachineRadii.radiusMedium.r),
                border: Border.all(color: CaseTimeMachineColors.borderLight),
                boxShadow: [CaseTimeMachineShadows.softShadow],
              ),
              child: Row(
                children: [
                  Container(
                    width: 64.w,
                    height: 64.h,
                    decoration: BoxDecoration(
                      color: CaseTimeMachineColors.bgCream,
                      borderRadius: BorderRadius.circular(
                          CaseTimeMachineRadii.radiusSmall.r),
                    ),
                    child: Center(
                      child: CtmSvgIcon(
                        CtmSvgIcons.gavel,
                        size: 24.w,
                        color: CaseTimeMachineColors.primaryGreen,
                      ),
                    ),
                  ),
                  SizedBox(width: 14.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${book.year} · ${book.category}',
                          style: TextStyle(
                            fontSize: 11.sp,
                            fontWeight: FontWeight.w800,
                            color: CaseTimeMachineColors.accentGold,
                          ),
                        ),
                        SizedBox(height: 4.h),
                        Text(
                          book.titleZh,
                          style: CaseTimeMachineTextStyles.cardTitle(context)
                              .copyWith(
                            color: CaseTimeMachineColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  CtmSvgIcon(
                    CtmSvgIcons.bookmark,
                    size: 20.sp,
                    color: CaseTimeMachineColors.accentGold,
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 12.h),
        ],
      ],
    );
  }

  // --- 4. SCREEN 6: STATUS VIEW (狀態分館) ---
  Widget _buildStatusView(BuildContext context) {
    return ListView.separated(
      padding: EdgeInsets.fromLTRB(18.w, 4.h, 18.w, 24.h),
      itemCount: widget.hall.shelves.length,
      separatorBuilder: (_, __) => SizedBox(height: 24.h),
      itemBuilder: (context, shelfIndex) {
        final shelf = widget.hall.shelves[shelfIndex];
        // 真實案件動態比對或降級切片分發（避免空書架與使用舊有 Legacy 案件）
        final lowerName = shelf.name.toLowerCase();
        var shelfCases = _allCases.where((c) {
          return c.status.toLowerCase().contains(lowerName) ||
              c.category.toLowerCase().contains(lowerName) ||
              c.basicInfo.procedureStage.toLowerCase().contains(lowerName) ||
              c.basicInfo.courtLevel.toLowerCase().contains(lowerName);
        }).toList();

        if (shelfCases.isEmpty && _allCases.isNotEmpty) {
          // 若無完全匹配，依 index 分發一部分真實案件展示以維持豐富度
          shelfCases = _allCases.skip(shelfIndex * 3).take(3).toList();
        }

        Color accentColor;
        Color bgColor;
        switch (shelf.coverStyle) {
          case 'green':
            accentColor = const Color(0xFF357A53);
            bgColor = const Color(0xFFEAF6EF);
            break;
          case 'slate':
            accentColor = const Color(0xFF4F5E68);
            bgColor = const Color(0xFFEFF2F4);
            break;
          case 'gold':
            accentColor = const Color(0xFF8C642B);
            bgColor = const Color(0xFFFFF9EA);
            break;
          case 'cream':
          default:
            accentColor = const Color(0xFF7A684C);
            bgColor = const Color(0xFFFAF7F0);
            break;
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 4.w,
                  height: 16.h,
                  decoration: BoxDecoration(
                    color: accentColor,
                    borderRadius: BorderRadius.circular(2.r),
                  ),
                ),
                SizedBox(width: 8.w),
                Text(
                  shelf.name,
                  style:
                      CaseTimeMachineTextStyles.sectionTitle(context).copyWith(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w900,
                    color: CaseTimeMachineColors.primaryGreen,
                  ),
                ),
                SizedBox(width: 8.w),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                  decoration: BoxDecoration(
                    color: bgColor,
                    borderRadius: BorderRadius.circular(4.r),
                  ),
                  child: Text(
                    shelf.description,
                    style: TextStyle(
                      fontSize: 9.5.sp,
                      color: accentColor,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 12.h),
            SizedBox(
              height: 100.h,
              child: shelfCases.isEmpty
                  ? Center(
                      child: Text(
                        '暫無相關案件',
                        style: TextStyle(
                          fontSize: 11.sp,
                          color: CaseTimeMachineColors.textMuted,
                        ),
                      ),
                    )
                  : ListView.separated(
                      scrollDirection: Axis.horizontal,
                      physics: const BouncingScrollPhysics(),
                      itemCount: shelfCases.length,
                      separatorBuilder: (_, __) => SizedBox(width: 12.w),
                      itemBuilder: (context, caseIndex) {
                        final book = shelfCases[caseIndex];
                        return GestureDetector(
                          onTap: () => _openCaseDetail(context, book),
                          child: Container(
                            width: 260.w,
                            padding: EdgeInsets.all(12.w),
                            decoration: BoxDecoration(
                              color: CaseTimeMachineColors.bgWhite,
                              borderRadius: BorderRadius.circular(12.r),
                              border: Border.all(
                                  color: CaseTimeMachineColors.borderLight),
                              boxShadow: [CaseTimeMachineShadows.softShadow],
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(6.r),
                                  child: Image.asset(
                                    'assets/images/case_time_machine_v2/ctm_v2_case_book_cover.png',
                                    width: 56.w,
                                    height: 56.h,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                SizedBox(width: 10.w),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        book.titleZh,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style:
                                            CaseTimeMachineTextStyles.cardTitle(
                                                    context)
                                                .copyWith(
                                          fontSize: 12.5.sp,
                                          fontWeight: FontWeight.w900,
                                          color:
                                              CaseTimeMachineColors.textPrimary,
                                        ),
                                      ),
                                      SizedBox(height: 4.h),
                                      Text(
                                        book.shortDescription.isNotEmpty
                                            ? book.shortDescription
                                            : book.memoryLine,
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                        style:
                                            CaseTimeMachineTextStyles.caption(
                                                    context)
                                                .copyWith(
                                          fontSize: 10.sp,
                                          color:
                                              CaseTimeMachineColors.textMuted,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        );
      },
    );
  }
}

class _ThemeCaseDisplayModel {
  const _ThemeCaseDisplayModel({
    required this.title,
    required this.year,
    required this.location,
    required this.status,
    required this.summary,
    required this.tags,
  });
  final String title;
  final int year;
  final String location;
  final String status;
  final String summary;
  final List<String> tags;
}
