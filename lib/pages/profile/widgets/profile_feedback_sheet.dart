import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:preamble/app/app_state.dart';
import 'package:preamble/theme/app_colors.dart';

/// 反饋/問題回報 Bottom Sheet。
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surfaceColor = isDark ? const Color(0xFF171C22) : Colors.white;
    final borderSide =
        BorderSide(color: isDark ? const Color(0xFF2B3441) : AppColors.border);

    return Container(
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
      ),
      padding: EdgeInsets.fromLTRB(
          20.w, 12.h, 20.w, MediaQuery.viewInsetsOf(context).bottom + 24.h),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 頂部拖曳指示條 (Drag handle)
          Align(
            alignment: Alignment.center,
            child: Container(
              width: 40.w,
              height: 4.h,
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF2B3441) : AppColors.border,
                borderRadius: BorderRadius.circular(2.r),
              ),
            ),
          ),
          SizedBox(height: 16.h),
          Text(
            '問題回報與意見反饋',
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w900,
              color: isDark ? const Color(0xFFF2F4F7) : AppColors.textPrimary,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 20.h),

          // 反饋類型選擇按鈕組 (Category Selector)
          Text('反饋類型',
              style: TextStyle(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.bold,
                  color: isDark
                      ? const Color(0xFFA3ABB6)
                      : AppColors.textSecondary)),
          SizedBox(height: 6.h),
          Row(
            children: ['功能建議', '內容錯誤', '程式錯誤', '其他'].map((cat) {
              final isSelected = _category == cat;
              return Expanded(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 2.w),
                  child: InkWell(
                    onTap: () => setState(() => _category = cat),
                    borderRadius: BorderRadius.circular(8.r),
                    child: Container(
                      padding: EdgeInsets.symmetric(vertical: 8.h),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.primary
                            : (isDark
                                ? const Color(0xFF0F1216)
                                : const Color(0xFFFAF7F2)),
                        borderRadius: BorderRadius.circular(8.r),
                        border: Border.all(
                          color: isSelected
                              ? AppColors.primary
                              : (isDark
                                  ? const Color(0xFF2B3441)
                                  : AppColors.border),
                        ),
                      ),
                      child: Text(
                        cat,
                        style: TextStyle(
                          fontSize: 11.5.sp,
                          fontWeight:
                              isSelected ? FontWeight.bold : FontWeight.normal,
                          color: isSelected
                              ? Colors.white
                              : (isDark
                                  ? const Color(0xFFF2F4F7)
                                  : AppColors.textPrimary),
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          SizedBox(height: 16.h),

          // 聯絡信箱輸入欄位 (Email Field)
          Text('您的聯絡信箱 (選填)',
              style: TextStyle(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.bold,
                  color: isDark
                      ? const Color(0xFFA3ABB6)
                      : AppColors.textSecondary)),
          SizedBox(height: 6.h),
          TextField(
            controller: _emailController,
            decoration: InputDecoration(
              hintText: '請輸入信箱以利回覆',
              contentPadding:
                  EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
              filled: true,
              fillColor:
                  isDark ? const Color(0xFF0F1216) : const Color(0xFFFAF7F2),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.r),
                borderSide: borderSide,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.r),
                borderSide: BorderSide(color: AppColors.accent, width: 1.5),
              ),
            ),
            style: TextStyle(
                fontSize: 13.5.sp,
                color:
                    isDark ? const Color(0xFFF2F4F7) : AppColors.textPrimary),
          ),
          SizedBox(height: 16.h),

          // 反饋內容描述輸入欄位 (Content Field)
          Text('描述與建議',
              style: TextStyle(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.bold,
                  color: isDark
                      ? const Color(0xFFA3ABB6)
                      : AppColors.textSecondary)),
          SizedBox(height: 6.h),
          TextField(
            controller: _feedbackController,
            maxLines: 4,
            decoration: InputDecoration(
              hintText: '請詳細描述您遇到的問題或給予的指教...',
              contentPadding: EdgeInsets.all(14.w),
              filled: true,
              fillColor:
                  isDark ? const Color(0xFF0F1216) : const Color(0xFFFAF7F2),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.r),
                borderSide: borderSide,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.r),
                borderSide: BorderSide(color: AppColors.accent, width: 1.5),
              ),
            ),
            style: TextStyle(
                fontSize: 13.5.sp,
                color:
                    isDark ? const Color(0xFFF2F4F7) : AppColors.textPrimary),
          ),
          SizedBox(height: 20.h),

          // 底部操作按鈕（取消與提交） (Actions)
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: _isSending ? null : () => Navigator.pop(context),
                  style: OutlinedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 12.h),
                    side: borderSide,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14.r)),
                  ),
                  child: Text('取消',
                      style: TextStyle(
                          fontSize: 14.sp,
                          color: isDark
                              ? const Color(0xFFA3ABB6)
                              : AppColors.textSecondary)),
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: FilledButton(
                  onPressed: _isSending ? null : _submitFeedback,
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: EdgeInsets.symmetric(vertical: 12.h),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14.r)),
                  ),
                  child: _isSending
                      ? SizedBox(
                          width: 18.w,
                          height: 18.w,
                          child: const CircularProgressIndicator(
                              strokeWidth: 2.5, color: Colors.white),
                        )
                      : Text('提交',
                          style: TextStyle(
                              fontSize: 14.sp,
                              color: Colors.white,
                              fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _submitFeedback() async {
    final content = _feedbackController.text.trim();
    if (content.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('請填寫回饋內容！'), backgroundColor: Colors.redAccent),
      );
      return;
    }

    setState(() => _isSending = true);

    // 模擬網路傳輸延遲約 1 秒，提供真實載入感 (模擬網路延遲 1 秒)
    await Future<void>.delayed(const Duration(milliseconds: 900));

    if (mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('感謝回報！我們會盡快處理「$_category」問題。'),
          backgroundColor: const Color(0xFF2E7D32),
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }
}
