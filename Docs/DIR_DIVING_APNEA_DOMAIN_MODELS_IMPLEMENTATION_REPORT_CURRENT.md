# DIR DIVING — Apnea Domain Models and Versioned Schema

**Command:** `01_APNEA_DOMAIN_MODELS_AND_SCHEMA.md`  
**Date:** 2026-06-16  
**Branch:** `main`  
**Final result:** **PASS**

---

## Scope

Pure Apnea data domain for future Watch/iOS runtime — **no UI**, **no Diving lifecycle changes**, **no demo runtime values**.

---

## Architecture

| Layer | Location | Notes |
|-------|----------|-------|
| Core models | `Shared/Models/Apnea*.swift` | UI-free, `Codable` + `Hashable` + `Sendable` |
| Support | `Shared/Utils/ApneaDomainSupport.swift` | Sample normalization, depth metrics |
| Validation | `Shared/Utils/ApneaDomainValidator.swift` | NaN/Inf, monotonic samples, duplicates |
| Migration | `Shared/Utils/ApneaSchemaMigration.swift` | v0→v1, future schema, legacy dive record |

`DIRActivityMode.apnea` remains `isLaunchableInMAIN == false`. Experimental `ApneaDiveRecord` in excluded `ExplorationModels.swift` is **not** modified.

---

## Files added

| File | Types |
|------|-------|
| `ApneaDataQuality.swift` | `ApneaDataQuality` |
| `ApneaSample.swift` | `ApneaSample` |
| `ApneaEvent.swift` | `ApneaEventKind`, `ApneaEvent` |
| `ApneaAlarm.swift` | `ApneaAlarmKind`, `ApneaAlarm` |
| `ApneaDepthMarker.swift` | `ApneaDepthMarker` |
| `ApneaTarget.swift` | `ApneaTargetKind`, `ApneaTarget` |
| `ApneaRecoveryPolicy.swift` | `ApneaRecoveryPolicy`, `ApneaRecoveryInterval`, `ApneaRecoveryPhaseKind` |
| `ApneaProfile.swift` | `ApneaProfile`, `ApneaEquipmentProfile`, `ApneaBuddyInfo` |
| `ApneaSurfaceGPSPoint.swift` | `ApneaSurfaceGPSPoint` |
| `ApneaDive.swift` | `ApneaDive` |
| `ApneaSession.swift` | `ApneaSession`, `ApneaSessionStatistics`, session enums |
| `ApneaDomainSupport.swift` | Sample ordering, depth aggregation |
| `ApneaDomainValidator.swift` | `ApneaDomainValidationIssue` |
| `ApneaSchemaMigration.swift` | Versioned decode + legacy record mapper |
| `Tests/WatchAlgorithmTests/ApneaDomainModelTests.swift` | 12 unit tests |

---

## Depth separation (command requirement)

| Concept | Field | Scope |
|---------|-------|-------|
| Single dive maximum | `ApneaDive.maxDepthMeters` | One descent |
| Session maximum | `ApneaSessionStatistics.sessionMaxDepthMeters` | Max across dives in session |
| Personal record | `ApneaProfile.personalBestMaxDepthMeters` | Diver profile metadata |

---

## Schema versioning

- Root container: `ApneaSession.schemaVersion` (`currentSchemaVersion = 1`)
- Missing `schemaVersion` on decode → migrate to v1 + `.schemaMigrated` warning
- Future version (`schemaVersion > 1`) → best-effort v1 decode, normalize to current, add warning
- Encode always writes `currentSchemaVersion`

**Persistence key (future commands):** not wired yet — domain only.

---

## Validation

`ApneaDomainValidator` rejects:

- Non-finite depth, temperature, vertical speed, durations
- Negative depths/timestamps
- Non-monotonic sample timestamps within a dive
- Duplicate sample or dive IDs

---

## Tests

| Test | Coverage |
|------|----------|
| `testSessionCodableRoundTrip` | JSON encode/decode |
| `testMissingSchemaVersionMigratesToV1` | v0 migration |
| `testFutureSchemaVersionDecodesWithMigrationWarning` | Future schema |
| `testNonFiniteDepthRejected` | NaN/Inf |
| `testSampleOrderingAndDuplicateRemoval` | Normalization |
| `testNonMonotonicSamplesFlagged` | Ordering policy |
| `testDuplicateSampleIDsFlagged` | Duplicate detection |
| `testDiveSessionAndPersonalBestDepthsAreDistinct` | Depth semantics |
| `testLegacyDiveRecordMigration` | Experimental record shape |
| `testSessionStatisticsAggregate` | Aggregate stats |
| `testDiveDepthMetricsRecomputedFromSamples` | Sample-derived metrics |

---

## Not modified

- Diving lifecycle (`DiveSession`, `DiveLogStore`, `DiveManager`)
- Watch startup routing (`isLaunchableInMAIN`)
- Experimental `ApneaView` / `ExplorationStore`
- SwiftUI / WatchKit / WCSession / UserDefaults in core models

---

## project.yml

- App targets: auto via `path: Shared`
- iOS Algorithm Tests: explicit `Tests/WatchAlgorithmTests/ApneaDomainModelTests.swift`

---

## Rollback

Revert this commit and run `xcodegen generate`. No persistence keys are written by this command.

**Final result: PASS**
