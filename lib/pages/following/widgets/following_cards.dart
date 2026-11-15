part of '../following_page.dart';

class _SavedItemCard extends StatelessWidget {
  const _SavedItemCard({
    required this.item,
    required this.onTap,
    required this.onUnsave,
  });

  final _ResolvedSavedItem item;
  final VoidCallback onTap;
  final VoidCallback onUnsave;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final iconData = switch (item.kind) {
      _SavedKind.caseDossier => PhosphorIconsRegular.scales,
      _SavedKind.statute => PhosphorIconsRegular.bookOpenText,
      _SavedKind.article => PhosphorIconsRegular.shieldCheck,
    };

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20.r),
        child: Container(
          padding: EdgeInsets.all(16.w),
          decoration: t.cardDecoration(radius: 20.r),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  _CategoryPill(
                    icon: iconData,
                    label: item.categoryLabel,
                    color: _categoryAccentColor(t, item.categoryLabel),
                    bgColor: _categoryBgColor(t, item.categoryLabel),
                  ),
                  if (item.metaBadge != null) ...[
                    SizedBox(width: 8.w),
                    Expanded(
                      child: Text(
                        item.metaBadge!,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: t.sansBody(size: 11.5.sp, color: t.textMuted),
                      ),
                    ),
                  ] else
                    const Spacer(),
                  IconButton(
                    onPressed: onUnsave,
                    tooltip: '取消收藏',
                    visualDensity: VisualDensity.compact,
                    icon: Icon(
                      PhosphorIconsFill.bookmarkSimple,
                      size: 19.sp,
                      color: t.accentBrass,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 8.h),
              Text(
                item.title,
                style: t.serifTitle(size: 16.sp),
              ),
              SizedBox(height: 6.h),
              Text(
                item.subtitle,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: t.sansBody(size: 13.sp, color: t.textSecondary),
              ),
              SizedBox(height: 10.h),
              Row(
                children: [
                  Text(
                    item.kind == _SavedKind.statute
                        ? '點擊檢索法條與白話說明'
                        : item.kind == _SavedKind.caseDossier
                            ? '點擊開啟完整判決卷宗'
                            : '點擊開啟避坑檢核步驟',
                    style: t.sansBody(
                      size: 11.5.sp,
                      weight: FontWeight.w600,
                      color: t.brandPrimary,
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
            ],
          ),
        ),
      ),
    );
  }
}

class _TrackedUpdateCard extends StatelessWidget {
  const _TrackedUpdateCard({
    required this.item,
    required this.onTap,
    required this.onUnfollow,
  });

