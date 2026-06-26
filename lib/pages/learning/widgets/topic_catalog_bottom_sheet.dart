import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lawapp/components/home/v2/home_v2_palette.dart';
import 'package:lawapp/data/learning/learning_game_state.dart';
import 'package:lawapp/data/learning/supabase_learning_service.dart';
import 'package:lawapp/data/mock_data/learning/learning_mock_data.dart';
import 'package:lawapp/features/case_time_machine/widgets/case_time_machine_svg_icon.dart';
import 'package:lawapp/theme/app_colors.dart';

/// 全部專題分類庫 BottomSheet。
///
/// 此 Widget 從 know_law_page.dart 拆出（Step 4C），完全自包含，
/// 內部自行管理分類篩選狀態與 Supabase fetch，只透過 [onArticleTap] 回呼
/// 將使用者選擇的文章傳回給呼叫方。
class LearningTopicCatalogBottomSheet extends StatefulWidget {
  const LearningTopicCatalogBottomSheet({
    super.key,
    required this.initialCategory,
    required this.isDark,
    required this.onArticleTap,
  });

  final String? initialCategory;
  final bool isDark;
  final Function(LearningMockArticle) onArticleTap;

  @override
  State<LearningTopicCatalogBottomSheet> createState() =>
      _LearningTopicCatalogBottomSheetState();
}

