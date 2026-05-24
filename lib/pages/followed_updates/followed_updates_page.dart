import 'package:flutter/material.dart';
import 'package:lawapp/app/app_state.dart';
import 'package:lawapp/components/search/search_page_layout.dart';
import 'package:lawapp/data/mock_data/cases/case_story_mock_data.dart';
import 'package:lawapp/data/mock_data/followed_updates/followed_updates_mock_data.dart';
import 'package:lawapp/pages/journal/case_story_detail_page.dart';

/// 追蹤頁展示「我已追蹤」主題的最新整理與更新。
class FollowedUpdatesPage extends StatefulWidget {
  const FollowedUpdatesPage({super.key});

  @override
  State<FollowedUpdatesPage> createState() => _FollowedUpdatesPageState();
}

class _FollowedUpdatesPageState extends State<FollowedUpdatesPage> {
  final TextEditingController controller = TextEditingController();

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appState = LawAppScope.of(context);
    final savedCases = caseStoryItems
        .where((item) => appState.isCaseSaved(item.storageId))
        .toList(growable: false);

    return SearchPageLayout(
      controller: controller,
      hintText: '搜尋追蹤主題、Hashtag',
      headerTitle: '我的關注更新',
      headerSubtitle: '只顯示你追蹤的主題、案件、法條與 hashtag 更新，不混入全站熱門內容。',
      headerTitleSize: 26,
      builder: (context, layout, contentTopPadding, contentBottomPadding) {
        // 台灣繁體中文教學註解：
        // 案件詳情頁的收藏先落在 LawAppState 本機狀態；這裡同步讀同一份狀態，
        // 讓「收藏」不只是在詳情頁亮燈，也能回到會員入口被重新打開。
        return ListView(
          padding: EdgeInsets.fromLTRB(
            16,
            contentTopPadding,
            16,
            contentBottomPadding,
          ),
          children: [
            if (savedCases.isNotEmpty) ...[
              const _FollowedSectionTitle(title: '本機收藏案件'),
              const SizedBox(height: 10),
              ...savedCases.map(
                (item) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _SavedCaseFollowCard(item: item),
                ),
              ),
              const SizedBox(height: 4),
            ],
            if (appState.canTrackTopics) ...[
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: notificationFilterLabels
                    .map(
                      (label) => Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEAF0F8),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          label,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF31486F),
                          ),
                        ),
                      ),
                    )
                    .toList(),
              ),
              const SizedBox(height: 16),
              ...trackedTopicItems.map(
                (item) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: const Color(0xFFE5E7EB)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFEAF0F8),
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Text(
                            item.tag,
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF31486F),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          item.title,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          item.summary,
                          style: const TextStyle(
                            fontSize: 14,
                            height: 1.5,
                            color: Color(0xFF667085),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ] else
              const _FollowedLockedCard(),
          ],
        );
      },
    );
  }
}

class _FollowedSectionTitle extends StatelessWidget {
  const _FollowedSectionTitle({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w900,
        color: Color(0xFF101828),
      ),
    );
  }
}

class _SavedCaseFollowCard extends StatelessWidget {
  const _SavedCaseFollowCard({required this.item});

  final CaseStoryItem item;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => CaseStoryDetailPage(item: item),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: const Color(0xFFE5E7EB)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.star_rounded,
                  size: 18,
                  color: Color(0xFFD6A85F),
                ),
                const SizedBox(width: 6),
                Text(
                  item.statusLabel,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF667085),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              item.title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w900,
                color: Color(0xFF101828),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              item.oneSentenceConclusion,
              style: const TextStyle(
                fontSize: 13,
                height: 1.45,
                color: Color(0xFF667085),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FollowedLockedCard extends StatelessWidget {
  const _FollowedLockedCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.lock_outline_rounded, color: Color(0xFFD6A85F)),
          SizedBox(height: 10),
          Text(
            '登入後可以追蹤主題',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
          ),
          SizedBox(height: 8),
          Text(
            '訪客可以瀏覽公開內容；登入後會開啟法條、案件、Hashtag 與 AI 對話追蹤。',
            style: TextStyle(
              fontSize: 14,
              height: 1.5,
              color: Color(0xFF667085),
            ),
          ),
        ],
      ),
    );
  }
}
