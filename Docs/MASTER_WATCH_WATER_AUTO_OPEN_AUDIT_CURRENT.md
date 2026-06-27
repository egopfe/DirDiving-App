# Master Watch Water Auto-Open Audit — Current

**Command:** `03-MASTER_UI_UX_FULL_DEEP_COMPREHENSIVE_AUDIT_COMMAND_V2.1.md` §30.1  
**Audit date:** 2026-06-27  
**Branch:** `main`  
**Commit:** `83f884e`  
**Method:** Read-only static audit + `WatchWaterAutoOpenPolicyTests` contract review

---

## Executive summary

Water auto-open **policy, persistence, sanitization, and safety gates** are implemented and well-tested. Settings UX includes truthful system-limitation and Full Computer warning copy. The feature **does not start dives** and **blocks during active sessions**.

The audit is **PARTIAL** because:

1. **Cold launch does not invoke water auto-open policy** — only `OpenWaterAutoLaunchModeIntent` calls `beginWaterAutoLaunch()` (P1).
2. **Cold-launch submersion detection limitation** is not disclosed in Settings UI (P1).
3. **System Auto-Launch listing** and end-to-end water entry remain **PENDING_PHYSICAL**.
4. Missing test: lastSelected + Full Computer → predive (P2).

---

## Verified behavior (software)

| Requirement | Result | Evidence |
|-------------|--------|----------|
| Modes: Disabled / Last Selected / Preferred | PASS | `WatchWaterAutoOpenMode`, settings view |
| Default = Disabled | PASS | `testDefaultModeIsDisabled` |
| Preferred sanitized; non-diving → Gauge semantics | PASS | `WatchWaterAutoOpenPolicy.sanitize` |
| Preferred FC → predive configuration | PASS | `testPreferredDivingFullComputerResolvesToPrediveConfiguration` |
| Does not start dive/session | PASS | Intent source tests |
| Blocked during active Diving/Apnea/Snorkeling | PASS | 3 block tests |
| Legal gate on intent | PASS | `OpenWaterAutoLaunchModeIntent` |
| Settings disabled during active Diving | PASS | `SettingsView` `.disabled(dive.isDiveActive)` |
| System listing not falsely claimed | PASS | `settings.water_auto_open.system_limitation` |
| FC warning copy in settings | PASS | `WatchWaterAutoOpenSettingsView` |

---

## Critical finding — P1-WAO-001: Cold launch wiring gap

| Field | Value |
|-------|-------|
| Severity | P1 |
| Priority | Before internal TestFlight if marketing copy implies automatic routing |
| Platform | watchOS |
| Screen | Startup / Settings |
| Files | `Views/ContentView.swift` L112–115; `Services/DIRActivitySelectionStore.swift`; `Services/ActionButtonIntents.swift` L157 |
| Observed | `onAppear` always calls `beginColdLaunch()`. `beginWaterAutoLaunch()` only from App Intent |
| Expected | Either OS water-entry callback invokes policy, or Settings copy states routing requires system Auto-Launch + intent |
| Coherence impact | User may enable Preferred Mode but see normal cold launch unless watchOS triggers intent |
| Safety impact | Low direct safety risk; **truthfulness / reachability** impact |
| Remediation | Wire submersion/auto-launch entry to `beginWaterAutoLaunch()` when watchOS API available; or update all user-facing copy |
| Acceptance tests | Integration test: simulated water-entry launch path applies policy |
| Release impact | Blocks claiming “opens automatically when entering water” without physical evidence + wiring |

---

## P1-WAO-002: Cold-launch limitation not in Settings UI

| Field | Value |
|-------|-------|
| Severity | P1 |
| Files | `WatchWaterAutoOpenSettingsView`, localization |
| Observed | Limitation documented only in `WATCH_WATER_AUTO_OPEN_IMPLEMENTATION_REPORT_CURRENT.md` |
| Expected | Settings disclosure per audit §417–418 |

---

## Physical / system QA

| Gate | Status |
|------|--------|
| PENDING_PHYSICAL_WATER_AUTO_OPEN_QA | NOT_EXECUTED |
| PENDING_WATCHOS_SYSTEM_AUTO_LAUNCH_LISTING_QA | NOT_EXECUTED |

Evidence folders: `Docs/QA_EVIDENCE/WATCH_WATER_AUTO_OPEN_*` (all PENDING).

**Matrix:** [`MASTER_WATCH_WATER_AUTO_OPEN_QA_MATRIX_CURRENT.csv`](MASTER_WATCH_WATER_AUTO_OPEN_QA_MATRIX_CURRENT.csv)

---

## Final verdict

```text
WATCH_WATER_AUTO_OPEN_AUDIT: PARTIAL
WATER_AUTO_OPEN_ROUTING_POLICY: PARTIAL (policy PASS; cold-launch wiring FAIL)
WATCHOS_SYSTEM_AUTO_LAUNCH_LISTING_EVIDENCE: PENDING_PHYSICAL
```
