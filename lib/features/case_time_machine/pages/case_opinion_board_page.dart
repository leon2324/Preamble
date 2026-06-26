import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:preamble/features/case_time_machine/models/case_time_machine_models.dart';
import 'package:preamble/features/case_time_machine/theme/case_time_machine_theme.dart';

class CaseOpinionBoardPage extends StatefulWidget {
  const CaseOpinionBoardPage({super.key, required this.book});

  final CaseBook book;

  @override
  State<CaseOpinionBoardPage> createState() => _CaseOpinionBoardPageState();
}

class _CaseOpinionBoardPageState extends State<CaseOpinionBoardPage> {
  final TextEditingController _opinionController = TextEditingController();
  final List<Map<String, dynamic>> _opinions = [];

  @override
  void initState() {
    super.initState();
    // 初始化一些莫蘭迪色便利貼，展示溫和、有理性的感性共鳴話語
    _opinions.addAll([
      {
        'id': '1',
        'text': '期待本案能促成更完備的食品溯源與原料稽查制度，保護消費大眾的餐桌安全。',
        'resonanceCount': 128,
        'color': const Color(0xFFEAF6EF), // 莫蘭迪綠
        'textColor': const Color(0xFF357A53),
        'rotation': -2.0, // 傾斜度增加擬真感
      },
      {
        'id': '2',
        'text': '司法裁判在實踐法規的同時，也應該與社會大眾的素樸法感進行更深度的對話。',
        'resonanceCount': 94,
        'color': const Color(0xFFF0EEF9), // 莫蘭迪紫
        'textColor': const Color(0xFF6D649A),
        'rotation': 1.5,
      },
      {
        'id': '3',
        'text': '此案讓我理解到，程序正義不只是冷冰冰的條文，更是守護人民人身自由的底線。',
        'resonanceCount': 205,
        'color': const Color(0xFFEAF4F7), // 莫蘭迪藍
        'textColor': const Color(0xFF4A7C8C),
        'rotation': -1.2,
      },
    ]);
  }

  @override
  void dispose() {
    _opinionController.dispose();
    super.dispose();
  }

  void _submitRawOpinion() {
    final rawText = _opinionController.text.trim();
    if (rawText.isEmpty) return;

    // 偵測情緒化字眼並提供 AI 溫柔潤飾建議
    final hasEmotion = rawText.contains('爛') ||
        rawText.contains('扯') ||
        rawText.contains('恐龍') ||
        rawText.contains('氣') ||
        rawText.contains('怒') ||
        rawText.contains('垃圾') ||
        rawText.contains('貪污');

    if (hasEmotion) {
      _showAiGroomingDialog(rawText);
    } else {
      _addNewOpinion(rawText);
    }
  }

