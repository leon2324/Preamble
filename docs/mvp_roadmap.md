# 緒言 Preamble MVP Roadmap

## Phase 1：可用 MVP

- 完成 user/auth/app state 權限集中管理。
- 完成共用 loading、error、empty、disclaimer、citations 與 permission gate。
- 完成 AI、法規、案件、搜尋、追蹤、文件、官方資料 repository mock/backend 切換。
- 補 model、repository 與核心 widget tests。

## Phase 2：真實資料與後端

- 串接 auth、user profile、quota、law assistant conversations。
- 後端同步全國法規資料庫與司法院裁判書資料。
- 建立 RAG pipeline、citation formatter 與資料版本紀錄。
- 搜尋改由後端索引回傳混合結果。

## Phase 3：會員與訂閱

- 正式登入、訂閱驗證、額度管理與付款狀態。
- 收藏、筆記、追蹤、最近搜尋跨裝置同步。
- 訂閱者進階文件產生與完整卷宗權限。

## Phase 4：上架與測試

- 全站小螢幕、大字級與深色模式 QA。
- asset 壓縮、字體授權、隱私權政策與服務條款。
- `flutter analyze`、`flutter test`、手動 exploratory QA。
- iOS/Android store metadata、截圖與審核文案。

## Phase 5：正式營運

- 資料更新排程、內容審稿、客服與錯誤回報流程。
- 法務與資安稽核。
- 使用者行為分析、搜尋品質與 AI 回答品質評估。
- 持續擴充主題、案件資料館與文件模板。

