import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:preamble/features/case_library/data/case_library_data.dart';
import 'package:preamble/features/case_library/models/case_library_models.dart';
import 'package:preamble/features/case_library/pages/case_library_hall_page.dart';
import 'package:preamble/features/case_library/theme/case_library_theme.dart';
import 'package:preamble/features/case_library/widgets/case_library_scaffold.dart';
import 'package:preamble/features/case_library/widgets/case_library_svg_icon.dart';

class CaseLibraryHallSelectionPage extends StatelessWidget {
  const CaseLibraryHallSelectionPage({super.key});

  void _openHall(BuildContext context, CaseLibraryHall hall) {
    Navigator.of(context).push(
      CupertinoPageRoute<void>(
        builder: (__) => CaseLibraryHallPage(hall: hall),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final hallItems = [
      (
        id: 'timeline',
        iconSvg: CaseLibrarySvgIcons.clock,
        title: '年代館',
        desc: '依年代代表案件',
        detail: '以時間線梳理起社會與法律變遷',
      ),
      (
        id: 'theme',
        iconSvg: CaseLibrarySvgIcons.grid,
        title: '主題館',
        desc: '依議題探索案件',
        detail: '從關注主題快速找到相關案件',
      ),
      (
        id: 'classic',
        iconSvg: CaseLibrarySvgIcons.star,
        title: '經典館',
        desc: '先看最具代表性的案件',
        detail: '精選經典案例，掌握重要法理',
      ),
      (
        id: 'status',
        iconSvg: CaseLibrarySvgIcons.scale,
        title: '狀態館',
        desc: '依案件目前狀態切入思辨',
        detail: '看案件正處於發酵、落幕還是爭議中',
      ),
    ];

    return CaseLibraryScaffold(
      scene: CaseLibraryScene.halls,
      showBackButton: false,
      useSafeArea: false,
      child: Container(
        color: CaseLibraryColors.bgCream,
        child: SafeArea(
          bottom: false,
          child: ListView(
            padding: EdgeInsets.fromLTRB(18.w, 12.h, 18.w, 32.h),
            children: [
              // Header back button & title (Centered Layout)
              // 此處使用 Stack 進行 AppBar 標題與副標題的置中排版。
              // 使用 Positioned.fill 將返回按鈕固定於左側，並讓 Column（包含標題與描述）置中。
              // 這能確保即使左側有按鈕，整體頁面的視覺主軸依然能夠維持在水平正中央。
              SizedBox(
                width: double.infinity,
                height: 64.h,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Positioned(
                      left: 0,
                      child: IconButton(
                        icon: CaseLibrarySvgIcon(
                          CaseLibrarySvgIcons.chevronLeft,
                          size: 20.w,
                          color: CaseLibraryColors.primaryGreen,
                        ),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '選擇探索方式',
                          style:
                              CaseLibraryTextStyles.pageTitle(context).copyWith(
                            fontSize: 20.sp,
                          ),
                        ),
                        SizedBox(height: 3.h),
                        Text(
                          '你可以從年代、主題、經典或案件狀態切入。',
                          style:
                              CaseLibraryTextStyles.bodySmall(context).copyWith(
                            fontSize: 11.sp,
                            color: CaseLibraryColors.textMuted,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              SizedBox(height: 24.h),

              // List of Hall Selection Cards
              for (final item in hallItems) ...[
                _SelectionCard(
                  iconSvg: item.iconSvg,
                  title: item.title,
                  desc: item.desc,
                  detail: item.detail,
                  onTap: () {
                    final hall = caseLibraryHallById(item.id);
                    _openHall(context, hall);
                  },
                ),
                SizedBox(height: 16.h),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _SelectionCard extends StatelessWidget {
  const _SelectionCard({
    required this.iconSvg,
    required this.title,
    required this.desc,
    required this.detail,
    required this.onTap,
  });

  final String iconSvg;
  final String title;
  final String desc;
  final String detail;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(CaseLibraryRadii.radiusLarge.r),
        child: Container(
          padding: EdgeInsets.all(20.w),
          decoration: BoxDecoration(
            color: CaseLibraryColors.bgWhite,
            borderRadius: BorderRadius.circular(CaseLibraryRadii.radiusLarge.r),
            border: Border.all(color: CaseLibraryColors.borderLight),
            boxShadow: [CaseLibraryShadows.softShadow],
          ),
          child: Row(
            children: [
              Container(
                width: 52.w,
                height: 52.w,
                decoration: const BoxDecoration(
                  color: CaseLibraryColors.bgCream,
                  shape: BoxShape.circle,
                ),
                child: CaseLibrarySvgIcon(
                  iconSvg,
                  size: 26.sp,
                  color: CaseLibraryColors.primaryGreen,
                ),
              ),
              SizedBox(width: 18.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: CaseLibraryTextStyles.cardTitle(context).copyWith(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      desc,
                      style: CaseLibraryTextStyles.bodySmall(context).copyWith(
                        color: CaseLibraryColors.accentGold,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      detail,
                      style: CaseLibraryTextStyles.caption(context),
                    ),
                  ],
                ),
              ),
              CaseLibrarySvgIcon(
                CaseLibrarySvgIcons.chevronRight,
                size: 16.sp,
                color: CaseLibraryColors.primaryGreen.withValues(alpha: 0.5),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
