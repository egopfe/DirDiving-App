# Master Watch Full Computer — External Validation Plan — CURRENT

**Audit command:** `01-MASTER_WATCH_FULL_COMPUTER_FORENSIC_AUDIT_COMMAND_V2.0.md`  
**Date:** 2026-06-28  
**Branch:** `main` @ `5d757cc` (post-remediation rerun)  
**Status:** **PLANNED** — no external tool run or physical chamber evidence collected in this audit session

---

## Objective

Independently confirm DIR Diving Apple Watch **Full Computer** live decompression output against established Bühlmann ZH-L16C models and real Apple Watch hardware behavior. This plan does **not** claim EN 13319, ISO 6425, medical, or certified dive-computer status.

---

## Reference implementations

| Tool / reference | Role | Status |
|---|---|---|
| In-repo `IndependentBuhlmannOracle` | Primary tissue + TTS/schedule oracle (Audit-15) | **EXECUTED** — ML-01..ML-10 PASS prior; independent path verified @ 5d757cc |
| Production `BuhlmannEngine.runtimeProjection` | Live FC presentation only (not oracle reference) | **EXECUTED** — oracle sweep uses independent reference (CONS-008 CLOSED) |
| Subsurface / libdivecomputer ZH-L16C tables | Constant cross-check | **PENDING_EXTERNAL_VALIDATION** |
| MultiDeco / V-Planner / GAP manual | TTS/stop spot checks | **PENDING_EXTERNAL_VALIDATION** |
| Hand Schreiner calculations | Compartments 1,4,8 at t=130,404,1004 | **EXECUTED** via SchreinerAnalyticParityTests |

**Rule:** Normalize assumptions (GF, ascent rate, stop increment, water vapour 0.0627 bar, surface pressure, salinity) before judging external deltas.

---

## Canonical profiles

| Profile | Description | Software oracle | External replay |
|---|---|---|---|
| ML-01 | Air 39 m → 10 m, GF 30/70 | PASS 0 tissue failures | CSV: `Docs/WATCH_AUDIT15_AIR39_PROFILE_CURRENT.csv` — **PENDING fill** |
| ML-02 | EAN50 @ 21 m | PASS | Scaffold exported |
| ML-03 | Trimix + deco gases | PASS | Scaffold exported |
| ML-05 | Deco clear → re-descent | PASS | Scaffold exported |
| Altitude | 500/1000/1500/2000 m import | Env propagation PASS | Full ML replay **PENDING** |

Export script: `Scripts/export_watch_live_buhlmann_replay_vectors.py`

---

## Tolerance table (release comparison)

| Quantity | Tolerance | Direction |
|---|---:|---|
| Tissue N2/He (bar) | ±0.0002 | Neutral |
| Ceiling (m) | ±0.2 | Neutral |
| NDL (min) | ±0.6 | Neutral |
| TTS (min) | ±3.0 | Conservative acceptable |

---

## Physical validation strategy

1. **Dry run:** Predive environment accept → start → verify frozen `FullComputerRuntimePlan.plannerEnvironment` in logbook metadata (PQ-015).
2. **Simulator replay:** Audit-15 tests (prior evidence @ 7dfefe2; remediation targeted tests 36/36 PASS @ 5d757cc).
3. **Paired-device logging:** Watch + iPhone sync round-trip for FC logbook environment fields (PQ-016).
4. **Controlled water / pressure pot:** Ascent warnings and depth scaling (PQ-020, PQ-022).
5. **Apple Watch Ultra underwater:** Real submersion depth API — **PENDING_PHYSICAL** only.

---

## Discrepancy triage

| Delta type | Action |
|---|---|
| Tissue > 0.0002 bar | Block — investigate Schreiner/units |
| Ceiling > 0.2 m | Check GF interpolation and rounding |
| TTS > 3 min | Check 1-min simulation quanta (MWFC-P2-003) |
| External only diverges | Document assumption mismatch before code change |

---

## Governance

- Independent reviewer sign-off required before any external decompression parity claim.
- Physical QA matrix (`MASTER_WATCH_FULL_COMPUTER_PHYSICAL_QA_MATRIX_CURRENT.csv`) must reach **EXECUTED** for release gate.
- Finding MWFC-P1-002 tracks external validation gap.

**All external rows remain `PENDING_EXTERNAL_VALIDATION` unless evidence files exist under `Docs/QA_EVIDENCE/`.**
