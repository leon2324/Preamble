import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:preamble/components/shared/custom_toast.dart';
import 'package:preamble/components/shared/mvp_state_widgets.dart';
import 'package:preamble/components/shared/law_app_story_action_bar.dart';
import 'package:preamble/components/shared/share_sheet.dart';
import 'package:preamble/theme/app_fonts.dart';
import 'package:preamble/components/shared/liquid_glass_widgets.dart';
import 'package:preamble/features/case_library/data/case_interactive_profiles.dart';
import 'package:preamble/features/case_library/data/case_library_data.dart';
import 'package:preamble/features/case_library/data/case_library_image_resolver.dart';
import 'package:preamble/features/case_library/data/case_library_repository.dart';
import 'package:preamble/features/case_library/data/supabase_case_service.dart';
import 'package:preamble/features/case_library/models/case_library_models.dart';
import 'package:preamble/features/case_library/theme/case_library_theme.dart';
import 'package:preamble/components/shared/shimmer_skeleton.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:preamble/features/case_library/widgets/case_library_svg_icon.dart';
import 'package:preamble/features/case_library/pages/case_library_search_page.dart';
import 'package:preamble/features/case_library/pages/case_netizen_chat_room_page.dart';
import 'package:preamble/features/case_library/pages/case_judge_practice_page.dart';
import 'package:preamble/features/case_library/pages/case_opinion_spectrum_page.dart';
import 'package:preamble/features/case_library/pages/case_legal_vocabulary_page.dart';
import 'package:preamble/features/case_library/pages/case_witness_cross_page.dart';
import 'package:preamble/features/case_library/pages/case_social_graph_page.dart';
import 'package:preamble/features/case_library/pages/case_opinion_board_page.dart';
import 'package:preamble/pages/learning/know_law_page.dart';
import 'package:preamble/features/case_library/pages/case_timeline_detail_page.dart';
import 'package:preamble/features/case_library/widgets/wikipedia_infobox_card.dart';
import 'package:preamble/features/case_library/widgets/wikipedia_table_of_contents.dart';
import 'package:preamble/features/case_library/widgets/wikipedia_wikilink_text.dart';
import 'package:preamble/app/app_state.dart';

part 'widgets/case_dossier_tabs.dart';
part 'widgets/case_dossier_primitives.dart';
part 'widgets/case_dossier_timeline_widgets.dart';
part 'widgets/case_dossier_bottom_sheets.dart';
part 'case_dossier_helper_data.dart';

class LightTextStyles {
  static double multiplier = 1.0;

  static TextStyle displayTitle(BuildContext context) {
    final style = CaseLibraryTextStyles.displayTitle(context);
    return style.copyWith(
      color: CaseLibraryColors.primaryGreen,
      fontSize: (style.fontSize ?? 24.sp) * multiplier,
    );
  }

  static TextStyle pageTitle(BuildContext context) {
    final style = CaseLibraryTextStyles.pageTitle(context);
    return style.copyWith(
      color: CaseLibraryColors.primaryGreen,
      fontSize: (style.fontSize ?? 17.sp) * multiplier,
    );
  }

  static TextStyle sectionTitle(BuildContext context) {
    final style = CaseLibraryTextStyles.sectionTitle(context);
    return style.copyWith(
      color: CaseLibraryColors.primaryGreen,
      fontSize: (style.fontSize ?? 15.sp) * multiplier,
    );
  }

  static TextStyle cardTitle(BuildContext context) {
    final style = CaseLibraryTextStyles.cardTitle(context);
    return style.copyWith(
      color: CaseLibraryColors.textPrimary,
      fontSize: (style.fontSize ?? 13.sp) * multiplier,
    );
  }

  static TextStyle body(BuildContext context) {
    final style = CaseLibraryTextStyles.body(context);
    return style.copyWith(
      color: CaseLibraryColors.textPrimary,
      fontSize: (style.fontSize ?? 13.sp) * multiplier,
    );
  }

  static TextStyle bodySmall(BuildContext context) {
    final style = CaseLibraryTextStyles.bodySmall(context);
    return style.copyWith(
      color: CaseLibraryColors.textSecondary,
      fontSize: (style.fontSize ?? 11.5.sp) * multiplier,
    );
  }

  static TextStyle caption(BuildContext context) {
    final style = CaseLibraryTextStyles.caption(context);
    return style.copyWith(
      color: CaseLibraryColors.textMuted,
      fontSize: (style.fontSize ?? 10.sp) * multiplier,
    );
  }

  static TextStyle chipText(BuildContext context) {
    final style = CaseLibraryTextStyles.chipText(context);
    return style.copyWith(
      color: CaseLibraryColors.accentGold,
      fontSize: (style.fontSize ?? 10.sp) * multiplier,
    );
  }
}

class CaseDossierDetailPage extends StatefulWidget {
  const CaseDossierDetailPage({
    super.key,
    required this.book,
    this.initialTab,
  });

  final CaseBook book;
  final String? initialTab;

  @override
  State<CaseDossierDetailPage> createState() => _CaseDossierDetailPageState();
}

class _CaseDossierDetailPageState extends State<CaseDossierDetailPage> {
  CaseBook? _detailedBook;
  bool _isLoading = true;
  bool _loadFailed = false;

  late String _selectedTab;
  bool _isSaved = false;
  bool _isFollowed = false;
  bool _isTimelineExpanded = false;
  String _timelineFilter = 'all'; // 'all', 'event', 'trial'

  // Apple 閱讀偏好設定
  double _fontSizeMultiplier = 1.0;
  String _readingTint = 'none'; // 'none' (cream), 'cool' (blue), 'warm' (amber)

  late final PageController _galleryController;
  final ScrollController _nestedScrollController = ScrollController();
  int _galleryIndex = 0;

  // 思辨與探索進度、重點爭點收藏、重新整理狀態
  final Set<String> _exploredTools = <String>{};
  final Set<int> _focusedIssueIndices = <int>{};
  DateTime? _lastRefreshedAt;
  bool _isRefreshing = false;

  // 完整判決書與頁籤錨點滾動所使用的 GlobalKey，維持跨 Build 的狀態一致性。
  final GlobalKey _tabSectionKey = GlobalKey();
  final GlobalKey _mainVerdictKey = GlobalKey();
  final GlobalKey _proceduralKey = GlobalKey();
  final GlobalKey _reasoningKey = GlobalKey();
  final GlobalKey _lawsKey = GlobalKey();

  // 定義自訂的 SVG 圖示字串，避免使用 Google Material Icons。
  static const String _svgBackIcon = '''
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" width="24" height="24" fill="none" stroke="#1B3F38" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round">
  <polyline points="15 18 9 12 15 6"></polyline>
</svg>
''';

  static const String _svgForumIcon = '''
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" width="24" height="24" fill="none" stroke="#1B3F38" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
  <path d="M21 15a2 2 0 0 1-2 2H7l-4 4V5a2 2 0 0 1 2-2h14a2 2 0 0 1 2 2z"></path>
</svg>
''';

  // 為「鄉民討論」分頁設計的狀態變數，包含留言輸入控制、立場選擇、各案件的即時投開票數據、以及即時按讚與新增留言的快取。
  final TextEditingController _commentController = TextEditingController();
  String _selectedStance = '中立派';
  final Map<String, String> _myVotes = {};

  // 為了完全排除 LateInitializationError 崩潰風險，直接在聲明時對地圖變數進行初始賦值，不再使用 late 關鍵字。
  final Map<String, List<int>> _caseVotes = {
    '318': [142, 103], // 太陽花學運案件：合理 vs 不合理
    '161': [12, 228], // 幼兒園狼師案件：合理 vs 不合理（絕大多數家長覺得量刑偏輕不合理）
    '124': [88, 42], // 台鐵事故案件
  };

  final Map<String, List<Map<String, dynamic>>> _netizenComments = {
    '318': [
      {
        'avatar': '憲',
        'name': '熱血法學生',
        'time': '10 分鐘前',
        'stance': '合理派',
        'stanceColor': const Color(0xFF2E7D32),
        'content':
            '這個判決是台灣憲政史的里程碑！肯認「公民不服從」作為刑法超法規阻卻違法事由真的不容易。當時的代議制度確實失靈，這是民主防禦的最後防線！',
        'likes': 42,
        'liked': false,
      },
      {
        'avatar': '治',
        'name': '路過的法治派',
        'time': '30 分鐘前',
        'stance': '不合理派',
        'stanceColor': const Color(0xFFC62828),
        'content':
            '法治社會如果每個人都自稱「公民不服從」就去佔領公署，那社會不就亂套了？手段和平不和平每個人標準不同，不認同一二審宣判無罪。',
        'likes': 19,
        'liked': false,
      },
      {
        'avatar': '白',
        'name': '法白忠實讀者',
        'time': '2 小時前',
        'stance': '合理派',
        'stanceColor': const Color(0xFF2E7D32),
        'content':
            '判決書中詳細論證了「最後手段性」與「公益目的性」，黃國昌等人的訴求確實只針對程序問題，且沒有造成不可回復的重大財物損害，我覺得法官寫得非常有說服力。',
        'likes': 28,
        'liked': false,
      },
      {
        'avatar': '理',
        'name': '鍵盤理性人',
        'time': '5 小時前',
        'stance': '中立派',
        'stanceColor': const Color(0xFF757575),
        'content': '無論支持與否，本案開啟了法庭上對於公民抗爭與言論自由邊界的思辨。這才是民主社會該有的討論過程，而不是一味地貼標籤。',
        'likes': 14,
        'liked': false,
      },
    ],
    '161': [
      {
        'avatar': '悲',
        'name': '憤怒的家長',
        'time': '5 分鐘前',
        'stance': '不合理派',
        'stanceColor': const Color(0xFFC62828),
        'content': '這絕對不合理！對幼兒做出這種不可饒恕的事，居然只判這樣？這種惡行應該判終身監禁，永遠不能重回社會！',
        'likes': 156,
        'liked': false,
      },
      {
        'avatar': '律',
        'name': '法理分析師',
        'time': '40 分鐘前',
        'stance': '合理派',
        'stanceColor': const Color(0xFF2E7D32),
        'content':
            '雖然感性上無法接受，但法官量刑受限於罪刑法定原則與刑法加重上限。與其一味罵法官，不如支持立法委員趕快修法，把這種幼兒侵害案件的刑期上限拉高！',
        'likes': 73,
        'liked': false,
      },
      {
        'avatar': '防',
        'name': '保護兒童陣線',
        'time': '2 小時前',
        'stance': '不合理派',
        'stanceColor': const Color(0xFFC62828),
        'content':
            '幼兒園防護網破洞太大了！不僅是涉案人，連園方知情不報的行政責任也太輕，應該要全面公開涉案機構與黑名單，讓家長有知情權。',
        'likes': 95,
        'liked': false,
      },
    ],
  };

