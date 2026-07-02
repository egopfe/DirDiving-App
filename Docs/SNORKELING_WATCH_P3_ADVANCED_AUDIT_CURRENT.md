# Snorkeling Watch P3 — Advanced Navigation & Analytics Audit

**Date:** 2026-06-17  
**Repository:** egopfe/DirDiving-App  
**Verdict:** **PARTIAL** (pre-implementation baseline)

## Micro-map feasibility

| Item | Verdict |
|------|---------|
| `DiveBearingRing` on Watch navigation/return | **CONFIRMED** |
| MapKit on Watch | **MISSING** — not used |
| Route coordinate sampling (`SnorkelingRoutePresentationSampling`) | **CONFIRMED** |
| Canvas-based compact preview | **NOT_VERIFIABLE** pre-implementation |
| GPS/heading unavailable graceful hide | **PARTIAL** — bearing ring already degrades |
| Performance budget (downsampled route) | **DEFER** until policy defined |

**Recommendation:** **IMPLEMENT** — Canvas micro-map alongside bearing ring; no MapKit.

## iOS planned vs actual

| Item | Verdict |
|------|---------|
| Session detail map overlay | **CONFIRMED** (P1) |
| Planned route distance | **MISSING** |
| Actual track distance | **PARTIAL** — statistics only |
| Route progress / off-route from `runtimeSummary` | **CONFIRMED** data exists |
| Dedicated analytics card | **MISSING** |

**Recommendation:** **IMPLEMENT**

## Waypoint reached reporting

| Item | Verdict |
|------|---------|
| Navigation engine reach detection | **CONFIRMED** |
| Persisted `.waypointReached` events | **PARTIAL** |
| iOS logbook summary | **MISSING** |
| Conservative (no invented events) | **CONFIRMED** policy requirement |

**Recommendation:** **IMPLEMENT** — persist engine events; iOS reads events only.

## Track quality analytics

| Item | Verdict |
|------|---------|
| Track point GPS quality enum | **CONFIRMED** |
| Gap detection in map presentation | **CONFIRMED** |
| Dedicated analytics card | **MISSING** |
| Measured % / longest gap | **MISSING** |

**Recommendation:** **IMPLEMENT**

## Photo marker infrastructure

| Item | Verdict |
|------|---------|
| `SnorkelingMarker.photoReferenceID` | **CONFIRMED** |
| `SnorkelingSessionPhotoAttachment` + iOS store | **CONFIRMED** |
| Logbook thumbnail display | **MISSING** |
| Watch camera capture | **MISSING** — out of scope |

**Recommendation:** **IMPLEMENT** iOS thumbnail only; no Watch camera.

## Performance / battery risks

| Risk | Assessment |
|------|------------|
| Micro-map Canvas redraw | **LOW** — static downsampled polyline |
| Extra GPS processing | **NONE** — reuses existing track/route |
| Session JSON bloat | **LOW** — photo refs are UUIDs only |

## Non-regression risk matrix

| Area | Risk | Mitigation |
|------|------|------------|
| Bearing ring replaced | Medium | Keep ring; micro-map optional adjunct |
| Fake waypoint events | High | Events from engine only |
| Diving/Apnea contamination | Low | Snorkeling-scoped files only |
| Always Location | None | No new location APIs |

## Implementation recommendation

| Feature | Decision |
|---------|----------|
| Watch micro-map | **IMPLEMENT** |
| Planned vs actual | **IMPLEMENT** |
| Waypoint reached report | **IMPLEMENT** |
| Track quality analytics | **IMPLEMENT** |
| Photo marker thumbnails | **IMPLEMENT** (iOS only) |
