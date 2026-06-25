import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// 台灣繁體中文教學註解：
/// 高質感自訂 Toast 提示。
/// 使用 OverlayEntry 在螢幕正中央呈現 4:5 直式提示卡，避免傳統 Snackbar 貼底遮住底欄。
/// 支援微縮放進場動畫，顯示 1.5 秒後自動移除，用以替代短訊息型 Snackbar。
class CustomToast {
  static void show(
    BuildContext context,
    String message, {
    IconData icon = Icons.check_circle_outline_rounded,
  }) {
    final overlayState = Overlay.of(context);
    late OverlayEntry overlayEntry;

    overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        top: 0,
        bottom: 0,
        left: 0,
        right: 0,
        child: Material(
          color: Colors.transparent,
          child: Center(
            child: TweenAnimationBuilder<double>(
              tween: Tween<double>(begin: 0.85, end: 1.0),
              duration: const Duration(milliseconds: 180),
              curve: Curves.easeOutBack,
              builder: (context, scale, child) {
                return Transform.scale(
                  scale: scale,
                  child: Container(
                    width: 128.w,
                    height: 160.w,
                    padding:
                        EdgeInsets.symmetric(horizontal: 14.w, vertical: 16.h),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.82),
                      borderRadius: BorderRadius.circular(16.r),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.24),
                          blurRadius: 16,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          icon,
                          color: Colors.white,
                          size: 32.sp,
                        ),
                        SizedBox(height: 10.h),
                        Text(
                          message,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12.sp,
                            fontWeight: FontWeight.bold,
                            height: 1.35,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );

    overlayState.insert(overlayEntry);

    // 台灣繁體中文教學註解：Toast 保持 1.5 秒，讓使用者能讀完短句，但不打斷操作節奏。
    Timer(const Duration(milliseconds: 1500), () {
      overlayEntry.remove();
    });
  }
}
