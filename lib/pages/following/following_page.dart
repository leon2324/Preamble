import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:preamble/app/app_state.dart';
import 'package:preamble/components/shared/custom_toast.dart';
import 'package:preamble/components/shared/share_sheet.dart';
import 'package:preamble/components/subscription/morandi_paywall_sheet.dart';
import 'package:preamble/data/documents/document_models.dart';
import 'package:preamble/data/following/following_models.dart';
import 'package:preamble/data/mock_data/home/home_mock_data.dart';
import 'package:preamble/features/case_library/data/case_library_data.dart';
import 'package:preamble/features/case_library/models/case_library_models.dart';
import 'package:preamble/features/case_library/pages/case_dossier_detail_page.dart';
import 'package:preamble/features/case_library/pages/case_library_entry_page.dart';
import 'package:preamble/pages/home/subpages/home_life_legal_tips_page.dart';
import 'package:preamble/pages/learning/statute_database_page.dart';
import 'package:preamble/pages/learning/widgets/legal_document_export_page.dart';
import 'package:preamble/theme/preamble_tokens.dart';

part 'widgets/following_views.dart';
part 'widgets/following_cards.dart';
part 'widgets/following_primitives.dart';

enum _FollowingSection {
  collections('收藏', PhosphorIconsRegular.bookmarks),
  updates('追蹤動態', PhosphorIconsRegular.bellRinging),
  notes('法務筆記', PhosphorIconsRegular.notebook),
  drafts('文件草稿', PhosphorIconsRegular.fileText),
  questions('提問紀錄', PhosphorIconsRegular.chatsCircle);

  const _FollowingSection(this.label, this.icon);
  final String label;
  final IconData icon;
}

enum _SavedKind { caseDossier, statute, article }

enum _TrackedKind { statute, caseDossier, topic }

/// 《緒言 Preamble》個人案卷收藏、追蹤動態與法務筆記中心。
///
/// 全面綁定 `PreambleState` 真實持久化狀態（`savedCaseIds`、`followingSummary`、
/// `caseNoteDrafts`、`documentRepository.drafts`），確保與 `ProfilePage` 數據 100% 即時同步，
/// 並統一採用 `context.tokens` 靜奢 `20.r` 卡片與淺深色模式。
class FollowingPage extends StatefulWidget {
  const FollowingPage({
    super.key,
    this.initialTab = 'collections',
  });

  /// 支援傳入 `'collections'`、`'updates'`（或 `'tabs'`）、`'notes'`、`'drafts'`、`'questions'`。
  final String? initialTab;

  @override
  State<FollowingPage> createState() => _FollowingPageState();
}

class _FollowingPageState extends State<FollowingPage> {
  late _FollowingSection _activeSection;
  int _collectionFilterIndex = 0;
  int _updatesFilterIndex = 0;
  int _noteFilterIndex = 0;
  int _draftFilterIndex = 0;
  bool _questionsCleared = false;

  @override
  void initState() {
    super.initState();
    _activeSection = _parseSection(widget.initialTab);
  }

