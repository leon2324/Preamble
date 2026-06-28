import 'package:flutter/material.dart';
import 'package:preamble/components/shared/custom_toast.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:preamble/app/app_state.dart';
import 'package:preamble/theme/adaptive_layout.dart';
import 'package:preamble/theme/app_colors.dart';
import 'package:preamble/pages/profile/widgets/profile_widgets.dart';
import 'package:preamble/pages/profile/widgets/profile_editor.dart';
import 'package:preamble/pages/profile/apple_ecosystem_demo_page.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key, this.showBackButton = false});

  /// 個人頁同時會出現在底部導覽列，也可能被首頁以新路由 push 開啟。
  /// 不能直接用 Navigator.canPop() 判斷是否顯示返回鍵，否則從子功能返回底部 tab 後，
  /// 根 Navigator 仍可能回報可 pop，造成母頁多出返回箭頭並把主畫面 pop 成黑屏。
  final bool showBackButton;

  @override
  Widget build(BuildContext context) {
    final appState = PreambleScope.of(context);
    final topPadding =
        context.hasLargeTopInset ? context.topSafeInset + 10.h : 22.h;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final backgroundColor =
        isDark ? const Color(0xFF0F1216) : AppColors.background;
    final cardColor = isDark ? const Color(0xFF171C22) : Colors.white;
    final borderColor = isDark ? const Color(0xFF2B3441) : AppColors.border;
    final textColor = isDark ? const Color(0xFFF2F4F7) : AppColors.textPrimary;
    final textMutedColor =
        isDark ? const Color(0xFFA3ABB6) : AppColors.textSecondary;

    return Scaffold(
      backgroundColor: backgroundColor,
      body: ListView(
        physics: const BouncingScrollPhysics(),
        padding: EdgeInsets.fromLTRB(
            16.w, topPadding, 16.w, context.pageContentBottomPadding + 32.h),
        children: [
          if (showBackButton)
            _BackButton(onBack: () => Navigator.of(context).pop()),

          // Header: 自訂個人頭像與狀態（大頭像居中排列，偏上方視覺）
          Container(
            padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 24.h),
            decoration: BoxDecoration(
              color: cardColor,
              borderRadius: BorderRadius.circular(24.r),
              border: Border.all(color: borderColor),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x0A000000),
                  blurRadius: 18,
                  offset: Offset(0, 8),
                )
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // 居中大尺寸自訂頭像，點擊開啟編輯器
                GestureDetector(
                  onTap: () => _showProfileEditorSheet(context, appState),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      AvatarWidget(
                        avatarUrl: appState.currentUser.avatarUrl,
                        isSubscriber: appState.isSubscriber,
                        isGuest: appState.isGuest,
                        size: 88, // 放大頭像尺寸
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          padding: EdgeInsets.all(4.w),
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            shape: BoxShape.circle,
                            border: Border.all(color: cardColor, width: 1.5.w),
                          ),
                          child: Icon(
                            Icons.edit_rounded,
                            color: Colors.white,
                            size: 13.sp,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 14.h),

                // 居中使用者名稱
                Text(
                  appState.isGuest
                      ? '訪客個人中心'
                      : appState.currentUser.displayName,
                  style: TextStyle(
                    fontSize: 20.sp,
                    fontWeight: FontWeight.w900,
                    color: textColor,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 4.h),

                // 信箱或提示字
                Text(
                  appState.isGuest ? '點擊頭像編輯資料' : appState.currentUser.email,
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: textMutedColor,
                  ),
                  textAlign: TextAlign.center,
                ),
                if (!appState.isGuest) ...[
                  SizedBox(height: 8.h),
                  // 依據使用者的專業身分顯示金色/金屬感標籤 Badge
                  _buildProfessionBadge(
                      context, appState.currentUser.profession),
                ],
                SizedBox(height: 12.h),

                // 方案與額度膠囊 Badge
                Container(
                  padding:
                      EdgeInsets.symmetric(horizontal: 14.w, vertical: 5.h),
                  decoration: BoxDecoration(
                    color: appState.isSubscriber
                        ? AppColors.accent.withValues(alpha: 0.12)
                        : AppColors.primary.withValues(alpha: 0.06),
                    borderRadius: BorderRadius.circular(100.r),
                    border: Border.all(
                      color: appState.isSubscriber
                          ? AppColors.accent
                          : AppColors.primary.withValues(alpha: 0.15),
                      width: 1.w,
                    ),
                  ),
                  child: Text(
                    '${appState.accessTier.label}方案 ｜ 今日 AI 額度：${appState.remainingAiQuota}',
                    style: TextStyle(
                      fontSize: 11.sp,
                      color: appState.isSubscriber
                          ? AppColors.accent
                          : AppColors.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: 14.h),

          // Dashboard 卡片 Grid (對接統計數據)
          _SectionTitle('我的資料'),
          SizedBox(height: 10.h),
          DashboardGrid(appState: appState),
          SizedBox(height: 10.h),
          // 新增學習歷程與等級橫幅，顯示讀者法律智識等級
          LearningProgressBanner(appState: appState),

          SizedBox(height: 20.h),

          // 設定與個人化 (Grouped List Style)
          GroupedSettingsList(
            title: '個人化與設定',
            tiles: [
              SettingsTile(
                icon: Icons.apple_rounded,
                iconColor: const Color(0xFF0F1216),
                title: ' Apple 系統核心整合',
                subtitle: 'Widgets, Siri 捷徑與 PencilKit 實體功能集',
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const AppleEcosystemDemoPage()),
                ),
              ),
              SettingsTile(
                icon: Icons.dark_mode_rounded,
                iconColor: Colors.purple,
                title: '深色模式',
                subtitle: '夜間查資料或讀案例時降低亮度',
                trailing: Switch.adaptive(
                  value: appState.isDarkMode,
                  onChanged: appState.setDarkMode,
                  activeThumbColor: AppColors.accent,
                ),
              ),
              SettingsTile(
                icon: Icons.format_size_rounded,
                iconColor: Colors.teal,
                title: '閱讀字型大小',
                subtitle: '調整 App 內文字的大小比例',
                onTap: () => _showFontSizeDialog(context, appState),
              ),
              SettingsTile(
                icon: Icons.notifications_active_rounded,
                iconColor: Colors.orange,
                title: '提醒偏好',
                subtitle: '調整 App 內提醒摘要的呈現方式',
                onTap: () => _showNotificationSettingsSheet(context, appState),
              ),
              SettingsTile(
                icon: Icons.security_rounded,
                iconColor: Colors.blueAccent,
                title: '資料與隱私安全',
                subtitle: '了解本機資料、帳號與敏感資訊限制',
                onTap: () => _showAccountSecuritySheet(context),
              ),
              SettingsTile(
                icon: Icons.dashboard_customize_rounded,
                iconColor: Colors.blue,
                title: '自訂導覽與介面',
                subtitle: '調整底部導覽列順序、文字開關及主題配色',
                onTap: () => _showInterfaceSettingsSheet(context, appState),
              ),
              SettingsTile(
                icon: Icons.delete_sweep_rounded,
                iconColor: Colors.redAccent,
                title: '本機資料說明',
                subtitle: '了解收藏、筆記與草稿的保存方式',
                onTap: () => _showLocalStorageInfo(context),
              ),
            ],
          ),

          SizedBox(height: 16.h),

          // 關於與條款 (Grouped List Style)
          GroupedSettingsList(
            title: '支援與服務條款',
            tiles: [
              SettingsTile(
                icon: Icons.feedback_rounded,
                iconColor: Colors.blueAccent,
                title: '問題回報與建議',
                subtitle: '向團隊回饋系統程式錯誤或優化意見',
                onTap: () => _showFeedbackSheet(context, appState),
              ),
              SettingsTile(
                icon: Icons.source_rounded,
                iconColor: Colors.teal,
                title: '資料來源說明',
                subtitle: '查看案件、法規與學習內容的來源限制',
                onTap: () => _showSourcesSheet(context),
              ),
              SettingsTile(
                icon: Icons.privacy_tip_rounded,
                iconColor: Colors.indigo,
                title: '隱私權說明',
                subtitle: '了解本機資料與外部連結使用限制',
                onTap: () => _showPrivacySheet(context),
              ),
              SettingsTile(
                icon: Icons.article_rounded,
                iconColor: Colors.brown,
                title: '使用條款摘要',
                subtitle: '了解使用 緒言 Preamble 時的重要約定',
                onTap: () => _showTermsSheet(context),
              ),
              SettingsTile(
                icon: Icons.gavel_rounded,
                iconColor: Colors.amber,
                title: '法律免責聲明',
                subtitle: '檢視產品之法律資訊與責任限制說明',
                onTap: () => _showDisclaimerSheet(context),
              ),
              SettingsTile(
                icon: Icons.info_outline_rounded,
                iconColor: Colors.grey,
                title: '版本資訊',
                trailing: Text(
                  'v1.0.0 (Build 42)',
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: textMutedColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),

          // Release 版個人頁不放任何身份切換、內部展示或未接訂閱的控制入口；
          // 使用者可見區域只保留已可實際保存到本機狀態的設定與正式說明。
        ],
      ),
    );
  }

  void _showProfileEditorSheet(BuildContext context, PreambleState appState) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => ProfileEditorSheet(appState: appState),
    );
  }

  void _showFeedbackSheet(BuildContext context, PreambleState appState) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => FeedbackSheet(appState: appState),
    );
  }

  void _showDisclaimerSheet(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        return Padding(
          padding: EdgeInsets.all(16.w),
          child: Container(
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF171C22) : Colors.white,
              borderRadius: BorderRadius.circular(24.r),
              border: Border.all(
                  color: isDark ? const Color(0xFF2B3441) : AppColors.border),
            ),
            padding: EdgeInsets.all(20.w),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.gavel_rounded, color: AppColors.accent, size: 36.sp),
                SizedBox(height: 12.h),
                Text(
                  '法律免責聲明',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w900,
                    color: isDark
                        ? const Color(0xFFF2F4F7)
                        : AppColors.textPrimary,
                  ),
                ),
                SizedBox(height: 12.h),
                Text(
                  '本 App 提供的案件整理、法律知識與 AI 輔助說明，僅供學習與資訊參考，不構成法律意見。如涉及實際個案，請諮詢合格律師或相關專業人士。',
                  style: TextStyle(
                    fontSize: 13.sp,
                    height: 1.55,
                    color: isDark
                        ? const Color(0xFFCAD0D8)
                        : AppColors.textSecondary,
                  ),
                ),
                SizedBox(height: 20.h),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: () => Navigator.pop(context),
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.r)),
                    ),
                    child: const Text('關閉'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showSourcesSheet(BuildContext context) {
    _showPlainInfoDialog(
      context,
      title: '資料來源說明',
      message:
          '法規內容以全國法規資料庫與公開資料為主要查核來源；案件、學習文章與生活法律內容包含 緒言 Preamble 內建整理資料。若畫面未標示即時更新，代表內容不保證為最新狀態。涉及實際權益時，請回到官方來源或諮詢合格律師確認。',
    );
  }

  void _showLocalStorageInfo(BuildContext context) {
    _showPlainInfoDialog(
      context,
      title: '本機資料說明',
      message:
          '你的收藏、追蹤、筆記、閱讀偏好與文件草稿會先保存在此裝置。更換裝置、移除 App 或清除系統資料前，請自行備份重要內容。緒言 Preamble 不會將本機筆記視為正式送件或法律通知。',
    );
  }

  void _showPrivacySheet(BuildContext context) {
    _showPlainInfoDialog(
      context,
      title: '隱私權說明',
      message:
          '緒言 Preamble 會在裝置上保存你主動建立的收藏、筆記、偏好設定與草稿，用於延續 App 內體驗。請避免輸入不必要的身分證字號、完整地址、金融資料或第三人敏感資訊。開啟外部官方網站或分享內容時，該服務會依其自身規範處理資料。',
    );
  }

  void _showTermsSheet(BuildContext context) {
    _showPlainInfoDialog(
      context,
      title: '使用條款摘要',
      message:
          '緒言 Preamble 提供法律學習、案件理解與資料整理工具。你應自行判斷內容是否適合特定情境，並以官方資料與專業意見作為最終依據。不得將本 App 內容用於騷擾、詐欺、規避法律責任或其他不當目的。',
    );
  }

  void _showPlainInfoDialog(
    BuildContext context, {
    required String title,
    required String message,
  }) {
    showDialog<void>(
      context: context,
      builder: (context) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        final surfaceColor = isDark ? const Color(0xFF171C22) : Colors.white;
        final textStyle = TextStyle(
          fontSize: 14.sp,
          color: isDark ? const Color(0xFFA3ABB6) : AppColors.textSecondary,
        );

        return AlertDialog(
          backgroundColor: surfaceColor,
          title: Text(
            title,
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w900,
              color: isDark ? const Color(0xFFF2F4F7) : AppColors.textPrimary,
            ),
          ),
          content: Text(message, style: textStyle),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('知道了'),
            ),
          ],
        );
      },
    );
  }

  // 依據使用者的專業身分代碼，顯示對應風格的金色或金屬質感標籤。
  Widget _buildProfessionBadge(BuildContext context, String profession) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    String label = '一般民眾';
    IconData icon = Icons.person_outline_rounded;
    Color badgeColor = const Color(0xFFC96B3B);
    Color badgeBg = const Color(0xFFFBF0EA);

    if (profession == 'lawyer') {
      label = '執業律師';
      icon = Icons.gavel_rounded;
      badgeColor = const Color(0xFFD6A85F);
      badgeBg = isDark ? const Color(0xFF332715) : const Color(0xFFFAF2E6);
    } else if (profession == 'legal_staff') {
      label = '法務人員';
      icon = Icons.business_center_rounded;
      badgeColor = const Color(0xFF3F51B5);
      badgeBg = isDark ? const Color(0xFF1B2245) : const Color(0xFFE8EAF6);
    } else if (profession == 'law_student') {
      label = '法學生';
      icon = Icons.school_rounded;
      badgeColor = const Color(0xFF2E7D32);
      badgeBg = isDark ? const Color(0xFF133215) : const Color(0xFFE8F5E9);
    } else {
      label = '一般民眾';
      icon = Icons.person_rounded;
      badgeColor = isDark ? const Color(0xFFA3ABB6) : AppColors.textSecondary;
      badgeBg = isDark ? const Color(0xFF2B3441) : AppColors.chipSurface;
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 3.h),
      decoration: BoxDecoration(
        color: badgeBg,
        borderRadius: BorderRadius.circular(100.r),
        border:
            Border.all(color: badgeColor.withValues(alpha: 0.3), width: 1.w),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: badgeColor, size: 12.sp),
          SizedBox(width: 4.w),
          Text(
            label,
            style: TextStyle(
              fontSize: 10.5.sp,
              color: badgeColor,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  // 點擊彈出字型大小調整 Dialog，點選後會將更新值儲存至 SharedPreferences。
  void _showFontSizeDialog(BuildContext context, PreambleState appState) {
    showDialog<void>(
      context: context,
      builder: (context) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        final surfaceColor = isDark ? const Color(0xFF171C22) : Colors.white;
        final currentScale = appState.fontSizeScale;

        return AlertDialog(
          backgroundColor: surfaceColor,
          title: const Text('閱讀字型大小',
              style: TextStyle(fontWeight: FontWeight.bold)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildFontSizeOption(context, appState,
                  label: '小 (0.85)', scale: 0.85, current: currentScale),
              _buildFontSizeOption(context, appState,
                  label: '適中 (1.00)', scale: 1.0, current: currentScale),
              _buildFontSizeOption(context, appState,
                  label: '大 (1.15)', scale: 1.15, current: currentScale),
              _buildFontSizeOption(context, appState,
                  label: '特大 (1.30)', scale: 1.30, current: currentScale),
            ],
          ),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('關閉'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildFontSizeOption(
    BuildContext context,
    PreambleState appState, {
    required String label,
    required double scale,
    required double current,
  }) {
    final isSelected = current == scale;
    return ListTile(
      title: Text(label, style: TextStyle(fontSize: 14.sp * scale)),
      trailing: Icon(
        isSelected ? Icons.check_circle_rounded : Icons.circle_outlined,
        color: isSelected ? AppColors.accent : AppColors.textSecondary,
      ),
      onTap: () {
        appState.updateSettings(fontSizeScale: scale);
        Navigator.pop(context);
        CustomToast.show(context, '閱讀字型大小已更新！');
      },
    );
  }

  // 開啟通知精細設定 Bottom Sheet。
  void _showNotificationSettingsSheet(
      BuildContext context, PreambleState appState) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => NotificationSettingsSheet(appState: appState),
    );
  }

  // Release 版尚未開放正式第三方登入，因此只呈現資料安全說明。
  void _showAccountSecuritySheet(BuildContext context) {
    _showPlainInfoDialog(
      context,
      title: '資料與隱私安全',
      message:
          '目前個人資料、收藏、筆記與偏好設定會保存在此裝置。正式帳號登入與第三方帳號連結完成安全驗證前，本頁不提供帳號綁定或密碼變更操作。請不要在 App 內保存不必要的敏感個資。',
    );
  }

  // 開啟介面自訂偏好設定底頁。
  void _showInterfaceSettingsSheet(
      BuildContext context, PreambleState appState) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => InterfaceSettingsSheet(appState: appState),
    );
  }
}

class _BackButton extends StatelessWidget {
  const _BackButton({required this.onBack});

  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: IconButton(
        onPressed: onBack,
        icon: const Icon(Icons.arrow_back_ios_new_rounded),
        color: Theme.of(context).brightness == Brightness.dark
            ? const Color(0xFFF2F4F7)
            : AppColors.textPrimary,
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.title);
  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 16.sp,
        fontWeight: FontWeight.w900,
        color: Theme.of(context).brightness == Brightness.dark
            ? const Color(0xFFF2F4F7)
            : AppColors.textPrimary,
      ),
    );
  }
}
