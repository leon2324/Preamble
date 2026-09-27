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
    final portals = caseLibraryHalls
        .where((h) => h.type == CaseLibraryHallType.portal)
        .toList();

    final dimensionItems = [
      (
        id: 'timeline',
        iconSvg: CaseLibrarySvgIcons.clock,
        title: '年代大事紀館',
        desc: '依歷史時間軸梳理變遷',
        detail: '自 1990 年代至今，梳理台灣法律與人權關鍵演進',
      ),
      (
        id: 'theme',
        iconSvg: CaseLibrarySvgIcons.grid,
        title: '生活爭端實務館',
        desc: '依常見民刑事爭端切入',
        detail: '車禍賠償、借款返還、租屋糾紛等日常生活爭議裁判',
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
            padding: EdgeInsets.fromLTRB(18.w, 12.h, 18.w, 36.h),
            children: [
              // Header back button & title
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
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 48.w),
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              '司法專題館藏與分類目錄',
                              style:
                                  CaseLibraryTextStyles.pageTitle(context).copyWith(
                                fontSize: 19.sp,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            SizedBox(height: 3.h),
                            Text(
                              '依重大刑案、憲政人權、平反紀實等專題深度查閱',
                              style:
                                  CaseLibraryTextStyles.bodySmall(context).copyWith(
                                fontSize: 11.sp,
                                color: CaseLibraryColors.textMuted,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 18.h),

              // SECTION 1: 法律專題館藏（Legal Portals）
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '🏛️ 司法領域專題館藏',
                    style: CaseLibraryTextStyles.sectionTitle(context).copyWith(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w900,
                      color: CaseLibraryColors.primaryGreen,
                    ),
                  ),
                  Text(
                    '${portals.length} 大核心專題',
                    style: TextStyle(
                      fontSize: 11.sp,
                      fontWeight: FontWeight.bold,
                      color: CaseLibraryColors.accentGold,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 12.h),

              for (final portal in portals) ...[
                _PortalSelectionCard(
                  hall: portal,
                  onTap: () => _openHall(context, portal),
                ),
                SizedBox(height: 14.h),
              ],

              SizedBox(height: 18.h),

              // SECTION 2: 多維檢索維度
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '⏳ 多維司法檢索維度',
                    style: CaseLibraryTextStyles.sectionTitle(context).copyWith(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w900,
                      color: CaseLibraryColors.primaryGreen,
                    ),
                  ),
                  Text(
                    '年代・狀態・指標',
                    style: TextStyle(
                      fontSize: 11.sp,
                      color: CaseLibraryColors.textMuted,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 12.h),

              for (final item in dimensionItems) ...[
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
                SizedBox(height: 12.h),
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

class _PortalSelectionCard extends StatelessWidget {
  const _PortalSelectionCard({
    required this.hall,
    required this.onTap,
  });

  final CaseLibraryHall hall;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final accentColor = hall.accentColorValue != null
        ? Color(hall.accentColorValue!)
        : CaseLibraryColors.primaryGreen;

    final caseCount =
        hall.shelves.fold<int>(0, (sum, s) => sum + s.caseIds.length);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(CaseLibraryRadii.radiusLarge.r),
        child: Container(
          padding: EdgeInsets.all(18.w),
          decoration: BoxDecoration(
            color: CaseLibraryColors.bgWhite,
            borderRadius: BorderRadius.circular(CaseLibraryRadii.radiusLarge.r),
            border: Border.all(
              color: accentColor.withValues(alpha: 0.24),
              width: 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: accentColor.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
                    decoration: BoxDecoration(
                      color: accentColor.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(6.r),
                    ),
                    child: Text(
                      hall.badge ?? '專題館藏',
                      style: TextStyle(
                        fontSize: 10.5.sp,
                        fontWeight: FontWeight.w900,
                        color: accentColor,
                      ),
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF2F4F3),
                      borderRadius: BorderRadius.circular(4.r),
                    ),
                    child: Text(
                      '$caseCount 案典藏・${hall.shelves.length} 書架',
                      style: TextStyle(
                        fontSize: 10.sp,
                        color: CaseLibraryColors.textMuted,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 10.h),
              Text(
                hall.name,
                style: CaseLibraryTextStyles.cardTitle(context).copyWith(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w900,
                  color: const Color(0xFF17231F),
                ),
              ),
              SizedBox(height: 4.h),
              Text(
                hall.description,
                style: TextStyle(
                  fontSize: 11.5.sp,
                  color: CaseLibraryColors.textSecondary,
                  height: 1.4,
                ),
              ),
              if (hall.portalTags.isNotEmpty) ...[
                SizedBox(height: 10.h),
                Wrap(
                  spacing: 6.w,
                  runSpacing: 4.h,
                  children: hall.portalTags.take(3).map((tag) {
                    return Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF7F8F7),
                        borderRadius: BorderRadius.circular(4.r),
                        border: Border.all(
                          color: CaseLibraryColors.borderLight,
                        ),
                      ),
                      child: Text(
                        '#$tag',
                        style: TextStyle(
                          fontSize: 9.5.sp,
                          color: const Color(0xFF3B5E4F),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
              SizedBox(height: 12.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      '包含：${hall.shelves.map((s) => s.name).join('、')}',
                      style: TextStyle(
                        fontSize: 10.sp,
                        color: CaseLibraryColors.textMuted,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  SizedBox(width: 6.w),
                  Icon(
                    Icons.arrow_forward_rounded,
                    size: 14.sp,
                    color: accentColor,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
