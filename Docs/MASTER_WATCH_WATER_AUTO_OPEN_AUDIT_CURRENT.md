# Master Watch Water Auto-Open Audit — Current

**Command:** `03-MASTER_UI_UX_FULL_DEEP_COMPREHENSIVE_AUDIT_COMMAND_V2.3.md` §30.1  
**Audit date:** 2026-06-30  
**Branch:** `main` @ `451f8fb`  
**Execution:** Read-only static/source audit

---

## Executive Summary

Water auto-open routing policy, Settings UX, safety copy, and cold-launch integration are **software-truthful and safety-gated** at `451f8fb`. The feature **does not start a dive**, **blocks during active sessions**, **routes Full Computer to predive confirmation**, and **applies depth capability policy (CONS-019)** before FC predive. System submerged auto-launch listing and end-to-end wet routing remain **PENDING_PHYSICAL**.

| Gate | Verdict |
|------|---------|
| `WATCH_WATER_AUTO_OPEN_AUDIT` | **PARTIAL** |
| `WATER_AUTO_OPEN_ROUTING_POLICY` | **PASS** (software) |
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

## Routing Flow Verified

1. **Cold launch submerged probe:** `WatchSubmersionLaunchProbe` → `WatchLaunchRoutingPolicy.resolveColdLaunchEntryPoint` (400ms timeout — documented limitation).
2. **User cold launch:** `beginInitialLaunch(entry: .userColdLaunch)` — never applies WAO unless submerged entry resolved.
3. **Water auto-launch intent:** `OpenWaterAutoLaunchModeIntent` → legal gate → `beginWaterAutoLaunch()` → `beginInitialLaunch(entry: .waterAutoLaunchIntent)`.
4. **Active session block:** `canChangeModes` false → toast `modeChangeBlockedToast`; Apply Route Now disabled in Settings.
5. **FC path:** Startup step resolves to predive configuration/confirmation, not live decompression runtime.
6. **Depth gate:** `DIRStartupSelectionPolicy.resolveAutomaticStep` applies `DepthCapabilityPolicy.supportsFullComputerRuntime` before FC predive (CONS-019 remediated).

---

## Settings UX (`WatchWaterAutoOpenSettingsView`)

| Section | Truthfulness |
|---------|--------------|
| Mode picker (Disabled / Last / Preferred) | PASS |
| Preferred activity + diving mode | PASS |
| System auto-launch setup instructions | PASS — does not claim guaranteed system listing |
| Explanation | PASS — prepares/routes only |
| Cold launch limitation | PASS — discloses probe timeout |
| System limitation | PASS — no false auto-launch guarantee |
| Full Computer warning | PASS — predive confirmation required |
| Apply Route Now | PASS — blocked during active session |

Automated copy tests: `WatchWaterAutoOpenSettingsCopyTests`.

---

## Cold-Launch Modal Sequencing

`ContentView` @ `451f8fb`:

1. `WatchFirstLaunchLocationPermissionHost` wraps main UI.
2. `launchCompanionDisclaimer` (`showLaunchDisclaimer`) before startup flow.
3. `StartupFlowView` fullScreenCover when `startupFlowPresented`.
4. Submersion probe begins after disclaimer dismissed (`beginInitialLaunchIfNeeded`).

**PASS** for software sequencing; submerged cold-launch on hardware **PENDING_PHYSICAL**.

---

## Mandatory Negative Checks

| Check | Result |
|-------|--------|
| Disabled → normal startup | PASS |
| WAO does not call `startManualDive()` | PASS |
| WAO does not bypass legal onboarding | PASS |
| WAO does not bypass FC predive | PASS |
| WAO blocked during active Diving/Apnea/Snorkeling | PASS |
| Corrupt prefs → safe fallback | PASS |
| iOS does not claim guaranteed water auto-open | PASS (no iOS WAO surface) |

---

## Findings

| ID | Sev | Title |
|----|-----|-------|
| MUIUX-P1-001 | P1 | Water auto-open end-to-end physical QA pending |
| MUIUX-P2-004 | P2 | Submersion probe 400ms timeout — field validation pending |

No open software **P0** water auto-open findings.

---

## Final Verdict Block

```text
WATCH_WATER_AUTO_OPEN_AUDIT: PARTIAL
WATER_AUTO_OPEN_ROUTING_POLICY: PASS
WATCHOS_SYSTEM_AUTO_LAUNCH_LISTING_EVIDENCE: PENDING_PHYSICAL
UI_UX_NO_UNSUPPORTED_WATER_AUTO_OPEN_CLAIMS: PASS
```

Matrix: `Docs/MASTER_WATCH_WATER_AUTO_OPEN_QA_MATRIX_CURRENT.csv`
