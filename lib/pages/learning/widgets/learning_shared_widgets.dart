import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:preamble/components/home/v2/home_v2_palette.dart';
import 'package:preamble/features/case_time_machine/widgets/case_time_machine_svg_icon.dart';
import 'package:preamble/pages/learning/widgets/notebook_aesthetics.dart';
import 'package:preamble/theme/app_colors.dart';

/// 學習頁共用 hero 圖片。
///
/// 這裡只處理圖片來源的顯示與 fallback，不保存頁面狀態；
/// 讓 `KnowLawPage` 可以專注在資料與學習流程。
Widget buildLearningHeroImage({
  required String? imageUrl,
  required String localAsset,
  required BoxFit fit,
}) {
  if (imageUrl != null && imageUrl.isNotEmpty) {
    return Image.network(
      imageUrl,
      fit: fit,
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return Stack(
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
        );
      },
      errorBuilder: (context, error, stackTrace) {
        return Image.asset(localAsset, fit: fit);
      },
    );
  }
  return Image.asset(localAsset, fit: fit);
}

/// 主修課卡片上方的膠囊標籤。
///
/// 這個 helper 只吃文字與深色模式，不依賴 `KnowLawPageState`，
/// 適合先抽成共用純 UI。
Widget buildLearningCourseBadge(String label, bool isDark) {
  return Container(
    padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
    decoration: BoxDecoration(
      color: isDark
          ? const Color(0xFF10161D).withValues(alpha: 0.74)
          : Colors.white.withValues(alpha: 0.74),
      borderRadius: BorderRadius.circular(999.r),
      border: Border.all(
        color: isDark
            ? const Color(0xFF2D3845)
            : Colors.white.withValues(alpha: 0.72),
      ),
    ),
    child: Text(
      label,
      style: TextStyle(
        fontSize: 10.sp,
        fontWeight: FontWeight.w900,
        color: isDark
            ? Colors.white.withValues(alpha: 0.9)
            : HomeV2Palette.trustGreen,
      ),
    ),
  );
}

/// 手繪風勾選列。
///
/// 生活工具箱的檢核清單只需要把目前值與 onChanged 傳進來；
/// 勾選後要不要 `setState` 由呼叫端決定，這裡不碰父層狀態。
Widget buildLearningHanddrawnCheckbox({
  required String label,
  required bool value,
  required ValueChanged<bool?> onChanged,
  required bool isDark,
}) {
  return InkWell(
    onTap: () => onChanged(!value),
    child: Padding(
      padding: EdgeInsets.symmetric(vertical: 6.h),
      child: Row(
        children: [
          Container(
            width: 18.w,
            height: 18.w,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: value
                    ? HomeV2Palette.trustGreen
                    : (isDark
                        ? const Color(0xFF4C5B6B)
                        : const Color(0xFFC4B89F)),
                width: 1.6.w,
              ),
              color: value
                  ? HomeV2Palette.trustGreen.withValues(alpha: 0.12)
                  : Colors.transparent,
            ),
            child: Center(
              child: value
                  ? Icon(
                      Icons.star,
                      size: 10.sp,
                      color: HomeV2Palette.trustGreen,
                    )
                  : null,
            ),
          ),
          SizedBox(width: 9.w),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 12.sp,
                decoration: value ? TextDecoration.lineThrough : null,
                decorationColor: isDark ? Colors.grey : const Color(0xFFC4B89F),
                decorationThickness: 1.6,
                color: value ? AppColors.textMuted : AppColors.textPrimary,
                fontWeight: value ? FontWeight.normal : FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

/// 便利貼風文字輸入框。
///
/// controller 由父層持有，這個 helper 只負責欄位外觀，
/// 因此不會改變工具箱表單的資料流。
Widget buildLearningPostItInput({
  required TextEditingController controller,
  required String hintText,
  required bool isDark,
  int maxLines = 1,
}) {
  final bgColor = isDark ? const Color(0xFF2E2719) : const Color(0xFFFFFAD6);
  final borderCol = isDark ? const Color(0xFF7A6539) : const Color(0xFFEAD8A8);
  return Container(
    decoration: BoxDecoration(
      color: bgColor,
      borderRadius: BorderRadius.circular(8.r),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.05),
          blurRadius: 4,
          offset: const Offset(1, 2),
        ),
      ],
      border: Border.all(color: borderCol, width: 1.w),
    ),
    padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 2.h),
    child: TextField(
      controller: controller,
      maxLines: maxLines,
      style: TextStyle(
        fontSize: 12.5.sp,
        fontWeight: FontWeight.bold,
        color: isDark ? Colors.amber.shade100 : const Color(0xFF5D4817),
      ),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: TextStyle(
          fontSize: 12.sp,
          color: isDark
              ? Colors.amber.shade100.withValues(alpha: 0.4)
              : const Color(0xFFC0AE83),
        ),
        border: InputBorder.none,
        isDense: true,
      ),
    ),
  );
}

