import 'package:flutter/material.dart';
import 'package:lawapp/components/home/home_content.dart';
import 'package:lawapp/components/search/search_page_layout.dart';
import 'package:lawapp/components/shared/page_section_header.dart';
import 'package:lawapp/data/home_mock_data.dart';
import 'package:lawapp/theme/adaptive_layout.dart';

class KnowLawPage extends StatefulWidget {
  const KnowLawPage({super.key});

  @override
  KnowLawPageState createState() => KnowLawPageState();
}

class KnowLawPageState extends State<KnowLawPage> {
  KnowLawPageState() : super();

  final controller = TextEditingController();

  static const List<String> _recentTopics = [
    '勞動基準法',
    '職業安全衛生設施條例',
    '行政程序法',
    '洗錢防制法',
    '貪污治罪條例',
  ];

  static const List<String> _interestTopics = [
    '道路交通處罰管理條例',
    '住宅租賃糾紛',
    '網路購物退貨權',
  ];

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: SearchPageLayout(
              controller: controller,
              hintText: '搜尋判決、法律、實例...',
              headerTitle: '法律新知小報',
              headerSubtitle: '把近期值得學的法律議題整理成容易吸收的小報。',
              builder:
                  (context, layout, contentTopPadding, contentBottomPadding) =>
                      ListView(
                padding: EdgeInsets.fromLTRB(
                  16,
                  contentTopPadding,
                  16,
                  contentBottomPadding,
                ),
                children: [
                  ...homeNewsletterItems.map(
                    (item) => Padding(
                      padding: const EdgeInsets.only(bottom: 14),
                      child: _NewsletterLearningCard(item: item),
                    ),
                  ),
                  const SizedBox(height: 18),
                  const PageSectionHeader(
                    title: '根據你最近查看的案件',
                    subtitle: '延續你最近在意的法條與主題，快速回到熟悉脈絡。',
                    titleSize: 24,
                  ),
                  const SizedBox(height: 12),
                  ..._recentTopics.map(
                    (topic) => Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: _TopicChip(label: topic),
                    ),
                  ),
                  const SizedBox(height: 18),
                  const PageSectionHeader(
                    title: '你可能也會感興趣',
                    subtitle: '從常見生活情境出發，補充你下一步可能想知道的法律內容。',
                    titleSize: 24,
                  ),
                  const SizedBox(height: 12),
                  ..._interestTopics.map(
                    (topic) => Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: _TopicChip(label: topic),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _NewsletterLearningCard extends StatelessWidget {
  const _NewsletterLearningCard({required this.item});

  final HomeNewsletterItem item;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF3E6D6),
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            item.title,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: Color(0xFF2B4499),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            item.summary,
            style: const TextStyle(
              fontSize: 14,
              height: 1.55,
              color: Color(0xFF7B6A59),
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.7),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              item.tip,
              style: const TextStyle(
                fontSize: 13,
                height: 1.45,
                fontWeight: FontWeight.w600,
                color: Color(0xFF3F6C18),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TopicChip extends StatelessWidget {
  const _TopicChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w500,
          color: Color(0xFF101828),
        ),
      ),
    );
  }
}
