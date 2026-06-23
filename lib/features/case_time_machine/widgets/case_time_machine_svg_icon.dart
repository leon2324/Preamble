import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

// 台灣繁體中文教學註解：
// 案件時光機刻意避開 Google Material 原生 IconData，改用網路常見的開源 SVG 圖示語彙。
// 這個 helper 讓每個 SVG 都能套用同一套顏色與尺寸，避免各頁面重複貼 SvgPicture.string。
class CtmSvgIcon extends StatelessWidget {
  const CtmSvgIcon(
    this.svg, {
    super.key,
    required this.size,
    required this.color,
  });

  final String svg;
  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return SvgPicture.string(
      _paintSvg(svg, color),
      width: size,
      height: size,
    );
  }

  static String _paintSvg(String source, Color color) {
    final hex =
        '#${color.toARGB32().toRadixString(16).padLeft(8, '0').substring(2)}';
    return source.replaceAll('currentColor', hex);
  }
}

abstract final class CtmSvgIcons {
  static const arrowRight = '''
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.4" stroke-linecap="round" stroke-linejoin="round">
  <path d="M5 12h14"></path>
  <path d="m12 5 7 7-7 7"></path>
</svg>
''';

  static const chevronRight = '''
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.6" stroke-linecap="round" stroke-linejoin="round">
  <path d="m9 18 6-6-6-6"></path>
</svg>
''';

  static const chevronLeft = '''
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.6" stroke-linecap="round" stroke-linejoin="round">
  <path d="m15 18-6-6 6-6"></path>
</svg>
''';

  static const search = '''
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.4" stroke-linecap="round" stroke-linejoin="round">
  <circle cx="11" cy="11" r="8"></circle>
  <path d="m21 21-4.3-4.3"></path>
</svg>
''';

  static const clock = '''
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.4" stroke-linecap="round" stroke-linejoin="round">
  <circle cx="12" cy="12" r="10"></circle>
  <path d="M12 6v6l4 2"></path>
</svg>
''';

  static const scale = '''
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.2" stroke-linecap="round" stroke-linejoin="round">
  <path d="m16 16 3-8 3 8c-.87.65-1.92 1-3 1s-2.13-.35-3-1Z"></path>
  <path d="m2 16 3-8 3 8c-.87.65-1.92 1-3 1s-2.13-.35-3-1Z"></path>
  <path d="M7 21h10"></path>
  <path d="M12 3v18"></path>
  <path d="M3 8h18"></path>
</svg>
''';

  static const sparkles = '''
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.2" stroke-linecap="round" stroke-linejoin="round">
  <path d="M9.9 4.2 8.7 7.1 5.8 8.3l2.9 1.2 1.2 2.9 1.2-2.9 2.9-1.2-2.9-1.2-1.2-2.9Z"></path>
  <path d="M17.6 11.4 16.8 13l-1.6.8 1.6.8.8 1.6.8-1.6 1.6-.8-1.6-.8-.8-1.6Z"></path>
  <path d="M6.5 15.5 5.8 17l-1.5.7 1.5.7.7 1.5.7-1.5 1.5-.7-1.5-.7-.7-1.5Z"></path>
</svg>
''';

  static const timeline = '''
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.2" stroke-linecap="round" stroke-linejoin="round">
  <path d="M3 17 9 11l4 4 7-8"></path>
  <path d="M14 7h6v6"></path>
</svg>
''';

  static const bookOpen = '''
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.2" stroke-linecap="round" stroke-linejoin="round">
  <path d="M12 7v14"></path>
  <path d="M3 5a7 7 0 0 1 9 2 7 7 0 0 1 9-2v14a7 7 0 0 0-9 2 7 7 0 0 0-9-2Z"></path>
</svg>
''';

  static const grid = '''
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.2" stroke-linecap="round" stroke-linejoin="round">
  <rect x="3" y="3" width="7" height="7" rx="1.5"></rect>
  <rect x="14" y="3" width="7" height="7" rx="1.5"></rect>
  <rect x="3" y="14" width="7" height="7" rx="1.5"></rect>
  <rect x="14" y="14" width="7" height="7" rx="1.5"></rect>
</svg>
''';

