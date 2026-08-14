import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:preamble/components/shared/custom_toast.dart';
import 'package:preamble/data/law_assistant/law_assistant_models.dart';

/// 法律時效生死線倒數膠囊與行事曆連動元件。
///
/// 採用莫蘭迪琥珀金設計，提醒當事人法定救濟時效，並支援一鍵加入行事曆。
class StatuteCountdownBadge extends StatelessWidget {
  const StatuteCountdownBadge({
    super.key,
    required this.deadline,
  });

  final LegalStatuteDeadline deadline;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final bgAmber =
        isDark ? const Color(0xFF332918) : const Color(0xFFFDF6E8);
    final borderAmber =
        isDark ? const Color(0xFF5C4724) : const Color(0xFFEBD8B0);
    final textAmber =
        isDark ? const Color(0xFFE5C07B) : const Color(0xFF9E6800);

    return Container(
      margin: EdgeInsets.only(bottom: 10.h),
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: bgAmber,
        borderRadius: BorderRadius.circular(10.r),
        border: Border.all(color: borderAmber, width: 1.w),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.hourglass_top_rounded,
                size: 15.sp,
                color: textAmber,
              ),
              SizedBox(width: 6.w),
              Expanded(
                child: Text(
                  '⏳ 法律時效生死線：${deadline.title}',
                  style: TextStyle(
                    fontSize: 11.5.sp,
                    fontWeight: FontWeight.bold,
                    color: textAmber,
                  ),
                ),
              ),
              // 加入行事曆按鈕
              GestureDetector(
                onTap: () => _handleAddToCalendar(context),
                child: Container(
                  padding:
                      EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
                  decoration: BoxDecoration(
                    color: textAmber.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(6.r),
                    border: Border.all(color: textAmber, width: 0.8.w),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.calendar_today_rounded,
                          size: 11.sp, color: textAmber),
                      SizedBox(width: 4.w),
                      Text(
                        '加到行事曆',
                        style: TextStyle(
                          fontSize: 10.sp,
                          fontWeight: FontWeight.bold,
                          color: textAmber,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 4.h),
          Text(
            '【${deadline.legalBasis}】${deadline.urgencyDescription}',
            style: TextStyle(
              fontSize: 10.5.sp,
              height: 1.35,
              color: isDark ? const Color(0xFFD8C7A5) : const Color(0xFF5C4724),
            ),
          ),
          if (deadline.warningNote.isNotEmpty) ...[
            SizedBox(height: 2.h),
            Text(
              '⚠️ ${deadline.warningNote}',
              style: TextStyle(
                fontSize: 10.sp,
                fontWeight: FontWeight.w600,
                color: isDark ? const Color(0xFFE5A07B) : const Color(0xFFBA4A00),
              ),
            ),
          ],
        ],
      ),
    );
  }

  void _handleAddToCalendar(BuildContext context) {
    HapticFeedback.mediumImpact();
    final targetDate =
        DateTime.now().add(Duration(days: deadline.durationDays));
    final dateStr = '${targetDate.year}/${targetDate.month}/${targetDate.day}';

    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
        title: Row(
          children: [
            Icon(Icons.event_available_rounded,
                color: const Color(0xFF2C5E43), size: 22.sp),
            SizedBox(width: 8.w),
            Text('加入系統行事曆提醒', style: TextStyle(fontSize: 15.sp)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('事件標題：${deadline.title} - 救濟時效截止日',
                style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.bold)),
            SizedBox(height: 4.h),
            Text('預估截止日期：$dateStr (尚餘 ${deadline.durationDays} 天)',
                style: TextStyle(fontSize: 11.5.sp, color: const Color(0xFF9E6800))),
            SizedBox(height: 8.h),
            Text('系統將於到期前 7 天與前 1 天發送推播通知，確保您的法律救濟權益不受時效消滅影響。',
                style: TextStyle(fontSize: 11.sp, color: Colors.grey.shade700, height: 1.4)),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('取消'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              CustomToast.show(
                context,
                '✅ 已成功將「${deadline.title}」加入行事曆提醒！',
                icon: Icons.check_circle_outline_rounded,
              );
            },
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFF2C5E43),
            ),
            child: const Text('確認寫入'),
          ),
        ],
      ),
    );
  }
}
