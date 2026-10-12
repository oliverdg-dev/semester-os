# SemesterOS Error Catalogue

Every failure the app can show has a stable code `SEM-<AREA>-<NNN>`. A test parses this table and fails if a `Failure` class in `lib/core/errors/` has no row. Diagnostics record the code, exception type and stack frames only, never message text from foreign exceptions.

Status: initial catalogue from Phase 0 (2026-10-12). Codes are added as features land; codes are never reused.

| Code | Where | User message | Cause | Fix |
|---|---|---|---|---|
| SEM-DB-001 | open | "SemesterOS couldn't open your data safely." | `quick_check` failed or file is not a database | Restore from a backup, or Start fresh (old files kept) |
| SEM-DB-002 | open | "This data was made by a newer version of SemesterOS." | `user_version` newer than the app | Update the app, or restore an older backup |
| SEM-DB-003 | any write | "Couldn't save. Nothing was changed." | SQLite write failed (disk full, constraint) | Free space and retry; report with diagnostics if it repeats |
| SEM-DB-004 | runtime | "SemesterOS couldn't read your data safely." | corruption detected after open | Recovery screen |
| SEM-PLAN-001 | accept | "Your plan changed. Regenerate?" | inputs changed since the proposal (DataVersion) | Regenerate the proposal |
| SEM-PLAN-002 | accept | "Your plan changed. Regenerate?" | time passed a proposed or existing session start | Regenerate the proposal |
| SEM-PLAN-003 | generate | "Couldn't build a plan. Nothing was changed." | scheduler threw (bug) | Retry; report with diagnostics |
| SEM-SESSION-001 | start | "You're already studying {task}. Pause it or finish it first." | a live session exists | Pause and switch, or finish and switch |
| SEM-SESSION-002 | delete task | "Finish or skip the current session first." | task has a live session | Finish or skip, then delete |
| SEM-SESSION-003 | edit time | "That overlaps another session." | overlap with an existing session | Pick another time |
| SEM-SESSION-004 | edit time | "That's outside your study times." | outside availability or inside a busy time | Pick another time or change study times |
| SEM-BACKUP-001 | import | "This file is too large to be a SemesterOS backup." | file > 10 MB | Choose the right file |
| SEM-BACKUP-002 | import | "This file isn't a SemesterOS backup." | not JSON, or no `schemaVersion` | Choose a backup made by SemesterOS |
| SEM-BACKUP-003 | import | "This backup file is damaged." | malformed JSON | Use another backup |
| SEM-BACKUP-004 | import | "This backup is from a newer SemesterOS (format {n}). Update the app, then try again." | `schemaVersion` higher than supported | Update the app |
| SEM-BACKUP-005 | import | "This backup has a task linked to a missing subject." | dangling task → subject reference | Use another backup |
| SEM-BACKUP-006 | import | "This backup has a session linked to a missing task." | dangling session → task reference | Use another backup |
| SEM-BACKUP-007 | import | "This backup has a milestone linked to a missing task." | dangling milestone → task reference | Use another backup |
| SEM-BACKUP-008 | import | "This backup contains duplicate records." | duplicate ids | Use another backup |
| SEM-BACKUP-009 | import | "This backup has an invalid study time." | `endMinute ≤ startMinute` | Use another backup |
| SEM-BACKUP-010 | import | "This backup has overlapping study sessions." | overlapping sessions | Use another backup |
| SEM-BACKUP-011 | import | "This backup has more than one session in progress." | > 1 active/paused session | Use another backup |
| SEM-BACKUP-012 | import | "This backup has a field that's too long." | string length limit exceeded | Use another backup |
| SEM-BACKUP-013 | import | "This backup has an unknown value." | invalid enum or date | Use another backup |
| SEM-BACKUP-014 | import | "Couldn't restore. Your current data is unchanged." | write failed mid-import (rolled back) | Free space and retry |
| SEM-BACKUP-020 | export | "Backup couldn't be created." | serialized backup failed validation (bug) | Report with diagnostics |
| SEM-BACKUP-021 | export | "Couldn't save the file." | save dialog or file write failed | Choose another location |
| SEM-NOTIF-001 | reminders | "Notifications are off. You can turn them on in system settings." | permission denied | Allow notifications in system settings |
| SEM-NOTIF-002 | reminders | "Some reminders couldn't be scheduled." | platform scheduling failure | Reopen the app; reminders are re-planned |
| SEM-APP-001 | any screen | "Something went wrong on this screen." | unexpected exception (caught by global handler) | Retry or Go to Today; report with diagnostics |
