# Watch CMAltimeter Full Computer Remediation Report (Current)

**Date:** 2026-06-17  
**Branch:** `main`  
**Baseline audit:** `8ab4776` (Command 18 PARTIAL)  
**Software target:** 100% software-verifiable readiness

## Executive summary

All software-verifiable WCMA findings WCMA-001…011 are remediated with request-generation isolation, sensor timestamp freshness, nil-data handling, expanded negative tests, logbook provenance hardening, duplicate sampling guard, Watch-only altitude sensor proposal settings (Automatic / Manual only / Ask before sampling), Info.plist disclosure update, and 10 m manual altitude stepper with ±100 m coarse adjust.

Physical Apple Watch QA, external Bühlmann validation, and release gate remain **PENDING**.

## Finding status

| ID | Severity | Status |
|----|----------|--------|
| WCMA-001 | P1 | FIXED — terminal-state guard on callbacks |
| WCMA-002 | P1 | FIXED — monotonic request generation |
| WCMA-003 | P2 | FIXED — `CMLogItem.timestamp` → `capturedAt` |
| WCMA-004 | P2 | DOCUMENTED — `WATCH_CMALTIMETER_SAMPLING_POLICY_CURRENT.md` |
| WCMA-005 | P2 | VERIFIED — lifecycle + remediation tests |
| WCMA-006 | P2 | DOCUMENTED_ACCEPTED_RISK — ephemeral pending proposal |
| WCMA-007 | P2 | FIXED — nil-data stream fails after 3 callbacks |
| WCMA-008 | P2 | FIXED — session + logbook provenance snapshot |
| WCMA-009 | P3 | FIXED — `requestProposalIfNeeded` single owner |
| WCMA-010 | P3 | FIXED — Info.plist EN disclosure |
| WCMA-011 | P4 | FIXED — 10 m stepper + ±100 m buttons |

## Key production changes

- `Services/FullComputerEnvironmentSensorService.swift` — request generation, timestamps, nil-data, duplicate guard
- `Services/WatchFullComputerAltitudeSensorProposalSettingsStore.swift` — Watch-only policy store
- `Views/FullComputerPrediveAltitudeSensorSupport.swift` — lifecycle modifier + settings section
- `Services/DiveManager.swift` — `fullComputerSessionEnvironmentRecord` for logbook
- `Shared/Models/FullComputerEnvironmentRecord.swift` — `sensorReceivedAt`, `logbookRecord()`
- Tests: `WatchCMAltimeterLifecycleTests`, `WatchCMAltimeterRemediationTests`, expanded orchestrated tests

## Validation

```bash
xcodegen generate
./Scripts/validate_watch_cmaltimeter_full_computer_readiness.sh
```

Watch Algorithm Tests: **988/988 PASS** (post-remediation).

## Final verdict

```text
WATCH_CMALTIMETER_FULL_COMPUTER_REMEDIATION: PASS
WATCH_CMALTIMETER_FULL_COMPUTER_SOFTWARE_READINESS: 100%
PHYSICAL_APPLE_WATCH_SENSOR_QA: PENDING
RELEASE_GATE: PENDING_PHYSICAL_EVIDENCE
```
