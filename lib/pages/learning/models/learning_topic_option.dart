/// 學習頁精選專題選項的資料模型。
///
/// 此 class 從 know_law_page.dart 拆出（Step 4E），為純資料結構，
/// 無任何 Flutter / package 依賴，代表一個課程主題選項的標題、標籤與可用狀態。
class LearningTopicOption {
  const LearningTopicOption(this.title, this.badge, this.isAvailable);

  final String title;
  final String badge;
  final bool isAvailable;
}
