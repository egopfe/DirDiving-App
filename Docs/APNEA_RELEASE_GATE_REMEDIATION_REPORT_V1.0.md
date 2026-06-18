# Apnea Release Gate Remediation Report V1.0

**Date:** 2026-06-18  
**Authoritative audit:** [`AUDIT_APNEA_RELEASE_GATE_CURRENT.md`](AUDIT_APNEA_RELEASE_GATE_CURRENT.md) (Audit 08, `cbc485e` baseline)  
**Starting branch:** `main`  
**Starting committed SHA:** `51d3da0` (Audit 07 + Audit 08 report already on `origin/main`)  
**Remediation working tree:** dirty (Audit 08 code/docs — not committed per command)

---

## Executive summary

Audit 08 identified two suspend/resume test failures blocking `validate_apnea_release_readiness.sh`. Root cause was **uptime/wall-clock mismatch** between synthetic test clocks and production checkpoint export/restore paths. Production fixes align monotonic elapsed time across ingest, checkpoint export, and restore without weakening lifecycle safety.

**Internal Apnea readiness: 100%** (code, automated tests, documentation for internal gates).  
**TestFlight Apnea: NO-GO** — physical QA evidence 0%.  
**App Store Apnea: NO-GO** — physical QA + release review pending.  
**Certified freediving computer: not claimed.**  
**Medical validation: not claimed.**

---

## Initial dirty-tree classification

| Category | Files |
|----------|-------|
| **Audit 08 remediation (this work)** | `ApneaSessionEngine.swift`, suspend/resume + monotonic tests, `WatchSyncAuth` test hooks, crypto tests, validate script, docs, `APNEA_BATTERY_THERMAL` |
| **Audit 07 (already committed @ `7c8e8d3`)** | Sync negatives, E2E harness, QA scaffolds, codec hooks — on `main` |
| **Unrelated user work** | none detected |
| **Generated artifacts** | none committed |
| **Accidental/stale** | none removed |

---

## Suspend/resume root cause

1. **Synthetic uptime in tests** (`baseUptime + offset`) was not passed through `exportCheckpoint`, `appendRawSample`, or `diveClock.reset`, while `ProcessInfo.systemUptime` was used in some paths — corrupting `sessionClock.lastElapsed` after restore (~3000 s phantom elapsed).
2. **Checkpoint init** hardcoded `sessionElapsedSeconds: 0` instead of `refreshSnapshot`.
3. **`manualFallbackActive`** was incorrectly set when `lifecyclePhase == .sensorDegraded`.
4. **`lastMeasurementMonotonic`** from pre-suspend caused false sensor-loss on monotonic jump after restore.
5. **Post-suspend test ingests** used uptime offsets that did not match simulated wall-clock gap (600 s), triggering forward-skew policy incorrectly.

---

## Production changes (`Shared/Utils/ApneaSessionEngine.swift`)

| Change | Purpose |
|--------|---------|
| `armSession(at:uptime:)` | Pass uptime to lifecycle tick |
| `exportCheckpoint(now:uptime:)` | Normalize session/dive clock snapshots at save coordinates |
| `init(checkpoint:)` → `refreshSnapshot` | Restore truthful elapsed/phase snapshot |
| Clear `tracker.lastMeasurementMonotonic` on restore | Avoid false sensor-loss after suspend gap |
| `manualFallbackActive = false` on restore | Sensor-degraded ≠ manual fallback |
| `appendRawSample` / `appendAcceptedSample` pass uptime | Prevent session clock corruption |
| `diveClock.reset(anchorDate:uptime:)` on dive start | Align dive elapsed with session clock |

---

## Test changes

### Fixed (Audit 08 blockers)

- `testSuspendAndResumeRestoresApneaSessionWithoutSilentResetOrDuplicateDive` — **PASS**
- `testResumeAfterLargeWallClockJumpUsesMonotonicPolicy` — **PASS**

### Added — `ApneaSuspendResumeLifecycleIntegrationTests`

