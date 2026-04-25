import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lawapp/app/app_state.dart';
import 'package:lawapp/data/legal_sources/legal_source_registry.dart';
import 'package:lawapp/pages/followed_updates/followed_updates_page.dart';
import 'package:lawapp/pages/tools/legal_tools_page.dart';
import 'package:lawapp/theme/adaptive_layout.dart';
import 'package:lawapp/theme/app_colors.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = LawAppScope.of(context);
    final palette = _ProfilePalette.of(context);
    final topPadding =
        context.hasLargeTopInset ? context.topSafeInset + 10.h : 22.h;

    return Scaffold(
      backgroundColor: palette.background,
      body: ListView(
        physics: const BouncingScrollPhysics(),
        padding: EdgeInsets.fromLTRB(
          16.w,
          topPadding,
          16.w,
          context.pageContentBottomPadding + 32.h,
        ),
        children: [
          _ProfileHeader(appState: appState, palette: palette),
          SizedBox(height: 16.h),
          _AuthActionCard(appState: appState, palette: palette),
          SizedBox(height: 14.h),
          _ThemeCard(appState: appState, palette: palette),
          SizedBox(height: 14.h),
          _MemberFeatureGrid(palette: palette),
          SizedBox(height: 14.h),
          _PricingTierCard(appState: appState, palette: palette),
          SizedBox(height: 14.h),
          _LegalDisclaimerCard(palette: palette),
          SizedBox(height: 14.h),
          _LegalSourcesCard(palette: palette),
        ],
      ),
    );
  }
}

class _ProfilePalette {
  const _ProfilePalette({
    required this.background,
    required this.surface,
    required this.subtleSurface,
    required this.border,
    required this.primaryText,
    required this.secondaryText,
    required this.accent,
  });

  final Color background;
  final Color surface;
  final Color subtleSurface;
  final Color border;
  final Color primaryText;
  final Color secondaryText;
  final Color accent;

  static _ProfilePalette of(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    if (isDark) {
      return const _ProfilePalette(
        background: Color(0xFF0F1216),
        surface: Color(0xFF171C22),
        subtleSurface: Color(0xFF202731),
        border: Color(0xFF2B3441),
        primaryText: Color(0xFFF2F4F7),
        secondaryText: Color(0xFFA3ABB6),
        accent: Color(0xFFE5CD93),
      );
    }

    return const _ProfilePalette(
      background: AppColors.background,
      surface: Colors.white,
      subtleSurface: Color(0xFFFFFAEC),
      border: AppColors.border,
      primaryText: AppColors.textPrimary,
      secondaryText: AppColors.textSecondary,
      accent: AppColors.accent,
    );
  }
}

class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader({
    required this.appState,
    required this.palette,
  });

  final LawAppState appState;
  final _ProfilePalette palette;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(18.w),
      decoration: BoxDecoration(
        color: palette.surface,
        borderRadius: BorderRadius.circular(24.r),
        border: Border.all(color: palette.border),
        boxShadow: const [
          BoxShadow(
            color: Color(0x10000000),
            blurRadius: 18,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 58.w,
            height: 58.w,
            decoration: BoxDecoration(
              color: palette.subtleSurface,
              shape: BoxShape.circle,
              border: Border.all(color: palette.border),
            ),
            child: Icon(
              appState.isSubscriber
                  ? Icons.workspace_premium_rounded
                  : Icons.person_rounded,
              color: palette.accent,
              size: 30.sp,
            ),
          ),
          SizedBox(width: 14.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  appState.isGuest ? '一般民眾模式' : 'MylawApp 使用者',
                  style: TextStyle(
                    fontSize: 20.sp,
                    fontWeight: FontWeight.w900,
                    color: palette.primaryText,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  '${appState.accessTier.label} · ${appState.accessTier.helperText}',
                  style: TextStyle(
                    fontSize: 11.5.sp,
                    height: 1.4,
                    color: palette.secondaryText,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AuthActionCard extends StatelessWidget {
  const _AuthActionCard({
    required this.appState,
    required this.palette,
  });

  final LawAppState appState;
  final _ProfilePalette palette;

  @override
  Widget build(BuildContext context) {
    return _ProfileCard(
      palette: palette,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _ProfileSectionTitle(title: '登入與權限', palette: palette),
          SizedBox(height: 10.h),
          Text(
            '第一版先保留 Google / Apple 登入位置，並用 demo 權限驗證三層產品規則。',
            style: TextStyle(
              fontSize: 12.sp,
              height: 1.45,
              color: palette.secondaryText,
            ),
          ),
          SizedBox(height: 12.h),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _showReservedMessage(context, 'Google 登入'),
                  icon: const Icon(Icons.g_mobiledata_rounded),
                  label: const Text('Google'),
                ),
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _showReservedMessage(context, 'Apple 登入'),
                  icon: const Icon(Icons.apple_rounded),
                  label: const Text('Apple'),
                ),
              ),
            ],
          ),
          SizedBox(height: 10.h),
          Row(
            children: [
              Expanded(
                child: FilledButton(
                  onPressed: appState.signInDemo,
                  child: const Text('登入 Demo'),
                ),
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: FilledButton.tonal(
                  onPressed: appState.activateSubscriberDemo,
                  child: const Text('Pro Demo'),
                ),
              ),
            ],
          ),
          if (!appState.isGuest) ...[
            SizedBox(height: 8.h),
            SizedBox(
              width: double.infinity,
              child: TextButton(
                onPressed: appState.signOut,
                child: const Text('登出並回到訪客模式'),
              ),
            ),
          ],
        ],
      ),
    );
  }

  void _showReservedMessage(BuildContext context, String provider) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$provider 已在 UI 預留，正式 SDK 接入後即可啟用。')),
    );
  }
}

