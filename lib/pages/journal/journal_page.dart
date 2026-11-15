import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:preamble/components/navigation/app_shell_content_insets.dart';
import 'package:preamble/data/journal/journal_repository.dart';
import 'package:preamble/data/journal/user_case_journal_repository.dart';
import 'package:preamble/pages/journal/widgets/archive_activity_section.dart';
import 'package:preamble/pages/journal/widgets/assistant_prompt_bubble.dart';
import 'package:preamble/pages/journal/widgets/case_library_card.dart';
import 'package:preamble/pages/journal/widgets/curated_exhibition_shelf.dart';
import 'package:preamble/pages/journal/widgets/discussing_now_section.dart';
import 'package:preamble/pages/journal/widgets/journal_page_header.dart';
import 'package:preamble/pages/journal/widgets/journal_palette.dart';
import 'package:preamble/pages/journal/widgets/on_this_day_card.dart';
import 'package:preamble/pages/journal/widgets/user_case_journal_section.dart';
import 'package:preamble/theme/adaptive_layout.dart';
import 'package:preamble/theme/preamble_tokens.dart';

/// Tab 4 紀事策展頁 (`JournalPage`)。
///
/// 雙透鏡架構：
/// 0. `公共法治策展`：今日歷史記憶、主題特展、公共法治三大館藏入口、社會熱議與卷宗編纂動態。
/// 1. `個人自救案件夾`：雙重編碼自救卷宗（蒐證完成度進度條、法定時效關鍵期限、一鍵開啟實戰工具館）。
class JournalPage extends StatefulWidget {
  const JournalPage({
    super.key,
    this.initialQuery = '',
    this.initialLensTab = 0,
    this.lensSelectionVersion = 0,
    this.repository = const JournalRepository(),
  });

  final String initialQuery;
  final int initialLensTab;
  final int lensSelectionVersion;
  final JournalRepository repository;

  @override
  State<JournalPage> createState() => _JournalPageState();
}

class _JournalPageState extends State<JournalPage> {
  late final TextEditingController _searchController;
  Future<List<JournalSearchResult>>? _searchFuture;
  String _query = '';
  bool _isSearchOpen = false;
  int _selectedJournalTab = 0; // 0: 公共法治策展, 1: 個人自救案件夾
  final UserCaseJournalRepository _userCaseRepository =
      UserCaseJournalRepository();

  @override
  void initState() {
    super.initState();
    _selectedJournalTab = widget.initialLensTab.clamp(0, 1);
    _query = widget.initialQuery.trim();
    _isSearchOpen = _query.isNotEmpty;
    _searchController = TextEditingController(text: _query);
    if (_query.isNotEmpty) {
      _searchFuture = widget.repository.searchJournal(_query);
    }
  }

