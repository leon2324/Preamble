import 'package:flutter/material.dart';
import 'package:lawapp/components/search/search_page_layout.dart';
import 'package:lawapp/data/notifications_mock_data.dart';

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
    return SearchPageLayout(
      controller: controller,
      hintText: '搜尋追蹤主題、Hashtag',
      headerTitle: '我的關注更新',
      headerSubtitle: '只顯示你追蹤的主題、案件、法條與 hashtag 更新，不混入全站熱門內容。',
      headerTitleSize: 26,
      builder: (context, layout, contentTopPadding, contentBottomPadding) =>
          ListView(
        padding: EdgeInsets.fromLTRB(
          16,
          contentTopPadding,
          16,
          contentBottomPadding,
        ),
        children: [
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
        ],
      ),
    );
  }
}
