# Bühlmann External Validation Evidence — DIR DIVING iOS MAIN

**Status:** **PENDING** — no external sign-off recorded  
**Product stance:** DIR DIVING Bühlmann planner is **reference-only**, not certified decompression software.  
**Baseline audit:** `Docs/1-DIR_DIVING_IOS_BUHLMANN_COMPREHENSIVE_READINESS_AUDIT_CCR_CURRENT.md` @ `cc4d783`  
**Related plan:** [`DIR_DIVING_IOS_BUHLMANN_EXTERNAL_VALIDATION_PLAN.md`](DIR_DIVING_IOS_BUHLMANN_EXTERNAL_VALIDATION_PLAN.md)  
**Fixtures template:** [`BUHLMANN_EXTERNAL_VALIDATION_FIXTURES_TEMPLATE.md`](BUHLMANN_EXTERNAL_VALIDATION_FIXTURES_TEMPLATE.md)

---

## Execution instructions

1. Build DIR DIVING iOS from tagged commit; record build + commit in each row.
2. Enter identical inputs in DIR DIVING and external reference tool (Multideco, V-Planner, Subsurface planner export, published tables — cite source).
3. Capture DIR DIVING screenshots/PDF and reference tool output.
4. Compare stop depths, stop times, TTS, CNS/OTU within tolerance.
5. Fill **Observed** and **Pass/Fail** only after comparison — leave **PENDING** until then.
6. Store evidence under `Docs/QA_EVIDENCE/BUHLMANN_EXTERNAL/<profile-id>/`.

**CCR profiles:** compare OC Bühlmann only in this document. CCR validation uses [`CCR_REBREATHER_VALIDATION_EVIDENCE.md`](CCR_REBREATHER_VALIDATION_EVIDENCE.md).

---

## Validation matrix

| ID | Profile | DIR Diving input summary | Reference source | Expected stops | Expected TTS | Tolerance | Observed DIR Diving | Delta | Pass/Fail | Evidence path | Reviewer / date |
|---|---|---|---|---|---|---|---|---|---|---|---|
| BM-01 | No-deco air recreational | Base, 18 m, 40 min, Air, GF 30/85, sea level | _TBD_ | NDL / no stops | _TBD_ | TTS ±2 min; stops ±3 m | **PENDING** | — | **PENDING** | `Docs/QA_EVIDENCE/BUHLMANN_EXTERNAL/BM-01/` | |
| BM-02 | Nitrox no-deco | Base, 30 m, 25 min, EAN32, GF 30/85 | _TBD_ | | | same | **PENDING** | — | **PENDING** | `BM-02/` | |
| BM-03 | Air decompression | Deco, 40 m, 20 min, Air + EAN50 @ 21 m, GF 30/70 | _TBD_ | | | stops ±3 m, time ±2 min | **PENDING** | — | **PENDING** | `BM-03/` | |
| BM-04 | Trimix technical | Technical, 60 m, 15 min, TX 18/45 + deco gases, GF 30/70 | _TBD_ | | | same | **PENDING** | — | **PENDING** | `BM-04/` | |
| BM-05 | Multigas EAN50 + O2 | Technical, 45 m, 18 min, back TX + EAN50 + O2 @ 6 m | _TBD_ | | | same | **PENDING** | — | **PENDING** | `BM-05/` | |
| BM-06 | Altitude / freshwater | Deco, altitude 1000 m, freshwater if supported | _TBD_ | | | same | **PENDING** | — | **PENDING** | `BM-06/` | |
| BM-07 | Repetitive dive (if supported) | Surface interval + second dive per app capability | _TBD_ | | | same | **PENDING** | — | **PENDING** | `BM-07/` | |

---

## Release gate

External Bühlmann validation must show **PASS** on all mandatory rows (BM-01…BM-05 minimum) before **external TestFlight** or **App Store** algorithm sign-off.

Until then:

| Gate | Status |
|---|---|
| Internal TestFlight (algorithm) | Conditional — internal tests green |
| External TestFlight | **BLOCKED** |
| App Store (algorithm) | **BLOCKED** |

---

*Do not mark PASS without attached evidence.*
