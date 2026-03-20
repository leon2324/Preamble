class TrackedTopicItem {
  const TrackedTopicItem({
    required this.tag,
    required this.title,
    required this.summary,
  });

  final String tag;
  final String title;
  final String summary;
}

const trackedTopicItems = [
  TrackedTopicItem(
    tag: '#財劃法',
    title: '財劃法',
    summary: '今天新增 6 則新聞、12 則討論與 1 則法律整理。',
  ),
  TrackedTopicItem(
    tag: '#詐騙',
    title: '詐騙集團橫行',
    summary: '你追蹤的反詐主題最近 24 小時熱度升高。',
  ),
  TrackedTopicItem(
    tag: '#勞基法',
    title: '《勞基法》第32條修正',
    summary: '有新的條文解讀與熱門留言可查看。',
  ),
];

const notificationFilterLabels = ['案件', '法律', '追蹤中'];
