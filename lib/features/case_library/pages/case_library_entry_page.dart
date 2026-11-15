import 'dart:async';
import 'dart:ui' show ImageFilter;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:preamble/features/case_library/data/case_library_data.dart';
import 'package:preamble/features/case_library/models/case_library_models.dart';
import 'package:preamble/features/case_library/pages/case_dossier_detail_page.dart';
import 'package:preamble/features/case_library/pages/case_library_hall_page.dart';
import 'package:preamble/features/case_library/pages/case_library_hall_selection_page.dart';
import 'package:preamble/features/case_library/pages/case_netizen_chat_room_page.dart';
import 'package:preamble/features/case_library/pages/case_library_search_page.dart';
import 'package:preamble/features/case_library/theme/case_library_theme.dart';
import 'package:preamble/features/case_library/widgets/case_library_scaffold.dart';
import 'package:preamble/features/case_library/data/case_library_repository.dart';
import 'package:preamble/features/case_library/data/case_library_image_resolver.dart';
import 'package:preamble/components/shared/shimmer_skeleton.dart';
import 'package:cached_network_image/cached_network_image.dart';

// 定義導覽圖示的 SVG 字串。
const String _svgBackIcon = '''
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" width="24" height="24" fill="none" stroke="#1B3F38" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round">
  <polyline points="15 18 9 12 15 6"></polyline>
</svg>
''';

const String _svgSearchIcon = '''
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" width="24" height="24" fill="none" stroke="#1B3F38" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round">
  <circle cx="11" cy="11" r="8"></circle>
  <line x1="21" y1="21" x2="16.65" y2="16.65"></line>
</svg>
''';

// 精選案件 ID 列表，供 Hero 輪播使用（最多 6 張）
const _heroIds = ['318', '799', '103', '101', 'hung-2013', 'cheng-2021'];

// 各分館對應的案件 ID（年代館、議題館、精選必讀）
const _eraShelfIds = ['318', '799', '499', '520', 'hung-2013', 'ding-2015'];
const _topicShelfIds = ['101', '103', '102', 'cheng-2021', '104', '318'];
const _classicShelfIds = ['318', '101', '103', '799', 'hung-2013', '499'];

// 每個案件的討論數 mock 數據
const _discussionCounts = {
  '318': 142,
  '799': 245,
  '499': 158,
  '520': 340,
  '103': 89,
  '101': 203,
  'hung-2013': 167,
  'cheng-2021': 78,
};

// 有投票功能的案件 ID
const _hasVoteIds = {'318', '799', '103', '101'};

class CaseLibraryEntryPage extends StatefulWidget {
  const CaseLibraryEntryPage({super.key, this.initialCaseId});
  final String? initialCaseId;

  @override
  State<CaseLibraryEntryPage> createState() => _CaseLibraryEntryPageState();
}

class _CaseLibraryEntryPageState extends State<CaseLibraryEntryPage> {
  // 書架精選案件清單，由原本的寫死 ID 改為動態智慧推薦。
  List<CaseBook> _heroBooks = [];
  bool _heroLoading = true;
  String _selectedTopicTag = '🔥 社會矚目';
  static const List<String> _topicFilterChips = [
    '🔥 社會矚目',
    '🔍 世紀疑案',
    '⚖️ 逆轉平反',
    '📜 憲政地標',
    '💼 生活裁判',
  ];

  // 討論室數據，跨頁面共享
  final Map<String, List<int>> _caseVotes = {
    '318': [142, 103],
    '799': [245, 312],
    '499': [158, 290],
    '520': [340, 120],
    '161': [12, 228],
    '124': [88, 42],
  };
  final Map<String, List<Map<String, dynamic>>> _netizenComments = {};

  @override
  void initState() {
    super.initState();
    _loadHeroCases();
  }

