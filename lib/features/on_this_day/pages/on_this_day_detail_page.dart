import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:preamble/components/shared/custom_toast.dart';
import 'package:preamble/features/case_library/data/case_library_repository.dart';
import 'package:preamble/features/case_library/models/case_library_models.dart';
import 'package:preamble/features/case_library/pages/case_dossier_detail_page.dart';
import 'package:preamble/features/on_this_day/data/on_this_day_local_bookmarks.dart';
import 'package:preamble/features/on_this_day/data/on_this_day_mock_data.dart';
import 'package:preamble/features/on_this_day/models/on_this_day_models.dart';
import 'package:preamble/theme/preamble_tokens.dart';

class OnThisDayDetailPage extends StatefulWidget {
  const OnThisDayDetailPage({super.key, required this.caseId});

  final String caseId;

  @override
  State<OnThisDayDetailPage> createState() => _OnThisDayDetailPageState();
}

class _OnThisDayDetailPageState extends State<OnThisDayDetailPage> {
  static const List<String> _tabs = [
    '案件簡略',
    '時間線',
    '時代背景',
    '延伸影響',
    '資料來源',
  ];

  int _activeTab = 0;
  late OnThisDayCase _case;
  bool _isBookmarked = false;

  @override
  void initState() {
    super.initState();
    _case = onThisDayCaseById(widget.caseId) ?? onThisDayCases.first;
    _initRepository();
    _loadBookmarkState();
  }

