# DIR Diving — Apnea release-hard validation (Command 12)

**Date:** 2026-06-18  
**Branch:** `main` @ Audit 08 remediation  
**Automation:** `./Scripts/validate_apnea_release_readiness.sh --internal`

---

## Executive summary

Command 12 adds release-hard automated validation, documented tolerances, a 23-mockup audit matrix, architecture/release documentation, and a repeatable readiness script for the Apnea integration on `main`.

**This report does not certify the product for freediving.** Apnea remains an experimental training/logbook companion. Physical validation (depth sensor, Water Lock, gloves, open water) and any regulatory certification are **out of scope** for this command.

---

## Tests executed (automated)

### New suites

| Suite | Tests | Result |
|-------|-------|--------|
| `ApneaReleaseHardValidationTests` (Watch) | 7 | PASS (sim) |
| `ApneaMockupReferenceMatrixTests` | 3 | PASS |
| `ApneaReleaseHardValidationTests` (iOS) | 6 | PASS (sim) |

### Existing Apnea suites (included in validation script)

| Suite | Coverage |
|-------|----------|
| `ApneaLifecycleEngineTests` | depth feed, lifecycle, sensor degraded |
| `ApneaOperationalEventEngineTests` | alarms, markers, overlays |
| `ApneaTimeRecoveryCheckpointEngineTests` | recovery policies, checkpoint, corruption |
| `ApneaWatchPresentationTests` | stage mapping, recovery, summary |
| `ApneaWatchUIViewContractTests` | a11y, localization keys |
| `ApneaLogbookStoreTests` | persistence, degraded warnings |
| `ApneaSyncWatchReceiverTests` | plan import, stale revision |
| `IOSApneaCompanionTests` | iOS stores and navigation |
| `IOSApneaLogbookAnalyticsTests` | records eligibility, charts |
| `IOSApneaMapEquipmentExportTests` | map, equipment, export |
| `ApneaSuspendResumeLifecycleIntegrationTests` | suspend/resume, active dive restore |
| `ApneaMonotonicClockRestoreTests` | monotonic wall jump, checkpoint elapsed |
| `ApneaSyncCryptographicLogicTests` | HMAC/ACK pure logic (no Keychain skip) |

### Builds

- Watch (`DIRDiving Watch App`) — **BUILD SUCCEEDED**
- iOS (`DIRDiving iOS`) — **BUILD SUCCEEDED**

### Script run (2026-06-17)

`./Scripts/validate_apnea_release_readiness.sh` — **PASS**

- Watch Apnea suite: **70** tests, 0 failures
- iOS Apnea suite: **41** tests, 1 skipped (`ApneaSyncCodecTests` keychain), 0 failures

---

## Documented tolerances

| Quantity | Tolerance | Rationale |
|----------|-----------|-----------|
| Minimum recovery | ≥ 30 s | Legacy conservative floor |
| Sync issued-at skew | 5 min | Shared with `ApneaSyncCodec` replay window |
| Checkpoint encode+decode | ≤ 50 ms | Recovery must not block UI thread |
| Sensor loss → degraded | 3 s | Documented lifecycle timeout |

Constants: `Utils/ApneaReleaseHardTolerances.swift`

---

## Mockup matrix (23 APNEA PNGs)

All external mockup files are indexed in `Utils/ApneaMockupReferenceMatrix.swift`.

- **8 / 23** Watch mockups map to executable presentation stages via `ApneaWatchPresentation`.
- **15 / 23** iOS mockups map to `IOSApnea*` SwiftUI surfaces (view-level references).
- **No raster mockups** are embedded in application bundles (verified by test).

---

## Safety gates verified

| Gate | Status |
|------|--------|
| Sensor degraded blocks ready start | PASS (automated) |
| Sync namespace isolated from dive/FC | PASS (automated) |
| No blackout / no-movement claims in Apnea sources | PASS (static scan) |
| Degraded sessions excluded from records (default) | PASS (automated) |
| Buddy disclaimer on iOS | PASS (l10n keys) |
| ApneaView on Watch MAIN | PASS (automated — `ApneaWatchMainPromotionTests`) |
| `ApneaWatchRuntimeStore` (no DiveManager) | PASS (automated) |

---

## Residual gaps and risks

| Gap | Risk | Mitigation path |
|-----|------|-----------------|
| Physical QA matrices unsigned | TestFlight NO-GO | `Docs/QA_EVIDENCE/APNEA_*/README.md` |
| No pool / open-water depth validation | Wrong depth → wrong alarms | `APNEA_WATCH_ULTRA`, `APNEA_SENSOR_RECOVERY` |
| Water Lock + glove UX not automated | Missed taps / unreadable UI | `APNEA_WATER_LOCK`, `APNEA_WET_INTERACTION` |
| Battery / thermal baseline | Unknown drain under Mission Mode | `APNEA_BATTERY_THERMAL` |
| Screenshot regression not in repo | Visual drift | `ReferenceUI/README.md` |
| Buddy reminder not wired to iOS buddy store on Watch | Display-only buddy state | Future sync of buddy profile |
| Battery / thermal profiling not automated | Throttling under long sessions | Physical long-session QA |
| WC offline edge cases | Plan/session queue at dive site | `WATCH_IOS_SYNC_QA_MATRIX.md` |

---

## Explicitly not validated

- Blackout, hypoxia, or SAM detection (not implemented; must not be marketed)
- Remote rescue or distress monitoring
- EN13319 / ISO 6425 or any dive-computer certification
- Real submersion depth accuracy across temperature / salinity
- Production App Store release readiness

---

## Rollback

Revert to `main` or abandon `main` merge. Apnea sync uses dedicated keys (`apneaSyncPlanPackage`, `dirdiving_apnea_session`) and does not alter Gauge/Full Computer dive sync behaviour.

---

## Related documents

- [`APNEA_ARCHITECTURE.md`](APNEA_ARCHITECTURE.md)
- [`APNEA_RELEASE_HARD_TEST_MATRIX.md`](APNEA_RELEASE_HARD_TEST_MATRIX.md)
- [`APNEA_RELEASE_CHECKLIST.md`](APNEA_RELEASE_CHECKLIST.md)
- Commands 05–11 implementation reports (`DIR_DIVING_APNEA_*_REPORT_CURRENT.md`)
