import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:preamble/features/case_library/theme/case_library_theme.dart';
import 'package:preamble/features/case_library/widgets/case_library_svg_icon.dart';

// 現代扁平質感的小法助 AI 捷徑卡片。左側圓圈直接呈現經典的「小法助男生」頭像圖片，
// 完美符合使用者對於小法助形象的一致性期待。
class CaseLibraryAssistantCard extends StatelessWidget {
  const CaseLibraryAssistantCard({
    super.key,
    required this.onTap,
  });

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(14.w),
        decoration: BoxDecoration(
          color: const Color(0xFFF4F3FA),
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(
            color: const Color(0xFFE0DCF2),
            width: 1.2,
          ),
          boxShadow: [CaseLibraryShadows.softShadow],
        ),
        child: Row(
          children: [
            // 小法助頭像圓圈
            Container(
              width: 38.w,
              height: 38.w,
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              child: ClipOval(
                child: Image.asset(
                  'assets/images/assistant/law_assistant_home.png',
                  width: 38.w,
                  height: 38.w,
                  fit: BoxFit.cover,
                  alignment: Alignment.topCenter,
                ),
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: 7.w, vertical: 2.h),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(99),
                        ),
                        child: Text(
                          'AI 輔助',
                          style: TextStyle(
                            fontSize: 8.5.sp,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF6D649A),
                          ),
                        ),
                      ),
                      SizedBox(width: 6.w),
                      Text(
                        '小法助捷徑',
                        style: TextStyle(
                          fontSize: 10.sp,
                          fontWeight: FontWeight.w900,
                          color: const Color(0xFF6D649A),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    '有類似的法律困惑？問問 AI 小法助！',
                    style: TextStyle(
                      fontSize: 11.5.sp,
                      fontWeight: FontWeight.bold,
                      color: CaseLibraryColors.primaryGreen,
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    '輸入生活遇到的事件情境，快速解析可能的法規方向。',
                    style: TextStyle(
                      fontSize: 9.5.sp,
                      color: CaseLibraryColors.textMuted,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(width: 8.w),
            CaseLibrarySvgIcon(
              CaseLibrarySvgIcons.chevronRight,
              size: 14.sp,
              color: const Color(0xFF6D649A),
            ),
          ],
        ),
      ),
    );
  }
}
