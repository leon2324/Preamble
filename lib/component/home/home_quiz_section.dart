import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lawapp/component/home/home_content.dart';
import 'package:lawapp/component/home/home_section_title.dart';
import 'package:lawapp/theme/app_colors.dart';

class HomeQuizSection extends StatelessWidget {
  const HomeQuizSection({
    super.key,
    required this.selectedQuizIndex,
    required this.showQuizResult,
    required this.quizOptions,
    required this.onSelect,
    required this.onSubmit,
  });

  static const double _itemGap = 18;

  final int? selectedQuizIndex;
  final bool showQuizResult;
  final List<HomeQuizOption> quizOptions;
  final ValueChanged<int> onSelect;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const HomeSectionTitle(title: '給你的小任務(*¯︶¯*)'),
        SizedBox(height: 20.h),
        Container(
          padding: EdgeInsets.all(16.w),
          decoration: BoxDecoration(
            color: AppColors.taskSurface,
            borderRadius: BorderRadius.circular(24.r),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '請問下列何者為公共危險罪之定義？',
                style: TextStyle(
                  fontSize: 17.sp,
                  fontWeight: FontWeight.w400,
                  color: const Color(0xFF1F1B2D),
                ),
              ),
              SizedBox(height: _itemGap.h),
              ...List.generate(
                quizOptions.length,
                (index) => Padding(
                  padding: EdgeInsets.only(
                    bottom: index == quizOptions.length - 1 ? 0 : _itemGap.h,
                  ),
                  child: _QuizOptionTile(
                    option: quizOptions[index],
                    isSelected: selectedQuizIndex == index,
                    showQuizResult: showQuizResult,
                    onTap: () => onSelect(index),
                  ),
                ),
              ),
              SizedBox(height: _itemGap.h),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: selectedQuizIndex == null ? null : onSubmit,
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: EdgeInsets.symmetric(vertical: 14.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16.r),
                    ),
                  ),
                  child: Text(
                    showQuizResult ? '重新檢視答案' : '查看解析',
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
              ),
              if (showQuizResult) ...[
                SizedBox(height: _itemGap.h),
                Text(
                  '解析：刑法上的公共危險罪，重點在於危及「不特定或多數人」的公共安全，例如放火、決水、汽車酒駕肇事等。',
                  style: TextStyle(
                    fontSize: 14.sp,
                    height: 1.55,
                    fontWeight: FontWeight.w400,
                    color: const Color(0xFF271F38),
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _QuizOptionTile extends StatelessWidget {
  const _QuizOptionTile({
    required this.option,
    required this.isSelected,
    required this.showQuizResult,
    required this.onTap,
  });

  final HomeQuizOption option;
  final bool isSelected;
  final bool showQuizResult;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    Color backgroundColor = Colors.white;
    if (showQuizResult && option.isCorrect) {
      backgroundColor = AppColors.success;
    } else if (showQuizResult && isSelected && !option.isCorrect) {
      backgroundColor = AppColors.danger;
    }

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18.r),
      child: Ink(
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(18.r),
          border: Border.all(
            color: isSelected ? AppColors.primary : Colors.transparent,
          ),
        ),
        child: Text(
          option.title,
          style: TextStyle(
            fontSize: 13.sp,
            height: 1.35,
            fontWeight: FontWeight.w400,
            color: AppColors.textPrimary,
          ),
        ),
      ),
    );
  }
}
