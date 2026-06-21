part of '../know_law_page.dart';

/// 手帳筆記 Tab 外層容器。
///
/// 台灣繁體中文教學註解：
/// 這個 widget 只包住原本在 KnowLawPageState 組出的 Tab 子項目，
/// 真正資料來源、互動狀態與視覺 helper 仍留在原本 state，避免 Step 4A 改到功能邏輯。
class LearningNotebookTab extends StatelessWidget {
  const LearningNotebookTab({super.key, required this.children});

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

extension LearningNotebookTabBuilder on KnowLawPageState {
  // ==========================================
  // 📝 手帳筆記分頁建構與互動邏輯
  // ==========================================

  Widget buildLearningNotebookTab(bool isDark, LearningGameState gameState) {
    return LearningNotebookTab(children: [
      // 1. 筆記本美學與字體設定
      _buildAestheticsConfigCard(isDark, gameState),
      SizedBox(height: 12.h),

      // 2. 我的手帳貼紙簿
      _buildStickersAlbumCard(isDark, gameState),
      SizedBox(height: 12.h),

      // 3. 我的法律摘錄本
      _buildHighlightsSection(isDark, gameState),
      SizedBox(height: 12.h),

      // 4. 三段論邏輯思維筆記
      _buildCornellSection(isDark, gameState),
    ]);
  }
}
