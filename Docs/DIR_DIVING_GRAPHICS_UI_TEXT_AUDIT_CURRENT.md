# DIR Diving Graphics / UI Text Audit — Current

**Date:** 2026-06-07  
**Post-fix snapshot** after UI/UX readiness remediation.

## Watch MAIN visible text

| Surface | Status | Notes |
|---|---|---|
| Live dive metrics | Localized | TTV, RunTime, max/avg depth |
| Live dive banners | Localized + prioritized | Collapsed secondary summary |
| Depth safety | Localized | Distinct caution/critical/exceeded |
| Dive detail | Localized | Export Subsurface, delete, GPS rows |
| Compass (BUSSOLA) | Localized | ScrollView; status a11y |
| Export | Localized | Duplicate modifier removed |

## iOS Companion MAIN visible text

| Surface | Status | Notes |
|---|---|---|
| Legal onboarding 0–3 | Localized EN/IT | Safety/disclaimer meaning preserved |
| Planner input | Localized | Collapsible metric/reference block |
| Planner result | Localized | CNS banners, mode footer, chart a11y |
| Logbook | Localized | Delete affordance + a11y |

## Terminology guardrails

- **BUSSOLA** — preserved on Watch compass surfaces
- **COMPASSO** — must not appear in Watch MAIN strings or compiled views
- **Reference-only** — planner/onboarding disclaimers unchanged in meaning

## Remaining text QA

- iOS legal settings rows (`Version accepted`, etc.) still use legacy English keys — out of onboarding scope
- Device QA for truncated labels on 41 mm Watch faces — manual matrix pending
