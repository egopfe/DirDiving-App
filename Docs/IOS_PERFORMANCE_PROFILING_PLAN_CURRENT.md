# iOS Performance Profiling Plan — Current

**Branch:** `main`  
**Audit date:** 2026-06-22  
**Status:** Plan only — **no Instruments sessions executed in this audit**

---

## Instruments templates

| Template | Purpose |
|----------|---------|
| Time Profiler | Main-thread stalls, planner, startup, map |
| Allocations | Memory peaks during export, logbook load, charts |
| Leaks | Navigation retain cycles, Combine subscriptions |
| SwiftUI Body Updates | Settings mode switch, planner bindings (Xcode 15+) |
| Points of Interest | `DIRPerformanceSignpost` intervals |
| Energy Log | Background/foreground sync behavior |
| Network | WatchConnectivity message bursts |
| File Activity | Logbook persist, export temp files |
| Main Thread Checker | Sync I/O on main during startup |

---

## Devices

| Device | Role |
|--------|------|
| iPhone 15 Pro (physical) | Primary reference |
| iPhone 14 or SE 3 (physical) | Minimum supported class |
| iPhone 17 Pro (simulator) | CI parity / regression |
| Paired Apple Watch | Sync burst scenarios |

---

## Scenarios (ordered)

### 1. Cold start
- Kill app → launch → measure to legal gate OR activity selection OR Diving dashboard interactive
- Record: coordinator init, DiveLogStore load, CloudSync synchronize, WatchSync activate
- Signposts: add `ios_startup_coordinator_init` (recommended)

### 2. Settings mode switch × 50
- Diving tab → Settings → switch Diving → Apnea → Snorkeling repeatedly
- Record: bundle creation, body invalidation, scroll performance
- Compare before/after lazy env injection remediation

### 3. Diving planner rapid edit
- Open planner → change depth/runtime/gas 100 times
- Record: debounce window, main-thread blocking, solve count
- Use Points of Interest on `ios_planner_calc`

### 4. Tissue + profile charts
- Open long deco plan result → tissue analytics tab
- Record: `tissue_analytics_gen` (once instrumented), chart layout time

### 5. Logbook at cap
- Load logbook with 40 dive sessions (max cap)
- Apnea/Snorkeling lists with 80 sessions
- Record: first paint, scroll FPS

### 6. Export / import
- Export PDF planner briefing
- Import 10 MB CSV (bounded)
- Cancel mid-export (once cancellation implemented)

### 7. Snorkeling map
- Session with 10k and 50k GPS points
- Dashboard preview + session detail
- Record: MapPolyline build, coordinate array allocations

### 8. Sync burst
- Queue 40 dive sessions to Watch
- Process 100 inbound messages (simulated)
- Record: flush duration, decode on main thread

### 9. Background / foreground
- 20 cycles with pending sync queue
- Energy Log — verify no runaway timers

---

## Acceptance criteria (physical)

| Scenario | Pass threshold |
|----------|----------------|
| Cold start first interactive | < 2.0 s iPhone 14 class |
| Planner slider response | No stall > 100 ms after debounce |
| Settings mode switch | No visible freeze > 200 ms |
| Map 10k preview | Scroll/zoom remains responsive |
| Export PDF | Completes or shows progress; no jetsam |

---

## Deliverables from profiling run

1. `.trace` files archived under `Docs/evidence/ios-performance/` (future remediation command)
2. Update `IOS_PERFORMANCE_BUDGET_MATRIX_CURRENT.csv` Current_Result column
3. Close or downgrade findings in `IOS_PERFORMANCE_FINDING_TRACEABILITY_CURRENT.csv`
4. Update readiness scores in audit report

**PHYSICAL_INSTRUMENTS_PROFILING: PENDING**
