#!/usr/bin/env python3
# -*- coding: utf-8 -*-

import os
import sys
import subprocess
import json
import urllib.request
import urllib.error

# 這是一個利用內建 urllib 呼叫 Gemini API 自動根據 Git Diff 撰寫 Commit Message 並提交的腳本。
# 不需要額外安裝 pip 套件，只需在環境變數中設定 GEMINI_API_KEY 即可。

def check_git_repo():
    try:
        subprocess.run(["git", "rev-parse", "--is-inside-work-tree"], stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL, check=True)
    except subprocess.CalledProcessError:
        print("❌ 錯誤：目前目錄不是 Git 儲存庫。")
        sys.exit(1)

def get_git_diff():
    # 檢查是否有 staged 的變更
    staged_diff = subprocess.run(["git", "diff", "--cached"], capture_output=True, text=True).stdout
    if staged_diff.strip():
        return staged_diff, True

    # 如果沒有 staged 的變更，檢查是否有 unstaged 的變更
    unstaged_diff = subprocess.run(["git", "diff"], capture_output=True, text=True).stdout
    if unstaged_diff.strip():
        return unstaged_diff, False

    # 檢查是否有未追蹤的檔案
    untracked = subprocess.run(["git", "status", "--porcelain"], capture_output=True, text=True).stdout
    if untracked.strip():
        return "", False

    return "", None

def generate_commit_message(api_key, diff_content):
    url = f"https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent?key={api_key}"
    
    # 限制 diff 的長度，避免 token 爆掉（限制在 15000 字元內）
    if len(diff_content) > 15000:
        diff_content = diff_content[:15000] + "\n\n[... 後續 Diff 內容因過長而省略 ...]"

    prompt = (
        "你是一個專業的 Git Commit Message 產生器。\n"
        "請根據下方提供的 `git diff` 內容，撰寫一份符合 Git 規範的繁體中文 (台灣，Traditional Chinese) Commit Message。\n\n"
        "要求格式如下：\n"
        "1. 第一行是簡短的摘要（主標題），格式為: <type>(<scope>): <subject>，例如: feat(auth): 新增會員登入功能\n"
        "2. 第二行為空行\n"
        "3. 第三行開始是詳細的變更說明（Bullet points），條理分明地說明修改了什麼、修復了什麼崩潰或改動了哪些架構。\n"
        "4. **請只輸出 Commit Message 本身**，絕對不要加上任何 markdown 語法外框 (例如 ``` 或 ```git) 或額外的解釋說明。\n\n"
        f"Git Diff 內容如下：\n{diff_content}"
    )

    data = {
        "contents": [
            {
                "parts": [
                    {"text": prompt}
                ]
            }
        ],
        "generationConfig": {
            "temperature": 0.2
        }
    }

    req = urllib.request.Request(
        url,
        data=json.dumps(data).encode("utf-8"),
        headers={"Content-Type": "application/json"},
        method="POST"
    )

    try:
        with urllib.request.urlopen(req) as response:
            res_data = json.loads(response.read().decode("utf-8"))
            text = res_data["candidates"][0]["content"]["parts"][0]["text"]
            return text.strip()
    except urllib.error.HTTPError as e:
        print(f"❌ API 請求失敗，HTTP 狀態碼: {e.code}")
        try:
            print("錯誤詳情:", e.read().decode("utf-8"))
        except Exception:
            pass
        sys.exit(1)
    except Exception as e:
        print(f"❌ 發生未知錯誤: {e}")
        sys.exit(1)

def main():
    check_git_repo()

    api_key = os.environ.get("GEMINI_API_KEY")
    if not api_key:
        print("💡 提示：找不到 GEMINI_API_KEY 環境變數。")
        api_key = input("🔑 請輸入你的 Gemini API Key: ").strip()
        if not api_key:
            print("❌ 錯誤：未提供 API Key，無法產生 Message。")
            sys.exit(1)

    diff, has_staged = get_git_diff()

    if has_staged is None:
        print("✨ 檢查完畢：目前沒有任何需要提交的變更 (Working tree clean)。")
        return

    if not has_staged:
        print("⚠️ 偵測到有未暫存 (unstaged) 的變更。")
        ans = input("❓ 是否要自動暫存所有變更 (執行 `git add .`)？ [Y/n]: ").strip().lower()
        if ans in ["", "y", "yes"]:
            subprocess.run(["git", "add", "."])
            diff, has_staged = get_git_diff()
            if not has_staged:
                print("❌ 暫存變更失敗。")
                sys.exit(1)
        else:
            print("💡 請先手動執行 `git add <檔案>` 暫存你想提交的修改後再執行此腳本。")
            return

    print("🤖 正在調用 Gemini API 分析 Git Diff 並產生 Commit Message...")
    message = generate_commit_message(api_key, diff)

    print("\n================== 產生的 Commit Message ==================")
    print(message)
    print("===========================================================\n")

    ans = input("❓ 是否以此 Message 進行提交？\n[Y] 提交 / [N] 取消 / [E] 手動編輯: ").strip().lower()

    if ans in ["", "y", "yes"]:
        # 執行 commit
        proc = subprocess.Popen(["git", "commit", "-F", "-"], stdin=subprocess.PIPE, text=True)
        proc.communicate(input=message)
        print("\n✅ 提交成功！")
    elif ans == "e":
        # 讓使用者在終端機手動修改
        print("📝 請輸入你的 Commit Message (輸入完畢後，在新的一行按 Ctrl+D 儲存送出)：")
        edited_lines = []
        try:
            while True:
                line = sys.stdin.readline()
                if not line:
                    break
                edited_lines.append(line)
        except KeyboardInterrupt:
            print("\n❌ 已取消提交。")
            return
        
        edited_msg = "".join(edited_lines).strip()
        if edited_msg:
            proc = subprocess.Popen(["git", "commit", "-F", "-"], stdin=subprocess.PIPE, text=True)
            proc.communicate(input=edited_msg)
            print("\n✅ 提交成功！")
        else:
            print("❌ Commit Message 不能為空，已取消提交。")
    else:
        print("❌ 已取消提交。")

if __name__ == "__main__":
    main()
