import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lawapp/features/case_time_machine/models/case_time_machine_models.dart';
import 'package:lawapp/features/case_time_machine/theme/case_time_machine_theme.dart';

class CaseTimelineSection extends StatelessWidget {
  const CaseTimelineSection({super.key, required this.items});

  final List<CaseTimelineItem> items;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (var i = 0; i < items.length; i++)
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                children: [
                  Container(
                      width: 11.w,
                      height: 11.w,
                      decoration: const BoxDecoration(
                          color: CaseTimeMachineColors.libraryMistBlue,
                          shape: BoxShape.circle)),
                  if (i != items.length - 1)
                    Container(
                        width: 1,
                        height: 54.h,
                        color: CaseTimeMachineColors.libraryBorderGold),
                ],
              ),
              SizedBox(width: CaseTimeMachineSpacing.spaceM.w),
              Expanded(
                child: Padding(
                  padding:
                      EdgeInsets.only(bottom: CaseTimeMachineSpacing.spaceM.h),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('${items[i].dateLabel}｜${items[i].title}',
                          style: CaseTimeMachineTextStyles.chipText(context)),
                      SizedBox(height: CaseTimeMachineSpacing.spaceXS.h),
                      Text(items[i].description,
                          style: CaseTimeMachineTextStyles.bodySmall(context)),
                    ],
                  ),
                ),
              ),
            ],
          ),
      ],
    );
  }
}
