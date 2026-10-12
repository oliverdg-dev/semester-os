# SemesterOS Design System

Status: tokens implemented in `lib/app/theme/tokens.dart` (Phase 1, 2026-10-12; revised by the Phase 2 design pass on 2026-10-12 after the impeccable critique in `.impeccable/critique/`, decisions BD5/BD6); `test/theme/contrast_test.dart` recomputes every ratio below and fails if any drops under its target. IBM Plex Sans 1.1.0 is bundled (see §3).

## 1. Brand

- **Promise:** Know what matters. Know what to do next. Stay in control of your semester.
- **Personality:** calm, exact, on your side. The app is a steady study partner, not a coach that scolds.
- **Classifier:** OPERATE (app UI) everywhere. Utility language: orientation, status, action. Onboarding has one short welcome moment and nothing more.
- **Use scene:** a student glancing at the phone between classes in daylight, and planning at a desk on Sunday evening. Light theme by default, follows the system setting, dark fully supported.
- **Voice:** short, supportive, specific. "Three tasks remain. Let's find a realistic time for them." Never "You failed", never guilt, no exclamation marks in warnings.
- **Avoid:** card mosaics, gradients, glows, decorative blobs, emoji in UI, icon-in-colored-circle grids, centered-everything layouts, cream-and-serif, neon-on-black.

## 2. Color tokens

Text targets: 4.5:1 for body text, 3:1 for large text and UI boundaries. Ratios below were computed on 2026-10-12 (WCAG relative luminance).

### Light