  static const star = '''
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="currentColor">
  <path d="m12 2.7 2.9 5.9 6.5.9-4.7 4.6 1.1 6.5L12 17.5l-5.8 3.1 1.1-6.5-4.7-4.6 6.5-.9Z"></path>
</svg>
''';

  static const message = '''
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.2" stroke-linecap="round" stroke-linejoin="round">
  <path d="M21 15a4 4 0 0 1-4 4H8l-5 3V7a4 4 0 0 1 4-4h10a4 4 0 0 1 4 4Z"></path>
  <path d="M8 9h8"></path>
  <path d="M8 13h5"></path>
</svg>
''';

  static const filePen = '''
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.2" stroke-linecap="round" stroke-linejoin="round">
  <path d="M14 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V8Z"></path>
  <path d="M14 2v6h6"></path>
  <path d="m11 18 5-5 2 2-5 5h-2Z"></path>
</svg>
''';

  static const gavel = '''
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.2" stroke-linecap="round" stroke-linejoin="round">
  <path d="m14 13-7 7"></path>
  <path d="m8 8 6-6 6 6-6 6Z"></path>
  <path d="m6 10 8 8"></path>
  <path d="M3 21h7"></path>
</svg>
''';

  static const bookmark = '''
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.2" stroke-linecap="round" stroke-linejoin="round">
  <path d="M19 21 12 17 5 21V5a2 2 0 0 1 2-2h10a2 2 0 0 1 2 2Z"></path>
</svg>
''';

  static const award = '''
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.2" stroke-linecap="round" stroke-linejoin="round">
  <circle cx="12" cy="8" r="5"></circle>
  <path d="M8.5 12.5 7 22l5-3 5 3-1.5-9.5"></path>
</svg>
''';

  static const imageOff = '''
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.2" stroke-linecap="round" stroke-linejoin="round">
  <path d="M3 3l18 18"></path>
  <path d="M10.5 5H19a2 2 0 0 1 2 2v8.5"></path>
  <path d="M21 19H5a2 2 0 0 1-2-2V5"></path>
  <path d="m3 15 4-4 3 3"></path>
</svg>
''';

  static const question = '''
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.2" stroke-linecap="round" stroke-linejoin="round">
  <circle cx="12" cy="12" r="10"></circle>
  <path d="M9.5 9a3 3 0 1 1 5 2.2c-1.2.8-2 1.4-2 2.8"></path>
  <path d="M12 17h.01"></path>
</svg>
''';

  static const folderOpen = '''
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.2" stroke-linecap="round" stroke-linejoin="round">
  <path d="M3 7a2 2 0 0 1 2-2h5l2 2h7a2 2 0 0 1 2 2v2"></path>
  <path d="M3 11h18l-2 8a2 2 0 0 1-2 1H5a2 2 0 0 1-2-1Z"></path>
</svg>
''';

  static const brain = '''
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.1" stroke-linecap="round" stroke-linejoin="round">
  <path d="M8 5a3 3 0 0 0-3 3v1a4 4 0 0 0 0 8v1a3 3 0 0 0 5 2.2V5.8A3 3 0 0 0 8 5Z"></path>
  <path d="M16 5a3 3 0 0 1 3 3v1a4 4 0 0 1 0 8v1a3 3 0 0 1-5 2.2V5.8A3 3 0 0 1 16 5Z"></path>
  <path d="M10 12h4"></path>
</svg>
''';

  static const thumbsUp = '''
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.2" stroke-linecap="round" stroke-linejoin="round">
  <path d="M7 10v11"></path>
  <path d="M15 5.5 14 10h5a2 2 0 0 1 2 2.3l-1 6a3 3 0 0 1-3 2.7H7a2 2 0 0 1-2-2v-7a2 2 0 0 1 2-2h2l3.5-6.5A2 2 0 0 1 15 5.5Z"></path>
</svg>
''';

  static const thumbsDown = '''
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.2" stroke-linecap="round" stroke-linejoin="round">
  <path d="M7 14V3"></path>
  <path d="M15 18.5 14 14h5a2 2 0 0 0 2-2.3l-1-6A3 3 0 0 0 17 3H7a2 2 0 0 0-2 2v7a2 2 0 0 0 2 2h2l3.5 6.5a2 2 0 0 0 2.5-2Z"></path>
</svg>
''';

