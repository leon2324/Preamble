import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lawapp/components/home/v2/home_v2_palette.dart';
import 'package:lawapp/features/case_time_machine/widgets/case_time_machine_svg_icon.dart';
import 'package:lawapp/theme/app_colors.dart';

/// 訂製專屬法學課堂 Dialog。
///
/// 台灣繁體中文教學註解：
/// 此 Widget 從 know_law_page.dart 拆出（Step 4D），完全自包含，
/// 內部自行管理輸入文字、載入動畫與 Timer，只透過 [onGenerate] 回呼
/// 將使用者輸入的糾紛情境字串傳回給呼叫方。
class CustomClassroomDialog extends StatefulWidget {
  const CustomClassroomDialog({
    super.key,
    required this.isDark,
    required this.onGenerate,
  });

  final bool isDark;
  final Function(String) onGenerate;

  @override
  State<CustomClassroomDialog> createState() => _CustomClassroomDialogState();
}

class _CustomClassroomDialogState extends State<CustomClassroomDialog> {
  final TextEditingController _controller = TextEditingController();
  bool _isGenerating = false;
  int _loadingStep = 0;
  Timer? _timer;

  final List<String> _quickTags = [
    '租屋修繕責任',
    '車禍折舊與工資',
    '網路購物退貨',
    '加班費與離職預告',
  ];

  final List<String> _loadingMessages = [
    '📝 正在為您起草專屬案例關係人與糾紛情境...',
    '⚖️ 正在檢索中華民國相關法律之請求權基礎...',
    '📚 正在編排專屬 STEP 1 至 STEP 5 單元課程...',
    '🎯 正在產生各關卡之法律小測驗與解析...',
  ];

  @override
  void dispose() {
    _controller.dispose();
    _timer?.cancel();
    super.dispose();
  }

