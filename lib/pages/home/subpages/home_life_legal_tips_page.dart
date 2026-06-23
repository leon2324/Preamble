import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lawapp/components/home/home_content.dart';
import 'package:lawapp/components/shared/custom_toast.dart';
import 'package:lawapp/components/shared/share_sheet.dart';
import 'package:lawapp/data/mock_data/home/home_mock_data.dart';
import 'package:lawapp/pages/learning/know_law_page.dart';

// 台灣繁體中文教學註解：
// 生活避坑筆記這一組頁面以「首頁入口截圖」為設計母版：
// 奶油底大圓角卡、法學藍標題、灰色摘要、綠色小提醒、右側小插圖區與底部互動數據列。
// 後續若要微調整體風格，優先從這組色票與共用小元件改，避免列表頁與詳情頁各自長出不同設計語言。
class LifeTrapColors {
  const LifeTrapColors._();

  static const background = Color(0xFFFFFCF7);
  static const card = Color(0xFFFFF5E9);
  static const cardAlt = Color(0xFFFFFAF3);
  static const cobalt = Color(0xFF284AA5);
  static const forest = Color(0xFF17442F);
  static const reminder = Color(0xFF168019);
  static const body = Color(0xFF838383);
  static const ink = Color(0xFF24352E);
  static const border = Color(0xFFEDE4D8);
  static const panelGray = Color(0xFFC8C5C3);
  static const mutedGreen = Color(0xFFE7EFE7);
  static const mutedBlue = Color(0xFFEAF0F7);
  static const mutedRose = Color(0xFFF3E7E3);
  static const heart = Color(0xFFE60000);
  static const share = Color(0xFF8A7400);
  static const comment = Color(0xFF006B35);
  static const download = Color(0xFF008A8A);
}

class CategoryAesthetics {
  const CategoryAesthetics({
    required this.label,
    required this.primary,
    required this.tint,
    required this.icon,
  });

  final String label;
  final Color primary;
  final Color tint;
  final IconData icon;
}

class _CategoryFilter {
  const _CategoryFilter(this.label, this.value);

  final String label;
  final String? value;
}

CategoryAesthetics aestheticsForCategory(String category) {
  if (category.contains('狗') || category.contains('寵物')) {
    return const CategoryAesthetics(
      label: '養狗',
      primary: LifeTrapColors.forest,
      tint: LifeTrapColors.mutedGreen,
      icon: Icons.pets_rounded,
    );
  }
  if (category.contains('租')) {
    return const CategoryAesthetics(
      label: '租屋',
      primary: Color(0xFF9B6154),
      tint: LifeTrapColors.mutedRose,
      icon: Icons.home_work_outlined,
    );
  }
  if (category.contains('拍照') || category.contains('隱私')) {
    return const CategoryAesthetics(
      label: '隱私',
      primary: Color(0xFF58708A),
      tint: LifeTrapColors.mutedBlue,
      icon: Icons.photo_camera_outlined,
    );
  }
  if (category.contains('網購')) {
    return const CategoryAesthetics(
      label: '網購',
      primary: Color(0xFF8A5E4E),
      tint: Color(0xFFF2E9DE),
      icon: Icons.shopping_bag_outlined,
    );
  }
  if (category.contains('交通')) {
    return const CategoryAesthetics(
      label: '交通',
      primary: Color(0xFF4D7572),
      tint: Color(0xFFE6F0EF),
      icon: Icons.directions_car_outlined,
    );
  }
  return const CategoryAesthetics(
    label: '生活',
    primary: LifeTrapColors.forest,
    tint: LifeTrapColors.mutedGreen,
    icon: Icons.lightbulb_outline_rounded,
  );
}

/// 生活避坑筆記列表頁
class LifeLegalTipsPage extends StatefulWidget {
  const LifeLegalTipsPage({super.key});

  @override
  State<LifeLegalTipsPage> createState() => _LifeLegalTipsPageState();
}

class _LifeLegalTipsPageState extends State<LifeLegalTipsPage> {
  static const _filters = <_CategoryFilter>[
    _CategoryFilter('全部', null),
    _CategoryFilter('養狗', '養狗'),
    _CategoryFilter('租屋', '租屋'),
    _CategoryFilter('網購', '網購'),
    _CategoryFilter('交通', '交通'),
    _CategoryFilter('隱私', '拍照隱私'),
  ];

  late final PageController _featuredController;
  late final TextEditingController _searchController;
  Timer? _featuredTimer;
  var _selectedFilter = _filters.first;
  var _featuredIndex = 0;
  var _query = '';
  double _pageOffset = 0.0;

