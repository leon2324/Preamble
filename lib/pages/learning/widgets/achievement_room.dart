import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lawapp/data/learning/learning_game_state.dart';
import 'package:lawapp/pages/learning/widgets/notebook_aesthetics.dart';
import 'package:lawapp/theme/app_colors.dart';
import 'package:lawapp/components/home/v2/home_v2_palette.dart';
import 'package:lawapp/data/mock_data/learning/learning_mock_data.dart';
import 'package:lawapp/features/case_time_machine/widgets/case_time_machine_svg_icon.dart';
import 'package:intl/intl.dart';
import 'package:lawapp/pages/learning/learning_mock_detail_page.dart';
import 'package:lawapp/data/learning/supabase_learning_service.dart';
import 'package:lawapp/pages/learning/widgets/notebook_cover_editor_page.dart';

class AchievementRoomPage extends StatefulWidget {
  const AchievementRoomPage({super.key});

  @override
  State<AchievementRoomPage> createState() => _AchievementRoomPageState();
}

class _AchievementRoomPageState extends State<AchievementRoomPage> with SingleTickerProviderStateMixin {
  late final AnimationController _treeAnimController;
  double _waterScale = 1.0;
  bool _showWaterParticles = false;

  @override
  void initState() {
    super.initState();
    _treeAnimController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();
  }

  @override
  void dispose() {
    _treeAnimController.dispose();
    super.dispose();
  }

  void _triggerWatering() {
    if (_waterScale != 1.0) return;
    setState(() {
      _waterScale = 1.12;
      _showWaterParticles = true;
    });
    Future.delayed(const Duration(milliseconds: 140), () {
      if (mounted) {
        setState(() {
          _waterScale = 0.94;
        });
      }
    });
    Future.delayed(const Duration(milliseconds: 260), () {
      if (mounted) {
        setState(() {
          _waterScale = 1.0;
        });
      }
    });
    Future.delayed(const Duration(milliseconds: 800), () {
      if (mounted) {
        setState(() {
          _showWaterParticles = false;
        });
      }
    });
  }

