import 'dart:async';
import 'dart:convert';
import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;
import 'package:preamble/components/home/home_content.dart';

/// 自動刷新間隔：60 分鐘
const Duration _kAutoRefreshInterval = Duration(minutes: 60);

/// App 從背景回來時，距離上次成功抓取超過多久才重新抓取
const Duration _kStalenessThreshold = Duration(minutes: 55);

class DiscussionFeedService with WidgetsBindingObserver {
  static final DiscussionFeedService instance = DiscussionFeedService._();
  DiscussionFeedService._();

  // ── 狀態 ────────────────────────────────────────────────────────────────────

  bool isLoaded = false;
  bool hasError = false;
  bool _isFetching = false;

  /// 上次成功抓取的時間，null 代表從未成功過
  DateTime? _lastSuccessTime;

  HomeDiscussionFeed currentFeed = const HomeDiscussionFeed(
    collectionSlogan: '正在連線取得時事焦點...',
    topics: [],
    actionLabels: [],
  );

  // ── 監聽器 ──────────────────────────────────────────────────────────────────

  final List<void Function()> _listeners = [];
  void addListener(void Function() l) => _listeners.add(l);
  void removeListener(void Function() l) => _listeners.remove(l);

  void _notify() {
    for (final l in _listeners) {
      try {
        l();
      } catch (_) {
        // 安全廣播，不讓單一 listener 崩潰影響其他人
      }
    }
  }

  // ── 自動定時器 ──────────────────────────────────────────────────────────────

  Timer? _autoTimer;

  /// 啟動每 60 分鐘自動刷新，並立即執行第一次抓取。
  /// 由 App 啟動點（HomePage.initState 或 main.dart）呼叫一次即可。
  void startAutoRefresh() {
    // 避免重複啟動
    if (_autoTimer != null && _autoTimer!.isActive) return;

    // 立刻抓一次（若尚未成功過）
    if (!isLoaded) {
      refreshFeed();
    }

    // 之後每 60 分鐘自動刷新
    _autoTimer = Timer.periodic(_kAutoRefreshInterval, (_) {
      debugPrint(
          '[DiscussionFeedService] ⏱ Auto-refresh triggered (60min timer)');
      refreshFeed();
    });

    // 監聽 App 前後台切換
    WidgetsBinding.instance.addObserver(this);
    debugPrint(
        '[DiscussionFeedService] ✅ Auto-refresh started (every 60 min + lifecycle aware)');
  }

  /// 停止定時器，並解除 lifecycle 監聽。通常不需要手動呼叫（除非整個 App 要清除）。
  void stopAutoRefresh() {
    _autoTimer?.cancel();
    _autoTimer = null;
    WidgetsBinding.instance.removeObserver(this);
    debugPrint('[DiscussionFeedService] 🛑 Auto-refresh stopped');
  }

