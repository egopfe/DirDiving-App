# Master Audit Rerun Plan — Current

**Orchestrator:** V1.3 @ `bb204f5`  
**Remediation baseline:** `5d757cc` · **Snorkeling wave:** `dbe5d8b`–`70cf0d9` · **Date:** 2026-06-30  
**Policy:** Rerun upstream master audits after remediation batches and major feature waves. **CONS-046 OPEN** — integrity script must be fixed before trusting automated gate.

---

## Required reruns (STALE — CONS-047)

Upstream audits **01–06** last refreshed @ `905692e` / post-remediation @ `4d415c0` (2026-06-29). **Snorkeling P1/P2/P3** landed @ `dbe5d8b` with 14 test files and 12 QA templates — **not reflected** in domain audit outputs.

| Audit | Status | Trigger | Verify |
|-------|--------|---------|--------|
| **01** Watch FC | **STALE_UPSTREAM** | Snorkeling Watch runtime; cross-domain isolation | Snorkeling isolation; no FC regression |
| **02** iOS | **STALE_UPSTREAM** | Snorkeling iOS planner, route safety, export | 14 Snorkeling iOS test suites; CONS-002 GF unchanged |
| **03** UI/UX | **STALE_UPSTREAM** | Snorkeling planner sections; Watch presentation | Route planner UX; cross-activity routing |
| **04** Main/Sync/Security | **STALE_UPSTREAM** | Snorkeling route sync codec; runtime evaluator | Activity isolation; sync namespace |
| **05** Release/QA/Legal | **STALE_UPSTREAM** | 12 Snorkeling QA templates; release gates | CONS-048 physical register; no fake PASS |
| **06** Documentation | **STALE_UPSTREAM** | Command V1.2/V2.2/V2.3 @ bb204f5; Snorkeling docs | INDEX; command version matrix; CONS-046 |
| **00** Orchestrator | **COMPLETE** @ `bb204f5` | V1.3 consolidation | This refresh |
| **07** Post-remediation | **COMPLETE** @ `bb204f5` | Orchestrator 0D consumption | 8 verification deliverables |

**Execute 01–06 in order before next external release claim.** Do not consolidate Snorkeling as generic UI-only — spans 01, 02, 03, 04, 05, 06.

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
