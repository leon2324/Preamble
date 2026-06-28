import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:preamble/features/case_library/models/case_library_models.dart';
import 'package:preamble/features/case_library/theme/case_library_theme.dart';

class CaseBookSpineCard extends StatelessWidget {
  const CaseBookSpineCard({
    super.key,
    required this.book,
    required this.onTap,
    this.compact = false,
  });

  final CaseBook book;
  final VoidCallback onTap;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Hero(
      tag: 'case-book-${book.id}',
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(CaseLibraryRadii.radiusMedium.r),
          child: Container(
            width: compact ? 58.w : 48.w,
            height: compact ? 148.h : 128.h,
            padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 7.h),
            decoration: BoxDecoration(
              borderRadius:
                  BorderRadius.circular(CaseLibraryRadii.radiusMedium.r),
              gradient: const LinearGradient(
                colors: [
                  CaseLibraryColors.libraryDeepTeal,
                  CaseLibraryColors.libraryDeepGreen,
                ],
              ),
              border: Border.all(color: CaseLibraryColors.libraryBorderGold),
              boxShadow: [CaseLibraryShadows.mistGlow],
            ),
            child: Column(
              children: [
                Text('${book.year}',
                    maxLines: 1,
                    style: CaseLibraryTextStyles.chipText(context)),
                SizedBox(height: CaseLibrarySpacing.spaceXS.h),
                Container(
                  width: double.infinity,
                  height: 1,
                  color:
                      CaseLibraryColors.libraryMutedGold.withValues(alpha: .42),
                ),
                SizedBox(height: CaseLibrarySpacing.spaceS.h),
                Expanded(
                  // 書脊只放「短碼＋符號」，完整中文／英文案名交給下方資訊卡。
                  // 這樣能忠實保留 Prototype 的書架感，也不會在英文案名變長時截斷。
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: SizedBox(
                      width: (compact ? 44 : 38).r,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(
                              book.displayCode,
                              maxLines: 1,
                              style: CaseLibraryTextStyles.cardTitle(context)
                                  .copyWith(letterSpacing: .3),
                            ),
                          ),
                          SizedBox(height: CaseLibrarySpacing.spaceXS.r),
                          _SpineSeal(category: book.category),
                          SizedBox(height: CaseLibrarySpacing.spaceXS.r),
                          FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(
                              _categoryCode(book.category),
                              maxLines: 1,
                              style: CaseLibraryTextStyles.caption(context)
                                  .copyWith(
                                color: CaseLibraryColors.libraryMistBlue,
                                height: 1.1,
                                letterSpacing: .8,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                _BookmarkMark(filled: book.isFavorite),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

String _categoryCode(String category) {
  if (category.contains('司法')) return 'LAW';
  if (category.contains('校園') || category.contains('少年')) return 'SCH';
  if (category.contains('詐欺') || category.contains('財產')) return 'FRD';
  if (category.contains('制度')) return 'REF';
  if (category.contains('重大')) return 'CRM';
  if (category.contains('安全')) return 'SAF';
  return 'SOC';
}

class _SpineSeal extends StatelessWidget {
  const _SpineSeal({required this.category});

  final String category;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 18.r,
      height: 18.r,
      child: CustomPaint(painter: _SpineSealPainter(category)),
    );
  }
}

class _BookmarkMark extends StatelessWidget {
  const _BookmarkMark({required this.filled});

  final bool filled;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 13.r,
      height: 16.r,
      child: CustomPaint(painter: _BookmarkPainter(filled)),
    );
  }
}

class _SpineSealPainter extends CustomPainter {
  const _SpineSealPainter(this.category);

  final String category;

  @override
  void paint(Canvas canvas, Size size) {
    final gold = Paint()
      ..color = CaseLibraryColors.libraryMutedGold
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;
    canvas.drawCircle(
        size.center(Offset.zero), size.shortestSide / 2 - 1, gold);

    if (category.contains('校園')) {
      final path = Path()
        ..moveTo(size.width * .22, size.height * .62)
        ..lineTo(size.width * .5, size.height * .28)
        ..lineTo(size.width * .78, size.height * .62);
      canvas.drawPath(path, gold);
      canvas.drawLine(Offset(size.width * .34, size.height * .62),
          Offset(size.width * .66, size.height * .62), gold);
      return;
    }

    if (category.contains('司法')) {
      canvas.drawLine(Offset(size.width * .5, size.height * .24),
          Offset(size.width * .5, size.height * .76), gold);
      canvas.drawLine(Offset(size.width * .28, size.height * .4),
          Offset(size.width * .72, size.height * .4), gold);
      canvas.drawCircle(Offset(size.width * .34, size.height * .62), 2, gold);
      canvas.drawCircle(Offset(size.width * .66, size.height * .62), 2, gold);
      return;
    }

    if (category.contains('詐欺')) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(size.width * .27, size.height * .32, size.width * .46,
              size.height * .38),
          const Radius.circular(3),
        ),
        gold,
      );
      canvas.drawCircle(size.center(Offset.zero), 2, gold);
      return;
    }

    canvas.drawLine(Offset(size.width * .24, size.height * .68),
        Offset(size.width * .76, size.height * .68), gold);
    canvas.drawLine(Offset(size.width * .5, size.height * .28),
        Offset(size.width * .5, size.height * .68), gold);
    canvas.drawCircle(Offset(size.width * .5, size.height * .26), 2.2, gold);
  }

  @override
  bool shouldRepaint(covariant _SpineSealPainter oldDelegate) =>
      oldDelegate.category != category;
}

class _BookmarkPainter extends CustomPainter {
  const _BookmarkPainter(this.filled);

  final bool filled;

  @override
  void paint(Canvas canvas, Size size) {
    final path = Path()
      ..moveTo(size.width * .18, 0)
      ..lineTo(size.width * .82, 0)
      ..lineTo(size.width * .82, size.height)
      ..lineTo(size.width * .5, size.height * .72)
      ..lineTo(size.width * .18, size.height)
      ..close();
    final paint = Paint()
      ..color = CaseLibraryColors.libraryMistBlue
          .withValues(alpha: filled ? .86 : .38)
      ..style = filled ? PaintingStyle.fill : PaintingStyle.stroke
      ..strokeWidth = 1.2;
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _BookmarkPainter oldDelegate) =>
      oldDelegate.filled != filled;
}
