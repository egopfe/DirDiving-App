# Master Audit Rerun Plan — Current

**Orchestrator:** V1.2 @ `7dfefe2`  
**Date:** 2026-06-28  
**Policy:** Rerun upstream master audits after each remediation batch that touches their scope. **Do not launch 01–04 by filename until CONS-001 repaired** — use OOLD/V1.2 body sources or post-repair files.

| Remediation batch | Audits to rerun | Rationale |
|-------------------|-----------------|-----------|
| **Batch 0** — Baseline | **05** (snapshot) | Establish clean build/test banner @ HEAD |
| **Batch 1** — Watch FC safety | **01**, **03**, **04**, **05** | Oracle, altitude, deco UI, timing, release gates |
| **Batch 2** — Sync/persistence | **02**, **04**, **05**, **06** | Data integrity, paired sync, docs |
| **Batch 3** — Activity architecture | **02**, **03**, **04**, **06** | Settings/logbook ownership + UI |
| **Batch 4** — iOS planner / GF | **02**, **03**, **04**, **05** | GF import parity, planner UI truthfulness |
| **Batch 5** — Performance | **01**, **02**, **03**, **04** | Stale async, charts, planner lifecycle |
| **Batch 6** — UI/UX / WAO / a11y | **03**, **05**, **06** | Water auto-open, Crown, visual, accessibility |
| **Batch 7** — Security / depth | **04**, **05**, **06** | Shallow signing, entitlements, threat model |
| **Batch 8** — QA/evidence | **01**, **02**, **03**, **04**, **05** | Physical/external evidence refresh; WAO/HW/shallow gates |
| **Batch 9** — Release/docs | **05**, **06**, **00** | Legal, INDEX, command repair, full re-orchestration |

---

## Full Computer rule

Any batch touching Watch FC runtime, altitude, CMAltimeter, tissue, deco schedule, or GF presets must rerun **01** before external release claims.

---

## June 2026 wave reruns

| Wave feature | Minimum reruns after software change |
|--------------|--------------------------------------|
| Water auto-open | **03**, **04**, **05** |
| Crown / Action Button | **03**, **05** |
| Shallow depth / dev toggles | **01**, **04**, **05**, **07** (Batch 7) |
| GF presets | **01**, **02**, **04**, **05** |

---

## After physical QA campaigns

Rerun **01**, **03**, **05**; update `MASTER_UNRESOLVED_PHYSICAL_EXTERNAL_QA_REGISTER_CURRENT.csv`; preserve `SOFTWARE_READY` vs `PENDING_PHYSICAL` columns.

Matrices to refresh:

- `MASTER_WATER_AUTO_OPEN_PHYSICAL_QA_GATE_CURRENT.csv`
- `MASTER_WATCH_HARDWARE_CONTROLS_QA_GATE_CURRENT.csv`
- `MASTER_SHALLOW_DEPTH_RELEASE_GATE_MATRIX_CURRENT.csv`
- `MASTER_WATCH_FULL_COMPUTER_PHYSICAL_QA_MATRIX_CURRENT.csv`

---

## After external validation

Rerun **01**, **02**, **05**; attach evidence under `Docs/QA_EVIDENCE/BUHLMANN_EXTERNAL/`, `SUBSURFACE_EXTERNAL/`, GF preset compare artifacts.

---

## After CONS-001 command repair

Rerun **00** orchestrator V1.2, then **06** documentation alignment; optionally re-execute **01**–**04** in launch order to regenerate upstream MASTER outputs @ new HEAD.

---

## Consolidated plan refresh

After **Batch 9** or any release-gate closure: rerun **00** to regenerate all 12 orchestrator consolidation deliverables.
