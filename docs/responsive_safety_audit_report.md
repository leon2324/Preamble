# Responsive Safety Audit Report

## 執行基準

- Audit definition recorded at: `2026-07-15T00:00:00+08:00`
- Branch: `test/responsive-safety-matrix`
- Product baseline commit: `224e48f7929956cfb9e6dec9cae14a7ac53aac99`
- Runtime registry: 2 strict shared components, 9 automated product screens,
  4 manual-only entries.
- Manual-only pages are not counted as covered: case library/dossiers,
  law-assistant chat, saved notes, and profile setting sheets.

## Contract Result

`IslandBottomNav` and `LearningResultActionBar` pass the strict verified range
from 80% through 140% text scaling. `IslandBottomNav` also passes strict iPhone
safe-area regressions at 393x852 / 200% and 320x568 / 200% and 300%; it grows
from the measured, width-constrained label content without hiding a label or
shrinking Dynamic Type. All automated screens additionally pass a P0 strict
matrix at normal and 120% text scaling. The extended matrix compares unfixed
P1/P2 violations against `responsive_known_findings.dart`: an
unregistered error/observation, a direction or widget-signature change, a
higher count, or a materially larger overflow fails the test instead of merely
being printed.

The screen audit uses the real product widget for every automated entry. It
records layout violations, missing registered primary labels, unreachable
actions, clipping, and unexpected exceptions independently. A passing
exploratory audit means every observed layout failure matches the
known-findings baseline and no non-layout exception was swallowed. P1/P2
reachability and clipping observations remain visible in the generated report;
the P0 strict matrix rejects any such primary-action failure. A disappeared
baseline item is emitted as `stale` for explicit removal review.

## Batch A2: Dynamic bottom-navigation reservation

`MylawApp` keeps the existing floating Stack-based Island navigation, including
its transparent background, blur, rounded shape, shadow, 17pt outer offset, and
Home Indicator safe area. The rendered Nav and App shell share one
content-driven layout-metrics contract. `AppShellContentInsets` distributes only
the Dynamic Type growth above the Nav's minimum shell height to existing page
content spacing; it excludes both the Home Indicator safe bottom and 17pt outer
offset. The IndexedStack remains full-screen, so every Tab background continues
to paint through the bottom of the display and existing per-page spacers are not
counted a second time at normal text sizes.

The strict shell regression covers `393x852` at 100%, 140%, 160%, 200%, and
235%, plus `320x568` at 300%. It records both the legacy Stack overlap and the
old A2 background-shortening geometry, then verifies that full-screen tab
backgrounds remain intact while the final-content sentinel no longer intersects
the Nav.
Learning's top SafeArea is explicitly protected at a 59pt top inset for 100%,
160%, and 200%; Batch A2 does not alter its background, header, or status-bar
treatment.

## Runtime Matrix

| Matrix | Executions | Violating executions | Result |
| --- | ---: | ---: | --- |
| P0 strict screen gate | 36 | 0 | Pass |
| Strict component gate | 25 | 0 | Pass |
| Extended component audit | 40 | 0 | Pass |
| Screen fast | 45 | 9 | Findings recorded |
| Screen deep | 32 | 3 | Findings recorded |
| Screen extreme | 18 | 6 | Findings recorded |

No P0 condition was reproduced: no overflow occurred at normal text scaling or
at the 120% cases in the automated matrix. P0 scenarios cannot be added to the
known-findings baseline.

## P1: 140% to 200% Reproducible Risks

### RSA-002: Home V2 cards at compact and landscape large text

- **Widget candidates:** `HomeV2QuickAskSection`, `HomeV2WatchlistCard`, and
  `HomeV2ToolsDrawer`.
- **Files:** `lib/components/home/v2/home_v2_bento_cards.dart:66-226,
  253-388, 755-904`.
- **Matrix:** `320x568 / 1.4` and `852x393 / 1.4`; larger right and bottom
  overflows also appear at `393x852 / 2.0`.
- **Evidence:** direct `HomePage` reproduces right overflow `2.2px` and bottom
  overflow `15px` at compact 140%; landscape reports bottom overflow up to
  `194px`.
- **Impact:** the main home flow does not satisfy the large-text contract.
- **Suggested fix:** audit each compact card row before applying a global
  layout change; make the text-bearing row flexible or stack its controls.
- **Regression:** add targeted cases for each confirmed card before fixing.

### RSA-003: Learning tab switcher at large text

