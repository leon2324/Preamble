import 'dart:ui' show lerpDouble;

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lawapp/components/search/search_row_round_icon.dart';
import 'package:lawapp/theme/adaptive_layout.dart';
import 'package:lawapp/theme/app_colors.dart';

/// 首頁專用搜尋列。
///
/// 跟一般搜尋頁不同，這裡會依照 scroll 進度收合左側通知按鈕。
class SearchRowHomePage extends StatefulWidget {
  const SearchRowHomePage({
    super.key,
    required this.controller,
    required this.collapseProgress,
    this.hintText = '快速搜尋',
    this.showNotificationCapsule = true,
    this.hasShadow = true,
    this.surfaceColor = const Color.fromARGB(255, 224, 224, 224),
  });

  final TextEditingController controller;
  final double collapseProgress;
  final String hintText;
  final bool showNotificationCapsule;
  final bool hasShadow;
  final Color surfaceColor;

  @override
  State<SearchRowHomePage> createState() => _SearchRowHomePageState();
}

class _SearchRowHomePageState extends State<SearchRowHomePage> {
  late final FocusNode _focusNode;
  bool _isSearchFocused = false;

  List<BoxShadow> _searchShadow(double progress) {
    // 收合前後的陰影稍微不同，視覺上才不會像兩個完全分離的元件。
    final color = Color.lerp(
      const Color(0x6C5C5C5C),
      const Color.fromARGB(255, 92, 92, 92),
      progress,
    )!;
    final blurRadius = lerpDouble(23, 24, progress) ?? 24;
    final offsetY = lerpDouble(12.5, 14, progress) ?? 14;

    return [
      BoxShadow(
        color: color,
        spreadRadius: -4,
        blurRadius: blurRadius,
        offset: Offset(0, offsetY),
      ),
    ];
  }

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
    _focusNode.addListener(_handleFocusChange);
  }

  void _handleFocusChange() {
    if (_isSearchFocused == _focusNode.hasFocus) return;
    setState(() {
      _isSearchFocused = _focusNode.hasFocus;
    });
  }

  @override
  void dispose() {
    _focusNode.removeListener(_handleFocusChange);
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textBuffer = context.adaptiveBuffer(8);
    final buttonWidth = 59.w;
    final buttonHeight = 47.h + textBuffer;
    final effectiveCollapseProgress =
        _isSearchFocused ? 1.0 : widget.collapseProgress;
    final currentShadow = widget.hasShadow
        ? _searchShadow(widget.collapseProgress)
        : <BoxShadow>[];
    // 一旦輸入框取得焦點，就直接視為完全展開，避免使用者打字時
    // 搜尋列還被 scroll 位置影響而晃動。
    final leftIconWidth = widget.showNotificationCapsule
        ? lerpDouble(buttonWidth, 0, effectiveCollapseProgress) ?? 0
        : 0.0;
    final searchLeftMargin = widget.showNotificationCapsule
        ? lerpDouble(10.w, 0, effectiveCollapseProgress) ?? 0
        : 0.0;

    return Padding(
      padding: EdgeInsets.fromLTRB(10.w, 10.h, 10.w, 8.h),
      child: Row(
        children: [
          if (widget.showNotificationCapsule)
            AnimatedContainer(
              duration: const Duration(milliseconds: 140),
              curve: Curves.easeOut,
              width: leftIconWidth,
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 120),
                opacity: effectiveCollapseProgress < 0.92 ? 1 : 0,
                child: IgnorePointer(
                  ignoring: effectiveCollapseProgress >= 0.92,
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      RoundIconButton(
                        icon: Icons.notifications_none,
                        onPressed: () {},
                        width: buttonWidth,
                        height: buttonHeight,
                        boxShadow: currentShadow,
                        backgroundColor: widget.surfaceColor,
                      ),
                      Positioned(
                        top: 6.h,
                        right: 6.w,
                        child: Container(
                          width: 8.w,
                          height: 8.w,
                          decoration: const BoxDecoration(
                            color: AppColors.info,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          Expanded(
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 140),
              curve: Curves.easeOut,
              margin: EdgeInsets.only(left: searchLeftMargin, right: 10.w),
              child: Container(
                height: buttonHeight,
                decoration: BoxDecoration(
                  color: widget.surfaceColor,
                  borderRadius: BorderRadius.circular(buttonHeight / 2),
                  boxShadow: currentShadow,
                ),
                child: TextField(
                  controller: widget.controller,
                  focusNode: _focusNode,
                  onSubmitted: (_) => FocusScope.of(context).unfocus(),
                  onTapOutside: (_) => FocusScope.of(context).unfocus(),
                  textAlignVertical: TextAlignVertical.center,
                  decoration: InputDecoration(
                    hintText: widget.hintText,
                    hintStyle: TextStyle(
                      fontSize: 17.sp,
                      fontWeight: FontWeight.w400,
                      color: Colors.grey[600],
                    ),
                    border: InputBorder.none,
                    isCollapsed: true,
                    contentPadding: EdgeInsets.only(
                      left: 20.w,
                      right: 12.w,
                    ),
                    suffixIcon: Icon(
                      Icons.search,
                      size: 32.sp,
                      color: Colors.grey[600],
                    ),
                    suffixIconConstraints: BoxConstraints(
                      minHeight: 48.h,
                      minWidth: 50.w,
                    ),
                  ),
                ),
              ),
            ),
          ),
          RoundIconButton(
            icon: Icons.mic,
            onPressed: () {},
            width: buttonWidth,
            height: buttonHeight,
            boxShadow: currentShadow,
            backgroundColor: widget.surfaceColor,
          ),
        ],
      ),
    );
  }
}
