# Physical Performance QA Plan (Current)

**Command:** 10 — Performance/Concurrency/Battery Audit V3.0  
**Date:** 2026-06-20  
**Branch:** `main` @ `8cd51d6`  
**Purpose:** Separate **simulator/software** evidence from **physical Watch/iPhone** performance validation.

Do not record simulator XCTest passes as battery or thermal proof.

---

## Prerequisites

| Item | Requirement |
|------|-------------|
| Watch | Apple Watch Ultra (preferred) or Series 9+; watchOS matching `main` build |
| iPhone | Paired companion; iOS 17+ |
| Tools | Xcode Instruments (Energy Log, Time Profiler, Allocations) optional |
| Builds | TestFlight or development MAIN builds from `main` |
| Environment | Real water not required for battery desk tests; GPS tests need outdoor or simulated route |

---

## Watch — battery & thermal

### PERF-QA-W-01 — Long Full Computer dive (simulated depth)

| Field | Value |
|-------|--------|
| Activity | Diving / Full Computer |
| Duration | ≥2 h continuous (extend to 4 h if stable) |
| Setup | TestFlight simulation depth **or** pool with submersion; acknowledge simulation disclosure |
| Measure | % battery start/end; watch warm to touch (Y/N); UI responsiveness at T+120 min |
| Pass | ≤15%/h drain desk sim (informational); no watchdog kill; UI updates ≤1 s lag |
| Fail | Thermal shutdown, crash, frozen UI, runaway CPU (subjectively >1 s chart/tissue freeze) |

### PERF-QA-W-02 — Gauge-only dive control

| Field | Value |
|-------|--------|
| Activity | Diving / Gauge |
| Duration | 60 min |
| Measure | Battery delta vs PERF-QA-W-01 |
| Pass | Lower drain than Full Computer; GPS only if enabled |

### PERF-QA-W-03 — Apnea multi-dive session

| Field | Value |
|-------|--------|
| Activity | Apnea |
| Duration | 90 min with ≥6 dives |
| Measure | Tick responsiveness; checkpoint recovery after force quit |
| Pass | Recovery restores session; no duplicate haptic storms |

### PERF-QA-W-04 — Snorkeling GPS track session

| Field | Value |
|-------|--------|
| Activity | Snorkeling |
| Duration | 45 min outdoor walk/swim |
| Measure | Track point count; map smoothness; battery/h |
| Pass | Track renders without OOM; ≤20% battery for 45 min (informational) |

---

## Watch — concurrency & sync

### PERF-QA-W-05 — Pending queue flush under reachability toggling

| Field | Value |
|-------|--------|
| Setup | 10 dive sessions queued Watch→iPhone; toggle airplane mode / Bluetooth |
| Measure | Pending count drains; no duplicate imports |
| Pass | All sessions imported once; file-backed queue survives relaunch |

### PERF-QA-W-06 — Large payload file transfer

| Field | Value |
|-------|--------|
| Setup | Dive profile >512 KB (if reproducible) |
| Measure | File transfer fallback completes; hash verified |
| Pass | Session intact on iPhone; Watch pending cleared after signed ACK |

---

## iOS — planner & logbook

### PERF-QA-I-01 — Planner rapid edit stress

| Field | Value |
|-------|--------|
| Setup | OC planner; change depth/GF/cylinders rapidly for 2 min |
| Measure | UI jank; time to stable plan label |
| Pass | Debounce prevents freeze; final plan matches last edit |

### PERF-QA-I-02 — Large logbook scroll

| Field | Value |
|-------|--------|
| Setup | Import or synthesize ≥200 dive sessions |
| Measure | Scroll FPS subjectively; memory in Instruments |
| Pass | No crash; scroll remains usable |

### PERF-QA-I-03 — CSV export/import round trip

| Field | Value |
|-------|--------|
| Setup | Largest supported CSV (~10 MB boundary) |
| Measure | Import time; memory peak |
| Pass | Rejects >cap with localized error; imports valid file <30 s on target device |

---

## Paired-device matrix

| Case | Watch | iPhone | Pass criteria |
|------|-------|--------|---------------|
| Sequential tri-activity day | Diving AM, Apnea PM, Snorkeling eve | Companion | No cross-activity logbook bleed; sync latency <2 min per activity |
| Trust reset mid-sync | Reset trust during pending queue | Reset trust | Queues reconcile without corruption |
| Background transition | Dive active; wrist down 5 min | Locked | Draft recovery on resume |

---

## Evidence recording template

For each case record:

```
Case ID:
Date:
Build (SHA):
Devices:
Simulator/Physical: Physical
Battery start/end (%):
Thermal notes:
Instruments trace path (optional):
Pass/Fail:
Anomalies:
```

Store evidence under `Docs/evidence/performance/` (create at QA time; not required for software gate).

---

## Gate mapping

| Software gate | Physical gate |
|---------------|---------------|
| PERF-W-01…17 simulator PASS | PERF-QA-W-01…06 required for battery/field claims |
| PERF-I-01…09 simulator PASS | PERF-QA-I-01…03 required for large-data UX |
| CONC-* MITIGATED in code | PERF-QA-W-05…06 paired concurrency |

---

## Status

All cases **PENDING** — no physical evidence recorded in Command 10 audit pass.
