# iOS Companion MAIN UI QA Matrix

Owner: ________  Date: 2026-06-07  Commit: ________

| Flow | iPhone 17 sim | iPhone 15 Pro HW | VoiceOver | EN | IT | Evidence | Status |
|---|---|---|---|---|---|---|---|
| Legal onboarding 0–3 |  |  |  |  |  |  | Pending |
| Root chrome / black bands |  |  |  |  |  | See `IOS_FULLSCREEN_LAYOUT_QA_MATRIX.md` | **Pending visual QA** |
| Logbook delete (trash + menu) |  |  |  |  |  |  | Pending |
| Planner — collapsible reference |  |  |  |  |  |  | Pending |
| Planner — full-plan CNS banner |  |  |  |  |  |  | Pending |
| Planner — charts/tables a11y |  |  |  |  |  |  | Pending |
| Planner — imperial depth profile axis |  |  |  |  |  | Toggle units in More | Pending |
| Analysis chart Dynamic Type |  |  |  |  |  |  | Pending |

## Automated coverage

- `PlannerCNSCopyTests` — CNS/full-plan keys + mode footer
- `PlannerLocalizationTests` — chart/table a11y keys

## Blockers

- Fullscreen layout not verified on iPhone 15 Pro / legacy simulators (unavailable on audit Mac)