  @override
  void initState() {
    super.initState();
    _featuredController = PageController(viewportFraction: 0.93);
    _searchController = TextEditingController();

    _featuredController.addListener(() {
      if (!_featuredController.hasClients) return;
      setState(() {
        _pageOffset = _featuredController.page ?? _featuredIndex.toDouble();
      });
    });

    _searchController.addListener(() {
      setState(() => _query = _searchController.text.trim());
    });

    _featuredTimer = Timer.periodic(const Duration(seconds: 5), (__) {
      if (!_featuredController.hasClients) return;
      final next = (_featuredIndex + 1) % 5;
      _featuredController.animateToPage(
        next,
        duration: const Duration(milliseconds: 520),
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
    final featuredItems = homeNewsletterItems.take(5).toList(growable: false);
    final filteredItems = homeNewsletterItems.where((item) {
      final matchesCategory = _selectedFilter.value == null ||
          item.category == _selectedFilter.value ||
          (_selectedFilter.value == '拍照隱私' && item.category.contains('隱私'));
      final matchesQuery = _query.isEmpty ||
          item.title.contains(_query) ||
          item.summary.contains(_query) ||
          item.tip.contains(_query) ||
          item.category.contains(_query);
      return matchesCategory && matchesQuery;
    }).toList(growable: false);

    return Scaffold(
      backgroundColor: LifeTrapColors.background,
      body: Stack(
        children: [
          ListView(
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            physics: const BouncingScrollPhysics(),
            padding: EdgeInsets.fromLTRB(18.w, topPadding + 118.h, 18.w, 36.h),
            children: [
              _LifeTipCategoryRail(
                filters: _filters,
                selectedFilter: _selectedFilter,
                onSelected: (filter) {
                  HapticFeedback.selectionClick();
                  setState(() => _selectedFilter = filter);
                },
              ),
              SizedBox(height: 18.h),
              _SectionTitle(title: '今日焦點', count: featuredItems.length),
              SizedBox(height: 10.h),
              SizedBox(
                height: 260.h,
                child: PageView.builder(
                  controller: _featuredController,
                  physics: const BouncingScrollPhysics(),
                  itemCount: featuredItems.length,
                  onPageChanged: (index) => setState(() {
                    _featuredIndex = index;
                    _pageOffset = index.toDouble();
                  }),
                  itemBuilder: (context, index) {
                    final item = featuredItems[index];
                    return Padding(
                      padding: EdgeInsets.only(
                        left: index == 0 ? 0 : 6.w,
                        right: index == featuredItems.length - 1 ? 0 : 6.w,
                      ),
                      child: _LifeTipFeaturedCard(
                        item: item,
                        onTap: () => _openTip(context, item),
                      ),
                    );
                  },
                ),
              ),
              SizedBox(height: 12.h),
              _LifeTipPageDots(
                count: featuredItems.length,
                pageOffset: _pageOffset,
              ),
              SizedBox(height: 24.h),
              _SectionTitle(
                title: '最近筆記',
                count: filteredItems.length,
              ),
              SizedBox(height: 10.h),
              if (filteredItems.isEmpty)
                const _LifeTipStatusCard(
                  message: '目前沒有符合條件的避坑筆記，換個關鍵字試試看。',
                )
              else
                ...filteredItems.take(18).map(
                      (item) => Padding(
                        padding: EdgeInsets.only(bottom: 12.h),
                        child: _LifeTipListCard(
                          item: item,
                          onTap: () => _openTip(context, item),
                        ),
                      ),
                    ),
              SizedBox(height: 8.h),
              const _LifeTipStatusCard(
                message: '生活避坑筆記僅提供一般法律常識與風險預防參考，非正式律師意見。若遇具體糾紛，請尋求專業法律服務。',
              ),
            ],
          ),
          _LifeTrapTopFrostMask(topPadding: topPadding),
          Positioned(
            top: topPadding + 8.h,
            left: 14.w,
            right: 14.w,
            child: Column(
              children: [
                _LifeTipListTopBar(
                  onBack: () => Navigator.of(context).pop(),
                  onFilter: () => CustomToast.show(
                    context,
                    '分類篩選已在下方',
                    icon: Icons.tune_rounded,
                  ),
                ),
                SizedBox(height: 10.h),
                _LifeTrapSearchBar(controller: _searchController),
              ],
            ),
          ),
        ],
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
  var _readingProgress = 0.0;
  var _isFollowed = false;
  var _isSaved = false;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController()..addListener(_onScroll);
    _steps = _buildActionSteps(widget.item);
    _stepsChecked = List.generate(_steps.length, (_) => false);
  }

  @override
  void dispose() {
    _scrollController
      ..removeListener(_onScroll)
      ..dispose();
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
    final bottomPadding = MediaQuery.paddingOf(context).bottom;
    final aes = aestheticsForCategory(widget.item.category);
    final completed = _stepsChecked.where((value) => value).length;

    return Scaffold(
      backgroundColor: LifeTrapColors.background,
      body: Stack(
        children: [
          ListView(
            controller: _scrollController,
            physics: const BouncingScrollPhysics(),
            padding: EdgeInsets.fromLTRB(
              18.w,
              topPadding + 78.h,
              18.w,
              bottomPadding + 118.h,
            ),
            children: [
              _DetailHeader(item: widget.item, aesthetics: aes),
              SizedBox(height: 16.h),
              _DetailPanel(
                title: '踩坑情境',
                icon: Icons.warning_amber_rounded,
                accentColor: const Color(0xFFB45D55),
                child: Text(
                  _scenarioForTip(widget.item),
                  style: _detailBodyStyle(),
                ),
              ),
              SizedBox(height: 14.h),
              _DetailPanel(
                title: '你要注意',
                icon: Icons.fact_check_outlined,
                accentColor: aes.primary,
                child: Column(
                  children: _warningBullets(widget.item)
                      .map(
                        (text) => _DetailBullet(
                          text: text,
                          color: aes.primary,
                        ),
                      )
                      .toList(),
                ),
              ),
              SizedBox(height: 14.h),
              _DetailPanel(
                title: '避坑做法',
                subtitle: '$completed / ${_steps.length} 已完成',
                icon: Icons.playlist_add_check_rounded,
                accentColor: LifeTrapColors.reminder,
                child: Column(
                  children: List.generate(_steps.length, (index) {
                    final checked = _stepsChecked[index];
                    return _ChecklistRow(
                      index: index,
                      text: _steps[index],
                      checked: checked,
                      onTap: () {
                        HapticFeedback.lightImpact();
                        setState(() => _stepsChecked[index] = !checked);
                      },
                    );
                  }),
                ),
              ),
              SizedBox(height: 14.h),
              _DetailPanel(
                title: '相關法規',
                icon: Icons.gavel_rounded,
                accentColor: LifeTrapColors.cobalt,
                child: Text(
                  _lawReferenceForTip(widget.item),
                  style: _detailBodyStyle(),
                ),
              ),
            ],
          ),
          _LifeTipDetailAppBar(
            topPadding: topPadding,
            readingProgress: _readingProgress,
            onBack: () => Navigator.of(context).pop(),
            onDiscussion: () => CustomToast.show(
              context,
              '討論室開發中',
              icon: Icons.graphic_eq_rounded,
            ),
          ),
          _LifeTipBottomNavBar(
            bottomPadding: bottomPadding,
            isFollowed: _isFollowed,
            isSaved: _isSaved,
            onAskAssistant: _openAssistant,
            onNote: () => CustomToast.show(
              context,
              '已開啟筆記入口',
              icon: Icons.description_outlined,
            ),
            onFollow: () {
              HapticFeedback.mediumImpact();
              setState(() => _isFollowed = !_isFollowed);
            },
            onSave: () {
              HapticFeedback.lightImpact();
              setState(() => _isSaved = !_isSaved);
              CustomToast.show(
                context,
                _isSaved ? '已加入收藏' : '已取消收藏',
                icon: _isSaved ? Icons.star_rounded : Icons.star_border_rounded,
              );
            },
            onShare: () => ShareSheet.show(context, title: widget.item.title),
          ),
        ],
      ),
    );
  }

  void _openAssistant() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (__) => LawAssistantChatPage(
          initialPrompt: '我想了解「${widget.item.title}」這個生活法律問題，可以怎麼處理？',
        ),
      ),
    );
  }

  static TextStyle _detailBodyStyle() {
    return TextStyle(
      color: LifeTrapColors.body,
      fontSize: 13.2.sp,
      height: 1.58,
      fontWeight: FontWeight.w700,
    );
  }

  static List<String> _buildActionSteps(HomeNewsletterItem item) {
    if (item.title.contains('狗')) {
      return const [
        '先確認傷勢並協助就醫，保留診斷證明與醫療收據。',
        '拍下現場、牽繩狀態與周邊監視器位置，保存原始紀錄。',
        '和解內容要白紙黑字，賠償項目與付款日期都要寫清楚。',
      ];
    }
    if (item.title.contains('自拍') || item.title.contains('拍照')) {
      return const [
        '上傳照片前檢查背景是否有清楚可辨識的路人或車牌。',
        '商業使用、醜化言論或特寫他人時，先取得當事人同意。',
        '若收到下架或侵權通知，先保留溝通紀錄再調整公開範圍。',
      ];
    }
    if (item.title.contains('車禍')) {
      return const [
        '先報警、拍照、交換資料，不急著承認全部責任。',
        '保留行車紀錄器、現場照片與初判表，避免只靠口頭說法。',
        '和解前確認醫療費、修車費與後續復健費是否都列入。',
      ];
    }
    return const [
      '翻出契約，確認提前終止、違約金與修繕責任條款。',
      '點交退租前拍照或錄影，保存房屋現況與交屋紀錄。',
      '若房東扣押金，請對方提出明細、估價單或修繕收據。',
    ];
  }

  static String _scenarioForTip(HomeNewsletterItem item) {
    if (item.title.contains('狗')) {
      return '散步時狗突然咬傷路人，飼主通常需要說明自己已盡管理注意義務，例如牽繩、避開危險情境與即時協助就醫。';
    }
    if (item.title.contains('自拍') || item.title.contains('拍照')) {
      return '在公共場所拍照很常見，但若照片主體其實是清楚可辨識的路人，公開或營利使用時就可能產生肖像權與隱私爭議。';
    }
    if (item.title.contains('車禍')) {
      return '車禍現場可以先關心傷勢，但不要急著簽下不清楚的和解書，也不要只用口頭承諾處理後續賠償。';
    }
    return '退租時房東以清潔費、油漆費或修繕費扣押金，但未提出明細或證據，是租屋糾紛裡最常見的踩坑情境。';
  }

  static List<String> _warningBullets(HomeNewsletterItem item) {
    if (item.title.contains('狗')) {
      return const [
        '醫療費、精神損害與財物損失都可能被請求。',
        '是否繫牽繩、是否盡管理義務，會影響責任判斷。',
        '即使想和解，也要把賠償範圍與付款方式寫清楚。',
      ];
    }
    if (item.title.contains('自拍') || item.title.contains('拍照')) {
      return const [
        '公共場所可以拍攝，不代表可以任意特寫或醜化他人。',
        '商業用途、廣告露出或自媒體業配風險更高。',
        '模糊處理、裁切或取得授權，是最基本的自保方式。',
      ];
    }
    if (item.title.contains('車禍')) {
      return const [
        '道歉不必然等於承認全責，但簽文件前要看清楚。',
        '肇責仍以現場證據、初判表與鑑定結果為主要依據。',
        '調解時要把賠償項目逐項列明，避免後續再吵一次。',
      ];
    }
    return const [
      '押金扣款須有契約、損害事實或合理費用依據。',
      '正常使用造成的自然耗損，通常不應全部轉嫁給房客。',
      '點交紀錄、照片、對話紀錄與收據，是談判時的關鍵。',
    ];
  }

  static String _lawReferenceForTip(HomeNewsletterItem item) {
    if (item.title.contains('狗')) {
      return '可先查《民法》第 190 條、第 195 條與動物保護相關規範，確認飼主責任與損害賠償範圍。';
    }
    if (item.title.contains('自拍') || item.title.contains('拍照')) {
      return '可查詢肖像權、隱私權、個人資料保護法與民法侵權行為規定，判斷照片公開使用的風險。';
    }
    if (item.title.contains('車禍')) {
      return '可查道路交通事故處理辦法、民法侵權行為與損害賠償規定，先把肇責與損害項目分開看。';
    }
    return '可查住宅租賃定型化契約應記載及不得記載事項、租賃專法與民法租賃規定。';
  }
}

class _LifeTipListTopBar extends StatelessWidget {
  const _LifeTipListTopBar({
    required this.onBack,
    required this.onFilter,
  });

  final VoidCallback onBack;
  final VoidCallback onFilter;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 44.h,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: _CircleIconButton(
              icon: Icons.chevron_left_rounded,
              semanticLabel: '返回',
              onTap: onBack,
            ),
          ),
          Text(
            '生活避坑筆記',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: LifeTrapColors.ink,
              fontSize: 18.sp,
              fontWeight: FontWeight.w900,
              letterSpacing: 0,
            ),
          ),
          Align(
            alignment: Alignment.centerRight,
            child: _CircleIconButton(
              icon: Icons.tune_rounded,
              semanticLabel: '分類篩選',
              onTap: onFilter,
            ),
          ),
        ],
      ),
    );
  }
}

