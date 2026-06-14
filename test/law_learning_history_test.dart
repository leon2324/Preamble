import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:lawapp/data/learning/learning_game_state.dart';

void main() {
  test('LearningGameState records and retrieves quiz history correctly', () async {
    SharedPreferences.setMockInitialValues({});
    
    final gameState = LearningGameState.instance;
    
    // 初始歷史紀錄應為空
    expect(gameState.quizHistory, isEmpty);
    
    // 記錄一個答對的測驗
    gameState.recordQuizHistory(
      question: '租賃契約中，押金的上限是幾個月租金？',
      options: ['一個月', '兩個月', '三個月'],
      selectedAnswer: '兩個月',
      correctAnswer: '兩個月',
      isCorrect: true,
      category: '租屋糾紛',
      stepLabel: 'STEP 5',
      explanation: '根據土地法第99條規定，擔保金（押金）不得超過兩個月房屋租金之總額。',
    );
    
    // 驗證紀錄是否成功
    expect(gameState.quizHistory, hasLength(1));
    expect(gameState.quizHistory.first['question'], '租賃契約中，押金的上限是幾個月租金？');
    expect(gameState.quizHistory.first['isCorrect'], isTrue);
    expect(gameState.quizHistory.first['category'], '租屋糾紛');
    expect(gameState.quizHistory.first['stepLabel'], 'STEP 5');
    
    // 記錄另一個答錯的測驗
    gameState.recordQuizHistory(
      question: '發生車禍後，應於幾日內向警察機關申請閱覽道路交通事故分析研判表？',
      options: ['10日', '15日', '30日'],
      selectedAnswer: '15日',
      correctAnswer: '30日',
      isCorrect: false,
      category: '車禍事故',
      stepLabel: '專題測驗',
      explanation: '依道路交通事故處理辦法，當事人得於事故30日後申請提供道路交通事故初步分析研判表。',
    );
    
    // 驗證順序與資料（最新一筆應在最前）
    expect(gameState.quizHistory, hasLength(2));
    expect(gameState.quizHistory.first['category'], '車禍事故');
    expect(gameState.quizHistory.first['isCorrect'], isFalse);
    expect(gameState.quizHistory[1]['category'], '租屋糾紛');
  });
}
