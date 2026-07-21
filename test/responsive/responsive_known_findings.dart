import '../support/responsive_error_collector.dart';
import '../support/responsive_test_harness.dart';

/// 已確認、但尚未修正的響應式問題基線。
///
/// 台灣繁體中文教學註解：每筆資料鎖定到「一個產品 entry + 一個測試案例」，
/// 不是只計算總錯誤數。如此同一案例多一個 overflow、出現在未登錄的頁面，
/// 或像素嚴重度升高，都會被視為回歸。
class ResponsiveKnownFinding {
  const ResponsiveKnownFinding({
    required this.id,
    required this.entryId,
    required this.testCaseId,
    required this.failureKind,
    required this.requiredSignatures,
    required this.maxOccurrences,
    required this.maxOverflowPixels,
    required this.reason,
    required this.nextBatch,
  });

  final String id;
  final String entryId;
  final String testCaseId;
  final ResponsiveFailureKind failureKind;
  final List<ResponsiveLayoutSignature> requiredSignatures;
  final int maxOccurrences;
  final double maxOverflowPixels;
  final String reason;
  final String nextBatch;

  bool matches(ResponsiveAuditResult result) {
    return result.entry.id == entryId && result.testCase.id == testCaseId;
  }
}

enum ResponsiveObservationKind {
  missingPrimaryLabel,
  unreachablePrimaryLabel,
  clippedPrimaryText,
  mediaQueryMismatch,
}

/// 非 layout 觀察的精確基線，避免探索矩陣只列印而不守住既有結果。
class ResponsiveKnownObservation {
  const ResponsiveKnownObservation({
    required this.id,
    required this.entryId,
    required this.testCaseId,
    required this.kind,
    required this.value,
    required this.reason,
    required this.nextBatch,
  });

  final String id;
  final String entryId;
  final String testCaseId;
  final ResponsiveObservationKind kind;
  final String value;
  final String reason;
  final String nextBatch;

  bool matches(ResponsiveAuditResult result) {
    return result.entry.id == entryId && result.testCase.id == testCaseId;
  }
}

class ResponsiveBaselineRegression {
  const ResponsiveBaselineRegression(this.message);

  final String message;
}

class ResponsiveBaselineEvaluation {
  const ResponsiveBaselineEvaluation({
    required this.regressions,
    required this.staleFindings,
    required this.staleObservations,
  });

  final List<ResponsiveBaselineRegression> regressions;
  final List<ResponsiveKnownFinding> staleFindings;
  final List<ResponsiveKnownObservation> staleObservations;

  bool get hasRegressions => regressions.isNotEmpty;
}

const _renderFlexBottom = ResponsiveLayoutSignature(
  layoutType: 'RenderFlex',
  direction: 'bottom',
);
const _renderFlexRight = ResponsiveLayoutSignature(
  layoutType: 'RenderFlex',
  direction: 'right',
);
const _renderFlexRightAndBottom = <ResponsiveLayoutSignature>[
  _renderFlexRight,
  _renderFlexBottom,
];

