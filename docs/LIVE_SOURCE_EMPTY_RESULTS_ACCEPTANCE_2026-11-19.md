# 正式來源空結果與錯誤契約驗收（2026-11-19）

## 目的

已設定正式來源時，成功回傳 `[]` 表示查無資料；連線或 HTTP 失敗必須保留為錯誤。這兩種情況都不應顯示內建示範內容。未設定來源時保留原展示流程；只有明確注入 `DataFallbackPolicy.demo` 才允許正式來源空結果或錯誤回退。

## 本批修改

| 來源 | 正式成功空清單 | 正式失敗 | 未設定來源 |
| --- | --- | --- | --- |
| 案件、官方消息、全站搜尋 | 回傳空清單 | 向上傳遞錯誤 | 既有本機／MOJ 流程 |
| 法規 | 回傳空清單 | 向上傳遞錯誤 | 法務部來源無未設定分支 |
| 學習文章、生活筆記 | 回傳空清單 | 向上傳遞錯誤 | 既有本機展示資料 |
| 每日精選專題 | 從真正存在的專題 ID 選取；無完整專題時回空 | 向上傳遞錯誤 | 既有固定專題 |
| 案件庫分頁 | 回傳空清單，不再讀 SQLite 或種子案件 | 向上傳遞錯誤 | 既有本機目錄 |

生活筆記頁的載入失敗分支不再塞入展示清單，空清單時也不渲染假精選卡；案件館在已設定雲端時不再把固定書架、代表案或推薦種子加入遠端查詢結果。學堂每日專題空清單或失敗時改用既有共用空／錯誤狀態元件，不再回到固定專題；未設定來源的本機課程及使用者自訂課程保留。這些只改資料綁定及資料狀態，未調整版面樣式、尺寸或顏色。

Supabase 學習、生活筆記與案件服務現在可注入 HTTP client 與來源設定以測試三種來源狀態；正式 App 仍使用既有單例。每日專題先分頁取得真正存在的 ID，再按日期確定性抽選最多五個。服務擁有自己建立的 client；外部注入的 client 由呼叫端管理。

## 驗證

- `/Users/babychen/Documents/flutter/bin/cache/dart-sdk/bin/dart analyze`：`No issues found!`。
- `flutter test --no-pub --reporter expanded test/supabase_source_contract_test.dart test/data_fallback_policy_test.dart test/backend_api_services_test.dart`：24 項通過。
- `flutter test --no-pub --reporter expanded test/phase21_global_search_upgrades_test.dart test/home_dashboard_feed_test.dart`：10 項通過。
- `flutter test --no-pub --reporter expanded test/learning_top_inset_test.dart test/phase22_case_library_wikipedia_portals_test.dart`：6 項通過、1 項失敗。失敗是既有 `CaseLibraryEntryPage renders Wikipedia Portals carousel` 的 `pumpAndSettle timed out`；學堂三項與案件館 portal 測例通過。正式來源分支尚未做 widget 層注入測試。
- `git diff --check`：通過。
- 沒有連接正式 Supabase、推送、部署或真機驗收。上一批全量 UI 測試有 8 項既有失敗；本批尚未重跑全量。

## 已知界線

- 學堂另有使用者自訂專題與獨立的本機課程內容，案件館 portal 與入口頁也有靜態編輯內容；本批不把這些內容當作遠端分頁結果。若產品要在正式模式全面隱藏所有靜態內容，需另外定義其內容來源與空畫面契約。
- 文件草稿的本機資料可能是使用者建立的離線內容，因此本批沒有將「請求失敗」一律清空。追蹤／小法助的 mock 模式只在後端未設定時啟用，未發現正式成功空清單被它們替換。
- 頁面目前主要呈現既有空狀態；錯誤訊息的專屬呈現仍需產品規格。本批不變更視覺設計。

## 給 Antigravity 的接手順序

1. 查 `git log -1`、`git status --short`，確認本批 Commit 與乾淨工作區。
2. 讀取 `docs/AI_HANDOVER.md` 與 `docs/IMPLEMENTATION_STATUS.md` 的最新快照，再查本文件的來源矩陣。
3. 若要擴至整站靜態編輯內容，先確認「示範內容」與「本機正式內容」的產品定義，再改頁面空狀態；勿把本批遠端空清單回退重新加回去。
