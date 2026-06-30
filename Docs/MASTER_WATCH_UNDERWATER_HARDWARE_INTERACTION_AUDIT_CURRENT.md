# Master Watch Underwater Hardware Interaction Audit — Current

**Command:** `03-MASTER_UI_UX_FULL_DEEP_COMPREHENSIVE_AUDIT_COMMAND_V2.3.md` §30.2–30.3  
**Audit date:** 2026-06-30  
**Branch:** `main` @ `451f8fb` (`451f8fb644a85d8d205d53ef769e29ff9ed4f958d`)  
**Execution:** Read-only static/source audit + automated contract script

---

## Executive Summary

Watch underwater hardware interaction (Digital Crown vertical paging clamp, blocked-navigation toast, context-aware primary action router, App Intent safety gates) is **software-complete and safety-coherent** at `451f8fb`. All policy logic is unit-tested. **Physical QA under Water Lock, real Crown paging, and Action Button assignment remains PENDING_PHYSICAL** — simulator/static evidence cannot close hardware readiness.

| Gate | Verdict |
|------|---------|
| `DIGITAL_CROWN_UNDERWATER_PAGE_POLICY` | **PASS** (software) / **PENDING_PHYSICAL** (Water Lock) |
| `ACTION_BUTTON_UNDERWATER_PRIMARY_ACTION` | **PASS** (software) / **PENDING_PHYSICAL** (Ultra AB) |
| `WATCH_UNDERWATER_HARDWARE_INTERACTION_AUDIT` | **PARTIAL** |

---

## Scope Inspected

| File | Role |
|------|------|
| `Utils/WatchUnderwaterPagePolicy.swift` | Allowed pages during active session by activity |
| `Utils/WatchUnderwaterNavigationClampPolicy.swift` | Clamp forbidden pages → Live + toast keys |
| `Services/WatchUnderwaterActionRouter.swift` | Context-aware primary action execution |
| `Views/WatchUnderwaterPrimaryActionHintView.swift` | In-session hardware hint overlay |
| `Services/ActionButtonIntents.swift` | `ExecuteUnderwaterPrimaryActionIntent`, legacy intent safety |
| `Views/ContentView.swift` | Crown TabView, clamp onChange, toasts, hint overlays |
| `Services/AppNavigationStore.swift` | Blocked navigation + hardware action toasts |
| `Tests/WatchAlgorithmTests/WatchUnderwaterPagePolicyTests.swift` | Page policy unit tests |
| `Tests/WatchAlgorithmTests/WatchUnderwaterNavigationClampPolicyTests.swift` | Clamp unit tests |
| `Tests/WatchAlgorithmTests/WatchUnderwaterActionRouterTests.swift` | Router unit tests (15 tests) |

---

## Digital Crown Underwater Page Policy

### Observed behavior (@ `451f8fb`)

- **Pre-session:** Normal activity page policy via `WatchActivityPagePolicy`.
- **Active Diving:** `.live`, `.compass`, `.userImages` (only if `hasUserImages`).
- **Active Apnea / Snorkeling:** `.live` only.
- **Forbidden pages** (Settings, Logbook, mode selection, Compass for Apnea/Snorkeling): clamped to `.live` with per-activity toast via `WatchUnderwaterNavigationClampPolicy.blockedMessageKey`.
- **Crown hint:** Shown only on Live when no session active (`ContentView` crown hint overlay).

### Expected vs observed

| Requirement | Result |
|-------------|--------|
| Diving active + Settings → Live + toast | PASS (software) |
| Diving active + Logbook → Live + toast | PASS (software) |
| Diving active + no images + User Images → Live + toast | PASS (software) |
| Apnea active + Compass → Live + toast | PASS (software) |
| Snorkeling active + Settings → Live + toast | PASS (software) |
| Water Lock + real Crown underwater | **PENDING_PHYSICAL** |

---

## Action Button / Underwater Primary Action Router

### Observed behavior

- `WatchUnderwaterActionResolver` priority: alarm warning → Apnea operational overlay → page-specific action.
- **Live (Diving):** stopwatch start/stop unless `stopwatchHiddenByFullComputer`.
- **Compass (Diving):** set/update bearing (never clear underwater).
- **User Images (Diving):** next image when inventory exists.
- **Settings / default:** return to dashboard (Live) without mutating settings.
- **Unavailable:** toast + warning haptic; throws `WatchUnderwaterActionRouterError.unavailable`.
- `ExecuteUnderwaterPrimaryActionIntent` requires legal acceptance and routes exclusively through `WatchUnderwaterActionRouter`.
- Legacy intents (`ToggleStopwatchIntent`, etc.) delegate to `WatchIntentSafetyPolicy.routePrimaryActionIfUnderwaterSession()` when session active.

### Safety gates verified

- No hidden dive start via underwater primary action.
- No stopwatch reset via primary action path.
- Full Computer hidden stopwatch → unavailable (not silent no-op).
- Side button / Crown press unsupported assumptions **not claimed** in UI copy.

### Physical gaps

| Item | Status |
|------|--------|
| Ultra Action Button + Water Lock | **PENDING_PHYSICAL_ACTION_BUTTON_QA** |
| Toast/haptic visibility under Water Lock | **PENDING_PHYSICAL** |
| Shortcut assignment documentation | PASS — `DIRDivingAppShortcuts` + Settings help copy |

---

## Accessibility & Localization

- `Scripts/audit_accessibility_contracts.sh` — **PASS** @ `451f8fb` (underwater + water auto-open keys EN/IT).
- Blocked navigation accessibility keys per activity present.

---

## Findings

| ID | Sev | Title | Status |
|----|-----|-------|--------|
| MUIUX-P1-002 | P1 | Underwater Crown/Action Button physical QA pending | OPEN — PENDING_PHYSICAL |
| MUIUX-P2-004 | P2 | Watch test runner bootstrap failure this audit session | OPEN — NOT_EXECUTED this run |

No open **software P0** underwater hardware findings.

---

## Final Verdict Block

```text
WATCH_UNDERWATER_HARDWARE_INTERACTION_AUDIT: PARTIAL
DIGITAL_CROWN_UNDERWATER_PAGE_POLICY: PASS
ACTION_BUTTON_UNDERWATER_PRIMARY_ACTION: PASS
WATER_LOCK_PHYSICAL_QA: PENDING_PHYSICAL
PHYSICAL_WATCH_UI_QA: PENDING_PHYSICAL
```

Matrix: `Docs/MASTER_WATCH_UNDERWATER_HARDWARE_INTERACTION_MATRIX_CURRENT.csv`
