import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter/services.dart';
import 'package:lawapp/components/home/v2/home_v2_palette.dart';
import 'package:lawapp/components/home/v2/home_v2_primitives.dart';
import 'package:lawapp/data/mock_data/home/home_v2_mock_data.dart';
import 'package:lawapp/theme/app_colors.dart';

class HomeV2AiAssistantCard extends StatelessWidget {
  const HomeV2AiAssistantCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: HomeV2Palette.aiYellow,
        borderRadius: BorderRadius.circular(22.r),
        border: Border.all(color: const Color(0xFFE8B95F)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x14000000),
            blurRadius: 18,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 34.w,
                height: 34.w,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.72),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Icon(
                  Icons.psychology_alt_outlined,
                  color: const Color(0xFF94610D),
                  size: 22.sp,
                ),
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: Text(
                  'AI 法律輔助',
                  style: TextStyle(
                    color: const Color(0xFF5C3A07),
                    fontSize: 17.sp,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              const _BetaBadge(),
            ],
          ),
          SizedBox(height: 14.h),
          Text(
            '請描述你遇到的法律問題',
            style: TextStyle(
              color: const Color(0xFF5C3A07),
              fontSize: 17.sp,
              fontWeight: FontWeight.w900,
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            '越完整描述情境，越能提供精準的建議與法規來源。',
            style: TextStyle(
              color: const Color(0xFF8C651E),
              fontSize: 11.sp,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 14.h),
          Container(
            padding: EdgeInsets.fromLTRB(14.w, 10.h, 8.w, 10.h),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20.r),
              border: Border.all(color: const Color(0xFFE4C179)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    '例如：房東不退押金怎麼辦？',
                    style: TextStyle(
                      color: AppColors.textMuted,
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                Container(
                  width: 42.w,
                  height: 42.w,
                  decoration: const BoxDecoration(
                    color: HomeV2Palette.trustGreen,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.arrow_forward_rounded,
                    color: Colors.white,
                    size: 24.sp,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 12.h),
          Row(
            children: [
              Icon(
                Icons.lock_open_rounded,
                color: HomeV2Palette.trustGreen,
                size: 15.sp,
              ),
              SizedBox(width: 6.w),
              Expanded(
                child: Text(
                  '未登入也可使用基礎查詢，登入後可保存紀錄與追蹤案件。',
                  style: TextStyle(
                    color: const Color(0xFF6B4B14),
                    fontSize: 10.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class HomeV2QuickIssueGrid extends StatelessWidget {
  const HomeV2QuickIssueGrid({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 86.h,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemBuilder: (context, index) {
          final item = homeV2IssueItems[index];
          return Container(
            width: 74.w,
            padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 10.h),
            decoration: BoxDecoration(
              color: item.color,
              borderRadius: BorderRadius.circular(18.r),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  item.icon,
                  color: HomeV2Palette.trustGreen,
                  size: 25.sp,
                ),
                SizedBox(height: 7.h),
                FittedBox(
                  child: Text(
                    item.label,
                    style: TextStyle(
                      color: HomeV2Palette.trustGreen,
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ),
          );
        },
        separatorBuilder: (_, __) => SizedBox(width: 10.w),
        itemCount: homeV2IssueItems.length,
      ),
    );
  }
}

class HomeV2LawDatabaseCard extends StatelessWidget {
  const HomeV2LawDatabaseCard({super.key, required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(22.r),
      child: Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: HomeV2Palette.lawBlue,
          borderRadius: BorderRadius.circular(22.r),
          border: Border.all(color: const Color(0xFF9DCAFF)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.article_outlined,
                  color: const Color(0xFF1F4E87),
                  size: 26.sp,
                ),
                SizedBox(width: 10.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '法規資料庫',
                        style: TextStyle(
                          color: const Color(0xFF1F4E87),
                          fontSize: 17.sp,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      Text(
                        '查詢法條、條文、解釋函令',
                        style: TextStyle(
                          color: const Color(0xFF4C6D95),
                          fontSize: 11.sp,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 14.h),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18.r),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.search_rounded,
                    color: AppColors.textMuted,
                    size: 20.sp,
                  ),
                  SizedBox(width: 8.w),
                  Expanded(
                    child: Text(
                      '搜尋法條關鍵字，例如：民法 184',
                      style: TextStyle(
                        color: AppColors.textMuted,
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  CircleAvatar(
                    radius: 16.r,
                    backgroundColor: const Color(0xFF1F4E87),
                    child: Icon(
                      Icons.arrow_forward_rounded,
                      color: Colors.white,
                      size: 18.sp,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class HomeV2DailyMissionCard extends StatefulWidget {
  const HomeV2DailyMissionCard({
    super.key,
    required this.onAnsweredStateChanged,
    required this.onOpenMore,
  });

  final ValueChanged<bool> onAnsweredStateChanged;
  final VoidCallback onOpenMore;

  @override
  State<HomeV2DailyMissionCard> createState() => _HomeV2DailyMissionCardState();
}

/// 首頁版的小任務卡。
///
/// 台灣繁體中文教學註解：
/// 這裡刻意只放二選一與短回饋，讓首頁維持輕盈；
/// 若之後要做完整測驗，可另開子頁面承接。
class _HomeV2DailyMissionCardState extends State<HomeV2DailyMissionCard> {
  int _questionIndex = 0;
  int? _selectedIndex;
  bool _hasAnswered = false;

  HomeV2MissionItem get _question => homeV2MissionItems[_questionIndex];

  void _selectOption(int index) {
    if (_hasAnswered) return;

    HapticFeedback.selectionClick();

    setState(() {
      _selectedIndex = index;
      _hasAnswered = true;
    });
    widget.onAnsweredStateChanged(true);
  }

  void _showNextQuestion() {
    HapticFeedback.selectionClick();

    setState(() {
      _questionIndex = (_questionIndex + 1) % homeV2MissionItems.length;
      _selectedIndex = null;
      _hasAnswered = false;
    });
    widget.onAnsweredStateChanged(false);
  }

  @override
  Widget build(BuildContext context) {
    final question = _question;
    final isCorrect = _selectedIndex == question.correctIndex;
    final String? feedback = !_hasAnswered
        ? null
        : (isCorrect ? question.correctFeedback : question.incorrectFeedback);

    return HomeV2SurfaceCard(
      color: HomeV2Palette.lavender,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            question.question,
            style: TextStyle(
              color: HomeV2Palette.ink,
              fontSize: 15.sp,
              fontWeight: FontWeight.w900,
              height: 1.35,
            ),
          ),
          SizedBox(height: 12.h),
          Row(
            children: List.generate(question.options.length, (index) {
              final option = question.options[index];
              final isSelected = _selectedIndex == index;

              return Expanded(
                child: Padding(
                  padding: EdgeInsets.only(
                    right: index == 0 ? 8.w : 0,
                  ),
                  child: _AnswerPill(
                    label: option,
                    isSelected: isSelected,
                    isCorrect: index == question.correctIndex,
                    showResult: _hasAnswered,
                    onTap: () => _selectOption(index),
                  ),
                ),
              );
            }),
          ),
          if (_hasAnswered && feedback != null) ...[
            SizedBox(height: 12.h),
            _MissionFeedbackCard(
              title: isCorrect ? '答對了' : '再想一下',
              message: feedback,
              background:
                  isCorrect ? const Color(0xFFF8F6FF) : const Color(0xFFFFF7F1),
              borderColor:
                  isCorrect ? const Color(0xFFD9CDFB) : const Color(0xFFF2D2B7),
              accent:
                  isCorrect ? const Color(0xFF5940BC) : const Color(0xFFC47A42),
              icon: isCorrect
                  ? Icons.check_circle_outline_rounded
                  : Icons.tips_and_updates_outlined,
            ),
          ],
          SizedBox(height: 10.h),
          if (_hasAnswered)
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: _showNextQuestion,
                  style: TextButton.styleFrom(
                    foregroundColor: const Color(0xFF8A7BD3),
                    visualDensity: VisualDensity.compact,
                    padding:
                        EdgeInsets.symmetric(horizontal: 8.w, vertical: 6.h),
                  ),
                  child: const Text('換一題'),
                ),
                SizedBox(width: 6.w),
                TextButton.icon(
                  onPressed: widget.onOpenMore,
                  style: TextButton.styleFrom(
                    foregroundColor: const Color(0xFF6B55C8),
                    visualDensity: VisualDensity.compact,
                    padding:
                        EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
                  ),
                  icon: Icon(Icons.arrow_forward_rounded, size: 18.sp),
                  label: const Text('進入完整測驗'),
                ),
              ],
            ),
        ],
      ),
    );
  }
}

class HomeV2NewsletterCard extends StatelessWidget {
  const HomeV2NewsletterCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(14.w, 16.h, 14.w, 12.h),
      decoration: BoxDecoration(
        color: const Color(0xFFF6E8D7),
        borderRadius: BorderRadius.circular(24.r),
        border: Border.all(color: Colors.white.withValues(alpha: 0.72)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x128B6A3C),
            blurRadius: 18,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '狗咬人，主人要賠？！',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: const Color(0xFF2B4499),
                        fontSize: 17.sp,
                        fontWeight: FontWeight.w800,
                        height: 1.15,
                      ),
                    ),
                    SizedBox(height: 10.h),
                    Text(
                      '根據《民法》第 195 條，飼主有責任控管動物。若狗咬人，可能得賠醫藥費、精神損失費等。',
                      maxLines: 4,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 11.sp,
                        height: 1.45,
                      ),
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      '小提醒：遛狗記得繫牽繩，也別忘記植晶片喔！',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: const Color(0xFF3F8B2A),
                        fontSize: 10.sp,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: 12.w),
              Container(
                width: 112.w,
                height: 104.h,
                decoration: BoxDecoration(
                  color: const Color(0xFFD2BE98),
                  borderRadius: BorderRadius.circular(20.r),
                ),
                child: Icon(
                  Icons.pets_rounded,
                  color: Colors.white,
                  size: 38.sp,
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          const Row(
            children: [
              _NewsletterMetric(
                icon: Icons.favorite_border_rounded,
                color: Color(0xFFD85A53),
                label: '300+',
              ),
              _NewsletterMetric(
                icon: Icons.share_outlined,
                color: Color(0xFF9B874A),
                label: '100+',
              ),
              _NewsletterMetric(
                icon: Icons.comment_rounded,
                color: Color(0xFF4F8F36),
                label: '100+',
              ),
              _NewsletterMetric(
                icon: Icons.download_rounded,
                color: Color(0xFF4A8E88),
                label: '500+',
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class HomeV2DiscussionCard extends StatelessWidget {
  const HomeV2DiscussionCard({super.key});

  @override
  Widget build(BuildContext context) {
    return HomeV2SurfaceCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const HomeV2TinyLabel(
            icon: Icons.forum_outlined,
            label: '熱門討論',
            color: HomeV2Palette.trustGreen,
          ),
          SizedBox(height: 8.h),
          Text(
            '即將釋憲，究竟廢死還是維持死刑？',
            style: TextStyle(
              color: HomeV2Palette.ink,
              fontSize: 16.sp,
              fontWeight: FontWeight.w900,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            '由查詢次數、新聞熱度與社群討論訊號彙整，協助一般民眾理解爭點。',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 11.sp,
              height: 1.45,
            ),
          ),
          SizedBox(height: 12.h),
          const Row(
            children: [
              _MetricChip(label: '熱度 92'),
              _MetricChip(label: '上升 12%'),
              _MetricChip(label: '#憲法'),
            ],
          ),
        ],
      ),
    );
  }
}

class HomeV2TopicSeries extends StatelessWidget {
  const HomeV2TopicSeries({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 138.h,
      child: ListView(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        children: homeV2TopicItems
            .map(
              (item) => _TopicCard(
                title: item.title,
                subtitle: item.subtitle,
                color: item.color,
                icon: item.icon,
              ),
            )
            .toList(growable: false),
      ),
    );
  }
}

class _BetaBadge extends StatelessWidget {
  const _BetaBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.72),
        borderRadius: BorderRadius.circular(99.r),
      ),
      child: Text(
        'Beta',
        style: TextStyle(
          color: const Color(0xFF94610D),
          fontSize: 10.sp,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class _AnswerPill extends StatelessWidget {
  const _AnswerPill({
    required this.label,
    required this.onTap,
    this.isSelected = false,
    this.isCorrect = false,
    this.showResult = false,
  });

  final String label;
  final VoidCallback onTap;
  final bool isSelected;
  final bool isCorrect;
  final bool showResult;

  @override
  Widget build(BuildContext context) {
    final Color background;
    final Color borderColor;
    final Color textColor;

    if (showResult && isSelected && isCorrect) {
      background = const Color(0xFFE7F7EB);
      borderColor = const Color(0xFF8AC89B);
      textColor = const Color(0xFF2E7D4D);
    } else if (showResult && isSelected && !isCorrect) {
      background = const Color(0xFFFFF0F0);
      borderColor = const Color(0xFFE4A3A3);
      textColor = const Color(0xFFB24C4C);
    } else {
      background = Colors.white;
      borderColor =
          isSelected ? const Color(0xFFBDAAF7) : const Color(0xFFD6CDF8);
      textColor = const Color(0xFF5D4AB5);
    }

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16.r),
        child: Container(
          alignment: Alignment.centerLeft,
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
          decoration: BoxDecoration(
            color: background,
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(color: borderColor),
          ),
          child: Text(
            label,
            textAlign: TextAlign.left,
            style: TextStyle(
              color: textColor,
              fontSize: 12.sp,
              fontWeight: FontWeight.w800,
              height: 1.4,
            ),
          ),
        ),
      ),
    );
  }
}

class _MissionFeedbackCard extends StatelessWidget {
  const _MissionFeedbackCard({
    required this.title,
    required this.message,
    required this.background,
    required this.borderColor,
    required this.accent,
    required this.icon,
  });

  final String title;
  final String message;
  final Color background;
  final Color borderColor;
  final Color accent;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(12.w, 11.h, 12.w, 11.h),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: borderColor),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: accent, size: 18.sp),
          SizedBox(width: 8.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: accent,
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  message,
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 11.sp,
                    height: 1.45,
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

class _NewsletterMetric extends StatelessWidget {
  const _NewsletterMetric({
    required this.icon,
    required this.color,
    required this.label,
  });

  final IconData icon;
  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color.withValues(alpha: 0.92), size: 17.sp),
            SizedBox(width: 4.w),
            Text(
              label,
              style: TextStyle(
                color: HomeV2Palette.ink.withValues(alpha: 0.72),
                fontSize: 11.sp,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MetricChip extends StatelessWidget {
  const _MetricChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(right: 8.w),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 9.w, vertical: 6.h),
        decoration: BoxDecoration(
          color: HomeV2Palette.mint,
          borderRadius: BorderRadius.circular(99.r),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: HomeV2Palette.trustGreen,
            fontSize: 11.sp,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }
}

class _TopicCard extends StatelessWidget {
  const _TopicCard({
    required this.title,
    required this.subtitle,
    required this.color,
    required this.icon,
  });

  final String title;
  final String subtitle;
  final Color color;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 168.w,
      margin: EdgeInsets.only(right: 12.w),
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(22.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: HomeV2Palette.trustGreen, size: 28.sp),
          const Spacer(),
          Text(
            title,
            style: TextStyle(
              color: HomeV2Palette.ink,
              fontSize: 15.sp,
              fontWeight: FontWeight.w900,
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            subtitle,
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 12.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
