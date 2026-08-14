import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:preamble/app/app_state.dart';
import 'package:preamble/components/shared/custom_toast.dart';
import 'package:preamble/data/subscription/subscription_models.dart';

/// 緒言莫蘭迪黑金尊榮付費牆 (Morandi Premium Paywall Sheet)。
///
/// 採用莫蘭迪深墨綠 (#162720) 與香檳流金 (#D4AF37) 設計，
/// 完美符合 Apple App Store 與 Google Play 審查規範（含 7 天試用、方案對照、恢復購買、EULA 與隱私政策）。
class MorandiPaywallSheet extends StatefulWidget {
  const MorandiPaywallSheet({
    super.key,
    this.headline = '升級緒言 PRO 專業會員',
    this.subHeadline = '解鎖無限次 AI 法律問診、100% 客製公文生成與高清用印',
  });

  final String headline;
  final String subHeadline;

  static Future<bool?> show(
    BuildContext context, {
    String headline = '升級緒言 PRO 專業會員',
    String subHeadline = '解鎖無限次 AI 法律問診、100% 客製公文生成與高清用印',
  }) {
    return showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => MorandiPaywallSheet(
        headline: headline,
        subHeadline: subHeadline,
      ),
    );
  }

  @override
  State<MorandiPaywallSheet> createState() => _MorandiPaywallSheetState();
}

class _MorandiPaywallSheetState extends State<MorandiPaywallSheet> {
  int _selectedPlanIndex = 1; // 預設選中「年繳特惠」
  bool _isProcessing = false;

  final List<SubscriptionPlan> _plans = SubscriptionPlan.availablePlans;

