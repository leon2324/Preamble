import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:preamble/features/case_library/models/case_library_models.dart';
import 'package:preamble/features/case_library/theme/case_library_theme.dart';

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
                          color: CaseLibraryColors.libraryMistBlue,
                          shape: BoxShape.circle)),
                  if (i != items.length - 1)
                    Container(
                        width: 1,
                        height: 54.h,
                        color: CaseLibraryColors.libraryBorderGold),
                ],
              ),
              SizedBox(width: CaseLibrarySpacing.spaceM.w),
              Expanded(
                child: Padding(
                  padding: EdgeInsets.only(bottom: CaseLibrarySpacing.spaceM.h),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('${items[i].dateLabel}｜${items[i].title}',
                          style: CaseLibraryTextStyles.chipText(context)),
                      SizedBox(height: CaseLibrarySpacing.spaceXS.h),
                      Text(items[i].description,
                          style: CaseLibraryTextStyles.bodySmall(context)),
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
