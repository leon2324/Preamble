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

class CaseStoryDetailPage extends StatefulWidget {
  const CaseStoryDetailPage({super.key, required this.item});

  final CaseStoryItem item;

  @override
  State<CaseStoryDetailPage> createState() => _CaseStoryDetailPageState();
}

class _CaseStoryDetailPageState extends State<CaseStoryDetailPage> {
  _CaseAnalysisTab _selectedTab = _CaseAnalysisTab.keyPoints;

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final palette = _CasePalette.of(context);
    final appState = LawAppScope.of(context);
    final topPadding = MediaQuery.paddingOf(context).top;
    final item = widget.item;

    return Scaffold(
      backgroundColor: palette.background,
      body: Stack(
        children: [
          Positioned.fill(
            child: ListView(
              physics: const BouncingScrollPhysics(),
              padding: EdgeInsets.fromLTRB(
                16.w,
                topPadding + 14.h,
                16.w,
                122.h,
              ),
              children: [
                _CaseAnalysisTopBar(
                  palette: palette,
                  onBack: () => Navigator.of(context).pop(),
                  onShare: () => _showMessage('分享功能已預留。'),
                  onBookmark: () => _showMessage('已加入收藏示意。'),
                ),
                SizedBox(height: 16.h),
                _CaseAnalysisHeroCard(item: item, palette: palette),
                SizedBox(height: 12.h),
                _CaseAnalysisTabs(
                  selectedTab: _selectedTab,
                  palette: palette,
                  onChanged: (tab) {
                    setState(() {
                      _selectedTab = tab;
                    });
                  },
                ),
                SizedBox(height: 18.h),
                _buildSelectedTabContent(item, palette),
                if (!appState.canSeeFullCaseDossiers) ...[
                  SizedBox(height: 14.h),
                  _CaseUpgradeCard(palette: palette),
                ],
              ],
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: _CaseBottomActionBar(
              palette: palette,
              onSave: () => _showMessage('已加入收藏示意。'),
              onNote: () => _showMessage('筆記功能已預留。'),
              onAnalyze: () {
                if (!appState.isSignedIn) {
                  _showMessage('登入後可使用 AI 分析案件。');
                  return;
                }
                _showMessage('AI 案件分析流程已預留。');
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSelectedTabContent(
    CaseStoryItem item,
    _CasePalette palette,
  ) {
    switch (_selectedTab) {
      case _CaseAnalysisTab.keyPoints:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _CaseConclusionCard(item: item, palette: palette),
            SizedBox(height: 20.h),
            _CaseTimelinePanel(item: item, palette: palette),
          ],
        );
      case _CaseAnalysisTab.facts:
        return _CaseSectionCard(
          title: '事實經過',
          palette: palette,
          child: Text(
            item.summary,
            style: TextStyle(
              fontSize: 13.sp,
              height: 1.55,
              color: palette.primaryText,
            ),
          ),
        );
      case _CaseAnalysisTab.judgment:
        return _CaseSectionCard(
          title: '法院判決',
          palette: palette,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _CaseInfoLine(label: '法院', value: item.courtName),
              _CaseInfoLine(label: '案號', value: item.caseNumber),
              SizedBox(height: 10.h),
              Text(
                item.oneSentenceConclusion,
                style: TextStyle(
                  fontSize: 13.sp,
                  height: 1.55,
                  color: palette.primaryText,
                ),
              ),
            ],
          ),
        );
      case _CaseAnalysisTab.statutes:
        return _CaseSectionCard(
          title: '相關法條與爭點',
          palette: palette,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Wrap(
                spacing: 8.w,
                runSpacing: 8.h,
                children: item.legalIssues
                    .map((issue) => _CasePill(label: issue, palette: palette))
                    .toList(growable: false),
              ),
              SizedBox(height: 14.h),
              Text(
                '來源會在正式後端同步司法院裁判書後補上裁判書連結、引用段落與更新時間。',
                style: TextStyle(
                  fontSize: 12.sp,
                  height: 1.45,
                  color: palette.secondaryText,
                ),
              ),
            ],
          ),
        );
    }
  }
}

enum _CaseAnalysisTab {
  keyPoints,
  facts,
  judgment,
  statutes,
}

extension _CaseAnalysisTabLabel on _CaseAnalysisTab {
  String get label {
    switch (this) {
      case _CaseAnalysisTab.keyPoints:
        return '案件重點';
      case _CaseAnalysisTab.facts:
        return '事實經過';
      case _CaseAnalysisTab.judgment:
        return '法院判決';
      case _CaseAnalysisTab.statutes:
        return '相關法條';
    }
  }
}

class _CaseAnalysisTopBar extends StatelessWidget {
  const _CaseAnalysisTopBar({
    required this.palette,
    required this.onBack,
    required this.onShare,
    required this.onBookmark,
  });

