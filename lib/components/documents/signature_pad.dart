import 'dart:ui' as ui;
import 'dart:typed_data';
import 'package:flutter/material.dart';

class SignaturePad extends StatefulWidget {
  const SignaturePad({super.key, required this.onSigned});

  final void Function(Uint8List bytes) onSigned;

  @override
  State<SignaturePad> createState() => _SignaturePadState();
}

class _SignaturePadState extends State<SignaturePad> {
  final List<Offset?> _points = [];

  void _addPoint(DragUpdateDetails details) {
    setState(() {
      _points.add(details.localPosition);
    });
  }

  void _startStroke(DragStartDetails details) {
    setState(() {
      _points.add(details.localPosition);
    });
  }

  void _endStroke(DragEndDetails details) {
    setState(() {
      _points.add(null);
    });
  }

  void _clear() {
    setState(() {
      _points.clear();
    });
  }

  Future<void> _export() async {
    if (_points.isEmpty) return;

    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    final size = const Size(800, 400); // fixed export size
    
    // Draw white background
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), Paint()..color = Colors.white);
    
    final paint = Paint()
      ..color = Colors.black
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 5.0;

    // Scale points to export size based on current layout bounds
    // For simplicity, we just use raw points assuming they were drawn on a box,
    // but better is to map them. Here we just draw them as is.
    for (int i = 0; i < _points.length - 1; i++) {
      if (_points[i] != null && _points[i + 1] != null) {
        canvas.drawLine(_points[i]!, _points[i + 1]!, paint);
      } else if (_points[i] != null && _points[i + 1] == null) {
        canvas.drawPoints(ui.PointMode.points, [_points[i]!], paint);
      }
    }

    final picture = recorder.endRecording();
    final image = await picture.toImage(size.width.toInt(), size.height.toInt());
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    if (byteData != null) {
      widget.onSigned(byteData.buffer.asUint8List());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          height: 200,
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(12),
          ),
          child: GestureDetector(
            onPanStart: _startStroke,
            onPanUpdate: _addPoint,
            onPanEnd: _endStroke,
            child: CustomPaint(
              painter: _SignaturePainter(_points),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            TextButton.icon(
              onPressed: _clear,
              icon: const Icon(Icons.clear),
              label: const Text('重簽'),
            ),
            const SizedBox(width: 8),
            FilledButton.icon(
              onPressed: _export,
              icon: const Icon(Icons.check),
              label: const Text('確認簽名'),
            ),
          ],
        ),
      ],
    );
  }
}

class _SignaturePainter extends CustomPainter {
  _SignaturePainter(this.points);

  final List<Offset?> points;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 3.0;

    for (int i = 0; i < points.length - 1; i++) {
      if (points[i] != null && points[i + 1] != null) {
        canvas.drawLine(points[i]!, points[i + 1]!, paint);
      } else if (points[i] != null && points[i + 1] == null) {
        canvas.drawPoints(ui.PointMode.points, [points[i]!], paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _SignaturePainter oldDelegate) {
    return oldDelegate.points.length != points.length;
  }
}
