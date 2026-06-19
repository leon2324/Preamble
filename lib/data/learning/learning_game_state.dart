import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

/// 小法助成長檔案與成就系統的狀態管理
class LearningGameState extends ChangeNotifier {
  static const int totalLevels = 10;
  static const int experiencePerLevel = 100;

  // 台灣繁體中文教學註解：
  // Level、稱號、頭像與輔助符號都用同一個 index 對齊；
  // 日後若要增減等級，請同步調整 totalLevels 與下方三個清單。
  static const List<String> _levelTitles = [
    '法學見習生',
    '條文閱讀員',
    '案例整理員',
    '證據守門員',
    '租屋權益顧問',
    '消費調解員',
    '交通責任顧問',
    '職場權益顧問',
    '法庭溝通者',
    '首席法律導師',
  ];

  static const List<String> _levelSymbols = [
    '📘',
    '🔖',
    '🗂️',
    '🔎',
    '⚖️',
    '🛡️',
    '🚗',
    '💼',
    '🏛️',
    '🌿',
  ];

  static const List<String> _levelAvatarAssets = [
    'assets/images/learning/levels/level_01_legal_beginner.png',
    'assets/images/learning/levels/level_02_article_reader.png',
    'assets/images/learning/levels/level_03_case_organizer.png',
    'assets/images/learning/levels/level_04_evidence_keeper.png',
    'assets/images/learning/levels/level_05_housing_guide.png',
    'assets/images/learning/levels/level_06_consumer_mediator.png',
    'assets/images/learning/levels/level_07_traffic_guide.png',
    'assets/images/learning/levels/level_08_workplace_consultant.png',
    'assets/images/learning/levels/level_09_courtroom_communicator.png',
    'assets/images/learning/levels/level_10_chief_legal_mentor.png',
  ];

  static final LearningGameState instance = LearningGameState._internal();

  LearningGameState._internal() {
    _loadState();
  }

  int _level = 1;
  int _experience = 10; // 初始經驗值
  Set<String> _completedSteps = {};
  List<Map<String, dynamic>> _incorrectQuestions = [];
  List<Map<String, dynamic>> _savedEvidenceLists = [];
  Set<String> _unlockedBadges = {'初學乍練'}; // 預設解鎖第一個徽章
  int _translatorUsageCount = 0;
  List<Map<String, dynamic>> _quizHistory = [];

  // 學習連擊與簽到狀態
  int _studyStreak = 0;
  String _lastStudyDate = '';
  String _lastDailyQuizDate = '';
  int _dailyQuizCorrectCount = 0;

  // 貼紙/印章封面自訂狀態
  String _coverColorHex = '#EFECE6';
  Set<String> _unlockedStickers = {'sprout'};
  List<Map<String, dynamic>> _placedStickers = [];

  // 筆記與收藏狀態屬性
  Set<String> _savedArticles = {};
  List<Map<String, dynamic>> _savedQuotes = [];
  List<Map<String, dynamic>> _savedHighlights = [];
  Set<String> _viewedCategories = {};
  Map<String, String> _articleNotes = {};

  // 筆記本外觀與三段論狀態
  bool _useHandwrittenFont = false;
  String _notebookPaperStyle = 'grid'; // 'grid', 'lined', 'dotted', 'cornell'
  List<Map<String, dynamic>> _cornellNotes = [];

  int get level => _level;
  int get experience => _experience;
  Set<String> get completedSteps => _completedSteps;
  List<Map<String, dynamic>> get incorrectQuestions => _incorrectQuestions;
  List<Map<String, dynamic>> get savedEvidenceLists => _savedEvidenceLists;
  Set<String> get unlockedBadges => _unlockedBadges;
  List<Map<String, dynamic>> get quizHistory => _quizHistory;

  // 學習連擊與簽到 getters
  int get studyStreak => _studyStreak;
  String get lastStudyDate => _lastStudyDate;
  String get lastDailyQuizDate => _lastDailyQuizDate;

  // 貼紙/印章封面自訂 getters
  String get coverColorHex => _coverColorHex;
  Set<String> get unlockedStickers => _unlockedStickers;
  List<Map<String, dynamic>> get placedStickers => _placedStickers;

  // 筆記與收藏 Getters
  Set<String> get savedArticles => _savedArticles;
  List<Map<String, dynamic>> get savedQuotes => _savedQuotes;
  List<Map<String, dynamic>> get savedHighlights => _savedHighlights;
  Set<String> get viewedCategories => _viewedCategories;
  Map<String, String> get articleNotes => _articleNotes;

