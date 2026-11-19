# lawapp 實作狀態

更新日期：2026-11-19。狀態只代表本機 `lawapp`，不代表遠端部署。

## 本批：即時新聞每日熱度曲線與 TestFlight 打包（基準 `35b004d`）

| 項目 | 狀態 | 依據／限制 |
| --- | --- | --- |
| `trending-topics` v4 | 已部署 (`ACTIVE`) | 新增近 7 天每日報導量統計（`trendPoints`）供內頁趨勢圖繪製。 |
| `InteractiveTrendChart` 即時曲線 | 本機已改 | `DiscussionDetailPage` 優先以即時每日報導量繪製互動折線圖，並保留社群意向問答、小法助透視、關聯卷宗與新聞來源。 |
| 靜態分析與紀事測試 | 通過 | `dart analyze` 無問題；`test/phase20_journal_upgrades_test.dart` 4 項通過。 |

以下為上一批狀態（紀事頁內頁即時新聞與去 mock 化）。

## 本批：紀事頁內頁即時新聞與去 mock 化（基準 `a9b8bab`）

| 項目 | 狀態 | 依據／限制 |
| --- | --- | --- |
| `trending-topics` v3 | 已部署 (`ACTIVE`) | 過濾台灣在地法制新聞（報導者、中央社、自由財經等），回傳篇數與前 6 則連結。 |
| `DiscussionDetailPage` 去 mock 化 | 本機已改 | 移除假曲線／假投票／假留言，改為即時新聞列表（App 內建瀏覽器開啟）＋小法助透視＋關聯歷史卷宗。 |
| 靜態分析與紀事測試 | 通過 | `dart analyze` 無問題；`test/phase20_journal_upgrades_test.dart` 4 項通過。 |

以下為上一批狀態（紀事頁即時新聞熱度榜串接）。

## 本批：紀事頁即時新聞熱度榜串接（基準 `a9ce622`，本機未 commit）

| 項目 | 狀態 | 依據／限制 |
| --- | --- | --- |
| `trending-topics` Edge Function | 已部署並實測 (`ACTIVE`) | Supabase Edge Function 即時彙整 Google News 台灣 RSS 報導篇數；`curl` 實測回傳 200（30–49 則不等）。 |
| 紀事頁 `DiscussingNowSection` | 本機已改 | 優先顯示雲端即時新聞量與動態排序；離線或逾時自動維持誠實「焦點策展」標示。 |
| 靜態分析與紀事測試 | 通過 | `dart analyze` 無問題；`test/phase20_journal_upgrades_test.dart` 4 項全數通過。 |

以下為上一批狀態（紀事頁討論策展誠實標示）。

## 本批：紀事頁討論策展誠實標示（基準 `a9ce622`，本機未 commit）

| 項目 | 狀態 | 依據／限制 |
| --- | --- | --- |
| 紀事頁熱度榜改為策展標示 | 本機已改 | `discussing_now_section.dart` 與 `discussion_detail_page.dart` 移除靜態假分數／漲跌幅，改為「焦點策展」「示範策展」標示。 |
| 靜態分析與紀事測試 | 驗證中／見輸出 | `dart analyze` 與 `test/phase20_journal_upgrades_test.dart`。 |

以下為上一批狀態（Supabase 喚醒與小法助 Gemini Edge Function 串接）。

## 本批：Supabase 喚醒與小法助 Gemini Edge Function 串接（基準 `b1e030f`，本機未 commit）

| 項目 | 狀態 | 依據／限制 |
| --- | --- | --- |
| Supabase `LawApp` 專案 | 已喚醒 (`ACTIVE_HEALTHY`) | `restore_project` 成功；`execute_sql` 驗證 `cases` 10,200 筆、`life_legal_tips` 500 筆、`learning_articles` 10,000 筆。 |
| `law-assistant` Edge Function | 已部署 (`ACTIVE`) | 透過 Supabase MCP 部署，呼叫 Gemini；須由使用者於 Supabase Dashboard 填入 `GEMINI_API_KEY` Secret。 |
| Flutter 小法助串接 | 本機已改 | `LawAssistantRepository` 優先呼叫 Supabase Edge Function，失敗／離線自動退回 `LegalSyllogismEngine`；未將任何 Key 寫入程式碼。 |
| 專案靜態分析與聚焦測試 | 通過 | `dart analyze` 無問題；`law_assistant_test.dart`、`phase14_progressive_flow_test.dart`、`backend_resource_ownership_test.dart` 通過（詳見輸出）。 |

以下為上一批狀態（小法助回覆 UI 減法）。

## 本批：小法助回覆 UI 減法整理（基準 `b1e030f`，本機未 commit）

