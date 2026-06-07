# iOS Dynamic Type and VoiceOver QA Matrix

Owner: ________  Date: ________  Build: ________  Commit: ________

| Screen/Flow | Dynamic Type | VoiceOver | Evidence | Notes |
|---|---|---|---|---|
| Legal onboarding |  |  |  |  |
| Planner — input CNS (bottom preview) + footnote |  |  |  |  |
| Planner — result CNS (full plan) + footnotes |  |  |  |  |
| Planner — CNS Descent + Bottom + 15% warning/hint |  |  |  | Verify `planner.accessibility.cns_descent_bottom.warning.*` |
| Planner — full-plan CNS warning banner + VoiceOver |  |  |  | Verify `planner.accessibility.cns_full_plan.warning.*` |
| Planner — tissue / NDL / depth profile charts (min/max height) | XL–AX5 |  |  | Charts use `minHeight`/`maxHeight`; scroll parent required |
| Planner — GF / ascent tables (per-cell VoiceOver) |  |  |  | Row hint + column header labels |
| Analysis — max depth chart (min/max height) | XL–AX5 |  |  | `frame(minHeight:maxHeight:)` |
| Equipment |  |  |  |  |
| More/settings |  |  |  |  |
| Sync/conflict UI |  |  |  |  |
