import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lawapp/data/journal/journal_repository.dart';
import 'package:lawapp/pages/journal/widgets/archive_activity_section.dart';
import 'package:lawapp/pages/journal/widgets/case_time_machine_card.dart';
import 'package:lawapp/pages/journal/widgets/discussing_now_section.dart';
import 'package:lawapp/pages/journal/widgets/journal_page_header.dart';
import 'package:lawapp/pages/journal/widgets/journal_palette.dart';
import 'package:lawapp/pages/journal/widgets/on_this_day_card.dart';
import 'package:lawapp/theme/adaptive_layout.dart';
import 'package:lawapp/theme/app_colors.dart';

/// 記事頁。
///
/// 台灣繁體中文教學註解：
/// 這一版先把記事定位成「社會事件到案件資料館」的入口，
/// 主頁只負責展示趨勢、策展角度與資料館動態；子頁與搜尋流程之後再接。
/// 版型刻意承襲首頁的柔和卡片語言，但用案件圖書館做出記事頁自己的記憶感。
class JournalPage extends StatefulWidget {
  const JournalPage({
    super.key,
    this.initialQuery = '',
    this.repository = const JournalRepository(),
  });

  final String initialQuery;
  final JournalRepository repository;

  @override
  State<JournalPage> createState() => _JournalPageState();
}

class _JournalPageState extends State<JournalPage> {
  late final TextEditingController _searchController;
  Future<List<JournalSearchResult>>? _searchFuture;
  String _query = '';

  @override
  void initState() {
    super.initState();
    _query = widget.initialQuery.trim();
    _searchController = TextEditingController(text: _query);
    if (_query.isNotEmpty) {
      _searchFuture = widget.repository.searchJournal(_query);
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
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
    final palette = JournalPalette.of(context);
    final layout = context.homeSearchLayout;
    final topPadding = MediaQuery.paddingOf(context).top;
    final hasQuery = _query.isNotEmpty;

    return Scaffold(
      backgroundColor: palette.background,
      body: Stack(
        children: [
          ListView(
            physics: const BouncingScrollPhysics(),
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            padding: EdgeInsets.fromLTRB(
              16.w,
              topPadding + 16.h,
              16.w,
              126.h,
            ),
            children: [
              JournalPageHeader(palette: palette),
              SizedBox(height: 14.h),
              if (hasQuery)
                FutureBuilder<List<JournalSearchResult>>(
                  future: _searchFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return _JournalSearchStatusCard(
                        message: '正在搜尋記事資料...',
                        palette: palette,
                      );
                    }

                    if (snapshot.hasError) {
                      return _JournalSearchStatusCard(
                        message: '記事搜尋暫時無法讀取，請稍後再試。',
                        palette: palette,
                      );
                    }

                    return _JournalSearchResults(
                      query: _query,
                      results: snapshot.data ?? const [],
                      palette: palette,
                    );
                  },
                )
              else ...[
                // 台灣繁體中文教學註解：
                // 沒有搜尋字時仍維持原本策展首頁；一旦從全站搜尋帶 query 進來，
                // 這裡會切成前端資料結果，清楚告訴使用者目前查的是已整理資料。
                DiscussingNowSection(palette: palette),
                SizedBox(height: 20.h),

                CaseTimeMachineCard(palette: palette),
                SizedBox(height: 20.h),
                OnThisDayCard(palette: palette),
                SizedBox(height: 20.h),
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
                        AppColors.background,
                        AppColors.background.withValues(alpha: 0.92),
                        AppColors.background.withValues(alpha: 0.56),
                        AppColors.background.withValues(alpha: 0.18),
                        AppColors.background.withValues(alpha: 0),
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
}

class _JournalSearchField extends StatelessWidget {
  const _JournalSearchField({
    required this.controller,
    required this.palette,
    required this.onChanged,
    required this.onSubmitted,
    required this.onClear,
  });

  final TextEditingController controller;
  final JournalPalette palette;
  final ValueChanged<String> onChanged;
  final ValueChanged<String> onSubmitted;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 46.h,
      decoration: BoxDecoration(
        color: palette.surface,
        borderRadius: BorderRadius.circular(15.r),
        border: Border.all(color: palette.border.withValues(alpha: 0.78)),
      ),
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        onSubmitted: (value) => onSubmitted(value.trim()),
        textInputAction: TextInputAction.search,
        textAlignVertical: TextAlignVertical.center,
        decoration: InputDecoration(
          hintText: '搜尋案件、社會議題或圖書館關鍵字',
          hintStyle: TextStyle(
            fontSize: 13.sp,
            color: palette.secondaryText,
          ),
          prefixIcon: Icon(
            Icons.search_rounded,
            size: 21.sp,
            color: palette.secondaryText,
          ),
          suffixIcon: controller.text.isEmpty
              ? null
              : IconButton(
                  onPressed: onClear,
                  tooltip: '清除搜尋關鍵字',
                  icon: Icon(
                    Icons.close_rounded,
                    size: 18.sp,
                    color: palette.primaryText,
                  ),
                ),
          border: InputBorder.none,
          isCollapsed: true,
          contentPadding: EdgeInsets.symmetric(vertical: 13.h),
        ),
      ),
    );
  }
}

class _JournalSearchResults extends StatelessWidget {
  const _JournalSearchResults({
    required this.query,
    required this.results,
    required this.palette,
  });

  final String query;
  final List<JournalSearchResult> results;
  final JournalPalette palette;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '「$query」的前端資料結果',
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.w900,
            color: palette.primaryText,
          ),
        ),
        SizedBox(height: 6.h),
        Text(
          '目前先搜尋記事頁已整理的趨勢、圖書館更新與精選卷宗；完整後端索引接上後，這裡可改成真正案件搜尋。',
          style: TextStyle(
            fontSize: 12.sp,
            height: 1.45,
            color: palette.secondaryText,
          ),
        ),
        SizedBox(height: 12.h),
        if (results.isEmpty)
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(15.w),
            decoration: BoxDecoration(
              color: palette.surface,
              borderRadius: BorderRadius.circular(18.r),
              border: Border.all(color: palette.border.withValues(alpha: 0.78)),
            ),
            child: Text(
              '目前前端資料沒有符合「$query」的項目。你仍可以回全站搜尋改用小法助或法規資料庫查詢。',
              style: TextStyle(
                fontSize: 12.5.sp,
                height: 1.45,
                color: palette.secondaryText,
              ),
            ),
          )
        else
          ...results.map(
            (result) => Padding(
              padding: EdgeInsets.only(bottom: 10.h),
              child: _JournalSearchResultCard(
                result: result,
                palette: palette,
              ),
            ),
          ),
      ],
    );
  }
}