/// 筆記本橫線風輸入框。
///
/// 這個 helper 被多個生活法律工具共用，抽出後仍由父層傳入 controller；
/// 所以格式、keyboardType 與輸入結果都保持原本行為。
Widget buildLearningNotebookInput({
  required TextEditingController controller,
  required String labelText,
  required String hintText,
  required bool isDark,
  TextInputType keyboardType = TextInputType.text,
}) {
  final lineCol = isDark ? const Color(0xFF2D3845) : const Color(0xFFE5CEB1);
  final textCol = isDark ? Colors.blue.shade100 : const Color(0xFF374E6F);
  return Padding(
    padding: EdgeInsets.symmetric(vertical: 6.h),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (labelText.isNotEmpty)
          Text(
            labelText,
            style: TextStyle(
              fontSize: 11.sp,
              fontWeight: FontWeight.w900,
              color: isDark ? Colors.grey : const Color(0xFF7A6B53),
            ),
          ),
        Container(
          decoration: BoxDecoration(
            border: Border(bottom: BorderSide(color: lineCol, width: 1.4.w)),
          ),
          padding: EdgeInsets.symmetric(vertical: 2.h),
          child: TextField(
            controller: controller,
            keyboardType: keyboardType,
            style: TextStyle(
              fontSize: 13.sp,
              color: textCol,
              fontWeight: FontWeight.bold,
            ),
            decoration: InputDecoration(
              hintText: hintText,
              hintStyle: TextStyle(
                fontSize: 11.5.sp,
                color: isDark ? Colors.grey.shade600 : const Color(0xFFC1B8AA),
              ),
              border: InputBorder.none,
              isDense: true,
              contentPadding: EdgeInsets.symmetric(vertical: 4.h),
            ),
          ),
        ),
      ],
    ),
  );
}

/// 印章風主要按鈕。
///
/// 這裡只呈現按鈕外觀並觸發 callback；計算器與表單邏輯仍留在原本頁面。
Widget buildLearningSealButton({
  required String label,
  required VoidCallback onPressed,
  required Color color,
}) {
  return GestureDetector(
    onTap: onPressed,
    child: AnimatedContainer(
      duration: const Duration(milliseconds: 100),
      padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 8.h),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24.r),
        border: Border.all(color: color, width: 2.2.w),
        color: color.withValues(alpha: 0.08),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.15),
            blurRadius: 4,
            offset: const Offset(1, 2),
          ),
        ],
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12.5.sp,
          fontWeight: FontWeight.w900,
          color: color,
          letterSpacing: 1.5,
        ),
      ),
    ),
  );
}

/// 紙膠帶風次要按鈕。
///
/// 保留原本輕量、扁平的紙膠帶樣式；呼叫端負責決定實際操作。
Widget buildLearningWashiTapeButton({
  required String label,
  required VoidCallback onPressed,
  required Color color,
}) {
  return GestureDetector(
    onTap: onPressed,
    child: Container(
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 7.h),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(2.r),
        border: Border.all(
          color: color.withValues(alpha: 0.35),
          width: 1.w,
        ),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11.sp,
          fontWeight: FontWeight.w900,
          color: color,
        ),
      ),
    ),
  );
}

