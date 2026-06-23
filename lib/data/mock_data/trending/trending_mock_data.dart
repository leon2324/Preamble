/// 紀事頁使用的社會案件與爭點假資料。
class HotTopicItem {
  const HotTopicItem({
    required this.title,
    required this.summary,
    required this.tags,
  });

  final String title;
  final String summary;
  final List<String> tags;
}

const hotTopicItems = [
  HotTopicItem(
    title: '即將釋憲，究竟廢死還是維持死刑？',
    summary: '近期因定讞待執行死刑槍決的 37 名囚犯提起死刑釋憲，讓支持與反對立場再次升溫。',
    tags: ['#刑法', '#死刑', '#人權', '#憲法釋憲'],
  ),
  HotTopicItem(
    title: '詐騙集團橫行，政府擬強化金融監管',
    summary: '金流、帳戶監管與責任歸屬成為最近新聞與留言區最常被提起的焦點。',
    tags: ['#詐騙', '#金流', '#金融監管'],
  ),
];
