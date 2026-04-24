import 'package:flutter/material.dart';

/// 新版首頁常見法律問題入口資料。
///
/// 台灣繁體中文教學註解：
/// 這份資料只服務新版首頁，和舊首頁的 mock data 刻意分開，
/// 這樣未來替換成 API 時可以各自演進，不會互相牽連。
class HomeV2IssueItem {
  const HomeV2IssueItem({
    required this.label,
    required this.icon,
    required this.color,
  });

  final String label;
  final IconData icon;
  final Color color;
}

/// 新版首頁專題卡片資料。
class HomeV2TopicItem {
  const HomeV2TopicItem({
    required this.title,
    required this.subtitle,
    required this.color,
    required this.icon,
  });

  final String title;
  final String subtitle;
  final Color color;
  final IconData icon;
}

/// 新版首頁小任務的二選一資料。
///
/// 台灣繁體中文教學註解：
/// 首頁的小任務故意做成輕量版，只放短題目與二選一，
/// 完整四選一測驗則留給後續子頁面使用。
class HomeV2MissionItem {
  const HomeV2MissionItem({
    required this.question,
    required this.options,
    required this.correctIndex,
    required this.correctFeedback,
    required this.incorrectFeedback,
    required this.detailExplanation,
  });

  final String question;
  final List<String> options;
  final int correctIndex;
  final String correctFeedback;
  final String incorrectFeedback;
  final String detailExplanation;
}

const homeV2IssueItems = [
  HomeV2IssueItem(
    label: '租屋',
    icon: Icons.home_work_outlined,
    color: Color(0xFFE9F5EE),
  ),
  HomeV2IssueItem(
    label: '車禍',
    icon: Icons.directions_car_filled_outlined,
    color: Color(0xFFEAF3FF),
  ),
  HomeV2IssueItem(
    label: '勞資',
    icon: Icons.groups_2_outlined,
    color: Color(0xFFF0ECFF),
  ),
  HomeV2IssueItem(
    label: '消費',
    icon: Icons.storefront_outlined,
    color: Color(0xFFFFF1D1),
  ),
  HomeV2IssueItem(
    label: '法規查詢',
    icon: Icons.manage_search_rounded,
    color: Color(0xFFE8F3FF),
  ),
];

