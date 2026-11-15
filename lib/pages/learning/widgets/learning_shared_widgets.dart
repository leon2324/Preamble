import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:preamble/pages/learning/widgets/notebook_aesthetics.dart';
import 'package:preamble/theme/preamble_tokens.dart';

/// 學習頁共用 hero 圖片。
Widget buildLearningHeroImage({
  required String? imageUrl,
  required String localAsset,
  required BoxFit fit,
}) {
  if (imageUrl != null && imageUrl.isNotEmpty) {
    return CachedNetworkImage(
      imageUrl: imageUrl,
      fit: fit,
      placeholder: (context, url) => Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(localAsset, fit: fit),
          const Center(
            child: SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white70),
              ),
            ),
          ),
        ],
      ),
      errorWidget: (context, url, error) {
        return Image.asset(localAsset, fit: fit);
      },
    );
  }
  return Image.asset(localAsset, fit: fit);
}

/// 主修課卡片上方的膠囊標籤。
Widget buildLearningCourseBadge(String label, bool isDark) {
  final tokens = isDark ? PreambleTokens.dark : PreambleTokens.light;
  return Container(
    padding: EdgeInsets.symmetric(horizontal: 9.w, vertical: 4.h),
    decoration: BoxDecoration(
      color: tokens.surface.withValues(alpha: 0.86),
      borderRadius: BorderRadius.circular(999.r),
      border: Border.all(color: tokens.borderStrong),
    ),
    child: Text(
      label,
      style: tokens.sansBody(
        size: 11.sp,
        weight: FontWeight.w700,
        color: tokens.brandPrimary,
      ),
    ),
  );
}

/// 標準語意勾選列（修正原先誤用五角星充當勾選框之問題，改用 Phosphor 方框勾選圖示）。
Widget buildLearningHanddrawnCheckbox({
  required String label,
  required bool value,
  required ValueChanged<bool?> onChanged,
  required bool isDark,
}) {
  final t = isDark ? PreambleTokens.dark : PreambleTokens.light;
  return InkWell(
    onTap: () => onChanged(!value),
    borderRadius: BorderRadius.circular(8.r),
    child: Padding(
      padding: EdgeInsets.symmetric(vertical: 6.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.only(top: 1.5.h),
            child: Icon(
              value
                  ? PhosphorIconsFill.checkSquare
                  : PhosphorIconsRegular.square,
              size: 18.sp,
              color: value ? t.brandPrimary : t.textMuted,
            ),
          ),
          SizedBox(width: 9.w),
          Expanded(
            child: Text(
              label,
              style: t.sansBody(
                size: 12.5.sp,
                weight: value ? FontWeight.w500 : FontWeight.w600,
                color: value ? t.textMuted : t.textPrimary,
              ).copyWith(
                decoration: value ? TextDecoration.lineThrough : null,
                decorationColor: t.textMuted,
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

/// 靜奢微凹文字輸入框。
Widget buildLearningPostItInput({
  required TextEditingController controller,
  required String hintText,
  required bool isDark,
  int maxLines = 1,
}) {
  final t = isDark ? PreambleTokens.dark : PreambleTokens.light;
  return Container(
    decoration: BoxDecoration(
      color: t.surfaceSubtle,
      borderRadius: BorderRadius.circular(10.r),
      border: Border.all(color: t.borderStrong),
    ),
    padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
    child: TextField(
      controller: controller,
      maxLines: maxLines,
      style: t.sansBody(
        size: 13.sp,
        weight: FontWeight.w600,
        color: t.textPrimary,
      ),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: t.sansBody(size: 12.sp, color: t.textMuted),
        border: InputBorder.none,
        isDense: true,
      ),
    ),
  );
}

/// 典藏筆記底線風輸入框。
Widget buildLearningNotebookInput({
  required TextEditingController controller,
  required String labelText,
  required String hintText,
  required bool isDark,
  TextInputType keyboardType = TextInputType.text,
}) {
  final t = isDark ? PreambleTokens.dark : PreambleTokens.light;
  return Padding(
    padding: EdgeInsets.symmetric(vertical: 6.h),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (labelText.isNotEmpty)
          Text(
            labelText,
            style: t.sansBody(
              size: 11.5.sp,
              weight: FontWeight.w700,
              color: t.textSecondary,
            ),
          ),
        Container(
          decoration: BoxDecoration(
            border: Border(bottom: BorderSide(color: t.borderStrong, width: 1)),
          ),
          padding: EdgeInsets.symmetric(vertical: 2.h),
          child: TextField(
            controller: controller,
            keyboardType: keyboardType,
            style: t.sansBody(
              size: 13.5.sp,
              weight: FontWeight.w600,
              color: t.textPrimary,
            ),
            decoration: InputDecoration(
              hintText: hintText,
              hintStyle: t.sansBody(size: 12.sp, color: t.textMuted),
              border: InputBorder.none,
              isDense: true,
              contentPadding: EdgeInsets.symmetric(vertical: 6.h),
            ),
          ),
        ),
      ],
    ),
  );
}

/// 印鑑風主要行動膠囊按鈕。
Widget buildLearningSealButton({
  required String label,
  required VoidCallback onPressed,
  required Color color,
}) {
  return InkWell(
    onTap: onPressed,
    borderRadius: BorderRadius.circular(12.r),
    child: Container(
      padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 9.h),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: color, width: 1.5),
        color: color.withValues(alpha: 0.12),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12.5.sp,
          fontWeight: FontWeight.w700,
          color: color,
          letterSpacing: 0.6,
        ),
      ),
    ),
  );
}

