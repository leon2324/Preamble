# 緒言 Preamble 全面審查報告
> 產品經理 × UX 審查員 × Flutter 架構審查員
> 審查日期：2026-06-21

---

## 一、30 秒總評

### 最大問題
**功能廣度已超過第一版 App 的合理容量 3 倍以上。** 你在一個 App 裡同時在做：法律新聞平台、案件資料庫、法律百科、AI 助理、模擬法庭遊戲、法律歷史探索、手帳筆記、書狀產生器，這是 8 個不同的 Product 方向。

### 核心定位是否清楚？
**不清楚。** 使用者第一次打開 App，在 10 秒內看到的是：Bento 首頁 + 5 個意義不明確的底部導航（首頁、學習、小法助、記事、我的）。「記事」這個名稱讓人無法理解裡面有什麼。「學習」包含 3 個子分頁 + 工具箱 + 筆記，等同把 3 個 App 塞進一個 Tab。

### 第一版是否已接近完整？
**視覺接近完整，但產品結構還沒完整。** 你有很多漂亮的頁面，但使用者的核心流程（看案件→追蹤→更新動態）還沒形成一個順暢的閉環。

### 最大產品風險
使用者打開 App 後不知道這個 App 能為他們做什麼，直接離開。定位不清楚 = 留不住人 = 功能再多也沒用。

### 最大程式架構風險
`global_search_page.dart` 179KB、`following_page.dart` 94KB、`know_law_page.dart` 277KB、`case_dossier_detail_page.dart` 197KB。**你有 4 個超過 90KB 的單一 `.dart` 檔案。** 這是維護炸彈，任何改動都有副作用。

---

## 二、核心定位檢查

> **這個 App 應該被定義為：「讓普通人透過精選案件與法律故事，看懂社會、學到知識、追蹤更新的法律探索手帳。」**

### 哪些功能偏離了這個定位？

| 功能 | 是否符合定位 | 說明 |
|------|------------|------|
| 案件時光機（瀏覽 + 時間軸 + 卷宗） | ✅ 核心 | 這就是產品靈魂 |
| 歷史上的今天 | ✅ 核心 | 法律故事探索 |
| AI 法律助理 | ✅ 重要 | 實用工具，有連結感 |
| 追蹤案件/法規更新 | ✅ 核心 | 法律手帳的個人化 |
| 法律知識文章 | ✅ 核心 | 學習主線 |
| 觀點光譜 / 社會關係圖 | ⚠️ 第二版 | 很有趣，但第一版太複雜 |
| 網友討論模擬室 | ❌ 偏離 | 像社群 App，不是法律探索 |
| 模擬法庭 / 法官判案 / 證人詰問 | ⚠️ 可簡化 | 三個功能做同一件事，選一個 |
| 書狀產生器 | ⚠️ 第二版 | 工具 App 方向，不是故事探索 |
| 手帳筆記 + 封面編輯 | ⚠️ 第二版 | 很美但第一版非核心 |
| 成就展覽室 | ❌ 過早 | 內容不夠多時，成就系統是空殼 |
| 自訂底部導航順序 | ❌ 現在不需要 | 只有 5 個 tab 的 App 不需要讓使用者排序 |
| 底部導航動態排序邏輯 | ❌ 架構複雜度代價高 | `main.dart` 裡的 order mapping 邏輯讓 selectedIndex 與真實 index 脫鉤，造成 bug 溫床 |

---

## 三、頁面與功能審查

### 3.1 案例時光機模組（14 個頁面）

| 頁面 | 必要？ | 建議 |
|------|--------|------|
| `CaseTimeMachineEntryPage` | ✅ | 保留，這是入口 |
| `CaseLibraryHallPage` | ✅ | 保留，書架大廳 |
| `CaseLibraryHallSelectionPage` | ❌ | **合併進 CaseLibraryHallPage**。兩個頁面只是「選館」和「看館」，沒有必要分開 |
| `CaseDossierDetailPage` | ✅ | 保留，但 197KB 必須拆檔 |
| `CaseTimelineDetailPage` | ✅ | 保留，案件演進是核心 |
| `CaseOpinionSpectrumPage` | ⚠️ | 第二版。第一版先把它收進 CaseDossierDetailPage 的分頁 |
| `CaseSocialGraphPage` | ⚠️ | 第二版。同上 |
| `CaseOpinionBoardPage` | ❌ | **合併進 CaseNetizenChatRoomPage 或刪除其一**。兩個頁面都是「討論」 |
| `CaseNetizenChatRoomPage` | ⚠️ | 功能很酷，但定位模糊。如果是「模擬」就保留；如果是真正互動就刪掉 |
| `CaseWitnessCrossPage` | ⚠️ | 第二版，和模擬法庭重疊 |
| `CaseJudgePracticePage` | ⚠️ | 第二版，和模擬法庭重疊 |
| `CaseBookPreviewPage` | ✅ | 保留，書本美學是差異點 |
| `CaseTimeMachineSearchPage` | ❌ | **刪除**，讓全域搜尋（GlobalSearchPage）接管。兩個搜尋入口只會混淆使用者 |
| `CaseLegalVocabularyPage` | ✅ | 保留，但可收進 CaseDossierDetailPage 的分頁 |

**問題診斷：** CTM 模組有 6 個互動型子頁（觀點光譜、社關圖、觀點討論板、網友室、證人詰問、法官判案）。這是**把 6 個不同的「遊戲化功能」堆在同一個案件上**。第一版只需要 2 個：時間軸 + 觀點光譜。其他延後。