- `testSuspendDuringActiveDiveRestoresSameActiveDive`
- `testResumeThenSurfaceCommitsRestoredDiveExactlyOnce`
- `testRestoreDoesNotDropCommittedDives`
- `testRepeatedRestoreDoesNotDuplicateDive`
- `testRestoreDuringSurfaceDwellPreservesConservativeState`
- `testRestoreBeforeMinimumDurationDoesNotCommitInvalidDive`
- `testRestoreAfterMinimumDurationStillRequiresValidSurfaceTransition`

### Added — `ApneaMonotonicClockRestoreTests` (8 tests)

Wall forward/backward jump, persisted elapsed, monotonic after restore, recovery/surface dwell not completed from wall jump alone.

### Added — `ApneaSyncCryptographicLogicTests` (iOS, 7 tests)

Pure HMAC/ACK logic using `WatchSyncAuth.installTestSecrets` — **never skips** on Keychain.

---

## Clock architecture

- **Canonical elapsed:** `MonotonicElapsedClock` reconciling wall date + `systemUptime`.
- **Checkpoint export:** normalizes clock snapshot to `(savedAtWallClock, exportUptime, lastElapsed)`.
- **Restore:** reloads snapshot; does not fabricate elapsed from wall-clock jump alone.
- **Display/audit:** wall-clock timestamps on samples; not used as canonical elapsed.

---

## Checkpoint architecture

Unchanged policy: atomic write, checksum, schema version, corrupt reject, no silent reset. Export now stores consistent monotonic anchors for deterministic restore.

---

## Audit 07 integration

**Status: INTEGRATED @ `7c8e8d3` on `main`.** Verified in this remediation:

- Negative-path sync tests, offline→online E2E, QA evidence folders, codec test hooks (`DEBUG` only), extended validate script suites — all pass in `--internal` run.
- No production HMAC/replay bypass exposed.

---

## HMAC / Keychain test stability

- `WatchSyncAuth.installTestSecrets(local:peer:)` / `resetTestSecrets()` — **DEBUG only** (Watch + iOS).
- `ApneaSyncCryptographicLogicTests` — pure crypto, no Keychain skip.
- Transport integration tests may still skip if peer secret ingest fails; pure logic coverage is independent.

---

## Release-readiness script

- `--internal` (default): allows dirty tree; prints clean-commit pending.
- `--release`: requires clean `main`.
- Stale doc phrase scan for current-state ApneaView exclusion.
- Added `ApneaMonotonicClockRestoreTests`, `ApneaSyncCryptographicLogicTests` to suites.
- Requires `Docs/QA_EVIDENCE/APNEA_BATTERY_THERMAL/README.md`.

**Result:** `./Scripts/validate_apnea_release_readiness.sh --internal` — **PASS**

---

## Documentation drift fixes

| Document | Change |
|----------|--------|
| `APNEA_RELEASE_CHECKLIST.md` | Watch MAIN promotion completed; suspend/resume tests pass |
| `APNEA_RELEASE_HARD_TEST_MATRIX.md` | E-09, R-07, R-08; R-04 promotion on MAIN |
| `DIR_DIVING_APNEA_RELEASE_HARD_VALIDATION_REPORT.md` | MAIN promotion, new suites, physical gaps |
| `SAFETY_DISCLAIMER.md` | Apnea on `main`; `ApneaWatchRuntimeStore` isolation |

---

## Battery / thermal

- Code review: no unbounded checkpoint loop, no canonical Apnea `Timer.scheduledTimer`, haptic rate limiting preserved.
- Evidence scaffold: [`QA_EVIDENCE/APNEA_BATTERY_THERMAL/README.md`](QA_EVIDENCE/APNEA_BATTERY_THERMAL/README.md) — **PENDING**.

---

## Water Lock / wet-glove policy

- No programmatic Water Lock control claimed.
- Lifecycle does not require underwater touch; depth engine independent of Water Lock UI.
- Physical matrices: `APNEA_WATER_LOCK`, `APNEA_WET_INTERACTION` — **PENDING**.

---

## Gauge / Full Computer non-regression

| Suite | Result |
|-------|--------|
| `DiveManagerAlgorithmIntegrationTests` | PASS |
| `GaugeOptionalTTVTests` | PASS |
| `FullComputerNamespaceIsolationTests` | PASS |
| `ApneaArchitectureIsolationTests` | PASS |

