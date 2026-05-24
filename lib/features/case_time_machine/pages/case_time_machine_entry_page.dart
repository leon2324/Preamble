import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lawapp/features/case_time_machine/pages/case_library_hall_selection_page.dart';
import 'package:lawapp/features/case_time_machine/theme/case_time_machine_theme.dart';
import 'package:lawapp/features/case_time_machine/widgets/_ctm_surface.dart';
import 'package:lawapp/features/case_time_machine/widgets/case_library_hero_panel.dart';
import 'package:lawapp/features/case_time_machine/widgets/case_time_machine_scaffold.dart';

class CaseTimeMachineEntryPage extends StatelessWidget {
  const CaseTimeMachineEntryPage({super.key});

  void _enterLibrary(BuildContext context) {
    Navigator.of(context).push(
      CupertinoPageRoute<void>(
        builder: (_) => const CaseLibraryHallSelectionPage(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return CaseTimeMachineScaffold(
      scene: CaseTimeMachineScene.entry,
      child: ListView(
        padding: EdgeInsets.fromLTRB(24.w, 76.h, 24.w, 32.h),
        children: [
          const CaseLibraryHeroPanel(
            title: '案件時光機',
            eyebrow: 'CASE TIME MACHINE',
            subtitle: '走進案件圖書館，翻開那些曾經震動社會的卷宗',
          ),
          SizedBox(height: CaseTimeMachineSpacing.spaceXL.h),
          CtmSurface(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('案件圖書館',
                    style: CaseTimeMachineTextStyles.sectionTitle(context)),
                SizedBox(height: CaseTimeMachineSpacing.spaceM.h),
                Text(
                  '依年代、主題與經典案件，重新理解事件背後的法律脈絡。這裡不是普通列表，而是一座可以逐層探索的深綠法律資料館。',
                  style: CaseTimeMachineTextStyles.body(context),
                ),
                SizedBox(height: CaseTimeMachineSpacing.spaceL.h),
                const _ProcessRail(),
              ],
            ),
          ),
          SizedBox(height: CaseTimeMachineSpacing.spaceXL.h),
          FilledButton(
            style: FilledButton.styleFrom(
              minimumSize: Size.fromHeight(52.h),
              backgroundColor: CaseTimeMachineColors.libraryDeepTeal,
              side: const BorderSide(
                  color: CaseTimeMachineColors.libraryBorderGold),
            ),
            onPressed: () => _enterLibrary(context),
            child: Text('進入案件圖書館',
                style: CaseTimeMachineTextStyles.buttonText(context)),
          ),
        ],
      ),
    );
  }
}

class _ProcessRail extends StatelessWidget {
  const _ProcessRail();

  @override
  Widget build(BuildContext context) {
    final steps = [
      ('1', '選館'),
      ('2', '選書架'),
      ('3', '抽出案件之書'),
      ('4', '翻開卷宗'),
    ];

    // 台灣繁體中文教學註解：
    // 流程提示用 Wrap 而不是固定 Row，避免小螢幕或大字級時發生 overflow。
    return Wrap(
      spacing: 8.w,
      runSpacing: 8.h,
      children: [
        for (final step in steps)
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(999),
              color:
                  CaseTimeMachineColors.libraryDeepGreen.withValues(alpha: .58),
              border:
                  Border.all(color: CaseTimeMachineColors.libraryBorderMist),
            ),
            child: Text('${step.$1} ${step.$2}',
                style: CaseTimeMachineTextStyles.chipText(context)),
          ),
      ],
    );
  }
}
