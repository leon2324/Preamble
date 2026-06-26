import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lawapp/features/on_this_day/data/on_this_day_local_bookmarks.dart';
import 'package:lawapp/features/on_this_day/data/on_this_day_mock_data.dart';
import 'package:lawapp/features/on_this_day/models/on_this_day_models.dart';
import 'package:lawapp/features/on_this_day/theme/on_this_day_theme.dart';
import 'package:lawapp/features/case_time_machine/data/case_time_machine_repository.dart';
import 'package:lawapp/features/case_time_machine/pages/case_dossier_detail_page.dart';
import 'package:lawapp/features/case_time_machine/models/case_time_machine_models.dart';

class OnThisDayDetailPage extends StatefulWidget {
  const OnThisDayDetailPage({super.key, required this.caseId});

  final String caseId;

  @override
  State<OnThisDayDetailPage> createState() => _OnThisDayDetailPageState();
}

class _OnThisDayDetailPageState extends State<OnThisDayDetailPage> {
  int _activeTab = 0; // 0: 案件簡略, 1: 時間線, 2: 歷史照片, 3: 時代背景, 4: 延伸影響, 5: 資料來源
  late OnThisDayCase _case;
  late List<String> _tabs;

  late PageController _mediaController;
  int _mediaIndex = 0;
  bool _isBookmarked = false;

  @override
  void initState() {
    super.initState();
    _case = onThisDayCaseById(widget.caseId) ?? onThisDayCases.first;
    _tabs = ['案件簡略', '時間線', '歷史照片', '時代背景', '延伸影響', '資料來源'];
    _mediaController = PageController();
    _initRepository();
    _loadBookmarkState();
  }

  Future<void> _initRepository() async {
    final repo = CaseTimeMachineRepository.instance;
    if (repo.cases.isEmpty) {
      await repo.initialize();
      if (mounted) {
        setState(() {});
      }
    }
  }

  Future<void> _loadBookmarkState() async {
    final isSaved = await OnThisDayLocalBookmarks.isSaved(_case.id);
    if (!mounted) return;
    setState(() => _isBookmarked = isSaved);
  }

  CaseBook? _findDossierSync(OnThisDayCase mainCase) {
    final cases = CaseTimeMachineRepository.instance.cases;
    for (final book in cases) {
      if (book.id == mainCase.id ||
          book.titleZh.contains(mainCase.title) ||
          mainCase.title.contains(book.titleZh) ||
          (book.shortTitleZh.isNotEmpty &&
              (book.shortTitleZh.contains(mainCase.title) ||
                  mainCase.title.contains(book.shortTitleZh)))) {
        return book;
      }
    }
    return null;
  }

