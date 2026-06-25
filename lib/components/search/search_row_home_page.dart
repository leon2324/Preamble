import 'dart:ui' show lerpDouble;

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lawapp/theme/adaptive_layout.dart';

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
    this.onSubmitted,
    this.onSearchTap,
  });

  final TextEditingController controller;
  final double collapseProgress;
  final String hintText;
  final bool showNotificationCapsule;
  final bool hasShadow;
  final Color surfaceColor;
  final ValueChanged<String>? onSubmitted;
  final VoidCallback? onSearchTap;

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
    final buttonHeight = 47.h + textBuffer;
    final effectiveCollapseProgress =
        _isSearchFocused ? 1.0 : widget.collapseProgress;
    final currentShadow = widget.hasShadow
        ? _searchShadow(widget.collapseProgress)
        : <BoxShadow>[];
    // 一旦輸入框取得焦點，就直接視為完全展開，避免使用者打字時
    // 搜尋列還被 scroll 位置影響而晃動。
    // 台灣繁體中文教學註解：
    // Release 版先只保留可實際送出的文字搜尋；等額外輸入能力完成真機驗證後，
    // 再把左右側 icon 以同一個參數開回來。
    final searchLeftMargin =
        lerpDouble(10.w, 0, effectiveCollapseProgress) ?? 0;

    return Padding(
      padding: EdgeInsets.fromLTRB(10.w, 10.h, 10.w, 8.h),
      child: Row(
        children: [
          Expanded(
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 140),
              curve: Curves.easeOut,
              margin: EdgeInsets.symmetric(horizontal: searchLeftMargin),
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
                  textInputAction: TextInputAction.search,
                  onSubmitted: (value) {
                    // 台灣繁體中文教學註解：
                    // 共用搜尋列只負責收集與送出文字，實際要導去哪個搜尋流程
                    // 交給外層頁面決定，避免首頁、全站搜尋頁各自寫一套 TextField。
                    widget.onSubmitted?.call(value.trim());
                    FocusScope.of(context).unfocus();
                  },
                  onTapOutside: (__) => FocusScope.of(context).unfocus(),
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
                    suffixIcon: IconButton(
                      onPressed: () {
                        widget.onSearchTap?.call();
                        FocusScope.of(context).unfocus();
                      },
                      tooltip: '送出搜尋',
                      icon: Icon(
                        Icons.search,
                        size: 28.sp,
                        color: Colors.grey[600],
                      ),
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
        ],
      ),
    );
  }
}
