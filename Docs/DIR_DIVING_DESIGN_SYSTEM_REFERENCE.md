# DIR Diving Design System Reference (MAIN)

**Date:** 2026-06-07  
**Scope:** Shared iOS Companion tokens + Watch visual conventions (UI-only).

## iOS typography (`DIRTypography`)

| Token | Use |
|---|---|
| `screenTitle` | Screen headers (`dirScreenTitleStyle`) |
| `screenSubtitle` | Screen subtitles |
| `metricValue` | Hero numerals (logbook date block) |
| `captionSemibold` | Compact controls (planner “Read more”) |
| `legalBody` | Onboarding / legal body (`dirLegalBodyStyle`) |

## iOS color / surfaces

- `DIRTheme.cyan` — primary accent
- `DIRTheme.surface` / `surface2` — cards
- `DIRWarningBox` — reference/safety warnings (planner CNS, legal)

## Watch layout patterns

- `ScrollView` on dense subscreens (Compass, Live dive when many banners)
- Banner priority: safety-critical full width; secondary notices compact chip
- Back affordance: `WatchDetailBackButton` / `WatchSubscreenBackToolbar` + `watch.nav.back.a11y`

## Accessibility conventions added

- Depth safety: dedicated `depth.safety.a11y.*` labels
- Planner charts: `.accessibilityElement(children: .ignore)` + summary label/hint
- Planner tables: `.contain` per cell + row summary hint
- Logbook delete: `logbook.delete.button.a11y`

## Dynamic Type

- Charts: `frame(minHeight:maxHeight:)` inside scroll parents
- See `IOS_DYNAMIC_TYPE_VOICEOVER_QA_MATRIX.md` for device verification
