#!/usr/bin/env bash
set -euo pipefail

# 台灣繁體中文教學註解：
# 這支腳本會把專案內的開源 TTF 字體複製到 macOS 使用者字體資料夾。
# 用途是讓 Figma、Keynote、瀏覽器截圖或其他設計工具也能使用同一批字體；
# Flutter App 本身仍然是透過 pubspec.yaml 打包 assets/fonts/open_source 裡的檔案。

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
SOURCE_DIR="$PROJECT_DIR/assets/fonts/open_source"
TARGET_DIR="$HOME/Library/Fonts"

mkdir -p "$TARGET_DIR"

for font_file in "$SOURCE_DIR"/*.ttf; do
  font_name="$(basename "$font_file")"
  cp "$font_file" "$TARGET_DIR/$font_name"
  printf 'Installed %s\n' "$font_name"
done

printf 'Done. Please relaunch apps that were already open so they refresh the font list.\n'
