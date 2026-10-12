# SemesterOS Responsive Design

Status: Phase 0 specification (2026-10-12). Layout depends on the window width class, never on the device model.

## 1. Width classes

| Class | Width (logical px) | Navigation | Gutter |
|---|---|---|---|
| Compact | < 600 | NavigationBar (bottom), FAB for quick add | 16 |
| Medium | 600–839 | NavigationRail with quick-add button | 24 |
| Expanded | ≥ 840 | Extended NavigationRail (labels) with quick-add button | 24 |

Breakpoints come from `MediaQuery.sizeOf(context).width` of the app window, so split-screen, slide-over, freeform windows and rotation all re-evaluate. Breakpoints may move if Phase 6 testing shows a better split; changes are recorded here.

Content max width is 720 for reading columns; extra space goes to secondary panes, not wider text.

## 2. Screens

| Screen | Compact | Medium | Expanded |
|---|---|---|---|
| Today | single column in the order of UX_FLOWS §3 | two columns: next action + sessions / progress + deadlines | three regions: next action + sessions / deadlines / weekly load + secondary card |
| Plan | 7-day chip strip with load bars above a day agenda | 3-day view | 7-day time grid + unscheduled tray on the right |
| Proposal review | full-screen route | full-screen route | side panel next to the grid |
| Tasks / Subjects | list → detail route | list → detail route | master-detail (list 360 px + detail) |
| Insights | stacked charts | 2-column grid | 2- or 3-column grid |
| Settings | list → page | list → page | master-detail |
| Session timer | full screen | full screen | centered panel, max width 560 |

The mini session bar sits above the NavigationBar on compact and at the bottom of the content area on medium/expanded.

## 3. Master-detail rules (expanded)

- Empty detail pane: "Select a task" with a quick-add button.
- Selection survives rotation and resize; shrinking to medium/compact keeps the selected item open as a pushed route.
- Switching items with unsaved edits triggers "Discard changes?".

## 4. Text scaling and orientation

- Tested at text scale 1.0, 1.5 and 2.0. At ≥ 1.3 the planner forces the agenda layout at every width.
- Landscape compact phones use the compact layout with the NavigationBar; content scrolls, never clips.
- No fixed heights on text containers; lists use lazy builders.

## 5. Testing matrix

| Check | How |
|---|---|
| Navigation per class | widget tests at 360, 700, 1024 dp |
| No overflow | widget tests at 360/700/1024 × text scale 1.0/2.0 on Today, Plan, Tasks, proposal |
| Resize behavior | widget test 1024 → 700 → 1024 keeps the selected task |
| Goldens | macOS only, light and dark, compact and expanded |
| Real devices/simulators | Phase 6: iPhone SE 3, iPhone 15 Pro Max, iPad mini, iPad Pro 13 (simulators present on this Mac); an Android phone and tablet emulator |
| Split screen | Phase 6 manual check on iPad (Split View) and Android tablet emulator (multi-window); result recorded |
