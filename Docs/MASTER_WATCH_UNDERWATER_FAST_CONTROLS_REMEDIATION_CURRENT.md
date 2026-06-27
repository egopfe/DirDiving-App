# Master Watch Underwater Fast Controls — Remediation Current

**Date:** 2026-06-27

## Changes

- Added `WatchIntentSafetyPolicy` — legacy intents route or block during active sessions
- Added `WatchUnderwaterNavigationClampPolicy` — testable crown clamp + per-activity toast keys
- Updated `ActionButtonIntents` — **Underwater Primary Action** listed first; toggle/set bearing route through router when active
- Updated help copy EN/IT + Settings shortcut help panels
- Added tests: `WatchIntentSafetyPolicyTests`, `WatchUnderwaterNavigationClampPolicyTests`, updated routing tests

## Software readiness

**100%** — routing, copy, tests, scripts

## Physical gates

| Gate | Status |
|------|--------|
| WATER_LOCK_PHYSICAL_QA | PENDING_PHYSICAL |
| ACTION_BUTTON_PHYSICAL_QA | PENDING_PHYSICAL |
| DIGITAL_CROWN_PHYSICAL_QA | PENDING_PHYSICAL |
