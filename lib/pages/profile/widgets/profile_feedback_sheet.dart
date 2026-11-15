import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:preamble/app/app_state.dart';
import 'package:preamble/components/shared/custom_toast.dart';
import 'package:preamble/theme/preamble_tokens.dart';

class FeedbackSheet extends StatefulWidget {
  const FeedbackSheet({super.key, required this.appState});

  final PreambleState appState;

  @override
  State<FeedbackSheet> createState() => _FeedbackSheetState();
}

class _FeedbackSheetState extends State<FeedbackSheet> {
  final _feedbackController = TextEditingController();
  final _emailController = TextEditingController();
  String _category = '功能建議';
  bool _isSending = false;

  @override
  void initState() {
    super.initState();
    _emailController.text = widget.appState.currentUser.email;
  }

  @override
  void dispose() {
    _feedbackController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;

    return Container(
      decoration: BoxDecoration(
        color: t.surfaceElevated,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
        border: Border.all(color: t.border),
      ),
      padding: EdgeInsets.fromLTRB(
        20.w,
        12.h,
        20.w,
        MediaQuery.viewInsetsOf(context).bottom + 24.h,
      ),
      child: SafeArea(
        top: false,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 38.w,
                  height: 4.h,
                  decoration: BoxDecoration(
                    color: t.borderStrong,
                    borderRadius: BorderRadius.circular(99.r),
                  ),
                ),
              ),
              SizedBox(height: 16.h),
              Text(
                '問題回報與意見反饋',
                style: t.serifTitle(size: 17.sp),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 18.h),

              Text(
                '反饋類別',
                style: t.sansBody(
                  size: 12.sp,
                  weight: FontWeight.w700,
                  color: t.textSecondary,
                ),
              ),
              SizedBox(height: 8.h),
              Wrap(
                spacing: 8.w,
                runSpacing: 8.h,
                children: ['功能建議', '內容勘誤', '程式異常', '其他'].map((cat) {
                  final isSelected = _category == cat;
                  return ChoiceChip(
                    label: Text(cat),
                    selected: isSelected,
                    onSelected: (_) => setState(() => _category = cat),
                    selectedColor: t.brandPrimaryStrong,
                    backgroundColor: t.surfaceSubtle,
                    showCheckmark: false,
                    side: BorderSide(
                      color: isSelected ? t.brandPrimaryStrong : t.border,
                    ),
                    labelStyle: t.sansBody(
                      size: 12.sp,
                      weight: isSelected ? FontWeight.w700 : FontWeight.w500,
                      color: isSelected
                          ? const Color(0xFFFAF8F4)
                          : t.textPrimary,
                    ),
                  );
                }).toList(),
              ),
              SizedBox(height: 16.h),

              Text(
                '聯絡信箱（選填）',
                style: t.sansBody(
                  size: 12.sp,
                  weight: FontWeight.w700,
                  color: t.textSecondary,
                ),
              ),
              SizedBox(height: 6.h),
              TextField(
                controller: _emailController,
                style: t.sansBody(size: 13.5.sp, color: t.textPrimary),
                decoration: InputDecoration(
                  hintText: '填寫信箱以便團隊回覆處理進度',
                  hintStyle: t.sansBody(size: 13.sp, color: t.textMuted),
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 14.w, vertical: 11.h),
                  filled: true,
                  fillColor: t.surfaceSubtle,
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.r),
                    borderSide: BorderSide(color: t.border),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.r),
                    borderSide: BorderSide(color: t.brandPrimary, width: 1.5),
                  ),
                ),
              ),
              SizedBox(height: 16.h),

              Text(
                '詳細說明與建議',
                style: t.sansBody(
                  size: 12.sp,
                  weight: FontWeight.w700,
                  color: t.textSecondary,
                ),
              ),
              SizedBox(height: 6.h),
              TextField(
                controller: _feedbackController,
                maxLines: 4,
                style: t.sansBody(size: 13.5.sp, color: t.textPrimary),
                decoration: InputDecoration(
                  hintText: '請描述您遇到的情境或法規內容建議...',
                  hintStyle: t.sansBody(size: 13.sp, color: t.textMuted),
                  contentPadding: EdgeInsets.all(14.w),
                  filled: true,
                  fillColor: t.surfaceSubtle,
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.r),
                    borderSide: BorderSide(color: t.border),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.r),
                    borderSide: BorderSide(color: t.brandPrimary, width: 1.5),
                  ),
                ),
              ),
              SizedBox(height: 22.h),

              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed:
                          _isSending ? null : () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 12.h),
                        side: BorderSide(color: t.borderStrong),
                        foregroundColor: t.textSecondary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14.r),
                        ),
                      ),
                      child: const Text('取消'),
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: FilledButton(
                      onPressed: _isSending ? null : _submitFeedback,
                      style: FilledButton.styleFrom(
                        backgroundColor: t.brandPrimaryStrong,
                        foregroundColor: const Color(0xFFFAF8F4),
                        padding: EdgeInsets.symmetric(vertical: 12.h),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14.r),
                        ),
                      ),
                      child: _isSending
                          ? SizedBox(
                              width: 18.w,
                              height: 18.w,
                              child: const CircularProgressIndicator(
                                strokeWidth: 2.2,
                                color: Color(0xFFFAF8F4),
                              ),
                            )
                          : const Text('送出回饋'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _submitFeedback() async {
    final content = _feedbackController.text.trim();
    if (content.isEmpty) {
      CustomToast.show(
        context,
        '請填寫回饋內容後再送出',
        icon: PhosphorIconsRegular.warningCircle,
      );
      return;
    }

    setState(() => _isSending = true);
    await Future<void>.delayed(const Duration(milliseconds: 700));

    if (mounted) {
      Navigator.pop(context);
      CustomToast.show(
        context,
        '感謝您的「$_category」回饋，編輯團隊已收悉。',
        icon: PhosphorIconsFill.checkCircle,
      );
    }
  }
}
