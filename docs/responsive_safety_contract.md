# Responsive Safety Contract

## Purpose

This contract defines the minimum responsive behavior that the Preamble Flutter
app must preserve. It is a regression gate for verified shared components and
an evidence-gathering audit for screens not yet remediated.

- Audit definition recorded at: `2026-07-15T00:00:00+08:00`
- Product baseline commit: `224e48f7929956cfb9e6dec9cae14a7ac53aac99`

## Matrix

Fast matrix runs every automated registry entry at `320x568 / 1.0`,
`320x568 / 1.4`, `393x852 / 1.0`, `393x852 / 2.0`, and `852x393 / 1.4`.

Deep matrix adds `0.8`, `1.2`, `1.4`, `1.6`, and `2.0` text scales across
portrait and landscape sizes. English locale is opt-in: an entry must declare
that it can safely run without an application localization delegate.

Extreme stress runs selected primary flows at `2.0` and `3.0` text scaling,
small landscape, and keyboard insets of `300` and `400` logical pixels.

The P0 strict screen gate runs every automated screen at `320x568 / 1.0`,
`393x852 / 1.0`, `393x852 / 1.2`, and `430x932 / 1.2`. It accepts no layout
exception, missing/unreachable primary action, clipping, or unexpected error.

## Safety Rules

- No `RenderFlex` overflow, unbounded viewport, infinite constraint, or
  unlaid-out render box exception.
- Primary labels and actions registered for a screen must remain visible inside
  the viewport. Registered actions must be hit-testable; scrollable entries use
  `ensureVisible` before being classified as unreachable.
- A screen may reflow, scroll, or move an action below the fold; it may not
  silently truncate a primary label with ellipsis, fade, clip, max-lines, or a
  clipped fixed-height container, nor make the action unreachable.
- Safe-area and keyboard cases must keep fixed bottom controls within the
  usable viewport. Keyboard cases retain `viewPadding.bottom`, set
  `viewInsets.bottom`, and calculate `padding.bottom` from their difference.
- `IslandBottomNav` and `LearningResultActionBar` are strict gates: any layout
  exception, clipped text, or missing registered action fails their test.
  `IslandBottomNav` additionally has strict iPhone-safe-area regressions at
  `393x852 / 2.0`, `320x568 / 2.0`, and `320x568 / 3.0`; the latter may grow
  vertically from measured label content but must retain every label and action.
- The App shell has a separate strict bottom-reservation gate at `393x852 / 1.0`,
  `1.4`, `1.6`, `2.0`, and `2.35`, plus `320x568 / 3.0`. It measures the same
  `IslandBottomNav` layout contract used by the rendered Nav and exposes only
  the Dynamic Type growth beyond its minimum shell footprint through the shared
  `AppShellContentInsets` contract. Tab backgrounds remain full-screen; only
  existing scroll or content bottom spacing consumes this extra inset. The
  shared value excludes the Home Indicator safe bottom and the floating Nav's
  17pt outer offset. The shell must keep a positive content height and must not
  place final reachable content behind the floating Nav. This rule does not
  change any page's own top SafeArea contract.
- `KnowLawPage` keeps its notebook background behind the status bar, but its
  ListView owns the current `MediaQuery.padding` for top, bottom, left, and
  right safety. If an outer shell has already consumed an inset, the page sees
  zero for that side and retains only its design spacing; this avoids a double
  top inset without changing the existing Learning tab-switcher RSA baseline.
- Home V2 has a strict large-text regression gate at `320x568 / 1.4`,
  `393x852 / 2.0`, and `852x393 / 1.4`. Card reflow follows available
  constraints and measured content, without forced scaling or fixed text-scale
  breakpoints. `screen.home_page` declares `requiresScroll`, so below-fold
  labels are inspected after the existing `ensureVisible` flow.

## Registry Policy

The registry uses real product widgets. `declaredStates` documents the product
states intended for each entry; it is not test coverage until a state owns an
independent builder or fixture. Pages coupled to a singleton database,
remote service, or platform plugin are recorded as `manual-only` until a small,
product-neutral dependency-injection seam exists. They are not reported as
covered.

## Static Scan

Run:

```bash
dart run tool/responsive_static_risk_scan.dart --summary
dart run tool/responsive_static_risk_scan.dart
```

The static scanner reports candidates such as forced text scaling, ellipsis,
fixed content dimensions, `Positioned`, and intrinsic layout. A hit is a review
signal, not a confirmed runtime defect; classify it against the runtime audit.

## Current Coverage

Automated component gates:

- `component.island_bottom_nav`
- `component.learning_result_action_bar`

Automated screen entries:

- main navigation home shell
- learning tools and learning article
- journal
- profile
- global search
- statute database
- document export

Manual-only entries and their dependency reasons live in
`test/support/responsive_audit_registry.dart`.

## Known Findings Baseline

`test/responsive/responsive_known_findings.dart` records each accepted P1/P2
layout finding by entry ID and test case ID, including its RenderFlex direction,
optional widget/library signature, occurrence count, and maximum overflow
pixels. It separately records exact primary-action observations such as a
specific clipped label. The exploratory audit fails for any unregistered
layout/observation, any extra occurrence, a direction or widget-signature
change, or any severity increase. Findings that no longer reproduce are
reported as stale so the baseline can be removed deliberately; they are never
silently retained.

The audit writes deterministic JSON and Markdown summaries to stdout with the
baseline commit, run metadata, known findings, regressions, stale findings,
unexpected exceptions, and manual-only entries. CI may collect stdout as an
artifact without a test writing generated files into the working tree.
