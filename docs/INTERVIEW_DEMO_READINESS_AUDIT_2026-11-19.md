# Preamble 特殊選才面試展示盤點與風險紀錄（2026-11-19）

## 盤點目的與背景

因應 2026-11-20（13:00–13:20）國立中山大學社會學系特殊選才面試現場展示需求，於 `redesign/home-responsive-carousel` 分支（基準 Commit `b8dc013`）檢視 `docs/` 交接歷程、後端設定、`lib/` 頁面流程與測試現況。本紀錄僅反映本機原始碼與本機測試執行結果，不包含實機連線正式 Supabase 或真機 UI 操作驗收。

## 本機檢查結果

1. **靜態分析**：執行 `/Users/babychen/Documents/flutter/bin/cache/dart-sdk/bin/dart analyze`，結果為 `No issues found!`。
2. **全量 Flutter 測試**：執行 `/Users/babychen/Documents/flutter/bin/flutter test --no-pub --reporter compact test`，結果為 **324 項通過、8 項失敗**。
   - 8 項失敗與既有清單一致，分布於：
     - `test/home_v2_bento_cards_responsive_test.dart`（1 項：Quick Ask input reachable 斷言）
     - `test/widget_test.dart`（5 項：`App smoke test`、小螢幕大字級、側邊參考頁、Journal 版面、`Case time machine` 找不到「事件與訴訟脈絡」）
     - `test/phase22_case_library_wikipedia_portals_test.dart`（1 項：`pumpAndSettle` 逾時）
     - `test/phase23_case_library_wikipedia_reading_experience_test.dart`（1 項：「體驗法官裁判心證」文字斷言）
3. **沙盒網路檢查**：於本機沙盒執行 `curl` 檢查 `lib/config/supabase_config.dart` 所設定之 Supabase 專案 URL，因沙盒無 DNS 解析而回傳 `Could not resolve host`（`HTTP:000`），**尚未在本機外網環境驗證遠端資料表內容**。

## 現場展示成熟度與風險分析

### 1. 最大現場風險：正式來源契約與面試場地網路依賴
- `lib/config/supabase_config.dart` 目前已寫入非空的 `supabaseUrl` 與 `supabaseAnonKey`，因此 `SupabaseCaseService.isConfigured`、`SupabaseLifeTipsService.isConfigured` 與 `SupabaseLearningService.isConfigured` 皆為 `true`。
- 依據 `06e1ef6`、`7cd6f58`、`b8dc013` 建立的正式來源契約（`DataFallbackPolicy.liveWhenConfigured` 與案件庫雲端正文契約）：
  - 案件庫入口（`CaseLibraryEntryPage`）、案件詳情（`CaseDossierDetailPage`）、生活法律小筆記（`HomeLifeLegalTipsPage`）與每日精選專題（`KnowLawPage`）在已設定 Supabase 時，**若遠端回傳空陣列或發生網路失敗，不會退回內建種子資料或舊 SQLite 舊正文**，而是顯示空狀態或錯誤狀態。
  - 若面試教室 Wi-Fi 不穩、有 Captive Portal 或 Supabase 專案無資料，現場點擊上述頁面將無法看到展示內容。務必於面試前在實機（iPhone）以實際網路環境逐頁點測。

### 2. 離線／無自建後端仍可穩定展示的核心流程
- **AI 問診／小法助（`LawAssistantRepository`）**：在未設定 `PREAMBLE_API_BASE_URL` 時（預設狀態），會於本機執行 `PiiDataMasker`（個資去識別化遮罩）、`LegalSyllogismEngine`（法學三段論結構化回覆）與 `TypingSimulator`（打字機串流體驗），不依賴外部 AI API 即可完成完整互動展示。
- **我的 Preamble（`ProfilePage`）**：資料來源說明、隱私權政策、服務條款與法律免責聲明等靜態／本地狀態頁皆可離線開啟，且能直接回應「資料來源、隱私與 AI 責任邊界」等社會學／倫理提問。

### 3. 較不建議主動點擊或需避開的角落
- **舊版語音輸入按鈕**：`lib/pages/learning/law_assistant/legacy/law_assistant_search_page.dart` 的語音輸入目前顯示「語音輸入開發中；目前請先用文字描述問題。」。
- **外部瀏覽器跳轉**：法規或分享頁的外部連結會離開 App，現場演示建議以 App 內原生頁面為主。
- **系統整合與實驗室（`AppleEcosystemDemoPage`）**：偏重 iOS Widget／Spotlight 開發測試用途，未預先設定桌面小工具時不建議作為主軸展示。

## 已完成之面試前低風險優化（本機未 commit）

