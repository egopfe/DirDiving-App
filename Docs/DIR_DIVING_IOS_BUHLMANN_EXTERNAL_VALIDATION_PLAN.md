# DIR DIVING iOS Bühlmann External Validation Plan

**Date:** 2026-05-29  
**Scope:** iOS Companion MAIN — Bühlmann ZHL-16C N2+He multigas reference planner  
**Status:** Ready to execute (campaign not yet completed)  
**Positioning:** Non-certified planning reference — not decompression authority

---

## Objective

Independently compare DIR DIVING iOS Bühlmann reference outputs against established planning tools and published ZHL-16C GF envelopes **before** any stronger release or marketing claims.

This plan does **not** assert certified equivalence. Pass/fail is measured against documented tolerance envelopes only.

---

## Reference Sources (checklist)

| ID | Source | Role | Status |
|---|---|---|---|
| R1 | decotengu ZHL-16C GF planner (web) | TTS / stop envelope cross-check | ☐ Pending |
| R2 | Subsurface planner (desktop) | Multigas schedule sanity | ☐ Pending |
| R3 | VPlanner / MultiDeco literature envelopes | GF 30/70 vs 30/85 bands | ☐ Pending |
| R4 | Bühlmann ZHL-16C coefficient tables (published) | Constant verification | ✅ Covered by `BuhlmannConstantsTests` |
| R5 | Internal golden JSON fixtures (`Tests/iOSAlgorithmTests/Fixtures/`) | Regression envelopes | ✅ Automated XCTest |

---

## Fixture Assumptions

- **Environment:** ISA sea-level barometric (`1.01325 bar`) unless fixture specifies altitude/salinity.
- **Water density:** Salt `1025 kg/m³`, fresh `997 kg/m³`.
- **GF defaults:** Low 30 / High 70–85 unless profile specifies otherwise.
- **Gas sets:** Air (21/0), EAN32, TX18/45, EAN50 deco, O₂ deco.
- **Profile:** Square bottom, 18 m/min descent, 9 m/min ascent, 3 m stop rounding, 0.5 min switch dwell.
- **Tissue init:** Air-saturated at environment surface pressure unless repetitive fixture applies snapshot + SI.

---

## Tolerances

| Metric | Tolerance | Notes |
|---|---|---|
| NDL (no-deco) | ±1 min vs reference | Same GF High, gas, environment |
| TTS (deco) | ±3 min vs reference | GF and gas set must match |
| Stop count | ±1 stop | Depth rounding may differ by 3 m band |
| Stop depth | ±3 m | Consistent with 3 m stop grid |
| Ceiling at bottom | ±1 m | Environment-aware conversion |

Document any exceedance as **investigation required**, not automatic failure, until root cause is classified (environment mismatch, GF interpolation, switch ordering, etc.).

---

## Test Matrix (manual campaign)

| Profile | Gas | GF | Environment | NDL/TTS ref | DIR iOS | Pass? |
|---|---|---|---|---|---|---|
| 30 m / 20 min air | Air 21/0 | 30/85 | Sea salt | ☐ | ☐ | ☐ |
| 40 m / 15 min TX18/45 | TX18/45 + EAN50 | 30/70 | Sea salt | ☐ | ☐ | ☐ |
| 25 m / 25 min EAN32 | EAN32 | 40/85 | Sea salt | ☐ | ☐ | ☐ |
| 30 m air NDL only | Air | 30/85 | 1500 m salt | ☐ | ☐ | ☐ |
| 30 m air NDL only | Air | 30/85 | Sea fresh | ☐ | ☐ | ☐ |
| Repetitive 30 m + SI 45 | Air | 30/85 | Sea salt | ☐ | ☐ | ☐ |

---

## Execution Steps

1. Export identical inputs from DIR DIVING iOS planner (screenshot + manual transcription).
2. Enter same profile/gases/GF/environment in reference tool R1 or R2.
3. Record NDL, TTS, stop list, and runtime segments.
4. Compare against tolerances above.
5. Log result in this document or linked spreadsheet.
6. File regression fixture if discrepancy is reproducible and classified as engine defect.

---

## Automated Preconditions (must pass before campaign)

- `xcodebuild test` scheme **DIRDiving iOS Algorithm Tests** — all green on macOS.
- Preview NDL aligns with plan NDL for same environment (see `BuhlmannComprehensiveReadinessFixTests`).
- No legacy 1.0 bar + 10 m/bar fallback in validated Bühlmann paths when `PlannerEnvironment` is present.

---

## Out of Scope

- Apple Watch runtime decompression
- Logbook-derived tissue seeding (future enhancement)
- Certified decompression computer equivalence claims

---

## Sign-off

| Role | Name | Date | Result |
|---|---|---|---|
| Algorithm owner | ☐ | ☐ | ☐ |
| QA | ☐ | ☐ | ☐ |
| Product / safety review | ☐ | ☐ | ☐ |

**Campaign completion is a P1 process blocker for public release claims beyond “internal validation reference.”**
