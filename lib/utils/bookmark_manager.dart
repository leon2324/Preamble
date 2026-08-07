import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// 法規書籤模型
class StatuteBookmark {
  const StatuteBookmark({
    required this.id, // e.g., 'civil_184'
    required this.title, // e.g., '民法第 184 條'
    required this.createdAt,
  });

  final String id;
  final String title;
  final DateTime createdAt;

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'createdAt': createdAt.toIso8601String(),
      };

  factory StatuteBookmark.fromJson(Map<String, dynamic> json) => StatuteBookmark(
        id: json['id'] as String,
        title: json['title'] as String,
        createdAt: DateTime.parse(json['createdAt'] as String),
      );
}

/// 法規書籤管理員
class BookmarkManager extends ChangeNotifier {
  BookmarkManager._privateConstructor();
  static final BookmarkManager instance = BookmarkManager._privateConstructor();

  static const String _prefsKey = 'preamble_statute_bookmarks';
  SharedPreferences? _prefs;
  List<StatuteBookmark> _bookmarks = [];

  Future<void> init(SharedPreferences prefs) async {
    _prefs = prefs;
    _loadState();
  }

  void _loadState() {
    if (_prefs == null) return;
    final jsonString = _prefs!.getString(_prefsKey);
    if (jsonString != null) {
      try {
        final List<dynamic> jsonList = jsonDecode(jsonString) as List<dynamic>;
        _bookmarks = jsonList
            .map((e) => StatuteBookmark.fromJson(e as Map<String, dynamic>))
            .toList();
      } catch (e) {
        debugPrint('BookmarkManager: 無法解析書籤資料 - $e');
      }
    }
  }

  void _saveState() {
    if (_prefs == null) return;
    final jsonString = jsonEncode(_bookmarks.map((e) => e.toJson()).toList());
    _prefs!.setString(_prefsKey, jsonString);
    notifyListeners();
  }

  List<StatuteBookmark> get bookmarks => List.unmodifiable(_bookmarks);

  bool isBookmarked(String id) {
    return _bookmarks.any((b) => b.id == id);
  }

  void toggleBookmark(String id, String title) {
    if (isBookmarked(id)) {
      _bookmarks.removeWhere((b) => b.id == id);
      debugPrint('BookmarkManager: 已移除書籤 $id');
    } else {
      _bookmarks.add(
        StatuteBookmark(
          id: id,
          title: title,
          createdAt: DateTime.now(),
        ),
      );
      debugPrint('BookmarkManager: 已加入書籤 $id');
    }
    _saveState();
  }

  void clear() {
    _bookmarks.clear();
    _saveState();
  }
}
