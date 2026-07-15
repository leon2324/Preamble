import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/responsive_audit_reporter.dart';
import '../support/responsive_error_collector.dart';
import '../support/responsive_test_case.dart';
import '../support/responsive_test_harness.dart';
import 'responsive_known_findings.dart';

void main() {
  final entry = ResponsiveAuditEntry(
    id: 'screen.synthetic',
    label: 'Synthetic audit entry',
    builder: () => const SizedBox.shrink(),
    primaryLabels: const [],
    declaredStates: const ['normal'],
  );
  const testCase = ResponsiveTestCase(
    id: 'synthetic-case',
    viewport: Size(393, 852),
    textScale: 2,
  );
  const finding = ResponsiveKnownFinding(
    id: 'RSA-SYNTHETIC',
    entryId: 'screen.synthetic',
    testCaseId: 'synthetic-case',
    failureKind: ResponsiveFailureKind.layout,
    requiredSignatures: [
      ResponsiveLayoutSignature(
        layoutType: 'RenderFlex',
        direction: 'right',
      ),
    ],
    maxOccurrences: 1,
    maxOverflowPixels: 12,
    reason: 'Only used to prove the baseline gate itself.',
    nextBatch: 'Test',
  );

  test('new synthetic overflow is a baseline regression', () {
    final result = _result(
      entry: entry,
      testCase: testCase,
      failures: const <ResponsiveFailure>[
        ResponsiveFailure(
          kind: ResponsiveFailureKind.layout,
          message: 'A RenderFlex overflowed by 8 pixels on the right.',
        ),
      ],
    );
    final evaluation = evaluateResponsiveKnownFindings(
      [result],
      baseline: const <ResponsiveKnownFinding>[],
    );

    expect(evaluation.hasRegressions, isTrue);
    expect(
        evaluation.regressions.single.message, contains('New layout finding'));
  });

  test('known finding rejects extra failures and severity growth', () {
    final result = _result(
      entry: entry,
      testCase: testCase,
      failures: const <ResponsiveFailure>[
        ResponsiveFailure(
          kind: ResponsiveFailureKind.layout,
          message: 'A RenderFlex overflowed by 20 pixels on the right.',
        ),
        ResponsiveFailure(
          kind: ResponsiveFailureKind.layout,
          message: 'A RenderFlex overflowed by 4 pixels on the right.',
        ),
      ],
    );
    final evaluation = evaluateResponsiveKnownFindings(
      [result],
      baseline: const [finding],
    );

    expect(evaluation.regressions, hasLength(2));
    expect(
      evaluation.regressions.map((item) => item.message),
      contains(contains('has 2 layout failures')),
    );
    expect(
      evaluation.regressions.map((item) => item.message),
      contains(contains('overflow grew to 20.0 px')),
    );
  });

  test('disappeared known finding is reported as stale', () {
    final evaluation = evaluateResponsiveKnownFindings(
      const <ResponsiveAuditResult>[],
      baseline: const [finding],
    );

    expect(evaluation.regressions, isEmpty);
    expect(evaluation.staleFindings, contains(finding));
  });

  test('report output is deterministic and includes baseline metadata', () {
    final result = _result(
      entry: entry,
      testCase: testCase,
      failures: const <ResponsiveFailure>[],
    );
    final evaluation = evaluateResponsiveKnownFindings(
      const <ResponsiveAuditResult>[],
      baseline: const <ResponsiveKnownFinding>[],
    );
    final first = ResponsiveAuditReporter.jsonSummary(
      matrix: 'synthetic',
      results: [result],
      evaluation: evaluation,
      manualOnlyEntryIds: const ['manual.one'],
    );
    final second = ResponsiveAuditReporter.jsonSummary(
      matrix: 'synthetic',
      results: [result],
      evaluation: evaluation,
      manualOnlyEntryIds: const ['manual.one'],
    );

    expect(first, second);
    expect(first, contains(responsiveProductBaselineCommit));
    expect(first, contains(responsiveAuditDefinitionRecordedAt));
    expect(first, contains('productBaselineCommit'));
    expect(first, contains('auditDefinitionRecordedAt'));
  });

  test('layout signature rejects a same-size overflow in another direction',
      () {
    const bottomColumnFinding = ResponsiveKnownFinding(
      id: 'RSA-SIGNATURE',
      entryId: 'screen.synthetic',
      testCaseId: 'synthetic-case',
      failureKind: ResponsiveFailureKind.layout,
      requiredSignatures: [
        ResponsiveLayoutSignature(
          layoutType: 'RenderFlex',
          direction: 'bottom',
          widgetType: 'Column',
        ),
      ],
      maxOccurrences: 1,
      maxOverflowPixels: 12,
      reason: 'Only used to prove layout signatures.',
      nextBatch: 'Test',
    );
    final result = _result(
      entry: entry,
      testCase: testCase,
      failures: const <ResponsiveFailure>[
        ResponsiveFailure(
          kind: ResponsiveFailureKind.layout,
          message: 'A RenderFlex overflowed by 8 pixels on the right.',
          layoutSignature: ResponsiveLayoutSignature(
            layoutType: 'RenderFlex',
            direction: 'right',
            widgetType: 'Row',
          ),
        ),
      ],
    );

    final evaluation = evaluateResponsiveKnownFindings(
      [result],
      baseline: const [bottomColumnFinding],
      observationBaseline: const <ResponsiveKnownObservation>[],
    );

    expect(evaluation.hasRegressions, isTrue);
    expect(
      evaluation.regressions.map((item) => item.message),
      contains(contains('unrecognised layout signature')),
    );
    expect(
      evaluation.regressions.map((item) => item.message),
      contains(contains('no longer contains required layout signature')),
    );
  });

  test('unregistered primary observation is a baseline regression', () {
    final result = _result(
      entry: entry,
      testCase: testCase,
      failures: const <ResponsiveFailure>[],
      clippedText: const ['新的主要標籤'],
    );

    final evaluation = evaluateResponsiveKnownFindings(
      [result],
      baseline: const <ResponsiveKnownFinding>[],
      observationBaseline: const <ResponsiveKnownObservation>[],
    );

    expect(evaluation.hasRegressions, isTrue);
    expect(
      evaluation.regressions.single.message,
      contains('New clippedPrimaryText observation'),
    );
  });

  test('summary never reports PASS for a standalone unreachable action', () {
    final result = _result(
      entry: entry,
      testCase: testCase,
      failures: const <ResponsiveFailure>[],
      unreachablePrimaryLabels: const ['主要操作'],
    );

    expect(result.hasViolation, isTrue);
    expect(result.summary, contains('VIOLATION'));
    expect(result.summary, isNot(contains('PASS')));
    expect(result.summary, contains('unreachable=主要操作'));
  });

  test('summary includes every standalone observation type', () {
    final result = _result(
      entry: entry,
      testCase: testCase,
      failures: const <ResponsiveFailure>[],
      unreachablePrimaryLabels: const ['主要操作'],
      mediaQueryMismatch: 'text scaler differs',
    );

    expect(result.summary, contains('VIOLATION'));
    expect(result.summary, contains('unreachable=主要操作'));
    expect(result.summary, contains('mismatch=text scaler differs'));
    expect(result.summary, contains('issues=2'));
  });

  test('summary never reports PASS for a standalone MediaQuery mismatch', () {
    final result = _result(
      entry: entry,
      testCase: testCase,
      failures: const <ResponsiveFailure>[],
      mediaQueryMismatch: 'viewInsets differs',
    );

    expect(result.summary, contains('VIOLATION'));
    expect(result.summary, isNot(contains('PASS')));
    expect(result.summary, contains('mismatch=viewInsets differs'));
  });
}

ResponsiveAuditResult _result({
  required ResponsiveAuditEntry entry,
  required ResponsiveTestCase testCase,
  required List<ResponsiveFailure> failures,
  List<String> missingPrimaryLabels = const [],
  List<String> unreachablePrimaryLabels = const [],
  List<String> clippedText = const [],
  String? mediaQueryMismatch,
}) {
  return ResponsiveAuditResult(
    entry: entry,
    testCase: testCase,
    failures: failures,
    missingPrimaryLabels: missingPrimaryLabels,
    unreachablePrimaryLabels: unreachablePrimaryLabels,
    clippedText: clippedText,
    mediaQueryMismatch: mediaQueryMismatch,
  );
}
