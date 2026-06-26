import 'dart:math';
import 'package:lawapp/data/mock_data/learning/daily_quiz_questions.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Daily Rotation Topic ID Determinism Tests', () {
    List<int> getDailyTopicIdsForDate(DateTime date) {
      final seed = date.year * 10000 + date.month * 100 + date.day;
      final rand = Random(seed);

      final List<int> selectedTopicIds = [];
      while (selectedTopicIds.length < 5) {
        final id = rand.nextInt(1000) + 1;
        if (!selectedTopicIds.contains(id)) {
          selectedTopicIds.add(id);
        }
      }
      return selectedTopicIds;
    }

    test('Should return identical topic IDs for the same date', () {
      final date = DateTime(2026, 6, 14);
      final list1 = getDailyTopicIdsForDate(date);
      final list2 = getDailyTopicIdsForDate(date);

      expect(list1, equals(list2));
      expect(list1.length, equals(5));

      // All IDs must be unique
      expect(list1.toSet().length, equals(5));
    });

    test('Should return different topic IDs for different dates', () {
      final date1 = DateTime(2026, 6, 14);
      final date2 = DateTime(2026, 6, 15);

      final list1 = getDailyTopicIdsForDate(date1);
      final list2 = getDailyTopicIdsForDate(date2);

      expect(list1, isNot(equals(list2)));
    });

    test('All IDs must be within the range [1, 1000]', () {
      for (int i = 1; i <= 365; i++) {
        final date = DateTime(2026, 1, i);
        final list = getDailyTopicIdsForDate(date);
        for (final id in list) {
          expect(id, greaterThanOrEqualTo(1));
          expect(id, lessThanOrEqualTo(1000));
        }
      }
    });
  });

  group('Daily Quiz Question Bank Tests', () {
    test('Should contain exactly 50 daily check-in questions', () {
      expect(dailyQuizQuestions.length, equals(50));
    });

    test('Every daily check-in question should have valid options and answer',
        () {
      for (final question in dailyQuizQuestions) {
        expect(question.question.trim(), isNotEmpty);
        expect(question.options.length, equals(3));
        expect(question.correctIndex, inInclusiveRange(0, 2));
        expect(question.options[question.correctIndex].trim(), isNotEmpty);
        expect(question.explanation.trim(), isNotEmpty);
      }
    });

    test('Date rotation should reach questions beyond the first 31 days', () {
      // 每日簽到題庫擴充到 50 題後，測試需守住「第 32 題以後也會出題」，
      // 避免未來有人改回 DateTime.day 造成每月只輪替前 31 題。
      final firstFortyDays = List.generate(
        40,
        (index) => DateTime(2026, 1, 1).add(Duration(days: index)),
      );

      final usedIndexes =
          firstFortyDays.map(dailyQuizQuestionIndexForDate).toSet();

      expect(usedIndexes, containsAll(List.generate(40, (index) => index)));
    });
  });
}