  Future<void> _loadHeroCases({String? tag}) async {
    try {
      final activeTag = tag ?? _selectedTopicTag;
      final books = CaseLibraryRepository.instance.getRecommendedCases(
        topicTag: activeTag,
        limit: 6,
      );
      if (mounted) {
        setState(() {
          final initId = widget.initialCaseId;
          if (initId != null) {
            final existIdx = books.indexWhere((b) => b.id == initId);
            if (existIdx != -1) {
              final item = books.removeAt(existIdx);
              books.insert(0, item);
            } else {
              final initBook =
                  CaseLibraryRepository.instance.getCaseById(initId);
              books.insert(0, initBook);
            }
          }
          _heroBooks = books;
          _heroLoading = false;
        });
      }
    } catch (e) {
      print('Error loading hero cases: $e');
      if (mounted) {
        setState(() {
          _heroLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _openHall(BuildContext context, String hallId) {
    Navigator.of(context).push(
      CupertinoPageRoute<void>(
        builder: (__) => CaseLibraryHallPage(hall: caseLibraryHallById(hallId)),
      ),
    );
  }

  void _openSelection(BuildContext context) {
    Navigator.of(context).push(
      CupertinoPageRoute<void>(
        builder: (__) => const CaseLibraryHallSelectionPage(),
      ),
    );
  }

  void _openCaseDetail(BuildContext context, CaseBook book) {
    Navigator.of(context).push(
      CupertinoPageRoute<void>(
        builder: (__) => CaseDossierDetailPage(book: book),
      ),
    );
  }

  void _openChatRoom(BuildContext context, CaseBook book) {
    Navigator.of(context).push(
      CupertinoPageRoute<void>(
        builder: (__) => CaseNetizenChatRoomPage(
          book: book,
          caseVotes: _caseVotes,
          netizenComments: _netizenComments,
        ),
      ),
    );
  }

  void _openSearch(BuildContext context) {
    Navigator.of(context).push(
      CupertinoPageRoute<void>(
        builder: (__) => const CaseLibrarySearchPage(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return CaseLibraryScaffold(
      scene: CaseLibraryScene.entry,
      showBackButton: false,
      useSafeArea: false,
      child: Container(
        color: const Color(0xFFFAF8F5), // 暖米色背景
        child: SafeArea(
          bottom: false,
          child: Column(
            children: [
              // 自訂導航標題欄 (對齊設計圖：左側返回箭頭、中間標題與副標題、右側搜尋 icon)
              Padding(
                padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 4.h),
                child: SizedBox(
                  width: double.infinity,
                  height: 56.h,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Positioned(
                        left: 0,
                        child: IconButton(
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                          icon: Icon(
                            Icons.arrow_back_ios_new_rounded,
                            size: 20.sp,
                            color: const Color(0xFF17231F),
                          ),
                          onPressed: () => Navigator.of(context).pop(),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 48.w),
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                '案件圖書館',
                                style: TextStyle(
                                  fontFamily: 'Songti TC',
                                  fontSize: 20.sp,
                                  fontWeight: FontWeight.normal, // 主標不要粗體字
                                  color: const Color(0xFF17231F),
                                ),
                              ),
                              SizedBox(height: 2.h),
                              Text(
                                '閱讀・討論・思辨臺灣重大案件',
                                style: TextStyle(
                                  fontSize: 9.5.sp,
                                  color: CaseLibraryColors.textMuted,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Positioned(
                        right: 0,
                        child: IconButton(
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                          icon: Icon(
                            Icons.search,
                            size: 24.sp,
                            color: const Color(0xFF17231F),
                          ),
                          onPressed: () => _openSearch(context),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // 主內容 ListView
              Expanded(
                child: ListView(
                  padding: EdgeInsets.fromLTRB(16.w, 10.h, 16.w, 40.h),
                  children: [
                    // 1. 每日精選 (輪播卡片)
                    _buildDailySelectionCarousel(context),

                    SizedBox(height: 24.h),

                    // 2. 專題場館 (年代館、主題館、經典館)
                    _buildSpecialPavilions(context),

                    SizedBox(height: 28.h),

                    // 3. 近期熱議 (卡片列表)
                    _buildRecentDiscussions(context),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 焦點案件推薦輪播區塊
  Widget _buildDailySelectionCarousel(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '焦點案件探索',
              style: TextStyle(
                fontSize: 17.sp,
                fontWeight: FontWeight.w800,
                color: const Color(0xFF1C3A27),
              ),
            ),
            Text(
              '共 ${_heroBooks.length} 案精選',
              style: TextStyle(
                fontSize: 11.sp,
                color: CaseLibraryColors.textMuted,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        SizedBox(height: 10.h),

        // 焦點探索 Filter Chips
        SizedBox(
          height: 34.h,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: _topicFilterChips.length,
            separatorBuilder: (_, __) => SizedBox(width: 8.w),
            itemBuilder: (context, index) {
              final tag = _topicFilterChips[index];
              final isSelected = tag == _selectedTopicTag;
              return GestureDetector(
                onTap: () {
                  if (_selectedTopicTag != tag) {
                    setState(() {
                      _selectedTopicTag = tag;
                    });
                    _loadHeroCases(tag: tag);
                  }
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding:
                      EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? const Color(0xFF1B3F38)
                        : Colors.white,
                    borderRadius: BorderRadius.circular(20.r),
                    border: Border.all(
                      color: isSelected
                          ? const Color(0xFF1B3F38)
                          : const Color(0xFFE2E8E4),
                      width: 1.2,
                    ),
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: const Color(0xFF1B3F38)
                                  .withValues(alpha: 0.18),
                              blurRadius: 6,
                              offset: const Offset(0, 2),
                            )
                          ]
                        : null,
                  ),
                  child: Center(
                    child: Text(
                      tag,
                      style: TextStyle(
                        fontSize: 11.5.sp,
                        fontWeight:
                            isSelected ? FontWeight.bold : FontWeight.w600,
                        color: isSelected
                            ? Colors.white
                            : const Color(0xFF2C3E35),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        SizedBox(height: 12.h),

        if (_heroBooks.isEmpty)
          SizedBox(
            height: 240.h,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              physics: const NeverScrollableScrollPhysics(),
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              itemCount: 3,
              separatorBuilder: (_, __) => SizedBox(width: 12.w),
              itemBuilder: (_, __) => ShimmerSkeleton(
                width: 300.w,
                height: 240.h,
                borderRadius: 24,
              ),
            ),
          )
        else
          SizedBox(
            height: 250.h,
            child: PageView.builder(
              controller: PageController(viewportFraction: 0.85),
              physics: const BouncingScrollPhysics(),
              itemCount: _heroBooks.length,
              itemBuilder: (context, index) {
                final book = _heroBooks[index];
                final coverSource = _getCaseCoverImage(book, index);

                final yearChip = '${book.year}年';
                final locationChip =
                    book.location.isNotEmpty ? book.location : '臺灣';
                final statusChip =
                    book.status.isNotEmpty ? book.status : '已審結';

                return GestureDetector(
                  onTap: () => _openCaseDetail(context, book),
                  child: Container(
                    margin:
                        EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
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
                                  ],
                                ),
                                SizedBox(height: 8.h),
                                Text(
                                  book.titleZh,
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
                                  book.shortDescription.isNotEmpty
                                      ? book.shortDescription
                                      : book.oneSentenceSummary,
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
              },
            ),
          ),
      ],
    );
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
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          fontSize: 9.5.sp,
          fontWeight: FontWeight.bold,
          color: const Color(0xFF334A42),
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

  // 專題場館與司法專題館藏區塊
  Widget _buildSpecialPavilions(BuildContext context) {
    final portals = caseLibraryHalls
        .where((h) => h.type == CaseLibraryHallType.portal)
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '🏛️ 司法專題館藏',
              style: TextStyle(
                fontSize: 17.sp,
                fontWeight: FontWeight.w800,
                color: const Color(0xFF1C3A27),
              ),
            ),
            GestureDetector(
              onTap: () => _openSelection(context),
              child: Row(
                children: [
                  Text(
                    '全部專題 (${portals.length})',
                    style: TextStyle(
                      fontSize: 11.sp,
                      fontWeight: FontWeight.bold,
                      color: CaseLibraryColors.accentGold,
                    ),
                  ),
                  SizedBox(width: 2.w),
                  Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: 10.sp,
                    color: CaseLibraryColors.accentGold,
                  ),
                ],
              ),
            ),
          ],
        ),
        SizedBox(height: 12.h),

        // 1. 司法專題館藏橫向滑動卡片
        SizedBox(
          height: 118.h,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            itemCount: portals.length,
            separatorBuilder: (_, __) => SizedBox(width: 10.w),
            itemBuilder: (context, index) {
              final portal = portals[index];
              final color = portal.accentColorValue != null
                  ? Color(portal.accentColorValue!)
                  : const Color(0xFF2E5E4E);

              return GestureDetector(
                onTap: () => _openHall(context, portal.id),
                child: Container(
                  width: 200.w,
                  padding: EdgeInsets.all(12.w),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14.r),
                    border: Border.all(
                      color: color.withValues(alpha: 0.22),
                      width: 1.2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.04),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 6.w, vertical: 2.h),
                            decoration: BoxDecoration(
                              color: color.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(4.r),
                            ),
                            child: Text(
                              portal.badge ?? '專題館藏',
                              style: TextStyle(
                                fontSize: 9.sp,
                                fontWeight: FontWeight.bold,
                                color: color,
                              ),
                            ),
                          ),
                          const Spacer(),
                          Text(
                            '${portal.shelves.length} 書架',
                            style: TextStyle(
                              fontSize: 9.5.sp,
                              color: CaseLibraryColors.textMuted,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 8.h),
                      Text(
                        portal.name,
                        style: TextStyle(
                          fontSize: 13.sp,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF17231F),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        portal.description,
                        style: TextStyle(
                          fontSize: 10.sp,
                          color: const Color(0xFF5A615C),
                          height: 1.3,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),

        SizedBox(height: 14.h),

        // 2. 年代大事紀、重大刑案、憲政人權 3 大核心維度
        Row(
          children: [
            Expanded(
              child: _buildPavilionCard(
                context,
                title: '年代大事紀',
                gradientColors: const [Color(0xFF5E8B75), Color(0xFF7FA893)],
                icon: Icons.timeline_rounded,
                onTap: () => _openHall(context, 'timeline'),
              ),
            ),
            SizedBox(width: 8.w),
            Expanded(
              child: _buildPavilionCard(
                context,
                title: '重大刑案館',
                gradientColors: const [Color(0xFF8B5E63), Color(0xFFA87E83)],
                icon: Icons.shield_rounded,
                onTap: () => _openHall(context, 'portal-criminal-safety'),
              ),
            ),
            SizedBox(width: 8.w),
            Expanded(
              child: _buildPavilionCard(
                context,
                title: '憲政人權館',
                gradientColors: const [Color(0xFF5E738B), Color(0xFF7E92A8)],
                icon: Icons.account_balance_rounded,
                onTap: () => _openHall(context, 'portal-constitutional'),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPavilionCard(
    BuildContext context, {
    required String title,
    required List<Color> gradientColors,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 120.h,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16.r),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: gradientColors,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                color: Colors.white,
                size: 24.sp,
              ),
              SizedBox(height: 6.h),
              Text(
                title,
                style: TextStyle(
                  fontSize: 16.sp, // 放大字體
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 近期熱議區塊
  Widget _buildRecentDiscussions(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '近期熱議',
              style: TextStyle(
                fontSize: 17.sp,
                fontWeight: FontWeight.w800,
                color: const Color(0xFF1C3A27),
              ),
            ),
            GestureDetector(
              onTap: () {
                _openHall(context, 'theme');
              },
              child: Text(
                '查看全部',
                style: TextStyle(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF2C5E43),
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 12.h),
        _buildRecentDiscussionCard(
          context,
          tag: '#居住正義',
          tagColor: const Color(0xFF8FA89B), // 莫蘭迪粉綠
          time: '5小時前',
          title: '居住正義：租屋補貼法源探索',
          snippet: '內政部最新修正草案解析，針對租賃市場透明化與補貼機制之法律效力進行深度評估...',
          imageAsset: 'assets/images/case_library_v2/recent_housing.png',
          onTap: () => _openCaseDetail(
            context,
            CaseLibraryRepository.instance.getCaseById('case-029'),
          ),
        ),
        SizedBox(height: 12.h),
        _buildRecentDiscussionCard(
          context,
          tag: '#勞動權益',
          tagColor: const Color(0xFFAB8E8F), // 莫蘭迪玫瑰粉
          time: '昨天',
          title: '數位平台與勞動契約爭議',
          snippet: '外送平台夥伴之法律見解，探討承攬與雇傭關係在數位經濟下的新型態法律界定...',
          imageAsset: 'assets/images/case_library_v2/recent_labor.png',
          onTap: () => _openCaseDetail(
            context,
            CaseLibraryRepository.instance.getCaseById(
              'case-delivery-labor-2152',
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRecentDiscussionCard(
    BuildContext context, {
    required String tag,
    required Color tagColor,
    required String time,
    required String title,
    required String snippet,
    required String imageAsset,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Padding(
          padding: EdgeInsets.all(12.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 8.w, vertical: 3.h),
                              decoration: BoxDecoration(
                                color: tagColor.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(6.r),
                              ),
                              child: Text(
                                tag,
                                style: TextStyle(
                                  fontSize: 9.5.sp,
                                  fontWeight: FontWeight.bold,
                                  color: tagColor,
                                ),
                              ),
                            ),
                            SizedBox(width: 8.w),
                            Text(
                              time,
                              style: TextStyle(
                                fontSize: 10.sp,
                                color: const Color(0xFF8B928D),
                              ),
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
                          snippet,
                          style: TextStyle(
                            fontSize: 11.sp,
                            color: const Color(0xFF5A615C),
                            height: 1.4,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: 12.w),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12.r),
                    child: Image.asset(
                      imageAsset,
                      width: 76.w,
                      height: 76.w,
                      fit: BoxFit.cover,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 8.h),
              const Divider(color: Color(0xFFE6E2D8), height: 1),
              SizedBox(height: 8.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '閱讀全文',
                    style: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF17231F),
                    ),
                  ),
                  Icon(
                    Icons.arrow_forward_rounded,
                    size: 16.sp,
                    color: const Color(0xFF17231F),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// 三大館藏導覽卡 Widget
class _DirectoryCard extends StatelessWidget {
  const _DirectoryCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(14.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(color: color.withValues(alpha: 0.35), width: 1.2),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: EdgeInsets.all(8.w),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 20.w),
            ),
            SizedBox(height: 12.h),
            Text(
              title,
              style: TextStyle(
                fontSize: 13.5.sp,
                fontWeight: FontWeight.w900,
                color: const Color(0xFF1C3A27),
              ),
            ),
            SizedBox(height: 2.h),
            Text(
              subtitle,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 9.5.sp,
                height: 1.35,
                color: CaseLibraryColors.textMuted,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HotSearchMarquee extends StatefulWidget {
  const _HotSearchMarquee({required this.queries, required this.onTap});
  final List<String> queries;
  final ValueChanged<String> onTap;

  @override
  State<_HotSearchMarquee> createState() => _HotSearchMarqueeState();
}

class _HotSearchMarqueeState extends State<_HotSearchMarquee> {
  int _currentIndex = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 4), (timer) {
      if (mounted) {
        setState(() {
          _currentIndex = (_currentIndex + 1) % widget.queries.length;
        });
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.queries.isEmpty) return const SizedBox.shrink();
    final query = widget.queries[_currentIndex];
    return GestureDetector(
      onTap: () => widget.onTap(query),
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 500),
        transitionBuilder: (child, animation) {
          return FadeTransition(
            opacity: animation,
            child: SlideTransition(
              position: animation.drive(
                Tween<Offset>(
                  begin: const Offset(0, 0.3),
                  end: Offset.zero,
                ).chain(CurveTween(curve: Curves.easeOut)),
              ),
              child: child,
            ),
          );
        },
        child: Text(
          '熱搜：$query',
          key: ValueKey<String>(query),
          style: TextStyle(
            fontSize: 10.5.sp,
            color: CaseLibraryColors.primaryGreen,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}

class _CuratedBookCard extends StatelessWidget {
  const _CuratedBookCard({required this.book, required this.onTap});
  final CaseBook book;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final accentColor = _getCategoryColor(book.category);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 140.w,
        margin: EdgeInsets.only(right: 12.w, bottom: 4.h),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 6.r,
              offset: const Offset(0, 3),
            ),
          ],
          border: Border.all(
            color: CaseLibraryColors.borderLight,
            width: 0.8,
          ),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12.r),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 48.h,
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      accentColor,
                      accentColor.withValues(alpha: 0.75),
                    ],
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(
                          horizontal: 4.w, vertical: 1.5.h),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(3.r),
                      ),
                      child: Text(
                        book.category,
                        style: TextStyle(
                          fontSize: 8.sp,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Text(
                      '${book.year}',
                      style: TextStyle(
                        fontSize: 9.sp,
                        color: Colors.white.withValues(alpha: 0.9),
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Padding(
                  padding: EdgeInsets.all(10.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        book.titleZh,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 11.sp,
                          height: 1.3,
                          fontWeight: FontWeight.w900,
                          color: const Color(0xFF1B3F38),
                        ),
                      ),
                      Text(
                        book.oneSentenceSummary,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 8.5.sp,
                          height: 1.3,
                          color: CaseLibraryColors.textSecondary,
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

  Color _getCategoryColor(String cat) {
    const map = {
      '車禍賠償': Color(0xFF4A7C8C),
      '借款返還': Color(0xFF6D649A),
      '租屋糾紛': Color(0xFF8C4A5A),
      '給付價金': Color(0xFF357A53),
      '不當解雇': Color(0xFF9E7B2D),
      '離婚親權': Color(0xFF8C5C4A),
      '竊盜': Color(0xFF5C5C45),
      '傷害': Color(0xFF7A3535),
    };
    return map[cat] ?? CaseLibraryColors.primaryGreen;
  }
}

class _ThreeDStackedCarousel extends StatefulWidget {
  const _ThreeDStackedCarousel({
    required this.books,
    required this.onBookTap,
    required this.onChatTap,
  });

  final List<CaseBook> books;
  final ValueChanged<CaseBook> onBookTap;
  final ValueChanged<CaseBook> onChatTap;

  @override
  State<_ThreeDStackedCarousel> createState() => _ThreeDStackedCarouselState();
}

class _ThreeDStackedCarouselState extends State<_ThreeDStackedCarousel> {
  late PageController _pageController;
  double _currentPage = 0.0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(viewportFraction: 0.82);
    _pageController.addListener(() {
      if (mounted) {
        setState(() {
          _currentPage = _pageController.page ?? 0.0;
        });
      }
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  String _getUnsplashImageUrl(String category, String id) {
    const images = {
      '車禍賠償':
          'https://images.unsplash.com/photo-1518364538800-6bcb3f25da49?q=80&w=400&auto=format&fit=crop',
      '借款返還':
          'https://images.unsplash.com/photo-1554224155-8d04cb21cd6c?q=80&w=400&auto=format&fit=crop',
      '租屋糾紛':
          'https://images.unsplash.com/photo-1560518883-ce09059eeffa?q=80&w=400&auto=format&fit=crop',
      '給付價金':
          'https://images.unsplash.com/photo-1454165804606-c3d57bc86b40?q=80&w=400&auto=format&fit=crop',
      '不當解雇':
          'https://images.unsplash.com/photo-1521791136368-1a869372658b?q=80&w=400&auto=format&fit=crop',
      '離婚親權':
          'https://images.unsplash.com/photo-1516627145497-ae6968895b74?q=80&w=400&auto=format&fit=crop',
      '竊盜':
          'https://images.unsplash.com/photo-1508962914676-134849a727f0?q=80&w=400&auto=format&fit=crop',
      '傷害':
          'https://images.unsplash.com/photo-1505664194779-8beaceb93744?q=80&w=400&auto=format&fit=crop',
    };

    if (id == '318') {
      return 'https://images.unsplash.com/photo-1589829545856-d10d557cf95f?q=80&w=400&auto=format&fit=crop';
    }
    if (id == '799') {
      return 'https://images.unsplash.com/photo-1450133064473-71024230f91b?q=80&w=400&auto=format&fit=crop';
    }

    return images[category] ??
        'https://images.unsplash.com/photo-1447069387593-a5de0862481e?q=80&w=400&auto=format&fit=crop';
  }

  @override
  Widget build(BuildContext context) {
    if (widget.books.isEmpty) return const SizedBox.shrink();
    final cardWidth = MediaQuery.of(context).size.width * 0.82;

    return SizedBox(
      height: cardWidth + 12.h,
      child: PageView.builder(
        controller: _pageController,
        physics: const BouncingScrollPhysics(),
        itemCount: widget.books.length,
        itemBuilder: (context, index) {
          final book = widget.books[index];

          final difference = (index - _currentPage);
          final scale = (1 - (difference.abs() * 0.08)).clamp(0.88, 1.0);
          final opacity = (1 - (difference.abs() * 0.35)).clamp(0.6, 1.0);

          return Transform.scale(
            scale: scale,
            child: Opacity(
              opacity: opacity,
              child: _buildCarouselCard(book, cardWidth),
            ),
          );
        },
      ),
    );
  }

  Widget _buildCarouselCard(CaseBook book, double cardWidth) {
    final discussionCount = (book.id.hashCode % 80 + 10).abs();
    final hasActiveVote = book.id == '318' ||
        book.id == '799' ||
        book.id == '103' ||
        book.id == '101';
    final accentColor = _getCategoryColor(book.category);
    final bgImageUrl = _getUnsplashImageUrl(book.category, book.id);

    return Container(
      margin: EdgeInsets.symmetric(vertical: 6.h, horizontal: 4.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 12.r,
            offset: const Offset(0, 6),
          ),
        ],
      ),
child: ClipRRect(
        borderRadius: BorderRadius.circular(16.r),
        child: Stack(
          children: [
            Positioned.fill(
              child: CachedNetworkImage(
                imageUrl: bgImageUrl,
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
            ),
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withValues(alpha: 0.2),
                      Colors.transparent,
                      Colors.transparent,
                    ],
                    stops: const [0.0, 0.4, 1.0],
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              height: cardWidth * 0.46,
              child: ClipRRect(
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(16.r),
                  bottomRight: Radius.circular(16.r),
                ),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                  child: Container(
                    color: Colors.white.withValues(alpha: 0.72),
                    padding: EdgeInsets.fromLTRB(14.w, 10.h, 14.w, 10.h),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 7.w, vertical: 2.h),
                              decoration: BoxDecoration(
                                color: accentColor.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(4.r),
                              ),
                              child: Text(
                                book.category,
                                style: TextStyle(
                                  fontSize: 8.5.sp,
                                  fontWeight: FontWeight.bold,
                                  color: accentColor,
                                ),
                              ),
                            ),
                            Text(
                              '${book.year} 年',
                              style: TextStyle(
                                fontSize: 10.sp,
                                fontWeight: FontWeight.bold,
                                color: CaseLibraryColors.accentGold,
                              ),
                            ),
                          ],
                        ),
                        Text(
                          book.titleZh,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 13.5.sp,
                            fontWeight: FontWeight.w900,
                            color: const Color(0xFF1B3F38),
                          ),
                        ),
                        Text(
                          book.oneSentenceSummary,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 10.sp,
                            height: 1.35,
                            fontWeight: FontWeight.w500,
                            color: CaseLibraryColors.textSecondary,
                          ),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            GestureDetector(
                              onTap: () => widget.onChatTap(book),
                              child: Container(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 8.w, vertical: 4.h),
                                decoration: BoxDecoration(
                                  color: accentColor.withValues(alpha: 0.08),
                                  borderRadius: BorderRadius.circular(6.r),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.forum_outlined,
                                      size: 11.sp,
                                      color: accentColor,
                                    ),
                                    SizedBox(width: 4.w),
                                    Text(
                                      '$discussionCount 討論',
                                      style: TextStyle(
                                        fontSize: 9.sp,
                                        fontWeight: FontWeight.bold,
                                        color: accentColor,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                if (hasActiveVote) ...[
                                  GestureDetector(
                                    onTap: () => widget.onChatTap(book),
                                    child: Container(
                                      padding: EdgeInsets.symmetric(
                                          horizontal: 8.w, vertical: 5.h),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFFAF6EE),
                                        borderRadius:
                                            BorderRadius.circular(6.r),
                                        border: Border.all(
                                          color: CaseLibraryColors.accentGold
                                              .withValues(alpha: 0.35),
                                          width: 0.8,
                                        ),
                                      ),
                                      child: Text(
                                        '投票',
                                        style: TextStyle(
                                          fontSize: 9.5.sp,
                                          fontWeight: FontWeight.bold,
                                          color: CaseLibraryColors.accentGold,
                                        ),
                                      ),
                                    ),
                                  ),
                                  SizedBox(width: 6.w),
                                ],
                                ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor:
                                        CaseLibraryColors.primaryGreen,
                                    foregroundColor: Colors.white,
                                    elevation: 0,
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 10.w, vertical: 5.h),
                                    minimumSize: Size.zero,
                                    tapTargetSize:
                                        MaterialTapTargetSize.shrinkWrap,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(6.r),
                                    ),
                                  ),
                                  onPressed: () => widget.onBookTap(book),
                                  child: Text(
                                    '研讀案卷',
                                    style: TextStyle(
                                      fontSize: 9.5.sp,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getCategoryColor(String cat) {
    const map = {
      '車禍賠償': Color(0xFF4A7C8C),
      '借款返還': Color(0xFF6D649A),
      '租屋糾紛': Color(0xFF8C4A5A),
      '給付價金': Color(0xFF357A53),
      '不當解雇': Color(0xFF9E7B2D),
      '離婚親權': Color(0xFF8C5C4A),
      '竊盜': Color(0xFF5C5C45),
      '傷害': Color(0xFF7A3535),
    };
    return map[cat] ?? CaseLibraryColors.primaryGreen;
  }
}

class _LandmarkSpotlights extends StatelessWidget {
  const _LandmarkSpotlights({required this.books, required this.onCaseTap});

  final List<CaseBook> books;
  final ValueChanged<CaseBook> onCaseTap;

  @override
  Widget build(BuildContext context) {
    final landmarks = books
        .where((b) =>
            b.id == '318' ||
            b.id == '799' ||
            b.id == '103' ||
            b.id == '101' ||
            b.id == 'hung-2013')
        .toList();

    if (landmarks.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '重大焦點案卷',
          style: TextStyle(
            fontSize: 15.sp,
            fontWeight: FontWeight.w900,
            color: CaseLibraryColors.primaryGreen,
          ),
        ),
        SizedBox(height: 12.h),
        for (final book in landmarks) ...[
          Container(
            margin: EdgeInsets.only(bottom: 12.h),
            padding: EdgeInsets.all(14.w),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14.r),
              border: Border.all(color: const Color(0xFFE6E2D8)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.01),
                  blurRadius: 8.r,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 6.w, vertical: 2.h),
                            decoration: BoxDecoration(
                              color: CaseLibraryColors.accentGold
                                  .withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(4.r),
                            ),
                            child: Text(
                              '重大焦點',
                              style: TextStyle(
                                fontSize: 9.sp,
                                color: CaseLibraryColors.accentGold,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          SizedBox(width: 8.w),
                          Text(
                            '${book.year} 年 • ${book.category}',
                            style: TextStyle(
                              fontSize: 10.sp,
                              color: CaseLibraryColors.textMuted,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 8.h),
                      Text(
                        book.titleZh,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 13.5.sp,
                          fontWeight: FontWeight.w900,
                          color: const Color(0xFF1C3A27),
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        book.shortDescription,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 11.sp,
                          color: CaseLibraryColors.textSecondary,
                          height: 1.4,
                        ),
                      ),
                      SizedBox(height: 8.h),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: book.tags
                              .map((t) => Container(
                                    margin: EdgeInsets.only(right: 6.w),
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 6.w, vertical: 2.h),
                                    decoration: BoxDecoration(
                                      color: CaseLibraryColors.primaryGreen
                                          .withValues(alpha: 0.05),
                                      borderRadius: BorderRadius.circular(4.r),
                                    ),
                                    child: Text(
                                      '#$t',
                                      style: TextStyle(
                                        fontSize: 8.5.sp,
                                        color: CaseLibraryColors.primaryGreen,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ))
                              .toList(),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 12.w),
                GestureDetector(
                  onTap: () => onCaseTap(book),
                  child: Container(
                    padding: EdgeInsets.all(10.w),
                    decoration: BoxDecoration(
                      color:
                          CaseLibraryColors.primaryGreen.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.arrow_forward_ios_rounded,
                      color: CaseLibraryColors.primaryGreen,
                      size: 14.w,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}
