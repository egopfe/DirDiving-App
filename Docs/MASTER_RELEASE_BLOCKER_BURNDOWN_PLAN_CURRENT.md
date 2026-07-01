# Release Blocker Burndown Plan — CURRENT

**Baseline:** `main` @ `2c30412`  
**Date:** 2026-07-01  
**Orchestrator:** V1.5

---

## Summary

| Category | Open blockers | Software closed @ 2c30412 |
|----------|--------------:|---------------------------|
| Internal TestFlight (software) | **0 P0/P1** | CONS-046; CONS-049; IOS-P1-001 **FIXED** |
| Internal TestFlight (disclosure) | **1 conditional** | Physical/external honestly pending |
| External TestFlight | **10** | Physical + external + legal |
| App Store | **12** | + P0 legacy docs |
| Physical QA | **14** | 0% executed |
| External validation | **5** | 0% executed |
| Legal / claims | **2** | CONS-044; CONS-053 |

**P0 safety (FC math): 0** · **P0 documentation: 2** · **P1 open gates: 10**

---

## Internal TestFlight blockers

| Blocker_ID | Finding_ID | Severity | Why it blocks | Current evidence | Required remediation | Exit criteria |
|------------|------------|----------|---------------|------------------|----------------------|---------------|
| ITF-SW-001 | CONS-046 | P1 | Was script integrity | PASS @ 2c30412 | **CLOSED** @ 6a0005b | Script PASS |
| ITF-SW-002 | CONS-049 / IOS-P1-001 | P1 | Was iOS test lane | 1655/1655 PASS | **CLOSED** @ 7a429a7 | iOS tests green |
| ITF-SW-003 | CONS-050 / WFC-P2-005 | P2 | Watch suite 1139/1152 | 0 FC failures | R09 test alignment | 1152/1152 PASS |
| ITF-DISC-001 | Physical/external disclosure | n/a | Must not claim field validation | Audits PARTIAL | TestFlight notes honest | No false physical claims |

**Internal TestFlight software verdict:** **READY** — conditional on disclosure of pending physical/external gates.

---

## External TestFlight blockers

| Blocker_ID | Finding_ID | Severity | Why it blocks | Required remediation | Required physical QA | Exit criteria |
|------------|------------|----------|---------------|----------------------|----------------------|---------------|
| ETF-001 | CONS-009 / WFC-P1-001 | P1 | No external Bühlmann evidence | External validation campaign | Yes (controlled) | Signed BUHLMANN_EXTERNAL |
| ETF-002 | CONS-010 | P1 | No wet FC QA | Physical FC matrix | Yes | Signed Ultra wet artifacts |
| ETF-003 | CONS-021 | P1 | WAO not wet-tested | WAO physical QA | Yes | WATCH_WATER_AUTO_OPEN pack |
| ETF-004 | CONS-022 | P1 | Water Lock HW not tested | Underwater HW matrix | Yes | HW interaction artifacts |
| ETF-005 | CONS-042 | P1 | Shallow/full wet QA 0% | Shallow depth gate | Yes | Shallow wet matrix PASS |
| ETF-006 | CONS-048 | P1 | Snorkeling 0/12 field QA | 12 SNORKELING_* procedures | Yes | 12/12 folders PASS |
| ETF-007 | CONS-011 | P1 | Paired sync not field-tested | Paired device QA | Yes | Paired QA pack |
| ETF-008 | CONS-012 | P1 | Manual a11y pending | Accessibility field matrix | Yes | VoiceOver notes signed |
| ETF-009 | APNEA-PHY-001 | P1 | Apnea wet QA 0% | Apnea physical matrix | Yes | Apnea wet artifacts |
| ETF-010 | CONS-050 | P2 | Watch CI not fully green | R09 WAO test fix | No | 1152/1152 PASS |

---

## App Store blockers

All External TestFlight blockers **plus:**

| Blocker_ID | Finding_ID | Severity | Why it blocks | Exit criteria |
|------------|------------|----------|---------------|---------------|
| AS-001 | CONS-044 | P1 | Legal/marketing not signed | Counsel approval |
| AS-002 | CONS-013 | P1 | PDF physical render pending | Device PDF golden |
| AS-003 | CONS-053 | P0 | Legacy false App Store/CCR claims | Demote/repair 2 P0 docs |
| AS-004 | CONS-030 | P2 | Subsurface round-trip not validated | Desktop validation signed |
| AS-005 | CONS-033 | P2 | CCR external reference pending | Reference-only review |

---

## Burndown phases

### Phase A — Software gates (COMPLETE @ 2c30412)

- [x] CONS-046 V1.5 script integrity
- [x] CONS-049 / IOS-P1-001 iOS tests 1655 PASS
- [x] CONS-002..008 remediations verified
- [ ] CONS-050 WFC-P2-005 — **ACTIVE** (P2, non-FC)

### Phase B — Watch CI green (next software)

- [ ] Align WFC-P2-005 routing tests (R09)
- [ ] Fix CONS-051 Snorkeling progress test
- [ ] Rerun audits 01; 03; 04; 05

### Phase C — Documentation truth (before marketing)

- [ ] Repair CONS-053 P0 legacy claim docs
- [ ] Refresh CONS-054 INDEX/README @ 2c30412
- [ ] Reconcile INDEX SOFTWARE_READY vs PARTIAL audits

### Phase D — Physical QA (Batch 8)

- [ ] CONS-010 Watch FC wet
- [ ] CONS-021 WAO wet
- [ ] CONS-022 underwater HW
- [ ] CONS-042 shallow wet
- [ ] CONS-048 Snorkeling 12 procedures
- [ ] APNEA-PHY-001 Apnea wet

### Phase E — External validation + legal

- [ ] CONS-009 external Bühlmann
- [ ] CONS-043 GF external spot-check
- [ ] CONS-044 legal sign-off

---

**Expected command for Phase B:** R09 (WAO test alignment) — **not** Command 10/11.