const homeV2MissionItems = [
  HomeV2MissionItem(
    question: '租屋押金，房東可以想扣就扣嗎？',
    options: ['可以', '不一定'],
    correctIndex: 1,
    correctFeedback: '押金是擔保，不是房東想扣就能扣。',
    incorrectFeedback: '押金是否能扣，還是要看契約和實際損害依據。',
    detailExplanation:
        '押金的功能是擔保租客履約，例如未付租金或造成損害時才可能依法扣抵。房東若要扣押金，仍需提出契約依據或實際損害，不是想扣就能扣。',
  ),
  HomeV2MissionItem(
    question: '網購商品有瑕疵，可以要求處理嗎？',
    options: ['可以', '不行'],
    correctIndex: 0,
    correctFeedback: '通常可以依契約與消保規範主張處理。',
    incorrectFeedback: '商品有瑕疵時，通常還是有修補、退換貨或減價空間。',
    detailExplanation:
        '商品有瑕疵時，消費者通常可以依契約關係與消費者保護規範，主張修補、減價、解除契約或退換貨。具體能主張到哪一步，還是要看瑕疵情況與交易條件。',
  ),
  HomeV2MissionItem(
    question: '被罵了，就一定能告成功嗎？',
    options: ['不一定', '一定可以'],
    correctIndex: 0,
    correctFeedback: '還要看內容、場合與是否真的構成侵權或犯罪。',
    incorrectFeedback: '不是每次被罵都一定成立，還要看具體情況。',
    detailExplanation:
        '是否能成立妨害名譽、侮辱或民事侵權，通常要看對方說了什麼、是在什麼場合說、是否足以損害名譽，以及能不能證明相關事實，不是只要被罵就一定告得成。',
  ),
  HomeV2MissionItem(
    question: '收到存證信函，就代表一定輸了嗎？',
    options: ['不一定', '是'],
    correctIndex: 0,
    correctFeedback: '存證信函只是主張權利，不等於判決結果。',
    incorrectFeedback: '收到存證信函不代表一定輸，還是要看內容與後續程序。',
    detailExplanation:
        '存證信函主要是用來留下通知或主張權利的紀錄，提醒對方某件事已經正式告知。它不等於法院判決，也不會因為收到就直接決定誰輸誰贏。',
  ),
  HomeV2MissionItem(
    question: '借朋友錢，口頭約定就完全沒效嗎？',
    options: ['不是', '對'],
    correctIndex: 0,
    correctFeedback: '口頭約定不一定無效，只是證明上比較辛苦。',
    incorrectFeedback: '口頭借款不一定無效，只是日後舉證會比較困難。',
    detailExplanation:
        '借款關係不一定要書面才成立，口頭約定也可能有效，但如果日後發生爭議，會更需要轉帳紀錄、對話紀錄或證人來協助證明。',
  ),
  HomeV2MissionItem(
    question: '拍到車禍現場影片，可以直接公開上網嗎？',
    options: ['不一定', '可以'],
    correctIndex: 0,
    correctFeedback: '還要考慮隱私、個資與公開方式。',
    incorrectFeedback: '事故影片不是想公開就公開，仍要注意個資與隱私。',
    detailExplanation:
        '即使影片是真的，也不代表可以毫無遮掩地公開，尤其若畫面能辨識當事人、車牌或其他個資時，仍要注意隱私、個人資料與散布方式帶來的法律風險。',
  ),
  HomeV2MissionItem(
    question: '撿到別人的錢包，只要沒花就沒事嗎？',
    options: ['不是', '是'],
    correctIndex: 0,
    correctFeedback: '撿到遺失物仍有通報或送交義務。',
    incorrectFeedback: '就算沒花，若不處理遺失物，也可能有法律問題。',
    detailExplanation:
        '撿到遺失物後，通常仍應盡快交給警察、相關管理單位或設法通知失主。重點不只是有沒有使用，而是是否依法處理他人遺失的財物。',
  ),
  HomeV2MissionItem(
    question: '公司叫你加班，就一定不能拒絕嗎？',
    options: ['不一定', '不能拒絕'],
    correctIndex: 0,
    correctFeedback: '還要看勞動契約、法令和實際安排是否合理。',
    incorrectFeedback: '加班並不是公司說了就算，還是有勞基法規範。',
    detailExplanation:
        '雇主要求加班仍需符合勞基法與相關規定，例如工時上限、加班費、程序與特殊情況。員工是否必須配合，也要看契約內容與實際工作情境。',
  ),
  HomeV2MissionItem(
    question: '網路留言只要刪掉，就一定不會被追究嗎？',
    options: ['不一定', '會'],
    correctIndex: 0,
    correctFeedback: '刪掉不代表痕跡不存在，也不一定免責。',
    incorrectFeedback: '留言刪除後仍可能留下截圖或平台紀錄。',
    detailExplanation:
        '即使留言刪掉了，也可能早已被截圖、備份，或仍留有平台紀錄。是否會被追究，還是要看留言內容、影響程度和證據是否存在。',
  ),
  HomeV2MissionItem(
    question: '租約沒寫修繕責任，房東就一定不用修嗎？',
    options: ['不一定', '對'],
    correctIndex: 0,
    correctFeedback: '不是沒寫就沒有責任，還要看法律與損壞原因。',
    incorrectFeedback: '即使租約沒寫，也不代表房東完全不用負責。',
    detailExplanation:
        '修繕責任不一定全靠租約一句話決定，還要看法律規定、損壞成因以及是否屬於房屋基本設備。不同情況下，出租人與承租人的責任可能不同。',
  ),
];

const homeV2TopicItems = [
  HomeV2TopicItem(
    title: '租屋押金專題',
    subtitle: '契約、修繕、點交',
    color: Color(0xFFE9F5EE),
    icon: Icons.home_work_outlined,
  ),
  HomeV2TopicItem(
    title: '車禍責任專題',
    subtitle: '肇責、賠償、調解',
    color: Color(0xFFEAF3FF),
    icon: Icons.directions_car_outlined,
  ),
  HomeV2TopicItem(
    title: '詐騙自保專題',
    subtitle: '報案、金流、求償',
    color: Color(0xFFFFF1D1),
    icon: Icons.security_rounded,
  ),
];
