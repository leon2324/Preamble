import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter/services.dart';
import 'package:lawapp/app/app_state.dart';
import 'package:lawapp/components/home/v2/home_v2_palette.dart';
import 'package:lawapp/components/shared/mvp_state_widgets.dart';
import 'package:lawapp/data/law_assistant/guest_law_assistant_usage.dart';
import 'package:lawapp/data/law_assistant/law_assistant_models.dart';
import 'package:lawapp/data/law_assistant/law_assistant_repository.dart';
import 'package:lawapp/data/mock_data/learning/learning_mock_data.dart';
import 'package:lawapp/pages/learning/learning_mock_detail_page.dart';
import 'package:lawapp/pages/learning/statute_database_page.dart';
import 'package:lawapp/theme/app_colors.dart';

// 導入遊戲化、手寫本美學與自訂 SVG 圖示
import 'package:lawapp/data/learning/learning_game_state.dart';
import 'package:lawapp/pages/learning/widgets/notebook_aesthetics.dart';
import 'package:lawapp/pages/learning/widgets/achievement_room.dart';
import 'package:lawapp/pages/learning/widgets/mock_court_challenge.dart';
import 'package:lawapp/features/case_time_machine/widgets/case_time_machine_svg_icon.dart';
import 'package:lawapp/data/learning/supabase_learning_service.dart';

import 'dart:async';
import 'dart:ui' show ImageFilter;

part 'law_assistant/law_assistant_palette.dart';
part 'law_assistant/law_assistant_search_page.dart';
part 'law_assistant/law_assistant_prototype_widgets.dart';
part 'law_assistant/law_assistant_chat_page.dart';

/// 學習頁重構：單一 ListView 滾動大框架，結合方格紙手寫筆記本美學，全面採用 SVG 圖示
class KnowLawPage extends StatefulWidget {
  const KnowLawPage({super.key});

  @override
  KnowLawPageState createState() => KnowLawPageState();
}

class KnowLawPageState extends State<KnowLawPage> {
  static const String _rentCourseHeroAsset =
      'assets/images/learning/rent_course_room.png';
  static const List<_LearningTopicOption> _featuredTopics = [
    _LearningTopicOption('租屋糾紛', '主修中', true),
    _LearningTopicOption('車禍事故', '看全部', false),
    _LearningTopicOption('職場權益', '看全部', false),
    _LearningTopicOption('網購消費', '看全部', false),
    _LearningTopicOption('個資隱私', '看全部', false),
  ];

  int _selectedTabIndex = 0; // 0: 法學課堂, 1: 生活工具箱

