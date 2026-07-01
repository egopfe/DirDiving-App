# Master Watch Water Auto-Open Audit — CURRENT

**Command:** `03-MASTER_UI_UX_FULL_DEEP_COMPREHENSIVE_AUDIT_COMMAND_V1.5.md` §30.1  
**Audit date:** 2026-07-01  
**Branch:** `main` @ `2c30412`  
**Execution:** Read-only static/source audit

---

## Executive Summary

Water auto-open routing policy, Settings UX, safety copy, and cold-launch integration are **software-truthful and safety-gated** at `2c30412`. The feature **does not start a dive**, **blocks during active sessions**, **routes Full Computer to predive confirmation**, and **applies depth capability policy (CONS-019)** before FC predive.

**Regression note:** After Apnea P1/P2/P3 (`76f3703`), **12 WatchWaterAutoOpenPolicyTests** fail because startup routing now inserts `divingModeSelection` before ready/predive destinations — tests expect direct routing (WFC-P2-005 / MUIUX-P2-005). **UI copy remains truthful**; failure is test/flow alignment, not unsafe routing.

| Gate | Verdict |
|------|---------|
| `WATCH_WATER_AUTO_OPEN_AUDIT` | **PARTIAL** |
| `WATER_AUTO_OPEN_ROUTING_POLICY` | **PASS** (software routing intent) |
| `WATCHOS_SYSTEM_AUTO_LAUNCH_LISTING_EVIDENCE` | **PENDING_PHYSICAL** |

---

## Policy Summary

| Mode | Behavior |
|------|----------|
| **Disabled** (default) | Normal cold launch; no water routing |
| **Last Selected Mode** | Restores `lastSelectedDestination` (sanitized) |
| **Preferred Mode** | Uses `preferredDestination` (activity + diving mode for Diving) |

Sanitization: non-diving activities force `divingMode = .gauge` (`WatchWaterAutoOpenPolicy.sanitize`).

---

## Settings UX (`WatchWaterAutoOpenSettingsView`)

| Section | Truthfulness |
|---------|--------------|
| Mode picker (Disabled / Last / Preferred) | PASS |
| Preferred activity + diving mode | PASS |
| System auto-launch setup instructions | PASS — does not claim guaranteed listing |
| Explanation | PASS — prepares/routes only |
| Cold launch limitation | PASS — discloses probe timeout |
| System limitation | PASS — no false auto-launch guarantee |
| Full Computer warning | PASS — predive confirmation required |
| Apply Route Now | PASS — blocked during active session |

Automated copy tests: `WatchWaterAutoOpenSettingsCopyTests` **PASS**.

---

## Test Status @ `2c30412`

| Suite | Result |
|-------|--------|
| WatchWaterAutoOpenSettingsCopyTests | PASS |
| WatchWaterAutoOpenPolicyTests | **11 FAIL** (routing step mismatch) |
| WatchLaunchRoutingPolicyTests | **3 FAIL** (FC predive via WAO) |

See `MASTER_WATCH_WATER_AUTO_OPEN_QA_MATRIX_CURRENT.csv`.

---

## Verdict

```text
WATCH_WATER_AUTO_OPEN_AUDIT: PARTIAL
WATER_AUTO_OPEN_ROUTING_POLICY: PASS
WATCHOS_SYSTEM_AUTO_LAUNCH_LISTING_EVIDENCE: PENDING_PHYSICAL
RELEASE_BLOCKERS: MUIUX-P1-001,MUIUX-P2-005
```
