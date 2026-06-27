import 'dart:ui';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// 台灣繁體中文教學註解：
/// 本元件庫定義了 140 項設計中所有與「Liquid Glass (流體玻璃)」相關的 UI 基礎。
/// 全面採用 BackdropFilter 實現高斯模糊，並透過自定義 Paint/Decoration
/// 模擬 Apple 精緻的超橢圓邊角（Squircle）與邊緣眩光折射。

/// 1. Liquid Glass 基礎磨砂卡片
class LiquidGlassCard extends StatelessWidget {
  final Widget child;
  final double blur;
  final double opacity;
  final double radius;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final Color? glassColor;
  final List<BoxShadow>? customShadows;
  final Border? customBorder;

  const LiquidGlassCard({
    super.key,
    required this.child,
    this.blur = 15.0,
    this.opacity = 0.1,
    this.radius = 16.0,
    this.padding,
    this.margin,
    this.glassColor,
    this.customShadows,
    this.customBorder,
  });

  @override
  Widget build(BuildContext context) {
    final themeColor = glassColor ?? (Theme.of(context).brightness == Brightness.dark
        ? const Color(0xFF1E222B)
        : const Color(0xFFFFFFFF));

    return Container(
      margin: margin,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(radius.r),
        boxShadow: customShadows ?? [
          BoxShadow(
            color: Colors.black.withValues(alpha: Theme.of(context).brightness == Brightness.dark ? 0.15 : 0.03),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
          BoxShadow(
            color: themeColor.withValues(alpha: 0.02),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(radius.r),
        clipBehavior: Clip.antiAliasWithSaveLayer,
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
          child: Container(
            padding: padding ?? EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              color: themeColor.withValues(alpha: opacity),
              borderRadius: BorderRadius.circular(radius.r),
              border: customBorder ?? Border.all(
                color: themeColor.withValues(alpha: Theme.of(context).brightness == Brightness.dark ? 0.12 : 0.40),
                width: 0.5.w,
              ),
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}

/// 2. Liquid Glass 觸覺回彈按鈕
class LiquidGlassButton extends StatefulWidget {
  final Widget child;
  final VoidCallback onTap;
  final double blur;
  final double opacity;
  final double radius;
  final EdgeInsetsGeometry? padding;
  final Color? buttonColor;
  final bool enableHaptic;

  const LiquidGlassButton({
    super.key,
    required this.child,
    required this.onTap,
    this.blur = 15.0,
    this.opacity = 0.15,
    this.radius = 12.0,
    this.padding,
    this.buttonColor,
    this.enableHaptic = true,
  });

  @override
  State<LiquidGlassButton> createState() => _LiquidGlassButtonState();
}

class _LiquidGlassButtonState extends State<LiquidGlassButton> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.96).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    _controller.forward();
    if (widget.enableHaptic) {
      HapticFeedback.selectionClick();
    }
  }

  void _handleTapUp(TapUpDetails details) {
    _controller.reverse();
  }

  void _handleTapCancel() {
    _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _handleTapDown,
      onTapUp: _handleTapUp,
      onTapCancel: _handleTapCancel,
      onTap: () {
        if (widget.enableHaptic) {
          HapticFeedback.lightImpact();
        }
        widget.onTap();
      },
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: LiquidGlassCard(
          blur: widget.blur,
          opacity: widget.opacity,
          radius: widget.radius,
          padding: widget.padding ?? EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
          glassColor: widget.buttonColor,
          child: widget.child,
        ),
      ),
    );
  }
}

/// 3. Liquid Glass 發光微開關
class LiquidGlassSwitch extends StatelessWidget {
  final bool value;
  final ValueChanged<bool> onChanged;
  final Color? activeColor;

  const LiquidGlassSwitch({
    super.key,
    required this.value,
    required this.onChanged,
    this.activeColor,
  });