| 項目 | 狀態 | 依據／限制 |
| --- | --- | --- |
| 小法助回覆視覺減法 | 本機已改 | `law_assistant_chat_page.dart` 移除 AI 氣泡外框與重複 `【...】：` 前綴；`law_assistant_insight_card.dart` 支援 `initiallyExpanded`（對話頁傳入 `false` 預設收合）。 |
| 專案靜態分析 | 通過 | `/Users/babychen/Documents/flutter/bin/cache/dart-sdk/bin/dart analyze`：`No issues found!`。 |
| 小法助聚焦測試 | 9 項通過 | `test/phase14_progressive_flow_test.dart`、`test/law_assistant_test.dart` 全數通過。 |

以下為上一批狀態（已於 `b1e030f` 提交）。

## 本批：面試展示盤點與前夜低風險優化（基準 `b8dc013`，本機未 commit）

| 項目 | 狀態 | 依據／限制 |
| --- | --- | --- |
| App 內建瀏覽器開啟 | 本機已改 | `statute_database_page.dart`、`share_sheet.dart`、`home_official_feed_pages.dart`、`global_search_page.dart` 改用 `LaunchMode.inAppBrowserView`。 |
| 實驗室／語音按鈕隱藏 | 本機已改 | `profile_page.dart` 隱藏「系統整合與實驗室」入口；`law_assistant_prototype_widgets.dart` 隱藏語音按鈕，原檔與類別保留。 |
| 案件詳情 6 大思辨功能 | 聚焦測試通過 | `test/phase24_case_library_independent_deliberation_test.dart` 14 項通過（涵蓋蘇建和案、RCA 案、湯英伸案、跨國同婚案、外役監案等獨立 profile）。 |
| 專案靜態分析 | 通過 | `/Users/babychen/Documents/flutter/bin/cache/dart-sdk/bin/dart analyze`：`No issues found!`。 |
| 聚焦回歸測試 | 22 項通過 | `phase21_global_search_upgrades_test.dart`、`backend_api_services_test.dart`、`supabase_source_contract_test.dart` 全數通過。 |
| 全量測試／實機／Git | 未重跑／未編譯 | 修改前全量為 324 通過、8 失敗；本機尚未 commit、push 或編譯至 iPhone 實機驗收。 |

以下為上一批歷史狀態；資料契約細節請見下方及各日期化驗收文件。

## 本批：案件庫正式內容與快取（基準 `7cd6f58`）

| 項目 | 狀態 | 依據／限制 |
| --- | --- | --- |
| 正式內容來源 | 本機已修 | 不再初始化種子正文為正式快取；完整詳情由雲端確認，SQLite 只合併收藏／追蹤標記。 |
| 推薦與空結果 | 本機已修 | 正式清單建立推薦快照；正式空清單清除舊推薦；較慢的舊請求不能覆蓋新快照；案件入口先取雲端再產生 Hero。 |
| 離線展示 | 保留 | 未設定來源仍可使用本機種子；遺失 ID 不再被第一筆無關案件替代。 |
| 專案靜態分析 | 通過 | `dart analyze`：`No issues found!`；見[案件庫日期化驗收](CASE_LIBRARY_LIVE_CACHE_ACCEPTANCE_2026-11-19.md)。 |
| 聚焦 Flutter 測試 | 28 項相異測例通過 | 來源、後端、案件快取及並發契約測試；最後新增的測例已單獨重跑，未再三檔合併重跑。 |
| 相關 widget 測試 | 8 項通過、1 項失敗 | 案件詳情整合測例的既有文字斷言失敗；尚未隔離基準 Commit。 |
| 遠端／部署 | 未執行 | 沒有正式 Supabase、CI、push、PR、真機或部署驗收。 |

以下為上一批歷史狀態；本批結果請以上方及日期化驗收為準。

## 本批：正式來源空結果與錯誤（基準 `06e1ef6`）

| 項目 | 狀態 | 依據／限制 |
| --- | --- | --- |
| 正式來源空清單 | 本機已修 | 案件、法規、官方消息、全站搜尋、學習文章、生活筆記、每日專題、案件庫分頁照實回空；生活筆記、學堂及案件館不再將固定內容加回遠端清單。 |
| 正式來源失敗 | 本機已修 | 錯誤向上傳遞；生活筆記頁不再於錯誤時顯示示範卡。 |
| 未設定來源／明確 demo | 保留既有流程 | 未設定來源可展示本機內容；四個共用 repository 只有明確指定 `demo` 才允許正式空／錯誤回退。 |
| 每日專題 ID | 本機已修 | 從雲端存在的 ID 分頁取得後按日期抽選，不再猜 1–1000。 |
| 全專案靜態分析 | 通過 | `dart analyze`：`No issues found!`。 |
| 聚焦 Flutter 測試 | 34 項通過 | 來源空結果、HTTP 失敗、後端 API、搜尋與首頁 feed；詳見 [日期化驗收](LIVE_SOURCE_EMPTY_RESULTS_ACCEPTANCE_2026-11-19.md)。 |
| 相關 widget 測試 | 6 項通過、1 項既有失敗 | 學堂與案件館 portal 測例通過；案件入口頁 `pumpAndSettle timed out`，見日期化驗收。 |
| 全量 UI／正式來源／部署 | 未執行 | 上批全量仍為 304 通過、8 失敗；本批沒有正式 Supabase、CI、push 或部署。 |