  final _CasePalette palette;
  final VoidCallback onBack;
  final VoidCallback onShare;
  final VoidCallback onBookmark;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 42.h,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: _CasePlainIconButton(
              icon: Icons.arrow_back_rounded,
              onTap: onBack,
              palette: palette,
            ),
          ),
          Text(
            '案件解析',
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.w900,
              color: palette.primaryText,
            ),
          ),
          Align(
            alignment: Alignment.centerRight,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _CasePlainIconButton(
                  icon: Icons.ios_share_rounded,
                  onTap: onShare,
                  palette: palette,
                ),
                SizedBox(width: 8.w),
                _CasePlainIconButton(
                  icon: Icons.bookmark_border_rounded,
                  onTap: onBookmark,
                  palette: palette,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CaseAnalysisHeroCard extends StatelessWidget {
  const _CaseAnalysisHeroCard({
    required this.item,
    required this.palette,
  });

  final CaseStoryItem item;
  final _CasePalette palette;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: item.accentColor,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: Colors.white.withValues(alpha: 0.64)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _CaseMetaRow(item: item),
          SizedBox(height: 12.h),
          Text(
            item.title,
            style: TextStyle(
              fontSize: 20.sp,
              height: 1.2,
              fontWeight: FontWeight.w900,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            item.caseNumber,
            style: TextStyle(
              fontSize: 12.sp,
              height: 1.4,
              color: AppColors.textPrimary.withValues(alpha: 0.72),
            ),
          ),
          SizedBox(height: 12.h),
          Wrap(
            spacing: 7.w,
            runSpacing: 7.h,
            children: item.legalIssues.take(3).map((issue) {
              return _LightPill(label: issue);
            }).toList(growable: false),
          ),
        ],
      ),
    );
  }
}

class _CaseAnalysisTabs extends StatelessWidget {
  const _CaseAnalysisTabs({
    required this.selectedTab,
    required this.palette,
    required this.onChanged,
  });

  final _CaseAnalysisTab selectedTab;
  final _CasePalette palette;
  final ValueChanged<_CaseAnalysisTab> onChanged;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 38.h,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemBuilder: (context, index) {
          final tab = _CaseAnalysisTab.values[index];
          final isSelected = tab == selectedTab;

          return InkWell(
            onTap: () => onChanged(tab),
            borderRadius: BorderRadius.circular(8.r),
            child: Container(
              alignment: Alignment.center,
              padding: EdgeInsets.symmetric(horizontal: 10.w),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: isSelected ? palette.accent : Colors.transparent,
                    width: 2,
                  ),
                ),
              ),
              child: Text(
                tab.label,
                style: TextStyle(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w900,
                  color:
                      isSelected ? palette.primaryText : palette.secondaryText,
                ),
              ),
            ),
          );
        },
        separatorBuilder: (_, __) => SizedBox(width: 14.w),
        itemCount: _CaseAnalysisTab.values.length,
      ),
    );
  }
}

class _CaseConclusionCard extends StatelessWidget {
  const _CaseConclusionCard({
    required this.item,
    required this.palette,
  });

  final CaseStoryItem item;
  final _CasePalette palette;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: palette.subtleSurface,
        borderRadius: BorderRadius.circular(14.r),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0F000000),
            blurRadius: 14,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '一句話結論',
                  style: TextStyle(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w900,
                    color: palette.primaryText,
                  ),
                ),
                SizedBox(height: 8.h),
                Text(
                  item.oneSentenceConclusion,
                  style: TextStyle(
                    fontSize: 12.sp,
                    height: 1.5,
                    color: palette.primaryText,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: 12.w),
          Icon(
            Icons.gavel_rounded,
            color: const Color(0xFFB9A48A),
            size: 42.sp,
          ),
        ],
      ),
    );
  }
}

class _CaseTimelinePanel extends StatelessWidget {
  const _CaseTimelinePanel({
    required this.item,
    required this.palette,
  });