  static const link = '''
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.2" stroke-linecap="round" stroke-linejoin="round">
  <path d="M10 13a5 5 0 0 0 7.1 0l2-2a5 5 0 0 0-7.1-7.1l-1.1 1.1"></path>
  <path d="M14 11a5 5 0 0 0-7.1 0l-2 2A5 5 0 0 0 12 20.1l1.1-1.1"></path>
</svg>
''';

  static const externalLink = '''
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.2" stroke-linecap="round" stroke-linejoin="round">
  <path d="M15 3h6v6"></path>
  <path d="M10 14 21 3"></path>
  <path d="M21 14v5a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2V5a2 2 0 0 1 2-2h5"></path>
</svg>
''';

  static const copy = '''
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.2" stroke-linecap="round" stroke-linejoin="round">
  <rect x="9" y="9" width="13" height="13" rx="2"></rect>
  <path d="M5 15H4a2 2 0 0 1-2-2V4a2 2 0 0 1 2-2h9a2 2 0 0 1 2 2v1"></path>
</svg>
''';

  static const podcast = '''
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.2" stroke-linecap="round" stroke-linejoin="round">
  <circle cx="12" cy="11" r="2"></circle>
  <path d="M8.5 14.5a5 5 0 1 1 7 0"></path>
  <path d="M6 17a8 8 0 1 1 12 0"></path>
  <path d="M10 19h4l-1 3h-2Z"></path>
</svg>
''';

  static const playCircle = '''
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.2" stroke-linecap="round" stroke-linejoin="round">
  <circle cx="12" cy="12" r="10"></circle>
  <path d="m10 8 6 4-6 4Z"></path>
</svg>
''';

  static const newspaper = '''
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.2" stroke-linecap="round" stroke-linejoin="round">
  <path d="M4 19a2 2 0 0 0 2 2h14V5a2 2 0 0 0-2-2H6a2 2 0 0 0-2 2Z"></path>
  <path d="M8 7h8"></path>
  <path d="M8 11h8"></path>
  <path d="M8 15h5"></path>
</svg>
''';

  static const school = '''
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.2" stroke-linecap="round" stroke-linejoin="round">
  <path d="m22 10-10-5-10 5 10 5Z"></path>
  <path d="M6 12v5c3 2 9 2 12 0v-5"></path>
</svg>
''';

  static const xCircle = '''
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.2" stroke-linecap="round" stroke-linejoin="round">
  <circle cx="12" cy="12" r="10"></circle>
  <path d="m15 9-6 6"></path>
  <path d="m9 9 6 6"></path>
</svg>
''';

  static const searchOff = '''
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.2" stroke-linecap="round" stroke-linejoin="round">
  <path d="m3 3 18 18"></path>
  <circle cx="11" cy="11" r="8"></circle>
  <path d="m21 21-4.3-4.3"></path>
</svg>
''';

  static const article = '''
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.2" stroke-linecap="round" stroke-linejoin="round">
  <path d="M15 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V7Z"></path>
  <path d="M14 2v6h6"></path>
  <path d="M8 13h8"></path>
  <path d="M8 17h5"></path>
</svg>
''';

  static const edit = '''
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.2" stroke-linecap="round" stroke-linejoin="round">
  <path d="M12 20h9"></path>
  <path d="M16.5 3.5a2.1 2.1 0 0 1 3 3L7 19l-4 1 1-4Z"></path>
</svg>
''';

  static const chevronDown = '''
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.6" stroke-linecap="round" stroke-linejoin="round">
  <path d="m6 9 6 6 6-6"></path>
</svg>
''';

  static const chevronUp = '''
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.6" stroke-linecap="round" stroke-linejoin="round">
  <path d="m18 15-6-6-6 6"></path>
</svg>
''';

  static const heart = '''
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.2" stroke-linecap="round" stroke-linejoin="round">
  <path d="M20.8 4.6a5.5 5.5 0 0 0-7.8 0L12 5.6l-1-1a5.5 5.5 0 0 0-7.8 7.8l1 1L12 21l7.8-7.6 1-1a5.5 5.5 0 0 0 0-7.8Z"></path>
</svg>
''';

  static const heartFilled = '''
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="currentColor">
  <path d="M12 21.3 4.2 13.7l-1-1A5.7 5.7 0 1 1 11 4.4l1 1 1-1a5.7 5.7 0 1 1 7.8 8.3l-1 1Z"></path>
</svg>
''';

