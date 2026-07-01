# App Store / TestFlight Blockers — CURRENT

**Command:** 05 — `05-MASTER_RELEASE_QA_EVIDENCE_COMPLIANCE_AUDIT_COMMAND_V1.5.md`  
**Baseline:** `main` @ `2c30412`  
**Audit date:** 2026-07-01

---

## Internal TestFlight Blockers

| ID | Severity | Blocker | Status | Remediation |
|---|---|---|---|---|
| REL-P2-001 | P2 | Watch routing test drift (WFC-P2-005) — 13 failures | OPEN | Align WAO tests with post-Apnea `divingModeSelection` step |
| REL-P2-002 | P2 | SnorkelingRouteProgressCalculator test failure | OPEN | Fix progress-at-start assertion |
| REL-P1-001 | P1 | Physical QA disclosure required on TestFlight notes | OPEN | Add truthful pending-physical wording |
| REL-P2-003 | P2 | Developer shallow FC toggle TestFlight exposure risk (SDG-008) | OPEN | Verify internal-only labeling in TF metadata |

**Internal TestFlight software blockers:** **NONE at P0/P1 software level** — iOS 1655 PASS, builds PASS, CONS-046 PASS.

---

## External TestFlight Blockers

| ID | Severity | Blocker | Status |
|---|---|---|---|
| WFC-P1-001 | P1 | External Bühlmann validation not executed | OPEN |
| CONS-042 | P1 | Shallow/full depth wet QA 0% | OPEN |
| WAO-PHY-001 | P1 | Water auto-open physical end-to-end | OPEN |
| HWC-PHY-004 | P1 | Water Lock physical QA | OPEN |
| CONS-048 | P1 | Snorkeling 12 field QA templates (0/12) | OPEN |
| WFC-P2-001 | P2 | CMAltimeter physical CoreMotion samples | OPEN |
| HWC-PHY-001..003 | P2 | Crown / Action Button physical | OPEN |
| MASB-P-02 | P1 | Physical iPhone QA matrix | OPEN |
| MASB-P-03 | P1 | Paired-device sync field QA | OPEN |
| WFC-P2-005 | P2 | Watch test suite not fully green | OPEN |

---

## App Store Blockers

All external TestFlight blockers **plus:**

| ID | Severity | Blocker | Status |
|---|---|---|---|
| CONS-044 | P1 | Legal counsel marketing sign-off | OPEN |
| MASB-P-07 | P2 | App Store screenshots / metadata incomplete | OPEN |
| MASB-P-10 | P2 | Full-depth entitlement not provisioned | OPEN |
| MASB-P-11 | P2 | Manual accessibility QA | OPEN |
| MASB-P-12 | P3 | Incident / rollback drill not executed | OPEN |
| REL-P1-002 | P1 | EN13319 / ISO 6425 — no certification claim permitted | N/A (policy) |

---

## TestFlight Metadata Truthfulness

| Check | Status |
|---|---|
| No certified dive computer claim | **PASS** |
| No physical QA passed claim | **PASS** |
| Shallow-depth limitation disclosed | **PASS** |
| Developer shallow testing labeled internal | **PASS** (verify TF notes) |
| Apnea recovery not medical | **PASS** |
| Planner reference-only | **PASS** |
| CCR reference-only | **PASS** |

---

## Summary

```text
INTERNAL_TESTFLIGHT_BLOCKERS (software P0/P1): NONE
INTERNAL_TESTFLIGHT_BLOCKERS (P2 polish): WFC-P2-005, Snorkeling progress test
EXTERNAL_TESTFLIGHT_BLOCKERS: 10+ physical/external items
APP_STORE_BLOCKERS: External blockers + legal + assets + full-depth entitlement
```
