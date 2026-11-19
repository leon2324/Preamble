part of '../know_law_page.dart';

/// 法學課堂 Tab 外層容器。
///
/// 這個 widget 只包住原本在 KnowLawPageState 組出的 Tab 子項目，
/// 真正資料來源、互動狀態與視覺 helper 仍留在原本 state，避免 Step 4A 改到功能邏輯。
class LearningClassroomTab extends StatelessWidget {
  const LearningClassroomTab({super.key, required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: children,
    );
  }
}

extension LearningClassroomTabBuilder on KnowLawPageState {
  // 3) 法學課堂的列表項目
  // Mappings of recommendations: activeTopic -> [IllustrationTopic, DialogTopic]
  Widget buildLearningClassroomTab(bool isDark, LearningGameState gameState) {
    // 台灣繁體中文教學註解：正式來源空結果或失敗時沿用共用狀態元件，
    // 不把本機固定課程冒充今日雲端專題；自訂課程仍由使用者自行建立。
    if (!_isLoadingTopics && SupabaseLearningService.instance.isConfigured &&
        _dailyTopics.isEmpty && _customTopics.isEmpty) {
      return LearningClassroomTab(children: [
        _topicsLoadFailed
            ? AppErrorState(message: '每日專題暫時無法讀取。', onRetry: _initDailyTopics)
            : const AppEmptyState(title: '目前沒有每日專題', message: '請稍後再查看。'),
      ]);
    }
    if (_isLoadingTopics) {
      return LearningClassroomTab(children: [
        // 1. 公民法律小擂台入口 Banner
        NotebookCard(
          hasBookmark: true,
          bookmarkColor: const Color(0xFFE8B95F),
          backgroundColor: isDark ? const Color(0xFF161C23) : Colors.white,
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('公民法律小擂台',
                        style: TextStyle(
                            fontSize: 13.sp, fontWeight: FontWeight.w900)),
                    SizedBox(height: 4.h),
                    Text('挑戰每日一題法律隨堂考！',
                        style: TextStyle(
                            fontSize: 10.5.sp, color: AppColors.textSecondary)),
                  ],
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (__) => const MockCourtChallengePage(),
                    ),
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
        SizedBox(height: 12.h),

        // 1.5 法律手帳筆記本加強入口 Banner (高視覺優先級，微發光呼吸效果)
        BreathingGlowContainer(
          glowColor: const Color(0xFF4E7D5B),
          child: NotebookCard(
            hasBookmark: true,
            bookmarkColor: const Color(0xFF4E7D5B),
            backgroundColor:
                isDark ? const Color(0xFF1B241E) : const Color(0xFFF2F8F4),
            child: Row(
              children: [
                Container(
                  width: 40.w,
                  height: 40.w,
                  decoration: const BoxDecoration(
                    color: Color(0xFF8CAF96),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Icon(
                      Icons.edit_note_rounded,
                      size: 24.sp,
                      color: Colors.white,
                    ),
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '法治隨手記 & 標籤對照',
                        style: TextStyle(
                          fontSize: 14.5.sp,
                          fontWeight: FontWeight.w900,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      SizedBox(height: 2.h),
                      Text(
                        '記錄日常法學心得，隨時對照關聯法條！',
                        style: TextStyle(
                          fontSize: 10.5.sp,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                ElevatedButton(
                  onPressed: openNotebookTab,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4E7D5B),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                    padding: EdgeInsets.symmetric(horizontal: 14.w),
                  ),
                  child: const Text('開啟手帳'),
                ),
              ],
            ),
          ),
        ),
        SizedBox(height: 12.h),
        // Pulsing skeleton for switcher title/chips
        LearningPulsingSkeleton(width: 80.w, height: 16.h),
        SizedBox(height: 8.h),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: const NeverScrollableScrollPhysics(),
          child: Row(
            children: List.generate(
                4,
                (index) => Padding(
                      padding: EdgeInsets.only(right: 8.w),
                      child: LearningPulsingSkeleton(
                          width: 80.w,
                          height: 32.h,
                          borderRadius: BorderRadius.circular(999.r)),
                    )),
          ),
        ),
        SizedBox(height: 12.h),
        // Pulsing skeleton for Main Course Card
        LearningPulsingSkeleton(
            width: double.infinity,
            height: 260.h,
            borderRadius: BorderRadius.circular(16.r)),
      ]);
    }

    final currentTopic = _currentTopicData;
    final rentUnits = currentTopic.units;
    final completedRentCount = rentUnits
        .where((unit) => gameState.completedSteps
            .contains("${_activeTopic}_${unit.stepLabel}"))
        .length;
    final rentProgress =
        rentUnits.isEmpty ? 0.0 : completedRentCount / rentUnits.length;

    // 取得下方的獨立精選專題與對話專題資料，並動態生成一對一專屬文章
    final illuStory = fullIllustrationStories[
        _illuStoryIndex % fullIllustrationStories.length];
    final illuTargetArticle = generateArticleForIllustration(illuStory);

    final dialogStory =
        fullDialogStories[_dialogStoryIndex % fullDialogStories.length];
    final dialogTargetArticle = generateArticleForDialog(dialogStory);

    return LearningClassroomTab(children: [
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
                child: CaseLibrarySvgIcon(
                  CaseLibrarySvgIcons.award,
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
      SizedBox(height: 12.h),

      // 1.5 法律手帳筆記本加強入口 Banner (高視覺優先級，微發光呼吸效果)
      BreathingGlowContainer(
        glowColor: const Color(0xFF4E7D5B),
        child: NotebookCard(
          hasBookmark: true,
          bookmarkColor: const Color(0xFF4E7D5B),
          backgroundColor:
              isDark ? const Color(0xFF1B241E) : const Color(0xFFF2F8F4),
          child: Row(
            children: [
              Container(
                width: 40.w,
                height: 40.w,
                decoration: const BoxDecoration(
                  color: Color(0xFF8CAF96),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Icon(
                    Icons.edit_note_rounded,
                    size: 24.sp,
                    color: Colors.white,
                  ),
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '法治隨手記 & 標籤對照',
                      style: TextStyle(
                        fontSize: 14.5.sp,
                        fontWeight: FontWeight.w900,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      '記錄日常法學心得，隨時對照關聯法條！',
                      style: TextStyle(
                        fontSize: 10.5.sp,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              ElevatedButton(
                onPressed: openNotebookTab,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4E7D5B),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 14.w),
                ),
                child: const Text('開啟手帳'),
              ),
            ],
          ),
        ),
      ),
      SizedBox(height: 12.h),

      _buildDailyQuizCard(isDark, gameState),
      SizedBox(height: 12.h),

      _buildFeaturedTopicSwitcher(isDark),

      _buildMainCourseCard(
        isDark: isDark,
        gameState: gameState,
        rentUnits: rentUnits,
        completedRentCount: completedRentCount,
        rentProgress: rentProgress,
        topicData: currentTopic,
      ),

      _buildCustomClassroomCard(isDark),
      SizedBox(height: 12.h),

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
                CaseLibrarySvgIcon(
                  CaseLibrarySvgIcons.star,
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
                    illuStory.tag,
                    style: TextStyle(
                        fontSize: 9.5.sp,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF1F4E87)),
                  ),
                ),
                const Spacer(),
                GestureDetector(
                  onTap: _rotateIllustrationTopic,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '換主題',
                        style: TextStyle(
                          fontSize: 10.sp,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF1F4E87).withValues(alpha: 0.7),
                        ),
                      ),
                      SizedBox(width: 2.w),
                      Icon(
                        Icons.refresh,
                        size: 11.sp,
                        color: const Color(0xFF1F4E87).withValues(alpha: 0.7),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 10.h),
            Text(
              illuStory.title,
              style: TextStyle(
                fontSize: 14.5.sp,
                fontWeight: FontWeight.w900,
                color: AppColors.textPrimary,
              ),
            ),
            SizedBox(height: 6.h),
            Text(
              illuStory.description,
              style: TextStyle(
                  fontSize: 12.sp, height: 1.4, color: AppColors.textSecondary),
            ),
            SizedBox(height: 10.h),
            ElevatedButton.icon(
              icon: CaseLibrarySvgIcon(CaseLibrarySvgIcons.chevronRight,
                  size: 14.sp, color: Colors.white),
              label: const Text('研讀此案例'),
              onPressed: () => _openArticle(illuTargetArticle),
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
                CaseLibrarySvgIcon(
                  CaseLibrarySvgIcons.message,
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
                const Spacer(),
                GestureDetector(
                  onTap: _rotateDialogTopic,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '換一換',
                        style: TextStyle(
                          fontSize: 10.sp,
                          fontWeight: FontWeight.bold,
                          color:
                              HomeV2Palette.trustGreen.withValues(alpha: 0.78),
                        ),
                      ),
                      SizedBox(width: 2.w),
                      Icon(
                        Icons.refresh,
                        size: 11.sp,
                        color: HomeV2Palette.trustGreen.withValues(alpha: 0.78),
                      ),
                    ],
                  ),
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
                    sender: dialogStory.senderA,
                    text: dialogStory.textA,
                    isMe: false,
                    avatarInitial: dialogStory.avatarA,
                  ),
                  SizedBox(height: 8.h),
                  _buildChatBubble(
                    sender: dialogStory.senderB,
                    text: dialogStory.textB,
                    isMe: true,
                    avatarInitial: dialogStory.avatarB,
                  ),
                ],
              ),
            ),
            SizedBox(height: 10.h),
            Text(
              dialogStory.title,
              style: TextStyle(
                fontSize: 13.5.sp,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            SizedBox(height: 4.h),
            Text(
              dialogStory.description,
              style:
                  TextStyle(fontSize: 11.5.sp, color: AppColors.textSecondary),
            ),
            SizedBox(height: 8.h),
            TextButton(
              onPressed: () => _openArticle(dialogTargetArticle),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('看白話解析',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: HomeV2Palette.trustGreen,
                      )),
                  SizedBox(width: 4.w),
                  CaseLibrarySvgIcon(CaseLibrarySvgIcons.chevronRight,
                      size: 12.sp, color: HomeV2Palette.trustGreen),
                ],
              ),
            ),
          ],
        ),
      ),
    ]);
  }
}
