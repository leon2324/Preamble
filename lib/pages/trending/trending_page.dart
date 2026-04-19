import 'package:flutter/material.dart';
import 'package:lawapp/components/home/home_content.dart';
import 'package:lawapp/components/search/search_page_layout.dart';
import 'package:lawapp/components/shared/page_section_header.dart';
import 'package:lawapp/data/mock_data/home/home_mock_data.dart';
import 'package:lawapp/data/mock_data/trending/trending_mock_data.dart';

/// 紀事頁把社會案件與相關爭點拆成較完整的清單版本。
class TrendingPage extends StatefulWidget {
  const TrendingPage({super.key});

  @override
  State<TrendingPage> createState() => _TrendingPageState();
}

class _TrendingPageState extends State<TrendingPage> {
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
      hintText: '搜尋社會案件、爭點、人物...',
      headerTitle: '紀事',
      headerSubtitle: '整理過往社會案件的脈絡、爭點與後續討論。',
      builder: (context, layout, contentTopPadding, contentBottomPadding) =>
          ListView(
        padding: EdgeInsets.fromLTRB(
          16,
          contentTopPadding,
          16,
          contentBottomPadding,
        ),
        children: [
          ...List.generate(homeNewsItems.length, (index) {
            final item = homeNewsItems[index];
            return Padding(
              padding: EdgeInsets.only(
                bottom: index == homeNewsItems.length - 1 ? 0 : 12,
              ),
              child: _NewsListCard(item: item),
            );
          }),
          const SizedBox(height: 28),
          const PageSectionHeader(
            title: '案件脈絡',
            subtitle: '從事件背景、法律爭點到社會討論，快速掌握案件為什麼值得回看。',
            titleSize: 24,
          ),
          const SizedBox(height: 18),
          ...List.generate(hotTopicItems.length, (index) {
            final item = hotTopicItems[index];
            return Padding(
              padding: EdgeInsets.only(
                bottom: index == hotTopicItems.length - 1 ? 0 : 14,
              ),
              child: _HotTopicCard(
                title: item.title,
                summary: item.summary,
                tags: item.tags,
              ),
            );
          }),
        ],
      ),
    );
  }
}

class _NewsListCard extends StatelessWidget {
  const _NewsListCard({required this.item});

  final HomeNewsItem item;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFFF8F1E2),
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              item.badge,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: Color(0xFF946C22),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              item.title,
              style: const TextStyle(
                fontSize: 18,
                height: 1.35,
                fontWeight: FontWeight.w600,
                color: Color(0xFF101828),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _HotTopicCard extends StatelessWidget {
  const _HotTopicCard({
    required this.title,
    required this.summary,
    required this.tags,
  });

  final String title;
  final String summary;
  final List<String> tags;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFDCE7F5),
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.article_rounded,
                color: Color(0xFFC96B3B),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF16243D),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            height: 120,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.7),
              borderRadius: BorderRadius.circular(18),
            ),
            child: const Center(
              child: Text(
                '案件時間線與資料摘要',
                style: TextStyle(
                  fontSize: 14,
                  color: Color(0xFF52607A),
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            summary,
            style: const TextStyle(
              fontSize: 14,
              height: 1.55,
              color: Color(0xFF23314D),
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: tags
                .map(
                  (tag) => Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      tag,
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
        ],
      ),
    );
  }
}
