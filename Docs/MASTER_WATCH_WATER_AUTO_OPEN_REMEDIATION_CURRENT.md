# Master Watch Water Auto-Open — Remediation Current

**Date:** 2026-06-27

## P1-WAO-001 resolution

**Status:** `SAFE_TRUTHFUL_LIMITATION_WITH_TESTS`

Normal app-icon cold launch does **not** apply water auto-open routing (no OS submersion callback faked). Water routing applies only via:

1. `OpenWaterAutoLaunchModeIntent` (App Shortcut)
2. **Apply route now** button in Water Auto-Open Settings
3. Future watchOS system Auto-Launch hook (when available)

`WatchLaunchRoutingPolicy` + `beginInitialLaunch(entry:)` enforce separation.

## P1-WAO-002 resolution

**Status:** `FIXED_COPY`

Added `settings.water_auto_open.cold_launch_limitation` EN/IT in Settings UI.

## Software readiness

**100%**

## Physical gates

| Gate | Status |
|------|--------|
| WATCHOS_SYSTEM_AUTO_LAUNCH_LISTING_EVIDENCE | PENDING_PHYSICAL |
| PENDING_PHYSICAL_WATER_AUTO_OPEN_QA | PENDING_PHYSICAL |
