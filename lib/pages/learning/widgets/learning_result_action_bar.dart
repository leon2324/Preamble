import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:preamble/components/home/v2/home_v2_palette.dart';
import 'package:preamble/theme/app_colors.dart';

/// 學習工具計算或起草結果下方的主要操作按鈕。
///
/// 台灣繁體中文教學註解：按鈕文字會跟隨系統字體放大，因此不以省略號截斷
/// 主要動作；兩行內的自然換行和內容驅動高度能保留完整語意與觸控範圍。
class LearningResultActionButton extends StatelessWidget {
  const LearningResultActionButton({
    super.key,
    required this.icon,
    required this.label,
    required this.color,
    required this.onPressed,
  });

  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onPressed;

  static const double _iconSize = 18;
  static const double _iconLabelGap = 5;
  static const double _horizontalPadding = 6;

  TextStyle _labelStyle(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final foreground = isDark ? const Color(0xFFF2F4F7) : HomeV2Palette.ink;

    return (theme.textTheme.labelMedium ?? const TextStyle()).copyWith(
      color: foreground,
      fontSize: 10.5.sp,
      fontWeight: FontWeight.w800,
      height: 1.2,
    );
  }

  Color _iconColor(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return isDark
        ? Color.lerp(color, Colors.white, 0.52)!
        : Color.lerp(color, HomeV2Palette.trustGreen, 0.48)!;
  }

  TextPainter _createTextPainter(BuildContext context, {int? maxLines}) {
    return TextPainter(
      text: TextSpan(text: label, style: _labelStyle(context)),
      textDirection: Directionality.of(context),
      textScaler: MediaQuery.textScalerOf(context),
      maxLines: maxLines,
    );
  }

  double _buttonWidthForText(double textWidth) {
    return textWidth + _iconSize + _iconLabelGap + (_horizontalPadding * 2) + 2;
  }

  double _requiredSingleLineWidth(BuildContext context) {
    final painter = _createTextPainter(context, maxLines: 1)..layout();
    final width = _buttonWidthForText(painter.width);
    painter.dispose();

    // 台灣繁體中文教學註解：這個寬度包含實際文字、圖示、間距、內距與邊框餘量，
    // 操作列會用它決定是否真的放得下，而不是以手機型號或固定字級倍率猜測。
    return width;
  }

  double _requiredTwoLineWidth(BuildContext context) {
    final naturalPainter = _createTextPainter(context)..layout();
    var lowerBound = 0.0;
    var upperBound = naturalPainter.width;
    naturalPainter.dispose();

    // 以二分搜尋找出完整文字在兩行內可讀的最小寬度；沒有靠固定字數猜中文斷行。
    for (var iteration = 0; iteration < 14; iteration++) {
      final candidate = (lowerBound + upperBound) / 2;
      final painter = _createTextPainter(context, maxLines: 2)
        ..layout(maxWidth: candidate);
      final fits = !painter.didExceedMaxLines;
      painter.dispose();
      if (fits) {
        upperBound = candidate;
      } else {
        lowerBound = candidate;
      }
    }

    return _buttonWidthForText(upperBound);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final labelStyle = _labelStyle(context);
    final foreground = labelStyle.color!;
    final iconColor = _iconColor(context);
    final background = isDark
        ? theme.colorScheme.surface.withValues(alpha: 0.92)
        : Color.alphaBlend(
            AppColors.textPrimary.withValues(alpha: 0.025),
            AppColors.surface,
          );
    final borderColor =
        isDark ? const Color(0xFF3A4651) : const Color(0xFFE7DDD2);

    return Semantics(
      button: true,
      child: Material(
        color: Colors.transparent,
        child: Ink(
          decoration: BoxDecoration(
            color: background,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: borderColor),
          ),
          child: InkWell(
            onTap: onPressed,
            borderRadius: BorderRadius.circular(8),
            splashColor: foreground.withValues(alpha: 0.08),
            highlightColor: foreground.withValues(alpha: 0.05),
            child: ConstrainedBox(
              constraints: const BoxConstraints(minHeight: 44),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: _horizontalPadding,
                  vertical: 8,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(icon, size: _iconSize, color: iconColor),
                    const SizedBox(width: _iconLabelGap),
                    Flexible(
                      child: Text(
                        label,
                        maxLines: 2,
                        textAlign: TextAlign.center,
                        style: labelStyle,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// 依可用寬度與系統字體倍率排列結果操作列。
///
/// 台灣繁體中文教學註解：一般尺寸保留三欄方便快速操作；空間不足時將
/// 較長的 PDF 動作移到第二列，避免依賴特定手機型號或強制縮小文字。
class LearningResultActionBar extends StatelessWidget {
  const LearningResultActionBar({
    super.key,
    required this.copyAction,
    required this.noteAction,
    required this.exportAction,
  });

  final LearningResultActionButton copyAction;
  final LearningResultActionButton noteAction;
  final LearningResultActionButton exportAction;

  static const double _spacing = 8;

  bool _fits(List<double> widths, double maxWidth) {
    final totalSpacing = _spacing * (widths.length - 1);
    return widths.fold<double>(0, (total, width) => total + width) +
            totalSpacing <=
        maxWidth;
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final actions = [copyAction, noteAction, exportAction];
        final requiredWidths = actions
            .map((action) => action._requiredSingleLineWidth(context))
            .toList(growable: false);

        if (_fits(requiredWidths, constraints.maxWidth)) {
          return Row(
            children: [
              for (var index = 0; index < actions.length; index++) ...[
                if (index > 0) const SizedBox(width: _spacing),
                Expanded(
                  flex: (requiredWidths[index] * 100).round(),
                  child: actions[index],
                ),
              ],
            ],
          );
        }

        final compactSingleRowWidths = [
          requiredWidths[0],
          requiredWidths[1],
          exportAction._requiredTwoLineWidth(context),
        ];
        if (_fits(compactSingleRowWidths, constraints.maxWidth)) {
          return Row(
            children: [
              for (var index = 0; index < actions.length; index++) ...[
                if (index > 0) const SizedBox(width: _spacing),
                Expanded(
                  flex: (compactSingleRowWidths[index] * 100).round(),
                  child: actions[index],
                ),
              ],
            ],
          );
        }

        if (_fits(requiredWidths.take(2).toList(), constraints.maxWidth)) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Expanded(child: copyAction),
                  const SizedBox(width: _spacing),
                  Expanded(child: noteAction),
                ],
              ),
              const SizedBox(height: _spacing),
              SizedBox(width: double.infinity, child: exportAction),
            ],
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            copyAction,
            const SizedBox(height: _spacing),
            noteAction,
            const SizedBox(height: _spacing),
            exportAction,
          ],
        );
      },
    );
  }
}
