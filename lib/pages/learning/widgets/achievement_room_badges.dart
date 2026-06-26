import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:preamble/components/home/v2/home_v2_palette.dart';
import 'package:preamble/data/learning/learning_game_state.dart';
import 'package:preamble/features/case_time_machine/widgets/case_time_machine_svg_icon.dart';
import 'package:preamble/pages/learning/widgets/notebook_aesthetics.dart';
import 'package:preamble/theme/app_colors.dart';

// 成就室的徽章牆 UI。
// 只放徽章資料、徽章格狀牆與徽章詳細彈窗，不放學習歷程與錯題本邏輯。

class AchievementBadgeWall extends StatelessWidget {
  const AchievementBadgeWall({
    super.key,
    required this.gameState,
  });

  final LearningGameState gameState;

  // 徽章資料同時保留色票與圖片路徑；色票負責解鎖卡片的底色，
  // 圖片則是主要視覺，日後要替換徽章只需要換 asset 或更新這份清單。
  static final List<Map<String, dynamic>> _badgesInfo = [
    {
      'name': '初學乍練',
      'asset': 'assets/images/learning/badges/badge_beginner.png',
      'icon': CtmSvgIcons.sprout,
      'color': const Color(0xFFE2F0D9),
      'iconColor': const Color(0xFF385623),
      'desc': '加入法學學堂並開始學習。',
    },
    {
      'name': '租屋達人',
      'asset': 'assets/images/learning/badges/badge_rental_expert.png',
      'icon': CtmSvgIcons.home,
      'color': const Color(0xFFFFF2CC),
      'iconColor': const Color(0xFF7F6000),
      'desc': '通關「租屋糾紛」所有單元即可解鎖。',
    },
    {
      'name': '車禍防護',
      'asset': 'assets/images/learning/badges/badge_traffic_protector.png',
      'icon': CtmSvgIcons.car,
      'color': const Color(0xFFFCE4D6),
      'iconColor': const Color(0xFFC65911),
      'desc': '通關「車禍訴訟」課堂並答對測驗解鎖。',
    },
    {
      'name': '職場精英',
      'asset': 'assets/images/learning/badges/badge_workplace_rights.png',
      'icon': CtmSvgIcons.briefcase,
      'color': const Color(0xFFE8F0FE),
      'iconColor': const Color(0xFF1F4E79),
      'desc': '通關「職場權益」課堂單元解鎖。',
    },
    {
      'name': '網路先鋒',
      'asset': 'assets/images/learning/badges/badge_privacy_guard.png',
      'icon': CtmSvgIcons.smartphone,
      'color': const Color(0xFFEAF0F8),
      'iconColor': const Color(0xFF2F5597),
      'desc': '通關「肖像權與社群發文」課堂解鎖。',
    },
    {
      'name': '消費專家',
      'asset': 'assets/images/learning/badges/badge_consumer_protector.png',
      'icon': CtmSvgIcons.shoppingBag,
      'color': const Color(0xFFFDE8E8),
      'iconColor': const Color(0xFFC00000),
      'desc': '通關「網購退貨與消保」課堂解鎖。',
    },
    {
      'name': '擂台霸主',
      'asset': 'assets/images/learning/badges/badge_court_champion.png',
      'icon': CtmSvgIcons.trophy,
      'color': const Color(0xFFFFF0C2),
      'iconColor': const Color(0xFF806000),
      'desc': '在「公民法律小擂台」獲得全對。',
    },
    {
      'name': '翻譯大師',
      'asset':
          'assets/images/learning/badges/badge_plain_language_translator.png',
      'icon': CtmSvgIcons.gavel,
      'color': const Color(0xFFE1F5FE),
      'iconColor': const Color(0xFF0070C0),
      'desc': '使用過「白話文翻譯機」達 3 次。',
    },
    {
      'name': '備忘行家',
      'asset': 'assets/images/learning/badges/badge_evidence_memo.png',
      'icon': CtmSvgIcons.save,
      'color': const Color(0xFFECEFF1),
      'iconColor': const Color(0xFF37474F),
      'desc': '導出或儲存過一份證據準備清單。',
    },
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return NotebookCard(
      hasBookmark: true,
      bookmarkColor: const Color(0xFFE5CD93),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CtmSvgIcon(CtmSvgIcons.award,
                  color: const Color(0xFFE8B95F), size: 20.sp),
              SizedBox(width: 8.w),
              Text(
                '榮譽法律徽章牆 (3x3)',
                style: TextStyle(
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w900,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _badgesInfo.length,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              mainAxisSpacing: 10.h,
              crossAxisSpacing: 10.w,
              childAspectRatio: 0.9,
            ),
            itemBuilder: (context, index) {
              final badge = _badgesInfo[index];
              final isUnlocked =
                  gameState.unlockedBadges.contains(badge['name']);

              return GestureDetector(
                onTap: () => _showBadgeDetail(context, badge, isUnlocked),
                child: Container(
                  decoration: BoxDecoration(
                    color: isUnlocked
                        ? badge['color']
                        : (isDark
                            ? const Color(0xFF1E252D)
                            : const Color(0xFFF5F5F5)),
                    borderRadius: BorderRadius.circular(14.r),
                    border: Border.all(
                      color: isUnlocked
                          ? Colors.transparent
                          : (isDark
                              ? const Color(0xFF2D3845)
                              : const Color(0xFFE0E0E0)),
                      width: 1.w,
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildBadgeAsset(
                        badge['asset'] as String,
                        isUnlocked: isUnlocked,
                        size: 48.w,
                      ),
                      SizedBox(height: 6.h),
                      Text(
                        badge['name'],
                        style: TextStyle(
                          fontSize: 11.sp,
                          fontWeight: FontWeight.bold,
                          color: isUnlocked
                              ? const Color(0xFF1F4E3D)
                              : AppColors.textMuted,
                        ),
                      ),
                      SizedBox(height: 2.h),
                      Text(
                        isUnlocked ? '已解鎖' : '未解鎖',
                        style: TextStyle(
                          fontSize: 9.sp,
                          color: isUnlocked
                              ? Colors.green.shade800
                              : AppColors.textMuted,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildBadgeAsset(
    String assetPath, {
    required bool isUnlocked,
    required double size,
  }) {
    final image = Image.asset(
      assetPath,
      width: size,
      height: size,
      fit: BoxFit.contain,
      errorBuilder: (context, error, stackTrace) {
        return Icon(
          Icons.workspace_premium_outlined,
          size: size * 0.72,
          color: isUnlocked ? HomeV2Palette.trustGreen : AppColors.textMuted,
        );
      },
    );

    if (isUnlocked) return image;

    // 未解鎖狀態不另外準備灰色圖片，直接用灰階濾鏡處理同一張 asset，
    // 之後新增徽章時只要補彩色版即可維持一致的鎖定樣式。
    return Opacity(
      opacity: 0.38,
      child: ColorFiltered(
        colorFilter: const ColorFilter.matrix(<double>[
          0.2126,
          0.7152,
          0.0722,
          0,
          0,
          0.2126,
          0.7152,
          0.0722,
          0,
          0,
          0.2126,
          0.7152,
          0.0722,
          0,
          0,
          0,
          0,
          0,
          1,
          0,
        ]),
        child: image,
      ),
    );
  }

  // 顯示徽章詳細資訊
  void _showBadgeDetail(
    BuildContext context,
    Map<String, dynamic> badge,
    bool isUnlocked,
  ) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
          title: Row(
            children: [
              _buildBadgeAsset(
                badge['asset'] as String,
                isUnlocked: isUnlocked,
                size: 34.w,
              ),
              SizedBox(width: 8.w),
              Text(badge['name']),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                isUnlocked ? '恭喜，您已成功解鎖此榮譽徽章。' : '解鎖條件：',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color:
                      isUnlocked ? Colors.green.shade800 : Colors.red.shade800,
                ),
              ),
              SizedBox(height: 8.h),
              Text(badge['desc']),
              if (isUnlocked) ...[
                SizedBox(height: 12.h),
                Text(
                  '解鎖日期：${DateFormat('yyyy/MM/dd HH:mm').format(DateTime.now().subtract(const Duration(hours: 2)))}',
                  style: TextStyle(
                      fontSize: 11.sp, color: AppColors.textSecondary),
                ),
              ],
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('關閉'),
            ),
          ],
        );
      },
    );
  }
}
