# Snorkeling Domain / Ingestion / Lifecycle — Remediation Report V1.0

**Date:** 2026-06-18  
**Authoritative audit:** [`AUDIT_SNORKELING_DOMAIN_INGESTION_LIFECYCLE_CURRENT.md`](AUDIT_SNORKELING_DOMAIN_INGESTION_LIFECYCLE_CURRENT.md) @ `f38dbd4`  
**Starting branch:** `main` @ `ccf7baf`  
**Remediation branch:** `main` (uncommitted at report draft; commit follows validation)

---

## Executive summary

Audit 09 remediation closes all code-fixable findings for Snorkeling Commands **01–03**. The architecture-isolation false positive (`AUDIT09-SNK-001`) is resolved with a comment-aware executable scanner. Depth-only / no-GPS lifecycle is explicitly tested (`AUDIT09-SNK-002`). Checkpoint disk persistence (`AUDIT09-SNK-003`) and navigation engine (`AUDIT09-SNK-004`) remain deferred with formal contracts.

**Snorkeling Commands 01–03 internal readiness: 100%**  
**Navigation/return engine: PENDING Command 04**  
**Disk persistence/recovery: PENDING Command 07**  
**Watch MAIN UI: not promoted**  
**Production release: NO-GO**  
**Physical QA: PENDING**

---

## Files changed

| File | Change |
|------|--------|
| `Shared/Utils/SnorkelingArchitectureIsolation.swift` | **Added** — comment/string-literal stripping + forbidden-symbol scan |
| `Tests/WatchAlgorithmTests/SnorkelingArchitectureIsolationTests.swift` | **Added** — scanner regression + production scan |
| `Tests/WatchAlgorithmTests/SnorkelingDepthOnlyLifecycleTests.swift` | **Added** — 6 depth-only/no-GPS lifecycle tests |
| `Tests/WatchAlgorithmTests/SnorkelingCheckpointFoundationTests.swift` | **Added** — 7 in-memory checkpoint tests |
| `Tests/WatchAlgorithmTests/SnorkelingCommand04FoundationGateTests.swift` | **Added** — 5 foundation gate tests |
| `Tests/WatchAlgorithmTests/SnorkelingWatchMainIsolationTests.swift` | **Added** — 6 Watch MAIN exclusion tests |
| `Tests/WatchAlgorithmTests/SnorkelingCrossDomainIsolationTests.swift` | **Added** — 6 cross-domain isolation tests |
| `Tests/WatchAlgorithmTests/SnorkelingBoundedDataTests.swift` | **Added** — 5 bounded-data tests |
| `Tests/WatchAlgorithmTests/SnorkelingSensorGPSIngestionTests.swift` | **Modified** — removed duplicate isolation class |
| `project.yml` | **Modified** — register new iOS Algorithm Test sources |
| `Docs/SNORKELING_PERSISTENCE_RECOVERY_CONTRACT.md` | **Added** — Command 07 contract |
| `Docs/SNORKELING_NAVIGATION_RETURN_ENGINE_CONTRACT.md` | **Added** — Command 04 contract |
| `Docs/AUDIT_SNORKELING_DOMAIN_INGESTION_LIFECYCLE_CURRENT.md` | **Updated** — post-remediation status |
| `Docs/DIR_DIVING_SNORKELING_*_IMPLEMENTATION_REPORT_CURRENT.md` | **Updated** — remediation notes |
| `Docs/SNORKELING_EXPERIMENTAL_SPEC.md` | **Updated** — foundation boundary notes |
| `Docs/INDEX.md` | **Updated** |

---

## AUDIT09-SNK-001 — isolation false positive

**Root cause:** `SnorkelingArchitectureIsolationTests` scanned raw source including `///` documentation on `SnorkelingLifecycleStateMachine.swift` line 110 mentioning `ExplorationStore`. No executable dependency exists.

**Fix:** `SnorkelingArchitectureIsolation.stripCommentsAndStringLiterals(from:)` removes `//`, `///`, `/* */`, and string literals before forbidden-symbol matching. Production scan uses `violations(inRepositoryRoot:)`.

**Scanner tests added:** line/doc/block comment ignore; executable `ExplorationStore`, `DiveManager`, `ApneaSessionEngine`, `FullComputerRuntimeEngine` rejection.

---

## AUDIT09-SNK-002 — depth-only lifecycle

**Tests:** `SnorkelingDepthOnlyLifecycleTests` (6 tests) including `testEngineDepthOnlySessionWithoutGPS`, multiple dips, sensor degraded without fabricated GPS, zero distance, checkpoint round trip, GPS resume after underwater gap.

**Policy confirmed:** GPS optional for depth/dip lifecycle; no coordinates or measured distance fabricated when GPS absent.

---

## Domain / feed / lifecycle regression

| Suite | Tests | Result |
|-------|------:|--------|
| `SnorkelingDomainModelTests` | 12 | **PASS** |
| `SnorkelingSensorGPSIngestionTests` | 13 | **PASS** |
| `SnorkelingLifecycleEngineTests` | 15 | **PASS** |
| `SnorkelingArchitectureIsolationTests` | 9 | **PASS** |
| `SnorkelingDepthOnlyLifecycleTests` | 6 | **PASS** |
| `SnorkelingCheckpointFoundationTests` | 7 | **PASS** |
| `SnorkelingCommand04FoundationGateTests` | 5 | **PASS** |
| `SnorkelingWatchMainIsolationTests` | 6 | **PASS** |
| `SnorkelingCrossDomainIsolationTests` | 6 | **PASS** |
| `SnorkelingBoundedDataTests` | 5 | **PASS** |
| **Focused total** | **85** | **PASS** |