/// 集中管理目前 runtime audit 已知的 P1/P2 版面問題。
///
/// 不把 P0 情境寫入此表，因為 P0 strict gate 必須無條件通過。
const responsiveKnownFindings = <ResponsiveKnownFinding>[
  ResponsiveKnownFinding(
    id: 'RSA-003A',
    entryId: 'screen.learning_tools',
    testCaseId: 'phone-200',
    failureKind: ResponsiveFailureKind.layout,
    requiredSignatures: [_renderFlexRight],
    maxOccurrences: 1,
    maxOverflowPixels: 28,
    reason: '學習頁 tab switcher 在 200% 字體無法容納兩個標籤。',
    nextBatch: 'Batch B',
  ),
  ResponsiveKnownFinding(
    id: 'RSA-003B',
    entryId: 'screen.learning_tools',
    testCaseId: '393-160',
    failureKind: ResponsiveFailureKind.layout,
    requiredSignatures: [_renderFlexRight],
    maxOccurrences: 1,
    maxOverflowPixels: 3,
    reason: '學習頁 tab switcher 在 160% 字體已有輕微右側 overflow。',
    nextBatch: 'Batch B',
  ),
  ResponsiveKnownFinding(
    id: 'RSA-003C',
    entryId: 'screen.learning_tools',
    testCaseId: '320-200',
    failureKind: ResponsiveFailureKind.layout,
    requiredSignatures: [_renderFlexRight],
    maxOccurrences: 1,
    maxOverflowPixels: 25,
    reason: '學習頁在 compact 200% 字體的 tab switcher overflow。',
    nextBatch: 'Batch B',
  ),
  ResponsiveKnownFinding(
    id: 'RSA-003D',
    entryId: 'screen.learning_tools',
    testCaseId: '320-300',
    failureKind: ResponsiveFailureKind.layout,
    requiredSignatures: [_renderFlexRight],
    maxOccurrences: 4,
    maxOverflowPixels: 100,
    reason: '學習頁在 compact 300% 字體有多個 tab switcher overflow。',
    nextBatch: 'Batch B',
  ),
  ResponsiveKnownFinding(
    id: 'RSA-004A',
    entryId: 'screen.global_search',
    testCaseId: 'phone-200',
    failureKind: ResponsiveFailureKind.layout,
    requiredSignatures: [_renderFlexRight],
    maxOccurrences: 1,
    maxOverflowPixels: 75,
    reason: '小法助搜尋首頁在 200% 字體的配額與快捷列 overflow。',
    nextBatch: 'Batch B',
  ),
  ResponsiveKnownFinding(
    id: 'RSA-004B',
    entryId: 'screen.global_search',
    testCaseId: '430-200',
    failureKind: ResponsiveFailureKind.layout,
    requiredSignatures: [_renderFlexRight],
    maxOccurrences: 1,
    maxOverflowPixels: 82,
    reason: '小法助搜尋首頁在 430pt、200% 字體的快捷列 overflow。',
    nextBatch: 'Batch B',
  ),
  ResponsiveKnownFinding(
    id: 'RSA-004C',
    entryId: 'screen.global_search',
    testCaseId: '320-200',
    failureKind: ResponsiveFailureKind.layout,
    requiredSignatures: [_renderFlexRight],
    maxOccurrences: 1,
    maxOverflowPixels: 63,
    reason: '小法助搜尋首頁在 compact 200% 字體的快捷列 overflow。',
    nextBatch: 'Batch B',
  ),
  ResponsiveKnownFinding(
    id: 'RSA-005B',
    entryId: 'screen.app_shell_home',
    testCaseId: '320-300',
    failureKind: ResponsiveFailureKind.layout,
    requiredSignatures: [_renderFlexRight],
    maxOccurrences: 9,
    maxOverflowPixels: 52,
    reason: '主 shell 在 compact 300% 字體出現多個合併 overflow。',
    nextBatch: 'Batch A',
  ),
];

