import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:preamble/features/case_library/models/case_library_models.dart';
import 'package:preamble/features/case_library/data/case_library_image_resolver.dart';
import 'package:preamble/features/case_library/pages/case_dossier_detail_page.dart';
import 'package:preamble/features/case_library/pages/case_library_search_page.dart';
import 'package:preamble/features/case_library/theme/case_library_theme.dart';
import 'package:preamble/features/case_library/widgets/case_library_scaffold.dart';
import 'package:preamble/features/case_library/widgets/case_library_svg_icon.dart';
import 'package:preamble/features/case_library/data/case_library_repository.dart';

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
            await CaseLibraryRepository.instance.getCasesPaginated(60, 0);
        if (mounted) {
          setState(() {
            _allCases = books;
            _isLoading = false;
          });
        }
      } else if (widget.hall.type == CaseLibraryHallType.theme) {
        // 主題議題館：拉取特定真實類別的裁判
        final books = await CaseLibraryRepository.instance
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

  /// 根據案件類別取得對應的莫蘭迪色系強調色。
  /// 若類別不在對照表中，則回傳主題色 primaryGreen 作為預設值。
  Color _getCategoryAccentColor(String category) {
    return _categoryColorMap[category] ?? CaseLibraryColors.primaryGreen;
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
      return CaseLibraryScaffold(
        scene: _getScene(widget.hall.type),
        showBackButton: false,
        useSafeArea: false,
        child: Container(
          color: CaseLibraryColors.bgCream,
          child: const Center(
            child: CupertinoActivityIndicator(
              radius: 14,
              color: CaseLibraryColors.primaryGreen,
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

    return CaseLibraryScaffold(
      scene: _getScene(widget.hall.type),
      showBackButton: false,
      useSafeArea: false,
      child: Container(
        color: CaseLibraryColors.bgCream,
        child: SafeArea(
          bottom: false,
          child: Column(
            children: [
              // Top App Bar
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
                          icon: CaseLibrarySvgIcon(
                            CaseLibrarySvgIcons.chevronLeft,
                            size: 20.w,
                            color: CaseLibraryColors.primaryGreen,
                          ),
                          onPressed: () => Navigator.of(context).pop(),
                        ),
                      ),
                      Text(
                        widget.hall.type == CaseLibraryHallType.theme
                            ? '依議題探索'
                            : widget.hall.name,
                        style:
                            CaseLibraryTextStyles.pageTitle(context).copyWith(
                          fontSize: 20.sp,
                          color: CaseLibraryColors.primaryGreen,
                        ),
                      ),
                      if (widget.hall.type == CaseLibraryHallType.theme)
                        Positioned(
                          right: 0,
                          child: IconButton(
                            icon: CaseLibrarySvgIcon(
                              CaseLibrarySvgIcons.search,
                              size: 22.w,
                              color: CaseLibraryColors.primaryGreen,
                            ),
                            onPressed: () {
                              Navigator.of(context).push(
                                CupertinoPageRoute<void>(
                                  builder: (__) =>
                                      const CaseLibrarySearchPage(),
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

  CaseLibraryScene _getScene(CaseLibraryHallType type) {
    return switch (type) {
      CaseLibraryHallType.timeline => CaseLibraryScene.timeline,
      CaseLibraryHallType.theme => CaseLibraryScene.theme,
      CaseLibraryHallType.classic => CaseLibraryScene.classic,
      CaseLibraryHallType.status => CaseLibraryScene.classic,
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
                        ? CaseLibraryColors.primaryGreen
                        : CaseLibraryColors.bgWhite,
                    borderRadius: BorderRadius.circular(18.r),
                    border: Border.all(color: CaseLibraryColors.borderLight),
                  ),
                  child: Text(
                    era,
                    style: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w800,
                      color: isSelected
                          ? CaseLibraryColors.bgWhite
                          : CaseLibraryColors.textSecondary,
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
            separatorBuilder: (_, __) => SizedBox(height: 12.h),
            itemBuilder: (context, index) {
              final book = displayCases[index];
              return _buildAlignedCaseCard(context, book, index);
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
                        ? CaseLibraryColors.primaryGreen
                        : CaseLibraryColors.bgWhite,
                    borderRadius: BorderRadius.circular(18.r),
                    border: Border.all(
                      color: isSelected
                          ? CaseLibraryColors.primaryGreen
                          : CaseLibraryColors.borderLight,
                    ),
                  ),
                  child: Text(
                    tab,
                    style: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w800,
                      color: isSelected
                          ? CaseLibraryColors.bgWhite
                          : CaseLibraryColors.textSecondary,
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
                    style: CaseLibraryTextStyles.sectionTitle(context).copyWith(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w900,
                      color: CaseLibraryColors.primaryGreen,
                    ),
                  ),
                  Text(
                    '查看全部',
                    style: CaseLibraryTextStyles.caption(context).copyWith(
                      color: CaseLibraryColors.textMuted,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 12.h),

              // Sub-cards list
              for (final book in displayCases) ...[
                _buildAlignedCaseCard(
                    context, book, displayCases.indexOf(book)),
                SizedBox(height: 12.h),
              ],
            ],
          ),
        ),
      ],
    );
  }

  // --- 3. SCREEN 5: CLASSIC VIEW (經典館) ---
  Widget _buildClassicView(BuildContext context) {
    // Featured Case dynamically selected
    final featuredBook = _allCases.isNotEmpty
        ? _allCases.first
        : CaseLibraryRepository.instance.getCaseById('featured');

    // Representative list cases (others)
    final representativeCases =
        _allCases.isNotEmpty ? _allCases.skip(1).toList() : <CaseBook>[];

    return ListView(
      padding: EdgeInsets.fromLTRB(18.w, 4.h, 18.w, 24.h),
      children: [
        // Featured Case Card
        Container(
          decoration: BoxDecoration(
            color: CaseLibraryColors.primaryGreen,
            borderRadius: BorderRadius.circular(CaseLibraryRadii.radiusLarge.r),
            boxShadow: [CaseLibraryShadows.cardShadow],
          ),
          clipBehavior: Clip.antiAlias,
          child: Stack(
            children: [
              Positioned(
                right: -20.w,
                bottom: -20.h,
                child: Opacity(
                  opacity: 0.1,
                  child: CaseLibrarySvgIcon(
                    CaseLibrarySvgIcons.award,
                    size: 150.sp,
                    color: CaseLibraryColors.bgWhite,
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
                        color: CaseLibraryColors.accentGold,
                      ),
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      featuredBook.titleZh,
                      style: TextStyle(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.w900,
                        color: CaseLibraryColors.bgWhite,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      featuredBook.memoryLine,
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: CaseLibraryColors.bgCream,
                      ),
                    ),
                    SizedBox(height: 16.h),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: CaseLibraryColors.accentGold,
                        foregroundColor: CaseLibraryColors.primaryGreen,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                              CaseLibraryRadii.radiusSmall.r),
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
          style: CaseLibraryTextStyles.sectionTitle(context).copyWith(
            color: CaseLibraryColors.primaryGreen,
          ),
        ),
        SizedBox(height: 12.h),

        // Representative List Cards aligned with Daily Selection
        for (final book in representativeCases) ...[
          _buildAlignedCaseCard(
              context, book, representativeCases.indexOf(book)),
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
        // 真實案件動態比對或降級切片分發
        final lowerName = shelf.name.toLowerCase();
        var shelfCases = _allCases.where((c) {
          return c.status.toLowerCase().contains(lowerName) ||
              c.category.toLowerCase().contains(lowerName) ||
              c.basicInfo.procedureStage.toLowerCase().contains(lowerName) ||
              c.basicInfo.courtLevel.toLowerCase().contains(lowerName);
        }).toList();

        if (shelfCases.isEmpty && _allCases.isNotEmpty) {
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
                  style: CaseLibraryTextStyles.sectionTitle(context).copyWith(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w900,
                    color: CaseLibraryColors.primaryGreen,
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
              height: 220.h,
              child: shelfCases.isEmpty
                  ? Center(
                      child: Text(
                        '暫無相關案件',
                        style: TextStyle(
                          fontSize: 11.sp,
                          color: CaseLibraryColors.textMuted,
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
                        return SizedBox(
                          width: 220.w,
                          child:
                              _buildAlignedCaseCard(context, book, caseIndex),
                        );
                      },
                    ),
            ),
          ],
        );
      },
    );
  }

  // --- Aligned Case Card Builder ---
  Widget _buildAlignedCaseCard(BuildContext context, CaseBook book, int index,
      {double? width}) {
    final title =
        book.shortTitleZh.isNotEmpty ? book.shortTitleZh : book.titleZh;
    final summary = book.shortDescription.isNotEmpty
        ? book.shortDescription
        : book.memoryLine;
    final yearChip = '${book.year}年';
    final locationChip = book.location.isNotEmpty
        ? book.location
        : (index % 2 == 0 ? '台北' : '高雄');
    final statusChip =
        book.status.isNotEmpty ? book.status : (index % 2 == 0 ? '已定讞' : '審理中');
    final coverSource = _getCaseCoverImage(book, index);

    return GestureDetector(
      onTap: () => _openCaseDetail(context, book),
      child: Container(
        width: width,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
          border: Border.all(color: CaseLibraryColors.borderLight),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16.r),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildCaseCover(coverSource),
              Padding(
                padding: EdgeInsets.all(12.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        _buildInfoChip(yearChip),
                        SizedBox(width: 6.w),
                        _buildInfoChip(locationChip),
                        SizedBox(width: 6.w),
                        _buildInfoChip(statusChip),
                        const Spacer(),
                        CaseLibrarySvgIcon(
                          CaseLibrarySvgIcons.bookmark,
                          size: 18.sp,
                          color: CaseLibraryColors.accentGold,
                        ),
                      ],
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF17231F),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      summary,
                      style: TextStyle(
                        fontSize: 10.5.sp,
                        color: const Color(0xFF5A615C),
                        height: 1.4,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getCaseCoverImage(CaseBook book, int index) {
    final cover = resolveCaseLibraryCoverImage(book);
    if (cover != null && cover.url.isNotEmpty) {
      return cover.url;
    }

    final assets = [
      'assets/images/case_library_v2/daily_hunting.png',
      'assets/images/case_library_v2/daily_remote_work.png',
      'assets/images/case_library_v2/daily_rent_subsidy.png',
      'assets/images/case_library_v2/daily_gig_platform.png',
      'assets/images/case_library_v2/recent_housing.png',
      'assets/images/case_library_v2/recent_labor.png',
    ];
    return assets[(index + book.id.hashCode).abs() % assets.length];
  }

  Widget _buildCaseCover(String coverSource) {
    if (coverSource.startsWith('http')) {
      return Image.network(
        coverSource,
        height: 120.h,
        width: double.infinity,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => Container(
          height: 120.h,
          width: double.infinity,
          color: CaseLibraryColors.bgCream,
          child: const Center(child: Icon(Icons.broken_image)),
        ),
      );
    } else {
      return Image.asset(
        coverSource,
        height: 120.h,
        width: double.infinity,
        fit: BoxFit.cover,
      );
    }
  }

  Widget _buildInfoChip(String label) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
      decoration: BoxDecoration(
        color: const Color(0xFFF2F4F3),
        borderRadius: BorderRadius.circular(6.r),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 9.5.sp,
          fontWeight: FontWeight.bold,
          color: const Color(0xFF5A615C),
        ),
      ),
    );
  }
}
