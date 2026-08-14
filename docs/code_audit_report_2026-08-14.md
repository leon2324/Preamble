# 全專案程式碼審查 & 架構修復計畫

透過 7 組平行審計代理深度掃描 130+ 個 Dart 原始碼檔案，發現以下問題並提出修復方案。

## 審查原則
- ✅ 僅修正程式碼架構問題，加上教學型註解
- ❌ 不改動任何產品功能、邏輯、UI/UX

---

## 發現的問題彙整

### 🔴 CRITICAL — 嚴重（會導致狀態錯亂）

#### 1. main.dart — `IosIntentRouter` 與 `NativeStartupCoordinator` 重複消費 Intent（競態條件）
> [!CAUTION]
> `initState` 中先呼叫 `IosIntentRouter.register(context)` + `checkInitialIntents(context)`，緊接著又呼叫 `_nativeStartupCoordinator.consumeAndHandleInitialEvents()`。兩者都會調用同一批 `consumeInitialPrompt/consumeInitialQuery/consumeInitialLink`。Platform Channel 的 consume 行為是「讀取即銷毀」，造成競態條件：其中一方可能讀到 null，或兩邊同時處理不同事件觸發矛盾導航（一個用 `Navigator.push`、一個改 `selectedIndex`）。

**修復**：移除 `IosIntentRouter` 在 main.dart 中的所有呼叫，統一使用 `NativeStartupCoordinator`。

---

### 🟠 HIGH — 高風險

#### 2. main.dart — `_navItems` 是死碼
`_MylawAppState` 中宣告了 `static const List<BottomNavItemData> _navItems`（L67-93），但 `build()` 方法中自行建立了 `originalNavItems` 區域變數（L240-266），`_navItems` 從未被使用。

**修復**：移除 `_navItems`，在 `build()` 中改為引用提取後的 static const。

#### 3. auth_interceptor.dart — 併發 Token 刷新的競態條件
當多個請求同時遇到 401 時，第一個進入 `_refreshToken()` 設定 `_isRefreshing = true` 並開始 800ms 模擬刷新。後續請求進入 `if (_isRefreshing)` 分支，只等待 500ms 就返回 `_mockAccessToken`。但此時 800ms 的刷新尚未完成，返回的仍是舊/過期 Token。

**修復**：改用 `Completer<String?>` 讓併發請求共享同一次刷新結果。

#### 4. on_this_day_home_page.dart — 閏年日期溢位
`_timeTravel()` 中 `DateTime(_anchorDate.year, randomCase.month, randomCase.day)`，若 `randomCase` 是 2/29，但 `_anchorDate.year` 非閏年，Dart 會自動滾入 3/1，導致載入錯誤日期的案件。

**修復**：加入閏日安全檢查。

#### 5. ios_intent_router.dart — push KnowLawPage 產生重複頁面疊層
`_handleDeepLink` 中對 `today_case` 做 `Navigator.push(KnowLawPage())`，但 `KnowLawPage` 是 `IndexedStack` 中的主分頁。Push 後使用者會看到一個沒有底部導覽的重複頁面。

**修復**：此檔案因與 `NativeStartupCoordinator` 完全重複且會產生副作用，在 main.dart 中已移除其所有呼叫；保留檔案但加上 @Deprecated 註解。

---

### 🟡 MEDIUM — 中風險

#### 6. case_library_repository.dart — toggleFavorite/toggleFollowing 手動複製 30 個屬性（脆弱且易遺漏）
`toggleFavorite` 和 `toggleFollowing` 手動逐一複製 CaseBook 的所有屬性，而同一檔案其他地方正確使用 `copyWith()`。若日後新增欄位忘記在此處同步，會導致資料遺失。

**修復**：改用 `copyWith()` 方法。

#### 7. calendar_sync_service.dart — `formattedDate` 死碼
`syncToReminders()` 中建構的 `formattedDate` 字串從未使用。

