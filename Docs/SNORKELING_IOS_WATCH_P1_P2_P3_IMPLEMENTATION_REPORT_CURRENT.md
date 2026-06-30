# Snorkeling iOS + Watch P1/P2/P3 — Implementation Report (Current)

**Command:** `DIR_DIVING_SNORKELING_IOS_WATCH_P1_P2_P3_CURSOR_COMMAND.md`  
**Date:** 2026-06-30  
**Task type:** Software implementation + deterministic tests + docs/QA scaffolding

## Summary

P1/P2/P3 Snorkeling route planning, validation, Watch runtime evaluation, GPS quality, return alerts, off-route detection, and export layers are implemented in shared pure helpers and wired into existing iOS planner and Watch runtime stores. Physical QA remains **PENDING** for all new evidence folders.

## Delivered — Shared helpers

| Helper | Purpose |
|--------|---------|
| `SnorkelingDistanceCalculator` | Haversine polyline distance |
| `SnorkelingBearingCalculator` | Initial bearing between coordinates |
| `SnorkelingDurationEstimator` | Profile/kind speed → duration |
| `SnorkelingRouteValidator` | Status + warnings + transfer gate |
| `SnorkelingGPSQualityEvaluator` | Good/Medium/Poor/Lost bands |
| `SnorkelingRouteProgressCalculator` | Percent complete along route |
| `SnorkelingOffRouteDetector` | Min distance to route segments |
| `SnorkelingWaypointProgressTracker` | Next WP + 25 m reached threshold |
| `SnorkelingPlannedRouteReturnAlertEngine` | 50% time/distance once |
| `SnorkelingRouteRuntimeEvaluator` | Watch tick evaluation + haptics |

## Delivered — Models

- `SnorkelingRoutePlanningModels.swift` — route type, profile kinds, validation result, checklist, planning metadata, runtime summary
- Extended `SnorkelingRoutePlannerDraft` — route type, return policy, profile kind, checklist
- Extended `SnorkelingRouteSyncPackageBody` — optional `planningMetadata`

## Delivered — iOS

- Route planner sections: safety check, profiles, return alert, checklist, send, export
- `SnorkelingRoutePlanExportFormatter` — share text with disclaimer
- `SnorkelingRoutePackageBuilder` — validation-gated package build

## Delivered — Watch

- `SnorkelingImportedRouteStore` — planning metadata activation
- `SnorkelingRouteRuntimeEvaluator` — GPS band, progress, off-route, return alert haptics
- Presentation integration via existing `SnorkelingWatchPresentation` / runtime store

## Tests added (Command §15)

### iOS Algorithm Tests

| Suite | Coverage |
|-------|----------|
| `SnorkelingDistanceCalculatorTests` | Known coordinates, multi-segment, invalid coords |
| `SnorkelingBearingCalculatorTests` | Cardinal bearings, dateline |
| `SnorkelingDurationEstimatorTests` | Profile speed, kind fallback |
| `SnorkelingRouteValidatorTests` | Incomplete/ready/warning/blocked |
| `SnorkelingRouteProfileTests` | Kind limits, metadata, profile overrides |
| `SnorkelingReturnAlertPolicyTests` | 50% time/distance, no double fire |
| `SnorkelingChecklistTests` | Count, metadata, encoding |
| `SnorkelingExportPayloadTests` | Share text, fake logbook isolation |

### Watch Algorithm Tests

| Suite | Coverage |
|-------|----------|
| `SnorkelingGPSQualityEvaluatorTests` | Good/Medium/Poor/Lost |
| `SnorkelingRouteProgressCalculatorTests` | Start/mid/end/clamped |
| `SnorkelingOffRouteDetectorTests` | Threshold on/off route |
| `SnorkelingWaypointProgressTrackerTests` | Threshold reached, next ID |
| `SnorkelingReturnAlertRuntimeTests` | Runtime alert, off-route GPS gating |
| `SnorkelingImportedRouteCompatibilityTests` | Legacy metadata nil, namespace isolation |

## Documentation

- `SNORKELING_IOS_WATCH_ROADMAP_P1_P2_P3.md`
- `SNORKELING_IOS_WATCH_ARCHITECTURE.md`
- `SNORKELING_ROUTE_SAFETY_CHECK.md`
- `SNORKELING_WATCH_RETURN_TO_ENTRY.md`
- `SNORKELING_GPS_QUALITY_POLICY.md`

## QA evidence (PENDING templates)

12 new folders under `Docs/QA_EVIDENCE/SNORKELING_*` — see command §17.

## Not claimed

- Physical device PASS for open-water scenarios
- Certified or life-saving navigation
- Cross-activity regression free without paired-device QA (`SNORKELING_NO_CROSS_ACTIVITY_REGRESSION` pending)

## Validation (macOS)

Run on Mac:

```bash
xcodegen generate
xcodebuild -scheme "DIRDiving iOS Algorithm Tests" -destination 'platform=iOS Simulator,name=iPhone 16' test
xcodebuild -scheme "DIRDiving Watch Algorithm Tests" -destination 'platform=watchOS Simulator,name=Apple Watch Series 11 (46mm)' test
```

## Gate

**READY_FOR_INTERNAL_TESTFLIGHT** (software) — external/open-water QA still required.
