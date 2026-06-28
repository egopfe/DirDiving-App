# Master Watch Underwater Hardware Interaction Audit — Current

**Command:** `03-MASTER_UI_UX_FULL_DEEP_COMPREHENSIVE_AUDIT_COMMAND_V2.1.md` §30.2–30.3  
**Audit date:** 2026-06-28  
**Branch:** `main`  
**Commit:** `7dfefe2`  
**Method:** Read-only static audit + XCTest contract review (tests NOT re-run — DerivedData lock)

---

## Executive summary

Digital Crown vertical paging and the **Underwater Primary Action** router pass **software** gates. Crown page policy restricts active-session navigation by activity. Alarm/overlay acknowledgement has highest priority. Legacy App Intents now route through `WatchIntentSafetyPolicy` during active sessions.

| Layer | Verdict |
|-------|---------|
| **SOFTWARE_READY** | **PASS** — Crown policy, clamp, router, intents, help copy |
| **PENDING_PHYSICAL** | Water Lock, Action Button, crown paging underwater, toast/haptic under Water Lock |

---

## Verified behavior (software)

| Area | Result | Evidence |
|------|--------|----------|
| Crown = vertical page navigation | PASS | `ContentView` TabView `.verticalPage` |
| Diving active: Live + Compass + Images (if any) | PASS | `WatchUnderwaterPagePolicy` |
| Apnea/Snorkeling active: Live only | PASS | Policy + unit tests |
| Settings/Logbook/mode blocked → Live + toast | PASS | `WatchUnderwaterNavigationClampPolicy`, `AppNavigationStore` |
| Per-activity blocked-nav copy + a11y | PASS | `nav.underwater.blocked.{diving,apnea,snorkeling}` EN/IT |
| Primary action via router | PASS | `ExecuteUnderwaterPrimaryActionIntent` |
| Legacy intents route/block during session | PASS | `WatchIntentSafetyPolicy` |
| Alarm ack priority | PASS | `WatchUnderwaterActionResolver` |
| FC hidden stopwatch → unavailable | PASS | Resolver + tests |
| Legal gate on all 9 intents | PASS | `ActionButtonIntents` |
| Side button / Crown press not claimed | PASS | Help strings + user guide |
| Underwater hint overlay | PASS | `WatchUnderwaterPrimaryActionHintView` |
| Underwater Primary Action help panel | PASS | `SettingsView` `WatchShortcutHelpView` |
| Legacy intents help panel | PASS | `shortcuts.help.legacy_intents.*` |

---

## Closed findings (since 83f884e)

| ID | Was | Now |
|----|-----|-----|
| P1-AB-001 | Legacy intents bypass router | **CLOSED** — `WatchIntentSafetyPolicy.routePrimaryActionIfUnderwaterSession` |
| P2-UX-001 | Stale underwater help body | **CLOSED** — EN/IT updated |
| P2-UX-002 | Missing Underwater Action help | **CLOSED** — help panel added |
| P2-UX-003 | Diving-centric blocked toast | **CLOSED** — per-activity keys |
| P2-TEST-002/003 | Stale/missing clamp tests | **CLOSED** — `WatchUnderwaterNavigationClampPolicyTests` |

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
WATCH_UNDERWATER_HARDWARE_INTERACTION_AUDIT: PARTIAL (software PASS; physical PENDING)
DIGITAL_CROWN_UNDERWATER_PAGE_POLICY: PASS (software) / PENDING_PHYSICAL
ACTION_BUTTON_UNDERWATER_PRIMARY_ACTION: PASS (software) / PENDING_PHYSICAL
WATER_LOCK_PHYSICAL_QA: PENDING_PHYSICAL
```
