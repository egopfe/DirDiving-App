# Master Consolidated Post-Remediation Audit Rerun Checklist

**Date:** 2026-06-29  
**Remediation:** consolidated software remediation @ `main` @ `5d757cc`  
**Orchestrator 00 refresh:** `4d415c0` (prior @ `8ae1034`)  
**Pre-remediation baseline:** `7dfefe2`  
**Report:** [`MASTER_CONSOLIDATED_SOFTWARE_REMEDIATION_TO_100_REPORT_CURRENT.md`](MASTER_CONSOLIDATED_SOFTWARE_REMEDIATION_TO_100_REPORT_CURRENT.md) · [`MASTER_CONSOLIDATED_AUDIT_AND_NON_REGRESSIVE_REMEDIATION_PLAN_CURRENT.md`](MASTER_CONSOLIDATED_AUDIT_AND_NON_REGRESSIVE_REMEDIATION_PLAN_CURRENT.md)

**Policy:** Read-only audit re-runs only. **CONS-001 repaired** — filename-based launch of `commands_for_cursor/01`–`04` is trustworthy.

---

## Mandatory reruns (software remediation scope)

| # | Audit command file | Rerun status | Trigger | Verify |
|---|-------------------|--------------|---------|--------|
| 01 | `01-MASTER_WATCH_FULL_COMPUTER_FORENSIC_AUDIT_COMMAND_V2.1.md` | **COMPLETE** @ `5d757cc` | CONS-008 oracle; CONS-017/018/038 tests; CONS-019 WAO gate | **36/36** targeted tests PASS |
| 02 | `02-MASTER_IOS_FULL_DEEP_COMPREHENSIVE_AUDIT_COMMAND_V1.1.md` | **COMPLETE** @ `5d757cc` | CONS-002 GF parity; CONS-027 PlannerStore | **1527/1527** iOS tests |
| 04 | `04-MASTER_MAIN_CODE_SYNC_SECURITY_PERFORMANCE_AUDIT_COMMAND_V1.1.md` | **COMPLETE** @ `5d757cc` | CONS-003–005 sync; CONS-006–007 depth | **P1=0** |
| 05 | `05-MASTER_RELEASE_QA_EVIDENCE_COMPLIANCE_AUDIT_COMMAND_V1.1.md` | **COMPLETE** @ `5d757cc` | Full gate matrix refresh | `validate_consolidated_software_readiness.sh` **PASS** |
| 06 | `06-MASTER_DOCUMENTATION_REPOSITORY_ALIGNMENT_AUDIT_COMMAND_V1.1.md` | **COMPLETE** @ `5d757cc` | CONS-001; CONS-034 INDEX | Command integrity **PASS** |

## Conditional reruns

| # | Audit command file | Rerun status | Trigger | Notes |
|---|-------------------|--------------|---------|-------|
| 03 | `03-MASTER_UI_UX_FULL_DEEP_COMPREHENSIVE_AUDIT_COMMAND_V2.2.md` | **COMPLETE** @ `4d415c0` | CONS-019 WAO UI path | **PARTIAL** — software PASS; physical/pixel PENDING |
| 00 | `00-MASTER_SUPER_ORCHESTRATOR_...V1.2.md` | **COMPLETE** @ `4d415c0` | All six audits refreshed | UPSTREAM_AUDITS_COMPLETE **PASS** |

---

## Pre-rerun gates

```bash
git branch --show-current   # must be main
git rev-parse --short HEAD  # 4d415c0
bash Scripts/validate_commands_for_cursor_integrity.sh   # PASS
bash Scripts/validate_consolidated_software_readiness.sh # PASS
```

---

## Acceptance

```
POST_REMEDIATION_AUDIT_RERUN: COMPLETE @ 4d415c0 (01–06)
ORCHESTRATOR_00_REFRESH: COMPLETE @ 4d415c0
UPSTREAM_AUDITS_COMPLETE: PASS
CONS-001_COMMAND_INTEGRITY: PASS
validate_consolidated_software_readiness.sh: PASS
SOFTWARE_READINESS: 100% (software-actionable scope)
INTERNAL_TESTFLIGHT_SOFTWARE_READINESS: READY
PHYSICAL_QA: PENDING_PHYSICAL
EXTERNAL_VALIDATION: PENDING_EXTERNAL_VALIDATION
APP_STORE_READY: NOT_READY
OVERALL_RELEASE_READINESS: ~72%
RECOMMENDED_NEXT: Physical/external QA OR doc-only README/matrix OR legal/release packaging
```