  @override
  void didUpdateWidget(covariant FollowingPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialTab != widget.initialTab &&
        widget.initialTab != null) {
      _activeSection = _parseSection(widget.initialTab);
    }
  }

  _FollowingSection _parseSection(String? tab) {
    switch (tab) {
      case 'updates':
      case 'tabs':
        return _FollowingSection.updates;
      case 'notes':
        return _FollowingSection.notes;
      case 'drafts':
        return _FollowingSection.drafts;
      case 'questions':
        return _FollowingSection.questions;
      case 'collections':
      default:
        return _FollowingSection.collections;
    }
  }

  @override
  Widget build(BuildContext context) {
    final appState = PreambleScope.of(context);
    final t = context.tokens;
    final topInset = MediaQuery.paddingOf(context).top;
    final canPop = Navigator.of(context).canPop();

    return AnimatedBuilder(
      animation: appState,
      builder: (context, _) {
        final summary = appState.followingSummary;
        final savedItems = _buildSavedItems(appState, summary);
        final trackedItems = _buildTrackedItems(summary);
        final noteEntries = _buildNoteEntries(appState.caseNoteDrafts);
        final drafts = appState.documentRepository.drafts;

        return Scaffold(
          backgroundColor: t.canvas,
          body: Column(
            children: [
              // 頂部固定導航與分頁切換列
              Container(
                decoration: BoxDecoration(
                  color: t.canvas,
                  border: Border(bottom: BorderSide(color: t.border)),
                ),
                padding: EdgeInsets.fromLTRB(16.w, topInset + 10.h, 16.w, 12.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _TopHeaderBar(
                      title: _activeSection.label,
                      subtitle: _subtitleForSection(
                        _activeSection,
                        savedCount: savedItems.length,
                        trackedCount: trackedItems.length,
                        noteCount: noteEntries.length,
                        draftCount: drafts.length,
                      ),
                      showBack: canPop,
                      onBack: () => Navigator.of(context).maybePop(),
                      trailing: _activeSection == _FollowingSection.notes
                          ? _FollowActionChip(
                              icon: PhosphorIconsRegular.plus,
                              label: '新增筆記',
                              onTap: () => _openNoteEditorSheet(appState),
                            )
                          : null,
                    ),
                    SizedBox(height: 12.h),
                    _FollowSectionTabBar(
                      activeSection: _activeSection,
                      counts: {
                        _FollowingSection.collections: savedItems.length,
                        _FollowingSection.updates: trackedItems.length,
                        _FollowingSection.notes: noteEntries.length,
                        _FollowingSection.drafts: drafts.length,
                        _FollowingSection.questions:
                            _questionsCleared ? 0 : _samplePrompts.length,
                      },
                      onChanged: (section) {
                        HapticFeedback.selectionClick();
                        setState(() => _activeSection = section);
                      },
                    ),
                  ],
                ),
              ),

              // 主內容捲動區
              Expanded(
                child: ListView(
                  keyboardDismissBehavior:
                      ScrollViewKeyboardDismissBehavior.onDrag,
                  physics: const BouncingScrollPhysics(),
                  padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 40.h),
                  children: [
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 180),
                      child: KeyedSubtree(
                        key: ValueKey(_activeSection),
                        child: _buildActiveSectionBody(
                          context,
                          appState: appState,
                          savedItems: savedItems,
                          trackedItems: trackedItems,
                          noteEntries: noteEntries,
                          drafts: drafts,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  String _subtitleForSection(
    _FollowingSection section, {
    required int savedCount,
    required int trackedCount,
    required int noteCount,
    required int draftCount,
  }) {
    switch (section) {
      case _FollowingSection.collections:
        return '本機已典藏 $savedCount 筆案卷、法規與避坑指引';
      case _FollowingSection.updates:
        return '正在監控 $trackedCount 項法規修訂與案件進度';
      case _FollowingSection.notes:
        return '共 $noteCount 則個人法務爭點與蒐證隨筆';
      case _FollowingSection.drafts:
        return '共 $draftCount 份本機書狀與協商通知草稿';
      case _FollowingSection.questions:
        return '小法助歷史諮詢重點與常用問診題庫';
    }
  }

  Widget _buildActiveSectionBody(
    BuildContext context, {
    required PreambleState appState,
    required List<_ResolvedSavedItem> savedItems,
    required List<_ResolvedTrackedItem> trackedItems,
    required List<_ResolvedNoteEntry> noteEntries,
    required List<DocumentDraft> drafts,
  }) {
    switch (_activeSection) {
      case _FollowingSection.collections:
        return _CollectionsTabView(
          items: savedItems,
          selectedFilterIndex: _collectionFilterIndex,
          onFilterChanged: (idx) =>
              setState(() => _collectionFilterIndex = idx),
          onOpenItem: _handleOpenSavedItem,
          onUnsaveItem: (item) => _handleUnsaveItem(appState, item),
          onExploreCases: _openCaseLibrary,
          onExploreStatutes: () => _openStatuteDatabase(''),
          onLoadSamples: () => _loadSampleCollections(appState),
        );
      case _FollowingSection.updates:
        return _UpdatesTabView(
          trackedItems: trackedItems,
          recommendedStatutes: _curatedStatuteWatches,
          isStatuteFollowed: appState.isStatuteFollowed,
          selectedFilterIndex: _updatesFilterIndex,
          onFilterChanged: (idx) => setState(() => _updatesFilterIndex = idx),
          onOpenTracked: _handleOpenTrackedItem,
          onUnfollowTracked: (item) => _handleUnfollowItem(appState, item),
          onToggleRecommendedStatute: (watch) =>
              _handleToggleRecommendedStatute(appState, watch),
          onOpenRecommendedStatute: (watch) =>
              _openStatuteDatabase(watch.searchQuery),
        );
      case _FollowingSection.notes:
        return _NotesTabView(
          notes: noteEntries,
          selectedFilterIndex: _noteFilterIndex,
          onFilterChanged: (idx) => setState(() => _noteFilterIndex = idx),
          onCreateNote: () => _openNoteEditorSheet(appState),
          onOpenNote: (entry) => _openNoteDetailSheet(appState, entry),
          onEditNote: (entry) => _openNoteEditorSheet(appState, existing: entry),
          onDeleteNote: (entry) => _confirmDeleteNote(appState, entry),
          onLoadSampleNotes: () => _loadSampleNotes(appState),
        );
      case _FollowingSection.drafts:
        return _DraftsTabView(
          drafts: drafts,
          selectedFilterIndex: _draftFilterIndex,
          onFilterChanged: (idx) => setState(() => _draftFilterIndex = idx),
          onOpenDraft: _openDraftExportPage,
          onDeleteDraft: (draft) async {
            await appState.documentRepository.deleteDraft(draft.id);
            if (!mounted) return;
            CustomToast.show(
              this.context,
              '已移除草稿「${draft.title}」',
              icon: PhosphorIconsRegular.trash,
            );
          },
          onCreateQuickDraft: () => _createSampleDraft(appState),
        );
      case _FollowingSection.questions:
        return _QuestionsTabView(
          appState: appState,
          prompts: _questionsCleared ? const [] : _samplePrompts,
          onUpgradePro: () => MorandiPaywallSheet.show(context),
          onClearHistory: () {
            setState(() => _questionsCleared = true);
            CustomToast.show(
              context,
              '已清除本機提問參考紀錄',
              icon: PhosphorIconsRegular.checkCircle,
            );
          },
          onRestoreHistory: () {
            setState(() => _questionsCleared = false);
          },
        );
    }
  }

  // ---------------------------------------------------------------------------
  // 導航與狀態寫入動作
  // ---------------------------------------------------------------------------

  void _openCaseLibrary() {
    Navigator.of(context).push(
      CupertinoPageRoute<void>(
        builder: (_) => const CaseLibraryEntryPage(),
      ),
    );
  }

  void _openStatuteDatabase(String query) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => StatuteDatabasePage(initialQuery: query),
      ),
    );
  }

  void _openLifeTips() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => const LifeLegalTipsPage(),
      ),
    );
  }

  void _handleOpenSavedItem(_ResolvedSavedItem item) {
    switch (item.kind) {
      case _SavedKind.caseDossier:
        final book = item.caseBook ?? caseLibraryCaseById(item.rawId);
        Navigator.of(context).push(
          CupertinoPageRoute<void>(
            builder: (_) => CaseDossierDetailPage(book: book),
          ),
        );
        break;
      case _SavedKind.statute:
        _openStatuteDatabase(item.statuteQuery ?? item.title);
        break;
      case _SavedKind.article:
        _openLifeTips();
        break;
    }
  }

  Future<void> _handleUnsaveItem(
    PreambleState appState,
    _ResolvedSavedItem item,
  ) async {
    HapticFeedback.lightImpact();
    switch (item.kind) {
      case _SavedKind.caseDossier:
        await appState.setCaseSaved(item.rawId, false);
        break;
      case _SavedKind.statute:
        await appState.setStatuteSaved(item.rawId, false);
        break;
      case _SavedKind.article:
        await appState.setArticleSaved(item.rawId, false);
        break;
    }
    if (!mounted) return;
    CustomToast.show(
      context,
      '已自收藏夾移除「${item.title}」',
      icon: PhosphorIconsRegular.bookmarkSimple,
    );
  }

  Future<void> _loadSampleCollections(PreambleState appState) async {
    HapticFeedback.mediumImpact();
    await appState.setCaseSaved('318', true);
    await appState.setCaseSaved('case-chang-will-1764', true);
    await appState.setStatuteSaved('labor-32-1', true);
    await appState.setArticleSaved('tip-landlord-entry', true);
    if (!mounted) return;
    CustomToast.show(
      context,
      '已載入 4 筆範例收藏，與個人中心統計即時同步',
      icon: PhosphorIconsFill.bookmarks,
    );
  }

  void _handleOpenTrackedItem(_ResolvedTrackedItem item) {
    switch (item.kind) {
      case _TrackedKind.statute:
        _openStatuteDatabase(item.statuteQuery ?? item.title);
        break;
      case _TrackedKind.caseDossier:
        if (item.caseBook != null) {
          Navigator.of(context).push(
            CupertinoPageRoute<void>(
              builder: (_) => CaseDossierDetailPage(book: item.caseBook!),
            ),
          );
        } else {
          _openCaseLibrary();
        }
        break;
      case _TrackedKind.topic:
        _openLifeTips();
        break;
    }
  }

  Future<void> _handleUnfollowItem(
    PreambleState appState,
    _ResolvedTrackedItem item,
  ) async {
    HapticFeedback.lightImpact();
    switch (item.kind) {
      case _TrackedKind.statute:
        await appState.setStatuteFollowed(item.rawId, false);
        break;
      case _TrackedKind.caseDossier:
        await appState.setCaseFollowed(item.rawId, false);
        break;
      case _TrackedKind.topic:
        await appState.setTopicFollowed(item.rawId, false);
        break;
    }
    if (!mounted) return;
    CustomToast.show(
      context,
      '已取消追蹤「${item.title}」',
      icon: PhosphorIconsRegular.bellSlash,
    );
  }

  Future<void> _handleToggleRecommendedStatute(
    PreambleState appState,
    _StatuteWatchSpec watch,
  ) async {
    HapticFeedback.selectionClick();
    final nextFollowed = !appState.isStatuteFollowed(watch.statuteId);
    await appState.setStatuteFollowed(watch.statuteId, nextFollowed);
    if (!mounted) return;
    CustomToast.show(
      context,
      nextFollowed
          ? '已追蹤「${watch.articleRef}」修法動態'
          : '已取消追蹤「${watch.articleRef}」',
      icon: nextFollowed
          ? PhosphorIconsFill.bellRinging
          : PhosphorIconsRegular.bellSlash,
    );
  }

  Future<void> _loadSampleNotes(PreambleState appState) async {
    HapticFeedback.mediumImpact();
    await appState.saveCaseNoteDraft(
      'note_sample_rental',
      '【租屋｜退租點交與押金返還備忘】\n退租當日務必拍攝水電表度數、牆面與冷氣現況，並要求房東於七日內提出具體修繕單據，避免遭不當扣抵自然折舊費用。',
    );
    await appState.saveCaseNoteDraft(
      'note_sample_labor',
      '【勞動｜延長工時與補休結算紀錄】\n依勞基法第 32 條之 1，加班補休須由勞工於加班事實發生後自主選擇；年度屆期未休畢者應依原加班費率折算工資。',
    );
    await appState.saveCaseNoteDraft(
      'note_sample_general',
      '【一般｜日常契約簽署審閱三原則】\n簽署任何定型化契約前，先確認審閱期天數、違約金上限條款與爭議管轄法院，並保留完整對話紀錄與匯款憑證。',
    );
    if (!mounted) return;
    CustomToast.show(
      context,
      '已建立 3 則分類範例筆記',
      icon: PhosphorIconsFill.notebook,
    );
  }

  void _openNoteDetailSheet(
    PreambleState appState,
    _ResolvedNoteEntry entry,
  ) {
    final t = context.tokens;
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return Container(
          decoration: BoxDecoration(
            color: t.surfaceElevated,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
            border: Border.all(color: t.border),
          ),
          padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 24.h),
          child: SafeArea(
            top: false,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 38.w,
                      height: 4.h,
                      decoration: BoxDecoration(
                        color: t.borderStrong,
                        borderRadius: BorderRadius.circular(99.r),
                      ),
                    ),
                  ),
                  SizedBox(height: 16.h),
                  Row(
                    children: [
                      _CategoryPill(
                        label: entry.category,
                        color: _categoryAccentColor(t, entry.category),
                        bgColor: _categoryBgColor(t, entry.category),
                      ),
                      const Spacer(),
                      IconButton(
                        onPressed: () => Navigator.of(sheetContext).pop(),
                        icon: Icon(
                          PhosphorIconsRegular.x,
                          size: 20.sp,
                          color: t.textSecondary,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 6.h),
                  Text(
                    entry.title,
                    style: t.serifTitle(size: 18.sp),
                  ),
                  if (entry.sourceLabel != null) ...[
                    SizedBox(height: 4.h),
                    Text(
                      entry.sourceLabel!,
                      style: t.sansBody(size: 12.sp, color: t.textMuted),
                    ),
                  ],
                  SizedBox(height: 14.h),
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(16.w),
                    decoration: t.subtleBoxDecoration(radius: 16.r),
                    child: Text(
                      entry.body,
                      style: t.sansBody(
                        size: 14.sp,
                        color: t.textPrimary,
                        height: 1.68,
                      ),
                    ),
                  ),
                  if (entry.linkedCase != null) ...[
                    SizedBox(height: 12.h),
                    InkWell(
                      onTap: () {
                        Navigator.of(sheetContext).pop();
                        Navigator.of(context).push(
                          CupertinoPageRoute<void>(
                            builder: (_) =>
                                CaseDossierDetailPage(book: entry.linkedCase!),
                          ),
                        );
                      },
                      borderRadius: BorderRadius.circular(14.r),
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 14.w,
                          vertical: 11.h,
                        ),
                        decoration: t.cardDecoration(
                          radius: 14.r,
                          elevated: false,
                        ),
                        child: Row(
                          children: [
                            Icon(
                              PhosphorIconsRegular.scales,
                              size: 18.sp,
                              color: t.brandPrimary,
                            ),
                            SizedBox(width: 10.w),
                            Expanded(
                              child: Text(
                                '前往關聯案卷：${entry.linkedCase!.titleZh}',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: t.sansTitle(size: 13.sp),
                              ),
                            ),
                            Icon(
                              PhosphorIconsRegular.caretRight,
                              size: 16.sp,
                              color: t.textMuted,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                  SizedBox(height: 20.h),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {
                            Navigator.of(sheetContext).pop();
                            _openNoteEditorSheet(appState, existing: entry);
                          },
                          style: OutlinedButton.styleFrom(
                            foregroundColor: t.brandPrimary,
                            side: BorderSide(color: t.borderStrong),
                            padding: EdgeInsets.symmetric(vertical: 11.h),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12.r),
                            ),
                          ),
                          icon: Icon(
                            PhosphorIconsRegular.pencilSimple,
                            size: 16.sp,
                          ),
                          label: const Text('編輯'),
                        ),
                      ),
                      SizedBox(width: 8.w),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {
                            Navigator.of(sheetContext).pop();
                            ShareSheet.show(context, title: entry.title);
                          },
                          style: OutlinedButton.styleFrom(
                            foregroundColor: t.textPrimary,
                            side: BorderSide(color: t.borderStrong),
                            padding: EdgeInsets.symmetric(vertical: 11.h),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12.r),
                            ),
                          ),
                          icon: Icon(
                            PhosphorIconsRegular.shareNetwork,
                            size: 16.sp,
                          ),
                          label: const Text('分享'),
                        ),
                      ),
                      SizedBox(width: 8.w),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {
                            Navigator.of(sheetContext).pop();
                            _confirmDeleteNote(appState, entry);
                          },
                          style: OutlinedButton.styleFrom(
                            foregroundColor: t.semanticUrgent,
                            side: BorderSide(
                              color: t.semanticUrgent.withValues(alpha: 0.45),
                            ),
                            padding: EdgeInsets.symmetric(vertical: 11.h),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12.r),
                            ),
                          ),
                          icon: Icon(PhosphorIconsRegular.trash, size: 16.sp),
                          label: const Text('刪除'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _openNoteEditorSheet(
    PreambleState appState, {
    _ResolvedNoteEntry? existing,
  }) {
    final titleController = TextEditingController(text: existing?.title ?? '');
    final bodyController = TextEditingController(text: existing?.body ?? '');
    String selectedCategory = existing?.category ?? '一般';

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (sheetContext, setSheetState) {
            final t = sheetContext.tokens;
            final bottomInset = MediaQuery.viewInsetsOf(sheetContext).bottom;

            return Container(
              decoration: BoxDecoration(
                color: t.surfaceElevated,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
                border: Border.all(color: t.border),
              ),
              padding: EdgeInsets.fromLTRB(
                20.w,
                12.h,
                20.w,
                bottomInset + 24.h,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Center(
                      child: Container(
                        width: 38.w,
                        height: 4.h,
                        decoration: BoxDecoration(
                          color: t.borderStrong,
                          borderRadius: BorderRadius.circular(99.r),
                        ),
                      ),
                    ),
                    SizedBox(height: 16.h),
                    Text(
                      existing == null ? '新增法務筆記' : '編輯法務筆記',
                      style: t.serifTitle(size: 17.sp),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 16.h),
                    Text(
                      '筆記分類',
                      style: t.sansTitle(size: 12.5.sp, color: t.textSecondary),
                    ),
                    SizedBox(height: 8.h),
                    Wrap(
                      spacing: 8.w,
                      runSpacing: 8.h,
                      children: const ['一般', '租屋', '勞動', '消費'].map((cat) {
                        final active = selectedCategory == cat;
                        return ChoiceChip(
                          label: Text(cat),
                          selected: active,
                          onSelected: (_) =>
                              setSheetState(() => selectedCategory = cat),
                          selectedColor: t.brandPrimaryStrong,
                          backgroundColor: t.surfaceSubtle,
                          labelStyle: t.sansBody(
                            size: 12.5.sp,
                            weight: FontWeight.w700,
                            color: active
                                ? const Color(0xFFFAF8F4)
                                : t.textPrimary,
                          ),
                          side: BorderSide(
                            color: active ? t.brandPrimaryStrong : t.border,
                          ),
                          showCheckmark: false,
                        );
                      }).toList(),
                    ),
                    SizedBox(height: 14.h),
                    Text(
                      '筆記標題',
                      style: t.sansTitle(size: 12.5.sp, color: t.textSecondary),
                    ),
                    SizedBox(height: 6.h),
                    TextField(
                      controller: titleController,
                      style: t.sansBody(size: 14.sp, color: t.textPrimary),
                      decoration: InputDecoration(
                        hintText: '例如：退租押金返還協商重點',
                        hintStyle: t.sansBody(size: 13.sp, color: t.textMuted),
                        filled: true,
                        fillColor: t.surfaceSubtle,
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 14.w,
                          vertical: 12.h,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.r),
                          borderSide: BorderSide(color: t.border),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.r),
                          borderSide:
                              BorderSide(color: t.brandPrimary, width: 1.5),
                        ),
                      ),
                    ),
                    SizedBox(height: 14.h),
                    Text(
                      '爭點與蒐證內容',
                      style: t.sansTitle(size: 12.5.sp, color: t.textSecondary),
                    ),
                    SizedBox(height: 6.h),
                    TextField(
                      controller: bodyController,
                      maxLines: 5,
                      style: t.sansBody(size: 14.sp, color: t.textPrimary),
                      decoration: InputDecoration(
                        hintText: '記錄事實經過、對方主張、現有證據或待查法條...',
                        hintStyle: t.sansBody(size: 13.sp, color: t.textMuted),
                        filled: true,
                        fillColor: t.surfaceSubtle,
                        contentPadding: EdgeInsets.all(14.w),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.r),
                          borderSide: BorderSide(color: t.border),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.r),
                          borderSide:
                              BorderSide(color: t.brandPrimary, width: 1.5),
                        ),
                      ),
                    ),
                    SizedBox(height: 20.h),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => Navigator.of(sheetContext).pop(),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: t.textSecondary,
                              side: BorderSide(color: t.borderStrong),
                              padding: EdgeInsets.symmetric(vertical: 12.h),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14.r),
                              ),
                            ),
                            child: const Text('取消'),
                          ),
                        ),
                        SizedBox(width: 12.w),
                        Expanded(
                          child: FilledButton(
                            onPressed: () async {
                              final rawBody = bodyController.text.trim();
                              final rawTitle = titleController.text.trim();
                              if (rawBody.isEmpty && rawTitle.isEmpty) {
                                CustomToast.show(
                                  context,
                                  '請輸入筆記標題或內容',
                                  icon: PhosphorIconsRegular.warningCircle,
                                );
                                return;
                              }
                              final effectiveTitle = rawTitle.isEmpty
                                  ? '$selectedCategory法務隨筆'
                                  : rawTitle;
                              final effectiveBody = rawBody.isEmpty
                                  ? effectiveTitle
                                  : rawBody;
                              final noteKey = existing?.key ??
                                  'note_${DateTime.now().millisecondsSinceEpoch}';
                              final encoded =
                                  '【$selectedCategory｜$effectiveTitle】\n$effectiveBody';

                              await appState.saveCaseNoteDraft(
                                noteKey,
                                encoded,
                              );
                              if (!sheetContext.mounted) return;
                              Navigator.of(sheetContext).pop();
                              if (!mounted) return;
                              CustomToast.show(
                                context,
                                existing == null ? '已儲存新法務筆記' : '法務筆記已更新',
                                icon: PhosphorIconsFill.checkCircle,
                              );
                            },
                            style: FilledButton.styleFrom(
                              backgroundColor: t.brandPrimaryStrong,
                              foregroundColor: const Color(0xFFFAF8F4),
                              padding: EdgeInsets.symmetric(vertical: 12.h),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14.r),
                              ),
                            ),
                            child: Text(existing == null ? '儲存筆記' : '儲存變更'),
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
      },
    ).whenComplete(() {
      titleController.dispose();
      bodyController.dispose();
    });
  }

  void _confirmDeleteNote(
    PreambleState appState,
    _ResolvedNoteEntry entry,
  ) {
    final t = context.tokens;
    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: t.surfaceElevated,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.r),
            side: BorderSide(color: t.border),
          ),
          title: Text('刪除法務筆記', style: t.serifTitle(size: 16.5.sp)),
          content: Text(
            '確定要永久移除「${entry.title}」嗎？移除後將同步更新本機筆記統計。',
            style: t.sansBody(size: 13.5.sp, color: t.textSecondary),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: Text(
                '取消',
                style: t.sansBody(
                  size: 13.sp,
                  weight: FontWeight.w600,
                  color: t.textSecondary,
                ),
              ),
            ),
            FilledButton(
              onPressed: () async {
                await appState.saveCaseNoteDraft(entry.key, '');
                if (!dialogContext.mounted) return;
                Navigator.of(dialogContext).pop();
                if (!mounted) return;
                CustomToast.show(
                  context,
                  '已刪除筆記「${entry.title}」',
                  icon: PhosphorIconsRegular.trash,
                );
              },
              style: FilledButton.styleFrom(
                backgroundColor: t.semanticUrgent,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.r),
                ),
              ),
              child: const Text('確定刪除'),
            ),
          ],
        );
      },
    );
  }

  void _openDraftExportPage(DocumentDraft draft) {
    Navigator.of(context).push(
      CupertinoPageRoute<void>(
        builder: (_) => LegalDocumentExportPage(
          title: draft.title,
          content: draft.content,
        ),
      ),
    );
  }

  Future<void> _createSampleDraft(PreambleState appState) async {
    HapticFeedback.mediumImpact();
    final draft = await appState.documentRepository.createDraft(
      templateType: DocumentTemplateType.rentalDepositNegotiation,
      input: DocumentTemplateInput(
        senderName: appState.currentUser.displayName,
        receiverName: '出租人／相對人',
        facts: '租期屆滿完成點交後，相對人主張扣留押金卻未提出具體修繕單據與收據明細。',
        extraRequest: '請於文到七日內提供正式修繕憑證；逾期未提出請全額返還押金。',
        evidence: '住宅租賃契約書、押金匯款紀錄、入住與退租點交照片、通訊對話紀錄。',
        toneLabel: '正式但保留協商空間',
      ),
      title: '退租押金返還協商通知草稿',
    );
    if (!mounted) return;
    _openDraftExportPage(draft);
  }
}

