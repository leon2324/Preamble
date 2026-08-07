import 'package:flutter_test/flutter_test.dart';
import 'package:preamble/utils/idempotency_manager.dart';
import 'package:preamble/utils/offline_request_queue.dart';

void main() {
  group('Phase 8 IdempotencyManager Tests', () {
    setUp(() {
      IdempotencyManager.instance.clear();
    });

    test('generates unique UUID keys', () {
      final key1 = IdempotencyManager.instance.generateKey();
      final key2 = IdempotencyManager.instance.generateKey();
      expect(key1, isNotEmpty);
      expect(key1, isNot(equals(key2)));
    });

    test('blocks duplicate keys', () {
      final key = IdempotencyManager.instance.generateKey();
      
      // First use should be true
      expect(IdempotencyManager.instance.markAsUsed(key), isTrue);
      
      // Second use should be false
      expect(IdempotencyManager.instance.markAsUsed(key), isFalse);
    });
  });

  group('Phase 8 OfflineRequestQueue Tests', () {
    setUp(() {
      OfflineRequestQueue.instance.clear();
    });

    test('enqueue increases queue length', () {
      expect(OfflineRequestQueue.instance.length, 0);
      
      OfflineRequestQueue.instance.enqueue(
        endpoint: '/test',
        payload: {'data': 'value'},
      );
      
      expect(OfflineRequestQueue.instance.length, 1);
    });

    test('sync processes items and removes successful ones', () async {
      OfflineRequestQueue.instance.enqueue(
        endpoint: '/test1',
        payload: {'id': 1},
      );
      OfflineRequestQueue.instance.enqueue(
        endpoint: '/test2',
        payload: {'id': 2},
      );

      expect(OfflineRequestQueue.instance.length, 2);

      int processedCount = 0;
      await OfflineRequestQueue.instance.sync((request) async {
        processedCount++;
        // return true to indicate success
        return true;
      });

      expect(processedCount, 2);
      expect(OfflineRequestQueue.instance.length, 0);
    });

    test('sync keeps failed items for retry', () async {
      OfflineRequestQueue.instance.enqueue(
        endpoint: '/test1',
        payload: {'id': 1},
      );

      await OfflineRequestQueue.instance.sync((request) async {
        // return false to indicate failure
        return false;
      });

      // Item should still be in queue for retry
      expect(OfflineRequestQueue.instance.length, 1);
    });
  });
}
