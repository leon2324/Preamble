import 'dart:io';

class _RiskPattern {
  const _RiskPattern(this.id, this.severity, this.expression, this.suggestion);

  final String id;
  final String severity;
  final RegExp expression;
  final String suggestion;
}

class _RiskHit {
  const _RiskHit({
    required this.path,
    required this.line,
    required this.pattern,
    required this.source,
  });

  final String path;
  final int line;
  final _RiskPattern pattern;
  final String source;
}

/// 以保守規則找出需要人工或 runtime audit 驗證的 layout 訊號。
///
/// 台灣繁體中文教學註解：這不是 Dart AST lint，也不把每個命中判定為 bug；
/// 它只建立可重跑的候選清單，最後仍要以 responsive widget audit 或真機結果分類。
void main(List<String> arguments) {
  final summaryOnly = arguments.contains('--summary');
  final root = Directory('lib');
  if (!root.existsSync()) {
    stderr.writeln('Run this tool from the repository root.');
    exitCode = 64;
    return;
  }

  final patterns = <_RiskPattern>[
    _RiskPattern(
      'forced-text-scale',
      'P0',
      RegExp(r'TextScaler\.noScaling|textScaleFactor\s*:'),
      'Remove forced scaling; let content reflow with the platform TextScaler.',
    ),
    _RiskPattern(
      'fitted-primary-text',
      'P1',
      RegExp(r'\bFittedBox\b'),
      'Verify it is not compressing user-facing primary text.',
    ),
    _RiskPattern(
      'ellipsis',
      'P1',
      RegExp(r'TextOverflow\.ellipsis'),
      'Confirm the shortened text is secondary, never a primary action.',
    ),
    _RiskPattern(
      'intrinsic-layout',
      'P2',
      RegExp(r'\bIntrinsic(?:Height|Width)\b'),
      'Test under large text because intrinsic measurement can amplify constraints.',
    ),
    _RiskPattern(
      'single-line-text',
      'P2',
      RegExp(r'maxLines\s*:\s*1\b'),
      'Verify localized and Dynamic Type content is not silently clipped.',
    ),
    _RiskPattern(
      'positioned-content',
      'P2',
      RegExp(r'\bPositioned(?:\.fill)?\s*\('),
      'Verify the positioned area remains inside safe areas and keyboard insets.',
    ),
    _RiskPattern(
      'fixed-width',
      'P2',
      RegExp(
          r'\b(?:width|constraints)\s*:\s*(?:[0-9]+(?:\.[0-9]+)?|[^,;]*\.w\b)'),
      'Check text-bearing content with a constrained small viewport.',
    ),
    _RiskPattern(
      'fixed-height',
      'P2',
      RegExp(r'\bheight\s*:\s*(?:[0-9]+(?:\.[0-9]+)?|[^,;]*\.h\b)'),
      'Check that text-bearing content uses a content-driven minimum height.',
    ),
  ];

  final hits = <_RiskHit>[];
  for (final file in root
      .listSync(recursive: true)
      .whereType<File>()
      .where((file) => file.path.endsWith('.dart'))) {
    final lines = file.readAsLinesSync();
    for (var index = 0; index < lines.length; index++) {
      for (final pattern in patterns) {
        if (pattern.expression.hasMatch(lines[index])) {
          hits.add(
            _RiskHit(
              path: file.path,
              line: index + 1,
              pattern: pattern,
              source: lines[index].trim(),
            ),
          );
        }
      }
    }
  }

  final counts = <String, int>{};
  for (final hit in hits) {
    counts.update(hit.pattern.id, (count) => count + 1, ifAbsent: () => 1);
  }

  stdout.writeln('RESPONSIVE_STATIC_SCAN hits=${hits.length}');
  for (final pattern in patterns) {
    stdout.writeln(
      'RESPONSIVE_STATIC_SCAN ${pattern.severity} ${pattern.id} '
      'count=${counts[pattern.id] ?? 0} suggestion=${pattern.suggestion}',
    );
  }
  if (!summaryOnly) {
    for (final hit in hits) {
      stdout.writeln(
        '${hit.pattern.severity}|${hit.pattern.id}|${hit.path}:${hit.line}|'
        '${hit.source}',
      );
    }
  }
}