class _ThemeCard extends StatelessWidget {
  const _ThemeCard({
    required this.appState,
    required this.palette,
  });

  final LawAppState appState;
  final _ProfilePalette palette;

  @override
  Widget build(BuildContext context) {
    return _ProfileCard(
      palette: palette,
      child: SwitchListTile.adaptive(
        value: appState.isDarkMode,
        onChanged: appState.setDarkMode,
        dense: true,
        contentPadding: EdgeInsets.zero,
        title: Text(
          '深色模式',
          style: TextStyle(
            fontSize: 15.sp,
            fontWeight: FontWeight.w900,
            color: palette.primaryText,
          ),
        ),
        subtitle: Text(
          '夜間查資料或讀案例時降低亮度。',
          style: TextStyle(fontSize: 11.5.sp, color: palette.secondaryText),
        ),
      ),
    );
  }
}

class _MemberFeatureGrid extends StatelessWidget {
  const _MemberFeatureGrid({required this.palette});

  final _ProfilePalette palette;

  @override
  Widget build(BuildContext context) {
    final features = [
      _FeatureShortcut(
        title: '收藏追蹤',
        subtitle: '主題、案件、法條更新',
        icon: Icons.bookmark_rounded,
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const FollowedUpdatesPage()),
          );
        },
      ),
      _FeatureShortcut(
        title: '文件工具',
        subtitle: '通知、協商、備忘草稿',
        icon: Icons.description_rounded,
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const LegalToolsPage()),
          );
        },
      ),
    ];

    return Row(
      children: features.map((feature) {
        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(
              right: feature == features.first ? 10.w : 0,
            ),
            child: InkWell(
              onTap: feature.onTap,
              borderRadius: BorderRadius.circular(20.r),
              child: Container(
                padding: EdgeInsets.all(14.w),
                decoration: BoxDecoration(
                  color: palette.surface,
                  borderRadius: BorderRadius.circular(20.r),
                  border: Border.all(color: palette.border),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(feature.icon, color: palette.accent, size: 24.sp),
                    SizedBox(height: 10.h),
                    Text(
                      feature.title,
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w900,
                        color: palette.primaryText,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      feature.subtitle,
                      style: TextStyle(
                        fontSize: 10.5.sp,
                        height: 1.35,
                        color: palette.secondaryText,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      }).toList(growable: false),
    );
  }
}

class _FeatureShortcut {
  const _FeatureShortcut({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;
}

class _PricingTierCard extends StatelessWidget {
  const _PricingTierCard({
    required this.appState,
    required this.palette,
  });

  final LawAppState appState;
  final _ProfilePalette palette;

  @override
  Widget build(BuildContext context) {
    return _ProfileCard(
      palette: palette,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _ProfileSectionTitle(title: '三層功能規則', palette: palette),
          SizedBox(height: 10.h),
          _TierRow(
            title: '未登入',
            body: '公開查詢、一次 AI 試問、可閱讀基礎案例摘要。',
            isActive: appState.accessTier == LawAppAccessTier.guest,
            palette: palette,
          ),
          _TierRow(
            title: '已登入',
            body: '保存對話、收藏追蹤、記錄測驗與學習進度。',
            isActive: appState.accessTier == LawAppAccessTier.member,
            palette: palette,
          ),
          _TierRow(
            title: '訂閱者',
            body: '進階文件草稿、完整案例卷宗、較高 AI/RAG 額度。',
            isActive: appState.accessTier == LawAppAccessTier.subscriber,
            palette: palette,
          ),
        ],
      ),
    );
  }
}

class _TierRow extends StatelessWidget {
  const _TierRow({
    required this.title,
    required this.body,
    required this.isActive,
    required this.palette,
  });

  final String title;
  final String body;
  final bool isActive;
  final _ProfilePalette palette;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 8.h),
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: isActive ? palette.subtleSurface : Colors.transparent,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: isActive ? palette.accent : palette.border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            isActive ? Icons.check_circle_rounded : Icons.circle_outlined,
            color: isActive ? palette.accent : palette.secondaryText,
            size: 18.sp,
          ),
          SizedBox(width: 8.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w900,
                    color: palette.primaryText,
                  ),
                ),
                SizedBox(height: 3.h),
                Text(
                  body,
                  style: TextStyle(
                    fontSize: 11.sp,
                    height: 1.4,
                    color: palette.secondaryText,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _LegalDisclaimerCard extends StatelessWidget {
  const _LegalDisclaimerCard({required this.palette});

  final _ProfilePalette palette;

  @override
  Widget build(BuildContext context) {
    return _ProfileCard(
      palette: palette,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _ProfileSectionTitle(title: '法律使用提醒', palette: palette),
          SizedBox(height: 8.h),
          Text(
            '本 App 提供法律資訊整理、學習與 AI 輔助，不構成律師正式法律意見。'
            '案件結果會受完整事實、證據、法院見解與最新法令影響；遇到訴訟期限、重大財產、刑事或人身安全問題，請儘快諮詢律師或法律扶助資源。',
            style: TextStyle(
              fontSize: 12.sp,
              height: 1.55,
              color: palette.secondaryText,
            ),
          ),
        ],
      ),
    );
  }
}

class _LegalSourcesCard extends StatelessWidget {
  const _LegalSourcesCard({required this.palette});

  final _ProfilePalette palette;

  @override
  Widget build(BuildContext context) {
    return _ProfileCard(
      palette: palette,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _ProfileSectionTitle(title: '資料來源與後端規劃', palette: palette),
          SizedBox(height: 10.h),
          ...legalSourceEntries.map(
            (source) => Padding(
              padding: EdgeInsets.only(bottom: 10.h),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 34.w,
                    height: 34.w,
                    decoration: BoxDecoration(
                      color: palette.subtleSurface,
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child:
                        Icon(source.icon, color: palette.accent, size: 19.sp),
                  ),
                  SizedBox(width: 10.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${source.title}｜${source.statusLabel}',
                          style: TextStyle(
                            fontSize: 12.5.sp,
                            fontWeight: FontWeight.w900,
                            color: palette.primaryText,
                          ),
                        ),
                        SizedBox(height: 3.h),
                        Text(
                          source.description,
                          style: TextStyle(
                            fontSize: 10.8.sp,
                            height: 1.45,
                            color: palette.secondaryText,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileCard extends StatelessWidget {
  const _ProfileCard({
    required this.palette,
    required this.child,
  });

  final _ProfilePalette palette;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: palette.surface,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: palette.border),
      ),
      child: child,
    );
  }
}

class _ProfileSectionTitle extends StatelessWidget {
  const _ProfileSectionTitle({
    required this.title,
    required this.palette,
  });

  final String title;
  final _ProfilePalette palette;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 16.sp,
        fontWeight: FontWeight.w900,
        color: palette.primaryText,
      ),
    );
  }
}
