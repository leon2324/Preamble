part of '../following_page.dart';

class _CollectionsTabView extends StatelessWidget {
  const _CollectionsTabView({
    required this.items,
    required this.selectedFilterIndex,
    required this.onFilterChanged,
    required this.onOpenItem,
    required this.onUnsaveItem,
    required this.onExploreCases,
    required this.onExploreStatutes,
    required this.onLoadSamples,
  });

  final List<_ResolvedSavedItem> items;
  final int selectedFilterIndex;
  final ValueChanged<int> onFilterChanged;
  final ValueChanged<_ResolvedSavedItem> onOpenItem;
  final ValueChanged<_ResolvedSavedItem> onUnsaveItem;
  final VoidCallback onExploreCases;
  final VoidCallback onExploreStatutes;
  final VoidCallback onLoadSamples;

  static const List<String> _filters = ['全部', '案件卷宗', '常用法規', '避坑指引'];

  @override
  Widget build(BuildContext context) {
    final filtered = selectedFilterIndex == 0
        ? items
        : items
            .where((e) => e.categoryLabel == _filters[selectedFilterIndex])
            .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _FollowFilterChips(
          labels: _filters,
          selectedIndex: selectedFilterIndex,
          onChanged: onFilterChanged,
        ),
        SizedBox(height: 16.h),
        if (items.isEmpty)
          _QuietEmptyCard(
            icon: PhosphorIconsRegular.bookmarks,
            title: '尚無典藏案卷或常用法規',
            description:
                '閱讀判決案卷、檢索全國法規或瀏覽生活避坑指引時，點擊書籤圖示即可同步收錄至此處。',
            primaryLabel: '探索案件圖書館',
            onPrimaryTap: onExploreCases,
            secondaryLabel: '查閱全國法規庫',
            onSecondaryTap: onExploreStatutes,
            helperLabel: '載入範例收藏體驗',
            onHelperTap: onLoadSamples,
          )
        else if (filtered.isEmpty)
          _QuietEmptyCard(
            icon: PhosphorIconsRegular.funnel,
            title: '此分類目前沒有收藏項目',
            description: '切換至「全部」檢視其他已典藏內容，或前往法規與案件庫新增收藏。',
            primaryLabel: '查看全部收藏',
            onPrimaryTap: () => onFilterChanged(0),
          )
        else
          for (final item in filtered) ...[
            _SavedItemCard(
              item: item,
              onTap: () => onOpenItem(item),
              onUnsave: () => onUnsaveItem(item),
            ),
            SizedBox(height: 12.h),
          ],
      ],
    );
  }
}

class _UpdatesTabView extends StatelessWidget {
  const _UpdatesTabView({
    required this.trackedItems,
    required this.recommendedStatutes,
    required this.isStatuteFollowed,
    required this.selectedFilterIndex,
    required this.onFilterChanged,
    required this.onOpenTracked,
    required this.onUnfollowTracked,
    required this.onToggleRecommendedStatute,
    required this.onOpenRecommendedStatute,
  });

  final List<_ResolvedTrackedItem> trackedItems;
  final List<_StatuteWatchSpec> recommendedStatutes;
  final bool Function(String statuteId) isStatuteFollowed;
  final int selectedFilterIndex;
  final ValueChanged<int> onFilterChanged;
  final ValueChanged<_ResolvedTrackedItem> onOpenTracked;
  final ValueChanged<_ResolvedTrackedItem> onUnfollowTracked;
  final ValueChanged<_StatuteWatchSpec> onToggleRecommendedStatute;
  final ValueChanged<_StatuteWatchSpec> onOpenRecommendedStatute;

