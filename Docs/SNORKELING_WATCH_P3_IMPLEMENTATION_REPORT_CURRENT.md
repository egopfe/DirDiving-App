# Snorkeling Watch P3 — Implementation Report

**Date:** 2026-06-17  
**Verdict:** **INTERNAL_READY** · **MANUAL_UI_QA_PENDING** · **PHYSICAL_QA_PENDING**

## Delivered

1. **Watch micro-map / compass-line hybrid** — Canvas route preview alongside `DiveBearingRing`; hidden underwater or when GPS/heading unavailable (`SnorkelingWatchMicroMapPresentationPolicy`, `SnorkelingWatchMicroMapView`)
2. **iOS planned vs actual analytics** — planned/actual distance, route progress, max off-route, return alert (`SnorkelingPlannedVsActualAnalyticsPolicy`, session detail card)
3. **Waypoint reached reporting** — engine persists `.waypointReached` events; iOS report uses events only (`SnorkelingWaypointReachedReportPolicy`)
4. **Track quality analytics** — measured/stale/unavailable counts, GPS gaps, longest gap, measured % (`SnorkelingTrackQualityAnalyticsPolicy`)
5. **Photo marker integration** — logbook rows expose photo refs; thumbnails via `IOSSnorkelingSessionPhotoStore` when attachment exists

## Deferred

- Watch photo capture — not present in existing infrastructure; iOS-only thumbnails
- Interactive map pan/zoom on Watch — explicitly out of scope

## Tests

| Suite | Tests |
|-------|-------|
| `SnorkelingWatchMicroMapPresentationTests` | 4 |
| `SnorkelingPlannedVsActualAnalyticsTests` | 3 |
| `SnorkelingWaypointReachedReportTests` | 3 |
| `SnorkelingTrackQualityAnalyticsTests` | 3 |
| `SnorkelingPhotoMarkerIntegrationTests` | 3 |
| `SnorkelingP3NoRegressionTests` | 3 |

## No algorithm regression

No changes to Bühlmann, GF, CCR, gas, Diving, Apnea, or Watch depth/GPS sampling policy. Micro-map is presentation-only; analytics consume existing session data.
