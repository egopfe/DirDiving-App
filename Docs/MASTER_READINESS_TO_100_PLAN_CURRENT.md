# DIR DIVING — Master Readiness to 100% Plan (Current)

**Command:** 05 — `05-MASTER_RELEASE_QA_EVIDENCE_COMPLIANCE_AUDIT_COMMAND_V1.1.md`  
**Date:** 2026-06-28  
**Branch:** `main` @ `5d757cc`  
**Pre-remediation baseline:** `7dfefe2`  
**Current overall release readiness:** **72%**  
**Software-actionable readiness:** **100%**  
**Target:** **100% evidence + compliance readiness** (physical, external, legal, ASC)

---

## Readiness layers

| Layer | Current | Target | Gap | Status class |
|-------|--------:|-------:|----:|--------------|
| Automated unit/integration (remediation gates) | **100%** | 100% | 0% | SOFTWARE_READY |
| Simulator validation scripts | **100%** | 100% | 0% | SOFTWARE_READY |
| Claims / legal software posture | **100%** | 100% | 0% | SOFTWARE_READY |
| Privacy manifest / engineering disclosure | **100%** | 100% | 0% | SOFTWARE_READY |
| Shallow depth software gate | **100%** | 100% | 0% | SOFTWARE_READY |
| Water auto-open software gate | **100%** | 100% | 0% | SOFTWARE_READY |
| Hardware controls software gate | **100%** | 100% | 0% | SOFTWARE_READY |
| GF preset software gate | **100%** | 100% | 0% | SOFTWARE_READY |
| Physical Watch evidence | **0%** | 100% | 100% | PENDING_PHYSICAL |
| Physical iPhone evidence | **0%** | 100% | 100% | PENDING_PHYSICAL |
| Paired-device evidence | **0%** | 100% | 100% | PENDING_PHYSICAL |
| CMAltimeter physical gate | **0%** | 100% | 100% | PENDING_PHYSICAL |
| Shallow wet / WAO / HW physical | **0%** | 100% | 100% | PENDING_PHYSICAL |
| External reference validation | **0%** | 100% | 100% | PENDING_EXTERNAL_VALIDATION |
| App Store / legal sign-off | **35%** | 100% | 65% | PENDING_LEGAL_REVIEW |

Software-only readiness is **100%** on `5d757cc` (`validate_consolidated_software_readiness.sh` PASS). Path to **100% overall** is dominated by **field evidence packs and external/legal gates**.

---

## P0 — Before any safety-critical TestFlight (must be zero)

**P0 open items: 0** — unchanged from pre-remediation; no false physical/external claims.

---

## P1 — Before internal TestFlight

| ID | Work item | Status @ 5d757cc | Action |
|----|-----------|------------------|--------|
| P1-01 | Remediation automated test gates green | **PASS** | Consolidated script PASS |
| P1-02 | Fix GF iOS→Watch preset mismatch | **CLOSED** | CONS-002 @ 5d757cc |
| P1-03 | MAIN sync P1 findings | **CLOSED** | CONS-003..005 |
| P1-04 | Shallow FC TF labeling | **OPEN** | SDG-008 disclosure in TF notes |
| P1-05 | Depth tier metadata CI check | **OPEN** | MASTER-DEPTH-002 |
| P1-06 | Basic physical install smoke | **PENDING_PHYSICAL** | Ultra + iPhone install log |
| P1-07 | Paired sync smoke | **PENDING_PHYSICAL** | One row of WATCH_IOS_SYNC matrix |

**Internal TestFlight software lane: READY** with disclosure of open P1-04/P1-05 and all physical gaps.

---

## P2 — Before external TestFlight

All physical matrices (38 Watch + 16 iPhone + 8 paired + WAO + HW + shallow wet), external validation (4 campaigns), App Store assets — **NOT EXECUTED**.

---

## P3 — Before App Store

Legal counsel, accessibility manual QA, localization spot check, incident drill — **PENDING**.

---

## Validation evidence @ 5d757cc

```bash
bash Scripts/validate_consolidated_software_readiness.sh  # PASS (~15 min)
```

Remediation-critical tests: iOS 23/23, Watch 42/42 (consolidated script lane).

---

## Final block

```text
SOFTWARE_READINESS: 100%
INTERNAL_TESTFLIGHT_SOFTWARE_READINESS: READY
PHYSICAL_QA: 0% / PENDING_PHYSICAL
EXTERNAL_VALIDATION: 0% / PENDING_EXTERNAL_VALIDATION
APP_STORE_READY: NOT_READY
OVERALL_RELEASE_READINESS: 72%
```
