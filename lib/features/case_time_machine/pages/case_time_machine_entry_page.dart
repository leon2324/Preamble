import 'dart:async';
import 'dart:ui' show ImageFilter;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:lawapp/features/case_time_machine/data/case_time_machine_mock_data.dart';
import 'package:lawapp/features/case_time_machine/models/case_time_machine_models.dart';
import 'package:lawapp/features/case_time_machine/pages/case_dossier_detail_page.dart';
import 'package:lawapp/features/case_time_machine/pages/case_library_hall_page.dart';
import 'package:lawapp/features/case_time_machine/pages/case_library_hall_selection_page.dart';
import 'package:lawapp/features/case_time_machine/pages/case_netizen_chat_room_page.dart';
import 'package:lawapp/features/case_time_machine/pages/case_time_machine_search_page.dart';
import 'package:lawapp/features/case_time_machine/theme/case_time_machine_theme.dart';
import 'package:lawapp/features/case_time_machine/widgets/case_time_machine_scaffold.dart';
import 'package:lawapp/features/case_time_machine/data/case_time_machine_repository.dart';

// 台灣繁體中文教學註解：
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

// 台灣繁體中文教學註解：
// 精選案件 ID 列表，供 Hero 輪播使用（最多 6 張）
const _heroIds = ['318', '799', '103', '101', 'hung-2013', 'cheng-2021'];

// 台灣繁體中文教學註解：
// 各分館對應的案件 ID（年代館、議題館、精選必讀）
const _eraShelfIds = ['318', '799', '499', '520', 'hung-2013', 'ding-2015'];
const _topicShelfIds = ['101', '103', '102', 'cheng-2021', '104', '318'];
const _classicShelfIds = ['318', '101', '103', '799', 'hung-2013', '499'];

// 台灣繁體中文教學註解：每個案件的討論數 mock 數據
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

// 台灣繁體中文教學註解：有投票功能的案件 ID
const _hasVoteIds = {'318', '799', '103', '101'};

class CaseTimeMachineEntryPage extends StatefulWidget {
  const CaseTimeMachineEntryPage({super.key, this.initialCaseId});
  final String? initialCaseId;

  @override
  State<CaseTimeMachineEntryPage> createState() =>
      _CaseTimeMachineEntryPageState();
}

class _CaseTimeMachineEntryPageState extends State<CaseTimeMachineEntryPage> {
  // 台灣繁體中文教學註解：
  // 書架精選案件清單，由原本的寫死 ID 改為動態拉取 Supabase。
  List<CaseBook> _heroBooks = [];
  bool _heroLoading = true;

  // 台灣繁體中文教學註解：討論室數據，跨頁面共享
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

