# LawApp 專案盤點

## 目前專案架構

- `lib/main.dart`：五分頁 shell、主題、深色模式與底部導覽。
- `lib/app/app_state.dart`：會員層級、demo auth、本機收藏、案件筆記、AI 額度與權限 getter。
- `lib/pages/home/`：首頁與子頁入口，保留柔和清新風格。
- `lib/pages/learning/`：學習頁、小法助、法規資料庫、測驗與學習文章。
- `lib/pages/search/`：全站搜尋入口，目前導向小法助、法規與記事。
- `lib/pages/journal/`：記事頁、案件時光機、那年今日、案件資料館與詳情頁。
- `lib/pages/following/`：追蹤頁 MVP，可顯示追蹤案件、法條與主題。
- `lib/pages/profile/`：會員與 demo 權限入口。
- `lib/data/`：API services、repositories、formal models 與 mock data。
- `lib/components/shared/`：共用 loading/error/empty/disclaimer/citations/permission/backend banner。
- `test/`：既有 widget/service 測試與 MVP foundation 測試。

## 已完成功能

- guest / member / subscriber 權限與 demo 登入。
- 深色模式、本機收藏與案件筆記草稿。
- 小法助 API service 與 repository mock fallback。
- 法規資料庫 service、repository、搜尋與詳情來源資訊。
- 案件資料館可篩選年代、進卷宗詳情。
- Case/Search/Following/Document/Official feed repository 骨架。
- 法律免責聲明與來源引用共用元件。

## 尚未完成功能

- 正式 auth、token refresh、會員同步與訂閱驗證。
- 真實 AI RAG 後端、conversation persistence、quota server-side enforcement。
- 正式案件資料庫與裁判書 API 同步。
- 全站搜尋後端索引與結果詳情路由。
- 文件後端 `/documents/drafts` 與 export。
- 推播通知、追蹤同步、離線快取策略。

## Mock Data 與正式資料差異

- Mock data：用於 UI demo、測試與 backend 未設定狀態，會標示 `isMock` 或顯示 banner。
- 正式資料：應由後端提供 id、updatedAt、sourceLinks、citations、privacyLevel 與 audit trail。
- 法規資料：目前可直接讀 MOJ 公開 ZIP JSON；正式商用建議後端同步與快取。
- 案件資料：目前為示範整理，不可假裝為完整裁判書資料庫。

## 後端尚未串接處

- `auth/*`
- `users/me`
- `law-assistant/*`
- `statutes/*`
- `cases/*`
- `search`
- `following/*`
- `documents/drafts`
- `official-feeds/*`
- `quota/*`

## 風險項目

- 法律內容必須持續顯示免責聲明，避免被理解為正式法律意見。
- 新聞與外部內容不能複製全文，需以摘要、標題與來源連結為主。
- Flutter 端不得保存 AI provider key。
- 大型 assets 與 `.png.png` 檔名需在上架前整理。
- 目前工作區有多個未提交變更，合併前需再次跑完整 `flutter analyze` 與 `flutter test`。

## 下一階段 Roadmap

- Phase 1：完成 MVP foundation、mock/backend 切換與核心測試。
- Phase 2：接正式後端、法規同步與 AI RAG。
- Phase 3：會員/訂閱/額度與追蹤同步。
- Phase 4：上架 QA、效能、授權、隱私與法務審查。
- Phase 5：正式營運、資料維護與客服流程。

