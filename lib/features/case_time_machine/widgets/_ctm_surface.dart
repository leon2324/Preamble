import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lawapp/features/case_time_machine/theme/case_time_machine_theme.dart';

class CtmSurface extends StatelessWidget {
  const CtmSurface({super.key, required this.child, this.onTap, this.padding});

  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    final box = Container(
      padding: padding ?? EdgeInsets.all(CaseTimeMachineSpacing.spaceL.w),
      decoration: BoxDecoration(
        color: CaseTimeMachineColors.libraryCardGlass,
        borderRadius: BorderRadius.circular(CaseTimeMachineRadii.radiusLarge.r),
        border: Border.all(
          color: CaseTimeMachineColors.libraryBorderGold.withValues(alpha: .92),
        ),
        boxShadow: [
          CaseTimeMachineShadows.goldGlow,
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
      borderRadius: BorderRadius.circular(CaseTimeMachineRadii.radiusLarge.r),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(CaseTimeMachineRadii.radiusLarge.r),
        child: box,
      ),
    );
  }
}