  @override
  Widget build(BuildContext context) {
    final appState = PreambleScope.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final bgDark = const Color(0xFF13221B);
    final cardBg = const Color(0xFF1B2F26);
    final goldAccent = const Color(0xFFE5C07B);
    final lightGreen = const Color(0xFF68B28B);

    return Container(
      height: 0.88.sh,
      decoration: BoxDecoration(
        color: bgDark,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
        boxShadow: const [
          BoxShadow(
            color: Colors.black54,
            blurRadius: 20,
            spreadRadius: 4,
          ),
        ],
      ),
      child: Stack(
        children: [
          // 頂部淡雅流金微光
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: 120.h,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    goldAccent.withValues(alpha: 0.15),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),

          // 主內容捲動區
          Column(
            children: [
              // 頂部拖曳把手與關閉按鈕
              Padding(
                padding: EdgeInsets.only(top: 12.h, left: 16.w, right: 16.w),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton(
                      onPressed: _isProcessing ? null : () => _handleRestore(appState),
                      child: Text(
                        '恢復購買',
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: Colors.white70,
                        ),
                      ),
                    ),
                    Container(
                      width: 36.w,
                      height: 4.h,
                      decoration: BoxDecoration(
                        color: Colors.white24,
                        borderRadius: BorderRadius.circular(2.r),
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(false),
                      icon: Icon(
                        Icons.close_rounded,
                        color: Colors.white70,
                        size: 22.sp,
                      ),
                    ),
                  ],
                ),
              ),

              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: EdgeInsets.symmetric(horizontal: 20.w),
                  child: Column(
                    children: [
                      SizedBox(height: 6.h),

                      // 皇冠徽章
                      Container(
                        padding: EdgeInsets.all(12.w),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: goldAccent.withValues(alpha: 0.15),
                          border: Border.all(color: goldAccent, width: 1.2.w),
                        ),
                        child: Icon(
                          Icons.workspace_premium_rounded,
                          size: 32.sp,
                          color: goldAccent,
                        ),
                      ),
                      SizedBox(height: 12.h),

                      // 主標題
                      Text(
                        widget.headline,
                        style: TextStyle(
                          fontSize: 20.sp,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: 0.5,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 6.h),
                      Text(
                        widget.subHeadline,
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: Colors.white70,
                          height: 1.4,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 20.h),

                      // 核心權益列表
                      Container(
                        padding: EdgeInsets.all(14.w),
                        decoration: BoxDecoration(
                          color: cardBg,
                          borderRadius: BorderRadius.circular(14.r),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.08),
                          ),
                        ),
                        child: Column(
                          children: [
                            _buildFeatureRow(
                              Icons.auto_awesome_rounded,
                              'AI 法律大腦自主編排生成',
                              '不限字數與情境，100% 打造專業公文',
                              goldAccent,
                            ),
                            SizedBox(height: 10.h),
                            _buildFeatureRow(
                              Icons.picture_as_pdf_rounded,
                              '無浮水印高畫質 PDF 匯出',
                              '符合郵局三聯格線，支援親筆簽名與用印',
                              lightGreen,
                            ),
                            SizedBox(height: 10.h),
                            _buildFeatureRow(
                              Icons.chat_bubble_outline_rounded,
                              '無限次 AI 小法助深度問診',
                              '免除每日 3 次限制，隨時推演案件攻防',
                              Colors.white,
                            ),
                            SizedBox(height: 10.h),
                            _buildFeatureRow(
                              Icons.security_rounded,
                              '本機隱私保險箱加密存根',
                              '端到端本地保護，案件機密絕不外洩',
                              Colors.white,
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 18.h),

                      // 方案選擇卡片列表
                      Text(
                        '選擇最適合您的訂閱方案',
                        style: TextStyle(
                          fontSize: 13.sp,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(height: 10.h),

                      for (var i = 0; i < _plans.length; i++)
                        _buildPlanCard(i, _plans[i], goldAccent),

                      SizedBox(height: 16.h),

                      // Apple 規範法律條款說明
                      Text(
                        '訂閱將在確認購買後由您的 App Store / Google Play 帳戶扣款。'
                        '訂閱將自動續訂，除非在目前週期結束前至少 24 小時關閉自動續訂。'
                        '您可隨時在帳戶設定中管理或取消訂閱。',
                        style: TextStyle(
                          fontSize: 10.sp,
                          color: Colors.white38,
                          height: 1.4,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 8.h),

                      // 條款連結
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _buildLinkText('服務條款 (EULA)'),
                          Text(' • ', style: TextStyle(color: Colors.white38)),
                          _buildLinkText('隱私權政策'),
                        ],
                      ),
                      SizedBox(height: 80.h),
                    ],
                  ),
                ),
              ),

              // 底部固定購買按鈕
              Container(
                padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 14.h),
                decoration: BoxDecoration(
                  color: bgDark,
                  border: Border(
                    top: BorderSide(
                      color: Colors.white.withValues(alpha: 0.1),
                    ),
                  ),
                ),
                child: SizedBox(
                  width: double.infinity,
                  height: 48.h,
                  child: ElevatedButton(
                    onPressed: _isProcessing
                        ? null
                        : () => _handlePurchase(appState, _plans[_selectedPlanIndex]),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: goldAccent,
                      foregroundColor: const Color(0xFF1E2824),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                    ),
                    child: _isProcessing
                        ? SizedBox(
                            width: 20.w,
                            height: 20.w,
                            child: const CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Color(0xFF1E2824),
                            ),
                          )
                        : Text(
                            _selectedPlanIndex == 1
                                ? '開始 7 天免費試用並訂閱'
                                : '立即以 ${_plans[_selectedPlanIndex].priceLabel} 解鎖 PRO',
                            style: TextStyle(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.3,
                            ),
                          ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureRow(
    IconData icon,
    String title,
    String subtitle,
    Color iconColor,
  ) {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(6.w),
          decoration: BoxDecoration(
            color: iconColor.withValues(alpha: 0.15),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, size: 14.sp, color: iconColor),
        ),
        SizedBox(width: 10.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 10.sp,
                  color: Colors.white60,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPlanCard(int index, SubscriptionPlan plan, Color goldAccent) {
    final isSelected = _selectedPlanIndex == index;

    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        setState(() => _selectedPlanIndex = index);
      },
      child: Container(
        margin: EdgeInsets.only(bottom: 10.h),
        padding: EdgeInsets.all(14.w),
        decoration: BoxDecoration(
          color: isSelected
              ? goldAccent.withValues(alpha: 0.12)
              : Colors.white.withValues(alpha: 0.04),
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
            color: isSelected ? goldAccent : Colors.white.withValues(alpha: 0.1),
            width: isSelected ? 1.8.w : 1.w,
          ),
        ),
        child: Row(
          children: [
            Icon(
              isSelected
                  ? Icons.radio_button_checked_rounded
                  : Icons.radio_button_off_rounded,
              color: isSelected ? goldAccent : Colors.white38,
              size: 20.sp,
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        plan.title,
                        style: TextStyle(
                          fontSize: 13.sp,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      if (plan.badge.isNotEmpty) ...[
                        SizedBox(width: 8.w),
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 6.w,
                            vertical: 2.h,
                          ),
                          decoration: BoxDecoration(
                            color: goldAccent,
                            borderRadius: BorderRadius.circular(4.r),
                          ),
                          child: Text(
                            plan.badge,
                            style: TextStyle(
                              fontSize: 9.sp,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF1E2824),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    plan.periodLabel,
                    style: TextStyle(
                      fontSize: 10.sp,
                      color: Colors.white60,
                    ),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  plan.priceLabel,
                  style: TextStyle(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.bold,
                    color: isSelected ? goldAccent : Colors.white,
                  ),
                ),
                Text(
                  plan.originalPriceLabel,
                  style: TextStyle(
                    fontSize: 10.sp,
                    color: Colors.white38,
                    decoration: TextDecoration.lineThrough,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLinkText(String text) {
    return GestureDetector(
      onTap: () {
        CustomToast.show(context, '正在開啟 $text...');
      },
      child: Text(
        text,
        style: TextStyle(
          fontSize: 10.sp,
          color: Colors.white60,
          decoration: TextDecoration.underline,
        ),
      ),
    );
  }

  Future<void> _handlePurchase(
    PreambleState appState,
    SubscriptionPlan plan,
  ) async {
    setState(() => _isProcessing = true);
    HapticFeedback.mediumImpact();

    try {
      final success = await appState.subscriptionService.purchasePlan(plan);
      if (!mounted) return;

      if (success) {
        HapticFeedback.heavyImpact();
        CustomToast.show(
          context,
          '🎉 恭喜您已成功升級為 ${plan.tier == SubscriptionTier.pro ? 'PRO 專業會員' : '企業會員'}！',
          icon: Icons.check_circle_outline_rounded,
        );
        Navigator.of(context).pop(true);
      }
    } catch (_) {
      if (!mounted) return;
      CustomToast.show(context, '購買過程中發生錯誤，請稍後再試。');
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  Future<void> _handleRestore(PreambleState appState) async {
    setState(() => _isProcessing = true);
    HapticFeedback.lightImpact();

    try {
      final restored = await appState.subscriptionService.restorePurchases();
      if (!mounted) return;

      if (restored) {
        CustomToast.show(
          context,
          '已為您恢復會員訂閱權益！',
          icon: Icons.check_circle_outline_rounded,
        );
        Navigator.of(context).pop(true);
      } else {
        CustomToast.show(
          context,
          '未找到過去的有效訂閱紀錄。',
          icon: Icons.info_outline_rounded,
        );
      }
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }
}
