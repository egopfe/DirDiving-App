# Master Watch Underwater Hardware Interaction Audit — Current

**Command:** `03-MASTER_UI_UX_FULL_DEEP_COMPREHENSIVE_AUDIT_COMMAND_V2.1.md` §30.2–30.3  
**Audit date:** 2026-06-27  
**Branch:** `main`  
**Commit:** `83f884e`  
**Method:** Read-only static audit + XCTest contract review (not re-run on device)

---

## Executive summary

Digital Crown vertical paging and the **Underwater Action** primary-action router are **implemented and tested in software**. Crown page policy correctly restricts active-session navigation by activity. Alarm/overlay acknowledgement has highest priority on the Action Button path.

The audit is **PARTIAL** because:

1. **Physical QA is entirely pending** (Water Lock, Action Button, crown paging underwater).
2. **Legacy App Intents** still bypass `WatchUnderwaterActionRouter` (P1).
3. **Help copy and toast strings** are partially stale or Diving-centric (P2).
4. **ContentView integration tests** for blocked-navigation clamp are missing (P2).

---

## Verified behavior (software)

| Area | Result | Evidence |
|------|--------|----------|
| Crown = vertical page navigation | PASS | `ContentView` TabView `.verticalPage` |
| Diving active: Live + Compass + Images (if any) | PASS | `WatchUnderwaterPagePolicy` |
| Apnea/Snorkeling active: Live only | PASS | Policy + 8 unit tests |
| Settings/Logbook/mode blocked → Live + toast | PASS | `ContentView` clamp + `AppNavigationStore` |
| Primary action via router | PASS | `ExecuteUnderwaterPrimaryActionIntent` |
| Alarm ack priority | PASS | `WatchUnderwaterActionResolver` |
| FC hidden stopwatch → unavailable | PASS | Resolver + tests |
| Legal gate on all 9 intents | PASS | `ActionButtonIntents` + safety tests |
| Side button / Crown press not claimed | PASS | Help strings + user guide |
| Underwater hint overlay | PASS | `WatchUnderwaterPrimaryActionHintView` |

---

## Findings

### P1 — P1-AB-001: Legacy App Intents bypass router

| Field | Value |
|-------|-------|
| Severity | P1 |
| Platform | watchOS |
| Files | `Services/ActionButtonIntents.swift` |
| Observed | Seven granular shortcuts (`ToggleStopwatchIntent`, `StartManualDiveIntent`, etc.) call managers directly |
| Expected | Underwater primary path uses `WatchUnderwaterActionRouter` only; legacy shortcuts documented as surface/advanced |
| Safety impact | User assigning legacy shortcut to Action Button may get context-unaware behavior underwater |
| Remediation | Document surface-only use; or route legacy intents through router when session active |
| Physical QA | PENDING_PHYSICAL_ACTION_BUTTON_QA |

### P2 — P2-UX-001: Stale underwater help body

| Field | Value |
|-------|-------|
| Severity | P2 |
| Files | `Resources/en.lproj/Localizable.strings` (`shortcuts.help.underwater.body`) |
| Observed | Copy mentions only Live and Compass |
| Expected | Include User Images (when present) and Apnea/Snorkeling live-only rules |

### P2 — P2-UX-002: Missing Underwater Action help panel

| Field | Value |
|-------|-------|
| Severity | P2 |
| Files | `Views/SettingsView.swift` (`WatchShortcutHelpView`) |
| Observed | No dedicated panel for **Underwater Action** shortcut |
| Expected | Recommend Ultra Action Button assignment per user guide |

### P2 — P2-UX-003: Blocked-navigation toast Diving-centric

| Field | Value |
|-------|-------|
| Severity | P2 |
| Files | `nav.underwater.blocked` localization |
| Observed | "Settings locked during dive" for all blocked pages/activities |
| Expected | Activity-neutral or activity-specific copy |

### P2 — P2-TEST-002/003: Stale/missing integration tests

| Field | Value |
|-------|-------|
| Severity | P2 |
| Files | `WatchSettingsRoutingTests.swift`, `ContentView.swift` |
| Observed | Source grep asserts removed pattern; no behavioral clamp tests |
| Expected | Tests for Settings/Logbook/Compass block → Live + toast |

---

## Physical QA status

All templates under `Docs/QA_EVIDENCE/WATCH_UNDERWATER_FAST_CONTROLS_*` remain **PENDING_PHYSICAL**.

| Gate | Status |
|------|--------|
| PENDING_PHYSICAL_WATER_LOCK_QA | NOT_EXECUTED |
| PENDING_PHYSICAL_ACTION_BUTTON_QA | NOT_EXECUTED |
| PENDING_PHYSICAL (crown underwater) | NOT_EXECUTED |

**Matrix:** [`MASTER_WATCH_UNDERWATER_HARDWARE_INTERACTION_MATRIX_CURRENT.csv`](MASTER_WATCH_UNDERWATER_HARDWARE_INTERACTION_MATRIX_CURRENT.csv)

---

## Final verdict

```text
WATCH_UNDERWATER_HARDWARE_INTERACTION_AUDIT: PARTIAL
DIGITAL_CROWN_UNDERWATER_PAGE_POLICY: PASS (software) / PENDING_PHYSICAL
ACTION_BUTTON_UNDERWATER_PRIMARY_ACTION: PARTIAL / PENDING_PHYSICAL
WATER_LOCK_PHYSICAL_QA: PENDING_PHYSICAL
```
