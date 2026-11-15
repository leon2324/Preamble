import 'package:flutter/material.dart';
import 'package:preamble/data/documents/document_models.dart';

class FormCompletenessIndicator extends StatelessWidget {
  const FormCompletenessIndicator({
    super.key,
    required this.input,
  });

  final DocumentTemplateInput input;

  double get completenessScore {
    int total = 5;
    int filled = 0;
    if (input.senderName.trim().isNotEmpty) filled++;
    if (input.receiverName.trim().isNotEmpty) filled++;
    if (input.facts.trim().isNotEmpty) filled++;
    if (input.eventDate.trim().isNotEmpty || input.eventPlace.trim().isNotEmpty) filled++;
    if (input.evidence.trim().isNotEmpty) filled++;
    return filled / total;
  }

  String get suggestion {
    final score = completenessScore;
    if (score == 1.0) return '資料已齊全，可產出草稿！';
    if (input.facts.trim().isEmpty) return '建議補充「事實經過」，讓草稿更具體。';
    if (input.evidence.trim().isEmpty) return '建議補充「證據資料」，增加法律談判籌碼。';
    if (input.receiverName.trim().isEmpty) return '建議填寫「相對人姓名」。';
    return '再補充一些細節，草稿會更完整喔！';
  }

  @override
  Widget build(BuildContext context) {
    final score = completenessScore;
    final theme = Theme.of(context);
    final color = score > 0.8 ? Colors.green : (score > 0.4 ? Colors.orange : Colors.redAccent);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '填寫完整度',
                style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
              ),
              Text(
                '${(score * 100).toInt()}%',
                style: theme.textTheme.titleSmall?.copyWith(
                  color: color,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: score,
            backgroundColor: color.withValues(alpha: 0.2),
            valueColor: AlwaysStoppedAnimation<Color>(color),
            borderRadius: BorderRadius.circular(4),
          ),
          const SizedBox(height: 8),
          Text(
            suggestion,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