/// 摘錄顏色選擇圓點。
///
/// 色點只知道目前選到哪個名稱與點擊 callback，
/// 不直接修改手帳筆記資料，方便未來複用到其他 highlight UI。
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
          color: isSelected ? Colors.black : Colors.grey.shade400,
          width: isSelected ? 2.w : 0.8.w,
        ),
        boxShadow: isSelected
            ? [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.15),
                  blurRadius: 3,
                  offset: const Offset(0, 1.5),
                )
              ]
            : null,
      ),
      child: isNone
          ? Center(
              child:
                  Icon(Icons.close, size: 14.sp, color: Colors.grey.shade700),
            )
          : (isSelected
              ? Center(
                  child: Icon(Icons.check, size: 14.sp, color: Colors.black),
                )
              : null),
    ),
  );
}

/// 每日專題非同步載入骨架屏。
///
/// 這個元件只做淡入淡出的 skeleton loading，不讀取任何頁面狀態；
/// 因此從 `KnowLawPage` 抽出後不會影響資料載入流程。
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return FadeTransition(
      opacity: _animation,
      child: Container(
        width: widget.width,
        height: widget.height,
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF2C3540) : const Color(0xFFE5E9EC),
          borderRadius: widget.borderRadius ?? BorderRadius.circular(8.r),
        ),
      ),
    );
  }
}

/// 自訂專屬法學課堂入口卡。
///
/// 卡片本身只處理按壓縮放與畫面呈現；開啟 dialog 的流程仍由父層 callback 控制。
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
    final cardBg =
        widget.isDark ? const Color(0xFF2E2D24) : const Color(0xFFFFFDE7);
    final circleBg =
        widget.isDark ? const Color(0xFF4A4930) : const Color(0xFFFFF59D);
    final iconColor =
        widget.isDark ? const Color(0xFFFFD54F) : const Color(0xFFF57F17);

    return GestureDetector(
      onTapDown: (_) => setState(() => _scale = 0.97),
      onTapUp: (_) => setState(() => _scale = 1.0),
      onTapCancel: () => setState(() => _scale = 1.0),
      onTap: widget.onTap,
      child: AnimatedScale(
        scale: _scale,
        duration: const Duration(milliseconds: 100),
        child: NotebookCard(
          backgroundColor: cardBg,
          child: Row(
            children: [
              Container(
                width: 40.w,
                height: 40.w,
                decoration: BoxDecoration(
                  color: circleBg,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: CtmSvgIcon(
                    CtmSvgIcons.idea,
                    size: 20.sp,
                    color: iconColor,
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
                      style: TextStyle(
                        fontSize: 14.5.sp,
                        fontWeight: FontWeight.w900,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      '輸入您的生活狀況，AI 將量身打造 5 個學習單元與測驗！',
                      style: TextStyle(
                        fontSize: 10.5.sp,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: 8.w),
              Icon(
                Icons.chevron_right,
                size: 20.sp,
                color: iconColor.withValues(alpha: 0.8),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// 呼吸發光容器，用以加強重點入口視覺優先級。
class BreathingGlowContainer extends StatefulWidget {
  const BreathingGlowContainer({
    super.key,
    required this.child,
    this.glowColor = const Color(0xFF6B4B14),
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
    _animation = Tween<double>(begin: 1.5, end: 6.0).animate(
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
                    .withValues(alpha: 0.15 * (_animation.value / 6.0)),
                blurRadius: _animation.value * 2.w,
                spreadRadius: _animation.value * 0.5.w,
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

/// 呼吸發光小圓點，用於提醒或高亮入口。
class BreathingDot extends StatefulWidget {
  const BreathingDot({super.key, this.color = const Color(0xFF4E7D5B)});
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
    _animation = Tween<double>(begin: 0.3, end: 1.0).animate(_controller);
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
              boxShadow: [
                BoxShadow(
                  color: widget.color.withValues(alpha: 0.5),
                  blurRadius: 4.w,
                  spreadRadius: 1.w,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
