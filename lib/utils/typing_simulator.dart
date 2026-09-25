import 'dart:async';
import 'dart:math';

/// 模擬真人思考與打字的自然節奏
class TypingSimulator {
  static final _random = Random();

  /// 接收一串字串（例如來自 SSE 的 Token 流），並加入動態微延遲重新 yield
  static Stream<String> simulateStream(Stream<String> sourceStream) async* {
    await for (final chunk in sourceStream) {
      yield chunk;
    }
  }

  /// 為單純的字串包裝成流式輸出 (用於 Mock / 離線模擬)
  /// 預設以 2~4 字的區塊流暢輸出，模擬自然打字速度（總耗時約 0.5~1 秒）
  static Stream<String> simulateString(
    String fullText, {
    Duration punctuationDelay = const Duration(milliseconds: 10),
    Duration charDelay = const Duration(milliseconds: 3),
  }) async* {
    int i = 0;
    while (i < fullText.length) {
      final char = fullText[i];
      final isPunctuation =
          ['，', '。', '？', '！', '\n', ',', '.', '?', '!'].contains(char);

      if (isPunctuation) {
        if (punctuationDelay > Duration.zero) {
          await Future.delayed(punctuationDelay);
        }
        yield char;
        i++;
      } else {
        // 一次輸出 2~4 個字，更加流暢與現代
        final chunkSize = min(2 + _random.nextInt(3), fullText.length - i);
        final chunk = fullText.substring(i, i + chunkSize);
        if (charDelay > Duration.zero) {
          await Future.delayed(charDelay);
        }
        yield chunk;
        i += chunkSize;
      }
    }
  }
}