| Token | Hex | Contrast (on surface #FFFFFF / background #F6F7F8 / surfaceVariant #EEF0F2) |
|---|---|---|
| background | #F6F7F8 | |
| surface | #FFFFFF | |
| surfaceVariant | #EEF0F2 | |
| divider | #E3E6EA | decorative only |
| outline (interactive borders) | #8A929C | 3.15 on surface |
| textPrimary | #15181C | 17.81 / 16.60 / 15.59 |
| textSecondary | #4A525C | 7.92 / 7.38 / 6.93 |
| accent | #0F766E | 5.47 / 5.10 / 4.79 |
| onAccent | #FFFFFF | 5.47 on accent |
| accentContainer | #D5F0EC | |
| info | #3B5B7A | 7.09 / 6.61 / 6.20 |
| attention | #8A5A00 | 5.93 / 5.53 / 5.19 |
| capacity | #52398F | 8.97 / 8.36 / 7.85 |
| success | #1E7A3C | 5.38 / 5.01 / 4.71 |
| danger | #B42318 | 6.57 / 6.13 / 5.75 |

Containers for banners (text on them uses the matching strong color or textPrimary): infoContainer #E6EEF6, attentionContainer #FFF1D6, capacityContainer #ECE8F6, successContainer #DFF3E5, dangerContainer #FDE7E5. Their ratios are covered by `test/theme/contrast_test.dart`.

### Dark

| Token | Hex | Contrast (on surface #1A1D21 / background #111315 / surfaceVariant #23272C) |
|---|---|---|
| background | #111315 | |
| surface | #1A1D21 | |
| surfaceVariant | #23272C | |
| divider | #2C3136 | decorative only |
| outline | #6B7380 | 3.53 on surface |
| textPrimary | #E8EAED | 14.03 / 15.45 / 12.46 |
| textSecondary | #A9B0B9 | 7.73 / 8.51 / 6.87 |
| accent | #5EC4B6 | 8.09 / 8.91 / 7.19 |
| onAccent | #04201D | 8.17 on accent |
| info | #9DB8D6 | 8.26 / 9.10 / 7.34 |
| attention | #F2C063 | 10.06 / 11.08 / 8.94 |
| capacity | #B09FDB | 7.11 / 7.83 / 6.31 |
| success | #7BD39A | 9.36 / 10.31 / 8.32 |
| danger | #FF8A80 | 7.41 / 8.16 / 6.58 |

Dark containers: accentContainer #12403B, infoContainer #1D2B3A, attentionContainer #3A2C10, capacityContainer #29234A, successContainer #173222, dangerContainer #3D1D1B (each passes 4.5:1 with its strong color and with textPrimary; see test/theme/contrast_test.dart).

### Color rules

- **capacity** (more work than time) is an indigo ink, never red: the app is honest about capacity without sounding an alarm (owner, 2026-10-12). **danger** is only for real failures and destructive confirmations; Material's `error` role maps to it.
- Every Material color role is mapped explicitly from the palette in `schemeFor()` (`lib/app/theme/app_theme.dart`), not derived from a seed, and `test/theme/contrast_test.dart` checks each on-color pair at 4.5:1. Sheets, dialogs and menus share the surface color; snackbars use the opposite theme's surface, text and accent.

### Subject palette (10 colors, stored as `colorIndex`)

Used as a swatch next to the subject name (never as the only identifier).

| Index | Light | vs #FFFFFF | Dark | vs #1A1D21 |
|---|---|---|---|---|
| 0 Blue | #255893 | 7.25 | #7CAADE | 6.98 |
| 1 Plum | #8F3D8F | 6.50 | #C270C2 | 5.15 |
| 2 Green | #339955 | 3.60 | #94DBAC | 10.46 |
| 3 Rose | #8E294B | 8.17 | #DA819E | 6.13 |
| 4 Orange | #A54312 | 6.16 | #EF986C | 7.55 |
| 5 Olive | #719C1C | 3.24 | #C0E774 | 12.02 |
| 6 Ochre | #AA7B0E | 3.78 | #F3C968 | 10.76 |
| 7 Sky | #1281A5 | 4.46 | #6CCEEF | 9.43 |
| 8 Slate | #535A65 | 6.96 | #9AA2AC | 6.55 |
| 9 Brown | #815637 | 6.33 | #CEA88D | 7.74 |

Swatches stay visibly apart from the accent and capacity colors (RGB distance above 50) and from each other (above 40) so a subject never reads as a link, a selection or a warning; the contrast test enforces both.

## 3. Typography

- Typeface: **IBM Plex Sans** (SIL OFL) for content on both platforms (headlines, the next action, body, numbers). On iOS, controls use the system face (SF, `kIosSystemFontFamily`): navigation titles (17 pt semibold), large titles, tab bar labels and settings rows (owner, 2026-10-12). Android uses Plex throughout.
- Plex is bundled in `assets/fonts/` (Regular 400, Medium 500, SemiBold 600, version 1.1.0, licence in `assets/fonts/OFL.txt`) and set via `kAppFontFamily` in `lib/app/theme/app_theme.dart`; `test/theme/font_test.dart` checks the files, the pubspec weights and that every text style uses it. No runtime font fetching (google_fonts runtime loading breaks offline-first).
- Tabular figures (`FontFeature.tabularFigures()`) for times, durations, timers and numbers in tables.
- Scale (logical px / line height): displaySmall 32/40 SemiBold · headlineSmall 24/32 SemiBold (the Today next action, one step above every other content heading) · titleLarge 20/28 SemiBold (Android page titles) · titleMedium 16/24 SemiBold (empty-state and section headlines) · body 16/24 Regular · bodySmall 14/20 Regular · label 14/20 Medium · caption 12/16 Regular. iOS page titles are the system large title (34 pt bold) collapsing to the inline title.
- Extra roles in the `AppTextStyles` theme extension (`context.appText`), all with tabular figures: `numeric` (body size, times and durations in text), `numericLarge` (headline size), `timer` (56/64 Medium, the session timer), `dateLine` (14/20 Medium secondary, "Monday 12 October" under a page title).
- Body text is never below 16. Captions are for metadata only, never for actions or warnings.
- Headings sit closer to the content they introduce than to the content above (more space above than below).

## 4. Spacing, radii, elevation

- Spacing scale (4-pt): 4, 8, 12, 16, 24, 32, 48. Page gutter 16 (compact), 24 (medium/expanded). Max readable content width 720.
- Radii: 4 (chips, badges), 8 (inputs, list blocks, session blocks), 16 (bottom sheets, dialogs). No uniform bubbly radius.
- Elevation: surfaces are flat and separated by dividers or surfaceVariant. Elevation (with offset shadow) only for bottom sheets, dialogs, the FAB and the mini session bar.

## 5. Icons

Android: Material Icons. iOS: Cupertino icons (`cupertino_icons`, the SF Symbols look) for navigation and controls. Destinations: Today = sun, Plan = calendar (Android) / week columns (iOS), Tasks = checklist, Insights = bar chart. Icons always accompany text for status; standalone icon buttons carry a tooltip (Android) or a semantics label (iOS). No emoji.

## 6. Motion

- Durations 150-250 ms, `Curves.easeOutCubic`. Page transitions use the platform default.
- Motion only clarifies change: a session block moving after Accept, a banner appearing, the timer starting.
- Reduced motion (`MediaQuery.disableAnimationsOf(context)`): transitions become instant.

## 7. Components

| Component | Purpose | Notes |
|---|---|---|
| AdaptiveShell | top-level navigation | iOS: system tab bar at every size. Android: NavigationBar (compact), NavigationRail with labels (medium), permanent NavigationDrawer (expanded, widens with text size). Mini session bar slot. `lib/core/widgets/adaptive_shell.dart` |
| PageScaffold | frame of a top-level page | iOS: large title collapsing on scroll, Settings at the trailing edge. Android: pinned top app bar with a Settings action. Optional date line. Always scrolls; body capped at 720 and aligned to the start edge. |
| DetailScaffold | frame of a pushed screen (Settings, details) | iOS: system navigation bar with centered title and back chevron. Android: Material top app bar. |
| SettingsSection | settings-shaped lists | iOS: inset grouped list. Android: list tiles on the page gutter. |
| NextActionBlock | Today's single visual anchor | top of Today on the gutter; headlineSmall headline, one supporting line, one filled button at most. `lib/features/dashboard/presentation/widgets/next_action_block.dart` |
| SessionListTile | session in a list: time range, task, subject swatch, status label | semantics label includes all of it |
| SessionBlock | session in the planner grid | pinned icon + label, never color only |
| DeadlineItem | task, subject, "Due Fri, end of day", status | |
| TaskListTile | title, subject, deadline, progress bar | |
| SubjectRow | swatch, name, course code, counts, next deadline | |
| WarningRow / WarningBadge | the warning taxonomy (§8) | one component everywhere |
| AttentionBanner | single banner slot on Today/Plan | non-modal |
| ProposalSummary | "24 sessions over 3 weeks · 2 tasks don't fit · 1 deadline at risk" | |
| MiniSessionBar | active/paused session above the navigation | task, elapsed, Pause/Complete |
| SessionTimer | full-screen timer | tabular figures, large type |
| EmptyState | headline, one sentence, one primary action | top-start on the gutter where content will appear (no centered block, no icon); headline marked as a heading. Copy in UX_FLOWS.md |
| ErrorState | what happened, Retry / Go to Today, error code | neutral icon, not red: calm even when something failed |
| PrimaryActionButton | the one primary action of a screen | |

Cards are used only for the Today secondary slot and the proposal summary.

## 8. Warning taxonomy

| Warning type | Level | Icon | Label pattern | Placement | Action |
|---|---|---|---|---|---|
| plannedLater | info | schedule | "Planned later (from Mon 14)" | inline on task | none |
| overdue | attention | error_outline | "Overdue since Tue" | inline + Today slot | Plan it now |
| pinnedConflict | attention | push_pin | "Outside your study times" (or limit / after deadline / busy time) | inline on session | Unpin |
| taskAlreadyComplete | attention | task_alt | "Task already complete" | inline on session | Remove session |
| sessionAfterDeadline | attention | event_busy | "After the deadline" | inline on session | Update plan |
| deadlineAtRisk | capacity | warning_amber | "About 2 h short before Fri 14" | proposal summary + inline | See what doesn't fit |
| notEnoughTime | capacity | warning_amber | "Doesn't fit before its deadline" | unscheduled tray | Add study time |
| overloadedDay | capacity | view_day | "About 90 min over your daily limit" | planner day header | Review this day |
| termOverload | capacity | warning_amber | "About 6 h more than your study time before Fri 14" | Today slot + proposal | Add study time · Review estimates · See what doesn't fit |
| planNeedsAttention | attention | update | "Your plan needs attention" | Today/Plan banner | Review changes |
| backupReminder | info | backup | "Back up your semester" | Today slot | Back up now |

Info = neutral information; attention = something the student should look at; capacity = there is more work than time. Color is always paired with the icon and the text label. A test compares this table with the warning enum in code.

## 9. Forms and buttons

- Visible labels above fields (never placeholder-only). Errors appear under the field in capacity color with an icon, and entered data is kept.
- Primary button: filled accent. Secondary: outlined. Destructive actions: text button in capacity color inside a confirmation.
- Touch targets ≥ 48 × 48 dp.
- Pickers and controls follow the platform (BD6): iOS uses Cupertino date/time pickers, `CupertinoSegmentedControl`/sliding segmented control for task type and priority, switches and action sheets; Android uses Material 3 pickers, segmented buttons, switches and bottom sheets. Primary actions on iOS that live in a navigation bar (Add, Done) use the bar, not a FAB.

## 10. Charts

- fl_chart, flat, no gradients, accent and textSecondary series colors; gridlines in divider color.
- Each chart has a one-sentence text summary above it that is also its semantics label ("You studied 6 h 10 m of 8 h planned this week").
- Charts appear only with at least one studied session; otherwise the insight's empty state shows.

## 11. States checklist

Every screen defines: loading (none under ~150 ms for local reads; inline progress for plan generation), empty (copy + action), error (ErrorState with code), success (snackbar with Undo where reversible), partial (unscheduled/conflict sections). Session states are shown with icon + label: Planned, Active, Paused, Completed, Skipped, Missed.

## 12. Accessibility

- Contrast as measured above, enforced by test.
- Text scale tested at 1.0, 1.5, 2.0; planner switches to agenda at ≥ 1.3.
- Semantics labels on session blocks, chips, icon buttons and charts.
- Logical focus order; visible focus ring on tablets with keyboards or switch access.
- Status never color-only. Timer announces state changes, not every second.
- Flutter `meetsGuideline` tests (tap target, labeled tap target, text contrast) on Today, Plan, Tasks and the proposal screen.

## 13. Platform mapping (BD6)

One shared token set feeds both platforms; structure and controls follow each platform's conventions.

| Need | iOS | Android |
|---|---|---|
| Top-level navigation | Tab bar (all sizes) | NavigationBar → rail → permanent drawer |
| Page title | Large title, collapses on scroll | Pinned small top app bar |
| Pushed screen | Navigation bar, back chevron, edge-swipe back | Top app bar, system Back / predictive back |
| Settings lists | Inset grouped list, chevrons | List tiles |
| Quick add (Phase 2) | "+" in the navigation bar | FAB (compact) or drawer/rail button |
| Pickers, segments, switches | Cupertino controls | Material 3 controls |
| Control font | SF (system) | IBM Plex Sans |
| Content font | IBM Plex Sans | IBM Plex Sans |
| Page gutter | 16 at every size (matches the bar inset) | 16 compact, 24 medium and expanded |

