# Watch Live Decompression External Validation Plan — Current

**Audit:** Command 15 — Live Bühlmann / Schreiner / Multilevel  
**Date:** 2026-06-21  
**Branch:** `main` @ `1fe4a67`  
**Status:** **PLANNED** — no external or physical evidence collected in this audit

---

## Objective

Independently confirm that DIR Diving Watch Full Computer live decompression output matches established decompression models under documented assumptions, and validate real-world behavior on Apple Watch Ultra hardware. This plan does **not** claim EN 13319, medical, or dive-computer certification.

---

## Scope

| In scope | Out of scope |
|---|---|
| Live Full Computer tissue loading (ZH-L16C) | Gauge mode |
| Schreiner linear segments + Haldane constant depth | Apnea / Snorkeling |
| GF 30/70 default; configurable GF | iOS Planner UI (reference only) |
| Air and multigas profiles as configured in app | CCR / rebreather |

---

## Reference implementations and tools

| Tool / reference | Role | Notes |
|---|---|---|
| In-repo `IndependentBuhlmannOracle` | Primary software oracle | Already used in Audit-15 tests |
| Subsurface libdivecomputer / Bühlmann reference | Secondary constant verification | Compare ZH-L16C tables only |
| MultiDeco / V-Planner / GAP (manual) | TTS / stop schedule spot checks | Document GF, ascent rate, stop spacing |
| Hand calculations | Spot checks compartments 1, 4, 8 at selected timestamps | Schreiner closed form |

**Rule:** Normalize assumptions before judging any external delta (water vapour, surface pressure, GF interpolation, stop increment, ascent rate).

---

## Shared configuration profile (ML-01 canonical)

Export format: CSV (see `Docs/WATCH_AUDIT15_AIR39_PROFILE_CURRENT.csv`)

| Parameter | Value |
|---|---|
| Gas | Air (21% O₂, 79% N₂) |
| GF Low / High | 30 / 70 |
| Environment | Sea-level salt water (1025 kg/m³, 1.01325 bar surface) |
| Descent rate | 18 m/min to 39 m |
| Bottom | Until mandatory decompression |
| Ascent rate | 9 m/min to 10 m |
| Level | 600 s at 10 m |
| Tissue update | 1 Hz equivalent (per-second depth timeline) |

Extended profiles for future runs: ML-02 (EAN50 @21 m), ML-03 (trimix), ML-04 (sawtooth), ML-05 (re-descent) — see Command 15 Phase 9.

---

## Comparison fields

Per timestamp (1 Hz or decimated):

- Depth (m), ambient pressure (bar)
- Active gas fractions
- 16 × N₂ tissue pressure (bar)
- 16 × He tissue pressure (bar)
- Raw ceiling (m), operational ceiling (m)
- Controlling compartment (1-based)
- NDL (min), TTS (min), stop list
- Deco state (ndl / deco)

---

## Tolerated differences

| Field | Software tolerance | External tolerance (initial) |
|---|---:|---:|
| Tissue pressure | ±0.0002 bar | ±0.001 bar (tool rounding) |
| Ceiling | ±0.2 m | ±0.5 m (GF / stop rounding) |
| TTS | ±3 min | ±5 min (simulation step differences) |
| Controlling compartment | Must match if ceilings within 0.05 m | Same |

Discrepancies beyond tolerance → triage:

1. Confirm identical constants (ZH-L16C table)
2. Confirm pressure model (salt water, vapour pressure)
3. Confirm GF interpolation anchor (first stop vs current depth)
4. Confirm ascent rate and stop spacing (3 m)
5. Confirm gas switch ordering if multigas

---

## Validation phases

### Phase A — Simulator replay (software)

| Step | Action | Owner | Status |
|---|---|---|---|
| A1 | Run `Audit15Air39MultilevelProfileTests` + full Watch Algorithm Tests | CI / dev | **DONE** (51/51 selective PASS 2026-06-21) |
| A2 | Export production timeline CSV from test recorder | Dev | **PENDING** |
| A3 | Replay CSV through external tool with matched config | Independent reviewer | **PENDING** |

### Phase B — Paired logging (dry)

| Step | Action | Status |
|---|---|---|
| B1 | Log `FullComputerRuntimeSnapshot` + tissue vector at 1 Hz during simulated dive | **PENDING** |
| B2 | Compare log to oracle offline | **PENDING** |
| B3 | Verify no false deco clear events in log | **PENDING** |

### Phase C — Physical Apple Watch Ultra

| Step | Action | Status |
|---|---|---|
| C1 | Depth entitlement smoke (submersion API) | **PENDING** |
| C2 | Shallow pool profile 0–10 m with timestamped log | **PENDING** |
| C3 | Confirm 1 Hz tick under water + Mission Mode | **PENDING** |
| C4 | Confirm degraded state on missed samples (if injectable) | **PENDING** |

### Phase D — Controlled pressure (optional)

| Step | Action | Status |
|---|---|---|
| D1 | Pressure pot / chamber profile matching ML-01 segments | **PENDING** |
| D2 | Compare logged tissues to oracle at hold points | **PENDING** |

---

## Safety governance

- No external validation result may override a failing independent oracle test.
- Physical tests require dedicated dive safety officer and abort criteria.
- Simulation / mock depth must be visibly marked in UI (existing `SensorSourceMode` policy).
- Independent reviewer sign-off required before raising **External TestFlight** readiness for Full Computer decompression claims.

---

## Deliverables checklist

- [ ] ML-01 external tool comparison report (assumptions table + delta CSV)
- [ ] Ultra hardware tick log (≥30 min simulated or shallow dive)
- [ ] Signed reviewer checklist
- [ ] Update `Docs/WATCH_LIVE_BUHLMANN_SCHREINER_MULTILEVEL_AUDIT_CURRENT.md` readiness matrix

---

## Related artifacts

- `Docs/WATCH_SCHREINER_TEST_VECTOR_MATRIX_CURRENT.csv`
- `Docs/WATCH_MULTILEVEL_DECO_TRANSITION_MATRIX_CURRENT.csv`
- `Docs/WATCH_BUHLMANN_NUMERICAL_ERROR_BUDGET_CURRENT.md`
- `Docs/WATCH_AUDIT15_AIR39_PROFILE_CURRENT.csv`
- `Docs/WATCH_AUDIT15_REDESCENT_PROFILE_CURRENT.csv`
