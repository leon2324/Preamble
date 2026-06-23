import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lawapp/features/case_time_machine/data/case_time_machine_mock_data.dart';
import 'package:lawapp/features/case_time_machine/models/case_time_machine_models.dart';
import 'package:lawapp/features/case_time_machine/theme/case_time_machine_theme.dart';

class CaseBookCover extends StatelessWidget {
  const CaseBookCover({super.key, required this.book});

  final CaseBook book;

  @override
  Widget build(BuildContext context) {
    return Hero(
      tag: 'case-book-${book.id}',
      child: Material(
        color: Colors.transparent,
        child: Container(
          padding: EdgeInsets.all(CaseTimeMachineSpacing.spaceXL.w),
          decoration: BoxDecoration(
            image: const DecorationImage(
              image: AssetImage(caseTimeMachineV2CaseBookCoverAsset),
              fit: BoxFit.cover,
            ),
            borderRadius:
                BorderRadius.circular(CaseTimeMachineRadii.radiusXL.r),
            border: Border.all(
                color: CaseTimeMachineColors.libraryBorderGold, width: 1.6),
            boxShadow: [
              CaseTimeMachineShadows.goldGlow,
              CaseTimeMachineShadows.mistGlow
            ],
          ),
          child: Stack(
            fit: StackFit.expand,
            children: [
              DecoratedBox(
                decoration: BoxDecoration(
                  borderRadius:
                      BorderRadius.circular(CaseTimeMachineRadii.radiusXL.r),
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withValues(alpha: .18),
                      CaseTimeMachineColors.libraryMidnight
                          .withValues(alpha: .46),
                      Colors.black.withValues(alpha: .28),
                    ],
                  ),
                ),
              ),
              CustomPaint(painter: _GeneratedBookCoverFramePainter()),
              Center(
                // 台灣繁體中文教學註解：
                // 案件書封面改成 Flutter 原生繪製，不再吃舊版 cover asset；
                // 文字區仍用 FittedBox 防止中文長標與橫向測試尺寸爆版。
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: SizedBox(
                    width: 178.w,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.balance_rounded,
                            color: CaseTimeMachineColors.libraryMutedGold,
                            size: 36.sp),
                        SizedBox(height: CaseTimeMachineSpacing.spaceXL.h),
                        Text(book.shortTitleZh,
                            textAlign: TextAlign.center,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style:
                                CaseTimeMachineTextStyles.pageTitle(context)),
                        SizedBox(height: CaseTimeMachineSpacing.spaceS.h),
                        Text(book.shortTitleEn,
                            textAlign: TextAlign.center,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: CaseTimeMachineTextStyles.caption(context)),
                        SizedBox(height: CaseTimeMachineSpacing.spaceL.h),
                        Text('${book.year}',
                            style:
                                CaseTimeMachineTextStyles.sectionTitle(context)
                                    .copyWith(
                                        color: CaseTimeMachineColors
                                            .libraryMutedGold)),
                        Text(book.category,
                            textAlign: TextAlign.center,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: CaseTimeMachineTextStyles.caption(context)),
                      ],
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
}

class _GeneratedBookCoverFramePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final gold = Paint()
      ..color = CaseTimeMachineColors.libraryMutedGold.withValues(alpha: .62)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.1;
    final inner = Rect.fromLTWH(12, 12, size.width - 24, size.height - 24);
    canvas.drawRRect(
      RRect.fromRectAndRadius(inner, const Radius.circular(22)),
      gold,
    );
    canvas.drawLine(
      Offset(size.width * .18, size.height * .13),
      Offset(size.width * .82, size.height * .13),
      gold,
    );
    canvas.drawLine(
      Offset(size.width * .18, size.height * .87),
      Offset(size.width * .82, size.height * .87),
      gold,
    );

    final glow = Paint()
      ..shader = RadialGradient(
        colors: [
          const Color(0xFF79D8CF).withValues(alpha: .18),
          Colors.transparent,
        ],
      ).createShader(
        Rect.fromCircle(
          center: Offset(size.width * .5, size.height * .44),
          radius: size.shortestSide * .58,
        ),
      );
    canvas.drawRect(Offset.zero & size, glow);
  }

  @override
  bool shouldRepaint(covariant _GeneratedBookCoverFramePainter oldDelegate) =>
      false;
}
