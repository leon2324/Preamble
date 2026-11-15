part of '../global_search_page.dart';

// 靜奢律政 × 雙重編碼「AI 三段論法理總覽卡」：
// 明確拆解「01 大前提法規範（宋體權威條文）➔ 02 小前提爭點涵攝（黑體檢核）➔ 03 結論與行動建議」，
// 並整合法定時效警示、談判自保防禦金句與一鍵建立「自救記事」案卷。

class _AssistantThinkingIndicator extends StatefulWidget {
  const _AssistantThinkingIndicator();

  @override
  State<_AssistantThinkingIndicator> createState() =>
      _AssistantThinkingIndicatorState();
}

class _AssistantThinkingIndicatorState
    extends State<_AssistantThinkingIndicator>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(3, (index) {
        return AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            final delay = index * 0.22;
            final val = (_controller.value + delay) % 1.0;
            final scale = 0.65 + 0.35 * (0.5 - (0.5 - val).abs()) * 2;
            return Transform.scale(
              scale: scale,
              child: Container(
                width: 7.r,
                height: 7.r,
                margin: EdgeInsets.symmetric(horizontal: 2.5.w),
                decoration: BoxDecoration(
                  color: t.brandPrimary,
                  shape: BoxShape.circle,
                ),
              ),
            );
          },
        );
      }),
    );
  }
}

class _DottedLine extends StatelessWidget {
  const _DottedLine({
    required this.color,
    this.height = 1,
    this.dashWidth = 4,
    this.dashSpace = 4,
  });

  final double height;
  final Color color;
  final double dashWidth;
  final double dashSpace;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final boxWidth = constraints.constrainWidth();
        if (!boxWidth.isFinite || boxWidth <= 0) return const SizedBox.shrink();
        final dashCount = (boxWidth / (dashWidth + dashSpace)).floor();
        if (dashCount <= 0) return const SizedBox.shrink();
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(dashCount, (_) {
            return SizedBox(
              width: dashWidth,
              height: height,
              child: DecoratedBox(
                decoration: BoxDecoration(color: color),
              ),
            );
          }),
        );
      },
    );
  }
}

class _AssistantReportHeader extends StatelessWidget {
  const _AssistantReportHeader({
    required this.docId,
    required this.isThinking,
    required this.isNaturalQuestion,
  });

