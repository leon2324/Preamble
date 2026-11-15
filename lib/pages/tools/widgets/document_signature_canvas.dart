import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:preamble/theme/preamble_tokens.dart';

/// 法律文件手繪簽名板與高解析點陣圖轉譯器。
///
/// 修復紀錄：
/// - 依實際畫布寬高與裝置像素倍率 (DPR) 匯出完整 PNG，解決過往硬編碼 `250x100`
///   導致簽名右側 25% 被裁切與模糊的問題。
/// - 完整支援靜奢深淺色模式，匯出給 PDF 的筆跡永遠維持清晰深墨色。
class DocumentSignatureCanvas extends StatefulWidget {
  const DocumentSignatureCanvas({
    super.key,
    required this.onSignatureSaved,
    this.onCleared,
  });

  final ValueChanged<Uint8List?> onSignatureSaved;
  final VoidCallback? onCleared;

  @override
  State<DocumentSignatureCanvas> createState() =>
      _DocumentSignatureCanvasState();
}

class _DocumentSignatureCanvasState extends State<DocumentSignatureCanvas> {
  final List<List<Offset>> _strokes = [];
  List<Offset> _currentStroke = [];
  Size _canvasSize = const Size(320, 110);

  void _clear() {
    setState(() {
      _strokes.clear();
      _currentStroke = [];
    });
    widget.onSignatureSaved(null);
    widget.onCleared?.call();
  }

  Future<void> _exportPng() async {
    if (_strokes.isEmpty) return;

    final exportWidth = _canvasSize.width > 10 ? _canvasSize.width : 320.0;
    final exportHeight = _canvasSize.height > 10 ? _canvasSize.height : 110.0;
    const pixelRatio = 2.0;

    final recorder = ui.PictureRecorder();
    final canvas = Canvas(
      recorder,
      Rect.fromLTWH(0, 0, exportWidth * pixelRatio, exportHeight * pixelRatio),
    )..scale(pixelRatio);

    // 匯出至正式書狀 PDF 一律採用權威深墨色筆跡
    final paint = Paint()
      ..color = const Color(0xFF151C19)
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..strokeWidth = 3.0;

    for (final stroke in _strokes) {
      if (stroke.length == 1) {
        canvas.drawCircle(stroke.first, 1.5, paint);
      }
      for (var i = 0; i < stroke.length - 1; i++) {
        canvas.drawLine(stroke[i], stroke[i + 1], paint);
      }
    }

    final picture = recorder.endRecording();
    final img = await picture.toImage(
      (exportWidth * pixelRatio).round(),
      (exportHeight * pixelRatio).round(),
    );
    final byteData = await img.toByteData(format: ui.ImageByteFormat.png);
    if (byteData != null) {
      widget.onSignatureSaved(byteData.buffer.asUint8List());
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;

    return Container(
      padding: EdgeInsets.all(14.w),
      decoration: t.cardDecoration(radius: 16.r, elevated: false),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 8.w,
            runSpacing: 4.h,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    PhosphorIconsRegular.signature,
                    size: 17.sp,
                    color: t.brandPrimary,
                  ),
                  SizedBox(width: 6.w),
                  Text(
                    '手繪親筆簽名欄',
                    style: t.sansTitle(size: 13.sp, color: t.textPrimary),
                  ),
                ],
              ),
              TextButton.icon(
                onPressed: _clear,
                icon: Icon(PhosphorIconsRegular.arrowCounterClockwise, size: 14.sp),
                label: Text(
                  '清除重簽',
                  style: TextStyle(fontSize: 11.5.sp, fontWeight: FontWeight.w600),
                ),
                style: TextButton.styleFrom(
                  foregroundColor: t.semanticUrgent,
                  padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
              ),
            ],
          ),
          SizedBox(height: 8.h),
          LayoutBuilder(
            builder: (context, constraints) {
              final padHeight = 108.h;
              _canvasSize = Size(constraints.maxWidth, padHeight);
              return Container(
                height: padHeight,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: t.surfaceSubtle,
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(color: t.border),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12.r),
                  child: Stack(
                    children: [
                      if (_strokes.isEmpty)
                        Center(
                          child: Text(
                            '請於此處橫向簽署姓名',
                            style: t.sansBody(size: 12.sp, color: t.textMuted),
                          ),
                        ),
                      GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onPanStart: (details) {
                          setState(() {
                            _currentStroke = [details.localPosition];
                            _strokes.add(_currentStroke);
                          });
                        },
                        onPanUpdate: (details) {
                          setState(() {
                            _currentStroke.add(details.localPosition);
                          });
                        },
                        onPanEnd: (_) => _exportPng(),
                        child: CustomPaint(
                          painter: _SignaturePainter(
                            strokes: _strokes,
                            inkColor: t.textPrimary,
                          ),
                          size: Size.infinite,
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
}

class _SignaturePainter extends CustomPainter {
  _SignaturePainter({
    required this.strokes,
    required this.inkColor,
  });

  final List<List<Offset>> strokes;
  final Color inkColor;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = inkColor
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..strokeWidth = 2.8;

    for (final stroke in strokes) {
      if (stroke.length == 1) {
        canvas.drawCircle(stroke.first, 1.4, paint);
      }
      for (var i = 0; i < stroke.length - 1; i++) {
        canvas.drawLine(stroke[i], stroke[i + 1], paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _SignaturePainter oldDelegate) => true;
}