  // 台灣繁體中文教學註解：
  // 徽章資料同時保留色票與圖片路徑；色票負責解鎖卡片的底色，
  // 圖片則是主要視覺，日後要替換徽章只需要換 asset 或更新這份清單。
  final List<Map<String, dynamic>> _badgesInfo = [
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
    final gameState = LearningGameState.instance;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          '小法助成長檔案與成就室',
          style: TextStyle(
            fontSize: 17.sp,
            fontWeight: FontWeight.w800,
            color: AppColors.textPrimary,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        systemOverlayStyle: isDark ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark,
      ),
      body: ListenableBuilder(
        listenable: gameState,
        builder: (context, _) {
          return NotebookBackground(
            child: ListView(
              padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 40.h),
              children: [
                // 1. 吉祥物成長狀態卡片
                _buildMascotStatusCard(gameState),
                SizedBox(height: 12.h),

                // 2. 榮譽法律徽章牆
                _buildBadgeWall(gameState),
                SizedBox(height: 12.h),

                // 3. 我的備忘錄 (錯題本 + 儲存證據清單)
                _buildMemoSection(gameState),
                SizedBox(height: 12.h),

                // 4. 解答與學習歷史紀錄
                _buildHistorySection(gameState),
              ],
            ),
          );
        },
      ),
    );
  }

  // 1. 吉祥物狀態卡
  // 1. 吉祥物狀態卡 (現改版為：動態法學智慧樹與奔跑小孩主視覺)
  Widget _buildMascotStatusCard(LearningGameState gameState) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return NotebookCard(
      hasPaperClip: true,
      padding: EdgeInsets.zero,
      backgroundColor: isDark ? const Color(0xFF161C23) : Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 1. 動態畫布區域
          GestureDetector(
            onTap: _triggerWatering, // 點擊樹木澆水互動
            child: ClipRRect(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(16.r),
                topRight: Radius.circular(16.r),
              ),
              child: Stack(
                children: [
                  SizedBox(
                    height: 195.h,
                    width: double.infinity,
                    child: AnimatedBuilder(
                      animation: _treeAnimController,
                      builder: (context, _) {
                        return CustomPaint(
                          painter: _WisdomTreePainter(
                            level: gameState.level,
                            completedUnits: gameState.completedSteps.length,
                            animationValue: _treeAnimController.value,
                            treeScale: _waterScale,
                            showParticles: _showWaterParticles,
                          ),
                        );
                      },
                    ),
                  ),
                  // 澆水浮動提示標籤
                  Positioned(
                    top: 10.h,
                    left: 10.w,
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.85),
                        borderRadius: BorderRadius.circular(20.r),
                        border: Border.all(color: const Color(0xFF9EC979).withValues(alpha: 0.5)),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.05),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.water_drop, color: Colors.blue[400], size: 12.sp),
                          SizedBox(width: 2.w),
                          Text(
                            '點擊大樹澆水',
                            style: TextStyle(
                              fontSize: 9.5.sp,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF2E7D32),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          // 2. 下半部膠囊進度條與資訊
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
                      decoration: BoxDecoration(
                        color: HomeV2Palette.aiYellow,
                        borderRadius: BorderRadius.circular(6.r),
                        border: Border.all(color: const Color(0xFFE8B95F)),
                      ),
                      child: Text(
                        'Level ${gameState.level} / ${gameState.maxLevel}',
                        style: TextStyle(
                          fontSize: 10.sp,
                          fontWeight: FontWeight.w900,
                          color: HomeV2Palette.ink,
                        ),
                      ),
                    ),
                    SizedBox(width: 8.w),
                    Text(
                      gameState.levelTitle,
                      style: TextStyle(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w900,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      '經驗值：${gameState.experience} / ${gameState.nextLevelXp} XP',
                      style: TextStyle(
                        fontSize: 11.sp,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8.h),
                // 進度條
                ClipRRect(
                  borderRadius: BorderRadius.circular(99.r),
                  child: LinearProgressIndicator(
                    value: gameState.levelProgress,
                    minHeight: 8.h,
                    backgroundColor: isDark
                        ? const Color(0xFF2D3845)
                        : const Color(0xFFEFECE6),
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      HomeV2Palette.trustGreen,
                    ),
                  ),
                ),
                SizedBox(height: 6.h),
                Text(
                  gameState.level >= gameState.maxLevel
                      ? '已達最高 Level ${gameState.maxLevel}，智慧法治神木已完全長成！🌳'
                      : '再獲得 ${gameState.xpToNextLevel} XP 可升級為「${gameState.nextLevelTitle}」並壯大樹木與解鎖可愛奔跑小孩！',
                  style: TextStyle(
                    fontSize: 9.sp,
                    color: AppColors.textMuted,
                  ),
                ),
                SizedBox(height: 12.h),
                const Divider(),
                SizedBox(height: 6.h),
                ElevatedButton.icon(
                  icon: Icon(Icons.palette_rounded, size: 14.sp),
                  label: Text('自訂我的法學筆記本封面', style: TextStyle(fontSize: 11.5.sp, fontWeight: FontWeight.bold)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: HomeV2Palette.mint,
                    foregroundColor: HomeV2Palette.trustGreen,
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
                    padding: EdgeInsets.symmetric(vertical: 10.h),
                  ),
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const NotebookCoverEditorPage()),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 2. 榮譽法律徽章牆
  Widget _buildBadgeWall(LearningGameState gameState) {
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
                onTap: () => _showBadgeDetail(badge, isUnlocked),
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

    // 台灣繁體中文教學註解：
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
  void _showBadgeDetail(Map<String, dynamic> badge, bool isUnlocked) {
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

  // 3. 我的備忘錄
  Widget _buildMemoSection(LearningGameState gameState) {
    return NotebookCard(
      hasBinderRings: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CtmSvgIcon(CtmSvgIcons.bookmark,
                  color: HomeV2Palette.trustGreen, size: 20.sp),
              SizedBox(width: 8.w),
              Text(
                '我的備忘錄',
                style: TextStyle(
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w900,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),

          // 錯題本入口
          ListTile(
            leading: CtmSvgIcon(CtmSvgIcons.bookOpen,
                color: const Color(0xFFE88B8B), size: 20.sp),
            title: Text(
              '📕 我的錯題本',
              style: TextStyle(fontSize: 13.5.sp, fontWeight: FontWeight.bold),
            ),
            subtitle: Text(
              '目前有 ${gameState.incorrectQuestions.length} 題答錯的題目',
              style: TextStyle(fontSize: 11.sp),
            ),
            trailing: CtmSvgIcon(CtmSvgIcons.chevronRight,
                size: 16.sp, color: Colors.grey),
            onTap: () => _openIncorrectQuestions(gameState),
          ),
          const Divider(),

          // 證據清單入口
          ListTile(
            leading: CtmSvgIcon(CtmSvgIcons.filePen,
                color: const Color(0xFF6FA8DC), size: 20.sp),
            title: Text(
              '💾 儲存的證據清單',
              style: TextStyle(fontSize: 13.5.sp, fontWeight: FontWeight.bold),
            ),
            subtitle: Text(
              '目前已儲存 ${gameState.savedEvidenceLists.length} 份清單',
              style: TextStyle(fontSize: 11.sp),
            ),
            trailing: CtmSvgIcon(CtmSvgIcons.chevronRight,
                size: 16.sp, color: Colors.grey),
            onTap: () => _openSavedEvidenceLists(gameState),
          ),
          const Divider(),

          // 收藏的法律金句與筆記入口
          ListTile(
            leading: CtmSvgIcon(CtmSvgIcons.bookmark,
                color: const Color(0xFFE8B95F), size: 20.sp),
            title: Text(
              '🏷️ 收藏的法律金句與筆記',
              style: TextStyle(fontSize: 13.5.sp, fontWeight: FontWeight.bold),
            ),
            subtitle: Text(
              '目前已儲存 ${gameState.savedQuotes.length + gameState.savedArticles.length + gameState.savedHighlights.length} 項內容',
              style: TextStyle(fontSize: 11.sp),
            ),
            trailing: CtmSvgIcon(CtmSvgIcons.chevronRight,
                size: 16.sp, color: Colors.grey),
            onTap: () => _openSavedNotesPage(gameState),
          ),
        ],
      ),
    );
  }

  // 4. 解答與學習歷史紀錄
  Widget _buildHistorySection(LearningGameState gameState) {
    final history = gameState.quizHistory;
    final totalCount = history.length;
    final correctCount = history.where((item) => item['isCorrect'] == true).length;
    final accuracy = totalCount == 0 ? 0.0 : (correctCount / totalCount) * 100;

    return NotebookCard(
      hasBinderRings: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.history, color: const Color(0xFF5F9EA0), size: 20.sp),
              SizedBox(width: 8.w),
              Text(
                '解答與學習歷史',
                style: TextStyle(
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w900,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),

          if (history.isNotEmpty) ...[
            // 數據儀表板
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildStatChip('總解答題數', '$totalCount 題', Colors.blue),
                _buildStatChip('答對率', '${accuracy.toStringAsFixed(0)}%', accuracy >= 70 ? Colors.green : Colors.orange),
                _buildStatChip('錯題本', '${gameState.incorrectQuestions.length} 題', Colors.red),
              ],
            ),
            SizedBox(height: 12.h),

            // 最近 5 筆紀錄
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: history.length > 5 ? 5 : history.length,
              itemBuilder: (context, index) {
                return _buildHistoryItem(history[index]);
              },
            ),

            if (history.length > 5) ...[
              SizedBox(height: 8.h),
              Center(
                child: TextButton(
                  onPressed: () => _showAllHistoryPage(gameState),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '查看全部解答歷史 (${history.length})',
                        style: TextStyle(
                          fontSize: 12.5.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Icon(Icons.keyboard_arrow_right, size: 16.sp),
                    ],
                  ),
                ),
              ),
            ],
          ] else ...[
            // 空白佔位
            Padding(
              padding: EdgeInsets.symmetric(vertical: 24.h),
              child: Center(
                child: Column(
                  children: [
                    Icon(
                      Icons.history_edu,
                      size: 40.sp,
                      color: Colors.grey.withValues(alpha: 0.5),
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      '尚未開始挑戰測驗，快去學堂答題吧！🌱',
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStatChip(String label, String value, Color color) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Expanded(
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 4.w),
        padding: EdgeInsets.symmetric(vertical: 8.h, horizontal: 6.w),
        decoration: BoxDecoration(
          color: color.withValues(alpha: isDark ? 0.15 : 0.08),
          borderRadius: BorderRadius.circular(8.r),
          border: Border.all(color: color.withValues(alpha: 0.2)),
        ),
        child: Column(
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 10.sp,
                color: isDark ? Colors.grey[400] : Colors.grey[700],
              ),
            ),
            SizedBox(height: 4.h),
            Text(
              value,
              style: TextStyle(
                fontSize: 13.sp,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHistoryItem(Map<String, dynamic> record) {
    final isCorrect = record['isCorrect'] as bool? ?? false;
    final category = record['category'] as String? ?? '法學知識';
    final stepLabel = record['stepLabel'] as String? ?? '專題測驗';
    final timestampStr = record['timestamp'] as String? ?? '';
    final question = record['question'] as String? ?? '';

    // 格式化時間印記
    String formattedTime = '';
    if (timestampStr.isNotEmpty) {
      try {
        final dt = DateTime.parse(timestampStr);
        formattedTime = '${dt.month.toString().padLeft(2, '0')}/${dt.day.toString().padLeft(2, '0')} ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
      } catch (_) {
        formattedTime = timestampStr;
      }
    }

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final themeColor = _getCategoryColor(category);

    return Container(
      margin: EdgeInsets.symmetric(vertical: 6.h),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1F2937) : Colors.grey[50],
        borderRadius: BorderRadius.circular(10.r),
        border: Border.all(
          color: isDark ? const Color(0xFF374151) : Colors.grey[200]!,
          width: 0.5,
        ),
      ),
      child: ListTile(
        contentPadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
        title: Row(
          children: [
            Container(
              padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
              decoration: BoxDecoration(
                color: themeColor.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(4.r),
              ),
              child: Text(
                category,
                style: TextStyle(
                  fontSize: 10.sp,
                  fontWeight: FontWeight.bold,
                  color: themeColor,
                ),
              ),
            ),
            SizedBox(width: 6.w),
            Text(
              stepLabel,
              style: TextStyle(
                fontSize: 11.sp,
                fontWeight: FontWeight.w600,
                color: Colors.grey,
              ),
            ),
            const Spacer(),
            Text(
              formattedTime,
              style: TextStyle(
                fontSize: 10.sp,
                color: Colors.grey,
              ),
            ),
          ],
        ),
        subtitle: Padding(
          padding: EdgeInsets.only(top: 6.h),
          child: Text(
            question,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 12.5.sp,
              fontWeight: FontWeight.w500,
              color: AppColors.textPrimary,
            ),
          ),
        ),
        trailing: Container(
          padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
          decoration: BoxDecoration(
            color: isCorrect
                ? Colors.green.withValues(alpha: 0.1)
                : Colors.red.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(20.r),
          ),
          child: Text(
            isCorrect ? '答對' : '答錯',
            style: TextStyle(
              fontSize: 10.sp,
              fontWeight: FontWeight.bold,
              color: isCorrect ? Colors.green : Colors.red,
            ),
          ),
        ),
        onTap: () => _showHistoryDetailSheet(context, record),
      ),
    );
  }

  Color _getCategoryColor(String category) {
    switch (category) {
      case '租屋糾紛':
        return const Color(0xFFD4A373);
      case '車禍事故':
        return const Color(0xFFE07A5F);
      case '職場權益':
        return const Color(0xFF3D5A80);
      case '網購消費':
        return const Color(0xFFE63946);
      case '個資隱私':
        return const Color(0xFF8338EC);
      default:
        return const Color(0xFF457B9D);
    }
  }

  void _showHistoryDetailSheet(BuildContext context, Map<String, dynamic> record) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isCorrect = record['isCorrect'] as bool? ?? false;
    final category = record['category'] as String? ?? '法學知識';
    final stepLabel = record['stepLabel'] as String? ?? '專題測驗';
    final question = record['question'] as String? ?? '';
    final options = List<String>.from(record['options'] ?? []);
    final selectedAnswer = record['selectedAnswer'] as String? ?? '';
    final correctAnswer = record['correctAnswer'] as String? ?? '';
    final explanation = record['explanation'] as String? ?? '';
    final themeColor = _getCategoryColor(category);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1A222D) : Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(24.r),
              topRight: Radius.circular(24.r),
            ),
          ),
          padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, MediaQuery.of(context).padding.bottom + 20.h),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 40.w,
                  height: 5.h,
                  decoration: BoxDecoration(
                    color: Colors.grey.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                ),
              ),
              SizedBox(height: 16.h),

              Row(
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                    decoration: BoxDecoration(
                      color: themeColor.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(6.r),
                    ),
                    child: Text(
                      category,
                      style: TextStyle(
                        fontSize: 11.sp,
                        fontWeight: FontWeight.bold,
                        color: themeColor,
                      ),
                    ),
                  ),
                  SizedBox(width: 8.w),
                  Text(
                    stepLabel,
                    style: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey,
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                    decoration: BoxDecoration(
                      color: isCorrect
                          ? Colors.green.withValues(alpha: 0.1)
                          : Colors.red.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20.r),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          isCorrect ? Icons.check_circle : Icons.cancel,
                          color: isCorrect ? Colors.green : Colors.red,
                          size: 14.sp,
                        ),
                        SizedBox(width: 4.w),
                        Text(
                          isCorrect ? '解答正確' : '解答錯誤',
                          style: TextStyle(
                            fontSize: 11.sp,
                            fontWeight: FontWeight.bold,
                            color: isCorrect ? Colors.green : Colors.red,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16.h),

              Text(
                '題目：',
                style: TextStyle(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey,
                ),
              ),
              SizedBox(height: 4.h),
              Text(
                question,
                style: TextStyle(
                  fontSize: 15.sp,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                  height: 1.4,
                ),
              ),
              SizedBox(height: 16.h),

              Container(
                padding: EdgeInsets.all(12.w),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF263238) : Colors.grey[50],
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(
                    color: isDark ? const Color(0xFF37474F) : Colors.grey[200]!,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.person, size: 16.sp, color: isCorrect ? Colors.green : Colors.red),
                        SizedBox(width: 6.w),
                        Text(
                          '你的解答：',
                          style: TextStyle(fontSize: 12.sp, color: isDark ? Colors.grey[300] : Colors.grey[700]),
                        ),
                        Expanded(
                          child: Text(
                            selectedAnswer,
                            style: TextStyle(
                              fontSize: 13.sp,
                              fontWeight: FontWeight.bold,
                              color: isCorrect ? Colors.green : Colors.red,
                            ),
                          ),
                        ),
                      ],
                    ),
                    if (!isCorrect) ...[
                      SizedBox(height: 8.h),
                      Row(
                        children: [
                          Icon(Icons.check_circle_outline, size: 16.sp, color: Colors.green),
                          SizedBox(width: 6.w),
                          Text(
                            '正確解答：',
                            style: TextStyle(fontSize: 12.sp, color: isDark ? Colors.grey[300] : Colors.grey[700]),
                          ),
                          Expanded(
                            child: Text(
                              correctAnswer,
                              style: TextStyle(
                                fontSize: 13.sp,
                                fontWeight: FontWeight.bold,
                                color: Colors.green,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
              SizedBox(height: 16.h),

              Text(
                '💡 實務解析：',
                style: TextStyle(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.bold,
                  color: themeColor,
                ),
              ),
              SizedBox(height: 6.h),
              Container(
                constraints: BoxConstraints(maxHeight: 180.h),
                child: SingleChildScrollView(
                  child: Text(
                    explanation,
                    style: TextStyle(
                      fontSize: 13.sp,
                      color: AppColors.textSecondary,
                      height: 1.5,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 20.h),

              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 12.h),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
                      ),
                      onPressed: () => Navigator.pop(context),
                      child: const Text('關閉'),
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: themeColor,
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(vertical: 12.h),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
                      ),
                      onPressed: () {
                        Navigator.pop(context);
                        _navigateToQuizUnit(category, stepLabel);
                      },
                      child: Text(isCorrect ? '前往複習' : '重新挑戰'),
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

  void _showAllHistoryPage(LearningGameState gameState) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => Scaffold(
          appBar: AppBar(
            title: const Text('📜 全部解答歷史'),
            centerTitle: true,
          ),
          body: ListenableBuilder(
            listenable: gameState,
            builder: (context, _) {
              if (gameState.quizHistory.isEmpty) {
                return const Center(child: Text('目前沒有解答歷史紀錄。🌱'));
              }
              return ListView.builder(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                itemCount: gameState.quizHistory.length,
                itemBuilder: (context, index) {
                  return _buildHistoryItem(gameState.quizHistory[index]);
                },
              );
            },
          ),
        ),
      ),
    );
  }

  void _navigateToQuizUnit(String category, String stepLabel) async {
    LearningTopicData? topic = featuredLearningTopics[category];
    if (topic == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Row(
            children: [
              SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
              ),
              SizedBox(width: 12),
              Text('正在從雲端載入專題內容...'),
            ],
          ),
          duration: Duration(seconds: 1),
        ),
      );
      topic = await SupabaseLearningService.instance.fetchTopicByTitle(category);
    }

    if (topic == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('找不到對應的主題，可能尚未同步或已移除。')),
      );
      return;
    }

    final finalTopic = topic;
    LearningMockArticle? targetArticle;
    String? finalStepLabel;

    if (stepLabel == '專題測驗') {
      finalStepLabel = 'STEP 5';
      final step5Unit = finalTopic.units.firstWhere(
        (u) => u.stepLabel == 'STEP 5',
        orElse: () => finalTopic.units.last,
      );
      targetArticle = step5Unit.article;
    } else {
      for (final unit in finalTopic.units) {
        if (unit.stepLabel == stepLabel) {
          targetArticle = unit.article;
          finalStepLabel = unit.stepLabel;
          break;
        }
      }
    }

    if (targetArticle != null) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => LearningMockDetailPage(
            article: targetArticle!,
            unitStepLabel: finalStepLabel,
            category: category,
          ),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('找不到對應的學習單元。')),
      );
    }
  }

  // 開啟錯題本
  void _openIncorrectQuestions(LearningGameState gameState) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => Scaffold(
          appBar: AppBar(title: const Text('📕 我的錯題本')),
          body: ListenableBuilder(
            listenable: gameState,
            builder: (context, _) {
              if (gameState.incorrectQuestions.isEmpty) {
                return const Center(
                  child: Text('目前沒有答錯的題目，太棒了！👏'),
                );
              }
              return NotebookBackground(
                child: ListView.builder(
                  padding: EdgeInsets.all(16.w),
                  itemCount: gameState.incorrectQuestions.length,
                  itemBuilder: (context, index) {
                    final item = gameState.incorrectQuestions[index];
                    return NotebookCard(
                      backgroundColor: Colors.white,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 8.w, vertical: 3.h),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFBE8E7),
                                  borderRadius: BorderRadius.circular(6.r),
                                ),
                                child: Text(
                                  '待挑戰',
                                  style: TextStyle(
                                    fontSize: 10.sp,
                                    color: const Color(0xFFC00000),
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              const Spacer(),
                              IconButton(
                                icon: CtmSvgIcon(CtmSvgIcons.xCircle,
                                    size: 18.sp, color: Colors.grey),
                                onPressed: () {
                                  setState(() {
                                    gameState.incorrectQuestions
                                        .removeAt(index);
                                  });
                                },
                              ),
                            ],
                          ),
                          SizedBox(height: 6.h),
                          Text(
                            item['question'],
                            style: TextStyle(
                              fontSize: 14.5.sp,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          SizedBox(height: 10.h),
                          Text(
                            '你的答案：${item['wrongAnswer']}',
                            style: const TextStyle(
                                color: Colors.red, fontWeight: FontWeight.w600),
                          ),
                          Text(
                            '正確答案：${item['correctAnswer']}',
                            style: const TextStyle(
                                color: Colors.green,
                                fontWeight: FontWeight.w600),
                          ),
                          SizedBox(height: 8.h),
                          Container(
                            padding: EdgeInsets.all(10.w),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF7F2EA),
                              borderRadius: BorderRadius.circular(10.r),
                            ),
                            child: Text(
                              '白話解析：\n${item['explanation']}',
                              style: TextStyle(
                                  fontSize: 12.sp,
                                  color: AppColors.textSecondary,
                                  height: 1.4),
                            ),
                          ),
                          SizedBox(height: 12.h),
                          ElevatedButton.icon(
                            icon: CtmSvgIcon(CtmSvgIcons.clock,
                                size: 14.sp, color: HomeV2Palette.trustGreen),
                            label: const Text('重新挑戰'),
                            onPressed: () => _rechallengeQuestion(item),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  // 重新挑戰錯題
  void _rechallengeQuestion(Map<String, dynamic> incorrectItem) {
    final String qText = incorrectItem['question'];
    final String correctAns = incorrectItem['correctAnswer'];
    final String explanation = incorrectItem['explanation'] ?? '';
    final List<String> options = List<String>.from(
      incorrectItem['options'] ?? [incorrectItem['wrongAnswer'], correctAns],
    );

    int? tempSelectedIndex;
    bool isAnswered = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 30.h),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    '重新挑戰 🎯',
                    style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.bold,
                        color: HomeV2Palette.trustGreen),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 12.h),
                  Text(
                    qText,
                    style:
                        TextStyle(fontSize: 15.sp, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 14.h),
                  ...List.generate(options.length, (index) {
                    final optTitle = options[index];
                    final isSelected = tempSelectedIndex == index;
                    final isCorrectOpt = isAnswered && optTitle == correctAns;
                    final isWrongOpt = isAnswered && isSelected && optTitle != correctAns;

                    Color cardBg = Colors.white;
                    Color borderCol = const Color(0xFFE8E4DC);
                    if (isCorrectOpt) {
                      cardBg = const Color(0xFFEAF6E2);
                      borderCol = const Color(0xFF9EC979);
                    } else if (isWrongOpt) {
                      cardBg = const Color(0xFFFBE8E7);
                      borderCol = const Color(0xFFE4A29D);
                    } else if (isSelected) {
                      cardBg = const Color(0xFFFFF7E6);
                      borderCol = const Color(0xFFE8B95F);
                    }

                    return Padding(
                      padding: EdgeInsets.only(bottom: 8.h),
                      child: InkWell(
                        onTap: isAnswered
                            ? null
                            : () {
                                setModalState(() {
                                  tempSelectedIndex = index;
                                });
                              },
                        borderRadius: BorderRadius.circular(12.r),
                        child: Container(
                          padding: EdgeInsets.all(12.w),
                          decoration: BoxDecoration(
                            color: cardBg,
                            border: Border.all(color: borderCol, width: 1.2.w),
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                          child: Text(
                            optTitle,
                            style: TextStyle(
                                fontSize: 13.sp, fontWeight: FontWeight.w600),
                          ),
                        ),
                      ),
                    );
                  }),
                  SizedBox(height: 16.h),
                  if (!isAnswered)
                    FilledButton(
                      onPressed: tempSelectedIndex == null
                          ? null
                          : () {
                              setModalState(() {
                                isAnswered = true;
                                final pickedText = options[tempSelectedIndex!];
                                final pickedCorrect = pickedText == correctAns;
                                if (pickedCorrect) {
                                  LearningGameState.instance
                                      .removeIncorrectQuestion(qText);
                                } else {
                                  LearningGameState.instance
                                      .addIncorrectQuestion(
                                    qText,
                                    pickedText,
                                    correctAns,
                                    explanation,
                                    options,
                                  );
                                }
                              });
                            },
                      style: FilledButton.styleFrom(
                          backgroundColor: HomeV2Palette.trustGreen),
                      child: const Text('送出答案'),
                    )
                  else ...[
                    Text(
                      options[tempSelectedIndex!] == correctAns
                          ? '答對了！🎉 經驗值 +15'
                          : '可惜又答錯了，再看一次白話解析吧！',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: options[tempSelectedIndex!] == correctAns
                            ? Colors.green.shade800
                            : Colors.red.shade800,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 12.h),
                    FilledButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('關閉'),
                    )
                  ]
                ],
              ),
            );
          },
        );
      },
    );
  }

  // 開啟儲存的證據清單
  void _openSavedEvidenceLists(LearningGameState gameState) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => Scaffold(
          appBar: AppBar(title: const Text('💾 儲存的證據清單')),
          body: ListenableBuilder(
            listenable: gameState,
            builder: (context, _) {
              if (gameState.savedEvidenceLists.isEmpty) {
                return const Center(
                  child: Text('目前尚未儲存任何證據清單，\n可去「生活工具箱」勾選並儲存！'),
                );
              }
              return NotebookBackground(
                child: ListView.builder(
                  padding: EdgeInsets.all(16.w),
                  itemCount: gameState.savedEvidenceLists.length,
                  itemBuilder: (context, index) {
                    final item = gameState.savedEvidenceLists[index];
                    final checkedItems =
                        List<String>.from(item['checkedItems']);
                    final allItems = List<String>.from(item['allItems']);
                    final String timeStr = DateFormat('yyyy/MM/dd HH:mm')
                        .format(DateTime.parse(item['timestamp']));

                    return NotebookCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  item['title'],
                                  style: TextStyle(
                                    fontSize: 14.5.sp,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                              ),
                              IconButton(
                                icon: CtmSvgIcon(CtmSvgIcons.xCircle,
                                    size: 18.sp, color: Colors.grey),
                                onPressed: () {
                                  gameState.deleteEvidenceList(index);
                                },
                              ),
                            ],
                          ),
                          Text(
                            '儲存時間：$timeStr',
                            style: TextStyle(
                                fontSize: 10.sp, color: AppColors.textMuted),
                          ),
                          SizedBox(height: 8.h),
                          ...allItems.map((name) {
                            final isChecked = checkedItems.contains(name);
                            return Padding(
                              padding: EdgeInsets.symmetric(vertical: 2.h),
                              child: Row(
                                children: [
                                  CtmSvgIcon(
                                    isChecked
                                        ? CtmSvgIcons.star
                                        : CtmSvgIcons.timeline,
                                    color: isChecked
                                        ? HomeV2Palette.trustGreen
                                        : Colors.grey,
                                    size: 18.sp,
                                  ),
                                  SizedBox(width: 8.w),
                                  Text(
                                    name,
                                    style: TextStyle(
                                      fontSize: 12.5.sp,
                                      decoration: isChecked
                                          ? TextDecoration.lineThrough
                                          : null,
                                      color: isChecked
                                          ? AppColors.textMuted
                                          : AppColors.textPrimary,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }),
                          SizedBox(height: 12.h),
                          Row(
                            children: [
                              Text(
                                '進度：${checkedItems.length} / ${allItems.length}',
                                style: TextStyle(
                                    fontSize: 11.sp,
                                    fontWeight: FontWeight.bold,
                                    color: HomeV2Palette.trustGreen),
                              ),
                              const Spacer(),
                              ElevatedButton.icon(
                                icon: CtmSvgIcon(CtmSvgIcons.externalLink,
                                    size: 14.sp, color: Colors.white),
                                label: const Text('導出清單'),
                                onPressed: () {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                          '已成功導出「${item['title']}」清單 PDF 到下載資料夾！'),
                                      backgroundColor: HomeV2Palette.trustGreen,
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  // 開啟收藏與筆記頁面
  void _openSavedNotesPage(LearningGameState gameState) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const SavedNotesPage(),
      ),
    );
  }
}

// 獨立的收藏與筆記查看頁面
class SavedNotesPage extends StatefulWidget {
  const SavedNotesPage({super.key});

  @override
  State<SavedNotesPage> createState() => _SavedNotesPageState();
}

class _SavedNotesPageState extends State<SavedNotesPage> {
  void _navigateToArticle(String articleTitle) async {
    LearningMockArticle? matchedArticle;
    String? matchedCategory;
    String? stepLabel;

    for (final entry in featuredLearningTopics.entries) {
      final topicName = entry.key;
      final topic = entry.value;

      if (topic.heroArticle.title == articleTitle) {
        matchedArticle = topic.heroArticle;
        matchedCategory = topicName;
        break;
      }

      for (final unit in topic.units) {
        if (unit.article.title == articleTitle) {
          matchedArticle = unit.article;
          matchedCategory = topicName;
          stepLabel = unit.stepLabel;
          break;
        }
      }
      if (matchedArticle != null) break;

      for (final related in topic.relatedTopics) {
        if (related.article.title == articleTitle) {
          matchedArticle = related.article;
          matchedCategory = topicName;
          break;
        }
      }
      if (matchedArticle != null) break;

      for (final support in topic.supportItems) {
        if (support.article.title == articleTitle) {
          matchedArticle = support.article;
          matchedCategory = topicName;
          break;
        }
      }
      if (matchedArticle != null) break;
    }

    if (matchedArticle == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Row(
            children: [
              SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
              ),
              SizedBox(width: 12),
              Text('正在從雲端載入文章內容...'),
            ],
          ),
          duration: Duration(seconds: 1),
        ),
      );
      matchedArticle = await SupabaseLearningService.instance.fetchArticleByTitle(articleTitle);
      if (matchedArticle != null) {
        matchedCategory = matchedArticle.category ?? '法律情境';
        if (matchedArticle.stepNumber != null) {
          stepLabel = 'STEP ${matchedArticle.stepNumber}';
        }
      }
    }

    if (matchedArticle != null) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => LearningMockDetailPage(
            article: matchedArticle!,
            unitStepLabel: stepLabel,
            category: matchedCategory,
          ),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('找不到對應的學習單元，可能已移除。')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final gameState = LearningGameState.instance;

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            '收藏的法律金句與筆記',
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
          ),
          centerTitle: true,
          bottom: TabBar(
            labelColor: HomeV2Palette.trustGreen,
            unselectedLabelColor: Colors.grey,
            indicatorColor: HomeV2Palette.trustGreen,
            labelStyle: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.bold),
            tabs: const [
              Tab(text: '金句收藏'),
              Tab(text: '單元收藏'),
              Tab(text: '重點劃記'),
            ],
          ),
        ),
        body: ListenableBuilder(
          listenable: gameState,
          builder: (context, _) {
            return NotebookBackground(
              child: TabBarView(
                children: [
                  _buildQuotesTab(gameState),
                  _buildArticlesTab(gameState),
                  _buildHighlightsTab(gameState),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildQuotesTab(LearningGameState gameState) {
    if (gameState.savedQuotes.isEmpty) {
      return const Center(
        child: Text('目前尚未收藏任何金句。可在學習單元內點擊星星收藏金句！'),
      );
    }
    return ListView.builder(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      itemCount: gameState.savedQuotes.length,
      itemBuilder: (context, index) {
        final item = gameState.savedQuotes[index];
        final String quote = item['quote'] ?? '';
        final String articleTitle = item['articleTitle'] ?? '';
        String timeStr = '';
        if (item['timestamp'] != null) {
          try {
            timeStr = DateFormat('yyyy/MM/dd HH:mm').format(DateTime.parse(item['timestamp']));
          } catch (_) {}
        }

        return NotebookCard(
          margin: EdgeInsets.only(bottom: 10.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      '「$quote」',
                      style: TextStyle(
                        fontSize: 13.5.sp,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                        height: 1.45,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: CtmSvgIcon(
                      CtmSvgIcons.xCircle,
                      size: 18.sp,
                      color: Colors.grey,
                    ),
                    onPressed: () {
                      gameState.toggleQuoteSave(quote, articleTitle);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('已取消收藏該金句！'),
                          duration: Duration(seconds: 1),
                        ),
                      );
                    },
                  ),
                ],
              ),
              SizedBox(height: 8.h),
              Row(
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: () => _navigateToArticle(articleTitle),
                      child: Row(
                        children: [
                          CtmSvgIcon(
                            CtmSvgIcons.bookOpen,
                            size: 14.sp,
                            color: HomeV2Palette.trustGreen,
                          ),
                          SizedBox(width: 4.w),
                          Expanded(
                            child: Text(
                              articleTitle,
                              style: TextStyle(
                                fontSize: 11.sp,
                                color: HomeV2Palette.trustGreen,
                                fontWeight: FontWeight.bold,
                                decoration: TextDecoration.underline,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Text(
                    timeStr,
                    style: TextStyle(
                      fontSize: 10.sp,
                      color: AppColors.textMuted,
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

  Widget _buildArticlesTab(LearningGameState gameState) {
    if (gameState.savedArticles.isEmpty) {
      return const Center(
        child: Text('目前尚未收藏任何學習單元。可在單元頁面右上角點擊書籤進行收藏！'),
      );
    }

    final allMockArticles = [
      learningTopic.heroArticle,
      ...learningTopic.units.map((u) => u.article),
      ...learningTopic.relatedTopics.map((r) => r.article),
      ...learningTopic.supportItems.map((s) => s.article),
    ];

    final savedTitlesList = gameState.savedArticles.toList();

    return ListView.builder(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      itemCount: savedTitlesList.length,
      itemBuilder: (context, index) {
        final title = savedTitlesList[index];
        LearningMockArticle? matchedArticle;
        for (final article in allMockArticles) {
          if (article.title == title) {
            matchedArticle = article;
            break;
          }
        }

        final badge = matchedArticle?.badge ?? '學習單元';
        final summary = matchedArticle?.summary ?? '點選進入學習單元閱讀詳細內容。';
        final readTime = matchedArticle?.readTime ?? '3 分鐘';

        return NotebookCard(
          margin: EdgeInsets.only(bottom: 10.h),
          child: InkWell(
            onTap: () => _navigateToArticle(title),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
                      decoration: BoxDecoration(
                        color: HomeV2Palette.mint,
                        borderRadius: BorderRadius.circular(999.r),
                      ),
                      child: Text(
                        badge,
                        style: TextStyle(
                          fontSize: 10.sp,
                          fontWeight: FontWeight.bold,
                          color: HomeV2Palette.trustGreen,
                        ),
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      icon: CtmSvgIcon(
                        CtmSvgIcons.bookmark,
                        size: 18.sp,
                        color: HomeV2Palette.trustGreen,
                      ),
                      onPressed: () {
                        gameState.toggleArticleSave(title);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('已取消收藏本單元！'),
                            duration: Duration(seconds: 1),
                          ),
                        );
                      },
                    ),
                  ],
                ),
                SizedBox(height: 8.h),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14.5.sp,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                SizedBox(height: 6.h),
                Text(
                  summary,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: AppColors.textSecondary,
                  ),
                ),
                SizedBox(height: 8.h),
                Row(
                  children: [
                    CtmSvgIcon(
                      CtmSvgIcons.clock,
                      size: 12.sp,
                      color: Colors.grey,
                    ),
                    SizedBox(width: 4.w),
                    Text(
                      readTime,
                      style: TextStyle(
                        fontSize: 11.sp,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildHighlightsTab(LearningGameState gameState) {
    if (gameState.savedHighlights.isEmpty) {
      return const Center(
        child: Text('目前尚未劃記任何重點。可在學習單元正文中選取文字並點擊「劃記重點 ✍️」！'),
      );
    }
    return ListView.builder(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      itemCount: gameState.savedHighlights.length,
      itemBuilder: (context, index) {
        final item = gameState.savedHighlights[index];
        final String highlight = item['highlight'] ?? '';
        final String articleTitle = item['articleTitle'] ?? '';
        String timeStr = '';
        if (item['timestamp'] != null) {
          try {
            timeStr = DateFormat('yyyy/MM/dd HH:mm').format(DateTime.parse(item['timestamp']));
          } catch (_) {}
        }

        return NotebookCard(
          margin: EdgeInsets.only(bottom: 10.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
                      decoration: BoxDecoration(
                        color: Colors.yellow.withValues(alpha: 0.45),
                        borderRadius: BorderRadius.circular(4.r),
                      ),
                      child: Text(
                        highlight,
                        style: TextStyle(
                          fontSize: 13.5.sp,
                          fontWeight: FontWeight.w600,
                          color: Colors.black,
                          height: 1.45,
                        ),
                      ),
                    ),
                  ),
                  IconButton(
                    icon: CtmSvgIcon(
                      CtmSvgIcons.xCircle,
                      size: 18.sp,
                      color: Colors.grey,
                    ),
                    onPressed: () {
                      gameState.removeHighlight(index);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('已刪除此劃記重點！'),
                          duration: Duration(seconds: 1),
                        ),
                      );
                    },
                  ),
                ],
              ),
              SizedBox(height: 10.h),
              Row(
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: () => _navigateToArticle(articleTitle),
                      child: Row(
                        children: [
                          CtmSvgIcon(
                            CtmSvgIcons.bookOpen,
                            size: 14.sp,
                            color: HomeV2Palette.trustGreen,
                          ),
                          SizedBox(width: 4.w),
                          Expanded(
                            child: Text(
                              articleTitle,
                              style: TextStyle(
                                fontSize: 11.sp,
                                color: HomeV2Palette.trustGreen,
                                fontWeight: FontWeight.bold,
                                decoration: TextDecoration.underline,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Text(
                    timeStr,
                    style: TextStyle(
                      fontSize: 10.sp,
                      color: AppColors.textMuted,
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
}

class _WisdomTreePainter extends CustomPainter {
  _WisdomTreePainter({
    required this.level,
    required this.completedUnits,
    required this.animationValue,
    required this.treeScale,
    required this.showParticles,
  });

  final int level;
  final int completedUnits;
  final double animationValue; // 0.0 to 1.0
  final double treeScale;
  final bool showParticles;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;

    // 1. 繪製天空與陽光背景
    final skyPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Color(0xFFE2F0FD),
          Color(0xFFFFF9E6),
        ],
      ).createShader(rect);
    canvas.drawRect(rect, skyPaint);

    // 太陽
    final sunPaint = Paint()
      ..color = const Color(0xFFFFE699).withValues(alpha: 0.8)
      ..style = PaintingStyle.fill;
    final sunGlowPaint = Paint()
      ..color = const Color(0xFFFFD966).withValues(alpha: 0.3)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 15);
    
    canvas.drawCircle(Offset(size.width - 40, 40), 25, sunGlowPaint);
    canvas.drawCircle(Offset(size.width - 40, 40), 18, sunPaint);

    // 雲朵 (微風吹拂移動)
    final cloudPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.9)
      ..style = PaintingStyle.fill;
    final cloudOffset = animationValue * size.width;
    _drawCloud(canvas, Offset((cloudOffset - 100) % (size.width + 120) - 60, 25.0), cloudPaint);
    _drawCloud(canvas, Offset(((cloudOffset * 0.5) + 120) % (size.width + 120) - 60, 45.0), cloudPaint);

    // 2. 繪製底部綠色草地
    final grassPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Color(0xFF9DD49D),
          Color(0xFF7CB87C),
        ],
      ).createShader(Rect.fromLTWH(0, size.height - 40, size.width, 40));
    final grassPath = Path()
      ..moveTo(0, size.height - 15)
      ..quadraticBezierTo(size.width * 0.4, size.height - 35, size.width * 0.75, size.height - 20)
      ..quadraticBezierTo(size.width * 0.9, size.height - 15, size.width, size.height - 25)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
    canvas.drawPath(grassPath, grassPaint);

    // 3. 智慧之樹主體 (以 center 為基準)
    final treeCenter = Offset(size.width / 2, size.height - 22);
    canvas.save();
    canvas.translate(treeCenter.dx, treeCenter.dy);
    canvas.scale(treeScale); // 點擊澆水彈跳縮放

    // 依等級設定樹幹寬與高
    final double trunkWidth = 4.0 + (level * 1.2);
    final double trunkHeight = 25.0 + (level * 5.0);

    // 繪製樹幹 (帶有分支)
    final trunkPaint = Paint()
      ..color = const Color(0xFF8B5A2B)
      ..style = PaintingStyle.fill;
    
    // 樹根
    if (level >= 7) {
      final rootPath = Path()
        ..moveTo(-trunkWidth * 1.5, 2)
        ..lineTo(trunkWidth * 1.5, 2)
        ..quadraticBezierTo(0, -5, 0, -trunkHeight)
        ..close();
      canvas.drawPath(rootPath, trunkPaint);
    }

    // 主樹幹
    final trunkRect = Rect.fromLTWH(-trunkWidth / 2, -trunkHeight, trunkWidth, trunkHeight);
    canvas.drawRRect(RRect.fromRectAndRadius(trunkRect, const Radius.circular(2)), trunkPaint);

    // 樹枝分岔 (Level 3 以上)
    if (level >= 3) {
      final branchPaint = Paint()
        ..color = const Color(0xFF8B5A2B)
        ..strokeWidth = trunkWidth * 0.6
        ..strokeCap = StrokeCap.round
        ..style = PaintingStyle.stroke;
      
      // 左樹枝
      canvas.drawLine(
        Offset(-trunkWidth * 0.1, -trunkHeight * 0.5),
        Offset(-trunkWidth * 1.6, -trunkHeight * 0.78),
        branchPaint,
      );
      // 右樹枝
      canvas.drawLine(
        Offset(trunkWidth * 0.1, -trunkHeight * 0.6),
        Offset(trunkWidth * 1.8, -trunkHeight * 0.82),
        branchPaint,
      );
    }

    // 4. 繪製樹冠 (圓形葉子球，隨微風輕微擺晃)
    final double windSway = math.sin(animationValue * 2 * math.pi) * 1.8;
    canvas.save();
    canvas.translate(0, -trunkHeight);
    canvas.rotate(windSway * math.pi / 180); // 隨風微擺

    final double canopyRadius = 15.0 + (level * 3.8);
    final leafPaint = Paint()
      ..style = PaintingStyle.fill;

    // 依等級繪製多層漸層葉子球
    final List<Offset> leafOffsets = [];
    if (level == 1) {
      leafOffsets.add(const Offset(0, -5));
    } else if (level <= 3) {
      leafOffsets.addAll([
        const Offset(0, -8),
        const Offset(-10, 0),
        const Offset(10, 0),
      ]);
    } else if (level <= 6) {
      leafOffsets.addAll([
        const Offset(0, -15),
        const Offset(-18, -5),
        const Offset(18, -5),
        const Offset(-10, 10),
        const Offset(10, 10),
      ]);
    } else {
      leafOffsets.addAll([
        const Offset(0, -28),
        const Offset(-28, -14),
        const Offset(28, -14),
        const Offset(-32, 10),
        const Offset(32, 10),
        const Offset(-15, -15),
        const Offset(15, -15),
        const Offset(0, 5),
      ]);
    }

    for (int i = 0; i < leafOffsets.length; i++) {
      final offset = leafOffsets[i];
      // 漸層色調：深淺交錯
      final isTop = offset.dy < -10;
      final Color leafColor;
      if (isTop) {
        leafColor = const Color(0xFF6EBE78);
      } else {
        leafColor = i % 2 == 0 ? const Color(0xFF4FA65A) : const Color(0xFF388E44);
      }
      
      leafPaint.shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [leafColor, leafColor.withRed(10).withGreen(100)],
      ).createShader(Rect.fromCircle(center: offset, radius: canopyRadius));

      canvas.drawCircle(offset, canopyRadius, leafPaint);
    }

    // 5. 智慧之花 (Level 5 ~ 6) 或 智慧之果 (Level 7 ~ 10)
    if (level >= 5 && level <= 6) {
      // 智慧花苞 (粉白小點)
      final flowerPaint = Paint()
        ..color = const Color(0xFFFFF0F5)
        ..style = PaintingStyle.fill;
      final flowerCorePaint = Paint()
        ..color = const Color(0xFFFFB6C1)
        ..style = PaintingStyle.fill;

      for (int i = 0; i < leafOffsets.length; i++) {
        final flowerPos = leafOffsets[i] + Offset(canopyRadius * 0.4 * math.sin(i), -canopyRadius * 0.4);
        canvas.drawCircle(flowerPos, 3.5, flowerPaint);
        canvas.drawCircle(flowerPos, 1.8, flowerCorePaint);
      }
    } else if (level >= 7) {
      // 智慧之果 (金色小果實)
      final fruitPaint = Paint()
        ..color = const Color(0xFFFFD700)
        ..style = PaintingStyle.fill;
      final fruitHighlightPaint = Paint()
        ..color = Colors.white
        ..style = PaintingStyle.fill;

      // 果實掛載位置
      for (int i = 0; i < (level - 5).clamp(2, 6); i++) {
        final offsetIdx = i % leafOffsets.length;
        final fruitPos = leafOffsets[offsetIdx] + Offset(canopyRadius * 0.5 * math.sin(i * 1.5), canopyRadius * 0.3);
        canvas.drawCircle(fruitPos, 4.5, fruitPaint);
        // 高光點
        canvas.drawCircle(fruitPos + const Offset(-1.2, -1.2), 1.2, fruitHighlightPaint);
      }
    }

    // 6. 微觀綠葉 (數量 = completedUnits)
    final singleLeafPaint = Paint()
      ..color = const Color(0xFF2E7D32)
      ..style = PaintingStyle.fill;
    
    for (int i = 0; i < completedUnits; i++) {
      // 圍繞樹冠均勻分布或輕微飄落
      final double angle = (i * 2.4) + (animationValue * 0.1);
      final double dist = canopyRadius * 1.1 + (i % 3) * 3.0;
      final double leafX = dist * math.cos(angle);
      final double leafY = dist * math.sin(angle) - 5;
      
      canvas.save();
      canvas.translate(leafX, leafY);
      canvas.rotate(angle);
      canvas.drawOval(const Rect.fromLTRB(-3.5, -2, 3.5, 2), singleLeafPaint);
      canvas.restore();
    }

    canvas.restore(); // 結束樹冠擺動
    canvas.restore(); // 結束樹整體縮放

    // 7. 繪製小孩跑跳動畫
    // 依等級決定小孩人數
    final int kidsCount;
    if (level == 1 || level == 2) {
      kidsCount = 1;
    } else if (level == 3 || level == 4) {
      kidsCount = 2;
    } else if (level == 5 || level == 6) {
      kidsCount = 3;
    } else if (level == 7 || level == 8) {
      kidsCount = 4;
    } else {
      kidsCount = 5;
    }

    for (int i = 0; i < kidsCount; i++) {
      _drawChild(canvas, size, i, animationValue);
    }

    // 8. 澆水動畫粒子 (showParticles = true 時渲染)
    if (showParticles) {
      final particlePaint = Paint()
        ..color = const Color(0xFFFFD700).withValues(alpha: 0.8)
        ..style = PaintingStyle.fill;
      for (int i = 0; i < 8; i++) {
        // 從樹中心向外擴散的金色光斑
        final double angle = i * math.pi / 4 + (animationValue * 4);
        final double dist = 35.0 + 40.0 * (animationValue % 0.5) * 2;
        final double px = treeCenter.dx + dist * math.cos(angle);
        final double py = treeCenter.dy - trunkHeight - 20 + dist * math.sin(angle);
        canvas.drawCircle(Offset(px, py), 2.5 * (1.0 - (dist / 75.0)), particlePaint);
      }
    }
  }

  // 雲朵位置微調 helper
  double get _cloudYOffset => 0.0;
  double get _cloudXOffset => 0.0;

  void _drawCloud(Canvas canvas, Offset pos, Paint paint) {
    canvas.drawCircle(pos, 15, paint);
    canvas.drawCircle(pos + const Offset(12, -4), 12, paint);
    canvas.drawCircle(pos + const Offset(-12, -2), 10, paint);
    canvas.drawCircle(pos + const Offset(22, 2), 9, paint);
  }

  void _drawChild(Canvas canvas, Size size, int index, double anim) {
    // 每個小孩的衣服顏色
    final List<Color> clothesColors = [
      const Color(0xFF3F8FDF), // 藍
      const Color(0xFFDF5F3F), // 紅
      const Color(0xFFDFBF3F), // 黃
      const Color(0xFF9F3FDF), // 紫
      const Color(0xFF3FDFBF), // 青
    ];

    final clothesColor = clothesColors[index % clothesColors.length];

    if (index == 0) {
      // 第一個小孩：Level 1 起解鎖，坐在樹底下看書的小男孩 (安靜坐在樹左側)
      final Offset pos = Offset(size.width / 2 - 40, size.height - 22);
      _drawSittingChild(canvas, pos, clothesColor);
    } else if (index == 1) {
      // 第二個小孩：Level 3 起解鎖，在右側跳躍的女孩
      final double sway = math.sin(anim * 4 * math.pi);
      final Offset pos = Offset(size.width / 2 + 45, size.height - 24 + sway.abs() * -6);
      _drawJumpingChild(canvas, pos, clothesColor, sway);
    } else if (index == 2) {
      // 第三個小孩：Level 5 起解鎖，在左側快樂跑動的小孩
      // x座標在 [size.width/2 - 120, size.width/2 - 50] 之間移動
      final double progress = (anim * 2) % 2; // 0 to 2
      final double xRange = 60.0;
      final double direction = progress > 1 ? -1 : 1;
      final double relativeProgress = progress > 1 ? progress - 1 : progress;
      
      final double childX = direction > 0
          ? (size.width / 2 - 110) + relativeProgress * xRange
          : (size.width / 2 - 50) - relativeProgress * xRange;

      final double bob = (math.sin(anim * 6 * math.pi)).abs() * -4.0;
      final Offset pos = Offset(childX, size.height - 23 + bob);
      _drawRunningChild(canvas, pos, clothesColor, direction > 0, anim);
    } else if (index == 3) {
      // 第四個小孩：Level 7 起解鎖，在右側大範圍奔跑的小長腿
      // x座標在 [size.width/2 + 50, size.width/2 + 130] 之間跑動
      final double progress = (anim * 1.5 + 0.5) % 2;
      final double xRange = 70.0;
      final double direction = progress > 1 ? -1 : 1;
      final double relativeProgress = progress > 1 ? progress - 1 : progress;

      final double childX = direction > 0
          ? (size.width / 2 + 55) + relativeProgress * xRange
          : (size.width / 2 + 125) - relativeProgress * xRange;

      final double bob = (math.sin(anim * 5 * math.pi)).abs() * -4.5;
      final Offset pos = Offset(childX, size.height - 23 + bob);
      _drawRunningChild(canvas, pos, clothesColor, direction > 0, anim + 0.25);
    } else {
      // 第五個小孩：Level 9 起解鎖，在中右側開心地抱著氣球手舞足蹈的小孩
      final double sway = math.sin(anim * 3 * math.pi);
      final Offset pos = Offset(size.width / 2 + 85 + sway * 8, size.height - 25);
      _drawDancingChild(canvas, pos, clothesColor, sway);
    }
  }

  void _drawSittingChild(Canvas canvas, Offset pos, Color clothesColor) {
    final headPaint = Paint()..color = const Color(0xFFFFD5B3)..style = PaintingStyle.fill;
    final hairPaint = Paint()..color = const Color(0xFF333333)..style = PaintingStyle.fill;
    final clothesPaint = Paint()..color = clothesColor..style = PaintingStyle.fill;
    final pantsPaint = Paint()..color = const Color(0xFF4F5B66)..style = PaintingStyle.fill;
    final bookPaint = Paint()..color = const Color(0xFF4A90E2)..style = PaintingStyle.fill;
    final pagePaint = Paint()..color = Colors.white..style = PaintingStyle.fill;

    // 身體/坐姿
    canvas.drawRect(Rect.fromLTWH(pos.dx - 5, pos.dy - 10, 10, 8), clothesPaint);
    // 腿/屈膝
    canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(pos.dx - 8, pos.dy - 3, 14, 4), const Radius.circular(2)), pantsPaint);

    // 頭部
    canvas.drawCircle(pos + const Offset(0, -14), 5.5, headPaint);
    // 頭髮
    final hairPath = Path()
      ..addArc(Rect.fromCircle(center: pos + const Offset(0, -14), radius: 5.8), -math.pi, math.pi)
      ..lineTo(pos.dx + 5.8, pos.dy - 14)
      ..lineTo(pos.dx + 3, pos.dy - 12)
      ..lineTo(pos.dx - 3, pos.dy - 12)
      ..lineTo(pos.dx - 5.8, pos.dy - 14)
      ..close();
    canvas.drawPath(hairPath, hairPaint);

    // 小藍書
    canvas.drawRect(Rect.fromLTWH(pos.dx - 2, pos.dy - 10, 8, 5), bookPaint);
    canvas.drawRect(Rect.fromLTWH(pos.dx, pos.dy - 9, 6, 3), pagePaint);
  }

  void _drawJumpingChild(Canvas canvas, Offset pos, Color clothesColor, double sway) {
    final headPaint = Paint()..color = const Color(0xFFFFD5B3)..style = PaintingStyle.fill;
    final hairPaint = Paint()..color = const Color(0xFFC68E17)..style = PaintingStyle.fill; // 橘金髮
    final clothesPaint = Paint()..color = clothesColor..style = PaintingStyle.fill;
    final limbPaint = Paint()..color = const Color(0xFFFFD5B3)..strokeWidth = 2..strokeCap = StrokeCap.round..style = PaintingStyle.stroke;

    // 身體
    canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(pos.dx - 4, pos.dy - 10, 8, 9), const Radius.circular(2)), clothesPaint);

    // 頭部
    canvas.drawCircle(pos + const Offset(0, -15), 5.5, headPaint);
    // 頭髮 (雙馬尾/小辮子)
    canvas.drawCircle(pos + const Offset(-5.5, -16), 2, hairPaint);
    canvas.drawCircle(pos + const Offset(5.5, -16), 2, hairPaint);
    canvas.drawCircle(pos + const Offset(0, -16.5), 5.8, hairPaint);

    // 手部 (V字揮舞)
    canvas.drawLine(Offset(pos.dx - 4, pos.dy - 8), Offset(pos.dx - 9, pos.dy - 14 + sway), limbPaint);
    canvas.drawLine(Offset(pos.dx + 4, pos.dy - 8), Offset(pos.dx + 9, pos.dy - 14 - sway), limbPaint);

    // 腿部 (懸空/分開)
    canvas.drawLine(Offset(pos.dx - 2, pos.dy - 1), Offset(pos.dx - 5, pos.dy + 3), limbPaint);
    canvas.drawLine(Offset(pos.dx + 2, pos.dy - 1), Offset(pos.dx + 5, pos.dy + 3), limbPaint);
  }

  void _drawRunningChild(Canvas canvas, Offset pos, Color clothesColor, bool facingRight, double anim) {
    final headPaint = Paint()..color = const Color(0xFFFFD5B3)..style = PaintingStyle.fill;
    final hairPaint = Paint()..color = const Color(0xFF4A4A4A)..style = PaintingStyle.fill;
    final clothesPaint = Paint()..color = clothesColor..style = PaintingStyle.fill;
    final limbPaint = Paint()..color = const Color(0xFFFFD5B3)..strokeWidth = 2.2..strokeCap = StrokeCap.round..style = PaintingStyle.stroke;

    final double stepPhase = math.sin(anim * 5 * math.pi);

    // 身體 (傾斜奔跑)
    canvas.save();
    canvas.translate(pos.dx, pos.dy);
    canvas.rotate((facingRight ? 8.0 : -8.0) * math.pi / 180);

    canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(-4, -10, 8, 9), const Radius.circular(2)), clothesPaint);

    // 頭部
    canvas.drawCircle(const Offset(0, -15), 5.5, headPaint);
    canvas.drawCircle(const Offset(0, -16.5), 5.8, hairPaint);

    // 手臂 (擺動)
    final double leftArmAngle = stepPhase * 10;
    final double rightArmAngle = -stepPhase * 10;
    canvas.drawLine(const Offset(-4, -8), Offset(-4 + (facingRight ? -4 : 4) + leftArmAngle * 0.2, -4), limbPaint);
    canvas.drawLine(const Offset(4, -8), Offset(4 + (facingRight ? 4 : -4) + rightArmAngle * 0.2, -4), limbPaint);

    // 雙腿 (跑動剪刀步)
    final double frontLegSway = stepPhase * 6;
    final double backLegSway = -stepPhase * 6;
    canvas.drawLine(const Offset(-2, -1), Offset(-4 + backLegSway * 0.5, 4), limbPaint);
    canvas.drawLine(const Offset(2, -1), Offset(4 + frontLegSway * 0.5, 4), limbPaint);

    canvas.restore();
  }

  void _drawDancingChild(Canvas canvas, Offset pos, Color clothesColor, double sway) {
    final headPaint = Paint()..color = const Color(0xFFFFD5B3)..style = PaintingStyle.fill;
    final hairPaint = Paint()..color = const Color(0xFF8B5A2B)..style = PaintingStyle.fill; // 棕髮
    final clothesPaint = Paint()..color = clothesColor..style = PaintingStyle.fill;
    final limbPaint = Paint()..color = const Color(0xFFFFD5B3)..strokeWidth = 2..strokeCap = StrokeCap.round..style = PaintingStyle.stroke;
    final stringPaint = Paint()..color = Colors.grey..strokeWidth = 0.8..style = PaintingStyle.stroke;
    final balloonPaint = Paint()..color = const Color(0xFFFF6B6B)..style = PaintingStyle.fill;

    // 身體
    canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(pos.dx - 4, pos.dy - 10, 8, 9), const Radius.circular(2)), clothesPaint);

    // 頭部
    canvas.drawCircle(pos + const Offset(0, -15), 5.5, headPaint);
    canvas.drawCircle(pos + const Offset(0, -16.2), 5.8, hairPaint);

    // 左手臂捧著氣球線
    canvas.drawLine(Offset(pos.dx - 4, pos.dy - 8), Offset(pos.dx - 10, pos.dy - 12), limbPaint);
    // 右手臂上舉
    canvas.drawLine(Offset(pos.dx + 4, pos.dy - 8), Offset(pos.dx + 9, pos.dy - 14 + sway * 3), limbPaint);

    // 氣球線與紅色氣球
    final Offset balloonPos = pos + Offset(-15, -35 + sway * 2);
    canvas.drawLine(Offset(pos.dx - 10, pos.dy - 12), balloonPos, stringPaint);
    canvas.drawCircle(balloonPos, 7.5, balloonPaint);
    // 氣球小尾巴三角形
    final tailPath = Path()
      ..moveTo(balloonPos.dx, balloonPos.dy + 7.5)
      ..lineTo(balloonPos.dx - 2, balloonPos.dy + 10)
      ..lineTo(balloonPos.dx + 2, balloonPos.dy + 10)
      ..close();
    canvas.drawPath(tailPath, balloonPaint);

    // 雙腿
    canvas.drawLine(Offset(pos.dx - 2, pos.dy - 1), Offset(pos.dx - 4 + sway * 2, pos.dy + 4), limbPaint);
    canvas.drawLine(Offset(pos.dx + 2, pos.dy - 1), Offset(pos.dx + 4 - sway * 2, pos.dy + 4), limbPaint);
  }

  @override
  bool shouldRepaint(covariant _WisdomTreePainter oldDelegate) {
    return oldDelegate.level != level ||
        oldDelegate.completedUnits != completedUnits ||
        oldDelegate.animationValue != animationValue ||
        oldDelegate.treeScale != treeScale ||
        oldDelegate.showParticles != showParticles;
  }
}