  @override
  void didUpdateWidget(covariant JournalPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.lensSelectionVersion != oldWidget.lensSelectionVersion ||
        widget.initialLensTab != oldWidget.initialLensTab) {
      setState(() {
        _selectedJournalTab = widget.initialLensTab.clamp(0, 1);
      });
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _toggleSearchBar() {
    setState(() {
      if (_isSearchOpen) {
        _isSearchOpen = false;
        _query = '';
        _searchController.clear();
        _searchFuture = null;
        FocusManager.instance.primaryFocus?.unfocus();
      } else {
        _isSearchOpen = true;
      }
    });
  }

  void _onQueryChanged(String raw) {
    final query = raw.trim();
    setState(() {
      _query = query;
      _searchFuture =
          query.isEmpty ? null : widget.repository.searchJournal(query);
    });
  }

  void _submitJournalQuery(String value) {
    final query = value.trim();
    setState(() {
      _query = query;
      _searchController.text = query;
      _searchController.selection =
          TextSelection.collapsed(offset: query.length);
      _searchFuture =
          query.isEmpty ? null : widget.repository.searchJournal(query);
    });
    FocusManager.instance.primaryFocus?.unfocus();
  }

  void _clearJournalQuery() {
    setState(() {
      _query = '';
      _searchController.clear();
      _searchFuture = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final palette = JournalPalette.of(context);
    final layout = context.homeSearchLayout;
    final topPadding = MediaQuery.paddingOf(context).top;
    final hasQuery = _query.isNotEmpty;

    return Scaffold(
      backgroundColor: t.canvas,
      body: Stack(
        children: [
          ListView(
            cacheExtent: 600,
            physics: const BouncingScrollPhysics(),
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            padding: EdgeInsets.fromLTRB(
              16.w,
              topPadding + 14.h,
              16.w,
              126.h + AppShellContentInsets.additionalBottomOf(context),
            ),
            children: [
              JournalPageHeader(
                palette: palette,
                isSearchOpen: _isSearchOpen,
                onToggleSearch: _toggleSearchBar,
              ),
              if (_isSearchOpen) ...[
                SizedBox(height: 12.h),
                _JournalSearchField(
                  controller: _searchController,
                  onChanged: _onQueryChanged,
                  onSubmitted: _submitJournalQuery,
                  onClear: _clearJournalQuery,
                ),
              ],
              SizedBox(height: 14.h),
              _buildDualLensSegmentedControl(t),
              SizedBox(height: 16.h),
              if (hasQuery)
                FutureBuilder<List<JournalSearchResult>>(
                  future: _searchFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return _JournalSearchStatusCard(
                        message: '正在檢索紀事與案件館資料...',
                        tokens: t,
                      );
                    }

                    if (snapshot.hasError) {
                      return _JournalSearchStatusCard(
                        message: '紀事搜尋暫時無法讀取，請稍後再試。',
                        tokens: t,
                      );
                    }

                    return _JournalSearchResults(
                      query: _query,
                      results: snapshot.data ?? const [],
                      tokens: t,
                    );
                  },
                )
              else if (_selectedJournalTab == 1) ...[
                UserCaseJournalSection(
                  palette: palette,
                  repository: _userCaseRepository,
                ),
              ] else ...[
                AssistantPromptBubble(palette: palette),
                SizedBox(height: 16.h),
                OnThisDayCard(palette: palette),
                SizedBox(height: 18.h),
                DiscussingNowSection(palette: palette),
                SizedBox(height: 20.h),
                CuratedExhibitionShelf(palette: palette),
                SizedBox(height: 20.h),
                CaseLibraryCard(palette: palette),
                SizedBox(height: 22.h),
                ArchiveActivitySection(palette: palette),
              ],
            ],
          ),
          if (layout.hasLargeTopInset)
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: IgnorePointer(
                child: Container(
                  height: layout.topMaskHeight.h,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      stops: const [0, 0.12, 0.28, 0.52, 1],
                      colors: [
                        t.canvas,
                        t.canvas.withValues(alpha: 0.92),
                        t.canvas.withValues(alpha: 0.56),
                        t.canvas.withValues(alpha: 0.18),
                        t.canvas.withValues(alpha: 0),
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildDualLensSegmentedControl(PreambleTokens t) {
    final caseCount = _userCaseRepository.entries.length;
    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: t.surfaceSubtle,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: t.border),
      ),
      child: Row(
        children: [
          Expanded(
            child: _LensSegmentButton(
              isSelected: _selectedJournalTab == 0,
              icon: PhosphorIconsRegular.columns,
              label: '公共法治策展',
              onTap: () => setState(() => _selectedJournalTab = 0),
            ),
          ),
          SizedBox(width: 4.w),
          Expanded(
            child: _LensSegmentButton(
              isSelected: _selectedJournalTab == 1,
              icon: PhosphorIconsRegular.briefcase,
              label: '個人自救案件夾',
              countBadge: caseCount > 0 ? '$caseCount' : null,
              onTap: () => setState(() => _selectedJournalTab = 1),
            ),
          ),
        ],
      ),
    );
  }
}

class _LensSegmentButton extends StatelessWidget {
  const _LensSegmentButton({
    required this.isSelected,
    required this.icon,
    required this.label,
    required this.onTap,
    this.countBadge,
  });

  final bool isSelected;
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final String? countBadge;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final fg = isSelected ? const Color(0xFFFAF8F4) : t.textSecondary;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(11.r),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: EdgeInsets.symmetric(vertical: 9.h, horizontal: 8.w),
          decoration: BoxDecoration(
            color: isSelected ? t.brandPrimaryStrong : Colors.transparent,
            borderRadius: BorderRadius.circular(11.r),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: t.shadowAmbient,
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 15.sp, color: fg),
              SizedBox(width: 6.w),
              Flexible(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: t.sansBody(
                    size: 12.5.sp,
                    weight: FontWeight.w700,
                    color: fg,
                    height: 1.2,
                  ),
                ),
              ),
              if (countBadge != null) ...[
                SizedBox(width: 5.w),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 5.5.w,
                    vertical: 1.h,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? const Color(0x33D4AC6E)
                        : t.accentBrassContainer,
                    borderRadius: BorderRadius.circular(999.r),
                  ),
                  child: Text(
                    countBadge!,
                    style: t.tabularMetric(
                      size: 10.sp,
                      weight: FontWeight.w700,
                      color: isSelected
                          ? const Color(0xFFEED3A5)
                          : t.accentOnBrassContainer,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _JournalSearchField extends StatelessWidget {
  const _JournalSearchField({
    required this.controller,
    required this.onChanged,
    required this.onSubmitted,
    required this.onClear,
  });

  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final ValueChanged<String> onSubmitted;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;

    return Container(
      height: 44.h,
      decoration: t.subtleBoxDecoration(radius: 14.r, fill: t.surface),
      child: TextField(
        controller: controller,
        autofocus: true,
        onTapOutside: (_) => FocusManager.instance.primaryFocus?.unfocus(),
        onChanged: onChanged,
        onSubmitted: (value) => onSubmitted(value.trim()),
        textInputAction: TextInputAction.search,
        textAlignVertical: TextAlignVertical.center,
        style: t.sansBody(size: 13.sp, color: t.textPrimary),
        decoration: InputDecoration(
          hintText: '搜尋重大案件、歷史記憶或社會議題關鍵字',
          hintStyle: t.sansBody(size: 12.5.sp, color: t.textMuted),
          prefixIcon: Icon(
            PhosphorIconsRegular.magnifyingGlass,
            size: 18.sp,
            color: t.textSecondary,
          ),
          suffixIcon: controller.text.isEmpty
              ? null
              : IconButton(
                  onPressed: onClear,
                  tooltip: '清除搜尋關鍵字',
                  icon: Icon(
                    PhosphorIconsRegular.xCircle,
                    size: 17.sp,
                    color: t.textSecondary,
                  ),
                ),
          border: InputBorder.none,
          isCollapsed: true,
          contentPadding: EdgeInsets.symmetric(vertical: 11.h),
        ),
      ),
    );
  }
}

class _JournalSearchResults extends StatelessWidget {
  const _JournalSearchResults({
    required this.query,
    required this.results,
    required this.tokens,
  });

  final String query;
  final List<JournalSearchResult> results;
  final PreambleTokens tokens;

  @override
  Widget build(BuildContext context) {
    final t = tokens;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '「$query」檢索結果',
          style: t.serifTitle(size: 18.sp, weight: FontWeight.w800),
        ),
        SizedBox(height: 4.h),
        Text(
          '涵蓋重大案件卷宗、歷史上的今日、社會熱議與館藏更新紀錄。',
          style: t.sansBody(size: 12.sp, color: t.textSecondary),
        ),
        SizedBox(height: 12.h),
        if (results.isEmpty)
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(16.w),
            decoration: t.cardDecoration(radius: 18.r, elevated: false),
            child: Text(
              '目前館藏沒有符合「$query」的紀錄，建議更換關鍵字或使用小法助問診查詢。',
              style: t.sansBody(size: 12.5.sp, color: t.textSecondary),
            ),
          )
        else
          ...results.map(
            (result) => Padding(
              padding: EdgeInsets.only(bottom: 10.h),
              child: _JournalSearchResultCard(result: result, tokens: t),
            ),
          ),
      ],
    );
  }
}

class _JournalSearchStatusCard extends StatelessWidget {
  const _JournalSearchStatusCard({
    required this.message,
    required this.tokens,
  });

  final String message;
  final PreambleTokens tokens;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.w),
      decoration: tokens.cardDecoration(radius: 18.r, elevated: false),
      child: Text(
        message,
        style: tokens.sansBody(size: 12.5.sp, color: tokens.textSecondary),
      ),
    );
  }
}

