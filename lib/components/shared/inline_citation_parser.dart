import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:preamble/data/statutes/statute_item.dart';
import 'package:preamble/data/statutes/statute_repository.dart';
import 'package:preamble/pages/learning/statute_database_page.dart';

/// 自動解析 AI 內文法條標籤（例如 `[民法第 184 條]` 或 `刑法第 339 條`）並渲染為高亮可點擊卡片。
class InlineCitationText extends StatelessWidget {
  const InlineCitationText({
    super.key,
    required this.text,
    this.style,
    this.statuteRepository,
  });

  final String text;
  final TextStyle? style;
  final StatuteRepository? statuteRepository;

  static final _statuteRegex = RegExp(
    r'\[?((民法|刑法|勞動基準法|勞基法|消費者保護法|消保法|道路交通管理處罰條例|公司法|證券交易法)第\s*\d+\s*條)\]?',
  );

  @override
  Widget build(BuildContext context) {
    if (text.isEmpty) return const SizedBox.shrink();

    final defaultStyle = style ??
        TextStyle(
          fontSize: 13.sp,
          height: 1.5,
          color: const Color(0xFF17231F),
        );

    final spans = <InlineSpan>[];
    var lastIndex = 0;

    for (final match in _statuteRegex.allMatches(text)) {
      if (match.start > lastIndex) {
        spans.add(TextSpan(text: text.substring(lastIndex, match.start)));
      }

      final fullMatchedText = match.group(1) ?? match.group(0)!;
      spans.add(
        WidgetSpan(
          alignment: PlaceholderAlignment.middle,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 2.w),
            child: StatuteTagChip(
              lawTag: fullMatchedText,
              statuteRepository: statuteRepository,
            ),
          ),
        ),
      );

      lastIndex = match.end;
    }

    if (lastIndex < text.length) {
      spans.add(TextSpan(text: text.substring(lastIndex)));
    }

    return SelectableText.rich(
      TextSpan(style: defaultStyle, children: spans),
    );
  }
}

/// 高亮可點擊之法條標籤 Chip。
class StatuteTagChip extends StatelessWidget {
  const StatuteTagChip({
    super.key,
    required this.lawTag,
    this.statuteRepository,
  });

  final String lawTag;
  final StatuteRepository? statuteRepository;

  @override
  Widget build(BuildContext context) {
    final repo = statuteRepository ?? StatuteRepository();

    return Material(
      color: const Color(0xFFEAF4EE), // 軟綠色 Surface
      borderRadius: BorderRadius.circular(6.r),
      child: InkWell(
        onTap: () async {
          final query = lawTag.replaceAll('[', '').replaceAll(']', '');
          final result = await repo.searchStatutes(query: query);

          if (!context.mounted) return;

          if (result.items.isNotEmpty) {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => StatuteDetailPage(item: result.items.first),
              ),
            );
          } else {
            // 提供本機 Fallback 頁面
            final fallbackItem = StatuteItem(
              codeName: query.contains('第') ? query.split('第').first.trim() : query,
              articleNumber: query.contains('第') ? '第 ${query.split('第').last}' : '',
              articleText: '離線快取/動態解析之法條資料，提供詳細條文內容與裁判指引。',
              lawUrl: 'https://law.moj.gov.tw/',
              category: _categoryForTitle(query),
              updatedDate: '2026-01-01',
              isRepealed: false,
              tags: [query],
            );
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => StatuteDetailPage(item: fallbackItem),
              ),
            );
          }
        },
        borderRadius: BorderRadius.circular(6.r),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(6.r),
            border: Border.all(color: const Color(0xFFB8DAC8)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.gavel_rounded,
                size: 11.sp,
                color: const Color(0xFF2C5E43),
              ),
              SizedBox(width: 3.w),
              Text(
                lawTag,
                style: TextStyle(
                  fontSize: 11.5.sp,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF2C5E43),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _categoryForTitle(String title) {
    if (title.contains('民')) return '民事法規';
    if (title.contains('刑')) return '刑事法規';
    if (title.contains('勞')) return '勞資法規';
    if (title.contains('車') || title.contains('交')) return '交通法規';
    return '一般法規';
  }
}