class _JournalSearchStatusCard extends StatelessWidget {
  const _JournalSearchStatusCard({
    required this.message,
    required this.palette,
  });

  final String message;
  final JournalPalette palette;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(15.w),
      decoration: BoxDecoration(
        color: palette.surface,
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(color: palette.border.withValues(alpha: 0.78)),
      ),
      child: Text(
        message,
        style: TextStyle(
          fontSize: 12.5.sp,
          height: 1.45,
          color: palette.secondaryText,
        ),
      ),
    );
  }
}

class _JournalSearchResultCard extends StatelessWidget {
  const _JournalSearchResultCard({
    required this.result,
    required this.palette,
  });

  final JournalSearchResult result;
  final JournalPalette palette;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: palette.surface,
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(color: palette.border.withValues(alpha: 0.78)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36.w,
            height: 36.w,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: const Color(0xFFEAF7F2),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Icon(
              _iconForJournalResult(result.type),
              size: 19.sp,
              color: const Color(0xFF146B50),
            ),
          ),
          SizedBox(width: 11.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  result.typeLabel,
                  style: TextStyle(
                    fontSize: 10.8.sp,
                    fontWeight: FontWeight.w800,
                    color: palette.secondaryText,
                  ),
                ),
                SizedBox(height: 3.h),
                Text(
                  result.title,
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w900,
                    color: palette.primaryText,
                  ),
                ),
                SizedBox(height: 6.h),
                Text(
                  result.summary,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 11.8.sp,
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

IconData _iconForJournalResult(JournalSearchResultType type) {
  switch (type) {
    case JournalSearchResultType.trend:
      return Icons.trending_up_rounded;
    case JournalSearchResultType.archiveUpdate:
      return Icons.update_rounded;
    case JournalSearchResultType.archiveDossier:
      return Icons.inventory_2_rounded;
    case JournalSearchResultType.onThisDay:
      return Icons.history_edu_rounded;
    case JournalSearchResultType.caseBook:
      return Icons.auto_stories_rounded;
  }
}
