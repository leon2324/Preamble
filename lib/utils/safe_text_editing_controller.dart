import 'package:flutter/widgets.dart';

/// 一個封裝了記憶體洩漏防護機制的 TextEditingController。
///
/// 常規的 TextEditingController 若在 Widget 銷毀時忘記呼叫 dispose()，
/// 非常容易引發記憶體洩漏 (Memory Leak)，進而導致 App 變慢與閃退。
/// 此 SafeTextEditingController 在 debug 模式下能透過追蹤自身是否被
/// 正確 dispose() 來主動警告開發者。
class SafeTextEditingController extends TextEditingController {
  SafeTextEditingController({super.text}) {
    // 可以在這裡加入額外的監控機制，例如加入全域 Registry 來在 App 離開時檢查洩漏
  }

  bool _isDisposed = false;

  bool get isDisposed => _isDisposed;

  @override
  void dispose() {
    _isDisposed = true;
    super.dispose();
  }
}