class _LifeTipDetailAppBar extends StatelessWidget {
  const _LifeTipDetailAppBar({
    required this.topPadding,
    required this.readingProgress,
    required this.onBack,
    required this.onDiscussion,
  });

  final double topPadding;
  final double readingProgress;
  final VoidCallback onBack;
  final VoidCallback onDiscussion;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: Container(
        height: topPadding + 58.h,
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(
            bottom: BorderSide(color: LifeTrapColors.border, width: 0.8),
          ),
        ),
        child: Column(
          children: [
            SizedBox(height: topPadding),
            SizedBox(
              height: 56.h,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: SizedBox(
                      width: 76.w,
                      child: IconButton(
                        tooltip: '返回',
                        onPressed: onBack,
                        icon: Icon(
                          Icons.chevron_left_rounded,
                          color: LifeTrapColors.forest,
                          size: 32.sp,
                        ),
                      ),
                    ),
                  ),
                  Text(
                    '避坑指引',
                    style: TextStyle(
                      color: LifeTrapColors.ink,
                      fontSize: 18.sp,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0,
                    ),
                  ),
                  Align(
                    alignment: Alignment.centerRight,
                    child: SizedBox(
                      width: 76.w,
                      child: IconButton(
                        tooltip: '討論室',
                        onPressed: onDiscussion,
                        icon: Icon(
                          Icons.graphic_eq_rounded,
                          color: LifeTrapColors.forest,
                          size: 28.sp,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Align(
              alignment: Alignment.centerLeft,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 120),
                height: 2.h,
                width: MediaQuery.sizeOf(context).width * readingProgress,
                color: LifeTrapColors.reminder,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LifeTipBottomNavBar extends StatelessWidget {
  const _LifeTipBottomNavBar({
    required this.bottomPadding,
    required this.isFollowed,
    required this.isSaved,
    required this.onAskAssistant,
    required this.onNote,
    required this.onFollow,
    required this.onSave,
    required this.onShare,
  });

  final double bottomPadding;
  final bool isFollowed;
  final bool isSaved;
  final VoidCallback onAskAssistant;
  final VoidCallback onNote;
  final VoidCallback onFollow;
  final VoidCallback onSave;
  final VoidCallback onShare;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: 0,
      right: 0,
      bottom: 0,
      child: Container(
        height: bottomPadding + 86.h,
        padding: EdgeInsets.fromLTRB(18.w, 8.h, 18.w, bottomPadding + 8.h),
        decoration: const BoxDecoration(
          color: Colors.white,
          border:
              Border(top: BorderSide(color: LifeTrapColors.border, width: 0.8)),
        ),
        child: Row(
          children: [
            Expanded(
              child: _BottomNavItem(
                label: '問法助',
                icon: Icons.psychology_alt_rounded,
                useAvatar: true,
                onTap: onAskAssistant,
              ),
            ),
            Expanded(
              child: _BottomNavItem(
                label: '筆記',
                icon: Icons.description_outlined,
                onTap: onNote,
              ),
            ),
            SizedBox(width: 8.w),
            _FollowPill(
              isFollowed: isFollowed,
              onTap: onFollow,
            ),
            SizedBox(width: 8.w),
            Expanded(
              child: _BottomNavItem(
                label: '收藏',
                icon: isSaved ? Icons.star_rounded : Icons.star_border_rounded,
                onTap: onSave,
              ),
            ),
            Expanded(
              child: _BottomNavItem(
                label: '分享',
                icon: Icons.ios_share_rounded,
                onTap: onShare,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BottomNavItem extends StatelessWidget {
  const _BottomNavItem({
    required this.label,
    required this.icon,
    required this.onTap,
    this.useAvatar = false,
  });

  final String label;
  final IconData icon;
  final VoidCallback onTap;
  final bool useAvatar;

  @override
  Widget build(BuildContext context) {
    final iconWidget = useAvatar
        ? Container(
            width: 28.w,
            height: 28.w,
            decoration: const BoxDecoration(
              color: LifeTrapColors.mutedGreen,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: LifeTrapColors.forest, size: 16.sp),
          )
        : Icon(icon, color: LifeTrapColors.forest, size: 29.sp);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12.r),
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 4.h),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              iconWidget,
              SizedBox(height: 3.h),
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: LifeTrapColors.forest,
                  fontSize: 11.5.sp,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FollowPill extends StatelessWidget {
  const _FollowPill({
    required this.isFollowed,
    required this.onTap,
  });

  final bool isFollowed;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 118.w,
      height: 48.h,
      child: FilledButton.icon(
        onPressed: onTap,
        style: FilledButton.styleFrom(
          backgroundColor: LifeTrapColors.forest,
          foregroundColor: Colors.white,
          padding: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(999.r),
          ),
        ),
        icon: Icon(
          isFollowed ? Icons.check_rounded : Icons.add_rounded,
          size: 20.sp,
        ),
        label: Text(
          isFollowed ? '已追蹤' : '追蹤',
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w900,
            letterSpacing: 0,
          ),
        ),
      ),
    );
  }
}

class _CircleIconButton extends StatelessWidget {
  const _CircleIconButton({
    required this.icon,
    required this.semanticLabel,
    required this.onTap,
  });

  final IconData icon;
  final String semanticLabel;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: semanticLabel,
      button: true,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999.r),
        child: SizedBox(
          width: 42.w,
          height: 42.w,
          child: Icon(icon, color: LifeTrapColors.forest, size: 26.sp),
        ),
      ),
    );
  }
}

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
        child: ClipRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
            child: Container(
              height: topPadding + 118.h,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    LifeTrapColors.background.withValues(alpha: 0.98),
                    LifeTrapColors.background.withValues(alpha: 0.9),
                    LifeTrapColors.background.withValues(alpha: 0),
                  ],
                  stops: const [0, 0.76, 1],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

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
    _focusNode = FocusNode()
      ..addListener(() {
        setState(() => _isFocused = _focusNode.hasFocus);
      });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16.r),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          height: 46.h,
          padding: EdgeInsets.symmetric(horizontal: 14.w),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: _isFocused ? 0.98 : 0.78),
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(
              color: _isFocused ? LifeTrapColors.forest : LifeTrapColors.border,
              width: 1.w,
            ),
          ),
          child: TextField(
            controller: widget.controller,
            focusNode: _focusNode,
            onTapOutside: (_) => _focusNode.unfocus(),
            textInputAction: TextInputAction.search,
            decoration: InputDecoration(
              border: InputBorder.none,
              icon: Icon(
                Icons.search_rounded,
                color: _isFocused ? LifeTrapColors.forest : LifeTrapColors.body,
                size: 20.sp,
              ),
              hintText: '搜尋生活情境或關鍵字',
              hintStyle: TextStyle(
                color: LifeTrapColors.body,
                fontSize: 12.5.sp,
                fontWeight: FontWeight.w700,
              ),
              suffixIcon: widget.controller.text.isEmpty
                  ? null
                  : IconButton(
                      onPressed: widget.controller.clear,
                      icon: Icon(
                        Icons.close_rounded,
                        color: LifeTrapColors.body,
                        size: 18.sp,
                      ),
                    ),
            ),
            style: TextStyle(
              color: LifeTrapColors.ink,
              fontSize: 13.sp,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ),
    );
  }
}