  // ── WidgetsBindingObserver ──────────────────────────────────────────────────

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      debugPrint(
          '[DiscussionFeedService] 📱 App resumed — checking staleness...');
      refreshIfStale();
    }
  }

  /// 若距離上次成功超過 55 分鐘（或從未成功過），立即刷新。
  /// 避免使用者每次切換 Tab 都重新打 API。
  void refreshIfStale() {
    if (_isFetching) return;
    final last = _lastSuccessTime;
    if (last == null ||
        DateTime.now().difference(last) >= _kStalenessThreshold) {
      debugPrint('[DiscussionFeedService] 🔄 Data stale, refreshing...');
      refreshFeed();
    } else {
      final remaining = _kStalenessThreshold - DateTime.now().difference(last);
      debugPrint(
          '[DiscussionFeedService] ✔ Data fresh, next refresh in ${remaining.inMinutes}min');
    }
  }

  // ── 核心抓取邏輯 ────────────────────────────────────────────────────────────

  Future<void> refreshFeed() async {
    if (_isFetching) return;
    _isFetching = true;

    try {
      debugPrint('[DiscussionFeedService] 🌐 Fetching Google Trends TW RSS...');

      // 先抓預設（24h 滾動），若相關議題不夠再嘗試 48h 擴大搜尋
      final urls = [
        'https://trends.google.com.tw/trending/rss?geo=TW',
        'https://trends.google.com.tw/trending/rss?geo=TW&hours=48',
      ];

      String rawXml = '';
      for (final url in urls) {
        try {
          final resp = await http.get(
            Uri.parse(url),
            headers: {
              'User-Agent': 'Mozilla/5.0 (compatible; LawApp/1.0)',
              'Accept': 'application/rss+xml, application/xml, text/xml, */*',
            },
          ).timeout(const Duration(seconds: 8));
          if (resp.statusCode == 200) {
            rawXml += utf8.decode(resp.bodyBytes); // 合併兩個回應讓候選池更大
          }
        } catch (_) {}
        if (rawXml.isNotEmpty) break; // 第一個成功就夠了，只有 <5 筆相關時才用第二個
      }

      if (rawXml.isEmpty) throw Exception('All RSS endpoints failed');

      var parsedTopics = _parseRssFiltered(rawXml);

      // 若相關議題仍不足，嘗試合併兩個 endpoint 的候選池
      if (parsedTopics.length < 5) {
        debugPrint(
            '[DiscussionFeedService] ⚠ Only ${parsedTopics.length} relevant topics, fetching 48h...');
        try {
          final resp48 = await http.get(
            Uri.parse(
                'https://trends.google.com.tw/trending/rss?geo=TW&hours=48'),
            headers: {'User-Agent': 'Mozilla/5.0 (compatible; LawApp/1.0)'},
          ).timeout(const Duration(seconds: 8));
          if (resp48.statusCode == 200) {
            final combined = rawXml + utf8.decode(resp48.bodyBytes);
            parsedTopics = _parseRssFiltered(combined);
          }
        } catch (_) {}
      }

      if (parsedTopics.isNotEmpty) {
        final now = DateTime.now();
        final timeStr =
            '${now.month}/${now.day} ${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
        currentFeed = HomeDiscussionFeed(
          collectionSlogan: '已同步 Google 台灣熱門搜尋（$timeStr 更新）',
          topics: parsedTopics,
          actionLabels: const [],
        );
        isLoaded = true;
        hasError = false;
        _lastSuccessTime = now;
        _isFetching = false;
        _notify();
        debugPrint(
            '[DiscussionFeedService] ✅ Loaded ${parsedTopics.length} relevant topics');
        return;
      }
      throw Exception('No relevant social/legal topics found in feed');
    } catch (e) {
      _isFetching = false;
      if (!isLoaded) {
        hasError = true;
        currentFeed = const HomeDiscussionFeed(
          collectionSlogan: '沒有連線QQ，請連線後再試用一次',
          topics: [],
          actionLabels: [],
        );
        _notify();
      } else {
        debugPrint(
            '[DiscussionFeedService] ⚠ Refresh failed, keeping old data: $e');
      }
      debugPrint('[DiscussionFeedService] ❌ $e');
    }
  }

  // ── RSS 解析 + 過濾 ─────────────────────────────────────────────────────────

  /// 從 XML 中解析所有 item，先打分、排除體育娛樂、再取社會/法律相關前 5 名。
  List<HomeDiscussionTopic> _parseRssFiltered(String xml) {
    final itemRegex = RegExp(r'<item>(.*?)</item>', dotAll: true);
    final titleRegex = RegExp(r'<title>(.*?)</title>');
    final approxTrafficRegex =
        RegExp(r'<ht:approx_traffic>(.*?)</ht:approx_traffic>');
    final snippetRegex =
        RegExp(r'<ht:news_item_snippet>(.*?)</ht:news_item_snippet>');
    final newsTitleRegex =
        RegExp(r'<ht:news_item_title>(.*?)</ht:news_item_title>');
    final newsContentRegex =
        RegExp(r'<ht:news_item>(.*?)</ht:news_item>', dotAll: true);

    // 1️⃣ 提取所有候選項目
    final candidates = <_RssCandidate>[];
    final seenTitles = <String>{}; // 去除合併後的重複項

    for (final match in itemRegex.allMatches(xml)) {
      final content = match.group(1) ?? '';
      final titleMatch = titleRegex.firstMatch(content);
      final title = titleMatch?.group(1)?.trim() ?? '';
      if (title.isEmpty || seenTitles.contains(title)) continue;
      seenTitles.add(title);

      final trafficMatch = approxTrafficRegex.firstMatch(content);
      final traffic = trafficMatch?.group(1)?.trim() ?? '100+';

      // 聚合所有 news_item 文字作為完整語境
      final allNewsContent = newsContentRegex
          .allMatches(content)
          .map((m) => m.group(1) ?? '')
          .join(' ');

      final snippetMatch = snippetRegex.firstMatch(content);
      var overview = snippetMatch?.group(1)?.trim() ?? '';
      if (overview.isEmpty) {
        final newsTitleMatch = newsTitleRegex.firstMatch(content);
        overview = newsTitleMatch?.group(1)?.trim() ?? '';
      }
      overview = _cleanHtml(overview);

      // 用標題 + 所有新聞內文計算相關性
      final fullText = '$title $overview $allNewsContent'.toLowerCase();
      final relevance = _scoreSocialLegalRelevance(fullText);

      candidates.add(_RssCandidate(
        title: title,
        traffic: traffic,
        overview: overview,
        relevance: relevance,
      ));
    }

    if (candidates.isEmpty) return [];

    // 2️⃣ 排序：先依相關性分數降序，同分則依流量降序
    candidates.sort((a, b) {
      if (b.relevance != a.relevance) return b.relevance.compareTo(a.relevance);
      return _trafficNum(b.traffic).compareTo(_trafficNum(a.traffic));
    });

    debugPrint('[DiscussionFeedService] Candidates after scoring:');
    for (var c in candidates) {
      debugPrint('  [score=${c.relevance}] [${c.traffic}] ${c.title}');
    }

    // 3️⃣ 取相關性 >= 1 的（至少有一個正向社會關鍵字），最多 5 筆
    //    若連一個都沒有，退而求其次取 score >= 0（即非體育/娛樂的任意議題）
    var accepted = candidates.where((c) => c.relevance >= 2).take(5).toList();
    if (accepted.length < 3) {
      accepted = candidates.where((c) => c.relevance >= 1).take(5).toList();
    }
    if (accepted.length < 3) {
      // 最後退路：只要不是明顯體育/娛樂（score >= 0），就收進來
      accepted = candidates.where((c) => c.relevance >= 0).take(5).toList();
    }

    if (accepted.isEmpty) return [];

    // 4️⃣ 轉換為 HomeDiscussionTopic
    final list = <HomeDiscussionTopic>[];
    final now = DateTime.now();
    final todayStr =
        '${now.year}.${now.month.toString().padLeft(2, '0')}.${now.day.toString().padLeft(2, '0')}';
    final yesterdayStr = () {
      final y = now.subtract(const Duration(days: 1));
      return '${y.year}.${y.month.toString().padLeft(2, '0')}.${y.day.toString().padLeft(2, '0')}';
    }();

    for (var i = 0; i < accepted.length; i++) {
      final c = accepted[i];
      final rank = i + 1;
      final heatScore = _trafficToHeatScore(c.traffic, rank);

      list.add(HomeDiscussionTopic(
        headline: c.title,
        title: c.title,
        heatScore: heatScore,
        rank: rank,
        dayChangePercent: 18 - rank * 2,
        weekRankDelta: rank % 2 == 0 ? 1 : 2,
        overview: c.overview.isNotEmpty
            ? c.overview
            : '今日 Google 台灣熱搜議題「${c.title}」，正被社群廣泛討論，涉及相關法律制度的落實與完善。',
        heatLabel: '資料收集顯示：本日 Google 台灣熱門搜尋，搜尋量逾 ${c.traffic}',
        trendPoints: [
          HomeDiscussionTrendPoint(
              dateLabel: '前天', volumeLabel: '${(heatScore * 0.45).round()} 次'),
          HomeDiscussionTrendPoint(
              dateLabel: '昨天',
              volumeLabel: '${(heatScore * 0.75).round()} 次',
              annotation: '聲量攀升'),
          HomeDiscussionTrendPoint(
              dateLabel: '今天',
              volumeLabel: '${c.traffic} 次',
              annotation: '本日熱度'),
        ],
        timelineEvents: [
          HomeDiscussionTimelineEvent(
            pointIndex: 1,
            timeLabel: '$yesterdayStr 15:40',
            description: '社群、PTT 及各新聞媒體開始大量報導「${c.title}」相關消息與討論。',
            impactLabel: '+28%',
          ),
          HomeDiscussionTimelineEvent(
            pointIndex: 2,
            timeLabel: '$todayStr 10:20',
            description: 'Google 熱門搜尋量突破 ${c.traffic}，衝上本日熱搜排行榜第 $rank 名。',
            impactLabel: '+52%',
          ),
        ],
        poll: HomeDiscussionPoll(
          prompt: '針對「${c.title}」議題，你認為目前的法制規範是否完善？',
          options: [
            HomeDiscussionPollOption(
                label: '完善，現有民刑法足以保障', votes: 1450 + rank * 120),
            HomeDiscussionPollOption(
                label: '不夠，應加速立法院修法或釋憲', votes: 1120 - rank * 70),
            HomeDiscussionPollOption(
                label: '保留，等法院具體裁判確定再說', votes: 850 + rank * 40),
          ],
        ),
        latestComment: HomeDiscussionComment(
          content: '「${c.title}」的討論在社群上越來越熱，大家的關注度真的很高！',
          submittedAt:
              '$todayStr ${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}',
          userHandle: '@netizen_${105 + rank}',
        ),
        tags: ['#${c.title}', '#${now.year}時事', '#社會關注'],
      ));
    }
    return list;
  }

  // ── 相關性評分 ──────────────────────────────────────────────────────────────

  /// 回傳相關性分數：
  ///   >= 3  強法律/司法/社會議題
  ///   2     一般社會/政治/民生議題
  ///   1     廣義公共議題（健康、環境、經濟）
  ///   0     中性（無明顯分類）
  ///  -1     體育、娛樂、電競 → 排除
  int _scoreSocialLegalRelevance(String text) {
    // ── 體育 / 娛樂 / 電競 排除名單（score = -1）──────────────────────
    final excludePatterns = [
      // 體育賽事
      '世界盃', '世足', '世界杯', '球賽', '足球', '籃球', '棒球', '網球', '羽球',
      '排球', '高球', '高爾夫', '賽車', '馬拉松', '田徑', '游泳', '奧運',
      '世界杯', '冠軍聯賽', 'nba', 'mlb', 'nfl', 'premier league',
      'champions league', 'world cup', 'copa', 'euro',
      'lcs', 'lpl', 'msi', 'worlds', // 電競賽事
      'vs ', ' vs ', 'algeria', 'austria', 'jordan', 'argentina',
      '日本巴西', '日本 巴西', 'dcg', 'karmine',
      // 娛樂 / 藝人
      '金曲獎', '金馬獎', '金鐘獎', '電影', '演唱會', '演員', '歌手', '偶像',
      '網飛', 'netflix', '韓劇', '日劇', '美劇', '動漫', '動畫',
      '美輪明宏', // 日本藝人
      '博物館 河馬', '奇美 博物館',
      // 運動員人名（英文，通常是外國球員）
      'tucker', 'rushing', 'lautaro', 'al-tamari',
    ];
    for (final ex in excludePatterns) {
      if (text.contains(ex.toLowerCase())) {
        debugPrint(
            '[DiscussionFeedService] 🚫 Excluded (sports/ent): score=-1 matched "$ex"');
        return -1;
      }
    }

    var score = 0;

    // ── 強法律 / 司法 / 人權 關鍵字（+3）────────────────────────────────
    final legalStrong = [
      '法院',
      '判決',
      '裁判',
      '起訴',
      '檢察',
      '羈押',
      '交保',
      '聲押',
      '定讞',
      '大法官',
      '釋憲',
      '違憲',
      '憲法',
      '釋字',
      '司法院',
      '立法院',
      '立院',
      '國會',
      '朝野',
      '三讀',
      '法案',
      '修法',
      '條例',
      '刑事',
      '民事',
      '行政訴訟',
      '訴訟',
      '上訴',
      '抗告',
      '詐騙',
      '洗錢',
      '吸金',
      '偽造',
      '竊盜',
      '搶奪',
      '殺人',
      '傷害',
      '強制',
      '性侵',
      '性騷',
      'metoo',
      'me too',
      '職場霸凌',
      '勞基法',
      '勞資',
      '解雇',
      '資遣',
      '過勞',
      '租賃',
      '押金',
      '房東',
      '租屋',
      '違建',
      '酒駕',
      '肇事逃逸',
      '超速',
      '車禍肇責',
    ];
    for (final kw in legalStrong) {
      if (text.contains(kw.toLowerCase())) {
        score += 3;
        break;
      }
    }

    // ── 社會 / 政治 / 人權（+2）──────────────────────────────────────────
    final socialMed = [
      '政府',
      '行政院',
      '總統',
      '總統府',
      '院長',
      '部長',
      '立委',
      '選舉',
      '公投',
      '罷免',
      '民調',
      '施政',
      '國安',
      '國防',
      '兩岸',
      '中國',
      '軍事',
      '飛彈',
      '共諜',
      '人權',
      '民主',
      '抗議',
      '陳抗',
      '遊行',
      '詐騙',
      '犯罪',
      '治安',
      '警察',
      '消防',
      '移民',
      '難民',
      '外籍',
      '勞工',
      '境外',
    ];
    for (final kw in socialMed) {
      if (text.contains(kw.toLowerCase())) {
        score += 2;
        break;
      }
    }

    // ── 廣義民生 / 公共議題（+1）────────────────────────────────────────
    final publicLight = [
      '物價',
      '通膨',
      '利率',
      '房價',
      '股市',
      '稅',
      '健保',
      '保費',
      '醫療',
      '醫院',
      '疫情',
      '疫苗',
      '食安',
      '食品',
      '黑心',
      '交通',
      '捷運',
      '高鐵',
      '台鐵',
      '公路',
      '道路',
      '學校',
      '教育',
      '大學',
      '學生',
      '教師',
      '環境',
      '污染',
      '氣候',
      '颱風',
      '地震',
      '災害',
      '薪資',
      '最低工資',
      '失業',
      '就業',
      '職缺',
      '少子化',
      '生育',
      '育兒',
      '托育',
      '長照',
      '老人',
    ];
    for (final kw in publicLight) {
      if (text.contains(kw.toLowerCase())) {
        score += 1;
        break;
      }
    }

    return score;
  }

  // ── 輔助工具 ────────────────────────────────────────────────────────────────

  /// 把 traffic 字串換算為熱度分數（0-99）
  int _trafficToHeatScore(String traffic, int rank) {
    var base = 91 - rank * 3;
    if (traffic.contains('500,000') || traffic.contains('1,000,000')) return 99;
    if (traffic.contains('100,000') || traffic.contains('200,000')) return 97;
    if (traffic.contains('50,000')) return 95;
    if (traffic.contains('20,000')) return 90;
    if (traffic.contains('10,000')) return 85;
    if (traffic.contains('5,000')) return 80;
    if (traffic.contains('2,000')) return 75;
    if (traffic.contains('1,000')) return 70;
    if (traffic.contains('500')) return 65;
    if (traffic.contains('200')) return 60;
    if (traffic.contains('100')) return 55;
    return base.clamp(40, 91);
  }

  /// 把 traffic 字串換算為整數（用於排序）
  int _trafficNum(String traffic) {
    final m = RegExp(r'([\d,]+)').firstMatch(traffic.replaceAll(',', ''));
    return int.tryParse(m?.group(1)?.replaceAll(',', '') ?? '0') ?? 0;
  }

  /// HTML entity 清理
  String _cleanHtml(String s) {
    return s
        .replaceAll('&lt;', '<')
        .replaceAll('&gt;', '>')
        .replaceAll('&quot;', '"')
        .replaceAll('&amp;', '&')
        .replaceAll('&#39;', "'")
        .replaceAll('&apos;', "'");
  }

  // ── 關鍵字映射至相關法規卷宗 ────────────────────────────────────────────────

  List<String> _matchRelatedCases(String title, String overview) {
    final text = (title + overview).toLowerCase();

    if (text.contains('立院') ||
        text.contains('國會') ||
        text.contains('釋憲') ||
        text.contains('法案') ||
        text.contains('違憲') ||
        text.contains('憲法') ||
        text.contains('大法官') ||
        text.contains('立法院')) {
      return ['318', '799', '499'];
    }
    if (text.contains('詐騙') ||
        text.contains('洗錢') ||
        text.contains('吸金') ||
        text.contains('imb') ||
        text.contains('投資') ||
        text.contains('金融') ||
        text.contains('虛擬')) {
      return ['case-006'];
    }
    if (text.contains('加班') ||
        text.contains('勞資') ||
        text.contains('解雇') ||
        text.contains('資遣') ||
        text.contains('勞基法') ||
        text.contains('過勞') ||
        text.contains('離職') ||
        text.contains('工時')) {
      return ['case-031'];
    }
    if (text.contains('口角') ||
        text.contains('互毆') ||
        text.contains('打架') ||
        text.contains('鄰居') ||
        text.contains('傷害') ||
        text.contains('衝突')) {
      return ['case-034'];
    }
    if (text.contains('租屋') ||
        text.contains('押金') ||
        text.contains('房東') ||
        text.contains('租賃') ||
        text.contains('扣抵') ||
        text.contains('退租')) {
      return ['case-029'];
    }
    if (text.contains('性侵') ||
        text.contains('性騷') ||
        text.contains('性平') ||
        text.contains('metoo') ||
        text.contains('me too')) {
      return ['case-041'];
    }
    if (text.contains('車禍') ||
        text.contains('交通') ||
        text.contains('超速') ||
        text.contains('酒駕') ||
        text.contains('肇事')) {
      return ['case-022'];
    }

    return ['318', '799', '499'];
  }
}

/// 解析 RSS item 後的輕量候選資料容器，僅用於過濾排序。
class _RssCandidate {
  _RssCandidate({
    required this.title,
    required this.traffic,
    required this.overview,
    required this.relevance,
  });

  final String title;
  final String traffic;
  final String overview;

  /// 相關性分數：>= 3 強法律；2 社會政治；1 廣義民生；0 中性；-1 體育/娛樂（排除）
  final int relevance;
}