依使用者指示，於 `b8dc013` 基礎上完成以下三項低風險調整：
1. **App 內建瀏覽器開啟網頁**：將 [statute_database_page.dart](file:///Users/babychen/Dropbox/Baby%20Mac/python/lawapp/lib/pages/learning/statute_database_page.dart)、[share_sheet.dart](file:///Users/babychen/Dropbox/Baby%20Mac/python/lawapp/lib/components/shared/share_sheet.dart)、[home_official_feed_pages.dart](file:///Users/babychen/Dropbox/Baby%20Mac/python/lawapp/lib/pages/home/subpages/home_official_feed_pages.dart) 與 [global_search_page.dart](file:///Users/babychen/Dropbox/Baby%20Mac/python/lawapp/lib/pages/search/global_search_page.dart) 的網頁 `launchUrl` 由 `LaunchMode.externalApplication` 改為 `LaunchMode.inAppBrowserView`（iOS 以原生 `SFSafariViewController` 留在 App 內開啟，可隨時返回或再切至外部 Safari）；行事曆與提醒事項之系統 scheme 維持不變。
2. **隱藏「系統整合與實驗室」入口**：將 [profile_page.dart](file:///Users/babychen/Dropbox/Baby%20Mac/python/lawapp/lib/pages/profile/profile_page.dart) 中通往 `AppleEcosystemDemoPage` 的選單項目與未使用 import 暫時註解隱藏，保留原實驗室頁面檔案待日後 MAIC 計畫重新啟用。
3. **隱藏舊版語音輸入按鈕**：將 [law_assistant_prototype_widgets.dart](file:///Users/babychen/Dropbox/Baby%20Mac/python/lawapp/lib/pages/learning/law_assistant/legacy/law_assistant_prototype_widgets.dart) 的麥克風按鈕暫時註解隱藏，避免展示時觸發「語音輸入開發中」提示。
4. **案件詳情頁 6 大思辨功能檢查**：確認 [case_dossier_detail_page.dart](file:///Users/babychen/Dropbox/Baby%20Mac/python/lawapp/lib/features/case_library/pages/case_dossier_detail_page.dart) 的 6 項思辨工具（法律詞卡、觀點光譜、如果你是法官、虛擬詰問室、社會效應圖譜、意見塗鴉牆）已有獨立案件 profile；執行 `test/phase24_case_library_independent_deliberation_test.dart` 14 項全數通過；`dart analyze` 為 `No issues found!`，搜尋／後端／Supabase 契約聚焦測試 22 項全數通過。

（上述三項已於 Commit `b1e030f` 提交本機分支。）

## 後續新增：小法助回覆 UI 減法與 Gemini Edge Function 串接

1. **移除多餘外框與重複前綴**：於 [law_assistant_chat_page.dart](file:///Users/babychen/Dropbox/Baby%20Mac/python/lawapp/lib/pages/learning/law_assistant/law_assistant_chat_page.dart) 將 AI 回覆氣泡改為無框線柔和底色容器，並於 `_AssistantAnswerBlock` 去除重複的 `【...】：` 前綴與放大行距，提升閱讀感。
2. **洞察卡片預設收合**：於 [law_assistant_insight_card.dart](file:///Users/babychen/Dropbox/Baby%20Mac/python/lawapp/lib/components/assistant/law_assistant_insight_card.dart) 新增 `initiallyExpanded` 參數（預設 `true` 保留既有元件測試契約），於對話頁傳入 `false` 預設收合「攻防洞察與雙重編碼指引」，避免多層框線同時堆疊，需要時再點開。
3. **Supabase 專案喚醒與資料驗證**：透過 Supabase MCP 將 `LawApp`（`vtpdncwijhfjtegnnwkz`）由 `INACTIVE` 喚醒至 `ACTIVE_HEALTHY`，實測確認 `cases`（10,200 筆）、`life_legal_tips`（500 筆）與 `learning_articles`（10,000 筆）皆有資料。
4. **部署 `law-assistant` Edge Function 與安全串接**：已部署 Supabase Edge Function `law-assistant`（`verify_jwt: false`）呼叫 Gemini API，並由使用者於 Supabase Dashboard 安全設定 `GEMINI_API_KEY` Secret（不寫入前端或 Git）。[law_assistant_repository.dart](file:///Users/babychen/Dropbox/Baby%20Mac/python/lawapp/lib/data/law_assistant/law_assistant_repository.dart) 優先呼叫此雲端介面，離線或逾時時自動退回本機三段論引擎。
5. **驗證**：`dart analyze` 無問題；`test/law_assistant_test.dart`、`test/phase14_progressive_flow_test.dart`、`test/backend_resource_ownership_test.dart` 共 11 項全數通過；尚待實機編譯後做終端對終端連線實測。

## 建議後續追蹤
- 面試前先於實機確認 Supabase 連線與資料表狀態；若需無網路環境的純離線展示保險，需另外明確決定是否切換為未設定來源／demo 模式（注意不得違反既有正式來源契約紀錄，應於驗證後清楚標註）。