**修復**：移除死碼。

#### 8. quota_manager.dart — `consumeQuota()` 呼叫 `remainingQuota` 造成 `_loadState()` 雙重執行
`consumeQuota()` 先呼叫 `_loadState()`，然後呼叫 `remainingQuota`（getter 內部又會呼叫 `_loadState()`），造成不必要的雙重執行。

**修復**：直接用 `_dailyLimit - _usedQuota` 取代 `remainingQuota`。

---

### 🔵 LOW — 低風險（死碼 / 冗餘）

#### 9. preamble_theme.dart — 整個檔案是死碼
`PreambleTheme` 類別未在任何地方被使用，`main.dart` 使用的是 `AppTheme`。

**修復**：保留檔案但加上 @Deprecated 註解與說明，標記為設計階段遺留。

#### 10. on_this_day_home_page.dart — `_selectedQuote` 在兩處重複計算
`_loadCasesForSelectedDate()` 計算並存入 `_selectedQuote`，但 `_buildFeaturedCardTextContent()` 又重複計算相同的 index。

**修復**：在 build 中直接使用 `_selectedQuote`。

---

## 教學型註解策略

在每個修改的檔案中，以 `//` 加入中文教學型註解，說明：
- 為何這段程式碼存在
- 它解決了什麼問題
- 未來維護時需要注意什麼

---

## 修改檔案清單

### [MODIFY] [main.dart](file:///Users/babychen/Dropbox/Baby%20Mac/python/lawapp/lib/main.dart)
- 移除死碼 `_navItems`
- 移除 `IosIntentRouter` 的重複 Intent 消費
- 將 `originalNavItems` 提取為 static const 避免每次 build 重建

### [MODIFY] [auth_interceptor.dart](file:///Users/babychen/Dropbox/Baby%20Mac/python/lawapp/lib/utils/auth_interceptor.dart)
- 修復併發 Token 刷新競態條件（改用 Completer）
- 加上教學型註解

### [MODIFY] [case_library_repository.dart](file:///Users/babychen/Dropbox/Baby%20Mac/python/lawapp/lib/features/case_library/data/case_library_repository.dart)
- `toggleFavorite`/`toggleFollowing` 改用 `copyWith()`
- 加上教學型註解

### [MODIFY] [calendar_sync_service.dart](file:///Users/babychen/Dropbox/Baby%20Mac/python/lawapp/lib/platform/calendar_sync_service.dart)
- 移除未使用的 `formattedDate` 死碼
- 加上教學型註解

### [MODIFY] [on_this_day_home_page.dart](file:///Users/babychen/Dropbox/Baby%20Mac/python/lawapp/lib/features/on_this_day/pages/on_this_day_home_page.dart)
- 修復閏年日期溢位
- 消除 `_selectedQuote` 重複計算
- 加上教學型註解

### [MODIFY] [quota_manager.dart](file:///Users/babychen/Dropbox/Baby%20Mac/python/lawapp/lib/utils/quota_manager.dart)
- 修復 `_loadState()` 雙重執行
- 加上教學型註解

### [MODIFY] [preamble_theme.dart](file:///Users/babychen/Dropbox/Baby%20Mac/python/lawapp/lib/app/preamble_theme.dart)
- 加上 @Deprecated 註解標記為死碼
- 保留檔案供日後參考

### [MODIFY] [ios_intent_router.dart](file:///Users/babychen/Dropbox/Baby%20Mac/python/lawapp/lib/platform/ios_intent_router.dart)
- 加上 @Deprecated 註解與說明

---

## 驗證計畫

### 自動化測試
```bash
cd /Users/babychen/Dropbox/Baby\ Mac/python/lawapp && flutter analyze
```

### 手動驗證
- 確認所有修改不影響現有產品功能、邏輯、UI/UX
- 修改均為：移除死碼、修正競態條件、改善程式碼健壯性、加上教學註解