  static const List<String> _filters = ['全部', '法規異動', '案件進度', '議題追蹤'];

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final filtered = selectedFilterIndex == 0
        ? trackedItems
        : trackedItems
            .where((e) => e.categoryLabel == _filters[selectedFilterIndex])
            .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _FollowFilterChips(
          labels: _filters,
          selectedIndex: selectedFilterIndex,
          onChanged: onFilterChanged,
        ),
        SizedBox(height: 16.h),
        Row(
          children: [
            Icon(
              PhosphorIconsRegular.bellRinging,
              size: 17.sp,
              color: t.brandPrimary,
            ),
            SizedBox(width: 6.w),
            Text(
              '我的追蹤清單（${filtered.length}）',
              style: t.serifTitle(size: 16.sp),
            ),
          ],
        ),
        SizedBox(height: 10.h),
        if (trackedItems.isEmpty)
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(18.w),
            decoration: t.subtleBoxDecoration(radius: 20.r),
            child: Row(
              children: [
                Icon(
                  PhosphorIconsRegular.gitDiff,
                  size: 22.sp,
                  color: t.brandPrimary,
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Text(
                    '目前尚未加入追蹤項目。您可從下方「推薦追蹤法規」一鍵開啟修法監控，統計將與個人中心即時同步。',
                    style: t.sansBody(size: 12.5.sp, color: t.textSecondary),
                  ),
                ),
              ],
            ),
          )
        else if (filtered.isEmpty)
          _QuietEmptyCard(
            icon: PhosphorIconsRegular.funnel,
            title: '此分類尚無追蹤項目',
            description: '切換回「全部」檢視所有已追蹤法規與案件。',
            primaryLabel: '查看全部追蹤',
            onPrimaryTap: () => onFilterChanged(0),
          )
        else
          for (final item in filtered) ...[
            _TrackedUpdateCard(
              item: item,
              onTap: () => onOpenTracked(item),
              onUnfollow: () => onUnfollowTracked(item),
            ),
            SizedBox(height: 12.h),
          ],
        SizedBox(height: 22.h),
        Row(
          children: [
            Icon(
              PhosphorIconsRegular.sparkle,
              size: 17.sp,
              color: t.accentBrass,
            ),
            SizedBox(width: 6.w),
            Expanded(
              child: Text(
                '推薦追蹤法規',
                style: t.serifTitle(size: 16.sp),
              ),
            ),
            Text(
              '官方修法焦點',
              style: t.sansBody(size: 11.5.sp, color: t.textMuted),
            ),
          ],
        ),
        SizedBox(height: 10.h),
        for (final spec in recommendedStatutes) ...[
          _RecommendedStatuteCard(
            spec: spec,
            isFollowed: isStatuteFollowed(spec.statuteId),
            onToggleFollow: () => onToggleRecommendedStatute(spec),
            onOpenStatute: () => onOpenRecommendedStatute(spec),
          ),
          SizedBox(height: 12.h),
        ],
      ],
    );
  }
}

class _NotesTabView extends StatelessWidget {
  const _NotesTabView({
    required this.notes,
    required this.selectedFilterIndex,
    required this.onFilterChanged,
    required this.onCreateNote,
    required this.onOpenNote,
    required this.onEditNote,
    required this.onDeleteNote,
    required this.onLoadSampleNotes,
  });

  final List<_ResolvedNoteEntry> notes;
  final int selectedFilterIndex;
  final ValueChanged<int> onFilterChanged;
  final VoidCallback onCreateNote;
  final ValueChanged<_ResolvedNoteEntry> onOpenNote;
  final ValueChanged<_ResolvedNoteEntry> onEditNote;
  final ValueChanged<_ResolvedNoteEntry> onDeleteNote;
  final VoidCallback onLoadSampleNotes;

  /// 精準對應 5 大分類：修正舊版選擇「一般」卻誤用 `contains('租屋')` 的篩選錯誤。
  static const List<String> _filters = ['全部', '租屋', '勞動', '消費', '一般'];

