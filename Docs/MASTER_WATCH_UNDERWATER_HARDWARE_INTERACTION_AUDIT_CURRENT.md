# Master Watch Underwater Hardware Interaction Audit — CURRENT

**Command:** 03 V1.5 §30.2–30.3  
**Date:** 2026-07-01  
**Commit:** `2c30412`

---

## Executive Summary

Digital Crown vertical paging, underwater page clamp, blocked-navigation toast, and context-aware Underwater Primary Action router are **implemented and software-tested**. Action Button / App Intents route through `WatchUnderwaterActionRouter` only with legal acceptance gate. **Physical Water Lock, Action Button, and Crown behavior under water remain PENDING_PHYSICAL**.

| Gate | Verdict |
|------|---------|
| `WATCH_UNDERWATER_HARDWARE_INTERACTION_AUDIT` | **PARTIAL** |
| `DIGITAL_CROWN_UNDERWATER_PAGE_POLICY` | **PASS** (software) |
| `ACTION_BUTTON_UNDERWATER_PRIMARY_ACTION` | **PASS** (software) |
| `WATER_LOCK_PHYSICAL_QA` | **PENDING_PHYSICAL** |

---

## Crown Policy Verified

- Diving active: Live, Compass, User Images (if inventory)
- Apnea active: Live only
- Snorkeling active: Live only
- Settings/Logbook/mode selection blocked → clamp to Live + toast
- Toast localized EN/IT; does not cover critical metrics (layout contracts)

**Source:** `WatchUnderwaterPagePolicy.swift`, `WatchUnderwaterNavigationClampPolicy.swift`, `ContentView.swift`

---

## Action Button / Primary Action Verified

- Alarm ack priority > Apnea overlay ack > page actions
- Diving Live stopwatch toggle when visible; FC hidden stopwatch → unavailable
- Compass: set/update bearing (never clear underwater)
- User Images: next image when present
- Settings page: return to dashboard; no settings mutation underwater
- `ExecuteUnderwaterPrimaryActionIntent` → router only; legal gate required

**Tests:** `WatchUnderwaterActionRouterTests` **PASS** @ Audit 01 session.

---

## Apnea P1/P2/P3 Interaction

- Apnea live page: primary action unavailable (no hidden stopwatch)
- Training/alarm overlays: ack priority preserved
- Crown clamp: live only during active Apnea session

---

## Physical QA Pending

All items in `MASTER_UI_UX_EXTERNAL_PHYSICAL_QA_PENDING_CURRENT.md` § Underwater Hardware.

---

## Verdict

```text
WATCH_UNDERWATER_HARDWARE_INTERACTION_AUDIT: PARTIAL
DIGITAL_CROWN_UNDERWATER_PAGE_POLICY: PASS
ACTION_BUTTON_UNDERWATER_PRIMARY_ACTION: PASS
WATER_LOCK_PHYSICAL_QA: PENDING_PHYSICAL
RELEASE_BLOCKERS: MUIUX-P1-002
```

Matrix: `MASTER_WATCH_UNDERWATER_HARDWARE_INTERACTION_MATRIX_CURRENT.csv`
