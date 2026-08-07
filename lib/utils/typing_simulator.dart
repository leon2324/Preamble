import 'dart:async';
import 'dart:math';

/// 模擬真人思考與打字的自然節奏
class TypingSimulator {
  static final _random = Random();

  /// 接收一串字串（例如來自 SSE 的 Token 流），並加入動態延遲重新 yield
  static Stream<String> simulateStream(Stream<String> sourceStream) async* {
    await for (final chunk in sourceStream) {
      for (int i = 0; i < chunk.length; i++) {
        final char = chunk[i];
        
        // 遇到標點符號，大幅度停頓 (模擬思考)
        if (['，', '。', '？', '！', '\n', ',', '.', '?', '!'].contains(char)) {
          await Future.delayed(Duration(milliseconds: 300 + _random.nextInt(200)));
        } else {
          // 一般字元，隨機小幅度停頓
          await Future.delayed(Duration(milliseconds: 20 + _random.nextInt(30)));
        }
        
        yield char;
      }
    }
  }

  /// 為單純的字串包裝成流式輸出 (用於 Mock 測試)
  static Stream<String> simulateString(String fullText) async* {
    for (int i = 0; i < fullText.length; i++) {
      final char = fullText[i];
      
      if (['，', '。', '？', '！', '\n', ',', '.', '?', '!'].contains(char)) {
        await Future.delayed(Duration(milliseconds: 300 + _random.nextInt(200)));
      } else {
        await Future.delayed(Duration(milliseconds: 20 + _random.nextInt(30)));
      }
      
      yield char;
    }
  }
}