  Future<void> _loadHeroCases() async {
    try {
      // 動態載入前 6 筆真實案件（以對接 Supabase 10,000 筆真實資料）
      final books = await CaseTimeMachineRepository.instance.getCasesPaginated(6, 0);
      if (mounted) {
        setState(() {
          final initId = widget.initialCaseId;
          if (initId != null) {
            final existIdx = books.indexWhere((b) => b.id == initId);
            if (existIdx != -1) {
              final item = books.removeAt(existIdx);
              books.insert(0, item);
            } else {
              final initBook = CaseTimeMachineRepository.instance.getCaseById(initId);
              books.insert(0, initBook);
            }
          }
          _heroBooks = books;
          _heroLoading = false;
        });
      }
    } catch (e) {
      print('Error loading hero cases dynamically: $e');
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
        builder: (__) =>
            CaseLibraryHallPage(hall: caseTimeMachineHallById(hallId)),
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
        builder: (__) => const CaseTimeMachineSearchPage(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return CaseTimeMachineScaffold(
      scene: CaseTimeMachineScene.entry,
      showBackButton: false,
      useSafeArea: false,
      child: Container(
        color: CaseTimeMachineColors.bgCream,
        child: SafeArea(
          bottom: false,
          child: Column(
            children: [
              // 台灣繁體中文教學註解：
              // 自訂導航標題欄與搜尋入口
              Padding(
                padding: EdgeInsets.fromLTRB(10.w, 8.h, 10.w, 4.h),
                child: SizedBox(
                  width: double.infinity,
                  height: 48.h,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Positioned(
                        left: 0,
                        child: IconButton(
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                          icon: SvgPicture.string(_svgBackIcon,
                              width: 20.w, height: 20.w),
                          onPressed: () => Navigator.of(context).pop(),
                        ),
                      ),
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            '案件圖書館',
                            style: CaseTimeMachineTextStyles.pageTitle(context)
                                .copyWith(
                              fontSize: 17.sp,
                              color: CaseTimeMachineColors.primaryGreen,
                            ),
                          ),
                          SizedBox(height: 1.h),
                          Text(
                            '閱讀・討論・思辨臺灣重大案件',
                            style: TextStyle(
                              fontSize: 9.5.sp,
                              color: CaseTimeMachineColors.textMuted,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      Positioned(
                        right: 0,
                        child: IconButton(
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                          icon: SvgPicture.string(_svgSearchIcon,
                              width: 22.w, height: 22.w),
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
                    // 熱搜跑馬燈條
                    Container(
                      height: 32.h,
                      margin: EdgeInsets.only(bottom: 16.h),
                      padding: EdgeInsets.symmetric(horizontal: 12.w),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF7F5F0),
                        borderRadius: BorderRadius.circular(20.r),
                        border: Border.all(
                          color: CaseTimeMachineColors.borderLight,
                          width: 0.8,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.trending_up_rounded,
                            size: 14.sp,
                            color: CaseTimeMachineColors.accentGold,
                          ),
                          SizedBox(width: 8.w),
                          Expanded(
                            child: _HotSearchMarquee(
                              queries: const ['318 太陽花', '釋字 799 號', '幼兒園案', '集會自由', '車禍過失'],
                              onTap: (q) {
                                Navigator.of(context).push(
                                  CupertinoPageRoute<void>(
                                    builder: (__) => CaseTimeMachineSearchPage(initialQuery: q),
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),

                    // 1. 矚目大案聚焦 (3D 疊加縮放輪播)
                    _heroLoading
                        ? SizedBox(
                            height: 180.h,
                            child: const Center(
                              child: CupertinoActivityIndicator(
                                radius: 14,
                                color: CaseTimeMachineColors.primaryGreen,
                              ),
                            ),
                          )
                        : Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '矚目大案聚焦',
                                style: TextStyle(
                                  fontSize: 15.sp,
                                  fontWeight: FontWeight.w900,
                                  color: CaseTimeMachineColors.primaryGreen,
                                ),
                              ),
                              SizedBox(height: 12.h),
                              _ThreeDStackedCarousel(
                                books: _heroBooks,
                                onBookTap: (book) => _openCaseDetail(context, book),
                                onChatTap: (book) => _openChatRoom(context, book),
                              ),
                            ],
                          ),

                    SizedBox(height: 16.h),

                    // 2. 檢索館藏目錄格線區塊 (年代 / 議題 / 法院 / 網友思辨)
                    _buildDirectoryCards(context),

                    SizedBox(height: 24.h),

                    // 2.5 館長今日推薦 (Curated Bookcase)
                    _buildCuratedBookcase(context),

                    SizedBox(height: 24.h),

                    // 3. 重大焦點案卷 (取代原本普通小案 feed)
                    _heroLoading
                        ? const Center(child: CupertinoActivityIndicator())
                        : _LandmarkSpotlights(
                            books: _heroBooks,
                            onCaseTap: (book) => _openCaseDetail(context, book),
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


  // 檢索館藏目錄導覽卡
  Widget _buildDirectoryCards(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '檢索館藏目錄',
              style: TextStyle(
                fontSize: 15.sp,
                fontWeight: FontWeight.w900,
                color: CaseTimeMachineColors.primaryGreen,
              ),
            ),
            GestureDetector(
              onTap: () {
                if (_heroBooks.isNotEmpty) {
                  final listCopy = List<CaseBook>.from(_heroBooks);
                  listCopy.shuffle();
                  _openCaseDetail(context, listCopy.first);
                }
              },
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
                decoration: BoxDecoration(
                  color: const Color(0xFFF7F5F0),
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(
                    color: CaseTimeMachineColors.accentGold.withValues(alpha: 0.3),
                    width: 0.8,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.casino_outlined,
                      size: 13.w,
                      color: CaseTimeMachineColors.accentGold,
                    ),
                    SizedBox(width: 4.w),
                    Text(
                      '隨機選書',
                      style: TextStyle(
                        fontSize: 11.sp,
                        fontWeight: FontWeight.w900,
                        color: CaseTimeMachineColors.accentGold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 12.h),
        Row(
          children: [
            Expanded(
              child: _DirectoryCard(
                title: '年代紀元',
                subtitle: '收錄 1950 至今歷年人權與法治軌跡',
                icon: Icons.history_toggle_off_rounded,
                color: CaseTimeMachineColors.morandiBlue,
                onTap: () => _openHall(context, 'timeline'),
              ),
            ),
            SizedBox(width: 10.w),
            Expanded(
              child: _DirectoryCard(
                title: '法律議題',
                subtitle: '聚焦車禍、租屋、解雇等 8 大核心爭議',
                icon: Icons.gavel_rounded,
                color: CaseTimeMachineColors.morandiGreen,
                onTap: () => _openHall(context, 'theme'),
              ),
            ),
          ],
        ),
        SizedBox(height: 10.h),
        Row(
          children: [
            Expanded(
              child: _DirectoryCard(
                title: '法院層級',
                subtitle: '橫跨地院至最高法院裁判',
                icon: Icons.account_balance_rounded,
                color: CaseTimeMachineColors.morandiGold,
                onTap: () => _openHall(context, 'classic'),
              ),
            ),
            SizedBox(width: 10.w),
            Expanded(
              child: _DirectoryCard(
                title: '思辨討論',
                subtitle: '參與觀點對質，投下關鍵票',
                icon: Icons.forum_rounded,
                color: CaseTimeMachineColors.morandiLavender,
                onTap: () => _openSelection(context),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCuratedBookcase(BuildContext context) {
    if (_heroBooks.isEmpty) return const SizedBox.shrink();

    // 取 4 筆不同的案件作為館長今日推薦（過濾掉 318 學運，讓其他大案露臉）
    final curatedBooks = _heroBooks.where((b) => b.id != '318').take(4).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '館長今日推薦',
          style: TextStyle(
            fontSize: 15.sp,
            fontWeight: FontWeight.w900,
            color: CaseTimeMachineColors.primaryGreen,
          ),
        ),
        SizedBox(height: 12.h),
        SizedBox(
          height: 145.h,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            itemCount: curatedBooks.length,
            itemBuilder: (context, index) {
              final book = curatedBooks[index];
              return _CuratedBookCard(
                book: book,
                onTap: () => _openCaseDetail(context, book),
              );
            },
          ),
        ),
      ],
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
                color: CaseTimeMachineColors.textMuted,
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
            color: CaseTimeMachineColors.primaryGreen,
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
            color: CaseTimeMachineColors.borderLight,
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
                      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.5.h),
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
                          color: CaseTimeMachineColors.textSecondary,
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
    return map[cat] ?? CaseTimeMachineColors.primaryGreen;
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
      '車禍賠償': 'https://images.unsplash.com/photo-1518364538800-6bcb3f25da49?q=80&w=400&auto=format&fit=crop',
      '借款返還': 'https://images.unsplash.com/photo-1554224155-8d04cb21cd6c?q=80&w=400&auto=format&fit=crop',
      '租屋糾紛': 'https://images.unsplash.com/photo-1560518883-ce09059eeffa?q=80&w=400&auto=format&fit=crop',
      '給付價金': 'https://images.unsplash.com/photo-1454165804606-c3d57bc86b40?q=80&w=400&auto=format&fit=crop',
      '不當解雇': 'https://images.unsplash.com/photo-1521791136368-1a869372658b?q=80&w=400&auto=format&fit=crop',
      '離婚親權': 'https://images.unsplash.com/photo-1516627145497-ae6968895b74?q=80&w=400&auto=format&fit=crop',
      '竊盜': 'https://images.unsplash.com/photo-1508962914676-134849a727f0?q=80&w=400&auto=format&fit=crop',
      '傷害': 'https://images.unsplash.com/photo-1505664194779-8beaceb93744?q=80&w=400&auto=format&fit=crop',
    };
    
    if (id == '318') {
      return 'https://images.unsplash.com/photo-1589829545856-d10d557cf95f?q=80&w=400&auto=format&fit=crop';
    }
    if (id == '799') {
      return 'https://images.unsplash.com/photo-1450133064473-71024230f91b?q=80&w=400&auto=format&fit=crop';
    }

    return images[category] ?? 'https://images.unsplash.com/photo-1447069387593-a5de0862481e?q=80&w=400&auto=format&fit=crop';
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
    final hasActiveVote = book.id == '318' || book.id == '799' || book.id == '103' || book.id == '101';
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
              child: Image.network(
                bgImageUrl,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Image.asset(
                    'assets/images/case_time_machine_v2/ctm_v2_case_book_cover.png',
                    fit: BoxFit.cover,
                  );
                },
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Image.asset(
                    'assets/images/case_time_machine_v2/ctm_v2_case_book_cover.png',
                    fit: BoxFit.cover,
                  );
                },
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
                              padding: EdgeInsets.symmetric(horizontal: 7.w, vertical: 2.h),
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
                                color: CaseTimeMachineColors.accentGold,
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
                            color: CaseTimeMachineColors.textSecondary,
                          ),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            GestureDetector(
                              onTap: () => widget.onChatTap(book),
                              child: Container(
                                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
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
                                      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 5.h),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFFAF6EE),
                                        borderRadius: BorderRadius.circular(6.r),
                                        border: Border.all(
                                          color: CaseTimeMachineColors.accentGold.withValues(alpha: 0.35),
                                          width: 0.8,
                                        ),
                                      ),
                                      child: Text(
                                        '投票',
                                        style: TextStyle(
                                          fontSize: 9.5.sp,
                                          fontWeight: FontWeight.bold,
                                          color: CaseTimeMachineColors.accentGold,
                                        ),
                                      ),
                                    ),
                                  ),
                                  SizedBox(width: 6.w),
                                ],
                                ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: CaseTimeMachineColors.primaryGreen,
                                    foregroundColor: Colors.white,
                                    elevation: 0,
                                    padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
                                    minimumSize: Size.zero,
                                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
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
    return map[cat] ?? CaseTimeMachineColors.primaryGreen;
  }
}

class _LandmarkSpotlights extends StatelessWidget {
  const _LandmarkSpotlights({required this.books, required this.onCaseTap});

  final List<CaseBook> books;
  final ValueChanged<CaseBook> onCaseTap;

  @override
  Widget build(BuildContext context) {
    final landmarks = books.where((b) => b.id == '318' || b.id == '799' || b.id == '103' || b.id == '101' || b.id == 'hung-2013').toList();
    
    if (landmarks.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '重大焦點案卷',
          style: TextStyle(
            fontSize: 15.sp,
            fontWeight: FontWeight.w900,
            color: CaseTimeMachineColors.primaryGreen,
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
                            padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                            decoration: BoxDecoration(
                              color: CaseTimeMachineColors.accentGold.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(4.r),
                            ),
                            child: Text(
                              '重大焦點',
                              style: TextStyle(
                                fontSize: 9.sp,
                                color: CaseTimeMachineColors.accentGold,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          SizedBox(width: 8.w),
                          Text(
                            '${book.year} 年 • ${book.category}',
                            style: TextStyle(
                              fontSize: 10.sp,
                              color: CaseTimeMachineColors.textMuted,
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
                          color: CaseTimeMachineColors.textSecondary,
                          height: 1.4,
                        ),
                      ),
                      SizedBox(height: 8.h),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: book.tags.map((t) => Container(
                            margin: EdgeInsets.only(right: 6.w),
                            padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                            decoration: BoxDecoration(
                              color: CaseTimeMachineColors.primaryGreen.withValues(alpha: 0.05),
                              borderRadius: BorderRadius.circular(4.r),
                            ),
                            child: Text(
                              '#$t',
                              style: TextStyle(
                                fontSize: 8.5.sp,
                                color: CaseTimeMachineColors.primaryGreen,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          )).toList(),
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
                      color: CaseTimeMachineColors.primaryGreen.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.arrow_forward_ios_rounded,
                      color: CaseTimeMachineColors.primaryGreen,
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
