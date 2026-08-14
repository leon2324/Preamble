import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// 全域緊急防窺與偽裝模式包裹層 (Privacy Shield Wrapper)。
///
/// 支援「雙指雙擊螢幕 (Two-Finger Double Tap)」或點擊眼睛圖示，
/// 瞬間將敏感的法律問診與書狀內容平滑偽裝為「極簡法規備忘錄」，保護使用者當前隱私。
class PrivacyShieldWrapper extends StatefulWidget {
  const PrivacyShieldWrapper({
    super.key,
    required this.child,
  });

  final Widget child;

  @override
  State<PrivacyShieldWrapper> createState() => _PrivacyShieldWrapperState();
}

class _PrivacyShieldWrapperState extends State<PrivacyShieldWrapper> {
  bool _isDisguised = false;

  void toggleDisguise() {
    HapticFeedback.heavyImpact();
    setState(() => _isDisguised = !_isDisguised);
  }

  @override
  Widget build(BuildContext context) {
    return RawGestureDetector(
      gestures: {
        _TwoFingerDoubleTapGestureRecognizer:
            GestureRecognizerFactoryWithHandlers<
                _TwoFingerDoubleTapGestureRecognizer>(
          () => _TwoFingerDoubleTapGestureRecognizer(),
          (instance) {
            instance.onTwoFingerDoubleTap = toggleDisguise;
          },
        ),
      },
      child: Stack(
        children: [
          widget.child,

          // 偽裝層 (極簡工作備忘錄)
          if (_isDisguised)
            Positioned.fill(
              child: Container(
                color: const Color(0xFFF9F9F8),
                padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 60.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '備忘錄 (Notes)',
                          style: TextStyle(
                            fontSize: 22.sp,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        IconButton(
                          onPressed: toggleDisguise,
                          tooltip: '退出防窺模式',
                          icon: Icon(Icons.remove_red_eye_outlined,
                              color: Colors.grey.shade600),
                        ),
                      ],
                    ),
                    Divider(color: Colors.grey.shade300),
                    SizedBox(height: 14.h),
                    Text(
                      '今日待辦與會議紀錄',
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.bold,
                        color: Colors.black54,
                      ),
                    ),
                    SizedBox(height: 10.h),
                    _buildDummyNoteItem('1. 整理下週專案進度與時程表'),
                    _buildDummyNoteItem('2. 查閱相關產業法規條文第 15 條細則'),
                    _buildDummyNoteItem('3. 採購辦公室耗材與文具用品'),
                    _buildDummyNoteItem('4. 回覆客戶電子郵件'),
                    const Spacer(),
                    Center(
                      child: Text(
                        '（雙指雙擊螢幕或點擊右上角退出防窺模式）',
                        style: TextStyle(
                          fontSize: 11.sp,
                          color: Colors.grey.shade400,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildDummyNoteItem(String text) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8.h),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 13.sp,
          color: Colors.black87,
          height: 1.4,
        ),
      ),
    );
  }
}

/// 自定義雙指雙擊手勢識別器
class _TwoFingerDoubleTapGestureRecognizer extends RawGestureRecognizer {
  VoidCallback? onTwoFingerDoubleTap;
  int _pointersCount = 0;
  DateTime? _lastTapTime;

  @override
  void addAllowedPointer(PointerDownEvent event) {
    _pointersCount++;
    if (_pointersCount == 2) {
      final now = DateTime.now();
      if (_lastTapTime != null &&
          now.difference(_lastTapTime!).inMilliseconds < 450) {
        onTwoFingerDoubleTap?.call();
        _lastTapTime = null;
      } else {
        _lastTapTime = now;
      }
    }
    super.addAllowedPointer(event);
  }

  @override
  void handleEvent(PointerEvent event) {
    if (event is PointerUpEvent || event is PointerCancelEvent) {
      _pointersCount = 0;
    }
  }

  @override
  String get debugDescription => 'twoFingerDoubleTap';

  @override
  void didStopTrackingLastPointer(int pointer) {
    _pointersCount = 0;
  }
}