  List<String> get _availableTabs {
    final book = _detailedBook ?? widget.book;
    final tabs = <String>[];

    // Core Fixed Tabs (always display to form a consistent wiki structure)
    tabs.add('事件背景');
    tabs.add('事件與訴訟脈絡');
    tabs.add('法律爭點');
    tabs.add('相關法條');
    tabs.add('完整判決書');

    // Optional Dynamic Tabs (only show if data is present in database)
    if (book.people.isNotEmpty) tabs.add('關係人角色');
    if (book.courtReasoning.isNotEmpty ||
        book.courtArguments.isNotEmpty ||
        book.investigationAndTrial.isNotEmpty) {
      tabs.add('裁判心證');
    }
    if (book.socialImpact.isNotEmpty) tabs.add('社會影響');
    if (_getLiteratures(book.id).isNotEmpty) tabs.add('學術文獻');
    if (book.mediaReferences.isNotEmpty) tabs.add('延伸媒體');
    if (book.relatedCases.isNotEmpty) tabs.add('相關案件');

    final hasDiscussions = book.id == '318' ||
        book.id == '161' ||
        book.id == '124' ||
        (_netizenComments[book.id]?.isNotEmpty == true);
    if (hasDiscussions) tabs.add('鄉民討論');

    return tabs;
  }

  @override
  void initState() {
    super.initState();
    LightTextStyles.multiplier = 1.0;
    _galleryController = PageController();

    _isFollowed = book.isFollowing;
    _isSaved = book.isFavorite;

    // 優先初始化預設 Tab，等資料載入完成會再次更新
    final tabs = _availableTabs;
    if (widget.initialTab != null && tabs.contains(widget.initialTab)) {
      _selectedTab = widget.initialTab!;
    } else {
      _selectedTab = tabs.isNotEmpty ? tabs.first : '事件背景';
    }

    _loadDetails();
  }

  Future<void> _loadDetails() async {
    try {
      final detail =
          await CaseLibraryRepository.instance.getCaseDetail(book.id);
      if (mounted) {
        setState(() {
          _detailedBook = detail;
          _isLoading = false;
          _loadFailed = false;
          // 重新計算 Tab，防 Placeholder 空欄位導致 Tab 被隱藏
          final tabs = _availableTabs;
          if (tabs.contains(_selectedTab)) {
            // 保留使用者已切換或正在檢視的分頁
          } else if (widget.initialTab != null &&
              tabs.contains(widget.initialTab)) {
            _selectedTab = widget.initialTab!;
          } else {
            _selectedTab = tabs.isNotEmpty ? tabs.first : '事件背景';
          }
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _loadFailed = SupabaseCaseService.instance.isConfigured;
        });
      }
    }
  }

  void _retryLoadDetails() {
    setState(() {
      _isLoading = true;
      _loadFailed = false;
    });
    _loadDetails();
  }

  Future<void> _refreshDossier() async {
    if (_isRefreshing) return;
    setState(() => _isRefreshing = true);
    HapticFeedback.mediumImpact();
    try {
      await _loadDetails();
      if (mounted) {
        setState(() {
          _lastRefreshedAt = DateTime.now();
        });
      }
    } finally {
      if (mounted) {
        setState(() => _isRefreshing = false);
      }
    }
  }

  void _selectTabAndScroll(String tab) {
    if (!_availableTabs.contains(tab)) return;
    HapticFeedback.selectionClick();
    setState(() {
      _selectedTab = tab;
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final tabContext = _tabSectionKey.currentContext;
      if (tabContext != null) {
        Scrollable.ensureVisible(
          tabContext,
          duration: const Duration(milliseconds: 360),
          curve: Curves.easeOutCubic,
          alignment: 0.0,
        );
      }
    });
  }

