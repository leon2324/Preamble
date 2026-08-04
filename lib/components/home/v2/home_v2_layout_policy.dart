import 'dart:math' as math;

import 'package:flutter/material.dart';

/// 首頁探索型卡片的同步版型規則。
///
/// 台灣繁體中文教學註解：這個 policy 不以文字倍率或裝置方向選版型，而是把
/// 真實可用寬度、主標題、CTA 與內距一起量測。探索型內容保留水平瀏覽；文字
/// 變大時只讓卡片逐步變寬，仍留下下一張卡片的預覽提示可左右滑動。
class HomeV2LayoutPolicy {
  const HomeV2LayoutPolicy._();

  static double minimumReadableCardWidth(
    BuildContext context, {
    required String primaryTitle,
    required TextStyle titleStyle,
    String? actionLabel,
    TextStyle? actionStyle,
    required double horizontalPadding,
    int readableCharacters = 7,
  }) {
    final titleSample = primaryTitle.characters.take(readableCharacters).string;
    final direction = Directionality.of(context);
    final scaler = MediaQuery.textScalerOf(context);
    double measure(String text, TextStyle style) => (TextPainter(
          text: TextSpan(text: text, style: style),
          textScaler: scaler,
          textDirection: direction,
        )..layout())
            .width;

    final titleWidth = measure(titleSample, titleStyle);
    final actionWidth = actionLabel == null || actionStyle == null
        ? 0.0
        : measure(actionLabel, actionStyle);
    return math.max(titleWidth, actionWidth) + horizontalPadding * 2;
  }

  /// 以內容最低可讀寬度推導 carousel 卡片比例，並保留下一張預覽。
  static double carouselViewportFraction({
    required double availableWidth,
    required double minimumReadableWidth,
  }) {
    if (availableWidth <= 0) return .84;
    return (minimumReadableWidth / availableWidth).clamp(.76, .94);
  }
}
