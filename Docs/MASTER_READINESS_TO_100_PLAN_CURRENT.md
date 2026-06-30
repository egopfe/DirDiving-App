# DIR DIVING — Master Readiness to 100% Plan (Current)

**Command:** 05 — `05-MASTER_RELEASE_QA_EVIDENCE_COMPLIANCE_AUDIT_COMMAND_V1.2.md`  
**Date:** 2026-06-30  
**Branch:** `main` @ `451f8fb`  
**Current overall release readiness:** **62%**  
**Software-actionable readiness:** **88%** (regressed from 100% due to IOS-P1-001 + CONS-046)  
**Target:** **100% evidence + compliance readiness** (physical, external, legal, ASC)

---

## Readiness layers

| Layer | Current | Target | Gap | Status class |
|-------|--------:|-------:|----:|--------------|
| Automated unit/integration (Watch) | **95%** | 100% | 5% | PARTIAL — 353/355 @ audit 01 |
| Automated unit/integration (iOS) | **0%** | 100% | 100% | **BLOCKED** — IOS-P1-001 |
| Command integrity automation | **0%** | 100% | 100% | **FAIL** — CONS-046 |
| Simulator validation scripts | **95%** | 100% | 5% | PARTIAL — script drift |
| Claims / legal software posture | **98%** | 100% | 2% | SOFTWARE_READY |
| Privacy manifest / engineering disclosure | **100%** | 100% | 0% | SOFTWARE_READY |
| Shallow depth software gate | **100%** | 100% | 0% | SOFTWARE_READY |
| Water auto-open software gate | **100%** | 100% | 0% | SOFTWARE_READY |
| Hardware controls software gate | **100%** | 100% | 0% | SOFTWARE_READY |
| GF preset software gate | **100%** | 100% | 0% | SOFTWARE_READY |
| Snorkeling software (route/sync) | **92%** | 100% | 8% | SOFTWARE_READY |
| Snorkeling field QA (12 templates) | **0%** | 100% | 100% | PENDING_PHYSICAL (CONS-048) |
| Physical Watch evidence | **0%** | 100% | 100% | PENDING_PHYSICAL |
| Physical iPhone evidence | **0%** | 100% | 100% | PENDING_PHYSICAL |
| Paired-device evidence | **0%** | 100% | 100% | PENDING_PHYSICAL |
| CMAltimeter physical gate | **0%** | 100% | 100% | PENDING_PHYSICAL |
| Shallow wet / WAO / HW physical | **0%** | 100% | 100% | PENDING_PHYSICAL |
| External reference validation | **0%** | 100% | 100% | PENDING_EXTERNAL_VALIDATION |
| App Store / legal sign-off | **35%** | 100% | 65% | PENDING_LEGAL_REVIEW |

---

## P0 — Before any safety-critical TestFlight (must be zero)

**P0 open items: 0** — no false physical/external claims; no unsupported certification claims in software.

---

## P1 — Before internal TestFlight

| ID | Work item | Status @ 451f8fb | Action |
|----|-----------|------------------|--------|
| P1-01 | iOS Algorithm Tests compile+run | **FAIL** | Fix IOS-P1-001 Snorkeling compile |
| P1-02 | Command integrity script | **FAIL** | Fix CONS-046 paths to V2.2/V1.2/V2.3 |
| P1-03 | GF iOS→Watch preset mismatch | **CLOSED** | CONS-002 @ 451f8fb |
| P1-04 | MAIN sync P1 findings | **CLOSED** | CONS-003..005 |
| P1-05 | Shallow FC TF labeling | **OPEN** | SDG-008 disclosure in TF notes |
| P1-06 | Depth tier metadata CI check | **OPEN** | MASTER-DEPTH-002 |
| P1-07 | Basic physical install smoke | **PENDING_PHYSICAL** | Ultra + iPhone install log |
| P1-08 | Paired sync smoke | **PENDING_PHYSICAL** | One row of WATCH_IOS_SYNC matrix |
| P1-09 | Snorkeling 12 QA templates | **PENDING_PHYSICAL** | CONS-048 Batch-8 |

**Internal TestFlight software lane: CONDITIONAL** — fix P1-01/P1-02; disclose all physical gaps.

---

## P2 — Before external TestFlight

All physical matrices (38 Watch + 16 iPhone + 8 paired + WAO + HW + shallow wet + 12 Snorkeling), external validation (4 campaigns), App Store assets — **NOT EXECUTED**.

---

## P3 — Before App Store

Legal counsel, accessibility manual QA, localization spot check, incident drill — **PENDING**.

---

## Validation evidence @ 451f8fb

```bash
./Scripts/validate_commands_for_cursor_integrity.sh   # FAIL (CONS-046)
xcodebuild test -scheme "DIRDiving iOS Algorithm Tests"  # BUILD FAILED (IOS-P1-001)
xcodebuild build -scheme "DIRDiving iOS"               # BUILD SUCCEEDED
xcodebuild build -scheme "DIRDiving Watch App"         # BUILD SUCCEEDED
```

---

## Critical path to 100%

1. Fix IOS-P1-001 (Snorkeling test compile)  
2. Fix CONS-046 (integrity script paths)  
3. Execute CONS-048 Snorkeling Batch-8 (12 field templates)  
4. Execute legacy physical campaigns (Ultra, CMAltimeter, WAO, HW, paired sync)  
5. Execute external Bühlmann/Subsurface/CCR validation  
6. Legal counsel + ASC metadata + incident drill  

---

**Status:** OPEN @ `451f8fb` · 2026-06-30
