part of '../case_dossier_detail_page.dart';

// 這個 part 檔集中收納案件詳情頁的 Timeline UI。
// 時間軸資料來源、mock helper 與 repository 載入仍保留在 case_dossier_detail_page.dart。

extension _CaseDossierTimelineWidgets on _CaseDossierDetailPageState {
  Widget _buildCombinedTimelineTab(BuildContext context) {
    // 1. Gather all timeline nodes and trial steps without overwriting same-date entries
    final List<_CombinedTimelineNode> allNodes = [];

    for (final item in book.timeline) {
      allNodes.add(
        _CombinedTimelineNode(
          date: item.dateLabel,
          title: item.title,
          description: item.description,
          type: 'event',
        ),
      );
    }

    final trialSteps = _getTrialSteps(book.id);
    for (final step in trialSteps) {
      allNodes.add(
        _CombinedTimelineNode(
          date: step.date,
          title: '${step.stage} · ${step.courtName}',
          description: step.outcome,
          type: 'trial',
          trialStep: step,
        ),
      );
    }

    // 2. Sort by date ascending
    allNodes.sort((a, b) => a.date.compareTo(b.date));

    final eventCount = allNodes.where((n) => n.type == 'event').length;
    final trialCount = allNodes.where((n) => n.type == 'trial').length;

    final filteredNodes = allNodes.where((n) {
      if (_timelineFilter == 'event') return n.type == 'event';
      if (_timelineFilter == 'trial') return n.type == 'trial';
      return true;
    }).toList();

    // 3. Handle expand/collapse logic
    final displayNodes = _isTimelineExpanded
        ? filteredNodes
        : filteredNodes.take(4).toList();

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
            accentColor: CaseLibraryColors.primaryGreen,
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
                      color: CaseLibraryColors.textPrimary,
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
                    child: CaseLibrarySvgIcon(
                      CaseLibrarySvgIcons.gavel,
                      size: 22.w,
                      color: CaseLibraryColors.primaryGreen,
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 22.h),
        ],

        Row(
          children: [
            Expanded(
              child: Text(
                '完整事件與訴訟脈絡',
                style: LightTextStyles.sectionTitle(context).copyWith(
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
            Text(
              '共 ${filteredNodes.length} 筆',
              style: TextStyle(
                fontSize: 11.sp,
                fontWeight: FontWeight.w700,
                color: CaseLibraryColors.textSecondary,
              ),
            ),
          ],
        ),
        SizedBox(height: 10.h),

        // Segmented Track Filter Pills
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _buildTimelineFilterChip(
                label: '全部 (${allNodes.length})',
                value: 'all',
              ),
              SizedBox(width: 8.w),
              _buildTimelineFilterChip(
                label: '社會事件 ($eventCount)',
                value: 'event',
                dotColor: CaseLibraryColors.primaryGreen,
              ),
              SizedBox(width: 8.w),
              _buildTimelineFilterChip(
                label: '司法審理 ($trialCount)',
                value: 'trial',
                dotColor: CaseLibraryColors.accentGold,
              ),
            ],
          ),
        ),
        SizedBox(height: 14.h),

