# Master Audit Rerun Plan — Current

**Orchestrator:** V1.2 refresh @ `8ae1034`  
**Remediation baseline:** `5d757cc` · **Date:** 2026-06-29  
**Policy:** Rerun upstream master audits after remediation batches. **CONS-001 FIXED** — filename-based launch of **01–04** is trustworthy.

---

## Post-remediation reruns (COMPLETE @ 5d757cc)

| Audit | Status | Trigger | Verify |
|-------|--------|---------|--------|
| **01** Watch FC | **COMPLETE** | CONS-008 oracle; CONS-017/018/038; CONS-019 WAO | 36/36 targeted tests PASS |
| **02** iOS | **COMPLETE** | CONS-002 GF; CONS-027 PlannerStore | 15/15 targeted; 1527/1527 full iOS |
| **04** Main/Sync/Security | **COMPLETE** | CONS-003–007 | P1=0; gate scripts PASS |
| **05** Release/QA/Legal | **COMPLETE** | Full gate matrix refresh | `validate_consolidated_software_readiness.sh` PASS |
| **06** Documentation | **COMPLETE** | CONS-001 repair; CONS-034 INDEX | Command integrity PASS |
| **00** Orchestrator | **COMPLETE** @ `8ae1034` | Consolidation refresh after 01–06 | This deliverable set |

---

## Stale / optional reruns

| Audit | Status | Notes |
|-------|--------|-------|
| **03** UI/UX | **STALE_UPSTREAM_AUDIT_OUTPUT @ 7dfefe2** | Optional — no UI layout changes in remediation; software-ready WAO/Crown items still valid |

---

## Remediation batch → audit mapping (future changes)

| Remediation batch | Audits to rerun | Rationale |
|-------------------|-----------------|-----------|
| **Batch 0** | **05** (snapshot) | Build/test banner @ HEAD |
| **Batch 1** | **01**, **03**, **04**, **05** | Oracle, altitude, deco UI, release gates |
| **Batch 2** | **02**, **04**, **05**, **06** | Sync integrity, paired sync, docs |
| **Batch 3** | **02**, **03**, **04**, **06** | Settings/logbook ownership + UI |
| **Batch 4** | **02**, **03**, **04**, **05** | GF import parity, planner UI |
| **Batch 5** | **01**, **02**, **03**, **04** | Stale async, charts, planner lifecycle |
| **Batch 6** | **03**, **05**, **06** | WAO, Crown, visual, accessibility |
| **Batch 7** | **04**, **05**, **06** | Shallow signing, entitlements |
| **Batch 8** | **01**, **02**, **03**, **04**, **05** | Physical/external evidence refresh |
| **Batch 9** | **05**, **06**, **00** | Legal, INDEX, full re-orchestration |

**Software batches 0–7 (Command 10 scope): already rerun 01/02/04/05/06 @ 5d757cc.**

---

## Full Computer rule

Any future batch touching Watch FC runtime, altitude, CMAltimeter, tissue, deco schedule, or GF presets must rerun **01** before external release claims.

---

## After physical QA campaigns (NEXT)

Rerun **01**, **03** (recommended if stale), **05**; update `MASTER_UNRESOLVED_PHYSICAL_EXTERNAL_QA_REGISTER_CURRENT.csv`; preserve `SOFTWARE_READY` vs `PENDING_PHYSICAL`.

Matrices to refresh:

- `MASTER_WATER_AUTO_OPEN_PHYSICAL_QA_GATE_CURRENT.csv`
- `MASTER_WATCH_HARDWARE_CONTROLS_QA_GATE_CURRENT.csv`
- `MASTER_SHALLOW_DEPTH_RELEASE_GATE_MATRIX_CURRENT.csv`
- `MASTER_WATCH_FULL_COMPUTER_PHYSICAL_QA_MATRIX_CURRENT.csv`

---

## After external validation

Rerun **01**, **02**, **05**; attach evidence under `Docs/QA_EVIDENCE/BUHLMANN_EXTERNAL/`, `SUBSURFACE_EXTERNAL/`, GF preset compare artifacts.

---

## Consolidated plan refresh

After Batch 8 evidence milestones or Batch 9 legal closure: rerun **00** to regenerate all 12 orchestrator consolidation deliverables.

**Last refresh:** orchestrator **00** @ `8ae1034` · 2026-06-29