  void _startGeneration() {
    final text = _controller.text.trim();
    if (text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('請輸入您的生活糾紛情境或選擇快速標籤！'),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    setState(() {
      _isGenerating = true;
      _loadingStep = 0;
    });

    _timer = Timer.periodic(const Duration(milliseconds: 800), (timer) {
      if (_loadingStep < _loadingMessages.length - 1) {
        setState(() {
          _loadingStep++;
        });
      } else {
        _timer?.cancel();
        widget.onGenerate(text);
      }
    });
  }

  Widget _buildLoadingView() {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 24.h),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 70.w,
                height: 70.w,
                child: const CircularProgressIndicator(
                  strokeWidth: 3.5,
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFF57F17)),
                  backgroundColor: Color(0xFFFAF6EE),
                ),
              ),
              CtmSvgIcon(
                CtmSvgIcons.idea,
                size: 30.sp,
                color: const Color(0xFFF57F17),
              ),
            ],
          ),
          SizedBox(height: 24.h),
          Text(
            '法律 AI 起草中',
            style: TextStyle(
              fontSize: 15.sp,
              fontWeight: FontWeight.w900,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: 12.h),
          Container(
            height: 48.h,
            alignment: Alignment.center,
            padding: EdgeInsets.symmetric(horizontal: 12.w),
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              transitionBuilder: (Widget child, Animation<double> animation) {
                return FadeTransition(
                  opacity: animation,
                  child: SlideTransition(
                    position: Tween<Offset>(
                      begin: const Offset(0.0, 0.2),
                      end: Offset.zero,
                    ).animate(animation),
                    child: child,
                  ),
                );
              },
              child: Text(
                _loadingMessages[_loadingStep],
                key: ValueKey<int>(_loadingStep),
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12.5.sp,
                  color: AppColors.textSecondary,
                  height: 1.4,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputView() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: EdgeInsets.all(6.w),
              decoration: const BoxDecoration(
                color: Color(0xFFFFF176),
                shape: BoxShape.circle,
              ),
              child: CtmSvgIcon(
                CtmSvgIcons.idea,
                size: 20.sp,
                color: const Color(0xFFF57F17),
              ),
            ),
            SizedBox(width: 10.w),
            Expanded(
              child: Text(
                '訂製專屬法學課堂',
                style: TextStyle(
                  fontSize: 16.5.sp,
                  fontWeight: FontWeight.w900,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
            IconButton(
              icon: Icon(Icons.close, size: 20.sp),
              onPressed: () => Navigator.pop(context),
            ),
          ],
        ),
        SizedBox(height: 12.h),
        Text(
          '請描述您面臨的生活法學困境或糾紛：',
          style: TextStyle(
            fontSize: 12.5.sp,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        SizedBox(height: 8.h),
        TextField(
          controller: _controller,
          onTapOutside: (event) {
            FocusManager.instance.primaryFocus?.unfocus();
          },
          maxLines: 4,
          style: TextStyle(fontSize: 13.sp, color: AppColors.textPrimary),
          decoration: InputDecoration(
            hintText: '例如：鄰居把私人物品與垃圾堆在樓梯公用走道上，勸導多次也不肯清理...',
            hintStyle: TextStyle(
              fontSize: 12.sp,
              color: AppColors.textSecondary.withValues(alpha: 0.7),
            ),
            filled: true,
            fillColor: widget.isDark
                ? const Color(0xFF1E252D)
                : const Color(0xFFFAF6EE),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: BorderSide(
                color: widget.isDark
                    ? const Color(0xFF354454)
                    : const Color(0xFFD8D0C2),
                width: 1.w,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: BorderSide(
                color: HomeV2Palette.trustGreen,
                width: 1.5.w,
              ),
            ),
            contentPadding: EdgeInsets.all(12.w),
          ),
        ),
        SizedBox(height: 16.h),
        Text(
          '快速點選常見主題標籤：',
          style: TextStyle(
            fontSize: 12.5.sp,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        SizedBox(height: 8.h),
        Wrap(
          spacing: 8.w,
          runSpacing: 8.h,
          children: _quickTags.map((tag) {
            return GestureDetector(
              onTap: () {
                setState(() {
                  _controller.text = tag;
                });
              },
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
                decoration: BoxDecoration(
                  color: widget.isDark
                      ? const Color(0xFF1E252D)
                      : const Color(0xFFF9F7F0),
                  borderRadius: BorderRadius.circular(20.r),
                  border: Border.all(
                    color: _controller.text == tag
                        ? HomeV2Palette.trustGreen
                        : (widget.isDark
                            ? const Color(0xFF354454)
                            : const Color(0xFFD8D0C2)),
                    width: _controller.text == tag ? 1.5.w : 1.w,
                  ),
                ),
                child: Text(
                  '#$tag',
                  style: TextStyle(
                    fontSize: 11.sp,
                    fontWeight: _controller.text == tag
                        ? FontWeight.bold
                        : FontWeight.normal,
                    color: _controller.text == tag
                        ? HomeV2Palette.trustGreen
                        : AppColors.textSecondary,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
        SizedBox(height: 24.h),
        SizedBox(
          width: double.infinity,
          height: 44.h,
          child: ElevatedButton(
            onPressed: _startGeneration,
            style: ElevatedButton.styleFrom(
              backgroundColor: HomeV2Palette.trustGreen,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.r),
              ),
              elevation: 0,
            ),
            child: Text(
              '開始訂製專屬課堂',
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 24.h),
      child: Container(
        constraints: BoxConstraints(maxWidth: 450.w),
        decoration: BoxDecoration(
          color:
              widget.isDark ? const Color(0xFF161C23) : const Color(0xFFFFFCF4),
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(
            color: widget.isDark
                ? const Color(0xFF26323E)
                : const Color(0xFFECE6DB),
            width: 1.5.w,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.3),
              blurRadius: 16,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: SingleChildScrollView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          child: Padding(
            padding: EdgeInsets.all(20.w),
            child: _isGenerating ? _buildLoadingView() : _buildInputView(),
          ),
        ),
      ),
    );
  }
}