  Future<void> _initRepository() async {
    final repo = CaseLibraryRepository.instance;
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
    final cases = CaseLibraryRepository.instance.cases;
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
        _activeTab = 0;
      });
      _loadBookmarkState();
    }
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
      CustomToast.show(context, '相關案卷「$title」暫無細節資料');
    }
  }

  Future<void> _toggleBookmark() async {
    final isSaved = await OnThisDayLocalBookmarks.toggle(_case.id);
    if (!mounted) return;
    setState(() => _isBookmarked = isSaved);
    CustomToast.show(context, isSaved ? '已加入本機收藏。' : '已從本機收藏移除。');
  }

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;

    return Scaffold(
      backgroundColor: t.canvas,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(6.w, 4.h, 12.w, 4.h),
              child: Row(
                children: [
                  IconButton(
                    icon: Icon(
                      PhosphorIconsRegular.caretLeft,
                      color: t.textPrimary,
                      size: 20.sp,
                    ),
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
                          style: t.serifTitle(
                            size: 16.5.sp,
                            weight: FontWeight.w800,
                          ),
                        ),
                        SizedBox(height: 1.h),
                        Text(
                          '${_case.year} 年 · ${_case.category} · ${_case.location}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: t.sansBody(
                            size: 11.sp,
                            color: t.textMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      _isBookmarked
                          ? PhosphorIconsFill.bookmarkSimple
                          : PhosphorIconsRegular.bookmarkSimple,
                      color: _isBookmarked ? t.accentBrass : t.textSecondary,
                      size: 20.sp,
                    ),
                    onPressed: _toggleBookmark,
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                physics: const BouncingScrollPhysics(),
                padding: EdgeInsets.only(bottom: 28.h),
                children: [
                  _buildEditorialHeroCard(t),
                  SizedBox(height: 14.h),
                  _buildTabBar(t),
                  SizedBox(height: 16.h),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 18.w),
                    child: _buildActiveTabContent(t),
                  ),
                ],
              ),
            ),
            _buildBottomActionBar(t),
          ],
        ),
      ),
    );
  }

  Widget _buildEditorialHeroCard(PreambleTokens t) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 18.w),
      padding: EdgeInsets.all(18.w),
      decoration: BoxDecoration(
        color: t.brandPrimaryStrong,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(
          color: t.accentBrass.withValues(alpha: 0.35),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: t.shadowAmbient,
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 9.w, vertical: 3.h),
                decoration: BoxDecoration(
                  color: const Color(0x26D4AC6E),
                  borderRadius: BorderRadius.circular(999.r),
                  border: Border.all(color: const Color(0x66D4AC6E)),
                ),
                child: Text(
                  _case.fullDateLabel,
                  style: t.tabularMetric(
                    size: 11.sp,
                    weight: FontWeight.w700,
                    color: const Color(0xFFEED3A5),
                  ),
                ),
              ),
              SizedBox(width: 8.w),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 9.w, vertical: 3.h),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(999.r),
                ),
                child: Text(
                  _case.status,
                  style: t.sansBody(
                    size: 10.5.sp,
                    weight: FontWeight.w600,
                    color: const Color(0xFFD6EAE2),
                    height: 1.2,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          Text(
            _case.title,
            style: t.serifTitle(
              size: 21.sp,
              weight: FontWeight.w800,
              color: const Color(0xFFFAF8F4),
            ),
          ),
          SizedBox(height: 8.h),
          Container(
            padding: EdgeInsets.only(left: 10.w),
            decoration: const BoxDecoration(
              border: Border(
                left: BorderSide(color: Color(0xFFD4AC6E), width: 2.5),
              ),
            ),
            child: Text(
              '「${_case.quote}」',
              style: t.serifBody(
                size: 13.sp,
                color: const Color(0xFFE5EFEA),
                height: 1.55,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar(PreambleTokens t) {
    return SizedBox(
      height: 38.h,
      child: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 18.w),
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        child: Row(
          children: List.generate(_tabs.length, (index) {
            final isSelected = index == _activeTab;
            return Padding(
              padding: EdgeInsets.only(
                right: index == _tabs.length - 1 ? 0 : 8.w,
              ),
              child: GestureDetector(
                onTap: () => setState(() => _activeTab = index),
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 15.w,
                    vertical: 6.h,
                  ),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: isSelected ? t.brandPrimaryStrong : t.surface,
                    borderRadius: BorderRadius.circular(999.r),
                    border: Border.all(
                      color: isSelected ? t.brandPrimaryStrong : t.border,
                    ),
                  ),
                  child: Text(
                    _tabs[index],
                    style: t.sansBody(
                      size: 12.sp,
                      weight: isSelected ? FontWeight.w700 : FontWeight.w600,
                      color: isSelected
                          ? const Color(0xFFFAF8F4)
                          : t.textSecondary,
                      height: 1.2,
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

  Widget _buildContentCard(
    PreambleTokens t, {
    required Widget child,
    Color? accentColor,
    EdgeInsetsGeometry? padding,
  }) {
    final barColor = accentColor ?? t.accentBrass;
    return Container(
      width: double.infinity,
      decoration: t.cardDecoration(radius: 16.r, elevated: false),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(15.r),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(width: 4.w, color: barColor),
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

  Widget _buildActiveTabContent(PreambleTokens t) {
    switch (_activeTab) {
      case 0:
        return _buildIntroTab(t);
      case 1:
        return _buildTimelineTab(t);
      case 2:
        return _buildBackgroundTab(t);
      case 3:
        return _buildImpactTab(t);
      case 4:
        return _buildSourcesTab(t);
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildIntroTab(PreambleTokens t) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '事件簡介',
          style: t.sansTitle(size: 14.5.sp, weight: FontWeight.w700),
        ),
        SizedBox(height: 8.h),
        _buildContentCard(
          t,
          accentColor: t.brandPrimary,
          child: Text(
            _case.background,
            style: t.serifBody(size: 14.sp, color: t.textPrimary),
          ),
        ),
        SizedBox(height: 20.h),
        Text(
          '要旨速覽',
          style: t.sansTitle(size: 14.5.sp, weight: FontWeight.w700),
        ),
        SizedBox(height: 8.h),
        _buildContentCard(
          t,
          accentColor: t.accentBrass,
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
          child: Column(
            children: [
              _buildFactRow(t, '發生日期', _case.fullDateLabel, tabular: true),
              Divider(color: t.border, height: 16.h),
              _buildFactRow(t, '事件地點', _case.location),
              Divider(color: t.border, height: 16.h),
              _buildFactRow(t, '要旨分類', _case.category),
              Divider(color: t.border, height: 16.h),
              _buildFactRow(t, '關聯標籤', _case.tags.join(' · ')),
            ],
          ),
        ),
        if (_case.photos.isNotEmpty) ...[
          SizedBox(height: 20.h),
          Text(
            '歷史影像與現場實景',
            style: t.sansTitle(size: 14.5.sp, weight: FontWeight.w700),
          ),
          SizedBox(height: 8.h),
          ..._case.photos.map(
            (photo) => Padding(
              padding: EdgeInsets.only(bottom: 12.h),
              child: Container(
                width: double.infinity,
                decoration: t.cardDecoration(radius: 16.r, elevated: false),
                clipBehavior: Clip.antiAlias,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AspectRatio(
                      aspectRatio: 16 / 9,
                      child: photo.photoUrl.startsWith('http')
                          ? Image.network(
                              photo.photoUrl,
                              fit: BoxFit.cover,
                              loadingBuilder: (context, child, progress) {
                                if (progress == null) return child;
                                return Container(
                                  color: t.surface,
                                  alignment: Alignment.center,
                                  child: const CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                );
                              },
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  color: t.surface,
                                  alignment: Alignment.center,
                                  child: Icon(
                                    PhosphorIconsRegular.imageSquare,
                                    color: t.textMuted,
                                    size: 28.sp,
                                  ),
                                );
                              },
                            )
                          : Image.asset(
                              photo.photoUrl,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  color: t.surface,
                                  alignment: Alignment.center,
                                  child: Icon(
                                    PhosphorIconsRegular.imageSquare,
                                    color: t.textMuted,
                                    size: 28.sp,
                                  ),
                                );
                              },
                            ),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 14.w,
                        vertical: 10.h,
                      ),
                      child: Text(
                        photo.caption,
                        style: t.sansBody(
                          size: 12.sp,
                          color: t.textSecondary,
                          height: 1.45,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildFactRow(
    PreambleTokens t,
    String label,
    String value, {
    bool tabular = false,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 82.w,
          child: Text(
            label,
            style: t.sansBody(
              size: 12.sp,
              weight: FontWeight.w600,
              color: t.textMuted,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: tabular
                ? t.tabularMetric(
                    size: 12.5.sp,
                    weight: FontWeight.w700,
                    color: t.textPrimary,
                  )
                : t.sansBody(
                    size: 12.5.sp,
                    weight: FontWeight.w600,
                    color: t.textPrimary,
                  ),
          ),
        ),
      ],
    );
  }

  Widget _buildTimelineTab(PreambleTokens t) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '事件發展脈絡',
          style: t.sansTitle(size: 14.5.sp, weight: FontWeight.w700),
        ),
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
                    width: 78.w,
                    child: Padding(
                      padding: EdgeInsets.only(top: 2.h),
                      child: Text(
                        node.dateLabel,
                        style: t.tabularMetric(
                          size: 12.sp,
                          weight: FontWeight.w700,
                          color: t.accentBrass,
                        ),
                      ),
                    ),
                  ),
                  Column(
                    children: [
                      Container(
                        width: 10.w,
                        height: 10.w,
                        margin: EdgeInsets.only(top: 4.h),
                        decoration: BoxDecoration(
                          color: t.brandPrimary,
                          shape: BoxShape.circle,
                        ),
                      ),
                      if (!isLast)
                        Expanded(
                          child: Container(
                            width: 1.5,
                            color: t.border,
                          ),
                        ),
                    ],
                  ),
                  SizedBox(width: 14.w),
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(bottom: 18.h),
                      child: Container(
                        padding: EdgeInsets.all(13.w),
                        decoration:
                            t.cardDecoration(radius: 14.r, elevated: false),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              node.title,
                              style: t.sansTitle(
                                size: 13.5.sp,
                                weight: FontWeight.w700,
                              ),
                            ),
                            SizedBox(height: 4.h),
                            Text(
                              node.description,
                              style: t.sansBody(
                                size: 12.sp,
                                color: t.textSecondary,
                              ),
                            ),
                          ],
                        ),
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

  Widget _buildBackgroundTab(PreambleTokens t) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '時代背景脈絡',
          style: t.sansTitle(size: 14.5.sp, weight: FontWeight.w700),
        ),
        SizedBox(height: 8.h),
        _buildContentCard(
          t,
          accentColor: t.semanticInfo,
          child: Text(
            _case.backgroundDetails,
            style: t.serifBody(size: 14.sp, color: t.textPrimary),
          ),
        ),
      ],
    );
  }

  Widget _buildImpactTab(PreambleTokens t) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '社會與憲政影響',
          style: t.sansTitle(size: 14.5.sp, weight: FontWeight.w700),
        ),
        SizedBox(height: 8.h),
        _buildContentCard(
          t,
          accentColor: t.accentBrass,
          child: Text(
            _case.socialImpact,
            style: t.serifBody(size: 14.sp, color: t.textPrimary),
          ),
        ),
        if (_case.relatedCaseTitles.isNotEmpty) ...[
          SizedBox(height: 20.h),
          Text(
            '相關延伸案件',
            style: t.sansTitle(size: 14.5.sp, weight: FontWeight.w700),
          ),
          SizedBox(height: 8.h),
          Wrap(
            spacing: 8.w,
            runSpacing: 8.h,
            children: [
              for (final title in _case.relatedCaseTitles)
                GestureDetector(
                  onTap: () => _openRelatedCase(title),
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 12.w,
                      vertical: 7.h,
                    ),
                    decoration: BoxDecoration(
                      color: t.surface,
                      borderRadius: BorderRadius.circular(999.r),
                      border: Border.all(color: t.border),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          title,
                          style: t.sansBody(
                            size: 12.sp,
                            weight: FontWeight.w700,
                            color: t.brandPrimary,
                            height: 1.2,
                          ),
                        ),
                        SizedBox(width: 4.w),
                        Icon(
                          PhosphorIconsRegular.arrowUpRight,
                          size: 13.sp,
                          color: t.brandPrimary,
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ],
        if (_case.relatedReadings.isNotEmpty) ...[
          SizedBox(height: 20.h),
          Text(
            '延伸閱讀與官方檔案',
            style: t.sansTitle(size: 14.5.sp, weight: FontWeight.w700),
          ),
          SizedBox(height: 8.h),
          Column(
            children: [
              for (final reading in _case.relatedReadings)
                Container(
                  margin: EdgeInsets.only(bottom: 8.h),
                  decoration: t.cardDecoration(radius: 14.r, elevated: false),
                  child: ListTile(
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 14.w,
                      vertical: 2.h,
                    ),
                    leading: Container(
                      width: 34.w,
                      height: 34.w,
                      decoration: BoxDecoration(
                        color: t.accentBrassContainer,
                        borderRadius: BorderRadius.circular(10.r),
                      ),
                      child: Icon(
                        PhosphorIconsRegular.bookOpenText,
                        color: t.accentOnBrassContainer,
                        size: 18.sp,
                      ),
                    ),
                    title: Text(
                      reading.title,
                      style: t.sansBody(
                        size: 12.5.sp,
                        weight: FontWeight.w700,
                        color: t.textPrimary,
                      ),
                    ),
                    trailing: Icon(
                      PhosphorIconsRegular.arrowSquareOut,
                      size: 16.sp,
                      color: t.accentBrass,
                    ),
                    onTap: () {
                      CustomToast.show(context, '檔案來源：${reading.url}');
                    },
                  ),
                ),
            ],
          ),
        ],
      ],
    );
  }

  Widget _buildSourcesTab(PreambleTokens t) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '資料來源與修訂紀錄',
          style: t.sansTitle(size: 14.5.sp, weight: FontWeight.w700),
        ),
        SizedBox(height: 8.h),
        _buildContentCard(
          t,
          accentColor: t.borderStrong,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (int i = 0; i < _case.sources.length; i++) ...[
                Row(
                  children: [
                    Icon(
                      PhosphorIconsRegular.archive,
                      color: t.accentBrass,
                      size: 16.sp,
                    ),
                    SizedBox(width: 8.w),
                    Expanded(
                      child: Text(
                        _case.sources[i].title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: t.sansBody(
                          size: 12.5.sp,
                          weight: FontWeight.w600,
                          color: t.textPrimary,
                        ),
                      ),
                    ),
                    SizedBox(width: 8.w),
                    Text(
                      _case.sources[i].updatedAt,
                      style: t.tabularMetric(
                        size: 11.sp,
                        weight: FontWeight.w600,
                        color: t.textMuted,
                      ),
                    ),
                  ],
                ),
                if (i < _case.sources.length - 1)
                  Divider(color: t.border, height: 18.h),
              ],
              SizedBox(height: 12.h),
              Container(
                padding: EdgeInsets.all(10.w),
                decoration: t.subtleBoxDecoration(radius: 10.r),
                child: Text(
                  '編纂聲明：本單元內容取材自國家檔案館、司法院公開裁判與法制史研究文獻，旨在提供客觀之法治與人權歷史教育參考。',
                  style: t.sansBody(
                    size: 11.sp,
                    color: t.textMuted,
                    height: 1.45,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBottomActionBar(PreambleTokens t) {
    final matchedBook = _findDossierSync(_case);
    final hasDossier = matchedBook != null;

    return Container(
      padding: EdgeInsets.fromLTRB(18.w, 10.h, 18.w, 16.h),
      decoration: BoxDecoration(
        color: t.surface,
        border: Border(top: BorderSide(color: t.border)),
      ),
      child: SizedBox(
        width: double.infinity,
        height: 46.h,
        child: TextButton(
          style: TextButton.styleFrom(
            backgroundColor: t.brandPrimaryStrong,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14.r),
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
              Navigator.of(context).pop();
            }
          },
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                hasDossier
                    ? PhosphorIconsRegular.scales
                    : PhosphorIconsRegular.books,
                size: 16.sp,
                color: const Color(0xFFFAF8F4),
              ),
              SizedBox(width: 8.w),
              Text(
                hasDossier ? '開啟重大案件完整卷宗' : '返回歷史上的今日',
                style: t.sansTitle(
                  size: 13.5.sp,
                  weight: FontWeight.w700,
                  color: const Color(0xFFFAF8F4),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
