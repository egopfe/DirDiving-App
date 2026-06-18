# DIR DIVING — Snorkeling Watch UI (All Approved States)

**Command:** `06_WATCH_SNORKELING_UI_ALL_STATES.md`  
**Date:** 2026-06-18  
**Branch:** `main`  
**Final result:** **PASS** — Watch MAIN promoted

---

## Scope

Apnea-style Watch UI promotion for Snorkeling: pure presentation mapper, runtime store bridging `SnorkelingSessionEngine`, and `SnorkelingView` with all approved lifecycle screens. No business logic in views; no `ExplorationStore` / `DiveManager` coupling.

---

## Architecture

| Layer | Location |
|-------|----------|
| Presentation mapper | `Utils/SnorkelingWatchPresentation.swift` |
| Runtime bridge | `Services/SnorkelingWatchRuntimeStore.swift` |
| SwiftUI screens | `Views/SnorkelingView.swift` |
| Live tab routing | `Views/DiveLiveView.swift` |
| Startup routing | `Models/DIRModesAndStartup.swift`, `Utils/DIRStartupSelectionPolicy.swift` |

---

## Screens

1. Ready Snorkeling — pre-start grid (GPS, depth sensor, entry, limits, Mission Mode)
2. Surface Dashboard — runtime hero, distance/speed/temp/dips, entry distance footer
3. Dip in Progress — depth hero, dip timer/max, vertical-speed gauge
4. Navigation to Waypoint — `DiveBearingRing`, turn instruction, distance
5. Return to Entry — bearing/distance, advisor line, degraded GPS fallback
6. Save Marker — category picker, position quality, save CTA
7. Session Summary — 2×4 metric grid, save-state footer
8. Warning overlays — sensor degraded, underwater GPS informational, operational alarms

---

## Promotion

- `SnorkelingView` removed from Watch MAIN exclusions
- `DIRActivityMode.snorkeling.isLaunchableOnWatchMAIN = true`
- Routes to `.ready(activity: .snorkeling, divingMode: .gauge)`
- `SnorkelingWatchRuntimeStore` injected in `DIRDivingApp`
- Session-active navigation lock extended in `ContentView`
- `ExplorationStore` remains excluded

---

## Tests

| Suite | Count |
|-------|-------|
| `SnorkelingWatchPresentationTests` | 15 |
| `SnorkelingWatchLayoutContractTests` | 5 |
| `SnorkelingWatchMainPromotionTests` | 8 |
| Full Snorkeling focused suite | 137 |

---

## Localization

IT/EN strings under `snorkeling.*` in `Resources/*/Localizable.strings`.

---

## Gate

`READY_FOR_SNORKELING_COMMAND_07` (persistence/logbook)

---

## Explicit non-goals

- iOS Companion snorkeling UI
- Snorkeling logbook persistence (Command 07)
- Photo capture on Watch