class _LifeTipCategoryRail extends StatelessWidget {
  const _LifeTipCategoryRail({
    required this.filters,
    required this.selectedFilter,
    required this.onSelected,
  });

  final List<_CategoryFilter> filters;
  final _CategoryFilter selectedFilter;
  final ValueChanged<_CategoryFilter> onSelected;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 38.h,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: filters.length,
        separatorBuilder: (_, __) => SizedBox(width: 8.w),
        itemBuilder: (context, index) {
          final filter = filters[index];
          final selected = filter.label == selectedFilter.label;
          final aes = aestheticsForCategory(filter.value ?? '');
          return Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => onSelected(filter),
              borderRadius: BorderRadius.circular(999.r),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                padding: EdgeInsets.symmetric(horizontal: 15.w, vertical: 8.h),
                decoration: BoxDecoration(
                  color: selected ? LifeTrapColors.forest : Colors.white,
                  borderRadius: BorderRadius.circular(999.r),
                  border: Border.all(
                    color: selected
                        ? LifeTrapColors.forest
                        : LifeTrapColors.border,
                    width: 1.w,
                  ),
                ),
                child: Text(
                  filter.label,
                  style: TextStyle(
                    color: selected ? Colors.white : aes.primary,
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({
    required this.title,
    required this.count,
  });

  final String title;
  final int count;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: TextStyle(
              color: LifeTrapColors.ink,
              fontSize: 16.sp,
              fontWeight: FontWeight.w900,
              letterSpacing: 0,
            ),
          ),
        ),
        Text(
          '$count 則',
          style: TextStyle(
            color: LifeTrapColors.body,
            fontSize: 11.sp,
            fontWeight: FontWeight.w800,
            letterSpacing: 0,
          ),
        ),
      ],
    );
  }
}

