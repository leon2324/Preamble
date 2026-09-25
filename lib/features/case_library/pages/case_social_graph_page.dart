import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:preamble/features/case_library/data/case_interactive_profiles.dart';
import 'package:preamble/features/case_library/models/case_library_models.dart';
import 'package:preamble/features/case_library/theme/case_library_theme.dart';

class CaseSocialGraphPage extends StatefulWidget {
  const CaseSocialGraphPage({super.key, required this.book});

  final CaseBook book;

  @override
  State<CaseSocialGraphPage> createState() => _CaseSocialGraphPageState();
}

class _CaseSocialGraphPageState extends State<CaseSocialGraphPage> {
  String? _selectedNodeId;

  // 針對特定案件渲染量身打造的社會連鎖效應心智圖資料。
  // 若是一般案件，我們也提供一組具有法理與社會通用的變革效應樹狀圖。
  late final List<Map<String, dynamic>> _nodes;

  @override
  void initState() {
    super.initState();
    _nodes = _getSocialEffects();
    // 預設選擇核心案件節點
    _selectedNodeId = 'root';
  }

  List<Map<String, dynamic>> _getSocialEffects() {
    return CaseInteractiveProfiles.getSocialEffects(widget.book);
  }

  @override
  Widget build(BuildContext context) {
    final selectedNode = _nodes.firstWhere((n) => n['id'] == _selectedNodeId);
    final coreNode = _nodes.firstWhere((n) => n['type'] == 'core');
    final effectNodes = _nodes.where((n) => n['type'] == 'effect').toList();

    return Scaffold(
      backgroundColor: CaseLibraryColors.bgCream,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: CaseLibraryColors.bgCream,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            color: CaseLibraryColors.primaryGreen,
            size: 20.sp,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          '社會效應圖譜',
          style: TextStyle(
            fontFamily: 'Songti TC',
            fontFamilyFallback: const ['Songti SC', 'STSong', 'PingFang TC'],
            fontSize: 16.sp,
            fontWeight: FontWeight.w800,
            color: CaseLibraryColors.primaryGreen,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '【點選各個效應節點，探索連鎖變革詳情】',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.bold,
                  color: CaseLibraryColors.primaryGreen,
                ),
              ),
              SizedBox(height: 16.h),
              // 1. 互動圖表區 (心智圖樹狀連線)
              Expanded(
                flex: 3,
                child: Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(12.w),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16.r),
                    border: Border.all(color: CaseLibraryColors.borderLight),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.03),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // 繪製背景連結虛線
                      CustomPaint(
                        size: Size.infinite,
                        painter: _GraphLinkPainter(
                          nodeCount: effectNodes.length,
                        ),
                      ),
                      // 渲染核心節點 (置中)
                      GestureDetector(
                        onTap: () => setState(
                            () => _selectedNodeId = coreNode['id'] as String),
                        child: Container(
                          width: 140.w,
                          padding: EdgeInsets.symmetric(
                              horizontal: 12.w, vertical: 12.h),
                          decoration: BoxDecoration(
                            color: _selectedNodeId == coreNode['id']
                                ? CaseLibraryColors.primaryGreen
                                : const Color(0xFF1C3A27),
                            borderRadius: BorderRadius.circular(16.r),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.1),
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.gavel_rounded,
                                color: Colors.white,
                                size: 18.sp,
                              ),
                              SizedBox(height: 6.h),
                              Text(
                                coreNode['title'] as String,
                                textAlign: TextAlign.center,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 11.5.sp,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                  fontFamily: 'Songti TC',
                                  fontFamilyFallback: const [
                                    'Songti SC',
                                    'STSong',
                                    'PingFang TC'
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      // 圍繞核心節點渲染外圍效應節點 (使用 Positioned 模擬環狀排版)
                      ..._buildEffectNodes(effectNodes),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 16.h),
              // 2. 節點詳情說明區
              Expanded(
                flex: 2,
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 250),
                  child: Container(
                    key: ValueKey(_selectedNodeId),
                    width: double.infinity,
                    padding: EdgeInsets.all(16.w),
                    decoration: BoxDecoration(
                      color: selectedNode['id'] == 'root'
                          ? const Color(0xFFFAF7F0)
                          : const Color(0xFFEAF6EF),
                      borderRadius: BorderRadius.circular(16.r),
                      border: Border.all(
                        color: selectedNode['id'] == 'root'
                            ? const Color(0xFFE6E2D8)
                            : const Color(0xFFD0E0D6),
                      ),
                    ),
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                selectedNode['id'] == 'root'
                                    ? Icons.info_outline_rounded
                                    : Icons.bolt_rounded,
                                color: selectedNode['id'] == 'root'
                                    ? const Color(0xFFC8A261)
                                    : CaseLibraryColors.primaryGreen,
                                size: 18.sp,
                              ),
                              SizedBox(width: 8.w),
                              Expanded(
                                child: Text(
                                  selectedNode['title'] as String,
                                  style: TextStyle(
                                    fontSize: 13.5.sp,
                                    fontWeight: FontWeight.w900,
                                    color: const Color(0xFF1C3A27),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 8.h),
                          Text(
                            selectedNode['description'] as String,
                            style: TextStyle(
                              fontSize: 12.sp,
                              height: 1.58,
                              color: const Color(0xFF2E332F),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 根據效應節點數量，利用三角函數環繞核心節點排版
  List<Widget> _buildEffectNodes(List<Map<String, dynamic>> effects) {
    final widgets = <Widget>[];
    final count = effects.length;
    // 預設外圍環繞半徑
    final double radiusX = 105.w;
    final double radiusY = 135.h;

    for (var i = 0; i < count; i++) {
      final effect = effects[i];
      // 平分 360 度角
      final double angle = (2 * 3.14159 / count) * i - (3.14159 / 2);

      widgets.add(
        Positioned(
          left: (radiusX * (1 + 0.9 * (angle).clamp(-1.0, 1.0) /* 略微偏移防重疊 */))
              .clamp(0, double.infinity),
          // 由於手動排版較為安全，我們使用更精準的 Positioned 計算
          // 中心點大約在 (x=160.w, y=180.h)，根據 radius 環繞
          child: _buildPositionedEffectTile(effect, angle),
        ),
      );
    }

    // 為了排版更加完美、安全，我們直接寫死 Positioned，避免三角函數在小螢幕溢出
    return _buildStaticLayoutNodes(effects);
  }

  List<Widget> _buildStaticLayoutNodes(List<Map<String, dynamic>> effects) {
    final count = effects.length;
    if (count == 4) {
      return [
        // 左上
        Positioned(
          left: 10.w,
          top: 30.h,
          child: _buildEffectTile(effects[0]),
        ),
        // 右上
        Positioned(
          right: 10.w,
          top: 30.h,
          child: _buildEffectTile(effects[1]),
        ),
        // 左下
        Positioned(
          left: 10.w,
          bottom: 30.h,
          child: _buildEffectTile(effects[2]),
        ),
        // 右下
        Positioned(
          right: 10.w,
          bottom: 30.h,
          child: _buildEffectTile(effects[3]),
        ),
      ];
    }

    // 預設 3 個或其它數量的佈局
    return [
      // 頂部中
      Positioned(
        top: 20.h,
        child: _buildEffectTile(effects[0]),
      ),
      // 左下
      Positioned(
        left: 10.w,
        bottom: 40.h,
        child: _buildEffectTile(effects[1 % count]),
      ),
      // 右下
      Positioned(
        right: 10.w,
        bottom: 40.h,
        child: _buildEffectTile(effects[2 % count]),
      ),
    ];
  }

  Widget _buildPositionedEffectTile(Map<String, dynamic> effect, double angle) {
    // 此 helper 僅備用
    return _buildEffectTile(effect);
  }

  Widget _buildEffectTile(Map<String, dynamic> effect) {
    final isSelected = _selectedNodeId == effect['id'];
    return GestureDetector(
      onTap: () => setState(() => _selectedNodeId = effect['id'] as String),
      child: Container(
        width: 110.w,
        padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 10.h),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFEAF6EF) : Colors.white,
          border: Border.all(
            color: isSelected
                ? CaseLibraryColors.primaryGreen
                : const Color(0xFFC8A261).withValues(alpha: 0.5),
            width: 1.2,
          ),
          borderRadius: BorderRadius.circular(12.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            CircleAvatar(
              radius: 12.r,
              backgroundColor: isSelected
                  ? CaseLibraryColors.primaryGreen
                  : const Color(0xFFFAF7F0),
              child: Icon(
                Icons.bolt_rounded,
                size: 13.sp,
                color: isSelected ? Colors.white : const Color(0xFFC8A261),
              ),
            ),
            SizedBox(height: 6.h),
            Text(
              effect['title'] as String,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 10.5.sp,
                fontWeight: FontWeight.bold,
                color: isSelected
                    ? CaseLibraryColors.primaryGreen
                    : CaseLibraryColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// 繪製心智圖連結的裝飾虛線，增加 WOW 的視覺引導
class _GraphLinkPainter extends CustomPainter {
  _GraphLinkPainter({required this.nodeCount});

  final int nodeCount;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFC8A261).withValues(alpha: 0.25)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    final double centerX = size.width / 2;
    final double centerY = size.height / 2;

    // 根據 3 點或 4 點靜態座標畫連結線
    if (nodeCount == 4) {
      // 左上
      canvas.drawLine(Offset(centerX, centerY), Offset(55.w, 80.h), paint);
      // 右上
      canvas.drawLine(
          Offset(centerX, centerY), Offset(size.width - 55.w, 80.h), paint);
      // 左下
      canvas.drawLine(
          Offset(centerX, centerY), Offset(55.w, size.height - 80.h), paint);
      // 右下
      canvas.drawLine(Offset(centerX, centerY),
          Offset(size.width - 55.w, size.height - 80.h), paint);
    } else {
      // 頂部中
      canvas.drawLine(Offset(centerX, centerY), Offset(centerX, 60.h), paint);
      // 左下
      canvas.drawLine(
          Offset(centerX, centerY), Offset(65.w, size.height - 80.h), paint);
      // 右下
      canvas.drawLine(Offset(centerX, centerY),
          Offset(size.width - 65.w, size.height - 80.h), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
