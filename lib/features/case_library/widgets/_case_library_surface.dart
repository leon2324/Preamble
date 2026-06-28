import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:preamble/features/case_library/theme/case_library_theme.dart';

class CaseLibrarySurface extends StatelessWidget {
  const CaseLibrarySurface(
      {super.key, required this.child, this.onTap, this.padding});

  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    final box = Container(
      padding: padding ?? EdgeInsets.all(CaseLibrarySpacing.spaceL.w),
      decoration: BoxDecoration(
        color: CaseLibraryColors.libraryCardGlass,
        borderRadius: BorderRadius.circular(CaseLibraryRadii.radiusLarge.r),
        border: Border.all(
          color: CaseLibraryColors.libraryBorderGold.withValues(alpha: .92),
        ),
        boxShadow: [
          CaseLibraryShadows.goldGlow,
          BoxShadow(
            color: Colors.black.withValues(alpha: .34),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: child,
    );
    if (onTap == null) return box;
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(CaseLibraryRadii.radiusLarge.r),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(CaseLibraryRadii.radiusLarge.r),
        child: box,
      ),
    );
  }
}