class _LifeTipFeaturedCard extends StatelessWidget {
  const _LifeTipFeaturedCard({
    required this.item,
    required this.onTap,
  });

  final HomeNewsletterItem item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final cleanTip = _cleanTip(item.tip);
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24.r),
        child: Ink(
          decoration: BoxDecoration(
            color: LifeTrapColors.card,
            borderRadius: BorderRadius.circular(24.r),
            border: Border.all(
                color: Colors.white.withValues(alpha: 0.78), width: 1.w),
          ),
          child: Padding(
            padding: EdgeInsets.fromLTRB(20.w, 18.h, 14.w, 13.h),
            child: Column(
              children: [
                Expanded(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.title,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: LifeTrapColors.cobalt,
                                fontSize: 21.sp,
                                fontWeight: FontWeight.w900,
                                height: 1.18,
                                letterSpacing: 0,
                              ),
                            ),
                            SizedBox(height: 10.h),
                            Text(
                              item.summary,
                              maxLines: 3,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: LifeTrapColors.body,
                                fontSize: 14.6.sp,
                                fontWeight: FontWeight.w800,
                                height: 1.28,
                                letterSpacing: 0,
                              ),
                            ),
                            const Spacer(),
                            Text(
                              '小提醒：$cleanTip',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: LifeTrapColors.reminder,
                                fontSize: 12.sp,
                                fontWeight: FontWeight.w900,
                                height: 1.3,
                                letterSpacing: 0,
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(width: 14.w),
                      _IllustrationPanel(
                        width: 116.w,
                        height: 142.h,
                        radius: 22.r,
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 8.h),
                _MetricRow(item: item, iconSize: 30.sp, fontSize: 15.sp),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _LifeTipListCard extends StatelessWidget {
  const _LifeTipListCard({
    required this.item,
    required this.onTap,
  });

  final HomeNewsletterItem item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final aes = aestheticsForCategory(item.category);
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20.r),
        child: Ink(
          decoration: BoxDecoration(
            color: LifeTrapColors.cardAlt,
            borderRadius: BorderRadius.circular(20.r),
            border: Border.all(color: LifeTrapColors.border, width: 0.9.w),
          ),
          child: Padding(
            padding: EdgeInsets.fromLTRB(14.w, 14.h, 12.w, 14.h),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          _CategoryCapsule(label: aes.label, aesthetics: aes),
                          SizedBox(width: 8.w),
                          Text(
                            '5 分鐘閱讀',
                            style: TextStyle(
                              color: LifeTrapColors.body,
                              fontSize: 10.5.sp,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 8.h),
                      Text(
                        item.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: LifeTrapColors.cobalt,
                          fontSize: 15.sp,
                          fontWeight: FontWeight.w900,
                          height: 1.25,
                          letterSpacing: 0,
                        ),
                      ),
                      SizedBox(height: 6.h),
                      Text(
                        item.summary,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: LifeTrapColors.body,
                          fontSize: 12.2.sp,
                          fontWeight: FontWeight.w700,
                          height: 1.38,
                          letterSpacing: 0,
                        ),
                      ),
                      SizedBox(height: 8.h),
                      Text(
                        '小提醒：${_cleanTip(item.tip)}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: LifeTrapColors.reminder,
                          fontSize: 11.sp,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 10.w),
                Column(
                  children: [
                    _IllustrationPanel(width: 74.w, height: 74.w, radius: 18.r),
                    SizedBox(height: 12.h),
                    Icon(
                      Icons.chevron_right_rounded,
                      color: LifeTrapColors.forest,
                      size: 26.sp,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _DetailHeader extends StatelessWidget {
  const _DetailHeader({
    required this.item,
    required this.aesthetics,
  });

  final HomeNewsletterItem item;
  final CategoryAesthetics aesthetics;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          item.title,
          style: TextStyle(
            color: LifeTrapColors.cobalt,
            fontSize: 26.sp,
            fontWeight: FontWeight.w900,
            height: 1.18,
            letterSpacing: 0,
          ),
        ),
        SizedBox(height: 12.h),
        Row(
          children: [
            _CategoryCapsule(label: aesthetics.label, aesthetics: aesthetics),
            SizedBox(width: 8.w),
            Text(
              '5 分鐘閱讀',
              style: TextStyle(
                color: LifeTrapColors.body,
                fontSize: 12.sp,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
        SizedBox(height: 16.h),
        Container(
          width: double.infinity,
          padding: EdgeInsets.fromLTRB(16.w, 16.h, 14.w, 14.h),
          decoration: BoxDecoration(
            color: LifeTrapColors.card,
            borderRadius: BorderRadius.circular(24.r),
            border: Border.all(
                color: Colors.white.withValues(alpha: 0.72), width: 1.w),
          ),
          child: Column(
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      item.summary,
                      style: TextStyle(
                        color: LifeTrapColors.body,
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w800,
                        height: 1.45,
                        letterSpacing: 0,
                      ),
                    ),
                  ),
                  SizedBox(width: 12.w),
                  _IllustrationPanel(width: 96.w, height: 96.w, radius: 20.r),
                ],
              ),
              SizedBox(height: 12.h),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  '小提醒：${_cleanTip(item.tip)}',
                  style: TextStyle(
                    color: LifeTrapColors.reminder,
                    fontSize: 12.5.sp,
                    fontWeight: FontWeight.w900,
                    height: 1.35,
                    letterSpacing: 0,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _DetailPanel extends StatelessWidget {
  const _DetailPanel({
    required this.title,
    required this.icon,
    required this.accentColor,
    required this.child,
    this.subtitle,
  });

  final String title;
  final IconData icon;
  final Color accentColor;
  final Widget child;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22.r),
        border: Border.all(color: LifeTrapColors.border, width: 0.9.w),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 30.w,
                height: 30.w,
                decoration: BoxDecoration(
                  color: accentColor.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: accentColor, size: 17.sp),
              ),
              SizedBox(width: 9.w),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    color: LifeTrapColors.ink,
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0,
                  ),
                ),
              ),
              if (subtitle != null)
                Text(
                  subtitle!,
                  style: TextStyle(
                    color: accentColor,
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w900,
                  ),
                ),
            ],
          ),
          SizedBox(height: 12.h),
          child,
        ],
      ),
    );
  }
}

