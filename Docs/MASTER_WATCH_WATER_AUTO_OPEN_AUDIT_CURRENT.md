# Master Watch Water Auto-Open Audit — Current

**Command:** `03-MASTER_UI_UX_FULL_DEEP_COMPREHENSIVE_AUDIT_COMMAND_V2.2.md` §30.1  
**Audit date:** 2026-06-29  
**Branch:** `main`  
**Commit:** `15c8068` (`15c80680da9f53b57153efea751fc5f8a29e5c4d`)  
**Prior baseline:** `7dfefe2`  
**Remediation wave:** `5d757cc` (CONS-019 depth gate)  
**Method:** Read-only static audit + XCTest contract review

---

## Executive summary

Water auto-open **policy, persistence, sanitization, routing, Settings UX, safety gates, and CONS-019 depth capability gate** pass **software** gates at `15c8068`. Cold-launch submersion probe wiring, cold-launch limitation disclosure, **Apply Route Now**, and modal sequencing fixes from the June 2026 wave remain valid.

The audit is **PARTIAL** overall because **physical/system QA remains entirely pending** — not because of open software defects in this area.

| Layer | Verdict |
|-------|---------|
| **SOFTWARE_READY** | **PASS** — policy, routing, Settings, depth gate, tests |
| **PENDING_PHYSICAL** | Water Lock, submerged auto-launch listing, end-to-end water entry |

### CONS-019 status

| Item | Result |
|------|--------|
| **CONS-019** WAO FC routing skips depth gate | **FIXED_SOFTWARE** @ `5d757cc` |
| Verification @ `15c8068` | `DIRStartupSelectionPolicy.resolveAutomaticStep` L99–107 applies `DepthCapabilityPolicy.current` before FC predive |
| Shallow-only + FC preferred/last-selected | Downgrades to Gauge when gauge allowed; else `.divingModeSelection` — not FC predive |
| Matrix row | **WAO-018** in [`MASTER_WATCH_WATER_AUTO_OPEN_QA_MATRIX_CURRENT.csv`](MASTER_WATCH_WATER_AUTO_OPEN_QA_MATRIX_CURRENT.csv) |

---

## Verified behavior (software)

| Requirement | Result | Evidence |
|-------------|--------|----------|
| Modes: Disabled / Last Selected / Preferred | PASS | `WatchWaterAutoOpenMode`, `WatchWaterAutoOpenSettingsView` |
| Default = Disabled | PASS | `testDefaultModeIsDisabled` |
| Preferred sanitized; non-diving → Gauge semantics | PASS | `WatchWaterAutoOpenPolicy.sanitize` |
| Preferred FC → predive configuration (when depth allows) | PASS | `testPreferredDivingFullComputerResolvesToPrediveConfiguration` |
| **Depth gate on automatic routing** | PASS | `resolveAutomaticStep` L99–107; WAO-018 |
| Does not start dive/session | PASS | `beginWaterAutoLaunch`, intent source tests |
| Blocked during active Diving/Apnea/Snorkeling | PASS | `canChangeModes` + block tests |
| Legal gate on intent | PASS | `OpenWaterAutoLaunchModeIntent` |
| Settings disabled during active Diving | PASS | `SettingsView` `.disabled(dive.isDiveActive)` |
| System listing not falsely claimed | PASS | `settings.water_auto_open.system_limitation` |
| FC warning copy in settings | PASS | `fullComputerWarningSection` |
| Cold-launch limitation disclosed in Settings | PASS | `coldLaunchLimitationSection` EN/IT |
| Normal icon cold launch does not apply water routing | PASS | `WatchLaunchRoutingPolicy` |
| Submerged cold launch applies routing when enabled | PASS | `ContentView.beginInitialLaunchIfNeeded`, `WatchSubmersionLaunchProbe` |
| Apply Route Now (in-app test path) | PASS | `WatchWaterAutoOpenSettingsView.applyConfiguredWaterRouteNow` |
| Cold-launch modal sequencing (no double cover) | PASS | `ContentView` disclaimer → startup binding @ `2e3f262` |

---

## Closed findings

| ID | Was | Now | Evidence |
|----|-----|-----|----------|
| CONS-019 | WAO skipped depth gate | **FIXED_SOFTWARE** | `resolveAutomaticStep` depth policy @ `5d757cc` |
| P1-WAO-001 | Cold launch not wired | **CLOSED** | `WatchLaunchRoutingPolicy`, `WatchSubmersionLaunchProbe` |
| P1-WAO-002 | Cold-launch limitation missing | **CLOSED** | `settings.water_auto_open.cold_launch_limitation` EN/IT |
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
CONS-019: FIXED_SOFTWARE
```
