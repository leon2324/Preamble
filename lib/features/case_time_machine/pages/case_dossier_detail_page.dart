import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:lawapp/theme/app_fonts.dart';
import 'package:lawapp/features/case_time_machine/data/case_time_machine_mock_data.dart';
import 'package:lawapp/features/case_time_machine/data/case_time_machine_repository.dart';
import 'package:lawapp/features/case_time_machine/models/case_time_machine_models.dart';
import 'package:lawapp/features/case_time_machine/theme/case_time_machine_theme.dart';
import 'package:lawapp/features/case_time_machine/widgets/case_time_machine_svg_icon.dart';
import 'package:lawapp/features/case_time_machine/pages/case_time_machine_search_page.dart';
import 'package:lawapp/features/case_time_machine/pages/case_netizen_chat_room_page.dart';
import 'package:lawapp/features/case_time_machine/pages/case_judge_practice_page.dart';
import 'package:lawapp/features/case_time_machine/pages/case_opinion_spectrum_page.dart';
import 'package:lawapp/features/case_time_machine/pages/case_legal_vocabulary_page.dart';
import 'package:lawapp/features/case_time_machine/pages/case_witness_cross_page.dart';
import 'package:lawapp/features/case_time_machine/pages/case_social_graph_page.dart';
import 'package:lawapp/features/case_time_machine/pages/case_opinion_board_page.dart';
import 'package:lawapp/pages/learning/know_law_page.dart';

class LightTextStyles {
  static TextStyle displayTitle(BuildContext context) =>
      CaseTimeMachineTextStyles.displayTitle(context)
          .copyWith(color: CaseTimeMachineColors.primaryGreen);

  static TextStyle pageTitle(BuildContext context) =>
      CaseTimeMachineTextStyles.pageTitle(context)
          .copyWith(color: CaseTimeMachineColors.primaryGreen);

  static TextStyle sectionTitle(BuildContext context) =>
      CaseTimeMachineTextStyles.sectionTitle(context)
          .copyWith(color: CaseTimeMachineColors.primaryGreen);

  static TextStyle cardTitle(BuildContext context) =>
      CaseTimeMachineTextStyles.cardTitle(context)
          .copyWith(color: CaseTimeMachineColors.textPrimary);

  static TextStyle body(BuildContext context) =>
      CaseTimeMachineTextStyles.body(context)
          .copyWith(color: CaseTimeMachineColors.textPrimary);

  static TextStyle bodySmall(BuildContext context) =>
      CaseTimeMachineTextStyles.bodySmall(context)
          .copyWith(color: CaseTimeMachineColors.textSecondary);

  static TextStyle caption(BuildContext context) =>
      CaseTimeMachineTextStyles.caption(context)
          .copyWith(color: CaseTimeMachineColors.textMuted);

  static TextStyle chipText(BuildContext context) =>
      CaseTimeMachineTextStyles.chipText(context)
          .copyWith(color: CaseTimeMachineColors.accentGold);
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

  late String _selectedTab;
  bool _isSaved = false;
  bool _isFollowed = false;
  bool _isTimelineExpanded = false;

  late final PageController _galleryController;
  int _galleryIndex = 0;

  // 台灣繁體中文教學註解：
  // 完整判決書分頁錨點滾動所使用的 GlobalKey，維持跨 Build 的狀態一致性。
  final GlobalKey _mainVerdictKey = GlobalKey();
  final GlobalKey _proceduralKey = GlobalKey();
  final GlobalKey _reasoningKey = GlobalKey();
  final GlobalKey _lawsKey = GlobalKey();

  // 台灣繁體中文教學註解：
  // 定義自訂的 SVG 圖示字串，避免使用 Google Material Icons。
  static const String _svgNotesIcon = '''
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" width="24" height="24" fill="none" stroke="#1B3F38" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
  <path d="M14 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V8z"></path>
  <polyline points="14 2 14 8 20 8"></polyline>
  <line x1="16" y1="13" x2="8" y2="13"></line>
  <line x1="16" y1="17" x2="8" y2="17"></line>
  <polyline points="10 9 9 9 8 9"></polyline>
</svg>
''';

  static const String _svgShareIcon = '''
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" width="24" height="24" fill="none" stroke="#1B3F38" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
  <path d="M4 12v8a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2v-8"></path>
  <polyline points="16 6 12 2 8 6"></polyline>
  <line x1="12" y1="2" x2="12" y2="15"></line>
</svg>
''';
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

  static const String _svgStarOutlineIcon = '''
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" width="24" height="24" fill="none" stroke="#1B3F38" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
  <polygon points="12 2 15.09 8.26 22 9.27 17 14.14 18.18 21.02 12 17.77 5.82 21.02 7 14.14 2 9.27 8.91 8.26 12 2"></polygon>
</svg>
''';

  static const String _svgStarFilledIcon = '''
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" width="24" height="24" fill="#1B3F38">
  <polygon points="12 2 15.09 8.26 22 9.27 17 14.14 18.18 21.02 12 17.77 5.82 21.02 7 14.14 2 9.27 8.91 8.26 12 2"></polygon>
</svg>
''';

  static const String _svgAddIcon = '''
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" width="24" height="24" fill="none" stroke="#FFFFFF" stroke-width="3" stroke-linecap="round" stroke-linejoin="round">
  <line x1="12" y1="5" x2="12" y2="19"></line>
  <line x1="5" y1="12" x2="19" y2="12"></line>
</svg>
''';

  static const String _svgCheckIcon = '''
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" width="24" height="24" fill="none" stroke="#FFFFFF" stroke-width="3" stroke-linecap="round" stroke-linejoin="round">
  <polyline points="20 6 9 17 4 12"></polyline>
</svg>
''';

  // 台灣繁體中文教學註解：
  // 為「鄉民討論」分頁設計的狀態變數，包含留言輸入控制、立場選擇、各案件的即時投開票數據、以及即時按讚與新增留言的快取。
  final TextEditingController _commentController = TextEditingController();
  String _selectedStance = '中立派';
  final Map<String, String> _myVotes = {};

  // 台灣繁體中文教學註解：
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
    if (book.courtReasoning.isNotEmpty || book.courtArguments.isNotEmpty || book.investigationAndTrial.isNotEmpty) {
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
          await CaseTimeMachineRepository.instance.getCaseDetail(book.id);
      if (mounted) {
        setState(() {
          _detailedBook = detail;
          _isLoading = false;
          // 重新計算 Tab，防 Placeholder 空欄位導致 Tab 被隱藏
          final tabs = _availableTabs;
          if (widget.initialTab != null && tabs.contains(widget.initialTab)) {
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
        });
      }
    }
  }

  CaseBook get book => _detailedBook ?? widget.book;

  @override
  void dispose() {
    _galleryController.dispose();
    _commentController.dispose();
    super.dispose();
  }

  void _openRelatedCase(BuildContext context, String caseId) {
    final relatedBook = caseTimeMachineCaseById(caseId);
    Navigator.of(context).push(
      CupertinoPageRoute<void>(
        builder: (_) => CaseDossierDetailPage(book: relatedBook),
      ),
    );
  }