// =============================================================================
// 真實持久化狀態解析模型與查表輔助 (State Resolvers)
// =============================================================================

class _StatuteWatchSpec {
  const _StatuteWatchSpec({
    required this.statuteId,
    required this.articleRef,
    required this.title,
    required this.summary,
    required this.searchQuery,
    required this.badgeLabel,
  });

  final String statuteId;
  final String articleRef;
  final String title;
  final String summary;
  final String searchQuery;
  final String badgeLabel;
}

const List<_StatuteWatchSpec> _curatedStatuteWatches = [
  _StatuteWatchSpec(
    statuteId: 'labor-32-1',
    articleRef: '勞動基準法 第 32 條之 1',
    title: '加班補休選擇權與年度屆期強制折算工資規範',
    summary: '補休須由勞工於加班事實發生後自主選擇，契約年度屆期未休畢應依原加班費率折發工資。',
    searchQuery: '勞動基準法',
    badgeLabel: '勞動權益常備',
  ),
  _StatuteWatchSpec(
    statuteId: 'rental-elec-2024',
    articleRef: '住宅租賃定型化契約應記載事項',
    title: '租屋電費計收新制：禁止超收台電當期每度平均單價',
    summary: '計收上限不得逾台電當期平均電價，且出租人負有提供電費資訊供承租人查核之法定義務。',
    searchQuery: '租賃',
    badgeLabel: '租屋新制焦點',
  ),
  _StatuteWatchSpec(
    statuteId: 'anti-fraud-2024',
    articleRef: '詐欺犯罪危害防制條例 第 43 條',
    title: '高額假投資與深偽詐欺加重刑責暨被害人保護新制',
    summary: '針對高額詐欺犯罪大幅提高法定刑度與假釋門檻，強化金融帳戶預警與被害人訴訟參與權益。',
    searchQuery: '詐欺',
    badgeLabel: '刑事打詐新法',
  ),
  _StatuteWatchSpec(
    statuteId: 'statute-民法第184條',
    articleRef: '民法 第 184 條',
    title: '一般侵權行為損害賠償核心請求權基礎',
    summary: '因故意或過失不法侵害他人權利，或違反保護他人之法律致生損害者，負損害賠償責任。',
    searchQuery: '民法 184',
    badgeLabel: '民事核心基礎',
  ),
];

