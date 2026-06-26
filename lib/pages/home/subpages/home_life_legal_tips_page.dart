import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lawapp/app/app_state.dart';
import 'package:lawapp/components/home/home_content.dart';
import 'package:lawapp/components/shared/custom_toast.dart';
import 'package:lawapp/components/shared/law_app_story_action_bar.dart';
import 'package:lawapp/components/shared/share_sheet.dart';
import 'package:lawapp/data/mock_data/home/home_mock_data.dart';
import 'package:lawapp/pages/home/subpages/home_subpage_primitives.dart';
import 'package:lawapp/pages/learning/know_law_page.dart';
import 'package:lawapp/platform/native_share_bridge.dart';
import 'package:lawapp/theme/app_colors.dart';
import 'package:lawapp/features/case_time_machine/widgets/case_time_machine_svg_icon.dart';

String _imageForCategory(String category) {
  return switch (category) {
    '養狗' => 'assets/images/learning/levels/level_02_article_reader.png',
    '租屋' => 'assets/images/learning/rent_course_room.png',
    '拍照隱私' => 'assets/images/learning/privacy_course_room.png',
    '網購' => 'assets/images/learning/consumer_course_room.png',
    '交通' => 'assets/images/learning/car_course_room.png',
    _ => 'assets/images/learning/levels/level_01_legal_beginner.png',
  };
}

String _lifeTipArticleId(HomeNewsletterItem item) {
  return 'article-${_lifeTipSlugFor(item.title)}';
}

String _lifeTipTopicId(HomeNewsletterItem item) {
  return 'topic-${_lifeTipSlugFor(item.title)}';
}

String _lifeTipSlugFor(String value) {
  return value
      .trim()
      .toLowerCase()
      .replaceAll(RegExp(r'\s+'), '')
      .replaceAll(RegExp(r'[^a-z0-9\u4e00-\u9fff]+'), '');
}

const String _svgShareNetwork = '''
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.2" stroke-linecap="round" stroke-linejoin="round">
  <circle cx="18" cy="5" r="3"></circle>
  <circle cx="6" cy="12" r="3"></circle>
  <circle cx="18" cy="19" r="3"></circle>
  <line x1="8.59" y1="13.51" x2="15.42" y2="17.49"></line>
  <line x1="15.41" y1="6.51" x2="8.59" y2="10.49"></line>
</svg>
''';

// 台灣繁體中文教學註解：
// 生活避坑筆記這次改成「日常故事卡」設計系統。
// 色彩以暖白紙張、深綠行動色、低飽和藍灰與少量陶土紅組成，
// 讓使用者感覺是在閱讀生活提醒，而不是硬背法律條文。
class ProtoColors {
  static const Color sageGreen = Color(0xFFAFC3B4);
  static const Color blueGray = Color(0xFFA9B4C4);
  static const Color warmBeige = Color(0xFFF2EDE6);
  static const Color softTaupe = Color(0xFFD7CEC2);
  static const Color clay = Color(0xFFC48A7A);
  static const Color deepGreen = Color(0xFF2C5E43);
  static const Color charcoal = Color(0xFF17231F);
  static const Color lightBg = Color(0xFFFAF8F5); // 暖米白色背景
  static const Color border = AppColors.border;
}

class CategoryAesthetics {
  final Color primary;
  final List<Color> gradient;
  final IconData icon;

  const CategoryAesthetics({
    required this.primary,
    required this.gradient,
    required this.icon,
  });
}

CategoryAesthetics aestheticsForCategory(String category, bool isDark) {
  return switch (category) {
    '養狗' => const CategoryAesthetics(
        primary: ProtoColors.deepGreen,
        gradient: [ProtoColors.deepGreen, ProtoColors.sageGreen],
        icon: Icons.pets_rounded,
      ),
    '租屋' => const CategoryAesthetics(
        primary: Color(0xFF7A624A),
        gradient: [Color(0xFF7A624A), ProtoColors.softTaupe],
        icon: Icons.home_work_outlined,
      ),
    '拍照隱私' => const CategoryAesthetics(
        primary: Color(0xFF426E9F),
        gradient: [Color(0xFF426E9F), ProtoColors.blueGray],
        icon: Icons.photo_camera_outlined,
      ),
    '網購' => const CategoryAesthetics(
        primary: Color(0xFFC9877B),
        gradient: [Color(0xFFC9877B), Color(0xFFE8C8BE)],
        icon: Icons.shopping_bag_outlined,
      ),
    '交通' => const CategoryAesthetics(
        primary: Color(0xFF8A7B5C),
        gradient: [Color(0xFF8A7B5C), Color(0xFFE5D5A8)],
        icon: Icons.traffic_rounded,
      ),
    _ => const CategoryAesthetics(
        primary: ProtoColors.charcoal,
        gradient: [ProtoColors.charcoal, Color(0xFF888888)],
        icon: Icons.lightbulb_outline_rounded,
      ),
  };
}

/// 生活避坑筆記列表頁
class LifeLegalTipsPage extends StatefulWidget {
  const LifeLegalTipsPage({super.key});

  @override
  State<LifeLegalTipsPage> createState() => _LifeLegalTipsPageState();
}

class _LifeLegalTipsPageState extends State<LifeLegalTipsPage> {
  static const _categories = ['全部', '養狗', '租屋', '拍照隱私', '網購', '交通'];

  late final TextEditingController _searchController;
  var _selectedCategory = '全部';
  var _query = '';
  var _isSearchOpen = false;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();

