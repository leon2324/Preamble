import 'package:flutter/cupertino.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lawapp/features/case_time_machine/data/case_time_machine_mock_data.dart';
import 'package:lawapp/features/case_time_machine/models/case_time_machine_models.dart';
import 'package:lawapp/features/case_time_machine/pages/case_library_hall_page.dart';
import 'package:lawapp/features/case_time_machine/theme/case_time_machine_theme.dart';
import 'package:lawapp/features/case_time_machine/widgets/case_library_hero_panel.dart';
import 'package:lawapp/features/case_time_machine/widgets/case_time_machine_scaffold.dart';
import 'package:lawapp/features/case_time_machine/widgets/hall_selection_card.dart';

class CaseLibraryHallSelectionPage extends StatelessWidget {
  const CaseLibraryHallSelectionPage({super.key});

  void _openHall(BuildContext context, CaseLibraryHall hall) {
    Navigator.of(context).push(
      CupertinoPageRoute<void>(
        builder: (_) => CaseLibraryHallPage(hall: hall),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return CaseTimeMachineScaffold(
      scene: CaseTimeMachineScene.halls,
      child: ListView(
        padding: EdgeInsets.fromLTRB(20.w, 70.h, 20.w, 32.h),
        children: [
          const CaseLibraryHeroPanel(
            title: '三大館',
            eyebrow: 'SELECT A HALL',
            subtitle: '選擇你想探索的館別，從時間、主題或經典書單進入案件書架。',
            emblemAsset: caseTimeMachineV2EraEmblemAsset,
          ),
          SizedBox(height: CaseTimeMachineSpacing.spaceXL.h),
          for (final hall in caseTimeMachineHalls) ...[
            HallSelectionCard(
                hall: hall, onTap: () => _openHall(context, hall)),
            SizedBox(height: CaseTimeMachineSpacing.spaceM.h),
          ],
        ],
      ),
    );
  }
}
