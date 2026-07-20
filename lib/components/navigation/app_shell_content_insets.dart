import 'package:flutter/widgets.dart';

/// App shell 提供給主 Tab 內容的額外底部避讓空間。
///
/// 台灣繁體中文教學註解：這個值只代表 Dynamic Type 讓 IslandBottomNav
/// 相對於既有最小殼層「額外長高」的 logical pixels。不包含 Home Indicator
/// safe area、17pt 浮島外距或任一頁原本的內容底部留白；頁面只把它加在自己
/// 已有的可捲內容 padding，背景則保持全螢幕。
class AppShellContentInsets extends InheritedWidget {
  const AppShellContentInsets({
    super.key,
    required this.additionalBottom,
    required super.child,
  });

  final double additionalBottom;

  /// 找不到 App shell 時回傳 0，讓子頁、預覽與獨立 widget test 可安全使用。
  static double additionalBottomOf(BuildContext context) {
    return context
            .dependOnInheritedWidgetOfExactType<AppShellContentInsets>()
            ?.additionalBottom ??
        0;
  }

  @override
  bool updateShouldNotify(AppShellContentInsets oldWidget) {
    return additionalBottom != oldWidget.additionalBottom;
  }
}