  // 顯示男生小法助吉祥物溫柔引導的 AI 潤飾視窗，避免情緒出氣筒，轉化為有溫度的理性見解。
  void _showAiGroomingDialog(String rawText) {
    // 根據原情緒字眼進行 Mock 潤飾
    String polishedText =
        '本案的裁判標準與社會期待似乎存在一定落差，期許未來司法體系在重大法理裁決上能提供更多親民說明，深化司法公信力。';
    if (rawText.contains('油') || rawText.contains('頂新')) {
      polishedText = '對於民生食安案件，期待司法審判能在法條適用上落實源頭原料安全審查，建立企業在法律與誠信上的雙重防火牆。';
    } else if (rawText.contains('死刑')) {
      polishedText =
          '死刑制度之存廢涉及生命權、平等原則與重大社會秩序防衛之拉鋸，期盼司法程序能在程序嚴密性與被害人權益保障間，尋求更理性的對話空間。';
    }

    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.r),
          ),
          child: Padding(
            padding: EdgeInsets.all(20.w),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // 1. 男生小法助吉祥物 Avatar 與溫柔招呼
                Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: const Color(0xFFEAF6EF),
                      radius: 24.r,
                      child: Icon(
                        Icons.face_retouching_natural_rounded, // 模擬小法助吉祥物圖示
                        color: CaseTimeMachineColors.primaryGreen,
                        size: 28.sp,
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'AI 小法助來幫忙！',
                            style: TextStyle(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w900,
                              color: CaseTimeMachineColors.primaryGreen,
                            ),
                          ),
                          SizedBox(height: 2.h),
                          Text(
                            '要不要試試看這樣說，會讓你的看法更有思辨力量喔？',
                            style: TextStyle(
                              fontSize: 11.sp,
                              color: CaseTimeMachineColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16.h),
                // 2. 對照卡片一：原話 (感性抱怨)
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(12.w),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFAF8F5),
                    borderRadius: BorderRadius.circular(12.r),
                    border: Border.all(color: const Color(0xFFE6E2D8)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '原本的話：',
                        style: TextStyle(
                          fontSize: 10.5.sp,
                          color: CaseTimeMachineColors.textMuted,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        rawText,
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: const Color(0xFF8B3A3A), // 情緒紅
                          decoration: TextDecoration.lineThrough,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 8.h),
                // 3. 對照卡片二：AI 潤飾 (理性建設)
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(12.w),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEAF6EF),
                    borderRadius: BorderRadius.circular(12.r),
                    border: Border.all(color: const Color(0xFFD0E0D6)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '小法助潤飾版：',
                        style: TextStyle(
                          fontSize: 10.5.sp,
                          color: CaseTimeMachineColors.primaryGreen,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        polishedText,
                        style: TextStyle(
                          fontSize: 12.5.sp,
                          height: 1.45,
                          fontWeight: FontWeight.bold,
                          color: CaseTimeMachineColors.primaryGreen,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 20.h),
                // 4. 按鈕區
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: Text(
                        '修改內容',
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: CaseTimeMachineColors.textMuted,
                        ),
                      ),
                    ),
                    SizedBox(width: 8.w),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: CaseTimeMachineColors.primaryGreen,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.r),
                        ),
                      ),
                      onPressed: () {
                        Navigator.of(context).pop();
                        _addNewOpinion(polishedText);
                      },
                      child: Text(
                        '用小法助版貼上牆',
                        style: TextStyle(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.bold,
                        ),
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

  void _addNewOpinion(String text) {
    // 輪流分配莫蘭迪色系
    final List<Map<String, dynamic>> colors = [
      {
        'color': const Color(0xFFEAF6EF), // 綠
        'textColor': const Color(0xFF357A53),
      },
      {
        'color': const Color(0xFFF0EEF9), // 紫
        'textColor': const Color(0xFF6D649A),
      },
      {
        'color': const Color(0xFFEAF4F7), // 藍
        'textColor': const Color(0xFF4A7C8C),
      },
      {
        'color': const Color(0xFFFFF2CF), // 黃
        'textColor': const Color(0xFF9E7B2D),
      },
    ];

    final colorIndex = _opinions.length % colors.length;
    // 隨機在 [-2.5, 2.5] 之間產生小偏角，增加便利貼錯落美感
    final double rotation = ((_opinions.length * 1.7) % 5.0) - 2.5;

    setState(() {
      _opinions.insert(0, {
        'id': DateTime.now().millisecondsSinceEpoch.toString(),
        'text': text,
        'resonanceCount': 1,
        'color': colors[colorIndex]['color'],
        'textColor': colors[colorIndex]['textColor'],
        'rotation': rotation,
      });
      _opinionController.clear();
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('思辨便利貼貼上牆成功！'),
        duration: Duration(seconds: 1),
      ),
    );
  }

  void _toggleResonance(String id) {
    setState(() {
      final opinion = _opinions.firstWhere((o) => o['id'] == id);
      opinion['resonanceCount'] = opinion['resonanceCount'] + 1;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CaseTimeMachineColors.bgCream,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: CaseTimeMachineColors.bgCream,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            color: CaseTimeMachineColors.primaryGreen,
            size: 20.sp,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          '意見塗鴉牆',
          style: TextStyle(
            fontFamily: 'Songti TC',
            fontFamilyFallback: const ['Songti SC', 'STSong', 'PingFang TC'],
            fontSize: 16.sp,
            fontWeight: FontWeight.w800,
            color: CaseTimeMachineColors.primaryGreen,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            // 頂部導言
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
              child: Text(
                '貼上你的看法便利貼，點選 ❤️ 可對其他網友的理性心聲產生共鳴：',
                style: TextStyle(
                  fontSize: 11.5.sp,
                  fontWeight: FontWeight.bold,
                  color: CaseTimeMachineColors.primaryGreen,
                  height: 1.4,
                ),
              ),
            ),
            // 便利貼牆面 (錯落排列的 ListView)
            Expanded(
              child: ListView.builder(
                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.onDrag,
                padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 16.h),
                itemCount: _opinions.length,
                itemBuilder: (context, index) {
                  final opinion = _opinions[index];
                  return Transform.rotate(
                    angle: opinion['rotation'] * 3.14159 / 180,
                    child: Container(
                      margin: EdgeInsets.only(
                          bottom: 12.h,
                          left: (index % 2 == 0 ? 8 : 24).w,
                          right: (index % 2 == 0 ? 24 : 8).w),
                      padding: EdgeInsets.all(14.w),
                      decoration: BoxDecoration(
                        color: opinion['color'] as Color,
                        borderRadius: BorderRadius.circular(16.r),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.05),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                        border: Border.all(
                          color: (opinion['textColor'] as Color)
                              .withValues(alpha: 0.15),
                          width: 1.2,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            opinion['text'] as String,
                            style: TextStyle(
                              fontSize: 12.5.sp,
                              height: 1.5,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF2E332F),
                            ),
                          ),
                          SizedBox(height: 10.h),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              GestureDetector(
                                onTap: () =>
                                    _toggleResonance(opinion['id'] as String),
                                child: Container(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 8.w, vertical: 4.h),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.6),
                                    borderRadius: BorderRadius.circular(999),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.favorite_rounded,
                                        color: const Color(0xFFCD5C5C),
                                        size: 11.sp,
                                      ),
                                      SizedBox(width: 4.w),
                                      Text(
                                        '共鳴 ${opinion['resonanceCount']}',
                                        style: TextStyle(
                                          fontSize: 9.5.sp,
                                          fontWeight: FontWeight.bold,
                                          color: opinion['textColor'] as Color,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            // 輸入區 (小法助溫和引導)
            Container(
              padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 16.h),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20.r),
                  topRight: Radius.circular(20.r),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 10,
                    offset: const Offset(0, -4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _opinionController,
                      onTapOutside: (event) {
                        FocusManager.instance.primaryFocus?.unfocus();
                      },
                      style: TextStyle(fontSize: 12.5.sp),
                      decoration: InputDecoration(
                        hintText: '對本案說說你的理性與感性想法...',
                        hintStyle: TextStyle(
                          fontSize: 12.5.sp,
                          color: CaseTimeMachineColors.textMuted,
                        ),
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 14.w,
                          vertical: 10.h,
                        ),
                        fillColor: const Color(0xFFFAF8F5),
                        filled: true,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.r),
                          borderSide: BorderSide(
                            color: CaseTimeMachineColors.borderLight,
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.r),
                          borderSide: BorderSide(
                            color: CaseTimeMachineColors.borderLight,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.r),
                          borderSide: BorderSide(
                            color: CaseTimeMachineColors.primaryGreen,
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 8.w),
                  GestureDetector(
                    onTap: _submitRawOpinion,
                    child: Container(
                      padding: EdgeInsets.all(10.w),
                      decoration: BoxDecoration(
                        color: CaseTimeMachineColors.primaryGreen,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.send_rounded,
                        size: 16.sp,
                        color: Colors.white,
                      ),
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
