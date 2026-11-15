import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// 法律故事型詳情頁共用底部操作列。
///
/// 案件圖書館與生活避坑筆記都屬於「讀完內容後接續行動」的詳情頁，
/// 因此把問法助、筆記、追蹤、收藏、分享抽成同一個元件。
/// 這樣未來要微調 Apple-like 底欄高度、圖示、顏色時，只需要改這裡。
class PreambleStoryActionBar extends StatelessWidget {
  const PreambleStoryActionBar({
    super.key,
    required this.isFollowed,
    required this.isSaved,
    required this.onAskAssistant,
    required this.onNote,
    required this.onFollow,
    required this.onSave,
    required this.onShare,
    this.showSaveButton = true,
    this.backgroundColor = Colors.white,
    this.borderColor = const Color(0xFFEDE4D8),
    this.primaryColor = const Color(0xFF1B3F38),
  });

  final bool isFollowed;
  final bool isSaved;
  final VoidCallback onAskAssistant;
  final VoidCallback onNote;
  final VoidCallback onFollow;
  final VoidCallback onSave;
  final VoidCallback onShare;
  final bool showSaveButton;
  final Color backgroundColor;
  final Color borderColor;
  final Color primaryColor;

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.paddingOf(context).bottom;

    return Container(
      padding: EdgeInsets.fromLTRB(12.w, 4.h, 12.w, bottomPadding + 8.h),
      decoration: BoxDecoration(
        color: backgroundColor,
        border: Border(top: BorderSide(color: borderColor)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _StoryActionButton(
            icon: ClipOval(
              child: Image.asset(
                'assets/images/assistant/law_assistant_home.png',
                width: 24.w,
                height: 24.w,
                fit: BoxFit.cover,
              ),
            ),
            label: '問法助',
            color: primaryColor,
            onTap: onAskAssistant,
          ),
          _StoryActionButton(
            icon: _StorySvgIcon(_svgNotesIcon, color: primaryColor),
            label: '筆記',
            color: primaryColor,
            onTap: onNote,
          ),
          GestureDetector(
            onTap: onFollow,
            child: Container(
              constraints: BoxConstraints(minWidth: 104.w),
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 8.h),
              decoration: BoxDecoration(
                color: primaryColor,
                borderRadius: BorderRadius.circular(999.r),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SvgPicture.string(
                    isFollowed ? _svgCheckIcon : _svgAddIcon,
                    width: 14.sp,
                    height: 14.sp,
                  ),
                  SizedBox(width: 5.w),
                  Text(
                    isFollowed ? '已追蹤' : '追蹤',
                    style: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                      letterSpacing: 0,
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (showSaveButton)
            _StoryActionButton(
              icon: _StorySvgIcon(
                isSaved ? _svgStarFilledIcon : _svgStarOutlineIcon,
                color: primaryColor,
                applyColor: !isSaved,
              ),
              label: '收藏',
              color: primaryColor,
              onTap: onSave,
            ),
          _StoryActionButton(
            icon: _StorySvgIcon(_svgShareIcon, color: primaryColor),
            label: '分享',
            color: primaryColor,
            onTap: onShare,
          ),
        ],
      ),
    );
  }
}

class _StoryActionButton extends StatelessWidget {
  const _StoryActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  final Widget icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: SizedBox(
        width: 52.w,
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 4.h),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(width: 24.w, height: 24.w, child: Center(child: icon)),
              SizedBox(height: 2.h),
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 10.sp,
                  fontWeight: FontWeight.w900,
                  color: color,
                  letterSpacing: 0,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StorySvgIcon extends StatelessWidget {
  const _StorySvgIcon(
    this.svg, {
    required this.color,
    this.applyColor = true,
  });

  final String svg;
  final Color color;
  final bool applyColor;

  @override
  Widget build(BuildContext context) {
    return SvgPicture.string(
      svg,
      width: 22.w,
      height: 22.w,
      colorFilter: applyColor ? ColorFilter.mode(color, BlendMode.srcIn) : null,
    );
  }
}

const String _svgNotesIcon = '''
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" width="24" height="24" fill="none" stroke="#1B3F38" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
  <path d="M14 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V8z"></path>
  <polyline points="14 2 14 8 20 8"></polyline>
  <line x1="16" y1="13" x2="8" y2="13"></line>
  <line x1="16" y1="17" x2="8" y2="17"></line>
  <polyline points="10 9 9 9 8 9"></polyline>
</svg>
''';

const String _svgShareIcon = '''
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" width="24" height="24" fill="none" stroke="#1B3F38" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
  <path d="M4 12v8a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2v-8"></path>
  <polyline points="16 6 12 2 8 6"></polyline>
  <line x1="12" y1="2" x2="12" y2="15"></line>
</svg>
''';

const String _svgStarOutlineIcon = '''
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" width="24" height="24" fill="none" stroke="#1B3F38" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
  <polygon points="12 2 15.09 8.26 22 9.27 17 14.14 18.18 21.02 12 17.77 5.82 21.02 7 14.14 2 9.27 8.91 8.26 12 2"></polygon>
</svg>
''';

const String _svgStarFilledIcon = '''
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" width="24" height="24" fill="#1B3F38">
  <polygon points="12 2 15.09 8.26 22 9.27 17 14.14 18.18 21.02 12 17.77 5.82 21.02 7 14.14 2 9.27 8.91 8.26 12 2"></polygon>
</svg>
''';

const String _svgAddIcon = '''
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" width="24" height="24" fill="none" stroke="#FFFFFF" stroke-width="3" stroke-linecap="round" stroke-linejoin="round">
  <line x1="12" y1="5" x2="12" y2="19"></line>
  <line x1="5" y1="12" x2="19" y2="12"></line>
</svg>
''';

const String _svgCheckIcon = '''
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" width="24" height="24" fill="none" stroke="#FFFFFF" stroke-width="3" stroke-linecap="round" stroke-linejoin="round">
  <polyline points="20 6 9 17 4 12"></polyline>
</svg>
''';
