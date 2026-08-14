import 'dart:convert';

/// 會員方案層級
enum SubscriptionTier {
  free,
  pro,
  business,
}

/// 訂閱計費週期
enum SubscriptionBillingCycle {
  monthly,
  annual,
}

/// 訂閱方案實體
class SubscriptionPlan {
  const SubscriptionPlan({
    required this.id,
    required this.tier,
    required this.billingCycle,
    required this.title,
    required this.priceLabel,
    required this.originalPriceLabel,
    required this.periodLabel,
    required this.badge,
    required this.features,
    this.isPopular = false,
  });

  final String id;
  final SubscriptionTier tier;
  final SubscriptionBillingCycle billingCycle;
  final String title;
  final String priceLabel;
  final String originalPriceLabel;
  final String periodLabel;
  final String badge;
  final List<String> features;
  final bool isPopular;

  static const List<SubscriptionPlan> availablePlans = [
    SubscriptionPlan(
      id: 'preamble_pro_monthly',
      tier: SubscriptionTier.pro,
      billingCycle: SubscriptionBillingCycle.monthly,
      title: '專業版 (月繳)',
      priceLabel: 'NT\$ 199',
      originalPriceLabel: 'NT\$ 299',
      periodLabel: '/ 月',
      badge: '熱門推薦',
      features: [
        '無限次 AI 法律小法助深度問診',
        '100% 動態客製化法律書狀大腦生成',
        '正式郵局三聯公文與高畫質 PDF 匯出',
        '去除全部系統浮水印與專屬官方用印',
        '離線隱私加密儲存與草稿備份',
      ],
      isPopular: true,
    ),
    SubscriptionPlan(
      id: 'preamble_pro_annual',
      tier: SubscriptionTier.pro,
      billingCycle: SubscriptionBillingCycle.annual,
      title: '專業版 (年繳特惠)',
      priceLabel: 'NT\$ 1,790',
      originalPriceLabel: 'NT\$ 2,388',
      periodLabel: '/ 年 (相當於 NT\$ 149/月)',
      badge: '現省 25%',
      features: [
        '包含專業版所有每月無限權益',
        '享 7 天尊榮免費試用，滿意再付費',
        '全年無限次動態書狀生成與匯出',
        '專屬優先法律知識庫與新功能搶先用',
      ],
      isPopular: true,
    ),
    SubscriptionPlan(
      id: 'preamble_business_monthly',
      tier: SubscriptionTier.business,
      billingCycle: SubscriptionBillingCycle.monthly,
      title: '企業商務版',
      priceLabel: 'NT\$ 599',
      originalPriceLabel: 'NT\$ 899',
      periodLabel: '/ 月',
      badge: '公司 / 創業者首選',
      features: [
        '包含專業版所有權益',
        '商業合夥、股權、外包 NDA 專屬高階條款',
        '官方合作執業律師快速審閱通道',
        '多人協作與雲端存根存證管理',
      ],
    ),
  ];
}

/// 用戶當前訂閱狀態
class UserSubscriptionStatus {
  const UserSubscriptionStatus({
    required this.tier,
    this.expiryDate,
    this.isAutoRenewing = false,
    this.planId,
    this.dailyAiConsultationCount = 0,
    this.lastConsultationDate,
  });

  final SubscriptionTier tier;
  final DateTime? expiryDate;
  final bool isAutoRenewing;
  final String? planId;
  final int dailyAiConsultationCount;
  final DateTime? lastConsultationDate;

  bool get isPro => tier == SubscriptionTier.pro;
  bool get isBusiness => tier == SubscriptionTier.business;
  bool get isProOrHigher =>
      tier == SubscriptionTier.pro || tier == SubscriptionTier.business;

  /// 免費用戶每日上限 3 次，Pro/Business 無限次
  int get remainingAiQuota {
    if (isProOrHigher) return 999;
    final now = DateTime.now();
    if (lastConsultationDate == null ||
        lastConsultationDate!.day != now.day ||
        lastConsultationDate!.month != now.month ||
        lastConsultationDate!.year != now.year) {
      return 3;
    }
    return (3 - dailyAiConsultationCount).clamp(0, 3);
  }

  bool get canUseAiAssistant => isProOrHigher || remainingAiQuota > 0;
  bool get canExportUnwatermarkedPdf => isProOrHigher;
  bool get canUseAdvancedBrain => isProOrHigher;

  String get tierDisplayName => switch (tier) {
        SubscriptionTier.free => '一般會員 (Free)',
        SubscriptionTier.pro => 'PRO 專業會員',
        SubscriptionTier.business => 'BUSINESS 企業會員',
      };

  Map<String, dynamic> toJson() => {
        'tier': tier.name,
        'expiryDate': expiryDate?.toIso8601String(),
        'isAutoRenewing': isAutoRenewing,
        'planId': planId,
        'dailyAiConsultationCount': dailyAiConsultationCount,
        'lastConsultationDate': lastConsultationDate?.toIso8601String(),
      };

  factory UserSubscriptionStatus.fromJson(Map<String, dynamic> json) {
    return UserSubscriptionStatus(
      tier: SubscriptionTier.values.firstWhere(
        (t) => t.name == json['tier'],
        orElse: () => SubscriptionTier.free,
      ),
      expiryDate: json['expiryDate'] != null
          ? DateTime.tryParse(json['expiryDate'] as String)
          : null,
      isAutoRenewing: json['isAutoRenewing'] == true,
      planId: json['planId'] as String?,
      dailyAiConsultationCount:
          (json['dailyAiConsultationCount'] as int?) ?? 0,
      lastConsultationDate: json['lastConsultationDate'] != null
          ? DateTime.tryParse(json['lastConsultationDate'] as String)
          : null,
    );
  }

  UserSubscriptionStatus copyWith({
    SubscriptionTier? tier,
    DateTime? expiryDate,
    bool? isAutoRenewing,
    String? planId,
    int? dailyAiConsultationCount,
    DateTime? lastConsultationDate,
  }) {
    return UserSubscriptionStatus(
      tier: tier ?? this.tier,
      expiryDate: expiryDate ?? this.expiryDate,
      isAutoRenewing: isAutoRenewing ?? this.isAutoRenewing,
      planId: planId ?? this.planId,
      dailyAiConsultationCount:
          dailyAiConsultationCount ?? this.dailyAiConsultationCount,
      lastConsultationDate: lastConsultationDate ?? this.lastConsultationDate,
    );
  }
}
