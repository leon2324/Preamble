import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:preamble/app/app_state.dart';
import 'package:preamble/components/shared/custom_toast.dart';
import 'package:preamble/components/subscription/legal_terms_sheet.dart';
import 'package:preamble/theme/preamble_tokens.dart';

export 'legal_terms_sheet.dart';

/// 《緒言 Preamble》靜奢深松綠 × 典藏古銅金尊榮付費牆 (MorandiPaywallSheet)。
///
/// 全面採用 `context.tokens` 支援淺深色模式，並符合 Apple App Store 與 Google Play 審查規範：
/// - 清楚呈現計費週期、7 天免費試用與方案對照
/// - 支援「恢復購買」
/// - 點擊「服務條款 (EULA)」與「隱私權政策」開啟完整條文閱讀底頁（非暫態提示）
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
      useSafeArea: true,
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
  int _selectedPlanIndex = 1; // 預設選中「專業版 (年繳特惠)」
  bool _isProcessing = false;

  final List<SubscriptionPlan> _plans = SubscriptionPlan.availablePlans;

  @override
  Widget build(BuildContext context) {
    final appState = PreambleScope.of(context);
    final t = context.tokens;

    return ConstrainedBox(
      constraints: BoxConstraints(maxHeight: 0.90.sh),
      child: Container(
        decoration: BoxDecoration(
          color: t.surfaceElevated,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
          border: Border.all(color: t.border),
          boxShadow: [
            BoxShadow(
              color: t.shadowAmbient,
              blurRadius: 24,
              offset: const Offset(0, -6),
            ),
          ],
        ),
        child: Stack(
          children: [
            // 頂部典藏古銅金 × 深松墨綠柔和環境光暈
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              height: 132.h,
              child: IgnorePointer(
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius:
                        BorderRadius.vertical(top: Radius.circular(24.r)),
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        t.accentBrass.withValues(alpha: t.isDark ? 0.16 : 0.12),
                        t.surfaceElevated.withValues(alpha: 0),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            SafeArea(
              top: false,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // 頂部恢復購買、拖曳把手與關閉鍵（小螢幕與 200% 字級零溢位保護）
                  Padding(
                    padding:
                        EdgeInsets.only(top: 10.h, left: 12.w, right: 10.w),
                    child: Row(
                      children: [
                        Flexible(
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: TextButton(
                              onPressed: _isProcessing
                                  ? null
                                  : () => _handleRestore(appState),
                              style: TextButton.styleFrom(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 8.w,
                                  vertical: 6.h,
                                ),
                                minimumSize: Size.zero,
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              ),
                              child: Text(
                                '恢復購買',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: t.sansBody(
                                  size: 12.5.sp,
                                  weight: FontWeight.w600,
                                  color: t.textSecondary,
                                ),
                              ),
                            ),
                          ),
                        ),
                        Container(
                          width: 38.w,
                          height: 4.h,
                          margin: EdgeInsets.symmetric(horizontal: 8.w),
                          decoration: BoxDecoration(
                            color: t.borderStrong,
                            borderRadius: BorderRadius.circular(99.r),
                          ),
                        ),
                        Expanded(
                          child: Align(
                            alignment: Alignment.centerRight,
                            child: IconButton(
                              onPressed: () => Navigator.of(context).pop(false),
                              tooltip: '關閉',
                              icon: Icon(
                                PhosphorIconsRegular.x,
                                color: t.textSecondary,
                                size: 20.sp,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  Flexible(
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      padding: EdgeInsets.symmetric(horizontal: 20.w),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          SizedBox(height: 4.h),

                          // 深松墨綠 × 古銅金 PRO 尊榮徽章
                          Center(
                            child: Container(
                              width: 58.w,
                              height: 58.w,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: t.brandPrimaryStrong,
                                border: Border.all(
                                  color: t.accentBrass,
                                  width: 1.5,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color:
                                        t.accentBrass.withValues(alpha: 0.22),
                                    blurRadius: 16,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Icon(
                                PhosphorIconsFill.crown,
                                size: 28.sp,
                                color: t.accentBrass,
                              ),
                            ),
                          ),
                          SizedBox(height: 12.h),

                          Text(
                            widget.headline,
                            style: t.serifTitle(size: 20.sp),
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(height: 6.h),
                          Text(
                            widget.subHeadline,
                            style: t.sansBody(
                              size: 12.5.sp,
                              color: t.textSecondary,
                              height: 1.48,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(height: 18.h),

                          // 核心權益列表卡片
                          Container(
                            padding: EdgeInsets.all(16.w),
                            decoration: t.cardDecoration(radius: 20.r),
                            child: Column(
                              children: [
                                _buildFeatureRow(
                                  context,
                                  icon: PhosphorIconsRegular.sparkle,
                                  title: 'AI 法律大腦自主編排生成',
                                  subtitle: '依個案事實客製化草擬催告函、協商書與聲明書',
                                  accentColor: t.accentBrass,
                                  badgeBg: t.accentBrassContainer,
                                ),
                                SizedBox(height: 12.h),
                                _buildFeatureRow(
                                  context,
                                  icon: PhosphorIconsRegular.filePdf,
                                  title: '無浮水印高畫質 PDF 匯出',
                                  subtitle: '對齊標準存證信函三聯格線，支援簽章與列印',
                                  accentColor: t.semanticSuccess,
                                  badgeBg: t.semanticSuccessContainer,
                                ),
                                SizedBox(height: 12.h),
                                _buildFeatureRow(
                                  context,
                                  icon: PhosphorIconsRegular.scales,
                                  title: '無限次 AI 法律問診推演',
                                  subtitle: '解除每日免費額度上限，隨時拆解爭點與時效',
                                  accentColor: t.brandPrimary,
                                  badgeBg: t.brandContainer,
                                ),
                                SizedBox(height: 12.h),
                                _buildFeatureRow(
                                  context,
                                  icon: PhosphorIconsRegular.shieldCheck,
                                  title: '本機隱私保險箱優先存根',
                                  subtitle: '收藏、法務筆記與書狀草稿安全保存於個人裝置',
                                  accentColor: t.semanticInfo,
                                  badgeBg: t.semanticInfoContainer,
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: 20.h),

                          Text(
                            '選擇最適合您的訂閱方案',
                            style: t.serifTitle(size: 15.sp),
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(height: 12.h),

                          for (var i = 0; i < _plans.length; i++)
                            _buildPlanCard(context, i, _plans[i]),

                          SizedBox(height: 14.h),

                          // App Store / Google Play 自動續訂法定揭露文字
                          Text(
                            '訂閱將在確認購買後由您的 App Store 或 Google Play 帳戶扣款。'
                            '訂閱採自動續訂制，除非在當期結束前至少 24 小時關閉自動續訂。'
                            '您可隨時於系統帳戶設定中管理或取消訂閱。',
                            style: t.sansBody(
                              size: 11.sp,
                              color: t.textMuted,
                              height: 1.5,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(height: 10.h),

                          // 條款連結（使用 Wrap 防止 320pt × 200% 字級橫向溢位）
                          Wrap(
                            alignment: WrapAlignment.center,
                            crossAxisAlignment: WrapCrossAlignment.center,
                            spacing: 8.w,
                            runSpacing: 6.h,
                            children: [
                              _buildLegalLinkButton(
                                context,
                                label: '服務條款 (EULA)',
                                kind: LegalTermsKind.eula,
                              ),
                              Text(
                                '•',
                                style: t.sansBody(
                                  size: 11.sp,
                                  color: t.textMuted,
                                ),
                              ),
                              _buildLegalLinkButton(
                                context,
                                label: '隱私權政策',
                                kind: LegalTermsKind.privacy,
                              ),
                            ],
                          ),
                          SizedBox(height: 20.h),
                        ],
                      ),
                    ),
                  ),

                  // 底部固定購買行動列
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 20.w,
                      vertical: 14.h,
                    ),
                    decoration: BoxDecoration(
                      color: t.surfaceElevated,
                      border: Border(top: BorderSide(color: t.border)),
                    ),
                    child: SizedBox(
                      width: double.infinity,
                      child: ConstrainedBox(
                        constraints: BoxConstraints(minHeight: 48.h),
                        child: FilledButton(
                          onPressed: _isProcessing
                              ? null
                              : () => _handlePurchase(
                                    appState,
                                    _plans[_selectedPlanIndex],
                                  ),
                          style: FilledButton.styleFrom(
                            backgroundColor: t.brandPrimaryStrong,
                            foregroundColor: const Color(0xFFFAF8F4),
                            elevation: 0,
                            padding: EdgeInsets.symmetric(
                              horizontal: 16.w,
                              vertical: 12.h,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14.r),
                              side: BorderSide(
                                color: t.accentBrass.withValues(alpha: 0.65),
                              ),
                            ),
                          ),
                          child: _isProcessing
                              ? SizedBox(
                                  width: 20.w,
                                  height: 20.w,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: t.accentBrass,
                                  ),
                                )
                              : Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      PhosphorIconsFill.crown,
                                      size: 17.sp,
                                      color: t.accentBrass,
                                    ),
                                    SizedBox(width: 8.w),
                                    Flexible(
                                      child: Text(
                                        _selectedPlanIndex == 1
                                            ? '開始 7 天免費試用並訂閱'
                                            : '立即以 ${_plans[_selectedPlanIndex].priceLabel} 解鎖 PRO',
                                        textAlign: TextAlign.center,
                                        style: t.sansTitle(
                                          size: 14.sp,
                                          color: const Color(0xFFFAF8F4),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureRow(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required Color accentColor,
    required Color badgeBg,
  }) {
    final t = context.tokens;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: EdgeInsets.all(8.w),
          decoration: BoxDecoration(
            color: badgeBg,
            borderRadius: BorderRadius.circular(10.r),
          ),
          child: Icon(icon, size: 17.sp, color: accentColor),
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: t.sansTitle(size: 13.5.sp),
              ),
              SizedBox(height: 2.h),
              Text(
                subtitle,
                style: t.sansBody(size: 11.5.sp, color: t.textSecondary),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPlanCard(
    BuildContext context,
    int index,
    SubscriptionPlan plan,
  ) {
    final t = context.tokens;
    final isSelected = _selectedPlanIndex == index;
    final textScale = MediaQuery.textScalerOf(context).scale(1.0);

    return Padding(
      padding: EdgeInsets.only(bottom: 10.h),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            HapticFeedback.selectionClick();
            setState(() => _selectedPlanIndex = index);
          },
          borderRadius: BorderRadius.circular(16.r),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            padding: EdgeInsets.all(14.w),
            decoration: BoxDecoration(
              color: isSelected ? t.accentBrassContainer : t.surface,
              borderRadius: BorderRadius.circular(16.r),
              border: Border.all(
                color: isSelected ? t.accentBrass : t.border,
                width: isSelected ? 1.6 : 1.0,
              ),
            ),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final stackVertically =
                    textScale > 1.45 || constraints.maxWidth < 260;

                final titleBlock = Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Wrap(
                      crossAxisAlignment: WrapCrossAlignment.center,
                      spacing: 6.w,
                      runSpacing: 4.h,
                      children: [
                        Text(
                          plan.title,
                          style: t.sansTitle(
                            size: 14.sp,
                            color: isSelected
                                ? t.accentOnBrassContainer
                                : t.textPrimary,
                          ),
                        ),
                        if (plan.badge.isNotEmpty)
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 7.w,
                              vertical: 2.h,
                            ),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? t.brandPrimaryStrong
                                  : t.surfaceSubtle,
                              borderRadius: BorderRadius.circular(6.r),
                            ),
                            child: Text(
                              plan.badge,
                              style: t.sansBody(
                                size: 10.sp,
                                weight: FontWeight.w700,
                                color: isSelected
                                    ? const Color(0xFFFAF8F4)
                                    : t.textSecondary,
                              ),
                            ),
                          ),
                      ],
                    ),
                    SizedBox(height: 3.h),
                    Text(
                      plan.periodLabel,
                      style: t.sansBody(
                        size: 11.5.sp,
                        color: isSelected
                            ? t.accentOnBrassContainer.withValues(alpha: 0.85)
                            : t.textSecondary,
                      ),
                    ),
                  ],
                );

                final priceBlock = Column(
                  crossAxisAlignment: stackVertically
                      ? CrossAxisAlignment.start
                      : CrossAxisAlignment.end,
                  children: [
                    Text(
                      plan.priceLabel,
                      style: t.tabularMetric(
                        size: 15.5.sp,
                        color: isSelected
                            ? t.accentOnBrassContainer
                            : t.textPrimary,
                      ),
                    ),
                    Text(
                      plan.originalPriceLabel,
                      style: t.tabularMetric(
                        size: 10.5.sp,
                        weight: FontWeight.w500,
                        color: t.textMuted,
                      ).copyWith(decoration: TextDecoration.lineThrough),
                    ),
                  ],
                );

                final radioIcon = Icon(
                  isSelected
                      ? PhosphorIconsFill.checkCircle
                      : PhosphorIconsRegular.circle,
                  color: isSelected ? t.accentBrass : t.textMuted,
                  size: 21.sp,
                );

                if (stackVertically) {
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: EdgeInsets.only(top: 2.h),
                        child: radioIcon,
                      ),
                      SizedBox(width: 10.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            titleBlock,
                            SizedBox(height: 8.h),
                            priceBlock,
                          ],
                        ),
                      ),
                    ],
                  );
                }

                return Row(
                  children: [
                    radioIcon,
                    SizedBox(width: 12.w),
                    Expanded(child: titleBlock),
                    SizedBox(width: 8.w),
                    priceBlock,
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLegalLinkButton(
    BuildContext context, {
    required String label,
    required LegalTermsKind kind,
  }) {
    final t = context.tokens;
    return InkWell(
      onTap: () {
        HapticFeedback.selectionClick();
        LegalTermsSheet.show(context, kind: kind);
      },
      borderRadius: BorderRadius.circular(6.r),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 3.h),
        child: Text(
          label,
          style: t.sansBody(
            size: 11.5.sp,
            weight: FontWeight.w600,
            color: t.brandPrimary,
          ).copyWith(decoration: TextDecoration.underline),
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
          '已成功開通 ${plan.tier == SubscriptionTier.pro ? 'PRO 專業會員' : '企業商務會員'} 權益',
          icon: PhosphorIconsFill.checkCircle,
        );
        Navigator.of(context).pop(true);
      }
    } catch (_) {
      if (!mounted) return;
      CustomToast.show(
        context,
        '購買過程中發生錯誤，請稍後再試。',
        icon: PhosphorIconsRegular.warningCircle,
      );
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
          '已為您恢復會員訂閱權益。',
          icon: PhosphorIconsFill.checkCircle,
        );
        Navigator.of(context).pop(true);
      } else {
        CustomToast.show(
          context,
          '未查詢到過去的有效訂閱紀錄。',
          icon: PhosphorIconsRegular.info,
        );
      }
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }
}