  void _scrollToTop() {
    HapticFeedback.selectionClick();
    if (_nestedScrollController.hasClients) {
      _nestedScrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 380),
        curve: Curves.easeOutCubic,
      );
    }
  }

  CaseBook get book => _detailedBook ?? widget.book;

  void _setTimelineExpanded(bool isExpanded) {
    setState(() {
      _isTimelineExpanded = isExpanded;
    });
  }

  void _setTimelineFilter(String filter) {
    setState(() {
      _timelineFilter = filter;
    });
  }

  @override
  void dispose() {
    _galleryController.dispose();
    _nestedScrollController.dispose();
    _commentController.dispose();
    super.dispose();
  }

  void _openRelatedCase(BuildContext context, String caseId) {
    final relatedBook = caseLibraryCaseById(caseId);
    Navigator.of(context).push(
      CupertinoPageRoute<void>(
        builder: (_) => CaseDossierDetailPage(book: relatedBook),
      ),
    );
  }

  Widget _buildLoadingState(BuildContext context) {
    return Scaffold(
      backgroundColor: CaseLibraryColors.bgCream,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(10.w, 4.h, 10.w, 2.h),
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
                        icon: SvgPicture.string(
                          _svgBackIcon,
                          width: 20.w,
                          height: 20.w,
                          colorFilter: const ColorFilter.mode(
                            CaseLibraryColors.primaryGreen,
                            BlendMode.srcIn,
                          ),
                        ),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ),
                    Text(
                      book.shortTitleZh.isNotEmpty
                          ? book.shortTitleZh
                          : book.titleZh,
                      style: LightTextStyles.cardTitle(context).copyWith(
                          fontSize: 16.sp, fontWeight: FontWeight.w900),
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 20.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        SizedBox(
                          width: 14.w,
                          height: 14.w,
                          child: const CircularProgressIndicator(
                            strokeWidth: 2.0,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              CaseLibraryColors.primaryGreen,
                            ),
                          ),
                        ),
                        SizedBox(width: 10.w),
                        Text(
                          '正在安全調閱雲端卷宗...',
                          style: TextStyle(
                            fontSize: 13.5.sp,
                            fontWeight: FontWeight.bold,
                            color: CaseLibraryColors.primaryGreen,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 20.h),
                    LiquidGlassShimmer(
                      width: double.infinity,
                      height: 120.h,
                      radius: 12.r,
                    ),
                    SizedBox(height: 14.h),
                    LiquidGlassShimmer(
                      width: double.infinity,
                      height: 80.h,
                      radius: 12.r,
                    ),
                    SizedBox(height: 14.h),
                    LiquidGlassShimmer(
                      width: double.infinity,
                      height: 100.h,
                      radius: 12.r,
                    ),
                    SizedBox(height: 14.h),
                    LiquidGlassShimmer(
                      width: double.infinity,
                      height: 90.h,
                      radius: 12.r,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCaseGalleryImage(String source) {
    final imageError = Container(
      color: CaseLibraryColors.borderLight,
      child: Center(
        child: CaseLibrarySvgIcon(
          CaseLibrarySvgIcons.imageOff,
          size: 40.w,
          color: CaseLibraryColors.textMuted,
        ),
      ),
    );

    if (source.startsWith('http')) {
      return CachedNetworkImage(
        imageUrl: source,
        fit: BoxFit.cover,
        width: double.infinity,
        errorWidget: (context, url, error) => imageError,
        placeholder: (context, url) => const ShimmerSkeleton(
          width: double.infinity,
          height: double.infinity,
          borderRadius: 0,
        ),
      );
    }

    return Image.asset(
      source,
      fit: BoxFit.cover,
      width: double.infinity,
      errorBuilder: (context, error, stackTrace) => imageError,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return _buildLoadingState(context);
    }

    // 台灣繁體中文教學註解：正式詳情讀取失敗時不能改顯示傳入頁面的
    // 舊快取或種子案件，沿用共用錯誤元件提供重試入口。
    if (_loadFailed) {
      return Scaffold(
        body: SafeArea(
          child: AppErrorState(message: '案件詳情暫時無法讀取。', onRetry: _retryLoadDetails),
        ),
      );
    }

    final book = _detailedBook ?? widget.book;
    final displayImages = _getDefaultImagesForCase(book);

    final backgroundColor = _readingTint == 'cool'
        ? const Color(0xFFEBF3F9)
        : _readingTint == 'warm'
            ? const Color(0xFFF9F3E6)
            : CaseLibraryColors.bgCream;

    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // Shorter, elegant top App Bar (Centered Title & AI Assistant shortcut)
            // 為了讓長標題在中間完美對齊，此處使用 Stack 進行多層疊加排版。
            // 這裡一定要給 SizedBox 滿版寬度，否則 Column 會讓 Header 跟著標題內容縮小，
            // 導致 left/right 定位只貼在縮小後的標題區塊，而不是螢幕左右邊界。
            Padding(
              padding: EdgeInsets.fromLTRB(10.w, 4.h, 10.w, 2.h),
              child: SizedBox(
                width: double.infinity,
                height: 48.h,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // 左側返回鍵，完全移除 Material Icons，改用自訂的 iOS 風格 SVG 返回圖示，並去除內距與約束靠最左側對齊。
                    Positioned(
                      left: 0,
                      child: IconButton(
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        icon: SvgPicture.string(
                          _svgBackIcon,
                          width: 20.w,
                          height: 20.w,
                          colorFilter: const ColorFilter.mode(
                            CaseLibraryColors.primaryGreen,
                            BlendMode.srcIn,
                          ),
                        ),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ),
                    // 置中案件名稱，水平方向預留安全空間，避免被左右兩側按鈕遮蓋，文字超出部分以「...」縮減顯示。
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 80.w),
                      child: Text(
                        book.shortTitleZh.isNotEmpty
                            ? book.shortTitleZh
                            : book.titleZh,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                        style: LightTextStyles.cardTitle(context).copyWith(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                    // 右側：閱讀設定與討論按鈕
                    Positioned(
                      right: 0,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                            icon: const Icon(
                              Icons.text_format_rounded,
                              color: CaseLibraryColors.primaryGreen,
                              size: 20,
                            ),
                            tooltip: '調整閱讀字型與色溫',
                            onPressed: () => _showReadingSettingsSheet(context),
                          ),
                          SizedBox(width: 10.w),
                          IconButton(
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                            icon: CaseLibrarySvgIcon(
                              CaseLibrarySvgIcons.waveform3,
                              size: 22.w,
                              color: CaseLibraryColors.primaryGreen,
                            ),
                            tooltip: '查看鄉民思辨討論',
                            onPressed: () {
                              Navigator.of(context).push(
                                CupertinoPageRoute<void>(
                                  builder: (_) => CaseNetizenChatRoomPage(
                                    book: widget.book,
                                    caseVotes: _caseVotes,
                                    netizenComments: _netizenComments,
                                  ),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            Expanded(
              child: MediaQuery(
                data: MediaQuery.of(context).copyWith(
                  textScaler: TextScaler.linear(_fontSizeMultiplier),
                ),
                child: NestedScrollView(
                  controller: _nestedScrollController,
                  physics: const BouncingScrollPhysics(
                    parent: AlwaysScrollableScrollPhysics(),
                  ),
                  headerSliverBuilder: (context, innerBoxIsScrolled) {
                    return [
                      CupertinoSliverRefreshControl(
                        refreshTriggerPullDistance: 100.0,
                        refreshIndicatorExtent: 64.0,
                        onRefresh: _refreshDossier,
                        builder: (
                          context,
                          refreshState,
                          pulledExtent,
                          refreshTriggerPullDistance,
                          refreshIndicatorExtent,
                        ) {
                          final progress = (pulledExtent /
                                  refreshTriggerPullDistance)
                              .clamp(0.0, 1.0);
                          return Center(
                            child: Opacity(
                              opacity: progress,
                              child: Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 14.w,
                                  vertical: 8.h,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(999),
                                  border: Border.all(
                                    color: CaseLibraryColors.borderLight,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color:
                                          Colors.black.withValues(alpha: 0.08),
                                      blurRadius: 10,
                                      offset: const Offset(0, 3),
                                    ),
                                  ],
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    if (refreshState ==
                                            RefreshIndicatorMode.refresh ||
                                        refreshState ==
                                            RefreshIndicatorMode.armed)
                                      const CupertinoActivityIndicator(
                                        radius: 9,
                                      )
                                    else
                                      CupertinoActivityIndicator.partiallyRevealed(
                                        radius: 9,
                                        progress: progress,
                                      ),
                                    SizedBox(width: 8.w),
                                    Text(
                                      refreshState ==
                                              RefreshIndicatorMode.refresh
                                          ? '重新整理中...'
                                          : (refreshState ==
                                                  RefreshIndicatorMode.armed
                                              ? '放開即可重新整理'
                                              : '下拉重新整理'),
                                      style: TextStyle(
                                        fontSize: 11.sp,
                                        fontWeight: FontWeight.w700,
                                        color: CaseLibraryColors.primaryGreen,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                      SliverToBoxAdapter(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // 1. Swipable Image Gallery (PageView)
                          SizedBox(
                            height: 200.h,
                            child: Stack(
                              children: [
                                PageView.builder(
                                  controller: _galleryController,
                                  itemCount: displayImages.length,
                                  onPageChanged: (index) {
                                    setState(() {
                                      _galleryIndex = index;
                                    });
                                  },
                                  itemBuilder: (context, index) {
                                    final image = displayImages[index];
                                    return _buildCaseGalleryImage(image.url);
                                  },
                                ),
                                // Page Number Badge (top-right)
                                Positioned(
                                  top: 12.h,
                                  right: 12.w,
                                  child: Container(
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 10.w, vertical: 4.h),
                                    decoration: BoxDecoration(
                                      color:
                                          Colors.black.withValues(alpha: 0.55),
                                      borderRadius: BorderRadius.circular(12.r),
                                    ),
                                    child: Text(
                                      '${_galleryIndex + 1}/${displayImages.length}',
                                      style: TextStyle(
                                        fontSize: 10.sp,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                                // Translucent Image Source overlay (bottom-left)
                                Positioned(
                                  bottom: 0,
                                  left: 0,
                                  right: 0,
                                  child: Container(
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 12.w, vertical: 8.h),
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: [
                                          Colors.black.withValues(alpha: 0.65),
                                          Colors.transparent,
                                        ],
                                        begin: Alignment.bottomCenter,
                                        end: Alignment.topCenter,
                                      ),
                                    ),
                                    child: Text(
                                      '圖片來源：${displayImages[_galleryIndex].source}',
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        fontSize: 9.5.sp,
                                        color:
                                            Colors.white.withValues(alpha: 0.9),
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // Case Header details card
                          Padding(
                            padding: EdgeInsets.fromLTRB(18.w, 16.h, 18.w, 0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      '${book.year}',
                                      style: TextStyle(
                                        fontSize: 13.sp,
                                        fontWeight: FontWeight.w900,
                                        color: CaseLibraryColors.accentGold,
                                      ),
                                    ),
                                    SizedBox(width: 8.w),
                                    Expanded(
                                      child: Text(
                                        '|  ${book.location}  |  ${book.status}',
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          fontSize: 11.sp,
                                          fontWeight: FontWeight.bold,
                                          color: CaseLibraryColors.textMuted,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 8.h),
                                Text(
                                  book.titleZh,
                                  style: TextStyle(
                                    fontFamily: 'Songti TC',
                                    fontFamilyFallback: const [
                                      'BiauKai',
                                      'Songti SC',
                                      'STSong'
                                    ],
                                    fontSize: 22.sp,
                                    height: 1.3,
                                    fontWeight: FontWeight.bold,
                                    color: CaseLibraryColors.primaryGreen,
                                  ),
                                ),
                                SizedBox(height: 10.h),
                                // Tags
                                // 此處使用 SingleChildScrollView 進行水平包裹，避免當案件 tags 超出螢幕寬度時引發 Layout 溢出。
                                // 同時為每個標籤加上點擊事件，讓使用者可直接透過此標籤跳轉至搜尋頁進行案件篩選。
                                SingleChildScrollView(
                                  scrollDirection: Axis.horizontal,
                                  physics: const BouncingScrollPhysics(),
                                  child: Row(
                                    children: book.tags.map((tag) {
                                      return GestureDetector(
                                        onTap: () {
                                          Navigator.of(context).push(
                                            CupertinoPageRoute<void>(
                                              builder: (_) =>
                                                  CaseLibrarySearchPage(
                                                      initialQuery: tag),
                                            ),
                                          );
                                        },
                                        child: Container(
                                          margin: EdgeInsets.only(right: 6.w),
                                          padding: EdgeInsets.symmetric(
                                              horizontal: 10.w, vertical: 4.h),
                                          decoration: BoxDecoration(
                                            color: CaseLibraryColors
                                                .primaryGreen
                                                .withValues(alpha: 0.08),
                                            borderRadius:
                                                BorderRadius.circular(4.r),
                                          ),
                                          child: Text(
                                            '#$tag',
                                            style: TextStyle(
                                              fontSize: 10.sp,
                                              color: CaseLibraryColors
                                                  .primaryGreen,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      );
                                    }).toList(),
                                  ),
                                ),
                                SizedBox(height: 12.h),

                                // Verdict Outcome Badge
                                if (book.judgmentResult.isNotEmpty) ...[
                                  () {
                                    Color badgeBgColor;
                                    Color badgeTextColor;
                                    Color badgeBorderColor;
                                    String badgeTitle = '裁判結果';
                                    final result = book.judgmentResult;
                                    if (result.contains('無罪')) {
                                      badgeBgColor = const Color(0xFFEAF5F0);
                                      badgeTextColor = const Color(0xFF2E6B4E);
                                      badgeBorderColor =
                                          const Color(0xFFC7E6D7);
                                      badgeTitle = '無罪宣告';
                                    } else if (result.contains('違憲') ||
                                        result.contains('合憲')) {
                                      badgeBgColor = const Color(0xFFFFF7E6);
                                      badgeTextColor = const Color(0xFFB37D14);
                                      badgeBorderColor =
                                          const Color(0xFFFFE7B3);
                                      badgeTitle = '憲法裁決';
                                    } else if (result.contains('徒刑') ||
                                        result.contains('有罪') ||
                                        result.contains('罰')) {
                                      badgeBgColor = const Color(0xFFFFF1F0);
                                      badgeTextColor = const Color(0xFFAD352B);
                                      badgeBorderColor =
                                          const Color(0xFFFFA39E);
                                      badgeTitle = '刑事處置';
                                    } else {
                                      badgeBgColor = const Color(0xFFF0F4F8);
                                      badgeTextColor = const Color(0xFF3C5A80);
                                      badgeBorderColor =
                                          const Color(0xFFD0E1FD);
                                      badgeTitle = '最終裁決';
                                    }
                                    return Container(
                                      width: double.infinity,
                                      margin: EdgeInsets.only(bottom: 14.h),
                                      padding: EdgeInsets.symmetric(
                                          horizontal: 14.w, vertical: 10.h),
                                      decoration: BoxDecoration(
                                        color: badgeBgColor,
                                        borderRadius:
                                            BorderRadius.circular(10.r),
                                        border: Border.all(
                                          color: badgeBorderColor,
                                          width: 1.2,
                                        ),
                                      ),
                                      child: Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Container(
                                            padding: EdgeInsets.symmetric(
                                                horizontal: 8.w, vertical: 2.h),
                                            decoration: BoxDecoration(
                                              color: badgeTextColor.withValues(
                                                  alpha: 0.12),
                                              borderRadius:
                                                  BorderRadius.circular(4.r),
                                            ),
                                            child: Text(
                                              badgeTitle,
                                              style: TextStyle(
                                                fontSize: 10.sp *
                                                    LightTextStyles.multiplier,
                                                fontWeight: FontWeight.bold,
                                                color: badgeTextColor,
                                              ),
                                            ),
                                          ),
                                          SizedBox(width: 8.w),
                                          Expanded(
                                            child: Text(
                                              book.judgmentResult,
                                              style: TextStyle(
                                                fontSize: 12.sp *
                                                    LightTextStyles.multiplier,
                                                fontWeight: FontWeight.bold,
                                                color: badgeTextColor,
                                                height: 1.45,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  }(),
                                ],

                                // Quote card block
                                Container(
                                  width: double.infinity,
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 16.w, vertical: 14.h),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFE9F2F1),
                                    borderRadius: BorderRadius.circular(10.r),
                                  ),
                                  child: Text(
                                    '「${book.oneSentenceSummary}」',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontFamily: 'Songti TC',
                                      fontFamilyFallback: const [
                                        'BiauKai',
                                        'Songti SC',
                                        'STSong'
                                      ],
                                      fontSize: 13.5.sp,
                                      height: 1.45,
                                      fontWeight: FontWeight.bold,
                                      color: CaseLibraryColors.primaryGreen,
                                    ),
                                  ),
                                ),
                                SizedBox(height: 14.h),

                                // 維基百科式條目資訊框 (Wikipedia Legal Infobox)
                                WikipediaInfoboxCard(book: book),

                                // 維基百科條目目錄 (Wikipedia Table of Contents)
                                WikipediaTableOfContents(
                                  activeTab: _selectedTab,
                                  onSelectTab: _selectTabAndScroll,
                                ),
                                SizedBox(height: 16.h),

                                // 事件摘要 Section
                                Text(
                                  '事件摘要',
                                  style: LightTextStyles.sectionTitle(context)
                                      .copyWith(
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                                SizedBox(height: 8.h),
                                _buildRichTextWithGlossary(
                                  context,
                                  book.background,
                                  LightTextStyles.body(context).copyWith(
                                    height: 1.6,
                                  ),
                                ),
                                SizedBox(height: 20.h),

                                // 主要爭點 Section（雙重編碼攻防重點卡）
                                _buildLegalIssuesSection(context, book),
                                SizedBox(height: 22.h),

                                // 「思辨與探索」引導式三步思辨旅程 + 進度追蹤
                                _buildDeliberationJourneySection(context, book),
                                SizedBox(height: 24.h),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    SliverPersistentHeader(
                      pinned: true,
                      delegate: _SliverTabBarDelegate(
                        child: _buildDossierTabBar(
                          context,
                          key: _tabSectionKey,
                          pinned: true,
                        ),
                      ),
                    ),
                  ];
                },
                body: CustomScrollView(
                  keyboardDismissBehavior:
                      ScrollViewKeyboardDismissBehavior.onDrag,
                  physics: const BouncingScrollPhysics(
                    parent: AlwaysScrollableScrollPhysics(),
                  ),
                  slivers: [
                    SliverPadding(
                      padding: EdgeInsets.fromLTRB(18.w, 12.h, 18.w, 32.h),
                      sliver: SliverList(
                        delegate: SliverChildListDelegate([
                          _buildActiveTabContent(context),
                          SizedBox(height: 24.h),
                          // 實作精緻的莫蘭迪粉綠漸層「小法助 AI 捷徑」橫幅（Banner），並改用 sparkling 圖示。
                          GestureDetector(
                            onTap: () {
                              CustomToast.show(
                                context,
                                '正在開啟\n小法助',
                                icon: Icons.support_agent_rounded,
                              );
                              Navigator.of(context).push(
                                MaterialPageRoute<void>(
                                  builder: (_) => LawAssistantChatPage(
                                    initialPrompt:
                                        '對「${book.titleZh}」的判決有疑問，請 AI 小法助協助解答。',
                                  ),
                                ),
                              );
                            },
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 16.w, vertical: 14.h),
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [
                                    Color(0xFFFAF8F5),
                                    Color(0xFFE6EFEA)
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                borderRadius: BorderRadius.circular(12.r),
                                border: Border.all(
                                  color: const Color(0xFFC7DED1),
                                  width: 1.2,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.02),
                                    blurRadius: 8,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    padding: EdgeInsets.all(8.w),
                                    decoration: BoxDecoration(
                                      color:
                                          Colors.white.withValues(alpha: 0.7),
                                      shape: BoxShape.circle,
                                    ),
                                    child: CaseLibrarySvgIcon(
                                      CaseLibrarySvgIcons.sparkles,
                                      size: 20.sp,
                                      color: CaseLibraryColors.primaryGreen,
                                    ),
                                  ),
                                  SizedBox(width: 12.w),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          '對本案判決有疑問？點擊詢問 AI 小法助',
                                          style: TextStyle(
                                            fontSize: 13.sp,
                                            fontWeight: FontWeight.bold,
                                            color:
                                                CaseLibraryColors.primaryGreen,
                                          ),
                                        ),
                                        SizedBox(height: 3.h),
                                        Text(
                                          '為您快速分析裁判意旨與涉及的法律爭點',
                                          style: TextStyle(
                                            fontSize: 10.5.sp,
                                            color:
                                                CaseLibraryColors.textSecondary,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  CaseLibrarySvgIcon(
                                    CaseLibrarySvgIcons.chevronRight,
                                    size: 12.sp,
                                    color: CaseLibraryColors.primaryGreen,
                                  ),
                                ],
                              ),
                            ),
                          ),
                          SizedBox(height: 14.h),
                          _buildDossierFooterActions(context),
                        ]),
                      ),
                    ),
                  ],
                ),
              ),
              ),
            ),

            // Bottom Sticky Action Bar
            _buildBottomActionBar(),
          ],
        ),
      ),
    );
  }

  Widget _buildActiveTabContent(BuildContext context) {
    switch (_selectedTab) {
      case '事件背景':
        return _buildBackgroundTab(context);
      case '事件與訴訟脈絡':
        return _buildCombinedTimelineTab(context);
      case '法律爭點':
        return _buildDisputesTab(context);
      case '相關法條':
        return _buildLawsTab(context);
      case '關係人角色':
        return _buildPeopleTab(context);
      case '裁判心證':
        return _buildCourtReasoningTab(context);
      case '完整判決書':
        return _buildFullJudgmentTab(context);
      case '社會影響':
        return _buildSocialImpactTab(context);
      case '學術文獻':
        return _buildLiteratureTab(context);
      case '延伸媒體':
        return _buildMediaTab(context);
      case '相關案件':
        return _buildExtensionsTab(context);
      case '鄉民討論':
        return _buildDiscussionsTab(context);
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildDossierTabBar(
    BuildContext context, {
    Key? key,
    bool pinned = false,
  }) {
    return Container(
      key: key,
      decoration: BoxDecoration(
        color: CaseLibraryColors.bgCream,
        border: pinned
            ? const Border(
                bottom: BorderSide(color: CaseLibraryColors.borderLight),
              )
            : null,
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: pinned ? 8.h : 16.h),
        child: SizedBox(
          height: 38.h,
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            padding: EdgeInsets.symmetric(horizontal: 18.w),
            child: Row(
              children: _availableTabs.map((tab) {
                final isSelected = tab == _selectedTab;
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedTab = tab;
                    });
                  },
                  child: Container(
                    margin: EdgeInsets.only(right: 8.w),
                    padding:
                        EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? CaseLibraryColors.primaryGreen
                          : CaseLibraryColors.bgWhite,
                      borderRadius: BorderRadius.circular(20.r),
                      border: Border.all(
                        color: isSelected
                            ? CaseLibraryColors.primaryGreen
                            : CaseLibraryColors.borderLight,
                      ),
                    ),
                    child: Text(
                      tab,
                      style: TextStyle(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.bold,
                        color: isSelected
                            ? CaseLibraryColors.bgWhite
                            : CaseLibraryColors.textSecondary,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ),
      ),
    );
  }

  // --- TAB: 鄉民討論 ---
  // 此處實作為所有案件設計的「鄉民討論」互動分頁。
  // 包含：
  // 1. 法律思辨投開票所 (PK Opinion Poll)：顯示該案在社群上的認同率，投票後展示美觀比例條與票數。
  // 2. 發表觀點欄：使用者可撰寫意見並挑選立場 (合理派/不合理派/中立派)，發言後即時以 setState 動態插入留言板首位。
  // 3. 鄉民留言板 (Salon Comments)：展示多方不同立場的思辨留言，並可點擊愛心進行按讚/取消讚。
  Widget _buildDiscussionsTab(BuildContext context) {
    final votes =
        _caseVotes[book.id] ?? CaseInteractiveProfiles.getPollVotes(book);
    final agreeCount = votes[0];
    final disagreeCount = votes[1];
    final totalVotes = agreeCount + disagreeCount;
    final agreePercent =
        totalVotes > 0 ? (agreeCount / totalVotes * 100).round() : 50;
    final disagreePercent = totalVotes > 0 ? 100 - agreePercent : 50;
    final hasVoted = _myVotes.containsKey(book.id);
    final myChoice = _myVotes[book.id];

    // 初始化該案件量身打造之獨立鄉民思辨留言列表
    if (!_netizenComments.containsKey(book.id)) {
      _netizenComments[book.id] =
          CaseInteractiveProfiles.getNetizenComments(book);
    }
    final comments = _netizenComments[book.id]!;

    // 依據案件設定思辨投開票所題目
    final pollQuestion = CaseInteractiveProfiles.getPollQuestion(book);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 1. 法律思辨投開票所 (Poll Section)
        Text(
          '法律思辨投開票所',
          style: LightTextStyles.sectionTitle(context).copyWith(
            fontWeight: FontWeight.w900,
          ),
        ),
        SizedBox(height: 10.h),
        Container(
          padding: EdgeInsets.all(16.w),
          decoration: BoxDecoration(
            color: CaseLibraryColors.bgWhite,
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(color: CaseLibraryColors.borderLight),
            boxShadow: [CaseLibraryShadows.softShadow],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: 6.w, vertical: 3.h),
                    decoration: BoxDecoration(
                      color:
                          CaseLibraryColors.accentGold.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(4.r),
                    ),
                    child: Text(
                      '鄉民即時 PK',
                      style: TextStyle(
                        fontSize: 9.5.sp,
                        fontWeight: FontWeight.bold,
                        color: CaseLibraryColors.accentGold,
                      ),
                    ),
                  ),
                  SizedBox(width: 8.w),
                  Text(
                    '已累積 $totalVotes 人投票',
                    style: TextStyle(
                      fontSize: 10.sp,
                      color: CaseLibraryColors.textMuted,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 12.h),
              Text(
                pollQuestion,
                style: TextStyle(
                  fontSize: 13.sp,
                  height: 1.45,
                  fontWeight: FontWeight.w900,
                  color: CaseLibraryColors.primaryGreen,
                ),
              ),
              SizedBox(height: 16.h),
              if (!hasVoted) ...[
                // 未投票時：顯示兩個大投票按鈕
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFF2E7D32),
                          side: const BorderSide(
                              color: Color(0xFF2E7D32), width: 1.2),
                          padding: EdgeInsets.symmetric(vertical: 12.h),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.r),
                          ),
                        ),
                        icon: CaseLibrarySvgIcon(
                          CaseLibrarySvgIcons.thumbsUp,
                          size: 16.sp,
                          color: const Color(0xFF2E7D32),
                        ),
                        label: const Text('合理',
                            style: TextStyle(fontWeight: FontWeight.bold)),
                        onPressed: () {
                          setState(() {
                            _myVotes[book.id] = 'agree';
                            _caseVotes[book.id] = [
                              agreeCount + 1,
                              disagreeCount
                            ];
                          });
                          CustomToast.show(
                            context,
                            '已投合理',
                            icon: Icons.thumb_up_alt_rounded,
                          );
                        },
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFFC62828),
                          side: const BorderSide(
                              color: Color(0xFFC62828), width: 1.2),
                          padding: EdgeInsets.symmetric(vertical: 12.h),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.r),
                          ),
                        ),
                        icon: CaseLibrarySvgIcon(
                          CaseLibrarySvgIcons.thumbsDown,
                          size: 16.sp,
                          color: const Color(0xFFC62828),
                        ),
                        label: const Text('不合理',
                            style: TextStyle(fontWeight: FontWeight.bold)),
                        onPressed: () {
                          setState(() {
                            _myVotes[book.id] = 'disagree';
                            _caseVotes[book.id] = [
                              agreeCount,
                              disagreeCount + 1
                            ];
                          });
                          CustomToast.show(
                            context,
                            '已投不合理',
                            icon: Icons.thumb_down_alt_rounded,
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ] else ...[
                // 已投票時：顯示動態長條比率與標記
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 百分比條
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8.r),
                      child: SizedBox(
                        height: 18.h,
                        child: Row(
                          children: [
                            Expanded(
                              flex: agreePercent,
                              child: Container(
                                color: const Color(0xFF2E7D32),
                                alignment: Alignment.centerLeft,
                                padding: EdgeInsets.only(left: 8.w),
                                child: Text(
                                  '合理 $agreePercent%',
                                  style: TextStyle(
                                    fontSize: 9.5.sp,
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                            Container(
                              width: 14.w,
                              color: Colors.white,
                              alignment: Alignment.center,
                              child: Text(
                                'VS',
                                style: TextStyle(
                                  fontSize: 8.sp,
                                  fontWeight: FontWeight.w900,
                                  color: CaseLibraryColors.primaryGreen,
                                ),
                              ),
                            ),
                            Expanded(
                              flex: disagreePercent,
                              child: Container(
                                color: const Color(0xFFC62828),
                                alignment: Alignment.centerRight,
                                padding: EdgeInsets.only(right: 8.w),
                                child: Text(
                                  '$disagreePercent% 不合理',
                                  style: TextStyle(
                                    fontSize: 9.5.sp,
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 10.h),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '合理 $agreeCount 票 · 不合理 $disagreeCount 票',
                          style: TextStyle(
                            fontSize: 10.sp,
                            color: CaseLibraryColors.textMuted,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '您的立場：${myChoice == 'agree' ? '合理 👍' : '不合理 👎'}',
                          style: TextStyle(
                            fontSize: 10.sp,
                            color: myChoice == 'agree'
                                ? const Color(0xFF2E7D32)
                                : const Color(0xFFC62828),
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
        SizedBox(height: 24.h),

        // 2. 發表我的法律看法 (Input Form)
        Text(
          '發表我的法律思辨看法',
          style: LightTextStyles.sectionTitle(context).copyWith(
            fontWeight: FontWeight.w900,
          ),
        ),
        SizedBox(height: 10.h),
        Container(
          padding: EdgeInsets.all(14.w),
          decoration: BoxDecoration(
            color: CaseLibraryColors.bgWhite,
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(color: CaseLibraryColors.borderLight),
            boxShadow: [CaseLibraryShadows.softShadow],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 立場選擇器
              Row(
                children: [
                  Text(
                    '我的立場：',
                    style: TextStyle(
                      fontSize: 11.5.sp,
                      fontWeight: FontWeight.bold,
                      color: CaseLibraryColors.textSecondary,
                    ),
                  ),
                  _buildStanceChip('合理派', const Color(0xFF2E7D32)),
                  SizedBox(width: 6.w),
                  _buildStanceChip('不合理派', const Color(0xFFC62828)),
                  SizedBox(width: 6.w),
                  _buildStanceChip('中立派', const Color(0xFF757575)),
                ],
              ),
              SizedBox(height: 10.h),
              // 輸入框
              TextField(
                controller: _commentController,
                onTapOutside: (event) {
                  FocusManager.instance.primaryFocus?.unfocus();
                },
                maxLines: 3,
                style: TextStyle(
                    fontSize: 12.5.sp, color: CaseLibraryColors.textPrimary),
                decoration: InputDecoration(
                  hintText: '引述法條思辨，在此發表你對於本案判決或爭點的看法...',
                  hintStyle: TextStyle(
                      fontSize: 11.5.sp, color: CaseLibraryColors.textMuted),
                  contentPadding: EdgeInsets.all(12.w),
                  filled: true,
                  fillColor: const Color(0xFFF9F9F6),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.r),
                    borderSide:
                        const BorderSide(color: CaseLibraryColors.borderLight),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.r),
                    borderSide: const BorderSide(
                        color: CaseLibraryColors.primaryGreen, width: 1.2),
                  ),
                ),
              ),
              SizedBox(height: 10.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // 引述法條輔助工具提示
                  Row(
                    children: [
                      CaseLibrarySvgIcon(
                        CaseLibrarySvgIcons.gavel,
                        size: 14.sp,
                        color: CaseLibraryColors.accentGold,
                      ),
                      SizedBox(width: 4.w),
                      Text(
                        '可點「相關法條」引述條文',
                        style: TextStyle(
                          fontSize: 10.sp,
                          color: CaseLibraryColors.accentGold,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: CaseLibraryColors.primaryGreen,
                      foregroundColor: Colors.white,
                      padding:
                          EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                    ),
                    onPressed: () {
                      final text = _commentController.text.trim();
                      if (text.isEmpty) {
                        CustomToast.show(
                          context,
                          '請先輸入內容',
                          icon: Icons.edit_note_rounded,
                        );
                        return;
                      }

                      setState(() {
                        comments.insert(0, {
                          'avatar': '我',
                          'name': '法律學習者',
                          'time': '剛剛',
                          'stance': _selectedStance,
                          'stanceColor': _selectedStance == '合理派'
                              ? const Color(0xFF2E7D32)
                              : (_selectedStance == '不合理派'
                                  ? const Color(0xFFC62828)
                                  : const Color(0xFF757575)),
                          'content': text,
                          'likes': 0,
                          'liked': false,
                        });
                        _commentController.clear();
                      });
                      CustomToast.show(
                        context,
                        '觀點已發表',
                        icon: Icons.check_circle_outline_rounded,
                      );
                    },
                    child: Text(
                      '發表觀點',
                      style: TextStyle(
                        fontSize: 11.5.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        SizedBox(height: 24.h),

        // 3. 鄉民留言板 (Salon)
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '網友思辨留言板',
              style: LightTextStyles.sectionTitle(context).copyWith(
                fontWeight: FontWeight.w900,
              ),
            ),
            Text(
              '共 ${comments.length} 條觀點',
              style: TextStyle(
                fontSize: 11.sp,
                color: CaseLibraryColors.textMuted,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        SizedBox(height: 10.h),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: comments.length,
          itemBuilder: (context, index) {
            final comment = comments[index];
            final liked = comment['liked'] as bool;
            final likesCount = comment['likes'] as int;

            return Container(
              margin: EdgeInsets.only(bottom: 10.h),
              padding: EdgeInsets.all(12.w),
              decoration: BoxDecoration(
                color: CaseLibraryColors.bgWhite,
                borderRadius: BorderRadius.circular(10.r),
                border: Border.all(color: CaseLibraryColors.borderLight),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 網友 Header
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 14.r,
                        backgroundColor: CaseLibraryColors.bgCream,
                        child: Text(
                          comment['avatar'],
                          style: TextStyle(
                            fontSize: 11.sp,
                            fontWeight: FontWeight.bold,
                            color: CaseLibraryColors.primaryGreen,
                          ),
                        ),
                      ),
                      SizedBox(width: 8.w),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                comment['name'],
                                style: TextStyle(
                                  fontSize: 12.sp,
                                  fontWeight: FontWeight.bold,
                                  color: CaseLibraryColors.textPrimary,
                                ),
                              ),
                              SizedBox(width: 6.w),
                              Container(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 6.w, vertical: 1.5.h),
                                decoration: BoxDecoration(
                                  color: (comment['stanceColor'] as Color)
                                      .withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(3.r),
                                ),
                                child: Text(
                                  comment['stance'],
                                  style: TextStyle(
                                    fontSize: 8.5.sp,
                                    fontWeight: FontWeight.w900,
                                    color: comment['stanceColor'],
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 2.h),
                          Text(
                            comment['time'],
                            style: TextStyle(
                              fontSize: 9.5.sp,
                              color: CaseLibraryColors.textMuted,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  SizedBox(height: 10.h),
                  // 內容
                  Text(
                    comment['content'],
                    style: TextStyle(
                      fontSize: 12.5.sp,
                      height: 1.5,
                      color: CaseLibraryColors.textPrimary,
                    ),
                  ),
                  SizedBox(height: 10.h),
                  // 按讚功能
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            comment['liked'] = !liked;
                            comment['likes'] = likesCount + (!liked ? 1 : -1);
                          });
                        },
                        child: Row(
                          children: [
                            CaseLibrarySvgIcon(
                              liked
                                  ? CaseLibrarySvgIcons.heartFilled
                                  : CaseLibrarySvgIcons.heart,
                              size: 14.sp,
                              color: liked
                                  ? Colors.red
                                  : CaseLibraryColors.textMuted,
                            ),
                            SizedBox(width: 4.w),
                            Text(
                              '認同 ($likesCount)',
                              style: TextStyle(
                                fontSize: 10.5.sp,
                                color: liked
                                    ? Colors.red
                                    : CaseLibraryColors.textMuted,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }

  // 建立立場選擇 Chip 的輔助方法，點擊時會更換當前選擇的立場。
  Widget _buildStanceChip(String stance, Color activeColor) {
    final isSelected = _selectedStance == stance;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedStance = stance;
        });
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
        decoration: BoxDecoration(
          color: isSelected ? activeColor : Colors.transparent,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
            color: isSelected ? activeColor : CaseLibraryColors.borderLight,
            width: 1.2,
          ),
        ),
        child: Text(
          stance,
          style: TextStyle(
            fontSize: 10.5.sp,
            fontWeight: FontWeight.bold,
            color: isSelected ? Colors.white : CaseLibraryColors.textSecondary,
          ),
        ),
      ),
    );
  }

  // --- TAB 0: 脈絡 ---
  // --- TAB 1: 爭點 ---
  // --- TAB 2: 法條 ---
  // 點擊法條卡片時彈出的莫蘭迪米白 (Cream) 精緻底頁，顯示完整條文概要與該案之關聯。
  // --- TAB 3: 延伸 ---
  // --- Bottom Action Bar ---
  Widget _buildBottomActionBar() {
    // 底部行動列已抽成跨功能共用元件，生活避坑筆記也會使用同一套；
    // 這能避免案件詳情與文章詳情各自複製一份相似 UI，造成之後維護漂移。
    return PreambleStoryActionBar(
      isFollowed: _isFollowed,
      isSaved: _isSaved,
      onAskAssistant: () {
        Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (_) => LawAssistantChatPage(
              initialPrompt: '我想了解關於「${book.titleZh}」的法律爭點與實務見解。',
            ),
          ),
        );
      },
      onNote: () {
        _CaseDossierBottomSheets(this).showNoteBottomSheet(context);
      },
      onFollow: () {
        HapticFeedback.lightImpact();
        setState(() {
          _isFollowed = !_isFollowed;
        });
        CustomToast.show(
          context,
          _isFollowed ? '已加入追蹤' : '已取消追蹤',
          icon: _isFollowed
              ? Icons.notifications_active_rounded
              : Icons.notifications_off_rounded,
        );
      },
      onSave: () {
        HapticFeedback.lightImpact();
        setState(() {
          _isSaved = !_isSaved;
        });
        CustomToast.show(
          context,
          _isSaved ? '已加入收藏' : '已取消收藏',
          icon: _isSaved ? Icons.bookmark_rounded : Icons.bookmark_border,
        );
      },
      onShare: () {
        ShareSheet.show(
          context,
          title: book.titleZh,
          url:
              'https://preamble.vernalcollective.com/cases/${Uri.encodeComponent(book.id)}',
        );
      },
    );
  }

  // --- Redesign Helpers & UI Builders ---

  Widget _buildRichTextWithGlossary(
      BuildContext context, String text, TextStyle baseStyle) {
    return WikipediaWikilinkText(
      text: text,
      baseStyle: baseStyle,
    );
  }

  Widget _buildFullJudgmentTab(BuildContext context) {
    final book = _detailedBook ?? widget.book;

    // Helper to format date into Taiwanese Minguo date format
    String formattedDate = '';
    try {
      final parts = book.basicInfo.updatedAt.split('/');
      if (parts.length == 3) {
        final year = int.parse(parts[0]);
        final minguoYear = year - 1911;
        formattedDate = '中華民國 $minguoYear 年 ${parts[1]} 月 ${parts[2]} 日';
      }
    } catch (_) {
      formattedDate = '中華民國 ${book.year - 1911} 年';
    }

    final minguoYearLabel = book.year - 1911;

    final officialCaseNo = book.basicInfo.caseNumber?.isNotEmpty == true
        ? book.basicInfo.caseNumber!
        : (book.displayCode.isNotEmpty
            ? book.displayCode
            : '${book.basicInfo.courtLevel} $minguoYearLabel 年度字第 ${book.id} 號');

    final officialDate = book.basicInfo.judgmentDate?.isNotEmpty == true
        ? book.basicInfo.judgmentDate!
        : formattedDate;

    final officialCause = book.basicInfo.cause?.isNotEmpty == true
        ? book.basicInfo.cause!
        : '${book.category}（${book.titleZh}）';

    final benchText = book.basicInfo.bench?.isNotEmpty == true
        ? book.basicInfo.bench!
        : (book.people.any((p) => p.role.contains('審判') || p.role.contains('法官'))
            ? book.people
                .firstWhere(
                    (p) => p.role.contains('審判') || p.role.contains('法官'))
                .description
            : '司法院合議庭');

    // Build the parts of the judgment
    final metadataText = '【裁判機關】${book.basicInfo.courtLevel}\n'
        '【裁判字號】$officialCaseNo\n'
        '【裁判日期】$officialDate\n'
        '【裁判案由】$officialCause';

    final mainVerdictText =
        book.judgmentResult.isNotEmpty ? book.judgmentResult : "上訴駁回。";

    final proceduralText = book.investigationAndTrial.isNotEmpty
        ? book.investigationAndTrial
        : '本案經檢察官提起公訴，歷經言詞辯論，本院依法審判之程序完備。';

    final reasoningText = book.courtReasoning.isNotEmpty
        ? book.courtReasoning
        : (book.fullStory.isNotEmpty ? book.fullStory : book.background);

    final List<String> lawLines = [];
    if (book.relatedLaws.isNotEmpty) {
      for (final law in book.relatedLaws) {
        lawLines.add(
            '依${law.lawName}${law.articleNumber}（${law.plainSummary}）之規定，本案據此裁判。');
      }
    } else {
      lawLines.add('依相關法律之規定，本案據此裁判。');
    }

    final baseTextStyle = TextStyle(
      fontFamily: AppFonts.serifTW,
      fontFamilyFallback: AppFonts.serifFallbacks,
      fontSize: 12.5.sp * LightTextStyles.multiplier,
      height: 1.8,
      letterSpacing: 1.1,
      color: const Color(0xFF2B2B2B), // Traditional charcoal black
    );

    final sectionTitleStyle = TextStyle(
      fontFamily: AppFonts.serifTW,
      fontFamilyFallback: AppFonts.serifFallbacks,
      fontSize: 14.sp * LightTextStyles.multiplier,
      fontWeight: FontWeight.bold,
      color: CaseLibraryColors.primaryGreen,
      height: 2.0,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '司法院裁判書官方全文與理由要旨',
              style: LightTextStyles.sectionTitle(context).copyWith(
                fontWeight: FontWeight.w900,
              ),
            ),
            GestureDetector(
              onTap: () {
                final fullTextBuffer = StringBuffer()
                  ..writeln(metadataText)
                  ..writeln('\n【主文】\n$mainVerdictText\n')
                  ..writeln('【事實與理由】\n')
                  ..writeln('壹、程序概述\n$proceduralText\n')
                  ..writeln('貳、實體理由與心證闡述\n$reasoningText\n')
                  ..writeln('參、適用法條');
                for (final line in lawLines) {
                  fullTextBuffer.writeln(line);
                }
                fullTextBuffer.writeln('\n\n【審判合議庭】\n'
                    '$benchText\n'
                    '\n以上正本證明與原本無異。');

                Clipboard.setData(
                    ClipboardData(text: fullTextBuffer.toString()));
                CustomToast.show(
                  context,
                  '全文已複製',
                  icon: Icons.content_copy_rounded,
                );
              },
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
                decoration: BoxDecoration(
                  color: CaseLibraryColors.primaryGreen.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(6.r),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CaseLibrarySvgIcon(
                      CaseLibrarySvgIcons.copy,
                      size: 13.sp,
                      color: CaseLibraryColors.primaryGreen,
                    ),
                    SizedBox(width: 4.w),
                    Text(
                      '複製全文',
                      style: TextStyle(
                        fontSize: 10.5.sp,
                        fontWeight: FontWeight.bold,
                        color: CaseLibraryColors.primaryGreen,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 12.h),

        // Horizontal anchor bar at the top of the judgment card
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          padding: EdgeInsets.only(bottom: 12.h),
          child: Row(
            children: [
              _buildAnchorButton('主文', _mainVerdictKey),
              _buildAnchorButton('程序概述', _proceduralKey),
              _buildAnchorButton('理由與心證', _reasoningKey),
              _buildAnchorButton('適用法條', _lawsKey),
            ],
          ),
        ),

        // Parchment styled scroll view containing distinct visual sections
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: const Color(0xFFFAF9F6), // Parchment ivory/cream
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(
              color: const Color(0xFF8D7F67).withValues(alpha: 0.5),
              width: 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          padding: EdgeInsets.all(4.w), // Outer frame spacing
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8.r),
              border: Border.all(
                color: const Color(0xFF8D7F67).withValues(alpha: 0.25),
                width: 0.8,
              ),
            ),
            padding: EdgeInsets.all(16.w), // Inner frame spacing
            child: SelectionArea(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Metadata block
                  Text(
                    metadataText,
                    style: baseTextStyle.copyWith(
                      color: const Color(0xFF555555),
                      fontSize: 11.5.sp * LightTextStyles.multiplier,
                    ),
                  ),
                  SizedBox(height: 16.h),
                  const Divider(color: Color(0xFF8D7F67), thickness: 0.5),
                  SizedBox(height: 16.h),

                  // 1. 主文 Section
                  Container(
                    key: _mainVerdictKey,
                    width: double.infinity,
                    padding: EdgeInsets.all(12.w),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFAF8F2),
                      borderRadius: BorderRadius.circular(8.r),
                      border: Border.all(
                        color: const Color(0xFF8D7F67).withValues(alpha: 0.2),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('【主文】', style: sectionTitleStyle),
                        SizedBox(height: 4.h),
                        Text(
                          mainVerdictText,
                          style: baseTextStyle.copyWith(
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF1B3F38),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 20.h),

                  // 2. 程序概述 Section
                  Column(
                    key: _proceduralKey,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('壹、程序概述', style: sectionTitleStyle),
                      SizedBox(height: 6.h),
                      Text(
                        proceduralText,
                        style: baseTextStyle,
                      ),
                    ],
                  ),
                  SizedBox(height: 20.h),

                  // 3. 理由與心證 Section
                  Column(
                    key: _reasoningKey,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('貳、實體理由與心證闡述', style: sectionTitleStyle),
                      SizedBox(height: 6.h),
                      Text(
                        reasoningText,
                        style: baseTextStyle,
                      ),
                    ],
                  ),
                  SizedBox(height: 20.h),

                  // 4. 適用法條 Section
                  Column(
                    key: _lawsKey,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('參、適用法條', style: sectionTitleStyle),
                      SizedBox(height: 6.h),
                      for (final line in lawLines)
                        Padding(
                          padding: EdgeInsets.only(bottom: 6.h),
                          child: Text(
                            line,
                            style: baseTextStyle,
                          ),
                        ),
                    ],
                  ),
                  SizedBox(height: 24.h),
                  const Divider(color: Color(0xFF8D7F67), thickness: 0.3),
                  SizedBox(height: 16.h),

                  // Footer block
                  Text(
                    '${book.basicInfo.courtLevel}\n'
                    '【合議庭審理法官】\n'
                    '$benchText\n\n'
                    '以上正本證明與原本無異。',
                    style: baseTextStyle.copyWith(
                      color: const Color(0xFF666666),
                      fontSize: 11.5.sp,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _scrollToSection(GlobalKey key) {
    final context = key.currentContext;
    if (context != null) {
      Scrollable.ensureVisible(
        context,
        duration: const Duration(milliseconds: 400),
        alignment: 0.1, // Align near the top of the viewport
        curve: Curves.easeInOut,
      );
    }
  }

  Widget _buildAnchorButton(String label, GlobalKey key) {
    return GestureDetector(
      onTap: () => _scrollToSection(key),
      child: Container(
        margin: EdgeInsets.only(right: 8.w),
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
        decoration: BoxDecoration(
          color: const Color(0xFFEAF2F1),
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(
            color: CaseLibraryColors.primaryGreen.withValues(alpha: 0.2),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            CaseLibrarySvgIcon(
              CaseLibrarySvgIcons.article,
              size: 12.sp,
              color: CaseLibraryColors.primaryGreen,
            ),
            SizedBox(width: 4.w),
            Text(
              label,
              style: TextStyle(
                fontSize: 11.5.sp,
                fontWeight: FontWeight.bold,
                color: CaseLibraryColors.primaryGreen,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showReadingSettingsSheet(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            final isDark = Theme.of(context).brightness == Brightness.dark;
            final bg =
                isDark ? const Color(0xFF171C22) : const Color(0xFFFAF6F0);
            final text =
                isDark ? const Color(0xFFFAF6F0) : const Color(0xFF234D3B);

            return Container(
              decoration: BoxDecoration(
                color: bg,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
              ),
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 24.h),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 48.w,
                      height: 5.h,
                      decoration: BoxDecoration(
                        color: Colors.grey[400],
                        borderRadius: BorderRadius.circular(100.r),
                      ),
                    ),
                  ),
                  SizedBox(height: 20.h),
                  Text(
                    " Apple 閱讀偏好設定",
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                      color: text,
                    ),
                  ),
                  SizedBox(height: 18.h),

                  // 色溫設定
                  Text(
                    "閱讀背景色溫",
                    style: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[600],
                    ),
                  ),
                  SizedBox(height: 10.h),
                  Row(
                    children: [
                      _buildTintOption(
                        label: "預設米白",
                        value: "none",
                        activeColor: const Color(0xFFFAF6F0),
                        setSheetState: setSheetState,
                      ),
                      SizedBox(width: 8.w),
                      _buildTintOption(
                        label: "冷光護眼",
                        value: "cool",
                        activeColor: const Color(0xFFEBF3F9),
                        setSheetState: setSheetState,
                      ),
                      SizedBox(width: 8.w),
                      _buildTintOption(
                        label: "暖陽紙質",
                        value: "warm",
                        activeColor: const Color(0xFFF9F3E6),
                        setSheetState: setSheetState,
                      ),
                    ],
                  ),
                  SizedBox(height: 20.h),

                  // 字型縮放
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "字型大小縮放",
                        style: TextStyle(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[600],
                        ),
                      ),
                      Text(
                        "${(_fontSizeMultiplier * 100).toInt()}%",
                        style: TextStyle(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.bold,
                          color: text,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 10.h),
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.remove_circle_outline),
                        onPressed: _fontSizeMultiplier <= 0.8
                            ? null
                            : () {
                                HapticFeedback.selectionClick();
                                setState(() {
                                  _fontSizeMultiplier -= 0.1;
                                  if (_fontSizeMultiplier < 0.8) {
                                    _fontSizeMultiplier = 0.8;
                                  }
                                });
                                setSheetState(() {});
                              },
                      ),
                      Expanded(
                        child: Slider.adaptive(
                          value: _fontSizeMultiplier,
                          min: 0.8,
                          max: 1.8,
                          divisions: 10,
                          onChanged: (val) {
                            HapticFeedback.selectionClick();
                            setState(() {
                              _fontSizeMultiplier = val;
                            });
                            setSheetState(() {});
                          },
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.add_circle_outline),
                        onPressed: _fontSizeMultiplier >= 1.8
                            ? null
                            : () {
                                HapticFeedback.selectionClick();
                                setState(() {
                                  _fontSizeMultiplier += 0.1;
                                  if (_fontSizeMultiplier > 1.8) {
                                    _fontSizeMultiplier = 1.8;
                                  }
                                });
                                setSheetState(() {});
                              },
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildTintOption({
    required String label,
    required String value,
    required Color activeColor,
    required StateSetter setSheetState,
  }) {
    final isSelected = _readingTint == value;
    return Expanded(
      child: LiquidGlassButton(
        padding: EdgeInsets.symmetric(vertical: 10.h),
        buttonColor: isSelected ? const Color(0xFF1B5E4F) : Colors.grey[200],
        onTap: () {
          setState(() {
            _readingTint = value;
          });
          setSheetState(() {});
        },
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 11.sp,
              fontWeight: FontWeight.bold,
              color: isSelected ? Colors.white : Colors.black87,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLegalIssuesSection(BuildContext context, CaseBook book) {
    final issues = book.legalIssues;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                '主要爭點',
                style: LightTextStyles.sectionTitle(context).copyWith(
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
            if (issues.isNotEmpty)
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: CaseLibraryColors.primaryGreen.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  '雙重編碼拆解 · 共 ${issues.length} 項',
                  style: TextStyle(
                    fontSize: 10.5.sp,
                    fontWeight: FontWeight.w700,
                    color: CaseLibraryColors.primaryGreen,
                  ),
                ),
              ),
          ],
        ),
        SizedBox(height: 10.h),
        if (issues.isEmpty)
          Text(
            '本案核心爭點整理中，可點選下方「思辨與探索」或詢問 AI 小法助。',
            style: LightTextStyles.bodySmall(context),
          )
        else
          ...List.generate(issues.length, (idx) {
            final issue = issues[idx];
            final matchedLaws = book.relatedLaws.where((law) {
              if (issue.relatedLawIds.isEmpty) return false;
              final label = '${law.lawName} ${law.articleNumber}';
              return issue.relatedLawIds.any(
                (id) =>
                    label.contains(id) ||
                    id.contains(law.articleNumber) ||
                    id.contains(law.lawName),
              );
            }).toList();
            final lawLabels = matchedLaws.isNotEmpty
                ? matchedLaws
                    .map((l) => '${l.lawName} ${l.articleNumber}'.trim())
                    .toList()
                : (issue.relatedLawIds.isNotEmpty
                    ? issue.relatedLawIds
                    : book.relatedLaws
                        .take(2)
                        .map((l) => '${l.lawName} ${l.articleNumber}'.trim())
                        .toList());

            return Padding(
              padding: EdgeInsets.only(bottom: 12.h),
              child: _DualCodingIssueCard(
                index: idx,
                issue: issue,
                lawLabels: lawLabels,
                isFocused: _focusedIssueIndices.contains(idx),
                hasLawTab: _availableTabs.contains('相關法條'),
                onToggleFocus: () {
                  HapticFeedback.selectionClick();
                  setState(() {
                    if (_focusedIssueIndices.contains(idx)) {
                      _focusedIssueIndices.remove(idx);
                    } else {
                      _focusedIssueIndices.add(idx);
                    }
                  });
                },
                onTapLawChip: () => _selectTabAndScroll('相關法條'),
                onAskAssistant: () {
                  HapticFeedback.selectionClick();
                  Navigator.of(context).push(
                    CupertinoPageRoute<void>(
                      builder: (_) => LawAssistantChatPage(
                        initialPrompt:
                            '請幫我用白話拆解「${book.shortTitleZh}」的爭點：「${issue.title}」。核心爭點說明：${issue.plainExplanation}',
                      ),
                    ),
                  );
                },
                onOpenJudgePractice: () => _openDeliberationTool(
                  'judge',
                  () => CaseJudgePracticePage(book: book),
                ),
              ),
            );
          }),
      ],
    );
  }

  void _openDeliberationTool(
    String toolId,
    Widget Function() pageBuilder,
  ) {
    HapticFeedback.selectionClick();
    setState(() {
      _exploredTools.add(toolId);
    });
    Navigator.of(context).push(
      CupertinoPageRoute<void>(
        builder: (_) => pageBuilder(),
      ),
    );
  }

  Widget _buildDeliberationJourneySection(BuildContext context, CaseBook book) {
    final exploredCount = _exploredTools.length;
    final progress = (exploredCount / 6).clamp(0.0, 1.0);

    final vocabPreview = book.tags.isNotEmpty
        ? '收錄關鍵概念，例如「${book.tags.first}」等詞彙與白話釋義'
        : '快速掌握本案核心法學名詞與白話釋義';
    final spectrumPreview = book.legalIssues.isNotEmpty
        ? '透視「${book.legalIssues.first.title}」的多方立場'
        : '透視控辯、學界與社會各界爭議光譜';
    final judgePreview = '親自權衡「${book.shortTitleZh}」的爭點與量刑心證';
    final witnessPreview = '模擬詰問關鍵證人與檢辯攻防破綻';
    final socialPreview = book.socialImpact.trim().isNotEmpty
        ? book.socialImpact.trim()
        : '追蹤本案引發的修法與制度變革';
    final opinionPreview = '看看大家對「${book.shortTitleZh}」怎麼看，留下你的觀點';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                '思辨與探索',
                style: LightTextStyles.sectionTitle(context).copyWith(
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
              decoration: BoxDecoration(
                color: CaseLibraryColors.primaryGreen.withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(999),
                border: Border.all(
                  color:
                      CaseLibraryColors.primaryGreen.withValues(alpha: 0.25),
                ),
              ),
              child: Text(
                '已探索 $exploredCount / 6',
                style: TextStyle(
                  fontSize: 11.sp,
                  fontWeight: FontWeight.w800,
                  color: CaseLibraryColors.primaryGreen,
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 6.h),
        Text(
          '依序從「法理拆解」走向「沉浸攻防」與「公民回響」，完整參與本案思辨旅程。',
          style: LightTextStyles.bodySmall(context),
        ),
        SizedBox(height: 8.h),
        ClipRRect(
          borderRadius: BorderRadius.circular(999),
          child: LinearProgressIndicator(
            value: progress,
            minHeight: 6.h,
            backgroundColor: CaseLibraryColors.borderLight,
            valueColor: const AlwaysStoppedAnimation<Color>(
              CaseLibraryColors.primaryGreen,
            ),
          ),
        ),
        SizedBox(height: 14.h),

        // Step 1 · 法理拆解
        const _DeliberationStepHeader(
          stepNumber: 'STEP 1',
          title: '法理拆解',
          subtitle: '先弄懂關鍵詞彙與各方立場',
          accentColor: Color(0xFF6D649A),
        ),
        SizedBox(height: 8.h),
        _DeliberationStepCard(
          iconSvg: CaseLibrarySvgIcons.bookOpen,
          title: '法律詞卡',
          preview: vocabPreview,
          isExplored: _exploredTools.contains('vocab'),
          backgroundColor: const Color(0xFFFFF8E6),
          accentColor: const Color(0xFF9E7B2D),
          onTap: () => _openDeliberationTool(
            'vocab',
            () => CaseLegalVocabularyPage(book: book),
          ),
        ),
        SizedBox(height: 8.h),
        _DeliberationStepCard(
          iconSvg: CaseLibrarySvgIcons.sparkles,
          title: '觀點光譜',
          preview: spectrumPreview,
          isExplored: _exploredTools.contains('spectrum'),
          backgroundColor: const Color(0xFFF3F1FA),
          accentColor: const Color(0xFF6D649A),
          onTap: () => _openDeliberationTool(
            'spectrum',
            () => CaseOpinionSpectrumPage(book: book),
          ),
        ),
        SizedBox(height: 14.h),

        // Step 2 · 沉浸攻防
        const _DeliberationStepHeader(
          stepNumber: 'STEP 2',
          title: '沉浸攻防',
          subtitle: '進入法庭角色做出判斷與詰問',
          accentColor: Color(0xFF357A53),
        ),
        SizedBox(height: 8.h),
        _DeliberationStepCard(
          iconSvg: CaseLibrarySvgIcons.scale,
          title: '如果你是法官',
          preview: judgePreview,
          isExplored: _exploredTools.contains('judge'),
          backgroundColor: const Color(0xFFEAF6EF),
          accentColor: const Color(0xFF357A53),
          onTap: () => _openDeliberationTool(
            'judge',
            () => CaseJudgePracticePage(book: book),
          ),
        ),
        SizedBox(height: 8.h),
        _DeliberationStepCard(
          iconSvg: CaseLibrarySvgIcons.message,
          title: '虛擬詰問室',
          preview: witnessPreview,
          isExplored: _exploredTools.contains('witness'),
          backgroundColor: const Color(0xFFEAF4F7),
          accentColor: const Color(0xFF4A7C8C),
          onTap: () => _openDeliberationTool(
            'witness',
            () => CaseWitnessCrossPage(book: book),
          ),
        ),
        SizedBox(height: 14.h),

        // Step 3 · 公民回響
        const _DeliberationStepHeader(
          stepNumber: 'STEP 3',
          title: '公民回響',
          subtitle: '看見判決後的社會效應與公共討論',
          accentColor: Color(0xFFCD5C5C),
        ),
        SizedBox(height: 8.h),
        _DeliberationStepCard(
          iconSvg: CaseLibrarySvgIcons.brain,
          title: '社會效應圖譜',
          preview: socialPreview,
          isExplored: _exploredTools.contains('social'),
          backgroundColor: const Color(0xFFF7F4EC),
          accentColor: const Color(0xFF6A706C),
          onTap: () => _openDeliberationTool(
            'social',
            () => CaseSocialGraphPage(book: book),
          ),
        ),
        SizedBox(height: 8.h),
        _DeliberationStepCard(
          iconSvg: CaseLibrarySvgIcons.filePen,
          title: '意見塗鴉牆',
          preview: opinionPreview,
          isExplored: _exploredTools.contains('opinion'),
          backgroundColor: const Color(0xFFFDECEE),
          accentColor: const Color(0xFFCD5C5C),
          onTap: () => _openDeliberationTool(
            'opinion',
            () => CaseOpinionBoardPage(book: book),
          ),
        ),
      ],
    );
  }

  Widget _buildDossierFooterActions(BuildContext context) {
    final refreshedLabel = _lastRefreshedAt == null
        ? '下拉或點擊右側按鈕可重新整理卷宗'
        : '最近更新：${_lastRefreshedAt!.hour.toString().padLeft(2, '0')}:${_lastRefreshedAt!.minute.toString().padLeft(2, '0')}';

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: CaseLibraryColors.borderLight),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              refreshedLabel,
              style: TextStyle(
                fontSize: 11.sp,
                color: CaseLibraryColors.textSecondary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          SizedBox(width: 8.w),
          TextButton(
            onPressed: _isRefreshing ? null : _refreshDossier,
            style: TextButton.styleFrom(
              foregroundColor: CaseLibraryColors.primaryGreen,
              padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: Text(
              _isRefreshing ? '整理中...' : '重新整理',
              style: TextStyle(
                fontSize: 11.5.sp,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          SizedBox(width: 4.w),
          OutlinedButton(
            onPressed: _scrollToTop,
            style: OutlinedButton.styleFrom(
              foregroundColor: CaseLibraryColors.primaryGreen,
              side: BorderSide(
                color: CaseLibraryColors.primaryGreen.withValues(alpha: 0.35),
              ),
              padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(999),
              ),
            ),
            child: Text(
              '回到頂部',
              style: TextStyle(
                fontSize: 11.5.sp,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DualCodingIssueCard extends StatelessWidget {
  const _DualCodingIssueCard({
    required this.index,
    required this.issue,
    required this.lawLabels,
    required this.isFocused,
    required this.hasLawTab,
    required this.onToggleFocus,
    required this.onTapLawChip,
    required this.onAskAssistant,
    required this.onOpenJudgePractice,
  });

  final int index;
  final LegalIssue issue;
  final List<String> lawLabels;
  final bool isFocused;
  final bool hasLawTab;
  final VoidCallback onToggleFocus;
  final VoidCallback onTapLawChip;
  final VoidCallback onAskAssistant;
  final VoidCallback onOpenJudgePractice;

  @override
  Widget build(BuildContext context) {
    final issueNumber = '爭點 ${(index + 1).toString().padLeft(2, '0')}';

    return Container(
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: isFocused
              ? CaseLibraryColors.primaryGreen.withValues(alpha: 0.45)
              : CaseLibraryColors.borderLight,
          width: isFocused ? 1.4 : 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
                decoration: BoxDecoration(
                  color: CaseLibraryColors.primaryGreen,
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Text(
                  issueNumber,
                  style: TextStyle(
                    fontSize: 10.5.sp,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
              ),
              SizedBox(width: 8.w),
              Expanded(
                child: Text(
                  issue.title,
                  style: TextStyle(
                    fontSize: 14.sp,
                    height: 1.4,
                    fontWeight: FontWeight.w900,
                    color: CaseLibraryColors.primaryGreen,
                  ),
                ),
              ),
              SizedBox(width: 6.w),
              InkWell(
                onTap: onToggleFocus,
                borderRadius: BorderRadius.circular(999),
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                  decoration: BoxDecoration(
                    color: isFocused
                        ? const Color(0xFFFFF4D6)
                        : CaseLibraryColors.bgCream,
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(
                      color: isFocused
                          ? CaseLibraryColors.accentGold
                          : CaseLibraryColors.borderLight,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        isFocused
                            ? Icons.bookmark_rounded
                            : Icons.bookmark_border_rounded,
                        size: 14.sp,
                        color: isFocused
                            ? const Color(0xFF9E7B2D)
                            : CaseLibraryColors.textSecondary,
                      ),
                      SizedBox(width: 3.w),
                      Text(
                        isFocused ? '已標記' : '標記',
                        style: TextStyle(
                          fontSize: 10.5.sp,
                          fontWeight: FontWeight.w700,
                          color: isFocused
                              ? const Color(0xFF9E7B2D)
                              : CaseLibraryColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          if (issue.plainExplanation.trim().isNotEmpty) ...[
            SizedBox(height: 10.h),
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(10.w),
              decoration: BoxDecoration(
                color: CaseLibraryColors.bgCream,
                borderRadius: BorderRadius.circular(10.r),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '白話核心重點',
                    style: TextStyle(
                      fontSize: 11.sp,
                      fontWeight: FontWeight.w800,
                      color: CaseLibraryColors.primaryGreen,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    issue.plainExplanation,
                    style: TextStyle(
                      fontSize: 12.5.sp,
                      height: 1.55,
                      color: CaseLibraryColors.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
          ],
          if (issue.relationToCase.trim().isNotEmpty) ...[
            SizedBox(height: 8.h),
            Text(
              '本案關鍵關聯：${issue.relationToCase}',
              style: TextStyle(
                fontSize: 12.sp,
                height: 1.5,
                fontWeight: FontWeight.w600,
                color: CaseLibraryColors.textSecondary,
              ),
            ),
          ],
          if (lawLabels.isNotEmpty) ...[
            SizedBox(height: 10.h),
            Wrap(
              spacing: 6.w,
              runSpacing: 6.h,
              children: lawLabels.map((lawLabel) {
                return InkWell(
                  onTap: hasLawTab ? onTapLawChip : null,
                  borderRadius: BorderRadius.circular(999),
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 10.w,
                      vertical: 5.h,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEEF4F1),
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(
                        color: CaseLibraryColors.primaryGreen
                            .withValues(alpha: 0.22),
                      ),
                    ),
                    child: Text(
                      '$lawLabel →',
                      style: TextStyle(
                        fontSize: 11.sp,
                        fontWeight: FontWeight.w700,
                        color: CaseLibraryColors.primaryGreen,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
          SizedBox(height: 12.h),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: onAskAssistant,
                  icon: CaseLibrarySvgIcon(
                    CaseLibrarySvgIcons.sparkles,
                    size: 14.sp,
                    color: CaseLibraryColors.primaryGreen,
                  ),
                  label: Text(
                    '問小法助拆解',
                    style: TextStyle(
                      fontSize: 11.5.sp,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: CaseLibraryColors.primaryGreen,
                    side: BorderSide(
                      color:
                          CaseLibraryColors.primaryGreen.withValues(alpha: 0.35),
                    ),
                    padding: EdgeInsets.symmetric(vertical: 8.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                  ),
                ),
              ),
              SizedBox(width: 8.w),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: onOpenJudgePractice,
                  icon: CaseLibrarySvgIcon(
                    CaseLibrarySvgIcons.scale,
                    size: 14.sp,
                    color: Colors.white,
                  ),
                  label: Text(
                    '進模擬法庭判這題',
                    style: TextStyle(
                      fontSize: 11.5.sp,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: CaseLibraryColors.primaryGreen,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: EdgeInsets.symmetric(vertical: 8.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _DeliberationStepHeader extends StatelessWidget {
  const _DeliberationStepHeader({
    required this.stepNumber,
    required this.title,
    required this.subtitle,
    required this.accentColor,
  });

  final String stepNumber;
  final String title;
  final String subtitle;
  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
          decoration: BoxDecoration(
            color: accentColor.withValues(alpha: 0.14),
            borderRadius: BorderRadius.circular(6.r),
          ),
          child: Text(
            stepNumber,
            style: TextStyle(
              fontSize: 10.sp,
              fontWeight: FontWeight.w900,
              color: accentColor,
            ),
          ),
        ),
        SizedBox(width: 8.w),
        Text(
          title,
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w900,
            color: CaseLibraryColors.textPrimary,
          ),
        ),
        SizedBox(width: 8.w),
        Expanded(
          child: Text(
            subtitle,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 11.sp,
              color: CaseLibraryColors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}

class _DeliberationStepCard extends StatelessWidget {
  const _DeliberationStepCard({
    required this.iconSvg,
    required this.title,
    required this.preview,
    required this.isExplored,
    required this.backgroundColor,
    required this.accentColor,
    required this.onTap,
  });

  final String iconSvg;
  final String title;
  final String preview;
  final bool isExplored;
  final Color backgroundColor;
  final Color accentColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14.r),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 11.h),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(14.r),
          border: Border.all(
            color: isExplored
                ? accentColor.withValues(alpha: 0.45)
                : accentColor.withValues(alpha: 0.18),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 36.w,
              height: 36.w,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.85),
                borderRadius: BorderRadius.circular(10.r),
              ),
              child: Center(
                child: CaseLibrarySvgIcon(
                  iconSvg,
                  size: 18.sp,
                  color: accentColor,
                ),
              ),
            ),
            SizedBox(width: 10.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          title,
                          style: TextStyle(
                            fontSize: 13.5.sp,
                            fontWeight: FontWeight.w900,
                            color: CaseLibraryColors.textPrimary,
                          ),
                        ),
                      ),
                      SizedBox(width: 6.w),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 7.w,
                          vertical: 2.h,
                        ),
                        decoration: BoxDecoration(
                          color: isExplored
                              ? accentColor
                              : Colors.white.withValues(alpha: 0.85),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          isExplored ? '已探索 ✓' : '待探索',
                          style: TextStyle(
                            fontSize: 10.sp,
                            fontWeight: FontWeight.w800,
                            color: isExplored ? Colors.white : accentColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    preview,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 11.5.sp,
                      height: 1.4,
                      color: CaseLibraryColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(width: 6.w),
            CaseLibrarySvgIcon(
              CaseLibrarySvgIcons.chevronRight,
              size: 12.sp,
              color: accentColor,
            ),
          ],
        ),
      ),
    );
  }
}
