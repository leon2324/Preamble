import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:preamble/pages/journal/widgets/journal_palette.dart';

class JournalPageHeader extends StatelessWidget {
  const JournalPageHeader({super.key, required this.palette});

  final JournalPalette palette;
  static const _headerAspectRatio = 1983 / 793;

  @override
  Widget build(BuildContext context) {
    // 這版 header 完全只顯示使用者提供的圖片，不再疊任何文字或搜尋欄；
    // 為了適應手機寬度，直接用圖片原始長寬比顯示，避免被固定高度裁切變形。
    return AspectRatio(
      aspectRatio: _headerAspectRatio,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18.r),
        child: Image.asset(
          'assets/images/journal/journal_header.png',
          fit: BoxFit.cover,
          alignment: Alignment.center,
        ),
      ),
    );
  }
}
