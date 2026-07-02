# Snorkeling Watch P2 — Implementation Report

**Date:** 2026-06-17  
**Verdict:** **INTERNAL_READY** · **MANUAL_UI_QA_PENDING** · **PHYSICAL_QA_PENDING**

## Delivered

1. **Return to Entry primary action** — full-width hero button first in action row; disabled when entry missing (`SnorkelingWatchReturnPrimaryActionPolicy`, `SnorkelingView`)
2. **iOS operational settings** — max duration, max distance, off-route threshold, GPS quality warning, buddy reminder, return alert policy (`SnorkelingCompanionSettings` v2, `IOSSnorkelingSettingsContent`)
3. **Watch route metadata sync** — operational thresholds embedded in `SnorkelingRoutePlanningMetadata`; applied on Watch import (`SnorkelingRoutePackageBuilder`, `SnorkelingWatchRuntimeStore`)
4. **Watch route summary** — compact pre-start summary with waypoints, return alert, off-route config (`SnorkelingWatchRouteSummaryPresentationPolicy`)
5. **iOS marker logbook** — category counts + enriched rows (`SnorkelingMarkerLogbookPresentation`)
6. **Export/share** — GPX/KML dedicated services + session summary text export

## Tests

| Suite | Tests |
|-------|-------|
| `SnorkelingWatchReturnPrimaryActionTests` | 2 |
| `SnorkelingWatchRouteSummaryPresentationTests` | 2 |
| `SnorkelingOperationalSettingsPersistenceTests` | 2 |
| `SnorkelingOperationalSettingsRouteSyncTests` | 1 |
| `SnorkelingMarkerLogbookPresentationTests` | 2 |
| `SnorkelingTrackGPXExportTests` | 1 |
| `SnorkelingTrackKMLExportTests` | 1 |

## No algorithm regression

No changes to Bühlmann, GF, CCR, gas, Diving, Apnea, or Watch depth/GPS sampling policy. Off-route and GPS band evaluation consume configurable thresholds only.
