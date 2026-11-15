import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:preamble/app/app_state.dart';
import 'package:preamble/app/build_info.dart';
import 'package:preamble/components/navigation/app_shell_content_insets.dart';
import 'package:preamble/components/shared/custom_toast.dart';
import 'package:preamble/components/subscription/morandi_paywall_sheet.dart';
import 'package:preamble/pages/profile/apple_ecosystem_demo_page.dart';
import 'package:preamble/pages/profile/widgets/profile_editor.dart';
import 'package:preamble/pages/profile/widgets/profile_widgets.dart';
import 'package:preamble/theme/adaptive_layout.dart';
import 'package:preamble/theme/preamble_tokens.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({
    super.key,
    this.showBackButton = true,
    this.buildInfoProvider = const PackageBuildInfoProvider(),
  });

  /// 個人頁同時會出現在底部導覽列（傳入 `showBackButton: false`），
  /// 也可能被首頁或其他入口以新路由 push 開啟（預設 `true`）。
  final bool showBackButton;
  final BuildInfoProvider buildInfoProvider;

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  BuildInfo? _buildInfo;

  @override
  void initState() {
    super.initState();
    _loadBuildInfo();
  }

  @override
  void didUpdateWidget(covariant ProfilePage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.buildInfoProvider != widget.buildInfoProvider) {
      _loadBuildInfo();
    }
  }

  Future<void> _loadBuildInfo() async {
    final buildInfo = await widget.buildInfoProvider.load().catchError(
          (_) => BuildInfo.unknown(),
        );
    if (!mounted) return;
    setState(() => _buildInfo = buildInfo);
  }

  @override
  Widget build(BuildContext context) {
    final appState = PreambleScope.of(context);
    final topPadding =
        context.hasLargeTopInset ? context.topSafeInset + 10.h : 22.h;

    return AnimatedBuilder(
      animation: Listenable.merge([appState, appState.subscriptionService]),
      builder: (context, _) {
        final t = context.tokens;
        final metrics = ProfileSyncedMetrics.fromState(appState);
        final isPro = appState.subscriptionService.isProOrHigher;
        final expiryDateStr = appState.subscriptionService.status.expiryDate
            ?.toString()
            .split(' ')
            .first;

        return Scaffold(
          backgroundColor: t.canvas,
          body: ListView(
            physics: const BouncingScrollPhysics(),
            padding: EdgeInsets.fromLTRB(
              16.w,
              topPadding,
              16.w,
              context.pageContentBottomPadding +
                  32.h +
                  AppShellContentInsets.additionalBottomOf(context),
            ),
            children: [
              if (widget.showBackButton && Navigator.of(context).canPop())
                _BackButton(onBack: () => Navigator.of(context).maybePop()),

              // 頂部會員名片與即時同步數據快覽橫條
              Container(
                padding: EdgeInsets.fromLTRB(18.w, 24.h, 18.w, 18.h),
                decoration: t.cardDecoration(radius: 24.r),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    GestureDetector(
                      onTap: () => _showProfileEditorSheet(context, appState),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          AvatarWidget(
                            avatarUrl: appState.currentUser.avatarUrl,
                            isSubscriber: appState.isSubscriber || isPro,
                            isGuest: appState.isGuest,
                            size: 86,
                          ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: Container(
                              padding: EdgeInsets.all(5.w),
                              decoration: BoxDecoration(
                                color: t.brandPrimaryStrong,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: t.surface,
                                  width: 1.8.w,
                                ),
                              ),
                              child: Icon(
                                PhosphorIconsFill.pencilSimple,
                                color: const Color(0xFFFAF8F4),
                                size: 12.5.sp,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 14.h),
                    Text(
                      appState.isGuest
                          ? '訪客個人中心'
                          : appState.currentUser.displayName,
                      style: t.serifTitle(size: 20.sp),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      appState.isGuest
                          ? '點擊頭像設定個人稱謂與身分偏好'
                          : appState.currentUser.email,
                      style: t.sansBody(
                        size: 12.sp,
                        color: t.textSecondary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    if (!appState.isGuest) ...[
                      SizedBox(height: 8.h),
                      _buildProfessionBadge(
                        context,
                        appState.currentUser.profession,
                      ),
                    ],
                    SizedBox(height: 12.h),

                    // 方案與今日 AI 額度膠囊（點擊開啟訂閱方案底頁）
                    Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () => MorandiPaywallSheet.show(context),
                        borderRadius: BorderRadius.circular(99.r),
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 14.w,
                            vertical: 6.5.h,
                          ),
                          decoration: BoxDecoration(
                            color: isPro
                                ? t.accentBrassContainer
                                : t.brandContainer,
                            borderRadius: BorderRadius.circular(99.r),
                            border: Border.all(
                              color: isPro
                                  ? t.accentBrass.withValues(alpha: 0.65)
                                  : t.brandPrimary.withValues(alpha: 0.25),
                            ),
                          ),
                          child: Wrap(
                            alignment: WrapAlignment.center,
                            crossAxisAlignment: WrapCrossAlignment.center,
                            spacing: 5.w,
                            runSpacing: 2.h,
                            children: [
                              Icon(
                                isPro
                                    ? PhosphorIconsFill.crown
                                    : PhosphorIconsRegular.sparkle,
                                size: 14.sp,
                                color: isPro
                                    ? t.accentBrass
                                    : t.brandPrimary,
                              ),
                              Text(
                                isPro
                                    ? '${appState.subscriptionService.status.tierDisplayName} ｜ 無限次 AI'
                                    : '免費用戶 ｜ 今日 AI 額度：${appState.subscriptionService.remainingAiQuota}',
                                style: t.sansBody(
                                  size: 11.5.sp,
                                  weight: FontWeight.w700,
                                  color: isPro
                                      ? t.accentOnBrassContainer
                                      : t.brandPrimary,
                                ),
                              ),
                              if (!isPro)
                                Text(
                                  '升級',
                                  style: t.sansBody(
                                    size: 11.sp,
                                    weight: FontWeight.w800,
                                    color: t.accentOnBrassContainer,
                                  ).copyWith(
                                    decoration: TextDecoration.underline,
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    SizedBox(height: 16.h),

                    // 100% 即時同步三欄統計橫條（收藏案卷・法規 / 追蹤動態 / 隨手筆記）
                    ProfileQuickStatsStrip(metrics: metrics),
                  ],
                ),
              ),

              SizedBox(height: 14.h),

              // 靜奢深松墨綠 × 古銅金 PRO 會員尊榮橫幅卡片
              ProUpgradeBanner(
                isPro: isPro,
                expiryText: expiryDateStr != null
                    ? '有效期限至 $expiryDateStr ｜ 享無限次 AI 問診與無浮水印匯出'
                    : '自動續訂中 ｜ 享無限次 AI 問診、客製公文與無浮水印 PDF',
                onTap: () => MorandiPaywallSheet.show(context),
              ),

              SizedBox(height: 20.h),

              // 主要資料儀表板
              const _SectionTitle('我的資料'),
              SizedBox(height: 10.h),
              DashboardGrid(appState: appState),
              SizedBox(height: 10.h),
              LearningProgressBanner(appState: appState),

              SizedBox(height: 22.h),

              // 個人化與設定（修復深色模式黑底黑圖示與本機資料說明誤用紅色刪除圖示問題）
              GroupedSettingsList(
                title: '個人化與設定',
                tiles: [
                  SettingsTile(
                    icon: PhosphorIconsRegular.moonStars,
                    iconColor: t.brandPrimary,
                    iconBgColor: t.brandContainer,
                    title: '深色模式',
                    subtitle: '夜間查閱法規或閱讀案卷時切換靜奢深色介面',
                    trailing: Switch.adaptive(
                      value: appState.isDarkMode,
                      onChanged: appState.setDarkMode,
                      activeThumbColor: t.brandPrimary,
                    ),
                  ),
                  SettingsTile(
                    icon: PhosphorIconsRegular.textAa,
                    iconColor: t.brandPrimary,
                    iconBgColor: t.brandContainer,
                    title: '閱讀字型大小',
                    subtitle:
                        '調整 App 內法條與內文字級比例（目前 ${(appState.fontSizeScale * 100).round()}%）',
                    onTap: () => _showFontSizeDialog(context, appState),
                  ),
                  SettingsTile(
                    icon: PhosphorIconsRegular.bellRinging,
                    iconColor: t.accentOnBrassContainer,
                    iconBgColor: t.accentBrassContainer,
                    title: '提醒偏好',
                    subtitle: '管理修法異動、追蹤案卷與系統提醒摘要',
                    onTap: () =>
                        _showNotificationSettingsSheet(context, appState),
                  ),
                  SettingsTile(
                    icon: PhosphorIconsRegular.slidersHorizontal,
                    iconColor: t.semanticInfo,
                    iconBgColor: t.semanticInfoContainer,
                    title: '自訂導覽與介面',
                    subtitle: '調整底部導覽列順序、標籤開關與主題點綴色',
                    onTap: () =>
                        _showInterfaceSettingsSheet(context, appState),
                  ),
                  SettingsTile(
                    icon: PhosphorIconsRegular.shieldCheck,
                    iconColor: t.semanticSuccess,
                    iconBgColor: t.semanticSuccessContainer,
                    title: '資料與隱私安全',
                    subtitle: '了解本機資料保護、帳號與敏感資訊規範',
                    onTap: () => _showAccountSecurityInfo(context),
                  ),
                  SettingsTile(
                    icon: PhosphorIconsRegular.hardDrive,
                    iconColor: t.semanticInfo,
                    iconBgColor: t.semanticInfoContainer,
                    title: '本機資料說明',
                    subtitle: '了解收藏、法務筆記與書狀草稿的儲存方式',
                    onTap: () => _showLocalStorageInfo(context),
                  ),
                ],
              ),

              SizedBox(height: 18.h),

              // 支援、條款與系統整合（將 iOS 生態系展示移至此處作為次要實驗室入口）
              GroupedSettingsList(
                title: '支援與系統資訊',
                tiles: [
                  SettingsTile(
                    icon: PhosphorIconsRegular.chatCenteredText,
                    iconColor: t.brandPrimary,
                    iconBgColor: t.brandContainer,
                    title: '問題回報與建議',
                    subtitle: '向團隊回報系統異常或提出體驗改善建議',
                    onTap: () => _showFeedbackSheet(context, appState),
                  ),
                  SettingsTile(
                    icon: PhosphorIconsRegular.books,
                    iconColor: t.semanticInfo,
                    iconBgColor: t.semanticInfoContainer,
                    title: '資料來源說明',
                    subtitle: '檢視公開裁判書、全國法規資料庫與更新範圍',
                    onTap: () => _showSourcesSheet(context),
                  ),
                  SettingsTile(
                    icon: PhosphorIconsRegular.lockKey,
                    iconColor: t.semanticSuccess,
                    iconBgColor: t.semanticSuccessContainer,
                    title: '隱私權政策',
                    subtitle: '詳閱本機優先儲存原則與個人資料保護政策',
                    onTap: () => LegalTermsSheet.show(
                      context,
                      kind: LegalTermsKind.privacy,
                    ),
                  ),
                  SettingsTile(
                    icon: PhosphorIconsRegular.scroll,
                    iconColor: t.accentOnBrassContainer,
                    iconBgColor: t.accentBrassContainer,
                    title: '服務條款 (EULA)',
                    subtitle: '詳閱使用者授權合約、訂閱自動續訂與取消說明',
                    onTap: () => LegalTermsSheet.show(
                      context,
                      kind: LegalTermsKind.eula,
                    ),
                  ),
                  SettingsTile(
                    icon: PhosphorIconsRegular.scales,
                    iconColor: t.accentOnBrassContainer,
                    iconBgColor: t.accentBrassContainer,
                    title: '法律免責聲明',
                    subtitle: '檢視 AI 非正式法律意見與責任限制說明',
                    onTap: () => _showDisclaimerSheet(context),
                  ),
                  SettingsTile(
                    icon: PhosphorIconsRegular.deviceMobile,
                    iconColor: t.textSecondary,
                    iconBgColor: t.surfaceSubtle,
                    title: '系統整合與實驗室',
                    subtitle: 'iOS 小工具與捷徑展示',
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => const AppleEcosystemDemoPage(),
                      ),
                    ),
                  ),
                  SettingsTile(
                    icon: PhosphorIconsRegular.info,
                    iconColor: t.textSecondary,
                    iconBgColor: t.surfaceSubtle,
                    title: '版本資訊',
                    trailing: Flexible(
                      fit: FlexFit.loose,
                      child: Align(
                        alignment: Alignment.centerRight,
                        child: Text(
                          _buildInfo?.displayLabel ?? '版本資訊讀取中',
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.right,
                          style: t.tabularMetric(
                            size: 12.sp,
                            weight: FontWeight.w600,
                            color: t.textSecondary,
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
      },
    );
  }

  void _showProfileEditorSheet(BuildContext context, PreambleState appState) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (_) => ProfileEditorSheet(appState: appState),
    );
  }

  void _showFeedbackSheet(BuildContext context, PreambleState appState) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (_) => FeedbackSheet(appState: appState),
    );
  }

  void _showNotificationSettingsSheet(
    BuildContext context,
    PreambleState appState,
  ) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (_) => NotificationSettingsSheet(appState: appState),
    );
  }

  void _showInterfaceSettingsSheet(
    BuildContext context,
    PreambleState appState,
  ) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (_) => InterfaceSettingsSheet(appState: appState),
    );
  }

  void _showDisclaimerSheet(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        final t = sheetContext.tokens;
        return Padding(
          padding: EdgeInsets.all(16.w),
          child: Container(
            decoration: BoxDecoration(
              color: t.surfaceElevated,
              borderRadius: BorderRadius.circular(24.r),
              border: Border.all(color: t.border),
            ),
            padding: EdgeInsets.all(20.w),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: EdgeInsets.all(12.w),
                    decoration: BoxDecoration(
                      color: t.accentBrassContainer,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      PhosphorIconsRegular.scales,
                      color: t.accentBrass,
                      size: 28.sp,
                    ),
                  ),
                  SizedBox(height: 12.h),
                  Text(
                    '法律免責聲明',
                    style: t.serifTitle(size: 17.sp),
                  ),
                  SizedBox(height: 10.h),
                  Text(
                    '《緒言 Preamble》提供之裁判案卷整理、法規白話解析、AI 輔助問診與書狀草稿生成功能，僅供法學學習與事前資訊參考，不構成正式法律意見或律師代理。如涉及實際個案權益，請務必諮詢合格執業律師或相關主管機關。',
                    style: t.sansBody(
                      size: 13.5.sp,
                      height: 1.6,
                      color: t.textSecondary,
                    ),
                  ),
                  SizedBox(height: 20.h),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: () => Navigator.pop(sheetContext),
                      style: FilledButton.styleFrom(
                        backgroundColor: t.brandPrimaryStrong,
                        foregroundColor: const Color(0xFFFAF8F4),
                        padding: EdgeInsets.symmetric(vertical: 12.5.h),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14.r),
                        ),
                      ),
                      child: const Text('我已了解'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _showSourcesSheet(BuildContext context) {
    _showInfoDialog(
      context,
      icon: PhosphorIconsRegular.books,
      title: '資料來源說明',
      message:
          '法規內容以全國法規資料庫與政府公開資料為主要查核來源；裁判案卷、專題與生活避坑內容包含《緒言 Preamble》法學編輯團隊整理之結構化摘要。若涉及具體個案時效或最新修法施行日，請以全國法規資料庫與司法院最新公告文本為準。',
    );
  }

  void _showLocalStorageInfo(BuildContext context) {
    _showInfoDialog(
      context,
      icon: PhosphorIconsRegular.hardDrive,
      title: '本機資料說明',
      message:
          '您的案卷收藏、法規追蹤、法務筆記、閱讀字級偏好與文件草稿均優先保存在此裝置本機儲存空間。更換裝置、移除 App 或重置系統前，請自行匯出或備份重要草稿內容。本機筆記與草稿不會自動作為正式法律送件。',
    );
  }

  void _showAccountSecurityInfo(BuildContext context) {
    _showInfoDialog(
      context,
      icon: PhosphorIconsRegular.shieldCheck,
      title: '資料與隱私安全',
      message:
          '目前個人稱謂、收藏、筆記與介面偏好均採本機優先（Local-First）安全儲存。為保護當事人隱私，請避免在筆記或問診中輸入真實身分證字號、完整門牌地址、銀行帳號或第三人敏感個資。',
    );
  }

  void _showInfoDialog(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String message,
  }) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        final t = dialogContext.tokens;
        return AlertDialog(
          backgroundColor: t.surfaceElevated,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.r),
            side: BorderSide(color: t.border),
          ),
          title: Row(
            children: [
              Icon(icon, color: t.brandPrimary, size: 20.sp),
              SizedBox(width: 8.w),
              Expanded(
                child: Text(
                  title,
                  style: t.serifTitle(size: 16.5.sp),
                ),
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: Text(
              message,
              style: t.sansBody(
                size: 13.5.sp,
                color: t.textSecondary,
                height: 1.6,
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              style: TextButton.styleFrom(foregroundColor: t.brandPrimary),
              child: Text(
                '知道了',
                style: t.sansTitle(size: 13.5.sp, color: t.brandPrimary),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildProfessionBadge(BuildContext context, String profession) {
    final t = context.tokens;
    String label = '一般民眾';
    IconData icon = PhosphorIconsRegular.user;
    Color fgColor = t.brandPrimary;
    Color bgColor = t.brandContainer;

    if (profession == 'lawyer') {
      label = '執業律師';
      icon = PhosphorIconsRegular.scales;
      fgColor = t.accentOnBrassContainer;
      bgColor = t.accentBrassContainer;
    } else if (profession == 'legal_staff') {
      label = '法務人員';
      icon = PhosphorIconsRegular.briefcase;
      fgColor = t.semanticInfo;
      bgColor = t.semanticInfoContainer;
    } else if (profession == 'law_student') {
      label = '法學生';
      icon = PhosphorIconsRegular.graduationCap;
      fgColor = t.semanticSuccess;
      bgColor = t.semanticSuccessContainer;
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 3.5.h),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(99.r),
        border: Border.all(color: fgColor.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: fgColor, size: 12.5.sp),
          SizedBox(width: 4.w),
          Text(
            label,
            style: t.sansBody(
              size: 11.sp,
              weight: FontWeight.w700,
              color: fgColor,
            ),
          ),
        ],
      ),
    );
  }

  void _showFontSizeDialog(BuildContext context, PreambleState appState) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        final t = dialogContext.tokens;
        final currentScale = appState.fontSizeScale;

        return AlertDialog(
          backgroundColor: t.surfaceElevated,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.r),
            side: BorderSide(color: t.border),
          ),
          title: Text(
            '閱讀字型大小',
            style: t.serifTitle(size: 17.sp),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildFontSizeOption(
                  dialogContext,
                  appState,
                  label: '精巧 (85%)',
                  scale: 0.85,
                  current: currentScale,
                ),
                _buildFontSizeOption(
                  dialogContext,
                  appState,
                  label: '標準適中 (100%)',
                  scale: 1.0,
                  current: currentScale,
                ),
                _buildFontSizeOption(
                  dialogContext,
                  appState,
                  label: '舒適大字 (115%)',
                  scale: 1.15,
                  current: currentScale,
                ),
                _buildFontSizeOption(
                  dialogContext,
                  appState,
                  label: '特大清晰 (130%)',
                  scale: 1.30,
                  current: currentScale,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text(
                '關閉',
                style: t.sansTitle(size: 13.5.sp, color: t.textSecondary),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildFontSizeOption(
    BuildContext dialogContext,
    PreambleState appState, {
    required String label,
    required double scale,
    required double current,
  }) {
    final t = dialogContext.tokens;
    final isSelected = (current - scale).abs() < 0.01;
    return ListTile(
      contentPadding: EdgeInsets.symmetric(horizontal: 4.w),
      title: Text(
        label,
        style: t.sansBody(
          size: (13.5 * scale).sp,
          weight: isSelected ? FontWeight.w700 : FontWeight.w500,
          color: t.textPrimary,
        ),
      ),
      trailing: Icon(
        isSelected
            ? PhosphorIconsFill.checkCircle
            : PhosphorIconsRegular.circle,
        color: isSelected ? t.brandPrimary : t.textMuted,
        size: 20.sp,
      ),
      onTap: () {
        appState.updateSettings(fontSizeScale: scale);
        Navigator.pop(dialogContext);
        CustomToast.show(
          context,
          '閱讀字型大小已更新',
          icon: PhosphorIconsRegular.checkCircle,
        );
      },
    );
  }
}

class _BackButton extends StatelessWidget {
  const _BackButton({required this.onBack});

  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: EdgeInsets.only(bottom: 6.h),
        child: IconButton(
          onPressed: onBack,
          tooltip: '返回',
          icon: Icon(
            PhosphorIconsRegular.caretLeft,
            color: t.textPrimary,
            size: 22.sp,
          ),
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.title);
  final String title;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    return Padding(
      padding: EdgeInsets.only(left: 4.w),
      child: Text(
        title,
        style: t.serifTitle(size: 16.5.sp),
      ),
    );
  }
}
