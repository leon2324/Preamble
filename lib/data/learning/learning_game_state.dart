import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

/// 小法助成長檔案與成就系統的狀態管理
class LearningGameState extends ChangeNotifier {
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

  int get level => _level;
  int get experience => _experience;
  Set<String> get completedSteps => _completedSteps;
  List<Map<String, dynamic>> get incorrectQuestions => _incorrectQuestions;
  List<Map<String, dynamic>> get savedEvidenceLists => _savedEvidenceLists;
  Set<String> get unlockedBadges => _unlockedBadges;

  // 經驗值升級閥值
  int get nextLevelXp => 100;

  // 取得當前表情與稱號
  String get mascotExpression {
    if (_level >= 3) return '🎓'; // Level 3: 金牌大法官
    if (_level == 2) return '🧐'; // Level 2: 實習法官助理
    return '😮'; // Level 1: 法學見習生
  }

  String get levelTitle {
    if (_level >= 3) return '金牌大法官';
    if (_level == 2) return '實習法官助理';
    return '法學見習生';
  }

  // 載入狀態
  Future<void> _loadState() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _level = prefs.getInt('learning_level') ?? 1;
      _experience = prefs.getInt('learning_experience') ?? 10;
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
        _incorrectQuestions = List<Map<String, dynamic>>.from(jsonDecode(incorrectRaw));
      }

      final evidenceRaw = prefs.getString('learning_saved_evidences');
      if (evidenceRaw != null) {
        _savedEvidenceLists = List<Map<String, dynamic>>.from(jsonDecode(evidenceRaw));
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
      await prefs.setStringList('learning_completed_steps', _completedSteps.toList());
      await prefs.setStringList('learning_unlocked_badges', _unlockedBadges.toList());
      await prefs.setString('learning_incorrect_questions', jsonEncode(_incorrectQuestions));
      await prefs.setString('learning_saved_evidences', jsonEncode(_savedEvidenceLists));
    } catch (e) {
      debugPrint('Error saving learning game state: $e');
    }
  }

  // 增加經驗值
  void addExperience(int amount) {
    _experience += amount;
    if (_experience >= nextLevelXp) {
      _experience = _experience - nextLevelXp;
      _level++;
      // 解鎖稱號對應的徽章
      if (_level == 2) {
        unlockBadge('實習法助');
      } else if (_level >= 3) {
        unlockBadge('金牌大法官');
      }
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
      final rentSteps = {'STEP 1', 'STEP 2', 'STEP 3', 'STEP 4'};
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
  void addIncorrectQuestion(String question, String wrongAnswer, String correctAnswer, String explanation) {
    // 避免重複加入同一個問題
    _incorrectQuestions.removeWhere((item) => item['question'] == question);
    _incorrectQuestions.add({
      'question': question,
      'wrongAnswer': wrongAnswer,
      'correctAnswer': correctAnswer,
      'explanation': explanation,
      'timestamp': DateTime.now().toIso8601String(),
    });
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

  // 儲存證據清單
  void saveEvidenceList(String title, List<String> checkedItems, List<String> allItems) {
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
}
