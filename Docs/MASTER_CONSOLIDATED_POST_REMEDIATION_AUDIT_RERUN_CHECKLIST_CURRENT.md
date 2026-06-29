# Master Consolidated Post-Remediation Audit Rerun Checklist

**Date:** 2026-06-28  
**Remediation:** consolidated software remediation @ `main` (dirty tree after fixes)  
**Pre-remediation baseline:** `7dfefe2`  
**Report:** [`MASTER_CONSOLIDATED_SOFTWARE_REMEDIATION_TO_100_REPORT_CURRENT.md`](MASTER_CONSOLIDATED_SOFTWARE_REMEDIATION_TO_100_REPORT_CURRENT.md)

**Policy:** Read-only audit re-runs only. **CONS-001 repaired** — filename-based launch of `commands_for_cursor/01`–`04` is now trustworthy.

---

## Mandatory reruns (software remediation scope)

| # | Audit command file | Rerun status | Trigger | Verify |
|---|-------------------|--------------|---------|--------|
| 01 | `01-MASTER_WATCH_FULL_COMPUTER_FORENSIC_AUDIT_COMMAND_V2.1.md` | **Recommended — next** | CONS-008 oracle; CONS-017/018/038 tests; CONS-019 WAO gate | Independent oracle traceability; startup routing; GF import |
| 02 | `02-MASTER_IOS_FULL_DEEP_COMPREHENSIVE_AUDIT_COMMAND_V1.1.md` | **Recommended** | CONS-002 GF parity; CONS-027 PlannerStore | `DivePlanPackageBuilder` preset triplets; planner lifecycle |
| 04 | `04-MASTER_MAIN_CODE_SYNC_SECURITY_PERFORMANCE_AUDIT_COMMAND_V1.1.md` | **Recommended** | CONS-003–005 sync; CONS-006–007 depth | in-flight release; diveImportAck; signed tombstones; entitlement authority |
| 05 | `05-MASTER_RELEASE_QA_EVIDENCE_COMPLIANCE_AUDIT_COMMAND_V1.1.md` | **Recommended** | Full gate matrix refresh | Claims vs evidence; physical/external still PENDING |
| 06 | `06-MASTER_DOCUMENTATION_REPOSITORY_ALIGNMENT_AUDIT_COMMAND_V1.1.md` | **Recommended** | CONS-001 command repair; CONS-034 INDEX | INDEX/README/feature matrix; command SHA alignment |

## Conditional reruns

| # | Audit command file | Rerun status | Trigger | Notes |
|---|-------------------|--------------|---------|-------|
| 03 | `03-MASTER_UI_UX_FULL_DEEP_COMPREHENSIVE_AUDIT_COMMAND_V2.2.md` | **Optional** | CONS-019 WAO UI path | No layout changes; policy gate only |
| 00 | `00-MASTER_SUPER_ORCHESTRATOR_...V1.2.md` | **After 01–06** | Refresh consolidated % | Recompute CONS register statuses |

## Not required for this remediation wave

| Item | Reason |
|------|--------|
| 03 full UI pixel regression | No mockup/production UI layout changes |
| Physical QA matrix execution | Remediation explicitly deferred — templates only |

---

## Pre-rerun gates

```bash
git branch --show-current   # must be main
bash Scripts/validate_commands_for_cursor_integrity.sh
bash Scripts/validate_consolidated_software_readiness.sh   # after Watch test compile fix
```

---

## Post-rerun deliverables to refresh

- `MASTER_CONSOLIDATED_FINDINGS_REGISTER_CURRENT.csv`
- `MASTER_CONSOLIDATED_AUDIT_AND_NON_REGRESSIVE_REMEDIATION_PLAN_CURRENT.md`
- `Docs/INDEX.md` (CONS-034)
- This checklist — mark reruns **COMPLETE** with audit commit SHA

---

## Acceptance

Audit re-run checklist is **OPEN** until read-only audits 01, 02, 04, 05, 06 execute post-remediation. Software remediation does **not** claim final orchestrator readiness 100% until rerun evidence exists.

```
POST_REMEDIATION_AUDIT_RERUN: PENDING
CONS-001_COMMAND_INTEGRITY: PASS (prerequisite met)
SOFTWARE_READINESS: 100% (software-actionable scope)
PHYSICAL_QA: PENDING_PHYSICAL
APP_STORE_READY: NOT_READY
```
