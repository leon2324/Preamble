/// 台灣繁體中文教學註解：把「何時可用示範／本機資料代替來源」寫成明確契約。
/// 正式後端若回傳空清單，代表查無資料，與連線失敗是兩個不同結果。
enum DataFallbackReason { unconfigured, remoteEmpty, remoteError }

class DataFallbackPolicy {
  const DataFallbackPolicy({
    required this.onUnconfigured,
    required this.onRemoteEmpty,
    required this.onRemoteError,
  });

  /// 台灣繁體中文教學註解：僅供明確的展示或離線情境選用，允許以本機資料
  /// 替代遠端空結果及錯誤；正式來源預設使用 liveWhenConfigured。
  static const demo = DataFallbackPolicy(
    onUnconfigured: true,
    onRemoteEmpty: true,
    onRemoteError: true,
  );

  /// 台灣繁體中文教學註解：正式來源一旦設定，成功空清單就是空結果，
  /// 請求失敗也不能冒充本機資料；未設定來源時仍保留既有示範流程。
  static const liveWhenConfigured = DataFallbackPolicy(
    onUnconfigured: true,
    onRemoteEmpty: false,
    onRemoteError: false,
  );

  /// 正式來源模式：未設定時明確報錯；遠端空結果照實回空；錯誤往上傳。
  static const strict = DataFallbackPolicy(
    onUnconfigured: false,
    onRemoteEmpty: false,
    onRemoteError: false,
  );

  final bool onUnconfigured;
  final bool onRemoteEmpty;
  final bool onRemoteError;

  bool allows(DataFallbackReason reason) => switch (reason) {
        DataFallbackReason.unconfigured => onUnconfigured,
        DataFallbackReason.remoteEmpty => onRemoteEmpty,
        DataFallbackReason.remoteError => onRemoteError,
      };
}

/// 未設定正式來源時由 strict 模式拋出，避免默默顯示示範資料。
class DataSourceUnavailableException implements Exception {
  const DataSourceUnavailableException(this.source);

  final String source;

  @override
  String toString() => '尚未設定資料來源：$source';
}
