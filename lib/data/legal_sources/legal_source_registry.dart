import 'package:flutter/material.dart';

enum LegalSourceStatus {
  connected,
  credentialRequired,
  planned,
}

class LegalSourceEntry {
  const LegalSourceEntry({
    required this.title,
    required this.owner,
    required this.description,
    required this.endpointLabel,
    required this.url,
    required this.status,
    required this.icon,
  });

  final String title;
  final String owner;
  final String description;
  final String endpointLabel;
  final String url;
  final LegalSourceStatus status;
  final IconData icon;

  String get statusLabel {
    switch (status) {
      case LegalSourceStatus.connected:
        return '已可串接';
      case LegalSourceStatus.credentialRequired:
        return '需後端憑證';
      case LegalSourceStatus.planned:
        return '已預留';
    }
  }
}

/// 法律資料來源登錄表。
///
/// App 裡所有「資料來源」說明先集中在這裡，UI 只負責呈現。
/// 未來若要新增中國、香港、美國、日本資料源，建議先補這份 registry，
/// 再實作各自的 service，避免資料來源散在不同頁面難以稽核。
const legalSourceEntries = [
  LegalSourceEntry(
    title: '全國法規資料庫',
    owner: '法務部',
    description: '提供台灣現行法律與命令資料，法條頁已直接讀取中文法律與命令 JSON。',
    endpointLabel: '/api/ch/law/json、/api/ch/order/json',
    url: 'https://law.moj.gov.tw/',
    status: LegalSourceStatus.connected,
    icon: Icons.account_balance_rounded,
  ),
  LegalSourceEntry(
    title: '司法院裁判書開放資料',
    owner: '司法院',
    description: '提供裁判書異動清單與全文。需平台帳密換 token 且限凌晨服務，正式產品應由後端排程同步，不建議前端爬裁判書網頁。',
    endpointLabel: 'Auth、JList、JDoc/{jid}',
    url: 'https://opendata.judicial.gov.tw/',
    status: LegalSourceStatus.credentialRequired,
    icon: Icons.gavel_rounded,
  ),
  LegalSourceEntry(
    title: 'AI/RAG 法律助理後端',
    owner: 'MylawApp backend',
    description: 'Flutter 端只呼叫後端 proxy；API key、檢索索引與模型選擇都留在後端。',
    endpointLabel: 'PREAMBLE_API_BASE_URL',
    url: 'https://example.com/preamble-api-contract',
    status: LegalSourceStatus.planned,
    icon: Icons.hub_rounded,
  ),
  LegalSourceEntry(
    title: '跨國法律資料源',
    owner: '待接各國官方來源',
    description: '中國、香港、美國、日本資料先在產品層預留國別與來源欄位，待正式 API 後接入。',
    endpointLabel: 'country-aware legal source adapters',
    url: 'https://data.gov.tw/',
    status: LegalSourceStatus.planned,
    icon: Icons.public_rounded,
  ),
];
