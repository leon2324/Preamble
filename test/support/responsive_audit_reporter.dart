import 'dart:convert';

import '../responsive/responsive_known_findings.dart';
import 'responsive_test_harness.dart';

/// 響應式稽核定義所對應的產品基準 commit。
///
/// 台灣繁體中文教學註解：這不是執行時讀取 Git 的行為，避免測試依賴本機 Git
/// 狀態。更新 audit baseline 時才同步更新此值與文件中的執行基準。
const responsiveProductBaselineCommit =
    '224e48f7929956cfb9e6dec9cae14a7ac53aac99';
const responsiveAuditDefinitionRecordedAt = '2026-07-15T00:00:00+08:00';

/// 將 runtime audit 結果轉成穩定排序的 JSON 與 Markdown。
///
/// 台灣繁體中文教學註解：測試以 stdout 輸出這份內容，CI 可收集它做為產物；
/// 它不會在測試中寫入工作區，因此不會產生機器專屬或時間漂移的 diff。
class ResponsiveAuditReporter {
  const ResponsiveAuditReporter._();

  static String jsonSummary({
    required String matrix,
    required Iterable<ResponsiveAuditResult> results,
    required ResponsiveBaselineEvaluation evaluation,
    required Iterable<String> manualOnlyEntryIds,
  }) {
    final sorted = _sorted(results);
    final payload = <String, Object?>{
      'auditDefinitionRecordedAt': responsiveAuditDefinitionRecordedAt,
      'productBaselineCommit': responsiveProductBaselineCommit,
      'matrix': matrix,
      'executions': sorted.map(_resultPayload).toList(growable: false),
      'knownFindings': responsiveKnownFindings
          .map(
            (finding) => <String, Object>{
              'id': finding.id,
              'entryId': finding.entryId,
              'testCaseId': finding.testCaseId,
              'nextBatch': finding.nextBatch,
            },
          )
          .toList(growable: false),
      'knownObservations': responsiveKnownObservations
          .map(
            (observation) => <String, Object>{
              'id': observation.id,
              'entryId': observation.entryId,
              'testCaseId': observation.testCaseId,
              'kind': observation.kind.name,
              'value': observation.value,
              'nextBatch': observation.nextBatch,
            },
          )
          .toList(growable: false),
      'newRegressions': evaluation.regressions
          .map((regression) => regression.message)
          .toList(growable: false),
      'staleFindings': evaluation.staleFindings
          .map((finding) => finding.id)
          .toList(growable: false),
      'staleObservations': evaluation.staleObservations
          .map((observation) => observation.id)
          .toList(growable: false),
      'unexpectedExceptions': sorted
          .expand((result) => result.failures)
          .where((failure) => !failure.isLayout)
          .map((failure) => failure.message)
          .toList(growable: false),
      'manualOnlyEntries': manualOnlyEntryIds.toList()..sort(),
    };
    return const JsonEncoder.withIndent('  ').convert(payload);
  }

  static String markdownSummary({
    required String matrix,
    required Iterable<ResponsiveAuditResult> results,
    required ResponsiveBaselineEvaluation evaluation,
    required Iterable<String> manualOnlyEntryIds,
  }) {
    final sorted = _sorted(results);
    final violations = sorted.where((result) => result.hasViolation).toList();
    final buffer = StringBuffer()
      ..writeln('# Responsive Audit Summary')
      ..writeln()
      ..writeln(
        '- Audit definition recorded at: '
        '`$responsiveAuditDefinitionRecordedAt`',
      )
      ..writeln('- Product baseline commit: `$responsiveProductBaselineCommit`')
      ..writeln('- Matrix: `$matrix`')
      ..writeln('- Executions: `${sorted.length}`')
      ..writeln('- Violations: `${violations.length}`')
      ..writeln('- New regressions: `${evaluation.regressions.length}`')
      ..writeln('- Stale findings: `${evaluation.staleFindings.length}`')
      ..writeln(
          '- Stale observations: `${evaluation.staleObservations.length}`')
      ..writeln()
      ..writeln('## Violations');
    if (violations.isEmpty) {
      buffer.writeln('- None');
    } else {
      for (final result in violations) {
        buffer.writeln('- `${result.summary}`');
      }
    }
    buffer
      ..writeln()
      ..writeln('## New Regressions');
    if (evaluation.regressions.isEmpty) {
      buffer.writeln('- None');
    } else {
      for (final regression in evaluation.regressions) {
        buffer.writeln('- ${regression.message}');
      }
    }
    buffer
      ..writeln()
      ..writeln('## Stale Findings');
    if (evaluation.staleFindings.isEmpty) {
      buffer.writeln('- None');
    } else {
      for (final finding in evaluation.staleFindings) {
        buffer.writeln('- `${finding.id}` should be reviewed and removed.');
      }
    }
    buffer
      ..writeln()
      ..writeln('## Stale Observations');
    if (evaluation.staleObservations.isEmpty) {
      buffer.writeln('- None');
    } else {
      for (final observation in evaluation.staleObservations) {
        buffer.writeln('- `${observation.id}` should be reviewed and removed.');
      }
    }
    buffer
      ..writeln()
      ..writeln('## Manual-only Entries');
    for (final entryId in manualOnlyEntryIds.toList()..sort()) {
      buffer.writeln('- `$entryId`');
    }
    return buffer.toString();
  }

  static List<ResponsiveAuditResult> _sorted(
    Iterable<ResponsiveAuditResult> results,
  ) {
    final sorted = results.toList(growable: false);
    sorted.sort((left, right) {
      final entryOrder = left.entry.id.compareTo(right.entry.id);
      return entryOrder != 0
          ? entryOrder
          : left.testCase.id.compareTo(right.testCase.id);
    });
    return sorted;
  }

  static Map<String, Object?> _resultPayload(ResponsiveAuditResult result) {
    return <String, Object?>{
      'entryId': result.entry.id,
      'testCaseId': result.testCase.id,
      'layoutFailures': result.failures
          .where((failure) => failure.isLayout)
          .map((failure) => failure.message)
          .toList(growable: false),
      'unexpectedFailures': result.failures
          .where((failure) => !failure.isLayout)
          .map((failure) => failure.message)
          .toList(growable: false),
      'missingPrimaryLabels': result.missingPrimaryLabels,
      'unreachablePrimaryLabels': result.unreachablePrimaryLabels,
      'clippedText': result.clippedText,
      'mediaQueryMismatch': result.mediaQueryMismatch,
    };
  }
}
