import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:preamble/app/app_state.dart';
import 'package:preamble/pages/following/following_page.dart';
import 'package:preamble/theme/preamble_tokens.dart';

import 'profile_editor.dart';

/// 計算與 `FollowingPage` 100% 一致的個人中心即時統計數據。
class ProfileSyncedMetrics {
  const ProfileSyncedMetrics({
    required this.savedCount,
    required this.followedCount,
    required this.noteCount,
    required this.draftCount,
  });

  factory ProfileSyncedMetrics.fromState(PreambleState appState) {
    final following = appState.followingSummary;
    final savedCaseTotal = <String>{
      ...appState.savedCaseIds,
      ...following.savedCaseIds,
    }.length;
    final savedTotal = savedCaseTotal +
        following.savedStatuteIds.length +
        following.savedArticleIds.length;
    final followedTotal = following.followedCaseIds.length +
        following.followedStatuteIds.length +
        following.followedTopicIds.length;

    return ProfileSyncedMetrics(
      savedCount: savedTotal,
      followedCount: followedTotal,
      noteCount: appState.caseNoteDrafts.length,
      draftCount: appState.documentRepository.drafts.length,
    );
  }

  final int savedCount;
  final int followedCount;
  final int noteCount;
  final int draftCount;
}

/// 專屬頭像組件，支援訪客、一般會員與 PRO 專業訂閱者典藏古銅金光環。
class AvatarWidget extends StatelessWidget {
  const AvatarWidget({
    super.key,
    required this.avatarUrl,
    required this.isSubscriber,
    required this.isGuest,
    this.size = 64,
  });

  final String? avatarUrl;
  final bool isSubscriber;
  final bool isGuest;
  final double size;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final avatar = isGuest ? null : getAvatarById(avatarUrl);

    final avatarCore = Container(
      width: size.w,
      height: size.w,
      decoration: BoxDecoration(
        color: isGuest
            ? t.surfaceSubtle
            : (t.isDark
                ? avatar!.color.withValues(alpha: 0.18)
                : avatar!.backgroundColor),
        shape: BoxShape.circle,
        border: Border.all(color: t.border, width: 1.w),
      ),
      child: Center(
        child: Icon(
          isGuest ? PhosphorIconsRegular.user : avatar!.icon,
          color: isGuest
              ? t.textSecondary
              : (t.isDark ? t.brandPrimary : avatar!.color),
          size: (size * 0.48).sp,
        ),
      ),
    );

    if (isSubscriber) {
      return Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            padding: EdgeInsets.all(3.w),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: t.accentBrass, width: 2.w),
              boxShadow: [
                BoxShadow(
                  color: t.accentBrass.withValues(alpha: 0.26),
                  blurRadius: 12,
                  spreadRadius: 1,
                ),
              ],
            ),
            child: avatarCore,
          ),
          Positioned(
            bottom: -2.h,
            right: -2.w,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
              decoration: BoxDecoration(
                color: t.brandPrimaryStrong,
                borderRadius: BorderRadius.circular(6.r),
                border: Border.all(color: t.accentBrass, width: 1.2.w),
              ),
              child: Text(
                'PRO',
                style: t.tabularMetric(
                  size: 8.5.sp,
                  color: t.accentBrass,
                ),
              ),
            ),
          ),
        ],
      );
    }

    return avatarCore;
  }
}

/// 個人名片內嵌之三欄即時數據快覽橫條（收藏案卷・法規 / 追蹤動態 / 隨手筆記），
/// 點擊直接進入 `FollowingPage` 對應分頁。
class ProfileQuickStatsStrip extends StatelessWidget {
  const ProfileQuickStatsStrip({
    super.key,
    required this.metrics,
  });

  final ProfileSyncedMetrics metrics;

  void _openTab(BuildContext context, String tab) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => FollowingPage(initialTab: tab),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;