  // 筆記本外觀與三段論 getters
  bool get useHandwrittenFont => _useHandwrittenFont;
  String get notebookPaperStyle => _notebookPaperStyle;
  List<Map<String, dynamic>> get cornellNotes => _cornellNotes;

  String getArticleNote(String title) => _articleNotes[title] ?? '';

  void setArticleNote(String title, String noteText) {
    _articleNotes[title] = noteText;
    _saveState();
    notifyListeners();
  }

  // 經驗值升級閥值
  int get nextLevelXp => experiencePerLevel;
  int get maxLevel => totalLevels;
  int get currentLevelIndex => _level.clamp(1, totalLevels).toInt() - 1;
  int get xpToNextLevel => _level >= totalLevels
      ? 0
      : (nextLevelXp - _experience).clamp(0, nextLevelXp).toInt();
  double get levelProgress => _level >= totalLevels
      ? 1
      : (_experience / nextLevelXp).clamp(0.0, 1.0).toDouble();

  // 取得當前表情與稱號
  String get mascotExpression => _levelSymbols[currentLevelIndex];

  String get levelTitle => _levelTitles[currentLevelIndex];
  String get mascotAsset => _levelAvatarAssets[currentLevelIndex];

  String? get nextLevelTitle {
    if (_level >= totalLevels) return null;
    return _levelTitles[currentLevelIndex + 1];
  }

  // 載入狀態
  Future<void> _loadState() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _level =
          (prefs.getInt('learning_level') ?? 1).clamp(1, totalLevels).toInt();
      _experience = prefs.getInt('learning_experience') ?? 10;
      if (_level >= totalLevels) {
        _experience = nextLevelXp;
      } else {
        _experience = _experience.clamp(0, nextLevelXp - 1).toInt();
      }
      _translatorUsageCount = prefs.getInt('learning_translator_count') ?? 0;

      final stepsRaw = prefs.getStringList('learning_completed_steps');
      if (stepsRaw != null) {
        _completedSteps = stepsRaw.toSet();
      }

      final badgesRaw = prefs.getStringList('learning_unlocked_badges');
      if (badgesRaw != null) {
        _unlockedBadges = badgesRaw.toSet();
      } else {
        _unlockedBadges = {'初學乍練'};
      }

      final incorrectRaw = prefs.getString('learning_incorrect_questions');
      if (incorrectRaw != null) {
        _incorrectQuestions =
            List<Map<String, dynamic>>.from(jsonDecode(incorrectRaw));
      }

      final evidenceRaw = prefs.getString('learning_saved_evidences');
      if (evidenceRaw != null) {
        _savedEvidenceLists =
            List<Map<String, dynamic>>.from(jsonDecode(evidenceRaw));
      }

      final quizHistoryRaw = prefs.getString('learning_quiz_history');
      if (quizHistoryRaw != null) {
        _quizHistory =
            List<Map<String, dynamic>>.from(jsonDecode(quizHistoryRaw));
      }

      // 載入學習連擊與簽到狀態
      _studyStreak = prefs.getInt('learning_study_streak') ?? 0;
      _lastStudyDate = prefs.getString('learning_last_study_date') ?? '';
      _lastDailyQuizDate = prefs.getString('learning_last_daily_quiz_date') ?? '';
      _dailyQuizCorrectCount = prefs.getInt('learning_daily_quiz_correct_count') ?? 0;

      // 載入自訂貼紙封面狀態
      _coverColorHex = prefs.getString('learning_cover_color_hex') ?? '#EFECE6';
      final stickersRaw = prefs.getStringList('learning_unlocked_stickers');
      if (stickersRaw != null) {
        _unlockedStickers = stickersRaw.toSet();
      } else {
        _unlockedStickers = {'sprout'};
      }
      final placedRaw = prefs.getString('learning_placed_stickers');
      if (placedRaw != null) {
        _placedStickers = List<Map<String, dynamic>>.from(jsonDecode(placedRaw));
      } else {
        _placedStickers = [];
      }

      // 載入單元收藏
      final articlesRaw = prefs.getStringList('learning_saved_articles');
      if (articlesRaw != null) {
        _savedArticles = articlesRaw.toSet();
      }

      // 載入思考金句
      final quotesRaw = prefs.getString('learning_saved_quotes');
      if (quotesRaw != null) {
        _savedQuotes = List<Map<String, dynamic>>.from(jsonDecode(quotesRaw));
      }

      // 載入螢光筆劃記重點
      final highlightsRaw = prefs.getString('learning_saved_highlights');
      if (highlightsRaw != null) {
        _savedHighlights = List<Map<String, dynamic>>.from(jsonDecode(highlightsRaw));
      }

