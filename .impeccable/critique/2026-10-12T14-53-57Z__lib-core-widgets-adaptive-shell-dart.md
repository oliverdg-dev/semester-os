---
target: Phase 1 shell and design tokens
total_score: 18
max_score: 28
na_heuristics: 5,7,10
p0_count: 0
p1_count: 2
target_identity: "file:/Users/oliskiee/semester-os/lib/core/widgets/adaptive_shell.dart"
target_fingerprint: "sha256:1492e9e8cdd53cfd99ca7993493d1619bc32cfed627c75d7db6194ef84d8ac16"
target_path: /Users/oliskiee/semester-os/lib/core/widgets/adaptive_shell.dart
timestamp: 2026-10-12T14-53-57Z
slug: lib-core-widgets-adaptive-shell-dart
---
# Critique: SemesterOS Phase 1 shell and tokens (2026-10-12)
Method: dual-agent. Evidence: iPhone 15 sim iOS 17.5, Pixel Fold emulator (light/dark), 360/1024 goldens.

Score 18/28 (n/a: 5, 7, 10). H1 3, H2 3, H3 2, H4 1, H6 3, H8 3, H9 3.

Specificity: docs product-specific, pixels stock M3 (teal seed = Tailwind teal-700, Tailwind 700 subject palette, centered icon+headline empty state). Detector: exit 0 on lib/ but scans web patterns only, no Flutter signal. Manual: no Cupertino code, Motion tokens unused, raw size 32 x2, no SafeArea on rail, no semantics/meetsGuideline/iOS tests.

## Priority issues
- [P1] iOS build is Material (NavigationBar ~80pt, Material icons, centerTitle false, no large titles, flat Settings list; DESIGN_SYSTEM §5/7/9 Material-only) vs BD6. Fix: Cupertino tab bar + icons on iOS, large titles, platform title alignment, inset grouped Settings, per-platform mapping table. /impeccable adapt
- [P1] Today empty state is a centered generic block; no action; duplicates NextActionBlock "No tasks" state. Fix: NextActionBlock top-anchored with headline token + one filled button (quick add); EmptyState top-start, no icon, scrollable. /impeccable layout, onboard
- [P2] Responsive divergence: landscape phone gets extended rail; 720 cap unused; Settings drops rail on expanded; EmptyState not scrollable (predicted overflow at 2.0 landscape); tests height fixed 900. /impeccable adapt, harden
- [P2] Seed-derived M3 roles uncontrolled/untested; subject 1 == accent; raspberry/wine near capacity; error == capacity. /impeccable extract, audit
- [P2] Type scale lacks tabular numeric, timer, iOS large title, page-title vs headline split, date-line slot. /impeccable typeset

## Personas
Maya (between classes): dead-end instruction, no date, gear out of reach, foreign iOS tab bar, landscape rail. Sam (screen reader, 2.0): predicted landscape overflow, headline not a header. Alex (tablet): Settings drops rail, About outside router, rail 30% width with uncapped content.

## Minor
SemanticColors lerp snaps; tab bar edge 1.07:1 in light; empty rail leading area; Settings 16 vs 24 gutter; ErrorState always alarm red; 12px nav labels.

## Questions
Plex for content + SF for iOS controls? Non-red ink for capacity? Insights tab empty in week one?
