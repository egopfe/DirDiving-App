# Snorkeling Watch P2 — Premium Runtime Audit

**Date:** 2026-06-17  
**Repository:** egopfe/DirDiving-App  
**Verdict:** **PARTIAL** (pre-implementation baseline)

## Return to Entry prominence

| Item | Verdict |
|------|---------|
| Return action in Watch action row | **CONFIRMED** — equal weight with NAV/MARKER |
| Primary/hero placement | **MISSING** |
| Entry unavailable disabled state | **PARTIAL** — button always enabled |

## iOS configurable operational thresholds

| Item | Verdict |
|------|---------|
| Settings model (`SnorkelingCompanionSettings`) | **PARTIAL** — return distance + duration UI only |
| Engine consumption | **MISSING** — alarms used hardcoded 7200s / 1500m |
| Watch sync via route metadata | **MISSING** |
| Off-route threshold configurable | **MISSING** — fixed 50 m default |
| GPS quality threshold configurable | **MISSING** |

## Watch route summary before start

| Item | Verdict |
|------|---------|
| Route name/status (P1) | **CONFIRMED** |
| Distance/duration compact line (P1) | **CONFIRMED** |
| Waypoint count + alert/off-route config | **MISSING** |
| No-route graceful text | **PARTIAL** |

## iOS marker logbook

| Item | Verdict |
|------|---------|
| Basic marker list | **CONFIRMED** |
| Category counts | **MISSING** |
| GPS quality + distance from entry | **MISSING** |

## Export/share track

| Item | Verdict |
|------|---------|
| GPX via `SnorkelingSessionExportEngine` | **CONFIRMED** |
| Dedicated GPX service + markers | **MISSING** |
| KML | **MISSING** |
| Session summary share text | **MISSING** |

## Non-regression risk matrix

| Risk | Level |
|------|-------|
| Cross-activity settings bleed | Low — snorkeling-scoped namespace |
| WatchConnectivity protocol break | Low — optional metadata fields |
| Off-route false positives | Medium — threshold wiring |
| Export invalid coordinates | Medium — must filter measured only |