  void _openArticle(LearningMockArticle article) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (__) => LearningMockDetailPage(article: article),
      ),
    );
  }

  void _openUnitStep(LearningTopicUnit unit) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (__) => LearningMockDetailPage(
          article: unit.article,
          unitStepLabel: unit.stepLabel,
        ),
      ),
    );
  }

  void _openStatuteDatabase({String initialQuery = ''}) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (__) => StatuteDatabasePage(initialQuery: initialQuery),
      ),
    );
  }

  void _openAchievementRoom() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (__) => const AchievementRoomPage(),
      ),
    );
  }

  void _showTopicComingSoon(String topic) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text('$topic 專題正在整理中，之後會加入主修課。'),
          backgroundColor: HomeV2Palette.trustGreen,
        ),
      );
  }

  void _openLearningTopicCatalog({String? initialCategory}) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        final isDark = Theme.of(sheetContext).brightness == Brightness.dark;
        return _LearningTopicCatalogBottomSheet(
          initialCategory: initialCategory,
          isDark: isDark,
          onArticleTap: _openArticle,
        );
      },
    );
  }
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final gameState = LearningGameState.instance;

    return Scaffold(
      body: ListenableBuilder(
        listenable: gameState,
        builder: (context, _) {
          return NotebookBackground(
            child: SafeArea(
              child: ListView(
                padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 80.h),
                physics: const BouncingScrollPhysics(),
                children: [
                  // 1. 頂部自訂 Header列
                  _buildHeaderRow(isDark, gameState),
                  SizedBox(height: 12.h),

                  // 2. 智慧小法助輪播提問氣泡
                  _AssistantPromptBubble(
                    onMascotTap: _openAchievementRoom,
                  ),
                  SizedBox(height: 16.h),

                  // 3. 左右切換分頁 Tab 按鈕（單一 Scroll 結構下的切換按鈕）
                  _buildTabSwitcher(isDark),
                  SizedBox(height: 16.h),

                  // 4. 根據切換選取的 Tab 渲染不同內容
                  if (_selectedTabIndex == 0)
                    ..._buildClassroomItems(isDark, gameState)
                  else
                    ..._buildToolkitItems(isDark, gameState),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // 1) 頂部自訂 Header 列
  Widget _buildHeaderRow(bool isDark, LearningGameState gameState) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '學堂與工具箱',
                style: TextStyle(
                  fontSize: 24.sp,
                  fontWeight: FontWeight.w900,
                  color: AppColors.textPrimary,
                  height: 1.2,
                ),
              ),
              SizedBox(height: 2.h),
              Text(
                '手寫法律筆記本 • 用情境學常識',
                style: TextStyle(
                  fontSize: 11.sp,
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        // 吉祥物頭像按鈕，點擊開啟成就室
        GestureDetector(
          onTap: _openAchievementRoom,
          child: Container(
            width: 40.w,
            height: 40.w,
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF26303D) : const Color(0xFFF3EDE0),
              shape: BoxShape.circle,
              border: Border.all(
                color:
                    isDark ? const Color(0xFF354454) : const Color(0xFFE4D9C4),
                width: 1.5.w,
              ),
            ),
            child: Center(
              child: Text(
                gameState.mascotExpression,
                style: TextStyle(fontSize: 22.sp),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // 2) 左右切換分頁按鈕
  Widget _buildTabSwitcher(bool isDark) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF161C23) : const Color(0xFFEFECE6),
        borderRadius: BorderRadius.circular(12.r),
      ),
      padding: EdgeInsets.all(4.w),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _selectedTabIndex = 0),
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 10.h),
                decoration: BoxDecoration(
                  color: _selectedTabIndex == 0
                      ? (isDark ? const Color(0xFF232B35) : Colors.white)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(10.r),
                  border: _selectedTabIndex == 0
                      ? Border.all(
                          color: isDark
                              ? const Color(0xFF2D3845)
                              : const Color(0xFFECE6DB),
                          width: 1.2.w,
                        )
                      : null,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CtmSvgIcon(
                      CtmSvgIcons.bookOpen,
                      size: 16.sp,
                      color: _selectedTabIndex == 0
                          ? HomeV2Palette.trustGreen
                          : AppColors.textSecondary,
                    ),
                    SizedBox(width: 6.w),
                    Text(
                      '法學課堂',
                      style: TextStyle(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.bold,
                        color: _selectedTabIndex == 0
                            ? HomeV2Palette.trustGreen
                            : AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _selectedTabIndex = 1),
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 10.h),
                decoration: BoxDecoration(
                  color: _selectedTabIndex == 1
                      ? (isDark ? const Color(0xFF232B35) : Colors.white)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(10.r),
                  border: _selectedTabIndex == 1
                      ? Border.all(
                          color: isDark
                              ? const Color(0xFF2D3845)
                              : const Color(0xFFECE6DB),
                          width: 1.2.w,
                        )
                      : null,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CtmSvgIcon(
                      CtmSvgIcons.gavel,
                      size: 16.sp,
                      color: _selectedTabIndex == 1
                          ? HomeV2Palette.trustGreen
                          : AppColors.textSecondary,
                    ),
                    SizedBox(width: 6.w),
                    Text(
                      '生活工具箱',
                      style: TextStyle(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.bold,
                        color: _selectedTabIndex == 1
                            ? HomeV2Palette.trustGreen
                            : AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 3) 法學課堂的列表項目
  List<Widget> _buildClassroomItems(bool isDark, LearningGameState gameState) {
    final rentUnits = learningTopic.units.take(4).toList(growable: false);
    final completedRentCount = rentUnits
        .where((unit) => gameState.completedSteps.contains(unit.stepLabel))
        .length;
    final rentProgress = completedRentCount / rentUnits.length;

    return [
      // 1. 公民法律小擂台入口 Banner
      NotebookCard(
        hasBookmark: true,
        bookmarkColor: const Color(0xFFE8B95F),
        backgroundColor:
            isDark ? const Color(0xFF202A24) : const Color(0xFFFFFDF5),
        child: Row(
          children: [
            Container(
              width: 40.w,
              height: 40.w,
              decoration: const BoxDecoration(
                color: Color(0xFFFFD46A),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: CtmSvgIcon(
                  CtmSvgIcons.award,
                  size: 20.sp,
                  color: const Color(0xFF6B4B14),
                ),
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '公民法律小擂台',
                    style: TextStyle(
                      fontSize: 14.5.sp,
                      fontWeight: FontWeight.w900,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    '法官模擬案件挑戰，連對解鎖專屬徽章！',
                    style: TextStyle(
                      fontSize: 10.5.sp,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                      builder: (__) => const MockCourtChallengePage()),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: HomeV2Palette.trustGreen,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.r)),
                padding: EdgeInsets.symmetric(horizontal: 14.w),
              ),
              child: const Text('開始挑戰'),
            ),
          ],
        ),
      ),

      _buildFeaturedTopicSwitcher(isDark),
      SizedBox(height: 12.h),

      _buildMainCourseCard(
        isDark: isDark,
        gameState: gameState,
        rentUnits: rentUnits,
        completedRentCount: completedRentCount,
        rentProgress: rentProgress,
      ),

      // 3. 混合排列的卡片：插圖故事卡片
      NotebookCard(
        hasPaperClip: true,
        backgroundColor:
            isDark ? const Color(0xFF242C36) : const Color(0xFFEAF0F8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CtmSvgIcon(
                  CtmSvgIcons.star,
                  size: 20.sp,
                  color: const Color(0xFF3F7FBF),
                ),
                SizedBox(width: 8.w),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.6),
                    borderRadius: BorderRadius.circular(4.r),
                  ),
                  child: Text(
                    '車禍防護課',
                    style: TextStyle(
                        fontSize: 9.5.sp,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF1F4E87)),
                  ),
                ),
              ],
            ),
            SizedBox(height: 10.h),
            Text(
              '車禍被撞了！第一時間該拍照還是移車？',
              style: TextStyle(
                fontSize: 14.5.sp,
                fontWeight: FontWeight.w900,
                color: AppColors.textPrimary,
              ),
            ),
            SizedBox(height: 6.h),
            Text(
              '道路事故現場的黃金三步驟：安全防範、拍照存證、定位通報。答對測驗可解鎖車禍徽章！',
              style: TextStyle(
                  fontSize: 12.sp, height: 1.4, color: AppColors.textSecondary),
            ),
            SizedBox(height: 10.h),
            ElevatedButton.icon(
              icon: CtmSvgIcon(CtmSvgIcons.chevronRight,
                  size: 14.sp, color: Colors.white),
              label: const Text('研讀此案例'),
              onPressed: () =>
                  _openArticle(learningTopic.supportItems[2].article),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF3F7FBF),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.r)),
              ),
            ),
          ],
        ),
      ),

      // 4. 混合排列的卡片：模擬 LINE 對話圖卡
      NotebookCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CtmSvgIcon(
                  CtmSvgIcons.message,
                  size: 16.sp,
                  color: HomeV2Palette.trustGreen,
                ),
                SizedBox(width: 8.w),
                Text(
                  '模擬對話故事',
                  style: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.bold,
                      color: HomeV2Palette.trustGreen),
                ),
              ],
            ),
            SizedBox(height: 10.h),
            // LINE 對話泡泡
            Container(
              padding: EdgeInsets.all(12.w),
              decoration: BoxDecoration(
                color:
                    isDark ? const Color(0xFF1E252D) : const Color(0xFFF7F7F7),
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Column(
                children: [
                  _buildChatBubble(
                    sender: '房東 👩‍🦳',
                    text: '冷氣吹不冷喔？那台舊了啦，要換你自己換，合約寫修繕自行負責喔！',
                    isMe: false,
                  ),
                  SizedBox(height: 8.h),
                  _buildChatBubble(
                    sender: '房客 🧑',
                    text: '房東太太，可是民法第429條規定，除非契約另有約定，否則修繕責任應由房東承擔...',
                    isMe: true,
                  ),
                ],
              ),
            ),
            SizedBox(height: 10.h),
            Text(
              '房東說「合約寫自行負責」真的有效嗎？',
              style: TextStyle(
                fontSize: 13.5.sp,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            SizedBox(height: 4.h),
            Text(
              '學會區分自然折舊與人為損壞，保障租屋權益。',
              style:
                  TextStyle(fontSize: 11.5.sp, color: AppColors.textSecondary),
            ),
            SizedBox(height: 8.h),
            TextButton(
              onPressed: () => _openArticle(learningTopic.units[2].article),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('看白話解析',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  SizedBox(width: 4.w),
                  CtmSvgIcon(CtmSvgIcons.chevronRight,
                      size: 12.sp, color: HomeV2Palette.trustGreen),
                ],
              ),
            ),
          ],
        ),
      ),
    ];
  }

  Widget _buildFeaturedTopicSwitcher(bool isDark) {
    final gameState = LearningGameState.instance;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 膠囊顯示曾經看過案件的議題
        if (gameState.viewedCategories.isNotEmpty) ...[
          Text(
            '最近關注的議題',
            style: TextStyle(
              fontSize: 11.5.sp,
              fontWeight: FontWeight.w900,
              color: AppColors.textSecondary,
            ),
          ),
          SizedBox(height: 6.h),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            child: Row(
              children: gameState.viewedCategories.map((cat) {
                return Padding(
                  padding: EdgeInsets.only(right: 6.w),
                  child: ActionChip(
                    label: Text(
                      cat,
                      style: TextStyle(
                        fontSize: 10.5.sp,
                        fontWeight: FontWeight.bold,
                        color: HomeV2Palette.trustGreen,
                      ),
                    ),
                    backgroundColor: HomeV2Palette.mint,
                    side: BorderSide(
                      color: HomeV2Palette.trustGreen.withValues(alpha: 0.25),
                      width: 1.w,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(999.r),
                    ),
                    onPressed: () => _openLearningTopicCatalog(initialCategory: cat),
                  ),
                );
              }).toList(),
            ),
          ),
          SizedBox(height: 14.h),
        ],

        Row(
          children: [
            Text(
              '精選專題',
              style: TextStyle(
                fontSize: 13.sp,
                fontWeight: FontWeight.w900,
                color: AppColors.textPrimary,
              ),
            ),
            const Spacer(),
            GestureDetector(
              onTap: () => _openLearningTopicCatalog(),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '全部專題',
                    style: TextStyle(
                      fontSize: 11.5.sp,
                      fontWeight: FontWeight.w900,
                      color: HomeV2Palette.trustGreen,
                    ),
                  ),
                  SizedBox(width: 2.w),
                  CtmSvgIcon(
                    CtmSvgIcons.chevronRight,
                    size: 13.sp,
                    color: HomeV2Palette.trustGreen,
                  ),
                ],
              ),
            ),
          ],
        ),
        SizedBox(height: 8.h),
        // 台灣繁體中文教學註解：
        // 學習首頁只展示少量精選專題，避免活躍 App 內容增加後把首頁塞成百科列表；
        // 更多專題集中到「全部專題」面板，未來接 API 時阻擋並直接以 drawer 代替。
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          child: Row(
            children: _featuredTopics.map((topic) {
              return Padding(
                padding: EdgeInsets.only(right: 8.w),
                child: _buildTopicChip(topic, isDark),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildTopicChip(_LearningTopicOption topic, bool isDark) {
    final isSelected = topic.isAvailable;
    return GestureDetector(
      onTap: () {
        if (topic.title == '租屋糾紛') {
          // 租屋糾紛是主修課，點擊不執行動作（直接由下方的主修卡片開啟）
        } else {
          _openLearningTopicCatalog(initialCategory: topic.title);
        }
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
        decoration: BoxDecoration(
          color: isSelected
              ? HomeV2Palette.trustGreen
              : (isDark ? const Color(0xFF161C23) : Colors.white),
          borderRadius: BorderRadius.circular(999.r),
          border: Border.all(
            color: isSelected
                ? HomeV2Palette.trustGreen
                : (isDark ? const Color(0xFF2D3845) : const Color(0xFFECE6DB)),
            width: 1.1.w,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              topic.title,
              style: TextStyle(
                fontSize: 12.sp,
                fontWeight: FontWeight.w900,
                color: isSelected ? Colors.white : AppColors.textPrimary,
              ),
            ),
            SizedBox(width: 6.w),
            Text(
              topic.badge,
              style: TextStyle(
                fontSize: 9.5.sp,
                fontWeight: FontWeight.w800,
                color: isSelected
                    ? Colors.white.withValues(alpha: 0.78)
                    : AppColors.textMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }


  Widget _buildMainCourseCard({
    required bool isDark,
    required LearningGameState gameState,
    required List<LearningTopicUnit> rentUnits,
    required int completedRentCount,
    required double rentProgress,
  }) {
    final cardColor = isDark ? const Color(0xFF161C23) : Colors.white;
    final nextUnit = rentUnits.firstWhere(
      (unit) => !gameState.completedSteps.contains(unit.stepLabel),
      orElse: () => rentUnits.last,
    );
    final isComplete = completedRentCount == rentUnits.length;
    final ctaLabel = isComplete
        ? '複習主修課'
        : completedRentCount == 0
            ? '開始學習'
            : '繼續學習';

    return NotebookCard(
      hasBinderRings: true,
      padding: EdgeInsets.zero,
      backgroundColor: cardColor,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            height: 292.h,
            child: Stack(
              fit: StackFit.expand,
              children: [
                Image.asset(
                  _rentCourseHeroAsset,
                  fit: BoxFit.cover,
                ),
                // 台灣繁體中文教學註解：
                // 這裡用兩層同圖柔焦做「景深式」過渡：中段先開始微糊，底部再加重糊。
                // 這樣照片仍會延伸到底部，不會變成一塊紙色霧面造成斷層。
                Positioned.fill(
                  child: IgnorePointer(
                    child: ShaderMask(
                      blendMode: BlendMode.dstIn,
                      shaderCallback: (bounds) => const LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.transparent,
                          Colors.black26,
                          Colors.black,
                        ],
                        stops: [0.0, 0.18, 0.38, 1.0],
                      ).createShader(bounds),
                      child: ImageFiltered(
                        imageFilter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
                        child: Transform.scale(
                          scale: 1.03,
                          child: Image.asset(
                            _rentCourseHeroAsset,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                Positioned.fill(
                  child: IgnorePointer(
                    child: ShaderMask(
                      blendMode: BlendMode.dstIn,
                      shaderCallback: (bounds) => const LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.transparent,
                          Colors.black38,
                          Colors.black,
                        ],
                        stops: [0.0, 0.46, 0.64, 1.0],
                      ).createShader(bounds),
                      child: ImageFiltered(
                        imageFilter: ImageFilter.blur(sigmaX: 42, sigmaY: 42),
                        child: Transform.scale(
                          scale: 1.08,
                          child: Image.asset(
                            _rentCourseHeroAsset,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black.withValues(alpha: isDark ? 0.12 : 0.02),
                        (isDark ? Colors.black : Colors.white)
                            .withValues(alpha: isDark ? 0.10 : 0.18),
                        (isDark ? Colors.black : const Color(0xFFD7B27C))
                            .withValues(alpha: isDark ? 0.24 : 0.18),
                        (isDark ? Colors.black : const Color(0xFF8C5D24))
                            .withValues(alpha: isDark ? 0.48 : 0.34),
                      ],
                      stops: const [0.0, 0.42, 0.74, 1.0],
                    ),
                  ),
                ),
                Positioned(
                  top: 12.h,
                  left: 12.w,
                  right: 12.w,
                  child: Row(
                    children: [
                      _buildCourseBadge('主修課', isDark),
                      SizedBox(width: 8.w),
                      _buildCourseBadge('${rentUnits.length} 個單元', isDark),
                      const Spacer(),
                      _buildCourseBadge('租屋生活必修', isDark),
                    ],
                  ),
                ),
                Positioned(
                  left: 14.w,
                  right: 14.w,
                  bottom: 14.h,
                  // 台灣繁體中文教學註解：
                  // 文字直接壓在已經糊化的照片上，不再另做局部霧面卡；
                  // 可讀性靠底圖重糊、全寬漸層與文字陰影共同處理。
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '租屋糾紛怎麼看懂',
                        style: TextStyle(
                          fontSize: 21.sp,
                          height: 1.18,
                          fontWeight: FontWeight.w900,
                          color:
                              isDark ? Colors.white : const Color(0xFF17243A),
                          shadows: [
                            Shadow(
                              color: (isDark ? Colors.black : Colors.white)
                                  .withValues(alpha: isDark ? 0.40 : 0.70),
                              blurRadius: 12,
                            ),
                            Shadow(
                              color: (isDark ? Colors.black : Colors.white)
                                  .withValues(alpha: isDark ? 0.22 : 0.50),
                              blurRadius: 24,
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 6.h),
                      Text(
                        '學完後，你會知道押金能不能扣、提前解約怎麼判斷、點交證據怎麼留。',
                        style: TextStyle(
                          fontSize: 12.sp,
                          height: 1.45,
                          fontWeight: FontWeight.w800,
                          color: isDark
                              ? Colors.white.withValues(alpha: 0.78)
                              : const Color(0xFF53657B),
                          shadows: [
                            Shadow(
                              color: (isDark ? Colors.black : Colors.white)
                                  .withValues(alpha: isDark ? 0.34 : 0.58),
                              blurRadius: 14,
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 12.h),
                      GestureDetector(
                        onTap: () => _openUnitStep(nextUnit),
                        child: Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: 12.w, vertical: 10.h),
                          decoration: BoxDecoration(
                            color: HomeV2Palette.trustGreen,
                            borderRadius: BorderRadius.circular(10.r),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      ctaLabel,
                                      style: TextStyle(
                                        fontSize: 13.sp,
                                        fontWeight: FontWeight.w900,
                                        color: Colors.white,
                                      ),
                                    ),
                                    SizedBox(height: 2.h),
                                    Text(
                                      isComplete
                                          ? '已完成 ${rentUnits.length} 個單元，回頭複習判斷順序'
                                          : '下一步：${nextUnit.stepLabel} ${nextUnit.title}',
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        fontSize: 10.5.sp,
                                        fontWeight: FontWeight.w700,
                                        color: Colors.white
                                            .withValues(alpha: 0.82),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              CtmSvgIcon(
                                CtmSvgIcons.arrowRight,
                                size: 18.sp,
                                color: Colors.white,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(14.w, 4.h, 14.w, 14.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      '學習路徑',
                      style: TextStyle(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w900,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      '已完成 $completedRentCount / ${rentUnits.length}',
                      style: TextStyle(
                        fontSize: 11.sp,
                        fontWeight: FontWeight.w800,
                        color: HomeV2Palette.trustGreen,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8.h),
                ClipRRect(
                  borderRadius: BorderRadius.circular(99.r),
                  child: LinearProgressIndicator(
                    value: rentProgress,
                    minHeight: 6.h,
                    backgroundColor: isDark
                        ? const Color(0xFF2D3845)
                        : const Color(0xFFEFECE6),
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      HomeV2Palette.trustGreen,
                    ),
                  ),
                ),
                SizedBox(height: 12.h),
                ...rentUnits.asMap().entries.map((entry) {
                  final unit = entry.value;
                  final isDone =
                      gameState.completedSteps.contains(unit.stepLabel);
                  final isNext =
                      unit.stepLabel == nextUnit.stepLabel && !isComplete;
                  return _buildCoursePathStepRow(
                    unit,
                    isDone: isDone,
                    isNext: isNext,
                    isLast: entry.key == rentUnits.length - 1,
                    isDark: isDark,
                  );
                }),
                SizedBox(height: 10.h),
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(10.w),
                  decoration: BoxDecoration(
                    color: isDark
                        ? const Color(0xFF1E2622)
                        : const Color(0xFFF2FAF6),
                    borderRadius: BorderRadius.circular(10.r),
                    border: Border.all(
                      color: isDark
                          ? const Color(0xFF2E3C36)
                          : const Color(0xFFD2E6DE),
                    ),
                  ),
                  child: Text(
                    '學到點交與修繕時，可以到「生活工具箱」整理租屋證據清單。',
                    style: TextStyle(
                      fontSize: 11.5.sp,
                      height: 1.35,
                      fontWeight: FontWeight.w700,
                      color: isDark
                          ? const Color(0xFF99C3B3)
                          : const Color(0xFF1B4D3E),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCourseBadge(String label, bool isDark) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: isDark
            ? const Color(0xFF10161D).withValues(alpha: 0.74)
            : Colors.white.withValues(alpha: 0.74),
        borderRadius: BorderRadius.circular(999.r),
        border: Border.all(
          color: isDark
              ? const Color(0xFF2D3845)
              : Colors.white.withValues(alpha: 0.72),
        ),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 10.sp,
          fontWeight: FontWeight.w900,
          color: isDark
              ? Colors.white.withValues(alpha: 0.9)
              : HomeV2Palette.trustGreen,
        ),
      ),
    );
  }

  // 4) 生活工具箱的列表項目
  List<Widget> _buildToolkitItems(bool isDark, LearningGameState gameState) {
    return [
      // 1. 白話文翻譯機
      _buildTranslatorWidget(),
      SizedBox(height: 12.h),

      // 2. 文件與證據準備清單
      _buildEvidenceChecklistWidget(gameState),
      SizedBox(height: 12.h),

      // 3. 常用法規快查
      _buildStatuteSearchWidget(),
    ];
  }

  Widget _buildCoursePathStepRow(
    LearningTopicUnit unit, {
    required bool isDone,
    required bool isNext,
    required bool isLast,
    required bool isDark,
  }) {
    final activeColor = isDone
        ? HomeV2Palette.trustGreen
        : isNext
            ? const Color(0xFFE8B95F)
            : AppColors.textMuted;
    final paperColor =
        isDark ? const Color(0xFF1D252E) : const Color(0xFFFAF7F0);

    return GestureDetector(
      onTap: () => _openUnitStep(unit),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 26.w,
            child: Column(
              children: [
                Container(
                  width: 24.w,
                  height: 24.w,
                  decoration: BoxDecoration(
                    color: activeColor.withValues(
                        alpha: isDone || isNext ? 0.18 : 0.10),
                    shape: BoxShape.circle,
                    border: Border.all(color: activeColor, width: 1.4.w),
                  ),
                  child: Center(
                    child: CtmSvgIcon(
                      isDone ? CtmSvgIcons.star : CtmSvgIcons.timeline,
                      size: 13.sp,
                      color: activeColor,
                    ),
                  ),
                ),
                if (!isLast)
                  Container(
                    width: 1.2.w,
                    height: 42.h,
                    color: activeColor.withValues(alpha: 0.24),
                  ),
              ],
            ),
          ),
          SizedBox(width: 9.w),
          Expanded(
            child: Container(
              margin: EdgeInsets.only(bottom: isLast ? 0 : 8.h),
              padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 9.h),
              decoration: BoxDecoration(
                color: paperColor,
                borderRadius: BorderRadius.circular(10.r),
                border: Border.all(
                  color: isNext
                      ? const Color(0xFFE8B95F)
                      : (isDark
                          ? const Color(0xFF2D3845)
                          : const Color(0xFFECE6DB)),
                  width: isNext ? 1.4.w : 1.w,
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${unit.stepLabel}：${unit.title}',
                          style: TextStyle(
                            fontSize: 12.5.sp,
                            fontWeight: FontWeight.w900,
                            decoration:
                                isDone ? TextDecoration.lineThrough : null,
                            color: isDone
                                ? AppColors.textMuted
                                : AppColors.textPrimary,
                          ),
                        ),
                        SizedBox(height: 3.h),
                        Text(
                          '${unit.goal} • ${unit.readTime}',
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 10.5.sp,
                            height: 1.35,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: 8.w),
                  CtmSvgIcon(
                    CtmSvgIcons.chevronRight,
                    size: 15.sp,
                    color: activeColor,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChatBubble(
      {required String sender, required String text, required bool isMe}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
      children: [
        if (!isMe) ...[
          CircleAvatar(
            radius: 14.r,
            backgroundColor: Colors.grey.shade300,
            child:
                Text(sender.substring(0, 1), style: TextStyle(fontSize: 11.sp)),
          ),
          SizedBox(width: 8.w),
        ],
        Flexible(
          child: Column(
            crossAxisAlignment:
                isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
            children: [
              Text(sender,
                  style: TextStyle(fontSize: 9.sp, color: Colors.grey)),
              SizedBox(height: 2.h),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                decoration: BoxDecoration(
                  color: isMe
                      ? HomeV2Palette.mint
                      : (isDark
                          ? const Color(0xFF26303D)
                          : const Color(0xFFE8E8E8)),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(isMe ? 12.r : 2.r),
                    topRight: Radius.circular(isMe ? 2.r : 12.r),
                    bottomLeft: Radius.circular(12.r),
                    bottomRight: Radius.circular(12.r),
                  ),
                ),
                child: Text(
                  text,
                  style: TextStyle(fontSize: 12.sp, height: 1.3),
                ),
              ),
            ],
          ),
        ),
        if (isMe) ...[
          SizedBox(width: 8.w),
          CircleAvatar(
            radius: 14.r,
            backgroundColor: HomeV2Palette.trustGreen.withValues(alpha: 0.2),
            child: Text(sender.substring(0, 1),
                style: TextStyle(
                    fontSize: 11.sp, color: HomeV2Palette.trustGreen)),
          ),
        ],
      ],
    );
  }

  // 1) 法律術語白話翻譯機 Widget
  final TextEditingController _translatorController = TextEditingController();
  String _translationOutput = '';
  final Map<String, String> _termsMap = {
    '應予駁回': '法院拒絕了這項請求。例如：原告主張無理由，法院「應予駁回」。',
    '酌減': '法院決定減少金額/處罰。例如：違約金過高，法院予以「酌減」。',
    '按之': '依照這個規定/道理來看。通常用在引用法條。',
    '矧以': '更何況是...。用來加強論點。',
    '無理由': '主張在法律上站不住腳，不可信。',
  };

  Widget _buildTranslatorWidget() {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return NotebookCard(
      hasPaperClip: true,
      backgroundColor:
          isDark ? const Color(0xFF28241B) : const Color(0xFFFFFDF8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CtmSvgIcon(CtmSvgIcons.gavel,
                  color: const Color(0xFF94610D), size: 20.sp),
              SizedBox(width: 8.w),
              Text(
                '法律術語白話翻譯機',
                style: TextStyle(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w900,
                    color: AppColors.textPrimary),
              ),
            ],
          ),
          SizedBox(height: 10.h),
          TextField(
            controller: _translatorController,
            style: TextStyle(fontSize: 13.sp),
            decoration: InputDecoration(
              hintText: '輸入判決書難懂字眼，或點擊下方快捷詞晶片...',
              hintStyle: TextStyle(fontSize: 12.sp, color: Colors.grey),
              filled: true,
              fillColor:
                  isDark ? const Color(0xFF1E252D) : const Color(0xFFFFFAEC),
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.r),
                  borderSide: BorderSide.none),
              contentPadding: EdgeInsets.all(10.w),
            ),
            maxLines: 2,
          ),
          SizedBox(height: 8.h),

          // 快捷晶片 (Chips)
          Wrap(
            spacing: 6.w,
            children: _termsMap.keys.map((term) {
              return ActionChip(
                label: Text(term,
                    style: TextStyle(
                        fontSize: 11.sp, fontWeight: FontWeight.bold)),
                backgroundColor:
                    isDark ? const Color(0xFF2C353F) : const Color(0xFFEAE5DB),
                padding: EdgeInsets.zero,
                onPressed: () {
                  setState(() {
                    _translatorController.text = term;
                    _translationOutput = _termsMap[term]!;
                    LearningGameState.instance.incrementTranslatorUsage();
                  });
                },
              );
            }).toList(),
          ),
          SizedBox(height: 10.h),

          // 翻譯按鈕
          Row(
            children: [
              ElevatedButton(
                onPressed: () {
                  final text = _translatorController.text.trim();
                  if (text.isEmpty) return;
                  setState(() {
                    _translationOutput = _termsMap[text] ??
                        '白話翻譯：該詞彙正在整理中。法律概念通常指「依照規定做對應處置，並保障當事人權利」。';
                    LearningGameState.instance.incrementTranslatorUsage();
                  });
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF94610D),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.r)),
                ),
                child: const Text('翻譯'),
              ),
              if (_translationOutput.isNotEmpty) ...[
                SizedBox(width: 10.w),
                TextButton(
                  onPressed: () {
                    setState(() {
                      _translatorController.clear();
                      _translationOutput = '';
                    });
                  },
                  child: const Text('清除'),
                )
              ]
            ],
          ),

          // 翻譯結果
          if (_translationOutput.isNotEmpty) ...[
            SizedBox(height: 12.h),
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(10.w),
              decoration: BoxDecoration(
                color:
                    isDark ? const Color(0xFF332B1E) : const Color(0xFFFFFAEC),
                borderRadius: BorderRadius.circular(10.r),
                border: Border.all(color: const Color(0xFFE4C179)),
              ),
              child: Text(
                _translationOutput,
                style: TextStyle(
                  fontSize: 12.5.sp,
                  height: 1.4,
                  color:
                      isDark ? Colors.orange.shade100 : const Color(0xFF5D4017),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  // 2) 文件與證據準備清單 Widget
  int _evidenceTabType = 0; // 0: 車禍糾紛, 1: 租屋糾紛
  final List<String> _carEvidences = [
    '行車紀錄器影片 (影片檔案)',
    '車損照片與事故現場照片',
    '道路交通事故初步分析研判表 (警局申請)',
    '診斷證明書 (如有體傷)',
    '車輛修繕費用收據/估價單'
  ];
  final List<String> _rentEvidences = [
    '房屋租賃契約書 (合約本體)',
    '點交照片或影片',
    '修繕通知簡訊/LINE對話紀錄',
    '修繕費用收據',
    '押金收據或匯款紀錄'
  ];
  final Set<String> _checkedEvidences = {};

  Widget _buildEvidenceChecklistWidget(LearningGameState gameState) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final currentList = _evidenceTabType == 0 ? _carEvidences : _rentEvidences;
    final String currentTitle =
        _evidenceTabType == 0 ? '🚗 車禍責任釐清證據包' : '🏠 租屋點交扣押金證據包';

    return NotebookCard(
      hasBinderRings: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CtmSvgIcon(CtmSvgIcons.filePen,
                  color: HomeV2Palette.trustGreen, size: 20.sp),
              SizedBox(width: 8.w),
              Text(
                '證據準備與文件清單',
                style: TextStyle(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w900,
                    color: AppColors.textPrimary),
              ),
            ],
          ),
          SizedBox(height: 8.h),

          // 切換車禍/租屋
          Row(
            children: [
              ChoiceChip(
                label: Text('車禍糾紛', style: TextStyle(fontSize: 11.sp)),
                selected: _evidenceTabType == 0,
                onSelected: (val) {
                  setState(() {
                    _evidenceTabType = 0;
                    _checkedEvidences.clear();
                  });
                },
              ),
              SizedBox(width: 8.w),
              ChoiceChip(
                label: Text('租屋爭議', style: TextStyle(fontSize: 11.sp)),
                selected: _evidenceTabType == 1,
                onSelected: (val) {
                  setState(() {
                    _evidenceTabType = 1;
                    _checkedEvidences.clear();
                  });
                },
              ),
            ],
          ),
          SizedBox(height: 10.h),

          // 核取清單
          ...currentList.map((item) {
            final isChecked = _checkedEvidences.contains(item);
            return CheckboxListTile(
              contentPadding: EdgeInsets.zero,
              dense: true,
              title: Text(
                item,
                style: TextStyle(
                  fontSize: 12.5.sp,
                  decoration: isChecked ? TextDecoration.lineThrough : null,
                  color:
                      isChecked ? AppColors.textMuted : AppColors.textPrimary,
                ),
              ),
              value: isChecked,
              activeColor: HomeV2Palette.trustGreen,
              onChanged: (val) {
                setState(() {
                  if (val == true) {
                    _checkedEvidences.add(item);
                  } else {
                    _checkedEvidences.remove(item);
                  }
                });
              },
            );
          }),

          SizedBox(height: 12.h),

          // 備忘/導出按鈕
          Row(
            children: [
              ElevatedButton.icon(
                icon: CtmSvgIcon(CtmSvgIcons.bookmark,
                    size: 14.sp, color: Colors.white),
                label: const Text('儲存備忘'),
                onPressed: () {
                  gameState.saveEvidenceList(
                      currentTitle, _checkedEvidences.toList(), currentList);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('已成功儲存證據清單至小法助的「備忘錄」中！'),
                      backgroundColor: HomeV2Palette.trustGreen,
                    ),
                  );
                },
              ),
              SizedBox(width: 10.w),
              OutlinedButton.icon(
                icon: CtmSvgIcon(CtmSvgIcons.externalLink,
                    size: 14.sp, color: HomeV2Palette.trustGreen),
                label: const Text('導出 PDF'),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('成功導出證據清單 PDF！已儲存至本機檔案及成就室備忘錄。'),
                      backgroundColor: HomeV2Palette.trustGreen,
                    ),
                  );
                  gameState.saveEvidenceList('$currentTitle (PDF 導出版)',
                      _checkedEvidences.toList(), currentList);
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  // 3) 常用法規快查 Widget
  Widget _buildStatuteSearchWidget() {
    return NotebookCard(
      hasBookmark: true,
      bookmarkColor: const Color(0xFF6FA8DC),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CtmSvgIcon(CtmSvgIcons.search,
                  color: const Color(0xFF3F7FBF), size: 20.sp),
              SizedBox(width: 8.w),
              Text(
                '常用法規快速查詢',
                style: TextStyle(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w900,
                    color: AppColors.textPrimary),
              ),
            ],
          ),
          SizedBox(height: 10.h),
          Wrap(
            spacing: 8.w,
            runSpacing: 6.h,
            children: [
              _buildStatuteChip('民法'),
              _buildStatuteChip('刑法'),
              _buildStatuteChip('勞基法', actual: '勞動基準法'),
              _buildStatuteChip('消保法', actual: '消費者保護法'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatuteChip(String label, {String? actual}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return ActionChip(
      label: Text(label,
          style: TextStyle(
              fontSize: 11.sp,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF1F4E87))),
      backgroundColor:
          isDark ? const Color(0xFF1F2B38) : const Color(0xFFE8F0FE),
      onPressed: () => _openStatuteDatabase(initialQuery: actual ?? label),
    );
  }
}

class _LearningTopicOption {
  const _LearningTopicOption(this.title, this.badge, this.isAvailable);

  final String title;
  final String badge;
  final bool isAvailable;
}

// 🤖 智慧小法助輪播提問氣泡元件 (整合等級表情與自訂印花)
class _AssistantPromptBubble extends StatefulWidget {
  const _AssistantPromptBubble({required this.onMascotTap});
  final VoidCallback onMascotTap;

  @override
  State<_AssistantPromptBubble> createState() => _AssistantPromptBubbleState();
}

class _AssistantPromptBubbleState extends State<_AssistantPromptBubble> {
  late final Timer _timer;
  int _currentIndex = 0;

  static const List<String> _prompts = [
    '租屋提前解約，押金一定拿不回來嗎？',
    '車禍發生時，第一時間到底該不該移車？',
    '網購服飾拆封試穿後，到底能不能退？',
    '在臉書貼人對話截圖，會不會觸犯個資法？',
    '什麼是法律上的「應予駁回」？',
  ];

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 4), (timer) {
      if (mounted) {
        setState(() {
          _currentIndex = (_currentIndex + 1) % _prompts.length;
        });
      }
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final currentPrompt = _prompts[_currentIndex];
    final gameState = LearningGameState.instance;

    final bubbleBgColor =
        isDark ? const Color(0xFF1E2622) : const Color(0xFFF2FAF6);
    final bubbleBorderColor =
        isDark ? const Color(0xFF2E3C36) : const Color(0xFFD2E6DE);
    final textColor =
        isDark ? const Color(0xFF99C3B3) : const Color(0xFF1B4D3E);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // 吉祥物頭貼
        GestureDetector(
          onTap: widget.onMascotTap,
          child: Tooltip(
            message: '開啟小法助成長檔案',
            child: Container(
              padding: EdgeInsets.all(2.w),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border:
                    Border.all(color: HomeV2Palette.trustGreen, width: 1.5.w),
              ),
              child: ClipOval(
                child: Image.asset(
                  'assets/images/assistant/law_assistant_home.png',
                  width: 40.w,
                  height: 40.w,
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
        ),
        SizedBox(width: 8.w),
        // 對話氣泡 (優化動畫與排版對齊避免重疊)
        Expanded(
          child: GestureDetector(
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) =>
                      LawAssistantSearchPage(initialPrompt: currentPrompt),
                ),
              );
            },
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
              decoration: BoxDecoration(
                color: bubbleBgColor,
                border: Border.all(color: bubbleBorderColor, width: 1.2.w),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(4.r),
                  topRight: Radius.circular(16.r),
                  bottomLeft: Radius.circular(16.r),
                  bottomRight: Radius.circular(16.r),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: isDark ? 0.1 : 0.02),
                    blurRadius: 6,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${gameState.levelTitle} ${gameState.mascotExpression} 提問：',
                          style: TextStyle(
                            fontSize: 9.5.sp,
                            fontWeight: FontWeight.bold,
                            color: textColor.withValues(alpha: 0.7),
                          ),
                        ),
                        SizedBox(height: 2.h),
                        // 鎖定 ClipRect 與 AnimatedSwitcher 進行向上跑馬燈，防止新舊文字動畫期間重疊
                        ClipRect(
                          child: AnimatedSwitcher(
                            duration: const Duration(milliseconds: 250),
                            layoutBuilder: (Widget? currentChild,
                                List<Widget> previousChildren) {
                              return Stack(
                                alignment: Alignment.centerLeft,
                                children: <Widget>[
                                  ...previousChildren,
                                  if (currentChild != null) currentChild,
                                ],
                              );
                            },
                            transitionBuilder: (child, animation) {
                              final isNew =
                                  child.key == ValueKey<int>(_currentIndex);
                              return FadeTransition(
                                opacity: animation,
                                child: SlideTransition(
                                  position: Tween<Offset>(
                                    begin: isNew
                                        ? const Offset(0.0, 0.2)
                                        : const Offset(0.0, -0.2),
                                    end: Offset.zero,
                                  ).animate(animation),
                                  child: child,
                                ),
                              );
                            },
                            child: Text(
                              currentPrompt,
                              key: ValueKey<int>(_currentIndex),
                              style: TextStyle(
                                fontSize: 12.sp,
                                fontWeight: FontWeight.bold,
                                color: textColor,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: 4.w),
                  CtmSvgIcon(
                    CtmSvgIcons.chevronRight,
                    size: 12.sp,
                    color: textColor.withValues(alpha: 0.7),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// 保留此私有類別供 part 檔案外部呼叫 (編譯相容性)
class _LawBuddyAvatar extends StatelessWidget {
  const _LawBuddyAvatar();

  @override
  Widget build(BuildContext context) {
    final assistantPalette = _LawAssistantPalette.of(context);
    return SizedBox(
      width: 42.w,
      height: 42.w,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CtmSvgIcon(
            CtmSvgIcons.bot,
            size: 35.sp,
            color: assistantPalette.accent,
          ),
          Positioned(
            right: 3.w,
            bottom: 2.w,
            child: Container(
              width: 15.w,
              height: 15.w,
              decoration: BoxDecoration(
                color: assistantPalette.highlight,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: CtmSvgIcon(
                  CtmSvgIcons.scale,
                  size: 10.sp,
                  color: assistantPalette.primaryText,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
class _LearningTopicCatalogBottomSheet extends StatefulWidget {
  const _LearningTopicCatalogBottomSheet({
    required this.initialCategory,
    required this.isDark,
    required this.onArticleTap,
  });

  final String? initialCategory;
  final bool isDark;
  final Function(LearningMockArticle) onArticleTap;

  @override
  State<_LearningTopicCatalogBottomSheet> createState() => _LearningTopicCatalogBottomSheetState();
}

class _LearningTopicCatalogBottomSheetState extends State<_LearningTopicCatalogBottomSheet> {
  late String _selectedCategory;
  String _searchQuery = '';
  late Future<List<LearningMockArticle>> _future;

  @override
  void initState() {
    super.initState();
    _selectedCategory = widget.initialCategory ?? '全部';
    _fetchData();
  }

  void _fetchData() {
    _future = SupabaseLearningService.instance.fetchArticles(
      category: _selectedCategory == '全部' ? null : _selectedCategory,
      query: _searchQuery.isEmpty ? null : _searchQuery,
      limit: 50,
    );
  }

  @override
  Widget build(BuildContext context) {
    final List<String> catalogCategories = [
      '全部',
      '租屋糾紛',
      '車禍事故',
      '職場權益',
      '網購消費',
      '個資隱私',
      '鄰里生活',
      '婚姻家庭',
      '防詐騙常識'
    ];

    return DraggableScrollableSheet(
      initialChildSize: 0.82,
      minChildSize: 0.50,
      maxChildSize: 0.95,
      expand: false,
      builder: (sheetContext, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: widget.isDark ? const Color(0xFF161C23) : const Color(0xFFFFFCF4),
            borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
          ),
          child: Column(
            children: [
              SizedBox(height: 10.h),
              Center(
                child: Container(
                  width: 42.w,
                  height: 4.h,
                  decoration: BoxDecoration(
                    color: widget.isDark ? const Color(0xFF354454) : const Color(0xFFD8D0C2),
                    borderRadius: BorderRadius.circular(99.r),
                  ),
                ),
              ),
              SizedBox(height: 16.h),
              
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.w),
                child: Row(
                  children: [
                    Text(
                      '全部專題分類庫 📚',
                      style: TextStyle(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.w900,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 12.h),

              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.w),
                child: TextField(
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value;
                      _fetchData();
                    });
                  },
                  decoration: InputDecoration(
                    hintText: '搜尋生活法律情境、關鍵字...',
                    hintStyle: TextStyle(fontSize: 12.sp, color: Colors.grey),
                    prefixIcon: Padding(
                      padding: EdgeInsets.all(10.w),
                      child: CtmSvgIcon(
                        CtmSvgIcons.search,
                        size: 16.sp,
                        color: Colors.grey,
                      ),
                    ),
                    filled: true,
                    fillColor: widget.isDark ? const Color(0xFF232B35) : const Color(0xFFF5EFE2),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14.r),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: EdgeInsets.symmetric(vertical: 8.h),
                  ),
                  style: TextStyle(fontSize: 13.sp, color: AppColors.textPrimary),
                ),
              ),
              SizedBox(height: 12.h),

              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                child: Row(
                  children: catalogCategories.map((cat) {
                    final isSelected = _selectedCategory == cat;
                    return Padding(
                      padding: EdgeInsets.only(right: 6.w),
                      child: ChoiceChip(
                        label: Text(
                          cat,
                          style: TextStyle(
                            fontSize: 11.sp,
                            fontWeight: FontWeight.bold,
                            color: isSelected ? Colors.white : AppColors.textPrimary,
                          ),
                        ),
                        selected: isSelected,
                        onSelected: (selected) {
                          if (selected) {
                            setState(() {
                              _selectedCategory = cat;
                              _fetchData();
                            });
                          }
                        },
                        selectedColor: HomeV2Palette.trustGreen,
                        backgroundColor: widget.isDark ? const Color(0xFF232B35) : const Color(0xFFF5EFE2),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(999.r),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
              SizedBox(height: 10.h),

              Expanded(
                child: FutureBuilder<List<LearningMockArticle>>(
                  future: _future,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return ListView(
                        controller: scrollController,
                        children: const [
                          SizedBox(height: 120),
                          Center(
                            child: CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(HomeV2Palette.trustGreen),
                            ),
                          ),
                        ],
                      );
                    }
                    if (snapshot.hasError) {
                      return ListView(
                        controller: scrollController,
                        children: const [
                          SizedBox(height: 120),
                          Center(
                            child: Text('載入失敗，請稍後再試'),
                          ),
                        ],
                      );
                    }
                    final list = snapshot.data ?? [];
                    if (list.isEmpty) {
                      return ListView(
                        controller: scrollController,
                        children: [
                          const SizedBox(height: 100),
                          Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text('🔍', style: TextStyle(fontSize: 32.sp)),
                                SizedBox(height: 8.h),
                                Text(
                                  '找不到符合的情境專題',
                                  style: TextStyle(
                                    fontSize: 13.sp,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      );
                    }

                    return GridView.builder(
                      controller: scrollController,
                      padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 20.h),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        mainAxisSpacing: 10.h,
                        crossAxisSpacing: 10.w,
                        childAspectRatio: 0.88,
                      ),
                      itemCount: list.length,
                      itemBuilder: (context, index) {
                        final article = list[index];
                        final cat = article.category ?? '法律常識';
                        
                        Color cardBg;
                        Color textColor;
                        Color accentColor;
                        
                        if (widget.isDark) {
                          cardBg = const Color(0xFF1E252E);
                          textColor = Colors.white;
                          accentColor = HomeV2Palette.trustGreen;
                        } else {
                          switch (cat) {
                            case '租屋糾紛':
                              cardBg = const Color(0xFFE8F5E9);
                              accentColor = const Color(0xFF2E7D32);
                              break;
                            case '車禍事故':
                              cardBg = const Color(0xFFE3F2FD);
                              accentColor = const Color(0xFF1565C0);
                              break;
                            case '職場權益':
                              cardBg = const Color(0xFFFFF3E0);
                              accentColor = const Color(0xFFE65100);
                              break;
                            case '網購消費':
                              cardBg = const Color(0xFFFCE4EC);
                              accentColor = const Color(0xFFC2185B);
                              break;
                            case '個資隱私':
                              cardBg = const Color(0xFFEDE7F6);
                              accentColor = const Color(0xFF512DA8);
                              break;
                            case '鄰里生活':
                              cardBg = const Color(0xFFE0F2F1);
                              accentColor = const Color(0xFF00796B);
                              break;
                            case '婚姻家庭':
                              cardBg = const Color(0xFFFDF2E9);
                              accentColor = const Color(0xFFA04000);
                              break;
                            case '防詐騙常識':
                              cardBg = const Color(0xFFECEFF1);
                              accentColor = const Color(0xFF37474F);
                              break;
                            default:
                              cardBg = const Color(0xFFFFFDF5);
                              accentColor = HomeV2Palette.trustGreen;
                          }
                          textColor = AppColors.textPrimary;
                        }

                        return GestureDetector(
                          onTap: () {
                            Navigator.of(sheetContext).pop();
                            widget.onArticleTap(article);
                          },
                          child: Container(
                            padding: EdgeInsets.all(12.w),
                            decoration: BoxDecoration(
                              color: cardBg,
                              borderRadius: BorderRadius.circular(16.r),
                              border: Border.all(
                                color: widget.isDark ? const Color(0xFF2C3845) : accentColor.withValues(alpha: 0.15),
                                width: 1.w,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.03),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                                      decoration: BoxDecoration(
                                        color: widget.isDark ? const Color(0xFF354454) : Colors.white.withValues(alpha: 0.72),
                                        borderRadius: BorderRadius.circular(6.r),
                                      ),
                                      child: Text(
                                        cat,
                                        style: TextStyle(
                                          fontSize: 9.sp,
                                          fontWeight: FontWeight.bold,
                                          color: widget.isDark ? Colors.white70 : accentColor,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 8.h),
                                Expanded(
                                  child: Text(
                                    article.title,
                                    style: TextStyle(
                                      fontSize: 12.5.sp,
                                      fontWeight: FontWeight.w900,
                                      color: textColor,
                                      height: 1.3,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                SizedBox(height: 6.h),
                                Text(
                                  article.summary,
                                  style: TextStyle(
                                    fontSize: 10.sp,
                                    color: widget.isDark ? Colors.white60 : AppColors.textSecondary,
                                    height: 1.3,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                SizedBox(height: 8.h),
                                Row(
                                  children: [
                                    CtmSvgIcon(
                                      CtmSvgIcons.clock,
                                      size: 11.sp,
                                      color: widget.isDark ? Colors.white38 : Colors.grey,
                                    ),
                                    SizedBox(width: 4.w),
                                    Text(
                                      article.readTime,
                                      style: TextStyle(
                                        fontSize: 9.5.sp,
                                        color: widget.isDark ? Colors.white38 : Colors.grey,
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
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
