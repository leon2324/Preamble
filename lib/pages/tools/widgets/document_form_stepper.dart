import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// 步驟化進度條指示器 (Step 1 / 2 / 3)。
class DocumentFormStepper extends StatelessWidget {
  const DocumentFormStepper({
    super.key,
    required this.currentStep,
  });

  /// 1 = 情境, 2 = 補充資料, 3 = 預覽草稿
  final int currentStep;

  @override
  Widget build(BuildContext context) {
    const activeColor = Color(0xFF2C5E43); // 莫蘭迪綠
    const inactiveColor = Color(0xFFE2E8E4);
    const textMuted = Color(0xFF7A8B80);

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: const Color(0xFFEDEFEF)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          _StepDot(
            stepNumber: 1,
            label: '選擇情境',
            isActive: currentStep >= 1,
            isCurrent: currentStep == 1,
            activeColor: activeColor,
            inactiveColor: inactiveColor,
            textMuted: textMuted,
          ),
          _StepLine(isActive: currentStep >= 2, activeColor: activeColor),
          _StepDot(
            stepNumber: 2,
            label: '補充資料',
            isActive: currentStep >= 2,
            isCurrent: currentStep == 2,
            activeColor: activeColor,
            inactiveColor: inactiveColor,
            textMuted: textMuted,
          ),
          _StepLine(isActive: currentStep >= 3, activeColor: activeColor),
          _StepDot(
            stepNumber: 3,
            label: '預覽草稿',
            isActive: currentStep >= 3,
            isCurrent: currentStep == 3,
            activeColor: activeColor,
            inactiveColor: inactiveColor,
            textMuted: textMuted,
          ),
        ],
      ),
    );
  }
}

class _StepDot extends StatelessWidget {
  const _StepDot({
    required this.stepNumber,
    required this.label,
    required this.isActive,
    required this.isCurrent,
    required this.activeColor,
    required this.inactiveColor,
    required this.textMuted,
  });

  final int stepNumber;
  final String label;
  final bool isActive;
  final bool isCurrent;
  final Color activeColor;
  final Color inactiveColor;
  final Color textMuted;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: isCurrent ? 28.w : 24.w,
          height: isCurrent ? 28.w : 24.w,
          decoration: BoxDecoration(
            color: isActive ? activeColor : inactiveColor,
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              '$stepNumber',
              style: TextStyle(
                fontSize: 12.sp,
                fontWeight: FontWeight.bold,
                color: isActive ? Colors.white : textMuted,
              ),
            ),
          ),
        ),
        SizedBox(height: 4.h),
        Text(
          label,
          style: TextStyle(
            fontSize: 11.sp,
            fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
            color: isActive ? activeColor : textMuted,
          ),
        ),
      ],
    );
  }
}

class _StepLine extends StatelessWidget {
  const _StepLine({required this.isActive, required this.activeColor});

  final bool isActive;
  final Color activeColor;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        height: 2.h,
        margin: EdgeInsets.symmetric(horizontal: 6.w),
        color: isActive ? activeColor : const Color(0xFFE2E8E4),
      ),
    );
  }
}

/// 快速範例帶入工具列。
class DocumentQuickFillBar extends StatelessWidget {
  const DocumentQuickFillBar({
    super.key,
    required this.onQuickFill,
  });

  final VoidCallback onQuickFill;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onQuickFill,
      borderRadius: BorderRadius.circular(8.r),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
        decoration: BoxDecoration(
          color: const Color(0xFFEAF4EE),
          borderRadius: BorderRadius.circular(8.r),
          border: Border.all(color: const Color(0xFFB8DAC8)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.auto_awesome_rounded,
              size: 14.sp,
              color: const Color(0xFF2C5E43),
            ),
            SizedBox(width: 4.w),
            Text(
              '一鍵帶入預設範例',
              style: TextStyle(
                fontSize: 11.5.sp,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF2C5E43),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 填表完整度計量器。
class DocumentFormCompletenessBar extends StatelessWidget {
  const DocumentFormCompletenessBar({
    super.key,
    required this.completenessRatio,
  });

  /// 0.0 ~ 1.0 (例如 0.8 代表 80%)
  final double completenessRatio;

  @override
  Widget build(BuildContext context) {
    const activeColor = Color(0xFF2C5E43);
    final percentage = (completenessRatio.clamp(0.0, 1.0) * 100).toInt();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '填表完成度',
              style: TextStyle(
                fontSize: 11.5.sp,
                color: const Color(0xFF5A6E63),
              ),
            ),
            Text(
              '$percentage %',
              style: TextStyle(
                fontSize: 12.sp,
                fontWeight: FontWeight.bold,
                color: activeColor,
              ),
            ),
          ],
        ),
        SizedBox(height: 4.h),
        ClipRRect(
          borderRadius: BorderRadius.circular(4.r),
          child: LinearProgressIndicator(
            value: completenessRatio.clamp(0.0, 1.0),
            backgroundColor: const Color(0xFFE2E8E4),
            color: activeColor,
            minHeight: 6.h,
          ),
        ),
      ],
    );
  }
}