class _LearningTopicCatalogBottomSheetState
    extends State<LearningTopicCatalogBottomSheet> {
  late String _selectedCategory;
  String _searchQuery = '';
  late Future<List<LearningMockArticle>> _future;

  @override
  void initState() {
    super.initState();
    _selectedCategory = widget.initialCategory ?? '全部';
    _fetchData();
  }

  void _fetchData() {
    _future = SupabaseLearningService.instance.fetchArticles(
      category: _selectedCategory == '全部' ? null : _selectedCategory,
      query: _searchQuery.isEmpty ? null : _searchQuery,
      limit: 50,
    );
  }

  @override
  Widget build(BuildContext context) {
    final List<String> catalogCategories = [
      '全部',
      '租屋糾紛',
      '車禍事故',
      '職場權益',
      '網購消費',
      '個資隱私',
      '鄰里生活',
      '婚姻家庭',
      '防詐騙常識'
    ];

    return DraggableScrollableSheet(
      initialChildSize: 0.82,
      minChildSize: 0.50,
      maxChildSize: 0.95,
      expand: false,
      builder: (sheetContext, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: widget.isDark
                ? const Color(0xFF161C23)
                : const Color(0xFFFFFCF4),
            borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
          ),
          child: Column(
            children: [
              SizedBox(height: 10.h),
              Center(
                child: Container(
                  width: 42.w,
                  height: 4.h,
                  decoration: BoxDecoration(
                    color: widget.isDark
                        ? const Color(0xFF354454)
                        : const Color(0xFFD8D0C2),
                    borderRadius: BorderRadius.circular(99.r),
                  ),
                ),
              ),
              SizedBox(height: 16.h),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.w),
                child: Row(
                  children: [
                    Text(
                      '全部專題分類庫 📚',
                      style: TextStyle(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.w900,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 12.h),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.w),
                child: TextField(
                  onTapOutside: (event) {
                    FocusManager.instance.primaryFocus?.unfocus();
                  },
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value;
                      _fetchData();
                    });
                  },
                  decoration: InputDecoration(
                    hintText: '搜尋生活法律情境、關鍵字...',
                    hintStyle: TextStyle(fontSize: 12.sp, color: Colors.grey),
                    prefixIcon: Padding(
                      padding: EdgeInsets.all(10.w),
                      child: CtmSvgIcon(
                        CtmSvgIcons.search,
                        size: 16.sp,
                        color: Colors.grey,
                      ),
                    ),
                    filled: true,
                    fillColor: widget.isDark
                        ? const Color(0xFF232B35)
                        : const Color(0xFFF5EFE2),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14.r),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: EdgeInsets.symmetric(vertical: 8.h),
                  ),
                  style:
                      TextStyle(fontSize: 13.sp, color: AppColors.textPrimary),
                ),
              ),
              SizedBox(height: 12.h),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                child: Row(
                  children: catalogCategories.map((cat) {
                    final isSelected = _selectedCategory == cat;
                    return Padding(
                      padding: EdgeInsets.only(right: 6.w),
                      child: ChoiceChip(
                        label: Text(
                          cat,
                          style: TextStyle(
                            fontSize: 11.sp,
                            fontWeight: FontWeight.bold,
                            color: isSelected
                                ? Colors.white
                                : AppColors.textPrimary,
                          ),
                        ),
                        selected: isSelected,
                        onSelected: (selected) {
                          if (selected) {
                            setState(() {
                              _selectedCategory = cat;
                              _fetchData();
                            });
                          }
                        },
                        selectedColor: HomeV2Palette.trustGreen,
                        backgroundColor: widget.isDark
                            ? const Color(0xFF232B35)
                            : const Color(0xFFF5EFE2),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(999.r),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
              SizedBox(height: 10.h),
              Expanded(
                child: FutureBuilder<List<LearningMockArticle>>(
                  future: _future,
                  builder: (context, snapshot) {
                    final List<LearningMockArticle> list = snapshot.data ?? [];

                    return CustomScrollView(
                      keyboardDismissBehavior:
                          ScrollViewKeyboardDismissBehavior.onDrag,
                      controller: scrollController,
                      physics: const AlwaysScrollableScrollPhysics(),
                      slivers: [
                        if (snapshot.connectionState == ConnectionState.waiting)
                          SliverFillRemaining(
                            hasScrollBody: false,
                            child: Center(
                              child: CircularProgressIndicator(
                                valueColor: AlwaysStoppedAnimation<Color>(
                                    HomeV2Palette.trustGreen),
                              ),
                            ),
                          )
                        else if (snapshot.hasError)
                          const SliverFillRemaining(
                            hasScrollBody: false,
                            child: Center(
                              child: Text('載入失敗，請稍後再試'),
                            ),
                          )
                        else if (list.isEmpty)
                          SliverFillRemaining(
                            hasScrollBody: false,
                            child: Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text('🔍', style: TextStyle(fontSize: 32.sp)),
                                  SizedBox(height: 8.h),
                                  Text(
                                    '找不到符合的情境專題',
                                    style: TextStyle(
                                      fontSize: 13.sp,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )
                        else
                          SliverPadding(
                            padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 20.h),
                            sliver: SliverGrid(
                              gridDelegate:
                                  SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                mainAxisSpacing: 10.h,
                                crossAxisSpacing: 10.w,
                                childAspectRatio: 1.06,
                              ),
                              delegate: SliverChildBuilderDelegate(
                                (context, index) {
                                  final article = list[index];
                                  final cat = article.category ?? '法律常識';

                                  Color cardBg;
                                  Color textColor;
                                  Color accentColor;

                                  if (widget.isDark) {
                                    cardBg = const Color(0xFF1E252E);
                                    textColor = Colors.white;
                                    accentColor = HomeV2Palette.trustGreen;
                                  } else {
                                    switch (cat) {
                                      case '租屋糾紛':
                                        cardBg = const Color(0xFFE8F5E9);
                                        accentColor = const Color(0xFF2E7D32);
                                        break;
                                      case '車禍事故':
                                        cardBg = const Color(0xFFE3F2FD);
                                        accentColor = const Color(0xFF1565C0);
                                        break;
                                      case '職場權益':
                                        cardBg = const Color(0xFFFFF3E0);
                                        accentColor = const Color(0xFFE65100);
                                        break;
                                      case '網購消費':
                                        cardBg = const Color(0xFFFCE4EC);
                                        accentColor = const Color(0xFFC2185B);
                                        break;
                                      case '個資隱私':
                                        cardBg = const Color(0xFFEDE7F6);
                                        accentColor = const Color(0xFF512DA8);
                                        break;
                                      case '鄰里生活':
                                        cardBg = const Color(0xFFE0F2F1);
                                        accentColor = const Color(0xFF00796B);
                                        break;
                                      case '婚姻家庭':
                                        cardBg = const Color(0xFFFDF2E9);
                                        accentColor = const Color(0xFFA04000);
                                        break;
                                      case '防詐騙常識':
                                        cardBg = const Color(0xFFECEFF1);
                                        accentColor = const Color(0xFF37474F);
                                        break;
                                      default:
                                        cardBg = const Color(0xFFFFFDF5);
                                        accentColor = HomeV2Palette.trustGreen;
                                    }
                                    textColor = AppColors.textPrimary;
                                  }

                                  return GestureDetector(
                                    onTap: () {
                                      Navigator.of(sheetContext).pop();
                                      widget.onArticleTap(article);
                                    },
                                    child: Container(
                                      padding: EdgeInsets.all(12.w),
                                      decoration: BoxDecoration(
                                        color: cardBg,
                                        borderRadius:
                                            BorderRadius.circular(16.r),
                                        border: Border.all(
                                          color: widget.isDark
                                              ? const Color(0xFF2C3845)
                                              : accentColor.withValues(
                                                  alpha: 0.15),
                                          width: 1.w,
                                        ),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black
                                                .withValues(alpha: 0.03),
                                            blurRadius: 4,
                                            offset: const Offset(0, 2),
                                          ),
                                        ],
                                      ),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              Container(
                                                padding: EdgeInsets.symmetric(
                                                    horizontal: 6.w,
                                                    vertical: 2.h),
                                                decoration: BoxDecoration(
                                                  color: widget.isDark
                                                      ? const Color(0xFF354454)
                                                      : Colors.white.withValues(
                                                          alpha: 0.72),
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          6.r),
                                                ),
                                                child: Text(
                                                  cat,
                                                  style: TextStyle(
                                                    fontSize: 9.sp,
                                                    fontWeight: FontWeight.bold,
                                                    color: widget.isDark
                                                        ? Colors.white70
                                                        : accentColor,
                                                  ),
                                                ),
                                              ),
                                              const Spacer(),
                                              if (LearningGameState
                                                  .instance.savedArticles
                                                  .contains(article.title))
                                                CtmSvgIcon(
                                                  CtmSvgIcons.bookmark,
                                                  size: 11.sp,
                                                  color:
                                                      const Color(0xFFE8B95F),
                                                ),
                                            ],
                                          ),
                                          SizedBox(height: 8.h),
                                          Text(
                                            article.title,
                                            style: TextStyle(
                                              fontSize: 12.5.sp,
                                              fontWeight: FontWeight.w900,
                                              color: textColor,
                                              height: 1.3,
                                            ),
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          SizedBox(height: 6.h),
                                          Text(
                                            article.summary,
                                            style: TextStyle(
                                              fontSize: 10.sp,
                                              color: widget.isDark
                                                  ? Colors.white60
                                                  : AppColors.textSecondary,
                                              height: 1.3,
                                            ),
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          const Spacer(),
                                          Row(
                                            children: [
                                              CtmSvgIcon(
                                                CtmSvgIcons.clock,
                                                size: 11.sp,
                                                color: widget.isDark
                                                    ? Colors.white38
                                                    : Colors.grey,
                                              ),
                                              SizedBox(width: 4.w),
                                              Text(
                                                article.readTime,
                                                style: TextStyle(
                                                  fontSize: 9.5.sp,
                                                  color: widget.isDark
                                                      ? Colors.white38
                                                      : Colors.grey,
                                                ),
                                              ),
                                              const Spacer(),
                                              Text(
                                                '★' *
                                                        ((article.title.length %
                                                                3) +
                                                            1) +
                                                    '☆' *
                                                        (3 -
                                                            ((article.title
                                                                        .length %
                                                                    3) +
                                                                1)),
                                                style: TextStyle(
                                                  fontSize: 10.sp,
                                                  fontWeight: FontWeight.bold,
                                                  color:
                                                      const Color(0xFFE8B95F),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                                childCount: list.length,
                              ),
                            ),
                          ),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