const Map<String, ({String title, String subtitle})> _knownLifeTips = {
  'tip-landlord-entry': (
    title: '租屋簽約與居住防身：房東擅自帶看與扣押金三步自保',
    subtitle: '刑法第 306 條・民法第 423 條｜居住安全與押金返還檢核',
  ),
  'tip-lock-change': (
    title: '房客為安全自行換鎖違法嗎？退租點交零糾紛實務清單',
    subtitle: '民法租賃編・占有保護原則｜退租復原與鑰匙點交步驟',
  ),
  'tip-intrusion-evidence': (
    title: '遭遇突襲開門或鄰里騷擾：具備法庭證據力的蒐證三原則',
    subtitle: '刑事訴訟法證據保全實務｜時間戳記與原始影音雙重備份',
  ),
};

class _ResolvedSavedItem {
  const _ResolvedSavedItem({
    required this.rawId,
    required this.kind,
    required this.categoryLabel,
    required this.title,
    required this.subtitle,
    this.metaBadge,
    this.caseBook,
    this.statuteQuery,
  });

  final String rawId;
  final _SavedKind kind;
  final String categoryLabel;
  final String title;
  final String subtitle;
  final String? metaBadge;
  final CaseBook? caseBook;
  final String? statuteQuery;
}

class _ResolvedTrackedItem {
  const _ResolvedTrackedItem({
    required this.rawId,
    required this.kind,
    required this.categoryLabel,
    required this.title,
    required this.subtitle,
    required this.statusNote,
    this.caseBook,
    this.statuteQuery,
  });

