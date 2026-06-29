# Master Consolidated Post-Remediation Audit Rerun Checklist

**Date:** 2026-06-28  
**Remediation:** consolidated software remediation @ `main` @ `5d757cc`  
**Pre-remediation baseline:** `7dfefe2`  
**Report:** [`MASTER_CONSOLIDATED_SOFTWARE_REMEDIATION_TO_100_REPORT_CURRENT.md`](MASTER_CONSOLIDATED_SOFTWARE_REMEDIATION_TO_100_REPORT_CURRENT.md)

**Policy:** Read-only audit re-runs only. **CONS-001 repaired** — filename-based launch of `commands_for_cursor/01`–`04` is now trustworthy.

---

## Mandatory reruns (software remediation scope)

| # | Audit command file | Rerun status | Trigger | Verify |
|---|-------------------|--------------|---------|--------|
| 01 | `01-MASTER_WATCH_FULL_COMPUTER_FORENSIC_AUDIT_COMMAND_V2.1.md` | **COMPLETE** @ `5d757cc` | CONS-008 oracle; CONS-017/018/038 tests; CONS-019 WAO gate | Oracle traceability; startup routing; GF import — **36/36 targeted tests PASS** |
| 02 | `02-MASTER_IOS_FULL_DEEP_COMPREHENSIVE_AUDIT_COMMAND_V1.1.md` | **COMPLETE** @ `5d757cc` | CONS-002 GF parity; CONS-027 PlannerStore | GF triplets + `gradientFactorPreset`; PlannerStore deinit — **15/15 targeted, 1527/1527 full iOS** |
| 04 | `04-MASTER_MAIN_CODE_SYNC_SECURITY_PERFORMANCE_AUDIT_COMMAND_V1.1.md` | **COMPLETE** @ `5d757cc` | CONS-003–005 sync; CONS-006–007 depth | in-flight release; diveImportAck; signed tombstones; entitlement authority — **P1=0** |
| 05 | `05-MASTER_RELEASE_QA_EVIDENCE_COMPLIANCE_AUDIT_COMMAND_V1.1.md` | **COMPLETE** @ `5d757cc` | Full gate matrix refresh | `validate_consolidated_software_readiness.sh` **PASS** |
| 06 | `06-MASTER_DOCUMENTATION_REPOSITORY_ALIGNMENT_AUDIT_COMMAND_V1.1.md` | **COMPLETE** @ `5d757cc` | CONS-001 command repair; CONS-034 INDEX | Command integrity **PASS**; INDEX wave **PARTIAL** (README/matrix drift P2) |

## Conditional reruns

| # | Audit command file | Rerun status | Trigger | Notes |
|---|-------------------|--------------|---------|-------|
| 03 | `03-MASTER_UI_UX_FULL_DEEP_COMPREHENSIVE_AUDIT_COMMAND_V2.2.md` | **Optional — skipped** | CONS-019 WAO UI path | No layout changes; policy gate only |
| 00 | `00-MASTER_SUPER_ORCHESTRATOR_...V1.2.md` | **Recommended next** | Refresh consolidated % | Recompute CONS register after 01–06 reruns |

---

## Pre-rerun gates

```bash
git branch --show-current   # must be main
git rev-parse --short HEAD  # 5d757cc
bash Scripts/validate_commands_for_cursor_integrity.sh   # PASS
bash Scripts/validate_consolidated_software_readiness.sh # PASS @ 5d757cc
```

---

## Post-rerun deliverables refreshed

- All `MASTER_WATCH_FULL_COMPUTER_*` (Command 01)
- All `MASTER_IOS_*` + `MASTER_GF_PRESET_SYNC_SCHEMA_MATRIX_CURRENT.csv` (Command 02)
- All `MASTER_MAIN_*` sync/security/performance matrices (Command 04)
- Release/claims/readiness matrices (Command 05)
- Documentation alignment matrices + INDEX Command 06 block (Command 06)

---

## Acceptance

```
POST_REMEDIATION_AUDIT_RERUN: COMPLETE @ 5d757cc (01, 02, 04, 05, 06)
CONS-001_COMMAND_INTEGRITY: PASS
validate_consolidated_software_readiness.sh: PASS
SOFTWARE_READINESS: 100% (software-actionable scope)
INTERNAL_TESTFLIGHT_SOFTWARE_READINESS: READY
PHYSICAL_QA: PENDING_PHYSICAL
EXTERNAL_VALIDATION: PENDING_EXTERNAL_VALIDATION
APP_STORE_READY: NOT_READY
DOCUMENTATION_READINESS: 72% (README/feature matrix P2 drift — doc-only)
```