class _JournalSearchResultCard extends StatelessWidget {
  const _JournalSearchResultCard({
    required this.result,
    required this.tokens,
  });

  final JournalSearchResult result;
  final PreambleTokens tokens;

  IconData _iconForJournalResult(JournalSearchResultType type) {
    return switch (type) {
      JournalSearchResultType.trend => PhosphorIconsRegular.trendUp,
      JournalSearchResultType.archiveUpdate =>
        PhosphorIconsRegular.clockCounterClockwise,
      JournalSearchResultType.archiveDossier => PhosphorIconsRegular.archive,
      JournalSearchResultType.onThisDay => PhosphorIconsRegular.calendarStar,
      JournalSearchResultType.caseBook => PhosphorIconsRegular.scales,
    };
  }

  @override
  Widget build(BuildContext context) {
    final t = tokens;
    return Container(
      padding: EdgeInsets.all(14.w),
      decoration: t.cardDecoration(radius: 18.r, elevated: false),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36.w,
            height: 36.w,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: t.brandContainer,
              borderRadius: BorderRadius.circular(11.r),
            ),
            child: Icon(
              _iconForJournalResult(result.type),
              size: 18.sp,
              color: t.brandOnContainer,
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  result.typeLabel,
                  style: t.sansBody(
                    size: 10.5.sp,
                    weight: FontWeight.w700,
                    color: t.accentBrass,
                  ),
                ),
                SizedBox(height: 3.h),
                Text(
                  result.title,
                  style: t.serifTitle(size: 14.5.sp, weight: FontWeight.w800),
                ),
                SizedBox(height: 5.h),
                Text(
                  result.summary,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: t.sansBody(
                    size: 12.sp,
                    color: t.textSecondary,
                    height: 1.45,
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
