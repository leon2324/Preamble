import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// 小法助 AI 對話智慧追問建議按鈕列。
class LawAssistantSuggestedPrompts extends StatelessWidget {
  const LawAssistantSuggestedPrompts({
    super.key,
    required this.onSelectPrompt,
    this.prompts = const [
      '該如何蒐集與保存相關證據？',
      '民刑事求償的法定消滅時效多久？',
      '如果對方拒絕回應，下一步該怎麼做？',
    ],
  });

  final ValueChanged<String> onSelectPrompt;
  final List<String> prompts;

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFF2C5E43); // 莫蘭迪綠

    return Container(
      margin: EdgeInsets.only(top: 10.h, bottom: 6.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.lightbulb_outline_rounded,
                size: 14.sp,
                color: primaryColor,
              ),
              SizedBox(width: 4.w),
              Text(
                '延伸追問建議',
                style: TextStyle(
                  fontSize: 11.5.sp,
                  fontWeight: FontWeight.bold,
                  color: primaryColor,
                ),
              ),
            ],
          ),
          SizedBox(height: 8.h),
          Wrap(
            spacing: 8.w,
            runSpacing: 8.h,
            children: prompts.map((prompt) {
              return InkWell(
                onTap: () => onSelectPrompt(prompt),
                borderRadius: BorderRadius.circular(20.r),
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF5F8F6),
                    borderRadius: BorderRadius.circular(20.r),
                    border: Border.all(color: const Color(0xFFB8DAC8)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        prompt,
                        style: TextStyle(
                          fontSize: 11.5.sp,
                          color: const Color(0xFF2C3E35),
                        ),
                      ),
                      SizedBox(width: 4.w),
                      Icon(
                        Icons.north_east_rounded,
                        size: 12.sp,
                        color: primaryColor,
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
