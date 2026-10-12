# Product

<!-- impeccable:product-schema 1 -->

## Platform

adaptive

## Users

Students at any level (high school, undergraduate, graduate) who juggle several courses or long projects with deadlines. They use a phone most of the time, glancing at it between classes or on the move, and sometimes plan at a desk or on a tablet. The design must not assume one study rhythm, one term length or one grading system. Their job: know what matters, know what to work on next, and stay in control of the term without spending time on the planner itself.

## Product Purpose

SemesterOS is an offline-first study planner for Android and iOS phones and tablets. The student adds deadlines and the times they can study; the app builds a realistic plan, says what to work on next, tracks study sessions, and warns early when the work does not fit. Success: real students keep using it for weeks because it saves them planning effort and they trust the plan (initial target from the plan: 5 students for 3 consecutive weeks).

## Positioning

All four are core promises, owner-confirmed 2026-10-12:

1. **Explained, never silent.** Every plan is a proposal the student accepts; nothing moves on its own, and every session can say why it is there.
2. **Private, no account.** Everything stays on the device: no sign-up, no network requests for features, no data sent anywhere.
3. **Learns your real pace.** Estimates adapt to how long the student's tasks actually take.
4. **Honest about capacity.** When the work does not fit the available time, the app says so early and plainly, and offers concrete ways out.

## Operating Context

- Quick glances between classes, often outdoors in daylight, one-handed on a phone.
- Longer planning sessions at a desk (weekly review, adding a batch of deadlines), on phone or tablet, including iPad and Android tablet split screen.
- A study session running with a timer while the student works on something else (the phone sits next to them).
- Light theme by default, follows the system setting; dark fully supported.

## Capabilities and Constraints

- Subjects, tasks (assignments, exams, projects, readings and so on) with deadlines, estimates, priority, grade weight and milestones; quick add.
- Weekly study times with one-off exceptions; a local scheduler that produces proposals with reasons; sessions with start/pause/complete/skip and a timer; missed-session handling; insights (planned vs studied, workload, estimate accuracy); weekly review; JSON backup and restore; optional local reminders.
- Zero-dollar budget: no paid APIs, no backend, no accounts, no cloud sync in v1. All logic runs on the device in Dart (Flutter).
- Terminology: proposal, pinned session, ad-hoc ("Study now") session, missed session, study times (availability), "Your plan needs attention".
- Undecided: whether a student testing round happens after Phase 4 (UC1) and whether a basic session reminder moves earlier (UC2).

## Brand Commitments

- Name: SemesterOS. Promise line: "Know what matters. Know what to do next. Stay in control of your semester."
- Voice: calm, exact, on the student's side. Short, supportive, specific sentences. Never guilt, never "you failed", no exclamation marks in warnings, no emoji.
- Typeface: IBM Plex Sans, bundled (owner-approved in docs/DESIGN_SYSTEM.md).

## Evidence on Hand

None yet: no real users, testimonials, usage data or screenshots from students. Future work must not invent any.

## Product Principles

1. The student stays in control: the app proposes, the student decides.
2. Say the true thing early, kindly, with a way forward.
3. Every screen answers "what should I do next?" before anything else.
4. Nothing leaves the device, and the app never pretends otherwise.
5. Feel at home on each platform: iOS like iOS, Android like Android.

## Accessibility & Inclusion

Text contrast at least 4.5:1 (3:1 for large text and UI boundaries), enforced by test. Usable at text scale 2.0. Touch targets at least 44 pt on iOS and 48 dp on Android. Full screen-reader support (VoiceOver, TalkBack). Status never shown by color alone. Reduced motion respected.
