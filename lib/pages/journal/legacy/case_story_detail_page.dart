import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter/services.dart';
import 'package:preamble/app/app_state.dart';
import 'package:preamble/data/mock_data/cases/case_story_mock_data.dart';
import 'package:preamble/pages/learning/know_law_page.dart';
import 'package:preamble/theme/app_colors.dart';

class CaseStoryDetailPage extends StatefulWidget {
  const CaseStoryDetailPage({super.key, required this.item});

  final CaseStoryItem item;

  @override
  State<CaseStoryDetailPage> createState() => _CaseStoryDetailPageState();
}

class _CaseStoryDetailPageState extends State<CaseStoryDetailPage> {
  late final ScrollController _scrollController;
  _CaseAnalysisTab _selectedTab = _CaseAnalysisTab.keyPoints;
  double _headerCollapse = 0;

  static const _headerCollapseDistance = 120.0;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController()..addListener(_syncHeaderCollapse);
  }

  @override
  void dispose() {
    _scrollController
      ..removeListener(_syncHeaderCollapse)
      ..dispose();
    super.dispose();
  }

  void _syncHeaderCollapse() {
    final next = (_scrollController.offset / _headerCollapseDistance)
        .clamp(0.0, 1.0)
        .toDouble();
    if ((next - _headerCollapse).abs() < 0.01) return;

    setState(() {
      _headerCollapse = next;
    });
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  String get _caseId => widget.item.storageId;

  Future<void> _copyShareSummary(CaseStoryItem item) async {
    final shareText = [
      item.title,
      item.subtitle,
      '一句話結論：${item.oneSentenceConclusion}',
      '案件資料：${item.caseNumber}',
    ].join('\n');

    await Clipboard.setData(ClipboardData(text: shareText));
    if (!mounted) return;
    _showMessage('已複製案件摘要，可貼到訊息或筆記。');
  }

  Future<void> _toggleSaved(PreambleState appState) async {
    final nextSaved = !appState.isCaseSaved(_caseId);
    await appState.setCaseSaved(_caseId, nextSaved);
    if (!mounted) return;
    _showMessage(nextSaved ? '已收藏到本機案件清單。' : '已取消本機收藏。');
  }

  Future<void> _openNoteSheet(PreambleState appState) async {
    final note = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return _CaseNoteSheet(
          item: widget.item,
          palette: _CasePalette.of(sheetContext),
          initialNote: appState.caseNoteDraft(_caseId) ?? '',
        );
      },
    );

    if (note == null) return;
    await appState.saveCaseNoteDraft(_caseId, note);
    if (!mounted) return;
    _showMessage(note.trim().isEmpty ? '已清除本機筆記。' : '已儲存本機筆記。');
  }

  void _openCaseAssistant(CaseStoryItem item) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (__) => LawAssistantChatPage(
          initialPrompt: _caseAssistantPrompt(item),
        ),
      ),
    );
  }

  String _caseAssistantPrompt(CaseStoryItem item) {
    // 案件頁的 AI CTA 不直接假裝完成分析，而是把案名、分類、狀態與已整理摘要
    // 帶到小法助入口，沿用既有 guest 額度、登入與後端錯誤處理流程。
    return [
      '請用一般人看得懂的方式，幫我分析這個案件：${item.title}',
      '案件分類：${item.category}',
      '發生日期與地點：${item.occurredAt}｜${item.location}',
      '目前狀態：${item.statusLabel}',
      '案件摘要：${item.summary}',
      '我想知道：這個案件的法律爭點、法院可能重視的事實，以及我接下來該看哪些資料。',
    ].join('\n');
  }

  @override
  Widget build(BuildContext context) {
    final palette = _CasePalette.of(context);
    final appState = PreambleScope.of(context);
    final item = widget.item;
    final isSaved = appState.isCaseSaved(_caseId);
    final hasNote = appState.hasCaseNoteDraft(_caseId);

    return Scaffold(
      backgroundColor: palette.background,
      body: Stack(
        children: [
          Positioned.fill(
            child: Column(
              children: [
                _CaseFrozenHeader(
                  item: item,
                  palette: palette,
                  selectedTab: _selectedTab,
                  isSaved: isSaved,
                  collapseProgress: _headerCollapse,
                  onBack: () => Navigator.of(context).pop(),
                  onShare: () => _copyShareSummary(item),
                  onBookmark: () => _toggleSaved(appState),
                  onTabChanged: (tab) {
                    setState(() => _selectedTab = tab);
                  },
                ),
                Expanded(
                  child: ListView(
                    controller: _scrollController,
                    physics: const ClampingScrollPhysics(),
                    padding: EdgeInsets.fromLTRB(16.w, 14.h, 16.w, 104.h),
                    children: [
                      _buildSelectedTabContent(item, palette),
                      if (!appState.canSeeFullCaseDossiers) ...[
                        SizedBox(height: 14.h),
                        _CaseUpgradeCard(palette: palette),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: _CaseBottomActionBar(
              palette: palette,
              isSaved: isSaved,
              hasNote: hasNote,
              onSave: () => _toggleSaved(appState),
              onNote: () => _openNoteSheet(appState),
              onAskAi: () => _openCaseAssistant(item),
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
      case _CaseAnalysisTab.news:
        return _CaseNewsDataPanel(item: item, palette: palette);
      case _CaseAnalysisTab.media:
        return _CaseMediaPanel(item: item, palette: palette);
    }
  }
}

enum _CaseAnalysisTab {
  keyPoints,
  facts,
  judgment,
  statutes,
  news,
  media,
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
      case _CaseAnalysisTab.news:
        return '新聞資料';
      case _CaseAnalysisTab.media:
        return '相關媒體影音';
    }
  }
}

class _CaseFrozenHeader extends StatelessWidget {
  const _CaseFrozenHeader({
    required this.item,
    required this.palette,
    required this.selectedTab,
    required this.isSaved,
    required this.collapseProgress,
    required this.onBack,
    required this.onShare,
    required this.onBookmark,
    required this.onTabChanged,
  });

  final CaseStoryItem item;
  final _CasePalette palette;
  final _CaseAnalysisTab selectedTab;
  final bool isSaved;
  final double collapseProgress;
  final VoidCallback onBack;
  final VoidCallback onShare;
  final VoidCallback onBookmark;
  final ValueChanged<_CaseAnalysisTab> onTabChanged;

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.paddingOf(context).top;
    final detailHeight = _scaleValue(132.h, 26.h, collapseProgress);
    final sectionGap = _scaleValue(7.h, 2.h, collapseProgress);

    return Container(
      padding: EdgeInsets.fromLTRB(16.w, topPadding + 8.h, 16.w, 8.h),
      decoration: BoxDecoration(
        color: palette.background,
        border: Border(
          bottom: BorderSide(color: palette.border.withValues(alpha: 0.72)),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06 * collapseProgress),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          // 案件詳情是查閱型頁面，使用者會在不同資料分頁間比對；
          // 因此把標題、案件摘要與分頁固定在上方，讓下方內容滾動時脈絡不會消失。
          _CaseAnalysisTopBar(
            palette: palette,
            isSaved: isSaved,
            onBack: onBack,
            onShare: onShare,
            onBookmark: onBookmark,
          ),
          SizedBox(height: sectionGap),
          ClipRect(
            child: SizedBox(
              height: detailHeight,
              child: Stack(
                children: [
                  Positioned.fill(
                    child: IgnorePointer(
                      ignoring: collapseProgress > 0.5,
                      child: Opacity(
                        opacity: (1 - collapseProgress).clamp(0.0, 1.0),
                        child: _CaseExpandedHeaderDetails(
                          item: item,
                          palette: palette,
                        ),
                      ),
                    ),
                  ),
                  Positioned.fill(
                    child: IgnorePointer(
                      ignoring: collapseProgress < 0.5,
                      child: Opacity(
                        opacity: collapseProgress.clamp(0.0, 1.0),
                        child: _CaseCollapsedHeaderDetails(
                          item: item,
                          palette: palette,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: sectionGap),
          _CaseAnalysisTabs(
            selectedTab: selectedTab,
            palette: palette,
            onChanged: onTabChanged,
          ),
        ],
      ),
    );
  }

  double _scaleValue(double expanded, double collapsed, double progress) {
    return expanded + ((collapsed - expanded) * progress.clamp(0.0, 1.0));
  }
}

class _CaseAnalysisTopBar extends StatelessWidget {
  const _CaseAnalysisTopBar({
    required this.palette,
    required this.isSaved,
    required this.onBack,
    required this.onShare,
    required this.onBookmark,
  });

  final _CasePalette palette;
  final bool isSaved;
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
              icon: Icons.arrow_back_ios_new_rounded,
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
                  icon: isSaved
                      ? Icons.bookmark_rounded
                      : Icons.bookmark_border_rounded,
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

class _CaseExpandedHeaderDetails extends StatelessWidget {
  const _CaseExpandedHeaderDetails({
    required this.item,
    required this.palette,
  });

  final CaseStoryItem item;
  final _CasePalette palette;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // 展開狀態只放「案名、分類、時間地點、狀態」四個維護欄位；
        // 不再塞入法條爭點與案號，避免案件閱讀頁一進來就被資訊噪音蓋住。
        return Align(
          alignment: Alignment.topLeft,
          child: FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.topLeft,
            child: SizedBox(
              width: constraints.maxWidth,
              child: Padding(
                padding: EdgeInsets.fromLTRB(2.w, 6.h, 2.w, 2.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      width: double.infinity,
                      child: Text(
                        item.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 25.sp,
                          height: 1.12,
                          fontWeight: FontWeight.w900,
                          color: palette.primaryText,
                        ),
                      ),
                    ),
                    SizedBox(height: 9.h),
                    _CaseMetaTextLine(
                      label: '案件分類',
                      value: item.category,
                      palette: palette,
                    ),
                    _CaseMetaTextLine(
                      label: '日期地點',
                      value: '${item.occurredAt}｜${item.location}',
                      palette: palette,
                    ),
                    _CaseMetaTextLine(
                      label: '目前狀態',
                      value: item.statusLabel,
                      palette: palette,
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _CaseCollapsedHeaderDetails extends StatelessWidget {
  const _CaseCollapsedHeaderDetails({
    required this.item,
    required this.palette,
  });

  final CaseStoryItem item;
  final _CasePalette palette;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.center,
      child: Text(
        item.title,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 14.sp,
          fontWeight: FontWeight.w900,
          color: palette.primaryText,
        ),
      ),
    );
  }
}

class _CaseMetaTextLine extends StatelessWidget {
  const _CaseMetaTextLine({
    required this.label,
    required this.value,
    required this.palette,
  });

  final String label;
  final String value;
  final _CasePalette palette;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 3.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 58.w,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 11.sp,
                fontWeight: FontWeight.w800,
                color: palette.secondaryText.withValues(alpha: 0.72),
              ),
            ),
          ),
          SizedBox(width: 8.w),
          Expanded(
            child: Text(
              value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 11.5.sp,
                height: 1.3,
                fontWeight: FontWeight.w700,
                color: palette.secondaryText,
              ),
            ),
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
        physics: const ClampingScrollPhysics(),
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
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: palette.subtleSurface,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: palette.border.withValues(alpha: 0.68)),
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
            size: 34.sp,
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

class _CaseNewsDataPanel extends StatelessWidget {
  const _CaseNewsDataPanel({
    required this.item,
    required this.palette,
  });

  final CaseStoryItem item;
  final _CasePalette palette;

  @override
  Widget build(BuildContext context) {
    return _CaseSectionCard(
      title: '新聞資料',
      palette: palette,
      child: Column(
        children: [
          for (final source in item.sources)
            _CaseDataRow(
              icon: Icons.article_outlined,
              title: source,
              body: '目前先保留來源分類，等正式資料庫接上後再顯示新聞標題、日期與原始連結。',
              palette: palette,
            ),
          SizedBox(height: 2.h),
          _CaseInlineNotice(
            icon: Icons.fact_check_outlined,
            text: '避免把未審核連結包裝成可引用資料；這裡只呈現目前已整理的來源類型。',
            palette: palette,
          ),
        ],
      ),
    );
  }
}

class _CaseMediaPanel extends StatelessWidget {
  const _CaseMediaPanel({
    required this.item,
    required this.palette,
  });

  final CaseStoryItem item;
  final _CasePalette palette;

  @override
  Widget build(BuildContext context) {
    return _CaseSectionCard(
      title: '相關媒體影音',
      palette: palette,
      child: Column(
        children: [
          for (final point in item.watchPoints)
            _CaseDataRow(
              icon: Icons.play_circle_outline_rounded,
              title: point,
              body: '可作為日後串接新聞專題、Podcast 或法院公開說明影片時的影音索引題目。',
              palette: palette,
            ),
          SizedBox(height: 2.h),
          _CaseInlineNotice(
            icon: Icons.video_library_outlined,
            text: '目前尚未接影音資料來源，所以不放假影片卡；正式來源確認後才會出現可播放內容。',
            palette: palette,
          ),
        ],
      ),
    );
  }
}

class _CaseDataRow extends StatelessWidget {
  const _CaseDataRow({
    required this.icon,
    required this.title,
    required this.body,
    required this.palette,
  });

  final IconData icon;
  final String title;
  final String body;
  final _CasePalette palette;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20.sp, color: palette.accent),
          SizedBox(width: 10.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w900,
                    color: palette.primaryText,
                  ),
                ),
                SizedBox(height: 3.h),
                Text(
                  body,
                  style: TextStyle(
                    fontSize: 11.5.sp,
                    height: 1.45,
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

class _CaseInlineNotice extends StatelessWidget {
  const _CaseInlineNotice({
    required this.icon,
    required this.text,
    required this.palette,
  });

  final IconData icon;
  final String text;
  final _CasePalette palette;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: palette.subtleSurface.withValues(alpha: 0.72),
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: palette.border.withValues(alpha: 0.7)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18.sp, color: palette.accent),
          SizedBox(width: 8.w),
          Expanded(
            child: Text(
              text,
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
    required this.isSaved,
    required this.hasNote,
    required this.onSave,
    required this.onNote,
    required this.onAskAi,
  });

  final _CasePalette palette;
  final bool isSaved;
  final bool hasNote;
  final VoidCallback onSave;
  final VoidCallback onNote;
  final VoidCallback onAskAi;

  @override
  Widget build(BuildContext context) {
    final isNarrow = MediaQuery.sizeOf(context).width < 360;

    return SafeArea(
      top: false,
      child: Padding(
        padding: EdgeInsets.fromLTRB(30.w, 8.h, 30.w, 12.h),
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: 340.w),
            child: Container(
              padding: EdgeInsets.all(9.w),
              decoration: BoxDecoration(
                color: palette.surface.withValues(alpha: 0.97),
                borderRadius: BorderRadius.circular(22.r),
                border: Border.all(color: palette.border),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x18000000),
                    blurRadius: 18,
                    offset: Offset(0, 8),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: _CaseActionChip(
                      icon: isSaved
                          ? Icons.star_rounded
                          : Icons.star_border_rounded,
                      label: isSaved ? '已收藏' : '收藏',
                      isActive: isSaved,
                      onTap: onSave,
                      palette: palette,
                    ),
                  ),
                  SizedBox(width: 8.w),
                  Expanded(
                    child: _CaseActionChip(
                      icon: hasNote
                          ? Icons.note_alt_rounded
                          : Icons.note_add_outlined,
                      label: isNarrow
                          ? '筆記'
                          : hasNote
                              ? '編輯筆記'
                              : '加入筆記',
                      isActive: hasNote,
                      onTap: onNote,
                      palette: palette,
                    ),
                  ),
                  SizedBox(width: 8.w),
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: onAskAi,
                      icon: Icon(Icons.auto_awesome_rounded, size: 16.sp),
                      label: Text(isNarrow ? '問 AI' : '問 AI'),
                      style: FilledButton.styleFrom(
                        backgroundColor: const Color(0xFF118AB2),
                        foregroundColor: Colors.white,
                        minimumSize: Size(0, 38.h),
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        visualDensity: VisualDensity.compact,
                        padding: EdgeInsets.symmetric(
                          horizontal: 8.w,
                          vertical: 10.h,
                        ),
                        textStyle: TextStyle(
                          fontSize: 11.sp,
                          fontWeight: FontWeight.w900,
                        ),
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

class _CaseActionChip extends StatelessWidget {
  const _CaseActionChip({
    required this.icon,
    required this.label,
    required this.isActive,
    required this.onTap,
    required this.palette,
  });

  final IconData icon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;
  final _CasePalette palette;

  @override
  Widget build(BuildContext context) {
    final activeColor = palette.accent.withValues(alpha: 0.16);

    return OutlinedButton.icon(
      onPressed: onTap,
      icon: Icon(icon, size: 16.sp),
      label: Text(label),
      style: OutlinedButton.styleFrom(
        foregroundColor: palette.primaryText,
        backgroundColor: isActive ? activeColor : Colors.transparent,
        side: BorderSide(
          color: isActive ? palette.accent : palette.border,
        ),
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

class _CaseNoteSheet extends StatefulWidget {
  const _CaseNoteSheet({
    required this.item,
    required this.palette,
    required this.initialNote,
  });

  final CaseStoryItem item;
  final _CasePalette palette;
  final String initialNote;

  @override
  State<_CaseNoteSheet> createState() => _CaseNoteSheetState();
}

class _CaseNoteSheetState extends State<_CaseNoteSheet> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialNote);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final palette = widget.palette;
    final keyboardInset = MediaQuery.viewInsetsOf(context).bottom;

    return AnimatedPadding(
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeOut,
      padding: EdgeInsets.only(bottom: keyboardInset),
      child: SafeArea(
        top: false,
        child: Container(
          padding: EdgeInsets.fromLTRB(18.w, 14.h, 18.w, 16.h),
          decoration: BoxDecoration(
            color: palette.surface,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
            border: Border(top: BorderSide(color: palette.border)),
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
                    color: palette.border,
                    borderRadius: BorderRadius.circular(999.r),
                  ),
                ),
              ),
              SizedBox(height: 14.h),
              Text(
                '本機筆記',
                style: TextStyle(
                  fontSize: 17.sp,
                  fontWeight: FontWeight.w900,
                  color: palette.primaryText,
                ),
              ),
              SizedBox(height: 4.h),
              Text(
                widget.item.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 12.sp,
                  color: palette.secondaryText,
                ),
              ),
              SizedBox(height: 12.h),
              // 這裡只承諾「本機草稿」；不寫成雲端筆記或會員同步，
              // 是為了讓目前真的能完成的動作和使用者看到的文案一致。
              TextField(
                controller: _controller,
                onTapOutside: (event) {
                  FocusManager.instance.primaryFocus?.unfocus();
                },
                minLines: 4,
                maxLines: 7,
                textInputAction: TextInputAction.newline,
                decoration: InputDecoration(
                  hintText: '記下想追的判決理由、新聞線索或疑問...',
                  filled: true,
                  fillColor: palette.subtleSurface.withValues(alpha: 0.46),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14.r),
                    borderSide: BorderSide(color: palette.border),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14.r),
                    borderSide: BorderSide(color: palette.border),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14.r),
                    borderSide: BorderSide(color: palette.accent, width: 1.4),
                  ),
                ),
              ),
              SizedBox(height: 12.h),
              Row(
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(''),
                    child: const Text('清除'),
                  ),
                  const Spacer(),
                  OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('取消'),
                  ),
                  SizedBox(width: 8.w),
                  FilledButton(
                    onPressed: () =>
                        Navigator.of(context).pop(_controller.text),
                    child: const Text('儲存'),
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

    return _CasePalette(
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
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: palette.surface,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: palette.border.withValues(alpha: 0.82)),
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
      child: SizedBox(
        width: 42.w,
        height: 42.w,
        child: Icon(icon, color: palette.primaryText, size: 20.sp),
      ),
    );
  }
}
