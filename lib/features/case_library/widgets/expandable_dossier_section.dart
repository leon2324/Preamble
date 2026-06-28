import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:preamble/features/case_library/theme/case_library_theme.dart';

class ExpandableDossierSection extends StatelessWidget {
  const ExpandableDossierSection(
      {super.key, required this.title, required this.body});

  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
      child: ExpansionTile(
        tilePadding: EdgeInsets.zero,
        collapsedIconColor: CaseLibraryColors.libraryMutedGold,
        iconColor: CaseLibraryColors.libraryMutedGold,
        title: Text(title, style: CaseLibraryTextStyles.sectionTitle(context)),
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: Padding(
              padding: EdgeInsets.only(bottom: CaseLibrarySpacing.spaceM.h),
              child: Text(body, style: CaseLibraryTextStyles.body(context)),
            ),
          ),
        ],
      ),
    );
  }
}