---

### 3.2 歷史上的今天模組（4 個頁面）

| 頁面 | 必要？ | 建議 |
|------|--------|------|
| `OnThisDayHomePage` | ✅ | 保留 |
| `OnThisDayListPage` | ✅ | 保留 |
| `OnThisDayDateDiscoveryPage` | ✅ | 保留，撥盤式日期是差異點 |
| `OnThisDayDetailPage` | ✅ | 保留 |

**此模組結構最乾淨。不需要大改。** 但入口要確保使用者容易找到（目前藏在「記事」裡的 card）。

---

### 3.3 學習模組（`KnowLawPage` 下）

**警告：`know_law_page.dart` 是 277KB 的單一檔案。這是整個專案最大的問題之一。**

| 頁面/功能 | 必要？ | 建議 |
|------|--------|------|
| 法學課堂（文章 + 推薦） | ✅ | 保留，是核心 |
| `LearningMockDetailPage` | ✅ | 保留，但 90KB 需拆 |
| `StatuteDatabasePage` | ✅ | 保留，但入口應更清楚 |
| `HomeMissionQuizPage` | ⚠️ | **和 `LearningQuizPage` 重複**，合併一個即可 |
| `LearningQuizPage` | ✅ | 保留一個即可 |
| `MockCourtChallenge` | ⚠️ | **和 CaseJudgePracticePage / CaseWitnessCrossPage 重複**。三個功能都是模擬法庭，選一個保留 |
| `LegalDocumentExportPage` | ❌ | **延後**。書狀產生器是工具 App 方向，第二版 |
| `AchievementRoom` | ❌ | **延後**。98KB 的成就展覽室，第一版不應是重點 |
| `NotebookCoverEditorPage` | ❌ | **延後**。手帳封面編輯是第二版功能 |
| 生活工具箱（Tab） | ⚠️ | 把工具收攏，不要有獨立工具 Tab，改成工具入口卡片 |

---

### 3.4 追蹤相關頁面

**這裡有嚴重的功能重複問題。**

| 頁面 | 問題 | 建議 |
|------|------|------|
| `FollowingPage` | 94KB，包含首頁/動態/追蹤/收藏/筆記/提問/草稿/設定，是一個「頁內 App」 | **拆分責任**：追蹤列表 + 收藏保留；筆記/提問/草稿移到「我的」 |
| `FollowedUpdatesPage` | 很小（9KB），只有更新動態 | **合併進 FollowingPage 的動態分頁** |
| `FollowingPage._FollowPage` enum | 有 13 種狀態，等於在一個 Widget 裡做了 13 個頁面 | 這是個 App-in-App 反模式，需要重構 |

---

### 3.5 首頁子頁面（`home_subpages.dart`）

`home_subpages.dart` 是 1745 行的單一檔案，包含：
- `OfficialFeedPage`
- `LifeLegalTipsPage`
- `HomeLearningTopicsPage`

**問題：** 首頁子頁面應該有獨立的路由/頁面，而不是全部塞在一個 `_subpages.dart` 裡。

---

### 3.6 Legacy 頁面

目前 legacy 頁面散落在：
- `lib/pages/home/legacy/home_page_legacy.dart`
- `lib/pages/journal/legacy/case_story_detail_page.dart`（43KB）
- `lib/pages/journal/legacy/journal_archive_page.dart`（28KB）
- `lib/pages/learning/law_assistant/legacy/law_assistant_search_page.dart`（50KB）
- `lib/pages/learning/law_assistant/legacy/law_assistant_prototype_widgets.dart`（38KB）
- `lib/pages/profile/legacy/about_me_page_legacy.dart`
- `lib/pages/tools/legacy/legal_tools_page.dart`（70KB）
- `lib/pages/trending/legacy/trend_page_legacy.dart`
- `lib/features/case_time_machine/legacy/`（7 個檔案）
- `lib/components/home/legacy/`（4 個檔案）

**問題：** Legacy 程式碼仍然被 live 程式碼 import。具體發現：
- `home_page.dart` 還在 import `home_discussion_section_legacy.dart`
- `home_v2_sections.dart` 也 import 了同一個 legacy 元件
- `following_page.dart` import 了 `legal_tools_page.dart`（legacy）

**Legacy 頁面的實際大小加總：** 至少 229KB 的廢棄程式碼仍在正式 import 鏈中。

---

## 四、首頁資訊架構審查

### 目前首頁有哪些區塊（從 `home_page.dart` 分析）：
1. `HomeV2HeroHeader` - 頂部 Header + 頭像
2. `HomeV2GreetingCard` - 問候卡
3. `HomeV2QuickAskSection` - 快速提問
4. `HomeV2WatchlistCard` - 追蹤清單
5. `HomeV2AchievementCard` - 成就卡
6. `HomeV2DailyCaseStoryCard` - 每日案件故事
7. `HomeV2ToolsDrawer` - 工具抽屜
8. `HomeV2LawDatabaseCard` - 法規資料庫
9. `HomeV2TopicBentoGrid` - 專題 Bento 格
10. `HomeV2NewsletterFocusCard` - 生活避坑筆記
11. `HomeV2SocialNewsSection` - 社會新聞 + 討論

**11 個區塊，其中有 3 個方向完全不同：成就、工具、新聞。**

