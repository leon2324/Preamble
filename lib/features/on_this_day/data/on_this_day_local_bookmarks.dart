import 'package:shared_preferences/shared_preferences.dart';

// 「歷史上的今天」收藏屬於個人偏好資料；在沒有正式 Auth + RLS 前，
// 只保存於本機 SharedPreferences，避免把個人閱讀偏好寫入雲端。
class OnThisDayLocalBookmarks {
  const OnThisDayLocalBookmarks._();

  static const _storageKey = 'lawAppOnThisDaySavedCaseIds';

  static Future<Set<String>> load() async {
    final preferences = await SharedPreferences.getInstance();
    return (preferences.getStringList(_storageKey) ?? const <String>[]).toSet();
  }

  static Future<bool> isSaved(String caseId) async {
    final ids = await load();
    return ids.contains(caseId);
  }

  static Future<bool> toggle(String caseId) async {
    final preferences = await SharedPreferences.getInstance();
    final ids =
        (preferences.getStringList(_storageKey) ?? const <String>[]).toSet();
    final next = !ids.contains(caseId);
    if (next) {
      ids.add(caseId);
    } else {
      ids.remove(caseId);
    }
    final sortedIds = ids.toList()..sort();
    await preferences.setStringList(_storageKey, sortedIds);
    return next;
  }
}