        if (displayNodes.isEmpty)
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(color: CaseLibraryColors.borderLight),
            ),
            child: Text(
              '此分類目前尚無紀錄。',
              style: LightTextStyles.bodySmall(context),
            ),
          )
        else
          // Dual-Track Vertical Timeline Cards
          Column(
            children: List.generate(displayNodes.length, (index) {
              final node = displayNodes[index];
              final isLast = index == displayNodes.length - 1;
              final isTrial = node.type == 'trial';
              final trackColor = isTrial
                  ? CaseLibraryColors.accentGold
                  : CaseLibraryColors.primaryGreen;
              final stageLabel =
                  isTrial ? node.trialStep!.stage : '案發經過';

              return IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Left Vertical Rail + Track Dot
                    SizedBox(
                      width: 20.w,
                      child: Column(
                        children: [
                          SizedBox(height: 14.h),
                          Container(
                            width: 11.w,
                            height: 11.w,
                            decoration: BoxDecoration(
                              color: trackColor,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: CaseLibraryColors.bgCream,
                                width: 2,
                              ),
                            ),
                          ),
                          if (!isLast)
                            Expanded(
                              child: Container(
                                width: 2.w,
                                margin: EdgeInsets.symmetric(vertical: 4.h),
                                color: trackColor.withValues(alpha: 0.25),
                              ),
                            ),
                        ],
                      ),
                    ),
                    SizedBox(width: 8.w),
                    // Right Structured Card
                    Expanded(
                      child: Padding(
                        padding: EdgeInsets.only(bottom: 12.h),
                        child: Container(
                          padding: EdgeInsets.all(14.w),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(14.r),
                            border: Border.all(
                              color: isTrial
                                  ? CaseLibraryColors.accentGold
                                      .withValues(alpha: 0.35)
                                  : CaseLibraryColors.borderLight,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.025),
                                blurRadius: 8,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: isTrial
                              ? _buildTrialTimelineCardContent(
                                  context,
                                  node.date,
                                  stageLabel,
                                  node.trialStep!,
                                )
                              : _buildEventTimelineCardContent(
                                  context,
                                  node.date,
                                  stageLabel,
                                  node.title,
                                  node.description,
                                ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }),
          ),

        // Expand / Collapse Timeline button & Interactive Timeline Page Entry
        if (filteredNodes.length > 4) ...[
          Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                GestureDetector(
                  onTap: () {
                    _setTimelineExpanded(!_isTimelineExpanded);
                  },
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _isTimelineExpanded ? '收合時間軸' : '展開時間軸',
                        style: TextStyle(
                          fontSize: 11.sp,
                          color: CaseLibraryColors.accentGold,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      SizedBox(width: 4.w),
                      CaseLibrarySvgIcon(
                        _isTimelineExpanded
                            ? CaseLibrarySvgIcons.chevronUp
                            : CaseLibrarySvgIcons.chevronDown,
                        size: 13.sp,
                        color: CaseLibraryColors.accentGold,
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 16.w),
                Container(
                  width: 1.w,
                  height: 12.h,
                  color: Colors.grey.withValues(alpha: 0.3),
                ),
                SizedBox(width: 16.w),
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            CaseTimelineDetailPage(book: book),
                      ),
                    );
                  },
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '互動脈絡年表 (行事曆同步)',
                        style: TextStyle(
                          fontSize: 11.sp,
                          color: CaseLibraryColors.primaryGreen,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      SizedBox(width: 4.w),
                      Icon(
                        Icons.open_in_new_rounded,
                        size: 13.sp,
                        color: CaseLibraryColors.primaryGreen,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 24.h),
        ],
      ],
    );
  }

  Widget _buildTimelineFilterChip({
    required String label,
    required String value,
    Color? dotColor,
  }) {
    final isSelected = _timelineFilter == value;
    return InkWell(
      onTap: () => _setTimelineFilter(value),
      borderRadius: BorderRadius.circular(999),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
        decoration: BoxDecoration(
          color: isSelected ? CaseLibraryColors.primaryGreen : Colors.white,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: isSelected
                ? CaseLibraryColors.primaryGreen
                : CaseLibraryColors.borderLight,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (dotColor != null) ...[
              Container(
                width: 7.w,
                height: 7.w,
                decoration: BoxDecoration(
                  color: isSelected ? Colors.white : dotColor,
                  shape: BoxShape.circle,
                ),
              ),
              SizedBox(width: 6.w),
            ],
            Text(
              label,
              style: TextStyle(
                fontSize: 11.sp,
                fontWeight: FontWeight.w700,
                color: isSelected ? Colors.white : CaseLibraryColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEventTimelineCardContent(
    BuildContext context,
    String date,
    String stageLabel,
    String title,
    String description,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
              decoration: BoxDecoration(
                color: CaseLibraryColors.primaryGreen.withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(6.r),
              ),
              child: Text(
                stageLabel,
                style: TextStyle(
                  fontSize: 10.sp,
                  fontWeight: FontWeight.w800,
                  color: CaseLibraryColors.primaryGreen,
                ),
              ),
            ),
            SizedBox(width: 8.w),
            Expanded(
              child: Text(
                date,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 11.5.sp,
                  fontWeight: FontWeight.w800,
                  color: CaseLibraryColors.textSecondary,
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 8.h),
        Text(
          title,
          style: TextStyle(
            fontSize: 13.5.sp,
            fontWeight: FontWeight.w800,
            color: CaseLibraryColors.primaryGreen,
            height: 1.35,
          ),
        ),
        if (description.trim().isNotEmpty) ...[
          SizedBox(height: 5.h),
          Text(
            description,
            style: LightTextStyles.bodySmall(context).copyWith(
              fontSize: 12.sp,
              height: 1.5,
              color: CaseLibraryColors.textSecondary,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildTrialTimelineCardContent(
    BuildContext context,
    String date,
    String stageLabel,
    _TrialStep step,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
              decoration: BoxDecoration(
                color: CaseLibraryColors.accentGold.withValues(alpha: 0.16),
                borderRadius: BorderRadius.circular(6.r),
              ),
              child: Text(
                stageLabel,
                style: TextStyle(
                  fontSize: 10.sp,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF9E7B2D),
                ),
              ),
            ),
            SizedBox(width: 8.w),
            Expanded(
              child: Text(
                date,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 11.5.sp,
                  fontWeight: FontWeight.w800,
                  color: CaseLibraryColors.textSecondary,
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 8.h),
        Text(
          step.courtName,
          style: TextStyle(
            fontSize: 13.5.sp,
            fontWeight: FontWeight.w800,
            color: CaseLibraryColors.primaryGreen,
          ),
        ),
        if (step.caseNumber.trim().isNotEmpty) ...[
          SizedBox(height: 3.h),
          Text(
            step.caseNumber,
            style: TextStyle(
              fontSize: 11.sp,
              color: CaseLibraryColors.textSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
        SizedBox(height: 6.h),
        Text(
          step.outcome,
          style: TextStyle(
            fontSize: 12.sp,
            color: const Color(0xFF2E7D32),
            fontWeight: FontWeight.w800,
            height: 1.45,
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
                  color: CaseLibraryColors.accentGold,
                  fontWeight: FontWeight.w800,
                ),
              ),
              SizedBox(width: 4.w),
              CaseLibrarySvgIcon(
                CaseLibrarySvgIcons.article,
                size: 13.sp,
                color: CaseLibraryColors.accentGold,
              ),
            ],
          ),
        ),
      ],
    );
  }

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
                          color: CaseLibraryColors.accentGold,
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
                          color: CaseLibraryColors.primaryGreen,
                          shape: BoxShape.circle,
                          border: Border.all(
                              color: CaseLibraryColors.bgCream, width: 2),
                        ),
                      ),
                      if (!isLast)
                        Expanded(
                          child: Container(
                            width: 1.5.w,
                            color: CaseLibraryColors.primaryGreen
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
                              color: CaseLibraryColors.primaryGreen,
                            ),
                          ),
                          SizedBox(height: 4.h),
                          Text(
                            node.description,
                            style: LightTextStyles.bodySmall(context).copyWith(
                              fontSize: 11.5.sp,
                              height: 1.45,
                              color: CaseLibraryColors.textSecondary,
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

        // Expand / Collapse Timeline button & Interactive Timeline Page Entry
        if (timelineNodes.length > 3) ...[
          Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                GestureDetector(
                  onTap: () {
                    _setTimelineExpanded(!_isTimelineExpanded);
                  },
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _isTimelineExpanded ? '收合時間軸' : '展開時間軸',
                        style: TextStyle(
                          fontSize: 11.sp,
                          color: CaseLibraryColors.accentGold,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      SizedBox(width: 4.w),
                      CaseLibrarySvgIcon(
                        _isTimelineExpanded
                            ? CaseLibrarySvgIcons.chevronUp
                            : CaseLibrarySvgIcons.chevronDown,
                        size: 13.sp,
                        color: CaseLibraryColors.accentGold,
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 16.w),
                Container(
                  width: 1.w,
                  height: 12.h,
                  color: Colors.grey.withValues(alpha: 0.3),
                ),
                SizedBox(width: 16.w),
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            CaseTimelineDetailPage(book: book),
                      ),
                    );
                  },
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '互動脈絡年表 (行事曆同步)',
                        style: TextStyle(
                          fontSize: 11.sp,
                          color: CaseLibraryColors.primaryGreen,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      SizedBox(width: 4.w),
                      Icon(
                        Icons.open_in_new_rounded,
                        size: 13.sp,
                        color: CaseLibraryColors.primaryGreen,
                      ),
                    ],
                  ),
                ),
              ],
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
            accentColor: CaseLibraryColors.primaryGreen,
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
                      color: CaseLibraryColors.textPrimary,
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
                    child: CaseLibrarySvgIcon(
                      CaseLibrarySvgIcons.gavel,
                      size: 22.w,
                      color: CaseLibraryColors.primaryGreen,
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

  Widget _buildLitigationTimeline(BuildContext context) {
    final steps = _getTrialSteps(book.id);

    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: CaseLibraryColors.bgWhite,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: CaseLibraryColors.borderLight),
        boxShadow: [CaseLibraryShadows.softShadow],
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
                            ? CaseLibraryColors.accentGold
                            : CaseLibraryColors.primaryGreen
                                .withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isLast
                              ? CaseLibraryColors.bgWhite
                              : CaseLibraryColors.primaryGreen,
                          width: 3.w,
                        ),
                      ),
                    ),
                    if (!isLast)
                      Expanded(
                        child: Container(
                          width: 2.w,
                          color: CaseLibraryColors.primaryGreen
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
                                    ? CaseLibraryColors.accentGold
                                        .withValues(alpha: 0.15)
                                    : CaseLibraryColors.primaryGreen
                                        .withValues(alpha: 0.08),
                                borderRadius: BorderRadius.circular(4.r),
                              ),
                              child: Text(
                                step.stage,
                                style: TextStyle(
                                  fontSize: 9.sp,
                                  fontWeight: FontWeight.bold,
                                  color: isLast
                                      ? CaseLibraryColors.accentGold
                                      : CaseLibraryColors.primaryGreen,
                                ),
                              ),
                            ),
                            Text(
                              step.date,
                              style: TextStyle(
                                fontSize: 10.sp,
                                color: CaseLibraryColors.textMuted,
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
                            color: CaseLibraryColors.primaryGreen,
                          ),
                        ),
                        SizedBox(height: 2.h),
                        Text(
                          step.caseNumber,
                          style: TextStyle(
                            fontSize: 10.5.sp,
                            color: CaseLibraryColors.textSecondary,
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
                                : CaseLibraryColors.textPrimary,
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
                                  color: CaseLibraryColors.accentGold,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              SizedBox(width: 4.w),
                              CaseLibrarySvgIcon(
                                CaseLibrarySvgIcons.article,
                                size: 13.sp,
                                color: CaseLibraryColors.accentGold,
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
}
