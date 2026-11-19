# lawapp Codex／Antigravity 交接入口

此文件僅記錄 `lawapp`。每次接手先核對 Git 現況與最新驗收，不得把同層 `time_recorder` 的分支、測試、資料或部署狀態套用到此專案。

## 目前快照（2026-11-19，紀事頁即時新聞熱度榜串接）

- 分支 `redesign/home-responsive-carousel`，基準 Commit `a9ce622`。已透過 Supabase MCP 部署 `trending-topics` Edge Function（`verify_jwt: false`），即時抓取 Google News 台灣公開 RSS 統計各法制／社會議題報導篇數並動態排序（實測回傳 30–49 則新聞不等）。
- `DiscussingNowSection` 已改為 `StatefulWidget` 優先載入雲端即時新聞量與排序，離線或測試環境自動維持誠實的「焦點策展／示範策展」標示；`discussion_detail_page.dart` 同步去除假即時分數與漲跌幅。
- 下一步待 `phase20_journal_upgrades_test.dart` 通過後，Commit、push GitHub、重包 Release IPA（`1.1.0+2`）並上傳 TestFlight。

以下為上一批歷史快照（紀事頁討論策展誠實標示）。

## 目前快照（2026-11-19，紀事頁討論策展誠實標示）

- 分支 `redesign/home-responsive-carousel`，基準 Commit `a9ce622`（已 push 至 GitHub）。本批將紀事頁（`discussing_now_section.dart`、`discussion_detail_page.dart`）原本靜態的「熱度分數／24h 漲跌幅」改為誠實的「焦點策展／示範策展」標示，避免現場展示被誤認為即時爬蟲數據。
- 待確認分析與測試通過後，即可重新建置 Release IPA 並以 `xcrun altool` 上傳 TestFlight。

以下為上一批歷史快照（Supabase 喚醒與小法助 Gemini Edge Function 串接）。

## 目前快照（2026-11-19，Supabase 喚醒與小法助 Gemini Edge Function 串接）

- 分支 `redesign/home-responsive-carousel`，最新 Commit `b1e030f`；工作區含小法助回覆 UI 減法與 `LawAssistantRepository` 串接 Supabase Edge Function（尚未 commit）。
- **Supabase 狀態實測**：已透過 Supabase MCP 將 `LawApp`（`vtpdncwijhfjtegnnwkz`）由 `INACTIVE` 喚醒至 `ACTIVE_HEALTHY`，並查詢確認 `cases`（10,200 筆）、`life_legal_tips`（500 筆）、`learning_articles`（10,000 筆）皆有資料。
- **小法助雲端串接**：已部署 `law-assistant` Edge Function（`verify_jwt: false`）呼叫 Gemini API；`LawAssistantRepository` 於未設定 `PREAMBLE_API_BASE_URL` 時優先呼叫該 Edge Function，失敗或逾時（15 秒）自動退回本機三段論引擎，不把 AI Key 放進 Flutter。仍須使用者於 Supabase Dashboard 設定 `GEMINI_API_KEY` Secret 並上機實測。

以下為上一批歷史快照（小法助回覆 UI 減法與前夜優化）。

## 目前快照（2026-11-19，小法助回覆 UI 減法與前夜優化）

- 分支 `redesign/home-responsive-carousel`，最新 Commit `b1e030f`（含 App 內建瀏覽器、隱藏實驗室與語音按鈕、面試盤點紀錄）；工作區另有本批小法助回覆 UI 整理（尚未 commit）。
- 小法助對話頁（`law_assistant_chat_page.dart`）移除 AI 氣泡外框與重複 `【...】：` 標籤，並讓 `LawAssistantInsightCard` 於對話中預設收合（獨立元件預設仍為展開），降低多層框線壓迫感。
- 驗證：`dart analyze` 無問題（`No issues found!`）；`test/phase14_progressive_flow_test.dart` 與 `test/law_assistant_test.dart` 執行結果見 `IMPLEMENTATION_STATUS.md`。
- 盤點與風險細節見[面試展示盤點與風險紀錄](INTERVIEW_DEMO_READINESS_AUDIT_2026-11-19.md)；尚未 push 或編譯至 iPhone 實機。