      // 載入看過的議題/分類
      final viewedRaw = prefs.getStringList('learning_viewed_categories');
      if (viewedRaw != null) {
        _viewedCategories = viewedRaw.toSet();
      }

      // 載入自訂單元筆記
      final notesRaw = prefs.getString('learning_article_notes');
      if (notesRaw != null) {
        try {
          _articleNotes = Map<String, String>.from(jsonDecode(notesRaw));
        } catch (e) {
          debugPrint('Error parsing article notes: $e');
        }
      }

      // 載入筆記本外觀與三段論設定
      _useHandwrittenFont = prefs.getBool('learning_use_handwritten_font') ?? false;
      _notebookPaperStyle = prefs.getString('learning_notebook_paper_style') ?? 'grid';
      final cornellRaw = prefs.getString('learning_cornell_notes');
      if (cornellRaw != null) {
        _cornellNotes = List<Map<String, dynamic>>.from(jsonDecode(cornellRaw));
      } else {
        _cornellNotes = [];
      }

      notifyListeners();
    } catch (e) {
      debugPrint('Error loading learning game state: $e');
    }
  }

  // 儲存狀態
  Future<void> _saveState() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('learning_level', _level);
      await prefs.setInt('learning_experience', _experience);
      await prefs.setInt('learning_translator_count', _translatorUsageCount);
      await prefs.setStringList(
          'learning_completed_steps', _completedSteps.toList());
      await prefs.setStringList(
          'learning_unlocked_badges', _unlockedBadges.toList());
      await prefs.setString(
          'learning_incorrect_questions', jsonEncode(_incorrectQuestions));
      await prefs.setString(
          'learning_saved_evidences', jsonEncode(_savedEvidenceLists));
      await prefs.setString(
          'learning_quiz_history', jsonEncode(_quizHistory));

      // 儲存連擊與封面狀態
      await prefs.setInt('learning_study_streak', _studyStreak);
      await prefs.setString('learning_last_study_date', _lastStudyDate);
      await prefs.setString('learning_last_daily_quiz_date', _lastDailyQuizDate);
      await prefs.setInt('learning_daily_quiz_correct_count', _dailyQuizCorrectCount);
      await prefs.setString('learning_cover_color_hex', _coverColorHex);
      await prefs.setStringList('learning_unlocked_stickers', _unlockedStickers.toList());
      await prefs.setString('learning_placed_stickers', jsonEncode(_placedStickers));

      // 儲存筆記與收藏
      await prefs.setStringList('learning_saved_articles', _savedArticles.toList());
      await prefs.setString('learning_saved_quotes', jsonEncode(_savedQuotes));
      await prefs.setString('learning_saved_highlights', jsonEncode(_savedHighlights));
      await prefs.setStringList('learning_viewed_categories', _viewedCategories.toList());
      await prefs.setString('learning_article_notes', jsonEncode(_articleNotes));

      // 儲存外觀與三段論
      await prefs.setBool('learning_use_handwritten_font', _useHandwrittenFont);
      await prefs.setString('learning_notebook_paper_style', _notebookPaperStyle);
      await prefs.setString('learning_cornell_notes', jsonEncode(_cornellNotes));
    } catch (e) {
      debugPrint('Error saving learning game state: $e');
    }
  }

  // 增加經驗值
  void addExperience(int amount) {
    if (amount <= 0) return;

    // 台灣繁體中文教學註解：
    // 10 階是目前成長系統的天花板；達到最高階後經驗條固定顯示滿格，
    // 避免舊資料或大量加分把玩家推到未設計的 Level 11 之後。
    if (_level >= totalLevels) {
      _level = totalLevels;
      _experience = nextLevelXp;
      _saveState();
      notifyListeners();
      return;
    }

    _experience += amount;
    while (_experience >= nextLevelXp && _level < totalLevels) {
      _experience = _experience - nextLevelXp;
      _level++;
    }

    if (_level >= totalLevels) {
      _level = totalLevels;
      _experience = nextLevelXp;
    }
    _saveState();
    notifyListeners();
  }

  // 完成課程單元
  void completeStep(String stepId) {
    if (!_completedSteps.contains(stepId)) {
      _completedSteps.add(stepId);
      addExperience(20); // 每個單元給 20 XP

      // 檢查是否通關租屋糾紛所有 STEP (除 STEP 5 Quiz 之外為 1~4)
      final rentSteps = {
        '租屋糾紛_STEP 1',
        '租屋糾紛_STEP 2',
        '租屋糾紛_STEP 3',
        '租屋糾紛_STEP 4',
      };
      if (_completedSteps.containsAll(rentSteps)) {
        unlockBadge('租屋達人');
      }

      _saveState();
      notifyListeners();
    }
  }

  // 解鎖徽章
  void unlockBadge(String badgeName) {
    if (!_unlockedBadges.contains(badgeName)) {
      _unlockedBadges.add(badgeName);
      _saveState();
      notifyListeners();
    }
  }

  // 增加翻譯機使用次數
  void incrementTranslatorUsage() {
    _translatorUsageCount++;
    if (_translatorUsageCount >= 3) {
      unlockBadge('翻譯大師');
    }
    _saveState();
  }

  // 新增錯題
  // 新增錯題
  void addIncorrectQuestion(String question, String wrongAnswer,
      String correctAnswer, String explanation, [List<String>? options]) {
    // 避免重複加入同一個問題
    _incorrectQuestions.removeWhere((item) => item['question'] == question);
    _incorrectQuestions.add({
      'question': question,
      'wrongAnswer': wrongAnswer,
      'correctAnswer': correctAnswer,
      'explanation': explanation,
      'options': options ?? [wrongAnswer, correctAnswer],
      'timestamp': DateTime.now().toIso8601String(),
    });
    _saveState();
    notifyListeners();
  }

  // 完成每日隨堂考與簽到
  void completeDailyQuiz(bool isCorrect) {
    final todayStr = DateTime.now().toIso8601String().substring(0, 10);
    if (_lastDailyQuizDate == todayStr) return; // 本日已回答過

    _lastDailyQuizDate = todayStr;

    // 計算 Streak
    if (_lastStudyDate.isNotEmpty) {
      try {
        final lastDate = DateTime.parse(_lastStudyDate);
        final today = DateTime.parse(todayStr);
        final diff = today.difference(lastDate).inDays;
        
        if (diff == 1) {
          _studyStreak++;
        } else if (diff > 1) {
          _studyStreak = 1;
        }
      } catch (e) {
        _studyStreak = 1;
      }
    } else {
      _studyStreak = 1;
    }
    _lastStudyDate = todayStr;

    // 給予答題獎勵與經驗值
    addExperience(20);
    if (isCorrect) {
      addExperience(10); // 答對額外獎勵
      _dailyQuizCorrectCount++;
    }

    // 檢查 Streak 獎勵與解鎖
    if (_studyStreak >= 3) {
      unlockSticker('trophy'); // 簽到滿 3 天解鎖獎盃貼紙
    }
    if (_studyStreak >= 7) {
      unlockBadge('持久修煉者');
      unlockSticker('star'); // 簽到滿 7 天解鎖星星貼紙
    }

    _saveState();
    notifyListeners();
  }

  // 解鎖貼紙
  void unlockSticker(String stickerId) {
    if (!_unlockedStickers.contains(stickerId)) {
      _unlockedStickers.add(stickerId);
      _saveState();
      notifyListeners();
    }
  }

  // 保存筆記本封面自訂狀態
  void saveNotebookCover(String colorHex, List<Map<String, dynamic>> placedStickers) {
    _coverColorHex = colorHex;
    _placedStickers = placedStickers;
    _saveState();
    notifyListeners();
  }

  // 移出錯題（重新挑戰答對後）
  void removeIncorrectQuestion(String question) {
    _incorrectQuestions.removeWhere((item) => item['question'] == question);
    addExperience(15); // 重新挑戰答對加 15 XP
    _saveState();
    notifyListeners();
  }

  // 紀錄答題歷史
  void recordQuizHistory({
    required String question,
    required List<String> options,
    required String selectedAnswer,
    required String correctAnswer,
    required bool isCorrect,
    required String category,
    required String stepLabel,
    required String explanation,
  }) {
    // 避免重複加入同一個問題，若有則移除舊紀錄
    _quizHistory.removeWhere((item) => item['question'] == question);
    _quizHistory.insert(0, {
      'question': question,
      'options': options,
      'selectedAnswer': selectedAnswer,
      'correctAnswer': correctAnswer,
      'isCorrect': isCorrect,
      'category': category,
      'stepLabel': stepLabel,
      'explanation': explanation,
      'timestamp': DateTime.now().toIso8601String(),
    });
    // 限制最多保存 50 筆紀錄
    if (_quizHistory.length > 50) {
      _quizHistory.removeLast();
    }
    _saveState();
    notifyListeners();
  }

  // 儲存證據清單
  void saveEvidenceList(
      String title, List<String> checkedItems, List<String> allItems) {
    _savedEvidenceLists.add({
      'title': title,
      'checkedItems': checkedItems,
      'allItems': allItems,
      'timestamp': DateTime.now().toIso8601String(),
    });
    unlockBadge('備忘行家');
    _saveState();
    notifyListeners();
  }

  // 刪除儲存的證據清單
  void deleteEvidenceList(int index) {
    if (index >= 0 && index < _savedEvidenceLists.length) {
      _savedEvidenceLists.removeAt(index);
      _saveState();
      notifyListeners();
    }
  }

  // === 筆記與收藏管理方法 ===

  // 1) 單元整體收藏
  bool isArticleSaved(String title) => _savedArticles.contains(title);

  void toggleArticleSave(String title) {
    if (_savedArticles.contains(title)) {
      _savedArticles.remove(title);
    } else {
      _savedArticles.add(title);
    }
    _saveState();
    notifyListeners();
  }

  // 2) 思考金句收藏
  bool isQuoteSaved(String quote) {
    return _savedQuotes.any((item) => item['quote'] == quote);
  }

  void toggleQuoteSave(String quote, String articleTitle) {
    final exists = _savedQuotes.any((item) => item['quote'] == quote);
    if (exists) {
      _savedQuotes.removeWhere((item) => item['quote'] == quote);
    } else {
      _savedQuotes.add({
        'quote': quote,
        'articleTitle': articleTitle,
        'timestamp': DateTime.now().toIso8601String(),
      });
      unlockBadge('備忘行家'); // 使用收藏可解鎖備忘行家
    }
    _saveState();
    notifyListeners();
  }

  // 3) 螢光筆劃記重點
  void addHighlight(String text, String articleTitle) {
    if (text.trim().isEmpty) return;
    // 避免重複劃記一模一樣的句子
    final exists = _savedHighlights.any((item) => item['highlight'] == text && item['articleTitle'] == articleTitle);
    if (!exists) {
      _savedHighlights.add({
        'highlight': text,
        'articleTitle': articleTitle,
        'timestamp': DateTime.now().toIso8601String(),
        'note': '',
        'highlightColor': 'yellow',
        'stickerId': null,
      });
      _saveState();
      notifyListeners();
    }
  }

  void removeHighlight(int index) {
    if (index >= 0 && index < _savedHighlights.length) {
      _savedHighlights.removeAt(index);
      _saveState();
      notifyListeners();
    }
  }

  // 4) 標記看過的議題/分類
  void markCategoryViewed(String category) {
    if (category.trim().isEmpty) return;
    if (!_viewedCategories.contains(category)) {
      _viewedCategories.add(category);
      _saveState();
      WidgetsBinding.instance.addPostFrameCallback((_) {
        notifyListeners();
      });
    }
  }

  // 5) 筆記本外觀設定與三段論功能方法
  void setUseHandwrittenFont(bool value) {
    if (_useHandwrittenFont != value) {
      _useHandwrittenFont = value;
      _saveState();
      notifyListeners();
    }
  }

  void setNotebookPaperStyle(String value) {
    if (_notebookPaperStyle != value) {
      _notebookPaperStyle = value;
      _saveState();
      notifyListeners();
    }
  }

  void addCornellNote(String title, String premise, String fact, String conclusion) {
    _cornellNotes.insert(0, {
      'id': DateTime.now().millisecondsSinceEpoch.toString(),
      'title': title,
      'premise': premise,
      'fact': fact,
      'conclusion': conclusion,
      'date': DateTime.now().toIso8601String().substring(0, 10),
      'stickerId': null,
    });
    unlockSticker('scale'); // 製作三段論筆記解鎖天平貼紙
    _saveState();
    notifyListeners();
  }

  void removeCornellNote(String id) {
    _cornellNotes.removeWhere((item) => item['id'] == id);
    _saveState();
    notifyListeners();
  }

  void updateCornellSticker(String id, String? stickerId) {
    final idx = _cornellNotes.indexWhere((item) => item['id'] == id);
    if (idx != -1) {
      _cornellNotes[idx]['stickerId'] = stickerId;
      _saveState();
      notifyListeners();
    }
  }

  void updateHighlightNote(int index, String note) {
    if (index >= 0 && index < _savedHighlights.length) {
      _savedHighlights[index]['note'] = note;
      _saveState();
      notifyListeners();
    }
  }

  void updateHighlightColor(int index, String colorName) {
    if (index >= 0 && index < _savedHighlights.length) {
      _savedHighlights[index]['highlightColor'] = colorName;
      _saveState();
      notifyListeners();
    }
  }

  void updateHighlightSticker(int index, String? stickerId) {
    if (index >= 0 && index < _savedHighlights.length) {
      _savedHighlights[index]['stickerId'] = stickerId;
      _saveState();
      notifyListeners();
    }
  }
}