### 1. 首頁必留區塊（最多 5 個）

| 區塊 | 為什麼留 |
|------|---------|
| HeroHeader | 品牌感與入口識別 |
| 今日案件故事 / 焦點案件卡 | 核心定位的第一印象 |
| 快速提問（AI 助理入口） | 使用者最可能的第一個行動 |
| 追蹤更新 / 關注動態 | 讓使用者有理由每天回來 |
| 法律知識專題 Bento | 引導使用者進入「學習」主線 |

### 2. 首頁可留但要簡化

| 區塊 | 建議 |
|------|------|
| 社會新聞 | 只放 2 則，加「看更多」連到記事頁 |
| 生活避坑筆記 | 縮為一張 highlight card |

### 3. 不適合放首頁

| 區塊 | 應該去哪裡 |
|------|-----------|
| 成就卡（HomeV2AchievementCard） | 移到「我的」頁面 |
| 工具抽屜（HomeV2ToolsDrawer） | 移到「學習」的工具分頁 |
| 法規資料庫 card | 移到「學習」或搜尋入口 |
| 問候卡（HomeV2GreetingCard） | 和 HeroHeader 合併 |

### 4. 建議首頁資訊順序

```
1. Header（品牌 + 使用者狀態）
2. 今日焦點案件卡（最大、最突出）
3. AI 快速提問入口
4. 你追蹤的最新動態（個人化）
5. 法律知識專題（Bento 格）
6. 近期社會新聞（2 則 + 連結）
```

### 5. 首頁一句話定位文案

**「每天五分鐘，看懂一個社會案件。」**

---

## 五、使用者流程審查

### 流程 1：看案件
**目前卡在哪裡：** 使用者要看案件，需要知道「記事」這個名字 → 裡面有「案例時光機」card → 進入 `CaseTimeMachineEntryPage` → 再進 `CaseLibraryHallPage`。**3 層才到案件，且每一層的名字都不直覺。**

**建議：** 首頁「今日焦點案件卡」直接連到 `CaseDossierDetailPage`。記事 Tab 改名為「案件」。

---

### 流程 2：搜尋案件
**目前卡在哪裡：** 有 3 個搜尋入口：`GlobalSearchPage`（底部導航「小法助」）、`CaseTimeMachineSearchPage`（在 CTM 模組內）、`JournalPage` 也有搜尋框。使用者不知道要用哪個。

**建議：** 統一成一個搜尋入口（GlobalSearchPage），砍掉 `CaseTimeMachineSearchPage`，`JournalPage` 的搜尋框連到全域搜尋。

---

### 流程 3：學法律知識
**目前卡在哪裡：** 「學習」Tab → `KnowLawPage` 有 3 個 Tab（法學課堂 / 生活工具箱 / 手帳筆記）。使用者看到「手帳筆記」會困惑這是什麼。

**建議：** 第一版學習 Tab 只放 2 個子分頁：法學課堂 + 工具。手帳筆記延後。

---

### 流程 4：追蹤案件或法規
**目前卡在哪裡：** `FollowingPage` 是一個沒有在底部導航裡的頁面，入口分散在首頁、個人頁、案件詳情頁等多個地方。使用者不知道「我追蹤的東西去哪裡看」。

**建議：** 把追蹤 / 收藏 / 更新動態收進「我的」Tab（`ProfilePage`），或直接換掉底部導航一個 Tab 為「追蹤」。

---

### 流程 5：從首頁焦點進入案件詳情
**目前卡在哪裡：** 首頁有「每日案件故事卡」，但點進去可能是 `LearningMockDetailPage`（學習文章詳情）而不是 `CaseDossierDetailPage`（案卷詳情）。兩者定位不同，使用者會混淆。

**建議：** 首頁焦點卡要明確分類：「案件」→ `CaseDossierDetailPage`；「法律知識文章」→ `LearningMockDetailPage`。

---

### 流程 6：回到收藏或追蹤中的內容
**目前卡在哪裡：** `FollowingPage` 是 3227 行的單一 Widget，裡面有一個 `_FollowPage` enum 控制 13 種子狀態。使用者從外部根本無法預測目前在哪一層。

**建議：** 拆分成獨立頁面，用 `Navigator.push` 進入，而不是頁內狀態機。

---

### 流程 7：使用 AI 法律助理
**目前：** 入口在底部導航「小法助」（`GlobalSearchPage`），裡面有搜尋 + AI 摘要。另外還有 `LawAssistantChatPage` 是獨立的對話頁。

**問題：** GlobalSearchPage 本身已經在 inline 模擬 AI 回應（5240 行，hardcode 了詐欺、退貨等關鍵字的回應）。這和 `LawAssistantChatPage` 的功能是重疊的。

**建議：** 搜尋頁的 AI 摘要留一個輕量版；完整對話移到 `LawAssistantChatPage`。搜尋頁不應該 hardcode AI 回應邏輯，這段應該抽到 service 層。

---

### 流程 8：使用互動型學習功能
**目前：** 互動功能分散在 3 個地方：
- `KnowLawPage` → 工具 Tab → `MockCourtChallenge`
- `CaseDossierDetailPage` → 子頁 → `CaseJudgePracticePage`、`CaseWitnessCrossPage`

使用者找不到統一入口，且功能定位重疊。

**建議：** 第一版只保留一個互動型功能（建議：`MockCourtChallenge`），其他延後。

---