  @override
  void didUpdateWidget(covariant OnThisDayDetailPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.caseId != widget.caseId) {
      setState(() {
        _case = onThisDayCaseById(widget.caseId) ?? onThisDayCases.first;
        _mediaIndex = 0;
        _mediaController.jumpToPage(0);
      });
      _loadBookmarkState();
    }
  }

  @override
  void dispose() {
    _mediaController.dispose();
    super.dispose();
  }

  void _openRelatedCase(String title) {
    try {
      final matched = onThisDayCases.firstWhere((c) => c.title == title);
      Navigator.of(context).push(
        CupertinoPageRoute<void>(
          builder: (__) => OnThisDayDetailPage(caseId: matched.id),
        ),
      );
    } catch (__) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('相關案卷「$title」暫無細節資料')),
      );
    }
  }

  Future<void> _toggleBookmark() async {
    final isSaved = await OnThisDayLocalBookmarks.toggle(_case.id);
    if (!mounted) return;
    setState(() => _isBookmarked = isSaved);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(isSaved ? '已加入本機收藏。' : '已從本機收藏移除。'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: OnThisDayColors.paperBeige,
      body: SafeArea(
        child: Column(
          children: [
            // Top App Bar
            Padding(
              padding: EdgeInsets.fromLTRB(6.w, 4.h, 18.w, 2.h),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios_new_rounded,
                        color: OnThisDayColors.primaryGreen),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _case.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style:
                              OnThisDayTextStyles.titleSerif(context).copyWith(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        SizedBox(height: 1.h),
                        Text(
                          '${_case.year} 年 · ${_case.category}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: OnThisDayTextStyles.caption(context)
                              .copyWith(fontSize: 10.sp),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      _isBookmarked
                          ? Icons.bookmark_rounded
                          : Icons.bookmark_border_rounded,
                      color: OnThisDayColors.accentGold,
                    ),
                    onPressed: _toggleBookmark,
                  ),
                ],
              ),
            ),

            Expanded(
              child: ListView(
                physics: const BouncingScrollPhysics(),
                padding: EdgeInsets.zero,
                children: [
                  // 1. Swipable historical media photos
                  _buildMediaCarousel(),
                  SizedBox(height: 12.h),

                  // 2. Pill Tabs Selector
                  _buildTabBar(),
                  SizedBox(height: 16.h),

                  // 3. Tab contents
                  LayoutBuilder(
                    builder: (context, constraints) {
                      // Calculate a minimum height so that the page height is guaranteed to be large enough to scroll properly if needed,
                      // or just to provide a clean, spacious Morandi/beige background flow without clipping.
                      // Screen height minus media carousel (160.h), tab bar (40.h), spacing, appbar, bottom action bar, etc.
                      final screenHeight = MediaQuery.of(context).size.height;
                      final minHeight = screenHeight - 160.h - 40.h - 150.h;
                      return ConstrainedBox(
                        constraints: BoxConstraints(
                          minHeight: minHeight > 200 ? minHeight : 200,
                        ),
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: 18.w),
                          child: _buildActiveTabContent(),
                        ),
                      );
                    },
                  ),
                  SizedBox(height: 32.h),
                ],
              ),
            ),

            // Sticky Bottom CTA Redirection
            _buildBottomActionBar(),
          ],
        ),
      ),
    );
  }

  Widget _buildMediaCarousel() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 18.w),
      height: 160.h,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16.r),
        child: Stack(
          fit: StackFit.expand,
          children: [
            PageView.builder(
              controller: _mediaController,
              itemCount: _case.photos.length,
              onPageChanged: (index) {
                setState(() {
                  _mediaIndex = index;
                });
              },
              itemBuilder: (context, index) {
                final photo = _case.photos[index];
                return Stack(
                  fit: StackFit.expand,
                  children: [
                    // Styled Abstract Vintage Graphic Box instead of local image files
                    Container(
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Color(0xFF2C3E50), Color(0xFF1E2A38)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                      child: Center(
                        child: Opacity(
                          opacity: 0.12,
                          child: Icon(
                            Icons.history_edu_rounded,
                            size: 100.sp,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      left: 14.w,
                      bottom: 14.h,
                      right: 14.w,
                      child: Text(
                        photo.caption,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 10.sp,
                          fontWeight: FontWeight.w700,
                          color: OnThisDayColors.bgPaperLight,
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
            // Indicator
            Positioned(
              right: 14.w,
              top: 14.h,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.6),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Text(
                  '${_mediaIndex + 1}/${_case.photos.length}',
                  style: TextStyle(
                    fontSize: 9.sp,
                    fontWeight: FontWeight.w900,
                    color: OnThisDayColors.bgPaperLight,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabBar() {
    return SizedBox(
      height: 40.h,
      child: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 18.w),
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        child: Row(
          children: List.generate(_tabs.length, (index) {
            final isSelected = index == _activeTab;
            return Padding(
              padding:
                  EdgeInsets.only(right: index == _tabs.length - 1 ? 0 : 8.w),
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    _activeTab = index;
                  });
                },
                child: Container(
                  padding:
                      EdgeInsets.symmetric(horizontal: 16.w, vertical: 6.h),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: isSelected
                        ? OnThisDayColors.primaryGreen
                        : OnThisDayColors.bgCream.withValues(alpha: 0.25),
                    borderRadius: BorderRadius.circular(18.r),
                    border: Border.all(
                      color: isSelected
                          ? OnThisDayColors.primaryGreen
                          : OnThisDayColors.borderLight,
                    ),
                  ),
                  child: Text(
                    _tabs[index],
                    style: TextStyle(
                      fontSize: 12.sp,
                      fontWeight:
                          isSelected ? FontWeight.w900 : FontWeight.w700,
                      color: isSelected
                          ? OnThisDayColors.bgPaperLight
                          : OnThisDayColors.textSecondary,
                    ),
                  ),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }

  Widget _buildContentCard({
    required Widget child,
    Color accentColor = OnThisDayColors.accentGold,
    EdgeInsetsGeometry? padding,
  }) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: OnThisDayColors.bgPaperLight,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: OnThisDayColors.borderLight),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
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
              Container(width: 4.w, color: accentColor),
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

  Widget _buildActiveTabContent() {
    switch (_activeTab) {
      case 0:
        return _buildIntroTab();
      case 1:
        return _buildTimelineTab();
      case 2:
        return _buildPhotosTab();
      case 3:
        return _buildBackgroundTab();
      case 4:
        return _buildImpactTab();
      case 5:
        return _buildSourcesTab();
      default:
        return const SizedBox.shrink();
    }
  }

  // Tab 0: 案件簡略
  Widget _buildIntroTab() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('事件簡介',
            style: OnThisDayTextStyles.cardTitle(context)
                .copyWith(fontSize: 14.sp)),
        SizedBox(height: 8.h),
        _buildContentCard(
          accentColor: OnThisDayColors.primaryGreen,
          child:
              Text(_case.background, style: OnThisDayTextStyles.body(context)),
        ),
        SizedBox(height: 20.h),
        Text('要旨速覽',
            style: OnThisDayTextStyles.cardTitle(context)
                .copyWith(fontSize: 14.sp)),
        SizedBox(height: 8.h),
        _buildContentCard(
          accentColor: OnThisDayColors.accentGold,
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
          child: Column(
            children: [
              _buildFactRow('發生日期', _case.fullDateLabel),
              const Divider(color: OnThisDayColors.borderLight),
              _buildFactRow('事件地點', _case.location),
              const Divider(color: OnThisDayColors.borderLight),
              _buildFactRow('要旨分類', _case.category),
              const Divider(color: OnThisDayColors.borderLight),
              _buildFactRow('關聯標籤', _case.tags.join('、')),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFactRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80.w,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 11.5.sp,
                fontWeight: FontWeight.w800,
                color: OnThisDayColors.textMuted,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 11.5.sp,
                fontWeight: FontWeight.w700,
                color: OnThisDayColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Tab 1: 時間線
  Widget _buildTimelineTab() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('事件發展脈絡',
            style: OnThisDayTextStyles.cardTitle(context)
                .copyWith(fontSize: 14.sp)),
        SizedBox(height: 12.h),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _case.timeline.length,
          itemBuilder: (context, index) {
            final node = _case.timeline[index];
            final isLast = index == _case.timeline.length - 1;
            return IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 72.w,
                    child: Padding(
                      padding: EdgeInsets.only(top: 2.h),
                      child: Text(
                        node.dateLabel,
                        style: TextStyle(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w900,
                          color: OnThisDayColors.accentGold,
                        ),
                      ),
                    ),
                  ),
                  Column(
                    children: [
                      Container(
                        width: 10.w,
                        height: 10.w,
                        decoration: const BoxDecoration(
                          color: OnThisDayColors.primaryGreen,
                          shape: BoxShape.circle,
                        ),
                      ),
                      if (!isLast)
                        Expanded(
                          child: Container(
                            width: 1.5.w,
                            color: OnThisDayColors.borderLight,
                          ),
                        ),
                    ],
                  ),
                  SizedBox(width: 14.w),
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(bottom: 20.h),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            node.title,
                            style: OnThisDayTextStyles.cardTitle(context)
                                .copyWith(fontSize: 13.sp),
                          ),
                          SizedBox(height: 4.h),
                          Text(
                            node.description,
                            style: OnThisDayTextStyles.body(context).copyWith(
                              fontSize: 11.sp,
                              color: OnThisDayColors.textSecondary,
                            ),
                          ),
                        ],
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

  // Tab 2: 歷史照片
  Widget _buildPhotosTab() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('現場與歷史見證',
            style: OnThisDayTextStyles.cardTitle(context)
                .copyWith(fontSize: 14.sp)),
        SizedBox(height: 12.h),
        Wrap(
          spacing: 12.w,
          runSpacing: 12.h,
          children: [
            for (final photo in _case.photos)
              SizedBox(
                width: 163
                    .w, // Half-width container for two columns on typical 375.w design size
                child: Container(
                  decoration: BoxDecoration(
                    color: OnThisDayColors.bgPaperLight,
                    borderRadius: BorderRadius.circular(12.r),
                    border: Border.all(color: OnThisDayColors.borderLight),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Vintage styled photo placeholder container
                      Container(
                        height: 95.h,
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Color(0xFF4A3E3D), Color(0xFF2C2424)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius:
                              BorderRadius.vertical(top: Radius.circular(12)),
                        ),
                        child: Center(
                          child: Opacity(
                            opacity: 0.15,
                            child: Icon(
                              Icons.image_outlined,
                              size: 24.sp,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.all(8.w),
                        child: Text(
                          photo.caption,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 10.sp,
                            fontWeight: FontWeight.w800,
                            color: OnThisDayColors.textPrimary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }

  // Tab 3: 時代背景
  Widget _buildBackgroundTab() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('時代背景脈絡',
            style: OnThisDayTextStyles.cardTitle(context)
                .copyWith(fontSize: 14.sp)),
        SizedBox(height: 8.h),
        _buildContentCard(
          accentColor: OnThisDayColors.secondaryGreen,
          child: Text(_case.backgroundDetails,
              style: OnThisDayTextStyles.body(context)),
        ),
      ],
    );
  }

  // Tab 4: 延伸影響
  Widget _buildImpactTab() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('社會影響效應',
            style: OnThisDayTextStyles.cardTitle(context)
                .copyWith(fontSize: 14.sp)),
        SizedBox(height: 8.h),
        _buildContentCard(
          accentColor: const Color(0xFFD35400),
          child: Text(_case.socialImpact,
              style: OnThisDayTextStyles.body(context)),
        ),
        SizedBox(height: 20.h),
        Text('相關延伸案件',
            style: OnThisDayTextStyles.cardTitle(context)
                .copyWith(fontSize: 14.sp)),
        SizedBox(height: 8.h),
        Wrap(
          spacing: 8.w,
          runSpacing: 8.h,
          children: [
            for (final title in _case.relatedCaseTitles)
              GestureDetector(
                onTap: () => _openRelatedCase(title),
                child: Container(
                  padding:
                      EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                  decoration: BoxDecoration(
                    color: OnThisDayColors.paperBeige.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(16.r),
                    border: Border.all(color: OnThisDayColors.borderLight),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 11.sp,
                          fontWeight: FontWeight.w800,
                          color: OnThisDayColors.primaryGreen,
                        ),
                      ),
                      SizedBox(width: 4.w),
                      Icon(Icons.arrow_forward_ios_rounded,
                          size: 8.sp, color: OnThisDayColors.primaryGreen),
                    ],
                  ),
                ),
              ),
          ],
        ),
        SizedBox(height: 20.h),
        Text('延伸閱讀與資料庫',
            style: OnThisDayTextStyles.cardTitle(context)
                .copyWith(fontSize: 14.sp)),
        SizedBox(height: 8.h),
        Column(
          children: [
            for (final reading in _case.relatedReadings)
              Container(
                margin: EdgeInsets.only(bottom: 8.h),
                decoration: BoxDecoration(
                  color: OnThisDayColors.bgPaperLight,
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(color: OnThisDayColors.borderLight),
                ),
                child: ListTile(
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
                  leading: CircleAvatar(
                    backgroundColor:
                        OnThisDayColors.accentGold.withValues(alpha: 0.1),
                    child: const Icon(Icons.link_rounded,
                        color: OnThisDayColors.accentGold),
                  ),
                  title: Text(
                    reading.title,
                    style: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w800,
                      color: OnThisDayColors.textPrimary,
                    ),
                  ),
                  trailing: Icon(
                    Icons.open_in_new_rounded,
                    size: 16.sp,
                    color: OnThisDayColors.accentGold,
                  ),
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('前往外部網頁：${reading.url}')),
                    );
                  },
                ),
              ),
          ],
        ),
      ],
    );
  }

  // Tab 5: 資料來源
  Widget _buildSourcesTab() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('資料來源與修訂',
            style: OnThisDayTextStyles.cardTitle(context)
                .copyWith(fontSize: 14.sp)),
        SizedBox(height: 8.h),
        _buildContentCard(
          accentColor: OnThisDayColors.textMuted,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (final source in _case.sources) ...[
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 4.h),
                  child: Row(
                    children: [
                      const Icon(Icons.import_contacts_rounded,
                          color: OnThisDayColors.accentGold, size: 16),
                      SizedBox(width: 8.w),
                      Expanded(
                        child: Text(
                          source.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 11.5.sp,
                            fontWeight: FontWeight.w700,
                            color: OnThisDayColors.textPrimary,
                          ),
                        ),
                      ),
                      SizedBox(width: 8.w),
                      Text(
                        source.updatedAt,
                        style: OnThisDayTextStyles.caption(context)
                            .copyWith(fontSize: 10.sp),
                      ),
                    ],
                  ),
                ),
                const Divider(color: OnThisDayColors.borderLight),
              ],
              SizedBox(height: 8.h),
              Text(
                '免責聲明：\n本單元內容皆取材自官方文獻檔案與學術歷史記錄進行客觀編寫，旨在提供正當法治歷史與人權教育參考。不代表任何現存主觀政治立場。',
                style: OnThisDayTextStyles.caption(context)
                    .copyWith(height: 1.4, fontSize: 9.5.sp),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBottomActionBar() {
    final matchedBook = _findDossierSync(_case);
    final hasDossier = matchedBook != null;

    return Container(
      padding: EdgeInsets.fromLTRB(16.w, 10.h, 16.w, 20.h),
      decoration: BoxDecoration(
        color: OnThisDayColors.paperBeige,
        border:
            const Border(top: BorderSide(color: OnThisDayColors.borderLight)),
      ),
      child: SizedBox(
        width: double.infinity,
        height: 44.h,
        child: TextButton(
          style: TextButton.styleFrom(
            backgroundColor: OnThisDayColors.primaryGreen,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(22.r),
            ),
          ),
          onPressed: () {
            if (hasDossier) {
              Navigator.of(context).push(
                CupertinoPageRoute<void>(
                  builder: (__) => CaseDossierDetailPage(book: matchedBook),
                ),
              );
            } else {
              // Pop back to OnThisDayHomePage (or list page)
              Navigator.of(context).popUntil((route) => route.isFirst);
            }
          },
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                hasDossier ? '調閱法治卷宗' : '查看更多歷史案件',
                style: TextStyle(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w900,
                  color: OnThisDayColors.bgPaperLight,
                ),
              ),
              SizedBox(width: 6.w),
              Icon(Icons.arrow_forward_rounded,
                  size: 14.sp, color: OnThisDayColors.bgPaperLight),
            ],
          ),
        ),
      ),
    );
  }
}