  @override
  Widget build(BuildContext context) {
    final activeCategory = _filters[selectedFilterIndex];
    final filtered = selectedFilterIndex == 0
        ? notes
        : notes.where((n) => n.category == activeCategory).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _FollowFilterChips(
          labels: _filters,
          selectedIndex: selectedFilterIndex,
          onChanged: onFilterChanged,
        ),
        SizedBox(height: 16.h),
        if (notes.isEmpty)
          _QuietEmptyCard(
            icon: PhosphorIconsRegular.notebook,
            title: '尚無個人法務筆記',
            description:
                '隨時記錄生活契約爭點、退租點交清單、工時證據或案卷讀後心得，所有筆記安全保存在此裝置。',
            primaryLabel: '新增第一則筆記',
            onPrimaryTap: onCreateNote,
            helperLabel: '載入範例筆記體驗',
            onHelperTap: onLoadSampleNotes,
          )
        else if (filtered.isEmpty)
          _QuietEmptyCard(
            icon: PhosphorIconsRegular.notebook,
            title: '「$activeCategory」分類尚無筆記',
            description: '點擊右上角「新增筆記」建立此領域備忘，或切換至「全部」檢視所有筆記。',
            primaryLabel: '新增$activeCategory筆記',
            onPrimaryTap: onCreateNote,
            secondaryLabel: '查看全部筆記',
            onSecondaryTap: () => onFilterChanged(0),
          )
        else
          for (final entry in filtered) ...[
            _LawNoteCard(
              entry: entry,
              onTap: () => onOpenNote(entry),
              onEdit: () => onEditNote(entry),
              onDelete: () => onDeleteNote(entry),
            ),
            SizedBox(height: 12.h),
          ],
      ],
    );
  }
}

class _DraftsTabView extends StatelessWidget {
  const _DraftsTabView({
    required this.drafts,
    required this.selectedFilterIndex,
    required this.onFilterChanged,
    required this.onOpenDraft,
    required this.onDeleteDraft,
    required this.onCreateQuickDraft,
  });

  final List<DocumentDraft> drafts;
  final int selectedFilterIndex;
  final ValueChanged<int> onFilterChanged;
  final ValueChanged<DocumentDraft> onOpenDraft;
  final ValueChanged<DocumentDraft> onDeleteDraft;
  final VoidCallback onCreateQuickDraft;

  static const List<String> _filters = ['全部', '協商草稿', '存證信函', '其他'];

  String _tagForType(DocumentTemplateType type) {
    switch (type) {
      case DocumentTemplateType.depositDemand:
        return '存證信函';
      case DocumentTemplateType.rentalDepositNegotiation:
      case DocumentTemplateType.laborDisputeMessage:
        return '協商草稿';
      case DocumentTemplateType.carAccidentChecklist:
      case DocumentTemplateType.consumerComplaint:
      case DocumentTemplateType.dynamicCustom:
        return '其他';
    }
  }

  String _formatTime(DateTime dt, String source) {
    String two(int v) => v.toString().padLeft(2, '0');
    return '${dt.year}/${two(dt.month)}/${two(dt.day)} ${two(dt.hour)}:${two(dt.minute)} · $source';
  }

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final filtered = selectedFilterIndex == 0
        ? drafts
        : drafts
            .where(
              (d) => _tagForType(d.templateType) == _filters[selectedFilterIndex],
            )
            .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _FollowFilterChips(
          labels: _filters,
          selectedIndex: selectedFilterIndex,
          onChanged: onFilterChanged,
        ),
        SizedBox(height: 12.h),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
          decoration: t.subtleBoxDecoration(radius: 14.r),
          child: Row(
            children: [
              Icon(
                PhosphorIconsRegular.info,
                size: 16.sp,
                color: t.brandPrimary,
              ),
              SizedBox(width: 8.w),
              Expanded(
                child: Text(
                  '書狀草稿僅供事前溝通與證據整理參考；正式寄發前建議委請執業律師審閱。',
                  style: t.sansBody(size: 12.sp, color: t.textSecondary),
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 14.h),
        if (filtered.isEmpty)
          _QuietEmptyCard(
            icon: PhosphorIconsRegular.fileText,
            title: '目前尚無此類別書狀草稿',
            description: '可快速建立一份「退租押金返還協商草稿」預覽正式排版與匯出流程。',
            primaryLabel: '建立範例協商草稿',
            onPrimaryTap: onCreateQuickDraft,
          )
        else ...[
          for (final draft in filtered) ...[
            _DocumentDraftCard(
              draft: draft,
              tagLabel: _tagForType(draft.templateType),
              timeLabel: _formatTime(draft.createdAt, draft.sourceLabel),
              onTap: () => onOpenDraft(draft),
              onDelete: () => onDeleteDraft(draft),
            ),
            SizedBox(height: 12.h),
          ],
          SizedBox(height: 6.h),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: onCreateQuickDraft,
              style: OutlinedButton.styleFrom(
                foregroundColor: t.brandPrimary,
                side: BorderSide(color: t.borderStrong),
                padding: EdgeInsets.symmetric(vertical: 12.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14.r),
                ),
              ),
              icon: Icon(PhosphorIconsRegular.plus, size: 16.sp),
              label: const Text('新增退租協商通知草稿'),
            ),
          ),
        ],
      ],
    );
  }
}

