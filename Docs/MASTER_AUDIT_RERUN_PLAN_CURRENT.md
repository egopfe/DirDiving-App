# Master Audit Rerun Plan — Current

**Orchestrator:** V1.3 @ `451f8fb`  
**Remediation baseline:** `5d757cc` · **Snorkeling wave:** `dbe5d8b`–`70cf0d9` · **Date:** 2026-06-30  
**Policy:** Rerun upstream master audits after remediation batches and major feature waves.

---

## Completed reruns (@ 451f8fb · 2026-06-30)

| Audit | Status | Notes |
|-------|--------|-------|
| **01** Watch FC | **COMPLETE** | 0 P0; CONS-002/006/007/008 verified |
| **02** iOS | **COMPLETE** | IOS-P1-001 test compile regression |
| **03** UI/UX | **COMPLETE** | 0 software P0 |
| **04** Main | **COMPLETE** | CONS-046 script FAIL |
| **05** Release/QA | **COMPLETE** | Physical 0% |
| **06** Documentation | **COMPLETE** | Command parity PASS |
| **07** Post-remediation | **COMPLETE** | PARTIAL verdict |
| **00** Orchestrator | **COMPLETE** | This consolidation |

**CONS-047 CLOSED** — upstream audits current @ HEAD.

---

## Next reruns (after remediation)

| Trigger | Rerun |
|---------|-------|
| Fix IOS-P1-001 (CONS-049) | 02, 05, 07 |
| Fix CONS-046 script | 06, 07 |
| Physical QA Batch-8 | 01, 03, 05, 07 |
| Any FC algorithm change | 01, 04, 05, 07 |

---

## Script fix batch (BLOCKING — CONS-046)

Before relying on CI/orchestrator preflight:

```bash
# Update Scripts/validate_commands_for_cursor_integrity.sh to:
# 01 → V2.2, 02 → V1.2, 03 → V2.3, 04 → V1.2, 05 → V1.2, 06 → V1.2
# Optionally add 00 V1.3 and 07 V1.0 presence checks
./Scripts/validate_commands_for_cursor_integrity.sh  # must PASS
```

Pair with **06** documentation rerun to refresh `MASTER_COMMAND_VERSION_ALIGNMENT_MATRIX_CURRENT.csv`.

---

## Post-remediation reruns (COMPLETE but superseded by Snorkeling)

| Audit | Prior status | Notes |
|-------|--------------|-------|
| **01–06** @ `5d757cc`–`4d415c0` | COMPLETE (2026-06-29) | Valid for pre-Snorkeling baseline; **STALE** after `dbe5d8b` |
| Command 10 remediation | COMPLETE @ `5d757cc` | CONS-001..045 software actionable closed |

---

## Remediation batch → audit mapping (future changes)

| Remediation batch | Audits to rerun | Rationale |
|-------------------|-----------------|-----------|
| **Script fix** | **06**, **00**, **07** | CONS-046 integrity gate |
| **Snorkeling follow-up** | **01**, **02**, **03**, **04**, **05** | Route safety, Watch runtime, QA templates |
| **Batch 8 physical** | **01**, **03**, **05** + Snorkeling QA folders | Signed evidence |
| **Batch 8 external** | **01**, **02**, **05** | Bühlmann, GF, Subsurface |
| **Batch 9 legal/docs** | **05**, **06**, **00** | Release packaging |

---

## Snorkeling P1/P2/P3 wave (@ dbe5d8b)

Software delivered (route safety, Watch runtime, shared helpers, 14 test files). Physical QA **12 templates PENDING** — do not claim PASS.

Rerun priority after script fix:

1. **04** — sync/activity isolation for Snorkeling route packages  
2. **02** — iOS planner and export surfaces  
3. **03** — UI/UX parity and navigation  
4. **05** — QA evidence and release gates (CONS-048)  
5. **01** — Watch cross-domain regression  
6. **06** — docs/command alignment  

---

## Full Computer rule

Any batch touching Watch FC runtime, altitude, CMAltimeter, tissue, deco schedule, or GF presets must rerun **01** before external release claims. Snorkeling Watch runtime changes require **01** isolation check even though not FC math.

---

## Consolidated plan refresh

After 01–06 reruns post-Snorkeling or Batch 8 evidence: rerun **00** V1.3 and **07**.

**Last refresh:** orchestrator **00** V1.3 @ `bb204f5` · 2026-06-30
