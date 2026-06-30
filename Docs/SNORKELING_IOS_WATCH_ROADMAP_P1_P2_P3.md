# Snorkeling iOS + Watch — P1/P2/P3 Roadmap

**Status:** Reference roadmap — not a safety certification.  
**Scope:** Snorkeling iOS companion + Apple Watch runtime only.

## Separation of concerns

| Platform | Role |
|----------|------|
| **iOS** | Route planner, profile selection, route safety validation, checklist, export/share, send-to-Watch, logbook analytics |
| **Apple Watch** | Session runtime, GPS quality presentation, return-to-entry, next waypoint, return alerts, off-route warnings, route progress, session log |

The Watch does **not** edit full routes. It consumes a compact signed package from iOS.

## P1 — Essential

### iOS

- Return-to-entry preview (distance + bearing from current/last known position to entry)
- Estimated route distance (Haversine) and duration (profile speed)
- Route type: round trip vs different exit
- Route safety check: ready / warning / incomplete / blocked
- Pre-snorkeling checklist (6 items)
- Send to Watch gated by validation (`allowsWatchTransfer`)
- Share/export text with safety disclaimer

### Watch

- Imported route activation from iOS package
- Return-to-entry distance and bearing (when GPS reliable)
- Next waypoint distance and bearing
- GPS quality band: Good / Medium / Poor / Lost
- 50% planned time or distance return alert (haptic, once per session)

## P2 — High value

### iOS

- Route profile kinds (relax, coastal, training, photo/reef, long route) with recommended limits
- Profile-driven validation warnings (distance, duration, exit separation, waypoint spacing)
- Return alert policy selection (off / 50% time / 50% distance)

### Watch

- Route progress percentage along planned polyline
- Automatic waypoint reached within 25 m (GPS quality gated)
- Compact route summary screen (progress, next, entry, GPS)
- Logbook runtime summary includes GPS quality band

## P3 — Advanced

### Watch

- Off-route detection (default 50 m from route segments)
- Off-route haptic (once per event; paused when GPS lost/poor)
- Runtime accumulation: off-route events, max off-route distance, time off route
- Local geodesic approximation documented — not survey-grade navigation

## Out of scope

- Diving, Gauge, Full Computer, Apnea, Bühlmann, deco planner
- Background / Always location
- Fake GPS in real runtime or real logbook
- Life-saving or certified navigation claims

## Related docs

- [`SNORKELING_IOS_WATCH_ARCHITECTURE.md`](SNORKELING_IOS_WATCH_ARCHITECTURE.md)
- [`SNORKELING_ROUTE_SAFETY_CHECK.md`](SNORKELING_ROUTE_SAFETY_CHECK.md)
- [`SNORKELING_GPS_QUALITY_POLICY.md`](SNORKELING_GPS_QUALITY_POLICY.md)
- [`SNORKELING_IOS_WATCH_P1_P2_P3_IMPLEMENTATION_REPORT_CURRENT.md`](SNORKELING_IOS_WATCH_P1_P2_P3_IMPLEMENTATION_REPORT_CURRENT.md)

## Physical QA

All scenarios start **PENDING** under `Docs/QA_EVIDENCE/SNORKELING_*`. Simulator and unit tests do not replace open-water validation.
