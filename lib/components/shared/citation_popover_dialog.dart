import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:preamble/data/statutes/statute_item.dart';
import 'package:preamble/pages/learning/statute_database_page.dart';

/// 法條 Citation 懸浮預覽卡片對話框。
class CitationPopoverDialog extends StatelessWidget {
  const CitationPopoverDialog({
    super.key,
    required this.statuteItem,
  });

  final StatuteItem statuteItem;

  static Future<void> show(BuildContext context, StatuteItem item) {
    return showDialog<void>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.35),
      builder: (_) => CitationPopoverDialog(statuteItem: item),
    );
  }

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFF2C5E43); // 莫蘭迪綠
    const bgCardColor = Color(0xFFF5F8F6);

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20.r),
      ),
      insetPadding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 40.h),
      child: Container(
        padding: EdgeInsets.all(20.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20.r),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 頂欄 Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEAF4EE),
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Text(
                    statuteItem.category,
                    style: TextStyle(
                      fontSize: 11.5.sp,
                      fontWeight: FontWeight.bold,
                      color: primaryColor,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close_rounded),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  iconSize: 20.sp,
                ),
              ],
            ),
            SizedBox(height: 12.h),

            // 法規名稱與條號
            Text(
              statuteItem.displayTitle,
              style: TextStyle(
                fontSize: 17.sp,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF17231F),
              ),
            ),
            SizedBox(height: 10.h),

            // 條文摘要內文卡片
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(14.w),
              decoration: BoxDecoration(
                color: bgCardColor,
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(color: const Color(0xFFB8DAC8)),
              ),
              child: Text(
                statuteItem.articleText,
                maxLines: 6,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 13.sp,
                  height: 1.5,
                  color: const Color(0xFF2C3E35),
                ),
              ),
            ),
            SizedBox(height: 14.h),

            // 標籤群
            Wrap(
              spacing: 6.w,
              runSpacing: 6.h,
              children: statuteItem.tags.map((tag) {
                return Container(
                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEDEFEF),
                    borderRadius: BorderRadius.circular(6.r),
                  ),
                  child: Text(
                    '# $tag',
                    style: TextStyle(
                      fontSize: 10.5.sp,
                      color: const Color(0xFF5A6E63),
                    ),
                  ),
                );
              }).toList(),
            ),
            SizedBox(height: 18.h),

            // 底欄按鈕
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.of(context).pop();
                  Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => StatuteDetailPage(item: statuteItem),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: 12.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  elevation: 0,
                ),
                icon: Icon(Icons.auto_stories_rounded, size: 16.sp),
                label: Text(
                  '閱讀完整法規條文',
                  style: TextStyle(
                    fontSize: 13.5.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
