import 'dart:async';
import 'dart:ui' show ImageFilter;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
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
      final books =
          await CaseTimeMachineRepository.instance.getCasesPaginated(6, 0);
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
                  CaseTimeMachineRepository.instance.getCaseById(initId);
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
                      Column(
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

  // 每日精選輪播區塊
  Widget _buildDailySelectionCarousel(BuildContext context) {
    if (_heroBooks.isEmpty) {
      return SizedBox(
        height: 240.h,
        child: const Center(
          child: CupertinoActivityIndicator(
            color: CaseTimeMachineColors.primaryGreen,
          ),
        ),
      );
    }

    final carouselBooks = _heroBooks.take(4).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '每日精選',
          style: TextStyle(
            fontSize: 17.sp,
            fontWeight: FontWeight.w800,
            color: const Color(0xFF1C3A27),
          ),
        ),
        SizedBox(height: 12.h),
        SizedBox(
          height: 250.h,
          child: PageView.builder(
            controller: PageController(viewportFraction: 0.85),
            physics: const BouncingScrollPhysics(),
            itemCount: carouselBooks.length,
            itemBuilder: (context, index) {
              final book = carouselBooks[index];
              
              String imageAsset = 'assets/images/case_time_machine_v2/ctm_v2_case_book_cover.png';
              if (index == 0) {
                imageAsset = 'assets/images/case_time_machine_v2/daily_hunting.png';
              } else if (index == 1) {
                imageAsset = 'assets/images/case_time_machine_v2/daily_remote_work.png';
              } else if (index == 2) {
                imageAsset = 'assets/images/case_time_machine_v2/daily_rent_subsidy.png';
              } else if (index == 3) {
                imageAsset = 'assets/images/case_time_machine_v2/daily_gig_platform.png';
              }

              String yearChip = '${book.year}年';
              String locationChip = index % 2 == 0 ? '台北' : '高雄';
              String statusChip = index % 2 == 0 ? '已定讞' : '審理中';

              return GestureDetector(
                onTap: () => _openCaseDetail(context, book),
                child: Container(
                  margin: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
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
                        Image.asset(
                          imageAsset,
                          height: 120.h,
                          width: double.infinity,
                          fit: BoxFit.cover,
                        ),
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
                                book.shortDescription,
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
        style: TextStyle(
          fontSize: 9.5.sp,
          fontWeight: FontWeight.bold,
          color: const Color(0xFF5A615C),
        ),
      ),
    );
  }

  // 專題場館區塊
  Widget _buildSpecialPavilions(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '專題場館',
          style: TextStyle(
            fontSize: 17.sp,
            fontWeight: FontWeight.w800,
            color: const Color(0xFF1C3A27),
          ),
        ),
        SizedBox(height: 12.h),
        Row(
          children: [
            Expanded(
              child: _buildPavilionCard(
                context,
                title: '年代館',
                imagePath: 'assets/images/case_time_machine_v2/ctm_v2_era_emblem.png',
                icon: Icons.edit_note_rounded,
                onTap: () => _openHall(context, 'timeline'),
              ),
            ),
            SizedBox(width: 8.w),
            Expanded(
              child: _buildPavilionCard(
                context,
                title: '主題館',
                imagePath: 'assets/images/case_time_machine_v2/ctm_v2_theme_emblem.png',
                icon: Icons.account_balance_rounded,
                onTap: () => _openHall(context, 'theme'),
              ),
            ),
            SizedBox(width: 8.w),
            Expanded(
              child: _buildPavilionCard(
                context,
                title: '經典館',
                imagePath: 'assets/images/case_time_machine_v2/ctm_v2_classic_emblem.png',
                icon: Icons.auto_awesome_rounded,
                onTap: () => _openHall(context, 'classic'),
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
    required String imagePath,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 120.h,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16.r),
          child: Stack(
            children: [
              Positioned.fill(
                child: Image.asset(
                  imagePath,
                  fit: BoxFit.cover,
                ),
              ),
              Positioned.fill(
                child: Container(
                  color: Colors.black.withValues(alpha: 0.35),
                ),
              ),
              Center(
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
          imageAsset: 'assets/images/case_time_machine_v2/recent_housing.png',
          onTap: () {
            if (_heroBooks.isNotEmpty) {
              _openCaseDetail(context, _heroBooks.first);
            }
          },
        ),

        SizedBox(height: 12.h),

        _buildRecentDiscussionCard(
          context,
          tag: '#勞動權益',
          tagColor: const Color(0xFFAB8E8F), // 莫蘭迪玫瑰粉
          time: '昨天',
          title: '數位平台與勞動契約爭議',
          snippet: '外送平台夥伴之法律見解，探討承攬與雇傭關係在數位經濟下的新型態法律界定...',
          imageAsset: 'assets/images/case_time_machine_v2/recent_labor.png',
          onTap: () {
            if (_heroBooks.length > 1) {
              _openCaseDetail(context, _heroBooks[1]);
            }
          },
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
                              padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
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
                                          color: CaseTimeMachineColors
                                              .accentGold
                                              .withValues(alpha: 0.35),
                                          width: 0.8,
                                        ),
                                      ),
                                      child: Text(
                                        '投票',
                                        style: TextStyle(
                                          fontSize: 9.5.sp,
                                          fontWeight: FontWeight.bold,
                                          color:
                                              CaseTimeMachineColors.accentGold,
                                        ),
                                      ),
                                    ),
                                  ),
                                  SizedBox(width: 6.w),
                                ],
                                ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor:
                                        CaseTimeMachineColors.primaryGreen,
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
    return map[cat] ?? CaseTimeMachineColors.primaryGreen;
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
                            padding: EdgeInsets.symmetric(
                                horizontal: 6.w, vertical: 2.h),
                            decoration: BoxDecoration(
                              color: CaseTimeMachineColors.accentGold
                                  .withValues(alpha: 0.1),
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
                          children: book.tags
                              .map((t) => Container(
                                    margin: EdgeInsets.only(right: 6.w),
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 6.w, vertical: 2.h),
                                    decoration: BoxDecoration(
                                      color: CaseTimeMachineColors.primaryGreen
                                          .withValues(alpha: 0.05),
                                      borderRadius: BorderRadius.circular(4.r),
                                    ),
                                    child: Text(
                                      '#$t',
                                      style: TextStyle(
                                        fontSize: 8.5.sp,
                                        color:
                                            CaseTimeMachineColors.primaryGreen,
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
                      color: CaseTimeMachineColors.primaryGreen
                          .withValues(alpha: 0.1),
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
