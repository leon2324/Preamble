/// 法條資料庫頁使用的條文資料模型。
///
/// 這個模型刻意只保留 App 需要呈現與搜尋的欄位，避免 UI 直接依賴
/// 全國法規資料庫 API 的原始 JSON 結構；之後若來源欄位調整，優先改
/// service 的轉換邏輯即可。
class StatuteItem {
  const StatuteItem({
    required this.codeName,
    required this.articleNumber,
    required this.articleText,
    required this.lawUrl,
    required this.category,
    required this.updatedDate,
    required this.isRepealed,
    required this.tags,
  });

  final String codeName;
  final String articleNumber;
  final String articleText;
  final String lawUrl;
  final String category;
  final String updatedDate;
  final bool isRepealed;
  final List<String> tags;

  String get displayTitle {
    if (articleNumber.isEmpty) return codeName;
    return '$codeName $articleNumber';
  }

  String get plainSummary {
    final normalized = articleText.replaceAll(RegExp(r'\s+'), ' ').trim();
    if (normalized.length <= 72) return normalized;
    return '${normalized.substring(0, 72)}...';
  }

  bool matches(String query) {
    final normalizedQuery = query.trim().toLowerCase();
    if (normalizedQuery.isEmpty) return true;

    final haystacks = [
      codeName,
      articleNumber,
      articleText,
      category,
      ...tags,
    ].map((value) => value.toLowerCase());

    return haystacks.any((value) => value.contains(normalizedQuery));
  }
}
