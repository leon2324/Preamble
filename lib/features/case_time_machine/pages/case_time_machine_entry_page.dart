import 'dart:async';

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
import 'package:lawapp/features/case_time_machine/widgets/case_library_active_case_card.dart';
import 'package:lawapp/features/case_time_machine/widgets/case_library_category_exploration.dart';
import 'package:lawapp/features/case_time_machine/widgets/case_time_machine_scaffold.dart';
import 'package:lawapp/features/case_time_machine/data/case_time_machine_repository.dart';
import 'package:lawapp/features/case_time_machine/widgets/immersive_bookshelf.dart';

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
  int _heroIndex = 0;

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
                    // 1. 搜尋引擎入口區塊 (為 10 萬案件引流)
                    _buildSearchEngineSection(context),

                    // 2. 3D 沉浸式書架區塊
                    _heroLoading
                        ? const Center(
                            child: CupertinoActivityIndicator(
                              radius: 14,
                              color: CaseTimeMachineColors.primaryGreen,
                            ),
                          )
                        : Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              ImmersiveBookshelf(
                                books: _heroBooks,
                                compact: true,
                                onBookTap: (book) {
                                  setState(() {
                                    _heroIndex = _heroBooks.indexOf(book);
                                  });
                                },
                              ),
                              SizedBox(height: 16.h),
                              // 顯示當前「抽出來的案件之書」的詳細資訊卡與入口
                              if (_heroBooks.isNotEmpty && _heroIndex < _heroBooks.length) ...[
                                Text(
                                  '已抽出案件之書：',
                                  style: TextStyle(
                                    fontSize: 11.5.sp,
                                    fontWeight: FontWeight.bold,
                                    color: CaseTimeMachineColors.primaryGreen,
                                  ),
                                ),
                                SizedBox(height: 8.h),
                                CaseLibraryHeroCard(
                                  book: _heroBooks[_heroIndex],
                                  discussionCount: _discussionCounts[_heroBooks[_heroIndex].id] ??
                                      (_heroBooks[_heroIndex].id.hashCode % 80 + 10).abs(),
                                  hasActiveVote: _hasVoteIds.contains(_heroBooks[_heroIndex].id) ||
                                      (_heroBooks[_heroIndex].id.hashCode % 3 == 0),
                                  onReadDossierTap: () =>
                                      _openCaseDetail(context, _heroBooks[_heroIndex]),
                                  onJoinDiscussionTap: () =>
                                      _openChatRoom(context, _heroBooks[_heroIndex]),
                                ),
                              ],
                            ],
                          ),


                    SizedBox(height: 24.h),

                    // 4. 圖書館分館探索區塊
                    CaseLibraryCategoryExploration(
                      onOpenHall: (hallId) => _openHall(context, hallId),
                      onViewAllTap: () => _openSelection(context),
                    ),

                    SizedBox(height: 24.h),

                    // 5. 檢索館藏目錄格線區塊 (年代 / 議題 / 法院 / 網友思辨)
                    _buildDirectoryCards(context),

                    SizedBox(height: 28.h),

                    // 6. 熱門思辨案例 - 本地 SQLite 異步分頁加載饋送 (Infinite Scroll Feed)
                    _FactualCaseFeed(
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

  // 全局搜尋引擎 Banner 區塊
  Widget _buildSearchEngineSection(BuildContext context) {
    return GestureDetector(
      onTap: () => _openSearch(context),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
        margin: EdgeInsets.only(bottom: 20.h),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14.r),
          border: Border.all(color: const Color(0xFFE6E2D8)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(Icons.search_rounded, color: CaseTimeMachineColors.morandiGreen, size: 20.w),
            SizedBox(width: 12.w),
            Text(
              '搜尋 10 萬件真實裁判與法理案卷...',
              style: TextStyle(
                fontSize: 12.5.sp,
                color: CaseTimeMachineColors.textMuted,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 檢索館藏目錄導覽卡
  Widget _buildDirectoryCards(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '檢索館藏目錄',
          style: TextStyle(
            fontSize: 15.sp,
            fontWeight: FontWeight.w900,
            color: CaseTimeMachineColors.primaryGreen,
          ),
        ),
        SizedBox(height: 12.h),
        Row(
          children: [
            Expanded(
              child: _DirectoryCard(
                title: '年代紀元',
                subtitle: '歷年司法軌跡',
                icon: Icons.history_toggle_off_rounded,
                color: CaseTimeMachineColors.morandiBlue,
                onTap: () => _openHall(context, 'timeline'),
              ),
            ),
            SizedBox(width: 10.w),
            Expanded(
              child: _DirectoryCard(
                title: '法律議題',
                subtitle: '民刑與憲政爭議',
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
                subtitle: '審級裁判體系',
                icon: Icons.account_balance_rounded,
                color: CaseTimeMachineColors.morandiGold,
                onTap: () => _openHall(context, 'classic'),
              ),
            ),
            SizedBox(width: 10.w),
            Expanded(
              child: _DirectoryCard(
                title: '思辨討論',
                subtitle: '與網友法庭對質',
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
              style: TextStyle(
                fontSize: 10.sp,
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

// 本地 SQLite 異步分頁 Feed
class _FactualCaseFeed extends StatefulWidget {
  const _FactualCaseFeed({required this.onCaseTap});
  final Function(CaseBook) onCaseTap;

  @override
  State<_FactualCaseFeed> createState() => _FactualCaseFeedState();
}

class _FactualCaseFeedState extends State<_FactualCaseFeed> {
  final List<CaseBook> _loadedCases = [];
  int _offset = 0;
  bool _loading = false;
  bool _hasMore = true;
  final int _limit = 10;

  @override
  void initState() {
    super.initState();
    _loadMore();
  }

  Future<void> _loadMore() async {
    if (_loading || !_hasMore) return;
    if (mounted) setState(() => _loading = true);

    try {
      final newCases = await CaseTimeMachineRepository.instance.getCasesPaginated(_limit, _offset);
      if (newCases.length < _limit) {
        _hasMore = false;
      }
      if (mounted) {
        setState(() {
          _loadedCases.addAll(newCases);
          _offset += newCases.length;
        });
      }
    } catch (e) {
      print('Error loading paginated cases: $e');
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '熱門思辨案例',
              style: TextStyle(
                fontSize: 15.sp,
                fontWeight: FontWeight.w900,
                color: CaseTimeMachineColors.primaryGreen,
              ),
            ),
            Text(
              '已加載 ${_loadedCases.length} 案',
              style: TextStyle(
                fontSize: 11.sp,
                color: CaseTimeMachineColors.textMuted,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        SizedBox(height: 12.h),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _loadedCases.length + (_hasMore ? 1 : 0),
          itemBuilder: (context, index) {
            if (index == _loadedCases.length) {
              return Padding(
                padding: EdgeInsets.symmetric(vertical: 12.h),
                child: Center(
                  child: _loading
                      ? const CupertinoActivityIndicator()
                      : TextButton(
                          onPressed: _loadMore,
                          child: Text(
                            '點擊加載更多案例...',
                            style: TextStyle(
                              fontSize: 12.sp,
                              color: CaseTimeMachineColors.morandiGreen,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                ),
              );
            }

            final book = _loadedCases[index];
            return Container(
              margin: EdgeInsets.only(bottom: 12.h),
              padding: EdgeInsets.all(14.w),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14.r),
                border: Border.all(color: const Color(0xFFE6E2D8)),
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
                                color: CaseTimeMachineColors.morandiGreen.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(6.r),
                              ),
                              child: Text(
                                book.category,
                                style: TextStyle(
                                  fontSize: 9.sp,
                                  color: CaseTimeMachineColors.morandiGreen,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            SizedBox(width: 8.w),
                            Text(
                              '${book.year} 年',
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
                            fontWeight: FontWeight.w800,
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
                      ],
                    ),
                  ),
                  SizedBox(width: 12.w),
                  GestureDetector(
                    onTap: () => widget.onCaseTap(book),
                    child: Container(
                      padding: EdgeInsets.all(10.w),
                      decoration: BoxDecoration(
                        color: CaseTimeMachineColors.morandiGreen.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.arrow_forward_ios_rounded,
                        color: CaseTimeMachineColors.morandiGreen,
                        size: 14.w,
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }
}
