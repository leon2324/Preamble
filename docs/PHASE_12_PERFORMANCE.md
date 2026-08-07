# 緒言 Preamble Phase 12 效能、快取與記憶體管理

本階段致力於提升底層運作的效能與穩定度，解決潛在的卡頓 (Jank) 與記憶體洩漏 (Memory Leak) 隱患。

## 1. 啟動時間最佳化 (Deferred Initialization)
- **檔案變更**：`lib/main.dart`
- **實作設計**：
  - 移除了 `main()` 函式中阻塞的 `CaseLibraryRepository.instance.initialize()` 與 WidgetKit 跨進程同步呼叫。
  - 將上述資料庫初始化的操作延後至 `_MylawAppState.initState` 裡的 `WidgetsBinding.instance.addPostFrameCallback` 執行。
  - 此舉確保 Flutter 能第一時間 (First Frame) 繪製 UI，大幅提升冷啟動速度。

## 2. 首頁微光骨架屏 (Shimmer Skeleton)
- **檔案變更**：`lib/components/shared/shimmer_skeleton.dart`、`lib/features/case_library/pages/case_library_entry_page.dart`
- **實作設計**：
  - 開發純 Dart 的 `ShimmerSkeleton` 元件，藉由 `AnimationController` 與 `LinearGradient` 製作滑動高光效果。
  - 當法規或案件庫處於背景載入 (10~50毫秒) 狀態時，呈現平滑的科技感進場特效，取代傳統呆板的文字載入提示。

## 3. Isolate 背景多執行緒運算
- **檔案變更**：`lib/data/documents/document_repository.dart`
- **實作設計**：
  - 由於 Phase 11 加入了高畫質簽名圖檔 (Base64) 儲存功能，龐大的 JSON 在 Main Thread 編碼與解碼容易引發掉幀。
  - 全面引入 `Isolate.run()`，在背景執行緒非同步處理 `jsonEncode` 與 `jsonDecode`。

## 4. 記憶體洩漏防護 (SafeTextEditingController)
- **檔案變更**：`lib/utils/safe_text_editing_controller.dart`、`lib/pages/search/global_search_page.dart`
- **實作設計**：
  - 新增 `SafeTextEditingController` 提供追蹤銷毀生命週期的機制。
  - 替換搜尋頁面的控制器，避免多次進出小法助對話頁面時因忘記 `dispose()` 導致的記憶體殘留。
