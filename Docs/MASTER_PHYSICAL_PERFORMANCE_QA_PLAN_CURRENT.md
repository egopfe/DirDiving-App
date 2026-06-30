# Master Physical Performance QA Plan (Current)

**Audit command:** 04 — MASTER MAIN CODE / SYNC / SECURITY / PERFORMANCE AUDIT V1.2  
**Branch:** `main` @ `451f8fb`  
**Date:** 2026-06-30

**Status:** All scenarios below are **PENDING** unless evidence file exists in `Docs/QA_EVIDENCE/`. No fabricated pass claims.

---

## A. Prerequisites

| Item | Required | Notes |
|------|----------|-------|
| Apple Watch Ultra 2 (or Series 9+) | Yes | Full Computer long-dive battery |
| Paired iPhone (iOS 18+) | Yes | WC sync + tombstone QA |
| Xcode Instruments | Yes | Energy Log, Time Profiler, Allocations |
| Subsurface reference (optional) | Recommended | Export fidelity spot-check |
| Underwater validation | **NOT IN SCOPE** | Software-only audit |

---

## B. Watch — Full Computer runtime

| Scenario ID | Description | Duration | Instruments | Pass criteria | Finding |
|-------------|-------------|----------|-------------|---------------|---------|
| PHYS-W-FC-01 | Simulated 2h Full Computer dive | 2h | Energy Log | No thermal shutdown; tick degraded ≤5% | MASTER-PERF-001 |
| PHYS-W-FC-02 | Simulated 4h multilevel profile | 4h | Time Profiler | Solver p95 ≤50ms | MASTER-PERF-001 |
| PHYS-W-FC-03 | Checkpoint restore after force quit | 15min | Manual | Tissue state restored; no reset | — |
| PHYS-W-FC-04 | Haptic storm under ascent warnings | 30min | Energy Log | No runaway haptic loop | — |

---

## C. Watch — Apnea / Snorkeling

| Scenario ID | Description | Duration | Pass criteria | Finding |
|-------------|-------------|----------|---------------|---------|
| PHYS-W-AP-01 | Apnea 1h session tick stability | 1h | No tick stall; checkpoint ≤4/min | — |
| PHYS-W-SN-01 | Snorkeling 2h GPS track | 2h | Track persist; battery acceptable | MASTER-PERF-004 |
| PHYS-W-SN-02 | 10k point route map pan/zoom | 30min | Smooth interaction | MASTER-PERF-004 |

---

## D. Paired-device sync

| Scenario ID | Description | Pass criteria | Finding |
|-------------|-------------|---------------|---------|
| PHYS-PAIR-01 | 40-session diving flush Watch→iOS | All ACK'd; no duplicate | MASTER-PERF-002 |
| PHYS-PAIR-02 | Delete tombstone propagation all activities | Remote delete within 60s | MASTER-SEC-001 |
| PHYS-PAIR-03 | Large payload (>512KB) file transfer | Session merges correctly | MASTER-SYNC-001 |
| PHYS-PAIR-04 | Low battery (<20%) sync burst | No watchdog; queue recovers | MASTER-PERF-002 |
| PHYS-PAIR-05 | Briefing card burst (10 cards) | All ACK; no path traversal | — |
| PHYS-PAIR-06 | Photo inventory 50 images | Transfer + delete ACK | — |

---

## E. iOS — performance

| Scenario ID | Description | Instruments | Pass criteria | Finding |
|-------------|-------------|-------------|---------------|---------|
| PHYS-I-01 | Cold launch to dashboard | Time Profiler | First frame <1500ms | MASTER-IOS-001 |
| PHYS-I-02 | Planner 100 rapid depth edits | Time Profiler | Main thread p95 <16ms | — |
| PHYS-I-03 | Logbook scroll at 40 sessions | Core Animation | 60fps scroll | MASTER-PERF-003 |
| PHYS-I-04 | Snorkeling map 50k points detail | Core Animation | Pan smooth | MASTER-IOS-002 |
| PHYS-I-05 | PDF export large deco plan | Allocations | Peak <250MB | — |
| PHYS-I-06 | CSV import 10MB file | Time Profiler | Complete <8s | — |

---

## F. External validation (out of scope for software audit)

| Scenario | Status |
|----------|--------|
| Bühlmann oracle vs external reference | PENDING_EXTERNAL_VALIDATION |
| CCR reference plan vs field CCR | PENDING_EXTERNAL_VALIDATION |
| Underwater depth sensor accuracy | PENDING_PHYSICAL |
| App Store privacy review | NOT_EXECUTED |

---

## G. Evidence recording

For each executed scenario, record:

```text
scenario_id
device_model
os_version
app_build (commit)
start/end timestamp
instruments_trace_path (if any)
pass/fail
notes
```

Store under `Docs/QA_EVIDENCE/` with filename `PHYS-<scenario_id>-<YYYYMMDD>.md`.

---

**Plan status:** READY FOR EXECUTION — no scenarios marked passed in this audit pass.