## 六、底部導航審查

### 目前底部導航的問題

1. **「記事」** 這個詞沒有任何法律 App 的語意。使用者無法猜到裡面有「案例時光機」和「歷史上的今天」
2. **「小法助」** 這個命名是 AI 助理，但 Tab 的實際功能是「全域搜尋 + AI」，讓「搜尋」功能沒有清楚的入口
3. **「學習」** 裡面有 3 個子分頁 + 多個工具，等於把 3 個 App 塞進一個 Tab
4. 動態排序機制造成 `selectedIndex` 與真實 index 脫鉤，是 bug 溫床

### 建議的底部導航（4 個，不超過 5 個）

> **第一版建議：改為 4 個 Tab，去掉「記事」**

| # | 現在 | 建議改名 | 圖示建議 | 包含內容 |
|---|------|---------|---------|---------|
| 1 | 首頁 | **首頁** | home | 維持 Bento 首頁 |
| 2 | 學習 | **學習** | menu_book | 法學課堂 + 工具（去掉手帳） |
| 3 | 小法助 | **搜尋** | search | 搜尋 + AI 助理入口 |
| 4 | 記事 | **案件** | inventory_2 → `gavel` | 案件時光機 + 歷史上的今天 |
| ~~5~~ | ~~我的~~ | **移除或縮減** | | 個人設定可放在首頁 Header 右上角 |

**或者：** 如果一定要保留 5 個 Tab，則第 5 個應該是「**我的**」（收藏 + 追蹤 + 設定），但功能要大幅簡化，不要是現在 3227 行的 FollowingPage。

### 建議完整取消的功能
- 自訂 Tab 排序：沒有必要，增加 main.dart 複雜度
- 動態 order mapping：應直接靜態定義

---

## 七、Flutter 程式結構審查

### 7.1 Route 命名問題
- 目前**沒有統一 route 命名系統**，全部使用 `Navigator.of(context).push(MaterialPageRoute(...))`
- 沒有 named routes，沒有 `GoRouter` 或 `AutoRoute`
- 跨功能導航（例如從首頁 Bento 卡跳到 CTM）使用 callback 傳遞，造成 `main.dart` 承接了不必要的「頁面間協調」責任

### 7.2 Widget 重複問題（確認的）

| 重複項目 | 位置 1 | 位置 2 | 建議 |
|---------|--------|--------|------|
| 搜尋欄位 Widget | `JournalPage._JournalSearchField` | `GlobalSearchPage` 內的搜尋框 | 抽成 `SharedSearchField` |
| 狀態卡片（載入中/錯誤/空） | `JournalPage._JournalSearchStatusCard` | 多處 FutureBuilder | 抽成 `AsyncStateCard` |
| Legacy import | `home_page.dart` 還 import `legacy/home_discussion_section_legacy.dart` | `home_v2_sections.dart` 也 import 同一個 | 清除 legacy import |
| AI 模擬回應邏輯 | `GlobalSearchPage._triggerAiOverviewGeneration`（hardcoded if-else，200 行） | `LawAssistantChatPage` | 應統一抽到 `LawAssistantService` |

### 7.3 頁面過肥問題（最嚴重的）

| 檔案 | 大小 | 問題 |
|------|------|------|
| `know_law_page.dart` | **277KB** | 整個「學習」Tab 的 UI 都在這裡 |
| `global_search_page.dart` | **179KB** | 搜尋 + AI + 案件詳情 + 法條詳情全在一個檔案 |
| `case_dossier_detail_page.dart` | **197KB** | 案卷詳情有 10+ 個子頁面都在一個檔案裡 |
| `following_page.dart` | **94KB** | 13 種頁面狀態在一個 Widget 裡 |
| `home_subpages.dart` | **53KB** | 3 個獨立子頁面在一個檔案裡 |

### 7.4 features/ 和 pages/ 混用問題

| 問題 | 說明 |
|------|------|
| CTM 和 OnThisDay 在 `features/`，其他都在 `pages/` | 分層標準不一致 |
| `pages/learning/` 下有 `widgets/` 放了實際頁面（`achievement_room.dart`、`mock_court_challenge.dart`） | widget 目錄放了完整頁面，命名誤導 |
| `pages/tools/legacy/` 是空 shell，但 `legal_tools_page.dart` 還被 `following_page.dart` import | Legacy 未清除 |
| `pages/prototype/` 目錄是空的 | 無用目錄 |
| `pages/trending/` 下只有 `legacy/trend_page_legacy.dart` | 應該整個砍掉 |

### 7.5 main.dart 的問題

`main.dart` 目前承擔了：
1. App 殼層（`MylawApp`）✅ 合理
2. Theme 建構（`_buildLightTheme`, `_buildDarkTheme`）⚠️ 應移到 `theme/app_theme.dart`
3. 底部導航 Widget（`_IslandBottomNav`）⚠️ 應移到 `components/navigation/island_bottom_nav.dart`
4. Nav item 資料定義（`_navItems` 靜態 const）⚠️ 應移到 navigation 設定
5. Navbar order mapping 邏輯 ❌ 這段邏輯造成 `selectedIndex` 不等於實際 tab index 的混亂

### 7.6 data/ 層問題

- `data/mock_data/` 散落在多個子目錄：`home/`、`learning/`，需要統一
- `data/moj/` 和 `data/legal_sources/` 的邊界不清
- `data/official/` 目錄用途不明（和 `moj/` 是什麼關係？）

