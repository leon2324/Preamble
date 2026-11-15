import 'package:flutter/material.dart';

/// 專案共用靜態色票（已全面收斂至「溫柔日系粉彩 × 親切工具風」母體色系）。
///
/// 提示：涉及深淺色動態切換的元件，請優先使用 `context.tokens` (`PreambleTokens`)，
/// 以確保深色模式下文字與卡片永遠維持高對比度。
class AppColors {
  static const background = Color(0xFFFAF8F4);
  static const surface = Color(0xFFFFFFFF);
  static const shadow = Color(0x0D2C3531);
  static const border = Color(0xFFECE8DF);
  static const textPrimary = Color(0xFF2C3531);
  static const textSecondary = Color(0xFF66726D);
  static const textMuted = Color(0xFF949F9A);

  static const searchSurface = Color(0xFFF3F1EC);
  static const newsSurface = Color(0xFFE6F2EC);
  static const newsletterSurface = Color(0xFFFDF2E6);
  static const taskSurface = Color(0xFFEDF3F8);
  static const discussionSurface = Color(0xFFEAE6DD);
  static const chipSurface = Color(0xFFE6F2EC);
  static const placeholder = Color(0xFFA3AEA8);

  /// 品牌核心溫柔鼠尾草綠（親切、治癒、無距離感）
  static const primary = Color(0xFF538A74);
  static const primarySoft = Color(0xFF6FA38E);

  /// 溫柔粉彩強調色選擇器
  /// 0: 奶茶杏 (預設), 1: 珊瑚粉橘, 2: 柔霧天藍, 3: 鼠尾草綠
  static int accentColorIndex = 0;

  static const _accents = [
    Color(0xFFDFA065), // 奶茶杏
    Color(0xFFDF7366), // 珊瑚粉橘
    Color(0xFF6E95B8), // 柔霧天藍
    Color(0xFF538A74), // 鼠尾草綠
  ];

  static Color get accent => _accents[accentColorIndex.clamp(0, _accents.length - 1)];

  static const success = Color(0xFF4B9B7B);
  static const danger = Color(0xFFDF7366);
  static const info = Color(0xFF6E95B8);
}