- **Widget:** `KnowLawPageState._buildTabSwitcher`.
- **File:** `lib/pages/learning/know_law_page.dart:958-1030`.
- **Matrix:** `393x852 / 1.6` produces a `2px` right overflow; `393x852 / 2.0`
  produces `26px`; compact extreme cases grow to `93px`.
- **Impact:** `法學課堂` and `生活工具箱` share a two-column row whose labels
  cannot safely grow.
- **Suggested fix:** measure the two labels and allow a two-row or scrollable
  segmented treatment only when content no longer fits; do not shrink text or
  truncate the tab labels.
- **Regression:** add a dedicated tab-switcher widget test for 160% and 200%.

### RSA-004: Global search home at 200%

- **Widget candidate:** `_AssistantQuotaCapsule` and the horizontal quick
  action rows.
- **Files:** `lib/pages/search/widgets/search_home_widgets.dart:119-161,
  437-459`; secondary candidates are in
  `lib/pages/search/global_search_page.dart:365-375, 1857-1896`.
- **Matrix:** `393x852 / 2.0` overflows right by `73px`; `430x932 / 2.0` by
  `79px`; `320x568 / 2.0` by `60px`.
- **Impact:** the legal search / Quick Ask landing flow has a reproducible
  large-text horizontal overflow.
- **Suggested fix:** make quota and shortcut content content-aware, with a
  wrap or vertically stacked fallback that keeps the search field usable.
- **Regression:** cover 200% portrait and a keyboard-inset case after the
  actual culprit is narrowed with a focused test.

### Additional P1 observation: document export title in landscape

- **Widget:** `LegalDocumentExportPage` primary title.
- **Matrix:** `852x393 / 1.4` and `932x430 / 1.4`; the primary title is
  detected as clipped inside its fixed-height landscape header.
- **Impact:** the PDF export screen keeps loading, but the main title may not
  be fully readable in a large-text landscape scenario.
- **Follow-up:** include this in Batch C with the document export header and
  add a focused regression test before changing the product layout. It is
  reported by the audit but is not an RSA-001 through RSA-005 layout baseline.

## P2: Extreme Stress Risks

### RSA-005: App shell composite stress

- **Widget:** main shell with all IndexedStack children and bottom navigation.
- **Files:** `lib/main.dart:289-365` plus the P1 candidates above.
- **Matrix:** `320x568 / 3.0` and `568x320 / 2.0`.
- **Evidence:** multiple right/bottom RenderFlex overflows; at 300% the shell
  records right overflow up to `49px` and repeated bottom overflows of `45px`.
- **Impact:** expected stress-only reflow is not yet implemented. This is not a
  normal-text release blocker, but it is an accessibility backlog item.
- **Suggested fix:** resolve RSA-002 through RSA-004 first, then rerun this
  composite case to reveal remaining shell-only failures.

## Static Scan

`dart run tool/responsive_static_risk_scan.dart --summary` found 3,785 review
candidates. These are not bugs until confirmed by runtime audit or manual QA.

| Priority | Pattern | Count | Recommended follow-up |
| --- | --- | ---: | --- |
| P0 | forced text scale | 0 | Keep this at zero. |
| P1 | `FittedBox` | 19 | Ensure no primary text is compressed. |
| P1 | `TextOverflow.ellipsis` | 196 | Review primary-action usage first. |
| P2 | intrinsic layout | 11 | Exercise at 160%+. |
| P2 | single-line text | 120 | Review localized / Dynamic Type clipping. |
| P2 | positioned content | 124 | Check SafeArea and keyboard conditions. |
| P2 | fixed width | 1,086 | Prioritize text-bearing controls. |
| P2 | fixed height | 2,229 | Prefer content-driven minimum heights. |

The non-summary scanner emits every individual candidate with its file, line,
pattern ID, source line, severity, and recommendation. Keep this output
generated rather than committed because the 3,785 entries are mechanical and
change with normal source edits.

## Recommended Repair Batches

1. **Batch A - home cards:** RSA-002.
2. **Batch B - learning tabs and search rows:** RSA-003 and RSA-004.
3. **Batch C - keyboard and sheets:** profile sheets, search action sheet, and
   saved notes after their presenters gain test seams.
4. **Batch D - case library and long legal content:** inject case repository
   fakes, then audit dossiers, forms, and segmented controls.
5. **Batch E - static candidate reduction:** review remaining ellipsis,
   fixed-height cards, and positioned decorative content after runtime P1 work.
