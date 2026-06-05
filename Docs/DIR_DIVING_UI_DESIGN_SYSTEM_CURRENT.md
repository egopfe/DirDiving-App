# DIR Diving — UI Design System (CURRENT)

Date: 2026-06-05  
Branch: `main`  
Scope: Apple Watch MAIN + iOS Companion MAIN  
Purpose: Shared semantic rules aligning `DiveUI` (Watch) and `DIRTheme` (iOS)

## Semantic colors

| Meaning | Watch (`DiveUI`) | iOS (`DIRTheme`) | Usage |
|---------|------------------|------------------|--------|
| Dive / action / water | `cyan`, `blue` | `cyan` | Primary actions, depth accents, links |
| Normal / safe | `green` | `green` | OK states, no-deco, surface row |
| Caution | `yellow`, `orange` | `yellow`, `orange` | Warnings, MOD stress, mission mode |
| Critical | `red` | `red` | Blocking issues, exceeded depth, alarms |
| Secondary | `secondaryText`, muted white | `muted`, `faint`, `hairline` | Footnotes, diagnostics, table headers |

Do not use color alone for warnings — pair icon + title + body text.

## Watch tokens (`DiveUI`)

- Typography: `screenTitle`, `rowTitle` (13.5pt), `rowSubtitle` (11.5pt), `warningTitle` (13pt), `warningBody` (11.5pt)
- Layout mins: interactive 44pt, informational 40pt, legal 48pt, command 40pt
- Components: `WatchSettingsRow`, `DiveCommandButton`, `DiveInlineStatusBanner`, warning banners

## iOS tokens (`DIRTheme` + `DIRTypography`)

- Surfaces: `background`, `surface`, `surface2`, `cardRadius`, `compactRadius`
- Spacing: `screenPadding` 16, `cardPadding` 16, `buttonMinHeight` 44
- Components: `DIRScreenContainer`, `DIRCard`, `DIRMetricTile`, `DIRWarningBox`, `DIRBackground`

## Typography hierarchy

1. Screen title — one per screen (`dirScreenTitleStyle` / `DiveUI.Typography.screenTitle`)
2. Section/card title — `DIRCard` header / `WatchSettingsSectionHeader`
3. Primary value — hero metrics, dashboard tiles
4. Body — warnings, table cells
5. Footnote — legal/reference copy (`caption2`, muted)

## Warning hierarchy

| Level | iOS | Watch |
|-------|-----|-------|
| Blocking | `DIRCard` red + octagon icon | Red banner, min 44pt height |
| Caution | `DIRCard` yellow or `DIRWarningBox` | Yellow/orange banner |
| Info | Muted footnote / `DIRWarningBox` info | `secondaryText`, info badge |

## Table pattern (Planner ascent / timeline)

- Header row on `surface2` background
- Column alignment: depth leading, time center, gas center, PPO₂ trailing
- Surface row highlighted with green tint
- Minimum vertical padding 8–10pt per row
- VoiceOver: combine row values

## Chart pattern

- Bühlmann tissue groups 1–4 / 5–8 / 9–12 / 13–16 with legend before chart
- Y axis 0–100% load; X axis elapsed minutes
- Empty state: icon + title + explanation (no mock data)
- Accessibility summary with peak load when data present

## Empty state pattern

- SF Symbol + short title + one-line explanation
- Muted secondary text; no fake data
- Tap targets ≥ 44pt (iOS) / 40pt (Watch secondary actions)

## Legal / disclaimer pattern

- Mandatory meaning unchanged; visually de-emphasized at bottom of result screens
- Blocking safety copy remains in warning cards above fold
- Reference-only planner hint in footnote section, not repeated in every metric row

## Accessibility rules

- Charts: `accessibilityLabel` summary; do not rely on color-only series
- Tables: combine row text for VoiceOver
- Dynamic Type: prefer scroll + `fixedSize` over hard clipping; min row heights on Watch
- Tab controls: selected trait + label on iOS planner result tabs

## Screenshot QA matrix (manual)

See `Docs/DIR_DIVING_UI_UX_READINESS_100_PLAN_CURRENT.md` §10.