  final String rawId;
  final _TrackedKind kind;
  final String categoryLabel;
  final String title;
  final String subtitle;
  final String statusNote;
  final CaseBook? caseBook;
  final String? statuteQuery;
}

class _ResolvedNoteEntry {
  const _ResolvedNoteEntry({
    required this.key,
    required this.category,
    required this.title,
    required this.body,
    this.sourceLabel,
    this.linkedCase,
  });

  final String key;
  final String category; // '租屋' | '勞動' | '消費' | '一般'
  final String title;
  final String body;
  final String? sourceLabel;
  final CaseBook? linkedCase;
}

class _PromptRecord {
  const _PromptRecord({
    required this.category,
    required this.question,
    required this.summaryHint,
    required this.relatedLaw,
  });

  final String category;
  final String question;
  final String summaryHint;
  final String relatedLaw;
}

const List<_PromptRecord> _samplePrompts = [
  _PromptRecord(
    category: '租屋權益',
    question: '退租時房東以牆面自然泛黃為由扣留押金，我該如何主張返還？',
    summaryHint: '先區分「自然折舊」與「人為毀損」，定型化契約規定修繕義務原則歸出租人，可先寄發定期催告函。',
    relatedLaw: '民法第 423 條・住宅租賃定型化契約',
  ),
  _PromptRecord(
    category: '勞動法令',
    question: '公司規定加班只能換補休、年底沒休完直接歸零，這樣合法嗎？',
    summaryHint: '雇主不得片面規定僅能補休；契約年度屆滿未休畢之時數，依法須按原加班費率折算工資發給。',
    relatedLaw: '勞動基準法第 24 條、第 32 條之 1',
  ),
  _PromptRecord(
    category: '消費保障',
    question: '網購拆封試穿發現尺寸不合，賣家以「已拆封」拒絕七天退貨是否有效？',
    summaryHint: '必要之檢視拆封不影響通訊交易七日猶豫期解除權，惟須保持商品本體、吊牌與包裝完整。',
    relatedLaw: '消費者保護法第 19 條',
  ),
];