以下為上一批歷史快照（面試展示盤點與前夜低風險優化）。

## 目前快照（2026-11-19，面試展示盤點與前夜低風險優化）

- 分支 `redesign/home-responsive-carousel`，基準 Commit `b8dc013`（本機有未 commit 修改）。本輪完成三項低風險展示優化：全站網頁 `launchUrl` 改為 `LaunchMode.inAppBrowserView`、隱藏 `profile_page.dart` 的「系統整合與實驗室」入口、隱藏舊版小法助語音麥克風按鈕。
- 驗證：`dart analyze` 無問題（`No issues found!`）；`test/phase24_case_library_independent_deliberation_test.dart` 14 項通過；`phase21_global_search_upgrades_test.dart` + `backend_api_services_test.dart` + `supabase_source_contract_test.dart` 22 項通過。先前全量 `flutter test`（修改前）為 324 通過、8 失敗。
- 盤點與風險細節見[面試展示盤點與風險紀錄](INTERVIEW_DEMO_READINESS_AUDIT_2026-11-19.md)；尚未重新 build 到實機或 commit。

以下為上一批歷史快照（案件庫正式快取），仍為目前資料層契約基準。

## 目前快照（2026-11-19，案件庫正式快取）

- 分支 `redesign/home-responsive-carousel`，開工基準 Commit `7cd6f58`。本批停止正式模式的內建案件種子初始化與舊 SQLite 正文優先讀取；正式詳情每次由雲端確認，只合併本機收藏／追蹤標記。
- 正式清單建立推薦快照，成功空結果清除舊推薦；案件入口先讀正式清單再選 Hero。正式詳情失敗時沿用共用錯誤狀態，不顯示傳入頁面的舊案件內容；離線模式保留原展示流程。
- 聚焦測試、已知 widget 測例失敗與靜態內容界線詳見[案件庫日期化驗收](CASE_LIBRARY_LIVE_CACHE_ACCEPTANCE_2026-11-19.md)。最新 Commit SHA 以 `git log -1` 查核；未 push、部署或驗收正式 Supabase。
- 下一步應為靜態編輯內容與 generated `caseLibraryCases` 定義來源標示及正式模式契約；SQLite 若要移除舊種子列，須先規劃不刪收藏／追蹤標記的 migration。

以下為上一批歷史快照，不代表目前案件詳情快取優先順序。

## 目前快照（2026-11-19，正式來源空結果）

- 分支 `redesign/home-responsive-carousel`，開工基準 Commit `06e1ef6`。本批將案件、法規、官方消息與全站搜尋的預設改為 `DataFallbackPolicy.liveWhenConfigured`：正式來源成功空結果照實回空，失敗向上傳遞；未設定來源仍保留既有展示流程。`demo` 僅供明確選用。
- 學習文章、生活筆記、每日專題與案件庫分頁採用同一來源契約；每日專題改從實際存在的 ID 抽選。生活筆記、案件館與學堂的資料綁定不再把示範項目加進正式空清單；沿用共用空／錯誤狀態，沒有改版面樣式。
- 聚焦測試與來源矩陣、靜態內容界線見 [正式來源驗收](LIVE_SOURCE_EMPTY_RESULTS_ACCEPTANCE_2026-11-19.md)。本批最終分析與 Git 狀態以該文件及 `git log -1` 查核；尚未 push、部署或驗收正式資料庫。
- 下一步應定義靜態編輯內容、離線使用者資料與正式後端資料在頁面上的來源標示及錯誤／空狀態契約。

以下為上一批歷史快照，不代表目前預設回退行為。

## 目前快照（2026-11-19，資料來源回退契約）

