import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:preamble/features/case_library/models/case_library_models.dart';
import 'package:preamble/features/case_library/data/case_library_image_resolver.dart';
import 'package:preamble/features/case_library/pages/case_dossier_detail_page.dart';
import 'package:preamble/features/case_library/pages/case_library_search_page.dart';
import 'package:preamble/features/case_library/theme/case_library_theme.dart';
import 'package:preamble/features/case_library/widgets/case_library_scaffold.dart';
import 'package:preamble/components/shared/shimmer_skeleton.dart';
import 'package:cached_network_image/cached_network_image.dart';
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

  // Portal State
  String _selectedPortalShelfId = 'all';

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
        // 年代、經典、審判狀態館：從倉庫與書架定義收集真實裁判筆數進行展示
        final books =
            await CaseLibraryRepository.instance.getCasesPaginated(60, 0);
        final shelfCaseIds = <String>{};
        for (final shelf in widget.hall.shelves) {
          shelfCaseIds.addAll(shelf.caseIds);
        }
        for (final id in shelfCaseIds) {
          final b = CaseLibraryRepository.instance.getCaseById(id);
          if (b.titleZh != '案件載入中...' && !books.any((x) => x.id == b.id)) {
            books.add(b);
          }
        }
        if (mounted) {
          setState(() {
            _allCases = books;
            _isLoading = false;
          });
        }
      } else if (widget.hall.type == CaseLibraryHallType.portal) {
        // 司法專題館：從該專題的所有子書架與精選案中動態收集全部實體指標案件
        final portalCaseIds = <String>{};
        for (final shelf in widget.hall.shelves) {
          portalCaseIds.addAll(shelf.caseIds);
        }
        if (widget.hall.featuredCaseId != null) {
          portalCaseIds.add(widget.hall.featuredCaseId!);
        }

        final List<CaseBook> books = [];
        for (final id in portalCaseIds) {
          books.add(CaseLibraryRepository.instance.getCaseById(id));
        }
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
      case CaseLibraryHallType.portal:
        content = _buildPortalView(context);
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
              // 為了在各種尺寸螢幕上保持標題置中且絕不溢出，
              // 左右保留按鈕安全內距，並以 FittedBox 搭配單行縮放自適應長標題。
              Padding(
                padding: EdgeInsets.fromLTRB(6.w, 8.h, 18.w, 8.h),
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
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 48.w),
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            widget.hall.type == CaseLibraryHallType.theme
                                ? '依議題探索'
                                : widget.hall.name,
                            maxLines: 1,
                            style:
                                CaseLibraryTextStyles.pageTitle(context).copyWith(
                              fontSize: 18.sp,
                              fontWeight: FontWeight.w900,
                              color: CaseLibraryColors.primaryGreen,
                            ),
                          ),
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
      CaseLibraryHallType.portal => CaseLibraryScene.classic,
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
        : CaseLibraryRepository.instance.getCaseById('499');

    // Representative list cases (others)
    final representativeCases = _allCases.length > 1
        ? _allCases.skip(1).toList()
        : CaseLibraryRepository.instance.getRecommendedCases(limit: 6).skip(1).toList();

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
        // 優先從該書架已註冊的真實案例提取，確保不空置
        final shelfCaseBooks = <CaseBook>[];
        for (final id in shelf.caseIds) {
          final b = CaseLibraryRepository.instance.getCaseById(id);
          if (b.titleZh != '案件載入中...' && !shelfCaseBooks.any((x) => x.id == b.id)) {
            shelfCaseBooks.add(b);
          }
        }

        var shelfCases = shelfCaseBooks;
        if (shelfCases.isEmpty) {
          final lowerName = shelf.name.toLowerCase();
          shelfCases = _allCases.where((c) {
            return c.status.toLowerCase().contains(lowerName) ||
                c.category.toLowerCase().contains(lowerName) ||
                c.basicInfo.procedureStage.toLowerCase().contains(lowerName) ||
                c.basicInfo.courtLevel.toLowerCase().contains(lowerName);
          }).toList();
        }

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
                Expanded(
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                    decoration: BoxDecoration(
                      color: bgColor,
                      borderRadius: BorderRadius.circular(4.r),
                    ),
                    child: Text(
                      shelf.description,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 9.5.sp,
                        color: accentColor,
                        fontWeight: FontWeight.w800,
                      ),
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

  // --- 5. WIKIPEDIA PORTAL VIEW (維基專題門戶) ---
  Widget _buildPortalView(BuildContext context) {
    final hall = widget.hall;
    final accentColor = hall.accentColorValue != null
        ? Color(hall.accentColorValue!)
        : CaseLibraryColors.primaryGreen;

    // Featured case
    CaseBook? featuredBook;
    if (hall.featuredCaseId != null) {
      final found =
          _allCases.where((c) => c.id == hall.featuredCaseId).toList();
      featuredBook = found.isNotEmpty
          ? found.first
          : CaseLibraryRepository.instance.getCaseById(hall.featuredCaseId!);
    }

    // Active shelf
    final isAll = _selectedPortalShelfId == 'all';
    final activeShelf = isAll
        ? null
        : hall.shelves.firstWhere(
            (s) => s.id == _selectedPortalShelfId,
            orElse: () => hall.shelves.first,
          );

    final displayCases = isAll
        ? _allCases
        : _allCases.where((c) => activeShelf!.caseIds.contains(c.id)).toList();

    return ListView(
      padding: EdgeInsets.fromLTRB(18.w, 4.h, 18.w, 24.h),
      children: [
        // 1. 維基專題門戶導讀卡（Wikipedia Portal Lead Card）
        Container(
          padding: EdgeInsets.all(16.w),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(
              color: accentColor.withValues(alpha: 0.25),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: accentColor.withValues(alpha: 0.06),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
                    decoration: BoxDecoration(
                      color: accentColor.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(6.r),
                    ),
                    child: Text(
                      hall.badge ?? '司法專題館',
                      style: TextStyle(
                        fontSize: 10.5.sp,
                        fontWeight: FontWeight.w900,
                        color: accentColor,
                      ),
                    ),
                  ),
                  const Spacer(),
                  Text(
                    '收錄 ${hall.shelves.fold<int>(0, (sum, s) => sum + s.caseIds.length)} 案・${hall.shelves.length} 大分類',
                    style: TextStyle(
                      fontSize: 10.sp,
                      color: CaseLibraryColors.textMuted,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 10.h),
              Text(
                hall.name,
                style: TextStyle(
                  fontSize: 17.sp,
                  fontWeight: FontWeight.w900,
                  color: const Color(0xFF17231F),
                ),
              ),
              if (hall.leadMission != null && hall.leadMission!.isNotEmpty) ...[
                SizedBox(height: 6.h),
                Text(
                  hall.leadMission!,
                  style: TextStyle(
                    fontSize: 11.5.sp,
                    color: const Color(0xFF4A5568),
                    height: 1.5,
                  ),
                ),
              ],
              if (hall.portalTags.isNotEmpty) ...[
                SizedBox(height: 10.h),
                Wrap(
                  spacing: 6.w,
                  runSpacing: 4.h,
                  children: hall.portalTags.map((tag) {
                    return Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF0F4F2),
                        borderRadius: BorderRadius.circular(4.r),
                      ),
                      child: Text(
                        '#$tag',
                        style: TextStyle(
                          fontSize: 9.5.sp,
                          color: const Color(0xFF2E5E4E),
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ],
          ),
        ),
        SizedBox(height: 16.h),

        // 2. 專題子分類書架標籤切換列（Sub-shelves Taxonomy Tabs）
        SizedBox(
          height: 36.h,
          child: ListView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            children: [
              GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedPortalShelfId = 'all';
                  });
                },
                child: Container(
                  padding:
                      EdgeInsets.symmetric(horizontal: 14.w, vertical: 6.h),
                  margin: EdgeInsets.only(right: 8.w),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: isAll ? accentColor : Colors.white,
                    borderRadius: BorderRadius.circular(18.r),
                    border: Border.all(
                      color: isAll ? accentColor : CaseLibraryColors.borderLight,
                    ),
                  ),
                  child: Text(
                    '全部典藏 (${_allCases.length})',
                    style: TextStyle(
                      fontSize: 11.5.sp,
                      fontWeight: FontWeight.w800,
                      color: isAll ? Colors.white : CaseLibraryColors.textSecondary,
                    ),
                  ),
                ),
              ),
              ...hall.shelves.map((shelf) {
                final isSelected = shelf.id == _selectedPortalShelfId;
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedPortalShelfId = shelf.id;
                    });
                  },
                  child: Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: 14.w, vertical: 6.h),
                    margin: EdgeInsets.only(right: 8.w),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: isSelected ? accentColor : Colors.white,
                      borderRadius: BorderRadius.circular(18.r),
                      border: Border.all(
                        color: isSelected
                            ? accentColor
                            : CaseLibraryColors.borderLight,
                      ),
                    ),
                    child: Text(
                      '${shelf.name} (${shelf.caseIds.length})',
                      style: TextStyle(
                        fontSize: 11.5.sp,
                        fontWeight: FontWeight.w800,
                        color: isSelected
                            ? Colors.white
                            : CaseLibraryColors.textSecondary,
                      ),
                    ),
                  ),
                );
              }),
            ],
          ),
        ),
        SizedBox(height: 16.h),

        // 3. 專題精選指標代表條目（當在全部標籤且有精選案時）
        if (isAll && featuredBook != null) ...[
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [accentColor, accentColor.withValues(alpha: 0.85)],
              ),
              borderRadius:
                  BorderRadius.circular(CaseLibraryRadii.radiusLarge.r),
              boxShadow: [CaseLibraryShadows.cardShadow],
            ),
            child: Padding(
              padding: EdgeInsets.all(16.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: 8.w, vertical: 3.h),
                        decoration: BoxDecoration(
                          color: const Color(0xFFD4AF37),
                          borderRadius: BorderRadius.circular(4.r),
                        ),
                        child: Text(
                          '⭐ 焦點指標大案',
                          style: TextStyle(
                            fontSize: 10.sp,
                            fontWeight: FontWeight.w900,
                            color: const Color(0xFF261D00),
                          ),
                        ),
                      ),
                      const Spacer(),
                      Text(
                        '${featuredBook.year} 年裁判',
                        style: TextStyle(
                          fontSize: 11.sp,
                          color: Colors.white.withValues(alpha: 0.85),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 10.h),
                  Text(
                    featuredBook.titleZh,
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      height: 1.3,
                    ),
                  ),
                  SizedBox(height: 6.h),
                  Text(
                    featuredBook.shortDescription.isNotEmpty
                        ? featuredBook.shortDescription
                        : featuredBook.oneSentenceSummary,
                    style: TextStyle(
                      fontSize: 11.5.sp,
                      color: Colors.white.withValues(alpha: 0.9),
                      height: 1.45,
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 14.h),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: accentColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        padding: EdgeInsets.symmetric(vertical: 8.h),
                      ),
                      icon: Icon(Icons.menu_book_rounded, size: 16.sp),
                      label: const Text(
                        '研讀判決檔案詳情 ➔',
                        style: TextStyle(fontWeight: FontWeight.w900),
                      ),
                      onPressed: () => _openCaseDetail(context, featuredBook!),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 20.h),
        ],

        // 4. 書架標題（若在特定子書架下）
        if (!isAll && activeShelf != null) ...[
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
                activeShelf.name,
                style: CaseLibraryTextStyles.sectionTitle(context).copyWith(
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w900,
                  color: CaseLibraryColors.primaryGreen,
                ),
              ),
              SizedBox(width: 8.w),
              Expanded(
                child: Text(
                  activeShelf.description,
                  style: TextStyle(
                    fontSize: 10.5.sp,
                    color: CaseLibraryColors.textMuted,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
        ] else if (isAll) ...[
          Text(
            '本門戶收錄條目典藏',
            style: CaseLibraryTextStyles.sectionTitle(context).copyWith(
              fontSize: 15.sp,
              fontWeight: FontWeight.w900,
              color: CaseLibraryColors.primaryGreen,
            ),
          ),
          SizedBox(height: 12.h),
        ],

        // 5. 案件條目列表
        for (int i = 0; i < displayCases.length; i++) ...[
          _buildAlignedCaseCard(context, displayCases[i], i),
          SizedBox(height: 12.h),
        ],
      ],
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
                        Flexible(
                          child: _buildInfoChip(statusChip),
                        ),
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
      return SizedBox(
        height: 120.h,
        width: double.infinity,
        child: CachedNetworkImage(
          imageUrl: coverSource,
          fit: BoxFit.cover,
          placeholder: (context, url) => const ShimmerSkeleton(
            width: double.infinity,
            height: double.infinity,
            borderRadius: 0,
          ),
          errorWidget: (context, url, error) => Image.asset(
            'assets/images/case_library_v2/case_library_v2_case_book_cover.png',
            fit: BoxFit.cover,
          ),
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
      padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.5.h),
      decoration: BoxDecoration(
        color: const Color(0xFFF2F4F3),
        borderRadius: BorderRadius.circular(4.r),
      ),
      child: Text(
        label,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          fontSize: 9.5.sp,
          fontWeight: FontWeight.bold,
          color: const Color(0xFF5A615C),
        ),
      ),
    );
  }
}
