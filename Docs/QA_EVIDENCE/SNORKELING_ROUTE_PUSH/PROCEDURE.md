# WatchConnectivity E2E — SNORKELING_ROUTE_PUSH

| Field | Value |
|-------|-------|
| **Harness type** | Documented manual/integration procedure |
| **Status** | **PENDING** — not executed in CI |
| **Linked QA folder** | `Docs/QA_EVIDENCE/SNORKELING_ROUTE_PUSH/` |

## Purpose

Validate the full Snorkeling route push path:

```text
iOS route planner send → Watch import → ACK → iOS acknowledged state
```

## Preconditions

1. Paired iPhone and Apple Watch with DIR Diving iOS + Watch builds at the recorded commit SHA.
2. WatchConnectivity activated; Watch app installed.
3. Snorkeling route drafted on iOS with valid entry/exit and passes validation.
4. No active Snorkeling session on Watch (or document pending-route activation scenario separately).

## Procedure

1. On iOS, open Snorkeling route planner and tap send to Watch.
2. Confirm iOS transfer state moves to sending/awaiting ACK (not failed).
3. On Watch, open Snorkeling ready screen and confirm route status shows ready or pending (if session active).
4. Force-quit iOS app while transfer is queued/awaiting ACK; relaunch and confirm pending queue restores (R1-007).
5. When Watch imports route, confirm ACK returns to iOS and state becomes acknowledged.
6. Capture logs/screenshots under `Docs/QA_EVIDENCE/SNORKELING_ROUTE_PUSH/` — do **not** mark PASS without artifacts.

## Expected results

| Step | Expected |
|------|----------|
| Send | iOS shows success or queued state; no validation failure |
| Watch import | Route name/revision visible on ready panel |
| ACK | iOS `IOSSnorkelingWatchTransferService` acknowledged; pending queue empty |
| Relaunch | Pending send survives process kill until ACK or explicit failure |

## Automated coverage (software only)

- `SnorkelingRouteAckRoundTripTests`
- `SnorkelingPendingRouteQueuePersistenceTests`
- `SnorkelingRouteSyncStatusPresentationTests`

These do **not** replace paired-device E2E evidence.

## Verdict

**PENDING** — execute on hardware before marking `SNORKELING_ROUTE_PUSH` PASS.
