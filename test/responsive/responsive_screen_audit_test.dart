import 'package:flutter_test/flutter_test.dart';

import '../support/responsive_audit_registry.dart';
import '../support/responsive_audit_reporter.dart';
import '../support/responsive_error_collector.dart';
import '../support/responsive_test_case.dart';
import '../support/responsive_test_harness.dart';
import 'responsive_known_findings.dart';

void main() {
  final harness = ResponsiveTestHarness();

  testWidgets('P0 strict responsive safety gate for every automated screen',
      (tester) async {
    final results = await _runMatrix(
      tester,
      entries: responsiveScreenEntries,
      matrix: responsiveP0StrictMatrix,
    );
    _failForUnexpectedExceptions(results);
    final violations = results.where((result) => result.hasViolation).toList();
    expect(
      violations,
      isEmpty,
      reason: violations.map((result) => result.summary).join('\n'),
    );
  });

  testWidgets('responsive screen audit fast matrix', (tester) async {
    final results = await _runMatrix(
      tester,
      entries: responsiveScreenEntries,
      matrix: responsiveFastMatrix,
    );
    _evaluateExploratoryMatrix('fast', results);
  });

  testWidgets('responsive screen audit deep matrix for high-risk flows',
      (tester) async {
    final entries = responsiveScreenEntries.where((entry) {
      return entry.id == 'screen.learning_tools' ||
          entry.id == 'screen.global_search' ||
          entry.id == 'screen.statute_database' ||
          entry.id == 'screen.document_export';
    }).toList(growable: false);
    final results = await _runMatrix(
      tester,
      entries: entries,
      matrix: responsiveDeepMatrix,
    );
    _evaluateExploratoryMatrix('deep', results);
  });

  testWidgets('responsive screen audit extreme stress matrix', (tester) async {
    final entries = responsiveScreenEntries.where((entry) {
      return entry.id == 'screen.app_shell_home' ||
          entry.id == 'screen.learning_tools' ||
          entry.id == 'screen.global_search';
    }).toList(growable: false);
    final results = await _runMatrix(
      tester,
      entries: entries,
      matrix: responsiveExtremeMatrix,
    );
    _evaluateExploratoryMatrix('extreme', results);
  });
}

Future<List<ResponsiveAuditResult>> _runMatrix(
  WidgetTester tester, {
  required List<ResponsiveAuditEntry> entries,
  required List<ResponsiveTestCase> matrix,
}) async {
  final harness = ResponsiveTestHarness();
  final results = <ResponsiveAuditResult>[];

  for (final entry in entries) {
    for (final testCase in matrix) {
      if (!entry.supportsEnglish && testCase.locale.languageCode == 'en') {
        continue;
      }
      results.add(
        await harness.pumpEntry(
          tester,
          entry: entry,
          testCase: testCase,
        ),
      );
    }
  }
  return results;
}

void _evaluateExploratoryMatrix(
  String matrix,
  List<ResponsiveAuditResult> results,
) {
  final evaluation = evaluateResponsiveKnownFindings(
    results,
    includeOnlyExecutedCases: true,
  );
  _printSummary(matrix, results, evaluation);
  _failForUnexpectedExceptions(results);
  expect(
    evaluation.regressions,
    isEmpty,
    reason: evaluation.regressions.map((item) => item.message).join('\n'),
  );
}

void _printSummary(
  String matrix,
  List<ResponsiveAuditResult> results,
  ResponsiveBaselineEvaluation evaluation,
) {
  final violations = results.where((result) => result.hasViolation).toList();
  // ignore: avoid_print
  print(
    'RESPONSIVE_AUDIT matrix=$matrix cases=${results.length} '
    'violations=${violations.length}',
  );
  // ignore: avoid_print
  print(
    'RESPONSIVE_AUDIT_JSON\n${ResponsiveAuditReporter.jsonSummary(
      matrix: matrix,
      results: results,
      evaluation: evaluation,
      manualOnlyEntryIds: responsiveManualOnlyEntries.map((entry) => entry.id),
    )}',
  );
  // ignore: avoid_print
  print(
    'RESPONSIVE_AUDIT_MARKDOWN\n${ResponsiveAuditReporter.markdownSummary(
      matrix: matrix,
      results: results,
      evaluation: evaluation,
      manualOnlyEntryIds: responsiveManualOnlyEntries.map((entry) => entry.id),
    )}',
  );
}

void _failForUnexpectedExceptions(List<ResponsiveAuditResult> results) {
  final unexpected = results
      .expand((result) => result.failures)
      .where((failure) => failure.kind == ResponsiveFailureKind.unexpected)
      .toList(growable: false);
  expect(
    unexpected,
    isEmpty,
    reason: 'Responsive audit must not suppress non-layout failures: '
        '${unexpected.map((failure) => failure.message).join('\n')}',
  );
}
