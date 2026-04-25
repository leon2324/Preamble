import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lawapp/app/app_state.dart';
import 'package:lawapp/components/search/search_page_layout.dart';
import 'package:lawapp/data/legal_sources/legal_source_registry.dart';
import 'package:lawapp/data/mock_data/cases/case_story_mock_data.dart';
import 'package:lawapp/theme/app_colors.dart';

/// 案例庫頁。
///
/// 台灣繁體中文教學註解：
/// 使用者不一定是法律背景，很多人是因為社會新聞、犯罪 Podcast 或調查節目
/// 對案件產生興趣；所以這頁用「案件故事 + 法律爭點 + 時間線」包裝，
/// 未來後端接司法院裁判書後，再把 mock data 換成同步資料即可。
class TrendingPage extends StatefulWidget {
  const TrendingPage({super.key});

  @override
  State<TrendingPage> createState() => _TrendingPageState();
}

class _TrendingPageState extends State<TrendingPage> {
  final TextEditingController controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    controller.addListener(_refresh);
  }

  @override
  void dispose() {
    controller.removeListener(_refresh);
    controller.dispose();
    super.dispose();
  }

  void _refresh() => setState(() {});

  List<CaseStoryItem> get _visibleItems {
    final query = controller.text.trim();
    if (query.isEmpty) return caseStoryItems;

    return caseStoryItems.where((item) {
      final haystacks = [
        item.title,
        item.subtitle,
        item.category,
        item.country,
        item.summary,
        ...item.legalIssues,
      ];
      return haystacks.any((text) => text.contains(query));
    }).toList(growable: false);
  }

  @override
  Widget build(BuildContext context) {
    final palette = _CasePalette.of(context);

    return SearchPageLayout(
      controller: controller,
      hintText: '搜尋社會案件、爭點、人物...',
      headerTitle: '案例庫',
      headerSubtitle: '整理社會案件脈絡、裁判資料來源與一般人最需要看懂的法律爭點。',
      builder: (context, layout, contentTopPadding, contentBottomPadding) {
        final items = _visibleItems;

        return ListView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          padding: EdgeInsets.fromLTRB(
            16.w,
            contentTopPadding,
            16.w,
            contentBottomPadding,
          ),
          children: [
            _CaseSourceNotice(palette: palette),
            SizedBox(height: 14.h),
            _CaseTopicFilters(palette: palette),
            SizedBox(height: 14.h),
            if (items.isEmpty)
              _CaseEmptyState(palette: palette)
            else
              ...items.map(
                (item) => Padding(
                  padding: EdgeInsets.only(bottom: 12.h),
                  child: _CaseStoryCard(
                    item: item,
                    palette: palette,
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => CaseStoryDetailPage(item: item),
                        ),
                      );
                    },
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}

class CaseStoryDetailPage extends StatelessWidget {
  const CaseStoryDetailPage({super.key, required this.item});

  final CaseStoryItem item;

  @override
  Widget build(BuildContext context) {
    final palette = _CasePalette.of(context);
    final appState = LawAppScope.of(context);
    final topPadding = MediaQuery.paddingOf(context).top;

    return Scaffold(
      backgroundColor: palette.background,
      body: ListView(
        physics: const BouncingScrollPhysics(),
        padding: EdgeInsets.fromLTRB(16.w, topPadding + 14.h, 16.w, 30.h),
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: _CaseIconButton(
              icon: Icons.arrow_back_rounded,
              onTap: () => Navigator.of(context).pop(),
              palette: palette,
            ),
          ),
          SizedBox(height: 16.h),
          Container(
            padding: EdgeInsets.all(18.w),
            decoration: BoxDecoration(
              color: item.accentColor,
              borderRadius: BorderRadius.circular(24.r),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _CaseMetaRow(item: item),
                SizedBox(height: 12.h),
                Text(
                  item.title,
                  style: TextStyle(
                    fontSize: 24.sp,
                    height: 1.12,
                    fontWeight: FontWeight.w900,
                    color: AppColors.textPrimary,
                  ),
                ),
                SizedBox(height: 8.h),
                Text(
                  item.summary,
                  style: TextStyle(
                    fontSize: 13.sp,
                    height: 1.5,
                    color: AppColors.textPrimary.withValues(alpha: 0.78),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 16.h),
          _CaseSectionCard(
            title: '法律爭點',
            palette: palette,
            child: Wrap(
              spacing: 8.w,
              runSpacing: 8.h,
              children: item.legalIssues
                  .map((issue) => _CasePill(label: issue, palette: palette))
                  .toList(growable: false),
            ),
          ),
          SizedBox(height: 14.h),
          _CaseSectionCard(
            title: '時間線',
            palette: palette,
            child: Column(
              children: item.timeline.map((event) {
                final isLocked = !appState.canSeeFullCaseDossiers &&
                    item.timeline.indexOf(event) > 0;
                return _TimelineRow(
                  event: event,
                  isLocked: isLocked,
                  palette: palette,
                );
              }).toList(growable: false),
            ),
          ),
          SizedBox(height: 14.h),
          _CaseSectionCard(
            title: '看案件時要注意',
            palette: palette,
            child: Column(
              children: item.watchPoints.map((point) {
                return Padding(
                  padding: EdgeInsets.only(bottom: 8.h),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.remove_red_eye_outlined,
                        size: 17.sp,
                        color: palette.accent,
                      ),
                      SizedBox(width: 8.w),
                      Expanded(
                        child: Text(
                          point,
                          style: TextStyle(
                            fontSize: 12.sp,
                            height: 1.45,
                            color: palette.primaryText,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(growable: false),
            ),
          ),
          if (!appState.canSeeFullCaseDossiers) ...[
            SizedBox(height: 14.h),
            _CaseUpgradeCard(palette: palette),
          ],
        ],
      ),
    );
  }
}

class _CasePalette {
  const _CasePalette({
    required this.background,
    required this.surface,
    required this.subtleSurface,
    required this.border,
    required this.primaryText,
    required this.secondaryText,
    required this.accent,
  });

  final Color background;
  final Color surface;
  final Color subtleSurface;
  final Color border;
  final Color primaryText;
  final Color secondaryText;
  final Color accent;

  static _CasePalette of(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    if (isDark) {
      return const _CasePalette(
        background: Color(0xFF0F1216),
        surface: Color(0xFF171C22),
        subtleSurface: Color(0xFF202731),
        border: Color(0xFF2B3441),
        primaryText: Color(0xFFF2F4F7),
        secondaryText: Color(0xFFA3ABB6),
        accent: Color(0xFFE5CD93),
      );
    }

    return const _CasePalette(
      background: AppColors.background,
      surface: Colors.white,
      subtleSurface: Color(0xFFF8F1E2),
      border: AppColors.border,
      primaryText: AppColors.textPrimary,
      secondaryText: AppColors.textSecondary,
      accent: AppColors.accent,
    );
  }
}

class _CaseSourceNotice extends StatelessWidget {
  const _CaseSourceNotice({required this.palette});

  final _CasePalette palette;

  @override
  Widget build(BuildContext context) {
    final judicialSource = legalSourceEntries.firstWhere(
      (source) => source.title.contains('司法院'),
    );

    return Container(
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: palette.subtleSurface,
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(color: palette.border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.info_outline_rounded, color: palette.accent, size: 20.sp),
          SizedBox(width: 9.w),
          Expanded(
            child: Text(
              '${judicialSource.title}：${judicialSource.statusLabel}。第一版先呈現整理型案例，正式後端會以裁判書資料定期同步並標明來源。',
              style: TextStyle(
                fontSize: 11.5.sp,
                height: 1.45,
                color: palette.secondaryText,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CaseTopicFilters extends StatelessWidget {
  const _CaseTopicFilters({required this.palette});

  final _CasePalette palette;

  static const labels = ['刑事', '民事', '憲法', '金融', '租賃', '高熱度'];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 34.h,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemBuilder: (context, index) {
          return Container(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 7.h),
            decoration: BoxDecoration(
              color: palette.surface,
              borderRadius: BorderRadius.circular(999.r),
              border: Border.all(color: palette.border),
            ),
            child: Text(
              labels[index],
              style: TextStyle(
                fontSize: 11.sp,
                fontWeight: FontWeight.w800,
                color: palette.primaryText,
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

class _CaseStoryCard extends StatelessWidget {
  const _CaseStoryCard({
    required this.item,
    required this.palette,
    required this.onTap,
  });

  final CaseStoryItem item;
  final _CasePalette palette;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(22.r),
        child: Container(
          padding: EdgeInsets.all(16.w),
          decoration: BoxDecoration(
            color: palette.surface,
            borderRadius: BorderRadius.circular(22.r),
            border: Border.all(color: palette.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _CaseMetaRow(item: item),
              SizedBox(height: 10.h),
              Text(
                item.title,
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w900,
                  color: palette.primaryText,
                ),
              ),
              SizedBox(height: 5.h),
              Text(
                item.subtitle,
                style: TextStyle(
                  fontSize: 12.sp,
                  height: 1.4,
                  color: palette.secondaryText,
                ),
              ),
              SizedBox(height: 12.h),
              Row(
                children: [
                  Expanded(
                    child: Wrap(
                      spacing: 6.w,
                      runSpacing: 6.h,
                      children: item.legalIssues.take(3).map((issue) {
                        return _CasePill(label: issue, palette: palette);
                      }).toList(growable: false),
                    ),
                  ),
                  SizedBox(width: 8.w),
                  Column(
                    children: [
                      Text(
                        '${item.publicInterest}',
                        style: TextStyle(
                          fontSize: 22.sp,
                          fontWeight: FontWeight.w900,
                          color: palette.accent,
                        ),
                      ),
                      Text(
                        '熱度',
                        style: TextStyle(
                          fontSize: 10.sp,
                          color: palette.secondaryText,
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
    );
  }
}

class _CaseMetaRow extends StatelessWidget {
  const _CaseMetaRow({required this.item});

  final CaseStoryItem item;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 7.w,
      runSpacing: 7.h,
      children: [
        _LightPill(label: item.country),
        _LightPill(label: item.category),
        _LightPill(label: item.statusLabel),
      ],
    );
  }
}

class _CaseSectionCard extends StatelessWidget {
  const _CaseSectionCard({
    required this.title,
    required this.child,
    required this.palette,
  });

  final String title;
  final Widget child;
  final _CasePalette palette;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: palette.surface,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: palette.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w900,
              color: palette.primaryText,
            ),
          ),
          SizedBox(height: 10.h),
          child,
        ],
      ),
    );
  }
}

class _TimelineRow extends StatelessWidget {
  const _TimelineRow({
    required this.event,
    required this.isLocked,
    required this.palette,
  });

  final CaseTimelineItem event;
  final bool isLocked;
  final _CasePalette palette;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 11.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            isLocked ? Icons.lock_outline_rounded : Icons.radio_button_checked,
            size: 17.sp,
            color: palette.accent,
          ),
          SizedBox(width: 8.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  event.label,
                  style: TextStyle(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w900,
                    color: palette.primaryText,
                  ),
                ),
                SizedBox(height: 3.h),
                Text(
                  isLocked ? '訂閱後可查看完整時間線與裁判資料連結。' : event.description,
                  style: TextStyle(
                    fontSize: 11.5.sp,
                    height: 1.4,
                    color: palette.secondaryText,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CaseUpgradeCard extends StatelessWidget {
  const _CaseUpgradeCard({required this.palette});

  final _CasePalette palette;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(15.w),
      decoration: BoxDecoration(
        color: palette.subtleSurface,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: palette.border),
      ),
      child: Row(
        children: [
          Icon(Icons.workspace_premium_outlined, color: palette.accent),
          SizedBox(width: 10.w),
          Expanded(
            child: Text(
              '訂閱者可查看完整卷宗：裁判書連結、爭點摘要、類似案例與 AI 問答脈絡。',
              style: TextStyle(
                fontSize: 12.sp,
                height: 1.45,
                color: palette.primaryText,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CasePill extends StatelessWidget {
  const _CasePill({
    required this.label,
    required this.palette,
  });

  final String label;
  final _CasePalette palette;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 9.w, vertical: 5.h),
      decoration: BoxDecoration(
        color: palette.subtleSurface,
        borderRadius: BorderRadius.circular(999.r),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 10.5.sp,
          fontWeight: FontWeight.w800,
          color: palette.primaryText,
        ),
      ),
    );
  }
}

class _LightPill extends StatelessWidget {
  const _LightPill({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 9.w, vertical: 5.h),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.72),
        borderRadius: BorderRadius.circular(999.r),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 10.5.sp,
          fontWeight: FontWeight.w800,
          color: AppColors.primary,
        ),
      ),
    );
  }
}

class _CaseEmptyState extends StatelessWidget {
  const _CaseEmptyState({required this.palette});

  final _CasePalette palette;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: palette.surface,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: palette.border),
      ),
      child: Text(
        '目前沒有符合的案件整理。之後接上後端搜尋後，這裡會查詢裁判書索引與案件摘要。',
        style: TextStyle(
          fontSize: 12.sp,
          height: 1.45,
          color: palette.secondaryText,
        ),
      ),
    );
  }
}

class _CaseIconButton extends StatelessWidget {
  const _CaseIconButton({
    required this.icon,
    required this.onTap,
    required this.palette,
  });

  final IconData icon;
  final VoidCallback onTap;
  final _CasePalette palette;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14.r),
      child: Container(
        width: 42.w,
        height: 42.w,
        decoration: BoxDecoration(
          color: palette.surface,
          borderRadius: BorderRadius.circular(14.r),
          border: Border.all(color: palette.border),
        ),
        child: Icon(icon, color: palette.primaryText, size: 22.sp),
      ),
    );
  }
}