---

## 八、第一版 App 建議

### A. 第一版必留功能
1. 首頁（Bento 風格，但減少到 6 個區塊）
2. 案件時光機（入口 + 書架 + 案卷詳情 + 時間軸）
3. 歷史上的今天（4 個頁面，結構乾淨）
4. 全域搜尋 + AI 助理（合併為一個入口）
5. 法律知識文章（學習課堂）
6. 追蹤 / 收藏功能（簡化版，收進「我的」）
7. 個人設定（深淺色主題、通知）

### B. 第一版可簡化功能
1. 互動測驗（只保留一個 Quiz 頁面，合併 `HomeMissionQuizPage` 和 `LearningQuizPage`）
2. 社會新聞 / 官方資訊（首頁 2 則，不做獨立 Tab）
3. 觀點光譜（收進 `CaseDossierDetailPage` 的分頁，不獨立頁面）
4. AI 助理（保留 `GlobalSearchPage` 的 inline 摘要，但 hardcode 邏輯移到 service）

### C. 第二版再做的功能
1. 觀點光譜（獨立頁面版）
2. 社會關係圖（`CaseSocialGraphPage`）
3. 手帳筆記 + 封面編輯
4. 書狀產生器
5. 成就展覽室
6. 自訂底部導航排序

### D. 建議刪除的功能
1. `CaseLibraryHallSelectionPage`（合併進大廳頁）
2. `CaseTimeMachineSearchPage`（由全域搜尋取代）
3. `FollowedUpdatesPage`（合併進 FollowingPage 動態分頁）
4. `CaseOpinionBoardPage`（和網友室重疊，選一個）
5. Legacy 頁面的正式路由入口（保留檔案但移除所有 live import）
6. 底部導航排序機制（靜態化）
7. `pages/prototype/` 目錄（空的）
8. `pages/trending/` 目錄（只剩 legacy）

### E. 會讓 App 變得不聚焦的功能
1. `MockCourtChallenge` + `CaseJudgePracticePage` + `CaseWitnessCrossPage` 三個同時存在（選一個）
2. `NotebookCoverEditorPage`（視覺很美，但第一版使用者找不到理由用它）
3. `AchievementRoom` 98KB（第一版內容量不夠，成就系統是空殼）
4. `CaseNetizenChatRoomPage`（像社群功能，和法律探索主線無直接關係）

---

## 九、總表

