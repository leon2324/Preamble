import 'package:flutter/material.dart';
import 'package:lawapp/data/international_case_mock_data.dart';

class InternationalCasePage extends StatelessWidget {
  const InternationalCasePage({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 24),
      children: [
        const Text(
          '熱門討論',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w800,
            color: Color(0xFF101828),
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          '根據最近討論度最高的新聞或案件，看看大家正在關心什麼。',
          style: TextStyle(
            fontSize: 14,
            color: Color(0xFF667085),
          ),
        ),
        const SizedBox(height: 18),
        ...List.generate(hotTopicItems.length, (index) {
          final item = hotTopicItems[index];
          return Padding(
            padding: EdgeInsets.only(
                bottom: index == hotTopicItems.length - 1 ? 0 : 14),
            child: _HotTopicCard(
              title: item.title,
              summary: item.summary,
              tags: item.tags,
            ),
          );
        }),
      ],
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
                Icons.local_fire_department_rounded,
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
                '趨勢圖與留言預覽',
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
