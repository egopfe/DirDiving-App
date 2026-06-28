# Master Watch Water Auto-Open Audit — Current

**Command:** `03-MASTER_UI_UX_FULL_DEEP_COMPREHENSIVE_AUDIT_COMMAND_V2.1.md` §30.1  
**Audit date:** 2026-06-28  
**Branch:** `main`  
**Commit:** `7dfefe2` (`7dfefe2cd7817780a903a64e51b890d901111ffd`)  
**Method:** Read-only static audit + XCTest contract review (tests NOT re-run — DerivedData lock)

---

## Executive summary

Water auto-open **policy, persistence, sanitization, routing, Settings UX, and safety gates** pass **software** gates at `7dfefe2`. Since the prior audit (`83f884e`), cold-launch submersion probe wiring, cold-launch limitation disclosure, **Apply Route Now**, and modal sequencing fixes landed (`9176da8`, `2e3f262`).

The audit is **PARTIAL** overall because **physical/system QA remains entirely pending** — not because of open software defects in this area.

| Layer | Verdict |
|-------|---------|
| **SOFTWARE_READY** | **PASS** — policy, routing, Settings, tests |
| **PENDING_PHYSICAL** | Water Lock, submerged auto-launch listing, end-to-end water entry |

---

## Verified behavior (software)

| Requirement | Result | Evidence |
|-------------|--------|----------|
| Modes: Disabled / Last Selected / Preferred | PASS | `WatchWaterAutoOpenMode`, `WatchWaterAutoOpenSettingsView` |
| Default = Disabled | PASS | `testDefaultModeIsDisabled` |
| Preferred sanitized; non-diving → Gauge semantics | PASS | `WatchWaterAutoOpenPolicy.sanitize` |
| Preferred FC → predive configuration | PASS | `testPreferredDivingFullComputerResolvesToPrediveConfiguration` |
| Does not start dive/session | PASS | `beginWaterAutoLaunch`, intent source tests |
| Blocked during active Diving/Apnea/Snorkeling | PASS | `canChangeModes` + block tests |
| Legal gate on intent | PASS | `OpenWaterAutoLaunchModeIntent` |
| Settings disabled during active Diving | PASS | `SettingsView` `.disabled(dive.isDiveActive)` |
| System listing not falsely claimed | PASS | `settings.water_auto_open.system_limitation` |
| FC warning copy in settings | PASS | `fullComputerWarningSection` |
| Cold-launch limitation disclosed in Settings | PASS | `coldLaunchLimitationSection` EN/IT |
| Normal icon cold launch does not apply water routing | PASS | `WatchLaunchRoutingPolicy`, `testBeginInitialLaunchColdLaunchDoesNotApplyWaterRouting` |
| Submerged cold launch applies routing when enabled | PASS | `ContentView.beginInitialLaunchIfNeeded`, `WatchSubmersionLaunchProbe`, `WatchLaunchRoutingPolicyTests` |
| Apply Route Now (in-app test path) | PASS | `WatchWaterAutoOpenSettingsView.applyConfiguredWaterRouteNow` |
| Cold-launch modal sequencing (no double cover) | PASS | `ContentView` disclaimer → startup binding @ `2e3f262` |

---

## Closed findings (since 83f884e)

| ID | Was | Now | Evidence |
|----|-----|-----|----------|
| P1-WAO-001 | Cold launch not wired | **CLOSED** | `WatchLaunchRoutingPolicy`, `WatchSubmersionLaunchProbe`, `beginInitialLaunch(entry:)` |
| P1-WAO-002 | Cold-launch limitation missing in Settings | **CLOSED** | `settings.water_auto_open.cold_launch_limitation` EN/IT |
| P2-TEST-001 | Missing lastSelected FC predive test | **CLOSED** | `testLastSelectedFullComputerRoutesPrediveConfiguration` |

---

## Physical / system QA (PENDING)

| Gate | Status |
|------|--------|
| PENDING_PHYSICAL_WATER_AUTO_OPEN_QA | NOT_EXECUTED |
| PENDING_WATCHOS_SYSTEM_AUTO_LAUNCH_LISTING_QA | NOT_EXECUTED |
| PENDING_PHYSICAL_WATER_LOCK_QA | NOT_EXECUTED |

Evidence folders: `Docs/QA_EVIDENCE/WATCH_WATER_AUTO_OPEN_*` — templates only.

**Matrix:** [`MASTER_WATCH_WATER_AUTO_OPEN_QA_MATRIX_CURRENT.csv`](MASTER_WATCH_WATER_AUTO_OPEN_QA_MATRIX_CURRENT.csv)

---

## Final verdict

```text
WATCH_WATER_AUTO_OPEN_AUDIT: PARTIAL (software PASS; physical PENDING)
WATER_AUTO_OPEN_ROUTING_POLICY: PASS (software) / PENDING_PHYSICAL
WATCHOS_SYSTEM_AUTO_LAUNCH_LISTING_EVIDENCE: PENDING_PHYSICAL
```
