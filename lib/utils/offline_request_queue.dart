import 'dart:async';
import 'package:flutter/foundation.dart';

/// 離線請求模型
class OfflineRequest {
  const OfflineRequest({
    required this.id,
    required this.endpoint,
    required this.payload,
    required this.createdAt,
    this.retryCount = 0,
  });

  final String id;
  final String endpoint;
  final Map<String, dynamic> payload;
  final DateTime createdAt;
  final int retryCount;

  OfflineRequest copyWith({
    int? retryCount,
  }) {
    return OfflineRequest(
      id: id,
      endpoint: endpoint,
      payload: payload,
      createdAt: createdAt,
      retryCount: retryCount ?? this.retryCount,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'endpoint': endpoint,
        'payload': payload,
        'createdAt': createdAt.toIso8601String(),
        'retryCount': retryCount,
      };

  factory OfflineRequest.fromJson(Map<String, dynamic> json) => OfflineRequest(
        id: json['id'] as String,
        endpoint: json['endpoint'] as String,
        payload: json['payload'] as Map<String, dynamic>,
        createdAt: DateTime.parse(json['createdAt'] as String),
        retryCount: json['retryCount'] as int? ?? 0,
      );
}

/// 離線佇列管理員 (MVP 實作以記憶體為基礎)
/// 負責在網路斷線時暫存使用者的變更行為。
class OfflineRequestQueue {
  OfflineRequestQueue._privateConstructor();
  static final OfflineRequestQueue instance = OfflineRequestQueue._privateConstructor();

  final List<OfflineRequest> _queue = [];
  bool _isSyncing = false;

  /// 加入佇列
  void enqueue({
    required String endpoint,
    required Map<String, dynamic> payload,
  }) {
    final request = OfflineRequest(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      endpoint: endpoint,
      payload: payload,
      createdAt: DateTime.now(),
    );
    _queue.add(request);
    debugPrint('OfflineRequestQueue: Enqueued request for $endpoint. Queue size: ${_queue.length}');
  }

  /// 取得當前佇列長度
  int get length => _queue.length;

  /// 清空佇列
  void clear() {
    _queue.clear();
  }

  /// 執行同步 (需傳入負責實際打 API 的處理常式)
  Future<void> sync(Future<bool> Function(OfflineRequest) handler) async {
    if (_isSyncing || _queue.isEmpty) return;
    _isSyncing = true;
    debugPrint('OfflineRequestQueue: Starting sync for ${_queue.length} items...');

    final List<OfflineRequest> failedRequests = [];

    while (_queue.isNotEmpty) {
      final request = _queue.removeAt(0);
      try {
        final success = await handler(request);
        if (!success) {
          // 如果失敗，增加 retryCount 並放回 pending (如果還不到上限)
          if (request.retryCount < 3) {
            failedRequests.add(request.copyWith(retryCount: request.retryCount + 1));
          } else {
            debugPrint('OfflineRequestQueue: Dropped request ${request.id} after 3 retries.');
          }
        }
      } catch (e) {
        debugPrint('OfflineRequestQueue: Error syncing request ${request.id}: $e');
        if (request.retryCount < 3) {
          failedRequests.add(request.copyWith(retryCount: request.retryCount + 1));
        }
      }
    }

    // 將失敗的塞回佇列等待下次 sync
    _queue.addAll(failedRequests);
    _isSyncing = false;
    debugPrint('OfflineRequestQueue: Sync finished. Remaining items: ${_queue.length}');
  }
}