/// 目前探索矩陣已確認的非 layout observation；每一筆都精確到標籤與案例。
const responsiveKnownObservations = <ResponsiveKnownObservation>[
  ResponsiveKnownObservation(
    id: 'RSA-OBS-001',
    entryId: 'screen.document_export',
    testCaseId: 'landscape-large',
    kind: ResponsiveObservationKind.clippedPrimaryText,
    value: '書狀預覽與導出',
    reason: '橫向 140% 字體時 PDF 預覽頁的主標題被偵測為裁切。',
    nextBatch: 'Batch C',
  ),
  ResponsiveKnownObservation(
    id: 'RSA-OBS-002',
    entryId: 'screen.app_shell_home',
    testCaseId: 'landscape-large',
    kind: ResponsiveObservationKind.unreachablePrimaryLabel,
    value: '法律即時快問',
    reason: '首頁 shell 在橫向 140% 字體時的主要快問入口不可達。',
    nextBatch: 'Batch A',
  ),
  ResponsiveKnownObservation(
    id: 'RSA-OBS-004',
    entryId: 'screen.app_shell_home',
    testCaseId: '320-300',
    kind: ResponsiveObservationKind.unreachablePrimaryLabel,
    value: '法律即時快問',
    reason: '首頁 shell 在 compact 300% 字體時的主要快問入口不可達。',
    nextBatch: 'Batch A',
  ),
  ResponsiveKnownObservation(
    id: 'RSA-OBS-005',
    entryId: 'screen.app_shell_home',
    testCaseId: '568x320-200',
    kind: ResponsiveObservationKind.unreachablePrimaryLabel,
    value: '法律即時快問',
    reason: '首頁 shell 在 compact landscape 200% 字體時的主要快問入口不可達。',
    nextBatch: 'Batch A',
  ),
  ResponsiveKnownObservation(
    id: 'RSA-OBS-006',
    entryId: 'screen.document_export',
    testCaseId: '932x430-140',
    kind: ResponsiveObservationKind.clippedPrimaryText,
    value: '書狀預覽與導出',
    reason: '寬橫向 140% 字體時 PDF 預覽頁的主標題被偵測為裁切。',
    nextBatch: 'Batch C',
  ),
];

ResponsiveBaselineEvaluation evaluateResponsiveKnownFindings(
  Iterable<ResponsiveAuditResult> results, {
  Iterable<ResponsiveKnownFinding> baseline = responsiveKnownFindings,
  Iterable<ResponsiveKnownObservation> observationBaseline =
      responsiveKnownObservations,
  bool includeOnlyExecutedCases = false,
}) {
  final resultList = results.toList(growable: false);
  final executedCaseKeys = resultList
      .map((result) => '${result.entry.id}/${result.testCase.id}')
      .toSet();
  final findings = baseline
      .where(
        (finding) =>
            !includeOnlyExecutedCases ||
            executedCaseKeys
                .contains('${finding.entryId}/${finding.testCaseId}'),
      )
      .toList(growable: false);
  final observations = observationBaseline
      .where(
        (observation) =>
            !includeOnlyExecutedCases ||
            executedCaseKeys
                .contains('${observation.entryId}/${observation.testCaseId}'),
      )
      .toList(growable: false);
  final regressions = <ResponsiveBaselineRegression>[];
  final matchedFindingIds = <String>{};
  final matchedObservationIds = <String>{};

  for (final result in resultList) {
    final layoutFailures = result.failures
        .where((failure) => failure.kind == ResponsiveFailureKind.layout)
        .toList(growable: false);
    _evaluateLayoutFailures(
      result: result,
      layoutFailures: layoutFailures,
      findings: findings,
      matchedFindingIds: matchedFindingIds,
      regressions: regressions,
    );
    _evaluateObservations(
      result: result,
      observations: observations,
      matchedObservationIds: matchedObservationIds,
      regressions: regressions,
    );
  }

  final stale = findings
      .where((finding) => !matchedFindingIds.contains(finding.id))
      .toList(growable: false);
  final staleObservations = observations
      .where((observation) => !matchedObservationIds.contains(observation.id))
      .toList(growable: false);
  return ResponsiveBaselineEvaluation(
    regressions: regressions,
    staleFindings: stale,
    staleObservations: staleObservations,
  );
}