class _DetailBullet extends StatelessWidget {
  const _DetailBullet({
    required this.text,
    required this.color,
  });

  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 9.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: EdgeInsets.only(top: 6.h),
            width: 7.w,
            height: 7.w,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          SizedBox(width: 10.w),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                color: LifeTrapColors.body,
                fontSize: 13.sp,
                fontWeight: FontWeight.w700,
                height: 1.45,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ChecklistRow extends StatelessWidget {
  const _ChecklistRow({
    required this.index,
    required this.text,
    required this.checked,
    required this.onTap,
  });

  final int index;
  final String text;
  final bool checked;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 9.h),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16.r),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 11.h),
            decoration: BoxDecoration(
              color:
                  checked ? LifeTrapColors.mutedGreen : LifeTrapColors.cardAlt,
              borderRadius: BorderRadius.circular(16.r),
              border: Border.all(
                color:
                    checked ? LifeTrapColors.reminder : LifeTrapColors.border,
                width: 0.9.w,
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  width: 22.w,
                  height: 22.w,
                  decoration: BoxDecoration(
                    color: checked ? LifeTrapColors.reminder : Colors.white,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: checked
                          ? LifeTrapColors.reminder
                          : LifeTrapColors.body,
                      width: 1.2.w,
                    ),
                  ),
                  child: Center(
                    child: checked
                        ? Icon(Icons.check_rounded,
                            color: Colors.white, size: 15.sp)
                        : Text(
                            '${index + 1}',
                            style: TextStyle(
                              color: LifeTrapColors.body,
                              fontSize: 10.sp,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                  ),
                ),
                SizedBox(width: 10.w),
                Expanded(
                  child: Text(
                    text,
                    style: TextStyle(
                      color:
                          checked ? LifeTrapColors.forest : LifeTrapColors.body,
                      fontSize: 12.8.sp,
                      fontWeight: FontWeight.w800,
                      height: 1.42,
                      decoration: checked ? TextDecoration.lineThrough : null,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _CategoryCapsule extends StatelessWidget {
  const _CategoryCapsule({
    required this.label,
    required this.aesthetics,
  });

  final String label;
  final CategoryAesthetics aesthetics;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 9.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: aesthetics.tint,
        borderRadius: BorderRadius.circular(999.r),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: aesthetics.primary,
          fontSize: 10.5.sp,
          fontWeight: FontWeight.w900,
          letterSpacing: 0,
        ),
      ),
    );
  }
}

class _IllustrationPanel extends StatelessWidget {
  const _IllustrationPanel({
    required this.width,
    required this.height,
    required this.radius,
  });

  final double width;
  final double height;
  final double radius;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      alignment: Alignment.center,
      padding: EdgeInsets.all(10.w),
      decoration: BoxDecoration(
        color: LifeTrapColors.panelGray,
        borderRadius: BorderRadius.circular(radius),
      ),
      child: Text(
        '跟內容有關的小插圖',
        textAlign: TextAlign.center,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          color: Colors.black,
          fontSize: 10.5.sp,
          fontWeight: FontWeight.w700,
          height: 1.25,
        ),
      ),
    );
  }
}