  final String docId;
  final bool isThinking;
  final bool isNaturalQuestion;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          alignment: WrapAlignment.spaceBetween,
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: 8.w,
          runSpacing: 4.h,
          children: [
            Text(
              docId,
              style: _SearchText.metric(
                context,
                size: 11.sp,
                color: t.textMuted,
              ),
            ),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
              decoration: BoxDecoration(
                color: isNaturalQuestion
                    ? t.accentBrassContainer
                    : t.brandContainer,
                borderRadius: BorderRadius.circular(6.r),
              ),
              child: Text(
                isNaturalQuestion ? '情境問診三段論' : '法源結構快析',
                style: _SearchText.captionStrong(context).copyWith(
                  color: isNaturalQuestion
                      ? t.accentOnBrassContainer
                      : t.brandOnContainer,
                  fontSize: 11.sp,
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 8.h),
        Row(
          children: [
            Container(
              width: 30.r,
              height: 30.r,
              decoration: BoxDecoration(
                color: t.brandPrimaryStrong,
                borderRadius: BorderRadius.circular(8.r),
                border: Border.all(
                  color: t.accentBrass.withValues(alpha: 0.4),
                ),
              ),
              child: Icon(
                PhosphorIconsFill.scales,
                color: t.accentBrass,
                size: 16.sp,
              ),
            ),
            SizedBox(width: 9.w),
            Expanded(
              child: Text(
                'AI 三段論法理總覽',
                style: _SearchText.serifSection(context),
              ),
            ),
            if (isThinking)
              const _AssistantThinkingIndicator()
            else
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: t.semanticSuccessContainer,
                  borderRadius: BorderRadius.circular(6.r),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      PhosphorIconsFill.checkCircle,
                      size: 12.sp,
                      color: t.semanticSuccess,
                    ),
                    SizedBox(width: 4.w),
                    Text(
                      '已完成',
                      style: _SearchText.captionStrong(context).copyWith(
                        color: t.semanticSuccess,
                        fontSize: 11.sp,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ],
    );
  }
}

class _AssistantOverviewCard extends StatelessWidget {
  const _AssistantOverviewCard({
    required this.query,
    required this.summary,
    required this.isThinking,
    required this.isNaturalQuestion,
    required this.tone,
    required this.length,
    required this.onToneChanged,
    required this.onLengthChanged,
    required this.onNotebookSave,
    required this.onContinueChat,
    this.syllogismAnalysis,
    this.defenseInsight,
    this.onSaveToJournal,
  });

  final String query;
  final String summary;
  final bool isThinking;
  final bool isNaturalQuestion;
  final String tone;
  final String length;
  final ValueChanged<String> onToneChanged;
  final ValueChanged<String> onLengthChanged;
  final VoidCallback onNotebookSave;
  final VoidCallback onContinueChat;
  final LegalSyllogismAnalysis? syllogismAnalysis;
  final LawAssistantDefenseInsight? defenseInsight;
  final VoidCallback? onSaveToJournal;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final docId = 'SYLLOGISM-${(query.hashCode % 9000 + 1000).abs()}';
    final analysis = syllogismAnalysis ??
        LegalSyllogismEngine.analyzeDispute(
          rawDisputeFacts: query.trim().isEmpty ? '一般民事權益爭議' : query.trim(),
        );

    return _ProtoCard(
      background: t.surface,
      borderColor:
          isNaturalQuestion ? t.accentBrass.withValues(alpha: 0.45) : t.borderStrong,
      padding: EdgeInsets.all(16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _AssistantReportHeader(
            docId: docId,
            isThinking: isThinking,
            isNaturalQuestion: isNaturalQuestion,
          ),
          SizedBox(height: 12.h),
          _DottedLine(
            height: 1,
            color: t.borderStrong,
            dashWidth: 4,
            dashSpace: 4,
          ),
          SizedBox(height: 14.h),
          if (isThinking)
            Padding(
              padding: EdgeInsets.symmetric(vertical: 18.h),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const _AssistantThinkingIndicator(),
                    SizedBox(height: 10.h),
                    Text(
                      '正在執行三段論法理涵攝與法源比對...',
                      style: _SearchText.bodyStrong(context).copyWith(
                        color: t.textSecondary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            )
          else ...[
            // 三段論雙重編碼結構（大前提法規範 ➔ 小前提爭點 ➔ 結論與行動建議）
            _SyllogismStepsFlow(
              analysis: analysis,
              summary: summary,
            ),

            // 小法助即時解方與自保防禦模組
            if (defenseInsight != null) ...[
              SizedBox(height: 14.h),
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(13.w),
                decoration: t.subtleBoxDecoration(
                  radius: 14.r,
                  fill: t.surfaceSubtle,
                  borderColor: t.borderStrong,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Wrap(
                      spacing: 8.w,
                      runSpacing: 6.h,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 8.w,
                            vertical: 3.h,
                          ),
                          decoration: BoxDecoration(
                            color: t.brandContainer,
                            borderRadius: BorderRadius.circular(6.r),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                PhosphorIconsFill.shieldCheck,
                                size: 13.sp,
                                color: t.brandOnContainer,
                              ),
                              SizedBox(width: 4.w),
                              Text(
                                '小法助即時解方',
                                style:
                                    _SearchText.captionStrong(context).copyWith(
                                  color: t.brandOnContainer,
                                  fontSize: 11.sp,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Text(
                          defenseInsight!.disputeCategory,
                          style: _SearchText.bodyStrong(context),
                        ),
                      ],
                    ),
                    if (defenseInsight!.statuteDeadline != null) ...[
                      SizedBox(height: 10.h),
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.symmetric(
                          horizontal: 10.w,
                          vertical: 8.h,
                        ),
                        decoration: BoxDecoration(
                          color: t.semanticUrgentContainer,
                          borderRadius: BorderRadius.circular(10.r),
                          border: Border.all(
                            color: t.semanticUrgent.withValues(alpha: 0.35),
                          ),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: EdgeInsets.only(top: 2.h),
                              child: Icon(
                                PhosphorIconsFill.clockCountdown,
                                size: 15.sp,
                                color: t.semanticUrgent,
                              ),
                            ),
                            SizedBox(width: 8.w),
                            Expanded(
                              child: Wrap(
                                spacing: 6.w,
                                runSpacing: 2.h,
                                crossAxisAlignment: WrapCrossAlignment.center,
                                children: [
                                  Text(
                                    '時效警示：${defenseInsight!.statuteDeadline!.title}',
                                    style: _SearchText.captionStrong(context)
                                        .copyWith(color: t.semanticUrgent),
                                  ),
                                  Container(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 6.w,
                                      vertical: 2.h,
                                    ),
                                    decoration: BoxDecoration(
                                      color: t.semanticUrgent
                                          .withValues(alpha: 0.14),
                                      borderRadius: BorderRadius.circular(5.r),
                                    ),
                                    child: Text(
                                      '${defenseInsight!.statuteDeadline!.durationDays} 天',
                                      style: _SearchText.metric(
                                        context,
                                        size: 11.sp,
                                        color: t.semanticUrgent,
                                      ),
                                    ),
                                  ),
                                  Text(
                                    '依據：${defenseInsight!.statuteDeadline!.legalBasis}',
                                    style: _SearchText.caption(context)
                                        .copyWith(color: t.textPrimary),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                    SizedBox(height: 10.h),
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(11.w),
                      decoration: BoxDecoration(
                        color: t.surface,
                        borderRadius: BorderRadius.circular(10.r),
                        border: Border.all(color: t.border),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                PhosphorIconsFill.quotes,
                                size: 14.sp,
                                color: t.accentBrass,
                              ),
                              SizedBox(width: 5.w),
                              Expanded(
                                child: Text(
                                  '談判自保防禦金句',
                                  style: _SearchText.captionStrong(context)
                                      .copyWith(color: t.brandPrimary),
                                ),
                              ),
                              InkWell(
                                onTap: () {
                                  Clipboard.setData(
                                    ClipboardData(
                                      text:
                                          defenseInsight!.tacticalGoldenPhrase,
                                    ),
                                  );
                                  CustomToast.show(context, '已複製談判自保防禦金句');
                                },
                                borderRadius: BorderRadius.circular(6.r),
                                child: Padding(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 6.w,
                                    vertical: 3.h,
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        PhosphorIconsRegular.copy,
                                        size: 13.sp,
                                        color: t.brandPrimary,
                                      ),
                                      SizedBox(width: 4.w),
                                      Text(
                                        '複製',
                                        style:
                                            _SearchText.captionStrong(context)
                                                .copyWith(
                                          color: t.brandPrimary,
                                          fontSize: 11.sp,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 6.h),
                          Text(
                            defenseInsight!.tacticalGoldenPhrase,
                            style: _SearchText.serifBody(context).copyWith(
                              fontSize: 13.sp,
                              height: 1.55,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (onSaveToJournal != null) ...[
                      SizedBox(height: 10.h),
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton.icon(
                          style: FilledButton.styleFrom(
                            backgroundColor: t.brandPrimaryStrong,
                            foregroundColor: const Color(0xFFFAF8F4),
                            minimumSize: const Size(double.infinity, 42),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10.r),
                              side: BorderSide(
                                color: t.accentBrass.withValues(alpha: 0.35),
                              ),
                            ),
                            padding: EdgeInsets.symmetric(
                              horizontal: 12.w,
                              vertical: 9.h,
                            ),
                          ),
                          icon: Icon(
                            PhosphorIconsRegular.folderSimplePlus,
                            size: 15.sp,
                            color: t.accentBrass,
                          ),
                          label: Text(
                            '建立「自救記事」進度追蹤',
                            style: TextStyle(
                              color: const Color(0xFFFAF8F4),
                              fontSize: 12.sp,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          onPressed: onSaveToJournal,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],

            SizedBox(height: 14.h),
            _AssistantCitationsRow(query: query),
            SizedBox(height: 14.h),
            Wrap(
              spacing: 6.w,
              runSpacing: 8.h,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                Text(
                  '語氣：',
                  style: _SearchText.captionStrong(context),
                ),
                _StyleChip(
                  label: '白話',
                  selected: tone == '白話',
                  onTap: () => onToneChanged('白話'),
                ),
                _StyleChip(
                  label: '專業',
                  selected: tone == '專業',
                  onTap: () => onToneChanged('專業'),
                ),
                SizedBox(width: 6.w),
                Text(
                  '篇幅：',
                  style: _SearchText.captionStrong(context),
                ),
                _StyleChip(
                  label: '精簡',
                  selected: length == '精簡',
                  onTap: () => onLengthChanged('精簡'),
                ),
                _StyleChip(
                  label: '詳細',
                  selected: length == '詳細',
                  onTap: () => onLengthChanged('詳細'),
                ),
              ],
            ),
            SizedBox(height: 14.h),
            LayoutBuilder(
              builder: (context, constraints) {
                final isCompact = constraints.maxWidth < 290;
                final saveBtn = OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: t.brandPrimary,
                    backgroundColor: t.surface,
                    minimumSize: const Size(0, 42),
                    side: BorderSide(color: t.borderStrong),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(11.r),
                    ),
                    padding:
                        EdgeInsets.symmetric(horizontal: 10.w, vertical: 9.h),
                  ),
                  icon: Icon(
                    PhosphorIconsRegular.bookmarkSimple,
                    size: 15.sp,
                    color: t.brandPrimary,
                  ),
                  label: Text(
                    '摘錄筆記',
                    style: _SearchText.captionStrong(context).copyWith(
                      color: t.brandPrimary,
                      fontSize: 12.sp,
                    ),
                  ),
                  onPressed: onNotebookSave,
                );

                final chatBtn = FilledButton.icon(
                  style: FilledButton.styleFrom(
                    backgroundColor: t.brandPrimaryStrong,
                    foregroundColor: const Color(0xFFFAF8F4),
                    minimumSize: const Size(0, 42),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(11.r),
                    ),
                    padding:
                        EdgeInsets.symmetric(horizontal: 10.w, vertical: 9.h),
                  ),
                  icon: Icon(
                    PhosphorIconsRegular.chatsCircle,
                    size: 15.sp,
                    color: t.accentBrass,
                  ),
                  label: Text(
                    '深入問診',
                    style: _SearchText.captionStrong(context).copyWith(
                      color: const Color(0xFFFAF8F4),
                      fontSize: 12.sp,
                    ),
                  ),
                  onPressed: onContinueChat,
                );

                if (isCompact) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      saveBtn,
                      SizedBox(height: 8.h),
                      chatBtn,
                    ],
                  );
                }
                return Row(
                  children: [
                    Expanded(child: saveBtn),
                    SizedBox(width: 8.w),
                    Expanded(child: chatBtn),
                  ],
                );
              },
            ),
          ],
        ],
      ),
    );
  }
}

class _SyllogismStepsFlow extends StatelessWidget {
  const _SyllogismStepsFlow({
    required this.analysis,
    required this.summary,
  });

  final LegalSyllogismAnalysis analysis;
  final String summary;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final primaryStatute = analysis.majorPremiseStatutes.isNotEmpty
        ? analysis.majorPremiseStatutes.first
        : null;
    final issues = analysis.identifiedIssues.take(2).toList(growable: false);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 01 大前提：法規範基礎（宋體權威條文）
        Container(
          width: double.infinity,
          padding: EdgeInsets.all(12.w),
          decoration: BoxDecoration(
            color: t.surfaceSubtle,
            borderRadius: BorderRadius.circular(12.r),
            border: Border(
              left: BorderSide(color: t.brandPrimary, width: 3.w),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  _SyllogismStepBadge(number: '01', label: '大前提・法規範基礎'),
                ],
              ),
              SizedBox(height: 7.h),
              if (primaryStatute != null) ...[
                Text(
                  primaryStatute.fullCitation,
                  style: _SearchText.serifTileTitle(context).copyWith(
                    color: t.brandPrimary,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  primaryStatute.officialText,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: _SearchText.serifBody(context).copyWith(
                    fontSize: 13.sp,
                    height: 1.58,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  '白話要旨：${primaryStatute.plainSummary}',
                  style: _SearchText.body(context),
                ),
              ] else
                Text(
                  '依現行民刑法與特別法相關權利保障規範進行涵攝。',
                  style: _SearchText.serifBody(context),
                ),
            ],
          ),
        ),
        Padding(
          padding: EdgeInsets.symmetric(vertical: 4.h, horizontal: 14.w),
          child: Icon(
            PhosphorIconsRegular.arrowDown,
            size: 14.sp,
            color: t.accentBrass,
          ),
        ),
        // 02 小前提：爭點與構成要件檢核（黑體行動語氣）
        Container(
          width: double.infinity,
          padding: EdgeInsets.all(12.w),
          decoration: BoxDecoration(
            color: t.surfaceSubtle,
            borderRadius: BorderRadius.circular(12.r),
            border: Border(
              left: BorderSide(color: t.accentBrass, width: 3.w),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  _SyllogismStepBadge(
                    number: '02',
                    label: '小前提・爭點與要件涵攝',
                    isBrass: true,
                  ),
                ],
              ),
              SizedBox(height: 7.h),
              if (issues.isNotEmpty)
                for (final issue in issues)
                  Padding(
                    padding: EdgeInsets.only(bottom: 4.h),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: EdgeInsets.only(top: 3.h),
                          child: Icon(
                            PhosphorIconsFill.caretRight,
                            size: 12.sp,
                            color: t.accentBrass,
                          ),
                        ),
                        SizedBox(width: 6.w),
                        Expanded(
                          child: Text(
                            issue,
                            style: _SearchText.bodyStrong(context),
                          ),
                        ),
                      ],
                    ),
                  )
              else
                Text(
                  analysis.summaryOfFacts,
                  style: _SearchText.bodyStrong(context),
                ),
            ],
          ),
        ),
        Padding(
          padding: EdgeInsets.symmetric(vertical: 4.h, horizontal: 14.w),
          child: Icon(
            PhosphorIconsRegular.arrowDown,
            size: 14.sp,
            color: t.brandPrimary,
          ),
        ),
        // 03 結論與行動建議
        Container(
          width: double.infinity,
          padding: EdgeInsets.all(12.w),
          decoration: BoxDecoration(
            color: t.brandContainer.withValues(alpha: t.isDark ? 0.5 : 0.65),
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(
              color: t.brandPrimary.withValues(alpha: 0.28),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  _SyllogismStepBadge(number: '03', label: '結論與行動建議'),
                ],
              ),
              SizedBox(height: 7.h),
              Text(
                summary.trim().isNotEmpty ? summary : analysis.conclusionRemedy,
                style: _SearchText.bodyStrong(context).copyWith(
                  height: 1.58,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _SyllogismStepBadge extends StatelessWidget {
  const _SyllogismStepBadge({
    required this.number,
    required this.label,
    this.isBrass = false,
  });

  final String number;
  final String label;
  final bool isBrass;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final fg = isBrass ? t.accentOnBrassContainer : t.brandOnContainer;
    final bg = isBrass ? t.accentBrassContainer : t.brandContainer;
    return Flexible(
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(6.r),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              number,
              style: _SearchText.metric(
                context,
                size: 11.sp,
                color: fg,
              ),
            ),
            SizedBox(width: 5.w),
            Flexible(
              child: Text(
                label,
                style: _SearchText.captionStrong(context).copyWith(
                  color: fg,
                  fontSize: 11.sp,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AssistantCitationsRow extends StatelessWidget {
  const _AssistantCitationsRow({required this.query});

  final String query;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final List<Map<String, String>> citations = [];
    final matchingStatutes =
        TaiwanStatuteCanon.findBestMatchingStatutes(query, limit: 2);
    for (int i = 0; i < matchingStatutes.length; i++) {
      final s = matchingStatutes[i];
      final category = s.disputeCategories.isNotEmpty
          ? s.disputeCategories.first
          : '規範要旨';
      final title = '${s.fullCitation} ($category)';
      citations.add({'id': '[${i + 1}]', 'title': title, 'tag': '法規'});
    }

    final domain = TaiwanStatuteCanon.detectDisputeDomain(query);
    final officialSource = switch (domain) {
      TaiwanDisputeDomain.rentalAndHousing => {
          'id': '[${citations.length + 1}]',
          'title': '內政部地政司 租賃住宅專區',
          'tag': '官方',
        },
      TaiwanDisputeDomain.laborAndEmployment => {
          'id': '[${citations.length + 1}]',
          'title': '勞動部 勞工權益保障指南',
          'tag': '官方',
        },
      TaiwanDisputeDomain.trafficAndTort => {
          'id': '[${citations.length + 1}]',
          'title': '警政署 道路交通事故處理規範',
          'tag': '官方',
        },
      TaiwanDisputeDomain.consumerProtection => {
          'id': '[${citations.length + 1}]',
          'title': '行政院消保處 消費申訴網',
          'tag': '官方',
        },
      TaiwanDisputeDomain.fraudAndCybercrime => {
          'id': '[${citations.length + 1}]',
          'title': '警政署 165 全民防騙網',
          'tag': '官方',
        },
      _ => {
          'id': '[${citations.length + 1}]',
          'title': '司法院法規檢索系統',
          'tag': '官方',
        },
    };
    citations.add(officialSource);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              PhosphorIconsRegular.bookOpenText,
              color: t.brandPrimary,
              size: 14.sp,
            ),
            SizedBox(width: 5.w),
            Text(
              '參考法源引用索引',
              style: _SearchText.captionStrong(context).copyWith(
                color: t.brandPrimary,
              ),
            ),
          ],
        ),
        SizedBox(height: 6.h),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          child: Row(
            children: citations.map((citation) {
              return Padding(
                padding: EdgeInsets.only(right: 8.w),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () {
                      Clipboard.setData(
                        ClipboardData(text: citation['title']!),
                      );
                      CustomToast.show(
                        context,
                        '已複製引用來源：${citation['title']}',
                      );
                    },
                    borderRadius: BorderRadius.circular(8.r),
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 9.w,
                        vertical: 5.h,
                      ),
                      decoration: BoxDecoration(
                        color: t.surfaceSubtle,
                        borderRadius: BorderRadius.circular(8.r),
                        border: Border.all(color: t.border),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            citation['id']!,
                            style: _SearchText.metric(
                              context,
                              size: 11.sp,
                              color: t.brandPrimary,
                            ),
                          ),
                          SizedBox(width: 5.w),
                          Text(
                            citation['title']!,
                            style: _SearchText.caption(context).copyWith(
                              color: t.textPrimary,
                              fontSize: 11.sp,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}

class _StyleChip extends StatelessWidget {
  const _StyleChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999.r),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 11.w, vertical: 5.h),
          decoration: BoxDecoration(
            color: selected ? t.brandPrimaryStrong : t.surface,
            border: Border.all(
              color: selected ? t.brandPrimaryStrong : t.border,
            ),
            borderRadius: BorderRadius.circular(999.r),
          ),
          child: Text(
            label,
            style: _SearchText.captionStrong(context).copyWith(
              color: selected ? const Color(0xFFFAF8F4) : t.textSecondary,
              fontSize: 11.5.sp,
            ),
          ),
        ),
      ),
    );
  }
}