  static const waveform3 = '''
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.6" stroke-linecap="round" stroke-linejoin="round">
  <path d="M7 9v6"></path>
  <path d="M12 4v16"></path>
  <path d="M17 10v4"></path>
</svg>
''';

  static const sprout = '''
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.2" stroke-linecap="round" stroke-linejoin="round">
  <path d="M12 12C12 7.02944 16.0294 3 21 3C21 7.97056 16.9706 12 12 12Z"></path>
  <path d="M12 12C12 7.02944 7.97056 3 3 3C3 7.97056 7.02944 12 12 12Z"></path>
  <path d="M12 12V21"></path>
</svg>
''';

  static const home = '''
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.2" stroke-linecap="round" stroke-linejoin="round">
  <path d="m3 9 9-7 9 7v11a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2z"></path>
  <polyline points="9 22 9 12 15 12 15 22"></polyline>
</svg>
''';

  static const car = '''
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.2" stroke-linecap="round" stroke-linejoin="round">
  <rect x="1" y="12" width="22" height="8" rx="2"></rect>
  <path d="M3 12V7a2 2 0 0 1 2-2h14a2 2 0 0 1 2 2v5"></path>
  <circle cx="6" cy="20" r="2"></circle>
  <circle cx="18" cy="20" r="2"></circle>
</svg>
''';

  static const briefcase = '''
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.2" stroke-linecap="round" stroke-linejoin="round">
  <rect x="2" y="7" width="20" height="14" rx="2" ry="2"></rect>
  <path d="M16 21V5a2 2 0 0 0-2-2h-4a2 2 0 0 0-2 2v16"></path>
</svg>
''';

  static const smartphone = '''
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.2" stroke-linecap="round" stroke-linejoin="round">
  <rect x="5" y="2" width="14" height="20" rx="2" ry="2"></rect>
  <line x1="12" y1="18" x2="12.01" y2="18"></line>
</svg>
''';

  static const shoppingBag = '''
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.2" stroke-linecap="round" stroke-linejoin="round">
  <path d="M6 2L3 6v14a2 2 0 0 0 2 2h14a2 2 0 0 0 2-2V6l-3-4z"></path>
  <line x1="3" y1="6" x2="21" y2="6"></line>
  <path d="M16 10a4 4 0 0 1-8 0"></path>
</svg>
''';

  static const trophy = '''
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.2" stroke-linecap="round" stroke-linejoin="round">
  <path d="M6 9H4.5a2.5 2.5 0 0 1 0-5H6"></path>
  <path d="M18 9h1.5a2.5 2.5 0 0 0 0-5H18"></path>
  <path d="M4 22h16"></path>
  <path d="M10 14.66V17c0 .55-.45 1-1 1H4v2h16v-2h-5c-.55 0-1-.45-1-1v-2.34"></path>
  <path d="M12 2a6 6 0 0 1 6 6v3.5c0 3.3-2.7 6-6 6s-6-2.7-6-6V8a6 6 0 0 1 6-6Z"></path>
</svg>
''';

  static const save = '''
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.2" stroke-linecap="round" stroke-linejoin="round">
  <path d="M19 21H5a2 2 0 0 1-2-2V5a2 2 0 0 1 2-2h11l5 5v11a2 2 0 0 1-2 2z"></path>
  <polyline points="17 21 17 13 7 13 7 21"></polyline>
  <polyline points="7 3 7 8 15 8"></polyline>
</svg>
''';

  static const bot = '''
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.2" stroke-linecap="round" stroke-linejoin="round">
  <path d="M12 8V4H8"></path>
  <rect x="5" y="8" width="14" height="12" rx="2"></rect>
  <circle cx="9" cy="13" r="1"></circle>
  <circle cx="15" cy="13" r="1"></circle>
  <path d="M9 16h6"></path>
</svg>
''';

  static const idea = '''
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.2" stroke-linecap="round" stroke-linejoin="round">
  <path d="M15 14c.2-1 .7-1.7 1.5-2.5 1-.9 1.5-2.2 1.5-3.5A5 5 0 0 0 8 8c0 1 .3 2.2 1.5 3.5.7.7 1.3 1.5 1.5 2.5"></path>
  <path d="M9 18h6"></path>
  <path d="M10 22h4"></path>
</svg>
''';
}