List<_ResolvedSavedItem> _buildSavedItems(
  PreambleState appState,
  FollowingSummary summary,
) {
  final results = <_ResolvedSavedItem>[];
  final allCaseIds = <String>{
    ...appState.savedCaseIds,
    ...summary.savedCaseIds,
  };

  for (final id in allCaseIds) {
    final matched = _findCaseBookOrNull(id);
    if (matched != null) {
      results.add(
        _ResolvedSavedItem(
          rawId: id,
          kind: _SavedKind.caseDossier,
          categoryLabel: '案件卷宗',
          title: matched.titleZh,
          subtitle: matched.oneSentenceSummary,
          metaBadge: '${matched.category} · ${matched.basicInfo.courtLevel}',
          caseBook: matched,
        ),
      );
    } else {
      results.add(
        _ResolvedSavedItem(
          rawId: id,
          kind: _SavedKind.caseDossier,
          categoryLabel: '案件卷宗',
          title: _humanizeId(id),
          subtitle: '已收入本機個人案卷收藏夾，點擊前往完整卷宗閱覽。',
          metaBadge: '典藏案卷',
        ),
      );
    }
  }

  for (final id in summary.savedStatuteIds) {
    final spec = _resolveStatuteInfo(id);
    results.add(
      _ResolvedSavedItem(
        rawId: id,
        kind: _SavedKind.statute,
        categoryLabel: '常用法規',
        title: spec.title,
        subtitle: spec.summary,
        metaBadge: '全國法規檢索',
        statuteQuery: spec.query,
      ),
    );
  }

  for (final id in summary.savedArticleIds) {
    final tip = _resolveArticleInfo(id);
    results.add(
      _ResolvedSavedItem(
        rawId: id,
        kind: _SavedKind.article,
        categoryLabel: '避坑指引',
        title: tip.title,
        subtitle: tip.subtitle,
        metaBadge: '生活法律實務',
      ),
    );
  }

  return results;
}

