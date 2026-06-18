# DIR DIVING — Snorkeling Shared Sensor and GPS Ingestion

**Command:** `02_SNORKELING_SHARED_SENSOR_GPS_INGESTION.md`  
**Date:** 2026-06-18  
**Branch:** `main`  
**Final result:** **PASS** (ingestion-only; UI not activated)

---

## Scope

UI-free shared depth and GPS feeds for future Snorkeling runtime. No session lifecycle engine (Command 03), no persistence, no SwiftUI/WatchKit/UIKit/MapKit/WCSession/UserDefaults.

---

## Architecture

| Layer | Location | Notes |
|-------|----------|-------|
| Depth feed | `Shared/Utils/SnorkelingDepthFeed.swift` | Wraps `DepthMeasurementFeed` with snorkeling config |
| GPS feed | `Shared/Utils/SnorkelingGPSFeed.swift` | Surface-only policy, geodetic segments |
| Shared depth core | `Shared/Utils/DepthMeasurementFeed.swift` | Added `.snorkelingDefault` configuration |
| Domain distance | `Shared/Utils/SnorkelingDomainSupport.swift` | Haversine segment distance |

No references to `DiveManager`, `ApneaSessionEngine`, `ExplorationStore`, or Diving lifecycle.

---

## Depth feed

- Reuses `DepthMeasurementFeed.ingest` via `DepthMeasurementFeedConfiguration.snorkelingDefault`
- Monotonic relative timestamp supplied by caller (session engine in Command 03)
- Maps to `SnorkelingDepthQuality` + `SnorkelingDepthPresentationState` (`valid` / `degraded` / `unavailable`)
- Spike validation, regressive timestamp rejection, temperature passthrough
- Underwater hint from configurable depth threshold (default 0.35 m)
- Raw auditable trail (`SnorkelingDepthRawAuditEntry`, capped at 2048)

---

## GPS feed

| Policy | Behaviour |
|--------|-----------|
| Surface only | `isUnderwater` → `.underwaterUnavailable`, never measured coords |
| Horizontal accuracy | ≤20 m tracking, ≤45 m degraded, above → reject |
| Fix age | ≤12 s tracking, ≤90 s stale, older → reject |
| Speed gate | Geodetic implied speed ≤3.5 m/s between accepted fixes |
| Gap policy | Gap >45 s resets accepted bridge (`gapExceeded`) |
| Distance | Haversine segment sum; degraded/stale fixes do not add measured distance |
| Audit | `SnorkelingGPSRawAuditEntry` per raw fix |

Presentation states: `tracking`, `degraded`, `stale`, `unavailable`, `underwaterUnavailable`.

---

## Tests

`Tests/WatchAlgorithmTests/SnorkelingSensorGPSIngestionTests.swift` — 13 tests:

- Depth: surface accept + temperature, spike, underwater quality, regressive timestamp
- GPS: replay distance, low accuracy, speed spike, stale fix, underwater unavailable, gap reset, surface resume
- Concurrency: independent depth/GPS audit trails with underwater GPS suppression
- Degraded accuracy accepted without distance credit
- Architecture isolation (no Dive/Apnea/FC/UI references)

Also in `DIRDiving iOS Algorithm Tests` target.

---

## Next commands

- `07_SNORKELING_PERSISTENCE_RECOVERY_AND_WATCH_LOGBOOK`

**Completed:** `03_SNORKELING_SESSION_AND_DIP_LIFECYCLE_ENGINE` — see [`DIR_DIVING_SNORKELING_SESSION_LIFECYCLE_IMPLEMENTATION_REPORT_CURRENT.md`](DIR_DIVING_SNORKELING_SESSION_LIFECYCLE_IMPLEMENTATION_REPORT_CURRENT.md)

---

## Related docs (Command 02)

- [`DIR_DIVING_SNORKELING_DOMAIN_MODELS_IMPLEMENTATION_REPORT_CURRENT.md`](DIR_DIVING_SNORKELING_DOMAIN_MODELS_IMPLEMENTATION_REPORT_CURRENT.md)
- [`SNORKELING_EXPERIMENTAL_SPEC.md`](SNORKELING_EXPERIMENTAL_SPEC.md)
- [`SNORKELING_DOMAIN_INGESTION_LIFECYCLE_REMEDIATION_REPORT_V1.0.md`](SNORKELING_DOMAIN_INGESTION_LIFECYCLE_REMEDIATION_REPORT_V1.0.md)

---

## Remediation V1.0 (2026-06-18)

`SnorkelingArchitectureIsolation` comment-aware scanner; bounded-data tests confirm 2048 raw audit cap. Ingestion suite 13 PASS + isolation moved to dedicated test target.