| 類別 | 頁面或功能名稱 | 問題 | 建議處理方式 | 優先級 | 影響第一版 | UX 影響 | 維護影響 | Codex 實作指令 |
|------|-------------|------|------------|--------|-----------|--------|---------|--------------|
| 合併 | `CaseLibraryHallSelectionPage` → `CaseLibraryHallPage` | 兩頁只差「選館動作」 | 把選館 UI 加進大廳頁頂部 | 高 | ✅ 是 | 減少跳頁混亂 | 刪一個檔案 | 把 `case_library_hall_selection_page.dart` 的館別選擇 UI 移到 `case_library_hall_page.dart` 頂部，刪除 Selection 頁 |
| 刪除 | `CaseTimeMachineSearchPage` | 和 GlobalSearchPage 重複 | 刪除，讓 CTM 搜尋跳轉到 GlobalSearchPage | 高 | ✅ 是 | 統一搜尋入口 | 刪一個檔案 | 在 CTM 內的搜尋按鈕改為 `Navigator.push` 到 `GlobalSearchPage`，刪除 `case_time_machine_search_page.dart` |
| 合併 | `HomeMissionQuizPage` + `LearningQuizPage` | 功能重複 | 保留一個，統一入口 | 高 | ✅ 是 | 減少混亂 | 減少維護 | 保留 `LearningQuizPage`，在學習頁統一引用，刪除 `home_mission_quiz_page.dart` |
| 合併 | `FollowedUpdatesPage` → `FollowingPage` | 功能重複，FollowedUpdates 只有 9KB | 合併進 FollowingPage 的更新動態分頁 | 高 | ✅ 是 | 減少迷路 | 減少維護 | 把 `followed_updates_page.dart` 的 UI 移入 `FollowingPage` 的 `_FollowPage.updates` 分頁，刪除獨立頁 |
| 刪除正式入口 | 所有 Legacy 頁面 | 仍被 live 程式碼 import | 移除所有 live import，legacy 資料夾保留但加 `// ARCHIVED` 標記 | 高 | ✅ 是 | 無 UX 影響 | 降低 build 體積與混亂 | 刪除 `home_page.dart` 的 legacy import、`home_v2_sections.dart` 的 legacy import、`following_page.dart` 對 `legal_tools_page.dart` 的 import |
| 延後 | `MockCourtChallenge` / `CaseJudgePracticePage` / `CaseWitnessCrossPage` | 三個功能做同一件事 | 只保留 `MockCourtChallenge`，其他兩個移到第二版 | 高 | ✅ 是 | 減少重複 | 減少 50KB+ 程式碼 | 移除 `CaseJudgePracticePage` 和 `CaseWitnessCrossPage` 的正式路由入口，保留檔案但標記 `// V2` |
| 延後 | `AchievementRoom`（98KB） | 第一版內容不足 | 移除首頁/學習頁入口，第二版再做 | 高 | ✅ 是 | 輕微損失，但不核心 | 省 98KB 編譯 | 移除 `home_v2_bento_cards.dart` 中 `HomeV2AchievementCard` 的跳頁邏輯，或把卡片改成靜態展示 |
| 延後 | `NotebookCoverEditorPage` / 手帳筆記 | 第一版非核心 | 移除 KnowLawPage 的手帳 Tab | 中 | ✅ 是 | 輕微損失 | 省 24KB | 移除 `KnowLawPage` 的手帳 Tab，保留檔案 |
| 延後 | `LegalDocumentExportPage` | 工具方向，偏離定位 | 移除學習工具箱入口 | 中 | ⚠️ 視產品決策 | 輕微損失 | 省 17KB | 移除工具抽屜中的書狀產生器入口 |
| 改名 | 底部 Tab「記事」→「案件」 | 使用者看不懂 | 改名並換圖示 | 高 | ✅ 是 | 大幅提升清楚度 | 只改 main.dart | 在 `main.dart` 的 `_navItems` 把 label `'記事'` 改為 `'案件'`，icon 從 `inventory_2` 改為 `gavel_rounded` |
| 刪除 | 底部導航動態排序機制 | 增加複雜度，5 個 Tab 不需要 | 移除 order mapping 邏輯，靜態化 navItems | 高 | ✅ 是 | 無 UX 影響 | 大幅降低 main.dart 複雜度 | 移除 `main.dart` 中的 `order.map(...)` 邏輯，改為直接使用 `_navItems` 和 `_pages` 靜態陣列 |
| 拆檔 | `know_law_page.dart`（277KB） | 過肥，難維護 | 拆分為頁面 + 子頁面 + widgets | 高 | ✅ 是 | 無 UX 影響 | 大幅提升維護性 | 把三個 Tab（課堂/工具/手帳）的 UI 分別拆到 `learning_classroom_tab.dart`、`learning_tools_tab.dart`，原 `know_law_page.dart` 只保留 TabController 和 Shell |
| 拆檔 | `global_search_page.dart`（179KB） | 過肥，AI 邏輯 hardcoded | 拆分搜尋 / AI / 結果列表 | 中 | ✅ 是 | 無 UX 影響 | 大幅提升維護性 | 把 `_triggerAiOverviewGeneration` 移到 `lib/data/law_assistant/law_assistant_service.dart`，把 `_SearchPage` 的各子頁 UI 拆到獨立 Widget 檔案 |
| 拆檔 | `following_page.dart`（94KB，13 種頁面狀態） | App-in-App 反模式 | 把 13 種狀態中，需要獨立路由的改為 push 頁面 | 中 | ⚠️ 視重構規模 | 提升流程清楚度 | 提升維護性 | 把 `_FollowPage.collections`、`_FollowPage.notes`、`_FollowPage.drafts` 改為獨立 Page，用 `Navigator.push` 進入 |
| 新增 | `lib/components/navigation/island_bottom_nav.dart` | 目前 `_IslandBottomNav` 在 main.dart | 抽到獨立元件 | 中 | ⚠️ | 無 UX 影響 | 提升 main.dart 可讀性 | 把 `_IslandBottomNav` 和 `_BottomNavItemData` 從 `main.dart` 剪切到 `lib/components/navigation/island_bottom_nav.dart` |
| 新增 | `lib/theme/app_theme.dart` | theme 建構在 main.dart | 抽到獨立檔案 | 低 | ❌ | 無 UX 影響 | 提升可讀性 | 把 `_buildLightTheme()` 和 `_buildDarkTheme()` 移到 `app_theme.dart` |
| 刪除 | `pages/prototype/`（空目錄） | 完全空的 | 直接刪除 | 低 | ❌ | 無 | 清理 | `rm -rf lib/pages/prototype` |
| 刪除 | `pages/trending/`（只剩 legacy） | 只有 1 個 3KB legacy 檔案 | 把 legacy 檔案移到 `pages/home/legacy/`，刪除 trending 目錄 | 低 | ❌ | 無 | 清理 | 移動 `trend_page_legacy.dart` 到 `lib/pages/home/legacy/`，刪除 `pages/trending/` 目錄 |

---

## 十、最小修改路線（最優先 10 步）

### Step 1：改名底部 Tab「記事」→「案件」

**為什麼優先：** 這是最快提升 App 清楚度的動作，0 風險，10 分鐘完成。