class _QuestionsTabView extends StatelessWidget {
  const _QuestionsTabView({
    required this.appState,
    required this.prompts,
    required this.onUpgradePro,
    required this.onClearHistory,
    required this.onRestoreHistory,
  });

  final PreambleState appState;
  final List<_PromptRecord> prompts;
  final VoidCallback onUpgradePro;
  final VoidCallback onClearHistory;
  final VoidCallback onRestoreHistory;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final isPro = appState.subscriptionService.isProOrHigher;
    final quota = appState.subscriptionService.remainingAiQuota;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: EdgeInsets.all(16.w),
          decoration: t.cardDecoration(
            radius: 20.r,
            fill: isPro ? t.accentBrassContainer : t.surface,
            borderColor: isPro ? t.accentBrass : t.border,
          ),
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.all(10.w),
                decoration: BoxDecoration(
                  color: isPro ? t.brandPrimaryStrong : t.brandContainer,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isPro
                      ? PhosphorIconsFill.crown
                      : PhosphorIconsRegular.scales,
                  size: 20.sp,
                  color: isPro ? t.accentBrass : t.brandPrimary,
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isPro ? 'PRO 專業會員・無限次 AI 法律問診' : '今日小法助問診剩餘額度：$quota 次',
                      style: t.sansTitle(
                        size: 14.sp,
                        color:
                            isPro ? t.accentOnBrassContainer : t.textPrimary,
                      ),
                    ),
                    SizedBox(height: 3.h),
                    Text(
                      isPro
                          ? '已解除每日提問上限，可隨時於底部「問診」分頁深度推演案情。'
                          : '免費方案每日提供基礎問診額度，升級 PRO 解鎖無限次攻防推演。',
                      style: t.sansBody(
                        size: 12.sp,
                        color: isPro
                            ? t.accentOnBrassContainer.withValues(alpha: 0.85)
                            : t.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              if (!isPro) ...[
                SizedBox(width: 8.w),
                TextButton(
                  onPressed: onUpgradePro,
                  child: Text(
                    '升級',
                    style: t.sansBody(
                      size: 12.5.sp,
                      weight: FontWeight.w700,
                      color: t.accentBrass,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
        SizedBox(height: 18.h),
        Row(
          children: [
            Expanded(
              child: Text(
                '高頻實務問診題庫與摘要',
                style: t.serifTitle(size: 16.sp),
              ),
            ),
            if (prompts.isNotEmpty)
              TextButton(
                onPressed: onClearHistory,
                child: Text(
                  '清除紀錄',
                  style: t.sansBody(size: 12.sp, color: t.textMuted),
                ),
              ),
          ],
        ),
        SizedBox(height: 8.h),
        if (prompts.isEmpty)
          _QuietEmptyCard(
            icon: PhosphorIconsRegular.chatsCircle,
            title: '本機提問參考紀錄已清空',
            description: '您可前往底部導覽列「問診」分頁發起全新法律諮詢，或載入高頻實務問診範例。',
            helperLabel: '載入高頻實務問診範例',
            onHelperTap: onRestoreHistory,
          )
        else
          for (final item in prompts) ...[
            _QuestionRecordCard(record: item),
            SizedBox(height: 12.h),
          ],
      ],
    );
  }
}
