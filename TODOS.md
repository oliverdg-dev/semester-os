# TODOS

## Planner

### Export the study plan as an .ics calendar file

**What:** Export planned sessions for a chosen range as an .ics file through the system share sheet.

**Why:** Students who live in their phone calendar can see study blocks next to classes without any sync service or API.

**Context:** Deferred by the 2026-10-12 /autoplan CEO review (taste decision E5). Fully offline: generate RFC 5545 text locally and hand it to the share sheet the backup feature already uses. Not needed for the v1 acceptance criteria. Start after Phase 7 backups exist so the file-sharing path is reused.

**Effort:** M (human) / S (CC)
**Priority:** P2
**Depends on:** Phase 7 export/share path

## Capture

### Import deadlines from an LMS calendar (.ics) file

**What:** Pick an .ics file exported from Canvas, Moodle, Blackboard or Brightspace and turn its events into draft tasks the student confirms.

**Why:** Typing in every deadline is the biggest setup cost; most LMSs already export a calendar file.

**Context:** Raised by the 2026-10-12 /autoplan CEO voice (F1a), deferred as a taste decision. Fully offline: parse the file locally, show a review list with type guesses, never auto-create. LMS .ics files vary (all-day vs timed events, duplicate UIDs), so build a fixture corpus first.

**Effort:** M (human) / S (CC)
**Priority:** P1
**Depends on:** Phase 2 task repository; file picker

### Paste a syllabus to draft tasks

**What:** Paste syllabus text; a local rule-based parser finds lines with dates and proposes draft tasks.

**Why:** Same setup-cost problem for courses without an LMS export.

**Context:** CEO voice F1b. Rule-based first; an optional on-device model could improve it later (see Platform). Always a review step before saving.

**Effort:** M (human) / M (CC)
**Priority:** P2
**Depends on:** Import review UI from the .ics item

## Onboarding

### Optional sample semester

**What:** Let onboarding load a clearly labeled sample semester that can be removed in one tap.

**Why:** An empty app is the main reason new users never add a first task.

**Context:** Deferred by the 2026-10-12 /autoplan CEO review (taste decision E3) because the brief forbids misleading placeholder statistics. If built, sample rows must be tagged in the database, excluded from insights by default and removable in one transaction.

**Effort:** S (human) / S (CC)
**Priority:** P3
**Depends on:** Phase 2 repositories

## Data

### Semester/term entity with end-of-term archive

**What:** Add a Term table, assign subjects to a term, and archive finished terms out of every active view.

**Why:** After one semester the task and subject lists fill with finished work; the product name promises semester-level control.

**Context:** Deferred by the 2026-10-12 /autoplan CEO review (E9). Requires a Drift schema migration (nullable termId on subjects, backfilled to a default term) and filters in every list query. Design the v1 schema so this is additive.

**Effort:** M (human) / S (CC)
**Priority:** P2
**Depends on:** v1 schema and migration test harness

## Platform

### Home-screen widget showing the next session

**What:** Android App Widget and iOS WidgetKit extension that show the next planned session and a start button.

**Why:** Puts "what do I do next" one glance away without opening the app.

**Context:** Deferred by the 2026-10-12 /autoplan CEO review (E4). Needs native code per platform plus a shared read path into the SQLite file (for example the home_widget package, license and maintenance to be checked). Outside v1 blast radius.

**Effort:** L (human) / M (CC)
**Priority:** P3
**Depends on:** Stable v1 release

### Read-only device calendar busy times

**What:** Optionally read the device calendar and treat its events as busy time for scheduling.

**Why:** Classes, shifts and trips already live in the calendar; one-off busy times (v1) still need manual entry.

**Context:** CEO voice F5, deferred. Offline through platform calendar APIs; needs permission flows on both platforms and a dependency check (license, maintenance).

**Effort:** M (human) / S (CC)
**Priority:** P2
**Depends on:** v1 availability exceptions

### Web or desktop build

**What:** Evaluate a Flutter web or macOS/Windows build for planning on a laptop.

**Why:** Students often plan on laptops and execute on phones.

**Context:** CEO voice F11. Layout is already width-based; Drift supports web (WASM) and desktop. Without sync, a desktop copy has separate data, so pair with export/import or a future sync.

**Effort:** M (human) / S (CC)
**Priority:** P3
**Depends on:** Stable v1

### Optional on-device model for parsing and explanations

**What:** Use Apple Foundation Models or Android on-device GenAI, where the device supports it, to improve syllabus parsing and plain-language explanations; rule-based path remains the fallback.

**Why:** Free, offline and keyless, so it fits the zero-budget rules.

**Context:** CEO voice F12. Device coverage is limited; never required for core features.

**Effort:** L (human) / M (CC)
**Priority:** P4
**Depends on:** Syllabus parser

## Completed
