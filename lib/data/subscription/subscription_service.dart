import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:preamble/data/subscription/subscription_models.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// 緒言商業訂閱與會員權益管理服務。
///
/// 負責管理使用者當前會員等級、持久化儲存、消耗/計算每日 AI 諮詢次數，
/// 並支援跨平台 In-App Purchase 購買與 Apple 審查強制要求的「恢復購買 (Restore)」功能。
class SubscriptionService extends ChangeNotifier {
  SubscriptionService({SharedPreferences? prefs}) : _prefs = prefs {
    _init();
  }

  SharedPreferences? _prefs;
  static const String _storageKey = 'preamble_user_subscription_status';

  UserSubscriptionStatus _status = const UserSubscriptionStatus(
    tier: SubscriptionTier.free,
  );

  UserSubscriptionStatus get status => _status;
  bool get isProOrHigher => _status.isProOrHigher;
  int get remainingAiQuota => _status.remainingAiQuota;

  Future<void> _init() async {
    _prefs ??= await SharedPreferences.getInstance();
    final jsonStr = _prefs!.getString(_storageKey);
    if (jsonStr != null && jsonStr.isNotEmpty) {
      try {
        final map = jsonDecode(jsonStr) as Map<String, dynamic>;
        _status = UserSubscriptionStatus.fromJson(map);
        _checkExpiry();
      } catch (_) {
        _status = const UserSubscriptionStatus(tier: SubscriptionTier.free);
      }
    }
    notifyListeners();
  }

  /// 檢查訂閱是否過期
  void _checkExpiry() {
    if (_status.tier != SubscriptionTier.free && _status.expiryDate != null) {
      if (DateTime.now().isAfter(_status.expiryDate!)) {
        // 訂閱已過期，降級為免費版
        _status = _status.copyWith(
          tier: SubscriptionTier.free,
          isAutoRenewing: false,
        );
        _save();
      }
    }
  }

  /// 記錄一次 AI 諮詢消耗
  Future<bool> consumeAiQuota() async {
    if (_status.isProOrHigher) return true;

    final now = DateTime.now();
    int currentCount = _status.dailyAiConsultationCount;

    // 檢查是否換天
    if (_status.lastConsultationDate == null ||
        _status.lastConsultationDate!.day != now.day ||
        _status.lastConsultationDate!.month != now.month ||
        _status.lastConsultationDate!.year != now.year) {
      currentCount = 0;
    }

    if (currentCount >= 3) {
      return false; // 超出配額
    }

    _status = _status.copyWith(
      dailyAiConsultationCount: currentCount + 1,
      lastConsultationDate: now,
    );

    await _save();
    notifyListeners();
    return true;
  }

  /// 購買方案（在 Sandbox / Demo 模式下即時升級並持久化）
  Future<bool> purchasePlan(SubscriptionPlan plan) async {
    // 模擬網絡延遲與 IAP 驗證
    await Future.delayed(const Duration(milliseconds: 600));

    final now = DateTime.now();
    final expiry = plan.billingCycle == SubscriptionBillingCycle.annual
        ? now.add(const Duration(days: 365))
        : now.add(const Duration(days: 30));

    _status = _status.copyWith(
      tier: plan.tier,
      expiryDate: expiry,
      isAutoRenewing: true,
      planId: plan.id,
    );

    await _save();
    notifyListeners();
    return true;
  }

  /// 恢復購買 (Restore Purchases) —— Apple App Store 必備規範
  Future<bool> restorePurchases() async {
    await Future.delayed(const Duration(milliseconds: 700));

    // 檢查是否有儲存紀錄
    if (_prefs != null) {
      final jsonStr = _prefs!.getString(_storageKey);
      if (jsonStr != null && jsonStr.isNotEmpty) {
        final map = jsonDecode(jsonStr) as Map<String, dynamic>;
        final restored = UserSubscriptionStatus.fromJson(map);
        if (restored.isProOrHigher) {
          _status = restored;
          notifyListeners();
          return true;
        }
      }
    }
    return false;
  }

  /// 取消訂閱 / 降級為免費用戶
  Future<void> cancelSubscription() async {
    _status = _status.copyWith(
      isAutoRenewing: false,
    );
    await _save();
    notifyListeners();
  }

  /// 重設為完全免費用戶（測試用）
  Future<void> resetToFree() async {
    _status = const UserSubscriptionStatus(tier: SubscriptionTier.free);
    await _save();
    notifyListeners();
  }

  Future<void> _save() async {
    _prefs ??= await SharedPreferences.getInstance();
    await _prefs!.setString(_storageKey, jsonEncode(_status.toJson()));
  }
}
