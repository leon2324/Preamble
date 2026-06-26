part of '../global_search_page.dart';

// 本檔只放搜尋頁使用的 bottom sheet 展示元件與語音搜尋模擬 UI。
// 父層仍負責開啟 sheet、接收辨識結果並執行 submit / route 行為。

class _SearchActionSheet extends StatelessWidget {
  const _SearchActionSheet({
    required this.title,
    required this.message,
    required this.actions,
  });

  final String title;
  final String message;
  final List<_SheetAction> actions;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 16.h),
        child: _ProtoCard(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: _SearchText.section()),
              SizedBox(height: 8.h),
              Text(message, style: _SearchText.body()),
              SizedBox(height: 14.h),
              for (final action in actions) ...[
                _SheetActionTile(action: action),
                SizedBox(height: 8.h),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _SheetActionTile extends StatelessWidget {
  const _SheetActionTile({required this.action});

  final _SheetAction action;

  @override
  Widget build(BuildContext context) {
    return _ProtoCard(
      onTap: action.onTap,
      background: _SearchColors.softMint,
      child: Row(
        children: [
          _IconBox(icon: action.icon, color: _SearchColors.primary),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(action.title, style: _SearchText.tileTitle()),
                SizedBox(height: 4.h),
                Text(action.subtitle, style: _SearchText.caption()),
              ],
            ),
          ),
          Icon(Icons.chevron_right_rounded,
              color: _SearchColors.mutedText, size: 20.sp),
        ],
      ),
    );
  }
}

class _SheetAction {
  const _SheetAction({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
}

class _SearchVoiceBottomSheet extends StatefulWidget {
  const _SearchVoiceBottomSheet();

  @override
  State<_SearchVoiceBottomSheet> createState() =>
      _SearchVoiceBottomSheetState();
}

class _SearchVoiceBottomSheetState extends State<_SearchVoiceBottomSheet>
    with SingleTickerProviderStateMixin {
  late final AnimationController _waveController;
  String _statusText = '正在聆聽中...';
  String _recognizedText = '';
  bool _isFinished = false;

  @override
  void initState() {
    super.initState();
    _waveController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();

    // 模擬語音辨識過程：1.5秒後開始顯示辨識文字，3秒後自動送出
    Future.delayed(const Duration(milliseconds: 1200), () {
      if (!mounted) return;
      setState(() {
        _statusText = '語音辨識中...';
      });
      _simulateTyping('我買到瑕疵商品想要退貨，可以要求退款或賠償嗎？', 0);
    });
  }

  void _simulateTyping(String fullText, int index) {
    if (!mounted) return;
    if (index <= fullText.length) {
      setState(() {
        _recognizedText = fullText.substring(0, index);
      });
      Future.delayed(const Duration(milliseconds: 50), () {
        _simulateTyping(fullText, index + 1);
      });
    } else {
      setState(() {
        _isFinished = true;
        _statusText = '辨識完成！即時搜尋';
      });
      Future.delayed(const Duration(milliseconds: 800), () {
        if (!mounted) return;
        Navigator.of(context).pop(fullText);
      });
    }
  }

  @override
  void dispose() {
    _waveController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.95),
        borderRadius: BorderRadius.vertical(top: Radius.circular(28.r)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x1A000000),
            blurRadius: 20,
            offset: Offset(0, -5),
          ),
        ],
      ),
      padding: EdgeInsets.fromLTRB(24.w, 20.h, 24.w, 40.h),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 46.w,
            height: 5.h,
            decoration: BoxDecoration(
              color: _SearchColors.border,
              borderRadius: BorderRadius.circular(999.r),
            ),
          ),
          SizedBox(height: 24.h),
          Text(
            _statusText,
            style: _SearchText.section().copyWith(color: _SearchColors.primary),
          ),
          SizedBox(height: 18.h),
          Container(
            height: 120.h,
            width: double.infinity,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: _SearchColors.background,
              borderRadius: BorderRadius.circular(18.r),
              border: Border.all(
                  color: _SearchColors.border.withValues(alpha: 0.5)),
            ),
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
            child: _recognizedText.isEmpty
                ? AnimatedBuilder(
                    animation: _waveController,
                    builder: (context, child) {
                      return Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(5, (index) {
                          final value =
                              (_waveController.value + (index * 0.2)) % 1.0;
                          final height =
                              15.h + (45.h * (0.5 - (0.5 - value).abs()));
                          return Container(
                            width: 6.w,
                            height: height,
                            margin: EdgeInsets.symmetric(horizontal: 4.w),
                            decoration: BoxDecoration(
                              color: _SearchColors.primary
                                  .withValues(alpha: 0.2 + (0.8 * value)),
                              borderRadius: BorderRadius.circular(999.r),
                            ),
                          );
                        }),
                      );
                    },
                  )
                : Text(
                    _recognizedText,
                    textAlign: TextAlign.center,
                    style: _SearchText.heroSmall().copyWith(
                      color: _SearchColors.text,
                      height: 1.4,
                    ),
                  ),
          ),
          SizedBox(height: 28.h),
          GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
              decoration: BoxDecoration(
                color: _SearchColors.softPaper,
                borderRadius: BorderRadius.circular(999.r),
              ),
              child: Text(
                '取消',
                style: _SearchText.captionStrong()
                    .copyWith(color: _SearchColors.mutedText),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
