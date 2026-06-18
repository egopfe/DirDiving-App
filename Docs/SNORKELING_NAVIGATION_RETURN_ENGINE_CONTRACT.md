# Snorkeling Navigation & Return Engine Contract (Command 04)

**Status:** Implemented (engine) — UI not promoted  
**Date:** 2026-06-18  
**Implementation report:** [`DIR_DIVING_SNORKELING_NAVIGATION_RETURN_ENGINE_IMPLEMENTATION_REPORT_CURRENT.md`](DIR_DIVING_SNORKELING_NAVIGATION_RETURN_ENGINE_IMPLEMENTATION_REPORT_CURRENT.md)

---

## Current foundation hooks (Commands 01–03)

`SnorkelingSessionEngine` exposes phase transitions only:

- `enterNavigation(at:)`
- `enterReturnMode(at:)`
- `exitNavigationOrReturn(at:)`

These update `SnorkelingLifecyclePhase` and persisted `SnorkelingSession.state` without fabricating bearings, waypoints, or return guidance. Metrics continuity is preserved across enter/exit (verified by `SnorkelingCommand04FoundationGateTests`).

GPS quality, measured vs estimated track distinction, and surface-only measured GPS policy remain owned by `SnorkelingGPSFeed` and domain validation.

---

## Bearing (Command 04)

- Computed only from **accepted surface** GPS fixes with valid quality.
- Invalid when fixes are stale, rejected, gap-exceeded, or underwater-unavailable.
- No blind continuation after long GPS gap without explicit degraded state.
- No implied underwater GPS precision.

---

## Waypoints (Command 04)

- Versioned waypoint IDs; deterministic ordering.
- Invalid coordinates rejected; duplicates handled deterministically.
- Explicit current waypoint; no automatic completion from poor-quality fixes.
- No demo or seeded waypoints in production runtime.

---

## Return advisor (Command 04)

- **Reference-only** — no guarantee of return or rescue.
- Based on accepted geodetic surface track where available.
- Confidence/quality state visible to UI when implemented.
- Degraded or unavailable when GPS is insufficient.
- Must **not** integrate reported speed into distance.
- Must **not** fabricate underwater path.
- Must **not** change `SnorkelingSessionEngine` lifecycle ownership.

---

## Degraded GPS policy

- Underwater segments: estimated or unavailable; zero measured-distance credit (current behavior).
- Degraded accuracy: may contribute track points per current `SnorkelingGPSQuality` rules but with zero measured-distance credit where policy requires.
- Depth-only sessions: navigation/return advisor remains unavailable; lifecycle continues without GPS.

---

## Isolation

Command 04 navigation services must not reference:

- `DiveManager`, `DiveLogStore`
- `ApneaSessionEngine`, `ApneaLogbookStore`
- `FullComputerRuntimeEngine`, Full Computer plan/session stores
- `ExplorationStore` or legacy Exploration timers
- Standard dive navigation stores

All models and services remain namespaced under Snorkeling domain types.

---

## Safety wording (EN/IT when UI ships)

Must not claim: guaranteed navigation, guaranteed return, rescue capability, underwater GPS precision, medical monitoring, certified snorkeling computer, or replacement for supervision.

Required disclosures:

- GPS may be unavailable or inaccurate.
- Measured track is surface-based.
- Underwater segments may be estimated or unavailable.
- Navigation is reference-only.
- User remains responsible for route and conditions.

---

## Gate output

```text
SNORKELING_COMMAND_04_ENGINE_COMPLETE
```

Watch navigation UI and physical GPS validation remain separate future work. `SnorkelingView` is not promoted to Watch MAIN.
