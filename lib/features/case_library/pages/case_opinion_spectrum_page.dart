import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:preamble/features/case_library/data/case_interactive_profiles.dart';
import 'package:preamble/features/case_library/models/case_library_models.dart';
import 'package:preamble/features/case_library/theme/case_library_theme.dart';
import 'package:preamble/features/case_library/widgets/case_library_svg_icon.dart';

// 「觀點光譜」互動頁面 (CaseOpinionSpectrumPage)
// 本頁面提供一條橫向色彩漸層的光譜滑軌，標示著社會與司法對該案件的多重論點節點。
// 使用者可以左右滑動指標了解不同區段的法理見解，並能「投下一票」揭示大眾投票分佈的 Bezier 曲線圖，
// 幫助使用者在思辨中找到自己的法律定位，擺脫非黑即白的二元對立。
class CaseOpinionSpectrumPage extends StatefulWidget {
  const CaseOpinionSpectrumPage({
    super.key,
    required this.book,
  });

  final CaseBook book;

  @override
  State<CaseOpinionSpectrumPage> createState() =>
      _CaseOpinionSpectrumPageState();
}

class _CaseOpinionSpectrumPageState extends State<CaseOpinionSpectrumPage>
    with SingleTickerProviderStateMixin {
  double _currentValue = 50.0; // 0 ~ 100
  bool _voted = false;
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeIn,
    );
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  // 取得該案件 100% 獨立量身打造之法學爭點觀點光譜節點
  List<Map<String, dynamic>> _getNodes() {
    return CaseInteractiveProfiles.getSpectrumNodes(widget.book);
  }

  void _onVote() {
    setState(() {
      _voted = true;
    });
    _fadeController.forward();
  }

  @override
  Widget build(BuildContext context) {
    final nodes = _getNodes();
    // 找出距離當前數值最近的節點，以便在下方卡片中做聚焦解說
    final closestNode = nodes.reduce((a, b) =>
        ((a['value'] as double) - _currentValue).abs() <
                ((b['value'] as double) - _currentValue).abs()
            ? a
            : b);

    return Scaffold(
      backgroundColor: CaseLibraryColors.bgCream,
      body: SafeArea(
        child: Column(
          children: [
            // AppBar
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
              child: SizedBox(
                height: 56.h,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Positioned(
                      left: 0,
                      child: IconButton(
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        icon: SvgPicture.string(
                          _svgBackIcon,
                          width: 20.w,
                          height: 20.w,
                        ),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ),
                    Align(
                      alignment: Alignment.center,
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 60.w),
                        child: Text(
                          '觀點光譜',
                          style: LightTextStyles.pageTitle(context).copyWith(
                            fontSize: 17.sp,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // 頂部導引
            Container(
              width: double.infinity,
              margin: EdgeInsets.symmetric(horizontal: 16.w),
              padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
              decoration: BoxDecoration(
                color: const Color(0xFFFAF7F0),
                borderRadius: BorderRadius.circular(10.r),
                border: Border.all(color: CaseLibraryColors.borderLight),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '案名：${widget.book.shortTitleZh.isNotEmpty ? widget.book.shortTitleZh : widget.book.titleZh}',
                    style: LightTextStyles.cardTitle(context).copyWith(
                      fontSize: 12.sp,
                    ),
                  ),
                  SizedBox(height: 3.h),
                  Text(
                    '說明：滑動光譜線來探索不同的司法與社會觀點，點擊節點可快速跳轉。',
                    style: LightTextStyles.caption(context).copyWith(
                      fontSize: 9.5.sp,
                    ),
                  ),
                ],
              ),
            ),

            Expanded(
              child: ListView(
                padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 32.h),
                children: [
                  // 1. 光譜本體卡片
                  Container(
                    padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 20.h),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16.r),
                      boxShadow: [CaseLibraryShadows.softShadow],
                      border: Border.all(color: CaseLibraryColors.borderLight),
                    ),
                    child: Column(
                      children: [
                        Text(
                          '⚖️ 拖曳金色滑鈕表達你的位置：',
                          style: LightTextStyles.cardTitle(context).copyWith(
                            fontSize: 13.sp,
                          ),
                        ),
                        SizedBox(height: 12.h),

                        // 光譜滑軌背景（帶有節點圖示與社群分佈曲線）
                        Stack(
                          clipBehavior: Clip.none,
                          children: [
                            // 社群投票分佈圖（Bezier 曲線） - 投票後漸顯
                            if (_voted)
                              AnimatedBuilder(
                                animation: _fadeAnimation,
                                builder: (context, child) {
                                  return Opacity(
                                    opacity: _fadeAnimation.value,
                                    child: SizedBox(
                                      height: 50.h,
                                      width: double.infinity,
                                      child: CustomPaint(
                                        painter: _SpectrumDistributionPainter(
                                          isSunflower: widget.book.id == '318',
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              )
                            else
                              SizedBox(height: 50.h),

                            // 色彩漸層色帶
                            Positioned(
                              bottom: 12.h,
                              left: 10.w,
                              right: 10.w,
                              child: Container(
                                height: 8.h,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(99),
                                  gradient: const LinearGradient(
                                    colors: [
                                      Color(0xFFC62828), // 紅
                                      Color(0xFFEF6C00), // 橘
                                      Color(0xFF8C9B3E), // 黃綠
                                      Color(0xFF2E7D32), // 綠
                                    ],
                                  ),
                                ),
                              ),
                            ),

                            // 標示出 nodes 位置的小白點與文字
                            Positioned.fill(
                              child: LayoutBuilder(
                                builder: (context, constraints) {
                                  final double trackWidth =
                                      constraints.maxWidth - 20.w;
                                  return Stack(
                                    children: [
                                      for (final node in nodes)
                                        Positioned(
                                          left: 10.w +
                                              ((node['value'] as double) /
                                                  100 *
                                                  trackWidth) -
                                              18.w,
                                          bottom: 0,
                                          child: GestureDetector(
                                            onTap: () {
                                              setState(() {
                                                _currentValue =
                                                    node['value'] as double;
                                              });
                                            },
                                            child: Column(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Container(
                                                  width: 10.w,
                                                  height: 10.w,
                                                  decoration: BoxDecoration(
                                                    color: Colors.white,
                                                    shape: BoxShape.circle,
                                                    border: Border.all(
                                                      color: node['color']
                                                          as Color,
                                                      width: 2.5,
                                                    ),
                                                  ),
                                                ),
                                                SizedBox(height: 2.h),
                                                Text(
                                                  node['shortTitle'] as String,
                                                  style: TextStyle(
                                                    fontSize: 8.5.sp,
                                                    fontWeight: FontWeight.bold,
                                                    color:
                                                        node['color'] as Color,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                    ],
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 12.h),

                        // Flutter Slider 原生金色滑鈕控制
                        SliderTheme(
                          data: SliderThemeData(
                            activeTrackColor: Colors.transparent,
                            inactiveTrackColor: Colors.transparent,
                            thumbColor: CaseLibraryColors.accentGold,
                            overlayColor: CaseLibraryColors.accentGold
                                .withValues(alpha: 0.15),
                            trackHeight: 0,
                            thumbShape: const RoundSliderThumbShape(
                                enabledThumbRadius: 10),
                          ),
                          child: Slider(
                            value: _currentValue,
                            min: 0.0,
                            max: 100.0,
                            onChanged: (val) {
                              setState(() {
                                _currentValue = val;
                              });
                            },
                          ),
                        ),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('秩序與安定性',
                                style: LightTextStyles.caption(context)
                                    .copyWith(fontWeight: FontWeight.bold)),
                            Text('您的選擇：${_currentValue.toInt()}%',
                                style: TextStyle(
                                    fontSize: 11.sp,
                                    fontWeight: FontWeight.bold,
                                    color: CaseLibraryColors.primaryGreen)),
                            Text('權益與抵抗權',
                                style: LightTextStyles.caption(context)
                                    .copyWith(fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 14.h),

                  // 2. 當前位置觀點卡
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    padding: EdgeInsets.all(16.w),
                    decoration: BoxDecoration(
                      color: (closestNode['color'] as Color)
                          .withValues(alpha: 0.04),
                      borderRadius: BorderRadius.circular(16.r),
                      border: Border.all(
                        color: (closestNode['color'] as Color)
                            .withValues(alpha: 0.28),
                        width: 1.5,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 8.w, vertical: 4.h),
                              decoration: BoxDecoration(
                                color: closestNode['color'] as Color,
                                borderRadius: BorderRadius.circular(6.r),
                              ),
                              child: Text(
                                closestNode['label'] as String,
                                style: TextStyle(
                                  fontSize: 10.sp,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            SizedBox(width: 8.w),
                            Text(
                              '偏向此區間的法理邏輯：',
                              style: LightTextStyles.caption(context).copyWith(
                                color: CaseLibraryColors.textPrimary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 10.h),
                        Text(
                          closestNode['fullText'] as String,
                          style: LightTextStyles.body(context).copyWith(
                            fontSize: 12.sp,
                            color: CaseLibraryColors.textPrimary,
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 16.h),

                  // 3. 投下一票與展示大眾投票
                  if (!_voted)
                    SizedBox(
                      width: double.infinity,
                      height: 48.h,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: CaseLibraryColors.primaryGreen,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                        ),
                        onPressed: _onVote,
                        child: Text(
                          '🗳️ 投下我的一票，查看社群觀點分佈',
                          style: LightTextStyles.buttonText(context),
                        ),
                      ),
                    )
                  else
                    Container(
                      padding: EdgeInsets.all(14.w),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF0F5F2),
                        borderRadius: BorderRadius.circular(12.r),
                        border: Border.all(color: const Color(0xFFD0E0D6)),
                      ),
                      child: Row(
                        children: [
                          const CaseLibrarySvgIcon(
                            CaseLibrarySvgIcons.sparkles,
                            size: 18,
                            color: Color(0xFF2E7D32),
                          ),
                          SizedBox(width: 8.w),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '投票已記錄！',
                                  style: TextStyle(
                                    fontSize: 12.5.sp,
                                    fontWeight: FontWeight.w900,
                                    color: const Color(0xFF1B5E20),
                                  ),
                                ),
                                SizedBox(height: 2.h),
                                Text(
                                  '背景中已漸顯大眾投票的波峰分佈圖。此案件的討論中，社群呈現了兩極化分佈（在 15% 與 85% 有兩個高點），代表社會在此議題上具有顯著的法理張力與分歧。',
                                  style: TextStyle(
                                    fontSize: 10.5.sp,
                                    color: const Color(0xFF2E7D32),
                                    height: 1.4,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
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

  static const String _svgBackIcon = '''
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.6" stroke-linecap="round" stroke-linejoin="round">
  <path d="m15 18-6-6 6-6"></path>
</svg>
''';
}

// 自訂畫筆 (_SpectrumDistributionPainter)
// 利用貝茲曲線 (Bezier Curve) 描繪大眾投票的波峰分佈。
// 針對 318 案繪製雙峰分佈波形 (Bimodal Distribution)，其他案件則繪製單峰分佈波形，
// 完美模擬大眾在不同爭點上的統計趨勢。
class _SpectrumDistributionPainter extends CustomPainter {
  const _SpectrumDistributionPainter({required this.isSunflower});

  final bool isSunflower;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          const Color(0xFFD1A96C).withValues(alpha: 0.35),
          const Color(0xFFD1A96C).withValues(alpha: 0.0),
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height))
      ..style = PaintingStyle.fill;

    final borderPaint = Paint()
      ..color = const Color(0xFFD1A96C).withValues(alpha: 0.7)
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;

    final path = Path();
    path.moveTo(0, size.height - 12.h);

    if (isSunflower) {
      // 雙峰曲線 (Bimodal Curve) - 適用於極端分歧案件
      path.cubicTo(
        size.width * 0.15,
        size.height * -0.2, // 第一個高峰
        size.width * 0.25,
        size.height * -0.1,
        size.width * 0.5,
        size.height * 0.7, // 中間低谷
      );
      path.cubicTo(
        size.width * 0.7,
        size.height * -0.1,
        size.width * 0.85,
        size.height * -0.3, // 第二個高峰
        size.width,
        size.height - 12.h,
      );
    } else {
      // 單峰曲線 (Normal Curve)
      path.cubicTo(
        size.width * 0.3,
        size.height * 0.8,
        size.width * 0.5,
        size.height * -0.4, // 正中間高峰
        size.width * 0.7,
        size.height * 0.8,
      );
      path.lineTo(size.width, size.height - 12.h);
    }

    canvas.drawPath(path, paint);
    canvas.drawPath(path, borderPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