    _searchController.addListener(() {
      setState(() {
        _query = _searchController.text.trim();
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.paddingOf(context).top;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final filteredItems = homeNewsletterItems.where((item) {
      final matchesCategory =
          _selectedCategory == '全部' || item.category == _selectedCategory;
      final matchesQuery = _query.isEmpty ||
          item.title.contains(_query) ||
          item.summary.contains(_query) ||
          item.tip.contains(_query) ||
          item.category.contains(_query);
      return matchesCategory && matchesQuery;
    }).toList(growable: false);

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0F1216) : ProtoColors.lightBg,
      body: CustomScrollView(
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverPersistentHeader(
            pinned: true,
            delegate: _LifeTrapFrozenHeaderDelegate(
              topPadding: topPadding,
              isDark: isDark,
              searchController: _searchController,
              labels: _categories,
              selectedLabel: _selectedCategory,
              isSearchOpen: _isSearchOpen,
              isSearchActive: _query.isNotEmpty,
              onBack: () => Navigator.of(context).pop(),
              onSearchToggle: () {
                setState(() {
                  if (_isSearchOpen) {
                    _searchController.clear();
                  }
                  _isSearchOpen = !_isSearchOpen;
                });
              },
              onSelected: (label) {
                setState(() => _selectedCategory = label);
              },
            ),
          ),
          SliverPadding(
            padding: EdgeInsets.fromLTRB(16.w, 18.h, 16.w, 42.h),
            sliver: SliverList(
              delegate: SliverChildListDelegate(
                [
                  _LifeTipFeaturedCard(
                    item: homeNewsletterItems.first,
                    onTap: () => _openTip(context, homeNewsletterItems.first),
                  ),
                  if (_selectedCategory == '租屋') ...[
                    SizedBox(height: 18.h),
                    const _RentTimelineGuideCard(),
                  ],
                  SizedBox(height: 22.h),
                  _SubpageInlineHeader(
                    title: _selectedCategory == '全部'
                        ? '今天的日常小動作'
                        : _selectedCategory,
                    count: filteredItems.length,
                  ),
                  SizedBox(height: 12.h),
                  if (filteredItems.isEmpty)
                    const SubpageStatusCard(
                      message: '目前沒有符合條件的避坑筆記，換個關鍵字試試看。',
                    )
                  else
                    ...filteredItems.take(16).map(
                          (item) => Padding(
                            padding: EdgeInsets.only(bottom: 10.h),
                            child: _LifeTipListCard(
                              item: item,
                              onTap: () => _openTip(context, item),
                            ),
                          ),
                        ),
                  SizedBox(height: 12.h),
                  const SubpageStatusCard(
                    message: '生活避坑筆記僅提供一般法律常識與風險預防參考，非正式律師意見。若遇具體糾紛，請尋求專業法律服務。',
                  ),
                ],
              ),
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
  double _readingProgress = 0.0;
  var _syncedInitialInteractionState = false;

  var _isFollowing = false;
  var _isBookmarked = false;
  var _isLiked = false;
  var _shareCountDelta = 0;
  var _commentCountDelta = 0;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollController.addListener(_onScroll);

    _steps = _buildActionSteps(widget.item);
    _stepsChecked = List.generate(_steps.length, (_) => false);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_syncedInitialInteractionState) return;

    final appState = LawAppScope.of(context);
    _isBookmarked = appState.isArticleSaved(_lifeTipArticleId(widget.item));
    _isFollowing = appState.isTopicFollowed(_lifeTipTopicId(widget.item));
    _syncedInitialInteractionState = true;
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    final maxScroll = _scrollController.position.maxScrollExtent;
    if (maxScroll <= 0) return;
    setState(() {
      _readingProgress = (_scrollController.offset / maxScroll).clamp(0.0, 1.0);
    });
  }

  int _metricBase(String value) {
    final digits = RegExp(r'\d+').firstMatch(value)?.group(0);
    return int.tryParse(digits ?? '') ?? 0;
  }

  String _metricText(String value, int delta) {
    final next = _metricBase(value) + delta;
    return '$next+';
  }

  void _toggleLike() {
    if (!_isLiked) {
      HapticFeedback.mediumImpact();
    } else {
      HapticFeedback.lightImpact();
    }
    setState(() {
      _isLiked = !_isLiked;
    });
  }

  Future<void> _toggleBookmark() async {
    if (!_isBookmarked) {
      HapticFeedback.mediumImpact();
    } else {
      HapticFeedback.lightImpact();
    }
    final next = !_isBookmarked;
    setState(() {
      _isBookmarked = next;
    });
    await LawAppScope.of(context).setArticleSaved(
      _lifeTipArticleId(widget.item),
      next,
    );
  }

  Future<void> _toggleFollow() async {
    if (!_isFollowing) {
      HapticFeedback.mediumImpact();
    } else {
      HapticFeedback.lightImpact();
    }
    final next = !_isFollowing;
    setState(() {
      _isFollowing = next;
    });
    await LawAppScope.of(context).setTopicFollowed(
      _lifeTipTopicId(widget.item),
      next,
    );
  }

  void _shareFromInteraction() {
    setState(() {
      _shareCountDelta += 1;
    });
    _showShareCardDialog();
  }

  void _showCommentsBottomSheet() {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return _LifeTipCommentSheet(
          title: widget.item.title,
          onCommentPosted: () {
            setState(() {
              _commentCountDelta += 1;
            });
          },
        );
      },
    );
  }

  void _showNotesBottomSheet() {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        final bg = isDark ? const Color(0xFF1E2228) : Colors.white;
        final textCol = isDark ? Colors.white : const Color(0xFF17231F);
        return Padding(
          padding:
              EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
          child: Container(
            decoration: BoxDecoration(
              color: bg,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
            ),
            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '編輯生活避坑筆記',
                      style: TextStyle(
                        fontSize: 15.sp,
                        fontWeight: FontWeight.bold,
                        color: textCol,
                      ),
                    ),
                    IconButton(
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      icon: const Icon(Icons.close_rounded, color: Colors.grey),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
                SizedBox(height: 12.h),
                Text(
                  '主題：${widget.item.title}',
                  style: TextStyle(
                    fontSize: 11.5.sp,
                    color: Colors.grey,
                  ),
                ),
                SizedBox(height: 16.h),
                TextField(
                  maxLines: 4,
                  autofocus: true,
                  style: TextStyle(fontSize: 13.sp, color: textCol),
                  decoration: InputDecoration(
                    hintText: '在此輸入您的心得或整理筆記...',
                    hintStyle: TextStyle(fontSize: 12.5.sp, color: Colors.grey),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.r),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.r),
                      borderSide: const BorderSide(color: Color(0xFF2EA26F)),
                    ),
                  ),
                ),
                SizedBox(height: 16.h),
                SizedBox(
                  width: double.infinity,
                  height: 44.h,
                  child: FilledButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      CustomToast.show(this.context, '筆記已儲存');
                    },
                    style: FilledButton.styleFrom(
                      backgroundColor: const Color(0xFF2EA26F),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                    ),
                    child: const Text('儲存筆記'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showShareCardDialog() {
    showDialog<void>(
      context: context,
      builder: (context) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        final bg = isDark ? const Color(0xFF1E2228) : Colors.white;
        final textCol = isDark ? Colors.white : const Color(0xFF17231F);
        final title = widget.item.title;
        final summary = widget.item.summary.isNotEmpty
            ? widget.item.summary
            : '生活處處有坑，點滴學習才能安穩避險。本期避坑指南將為您解析核心法律點。';

        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 40.h),
          child: Container(
            decoration: BoxDecoration(
              color: bg,
              borderRadius: BorderRadius.circular(20.r),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.15),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            padding: EdgeInsets.all(20.w),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // 頂部關閉按鈕
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '分享避坑圖卡',
                      style: TextStyle(
                        fontSize: 15.sp,
                        fontWeight: FontWeight.bold,
                        color: textCol,
                      ),
                    ),
                    IconButton(
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      icon: Icon(Icons.close_rounded,
                          size: 20.sp, color: Colors.grey),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
                SizedBox(height: 16.h),
                // 圖卡預覽區域
                Container(
                  padding: EdgeInsets.all(16.w),
                  decoration: BoxDecoration(
                    color: isDark
                        ? const Color(0xFF13171C)
                        : const Color(0xFFF9F6F0),
                    borderRadius: BorderRadius.circular(12.r),
                    border: Border.all(
                      color: isDark
                          ? const Color(0xFF2D333F)
                          : const Color(0xFFEFE6D5),
                      width: 1.w,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 引號裝飾
                      Text(
                        '“',
                        style: TextStyle(
                          fontSize: 28.sp,
                          fontFamily: 'serif',
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF2C5E43),
                          height: 0.8,
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 8.w),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              title,
                              style: TextStyle(
                                fontSize: 15.sp,
                                fontWeight: FontWeight.w900,
                                color: textCol,
                                height: 1.4,
                              ),
                            ),
                            SizedBox(height: 12.h),
                            Text(
                              summary,
                              style: TextStyle(
                                fontSize: 12.sp,
                                color: isDark
                                    ? const Color(0xFF94A3B8)
                                    : const Color(0xFF4A5568),
                                height: 1.6,
                              ),
                              maxLines: 4,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      Align(
                        alignment: Alignment.bottomRight,
                        child: Padding(
                          padding: EdgeInsets.only(top: 16.h, right: 8.w),
                          child: Text(
                            '—— 摘自生活避坑筆記《$title》',
                            style: TextStyle(
                              fontSize: 10.sp,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF2C5E43),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 20.h),
                // 按鈕區域
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          Clipboard.setData(ClipboardData(
                              text:
                                  '【生活避坑筆記】\n標題：$title\n摘要：$summary\n來源：法助官網 https://lawapp.com/tips'));
                          Navigator.of(context).pop();
                          CustomToast.show(
                            this.context,
                            '文字已複製',
                            icon: Icons.content_copy_rounded,
                          );
                        },
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFF2C5E43),
                          side: const BorderSide(color: Color(0xFF2C5E43)),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.r),
                          ),
                          padding: EdgeInsets.symmetric(vertical: 12.h),
                        ),
                        child: const Text('複製文字',
                            style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: FilledButton(
                        onPressed: () async {
                          Navigator.of(context).pop();
                          await _shareTipCardWithAppleSheet(
                            title: title,
                            summary: summary,
                          );
                        },
                        style: FilledButton.styleFrom(
                          backgroundColor: const Color(0xFF2C5E43),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.r),
                          ),
                          padding: EdgeInsets.symmetric(vertical: 12.h),
                        ),
                        child: const Text('分享圖卡',
                            style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _shareTipCardWithAppleSheet({
    required String title,
    required String summary,
  }) async {
    // 台灣繁體中文教學註解：
    // 分享圖卡不再直接宣稱「已儲存至相簿」。iOS 先開 Apple 原生分享面板，
    // 讓使用者在系統選項中自行選擇儲存圖片、AirDrop 或分享到其他 App。
    final openedNativeSheet = await NativeShareBridge.shareTipCard(
      title: title,
      summary: summary,
      source: '摘自生活避坑筆記《$title》',
    );
    if (openedNativeSheet) return;
    if (!mounted) return;

    ShareSheet.show(
      context,
      title: title,
      url: 'https://lawapp.com/tips/${Uri.encodeComponent(title)}',
    );
  }

  Widget _buildBottomNavigationBar(bool isDark, CategoryAesthetics aes) {
    // 台灣繁體中文教學註解：
    // 生活避坑筆記詳細頁直接共用案件詳情頁同源底欄，且不覆蓋顏色；
    // 避免同一組 NavBar 在案件與筆記詳情頁出現「設計一樣但顏色不同」的維護漂移。
    return LawAppStoryActionBar(
      isFollowed: _isFollowing,
      isSaved: _isBookmarked,
      onAskAssistant: () {
        Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (__) => LawAssistantChatPage(
              initialPrompt:
                  '我想了解「${widget.item.title}」這個生活小動作可能有哪些法律問題，可以怎麼避坑？',
            ),
          ),
        );
      },
      onNote: _showNotesBottomSheet,
      onFollow: () {
        _toggleFollow();
        CustomToast.show(
          context,
          _isFollowing ? '已開啟追蹤' : '已取消追蹤',
          icon: _isFollowing
              ? Icons.notifications_active_rounded
              : Icons.notifications_off_rounded,
        );
      },
      onSave: () {
        _toggleBookmark();
        CustomToast.show(
          context,
          _isBookmarked ? '已加入收藏' : '已取消收藏',
          icon: _isBookmarked ? Icons.bookmark_rounded : Icons.bookmark_border,
        );
      },
      onShare: _showShareCardDialog,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final aes = aestheticsForCategory(widget.item.category, isDark);
    final appBarBg = isDark ? const Color(0xFF0F1216) : const Color(0xFFFAF8F5);

    return Scaffold(
      backgroundColor: appBarBg,
      appBar: AppBar(
        backgroundColor: appBarBg,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            size: 20.sp,
            color: isDark ? Colors.white : const Color(0xFF2C5E43),
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          '避坑指引',
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.normal,
            color: isDark ? Colors.white : const Color(0xFF2C5E43),
          ),
        ),
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(2.5.h),
          child: Container(
            alignment: Alignment.centerLeft,
            height: 2.5.h,
            color: isDark
                ? Colors.white.withValues(alpha: 0.03)
                : Colors.black.withValues(alpha: 0.02),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 80),
              width: MediaQuery.of(context).size.width * _readingProgress,
              height: 2.5.h,
              color: aes.primary,
            ),
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomNavigationBar(isDark, aes),
      body: ListView(
        controller: _scrollController,
        physics: const BouncingScrollPhysics(),
        padding: EdgeInsets.fromLTRB(16.w, 10.h, 16.w, 24.h),
        children: [
          // 頂部首部資訊區
          _buildHeaderSection(isDark),
          SizedBox(height: 20.h),

          _buildInteractionSection(isDark, aes),
          SizedBox(height: 20.h),

          // 1. 踩坑情境
          _buildScenarioSection(isDark, aes),
          SizedBox(height: 20.h),

          // 2. 你要注意
          _buildWarningSection(isDark, aes),
          SizedBox(height: 20.h),

          // 3. 避坑做法
          _buildStepsSection(isDark, aes),
          SizedBox(height: 20.h),

          // 4. 相關法規 / 生活提醒
          _buildLawsSection(isDark, aes),
        ],
      ),
    );
  }

  Widget _buildHeaderSection(bool isDark) {
    final aes = aestheticsForCategory(widget.item.category, isDark);
    final readTime = _readTimeForTip(widget.item);
    final imageAsset = _imageForCategory(widget.item.category);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: EdgeInsets.symmetric(horizontal: 9.w, vertical: 4.h),
              decoration: BoxDecoration(
                color: aes.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(999.r),
              ),
              child: Text(
                widget.item.category,
                style: TextStyle(
                  color: aes.primary,
                  fontSize: 10.5.sp,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
            SizedBox(width: 8.w),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 9.w, vertical: 4.h),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1E2228) : Colors.white,
                borderRadius: BorderRadius.circular(999.r),
                border: Border.all(
                  color: isDark
                      ? const Color(0xFF2D333F)
                      : const Color(0xFFE8DFD1),
                  width: 0.8.w,
                ),
              ),
              child: Text(
                readTime,
                style: TextStyle(
                  color: isDark
                      ? const Color(0xFF94A3B8)
                      : AppColors.textSecondary,
                  fontSize: 10.5.sp,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 12.h),
        Text(
          widget.item.title,
          style: TextStyle(
            fontSize: 21.sp,
            fontWeight: FontWeight.w900,
            color: isDark ? Colors.white : ProtoColors.charcoal,
            height: 1.35,
            letterSpacing: 0,
          ),
        ),
        SizedBox(height: 8.h),
        Text(
          '從一個日常小動作開始，看懂它背後可能牽涉的法律風險與自保方式。',
          style: TextStyle(
            fontSize: 12.5.sp,
            height: 1.5,
            fontWeight: FontWeight.w700,
            color: isDark ? const Color(0xFF94A3B8) : AppColors.textSecondary,
          ),
        ),
        SizedBox(height: 14.h),
        ClipRRect(
          borderRadius: BorderRadius.circular(12.r),
          child: Image.asset(
            imageAsset,
            width: double.infinity,
            height: 142.h,
            fit: BoxFit.cover,
          ),
        ),
        SizedBox(height: 14.h),
        Container(
          width: double.infinity,
          padding: EdgeInsets.all(12.w),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF181C23) : Colors.white,
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(
              color: isDark ? const Color(0xFF2D333F) : const Color(0xFFE8DFD1),
              width: 0.8.w,
            ),
          ),
          child: Text(
            _issueHintForTip(widget.item),
            style: TextStyle(
              fontSize: 12.5.sp,
              height: 1.45,
              color: isDark ? const Color(0xFFE2E8F0) : ProtoColors.charcoal,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInteractionSection(bool isDark, CategoryAesthetics aes) {
    // 台灣繁體中文教學註解：
    // 這是詳情內頁的「文章互動區」，和首頁入口卡的互動列語意一致。
    // 底部 Nav 偏向下一步操作；這裡則讓使用者對文章本身按讚、留言、分享與儲存。
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(14.w, 14.h, 14.w, 12.h),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF181C23) : Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: isDark ? const Color(0xFF2D333F) : const Color(0xFFE8DFD1),
          width: 0.8.w,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 34.w,
                height: 34.w,
                decoration: BoxDecoration(
                  color: aes.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: Center(
                  child: CtmSvgIcon(
                    CtmSvgIcons.sprout,
                    color: aes.primary,
                    size: 18.sp,
                  ),
                ),
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '我學到的避坑提醒',
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w900,
                        color: isDark ? Colors.white : ProtoColors.charcoal,
                        letterSpacing: 0,
                      ),
                    ),
                    SizedBox(height: 3.h),
                    Text(
                      '覺得有幫助，可以留下反應或收藏到稍後複習。',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 11.5.sp,
                        fontWeight: FontWeight.w700,
                        color: isDark
                            ? const Color(0xFF94A3B8)
                            : AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          Row(
            children: [
              _LifeTipInteractionMetric(
                svgPath: _isLiked ? CtmSvgIcons.heartFilled : CtmSvgIcons.heart,
                color: const Color(0xFFC9877B),
                label: _metricText(widget.item.likes, _isLiked ? 1 : 0),
                onTap: _toggleLike,
              ),
              _LifeTipInteractionMetric(
                svgPath: _svgShareNetwork,
                color: const Color(0xFF8A7B5C),
                label: _metricText(widget.item.shares, _shareCountDelta),
                onTap: _shareFromInteraction,
              ),
              _LifeTipInteractionMetric(
                svgPath: CtmSvgIcons.message,
                color: const Color(0xFF426E9F),
                label: _metricText(widget.item.comments, _commentCountDelta),
                onTap: _showCommentsBottomSheet,
              ),
              _LifeTipInteractionMetric(
                svgPath: CtmSvgIcons.bookmark,
                color:
                    _isBookmarked ? ProtoColors.deepGreen : AppColors.textMuted,
                label: _isBookmarked ? '已儲存' : '儲存',
                onTap: () {
                  _toggleBookmark();
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildScenarioSection(bool isDark, CategoryAesthetics aes) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF181C23) : const Color(0xFFFFFAF2),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: isDark ? const Color(0xFF2D333F) : const Color(0xFFEFE3D0),
          width: 0.8.w,
        ),
      ),
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CtmSvgIcon(CtmSvgIcons.question,
                    color: aes.primary, size: 18.sp),
                SizedBox(width: 8.w),
                Text(
                  '日常情境',
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w900,
                    color: isDark ? Colors.white : AppColors.textPrimary,
                  ),
                ),
              ],
            ),
            SizedBox(height: 8.h),
            Text(
              _scenarioForTip(widget.item),
              style: TextStyle(
                fontSize: 13.sp,
                height: 1.5,
                color:
                    isDark ? const Color(0xFFCBD5E1) : const Color(0xFF475467),
              ),
            ),
            SizedBox(height: 10.h),
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(12.w),
              decoration: BoxDecoration(
                color: aes.primary.withValues(alpha: isDark ? 0.12 : 0.08),
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Text(
                _exampleForTip(widget.item),
                style: TextStyle(
                  fontSize: 12.5.sp,
                  height: 1.5,
                  color: isDark ? const Color(0xFFE2E8F0) : aes.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWarningSection(bool isDark, CategoryAesthetics aes) {
    final bullets = _riskBulletsForTip(widget.item);
    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF181C23) : Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: isDark ? const Color(0xFF2D333F) : const Color(0xFFE8DFD1),
          width: 0.8.w,
        ),
      ),
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CtmSvgIcon(CtmSvgIcons.idea,
                    color: const Color(0xFFC9877B), size: 18.sp),
                SizedBox(width: 8.w),
                Text(
                  '可能踩到的法律問題',
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w900,
                    color: isDark ? Colors.white : AppColors.textPrimary,
                  ),
                ),
              ],
            ),
            SizedBox(height: 10.h),
            ...bullets.map((bullet) => Padding(
                  padding: EdgeInsets.only(bottom: 6.h),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        margin: EdgeInsets.only(top: 6.h),
                        width: 5.w,
                        height: 5.w,
                        decoration: const BoxDecoration(
                          color: Color(0xFFC9877B),
                          shape: BoxShape.circle,
                        ),
                      ),
                      SizedBox(width: 8.w),
                      Expanded(
                        child: Text(
                          bullet,
                          style: TextStyle(
                            fontSize: 13.sp,
                            height: 1.45,
                            color: isDark
                                ? const Color(0xFFCBD5E1)
                                : const Color(0xFF334155),
                          ),
                        ),
                      ),
                    ],
                  ),
                )),
          ],
        ),
      ),
    );
  }

  Widget _buildStepsSection(bool isDark, CategoryAesthetics aes) {
    final completedCount = _stepsChecked.where((c) => c).length;
    final progress = _steps.isEmpty ? 0.0 : completedCount / _steps.length;

    return ClipRRect(
      borderRadius: BorderRadius.circular(12.r),
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF181C23) : const Color(0xFFF4FAF7),
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
            color: isDark ? const Color(0xFF2D333F) : const Color(0xFFD2ECE0),
            width: 0.8.w,
          ),
        ),
        child: Padding(
          padding: EdgeInsets.all(14.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      CtmSvgIcon(CtmSvgIcons.filePen,
                          color: ProtoColors.deepGreen, size: 18.sp),
                      SizedBox(width: 8.w),
                      Text(
                        '你可以怎麼做',
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w900,
                          color: isDark ? Colors.white : AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                  CircularProgressRing(
                    progress: progress,
                    accentColor: ProtoColors.deepGreen,
                  ),
                ],
              ),
              SizedBox(height: 12.h),
              ...List.generate(_steps.length, (index) {
                final step = _steps[index];
                final isChecked = _stepsChecked[index];
                return GestureDetector(
                  onTap: () {
                    if (!isChecked) {
                      HapticFeedback.mediumImpact();
                    } else {
                      HapticFeedback.lightImpact();
                    }
                    setState(() {
                      _stepsChecked[index] = !_stepsChecked[index];
                    });
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: EdgeInsets.only(bottom: 8.h),
                    padding:
                        EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
                    decoration: BoxDecoration(
                      color: isChecked
                          ? (isDark
                              ? const Color(0xFF14241B)
                              : AppColors.success.withValues(alpha: 0.12))
                          : (isDark ? const Color(0xFF1E2228) : Colors.white),
                      borderRadius: BorderRadius.circular(8.r),
                      border: Border.all(
                        color: isChecked
                            ? AppColors.success
                            : (isDark
                                ? const Color(0xFF2D333F)
                                : ProtoColors.border),
                        width: 0.8.w,
                      ),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 18.w,
                          height: 18.w,
                          decoration: BoxDecoration(
                            color: isChecked
                                ? AppColors.success
                                : Colors.transparent,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: isChecked
                                  ? AppColors.success
                                  : ProtoColors.deepGreen,
                              width: 1.5.w,
                            ),
                          ),
                          child: Center(
                            child: isChecked
                                ? Icon(Icons.check,
                                    size: 12.sp,
                                    color: isDark ? Colors.black : Colors.white)
                                : Text(
                                    '${index + 1}',
                                    style: TextStyle(
                                      fontSize: 10.sp,
                                      fontWeight: FontWeight.bold,
                                      color: ProtoColors.deepGreen,
                                    ),
                                  ),
                          ),
                        ),
                        SizedBox(width: 10.w),
                        Expanded(
                          child: Text(
                            step,
                            style: TextStyle(
                              fontSize: 12.5.sp,
                              height: 1.45,
                              color: isChecked
                                  ? (isDark
                                      ? const Color(0xFF8CAF96)
                                      : const Color(0xFF3B5E4A))
                                  : (isDark
                                      ? const Color(0xFFE2E8F0)
                                      : const Color(0xFF334155)),
                              decoration:
                                  isChecked ? TextDecoration.lineThrough : null,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLawsSection(bool isDark, CategoryAesthetics aes) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12.r),
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF181C23) : const Color(0xFFFFFDF5),
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
            color: isDark ? const Color(0xFF2D333F) : const Color(0xFFF5E8C8),
            width: 0.8.w,
          ),
        ),
        child: Padding(
          padding: EdgeInsets.all(14.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CtmSvgIcon(CtmSvgIcons.gavel,
                      color: const Color(0xFF8A7B5C), size: 18.sp),
                  SizedBox(width: 8.w),
                  Text(
                    '法律提醒',
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w900,
                      color: isDark ? Colors.white : AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 10.h),
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(12.w),
                decoration: BoxDecoration(
                  color: isDark
                      ? const Color(0xFF2E2719)
                      : const Color(0xFFFFF9E6),
                  borderRadius: BorderRadius.circular(8.r),
                  border: Border.all(
                    color: isDark
                        ? const Color(0xFF3D3425)
                        : const Color(0xFFF1E4C3),
                    width: 0.8.w,
                  ),
                ),
                child: Text(
                  _lawHintForTip(widget.item),
                  style: TextStyle(
                    fontSize: 12.5.sp,
                    height: 1.5,
                    color: isDark
                        ? const Color(0xFFE2B095)
                        : const Color(0xFF7A624A),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static String _scenarioForTip(HomeNewsletterItem item) {
    // 台灣繁體中文教學註解：
    // 詳情頁的第一屏要讓使用者先代入「我也可能這樣做」的生活情境，
    // 再往下讀法律風險；這比一開始列法條更容易完成學習轉換。
    if (item.category.contains('養狗') || item.title.contains('狗')) {
      return '你只是帶狗散步、讓牠在社區或公園和人互動，但如果狗突然撲人、咬人或嚇到路人跌倒，事情就不只是道歉這麼簡單。';
    }
    if (item.category.contains('拍照') ||
        item.category.contains('隱私') ||
        item.title.contains('自拍') ||
        item.title.contains('截圖')) {
      return '朋友聚餐、路上拍照、社群截圖分享，看起來只是日常紀錄；但只要照片裡的人可以被辨識，或內容涉及私生活，就可能變成法律問題。';
    }
    if (item.category.contains('網購') || item.title.contains('退貨')) {
      return '下單、拆封、退貨、給負評都很日常，但商品類型、保存狀態與溝通紀錄不同，會影響你能不能主張退費或要求賠償。';
    }
    if (item.category.contains('交通') || item.title.contains('車禍')) {
      return '擦撞後趕著上班、口頭說沒事就離開，可能讓後續肇責、保險與醫療費變得很難處理。';
    }
    return '退租、搬家或點交時，很多人只想趕快完成流程；但牆面、家具、清潔與押金扣款若沒有記錄清楚，後續很容易變成糾紛。';
  }

  static String _exampleForTip(HomeNewsletterItem item) {
    if (item.category.contains('養狗') || item.title.contains('狗')) {
      return '情境範例：狗只是衝上前玩，對方卻被咬傷或跌倒，飼主可能需要負擔醫療費與其他損害。';
    }
    if (item.category.contains('拍照') ||
        item.category.contains('隱私') ||
        item.title.contains('自拍') ||
        item.title.contains('截圖')) {
      return '情境範例：你把聚餐照上傳限動，背景中的朋友、路人或私人物品清楚入鏡，對方認為隱私被公開。';
    }
    if (item.category.contains('網購') || item.title.contains('退貨')) {
      return '情境範例：拆封試用後才想退貨，賣家主張商品已影響完整性，雙方對七日鑑賞期認知不同。';
    }
    if (item.category.contains('交通') || item.title.contains('車禍')) {
      return '情境範例：小擦撞當下沒有拍照、沒有報警，後來對方改口要求賠償，證據卻很薄弱。';
    }
    return '情境範例：房東以清潔費、油漆費或家具損壞為由扣押金，但沒有提出明確照片、估價單或收據。';
  }

  static List<String> _riskBulletsForTip(HomeNewsletterItem item) {
    if (item.category.contains('養狗') || item.title.contains('狗')) {
      return const [
        '飼主可能要負擔動物造成他人受傷的損害賠償。',
        '是否有牽繩、嘴套、警示與即時處理，會影響責任判斷。',
        '醫療收據、現場照片與監視器畫面會成為關鍵證據。',
      ];
    }
    if (item.category.contains('拍照') ||
        item.category.contains('隱私') ||
        item.title.contains('自拍') ||
        item.title.contains('截圖')) {
      return const [
        '照片或截圖若讓他人可被辨識，可能涉及肖像權或隱私權。',
        '如果搭配嘲諷、商業用途或敏感資訊，風險會明顯升高。',
        '公開分享前是否取得同意，常是判斷正當性的重點。',
      ];
    }
    if (item.category.contains('網購') || item.title.contains('退貨')) {
      return const [
        '七日鑑賞期不是所有商品都無條件適用。',
        '商品完整性、拆封程度與保存狀態會影響退貨權利。',
        '聊天紀錄、訂單截圖、物流單據要保留到退款完成。',
      ];
    }
    if (item.category.contains('交通') || item.title.contains('車禍')) {
      return const [
        '沒有現場照片或報案資料，後續肇責容易各說各話。',
        '口頭和解如果沒有留下文字，可能引發第二次爭議。',
        '傷勢、修車與保險理賠都需要單據佐證。',
      ];
    }
    return const [
      '押金扣除需要具體理由，不能只用概括名目扣款。',
      '自然耗損與人為損壞要分開判斷。',
      '退租點交紀錄、照片與收據會直接影響後續協商。',
    ];
  }

  static List<String> _buildActionSteps(HomeNewsletterItem item) {
    if (item.category.contains('養狗') || item.title.contains('狗')) {
      return const [
        '確認是否有受傷，並前往醫院開立就醫診斷證明。',
        '保留現場照片、調閱監視器畫面，留存牽繩防護細節或飼主身分。',
        '如需和解或訴訟，請整理好醫療收據及其他財產損失單據。'
      ];
    }
    if (item.category.contains('拍照') ||
        item.category.contains('隱私') ||
        item.title.contains('自拍') ||
        item.title.contains('拍照')) {
      return const [
        '公開上傳照片或影片前，檢查背景是否有明顯可辨識的路人。',
        '避免將他人清晰的特寫、車牌號碼、或門牌住家當作照片主體。',
        '若用於商業營利、自媒體置入或醜化言論，務必取得當事人授權。'
      ];
    }
    if (item.category.contains('網購') || item.title.contains('退貨')) {
      return const [
        '先確認商品是否屬於通訊交易解除權例外。',
        '退貨前拍下商品狀態、外盒、配件與出貨明細。',
        '客服溝通盡量留下文字紀錄，並保存訂單與物流資料。'
      ];
    }
    if (item.category.contains('交通') || item.title.contains('車禍')) {
      return const [
        '先確認人身安全，必要時報警並通知保險公司。',
        '拍下車損、位置、號誌、煞車痕與雙方證件資料。',
        '和解內容用文字列清楚，包含金額、給付期限與是否拋棄其他請求。'
      ];
    }
    return const [
      '翻出契約，詳閱是否有提前終止條款、違約金規定或修繕義務分配。',
      '點交退租前，務必對房屋現狀進行拍照或錄影存證。',
      '若房東無故扣押金，請其出示折抵修繕項目的估價單或收據。'
    ];
  }

  static String _lawHintForTip(HomeNewsletterItem item) {
    if (item.category.contains('養狗') || item.title.contains('狗')) {
      return '法律提醒：民法對動物占有人責任有相關規範。重點不是「狗平常乖不乖」，而是事件發生時飼主是否已盡合理管理與防護義務。';
    }
    if (item.category.contains('拍照') ||
        item.category.contains('隱私') ||
        item.title.contains('自拍') ||
        item.title.contains('截圖')) {
      return '法律提醒：肖像、隱私與個資問題常和公開程度、可識別性、用途有關。越公開、越具商業或貶損效果，越需要先取得同意。';
    }
    if (item.category.contains('網購') || item.title.contains('退貨')) {
      return '法律提醒：消費者保護法的通訊交易解除權有例外，也會受商品性質與完整性影響。退貨前先保留商品狀態與溝通紀錄。';
    }
    if (item.category.contains('交通') || item.title.contains('車禍')) {
      return '法律提醒：交通事故的後續處理通常依現場證據、警方紀錄、醫療與修繕單據來判斷。不要只靠口頭承諾。';
    }
    return '法律提醒：租賃押金扣款通常要能說明扣款原因與金額依據。自然耗損、修繕責任與點交紀錄會是協商重點。';
  }
}

String _issueHintForTip(HomeNewsletterItem item) {
  // 台灣繁體中文教學註解：
  // 生活避坑筆記的核心不是「文章分類」，而是讓使用者看見小動作背後的法律風險。
  // 這裡先依既有 mock title/category 推導提示文字，未來可改由 API 直接回傳。
  if (item.category.contains('養狗') || item.title.contains('狗')) {
    return '可能涉及：動物占有人責任、醫療費、精神損害賠償';
  }
  if (item.category.contains('拍照') ||
      item.category.contains('隱私') ||
      item.title.contains('自拍') ||
      item.title.contains('截圖')) {
    return '可能涉及：肖像權、隱私權、個人資料使用';
  }
  if (item.category.contains('租') || item.title.contains('押金')) {
    return '可能涉及：押金返還、修繕責任、退租點交';
  }
  if (item.category.contains('網購') || item.title.contains('退貨')) {
    return '可能涉及：七日鑑賞期、退款期限、交易證明';
  }
  if (item.category.contains('交通') || item.title.contains('車禍')) {
    return '可能涉及：肇責判斷、和解書、保險理賠';
  }
  return '可能涉及：證據保存、通知方式、協商紀錄';
}

String _readTimeForTip(HomeNewsletterItem item) {
  if (item.category.contains('租')) return '4 分鐘';
  if (item.category.contains('交通')) return '5 分鐘';
  return '3 分鐘';
}

class _LifeTrapFrozenHeaderDelegate extends SliverPersistentHeaderDelegate {
  _LifeTrapFrozenHeaderDelegate({
    required this.topPadding,
    required this.isDark,
    required this.searchController,
    required this.labels,
    required this.selectedLabel,
    required this.isSearchOpen,
    required this.isSearchActive,
    required this.onBack,
    required this.onSearchToggle,
    required this.onSelected,
  });

  final double topPadding;
  final bool isDark;
  final TextEditingController searchController;
  final List<String> labels;
  final String selectedLabel;
  final bool isSearchOpen;
  final bool isSearchActive;
  final VoidCallback onBack;
  final VoidCallback onSearchToggle;
  final ValueChanged<String> onSelected;

  @override
  double get minExtent => maxExtent;

  @override
  double get maxExtent => (topPadding + (isSearchOpen ? 226.h : 148.h)).roundToDouble();


  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    // 台灣繁體中文教學註解：
    // 使用 pinned SliverPersistentHeader 模擬試算表「凍結窗格」：
    // 上方返回、標題、搜尋與分類永遠停在可視區，下面的筆記清單獨立滾動。
    final bg = isDark ? const Color(0xFF0F1216) : ProtoColors.lightBg;

    return Container(
      color: bg,
      padding: EdgeInsets.fromLTRB(16.w, topPadding + 8.h, 16.w, 12.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _LifeTrapAppBar(
            onBack: onBack,
            onSearchToggle: onSearchToggle,
            isSearchActive: isSearchOpen || isSearchActive,
          ),
          Padding(
            padding: EdgeInsets.only(left: 2.w, top: 2.h, bottom: 12.h),
            child: Text(
              '用生活場景看懂法律風險',
              style: TextStyle(
                fontSize: 12.5.sp,
                fontWeight: FontWeight.w700,
                color: isDark ? const Color(0xFF94A3B8) : AppColors.textMuted,
              ),
            ),
          ),
          if (isSearchOpen) ...[
            _LifeTrapSearchBar(controller: searchController),
            SizedBox(height: 14.h),
          ],
          _LifeTipCategoryRail(
            labels: labels,
            selectedLabel: selectedLabel,
            onSelected: onSelected,
          ),
        ],
      ),
    );
  }

  @override
  bool shouldRebuild(covariant _LifeTrapFrozenHeaderDelegate oldDelegate) {
    return oldDelegate.topPadding != topPadding ||
        oldDelegate.isDark != isDark ||
        oldDelegate.searchController != searchController ||
        oldDelegate.selectedLabel != selectedLabel ||
        oldDelegate.isSearchOpen != isSearchOpen ||
        oldDelegate.isSearchActive != isSearchActive ||
        oldDelegate.labels != labels;
  }
}

/// 頂部 AppBar
class _LifeTrapAppBar extends StatelessWidget {
  const _LifeTrapAppBar({
    required this.onBack,
    required this.onSearchToggle,
    required this.isSearchActive,
  });

  final VoidCallback onBack;
  final VoidCallback onSearchToggle;
  final bool isSearchActive;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return SizedBox(
      height: 42.h,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: SubpageTopBar(onBack: onBack),
          ),
          Text(
            '生活避坑筆記',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 17.sp,
              fontWeight: FontWeight.w900,
              color: isDark ? Colors.white : ProtoColors.charcoal,
            ),
          ),
          Align(
            alignment: Alignment.centerRight,
            child: IconButton(
              onPressed: onSearchToggle,
              icon: Icon(
                isSearchActive ? Icons.close_rounded : Icons.search_rounded,
                color: isDark ? Colors.white : ProtoColors.charcoal,
                size: 22.sp,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// 搜尋框 (帶聚焦光暈)
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
    _focusNode = FocusNode();
    _focusNode.addListener(() {
      setState(() {
        _isFocused = _focusNode.hasFocus;
      });
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = AppColors.primary;
    final secondaryColor =
        isDark ? const Color(0xFF64748B) : AppColors.textSecondary;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 2.h),
      decoration: BoxDecoration(
        color: _isFocused
            ? (isDark ? const Color(0xFF1E2228) : AppColors.surface)
            : (isDark ? const Color(0xFF1E2228) : AppColors.searchSurface),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: _isFocused ? primaryColor : Colors.transparent,
          width: 0.8.w,
        ),
      ),
      child: TextField(
        controller: widget.controller,
        focusNode: _focusNode,
        onTapOutside: (event) {
          _focusNode.unfocus();
        },
        textInputAction: TextInputAction.search,
        decoration: InputDecoration(
          hintText: '搜尋筆記標題或關鍵字',
          hintStyle: TextStyle(
            color: isDark ? const Color(0xFF64748B) : AppColors.textMuted,
            fontSize: 12.5.sp,
          ),
          border: InputBorder.none,
          icon: Icon(
            Icons.search_rounded,
            color: _isFocused ? primaryColor : secondaryColor,
            size: 20.sp,
          ),
          suffixIcon: widget.controller.text.isEmpty
              ? null
              : IconButton(
                  onPressed: widget.controller.clear,
                  icon: Icon(Icons.close_rounded,
                      size: 18.sp, color: secondaryColor),
                ),
        ),
        style: TextStyle(
          fontSize: 12.5.sp,
          fontWeight: FontWeight.w700,
          color: isDark ? Colors.white : AppColors.textSecondary,
        ),
      ),
    );
  }
}

class _SubpageInlineHeader extends StatelessWidget {
  const _SubpageInlineHeader({
    required this.title,
    required this.count,
  });

  final String title;
  final int count;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 15.sp,
              fontWeight: FontWeight.w900,
              color: isDark ? Colors.white : ProtoColors.charcoal,
            ),
          ),
        ),
        Text(
          '$count 則',
          style: TextStyle(
            fontSize: 10.5.sp,
            fontWeight: FontWeight.w800,
            color: isDark ? const Color(0xFF64748B) : AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}

/// 分類篩選藥丸軌道
class _LifeTipCategoryRail extends StatelessWidget {
  const _LifeTipCategoryRail({
    required this.labels,
    required this.selectedLabel,
    required this.onSelected,
  });

  final List<String> labels;
  final String selectedLabel;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SizedBox(
      height: 38.h,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        padding: EdgeInsets.symmetric(horizontal: 4.w),
        itemBuilder: (context, index) {
          final label = labels[index];
          final isSelected = label == selectedLabel;
          final aes = aestheticsForCategory(label, isDark);
          final pillBg = isSelected
              ? AppColors.primary
              : (isDark ? const Color(0xFF1E2228) : AppColors.chipSurface);
          final textCol = isSelected
              ? Colors.white
              : (isDark ? const Color(0xFF94A3B8) : AppColors.textSecondary);

          return AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () => onSelected(label),
                borderRadius: BorderRadius.circular(8.r),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding:
                      EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                  decoration: BoxDecoration(
                    color: pillBg,
                    borderRadius: BorderRadius.circular(8.r),
                    border: Border.all(
                      color:
                          isSelected ? AppColors.primary : Colors.transparent,
                      width: 1.w,
                    ),
                  ),
                  child: Center(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (isSelected && label != '全部') ...[
                          Icon(aes.icon, size: 13.sp, color: Colors.white),
                          SizedBox(width: 6.w),
                        ],
                        Text(
                          label,
                          style: TextStyle(
                            fontSize: 11.5.sp,
                            fontWeight: FontWeight.w900,
                            color: textCol,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
        separatorBuilder: (_, __) => SizedBox(width: 8.w),
        itemCount: labels.length,
      ),
    );
  }
}

/// 輪播專用精簡大卡片 (平面設計)
class _LifeTipFeaturedCard extends StatelessWidget {
  const _LifeTipFeaturedCard({
    required this.item,
    required this.onTap,
  });

  final HomeNewsletterItem item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final aes = aestheticsForCategory(item.category, isDark);
    final imageAsset = _imageForCategory(item.category);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12.r),
        child: Ink(
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF181C23) : const Color(0xFFFFFAF2),
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(
              color: isDark ? const Color(0xFF2D333F) : const Color(0xFFEFE3D0),
              width: 1.w,
            ),
          ),
          child: Padding(
            padding: EdgeInsets.all(12.w),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '今天最常見：寵物責任',
                        style: TextStyle(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w900,
                          color: const Color(0xFFC9877B),
                          letterSpacing: 0,
                        ),
                      ),
                      SizedBox(height: 6.h),
                      Text(
                        item.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: isDark ? Colors.white : ProtoColors.charcoal,
                          fontSize: 15.sp,
                          fontWeight: FontWeight.w900,
                          height: 1.3,
                          letterSpacing: 0,
                        ),
                      ),
                      SizedBox(height: 6.h),
                      Text(
                        '一個日常小動作，可能牽涉責任歸屬、證據保存與協商方式。',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: isDark
                              ? const Color(0xFF94A3B8)
                              : AppColors.textSecondary,
                          fontSize: 11.5.sp,
                          height: 1.45,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      SizedBox(height: 10.h),
                      Row(
                        children: [
                          _StoryChip(label: item.category, color: aes.primary),
                          SizedBox(width: 6.w),
                          _StoryChip(
                              label: '民法', color: const Color(0xFF426E9F)),
                          SizedBox(width: 6.w),
                          _StoryChip(
                              label: '4 分鐘', color: const Color(0xFF8A7B5C)),
                        ],
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 12.w),
                ClipRRect(
                  borderRadius: BorderRadius.circular(10.r),
                  child: Image.asset(
                    imageAsset,
                    width: 86.w,
                    height: 86.w,
                    fit: BoxFit.cover,
                  ),
                ),
                SizedBox(width: 6.w),
                Icon(
                  Icons.chevron_right_rounded,
                  size: 20.sp,
                  color: isDark ? const Color(0xFF64748B) : AppColors.textMuted,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _StoryChip extends StatelessWidget {
  const _StoryChip({
    required this.label,
    required this.color,
  });

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(999.r),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 10.sp,
          fontWeight: FontWeight.w900,
          color: color,
          letterSpacing: 0,
        ),
      ),
    );
  }
}

class _LifeTipInteractionMetric extends StatelessWidget {
  const _LifeTipInteractionMetric({
    required this.svgPath,
    required this.color,
    required this.label,
    required this.onTap,
  });

  final String svgPath;
  final Color color;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Expanded(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(10.r),
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 6.h),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CtmSvgIcon(svgPath, color: color, size: 18.sp),
                SizedBox(width: 5.w),
                Flexible(
                  child: Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: isDark
                          ? const Color(0xFF94A3B8)
                          : AppColors.textSecondary,
                      fontSize: 12.5.sp,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0,
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

class _LifeTipCommentSheet extends StatefulWidget {
  const _LifeTipCommentSheet({
    required this.title,
    required this.onCommentPosted,
  });

  final String title;
  final VoidCallback onCommentPosted;

  @override
  State<_LifeTipCommentSheet> createState() => _LifeTipCommentSheetState();
}

class _LifeTipCommentSheetState extends State<_LifeTipCommentSheet> {
  final _controller = TextEditingController();
  final _comments = <String>[
    '這篇很實用，原來只是日常小動作也要先留紀錄。',
    '我會先收藏，退租或拍照前拿出來確認。',
  ];

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    HapticFeedback.mediumImpact();
    setState(() {
      _comments.insert(0, text);
      _controller.clear();
    });
    widget.onCommentPosted();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    final bg = isDark ? const Color(0xFF181C23) : Colors.white;
    final text = isDark ? Colors.white : ProtoColors.charcoal;
    final muted = isDark ? const Color(0xFF94A3B8) : AppColors.textSecondary;

    return Padding(
      padding: EdgeInsets.only(bottom: bottomInset),
      child: Container(
        padding: EdgeInsets.fromLTRB(18.w, 12.h, 18.w, 18.h),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 42.w,
                height: 4.h,
                decoration: BoxDecoration(
                  color: isDark
                      ? const Color(0xFF2D333F)
                      : const Color(0xFFE8DFD1),
                  borderRadius: BorderRadius.circular(999.r),
                ),
              ),
            ),
            SizedBox(height: 14.h),
            Text(
              '避坑留言',
              style: TextStyle(
                color: text,
                fontSize: 16.sp,
                fontWeight: FontWeight.w900,
              ),
            ),
            SizedBox(height: 4.h),
            Text(
              widget.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: muted,
                fontSize: 11.5.sp,
                fontWeight: FontWeight.w700,
              ),
            ),
            SizedBox(height: 14.h),
            ConstrainedBox(
              constraints: BoxConstraints(maxHeight: 190.h),
              child: ListView.separated(
                shrinkWrap: true,
                itemCount: _comments.length,
                separatorBuilder: (_, __) => SizedBox(height: 8.h),
                itemBuilder: (context, index) {
                  return Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
                    decoration: BoxDecoration(
                      color: isDark
                          ? const Color(0xFF1E2228)
                          : const Color(0xFFFAF8F5),
                      borderRadius: BorderRadius.circular(10.r),
                      border: Border.all(
                        color: isDark
                            ? const Color(0xFF2D333F)
                            : const Color(0xFFE8DFD1),
                        width: 0.8.w,
                      ),
                    ),
                    child: Text(
                      _comments[index],
                      style: TextStyle(
                        color: text,
                        fontSize: 12.5.sp,
                        height: 1.45,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  );
                },
              ),
            ),
            SizedBox(height: 14.h),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    minLines: 1,
                    maxLines: 3,
                    style: TextStyle(color: text, fontSize: 12.5.sp),
                    decoration: InputDecoration(
                      hintText: '寫下你的避坑心得...',
                      hintStyle: TextStyle(color: muted, fontSize: 12.5.sp),
                      filled: true,
                      fillColor: isDark
                          ? const Color(0xFF1E2228)
                          : const Color(0xFFFAF8F5),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.r),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 12.w,
                        vertical: 10.h,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 10.w),
                GestureDetector(
                  onTap: _submit,
                  child: Container(
                    width: 42.w,
                    height: 42.w,
                    decoration: const BoxDecoration(
                      color: ProtoColors.deepGreen,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.arrow_upward_rounded,
                      color: Colors.white,
                      size: 20.sp,
                    ),
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

class _RentTimelineGuideCard extends StatelessWidget {
  const _RentTimelineGuideCard();

  static const _steps = [
    ('拍照留證', '退租前 7 天，拍下牆面、地板、家具與全室狀態'),
    ('確認修繕', '整理哪些是自然耗損，哪些可能需要修復'),
    ('押金返還', '點交時同步確認扣款理由、金額與收據'),
    ('爭議處理', '如果協商卡住，保留對話紀錄與點交單'),
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF181C23) : Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: isDark ? const Color(0xFF2D333F) : const Color(0xFFE7DED0),
          width: 1.w,
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '退租前 7 天檢查表',
                  style: TextStyle(
                    fontSize: 17.sp,
                    fontWeight: FontWeight.w900,
                    color: isDark ? Colors.white : ProtoColors.charcoal,
                    letterSpacing: 0,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  '一步步留證，保護你的押金',
                  style: TextStyle(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w700,
                    color:
                        isDark ? const Color(0xFF94A3B8) : AppColors.textMuted,
                  ),
                ),
                SizedBox(height: 14.h),
                ...List.generate(_steps.length, (index) {
                  final step = _steps[index];
                  final isLast = index == _steps.length - 1;
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Column(
                        children: [
                          Container(
                            width: 22.w,
                            height: 22.w,
                            decoration: const BoxDecoration(
                              color: Color(0xFF2C5E43),
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: Text(
                                '${index + 1}',
                                style: TextStyle(
                                  fontSize: 10.sp,
                                  fontWeight: FontWeight.w900,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                          if (!isLast)
                            Container(
                              width: 1.2.w,
                              height: 26.h,
                              color: const Color(0xFF2C5E43)
                                  .withValues(alpha: 0.28),
                            ),
                        ],
                      ),
                      SizedBox(width: 10.w),
                      Expanded(
                        child: Padding(
                          padding: EdgeInsets.only(bottom: isLast ? 0 : 12.h),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                step.$1,
                                style: TextStyle(
                                  fontSize: 13.sp,
                                  fontWeight: FontWeight.w900,
                                  color: isDark
                                      ? Colors.white
                                      : ProtoColors.charcoal,
                                ),
                              ),
                              SizedBox(height: 2.h),
                              Text(
                                step.$2,
                                style: TextStyle(
                                  fontSize: 11.5.sp,
                                  height: 1.35,
                                  color: isDark
                                      ? const Color(0xFF94A3B8)
                                      : AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  );
                }),
              ],
            ),
          ),
          SizedBox(width: 10.w),
          ClipRRect(
            borderRadius: BorderRadius.circular(10.r),
            child: Image.asset(
              'assets/images/learning/rent_course_room.png',
              width: 88.w,
              height: 108.h,
              fit: BoxFit.cover,
            ),
          ),
        ],
      ),
    );
  }
}

/// 列表專用精美大卡片 (左側文字與右側縮圖平面設計)
class _LifeTipListCard extends StatefulWidget {
  const _LifeTipListCard({
    required this.item,
    this.onTap,
  });

  final HomeNewsletterItem item;
  final VoidCallback? onTap;

  @override
  State<_LifeTipListCard> createState() => _LifeTipListCardState();
}

class _LifeTipListCardState extends State<_LifeTipListCard> {
  @override
  Widget build(BuildContext context) {
    final item = widget.item;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final aes = aestheticsForCategory(item.category, isDark);
    final imageAsset = _imageForCategory(item.category);
    final issue = _issueHintForTip(item);

    return Material(
      color: Colors.transparent,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12.r),
        child: Container(
          decoration: BoxDecoration(
            color: isDark
                ? Color.alphaBlend(
                    aes.primary.withValues(alpha: 0.03),
                    const Color(0xFF1E2228),
                  )
                : Colors.white,
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(
              color: isDark ? const Color(0xFF2D333F) : const Color(0xFFE8DFD1),
              width: 0.8.w,
            ),
          ),
          child: InkWell(
            onTap: widget.onTap,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 左側資訊
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          item.title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 13.5.sp,
                            fontWeight: FontWeight.w900,
                            color: isDark ? Colors.white : ProtoColors.charcoal,
                            height: 1.35,
                            letterSpacing: 0,
                          ),
                        ),
                        SizedBox(height: 6.h),
                        Text(
                          issue,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 11.5.sp,
                            height: 1.4,
                            fontWeight: FontWeight.w700,
                            color: isDark
                                ? const Color(0xFF94A3B8)
                                : AppColors.textSecondary,
                          ),
                        ),
                        SizedBox(height: 10.h),
                        Row(
                          children: [
                            _StoryChip(
                                label: item.category, color: aes.primary),
                            SizedBox(width: 6.w),
                            _StoryChip(
                              label: _readTimeForTip(item),
                              color: const Color(0xFF8A7B5C),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: 12.w),
                  // 右側：縮圖 (由 category 顯示對應圖片，有剪裁)
                  Container(
                    width: 80.w,
                    height: 80.w,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8.r),
                      border: Border.all(
                        color: aes.primary.withValues(alpha: 0.2),
                        width: 0.8.w,
                      ),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8.r),
                      child: Image.asset(
                        imageAsset,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// 自定義的圓形進度環 (Apple Watch 風格)
class CircularProgressRing extends StatelessWidget {
  const CircularProgressRing({
    super.key,
    required this.progress,
    this.size = 56.0,
    required this.accentColor,
  });

  final double progress;
  final double size;
  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final trackColor = isDark
        ? Colors.white.withValues(alpha: 0.08)
        : Colors.black.withValues(alpha: 0.05);
    final List<Color> ringGradient = [
      accentColor.withValues(alpha: 0.6),
      accentColor,
      accentColor.withValues(alpha: 0.9),
    ];

    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: ProgressRingPainter(
          progress: progress,
          trackColor: trackColor,
          ringGradient: ringGradient,
        ),
        child: Center(
          child: Text(
            '${(progress * 100).toInt()}%',
            style: TextStyle(
              fontSize: 11.sp,
              fontWeight: FontWeight.w900,
              color: accentColor,
            ),
          ),
        ),
      ),
    );
  }
}

class ProgressRingPainter extends CustomPainter {
  final double progress;
  final Color trackColor;
  final List<Color> ringGradient;

  ProgressRingPainter({
    required this.progress,
    required this.trackColor,
    required this.ringGradient,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - 6.w) / 2;

    final trackPaint = Paint()
      ..color = trackColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5.w;
    canvas.drawCircle(center, radius, trackPaint);

    if (progress > 0) {
      final rect = Rect.fromCircle(center: center, radius: radius);
      final ringPaint = Paint()
        ..shader = SweepGradient(
          colors: ringGradient,
          startAngle: -3.14159 / 2,
          endAngle: 3 * 3.14159 / 2,
        ).createShader(rect)
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeWidth = 5.w;

      canvas.drawArc(
          rect, -3.14159 / 2, progress * 2 * 3.14159, false, ringPaint);
    }
  }

  @override
  bool shouldRepaint(covariant ProgressRingPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
