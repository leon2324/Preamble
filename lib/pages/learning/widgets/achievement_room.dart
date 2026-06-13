import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lawapp/data/learning/learning_game_state.dart';
import 'package:lawapp/pages/learning/widgets/notebook_aesthetics.dart';
import 'package:lawapp/theme/app_colors.dart';
import 'package:lawapp/components/home/v2/home_v2_palette.dart';
import 'package:lawapp/data/mock_data/learning/learning_mock_data.dart';
import 'package:intl/intl.dart';

class AchievementRoomPage extends StatefulWidget {
  const AchievementRoomPage({super.key});

  @override
  State<AchievementRoomPage> createState() => _AchievementRoomPageState();
}

class _AchievementRoomPageState extends State<AchievementRoomPage> {
  // 模擬徽章資訊
  final List<Map<String, dynamic>> _badgesInfo = [
    {
      'name': '初學乍練',
      'icon': '🌱',
      'color': const Color(0xFFE2F0D9),
      'desc': '加入法學學堂並開始學習。',
    },
    {
      'name': '租屋達人',
      'icon': '🏠',
      'color': const Color(0xFFFFF2CC),
      'desc': '通關「租屋糾紛」所有單元即可解鎖。',
    },
    {
      'name': '車禍防護',
      'icon': '🚗',
      'color': const Color(0xFFFCE4D6),
      'desc': '通關「車禍訴訟」課堂並答對測驗解鎖。',
    },
    {
      'name': '職場精英',
      'icon': '💼',
      'color': const Color(0xFFE8F0FE),
      'desc': '通關「職場權益」課堂單元解鎖。',
    },
    {
      'name': '網路先鋒',
      'icon': '📱',
      'color': const Color(0xFFEAF0F8),
      'desc': '通關「肖像權與社群發文」課堂解鎖。',
    },
    {
      'name': '消費專家',
      'icon': '🛍️',
      'color': const Color(0xFFFDE8E8),
      'desc': '通關「網購退貨與消保」課堂解鎖。',
    },
    {
      'name': '擂台霸主',
      'icon': '🏆',
      'color': const Color(0xFFFFF0C2),
      'desc': '在「公民法律小擂台」獲得全對。',
    },
    {
      'name': '翻譯大師',
      'icon': '🧰',
      'color': const Color(0xFFE1F5FE),
      'desc': '使用過「白話文翻譯機」達 3 次。',
    },
    {
      'name': '備忘行家',
      'icon': '💾',
      'color': const Color(0xFFECEFF1),
      'desc': '導出或儲存過一份證據準備清單。',
    },
  ];