void _evaluateLayoutFailures({
  required ResponsiveAuditResult result,
  required List<ResponsiveFailure> layoutFailures,
  required List<ResponsiveKnownFinding> findings,
  required Set<String> matchedFindingIds,
  required List<ResponsiveBaselineRegression> regressions,
}) {
  if (layoutFailures.isEmpty) return;
  final finding = _firstWhereOrNull(findings, (item) => item.matches(result));
  if (finding == null) {
    regressions.add(
      ResponsiveBaselineRegression(
        'New layout finding at ${result.entry.id}/${result.testCase.id}.',
      ),
    );
    return;
  }
  matchedFindingIds.add(finding.id);
  if (finding.failureKind != ResponsiveFailureKind.layout) {
    regressions.add(
      ResponsiveBaselineRegression(
        '${finding.id} is configured for an unsupported failure kind.',
      ),
    );
    return;
  }
  if (layoutFailures.length > finding.maxOccurrences) {
    regressions.add(
      ResponsiveBaselineRegression(
        '${finding.id} has ${layoutFailures.length} layout failures; '
        'baseline permits ${finding.maxOccurrences}.',
      ),
    );
  }
  final actualSignatures = layoutFailures
      .map((failure) => failure.effectiveLayoutSignature)
      .whereType<ResponsiveLayoutSignature>()
      .toList(growable: false);
  for (final signature in actualSignatures) {
    if (!finding.requiredSignatures
        .any((expected) => expected.matches(signature))) {
      regressions.add(
        ResponsiveBaselineRegression(
          '${finding.id} emitted an unrecognised layout signature: '
          '${signature.description}.',
        ),
      );
    }
  }
  for (final requiredSignature in finding.requiredSignatures) {
    if (!actualSignatures.any((actual) => requiredSignature.matches(actual))) {
      regressions.add(
        ResponsiveBaselineRegression(
          '${finding.id} no longer contains required layout signature: '
          '${requiredSignature.description}.',
        ),
      );
    }
  }
  for (final failure in layoutFailures) {
    final overflowPixels = failure.overflowPixels;
    if (overflowPixels != null && overflowPixels > finding.maxOverflowPixels) {
      regressions.add(
        ResponsiveBaselineRegression(
          '${finding.id} overflow grew to $overflowPixels px; '
          'baseline permits ${finding.maxOverflowPixels} px.',
        ),
      );
    }
  }
}

void _evaluateObservations({
  required ResponsiveAuditResult result,
  required List<ResponsiveKnownObservation> observations,
  required Set<String> matchedObservationIds,
  required List<ResponsiveBaselineRegression> regressions,
}) {
  for (final observation in _observationsFrom(result)) {
    final baseline = _firstWhereOrNull(
      observations,
      (candidate) =>
          candidate.matches(result) &&
          candidate.kind == observation.kind &&
          candidate.value == observation.value,
    );
    if (baseline == null) {
      regressions.add(
        ResponsiveBaselineRegression(
          'New ${observation.kind.name} observation at '
          '${result.entry.id}/${result.testCase.id}: ${observation.value}.',
        ),
      );
      continue;
    }
    matchedObservationIds.add(baseline.id);
  }
}

Iterable<_ResponsiveObservationValue> _observationsFrom(
  ResponsiveAuditResult result,
) sync* {
  for (final label in result.missingPrimaryLabels) {
    yield _ResponsiveObservationValue(
      ResponsiveObservationKind.missingPrimaryLabel,
      label,
    );
  }
  for (final label in result.unreachablePrimaryLabels) {
    yield _ResponsiveObservationValue(
      ResponsiveObservationKind.unreachablePrimaryLabel,
      label,
    );
  }
  for (final label in result.clippedText) {
    yield _ResponsiveObservationValue(
      ResponsiveObservationKind.clippedPrimaryText,
      label,
    );
  }
  if (result.mediaQueryMismatch != null) {
    yield _ResponsiveObservationValue(
      ResponsiveObservationKind.mediaQueryMismatch,
      result.mediaQueryMismatch!,
    );
  }
}

T? _firstWhereOrNull<T>(Iterable<T> values, bool Function(T value) matches) {
  for (final value in values) {
    if (matches(value)) return value;
  }
  return null;
}

class _ResponsiveObservationValue {
  const _ResponsiveObservationValue(this.kind, this.value);

  final ResponsiveObservationKind kind;
  final String value;
}
