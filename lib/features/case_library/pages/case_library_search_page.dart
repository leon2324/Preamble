import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:preamble/features/case_library/data/case_library_data.dart';
import 'package:preamble/features/case_library/data/case_library_repository.dart';
import 'package:preamble/features/case_library/models/case_library_models.dart';
import 'package:preamble/features/case_library/pages/case_dossier_detail_page.dart';
import 'package:preamble/features/case_library/theme/case_library_theme.dart';
import 'package:preamble/features/case_library/widgets/case_library_scaffold.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:preamble/components/shared/shimmer_skeleton.dart';
import 'package:preamble/features/case_library/widgets/case_library_svg_icon.dart';

class CaseLibrarySearchPage extends StatefulWidget {
  // 透過建構子傳入 initialQuery，可以讓其他頁面點擊標籤時直接導向搜尋頁，並帶入預設的關鍵字進行篩選。
  const CaseLibrarySearchPage({super.key, this.initialQuery});

  final String? initialQuery;

  @override
  State<CaseLibrarySearchPage> createState() => _CaseLibrarySearchPageState();
}

class _CaseLibrarySearchPageState extends State<CaseLibrarySearchPage> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _selectedCategory = '全部';

  List<CaseBook> _searchResults = [];
  bool _isSearching = false;
  Timer? _debounce;

  Future<void> _performSearch() async {
    if (mounted) {
      setState(() {
        _isSearching = true;
      });
    }

    try {
      final category = _selectedCategory == '全部' ? null : _selectedCategory;
      final query = _searchQuery.trim().isEmpty ? null : _searchQuery;

      final results = await CaseLibraryRepository.instance.getCasesPaginated(
        50, // 搜尋最多載入 50 筆
        0, // offset
        category: category,
        query: query,
      );

      if (mounted) {
        setState(() {
          _searchResults = results;
          _isSearching = false;
        });
      }
    } catch (e) {
      print('Search failed: $e');
      if (mounted) {
        setState(() {
          _isSearching = false;
        });
      }
    }
  }

  @override
  void initState() {
    super.initState();
    // 若在開啟搜尋頁面時有帶入 initialQuery（例如使用者點擊了標籤 chip），
    // 則在此處對搜尋框控制器的文字與搜尋字串進行初始化，讓進入頁面時能直接顯示搜尋結果。
    if (widget.initialQuery != null && widget.initialQuery!.isNotEmpty) {
      _searchQuery = widget.initialQuery!;
      _searchController.text = widget.initialQuery!;
    }
    _performSearch();
  }

  final List<String> _categories = [
    '全部',
    '刑事案件',
    '家庭案件',
    '勞資案件',
    '詐欺案件',
    '校園案件',
    '司法爭議'
  ];

  List<CaseBook> get _filteredCases {
    return caseLibraryCases.where((book) {
      // 1. Filter by category
      if (_selectedCategory != '全部') {
        if (book.category != _selectedCategory) {
          return false;
        }
      }

      // 2. Filter by search query
      if (_searchQuery.isNotEmpty) {
        final query = _searchQuery.toLowerCase();
        final matchTitle = book.titleZh.toLowerCase().contains(query) ||
            book.titleEn.toLowerCase().contains(query);
        final matchShortTitle =
            book.shortTitleZh.toLowerCase().contains(query) ||
                book.shortTitleEn.toLowerCase().contains(query);
        final matchSummary = book.memoryLine.toLowerCase().contains(query) ||
            book.shortDescription.toLowerCase().contains(query);
        final matchTags =
            book.tags.any((tag) => tag.toLowerCase().contains(query));
        final matchLaws = book.relatedLaws.any((law) =>
            law.lawName.toLowerCase().contains(query) ||
            law.articleNumber.toLowerCase().contains(query));

        if (!matchTitle &&
            !matchShortTitle &&
            !matchSummary &&
            !matchTags &&
            !matchLaws) {
          return false;
        }
      }

      return true;
    }).toList();
  }

  void _openCaseDetail(BuildContext context, CaseBook book) {
    Navigator.of(context).push(
      CupertinoPageRoute<void>(
        builder: (__) => CaseDossierDetailPage(book: book),
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final results = _searchResults;

    return CaseLibraryScaffold(
      scene: CaseLibraryScene.theme,
      showBackButton: false,
      useSafeArea: false,
      child: Container(
        color: CaseLibraryColors.bgCream,
        child: SafeArea(
          bottom: false,
          child: Column(
            children: [
              // Top App Bar
              // 為了讓標題完美置中於螢幕，此處將原本 Row 改為 Stack。
              // 如此一來，即使左側返回按鈕佔據寬度，標題文字依然能以主體中心為準進行對齊，而不會偏心。
              // 必須讓 SizedBox 撐滿寬度，左側返回鍵才會定位到真正的 AppBar 左緣。
              Padding(
                padding: EdgeInsets.fromLTRB(6.w, 4.h, 16.w, 4.h),
                child: SizedBox(
                  width: double.infinity,
                  height: 38.h,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Positioned(
                        left: 0,
                        child: IconButton(
                          padding: EdgeInsets.zero,
                          constraints: BoxConstraints(
                            minWidth: 36.w,
                            minHeight: 36.w,
                          ),
                          icon: CaseLibrarySvgIcon(
                            CaseLibrarySvgIcons.chevronLeft,
                            size: 19.w,
                            color: CaseLibraryColors.primaryGreen,
                          ),
                          onPressed: () => Navigator.of(context).pop(),
                        ),
                      ),
                      Text(
                        '搜尋司法案件',
                        style:
                            CaseLibraryTextStyles.pageTitle(context).copyWith(
                          fontSize: 17.sp,
                          fontWeight: FontWeight.w900,
                          color: CaseLibraryColors.primaryGreen,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Search Bar Input
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 18.w),
                child: Container(
                  decoration: BoxDecoration(
                    color: CaseLibraryColors.bgWhite,
                    borderRadius: BorderRadius.circular(24.r),
                    border: Border.all(color: CaseLibraryColors.borderLight),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.02),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: TextField(
                    controller: _searchController,
                    onTapOutside: (event) {
                      FocusManager.instance.primaryFocus?.unfocus();
                    },
                    autofocus: widget.initialQuery == null ||
                        widget.initialQuery!.isEmpty,
                    textInputAction: TextInputAction.search,
                    onChanged: (val) {
                      setState(() {
                        _searchQuery = val;
                      });
                      _debounce?.cancel();
                      _debounce = Timer(const Duration(milliseconds: 300), () {
                        _performSearch();
                      });
                    },
                    decoration: InputDecoration(
                      prefixIcon: Padding(
                        padding: EdgeInsets.all(12.w),
                        child: CaseLibrarySvgIcon(
                          CaseLibrarySvgIcons.search,
                          size: 18.w,
                          color: CaseLibraryColors.textMuted,
                        ),
                      ),
                      suffixIcon: _searchQuery.isNotEmpty
                          ? IconButton(
                              icon: CaseLibrarySvgIcon(
                                CaseLibrarySvgIcons.xCircle,
                                size: 19.w,
                                color: CaseLibraryColors.textMuted,
                              ),
                              onPressed: () {
                                _searchController.clear();
                                setState(() {
                                  _searchQuery = '';
                                });
                                _performSearch();
                              },
                            )
                          : null,
                      hintText: '輸入案件名稱、法條、爭點或標籤...',
                      hintStyle: TextStyle(
                        fontSize: 13.sp,
                        color: CaseLibraryColors.textMuted,
                      ),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(vertical: 14.h),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 14.h),

              // Category Filter Chips Row
              SizedBox(
                height: 34.h,
                child: ListView.separated(
                  padding: EdgeInsets.symmetric(horizontal: 18.w),
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  itemCount: _categories.length,
                  separatorBuilder: (_, __) => SizedBox(width: 8.w),
                  itemBuilder: (context, index) {
                    final cat = _categories[index];
                    final isSelected = cat == _selectedCategory;
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedCategory = cat;
                        });
                      },
                      child: Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: 14.w, vertical: 6.h),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: isSelected
                              ? CaseLibraryColors.primaryGreen
                              : CaseLibraryColors.bgWhite,
                          borderRadius: BorderRadius.circular(16.r),
                          border: Border.all(
                            color: isSelected
                                ? CaseLibraryColors.primaryGreen
                                : CaseLibraryColors.borderLight,
                          ),
                        ),
                        child: Text(
                          cat == '司法爭議'
                              ? '司法制度'
                              : (cat == '全部'
                                  ? '全部領域'
                                  : cat.replaceAll('案件', '')),
                          style: TextStyle(
                            fontSize: 11.5.sp,
                            fontWeight: FontWeight.bold,
                            color: isSelected
                                ? CaseLibraryColors.bgWhite
                                : CaseLibraryColors.textSecondary,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              SizedBox(height: 16.h),

              // Results List
              Expanded(
                child: _isSearching
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const CupertinoActivityIndicator(
                              radius: 12,
                              color: CaseLibraryColors.primaryGreen,
                            ),
                            SizedBox(height: 12.h),
                            Text(
                              '正在檢索雲端裁判庫...',
                              style: TextStyle(
                                fontSize: 11.5.sp,
                                color: CaseLibraryColors.morandiGreen,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      )
                    : results.isEmpty
                        ? _buildEmptyState()
                        : ListView.separated(
                            keyboardDismissBehavior:
                                ScrollViewKeyboardDismissBehavior.onDrag,
                            padding: EdgeInsets.fromLTRB(18.w, 0, 18.w, 24.h),
                            itemCount: results.length,
                            separatorBuilder: (_, __) => SizedBox(height: 12.h),
                            itemBuilder: (context, index) {
                              final book = results[index];
                              return _buildSearchCaseCard(context, book);
                            },
                          ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSearchCaseCard(BuildContext context, CaseBook book) {
    return GestureDetector(
      onTap: () => _openCaseDetail(context, book),
      child: Container(
        padding: EdgeInsets.all(12.w),
        decoration: BoxDecoration(
          color: CaseLibraryColors.bgWhite,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: CaseLibraryColors.borderLight),
          boxShadow: [CaseLibraryShadows.softShadow],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Left Thumbnail
            ClipRRect(
              borderRadius: BorderRadius.circular(8.r),
              child: book.displayImages.isNotEmpty
                  ? CachedNetworkImage(
                      imageUrl: book.displayImages.first.url ?? '',
                      width: 72.w,
                      height: 72.h,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => const ShimmerSkeleton(
                        width: 72,
                        height: 72,
                        borderRadius: 0,
                      ),
                      errorWidget: (context, url, error) => Container(
                        width: 72.w,
                        height: 72.h,
                        color: CaseLibraryColors.bgCream,
                        child: Center(
                          child: CaseLibrarySvgIcon(
                            CaseLibrarySvgIcons.gavel,
                            size: 24.w,
                            color: CaseLibraryColors.primaryGreen,
                          ),
                        ),
                      ),
                    )
                  : Image.asset(
                      'assets/images/case_library_v2/case_library_v2_case_book_cover.png',
                      width: 72.w,
                      height: 72.h,
                      fit: BoxFit.cover,
                    ),
            ),
            SizedBox(width: 12.w),
            // Middle Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    book.titleZh,
                    style: CaseLibraryTextStyles.cardTitle(context).copyWith(
                      fontSize: 13.5.sp,
                      fontWeight: FontWeight.w900,
                      color: CaseLibraryColors.primaryGreen,
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    '${book.year} 年 | ${book.location} | ${book.status}',
                    style: TextStyle(
                      fontSize: 10.sp,
                      color: CaseLibraryColors.textMuted,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 6.h),
                  Text(
                    book.memoryLine.isNotEmpty
                        ? book.memoryLine
                        : book.shortDescription,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: CaseLibraryTextStyles.bodySmall(context).copyWith(
                      color: CaseLibraryColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            CaseLibrarySvgIcon(
              CaseLibrarySvgIcons.chevronRight,
              size: 20.sp,
              color: CaseLibraryColors.primaryGreen.withValues(alpha: 0.5),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 36.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CaseLibrarySvgIcon(
              CaseLibrarySvgIcons.searchOff,
              size: 64.sp,
              color: CaseLibraryColors.textMuted,
            ),
            SizedBox(height: 16.h),
            Text(
              '未找到相關案件',
              style: TextStyle(
                fontSize: 15.sp,
                fontWeight: FontWeight.bold,
                color: CaseLibraryColors.textPrimary,
              ),
            ),
            SizedBox(height: 6.h),
            Text(
              '請嘗試更改關鍵字或變更分類篩選條件，以尋找相關司法裁判資料。',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12.sp,
                color: CaseLibraryColors.textMuted,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