    return Container(
      padding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 6.w),
      decoration: t.subtleBoxDecoration(radius: 16.r),
      child: IntrinsicHeight(
        child: Row(
          children: [
            Expanded(
              child: _QuickStatCell(
                label: '收藏案卷・法規',
                count: metrics.savedCount,
                onTap: () => _openTab(context, 'collections'),
              ),
            ),
            VerticalDivider(width: 1, thickness: 1, color: t.border),
            Expanded(
              child: _QuickStatCell(
                label: '追蹤動態',
                count: metrics.followedCount,
                onTap: () => _openTab(context, 'updates'),
              ),
            ),
            VerticalDivider(width: 1, thickness: 1, color: t.border),
            Expanded(
              child: _QuickStatCell(
                label: '隨手筆記',
                count: metrics.noteCount,
                onTap: () => _openTab(context, 'notes'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _QuickStatCell extends StatelessWidget {
  const _QuickStatCell({
    required this.label,
    required this.count,
    required this.onTap,
  });

  final String label;
  final int count;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12.r),
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 4.h, horizontal: 4.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '$count',
              style: t.tabularMetric(
                size: 17.sp,
                color: t.brandPrimary,
              ),
            ),
            SizedBox(height: 3.h),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: t.sansBody(
                size: 11.sp,
                weight: FontWeight.w600,
                color: t.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 儀表板 2x2 對稱卡片網格與下方小法助提問紀錄橫幅。
class DashboardGrid extends StatelessWidget {
  const DashboardGrid({super.key, required this.appState});

  final PreambleState appState;

  void _openTab(BuildContext context, String tab) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => FollowingPage(initialTab: tab),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final metrics = ProfileSyncedMetrics.fromState(appState);

    final items = [
      _DashboardItemData(
        title: '我的收藏',
        value: '${metrics.savedCount} 筆',
        icon: PhosphorIconsRegular.bookmarks,
        color: t.brandPrimary,
        bgColor: t.brandContainer,
        onTap: () => _openTab(context, 'collections'),
      ),
      _DashboardItemData(
        title: '追蹤動態',
        value: '${metrics.followedCount} 筆',
        icon: PhosphorIconsRegular.bellRinging,
        color: t.semanticInfo,
        bgColor: t.semanticInfoContainer,
        onTap: () => _openTab(context, 'updates'),
      ),
      _DashboardItemData(
        title: '我的筆記',
        value: '${metrics.noteCount} 筆',
        icon: PhosphorIconsRegular.notebook,
        color: t.semanticSuccess,
        bgColor: t.semanticSuccessContainer,
        onTap: () => _openTab(context, 'notes'),
      ),
      _DashboardItemData(
        title: '文件草稿',
        value: '${metrics.draftCount} 份',
        icon: PhosphorIconsRegular.fileText,
        color: t.accentOnBrassContainer,
        bgColor: t.accentBrassContainer,
        onTap: () => _openTab(context, 'drafts'),
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final cardWidth = (constraints.maxWidth - 10.w) / 2;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Wrap(
              spacing: 10.w,
              runSpacing: 10.h,
              children: items.map((item) {
                return SizedBox(
                  width: cardWidth,
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: item.onTap,
                      borderRadius: BorderRadius.circular(20.r),
                      child: Container(
                        padding: EdgeInsets.all(15.w),
                        decoration: t.cardDecoration(
                          radius: 20.r,
                          elevated: false,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Container(
                                  padding: EdgeInsets.all(8.w),
                                  decoration: BoxDecoration(
                                    color: item.bgColor,
                                    borderRadius: BorderRadius.circular(11.r),
                                  ),
                                  child: Icon(
                                    item.icon,
                                    color: item.color,
                                    size: 19.sp,
                                  ),
                                ),
                                Icon(
                                  PhosphorIconsRegular.arrowUpRight,
                                  size: 14.sp,
                                  color: t.textMuted,
                                ),
                              ],
                            ),
                            SizedBox(height: 12.h),
                            Text(
                              item.title,
                              style: t.sansTitle(size: 14.sp),
                            ),
                            SizedBox(height: 3.h),
                            Text(
                              item.value,
                              style: t.tabularMetric(
                                size: 12.5.sp,
                                weight: FontWeight.w600,
                                color: t.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            SizedBox(height: 10.h),
            Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () => _openTab(context, 'questions'),
                borderRadius: BorderRadius.circular(20.r),
                child: Container(
                  padding: EdgeInsets.all(15.w),
                  decoration: t.cardDecoration(radius: 20.r, elevated: false),
                  child: Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(9.w),
                        decoration: BoxDecoration(
                          color: t.accentBrassContainer,
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        child: Icon(
                          PhosphorIconsRegular.chatsCircle,
                          color: t.accentBrass,
                          size: 20.sp,
                        ),
                      ),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '小法助提問紀錄',
                              style: t.sansTitle(size: 14.sp),
                            ),
                            SizedBox(height: 2.h),
                            Text(
                              '檢視常用問診題庫、法源索引與今日剩餘額度',
                              style: t.sansBody(
                                size: 11.5.sp,
                                color: t.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Icon(
                        PhosphorIconsRegular.caretRight,
                        color: t.textMuted,
                        size: 15.sp,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _DashboardItemData {
  const _DashboardItemData({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
    required this.bgColor,
    required this.onTap,
  });

  final String title;
  final String value;
  final IconData icon;
  final Color color;
  final Color bgColor;
  final VoidCallback onTap;
}

/// 靜奢深松墨綠 × 典藏古銅金 PRO 會員權益橫幅卡片。
class ProUpgradeBanner extends StatelessWidget {
  const ProUpgradeBanner({
    super.key,
    required this.isPro,
    required this.expiryText,
    required this.onTap,
  });

  final bool isPro;
  final String? expiryText;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20.r),
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.all(18.w),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                t.brandPrimaryStrong,
                const Color(0xFF122921),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20.r),
            border: Border.all(
              color: t.accentBrass.withValues(alpha: 0.45),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: t.shadowAmbient,
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.all(10.w),
                decoration: BoxDecoration(
                  color: t.accentBrass.withValues(alpha: 0.16),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: t.accentBrass.withValues(alpha: 0.55),
                  ),
                ),
                child: Icon(
                  PhosphorIconsFill.crown,
                  color: t.accentBrass,
                  size: 22.sp,
                ),
              ),
              SizedBox(width: 14.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isPro ? '緒言 PRO 專業會員已開通' : '升級 緒言 Preamble PRO',
                      style: t.serifTitle(
                        size: 16.sp,
                        color: const Color(0xFFFAF8F4),
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      isPro
                          ? (expiryText ?? '享無限次 AI 問診、客製公文生成與無浮水印 PDF')
                          : '解鎖無限次 AI 問診、客製公文生成與無浮水印 PDF 匯出',
                      style: t.sansBody(
                        size: 11.5.sp,
                        color: const Color(0xFFD6E2DC),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: 10.w),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 11.w, vertical: 6.h),
                decoration: BoxDecoration(
                  color: t.accentBrass,
                  borderRadius: BorderRadius.circular(99.r),
                ),
                child: Text(
                  isPro ? '管理方案' : '立即解鎖',
                  style: t.sansBody(
                    size: 11.5.sp,
                    weight: FontWeight.w700,
                    color: const Color(0xFF151C19),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// 讀者法學智識進修歷程橫幅（零 3D Emoji，統一使用 Phosphor 語意圖示）。
class LearningProgressBanner extends StatelessWidget {
  const LearningProgressBanner({super.key, required this.appState});

  final PreambleState appState;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final savedStatuteCount = appState.followingSummary.savedStatuteIds.length;

    String levelName = '法學入門讀者';
    if (savedStatuteCount >= 1 && savedStatuteCount <= 2) {
      levelName = '法規研習讀者';
    } else if (savedStatuteCount >= 3) {
      levelName = '律政進修學者';
    }

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          showModalBottomSheet<void>(
            context: context,
            isScrollControlled: true,
            useSafeArea: true,
            backgroundColor: Colors.transparent,
            builder: (_) => AchievementRoomSheet(appState: appState),
          );
        },
        borderRadius: BorderRadius.circular(20.r),
        child: Container(
          padding: EdgeInsets.all(15.w),
          decoration: t.cardDecoration(radius: 20.r, elevated: false),
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.all(9.w),
                decoration: BoxDecoration(
                  color: t.brandContainer,
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Icon(
                  PhosphorIconsRegular.medal,
                  color: t.brandPrimary,
                  size: 20.sp,
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '我的學習歷程',
                      style: t.sansTitle(size: 14.sp),
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      '目前頭銜：$levelName（已典藏 $savedStatuteCount 條法規）',
                      style: t.sansBody(size: 11.5.sp, color: t.textSecondary),
                    ),
                  ],
                ),
              ),
              Icon(
                PhosphorIconsRegular.caretRight,
                color: t.textMuted,
                size: 15.sp,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class AchievementRoomSheet extends StatelessWidget {
  const AchievementRoomSheet({super.key, required this.appState});

  final PreambleState appState;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final following = appState.followingSummary;
    final savedStatuteCount = following.savedStatuteIds.length;
    final savedCaseCount = <String>{
      ...appState.savedCaseIds,
      ...following.savedCaseIds,
    }.length;
    final noteCount = appState.caseNoteDrafts.length;

    return Container(
      decoration: BoxDecoration(
        color: t.surfaceElevated,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
        border: Border.all(color: t.border),
      ),
      padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 24.h),
      child: SafeArea(
        top: false,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 38.w,
                  height: 4.h,
                  decoration: BoxDecoration(
                    color: t.borderStrong,
                    borderRadius: BorderRadius.circular(99.r),
                  ),
                ),
              ),
              SizedBox(height: 16.h),
              Text(
                '法律學習成就陳列室',
                style: t.serifTitle(size: 17.sp),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 18.h),
              _buildAchievementTile(
                context,
                title: '法規研習讀者',
                description: '典藏至少 1 條常用法規（目前 $savedStatuteCount 條）',
                icon: PhosphorIconsRegular.bookOpenText,
                isUnlocked: savedStatuteCount >= 1,
                badgeColor: t.semanticSuccess,
              ),
              SizedBox(height: 10.h),
              _buildAchievementTile(
                context,
                title: '律政進修學者',
                description: '典藏至少 3 條常用法規（目前 $savedStatuteCount 條）',
                icon: PhosphorIconsRegular.graduationCap,
                isUnlocked: savedStatuteCount >= 3,
                badgeColor: t.accentBrass,
              ),
              SizedBox(height: 10.h),
              _buildAchievementTile(
                context,
                title: '判例閱卷達人',
                description: '典藏至少 1 筆判決案卷（目前 $savedCaseCount 筆）',
                icon: PhosphorIconsRegular.scales,
                isUnlocked: savedCaseCount >= 1,
                badgeColor: t.brandPrimary,
              ),
              SizedBox(height: 10.h),
              _buildAchievementTile(
                context,
                title: '爭點筆記推手',
                description: '撰寫至少 1 則法務筆記（目前 $noteCount 則）',
                icon: PhosphorIconsRegular.notebook,
                isUnlocked: noteCount >= 1,
                badgeColor: t.semanticInfo,
              ),
              SizedBox(height: 22.h),
              FilledButton(
                onPressed: () => Navigator.pop(context),
                style: FilledButton.styleFrom(
                  backgroundColor: t.brandPrimaryStrong,
                  foregroundColor: const Color(0xFFFAF8F4),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14.r),
                  ),
                  padding: EdgeInsets.symmetric(vertical: 12.h),
                ),
                child: const Text('關閉'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAchievementTile(
    BuildContext context, {
    required String title,
    required String description,
    required IconData icon,
    required bool isUnlocked,
    required Color badgeColor,
  }) {
    final t = context.tokens;

    return Container(
      padding: EdgeInsets.all(13.w),
      decoration: BoxDecoration(
        color: isUnlocked ? t.surface : t.surfaceSubtle,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: isUnlocked ? badgeColor.withValues(alpha: 0.45) : t.border,
          width: isUnlocked ? 1.4 : 1.0,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(9.w),
            decoration: BoxDecoration(
              color: isUnlocked
                  ? badgeColor.withValues(alpha: 0.14)
                  : t.surfaceMuted,
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: isUnlocked ? badgeColor : t.textMuted,
              size: 21.sp,
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        title,
                        style: t.sansTitle(
                          size: 14.sp,
                          color: isUnlocked ? t.textPrimary : t.textMuted,
                        ),
                      ),
                    ),
                    if (isUnlocked) ...[
                      SizedBox(width: 6.w),
                      Icon(
                        PhosphorIconsFill.checkCircle,
                        color: badgeColor,
                        size: 14.sp,
                      ),
                    ],
                  ],
                ),
                SizedBox(height: 2.h),
                Text(
                  description,
                  style: t.sansBody(
                    size: 11.5.sp,
                    color: isUnlocked ? t.textSecondary : t.textMuted,
                  ),
                ),
              ],
            ),
          ),
          Text(
            isUnlocked ? '已達成' : '未解鎖',
            style: t.sansBody(
              size: 11.sp,
              weight: FontWeight.w700,
              color: isUnlocked ? badgeColor : t.textMuted,
            ),
          ),
        ],
      ),
    );
  }
}