  @override
  Widget build(BuildContext context) {
    final active = activeColor ?? const Color(0xFF1B5E4F);

    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        onChanged(!value);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        width: 48.w,
        height: 26.h,
        padding: EdgeInsets.symmetric(horizontal: 2.w),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(13.r),
          color: value ? active.withValues(alpha: 0.25) : Colors.black.withValues(alpha: 0.05),
          border: Border.all(
            color: value ? active.withValues(alpha: 0.4) : Colors.black.withValues(alpha: 0.1),
            width: 0.8,
          ),
        ),
        child: Align(
          alignment: value ? Alignment.centerRight : Alignment.centerLeft,
          child: LiquidGlassCard(
            blur: 5,
            opacity: 0.95,
            radius: 11,
            padding: EdgeInsets.zero,
            glassColor: value ? active : Colors.white,
            customShadows: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.15),
                blurRadius: 3,
                offset: const Offset(0, 1.5),
              )
            ],
            child: SizedBox(
              width: 20.w,
              height: 20.h,
            ),
          ),
        ),
      ),
    );
  }
}

/// 4. Liquid Glass 骨架載入動畫
class LiquidGlassShimmer extends StatefulWidget {
  final double width;
  final double height;
  final double radius;

  const LiquidGlassShimmer({
    super.key,
    required this.width,
    required this.height,
    this.radius = 12.0,
  });

  @override
  State<LiquidGlassShimmer> createState() => _LiquidGlassShimmerState();
}

class _LiquidGlassShimmerState extends State<LiquidGlassShimmer> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();
    _animation = Tween<double>(begin: -1.0, end: 2.0).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(widget.radius.r),
            border: Border.all(color: Colors.white.withValues(alpha: 0.15), width: 0.5.w),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(widget.radius.r),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.white.withValues(alpha: 0.03),
                      Colors.white.withValues(alpha: 0.15),
                      Colors.white.withValues(alpha: 0.03),
                    ],
                    stops: const [0.0, 0.5, 1.0],
                    begin: Alignment(_animation.value - 1.0, -0.3),
                    end: Alignment(_animation.value, 0.3),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

/// 5. Liquid Glass 漂浮動態彩色流體背景（創造景深折射）
class LiquidGlassBackground extends StatefulWidget {
  final Widget? child;

  const LiquidGlassBackground({super.key, this.child});

  @override
  State<LiquidGlassBackground> createState() => _LiquidGlassBackgroundState();
}

class _LiquidGlassBackgroundState extends State<LiquidGlassBackground> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final progress = _controller.value;
        final screenWidth = MediaQuery.of(context).size.width;
        final screenHeight = MediaQuery.of(context).size.height;

        // 利用三角函數計算平滑的漂浮曲線，保證沒有跳躍且連續
        final sinT = sin(progress * 2 * pi);
        final cosT = cos(progress * 2 * pi);

        final orb1X = screenWidth * 0.15 + (screenWidth * 0.08 * sinT);
        final orb1Y = screenHeight * 0.25 + (screenHeight * 0.05 * cosT);

        final orb2X = screenWidth * 0.80 - (screenWidth * 0.06 * cosT);
        final orb2Y = screenHeight * 0.70 + (screenHeight * 0.08 * sinT);

        final orb3X = screenWidth * 0.45 + (screenWidth * 0.05 * cos(progress * 4 * pi));
        final orb3Y = screenHeight * 0.50 - (screenHeight * 0.07 * sin(progress * 4 * pi));

        return Stack(
          children: [
            // 流體球背景 1
            Positioned(
              left: orb1X - 140.w,
              top: orb1Y - 140.w,
              child: Container(
                width: 280.w,
                height: 280.w,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      const Color(0xFFC8E6C9).withValues(alpha: 0.35),
                      const Color(0xFFC8E6C9).withValues(alpha: 0.0),
                    ],
                  ),
                ),
              ),
            ),
            // 流體球背景 2
            Positioned(
              left: orb2X - 160.w,
              top: orb2Y - 160.w,
              child: Container(
                width: 320.w,
                height: 320.w,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      const Color(0xFFFFCCBC).withValues(alpha: 0.30),
                      const Color(0xFFFFCCBC).withValues(alpha: 0.0),
                    ],
                  ),
                ),
              ),
            ),
            // 流體球背景 3
            Positioned(
              left: orb3X - 120.w,
              top: orb3Y - 120.w,
              child: Container(
                width: 240.w,
                height: 240.w,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      const Color(0xFFFFF9C4).withValues(alpha: 0.30),
                      const Color(0xFFFFF9C4).withValues(alpha: 0.0),
                    ],
                  ),
                ),
              ),
            ),
            // 前景元件
            if (widget.child != null) widget.child!,
          ],
        );
      },
    );
  }
}
