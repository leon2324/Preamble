import 'package:flutter/cupertino.dart';
import 'package:preamble/components/shared/custom_toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:preamble/features/on_this_day/data/on_this_day_local_bookmarks.dart';
import 'package:preamble/features/on_this_day/data/on_this_day_mock_data.dart';
import 'package:preamble/features/on_this_day/models/on_this_day_models.dart';
import 'package:preamble/features/on_this_day/theme/on_this_day_theme.dart';
import 'package:preamble/features/on_this_day/pages/on_this_day_detail_page.dart';

class OnThisDayListPage extends StatefulWidget {
  const OnThisDayListPage({super.key});

  @override
  State<OnThisDayListPage> createState() => _OnThisDayListPageState();
}

class _OnThisDayListPageState extends State<OnThisDayListPage> {
  final List<String> _categories = ['全部', '言論自由', '民主運動', '公共安全', '司法爭議'];
  String _selectedCategory = '全部';
  List<OnThisDayCase> _filteredCases = [];
  final Set<String> _savedCaseIds = <String>{};

  @override
  void initState() {
    super.initState();
    _loadFilteredCases();
    _loadSavedCases();
  }

  Future<void> _loadSavedCases() async {
    final ids = await OnThisDayLocalBookmarks.load();
    if (!mounted) return;
    setState(() {
      _savedCaseIds
        ..clear()
        ..addAll(ids);
    });
  }

  void _loadFilteredCases() {
    setState(() {
      if (_selectedCategory == '全部') {
        _filteredCases = onThisDayCases;
      } else {
        _filteredCases = onThisDayCases
            .where((c) =>
                c.category == _selectedCategory ||
                c.tags.contains(_selectedCategory))
            .toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: OnThisDayColors.paperBeige,
      appBar: AppBar(
        backgroundColor: OnThisDayColors.paperBeige,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              color: OnThisDayColors.primaryGreen),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          '歷史案件',
          style:
              OnThisDayTextStyles.pageTitle(context).copyWith(fontSize: 20.sp),
        ),
      ),
      body: Column(
        children: [
          // Horizontal Category Tabs
          SizedBox(
            height: 44.h,
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
                      _loadFilteredCases();
                    });
                  },
                  child: Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: isSelected
                          ? OnThisDayColors.primaryGreen
                          : OnThisDayColors.bgCream.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(20.r),
                      border: Border.all(
                        color: isSelected
                            ? OnThisDayColors.primaryGreen
                            : OnThisDayColors.borderLight,
                      ),
                    ),
                    child: Text(
                      cat,
                      style: TextStyle(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w900,
                        color: isSelected
                            ? OnThisDayColors.bgPaperLight
                            : OnThisDayColors.textSecondary,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          SizedBox(height: 16.h),

          // Case List
          Expanded(
            child: ListView.separated(
              padding: EdgeInsets.fromLTRB(18.w, 0, 18.w, 24.h),
              itemCount: _filteredCases.length,
              separatorBuilder: (_, __) => SizedBox(height: 12.h),
              itemBuilder: (context, index) {
                final c = _filteredCases[index];
                return _buildListRow(c);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildListRow(OnThisDayCase c) {
    final isSaved = _savedCaseIds.contains(c.id);
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          CupertinoPageRoute<void>(
            builder: (__) => OnThisDayDetailPage(caseId: c.id),
          ),
        );
      },
      child: Container(
        padding: EdgeInsets.all(12.w),
        decoration: BoxDecoration(
          color: OnThisDayColors.bgPaperLight,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(color: OnThisDayColors.borderLight),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Retro vintage photo thumbnail placeholder
            Container(
              width: 72.w,
              height: 72.w,
              decoration: BoxDecoration(
                color: const Color(0xFFE5DCD0),
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(color: OnThisDayColors.borderLight),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12.r),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Container(
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Color(0xFF4A3E3D), Color(0xFF2C2424)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                    ),
                    Center(
                      child: Opacity(
                        opacity: 0.15,
                        child: Icon(Icons.history_edu_rounded,
                            color: Colors.white, size: 28.sp),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(width: 14.w),

            // Details Column
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${c.year} · ${c.category}',
                        style: TextStyle(
                          fontSize: 11.sp,
                          fontWeight: FontWeight.w900,
                          color: OnThisDayColors.accentGold,
                        ),
                      ),
                      IconButton(
                        icon: Icon(
                          isSaved
                              ? Icons.bookmark_rounded
                              : Icons.bookmark_border_rounded,
                          color: OnThisDayColors.accentGold,
                        ),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        iconSize: 18.sp,
                        onPressed: () async {
                          final next =
                              await OnThisDayLocalBookmarks.toggle(c.id);
                          if (!mounted) return;
                          setState(() {
                            next
                                ? _savedCaseIds.add(c.id)
                                : _savedCaseIds.remove(c.id);
                          });
                          CustomToast.show(context, next ? '已加入本機收藏。' : '已從本機收藏移除。');

                        },
                      ),
                    ],
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    c.title,
                    style: OnThisDayTextStyles.cardTitle(context)
                        .copyWith(fontSize: 14.sp),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    c.summary,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: OnThisDayTextStyles.body(context).copyWith(
                      fontSize: 11.5.sp,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
