# Watch MAIN UI QA Matrix

Owner: ________  Date: 2026-06-07  Commit: ________

| Flow | 41 mm | 45 mm | 49 mm Ultra | VoiceOver | EN | IT | Evidence | Status |
|---|---|---|---|---|---|---|---|---|
| Live dive — normal |  |  |  |  |  |  |  | Pending |
| Live dive — multi-banner (ascent + depth + stale) |  |  |  |  |  |  |  | **Priority QA** |
| Depth safety caution 35 m |  |  |  |  |  |  |  | Pending |
| Depth safety critical 38 m |  |  |  |  |  |  |  | Pending |
| Dive detail export/delete |  |  |  |  |  |  |  | Pending |
| Compass (BUSSOLA) scroll |  |  |  |  |  |  |  | Pending |
| Export subscreen |  |  |  |  |  |  |  | Pending |
| Back navigation consistency |  |  |  |  |  |  |  | Pending |

## Automated coverage

- `WatchMainUILocalizationTests` — keys + no hardcoded IT export/delete strings
- `LiveDiveBannerPresentationPolicyTests` — banner priority / collapse

## Blockers

- Smallest-face clip verification requires 41 mm hardware or simulator run
