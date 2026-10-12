# SemesterOS UX Flows

Status: Phase 0 specification (2026-10-12). Copy in quotes is the shipping copy unless a later review changes it; widget tests assert it.

## 1. Navigation map

```
  Today ── Plan ── Tasks (Tasks | Subjects segment) ── Insights        (4 destinations)
    │        │        │
    │        │        └─ Task detail / form · Subject detail / form
    │        ├─ Proposal review · Weekly review · Availability (study times)
    │        └─ Session detail · Edit time
    ├─ Session timer (from mini session bar or Start)
    └─ Header: Notices · Settings
                         └─ Planning defaults · Study times · Theme · Reminders · Backup ·
                            About & diagnostics · Developer (debug builds only)
  Quick add: FAB on Today, Plan, Tasks (compact); rail button (medium/expanded)
  Recovery screen: shown instead of the app when the database cannot be opened safely
```

## 2. First run and onboarding

```
  Welcome ──▶ Study times ──▶ Session length & breaks ──▶ Daily limit & theme ──▶ Add your first deadline (quick add)
     │            presets: "Weekday evenings 18–21" · "Weekends 10–16" · "Custom"
     └── Skip ──▶ Today (availability set to Mon–Fri 18:00–21:00, "Edit study times" link shown)
```

- Welcome: "SemesterOS plans your study time around your deadlines. Everything stays on this phone." Buttons: "Get started" / "Skip for now".
- Defaults: session 50 min, break 10 min, daily limit 4 h, theme follows system.
- Notification permission is never asked during onboarding.

## 3. Today

Order (compact):
1. Next-action block (the only primary button on the screen)
2. At most one attention banner. Priority: plan needs attention > term overload > overdue > backup reminder. Others go to Notices.
3. Today's sessions (list)
4. Progress: "1 h 40 m of 3 h studied today" with a bar
5. Deadlines, next 7 days
6. At most one secondary card: weekly review (on weekStartDay) first

### Next-action states

| Situation | Headline | Supporting line | Primary | Secondary |
|---|---|---|---|---|
| Session active | "Studying {task}" | "{elapsed} of {planned} · {subject}" | Pause | Complete |
| Session paused | "Paused: {task}" | "{elapsed} so far" | Resume | Complete · Skip |
| Next session later today | "Next: {task}" | "{start time} · {duration} · {subject}" | Start now | Details |
| Missed today, nothing upcoming | "A session slipped by" | "Let's find a new time." | Re-plan | — |
| Nothing planned today, tasks open | "Nothing planned today" | "Next deadline: {task}, {day}" | Study now | Open Plan |
| No tasks | "Add your first deadline" | "SemesterOS plans the rest." | Quick add | — |
| No study times | "When can you study?" | "Set your study times to get a plan." | Set study times | — |
| All done today | "Today's plan is done" | "{h m} studied today" | Plan tomorrow | — |

"Study now" starts an ad-hoc pinned session for the most urgent task immediately (preferred session length). If it overlaps a planned session, that session is shortened or superseded and "Your plan needs attention" appears.

### Welcome back

When 2 or more sessions were missed since the last app open, Today shows one summary instead of individual alarms: "A few sessions slipped by. Let's re-plan from today." Action: "Re-plan". The planner collapses missed sessions into a "Missed" history group.

## 4. Tasks and subjects

**Quick add** (bottom sheet): Title, Deadline (date; time optional), Type (segmented). Save → estimate from the type default, priority Medium. After save: snackbar "Task added. Schedule it now?" with action "Schedule" (opens a proposal) and the plan-needs-attention banner.

**Full task form:** title, subject (optional), type, deadline date + optional time (date-only shows "Due Fri, end of day"), estimate (prefilled from type default), priority, grade weight % (optional), description, milestones (checklist), "Repeat weekly until {date}" with live preview "Creates 10 tasks, Mondays 09:00, until Dec 15" (max 26).

**Progress:** tracked minutes / estimate as a bar; milestones show "2 of 5 done". Status becomes In progress automatically on the first session start. Completing sets Completed; "Reopen" returns it to Incomplete.

**Unsaved changes:** leaving any form with edits asks "Discard changes?" with "Keep editing" / "Discard".

**Delete task:** confirmation "Delete {task}? This removes {n} study sessions and {h m} of tracked time." Buttons "Cancel" / "Delete". If a session is live: "Finish or skip the current session first." Snackbar "Task deleted" with "Undo" (10 s, announced to screen readers).

**Delete subject:** with tasks: "Delete {subject}?" options "Keep its tasks without a subject" (default) / "Delete its tasks too". With 0 tasks: simple confirmation. Snackbar with Undo restores the subject and its tasks' links (or the deleted tasks).

## 5. Study times (availability)

Seven day rows, each with time-range chips ("18:00–21:00") and "+ Add"; "Copy to weekdays". Below: "One-off busy times" as a dated list with "+ Add busy time" (date, start, end, note). Saving changes raises "Your plan needs attention".

## 6. Planning

