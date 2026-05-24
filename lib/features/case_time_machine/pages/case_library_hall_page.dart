import 'package:flutter/cupertino.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lawapp/features/case_time_machine/data/case_time_machine_mock_data.dart';
import 'package:lawapp/features/case_time_machine/models/case_time_machine_models.dart';
import 'package:lawapp/features/case_time_machine/pages/case_shelf_page.dart';
import 'package:lawapp/features/case_time_machine/theme/case_time_machine_theme.dart';
import 'package:lawapp/features/case_time_machine/widgets/case_library_hero_panel.dart';
import 'package:lawapp/features/case_time_machine/widgets/case_time_machine_scaffold.dart';
import 'package:lawapp/features/case_time_machine/widgets/shelf_card.dart';

class CaseLibraryHallPage extends StatelessWidget {
  const CaseLibraryHallPage({super.key, required this.hall});

  final CaseLibraryHall hall;

  CaseTimeMachineScene get _scene => switch (hall.type) {
        CaseLibraryHallType.timeline => CaseTimeMachineScene.timeline,
        CaseLibraryHallType.theme => CaseTimeMachineScene.theme,
        CaseLibraryHallType.classic => CaseTimeMachineScene.classic,
      };

  String get _emblemAsset => switch (hall.type) {
        CaseLibraryHallType.timeline => caseTimeMachineV2EraEmblemAsset,
        CaseLibraryHallType.theme => caseTimeMachineV2ThemeEmblemAsset,
        CaseLibraryHallType.classic => caseTimeMachineV2ClassicEmblemAsset,
      };

  void _openShelf(BuildContext context, CaseShelf shelf) {
    Navigator.of(context).push(
      CupertinoPageRoute<void>(
        builder: (_) => CaseShelfPage(hall: hall, shelf: shelf),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return CaseTimeMachineScaffold(
      scene: _scene,
      child: ListView(
        padding: EdgeInsets.fromLTRB(20.w, 70.h, 20.w, 32.h),
        children: [
          CaseLibraryHeroPanel(
            title: hall.name,
            eyebrow: 'CASE LIBRARY HALL',
            subtitle: hall.description,
            emblemAsset: _emblemAsset,
          ),
          SizedBox(height: CaseTimeMachineSpacing.spaceXL.h),
          Text('館內書架', style: CaseTimeMachineTextStyles.sectionTitle(context)),
          SizedBox(height: CaseTimeMachineSpacing.spaceM.h),
          for (final shelf in hall.shelves) ...[
            ShelfCard(shelf: shelf, onTap: () => _openShelf(context, shelf)),
            SizedBox(height: CaseTimeMachineSpacing.spaceM.h),
          ],
        ],
      ),
    );
  }
}
