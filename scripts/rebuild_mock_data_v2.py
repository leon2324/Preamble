#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
LawApp Factual Case Scraping & LLM Structuring Pipeline (rebuild_mock_data_v2.py)

此腳本負責二個核心任務：
1. 設計模擬/實際對接司法院裁判書檢索系統之爬蟲框架（獲取各領域裁判事實）。
2. 設計 LLM Prompt 將長篇裁判書客觀、無偏見地轉換為 LawApp 的結構化 CaseBook JSON 格式。
3. 設計圖像檢索接口以補充案例的網絡配圖。

注意：司法院網站設有嚴格的 Captcha 驗證機制。在實際生產環境中，推薦透過司法院開放資料 API，
或使用本腳本之 LLM 事實提取管線，對下載的 HTML/PDF 裁判主文進行結構化解析。
"""

import os
import sys
import json
import urllib.parse
import requests
from bs4 import BeautifulSoup

# 設定專案路徑
SCRIPT_DIR = os.path.dirname(os.path.abspath(__file__))
PROJECT_DIR = os.path.dirname(SCRIPT_DIR)
OUTPUT_JSON_DIR = os.path.join(PROJECT_DIR, 'assets', 'data', 'factual_cases')

# 確保輸出目錄存在
os.makedirs(OUTPUT_JSON_DIR, exist_ok=True)

class JudicialYuanScraperPipeline:
    """
    司法院裁判書事實爬取與結構化處理管線
    """
    def __init__(self, gemini_api_key=None):
        self.headers = {
            'User-Agent': 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36'
        }
        self.gemini_api_key = gemini_api_key or os.getenv("GEMINI_API_KEY")

    def fetch_judgment_list(self, query_sys="V", query_kw="損害賠償", limit=10):
        """
        模擬檢索司法院裁判書列表
        query_sys: "V" (民事), "M" (刑事), "A" (行政), "P" (公懲)
        """
        print(f"[爬蟲] 開始檢索司法院裁判書，類別: {query_sys}，關鍵字: {query_kw}...")
        
        # 司法院查詢系統 base URL (示意)
        base_url = "https://judgment.judicial.gov.tw/LAW_OUT/FJUD/qryresult.aspx"
        params = {
            'kw': query_kw,
            'sys': query_sys,
            'judtype': 'JU'
        }
        
        # 實際運作時，需要處理驗證碼或配合授權 API
        # 這裡返回標準模擬裁判列表結構以展現爬取管線
        simulated_list = []
        for i in range(1, limit + 1):
            simulated_list.append({
                "jud_id": f"SIM-{query_sys}-{query_kw}-{100 + i}",
                "title": f"臺灣台北地方法院 {110 + (i%5)} 年度訴字第 {200 + i} 號民事判決",
                "sys": query_sys,
                "date": f"202{i%5}-05-{10 + i}"
            })
        return simulated_list

    def fetch_judgment_detail(self, jud_id):
        """
        獲取裁判書全文
        """
        print(f"[爬蟲] 正在獲取裁判書內容 ID: {jud_id}...")
        # 模擬一份真實的民事/刑事判決書主文，用以輸入至 LLM 提取事實
        dummy_jud_text = """
        【裁判字號】112,訴,456
        【裁判日期】民國112年06月15日
        【裁判案由】損害賠償
        【主文】被告李明華應給付原告王大德新臺幣參拾萬元，及自民國112年2月1日起至清償日止，按週年利率百分之五計算之利息。
        原告其餘之訴駁回。
        【事實及理由】
        一、原告王大德主張：被告李明華於民國111年12月1日晚上8時許，駕駛車牌號碼AA-0000之小客車，行經台北市中山區南京東路與建國北路口時，因未注意車前狀況，闖紅燈撞擊正在過斑馬線之原告。原告當場倒地，受有右腿脛骨骨折、頭部挫傷等傷害，送馬偕醫院急診並住院治療10天。支出醫療費用8萬元、看護費4萬元、工作損失18萬元，並受有極大精神痛苦，請求被告賠償醫療費、工作損失及精神慰撫金共計50萬元。
        二、被告李明華答辯：對於本件車禍之發生及原告受傷事實均不爭執，亦坦承有違規闖紅燈之過失。惟原告請求之精神慰撫金過高，且原告於車禍當時並未注意來車，亦有部分過失，應減輕被告賠償責任。
        三、本院之判斷：
            經查，原告主張被告闖紅燈撞傷原告之事實，有台北市政府警察局交通警察大隊道路交通事故調查報告表、診斷證明書可稽，且為被告所不爭執，自堪信為真實。被告駕駛車輛未遵守交通號誌闖紅燈，為本件車禍之肇事主因。原告行經行人穿越道，依交通安全規則享有絕對優先權，無過失可言，被告過失相抵之抗辯不足採信。審酌原告傷勢、雙方經濟能力等一切情節，認精神慰撫金以18萬元為適當。加上醫療費8萬、看護費4萬，合計30萬元，原告請求在此範圍內為有理由，應予准許；逾此部分之請求為無理由，應予駁回。
        """
        return dummy_jud_text

    def extract_factual_dossier(self, judgment_text):
        """
        透過 LLM (Gemini API) 客觀還原判決事實，保證無任何主觀想法與記者言論。
        """
        print("[LLM] 正在使用結構化 JSON 提取器解析裁判事實...")
        
        # 台灣繁體中文教學註解：
        # 為確保事實的100%客觀性，Prompt 中強烈要求 LLM 僅擷取判決書主文、事實與理由欄位中，
        # 法院所認定的客觀事實、爭點、法條與時間軸。不可加入任何「社論」、「大眾情緒」或「記者看法」。
        prompt = f"""
        你是一位極度客觀、不帶個人情緒的資深司法助理 AI。請閱讀下方裁判書，並嚴格遵循「100%基於客觀裁判事實，不得添加任何記者/AI的私自看法、推論或主觀形容詞」之原則，將其轉化為符合指定格式的 JSON 數據結構。

        【限制條件】
        1. 所有的 background, fullStory, reasoning 等欄位，必須完全採用客觀法庭認定語氣（例如：「法院認定...」、「原告主張...」、「被告抗辯...」）。
        2. 嚴禁使用誇張的社會新聞記者用語（例如：「可惡至極」、「狗血」、「悲痛欲絕」、「人神共憤」）。
        3. 如果判決書中沒有提到相關大法官意見或媒體文獻，相關欄位應返回空陣列。

        【裁判書主文】
        {judgment_text}

        【請輸出以下 JSON 結構】
        {{
          "id": "隨機或指定ID",
          "titleZh": "例如：王大德與李明華車禍損害賠償案",
          "year": 2023,
          "location": "台北市",
          "status": "判決確定",
          "category": "民事案件",
          "tags": ["交通車禍", "損害賠償", "侵權行為"],
          "memoryLine": "行人於穿越道被闖紅燈車輛撞擊之損害賠償認定。",
          "shortDescription": "被告因闖紅燈行經行人穿越道撞擊原告致傷，原告依法起訴請求醫療費及精神慰撫金，法院判定被告具完全過失折讓賠償。",
          "caseType": "民事訴訟",
          "procedureStage": "一審判決",
          "courtLevel": "臺灣台北地方法院",
          "updatedAt": "2023/06/15",
          "oneSentenceSummary": "行人於斑馬線遭闖紅燈撞傷起訴國賠，法院判賠30萬。",
          "background": "原告於過斑馬線時，遭被告駕駛之車輛闖紅燈撞擊倒地致脛骨骨折。",
          "fullStory": "原告王大德於111年12月1日行經台北市南京東路斑馬線，遭未注意車前狀況且闖紅燈之被告李明華開車撞擊，原告送醫住院10天。原告起訴請求醫療、看護費及慰撫金。法院經審查交通事故鑑定報告，認定被告違規屬實，原告行經行人穿越道具絕對優先權，最終判決被告應賠償30萬元。",
          "timeline": [
            {{"dateLabel": "2022/12/01", "title": "車禍事故發生", "description": "被告駕駛車輛於南京東路口闖紅燈撞擊原告。"}},
            {{"dateLabel": "2023/06/15", "title": "地院一審宣判", "description": "法院判決被告應給付原告30萬元。"}}
          ],
          "people": [
            {{"role": "原告", "description": "王大德，受害行人。"}},
            {{"role": "被告", "description": "李明華，肇事駕駛。"}}
          ],
          "legalIssues": [
            {{
              "title": "原告是否有過失相抵之適用？",
              "plainExplanation": "被告主張原告未注意來車具部分過失。法院認定原告行經行人穿越道有絕對路權，無過失。",
              "relationToCase": "判定被告須負100%賠償責任之依據。",
              "relatedLawIds": ["civ-217"]
            }}
          ],
          "investigationAndTrial": "地院經審查道路交通事故調查表、診斷書，確認被告闖紅燈為車禍肇事主因。",
          "courtReasoning": "法院指出行人穿越道為行人絕對路權保障範疇。被告闖紅燈撞擊行人，違規侵權行為明確，應負全部賠償責任。慰撫金部分依雙方資力調整為18萬合理。",
          "judgmentResult": "被告應給付原告30萬元，其餘原告之訴駁回。",
          "relatedLaws": [
            {{
              "lawName": "民法",
              "articleNumber": "第 184 條",
              "plainSummary": "因故意或過失，不法侵害他人之權利者，負損害賠償責任。",
              "relationToCase": "原告請求侵權行為損害賠償之法源基礎。"
            }}
          ],
          "relatedCases": [],
          "sources": [
            {{"title": "臺灣台北地方法院 112 年度訴字第 456 號民事判決", "sourceType": "judgement", "updatedAt": "2023/06/15"}}
          ]
        }}
        """

        # 這裡模擬 API 調用 Gemini / LLM 後的結構化輸出
        # 實際運作需引進 google.generativeai 模組並發送請求
        # 由於目前在測試環境，將生成確定無記者主觀論述的標準結構 JSON 作為展示
        simulated_json = {
          "id": "112-456",
          "titleZh": "王大德與李明華車禍損害賠償案",
          "titleEn": "Wang v. Li (Traffic Accident Damages)",
          "shortTitleZh": "王大德損賠案",
          "shortTitleEn": "Wang v. Li",
          "displayCode": "CRM-112-456",
          "year": 2023,
          "location": "台北市",
          "status": "判決確定",
          "category": "民事案件",
          "tags": ["交通車禍", "損害賠償", "侵權行為"],
          "memoryLine": "行人於穿越道被闖紅燈車輛撞擊之損害賠償認定。",
          "shortDescription": "被告因闖紅燈行經行人穿越道撞擊原告致傷，原告依法起訴請求醫療費及精神慰撫金，法院判定被告具完全過失折讓賠償。",
          "caseType": "民事訴訟",
          "procedureStage": "一審判決",
          "courtLevel": "臺灣台北地方法院",
          "updatedAt": "2023/06/15",
          "oneSentenceSummary": "行人於斑馬線遭闖紅燈撞傷起訴國賠，法院判賠30萬。",
          "background": "原告於過斑馬線時，遭被告駕駛之車輛闖紅燈撞擊倒地致脛骨骨折。",
          "fullStory": "原告王大德於111年12月1日行經台北市南京東路斑馬線，遭未注意車前狀況且闖紅燈之被告李明華開車撞擊，原告送醫住院10天。原告起訴請求醫療、看護費及慰撫金。法院經審查交通事故鑑定報告，認定被告違規屬實，原告行經行人穿越道具絕對優先權，最終判決被告應賠償30萬元。",
          "timeline": [
            {"dateLabel": "2022/12/01", "title": "車禍事故發生", "description": "被告駕駛車輛於南京東路口闖紅燈撞擊原告。"},
            {"dateLabel": "2023/06/15", "title": "地院一審宣判", "description": "法院判決被告應給付原告30萬元。"}
          ],
          "people": [
            {"role": "原告", "description": "王大德，受害行人。"},
            {"role": "被告", "description": "李明華，肇事駕駛。"}
          ],
          "legalIssues": [
            {
              "title": "原告是否有過失相抵之適用？",
              "plainExplanation": "被告主張原告未注意來車具部分過失。法院認定原告行經行人穿越道有絕對路權，無過失。",
              "relationToCase": "判定被告須負100%賠償責任之依據。",
              "relatedLawIds": ["civ-217"]
            }
          ],
          "investigationAndTrial": "地院經審查道路交通事故調查表、診斷書，確認被告闖紅燈為車禍肇事主因。",
          "courtReasoning": "法院指出行人穿越道為行人絕對路權保障範疇。被告闖紅燈撞擊行人，違規侵權行為明確，應負全部賠償責任。慰撫金部分依雙方資力調整為18萬合理。",
          "judgmentResult": "被告應給付原告30萬元，其餘原告之訴駁回。",
          "relatedLaws": [
            {
              "lawName": "民法",
              "articleNumber": "第 184 條",
              "plainSummary": "因故意或過失，不法侵害他人之權利者，負損害賠償責任。",
              "relationToCase": "原告請求侵權行為損害賠償之法源基礎。"
            }
          ],
          "relatedCases": [],
          "sources": [
            {"title": "臺灣台北地方法院 112 年度訴字第 456 號民事判決", "sourceType": "judgement", "updatedAt": "2023/06/15"}
          ]
        }
        return simulated_json

    def search_google_image_url(self, title):
        """
        為案例檢索客觀配圖，可對接 Custom Search API 獲取真實配圖 URL，
        這裡提供獲取機制並返回合法的公開影像連結。
        """
        print(f"[圖片] 檢索 google 相關案件配圖: {title}...")
        # 模擬圖片檢索結果
        return f"https://images.unsplash.com/photo-1589829545856-d10d557cf95f?auto=format&fit=crop&q=80&w=400"

    def run_pipeline(self):
        """
        啟動爬取 1000 新案數據管線，並導出至 JSON 目錄
        """
        # 第一步：檢索裁判書
        records = self.fetch_judgment_list(query_sys="V", query_kw="損害賠償", limit=10)
        
        extracted_dossiers = []
        for rec in records:
            raw_text = self.fetch_judgment_detail(rec["jud_id"])
            dossier_data = self.extract_factual_dossier(raw_text)
            
            # 加入配圖
            image_url = self.search_google_image_url(dossier_data["titleZh"])
            dossier_data["images"] = [{"url": image_url, "source": "網路搜尋配圖"}]
            
            # 寫入單獨的客觀事實 JSON 檔案中
            filename = f"case_{dossier_data['id']}.json"
            filepath = os.path.join(OUTPUT_JSON_DIR, filename)
            with open(filepath, 'w', encoding='utf-8') as f:
                json.dump(dossier_data, f, ensure_ascii=False, indent=2)
                
            extracted_dossiers.append(dossier_data)
            print(f"[儲存] 已成功儲存客觀事實卷宗 JSON: {filepath}")
            
        print(f"[完成] 爬取管線執行完畢。共輸出 {len(extracted_dossiers)} 個客觀裁判 JSON 檔案。")

def main():
    pipeline = JudicialYuanScraperPipeline()
    pipeline.run_pipeline()

if __name__ == "__main__":
    main()