  Widget _buildContentCard({
    required Widget child,
    Color accentColor = CaseTimeMachineColors.accentGold,
    EdgeInsetsGeometry? padding,
  }) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: CaseTimeMachineColors.bgWhite,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12.r),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                width: 4.w,
                color: accentColor,
              ),
              Expanded(
                child: Padding(
                  padding: padding ?? EdgeInsets.all(16.w),
                  child: child,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingState(BuildContext context) {
    return Scaffold(
      backgroundColor: CaseTimeMachineColors.bgCream,
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
                            CaseTimeMachineColors.primaryGreen,
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
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(
                        CaseTimeMachineColors.primaryGreen,
                      ),
                    ),
                    SizedBox(height: 20.h),
                    Text(
                      '正在安全調閱雲端卷宗...',
                      style: TextStyle(
                        fontSize: 13.5.sp,
                        fontWeight: FontWeight.bold,
                        color: CaseTimeMachineColors.primaryGreen,
                      ),
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

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return _buildLoadingState(context);
    }

    final book = _detailedBook ?? widget.book;
    final displayImages = book.images.isNotEmpty
        ? book.images
        : const [
            CaseImage(
              url:
                  'https://images.unsplash.com/photo-1589829545856-d10d557cf95f?auto=format&fit=crop&w=800&q=80',
              source: 'Unsplash',
            ),
            CaseImage(
              url:
                  'https://images.unsplash.com/photo-1505664194779-8bebcb95df84?auto=format&fit=crop&w=800&q=80',
              source: 'Unsplash',
            ),
            CaseImage(
              url:
                  'https://images.unsplash.com/photo-1521587760476-6c12a4b040da?auto=format&fit=crop&w=800&q=80',
              source: 'Unsplash',
            ),
          ];

    return Scaffold(
      backgroundColor: CaseTimeMachineColors.bgCream,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // Shorter, elegant top App Bar (Centered Title & AI Assistant shortcut)
            // 台灣繁體中文教學註解：
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
                    // 台灣繁體中文教學註解：
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
                            CaseTimeMachineColors.primaryGreen,
                            BlendMode.srcIn,
                          ),
                        ),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ),
                    // 台灣繁體中文教學註解：
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
                    // 台灣繁體中文教學註解：
                    // 右側僅放置單一討論功能按鈕，將原有的聊天室圖示替換為音波圖示，並防切邊右移 12.w 對齊。
                    Positioned(
                      right: 0,
                      child: IconButton(
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        icon: CtmSvgIcon(
                          CtmSvgIcons.waveform3,
                          size: 22.w,
                          color: CaseTimeMachineColors.primaryGreen,
                        ),
                        tooltip: '查看鄉民思辨討論',
                        onPressed: () {
                          // 台灣繁體中文教學註解：
                          // 點擊右側討論按鈕後，直接 Push 跳轉進入全新的「專屬聊天討論室（CaseNetizenChatRoomPage）」，
                          // 並將數據引用傳入以進行多頁面間的資料即時同步。
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
                    ),
                  ],
                ),
              ),
            ),

            Expanded(
              child: NestedScrollView(
                physics: const BouncingScrollPhysics(
                  parent: AlwaysScrollableScrollPhysics(),
                ),
                headerSliverBuilder: (context, innerBoxIsScrolled) {
                  return [
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
                                    return Image.network(
                                      image.url,
                                      fit: BoxFit.cover,
                                      width: double.infinity,
                                      errorBuilder:
                                          (context, error, stackTrace) =>
                                              Container(
                                        color:
                                            CaseTimeMachineColors.borderLight,
                                        child: Center(
                                          child: CtmSvgIcon(
                                            CtmSvgIcons.imageOff,
                                            size: 40.w,
                                            color:
                                                CaseTimeMachineColors.textMuted,
                                          ),
                                        ),
                                      ),
                                      loadingBuilder:
                                          (context, child, loadingProgress) {
                                        if (loadingProgress == null) {
                                          return child;
                                        }
                                        return Container(
                                          color: CaseTimeMachineColors
                                              .borderLight
                                              .withValues(alpha: 0.5),
                                          child: const Center(
                                              child:
                                                  CupertinoActivityIndicator()),
                                        );
                                      },
                                    );
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
                                        color: CaseTimeMachineColors.accentGold,
                                      ),
                                    ),
                                    SizedBox(width: 8.w),
                                    Text(
                                      '|  ${book.location}  |  ${book.status}',
                                      style: TextStyle(
                                        fontSize: 11.sp,
                                        fontWeight: FontWeight.bold,
                                        color: CaseTimeMachineColors.textMuted,
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
                                    color: CaseTimeMachineColors.primaryGreen,
                                  ),
                                ),
                                SizedBox(height: 10.h),
                                // Tags
                                // 台灣繁體中文教學註解：
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
                                                  CaseTimeMachineSearchPage(
                                                      initialQuery: tag),
                                            ),
                                          );
                                        },
                                        child: Container(
                                          margin: EdgeInsets.only(right: 6.w),
                                          padding: EdgeInsets.symmetric(
                                              horizontal: 10.w, vertical: 4.h),
                                          decoration: BoxDecoration(
                                            color: CaseTimeMachineColors
                                                .primaryGreen
                                                .withValues(alpha: 0.08),
                                            borderRadius:
                                                BorderRadius.circular(4.r),
                                          ),
                                          child: Text(
                                            '#$tag',
                                            style: TextStyle(
                                              fontSize: 10.sp,
                                              color: CaseTimeMachineColors
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
                                      badgeBorderColor = const Color(0xFFC7E6D7);
                                      badgeTitle = '無罪宣告';
                                    } else if (result.contains('違憲') || result.contains('合憲')) {
                                      badgeBgColor = const Color(0xFFFFF7E6);
                                      badgeTextColor = const Color(0xFFB37D14);
                                      badgeBorderColor = const Color(0xFFFFE7B3);
                                      badgeTitle = '憲法裁決';
                                    } else if (result.contains('徒刑') || result.contains('有罪') || result.contains('罰')) {
                                      badgeBgColor = const Color(0xFFFFF1F0);
                                      badgeTextColor = const Color(0xFFAD352B);
                                      badgeBorderColor = const Color(0xFFFFA39E);
                                      badgeTitle = '刑事處置';
                                    } else {
                                      badgeBgColor = const Color(0xFFF0F4F8);
                                      badgeTextColor = const Color(0xFF3C5A80);
                                      badgeBorderColor = const Color(0xFFD0E1FD);
                                      badgeTitle = '最終裁決';
                                    }
                                    return Container(
                                      width: double.infinity,
                                      margin: EdgeInsets.only(bottom: 14.h),
                                      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
                                      decoration: BoxDecoration(
                                        color: badgeBgColor,
                                        borderRadius: BorderRadius.circular(10.r),
                                        border: Border.all(
                                          color: badgeBorderColor,
                                          width: 1.2,
                                        ),
                                      ),
                                      child: Row(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Container(
                                            padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
                                            decoration: BoxDecoration(
                                              color: badgeTextColor.withValues(alpha: 0.12),
                                              borderRadius: BorderRadius.circular(4.r),
                                            ),
                                            child: Text(
                                              badgeTitle,
                                              style: TextStyle(
                                                fontSize: 10.sp,
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
                                                fontSize: 12.sp,
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
                                      color: CaseTimeMachineColors.primaryGreen,
                                    ),
                                  ),
                                ),
                                SizedBox(height: 20.h),

                                // 事件摘要 Section
                                Text(
                                  '事件摘要',
                                  style: LightTextStyles.sectionTitle(context)
                                      .copyWith(
                                    fontSize: 15.sp,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                                SizedBox(height: 8.h),
                                _buildRichTextWithGlossary(
                                  context,
                                  book.background,
                                  LightTextStyles.body(context).copyWith(
                                    fontSize: 13.sp,
                                    height: 1.6,
                                  ),
                                ),
                                SizedBox(height: 20.h),

                                // 主要爭點 Section
                                Text(
                                  '主要爭點',
                                  style: LightTextStyles.sectionTitle(context)
                                      .copyWith(
                                    fontSize: 15.sp,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                                SizedBox(height: 8.h),
                                Column(
                                  children: book.legalIssues.map((issue) {
                                    return Padding(
                                      padding: EdgeInsets.only(bottom: 10.h),
                                      child: Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Padding(
                                            padding: EdgeInsets.only(top: 2.h),
                                            child: CtmSvgIcon(
                                              CtmSvgIcons.question,
                                              size: 16.sp,
                                              color: CaseTimeMachineColors
                                                  .primaryGreen,
                                            ),
                                          ),
                                          SizedBox(width: 8.w),
                                          Expanded(
                                            child: Text(
                                              issue.title,
                                              style: TextStyle(
                                                fontSize: 13.sp,
                                                height: 1.45,
                                                fontWeight: FontWeight.w800,
                                                color: CaseTimeMachineColors
                                                    .primaryGreen,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  }).toList(),
                                ),
                                SizedBox(height: 20.h),

                                // 台灣繁體中文教學註解：
                                // 「思辨與探索」快捷方格 — 移自圖書館首頁，放在案件詳情頁更符合脈絡。
                                // 使用者已在瀏覽特定案件時，才最需要這些分析工具。
                                Text(
                                  '思辨與探索',
                                  style: LightTextStyles.sectionTitle(context)
                                      .copyWith(
                                    fontSize: 14.sp,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                                SizedBox(height: 10.h),
                                Column(
                                  children: [
                                    Row(
                                      children: [
                                        Expanded(
                                          child: _ExploreShortcutTile(
                                            iconSvg: CtmSvgIcons.scale,
                                            title: '如果你是法官',
                                            subtitle: '模擬司法天平裁判',
                                            backgroundColor:
                                                const Color(0xFFEAF6EF),
                                            foregroundColor:
                                                const Color(0xFF357A53),
                                            onTap: () =>
                                                Navigator.of(context).push(
                                              CupertinoPageRoute<void>(
                                                builder: (_) =>
                                                    CaseJudgePracticePage(
                                                        book: book),
                                              ),
                                            ),
                                          ),
                                        ),
                                        SizedBox(width: 8.w),
                                        Expanded(
                                          child: _ExploreShortcutTile(
                                            iconSvg: CtmSvgIcons.sparkles,
                                            title: '觀點光譜',
                                            subtitle: '透視各界爭議光譜',
                                            backgroundColor:
                                                const Color(0xFFF0EEF9),
                                            foregroundColor:
                                                const Color(0xFF6D649A),
                                            onTap: () =>
                                                Navigator.of(context).push(
                                              CupertinoPageRoute<void>(
                                                builder: (_) =>
                                                    CaseOpinionSpectrumPage(
                                                        book: book),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 8.h),
                                    Row(
                                      children: [
                                        Expanded(
                                          child: _ExploreShortcutTile(
                                            iconSvg: CtmSvgIcons.message,
                                            title: '虛擬詰問室',
                                            subtitle: 'AI詰問關係人證詞',
                                            backgroundColor:
                                                const Color(0xFFEAF4F7),
                                            foregroundColor:
                                                const Color(0xFF4A7C8C),
                                            onTap: () =>
                                                Navigator.of(context).push(
                                              CupertinoPageRoute<void>(
                                                builder: (_) =>
                                                    CaseWitnessCrossPage(
                                                        book: book),
                                              ),
                                            ),
                                          ),
                                        ),
                                        SizedBox(width: 8.w),
                                        Expanded(
                                          child: _ExploreShortcutTile(
                                            iconSvg: CtmSvgIcons.bookOpen,
                                            title: '法律詞卡',
                                            subtitle: '翻閱基礎法律釋義',
                                            backgroundColor:
                                                const Color(0xFFFFF2CF),
                                            foregroundColor:
                                                const Color(0xFF9E7B2D),
                                            onTap: () =>
                                                Navigator.of(context).push(
                                              CupertinoPageRoute<void>(
                                                builder: (_) =>
                                                    const CaseLegalVocabularyPage(),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 8.h),
                                    Row(
                                      children: [
                                        Expanded(
                                          child: _ExploreShortcutTile(
                                            iconSvg: CtmSvgIcons.brain,
                                            title: '社會效應圖譜',
                                            subtitle: '探索本案社會變革',
                                            backgroundColor:
                                                const Color(0xFFFAF7F0),
                                            foregroundColor:
                                                const Color(0xFF8B928D),
                                            onTap: () =>
                                                Navigator.of(context).push(
                                              CupertinoPageRoute<void>(
                                                builder: (_) =>
                                                    CaseSocialGraphPage(
                                                        book: book),
                                              ),
                                            ),
                                          ),
                                        ),
                                        SizedBox(width: 8.w),
                                        Expanded(
                                          child: _ExploreShortcutTile(
                                            iconSvg: CtmSvgIcons.filePen,
                                            title: '意見塗鴉牆',
                                            subtitle: '發表你的理性見解',
                                            backgroundColor:
                                                const Color(0xFFFDECEE),
                                            foregroundColor:
                                                const Color(0xFFCD5C5C),
                                            onTap: () =>
                                                Navigator.of(context).push(
                                              CupertinoPageRoute<void>(
                                                builder: (_) =>
                                                    CaseOpinionBoardPage(
                                                        book: book),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
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
                        child: _buildDossierTabBar(context, pinned: true),
                      ),
                    ),
                  ];
                },
                body: CustomScrollView(
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
                          // 台灣繁體中文教學註解：
                          // 實作精緻的莫蘭迪粉綠漸層「小法助 AI 捷徑」橫幅（Banner），並改用 sparkling 圖示。
                          GestureDetector(
                            onTap: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('✨ 正在開啟 AI 小法助對話，為您解析本案判決...'),
                                  duration: Duration(seconds: 2),
                                ),
                              );
                              Navigator.of(context).push(
                                CupertinoPageRoute<void>(
                                  builder: (_) => LawAssistantSearchPage(
                                    initialPrompt: '對「${book.titleZh}」的判決有疑問，請 AI 小法助協助解答。',
                                  ),
                                ),
                              );
                            },
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 16.w, vertical: 14.h),
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [Color(0xFFFAF8F5), Color(0xFFE6EFEA)],
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
                                      color: Colors.white.withValues(alpha: 0.7),
                                      shape: BoxShape.circle,
                                    ),
                                    child: CtmSvgIcon(
                                      CtmSvgIcons.sparkles,
                                      size: 20.sp,
                                      color: CaseTimeMachineColors.primaryGreen,
                                    ),
                                  ),
                                  SizedBox(width: 12.w),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          '對本案判決有疑問？點擊詢問 AI 小法助',
                                          style: TextStyle(
                                            fontSize: 13.sp,
                                            fontWeight: FontWeight.bold,
                                            color: CaseTimeMachineColors.primaryGreen,
                                          ),
                                        ),
                                        SizedBox(height: 3.h),
                                        Text(
                                          '為您快速分析裁判意旨與涉及的法律爭點',
                                          style: TextStyle(
                                            fontSize: 10.5.sp,
                                            color: CaseTimeMachineColors.textSecondary,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  CtmSvgIcon(
                                    CtmSvgIcons.chevronRight,
                                    size: 12.sp,
                                    color: CaseTimeMachineColors.primaryGreen,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ]),
                      ),
                    ),
                  ],
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
        color: CaseTimeMachineColors.bgCream,
        border: pinned
            ? const Border(
                bottom: BorderSide(color: CaseTimeMachineColors.borderLight),
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
                          ? CaseTimeMachineColors.primaryGreen
                          : CaseTimeMachineColors.bgWhite,
                      borderRadius: BorderRadius.circular(20.r),
                      border: Border.all(
                        color: isSelected
                            ? CaseTimeMachineColors.primaryGreen
                            : CaseTimeMachineColors.borderLight,
                      ),
                    ),
                    child: Text(
                      tab,
                      style: TextStyle(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.bold,
                        color: isSelected
                            ? CaseTimeMachineColors.bgWhite
                            : CaseTimeMachineColors.textSecondary,
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
  // 台灣繁體中文教學註解：
  // 此處實作為所有案件設計的「鄉民討論」互動分頁。
  // 包含：
  // 1. 法律思辨投開票所 (PK Opinion Poll)：顯示該案在社群上的認同率，投票後展示美觀比例條與票數。
  // 2. 發表觀點欄：使用者可撰寫意見並挑選立場 (合理派/不合理派/中立派)，發言後即時以 setState 動態插入留言板首位。
  // 3. 鄉民留言板 (Salon Comments)：展示多方不同立場的思辨留言，並可點擊愛心進行按讚/取消讚。
  Widget _buildDiscussionsTab(BuildContext context) {
    final votes = _caseVotes[book.id] ?? [50, 50];
    final agreeCount = votes[0];
    final disagreeCount = votes[1];
    final totalVotes = agreeCount + disagreeCount;
    final agreePercent =
        totalVotes > 0 ? (agreeCount / totalVotes * 100).round() : 50;
    final disagreePercent = totalVotes > 0 ? 100 - agreePercent : 50;
    final hasVoted = _myVotes.containsKey(book.id);
    final myChoice = _myVotes[book.id];

    // 初始化該案件留言列表，若無則提供預設留言
    if (!_netizenComments.containsKey(book.id)) {
      _netizenComments[book.id] = [
        {
          'avatar': '理',
          'name': '理性旁觀者',
          'time': '1 小時前',
          'stance': '合理派',
          'stanceColor': const Color(0xFF2E7D32),
          'content':
              '司法裁判的核心是程序正義與證據裁判。雖然有些罪責在情感上讓大家不能接受，但依照既有法規裁決，是確保民主法治不倒退的重要防線。',
          'likes': 15,
          'liked': false,
        },
        {
          'avatar': '正',
          'name': '社會公平維護',
          'time': '2 小時前',
          'stance': '不合理派',
          'stanceColor': const Color(0xFFC62828),
          'content': '我覺得這個案件的處罰或防範機制太過形式化，沒有真正解決核心的社會痛點，相關主管機關的疏失也應該被一併放大檢討！',
          'likes': 9,
          'liked': false,
        },
      ];
    }
    final comments = _netizenComments[book.id]!;

    // 依據案件設定思辨投開票所題目
    String pollQuestion = '對於本案定讞裁定與後續處理，你覺得合理嗎？';
    if (book.id == '318') {
      pollQuestion = '法院認同本案抗爭符合「公民不服從」而宣判黃國昌等 22 人無罪，你覺得合理嗎？';
    } else if (book.id == '161') {
      pollQuestion = '涉案幼兒園與教保員性侵幼童之刑事判決刑度與行政處罰，你覺得合理嗎？';
    } else if (book.id == '124') {
      pollQuestion = '台鐵事故案中，對於事故主因與第一線人員及行政主管責任歸屬判決，你覺得合理嗎？';
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 1. 法律思辨投開票所 (Poll Section)
        Text(
          '法律思辨投開票所',
          style: LightTextStyles.sectionTitle(context).copyWith(
            fontSize: 15.sp,
            fontWeight: FontWeight.w900,
          ),
        ),
        SizedBox(height: 10.h),
        Container(
          padding: EdgeInsets.all(16.w),
          decoration: BoxDecoration(
            color: CaseTimeMachineColors.bgWhite,
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(color: CaseTimeMachineColors.borderLight),
            boxShadow: [CaseTimeMachineShadows.softShadow],
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
                      color: CaseTimeMachineColors.accentGold
                          .withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(4.r),
                    ),
                    child: Text(
                      '鄉民即時 PK',
                      style: TextStyle(
                        fontSize: 9.5.sp,
                        fontWeight: FontWeight.bold,
                        color: CaseTimeMachineColors.accentGold,
                      ),
                    ),
                  ),
                  SizedBox(width: 8.w),
                  Text(
                    '已累積 $totalVotes 人投票',
                    style: TextStyle(
                      fontSize: 10.sp,
                      color: CaseTimeMachineColors.textMuted,
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
                  color: CaseTimeMachineColors.primaryGreen,
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
                        icon: CtmSvgIcon(
                          CtmSvgIcons.thumbsUp,
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
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('👍 投票成功！您投了「合理」')),
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
                        icon: CtmSvgIcon(
                          CtmSvgIcons.thumbsDown,
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
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('👎 投票成功！您投了「不合理」')),
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
                                  color: CaseTimeMachineColors.primaryGreen,
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
                            color: CaseTimeMachineColors.textMuted,
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
            fontSize: 15.sp,
            fontWeight: FontWeight.w900,
          ),
        ),
        SizedBox(height: 10.h),
        Container(
          padding: EdgeInsets.all(14.w),
          decoration: BoxDecoration(
            color: CaseTimeMachineColors.bgWhite,
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(color: CaseTimeMachineColors.borderLight),
            boxShadow: [CaseTimeMachineShadows.softShadow],
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
                      color: CaseTimeMachineColors.textSecondary,
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
                maxLines: 3,
                style: TextStyle(
                    fontSize: 12.5.sp,
                    color: CaseTimeMachineColors.textPrimary),
                decoration: InputDecoration(
                  hintText: '引述法條思辨，在此發表你對於本案判決或爭點的看法...',
                  hintStyle: TextStyle(
                      fontSize: 11.5.sp,
                      color: CaseTimeMachineColors.textMuted),
                  contentPadding: EdgeInsets.all(12.w),
                  filled: true,
                  fillColor: const Color(0xFFF9F9F6),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.r),
                    borderSide: const BorderSide(
                        color: CaseTimeMachineColors.borderLight),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.r),
                    borderSide: const BorderSide(
                        color: CaseTimeMachineColors.primaryGreen, width: 1.2),
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
                      CtmSvgIcon(
                        CtmSvgIcons.gavel,
                        size: 14.sp,
                        color: CaseTimeMachineColors.accentGold,
                      ),
                      SizedBox(width: 4.w),
                      Text(
                        '可點「相關法條」引述條文',
                        style: TextStyle(
                          fontSize: 10.sp,
                          color: CaseTimeMachineColors.accentGold,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: CaseTimeMachineColors.primaryGreen,
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
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('請先輸入看法內容')),
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
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('✏️ 發表看法成功！已同步至留言板')),
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
                fontSize: 15.sp,
                fontWeight: FontWeight.w900,
              ),
            ),
            Text(
              '共 ${comments.length} 條觀點',
              style: TextStyle(
                fontSize: 11.sp,
                color: CaseTimeMachineColors.textMuted,
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
                color: CaseTimeMachineColors.bgWhite,
                borderRadius: BorderRadius.circular(10.r),
                border: Border.all(color: CaseTimeMachineColors.borderLight),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 網友 Header
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 14.r,
                        backgroundColor: CaseTimeMachineColors.bgCream,
                        child: Text(
                          comment['avatar'],
                          style: TextStyle(
                            fontSize: 11.sp,
                            fontWeight: FontWeight.bold,
                            color: CaseTimeMachineColors.primaryGreen,
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
                                  color: CaseTimeMachineColors.textPrimary,
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
                              color: CaseTimeMachineColors.textMuted,
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
                      color: CaseTimeMachineColors.textPrimary,
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
                            CtmSvgIcon(
                              liked
                                  ? CtmSvgIcons.heartFilled
                                  : CtmSvgIcons.heart,
                              size: 14.sp,
                              color: liked
                                  ? Colors.red
                                  : CaseTimeMachineColors.textMuted,
                            ),
                            SizedBox(width: 4.w),
                            Text(
                              '認同 ($likesCount)',
                              style: TextStyle(
                                fontSize: 10.5.sp,
                                color: liked
                                    ? Colors.red
                                    : CaseTimeMachineColors.textMuted,
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

  // 台灣繁體中文教學註解：建立立場選擇 Chip 的輔助方法，點擊時會更換當前選擇的立場。
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
            color: isSelected ? activeColor : CaseTimeMachineColors.borderLight,
            width: 1.2,
          ),
        ),
        child: Text(
          stance,
          style: TextStyle(
            fontSize: 10.5.sp,
            fontWeight: FontWeight.bold,
            color:
                isSelected ? Colors.white : CaseTimeMachineColors.textSecondary,
          ),
        ),
      ),
    );
  }

  Widget _buildBackgroundTab(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (book.background.isNotEmpty) ...[
          Text(
            '事件背景與始末',
            style: LightTextStyles.sectionTitle(context).copyWith(
              fontSize: 15.sp,
              fontWeight: FontWeight.w900,
            ),
          ),
          SizedBox(height: 10.h),
          _buildRichTextWithGlossary(
            context,
            book.background,
            LightTextStyles.body(context).copyWith(
              fontSize: 13.sp,
              height: 1.6,
            ),
          ),
          SizedBox(height: 20.h),
        ],
        if (book.fullStory.isNotEmpty) ...[
          Text(
            '事件詳細經過',
            style: LightTextStyles.sectionTitle(context).copyWith(
              fontSize: 15.sp,
              fontWeight: FontWeight.w900,
            ),
          ),
          SizedBox(height: 10.h),
          _buildRichTextWithGlossary(
            context,
            book.fullStory,
            LightTextStyles.body(context).copyWith(
              fontSize: 13.sp,
              height: 1.6,
            ),
          ),
          SizedBox(height: 20.h),
        ],
        // Sources & Disclaimer
        Text(
          '資料來源與更新時間',
          style: LightTextStyles.sectionTitle(context).copyWith(
            fontSize: 15.sp,
            fontWeight: FontWeight.w900,
          ),
        ),
        SizedBox(height: 8.h),
        _buildContentCard(
          accentColor: CaseTimeMachineColors.textMuted,
          padding: EdgeInsets.all(14.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (final source in book.sources) ...[
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 4.h),
                  child: Row(
                    children: [
                      CtmSvgIcon(
                        CtmSvgIcons.link,
                        size: 16.sp,
                        color: CaseTimeMachineColors.accentGold,
                      ),
                      SizedBox(width: 8.w),
                      Expanded(
                        child: Text(
                          source.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 11.5.sp,
                            fontWeight: FontWeight.bold,
                            color: CaseTimeMachineColors.textPrimary,
                          ),
                        ),
                      ),
                      SizedBox(width: 8.w),
                      Text(
                        source.updatedAt,
                        style: LightTextStyles.caption(context)
                            .copyWith(fontSize: 10.sp),
                      ),
                    ],
                  ),
                ),
                const Divider(color: CaseTimeMachineColors.borderLight),
              ],
              SizedBox(height: 10.h),
              Text(
                '免責聲明：\n本卷宗內容均基於客觀司法裁判與官方公開資訊進行整理，旨在提供公正中立之歷史與法律學習參考，不構成任何正式法律意見。實際個案請諮詢專業律師。',
                style: LightTextStyles.caption(context)
                    .copyWith(height: 1.5, fontSize: 9.5.sp),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCombinedTimelineTab(BuildContext context) {
    // 1. Gather all timeline nodes and trial steps, deduplicate by date
    final Map<String, _CombinedTimelineNode> mergedNodes = {};

    for (final item in book.timeline) {
      mergedNodes[item.dateLabel] = _CombinedTimelineNode(
        date: item.dateLabel,
        title: item.title,
        description: item.description,
        type: 'event',
      );
    }

    final trialSteps = _getTrialSteps(book.id);
    for (final step in trialSteps) {
      mergedNodes[step.date] = _CombinedTimelineNode(
        date: step.date,
        title: '${step.stage} · ${step.courtName}',
        description: step.outcome,
        type: 'trial',
        trialStep: step,
      );
    }

    // 2. Sort by date ascending
    final sortedNodes = mergedNodes.values.toList()
      ..sort((a, b) => a.date.compareTo(b.date));

    // 3. Handle expand/collapse logic
    final displayNodes = _isTimelineExpanded
        ? sortedNodes
        : sortedNodes.take(3).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 案件結果 card (if judgmentResult exists)
        if (book.judgmentResult.isNotEmpty) ...[
          Text(
            '最終裁判結果',
            style: LightTextStyles.sectionTitle(context).copyWith(
              fontSize: 15.sp,
              fontWeight: FontWeight.w900,
            ),
          ),
          SizedBox(height: 10.h),
          _buildContentCard(
            accentColor: CaseTimeMachineColors.primaryGreen,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Text(
                    book.judgmentResult,
                    style: TextStyle(
                      fontSize: 13.sp,
                      height: 1.6,
                      fontWeight: FontWeight.w700,
                      color: CaseTimeMachineColors.textPrimary,
                    ),
                  ),
                ),
                SizedBox(width: 12.w),
                // Gavel emblem inside circle
                Container(
                  width: 48.w,
                  height: 48.w,
                  decoration: const BoxDecoration(
                    color: Color(0xFFE9F2F1),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: CtmSvgIcon(
                      CtmSvgIcons.gavel,
                      size: 22.w,
                      color: CaseTimeMachineColors.primaryGreen,
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 24.h),
        ],

        Text(
          '完整事件與訴訟脈絡',
          style: LightTextStyles.sectionTitle(context).copyWith(
            fontSize: 15.sp,
            fontWeight: FontWeight.w900,
          ),
        ),
        SizedBox(height: 12.h),

        // Vertical Timeline list
        Column(
          children: List.generate(displayNodes.length, (index) {
            final node = displayNodes[index];
            final isLast = index == displayNodes.length - 1;

            if (node.type == 'event') {
              return IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Date label (left)
                    SizedBox(
                      width: 76.w,
                      child: Padding(
                        padding: EdgeInsets.only(top: 2.h),
                        child: Text(
                          node.date,
                          style: TextStyle(
                            fontSize: 11.5.sp,
                            fontWeight: FontWeight.w900,
                            color: CaseTimeMachineColors.accentGold,
                          ),
                        ),
                      ),
                    ),
                    // Middle Line & Dot
                    Column(
                      children: [
                        Container(
                          width: 10.w,
                          height: 10.w,
                          decoration: BoxDecoration(
                            color: CaseTimeMachineColors.primaryGreen,
                            shape: BoxShape.circle,
                            border: Border.all(
                                color: CaseTimeMachineColors.bgCream, width: 2),
                          ),
                        ),
                        if (!isLast)
                          Expanded(
                            child: Container(
                              width: 1.5.w,
                              color: CaseTimeMachineColors.primaryGreen
                                  .withValues(alpha: 0.3),
                            ),
                          ),
                      ],
                    ),
                    SizedBox(width: 14.w),
                    // Content (right)
                    Expanded(
                      child: Padding(
                        padding: EdgeInsets.only(bottom: 20.h),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              node.title,
                              style: TextStyle(
                                fontSize: 13.sp,
                                fontWeight: FontWeight.w900,
                                color: CaseTimeMachineColors.primaryGreen,
                              ),
                            ),
                            SizedBox(height: 4.h),
                            Text(
                              node.description,
                              style: LightTextStyles.bodySmall(context).copyWith(
                                fontSize: 11.5.sp,
                                height: 1.45,
                                color: CaseTimeMachineColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              );
            } else {
              // Trial node (no card box, rendered directly like event items)
              final step = node.trialStep!;
              return IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Date label (left)
                    SizedBox(
                      width: 76.w,
                      child: Padding(
                        padding: EdgeInsets.only(top: 2.h),
                        child: Text(
                          node.date,
                          style: TextStyle(
                            fontSize: 11.5.sp,
                            fontWeight: FontWeight.w900,
                            color: CaseTimeMachineColors.accentGold,
                          ),
                        ),
                      ),
                    ),
                    // Timeline line & dot
                    Column(
                      children: [
                        Container(
                          width: 10.w,
                          height: 10.w,
                          decoration: BoxDecoration(
                            color: CaseTimeMachineColors.accentGold,
                            shape: BoxShape.circle,
                            border: Border.all(
                                color: CaseTimeMachineColors.bgCream, width: 2),
                          ),
                        ),
                        if (!isLast)
                          Expanded(
                            child: Container(
                              width: 1.5.w,
                              color: CaseTimeMachineColors.primaryGreen
                                  .withValues(alpha: 0.3),
                            ),
                          ),
                      ],
                    ),
                    SizedBox(width: 14.w),
                    // Trial Content (right)
                    Expanded(
                      child: Padding(
                        padding: EdgeInsets.only(bottom: 20.h),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Stage Badge + Court Name
                            Row(
                              children: [
                                Container(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 6.w, vertical: 2.h),
                                  decoration: BoxDecoration(
                                    color: CaseTimeMachineColors.accentGold
                                        .withValues(alpha: 0.15),
                                    borderRadius: BorderRadius.circular(4.r),
                                  ),
                                  child: Text(
                                    step.stage,
                                    style: TextStyle(
                                      fontSize: 9.sp,
                                      fontWeight: FontWeight.bold,
                                      color: CaseTimeMachineColors.accentGold,
                                    ),
                                  ),
                                ),
                                SizedBox(width: 8.w),
                                Expanded(
                                  child: Text(
                                    step.courtName,
                                    style: TextStyle(
                                      fontSize: 13.sp,
                                      fontWeight: FontWeight.bold,
                                      color: CaseTimeMachineColors.primaryGreen,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 6.h),
                            Text(
                              step.caseNumber,
                              style: TextStyle(
                                fontSize: 10.5.sp,
                                color: CaseTimeMachineColors.textSecondary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 6.h),
                            Text(
                              step.outcome,
                              style: TextStyle(
                                fontSize: 12.sp,
                                color: const Color(0xFF2E7D32),
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            SizedBox(height: 8.h),
                            GestureDetector(
                              onTap: () => _showHoldingBottomSheet(context, step),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    '檢視裁判理由',
                                    style: TextStyle(
                                      fontSize: 11.sp,
                                      color: CaseTimeMachineColors.accentGold,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                  SizedBox(width: 4.w),
                                  CtmSvgIcon(
                                    CtmSvgIcons.article,
                                    size: 13.sp,
                                    color: CaseTimeMachineColors.accentGold,
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
              );
            }
          }),
        ),

        // Expand / Collapse Timeline button
        if (sortedNodes.length > 3) ...[
          Center(
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _isTimelineExpanded = !_isTimelineExpanded;
                });
              },
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    _isTimelineExpanded ? '收合時間軸' : '查看更多時間軸',
                    style: TextStyle(
                      fontSize: 11.5.sp,
                      color: CaseTimeMachineColors.accentGold,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  CtmSvgIcon(
                    _isTimelineExpanded
                        ? CtmSvgIcons.chevronUp
                        : CtmSvgIcons.chevronRight,
                    size: 16.sp,
                    color: CaseTimeMachineColors.accentGold,
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 24.h),
        ],
      ],
    );
  }

  Widget _buildSocialImpactTab(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '輿論反應與社會影響',
          style: LightTextStyles.sectionTitle(context).copyWith(
            fontSize: 15.sp,
            fontWeight: FontWeight.w900,
          ),
        ),
        SizedBox(height: 12.h),
        _buildContentCard(
          accentColor: const Color(0xFF8E24AA),
          child: Text(
            book.socialImpact,
            style: LightTextStyles.body(context).copyWith(
              fontSize: 13.sp,
              height: 1.6,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLiteratureTab(BuildContext context) {
    return _buildLiteratureSection(context);
  }

  Widget _buildMediaTab(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '延伸影音資訊',
          style: LightTextStyles.sectionTitle(context).copyWith(
            fontSize: 15.sp,
            fontWeight: FontWeight.w900,
          ),
        ),
        SizedBox(height: 10.h),
        for (final ref in book.mediaReferences) ...[
          Container(
            margin: EdgeInsets.only(bottom: 10.h),
            decoration: BoxDecoration(
              color: CaseTimeMachineColors.bgWhite,
              borderRadius: BorderRadius.circular(10.r),
              border: Border.all(color: CaseTimeMachineColors.borderLight),
            ),
            child: ListTile(
              contentPadding:
                  EdgeInsets.symmetric(horizontal: 14.w, vertical: 4.h),
              leading: CircleAvatar(
                backgroundColor: (ref.mediaType == 'podcast'
                        ? const Color(0xFF8E24AA)
                        : ref.mediaType == 'youtube'
                            ? const Color(0xFFD32F2F)
                            : ref.mediaType == 'news'
                                ? const Color(0xFF1976D2)
                                : const Color(0xFF388E3C))
                    .withValues(alpha: 0.1),
                child: CtmSvgIcon(
                  ref.mediaType == 'podcast'
                      ? CtmSvgIcons.podcast
                      : ref.mediaType == 'youtube'
                          ? CtmSvgIcons.playCircle
                          : ref.mediaType == 'news'
                              ? CtmSvgIcons.newspaper
                              : CtmSvgIcons.school,
                  color: ref.mediaType == 'podcast'
                      ? const Color(0xFF8E24AA)
                      : ref.mediaType == 'youtube'
                          ? const Color(0xFFD32F2F)
                          : ref.mediaType == 'news'
                              ? const Color(0xFF1976D2)
                              : const Color(0xFF388E3C),
                  size: 20.sp,
                ),
              ),
              title: Text(
                ref.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 12.5.sp,
                  fontWeight: FontWeight.bold,
                  color: CaseTimeMachineColors.textPrimary,
                ),
              ),
              subtitle: Padding(
                padding: EdgeInsets.only(top: 4.h),
                child: Row(
                  children: [
                    Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                      decoration: BoxDecoration(
                        color: CaseTimeMachineColors.bgCream,
                        borderRadius: BorderRadius.circular(4.r),
                      ),
                      child: Text(
                        ref.platform,
                        style: TextStyle(
                          fontSize: 9.sp,
                          fontWeight: FontWeight.bold,
                          color: CaseTimeMachineColors.textSecondary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              trailing: CtmSvgIcon(
                CtmSvgIcons.externalLink,
                size: 16.sp,
                color: CaseTimeMachineColors.accentGold,
              ),
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('前往媒體：${ref.title}')),
                );
              },
            ),
          ),
        ],
      ],
    );
  }

  // --- TAB 0: 脈絡 ---
  Widget _buildTimelineTab(BuildContext context) {
    final timelineNodes = book.timeline;
    final displayNodes =
        _isTimelineExpanded ? timelineNodes : timelineNodes.take(3).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '事件脈絡',
          style: LightTextStyles.sectionTitle(context).copyWith(
            fontSize: 15.sp,
            fontWeight: FontWeight.w900,
          ),
        ),
        SizedBox(height: 12.h),

        // Vertical Timeline list
        Column(
          children: List.generate(displayNodes.length, (index) {
            final node = displayNodes[index];
            final isLast = index == displayNodes.length - 1;

            return IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Date label (left)
                  SizedBox(
                    width: 76.w,
                    child: Padding(
                      padding: EdgeInsets.only(top: 2.h),
                      child: Text(
                        node.dateLabel,
                        style: TextStyle(
                          fontSize: 11.5.sp,
                          fontWeight: FontWeight.w900,
                          color: CaseTimeMachineColors.accentGold,
                        ),
                      ),
                    ),
                  ),
                  // Middle Line & Dot
                  Column(
                    children: [
                      Container(
                        width: 10.w,
                        height: 10.w,
                        decoration: BoxDecoration(
                          color: CaseTimeMachineColors.primaryGreen,
                          shape: BoxShape.circle,
                          border: Border.all(
                              color: CaseTimeMachineColors.bgCream, width: 2),
                        ),
                      ),
                      if (!isLast)
                        Expanded(
                          child: Container(
                            width: 1.5.w,
                            color: CaseTimeMachineColors.primaryGreen
                                .withValues(alpha: 0.3),
                          ),
                        ),
                    ],
                  ),
                  SizedBox(width: 14.w),
                  // Content (right)
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(bottom: 20.h),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            node.title,
                            style: TextStyle(
                              fontSize: 13.sp,
                              fontWeight: FontWeight.w900,
                              color: CaseTimeMachineColors.primaryGreen,
                            ),
                          ),
                          SizedBox(height: 4.h),
                          Text(
                            node.description,
                            style: LightTextStyles.bodySmall(context).copyWith(
                              fontSize: 11.5.sp,
                              height: 1.45,
                              color: CaseTimeMachineColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
        ),

        // Expand / Collapse Timeline button
        if (timelineNodes.length > 3) ...[
          Center(
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _isTimelineExpanded = !_isTimelineExpanded;
                });
              },
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    _isTimelineExpanded ? '收合時間軸' : '查看更多時間軸',
                    style: TextStyle(
                      fontSize: 11.5.sp,
                      color: CaseTimeMachineColors.accentGold,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  CtmSvgIcon(
                    _isTimelineExpanded
                        ? CtmSvgIcons.chevronUp
                        : CtmSvgIcons.chevronRight,
                    size: 16.sp,
                    color: CaseTimeMachineColors.accentGold,
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 24.h),
        ],

        // 案件結果 card
        if (book.judgmentResult.isNotEmpty) ...[
          Text(
            '案件結果',
            style: LightTextStyles.sectionTitle(context).copyWith(
              fontSize: 15.sp,
              fontWeight: FontWeight.w900,
            ),
          ),
          SizedBox(height: 10.h),
          _buildContentCard(
            accentColor: CaseTimeMachineColors.primaryGreen,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Text(
                    book.judgmentResult,
                    style: TextStyle(
                      fontSize: 13.sp,
                      height: 1.6,
                      fontWeight: FontWeight.w700,
                      color: CaseTimeMachineColors.textPrimary,
                    ),
                  ),
                ),
                SizedBox(width: 12.w),
                // Gavel emblem inside circle
                Container(
                  width: 48.w,
                  height: 48.w,
                  decoration: const BoxDecoration(
                    color: Color(0xFFE9F2F1),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: CtmSvgIcon(
                      CtmSvgIcons.gavel,
                      size: 22.w,
                      color: CaseTimeMachineColors.primaryGreen,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
        SizedBox(height: 24.h),
        Text(
          '訴訟程序與審級進程',
          style: LightTextStyles.sectionTitle(context).copyWith(
            fontSize: 15.sp,
            fontWeight: FontWeight.w900,
          ),
        ),
        SizedBox(height: 12.h),
        _buildLitigationTimeline(context),
      ],
    );
  }

  // --- TAB 1: 爭點 ---
  Widget _buildDisputesTab(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '主要法律爭點',
          style: LightTextStyles.sectionTitle(context).copyWith(
            fontSize: 15.sp,
            fontWeight: FontWeight.w900,
          ),
        ),
        SizedBox(height: 12.h),
        for (final issue in book.legalIssues) ...[
          _buildContentCard(
            accentColor: const Color(0xFF1F4E5B),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  issue.title,
                  style: TextStyle(
                    fontSize: 13.5.sp,
                    fontWeight: FontWeight.w900,
                    color: CaseTimeMachineColors.primaryGreen,
                  ),
                ),
                SizedBox(height: 8.h),
                Text(
                  '法律說明：',
                  style: TextStyle(
                    fontSize: 11.5.sp,
                    fontWeight: FontWeight.w800,
                    color: CaseTimeMachineColors.accentGold,
                  ),
                ),
                SizedBox(height: 2.h),
                _buildRichTextWithGlossary(
                  context,
                  issue.plainExplanation,
                  LightTextStyles.body(context).copyWith(fontSize: 12.sp),
                ),
                SizedBox(height: 8.h),
                Text(
                  '與本案關聯：',
                  style: TextStyle(
                    fontSize: 11.5.sp,
                    fontWeight: FontWeight.w800,
                    color: CaseTimeMachineColors.accentGold,
                  ),
                ),
                SizedBox(height: 2.h),
                _buildRichTextWithGlossary(
                  context,
                  issue.relationToCase,
                  LightTextStyles.bodySmall(context).copyWith(
                    fontSize: 11.5.sp,
                    color: CaseTimeMachineColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 12.h),
        ],
      ],
    );
  }

  // --- TAB 2: 法條 ---
  Widget _buildLawsTab(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '相關法條資訊',
          style: LightTextStyles.sectionTitle(context).copyWith(
            fontSize: 15.sp,
            fontWeight: FontWeight.w900,
          ),
        ),
        SizedBox(height: 12.h),
        for (final law in book.relatedLaws) ...[
          GestureDetector(
            onTap: () => _showLawBottomSheet(context, law),
            child: _buildContentCard(
              accentColor: CaseTimeMachineColors.accentGold,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          '${law.lawName} ${law.articleNumber}',
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w900,
                            color: CaseTimeMachineColors.accentGold,
                          ),
                        ),
                      ),
                      CtmSvgIcon(
                        CtmSvgIcons.chevronRight,
                        size: 16.sp,
                        color: CaseTimeMachineColors.accentGold,
                      ),
                    ],
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    law.plainSummary,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style:
                        LightTextStyles.body(context).copyWith(fontSize: 12.sp),
                  ),
                  if (law.relationToCase.isNotEmpty) ...[
                    SizedBox(height: 6.h),
                    Text(
                      '法規關聯：${law.relationToCase}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: LightTextStyles.bodySmall(context).copyWith(
                        fontSize: 11.sp,
                        color: CaseTimeMachineColors.textMuted,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
          SizedBox(height: 12.h),
        ],
      ],
    );
  }

  // 台灣繁體中文教學註解：
  // 點擊法條卡片時彈出的莫蘭迪米白 (Cream) 精緻底頁，顯示完整條文概要與該案之關聯。
  void _showLawBottomSheet(BuildContext context, RelatedLaw law) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          decoration: BoxDecoration(
            color: CaseTimeMachineColors.bgCream,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.15),
                blurRadius: 20,
                offset: const Offset(0, -5),
              ),
            ],
          ),
          padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 36.h),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40.w,
                  height: 4.h,
                  decoration: BoxDecoration(
                    color: CaseTimeMachineColors.borderLight,
                    borderRadius: BorderRadius.circular(2.r),
                  ),
                ),
              ),
              SizedBox(height: 20.h),
              Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Expanded(
                    child: Text(
                      '${law.lawName} ${law.articleNumber}',
                      style: TextStyle(
                        fontFamily: 'Songti TC',
                        fontFamilyFallback: const ['BiauKai', 'Songti SC', 'STSong'],
                        fontSize: 18.sp,
                        fontWeight: FontWeight.bold,
                        color: CaseTimeMachineColors.primaryGreen,
                      ),
                    ),
                  ),
                  SizedBox(width: 8.w),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
                    decoration: BoxDecoration(
                      color: CaseTimeMachineColors.accentGold.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(4.r),
                    ),
                    child: Text(
                      '關聯法條',
                      style: TextStyle(
                        fontSize: 10.sp,
                        fontWeight: FontWeight.bold,
                        color: CaseTimeMachineColors.accentGold,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16.h),
              const Divider(color: CaseTimeMachineColors.borderLight),
              SizedBox(height: 16.h),
              Text(
                '【條文概要與釋義】',
                style: TextStyle(
                  fontSize: 11.5.sp,
                  fontWeight: FontWeight.w900,
                  color: CaseTimeMachineColors.accentGold,
                ),
              ),
              SizedBox(height: 6.h),
              Text(
                law.plainSummary,
                style: TextStyle(
                  fontSize: 13.sp,
                  height: 1.6,
                  color: CaseTimeMachineColors.textPrimary,
                ),
              ),
              if (law.relationToCase.isNotEmpty) ...[
                SizedBox(height: 20.h),
                Text(
                  '【本案關聯與適用】',
                  style: TextStyle(
                    fontSize: 11.5.sp,
                    fontWeight: FontWeight.w900,
                    color: CaseTimeMachineColors.accentGold,
                  ),
                ),
                SizedBox(height: 6.h),
                Text(
                  law.relationToCase,
                  style: TextStyle(
                    fontSize: 12.5.sp,
                    height: 1.6,
                    color: CaseTimeMachineColors.textSecondary,
                  ),
                ),
              ],
              SizedBox(height: 28.h),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: CaseTimeMachineColors.primaryGreen,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: 12.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                    elevation: 0,
                  ),
                  child: const Text('我知道了', style: TextStyle(fontWeight: FontWeight.bold)),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // --- TAB 3: 延伸 ---
  Widget _buildExtensionsTab(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 延伸影音資訊
        if (book.mediaReferences.isNotEmpty) ...[
          Text(
            '延伸影音資訊',
            style: LightTextStyles.sectionTitle(context).copyWith(
              fontSize: 15.sp,
              fontWeight: FontWeight.w900,
            ),
          ),
          SizedBox(height: 8.h),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: book.mediaReferences.length,
            itemBuilder: (context, index) {
              final ref = book.mediaReferences[index];
              String iconSvg = CtmSvgIcons.link;
              Color iconColor = CaseTimeMachineColors.accentGold;

              switch (ref.mediaType) {
                case 'podcast':
                  iconSvg = CtmSvgIcons.podcast;
                  iconColor = const Color(0xFF8E24AA);
                  break;
                case 'youtube':
                  iconSvg = CtmSvgIcons.playCircle;
                  iconColor = const Color(0xFFD32F2F);
                  break;
                case 'news':
                  iconSvg = CtmSvgIcons.newspaper;
                  iconColor = const Color(0xFF1976D2);
                  break;
                case 'academic':
                  iconSvg = CtmSvgIcons.school;
                  iconColor = const Color(0xFF388E3C);
                  break;
              }

              return Container(
                margin: EdgeInsets.only(bottom: 10.h),
                decoration: BoxDecoration(
                  color: CaseTimeMachineColors.bgWhite,
                  borderRadius: BorderRadius.circular(10.r),
                  border: Border.all(color: CaseTimeMachineColors.borderLight),
                ),
                child: ListTile(
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 14.w, vertical: 4.h),
                  leading: CircleAvatar(
                    backgroundColor: iconColor.withValues(alpha: 0.1),
                    child: CtmSvgIcon(iconSvg, size: 20.sp, color: iconColor),
                  ),
                  title: Text(
                    ref.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 12.5.sp,
                      fontWeight: FontWeight.bold,
                      color: CaseTimeMachineColors.textPrimary,
                    ),
                  ),
                  subtitle: Padding(
                    padding: EdgeInsets.only(top: 4.h),
                    child: Row(
                      children: [
                        Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: 6.w, vertical: 2.h),
                          decoration: BoxDecoration(
                            color: CaseTimeMachineColors.bgCream,
                            borderRadius: BorderRadius.circular(4.r),
                          ),
                          child: Text(
                            ref.platform,
                            style: TextStyle(
                              fontSize: 9.sp,
                              fontWeight: FontWeight.bold,
                              color: CaseTimeMachineColors.textSecondary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  trailing: CtmSvgIcon(
                    CtmSvgIcons.externalLink,
                    size: 16.sp,
                    color: CaseTimeMachineColors.accentGold,
                  ),
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('前往媒體：${ref.title}')),
                    );
                  },
                ),
              );
            },
          ),
          SizedBox(height: 18.h),
        ],

        // 相關案件
        if (book.relatedCases.isNotEmpty) ...[
          Text(
            '相關案件推薦',
            style: LightTextStyles.sectionTitle(context).copyWith(
              fontSize: 15.sp,
              fontWeight: FontWeight.w900,
            ),
          ),
          SizedBox(height: 10.h),
          for (final rel in book.relatedCases) ...[
            GestureDetector(
              onTap: () => _openRelatedCase(context, rel.caseId),
              child: Container(
                margin: EdgeInsets.only(bottom: 8.h),
                padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
                decoration: BoxDecoration(
                  color: CaseTimeMachineColors.bgWhite,
                  borderRadius: BorderRadius.circular(10.r),
                  border: Border.all(color: CaseTimeMachineColors.borderLight),
                ),
                child: Row(
                  children: [
                    Text(
                      rel.yearLabel,
                      style: TextStyle(
                        fontSize: 11.5.sp,
                        fontWeight: FontWeight.w900,
                        color: CaseTimeMachineColors.accentGold,
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            rel.title,
                            style: TextStyle(
                              fontSize: 13.sp,
                              fontWeight: FontWeight.bold,
                              color: CaseTimeMachineColors.textPrimary,
                            ),
                          ),
                          if (rel.reason.isNotEmpty) ...[
                            SizedBox(height: 2.h),
                            Text(
                              rel.reason,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 10.sp,
                                color: CaseTimeMachineColors.textMuted,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    CtmSvgIcon(
                      CtmSvgIcons.chevronRight,
                      size: 12.sp,
                      color: CaseTimeMachineColors.primaryGreen
                          .withValues(alpha: 0.5),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],

        _buildLiteratureSection(context),

        // Sources section
        SizedBox(height: 20.h),
        Text(
          '資料來源與更新時間',
          style: LightTextStyles.sectionTitle(context).copyWith(
            fontSize: 15.sp,
            fontWeight: FontWeight.w900,
          ),
        ),
        SizedBox(height: 8.h),
        _buildContentCard(
          accentColor: CaseTimeMachineColors.textMuted,
          padding: EdgeInsets.all(14.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (final source in book.sources) ...[
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 4.h),
                  child: Row(
                    children: [
                      CtmSvgIcon(
                        CtmSvgIcons.link,
                        size: 16.sp,
                        color: CaseTimeMachineColors.accentGold,
                      ),
                      SizedBox(width: 8.w),
                      Expanded(
                        child: Text(
                          source.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 11.5.sp,
                            fontWeight: FontWeight.bold,
                            color: CaseTimeMachineColors.textPrimary,
                          ),
                        ),
                      ),
                      SizedBox(width: 8.w),
                      Text(
                        source.updatedAt,
                        style: LightTextStyles.caption(context)
                            .copyWith(fontSize: 10.sp),
                      ),
                    ],
                  ),
                ),
                const Divider(color: CaseTimeMachineColors.borderLight),
              ],
              SizedBox(height: 10.h),
              Text(
                '免責聲明：\n本卷宗內容均基於客觀司法裁判與官方公開資訊進行整理，旨在提供公正中立之歷史與法律學習參考，不構成任何正式法律意見。實際個案請諮詢專業律師。',
                style: LightTextStyles.caption(context)
                    .copyWith(height: 1.5, fontSize: 9.5.sp),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // --- Bottom Action Bar ---
  Widget _buildBottomActionBar() {
    return Container(
      // 台灣繁體中文教學註解：縮短底端 Bar 高度，將上下 padding 改小 (由原先 10h/24h 縮為 4h/8h)。
      padding: EdgeInsets.fromLTRB(16.w, 4.h, 16.w, 8.h),
      decoration: BoxDecoration(
        color: CaseTimeMachineColors.bgWhite,
        border: const Border(
          top: BorderSide(color: CaseTimeMachineColors.borderLight),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // 1. 問法助 button (使用專案內建小法助人頭像)
          // 台灣繁體中文教學註解：
          // 將 Material Icon 替換為專案內的頭像圖片 `law_assistant_home.png`，
          // 並使用 ClipOval 包裹使其圓形化，建立客製 AI 快捷鍵。
          _buildTextActionButton(
            iconWidget: ClipOval(
              child: Image.asset(
                'assets/images/assistant/law_assistant_home.png',
                width: 24.w,
                height: 24.w,
                fit: BoxFit.cover,
              ),
            ),
            label: '問法助',
            onTap: () {
              Navigator.of(context).push(
                CupertinoPageRoute<void>(
                  builder: (_) => LawAssistantSearchPage(
                    initialPrompt: '我想了解關於「${book.titleZh}」的法律爭點與實務見解。',
                  ),
                ),
              );
            },
          ),
          // 2. 筆記 button (自訂筆記本 SVG)
          // 台灣繁體中文教學註解：
          // 新增自訂 SVG 渲染的筆記按鈕，與右側的分享形成完美對稱排版。
          _buildTextActionButton(
            iconWidget: SvgPicture.string(
              _svgNotesIcon,
              width: 22.w,
              height: 22.w,
            ),
            label: '筆記',
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('已開啟案件學習筆記（本機模擬）')),
              );
            },
          ),
          // 3. 追蹤 Pill button (加號/打勾改用自訂 SVG)
          // 台灣繁體中文教學註解：
          // 追蹤按鈕內部的 Icon 全面換成 SvgPicture.string 渲染自訂向量圖案，禁用 Material Icons。
          GestureDetector(
            onTap: () {
              setState(() {
                _isFollowed = !_isFollowed;
              });
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(_isFollowed ? '已加入我的追蹤' : '已取消追蹤')),
              );
            },
            child: Container(
              // 台灣繁體中文教學註解：配合短 Bar 設計，將膠囊高度 padding 由 12h 調整為 8h。
              padding: EdgeInsets.symmetric(
                  horizontal: 24.w, vertical: 8.h), // 調整寬度以適配 5 按鈕佈局
              decoration: BoxDecoration(
                color: CaseTimeMachineColors.primaryGreen,
                borderRadius: BorderRadius.circular(20.r),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SvgPicture.string(
                    _isFollowed ? _svgCheckIcon : _svgAddIcon,
                    width: 14.sp,
                    height: 14.sp,
                  ),
                  SizedBox(width: 4.w),
                  Text(
                    _isFollowed ? '已追蹤' : '追蹤',
                    style: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
          // 4. 收藏 button (星星改用自訂 SVG)
          // 台灣繁體中文教學註解：
          // 收藏按鈕圖示使用 SvgPicture.string 動態載入實心與空心星星 SVG。
          _buildTextActionButton(
            iconWidget: SvgPicture.string(
              _isSaved ? _svgStarFilledIcon : _svgStarOutlineIcon,
              width: 22.w,
              height: 22.w,
            ),
            label: '收藏',
            onTap: () {
              setState(() {
                _isSaved = !_isSaved;
              });
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(_isSaved ? '已加入我的收藏' : '已取消收藏')),
              );
            },
          ),
          // 5. 分享 button (分享改用自訂 SVG)
          // 台灣繁體中文教學註解：
          // 新增自訂 SVG 渲染的分享按鈕，放置於最右側，與左側的「問法助」和「筆記」達到雙向對稱。
          _buildTextActionButton(
            iconWidget: SvgPicture.string(
              _svgShareIcon,
              width: 22.w,
              height: 22.w,
            ),
            label: '分享',
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('已複製分享連結（本機模擬）')),
              );
            },
          ),
        ],
      ),
    );
  }

  // --- Redesign Helpers & UI Builders ---
  List<_TrialStep> _getTrialSteps(String caseId) {
    if (caseId == '318') {
      return const [
        _TrialStep(
          stage: '第一審',
          courtName: '臺灣臺北地方法院',
          caseNumber: '104 年度矚訴字第 1 號刑事判決',
          outcome: '黃國昌等 22 人判決無罪',
          date: '2017/03/31',
          holdingDetail:
              '【判決主文與事實理由概要】\n被告黃國昌、林飛帆、陳為廷等被控煽惑他人犯罪、妨害公務、侮辱公署等罪嫌。\n\n【核心理由】\n法院認為，被告等抗議手段係針對立法院審查服貿協議之程序爭議進行表達，屬於憲法保障之言論自由與集會自由範圍。且立法院之程序瑕疵引發重大社會爭端，被告之抗爭行為符合「公民不服從」之構成要件，手段和平非暴力且具有公益目的，故宣告全體被告無罪。',
        ),
        _TrialStep(
          stage: '第二審',
          courtName: '臺灣高等法院',
          caseNumber: '106 年度矚上訴字第 2 號刑事判決',
          outcome: '檢察官上訴駁回，維持一審無罪判決',
          date: '2018/03/13',
          holdingDetail:
              '【判決主文與事實理由概要】\n檢察官針對一審判決無罪之被告提起上訴。\n\n【核心理由】\n高院審理後指出，一審判決認事用法並無違誤。憲法保障集會自由之核心價值在於保障人民向政府表達不同意見之管道。本案雖有佔領議場之形式違法，但其抗爭手段與民主防禦本質相符，且未造成不可回復之重大損害，檢察官上訴無理由，駁回上訴。',
        ),
        _TrialStep(
          stage: '第三審定讞',
          courtName: '最高法院',
          caseNumber: '107 年度台上字第 42 號刑事判決',
          outcome: '上訴駁回，全案無罪確定',
          date: '2018/03/22',
          holdingDetail:
              '【判決主文與事實理由概要】\n檢察官不服二審判決，向最高法院提起上訴。\n\n【核心理由】\n最高法院指出，刑事訴訟法關於上訴第三審有嚴格之法律限制。本案二審維持一審無罪判決，且檢察官上訴指摘事項並非違背法令之核心，不符合上訴第三審之法定要件，裁定駁回檢察官上訴，本案無罪判決定讞。',
        ),
      ];
    }

    // Fallbacks for other cases to ensure UI completeness
    return [
      _TrialStep(
        stage: '第一審',
        courtName: book.basicInfo.courtLevel.contains('/')
            ? book.basicInfo.courtLevel.split('/').last.trim()
            : book.basicInfo.courtLevel,
        caseNumber: '【模擬案號】${book.year} 年度矚訴字第 999 號',
        outcome: '裁判結果：${book.status}',
        date: book.basicInfo.updatedAt,
        holdingDetail:
            '【判決概要】\n本案為 ${book.category}，經第一審法院審判，考量相關法條事證與社會大眾爭點後做成決議。\n\n【核心判決意旨】\n詳細判決內容請參考司法院裁判書公開查詢系統。本系統已收錄該案件之核心法律關係與爭點。',
      ),
      if (book.status == '判決確定' || book.status == '已結案')
        _TrialStep(
          stage: '終審確定',
          courtName: book.basicInfo.courtLevel.contains('/')
              ? book.basicInfo.courtLevel.split('/').first.trim()
              : book.basicInfo.courtLevel,
          caseNumber: '【模擬案號】${book.year + 1} 年度台上字第 888 號',
          outcome: '上訴駁回，維持原判決確定',
          date: book.basicInfo.updatedAt,
          holdingDetail:
              '【終審裁判概要】\n本案上訴至終審法院，認原審判決認事用法尚無違誤，裁定駁回上訴或宣判確定。\n\n【判決效力】\n全案定讞，對當事人具有實質確定力。',
        ),
    ];
  }

  void _showHoldingBottomSheet(BuildContext context, _TrialStep step) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          decoration: BoxDecoration(
            color: CaseTimeMachineColors.bgCream,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
          ),
          padding: EdgeInsets.fromLTRB(20.w, 20.h, 20.w, 36.h),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40.w,
                  height: 4.h,
                  decoration: BoxDecoration(
                    color: CaseTimeMachineColors.borderLight,
                    borderRadius: BorderRadius.circular(2.r),
                  ),
                ),
              ),
              SizedBox(height: 20.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                    decoration: BoxDecoration(
                      color: CaseTimeMachineColors.accentGold
                          .withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(4.r),
                    ),
                    child: Text(
                      step.stage,
                      style: TextStyle(
                        fontSize: 11.sp,
                        fontWeight: FontWeight.bold,
                        color: CaseTimeMachineColors.accentGold,
                      ),
                    ),
                  ),
                  Text(
                    step.date,
                    style: TextStyle(
                      fontSize: 11.sp,
                      color: CaseTimeMachineColors.textMuted,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 12.h),
              Text(
                step.courtName,
                style: TextStyle(
                  fontFamily: 'Songti TC',
                  fontFamilyFallback: const ['BiauKai', 'Songti SC', 'STSong'],
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                  color: CaseTimeMachineColors.primaryGreen,
                ),
              ),
              SizedBox(height: 4.h),
              Text(
                step.caseNumber,
                style: TextStyle(
                  fontSize: 12.sp,
                  color: CaseTimeMachineColors.textSecondary,
                  fontWeight: FontWeight.w700,
                ),
              ),
              SizedBox(height: 16.h),
              const Divider(color: CaseTimeMachineColors.borderLight),
              SizedBox(height: 16.h),
              Text(
                '判決主文與核心理由',
                style: TextStyle(
                  fontSize: 13.5.sp,
                  fontWeight: FontWeight.w900,
                  color: CaseTimeMachineColors.primaryGreen,
                ),
              ),
              SizedBox(height: 10.h),
              Flexible(
                child: SingleChildScrollView(
                  child: Text(
                    step.holdingDetail,
                    style: TextStyle(
                      fontSize: 12.5.sp,
                      height: 1.6,
                      color: CaseTimeMachineColors.textPrimary,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 24.h),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: CaseTimeMachineColors.primaryGreen,
                        side: const BorderSide(
                            color: CaseTimeMachineColors.primaryGreen),
                        padding: EdgeInsets.symmetric(vertical: 12.h),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.r),
                        ),
                      ),
                      icon: CtmSvgIcon(
                        CtmSvgIcons.copy,
                        size: 16.sp,
                        color: CaseTimeMachineColors.primaryGreen,
                      ),
                      label: const Text('複製案號資訊',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      onPressed: () {
                        Navigator.of(context).pop();
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                              content: Text(
                                  '已複製：${step.courtName} ${step.caseNumber}')),
                        );
                      },
                    ),
                  ),
                  SizedBox(width: 10.w),
                  Expanded(
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: CaseTimeMachineColors.primaryGreen,
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(vertical: 12.h),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.r),
                        ),
                      ),
                      icon: CtmSvgIcon(
                        CtmSvgIcons.externalLink,
                        size: 16.sp,
                        color: Colors.white,
                      ),
                      label: const Text('官方裁判書連結',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      onPressed: () {
                        Navigator.of(context).pop();
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('正在開起司法行政機關裁判書系統...')),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildLitigationTimeline(BuildContext context) {
    final steps = _getTrialSteps(book.id);

    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: CaseTimeMachineColors.bgWhite,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: CaseTimeMachineColors.borderLight),
        boxShadow: [CaseTimeMachineShadows.softShadow],
      ),
      child: Column(
        children: List.generate(steps.length, (index) {
          final step = steps[index];
          final isLast = index == steps.length - 1;

          return IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  children: [
                    Container(
                      width: 14.w,
                      height: 14.w,
                      decoration: BoxDecoration(
                        color: isLast
                            ? CaseTimeMachineColors.accentGold
                            : CaseTimeMachineColors.primaryGreen
                                .withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isLast
                              ? CaseTimeMachineColors.bgWhite
                              : CaseTimeMachineColors.primaryGreen,
                          width: 3.w,
                        ),
                      ),
                    ),
                    if (!isLast)
                      Expanded(
                        child: Container(
                          width: 2.w,
                          color: CaseTimeMachineColors.primaryGreen
                              .withValues(alpha: 0.2),
                        ),
                      ),
                  ],
                ),
                SizedBox(width: 14.w),
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(bottom: isLast ? 0 : 20.h),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 8.w, vertical: 2.h),
                              decoration: BoxDecoration(
                                color: isLast
                                    ? CaseTimeMachineColors.accentGold
                                        .withValues(alpha: 0.15)
                                    : CaseTimeMachineColors.primaryGreen
                                        .withValues(alpha: 0.08),
                                borderRadius: BorderRadius.circular(4.r),
                              ),
                              child: Text(
                                step.stage,
                                style: TextStyle(
                                  fontSize: 9.sp,
                                  fontWeight: FontWeight.bold,
                                  color: isLast
                                      ? CaseTimeMachineColors.accentGold
                                      : CaseTimeMachineColors.primaryGreen,
                                ),
                              ),
                            ),
                            Text(
                              step.date,
                              style: TextStyle(
                                fontSize: 10.sp,
                                color: CaseTimeMachineColors.textMuted,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 6.h),
                        Text(
                          step.courtName,
                          style: TextStyle(
                            fontSize: 13.sp,
                            fontWeight: FontWeight.bold,
                            color: CaseTimeMachineColors.primaryGreen,
                          ),
                        ),
                        SizedBox(height: 2.h),
                        Text(
                          step.caseNumber,
                          style: TextStyle(
                            fontSize: 10.5.sp,
                            color: CaseTimeMachineColors.textSecondary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 6.h),
                        Text(
                          step.outcome,
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: isLast
                                ? const Color(0xFF2E7D32)
                                : CaseTimeMachineColors.textPrimary,
                            fontWeight:
                                isLast ? FontWeight.w800 : FontWeight.w500,
                          ),
                        ),
                        SizedBox(height: 8.h),
                        GestureDetector(
                          onTap: () => _showHoldingBottomSheet(context, step),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                '檢視裁判主文與核心理由',
                                style: TextStyle(
                                  fontSize: 11.sp,
                                  color: CaseTimeMachineColors.accentGold,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              SizedBox(width: 4.w),
                              CtmSvgIcon(
                                CtmSvgIcons.article,
                                size: 13.sp,
                                color: CaseTimeMachineColors.accentGold,
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
          );
        }),
      ),
    );
  }

  List<_GlossaryItem> _getGlossaries(String caseId) {
    if (caseId == '318') {
      return const [
        _GlossaryItem(
          term: '公民不服從',
          pinyin: 'Civil Disobedience',
          definition:
              '出於對於公共利益或維護憲法體制之公益動機，以公開、和平、非暴力且願意承擔法律後果之最後手段，刻意違反特定法律之抗議行為。',
          importance: '法院肯認「公民不服從」在符合特定構成要件時，可作為刑法超法規之阻卻違法事由。',
        ),
        _GlossaryItem(
          term: '阻卻違法事由',
          pinyin: 'Justification / Excuse',
          definition:
              '指行為形式上雖符合特定刑罰條文，但實質上不具社會侵害性，而具法律容許之正當理由（如正當防衛、緊急避難或超法規事由）而不予處罰。',
          importance: '本案抗爭之核心動機具有高度公益性，且為防禦民主之最後手段，因而判決無罪。',
        ),
        _GlossaryItem(
          term: '比例原則',
          pinyin: 'Principle of Proportionality',
          definition:
              '國家行使權利限制人民自由時，手段必須符合適當性（有助於目的達成）、必要性（最小侵害）、以及衡量性（手段所造成損害不可大於追求之公益）。',
          importance: '學運相關之驅離訴訟案中，常用以檢視執法機關施放警械或水砲之妥當性。',
        ),
      ];
    }
    return const [
      _GlossaryItem(
        term: '無罪推定原則',
        pinyin: 'Presumption of Innocence',
        definition: '未經審判證明有罪確定前，推定被告為無罪。犯罪事實應依證據認定之，無證據不得認定犯罪事實。',
        importance: '刑事司法制度最核心之人權保障準則，舉證責任落在檢察官身上。',
      ),
      _GlossaryItem(
        term: '比例原則',
        pinyin: 'Principle of Proportionality',
        definition: '國家行使權利限制人民權益時，必須注意手段與目的之衡平，具備適當、必要、最小侵害之特性。',
        importance: '我國司法違憲審查與裁判見解中最常引年的憲法核心防線。',
      ),
    ];
  }



  List<_LiteratureItem> _getLiteratures(String caseId) {
    if (caseId == '318') {
      return const [
        _LiteratureItem(
          title: '代議失靈與公民不服從之憲法防禦權爭議',
          author: '張文貞教授',
          journal: '《台灣法學雜誌》第 246 期 (2014)',
          sourceType: '學術期刊',
        ),
        _LiteratureItem(
          title: '集會自由之預防性限制與緊急即時強制：兼論釋字第 718 號之落實',
          author: '葉俊榮教授',
          journal: '《台大法學論叢》第 43 卷第 4 期 (2014)',
          sourceType: '學術期刊',
        ),
        _LiteratureItem(
          title: '街頭抗爭的法律邊界：從太陽花學運無罪判決看阻卻違法事由',
          author: '法白編輯部',
          journal: '《法律實務白話文評析專欄》 (2018)',
          sourceType: '實務評析',
        ),
      ];
    }
    return const [
      _LiteratureItem(
        title: '重大刑案中精神鑑定與量刑因子之實務審查標準',
        author: '法學研究中心',
        journal: '《司法官月刊》第 620 期',
        sourceType: '實務評析',
      ),
      _LiteratureItem(
        title: '比例原則在限制身體自由與刑後強制治療案件之適用界線',
        author: '憲法研究基金會',
        journal: '《憲政時代》第 46 卷',
        sourceType: '學術期刊',
      ),
    ];
  }

  Widget _buildLiteratureSection(BuildContext context) {
    final items = _getLiteratures(book.id);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 20.h),
        Text(
          '法學評析與學術文獻',
          style: LightTextStyles.sectionTitle(context).copyWith(
            fontSize: 15.sp,
            fontWeight: FontWeight.w900,
          ),
        ),
        SizedBox(height: 10.h),
        for (final item in items) ...[
          Container(
            margin: EdgeInsets.only(bottom: 8.h),
            padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
            decoration: BoxDecoration(
              color: CaseTimeMachineColors.bgWhite,
              borderRadius: BorderRadius.circular(10.r),
              border: Border.all(color: CaseTimeMachineColors.borderLight),
            ),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 4.h),
                  decoration: BoxDecoration(
                    color: item.sourceType == '學術期刊'
                        ? const Color(0xFFE8F5E9)
                        : const Color(0xFFE3F2FD),
                    borderRadius: BorderRadius.circular(4.r),
                  ),
                  child: Text(
                    item.sourceType,
                    style: TextStyle(
                      fontSize: 8.5.sp,
                      fontWeight: FontWeight.bold,
                      color: item.sourceType == '學術期刊'
                          ? const Color(0xFF2E7D32)
                          : const Color(0xFF1565C0),
                    ),
                  ),
                ),
                SizedBox(width: 10.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.title,
                        style: TextStyle(
                          fontSize: 12.5.sp,
                          fontWeight: FontWeight.bold,
                          color: CaseTimeMachineColors.textPrimary,
                        ),
                      ),
                      SizedBox(height: 2.h),
                      Text(
                        '${item.author} · ${item.journal}',
                        style: TextStyle(
                          fontSize: 9.5.sp,
                          color: CaseTimeMachineColors.textMuted,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  icon: CtmSvgIcon(
                    CtmSvgIcons.externalLink,
                    size: 16.sp,
                    color: CaseTimeMachineColors.accentGold,
                  ),
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('已複製文獻引用資訊：${item.title}')),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildRichTextWithGlossary(BuildContext context, String text, TextStyle baseStyle) {
    final glossaries = _getGlossaries(book.id);
    if (glossaries.isEmpty) {
      return Text(text, style: baseStyle);
    }

    final sortedGlossaries = List<_GlossaryItem>.from(glossaries)
      ..sort((a, b) => b.term.length.compareTo(a.term.length));

    final terms = sortedGlossaries.map((g) => RegExp.escape(g.term)).join('|');
    final regex = RegExp('($terms)');
    final matches = regex.allMatches(text);

    if (matches.isEmpty) {
      return Text(text, style: baseStyle);
    }

    final List<InlineSpan> spans = [];
    int lastMatchEnd = 0;

    for (final match in matches) {
      if (match.start > lastMatchEnd) {
        spans.add(TextSpan(
          text: text.substring(lastMatchEnd, match.start),
          style: baseStyle,
        ));
      }

      final matchedTerm = match.group(0)!;
      final glossaryItem = sortedGlossaries.firstWhere((g) => g.term == matchedTerm);

      spans.add(TextSpan(
        text: matchedTerm,
        style: baseStyle.copyWith(
          color: const Color(0xFF2E7D32),
          fontWeight: FontWeight.bold,
          decoration: TextDecoration.underline,
          decorationColor: const Color(0xFF2E7D32),
        ),
        recognizer: TapGestureRecognizer()
          ..onTap = () {
            _showGlossaryBottomSheet(context, glossaryItem);
          },
      ));

      lastMatchEnd = match.end;
    }

    if (lastMatchEnd < text.length) {
      spans.add(TextSpan(
        text: text.substring(lastMatchEnd),
        style: baseStyle,
      ));
    }

    return RichText(
      text: TextSpan(children: spans),
    );
  }

  void _showGlossaryBottomSheet(BuildContext context, _GlossaryItem item) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          decoration: BoxDecoration(
            color: CaseTimeMachineColors.bgCream,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
          ),
          padding: EdgeInsets.fromLTRB(20.w, 20.h, 20.w, 36.h),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40.w,
                  height: 4.h,
                  decoration: BoxDecoration(
                    color: CaseTimeMachineColors.borderLight,
                    borderRadius: BorderRadius.circular(2.r),
                  ),
                ),
              ),
              SizedBox(height: 20.h),
              Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text(
                    item.term,
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.bold,
                      color: CaseTimeMachineColors.primaryGreen,
                    ),
                  ),
                  SizedBox(width: 8.w),
                  Expanded(
                    child: Text(
                      '(${item.pinyin})',
                      style: TextStyle(
                        fontSize: 11.sp,
                        fontStyle: FontStyle.italic,
                        color: CaseTimeMachineColors.textMuted,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16.h),
              const Divider(color: CaseTimeMachineColors.borderLight),
              SizedBox(height: 16.h),
              Text(
                '【名詞釋義】',
                style: TextStyle(
                  fontSize: 11.5.sp,
                  fontWeight: FontWeight.w900,
                  color: CaseTimeMachineColors.accentGold,
                ),
              ),
              SizedBox(height: 4.h),
              Text(
                item.definition,
                style: TextStyle(
                  fontSize: 13.sp,
                  height: 1.5,
                  color: CaseTimeMachineColors.textPrimary,
                ),
              ),
              SizedBox(height: 16.h),
              Text(
                '【本案關聯】',
                style: TextStyle(
                  fontSize: 11.5.sp,
                  fontWeight: FontWeight.w900,
                  color: CaseTimeMachineColors.accentGold,
                ),
              ),
              SizedBox(height: 4.h),
              Text(
                item.importance,
                style: TextStyle(
                  fontSize: 12.5.sp,
                  height: 1.5,
                  color: CaseTimeMachineColors.textSecondary,
                ),
              ),
              SizedBox(height: 24.h),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: CaseTimeMachineColors.primaryGreen,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: 12.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                  ),
                  child: const Text('我知道了', style: TextStyle(fontWeight: FontWeight.bold)),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPeopleTab(BuildContext context) {
    final book = _detailedBook ?? widget.book;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '關係人與角色分工',
          style: LightTextStyles.sectionTitle(context).copyWith(
            fontSize: 15.sp,
            fontWeight: FontWeight.w900,
          ),
        ),
        SizedBox(height: 10.h),
        for (final person in book.people) ...[
          Container(
            margin: EdgeInsets.only(bottom: 12.h),
            decoration: BoxDecoration(
              color: CaseTimeMachineColors.bgWhite,
              borderRadius: BorderRadius.circular(10.r),
              border: Border.all(color: CaseTimeMachineColors.borderLight),
            ),
            child: Padding(
              padding: EdgeInsets.all(14.w),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    radius: 20.r,
                    backgroundColor: CaseTimeMachineColors.primaryGreen.withValues(alpha: 0.1),
                    child: Text(
                      person.role.isNotEmpty ? person.role.substring(0, 1) : '人',
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.bold,
                        color: CaseTimeMachineColors.primaryGreen,
                      ),
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          person.role,
                          style: TextStyle(
                            fontSize: 13.sp,
                            fontWeight: FontWeight.bold,
                            color: CaseTimeMachineColors.textPrimary,
                          ),
                        ),
                        SizedBox(height: 4.h),
                        Text(
                          person.description,
                          style: LightTextStyles.bodySmall(context).copyWith(
                            fontSize: 12.sp,
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildCourtReasoningTab(BuildContext context) {
    final book = _detailedBook ?? widget.book;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (book.investigationAndTrial.isNotEmpty) ...[
          Text(
            '審判程序簡述',
            style: LightTextStyles.sectionTitle(context).copyWith(
              fontSize: 15.sp,
              fontWeight: FontWeight.w900,
            ),
          ),
          SizedBox(height: 10.h),
          _buildRichTextWithGlossary(
            context,
            book.investigationAndTrial,
            LightTextStyles.body(context).copyWith(
              fontSize: 13.sp,
              height: 1.6,
            ),
          ),
          SizedBox(height: 20.h),
        ],
        if (book.courtReasoning.isNotEmpty) ...[
          Text(
            '法院心證與裁判理由',
            style: LightTextStyles.sectionTitle(context).copyWith(
              fontSize: 15.sp,
              fontWeight: FontWeight.w900,
            ),
          ),
          SizedBox(height: 10.h),
          _buildRichTextWithGlossary(
            context,
            book.courtReasoning,
            LightTextStyles.body(context).copyWith(
              fontSize: 13.sp,
              height: 1.6,
            ),
          ),
          SizedBox(height: 20.h),
        ],
        if (book.courtArguments.isNotEmpty) ...[
          Text(
            '兩造辯論與攻防重點',
            style: LightTextStyles.sectionTitle(context).copyWith(
              fontSize: 15.sp,
              fontWeight: FontWeight.w900,
            ),
          ),
          SizedBox(height: 10.h),
          for (final arg in book.courtArguments) ...[
            Container(
              margin: EdgeInsets.only(bottom: 12.h),
              decoration: BoxDecoration(
                color: CaseTimeMachineColors.bgWhite,
                borderRadius: BorderRadius.circular(10.r),
                border: Border.all(color: CaseTimeMachineColors.borderLight),
              ),
              child: Padding(
                padding: EdgeInsets.all(14.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
                          decoration: BoxDecoration(
                            color: (arg.partyName.contains('被告') || arg.partyName.contains('辯護'))
                                ? const Color(0xFFC62828).withValues(alpha: 0.1)
                                : CaseTimeMachineColors.primaryGreen.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(4.r),
                          ),
                          child: Text(
                            arg.partyName,
                            style: TextStyle(
                              fontSize: 10.5.sp,
                              fontWeight: FontWeight.bold,
                              color: (arg.partyName.contains('被告') || arg.partyName.contains('辯護'))
                                  ? const Color(0xFFC62828)
                                  : CaseTimeMachineColors.primaryGreen,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 8.h),
                    _buildRichTextWithGlossary(
                      context,
                      arg.mainPoint,
                      LightTextStyles.body(context).copyWith(
                        fontSize: 12.5.sp,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ],
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

    // Build the parts of the judgment
    final metadataText = '【裁判機關】${book.basicInfo.courtLevel}\n'
        '【裁判字號】中華民國 $minguoYearLabel 年度特字第 ${book.id} 號\n'
        '【裁判日期】$formattedDate\n'
        '【裁判案由】${book.category}（${book.titleZh}）';

    final mainVerdictText = book.judgmentResult.isNotEmpty ? book.judgmentResult : "上訴駁回。";

    final proceduralText = book.investigationAndTrial.isNotEmpty 
        ? book.investigationAndTrial 
        : '本案經檢察官提起公訴，歷經言詞辯論，本院依法審判之程序完備。';

    final reasoningText = book.courtReasoning.isNotEmpty 
        ? book.courtReasoning 
        : (book.fullStory.isNotEmpty ? book.fullStory : book.background);

    final List<String> lawLines = [];
    if (book.relatedLaws.isNotEmpty) {
      for (final law in book.relatedLaws) {
        lawLines.add('依${law.lawName}${law.articleNumber}（${law.plainSummary}）之規定，本案據此裁判。');
      }
    } else {
      lawLines.add('依相關法律之規定，本案據此裁判。');
    }

    final baseTextStyle = TextStyle(
      fontFamily: AppFonts.serifTW,
      fontFamilyFallback: AppFonts.serifFallbacks,
      fontSize: 12.5.sp,
      height: 1.8,
      letterSpacing: 1.1,
      color: const Color(0xFF2B2B2B), // Traditional charcoal black
    );

    final sectionTitleStyle = TextStyle(
      fontFamily: AppFonts.serifTW,
      fontFamilyFallback: AppFonts.serifFallbacks,
      fontSize: 14.sp,
      fontWeight: FontWeight.bold,
      color: CaseTimeMachineColors.primaryGreen,
      height: 2.0,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '判決書全文（模擬書卷）',
              style: LightTextStyles.sectionTitle(context).copyWith(
                fontSize: 15.sp,
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
                fullTextBuffer.writeln('\n\n中華民國法院刑事/民事法庭\n'
                    '審判長法官  黃國法\n'
                    '      法官  林憲法\n'
                    '      法官  陳民法\n'
                    '\n以上正本證明與原本無異。');

                Clipboard.setData(ClipboardData(text: fullTextBuffer.toString()));
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('已複製判決書全文至剪貼簿')),
                );
              },
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
                decoration: BoxDecoration(
                  color: CaseTimeMachineColors.primaryGreen.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(6.r),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CtmSvgIcon(
                      CtmSvgIcons.copy,
                      size: 13.sp,
                      color: CaseTimeMachineColors.primaryGreen,
                    ),
                    SizedBox(width: 4.w),
                    Text(
                      '複製全文',
                      style: TextStyle(
                        fontSize: 10.5.sp,
                        fontWeight: FontWeight.bold,
                        color: CaseTimeMachineColors.primaryGreen,
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
                      fontSize: 11.5.sp,
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
                    '中華民國法院刑事/民事法庭\n'
                    '審判長法官  黃國法\n'
                    '      法官  林憲法\n'
                    '      法官  陳民法\n\n'
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
            color: CaseTimeMachineColors.primaryGreen.withValues(alpha: 0.2),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            CtmSvgIcon(
              CtmSvgIcons.article,
              size: 12.sp,
              color: CaseTimeMachineColors.primaryGreen,
            ),
            SizedBox(width: 4.w),
            Text(
              label,
              style: TextStyle(
                fontSize: 11.5.sp,
                fontWeight: FontWeight.bold,
                color: CaseTimeMachineColors.primaryGreen,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextActionButton({
    required Widget iconWidget,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        // 台灣繁體中文教學註解：將內部垂直 padding 由 8h 調整為 4h，使底部 Bar 整體高度更精簡美觀。
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            iconWidget,
            SizedBox(height: 2.h),
            Text(
              label,
              style: TextStyle(
                fontSize: 10.sp,
                fontWeight: FontWeight.bold,
                color: CaseTimeMachineColors.primaryGreen,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// 台灣繁體中文教學註解：
// 「思辨與探索」區塊的個別快捷方格 Tile。
// 複用 CaseLibraryInteractiveGrid 的莫蘭迪色設計，直接依此案件開啟對應分析頁面。
class _ExploreShortcutTile extends StatelessWidget {
  const _ExploreShortcutTile({
    required this.iconSvg,
    required this.title,
    required this.subtitle,
    required this.backgroundColor,
    required this.foregroundColor,
    required this.onTap,
  });

  final String iconSvg;
  final String title;
  final String subtitle;
  final Color backgroundColor;
  final Color foregroundColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 88.h,
        padding: EdgeInsets.fromLTRB(11.w, 10.h, 11.w, 9.h),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
            color: foregroundColor.withValues(alpha: 0.12),
            width: 1.2,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              padding: EdgeInsets.all(4.w),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.65),
                shape: BoxShape.circle,
              ),
              child: CtmSvgIcon(
                iconSvg,
                size: 16.sp,
                color: foregroundColor,
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 10.5.sp,
                    fontWeight: FontWeight.w900,
                    color: foregroundColor,
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 8.5.sp,
                    fontWeight: FontWeight.w700,
                    color: foregroundColor.withValues(alpha: 0.72),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _TrialStep {
  const _TrialStep({
    required this.stage,
    required this.courtName,
    required this.caseNumber,
    required this.outcome,
    required this.date,
    required this.holdingDetail,
  });

  final String stage;
  final String courtName;
  final String caseNumber;
  final String outcome;
  final String date;
  final String holdingDetail;
}

class _CombinedTimelineNode {
  final String date;
  final String title;
  final String description;
  final String type; // 'event' or 'trial'
  final _TrialStep? trialStep;

  const _CombinedTimelineNode({
    required this.date,
    required this.title,
    required this.description,
    required this.type,
    this.trialStep,
  });
}

class _GlossaryItem {
  const _GlossaryItem({
    required this.term,
    required this.pinyin,
    required this.definition,
    required this.importance,
  });
  final String term;
  final String pinyin;
  final String definition;
  final String importance;
}

class _LiteratureItem {
  const _LiteratureItem({
    required this.title,
    required this.author,
    required this.journal,
    required this.sourceType,
  });
  final String title;
  final String author;
  final String journal;
  final String sourceType;
}

class _SliverTabBarDelegate extends SliverPersistentHeaderDelegate {
  _SliverTabBarDelegate({required this.child});

  final Widget child;

  @override
  double get minExtent => 54.h;

  @override
  double get maxExtent => 54.h;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return SizedBox.expand(child: child);
  }

  @override
  bool shouldRebuild(covariant _SliverTabBarDelegate oldDelegate) {
    return oldDelegate.child != child;
  }
}