**涉及：** [`main.dart`](file:///Users/babychen/Dropbox/Baby%20Mac/python/preamble/lib/main.dart)

**Codex 指令：**
```
在 lib/main.dart 的 _navItems 中，找到 label: '記事' 的項目，把 label 改為 '案件'，
把 icon 從 Icons.inventory_2_outlined 改為 Icons.gavel_outlined，
把 selectedIcon 從 Icons.inventory_2_rounded 改為 Icons.gavel_rounded。
同樣修改 originalNavItems 中的對應項目。
```

**預期改善：** 使用者第一次打開 App 就能理解這個 Tab 是什麼。

---

### Step 2：移除 main.dart 的 navbarOrder 動態排序機制

**為什麼優先：** 這段 `order.map(...)` 邏輯讓 `selectedIndex` 和實際 tab index 不一致，是 bug 溫床，且功能（讓使用者排序 5 個 Tab）在第一版不值得。

**涉及：** [`main.dart`](file:///Users/babychen/Dropbox/Baby%20Mac/python/preamble/lib/main.dart)、[`app_state.dart`](file:///Users/babychen/Dropbox/Baby%20Mac/python/preamble/lib/app/app_state.dart)

**Codex 指令：**
```
在 lib/main.dart 的 _MylawAppState.build() 中：
1. 移除 `final order = _appState.navbarOrder;`
2. 移除 `final displayNavItems = order.map(...).toList();`
3. 移除 `final displayPages = order.map(...).toList();`
4. 把 originalNavItems 改名為 _navItems（static const）
5. 把 originalPages 改名為 _pages（直接用）
6. IndexedStack 的 children 改為直接用 _pages
7. _IslandBottomNav 的 items 改為直接用 _navItems
8. onNavigateToTab callback 的 realIndex 邏輯改為直接用 targetOriginalIndex
注意：在 ProfilePage 的介面設定裡，移除「調整導航欄排序」的 UI 入口。
```

**預期改善：** `main.dart` 可讀性大幅提升，`selectedIndex` 的語意變清楚。

---

### Step 3：清除所有 legacy import

**為什麼優先：** Legacy 程式碼仍在 live import 鏈中，增加 build 體積和維護混亂。

**涉及：**
- [`home_page.dart`](file:///Users/babychen/Dropbox/Baby%20Mac/python/preamble/lib/pages/home/home_page.dart)（import legacy_home）
- [`home_v2_sections.dart`](file:///Users/babychen/Dropbox/Baby%20Mac/python/preamble/lib/components/home/v2/home_v2_sections.dart)（import legacy_home）
- [`following_page.dart`](file:///Users/babychen/Dropbox/Baby%20Mac/python/preamble/lib/pages/following/following_page.dart)（import `legal_tools_page.dart`）

**Codex 指令：**
```
1. 在 lib/pages/home/home_page.dart 中，移除 `import 'package:preamble/components/home/legacy/home_discussion_section_legacy.dart' as legacy_home;`，
   並確認該 import 在 home_page.dart 中沒有被使用（如有使用，改用 v2 元件替代）。
2. 在 lib/components/home/v2/home_v2_sections.dart 中，移除同一個 legacy import，
   並把對應 legacy widget 呼叫改為 v2 元件或移除該 section。
3. 在 lib/pages/following/following_page.dart 中，移除 `import 'package:preamble/pages/tools/legacy/legal_tools_page.dart';`，
   並把對該 legacy 頁面的引用改為直接內聯或刪除該功能入口。
```

**預期改善：** 移除最少 229KB 的 dead import 依賴。

---

### Step 4：刪除 `CaseTimeMachineSearchPage`，統一搜尋入口

**為什麼優先：** 統一搜尋是使用者流程的核心，兩個搜尋入口必然讓人困惑。

**涉及：** [`case_time_machine_search_page.dart`](file:///Users/babychen/Dropbox/Baby%20Mac/python/preamble/lib/features/case_time_machine/pages/case_time_machine_search_page.dart)、[`case_time_machine_entry_page.dart`](file:///Users/babychen/Dropbox/Baby%20Mac/python/preamble/lib/features/case_time_machine/pages/case_time_machine_entry_page.dart)

**Codex 指令：**
```
1. 在 lib/features/case_time_machine/pages/case_time_machine_entry_page.dart 中，
   找到所有跳轉到 CaseTimeMachineSearchPage 的 Navigator.push 呼叫，
   改為 Navigator.push 到 GlobalSearchPage（從 lib/pages/search/global_search_page.dart 引入）。
2. 刪除 lib/features/case_time_machine/pages/case_time_machine_search_page.dart。
3. 確認沒有其他頁面 import 了 case_time_machine_search_page.dart。
```

**預期改善：** 使用者只需要知道一個搜尋入口。

---

### Step 5：合併 `CaseLibraryHallSelectionPage` 進 `CaseLibraryHallPage`

**為什麼優先：** 減少一層不必要的跳頁，使用者直接在大廳選擇展館。

**涉及：** [`case_library_hall_selection_page.dart`](file:///Users/babychen/Dropbox/Baby%20Mac/python/preamble/lib/features/case_time_machine/pages/case_library_hall_selection_page.dart)、[`case_library_hall_page.dart`](file:///Users/babychen/Dropbox/Baby%20Mac/python/preamble/lib/features/case_time_machine/pages/case_library_hall_page.dart)

**Codex 指令：**
```
1. 閱讀 case_library_hall_selection_page.dart 的 UI，把展館選擇卡片 Row/Grid 移到
   case_library_hall_page.dart 的頂部（在書架大廳 Header 下方）。
2. 把 case_library_hall_page.dart 中原本跳到 CaseLibraryHallSelectionPage 的 Navigator.push
   改為在同頁面直接顯示展館選擇 UI。
3. 刪除 case_library_hall_selection_page.dart。
```

**預期改善：** 案件瀏覽流程減少一層跳頁。

---

### Step 6：合併 `HomeMissionQuizPage` 和 `LearningQuizPage`

**為什麼優先：** 兩個測驗頁面功能重疊，保留一個，減少維護成本。

**涉及：** [`home_mission_quiz_page.dart`](file:///Users/babychen/Dropbox/Baby%20Mac/python/preamble/lib/pages/learning/home_mission_quiz_page.dart)、[`learning_quiz_page.dart`](file:///Users/babychen/Dropbox/Baby Mac/python/preamble/lib/pages/learning/learning_quiz_page.dart)

**Codex 指令：**
```
1. 對比 home_mission_quiz_page.dart 和 learning_quiz_page.dart 的功能差異。
2. 保留 learning_quiz_page.dart，把 home_mission_quiz_page.dart 中獨有的「每日任務」顯示邏輯移入。
3. 把 know_law_page.dart 中所有指向 HomeMissionQuizPage 的引用改為 LearningQuizPage。
4. 刪除 home_mission_quiz_page.dart。
```

**預期改善：** 測驗功能有清楚的單一入口。

---

### Step 7：移除 `HomeV2AchievementCard` 和 `HomeV2ToolsDrawer` 出首頁

**為什麼優先：** 首頁資訊密度過高，成就和工具不應該是首頁的核心區塊。

**涉及：** [`home_page.dart`](file:///Users/babychen/Dropbox/Baby%20Mac/python/preamble/lib/pages/home/home_page.dart)

**Codex 指令：**
```
在 lib/pages/home/home_page.dart 的 build() 方法中：
1. 移除 `HomeV2AchievementCard()` 和相鄰的 `HomeV2DailyCaseStoryCard()` 並排的 Row，
   只保留 `HomeV2DailyCaseStoryCard()` 作為全寬卡片。
2. 移除 `HomeV2ToolsDrawer(...)` 和相關的 SizedBox。
3. 移除 `HomeV2LawDatabaseCard(...)` 和相關的 SizedBox。
4. 確保首頁區塊順序為：Header → GreetingCard → QuickAsk → WatchlistCard → DailyCaseStory → TopicBentoGrid → NewsletterFocusCard → SocialNewsSection。
```

**預期改善：** 首頁資訊密度降低，核心內容（案件 + AI 問答 + 追蹤 + 專題）更突出。

---

### Step 8：把 `_IslandBottomNav` 和主題建構抽出 `main.dart`

**為什麼優先：** `main.dart` 應該只是 App 的入口，不應該包含 UI Widget 和主題邏輯。

**涉及：** [`main.dart`](file:///Users/babychen/Dropbox/Baby%20Mac/python/preamble/lib/main.dart)

**Codex 指令：**
```
1. 建立 lib/components/navigation/island_bottom_nav.dart，
   把 _IslandBottomNav class 和 _BottomNavItemData class 從 main.dart 剪切到此檔案，
   改為 public class（移除底線前綴）：IslandBottomNav 和 BottomNavItemData。
2. 建立 lib/theme/app_theme.dart，
   把 _buildLightTheme() 和 _buildDarkTheme() 方法移到此檔案，
   改為 static 方法：AppTheme.light() 和 AppTheme.dark()。
3. 在 main.dart 中引入以上兩個檔案，並更新引用。
```

**預期改善：** `main.dart` 縮短至約 150 行，職責清楚。

---

### Step 9：把 `KnowLawPage` 的三個 Tab 拆到獨立 Widget 檔案

**為什麼優先：** 277KB 的單一 Dart 檔案是整個專案最大的維護炸彈。

**涉及：** [`know_law_page.dart`](file:///Users/babychen/Dropbox/Baby%20Mac/python/preamble/lib/pages/learning/know_law_page.dart)

**Codex 指令：**
```
1. 閱讀 know_law_page.dart，確認三個 Tab 的 Widget 名稱與範圍。
2. 建立以下三個新檔案：
   - lib/pages/learning/tabs/learning_classroom_tab.dart（法學課堂 Tab 內容）
   - lib/pages/learning/tabs/learning_tools_tab.dart（生活工具箱 Tab 內容）
   - lib/pages/learning/tabs/learning_notebook_tab.dart（手帳筆記 Tab 內容）
3. 把對應 Tab 的 Widget 程式碼從 know_law_page.dart 移到各自的檔案。
4. 在 know_law_page.dart 中引入以上三個 tab 檔案，原檔案只保留：
   - KnowLawPage StatefulWidget
   - TabController 和 Tab 定義
   - build() 方法的 Scaffold + TabBarView
目標：know_law_page.dart 縮短到 100 行以內。
```

**預期改善：** 最大炸彈解除，法學課堂、工具箱、筆記各自可獨立修改。

---

### Step 10：移除互動型子頁的重複入口（`CaseJudgePracticePage`、`CaseWitnessCrossPage`）

**為什麼優先：** 三個模擬法庭功能並存，讓使用者和開發者都困惑。第一版只需要一個。

**涉及：** [`case_dossier_detail_page.dart`](file:///Users/babychen/Dropbox/Baby%20Mac/python/preamble/lib/features/case_time_machine/pages/case_dossier_detail_page.dart)

**Codex 指令：**
```
在 lib/features/case_time_machine/pages/case_dossier_detail_page.dart 中：
1. 找到所有跳轉到 CaseJudgePracticePage 的 Navigator.push 呼叫，把對應的按鈕 UI 移除或改為「即將推出」提示。
2. 找到所有跳轉到 CaseWitnessCrossPage 的 Navigator.push 呼叫，同樣移除或標記「即將推出」。
3. 保留跳轉到 MockCourtChallenge 的入口不動。
4. 不刪除 CaseJudgePracticePage 和 CaseWitnessCrossPage 的檔案（留作第二版），
   但在檔案頂部加上 // V2 FEATURE - NOT ACCESSIBLE FROM FIRST VERSION 的標記。
```

**預期改善：** 使用者在案卷詳情頁只看到一個清楚的互動入口，不再困惑有三個差不多的功能。