  @override
  Widget build(BuildContext context) {
    final gameState = LearningGameState.instance;

    return Scaffold(
      appBar: AppBar(
        title: const Text('小法助成長檔案與成就室'),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
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
              ],
            ),
          );
        },
      ),
    );
  }

  // 1. 吉祥物狀態卡
  Widget _buildMascotStatusCard(LearningGameState gameState) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return NotebookCard(
      hasPaperClip: true,
      backgroundColor: isDark ? const Color(0xFF1B222B) : const Color(0xFFFDFBF7),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // 吉祥物表情大圖
          Container(
            width: 80.w,
            height: 80.w,
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF26303D) : const Color(0xFFF3EDE0),
              shape: BoxShape.circle,
              border: Border.all(
                color: isDark ? const Color(0xFF354454) : const Color(0xFFE4D9C4),
                width: 2.w,
              ),
            ),
            child: Center(
              child: Text(
                gameState.mascotExpression,
                style: TextStyle(fontSize: 44.sp),
              ),
            ),
          ),
          SizedBox(width: 16.w),
          // 稱號與經驗條
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                  decoration: BoxDecoration(
                    color: HomeV2Palette.aiYellow,
                    borderRadius: BorderRadius.circular(8.r),
                    border: Border.all(color: const Color(0xFFE8B95F)),
                  ),
                  child: Text(
                    'Level ${gameState.level}：${gameState.levelTitle}',
                    style: TextStyle(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w900,
                      color: HomeV2Palette.ink,
                    ),
                  ),
                ),
                SizedBox(height: 8.h),
                Text(
                  '經驗值：${gameState.experience} / ${gameState.nextLevelXp} XP',
                  style: TextStyle(
                    fontSize: 11.5.sp,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textSecondary,
                  ),
                ),
                SizedBox(height: 6.h),
                // 進度條
                ClipRRect(
                  borderRadius: BorderRadius.circular(99.r),
                  child: LinearProgressIndicator(
                    value: gameState.experience / gameState.nextLevelXp,
                    minHeight: 10.h,
                    backgroundColor: isDark ? const Color(0xFF2D3845) : const Color(0xFFEFECE6),
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      HomeV2Palette.trustGreen,
                    ),
                  ),
                ),
                SizedBox(height: 6.h),
                Text(
                  gameState.level >= 3 
                      ? '已達到最高等級！您已是法學大師 🎉' 
                      : '再獲得 ${gameState.nextLevelXp - gameState.experience} XP 即可升級解鎖下一個表情與稱號',
                  style: TextStyle(
                    fontSize: 9.5.sp,
                    color: AppColors.textMuted,
                  ),
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
              Icon(Icons.military_tech_rounded, color: const Color(0xFFE8B95F), size: 24.sp),
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
              final isUnlocked = gameState.unlockedBadges.contains(badge['name']);

              return GestureDetector(
                onTap: () => _showBadgeDetail(badge, isUnlocked),
                child: Container(
                  decoration: BoxDecoration(
                    color: isUnlocked 
                        ? badge['color'] 
                        : (isDark ? const Color(0xFF1E252D) : const Color(0xFFF5F5F5)),
                    borderRadius: BorderRadius.circular(14.r),
                    border: Border.all(
                      color: isUnlocked 
                          ? Colors.transparent 
                          : (isDark ? const Color(0xFF2D3845) : const Color(0xFFE0E0E0)),
                      width: 1.w,
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // 灰階或彩色
                      isUnlocked 
                          ? Text(badge['icon'], style: TextStyle(fontSize: 28.sp))
                          : ColorFiltered(
                              colorFilter: const ColorFilter.matrix([
                                0.2126, 0.7152, 0.0722, 0, 0,
                                0.2126, 0.7152, 0.0722, 0, 0,
                                0.2126, 0.7152, 0.0722, 0, 0,
                                0,      0,      0,      1, 0,
                              ]),
                              child: Text(badge['icon'], style: TextStyle(fontSize: 28.sp)),
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

  // 顯示徽章詳細資訊
  void _showBadgeDetail(Map<String, dynamic> badge, bool isUnlocked) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
          title: Row(
            children: [
              Text(badge['icon'], style: TextStyle(fontSize: 28.sp)),
              SizedBox(width: 8.w),
              Text(badge['name']),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                isUnlocked ? '🎉 恭喜！您已成功解鎖此榮譽徽章！' : '🔒 解鎖條件：',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: isUnlocked ? Colors.green.shade800 : Colors.red.shade800,
                ),
              ),
              SizedBox(height: 8.h),
              Text(badge['desc']),
              if (isUnlocked) ...[
                SizedBox(height: 12.h),
                Text(
                  '解鎖日期：${DateFormat('yyyy/MM/dd HH:mm').format(DateTime.now().subtract(const Duration(hours: 2)))}',
                  style: TextStyle(fontSize: 11.sp, color: AppColors.textSecondary),
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
              Icon(Icons.collections_bookmark_rounded, color: HomeV2Palette.trustGreen, size: 24.sp),
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
            leading: Icon(Icons.menu_book_rounded, color: const Color(0xFFE88B8B), size: 22.sp),
            title: Text(
              '📕 我的錯題本',
              style: TextStyle(fontSize: 13.5.sp, fontWeight: FontWeight.bold),
            ),
            subtitle: Text(
              '目前有 ${gameState.incorrectQuestions.length} 題答錯的題目',
              style: TextStyle(fontSize: 11.sp),
            ),
            trailing: Icon(Icons.chevron_right_rounded, size: 20.sp),
            onTap: () => _openIncorrectQuestions(gameState),
          ),
          const Divider(),

          // 證據清單入口
          ListTile(
            leading: Icon(Icons.save_as_rounded, color: const Color(0xFF6FA8DC), size: 22.sp),
            title: Text(
              '💾 儲存的證據清單',
              style: TextStyle(fontSize: 13.5.sp, fontWeight: FontWeight.bold),
            ),
            subtitle: Text(
              '目前已儲存 ${gameState.savedEvidenceLists.length} 份清單',
              style: TextStyle(fontSize: 11.sp),
            ),
            trailing: Icon(Icons.chevron_right_rounded, size: 20.sp),
            onTap: () => _openSavedEvidenceLists(gameState),
          ),
        ],
      ),
    );
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
                                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
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
                                icon: const Icon(Icons.delete_outline, color: Colors.grey),
                                onPressed: () {
                                  setState(() {
                                    gameState.incorrectQuestions.removeAt(index);
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
                            style: const TextStyle(color: Colors.red, fontWeight: FontWeight.w600),
                          ),
                          Text(
                            '正確答案：${item['correctAnswer']}',
                            style: const TextStyle(color: Colors.green, fontWeight: FontWeight.w600),
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
                              style: TextStyle(fontSize: 12.sp, color: AppColors.textSecondary, height: 1.4),
                            ),
                          ),
                          SizedBox(height: 12.h),
                          ElevatedButton.icon(
                            icon: const Icon(Icons.refresh_rounded),
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
    // 找出對應的 Quiz question
    final question = learningQuizQuestions.firstWhere(
      (q) => q.question == incorrectItem['question'],
      orElse: () => learningQuizQuestions.first,
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
                    style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold, color: HomeV2Palette.trustGreen),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 12.h),
                  Text(
                    question.question,
                    style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 14.h),
                  ...List.generate(question.options.length, (index) {
                    final opt = question.options[index];
                    final isSelected = tempSelectedIndex == index;
                    final isCorrect = isAnswered && opt.isCorrect;
                    final isWrong = isAnswered && isSelected && !opt.isCorrect;

                    Color cardBg = Colors.white;
                    Color borderCol = const Color(0xFFE8E4DC);
                    if (isCorrect) {
                      cardBg = const Color(0xFFEAF6E2);
                      borderCol = const Color(0xFF9EC979);
                    } else if (isWrong) {
                      cardBg = const Color(0xFFFBE8E7);
                      borderCol = const Color(0xFFE4A29D);
                    } else if (isSelected) {
                      cardBg = const Color(0xFFFFF7E6);
                      borderCol = const Color(0xFFE8B95F);
                    }

                    return Padding(
                      padding: EdgeInsets.only(bottom: 8.h),
                      child: InkWell(
                        onTap: isAnswered ? null : () {
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
                            opt.title,
                            style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w600),
                          ),
                        ),
                      ),
                    );
                  }),
                  SizedBox(height: 16.h),
                  if (!isAnswered)
                    FilledButton(
                      onPressed: tempSelectedIndex == null ? null : () {
                        setModalState(() {
                          isAnswered = true;
                          final pickedCorrect = question.options[tempSelectedIndex!].isCorrect;
                          if (pickedCorrect) {
                            // 答對了！移出錯題
                            LearningGameState.instance.removeIncorrectQuestion(question.question);
                          } else {
                            // 答錯，把當前答案更新進去
                            LearningGameState.instance.addIncorrectQuestion(
                              question.question,
                              question.options[tempSelectedIndex!].title,
                              question.options.firstWhere((o) => o.isCorrect).title,
                              question.explanation,
                            );
                          }
                        });
                      },
                      style: FilledButton.styleFrom(backgroundColor: HomeV2Palette.trustGreen),
                      child: const Text('送出答案'),
                    )
                  else ...[
                    Text(
                      question.options[tempSelectedIndex!].isCorrect ? '答對了！🎉 經驗值 +15' : '可惜又答錯了，再看一次白話解析吧！',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: question.options[tempSelectedIndex!].isCorrect ? Colors.green.shade800 : Colors.red.shade800,
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
                    final checkedItems = List<String>.from(item['checkedItems']);
                    final allItems = List<String>.from(item['allItems']);
                    final String timeStr = DateFormat('yyyy/MM/dd HH:mm').format(DateTime.parse(item['timestamp']));

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
                                icon: const Icon(Icons.delete_outline, color: Colors.grey),
                                onPressed: () {
                                  gameState.deleteEvidenceList(index);
                                },
                              ),
                            ],
                          ),
                          Text(
                            '儲存時間：$timeStr',
                            style: TextStyle(fontSize: 10.sp, color: AppColors.textMuted),
                          ),
                          SizedBox(height: 8.h),
                          ...allItems.map((name) {
                            final isChecked = checkedItems.contains(name);
                            return Padding(
                              padding: EdgeInsets.symmetric(vertical: 2.h),
                              child: Row(
                                children: [
                                  Icon(
                                    isChecked ? Icons.check_box_rounded : Icons.check_box_outline_blank_rounded,
                                    color: isChecked ? HomeV2Palette.trustGreen : Colors.grey,
                                    size: 18.sp,
                                  ),
                                  SizedBox(width: 8.w),
                                  Text(
                                    name,
                                    style: TextStyle(
                                      fontSize: 12.5.sp,
                                      decoration: isChecked ? TextDecoration.lineThrough : null,
                                      color: isChecked ? AppColors.textMuted : AppColors.textPrimary,
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
                                style: TextStyle(fontSize: 11.sp, fontWeight: FontWeight.bold, color: HomeV2Palette.trustGreen),
                              ),
                              const Spacer(),
                              ElevatedButton.icon(
                                icon: const Icon(Icons.share, size: 16),
                                label: const Text('導出清單'),
                                onPressed: () {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('已成功導出「${item['title']}」清單 PDF 到下載資料夾！'),
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
}
