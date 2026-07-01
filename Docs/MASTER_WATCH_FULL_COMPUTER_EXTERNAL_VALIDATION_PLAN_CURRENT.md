# Watch Full Computer — External Validation Plan — CURRENT

**Baseline:** `main` @ `2c30412`  
**Audit date:** 2026-07-01  
**Status:** **PENDING_EXTERNAL_VALIDATION** (all items unless noted)

---

## Objectives

1. Compare Watch Full Computer Bühlmann ZH-L16C runtime against independent decompression tools.
2. Validate TTS/schedule/stop list at sea level and altitude.
3. Produce signed evidence under `Docs/QA_EVIDENCE/BUHLMANN_EXTERNAL/`.
4. Do **not** claim EN13319, ISO 6425, CE, or certified dive-computer status without official evidence.

---

## Independent Oracle (Software — COMPLETE)

| Item | Status | Evidence |
|---|---|---|
| Tissue loading oracle | PASS | `IndependentBuhlmannOracle.swift` |
| Schedule/TTS on oracle tissues | PASS | CONS-008 remediation |
| ML-01…ML-10 replay | PASS | Audit15 test suites @2c30412 (all FC tests pass; 1139/1152 Watch suite) |

---

## External Tool Comparison (PENDING)

### Tools

- **Subsurface** — Bühlmann ZH-L16C with GF; export dive profiles.
- **RatioDeco / VPM-B reference** — spot-check selected stops (document GF assumptions).
- **Pressure pot / chamber** (optional) — ambient pressure validation at altitude simulation.

### Profile CSV Format

```csv
second,depth_m,gas_name,o2_frac,he_frac,gf_low,gf_high,altitude_m,salinity_ppt
```

### Required Profiles

| Profile ID | Description | GF | Altitude |
|---|---|---|---|
| EXT-01 | Air 39m bottom → 10m level → surface | 30/70 | 0 m |
| EXT-02 | Same with EAN50 @ 21m | 30/70 | 0 m |
| EXT-03 | Trimix bottom + deco gases | 30/70 | 0 m |
| EXT-04 | Air multilevel re-descent | 30/70 | 0 m |
| EXT-05 | Air 30m NDL boundary | 30/70 | 1000 m |
| EXT-06 | GF preset triplet spot-check | 20/80 30/70 40/85 | 0 m |

### Tolerance Table (proposed)

| Metric | Tolerance | Direction |
|---|---|---|
| Tissue PN2/PHe (bar) | 0.001 | Document divergence |
| Ceiling (m) | 0.5 | Either |
| TTS (min) | 3 | Watch may read higher (1-min quanta) |
| First stop depth (m) | 3 (stop interval) | Either |

### Discrepancy Triage

1. Verify environment (surface pressure, water density, vapour pressure).
2. Verify GF interpolation anchor (first stop vs ambient).
3. Verify ascent rate and stop increment assumptions.
4. Verify gas switch timing (0.5 min Buhlmann switch).
5. Escalate to P1 if Watch reads **lower** TTS/ceiling than external tool (optimistic).

---

## Execution Phases

| Phase | Method | Status |
|---|---|---|
| 1 | Simulator CSV replay export from Audit15 recorders | NOT_EXECUTED |
| 2 | Subsurface manual profile entry + compare | PENDING_EXTERNAL_VALIDATION |
| 3 | Paired iPhone logging during dry run | PENDING_PHYSICAL |
| 4 | Controlled water / pressure pot | PENDING_PHYSICAL |
| 5 | Independent reviewer sign-off | NOT_EXECUTED |

---

## Governance

- No release claim of external parity until signed artifacts exist.
- Physical Watch sensor validation is separate gate (see PHYSICAL_QA matrix).
- Planner briefing cards and CCR metadata remain reference-only in all comparisons.

---

## Related Findings

- **MWFC-P1-001** (CONS-009) — blocks external release readiness claim.
- **CONS-043** — GF preset external spot-check pending.
