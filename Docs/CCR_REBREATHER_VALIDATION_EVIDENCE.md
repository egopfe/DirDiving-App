# CCR / Rebreather External Validation Evidence — DIR DIVING iOS MAIN

**Status:** **PENDING** — all slots empty  
**Product stance:** CCR planner is **reference-only**. DIR DIVING is **not** a CCR controller and does **not** monitor live loop PPO₂.  
**Baseline audit:** `Docs/1-DIR_DIVING_IOS_BUHLMANN_COMPREHENSIVE_READINESS_AUDIT_CCR_CURRENT.md`  
**Related plan:** [`CCR_REBREATHER_VALIDATION_PLAN.md`](CCR_REBREATHER_VALIDATION_PLAN.md)  
**Limitations:** [`CCR_REBREATHER_LIMITATIONS.md`](CCR_REBREATHER_LIMITATIONS.md)

---

## Mandatory warnings (review + App Store)

- CCR planner is a **reference companion tool**, not manufacturer-approved CCR software.
- **No live loop PPO₂ monitoring** — setpoint math is planning assumption only.
- **Bailout scenarios are heuristic SAC reserve estimates**, not Bühlmann-simulated OC bailout decompression schedules.

---

## Validation matrix

| ID | Scenario | Setpoints | Switch depth | Diluent | Bailout | Expected reference | DIR Diving output | Tolerance | Pass/Fail | Evidence | Reviewer / date |
|---|---|---|---|---|---|---|---|---|---|---|---|
| CCR-01 | Constant depth profile | 0.7 / 1.3 @ 20 m | 20 m | Air | EAN32 | _TBD_ | **PENDING** | schedule ±3 m stops | **PENDING** | `Docs/QA_EVIDENCE/CCR_EXTERNAL/CCR-01/` | |
| CCR-02 | Setpoint switch low→high | 0.7 → 1.3 @ 20 m | 20 m | Air | EAN32 | _TBD_ | **PENDING** | same | **PENDING** | `CCR-02/` | |
| CCR-03 | Trimix diluent | 0.7 / 1.3 @ 20 m | 20 m | TX 21/35 | EAN32 | _TBD_ | **PENDING** | same | **PENDING** | `CCR-03/` | |
| CCR-04 | Bailout configured | 0.7 / 1.3 | 20 m | Air | EAN32 + O2 | _Heuristic SAC only_ | **PENDING** | volume order-of-magnitude | **PENDING** | `CCR-04/` | |
| CCR-05 | CNS/OTU setpoint exposure | 0.7 / 1.3 | 20 m | Air | — | _TBD_ | **PENDING** | CNS ±5% | **PENDING** | `CCR-05/` | |
| CCR-06 | Tissue / ppN₂ / END sanity | 45 m / 20 min | 20 m | TX 21/35 | — | monotonic trace | **PENDING** | qualitative | **PENDING** | `CCR-06/` | |
| CCR-07 | Bailout heuristic disclosure | any | — | — | EAN32 | UI/PDF shows heuristic | **PENDING** | text audit | **PENDING** | `CCR-07/` | |
| CCR-08 | PDF/export consistency | CCR-01 inputs | — | — | — | PDF matches on-screen | **PENDING** | field match | **PENDING** | `CCR-08/` | |

---

## Release gate

CCR external validation (CCR-01…CCR-04 minimum + CCR-07 disclosure) must be **PASS** or explicitly **WAIVED** with written rationale before external TestFlight CCR marketing.

| Gate | Status |
|---|---|
| Internal reference use | Conditional |
| External TestFlight (CCR) | **BLOCKED** until evidence |

---

*Do not mark PASS without evidence files.*
