/// LawApp 會員層級。
///
/// 台灣繁體中文教學註解：
/// 權限層級集中放在 data/user，避免頁面、AppState、AuthService 各自宣告一份；
/// 日後若新增 trial、admin 或 family plan，也只需要從這裡往外擴充。
enum LawAppAccessTier {
  guest,
  member,
  subscriber,
}

extension LawAppAccessTierLabels on LawAppAccessTier {
  String get label {
    switch (this) {
      case LawAppAccessTier.guest:
        return '訪客';
      case LawAppAccessTier.member:
        return '已登入';
      case LawAppAccessTier.subscriber:
        return '訂閱者';
    }
  }

  String get helperText {
    switch (this) {
      case LawAppAccessTier.guest:
        return '可查詢公開內容與試用小法助一次。';
      case LawAppAccessTier.member:
        return '可保存對話、追蹤主題與記錄學習進度。';
      case LawAppAccessTier.subscriber:
        return '可使用進階文件產生、完整案例整理與高額度 AI。';
    }
  }

  int get defaultDailyAiQuota {
    switch (this) {
      case LawAppAccessTier.guest:
        return 1;
      case LawAppAccessTier.member:
        return 20;
      case LawAppAccessTier.subscriber:
        return 200;
    }
  }
}