- 分支 `redesign/home-responsive-carousel`，基準 Commit `501fe97`。本批新增 `DataFallbackPolicy.demo`／`strict`，在案件、法規、官方消息及全站搜尋 repository 明確區分未設定、遠端成功空清單與遠端錯誤。
- 預設 demo 維持既有展示；strict 僅在呼叫端明確注入時生效，本批沒有調整正式 App 入口或 UI。法規來源的成功空清單仍照實回空，官方消息預設保留 MOJ 回退。
- 全專案 `dart analyze` 無問題，聚焦 Flutter 測試 30 項通過；涵蓋範圍及限制見[本批日期化驗收](DATA_SOURCE_FALLBACK_ACCEPTANCE_2026-11-19.md)。本批 Commit SHA 以 `git log -1` 查核；尚未 push、建立 PR、執行遠端 CI、部署或真機驗收。
- 下一步應在正式後端與頁面 error／empty 契約確認後，再決定是否由 App 組裝層啟用 strict；大型靜態資料拆分仍需內容等價驗證。

以下是上一批快照，不可替代目前驗證狀態。

## 目前快照（2026-11-19，後端 API 傳輸層重構）

- 分支 `redesign/home-responsive-carousel`，基準 Commit `09ce31a`。本批將共用 Token 介面移至 `lib/data/common`，讓 `PreambleState` 直接依賴該介面，並讓七個領域服務共用 URI、headers 與錯誤訊息解析；保留原端點、模型、領域例外型別、mock 回退政策與前端展示。
- 共用傳輸物件不擁有 HTTP client；上一批的 client 所有權規則繼續由服務負責。小法助原型別 import 路徑保留 re-export。
- 全專案靜態分析無問題；聚焦測試與文件 repository 測試合計 33 項通過。完整結果與未測事項以[本批日期化驗收](BACKEND_API_TRANSPORT_ACCEPTANCE_2026-11-19.md)為準。本批 Commit SHA 以 `git log -1` 查核；尚未 push、建立 PR、執行遠端 CI、部署或真機驗收。
- 下一步先查本批實際 Commit 與測試，再定義各 repository 的資料來源回退契約；大型靜態資料拆分仍須資料等價驗證。

以下為上一批快照；測試與部署狀態不可代替本批驗證。

## 目前快照（2026-11-19，後端資源生命週期整理）

- 工作分支：`redesign/home-responsive-carousel`；開工基準 HEAD：`0e76821`。本批原始工作區已有上一輪未提交的認證修補、回歸測試與後端盤點文件，這些變更一併納入本批 Commit。
- 修改範圍：`AuthHttpClient` 的並發 401 刷新與不可重送請求保護；主要 API service、文件 repository 與組合型 repository 的資源所有權。只釋放自身建立的依賴，並補上搜尋 repository 自建案件 repository 的釋放。
- UI、前端展示、圖片與 Prototype 均未修改。沒有後端 migration、正式資料寫入或部署。
- 驗證：全專案 `dart analyze` 無問題；後端聚焦測試 13 項通過；全量 Flutter 304 項通過、8 項既有畫面／案件頁 widget 測例失敗。完整證據見 `docs/IMPLEMENTATION_STATUS.md` 與 `docs/BACKEND_ARCHITECTURE_AUDIT_2026-11-19.md`，不得把全量測試記為通過。
- 本批已以單一英文標題、中英雙語內文的 Commit 提交；實際 SHA 以 `git log -1` 查核。沒有 push 或建立 PR；遠端 CI、正式後端 JWT、手機與 production 均未驗收。

## 下次接手

1. 先確認本批 Commit、工作區、最新 CI；後端聚焦 13 項已通過，全量測試 8 項失敗需按 `docs/IMPLEMENTATION_STATUS.md` 核對。修 UI 測例前先確認使用者最新的 UI 修改範圍。
2. 釐清各 repository 在「未設定後端」「遠端空結果」「請求失敗」時的 mock 回退規則。這可能影響展示內容，需保留既有 UI 視覺並建立明確資料來源契約。
3. 整理各 API service 重複的 base URL、headers、錯誤解析，在契約測試保護下逐一遷移。
4. 拆分大型靜態案件資料檔前先建立內容等價驗證，避免無意改動案件資訊。

詳細問題清單與判斷依據見 [後端架構盤點](BACKEND_ARCHITECTURE_AUDIT_2026-11-19.md)。
