import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lawapp/features/case_time_machine/models/case_time_machine_models.dart';
import 'package:lawapp/features/case_time_machine/theme/case_time_machine_theme.dart';

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
            style: CaseTimeMachineTextStyles.caption(context)
                .copyWith(color: CaseTimeMachineColors.libraryMutedGold)),
        SizedBox(height: CaseTimeMachineSpacing.spaceS.h),
        Text(shelf.name, style: CaseTimeMachineTextStyles.pageTitle(context)),
        SizedBox(height: CaseTimeMachineSpacing.spaceS.h),
        Text(shelf.description, style: CaseTimeMachineTextStyles.body(context)),
      ],
    );
  }
}