List<_ResolvedTrackedItem> _buildTrackedItems(FollowingSummary summary) {
  final results = <_ResolvedTrackedItem>[];

  for (final id in summary.followedStatuteIds) {
    final spec = _resolveStatuteInfo(id);
    results.add(
      _ResolvedTrackedItem(
        rawId: id,
        kind: _TrackedKind.statute,
        categoryLabel: '法規異動',
        title: spec.title,
        subtitle: spec.summary,
        statusNote: '修法與實務函釋監控中',
        statuteQuery: spec.query,
      ),
    );
  }

  for (final id in summary.followedCaseIds) {
    final matched = _findCaseBookOrNull(id);
    results.add(
      _ResolvedTrackedItem(
        rawId: id,
        kind: _TrackedKind.caseDossier,
        categoryLabel: '案件進度',
        title: matched?.titleZh ?? _humanizeId(id),
        subtitle:
            matched?.oneSentenceSummary ?? '已開啟案件審級與相關裁判追蹤提醒。',
        statusNote: matched != null
            ? '${matched.basicInfo.procedureStage} · ${matched.status}'
            : '案件動態監控中',
        caseBook: matched,
      ),
    );
  }

  for (final id in summary.followedTopicIds) {
    final tip = _resolveArticleInfo(id);
    results.add(
      _ResolvedTrackedItem(
        rawId: id,
        kind: _TrackedKind.topic,
        categoryLabel: '議題追蹤',
        title: tip.title,
        subtitle: tip.subtitle,
        statusNote: '生活法律專題持續追蹤中',
      ),
    );
  }

  return results;
}

List<_ResolvedNoteEntry> _buildNoteEntries(Map<String, String> drafts) {
  final entries = <_ResolvedNoteEntry>[];
  final keys = drafts.keys.toList().reversed;

  for (final key in keys) {
    final raw = drafts[key]?.trim() ?? '';
    if (raw.isEmpty) continue;

    final linkedCase = _findCaseBookOrNull(key);
    String? explicitCategory;
    String? parsedTitle;
    String parsedBody = raw;

    // 解析結構化標頭：例如「【租屋｜退租點交備忘】\n內文...」
    final headerMatch =
        RegExp(r'^【(租屋|勞動|消費|一般)｜([^】]+)】\s*\n?([\s\S]*)$').firstMatch(raw);
    if (headerMatch != null) {
      explicitCategory = headerMatch.group(1);
      parsedTitle = headerMatch.group(2)?.trim();
      final rest = headerMatch.group(3)?.trim() ?? '';
      parsedBody = rest.isEmpty ? (parsedTitle ?? raw) : rest;
    } else {
      final bracketTitle = RegExp(r'^【([^】]+)】\s*\n?([\s\S]*)$').firstMatch(raw);
      if (bracketTitle != null) {
        parsedTitle = bracketTitle.group(1)?.trim();
        final rest = bracketTitle.group(2)?.trim() ?? '';
        parsedBody = rest.isEmpty ? raw : rest;
      }
    }

    final resolvedTitle = (parsedTitle != null && parsedTitle.isNotEmpty)
        ? parsedTitle
        : (linkedCase != null
            ? '${linkedCase.shortTitleZh}・閱卷筆記'
            : _deriveTitleFromBody(parsedBody));

    final category = explicitCategory ??
        _classifyNoteCategory(
          key: key,
          title: resolvedTitle,
          body: parsedBody,
        );

    String? sourceLabel;
    if (linkedCase != null) {
      sourceLabel = '關聯案卷：${linkedCase.displayCode} ${linkedCase.shortTitleZh}';
    } else if (key.startsWith('toolkit_')) {
      sourceLabel = '來源：法務急救箱蒐證清單';
    } else {
      sourceLabel = '本機隨手筆記';
    }

    entries.add(
      _ResolvedNoteEntry(
        key: key,
        category: category,
        title: resolvedTitle,
        body: parsedBody,
        sourceLabel: sourceLabel,
        linkedCase: linkedCase,
      ),
    );
  }

  return entries;
}

