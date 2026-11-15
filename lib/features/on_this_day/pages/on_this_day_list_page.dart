import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:preamble/components/shared/custom_toast.dart';
import 'package:preamble/features/on_this_day/data/on_this_day_local_bookmarks.dart';
import 'package:preamble/features/on_this_day/data/on_this_day_mock_data.dart';
import 'package:preamble/features/on_this_day/models/on_this_day_models.dart';
import 'package:preamble/features/on_this_day/pages/on_this_day_detail_page.dart';
import 'package:preamble/theme/preamble_tokens.dart';

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
    final t = context.tokens;

    return Scaffold(
      backgroundColor: t.canvas,
      appBar: AppBar(
        backgroundColor: t.canvas,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            PhosphorIconsRegular.caretLeft,
            color: t.textPrimary,
            size: 20.sp,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          '法治歷史事件總覽',
          style: t.serifTitle(size: 19.sp, weight: FontWeight.w800),
        ),
      ),
      body: Column(
        children: [
          SizedBox(
            height: 40.h,
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
                    padding: EdgeInsets.symmetric(
                      horizontal: 15.w,
                      vertical: 7.h,
                    ),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: isSelected ? t.brandPrimaryStrong : t.surface,
                      borderRadius: BorderRadius.circular(999.r),
                      border: Border.all(
                        color: isSelected ? t.brandPrimaryStrong : t.border,
                      ),
                    ),
                    child: Text(
                      cat,
                      style: t.sansBody(
                        size: 12.sp,
                        weight: FontWeight.w700,
                        color: isSelected
                            ? const Color(0xFFFAF8F4)
                            : t.textSecondary,
                        height: 1.2,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          SizedBox(height: 14.h),
          Expanded(
            child: ListView.separated(
              padding: EdgeInsets.fromLTRB(18.w, 0, 18.w, 28.h),
              itemCount: _filteredCases.length,
              separatorBuilder: (_, __) => SizedBox(height: 12.h),
              itemBuilder: (context, index) {
                return _buildListRow(t, _filteredCases[index]);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildListRow(PreambleTokens t, OnThisDayCase c) {
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
        padding: EdgeInsets.all(14.w),
        decoration: t.cardDecoration(radius: 18.r, elevated: false),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 68.w,
              padding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 6.w),
              decoration: BoxDecoration(
                color: t.surfaceSubtle,
                borderRadius: BorderRadius.circular(14.r),
                border: Border.all(
                  color: t.accentBrass.withValues(alpha: 0.4),
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '${c.year}',
                    style: t.tabularMetric(
                      size: 11.sp,
                      weight: FontWeight.w700,
                      color: t.accentBrass,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      '${c.month}/${c.day}',
                      style: t.serifTitle(
                        size: 16.sp,
                        weight: FontWeight.w800,
                        color: t.brandPrimary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(width: 14.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 7.w,
                          vertical: 2.h,
                        ),
                        decoration: BoxDecoration(
                          color: t.brandContainer,
                          borderRadius: BorderRadius.circular(6.r),
                        ),
                        child: Text(
                          c.category,
                          style: t.sansBody(
                            size: 10.5.sp,
                            weight: FontWeight.w700,
                            color: t.brandOnContainer,
                            height: 1.2,
                          ),
                        ),
                      ),
                      SizedBox(width: 6.w),
                      Expanded(
                        child: Text(
                          c.location,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: t.sansBody(
                            size: 11.sp,
                            color: t.textMuted,
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: () async {
                          final next =
                              await OnThisDayLocalBookmarks.toggle(c.id);
                          if (!mounted) return;
                          setState(() {
                            next
                                ? _savedCaseIds.add(c.id)
                                : _savedCaseIds.remove(c.id);
                          });
                          CustomToast.show(
                            context,
                            next ? '已加入本機收藏。' : '已從本機收藏移除。',
                          );
                        },
                        child: Padding(
                          padding: EdgeInsets.all(2.w),
                          child: Icon(
                            isSaved
                                ? PhosphorIconsFill.bookmarkSimple
                                : PhosphorIconsRegular.bookmarkSimple,
                            color: isSaved ? t.accentBrass : t.textMuted,
                            size: 18.sp,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 6.h),
                  Text(
                    c.title,
                    style: t.serifTitle(
                      size: 15.5.sp,
                      weight: FontWeight.w800,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    c.summary,
                    maxLines: 2,
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
      ),
    );
  }
}