**Plan screen:** persistent primary action "Update plan" (first time: "Generate plan"). While generating: the button shows inline progress; navigation stays usable.

**Proposal review** (full-screen on compact, side panel on expanded):
1. Summary line: "24 sessions over 3 weeks · 2 tasks don't fit · 1 deadline at risk"
2. "Doesn't fit" and "Conflicts" sections (with actions from the warning taxonomy)
3. Week groups ("This week · 9 sessions") collapsed; expanding shows sessions with "Why here?" (e.g. "Due in 2 days · High priority")
4. Accept / Reject. On a first-ever plan Reject reads "Not now".
- Accept success: snackbar "Plan updated". Stale: "Your plan changed. Regenerate?" with "Regenerate".

**Triggers** (banner "Your plan needs attention", tap → proposal): session skipped or missed, task created/edited/deleted/completed, deadline changed, study times or busy times changed, actual time far from the estimate (evaluated when a session completes or is skipped). The app never moves sessions without Accept.

**Session detail:** task, time, status, Pin/Unpin, "Edit time" (pins the session; blocks overlap and times outside study times with inline errors; over the daily limit shows "This goes past your daily limit" but allows saving).

## 7. Sessions

- Start: from Today, Plan or session detail. A second start while one is live: "You're already studying {task}. Pause it or finish it first." Buttons "Pause and switch" / "Finish and switch" / "Cancel".
- Mini session bar above the navigation on every screen while a session is active or paused: task, elapsed (tabular), Pause/Resume, Complete. Tap → Session timer.
- Complete sheet: "How long did you study?" minutes field prefilled with elapsed. "Save".
- Skip sheet: "Skip this session?" options "Didn't start" / "Studied some: __ min". Copy stays neutral; no guilt.
- Long-session dialog (elapsed over planned + 60 min, including after restart): "Still studying {task}? You've had it open for {h m}. How long did you actually study?" minutes prefilled with the planned duration. "Save".

## 8. Weekly review

Reachable from Plan at any time and as the Today secondary card on weekStartDay (all day, hidden after dismiss or after "Plan this week" is accepted).
- "Last 7 days: {studied} studied of {planned} planned"
- "Coming up: {n} deadlines" (overdue listed separately)
- Action "Plan this week" → proposal for today to today + 6.

## 9. Insights

- Planned vs studied (7 paired bars), workload by subject (horizontal bars), deadline concentration (list by week with counts), estimate vs actual (per type, plain text).
- Calibration card (≥ 3 qualifying tasks of a type): "Your Assignments usually take about 2 h 45 m. Use that for new ones?" Buttons "Use 2 h 45 m" / "Not now".
- Every chart has a one-sentence summary above it.

## 10. Backup and restore

- Settings > Backup shows "Last backup: {date}" or "Never backed up". "Back up now" opens the platform save dialog; success: "Backup saved". If the platform cannot confirm the save, the limitation is shown and the timestamp does not change.
- Reminder on Today (when ≥ 1 task exists and no backup in 30 days, not dismissed in the last 30 days): "Back up your semester. Your data lives only on this phone." Actions "Back up now" / "Later".
- Import: pick file → validation → "Replace everything on this phone with this backup from {date}? {n} tasks, {m} subjects. This can't be undone." Buttons "Back up current data first" / "Replace" / "Cancel". Errors name the problem and code: "This backup is from a newer SemesterOS (format 2). Update the app, then try again. (SEM-BACKUP-004)".

## 11. Recovery screen

"SemesterOS couldn't open your data safely." Options: "Restore from a backup" · "Start fresh (your current data stays saved as a file; nothing is deleted)" · "Show details" (error code, no content).

## 12. Reminders (Phase 7)

Settings > Reminders toggle. Turning it on shows "SemesterOS can remind you 10 minutes before each study session. Allow notifications?" then the system prompt. "Show task names in notifications" (default on). If permission is denied: "Notifications are off. You can turn them on in system settings."

## 13. Empty states

| Screen | Headline | Line | Action |
|---|---|---|---|
| Today (no tasks) | "Add your first deadline" | "SemesterOS plans the rest." | Quick add |
| Plan (no plan) | "No plan yet" | "Add a deadline and your study times, then generate a plan." | Generate plan |
| Plan (no study times) | "When can you study?" | "Your plan needs at least one study time." | Set study times |
| Tasks | "Nothing due yet" | "Add assignments, exams and readings as they come up." | Quick add |
| Subjects | "No subjects yet" | "Subjects group your tasks by course." | Add subject |
| Insights | "Insights appear after your first studied session" | "Start a session and come back here." | Go to Today |
| Weekly review (no data) | "A quiet week" | "Nothing was planned or studied in the last 7 days." | Plan this week |
| Notices | "All clear" | "Nothing needs your attention." | — |

## 14. Developer menu (debug builds only)

Settings > Developer: "Seed sample semester" (same fixture as tests), "Reset database", "Clock offset" (+1 day, +3 days, Sunday 20:00; not persisted), "Force recovery screen", "Dump database to JSON".