/// 精準判定法務筆記分類（修正舊版將「一般」錯誤篩選為「租屋」之缺陷）：
/// 非屬「租屋」、「勞動」、「消費」特定領域者，一律歸入「一般」。
String _classifyNoteCategory({
  required String key,
  required String title,
  required String body,
}) {
  final combined = '${key.toLowerCase()} $title $body';
  if (combined.contains('rental') ||
      combined.contains('租屋') ||
      combined.contains('租賃') ||
      combined.contains('房東') ||
      combined.contains('房客') ||
      combined.contains('押金') ||
      combined.contains('退租')) {
    return '租屋';
  }
  if (combined.contains('labor') ||
      combined.contains('勞動') ||
      combined.contains('勞資') ||
      combined.contains('勞基') ||
      combined.contains('加班') ||
      combined.contains('資遣') ||
      combined.contains('工資') ||
      combined.contains('工時') ||
      combined.contains('外送')) {
    return '勞動';
  }
  if (combined.contains('consumer') ||
      combined.contains('消費') ||
      combined.contains('網購') ||
      combined.contains('退貨') ||
      combined.contains('消保') ||
      combined.contains('瑕疵') ||
      combined.contains('鑑賞期') ||
      combined.contains('猶豫期')) {
    return '消費';
  }
  return '一般';
}

String _deriveTitleFromBody(String body) {
  final firstLine = body.split('\n').first.trim();
  if (firstLine.length <= 22) return firstLine;
  return '${firstLine.substring(0, 22)}…';
}

CaseBook? _findCaseBookOrNull(String rawId) {
  final trimmed = rawId.trim();
  if (trimmed.isEmpty) return null;

  for (final book in caseLibraryCases) {
    if (book.id == trimmed) return book;
  }

  final withoutPrefix = trimmed.replaceFirst(RegExp(r'^case-'), '');
  for (final book in caseLibraryCases) {
    if (book.id == withoutPrefix) return book;
    if (_slugify(book.titleZh) == _slugify(withoutPrefix) ||
        _slugify(book.shortTitleZh) == _slugify(withoutPrefix)) {
      return book;
    }
  }
  return null;
}

({String title, String summary, String query}) _resolveStatuteInfo(
  String rawId,
) {
  for (final watch in _curatedStatuteWatches) {
    if (watch.statuteId == rawId) {
      return (
        title: watch.articleRef,
        summary: '${watch.title} — ${watch.summary}',
        query: watch.searchQuery,
      );
    }
  }

  final cleaned = rawId.replaceFirst(RegExp(r'^statute-'), '').trim();
  final formatted = cleaned.replaceAllMapped(
    RegExp(r'([^\s])(第\d+條(?:之\d+)?)'),
    (m) => '${m.group(1)} ${m.group(2)}',
  );
  final query = formatted
      .replaceAll('第', ' ')
      .replaceAll('條', '')
      .replaceAll(RegExp(r'\s+'), ' ')
      .trim();

  return (
    title: formatted.isEmpty ? rawId : formatted,
    summary: '已納入個人法規清單，點擊開啟全國法規資料庫檢視完整條文與白話解析。',
    query: query.isEmpty ? formatted : query,
  );
}

({String title, String subtitle}) _resolveArticleInfo(String rawId) {
  final known = _knownLifeTips[rawId];
  if (known != null) return known;

  final normalized =
      rawId.replaceFirst(RegExp(r'^(article|topic)-'), '').trim();
  for (final item in homeNewsletterItems) {
    if (_slugify(item.title) == _slugify(normalized)) {
      return (
        title: item.title,
        subtitle: '${item.category}避坑實務｜點擊閱讀完整自保步驟',
      );
    }
  }

  return (
    title: _humanizeId(rawId),
    subtitle: '生活法律避坑與權益檢核指引',
  );
}

String _humanizeId(String rawId) {
  final stripped =
      rawId.replaceFirst(RegExp(r'^(case|statute|article|topic)-'), '').trim();
  return stripped.isEmpty ? rawId : stripped;
}

String _slugify(String text) {
  return text
      .trim()
      .toLowerCase()
      .replaceAll(RegExp(r'\s+'), '')
      .replaceAll(RegExp(r'[^a-z0-9\u4e00-\u9fff]+'), '');
}

Color _categoryAccentColor(PreambleTokens t, String category) {
  switch (category) {
    case '租屋':
    case '避坑指引':
      return t.accentOnBrassContainer;
    case '勞動':
    case '常用法規':
    case '法規異動':
      return t.semanticInfo;
    case '消費':
      return t.semanticSuccess;
    default:
      return t.brandPrimary;
  }
}

Color _categoryBgColor(PreambleTokens t, String category) {
  switch (category) {
    case '租屋':
    case '避坑指引':
      return t.accentBrassContainer;
    case '勞動':
    case '常用法規':
    case '法規異動':
      return t.semanticInfoContainer;
    case '消費':
      return t.semanticSuccessContainer;
    default:
      return t.brandContainer;
  }
}
