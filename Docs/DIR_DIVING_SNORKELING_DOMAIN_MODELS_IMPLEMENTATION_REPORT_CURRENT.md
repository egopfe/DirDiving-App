# DIR DIVING — Snorkeling Domain Models and Versioned Schema

**Command:** `01_SNORKELING_DOMAIN_MODELS_AND_VERSIONED_SCHEMA.md`  
**Date:** 2026-06-18  
**Branch:** `main`  
**Final result:** **PASS** (domain-only; UI not activated)

---

## Scope

Pure Snorkeling data domain for future Watch/iOS runtime — **no UI**, **no SwiftUI/WatchKit/UIKit/MapKit/WCSession/UserDefaults** in core models, **no demo runtime values**.

Experimental `ExplorationModels.swift` / `ExplorationStore` remain excluded from MAIN and are **not** modified.

---

## Architecture

| Layer | Location | Notes |
|-------|----------|-------|
| Core models | `Shared/Models/Snorkeling*.swift` | UI-free, `Codable` + `Hashable` + `Sendable` |
| Support | `Shared/Utils/SnorkelingDomainSupport.swift` | Track ordering, haversine distance, depth metrics |
| Validation | `Shared/Utils/SnorkelingDomainValidator.swift` | NaN/Inf, coordinates, monotonic series, underwater GPS policy |
| Migration | `Shared/Utils/SnorkelingSchemaMigration.swift` | v0→v1, future schema |

`DIRActivityMode.snorkeling` remains `isLaunchableOnWatchMAIN == false`. `SnorkelingView.swift` stays excluded from MAIN.

---

## Models delivered

| Type | File |
|------|------|
| `SnorkelingSession` (+ statistics, session enums) | `SnorkelingSession.swift` |
| `SnorkelingTrackPoint` | `SnorkelingTrackPoint.swift` |
| `SnorkelingDip` | `SnorkelingDip.swift` |
| `SnorkelingDipSample` | `SnorkelingDipSample.swift` |
| `SnorkelingMarker`, `SnorkelingMarkerCategory` | `SnorkelingMarker.swift`, `SnorkelingMarkerCategory.swift` |
| `SnorkelingWaypoint`, `SnorkelingRoutePlan` | `SnorkelingWaypoint.swift`, `SnorkelingRoutePlan.swift` |
| `SnorkelingProfile`, `SnorkelingEquipmentProfile`, `SnorkelingBuddyInfo` | `SnorkelingProfile.swift` |
| `SnorkelingAlarm` | `SnorkelingAlarm.swift` |
| `SnorkelingEvent` | `SnorkelingEvent.swift` |
| `SnorkelingGPSQuality`, `SnorkelingDepthQuality` | `SnorkelingGPSQuality.swift`, `SnorkelingDepthQuality.swift` |

---

## GPS / depth policy

| Situation | `SnorkelingGPSQuality` | Coordinates |
|-----------|------------------------|-------------|
| Valid surface fix | `.measured` | Required lat/lon |
| Underwater / no fix | `.estimated` / `.unavailable` | Optional; not navigation-grade |
| Invalid reading | `.invalid` | Rejected by validator |

Underwater points must **not** use `.measured` surface GPS (`underwaterMeasuredGPS` validation issue).

Distance aggregation uses **measured surface** segments only (`SnorkelingDomainSupport.trackDistanceMeters`).

---

## Schema versioning

- Root container: `SnorkelingSession.schemaVersion` (`currentSchemaVersion = 1`)
- Nested plans: `SnorkelingRoutePlan.schemaVersion` (`currentSchemaVersion = 1`)
- Missing `schemaVersion` on decode → migrate to v1 + `.schemaMigrated` warning
- Future version → best-effort v1 decode, normalize to current, add warning
- Encode always writes `currentSchemaVersion`

**Persistence key:** not wired in this command — domain only.

---

## Tests

`Tests/WatchAlgorithmTests/SnorkelingDomainModelTests.swift` — 12 tests:

- Codable round-trip (session, route plan)
- Schema migration (missing version, future version)
- NaN/Inf depth rejection
- Invalid coordinates
- Track point ordering / duplicate removal
- Non-monotonic track / duplicate dip samples
- Underwater measured GPS rejection
- Estimated underwater track excluded from measured distance
- Session statistics vs profile personal best

Also listed in `DIRDiving iOS Algorithm Tests` target (parity with Apnea domain tests).

---

## Next commands

- `02_SNORKELING_SHARED_SENSOR_GPS_INGESTION`
- `03_SNORKELING_SESSION_AND_DIP_LIFECYCLE_ENGINE`
- `07_SNORKELING_PERSISTENCE_RECOVERY_AND_WATCH_LOGBOOK`

---

## Related docs

- [`SNORKELING_EXPERIMENTAL_SPEC.md`](SNORKELING_EXPERIMENTAL_SPEC.md)
- [`DIRDIVING_APNEA_SNORKELING_MAIN_INTEGRATION_ANALYSIS_20260605.md`](DIRDIVING_APNEA_SNORKELING_MAIN_INTEGRATION_ANALYSIS_20260605.md)