/// 靜奢次要標籤按鈕（取代過往歪斜紙膠帶外觀）。
Widget buildLearningWashiTapeButton({
  required String label,
  required VoidCallback onPressed,
  required Color color,
}) {
  return InkWell(
    onTap: onPressed,
    borderRadius: BorderRadius.circular(8.r),
    child: Container(
      padding: EdgeInsets.symmetric(horizontal: 13.w, vertical: 7.h),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: color.withValues(alpha: 0.36)),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11.5.sp,
          fontWeight: FontWeight.w700,
          color: color,
        ),
      ),
    ),
  );
}

/// 摘錄重點標記色彩選擇圓點。
Widget buildLearningHighlightColorDot(
  String name,
  Color color,
  String selectedName,
  VoidCallback onTap, {
  bool isNone = false,
}) {
  final isSelected = selectedName == name;
  return GestureDetector(
    onTap: onTap,
    child: Container(
      margin: EdgeInsets.only(right: 12.w),
      width: 26.w,
      height: 26.w,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        border: Border.all(
          color: isSelected ? const Color(0xFF18362C) : Colors.grey.shade400,
          width: isSelected ? 2 : 1,
        ),
      ),
      child: isNone
          ? Center(
              child: Icon(
                PhosphorIconsRegular.x,
                size: 13.sp,
                color: Colors.grey.shade700,
              ),
            )
          : (isSelected
              ? Center(
                  child: Icon(
                    PhosphorIconsBold.check,
                    size: 13.sp,
                    color: const Color(0xFF18362C),
                  ),
                )
              : null),
    ),
  );
}

/// 每日專題非同步載入骨架屏。
class LearningPulsingSkeleton extends StatefulWidget {
  const LearningPulsingSkeleton({
    super.key,
    required this.width,
    required this.height,
    this.borderRadius,
  });

  final double width;
  final double height;
  final BorderRadiusGeometry? borderRadius;

  @override
  State<LearningPulsingSkeleton> createState() =>
      _LearningPulsingSkeletonState();
}

class _LearningPulsingSkeletonState extends State<LearningPulsingSkeleton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);
    _animation = Tween<double>(begin: 0.4, end: 0.8).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    return FadeTransition(
      opacity: _animation,
      child: Container(
        width: widget.width,
        height: widget.height,
        decoration: BoxDecoration(
          color: t.surfaceMuted,
          borderRadius: widget.borderRadius ?? BorderRadius.circular(10.r),
        ),
      ),
    );
  }
}