以下為上一批歷史狀態；本批預設已非 demo。

## 本批：資料來源回退契約（基準 `501fe97`）

| 項目 | 狀態 | 依據／限制 |
| --- | --- | --- |
| 預設展示模式 | 本機已實作 | 案件、法規、官方消息與搜尋保留原有回退；未改 App 入口或 UI。 |
| 明確 strict 模式 | 本機已實作，尚未於正式 App 啟用 | 未設定報錯、遠端空清單照實回空、遠端失敗傳出原始錯誤。 |
| 全專案靜態分析 | 通過 | `dart analyze`：`No issues found!`。 |
| 聚焦 Flutter 測試 | 30 項通過 | 涵蓋四個 repository 的三種來源結果、後端 API、基礎流程與搜尋；詳見日期化驗收。 |
| 全量 UI 測試 | 本批未重跑 | 上一批 304 項通過、8 項失敗，不能宣稱全量通過。 |
| Git／遠端／部署 | 本批已 Commit；遠端未執行 | 基準 `501fe97`；最新 SHA 以 `git log -1` 查核。未 push、未建立 PR、未部署。 |

以下為上一批狀態；本批結果請以上方及日期化驗收為準。

## 本批：共用 API 傳輸層（基準 `09ce31a`）

| 項目 | 狀態 | 依據／限制 |
| --- | --- | --- |
| Token 介面與七個 API 服務 | 本機已重構 | `AuthTokenProvider` 位於 `lib/data/common`；共用 URI、headers 與錯誤訊息解析；保留各服務的端點及例外型別。 |
| UI 與前端展示 | 本批未修改 | 只改 `lib/data`、`lib/app/app_state.dart` 的 import、測試與文件。 |
| 全專案靜態分析 | 通過 | `dart analyze`，`No issues found!`。 |
| 聚焦 Flutter 測試 | 33 項通過 | API 契約、資源所有權、共用傳輸層、小法助、基礎流程與文件 repository；結果見 `docs/BACKEND_API_TRANSPORT_ACCEPTANCE_2026-11-19.md`。 |
| Git／遠端／部署 | 本批已 Commit；遠端未執行 | 基準 `09ce31a`，最新 SHA 以 `git log -1` 查核；未 push、未建立 PR、未部署。 |

以下為上一批狀態；本批測試請看上方及日期化驗收。

| 項目 | 狀態 | 依據／限制 |
| --- | --- | --- |
| UI 與前端展示 | 本批未修改 | 修改限於 `lib/data`、後端測試與文件。 |
| 並發 401 Token 刷新 | 本機已修 | 共用單次刷新 Future；獨立 Dart smoke check 已通過。 |
| 不可重送請求 | 本機已修 | 串流請求保留 401，不嘗試重播；獨立 Dart smoke check 已通過。 |
| HTTP client 所有權 | 本機已修、聚焦測試通過 | 自建資源由建立者釋放，外部注入由呼叫端管理。 |
| 全專案靜態分析 | 通過 | `/Users/babychen/Documents/flutter/bin/cache/dart-sdk/bin/dart analyze`，`No issues found!`。 |
| Flutter 後端回歸測試 | 13 項通過 | `flutter test --no-pub --reporter expanded test/backend_api_services_test.dart test/backend_resource_ownership_test.dart`。首輪既有 401 測例曾失敗，已修正並重跑通過。 |
| Flutter 全量測試 | 304 項通過、8 項失敗 | `flutter test --no-pub --reporter expanded test` 完整執行。失敗集中在既有首頁／記事／案件時光機／Wikipedia 頁面的 widget 斷言與 `pumpAndSettle`；本批未修改上述 UI 檔。不能宣稱全量測試通過。 |
| Git Commit | 本批已提交 | 使用英文標題與中英雙語詳細內文；最新 SHA 以 `git log -1` 查核。尚未 push 或建立 PR。 |
| 真實後端／JWT、手機、CI、部署 | 未執行 | 本批沒有遠端環境操作。 |

下一優先事項：資料來源回退契約、共用 HTTP 傳輸層、大型靜態資料的等價拆分。詳細規劃見 `docs/AI_HANDOVER.md` 與 `docs/BACKEND_ARCHITECTURE_AUDIT_2026-11-19.md`。