---

## Checkpoint foundation (AUDIT09-SNK-003)

In-memory export/restore verified for depth-only sessions, active dip, multiple dips, GPS bridge state, sensor-degraded state, deterministic re-export, and absence of foreign-runtime JSON keys.

**Persistence scope decision:** Disk atomic store, checksum, quarantine, and relaunch recovery documented in [`SNORKELING_PERSISTENCE_RECOVERY_CONTRACT.md`](SNORKELING_PERSISTENCE_RECOVERY_CONTRACT.md). **Not implemented** (Command 07).

---

## Command 04 gate (AUDIT09-SNK-004)

Navigation/return phase hooks verified; no bearing, waypoint advisor, or fabricated guidance in production sources. Contract: [`SNORKELING_NAVIGATION_RETURN_ENGINE_CONTRACT.md`](SNORKELING_NAVIGATION_RETURN_ENGINE_CONTRACT.md).

**Gate:** `READY_FOR_SNORKELING_COMMAND_04`

---

## Watch MAIN exclusion

- `SnorkelingView.swift` remains in `project.yml` exclusion list.
- `DIRActivityMode.snorkeling.isLaunchableOnWatchMAIN == false`.
- Startup policy routes snorkeling to `comingSoon`.
- No `SnorkelingSessionEngine` reference in `App/DIRDivingApp.swift`.

---

## Performance / bounded data

Raw depth and GPS audit trails capped at **2048** with deterministic FIFO eviction (`SnorkelingBoundedDataTests`). Checkpoint JSON export budget under 512 KB for 50-sample probe session.

---

## Build and test results

| Target | Result |
|--------|--------|
| `xcodegen generate` | **PASS** |
| Focused Snorkeling iOS tests (85) | **PASS** |
| `DIRDiving iOS` build | **PASS** |
| `DIRDiving Watch App` build | **PASS** |
| `DIRDiving iOS Algorithm Tests` (1070 executed, 28 skipped) | **PASS** |
| `DIRDiving Watch Algorithm Tests` (687 executed, 19 skipped) | **PASS** |

Simulator: iPhone 17 Pro (iOS), Apple Watch Ultra 3 49mm (watchOS).

---

## Static scans

- No executable foreign-runtime references in Snorkeling production sources (`SnorkelingArchitectureIsolation` scan clean).
- `ExplorationStore` appears only in documentation comment (line 110 lifecycle state machine) — excluded from executable scan.
- No `Timer.scheduledTimer` canonical engine in Snorkeling shared utils.
- No demo/seeded snorkeling runtime sessions.

---

## Final readiness matrix

| Domain | Code | Automated Tests | Documentation | External/Physical |
|--------|-----:|----------------:|--------------:|-------------------|
| Domain Models | 100% | 100% | 100% | N/A |
| Schema Migration | 100% | 100% | 100% | N/A |
| Depth Feed | 100% | 100% | 100% | PENDING |
| GPS Feed | 100% | 100% | 100% | PENDING |
| GPS Quality Gating | 100% | 100% | 100% | PENDING |
| Geodetic Distance | 100% | 100% | 100% | PENDING |
| Depth-only Lifecycle | 100% | 100% | 100% | PENDING |
| Dip Lifecycle | 100% | 100% | 100% | PENDING |
| Sensor Degraded | 100% | 100% | 100% | PENDING |
| Manual Fallback | 100% | 100% | 100% | PENDING |
| Pause/Resume | 100% | 100% | 100% | PENDING |
| In-memory Checkpoint | 100% | 100% | 100% | N/A |
| Disk Persistence | Future Cmd 07 | Contract | 100% contract | PENDING |
| Architecture Isolation | 100% | 100% | 100% | N/A |
| Watch MAIN Exclusion | 100% | 100% | 100% | N/A |
| Command 04 Foundation Gate | READY | 100% | 100% | Separate |
| Navigation/Return Engine | Future Cmd 04 | Not impl. | Contract | PENDING |
| Overall Commands 01–03 | 100% | 100% | 100% | Separate |
| Production Release | Not ready | Not ready | Foundation complete | **NO-GO** |

---

## Gate decisions

```
SNORKELING_FOUNDATIONS_INTERNAL_GO
READY_FOR_SNORKELING_COMMAND_04
SNORKELING_WATCH_MAIN_UI_NOT_PROMOTED
SNORKELING_PRODUCTION_NO_GO
```

---

## Remaining future / PENDING items

1. Command 04 — bearing, waypoint ordering, return advisor, route UI, degraded-GPS navigation policy on device.
2. Command 07 — atomic disk persistence, checksum, quarantine, relaunch restore.
3. Watch MAIN UI promotion for `SnorkelingView` (separate authorized command).
4. Physical QA — Watch GPS underwater, Water Lock, wet/glove, battery/thermal.