/// 自訂專屬法學課堂入口卡（完整支援深色模式與古銅金點綴）。
class LearningCustomClassroomCard extends StatefulWidget {
  const LearningCustomClassroomCard({
    super.key,
    required this.isDark,
    required this.onTap,
  });

  final bool isDark;
  final VoidCallback onTap;

  @override
  State<LearningCustomClassroomCard> createState() =>
      _LearningCustomClassroomCardState();
}

class _LearningCustomClassroomCardState
    extends State<LearningCustomClassroomCard> {
  double _scale = 1.0;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;

    return GestureDetector(
      onTapDown: (_) => setState(() => _scale = 0.98),
      onTapUp: (_) => setState(() => _scale = 1.0),
      onTapCancel: () => setState(() => _scale = 1.0),
      onTap: widget.onTap,
      child: AnimatedScale(
        scale: _scale,
        duration: const Duration(milliseconds: 120),
        child: NotebookCard(
          backgroundColor: t.surface,
          hasBookmark: true,
          bookmarkColor: t.accentBrass,
          child: Row(
            children: [
              Container(
                width: 42.w,
                height: 42.w,
                decoration: BoxDecoration(
                  color: t.accentBrassContainer,
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(
                    color: t.accentBrass.withValues(alpha: 0.42),
                  ),
                ),
                child: Center(
                  child: Icon(
                    PhosphorIconsRegular.sparkle,
                    size: 20.sp,
                    color: t.accentOnBrassContainer,
                  ),
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '訂製專屬法學課堂',
                      style: t.serifTitle(size: 15.sp),
                    ),
                    SizedBox(height: 3.h),
                    Text(
                      '輸入您的生活爭議情境，量身編排 5 階段修煉節點與隨堂測驗',
                      style: t.sansBody(size: 11.5.sp, color: t.textSecondary),
                    ),
                  ],
                ),
              ),
              SizedBox(width: 8.w),
              Icon(
                PhosphorIconsRegular.caretRight,
                size: 18.sp,
                color: t.accentOnBrassContainer,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// 呼吸微光容器。
class BreathingGlowContainer extends StatefulWidget {
  const BreathingGlowContainer({
    super.key,
    required this.child,
    this.glowColor = const Color(0xFFB5894A),
    this.duration = const Duration(milliseconds: 1800),
  });

  final Widget child;
  final Color glowColor;
  final Duration duration;

  @override
  State<BreathingGlowContainer> createState() => _BreathingGlowContainerState();
}

class _BreathingGlowContainerState extends State<BreathingGlowContainer>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration)
      ..repeat(reverse: true);
    _animation = Tween<double>(begin: 1.5, end: 5.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
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
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16.r),
            boxShadow: [
              BoxShadow(
                color: widget.glowColor
                    .withValues(alpha: 0.14 * (_animation.value / 5.0)),
                blurRadius: _animation.value * 2.w,
                spreadRadius: _animation.value * 0.4.w,
              ),
            ],
          ),
          child: widget.child,
        );
      },
      child: widget.child,
    );
  }
}

/// 呼吸微光小圓點。
class BreathingDot extends StatefulWidget {
  const BreathingDot({super.key, this.color = const Color(0xFF235D46)});
  final Color color;
  @override
  State<BreathingDot> createState() => _BreathingDotState();
}

class _BreathingDotState extends State<BreathingDot>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1200))
      ..repeat(reverse: true);
    _animation = Tween<double>(begin: 0.35, end: 1.0).animate(_controller);
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
        return Opacity(
          opacity: _animation.value,
          child: Container(
            width: 6.w,
            height: 6.w,
            decoration: BoxDecoration(
              color: widget.color,
              shape: BoxShape.circle,
            ),
          ),
        );
      },
    );
  }
}
