# LawApp 參賽計劃書導讀

這份資料夾是給 Gemini 撰寫 LawApp 參賽計劃書用的精簡專案脈絡。請優先閱讀本文件，再閱讀 `README.md`、`docs/` 與 `lib/`。

## 一句話定位

LawApp 是面向台灣一般民眾的法律知識與案件學習 App，目標是把艱澀法律資訊轉換成可理解、可查詢、可練習、可收藏追蹤的日常法律學習工具。

## 目標使用者

- 一般民眾：遇到租屋、車禍、消費、職場、隱私等日常法律問題時，需要快速理解風險與下一步。
- 法律初學者：想用案例、法條、測驗與筆記建立法律知識。
- 關心公共議題者：想閱讀重大案件、了解爭點、比較不同立場。
- 需要自我整理資料的人：想收藏案件、做學習筆記、追蹤議題。

## 核心問題

台灣法律資訊常見痛點：

1. 法條與判決語言艱澀，非法律背景的人很難理解。
2. 日常法律問題分散在新聞、論壇、政府網站與判決系統中，搜尋成本高。
3. 使用者常不知道問題該先看法條、案例、證據還是下一步行動。
4. 法律學習缺少持續性，讀完資料後難以複習、練習與累積紀錄。

LawApp 的方向是用「白話理解 + 情境學習 + 案件探索 + 個人紀錄」降低法律理解門檻。

## 主要功能模組

### 1. 首頁與生活法律入口

相關路徑：

- `lib/pages/home/`
- `lib/components/home/v2/`
- `lib/pages/home/subpages/`

功能重點：

- 首頁以卡片與子頁串接法律學習、案件、生活提醒與搜尋入口。
- 生活避坑筆記整理常見日常法律情境，例如租屋、養狗、網購、拍照隱私、交通。
- 使用者可以從生活問題進入小法助提問或法規資料庫。

### 2. 學習中心

相關路徑：

- `lib/pages/learning/`
- `lib/data/mock_data/learning/`
- `lib/data/learning/`

功能重點：

- 提供法律主題課程、文章詳情、測驗、筆記、成就室。
- 主題包含租屋、車禍、職場、消費、個資隱私等。
- 使用者可答題、記錄學習歷史、收藏筆記、累積成就徽章。

### 3. 小法助 / AI 法律輔助入口

相關路徑：

- `lib/pages/learning/law_assistant/`
- `lib/pages/learning/know_law_page.dart`

功能重點：

- 讓使用者用自然語言描述法律問題。
- 從首頁、生活筆記、案件頁等多處進入。
- 目前前端以流程與 UI prototype 為主，適合未來接上 RAG、法規資料庫或後端服務。

### 4. 案件時光機 / Case Time Machine

相關路徑：

- `lib/features/case_time_machine/`

功能重點：

- 以台灣重大或代表性案件為素材，提供案件資料館、卷宗詳情、時間線、爭點、法條、詞卡、討論室。
- `case_dossier_detail_page.dart` 是案件詳情核心頁。
- `case_netizen_chat_room_page.dart` 是案件討論室，包含投票、AI 摘要、觀點光譜與留言卡。
- `case_legal_vocabulary_page.dart` 以詞卡方式解釋判決中的法律概念。

### 5. 紀事 / Journal

相關路徑：

- `lib/pages/journal/`
- `lib/features/on_this_day/`

功能重點：

- 用「今日案件」、「大家都在討論」、「典藏展示」等方式呈現法律與社會議題。
- 讓法律內容不只是工具頁，而是可持續探索的知識流。

### 6. 追蹤與個人頁

相關路徑：

- `lib/pages/following/`
- `lib/pages/profile/`
- `lib/app/app_state.dart`

功能重點：

- 使用者可追蹤案件、保存學習紀錄、查看個人狀態。
- `AppState` 管理部分前端狀態，例如追蹤、筆記、學習紀錄。

## 技術架構摘要

- Flutter / Dart：跨平台 App 前端。
- `flutter_screenutil`：響應式尺寸。
- `flutter_svg`：大量自訂 SVG icon。
- `sqflite`：本地資料庫能力。
- `shared_preferences`：本地狀態保存。
- `url_launcher`：外部法規或資料來源連結。
- 架構上多數功能仍以 mock data 與前端 prototype 為主，但已預留 repository/service 擴充位置。

請 Gemini 注意：本包排除了大型字型檔，`pubspec.yaml` 仍保留原始字型設定，這是為了讓模型理解正式 App 的字型策略，不代表此精簡包可直接 build。

## 產品亮點

1. 以台灣法律情境為核心，而不是通用法律 chatbot。
2. 同時包含生活法律、案件探索、法條查詢、學習測驗與個人紀錄。
3. UI 風格偏溫和、知識型、帶有手帳與資料館感，降低法律資訊的壓迫感。
4. 案件時光機把重大案件拆成時間線、法條、詞卡、觀點光譜，適合教育與公共討論。
5. 未來可接後端法規資料庫、判決資料庫、AI RAG、小法助風險提示。

## 可寫入參賽計劃書的方向

建議計劃書章節：

1. 專案名稱與一句話摘要
2. 問題背景：法律資訊艱澀、分散、缺少日常化學習入口
3. 目標族群：一般民眾、學生、公共議題關心者
4. 解決方案：LawApp 的六大模組
5. 使用者旅程：從生活問題、案件新聞或學習主題進入，完成理解、查詢、筆記、追蹤
6. 技術實作：Flutter 前端、mock data、repository/service 擴充、AI 輔助入口
7. 創新性：法律知識遊戲化、案件時光機、觀點光譜、白話詞卡
8. 社會影響：法律素養、公民教育、資訊可近性、降低諮詢前的理解成本
9. 未來規劃：接入正式法規/判決資料、AI RAG、個人化學習、TestFlight/上架
10. 風險與倫理：不取代律師、來源透明、提醒使用者尋求專業協助

## Gemini 輸出要求建議

請 Gemini 產出時使用台灣繁體中文，並以「參賽計劃書」語氣撰寫。
不要把 LawApp 描述成已經提供正式法律意見或律師服務；應描述為法律知識、學習與初步問題整理工具。
若提到 AI，請強調輔助、整理、導覽與風險提醒，而非直接給出最終法律判斷。

## 建議 Gemini 優先閱讀檔案

- `README.md`
- `docs/mvp_roadmap.md`
- `docs/data_sources_and_legal_notice.md`
- `lib/main.dart`
- `lib/app/app_state.dart`
- `lib/pages/home/home_page.dart`
- `lib/pages/learning/know_law_page.dart`
- `lib/features/case_time_machine/pages/case_dossier_detail_page.dart`
- `lib/features/case_time_machine/pages/case_netizen_chat_room_page.dart`
- `lib/pages/journal/journal_page.dart`
- `lib/pages/profile/profile_page.dart`
- `lib/data/mock_data/learning/learning_mock_data.dart`
- `lib/features/case_time_machine/data/case_time_machine_mock_data.dart`
