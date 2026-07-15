import 'package:flutter_test/flutter_test.dart';

import '../support/responsive_audit_registry.dart';
import '../support/responsive_audit_reporter.dart';
import '../support/responsive_error_collector.dart';
import '../support/responsive_test_case.dart';
import '../support/responsive_test_harness.dart';
import 'responsive_known_findings.dart';

void main() {
  final harness = ResponsiveTestHarness();
  final strictMatrix = <ResponsiveTestCase>[
    ...responsiveFastMatrix.where((testCase) => testCase.textScale <= 1.4),
    ...responsiveDeepMatrix.where((testCase) => testCase.textScale <= 1.4),
  ];

  for (final entry in responsiveComponentEntries) {
    testWidgets('strict responsive gate: ${entry.id}', (tester) async {
      for (final testCase in strictMatrix) {
        final result = await harness.pumpEntry(
          tester,
          entry: entry,
          testCase: testCase,
          failOnUnexpectedFailures: true,
        );

        expect(
          result.hasViolation,
          isFalse,
          reason: '${result.summary}\n'
              'failures=${result.failures.map((failure) => failure.message).join('\n')}',
        );
      }
    });
  }

  testWidgets('component audit reports extended matrix without hiding issues',
      (tester) async {
    final results = <ResponsiveAuditResult>[];
    final matrix = <ResponsiveTestCase>[
      ...responsiveFastMatrix,
      ...responsiveDeepMatrix,
      ...responsiveExtremeMatrix,
    ];
    for (final entry in responsiveComponentEntries) {
      for (final testCase in matrix) {
        results.add(
          await harness.pumpEntry(
            tester,
            entry: entry,
            testCase: testCase,
          ),
        );
      }
    }

    final evaluation = evaluateResponsiveKnownFindings(
      results,
      includeOnlyExecutedCases: true,
    );
    _printReport(
      matrix: 'component-extended',
      results: results,
      evaluation: evaluation,
    );
    _failForUnexpectedExceptions(results);
    expect(
      evaluation.regressions,
      isEmpty,
      reason: evaluation.regressions.map((item) => item.message).join('\n'),
    );
  });
}

void _printReport({
  required String matrix,
  required List<ResponsiveAuditResult> results,
  required ResponsiveBaselineEvaluation evaluation,
}) {
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