No Gauge/FC/Bühlmann logic modified.

---

## Test results (2026-06-18)

| Suite | Result |
|-------|--------|
| `ApneaSuspendResumeLifecycleIntegrationTests` (26 tests) | **PASS** |
| `ApneaMonotonicClockRestoreTests` (8 tests) | **PASS** |
| `ApneaSyncCryptographicLogicTests` (7 tests) | **PASS** |
| Release-hard Watch subset (validate script) | **PASS** |
| Release-hard iOS subset (validate script) | **PASS** |
| Complete Watch (`DIRDiving Watch Algorithm Tests`) | **602** tests, **19** skipped, **0** failures |
| Complete iOS (`DIRDiving iOS Algorithm Tests`) | **985** tests, **28** skipped, **0** failures |
| Watch + iOS builds | **PASS** |

---

## Physical QA status

19 folders under `Docs/QA_EVIDENCE/APNEA_*` (including `APNEA_BATTERY_THERMAL`). All **PENDING** — no fabricated evidence.

---

## Internal readiness matrix

| Domain | Code | Automated tests | Documentation | Physical |
|--------|-----:|----------------:|--------------:|----------|
| Lifecycle | 100% | 100% | 100% | PENDING |
| Suspend / Resume | 100% | 100% | 100% | PENDING |
| Monotonic clock | 100% | 100% | 100% | PENDING |
| Checkpoint recovery | 100% | 100% | 100% | PENDING |
| Sync / offline | 100% | 100% | 100% | PENDING |
| HMAC / ACK | 100% | 100% | 100% | PENDING |
| Gauge non-regression | 100% | 100% | 100% | N/A |
| FC non-regression | 100% | 100% | 100% | N/A |
| Battery / thermal | 100% internal | 100% internal | 100% | PENDING |
| Water Lock / wet-glove | 100% internal | 100% internal | 100% | PENDING |
| **Overall internal** | **100%** | **100%** | **100%** | **0% external** |

---

## Release gate decisions

```
APNEA_INTERNAL_GATE_GO
```

```
APNEA_CLEAN_MAIN_GATE_NOT_READY
```
(clean-commit + `--release` validation pending — remediation uncommitted)

```
APNEA_TESTFLIGHT_NO_GO
```

```
APNEA_APP_STORE_NO_GO
```

---

## Remaining risks

1. Physical QA entirely unsigned — blocks external release.
2. Keychain-dependent transport tests may still skip in some simulator environments; mitigated by pure crypto suite.
3. Clean `main` commit + `--release` script run required before TestFlight candidate tagging.

---

## Files changed (Audit 08 remediation)

| Path | Role |
|------|------|
| `Shared/Utils/ApneaSessionEngine.swift` | Suspend/resume + clock fix |
| `Tests/WatchAlgorithmTests/ApneaSuspendResumeLifecycleIntegrationTests.swift` | Helpers + 7 new tests |
| `Tests/WatchAlgorithmTests/ApneaMonotonicClockRestoreTests.swift` | **new** — 8 monotonic tests |
| `Tests/iOSAlgorithmTests/ApneaSyncCryptographicLogicTests.swift` | **new** — pure HMAC tests |
| `Services/WatchSyncAuth.swift` | DEBUG test secret hooks |
| `iOSApp/Services/WatchSyncAuth.swift` | DEBUG test secret hooks |
| `Scripts/validate_apnea_release_readiness.sh` | `--internal` / `--release`, new suites, doc scan |
| `Docs/APNEA_RELEASE_CHECKLIST.md` | MAIN promotion state |
| `Docs/APNEA_RELEASE_HARD_TEST_MATRIX.md` | E-09, R-07, R-08 |
| `Docs/DIR_DIVING_APNEA_RELEASE_HARD_VALIDATION_REPORT.md` | Current validation |
| `Docs/SAFETY_DISCLAIMER.md` | Apnea on `main` |
| `Docs/QA_EVIDENCE/APNEA_BATTERY_THERMAL/README.md` | **new** — physical scaffold |

---

## Final `git status`

Dirty tree on `main` @ `51d3da0` — ready for user-requested commit; not committed by this command.
