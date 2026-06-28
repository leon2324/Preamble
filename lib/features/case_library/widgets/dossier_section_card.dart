import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:preamble/features/case_library/theme/case_library_theme.dart';
import 'package:preamble/features/case_library/widgets/_case_library_surface.dart';

class DossierSectionCard extends StatelessWidget {
  const DossierSectionCard(
      {super.key, required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return CaseLibrarySurface(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: CaseLibraryTextStyles.sectionTitle(context)),
          SizedBox(height: CaseLibrarySpacing.spaceM.h),
          child,
        ],
      ),
    );
  }
}