class _MetricRow extends StatelessWidget {
  const _MetricRow({
    required this.item,
    required this.iconSize,
    required this.fontSize,
  });

  final HomeNewsletterItem item;
  final double iconSize;
  final double fontSize;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _MetricItem(
          icon: Icons.favorite_border_rounded,
          color: LifeTrapColors.heart,
          label: item.likes,
          iconSize: iconSize,
          fontSize: fontSize,
        ),
        _MetricItem(
          icon: Icons.share_rounded,
          color: LifeTrapColors.share,
          label: item.shares,
          iconSize: iconSize,
          fontSize: fontSize,
        ),
        _MetricItem(
          icon: Icons.chat_bubble_outline_rounded,
          color: LifeTrapColors.comment,
          label: item.comments,
          iconSize: iconSize,
          fontSize: fontSize,
        ),
        _MetricItem(
          icon: Icons.file_download_outlined,
          color: LifeTrapColors.download,
          label: item.downloads,
          iconSize: iconSize,
          fontSize: fontSize,
        ),
      ],
    );
  }
}

class _MetricItem extends StatelessWidget {
  const _MetricItem({
    required this.icon,
    required this.color,
    required this.label,
    required this.iconSize,
    required this.fontSize,
  });

  final IconData icon;
  final Color color;
  final String label;
  final double iconSize;
  final double fontSize;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: iconSize),
          SizedBox(width: 5.w),
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: Colors.black,
                fontSize: fontSize,
                fontWeight: FontWeight.w800,
                letterSpacing: 0,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LifeTipPageDots extends StatelessWidget {
  const _LifeTipPageDots({
    required this.count,
    required this.pageOffset,
  });

  final int count;
  final double pageOffset;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(count, (index) {
        final distance = (index - pageOffset).abs();
        final activeWeight = (1.0 - distance).clamp(0.0, 1.0);
        return AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          width: 8.w + (10.w * activeWeight),
          height: 8.w,
          margin: EdgeInsets.symmetric(horizontal: 5.w),
          decoration: BoxDecoration(
            color: Color.lerp(
              const Color(0xFFD1D1D1),
              LifeTrapColors.card,
              activeWeight,
            ),
            borderRadius: BorderRadius.circular(999.r),
          ),
        );
      }),
    );
  }
}

class _LifeTipStatusCard extends StatelessWidget {
  const _LifeTipStatusCard({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(15.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(color: LifeTrapColors.border, width: 0.9.w),
      ),
      child: Text(
        message,
        style: TextStyle(
          color: LifeTrapColors.body,
          fontSize: 12.5.sp,
          fontWeight: FontWeight.w700,
          height: 1.5,
        ),
      ),
    );
  }
}

String _cleanTip(String tip) {
  return tip
      .replaceFirst(RegExp(r'^小提醒：'), '')
      .replaceFirst(RegExp(r'^💡\s*'), '')
      .trim();
}
