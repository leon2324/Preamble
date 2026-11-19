# 資料來源回退契約驗收（2026-11-19）

## 範圍與基準

- 僅限 `lawapp`，分支 `redesign/home-responsive-carousel`，基準 Commit `501fe97`。
- 本批只修改資料層的政策與 repository、回歸測試及文件；沒有改 UI、前端展示、圖片、資料庫或遠端資料。
- 預設 `DataFallbackPolicy.demo` 保留現有 App 展示行為。`DataFallbackPolicy.strict` 由呼叫端明確注入，這一批沒有在正式 App 入口啟用。

## 三種結果的契約

| 情況 | 預設 demo | 明確指定 strict |
| --- | --- | --- |
| 未設定後端 | 使用既有本機／替代來源 | 丟出 `DataSourceUnavailableException` |
| 遠端成功但清單為空 | 案件、官方消息、搜尋保留原有回退；法規照實回空 | 照實回傳空清單 |
| 遠端請求失敗 | 使用各 repository 原有回退 | 保留原始錯誤往上傳，不偽裝為成功空清單 |

法規直接查法務部來源，不存在「未設定 `PREAMBLE_API_BASE_URL`」分支；成功空清單在兩種政策下都照實回空。官方消息的預設回退會先使用 MOJ 公開來源，必要時才用既有示範項。全站搜尋預設回退是本機聯合索引，不應把它標示成遠端結果。

政策只套用到上述 repository 的遠端讀取入口：案件的精選／檔案／搜尋／篩選／詳情、法規的 `fetchAllStatutes`／由其衍生的搜尋、官方消息清單，以及全站搜尋的 `searchAll`。案件的本機追蹤清單與搜尋 repository 的個別來源輔助方法仍維持各自既有語意；呼叫端注入自訂子 repository 時也須自行設定其政策。

## 實作與驗證

- 新增 `lib/data/common/data_fallback_policy.dart`；案件、法規、官方消息與全站搜尋 repository 接入明確政策。案件與官方消息的重複回退判斷已集中在各自的私有讀取函式。
- 新增 `test/data_fallback_policy_test.dart`，用假服務測未設定、成功空清單、失敗、預設回退與 strict 不回退。
- 全專案 `dart analyze`：最終版本 `No issues found!`。
- 聚焦 `flutter test --no-pub --reporter expanded test/data_fallback_policy_test.dart test/backend_api_services_test.dart test/mvp_foundation_test.dart test/phase21_global_search_upgrades_test.dart`：最終版本 30 項通過。
- 修改的 Dart 檔已執行 `dart format`；`git diff --check` 無問題。

## 限制與後續

- strict 是明確注入的資料層能力，尚未切換正式 App 的資料來源設定；切換前要先確認後端準備、頁面現有 error／empty 呈現及真實資料驗收。
- 本批未重跑全量 UI 測試；上一批全量結果為 304 項通過、8 項失敗，不可視為本批驗證。
- 尚未 push、建立 PR、執行遠端 CI、真實 JWT、真機或 production 部署。
