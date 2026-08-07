import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// 法律文件手繪簽名板與點陣圖轉譯器。
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

  void _clear() {
    setState(() {
      _strokes.clear();
      _currentStroke.clear();
    });
    widget.onSignatureSaved(null);
    if (widget.onCleared != null) widget.onCleared!();
  }

  Future<void> _exportPng() async {
    if (_strokes.isEmpty && _currentStroke.isEmpty) return;

    final recorder = ui.PictureRecorder();
    final canvas = Canvas(
      recorder,
      Rect.fromLTWH(0, 0, 250.w, 100.h),
    );

    final paint = Paint()
      ..color = const Color(0xFF17231F)
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 3.5;

    for (final stroke in _strokes) {
      for (int i = 0; i < stroke.length - 1; i++) {
        canvas.drawLine(stroke[i], stroke[i + 1], paint);
      }
    }

    final picture = recorder.endRecording();
    final img = await picture.toImage(250, 100);
    final byteData = await img.toByteData(format: ui.ImageByteFormat.png);
    if (byteData != null) {
      final bytes = byteData.buffer.asUint8List();
      widget.onSignatureSaved(bytes);
    }
  }

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFF2C5E43); // 莫蘭迪綠

    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: const Color(0xFFB8DAC8)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.gesture_rounded,
                    size: 16.sp,
                    color: primaryColor,
                  ),
                  SizedBox(width: 4.w),
                  Text(
                    '手繪親筆簽名板',
                    style: TextStyle(
                      fontSize: 12.5.sp,
                      fontWeight: FontWeight.bold,
                      color: primaryColor,
                    ),
                  ),
                ],
              ),
              TextButton.icon(
                onPressed: _clear,
                icon: Icon(Icons.refresh_rounded, size: 14.sp),
                label: Text(
                  '清除重簽',
                  style: TextStyle(fontSize: 11.5.sp),
                ),
                style: TextButton.styleFrom(
                  foregroundColor: const Color(0xFF9E4A4A),
                  padding: EdgeInsets.zero,
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
              ),
            ],
          ),
          SizedBox(height: 8.h),

          // 簽名手繪區域
          Container(
            height: 100.h,
            width: double.infinity,
            decoration: BoxDecoration(
              color: const Color(0xFFF5F8F6),
              borderRadius: BorderRadius.circular(10.r),
              border: Border.all(color: const Color(0xFFE2E8E4)),
            ),
            child: GestureDetector(
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
                painter: _SignaturePainter(strokes: _strokes),
                size: Size.infinite,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SignaturePainter extends CustomPainter {
  _SignaturePainter({required this.strokes});

  final List<List<Offset>> strokes;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF17231F)
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 3.0;

    for (final stroke in strokes) {
      for (int i = 0; i < stroke.length - 1; i++) {
        canvas.drawLine(stroke[i], stroke[i + 1], paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _SignaturePainter oldDelegate) => true;
}
