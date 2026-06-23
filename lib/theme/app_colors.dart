import 'package:flutter/material.dart';

/// 專案共用色票。
///
/// 之後若要調整品牌色或增加深色模式，先從這個檔案收斂顏色會最省力。
class AppColors {
  static const background = Color(0xFFFAF7F2);
  static const surface = Color(0xFFFFFDFC);
  static const shadow = Color(0x16000000);
  static const border = Color(0xFFE5E7EB);
  static const textPrimary = Color(0xFF101828);
  static const textSecondary = Color(0xFF667085);
  static const textMuted = Color(0xFF9A9A9A);

  static const searchSurface = Color(0xFFF1F0EE);
  static const newsSurface = Color(0xFFDDE9E1);
  static const newsletterSurface = Color(0xFFF3E6D6);
  static const taskSurface = Color(0xFFDDD1F2);
  static const discussionSurface = Color(0xFFDCE7F5);
  static const chipSurface = Color(0xFFEAF0F8);
  static const placeholder = Color(0xFFB7B7B7);

  static const primary = Color(0xFF243B63);
  static const primarySoft = Color(0xFF31486F);

  // 台灣繁體中文教學註解：
  // 動態 Accent 品牌色彩選擇器。
  // 0: 金色 (預設), 1: 典雅酒紅, 2: 正義深藍, 3: 森林草綠。
  static int accentColorIndex = 0;

  static const _accents = [
    Color(0xFFD6A85F), // 金色
    Color(0xFFC62828), // 典雅酒紅
    Color(0xFF1565C0), // 正義深藍
    Color(0xFF2E7D32), // 森林草綠
  ];

  static Color get accent => _accents[accentColorIndex];

  static const success = Color(0xFF8BF45F);
  static const danger = Color(0xFFFF8D8D);
  static const info = Color(0xFFC96B3B);
}
