import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:preamble/features/case_library/models/case_library_models.dart';
import 'package:preamble/features/case_library/theme/case_library_theme.dart';

class CaseShelfHeader extends StatelessWidget {
  const CaseShelfHeader({super.key, required this.shelf, required this.hall});

  final CaseShelf shelf;
  final CaseLibraryHall hall;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('${hall.name} / ${shelf.name}',
            style: CaseLibraryTextStyles.caption(context)
                .copyWith(color: CaseLibraryColors.libraryMutedGold)),
        SizedBox(height: CaseLibrarySpacing.spaceS.h),
        Text(shelf.name, style: CaseLibraryTextStyles.pageTitle(context)),
        SizedBox(height: CaseLibrarySpacing.spaceS.h),
        Text(shelf.description, style: CaseLibraryTextStyles.body(context)),
      ],
    );
  }
}
