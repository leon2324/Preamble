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

// 導入遊戲化與手寫本美學
import 'package:lawapp/data/learning/learning_game_state.dart';
import 'package:lawapp/pages/learning/widgets/notebook_aesthetics.dart';
import 'package:lawapp/pages/learning/widgets/achievement_room.dart';
import 'package:lawapp/pages/learning/widgets/mock_court_challenge.dart';

import 'dart:async';

part 'law_assistant/law_assistant_palette.dart';
part 'law_assistant/law_assistant_search_page.dart';
part 'law_assistant/law_assistant_prototype_widgets.dart';
part 'law_assistant/law_assistant_chat_page.dart';

/// 學習頁重構：左右 Tab 切換 (法學課堂 & 生活工具箱) 搭配手寫法律筆記本美學
class KnowLawPage extends StatefulWidget {
  const KnowLawPage({super.key});

  @override
  KnowLawPageState createState() => KnowLawPageState();
}

class KnowLawPageState extends State<KnowLawPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _openArticle(LearningMockArticle article) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (__) => LearningMockDetailPage(article: article),
      ),
    );
  }

  void _openLearningSearch() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (__) => const LawAssistantSearchPage(),
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

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final gameState = LearningGameState.instance;

    return Scaffold(
      appBar: AppBar(
        title: const Text('學堂與工具箱'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          // 頂部右側吉祥物人頭，點擊開成就室
          GestureDetector(
            onTap: _openAchievementRoom,
            child: Container(
              margin: EdgeInsets.only(right: 16.w),
              width: 36.w,
              height: 36.w,
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF26303D) : const Color(0xFFF3EDE0),
                shape: BoxShape.circle,
                border: Border.all(
                  color: isDark ? const Color(0xFF354454) : const Color(0xFFE4D9C4),
                  width: 1.5.w,
                ),
              ),
              child: ListenableBuilder(
                listenable: gameState,
                builder: (context, _) {
                  return Center(
                    child: Text(
                      gameState.mascotExpression,
                      style: TextStyle(fontSize: 20.sp),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
      body: ListenableBuilder(
        listenable: gameState,
        builder: (context, _) {
          return NotebookBackground(
            child: SafeArea(
              child: Column(
                children: [
                  // 置頂搜尋欄與 AI 輪播氣泡
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                    child: Column(
                      children: [
                        // 1. 全域搜尋欄
                        GestureDetector(
                          onTap: _openLearningSearch,
                          child: Container(
                            padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
                            decoration: BoxDecoration(
                              color: isDark ? const Color(0xFF1E252D) : Colors.white,
                              borderRadius: BorderRadius.circular(18.r),
                              border: Border.all(
                                color: isDark ? const Color(0xFF2D3845) : const Color(0xFFD5E2D9),
                                width: 1.2.w,
                              ),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.search_rounded,
                                  color: HomeV2Palette.trustGreen,
                                  size: 20.sp,
                                ),
                                SizedBox(width: 9.w),
                                Expanded(
                                  child: Text(
                                    '搜尋法律、生活案件...',
                                    style: TextStyle(
                                      color: AppColors.textMuted,
                                      fontSize: 13.sp,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(height: 10.h),
                        // 2. 智慧小法助輪播氣泡
                        _AssistantPromptBubble(
                          onMascotTap: _openAchievementRoom,
                        ),
                      ],
                    ),
                  ),

                  // 左右 Tab 切換鈕（設計成實體筆記本索引頁緣質感）
                  Container(
                    margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 6.h),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF161C23) : const Color(0xFFEFECE6),
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: TabBar(
                      controller: _tabController,
                      indicator: BoxDecoration(
                        color: isDark ? const Color(0xFF232B35) : Colors.white,
                        borderRadius: BorderRadius.circular(10.r),
                        border: Border.all(
                          color: isDark ? const Color(0xFF2D3845) : const Color(0xFFECE6DB),
                          width: 1.2.w,
                        ),
                      ),
                      labelColor: HomeV2Palette.trustGreen,
                      unselectedLabelColor: AppColors.textSecondary,
                      labelStyle: TextStyle(fontSize: 13.5.sp, fontWeight: FontWeight.bold),
                      indicatorSize: TabBarIndicatorSize.tab,
                      tabs: const [
                        Tab(text: '👨‍🏫 法學課堂'),
                        Tab(text: '🧰 生活工具箱'),
                      ],
                    ),
                  ),

                  // Tab 內容區
                  Expanded(
                    child: TabBarView(
                      controller: _tabController,
                      children: [
                        // Tab 1: 法學課堂
                        _buildClassroomTab(gameState),
                        // Tab 2: 生活工具箱
                        _buildToolkitTab(gameState),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // ────────────────────────────────────────────────────────
  // 👨‍🏫 Tab 1: 法學課堂
  // ────────────────────────────────────────────────────────
  Widget _buildClassroomTab(LearningGameState gameState) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // 計算租屋單元進度 (STEP 1 ~ STEP 4 共 4 個單元)
    final rentSteps = {'STEP 1', 'STEP 2', 'STEP 3', 'STEP 4'};
    final completedRentCount = gameState.completedSteps.intersection(rentSteps).length;
    final rentProgress = completedRentCount / 4;

    return ListView(
      controller: _scrollController,
      padding: EdgeInsets.fromLTRB(16.w, 10.h, 16.w, 40.h),
      physics: const BouncingScrollPhysics(),
      children: [
        // 1. 公民法律小擂台 Challenge Card
        NotebookCard(
          hasBookmark: true,
          bookmarkColor: const Color(0xFFE8B95F),
          backgroundColor: isDark ? const Color(0xFF202A24) : const Color(0xFFFFFDF5),
          child: Row(
            children: [
              Container(
                width: 44.w,
                height: 44.w,
                decoration: const BoxDecoration(
                  color: Color(0xFFFFD46A),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.emoji_events_rounded,
                  size: 24.sp,
                  color: const Color(0xFF6B4B14),
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '🏆 公民法律小擂台',
                      style: TextStyle(
                        fontSize: 15.sp,
                        fontWeight: FontWeight.w900,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    SizedBox(height: 3.h),
                    Text(
                      '模擬審判案件，連對解鎖專屬徽章！',
                      style: TextStyle(
                        fontSize: 11.sp,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (__) => const MockCourtChallengePage()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: HomeV2Palette.trustGreen,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
                  padding: EdgeInsets.symmetric(horizontal: 14.w),
                ),
                child: const Text('開始挑戰'),
              ),
            ],
          ),
        ),

        // 2. 租屋糾紛主專題卡片
        NotebookCard(
          hasBinderRings: true,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
                    decoration: BoxDecoration(
                      color: HomeV2Palette.mint,
                      borderRadius: BorderRadius.circular(6.r),
                    ),
                    child: Text(
                      '主修課',
                      style: TextStyle(
                        fontSize: 10.sp,
                        fontWeight: FontWeight.bold,
                        color: HomeV2Palette.trustGreen,
                      ),
                    ),
                  ),
                  const Spacer(),
                  Text(
                    '進度：${(rentProgress * 100).toInt()}%',
                    style: TextStyle(
                      fontSize: 11.5.sp,
                      fontWeight: FontWeight.bold,
                      color: HomeV2Palette.trustGreen,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 8.h),
              Text(
                '🏠 租屋糾紛怎麼看懂',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w900,
                  color: AppColors.textPrimary,
                ),
              ),
              SizedBox(height: 6.h),
              Text(
                '從押金、提前解約到修繕責任，用一條完整的邏輯線，帶你拆解最常見的租賃糾紛。',
                style: TextStyle(
                  fontSize: 12.sp,
                  height: 1.45,
                  color: AppColors.textSecondary,
                ),
              ),
              SizedBox(height: 10.h),
              // 進度條
              ClipRRect(
                borderRadius: BorderRadius.circular(99.r),
                child: LinearProgressIndicator(
                  value: rentProgress,
                  minHeight: 6.h,
                  backgroundColor: isDark ? const Color(0xFF2D3845) : const Color(0xFFEFECE6),
                  valueColor: const AlwaysStoppedAnimation<Color>(
                    HomeV2Palette.trustGreen,
                  ),
                ),
              ),
              SizedBox(height: 12.h),
              // 單元列表
              ...learningTopic.units.take(4).map((unit) {
                final isDone = gameState.completedSteps.contains(unit.stepLabel);
                return _buildUnitStepRow(unit, isDone);
              }),
            ],
          ),
        ),

        // 3. 混合排列的卡片：插圖故事卡片
        NotebookCard(
          hasPaperClip: true,
          backgroundColor: isDark ? const Color(0xFF242C36) : const Color(0xFFEAF0F8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.directions_car_rounded, color: const Color(0xFF3F7FBF), size: 24.sp),
                  SizedBox(width: 8.w),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.6),
                      borderRadius: BorderRadius.circular(4.r),
                    ),
                    child: Text(
                      '車禍防護課',
                      style: TextStyle(fontSize: 9.5.sp, fontWeight: FontWeight.bold, color: const Color(0xFF1F4E87)),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 10.h),
              Text(
                '🚗 車禍被撞了！第一時間該拍照還是移車？',
                style: TextStyle(
                  fontSize: 14.5.sp,
                  fontWeight: FontWeight.w900,
                  color: AppColors.textPrimary,
                ),
              ),
              SizedBox(height: 6.h),
              Text(
                '道路事故現場的黃金三步驟：安全防範、拍照存證、定位通報。答對測驗可解鎖車禍徽章！',
                style: TextStyle(fontSize: 12.sp, height: 1.4, color: AppColors.textSecondary),
              ),
              SizedBox(height: 10.h),
              ElevatedButton.icon(
                icon: const Icon(Icons.arrow_forward, size: 16),
                label: const Text('研讀此案例'),
                onPressed: () => _openArticle(learningTopic.supportItems[2].article),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF3F7FBF),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
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
                  Icon(Icons.chat_bubble_outline_rounded, color: HomeV2Palette.trustGreen, size: 20.sp),
                  SizedBox(width: 8.w),
                  Text(
                    '模擬對話故事',
                    style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.bold, color: HomeV2Palette.trustGreen),
                  ),
                ],
              ),
              SizedBox(height: 10.h),
              // LINE 對話泡泡
              Container(
                padding: EdgeInsets.all(12.w),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1E252D) : const Color(0xFFF7F7F7),
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
                '💡 房東說「合約寫自行負責」真的有效嗎？',
                style: TextStyle(
                  fontSize: 13.5.sp,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              SizedBox(height: 4.h),
              Text(
                '學會區分自然折舊與人為損壞，保障租屋權益。',
                style: TextStyle(fontSize: 11.5.sp, color: AppColors.textSecondary),
              ),
              SizedBox(height: 8.h),
              TextButton(
                onPressed: () => _openArticle(learningTopic.units[2].article),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('看白話解析', style: TextStyle(fontWeight: FontWeight.bold)),
                    SizedBox(width: 4.w),
                    Icon(Icons.arrow_forward, size: 14.sp),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildUnitStepRow(LearningTopicUnit unit, bool isDone) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(
        isDone ? Icons.check_circle_rounded : Icons.radio_button_off_rounded,
        color: isDone ? HomeV2Palette.trustGreen : Colors.grey,
        size: 20.sp,
      ),
      title: Text(
        '${unit.stepLabel}：${unit.title}',
        style: TextStyle(
          fontSize: 13.sp,
          fontWeight: FontWeight.bold,
          decoration: isDone ? TextDecoration.lineThrough : null,
          color: isDone ? AppColors.textMuted : AppColors.textPrimary,
        ),
      ),
      subtitle: Text(
        '${unit.goal} • ${unit.readTime}',
        style: TextStyle(fontSize: 11.sp),
      ),
      trailing: Icon(Icons.chevron_right_rounded, size: 18.sp),
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (__) => LearningMockDetailPage(
              article: unit.article,
              unitStepLabel: unit.stepLabel, // 用來讓詳情頁面知道要解鎖哪一個 STEP
            ),
          ),
        );
      },
    );
  }

  Widget _buildChatBubble({required String sender, required String text, required bool isMe}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
      children: [
        if (!isMe) ...[
          CircleAvatar(
            radius: 14.r,
            backgroundColor: Colors.grey.shade300,
            child: Text(sender.substring(0, 1), style: TextStyle(fontSize: 11.sp)),
          ),
          SizedBox(width: 8.w),
        ],
        Flexible(
          child: Column(
            crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
            children: [
              Text(sender, style: TextStyle(fontSize: 9.sp, color: Colors.grey)),
              SizedBox(height: 2.h),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                decoration: BoxDecoration(
                  color: isMe 
                      ? HomeV2Palette.mint 
                      : (isDark ? const Color(0xFF26303D) : const Color(0xFFE8E8E8)),
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
            child: Text(sender.substring(0, 1), style: TextStyle(fontSize: 11.sp, color: HomeV2Palette.trustGreen)),
          ),
        ],
      ],
    );
  }

  // ────────────────────────────────────────────────────────
  // 🧰 Tab 2: 生活工具箱
  // ────────────────────────────────────────────────────────
  Widget _buildToolkitTab(LearningGameState gameState) {
    return ListView(
      controller: _scrollController,
      padding: EdgeInsets.fromLTRB(16.w, 10.h, 16.w, 40.h),
      physics: const BouncingScrollPhysics(),
      children: [
        // 1. 白話文翻譯機
        _buildTranslatorWidget(),
        SizedBox(height: 12.h),

        // 2. 文件與證據準備清單
        _buildEvidenceChecklistWidget(gameState),
        SizedBox(height: 12.h),

        // 3. 常用法規快查
        _buildStatuteSearchWidget(),
      ],
    );
  }

  // 1) 白話文翻譯機 Widget
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
      backgroundColor: isDark ? const Color(0xFF28241B) : const Color(0xFFFFFDF8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.gavel_rounded, color: const Color(0xFF94610D), size: 22.sp),
              SizedBox(width: 8.w),
              Text(
                '🧰 法律術語白話翻譯機',
                style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w900, color: AppColors.textPrimary),
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
              fillColor: isDark ? const Color(0xFF1E252D) : const Color(0xFFFFFAEC),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.r), borderSide: BorderSide.none),
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
                label: Text(term, style: TextStyle(fontSize: 11.sp, fontWeight: FontWeight.bold)),
                backgroundColor: isDark ? const Color(0xFF2C353F) : const Color(0xFFEAE5DB),
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
                    _translationOutput = _termsMap[text] ?? '白話翻譯：該詞彙正在整理中。法律概念通常指「依照規定做對應處置，並保障當事人權利」。';
                    LearningGameState.instance.incrementTranslatorUsage();
                  });
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF94610D),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
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
                color: isDark ? const Color(0xFF332B1E) : const Color(0xFFFFFAEC),
                borderRadius: BorderRadius.circular(10.r),
                border: Border.all(color: const Color(0xFFE4C179)),
              ),
              child: Text(
                _translationOutput,
                style: TextStyle(
                  fontSize: 12.5.sp,
                  height: 1.4,
                  color: isDark ? Colors.orange.shade100 : const Color(0xFF5D4017),
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
    final String currentTitle = _evidenceTabType == 0 ? '🚗 車禍責任釐清證據包' : '🏠 租屋點交扣押金證據包';

    return NotebookCard(
      hasBinderRings: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.checklist_rtl_rounded, color: HomeV2Palette.trustGreen, size: 24.sp),
              SizedBox(width: 8.w),
              Text(
                '📋 證據準備與文件清單',
                style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w900, color: AppColors.textPrimary),
              ),
            ],
          ),
          SizedBox(height: 8.h),
          
          // 車禍/租屋 切換
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
                  color: isChecked ? AppColors.textMuted : AppColors.textPrimary,
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
          
          // 按鈕
          Row(
            children: [
              ElevatedButton.icon(
                icon: const Icon(Icons.bookmark_add_outlined, size: 16),
                label: const Text('儲存備忘'),
                onPressed: () {
                  gameState.saveEvidenceList(currentTitle, _checkedEvidences.toList(), currentList);
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
                icon: const Icon(Icons.share, size: 16),
                label: const Text('導出 PDF'),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('成功導出證據清單 PDF！已儲存至本機檔案及成就室備忘錄。'),
                      backgroundColor: HomeV2Palette.trustGreen,
                    ),
                  );
                  // 同步也存一份
                  gameState.saveEvidenceList('$currentTitle (PDF 導出版)', _checkedEvidences.toList(), currentList);
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
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return NotebookCard(
      hasBookmark: true,
      bookmarkColor: const Color(0xFF6FA8DC),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.search_rounded, color: const Color(0xFF3F7FBF), size: 22.sp),
              SizedBox(width: 8.w),
              Text(
                '🔍 常用法規快速查詢',
                style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w900, color: AppColors.textPrimary),
              ),
            ],
          ),
          SizedBox(height: 10.h),
          
          // 快捷按鈕
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
      label: Text(label, style: TextStyle(fontSize: 11.sp, fontWeight: FontWeight.bold, color: const Color(0xFF1F4E87))),
      backgroundColor: isDark ? const Color(0xFF1F2B38) : const Color(0xFFE8F0FE),
      onPressed: () => _openStatuteDatabase(initialQuery: actual ?? label),
    );
  }
}

// ────────────────────────────────────────────────────────
// 🤖 智慧小法助輪播提問氣泡元件 (整合成就室開啟)
// ────────────────────────────────────────────────────────
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

    final bubbleBgColor = isDark ? const Color(0xFF1E2622) : const Color(0xFFF2FAF6);
    final bubbleBorderColor = isDark ? const Color(0xFF2E3C36) : const Color(0xFFD2E6DE);
    final textColor = isDark ? const Color(0xFF99C3B3) : const Color(0xFF1B4D3E);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // 左側大頭貼，點擊可以進入成就室
        GestureDetector(
          onTap: widget.onMascotTap,
          child: Tooltip(
            message: '開啟小法助成長檔案',
            child: Container(
              padding: EdgeInsets.all(2.w),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: HomeV2Palette.trustGreen, width: 1.5.w),
              ),
              child: Image.asset(
                'assets/images/assistant/law_assistant_home.png',
                width: 42.w,
                height: 42.w,
                fit: BoxFit.contain,
              ),
            ),
          ),
        ),
        SizedBox(width: 8.w),
        // 對話氣泡
        Expanded(
          child: GestureDetector(
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => LawAssistantSearchPage(initialPrompt: currentPrompt),
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
                    blurRadius: 8,
                    offset: const Offset(0, 4),
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
                        AnimatedSwitcher(
                          duration: const Duration(milliseconds: 300),
                          transitionBuilder: (child, animation) {
                            return FadeTransition(
                              opacity: animation,
                              child: SlideTransition(
                                position: Tween<Offset>(
                                  begin: const Offset(0.0, 0.2),
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
                      ],
                    ),
                  ),
                  SizedBox(width: 4.w),
                  Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: 11.sp,
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
          Icon(
            Icons.smart_toy_rounded,
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
              child: Icon(
                Icons.balance_rounded,
                size: 10.sp,
                color: assistantPalette.primaryText,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
