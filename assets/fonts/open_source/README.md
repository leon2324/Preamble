# Open Source Fonts

台灣繁體中文教學註解：
這個資料夾放的是可以隨 App 打包的開源字體檔，來源與授權都保留在專案內，方便日後維護與上架審查。

## Included Families

- `Inter`：英文、數字與 UI 介面字，來源為 Inter v4.1，授權為 SIL Open Font License 1.1。
- `SourceHanSansTW/CN/JP`：繁中、簡中、日文黑體，來源為 Adobe Source Han Sans 2.005R Subset Variable TTF，授權為 SIL Open Font License 1.1。
- `SourceHanSerifTW/CN/JP`：繁中、簡中、日文明體，來源為 Adobe Source Han Serif 2.003R Subset Variable TTF，授權為 SIL Open Font License 1.1。

## Maintenance Notes

台灣繁體中文教學註解：
新增或替換字體時，請同步確認三件事：

1. 字體檔放在這個資料夾，授權文字放在 `licenses/`。
2. `pubspec.yaml` 的 `flutter.fonts` 有註冊對應 family。
3. `lib/theme/app_fonts.dart` 的常數與 fallback 順序有同步更新。

繁中 UI 請優先使用 `SourceHanSansTW` 或 `SourceHanSerifTW`，避免台灣常見字形被日文或簡中字形取代。
