import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:preamble/features/case_library/data/case_library_data.dart';
import 'package:preamble/features/case_library/models/case_library_models.dart';
import 'package:preamble/features/case_library/theme/case_library_theme.dart';
import 'package:preamble/features/case_library/widgets/case_library_section_header.dart';

// 熱門案源探索輪播元件。採用現代橫向扁平卡片設計：
// 白底圓角卡片，頂部並列分類標籤與年代，中間為案件名稱（宋體），
// 右下角為暖金色的「切換研讀 ➔」按鈕。移除木製書架與垂直書脊等擬物化風格。
class CaseLibraryCuratedCarousel extends StatelessWidget {
  const CaseLibraryCuratedCarousel({
    super.key,
    required this.selectedCase,
    required this.onSelectCase,
    required this.onViewAllTap,
  });

  final CaseBook selectedCase;
  final ValueChanged<CaseBook> onSelectCase;
  final VoidCallback onViewAllTap;

  @override
  Widget build(BuildContext context) {
    final listIds = ['318', '799', '499', '520', '161', '124'];
    final recommendedBooks = listIds
        .where((id) => id != selectedCase.id)
        .map(caseLibraryCaseById)
        .toList();

    // 每張卡片使用不同的淡雅主題色底，形成視覺層次
    final cardAccentColors = [
      const Color(0xFFEAF6EF), // 淡翠綠
      const Color(0xFFF0EEF9), // 淡薰衣草紫
      const Color(0xFFEAF4F7), // 淡天空藍
      const Color(0xFFFFF2CF), // 淡金黃
      const Color(0xFFF8EEF0), // 淡玫瑰粉
    ];

    final cardTextColors = [
      const Color(0xFF357A53),
      const Color(0xFF6D649A),
      const Color(0xFF4A7C8C),
      const Color(0xFF9E7B2D),
      const Color(0xFF8C4A5A),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CaseLibrarySectionHeader(
          title: '熱門探索案源',
          actionText: '查看全部',
          onActionTap: onViewAllTap,
        ),
        SizedBox(height: 9.h),
        SizedBox(
          height: 132.h,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            itemCount: recommendedBooks.length,
            itemBuilder: (context, idx) {
              final book = recommendedBooks[idx];
              final accentColor =
                  cardAccentColors[idx % cardAccentColors.length];
              final textColor = cardTextColors[idx % cardTextColors.length];
              final primaryTag =
                  book.tags.isNotEmpty ? book.tags.first : book.category;

              return GestureDetector(
                onTap: () => onSelectCase(book),
                child: Container(
                  width: 168.w,
                  margin: EdgeInsets.only(right: 10.w),
                  padding: EdgeInsets.all(12.w),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14.r),
                    border: Border.all(
                      color: const Color(0xFFE5DFD3),
                      width: 1.2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.03),
                        blurRadius: 6,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 頂部標籤列 — 分類 + 年代並列
                      Row(
                        children: [
                          Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 6.w, vertical: 2.5.h),
                            decoration: BoxDecoration(
                              color: accentColor,
                              borderRadius: BorderRadius.circular(6.r),
                            ),
                            child: Text(
                              primaryTag,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 8.5.sp,
                                fontWeight: FontWeight.bold,
                                color: textColor,
                              ),
                            ),
                          ),
                          SizedBox(width: 5.w),
                          Text(
                            '${book.year}',
                            style: TextStyle(
                              fontSize: 9.sp,
                              fontWeight: FontWeight.w600,
                              color: CaseLibraryColors.textMuted,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 8.h),
                      // 案件名稱主標題
                      Expanded(
                        child: Text(
                          book.titleZh,
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontFamily: 'Songti TC',
                            fontFamilyFallback: const [
                              'Songti SC',
                              'STSong',
                              'BiauKai',
                              'PingFang TC'
                            ],
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w800,
                            color: const Color(0xFF173C37),
                            height: 1.35,
                          ),
                        ),
                      ),
                      SizedBox(height: 8.h),
                      // 右下角暖金色「切換研讀 ➔」CTA
                      Align(
                        alignment: Alignment.centerRight,
                        child: Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: 8.w, vertical: 4.h),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFF2CF),
                            borderRadius: BorderRadius.circular(8.r),
                          ),
                          child: Text(
                            '切換研讀 ➔',
                            style: TextStyle(
                              fontSize: 9.5.sp,
                              fontWeight: FontWeight.w900,
                              color: const Color(0xFF8C642B),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