  final CaseStoryItem item;
  final _CasePalette palette;

  @override
  Widget build(BuildContext context) {
    return _CaseSectionCard(
      title: '案件時光機',
      palette: palette,
      child: Column(
        children: [
          for (var index = 0; index < item.timeline.length; index++)
            _TimelineRow(
              event: item.timeline[index],
              index: index,
              isLast: index == item.timeline.length - 1,
              palette: palette,
            ),
        ],
      ),
    );
  }
}

class _CaseInfoLine extends StatelessWidget {
  const _CaseInfoLine({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 48.w,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 12.sp,
                fontWeight: FontWeight.w800,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 12.sp,
                height: 1.45,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CaseBottomActionBar extends StatelessWidget {
  const _CaseBottomActionBar({
    required this.palette,
    required this.onSave,
    required this.onNote,
    required this.onAnalyze,
  });

  final _CasePalette palette;
  final VoidCallback onSave;
  final VoidCallback onNote;
  final VoidCallback onAnalyze;

  @override
  Widget build(BuildContext context) {
    final isNarrow = MediaQuery.sizeOf(context).width < 360;

    return SafeArea(
      top: false,
      child: Container(
        padding: EdgeInsets.fromLTRB(12.w, 10.h, 12.w, 12.h),
        decoration: BoxDecoration(
          color: palette.background.withValues(alpha: 0.96),
          boxShadow: const [
            BoxShadow(
              color: Color(0x14000000),
              blurRadius: 18,
              offset: Offset(0, -8),
            ),
          ],
        ),
        child: Container(
          padding: EdgeInsets.all(10.w),
          decoration: BoxDecoration(
            color: palette.surface,
            borderRadius: BorderRadius.circular(22.r),
            border: Border.all(color: palette.border),
          ),
          child: Row(
            children: [
              _CaseActionChip(
                icon: Icons.star_border_rounded,
                label: '收藏',
                onTap: onSave,
                palette: palette,
              ),
              SizedBox(width: 8.w),
              _CaseActionChip(
                icon: Icons.note_add_outlined,
                label: isNarrow ? '筆記' : '加入筆記',
                onTap: onNote,
                palette: palette,
              ),
              SizedBox(width: 8.w),
              Expanded(
                child: FilledButton.icon(
                  onPressed: onAnalyze,
                  icon: Icon(Icons.travel_explore_rounded, size: 18.sp),
                  label: Text(isNarrow ? 'AI 分析' : 'AI 分析此案件'),
                  style: FilledButton.styleFrom(
                    backgroundColor: palette.accent,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: 12.h),
                    textStyle: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CaseActionChip extends StatelessWidget {
  const _CaseActionChip({
    required this.icon,
    required this.label,
    required this.onTap,
    required this.palette,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final _CasePalette palette;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: onTap,
      icon: Icon(icon, size: 16.sp),
      label: Text(label),
      style: OutlinedButton.styleFrom(
        foregroundColor: palette.primaryText,
        side: BorderSide(color: palette.border),
        minimumSize: Size(0, 38.h),
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        visualDensity: VisualDensity.compact,
        padding: EdgeInsets.symmetric(horizontal: 9.w, vertical: 10.h),
        textStyle: TextStyle(
          fontSize: 11.sp,
          fontWeight: FontWeight.w800,
        ),
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
    required this.index,
    required this.isLast,
    required this.palette,
  });

  final CaseTimelineItem event;
  final int index;
  final bool isLast;
  final _CasePalette palette;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 0 : 14.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Container(
                width: 18.w,
                height: 18.w,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: palette.accent,
                  shape: BoxShape.circle,
                ),
                child: Text(
                  '${index + 1}'.padLeft(2, '0'),
                  style: TextStyle(
                    fontSize: 8.sp,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                  ),
                ),
              ),
              if (!isLast)
                Container(
                  width: 1.w,
                  height: 30.h,
                  color: palette.accent.withValues(alpha: 0.28),
                ),
            ],
          ),
          SizedBox(width: 10.w),
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
                  event.description,
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

class _CasePlainIconButton extends StatelessWidget {
  const _CasePlainIconButton({
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
      borderRadius: BorderRadius.circular(12.r),
      child: SizedBox(
        width: 42.w,
        height: 42.w,
        child: Icon(icon, color: palette.primaryText, size: 24.sp),
      ),
    );
  }
}
