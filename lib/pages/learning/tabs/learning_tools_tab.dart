part of '../know_law_page.dart';

/// 生活工具箱 Tab 外層容器。
///
/// 台灣繁體中文教學註解：
/// 這個 widget 只包住原本在 KnowLawPageState 組出的 Tab 子項目，
/// 真正資料來源、互動狀態與視覺 helper 仍留在原本 state，避免 Step 4A 改到功能邏輯。
class LearningToolsTab extends StatelessWidget {
  const LearningToolsTab({super.key, required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: children,
    );
  }
}

extension LearningToolsTabBuilder on KnowLawPageState {
  Widget buildLearningToolsTab(bool isDark, LearningGameState gameState) {
    return LearningToolsTab(children: [
      _buildToolkitTabs(isDark),
      SizedBox(height: 12.h),
      _buildActiveTool(isDark, gameState),
      SizedBox(height: 12.h),
      _buildStatuteSearchWidget(),
    ]);
  }
}