  final _ResolvedTrackedItem item;
  final VoidCallback onTap;
  final VoidCallback onUnfollow;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final iconData = switch (item.kind) {
      _TrackedKind.statute => PhosphorIconsRegular.gitDiff,
      _TrackedKind.caseDossier => PhosphorIconsRegular.scales,
      _TrackedKind.topic => PhosphorIconsRegular.tag,
    };

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20.r),
        child: Container(
          padding: EdgeInsets.all(16.w),
          decoration: t.cardDecoration(radius: 20.r),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  _CategoryPill(
                    icon: iconData,
                    label: item.categoryLabel,
                    color: _categoryAccentColor(t, item.categoryLabel),
                    bgColor: _categoryBgColor(t, item.categoryLabel),
                  ),
                  const Spacer(),
                  InkWell(
                    onTap: onUnfollow,
                    borderRadius: BorderRadius.circular(99.r),
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 10.w,
                        vertical: 4.5.h,
                      ),
                      decoration: BoxDecoration(
                        color: t.surfaceSubtle,
                        borderRadius: BorderRadius.circular(99.r),
                        border: Border.all(color: t.border),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            PhosphorIconsFill.bellRinging,
                            size: 13.sp,
                            color: t.brandPrimary,
                          ),
                          SizedBox(width: 4.w),
                          Text(
                            '追蹤中・取消',
                            style: t.sansBody(
                              size: 11.sp,
                              weight: FontWeight.w600,
                              color: t.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 10.h),
              Text(
                item.title,
                style: t.serifTitle(size: 16.sp),
              ),
              SizedBox(height: 6.h),
              Text(
                item.subtitle,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: t.sansBody(size: 13.sp, color: t.textSecondary),
              ),
              SizedBox(height: 10.h),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
                decoration: t.subtleBoxDecoration(radius: 10.r),
                child: Row(
                  children: [
                    Icon(
                      PhosphorIconsRegular.pulse,
                      size: 14.sp,
                      color: t.accentBrass,
                    ),
                    SizedBox(width: 6.w),
                    Expanded(
                      child: Text(
                        item.statusNote,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: t.sansBody(
                          size: 11.5.sp,
                          weight: FontWeight.w600,
                          color: t.textPrimary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RecommendedStatuteCard extends StatelessWidget {
  const _RecommendedStatuteCard({
    required this.spec,
    required this.isFollowed,
    required this.onToggleFollow,
    required this.onOpenStatute,
  });

  final _StatuteWatchSpec spec;
  final bool isFollowed;
  final VoidCallback onToggleFollow;
  final VoidCallback onOpenStatute;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onOpenStatute,
        borderRadius: BorderRadius.circular(20.r),
        child: Container(
          padding: EdgeInsets.all(16.w),
          decoration: t.cardDecoration(radius: 20.r),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  _CategoryPill(
                    icon: PhosphorIconsRegular.bookBookmark,
                    label: spec.badgeLabel,
                    color: t.semanticInfo,
                    bgColor: t.semanticInfoContainer,
                  ),
                  const Spacer(),
                  InkWell(
                    onTap: onToggleFollow,
                    borderRadius: BorderRadius.circular(99.r),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      padding: EdgeInsets.symmetric(
                        horizontal: 12.w,
                        vertical: 5.5.h,
                      ),
                      decoration: BoxDecoration(
                        color: isFollowed
                            ? t.brandContainer
                            : t.brandPrimaryStrong,
                        borderRadius: BorderRadius.circular(99.r),
                        border: Border.all(
                          color: isFollowed
                              ? t.brandPrimary
                              : t.brandPrimaryStrong,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            isFollowed
                                ? PhosphorIconsFill.checkCircle
                                : PhosphorIconsRegular.plus,
                            size: 13.sp,
                            color: isFollowed
                                ? t.brandOnContainer
                                : const Color(0xFFFAF8F4),
                          ),
                          SizedBox(width: 4.w),
                          Text(
                            isFollowed ? '已追蹤' : '+ 追蹤',
                            style: t.sansBody(
                              size: 11.5.sp,
                              weight: FontWeight.w700,
                              color: isFollowed
                                  ? t.brandOnContainer
                                  : const Color(0xFFFAF8F4),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 10.h),
              Text(
                spec.articleRef,
                style: t.serifTitle(size: 16.sp),
              ),
              SizedBox(height: 4.h),
              Text(
                spec.title,
                style: t.sansTitle(size: 13.5.sp, color: t.textPrimary),
              ),
              SizedBox(height: 6.h),
              Text(
                spec.summary,
                style: t.sansBody(size: 12.5.sp, color: t.textSecondary),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LawNoteCard extends StatelessWidget {
  const _LawNoteCard({
    required this.entry,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
  });

  final _ResolvedNoteEntry entry;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20.r),
        child: Container(
          padding: EdgeInsets.all(16.w),
          decoration: t.cardDecoration(radius: 20.r),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  _CategoryPill(
                    icon: PhosphorIconsRegular.tag,
                    label: entry.category,
                    color: _categoryAccentColor(t, entry.category),
                    bgColor: _categoryBgColor(t, entry.category),
                  ),
                  if (entry.sourceLabel != null) ...[
                    SizedBox(width: 8.w),
                    Expanded(
                      child: Text(
                        entry.sourceLabel!,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: t.sansBody(size: 11.5.sp, color: t.textMuted),
                      ),
                    ),
                  ] else
                    const Spacer(),
                  IconButton(
                    onPressed: onEdit,
                    tooltip: '編輯筆記',
                    visualDensity: VisualDensity.compact,
                    icon: Icon(
                      PhosphorIconsRegular.pencilSimple,
                      size: 17.sp,
                      color: t.textSecondary,
                    ),
                  ),
                  IconButton(
                    onPressed: onDelete,
                    tooltip: '刪除筆記',
                    visualDensity: VisualDensity.compact,
                    icon: Icon(
                      PhosphorIconsRegular.trash,
                      size: 17.sp,
                      color: t.textMuted,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 6.h),
              Text(
                entry.title,
                style: t.serifTitle(size: 16.sp),
              ),
              SizedBox(height: 6.h),
              Text(
                entry.body,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: t.sansBody(size: 13.sp, color: t.textSecondary),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DocumentDraftCard extends StatelessWidget {
  const _DocumentDraftCard({
    required this.draft,
    required this.tagLabel,
    required this.timeLabel,
    required this.onTap,
    required this.onDelete,
  });

  final DocumentDraft draft;
  final String tagLabel;
  final String timeLabel;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20.r),
        child: Container(
          padding: EdgeInsets.all(16.w),
          decoration: t.cardDecoration(radius: 20.r),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  _CategoryPill(
                    icon: PhosphorIconsRegular.fileText,
                    label: tagLabel,
                    color: t.brandOnContainer,
                    bgColor: t.brandContainer,
                  ),
                  SizedBox(width: 8.w),
                  Expanded(
                    child: Text(
                      timeLabel,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: t.sansBody(size: 11.5.sp, color: t.textMuted),
                    ),
                  ),
                  IconButton(
                    onPressed: onDelete,
                    tooltip: '移除草稿',
                    visualDensity: VisualDensity.compact,
                    icon: Icon(
                      PhosphorIconsRegular.trash,
                      size: 17.sp,
                      color: t.textMuted,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 6.h),
              Text(
                draft.title,
                style: t.serifTitle(size: 16.sp),
              ),
              SizedBox(height: 6.h),
              Text(
                draft.content,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: t.sansBody(size: 13.sp, color: t.textSecondary),
              ),
              SizedBox(height: 10.h),
              Row(
                children: [
                  Text(
                    '點擊預覽排版與匯出 PDF',
                    style: t.sansBody(
                      size: 11.5.sp,
                      weight: FontWeight.w600,
                      color: t.brandPrimary,
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
            ],
          ),
        ),
      ),
    );
  }
}

class _QuestionRecordCard extends StatelessWidget {
  const _QuestionRecordCard({required this.record});

  final _PromptRecord record;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: t.cardDecoration(radius: 20.r),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _CategoryPill(
                icon: PhosphorIconsRegular.chatsCircle,
                label: record.category,
                color: t.accentOnBrassContainer,
                bgColor: t.accentBrassContainer,
              ),
              const Spacer(),
              IconButton(
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: record.question));
                  CustomToast.show(
                    context,
                    '已複製問診問題，可貼至「問診」分頁深入推演',
                    icon: PhosphorIconsRegular.copy,
                  );
                },
                tooltip: '複製提問文字',
                visualDensity: VisualDensity.compact,
                icon: Icon(
                  PhosphorIconsRegular.copy,
                  size: 17.sp,
                  color: t.textSecondary,
                ),
              ),
            ],
          ),
          SizedBox(height: 6.h),
          Text(
            record.question,
            style: t.serifTitle(size: 15.5.sp),
          ),
          SizedBox(height: 8.h),
          Container(
            padding: EdgeInsets.all(12.w),
            decoration: t.subtleBoxDecoration(radius: 12.r),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  record.summaryHint,
                  style: t.sansBody(size: 12.5.sp, color: t.textPrimary),
                ),
                SizedBox(height: 6.h),
                Text(
                  '法源索引：${record.relatedLaw}',
                  style: t.sansBody(
                    size: 11.5.sp,
                    weight: FontWeight.w600,
                    color: t.brandPrimary,
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
