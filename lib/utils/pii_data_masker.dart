/// 敏感資料 (PII) 自動遮蔽器
/// 
/// 負責在發送對話至遠端 AI 伺服器前，使用正則表達式掃描並替換字串中的敏感個資（如身分證、電話）。
class PiiDataMasker {
  /// 台灣身分證字號 Regex (首碼大寫英文字母 + 9碼數字)
  static final RegExp _twIdRegex = RegExp(r'[A-Z][1289]\d{8}');

  /// 台灣手機號碼 Regex (09 開頭，可包含連字符或空格)
  static final RegExp _twPhoneRegex = RegExp(r'09\d{2}[-\s]?\d{3}[-\s]?\d{3}');

  /// 遮蔽佔位符
  static const String _maskPlaceholder = '[保護資訊]';

  /// 將傳入的字串進行 PII 去識別化處理
  static String mask(String input) {
    if (input.isEmpty) return input;

    String masked = input;
    // 遮蔽身分證
    masked = masked.replaceAll(_twIdRegex, _maskPlaceholder);
    // 遮蔽手機號碼
    masked = masked.replaceAll(_twPhoneRegex, _maskPlaceholder);

    return masked;
  }
}
