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
                            fontWeight: FontWeight.w600,
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
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(color: CaseLibraryColors.borderLight),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.book.shortTitleZh.isNotEmpty
                        ? widget.book.shortTitleZh
                        : widget.book.titleZh,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: LightTextStyles.cardTitle(context).copyWith(
                      fontSize: 13.sp,
                      color: CaseLibraryColors.primaryGreen,
                    ),
                  ),
                  SizedBox(height: 3.h),
                  Text(
                    '點擊下方立場圖卡或拖曳光譜游標，比較不同法理見解並投下你的立場。',
                    style: LightTextStyles.caption(context).copyWith(
                      fontSize: 10.5.sp,
                    ),
                  ),
                ],
              ),
            ),

            Expanded(
              child: ListView(
                padding: EdgeInsets.fromLTRB(16.w, 14.h, 16.w, 32.h),
                children: [
                  // 1. 光譜滑軌 + 立場節點膠囊列
                  Container(
                    padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 16.h),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16.r),
                      boxShadow: [CaseLibraryShadows.softShadow],
                      border: Border.all(color: CaseLibraryColors.borderLight),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                '你的光譜座標',
                                style:
                                    LightTextStyles.cardTitle(context).copyWith(
                                  fontSize: 13.5.sp,
                                ),
                              ),
                            ),
                            Container(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 10.w, vertical: 4.h),
                              decoration: BoxDecoration(
                                color: (closestNode['color'] as Color)
                                    .withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(999),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    '${_currentValue.toInt()}%',
                                    style: TextStyle(
                                      fontSize: 11.sp,
                                      fontWeight: FontWeight.w800,
                                      color: closestNode['color'] as Color,
                                    ),
                                  ),
                                  SizedBox(width: 6.w),
                                  Text(
                                    (closestNode['label'] as String?) ??
                                        (closestNode['shortTitle'] as String),
                                    style: TextStyle(
                                      fontSize: 11.sp,
                                      fontWeight: FontWeight.w800,
                                      color: closestNode['color'] as Color,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 14.h),
                        Container(
                          height: 10.h,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(99),
                            gradient: const LinearGradient(
                              colors: [
                                Color(0xFFC62828),
                                Color(0xFFEF6C00),
                                Color(0xFF8C9B3E),
                                Color(0xFF2E7D32),
                              ],
                            ),
                          ),
                        ),
                        SliderTheme(
                          data: SliderThemeData(
                            activeTrackColor: Colors.transparent,
                            inactiveTrackColor: Colors.transparent,
                            thumbColor: CaseLibraryColors.accentGold,
                            overlayColor: CaseLibraryColors.accentGold
                                .withValues(alpha: 0.18),
                            trackHeight: 0,
                            thumbShape: const RoundSliderThumbShape(
                              enabledThumbRadius: 10,
                            ),
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
                            Text(
                              '秩序與安定性',
                              style: LightTextStyles.caption(context).copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            Text(
                              '權益與抵抗權',
                              style: LightTextStyles.caption(context).copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 12.h),
                        Wrap(
                          spacing: 6.w,
                          runSpacing: 6.h,
                          children: nodes.map((node) {
                            final isSelected = node == closestNode;
                            final nodeColor = node['color'] as Color;
                            return InkWell(
                              onTap: () {
                                setState(() {
                                  _currentValue = node['value'] as double;
                                });
                              },
                              borderRadius: BorderRadius.circular(999),
                              child: Container(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 10.w, vertical: 5.h),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? nodeColor
                                      : nodeColor.withValues(alpha: 0.08),
                                  borderRadius: BorderRadius.circular(999),
                                  border: Border.all(
                                    color: isSelected
                                        ? nodeColor
                                        : nodeColor.withValues(alpha: 0.25),
                                  ),
                                ),
                                child: Text(
                                  node['shortTitle'] as String,
                                  style: TextStyle(
                                    fontSize: 11.sp,
                                    fontWeight: FontWeight.w700,
                                    color:
                                        isSelected ? Colors.white : nodeColor,
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 16.h),

                  // 2. 單一焦點立場詳解卡（投票後原地展開社群民意分佈，不重複列出）
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 220),
                    padding: EdgeInsets.all(16.w),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16.r),
                      border: Border.all(
                        color: (closestNode['color'] as Color)
                            .withValues(alpha: 0.45),
                        width: 1.4,
                      ),
                      boxShadow: [CaseLibraryShadows.softShadow],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 10.w,
                              height: 10.w,
                              decoration: BoxDecoration(
                                color: closestNode['color'] as Color,
                                shape: BoxShape.circle,
                              ),
                            ),
                            SizedBox(width: 8.w),
                            Expanded(
                              child: Text(
                                '${closestNode['shortTitle']} · 法理核心論據',
                                style: TextStyle(
                                  fontSize: 13.5.sp,
                                  fontWeight: FontWeight.w800,
                                  color: CaseLibraryColors.textPrimary,
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 10.h),
                        Text(
                          closestNode['fullText'] as String,
                          style: LightTextStyles.body(context).copyWith(
                            fontSize: 12.5.sp,
                            color: CaseLibraryColors.textSecondary,
                            height: 1.55,
                          ),
                        ),
                        if (_voted) ...[
                          SizedBox(height: 16.h),
                          const Divider(height: 1),
                          SizedBox(height: 14.h),
                          FadeTransition(
                            opacity: _fadeAnimation,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    const CaseLibrarySvgIcon(
                                      CaseLibrarySvgIcons.sparkles,
                                      size: 16,
                                      color: Color(0xFF2E7D32),
                                    ),
                                    SizedBox(width: 6.w),
                                    Expanded(
                                      child: Text(
                                        '已記錄你的立場：${closestNode['shortTitle']}',
                                        style: TextStyle(
                                          fontSize: 12.5.sp,
                                          fontWeight: FontWeight.w800,
                                          color: const Color(0xFF1B5E20),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 10.h),
                                SizedBox(
                                  height: 44.h,
                                  width: double.infinity,
                                  child: CustomPaint(
                                    painter: _SpectrumDistributionPainter(
                                      isSunflower: widget.book.id == '318',
                                    ),
                                  ),
                                ),
                                SizedBox(height: 10.h),
                                ...nodes.asMap().entries.map((entry) {
                                  final idx = entry.key;
                                  final node = entry.value;
                                  final nodeColor = node['color'] as Color;
                                  final pct = _computeNodeShare(
                                      nodes, idx, node == closestNode);
                                  return Padding(
                                    padding: EdgeInsets.only(bottom: 8.h),
                                    child: InkWell(
                                      onTap: () {
                                        setState(() {
                                          _currentValue =
                                              node['value'] as double;
                                        });
                                      },
                                      borderRadius: BorderRadius.circular(8.r),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              Expanded(
                                                child: Text(
                                                  node['shortTitle'] as String,
                                                  style: TextStyle(
                                                    fontSize: 11.5.sp,
                                                    fontWeight: node ==
                                                            closestNode
                                                        ? FontWeight.w800
                                                        : FontWeight.w600,
                                                    color: node == closestNode
                                                        ? nodeColor
                                                        : CaseLibraryColors
                                                            .textSecondary,
                                                  ),
                                                ),
                                              ),
                                              Text(
                                                '$pct%',
                                                style: TextStyle(
                                                  fontSize: 11.sp,
                                                  fontWeight: FontWeight.w800,
                                                  color: nodeColor,
                                                ),
                                              ),
                                            ],
                                          ),
                                          SizedBox(height: 4.h),
                                          ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(999),
                                            child: LinearProgressIndicator(
                                              value: pct / 100.0,
                                              minHeight: 6.h,
                                              backgroundColor:
                                                  CaseLibraryColors.borderLight,
                                              valueColor:
                                                  AlwaysStoppedAnimation<Color>(
                                                      nodeColor),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                }),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  SizedBox(height: 14.h),

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
                          '確認我的立場並查看民意分佈',
                          style: LightTextStyles.buttonText(context),
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

  int _computeNodeShare(
    List<Map<String, dynamic>> nodes,
    int index,
    bool isSelected,
  ) {
    if (nodes.isEmpty) return 0;
    final seed = widget.book.id.hashCode.abs();
    final weights = List<int>.generate(nodes.length, (i) {
      final base = 18 + ((seed + i * 17) % 23);
      return i == index && isSelected ? base + 8 : base;
    });
    final total = weights.fold<int>(0, (a, b) => a + b);
    if (total == 0) return 0;
    return ((weights[index] * 100) / total).round();
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
