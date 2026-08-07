import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:preamble/utils/auth_interceptor.dart';
import 'package:preamble/utils/bookmark_manager.dart';
import 'package:preamble/utils/quota_manager.dart';

void main() {
  group('Phase 9 AuthInterceptor Tests', () {
    test('successfully retries after 401', () async {
      int requestCount = 0;
      
      final result = await AuthInterceptor.instance.sendRequest(
        endpoint: '/test',
        requestAction: (token) async {
          requestCount++;
          if (token == 'access_token_v1' && requestCount == 1) {
            throw AuthException('Expired', 401);
          }
          return {'status': 'success', 'token_used': token};
        },
      );

      expect(requestCount, 2);
      expect(result['status'], 'success');
      expect(result['token_used'], startsWith('access_token_v2_'));
    });
  });

  group('Phase 9 QuotaManager Tests', () {
    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      await QuotaManager.instance.init(prefs);
      QuotaManager.instance.testForceSetDateAndQuota('2026-08-01', 0);
    });

    test('consumes quota until limit', () {
      expect(QuotaManager.instance.remainingQuota, 5);
      
      for (int i = 0; i < 5; i++) {
        QuotaManager.instance.consumeQuota();
      }
      
      expect(QuotaManager.instance.remainingQuota, 0);
      
      expect(
        () => QuotaManager.instance.consumeQuota(),
        throwsA(isA<QuotaExceededException>()),
      );
    });

    test('resets quota on a new day', () {
      QuotaManager.instance.testForceSetDateAndQuota('2020-01-01', 5);
      expect(QuotaManager.instance.remainingQuota, 5); // Should reset to 5 because today > 2020-01-01
    });
  });

  group('Phase 9 BookmarkManager Tests', () {
    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      await BookmarkManager.instance.init(prefs);
      BookmarkManager.instance.clear();
    });

    test('toggles bookmarks correctly', () {
      expect(BookmarkManager.instance.bookmarks, isEmpty);

      BookmarkManager.instance.toggleBookmark('civil_184', '民法第 184 條');
      expect(BookmarkManager.instance.bookmarks.length, 1);
      expect(BookmarkManager.instance.isBookmarked('civil_184'), isTrue);

      BookmarkManager.instance.toggleBookmark('civil_184', '民法第 184 條');
      expect(BookmarkManager.instance.bookmarks, isEmpty);
      expect(BookmarkManager.instance.isBookmarked('civil_184'), isFalse);
    });
  });
}
